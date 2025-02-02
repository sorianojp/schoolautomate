<%
	WebInterface WI   = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";

	String strGradeForName = WI.fillTextValue("grade_name_");//strSchCode = "CLDH";
	if(strSchCode.startsWith("UL"))
		strSchCode = "CGH";

	boolean bolIsCGH = false; //for cldh - i must have finals to record in %ge.
	if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") || (strSchCode.startsWith("CLDH") && strGradeForName.toLowerCase().startsWith("final")) )
		bolIsCGH = true;//bolIsCGH = true;

	String strTemp    = null;
	boolean bolIsCSA = strSchCode.startsWith("CSA");	
	
	boolean bolIsCIT = strSchCode.startsWith("CIT");
	
		
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
var imgWnd;


function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.print_page.value = "";
	document.form_.page_action.value="";
	if(document.form_.show_save.value == "1")
		document.form_.hide_save.src = "../../../images/blank.gif";
	if(document.form_.show_delete.value == "1")
		document.form_.hide_delete.src = "../../../images/blank.gif";
	this.ShowProcessing();
}
function ShowProcessing() {

	if(document.form_.grade_for) {
		document.form_.grade_name_.value = document.form_.grade_for[document.form_.grade_for.selectedIndex].text;
	}

	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	this.SubmitOnce('form_');
	imgWnd.focus();
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}


//added new.
function encodeGrade(strSubSecIndex, strSubIndex, strSection) {
	var pgLoc = "./grade_sheet.jsp?sub_sec_index="+strSubSecIndex+"&grade_for="+
	document.form_.grade_for[document.form_.grade_for.selectedIndex].value+"&prevent_fwd=1&sy_from="+
	document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&offering_sem="+
	document.form_.offering_sem[document.form_.offering_sem.selectedIndex].value+"&subject="+strSubIndex+
	"&section_name="+strSection;
	if(document.form_.graduating_only && document.form_.graduating_only.checked)
		pgLoc += "&graduating_only=1";
	location = pgLoc;
}
function viewGrade(strSubSecIndex, strSubIndex, strSection, examSchedule) {
	location = "./grade_sheet_print.jsp?sub_sec_index="+strSubSecIndex+
	//"&grade_for="+document.form_.grade_for[document.form_.grade_for.selectedIndex].value+
	"&grade_for="+examSchedule+
	"&prevent_fwd=1&sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+
	"&offering_sem="+document.form_.offering_sem[document.form_.offering_sem.selectedIndex].value+
	"&subject="+strSubIndex+
	"&section_name="+strSection+
	"&re_print_only="+document.form_.re_print_only.value+
	"&no_print=1&emp_id="+document.form_.emp_id.value;	
}


</script>


<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<form name="form_" action="./grade_sheet_encode_main.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	if(WI.fillTextValue("print_page").equals("1")){
	//i have to forward this page to print page
		if (!strSchCode.startsWith("CPU")) {
	%>
		<jsp:forward page="./grade_sheet_print.jsp" />
	<%}else{%>
		<jsp:forward page="./grade_sheet_final_report_print_cpu.jsp"/>
	<% } // end if else

	return;
	}

	DBOperation dbOP  = null;
	String strErrMsg  = null;
	Vector vSecDetail = null;



	int j = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet.jsp");
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
									"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(),
									null);
}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(),
									null);
}

//I have to check if grade sheet is locked..
if(new enrollment.SetParameter().isGsLocked(dbOP))
	iAccessLevel = 0;

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
GradeSystemExtn gsExtn     = new GradeSystemExtn();
String strEmployeeID = null;
String strEmployeeIndex = null;

boolean bolEncodingForOther = false;

if(WI.fillTextValue("allowed_fac").length() > 0) {
	strEmployeeID    = WI.fillTextValue("allowed_fac");
	strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
	request.getSession(false).setAttribute("userId_gs",strEmployeeID);
	
	bolEncodingForOther = true;
}
else {
	strEmployeeID    = (String)request.getSession(false).getAttribute("userId");
	strEmployeeIndex = (String)request.getSession(false).getAttribute("userIndex");
	request.getSession(false).setAttribute("userId_gs",null);
}
String strSubSecIndex   = null;

Vector vRetResult    = null;
//get here necessary information.

/**
String strGradeName = null;
if(WI.fillTextValue("grade_for").length() > 0) 
	strGradeName = dbOP.mapOneToOther("FA_PMT_SCHEDULE", "PMT_SCH_INDEX", WI.fillTextValue("grade_for"), "EXAM_NAME", null);
**/

