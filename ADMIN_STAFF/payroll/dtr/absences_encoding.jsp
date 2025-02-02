<%@ page language="java" import="utility.*,payroll.PReDTRME,java.util.Vector" buffer="16kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty/ non-Dtr Employee absences encoding</title>
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function CheckValidHour() {
	var vTime =document.form_.time_from_hr.value
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_from_hr.value = "12";
	}
	vTime =document.form_.time_to_hr.value
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_to_hr.value = "12";
	}
}
function CheckValidMin() {
	if(eval(document.form_.time_from_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_from_min.value = "00";
	}
	if(eval(document.form_.time_to_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_to_min.value = "00";
	}
}

function ReloadPage() {
	this.SubmitOnce('form_');
}

//function SelectSched(){
//	document.form_.PageReloaded.value = "1";
//	this.SubmitOnce('form_');
//}

function SelectSched(){
	var selectedIndex = document.form_.schedule.selectedIndex;	
	if(selectedIndex == 0){
		document.form_.time_from_hr.value = "";
		document.form_.time_from_min.value = "";
		document.form_.time_from_AMPM.value = "";
		document.form_.time_to_hr.value = "";
		document.form_.time_to_min.value = "";
		document.form_.time_to_AMPM.value = "";
		return;
	}
	document.form_.time_from_hr.value = eval('document.form_.time_from_hr_'+selectedIndex+'.value');	
	document.form_.time_from_min.value = eval('document.form_.time_from_min_'+selectedIndex+'.value');
	document.form_.time_from_AMPM.value = eval('document.form_.time_from_AMPM_'+selectedIndex+'.value');
	document.form_.time_to_hr.value = eval('document.form_.time_to_hr_'+selectedIndex+'.value');
	document.form_.time_to_min.value = eval('document.form_.time_to_min_'+selectedIndex+'.value');
	document.form_.time_to_AMPM.value = eval('document.form_.time_to_AMPM_'+selectedIndex+'.value');	
}

function CancelRecord(){
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1)
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}

function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
	document.form_.emp_id.focus();
}

function ViewAll() {
	document.form_.view_all.value = "1";
	this.ReloadPage();
}

