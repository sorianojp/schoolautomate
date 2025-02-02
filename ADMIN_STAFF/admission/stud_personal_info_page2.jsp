<%@ page language="java" import="utility.*,java.util.Vector,enrollment.PersonalInfoManagement,java.util.StringTokenizer,java.sql.*" %>
<%
//request.getSession(false).setMaxInactiveInterval(100000000);//keep the session alive all the time.
//System.out.println(request.getSession(false).getMaxInactiveInterval());


if(request.getSession(false).getAttribute("userIndex") == null){%>
<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">You are already logged out. Please login again.</p>
<%return;}
String strMethodType = request.getMethod();
if(!strMethodType.toLowerCase().equals("post") && request.getParameter("editInformation") != null) {%>
<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">Wrong Call. Please consult support.</p>
<%return;}

	WebInterface WI = new WebInterface(request);
	boolean bolIsMyHome = WI.fillTextValue("my_home").equals("1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%
response.setHeader("pragma","no-cache");//HTTP 1.1
response.setHeader("Cache-Control","no-cache");
response.setHeader("Cache-Control","no-store");
response.addDateHeader("Expires", -1);
response.setDateHeader("max-age", 0);
response.setIntHeader ("Expires", -1); //prevents caching at the proxy server
response.addHeader("cache-Control", "private");
%>
</head>
<script language="JavaScript" src="../../jscript/td.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.formstep2.submit();
}
function submitonce(theform)
{
//if IE 4+ or NS 6+
	//form is submitted here.
	if (document.all||document.getElementById)
	{
	//screen thru every element in the form, and hunt down "submit" and "reset"
		for (i=0;i<theform.length;i++)
		{
			var tempobj=theform.elements[i]
			if(tempobj.type.toLowerCase()=="submit"||tempobj.type.toLowerCase()=="reset")
			//disable em
			tempobj.disabled=true
		}
	}
}
function EditInformation()
{
    document.formstep2.editInformation.value="1";
      
	
}
function  ShowHideDetail() {
	//strShow = 1 , show the table rows. else hide the table rows.
	var strShow = 0;
	if(document.formstep2.stud_employed[0].checked)
		strShow = 1;
	else
		strShow = 0;
	if(strShow == 1) {
		this.showLayer('tr_1');
		this.showLayer('tr_2');
		this.showLayer('tr_3');
		this.showLayer('tr_4');
		this.showLayer('tr_5');
		this.showLayer('tr_6');
		this.showLayer('tr_7');
		this.showLayer('tr_8');
	}
	else {
		this.hideLayer('tr_1');
		this.hideLayer('tr_2');
		this.hideLayer('tr_3');
		this.hideLayer('tr_4');
		this.hideLayer('tr_5');
		this.hideLayer('tr_6');
		this.hideLayer('tr_7');
		this.hideLayer('tr_8');
	}
}
function CopySourceOfIncome() {
	document.formstep2.SOURCE_OF_INCOME.value =
		document.formstep2.SOURCE_OF_INCOME_SELECT[document.formstep2.SOURCE_OF_INCOME_SELECT.selectedIndex].text;
}
function Convert() {
	var pgLoc =
	"../../commfile/conversion.jsp?called_fr_form=formstep2&cm_field_name=height&lb_field_name=weight";

	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ShowHideCivilStat() {
	if(document.formstep2.civil_stat.selectedIndex == 1) {//married.
		//document.formstep2.maiden_name.value = '';
		//document.formstep2.spouse_name.value = '';
		this.showLayer('married_1');
		this.showLayer('married_2');
		this.showLayer('married_3');
		this.showLayer('married_4');
		this.showLayer('married_5');
	}
	else {
		document.formstep2.maiden_name.value = '';
		document.formstep2.spouse_name.value = '';
		this.hideLayer('married_1');
		this.hideLayer('married_2');
		this.hideLayer('married_3');
		this.hideLayer('married_4');

		this.showLayer('married_5');
		if(document.formstep2.civil_stat.selectedIndex == 0) {
			this.hideLayer('married_5');
			document.formstep2.no_of_children.value = '';
		}
	}
}
/**
function ajaxRefreshSession() {
	var objCOAInput = document.getElementById("update_session");
	this.InitXmlHttpObject2(objCOAInput, 2, "checking session...");//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=211";
	this.processRequest(strURL);

	window.setTimeout("ajaxRefreshSession()", 1000);
}
**/
function CopyAddr(strCopyTo) {
	if(strCopyTo == '1') {//copy Home address to contact address
		document.formstep2.con_house_no.value = document.formstep2.res_house_no.value;
		document.formstep2.con_city.value = document.formstep2.res_city.value;
		document.formstep2.con_provience.value = document.formstep2.res_provience.value;
		document.formstep2.con_country.value = document.formstep2.res_country.value;
		document.formstep2.con_zip.value = document.formstep2.res_zip.value;
		document.formstep2.con_tel.value     = document.formstep2.res_tel.value;		
	}
	else {//copy contact address to emergency address
		document.formstep2.emgn_house_no.value = document.formstep2.con_house_no.value;
		document.formstep2.emgn_city.value = document.formstep2.con_city.value;
		document.formstep2.emgn_provience.value = document.formstep2.con_provience.value;
		document.formstep2.emgn_country.value = document.formstep2.con_country.value;
		document.formstep2.emgn_zip.value = document.formstep2.con_zip.value;
		document.formstep2.emgn_tel.value = document.formstep2.con_tel.value;		
	}
}

</script>
<body bgcolor="<%if(bolIsMyHome){%>#9FBFD0<%}else{%>#D2AE72<%}%>" onLoad="ShowHideCivilStat();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	Vector[] vEditInfo = null;
	Vector vCourseApplInfo = null; //note here - basic information of course.
	String strEditMsg = "";
	String strImgFileExt = null;
	String[] astrConvertYr = {"","1st","2nd","3rd","4th","5th","6th"};
	String[] astrConvertSem= {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","stud_personal_info_page2.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Imange file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> Error in opening connection</font></p>
<%
		return;
	}
//authenticate this user.
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null) {
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out.");
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}

boolean bolIsSWU = strSchoolCode.startsWith("SWU");

