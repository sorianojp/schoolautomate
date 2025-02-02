<%@ page language="java" import="utility.*,enrollment.FacultyEvaluation, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;
	document.form_.submit();
}
function focusID() {
	document.form_.category.focus();
	document.form_.category.select();
}
function PreparedToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.preparedToEdit.value = '1';
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling-Faculty Evaluation-Manage Eval Sched","manage_eval_sched.jsp");
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

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance & Counseling","FACULTY EVALUATION",request.getRemoteAddr(),
														"manage_eval_sched.jsp");
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

Vector vEditInfo = null;Vector vRetResult = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");

FacultyEvaluation facEval = new FacultyEvaluation();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(facEval.operateOnEvalSched(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = facEval.getErrMsg();
	else {	
		strErrMsg = "Operation Successful.";
		strPreparedToEdit = "0";
	}
}
if(strPreparedToEdit.equals("1")) {
	vEditInfo = facEval.operateOnEvalSched(dbOP, request, 3);
	if(vEditInfo == null){
		strErrMsg = facEval.getErrMsg();
		strPreparedToEdit = "0";
	}
}

vRetResult = facEval.operateOnEvalSched(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null) 
	strErrMsg = facEval.getErrMsg();
%>
<form action="./manage_eval_sched.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::MANAGE QUESTION ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td>
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="DisplaySYTo();">
        to
<%
if(strTemp.length() > 0) 
	strTemp = Integer.toString(Integer.parseInt(strTemp) + 1);
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp; <select name="semester">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp == null)
	strTemp = "";

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
	  </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Valid Evaluation Date </td>
      <td width="80%">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("valid_fr");
%>
        <input name="valid_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.valid_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;&nbsp;to
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("valid_to");
%>
        &nbsp;&nbsp; <input name="valid_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.valid_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="27%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="34%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" align="center">
<%
if(strPreparedToEdit.equals("0")){%>
	  	<input type="submit" name="1" value="&nbsp;&nbsp;Save&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';document.form_.preparedToEdit.value='';document.form_.info_index.value='';">
<%}else{%>
	  	<input type="submit" name="10" value="&nbsp;&nbsp;Edit&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=vEditInfo.elementAt(0)%>';">
	  	&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" name="100" value="&nbsp;&nbsp;Cancel&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';">
<%}%>	  </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">EVALUATION SCHEDULE </font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="20%" height="25" align="center" style="font-size:9px; font-weight:bold;" class="thinborder"> SY-Term </td>
      <td width="40%" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Valid Evaluation Date </td>
      <td width="20%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Edit</td>
      <td width="20%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Delete</td>
    </tr>
<%//System.out.println(vRetResult);
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
for(int i=0; i<vRetResult.size(); i+=5){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i +1)%> - <%=astrConvertTerm[Integer.parseInt((String)vRetResult.elementAt(i +2))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%> to <%=(String)vRetResult.elementAt(i + 4)%></td>
      <td align="center" class="thinborder"><a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a></td>
      <td align="center" class="thinborder"><a href="javascript:PageAction('<%=(String)vRetResult.elementAt(i)%>','0');"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
  <%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>