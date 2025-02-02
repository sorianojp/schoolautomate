<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);
String strEN = WI.fillTextValue("en");
if(strSchCode.startsWith("SWU")){
	if(strEN.toLowerCase().startsWith("p")){%>
		<jsp:forward page="./exam_permit_for_prelim_SWU.jsp"/>
	<%}else{%>
	<jsp:forward page="./exam_permit_print_SWU.jsp"/>
	
<%}
}

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
<body topmargin="40px" bottommargin="0" onLoad="PrintPg();">
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


Vector vStudInfo   = null; double dDueForThisPeriod = 0d;
	enrollment.EnrlAddDropSubject enrlStudInfo = new enrollment.EnrlAddDropSubject();
	vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),	strStudID,strSYFrom, strSYTo, strSemester);
	if(vStudInfo == null) 
		strErrMsg = enrlStudInfo.getErrMsg();

if(vStudInfo != null && vStudInfo.size() > 0) {
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
			reportEnrl.autoGenAdmSlipNum(dbOP, (String)vStudInfo.elementAt(0),strExamPeriod, strSYFrom, strSemester);
			strTemp = "select DATE_PRINTED from ADM_SLIP_PRN_COUNT where user_index = "+vStudInfo.elementAt(0)+" and pmt_sch_index = "+strExamPeriod+
						" and is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;
			if(dbOP.getResultOfAQuery(strTemp, 0) == null)
				strTemp = ", DATE_PRINTED = '"+WI.getTodaysDate()+"',TIME_PRINTED = "+WI.getTodaysDate(28)+",PRINTED_BY = "+
						(String)request.getSession(false).getAttribute("userIndex");
			else	
				strTemp = "";
			
			strTemp = "update ADM_SLIP_PRN_COUNT set ALLOW_REPRINT = '0',PERMIT_VALIDITY=null "+strTemp+" where user_index = "+vStudInfo.elementAt(0)+" and pmt_sch_index = "+strExamPeriod+
						" and is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;
			///check 			
						
			
			dbOP.executeUpdateWithTrans(strTemp, null, null, false);
	}
}
%>

<%if(vStudInfo != null && vStudInfo.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="37%" height="18"><font size="2"><%=(String)vStudInfo.elementAt(1)%></font></td>
    <td width="26%">*** <%=strExamName.toUpperCase()%> EXAM ***</td>
    <td width="37%"><b><%=astrConvertSem[Integer.parseInt(strSemester)]%>, <%=strSYFrom+" - "+strSYTo%></b></td>
  </tr>
  <tr>
<%
strTemp = (String)vStudInfo.elementAt(15);
if(strTemp != null) {
	if(vStudInfo.elementAt(30).equals("1"))
		strTemp = "Returnee";
	else if(strTemp.startsWith("N"))
		strTemp = "Freshmen";
}
%>
    <td height="18" colspan="2"><%=strStudID%> <!--&nbsp;&nbsp;&nbsp;[<%=strTemp%>]&nbsp;&nbsp;&nbsp;&nbsp;-->
	<%=(String)vStudInfo.elementAt(16)%>
        <%if(vStudInfo.elementAt(6) != null){%>
/ <%=WI.getStrValue(vStudInfo.elementAt(22))%>
<%}%> - 
<%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></td>
    <td ><%//=WI.getTodaysDateTime()%></td>
  </tr>
</table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" cellpadding="0" cellspacing="0" height="225px"><tr><td valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
		  <tr style="font-weight:bold">
			<td width="1%" height="18">&nbsp;</td>
			<td width="12%">SUBJECT</td>
			<td width="27%">SUBJECT TITLE</td>
			<td width="5%">UNITS&nbsp;</td>
			<td width="10%">SECTION</td>
			<td width="30%">INSTRUCTOR</td>
			<td width="15%">SIGNATURE</td>
		  </tr>
		   <%
		   int iCount = 0;
		   for(int i=1; i< vRetResult.size(); i += 11){
		   	strTemp = (String)vRetResult.elementAt(i+1);
		   	if(strTemp != null && strTemp.length() > 25)
		   		strTemp = strTemp.substring(0,25);
			strErrMsg = (String)vRetResult.elementAt(i);
		   	if(strErrMsg != null && strErrMsg.startsWith("NSTP") && strErrMsg.indexOf("(")> 0)
		   		strErrMsg = strErrMsg.substring(0, strErrMsg.indexOf("("));
			
			%>
			  <tr>
				<td height="18"><%=++iCount%></td>
				<td><%=strErrMsg%></td>
				<td><%=strTemp%></td>
				<td><%=(String)vRetResult.elementAt(i+9)%></td>
				<td><%=(String)vRetResult.elementAt(i+3)%></td>
				<td><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
				<td>__________</td>
			  </tr>
		  <%}%>
		</table>
	</td></tr></table>
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="66%" align="right">Printed By: <%=(String)request.getSession(false).getAttribute("first_name")%></td>
			<td width="34%" align="left"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getTodaysDate(1)%></td>
		</tr>
	</table>
<%}
}//vRetResult is not null%>
</body>
</html>
<%
dbOP.cleanUP();
%>