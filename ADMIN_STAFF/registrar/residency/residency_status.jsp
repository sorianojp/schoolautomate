<%@ page language="java" import="utility.*,enrollment.GradeSystem, enrollment.GradeSystemExtn ,java.util.Vector" %>
<%
///get school code here.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strInfo5   = (String)request.getSession(false).getAttribute("info5");

boolean bolIsCGH = false;
if(strSchCode == null)
	strSchCode = "";


bolIsCGH = strSchCode.startsWith("CGH");

//bolIsCGH = true;
	WebInterface WI = new WebInterface(request);


//boolean bolIsEACCOG = (WI.fillTextValue("is_eac_cog").length() > 0);

boolean bolShowGrade = true;
if(WI.fillTextValue("online_advising").equals("1"))
	bolShowGrade = false;

if(WI.fillTextValue("print_pg").equals("1") && strSchCode.startsWith("UPH") && WI.getStrValue(strInfo5).equals("jonelta") ) {%>
		<jsp:forward page="./residency_status_print_uphjonelta.jsp" />
<%}

if(WI.fillTextValue("print_pg").equals("1")) {%>
		<jsp:forward page="./residency_status_print2.jsp" />
	<%
	}
if(WI.fillTextValue("print_pg").equals("2")) {%>
		<jsp:forward page="./uph_summary_of_grade.jsp" />
	<%
	}
if(WI.fillTextValue("print_pg").equals("3")) {%>
		<jsp:forward page="./uph_summary_of_grade_detailed.jsp" />
	<%
	}
if(WI.fillTextValue("print_pg").equals("4")) {
	if(strSchCode.startsWith("NEU")){
%>
	<jsp:forward page="./certificate_of_grade_NEU.jsp" />
<%}else{%>
		<jsp:forward page="./certificate_of_grade_CDD.jsp" />
<%}
}
if(WI.fillTextValue("print_pg").equals("5")) {%>
		<jsp:forward page="./certificate_of_grade_UL.jsp" />
	<%
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript">
function focusID() {
	if(document.form_.stud_id)
		document.form_.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CallPrint() {
	<%if(bolIsCGH){%>
		if(document.form_.redirect_to_print.value == "1")
			PPG('');
	<%}%>
}
function PPG(strSubmitStat){ 
	var strRemark = "";
	<%if(bolIsCGH && false){%>
		///changed -- now i have to keep remark for both.
		//if(document.form_.is_scholastic.checked)
			strRemark = "REMARKS : For evaluation purpose/ reference only.";
	<%}%>
	
	if(strSubmitStat == '1' && strRemark == "") {
		<%if(bolIsCGH ){%>
			strRemark = prompt("Please enter remark to be printed on residency status print out.","");
		<%}else{%>
			strRemark = prompt("Please enter remark to be printed on residency status print out.","REMARKS : ");
		<%}%>
		if(strRemark == null)
        	strRemark = "";
    }
	<%//if(!bolIsEACCOG){%>
	if(strSubmitStat == '4') {
		strRemark = prompt("Please enter remark to be printed on print out.","");
		if(strRemark == null)
        	strRemark = "";
    }
	<%//}%>
	if(strSubmitStat == '5') {
		document.form_.remarks.value = document.form_.ul_remark.value;

		if(document.form_.remarks.value == '') {
			alert("Please provide header and footer remark");
			return;
		}
    }
	else 
		document.form_.remarks.value = strRemark;
	document.form_.print_pg.value = strSubmitStat;
	if(strSubmitStat != '')
		this.SubmitOnce("form_");
}
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;

		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	int i=0; int j=0;
	int iYear = 0;
	int iSem  = 0;
	int iTempYear = 0;
	int iTempSem = 0;
	int iSchYrFrom = 0;
	int iTempSchYrFrom = 0;

	double dGWA         = 0d;

	String[] astrPrepPropInfo = {""," (Preparatory)","(Proper)"};
	String[] astrConvertYear ={"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String strResidencyStatus = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-RESIDENCY STATUS MONITORING","residency_status.jsp");
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
int iAccessLevel = 0;
if(WI.fillTextValue("online_advising").compareTo("1") ==0)
	iAccessLevel = 2;
else {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","RESIDENCY STATUS MONITORING",request.getRemoteAddr(),
														null);
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(),
						null);
	}
	if(iAccessLevel == 0) {
		//if called from guidance.
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
															null);
		if(iAccessLevel > 1)
			iAccessLevel = 1;
	}
}

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

//for neu, i have to check if user belong to same college.
boolean bolCheckCollegeRestriction = false;
boolean bolIsFatalErr = false;

String strStudID = WI.fillTextValue("stud_id");
if(WI.fillTextValue("online_advising").compareTo("1") == 0) {
	strStudID = (String)request.getSession(false).getAttribute("userId");
}


if(strSchCode.startsWith("CIT"))
	bolCheckCollegeRestriction = true;
