<%@ page language="java" import="utility.*,payroll.PReDTRME, eDTR.MultipleWorkingHour,java.util.Vector" buffer="16kb"%>
<%
WebInterface WI = new WebInterface(request);
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
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage() {
	this.SubmitOnce('form_');
}

function CancelRecord(){
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}

function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.update.disabled = true;
		//document.form_.hide_save.src = "../../../../images/blank.gif";
	this.SubmitOnce('form_');
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
	document.form_.emp_id.focus();
}

function CopyID(strID){
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

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
function checkAllSave() {
	var maxDisp = document.form_.sched_count.value;
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

function ajaxLoadSchedule() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("fac_schedule");
		var vJumpTo = document.form_.jumpto.value;
		
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=602&jumpto="+vJumpTo+
								 "&emp_id="+strCompleteName;

		this.processRequest(strURL);
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

<body bgcolor="#D2AE72" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strAmPm = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record-WORKING HOURS MGMT".toUpperCase()),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record".toUpperCase()),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
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
								"Admin/staff-Payroll-DTR-Encoding of Absences","batch_faculty_update.jsp");
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

	PReDTRME prEdtrME = new PReDTRME();
	Vector vRetResult = null;
	payroll.PRMiscDeduction prd = new payroll.PRMiscDeduction(request);
	String strTemp2  = null;
	String[] astrConverAMPM = {"AM","PM"};
	
	Vector vPersonalDetails = new Vector();
	Vector vFacSchedule = null;	
	
	Vector vEmpList = null;
	String strEmpID = WI.fillTextValue("emp_id");
	String[] astrConvSem = {"Summer", "1st", "2nd", "3rd"};
	String strSem = WI.fillTextValue("semester");
	String strSYFrom = null;
	String strEmpIndex = null;
	String[] astrWeekDay = {"SUN","MON","TUE","WED","THU","FRI","SAT"};
	
	MultipleWorkingHour mWHour = new MultipleWorkingHour();
	int iSearchResult = 0;
	int i = 0;
	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		vFacSchedule = mWHour.operateOnCreatedFacultySchedules(dbOP, request, Integer.parseInt(strPageAction));
		if(vFacSchedule == null)
			strErrMsg = mWHour.getErrMsg();
		else{
			strErrMsg = "Operation Successful";
		}
	}

	if (strEmpID.length() > 0) {
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
 		//strEmpIndex
		if(vPersonalDetails == null){
			strErrMsg = "No record for employee " + WI.fillTextValue("emp_id");
		}else{
			vFacSchedule = mWHour.operateOnCreatedFacultySchedules(dbOP, request, 4);
 			vEmpList = prd.getEmployeesList(dbOP);
			strEmpIndex = (String)vPersonalDetails.elementAt(0);
		}
	}//System.out.println(vPersonalDetails);

 	vRetResult = mWHour.operateOnEmpMultipleLogs(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = mWHour.getErrMsg();
	else
		iSearchResult = mWHour.getSearchCount();
		
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form name="form_" action="./batch_faculty_update.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      FACULTY WORKING HOURS ::::</strong></font></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="4" align="right"><%
	  		if (vEmpList != null && vEmpList.size() > 0){
			  %>
        <%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.indexOf((String)vEmpList.elementAt(0))){%>
        <a href="javascript:CopyID('<%=vEmpList.elementAt(0)%>');">FIRST</a>
        <%}else{%>
FIRST
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) > 0){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) - 1)%>');"> PREVIOUS</a>
<%}else{%>
PREVIOUS
<%}%>
<%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) < vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) + 1)%>');"> NEXT</a>
<%}else{%>
NEXT
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=((String)vEmpList.elementAt(vEmpList.size()-1)).toUpperCase()%>');">LAST</a>
<%}else{%>
LAST
<%}%>
<%}// if (vEmpList != null && vEmpList.size() > 0)%></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="3"><font size="3"><b><a href="./working_hour_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr >
      <td  width="2%" height="25">&nbsp;</td>
      <td width="14%">Employee ID</td>
      <td width="19%"> <input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"></td>
      <td width="65%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a><font size="1">click
        to search &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <!--
		<a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" border="0"></a>
		-->
		<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onClick="javascript:ReloadPage();">
		</font><label id="coa_info"></label></td>
    </tr>
     <tr >
      <td height="25">&nbsp;</td>
      <td>School Year</td>
      <td height="25" colspan="2">
	  <%
	strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')">
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
     <tr >
      <td height="12" colspan="4"><hr size="1"></td>
    </tr>
  </table>
 <% if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Employee Name</td>
      <td width="24%"> &nbsp;<strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
      <td width="19%">Employment Status</td>
      <td width="35%">&nbsp;<strong><%=WI.getStrValue((String)vPersonalDetails.elementAt(16),"")%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>College/Office</td>
      <td>&nbsp;<strong>
        <%if(vPersonalDetails.elementAt(13) != null){%>
        <%=(String)vPersonalDetails.elementAt(13)%> ;
        <%}if(vPersonalDetails.elementAt(14) != null){%>
        <%=(String)vPersonalDetails.elementAt(14)%>
        <%}%>
        </strong></td>
      <td>Employment Type</td>
      <td>&nbsp;<strong><%=WI.getStrValue((String)vPersonalDetails.elementAt(15),"")%></strong></td>
    </tr>
    <tr >
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
  </table>

   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFF99">
      <td height="25" colspan="7" align="center"><strong>::: CURRENT WORKING
      HOURS/SCHEDULE :::</strong></td>
    </tr>
  </table>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td><%if(vRetResult != null && vRetResult.size() > 0){%>
	<div onClick="showBranch('branch4');swapFolder('folder4')">
		<img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder4">
		<b><font color="#0000FF">View valid schedules </font></b></div>
	<span class="branch" id="branch4">
    <% 
	int iPageCount = iSearchResult/mWHour.defSearchSize;		
	if(iSearchResult % mWHour.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
<table  bgcolor="#FFFFFF" width="95%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="right"><font size="2">Jump To page:
        <select name="jumpto" onChange="ajaxLoadSchedule();">
      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%
					}
			}
			%>
        </select>
    </font></td>
  </tr>
