<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.show_list.value = "";
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0' || strAction == '5') {
		if(!confirm("Do you want to remove authentication"))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
		
	document.form_.show_list.value ="1";
	document.form_.submit();
}
function SelectAll() {
	var iMaxDisp = document.form_.max_count.value;
	if(iMaxDisp == "" || iMaxDisp == "0")
		return;
	if(document.form_.sel_all.checked) {
		for(var i = 0; i < eval(iMaxDisp); ++i)
			eval('document.form_.input_'+i+'.checked=true');
	}
	else {
		for(var i = 0; i < eval(iMaxDisp); ++i)
			eval('document.form_.input_'+i+'.checked=false');	
	}
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.Authentication,java.util.Vector,java.util.StringTokenizer" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-User Management","authentication_batch.jsp");

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
														"System Administration","User Management",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","User Management - Authentication",request.getRemoteAddr(),
														null);
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
Authentication auth = new Authentication();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(auth.operateOnBatchProcessAuth(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = auth.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}

if(WI.fillTextValue("show_list").length() > 0) {
	vRetResult = auth.operateOnBatchProcessAuth(dbOP, request, 10);
	if(vRetResult == null) 
		strErrMsg = auth.getErrMsg();
}
%>
<form name="form_" action="authentication_batch.jsp" method="post" onSubmit="SubmitOnceButton(this);">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          AUTHENTICATION - BATCH PROCESS ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="25" colspan="4" style="font-size:13px; font-weight:bold; color:#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
 </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td>
	  <input type="checkbox" name="show_new" value="checked" <%=WI.fillTextValue("show_new")%> onClick="ReloadPage();"> 
	  Show  employees without autentication </td>
      <td>Filter ID/Last Name 
        <input type="text" name="filter_id" class="textbox" style=" border:dotted; border-width:1px; border-color:#0033CC; background-color:#DEEDFF" value="<%=WI.fillTextValue("filter_id")%>"></td>
    </tr>
<%//if(WI.fillTextValue("show_new").length() == 0) {%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="47%">Access type :	    
        <select name="auth_type">
		<option value="">Show All</option>
          <%=dbOP.loadCombo("AUTH_TYPE_INDEX","AUTH_TYPE"," from AUTH_TYPE where IS_DEL=0 and auth_type_index <> 4 and auth_type_index <> 6 order by AUTH_TYPE_INDEX asc", WI.fillTextValue("auth_type"), false)%>
        </select></td>
      <td width="50%">User type :
        <select name="mem_type">
		<option value="">ALL</option>
	<%=dbOP.loadCombo("MEM_TYPE_INDEX","MEMBER_TYPE"," from SCHOOL_MEM_TYPE where is_valid=1 and is_student=0 order by MEMBER_TYPE asc",WI.fillTextValue("mem_type"), false)%>
       </select>	  </td>
    </tr>
    <tr>
      <td height="41">&nbsp;</td>
      <td colspan="2" align="center"><input type="submit" name="1" value="Show List of employees" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='1'"></td>
    </tr>
<%//}//end of show_new.%>
    <tr>
      <td height="20" bgcolor="#0099FF" style="font-size:11px; font-weight:bold;">&nbsp;</td>
      <td colspan="2" bgcolor="#0099FF" style="font-size:11px; font-weight:bold;">Add Authentication</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Modules to access :
        <select name="main_module" onChange="ReloadPage();" style="font-size:10px; font-family:Verdana, Arial, Helvetica, sans-serif">
          <option value="0">ALL</option>
          <%=dbOP.loadCombo("MODULE_INDEX","MODULE_NAME"," from MODULE where IS_DEL=0 order by MODULE_NAME asc", request.getParameter("main_module"), false)%>
        </select></td>
      <td>Sub-modules :
        <select name="sub_module">
		<option value="0">ALL</option>
          <%
strTemp = WI.fillTextValue("main_module");
if(strTemp.length() ==0) strTemp = "0";
strTemp = " from SUB_MODULE where is_del=0 and module_index="+strTemp+" order by sub_mod_name";
%>
          <%=dbOP.loadCombo("SUB_MOD_INDEX","SUB_MOD_NAME",strTemp, request.getParameter("sub_module"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Access mode:
        <select name="access_mode">
          <option value="0">Read Only</option>
<%
strTemp = WI.fillTextValue("access_mode");
if(WI.fillTextValue("reloadPage").compareTo("1") !=0)
	strTemp = "";
if(strTemp.compareTo("1") ==0){
%>
          <option value="1" selected>Read/Write(full)</option>
<%}else{%>
          <option value="1">Read/Write(full)</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Read/Write(edit)</option>
<%}else{%>
          <option value="2">Read/Write(edit)</option>
<%}%>
        </select></td>
      <td>
	  	<input type="submit" name="122" value="Save Authentication" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='1';document.form_.page_action.value='1';">
      </td>
    </tr>
<%
if( iAccessLevel >1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" align="center"></td>
    </tr>
<%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td height="25" colspan="7" bgcolor="#B9B292" align="center" style="font-size:11px; font-weight:bold;" class="thinborder">List Of Employees</td>
    </tr>
    <tr>
      <td width="3%" class="thinborder" align="center" style="font-size:9px;font-weight:bold">SL #</td>
      <td width="12%" height="25" class="thinborder" align="center" style="font-size:9px;font-weight:bold">Employee ID </td>
      <td width="20%" class="thinborder" align="center" style="font-size:9px;font-weight:bold">Employee Name </td>
      <td width="10%" class="thinborder" align="center" style="font-size:9px;font-weight:bold">Access Type </td>
      <td width="10%" class="thinborder" align="center" style="font-size:9px;font-weight:bold">User Type </td>
      <td width="40%" class="thinborder" align="center" style="font-size:9px;font-weight:bold">Authentication List </td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px;font-weight:bold">SELECT<br>
	  <input type="checkbox" name="sel_all" onClick="SelectAll();"> <font style="font-size:8px;">(ALL)</font></td>
    </tr>
<%int iTotListCount = 0;
for(int i = 0; i < vRetResult.size(); i += 6){%>
    <tr>
      <td class="thinborder" valign="top"><%=iTotListCount + 1%>.</td>
      <td height="25" class="thinborder" valign="top">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" valign="top">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" valign="top">&nbsp;<%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" valign="top">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 4))%></td>
      <td class="thinborder" style="font-size:9px;" valign="top"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "&nbsp;")%></td>
      <td align="center" class="thinborder"><input type="checkbox" name="input_<%=iTotListCount++%>" value="<%=vRetResult.elementAt(i)%>"></td>
    </tr>
<%}%>
    <tr>
      <td height="45" colspan="7" align="center" class="thinborder"><input type="submit" name="1222" value="Save Authentication" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='1';document.form_.page_action.value='1';"></td>
    </tr>
  </table>
<input type="hidden" name="max_count" value="<%=iTotListCount%>">

<%}//end of if(vRetResult != null && vRetResult.size() > 0) { %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="show_list">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
