<%@ page language="java" import="utility.*,java.util.Vector,eDTR.FacultyDTR" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(7);	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
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

function CancelEntries() {
		location = "./proctor_scheduling.jsp?login_date="+document.form_.login_date.value;
}

function AddRecord() {
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	//document.form_.hide_save.src = "../../../../images/blank.gif";
	this.SubmitOnce('form_');
}

function DeleteRecord(strInfoIndex) {
	if(!confirm("Continue deleting the schedule?"))
		return;
	document.form_.page_action.value = "0";
	document.form_.print_page.value = "";
	document.form_.info_index.value = strInfoIndex;	
	document.form_.searchEmployee.value = "1";
	//document.form_.hide_save.src = "../../../../images/blank.gif";
	this.SubmitOnce('form_');
}

function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewSchedule(strEmpID) {
	var pgLoc = "set_emp_working_multiple.jsp?viewonly=1&emp_id"+strEmpID;
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage()
{
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
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
		this.setEIP(false);
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
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
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strPrepareToEdit = null;

	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","proctor_scheduling.jsp");
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
														"proctor_scheduling.jsp");	
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","PROCTOR",request.getRemoteAddr(), 
														null);	
}														
														
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
	FacultyDTR WHour = new FacultyDTR(); 
 	Vector vRetResult = null;
	Vector vEmployeeWH = null;
	String[] astrConvertWeekDay= {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};	
	String[] astrConverAMPM = {"AM","PM"};
	if(bolIsSchool)
		 strTemp = "College";
	else
		 strTemp = "Division";
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};	
	int iSearchResult = 0;
	int i = 0;
	Vector vEmpSemSetting  = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	String strOfferingSem = WI.fillTextValue("semester");
	String strOfferingSYFrom = WI.fillTextValue("sy_from");
	String strOfferingSYTo = WI.fillTextValue("sy_to");
	String strLoginDate = WI.fillTextValue("login_date");
	strLoginDate = ConversionTable.convertTOSQLDateFormat(strLoginDate);
	
	String strPageAction = WI.fillTextValue("page_action");

	if(strPageAction.length() > 0){
		if(WHour.operateOnProctorScheduling(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = WHour.getErrMsg();
		} else {
			if(strPageAction.equals("1"))
				strErrMsg = "Successfully posted.";					
		}
	}
	
		vRetResult = WHour.operateOnProctorScheduling(dbOP, request,4);
		if(vRetResult == null){
			if(strPageAction.equals("1"))
				strErrMsg += "<br>";	
			strErrMsg += WI.getStrValue(WHour.getErrMsg());
		}else
			iSearchResult = WHour.getSearchCount();
%>	
<form action="proctor_scheduling.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      WORKING HOURS MGMT - SET PROCTOR SCHEDULE PAGE ::::</strong></font></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr> 
				<td height="23" colspan="5">&nbsp;<a href="./proctor_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
			</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
			  <td height="23">&nbsp;</td>
			  <td height="23">School Year</td>
			  <td height="23"><%
	strOfferingSYFrom = WI.fillTextValue("sy_from");
if(strOfferingSYFrom.length() ==0)
	strOfferingSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
          <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strOfferingSYFrom%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')">
-
<%
strOfferingSYTo = WI.fillTextValue("sy_to");
if(strOfferingSYTo.length() ==0)
	strOfferingSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strOfferingSYTo%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
-
<select name="semester">
  <option value="1">1st Sem</option>
  <%
strOfferingSem = WI.fillTextValue("semester");
if(strOfferingSem.length() ==0)
	strOfferingSem = (String)request.getSession(false).getAttribute("cur_sem");
if(strOfferingSem.compareTo("2") ==0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strOfferingSem.compareTo("3") ==0){%>
  <option value="3" selected>3rd Term</option>
  <%}else{%>
  <option value="3">3rd Term</option>
  <%}if(strOfferingSem.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select>
<input type="button" name="12" value=" Reload " style="font-size:11px; height:24px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();"></td>
	  </tr>
			
			<tr>
			  <td height="23">&nbsp;</td>
			  <td height="23">Subject</td>
				<%
					strTemp = WI.fillTextValue("sub_sec_index");
				%>
			  <td height="23"><select name="sub_sec_index" onChange="SearchEmployee();">
          <option value="">Select Subject</option>
          <%=dbOP.loadCombo("faculty_load.sub_sec_index","section, sub_code", " from faculty_load " +
				" join e_sub_section on (e_sub_section.sub_sec_index = faculty_load.sub_sec_index)" +
				" join subject on (subject.sub_index = e_sub_section.sub_index)" + 
				" where faculty_load.is_valid = 1  and e_sub_section.is_valid = 1 " +
        " and e_sub_section.offering_sy_from = " + strOfferingSYFrom + 
				" and e_sub_section.offering_sy_to = " + strOfferingSYTo + 
				" and e_sub_section.offering_sem = " + strOfferingSem + 
				" and ((subject.fatima_subject_type = 0 and is_lec = 0) or subject.fatima_subject_type > 0 )" +
				//WI.getStrValue(WI.fillTextValue("is_lec"), " and subject.fatima_subject_type = 0 and is_lec = ",""," and subject.fatima_subject_type > 0") +
				
 				" order by section", strTemp, false)%>
        </select></td>
	  </tr>
			<tr> 
				<td width="3%" height="23">&nbsp;</td>
			  <td width="19%" height="23">Date</td>
				<%
					strTemp = WI.fillTextValue("login_date");
				%>
			  <td width="78%" height="23"><input name="login_date" type="text" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" 
	   onBlur="style.backgroundColor='white'; AllowOnlyIntegerExtn('form_','login_date','/');"
	   onKeyUp= "AllowOnlyIntegerExtn('form_','login_date','/')"
	    value="<%=strTemp%>" size="10" maxlength="10">
          <a href="javascript:show_calendar('form_.login_date');"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		  </tr>
			<tr>
			  <td height="23">&nbsp;</td>
			  <td height="23">Time</td>
				<%
					strTemp = WI.fillTextValue("hr_from");
				%>				
			  <td height="23"><input name="hr_from" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
:
  <%
				strTemp = WI.fillTextValue("min_from");
			%>
  <input name="min_from" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
	  <%
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
				strTemp = WI.fillTextValue("hr_to");
			%>
<input name="hr_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
:
<%
				strTemp = WI.fillTextValue("min_to");
			%>
<input name="min_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
			<%
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
			  <td height="23">&nbsp;</td>
			  <td height="23">Employee ID </td>
			  <td height="23"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
		<label id="coa_info" style="position:absolute;width:400px;"></label></td>
	  </tr>
			<tr>
			  <td height="23">&nbsp;</td>
			  <td height="23">Room Number </td>
				<%
					strTemp = WI.fillTextValue("room_index");
				%>
			  <td height="23"><select name="room_index">
          <option value="">Select Room</option>
          <%=dbOP.loadCombo("room_index","location, room_number", " from e_room_detail where is_valid = 1 " +
				" order by location, room_number", strTemp, false)%>
        </select></td>
	  </tr>
	</table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%if(strSchCode.startsWith("FATIMA")){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("invalidate_existing");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td height="10" colspan="3"><input type="checkbox" name="invalidate_existing" value="1" <%=strTemp%>>
      auto invalidate existing records </td>
    </tr>
		<%}%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="10">&nbsp;</td>
      <td width="19%" height="10">&nbsp;</td>
      <td width="78%" height="10" colspan="3"><font size="1">
      <%if(iAccessLevel > 1) {%>
        <input type="button" name="12" value=" Save " style="font-size:11px; height:24px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
				click to save entries
      <%}%>
				<input type="button" name="122" value=" Cancel " style="font-size:11px; height:24px;border: 1px solid #FF0000;" onClick="javascript:CancelEntries();">
        click to remove entries </font></td>
    </tr>
  </table> 
	<%if(vRetResult != null && vRetResult.size() > 0){%>
<% 
	if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/WHour.defSearchSize;		
	if(iSearchResult % WHour.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="right"><font size="2">Jump To page:
        <select name="jumpto" onChange="SearchEmployee();">
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
<%}
}%>	
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="8" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES WITH PROCTOR SCHEDULE</strong></td>
    </tr>
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="6%" class="thinborder">&nbsp;</td> 
      <td width="34%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="23%" align="center" class="thinborder"><strong><font size="1">TIME</font></strong></td>
			<td width="12%" align="center" class="thinborder"><strong><font size="1">ROOM</font></strong></td>
			<td width="14%" align="center" class="thinborder"><strong><font size="1">SUBJECT</font></strong></td>
			<!--
      <td width="8%" align="center" class="thinborder">&nbsp;</td>
			-->
      <td width="8%" align="center" class="thinborder">DELETE</td>
    </tr>
    
    <% 	int iCount = 1;
	   for (i = 0; i < vRetResult.size(); i+=30,iCount++){
		 %>
    <tr>
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
							(String)vRetResult.elementAt(i+5), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="user_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
 <%
			strTemp = (String)vRetResult.elementAt(i + 7);		
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+8),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" +astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+9))];
			
			// time to here
			strTemp += " - " + (String)vRetResult.elementAt(i + 10);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+11),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+12))];
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+22)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+25),"&nbsp;")%></td>
      <!--
			<td align="center" class="thinborder"><strong><a href="javascript:ViewSchedule('<%=(String)vRetResult.elementAt(i+1)%>');"><img src="../../../../images/view.gif" width="40" height="31" border="0"></a></strong></td>
			-->
      <td align="center" class="thinborder">
			<input type="button" name="122" value=" Delete " 
			style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
			onClick="javascript:DeleteRecord(<%=vRetResult.elementAt(i)%>);"></td>
    </tr>
    <%} //end for loop%>
    
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>	
	<%}// end if vRetResult != null%>
<!-- here lies the great mysteries of and future-->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25"s>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee" > 
	<input type="hidden" name="info_index">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
