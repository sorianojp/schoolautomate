<%
if(request.getSession(false).getAttribute("userId") == null){%>
<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
	Please login to access this link.
</font>
<%return;
}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
</script>
<%@ page language="java" import="utility.*, organizer.SBEmail, java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int i = 0;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Message Board","inbox_settings.jsp");
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
/** authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Organizer","Message Board",request.getRemoteAddr(),
														"inbox_settings.jsp");
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
**/

SBEmail myMailBox = new SBEmail();

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myMailBox.operateOnOtherMail(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = myMailBox.getErrMsg();
	}
	
		
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = myMailBox.operateOnOtherMail(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = myMailBox.getErrMsg();
	}

vRetResult = myMailBox.operateOnOtherMail(dbOP, request, 4);
if (vRetResult == null && strErrMsg == null) 
 strErrMsg = myMailBox.getErrMsg();

%>
<body bgcolor="#8C9AAA">
<form action="./inbox_settings.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="6" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INBOX SETTINGS ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" colspan="3" bgcolor="#FFFFFF"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr>
    	<td width="5%">&nbsp;</td>
    	<td width="15%" align="left">Email Address</td>
		<td width="80%" align="left">
		<%if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(5);
		else
			strTemp = WI.fillTextValue("addr");%>
		<input name="addr" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>">
		</td>
    </tr>
<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
    <tr>
    	<td>&nbsp;</td>
    	<td align="left">Account Name</td>
    	<td colspan="4" align="left">
		<%if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(1);
		else
			strTemp = WI.fillTextValue("accnt");%>
    	<input name="accnt" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>">
    	</td>
    </tr>
   	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
    <tr>
    	<td>&nbsp;</td>
    	<td align="left">Password</td>
    	<td colspan="4" align="left">
		<%if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(2);
		else
			strTemp = WI.fillTextValue("pass");%>
    	<input name="pass" type="password" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>">
    	</td>
    </tr>
	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
    <tr>
    	<td>&nbsp;</td>
    	<td align="left">Host</td>
    	<td colspan="4" align="left">
		<%if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(3);
		else
			strTemp = WI.fillTextValue("host");%>
    	<input name="host" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>">
    	</td>
    </tr>
     <tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
     <tr>
    	<td>&nbsp;</td>
    	<td align="left">Trash Folder Name</td>
    	<td colspan="4" align="left">
		<%if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp =  WI.getStrValue((String)vEditInfo.elementAt(7),"");
		else
			strTemp = WI.fillTextValue("trash");%>
    	<input name="trash" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>">
    	<font size="1">(Optional)</font></td>
    </tr>
    <tr>
    	<td height="25">&nbsp;</td>
    	<td align="left" valign="bottom">Account Type</td>
    	<td colspan="4" align="left" valign="bottom">
		<%
      if (vEditInfo!=null && vEditInfo.size()>0)
	      strTemp = WI.getStrValue((String)vEditInfo.elementAt(6),"1");
      else
    	  strTemp = WI.getStrValue(WI.fillTextValue("accnt_type"),"1");
	  if (strTemp.equals("1")){%>
        <input type="radio" name="accnt_type" value="1" checked>IMAP
        <input type="radio" name="accnt_type" value="0">POP3
       <%} else {%>
        <input type="radio" name="accnt_type" value="1">IMAP
        <input type="radio" name="accnt_type" value="0" checked>POP3
        <%}%>
    	</td>
    </tr>
    <tr>
    	<td height="25">&nbsp;</td>
    	<td align="left" valign="bottom">Default Account</td>
    	<td colspan="4" align="left" valign="bottom">
		<%if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(4);
		else
			strTemp = WI.getStrValue(WI.fillTextValue("isDef"),"0");
		
		if (strTemp.compareTo("1")==0){%>
	   	<input type="checkbox" name="isDef" value="1" checked>
	   	<%}else{%>
	   	<input type="checkbox" name="isDef" value="1">
	   	<%}%>
    	</td>
    </tr>
    <tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
	<tr>
		<td colspan="6" align="center"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../images/add.gif" border="0" name="hide_save"></a> 
        Add account 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Edit account <a href="javascript:Cancel();"><img src="../../images/cancel.gif" border="0"></a> 
        Discard Changes 
        <%}%></font></td>    
	</tr>
	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
  </table>
  <%if (vRetResult != null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   	<tr bgcolor="#DBEAF5">
   	<td width="3%"><div align="left"><strong><font size="1">&nbsp;</font></strong></div></td>
   	<td width="38%"><div align="left"><strong><font size="1">Account Name</font></strong></div></td>
   	<td width="39%"><div align="left"><strong><font size="1">Host</font></strong></div></td>
   	<td colspan="2"><div align="center"><strong><font size="1">OPTIONS</font></strong></div></td>
   	</tr>
   	<%for (i = 0; i<vRetResult.size(); i+=8 ){%>
   	<tr>
   	<td class="thinborderBOTTOM"><%if (((String)vRetResult.elementAt(i+4)).compareTo("1")==0){%>
   	<img src="../../images/mail_def.gif" border="0"><%}else{%>&nbsp;<%}%></td>
   	<td class="thinborderBOTTOM"><%=(String)vRetResult.elementAt(i+1)%></td>
   	<td class="thinborderBOTTOM"><%=(String)vRetResult.elementAt(i+3)%></td>
	<td width="10%" class="thinborderBOTTOM"><font size="1"> 
        <% //if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'>
        <img src="../../images/edit.gif" border="0"></a>
        <%//}else{%>
        <!--Not authorized to edit--> 
        <%//}%>
        </font></td>
   	<td width="10%" class="thinborderBOTTOM"><font size="1"> <%// if(iAccessLevel ==2){%>
   	<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'>
        <img src="../../images/delete.gif" border="0"></a>
        <%//}else{%>
        <!--Not authorized to delete--> 
        <%//}%></font></td>
   	</tr>
   	<%}%>
   </table>
   <%}%>
   <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
 <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=WI.fillTextValue("prepareToEdit")%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>