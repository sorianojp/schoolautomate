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
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function focusID() {
	if(document.stud_eval.stud_id)
		document.stud_eval.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=stud_eval.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPage(strStudId)
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	var sT = "#";
	if(vProceed)
		sT = "./stud_cur_residency_eval_print.jsp?stud_id="+escape(strStudId);
	if(document.stud_eval.show_prereq && document.stud_eval.show_prereq.checked)
		sT += "&show_prereq=1";
		
	//print here
	if(vProceed)
	{
		var win=window.open(sT,"myfile",'dependent=no,width=850,height=550,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
//// - all about ajax..
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.stud_eval.stud_id.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}

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
	document.stud_eval.stud_id.value = strID;
	//document.stud_eval.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.stud_eval.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID()">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,student.StudentEvaluation,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	double dGWA      = 0d;

	String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","","","",""};
	String[] astrConvertResStatus = {"Regular","Irregular"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-STUDENT CURRICULUM EVALUATION","stud_cur_residency_eval.jsp");
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
														"Registrar Management","STUDENT COURSE EVALUATION",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(),
					null);
}
//if this is called from online advising, i have to allow,
if(WI.fillTextValue("online_advising").compareTo("1") ==0)
	iAccessLevel = 2;
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
	//adviser are allowed to check.
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"stud_cur_residency_eval.jsp");
	if(iAccessLevel == 0) {
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
}

//end of authenticaion code.
GradeSystem GS = new GradeSystem();
StudentEvaluation SE = new StudentEvaluation();
Vector vRetResult = null;
Vector vTemp = null;

String strSQLQuery = null;
java.sql.ResultSet rs = null;

String strUserIndex = null;
String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

boolean bolShowPreRequisite = false;
if(WI.fillTextValue("show_prereq").length() > 0) 
	bolShowPreRequisite = true;
boolean bolShowFailFrequency = false;
if(WI.fillTextValue("show_fail_freq").length() > 0) 
	bolShowFailFrequency = true;
Vector vFailedCount = new Vector();
int iIndexOf = 0;
boolean bolIsFatalErr = false;

//for neu, i have to check if user belong to same college.
boolean bolCheckCollegeRestriction = false;
if(strSchCode.startsWith("CIT") || strSchCode.startsWith("NEU") || strSchCode.startsWith("UC"))
	bolCheckCollegeRestriction = true;
	
if(WI.fillTextValue("stud_id").length() > 0 && bolCheckCollegeRestriction && WI.fillTextValue("online_advising").length() == 0) {
	if(!comUtil.isLoggedInUserBelongToCollegeOfStudent(dbOP, request, null,WI.fillTextValue("stud_id"), null)) {
		bolIsFatalErr = true;
		strErrMsg = comUtil.getErrMsg();
	}	
}

if(!bolIsFatalErr && WI.fillTextValue("stud_id").length() > 0) {
	vTemp = GS.getResidencySummary(dbOP, WI.fillTextValue("stud_id"));//System.out.println(vTemp);
	if(vTemp == null)
		strErrMsg = GS.getErrMsg();
	else {
		strUserIndex = (String)vTemp.elementAt(0);

		vRetResult = SE.getCurriculumResidencyEval(dbOP,(String)vTemp.elementAt(0),(String)vTemp.elementAt(15),
                                           (String)vTemp.elementAt(16),(String)vTemp.elementAt(8),(String)vTemp.elementAt(9),
                                           (String)vTemp.elementAt(11), bolShowPreRequisite);
		if(vRetResult == null || vRetResult.size() ==0)
			strErrMsg = SE.getErrMsg();
	}
	//System.out.println(vRetResult);
//I have to get the GWA for all the subjects completed so far.
	student.GWA gwa = new student.GWA();
	dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));
	
	///I have to now find failed frequency.. 
	if(bolShowFailFrequency && vTemp != null && vTemp.size() > 0) {
		strSQLQuery = "select sub_code, sub_name, count(*) from g_sheet_final join subject on (subject.sub_index = s_index) where is_valid = 1 and remark_index = 2 and user_index_ = "+(String)vTemp.elementAt(0)+
						" group by sub_code, sub_name";
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vFailedCount.addElement(rs.getString(1)+"-"+rs.getString(2));
			vFailedCount.addElement(rs.getString(3));//count;
		}
		rs.close();
	}
	

}//System.out.println(vRetResult);
boolean bolShowGrade = false;
if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CPU") || strSchCode.startsWith("WNU") ||
	strSchCode.startsWith("AUF") || strSchCode.startsWith("PIT") || strSchCode.startsWith("UB") || 
	strSchCode.startsWith("CSA") || strSchCode.startsWith("SPC") || strSchCode.startsWith("NEU"))
	bolShowGrade = true;