int iAccessLevel = 2;
if(!bolIsMyHome) {
	CommonUtil comUtil = new CommonUtil();
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Admission","Student Info Mgmt-View/Edit",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0)
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Admission","Student Info Mgmt",request.getRemoteAddr(),
															"stud_personal_info_page2.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0 )//NOT AUTHORIZED.
	{
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Student Affairs","Student Tracker",request.getRemoteAddr(),
															"stud_personal_info_page2.jsp");
		if(iAccessLevel == 0) {
			iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
															"stud_personal_info_page2.jsp");
			if(comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Student Affairs"))
				iAccessLevel = 2;//allow edit.
		}
		if(iAccessLevel ==0) {
			dbOP.cleanUP();
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
}//enter if not my home..

//end of authenticaion code.
if(bolIsMyHome && strSchoolCode.startsWith("NEU"))
	iAccessLevel = 1;

PersonalInfoManagement pInfo = new PersonalInfoManagement();


String strSchoolName = "select school_name from SYS_INFO";
strSchoolName = dbOP.getResultOfAQuery(strSchoolName, 0);

//edit only if it is submitted.
if(request.getParameter("editInformation") != null && request.getParameter("editInformation").compareTo("1") ==0)
{
	if(!pInfo.editPermStudPersonalInfo(dbOP, request,false))
		strErrMsg = pInfo.getErrMsg();
	else
		strErrMsg = "Student information edited successfully.";
}

String strIDNumber = null;
Vector vRecruit = null;
if(strErrMsg == null) {
	strTemp = request.getParameter("stud_id");	
	if(bolIsMyHome)
		strTemp = (String)request.getSession(false).getAttribute("userId");
	strIDNumber = strTemp;
	vEditInfo = pInfo.viewPermStudPersonalInfo(dbOP,strTemp);
	if(vEditInfo == null)
		strErrMsg = pInfo.getErrMsg();
	vRecruit = pInfo.getStudentRecruitDetails(dbOP,strTemp, false);	
}
if(vRecruit == null)
	vRecruit = new Vector();


boolean bolIsAUF  = strSchoolCode.startsWith("AUF");
boolean bolIsVMUF = strSchoolCode.startsWith("VMUF");

String[] strCount = {"I A","I B","II","III","IV","V","VI","VII","VIII","IX","X"};
int iCount = 0;


%>
<form name="formstep2" action="./stud_personal_info_page2.jsp" method="post" onSubmit="submitonce(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <%
if(strSchoolCode != null && strSchoolCode.startsWith("LNU") ){%>
    <tr bgcolor="#A49A6A">
      <td height="26" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>::::
          STUDENT'S GENERAL INFORMATION (SGI) ::::</strong></font></div></td>
    </tr>
    <%}else{%>
    <tr bgcolor="#A49A6A">
      <td height="26" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>::::
          GENERAL STUDENT PERSONAL INFORMATION SHEET (GSPIS) ::::</strong></font></div></td>
    </tr>
    <%}
if(strErrMsg != null){
	dbOP.cleanUP();
%>
    <tr>
      <td height="10" colspan="4">&nbsp; <b><%=strErrMsg%></b></td>
    </tr>
    <% return;
}%>
    <tr>
      <td width="22%" height="23">&nbsp; COURSE </td>
      <td colspan="2"><%=WI.getStrValue(vEditInfo[0].elementAt(0))%></td>
      <td width="15%" rowspan="4" valign="top"><img src="../../upload_img/<%=strIDNumber.toUpperCase()+"."+strImgFileExt%>" width="100" height="100" border="1" align="top">	  
	  </td>
    </tr>
    <tr>
      <td width="22%" height="23">&nbsp; MAJOR </td>
      <td colspan="2"><%=WI.getStrValue(vEditInfo[0].elementAt(2))%></td>
      </tr>
    <tr>
      <td height="25">&nbsp; CURRICULUM YEAR</td>
      <td height="25" colspan="2"><%=WI.getStrValue(vEditInfo[0].elementAt(4))%> to <%=WI.getStrValue(vEditInfo[0].elementAt(5))%></td>
      </tr>
    <tr>
      <td height="25">&nbsp; YEAR LEVEL/TERM</td>
      <td width="21%"><% if(vEditInfo[0].elementAt(8) != null){%>
        <%=astrConvertYr[Integer.parseInt(((String)vEditInfo[0].elementAt(8)))]%>
        <%}else{%>
        N/A
        <%}%>
        / <%=astrConvertSem[Integer.parseInt(((String)vEditInfo[0].elementAt(9)))]%></td>
      <td width="42%">SCHOOL YEAR : <%=WI.getStrValue(vEditInfo[0].elementAt(6))%> to <%=WI.getStrValue(vEditInfo[0].elementAt(7))%></td>
      </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="3"><strong><font color="#FFFFFF" size="2">&nbsp; <%=strCount[iCount++]%> &#8211; PERSONAL DATA</font></strong></td>
    </tr>
    <tr>
      <td width="34%" height="20" valign="bottom">&nbsp; Last Name </td>
      <td width="32%" valign="bottom">First Name </td>
      <td width="34%" valign="bottom">Middle Name </td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <input name="lname" type="text" size="20" maxlength="64" value="<%=(String)vEditInfo[0].elementAt(13)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%if(bolIsMyHome){%>readonly<%}%>></td>
      <td><input name="fname" type="text" size="20" maxlength="64" value="<%=(String)vEditInfo[0].elementAt(11)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%if(bolIsMyHome){%>readonly<%}%>></td>
      <td><input name="mname" type="text" size="20" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(12))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%if(bolIsMyHome){%>readonly<%}%>></td>
    </tr>
    <tr>
      <td colspan="3" height="25">&nbsp; Name in Native Language Character &nbsp;
        <input name="native_lan" type="text" size="48" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(14))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Gender </td>
      <td height="15" valign="bottom">Religion
        <%if(bolIsVMUF || true){%>
        <input type="text" name="scroll_religion" size="16" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_religion','formstep2.religion',true);" class="textbox">
        <%}%>
      </td>
      <td height="15" valign="bottom">Nationality
        <%if(bolIsVMUF || true){%>
        <input type="text" name="scroll_nationality" size="16" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_nationality','formstep2.nationality',true);" class="textbox">
        <%}%>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <select name="gender">
          <%
strTemp = WI.getStrValue(vEditInfo[0].elementAt(15));
if(strTemp.compareTo("M") ==0)
{%>
          <option value="M" selected>Male</option>
          <%}else{%>
          <option value="M">Male</option>
          <%}if(strTemp.compareTo("F") ==0)
{%>
          <option value="F" selected>Female</option>
          <%}else{%>
          <option value="F">Female</option>
          <%}%>
        </select></td>
      <td height="25"><select name="religion">
          <option value=""></option>
          <%
