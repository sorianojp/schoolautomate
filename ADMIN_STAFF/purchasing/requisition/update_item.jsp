<%@ page language="java" import="utility.*,java.util.Vector,purchasing.Requisition " %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Suppliers</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function PageAction(strAction,strIndex,strCity){
	if(strAction == 0){
		if(confirm('Delete '+strCity+'?')){
			document.form_.pageAction.value = strAction;
			document.form_.strIndex.value = strIndex;
			ReloadPage();
		}			
	}
	else{
		document.form_.pageAction.value = strAction;
		document.form_.strIndex.value = strIndex;
		ReloadPage();
	}	
}
function ReloadPage(){
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce('form_');
}
function CancelClicked(){
	document.form_.item.value = "";
	document.form_.pageAction.value = "";		
	ReloadPage();
}
function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	
<% if (WI.fillTextValue("opner_form_field").length() != 0){%>
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>[window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>.selectedIndex].value = 
		document.form_.opner_form_field_value.value;
<% }%>	
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
<% if (WI.fillTextValue("opner_form_field").length() != 0){%>
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>[window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>.selectedIndex].value = 
		document.form_.opner_form_field_value.value;
<% }%>

	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();

		window.opener.focus();
	}
}
function FocusID() {
	document.form_.item.select();
	//alert("I am here.");
	document.form_.item.focus();	
}
</script>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();" onLoad="FocusID();">
<%
	DBOperation dbOP = null;	
	String strTemp = null;
	String strErrMsg = null;		
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}

		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}		
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Update Item","update_item.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Requisition REQ = new Requisition();	
	Vector vRetResult = null;
	Vector vRetItem = null;	
	boolean bolErr = false;
	String strLastEntry = WI.getStrValue(WI.fillTextValue("opner_form_field_value"),"0");		
	
	if(WI.fillTextValue("pageAction").length() > 0){
		vRetItem = REQ.operateOnPreloadItem(dbOP,request,Integer.parseInt(WI.fillTextValue("pageAction")));
		if(vRetItem == null){
			strErrMsg = REQ.getErrMsg();
			if(WI.fillTextValue("pageAction").equals("2"))
				bolErr = true;
		}		
		else if (vRetItem != null && !(WI.fillTextValue("pageAction").equals("3"))){
			strErrMsg = " Operation successful.";
			if(WI.fillTextValue("pageAction").equals("0"))
				strLastEntry = "0";			
			else
				strLastEntry = (String)vRetItem.elementAt(0);				
		}
	}
	vRetResult = REQ.operateOnPreloadItem(dbOP,request,4);
%>
<form action="./update_item.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%if(WI.fillTextValue("is_supply").equals("0")){%>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          UPDATE NON-SUPPLY</strong></font><font color="#FFFFFF"><strong>/EQUIPMENT</strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong> 
          ITEMS PAGE ::::</strong></font></div></td>
    </tr>
	<%}else if(WI.fillTextValue("is_supply").equals("1")) {%>
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          UPDATE SUPPLY ITEMS PAGE ::::</strong></font></div></td>
    </tr>
	<%}else if(WI.fillTextValue("is_supply").equals("2")) {%>
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: UPDATE CHEMICALS ITEMS PAGE ::::</strong></font></div></td>
    </tr>
	<%}%>
    <tr> 
      <td height="25"><font size="3">&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%>
	  <a href="javascript:CloseWindow();">
	  <img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a>
	  </strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
    <%if(WI.fillTextValue("state").length() > 0){%>
    <tr>
      <td width="2%" rowspan="2">&nbsp;</td>
      <td width="12%" valign="top">&nbsp;</td>
      <td width="86%" valign="top">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td valign="top">Item Name</td>
      <td valign="top"> 
	  <%if(WI.fillTextValue("pageAction").equals("3"))
		  	strTemp = (String)vRetItem.elementAt(1);
		else if(WI.fillTextValue("item").length() > 0)
			strTemp = WI.fillTextValue("item");	
		else
			strTemp = "";
	  %> 
	  <!--<input name="item" type="text" value="<%=strTemp%>" size="64" maxlength="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"' style="font-size:11px;">-->
	  <textarea rows="2" cols="50" name="item"><%=strTemp%></textarea>
	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2"> <%if(WI.fillTextValue("pageAction").equals("3") || bolErr == true){%> 
	  <a href="javascript:PageAction(2,'<%=WI.fillTextValue("strIndex")%>','');"> 
        <img src="../../../images/edit.gif" border="0"></a><font size="1">click 
        to save changes</font> <a href="javascript:CancelClicked();"> <img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel edit</font> <%}else{%> <a href="javascript:PageAction(1,'','');"> 
        <img src="../../../images/add.gif" border="0"></a> <font size="1">click 
        to add entry</font> </td>
      <%}%>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">&nbsp; </td>
    </tr>    
  </table>
 <% if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" align="center" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <%if(WI.fillTextValue("is_supply").equals("0")){%>
	<tr> 
      <td colspan="4" bgcolor="#666666" class="thinborder"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF NON-SUPPLY ITEM(S)</font></strong></div></td>
    </tr>
	<%}else{%>
	<tr> 
      <td colspan="4" bgcolor="#666666" class="thinborder"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF SUPPLY ITEM(S)</font></strong></div></td>
    </tr>
	<%}%>
    <tr align="center"> 
      <td width="10%" class="thinborder"><strong>COUNT</strong></td>
      <td width="70%" class="thinborder"><strong>ITEM</strong></td>
      <td width="10%" class="thinborder"><strong>EDIT</strong></td>
      <td width="10%" class="thinborder"><strong>DELETE</strong></td>
    </tr>
    <% for (int iLoop =0; iLoop < vRetResult.size() ; iLoop+=5){ %>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+2)/2%></div></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(iLoop+1)%></td>
      <td class="thinborder"><div align="center"> 
	  <a href = "javascript:PageAction(3,<%=(String)vRetResult.elementAt(iLoop)%>,'');"> 
          <img src="../../../images/edit.gif" border="0"></a> </div></td>
      <td  class="thinborder"> <div align="center"> 
	  <a href="javascript:PageAction(0,<%=(String)vRetResult.elementAt(iLoop)%>,'<%=(String)vRetResult.elementAt(iLoop+1)%>');"> 
          <img src="../../../images/delete.gif" border="0"></a> </div></td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="strIndex" value="">
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
  <input type="hidden" name="cat_index" value="<%=WI.fillTextValue("cat_index")%>">
  <input type="hidden" name="class_index" value="<%=WI.fillTextValue("class_index")%>">
    
  <!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">
  <input type="hidden" name="opner_form_field" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_field"),"")%>">
  <input type="hidden" name="opner_form_field_value" value="<%=strLastEntry%>">
  <!-- this is very important - onUnload do not call close window -->
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>

