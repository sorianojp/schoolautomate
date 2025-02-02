<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value=index;
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}

function ViewInfo(){
	document.staff_profile.page_action.value="0";
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}
function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.donot_call_close_wnd.value = "1";
//	this.SubmitOnce("staff_profile");
}

function EditRecord(){
	document.staff_profile.page_action.value="2";
	document.staff_profile.donot_call_close_wnd.value = "1";
//	this.SubmitOnce("staff_profile");
}

function DeleteRecord(strInfoIndex){
	document.staff_profile.page_action.value="0";
	document.staff_profile.donot_call_close_wnd.value = "1";
	document.staff_profile.info_index.value = strInfoIndex;
	this.SubmitOnce("staff_profile");
}

function ReloadPage(){
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}
function CancelEdit(){
	document.staff_profile.page_action.value ="";
	document.staff_profile.prepareToEdit.value="";
	document.staff_profile.donot_call_close_wnd.value = "1";
	document.staff_profile.emp_type.value = "";
	this.SubmitOnce("staff_profile");	
}

function CloseWindow(){
	document.staff_profile.close_wnd_called.value = "1";
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
	if(document.staff_profile.donot_call_close_wnd.value.length >0)
		return;

	if(document.staff_profile.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.submit();
		window.opener.focus();
	}
}
</script>

<body bgcolor="#663300" onUnload="ReloadParentWnd();" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strTemp2 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ADMIN/STAFF - HR Management - Personnel ",
								"hr_emp_type.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(), 
														"hr_emp_type.jsp");	
if(iAccessLevel < 1) {//All employees are allowed to use this, because this is a common file.
strTemp = (String)request.getSession(false).getAttribute("authTypeIndex");
int iAuthTypeIndex = Integer.parseInt(WI.getStrValue(strTemp,"-1"));//System.out.println(iAuthTypeIndex);
	if(iAuthTypeIndex != -1) {
		if(iAuthTypeIndex != 4 || iAuthTypeIndex != 6)//no access to parent / student
			iAccessLevel = 2;
	}

}
	//System.out.println(iAccessLevel);
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
	Vector vEditInfo = null;
	HRManageList  hrList = new HRManageList();
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	
	if (WI.fillTextValue("page_action").compareTo("0") ==0){
		if (hrList.operateOnEmploymentList(dbOP,request,0) != null) {
			strErrMsg = " Employment type removed successfully";
			strPrepareToEdit = "";
		}else{
			strErrMsg = hrList.getErrMsg();
		}
	}else 	if (WI.fillTextValue("page_action").compareTo("1") ==0){
		if (hrList.operateOnEmploymentList(dbOP,request,1) != null) {
			strErrMsg = " Employment type recorded successfully";
		}else{
			strErrMsg = hrList.getErrMsg();
		}
	}else	if (WI.fillTextValue("page_action").compareTo("2") ==0){
		if (hrList.operateOnEmploymentList(dbOP,request,2) != null) {
			strErrMsg = " Employment type updated successfully";
			strPrepareToEdit = "";
		}else{
			strErrMsg = hrList.getErrMsg();
		}
	}
	
	if (strPrepareToEdit.length() > 0){
		vEditInfo = hrList.operateOnEmploymentList(dbOP,request,3);
		if (vEditInfo == null)
			strErrMsg = hrList.getErrMsg();
	}
	
	vRetResult =  hrList.operateOnEmploymentList(dbOP,request,4);
	if (vRetResult == null && strErrMsg == null){
		strErrMsg = hrList.getErrMsg();
	}

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
%>
<form action="./hr_emp_type.jsp" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          HEAD DEPARTMENT MAIN OFFICES::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <% if (vEditInfo!=null) strTemp = (String) vEditInfo.elementAt(1);
   else strTemp = WI.fillTextValue("emp_type"); 
 %>
      <td width="3%">&nbsp;</td>
      <td width="20%" valign="middle">Head Office Name </td>
      <td width="77%" valign="top"><input name="emp_type" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="40"></td>
    </tr>
    <% if (strSchCode.startsWith("AUF")){%>
    <tr>
      <td>&nbsp;</td>
      <td valign="top">Head Office Code </td>
      <td valign="top"><input name="emp_type2" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16" maxlength="16"></td>
    </tr>
<%} //end strSchCode == auf%>
    <tr> 
      <td>&nbsp;</td>
      <td valign="top">Hierarchy Order</td>
<%

	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(3));
	else 	strTemp = WI.fillTextValue("position_order");
%>
      <td valign="top"><input name="position_order" type="text" class="textbox" id="position_order" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="2">
        <font size="1">(set 1 as the priority..)</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2"> <% 
	  if(iAccessLevel > 1) {
	  if (vEditInfo != null){%> <input name="image" type="image" onClick='EditRecord()' src="../../../images/edit.gif" border="0"> 
        <font size="1">click to save changes</font> <a href='javascript:CancelEdit();'><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click 
        to cancel edit</font> <%}else{%> <input name="image" type="image" onClick='AddRecord()' src="../../../images/add.gif" width="42" height="32"> 
        <font size="1">click to add entry</font> <%}}%> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>


 <% 
 //System.out.println(vRetResult);
// System.out.println(vRetResult.size());
 
 if (vRetResult !=null){ %>  
<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td colspan="5" bgcolor="#A99A65"><div align="center"><strong><font color="#FFFFFF">LIST OF HEAD DEPARTMENT OFFICES</font></strong></div></td>
    </tr>
</table>
  <table width="100%" border="0" align="center" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr align="center"> 
      <td width="2%"><font size="1">&nbsp;</font></td>

      <td width="11%"><font size="1"><strong>HIERARCHY</strong></font></td>
<% if (strSchCode.startsWith("AUF")){%>
      <td width="23%"><font size="1"><strong>CODE</strong></font></td>
      <%}%>
      <td width="44%"><font size="1"><strong>NAME</strong></font></td>
      <td colspan="2"><font size="1"><strong>OPTIONS</strong></font> </td>
    </tr>
    <% for (int i =0; i < vRetResult.size() ; i+=4){ %>
    <tr> 
      <td>&nbsp;</td>

      <td><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>
<% if (strSchCode.startsWith("AUF")) {%>
      <td><%=astrCategory[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2),"0"))]%></td>
<%}%>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td width="7%"><div align="center"> <% if (iAccessLevel > 1) {%>
          <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>)"><img border="0" src="../../../images/edit.gif" width="40" height="26"></a> <%}else{%> N/A <%}%></div></td>
      <td width="13%"><% if (iAccessLevel==2){%><a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a><%}else{%>NA<%}%></td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
<% if (strSchCode.startsWith("AUF")) {%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>">

<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
</form>
</body>
</html>

