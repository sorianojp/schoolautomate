<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ReloadPage()
{
	document.vendor_access.submit();
}
function AddMainModule()
{
	document.vendor_access.page_action.value="1";
}
function EditMainModule()
{
	document.vendor_access.page_action.value="2";
}
function DeleteMainModule()
{
	document.vendor_access.page_action.value="3";
}
function AddSubModule()
{
	document.vendor_access.page_action.value="4";
}
function EditSubModule()
{
	document.vendor_access.page_action.value="5";
}
function DeleteSubModule()
{
	document.vendor_access.page_action.value="6";
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
Vector vViewSub = new Vector();
Authentication auth = new Authentication();
strTemp = WI.fillTextValue("page_action");
if(strTemp.trim().length() > 0 && strTemp.compareTo("0") != 0)
{
	if(auth.operateOn(dbOP, request, strTemp) != null)
		strErrMsg = "Operation successful";
	else
		strErrMsg = auth.getErrMsg();
}
vViewSub = auth.operateOn(dbOP, request,"0");//0 for view.
if(strErrMsg == null)	strErrMsg = "";
%>
<form name="vendor_access" action="./manage_module_submodule_vendor_access.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          AUTHENTICATION PAGE - VENDOR ACCESS ONLY::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="25%">Access Password</td>
      <td width="73%"><input type="password" name="password" value="4791"></td>
    </tr>
    <tr>
      <td  colspan="3" height="25"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="40%" valign="top">Main module Name
        <select name="main_module" onChange="ReloadPage();">
		<option value="0">Add new Name</option>
<%=dbOP.loadCombo("MODULE_INDEX","MODULE_NAME"," from MODULE where IS_DEL=0 order by MODULE_NAME asc", request.getParameter("main_module"), false)%>
        </select></td>
      <td width="58%">
	  <input type="text" name="main_module_name"><br>
	  <input type="image" src="../../images/add.gif" onClick="AddMainModule();">click to add new module name <br>
        <input type="image" src="../../images/edit.gif" onClick="EditMainModule();">Click to edit the module name(select
        the module name to be edited) <br><input type="image" src="../../images/delete.gif" onClick="DeleteMainModule();">
        Click to delete the selected module name</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Sub Module Name :
        <select name="sub_module">
		  <option value="0">Add new Name</option>
<%
strTemp = WI.fillTextValue("main_module");
if(strTemp.length() ==0) strTemp = "0";
strTemp = " from SUB_MODULE where is_del=0 and module_index="+strTemp+" order by sub_mod_name";
%>
<%=dbOP.loadCombo("SUB_MOD_INDEX","SUB_MOD_NAME",strTemp, request.getParameter("sub_module"), true)%>
        </select></td>
      <td><input type="text" name="sub_module_name">
        <br>
        <input name="image" type="image" onClick="AddSubModule();" src="../../images/add.gif">
        click to add new module name <br> <input name="image" type="image" onClick="EditSubModule();" src="../../images/edit.gif">
        Click to edit the module name(select the module name to be edited) <br>
        <input name="image" type="image" onClick="DeleteSubModule();" src="../../images/delete.gif">
        Click to delete the selected module name</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><div align="right"></div></td>
      <td>&nbsp;</td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center">LIST OF
          SUB MODULES</div></td>
    </tr>
    <tr>
      <td height="25"><div align="center"><font size="1"></font></div></td>
      <td><div align="center"><strong><font size="1">SUB-MODULES</font></strong></div></td>
    </tr>
<%
for(int i=0; i< vViewSub.size(); ++i)
{%>    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%" align="center"><%=(String)vViewSub.elementAt(i)%></td>
    </tr>
<%}%>
  </table>
	 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="page_action" value="0">

</form>
</body>
</html>
