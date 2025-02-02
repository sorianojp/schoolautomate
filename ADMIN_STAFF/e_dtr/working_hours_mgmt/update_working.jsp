<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(7);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	if(bolMyHome)
		strColorScheme = CommonUtil.getColorScheme(9);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Set working hours</title>
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
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function showLunchBreak(){
	if (document.dtr_op.one_tin_tout.checked){
		document.getElementById("lunch_br").innerHTML = 
		"<input name=\"lunch_break\" type=\"text\" size=\"3\" maxlength=\"3\"  "+ 
		"value=\"<%=WI.fillTextValue("lunch_break")%>\" class=\"textbox\" " +
		"onFocus=\"style.backgroundColor=\'#D3EBFF\'\" onBlur=\"style.backgroundColor=\'#FFFFFF\'\" " +
		" onKeypress=\" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;\"> Break (in Minutes)";

		document.getElementById("lbl_second_set").innerHTML = "Break Time <a href='javascript:showNote(1);'>NOTE</a>";
		
		document.dtr_op.logout_nextday.disabled = false;
//		document.dtr_op.pm_hr_fr.disabled = true;
//		document.dtr_op.pm_min_fr.disabled = true;
//		document.dtr_op.ampm_from1.disabled = true;
//		document.dtr_op.pm_hr_to.disabled = true;
//		document.dtr_op.pm_min_to.disabled = true;
//		document.dtr_op.ampm_to1.disabled = true;
	}else{
		document.getElementById("lunch_br").innerHTML = "";
		document.dtr_op.logout_nextday.disabled = true;
		document.getElementById("lbl_second_set").innerHTML = "Second Time In";
//		document.dtr_op.pm_hr_fr.disabled = false;
//		document.dtr_op.pm_min_fr.disabled = false;
//		document.dtr_op.ampm_from1.disabled = false;
//		document.dtr_op.pm_hr_to.disabled = false;
//		document.dtr_op.pm_min_to.disabled = false;
//		document.dtr_op.ampm_to1.disabled = false;
	}
}

function showNote(strShow){
	var iframe = document.getElementById('iframetop');
	var layer = document.getElementById("note_");
	
	if(strShow == '0'){		
		layer.style.visibility = "hidden";
		iframe.style.display = 'none';
		layer.style.display = 'none';	
	}else{
		layer.style.visibility = "visible";
		iframe.style.display = 'block';
		layer.style.display = 'block';	
		iframe.style.width = layer.offsetWidth-5;	
		iframe.style.left = layer.offsetLeft;
		iframe.style.top = layer.offsetTop;
		iframe.style.height = (layer.offsetHeight-5);
	}
}
 
function UpdateRecord(){
	document.dtr_op.update_record.value = "1";
	document.dtr_op.processsing.value = "1";	
}
 
</script>
<body bgcolor="#D2AE72" class="bgDynamic" topmargin="10">
<%
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strPrepareToEdit = null;
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	
	boolean bolViewOnly = WI.fillTextValue("view_only").equals("1");
	if(bolViewOnly)
		bolMyHome = true;
