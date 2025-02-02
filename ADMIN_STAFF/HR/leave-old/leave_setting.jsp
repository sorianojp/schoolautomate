<%@ page language="java" import="utility.*, java.util.Vector, hr.HRInfoLeave " buffer="16kb"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

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
<script language="javascript"  src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function UpdateProp(strInfoIndex){
	document.form_.update_info.value ="1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function ShowHideLabel(strLabel){
	if(strLabel == "")
		return;
 		
	for(var i = 1;i <= 2; i++){
		if(strLabel == i){		
			document.getElementById(strLabel).style.visibility = "visible";
		}else{
			document.getElementById(i).style.visibility = "hidden";
		}
	}
}

function TransmittalBanks(){
	var pgLoc = "./transmittal/transmittal_banklist.jsp";
	var win=window.open(pgLoc,"TransmittalBanks",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function SaveData(){
	document.form_.save_data.value = "1";
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
								"Admin/staff-Payroll-Configuration-Leave Setting","leave_setting.jsp");
		strTemp = (String)request.getSession(false).getAttribute("userId");
		if(strTemp != null && strTemp.equals("bricks"))
			bolShowALL = true;
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"leave_setting.jsp");
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
	response.sendRedirect("../../.././commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
ReadPropertyFile rpf = new ReadPropertyFile();
HRInfoLeave HRInfo = new HRInfoLeave();
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
String strLeaveCreditSched = null;

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

if(WI.fillTextValue("save_data").length() > 0){
	if(HRInfo.operateOnLeaveCreditSchedule(dbOP, request, 1) == null)
		strErrMsg = HRInfo.getErrMsg();
	else
		strErrMsg = "Operation Successful";
}

String strNextRundate = HRInfo.operateOnLeaveCreditSchedule(dbOP, request, 3);
 %>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" action="leave_setting.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      LEAVE SETTING PARAMETER  ::::</strong></font></td>
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
      <td height="25" colspan="3" class="thinborderALL"><strong>&nbsp;System Preference</strong></td>
    </tr>
    
    <tr>
      <td width="25%" height="18" class="thinborderLEFT">&nbsp;Allow update approved leaves </td>
      <td width="15%" nowrap><% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("EDIT_APPROVED_LEAVE");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("EDIT_APPROVED_LEAVE");
				%>
        <select name="EDIT_APPROVED_LEAVE">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select>
        <a href='javascript:ShowHideLabel("1")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td width="60%" height="18" class="thinborderRIGHT">
			<div id="1" style="position:absolute; visibility:hidden; width:auto;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Select Yes if the editing of approved leaves is allowed</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>			
			<font size="1"><a href='javascript:UpdateProp("EDIT_APPROVED_LEAVE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
		<tr>
      <td height="18" class="thinborderLEFT">&nbsp;Leave credit Schedule</td>
      <td height="18" colspan="2" nowrap>
			<% if (vRetResult != null)
						iIndex= vRetResult.indexOf("LEAVE_SCHEDULER");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strLeaveCreditSched = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strLeaveCreditSched = WI.fillTextValue("LEAVE_SCHEDULER");
 			%>
        <select name="LEAVE_SCHEDULER">
          <option value="2">Manual</option>
          <% if (strLeaveCreditSched.equals("0")){%>
          <option value="0" selected>Yearly</option>
          <%}else{%>
          <option value="0">Yearly</option>
          <%}%>
					<%if(strNextRundate == null || strNextRundate.length() == 0){%>
						<%if (strLeaveCreditSched.equals("1")){%>
						<option value="1" selected>Every Work Anniversary</option>
						<%}else{%>
						<option value="1">Every Work Anniversary</option>
						<%}%>					
					<%}%>
        </select>
			  <font size="1"><a href='javascript:UpdateProp("LEAVE_SCHEDULER")'><img src="../../../images/update.gif" width="60" height="26" border="0">
			  </a></font></td>
    </tr>
		<tr>		
		<%if(bolIsSchool && !strLeaveCreditSched.equals("1")){%>
		  <td height="18" class="thinborderLEFT">&nbsp;Year of Leave(Default)</td>
			<% if (vRetResult != null) 
					iIndex= vRetResult.indexOf("LEAVE_YEAR");
			 else 
					iIndex = -1;//System.out.println(vRetResult);
 
			 if (iIndex != -1) {
					strTemp = (String)vRetResult.elementAt(iIndex+1);
					vRetResult.removeElementAt(iIndex);
					vRetResult.removeElementAt(iIndex);
			 }else 
					strTemp = WI.fillTextValue("LEAVE_YEAR");
			%>
		  <td height="18" colspan="2" nowrap><select name="LEAVE_YEAR">
        <option value="0">School Year</option>
        <% if (strTemp.equals("1")){%>
        <option value="1" selected>Current Year</option>
        <%}else{%>
        <option value="1">Current Year</option>
        <%}%>
      </select>
	    <font size="1"><a href='javascript:UpdateProp("LEAVE_YEAR")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
		</tr>
		<%}%>
		<%if(strLeaveCreditSched.equals("0")){%>
		<tr>
		  <td height="32" class="thinborderLEFT">&nbsp;Date to Autocredit Leaves</td>
		  <td height="32" colspan="2" nowrap>
			<%if(strNextRundate == null){
				 int iTodaysYear = Integer.parseInt(WI.getTodaysDate(12)) + 1;
         strNextRundate = "01/01/"+ iTodaysYear;
			%>
				
			<input name="credit_date" type= "text"  class="textbox" value="<%=strNextRundate%>"
		   onFocus="style.backgroundColor='#D3EBFF'" 
		   onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','credit_date','/')" 
		   onKeyUp="AllowOnlyIntegerExtn('form_','credit_date','/')" size="10" maxlength="10">
        <a href="javascript:show_calendar('form_.credit_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				<a href='javascript:SaveData()'><img src="../../../images/save.gif" width="48" height="28" border="0"></a>
				<font size="1">One time setting only. Once saved, update will be disabled. </font>				
			<%}else{%>
				<strong><%=strNextRundate%></strong>
			<%}%>
			</td>
		</tr>
		<%}%>
	 <tr>
      <td width="25%" height="18" class="thinborderLEFT">Has Leave interval</td>
      <td width="15%" nowrap>
				<% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("HAS_LEAVE_INTERVAL");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("HAS_LEAVE_INTERVAL");
				%>
        <select name="HAS_LEAVE_INTERVAL">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select>
        <a href='javascript:ShowHideLabel("2")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td width="60%" height="18" class="thinborderRIGHT">
			<div id="2" style="position:absolute; visibility:hidden; width:auto;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Select Yes if there is an auto increment of leave credited to employees depending on the length of service</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>			
			<font size="1"><a href='javascript:UpdateProp("HAS_LEAVE_INTERVAL")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
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
<input type="hidden" name="save_data">
<input type="hidden" name="update_info" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>