<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Setting</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function UpdateProp(strInfoIndex){
	document.form_.update_info.value ="1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strErrMsg = null;
	String strTemp = null;
	boolean bolShowALL = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","ac_setting.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
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
ReadPropertyFile rpf = new ReadPropertyFile();

if(WI.fillTextValue("update_info").compareTo("1") == 0){
	if (rpf.setSysProperty(dbOP, request,WI.fillTextValue("info_index")))
		strErrMsg = " Information updated successfully";
	else {
		strErrMsg = rpf.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = " Infomation not updated. Please refresh and try again";
	}
}

vRetResult = rpf.getAllSysProperty(dbOP);
int iIndex = -1;

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" action="ac_setting.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: ACCOUNTING PARAMETER  ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr bgcolor="#F2E9D7"> 
      <td height="25" class="thinborderBOTTOM"><strong>&nbsp;Access Password</strong></td>
    </tr>
    <tr> 
      <td width="34%" height="25" style="font-size:11px"><strong>&nbsp;Password to Access</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;<input type="password" name="access_pwd" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="24"></td>
    </tr>
    <tr>
      <td height="14">&nbsp;</td>
    </tr>
  </table>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr bgcolor="#F2E9D7"> 
      <td height="25" colspan="3" class="thinborderALL"><strong>&nbsp;Accounting Setting</strong></td>
    </tr>
    
    <tr> 
      <td width="28%" height="25" class="thinborderLEFT">&nbsp;How System Locks Disbursement Voucher </td>
      <td width="12%" nowrap>
<% 
boolean bolIsManual = false;

if (vRetResult != null) 
		iIndex= vRetResult.indexOf("AC_CD_LOCK_SETTING");
   else 
		iIndex = -1;//System.out.println(vRetResult);

	 if (iIndex != -1) {
		 strTemp = (String)vRetResult.elementAt(iIndex+1);
		 vRetResult.removeElementAt(iIndex);
		 vRetResult.removeElementAt(iIndex);
	 }else 
		 strTemp = WI.fillTextValue("AC_CD_LOCK_SETTING");
%>
			<select name="AC_CD_LOCK_SETTING">
              <option value="1">Apply Lock Automatically</option>
<% 
if (strTemp.equals("2")) {
	strErrMsg = " selected";
	bolIsManual = true;
}
else	
	strErrMsg = "";
%>
              <option value="2" <%=strErrMsg%>>Apply Lock Manually</option>
            </select></td>
      <td width="60%" height="25" class="thinborderRIGHT">
			<font size="1"><a href='javascript:UpdateProp("AC_CD_LOCK_SETTING")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
    <tr> 
      <td width="28%" height="25" class="thinborderLEFT">&nbsp;Disbursement Voucher Lock Date </td>
      <td width="12%" nowrap>
<% if (vRetResult != null) 
		iIndex= vRetResult.indexOf("AC_CD_LOCK");
   else 
		iIndex = -1;//System.out.println(vRetResult);

	 if (iIndex != -1) {
		 strTemp = (String)vRetResult.elementAt(iIndex+1);
		 vRetResult.removeElementAt(iIndex);
		 vRetResult.removeElementAt(iIndex);
	 }else 
		 strTemp = WI.fillTextValue("AC_CD_LOCK");
%>
			<select name="AC_CD_LOCK">
<%if(!bolIsManual){%>
              <option value="1"<%=strErrMsg%>>System date when check created (Default)</option>
<% 
if (strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
              <option value="2" <%=strErrMsg%>>Lock date same as voucher date</option>
<%}else{%>
	<% 
	if (strTemp.equals("3"))
		strErrMsg = " selected";
	else	
		strErrMsg = "";
	%>
              <option value="3"<%=strErrMsg%>>Manually set lock date</option>
<%}%>
            </select></td>
      <td width="60%" height="25" class="thinborderRIGHT">
			<font size="1"><a href='javascript:UpdateProp("AC_CD_LOCK")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
  </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="update_info" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>