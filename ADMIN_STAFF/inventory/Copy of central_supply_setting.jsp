<%@ page language="java" import="utility.*, java.util.Vector, purchasing.PURSetting" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function SetFocus()
{
	document.form_.d_index.focus();
}
function AddRecord()
{
	document.form_.addRecord.value = "1";
}
 
</script>
<body bgcolor="#D2AE72" onLoad="SetFocus();">
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Set Allowed late time in","purchasing_setting.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"purchasing_setting.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

PURSetting purSetting = new PURSetting();

String strCentralDept = null;
String strDeptName = null;
strTemp = WI.fillTextValue("addRecord");
if(strTemp.compareTo("1") == 0)
{
	if(purSetting.operateOnPurchasingSetting(dbOP, request, 1) != null)
		strErrMsg = "Setting recorded successfully.";
	else
		strErrMsg = purSetting.getErrMsg();
}
	strCentralDept = purSetting.operateOnPurchasingSetting(dbOP, request, 3);
	if(strCentralDept != null && strCentralDept.length() > 0){
		strDeptName = "select d_name from department where is_del = 0 and d_index = " + strCentralDept;
		strDeptName = dbOP.getResultOfAQuery(strDeptName,0);
	}
%>	
<form action="purchasing_setting.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PURCHASING - SETTINGS ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2"><strong><font color="#FFFFFF">MAIN OFFICE(CENTRAL SUPPLIES)</font></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td width="26%">CURRENT OFFICE/DEPT SET : </td>
      <td width="71%"><strong>&nbsp;<%=WI.getStrValue(strDeptName,"No Setting")%></strong></td>
    </tr>
    
    <tr>
      <td height="29">&nbsp;</td>
      <td>Department</td>
      <%			
			if(strCentralDept == null || strCentralDept.length() == 0)
				strCentralDept = WI.fillTextValue("d_index");			
			%>
      <td height="29"><select name="d_index">
          <option value="">Select Office</option>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where is_del = 0 " + 
														" and (c_index = 0 or c_index is null) " +
														" order by d_name asc",strCentralDept, false)%>
      </select></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25"><div align="center">
	  <input type="image" src="../../images/save.gif" border="0" onClick="AddRecord();">
	  <font size="1">Click to save changes</font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">		
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="addRecord">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>