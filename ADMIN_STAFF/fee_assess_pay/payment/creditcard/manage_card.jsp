<%@ page language="java" import="utility.*,java.util.Vector,java.util.Date" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp   = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-PAYMENT"),"0"));
		if(iAccessLevel == 0) 
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
	}
			
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Credit Manage Card Type","manage_card.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
enrollment.CreditCardInfo CCardInfo = new enrollment.CreditCardInfo();

Vector vRetResult = null;
Vector vEditInfo  = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(CCardInfo.operateOnCardType(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = CCardInfo.getErrMsg();
	else	
		strErrMsg = "Credit card type information updated.";
}

vRetResult = CCardInfo.operateOnCardType(dbOP, request, 4);
if(strPreparedToEdit.equals("1"))
	vEditInfo = CCardInfo.operateOnCardType(dbOP, request, 3);	

dbOP.cleanUP();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
</script>
<body>
<form name="form_" method="post" action="manage_card.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=2"></jsp:include>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="22" colspan="3" align="center" style="font-size:11px; font-weight:bold"><u>:::: MANAGE CARD TYPE ::::</u></td>
    </tr>	
<%
if(strErrMsg != null) {%>
    <tr> 
      <td height="25" colspan="4" style="font-size:14px; font-weight:bold;">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
<%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
  	<td height="25" width="25%">Card Type </td>
  	<td>
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("card_type");
%>
	<input name="card_type" type="text" size="24" maxlength="24" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  	</tr>
  <tr>
  	<td height="25">Card Type (Code) </td>
  	<td style="font-size:9px;">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("card_code");
%>
	<input name="card_code" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
  	  - this will be shown in report. </td>
  	</tr>
  <tr>
    <td height="25">Is Debit Card </td>
    <td style="font-size:9px;">
	<select name="is_debit_card">
		<option value="1" <%=strTemp%>> YES (debit card)</option>
		<option value="1" <%=strTemp%>> NO (credit card)</option>		
	</select>
	
	</td>
  </tr>
  <tr>
    <td height="25">Edit/Delete Status </td>
    <td style="font-size:9px;">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("edit_del_stat");
if(strTemp.length() == 0) 
	strTemp = "0";
if(strTemp.equals("0"))	
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	<input name="edit_del_stat" type="radio" value="0"<%=strErrMsg%>> Read only 
<%
if(strTemp.equals("1"))	
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	<input name="edit_del_stat" type="radio" value="1"<%=strErrMsg%>> Edit only allowed 
<%
if(strTemp.equals("2"))	
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	<input name="edit_del_stat" type="radio" value="2"<%=strErrMsg%>> Edit/Del allowed	</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td style="font-size:9px;">
	<%if(iAccessLevel > 1){%>
		<%if(strPreparedToEdit.equals("0")){%>
			<input type="submit" onClick="document.form_.page_action.value='1';" name="_" value="Save Info">
		<%}else if(vEditInfo != null){%>
			<input type="submit" onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=(String)vEditInfo.elementAt(0)%>'" value="Edit Info">
	<%}
	}%>&nbsp;&nbsp;
	<input type="submit" onClick="document.form_.page_action.value='';document.form_.card_type.value='';document.form_.card_code.value='';document.form_.card_code.value=''" value="Cancel">	</td>
  </tr>
  <tr>
    <td height="25" colspan="2" align="center">&nbsp;</td>
    </tr>
  </table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr bgcolor="#CCFFCC" align="center">
  		<td height="22" class="thinborder" style="font-size:9px; font-weight: bold" width="25%">Card Type</td>
		<td class="thinborder" style="font-size:9px; font-weight: bold" width="25%">Card Type - Code</td>
		<td class="thinborder" style="font-size:9px; font-weight: bold" width="10%">Debit/Credit Card </td>
		<td class="thinborder" style="font-size:9px; font-weight: bold" width="25%">Edit/Del Stat</td>
		<td class="thinborder" style="font-size:9px; font-weight: bold" width="10%">Edit</td>
		<td class="thinborder" style="font-size:9px; font-weight: bold" width="15%">Delete</td>
	</tr>
	<%
	boolean bolIsEditAllowed = false;
	boolean bolIsDelAllowed  = false;
	for(int i = 0; i < vRetResult.size(); i += 6){
		bolIsEditAllowed = false;
		bolIsDelAllowed  = false;
	strTemp = (String)vRetResult.elementAt(i + 3);
	if(strTemp.equals("1")) {
		strTemp = "System Generated";
	}
	else {
		strTemp = (String)vRetResult.elementAt(i + 4);
		if(strTemp.equals("0"))
			strTemp = "Read Only";
		else if(strTemp.equals("1")) {
			strTemp = "Edit allowed.";
			bolIsEditAllowed = true;
		}
		else {
			strTemp = "Edit/Del allowed.";
			bolIsDelAllowed = true;
			bolIsEditAllowed = true;
		}
			
	}%>
	<tr>
  		<td height="22" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
  		<td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
  		<td class="thinborder">&nbsp;</td>
  		<td class="thinborder"><%=strTemp%></td>
  		<td class="thinborder">&nbsp;<%if(bolIsEditAllowed && iAccessLevel > 1){%>
			<input type="submit" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='1'; document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'" value="Edit">
		<%}%></td>
  		<td class="thinborder">&nbsp;<%if(bolIsDelAllowed && iAccessLevel == 2){%>
			<input type="submit" onClick="document.form_.page_action.value='';document.form_.page_action.value='0'; document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'" value="Delete">
		<%}%></td>
	</tr>
  	<%}%>
  </table>
  
  
  
  
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
  <input type="hidden" name="preparedToEdit">
</form>
</body>
</html>
