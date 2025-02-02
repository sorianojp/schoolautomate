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
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">

function ConvertHour(strHrValue, strHrSelect, strAmPm){
	var iHour = eval('document.dtr_op.'+strHrSelect+'.value');
	var vAMPM = eval('document.dtr_op.'+strAmPm+'.value');
	if(iHour == 12 && vAMPM == 0)
		iHour = 0;	
	
	if(vAMPM == 1 && iHour < 12 ){
		iHour = eval(iHour) + 12;
	}
	eval('document.dtr_op.'+strHrValue+'.value='+iHour);
	//document.form_.request_hr.value = iHour;
}

function SetFocus(){
	document.dtr_op.max_hour.focus();
}

function AddRecord(){
	document.dtr_op.addRecord.value = "1";
}

 
</script>
<body bgcolor="#D2AE72" onLoad="SetFocus();" class="bgDynamic">
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strTime = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Dtr Operations-Flexi Time DTR Setting","set_flexi_dtr_setting.jsp");
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
														"set_flexi_dtr_setting.jsp");	
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
int i = 0;
int iHour = 0;
String strAMPM = " AM";
strTemp = WI.fillTextValue("addRecord");
if(strTemp.compareTo("1") ==0)
{
	if(allowedLateTIN.addEditFlexSetting(dbOP, request))
		strErrMsg = "Time in information recorded successfully.";
	else
		strErrMsg = allowedLateTIN.getErrMsg();
}
	vRetResult = allowedLateTIN.operateOnLateSetting(dbOP, request, 3);

