<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.GradeSystemExtn,enrollment.FAPaymentUtil,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";

boolean bolIsVMA = strSchCode.startsWith("VMA");
boolean bolIsSWU = strSchCode.startsWith("SWU");
boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=grelease.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	SetFields();
	document.grelease.submit();
}
function SetFields()
{
	var strIsGPA     = "0";
	var strGradeName = document.grelease.grade_for.value;
	if(strGradeName == "GPA"){
		strGradeName = "Finals";
		strIsGPA     = "1";
	}
	document.grelease.is_gpa.value= strIsGPA;
	
	document.grelease.grade_name.value= strGradeName;
	document.grelease.semester_name.value= document.grelease.semester[document.grelease.semester.selectedIndex].text;
}
function PrintPage()
{
	<%if(bolIsSWU){%>
	if(document.grelease.grade_not_encoded.value != '0'){
		alert("Cannot print exam grade, 1 or more subject(s) grade not encoded.");
		return;
	}
	<%}%>

	var showGWA = "";
	if(document.grelease.show_gwa && document.grelease.show_gwa.checked)
		showGWA = "1";
	var printLoc = "./grade_releasing_print.jsp?stud_id="+escape(document.grelease.stud_id.value)+
		"&sy_from="+document.grelease.sy_from.value+
		"&sy_to="+document.grelease.sy_to.value+
		//"&grade_for="+escape(document.grelease.grade_for[document.grelease.grade_for.selectedIndex].value)+
		"&grade_for="+escape(document.grelease.grade_name.value)+
		"&semester="+document.grelease.semester[document.grelease.semester.selectedIndex].value+
		"&sem_name="+escape(document.grelease.semester[document.grelease.semester.selectedIndex].text)+
		"&show_gwa="+showGWA+
		"&grade_name="+escape(document.grelease.grade_name.value)+
		"&is_gpa="+escape(document.grelease.is_gpa.value)+
		"&swu_print_count="+document.grelease.swu_print_count.value;

	if(document.grelease.print_grade_option) {
		if(!document.grelease.print_grade_option[0])
			printLoc += "&print_grade_option=0";
		else if(document.grelease.print_grade_option[0].checked)
			printLoc += "&print_grade_option=0";
		else if(document.grelease.print_grade_option[1].checked)
			printLoc += "&print_grade_option=1";
		else if(document.grelease.print_grade_option[2].checked)
			printLoc += "&print_grade_option=2";
	}
	if(document.grelease.grad_date)
		printLoc +="&grad_date="+escape(document.grelease.grad_date.value);
	if(document.grelease.print_dotmatrix) {
		if(document.grelease.print_dotmatrix.checked)
			printLoc += "&print_dotmatrix=1";
	}
		
	var win=window.open(printLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusID() {
	document.grelease.stud_id.focus();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.grelease.stud_id.value;
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
	document.grelease.stud_id.value = strID;
	document.grelease.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.grelease.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

//update grade unit.
function UpdateGradeUnit(strGSRef, strLabelID) {
	<%if(!strSchCode.startsWith("CIT")){%>
		return;
	<%}%>
	var strNewUnit = prompt('Please enter new unit');
	if(strNewUnit == null || strNewUnit.length == 0) {
		alert('Please enter new Unit.');
		return;
	}
	
	var objCOAInput;
	objCOAInput = document.getElementById(strLabelID);
		
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strIsFinal = "0";
	<%if(bolIsFinal){%>
		strIsFinal = "1";
	<%}%>

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=215&new_gs="+strNewUnit+
				"&gs_ref="+strGSRef+"&is_final="+strIsFinal;

	this.processRequest(strURL);
}
</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	boolean bolIsRestricted = false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Releasing","grade_release.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Releasing",request.getRemoteAddr(),
									null);

}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","Grade Releasing - Restricted",request.getRemoteAddr(),
									null);
	if(iAccessLevel > 0)
		bolIsRestricted = true;//limit only college of logged in user.
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
//bolIsRestricted = true;
//end of authenticaion code.
java.sql.ResultSet rs = null;

