<%@ page language="java" import="utility.*,java.util.Vector,eDTR.MultipleWorkingHour" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: block;
	margin-left: 16px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<style type="text/css">
	.txtbox_noborder {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		text-align:right;
		border: 0; 
	}
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ViewRecord(){
 	this.SubmitOnce('form_');
}

 function PreparedToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}


function CancelEntries() {
		location = "./add_dtr_faculty_sched.jsp?emp_id=" + document.form_.emp_id.value + 
			"&login_date="+document.form_.login_date.value+
			"&show_list=1";
}

function AddRecord(){
	document.form_.page_action.value = "1";
	this.SubmitOnce('form_');
}

function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.reloaded.value = "1";
	this.SubmitOnce('form_');
}
function DeleteRecord(index){
	var vProceed = confirm("Confirm delete for schedule. Do you want to continue?");
	if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.info_index.value = index;
		this.SubmitOnce('form_');
	}else
		return;
}

   
	function focusID() {
		document.form_.emp_id.focus();
	}
	
	function OpenSearch() {
		var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
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
		//this.setEIP(false);
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function UpdateLateUT(strInfoIndex,strTinTout,iCtr){
	document.form_.info_index.value = strInfoIndex;
	document.form_.bTimeIn.value = strTinTout;
	eval('document.form_.late_under_time_val.value=document.form_.txtbox'+iCtr+'.value');
	document.form_.page_action.value="5";
	document.form_.submit();
}

function addSchedule(strIDLabel){
	var vWday = eval('document.form_.cur_day_'+strIDLabel+'.value');
	var strHrFr = eval('document.form_.hr_from'+strIDLabel+'.value');
	var strMinFr = eval('document.form_.min_from'+strIDLabel+'.value');
	var strAmPmFr = eval('document.form_.ampm_from'+strIDLabel+'.value');
	var strHrTo = eval('document.form_.hr_to'+strIDLabel+'.value');
	var strMinTo = eval('document.form_.min_to'+strIDLabel+'.value');
	var strAmPmTo = eval('document.form_.ampm_to'+strIDLabel+'.value');
	var strRoom = eval('document.form_.room_index_'+strIDLabel+'.value');
	var strSubSec = eval('document.form_.sub_sec_index_'+strIDLabel+'.value'); 

	var objCOAInput = document.getElementById("faculty_sched_");
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	//this.setEIP(false);
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=603" +
							"&hr_from="+strHrFr+"&min_from="+strMinFr+"&ampm_from="+strAmPmFr+
							"&hr_to="+strHrTo+"&min_to="+strMinTo+"&ampm_to="+strAmPmTo+						
							"&r_index="+strRoom+"&sub_sec_index="+strSubSec+"&cur_day="+vWday+
							"&login_date="+document.form_.login_date.value+
							"&emp_id="+document.form_.emp_id.value;

	this.processRequest(strURL);
	document.form_.submit();
}

///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}

///////////////////////////////////////// End of collapse and expand filter ////////////////////
</script>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode = 
				WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","add_dtr_faculty_sched.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(),
														"add_dtr_faculty_sched.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

///// exclusive for testers only.. 
String strUserID = (String)request.getSession(false).getAttribute("userId");
//////////////////

MultipleWorkingHour TInTOut = new MultipleWorkingHour();
Vector vRetResult = null;
Vector vPersonalDetails = null;
Vector vFacSchedule = null;

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String[] astrConverAMPM = {"AM","PM"};
String strAmPm  = " AM";
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
boolean bolReloaded = WI.fillTextValue("reloaded").equals("1");
int iPageAction  = 0;
String strUserIndex = null;
Vector vEmpSemSetting  = null;
String strLoginDate = WI.fillTextValue("login_date");
String strOfferingSem = null;
String strOfferingSYFrom = null;
String strOfferingSYTo = null;

  enrollment.Authentication authentication = new enrollment.Authentication();
	if (WI.fillTextValue("emp_id").length() > 0 && strLoginDate.length() > 0) {   
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
		if(vPersonalDetails != null)
			strUserIndex = (String)vPersonalDetails.elementAt(0);
			
			strLoginDate = ConversionTable.convertTOSQLDateFormat(strLoginDate);
			if(strLoginDate != null)
				vEmpSemSetting = TInTOut.getSemSettings(dbOP, strUserIndex, strLoginDate);
		
		if(vEmpSemSetting != null && vEmpSemSetting.size() > 0){
			strOfferingSem = (String)vEmpSemSetting.elementAt(0);
			strOfferingSYFrom = (String)vEmpSemSetting.elementAt(1);
			strOfferingSYTo = (String)vEmpSemSetting.elementAt(2);			
		}

		strTemp = WI.fillTextValue("page_action");	
		if(strTemp.length() > 0){
			if(TInTOut.operateOnEmpMultipleLogs(dbOP, request, Integer.parseInt(strTemp)) == null){
				strErrMsg = TInTOut.getErrMsg();
			} else {
				if(strTemp.equals("6"))
					strErrMsg = "Successfully posted.";		
			}
		}
			
		if(strPreparedToEdit.compareTo("1") == 0)  {
			vEditInfo = TInTOut.operateOnEmpMultipleLogs(dbOP, request, 3);
			if(vEditInfo == null)
				strErrMsg = TInTOut.getErrMsg();
		}
		
		vFacSchedule = TInTOut.operateOnFacultyScheduleForDate(dbOP, request, 4);
		if(vFacSchedule == null)
			strErrMsg = WI.getStrValue(strErrMsg) + WI.getStrValue(TInTOut.getErrMsg());
	
		vRetResult = TInTOut.operateOnEmpMultipleLogs(dbOP, request,5);
			if (vRetResult == null || vRetResult.size() == 0){
			strErrMsg  = TInTOut.getErrMsg();
		}
	}		
%>

<form action="./add_dtr_faculty_sched.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        DTR OPERATIONS - EDIT TIME-IN TIME-OUT PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25">&nbsp; <a href="./working_hour_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a><strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23">Employee ID </td>
      <td width="21%" height="23">
        <input name="emp_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16"
	   onKeyUp="AjaxMapName(1);">
        &nbsp; </td>
      <td width="19%"><label id="coa_info" style="position:absolute;width:400px;"></label><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="63%" rowspan="3" valign="top">
<% if (WI.fillTextValue("emp_id").length() > 0) {
	if (vPersonalDetails!=null){
%>
        <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
          <tr>
            <td> <table width="100%" border="0" cellspacing="0" cellpadding="3">
                <tr>
                  <td width="27%" rowspan="4">
                    <%strTemp = "<img src=\"../../../../upload_img/" + WI.fillTextValue("emp_id").toUpperCase() + 
								"."+strImgFileExt+"\" width=100 height=100>";%>
								
                    <%=strTemp%> </td>
					<% strTemp = WI.formatName((String)vPersonalDetails.elementAt(1), 
												(String)vPersonalDetails.elementAt(2),
												(String)vPersonalDetails.elementAt(3), 4); %>
												
                  <td width="73%" height="25"><strong><font size=1>Name : <%=WI.getStrValue(strTemp)%></font></strong></td>
                </tr>
                <tr>
                  <td height="25"><strong><font size=1>Position: <%=WI.getStrValue((String)vPersonalDetails.elementAt(15))%></font></strong></td>
                </tr>
                <tr>
                  <%
	   	 if((String)vPersonalDetails.elementAt(13) == null)
		    strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
		else
			{
			strTemp =WI.getStrValue((String)vPersonalDetails.elementAt(13));
			if((String)vPersonalDetails.elementAt(14) != null)
		 	 strTemp += "/" + WI.getStrValue((String)vPersonalDetails.elementAt(14));
			}
%>
                  <td height="25"><strong><font size=1>Office/College : <%=WI.getStrValue(strTemp)%></font></strong></td>
                </tr>
                <tr>
                  <td height="25"><strong><font size=1>Status: <%=WI.getStrValue((String)vPersonalDetails.elementAt(16))%></font></strong></td>
                </tr>
              </table></td>
          </tr>
        </table>
        <%}else{%>
	<font size=2><strong><%=authentication.getErrMsg()%></strong></font>
<%}}%>	</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Date </td>
      <td height="20" colspan="2">
<%
strTemp = WI.fillTextValue("login_date");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>	  <input name="login_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.login_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
<!--
		&nbsp;&nbsp;<a href="javascript:ClearDate();"><img src="../../../../images/clear.gif" width="55" height="19" border="0" ></a><font size="1">
        clear the date</font> --></td>
    </tr>
    <tr>
      <td width="3%" height="35">&nbsp;</td>
      <td width="13%" height="25">&nbsp;</td>
      <td colspan="2"><input name="image" type="image" src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></td>
    </tr>
    <tr>
      <td valign="top">&nbsp;</td>
        <%
				if(WI.fillTextValue("ignore_weekday").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>			
      <td height="25" colspan="4">&nbsp;<input type="checkbox" name="ignore_weekday" value="1" <%=strTemp%>>
      Ignore weekday of schedule </td>
    </tr>
  </table>
 <% if (vPersonalDetails != null && WI.fillTextValue("emp_id").length() > 0){ %>
	<%if(vFacSchedule != null && vFacSchedule.size() > 0) {%>	
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFF99">
      <td height="25" colspan="7" align="center"><strong>::: CURRENT WORKING
      HOURS/SCHEDULE :::</strong></td>
    </tr>
  </table>	
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td>
	<div onClick="showBranch('branch4');swapFolder('folder4')">
		<img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4">
		<b><font color="#0000FF">View valid schedules </font></b></div>
	<span class="branch" id="branch4">		
		<table width="80%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="18%" height="25" align="center" class="thinborder"><font size="1"><strong>SECTION
      </strong></font></td>
      <td width="31%" align="center" class="thinborder"><font size="1"><strong>ROOM NUMBER </strong></font></td>
      <td width="35%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
      <td width="16%" align="center" class="thinborder">&nbsp;</td>
    </tr>
    <%
		int iCount = 1;
		for(int i = 0 ; i < vFacSchedule.size() ; i +=15, iCount++){%>
    <tr> 
			<input type="hidden" name="cur_day_<%=iCount%>" value="<%=vFacSchedule.elementAt(i)%>">				
			<input type="hidden" name="hr_from<%=iCount%>" value="<%=vFacSchedule.elementAt(i+2)%>">
			<input type="hidden" name="min_from<%=iCount%>" value="<%=vFacSchedule.elementAt(i+3)%>">
			<input type="hidden" name="ampm_from<%=iCount%>" value="<%=vFacSchedule.elementAt(i+4)%>">
			<input type="hidden" name="hr_to<%=iCount%>" value="<%=vFacSchedule.elementAt(i+5)%>">
			<input type="hidden" name="min_to<%=iCount%>" value="<%=vFacSchedule.elementAt(i+6)%>">
			<input type="hidden" name="ampm_to<%=iCount%>" value="<%=vFacSchedule.elementAt(i+7)%>">
			<input type="hidden" name="room_index_<%=iCount%>" value="<%=vFacSchedule.elementAt(i+11)%>">
			<input type="hidden" name="sub_sec_index_<%=iCount%>" value="<%=vFacSchedule.elementAt(i+13)%>">
      <td height="25" class="thinborder">&nbsp;<%=(String)vFacSchedule.elementAt(i + 10)%></td>
			 <td align="right" class="thinborder"><%=(String)vFacSchedule.elementAt(i + 12)%>&nbsp;</td>
			 <% 	
			 		strTemp = (String)vFacSchedule.elementAt(i+1) + " ";
			 		strTemp += (String)vFacSchedule.elementAt(i+2) +  ":"  + 
					CommonUtil.formatMinute((String)vFacSchedule.elementAt(i+3));
					strAmPm = " " + astrConverAMPM[Integer.parseInt((String)vFacSchedule.elementAt(i+4))];
					strTemp += strAmPm;
					
					strTemp += " - ";
					strTemp +=(String)vFacSchedule.elementAt(i+5)  + ":"  + 
					CommonUtil.formatMinute((String)vFacSchedule.elementAt(i+6));
					strAmPm = " " + astrConverAMPM[Integer.parseInt((String)vFacSchedule.elementAt(i+7))];
					strTemp += strAmPm;;  
				%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				if(WI.fillTextValue("save_"+iCount).length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td align="center" class="thinborder"><a href="javascript:addSchedule('<%=iCount%>');">ADD</a></td>
    </tr>
    <%}%>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
	</span>
	</td>
  </tr>
</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
    
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
 <%// if (!bolMyHome) {%> 
  <%if(WI.fillTextValue("viewonly").length() ==0){%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%"><u>Working Hour</u></td>
      <td width="80%">&nbsp;</td>
    </tr>
  
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Time In </td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(3);
			else	
				strTemp = WI.fillTextValue("hr_from");
			%>			
      <td><input name="hr_from" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
        : 
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(4);
			else	
				strTemp = WI.fillTextValue("min_from");
			%>						
        <input name="min_from" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(5);
			else	
				strTemp = WI.fillTextValue("ampm_from");
			%>			
        <select name="ampm_from">
          <option value="0" >AM</option>
          <% if (strTemp.equals("1")) {%>
          <option value="1" selected>PM</option>
          <% }else {%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(6);
			else	
				strTemp = WI.fillTextValue("hr_to");
			%>					
        <input name="hr_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(7);
			else	
				strTemp = WI.fillTextValue("min_to");
			%>					
        <input name="min_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(8);
			else	
				strTemp = WI.fillTextValue("ampm_to");
			%>	
        <select name="ampm_to" >
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
      <td>Subject Type </td>
			<%
				strTemp = WI.fillTextValue("is_lec");
			%>
      <td><select name="is_lec" onChange="ViewRecord();">
				<option value="">Other</option>
        <%if(WI.fillTextValue("is_lec").equals("0")){%>
				<option value="0" selected>Is Lecture</option>
				<option value="1">Is Laboratory</option>
				<%}else if(WI.fillTextValue("is_lec").equals("1")){%>
				<option value="0">Is Lecture</option>
				<option value="1" selected>Is Laboratory</option>
				<%}else{%>
				<option value="0">Is Lecture</option>
				<option value="1">Is Laboratory</option>
				<%}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Section</td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(18);
			else	
				strTemp = WI.fillTextValue("sub_sec_index");
			%>				
      <td><select name="sub_sec_index">
				<option value="">None</option>
				<%=dbOP.loadCombo("faculty_load.sub_sec_index","section, sub_code", " from faculty_load " +
				" join e_sub_section on (e_sub_section.sub_sec_index = faculty_load.sub_sec_index)" +
				" join subject on (subject.sub_index = e_sub_section.sub_index)" + 
				" where faculty_load.is_valid = 1  and e_sub_section.is_valid = 1 " +
        " and e_sub_section.offering_sy_from = " + strOfferingSYFrom + 
				" and e_sub_section.offering_sy_to = " + strOfferingSYTo + 
				" and e_sub_section.offering_sem = " + strOfferingSem + 
				" and faculty_load.user_index = " + strUserIndex +
				WI.getStrValue(WI.fillTextValue("is_lec"), " and subject.fatima_subject_type = 0 and is_lec = ",""," and subject.fatima_subject_type > 0") +
				" order by section", strTemp, false)%>		
			</select>			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Room Number </td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(15);
			else	
				strTemp = WI.fillTextValue("room_index");
			%>					
      <td><select name="room_index">
				<option value="">None</option>
				<%=dbOP.loadCombo("room_index","location, room_number", " from e_room_detail where is_valid = 1 " +
				" order by location, room_number", strTemp, false)%>		
			</select></td>
    </tr>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>		
		
    <tr> 
      <td height="10" colspan="3"><div align="center"><font size="1">
        <%
			if(iAccessLevel > 1) {
			if(strPreparedToEdit.compareTo("0") == 0){%>
        <a href='javascript:AddRecord();'><img src="../../../../images/save.gif" border="0"></a>click 
        to save entries
        <%}else{%>
        <a href='javascript:EditRecord();'><img src="../../../../images/edit.gif" border="0"></a>click 
        to modify entries
        <%}
		}%>
        <a href="javascript:CancelEntries();"><img src="../../../../images/cancel.gif" border="0"></a> click to remove entries </font></div></td>
    </tr>
		<%}%>
<%//} // do not show if my home%>
  </table>
	<%}%>	 
 <label id="faculty_sched_">
 <%if ((vRetResult != null) && (vRetResult.size()>0)) { %>
 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
   <tr>
     <td height="25" colspan="3" align="center" bgcolor="#B9B292" class="thinborder">LIST OF 
       SCHEDULE FOR ID : <%=WI.fillTextValue("emp_id")%></td>
   </tr>
   <tr>
     <td width="53%" height="26" align="center" class="thinborder"><strong>Scheduled Time </strong></td>
     <td width="25%" align="center" class="thinborder"><strong>ROOM</strong></td>
     <td width="22%" align="center" class="thinborder"><strong>OPTION</strong></td>
   </tr>
   <% 
		 	int iCount = 1;
	  	for(int i = 0; i < vRetResult.size(); i += 25, iCount++){
	 %>
   <tr>
	 	<input type="hidden" name="info_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		<input type="hidden" name="sched_login_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+13)%>">
		<input type="hidden" name="sched_logout_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+14)%>">
     <%
			strTemp = (String)vRetResult.elementAt(i + 3);		
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+4),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" +astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+5))];
			
			// time to here
			strTemp += " - " + (String)vRetResult.elementAt(i + 6);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+7),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+8))];
			%>
     <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
		 <input type="hidden"	 name="schedule_<%=iCount%>" value="<%=strTemp%>">
		 <%
		 	//strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11));			
			//strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12), strTemp + " - ","", strTemp);
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+16));			
		 %>
     <td class="thinborder">&nbsp;<%=strTemp%></td>
     <td class="thinborder"><a href='javascript:PreparedToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a><a href='javascript:PreparedToEdit("<%=(String)vRetResult.elementAt(i)%>");'></a><a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/delete.gif" width="55" height="28" border="0"></a></td>
   </tr>
   
   <%}%>
	  <input type="hidden" name="emp_count" value="<%=iCount%>">
 </table>
   <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="20">&nbsp;</td>
    </tr>
  </table>
 <%}} // end else (vRetResult == null)%>
  </label>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>


	<input type="hidden" name="preparedToEdit" value=" <%=WI.getStrValue(strPrepareToEdit,"0")%>">
	<input type="hidden" name="page_action" value="">
	<input type="hidden" name="bTimeIn" value="">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input name="noAdjustment" type="hidden" value="1">
	<input type="hidden" name="info_logged" value="<%=WI.fillTextValue("info_logged")%>">
	<input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
	<input type="hidden" name="late_under_time_val" value="">
	<input type="hidden" name="reloaded" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