%>	
<form action="./set_flexi_dtr_setting.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      DTR OPERATIONS - FLEXI TIME DTR SETTING ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><u><strong>Current Max TIME IN</strong></u></td>
      <td><u><strong>Allowed Max TIME IN</strong></u></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
			<% 
				strTemp = "";
				if(vRetResult != null && vRetResult.size() > 0){
					// max hour
					strTemp = (String)vRetResult.elementAt(4);
					if(strTemp != null){
						strTemp += ":";
						strTemp2 = (String)vRetResult.elementAt(5);
						while(WI.getStrValue(strTemp2).length() < 2)
							strTemp2 = "0"+strTemp2;
						strTemp += strTemp2;
						
						strAMPM = (String)vRetResult.elementAt(6);
						if(strAMPM.equals("1"))
							strAMPM = " PM";
						else
							strAMPM = " AM";
						strTemp += strAMPM;
					}
				}
			%>
      <td width="48%" height="25"><strong><%=WI.getStrValue(strTemp)%></strong></td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(4);
				else
					strTemp = WI.fillTextValue("max_hour");
				iHour = Integer.parseInt(WI.getStrValue(strTemp, "11"));
			%>
      <td width="50%" height="25"><b><font color="#000066">
        <select name="max_hour">
          <option value="1">1</option>
          <%for(i = 2; i <= 12; i++){%>
          <%if(iHour == i){%>
          <option value="<%=i%>" selected="selected"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}%>
          <%}%>
        </select>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(5);
				else
					strTemp = WI.fillTextValue("max_minute"); 
				strTemp = WI.getStrValue(strTemp);
			%>				
        :
        <select name="max_minute">
          <%for(i = 0; i < 60; i+=1){%>
          <%if(strTemp.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected="selected"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}%>
          <%}%>
        </select>
				<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(6);
					else
						strTemp = WI.fillTextValue("max_am_pm"); 
					strTemp = WI.getStrValue(strTemp);
				%>
        <select name="max_am_pm">
          <option value="0">AM</option>
          <%if(strAMPM.equals("1")){%>
          <option value="1" selected="selected">PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select>
      </font></b></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>Current valid break period for flexi </strong></u></td>
      <td height="30"><u><strong>Valid break period </strong></u></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
			<% 
				strTemp = "";
				if(vRetResult != null && vRetResult.size() > 0){
					// valid time from
					strTemp = (String)vRetResult.elementAt(7);
 					if(strTemp != null){
						strTemp += ":";
						strTemp2 = (String)vRetResult.elementAt(8);
						while(WI.getStrValue(strTemp2).length() < 2)
							strTemp2 = "0"+strTemp2;
						strTemp += strTemp2;
						
						strAMPM = (String)vRetResult.elementAt(9);
						if(strAMPM.equals("1"))
							strAMPM = " PM";
						else
							strAMPM = " AM";
						strTemp += strAMPM;
					}
					
					strTime = strTemp;
					
					if(strTime != null){
						strTemp = (String)vRetResult.elementAt(10);
 						if(strTemp != null){
							strTemp += ":";
							strTemp2 = (String)vRetResult.elementAt(11);
							while(WI.getStrValue(strTemp2).length() < 2)
								strTemp2 = "0"+strTemp2;
							strTemp += strTemp2;
							
							strAMPM = (String)vRetResult.elementAt(12);
							if(strAMPM.equals("1"))
								strAMPM = " PM";
							else
								strAMPM = " AM";
							strTemp += strAMPM;
						}		
						strTime +=" - " + strTemp;		
					}					
				}
			%>
      <td width="48%" height="25">&nbsp;<strong><%=WI.getStrValue(strTime)%></strong></td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(7);
				else
					strTemp = WI.fillTextValue("hour_fr");
				strTemp = WI.getStrValue(strTemp);
			%>
      <td width="50%"><input name="hour_fr" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
:
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(8);
				else
					strTemp = WI.fillTextValue("min_fr");				
				strTemp = WI.getStrValue(strTemp);
			%>
  <input name="min_fr" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(9);
				else
					strTemp = WI.fillTextValue("am_pm_fr");
				strTemp = WI.getStrValue(strTemp);		
			%>
			
  <select name="am_pm_fr">
    <option value="0" >AM</option>
    <% if (strTemp.equals("1")) {%>
    <option value="1" selected>PM</option>
    <% }else {%>
    <option value="1">PM</option>
    <%}%>
  </select>
to
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(10);
				else
					strTemp = WI.fillTextValue("hour_to");
				strTemp = WI.getStrValue(strTemp);
			%>
<input name="hour_to" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
:
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(11);
				else
					strTemp = WI.fillTextValue("min_to");
				strTemp = WI.getStrValue(strTemp);
			%>
<input name="min_to" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(12);
				else
					strTemp = WI.fillTextValue("am_pm_to");
				strTemp = WI.getStrValue(strTemp);
			%>
<select name="am_pm_to" >
  <option value="0" >AM</option>
  <% if (strTemp.equals("1")){ %>
  <option value="1" selected>PM</option>
  <% }else{ %>
  <option value="1">PM</option>
  <%}%>
</select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<tr>
      <td height="25">&nbsp;</td>
      <td height="25"><u><strong>Current minimum break duration (in minutes) </strong></u></td>
      <td height="25"><u><strong>Minimum break time (in min) </strong></u></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(14);
				else
					strTemp = WI.fillTextValue("min_breaktime");
				strTemp = WI.getStrValue(strTemp);
			%>			
      <td height="25"><strong><%=WI.getStrValue(strTemp,"", " min", "")%></strong></td>
      <td>
			<input name="min_breaktime" type="text" size="4" maxlength="3" value="<%=WI.getStrValue(strTemp)%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
			</td>
    </tr>		
		<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><u><strong>Current maximum break duration (in minutes) </strong></u></td>
      <td height="25"><u><strong>Maximum break time (in min) </strong></u></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(13);
				else
					strTemp = WI.fillTextValue("max_breaktime");
				strTemp = WI.getStrValue(strTemp);
			%>			
      <td height="25"><strong><%=WI.getStrValue(strTemp,"", " min", "")%></strong></td>
      <td>
			<input name="max_breaktime" type="text" size="4" maxlength="3" value="<%=WI.getStrValue(strTemp)%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
			</td>
    </tr>
		-->
    <tr>
      <td height="32">&nbsp;</td>
      <td colspan="2"></td>
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
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" align="center">
			<%
 			if(iAccessLevel > 1){%>
	    <input type="image" src="../../../images/save.gif" border="0" onClick="AddRecord();">
	    <font size="1">click to save changes</font>
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