strTemp = WI.getStrValue(vEditInfo[0].elementAt(16));
if(strTemp.length() == 0)
	strTemp = "Roman Catholic";
%>
          <%=dbOP.loadCombo("HR_PRELOAD_RELIGION.RELIGION","HR_PRELOAD_RELIGION.RELIGION"," FROM HR_PRELOAD_RELIGION order by HR_PRELOAD_RELIGION.religion",strTemp,false)%>
        </select>
        <!--
	  <input name="religion" type="text" size="20" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(16))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
-->
      </td>
      <td height="25"><select name="nationality">
          <option value=""></option>
          <%
strTemp = WI.getStrValue(vEditInfo[0].elementAt(17));
if(strTemp.length() == 0)
	strTemp = "Filipino";
%>
          <%=dbOP.loadCombo("HR_PRELOAD_NATIONALITY.NATIONALITY","HR_PRELOAD_NATIONALITY.NATIONALITY"," FROM HR_PRELOAD_NATIONALITY order by HR_PRELOAD_NATIONALITY.nationality",strTemp,false)%>
        </select>
        <!--
	  <input name="nationality" type="text" size="20" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(17))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
-->
      </td>
    </tr>
    <tr valign="bottom">
      <td height="20">&nbsp; Date of Birth<font size="1">(mm/dd/yyyy)</font></td>
      <td height="20">Place of Birth </td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <%
StringTokenizer strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(18)), "/");
String strMM = "";
String strDD = "";
String strYYYY = "";
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();

%>
      <td height="25">&nbsp;
        <input name="mm" type="text" size="2" maxlength="2" value="<%=strMM%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="dd" type="text" size="2" maxlength="2" value="<%=strDD%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy" type="text" size="4" maxlength="4" value="<%=strYYYY%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25"><input name="place_of_birth" type="text" size="20" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(19))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr valign="bottom">
      <td height="25">&nbsp; Civil Status (If Married -&gt;) </td>
      <td height="25"><label id="married_1">Woman : State Maiden's Name</label></td>
      <td height="25"><label id="married_2">Man : Name of Spouse</label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <select name="civil_stat" onChange="ShowHideCivilStat();" onBlur="ShowHideCivilStat()">
          <%
strTemp = WI.getStrValue(vEditInfo[0].elementAt(20));
Vector vList = new Vector();
vList.addElement("Single");
vList.addElement("Married");
if(bolIsAUF) {
	vList.addElement("Separated - Annulled");
	vList.addElement("Separated - Divorced");
	vList.addElement("Separated - Single Parent (never married)");
	vList.addElement("Separated but re-married");
}
else {
	vList.addElement("Widow/Widower");
	vList.addElement("Divorced");
}
		for(int i = 0; i < vList.size(); ++i) {
			if(strTemp.compareToIgnoreCase((String)vList.elementAt(i)) == 0)
				strErrMsg = " selected";
			else
				strErrMsg = "";
%>
          <option <%=strErrMsg%> value="<%=vList.elementAt(i)%>"><%=vList.elementAt(i)%></option>
          <%}%>
        </select></td>
      <td height="25"><label id="married_3">
        <input name="maiden_name" type="text" size="20" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(21))%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </label></td>
      <td height="25"><label id="married_4">
        <input name="spouse_name" type="text" size="20" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(22))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <label id="married_5">No. of children :
        <input name="no_of_children" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(vEditInfo[0].elementAt(23))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        </label>
      </td>
      <td  colspan="2" height="25"><%if(!bolIsVMUF) {%>
        Email Address: &nbsp;
        <input name="email" type="text" size="36" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(24))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <%}%>
      </td>
    </tr>
    <tr>
      <td height="25"><%if(!bolIsAUF){%>
        &nbsp;
        Birth Order &nbsp;&nbsp;&nbsp;&nbsp; :
        <input name="birth_order" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(vEditInfo[0].elementAt(87))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        <%}%>
      </td>
      <td  colspan="2" height="25"><%if(!bolIsVMUF) {%>
        Mobile Number:
        <input name="contact_mob_no" type="text" size="36" maxlength="16"
	  value="<%=WI.getStrValue(vEditInfo[0].elementAt(95))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('formstep2','contact_mob_no');">
        <%}%>
      </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="3"><strong><font color="#FFFFFF" size="2">&nbsp; <%=strCount[iCount++]%> &#8211; ALIEN STATUS DATA (for alien/foreigner student only)</font></strong></td>
    </tr>
    <tr>
      <td width="34%" height="20" valign="bottom">&nbsp; Visa Status</td>
      <td width="32%" valign="bottom">Authorized Stay</td>
      <td width="34%" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <input name="visa_status" type="text" size="20" value="<%=WI.getStrValue(vEditInfo[0].elementAt(26))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><input name="authorized_stay" type="text" size="20" value="<%=WI.getStrValue(vEditInfo[0].elementAt(27))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Passport No.</td>
      <td height="15" valign="bottom">Place of Issue</td>
	  <%
	  strTemp = "Expiration Date";
	  if(bolIsSWU)
	  	strTemp = "Date Issue";		
	  %>
      <td valign="bottom"><%=strTemp%> <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <input name="pp_number" type="text" size="20" value="<%=WI.getStrValue(vEditInfo[0].elementAt(28))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="25"><input name="place_issued" type="text" size="20" value="<%=WI.getStrValue(vEditInfo[0].elementAt(29))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><%
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(30)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";

%>
        <input name="poi_mm" type="text" size="2" maxlength="2" value="<%=strMM%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="poi_dd" type="text" size="2" maxlength="2" value="<%=strDD%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="poi_yyyy" type="text" size="4" maxlength="4" value="<%=strYYYY%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
    </tr>
    <tr valign="bottom">		
      <td height="20">&nbsp; ACR I-Card No.</td>
      <td height="20">Date of Issue<font size="1">(mm/dd/yyyy)</font></td>
      <td>Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <input name="acr_no" type="text" size="20" value="<%=WI.getStrValue(vEditInfo[0].elementAt(31))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="25"><%
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(32)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";

%>
        <input name="acr_doi_mm" type="text" size="2" maxlength="2" value="<%=strMM%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="acr_doi_dd" type="text" size="2" maxlength="2" value="<%=strDD%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="acr_doi_yyyy" type="text" size="4" maxlength="4" value="<%=strYYYY%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><%
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(33)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";

