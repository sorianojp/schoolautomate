<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	String strSQLQuery = null;
	String strSchCode = "WUP";//(String)request.getSession(false).getAttribute("school_code");
	String strInfo5 = (String)request.getSession(false).getAttribute("info5");
	String strGradeForName = WI.fillTextValue("grade_name_");//strSchCode = "CLDH";

	DBOperation dbOP  = null;
	String strErrMsg  = null;
	Vector vSecDetail = null;
	int iIndexOf = 0;
	int j = 0;

	if (strSchCode == null) {%>
		<p style="font-family:Geneva, Arial, Helvetica, sans-serif; font-weight:bold; color:#FF0000;"> You are already logged out. please login again.</p>
	<%return;}
	
		
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
	
	boolean bolRemovePercentGrade = false;
	if(strSchCode.startsWith("UL")) {
		strSchCode = "CGH";
		//I have to find if subejct is from masteral.. 
		if(WI.fillTextValue("subject").length() > 0) {
			//if masteral , remove the percent grade.
			strSQLQuery = "select * from cculum_masters where sub_index = "+WI.fillTextValue("subject");
			if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null)
				bolRemovePercentGrade = true;
		}
	}

	boolean bolIsCGH = false; //for cldh - i must have finals to record in %ge.
	if(strSchCode.startsWith("EAC") || strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") || 
		(strSchCode.startsWith("CLDH") && strGradeForName.toLowerCase().startsWith("final")) || 
		(strSchCode.startsWith("WUP") && strGradeForName.toLowerCase().startsWith("final")) || 
		(strSchCode.startsWith("UPH") && strGradeForName.toLowerCase().startsWith("final") && strInfo5 == null)	)
		bolIsCGH = true;//bolIsCGH = true;
	
	//for fatima : they are allowed to encode in both format.. 
	if(WI.fillTextValue("encode_percent_grade").length() > 0) 
		bolIsCGH = true;
		

	String strTemp    = null;
	boolean bolIsCSA = strSchCode.startsWith("CSA");	
	
	boolean bolIsCIT = strSchCode.startsWith("CIT");
	boolean bolShowMTerm = false;
	if(strGradeForName.toLowerCase().startsWith("final"))
		bolShowMTerm = true;
		
	boolean bolIsSummer = false;
	if(WI.fillTextValue("offering_sem").equals("0")) 
		bolIsSummer = true;
	
	
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
enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
enrollment.GradeSystem  GS = new enrollment.GradeSystem();
GradeSystemExtn gsExtn     = new GradeSystemExtn();

boolean bolEncodingForOther = false;
String strEmployeeID = (String)request.getSession(false).getAttribute("userId_gs");//allowed to encode toher users.. 
if(strEmployeeID == null || strEmployeeID.length() == 0)
	strEmployeeID = (String)request.getSession(false).getAttribute("userId");
else 
	bolEncodingForOther = true;
		
//strEmployeeID = "05253-0036";
String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
String strSubSecIndex   = null;

Vector vRetResult    = null;
Vector vPendingGrade = null;
Vector vEncodedGrade = null;
Vector vCGHGrade     = null;
Vector vStudListWithDropSub = new Vector();

//I have to save the midterm grade if bolShowMTerm is true.
Vector vMTermGrade      = null;
Vector vPrelimGrade     = null;
Vector vMTermAttendance = null;


if (WI.fillTextValue("sub_sec_index").length() == 0 ){
	if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
		strSubSecIndex =
			dbOP.mapOneToOther("E_SUB_SECTION join faculty_load " +
					 " on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
					"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index",
					" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
					" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
					WI.fillTextValue("sy_from")+ " and e_sub_section.offering_sy_to = "+
					WI.fillTextValue("sy_to")+ " and e_sub_section.offering_sem="+
					WI.fillTextValue("offering_sem")+" and is_lec=0");
	}
}
else
	strSubSecIndex = WI.fillTextValue("sub_sec_index");

boolean bolIsSubmitted = false;
if(WI.fillTextValue("finalize_gs").length() > 0) {
	strSQLQuery = "update faculty_load set DATE_SUBMITTED_WUP = '"+WI.getTodaysDate()+"' where sub_sec_index = "+
	strSubSecIndex +" and user_index = "+(String)request.getSession(false).getAttribute("userIndex")+" and is_valid = 1";
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
}
strSQLQuery = "select DATE_SUBMITTED_WUP from faculty_load where sub_sec_index = "+strSubSecIndex+
				" and user_index = "+(String)request.getSession(false).getAttribute("userIndex")+" and is_valid = 1";
if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null)
	bolIsSubmitted = true;



String strGradeName = null;
if(WI.fillTextValue("grade_for").length() > 0) 
	strGradeName = dbOP.mapOneToOther("FA_PMT_SCHEDULE", "PMT_SCH_INDEX", WI.fillTextValue("grade_for"), "EXAM_NAME", null);

boolean bolIsAllowedToEncode = gsExtn.isAllowedToEncodeGS(dbOP,strEmployeeID, 
								WI.fillTextValue("grade_for"),WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("offering_sem"));
boolean bolIsAllowedToDelete = gsExtn.bolIsGSDelAllowedOthers(dbOP,strSubSecIndex, WI.fillTextValue("grade_for"), strGradeName);
if(bolIsAllowedToDelete && !bolIsAllowedToEncode)
	bolIsAllowedToDelete = false;
if(bolIsSubmitted)
	bolIsAllowedToDelete = false;

boolean bolFinal = false;
if (WI.getStrValue(strGradeName).toLowerCase().startsWith("final")) {
	bolFinal = true;
}

boolean bolForceAllowDel = false;//for deleting one only.. 
    if(WI.fillTextValue("del_one").length() > 0) {
	  String strGradeTableName = "GRADE_SHEET";
	  if(bolFinal)
	  	strGradeTableName = "G_SHEET_FINAL";
		
      strSQLQuery = "select FORCE_LOCK_STAT from "+strGradeTableName+" where gs_index = "+WI.fillTextValue("del_one");
      //System.out.println(strSQLQuery);
      strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
      if(strSQLQuery != null && strSQLQuery.equals("2"))
        bolForceAllowDel = true;
    }



strTemp = WI.fillTextValue("page_action");
if(strTemp.equals("1")) {//save grade sheet.
	if(bolIsAllowedToEncode) {
		if(GS.createGradeSheet(dbOP,request))
			strErrMsg = "Grade sheet is created successfully.";
		else
			strErrMsg = GS.getErrMsg();
	}
	else {
		strErrMsg = "Saving grde sheet is not allowed.";
	}
}
else if(strTemp.equals("0")) { //call for delete.
	if(bolForceAllowDel || bolIsAllowedToDelete) {
		if(GS.delGradeSheet(dbOP, request))
			strErrMsg = "Grade information deleted successfully.";
		else
			strErrMsg = GS.getErrMsg();
	}else {
		strErrMsg = "Delete is not allowed";
	}
		
}

//get here necessary information.

if(strSubSecIndex != null && strSubSecIndex.length() > 0) {//get here subject section detail.
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
	vStudListWithDropSub = gsExtn.getStudListWithSubStatChanged(dbOP, strSubSecIndex);
}

//Get here the pending grade to be encoded list and list of grades encoded.
	
