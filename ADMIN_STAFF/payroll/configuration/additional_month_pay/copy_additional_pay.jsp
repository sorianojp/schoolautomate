<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Copy additional month pay</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--

function CopyRecords(){
	document.form_.CopyRecords.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./copy_additional_pay.jsp";
}

function ReloadPage()
{
	this.SubmitOnce("form_");
}

-->
</script>
<%

	DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Set Additional Month  Pay Parameters","set_num_of_mths_pay.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"copy_additional_pay.jsp");
if(iAccessLevel == 0){
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION-SETADDLMNTH",request.getRemoteAddr(), null);
}														
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
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
Vector vRetResult = null;
PayrollConfig pr = new PayrollConfig();

if(WI.fillTextValue("CopyRecords").length() > 0){
  if(!pr.copyAddlMonthPay(dbOP, request))
	strErrMsg = pr.getErrMsg();	
  else
  	strErrMsg = "Copying completed successfully";
}	
%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./copy_additional_pay.jsp" method="post" name="form_" id="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="29" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: ADDITIONAL MONTH PAY PARAMETERS : COPY ADDITIONAL MONTH PAY::::</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="4%" height="25"><a href="addtl_mth_pay_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a></td>
      <td colspan="2">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
    
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20" valign="bottom">Year From: </td>
	  <%
	  	strTemp = WI.fillTextValue("year_from");
	  %>
      <td height="20" valign="bottom">
	    <input name="year_from" type="text" size="4" maxlength="4" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=WI.getStrValue(strTemp,"")%>" onKeyUp="AllowOnlyInteger('form_','year_from');"	 
       	onBlur="AllowOnlyInteger('form_','year_from');style.backgroundColor='white';"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20" valign="bottom">Year To: </td>
	  <%
	  	strTemp = WI.fillTextValue("year_to");
	  %>
      <td height="20" valign="bottom">
	    <input name="year_to" type="text" size="4" maxlength="4" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=WI.getStrValue(strTemp,"")%>" onKeyUp="AllowOnlyInteger('form_','year_to');"	 
       	onBlur="AllowOnlyInteger('form_','year_to');style.backgroundColor='white';"></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="34">&nbsp;</td>
      <td width="12%" height="34">&nbsp;</td>
      <td width="84%" height="34">
			<%if(iAccessLevel > 1){%>
			<a href="javascript:CopyRecords()"><img src="../../../../images/copy_all.gif" width="55" height="27" border="0"></a><font size="1">click 
        to copy entries <a href="javascript:CancelRecord()"><img src="../../../../images/cancel.gif" border="0" ></a>click 
        to cancel / clear entries</font>
			<%}else{%>
				Not Authorized to copy
			<%}%>
			</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>  
	<input type="hidden" name="CopyRecords">	
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>