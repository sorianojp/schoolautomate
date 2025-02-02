<%@ page language="java" import="utility.*,health.RecordHealthInformation,java.util.Vector " %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
.style1 {color: #FF0000}
</style>
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">
function ViewDetails(strInfoIndex){
	var pgLoc = "./dental_record_details.jsp?dental_record_index="+strInfoIndex;
	var win=window.open(pgLoc,"ViewDetails",'width=1000,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function updatePhysicians(){
	var pgLoc = "../clinic_visit_log/accredited_physicians_mgmt.jsp?is_forwarded=1";
	var win=window.open(pgLoc,"updatePhysicians",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function DeleteRecord(strInfoIndex){
	if(!confirm("Are you sure you want to delete this dental record?"))
		return;
	document.form_.page_action.value = "0";
	document.form_.delete_index.value = strInfoIndex;
	document.form_.submit();
}
function FocusID() {
	document.form_.stud_id.focus();
}
function ReloadPage() {
	document.form_.reload_page.value = "1";
	document.form_.page_action.value = "";
	document.form_.submit();
}
function UpdateRecord(){
	document.form_.page_action.value = "1";
	document.form_.submit();
}
function CheckStickPerDay() {
	document.form_.sming_sticks_pd.selectedIndex = 0;
	document.form_.sming_age_started.value = "";
}
function CheckAlcohol() {
	document.form_.alcohol_freq.selectedIndex = 0;
}
function OpenSearch() {
<%
if(bolIsSchool){%>
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
<%}else{%>
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.stud_id";
<%}%>
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ShowLedgend() {
	var win=window.open("./dental_status_setup.jsp","PrintWindow",'width=650,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AjaxMapName(strPos) {
		var strCompleteName;
			strCompleteName = document.form_.stud_id.value;

		if(strCompleteName.length <=2)
			return;

		var objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName)+ "&is_faculty=1";
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	//do nothing..
}
</script>
<body bgcolor="#8C9AAA" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;

	boolean bolNoRecord = true; //it is false if there is error in edit info.

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-DENTAL STATUS","dental_entry.jsp");
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
															"Health Monitoring","DENTAL STATUS",request.getRemoteAddr(),
															"dental_entry.jsp");
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
	
	Vector vBasicInfo = null; Vector vRetResult = null; Vector vDentalRecords = null;
	boolean bolIsStaff = false;
	boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	String strAge = null;
	
	//get all levels created.
	if(WI.fillTextValue("stud_id").length() > 0) {
		if(bolIsSchool) {
			vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
			if(vBasicInfo == null) //may be it is the teacher/staff
			{
				request.setAttribute("emp_id",request.getParameter("stud_id"));
				vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
				if(vBasicInfo != null)
					bolIsStaff = true;
			}
			else {//check if student is currently enrolled
				Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"),
				(String)vBasicInfo.elementAt(10),(String)vBasicInfo.elementAt(11),(String)vBasicInfo.elementAt(9));
				if(vTempBasicInfo != null)
					bolIsStudEnrolled = true;
			}
			if(vBasicInfo == null)
				strErrMsg = OAdm.getErrMsg();
		}
		else{//check faculty only if not school...
				request.setAttribute("emp_id",request.getParameter("stud_id"));
				vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
				if(vBasicInfo != null)
					bolIsStaff = true;
				if(vBasicInfo == null)
					strErrMsg = "Employee Information not found.";;
		}
	}
	//gets health info.
	
	int iSearchResult = 0;
	health.Dental dental = new health.Dental();
	if(vBasicInfo!= null) {
	
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			if(dental.operateOnDentalRecord(dbOP, request, Integer.parseInt(strTemp)) != null)
				strErrMsg = "Dental record updated successfully.";
			else
				strErrMsg = dental.getErrMsg();
		}
		
		vDentalRecords = dental.operateOnDentalRecord(dbOP, request, 4);
		if(vDentalRecords == null){
			if(strTemp.length() == 0)
				strErrMsg = dental.getErrMsg();
		}
		else
			iSearchResult = dental.getSearchCount();
		
		//get dental record for this day..
		vRetResult = dental.operateOnDentalRecord(dbOP, request, 3);
	}
	
	boolean bolIsDeciduous = false;
	String strInfoIndex    = null;
	Vector vTempDentalStat = null;//
	
	if(vRetResult != null && vRetResult.size() > 6) {
		strInfoIndex = (String)vRetResult.elementAt(5);
	}
%>
<form action="./dental_entry.jsp" method="post" name="form_">
<!--
	<EMBED SRC="../../../jscript/error_attendance.wav" autostart="true" LOOP="false" HIDDEN="true"></EMBED>
-->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="28" colspan="6" bgcolor="#697A8F" class="footerDynamic" align="center"><font color="#FFFFFF" ><strong>::::
        DENTAL RECORD ENTRY PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr >
      <td width="2%"  >&nbsp;</td>
      <td width="18%" >Enter ID No. :</td>
      <td width="17%" ><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">
      </td>
      <td width="21%" ><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" ></a></td>
      <td width="39%" rowspan="3" valign="top" ><%if(vBasicInfo != null){%>
          <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#B0B0FF">
            <tr>
              <td style="font-size:11px; font-weight:bold; color:#0000FF"><u>Current Dental Status</u> &nbsp;&nbsp;&nbsp;<br>
                  <%if(vRetResult != null) {%>
                Exam Date :<font color="#FF0000">
                <font color="#FF0000"><%=vRetResult.remove(0)%></font>
                <%if(vRetResult.remove(3).equals("1")){%>
                  (Deciduous)
                  <%}else{%>
                  (Permanent)
                  <%}%>
                  </font> <br>
				  <%
				  vTempDentalStat = (Vector)vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
				  if(vTempDentalStat != null && vTempDentalStat.size() > 0) {%>
					  <table cellpadding="0" cellspacing="0">
					  <%while(vTempDentalStat.size() > 0) {%>
						  <tr>
							<td><%=vTempDentalStat.remove(0)%> &nbsp;&nbsp; </td>
							<td><%=vTempDentalStat.remove(0)%></td>
						  </tr>
					  <%}%>
					  </table>
					<%}%>
				  <!--
                Decayed :<font color="#FF0000"><%//=vRetResult.remove(0)%></font> <br>
                Missing : <font color="#FF0000"><%//=vRetResult.remove(0)%></font> <br>
                Filled : <font color="#FF0000"><%//=vRetResult.remove(0)%></font>-->
                <%}else{%>
                	<font color="#FF0000">No Dental record available.</font>
                <%}%>              </td>
            </tr>
          </table>
        <%}%></td>
      <td width="3%" valign="top" >&nbsp;</td>
    </tr>
    <tr >
      <td >&nbsp;</td>
      <td >Examination Date : </td>
      <td colspan="2" ><font size="1">
        <%
strTemp = WI.fillTextValue("date_recorded");
if(strTemp.length() ==0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_recorded" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_recorded');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </font> </td>
      <td valign="top" >&nbsp;</td>
    </tr>
    <tr >
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td ><input name="image" type="image" src="../../../images/form_proceed.gif"></td>
      <td >&nbsp;</td>
      <td valign="top" >&nbsp;</td>
    </tr>
     <tr >
      <td height="18"></td>
      <td height="18" colspan="5" valign="top">
	  	<label id="coa_info" style="font-size:11px;"></label>
	  </td>
    </tr>
   <tr >
      <td height="18" colspan="6" ><hr size="1"></td>
    </tr>
  </table>
  <%
if(vBasicInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(!bolIsStaff){%>
    <tr >
      <td  width="2%" height="25">&nbsp;</td>
      <td width="15%" >Student Name : </td>
      <td width="46%" ><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
      <td width="13%" >Status : </td>
      <td width="24%" >
        <%if(bolIsStudEnrolled){%>
        Currently Enrolled
        <%}else{%>
        Not Currently Enrolled
        <%}%>      </td>
    </tr>
    <tr>
      <td   height="25">&nbsp;</td>
      <td >Course/Major :</td>
      <td height="25" colspan="3" ><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Year :</td>
      <td ><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></td>
      <td >Age : </td>
      <td ><span style="font-weight:bold"><%=WI.getStrValue(strAge,"Not Set")%></span></td>
    </tr>
    <%}//if not staff
else{%>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Emp. Name :</td>
      <td><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),
	  (String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></td>
      <td>Emp. Status :</td>
      <td><strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td ><%if(bolIsSchool){%>College/Office<%}else{%>Division<%}%> :</td>
      <td > <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/ <%=WI.getStrValue(vBasicInfo.elementAt(14))%></strong></td>
      <td >Designation :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td >Age : </td>
      <td style="font-weight:bold"><%=WI.getStrValue(strAge,"Not Set")%></td>
    </tr>
    <%}//only if staff %>
  </table>

  <table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="11" bgcolor="#FFFF9F"><strong>DENTAL RECORD :
<%
if(strInfoIndex != null)
	strTemp = (String)vRetResult.elementAt(5);
else
	strTemp = WI.fillTextValue("is_deciduous");

if(strTemp.equals("1") || strTemp.length() == 0) {
	bolIsDeciduous = true;
	strTemp = " checked";
}
else
	strTemp = "";
if(strAge != null && strAge.length() > 0) {
	int iAge = Integer.parseInt(strAge);
	if(iAge > 15) {
		strTemp = "";
		bolIsDeciduous = false;
	}
}
%>
	<input name="is_deciduous" type="radio" value="1" <%=strTemp%> onClick="document.form_.page_action.value='';document.form_.submit();"> Deciduous Teeth
<%
if(strTemp.length() == 0)
	strTemp = " checked";
else
	strTemp = "";
%>
      	<input name="is_deciduous" type="radio" value="0"<%=strTemp%> onClick="document.form_.page_action.value='';document.form_.submit();">Permanent Teeth
	  </strong></td>
    </tr>
<%if(!bolIsDeciduous){%>
    <tr>
      <td height="25" colspan="11">
	  <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td><div align="center"><img src="../../../images/teeth/permanent_teeth.jpg"></div></td>
        </tr>
        <tr>
          <td><table width="100%" border="0" cellpadding="3" cellspacing="0">
            <tr >
              <td height="25" colspan="17"><strong><u>Examination Result :</u></strong><span class="style1">
			  Legend : &nbsp;&nbsp;&nbsp;<strong><a href="javascript:ShowLedgend();">Click to View</a></strong> </span></td>
            </tr><%//=System.out.println(vRetResult)%>
    <!--
	        <tr >
              <td height="25" align="right">&nbsp;</td>
              <td colspan="16" style="font-weight:bold; font-size:11px; color:#0000FF">
			  	<%if(vRetResult != null && vRetResult.size() > 0) {%>
				    Status :
					Decayed : <%//=vRetResult.elementAt(2)%>
					Missing : <%//=vRetResult.elementAt(3)%>
					Filled : <%//=vRetResult.elementAt(4)%>
				<%
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);
				}else{%>Record not found.<%}%>
				</td>
              </tr>
    -->
	        <tr >
              <td width="10%" height="25" align="right">UPPER&nbsp;&nbsp;&nbsp; </td>
              <td width="9%">
			  <select name="u_1" style="font-size:9px">
                  <option></option>
<%//System.out.println(vRetResult);
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("1")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>

              </select>
			  </td>
              <td width="9%">
			  <select name="u_2" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("2")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_3" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("3")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_4" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("4")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_5" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("5")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
				</select></td>
              <td width="9%">
			  <select name="u_6" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("6")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
				</select></td>
              <td width="9%">
			  <select name="u_7" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("7")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%" class="thinborderRIGHT">
			  <select name="u_8" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("8")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_9" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("9")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_10" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("10")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_11" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("11")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_12" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("12")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_13" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("13")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_14" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("14")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_15" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("15")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_16" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("16")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
            </tr>
            <tr >
              <td height="25" align="right">LOWER&nbsp;&nbsp;&nbsp;</td>
              <td>
			  <select name="l_1" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("17")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_2" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("18")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_3" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("19")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_4" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("20")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_5" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("21")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_6" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("22")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_7" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("23")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td class="thinborderRIGHT">
			  <select name="l_8" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("24")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_9" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("25")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_10" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("26")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_11" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("27")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_12" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("28")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_13" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("29")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_14" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("30")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_15" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("31")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td>
			  <select name="l_16" style="font-size:9px">
                <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("32")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
            </tr>
            <tr >
              <td height="25" align="right">&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td class="thinborderRIGHT">&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
            </tr>
          </table></td>
        </tr>
<%}else{//end of showing permanent teeth.%>
        <tr>
          <td><div align="center"><img src="../../../images/teeth/deciduous_teeth.jpg" width="782"></div></td>
        </tr>
        <tr>
          <td>
		  	<table width="100%" border="0" cellpadding="3" cellspacing="0">
            <tr >
              <td height="25" colspan="11"><strong><u>Examination Result :</u></strong><span class="style1">
			  Legend : &nbsp;&nbsp;&nbsp;<strong><a href="javascript:ShowLedgend();">Click to View</a></strong> </span></td>
            </tr>
<!--
            <tr >
              <td height="25" align="right">&nbsp;</td>
              <td colspan="10" style="font-weight:bold; font-size:11px; color:#0000FF">
			  	<%if(vRetResult != null && vRetResult.size() > 0) {%>
					Status :
					Decayed : <%//=vRetResult.elementAt(2)%>
					Missing : <%//=vRetResult.elementAt(3)%>
					Filled : <%//=vRetResult.elementAt(4)%>
				<%
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);
				//}else{%>Record not found.<%}%>
			  </td>
              </tr>
-->
            <tr >
              <td width="10%" height="25" align="right">UPPER&nbsp;&nbsp;&nbsp; </td>
              <td width="9%">
			  <select name="u_1" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("1")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select></td>
              <td width="9%">
			  <select name="u_2" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("2")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td width="9%">
			  <select name="u_3" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("3")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td width="9%">
			  <select name="u_4" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("4")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td width="9%" class="thinborderRIGHT">
			  <select name="u_5" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("5")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td width="9%">
			  <select name="u_6" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("6")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td width="9%">
			  <select name="u_7" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("7")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td width="9%">
			  <select name="u_8" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("8")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td width="9%">
			  <select name="u_9" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("9")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td width="9%">
			  <select name="u_10" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("10")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
            </tr>
            <tr >
              <td height="25" align="right">LOWER&nbsp;&nbsp;&nbsp;</td>
              <td>
			  <select name="l_1" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("11")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td>
			  <select name="l_2" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("12")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td>
			  <select name="l_3" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("13")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td>
			  <select name="l_4" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("14")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td class="thinborderRIGHT">
			  <select name="l_5" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("15")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td>
			  <select name="l_6" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("16")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td>
			  <select name="l_7" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("17")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td>
			  <select name="l_8" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("18")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td>
			  <select name="l_9" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("19")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
              <td>
			  <select name="l_10" style="font-size:9px">
                  <option></option>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0 && vRetResult.elementAt(0).equals("20")) {
	vRetResult.remove(0);
	strTemp = (String)vRetResult.remove(0);
}
%>
<%=dbOP.loadCombo("STATUS_INDEX", "STATUS_CODE"," from HM_DENTAL_STATUS order by status_index",strTemp, false, false)%>
              </select>			  </td>
            </tr>
            <tr >
              <td height="25" align="right">&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td class="thinborderRIGHT">&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
            </tr>
          </table></td>
        </tr>
      </table></td>
    </tr>
<%}//show Deciduous teeth.%>
  	</table>
 	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="17%"><strong>Attending Dentist: </strong></td>
			<td width="85%">
				<select name="dentist">
					<option value="">Select Dentist</option>
					<%=dbOP.loadCombo("physician_index","physician_name", " from hm_accredited_physicians "+
										" where is_valid = 1 order by physician_name", WI.fillTextValue("dentist"), false)%>
				</select>
				<%if(iAccessLevel > 1){%>
					<a href="javascript:updatePhysicians();"><img src="../../../images/update.gif" border="0" ></a> 
					<font size="1">click to add list of accredited physicians </font>
				<%}%></td>
		</tr>
		<tr>
			<td height="25"><strong>Diagnosis: </strong></td>
		  	<td>
		  		<textarea name="diagnosis" cols="48" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" style="font-size:12px"><%=WI.fillTextValue("diagnosis")%></textarea></td>
	  	</tr>
		<tr>
			<td height="25"><strong>Treatment Plan: </strong></td>
		  	<td>
		  		<textarea name="treatment_plan" cols="48" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" style="font-size:12px"><%=WI.fillTextValue("treatment_plan")%></textarea></td>
	  	</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="5"><div align="center"><font size="1">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:UpdateRecord();"><img src="../../../images/update.gif" border="0"></a>
					click to update dental record
				<%}else{%>
					Not authorized to change information
				<%}%></font></div></td>
		</tr>
		<tr>
			<td height="10" colspan="5">&nbsp;</td>
		</tr>
	</table>
<%}//only if vBasicInfo is not null