if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
	if(bolShowMTerm) {
		strTemp = "select pmt_sch_index from fa_pmt_schedule where exam_name like 'm%'";
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		
		vMTermGrade      = gsExtn.getStudListForGradeSheetEncoding(dbOP, strTemp, strSubSecIndex,true);
		strTemp = "select pmt_sch_index from fa_pmt_schedule where exam_name like 'prelim%'";
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);

		vPrelimGrade     = gsExtn.getStudListForGradeSheetEncoding(dbOP, strTemp, strSubSecIndex,true);
		if(bolIsSummer)
			vMTermGrade = vPrelimGrade;
		//System.out.println(vMTermGrade);

		gsExtn.vAttendance = new Vector();
	}
	vRetResult = gsExtn.getStudListForGradeSheetEncoding(dbOP, WI.fillTextValue("grade_for"),
												strSubSecIndex,false);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else {
		vEncodedGrade = (Vector)vRetResult.elementAt(0);
		vPendingGrade = (Vector)vRetResult.elementAt(1);
	}
}
if(vMTermGrade == null)
	vMTermGrade = new Vector();
if(vMTermAttendance == null)
	vMTermAttendance = new Vector();

//System.out.println(WI.fillTextValue("grade_for"));
//System.out.println(vMTermGrade);
//System.out.println(vPrelimGrade);


//for CIT, all drop downs are read only.. 
String strIsReadOnly = null;
if(bolIsCIT)
	strIsReadOnly = " disabled";
else	
	strIsReadOnly = "";
//System.out.println(vEncodedGrade);

Vector vForcedLocked = null;
Vector vUnlockedSingle = new Vector(); // if one is unlocked.

if(bolIsCIT) {
	vForcedLocked = gsExtn.advanceGrade(dbOP, strSubSecIndex, (String)request.getSession(false).getAttribute("userIndex"), 1);
	if(bolFinal) 
		strTemp = "select gs_index from g_sheet_final where sub_sec_index = "+strSubSecIndex+" and is_valid = 1 and FORCE_LOCK_STAT = 2";
	else
		strTemp = "select gs_index from grade_sheet where sub_sec_index = "+strSubSecIndex+" and is_valid = 1 and FORCE_LOCK_STAT = 2";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next())
		vUnlockedSingle.addElement(rs.getString(1));
	rs.close();
}
if(vForcedLocked == null)
	vForcedLocked = new Vector();


Vector vGradeSystem = GS.viewAllGrade(dbOP, request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
.nav {
     /**color: #000000;**/
     background-color: #FFFFFF;
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     background-color: #FAFCDD;
	 font-weight:bold;
}

</style>
</head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript">
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}


var imgWnd;
function PrintPg(strIsFinalCopy) {
	if(strIsFinalCopy == '1') {
		if(!confirm("Printing Final copy locks the Grade sheet. Please click OK to print final copy."))
			return;
		document.gsheet.is_final_copy.value=strIsFinalCopy;
	}
	
	document.gsheet.print_page.value = "1";
	this.SubmitOnce('gsheet');
}
function CopyAll()
{
	document.gsheet.print_page.value = "";
	var strDate = document.gsheet.date0.value;
	var strTime = document.gsheet.time0.value;
	var maxDisp = document.gsheet.disp_count_gs_pending.value;

	if(document.gsheet.copy_all.checked) {
		if(strDate.length == 0 || strTime.length ==0) {
			alert("Please enter first Date and time field input.");
			document.gsheet.copy_all.checked = false;
			return;
		}
		//run a loop to copy information.	
		for(var i =1; i< maxDisp; ++i) {
			eval('document.gsheet.date'+i+'.value="'+strDate+'"');
			eval('document.gsheet.time'+i+'.value="'+strTime+'"');			
		}
	}
}
function delOneGrade(objChkBox, gsRef) {
	if(!confirm("Are you sure you want to Modify this record."))
		return;
	if(objChkBox) {
		document.gsheet.del_one.value=gsRef;
		objChkBox.checked = true;
		PageAction(0);
	}
}
function PageAction(strAction)
{
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value=strAction;

	//I have to check here, if cgh, faculty must click convert percentage to QP..
	if(strAction == 1) {
		<%if(bolIsCGH && !bolRemovePercentGrade) {%>
			if(!document.gsheet.convert_grade || !document.gsheet.convert_grade.checked) {
				alert("Please click Convert grade to convert percentage to Final point.");
				return;
			}
		<%}//if cgh, user must click convert grade.%>
		//I need to check if there is atleast one check box is selected.
		var iMaxDisp = document.gsheet.disp_count_gs_pending.value;
		var objChkBox; var bolReturn = true;
		for( i = 0; i < iMaxDisp; ++i) {
			eval('objChkBox=document.gsheet.save_'+i);
			if(!objChkBox)
				continue;
			if(objChkBox.checked) {
				bolReturn = false;
				break;
			}				
		}
		if(bolReturn) {
			alert("Please select atleast one checkbox for saving grade.");
			return;
		}
		<%if(bolIsCIT){%>
			bolReturn = true; var objTemp;
			for( i = 0; i < iMaxDisp; ++i) {
				eval('objChkBox=document.gsheet.save_'+i);
				if(!objChkBox)
					continue;
				eval('objTemp=document.gsheet.attendance'+i);
				if(!objTemp)
					continue;
				if(objTemp.value.length > 0) {
					bolReturn  = false;
					break;
				}				
			}
			if(bolReturn) {
				alert("Please enter atleast one absence value. Encode 0 for atleast one record if no one has absences.");
				return;
			}
		<%}%>
	}
	if(document.gsheet.show_save.value == "1") {
		document.gsheet.hide_save.src = "../../../images/blank.gif";
		
		//there may be 2 save buttons.
		if(document.gsheet.save_text2) {
			document.gsheet.hide_save2.src = "../../../images/blank.gif";
			if(strAction ==1)
				document.gsheet.save_text2.value = "Saving in progress....";
		}
	}
	if(document.gsheet.show_delete.value == "1")
		document.gsheet.hide_delete.src = "../../../images/blank.gif";
	if(strAction ==0 && document.gsheet.delete_text)
		document.gsheet.delete_text.value = "deleting in progress....";
	if(strAction ==1)
		document.gsheet.save_text.value = "Saving in progress....";


	this.ShowProcessing();
}
function ReloadPage()
{
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value="";
	if(document.gsheet.show_save.value == "1")
		document.gsheet.hide_save.src = "../../../images/blank.gif";
	if(document.gsheet.show_delete.value == "1")
		document.gsheet.hide_delete.src = "../../../images/blank.gif";
	this.ShowProcessing();
}
function EncodeInPercentGrade() {
	if(!confirm('System now will switch to selected grade encoding mode. If you have encoded any grade and not yet saved, entries will be removed. Click OK to reload page, Cancel to continue encoding')) {
		document.gsheet.encode_percent_grade.checked = !document.gsheet.encode_percent_grade.checked;
		return;
	}
	ReloadPage();	
}


function ResetPage()
{
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value="";
	document.gsheet.subject.selectedIndex = 0;
	this.ShowProcessing();
}


function ShowProcessing() {

	if(document.gsheet.grade_for) {
		if(document.gsheet.grade_for.selectedIndex)
			document.gsheet.grade_name_.value = document.gsheet.grade_for[document.gsheet.grade_for.selectedIndex].text;
		else	
			document.gsheet.grade_name_.value = document.gsheet.grade_for.value;//if read only is applied.
	}

	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	this.SubmitOnce('gsheet');
	imgWnd.focus();
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}
function checkAll()
{
	var maxDisp = document.gsheet.disp_count_gs_encoded.value;
	//unselect if it is unchecked.
	var bolCheck = document.gsheet.selAll.checked;
	
	var objChk;
	for(var i =0; i< maxDisp; ++i) {
		eval('objChk=document.gsheet.del_'+i);
		if(!objChk)
			continue;
		objChk.checked=bolCheck;
	}
/**
	if(!document.gsheet.selAll.checked) {
		for(var i =0; i< maxDisp; ++i)
			eval('document.gsheet.del_'+i+'.checked=false');
	}
	else {
		for(var i =0; i< maxDisp; ++i)
			eval('document.gsheet.del_'+i+'.checked=true');
	}
**/
}
function checkAllSave() {
	var maxDisp = document.gsheet.disp_count_gs_pending.value;
	//unselect if it is unchecked.
	if(!document.gsheet.selAllSave.checked) {
		for(var i =0; i< maxDisp; ++i)
			eval('document.gsheet.save_'+i+'.checked=false');
	}
	else {
		for(var i =0; i< maxDisp; ++i)
			eval('document.gsheet.save_'+i+'.checked=true');
	}
}