//new code.. 
String strPmtSchIndex = null;
Vector vFacultyLoad   = null;
Vector vPmtSchedule   = null;

String strSYFrom = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("offering_sem");

if(strSYFrom.length() == 0) {//I have to check if there are any open sy/term.
	vRetResult = gsExtn.getOpenGSEncodingSYTerm(dbOP, strEmployeeIndex);
	if(vRetResult != null && vRetResult.size() > 0) {//get the encoding sy/term.. 
		strSYFrom   = (String)vRetResult.remove(0);
		strSemester = (String)vRetResult.remove(1);
	}
	//System.out.println(gsExtn.getErrMsg());
}
//System.out.println("Print : "+strSemester);
//System.out.println("strSYFrom : "+strSYFrom);


if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
	
boolean bolEncodingAllowed = true;
Vector vExamSched = gsExtn.getExamSchedulesAllowed(dbOP,strEmployeeIndex, strSYFrom, strSemester);
if(vExamSched == null) {
	bolEncodingAllowed = false;
	strErrMsg = gsExtn.getErrMsg();
} 
//System.out.println(gsExtn.getErrMsg());

vFacultyLoad = gsExtn.getFacultyGradeEncodingSectionList(dbOP,strEmployeeIndex, strSYFrom, strSemester, request);
if(vFacultyLoad == null) {
	strErrMsg = gsExtn.getErrMsg();
	vFacultyLoad = new Vector();
}

vPmtSchedule = gsExtn.getAllowedGradePeriods(dbOP, strSYFrom, strSemester, strSchCode);
if(vPmtSchedule == null) {
	strErrMsg = gsExtn.getErrMsg();
	vPmtSchedule = new Vector();
}
	
Vector vLockedInfo = null;//gsExtn.getGSLockInfo(dbOP, strSYFrom, strSemester, strEmployeeIndex);


int iIndexOf = 0;

Vector vOtherFacEncodingAllowed = gsExtn.getGradeEncodeInchargeList(dbOP, (String)request.getSession(false).getAttribute("userIndex"), strSYFrom, strSemester);
if(vOtherFacEncodingAllowed == null)
	vOtherFacEncodingAllowed = new Vector();


///get list of subject allowed to encode if encoding for others.
Vector vAllowedSubList = null;
if(bolEncodingForOther) {
	vAllowedSubList = gsExtn.getAllowedSubListOfIncharge(dbOP,(String)request.getSession(false).getAttribute("userIndex")); 
}

///get verfiy date and time.. 
Vector vFinalCopyDateMT = new Vector();
Vector vFinalCopyDateFinal = new Vector();

if(vFacultyLoad != null && vFacultyLoad.size() > 0) {
	strTemp = "select pmt_sch_index, faculty_load.load_index, FACULTY_GRADE_VERIFY.verify_date, FACULTY_GRADE_VERIFY.verify_time from FACULTY_GRADE_VERIFY "+
				"join faculty_load on (faculty_load.load_index = FACULTY_GRADE_VERIFY.load_index) "+
				"where faculty_load.user_index = "+strEmployeeIndex;
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		if(rs.getInt(1) == 2) {
			vFinalCopyDateMT.addElement(rs.getString(2));
			vFinalCopyDateMT.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(3)));
			vFinalCopyDateMT.addElement(WI.formatDateTime(rs.getLong(4), 3));
		}
		else {
			vFinalCopyDateFinal.addElement(rs.getString(2));
			vFinalCopyDateFinal.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(3)));
			vFinalCopyDateFinal.addElement(WI.formatDateTime(rs.getLong(4), 3));
		}
	}	
}

int iIsFinal = -1;// 0 = no, 1 = yes, -1 is not yet set.

%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">

<input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
<input type="hidden" name="show_delete">
<input type="hidden" name="show_save">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          GRADE SHEETS MAIN PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;<strong><font size="3" color="#FF0000">
	  <%=WI.getStrValue(strErrMsg,"Error Message: ","","")%></font></strong></td>
    </tr>
<%
strTemp = null;
String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 9);
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td height="25" colspan="6">
		  <table width="100%" cellpadding="0" cellspacing="0">
			<tr>
			  <td width="2%" height="25">&nbsp;</td>
			  <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
			  <td width="2%">&nbsp;</td>
			</tr>
		  </table>	  </td>
    </tr>
