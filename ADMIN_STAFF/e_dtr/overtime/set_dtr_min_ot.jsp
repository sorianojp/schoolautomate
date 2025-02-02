<%@ page language="java" import="utility.*, java.util.Vector, eDTR.OverTime" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Overtime Settings</title>
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function SetFocus()
{
	document.dtr_op.hours_work.focus();
}
function AddRecord()
{
	document.dtr_op.addRecord.value = "1";
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

function ShowHideFrame(strShowHide){
	var iframe = document.getElementById('iframetop');
	var layer = document.getElementById("1");
	
	if(strShowHide == '1'){		
		layer.style.visibility = "visible";
		iframe.style.display = 'block';
		layer.style.display = 'block';	
		iframe.style.width = layer.offsetWidth-5;	
		iframe.style.left = layer.offsetLeft;
		iframe.style.top = layer.offsetTop;
		iframe.style.height = (layer.offsetHeight-5);				
	}else{
		layer.style.visibility = "hidden";
		iframe.style.display = 'none';
		layer.style.display = 'none';	
	}	
}
</script>
<body bgcolor="#D2AE72" onLoad="SetFocus();" class="bgDynamic">
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolHasOTBreak = false;
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-OVERTIME MANAGEMENT-Overtime Setting","set_dtr_min_ot.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasOTBreak = (readPropFile.getImageFileExtn("HAS_OT_BREAK","0")).equals("1");

	}	catch(Exception exp)	{
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
														"eDaily Time Record","OVERTIME MANAGEMENT",request.getRemoteAddr(), 
														"set_dtr_min_ot.jsp");	
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT-Set Overtime Setting",request.getRemoteAddr(), 
														"set_dtr_min_ot.jsp");	
}

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
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
OverTime minOT = new OverTime();
Vector vRetResult = null;
strTemp = WI.fillTextValue("addRecord");
if(strTemp.compareTo("1") ==0)
{
	if(minOT.operateOnMinOvertime(dbOP, request, 1) != null)
		strErrMsg = "Time in information recorded successfully.";
	else
		strErrMsg = minOT.getErrMsg();
}
	vRetResult = minOT.operateOnMinOvertime(dbOP, request, 3);
%>	
<form action="./set_dtr_min_ot.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      DTR OPERATIONS - OVERTIME SETTING ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30">&nbsp;</td>
      <td height="30">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>Current allowed minimum number of hours OT </strong></u></td>
      <td height="30"><u><strong>Minimum allowed OT number of hours per day </strong></u></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
			<%				
				if(vRetResult != null && vRetResult.size() > 0){
					strTemp = (String)vRetResult.elementAt(0) + " hours";
					
					strTemp += " and " + (String)vRetResult.elementAt(1) + " minutes";
				}
			%>
      <td width="48%" height="25"><strong><%=WI.getStrValue(strTemp,"0")%></strong></td>
			<%				
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(0);
			%>
      <td width="50%" height="25"><input name="hours_work" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyInteger('dtr_op','hours_work')" value="<%=strTemp%>" size="6" maxlength="6" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','hours_work')">
(hrs) and
			<%				
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(1);
			%>