// for AUF / CGH ONLY!!!

var iFailedSelectedIndex = -1;
var iPassedSelectedIndex = -1;
var iConditioanlSelectedIndex = -1;//for PIT.
function GetFailedSelectedIndex(strRemark){
<%
	strTemp = "fail";
	if (strSchCode.startsWith("AUF"))
		strTemp = "failed";
%>


	for (v=eval("document.gsheet."+strRemark+".length")-1 ; v >= 0; --v){
		if (eval("document.gsheet."+strRemark+
					"[" + v + "].text").toLowerCase().indexOf('<%=strTemp%>') == 0)
			return v;
	}

}

function GetPassedSelectedIndex(strRemark){
	for (v=eval("document.gsheet."+strRemark+".length")-1 ; v >= 0; --v){
		if (eval("document.gsheet."+strRemark+
					"[" + v + "].text").toLowerCase().indexOf('pass') == 0 &&
			eval("document.gsheet."+strRemark+"[" + v + "].text").toLowerCase().indexOf('pass/') == -1)
			return v;
	}

}
function GetConditionalSelectedIndex(strRemark){
	for (v=eval("document.gsheet."+strRemark+".length")-1 ; v >= 0; --v){
		if (eval("document.gsheet."+strRemark+"[" + v + "].text").toLowerCase().indexOf('cond') == 0)
			return v;
	}

}


function updateAvg(strPGrade,strMGrade,objFGrade,objAvgGrade, bolComputeAvg) {
	if(eval(objFGrade.value) > 100) {
		alert (" Invalid grade");
		objFGrade.value = '';
		objFGrade.focus();
		return;
	}
	if(!bolComputeAvg)
		return;
	if(objFGrade.value == '')
		return;
	<%if(bolIsSummer) {%>
		var avgGrade = eval(strPGrade) + eval(objFGrade.value);
		avgGrade = eval(avgGrade)/2;
	<%}else{%>
		var avgGrade = eval(strPGrade) + eval(strMGrade) + eval(objFGrade.value);
		avgGrade = eval(avgGrade)/3;
	<%}%>
	
	avgGrade = formatFloat( avgGrade,1, false);
	objAvgGrade.value = avgGrade;
	/**
	  retValue = new String(avgGrade);
  var iIndex = avgGrade.indexOf('.',0);
  if(iIndex > retValue.length -2)
  	retValue = retValue.substring(0,retValue.length-2);
	
	objAvgGrade.value = retValue;
	**/
	
}


function UpdateRemarks(strGrade,strRemark, objChkBox){
	var vGrade = "";
	eval("vGrade = document.gsheet."+strGrade+".value");

	if(vGrade.length == 0)
	return;
	
	//1 = 3 to 5 fail, else pass., 
	var iGradeSystem = 0;// 0 meaning 0 to 100
	
	//if fatima grade system is 1, but if encode in %ge grade, then it is in %ge.
	var bolInvalidGrade = false;
		
	
	<%if(GS.bolIsGradeSystemExtn && strSchCode.startsWith("WUP")){%>
		iGradeSystem = 5;
	<%}else if(strSchCode.startsWith("DBTC")){%>
		iGradeSystem = 1;
	<%}else if (strSchCode.startsWith("PIT")) {%>
		iGradeSystem = 2;
	<%}else if (strSchCode.startsWith("CIT")) {//1, 2 to 2.9 = fail, 3 to 5 pass, other not allowed.
		if(bolFinal){%>
			iGradeSystem = 4;
		<%}else{%>
			iGradeSystem = 3;
		<%}%>
	<%}%>


	if ( eval(vGrade) > 100){
		alert (" Invalid grade");
		eval("document.gsheet."+strGrade+".value=''");
		eval("document.gsheet."+strGrade+".focus()");
		objChkBox.checked = false;
		return;
	}
	if(iGradeSystem == 0) {
		if ( eval(vGrade) < 75){
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else if ( eval(vGrade) >= 75){
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
		}
	}
	else if(iGradeSystem == 5) {
		if ( eval(vGrade) < 85){
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else if ( eval(vGrade) >= 85){
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
		}
	}
	

}
function updateCheckBox(objGSInput, objChkBox) {

	if(objGSInput.value.length == 0) {
		if(objChkBox)
			objChkBox.checked = false;
	}
	else {
		if(objChkBox)
			objChkBox.checked = true;
	}
	
	//I have to implement the auto updating the grades.
	if(document.gsheet.convert_grade && document.gsheet.convert_grade.checked)
		ConvertGrade();
}


//call this to trigger TAB.
//some cases, i have more options.
function MoveNext(e, objNext1, objNext2, objNext3, objNext4) {//alert("I am here.");
	if(e.keyCode == 13) {
		if(objNext1)
			objNext1.focus();
		else if(objNext2)
			objNext2.focus();
		else if(objNext3)
			objNext3.focus();
		else if(objNext4)
			objNext4.focus();
	}
}


//implement Ajax to submit advanced Grade.. 
function SubmitAdanceGrade() {
	var objCOAInput = document.getElementById("submit_adv_grade");
		
	this.InitXmlHttpObject2(objCOAInput, 2,"<img src='../../../Ajax/ajax-loader_small_black.gif'>");//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=216&section=<%=strSubSecIndex%>";

	this.processRequest(strURL);
}

//for CIT, they can give NG only if mterm grade is >= 2.9
function checkNGRemark() {

}


function validateGrade(objPercent, objGrade, objChkBox, objRemark) {
	<%if(strSchCode.startsWith("EAC")){%>
		return;
	<%}%>
	var strPercent = "";
	var strGrade   = "";
	var strRemark  = "";
	
	if(objPercent) 
		strPercent = objPercent.value;
	if(objGrade) 
		strGrade = objGrade.value;
	if(objRemark) 
		strRemark = objRemark[objRemark.selectedIndex].text;
	//alert(strPercent)
	//alert(strRemark);
	//alert(strGrade)	
	
	strRemark = strRemark.toLowerCase();
	if(strRemark.indexOf("pass") == 0 || strRemark.indexOf("fail") == 0) {
		if(strGrade == '') 
			objChkBox.checked = false;
		return;
	}
	objChkBox.checked = true;
	
	objPercent.value='';
	objGrade.value = '';
}

function FinalizeGS() {
	if(!confirm('Are you sure you want to finalize grade sheet encoding. After finalize, you will not be able to edit Final term grade.'))
	return;
	document.gsheet.finalize_gs.value = '1';
	document.gsheet.submit();
}
</script>


<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<form name="gsheet" action="./grade_sheet_WUP.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">

<input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
<input type="hidden" name="prevent_fwd" value="<%=WI.fillTextValue("prevent_fwd")%>">
<input type="hidden" name="show_delete">
<input type="hidden" name="show_save">

<%if(strIsReadOnly.length() > 0) {%>
<input type="hidden" name="grade_for" value="<%=WI.fillTextValue("grade_for")%>">
<input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="section_name" value="<%=WI.fillTextValue("section_name")%>">
<input type="hidden" name="subject" value="<%=WI.fillTextValue("subject")%>">

<%}%>




    <tr bgcolor="#A49A6A">
      <td height="25" colspan="7"><div align="center"><font color="#FFFFFF"><strong>::::
          GRADE SHEETS PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;<strong><font size="3" color="#FF0000">
	  <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
    </tr>
<%
strTemp = null;
if(strEmployeeIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strEmployeeIndex, 9);
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td height="25" colspan="7">
		  <table width="100%" cellpadding="0" cellspacing="0">
			<tr>
			  <td width="2%" height="25">&nbsp;</td>
			  <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
			  <td width="2%">&nbsp;</td>
			</tr>
		  </table>
	  </td>
    </tr>
<%if(!strSchCode.startsWith("WUP"))%>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp; 
<%if(!bolEncodingForOther) {%>
	  <strong><font color="blue">NOTE: Subject/Sections appear are the sections handled by the logged in faculty Employee ID: <%=strEmployeeID%></font></strong>
<%}else{%>	  
		<strong><font color="red" size="4">NOTE: You are now encoding for Faculty: <%=strEmployeeID%></font></strong>
<%}%>	  
	  </td>
    </tr>
<%}%>
    <tr>
      <td width="1%" height="25" rowspan="4" >&nbsp;</td>
      <td width="25%" height="25" valign="bottom" >Grades for</td>
      <td width="22%" valign="bottom" >Term</td>
      <td width="27%" valign="bottom" >School Year</td>
      <td colspan="2" >&nbsp; </td>
      <td width="8%" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" valign="bottom" >
<%
String strTerm =WI.fillTextValue("offering_sem");
if(strTerm.length() ==0)
	strTerm = (String)request.getSession(false).getAttribute("cur_sem");
 

if(strSchCode.startsWith("CIT"))
	strTemp = " and (exam_name like 'm%' or exam_name like 'f%') ";
else	
	strTemp = "";
if(strTerm.equals("0") && strSchCode.startsWith("AUF"))
	strTemp = " and (exam_name not like 'p%') ";
//I have to check now if graduate courses.. 
if(strSchCode.startsWith("AUF") && WI.fillTextValue("subject").length() > 0 ) {
	strSQLQuery = "select * from cculum_masters where sub_index = "+WI.fillTextValue("subject");
	if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null)
		strTemp = " and (exam_name not like 'p%') ";
}
if(bolIsSummer)
	strTemp = " and exam_name not like 'm%' ";
