<%@ page language="java" import="utility.*,java.util.Vector,hr.HRSalaryGrade" %>
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
<script language="JavaScript">
function FocusID() {
	document.form_.benefit_name.select();
	document.form_.benefit_name.focus();	
}
function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value=index;
	document.form_.donot_call_close_wnd.value = "1";
}

function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.reloadPage.value = "1";
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.submit();
}
function CancelEdit(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.prepareToEdit.value = "";
	document.form_.page_action.value = "";
	
	document.form_.benefit_name.value = "";
	document.form_.submit();
}

function CloseWindow()
{
	document.form_.close_wnd_called.value = "1";
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
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

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management - manage incentive/benefit type",
								"sal_ben_incent_type_update.jsp");
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
														"sal_ben_incent_type_update.jsp");	
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
	String strLabel = WI.fillTextValue("label");	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	HRSalaryGrade  hrSG = new HRSalaryGrade();
	Vector vRetResult = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(hrSG.operateOnBenIncType(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = hrSG.getErrMsg();
		else {
			strErrMsg = "Operation is successful.";
			strPrepareToEdit = "0";
		}				
	}
	vRetResult = hrSG.operateOnBenIncType(dbOP, request, 4);
	if(strPrepareToEdit.compareTo("1") == 0)
		vEditInfo = hrSG.operateOnBenIncType(dbOP, request, 3);
	

%>
<form action="./sal_ben_incent_type_update.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          <%=strLabel%> RECORDS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%">&nbsp;</td>
<% if (vEditInfo!=null && vEditInfo.size() > 0){
	strTemp = (String) vEditInfo.elementAt(1);
}else{
	strTemp = WI.fillTextValue("benefit_name");
}
%>
      <td colspan="2" valign="top"><%=strLabel%>&nbsp;&nbsp; <textarea name="benefit_name" cols="40" rows="4" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="85%"> <% if (strPrepareToEdit.compareTo("1") == 0){%> 
	  <a href='javascript:PageAction("2","");'><img src="../../../images/edit.gif" border="0"></a>
        <font size="1">click to save changes</font> <a href='javascript:CancelEdit();'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
        to cancel edit</font> <%}else{%> <a href='javascript:PageAction("1","");'><img src="../../../images/add.gif" border="0"></a> 
        <font size="1">click to add entry</font> <%}%> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">&nbsp; </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>


 <% if (vRetResult !=null){ %>  
  <table width="100%" border="0" align="center" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" bgcolor="#666666"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF <%=strLabel%> </font></strong></div></td>
    </tr>
    <tr align="center"> 
      <td width="14%"><font size="1">&nbsp;</font></td>
      <td width="64%"><font size="1"><strong>NAME</strong></font></td>
      <td width="10%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
    </tr>
    <% for (int i =0; i < vRetResult.size() ; i+=2){ %>
    <tr> 
      <td>&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><div align="center">
          <input type="image" src="../../../images/edit.gif" onClick='PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'
	  							width="40" height="26">
        </div></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
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
  <input type="hidden" name="is_incentive" value="<%=WI.fillTextValue("is_incentive")%>">
  
  <input type="hidden" name="label" value="<%=strLabel%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">

<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
</form>
</body>
</html>

