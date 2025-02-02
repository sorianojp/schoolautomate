<%@ page language="java" import="utility.*,java.util.Vector, eDTR.ApplicationFix" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Recompute EDTR Undertime</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function ViewRecords()
{
	document.form_.update_records.value="1";
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","fix_dtr_date.jsp");
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
														"fix_dtr_date.jsp");	
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
if(strErrMsg == null) strErrMsg = "";


ApplicationFix AppFix = new ApplicationFix();
String strDateFr = null;
String strDateTo = null;
int iResult = 0;

if (WI.fillTextValue("update_records").equals("1")) { 
	iResult = AppFix.updateDatesFromLong(dbOP,request);
	
	if (iResult == -1) 
		strErrMsg = AppFix.getErrMsg();
	else
		strErrMsg  = iResult + " rows updated " ;
}
	
%>

<form name="form_" action="./fix_dtr_date.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        DTR OPERATIONS - UPDATE DATE LOGS::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" ><strong><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="15%" height="25"> Employee ID </td>
      <td width="80%" height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"><label id="coa_info"></label></td>
    </tr>

    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Date</td>
      <td height="25">From
        <input name="date_from" type="text" size="10" maxlength="10" 
	  value="<%=WI.fillTextValue("date_from")%>" class="textbox" 
	  onKeyUp="AllowOnlyIntegerExtn('form_','date_from','/');"
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_from','/')">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;to 
        &nbsp;&nbsp;
        <input name="date_to" type="text" size="10" maxlength="10" 
		value="<%=WI.fillTextValue("date_to")%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" 
		onKeyUp = "AllowOnlyIntegerExtn('form_','date_to','/')"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_to','/')">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><br> <input name="proceed" type="image" onClick="ViewRecords();" src="../../../images/form_proceed.gif">      </td>
    </tr>
 </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#ffffff">
      <td height="25">Page Info: This is an application fix for dtr records having inconsistent values in the date and long values in the dtr table. This page will update the timein date and timeout date based on the long value in the table.</td>
    </tr>
    <tr bgcolor="#ffffff">
      <td height="25">&nbsp;</td>
    </tr>  
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25">&nbsp;</td>
    </tr>  
</table>

<input type="hidden" name="update_records" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>