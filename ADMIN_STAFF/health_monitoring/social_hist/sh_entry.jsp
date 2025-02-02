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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
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
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function CheckStickPerDay() {
	document.form_.smoking_sticks_pd.selectedIndex = 0;
	document.form_.smoking_age_started.value = "";
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
								"Admin/staff-Health Monitoring-SOCIAL HISTORY","sh_entry.jsp");
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
														"Health Monitoring","SOCIAL HISTORY",request.getRemoteAddr(),
														"sh_entry.jsp");
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
Vector vBasicInfo = null;Vector vHealthInfo = null;
boolean bolIsStaff = false;
boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
RecordHealthInformation RH = new RecordHealthInformation();

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
if(vBasicInfo!= null) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		//I have to add / edit here.
		if(RH.oprateOnSocialHistory(dbOP, request,1) == null)
			strErrMsg = RH.getErrMsg();
		else
			strErrMsg = "Health Record successfully updated.";
	}
	vHealthInfo = RH.oprateOnSocialHistory(dbOP, request,3);
	if(vHealthInfo == null)
		strErrMsg = RH.getErrMsg();
}

%>
<form action="./sh_entry.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="28" colspan="6" bgcolor="#697A8F" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          SOCIAL HISTORY RECORD ENTRY PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr >
      <td width="2%"  >&nbsp;</td>
      <td width="15%" >Enter ID No. :</td>
      <td width="20%" ><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
	  </td>
      <td width="21%" ><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" ></a></td>
      <td width="39%" rowspan="2" valign="top" > <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#B0B0FF">
          <tr>
            <td><font size="1">
              Record Last Updated : <%if(vHealthInfo != null){%><%=(String)vHealthInfo.elementAt(7)%><%}%><br>
              <br>
              </font><font size="1">Updated by :
              <%if(vHealthInfo != null){%><%=(String)vHealthInfo.elementAt(9)%><%}%>
              </font></td>
          </tr>
        </table></td>
      <td width="3%" valign="top" >&nbsp;</td>
    </tr>
    <tr >
      <td >&nbsp;</td>
      <td >Date Recorded: </td>
      <td colspan="2" ><font size="1">
<%
strTemp = WI.fillTextValue("date_recorded");
if(strTemp.length() ==0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_recorded" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_recorded');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
        </font> </td>
      <td valign="top" >&nbsp;</td>
    </tr>
    <tr >
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td ><input type="image" src="../../../images/form_proceed.gif"></td>
      <td colspan="2" ><label id="coa_info" style="font-size:11px;"></label></td>
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
        <%}%>
      </td>
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
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <%}//if not staff
else{%>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Emp. Name :</td>
      <td ><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),
	  (String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></td>
      <td >Emp. Status :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td ><%if(bolIsSchool){%>College/Office<%}else{%>Division<%}%> :</td>
      <td > <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/ <%=WI.getStrValue(vBasicInfo.elementAt(14))%></strong></td>
      <td >Designation :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <%}//only if staff %>
  </table>

  <table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
    <tr >
      <td height="25" colspan="3" bgcolor="#FFFF9F"><strong>SOCIAL HISTORY</strong></td>
    </tr>
    <tr >
      <td width="30%" height="25" bgcolor="#FFFFFF">Smoking
        <%
if(vHealthInfo != null)
	strTemp = (String)vHealthInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("smoking");

if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else
	strTemp = "";
%> <input type="radio" name="smoking" value="1" <%=strTemp%>>
        Yes
        <%
if(strTemp.length() == 0)
	strTemp = " checked";
else
	strTemp ="";
%> <input type="radio" name="smoking" value="0"<%=strTemp%> onClick="CheckStickPerDay();">
        No</td>
      <td width="33%" bgcolor="#FFFFFF">Age Started
        <%
if(vHealthInfo != null)
	strTemp = (String)vHealthInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("smoking_age_started");
%> <input name="smoking_age_started" type="text" size="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  maxlength=2> </td>
      <td width="37%" bgcolor="#FFFFFF">Sticks per day
        <select name="smoking_sticks_pd">
          <option value="0">None</option>
          <%
if(vHealthInfo != null)
	strTemp = (String)vHealthInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("smoking_sticks_pd");

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1-5</option>
          <%}else{%>
          <option value="1">1-5</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option  value="2" selected>6-10</option>
          <%}else{%>
          <option  value="2">6-10</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option  value="3" selected>11-15</option>
          <%}else{%>
          <option  value="3">11-15</option>
          <%}if(strTemp.compareTo("4") == 0){%>
          <option  value="4" selected>16-20</option>
          <%}else{%>
          <option  value="4">16-20</option>
          <%}if(strTemp.compareTo("5") == 0){%>
          <option  value="5" selected>More</option>
          <%}else{%>
          <option  value="5">More</option>
          <%}%>
        </select></td>
    </tr>
    <tr >
      <td height="25" bgcolor="#FFFFFF">Alcohol
        <%
if(vHealthInfo != null)
	strTemp = (String)vHealthInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("alcohol");

if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else
	strTemp = "";
%> <input type="radio" name="alcohol" value="1"<%=strTemp%>>
        Yes
        <%
if(strTemp.length() == 0)
	strTemp = " checked";
else
	strTemp ="";
%> <input type="radio" name="alcohol" value="0"<%=strTemp%> onClick="CheckAlcohol();">
        No</td>
      <td bgcolor="#FFFFFF">How often
        <select name="alcohol_freq">
          <option value="0">Never</option>
          <%
if(vHealthInfo != null)
	strTemp = (String)vHealthInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("alcohol_freq");

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Daily</option>
          <%}else{%>
          <option value="1">Daily</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option  value="2" selected>Weekly</option>
          <%}else{%>
          <option  value="2">Weekly</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option  value="3" selected>Monthly</option>
          <%}else{%>
          <option  value="3">Monthly</option>
          <%}if(strTemp.compareTo("4") == 0){%>
          <option  value="4" selected>Occasionally</option>
          <%}else{%>
          <option  value="4">Occasionally</option>
          <%}%>
        </select> </td>
      <td bgcolor="#FFFFFF">Food Preference
<%
if(vHealthInfo != null)
	strTemp = (String)vHealthInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("food_pref");
%> <input name="food_pref" type="text" size="16" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="5"><div align="center">
	  <%
	  if(iAccessLevel > 1){%>
	  <a href="javascript:UpdateRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click
          to save entries<%}else{%>Not authorized to change information<%}%>
		<a href="./sh_entry.jsp"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
          to cancel/erase entries</font></font></div></td>
    </tr>
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>
<%}//only if vBasicInfo is not null%>

  <table  width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr >
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="reload_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