//System.out.println(strTemp);
%>
       <select name="grade_for" <%=strIsReadOnly%>>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and (is_valid=1 or is_valid = 0) and BSC_GRADING_NAME is not null "+strTemp+" order by EXAM_PERIOD_ORDER asc", request.getParameter("grade_for"), false)%>
        </select></td>
      <td valign="bottom" >
	  <select name="offering_sem" onChange="ReloadPage();" <%=strIsReadOnly%>>
          <option value="1">1st Sem</option>
          <%
if(strTerm.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTerm.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}if(strTerm.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select></td>
      <td valign="bottom" >
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("gsheet","sy_from","sy_to")' <%=strIsReadOnly%>>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes" <%=strIsReadOnly%>>      </td>
      <td colspan="2" >
	  	<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  </td>
      <td width="8%" >&nbsp;</td>
    </tr>
</table>
<%
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() >0){

	if (!strSchCode.startsWith("CPU")) {
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%"></td>
      <td width="39%" height="25" valign="bottom" >Section Handled</td>
      <td valign="bottom" >Instructor (Name of logged in user)</td>
    </tr>
    <tr>
      <td></td>
      <td height="25" >
        <%
strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  where "+
			"faculty_load.is_valid = 1 and e_sub_section.is_valid = 1 and e_sub_section.OFFERING_SY_FROM ="+
			WI.fillTextValue("sy_from")+" and e_sub_section.OFFERING_SEM = "+WI.fillTextValue("offering_sem")+" and faculty_load.user_index = "+
			strEmployeeIndex;
%>
        <select name="section_name" onChange="ResetPage();" <%=strIsReadOnly%>>
          <option value="">Select a section</option>
          <%=dbOP.loadCombo("distinct section","section",strTemp, request.getParameter("section_name"), false)%>
        </select> </td>
      <td height="25" > <strong>
        <%if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%>
        <%}%>
        </strong> </td>
    </tr>
    <tr>
      <td width="1%"></td>
      <td height="25">Subject Handled</td>
      <td>Subject Title </td>
    </tr>
    <tr>
      <td width="1%"></td>
      <td height="25" >
        <%
strTemp = " from faculty_load join e_sub_section on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) "+
			"join subject on (e_sub_section.sub_index = subject.sub_index) where faculty_load.user_index = "+
			strEmployeeIndex+" and e_sub_section.section = '"+WI.fillTextValue("section_name")+
			"' and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
			WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
			" and e_sub_section.offering_sem="+WI.fillTextValue("offering_sem");
//System.out.println(strTemp);%>
        <select name="subject" onChange="ReloadPage();" <%=strIsReadOnly%>>
          <option value="">Select a subject</option>
          <%=dbOP.loadCombo("distinct subject.sub_index","sub_code",strTemp, request.getParameter("subject"), false)%>
        </select></td>
      <td> <strong>
        <%
if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%>
        <%=WI.getStrValue(strTemp)%></strong></td>
      <%}%>
    </tr>
  </table>
<%}else{%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%"></td>
      <td width="39%" height="25" valign="bottom" >Stub Code :: Subject</td>
      <td valign="bottom" >Instructor </td>
    </tr>
    <tr>
      <td></td>
      <td height="25" > <%
strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  " +
			" join subject on (e_sub_section.sub_index = subject.sub_index) where "+
			" faculty_load.is_valid = 1 and e_sub_section.is_valid = 1 and is_main =1 " +
			" and MIX_SEC_REF_INDEX is null  and is_lec = 0 and e_sub_section.OFFERING_SY_FROM ="+
			WI.fillTextValue("sy_from")+" and e_sub_section.OFFERING_SY_TO="+WI.fillTextValue("sy_to")+
			" and e_sub_section.OFFERING_SEM = "+WI.fillTextValue("offering_sem")+
			" and faculty_load.user_index = "+
			strEmployeeIndex + " order by e_sub_section.sub_sec_index";
%> <select name="sub_sec_index" onChange="ReloadPage();" <%=strIsReadOnly%>>
          <option value="">Select a section</option>
          <%=dbOP.loadCombo("e_sub_section.sub_sec_index",
		  					" e_sub_section.sub_sec_index , sub_code",
							strTemp, request.getParameter("sub_sec_index"), false)%>
        </select> </td>
      <td height="25" > <strong>
        <%if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%>
        <%}%>
        </strong> </td>
    </tr>
  </table>


<%
 }//end of if else CPU's Header
}
if(vSecDetail != null){%>
  <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
    <tr>
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%>
    <tr>
      <td>&nbsp;</td>
      <td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td>&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}
