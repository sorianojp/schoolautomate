<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transferee Info Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PareparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = '1';
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = '';
	document.form_.submit();
}
function PageAction(strInfoIndex, strAction) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this record'))
			return;
	}
	if(strAction == '5') {
		if(!confirm('Are you sure you want to Invalidate this record'))
			return;
	}
	document.form_.preparedToEdit.value = '';
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="document.form_.scholar_code.focus();">
<%@ page language="java" import="utility.*,enrollment.CITChedBilling,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CHED Scholar-manage Scholarship Type","setup_type.jsp");
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
														"Registrar Management","CHED SCHOLAR",request.getRemoteAddr(),
														"setup_type.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

CITChedBilling CCB = new CITChedBilling();
Vector vRetResult = null; Vector vEditInfo = null;

String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
boolean bolIsSuccess = false;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(CCB.operateOnScholarType(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = CCB.getErrMsg();
	else {
		strErrMsg = "Request processed successfully.";
		strPreparedToEdit = "0";
		bolIsSuccess      = true;
	}
}
vRetResult = CCB.operateOnScholarType(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = CCB.getErrMsg();

if(strPreparedToEdit.equals("1"))
	vEditInfo = CCB.operateOnScholarType(dbOP, request, 3);

%>


<form action="./setup_type.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          MANAGE SCHOLARSHIP TYPE :::: </strong></font></div></td>
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
      <td height="25">&nbsp;</td>
      <td>Code</td>
      <td>
<%
if(bolIsSuccess) 
	strTemp ="";
else if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(1), "");
else
	strTemp = WI.fillTextValue("scholar_code");
%>
			<input name="scholar_code" type="text" value="<%=strTemp%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Name</td>
      <td>
<%
if(bolIsSuccess) 
	strTemp ="";
else if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(2), "");
else
	strTemp = WI.fillTextValue("scholar_name");
%>
			<input name="scholar_name" type="text" size="75" value="<%=strTemp%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">&nbsp;</td>
      <td width="85%">
	  <%if(strPreparedToEdit.equals("1")){%>
		  <input type="submit" name="edit_" value="Edit Information" onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=vEditInfo.elementAt(0)%>'">
		  <input type="submit" name="cancel" value="Cancel Edit" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';">
	  <%}else{%>
		  <input type="submit" name="save_" value="Add Type" onClick="document.form_.page_action.value='1';">
	  <%}%>	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5" class="thinborder" align="center" style="font-size:11px; font-weight:bold">::: Scholarship Type Listing ::: </td>
    </tr>
    <tr>
      <td width="15%"  height="25" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Scholarship Code </td>
      <td width="25%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Scholarship Name </td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Edit</td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Invalidate</td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Delete</td>
    </tr>
<%String steBGColor = null;

for(int i =0; i < vRetResult.size(); i += 4){
if(steBGColor == null && vRetResult.elementAt(i + 3).equals("1")) {
	steBGColor = " bgcolor='cccccc'";
}
%>
    <tr<%=steBGColor%>>
      <td height="25" class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" align="center">&nbsp;&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" align="center"><%if(iAccessLevel > 1){%><input type="button" value="Edit" onClick="PareparedToEdit('<%=vRetResult.elementAt(i)%>')"><%}else{%>N/A<%}%></td>
      <td class="thinborder" align="center"><%if(iAccessLevel == 2){%><input type="button" value="Invalidate" onClick="PageAction('<%=vRetResult.elementAt(i)%>','5')"><%}else{%>N/A<%}%></td>
      <td class="thinborder" align="center"><%if(iAccessLevel == 2){%><input type="button" value="Delete" onClick="PageAction('<%=vRetResult.elementAt(i)%>','0')"><%}else{%>N/A<%}%></td>
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