%>
        <input name="acr_expire_mm" type="text" size="2" maxlength="2" value="<%=strMM%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="acr_expire_dd" type="text" size="2" maxlength="2" value="<%=strDD%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="acr_expire_yyyy" type="text" size="4" maxlength="4" value="<%=strYYYY%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
    </tr>
    <tr valign="bottom">
      <td height="25">&nbsp; CRTS NO.</td>
      <td height="25">Date of Issue<font size="1">(mm/dd/yyyy)</font></td>
      <td>Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <input name="crts_no" type="text" size="20" value="<%=WI.getStrValue(vEditInfo[0].elementAt(34))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="25"><%
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(35)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";

%>
        <input name="crts_doi_mm" type="text" size="2" maxlength="2" value="<%=strMM%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="crts_doi_dd" type="text" size="2" maxlength="2" value="<%=strDD%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="crts_doi_yyyy" type="text" size="4" maxlength="4" value="<%=strYYYY%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
      <td><%
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(36)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";

%>
        <input name="crts_expire_mm" type="text" size="2" maxlength="2" value="<%=strMM%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="crts_expire_dd" type="text" size="2" maxlength="2" value="<%=strDD%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="crts_expire_yyyy" type="text" size="4" maxlength="4" value="<%=strYYYY%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
    </tr>
    <tr valign="bottom">
        <td height="25">&nbsp; SSP No.</td>
        <td height="25">Date of Issue<font size="1">(mm/dd/yyyy)</font></td>
        <td>Expiration Date <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <input name="ssp_no" type="text" size="20" value="<%=WI.getStrValue(vEditInfo[0].elementAt(96))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="25"><%
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(97)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";

%>
        <input name="ssp_doi_mm" type="text" size="2" maxlength="2" value="<%=strMM%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="ssp_doi_dd" type="text" size="2" maxlength="2" value="<%=strDD%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="ssp_doi_yyyy" type="text" size="4" maxlength="4" value="<%=strYYYY%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
      <td><%
strToken = new StringTokenizer(WI.getStrValue(vEditInfo[0].elementAt(98)), "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
else	strMM = "";
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
else strDD = "";
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();
else strYYYY = "";

%>
        <input name="ssp_expire_mm" type="text" size="2" maxlength="2" value="<%=strMM%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="ssp_expire_dd" type="text" size="2" maxlength="2" value="<%=strDD%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="ssp_expire_yyyy" type="text" size="4" maxlength="4" value="<%=strYYYY%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
    </tr>
	<tr>
		<td colspan="3" valign="top">
		<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="15%" height="22">&nbsp;</td>
				<td width="21%">Last Name</td>
				<td width="24%">First Name</td>
				<td width="40%">Middle Name</td>
			</tr>
			<tr>
			    <td height="22">&nbsp; Agent Name</td>
			    <td>
				<input name="agent_lname" type="text" size="20" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(101))%>" class="textbox"
	  			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">				</td>
			    <td><input name="agent_fname" type="text" size="20" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(99))%>" class="textbox"
	  			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			    <td><input name="agent_mname" type="text" size="20" maxlength="32" value="<%=WI.getStrValue((String)vEditInfo[0].elementAt(100))%>" class="textbox"
	 				 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			    </tr>
		</table>		</td>
	</tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="2"><strong><font color="#FFFFFF" >&nbsp; </font><font color="#FFFFFF" size="2"><%=strCount[iCount++]%></font><font color="#FFFFFF" > &#8211; RESIDENCE DATA</font></strong></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp; <font color="#0000FF"><u>Home Address: </u></font></td>
    </tr>
    <tr>
      <td width="60%" height="20" valign="bottom">&nbsp; Apartment Name/House
        No./Street/Barangay </td>
      <td width="40%" valign="bottom">City/Municipality </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="res_house_no" type="text" size="40" maxlength="128" value="<%=WI.getStrValue(vEditInfo[0].elementAt(37))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="res_city" type="text" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(38))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Province/State </td>
      <td valign="bottom">Country</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="res_provience" type="text" size="40" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(39))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="res_country" type="text" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(40))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Zipcode</td>
      <td valign="bottom">Telephone Nos. </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="res_zip" type="text" size="40" maxlength="10" value="<%=WI.getStrValue(vEditInfo[0].elementAt(41))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="res_tel" type="text" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(42))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp; <font color="#0000FF"><u>Current Contact Address: </u></font>
	  <input type="checkbox" onClick="CopyAddr('1');"> Copy Home Address
	  </td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Contact
        Person/Guardian Name </td>
      <td valign="bottom">Relation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="con_per_name" type="text" size="40" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(43))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="con_per_relation" type="text" size="30" maxlength="24" value="<%=WI.getStrValue(vEditInfo[0].elementAt(44))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Apartment
        Name/House No./Street/Barangay </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" height="25" valign="bottom">&nbsp;
        <input name="con_house_no" type="text" size="80" maxlength="128" value="<%=WI.getStrValue(vEditInfo[0].elementAt(45))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; City/Municipality</td>
      <td valign="bottom">Province/State </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="con_city" type="text" size="40" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(46))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td valign="bottom"><input name="con_provience" type="text" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(47))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Country </td>
      <td valign="bottom">Zipcode </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="con_country" type="text" size="40" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(48))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="con_zip" type="text" size="30" maxlength="10" value="<%=WI.getStrValue(vEditInfo[0].elementAt(49))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Telephone
        Nos.</td>
      <td valign="bottom">Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="con_tel" type="text" size="40" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(50))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="con_email" type="text" size="30" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(51))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp; <font color="#0000FF"><u>Emergency
        Contact Address:</u></font>
		
		<input type="checkbox" onClick="CopyAddr('2');"> Copy Current Contact Address
		</td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Contact
        Person Name </td>
      <td valign="bottom">Relation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="emgn_per_name" type="text" size="40" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(52))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="emgn_per_rel" type="text" size="30" maxlength="24" value="<%=WI.getStrValue(vEditInfo[0].elementAt(53))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Apartment
        Name/House No./Street/Barangay </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" height="25" valign="bottom">&nbsp;
        <input name="emgn_house_no" type="text" size="80" maxlength="128" value="<%=WI.getStrValue(vEditInfo[0].elementAt(54))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; City/Municipality</td>
      <td valign="bottom">Province/State </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="emgn_city" type="text" size="40" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(55))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td valign="bottom"><input name="emgn_provience" type="text" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(56))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Country</td>
      <td valign="bottom">Zipcode</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="emgn_country" type="text" size="40" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(57))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="emgn_zip" type="text" size="30" maxlength="10" value="<%=WI.getStrValue(vEditInfo[0].elementAt(58))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Telephone
        Nos. </td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="emgn_tel" type="text" size="40" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(59))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><strong><font color="#FFFFFF" size="2">&nbsp; <%=strCount[iCount++]%> &#8211; PHYSICAL DESCRIPTION</font></strong></td>
    </tr>
    <tr valign="bottom">
      <td height="20">&nbsp;</td>
      <td colspan="3"><a href="javascript:Convert();">CLICK FOR CONVERSION</a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr valign="bottom">
      <td width="16%" height="20">&nbsp; Height(cms)</td>
      <td width="16%">Weight(lbs)</td>
      <td width="16%">Built</td>
      <td width="16%">Eye color</td>
      <td width="17%">Hair color</td>
      <td width="19%">Complexion</td>
    </tr>
    <tr>
      <td height="25">&nbsp;
        <input name="height" type="text" size="10" maxlength="16" value="<%=WI.getStrValue(vEditInfo[0].elementAt(60))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="weight" type="text" size="10" maxlength="16" value="<%=WI.getStrValue(vEditInfo[0].elementAt(61))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="built" type="text" size="10" maxlength="16" value="<%=WI.getStrValue(vEditInfo[0].elementAt(62))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><input name="eye_color" type="text" size="10" maxlength="16" value="<%=WI.getStrValue(vEditInfo[0].elementAt(63))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><input name="hair_color" type="text" size="10" maxlength="16" value="<%=WI.getStrValue(vEditInfo[0].elementAt(64))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><input name="complexion" type="text" size="10" maxlength="16" value="<%=WI.getStrValue(vEditInfo[0].elementAt(65))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td colspan="3" height="20">&nbsp; Other Distinguishing Features </td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25">&nbsp;
        <input name="oth_prominent_feature" type="text" size="80" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(66))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td colspan="3" height="20">&nbsp; Physical Handicap or Disability (if any) </td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25">&nbsp;
        <input name="physical_disability" type="text" size="80" maxlength="128" value="<%=WI.getStrValue(vEditInfo[0].elementAt(67))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="2"><strong><font color="#FFFFFF" size="2" >&nbsp; <%=strCount[iCount++]%> &#8211; FAMILY DATA</font></strong></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="bottom">&nbsp; <font color="#0000FF"><u>Parents:</u></font></td>
    </tr>
    <tr>
      <td width="60%" height="20" valign="bottom">&nbsp;
        Father&#8217;s Name </td>
      <td width="40%" valign="bottom">Occupation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="f_name" type="text" size="40" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(68))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="f_occupation" type="text" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(69))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company Name </td>
      <td valign="bottom">Telephone Nos. </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="f_comp_name" type="text" size="40" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(70))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="f_tel" type="text" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(71))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company
        Address</td>
      <td valign="bottom">Father&#8217;s Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="f_comp_addr" type="text" size="40" value="<%=WI.getStrValue(vEditInfo[0].elementAt(72))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="f_email" type="text" size="30" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(73))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Mother&#8217;s
        Name </td>
      <td valign="bottom">Occupation</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="m_name" type="text" size="40" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(74))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="m_occupation" type="text" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(75))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company Name </td>
      <td valign="bottom">Telephone Nos. </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="m_comp_name" type="text" size="40" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(76))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="m_tel" type="text" size="30" maxlength="32" value="<%=WI.getStrValue(vEditInfo[0].elementAt(77))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp; Company
        Address</td>
      <td valign="bottom">Mother&#8217;s Email Address </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;
        <input name="m_comp_addr" type="text" size="40" value="<%=WI.getStrValue(vEditInfo[0].elementAt(78))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td valign="bottom"><input name="m_email" type="text" size="30" maxlength="64" value="<%=WI.getStrValue(vEditInfo[0].elementAt(79))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="34%" height="20">&nbsp; <font color="#0000FF">Brother(s)/Sister(s):</font></td>
      <td width="33%">&nbsp;</td>
      <td width="33%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp; <u>NAME
        <%if(!bolIsVMUF) {%>
        AND DOB
        <%}%>
        </u></td>
      <td><u>COURSE/OCCUPATION </u></td>
      <td><u>SCHOOL/COMPANY</u></td>
    </tr>
    <%
