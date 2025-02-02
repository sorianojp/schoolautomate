<!-- 
	Class Record printing.. 
-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--

table#classgrid {
	font-family: verdana,arial,sans-serif;
	font-size:10px;
	color:#000000;
	border: 1px solid #000000;
	border-collapse: collapse;
}

table#classgrid td {
	font-size:10px;
	border: 1px solid #000000;
	background-color: #ffffff;
}

body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
		border-top: solid 1px #000000;
    	border-right: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;	
    }

    TD.thinborder {
	    border-left: solid 1px #000000;
    	border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
    }
    TD.thinborderBOTTOM {
   	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOPBOTTOM {
   	border-top: solid 1px #000000;
   	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<body onLoad="window.print();" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-print class list","class_list_cit_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
Vector vSecDetail = null;
Vector vClassList = null;
Vector vSubSecRef = null;

String[] astrConvertSem = {"SUMMER","1st Semester","2nd Semester","3rd Semester", "4th Semester"};
String strSYTerm = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))] +", AY "+WI.fillTextValue("sy_from")+" - "+
	WI.fillTextValue("sy_to");



ReportEnrollment reportEnrl= new ReportEnrollment();
vSubSecRef = reportEnrl.getClassListSubSecRefCIT(dbOP, request);
if(vSubSecRef == null)
	strErrMsg = reportEnrl.getErrMsg();


String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAdd  = SchoolInformation.getAddressLine1(dbOP, false, false);

if(strErrMsg != null){
	dbOP.cleanUP();
%>
<table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%return;}

String strDateTimePrinted = WI.formatDateTime(null, 5);

int iRowsPerPg = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"),"20"));
int iRowsPrinted = 0; int iIndexOf = 0;

String strSubSecIndex = null;
String strSubCode     = null;
String strSubName     = null;
String strSection     = null;
String strIsLec       = null;
String strTimeRoomNo  = null;

String[] astrIsLec = {"Lec","Lab"};
int iPageNo = 0;int iCount;
int iTotalPageCount = 0;

Vector vScheduleDtls = null;
Vector vLabSchDtls   = null;

