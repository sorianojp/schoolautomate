<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
WebInterface WI = new WebInterface(request);


boolean bolIsBatchPrint = false;
if(WI.fillTextValue("batch_print").equals("1"))
	bolIsBatchPrint = true;

String strFontSize = WI.fillTextValue("font_size");
if(strFontSize.length() == 0)
	strFontSize = "9";

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
		font-size: <%=strFontSize%>px;
	}
	td {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
	th {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
	-->
	</style>
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script>
function PrintPg() {
	<%if(!bolIsBatchPrint){%>
		window.print();
		if(confirm('Click OK to Finish Printing and Close this page'))
			window.close();
	<%}%>

}
</script>
<body topmargin="5px" bottommargin="0" onLoad="PrintPg();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = 2;

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
String strSemester = WI.fillTextValue("offering_sem");
strExamPeriod      = WI.fillTextValue("pmt_schedule");

String strCourseName = null;


Vector vRetResult  = null;//get subject schedule information.

boolean bolAllowPrinting = false;

Vector vStudInfo   = null; double dDueForThisPeriod = 0d;
	enrollment.EnrlAddDropSubject enrlStudInfo = new enrollment.EnrlAddDropSubject();
	vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),	strStudID,strSYFrom, strSYTo, strSemester);
	if(vStudInfo == null)
		strErrMsg = enrlStudInfo.getErrMsg();

//System.out.println(strErrMsg);

if(vStudInfo != null && vStudInfo.size() > 0) {
	strTemp = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+strExamPeriod;
	strExamName = dbOP.getResultOfAQuery(strTemp, 0);

	if(vStudInfo.elementAt(16) == null) {
		strCourseName = dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(4)));
		bolIsBasic = true;
		astrConvertSem[1] = "Regular";
	}
	else {
		strCourseName = (String)vStudInfo.elementAt(16)+WI.getStrValue((String)vStudInfo.elementAt(22),"/","","") +
		WI.getStrValue((String)vStudInfo.elementAt(4),"-","","");
	}

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
Vector vOfferingCount = null;
String strAdmSlipNo   = null;

if(bolAllowPrinting) {
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	vRetResult = reportEnrl.getStudentLoad(dbOP, strStudID,strSYFrom, strSYTo, strSemester);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();
	else {
		Vector vStudDetail = (Vector)vRetResult.elementAt(0);
		vOfferingCount = (Vector)vStudDetail.remove(7);

			strAdmSlipNo = reportEnrl.autoGenAdmSlipNum(dbOP, (String)vStudInfo.elementAt(0),strExamPeriod, strSYFrom, strSemester,
                            (String)request.getSession(false).getAttribute("userIndex"));
			//strTemp = "update ADM_SLIP_PRN_COUNT set ALLOW_REPRINT = '0',PERMIT_VALIDITY=null where user_index = "+vStudInfo.elementAt(0)+" and pmt_sch_index = "+strExamPeriod+
			//			" and is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;
			//dbOP.executeUpdateWithTrans(strTemp, null, null, false);
	}
}
%>

<%if(vStudInfo != null && vStudInfo.size() > 0){%>
<table width="80%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td  colspan="3"><%=WI.getTodaysDateTime()%></td>
  </tr>
  <tr>
    <td width="39%" height="18"><%=strAdmSlipNo%></td>
    <td width="61%"><%=astrConvertSem[Integer.parseInt(strSemester)]%>, <%=strSYFrom+" - "+strSYTo%></td>
    <td width="61%">&nbsp;</td>
  </tr>
</table>
<br>
<table width="80%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="31%" height="18"><%=(String)vStudInfo.elementAt(1)%> (<%=strStudID%>) </td>
    <td width="69%"><%=strCourseName%></td>
  </tr>
</table>
<br>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="65%" cellpadding="0" cellspacing="0" height="225px"><tr><td valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
		  <tr style="font-weight:bold">
			<td width="14%" height="25">&nbsp;</td>
			<td width="14%">&nbsp;</td>
			<td width="14%">&nbsp;</td>
			<td width="48%">&nbsp;</td>
			<td width="10%">&nbsp;</td>
		  </tr>
		   <%
		   int iCount = 0;
		   for(int i=1; i< vRetResult.size(); i += 11){
		   	strTemp = (String)vRetResult.elementAt(i+1);
		   	if(strTemp != null && strTemp.length() > 35)
		   		strTemp = strTemp.substring(0,35);
			strErrMsg = (String)vRetResult.elementAt(i);
		   	if(strErrMsg != null && strErrMsg.startsWith("NSTP") && strErrMsg.indexOf("(")> 0)
		   		strErrMsg = strErrMsg.substring(0, strErrMsg.indexOf("("));

			%>
			  <tr>
				<td><%if(vOfferingCount.size() > 0){%><%=vOfferingCount.remove(0)%><%}else{%>&nbsp;<%}%></td>
				<td>&nbsp;</td>
				<td><%=strErrMsg%></td>
				<td><%=strTemp%></td>
				<td><%=(String)vRetResult.elementAt(i+9)%></td>
			  </tr>
		  <%}%>
		</table>
	</td></tr></table>
<%}
}//vRetResult is not null%>
</body>
</html>
<%
dbOP.cleanUP();
%>
