<%@ page language="java" import="utility.*, Accounting.Transaction, java.util.Vector"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
///////////////to reload parent window if this is closed //////////////
function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	
	window.opener.document.form_.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.form_.submit();

		window.opener.focus();
	}
}

function PageAction(strAction,strInfoIndex){
	document.form_.donot_call_close_wnd.value = 1;
	document.form_.page_action.value = strAction;
//	alert("strAction " + strAction);
///	if(strAction == 0){
//		if(!confirm('Delete '+strDel+' from Payees list?'))
//			return;
//	}

	if (strAction == 0){
		document.form_.prepareToEdit.value = "";
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;	
//	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.donot_call_close_wnd.value = 1;
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
//	this.SubmitOnce('form_');
}
function ConfirmDel(strInfoIndex,strDel) {
	document.form_.donot_call_close_wnd.value = 1;
	if(confirm("Do you want to delete " + strDel + "?"))
		return this.PageAction('0',strInfoIndex);
}
</script>

<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">

<%		
	WebInterface WI = new WebInterface(request);
	String strTemp  = null;
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ACCOUNTING-TRANSACTION-Requisition Info","payee_encode.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authentication code.									
	
	Transaction Transaction = new Transaction();	
	String strPageAction = WI.fillTextValue("page_action");
	String[] astrCategory = {"Personal (School Personnel)","Personal (Non-School Personnel)","Company"};
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strErrMsg  = "";
	Vector vRetResult = null;
	Vector vEditInfo = null;

	if(strPageAction.length() > 0){
		if(Transaction.operateOnPettyCashPayee(dbOP,request,Integer.parseInt(strPageAction)) == null){
			strErrMsg = Transaction.getErrMsg();
		}
	}
	if (strPrepareToEdit.length() > 0){
	  vEditInfo = Transaction.operateOnPettyCashPayee(dbOP,request,3);	  
	}
	
	vRetResult = Transaction.operateOnPettyCashPayee(dbOP,request,4);
	
%>
<form action="./payee_encode.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          PETTY CASH : ENCODING OF PAYEE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1"><a href="javascript:CloseWindow();"><img src="../../../../images/close_window.gif" border="0"></a></font>click 
        to close window and have the changes reflected in the dropdown list</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3" style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp; 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td>Payee Name</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		else
			strTemp = WI.fillTextValue("payee_name");
	  %>
      <td><input name="payee_name" type="text" size="50" class="textbox" value="<%=strTemp%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="13%" height="25">Category</td>
      <td width="81%" height="25"> 	  
	  <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)	
			strTemp = (String)vEditInfo.elementAt(2);
		else
			strTemp = WI.fillTextValue("category");
	  %> 
	    <select name="category">
          <option value="0">Personal (School Personnel)</option>
          <%if(strTemp.equals("1")){%>
          <option value="1" selected>Personal (Non-School Personnel)</option>
          <%}else{%>
          <option value="1">Personal (Non-SchoolPersonnel)</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>Company</option>
          <%}else{%>
          <option value="1">Company</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
	  <% strTemp = "";
	  	if(vEditInfo != null && vEditInfo.size() > 0)
		  if(((String)vEditInfo.elementAt(3)).equals("1"))
		  	strTemp = "checked";
		  
				
	  %>
      <td height="25" colspan="2"><input type="checkbox" name="is_hidden" value="1"<%=strTemp%>>
        Hide from drop down list. </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
	  <%if(!strPrepareToEdit.equals("1")) {%>
        <font size="1" > 
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
        click to save entries</font> 
        <%}else{%>
        <input type="submit" name="122" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');"> <font size="1">click to save changes</font> 
        <%}%>
        
        <input type="submit" name="123" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.payee_name.value=''">
         <font size="1">click to cancel edit</font></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: 
          LIST OF EXISTING PAYEES IN THE DATABASE :: </strong></font></div></td>
    </tr>
    <tr> 
      <td width="35%" height="25" class="thinborder"><div align="center"><strong><font size="1">PAYEE 
          NAME</font></strong></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong><font size="1">CATEGORY</font></strong></div></td>
      <td width="22%" class="thinborder" align="center">
        <font size="1"><strong>HIDE FROM DROP-DOWN</strong></font>
      </td>
      <td width="10%" class="thinborder">&nbsp;</td>
      <td width="10%" class="thinborder">&nbsp;</td>
    </tr>
	<%for (int i = 0; i < vRetResult.size(); i+=4){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=astrCategory[Integer.parseInt((String)vRetResult.elementAt(i+2))]%></td>
      <td class="thinborder" align="center">
	  <%if(((String)vRetResult.elementAt(i+3)).equals("1")){%>
	  <img src="../../../../images/tick.gif">
	  <%}else{%>
	  <img src="../../../../images/x.gif">
	  <%}%>
	  </td>
      <td class="thinborder"><div align="center"><font size="1">
          <input type="submit" name="1222" value="Edit" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PrepareToEdit('<%=vRetResult.elementAt(i)%>');">
          </font></div></td>
      <td class="thinborder"><font size="1"> 
        <input type="submit" name="1232" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="ConfirmDel('<%=vRetResult.elementAt(i)%>','<%=vRetResult.elementAt(i + 1)%>');">
        </font></td>
    </tr>
	<%}%>
  </table>
  <%}// end if vRetResult != null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="19%" height="18"><div align="left"></div></td>
      <td width="81%" height="18">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
<!-- this is very important - onUnload do not call close window -->
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">  
  <input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>