if(vPendingGrade != null && vPendingGrade.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="2"><div align="center">LIST OF STUDENTS ENROLLED
          IN THIS SUBJECT</div></td>
    </tr>
    <tr>
      <td width="2%" height="25"><div align="center"></div></td>
      <td height="25">
	  <%if(bolIsCGH && !bolRemovePercentGrade){%>
			<input type="checkbox" name="convert_grade" value="1" onClick="ConvertGrade();" checked="checked" readonly>
			<font color="#0000FF" size="1"><b>Convert grade to Final Point. Final point grade goes to TOR.</b></font>
		<%}%>
		
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<div align="right">	  
		<%if(strSchCode.startsWith("FATIMA")){%>
			<input type="checkbox" name="encode_percent_grade" value="checked" <%=WI.fillTextValue("encode_percent_grade")%> onClick="EncodeInPercentGrade();">
			<font color="#0000FF" size="2"><b>Encode in Percent Grade</b></font>
		<%}%>	  
		</div>
		
	  </td>
    </tr>
	<%if(bolIsCIT){%>
    <tr>
      <td height="25" colspan="2">
	  
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="6%">&nbsp;</td>
      <td width="44%"><%=WI.getStrValue(gsExtn.getErrMsg())%></td>
      <td width="50%" align="right">
	  <%if(bolIsAllowedToEncode && bolIsAllowedToDelete) {%>
        <a href="javascript:PageAction(1);"><img name="hide_save2" src="../../../images/save.gif" border="0"></a>
        <input name="save_text2" type="text" tabindex="-1" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 9px; border: 0;" value="Click to Save grades">
<script language="JavaScript">
document.gsheet.show_save.value = "1";
</script>
        <%}%>      
	  </td>
    </tr>
    <tr>
      <td width="6%">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
	  
	  </td>
    </tr>
	<%}%>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%"  height="25" >&nbsp;</td>
      <td width="8%"  height="25" ><div align="center"><font size="1"><strong>STUDENT ID </strong></font></div></td>
      <td width="20%" ><div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div></td>
      <td width="10%" ><div align="center"><font size="1"><strong>COURSE</strong></font></div></td>
      <td width="4%" ><font size="1"><strong>YEAR</strong></font></td>
<%if(bolShowMTerm){%>
      <td width="4%" align="center"><font size="1"><strong>Prelim Grade</strong></font></td>
      <%if(!bolIsSummer) {%>
		  <td width="4%" align="center"><font size="1"><strong>Midterm<br>Grade</strong></font></td>
	  <%}%>
      <td width="3%" align="center"><font size="1"><strong>Final Term Grade</strong></font></td>
      <%}%>
 <%if(bolIsCGH && !bolRemovePercentGrade){%>
      <td width="3%" align="center"><font size="1"><strong>Avg Grade</strong></font></td>
 <%}%>
      <td width="3%" ><div align="center"><font size="1"><strong>GRADE<%if(bolIsCGH){%><br> FP<%}%></strong></font></div></td>
      <td width="6%" ><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
      <td width="6%"  ><div align="center"><font size="1"><strong> <font size="1">SELECT <%if(!bolIsCIT){%> ALL<%}%></font></strong> <br>
          <%if(!bolIsCIT){%><input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();"><%}%>
          </font></div></td>
    </tr>
    <%
String strFontColor = null;//if red, i should not show input for grade.
/**
String strBlockedRemark = dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0 and is_internal = 1 and (remark ='no permit' or remark like 'drop%') order by remark desc",null , false,false);
String strNCRemark = dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0 and is_internal = 1 and (remark ='no permit' or remark like 'drop%' or remark like 'inc%') order by remark desc",null , false,false);
**/
String strBlockedRemark = dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0 and is_internal = 1 and (remark not like 'p%' and remark not like 'unofficial%') order by remark desc","7" , false,false);
String strNCRemark = dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0 and is_internal = 1 and (remark not like 'p%') order by remark desc",null , false,false);


boolean bolHideAvgGrade = false;


Vector vAdmSlipNumber = null;//new Vector();
if(strGradeName.toLowerCase().startsWith("f")) {
	vAdmSlipNumber = new Vector();
	
	strSQLQuery = "select user_index from adm_slip_prn_count where sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("offering_sem")+
		" and is_valid = 1 and pmt_sch_index = "+WI.fillTextValue("grade_for")+" and len(adm_slip_number) > 4";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) 
		vAdmSlipNumber.addElement(rs.getString(1));
	rs.close();
}

strTemp = "";
boolean bolIsMasteral = false;
if(strSchCode.startsWith("CIT") && strGradeName != null) {
	if(strGradeName.toLowerCase().startsWith("m")) 
		strTemp = " and remark_index in (1,2,11) ";
	else {
		strTemp = " and remark_index in (1,2,11 ";
		strNCRemark = " and remark_index in (1,2,11,12 ";
		//if masteral, i have to include in progress.
		strSQLQuery = "select cur_index from cculum_Masters where sub_index = "+WI.fillTextValue("subject")+
		" and is_valid = 1";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null) {
			bolIsMasteral = true;
			
			strTemp += ", 14";
			strNCRemark += ", 14";
		}
		strTemp += ")";
		strNCRemark += ")";
		strNCRemark = dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0 and is_internal = 1 "+strNCRemark,null , false,false);

	}
}
String strAllowedRemark = dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0 and is_internal = 1 and remark <> 'no permit'"+strTemp,null , false,false);

String strStudID = null; String strMGrade = null; String strPGrade = null; String strMAttendance = null; boolean bolShowNCRemark = false;//for CIT, show NC Remark if mterm grade is >= 2.9

//System.out.println("Printing Final Grade: "+vPendingGrade);