</table>
<%}%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td align="center">&nbsp; </td>
  </tr>
  <tr>
    <td>
		<label id="fac_schedule" style="position:fixed">
		<table  bgcolor="#FFFFFF" width="75%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="3" align="center" bgcolor="#B9B292" class="thinborder">LIST OF 
      CURRENT WORKING HOURS FOR ID : <%=WI.fillTextValue("emp_id")%></td>
    </tr>
    <tr> 
      <td width="25%" height="26" align="center" class="thinborder"><strong>LOGIN  
      DATE </strong></td>
      <td width="50%" align="center" class="thinborder"><strong>TIME</strong></td>
	    <td width="25%" align="center" class="thinborder"><strong>ROOM NO </strong></td>
    </tr>
<%
 for(i = 0; i < vRetResult.size(); i += 25){%>
   <tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 2))%></td>
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
      <td class="thinborder">
			<%if((String)vRetResult.elementAt(i+17) != null){%>
			<%=astrWeekDay[Integer.parseInt((String)vRetResult.elementAt(i+17))]%>&nbsp;
			<%}%>
			<%=strTemp%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 16),"&nbsp;")%></td>
    </tr>
	<%}%>
  </table>
	</label>
	</td>
  </tr>
</table>
	</span>
	<%}%></td>
  </tr>
