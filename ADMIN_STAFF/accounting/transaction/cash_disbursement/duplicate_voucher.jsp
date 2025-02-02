<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

</style>
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">

</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strTemp   = null;
	String strErrMsg = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) 
		strSchCode = "";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","duplicate_voucher.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
if(WI.fillTextValue("copy_val").length() > 0) {
	JvCD jvcd = new JvCD();
	if(jvcd.duplicateJVCD(dbOP, request) )
		strErrMsg = "Voucher Successfully copied.";
	else	
		strErrMsg = jvcd.getErrMsg();
}
%>
<form action="./duplicate_voucher.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::: COPY/DUPLICATE VOUCHER INFORMATION ::: </strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="85%" height="25" style="font-size:14px; color:#0000FF; font-weight:bold">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%>	  </td>
      <td width="15%" style="font-size:12px; color:#FF0000; font-weight:bold">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td>Voucher to Copy From </td>
      <td><input name="old_jv" type="text" value="<%=WI.fillTextValue("old_jv")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>New Voucher Number </td>
      <td><input name="new_jv" type="text" value="<%=WI.fillTextValue("new_jv")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="21%">Voucher Date</td>
      <td width="73%">
<%
strTemp = WI.fillTextValue("voucher_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>	  <input name="voucher_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.voucher_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
		
	  &nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="6%" height="30">&nbsp;</td>
      <td width="21%">&nbsp;</td>
      <td width="73%" valign="bottom"><input type="submit" name="123" value=" Copy Voucher Information " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="document.form_.copy_val.value='1'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><input name="focus_credit" type="text" class="textbox_noborder" style="background-color:#FFFFFF" size="1" readonly></td>
      <td style="font-size:14px; color:#0000FF; font-weight:bold">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
  <input type="hidden" name="copy_val">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>