int j=0;
for(int i=0; i<6;){
++i;
if(vEditInfo[1].size() > j)
	strTemp = WI.getStrValue(vEditInfo[1].elementAt(j++));
else
	strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;
        <input name="bsis<%=i%>_name" type="text" size="32" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px; height:20px;">
        &nbsp;&nbsp;
        <%if(!bolIsVMUF) {%>
        <%
if(vEditInfo[1].size() > j)
	strTemp = WI.getStrValue(vEditInfo[1].elementAt(j++));
else
	strTemp = "";
%>
        <input name="bsis<%=i%>_dob" type="text" size="11" maxlength="10" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px; height:20px;">
        <a href="javascript:show_calendar('formstep2.bsis<%=i%>_dob',
	  <%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a>
        <%}
else
	++j;
%>
      </td>
      <%
if(vEditInfo[1].size() > j)
	strTemp = WI.getStrValue(vEditInfo[1].elementAt(j++));
%>
      <td><input name="bsis<%=i%>_occupation" type="text" size="32" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px; height:20px;"></td>
      <%
if(vEditInfo[1].size() > j)
	strTemp = WI.getStrValue(vEditInfo[1].elementAt(j++));
++j;
%>
      <td><input name="bsis<%=i%>_company" type="text" size="32" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px; height:20px;"></td>
    </tr>
    <%}if(strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("PWC")){%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="3"><strong><font color="#FFFFFF" size="2" >&nbsp; <%=strCount[iCount++]%> &#8211; FINANCIAL DATA</font></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2"><%
if(vEditInfo[0].elementAt(89) == null)
	strTemp = "";
else
	strTemp = " checked";
%>
        Student is Employed?
        <input type="radio" name="stud_employed" value="1" onClick="ShowHideDetail();"<%=strTemp%>>
        YES &nbsp;&nbsp;&nbsp;
        <%
if(strTemp.length() > 0)
	strTemp = "";
else
	strTemp = " checked";
%>
        <input type="radio" name="stud_employed" value="0" onClick="ShowHideDetail();"<%=strTemp%>>
        NO</td>
    </tr>
    <tr id="tr_1">
      <td height="25">&nbsp;</td>
      <td width="57%">Occupation</td>
      <td width="41%">Company Name</td>
    </tr>
    <tr id="tr_2">
      <td height="25">&nbsp;</td>
      <td><input name="OCCUPATION" type="text" size="40" value="<%=WI.getStrValue(vEditInfo[0].elementAt(89))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><input name="COMPANY_NAME" type="text" size="40" value="<%=WI.getStrValue(vEditInfo[0].elementAt(90))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr id="tr_3">
      <td height="25">&nbsp;</td>
      <td>Company Address</td>
      <td>&nbsp;</td>
    </tr>
    <tr id="tr_4">
      <td height="25">&nbsp;</td>
      <td colspan="2"><input name="COMPANY_ADDR" type="text" size="65" value="<%=WI.getStrValue(vEditInfo[0].elementAt(91))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr id="tr_5">
      <td height="25">&nbsp;</td>
      <td>Telephone Numbers</td>
      <td>Source of Income</td>
    </tr>
    <tr id="tr_6">
      <td height="25">&nbsp;</td>
      <td><input name="TEL_NO" type="text" size="40" value="<%=WI.getStrValue(vEditInfo[0].elementAt(92))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><select name="SOURCE_OF_INCOME_SELECT" onChange="CopySourceOfIncome();">
          <%=dbOP.loadCombo(" distinct SOURCE_OF_INCOME","SOURCE_OF_INCOME"," from INFO_SELF_EMP_INFO",(String)vEditInfo[0].elementAt(93),
                         false)%>
          <option>Others (pls. specify)</option>
        </select>
      </td>
    </tr>
    <tr id="tr_7">
      <td height="25">&nbsp;</td>
      <td>Range of Income</td>
      <td><input type="text" name="SOURCE_OF_INCOME" value="<%=WI.getStrValue(vEditInfo[0].elementAt(93))%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr id="tr_8">
      <td height="25">&nbsp;</td>
      <td><select name="RANGE_OF_INCOME">
          <option value="0">P 1,000 - P 5,000</option>
          <%
strTemp = WI.getStrValue(vEditInfo[0].elementAt(94));
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>P 5,000 - P 10,000</option>
          <%}else{%>
          <option value="1">P 5,000 - P 10,000</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>P 10,000 - P 15,000</option>
          <%}else{%>
          <option value="2">P 10,000 - P 15,000</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="3" selected>P 15,000 - P 20,000</option>
          <%}else{%>
          <option value="3">P 15,000 - P 20,000</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="4" selected>P 20,000 - P 25,000</option>
          <%}else{%>
          <option value="4">P 20,000 - P 25,000</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="5" selected>P 25,000 and above</option>
          <%}else{%>
          <option value="5">P 25,000 and above</option>
          <%}%>
        </select></td>
      <td>&nbsp;</td>
    </tr>
    <script language="JavaScript">
