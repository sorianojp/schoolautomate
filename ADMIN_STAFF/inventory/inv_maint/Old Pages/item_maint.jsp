<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-family: Verdana, Arial, Helvetica, sans-serif}
.style3 {color: #000000}
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script>
</script>
<%@ page language="java" import="utility.*,java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTempStudId = request.getParameter("temp_id");
	int iMaxDisplayed = 0;
	String strDegreeType = null;

	Vector[] vAutoAdvisedList = new Vector[2];


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearance-Clearance Management-Manage Signatories","manage_signatories.jsp");
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
														"Clearance","Clearance Management",request.getRemoteAddr(),
														"manage_signatories.jsp");
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
%>


<body bgcolor="#D2AE72">
<form name="form_" action="eqpt_reg.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE -ITEMS REGISTER::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
    <tr>
      <td width="1%" height="30">&nbsp;</td>
      <td width="16%">Item Name </td>
      <td width="19%" height="25" valign="middle"><label>
        <input name="textfield" type="text" class="textbox" size="20" maxlength="20">
        <font size="1"></font></label></td>
      <td width="8%" height="25" valign="middle"><font size="1"><img src="../../../images/search.gif" alt="search" border="0"></font></td>
      <td height="25" colspan="2" valign="middle">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>Type</td>
      <td height="25" colspan="4" valign="middle"><select name="select">
        <option>Select Type</option>
        <option>Consumable</option>
        <option>Equipment</option>
      </select>      </td>
    </tr>
    <tr>
      <td height="28">&nbsp;</td>
      <td class="bodystyle style1">Category</td>
      <td height="28" colspan="4" valign="middle"><select name="select2">
        <option>Select Category</option>
        <option>Generic</option>
        <option>Apparatus</option>
        <option>Electronic</option>
        <option>PE Eqpt</option>
      </select>      </td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td class="style1 bodystyle">Unit</td>
      <td height="18" valign="middle"><label>
        <select name="select3">
          <option>Select Unit</option>
          <option>pcs</option>
          <option>packs</option>
          <option>sacks</option>
          <option>box</option>
          <option>ream</option>
        </select>
      </label></td>
      <td height="18" valign="middle"><font size="1"><img src="../../../images/update.gif" width="60" height="26" border="0"></font></td>
      <td width="22%" height="18" valign="middle"><label>
        <div align="right">
          <input name="textfield2" type="text" size="12" maxlength="12">
          </div>
      </label></td>
      <td width="34%" valign="middle"><strong><img src="../../../images/add.gif" width="42" height="32" border="0"></strong><font size="1">add unit </font></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td class="style1 bodystyle">Attributes:</td>
      <td height="18" colspan="4" valign="middle">&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td class="style1 bodystyle">&nbsp;</td>
      <td height="18" valign="middle"><label>
        <input type="checkbox" name="checkbox" value="checkbox">
      Transferrable</label></td>
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle"><font size="1"><img src="../../../images/update.gif" width="60" height="26" border="0">save changes</font></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td class="style1 bodystyle">&nbsp;</td>
      <td height="18" valign="middle"><label>
        <input type="checkbox" name="checkbox2" value="checkbox">
      Borrowable</label></td>
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle"><font size="1"><img src="../../../images/save.gif" alt="save" width="48" height="28">create new item </font></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td class="style1 bodystyle">&nbsp;</td>
      <td height="18" colspan="4" valign="middle">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="7" class="thinborder"><div align="center"> 
          <p><strong><font size="2">ITEM LIST </font></strong></p>
        </div></td>
    </tr>
    <tr>
      <td width="23%" height="25" class="thinborder"><div align="center"><strong>Item Name  </strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>Type </strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>Category</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>Unit</strong></div></td>
      <td width="17%" class="thinborder"><div align="center"><strong>Attributes</strong></div></td>
      <td width="17%" colspan="2" align="center" class="thinborder"><div align="center"><strong>OPTIONS</strong></div></td>
    </tr>
    <tr bordercolor="#111111">
      <td align="center" class="thinborder">Chair</td>
      <td align="center" class="thinborder">Equipment</td>
      <td align="center" bordercolor="#111111" class="thinborder">Generic</td>
      <td align="center" class="thinborder">pc</td>
      <td align="center" class="thinborder">Transferrable, Borrowable </td>
      <td align="center" class="thinborder"><img src="../../../images/edit.gif" width="40" height="26"></td>
      <td align="center" class="thinborder"><img src="../../../images/delete.gif" width="55" height="28" border="0"></td>
    </tr>
    <tr bordercolor="#111111">
      <td align="center" class="thinborder">Test Tube </td>
      <td align="center" class="thinborder">Equipment</td>
      <td align="center" class="thinborder">Apparatus</td>
      <td align="center" class="thinborder">pc</td>
      <td align="center" class="thinborder">Borrowable</td>
      <td align="center" class="thinborder"><img src="../../../images/edit.gif" width="40" height="26"></td>
      <td align="center" class="thinborder"><img src="../../../images/delete.gif" width="55" height="28" border="0"></td>
    </tr>
    <tr bordercolor="#111111">
      <td align="center" class="thinborder">Keyboard</td>
      <td align="center" class="thinborder">Equipment</td>
      <td align="center" class="thinborder">Electronic</td>
      <td align="center" class="thinborder">pc</td>
      <td align="center" class="thinborder">Transferrable, Borrowable </td>
      <td align="center" class="thinborder"><img src="../../../images/edit.gif" width="40" height="26"></td>
      <td align="center" class="thinborder"><img src="../../../images/delete.gif" width="55" height="28" border="0"></td>
    </tr>
    <tr bordercolor="#111111">
      <td align="center" class="thinborder">Net</td>
      <td align="center" bordercolor="#111111" class="thinborder">Equipment</td>
      <td align="center" class="thinborder">PE Equipment </td>
      <td align="center" class="thinborder">pc</td>
      <td align="center" class="thinborder">Transferrable</td>
      <td align="center" class="thinborder"><img src="../../../images/edit.gif" width="40" height="26"></td>
      <td align="center" class="thinborder"><img src="../../../images/delete.gif" width="55" height="28" border="0"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