//bolShowGrade = true;
if((strSchCode.startsWith("AUF") || strSchCode.startsWith("PIT")) && (String)request.getSession(false).getAttribute("advising") != null)
	bolShowGrade = false;

if(WI.fillTextValue("online_advising").compareTo("1") ==0)
	bolShowGrade = false;

//for NEU show grade for all
if(strSchCode.startsWith("NEU"))
	bolShowGrade = true;
	
String strLastPrintedDate = null;
if(strSchCode.startsWith("UDMC") && strErrMsg == null && vTemp != null && vTemp.size() > 0) {
	String strSYFrom   = (String)vTemp.elementAt(17);
	String strSemester = (String)vTemp.elementAt(18);

	strSQLQuery = "select DATE_PRINTED from TRACK_PRINTING where STUD_INDEX = "+(String)vTemp.elementAt(0)+
		" and PRINT_MODULE = 2 and SY_FROM = "+strSYFrom +" and SEMESTER="+strSemester+" order by date_printed desc";
	strLastPrintedDate = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strLastPrintedDate != null)
		strLastPrintedDate = strLastPrintedDate.substring(0,11);
}

String strSpcStudStat = null;
if(strSchCode.startsWith("SPC") && strUserIndex != null) {
	strSpcStudStat = "select STATUS_ from SPC_ADVISING_STUD_STAT  "+
					" join SEMESTER_SEQUENCE on (semester_val= term_) where SPC_ADVISING_STUD_STAT.is_valid = 1 and stud_index = "+
					strUserIndex+" order by sy_fr desc, SEM_ORDER desc";
	strSpcStudStat = dbOP.getResultOfAQuery(strSpcStudStat, 0);
	
}
%>
<form action="./stud_cur_residency_eval.jsp" method="post" name="stud_eval">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          STUDENT RESIDENCY EVALUATION ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 11);
else
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td colspan="5">
	  	  <table width="100%" cellpadding="0" cellspacing="0">
			<tr>
			  <td width="2%" height="25">&nbsp;</td>
			  <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
			  <td width="2%">&nbsp;</td>
			</tr>
	     </table>	  </td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="28%">Student ID: &nbsp;&nbsp;
        <%
String strReadOnly = " onKeyUp='AjaxMapName();'";
if(WI.fillTextValue("online_advising").compareTo("1") == 0) {
	strTemp = "textbox_noborder";
	strReadOnly = "readonly";
}
else
	strTemp = "textbox";
%>
        <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strReadOnly%>>      
	  
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute"></label>
	  </td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="9%">
        <%
if(WI.fillTextValue("online_advising").compareTo("1") != 0){%>
        <input type="image" src="../../../images/form_proceed.gif">
      <%}%>      </td>
      <td width="55%" style="font-size:9px; font-weight:bold; color:#0000FF">
<%if(strSchCode.startsWith("CSA") || strSchCode.startsWith("CIT")){%>
		  <input type="checkbox" name="show_prereq" value="checked" <%=WI.fillTextValue("show_prereq")%>> Show Pre-Requisite
<%}
if(strSchCode.startsWith("CIT") && request.getParameter("fake_arg") == null) 
	strTemp = "checked";
else	
	strTemp = WI.fillTextValue("show_fail_freq");
%>
		  <input type="checkbox" name="show_fail_freq" value="checked" <%=strTemp%>> Show Failure Frequency
	  </td>
    </tr>
<%if(strLastPrintedDate != null) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" align="right" style="font-size:14px; color:#FF0000; font-weight:bold"><%=" Course Evaluation already printed on : "+strLastPrintedDate%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
  </table>

<%if(vTemp != null && vTemp.size()>0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="15%">Student name</td>
      <td width="45%"><strong><%=WI.formatName((String)vTemp.elementAt(1),(String)vTemp.elementAt(2),(String)vTemp.elementAt(3),1)%></strong></td>
      <td width="6%">Year</td>
      <td width="32%"><strong><%=astrConvertYear[Integer.parseInt(WI.getStrValue(vTemp.elementAt(10),"0"))]%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Course/Major</td>
      <td><strong><%=(String)vTemp.elementAt(6)%>/<%=WI.getStrValue(vTemp.elementAt(7))%> (<%=(String)vTemp.elementAt(8)%>-<%=(String)vTemp.elementAt(9)%>)</strong></td>
      <td>Status</td>
      <td> <strong><%=astrConvertResStatus[Integer.parseInt(WI.getStrValue(vTemp.elementAt(14),"0"))]%></strong></tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"  colspan="2">Total units required for this course : <strong><%=(String)vTemp.elementAt(12)%></strong></td>
      <td height="25"  colspan="2">Total units taken : <strong><%=WI.getStrValue(vTemp.elementAt(13))%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-weight:bold; font-size:30px;"><%if(strSpcStudStat != null) {%>Status:<%}%></td>
      <td style="font-weight:bold; font-size:30px;"><%if(strSpcStudStat != null) {%><%=strSpcStudStat%><%}%></td>
      <td><% if (!((String)vTemp.elementAt(11)).equals("1") || !((String)vTemp.elementAt(11)).equals("2")){%>GWA :<%}%>&nbsp;</td>
      <td><% if (!((String)vTemp.elementAt(11)).equals("1") || !((String)vTemp.elementAt(11)).equals("2")){%><strong><%=CommonUtil.formatFloat(dGWA, true)%></strong><%}%>&nbsp;</td>
    </tr>
  </table>
 <%}//only vTemp is not null -- having residency summary.
