<%@ page language="java" import="utility.*, eDTR.ReportMultipleWH, eDTR.MultipleWorkingHour, java.util.Vector" buffer="16kb"%>
<%
///added code for HR/companies.
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Scheduling</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
 <script language="JavaScript">
function ReloadPage() {
	this.SubmitOnce('form_');
}
 
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../../images/blank.gif";
	this.SubmitOnce('form_');
}
 
function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
} 
</script>

<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strAmPm = null;
	WebInterface WI = new WebInterface(request);

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record-WORKING HOURS MGMT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Encoding of Absences","no_dtr_schedule.jsp");
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

	ReportMultipleWH rptWHour = new ReportMultipleWH();
	MultipleWorkingHour mWHour = new MultipleWorkingHour();
	String strTemp2  = null;
	String[] astrConverAMPM = {"AM","PM"};
	
	Vector vPersonalDetails = new Vector();
	Vector vRetResult = null;
	
	String strEmpID = WI.fillTextValue("emp_id");
	String[] astrConvSem = {"Summer", "1st", "2nd", "3rd"};
	String strSem = WI.fillTextValue("semester");
	String strRoomNo = null;
	
	int iSearchResult = 0;
	int i = 0;
	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		vRetResult = mWHour.operateOnFacultySchedule(dbOP, request, Integer.parseInt(strPageAction));
		if(vRetResult == null){
			strErrMsg = mWHour.getErrMsg();
		}else{
			strErrMsg = "Operation Successful";
		}
	}

	enrollment.Authentication authentication = new enrollment.Authentication();
  vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vPersonalDetails == null){
		strErrMsg = "No record for employee " + WI.fillTextValue("emp_id");
	}else{
		vRetResult = rptWHour.operateOnFacultyLoadWithoutDtrSched(dbOP, request, 4, WI.fillTextValue("emp_index"));
		if(vRetResult == null)
			strErrMsg = WI.getStrValue(strErrMsg) + WI.getStrValue(rptWHour.getErrMsg());
	}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form name="form_" action="./no_dtr_schedule.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      FACULTY WORKING HOURS ::::</strong></font></td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td>&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
  </tr>