GradeSystem GS = new GradeSystem();
GradeSystemExtn gsEx = new GradeSystemExtn();
FAPaymentUtil pmtUtil = new FAPaymentUtil();

String strUserIndex   = null;


//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));

Vector vGradeDetail = null;
if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else {
	strErrMsg = null;
	
	if(bolIsRestricted) {
		//I have to make sure the college of student belong to college of logged in user.. 
		strTemp = "select c_index from course_offered where course_index = "+vStudInfo.elementAt(6);
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		//I have to now check if same college as logged in user.
		if(!strTemp.equals(WI.getStrValue(request.getSession(false).getAttribute("info_faculty_basic.c_index"))))
			strErrMsg = "Student does not belong to same college.";
	}

	//get grade sheet release information.
	boolean bolIncludeEnrolledSubject = true;
	if(strErrMsg == null) {
		if(strSchCode.startsWith("WNU")){
			String strExcludeList = "#08-95138#,#08-94456#,#06-90163#,#95-02645#,#05-00356#,#08-94070#,#08-94472#,#07-90687#,#08-93114#,#07-91444#,#08-93878#,#07-92340#,#07-91577#,#07-92744#,#08-93053#,#06-90168#,#07-92697#,#07-91191#,#08-94889#,#08-94477#,#08-94853##05-03733#,#07-92704#,#07-92510#,#07-92297#,#06-02003#,#08-94071#,#07-92588#,#06-90221#,#84-02549#,#07-92008#,#08-94287#,#07-91517#,#09-1348-245#,#08-94156#,#07-92587#,#08-93021#,#07-91246#,#08-94747#,#06-90026#,#07-91855#";
			if(strExcludeList.indexOf("#"+request.getParameter("stud_id")+"#") > -1)
				bolIncludeEnrolledSubject = false;
		}
		
		vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_name"),
			request.getParameter("sy_from"),request.getParameter("sy_to"),
			request.getParameter("semester"),true,bolIncludeEnrolledSubject,true);//get all information.
		strUserIndex = (String)vStudInfo.elementAt(0);
		if(vGradeDetail == null)
			strErrMsg = GS.getErrMsg();
	}
}
if(strErrMsg == null) strErrMsg = "";

String strGradeCGH = null;
java.sql.PreparedStatement pstmtGetPercentGrade = dbOP.getPreparedStatement("select grade_cgh from g_sheet_final where gs_index = ?");

boolean bolIsCIT = strSchCode.startsWith("CIT");
boolean bolShowPrintButton = true;
Vector vSubSecIndexLocked = new Vector();
if(bolIsCIT && vGradeDetail != null && vGradeDetail.size() > 0) {
	strTemp = "select pmt_sch_index from fa_pmt_schedule where exam_name = '"+WI.fillTextValue("grade_name")+"'";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	
	vSubSecIndexLocked = gsEx.getSubSecIndexLocked(dbOP, request.getParameter("sy_from"), request.getParameter("semester"), strTemp);
}

//System.out.println(vSubSecIndexLocked);
if(vSubSecIndexLocked == null)
	vSubSecIndexLocked = new Vector();

int iGNA = 0;//used in SWU :: Grades not available, GS_INDEX is null

%>

<form name="grelease" action="./grade_release.jsp" method="post">
<input type="hidden" name="grade_name" value="<%=WI.fillTextValue("grade_name")%>">
<input type="hidden" name="semester_name" value="0">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>::::
        GRADE RELEASING PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="5" ><strong><%=strErrMsg%></strong>
<%if(true){%>	  
		<div align="right">
		<a href="./grade_release_main.jsp?print_by=1">Go to Batch Printing</a>	  
	  	</div>
<%}%>
	  </td>
    </tr>
