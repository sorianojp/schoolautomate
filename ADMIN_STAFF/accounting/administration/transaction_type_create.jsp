<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","transaction_type_create.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
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
Administration adm = new Administration();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(adm.operateOnTransactionType(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = adm.operateOnTransactionType(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = adm.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = adm.operateOnTransactionType(dbOP, request, 3);

%>
<form action="./transaction_type_create.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="100%" height="27" colspan="8" bgcolor="#B5AB73"><div align="center"><font color="#FFFFFF" size="2"><strong>:::: TRANSACTIONS TYPE PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td colspan="3" style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%" height="25">Transaction Type</td>
      <td width="80%" height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("trans_type");
%> 
	  <input name="trans_type" type="text" size="64" maxlength="128" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Transaction Code</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("trans_code");
%> 
	  <input name="trans_code" type="text" size="16" maxlength="16" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="37">&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1">
<%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">&nbsp;&nbsp;&nbsp;&nbsp;
	<%}else{%>
		<input type="submit" name="12" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.trans_type.value='';document.form_.trans_code.value=''">
      </font></td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="4" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: 
          LIST OF TRANSACTION TYPE :: </strong></font></div></td>
    </tr>
    <tr> 
      <td width="38%" height="25" class="thinborder"><div align="center"><font size="1"><strong>TRANSACTION TYPE </strong></font></div></td>
      <td width="31%" class="thinborder"><div align="center"><font size="1"><strong>TRANSACTION CODE</strong></font></div></td>
      <td width="14%" class="thinborder"><font size="1">&nbsp;</font></td>
      <td width="17%" class="thinborder">&nbsp;</td>
    </tr>
<%for(int i =0; i< vRetResult.size(); i += 3){%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;
	  <%if(iAccessLevel > 1) {%>
	  <input type="submit" name="12" value="&nbsp; Edit &nbsp;" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');"><%}%></td>
      <td class="thinborder">&nbsp;
	<%if(iAccessLevel ==2 ) {%>
	  <input type="submit" name="12" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');"><%}%>
	  </td>
    </tr>
<%}//end of for loop.%>
  </table>
<%}//show if vRetResult is not null.%>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="27" bgcolor="#B5AB73">&nbsp;</td>
    </tr>
  </table>


<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>