if(vRetResult != null){
String[] astrConvertToPrepProp = {""," (Preparatory)"," (Proper)"};
String strDegreeType = (String) vTemp.elementAt(11);
String strPrevYr  = null;
String strCurYr   = null;
int iPrevSem = 0;
int iCurSem  = 0;
float fTotalUnit = 0f; double dTotalCreditUnit = 0d;

float fTotalHour = 0f;

float fSubjectUnit = 0f;
float fUnitCredited = 0f;//not same as fSubjectUnit when subject is credited less than its units - for transferee/from other course.

String strBGColor = null;

double dSubjectUnit = 0d;
double dCreditEarned = 0d;
double dLakcingCredit = 0d;

%>
  <table bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td height="25" colspan="6" align="center" bgcolor="#EEEECC"> <strong>CURRICULUM
        RESIDENCY EVALUATION</strong></td>
      <%if(bolShowGrade){%><td bgcolor="#EEEECC" height="25" align="center">&nbsp;</td>
      <%}%>
     <%if(bolShowFailFrequency){%><td bgcolor="#EEEECC" align="center">&nbsp;</td><%}%>
     <%if(bolShowPreRequisite){%><td bgcolor="#EEEECC" align="center">&nbsp;</td><%}%>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4"><b><font size="1" color="#0000FF">NOTE: <img src="../../../images/blue_box.gif">
        -&gt; COLOR INDICATES SUBJECTS HAVING PASSING GRADE.</font><br>
        <font size="1" color="#47768F"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <img src="../../../images/gray_box.gif"> -&gt; COLOR INDICATES SUBJECTS
        HAVING CREDITED UNIT LESS THAN REQUIRED UNIT</font></b></td>
      <td><a href='javascript:PrintPage("<%=WI.fillTextValue("stud_id")%>");'>
        <img src="../../../images/print.gif" width="58" height="26" border="0"></a>
        <font size="1">print this page</font></td>
      <%if(bolShowGrade){%><td>&nbsp;</td>
      <%}%>
     <%if(bolShowFailFrequency){%><td>&nbsp;</td><%}%>
      <%if(bolShowPreRequisite){%><td>&nbsp;</td><%}%>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%"><font size="1"><b>SUB CODE</b></font></td>
      <td width="40%"><font size="1"><b>SUB DESC</b></font></td>
      <td width="10%"><font size="1"><b>TOTAL UNIT</b></font></td>
      <td width="5%"><font size="1"><b>CREDIT EARNED</b></font></td>
      <%if(bolShowGrade){%><td width="8%"><font size="1"><b>GRADE</b></font></td><%}%>
      <td width="15%"><font size="1"><b>REMARK</b></font></td>
<%if(bolShowFailFrequency){%>
      <td width="5%"><font size="1"><b>FAILED FREQUENCY</b></font></td>
<%}%>
<%if(bolShowPreRequisite){%>
      <td width="15%"><font size="1"><b>PRE-REQUISITE</b></font></td>
<%}%>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size();){
strPrevYr  = WI.getStrValue(vRetResult.elementAt(i),"0");
iPrevSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="5"><b><u>
        <%if(strDegreeType.compareTo("1") == 0){//do not parse, because it displays the requrement and the units.%>
        <%=strPrevYr%>
        <%}else{%>
        <%=astrConvertYear[Integer.parseInt(strPrevYr)]%>, <%=astrConvertSem[iPrevSem]%> <%=astrConvertToPrepProp[Integer.parseInt((String)vRetResult.elementAt(i+2))]%>
        <%}%>
        </u></b></td>
      <%if(bolShowGrade){%><td>&nbsp;</td>
      <%}%>
      <%if(bolShowFailFrequency){%><td>&nbsp;</td><%}%>
      <%if(bolShowPreRequisite){%><td>&nbsp;</td><%}%>
    </tr>
    <%
for(; i< vRetResult.size();){
strCurYr = WI.getStrValue(vRetResult.elementAt(i),"0");
iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
if(strCurYr.compareTo(strPrevYr) !=0 || iCurSem != iPrevSem)
	break;

fSubjectUnit = Float.parseFloat((String)vRetResult.elementAt(i + 10));
if( ((String)vRetResult.elementAt(i+11)).indexOf("nit") != -1)
	fTotalUnit += fSubjectUnit;
else
	fTotalHour += fSubjectUnit;
fUnitCredited = Float.parseFloat(WI.getStrValue(vRetResult.elementAt(i + 13),"0"));

dTotalCreditUnit += fUnitCredited;
//if student has done the subject , change the color.
strTemp = (String)vRetResult.elementAt(i+15);
if( fUnitCredited > 0f) {
	if(fUnitCredited >= fSubjectUnit)
		strBGColor = " bgcolor=#CCECFF";
	else {
		strBGColor = " bgcolor =#BECED3";
		dSubjectUnit = Double.parseDouble((String)vRetResult.elementAt(i + 10));
		dCreditEarned = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 13), "0"));
		dLakcingCredit = dSubjectUnit - dCreditEarned;

		strTemp = "Lacking "+dLakcingCredit+" Unit(s)";
	}
}else
	strBGColor = "";