<input name="minutes_work" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyInteger('dtr_op','minutes_work')" value="<%=strTemp%>" size="6" maxlength="6" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','minutes_work')">
(minutes)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong> Valid Overtime minutes interval</strong></td>
			<%				
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(2);
 			%>
      <td><input name="ot_interval" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyInteger('dtr_op','ot_interval')" value="<%=strTemp%>" size="3" maxlength="2" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','ot_interval')">
      minutes<font size="1">(value 0-59)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%				
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(2);
 			%>			
      <td height="25"><%=strTemp%> minutes <a href='javascript:ShowHideFrame("1")'><img src="../../../images/online_help.gif" width="34" height="26" border="0"></a>
			<iframe width="0" scrolling="no" height="0" frameborder="0" id="iframetop" style="position:absolute;height:75;"> </iframe>
			<div id="1" style="position:absolute; visibility:hidden; width:450px;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<%
						strTemp = "This refers to the fraction of an hour which will be considered as valid Overtime.<br>";
						strTemp += "Sample: Setting is 20 Minutes<br>";
						strTemp += "1. OT is 3 hours 30 minutes. Only the 3 hours 20 minutes will be valid.<br>";
						strTemp += "2. OT is 3 hours 45 minutes. Only the 3 hours 40 minutes will be valid.";
					%>
					<td width="90%"><strong><%=strTemp%></strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideFrame('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div>			</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
		<%if(bolHasOTBreak){%>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(3);
				else
					strTemp = WI.fillTextValue("has_break");
					
				if(strTemp != null && strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td height="25"><strong><input type="checkbox" value="1" name="has_break" <%=strTemp%>>
        </strong>Has Default Overtime  break<strong> (optional)</strong></td>
			<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(3);
					else
						strTemp = WI.fillTextValue("break_hr_fr");
					strTemp = WI.getStrValue(strTemp);
			%>
      <td>From :
        <input name="break_hr_fr" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  >
:
			<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(4);
					else
						strTemp = WI.fillTextValue("break_min_fr");
					strTemp = WI.getStrValue(strTemp);
			%>
<input name="break_min_fr" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(5);
					else
						strTemp = WI.fillTextValue("break_ampm_fr");
					strTemp = WI.getStrValue(strTemp);
			%>
<select name="break_ampm_fr" id="break_ampm_fr">
  <option value=0>AM</option>
  <% if (strTemp.equals("1")) {%>
  <option value=1 selected>PM</option>
  <% }else{%>
  <option value=1>PM</option>
  <%}%>
</select>
to
			<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(6);
					else
						strTemp = WI.fillTextValue("break_hr_to");
					strTemp = WI.getStrValue(strTemp);
			%>
<input name="break_hr_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
:
			<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(7);
					else
						strTemp = WI.fillTextValue("break_min_to");
					strTemp = WI.getStrValue(strTemp);
			%>
<input name="break_min_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(8);
					else
						strTemp = WI.fillTextValue("break_ampm_to");
					strTemp = WI.getStrValue(strTemp);
			%>
<select name="break_ampm_to" id="break_ampm_to">
  <option value="0">AM</option>
  <% if (strTemp.compareTo("1")== 0) {%>
  <option value="1" selected>PM</option>
  <%}else{%>
  <option value="1">PM</option>
  <%}%>
</select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
		<%}%>		
    <%if(strSchCode.startsWith("TAMIYA")){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td><u><strong>Current Overtime Meal Allowance rates</strong></u></td>
      <td><u><strong> Overtime Meal Allowance rates</strong></u></td>
    </tr>
		<tr>
		  <td height="25">&nbsp;</td>
			<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(11);
					strTemp = WI.getStrValue(strTemp);
			%>			
		  <td>Regular rate : <strong><%=CommonUtil.formatFloat(strTemp, true)%></strong><div id="2" style="position:absolute; visibility:hidden; width:450px;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<%
						strTemp2 = "This refers to the fraction of an hour which will be considered as valid Overtime.<br>";
						strTemp2 += "Sample: Setting is 20 Minutes<br>";
						strTemp2 += "1. OT is 3 hours 30 minutes. Only the 3 hours 20 minutes will be valid.<br>";
						strTemp2 += "2. OT is 3 hours 45 minutes. Only the 3 hours 40 minutes will be valid.";
					%>
					<td width="90%"><strong><%=strTemp2%></strong></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
			</div></td>
		  <td><input name="weekday_rate" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyIntegerExtn('dtr_op','weekday_rate', '.')" value="<%=strTemp%>" size="6" maxlength="8" 
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','weekday_rate', '.')"
			 style="text-align:right" ></td>
	  </tr>
		<!--
		<tr>
		  <td height="25">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(12);
				strTemp = WI.getStrValue(strTemp);
			%>		
		  <td>Weekend rate  : <strong><%=CommonUtil.formatFloat(strTemp, true)%></strong></td>
		  <td><input name="weekend_rate" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyIntegerExtn('dtr_op','weekend_rate', '.')" value="<%=strTemp%>" size="6" maxlength="8" 
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','weekend_rate','.')"
			style="text-align:right"></td>
	  </tr>  
		-->
		<tr>
		  <td height="25">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(13);
				strTemp = WI.getStrValue(strTemp);
			%>		
		  <td>Holiday/Leave Rate : <strong><%=CommonUtil.formatFloat(strTemp, true)%></strong></td>
		  <td><input name="others_rate" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyIntegerExtn('dtr_op','others_rate', '.')" value="<%=strTemp%>" size="6" maxlength="8" 
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','others_rate','.')"
			style="text-align:right"></td>
	  </tr>     
		<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25">
			<%if(iAccessLevel > 1){%>
			<div align="center">
	  <input type="image" src="../../../images/save.gif" border="0" onClick="AddRecord();">
	  <font size="1">click to save changes</font></div>
		<%}%>
		</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="addRecord">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>