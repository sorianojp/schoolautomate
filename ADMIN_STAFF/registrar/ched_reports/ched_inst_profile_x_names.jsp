<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDInstProfile"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED ICT REPORT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
.body_font{
	font-size:11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	a {
	text-decoration: none;
	}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<script language="JavaScript">
function ReloadPage(){
	this.SubmitOnce("form_");
}

function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce("form_");
}

function AddNewRecord(){
	document.form_.page_action.value="1";
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value="2";
	document.form_.donot_call_close_wnd.value = "1";	
	this.SubmitOnce("form_");
}

function DeleteRecord(strName, index){
var vConfirm = confirm(" Confirm Delete Record:" + strName);
	if (vConfirm){
		document.form_.page_action.value="0";
		document.form_.info_index.value=index;
		document.form_.donot_call_close_wnd.value = "1";
		this.SubmitOnce("form_");
	}
}

function CancelEdit()
{
	document.form_.donot_call_close_wnd.value = "1";
	location = "./ched_inst_profile_x_names.jsp";
}

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


</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CHED REPORTS-CHED FORM B C","ched_form_ict_staff.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}


Vector vRetResult = null;
Vector vEditResult = null;
CHEDInstProfile cr = new CHEDInstProfile();


String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (WI.fillTextValue("page_action").equals("0")){
	if (cr.operateOnInstFormerNames(dbOP,request,0) != null){
		strErrMsg = " Institution's former name remove successfully";
		strPrepareToEdit = "0";
	}else
		strErrMsg =cr.getErrMsg();	
}else if (WI.fillTextValue("page_action").equals("1")){
	if (cr.operateOnInstFormerNames(dbOP,request,1) != null)
		strErrMsg = " Institution's former name saved successfully";
	else
		strErrMsg =cr.getErrMsg();	
}else if (WI.fillTextValue("page_action").equals("2")){
	if (cr.operateOnInstFormerNames(dbOP,request,2) != null){
		strErrMsg = " Institution's former name updated successfully";
		strPrepareToEdit = "0";
	}else
		strErrMsg =cr.getErrMsg();	
}

if (strPrepareToEdit.equals("1")){
	vEditResult = cr.operateOnInstFormerNames(dbOP,request,3);
	if (vEditResult == null) {
		strErrMsg = cr.getErrMsg();
	}
}


vRetResult = cr.operateOnInstFormerNames(dbOP,request,4);

if (vRetResult == null && cr.getErrMsg() != null) {
	strErrMsg = cr.getErrMsg();
}


%>
<body  onUnload="ReloadParentWnd();" >
<form name="form_" action="./ched_inst_profile_x_names.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2"><div align="center"><font color="#000000" size="2" face="Arial, Helvetica, sans-serif"><strong>Institution's Former Name </strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%><a href="javascript:CloseWindow();">
	  <img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="2" bgcolor="#FFFFFF">

    <tr> 
      <td width="25%" height="25" class="body_font"> &nbsp;Name of Institution</td>
	  
	 <% if (vEditResult != null)
	 		strTemp = (String)vEditResult.elementAt(1);
		else 
			strTemp = WI.fillTextValue("former_name");
	 %> 
      <td width="75%" ><input name="former_name" type="text" size="32" maxlength="64" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td class="body_font">&nbsp;Duration (Years)</td>
      <td>&nbsp;From&nbsp; 
        <% if (vEditResult != null)
	 		strTemp = (String)vEditResult.elementAt(2);
		else 
			strTemp = WI.fillTextValue("sy_from");
	 %> 	  
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','sy_from')" onKeyUP="AllowOnlyInteger('form_','sy_from')"> &nbsp;&nbsp;&nbsp; To &nbsp; 
	 <% if (vEditResult != null)
	 		strTemp = (String)vEditResult.elementAt(3);
		else 
			strTemp = WI.fillTextValue("sy_to");
	 %> 
	  <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','sy_from')" onKeyUP="AllowOnlyInteger('form_','sy_to')"> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="2"><div align="center">&nbsp; 
          <% if (iAccessLevel > 1)  {
		if (vEditResult == null || vEditResult.size() == 0) {
%>
          <a href="javascript:AddNewRecord()"> <img src="../../../images/save.gif" border="0"></a><font size="1">click 
          to save data </font> 
          <%}else{ %>
          <a href="javascript:EditRecord()"> <img src="../../../images/edit.gif" border="0"></a> 
          <font size="1">click to update data</font> <a href="javascript:CancelEdit()"> 
          <img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
          to cancel edit</font> 
          <%
		} // !strPrepareToEdit.equals("1")
 } // end iAccessLevel > 1
 %>
        </div></td>
    </tr>
  </table>

<% if (vRetResult != null && vRetResult.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="52%" height="25" class="thinborder"><div align="center"><strong>FORMER 
          NAME </strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>YEARS</strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>Options</strong></div></td>
    </tr>
    <% 
		for(int i= 0; i <vRetResult.size() ; i+=4) {
	%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><div align="center">&nbsp;<%=(String)vRetResult.elementAt(i+2)%> - <%=(String)vRetResult.elementAt(i+3)%></div></td>
      <td class="thinborder">&nbsp;
	  <% if (iAccessLevel > 1) { %> 
	  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"></a>
	  <% if (iAccessLevel == 2) {%>
	  <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i+1)%>','<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
	  <%} // end allow delete
	  } // end allow edit/delete%>
	  </td>
    </tr>
    <%} // end for loop %>
  </table>

 <% } // end if vRetResult %>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action" value="">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
    
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