for(int i=0; i<vPendingGrade.size(); i +=10,++j){
if(Integer.parseInt((String)vPendingGrade.elementAt(i + 9)) == 0)
	strFontColor = " color = red";
else
	strFontColor = "";

strStudID = (String)vPendingGrade.elementAt(i + 3); 
//vAdmSlipNumber = null;
if(vAdmSlipNumber != null && vAdmSlipNumber.indexOf(vPendingGrade.elementAt(i + 2)) == -1)
	bolHideAvgGrade = true;
else	
	bolHideAvgGrade = false;

%>
    <tr class="nav" id="msg<%=j%>" onMouseOver="navRollOver('msg<%=j%>', 'on')" onMouseOut="navRollOver('msg<%=j%>', 'off')">
      <td><font size="1"><%=j + 1%></font>
      <td  height="25" ><font size="1" <%=strFontColor%>><%=(String)vPendingGrade.elementAt(i+3)%></font>
	  <input type="hidden" name="cur_hist<%=j%>" value="<%=(String)vPendingGrade.elementAt(i)%>">
      <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vPendingGrade.elementAt(i+1)%>">
      <input type="hidden" name="credit_earned<%=j%>" value="<%=(String)vPendingGrade.elementAt(i+8)%>">      </td>
      <td ><font size="1" <%=strFontColor%>><%=(String)vPendingGrade.elementAt(i+4)%></font></td>
      <td ><font size="1" <%=strFontColor%>><%=(String)vPendingGrade.elementAt(i+5)%></font></td>

      <td align="center"><font size="1" <%=strFontColor%>><%=WI.getStrValue(vPendingGrade.elementAt(i+7),"N/A")%></font></td>
<%
bolShowNCRemark = false;
if(bolShowMTerm){
iIndexOf = vPrelimGrade.indexOf(strStudID); //System.out.println("Printing iIndexOf : "+iIndexOf+" for ID : "+strStudID);
if(iIndexOf == -1) {
	strPGrade = "&nbsp;";
	bolShowNCRemark = true;
}
else {
	strPGrade = (String)vPrelimGrade.elementAt(iIndexOf + 6);
	if(strPGrade == null) {
		strPGrade = (String)vPrelimGrade.elementAt(iIndexOf + 7);
		bolShowNCRemark = true;
	}
	if(!bolShowNCRemark) {
		try {
			Double.parseDouble(strPGrade);
		}
		catch(Exception e) {
			bolShowNCRemark = true;
		}
	} 
}
%>
      <td width="4%" align="center"><%=strPGrade%></td>
<%
iIndexOf = vMTermGrade.indexOf(strStudID); //System.out.println("Printing iIndexOf : "+iIndexOf+" for ID : "+strStudID);
if(iIndexOf == -1) {
	strMGrade = "&nbsp;";
	bolShowNCRemark = true;
}
else {
	strMGrade = (String)vMTermGrade.elementAt(iIndexOf + 6);
	if(strMGrade == null) {
		strMGrade = (String)vMTermGrade.elementAt(iIndexOf + 7);
		bolShowNCRemark = true;
	}
	if(!bolShowNCRemark) {
		try {
			Double.parseDouble(strMGrade);
		}
		catch(Exception e) {
			bolShowNCRemark = true;
		}
	} 
}
%>
            <%if(!bolIsSummer) {%>
				<td width="4%" align="center"><%=strMGrade%></td>
			<%}%>
<%}%>
<%
if(bolShowNCRemark || bolHideAvgGrade) {
	bolHideAvgGrade = true;
}

if(bolIsCGH && !bolRemovePercentGrade){%>
      <td align="center">
	  <%if(strFontColor.length() ==0 ){%>
        <input name="grade_x<%=j%>" type="text" size="3" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';
	  AllowOnlyFloat('gsheet','grade_x<%=j%>');updateAvg('<%=strPGrade%>','<%=strMGrade%>',document.gsheet.grade_x<%=j%>,document.gsheet.grade_percent<%=j%>,<%=!bolShowNCRemark%>); updateCheckBox(document.gsheet.grade_x<%=j%>, document.gsheet.save_<%=j%>);
	  <%if(!bolShowNCRemark && !bolHideAvgGrade) {%> UpdateRemarks('grade_percent<%=j%>','remark<%=j%>');<%}%>"
	  	  onKeyUp="AllowOnlyFloat('gsheet','grade_x<%=j%>');MoveNext(event, document.gsheet.attendance<%=j+1%>,document.gsheet.grade_x<%=j+1%>);">
      <%}else {%> &nbsp; <%}%>	  </td>
      <td align="center">
	  <%if(!bolHideAvgGrade){%>
        <input name="grade_percent<%=j%>" type="text" size="3" class="textbox_noborder" <%if(bolIsCGH && !bolRemovePercentGrade){%>readonly='yes'  tabindex="-1"<%}%>
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';
	  AllowOnlyFloat('gsheet','grade_percent<%=j%>');updateCheckBox(document.gsheet.grade_percent<%=j%>, document.gsheet.save_<%=j%>);UpdateRemarks('grade_percent<%=j%>','remark<%=j%>');"
	  	  onKeyUp="AllowOnlyFloat('gsheet','grade_percent<%=j%>');">
      <%}else {%> 
        <input name="grade_percent<%=j%>" type="text" size="3" class="textbox_noborder" <%if(bolIsCGH && !bolRemovePercentGrade){%>readonly='yes'  tabindex="-1"<%}%>
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';
	  AllowOnlyFloat('gsheet','grade_percent<%=j%>');updateCheckBox(document.gsheet.grade_percent<%=j%>, document.gsheet.save_<%=j%>);UpdateRemarks('grade_percent<%=j%>','remark<%=j%>');"
	  	  onKeyUp="AllowOnlyFloat('gsheet','grade_percent<%=j%>');" style="font-size:1px;">
	  <%}%>	  </td>
<%}%>      
	<td align="center">
	  	<%if(strFontColor.length() ==0) {
				strTemp = "UpdateRemarks('grade" + j + "','remark" + j +"',document.gsheet.save_"+j+")";
	  	%>
        	  <%if(!bolHideAvgGrade){%>
					<input name="grade<%=j%>" type="text" size="3" class="textbox" <%if(bolIsCGH && !bolRemovePercentGrade){%>readonly='yes'  tabindex="-1"<%}%>
				  onFocus="navRollOver('msg<%=j%>', 'on');style.backgroundColor='#D3EBFF'" onBlur="navRollOver('msg<%=j%>', 'off');style.backgroundColor='white';updateCheckBox(document.gsheet.grade<%=j%>, document.gsheet.save_<%=j%>); <%=strTemp%>"
				  onKeyUp="AllowOnlyFloat('gsheet','grade<%=j%>'); MoveNext(event, document.gsheet.attendance<%=j+1%>,document.gsheet.grade<%=j+1%>);">
			  <%}else{%>
					<input name="grade<%=j%>" type="text" size="3" class="textbox_noborder" <%if(bolIsCGH && !bolRemovePercentGrade){%>readonly='yes'  tabindex="-1"<%}%>
				  onFocus="navRollOver('msg<%=j%>', 'on');style.backgroundColor='#D3EBFF'" onBlur="navRollOver('msg<%=j%>', 'off');style.backgroundColor='white';updateCheckBox(document.gsheet.grade<%=j%>, document.gsheet.save_<%=j%>); <%=strTemp%>"
				  onKeyUp="AllowOnlyFloat('gsheet','grade<%=j%>'); MoveNext(event, document.gsheet.attendance<%=j+1%>,document.gsheet.grade<%=j+1%>);" style="font-size:1px;">
			  <%}%>
        
		
		<%}else {%> &nbsp; <%}%> </td>
 
      <td > <% if (strSchCode.startsWith("AUF") || strSchCode.startsWith("CGH"))
	  		strTemp = "tabindex=\"-1\"";
		else
			strTemp = "";
	 %> <select name="remark<%=j%>" style="font-size:10px" <%=strTemp%> tabindex="-1" onChange="validateGrade(document.gsheet.grade_percent<%=j%>,document.gsheet.grade<%=j%>,document.gsheet.save_<%=j%>,document.gsheet.remark<%=j%>)">
          
		  <%if(bolHideAvgGrade){%>
		  		<%=strBlockedRemark%>
		  <%}else if(bolShowNCRemark){%>
		  		<%=strNCRemark%>
		  <%} else if(strFontColor.length() == 0){%>
          		<%=strAllowedRemark%>
		  		<option value="" selected="selected"></option>
          <%}else{%>
          		<%=strBlockedRemark%>
          <%}%>
        </select> </td>
      <td width="6%" align="center"> <input type="checkbox" name="save_<%=j%>" value="1" tabindex="-1" onClick="validateGrade(document.gsheet.grade_percent<%=j%>,document.gsheet.grade<%=j%>,document.gsheet.save_<%=j%>,document.gsheet.remark<%=j%>)"></td>
    </tr>
    <%}//end of for loop%>
  </table>
