<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<style type="text/css">
	
	@page {
		/*size:8.50in 3.70in; */
		margin:0in 0in 0in 0in; 
	}
	
	@media print { 
	  @page {
			/*size:8.50in 3.70in;*/ 
			margin:0in 0in 0in 0in; 
		}
	}
	
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
	-->
	</style>
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script>
function PrintPg() {
	window.print();
	if(confirm('Click OK to Finish Printing and Close this page'))
		window.close();
}
</script>
<body topmargin="0" bottommargin="0" onLoad="PrintPg();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-EXAM PERMIT-PRINT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}




//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

boolean bolIsBasic = false;
String strExamName = null;
String strExamPeriod = null;
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

String strStudID   = WI.fillTextValue("stud_id");
String strSYFrom   = WI.fillTextValue("sy_from");
String strSYTo     = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");
strExamPeriod      = WI.fillTextValue("pmt_schedule");

Vector vRetResult  = null;//get subject schedule information.

boolean bolAllowPrinting = false;


Vector vStudInfo   = null; 
double dDueForThisPeriod = 0d;
	enrollment.EnrlAddDropSubject enrlStudInfo = new enrollment.EnrlAddDropSubject();
	vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),	strStudID,strSYFrom, strSYTo, strSemester);
	if(vStudInfo == null) 
		strErrMsg = enrlStudInfo.getErrMsg();	





if(vStudInfo != null && vStudInfo.size() > 0) {
	bolIsBasic = ((String)vStudInfo.elementAt(5)).equals("0");

	strTemp = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+strExamPeriod;
	strExamName = dbOP.getResultOfAQuery(strTemp, 0);
	

	enrollment.FAAssessment FA = new enrollment.FAAssessment();
	//Vector vInstallmentDtls = FA.getInstallmentSchedulePerStudPerExamSch(dbOP,strExamPeriod, (String)vStudInfo.elementAt(0),
	//						strSYFrom,strSYTo,(String)vStudInfo.elementAt(4), strSemester) ;
	//if(vInstallmentDtls == null)
	//	strErrMsg = FA.getErrMsg();
	//else {
	//	dDueForThisPeriod = Double.parseDouble((String)vInstallmentDtls.elementAt(5));
		//System.out.println(dDueForThisPeriod);
	//	if(dDueForThisPeriod < 1d) {
	//		dDueForThisPeriod = 0d;
			bolAllowPrinting = true;
	//	}
	//}
}
if(bolAllowPrinting) {
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	vRetResult = reportEnrl.getStudentLoad(dbOP, strStudID,strSYFrom, strSYTo, strSemester);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();
	else {	
			reportEnrl.autoGenAdmSlipNum(dbOP, (String)vStudInfo.elementAt(0),strExamPeriod, strSYFrom, strSemester,(String)request.getSession(false).getAttribute("userIndex"));
			strTemp = "select DATE_PRINTED from ADM_SLIP_PRN_COUNT where user_index = "+vStudInfo.elementAt(0)+" and pmt_sch_index = "+strExamPeriod+
						" and is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;
			if(dbOP.getResultOfAQuery(strTemp, 0) == null)
				strTemp = ", DATE_PRINTED = '"+WI.getTodaysDate()+"',TIME_PRINTED = "+WI.getTodaysDate(28)+",PRINTED_BY = "+
						(String)request.getSession(false).getAttribute("userIndex");
			else	
				strTemp = "";
			
			strTemp = "update ADM_SLIP_PRN_COUNT set ALLOW_REPRINT = '0',PERMIT_VALIDITY=null "+strTemp+
						" where user_index = "+vStudInfo.elementAt(0)+" and pmt_sch_index = "+strExamPeriod+
						" and is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;
			///check 			
						
			
			dbOP.executeUpdateWithTrans(strTemp, null, null, false);
	}
}
%>

<%
int iRowCount = 0;
int iMaxRowCount = 7;
boolean bolPageBreak = false;

int iCount = 0;