if(strStudID.length() > 0 && bolCheckCollegeRestriction && WI.fillTextValue("online_advising").length() == 0) {
	if(!comUtil.isLoggedInUserBelongToCollegeOfStudent(dbOP, request, null,strStudID, null)) {
		bolIsFatalErr = true;
		strErrMsg = comUtil.getErrMsg();
	}	
}


GradeSystem GS = new GradeSystem();
GradeSystemExtn GSExtn = new GradeSystemExtn();
enrollment.GradeSystemTransferee GSTransferee = new enrollment.GradeSystemTransferee();

Vector vCourseHist = null;
Vector vResSummary = null;
Vector vResDetail = null;
Vector vTFInfo = null;
Vector vTemp = null;


String strTempCourse = null;
String strTempMajor = null;
String strTempType = null;
String strTempQuery = null;
String strCourseType = null;

int iCtr = 0;
int iMaxSel = 0;

String strUserIndex = null;


if(strStudID.length() > 0 && !bolIsFatalErr)
{
	vTFInfo = GSTransferee.viewFinalGradePerYrSemTransferee(dbOP,strStudID,true);

	vCourseHist = GSExtn.retrieveCourseHistory(dbOP, strStudID);
	if (vCourseHist == null)
		strErrMsg = GSExtn.getErrMsg();

	student.GWA gwa = new student.GWA();
	dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));

	vResSummary = GS.getResidencySummary(dbOP,strStudID);
	if(vResSummary == null)
		strErrMsg = GS.getErrMsg();
	else{
		strUserIndex = (String)vResSummary.elementAt(0);
	if (WI.fillTextValue("selCourse").length()>0)
		{
			if (WI.fillTextValue("selCourse").equals("under"))
			{
				strTempQuery = " and (stud_curriculum_hist.course_type = 0 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 4)";
				vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vResSummary.elementAt(0),"0", strTempQuery);
				strCourseType = "0";
			}
			else if (WI.fillTextValue("selCourse").equals("post"))
			{
				strTempQuery = " and (stud_curriculum_hist.course_type = 1 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 2)";
				vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vResSummary.elementAt(0),"1", strTempQuery);
				strCourseType = "1";
			}
			else
			{
				strTempCourse = WI.getStrValue(WI.fillTextValue("c_idx"+WI.fillTextValue("selCourse")),"");
				strTempMajor = WI.getStrValue(WI.fillTextValue("d_idx"+WI.fillTextValue("selCourse")),"");
				strTempType = WI.getStrValue(WI.fillTextValue("c_type"+WI.fillTextValue("selCourse")),"");
				if (strTempCourse.length()>0 && strTempType.length()>0)
				{
					strTempQuery = " and stud_curriculum_hist.course_index = "+strTempCourse;
					if (!strTempType.equals("1"))
						strTempQuery += " and (stud_curriculum_hist.course_type = 0 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 4)";
					if (strTempMajor.length()>0)
						strTempQuery += " and stud_curriculum_hist.major_index = "+strTempMajor;
					vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vResSummary.elementAt(0),strTempType, strTempQuery);
				}
				strCourseType = strTempType;
			}
			//System.out.println(strTempQuery);System.out.println(GS.getErrMsg());
		}
	}
}


%>
<form action="./residency_status.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
	<%
	strTemp = "RESIDENCY STATUS MONITORING";
	//if(bolIsEACCOG)
	//	strTemp = "GRADE CERTIFICATION PAGE";
	%>
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: <%=strTemp%> ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="4"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 5);
else
	strTemp = null;