<%
if(strUserIndex != null) {
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 4);
	strErrMsg = new enrollment.SetParameter().bolStudentIsOnHold(dbOP, strUserIndex);
	if(strErrMsg != null) {
		bolShowPrintButton = false;
		if(strTemp != null) 
			strTemp = strTemp + "<br>"+strErrMsg;
		else	
			strTemp = strErrMsg;
	}
}
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
      <td height="25" >&nbsp;</td>
    </tr>
<%}%>
    <tr valign="top">
      <td width="2%" height="25" >&nbsp;</td>
      <td width="30%" height="25" >Student ID: &nbsp; 
	  <input name="stud_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeyUp="AjaxMapName('1');" value="<%=WI.fillTextValue("stud_id")%>" size="16">      </td>
      <td width="5%" ><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="11%" ><input type="image" src="../../../images/form_proceed.gif" onClick="ReloadPage()">      </td>
      <td width="49%" ><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
      <td width="3%" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25" >
	  
	  <hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="2" >Student name : <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="2" >Course/Major : <strong><%=(String)vStudInfo.elementAt(2)%>
        <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td width="30%" height="25" >Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></strong></td>
      <td width="68%" >
	  <%//check here if it is printed arleady.. 
	  enrollment.ReportRegistrar RR = new enrollment.ReportRegistrar();
	  Vector vTemp = null;
	  if(strSchCode.startsWith("UDMC") && WI.fillTextValue("sy_from").length() > 0) {
		  	vTemp = RR.operateOnGradeReleasePrint(dbOP, request, 4);
		  strTemp = null;
	  	if(vTemp != null && vTemp.size() > 0)
	  		strTemp = "<font color='red'><u>Printed on "+vTemp.elementAt(0)+" by : "+vTemp.elementAt(1)+"</u></font>"; 
		  else	
		  	strTemp = "<font color='red'><u>Printing information not found.</u></font>";
	  }
	  %><%=WI.getStrValue(strTemp)%>
	  </td>
    </tr>
    <tr>
      <td colspan="3" height="25" ><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" width="2%" >&nbsp;</td>
<%
	
strTemp  = " from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 ";
if(bolIsCIT) 
	strTemp += " and (exam_name like 'midterm%' or exam_name like 'final%') ";	  
if(bolIsVMA)
	strTemp += " and (exam_name not like 'pre-final%') ";	  
	
	strTemp += "order by EXAM_PERIOD_ORDER asc"; 

