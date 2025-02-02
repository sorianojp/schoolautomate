<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "CIT";
boolean bolIsCIT = strSchCode.startsWith("CIT");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
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
    /**
		border-top: solid 1px #000000;
    	border-right: solid 1px #000000;
	**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    /**
	    border-left: solid 1px #000000;
    	border-bottom: solid 1px #000000;
	**/
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
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	if(WI.fillTextValue("show_1").equals("2")){%>
		<jsp:forward page="./class_list_cit_cr_print.jsp" />
	<%return;}
	if(WI.fillTextValue("show_1").equals("3")){%>
		<jsp:forward page="./class_list_cit_cr_excel.jsp" />
	<%return;}
	

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

ReportEnrollment reportEnrl= new ReportEnrollment();
vSubSecRef = reportEnrl.getClassListSubSecRefCIT(dbOP, request);
if(vSubSecRef == null)
	strErrMsg = reportEnrl.getErrMsg();
//System.out.println(vSubSecRef);




String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
if(!bolIsCIT) {
	astrConvertSem[1] = "First Term";
	astrConvertSem[2] = "Second Term";
	astrConvertSem[3] = "Third Term";
}


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

int iRowsPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iRowsPrinted = 0;

String strSubSecIndex = null;
String strSubCode     = null;
String strSubName     = null;
String strSection     = null;
String strIsLec       = null;
String strTimeRoomNo  = null;

String[] astrIsLec = {"Lec","Lab"};
int iPageNo = 0;int iCount;


Vector vScheduleDtls = null;
Vector vLabSchDtls   = null;

String strLecTime = null;
String strLabTime = null;
String strLecFac  = null;
String strLabFac  = null;
//System.out.println(vSubSecRef);
boolean bolForcePrint = false;
int iCount2 = 0; 
while(vSubSecRef.size() > 0) {
	strSubSecIndex = (String)vSubSecRef.remove(0);
	strSubCode     = (String)vSubSecRef.remove(0);
	strSubName     = (String)vSubSecRef.remove(0);
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
	if(vClassList == null || vClassList.size() == 0) {
		continue;
	}
	if(iCount2++ > 0)
		bolForcePrint = true;

	iPageNo = 0;iCount = 0;
	for(int i =0; i < vClassList.size();) {
		if(i > 0 || bolForcePrint){%>
			<DIV style="page-break-after:always" >&nbsp;</DIV>
		<%bolForcePrint = true;}%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
			 <tr>
			  <td width="70%" style="font-size:9px;">Date Printed: <%=strDateTimePrinted%></td>
			  <td width="30%" style="font-size:9px;" align="right">Page #: <%=++iPageNo%></td>
			</tr>
		  </table>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		  <%if(bolIsCIT){%>
			   <tr>
				  <td width="100%" style="font-size:18px;" align="center">C I T &nbsp;-&nbsp; U N I V E R S I T Y</td>
			</tr>
			<%}else{%>
			   <tr>
				  <td width="100%" style="font-size:18px;" align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
			</tr>
			<%}%>
			<tr>
			  <td align="center">
			  <%if(WI.fillTextValue("show_1").equals("0")){%>
				TEMPORARY 
			  <%}else{%>
				FINAL AND 
			  <%}%>
			  OFFICIAL LIST OF STUDENTS. 
			  <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>, SY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
			  <%if(WI.fillTextValue("show_1").equals("1") && bolIsCIT){%>
			  <br>
			  (Any correction must be reported to ETO within 3 days, otherwise, the data shall be considered true and correct)
			  <%}%><br>&nbsp;
			  </td>
			</tr>
		</table>
		<table  width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tr valign="top"> 
			<td width="46%" height="18">
			Subject Code: <%=strSubCode%></td>
			<td width="45%">
			Time: <%=strLecTime%>
			<%if(strLabTime != null){%><br>(LAB) <%=strLabTime%><%}%>			</td>
			<td width="9%">
			Type: <%=astrIsLec[Integer.parseInt(strIsLec)]%>	</td>
		  </tr>
		  <tr>
		    <td height="18">Descriptive Title: <%=strSubName%></td>
		    <td>&nbsp;</td>
		    <td>&nbsp;</td>
	      </tr>
		  <tr>
			<td height="18">Section: <%=strSection%></td>
		    <td colspan="2">Faculty:<%=WI.getStrValue(strLecFac)%>
			<%if(strLabFac != null){%><br>(LAB) <%=strLabFac%><%}%>			</td>
	      </tr>
		  <tr>
		    <td height="10">&nbsp;</td>
		    <td colspan="2">&nbsp;</td>
	      </tr>
		</table>
			
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td width="5%" class="thinborderTOPBOTTOM">Count</td>
					<td width="15%" class="thinborderTOPBOTTOM">ID Number</td>
					<td width="40%" class="thinborderTOPBOTTOM">Name</td>
					<td width="5%" class="thinborderTOPBOTTOM">Gender</td>
					<td width="30%" class="thinborderTOPBOTTOM">Course</td>
					<td width="5%" class="thinborderTOPBOTTOM">Year</td>
				</tr>
				<%
				
				for(iRowsPrinted = 0; i < vClassList.size(); i += 7, ++iRowsPrinted) {
					if(iRowsPerPg <= iRowsPrinted)
						break;
					%>
					<tr>
						<td height="14" style="font-size:11px;"><%=++iCount%>.</td>
						<td style="font-size:11px;"><%=vClassList.elementAt(i)%></td>
						<td style="font-size:11px;"><%=vClassList.elementAt(i + 1)%></td>
						<td align="center" style="font-size:11px;"><%=vClassList.elementAt(i + 2)%></td>
						<td style="font-size:11px;"><%=vClassList.elementAt(i + 3)%><%=WI.getStrValue((String)vClassList.elementAt(i + 4), " - ", "","")%></td>
						<td style="font-size:11px;"><%=WI.getStrValue((String)vClassList.elementAt(i + 5),"&nbsp;")%></td>
					</tr>
				<%}%>
			</table>
			
			
		
	<%}//outer for loop.%>
	<%if(bolIsCIT){%>
		<br>
		Reviewed By: ____________________________________________
	<%}%>
    <%}//while(vSubSecRef.size() > 0) %>


</body>
</html>
<%
dbOP.cleanUP();
%>