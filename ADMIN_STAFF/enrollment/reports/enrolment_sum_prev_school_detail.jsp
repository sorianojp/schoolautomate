<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {
	color: #FF0000;
	font-weight: bold;
}
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	var sT = "./enrolment_sum_prev_school_print_details.jsp?sy_from="+document.form_.sy_from.value+"&sy_to="+
		document.form_.sy_to.value+"&semester="+
		document.form_.semester[document.form_.semester.selectedIndex].value + 
		"&cc_index=" + document.form_.cc_index[document.form_.cc_index.selectedIndex].value + 
		"&status_index=" + 
		document.form_.status_index[document.form_.status_index.selectedIndex].value;
		

	if(document.form_.show_date.checked)
		sT +="&specific_date="+document.form_.specific_date.value;
	if(document.form_.is_basic.checked)
		sT +="&is_basic=checked";
	//print here
	var win=window.open(sT,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function ReloadPage()
{
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}

function SwitchForm()
{
	pgLoc = "./enrolment_sum_prev_school.jsp?sy_from=" + document.form_.sy_from.value + 
	"&sy_to=" + document.form_.sy_to.value + 
	"&semester="+ document.form_.semester[document.form_.semester.selectedIndex].value+
	"&reloadPage="+ document.form_.reloadPage.value;
	
	if(document.form_.is_basic.checked)
		pgLoc +="&is_basic=checked";
	
	location = pgLoc;
}

</script>
<body>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-enrollment summary from prev School","enrolment_sum_prev_school.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"enrolment_sum_prev_school.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
ReportEnrollment reportEnrollment = new ReportEnrollment();
Vector vRetResult = null;
Vector vSchoolInfo = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 &&
				WI.fillTextValue("reloadPage").compareTo("1") !=0)
{
	vRetResult = reportEnrollment.getEnrolSumFromPrevSchoolDetail(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrollment.getErrMsg();
//	else {
//		vSchoolInfo = (Vector)vRetResult.remove(0);
//	}
}

%>
<form action="./enrolment_sum_prev_school_detail.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SUMMARY REPORT OF ENROLLEE FROM PREVIOUS SCHOOL ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">School year </td>
      <td width="22%" height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   readonly="yes">      </td>
      <td width="5%">Term</td>
      <td width="22%" height="25"><select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="38%" style="font-weight:bold; color:#0000FF; font-size:9px;"><input type="image" src="../../../images/form_proceed.gif">
	  <input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%>> Show Grade School Only
	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="5"> <%
if(WI.fillTextValue("show_date").compareTo("1") ==0)
	strTemp = " checked";
else
    strTemp = "";
%> <input type="checkbox" name="show_date" value="1"<%=strTemp%> onClick="ReloadPage();">
        Enrollment Summary for a specific date &nbsp;&nbsp;&nbsp;<font size="1"> 
        <%
if(strTemp.length() > 0){%>
        <input name="specific_date" type="text" size="10" value="<%=WI.fillTextValue("specific_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        <a href="javascript:show_calendar('form_.specific_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font> <%}%> </td>
    </tr>
<!--    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="5">Student Status : 
        <select name="status_index">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where is_for_student = 1 order by status asc",
					WI.fillTextValue("status_index"), false)%> </select></td>
    </tr> -->
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25" align="right">&nbsp;</td>
      <td width="7%" height="25">Status </td>
      <td width="26%" height="25"><select name="status_index">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("status_index","status",
					" from user_status where is_for_student = 1 and (status='New'" +
					" or status like 'transfer%' or status like 'second%')" + 
					"order by status asc",
					WI.fillTextValue("status_index"), false)%>
      </select></td>
      <td width="15%" height="25" align="right">Classification&nbsp;</td>
      <td width="50%" height="25"><select name="cc_index">
          <option value="">Select a Program</option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 " +
		  	"order by cc_name asc", WI.fillTextValue("cc_index"), false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25" colspan="4" align="right">&nbsp;</td>
      <td height="25" align="right"><a href="javascript:SwitchForm()"><span class="style1">view/print summary</span></a> &nbsp;&nbsp;</td>
    </tr>
  </table>
  <%if(vRetResult != null){//System.out.println(vRetResult);
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="1" cellpadding="1">
	<tr>
		<td>
		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print this page</font>
		</td>
	</tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
<% for (int i = 0; i < vRetResult.size(); i+= 5) {
	
	if (vRetResult.elementAt(i) != null) {
%>
  <tr>
    <td height="20" colspan="2" class="thinborder">
		<font color="#0000FF"> <strong> 
	  &nbsp;<%=(String)vRetResult.elementAt(i) + " :: "+ (String)vRetResult.elementAt(i+1)%>	
	    </strong></font>	  </td>
  </tr>
<% } %> 
  <tr>
    <td width="40%" height="20" class="thinborder">&nbsp;&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
    <td width="60%" class="thinborder">&nbsp;
	  <%=(String)vRetResult.elementAt(i+3) + 
				WI.getStrValue((String)vRetResult.elementAt(i+4),"(",")","")%></td>
    </tr>
<%}%> 
</table>

  	

<%}//only if vRetResult is not null%>
<input type="hidden" name="reloadPage">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>