if(strTemp != null){%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="26%">Student ID:
        <%
String strReadOnly = "";

if(WI.fillTextValue("online_advising").compareTo("1") == 0) {
	strTemp = "textbox_noborder ";
	strReadOnly = "readonly";
	strErrMsg = (String)request.getSession(false).getAttribute("userId");
}
else {
	strTemp = "textbox";
	strReadOnly = "onKeyUp=\"AjaxMapName('1');\"";
}
%>
        &nbsp;&nbsp; <input name="stud_id" type="text" size="16" value="<%=WI.getStrValue(strStudID)%>" class="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strReadOnly%>>      </td>
      <td width="15%">
<%
if(!WI.fillTextValue("online_advising").equals("1")) {%>
	  <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>
<%}%>
</td>
      <td width="55%">
        <%
if(WI.fillTextValue("online_advising").compareTo("1") != 0 || true){%>
        <!--<input type="image" src="../../../images/form_proceed.gif" onClick="CallPrint();"> -->
<input type="submit" name="1" value="Refresh Page" style="font-size:10px; height:26px;border: 1px solid #FF0000;"
	    onClick="CallPrint();">
<%}
if(bolIsCGH){
strTemp = WI.fillTextValue("is_scholastic");
if(strTemp.equals("1"))
	strTemp = "checked";
else
	strTemp = "";
%>
        <input type="checkbox" name="is_scholastic" value="1" <%=strTemp%>>
        <font size="1" color="#0000FF"><b>For Scholastic Record(Print only) </b></font>
        <%}%></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%if(strSchCode.startsWith("UL")){%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td colspan="2">Name:
	  <input type="text" name="pos_new" value="<%=WI.fillTextValue("pos_new")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
      <td>Designation:
	  <input type="text" name="des_new" value="<%=WI.fillTextValue("des_new")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td colspan="3">
	  <input type="checkbox" name="hide_1" value="checked" <%=WI.fillTextValue("hide_1")%>> Hide Units Required and Units Completion Information
	  <input type="checkbox" name="hide_2" value="checked" <%=WI.fillTextValue("hide_2")%>> Hide GWA Information	  </td>
      <td>&nbsp;</td>
    </tr>
<%if(strSchCode.startsWith("UL")){%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td colspan="3">Enter Header and Footer Remark for Other Grade Certification: 
        <br>
        <textarea name="ul_remark" class="textbox" cols="70" rows="4"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("ul_remark")%></textarea>
	  
	  
	  </td>
      <td>&nbsp;</td>
    </tr>
<%}%>    <tr bgcolor="#FFFFFF">
      <td colspan="5" height="25">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>
	  <hr size="1"></td>
    </tr>
  </table>

<%if(vResSummary != null && vResSummary.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td width="15%">Student
        name : <strong></strong></td>
      <td width="45%"><strong><%=WI.formatName((String)vResSummary.elementAt(1),(String)vResSummary.elementAt(2),(String)vResSummary.elementAt(3),1)%></strong></td>
      <td width="6%">Year : </td>
      <td width="32%"><strong><%=astrConvertYear[Integer.parseInt(WI.getStrValue(vResSummary.elementAt(10),"0"))]%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td>Course/Major :</td>
      <td><strong><%=(String)vResSummary.elementAt(6)%>/<%=WI.getStrValue(vResSummary.elementAt(7))%> (<%=(String)vResSummary.elementAt(8)%>-<%=(String)vResSummary.elementAt(9)%>)</strong></td>
      <td>Status:<strong>
        </strong></td>
      <td><strong>
<%
strResidencyStatus = (String)vResSummary.elementAt(14);
if(strResidencyStatus != null && strResidencyStatus.compareTo("0") ==0)
	strResidencyStatus = "Regular";
else if(strResidencyStatus != null && strResidencyStatus.compareTo("1") ==0)
	strResidencyStatus = "Irregular";
%>			   &nbsp;<%=WI.getStrValue(strResidencyStatus)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25"  colspan="2">Total units required for this course : <strong><%=(String)vResSummary.elementAt(12)%></strong></td>
      <td height="25"  colspan="2">Total Credit Earned: <strong><%=WI.getStrValue(vResSummary.elementAt(13))%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><% if (!((String)vResSummary.elementAt(11)).equals("1") || !((String)vResSummary.elementAt(11)).equals("2")){%>GWA :<%}%>&nbsp;</td>
      <td height="25"><% if (!((String)vResSummary.elementAt(11)).equals("1") || !((String)vResSummary.elementAt(11)).equals("2")){%><strong><%=CommonUtil.formatFloat(dGWA,true)%></strong><%}%>&nbsp;</td>
    </tr>
  </table>
	<%if (vCourseHist!= null && vCourseHist.size()>0) {
	vTemp = (Vector)vCourseHist.elementAt(0);
	if (vTemp != null && vTemp.size()>0 && false){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#FFFFFF">
      <td height="10" colspan="4" >&nbsp;</td>
    </tr>
	<tr bgcolor="#B9B292">
      <td height="25" colspan="4" align="center" ><font color="#FFFFFF"><strong>BASIC EDUCATION</strong></font></td>
    </tr>
	<%for (iCtr = 0; iCtr < vTemp.size(); iCtr+=12) {%>
	<tr>
		<td width="25%" align="left" height="25">
		<%if (iCtr < vTemp.size()){%>
		<input type="checkbox" name="basic" value="<%=(String)vTemp.elementAt(iCtr+1)%>"><%=(String)vTemp.elementAt(iCtr+2)%>
		<%} else {%>&nbsp;<%}%></td>
		<td width="25%" align="left">
		<%if ((iCtr+3) < vTemp.size()){%><input type="checkbox" name="basic" value="<%=(String)vTemp.elementAt(iCtr+4)%>"><%=(String)vTemp.elementAt(iCtr+5)%>
		<%} else {%>&nbsp;<%}%></td>
		<td width="25%" align="left">
		<%if (iCtr+6 < vTemp.size()){%><input type="checkbox" name="basic" value="<%=(String)vTemp.elementAt(iCtr+7)%>"><%=(String)vTemp.elementAt(iCtr+8)%>
		<%} else {%>&nbsp;<%}%></td>
		<td width="25%" align="left">
		<%if (iCtr+9 < vTemp.size()){%><input type="checkbox" name="basic" value="<%=(String)vTemp.elementAt(iCtr+10)%>"><%=(String)vTemp.elementAt(iCtr+11)%>
		<%} else {%>&nbsp;<%}%></td>
	</tr>
	<%}%>
	</table>
	<%}
	strTemp = WI.fillTextValue("selCourse");
	vTemp = (Vector)vCourseHist.elementAt(1);
	if (vTemp != null && vTemp.size()>0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#FFFFFF">
      <td height="10" colspan="4" >&nbsp;</td>
    </tr>
	<tr bgcolor="#B9B292">
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>UNDERGRADUATE</strong></font></td>
    </tr>
    <tr>
    	<td width="5%" height="25">
    	<%
    	if (strTemp.equals("under")){%>
    	<input name="selCourse" type="radio" value="under" checked><%} else {%>
    	<input name="selCourse" type="radio" value="under"><%}%></td>
    	<td width="40%" align="left"><font size="1"><strong>COURSE</strong></font></td>
    	<td width="50%" align="left"><font size="1"><strong>MAJOR</strong></font></td>
    </tr>
	<%for (iCtr = 0; iCtr < vTemp.size(); iCtr += 5, ++iMaxSel) {%>
	<tr>
		<td align="left" height="25">
		<%if (strTemp.equals(Integer.toString(iMaxSel))){%>
		<input name="selCourse" type="radio" value="<%=iMaxSel%>" checked onClick="document.form_.redirect_to_print.value='1';"><%} else {%>
		<input name="selCourse" type="radio" value="<%=iMaxSel%>" onClick="document.form_.redirect_to_print.value='1';"><%}%></td>
		<td align="left"><font size="1"><%=(String)vTemp.elementAt(iCtr+3)%></font></td>
		<td align="left"><font size="1"><%=WI.getStrValue((String)vTemp.elementAt(iCtr+4),"&nbsp;")%></font></td>
		<input type="hidden" name="c_idx<%=iMaxSel%>" value="<%=(String)vTemp.elementAt(iCtr+1)%>">
		<input type="hidden" name="d_idx<%=iMaxSel%>" value="<%=(String)vTemp.elementAt(iCtr+2)%>">
		<input type="hidden" name="c_type<%=iMaxSel%>" value="<%=(String)vTemp.elementAt(iCtr)%>">
	</tr>
	<%}%>
    </table>
	<%}
	vTemp = (Vector)vCourseHist.elementAt(2);
	if (vTemp != null && vTemp.size()>0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#FFFFFF">
      <td height="10" colspan="4" >&nbsp;</td>
    </tr>
	<tr bgcolor="#B9B292">
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>POST GRADUATE</strong></font></td>
    </tr>
    <tr>
    	<td width="5%" height="25">
    	<%if (strTemp.equals("post")){%>
    	<input name="selCourse" type="radio" value="post" checked><%} else {%>
    	<input name="selCourse" type="radio" value="post"><%}%></td>
    	<td width="40%" align="left"><font size="1"><strong>COURSE</strong></font></td>
    	<td width="50%" align="left"><font size="1"><strong>MAJOR</strong></font></td>
    </tr>
	<%for (iCtr = 0; iCtr < vTemp.size(); iCtr += 5, ++iMaxSel) {%>
	<tr>
		<td align="left" height="25">
		<%if (strTemp.equals(Integer.toString(iMaxSel))){%>
		<input name="selCourse" type="radio" value="<%=iMaxSel%>" checked><%} else {%>
		<input name="selCourse" type="radio" value="<%=iMaxSel%>"><%}%></td>
		<td align="left"><font size="1"><%=(String)vTemp.elementAt(iCtr+3)%></font></td>
		<td align="left"><font size="1"><%=WI.getStrValue((String)vTemp.elementAt(iCtr+4),"&nbsp;")%></font></td>
		<input type="hidden" name="c_idx<%=iMaxSel%>" value="<%=(String)vTemp.elementAt(iCtr+1)%>">
		<input type="hidden" name="d_idx<%=iMaxSel%>" value="<%=(String)vTemp.elementAt(iCtr+2)%>">
		<input type="hidden" name="c_type<%=iMaxSel%>" value="<%=(String)vTemp.elementAt(iCtr)%>">
	</tr>
	<%}%>
    </table>
<%}
	vTemp = (Vector)vCourseHist.elementAt(3);
	if (vTemp != null && vTemp.size()>0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#FFFFFF">
      <td height="10" colspan="4" >&nbsp;</td>
    </tr>
	<tr bgcolor="#B9B292">
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>MEDICINE</strong></font></td>
    </tr>
    <tr>
    	<td width="5%" height="25">&nbsp;</td>
    	<td width="40%" align="left"><font size="1"><strong>COURSE</strong></font></td>
    	<td width="50%" align="left"><font size="1"><strong>MAJOR</strong></font></td>
    </tr>
	<%for (iCtr = 0; iCtr < vTemp.size(); iCtr += 5, ++iMaxSel) {%>
	<tr>
		<td align="left" height="25">
		<%
		if (strTemp.equals(Integer.toString(iMaxSel))){%>
		<input name="selCourse" type="radio" value="<%=iMaxSel%>" checked><%} else {%>
		<input name="selCourse" type="radio" value="<%=iMaxSel%>"><%}%></td>
		<td align="left"><font size="1"><%=(String)vTemp.elementAt(iCtr+3)%></font></td>
		<td align="left"><font size="1"><%=WI.getStrValue((String)vTemp.elementAt(iCtr+4),"&nbsp;")%></font></td>
		<input type="hidden" name="c_idx<%=iMaxSel%>" value="<%=(String)vTemp.elementAt(iCtr+1)%>">
		<input type="hidden" name="d_idx<%=iMaxSel%>" value="<%=(String)vTemp.elementAt(iCtr+2)%>">
		<input type="hidden" name="c_type<%=iMaxSel%>" value="<%=(String)vTemp.elementAt(iCtr)%>">
	</tr>
	<%}%>
    </table>
	<%}%>
	<%}%>
	<%if(vTFInfo != null && vTFInfo.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF"><strong>-
          TOR ENTRIES FROM PREVIOUS SCHOOL - </strong></font></div></td>
    </tr>
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td width="23%"  height="25" ><div align="left"><font size="1"><strong>SUBJECT
          CODE</strong></font></div></td>
      <td width="53%" ><div align="left"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
      <td width="6%" ><div align="left"><font size="1"><strong>CREDITS EARNED</strong></font></div></td>
      <td width="5%" ><div align="left"><font size="1"><strong>FINAL GRADES</strong></font></div></td>
      <td width="10%" ><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
<%//System.out.println(vTFInfo);
for(i=0; i< vTFInfo.size(); )
{
	iSem = Integer.parseInt((String)vTFInfo.elementAt(i+10));
	iSchYrFrom = Integer.parseInt((String)vTFInfo.elementAt(i+8));

	/*System.out.println(vTFInfo.elementAt(i));
	System.out.println(vTFInfo.elementAt(i+1));
	System.out.println(vResDetail.elementAt(i+2));
	System.out.println(vTFInfo.elementAt(i+3));
	System.out.println(vTFInfo.elementAt(i+4));
	System.out.println(vTFInfo.elementAt(i+5));
	System.out.println(vTFInfo.elementAt(i+6));
	*/
	%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="5">SCHOOL YEAR
	  (<%=(String)vTFInfo.elementAt(i+8) + " - "+(String)vTFInfo.elementAt(i+9)%>)/
	  (<%=astrConvertYear[Integer.parseInt(WI.getStrValue(vTFInfo.elementAt(i + 11),"0"))] +
	  	 " - "+ (String)vTFInfo.elementAt(i+12)%>) </td>
    </tr>
	<%
	//run a loop here to display transferee information.
	 for(j=i; j< vTFInfo.size();)
	 {//System.out.println(vResDetail.elementAt(j+4));System.out.println(vResDetail.elementAt(j+5));

		iTempSem = Integer.parseInt((String)vTFInfo.elementAt(i+10));
		iTempSchYrFrom = Integer.parseInt((String)vTFInfo.elementAt(i+8));

		if(iTempSem != iSem || iTempSchYrFrom != iSchYrFrom)
			break;
	if(vTFInfo.elementAt(i) != null){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="5">School Name: <strong><%=(String)vTFInfo.elementAt(i)%></strong></td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><%=WI.getStrValue(vTFInfo.elementAt(j+1),"&nbsp;")%></td>
      <td><%=(String)vTFInfo.elementAt(j+2)%></td>
      <td><%=(String)vTFInfo.elementAt(j+3)%></td>
      <td><%=(String)vTFInfo.elementAt(j+5)%></td>
      <td><%=(String)vTFInfo.elementAt(j+6)%></td>
    </tr>
	<%
	j = j + 13;
	i = j;
	}
}%>
  </table>

 <%
 }//if vResDetail !=null - student is having grade created already.


//check residency status in detail.

float fTotalUnits = 0;
float fTotalUnitPerSem = 0;

if(vResDetail == null || vResDetail.size()==0)
{%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <td width="2%" height="25">&nbsp;</td>
  <td><%=WI.getStrValue(GS.getErrMsg())%></td>
  </table>
<%}
else {%>
    <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF"><strong>-
          TOR ENTRIES FROM CURRENT SCHOOL - </strong></font></div></td>
    </tr>
</table>
<%	if(strCourseType.compareTo("0") ==0 || strCourseType.compareTo("3") ==0 || strCourseType.compareTo("4") ==0)//under graduate
	{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td rowspan="2">&nbsp;</td>
      <td width="15%"  height="19" rowspan="2"><div align="left"><font size="1"><strong>SUBJECT_CODE</strong></font></div></td>
      <td width="32%" rowspan="2"><div align="left"><font size="1"><strong>SUBJECT_DESC</strong></font></div></td>
      <td height="15" colspan="2"><div align="center"><font size="1"></font><strong><font size="1">UNITS</font></strong></div></td>
      <td width="12%" rowspan="2"><div align="center"><font size="1"><strong>CREDITS
          EARNED</strong></font></div></td>
      <td width="8%" rowspan="2"><font size="1"><strong>GRADE</strong></font></td>
      <td width="16%" rowspan="2"><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
    <tr>
      <td width="7%"><div align="center"><font size="1"><strong>LEC</strong></font></div></td>
      <td width="9%" height="15"><div align="center"><font size="1"><strong>LAB
          </strong></font></div></td>
    </tr>
    <%

for(i=0 ; i< vResDetail.size();){
if(vResDetail.elementAt(i) != null)
	iYear = Integer.parseInt((String)vResDetail.elementAt(i));
else
	iYear = -1;

if(vResDetail.elementAt(i+1) != null)
	iSem = Integer.parseInt((String)vResDetail.elementAt(i+1));
else if(iYear ==-1)
	iSem = -1;
else
	iSem = 0;//for summer.
if(vResDetail.elementAt(i+10) != null)
	iSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(i+10));

if(iYear != -1 && iSem != -1){%>
    <tr>
      <td width="1%">&nbsp;</td>
      <td colspan="7"><strong><u><font size="1"><%=iYear%> Year/<%=astrConvertSem[iSem]%>,SY
        <%=(String)vResDetail.elementAt(i+10) + " - "+(String)vResDetail.elementAt(i+11)%>
        <%=astrPrepPropInfo[Integer.parseInt(WI.getStrValue(vResDetail.elementAt(i+9),"0"))]%></font></u></strong></td>
    </tr>
    <%}else if(iYear == -1 && iSem != -1){%>
    <tr>
      <td width="1%">&nbsp;</td>
      <td colspan="7"><strong><u><font size="1"><%=astrConvertSem[iSem]%>,SY
        <%=(String)vResDetail.elementAt(i+10) + " - "+(String)vResDetail.elementAt(i+11)%></font></u></strong></td>
    </tr>
<%} for(j=i; j< vResDetail.size();){//System.out.println(vResDetail.elementAt(j+4));System.out.println(vResDetail.elementAt(j+5));

	if(iYear != -1)
		iTempYear = Integer.parseInt(WI.getStrValue((String)vResDetail.elementAt(j),"0"));
	else
		iTempYear = -1;
	if(iSem != -1)
	{
		if(vResDetail.elementAt(j+1) == null)
			iTempSem = 0;
		else
			iTempSem  = Integer.parseInt((String)vResDetail.elementAt(j+1));
	}
	else
		iTempSem = -1;
	//System.out.println(iTempYear);
	//System.out.println(iTempSem);
	//System.out.println(vResDetail.size());

	if(vResDetail.elementAt(j+10) != null)
		iTempSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(j+10));

	if(iTempYear!= iYear || iTempSem != iSem || iTempSchYrFrom != iSchYrFrom)//and check for school year ;-)
		break;
	//only if remark status is passed.
	//if( ((String)vResDetail.elementAt(j+7)).compareToIgnoreCase("passed") ==0)
		fTotalUnitPerSem += Float.parseFloat(WI.getStrValue(vResDetail.elementAt(j+8),"0"));
	 %>
    <tr>
      <td>&nbsp;</td>
      <td  height="19"><div align="left"><%=(String)vResDetail.elementAt(j+2)%></div></td>
      <td><%=(String)vResDetail.elementAt(j+3)%></td>
      <td><div align="center"><%=(String)vResDetail.elementAt(j+4)%> </div></td>
      <td><div align="center"><%=(String)vResDetail.elementAt(j+5)%> </div></td>
      <td align="center"><%=WI.getStrValue(vResDetail.elementAt(j+8))%></td>
      <td><%if(bolShowGrade){%><%=(String)vResDetail.elementAt(j+6)%><%}else{%>&nbsp;<%}%></td>
      <td><%=(String)vResDetail.elementAt(j+7)%></td>
    </tr>
    <%if(vResDetail.elementAt(j+12) != null){%>
    <tr>
      <td>&nbsp;</td>
      <td  height="19"></td>
      <td colspan="6"><font size="1"><%=(String)vResDetail.elementAt(j+12)%></font></td>
    </tr>
    <%}
	j = j+13;
	i = j;
	}///end of inner loop%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><em></em></div></td>
      <td><div align="center"></div></td>
      <td><div align="center"></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"><div align="center"><em>Total units completed for this semester
          :<strong> <%=fTotalUnitPerSem%></strong></em></div></td>
    </tr>
    <%
fTotalUnits += fTotalUnitPerSem;
fTotalUnitPerSem = 0;
}//end of outer loop %>
    <tr>
      <td height="22" colspan="8">&nbsp;</td>
    </tr>
<%if(iAccessLevel > 1 && bolShowGrade) {%>
    <tr>
      <td colspan="8">
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
				<%if(strSchCode.startsWith("UPH") && strInfo5 == null) {%>
					  <td width="33%">
					  <a href='javascript:PPG("2");'><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
					  <font size="1">Print Summary of Grade</font>
					  </td>
					  <td width="33%"><a href='javascript:PPG("3");'><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
					  <font size="1">Print Detailed Grade</font>
					  </td>
				<%}else if(strSchCode.startsWith("CDD") || strSchCode.startsWith("NEU")){%>
					  <td width="33%"><a href='javascript:PPG("4");'><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
					  <font size="1">Print COG</font>
					  </td>
				<%}else if(strSchCode.startsWith("UL")){%>
					  <td width="33%"><a href='javascript:PPG("5");'><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
					  <font size="1">Print Other Certification </font>					  </td>
				      <%}else{%>
					  <td width="66%">&nbsp;</td>
				<%}%>
					<td width="34%"><div align="right"><a href='javascript:PPG("1");'><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
				  <font size="1">Print Residence Status</font></div></td>
				</tr>
			</table>
	  </td>
    </tr>
<%}%>
  </table>
<%}//end of displaying for graduate course.
else if(strCourseType.compareTo("2") ==0)//College of Medicine.
{%>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td  height="19" ><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td colspan="2"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td><font size="1"><strong>TOTAL LOAD</strong></font></td>
      <td><div align="center"><strong><font size="1">CREDIT EARNED</font></strong></div></td>
      <td><font size="1"><strong>GRADE</strong></font></td>
      <td width="8%"><font size="1"><strong>REMARK</strong></font></td>
    </tr>
    <%
	String strMainSubject = null;//System.out.println(vResDetail);
for(i=0 ; i< vResDetail.size();){
iYear = Integer.parseInt((String)vResDetail.elementAt(i));
iSem = Integer.parseInt((String)vResDetail.elementAt(i+1));

	iSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(i+12));
%>
    <tr>
      <td align="center">&nbsp;</td>
      <td colspan="7"><font size="1"><strong><u> <%=iYear%> YEAR/<%=iSem%> SEMESTER,
        SY <font size="1"><%=(String)vResDetail.elementAt(i+12) + " - "+(String)vResDetail.elementAt(i+13)%></font></u></strong></font></td>
    </tr>
    <%
for(j = i ; j< vResDetail.size();)
{
iTempYear = Integer.parseInt((String)vResDetail.elementAt(j));
iTempSem = Integer.parseInt((String)vResDetail.elementAt(j+1));

	iTempSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(i+12));

if(iTempYear != iYear || iTempSem != iSem ||  iTempSchYrFrom != iSchYrFrom) break;

	strMainSubject = (String)vResDetail.elementAt(j+2);
%>
    <tr>
      <td align="center"><em></em></td>
      <td align="center"><div align="left"><%=strMainSubject%></div></td>
      <td  colspan="2" align="center"><div align="left"><%=(String)vResDetail.elementAt(j+3)%></div></td>
      <td align="center"><div align="left"><%=(String)vResDetail.elementAt(j+6)%> (<%=(String)vResDetail.elementAt(j+8)%>)
        </div></td>
      <td align="center"><%=WI.getStrValue(vResDetail.elementAt(j+11))%></td>
      <td><%if(bolShowGrade){%>
			  <%//Display F for failed grade.
		  if( ((String)vResDetail.elementAt(j+10)).toLowerCase().indexOf("fail") != -1){%>
			  F
			  <%}else{%>
			  <%=(String)vResDetail.elementAt(j+9)%>
			  <%}%>
		  <%}else{%>&nbsp;<%}%>
      </td>
      <td><%=(String)vResDetail.elementAt(j+10)%></td>
    </tr>
<%if(vResDetail.elementAt(j + 14) != null){%>
    <tr>
      <td ></td>
      <td></td>
      <td  colspan="6"><font size="1"><%=(String)vResDetail.elementAt(j+14)%></font></td>
    </tr>
    <%}
	for(int k = j ; k< vResDetail.size();)//check for sub_subject list
	{
		if(true)//forced break - because I am not displaying the sub Subject information.
			break;
		if(strMainSubject.compareTo((String)vResDetail.elementAt(k+2)) !=0)//check if there is a main in next entry.
		{
			j = j-15;
			break;
		}
		if(vResDetail.elementAt(j+4) == null)
			break;
		%>
    <tr>
      <td align="center">&nbsp;</td>
      <td width="21%"  height="21">&nbsp;</td>
      <td>&nbsp;&nbsp;<%=(String)vResDetail.elementAt(j+4)%></td>
      <td width="27%"><%=(String)vResDetail.elementAt(j+5)%></td>
      <td width="10%"><%=(String)vResDetail.elementAt(j+7)%></td>
      <td width="8%">&nbsp;</td>
      <td width="6%"><%=(String)vResDetail.elementAt(j+9)%></td>
      <td><%=(String)vResDetail.elementAt(j+10)%></td>
    </tr>
    <%
		k = k +15;
		j = k;

	}//show the sub subject.

	j = j+15;
	i = j;
  }//show the main subject for same year/ semester.%>
    <tr>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td  colspan="2" align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
    </tr>
    <%}//show major / sub subject detail %>
    <!--    <tr>
      <td colspan="8" align="center"><strong>4th Year </strong></td>
    </tr>
    <tr>
      <td colspan="8" align="center"><strong><u>Twelve Full-Month Clinical Clerkship
        Program</u></strong></td>
    </tr>-->
    <tr>
      <td colspan="8" align="center">&nbsp;</td>
    </tr>
<%if(iAccessLevel > 1 && bolShowGrade) {%>
    <tr>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td  colspan="6" align="center"><div align="right"><a href='javascript:PPG("1");'><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
          <font size="1">click to print residency status</font></div></td>
    </tr>
    <%}
}//end of displyaing college of medicine course.
else if(strCourseType.compareTo("1") ==0)
{
	%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%">&nbsp;</td>
      <td width="17%" height="25"><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td width="28%"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="16%"><font size="1"><strong>TOTAL LOAD</strong></font></td>
      <td width="20%"><div align="center"><strong><font size="1">CREDIT EARNED</font></strong></div></td>
      <td width="9%"><font size="1"><strong>GRADE</strong></font></td>
      <td width="9%"><font size="1"><strong>REMARK</strong></font></td>
    </tr>
    <%
for(i=0 ; i< vResDetail.size();)
{
if(vResDetail.elementAt(i+1) != null)
	iSem = Integer.parseInt((String)vResDetail.elementAt(i+1));
else
	iSem = 0;//for summer.
if(vResDetail.elementAt(i + 10) != null)
	iSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(i + 10));

if(iSem != -1){%>
    <tr>
      <td width="1%">&nbsp;</td>
      <td colspan="7"><strong><u><font size="1"><%=astrConvertSem[iSem]%>,SY <%=(String)vResDetail.elementAt(i + 10) + " - "+(String)vResDetail.elementAt(i+11)%></font></u></strong></td>
    </tr>
    <%}
 for(j=i; j< vResDetail.size();) {
 	if(iSem != -1) {
		if(vResDetail.elementAt(j+1) == null)
			iTempSem = 0;
		else
			iTempSem  = Integer.parseInt((String)vResDetail.elementAt(j+1));
	}
	else
		iTempSem = -1;

	if(vResDetail.elementAt(j + 10) != null)
		iTempSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(j + 10));

	if(iTempSem != iSem || iTempSchYrFrom != iSchYrFrom)//and check for school year ;-)
		break;
	 %>
    <tr>
      <td>&nbsp;</td>
      <td  height="19"><%=(String)vResDetail.elementAt(j+2)%></td>
      <td><%=(String)vResDetail.elementAt(j+3)%></td>
      <td align="center"><%=(String)vResDetail.elementAt(j+4)%> </td>
      <td align="center"><%=(String)vResDetail.elementAt(j+8)%></td>
      <td align="center"><%if(bolShowGrade){%><%=(String)vResDetail.elementAt(j+6)%><%}else{%>&nbsp;<%}%></td></td>
      <td>
        <%//Display F for failed grade.
	  if( ((String)vResDetail.elementAt(j+7)).toLowerCase().indexOf("fail") != -1){%>
        F
        <%}else{%>
        <%=(String)vResDetail.elementAt(j+7)%>
        <%}%>
      </td>
    </tr>
<%if(vResDetail.elementAt(j + 12) != null ){%>
    <tr>
      <td>&nbsp;</td>
      <td  height="19">&nbsp;</td>
      <td colspan="5"><font size="1"><%=(String)vResDetail.elementAt(j+12)%></font></td>
    </tr>
    <%}
j = j+13;
i = j;
}///end of inner loop%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><em></em></div></td>
      <td><div align="center"></div></td>
      <td><div align="center"></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%
}//end of outer loop %>
<%if(iAccessLevel > 1 && bolShowGrade) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"><div align="right"><a href='javascript:PPG("1");'>
          <img src="../../../images/print.gif" width="58" height="26" border="0"></a>
          <font size="1">click to print residency status</font></div></td>
    </tr>
<%}%>
  </table>
<%
			}//only if there course type is DOCTORAL / MASTERAL.
		}//if residency summery exisits%>
	<%}//if student residency status in detail exists.%>


<%if(strSchCode.startsWith("AUF")){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
		  <td colspan="8" height="25">NOTE: The final grades posted are valid if they tally with the grades given on the official grading sheets submitted to the Registrar's Office</td>
		</tr>
  </table>
<%}%>


<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
	<input type="hidden" name="print_pg">
	<input type="hidden" name="remarks">

	<input type="hidden" name="redirect_to_print">
	<input type="hidden" name="online_advising" value="<%=WI.fillTextValue("online_advising")%>">
	
	<input type="hidden" name="is_eac_cog" value="<%=WI.fillTextValue("is_eac_cog")%>">
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