this.ShowHideDetail();
</script>
  </table>
  <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="4"><strong><font color="#FFFFFF" size="2" >&nbsp; <%=strCount[iCount++]%> &#8211; EDUCATIONAL BACKGROUND</font></strong></td>
    </tr>
    <tr>
      <td width="15%" height="25">&nbsp;</td>
      <td width="36%"><u>NAME</u></td>
      <td width="25%"><u>COURSE/YEAR GRADUATED</u></td>
      <td width="24%"><u>HONORS/AWARDS</u></td>
    </tr>
    <%
j =0;//System.out.println(vEditInfo[2]);
if(vEditInfo[2] != null && vEditInfo[2].size() > j && vEditInfo[2].elementAt(j) != null &&
	((String)vEditInfo[2].elementAt(j)).compareToIgnoreCase("elementary") ==0){++j;
	//System.out.println(vEditInfo[2].elementAt(j));%>
    <tr>
      <td height="25">&nbsp; Elementary
        <%if(bolIsVMUF || true){%>
        <br>
        &nbsp;
        <input type="text" name="scroll_ELEM_SCH_NAME" size="12" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_ELEM_SCH_NAME','formstep2.ELEM_SCH_NAME',true);" class="textbox">
        <%}%>
      </td>
      <td><select name="ELEM_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCREDITED.SCH_NAME","SCH_ACCREDITED.SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_ACCREDITED.SCH_NAME",WI.getStrValue(vEditInfo[2].elementAt(j++)),false)%>
        </select>
      </td>
      <td><input name="ELEM_COURSE_TAKEN" type="text" size="16" maxlength="64" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <input name="ELEM_YEAR_GRAD" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="ELEM_HONOR_AWARD" type="text" size="28" maxlength="64" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp; Elementary
        <%if(bolIsVMUF || true){%>
        <br>
        &nbsp;
        <input type="text" name="scroll_ELEM_SCH_NAME" size="12" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_ELEM_SCH_NAME','formstep2.ELEM_SCH_NAME',true);" class="textbox">
        <%}%>
      </td>
      <td><select name="ELEM_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCREDITED.SCH_NAME","SCH_ACCREDITED.SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_ACCREDITED.SCH_NAME",WI.fillTextValue("ELEM_SCH_NAME"),false)%>
        </select></td>
      <td><input name="ELEM_COURSE_TAKEN" type="text" size="16" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <input name="ELEM_YEAR_GRAD" type="text" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="ELEM_HONOR_AWARD" type="text" size="28" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <%}if(vEditInfo[2] != null && vEditInfo[2].size() > j &&  vEditInfo[2].elementAt(j) != null &&
	((String)vEditInfo[2].elementAt(j)).compareToIgnoreCase("High school") ==0){++j;%>
    <tr>
      <td height="25">&nbsp; High School
        <%if(bolIsVMUF || true){%>
        <br>
        &nbsp;
        <input type="text" name="scroll_HIGH_SCH_NAME" size="12" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_HIGH_SCH_NAME','formstep2.HIGH_SCH_NAME',true);" class="textbox">
        <%}%>
      </td>
      <td><select name="HIGH_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCREDITED.SCH_NAME","SCH_ACCREDITED.SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_ACCREDITED.SCH_NAME",WI.getStrValue(vEditInfo[2].elementAt(j++)),false)%>
        </select>
        <!--<input name="HIGH_SCH_NAME" type="text" size="20" maxlength="64" value="<%//=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">--></td>
      <td><input name="HIGH_COURSE_TAKEN" type="text" size="16" maxlength="64" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <input name="HIGH_YEAR_GRAD" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="HIGH_HONOR_AWARD" type="text" size="28" maxlength="64" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp; High School
        <%if(bolIsVMUF || true){%>
        <br>
        &nbsp;
        <input type="text" name="scroll_HIGH_SCH_NAME" size="12" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_HIGH_SCH_NAME','formstep2.HIGH_SCH_NAME',true);" class="textbox">
        <%}%>
      </td>
      <td><select name="HIGH_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCREDITED.SCH_NAME","SCH_ACCREDITED.SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_ACCREDITED.SCH_NAME",WI.fillTextValue("HIGH_SCH_NAME"),false)%>
        </select>
        <!--<input name="HIGH_SCH_NAME" type="text" size="20" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">--></td>
      <td><input name="HIGH_COURSE_TAKEN" type="text" size="16" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <input name="HIGH_YEAR_GRAD" type="text" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="HIGH_HONOR_AWARD" type="text" size="28" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <%}if(vEditInfo[2] != null && vEditInfo[2].size() > j &&  vEditInfo[2].elementAt(j) != null &&
	((String)vEditInfo[2].elementAt(j)).compareToIgnoreCase("College") ==0){++j;%>
    <tr>
      <td height="25">&nbsp; College
        <%if(bolIsVMUF || true){%>
        <br>
        &nbsp;
        <input type="text" name="scroll_COLLEGE_NAME" size="12" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_COLLEGE_NAME','formstep2.COLLEGE_NAME',true);" class="textbox">
        <%}%>
      </td>
      <td><select name="COLLEGE_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCREDITED.SCH_NAME","SCH_ACCREDITED.SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_ACCREDITED.SCH_NAME",WI.getStrValue(vEditInfo[2].elementAt(j++)),false)%>
        </select>
        <!--<input name="COLLEGE_NAME" type="text" size="20" maxlength="64" value="<%//=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">--></td>
      <td><input name="COLLEGE_COURSE_TAKEN" type="text" size="16" maxlength="64" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <input name="COLLEGE_YEAR_GRAD" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="COLLEGE_HONOR_AWARD" type="text" size="28" maxlength="64" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp; College
        <%if(bolIsVMUF || true){%>
        <br>
        &nbsp;
        <input type="text" name="scroll_COLLEGE_NAME" size="12" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_COLLEGE_NAME','formstep2.COLLEGE_NAME',true);" class="textbox">
        <%}%>
      </td>
      <td><select name="COLLEGE_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCREDITED.SCH_NAME","SCH_ACCREDITED.SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_ACCREDITED.SCH_NAME",WI.fillTextValue("COLLEGE_NAME"),false)%>
        </select>
        <!--<input name="COLLEGE_NAME" type="text" size="20" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">--></td>
      <td><input name="COLLEGE_COURSE_TAKEN" type="text" size="16" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <input name="COLLEGE_YEAR_GRAD" type="text" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="COLLEGE_HONOR_AWARD" type="text" size="28" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <%}if(vEditInfo[2] != null && vEditInfo[2].size() > j &&  vEditInfo[2].elementAt(j) != null &&
	((String)vEditInfo[2].elementAt(j)).compareToIgnoreCase("PG") ==0){++j;%>
    <tr>
      <td height="25">&nbsp; Post Graduate
        <%if(bolIsVMUF || true){%>
        <br>
        &nbsp;
        <input type="text" name="scroll_PG_SCH_NAME" size="12" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_PG_SCH_NAME','formstep2.PG_SCH_NAME',true);" class="textbox">
        <%}%>
      </td>
      <td><select name="PG_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCREDITED.SCH_NAME","SCH_ACCREDITED.SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_ACCREDITED.SCH_NAME",WI.getStrValue(vEditInfo[2].elementAt(j++)),false)%>
        </select>
        <!--<input name="PG_SCH_NAME" type="text" size="20" maxlength="64" value="<%//=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">--></td>
      <td><input name="PG_COURSE_TAKEN" type="text" size="16" maxlength="64" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <input name="PG_YEAR_GRAD" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="PG_HONOR_AWARD" type="text" size="28" maxlength="64" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp; Post Graduate
        <%if(bolIsVMUF || true){%>
        <br>
        &nbsp;
        <input type="text" name="scroll_PG_SCH_NAME" size="12" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_PG_SCH_NAME','formstep2.PG_SCH_NAME',true);" class="textbox">
        <%}%>
      </td>
      <td><select name="PG_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCREDITED.SCH_NAME","SCH_ACCREDITED.SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_ACCREDITED.SCH_NAME",WI.fillTextValue("PG_SCH_NAME"),false)%>
        </select>
        <!--<input name="PG_SCH_NAME" type="text" size="20" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">--></td>
      <td><input name="PG_COURSE_TAKEN" type="text" size="16" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <input name="PG_YEAR_GRAD" type="text" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="PG_HONOR_AWARD" type="text" size="28" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <%}if(vEditInfo[2] != null && vEditInfo[2].size() > j &&  vEditInfo[2].elementAt(j) != null &&
	((String)vEditInfo[2].elementAt(j)).compareToIgnoreCase("Vocatinal") ==0){++j;%>
    <tr>
      <td height="25">&nbsp; Vocational
        <%if(bolIsVMUF || true){%>
        <br>
        &nbsp;
        <input type="text" name="scroll_VOC_SCH_NAME" size="12" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_VOC_SCH_NAME','formstep2.VOC_SCH_NAME',true);" class="textbox">
        <%}%>
      </td>
      <td><select name="VOC_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCREDITED.SCH_NAME","SCH_ACCREDITED.SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_ACCREDITED.SCH_NAME",WI.getStrValue(vEditInfo[2].elementAt(j++)),false)%>
        </select>
        <!--<input name="VOC_SCH_NAME" type="text" size="20" maxlength="64" value="<%//=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">--></td>
      <td><input name="VOC_COURSE_TAKEN" type="text" size="16" maxlength="64" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <input name="VOC_YEAR_GRAD" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="VOC_HONOR_AWARD" type="text" size="28" maxlength="64" value="<%=WI.getStrValue(vEditInfo[2].elementAt(j++))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp; Vocational
        <%if(bolIsVMUF || true){%>
        <br>
        &nbsp;
        <input type="text" name="scroll_VOC_SCH_NAME" size="12" style="font-size:12px"
		  onKeyUp="AutoScrollList('formstep2.scroll_VOC_SCH_NAME','formstep2.VOC_SCH_NAME',true);" class="textbox">
        <%}%>
      </td>
      <td><select name="VOC_SCH_NAME" style="font-size:10px; width:300px">
          <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCREDITED.SCH_NAME","SCH_ACCREDITED.SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_ACCREDITED.SCH_NAME",WI.fillTextValue("VOC_SCH_NAME"),false)%>
        </select>
        <!--<input name="VOC_SCH_NAME" type="text" size="20" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">--></td>
      <td><input name="VOC_COURSE_TAKEN" type="text" size="16" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <input name="VOC_YEAR_GRAD" type="text" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><input name="VOC_HONOR_AWARD" type="text" size="28" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25"  colspan="2"><strong><font color="#FFFFFF" size="2" >&nbsp; <%=strCount[iCount++]%> &#8211; GENERAL QUALIFICATION</font></strong></td>
    </tr>
    <tr>
      <td width="10%">&nbsp;<font color="#0000FF">Languages:</font></td>
      <td height="25"><input name="LANGUAGE_KNOWN" type="text" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(80))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td>&nbsp;<font color="#0000FF">Hobbies:</font></td>
      <td height="25"><input name="HOBBY" type="text" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(81))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <tr>
      <td><font color="#0000FF">&nbsp;Skills:</font></td>
      <td height="25"><input name="SKILL" type="text" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(82))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td><font color="#0000FF">&nbsp;Talents:</font></td>
      <td height="25"><input name="TALENT" type="text" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(83))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td>&nbsp;<font color="#0000FF">Sports:</font></td>
      <td height="25"><input name="SPORT" type="text" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(84))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td colspan="2" valign="bottom"><font color="#0000FF">&nbsp;Honors/Awards/Merits: (ex. &quot;Model
        Student, 1990&quot;)</font> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25"><input name="AWARD" type="text" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(85))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td colspan="2" valign="bottom">&nbsp;<font color="#0000FF">Extra-Curricular Activities
        : (Organizations, Clubs, etc)</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25"><input name="EXT_CURRICULAR_ACT" type="text" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(86))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td colspan="2" valign="bottom">&nbsp;<font color="#0000FF">Why am I taking
        this course?</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25"><input name="WHY_THIS_COURSE" type="text" size="80" value="<%=WI.getStrValue(vEditInfo[0].elementAt(88))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="2"><strong><font color="#FFFFFF" size="2">&nbsp; <%=strCount[iCount++]%> &#8211; REFERENCES</font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;Write two or three references
        who can vouch or guarantee for your total behavior.</td>
    </tr>
    <tr>
      <td width="37%" height="25">&nbsp;&nbsp;&nbsp;<u>NAME</u></td>
      <td width="63%"><u>ADDRESS/TEL. NOS.</u></td>
    </tr>
    <%//System.out.println(vEditInfo[3]);
