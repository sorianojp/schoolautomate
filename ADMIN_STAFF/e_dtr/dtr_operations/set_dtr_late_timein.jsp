<%@ page language="java" import="utility.*, java.util.Vector, eDTR.AllowedLateTimeIN" %>
<%
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>DTR late setting</title>
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
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function SetFocus()
{
	document.dtr_op.allowed_late_timein.focus();
}
function AddRecord()
{
	document.dtr_op.addRecord.value = "1";
}

function UpdateNote(){
	var vSelected = document.dtr_op.late_setting.value;
	var vChecked = '0';
	
 	if(vSelected == '1'){		
		if(document.dtr_op.one_time_late)
			showLayer('one_time');
 		document.getElementById("note").innerHTML = 
				"<font size='1'><strong>Save all tardiness but do not deduct from payroll those within grace period</strong><br><br>"+
				"Ex. Schedule: 8:00 am - 12:00 pm. Grace period: 15 minutes for morning<br> " +
				"Time in:  8:05 am.<br>" +
				"Late on record = 5 minutes. No deduction from salary if late is 15 minutes or less.</font>";
		//document.dtr_op.note.value= "Save all tardiness but do not deduct from payroll those within grace period";
	} else if(vSelected == '2') {
		if(document.dtr_op.one_time_late){
			hideLayer('one_time');
			document.dtr_op.one_time_late.checked = false;
		}
 		document.getElementById("note").innerHTML = 
				"<font size='1'><strong>Don't save late within grace period and deduct grace period from late</strong><br><br>" +
				"Ex. Schedule: 8:00 am - 12:00 pm. Grace period: 15 minutes for morning<br> " +
				"if time in is 8:15 am or earlier.<br>" +
				"Late on record = 0 minutes.<br><br>" +
				"if Time in:  8:16 am or later .<br>" +
				"(actual minutes late - grace period)<br>" +
				"Late on record = 21(Actual) - 15(grace). Deduct 6 minutes from salary</font>";
		//document.dtr_op.note.value= "Don't save late within grace period and deduct grace period from late";
	} else if(vSelected == '3'){
		if(document.dtr_op.one_time_late){
			hideLayer('one_time');
			document.dtr_op.one_time_late.checked = false;
		}
 		document.getElementById("note").innerHTML =
				"<font size='1'><strong>Don't save late within grace period and don't deduct grace period from late</strong><br><br>"+
				"Ex. Schedule: 8:00 am - 12:00 pm. Grace period: 15 minutes for morning<br>" +
				"if time in is 8:15 am or earlier. " +
				"Late on record = 0 minutes.<br>" +
				"if time in is 8:16 am or later. " +
				"Late on record = actual minutes late</font>";
		//document.dtr_op.note.value= "Don't save late within grace period and don't deduct grace period from late";		
	} else if(vSelected == '4'){
		if(document.dtr_op.one_time_late){
			hideLayer('one_time');
			document.dtr_op.one_time_late.checked = false;			
		}
 		document.getElementById("note").innerHTML =
				"<font size='1'><strong>Don't save late within grace period and don't deduct grace period from late.<br>" +
				"Use only one grace period for the whole day.(Set only in morning schedule)</strong><br><br>"+
				"Ex. Schedule: 8:00 am - 12:00 pm. Grace period: 15 minutes<br>" +
				"No deduction from salary if total late for the day is 15 minutes or less.<br>"+
				"</font>";
		//document.dtr_op.note.value= "Don't save late within grace period and don't deduct grace period from late";		
	}  else if(vSelected == '5'){
		if(document.dtr_op.one_time_late){
			hideLayer('one_time');
			document.dtr_op.one_time_late.checked = false;			
		}
		
 		document.getElementById("note").innerHTML =
				"<font size='1'><strong>Grace period is for the whole cut off (set only in 1st set)</strong>"+				
				"<br>All late incurred will be recorded as is. " +
				"<br>Ex. Grace setting for cut off is 10 minutes. " +
				"<br>No deduction from salary if total late is 10 min or less. Actual total will be deducted if total exceeds the setting"+
				"<br> Total : 10 minutes or less. No deduction." +
				"<br> Total : 11 minutes or more. Deduct actual number of minutes late.";
		//document.dtr_op.note.value= "Don't save late within grace period and don't deduct grace period from late";		
	}

 	if(!document.dtr_op.one_time_late)
		vChecked = '0';
	else{
		if(document.dtr_op.one_time_late.checked)
			vChecked = "1";
	}

	if(vChecked == '1'){
		document.getElementById("note").innerHTML +=
			"<font size='1'><br><br>Grace period is allowed only once per day. If late in the morning, no grace period in the afternoon.</font>";
	}
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

function UpdateProp(strInfoIndex){
	document.dtr_op.update_info.value ="1";
	document.dtr_op.info_index.value = strInfoIndex;
	this.SubmitOnce("dtr_op");
}

function UpdateTime(strInfoIndex){
	var vHour = document.dtr_op.restrict_hr.value;
	var vMin =  document.dtr_op.restrict_min.value;
	var vAmPm = document.dtr_op.am_pm.value;
	var vTime = 12;	
			//if(iHour >= 12){
							//	if(iHour > 12)							
							//		iHour = iHour - 12;
							//	strTemp2 = iHour + " PM";
							//}
	
	vTime = eval(vHour) + eval(vMin/60);
	if(vAmPm == 1){
		if(vHour < 12)
			vTime += 12;
	}else{
		if(vHour == 12)
			vTime -= 12;
	}

 	document.dtr_op.RESTRICTED_TIME.value = vTime;
}
</script>
<body bgcolor="#D2AE72" onLoad="SetFocus();UpdateNote();" class="bgDynamic">
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;	
	String strTemp2 = null;
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	boolean bolShowAll = false;
	
	String strTime = null;
//add security here.
	try
	{
		dbOP = new DBOperation(strUserID,
								"Admin/staff-eDaily Time Record-Dtr Operations-Set DTR Setting","set_dtr_late_timein.jsp");
		if(strUserID != null && (strUserID.equals("GTI-01")  || strUserID.equals("bricks") || strUserID.equals("SA-01")))
			bolShowAll = true;
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
														"set_dtr_late_timein.jsp");	
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

AllowedLateTimeIN allowedLateTIN = new AllowedLateTimeIN();
Vector vRetResult = null;
 
strTemp = WI.fillTextValue("addRecord");
if(strTemp.compareTo("1") ==0)
{
	if(allowedLateTIN.operateOnLateSetting(dbOP, request, 1) != null)
		strErrMsg = "Time in information recorded successfully.";
	else
		strErrMsg = allowedLateTIN.getErrMsg();
}
	vRetResult = allowedLateTIN.operateOnLateSetting(dbOP, request, 3);
	String strSchCode = dbOP.getSchoolIndex();
ReadPropertyFile rpf = new ReadPropertyFile();
Vector vProp = null;

int iHour = 0;
int iMinute = 0;
double dTime = 0d;
String strAMPM = null;

if(WI.fillTextValue("update_info").compareTo("1") == 0){
	if (rpf.setSysProperty(dbOP, request,WI.fillTextValue("info_index")))
		strErrMsg = " Information updated successfully";
	else {
		strErrMsg = rpf.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = " Infomation not updated. Please refresh and try again";
	}
}

vProp = rpf.getAllSysProperty(dbOP);
int iIndex = -1;

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

%>	
<form action="./set_dtr_late_timein.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      DTR OPERATIONS - SETTINGS ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="30">&nbsp;</td>
			<%
				strTemp = "";
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(3);
					
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
			%>
      <td height="30">
			<%if(!bolIsSchool){%>
					<label id="one_time">
 					<input type="checkbox" name="one_time_late" value="1" <%=strTemp%> onClick="UpdateNote();">
					tick if grace period is only allowed once					</label>
			<%}%>			</td>
      <td height="30">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>Current allowed late TIME IN (in mins) 1st set</strong></u></td>
      <td height="30"><u><strong>Allowed late TIME IN (in mins) 1st set </strong></u></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
			<% 
				strTemp = "";
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(1);
			%>
      <td width="48%" height="25"><strong><%=WI.getStrValue(strTemp,"0")%></strong></td>
      <td width="50%" height="25"><input name="allowed_late_timein" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><u><strong>Current allowed late TIME IN (in mins) 2nd set </strong></u></td>
      <td><u><strong>Allowed late TIME IN (in mins) 2nd set</strong></u></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(2);
			%>
      <td width="48%" height="25"><strong><%=WI.getStrValue(strTemp,"0")%></strong></td>
      <td width="50%" height="25"><input name="allowed_late_timein_pm" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
				<td height="25"><u><strong>Current Setting for saving late time in</strong></u></td>
			  <%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(0);
			%>
      <td height="25">
			<select name="late_setting" onChange="UpdateNote();">
        <option value="1">Setting 1</option>
        <%if(strTemp.compareTo("2") == 0) {%>
        <option value="2" selected>Setting 2</option>
        <%}else{%>
        <option value="2">Setting 2</option>
        <%}if(strTemp.compareTo("3") == 0) {%>
        <option value="3" selected>Setting 3</option>
        <%}else{%>
        <option value="3">Setting 3</option>
        <%}if(strTemp.compareTo("4") == 0) {%>
        <option value="4" selected>Setting 4</option>
        <%}else{%>
        <option value="4">Setting 4</option>				
        <%}if(strTemp.compareTo("5") == 0) {%>
        <option value="5" selected>Setting 5</option>
        <%}else{%>
        <option value="5">Setting 5</option>				
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(0);
			%>			
      <td height="25" colspan="2"><strong><%=WI.getStrValue(strTemp,"Setting ","", "")%></strong></td>
    </tr>
    
    <tr>
      <td height="32">&nbsp;</td>
      <td height="32" colspan="2"><font color="#FF0000"><label id="note"></label></font></td>
    </tr>
		<!--
		//hidden may 31, 2008
		//dunno where this is being used
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Current Lunch Break Deduction (in mins) </strong></td>
      <td height="25"><strong>Lunch Break Deduction (in mins)</strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><strong><%=WI.getStrValue(dbOP.mapOneToOther("EDTR_ALLOWED_LATE_TIN",
                                                   "IS_DEL","0","LUNCH_BREAK",
                                                   null))%> </strong></td>
      <td height="25"><input name="lunch_break" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("lunch_break")%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
		-->
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    
    <tr > 
      <td height="25" align="center">
			<%if(iAccessLevel > 1){%>
			<input type="image" src="../../../images/save.gif" border="0" onClick="AddRecord();">
			<font size="1">click to save changes</font>
			<%}%></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
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
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr bgcolor="#F2E9D7"> 
      <td height="25" colspan="3" class="thinborderALL"><strong>&nbsp;System Preference</strong></td>
    </tr>
    
    <tr> 
      <td width="23%" height="25" class="thinborderLEFT">Max time difference </td>
      <td width="11%">
			<% if (vProp != null) 
					iIndex= vProp.indexOf("MAX_DIFFERENCE");
			   else 
				 	iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
					 strTemp = (String)vProp.elementAt(iIndex+1);
					 vProp.removeElementAt(iIndex);
					 vProp.removeElementAt(iIndex);
				 }else 
				 	 strTemp = WI.fillTextValue("MAX_DIFFERENCE");
			%>
        <input name="MAX_DIFFERENCE" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href='javascript:ShowHideLabel("1")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td width="66%" height="25" class="thinborderRIGHT"> 
			<div id="1" style="position:absolute; visibility:hidden; width:auto;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Number of hours difference from the last time before the system considers the next time log as a new login. Applicable only to pair of dtr entries with different dates for time in/out.</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>
			<font size="1"><a href='javascript:UpdateProp("MAX_DIFFERENCE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">Ad Hoc Allowance hour </td>
      <td><% if (vProp != null) 
					iIndex= vProp.indexOf("ADHOC_DIFF");
			   else 
				 	iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
					 strTemp = (String)vProp.elementAt(iIndex+1);
					 vProp.removeElementAt(iIndex);
					 vProp.removeElementAt(iIndex);
				 }else 
				 	 strTemp = WI.fillTextValue("ADHOC_DIFF");
			%>
        <input name="ADHOC_DIFF" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href='javascript:ShowHideLabel("2")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a></td>
      <td height="25" class="thinborderRIGHT">
			<div id="2" style="position:absolute; visibility:hidden; width:auto;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><strong>Number of hours allowance for employees with early login during ad hoc date so that dtr would be recognized</strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>			
			<font size="1"><a href='javascript:UpdateProp("ADHOC_DIFF")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">Has Overtime Break </td>
      <td><% if (vProp != null) 
						iIndex= vProp.indexOf("HAS_OT_BREAK");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vProp.elementAt(iIndex+1);
						vProp.removeElementAt(iIndex);
						vProp.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("HAS_OT_BREAK");
				%>
        <select name="HAS_OT_BREAK">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select></td>
      <td height="25" class="thinborderRIGHT"><font size="1"><a href='javascript:UpdateProp("HAS_OT_BREAK")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></td>
    </tr>
    <%if(strSchCode.startsWith("PIT") || bolShowAll){%>
		<tr>
      <td height="25" class="thinborderLEFT">Login time restriction</td>
      <td height="25" colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
			<%				
				if (vProp != null) 
					iIndex= vProp.indexOf("RESTRICTED_TIME");
				else 
					iIndex = -1;//System.out.println(vRetResult);
					
 				 if (iIndex != -1) {
				 		strTemp = (String)vProp.elementAt(iIndex+1);
						vProp.removeElementAt(iIndex);
						vProp.removeElementAt(iIndex);						
				 }
 					strTime = WI.getStrValue(strTemp,"12.5");
					
					strTemp2 = CommonUtil.convert24HRTo12Hr(Double.parseDouble(strTime));
				%>				
          <td width="20%" nowrap><strong><%=WI.getStrValue(strTemp2)%><input name="RESTRICTED_TIME" type="hidden" value="<%=strTime%>">
            <font size="1"><a href='javascript:UpdateProp("RESTRICTED_TIME")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></font></strong></td>
					<%
									
					%>
          <td width="80%">					
					<select name="restrict_hr" style="font-size:10px;" onChange="UpdateTime();">
          <%
					if(request.getParameter("restrict_hr") == null){
						dTime = Double.parseDouble(strTime);
						if(dTime >= 12){
							strAMPM = "1";
							if(dTime > 12)
								dTime = dTime - 12;
						} else {
							strAMPM = "0";
						}
						
						iHour = (int)dTime;
						dTime = ((dTime - iHour) * 60) + .02;
						iMinute = (int)dTime;
						if(iHour == 0)
							iHour = 12;								
						strTemp = Integer.toString(iHour);
					}else{
						strTemp = WI.fillTextValue("restrict_hr");
					}
						
						
					if(strTemp.length() == 0)
						strTemp = "12";
						
						for(int i = 1; i <= 12; i++){
							//iHour = i;
							//strTemp2 = iHour + " AM";
							//if(iHour >= 12){
							//	if(iHour > 12)							
							//		iHour = iHour - 12;
							//	strTemp2 = iHour + " PM";
							//}
									
							if(strTemp.equals(Integer.toString(i)))
								strErrMsg = " selected";
							else	
								strErrMsg = "";	
						%>
            <option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
						<%}%>
           </select>
            <select name="restrict_min" style="font-size:10px;" onChange="UpdateTime();">
							  <%
						if(request.getParameter("restrict_min") == null)
							strTemp = Integer.toString(iMinute);
						else
							strTemp = WI.fillTextValue("restrict_min");
						for(int i = 0; i < 60; i+=5){
							if(strTemp.equals(Integer.toString(i)))
								strErrMsg = " selected";
							else	
								strErrMsg = "";	
						%>
            <option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
						<%}%>
            </select>
            <select name="am_pm" onChange="UpdateTime();">
						<%
						if(request.getParameter("am_pm") == null)
							strTemp = strAMPM;
						else
							strTemp = WI.fillTextValue("am_pm");						
						%>
              <option value="0">AM</option>
              <% if (strTemp.equals("1")){%>
              <option value="1" selected>PM</option>
              <%}else{%>
              <option value="1">PM</option>
              <%}%>
            </select></td>
        </tr>				
      </table></td>
    </tr>
		<%}%>
		<tr>
		  <td height="25" class="thinborderLEFT">Forfeit Overtime <br>
	    if Late/Undertime</td>
		  <td height="25"><% if (vProp != null) 
						iIndex= vProp.indexOf("FORFEIT_OT");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vProp.elementAt(iIndex+1);
						vProp.removeElementAt(iIndex);
						vProp.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("FORFEIT_OT");
				%>
        <select name="FORFEIT_OT">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select></td>
	    <td height="25"><font size="1"><a href='javascript:UpdateProp("FORFEIT_OT")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>(Forfeit overtime rendered if employee has late or undertime for the day)</font></td>
    </tr>
		<tr>
		  <td height="25" class="thinborderLEFT">Multiple Holiday Rate</td>
		  <td height="25"><% if (vProp != null) 
						iIndex= vProp.indexOf("MULTIPLE_HOLIDAY_RATE");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vProp.elementAt(iIndex+1);
						vProp.removeElementAt(iIndex);
						vProp.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("MULTIPLE_HOLIDAY_RATE");
				%>
        <select name="MULTIPLE_HOLIDAY_RATE">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select></td>
		  <td height="25"><font size="1"><a href='javascript:UpdateProp("MULTIPLE_HOLIDAY_RATE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>(System will be using multiple holiday rates)</font></td>
	  </tr>
		<%if(bolIsSchool){%>
		<tr>
		  <td height="25" class="thinborderLEFT">Faculty Scheduling</td>
		  <td height="25"><% if (vProp != null) 
						iIndex= vProp.indexOf("IS_FACULTY_APPLICABLE");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vProp.elementAt(iIndex+1);
						vProp.removeElementAt(iIndex);
						vProp.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("IS_FACULTY_APPLICABLE");
				%>
        <select name="IS_FACULTY_APPLICABLE">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select></td>
		  <td height="25"><font size="1"><a href='javascript:UpdateProp("IS_FACULTY_APPLICABLE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>(Enable separate dtr terminal for faculties)</font></td>
	  </tr>		
		<%}%>
 		<tr>
		  <td height="25" class="thinborderLEFT">Bundy Clock Style</td>
		  <td height="25">
			<% if (vProp != null) 
						iIndex= vProp.indexOf("HAS_BUNDY_STYLE");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vProp.elementAt(iIndex+1);
						vProp.removeElementAt(iIndex);
						vProp.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("HAS_BUNDY_STYLE");
				%>
        <select name="HAS_BUNDY_STYLE">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select></td>
		  <td height="25"><font size="1"><a href='javascript:UpdateProp("HAS_BUNDY_STYLE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>(Enable bundy clock style timekeeping)</font></td>
	  </tr>
 		<tr>
		  <td height="25" class="thinborderLEFT">Deduct Late/UT on Holidays </td>
		  <td height="25">
			<% if (vProp != null) 
						iIndex= vProp.indexOf("DEDUCT_HOLIDAY_LATE_UT");
			   else 
				 		iIndex = -1;//System.out.println(vRetResult);
   
				 if (iIndex != -1) {
				 		strTemp = (String)vProp.elementAt(iIndex+1);
						vProp.removeElementAt(iIndex);
						vProp.removeElementAt(iIndex);
				 }else 
				 		strTemp = WI.fillTextValue("DEDUCT_HOLIDAY_LATE_UT");
				%>
        <select name="DEDUCT_HOLIDAY_LATE_UT">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select></td>
		  <td height="25"><font size="1"><a href='javascript:UpdateProp("DEDUCT_HOLIDAY_LATE_UT")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>(Deduct late and undertime during holidays)</font></td>
	  </tr>	
   </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">		
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="addRecord">
	<input type="hidden" name="info_index">
	<input type="hidden" name="update_info" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>