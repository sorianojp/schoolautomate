<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(){
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function PageAction(strInfoIndex, strAction) {
	if(strAction == 1)
		document.form_.hide_save.src="../../images/blank.gif";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function InitID() {
	if(document.form_.CHNG_PSWD_FIRST_LOGON.selectedIndex != 2) 
		document.form_.initial_loginid.value = "";
}
function InitValidityDay() {
	if(document.form_.PWD_NEVER_EXPIRE.checked)
		document.form_.PASSWORD_VALIDITY.value = ""; 
}
</script>
<body bgcolor="#D2AE72">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Login account validity","set_param_user_acc_validity.jsp");

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
														"System Administration","SET PARAMETERS",request.getRemoteAddr(),
														"set_param_user_acc_validity.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
AccountValidity accountValidity = new AccountValidity();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(accountValidity.operateOnAccountValidity(dbOP, request,Integer.parseInt(strTemp)) != null ){
		strErrMsg = "Operation Successful.";
	}
	else
		strErrMsg = accountValidity.getErrMsg();
}
vRetResult = accountValidity.operateOnAccountValidity(dbOP, request,4);//view all.
//if(vRetResult == null)
//	System.out.println(accountValidity.getErrMsg());

%>
<form action="./set_param_user_acct_validity.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="88%" height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          USER ACCOUNT VALIDITY PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td>User</td>
      <td colspan="2"><select name="mem_type_index" onChange="ReloadPage();">
          <option value="0">All user</option>
          <%
strTemp = WI.fillTextValue("mem_type_index");
if(bolIsSchool){
	if(strTemp.compareTo("-1") ==0){%>
          <option value="-1" selected>Students</option>
    <%}else{%>
          <option value="-1">Students</option>
    <%}
	}//show only if school. 
	 	if(strTemp.compareTo("-2") ==0){%>
          <option value="-2" selected>Specific ID</option>
          <%}else{%>
          <option value="-2">Specific ID</option>
          <%}%>
          <%=dbOP.loadCombo("MEM_TYPE_INDEX","MEMBER_TYPE"," from SCHOOL_MEM_TYPE where IS_VALID=1 and is_student=0 order by MEMBER_TYPE asc", strTemp, false)%> </select> </td>
    </tr>
    <%
if(strTemp.compareTo("-2") ==0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>User ID :</td>
      <td><input name="user_id" type="text" size="16" value="<%=WI.fillTextValue("user_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td><img src="../../images/search.gif"> <font size="1">Click
        to search Employee</font></td>
    </tr>
<%}%>
    <tr>
      <td height="26" width="5%">&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="26%"> 
        <input type="submit" name="12" value=" Proceed >>" style="font-size:11px; height:24px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value=''"></td>
      <td width="55%">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25" >&nbsp;</td>
      <td colspan="3" ><strong><u>Settings</u></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="2" > <%
strTemp = WI.fillTextValue("PWD_NEVER_EXPIRE");
if(strTemp.compareTo("1") == 0 || request.getParameter("initial_loginid") == null)
	strTemp = "checked";
else
	strTemp = "";
%> <input type="checkbox" name="PWD_NEVER_EXPIRE" value="1" <%=strTemp%> onChange="InitValidityDay();">
        Password never expires</td>
      <td width="50%" >At First logon : 
        <select name="CHNG_PSWD_FIRST_LOGON" onChange="InitID();">
	  <option value="0">N/A</option>
<%
strTemp = WI.fillTextValue("CHNG_PSWD_FIRST_LOGON");
if(strTemp.compareTo("1") == 0){%> 
		<option value="1" selected>Change only password</option>
<%}else{%>
		<option value="1">Change only password</option>
<%}if(strTemp.compareTo("2") == 0) {%>
		<option value="2" selected>Change login id and password</option>
<%}else{%>
		<option value="2">Change login id and password</option>
<%}%>
</select>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="14%">Specify Validity </td>
      <td width="31%"> <input type="text" name="PASSWORD_VALIDITY" size="3" maxlength="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress="AllowOnlyInteger('form_','PASSWORD_VALIDITY');"
	  value="<%=WI.fillTextValue("PASSWORD_VALIDITY")%>" onKeyUp="InitValidityDay();">
        days </td>
      <td >Initial Digit of User ID :
        <input type="text" name="initial_loginid" size="5" maxlength="6" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("initial_loginid")%>"
	  onKeyUP="InitID();">
        <font size="1">(must enter if user ID is changed at first log on)</font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3" ><strong><font color="#0000FF">NOTE : Default Setting can
        be done by setting parameter for All User.</font></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >
        <input type="submit" name="122" value="Save Setting" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='1';"></td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td><div align="right"></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td height="25" colspan="4" bgcolor="#B9B292"><div align="center">USER ACCOUNT
          PARAMETER SETTINGS</div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="27%" height="24"><div align="center"><font size="1"><strong>USER</strong></font></div></td>
      <td width="16%"><div align="center"><font size="1"><strong>USER  ID</strong></font></div></td>
      <td width="28%"><div align="center"><font size="1"><strong>PASSWORD EXPIRE 
          CONDITION </strong></font></div></td>
      <td width="22%"><div align="center"><strong><font size="1"> AT FIRST LOGON</font></strong></div></td>
      <td width="7%">&nbsp;</td>
    </tr>
    <%String[] astrConvertAtFirstLogon = {"Do nothing","Change only password","Change loginID and password"};
	for(int i = 0; i< vRetResult.size(); i +=8){%>
    <tr> 
      <td height="25" align="center"> <%if(vRetResult.elementAt(i + 2) == null && vRetResult.elementAt(i + 1) == null && vRetResult.elementAt(i + 3) == null){%>
        ALL 
        <%}else{%>
        <%=WI.getStrValue(vRetResult.elementAt(i + 2),"&nbsp;")%>
        <%}%></td>
      <td height="25"><div align="center"><font size="1"> <%=WI.getStrValue(vRetResult.elementAt(i + 3),"&nbsp;")%></font></div></td>
      <td><div align="center"> 
          <% if(((String)vRetResult.elementAt(i + 4)).compareTo("1") ==0){%>
          Never expires
          <%}else{%>
          Expires in <%=vRetResult.elementAt(i + 6)%> day(s)<%}%></div></td>
      <td><div align="center"> <%=astrConvertAtFirstLogon[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%> 
	  <font size="1" color="#0000FF"><strong><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"<br> Prefix To ID ::: ","","")%></strong></font></div></td>
      <td><div align="center"> 
          <input type="submit" name="12" value="Delete" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=(String)vRetResult.elementAt(i)%>'">
		  </td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" >&nbsp;</td>
    </tr>
  </table>
 <%}//only if vRetResult is not null %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