j = 0;
if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;&nbsp;
        <input name="REF_NAME1" type="text" size="24" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <%
if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
++j;
%>
      <td><input name="REF_ADDR1" type="text" size="40" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>
      <td height="25">&nbsp;&nbsp;
        <input name="REF_NAME2" type="text" size="24" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
++j;
%>
      <td><input name="REF_ADDR2" type="text" size="40" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;&nbsp;
        <input name="REF_NAME3" type="text" size="24" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <%if(vEditInfo[3].size() > j)
	strTemp = WI.getStrValue(vEditInfo[3].elementAt(j++));
else
	strTemp = "";
%>
      <td><input name="REF_ADDR3" type="text" size="40" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
  </table>
   <%
  
   vRetResult = pInfo.getRecruitmentInfo(dbOP, request,4);
		if(vRetResult != null && vRetResult.size() > 0)
		{    %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="4"><strong><font color="#FFFFFF" size="2">&nbsp; <%=strCount[iCount++]%> &#8211; Admission / Registration </font></strong></td>
      </tr>
    
	 <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;How did you know <%= WI.getStrValue(strSchoolName) %> ?(Please check the box) </td>
      </tr>   
   
		 <%
		 iCount = 1;
		
	for(int i = 0; i < vRetResult.size(); i += 2, iCount++)
		{	
		
		
		strTemp = WI.fillTextValue("detail_index_"+ iCount); 
            if(strTemp.equals((String)vRetResult.elementAt(i)) || vRecruit.indexOf((String)vRetResult.elementAt(i)) >-1)
	              strErrMsg = "checked";
				  else
				  strErrMsg = "";
				  
 	
  %>
    <tr>
      <td colspan="2">&nbsp;&nbsp;
        <input type="checkbox" name="detail_index_<%=iCount%>" 
		value="<%=(String)vRetResult.elementAt(i)%>" <%=strErrMsg%>/>
        <%=(String)vRetResult.elementAt(i+1)%> </td>
    </tr>
    <%}%>
    <input type="hidden" name="rec_detail_count" value="<%= iCount%>">
  
    <tr>
    <%
	 if(vRecruit !=null && vRecruit.size()>0)
	 	strTemp = WI.getStrValue((String)vRecruit.elementAt(1));	 
	 else
	 	strTemp = WI.fillTextValue("other");
	%>
      <td colspan="2">&nbsp;&nbsp; 
        others
        <input type="text" name="other" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" />      </td>
    </tr>
    <tr>
      <td height="25" colspan="3"></td>
      </tr>
    <tr>
      <%
	 if(vRecruit !=null && vRecruit.size()>0)
	 strTemp = WI.getStrValue((String)vRecruit.elementAt(0));
	 
	 else
	 strTemp = WI.fillTextValue("person");
	%>
      <td width="27%" height="25">&nbsp;&nbsp; IF through a person, please specify: </td>
      <td width="73%"><input type="text" name="person" value="<%= strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
    </tr>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="30%">&nbsp;</td>
      <td width="55%">&nbsp;</td>
    </tr>
    <%
if( iAccessLevel >1 && WI.fillTextValue("removeEdit").compareTo("1") !=0){%>
    <tr>
      <td colspan="2" style="font-size:14px; font-weight:bold;"> NOTE : By saving the information, I hereby state and acknowledge that the information provided is true and
        complete to the best of my knowledge. </td>
    </tr>
    <tr>
      <td>&nbsp;
        <!--<label id="update_session"></label>
		  <input type="button" onClick="ajaxRefreshSession();">-->
      </td>
      <td align="right"><div align="left"><font size="1">click to save changes
          in the informaiton -&gt;</font>
          <input type="submit" name="sub" value="Change Information >>" onClick="EditInformation();">
        </div></td>
    </tr>
    <%}%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
      <td bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <%if(bolIsMyHome){%>
  <input type="hidden" name="info_index" value="<%=(String)request.getSession(false).getAttribute("userIndex")%>">
  <%}else{%>
  <input type="hidden" name="info_index" value="<%=(String)vEditInfo[0].elementAt(10)%>">
  <%}%>
  <input type="hidden" name="editInformation" value="0">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