if(vDentalRecords != null && vDentalRecords.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="22" colspan="7" bgcolor="#FFFF9F" class="thinborder">
				<div align="center"><strong>::: DENTAL RECORDS ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="5">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=dental.getDisplayRange()%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="2"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/dental.defSearchSize;		
				if(iSearchResult % dental.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+dental.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder" align="center" width="5%"><strong>Count</strong></td>
		    <td class="thinborder" align="center" width="12%"><strong>Exam Date</strong></td>
			<td class="thinborder" align="center" width="15%"><strong>Dentist</strong></td>
			<td class="thinborder" align="center" width="19%"><strong>Diagnosis</strong></td>
			<td class="thinborder" align="center" width="19%"><strong>Treatment Plan </strong></td>
		    <td class="thinborder" align="center" width="15%"><strong>Type</strong></td>		    
		    <td class="thinborder" align="center" width="15%"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vDentalRecords.size(); i += 11, iCount++){%>
		<tr>
			<td height="25" class="thinborder" align="center"><%=iCount%></td>
		    <td class="thinborder">&nbsp;<%=(String)vDentalRecords.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vDentalRecords.elementAt(i+9))%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vDentalRecords.elementAt(i+7))%></td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vDentalRecords.elementAt(i+10))%></td>
			<%
				strTemp = (String)vDentalRecords.elementAt(i+6);
				if(strTemp.equals("0"))
					strTemp = "Permanent";
				else
					strTemp = "Deciduous";
			%>
		    <td class="thinborder">&nbsp;<%=strTemp%></td>
		    <td align="center" class="thinborder">
				<a href="javascript:ViewDetails('<%=(String)vDentalRecords.elementAt(i)%>')">
					<img src="../../../images/view.gif" border="0"></a>
			<%if(iAccessLevel == 2){%>
				<a href="javascript:DeleteRecord('<%=(String)vDentalRecords.elementAt(i)%>')">
					<img src="../../../images/delete.gif" border="0"></a>
			<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>
			
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr >
			<td height="25" colspan="9">&nbsp;</td>
		</tr>
		<tr >
			<td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="reload_page">
	<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
	<input type="hidden" name="delete_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