</table>

  <% if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
      <td>Employee Name</td>
      <td colspan="3">&nbsp;<strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Employee ID</td>
      <td width="31%">&nbsp;<strong><%=WI.fillTextValue("emp_id")%> </strong></td>
      <td width="21%">Employment Status</td>
      <td width="26%">&nbsp;<strong><%=WI.getStrValue((String)vPersonalDetails.elementAt(16),"")%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Employment Type</td>
      <td>&nbsp;<strong><%=WI.getStrValue((String)vPersonalDetails.elementAt(15),"")%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>College/Office</td>
      <td colspan="3">&nbsp;<strong>
      <%if(vPersonalDetails.elementAt(13) != null){%>
      <%=(String)vPersonalDetails.elementAt(13)%> ;
      <%}if(vPersonalDetails.elementAt(14) != null){%>
      <%=(String)vPersonalDetails.elementAt(14)%>
      <%}%>
      </strong></td>
    </tr>
    <tr >
      <td height="12"></td>
			<%
				strTemp = WI.fillTextValue("show_no_room");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td height="12" colspan="4"><input type="checkbox" name="show_no_room" value="1" <%=strTemp%> onClick="ReloadPage();">Show also without room number</td>
    </tr>
    <tr >
      <td height="12" colspan="5"></td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0) {%>	
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFF99">
      <td height="25" colspan="7" align="center"><strong>::: CURRENT WORKING
      HOURS/SCHEDULE :::</strong></td>
    </tr>
  </table>	
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td align="center">
		
		<table width="90%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="16%" height="25" align="center" class="thinborder"><font size="1"><strong>SECTION
      </strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>SUBJECT</strong></font></td>
      <td width="27%" align="center" class="thinborder"><font size="1"><strong>ROOM NUMBER </strong></font></td>
      <td width="29%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">CONTROL</font></strong></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>CREATE SCHEDULE<br>
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
      </strong></font></td>
    </tr>
    <%
		int iCount = 1;
		for(i = 0 ; i < vRetResult.size() ; i +=15, iCount++){%>
    <tr> 
			<input type="hidden" name="cur_day_<%=iCount%>" value="<%=vRetResult.elementAt(i)%>">				
			<input type="hidden" name="hr_from<%=iCount%>" value="<%=vRetResult.elementAt(i+2)%>">
			<input type="hidden" name="min_from<%=iCount%>" value="<%=vRetResult.elementAt(i+3)%>">
			<input type="hidden" name="ampm_from<%=iCount%>" value="<%=vRetResult.elementAt(i+4)%>">
			<input type="hidden" name="hr_to<%=iCount%>" value="<%=vRetResult.elementAt(i+5)%>">
			<input type="hidden" name="min_to<%=iCount%>" value="<%=vRetResult.elementAt(i+6)%>">
			<input type="hidden" name="ampm_to<%=iCount%>" value="<%=vRetResult.elementAt(i+7)%>">
			<input type="hidden" name="room_index_<%=iCount%>" value="<%=vRetResult.elementAt(i+11)%>">
			<input type="hidden" name="sub_sec_index_<%=iCount%>" value="<%=vRetResult.elementAt(i+13)%>">
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 10)%></td>
			 <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 14)%></td>
			 <%
				 strRoomNo = (String)vRetResult.elementAt(i + 12);
			 %>
			 <td class="thinborder">&nbsp;<%=WI.getStrValue(strRoomNo)%></td>
			 <% 	
			 		strTemp = (String)vRetResult.elementAt(i+1) + " ";
			 		strTemp += (String)vRetResult.elementAt(i+2) +  ":"  + 
					CommonUtil.formatMinute((String)vRetResult.elementAt(i+3));
					strAmPm = " " + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+4))];
					strTemp += strAmPm;
					
					strTemp += " - ";
					strTemp +=(String)vRetResult.elementAt(i+5)  + ":"  + 
					CommonUtil.formatMinute((String)vRetResult.elementAt(i+6));
					strAmPm = " " + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+7))];
					strTemp += strAmPm;;  
				%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<td align="center" class="thinborder"><%=vRetResult.elementAt(i+13)%></td>
			<%
				if(WI.fillTextValue("save_"+iCount).length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td align="center" class="thinborder">
			<%if(strRoomNo != null){%>
			<input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1" <%=strTemp%>>
			<%}else{%>
				<input type="hidden" name="save_<%=iCount%>" value="">
				n/a
			<%}%>			</td>
    </tr>
    <%}%>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table></td>
  </tr>
</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
		  <td>&nbsp;</td>
	  </tr>
		<tr>
			<%
				strTemp = WI.fillTextValue("ignore_restday");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
		  <td><input type="checkbox" name="ignore_restday" value="1" <%=strTemp%>>
	    Ignore employee Rest day setting </td>
	  </tr>
		<tr>
			<td>Generate for &nbsp;Date :
			  <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a> to
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
		  <td height="23">&nbsp;</td>
	  </tr>
	</table>	
   <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="38" colspan="3" align="center">
        <%if(iAccessLevel > 1) {%>
        <!--
          <a href='javascript:PageAction(1, "");'> <img src="../../../../images/save.gif" border="0" id="hide_save"></a>					
					-->
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        <font size="1">click to save entries</font>
        <%}%>
        <!--
					<a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" border="0"></a>
					-->
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">					
        <font size="1"> click to cancel or go previous</font></td>
    </tr>
  </table>
	<%}%>	
<%}//show only if personal detail is found."
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="view_all">
<input type="hidden" name="page_action">
<input type="hidden" name="PageReloaded">
	<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
	<input type="hidden" name="emp_index" value="<%=WI.fillTextValue("emp_index")%>">
	<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
	<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>