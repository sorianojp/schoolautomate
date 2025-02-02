<%@ page language="java" import="utility.*,enrollment.FacultyEvaluation, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
		
	boolean bolVMA = strSchCode.startsWith("VMA");
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
	document.form_.point_name.focus();
}
function PreparedToEdit(strInfoIndex) {
	var strPointName = prompt('Please enter new point system name.','');
	if(strPointName == null || strPointName.length == 0) {
		alert('Please enter value for point name.');
		return;
	}
	document.form_.point_name.value = strPointName;
	
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = '2';
	
	document.form_.submit();
}

function ReloadPage(){
	
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling-Faculty Evaluation-Manage Eval Point","manage_eval_point.jsp");
	}
	catch(Exception exp) {
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
														"manage_eval_point.jsp");
														
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","ASSESSMENT AND EVALUATION",request.getRemoteAddr(),
														"manage_eval_point.jsp");
}

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
Vector vRetResult = null; boolean bolIsSuccess = false;

FacultyEvaluation facEval = new FacultyEvaluation();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(facEval.operateOnPointSystem(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = facEval.getErrMsg();
	else {
		strErrMsg = "Operation Successful.";
		bolIsSuccess = true;
	}
}

vRetResult = facEval.operateOnPointSystem(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null) {
	strErrMsg = facEval.getErrMsg();
	vRetResult = new Vector();
}

if(vRetResult == null)
	vRetResult = new Vector();
%>
<form action="./manage_eval_point.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: MANAGE EVALUATION POINT SYSTEM ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
 <%if(bolVMA){%>	
	<tr>
		<td height="25">&nbsp;</td>
        <td height="25">Evaluation Criteria</td>
        <td> 
			<select name="cIndex" id="cIndex" onChange='ReloadPage();'>
				<option value="0">Select Evaluation Criteria</option>
				<%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",WI.fillTextValue("cIndex"),false)%> 
			</select> 
		</td>
   </tr>
<%}%>	   
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Point Value </td>
      <td width="80%">
	  <select name="order_no">
<%
int iTemp = 1;
if(bolVMA)
	iTemp = 0;
int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("order_no"), "0"));
	for(int i = iTemp; i < 11; ++i){
		if(vRetResult.indexOf(Integer.toString(i)) > -1)
			continue;
		if(i == iDefVal)
			strTemp = "selected";
		else	
			strTemp = "";%>
		<option value="<%=i%>" <%=strTemp%>><%=i%></option>
	<%}%>
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Point Name</td>
      <td>
<%
if(bolIsSuccess)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("point_name");
%>
	  <input type="text" name="point_name" value="<%=strTemp%>" class="textbox" size="60"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="64">
	  </td>
    </tr>
	

  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="55%" colspan="2" align="center"><input type="submit" name="1" value="&nbsp;&nbsp;Save&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'"></td>
      <td width="34%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="136%" height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">POINT SYSTEM LIST</font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="55%" height="25" align="center" style="font-size:9px; font-weight:bold;">Point Name </td>
      <td width="12%" align="center" style="font-size:9px; font-weight:bold;">Point Value </td>
      <td width="15%" style="font-size:9px; font-weight:bold;" align="center">Edit</td>
      <td width="18%" style="font-size:9px; font-weight:bold;" align="center">Delete</td>
    </tr>
<%for(int i=0; i < vRetResult.size(); i+=2){%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i)%></td>
      <td align="center"s><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td align="center"><a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i + 1)%>');"><img src="../../../images/edit.gif" border="0"></a></td>
      <td align="center"><a href="javascript:PageAction('<%=(String)vRetResult.elementAt(i + 1)%>','0');"><img src="../../../images/delete.gif" border="0"></a></td>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>