<%
String strStudID    = (String)request.getSession(false).getAttribute("userId");
if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAYER INFORMATION</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
function Register() {
	objButton = document.getElementById('_submit');
	objButton.disabled=true;

	document.form_.create_.value = '1';
	document.form_.submit();
}
</script>
<body onLoad="document.form_.payer_name.focus();">
<%@ page language="java" import="utility.*,java.util.Vector,onlinepayment.Registration" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
//add security here.
	try
	{
		dbOP = new DBOperation();
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
	Vector vRetResult  	= null;
	Registration registration = new Registration();
	if(WI.fillTextValue("create_").length() > 0) {
		if(registration.operateOnUserProfile(dbOP, request, 1, true) == null)
			strErrMsg = registration.getErrMsg();
		else {
			//redirect now.. 
			dbOP.cleanUP();
			response.sendRedirect("./user_summary.jsp");
			return;
		}
	}
	
%>
<form name="form_" method="post" action="./register_new.jsp">
<%
if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" style="font-weight:bold; color:#FF0000; font-size:16px;">Failed to Create Profile ==> (Message): <%=strErrMsg%></td>
    </tr>
  </table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2" align="center" class="thinborderBOTTOM"><font size="1"><strong>REGISTRATION INFORMATION</strong></font></td>
    </tr>
    <tr >
      <td height="35" colspan="2" class="thinborderNONE" style="font-weight:bold; color:#0000FF">Note: Please provide all correct information. Once saved, information can't be modified. All fields are mandatory. </td>
    </tr>
    <tr >
      <td width="14%" height="20" class="thinborderNONE">Name: </td>
      <td width="86%">
	  
	  <input name="payer_name" type="text" size="64" value="<%=WI.fillTextValue("payer_name")%>" class="textbox" maxlength="64"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr >
      <td height="20" class="thinborderNONE">Email ID: </td>
      <td><input name="payer_email_id" type="text" size="32" value="<%=WI.fillTextValue("payer_email_id")%>" class="textbox" maxlength="64"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr >
      <td height="20" class="thinborderNONE">Password: </td>
      <td><input name="payer_password" type="password" size="32" value="<%=WI.fillTextValue("payer_password")%>" class="textbox" maxlength="32"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">(minimum 6 characters)</font></td>
    </tr>
    <tr >
      <td height="20" class="thinborderNONE">Retype Password: </td>
      <td>
	  <input name="retype_password" type="password" size="32" value="<%=WI.fillTextValue("retype_password")%>" class="textbox" maxlength="32"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr >
      <td height="20" class="thinborderNONE">DOB: </td>
      <td>
		<input name="payer_dob" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("payer_dob")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.payer_dob');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
    <tr >
      <td height="20" class="thinborderNONE">Mobile Number : </td>
      <td>
	  <input name="payer_phone" type="text" size="12" value="<%=WI.fillTextValue("payer_phone")%>" class="textbox" maxlength="11"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr >
      <td height="20" class="thinborderNONE" valign="top"><br>Address: </td>
      <td>
	  <textarea name="payer_address" rows="4" cols="60" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("payer_address")%></textarea>	  </td>
    </tr>
    <tr >
      <td height="20" class="thinborderNONE">Payer Type: </td>
      <td>
	  <select name="payer_type" style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px;">
	  	<option value="PARENT">PARENT</option>
<%
strTemp = WI.fillTextValue("payer_type");
if(strTemp.equals("STUDENT"))
	strTemp = " selected";
else	
	strTemp = "";
%>		
		<option value="STUDENT"<%=strTemp%>>STUDENT</option>
	  </select>	  </td>
    </tr>
<!--
    <tr >
      <td height="20" colspan="2" class="thinborderNONE" style="font-size:14px;"><strong>NOTE: If you are having difficulty in registration, Please proceed to Student Accounting Office. </strong></td>
    </tr>
-->
    <tr >
      <td height="20" class="thinborderNONE">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr >
      <td height="20" class="thinborderNONE">&nbsp;</td>
      <td>
        <input type="button" name="12" value=" Create Profile >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="Register();" id="_submit">	  </td>
    </tr>
  </table>
<input type="hidden" name="create_">  
</form>	
</body>
</html>
<%
dbOP.cleanUP();
%>