String strLecTime = null;
String strLabTime = null;
String strLecFac  = null;
String strLabFac  = null;
//System.out.println(vSubSecRef);
boolean bolForcePrint = false;
int iCount2 = 0; 
String strFontSize = "";
while(vSubSecRef.size() > 0) {
		
	strSubSecIndex = (String)vSubSecRef.remove(0);
	strSubCode     = (String)vSubSecRef.remove(0);
	strSubName     = (String)vSubSecRef.remove(0);
	if(strSubName != null && strSubName.length() > 40) 
		strSubName = strSubName.substring(0,40);	
		
	strSection     = (String)vSubSecRef.remove(0);
	strIsLec       = (String)vSubSecRef.remove(0);
	vScheduleDtls  = (Vector)vSubSecRef.remove(0);
	//System.out.println("Printing : "+vScheduleDtls);
	strLecTime = null;strLabTime = null;strLecFac  = null;strLabFac  = null;

	
	if(vScheduleDtls != null && vScheduleDtls.size() > 0) {
		vLabSchDtls    = (Vector)vScheduleDtls.remove(0);
		strLecFac = (String)vScheduleDtls.remove(0);
		for(int p = 0; p<vScheduleDtls.size(); p+=3) {
        	if(strLecTime == null)
				strLecTime = (String)vScheduleDtls.elementAt(p + 2) + " Room: " + (String)vScheduleDtls.elementAt(p);
			else	
				strLecTime +=", "+ (String)vScheduleDtls.elementAt(p + 2) + " Room: " + (String)vScheduleDtls.elementAt(p);
		}
		if(vLabSchDtls != null && vLabSchDtls.size() > 0) {
			strLabFac = (String)vLabSchDtls.remove(0);
			for(int p = 0; p<vLabSchDtls.size(); p+=3) {
				if(strLabTime == null)
					strLabTime = (String)vLabSchDtls.elementAt(p + 2) + " Room: " + (String)vLabSchDtls.elementAt(p);
				else	
					strLabTime +=", "+ (String)vLabSchDtls.elementAt(p + 2) + " Room: " + (String)vLabSchDtls.elementAt(p);
			}
		}
	}
	

	vClassList = reportEnrl.getClassListDetailCIT(dbOP, strSubSecIndex, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
	if(vClassList == null || vClassList.size() == 0) 
		continue;
		
		
		
	
	if(iCount2++ > 0)
		bolForcePrint = true;
	iPageNo = 0;iCount = 0;
	iTotalPageCount = (vClassList.size()/7)/iRowsPerPg;
	if((vClassList.size()/7) % iRowsPerPg > 0)
		++iTotalPageCount;
	
	for(int i =0; i < vClassList.size();) {
		if(i > 0 || bolForcePrint){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
		<%bolForcePrint = true;}%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		   <tr>
		    
			  <td colspan="2" align="center" style="font-size:14px;"><%=strSchName%><BR>
			  <font style="font-size:12px;"><%=strSchAdd%><BR></font>			  </td>
			</tr>
		   <tr>
		       <td width="45%" style="font-size:13px;"><strong>OFFICIAL CLASS RECORD</strong></td>
	           <td width="55%" style="font-size:10px;" align="right">TOTAL STUDENTS : <%=vClassList.size() / 7%><br>
			   PAGE <%=++iPageNo%> OF <%=iTotalPageCount%></td>
		   </tr>
		</table>		
		
		<table width="100%" cellpadding="0" cellspacing="0"  id="classgrid">
				<tr>
				<td rowspan="2" colspan="3">SCHOOL</td>
				<td colspan="5" align="center"><strong>%</strong></td>
				<td colspan="5" align="center"><strong>%</strong></td>
				<td colspan="5" align="center"><strong>%</strong></td>
				<td colspan="5" align="center"><strong>%</strong></td>
				<td colspan="5" align="center"><strong>%</strong></td>
				<td colspan="5" align="center"><strong>%</strong></td>
				<td width="10%">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="5" height="30">&nbsp;</td>
				<td colspan="5">&nbsp;</td>
				<td colspan="5">&nbsp;</td>
				<td colspan="5">&nbsp;</td>
				<td colspan="5">&nbsp;</td>
				<td colspan="5">&nbsp;</td>
				<td align="center"><strong>REMARKS</strong></td>
			</tr>
			<tr>
				<td width="2%" height="40" align="center"><font size="1">No.</font></td>
				<td width="11%" align="center"><font size="1">STUDENT ID</font></td>
				<td width="17%" align="center"><font size="1">NAME OF STUDENT<br>
			    (Lastname, Firstname, MI)</font></td>				
				
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>

				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>

				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>

				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				<td width="2%">&nbsp;</td>
				
				
				<td>&nbsp;</td>
			</tr>
			<tr>
			    <td height="15" align="center">&nbsp;</td>
			    <td colspan="2">Date : <%=WI.getTodaysDate(1)%> <%=WI.formatDateTime(Long.parseLong(WI.getTodaysDate(28)),3)%></td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
		    </tr>
				<%
				
				for(iRowsPrinted = 0; i < vClassList.size(); i += 7, ++iRowsPrinted) {
					if(iRowsPerPg <= iRowsPrinted)
						break;
					%>
					
					<tr>
			    <td height="27" align="right"><%=++iCount%>.</td>
			    <td style="padding-left:3px;"><%=(String)vClassList.elementAt(i)%></td>
			    <td style="padding-left:3px;"><%=WI.getStrValue((String)vClassList.elementAt(i+1)).toUpperCase()%></td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
		    </tr>
					
				<%}%>
</table>
			
	<%
	if(i+7 >= vClassList.size()){
	%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<%

		while(iRowsPrinted < iRowsPerPg){
			iRowsPrinted++;
		%>
		<tr><td height="27">&nbsp;</td></tr>
		<%}%>
	</table>
	<%}%>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="43%">SUBJECT AND SCHEDULE:</td>
			<td width="27%">&nbsp;</td>
			<td width="30%">INSTRUCTOR:</td>
		</tr>
		<tr>
		    <td><%=strSubCode%><%=WI.getStrValue(strSection," Section : ","","")%> <%=WI.getStrValue(strLecTime,"<br>","","")%><%=WI.getStrValue(strLabTime,"<br>(LAB)","","")%></td>
		    <td><%=strSYTerm%></td>
		    <td><%=WI.getStrValue(strLecFac,"&nbsp;")%></td>
	    </tr>
	</table>
	
	<%}//outer for loop.%>
	
    <%}//while(vSubSecRef.size() > 0) %>


</body>
</html>
<%
dbOP.cleanUP();
%>