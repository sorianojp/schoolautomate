<%@ page language="java" import="utility.*,enrollment.ScaledScoreConversion,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function CloseWindow(){		
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;
	
	window.opener.document.form_.submit();
	window.opener.focus();
	self.close();
}


function ReloadPage(){
	document.form_.donot_call_close_wnd.value = '1';
	document.form_.info_index.value = '';
	document.form_.prepareToEdit.value = '';
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	document.form_.donot_call_close_wnd.value = '1';
	document.form_.page_action.value = strAction;	
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value = '1';
	document.form_.info_index.value = strInfoIndex;
	document.form_.donot_call_close_wnd.value = '1';
	document.form_.submit();
}
</script>


<body bgcolor="#D2AE72" onUnload="CloseWindow();">
<form name="form_" action="./add_score_rating_exam_name.jsp" method="post">
<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;	
	String strTemp    = null;
	String strTemp2   = null;
	String strTemp3   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-IQ Test","add_score_rating_exam_name.jsp");
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
									"Guidance & Counseling","IQ Test",request.getRemoteAddr(), null);

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

ScaledScoreConversion scoreConversion = new ScaledScoreConversion();
Vector vRetResult = new Vector();
Vector vEditInfo  = new Vector();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(scoreConversion.operateOnIQExamName(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = scoreConversion.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Entry Successfully Deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Entry Successfully Saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Entry Successfully Updated.";
		strPrepareToEdit = "";
		
	}
}

vRetResult = scoreConversion.operateOnIQExamName(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = scoreConversion.getErrMsg();
	
if(strPrepareToEdit.length() > 0){
	vEditInfo = scoreConversion.operateOnIQExamName(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = scoreConversion.getErrMsg();
}

%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF"><strong>::::
          I.Q. SCORE NAME ::::</strong></font></div></td>
    </tr>
    <tr>
		<td height="25">&nbsp; &nbsp; &nbsp; <strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		<td align="right">
			<a href="javascript:CloseWindow();">
			<img src="../../../images/close_window.gif" border="0" align="absmiddle"></a>
		</td>
	</tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable2">
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">I.Q. Exam Name</td>
		<%
		strTemp = WI.fillTextValue("exam_name");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		%>
		<td>
		<input type="text" name="exam_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';" 
					size="50" maxlength="128" value="<%=strTemp%>" />
		</td>
	</tr>
	
	
	
	
	
	
	
	<tr><td colspan="3">&nbsp;</td></tr>
	
	<tr>
		<td colspan="2" height="25">&nbsp;</td>
		<td>
		<%if(iAccessLevel > 1){
			if(strPrepareToEdit.length() == 0){
		%>			
				<a href="javascript:PageAction('1','');">
				<img src="../../../images/save.gif" border="0"></a>		
				<font size="1">Click to save conversion</font>
			<%}else if(strPrepareToEdit.length() > 0 && vEditInfo != null && vEditInfo.size() > 0){%>
				<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');">
				<img src="../../../images/edit.gif" border="0"></a>		
				<font size="1">Click to update conversion</font>
			<%}%>			
			<a href="javascript:ReloadPage();">
			<img src="../../../images/cancel.gif" border="0"></a>		
			<font size="1">Click to refresh page</font>
		<%}%>
		</td>
	</tr>
	<tr><td colspan="3">&nbsp;</td></tr>
</table>
  
  
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td colspan="2" height="25" align="center" class="thinborder"><strong>EXAM LIST</strong></td>
	</tr>
	<tr>
		<td class="thinborder" align="center" height="25" width="20%"><strong>Exam Name</strong></td>		
		<td class="thinborder" align="center" width="20%"><strong>Option</strong></td>
	</tr>
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=2){
	%>
	
	<tr>
		<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>	
		<td class="thinborder" align="center">
			<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
			<img src="../../../images/edit.gif" border="0"></a>
			
			<%if(iAccessLevel == 2){%>
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
			<img src="../../../images/delete.gif" border="0"></a>
			<%}%>
		</td>
	</tr>
	
	<%}%>
</table>
<%}%>


  
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" >
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="donot_call_close_wnd">
<input type="hidden" name="exam_main_index" value="<%=WI.fillTextValue("exam_main_index")%>" />

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
