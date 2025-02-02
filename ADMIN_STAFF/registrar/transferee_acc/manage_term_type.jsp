<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transferee Info Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function edit(strInfoIndex) {
	document.form_.preparedToEdit.value = '1';
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = '';
/**
	var strNewVal = prompt('Please enter new term type.','');
	if(strNewVal == null || strNewVal.length == 0)
		return;
	document.form_.page_action.value = '2';
	document.form_.info_index.value = strInfoIndex;
	document.form_.term_type.value = strNewVal;
**/	
	document.form_.submit();
}
function toggleValidity(strInfoIndex, strToggleStat) {
	if(strToggleStat == '0')
		strToggleStat = "Invalidate";
	else	
		strToggleStat = "Activate";
	if(!confirm('Do you want to '+strToggleStat+' term type?'))
		return;
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = '5';
	
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.GradeSystemTransferee,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-TRANSFEREE INFO MAINTENANCE-manage term type","manage_term_type.jsp");
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
														"Registrar Management","TRANSFEREE INFO MAINTENANCE",request.getRemoteAddr(),
														"manage_term_type.jsp");
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

GradeSystemTransferee gST = new GradeSystemTransferee();
Vector vRetResult = null; Vector vEditInfo = null;

String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(gST.manageTermType(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = gST.getErrMsg();
	else {
		strErrMsg = "Request processed successfully.";
		strPreparedToEdit = "0";
	}
}
vRetResult = gST.manageTermType(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = gST.getErrMsg();

if(strPreparedToEdit.equals("1"))
	vEditInfo = gST.manageTermType(dbOP, request, 3);

%>


<form action="./manage_term_type.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          MANAGE TERM TYPE :::: </strong></font></div></td>
    </tr>
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
		<td width="2%" height="25" colspan="4">&nbsp;</td>
      <td width="98%"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">Term Type </td>
      <td width="13%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("term_type");
%>
	  <input name="term_type" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
      <td width="10%">&nbsp;</td>
      <td width="62%">
	  <%if(strPreparedToEdit.equals("1")){%>
		  <input type="submit" name="edit_" value="Edit Information" onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=vEditInfo.elementAt(0)%>'">
		  <input type="submit" name="cancel" value="Cancel Edit" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';">
	  <%}else{%>
		  <input type="submit" name="save_" value="Add Term Type" onClick="document.form_.page_action.value='1';">
	  <%}%>  
	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" style="font-size:9px; font-weight:bold">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("is_append_term");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" value="1" <%=strTemp%> name="is_append_term"> Append 1st/2nd/3rd/4th to Term type</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="4" class="thinborder" align="center" style="font-size:11px; font-weight:bold">::: Term Type Listing ::: </td>
    </tr>
    <tr>
      <td width="20%"  height="25" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Term Type</td>
      <td width="15%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Append 1st/2nd/3rd/4th to Term Type </td>
      <td width="26%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Edit Information </td>
      <td width="16%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Activate /Invalidate</td>
    </tr>
<%String steBGColor = null;
String strDelButtonLabel = "Invalidate";

for(int i =0; i < vRetResult.size(); i += 4){
if(steBGColor == null && vRetResult.elementAt(i + 2).equals("1")) {
	steBGColor = " bgcolor='cccccc'";
	strDelButtonLabel = "Activate";
}
	if(vRetResult.elementAt(i + 3).equals("1"))
		strTemp = "Append";
	else	
		strTemp = "No";
%>
    <tr<%=steBGColor%>>
      <td height="25" class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" align="center">&nbsp;&nbsp;<%=strTemp%></td>
      <td class="thinborder" align="center"><%if(i > 4 * 4){%><input type="button" value="Edit Term Type" onClick="edit('<%=vRetResult.elementAt(i)%>')"><%}else{%>N/A<%}%></td>
      <td class="thinborder" align="center"><%if(i > 4 * 4){%><input type="button" value="<%=strDelButtonLabel%>" onClick="toggleValidity('<%=vRetResult.elementAt(i)%>','<%=vRetResult.elementAt(i + 2)%>')"><%}else{%>N/A<%}%></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="info_index">
  <input type="hidden" name="page_action">
  <input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