</table>

   <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
		  <td width="13%">Subject</td>
			<%
				strTemp = WI.fillTextValue("sub_index");
			%>
		  <td width="87%"><select name="sub_index">
        <option value="">N/A</option>
        <%=dbOP.loadCombo("sub_index","sub_code", " from subject where is_del = 0 " +
													" and exists(select * from e_sub_section " +
													" join faculty_load on(e_sub_section.sub_sec_index = faculty_load.sub_sec_index) " +
													" where e_sub_section.sub_index = subject.sub_index " +
													" and user_index = "+ strEmpIndex+")", 
													strTemp,false)%>
      </select></td>
	   </tr>
		<tr>
		  <td>Section</td>			
			<%
				strTemp = WI.fillTextValue("sub_sec_index");
			%>
		  <td><select name="sub_sec_index">
        <option value="">N/A</option>
				<%=mWHour.getSubjectSections(dbOP, request, strEmpIndex)%>
      </select></td>
	   </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	   </tr>
		<tr>
		  <td>Week day </td>
			<%				
				Vector vSelected = null;
				String strSelected = null;
			  String[] astrSelected = request.getParameterValues("week_days");
				 if (astrSelected != null && astrSelected.length > 0) {
					 vSelected = new Vector();
					 for (i = 0; i < astrSelected.length; i++)
						 vSelected.addElement(astrSelected[i]);
				 }
				if(request.getParameterValues("week_days") == null || astrSelected[0].length() == 0)
					strTemp = "selected";
				else
					strTemp = "";
			%>			
			
		  <td><select name="week_days" multiple size="5">
				<option value="">N/A</option>
				<%for(i = 0; i < astrWeekDay.length;i++){
				 strSelected = "";
				 if (vSelected != null && vSelected.size() > 0) {
					 if (vSelected.indexOf(Integer.toString(i)) != -1)
						 strSelected = "selected";
				 }
				%>
				  <option value="<%=i%>" <%=strSelected%>><%=astrWeekDay[i]%></option>				
				<%}%>
      </select>
		  To select multiple weekdays, hold CTRL key and select the weekdays. </td>
	   </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	   </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td><font size="1">
		    <input type="button" name="proceed_btn2" value=" Proceed " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onClick="javascript:ReloadPage();">
		  </font></td>
	   </tr>
		<tr>
		  <td height="18" colspan="2">&nbsp;</td>
	   </tr>	
	</table>	
	<%if(vFacSchedule != null && vFacSchedule.size() > 0) {%>		
   <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		 	
		<tr>
		  <td height="23" colspan="2" align="center"><table width="80%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
        <tr>
          <td width="18%" height="25" align="center" class="thinborder"><font size="1"><strong>SECTION </strong></font></td>
          <td width="27%" align="center" class="thinborder"><font size="1"><strong>ROOM NUMBER </strong></font></td>
          <td width="35%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
          <td width="20%" align="center" class="thinborder"><font size="1"><strong>REMOVE SCHEDULE<br>
                  <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
          </strong></font></td>
        </tr>
        <%
		int iCount = 1;
		for(i = 0 ; i < vFacSchedule.size() ; i +=20, iCount++){%>
        <tr>
          <input type="hidden" name="cur_day_<%=iCount%>" value="<%=vFacSchedule.elementAt(i)%>">
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
          <td align="center" class="thinborder"><input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1" <%=strTemp%>></td>
        </tr>
        <%}%>
        <input type="hidden" name="sched_count" value="<%=iCount%>">
      </table></td>
	   </tr>
		<tr>
		  <td height="23" colspan="2">Note : Only schedules that are after the current date will be removed.</td>
	  </tr>
	</table>	
   <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="38" colspan="3" align="center"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
		  <td width="18%">Date option</td>
			<%
				strTemp = WI.fillTextValue("date_opt");
			%>
		  <td width="82%">
			<select name="date_opt" onChange="ReloadPage();">
				<option value="0">All after this day</option>
				<%if(strTemp.equals("1")){%>
				<option value="1" selected>Date Range</option>
				<%}else{%>
				<option value="1">Date Range</option>
				<%}%>
			</select>			</td>
	  </tr>
		<%if(strTemp.equals("1")){%>
		<tr>
			<td ><span class="fontsize11">Date</span></td>
			<td><input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a> to
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<%}%>
      </table></td>
    </tr>
    <tr>
      <td height="23" colspan="3" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td width="100%" height="38" colspan="3" align="center">
        <%if(iAccessLevel > 1) {%>
        <!--
          <a href='javascript:PageAction(1, "");'> <img src="../../../../images/save.gif" border="0" id="hide_save"></a>					
					-->
        <input type="button" name="update" value=" Update " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('0','');">
        <font size="1">click to delete entries</font>
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
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp; </td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>



<input type="hidden" name="view_all">
<input type="hidden" name="page_action">
<input type="hidden" name="PageReloaded">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>