if(vStudInfo != null && vStudInfo.size() > 0 && vRetResult != null && vRetResult.size() > 0){

for(int i=1; i< vRetResult.size(); ){
	if(bolPageBreak){
		bolPageBreak = false;
	%>
   <div style="page-break-after:always;">&nbsp;</div>
   <%}
//if(i == 1){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="41%" height="18"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
		<td width="34%"><%=strExamName.toUpperCase()%> EXAMINATION PERMIT</td>
		<td width="25%"><%=WI.getTodaysDateTime()%></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="48%" height="18"><%=WI.getStrValue(vStudInfo.elementAt(18)).toUpperCase()%></td>
		<%
		if(Integer.parseInt(strSemester) == 0)
			strTemp = strSYTo;
		else
			strTemp = strSYFrom+" - "+strSYTo;
		%>
		<td width="52%"><%if(!bolIsBasic){%><%=astrConvertSem[Integer.parseInt(strSemester)]%>, <%}else{%>S.Y. <%}%><%=strTemp%></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="18" width="28%"><%=(String)vStudInfo.elementAt(1)%></td>
		<%
		if(bolIsBasic)
			strTemp = dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(4)));
		else{
			strTemp = (String)vStudInfo.elementAt(16);
				if(vStudInfo.elementAt(6) != null)
					strTemp += " / "+WI.getStrValue((String)vStudInfo.elementAt(22));
		
			  strTemp += WI.getStrValue((String)vStudInfo.elementAt(4), " - ","","");
		}
		%>
		<td width="23%"><%=strTemp%></td>
		<td width="49%"><%=strStudID%></td>
	</tr>
</table>

<%//}%>

	<table width="100%" cellpadding="0" cellspacing="0"><tr><td valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
		  <tr>
		  	<td width="8%">&nbsp;</td>
			<td width="3%" height="18">No.</td>
			<td width="10%">Subject</td>
			<td width="30%">Description</td>
			<td width="4%" align="center">Units</td>
			<td width="12%" align="center">Days</td>
			<td width="20%" align="center">Time</td>
			<td width="13%">Room No.</td>
		  </tr>
		   <%
		   
		   for(; i< vRetResult.size(); i += 11){
		   	strTemp = (String)vRetResult.elementAt(i+1);
		   	if(strTemp != null && strTemp.length() > 25)
		   		strTemp = strTemp.substring(0,25);
			strErrMsg = (String)vRetResult.elementAt(i);
		   	if(strErrMsg != null && strErrMsg.startsWith("NSTP") && strErrMsg.indexOf("(")> 0)
		   		strErrMsg = strErrMsg.substring(0, strErrMsg.indexOf("("));
			
							
			String strTime = null;
			String strDay = null;
			String strTemp2 = null;
			String strErrMsg2 = (String)vRetResult.elementAt(i + 2);
			
			if(strErrMsg2 != null) {
				Vector vTemp = CommonUtil.convertCSVToVector(strErrMsg2, "<br>",true);			
				while(vTemp.size() > 0) {
					strTemp2 = (String)vTemp.remove(0);
					int iIndexOf = strTemp2.indexOf(" ");
					if(iIndexOf > -1){
						if(strTime == null)
							strTime = strTemp2.substring(iIndexOf + 1).toLowerCase();
						else
							strTime += "<br>"+strTemp2.substring(iIndexOf + 1).toLowerCase();
						
						if(strDay == null)
							strDay = strTemp2.substring(0, iIndexOf);
						else{
							strDay += "<br>"+strTemp2.substring(0, iIndexOf);
							iRowCount++;
						}
					}				
				}
			}
%>	
			  <tr>
			  	<td valign="top" style="border-bottom:solid 1px #000000;">&nbsp;</td>
				<td valign="top" height="18"><%=++iCount%>.</td>
				<td valign="top"><%=strErrMsg%></td>
				<%
				if(strTemp.length() > 15)
					strTemp = strTemp.substring(0,15);
				%>
				<td valign="top"><%=strTemp%></td>
				<td valign="top" align="center"><%=(String)vRetResult.elementAt(i+9)%></td>
				<td valign="top" align="center"><%=WI.getStrValue(strDay,"&nbsp;")%></td>
				<td valign="top"><%=WI.getStrValue(strTime,"&nbsp;")%></td>
				<%
				strTemp  = WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;");
				if(strTemp.length() > 8)
					strTemp = strTemp.substring(0,8);
				%>
				<td valign="top"><%=strTemp%></td>
			  </tr>
		  <%}
		  	if(iRowCount++ >= iMaxRowCount){
				iRowCount = 0;
				i+=11;
				bolPageBreak = true;
				break;	
			}
		  %>
		</table>
	</td></tr></table>	
<%}%>
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="66%">Released By: <%=(String)request.getSession(false).getAttribute("first_name")%></td>			
		</tr>
	</table>
<%
}//vRetResult is not null%>
</body>
</html>
<%
dbOP.cleanUP();
%>