//add security here.
	try
	{
		dbOP = new DBOperation(strUserID,
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","update_working.jsp");
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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"update_working.jsp");	
														
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		iAccessLevel  = 1;
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//																					
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
	WorkingHour whPersonal = new WorkingHour(); 
	Vector vRetResult = null;
	String strEmpID = null;
	String[] astrConvertWeekDay= {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};	
	String[] astrConverAMPM = {"AM","PM"};
	String strDateTo = null;

	double dTime = 0d;
	int iHour = 0;
	int iMinute = 0;	
	String strAMPM = " AM";
	boolean bolProcesssing = WI.fillTextValue("processsing").equals("1");
	
	Vector vEditInfo = null;
	strTemp = WI.fillTextValue("emp_id"); 
	strEmpID = strTemp;
	
	if(WI.fillTextValue("update_record").equals("1")){
		if(!whPersonal.updateWHSchedule(dbOP, request, WI.fillTextValue("wh_index")))
			strErrMsg = whPersonal.getErrMsg();
		else
			strErrMsg = "Operation Successful";
	}

 	vEditInfo = whPersonal.getEmployeeWorkingHours(dbOP, request, false, true, "3");
%>	
<form action="./update_working.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="22" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      EMPLOYEE WORKING HOUR PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td height="22"><strong><font size="2" >&nbsp;<%=WI.getStrValue(strErrMsg)%>&nbsp;</font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
    <tr>
      <td colspan="6" height="22">&nbsp;Employee ID :<strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>      </td>
    </tr>
  </table>
<% 

if (strTemp.length()  > 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
  vRetResult = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vRetResult !=null){
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="15">&nbsp;</td>
      <td height="15" colspan="2"><font size="1">Employee Name</font></td>
      <td width="56%" height="15"><font size="1">Employee Status</font></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <% strTemp = WI.formatName((String)vRetResult.elementAt(1), (String)vRetResult.elementAt(2),
									(String)vRetResult.elementAt(3),1); %>
      <td colspan="2" valign="top"><strong><%=strTemp%></strong></td>
      <td valign="top"><strong><%=WI.getStrValue((String)vRetResult.elementAt(16))%></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td colspan="2"><font size="1">Position</font></td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</font></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <% strTemp = (String)vRetResult.elementAt(15);%>
      <td colspan="2" valign="top"><strong><%=WI.getStrValue(strTemp)%></strong></td>
      <%
				if((String)vRetResult.elementAt(13) == null)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(14));
			else
			{	
				strTemp =WI.getStrValue((String)vRetResult.elementAt(13));
				if((String)vRetResult.elementAt(14) != null)
					strTemp += "/" + WI.getStrValue((String)vRetResult.elementAt(14));
			}
%>
      <td valign="top"><strong><%=WI.getStrValue(strTemp)%></strong></td>
    </tr>
    <tr> 
      <td height="2" colspan="4"><hr size="1"></td>
    </tr>
	</table>
		<%}%>
		
		<%if(vEditInfo != null && vEditInfo.size() > 0){%>
		<input type="hidden" name="week_day" value="<%=vEditInfo.elementAt(1)%>">
		<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="22">&nbsp;</td>
      <td width="19%"><u>Working Hour</u></td>
			<%
				if(vEditInfo.elementAt(1) != null)
					strTemp = astrConvertWeekDay[Integer.parseInt((String)vEditInfo.elementAt(1))];
				else
					strTemp = "";
			%>
      <td><strong><%=strTemp%></strong></td>
      </tr>
    <% if(((String)vEditInfo.elementAt(14)).equals("0")){%>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>First Time In</td>
			<%
			if(!bolProcesssing) 
				strTemp = (String)vEditInfo.elementAt(2);
			else
				strTemp = WI.fillTextValue("am_hr_fr");
			%>
      <td><input name="am_hr_fr" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
        : 
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(3);
			else	
				strTemp = WI.fillTextValue("am_min_fr");
			%>				
        <input name="am_min_fr" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(4);
			else	
				strTemp = WI.fillTextValue("ampm_from0");
			strTemp = WI.getStrValue(strTemp);
			%>
        <select name="ampm_from0">
          <option value="0" >AM</option>
          <% if (strTemp.equals("1") || strTemp.equals("PM")){ %>
          <option value="1" selected>PM</option>
          <% }else {%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(5);
			else	
				strTemp = WI.fillTextValue("am_hr_to");
			strTemp = WI.getStrValue(strTemp);
			%>				
        <input name="am_hr_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(6);
			else	
				strTemp = WI.fillTextValue("am_min_to");
			strTemp = WI.getStrValue(strTemp);
			%>						
        <input name="am_min_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(7);
			else	
				strTemp = WI.fillTextValue("ampm_to0");
			strTemp = WI.getStrValue(strTemp);			
			%>	
        <select name="ampm_to0" >
          <option value="0" >AM</option>
          <% if (strTemp.equals("1") || strTemp.equals("PM")){ %>
          <option value="1" selected>PM</option>
          <% }else{ %>
          <option value="1">PM</option>
          <%}%>
        </select>
        <br>
        <%
				if(!bolProcesssing)
					strTemp = (String)vEditInfo.elementAt(8);
				else	
					strTemp = WI.fillTextValue("one_tin_tout");
				
				if(strTemp == null)
					strTemp = "checked";
				else
					strTemp = "";
				%>
				<label for="one_chk_opt_">
				<input name="one_tin_tout" type="checkbox"  value="1"  id="one_chk_opt_"
				onClick="showLunchBreak()" tabindex="-1" <%=strTemp%>> 
        <font size="1">employee has only one time in/time out </font>				</label>				</td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td><label id="lbl_second_set">Second Time In</label>
			<iframe width="0" scrolling="no" height="0" frameborder="0" id="iframetop" style="position:absolute;"> </iframe>
			<div id="note_" style="position:absolute;visibility:hidden; width:400px;">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFCC">
				<tr>
					<td width="90%">If you enter valid break time range, then the Break (in Minutes) will be disregarded</td>
					<td width="10%" align="center"><a href="javascript:showNote('0');">HIDE</a></td>
				</tr>
			</table>
			</div>			</td>
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(8);
			else	
				strTemp = WI.fillTextValue("pm_hr_fr");
			strTemp = WI.getStrValue(strTemp);
			%>				
      <td><input name="pm_hr_fr" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(9);
			else	
				strTemp = WI.fillTextValue("pm_min_fr");
			strTemp = WI.getStrValue(strTemp);
			%>					
        <input name="pm_min_fr" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(10);
			else	
				strTemp = WI.fillTextValue("ampm_from1");
			strTemp = WI.getStrValue(strTemp);
			%>	
        <select name="ampm_from1" >
          <option value="0">AM</option>
         <% if (strTemp.equals("1") || strTemp.equals("PM")){ %>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(11);
			else	
				strTemp = WI.fillTextValue("pm_hr_to");
			strTemp = WI.getStrValue(strTemp);
			%>					
        <input name="pm_hr_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(12);
			else	
				strTemp = WI.fillTextValue("pm_min_to");
			strTemp = WI.getStrValue(strTemp);
			%>					
        <input name="pm_min_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(13);
			else	
				strTemp = WI.fillTextValue("ampm_to1");
			strTemp = WI.getStrValue(strTemp);
			%>		
        <select name="ampm_to1">
          <option value="0" >AM</option>
          <% if (strTemp.equals("1") || strTemp.equals("PM")){ %>
          <option value="1" selected>PM</option>
          <% }else{ %>
          <option value="1">PM</option>
          <%}%>
        </select>&nbsp;&nbsp;&nbsp;<label id="lunch_br"></label></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
        <input name="logout_nextday" type="checkbox" id="logout_nextday" value="1" disabled>
       <font size="1">employee logout is on the next day</font></td>
    </tr>
		<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><span class="branch" id="branch2">
			<input name="break_hr_fr" type="text" size="2" maxlength="2" value="<%//=WI.fillTextValue("break_hr_fr")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
      : 
      <input name="break_min_fr" type="text" size="2" maxlength="2" value="<%//=WI.fillTextValue("break_min_fr")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<select name="break_ampm_fr" >
				<option value="0">AM</option>
				<%//if(WI.fillTextValue("break_ampm_fr").equals("1")) {%>
				<option value="1" selected>PM</option>
				<%//}else{%>
				<option value="1">PM</option>
				<%//}%>
			</select>
			to 
      <input name="break_hr_to" type="text" size="2" maxlength="2" value="<%//=WI.fillTextValue("break_hr_to")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
      <input name="break_min_to" type="text" size="2" maxlength="2" value="<%//=WI.fillTextValue("break_min_to")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<select name="break_ampm_to" >
				<option value="0" >AM</option>
				<%// if (WI.fillTextValue("break_ampm_to").equals("1")) {%>
				<option value="1" selected>PM</option>
				<%// }else{ %>
				<option value="1">PM</option>
				<%//}%>
			</select>
			</span></td>
    </tr>
		-->
    <%} else {%>
    <tr>
      <td>&nbsp;</td>
      <td>Valid time in </td>
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(2);
			else	
				strTemp = WI.fillTextValue("am_hr_fr_flex");
			strTemp = WI.getStrValue(strTemp);
			%>
      <td><input name="am_hr_fr_flex" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
:
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(3);
			else	
				strTemp = WI.fillTextValue("am_min_fr_flex");
			strTemp = WI.getStrValue(strTemp);
			%>			
  <input name="am_min_fr_flex" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(4);
			else	
				strTemp = WI.fillTextValue("ampm_from0_flex");
			strTemp = WI.getStrValue(strTemp);
			%>	
  <select name="ampm_from0_flex">
    <option value="0" >AM</option>
    <% if (strTemp.equals("1") || strTemp.equals("PM")) {%>
    <option value="1" selected>PM</option>
    <% }else {%>
    <option value="1">PM</option>
    <%}%>
  </select>
to
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(5);
			else	
				strTemp = WI.fillTextValue("am_hr_to_flex");
			strTemp = WI.getStrValue(strTemp);
			%>
<input name="am_hr_to_flex" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
:
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(6);
			else	
				strTemp = WI.fillTextValue("am_min_to_flex");
			strTemp = WI.getStrValue(strTemp);
			%>
<input name="am_min_to_flex" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(7);
			else	
				strTemp = WI.fillTextValue("ampm_to0_flex");
			strTemp = WI.getStrValue(strTemp);
			%>
<select name="ampm_to0_flex" >
  <option value="0" >AM</option>
  <% if (strTemp.equals("1") || strTemp.equals("PM")){ %>
  <option value="1" selected>PM</option>
  <% }else{ %>
  <option value="1">PM</option>
  <%}%>
</select></td>
    </tr>
    
    <tr> 
      <td>&nbsp;</td>

      <td>Number of Hours : </td>
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(15);
			else	
				strTemp = WI.fillTextValue("flex_hour");
			strTemp = WI.getStrValue(strTemp);
			%>			
      <td><input name="flex_hour" type="text" class="textbox" onKeyUp="AllowOnlyFloat('dtr_op','flex_hour');"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"></td>
    </tr>
    <%} %>	
  	</table>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
     <tr>
      <td width="2%" height="18">&nbsp;</td>
      <td width="22%">&nbsp;</td>
      <td width="26%">&nbsp;</td>
      <td width="50%">&nbsp;</td>
    </tr>		
    <tr> 
      <td height="22">&nbsp;</td>
      <td>Effective Date From: </td>
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(33);
			else	
				strTemp = WI.fillTextValue("date_from");
			strTemp = WI.getStrValue(strTemp);
			%>				
      <td><input name="date_from" type="text" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" 
	   onBlur="style.backgroundColor='white'; AllowOnlyIntegerExtn('dtr_op','date_from','/');"
	   onKeyUp= "AllowOnlyIntegerExtn('dtr_op','date_from','/')"
	    value="<%=strTemp%>" size="10" maxlength="10">
      <a href="javascript:show_calendar('dtr_op.date_from');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(34);
			else	
				strTemp = WI.fillTextValue("date_to");
			strTemp = WI.getStrValue(strTemp);
			%>
      <td>Effective Date To: 
        <input name="date_to" type="text" class="textbox"  
		onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','date_to','/');"
		onKeyUP= "AllowOnlyIntegerExtn('dtr_op','date_to','/')"
		value="<%=strTemp%>" size="10" maxlength="10"> 
        <a href="javascript:show_calendar('dtr_op.date_to');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        <br>
        <font size="1">(leave blank if still applicable)</font></td>
    </tr>
     <tr>
      <td height="30" colspan="4"><font color="#FF0000"><strong>Warning : <br>
&nbsp;&nbsp;- Updating the information in this page may cause discrepancies in the dtr reports.</strong></font></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><div align="center">
          <input name="image" type="image" onClick="UpdateRecord();" src="../../../images/edit.gif" width="48" height="28">
          <font size="1">click to save changes</font></div></td>
    </tr>
  </table>
 <%}
 }%>
<!-- here lies the great mysteries of and future-->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25"s>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
	<input type="hidden" name="wh_index" value="<%=WI.fillTextValue("wh_index")%>">
	<input type="hidden" name="processsing">
	<input type="hidden" name="update_record" value="">
</form>
</body>
</html>

<% dbOP.cleanUP(); %>
