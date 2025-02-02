<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
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
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE- CONSUMABLES ENTRY LOG::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="7">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>Entry Type </td>
      <td valign="middle"><label>
        <select name="select">
          <option>Select Type</option>
          <option>Purchase</option>
          <option>Donation</option>
        </select>
      </label></td>
      <td valign="middle">&nbsp;</td>
      <td height="25" valign="middle"><strong>Entry Log #</strong></td>
      <td width="19%" height="25" valign="middle"><input name="textfield3" type="text" class="textbox" size="20" maxlength="20"></td>
      <td width="9%" valign="middle"><font size="1"><img src="../../../images/search.gif" alt="search" border="0"></font></td>
    </tr>
    <tr> 
      <td width="1%" height="30">&nbsp;</td>
      <td width="17%" valign="middle"><strong>Control number</strong> </td>
      <td width="19%" valign="middle"><label>
        <input name="textfield" type="text" class="textbox" size="20" maxlength="20">
      </label></td>
      <td width="20%" valign="middle"><font size="1"><img src="../../../images/search.gif" alt="search" border="0"></font></td>
      <td width="15%" height="25" valign="middle"><strong>Entry Date:</strong></td>
      <td height="25" colspan="2" valign="middle"><input name="eff_date" type= "text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="" size="12" maxlength="12" readonly="true">
      <a href="javascript:show_calendar('form_.eff_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>Recieved by </td>
      <td height="25" valign="middle"><label><font size="1">
        <input name="textfield2" type="text" class="textbox" size="20" maxlength="20">
      </font></label></td>
      <td height="25" valign="middle">&nbsp;</td>
      <td height="25" valign="middle">&nbsp;</td>
      <td height="25" colspan="2" valign="middle">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25" valign="middle">&nbsp;</td>
      <td height="25" valign="middle"><font size="1"><img src="../../../images/save.gif" alt="save" width="48" height="28"></font></td>
      <td height="25" valign="middle"><font size="1"><img src="../../../images/cancel.gif" width="51" height="26" border="0"></font></td>
      <td height="25" colspan="2" valign="middle">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="7">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"> 
          <p><strong><font size="2"> ENTRY LIST </font></strong></p>
        </div></td>
    </tr>
    <tr>
      <td height="25" colspan="2" class="thinborder"><div align="center"><strong>Received</strong></div></td>
      <td width="103" class="thinborder"><div align="center"><strong>Item Name </strong></div></td>
      <td width="103" class="thinborder"><div align="center"><strong>Property #  </strong></div></td>
      <td width="110" class="thinborder"><div align="center"><strong>Quantity</strong></div></td>
      <td width="125" class="thinborder"><div align="center"><strong>Laboratory</strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong>OPTIONS</strong></div></td>
    </tr>
    <tr bordercolor="#111111">
      <td colspan="2" align="center" class="thinborder"><label>
        <input type="checkbox" name="checkbox" value="checkbox">
      </label></td>
      <td align="center" class="thinborder">Nitroglycerine</td>
      <td align="center" class="thinborder">P1998-10-21</td>
      <td align="center" class="thinborder">100 li </td>
      <td align="center" class="thinborder">Chemistry</td>
      <td width="71" align="center" class="thinborder"><a href="eqpt_lctr.jsp" target="_blank">Locate</a></td>
      <td width="54" align="center" class="thinborder">Remove</td>
    </tr>
    <tr bordercolor="#111111">
      <td colspan="2" align="center" class="thinborder"><input type="checkbox" name="checkbox2" value="checkbox"></td>
      <td align="center" class="thinborder">Hydrochloric</td>
      <td align="center" class="thinborder">P1998-10-23</td>
      <td align="center" class="thinborder">100 kg </td>
      <td align="center" class="thinborder">Chemistry</td>
      <td align="center" class="thinborder"><a href="eqpt_lctr.jsp" target="_blank">Locate</a></td>
      <td align="center" class="thinborder">Remove</td>
    </tr>
    <tr bordercolor="#111111">
      <td colspan="2" align="center" class="thinborder"><input type="checkbox" name="checkbox3" value="checkbox"></td>
      <td align="center" class="thinborder">Phosphase</td>
      <td align="center" class="thinborder">P1998-10-25</td>
      <td align="center" class="thinborder">100 kg </td>
      <td align="center" class="thinborder">Chemistry</td>
      <td align="center" class="thinborder"><a href="eqpt_lctr.jsp" target="_blank">Locate</a></td>
      <td align="center" class="thinborder">Remove</td>
    </tr>
    <tr bordercolor="#111111">
      <td width="84" align="center" class="thinborder">select all </td>
      <td width="84" align="center" class="thinborder">select none </td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
    </tr>
    <tr bordercolor="#111111">
      <td colspan="2" align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
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

