<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete Payee type.'))
			return;
	}
		
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function CancelOperation() {
	location = "./manage_ap_type.jsp";
}
</script>

<%@ page language="java" import="utility.*,Accounting.AccountPayable,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
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

	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-Accounting-Transaction-A/P Manage AP Type","manage_ap_type.jsp");
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
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	AccountPayable AP = new AccountPayable();
	Vector vEditInfo  = null; Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(AP.operateOnAPPayeeType(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = AP.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Payee Type successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Payee Type successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Payee Type successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	vRetResult = AP.operateOnAPPayeeType(dbOP, request,4);	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = AP.operateOnAPPayeeType(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = AP.getErrMsg();
	}
%>

<body bgcolor="#D2AE72" onLoad="document.form_.payee_type.focus();">
<form action="./manage_ap_type.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="8"><div align="center"><font color="#FFFFFF" ><strong>:::: AP PAYEE TYPE MANAGEMENT ::::</strong></font></div></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><a href="./manage_ap.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Payee Type </td>
      <td width="82%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("payee_type");
%>	  <input type="text" name="payee_type" size="32" maxlength="32" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("allow_edit_del");
if(strTemp.length() == 0) 
	strTemp = "2";
	
if(strTemp.compareTo("2") == 0)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  <input type="radio" name="allow_edit_del" value="2"<%=strErrMsg%>> Default (Can be edited and deleted) &nbsp; &nbsp; &nbsp; 
<%
if(strTemp.compareTo("1") == 0)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		<input type="radio" name="allow_edit_del" value="1"<%=strErrMsg%>> Allow Edit Only&nbsp; &nbsp; &nbsp; 
<%
if(strTemp.compareTo("0") == 0)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		<input type="radio" name="allow_edit_del" value="0"<%=strErrMsg%>> Do not allow Edit/Delete</td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="50">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td>
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
		<input type="submit" value=" Save Payee Type " style="font-size:10px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.page_action.value='1';document.form_.prepareToEdit.value='';document.form_.info_index.value=''"> 
        <%}else {%>
        <input type="submit" value=" Edit Payee Type " style="font-size:10px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=(String)vEditInfo.elementAt(0)%>'">
        <%}%>
        &nbsp;&nbsp;&nbsp;
		<input type="button" value=" Cancel Operation " style="font-size:10px; height:22px;border: 1px solid #FF0000;" onClick="CancelOperation();">
		</td>
    </tr>
<%}%>	
  </table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
    <tr bgcolor="#DDDDEE"> 
      <td height="25" colspan="4" class="thinborder" align="center"><font color="#FF0000"><strong>LIST 
          OF AP PAYEE TYPE </strong></font></td>
    </tr>
    <tr> 
      <td width="23%" height="25" class="thinborder"><div align="center"><strong><font size="1">Payee Type Name </font></strong></div></td>
      <td width="38%" class="thinborder"><div align="center"><strong><font size="1">Payee Type </font></strong></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong><font size="1">Allowed Operation </font></strong></div></td>
      <td width="16%" class="thinborder" align="center"><strong><font size="1">Operation</font></strong></td>
    </tr>
<%
int iTypeMode = 0;
String[] astrConvertTypeMode = {"No Edit/Delete","Allow Edit Only","Allow Edit/Delete"};
String[] astrConvertPayeeTYpe = {"","S-Supplier","E-Employee","S-Student","","0-Others"};
for(int i = 0; i < vRetResult.size(); i += 4){
	iTypeMode = Integer.parseInt((String)vRetResult.elementAt(i + 2));
%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=astrConvertPayeeTYpe[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></font></td>
      <td class="thinborder"><font size="1">&nbsp;
	  <%=astrConvertTypeMode[iTypeMode]%></font></td>
      <td class="thinborder"><font size="1">&nbsp;
        <%
if(iAccessLevel > 1 && iTypeMode > 0 ){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/edit.gif" border="0"></a> 
<%}if(iAccessLevel == 2 && iTypeMode == 2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/delete.gif" border="0"></a> 
<%}%>
        </font></td>
    </tr>
<%}%>
  </table>
<%}//end of vRetResult%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A"> 
    <td width="50%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>