<input type="hidden" name="disp_count_gs_pending" value="<%=j%>">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="6%">&nbsp;</td>
      <td width="44%"><%if(!bolIsCIT){%><%=WI.getStrValue(gsExtn.getErrMsg())%><%}%></td>
      <td width="50%" align="right"><%if(bolIsAllowedToEncode && (bolIsCIT || bolIsAllowedToDelete)) {%>
        <a href="javascript:PageAction(1);"><img name="hide_save" src="../../../images/save.gif" border="0"></a>
        <input name="save_text" type="text" tabindex="-1" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 9px; border: 0;" value="Click to Save grades">
<script language="JavaScript">
document.gsheet.show_save.value = "1";
</script>
      <%}%></td>
    </tr>
    <tr>
      <td width="6%">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%}//end of disp of pending grade,
 if(vEncodedGrade != null && vEncodedGrade.size() > 0){%>
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5"><div align="center">LIST OF STUDENTS WITH GRADE
          ENCODED</div></td>
    </tr>
  </table>
<%if(!bolIsCIT) {%>
 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5" align="right">Number of lines per page: 
<%
int iNoOfLines = Integer.parseInt(WI.getStrValue(WI.fillTextValue("first_page"), "0"));
if(iNoOfLines == 0) 
	iNoOfLines = 45;
%>
<select name="first_page">
<%for(int i = 20; i < 60; ++i) {
	if(i == iNoOfLines)	
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>"<%=strTemp%>><%=i%></option>
<%}%>
</select>


<%
if(gsExtn.bolIsGSDelAllowedOthers(dbOP,strSubSecIndex, WI.fillTextValue("grade_for"), strGradeName)) {%>
	  <a href="javascript:PrintPg('0')"><img src="../../../images/print.gif" border="0"></a><font size="1">Click to print grade sheet</font>
<%}else{%>
<%=gsExtn.getErrMsg()%>
<%}%>
	</td>
    </tr>
  </table>
<%}else{
	if(vPendingGrade == null || vPendingGrade.size() == 0) {%>
	 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="45" colspan="5" align="right">Number of lines per page: 
	<%
	int iNoOfLines = Integer.parseInt(WI.getStrValue(WI.fillTextValue("first_page"), "0"));
	if(iNoOfLines == 0) 
		iNoOfLines = 60;
	//System.out.println(iNoOfLines);
	%>
	<select name="first_page">
	<%for(int i = 20; i < 65; ++i) {
		if(i == iNoOfLines)	
			strTemp = " selected";
		else	
			strTemp = "";
	%>
		<option value="<%=i%>"<%=strTemp%>><%=i%></option>
	<%}%>
	</select>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<input type="button" name="_" value="Print FINAL COPY" onClick="PrintPg('1');"style="font-size:11px; height:30px; width:100px; border: 1px solid #FF0000;">
	
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	
	<input type="button" name="_" value="Print DRAFT COPY" onClick="PrintPg('0');"style="font-size:11px; height:30px; width:100px; border: 1px solid #FF0000;">
	
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

		</td>
		</tr>
  </table>
<%}//show only if all subjects have grade.. 
else if(bolFinal) {%>
	 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="45" colspan="5" align="right">
		  <label id="submit_adv_grade" style="font-weight:bold; font-size:11px; color:#0000FF">&nbsp;</label>
			<input type="button" name="_" value="Submit ADVANCE Grade" onClick="SubmitAdanceGrade();"style="font-size:11px; height:30px; width:150px; border: 1px solid #FF0000;">
		</td>
		</tr>
  </table>
	




<%}//show submit partial grade if it is final.



}%>



<% 
System.out.println(vCGHGrade);
boolean bolIsWNU = strSchCode.startsWith("WNU");
//bolIsWNU = strGradeForName.toLowerCase().startsWith("final");
if(bolIsCSA && strGradeForName.toLowerCase().startsWith("final"))
	bolIsWNU = true;

if (!strSchCode.startsWith("CPU")){%>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%"  height="25" ><strong><font size="1">NO.</font></strong></td>
      <td width="11%"  height="25" align="center" ><font size="1"><strong>STUDENT
        ID </strong></font></td>
      <td width="23%" align="center" ><font size="1"><strong>STUDENT NAME
      </strong></font></td>
      <td width="30%" align="center"><font size="1"><strong>COURSE</strong></font></td>
      <td width="4%" align="center"><font size="1"><strong>YEAR</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>CREDIT EARNED</strong></font></td>
<%if(bolIsCGH || bolIsWNU){%>
      <td width="7%" align="center"><font size="1"><strong><%if(bolIsCSA) {%>FINALs<%}else{%>GRADE %ge<%}%></strong></font></td>
<%}%>
      <td width="5%" align="center"><font size="1"><strong><%if(bolIsCSA){%>FINAL <%}%>GRADE<%if(bolIsCGH){%><br>Final Point<%}%></strong></font></td>
      <td width="12%" align="center"><font size="1"><strong>REMARKS</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>SELECT ALL</strong></font>
	  <br> <input type="checkbox" name="selAll" value="0" onClick="checkAll();">&nbsp;</td>
      <td width="6%" align="center"><font size="1"><strong>EDIT</strong></font></td>
    </tr>
<%
	j = 0;
String strFontColor = null;//gsExtn.vCGHGrade.clear();
boolean bolSubStatChanged = false;//set to true and do not allow edit/delete if stat changed to dropped.. 

boolean bolIsForced = false;
for(int i=0; i<vEncodedGrade.size(); i += 9,++j){
	if(vStudListWithDropSub.indexOf(vEncodedGrade.elementAt(i+1)) > -1)
		bolSubStatChanged = true;
	else	
		bolSubStatChanged = false;
		
if( ((String)vEncodedGrade.elementAt(i+8)).toLowerCase().startsWith("f"))
	strFontColor = " color=red";
else
	strFontColor = "";

if(vForcedLocked.indexOf(vEncodedGrade.elementAt(i)) > -1)
	bolIsForced = true;
else	
	bolIsForced = false;

%>
    <tr>
      <td><font size="1"<%=strFontColor%>><%=j + 1%></font></td>
      <td  height="25" ><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+1)%></font>
    <input type="hidden" name="gs_index<%=j%>" value="<%=(String)vEncodedGrade.elementAt(i)%>">	  </td>
      <td ><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+2)%></font></td>
      <td ><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+3)%>
        <% if(vEncodedGrade.elementAt(i + 4) != null){%>
        :: <%=(String)vEncodedGrade.elementAt(i+4)%>
        <%}%>
        </font></td>
      <td align="center"><font size="1"<%=strFontColor%>><%=WI.getStrValue(vEncodedGrade.elementAt(i+5),"N/A")%></font></td>
      <td align="center"><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+6)%></font></td>
<%if(bolIsCGH || bolIsWNU){//System.out.println(gsExtn.vCGHGrade.elementAt(j * 2 + 1));%>
      <td align="center"><font size="1"<%=strFontColor%>>
	  	<%if(gsExtn.vCGHGrade.size() > (j * 2 + 1) ){%><%=WI.getStrValue(gsExtn.vCGHGrade.elementAt(j * 2 + 1), (String)vEncodedGrade.elementAt(i+7))%><%}%>
	  </font>&nbsp;</td>
<%}else if(bolIsCIT){
iIndexOf = gsExtn.vAttendance.indexOf(vEncodedGrade.elementAt(i));
if(iIndexOf > -1) {
	strErrMsg = (String)gsExtn.vAttendance.elementAt(iIndexOf + 2);
}
else	
	strErrMsg = null;%>
      <%}%>
      <td align="center"><font size="1"<%=strFontColor%>><%=WI.getStrValue(vEncodedGrade.elementAt(i+7),"&nbsp;")%></font></td>

<%
	strTemp = (String)vEncodedGrade.elementAt(i+8);

	if (strSchCode.startsWith("AUF") &&
			strTemp.toLowerCase().startsWith("fail")){
		strTemp = "Failed";
	}
%>
      <td align="center"><font size="1"<%=strFontColor%>><%=strTemp%></font></td>
      <td align="center"><%if(!bolSubStatChanged){%><input type="checkbox" name="del_<%=j%>" value="1"><%}%>&nbsp;</td>
      <td align="center">
	  <%if(vUnlockedSingle.indexOf(vEncodedGrade.elementAt(i)) > -1 || (bolIsAllowedToDelete && !bolSubStatChanged && !bolIsForced) ){%>
	  	<input type="button" value="Edit" onClick="delOneGrade(document.gsheet.del_<%=j%>,'<%=(String)vEncodedGrade.elementAt(i)%>')"><!--'<%//=vEncodedGrade.elementAt(i+1)%>','<%//=WI.getStrValue(strErrMsg)%>','<%//=WI.getStrValue(vEncodedGrade.elementAt(i+7))%>',-->
	  <%}else{%> NA<%}%></td>
    </tr>
<%}%>
  </table>
<input type="hidden" name="prev_val_studid">
<input type="hidden" name="prev_val_abs">
<input type="hidden" name="prev_val_grade">