function PrintPg() {
	var strPrintCheckList = "";	
	if(document.form_.print_checklist && document.form_.print_checklist.checked)
		strPrintCheckList = "&print_checklist=1";
	
	var pgLoc = "./absences_encoding_print.jsp?emp_id="+escape(document.form_.emp_id.value)+
	"&view_all=<%=request.getParameter("view_all")%>"+strPrintCheckList;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CopyID(strID)
{
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

}
function ToggleReadOnly(){
	if(document.form_.no_specific.checked)
		document.form_.duration.disabled = false;
	else{
		document.form_.duration.value = "";
		document.form_.duration.disabled = true;
	}
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-DTR"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-ENCODE-FACULTY ABSENCES"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Encoding of Absences","absences_encoding.jsp");
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
	Vector vEditInfo  = null;
	Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");//System.out.println("Info Index :: "+request.getParameter("info_index"));
	if(strTemp.length() > 0) {
		if(prEdtrME.operateOnAbsenceEncoding(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prEdtrME.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Absence information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Absence information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Absence information successfully removed.";
		}
	}

//get vEditInfo If it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = prEdtrME.operateOnAbsenceEncoding(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = prEdtrME.getErrMsg();
}

enrollment.FacultyManagementExtn fm = new enrollment.FacultyManagementExtn();
enrollment.FacultyManagement FM = new enrollment.FacultyManagement();
payroll.PRMiscDeduction prd = new payroll.PRMiscDeduction(request);
Vector vPersonalDetails = new Vector();
Vector vFacLoadDetail = null;
Vector vFacSchedule = null;
Vector vTimeDetails = null;
Vector vEmpList = null;
String strEmpID = WI.fillTextValue("emp_id");
String strMaxLoad =  fm.getFacMaxLoad(dbOP,request);
String[] astrConvSem = {"Summer", "1st", "2nd", "3rd"};
String strSem = WI.fillTextValue("semester");
String strSubjectIndex = WI.fillTextValue("schedule");

if (strEmpID.length() > 0) {
	enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vPersonalDetails == null){
		strErrMsg = "No record for employee " + WI.fillTextValue("emp_id");
	}else{
		if(bolIsSchool){
			vFacLoadDetail = FM.viewFacultyLoadSummary(dbOP,(String)vPersonalDetails.elementAt(0), WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
											 WI.fillTextValue("semester"));
	//		vFacLoadDetail = prEdtrME.viewFacultyLoadDetail(dbOP,(String)vPersonalDetails.elementAt(0), WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
	//						WI.fillTextValue("semester"));
			if(vFacLoadDetail == null)
				strErrMsg = "No schedule found for employee";
			if (vFacLoadDetail != null && vFacLoadDetail.size() > 0)
			vFacSchedule = prEdtrME.viewFacultySchedule(dbOP,(String)vPersonalDetails.elementAt(0), WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
						WI.fillTextValue("semester"));
			vTimeDetails = prEdtrME.getSubTimeDetails(dbOP,(String)vPersonalDetails.elementAt(0), WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
										 WI.fillTextValue("semester"));
		}
									
		vRetResult  = prEdtrME.operateOnAbsenceEncoding(dbOP, request,4);
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = prEdtrME.getErrMsg();
		vEmpList = prd.getEmployeesList(dbOP);
	}

}//System.out.println(vPersonalDetails);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsVMUF = strSchCode.startsWith("VMUF");
%>
<form name="form_" action="./absences_encoding.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      ABSENCES FOR 
        <%if(bolIsSchool){%>
        FACULTIES/
        <%}%>
      NON-DTR EMPLOYEES PAGE ::::</strong></font></td>
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
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr >
      <td  width="2%" height="25">&nbsp;</td>
      <td width="14%">Employee ID</td>
      <td width="19%"> <input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"></td>
      <td width="65%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a><font size="1">click
        to search &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <!--
		<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
		-->
		<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onClick="javascript:ReloadPage();">
		</font><label id="coa_info"></label></td>
    </tr>
<%if(bolIsSchool){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td>School Year</td>
      <td height="25" colspan="2">
	  <%
	strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
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
<%}%>
    <tr >
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
  </table>
 <%
if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
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
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</td>
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
  </table>
	<%if(bolIsSchool){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFF99">
      <td>&nbsp;</td>
      <td height="25" colspan="7" align="center"><strong>::: CURRENT WORKING
      HOURS/SCHEDULE :::</strong></td>
    </tr>
    <tr>
      <td width="0%" height="25">&nbsp;</td>
      <td height="25" valign="bottom">&nbsp;</td>
      <td colspan="4" valign="bottom">&nbsp;</td>
      <td width="44%" valign="bottom">Current Load: <strong>
        <%
	   	vPersonalDetails = FM.viewFacultyDetail(dbOP, (String)vPersonalDetails.elementAt(0), WI.fillTextValue("sy_from"),
				WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
		if(vPersonalDetails != null && vPersonalDetails.size() > 0) {%>
        	<%=WI.getStrValue((String)vPersonalDetails.elementAt(6),"0")%>
	        <%}else{%>
    	    0
        	<%}%>
        </strong></td>
    </tr>
  </table>	
<%
if(vFacLoadDetail != null && vFacLoadDetail.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="11%" height="25" align="center" class="thinborder"><font size="1"><strong>SECTION
      </strong></font></td>
      <td width="25%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong>ROOM
      #</strong></font></td>
    </tr>
    <%for(int i = 0 ; i < vFacLoadDetail.size() ; i +=9){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vFacLoadDetail.elementAt(i + 4)%></td>
      <td align="right" class="thinborder"><%=(String)vFacLoadDetail.elementAt(i + 6)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vFacLoadDetail.elementAt(i + 5),"Not Set")%></td>
    </tr>
    <%}%>
  </table>
<%}%>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="9%" height="25">&nbsp;</td>
      <td width="11%">Date</td>
      <td> <%
	  if (vEditInfo != null && vEditInfo.size() > 0){
		  strTemp = (String) vEditInfo.elementAt(1);
	  }else{
		  strTemp = WI.fillTextValue("date_absent");
		  if(strTemp.length() ==0)
			strTemp = WI.getTodaysDate(1);
	  }
	  %> <input name="date_absent" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_absent');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      </td>
    </tr>
		<%if(bolIsSchool){%>
	    <tr>
      <td height="25">&nbsp;</td>
      <%
			for(int i = 0;(vTimeDetails != null) &&  i < vTimeDetails.size();i+=6){%>
          <input type="hidden" name="time_from_hr_<%=(i+6)/6%>" value="<%=vTimeDetails.elementAt(i)%>">
          <input type="hidden" name="time_from_min_<%=(i+6)/6%>" value="<%=vTimeDetails.elementAt(i+1)%>">
          <input type="hidden" name="time_from_AMPM_<%=(i+6)/6%>" value="<%=vTimeDetails.elementAt(i+2)%>">
          <input type="hidden" name="time_to_hr_<%=(i+6)/6%>" value="<%=vTimeDetails.elementAt(i+3)%>">
          <input type="hidden" name="time_to_min_<%=(i+6)/6%>" value="<%=vTimeDetails.elementAt(i+4)%>">
          <input type="hidden" name="time_to_AMPM_<%=(i+6)/6%>" value="<%=vTimeDetails.elementAt(i+5)%>">
      <%}%>			
      <td>Time</td>
      <td>
	  <%
		  if (vEditInfo != null && vEditInfo.size() > 0){
			  strTemp = (String)vEditInfo.elementAt(12);
		  }else{
			  strTemp = WI.fillTextValue("schedule");
		  }
	  	strTemp = WI.getStrValue(strTemp,"0");
		//System.out.println("schedule " +strTemp);
	  %>

	  <% if(vFacSchedule != null && vFacSchedule.size() > 0) {%>
	  <select name="schedule" onChange="SelectSched();">
          <option value=""> (Select time schedule) </option>
      <%for(int i = 0 ; i < vFacSchedule.size() ; i +=3){
		  if (strTemp.equals((String)vFacSchedule.elementAt(i))){%>
          <option value="<%=(String)vFacSchedule.elementAt(i)%>" selected><%=(String)vFacSchedule.elementAt(i + 1) + " (" + (String)vFacSchedule.elementAt(i + 2) + ")"%></option>
		  <%}else{%>
		  <option value="<%=(String)vFacSchedule.elementAt(i)%>"><%=(String)vFacSchedule.elementAt(i + 1)+ " (" + (String)vFacSchedule.elementAt(i + 2) + ")"%></option>
          <%}
	  }%>
        </select>
	<%}%></td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Time</td>
      <td width="80%">
	  <%
		  if (vEditInfo != null && vEditInfo.size() > 0){
			  strTemp = (String) vEditInfo.elementAt(3);
		  }else{
			  strTemp = WI.fillTextValue("time_from_hr");
		  }
	  %>
	  <input type="text" name="time_from_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onblur="AllowOnlyInteger('form_','time_from_hr');style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp,"")%>"
	  onKeyUp="AllowOnlyInteger('form_','time_from_hr');CheckValidHour();">
        :
        <%
		  if (vEditInfo != null && vEditInfo.size() > 0){
			  strTemp = (String) vEditInfo.elementAt(4);
		  }else{
			  strTemp = WI.fillTextValue("time_from_min");
		  }
			strTemp = CommonUtil.formatMinute(strTemp);
	  %> <input type="text" name="time_from_min" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','time_from_min');style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp,"")%>"
	  onKeyUp="AllowOnlyInteger('form_','time_from_min');CheckValidMin();">
        :
        <select name="time_from_AMPM">
	      <%
			  if (vEditInfo != null && vEditInfo.size() > 0){
				  strTemp = (String) vEditInfo.elementAt(5);
			  }else{
				  strTemp = WI.fillTextValue("time_from_AMPM");
			  }
		  	strTemp = WI.getStrValue(strTemp,"0");
		  %>
          	<option selected value="0">AM</option>
		  <%if(strTemp.equals("1")){%>
          	<option value="1" selected>PM</option>
          <%}else{%>
          	<option value="1">PM</option>
          <%}%>
        </select>
        to
        <%
		  if (vEditInfo != null && vEditInfo.size() > 0){
			  strTemp = (String) vEditInfo.elementAt(6);
		  }else{
			  strTemp = WI.fillTextValue("time_to_hr");
		  }
	  %> <input type="text" name="time_to_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp,"")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour();">
        :
        <%
		  if (vEditInfo != null && vEditInfo.size() > 0){
			  strTemp = (String) vEditInfo.elementAt(7);
		  }else{
			  strTemp = WI.fillTextValue("time_to_min");
		  }
			strTemp = CommonUtil.formatMinute(strTemp);
	  %> <input type="text" name="time_to_min"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp,"")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin();">
        :
        <select name="time_to_AMPM">
          <option selected value="0">AM</option>
          <%
			  if (vEditInfo != null && vEditInfo.size() > 0){
				  strTemp = (String) vEditInfo.elementAt(8);
			  }else{
				  strTemp = WI.fillTextValue("time_to_AMPM");
			  }
		  strTemp = WI.getStrValue(strTemp,"0");
		  if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
      </select></td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><%
	    if (vEditInfo != null && vEditInfo.size() > 0){
		  strTemp = (String) vEditInfo.elementAt(9);
	    }else{
		  strTemp = WI.fillTextValue("no_specific");
	    }
		if(strTemp.equals("1"))
			strTemp = " checked";
		else
			strTemp = "";
	   %>
        <input type="checkbox" name="no_specific" value="1"<%=strTemp%> onClick="ToggleReadOnly();">
Tick if no specific time or Non-DTR</td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Duration</td>
      <td height="25">
	  <%
	  	if (vEditInfo != null && vEditInfo.size() > 0){
		  strTemp = (String) vEditInfo.elementAt(2);
	    }else{
		  strTemp = WI.fillTextValue("duration");
	    }
	  %>
	  <input type="text" name="duration" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onblur="AllowOnlyFloat('form_','duration');style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp,"")%>"
	  onKeyUp="AllowOnlyFloat('form_','duration');">
	  (in minutes)	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Remarks</td>
      <td height="25"> <select name="remark">
          <option value="0">With leave application</option>
          <%
			if (vEditInfo != null && vEditInfo.size() > 0){
			  strTemp = (String) vEditInfo.elementAt(10);
			}else{
			  strTemp = WI.fillTextValue("remark");
			}
	  if(strTemp.equals("1")) {%>
          <option value="1" selected>Without leave application</option>
          <%}else{%>
          <option value="1">Without leave application</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>Leave Application will be filed later</option>
          <%}else{%>
          <option value="2">Leave Application will be filed later</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
			<%
		   if (vEditInfo != null && vEditInfo.size() > 0){
			  strTemp = (String) vEditInfo.elementAt(13);
		   }else{
			  strTemp = WI.fillTextValue("is_deducted");
		   }

			if(strTemp.equals("1"))
				strTemp = " checked";
			else
				strTemp = "";
	   %>
        <input type="checkbox" name="is_deducted" value="1"<%=strTemp%>>
		<font style="font-weight:bold; font-size:11px; color:#0000FF"> Deduct from salary</font>		 </td>
    </tr>
<%
if(bolIsVMUF){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  <select name="on_board" style="font-size:10px;">
	  <option value="2">N/A</option>
<%
if (vEditInfo != null && vEditInfo.size() > 0)
  strTemp = (String) vEditInfo.elementAt(14);
else
  strTemp = WI.fillTextValue("on_board");

if(strTemp.equals("1"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
if(strTemp.equals("0"))
	strTemp = " selected";
else	
	strTemp = "";
%>
	  <option value="1" <%=strErrMsg%>>Yes</option>
	  <option value="0" <%=strTemp%>>No</option>
	  </select> 
	  On Post 
	  <select name="clear_board" style="font-size:10px;">
	  <option value="2">N/A</option>
<%
if (vEditInfo != null && vEditInfo.size() > 0)
  strTemp = (String) vEditInfo.elementAt(15);
else
  strTemp = WI.fillTextValue("clear_board");

if(strTemp.equals("1"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
if(strTemp.equals("0"))
	strTemp = " selected";
else	
	strTemp = "";
%>
	  <option value="1" <%=strErrMsg%>>Yes</option>
	  <option value="0" <%=strTemp%>>No</option>
	  </select> Clear Board 
	  <select name="in_uniform" style="font-size:10px;">
	  <option value="2">N/A</option>
<%
if (vEditInfo != null && vEditInfo.size() > 0)
  strTemp = (String) vEditInfo.elementAt(16);
else
  strTemp = WI.fillTextValue("in_uniform");

if(strTemp.equals("1"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
if(strTemp.equals("0"))
	strTemp = " selected";
else	
	strTemp = "";
%>
	  <option value="1" <%=strErrMsg%>>Yes</option>
	  <option value="0" <%=strTemp%>>No</option>
	  </select> In-Uniform 
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Room Number : 
<%
if (vEditInfo != null && vEditInfo.size() > 0)
  strTemp = (String) vEditInfo.elementAt(18);
else
  strTemp = WI.fillTextValue("room_no");
%>
	  <input type="text" name="room_no" size="12" maxlength="12" class="textbox" style="font-size:11px"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>">
<%
if (vEditInfo != null && vEditInfo.size() > 0)
  strTemp = (String) vEditInfo.elementAt(19);
else
  strTemp = WI.fillTextValue("subject_code");
%>
	  Subjct Code :  <input type="text" name="subject_code" size="12" maxlength="12" class="textbox" style="font-size:11px"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>">
	  <font size="1">&nbsp;(NOTE : Max 12 Chars)</font>
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Reason</td>
      <td>
<%
if (vEditInfo != null && vEditInfo.size() > 0)
  strTemp = (String) vEditInfo.elementAt(17);
else
  strTemp = WI.fillTextValue("reason");
%>
	  <input type="text" name="reason" size="80" maxlength="128" class="textbox" style="font-size:11px"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>">
	  </td>
    </tr>
    <tr>
      <td height="38" colspan="3" align="center">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <%if(iAccessLevel > 1) {%>
        <!--
          <a href='javascript:PageAction(1, "");'> <img src="../../../images/save.gif" border="0" id="hide_save"></a>					
					-->
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        <font size="1">click to save entries</font>
        <%}%>
        <%}else{%>
        <!--
					<a href='javascript:PageAction(2,"");'> <img src="../../../images/edit.gif" border="0"></a>
					-->
        <input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2', '');">
        <font size="1">Click to save changes</font>
        <%}%>
        <!--
					<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
					-->
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">					
        <font size="1"> click to cancel or go previous</font> </td>
    </tr>
    <tr>
      <td height="10" colspan="3"><font size="1">
        <div align="right"> <a href="javascript:ViewAll();"><img src="../../../images/view.gif" border="0"></a>click
          to view complete absences&nbsp;&nbsp;&nbsp; <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>click
          to print table
		  <%if(strSchCode.startsWith("VMUF")){%>
		  <input type="checkbox" value="1" name="print_checklist"><font style="color:#0000FF; font-weight:600"> Print Check list</font>
		  <%}%>
		  </div>
        </font></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<%if (WI.fillTextValue("view_all").equals("1")){%>
		<tr bgcolor="#FFFF99">
		  <td height="25" colspan="11" align="center" class="thinborder">LIST OF ALL ABSENCES</td>
		</tr>
	<%}else{%>
		<tr bgcolor="#FFFF99">
		  <td height="25" colspan="11" align="center" class="thinborder">LIST OF ABSENCES NOT YET DEDUCTED FROM SALARY</td>
		</tr>
	<%}%>
    <tr>
      <td height="26" colspan="11" class="thinborder">TOTAL : <%=(String)vRetResult.remove(0)%> </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="10%" height="25" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">Date</td>
      <td width="20%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">Time ::: Duration</td>
      <td width="15%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">Remarks</td>
      <td width="15%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">Reason</td>
<%if(bolIsVMUF){%>
      <td width="5%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">Room No</td>
      <td width="5%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">Subject</td>
      <td width="5%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">On Post</td>
      <td width="5%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">Clean Board</td>
      <td width="5%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">In-Uniform</td>
<%}%>
      <td colspan="2" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">Options</td>
    </tr>
<%
String[] astrConvertAMPM = {"AM","PM"};
String[] astrConvertRemark = {"With leave application","Without leave application","Leave Application will be filed later"};
String[] astrConvertSelection = {"No","Yes","N/A"};

for(int i = 0; i < vRetResult.size(); i += 20){
%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"> 
			<%if(vRetResult.elementAt(i + 3) != null && vRetResult.elementAt(i + 6) != null){%> 
				<%=(String)vRetResult.elementAt(i + 3)+ ":" + 
					 CommonUtil.formatMinute((String)vRetResult.elementAt(i + 4)) + " " + 
					 astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i + 5))]+ " - " +
			     (String)vRetResult.elementAt(i + 6)+ ":" + 
					 CommonUtil.formatMinute((String)vRetResult.elementAt(i + 7)) + " "  +
					 astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i + 8))]+" ::: "%> 
			<%}%> 
				<%=(String)vRetResult.elementAt(i + 2)%> min(s) </td>
			<%
				strTemp = (String)vRetResult.elementAt(i + 10);
				if(strTemp == null || strTemp.length() == 0){
					strTemp = "";
				}else{
					strTemp = WI.getStrValue(strTemp, "1");
					strTemp = astrConvertRemark[Integer.parseInt(strTemp)];
				}
			%>	
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 17), "&nbsp;")%></td>
<%if(bolIsVMUF){%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 18), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 19), "&nbsp;")%></td>
      <td class="thinborder"><%=astrConvertSelection[Integer.parseInt((String)vRetResult.elementAt(i + 14))]%></td>
      <td class="thinborder"><%=astrConvertSelection[Integer.parseInt((String)vRetResult.elementAt(i + 15))]%></td>
      <td class="thinborder"><%=astrConvertSelection[Integer.parseInt((String)vRetResult.elementAt(i + 16))]%></td>
<%}%>
      <td width="7%" align="center" class="thinborder"><div align="center">
          <% if (iAccessLevel > 1 && ((String)vRetResult.elementAt(i)).equals("0")) {%>
          <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i+ 11)%>);'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
          <%}else{%>
          NA
          <%}%>
        </div></td>
      <td width="8%" align="center" class="thinborder">
        <% if ((iAccessLevel == 2) && ((String)vRetResult.elementAt(i)).equals("0")){%>
        <a href="javascript:PageAction(0,'<%=(String)vRetResult.elementAt(i + 11)%>')"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}else{%>
        NA
        <%}%>      </td>
    </tr>
    <%}%>
  </table>
<%}//if vRetResult is not null.

}//show only if personal detail is found."
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
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>