<%}if(vOtherFacEncodingAllowed != null && vOtherFacEncodingAllowed.size() > 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">You are allowed to Encode Other Faculties (select One from List) </td>
      <td height="25" colspan="3">
	  <select name="allowed_fac" onChange="ReloadPage();">
	  <option value=""></option>
	  <%
	  strTemp = WI.fillTextValue("allowed_fac");
	  for(int i = 0;i < vOtherFacEncodingAllowed.size(); i += 4) {
	  	if(strTemp.equals(vOtherFacEncodingAllowed.elementAt(i + 1)))
			strErrMsg = " selected";
		else	
			strErrMsg = "";
		%>
		<option value="<%=vOtherFacEncodingAllowed.elementAt(i + 1)%>" <%=strErrMsg%>><%=vOtherFacEncodingAllowed.elementAt(i + 1)%> (<%=vOtherFacEncodingAllowed.elementAt(i + 2)%>, <%=vOtherFacEncodingAllowed.elementAt(i + 3)%>)</option>
	  <%}%>	
	  </select>
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp; 
<%if(!bolEncodingForOther) {%>
	  <strong><font color="blue">NOTE: Subject/Sections appear are the sections handled by the logged in faculty Employee ID: <%=strEmployeeID%></font></strong>
<%}else{%>	  
		<strong><font color="red" size="4">NOTE: You will now be encoding for Faculty: <%=strEmployeeID%></font></strong>
<%}%>	  
	  </td>
    </tr>
    <tr>
      <td width="1%" height="25" rowspan="4" >&nbsp;</td>
      <td width="25%" height="25" valign="bottom" >Grades for</td>
      <td width="22%" valign="bottom" >Term</td>
      <td width="14%" valign="bottom" >School Year</td>
      <td colspan="2" >&nbsp; </td>
    </tr>
    <tr>
      <td height="25" valign="bottom" >
<%
if(bolEncodingAllowed){
	java.lang.StringBuffer strBuf = new java.lang.StringBuffer();
	
	strPmtSchIndex = WI.fillTextValue("grade_for");
	if(strPmtSchIndex.length() == 0) 
		strPmtSchIndex = (String)vExamSched.elementAt(3);
	
	Vector vGradeSchExam = new Vector();
	String strSQLQuery = "select pmt_sch_index from fa_pmt_schedule where is_valid = 2";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next())
		vGradeSchExam.addElement(rs.getString(1));
	rs.close();
	
	for(int i = 0; i < vExamSched.size(); i += 4) {
		if(vGradeSchExam.indexOf(vExamSched.elementAt(i + 3)) > -1)
			continue;
		if(iIsFinal== -1) {
			if(((String)vExamSched.elementAt(i)).toLowerCase().startsWith("final"))
				iIsFinal = 1;
		}
		//System.out.println((String)vExamSched.elementAt(i));
			
		if(strPmtSchIndex.equals(vExamSched.elementAt(i + 3))) {
			strTemp = " selected";
			if(((String)vExamSched.elementAt(i)).toLowerCase().startsWith("final"))
				iIsFinal = 1;
			else	
				iIsFinal = 0;
		}
		else	
			strTemp = "";
		strBuf.append("<option value='"+vExamSched.elementAt(i + 3)+"' "+strTemp+">"+(String)vExamSched.elementAt(i)+ " ("+WI.getStrValue((String)vExamSched.elementAt(i + 1),"", " - "+(String)vExamSched.elementAt(i + 2), (String)vExamSched.elementAt(i + 2))+")</option>");
	}
%>
        <select name="grade_for">
			<%=strBuf.toString()%>
        </select>
<%}else{%>
	<font size="1" style="font-weight:bold; color:red">Grade encoding is closed.</font>
<%}%>	  </td>
      <td valign="bottom" >
	  <select name="offering_sem" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
