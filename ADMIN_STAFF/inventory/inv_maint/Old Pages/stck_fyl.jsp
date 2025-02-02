<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
</html>
<html>
<head>
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
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::INVENTORY MANAGEMENT-STOCK FILING::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td width="1%" height="30">&nbsp;</td>
      <td width="21%">Stock by </td>
      <td width="20%" valign="middle"><label>
        <select name="select">
          <option selected>Select stock type</option>
          <option>Bulk</option>
          <option>Unit</option>
        </select>
      </label></td>
      <td width="13%" valign="middle"><font size="1"><img src="../../../images/search.gif" alt="search" width="37" height="30" border="0"></font></td>
      <td width="18%" valign="middle"><strong>Date Filed</strong></td>
      <td width="27%" valign="middle">
        <input name="eff_date" type= "text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="" size="12" maxlength="12" readonly="true">
      <a href="javascript:show_calendar('form_.eff_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="30" valign="middle"><label><font size="1"></font></label></td>
      <td height="30" valign="middle"><font size="1"><a href="javascript:UpadteUnit();"></a></font></td>
      <td>Entered  by </td>
      <td height="30" valign="middle"><label><span class="bodystyle style1">
        <input name="textfield2" type="text" class="textbox">
      </span></label></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>Property # </td>
      <td height="18" valign="middle"><label><font size="1">
        <input name="textfield5" type="text" class="textbox" size="12" maxlength="12">
      </font></label></td>
      <td height="18" valign="middle">(if unit stock)</td>
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle">&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>Quantity Added </td>
      <td height="18" valign="middle"><input name="textfield" type="text" class="textbox" size="12" maxlength="12"></td>
      <td height="18" valign="middle">(if bulk stock)</td>
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle"><font size="1"><a href="lab_mgmt.jsp" target="_self"><img src="../../../images/save.gif" alt="save" width="48" height="28" border="0"></a>click to file </font></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="30" valign="middle">&nbsp;</td>
      <td height="30" valign="middle">&nbsp;</td>
      <td height="30" valign="middle">&nbsp;</td>
      <td height="30" valign="middle"><font size="1"><a href="lab_mgmt.jsp" target="_self"><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a>click to cancel</font></td>
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

