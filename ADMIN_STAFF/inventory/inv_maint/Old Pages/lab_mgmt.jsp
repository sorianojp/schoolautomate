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
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::INVENTORY MAINTENANCE-STOCKROOM MANAGEMENT::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr> 
      <td width="1%" height="30">&nbsp;</td>
      <td width="21%"><strong>Stockroom Name </strong></td>
      <td colspan="2" valign="middle"><select name="select">
        <option selected>Select Laboratory</option>
		<option>Physics Stockroom</option>
		<option>Engg Computer Lab</option>
		<option>CS Computer Lab</option>
		<option>University Shop</option>
		<option>HS Stockroom</option>
		</select>
      </td>
      <td valign="middle"><font size="1"><img src="../../../images/view.gif" width="40" height="31" border="0"></font></td>
      <td width="18%" valign="middle">&nbsp;</td>
      <td width="6%" valign="middle">&nbsp;</td>
      <td width="8%" valign="middle">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>Stockroom Location </td>
      <td height="30" colspan="3" valign="middle">&nbsp;</td>
      <td height="30" valign="middle">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="30" valign="middle">&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="18" colspan="3" valign="middle"><label><font size="1"></font></label></td>
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle">&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>Can  Stock Item </td>
      <td width="12%" height="18" valign="middle"><input name="textfield52" type="text" class="textbox" size="12" maxlength="12"></td>
      <td width="10%" valign="middle">&nbsp;</td>
      <td width="24%" valign="middle"><font size="1"><strong><img src="../../../images/add.gif" alt="add" width="42" height="32" border="0"></strong></font></td>
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle">&nbsp;</td>
      <td height="18" valign="middle">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="30" colspan="3" valign="middle">&nbsp;</td>
      <td height="30" valign="middle">&nbsp;</td>
      <td height="30" valign="middle">&nbsp;</td>
      <td height="30" valign="middle">&nbsp;</td>
    </tr>
    <tr bgcolor="#ABA37C" class="thinborder">
      <td height="25" colspan="8" class="thinborder"><div align="center">
          <p><strong><font size="2">LIST OF ITEMS AVAILABLE IN STOCK </font></strong></p>
      </div></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td><div align="center"><strong>Item Name </strong></div></td>
      <td height="30" colspan="2" valign="middle"><div align="center"><strong>Property number </strong></div></td>
      <td height="30" valign="middle"><div align="center"><strong>Item Detail </strong></div></td>
      <td height="30" valign="middle"><div align="center"><strong>Available Stock</strong> </div></td>
      <td height="30" colspan="2" valign="middle"><div align="center"><strong>OPTIONS</strong></div></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td><div align="center">Ballast</div></td>
      <td height="30" colspan="2" valign="middle"><div align="center">P2005-10-10</div></td>
      <td height="30" valign="middle"><div align="center">40w </div></td>
      <td height="30" valign="middle"><div align="center">24</div></td>
      <td height="30" valign="middle"><div align="center"><font size="1"><a href="stck_fyl.jsp" target="_self"><strong><img src="../../../images/add.gif" alt="add" width="42" height="32" border="0"></strong></a></font></div></td>
      <td height="30" valign="middle"><div align="center"><img src="../../../images/delete.gif" width="55" height="28" border="0"></div></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td><div align="center"></div></td>
      <td height="30" colspan="2" valign="middle"><div align="center">P1999-12-31</div></td>
      <td height="30" valign="middle"><div align="center">20w</div></td>
      <td height="30" valign="middle"><div align="center">39</div></td>
      <td height="30" valign="middle"><div align="center"><font size="1"><a href="javascript:UpadteUnit();"></a></font><font size="1"><a href="stck_fyl.jsp" target="_self"><strong><img src="../../../images/add.gif" alt="add" width="42" height="32" border="0"></strong></a></font></div></td>
      <td height="30" valign="middle"><div align="center"><img src="../../../images/delete.gif" width="55" height="28" border="0"></div></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td><div align="center">Barrel Bolt </div></td>
      <td height="30" colspan="2" valign="middle"><div align="center">P1998-09-14</div></td>
      <td height="30" valign="middle"><div align="center">4&quot;</div></td>
      <td height="30" valign="middle"><div align="center">50</div></td>
      <td height="30" valign="middle"><div align="center"><font size="1"><a href="javascript:UpadteUnit();"></a></font><font size="1"><a href="stck_fyl.jsp" target="_self"><strong><img src="../../../images/add.gif" alt="add" width="42" height="32" border="0"></strong></a></font></div></td>
      <td height="30" valign="middle"><div align="center"><img src="../../../images/delete.gif" width="55" height="28" border="0"></div></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td><div align="center"></div></td>
      <td height="30" colspan="2" valign="middle"><div align="center">P2001-01-15</div></td>
      <td height="30" valign="middle"><div align="center">2&quot;</div></td>
      <td height="30" valign="middle"><div align="center">14</div></td>
      <td height="30" valign="middle"><div align="center"><font size="1"><a href="javascript:UpadteUnit();"></a></font><font size="1"><a href="stck_fyl.jsp" target="_self"><strong><img src="../../../images/add.gif" alt="add" width="42" height="32" border="0"></strong></a></font></div></td>
      <td height="30" valign="middle"><div align="center"><img src="../../../images/delete.gif" width="55" height="28" border="0"></div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"></div></td>
      <td><div align="center">Video Card </div></td>
      <td height="30" colspan="2" valign="middle"><div align="center"></div></td>
      <td height="30" valign="middle"><div align="center">32 Mb </div></td>
      <td height="30" valign="middle"><div align="center">5</div></td>
      <td height="30" valign="middle"><div align="center"><font size="1"><a href="stck_fyl.jsp" target="_self"><strong><img src="../../../images/add.gif" alt="add" width="42" height="32" border="0"></strong></a></font></div></td>
      <td height="30" valign="middle"><div align="center"><img src="../../../images/delete.gif" width="55" height="28" border="0"></div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"></div></td>
      <td><div align="center"></div></td>
      <td height="30" colspan="2" valign="middle"><div align="center"></div></td>
      <td height="30" valign="middle"><div align="center">128 Mb </div></td>
      <td height="30" valign="middle"><div align="center">2</div></td>
      <td height="30" valign="middle"><div align="center"><font size="1"><a href="stck_fyl.jsp" target="_self"><strong><img src="../../../images/add.gif" alt="add" width="42" height="32" border="0"></strong></a></font></div></td>
      <td height="30" valign="middle"><div align="center"><img src="../../../images/delete.gif" width="55" height="28" border="0"></div></td>
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

