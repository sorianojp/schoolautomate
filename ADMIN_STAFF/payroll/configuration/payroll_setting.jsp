<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

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

function ShowHideLabel(strLabel){
	if(strLabel == "" || strLabel == null)
		return;
		
	if(!document.getElementById("iframetop"))
		return;
	
 	var iframe = document.getElementById("iframetop");
 
 	for(var i = 1;i <= 15; i++){
		if(strLabel == i){
			if(!document.getElementById(strLabel))
				continue;
			
			var layer = document.getElementById(strLabel);
			layer.style.display = 'block';
			layer.style.visibility = "visible";
			
			iframe.style.visibility = 'visible';				
			iframe.style.display = 'block';
			iframe.style.width = layer.offsetWidth-5;
			iframe.style.height = layer.offsetHeight-5;
			iframe.style.left = layer.offsetLeft;
			iframe.style.top = layer.offsetTop;					
		}else{
			if(!document.getElementById(i))
				continue;
			document.getElementById(i).style.visibility = "hidden";
		}
	}

	if(strLabel == 0){
		iframe.style.display = 'none';
		iframe.style.visibility = 'hidden';
	}
	
}

function TransmittalBanks(){
	var pgLoc = "./transmittal/transmittal_banklist.jsp";
	var win=window.open(pgLoc,"TransmittalBanks",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function ReloadPage(){
	this.SubmitOnce("form_");
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strErrMsg = null;
	String strTemp = null;
	boolean bolShowAdmin = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Payroll Parameter","payroll_setting.jsp");
		strTemp = (String)request.getSession(false).getAttribute("userId");
		if(strTemp != null){
 			if(strTemp.toUpperCase().equals("BRICKS") ||  (strTemp.toUpperCase().indexOf("GTI") != -1) || 
				 (strTemp.toUpperCase().indexOf("SA-01") != -1))
				bolShowAdmin = true;
		}
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
														"payroll_setting.jsp");
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
String[] astrLeaveOption = {"Save only Basic Salary Information",
													  "Process only Government Mandated contributions and loans",
														"Process as regular payroll"};

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
<form name="form_" action="payroll_setting.jsp" method="post" >

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL PARAMETER  ::::</strong></font></td>
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
      <td width="25%" height="25" class="thinborderLEFT">&nbsp;Allow weekly salary period </td>
      <td width="16%" nowrap>
			<% if (vRetResult != null) 
					iIndex= vRetResult.indexOf("PAYROLL_WEEKLY");
			   else 
				 	iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
					 strTemp = (String)vRetResult.elementAt(iIndex+1);
					 vRetResult.removeElementAt(iIndex);
					 vRetResult.removeElementAt(iIndex);
				 }else 
				 	 strTemp = WI.fillTextValue("PAYROLL_WEEKLY");
			%>
        <select name="PAYROLL_WEEKLY">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select>
        <a href='javascript:ShowHideLabel("1")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td width="59%" height="25" class="thinborderRIGHT">
			<iframe width="0" scrolling="no" height="0" 
    	frameborder="0" id="iframetop" style="position:absolute;" > </iframe>
        <div id="1" style="position:absolute; visibility:hidden; width:auto;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Select Yes if the system will allow the use of weekly salary period for the creation of payroll</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>
			<font size="1"><a href='javascript:UpdateProp("PAYROLL_WEEKLY")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Use confidential settings </td>
      <td nowrap> 
			<% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("HAS_CONFIDENTIAL");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("HAS_CONFIDENTIAL");
				%> 
				<select name="HAS_CONFIDENTIAL">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
      </select>
			<a href='javascript:ShowHideLabel("2")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td height="25" class="thinborderRIGHT"> 
			<div id="2" style="position:absolute; visibility:hidden; width:auto;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Select Yes company is allowed to have confidential setting in payroll</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>
			<font size="1"><a href='javascript:UpdateProp("HAS_CONFIDENTIAL")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT"> &nbsp;Enable Teams in reports </td>
      <td nowrap><% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("HAS_TEAMS");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("HAS_TEAMS");
				%>
        <select name="HAS_TEAMS">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
      </select>
      <a href='javascript:ShowHideLabel("3")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td height="25" class="thinborderRIGHT">
			<div id="3" style="position:absolute; visibility:hidden; width:auto;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Select Yes if the system will allow grouping of employees by team</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>
			<font size="1"><a href='javascript:UpdateProp("HAS_TEAMS")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
    
    <tr> 
      <td height="18" class="thinborderLEFT">&nbsp;Single payroll multiple release </td>
      <td nowrap><% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("HAS_AUF_STYLE");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("HAS_AUF_STYLE");
				%>
        <select name="HAS_AUF_STYLE">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
      </select>
      <a href='javascript:ShowHideLabel("4")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td height="18" class="thinborderRIGHT">
			<div id="4" style="position:absolute; visibility:hidden; width:auto;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Select Yes if the system will allow having employees with payroll 
													that is generated once a month only but releasing of payslip is done at least once</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>
			<font size="1"><a href='javascript:UpdateProp("HAS_AUF_STYLE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="18" class="thinborderLEFT">&nbsp;Allow Unfinalize payslip</td>
      <td nowrap><% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("ALLOW_UNFINALIZE");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("ALLOW_UNFINALIZE");
				%>
        <select name="ALLOW_UNFINALIZE">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
      </select>
      <a href='javascript:ShowHideLabel("5")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td height="18" class="thinborderRIGHT">
			<div id="5" style="position:absolute; visibility:hidden; width:auto;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Select Yes if the system will allow resetting of the finalized status of payslip so it can be edited again</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>
			<font size="1"><a href='javascript:UpdateProp("ALLOW_UNFINALIZE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="18" class="thinborderLEFT">&nbsp;Allow update approved leaves </td>
      <td nowrap><% if (vRetResult != null) 
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
        <a href='javascript:ShowHideLabel("6")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td height="18" class="thinborderRIGHT">
			<div id="6" style="position:absolute; visibility:hidden; width:auto;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
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
      <td height="18" colspan="2" nowrap class="thinborderRIGHT">
			<% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("LEAVE_SCHEDULER");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("LEAVE_SCHEDULER");
				%>
        <select name="LEAVE_SCHEDULER">
          <option value="2">Manual</option>
          <% if (strTemp.equals("0")){%>
          <option value="0" selected>Yearly</option>
          <%}else{%>
          <option value="0">Yearly</option>
          <%}%>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Every Work Anniversary</option>
          <%}else{%>
          <option value="1">Every Work Anniversary</option>
          <%}%>					
					<%if(bolIsSchool){%>
						<%if (strTemp.equals("3")){%>
						<option value="3" selected>Specific Date</option>
						<%}else{%>
						<option value="3">Specific Date</option>
						<%}%>
					<%}%>					
        </select>
			  <font size="1"><a href='javascript:UpdateProp("LEAVE_SCHEDULER")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
      </tr>
		<tr>
		  <td height="18" class="thinborderLEFT">&nbsp;Whole Salary period on Leave </td>
		  <td height="18" colspan="2" nowrap class="thinborderRIGHT">
			<div id="8" style="position:absolute; visibility:hidden;width:auto;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%" height="28"><strong><br>
					  <br><br>
					</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				<tr>
				  <td><strong>1. Save only Basic Salary Information</strong></td>
				  <td align="center">&nbsp;</td>
				  </tr>
				<tr>
				  <td><strong>2. Process only Government Mandated contributions and loans
				  </strong></td>
				  <td align="center">&nbsp;</td>
				  </tr>
				<tr>
				  <td><strong>3. Process as regular payroll</strong></td>
				  <td align="center">&nbsp;</td>
				  </tr>
				<tr>
				  <td>&nbsp;</td>
				  <td align="center">&nbsp;</td>
				  </tr>					
				</table>
			</div>
			<% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("ON_LEAVE_OPTION");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("ON_LEAVE_OPTION");
				%>
        <select name="ON_LEAVE_OPTION">
          <option value="0">Save only Basic Salary Information</option>
					<%for(int i = 1; i < astrLeaveOption.length;i++){
						if(strTemp.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected><%=astrLeaveOption[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrLeaveOption[i]%></option>
          <%}
					}%>
        </select>
        <a href='javascript:ShowHideLabel("8")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a><font size="1"><a href='javascript:UpdateProp("ON_LEAVE_OPTION")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
		  </tr>
		<tr>
      <td height="18" class="thinborderLEFT">&nbsp;Send payslip to email</td>
      <td nowrap>
			<% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("MAIL_PAYSLIP");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("MAIL_PAYSLIP");
				%>
        <select name="MAIL_PAYSLIP">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select>
        <a href='javascript:ShowHideLabel("7")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td height="18" class="thinborderRIGHT">
			<div id="7" style="position:absolute; visibility:hidden; width:auto;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Select Yes if the system will attempt to send to employee email the payslip for the period</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>			
			<font size="1"><a href='javascript:UpdateProp("MAIL_PAYSLIP")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
		<tr>
      <td height="18" class="thinborderLEFT">&nbsp;Allow internal operations</td>
      <td nowrap>
			<% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("HAS_INTERNAL");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("HAS_INTERNAL");
				%>
        <select name="HAS_INTERNAL">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select></td>
      <td height="18" class="thinborderRIGHT">&nbsp;</td>
    </tr>
		<tr>
      <td height="18" class="thinborderLEFT">&nbsp;Allow Allowance Override</td>
      <td nowrap>
			<% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("ALLOWANCE_OVERRIDE");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("ALLOWANCE_OVERRIDE");
				%>
        <select name="ALLOWANCE_OVERRIDE">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select>
        <a href='javascript:ShowHideLabel("9")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td height="18" class="thinborderRIGHT">
			<div id="9" style="position:absolute; visibility:hidden; width:auto;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Select Yes if the system will allow the users to set/update the variable allowance amount for each employee</strong><br><br></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>			
			<font size="1"><a href='javascript:UpdateProp("ALLOWANCE_OVERRIDE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
<tr>
      <td height="18" class="thinborderLEFT">&nbsp;First Period Contribution setting</td>
      <td height="18" colspan="2" nowrap class="thinborderRIGHT">
			<div id="10" style="position:absolute; visibility:hidden; width:auto;">
			  <table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
			    <tr>
			      <td width="90%"><strong>NOTE: <br>
			        <font color="#FF0000" size="1">Use Monthly Rate</font>
							<br>
		            </strong><font size="1">(ex. SSS contribution basis set is Gross. This setting will be ignored if the schedule of deduction of SSS contribution is set on the first salary period of the month. 
								The basis will be the monthly rate of the employee. In case there is no monthly rate set for the employee, the system will use the computed basic salary)</font><strong><font size="1"><br>
			          </font><font color="#FF0000" size="1">Use Previous Month amount</font></strong><br>
								<font size="1">The system will get the information from the previous month in getting the contribution basis total</font><br><br>						</td>
					  <td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				  </tr>
			    </table>
		  </div>			
			<% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("CONT_TREATMENT");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("CONT_TREATMENT");
				%>
			<font size="1">
			<select name="CONT_TREATMENT">
        <option value="0">Use Monthly Rate</option>
        <%if(strTemp.equals("1")) {%>
        <option value="1" selected>Use Previous Month amount</option>
        <%}else{%>
        <option value="1">Use Previous Month amount</option>
        <%}%>
      </select>
			</font><a href='javascript:ShowHideLabel("10")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a>
			<font size="1"><a href='javascript:UpdateProp("CONT_TREATMENT")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
      </tr>
<tr>
  <td height="18" class="thinborderLEFT"> &nbsp;Exclude Overtime</td>
  <td height="18" nowrap><% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("EXCLUDE_OVERTIME");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("EXCLUDE_OVERTIME");
				%>
    <select name="EXCLUDE_OVERTIME">
      <option value="0">No</option>
      <% if (strTemp.equals("1")){%>
      <option value="1" selected>Yes</option>
      <%}else{%>
      <option value="1">Yes</option>
      <%}%>
    </select>
    <a href='javascript:ShowHideLabel("11")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
  <td height="18" nowrap class="thinborderRIGHT">
	<div id="11" style="position:absolute; visibility:hidden; width:auto;">
				<table width="90%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Select Yes if the system will exclude overtime during payroll computation</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>		
	<font size="1"><a href='javascript:UpdateProp("EXCLUDE_OVERTIME")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
</tr>
<%if(bolIsSchool){%>
<tr>
  <td height="18" class="thinborderLEFT">&nbsp;Show PERAA/ Retirement plan </td>
  <td height="18" nowrap><% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("HAS_PERAA");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("HAS_PERAA");
				%>
    <select name="HAS_PERAA">
      <option value="0">No</option>
      <% if (strTemp.equals("1")){%>
      <option value="1" selected>Yes</option>
      <%}else{%>
      <option value="1">Yes</option>
      <%}%>
    </select>
    <a href='javascript:ShowHideLabel("12")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
  <td height="18" nowrap class="thinborderRIGHT"><font size="1">
		<div id="12" style="position:absolute; visibility:hidden; width:auto;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Select Yes if the PERAA/Retirement Plan will be shown</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
		</div>
	<a href='javascript:UpdateProp("HAS_PERAA")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
</tr>
<%}%>
<tr>
  <td height="18" class="thinborderLEFT">&nbsp;Show batch leave conversion </td>
  <td height="18" nowrap><% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("SHOW_BATCH_LEAVE");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("SHOW_BATCH_LEAVE");
				%>
    <select name="SHOW_BATCH_LEAVE">
      <option value="0">No</option>
      <% if (strTemp.equals("1")){%>
      <option value="1" selected>Yes</option>
      <%}else{%>
      <option value="1">Yes</option>
      <%}%>
    </select></td>
  <td height="18" nowrap class="thinborderRIGHT"><font size="1"><a href='javascript:UpdateProp("SHOW_BATCH_LEAVE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
</tr>
<tr>
  <td height="18" class="thinborderLEFT"> &nbsp;Allow bonus forwarding to Salary </td>
  <td height="18" nowrap>
		<% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("FORWARD_BONUS");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("FORWARD_BONUS");
				%>
    <select name="FORWARD_BONUS">
      <option value="0">No</option>
      <% if (strTemp.equals("1")){%>
      <option value="1" selected>Yes</option>
      <%}else{%>
      <option value="1">Yes</option>
      <%}%>
    </select></td>
  <td height="18" nowrap class="thinborderRIGHT"><font size="1"><a href='javascript:UpdateProp("FORWARD_BONUS")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
</tr>
<tr>
  <td height="18" class="thinborderLEFT">&nbsp;Enable allowances date range </td>
  <td height="18" nowrap><% if (vRetResult != null)
						iIndex= vRetResult.indexOf("CHECK_ALLOWANCES_DATE");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("CHECK_ALLOWANCES_DATE");
				%>
    <select name="CHECK_ALLOWANCES_DATE">
      <option value="0">No</option>
      <% if (strTemp.equals("1")){%>
      <option value="1" selected>Yes</option>
      <%}else{%>
      <option value="1">Yes</option>
      <%}%>
    </select></td>
  <td height="18" nowrap class="thinborderRIGHT"><font size="1"><a href='javascript:UpdateProp("CHECK_ALLOWANCES_DATE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
</tr>
<tr>
  <td height="18" class="thinborderLEFT">&nbsp;Skipped Loans Payment </td>
  <td height="18" colspan="2" nowrap><% if (vRetResult != null)
						iIndex= vRetResult.indexOf("LOAN_SCHED_BALANCE");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("LOAN_SCHED_BALANCE");
				%>    <select name="LOAN_SCHED_BALANCE">
    <option value="0">Ignore(Follow Schedule)</option>
    <% if (strTemp.equals("1")){%>
    <option value="1" selected>Forward balance to next pay period</option>
    <%}else{%>
    <option value="1">Forward balance to next pay period</option>
    <%}%>
  </select>
    <font size="1"><a href='javascript:UpdateProp("LOAN_SCHED_BALANCE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
  </tr>
<tr>
  <td height="18" class="thinborderLEFT"> &nbsp;Hired on middle of Cut Off</td>
  <td height="18" colspan="2" nowrap>
<div id="13" style="position:absolute; visibility:hidden; width:auto; height: 101px;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td height="28" colspan="2"><strong>This setting will only affect monthly rated/ deduction based employees. (Monthly) <br>
					  <br>
					</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				<tr>
				  <td width="14%" height="22"><strong>Setting 1</strong></td>
				  <td width="76%">Compute salary as daily rated. (based on days worked) </td>
				  <td align="center">&nbsp;</td>
				  </tr>
				<tr>
				  <td height="31"><strong>Setting 2</strong></td>
				  <td>Compute as regular salary but deduct from basic the total days from start of cut off to date hired</td>
				  <td align="center">&nbsp;</td>
				  </tr>
				<tr>
				  <td height="22"><strong>Setting 3 </strong></td>
				  <td>Compute as regular salary. Deduct only the unworked days.<br>
							Don't count days from start of cut off to date hired as absent</td>
				  <td align="center">&nbsp;</td>
				  </tr>
				
				<tr>
				  <td colspan="2" height="8"></td>
				  <td align="center"></td>
				  </tr>					
				</table>
			</div>	
	<% if (vRetResult != null)
						iIndex= vRetResult.indexOf("HIRED_ON_CUT_OFF");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("HIRED_ON_CUT_OFF");
				%>    <select name="HIRED_ON_CUT_OFF">
    <option value="1">Setting 1</option>
    <% if (strTemp.equals("2")){%>
    <option value="2" selected>Setting 2</option>
		<option value="3">Setting 3</option>
    <%}else if (strTemp.equals("3")){%>
    <option value="2">Setting 2</option>
		<option value="3" selected>Setting 3</option>
    <%}else{%>
    <option value="2">Setting 2</option>
		<option value="3">Setting 3</option>		
		<%}%>
  </select>
    <a href='javascript:ShowHideLabel("13")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a>    <font size="1"><a href='javascript:UpdateProp("HIRED_ON_CUT_OFF")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
  </tr>
<tr>
  <td height="18" class="thinborderLEFT">&nbsp;Loan External payments</td>
  <td height="18" colspan="2" nowrap>
	<div id="14" style="position:absolute; visibility:hidden; width:auto; height: 50px;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
 				<tr>
				  <td width="14%" height="22"><strong>Setting 1</strong></td>
				  <td width="76%">Pay first the unpaid schedules from the beginning</td>
				  <td align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				  </tr>
				<tr>
				  <td height="31"><strong>Setting 2</strong></td>
				  <td>Pay first the schedules at the end</td>
				  <td align="center">&nbsp;</td>
				</tr>
				<tr>
				  <td colspan="2" height="8"></td>
				  <td align="center"></td>
				  </tr>					
				</table>
			</div>		
	<% if (vRetResult != null)
						iIndex= vRetResult.indexOf("EXT_LOAN_PAYMENT");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("EXT_LOAN_PAYMENT");
				%>
    <select name="EXT_LOAN_PAYMENT">
      <option value="1">Setting 1</option>
      <% if (strTemp.equals("2")){%>
      <option value="2" selected>Setting 2</option>
			<%}else{%>
      <option value="2">Setting 2</option>
      <%}%>
    </select>
    <a href='javascript:ShowHideLabel("14")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a> <font size="1"><a href='javascript:UpdateProp("EXT_LOAN_PAYMENT")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
</tr>
<%if(strSchoolCode.startsWith("DEPED")){%>
<tr>
  <td height="18" class="thinborderLEFT">&nbsp;Show loan terms in payroll sheet</td>
  <td height="18" colspan="2" nowrap>
	<div id="15" style="position:absolute; visibility:hidden; width:auto; height: 32px;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
 				<tr>
					<td height="31"><strong>Set to Yes if loan term will be shown in the payroll sheet</strong></td>
				  <td align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				  </tr>
				</table>
			</div>		
	<% if (vRetResult != null)
						iIndex= vRetResult.indexOf("SHOW_LOAN_TERM");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("SHOW_LOAN_TERM");
				%>
	<select name="SHOW_LOAN_TERM">
    <option value="0">No</option>
    <% if (strTemp.equals("1")){%>
    <option value="1" selected>Yes</option>
    <%}else{%>
    <option value="1">Yes</option>
    <%}%>
  </select>
	<a href='javascript:ShowHideLabel("15")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a> <font size="1"><a href='javascript:UpdateProp("SHOW_LOAN_TERM")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
</tr>
<%}%>

<tr>
  <td height="18" class="thinborderLEFT">&nbsp;Minimum taxable income for PAG-IBIG</td>
  <td height="18" colspan="2" nowrap>
	<div id="15" style="position:absolute; visibility:hidden; width:auto; height: 32px;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
 				<tr>
					<td height="31"><strong>Set to Yes if loan term will be shown in the payroll sheet</strong></td>
				  <td align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				  </tr>
				</table>
		</div>		
	<% if (vRetResult != null)
						iIndex= vRetResult.indexOf("PAG_IBIG_TAXABLE");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("PAG_IBIG_TAXABLE");
				%>	
			<font size="1">
				<input type="text" name="PAG_IBIG_TAXABLE" value="<%=strTemp%>" width="10"
				  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="10">
			</font>
			
			<!--<a href='javascript:ShowHideLabel("15")'>
				<img src="../../../images/online_help.gif" width="34" height="26" border="0"></a>  -->
				<font size="1">
					<a href='javascript:UpdateProp("PAG_IBIG_TAXABLE")'>
						<img src="../../../images/update.gif" width="60" height="26" border="0">					</a>				</font>		</td>
</tr>
<tr>
  <td height="18" class="thinborderLEFT">&nbsp;Allow Manual Adjustment in Payroll  </td>
  <td height="18" nowrap><% if (vRetResult != null)
						iIndex= vRetResult.indexOf("PR_ALLOW_MANUALPOSTING");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("PR_ALLOW_MANUALPOSTING");
				%>
    <select name="PR_ALLOW_MANUALPOSTING">
      <option value="0">No</option>
      <% if (strTemp.equals("1")){%>
      <option value="1" selected>Yes</option>
      <%}else{%>
      <option value="1">Yes</option>
      <%}%>
    </select></td>
  <td height="18" nowrap class="thinborderRIGHT"><font size="1"><a href='javascript:UpdateProp("PR_ALLOW_MANUALPOSTING")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
</tr>
<tr>
  <td height="18" class="thinborderLEFT">&nbsp;Misc Earning Name to Auto Post Leave Credit from Prev. Salary Period</td>
  <td height="18" colspan="2">
	<% 	
		if (vRetResult != null)
			iIndex= vRetResult.indexOf("AUTO_POST_LEAVE_CREDIT");
   		else 
			iIndex = -1;//System.out.println(vRetResult);

		 if (iIndex != -1) {
				strTemp = (String)vRetResult.elementAt(iIndex+1);
				vRetResult.removeElementAt(iIndex);
				vRetResult.removeElementAt(iIndex);
		 }
		 else 
				strTemp = WI.fillTextValue("AUTO_POST_LEAVE_CREDIT");
	%>	
	<input type="text" name="AUTO_POST_LEAVE_CREDIT" value="<%=strTemp%>" width="10"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="10" class="textbox">

	<a href='javascript:UpdateProp("AUTO_POST_LEAVE_CREDIT")'>
		<img src="../../../images/update.gif" width="60" height="26" border="0"></a>
  </td>
</tr>
<tr>
  <td height="18" class="thinborderLEFT">&nbsp;Projected Month for 13th Month</td>
  <td height="18" colspan="2">
<% if (vRetResult != null)
	iIndex= vRetResult.indexOf("ADDL_MNTH_PROJECTION_MONTH");
else 
	iIndex = -1;//System.out.println(vRetResult);
 if (iIndex != -1) {
	strTemp = (String)vRetResult.elementAt(iIndex+1);
	vRetResult.removeElementAt(iIndex);
	vRetResult.removeElementAt(iIndex);
 }
 else 
	strTemp = WI.fillTextValue("ADDL_MNTH_PROJECTION_MONTH");
%>	
		<input type="text" name="ADDL_MNTH_PROJECTION_MONTH" value="<%=strTemp%>" size="12" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="20">
		<font size="1">
			<a href='javascript:UpdateProp("ADDL_MNTH_PROJECTION_MONTH")'>
				<img src="../../../images/update.gif" width="60" height="26" border="0">			</a>	
			<br>Note: If more than one month, enter in comma separated value (10, 11, 12). 1 = Jan , 2 = Feb, 3 = Mar, 4 = Apr, 5 = May, 6 = Jun, 7 = Jul, 8 = Aug, 9 = Sept, 10 = Oct, 11= Nov, 12 = Dec			
			<br>
			To Disable this feature, enter -1 and click update.		</font>	</td>
</tr>

<!--
<tr>
  <td height="18" class="thinborderLEFT">&nbsp;</td>
  <td height="18" nowrap><% if (vRetResult != null) 
						iIndex= vRetResult.indexOf("USE_SALARY_PERIOD");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vRetResult.elementAt(iIndex+1);
						vRetResult.removeElementAt(iIndex);
						vRetResult.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("USE_SALARY_PERIOD");
				%>
    <select name="USE_SALARY_PERIOD">
    <option value="0">No</option>
    <% if (strTemp.equals("1")){%>
    <option value="1" selected>Yes</option>
    <%}else{%>
    <option value="1">Yes</option>
    <%}%>
  </select></td>
  <td height="18" nowrap class="thinborderRIGHT"><font size="1"><a href='javascript:UpdateProp("USE_SALARY_PERIOD")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
</tr>		
-->
  </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <%if(bolShowAdmin && false){%>
		<tr> 
      <td height="25"><font size="1"><a href='javascript:TransmittalBanks()'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>Banks for transmittal (Open only for GTI Staff. Don't give this access to the clients) </font></td>
    </tr>
		<tr> 
    <%
			strTemp = (String)request.getSession(false).getAttribute("school_code");
			if(strTemp == null || !strTemp.equals(WI.getStrValue(WI.fillTextValue("sch_code"),strTemp)) ) {
				strTemp = WI.fillTextValue("sch_code");
				request.getSession(false).setAttribute("school_code",strTemp);
			}
			strTemp = WI.getStrValue(strTemp);
		if(false){%>
      <td height="25"><font size="1">
        <input type="text" name="sch_code" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="24">
      school code</font><font size="1"><a href='javascript:ReloadPage()'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>		
	<%}
	}%>
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