<%
if(strSemester.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strSemester.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strSemester.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td valign="bottom" >
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
<%
strTemp = String.valueOf(Integer.parseInt(strSYFrom) + 1);
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes">      </td>
      <td colspan="2" >
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" style="font-size:16px; font-weight:bold;">
	  <%if(iIsFinal == 1 && strSchCode.startsWith("SWU")){%>
	  	<input type="checkbox" name="graduating_only" value="checked" <%=WI.fillTextValue("graduating_only")%>> 
	  	Encode Graduating Student Only.
	    <%}%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center">
      <td height="25" colspan="8" style="font-weight:bold; font-size:12px;" class="thinborder" bgcolor="#66CCFF">Faculty Load Listing</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold" align="center">
      <td height="25" width="12%" class="thinborder">
	  <%if(bolEncodingAllowed) {%>
	  	Encode Grade
	  <%}else{%>
	  	xxxxx
	  <%}%>	  
	  </td>
      <td width="18%" class="thinborder"> Subject Code</td>
      <td width="25%" class="thinborder"> Subject Name</td>
      <td width="10%" class="thinborder"> Section</td>
      <!--<td width="5%" class="thinborder"> Type</td>-->
<%for(int i = 0; i <vPmtSchedule.size(); i += 2) {%> 
	  <%if(!bolIsCIT) {%>
      <td width="5%" class="thinborder"><%=vPmtSchedule.elementAt(i)%></td>
	  <%}if(bolIsCIT) {%>
		  <td width="10%" class="thinborder"><%=vPmtSchedule.elementAt(i)%><!--Final Copy Printed Date Time--></td>
	  <%}%>
<%}%>
    </tr>
<%for(int i = 0; i < vFacultyLoad.size(); i += 7){
if(vAllowedSubList != null && vAllowedSubList.indexOf(vFacultyLoad.elementAt(i)) == -1)
	continue;
%>
    <tr>
      <td height="35" class="thinborder" align="center">
	  <%if(bolEncodingAllowed) {%>
	    <input type="button" value="Encode Grade" name="_" style="font-size:11px; height:28px; width:100px; border: 1px solid #FF0000;" onClick="encodeGrade('<%=vFacultyLoad.elementAt(i + 3)%>','<%=vFacultyLoad.elementAt(i + 6)%>','<%=vFacultyLoad.elementAt(i + 2)%>');">
	  <%}else{%>
	  	xx
	  <%}%>	  
	  </td>
      <td class="thinborder"><%=vFacultyLoad.elementAt(i)%></td>
      <td class="thinborder"><%=vFacultyLoad.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vFacultyLoad.elementAt(i + 2)%></td>
      <!--<td class="thinborder"><%if(vFacultyLoad.elementAt(i + 5).equals("1")){%>LAB<%}else{%>&nbsp;<%}%></td>-->
<%
//System.out.println(vFinalCopyDateFinal);

for(int p = 0; p <vPmtSchedule.size(); p += 2) {%> 
	  <%if(!bolIsCIT) {
	  
	  strTemp = "View";
	  if(strSchCode.startsWith("NEU"))
	  	strTemp = "View/Print";
	  %>
      <td width="5%" class="thinborder"><input type="button" value="<%=strTemp%>" name="_" style="font-size:11px; height:24px; width:60px; border: 1px solid #FF0000;" onClick="viewGrade('<%=vFacultyLoad.elementAt(i + 3)%>','<%=vFacultyLoad.elementAt(i + 6)%>','<%=vFacultyLoad.elementAt(i + 2)%>','<%=vPmtSchedule.elementAt(p+1)%>');"></td>
	  <%}if(bolIsCIT) {
	  	if(vPmtSchedule.elementAt(p + 1).equals("2")) {
	  		iIndexOf = vFinalCopyDateMT.indexOf(vFacultyLoad.elementAt(i + 4));
			if(iIndexOf == -1)	
				strTemp = "&nbsp;";
			else {	
				strTemp = (String)vFinalCopyDateMT.elementAt(iIndexOf + 1)+"<br>"+(String)vFinalCopyDateMT.elementAt(iIndexOf + 2);
			}	
		}
		else {	//System.out.println(vFacultyLoad.elementAt(i + 4));
	  		iIndexOf = vFinalCopyDateFinal.indexOf(vFacultyLoad.elementAt(i + 4));//System.out.println(iIndexOf);
			if(iIndexOf == -1 )	
				strTemp = "&nbsp;";
			else if(vFinalCopyDateFinal.size() > (iIndexOf + 2)) {	
				strTemp = (String)vFinalCopyDateFinal.elementAt(iIndexOf + 1)+"<br>"+(String)vFinalCopyDateFinal.elementAt(iIndexOf + 2);
			}
			else
				strTemp = "&nbsp;";	
		}
	  %>
		  <td width="5%" class="thinborder"><%=strTemp%></td>
	  <%}%>
<%}%>
    </tr>
<%}%>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="emp_id" value="<%=strEmployeeID%>">
<input type="hidden" name="grade_name_">
<%
strTemp = WI.fillTextValue("re_print_only");
if(strSchCode.startsWith("NEU"))
	strTemp = "1";
%>
<input type="hidden" name="re_print_only" value="<%=strTemp%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
