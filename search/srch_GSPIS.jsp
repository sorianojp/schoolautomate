<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../jscript/date-picker.js"></script>
<script language="JavaScript" SRC="../jscript/td.js"></script>
<script language="javascript"  src ="../jscript/common.js" ></script>
<script language="JavaScript">

function ReloadPage()
{
	document.form_.executeSearch.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function ChangeType() 
{
	document.form_.srchType.value = document.form_.srchData.value;
	document.form_.executeSearch.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function SearchNow() {
	document.form_.executeSearch.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function ShowHideOthers(strSelFieldName, strOthFieldName,strTextBoxID)
{
	if( eval('document.form_.'+strSelFieldName+'.selectedIndex') == 0)
	{
		eval('document.form_.'+strOthFieldName+'.disabled=false');
		showLayer(strTextBoxID);
	}
	else
	{
		eval('document.form_.'+strOthFieldName+'.value=\'\'');
		hideLayer(strTextBoxID);
		eval('document.form_.'+strOthFieldName+'.disabled=true');
	}
	
}
function viewPersonalData(strStudID)
{
	var pgLoc = "../ADMIN_STAFF/admission/stud_personal_info_page2.jsp?stud_id="+strStudID+"&removeEdit=1";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPg() {
	document.form_.print_page.value = "1";
	document.form_.submit();
}
</script>
<%@ page language="java" import="utility.*, search.SearchStudent ,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDataType = null;
	int i=0;
	int iSearchResult = 0;
	Vector vRetResult = null;
	strDataType =	WI.getStrValue(WI.fillTextValue("srchType"),"0");
	String strExecute = null;
	strExecute = WI.getStrValue(WI.fillTextValue("executeSearch"),"0");
	
	if(WI.fillTextValue("print_page").length()> 0) {%>
		<jsp:forward page="./srch_GSPIS_print.jsp" />
	<%return;}
	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-Search","srch_GSPIS.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","Search",request.getRemoteAddr(),
														"srch_GSPIS.jsp");
if(iAccessLevel == 0)														
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"srch_GSPIS.jsp");
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
	response.sendRedirect("../commfile/unauthorized_page.jsp");
	return;
}
//end authentication
if(strErrMsg == null) strErrMsg = "";
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListEqual2 = {"Equal to","Starts with","Ends with","Contains", "Any Keywords","All Keywords"};
String[] astrDropListValEqual2 = {"equals","starts","ends","contains","any","all"};
String[] astrDropListEqual3 = {"Starts with","Ends with","Contains", "Any Keywords","All Keywords"};
String[] astrDropListValEqual3 = {"starts","ends","contains","any","all"};
String[] astrDropListBetween = {"Between","Equal to","Less than","More than"};
String[] astrDropListValBetween = {"BETWEEN","=","greater","less"};//check for between
String[] astrSortByName    = {"Student ID","Lastname","Firstname"};
String[] astrSortByVal     = {"id_number","lname","fname"};


	SearchStudent srchStud = new SearchStudent(request);
	if (strExecute.compareTo("1")==0) {
		vRetResult = srchStud.searchGSPIS(dbOP);
		if (vRetResult != null && vRetResult.size()>0) {
			iSearchResult = srchStud.getSearchCount();
			vRetResult.remove(0);
		}
		else {
			strErrMsg = srchStud.getErrMsg();
			}
	}	
%>
<body bgcolor="#D2AE72">
<form action="./srch_GSPIS.jsp" method="post" name = "form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SEARCH INFO FROM GSPIS PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
	<td colspan="4" height="25"><%=WI.getStrValue(strErrMsg)%></td>
  	</tr>
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="18%">Search Data Type</td>
      <% strTemp = WI.getStrValue(WI.fillTextValue("srchData"),"0");%>
      <td width="25%"><select name="srchData" onChange="JavaScript:ChangeType();">
	<%if (strTemp.compareTo("0")==0) {%>
          <option value="0" selected>Personal Data</option>
     <%} else {%>
	     <option value="0">Personal Data</option>
	<%} if (strTemp.compareTo("1")==0) {%>
          <option value="1" selected>Alien Status Data</option>
          <%}else{%>
          <option value="1">Alien Status Data</option>
          <%} if (strTemp.compareTo("2")==0) {%>
          <option value="2" selected>Residence Data</option>
          <%}else{%>
		  <option value="2">Residence Data</option>
          <%} if (strTemp.compareTo("3")==0) {%>
          <option value="3" selected>Physical Description</option>
          <%}else{%>
          <option value="3">Physical Description</option>
          <%} if (strTemp.compareTo("4")==0) {%>
          <option value="4" selected>Family Data</option>
          <%}else{%>
          <option value="4">Family Data</option>
          <%} if (strTemp.compareTo("5")==0) {%>
          <option value="5" selected>Educational Background</option>
          <%}else if(false){%>
          <option value="5">Educational Background</option>
          <%} if (strTemp.compareTo("6")==0) {%>
          <option value="6" selected>General Qualification</option>
          <%}else{%>
          <option value="6">General Qualification</option>
          <%}%>
        </select></td>
      <td width="55%"><a href="JavaScript:SearchNow();"><img src="../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Enrolled SY-TERM </td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() != 4)
	strTemp = "";
%>
	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="ChkShowOnlyEnrolled(); style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' maxlength=4>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() != 4)
	strTemp = "";
%>
      <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly> &nbsp;&nbsp; 
	  <select name="semester">
 <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
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
        </select>
	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="7"><hr size="1"></td>
    </tr>
  </table>
	<% if (strDataType.compareTo("0")==0) {%>
 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%" valign="bottom">Nationality</td>
      <td width="27%" valign="bottom">&nbsp; </td>
      <td colspan="2" valign="bottom">&nbsp;<%if (false) {%>Birthdate (Month)<%}%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><select name="ntl_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("ntl_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select></td>
      <td><input name="ntl" type="text" value="<%=WI.fillTextValue("ntl")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="25%">&nbsp;<%if (false) {%><select name="BMonth">
          <option value="0">January</option>
          <option value="1">February</option>
          <option value="2">March</option>
          <option value="3">April</option>
   		  <option value="4">May</option>
          <option value="5">June</option>
          <option value="6">July</option>
          <option value="7">August</option>
   		  <option value="8">September</option>
          <option value="9">October</option>
          <option value="10">November</option>
          <option value="11">December</option>
        </select><%}%></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Religion</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">Age</td>
      <td width="39%" valign="bottom">&nbsp; </td>
    </tr>
    <tr> 
      <td height="23">&nbsp;</td>
      <td><select name="rel_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("rel_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select></td>
      <td><input name="rel" type="text" value="<%=WI.fillTextValue("rel")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2"><select name="age_con" onChange='ShowHideOthers("age_con","age_to","age_to_");'>
          <%=srchStud.constructGenericDropList(WI.fillTextValue("age_con"),astrDropListBetween,astrDropListValBetween)%> 
        </select> <input name="age_fr" type="text" size="7" value="<%=WI.fillTextValue("age_fr")%>" class="textbox"
	 onKeyUp= 'AllowOnlyInteger("form_","age_fr")' onFocus="style.backgroundColor='#D3EBFF'" onblur='AllowOnlyInteger("form_","age_fr");style.backgroundColor="white"'>
        &nbsp;&nbsp;&nbsp; 
        <input name="age_to" type="text" size="7" value="<%=WI.fillTextValue("age_to")%>" class="textbox"
	id="age_to_" onKeyUp= 'AllowOnlyInteger("form_","age_to")' onFocus="style.backgroundColor='#D3EBFF'" onblur='AllowOnlyInteger("form_","age_to");style.backgroundColor="white"'></td>
     <%if(WI.fillTextValue("age_con").length() > 0){%>
	<script language="JavaScript">
	ShowHideOthers("age_con","age_fr","age_to_");
	</script><%}%>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Gender </td>
      <td valign="bottom">&nbsp;</td>
      <td colspan="2" valign="bottom">Date of Birth</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>
      <%strTemp = WI.fillTextValue("gender");%>
      <select name="gender">
          <option value="" selected="selected">N/A</option>
          <%if (strTemp.compareTo("F")==0){ %>
          <option value="F" selected>Female</option>
          <%} else {%>
          <option value="F">Female</option>
          <%} if (strTemp.compareTo("M")==0){ %>
          <option value="M" selected>Male</option>
			<%} else {%>
          <option value="M">Male</option>
          <%}%>
        </select></td>
      <td>&nbsp;</td>
      <td><font size="1">From </font><input name="dob_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("dob_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.dob_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td><font size="1">To </font> <input name="dob_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("dob_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" id="dob_to_"> 
        <a href="javascript:show_calendar('form_.dob_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
        <img src="../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Civil Status</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">Birth Order</td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%strTemp = WI.fillTextValue("c_stat");%>
      <select name="c_stat">
		  <option value="">N/A</option>
		<%=dbOP.loadCombo("DISTINCT CIVIL_STAT","CIVIL_STAT"," from INFO_PERSONAL order by INFO_PERSONAL.CIVIL_STAT asc", strTemp, false)%>
        </select></td>
      <td>&nbsp;</td>
      <%strTemp = WI.fillTextValue("birth_ord");%>
      <td><select name="birth_ord">
        <option value="" selected>N/A</option>
         <%for (i=1; i<16; ++i) {
         if (strTemp.compareTo(Integer.toString(i))==0) {%>
		<option value="<%=i%>" selected><%=i%></option>
		<%}// if ==i
		else {%>
		<option value="<%=i%>"><%=i%></option>
		<%}}%>
        </select></td>
      <td>&nbsp; </td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%} 
  if (strDataType.compareTo("1")==0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4">Visa Status 
<%strTemp = WI.fillTextValue("visa_stat");%>
<select name="visa_stat">
<option value="">N/A</option>
<%=dbOP.loadCombo("DISTINCT VISA_STATUS","VISA_STATUS"," from INFO_VISA order by INFO_VISA.VISA_STATUS asc", strTemp, false)%>
</select>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="21%" valign="bottom">Passport Expiration</td>
      <td width="24%" valign="bottom">&nbsp; </td>
      <td width="21%" valign="bottom"><%if (false) {%>Authorized Stay<%}%>&nbsp;</td>
      <td width="32%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><font size="1">From </font><input name="pass_expire_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("pass_expire_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.pass_expire_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td><font size="1">To </font><input name="pass_expire_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("pass_expire_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.pass_expire_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td><%if (false) {%><font size="1">From </font><input name="auth_stay_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("dob_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.auth_stay_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../images/calendar_new.gif" width="20" height="16" border="0"></a><%}%>&nbsp;</td>
      <td><%if (false) {%><font size="1">To </font><input name="auth_stay_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("dob_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.auth_stay_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../images/calendar_new.gif" width="20" height="16" border="0"></a><%}%>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom">ACR Expiration</td>
      <td valign="bottom">&nbsp; </td>
      <td valign="bottom">CRTS Expiration</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><font size="1">From </font><input name="acr_exp_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("acr_exp_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.acr_exp_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td><font size="1">To </font><input name="acr_exp_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("acr_exp_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.acr_exp_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td><font size="1">From </font><input name="crts_exp_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("crts_exp_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.crts_exp_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td><font size="1">To </font><input name="crts_exp_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("crts_exp_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.crts_exp_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%}
  if (strDataType.compareTo("2")==0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><u>Home Address:</u></td>
      <td colspan="2"><u>Current Contact Address &amp; Relation:</u></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" valign="bottom">Municipality/City</td>
      <td width="32%" valign="bottom">&nbsp; </td>
      <td width="15%" valign="bottom">Municipality/City</td>
      <td width="36%" valign="bottom">&nbsp; </td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="2" valign="bottom"><select name="home_city_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("home_city_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select><input name="home_city" type="text" value="<%=WI.fillTextValue("home_city")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2" valign="bottom">
      <select name="cur_city_con"><%=srchStud.constructGenericDropList(WI.fillTextValue("cur_city_con"),astrDropListEqual,astrDropListValEqual)%></select> 
      <input name="cur_city" type="text" value="<%=WI.fillTextValue("cur_city")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom">Province</td>
      <td valign="bottom">&nbsp; </td>
      <td valign="bottom">Province</td>
      <td valign="bottom">&nbsp; </td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="2" valign="bottom"><select name="home_prov_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("home_prov_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select><input name="home_prov" type="text" value="<%=WI.fillTextValue("home_prov")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2" valign="bottom"><select name="cur_prov_con"><%=srchStud.constructGenericDropList(WI.fillTextValue("cur_prov_con"),astrDropListEqual,astrDropListValEqual)%></select>
      <input name="cur_prov" type="text" value="<%=WI.fillTextValue("cur_prov")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom">Country</td>
      <td valign="bottom">&nbsp; </td>
      <td valign="bottom">Country</td>
      <td valign="bottom">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom"><select name="home_country_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("home_country_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select><input name="home_country" type="text" value="<%=WI.fillTextValue("home_country")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2" valign="bottom"><select name="cur_country_con"><%=srchStud.constructGenericDropList(WI.fillTextValue("cur_country_con"),astrDropListEqual,astrDropListValEqual)%></select>
      <input name="cur_country" type="text" value="<%=WI.fillTextValue("cur_country")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">&nbsp;</td>
      <td colspan="2" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%}
  if (strDataType.compareTo("3")==0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" valign="bottom">&nbsp;<%if (false) {%>Height (cms)<%}%></td>
      <td width="32%" valign="bottom">&nbsp; </td>
      <td width="15%" valign="bottom">Eye Color</td>
      <td width="36%" valign="bottom">&nbsp; </td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="2" valign="bottom">&nbsp;<%if (false) {%><select name="height_con" onChange='ShowHideOthers("height_con","h_to","h_to_");'>
          <%=srchStud.constructGenericDropList(WI.fillTextValue("age_con"),astrDropListBetween,astrDropListValBetween)%> 
        </select><input name="h_fr" type="text" size="7" value="<%=WI.fillTextValue("h_fr")%>" class="textbox"
	 onKeyUp= 'AllowOnlyInteger("form_","h_fr")' onFocus="style.backgroundColor='#D3EBFF'" onblur='AllowOnlyInteger("form_","h_fr");style.backgroundColor="white"'>
        &nbsp;&nbsp;&nbsp; 
        <input name="h_to" type="text" size="7" value="<%=WI.fillTextValue("h_to")%>" class="textbox"
	id="h_to_" onKeyUp= 'AllowOnlyInteger("form_","h_to")' onFocus="style.backgroundColor='#D3EBFF'" onblur='AllowOnlyInteger("form_","h_to");style.backgroundColor="white"'><%}%></td>
	 <%if(WI.fillTextValue("height_con").length() > 0){%>
		<script language="JavaScript">
		ShowHideOthers("height_con","h_fr","h_to_");
		</script><%}%>
      <td colspan="2" valign="bottom"><select name="eye_col_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("eye_col_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>&nbsp;<input name="eye_col" type="text" value="<%=WI.fillTextValue("eye_col")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom">&nbsp;<%if (false) {%>Weight (lbs)<%}%></td>
      <td valign="bottom">&nbsp; </td>
      <td valign="bottom">Hair color</td>
      <td valign="bottom">&nbsp; </td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="2" valign="bottom">&nbsp;<%if (false) {%><select name="weight_con" onChange='ShowHideOthers("weight_con","w_to","w_to_");'>
          <%=srchStud.constructGenericDropList(WI.fillTextValue("age_con"),astrDropListBetween,astrDropListValBetween)%> 
        </select> <input name="w_fr" type="text" size="7" value="<%=WI.fillTextValue("w_fr")%>" class="textbox"
	 onKeyUp= 'AllowOnlyInteger("form_","w_fr")' onFocus="style.backgroundColor='#D3EBFF'" onblur='AllowOnlyInteger("form_","w_fr");style.backgroundColor="white"'>
        &nbsp;&nbsp;&nbsp; 
        <input name="w_to" type="text" size="7" value="<%=WI.fillTextValue("w_to")%>" class="textbox"
	id="w_to_" onKeyUp= 'AllowOnlyInteger("form_","w_to")' onFocus="style.backgroundColor='#D3EBFF'" onblur='AllowOnlyInteger("form_","w_to");style.backgroundColor="white"'><%}%></td>
	<%if(WI.fillTextValue("weight_con").length() > 0){%>
		<script language="JavaScript">
		ShowHideOthers("weight_con","w_fr","w_to_");
		</script><%}%>
      <td colspan="2" valign="bottom"><select name="hair_col_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("hair_col_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>&nbsp;<input name="hair_col" type="text" value="<%=WI.fillTextValue("hair_col")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom">Built</td>
      <td valign="bottom">&nbsp; </td>
      <td valign="bottom">Complexion</td>
      <td valign="bottom">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom"><select name="built_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("built_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>&nbsp;<input name="built" type="text" value="<%=WI.fillTextValue("built")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2" valign="bottom"><select name="complxn_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("complxn_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>&nbsp;<input name="complxn" type="text" value="<%=WI.fillTextValue("cmplxn")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom"> <br>
        Other Distinguishing Features <br></td>
      <td colspan="2" valign="bottom">Physical Handicap or Disability </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom"><select name="features_con">
<%=srchStud.constructGenericDropList(WI.fillTextValue("features_con"),astrDropListEqual2,astrDropListValEqual2)%> 
        </select> <input name="feature" type="text" value="<%=WI.fillTextValue("feature")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2" valign="bottom"> <select name="handicap_con">
<%=srchStud.constructGenericDropList(WI.fillTextValue("handicap_con"),astrDropListEqual2,astrDropListValEqual2)%> 
        </select><input name="handicap" type="text" value="<%=WI.fillTextValue("handicap")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%}
  if (strDataType.compareTo("4")==0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="47%" valign="bottom">Father's Name</td>
      <td width="51%" colspan="2" valign="bottom">Father's Occupation </td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom"><select name="f_name_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("f_name_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>&nbsp;<input name="f_name" type="text" value="<%=WI.fillTextValue("f_name")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2" valign="bottom"><select name="f_occ_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("f_occ_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>&nbsp;<input name="f_occ" type="text" value="<%=WI.fillTextValue("f_occ")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom">Mother's Name</td>
      <td colspan="2" valign="bottom">Mother's Occupation </td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom"><select name="m_name_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("m_name_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>&nbsp;<input name="m_name" type="text" value="<%=WI.fillTextValue("m_name")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2" valign="bottom"><select name="m_occ_con">
          <%=srchStud.constructGenericDropList(WI.fillTextValue("m_occ_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>&nbsp;<input name="m_occ" type="text" value="<%=WI.fillTextValue("m_occ")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td valign="bottom">Brother(s)/Sister(s) Name</td>
      <td colspan="2" valign="bottom">Brother(s)/Sister(s) School </td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom"><select name="sibling_name_con">
<%=srchStud.constructGenericDropList(WI.fillTextValue("sibling_name_con"),astrDropListEqual2,astrDropListValEqual2)%> 
        </select> <input name="sibling_name" type="text" value="<%=WI.fillTextValue("sibling_name")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2" valign="bottom"><select name="sibling_sch_con">
<%=srchStud.constructGenericDropList(WI.fillTextValue("sibling_sch_con"),astrDropListEqual2,astrDropListValEqual2)%> 
        </select> <input name="sibling_sch" type="text" value="<%=WI.fillTextValue("sibling_sch")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <%}
  if (strDataType.compareTo("5")==0 && false) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="47%" valign="bottom">Year Graduated</td>
      <td width="51%" colspan="2" valign="bottom">School Graduated
        <select name="select38">
          <option>Elementary</option>
          <option>High School</option>
          <option>College</option>
          <option>Post Grad</option>
          <option>Vocational</option>
        </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom"><select name="grad_yr_con" onChange='ShowHideOthers("grad_yr_con","grad_yr_to","grad_yr_to_");'>
          <%=srchStud.constructGenericDropList(WI.fillTextValue("grad_yr_con"),astrDropListBetween,astrDropListValBetween)%> 
        </select> <input name="grad_yr_fr" type="text" size="7" value="<%=WI.fillTextValue("grad_yr_fr")%>" class="textbox"
	 onKeyUp= 'AllowOnlyInteger("form_","grad_yr_fr")' onFocus="style.backgroundColor='#D3EBFF'" onblur='AllowOnlyInteger("form_","grad_yr_fr");style.backgroundColor="white"'>
        &nbsp;&nbsp;&nbsp; 
        <input name="grad_yr_to" type="text" size="7" value="<%=WI.fillTextValue("grad_yr_to")%>" class="textbox"
	id="grad_yr_to_" onKeyUp= 'AllowOnlyInteger("form_","grad_yr_to")' onFocus="style.backgroundColor='#D3EBFF'" onblur='AllowOnlyInteger("form_","grad_yr_to");style.backgroundColor="white"'></td>
      <td colspan="2" valign="bottom"><select name="select37">
          <option>Equal to</option>
          <option>Starts with</option>
          <option>Ends with</option>
          <option>Contains</option>
        </select> <input name="textfield333322" type="text" size="28"> </td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom">Honors/Awards</td>
      <td colspan="2" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom"><select name="select35">
          <option>Equal to</option>
          <option>Starts with</option>
          <option>Ends with</option>
          <option>Contains</option>
        </select> <input name="textfield3322" type="text" size="20"></td>
      <td colspan="2" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <%}
  if (strDataType.compareTo("6")==0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" height="25" valign="bottom">Languages</td>
      <td width="32%" height="25" valign="bottom">&nbsp;</td>
      <td width="15%" height="25" valign="bottom">Sports</td>
      <td width="36%" height="25" valign="bottom">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom"><select name="lang_con">
<%=srchStud.constructGenericDropList(WI.fillTextValue("lang_con"),astrDropListEqual3,astrDropListValEqual3)%> 
        </select> <input name="lang" type="text" value="<%=WI.fillTextValue("lang")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="25" colspan="2" valign="bottom"><select name="sport_con">
<%=srchStud.constructGenericDropList(WI.fillTextValue("sport_con"),astrDropListEqual3,astrDropListValEqual3)%> 
        </select> <input name="sport" type="text" value="<%=WI.fillTextValue("sport")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Hobbies</td>
      <td height="25" valign="bottom">&nbsp; </td>
      <td height="25" colspan="2"> <br>
        Honors/Awards/Merits</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom"><select name="hobby_con">
<%=srchStud.constructGenericDropList(WI.fillTextValue("hobby_con"),astrDropListEqual3,astrDropListValEqual3)%> 
        </select> <input name="hobby" type="text" value="<%=WI.fillTextValue("hobby")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="25" colspan="2" valign="bottom"><select name="merit_con">
<%=srchStud.constructGenericDropList(WI.fillTextValue("merit_con"),astrDropListEqual3,astrDropListValEqual3)%> 
        </select> <input name="merit" type="text" value="<%=WI.fillTextValue("merit")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Skills</td>
      <td height="25" valign="bottom">&nbsp; </td>
      <td height="25" colspan="2" valign="bottom">Extra-Curricular Activities 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom"><select name="skill_con">
<%=srchStud.constructGenericDropList(WI.fillTextValue("skill_con"),astrDropListEqual3,astrDropListValEqual3)%> 
        </select> <input name="skill" type="text" value="<%=WI.fillTextValue("skill")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="25" colspan="2" valign="bottom"><select name="extra_curr_con">
<%=srchStud.constructGenericDropList(WI.fillTextValue("extra_curr_con"),astrDropListEqual3,astrDropListValEqual3)%> 
        </select> <input name="extra_curr" type="text" value="<%=WI.fillTextValue("extra_curr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom"> <br>
        Talents<br></td>
      <td height="25" colspan="2" valign="bottom">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom"><select name="talent_con">
<%=srchStud.constructGenericDropList(WI.fillTextValue("talent_con"),astrDropListEqual3,astrDropListValEqual3)%> 
        </select> <input name="talent" type="text" value="<%=WI.fillTextValue("talent")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2" valign="bottom">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="19%"><select name="sort_by1">
			<option value="">N/A</option>
	          <%=srchStud.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
			</select>
      </td>
      <td width="20%"><select name="sort_by2">
			<option value="">N/A</option>
	          <%=srchStud.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
			</select>
      </td>
      <td width="51%"><select name="sort_by3">
				<option value="">N/A</option>
	          <%=srchStud.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
			</select>
      </td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>			<select name="sort_by1_con">
				<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select></td>
      <td><select name="sort_by2_con">
					<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select></td>
      <td><select name="sort_by3_con">
				<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select></td>
      <td>&nbsp;</td>
    </tr>
     <tr> 
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="JavaScript:SearchNow();"><img src="../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
  </table>
<%if (vRetResult!=null && vRetResult.size()>0) {
boolean bolShowCourseYr = false;
if(WI.fillTextValue("sy_from").length() > 0) 
	bolShowCourseYr = true;

%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH
          RESULT</font></strong></div></td>
    </tr>
    <tr>
      <td width="43%" height="25"><b>TOTAL RESULT: <%=iSearchResult%> - Showing(<%=srchStud.getDisplayRange()%>)</b></td>
      <td width="26%" style="font-size:9px;">
	   <select name="num_stud_page">
		  <option value="1000000">Print ALL in One Page</option>
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"1000000"));
			for( i =30; i <=65 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}
			}%>
          </select>
	  
	  <a href="javascript:PrintPg();"><img src="../images/print.gif" border="0"></a> Print Report	  </td>
      <td width="31%"><div align="right"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/srchStud.defSearchSize;
		if(iSearchResult % srchStud.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        Jump To page:
          <select name="jumpto" onChange="SearchNow();">
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
          <%}%>
        </div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr style="font-weight:bold" align="center"> 
      <td  width="19%" height="25" ><font size="1">STUDENT ID</font></td>
      <td width="25%"><font size="1">LASTNAME</font></td>
      <td width="27%"><font size="1">FIRSTNAME</font></td>
      <td width="14%"><font size="1">MI</font></td>
<%if(bolShowCourseYr) {%>
      <td width="14%"><font size="1">COURSE-YR</font></td>
<%}%>
      <td width="9%"><font size="1">SELECT</font></td>
    </tr>
<%for (int j=0; j<vRetResult.size(); j+=7) {%>
    <tr> 
      <td height="25"><font size="1"><%=(String)vRetResult.elementAt(j+1)%></font></td>
      <td ><font size="1"><%=(String)vRetResult.elementAt(j+4)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(j+2)%></font></td>
      <td><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(j+3),"&nbsp;")%></font></td>
<%if(bolShowCourseYr) {
strTemp = (String)vRetResult.elementAt(j + 5);
if(strTemp != null)
	strTemp = strTemp + WI.getStrValue((String)vRetResult.elementAt(j + 6), " - ", "","");
else	
	strTemp = "&nbsp;";
%>
      <td><%=strTemp%></td>
<%}%>
      <td><div align="center"><font size="1">&nbsp; 
          <a href='javascript:viewPersonalData("<%=((String)vRetResult.elementAt(j+1))%>")'>
	  <img src="../images/view.gif" width="40" height="31" border="0"></a>
          </font></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
		<input type="hidden" name="srchType" value="<%=strDataType%>">
		<input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
		<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>