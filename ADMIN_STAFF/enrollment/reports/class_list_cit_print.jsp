<%

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "CIT";
	
boolean bolIsCIT = strSchCode.startsWith("CIT");
boolean bolIsSWU = strSchCode.startsWith("SWU");


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

//used for SWU
double dLecUnit = 0d;
double dLabUnit = 0d;
String strUnit = null;
String strSubIndex = null;
String strRoom = null;
String strTime = null;
String strDays  = null;
boolean bolTBA = false;

//System.out.println(vSubSecRef);
boolean bolForcePrint = false;
int iCount2 = 0; 


strTemp = 
	" select id_number from enrl_final_cur_list "+
	" join user_table on (user_table.user_index = enrl_final_cur_list.user_index) "+
	" where enrl_final_cur_list.is_valid =1 and sub_sec_index = ? "+
	" and new_added_dropped = 2 "+
	" and sy_from = "+WI.fillTextValue("sy_from")+" and current_semester = "+WI.fillTextValue("semester");
java.sql.PreparedStatement pstmtWithdraw = dbOP.getPreparedStatement(strTemp);
Vector vWithdrawList = new Vector();
java.sql.ResultSet rs = null;
while(vSubSecRef.size() > 0) {
	strSubSecIndex = (String)vSubSecRef.remove(0);
	strSubCode     = (String)vSubSecRef.remove(0);
	strSubName     = (String)vSubSecRef.remove(0);
	strSection     = (String)vSubSecRef.remove(0);
	strIsLec       = (String)vSubSecRef.remove(0);
	vScheduleDtls  = (Vector)vSubSecRef.remove(0);
	//System.out.println("Printing : "+vScheduleDtls);
	strLecTime = null;strLabTime = null;strLecFac  = null;strLabFac  = null;
	
	
	strRoom = null;
	strTime = null;
	strDays  = null;
if(bolIsSWU){
	strTemp = "select sub_index from E_SUB_SECTION where IS_VALID  = 1 and SUB_SEC_INDEX = "+strSubSecIndex;
	strSubIndex = dbOP.getResultOfAQuery(strTemp, 0);
	if(strSubIndex != null){
		strTemp = " select distinct lec_unit, lab_unit from curriculum where sub_index = "+strSubIndex+" and is_valid = 1 ";
		rs = dbOP.executeQuery(strTemp);
		if(rs.next()){
			dLecUnit = rs.getDouble(1);
			dLabUnit = rs.getDouble(2);
		}rs.close();
		if(dLecUnit > 0d || dLabUnit > 0d)
			strUnit = CommonUtil.formatFloat((dLecUnit+dLabUnit),1);

		
		if(strUnit == null || strUnit.length() == 0){
			strTemp = " select distinct unit from cculum_Masters where sub_index = "+strSubIndex+" and is_valid = 1 ";
			strUnit = dbOP.getResultOfAQuery(strTemp,0);
			if(strUnit != null)
				strUnit = CommonUtil.formatFloat(Double.parseDouble(strUnit),1);
		}
		if(strUnit == null || strUnit.length() == 0){
			strTemp = " select distinct main_unit from cculum_medicine where main_sub_index = "+strSubIndex+" and is_valid = 1 ";
			strUnit = dbOP.getResultOfAQuery(strTemp,0);
			if(strUnit != null)
				strUnit = CommonUtil.formatFloat(Double.parseDouble(strUnit),1);
		}
	}
}
	//vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	
if(vScheduleDtls != null && vScheduleDtls.size() > 0) {
		vLabSchDtls    = (Vector)vScheduleDtls.remove(0);
		
		strLecFac = (String)vScheduleDtls.elementAt(0);
		for(int p = 1; p<vScheduleDtls.size(); p+=3) {
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
		
if(bolIsSWU){			
			for(int p = 1; p < vScheduleDtls.size(); p+=3){
				if(strRoom == null)
					strRoom = (String)vScheduleDtls.elementAt(p);
				else
					strRoom += ", "+(String)vScheduleDtls.elementAt(p);
									
				strErrMsg = WI.getStrValue((String)vScheduleDtls.elementAt(p + 2));
				if(strErrMsg.length() > 0) {
					Vector vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);			
					strErrMsg = "";
					while(vTemp.size() > 0) {
						strTemp = (String)vTemp.remove(0);
						int iIndexOf = strTemp.indexOf(" ");
						if(iIndexOf > -1){
							bolTBA = false;					
							if(strTime == null){
								strTime = strTemp.substring(iIndexOf + 1).toLowerCase();						
								bolTBA = WI.getStrValue(strTime).trim().equalsIgnoreCase("0:00am-0:00am");
							}else{
								strTime += ", "+strTemp.substring(iIndexOf + 1).toLowerCase();			
								bolTBA = WI.getStrValue(strTemp).substring(iIndexOf + 1).trim().equalsIgnoreCase("0:00am-0:00am");		
							}
							
							if(strDays == null){
								if(bolTBA)
									strDays = "BY ARR";
								else
									strDays = strTemp.substring(0, iIndexOf);
							}else{
								if(bolTBA)
									strDays += ", BY ARR";
								else
									strDays += ", "+strTemp.substring(0, iIndexOf);
							}						
						}				
					}
				}
				
			}
	}	
}


	if(WI.fillTextValue("show_advised_date").length() > 0) 
		reportEnrl.avAddlInfo = new Vector();//to get advised date .. 
	
	if(WI.fillTextValue("show_notvalidated").length() > 0) 
		vClassList = reportEnrl.getClassListDetailCITIncNotValidated(dbOP, request, strSubSecIndex, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
	else
		vClassList = reportEnrl.getClassListDetailCIT(dbOP, strSubSecIndex, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
		
	if(vClassList == null || vClassList.size() == 0) {
		continue;
	}
	
	pstmtWithdraw.setString(1, strSubSecIndex);
	rs = pstmtWithdraw.executeQuery();
	while(rs.next())
		vWithdrawList.addElement(rs.getString(1));
	rs.close();
	
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
			<%}else if(bolIsSWU){%>
				<tr>
				<td width="100%"><div align="center"><font style="font-size:13px; font-weight:bold;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
					 <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
				  Teacher's Load/ Plantilla Master List<br><br>
				  Printed Date and Time : <%=WI.getTodaysDateTime()%>
				  </div></td>
			 </tr>
			<%}else{%>
			   <tr>
				  <td width="100%" style="font-size:18px;" align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
				</tr>
			<%}
			
			if(!bolIsSWU){
			%>
			
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
			  <%}%>
			  </td>
			</tr>
			<%}%>
		</table>
		
		
<%if(bolIsSWU){%>		
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="16%" height="20">Instructor</td>
		<td width="51%">: <%=WI.getStrValue(vScheduleDtls.elementAt(0))%></td>
		<td width="8%">Date</td>
		<td width="25%">: <%=WI.getStrValue(strDays)%></td>
	</tr>
	<tr>
		<td height="20">Subject</td>
		<td>: <%=strSection%>-<%=strSubCode%> &nbsp; Units : <%=WI.getStrValue(strUnit)%></td>
		<td>Time</td>
		<td>: <%=WI.getStrValue(strTime)%></td>
	</tr>
	<tr>
		<td height="20">Room</td>
		<td>: <%=strRoom%></td>
	</tr>
</table>


<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="thinborderTOPBOTTOM" width="8%" height="20" align="center">Seq. #</td>
		<td class="thinborderTOPBOTTOM" width="14%">Student No</td>
		<td class="thinborderTOPBOTTOM" width="40%" align="center">Name</td>
		<td class="thinborderTOPBOTTOM" width="15%" align="center">Course</td>
		<td class="thinborderTOPBOTTOM" width="8%" align="center">Year</td>
		<td class="thinborderTOPBOTTOM" width="15%" align="center">Date Enrolled</td>
	</tr>
	<%
	
	for(iRowsPrinted = 0; i < vClassList.size(); i += 7, ++iRowsPrinted) {
		if(iRowsPerPg <= iRowsPrinted)
			break;
		
		strTemp = "";
		if(vWithdrawList.indexOf(vClassList.elementAt(i)) > -1)
			strTemp = " W";
		
		%>
		<tr>
		<td height="22" align="center"><%=++iCount%>. <%=strTemp%></td>
		<td><%=vClassList.elementAt(i)%></td>		
		<td><%=vClassList.elementAt(i + 1)%></td>
		<td align="center"><%=vClassList.elementAt(i + 3)%><%=WI.getStrValue((String)vClassList.elementAt(i + 4), " - ", "","")%></td>
		<td align="center"><%=WI.getStrValue((String)vClassList.elementAt(i + 5),"N/A")%></td>		
		<td><%=WI.getStrValue((String)vClassList.elementAt(i + 6), "&nbsp;")%></td>
	</tr>
	<%}%>
</table>

<%}else{%>	
		
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
	<td width="46%">
	Subj & Section: <%=strSubCode%> - <%=strSection%>	</td>
	<td width="45%">
	Time: <%=strLecTime%>
	<%if(strLabTime != null){%><br>(LAB) <%=strLabTime%><%}%>
	</td>
	<td width="9%">
	Type: <%=astrIsLec[Integer.parseInt(strIsLec)]%>	</td>
  </tr>
  <tr>
	<td>Descriptive Title: <%=strSubName%></td>
	 <td colspan="2">Faculty:<%=WI.getStrValue(strLecFac)%>
	<%if(strLabFac != null){%><br>(LAB) <%=strLabFac%><%}%>
	</td>
	</tr>
</table>

<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="5%" class="thinborderTOPBOTTOM">Count</td>
		<td width="15%" class="thinborderTOPBOTTOM">ID Number</td>
		<td width="40%" class="thinborderTOPBOTTOM">Name</td>
		<td width="5%" class="thinborderTOPBOTTOM">Gender</td>
		<td width="20%" class="thinborderTOPBOTTOM">Course-Yr</td>
		<%if(bolIsCIT){%>
			<td width="15%" class="thinborderTOPBOTTOM">Date Enrolled</td>
		<%}%>
	</tr>
	<%
	
	for(iRowsPrinted = 0; i < vClassList.size(); i += 7, ++iRowsPrinted) {
		if(iRowsPerPg <= iRowsPrinted)
			break;
		%>
		<tr>
			<td height="16"><%=++iCount%>.</td>
			<td><%=vClassList.elementAt(i)%></td>
			<td><%=vClassList.elementAt(i + 1)%></td>
			<td align="center"><%=vClassList.elementAt(i + 2)%></td>
			<td><%=vClassList.elementAt(i + 3)%><%=WI.getStrValue((String)vClassList.elementAt(i + 4), " - ", "","")%>
				<%=WI.getStrValue((String)vClassList.elementAt(i + 5), " - ", "","")%></td>
			<%if(bolIsCIT){%>
				<td><%=WI.getStrValue((String)vClassList.elementAt(i + 6), "&nbsp;")%></td>
			<%}%>
		</tr>
	<%}%>
</table>
<%}%>		
		
		
			
			
			
			
		
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