%>
	  
      <td width="51%" height="25" > Show&nbsp; 
        <select name="grade_for" onChange="ReloadPage();">
          <%=dbOP.loadCombo("EXAM_NAME","EXAM_NAME",strTemp, request.getParameter("grade_for"), false)%>
		  <%
		  if(bolIsVMA){	
		  if(WI.fillTextValue("grade_for").equals("GPA") )	
		  	strErrMsg = "selected";  
		  else
		  	strErrMsg = "";
		  %><option value="GPA" <%=strErrMsg%>>GPA</option>
		  <%}%>
        </select>        grades for term &nbsp;
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st Semester</option>
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	if(strTemp == null)
		strTemp = "";
}
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Semester</option>
          <%}else{%>
          <option value="2">2nd Semester</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Semester</option>
          <%}else{%>
          <option value="3">3rd Semester</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select> </td>
      <td width="32%" height="25" >School year :
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>

        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("grelease","sy_from","sy_to")'>
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
      <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td width="15%" ><input type="image" src="../../../images/form_proceed.gif" onClick="ReloadPage()"></td>
    </tr>
<%
String strSYEnrolled = null; 
String strSemEnrolled = null;
String strCurHistIndex = null;

if( ( strSchCode.startsWith("FATIMA") || bolIsSWU ) && strUserIndex != null && WI.fillTextValue("sy_from").length() > 0){
	
	//do not check OS if already enrolled in later sy/term.. 
	String strSQLQuery = "select sy_from, semester, cur_hist_index from stud_curriculum_hist "+
						" join semester_sequence on (semester_val = semester) "+
						"where is_valid = 1 and user_index = "+strUserIndex+
						" order by sy_from desc, sem_order desc";
	rs = dbOP.executeQuery(strSQLQuery);
	
	if(rs.next()) {
		strSYEnrolled  = rs.getString(1);
		strSemEnrolled = rs.getString(2);
		strCurHistIndex = rs.getString(3);
	}rs.close();	
}	
if(strSchCode.startsWith("FATIMA") && strUserIndex != null && WI.fillTextValue("sy_from").length() > 0){	
	//check if enrolled next sy/term.. 
	double dOutStandingBalance = 0d; 
	int icompare = CommonUtil.compareSYTerm(strSYEnrolled, strSemEnrolled, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
	if(icompare == 0) {//get only if currently enrolled.. 
		enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
		dOutStandingBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, strUserIndex, true, true);
	}
	else {
		int iSYFrom   = Integer.parseInt(WI.fillTextValue("sy_from"));
		int iSYTo     = Integer.parseInt(WI.fillTextValue("sy_to"));
		int iSemester = Integer.parseInt(WI.fillTextValue("semester"));
		
		if(iSemester == 0) {
			iSemester = 1;
			++iSYFrom; ++iSYTo;
		}
		else {
			++iSemester;
		}
		
		enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
		dOutStandingBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, strUserIndex, false, false, Integer.toString(iSYFrom), Integer.toString(iSYTo), Integer.toString(iSemester), "1");
	}
	//System.out.println(dOutStandingBalance);
	if(dOutStandingBalance > 50d) {bolShowPrintButton = false;
%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" >
	  <font size="4" color="red"><strong>OLD ACCOUNT : <%=CommonUtil.formatFloat(dOutStandingBalance,true)%></strong></font>
	  
	  </td>
    </tr>
<%}
}%>
    <tr >
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
</table>
<script language="JavaScript">
<!--document.grelease.grade_name.value = document.grelease.grade_for.value;-->
document.grelease.semester_name.value = document.grelease.semester[document.grelease.semester.selectedIndex].text;
</script>
<%
if(vGradeDetail != null && vGradeDetail.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25">&nbsp;NOTE : Red color indicates grades not 
        verified and will appear &quot;grade not verified&quot; in printout.</td>
<%
String strPrintCount = null;
if(bolIsSWU && strCurHistIndex != null && strCurHistIndex.length() > 0){

	if(bolIsFinal)
		strTemp = "g_sheet_final";
	else
		strTemp = "grade_sheet";
		
	strTemp = 
		" select distinct ISNULL(SWU_PRINT_COUNT,0) from "+strTemp+" where IS_VALID = 1 "+
		" and CUR_HIST_INDEX = "+strCurHistIndex+" and GRADE_NAME like '"+WI.fillTextValue("grade_name")+"%' ";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	strPrintCount = strTemp;	
	if(strTemp != null && !strTemp.equals("0"))	{
%>		
      <td width="7%">
	  	<div style="border:solid 1px #FF0000; text-align:center;"><font size="1">PRINT COUNT</font><br><strong><%=strTemp%></strong></div>
	  </td>
<%}}
if(strPrintCount == null)
	strPrintCount = "0";
%>


	<input type="hidden" name="swu_print_count" value="<%=strPrintCount%>">
      <td width="13%" height="25">
	  <%if(bolShowPrintButton){%>
	  	<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
	  <%}%>	  </td>
    </tr>
<%if(strSchCode.startsWith("FATIMA") && bolShowPrintButton){%>
    <tr >
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;
	  <input name="print_dotmatrix" type="checkbox" value="checked" <%=WI.fillTextValue("print_dotmatrix")%>>
        <font color="#0033FF"><strong>Print to DotMatrix Printer </strong></font></td>
    </tr>
<%}

if(!bolIsCIT && !bolIsSWU){%>
    <tr >
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;
	  <%strTemp = WI.fillTextValue("show_gwa");
	  if(strTemp.compareTo("1") == 0) 
	  	strTemp = " checked";
	  else
	  	strTemp = "";
		%>
	  <input name="show_gwa" type="checkbox" value="1"<%=strTemp%>>
        <font color="#0033FF"><strong>In printout show GWA of student for this 
        semester (only if final grade is selected)</strong></font></td>
    </tr>
<%}

if(bolIsCIT){%>
    <tr >
      <td height="25" colspan="3" style="font-size:11px; font-weight:bold; color:#0033FF">&nbsp;&nbsp;&nbsp;
<%
strErrMsg = WI.fillTextValue("print_grade_option");
if(strErrMsg.length() == 0 || strErrMsg.equals("0")) 
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="radio" name="print_grade_option" value="0" <%=strTemp%>> Print Grades 
<%if(WI.fillTextValue("grade_for").startsWith("F")){
if(strErrMsg.equals("1")) 
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="radio" name="print_grade_option" value="1" <%=strTemp%>> Print Report Card 
<%
	if(strErrMsg.equals("2")) 
		strTemp = " checked";
	else	
		strTemp = "";
	%>
		  <input type="radio" name="print_grade_option" value="2" <%=strTemp%>> 
		  Print Advanced Grade
	  
	  <font color="#000000">(Graduation Date: 
	  
	  <input name="grad_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("grad_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('grelease.grad_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  
	  )</font>
<%}%>	  </td>
    </tr>
<%}%>
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="3" align="center"><strong> <%=WI.fillTextValue("grade_name")%></strong> GRADES FOR <strong><%=WI.fillTextValue("semester_name")%></strong> <strong><%=WI.fillTextValue("sy_from")%>- <%=WI.fillTextValue("sy_to")%></strong> </td>
    </tr>
  </table>
<%
boolean bolIsCLDH  = strSchCode.startsWith("CLDH");
if(!bolIsFinal)
	bolIsCLDH = false;
%>

 <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="16%" height="25" align="center" class="thinborder" ><font size="1"><strong>Subject Code </strong></font></td>
      <td align="center" class="thinborder" ><font size="1"><strong>Subject Name </strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>Credit</strong></font></td>
      <td width="24%" align="center" class="thinborder"><font size="1"><strong>Instructor</strong></font></td>
      <td width="8%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Grade<font size="1"><strong> </strong></font></td>
<%if(bolIsCLDH){%>
      <td width="8%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Grade %ge </td>
<%}

if(bolIsSWU){%>
	  <td width="8%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Re-Exam</td>
<%}
if(!bolIsSWU){%>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>Remarks</strong></font></td>
<%}%>
    </tr>
<%
String strTRCol = null;//red if faculty grade is not verified.
String strGradeReference = null;

String strGrade   = null;
String strRemark  = null;
String strCEarned = null;
String strReExam  = null;

//System.out.println(vGradeDetail);
for(int i=0; i< vGradeDetail.size(); i += 8){
strGradeReference = (String)vGradeDetail.elementAt(i);
if(strGradeReference == null)
	++iGNA;
if(vGradeDetail.elementAt(i) == null)
	strTemp = " colspan=2";
else	
	strTemp = "";
if(GS.vGSIndexLocked.indexOf(vGradeDetail.elementAt(i)) == -1) {
	if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0)
		strTRCol = " bgcolor=red";
	else	
		strTRCol = "";
}
else	
	strTRCol = "";

if(!bolIsFinal && !bolIsSWU && !strSchCode.startsWith("UB"))
	strTRCol = "";

if((bolIsCLDH || bolIsVMA) && vGradeDetail.elementAt(i) != null) {
	pstmtGetPercentGrade.setInt(1, Integer.parseInt((String)vGradeDetail.elementAt(i)));
	rs = pstmtGetPercentGrade.executeQuery();
	if(rs.next())
		strGradeCGH = rs.getString(1);
	else	
		strGradeCGH = "&nbsp;";
	rs.close();
}
else	
	strGradeCGH = "&nbsp;";


strGrade   = (String)vGradeDetail.elementAt(i+5);
strRemark  = WI.getStrValue(vGradeDetail.elementAt(i+6),"&nbsp;");
strCEarned = WI.getStrValue(vGradeDetail.elementAt(i+3),"&nbsp;");

if(WI.fillTextValue("grade_for").toLowerCase().startsWith("final") && bolIsVMA)
	strGrade = strGradeCGH;

strReExam = null;
if(bolIsSWU && vGradeDetail.size() > (i + 5 + 8) && strGrade != null && 
		( (strGrade.toLowerCase().indexOf("inc") == -1 || strGrade.toLowerCase().indexOf("inr") == -1 || strGrade.toLowerCase().indexOf("ine") == -1) ) &&
		((String)vGradeDetail.elementAt(i + 1)).compareTo((String)vGradeDetail.elementAt(i + 1 + 8)) == 0 &&
		((String)vGradeDetail.elementAt(i + 2)).compareTo((String)vGradeDetail.elementAt(i + 2 + 8)) == 0 
		){ //sub code,		
      	strReExam = (String)vGradeDetail.elementAt(i + 5 + 8);
		strCEarned = (String)vGradeDetail.elementAt(i + 3 + 8);
		i += 8;
}


if(bolIsCIT && strTRCol.length() > 0) {
	strTRCol   = "";
	//strGrade   = "GNA";
	//strRemark  = "&nbsp;";
	//strCEarned = "&nbsp;";
}

		if(bolIsCIT && vGradeDetail.elementAt(i) != null) {
			if(bolIsFinal)
				strErrMsg = "select sub_sec_index from g_sheet_final where gs_index = "+vGradeDetail.elementAt(i);
			else	
				strErrMsg = "select sub_sec_index from grade_sheet where gs_index = "+vGradeDetail.elementAt(i);
			
			strErrMsg = dbOP.getResultOfAQuery(strErrMsg, 0);
			if(strErrMsg != null && vSubSecIndexLocked.indexOf(strErrMsg) == -1) {
				if(GS.vGSIndexLocked.indexOf(vGradeDetail.elementAt(i)) == -1) {//advanced grade submitted.. 
					strRemark  = "&nbsp;";
					strCEarned = "&nbsp;";
					strGrade   = "GNA";
				}
			}
		}

//System.out.println("REmark: "+strRemark);
%>
    <tr<%=strTRCol%> title="<%=WI.getStrValue(strGradeReference)%>">
      	<td  height="25" class="thinborder" >&nbsp;<%=(String)vGradeDetail.elementAt(i + 1)%></td>
      	<td class="thinborder" >&nbsp;<%=(String)vGradeDetail.elementAt(i+2)%></td>
      	<td align="center" class="thinborder" onDblClick="UpdateGradeUnit('<%=strGradeReference%>', '<%=i%>')"><label id="<%=i%>"><%=strCEarned%></label></td>
      	<td class="thinborder" >&nbsp;<%=WI.getStrValue((String)vGradeDetail.elementAt(i+4),"n/f")%></td>
      	<td align="center" class="thinborder" <%=strTemp%>><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%if(bolIsCLDH){%>
		<td align="center" class="thinborder" <%=strTemp%>><%=WI.getStrValue(strGradeCGH, "&nbsp;")%></td>
<%}
if(strTemp.length() == 0 && bolIsSWU) {%>
		<td align="center" class="thinborder" ><%=WI.getStrValue(strReExam,"&nbsp;")%></td>
<%}
if(strTemp.length() == 0 && !bolIsSWU) {%>
      	<td align="center" class="thinborder" ><%=strRemark%></td>
<%}%>
    </tr>
<%}%>
  </table>

<%if(strSchCode.startsWith("AUF")){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
		  <td colspan="8" height="25">NOTE: The final grades posted are valid if they tally with the grades given on the official grading sheets submitted to the Registrar's Office</td>
		</tr>
  </table>
<%}%>


<%
	}//if vGradeDetail size > 0
}//only if vStudInfo is not null.
%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="grade_not_encoded" value="<%=iGNA%>">
 <input type="hidden" name="is_gpa" value="<%=WI.fillTextValue("is_gpa")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