if(strBGColor.length() == 0 && strTemp != null && strTemp.length () > 0 && fUnitCredited == 0f &&
		!strTemp.toLowerCase().startsWith("p"))
	strBGColor = " bgcolor=#FF6a6a";

//sometimes the subject unit is 0, but it is passed.
if(fSubjectUnit == 0 && strTemp != null && strTemp.startsWith("Pa"))
	strBGColor = " bgcolor=#CCECFF";

//if(strTemp != null && vRetResult.elementAt(i+14) != null)
//	strTemp += "(" +(String)vRetResult.elementAt(i+14) + ")";
%>
    <tr<%=strBGColor%>>
      <td width="2%" height="25">&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i+4)%></font></td>
      <td><%=(String)vRetResult.elementAt(i+5)%></td>
      <td><%=(String)vRetResult.elementAt(i+10)%><%=(String)vRetResult.elementAt(i+11)%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+13))%></td>
      <%if(bolShowGrade){%><td><%=WI.getStrValue(vRetResult.elementAt(i+14))%> </td><%}%>
      <td><%=WI.getStrValue(strTemp)%></td>
<%if(bolShowFailFrequency) {
	iIndexOf = vFailedCount.indexOf((String)vRetResult.elementAt(i+4)+"-"+(String)vRetResult.elementAt(i+5));
	if(iIndexOf == -1)
		strTemp = "&nbsp;";
	else	
		strTemp = (String)vFailedCount.elementAt(iIndexOf + 1); 

%>
      <td><%=strTemp%></td>
<%}if(bolShowPreRequisite) {
	if(vRetResult.elementAt(i + 16) == null) {
		strTemp = null;
		vRetResult.remove(i + 16);
	}else{
		strTemp = (String)vRetResult.remove(i + 16);
		strTemp = strTemp.substring(1);
		strTemp = strTemp.substring(0, strTemp.length() - 1);
	}
%>
      <td style="font-size:9px"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
<%}%>
    </tr>
    <%
	i += 16;
	}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="5" align="center"><font size="1"><b>
        <%if(strDegreeType.compareTo("1") != 0){
			if(fTotalUnit > 0f){%>
        <u>TOTAL REQUIRED UNITS : <%=fTotalUnit%></u>
        <%}else if(fTotalHour > 0f){%>
        <u>TOTAL REQUIRED HOURS : <%=fTotalHour%></u>
        <%}
		}%>
        &nbsp;&nbsp;&nbsp;&nbsp;TOTAL UNITS CREDITED : <%=dTotalCreditUnit%> </b></font></td>
      <%if(bolShowGrade){%><td align="center">&nbsp;</td>
      <%}%>
      <%if(bolShowFailFrequency){%><td align="center">&nbsp;</td><%}%>
      <%if(bolShowPreRequisite){%><td align="center">&nbsp;</td><%}%>
    </tr>
    <%fTotalUnit = 0f;fTotalHour = 0f;dTotalCreditUnit = 0d;}//end of loop for year/sem display.%>
  </table>
<%}%>
<%if(strSchCode.startsWith("AUF")){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
		  <td colspan="8" height="25">NOTE: The final grades posted are valid if they tally with the grades given on the official grading sheets submitted to the Registrar's Office</td>
		</tr>
  </table>
<%}%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
        <tr>

      <TD align="right"><a href='javascript:PrintPage("<%=WI.fillTextValue("stud_id")%>");'>
        <img src="../../../images/print.gif" width="58" height="26" border="0"></a>
        <font size="1">click to print curriculum residency evaluation page</font></TD>
        </tr>
  </table>


<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="fake_arg" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
