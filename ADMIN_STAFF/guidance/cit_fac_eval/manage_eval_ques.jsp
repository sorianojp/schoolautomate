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
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling-Faculty Evaluation-Manage Question","manage_eval_ques.jsp");
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
														"manage_eval_ques.jsp");
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
	if(facEval.opeateOnQuestion(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = facEval.getErrMsg();
	else {	
		strErrMsg = "Operation Successful.";
		strPreparedToEdit = "0";
	}
}
if(strPreparedToEdit.equals("1")) {
	vEditInfo = facEval.opeateOnQuestion(dbOP, request, 3);
	if(vEditInfo == null){
		strErrMsg = facEval.getErrMsg();
		strPreparedToEdit = "0";
	}
}

vRetResult = facEval.opeateOnQuestion(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null) 
	strErrMsg = facEval.getErrMsg();
%>
<form action="./manage_eval_ques.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
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
      <td>Select if Lec or LAB </td>
      <td><select name="is_lab" onChange="document.form_.info_index.value='';document.form_.preparedToEdit.value='';document.form_.submit();">
        <option value="0">Lec</option>
<%
	strTemp = WI.fillTextValue("is_lab");

if(strTemp.equals("1"))
	strTemp = "selected";
else	
	strTemp = "";
%>
        <option value="1" <%=strTemp%>>Lab</option>
      </select></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Question Order </td>
      <td width="80%">
	  <select name="order_no">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("order_no");
if(strTemp.length() == 0) 
	strTemp = "0";
int iTemp = Integer.parseInt(strTemp);
for(int i = 1; i <= 100; ++i) {
	if(iTemp == i)
		strErrMsg = "selected";
	else
		strErrMsg = "";
	%><option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
<%}%>
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Question Category </td>
      <td>
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("category");
%>
	  <select name="category">
	  	<%=dbOP.loadCombo("CATG_INDEX","CATEGORY"," from CIT_FAC_EVAL_CATG order by ORDER_NO",strTemp, false)%>
	  </select>
	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top"><br>Question</td>
      <td>
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("question");
%>
	<textarea name="question" class="textbox" rows="5" cols="80" style="font-size:11px"
	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
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
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">QUESTION LIST </font></strong></div></td>
    </tr>
    <tr style="font-weight:bold"> 
      <td height="25">Total Question : <%=vRetResult.size()/5%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="15%" height="25" align="center" style="font-size:9px; font-weight:bold;" class="thinborder"> Question Category </td>
      <td width="10%" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Question Order </td>
      <td width="60%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Question</td>
      <td width="8%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Edit</td>
      <td width="7%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Delete</td>
    </tr>
<%//System.out.println(vRetResult);
String strBGColor = "#FFFFFF";
strTemp = null;
for(int i=0; i<vRetResult.size(); i+=5){
if(strTemp == null)
	strTemp = (String)vRetResult.elementAt(i + 3);
else if(!strTemp.equals((String)vRetResult.elementAt(i + 3)) ){
	strTemp = (String)vRetResult.elementAt(i + 3);
	if(strBGColor.startsWith("#F"))
		strBGColor = "#DDDDDD";
	else
		strBGColor = "#FFFFFF";
}%>
    <tr bgcolor="<%=strBGColor%>"> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
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