<%}else{ // start of  CPU's Domain %>

  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%"  height="25" ><font size="1" face="Geneva, Arial, Helvetica, sans-serif">NO.</font></td>
      <td width="11%"  height="25" align="center"><font size="1" face="Geneva, Arial, Helvetica, sans-serif">CLASSIFICA-<br>
        TION EX,<br>
      BSE2       </font></td>
      <td width="39%" ><div align="center"><font size="1" face="Geneva, Arial, Helvetica, sans-serif"><strong>NAMES</strong></font></div></td>
      <td width="5%" align="center"><strong><font size="1" face="Geneva, Arial, Helvetica, sans-serif"><strong>GRADE</strong></font></strong></td>
      <td width="6%" align="center"><strong><font size="1" face="Geneva, Arial, Helvetica, sans-serif">CREDIT</font></strong></td>
      <td width="7%" align="center"><font size="1" face="Geneva, Arial, Helvetica, sans-serif">GRADE REMARK</font></td>
      <td width="7%" align="center"><strong><font size="1" face="Geneva, Arial, Helvetica, sans-serif">ATTEN-<br>
DANCE<br>
S-<br>
P-</font></strong></td>
      <td width="15%" align="center"><font size="1" face="Geneva, Arial, Helvetica, sans-serif">FINAL REMARK </font></td>
      <td width="6%" align="center"><font size="1" face="Geneva, Arial, Helvetica, sans-serif"><strong>SELECT ALL</strong></font>
	    <font size="1" face="Geneva, Arial, Helvetica, sans-serif"><br>
	    <input type="checkbox" name="selAll" value="0" onClick="checkAll();">
      </font></td>
    </tr>
<%
	j = 0;
String strFontColor = null;
int intMaxRows = 9; // final..
if (strGradeName.toLowerCase().startsWith("final")){
	intMaxRows = 11;
}


for(int i=0; i<vEncodedGrade.size(); i += intMaxRows,++j){
if( ((String)vEncodedGrade.elementAt(i+8)).toLowerCase().startsWith("f"))
	strFontColor = " color=red";
else
	strFontColor = "";
%>
    <tr>
      <td><font size="1"<%=strFontColor%>><%=j + 1%></font></td>
      <td  height="25" ><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+3)%>
          <% if(vEncodedGrade.elementAt(i + 4) != null){%>
:: <%=(String)vEncodedGrade.elementAt(i+4)%>
<%}%>
      </font><font size="1"<%=strFontColor%>><%=WI.getStrValue(vEncodedGrade.elementAt(i+5))%></font></td>
      <td ><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+2)%></font></td>
      <td align="center"><strong><font size="1"<%=strFontColor%>><%=WI.getStrValue(vEncodedGrade.elementAt(i+7),"&nbsp;")%></font></strong></td>
      <td align="center"><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+6)%></font></td>
      <td align="center"><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+8)%></font></td>
      <td align="center"><font size="1"<%=strFontColor%>>
	  <%if (bolFinal) {%>
		  <%=WI.getStrValue((String)vEncodedGrade.elementAt(i+9),"&nbsp;")%>
	  <%}else{%> &nbsp;<%}%>
	  </font></td>
      <td align="center"><font size="1"<%=strFontColor%>>
	  <% if (bolFinal) {%>
		  <%=WI.getStrValue((String)vEncodedGrade.elementAt(i+10),"&nbsp;")%>
	  <%}else{%> &nbsp;<%}%>
	  </font></td>
      <td align="center"><input type="hidden" name="gs_index<%=j%>" value="<%=(String)vEncodedGrade.elementAt(i)%>"><input type="checkbox" name="del_<%=j%>" value="1"></td>
    </tr>
<%}%>
  </table>


<%}%>

  <input type="hidden" name="disp_count_gs_encoded" value="<%=j%>">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="40%">&nbsp;</td>
      <td width="60%">
        <%
if(gsExtn.isAllowedToEncodeGS(dbOP,strEmployeeID,
								WI.fillTextValue("grade_for"),WI.fillTextValue("sy_from"),
								WI.fillTextValue("sy_to"),WI.fillTextValue("offering_sem")) && gsExtn.bolIsGSDelAllowedOthers(dbOP,strSubSecIndex, WI.fillTextValue("grade_for"), strGradeName)) {%>
        <%if(bolIsSubmitted) {%>
			Grade Sheet already submitted.
		<%}else{%>
		<a href="javascript:PageAction(0);"><img name="hide_delete" src="../../../images/delete.gif" border="0"></a>
        <input name="delete_text" type="text" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 9px; border: 0;"
		value="Click to delete grade">
	<script language="JavaScript">
		document.gsheet.show_delete.value = "1";
	</script>
	<%}//if not submitted.%>
	
<%}else{%>
<%=gsExtn.getErrMsg()%>
<%}%>	  </td>
    </tr>
<%if(bolShowMTerm && !bolIsSubmitted && (vPendingGrade == null || vPendingGrade.size() == 0) ) {%>    
	<tr>
      <td colspan="2" align="center" height="45" valign="bottom">	
	  	<input type="button" name="_" value="<<< Finalize & Submit >>>" onClick="FinalizeGS();"style="font-size:11px; height:30px; width:150px; border: 1px solid #FF0000;">
	  </td>
    </tr>
<%}%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
</table>
<%}//end of showing encoded grade
%>
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
<input type="hidden" name="is_final_copy">

<input type="hidden" name="prev_val_studid">
<input type="hidden" name="prev_val_abs">
<input type="hidden" name="prev_val_grade">
<input type="hidden" name="prev_val_remark">
<input type="hidden" name="del_one">

<script language="javascript">
<%
//I have to add here converting grade from percent to final point.
if(vGradeSystem != null){%>
var vFailedGrade = "";
function ConvertGrade(){
	var bolError = false;
	if(!document.gsheet.convert_grade.checked)
		document.gsheet.convert_grade.checked = true;
		
	var iGradeToEncode = document.gsheet.disp_count_gs_pending.value;
	var gradeEncoded   = ""; var gradeEquivalent = ""; var gradePercent;
	for(i = 0; i < iGradeToEncode; ++i) {
		eval("gradePercent = document.gsheet.grade_percent"+i);
		if(!gradePercent)
			continue;
		gradeEncoded = gradePercent.value;
		if(gradeEncoded.length == 0) {
			eval("document.gsheet.grade"+i+".value=''");
			continue;
		}
		gradeEquivalent = "";
		//I have to now check for if grade is within limit
		<%//double dGrade = 100d;
		for(int i =0; i < vGradeSystem.size(); i += 7){
			//if( ((String)vGradeSystem.elementAt(i + 5)).toLowerCase().startsWith("p"))
				//if(dGrade > Double.parseDouble((String)vGradeSystem.elementAt(i + 2)))
					//dGrade = Double.parseDouble((String)vGradeSystem.elementAt(i + 2));
				%>
			<%if(i > 0){%>else <%}%>if(gradeEncoded >= <%=((String)vGradeSystem.elementAt(i + 2)) %> &&
					gradeEncoded <= <%=(String)vGradeSystem.elementAt(i + 3)%>)
				gradeEquivalent = <%=(String)vGradeSystem.elementAt(i + 1)%>;
		<%}//System.out.println(dGrade);%>
		//if grade equivalent is having final point, change it, else continue;

		if(gradeEquivalent.length == 0) {
			bolError = true;
			continue;
		}
		else
			eval("document.gsheet.grade"+i+".value=gradeEquivalent");
	}
	if(bolError)
		alert("Error in converting grade. Please check all grades encoded.");

}
<%}else{%>
function ConvertGrade(){
	alert("Grade system is not set. Please check link :: Grade System :: and fill up the grade system.");
	return;
}
<%}%>
</script>
<input type="hidden" name="finalize_gs">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
