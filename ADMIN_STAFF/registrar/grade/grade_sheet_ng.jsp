<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	String strSQLQuery = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strGradeForName = WI.fillTextValue("grade_name_");

	DBOperation dbOP  = null;
	String strErrMsg  = null;
	Vector vSecDetail = null;
	int iIndexOf = 0;
	int j = 0;

	     if (strSchCode == null) {%>
					<p style="font-family:Geneva, Arial, Helvetica, sans-serif; font-weight:bold; color:#FF0000;"> 
							 You are already logged out. please login again.
					</p>
	     <% return;
		 }

		try
		{
			dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
									"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet_ng.jsp");
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
		boolean bolIsCGH = false; //for cldh - i must have finals to record in %ge.
		//for fatima : they are allowed to encode in both format.. 
		if(WI.fillTextValue("encode_percent_grade").length() > 0) 
			bolIsCGH = true;

		String strTemp    = null;
		boolean bolIsCSA = strSchCode.startsWith("CSA");	
		boolean bolIsCIT = strSchCode.startsWith("CIT");
		
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
Vector vEncodedGrade = null;
Vector vCGHGrade     = null;

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
	  
	  String strGradeName = null;
	  if(WI.fillTextValue("grade_for").length() > 0) 
		strGradeName = dbOP.mapOneToOther("FA_PMT_SCHEDULE", "PMT_SCH_INDEX", WI.fillTextValue("grade_for"), "EXAM_NAME", null);
		
		boolean bolIsAllowedToEncode = gsExtn.isAllowedToEncodeGS(dbOP,strEmployeeID, 
										WI.fillTextValue("grade_for"),WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),
										WI.fillTextValue("offering_sem"), true);
	//System.out.println("Printing: "+bolIsAllowedToEncode);
	boolean bolFinal = false;
	if (WI.getStrValue(strGradeName).toLowerCase().startsWith("final")) {
			bolFinal = true;
	}

    strTemp = WI.fillTextValue("page_action");
    if(strTemp.length() > 0){  
	    if(gsExtn.updateNGGradeUB(dbOP, request) == null)
			strErrMsg = gsExtn.getErrMsg();
		else {
			  strErrMsg = "Entry Successfully updated.";	
		}
	}
  
//get here necessary information.

	if(strSubSecIndex != null && strSubSecIndex.length() > 0) {//get here subject section detail.
		vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
		if(vSecDetail == null)
			strErrMsg = reportEnrl.getErrMsg();
	}

//Get here the pending grade to be encoded list and list of grades encoded.
	
	if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
		vEncodedGrade = gsExtn.getGradeEncodedNG(dbOP, strSubSecIndex, WI.fillTextValue("grade_for"));
		if(vEncodedGrade == null)
			strErrMsg = gsExtn.getErrMsg();
	}
	

//for CIT, all drop downs are read only.. 
String strIsReadOnly = null;
if(bolIsCIT)
	strIsReadOnly = " disabled";
else	
	strIsReadOnly = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
		//PageAction(0);
	}
}
function PageAction(strAction )
{ 
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value=strAction;
    
	
	//I have to check here, if cgh, faculty must click convert percentage to QP..
	if(strAction == 1) {
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
	}
	if(document.gsheet.show_save.value == "1") {
		document.gsheet.hide_save.src = "../../../images/blank.gif";
		document.gsheet.save_text.value = "Saving in progress....";
		
		//there may be 2 save buttons.
		if(document.gsheet.save_text2) {
			document.gsheet.hide_save2.src = "../../../images/blank.gif";
			if(strAction ==1)
				document.gsheet.save_text2.value = "Saving in progress....";
		}
	}

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
	var maxDisp = document.gsheet.disp_count_gs_pending.value;
	//unselect if it is unchecked.
	var bolCheck = document.gsheet.selAll.checked;
	
	var objChk;
	for(var i =0; i< maxDisp; ++i) {
		eval('objChk=document.gsheet.save_'+i);
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

function UpdateRemarks(strGrade,strRemark, objChkBox){
	var vGrade = "";
	eval("vGrade = document.gsheet."+strGrade+".value");

	if(vGrade.length == 0)
	return;
	
	//1 = 3 to 5 fail, else pass., 
	var iGradeSystem = 0;// 0 meaning 0 to 100
	
	//if fatima grade system is 1, but if encode in %ge grade, then it is in %ge.
	var bolInvalidGrade = false;
		
	<%if(strSchCode.startsWith("FATIMA") && !bolIsCGH) {%>
		iGradeSystem = 1;//Final Point.
		if(eval(vGrade) == 1 || eval(vGrade) == 1.25 || eval(vGrade) == 1.5 || eval(vGrade) == 1.75 || 
			eval(vGrade) == 2 || eval(vGrade) == 2.25 || eval(vGrade) == 2.5 || eval(vGrade) == 2.75 ||
			eval(vGrade) == 3 || eval(vGrade) == 5)
			bolInvalidGrade = false;
		else {	
			alert("Invalid Grade.");
			eval("document.gsheet."+strGrade+".value=''");
			eval("document.gsheet."+strGrade+".focus()");
			//alert("Invalid Grade. - focused...");
			objChkBox.checked = false;
		}
	<%}%>
	<%if(strSchCode.startsWith("EAC") && !bolIsCGH) {%>
		iGradeSystem = 0;
	<%}else if(GS.bolIsGradeSystemExtn && strSchCode.startsWith("WUP")){%>
		iGradeSystem = 5;
	<%}else if(strSchCode.startsWith("DBTC")){%>
		iGradeSystem = 1;
	<%}else if (strSchCode.startsWith("PIT")) {%>
		iGradeSystem = 2;
	<%}else if (strSchCode.startsWith("UB")) {%>
		iGradeSystem = 6;
	<%}else if (strSchCode.startsWith("PWC")) {%>
		iGradeSystem = 7;
	<%}else if (strSchCode.startsWith("CIT")) {//1, 2 to 2.9 = fail, 3 to 5 pass, other not allowed.
		if(bolFinal){%>
			iGradeSystem = 4;
		<%}else{%>
			iGradeSystem = 3;
		<%}%>
	<%}%>

	<%if(bolIsCSA) {%>
		if ( eval(vGrade) <1 || eval(vGrade) > 100){
			alert ("Invalid grade. Grade must be within 1-100");
			eval("document.gsheet."+strGrade+".focus()");
			eval("document.gsheet."+strGrade+".select()");
			return;
		}
	<%}%>
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
	else if(iGradeSystem == 1) {//for DBTC.. 
		if ( eval(vGrade) > 3){//failed..
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else {
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
		}
	}
	else if(iGradeSystem == 2) {//for PIT.. 
		if ( eval(vGrade) > 4.49){//failed..
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else if ( eval(vGrade) > 3.49){//failed..
			if (iConditioanlSelectedIndex == -1)
				iConditioanlSelectedIndex = GetConditionalSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iConditioanlSelectedIndex);
		}
		else {
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
		}
	}
	else if(iGradeSystem == 3 || iGradeSystem == 4) {//for CIT.. 
		//for 4, only 1, and 3 to 5 allowed.
		if(iGradeSystem == 4) {
			if(eval(vGrade) > 1 && eval(vGrade) <3) {
				alert("Invalid Grade. Please enter grade 1 or 3-5");
				eval("document.gsheet."+strGrade+".value=''");
				eval("document.gsheet."+strGrade+".focus()");
				//alert("Invalid Grade. - focused...");
				objChkBox.checked = false;
				//document.gsheet.grade0.focus();
				return;
			}
		}
		if(vGrade.length > 3 || eval(vGrade) < 1 || eval(vGrade) > 5) {
			alert("Invalid Grade.");
			eval("document.gsheet."+strGrade+".value=''");
			eval("document.gsheet."+strGrade+".focus()");
			//alert("Invalid Grade. - focused...");
			objChkBox.checked = false;
			//document.gsheet.grade0.focus();
			return;
		}
		if ( eval(vGrade) < 3){//failed..
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}		
		else {
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
	else if(iGradeSystem == 6) {
		if(eval(vGrade) < 1 || eval(vGrade) > 5) {
			alert("Invalid Grade.");
			eval("document.gsheet."+strGrade+".value=''");
			eval("document.gsheet."+strGrade+".focus()");
			//alert("Invalid Grade. - focused...");
			objChkBox.checked = false;
			//document.gsheet.grade0.focus();
			return;
		}
	
	
		if ( eval(vGrade) >3){
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else{
			if (iPassedSelectedIndex == -1)
				iPassedSelectedIndex = GetPassedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iPassedSelectedIndex);
		}
	}
	else if(iGradeSystem == 7) {
		if ( eval(vGrade) >4){
			if (iFailedSelectedIndex == -1)
				iFailedSelectedIndex = GetFailedSelectedIndex(strRemark);
			eval("document.gsheet."+strRemark+".selectedIndex=" + iFailedSelectedIndex);
		}
		else{
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


//for CIT, they can give NG only if mterm grade is >= 2.9
function checkNGRemark() {

}


function validateGrade(objPercent, objGrade, objChkBox, objRemark) {
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
</script>


<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<form name="gsheet" action="./grade_sheet_ng.jsp" method="post">
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
          NG GRADE SHEETS PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;<strong><font size="3" color="#FF0000">
	  <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
    </tr>
<%      strTemp = null;
		if(strEmployeeIndex != null)
			strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strEmployeeIndex, 9);
		else	
			strTemp = null;
		if(strTemp != null){
%>
    <tr>
      <td height="25" colspan="7">
		  <table width="100%" cellpadding="0" cellspacing="0">
			<tr>
			  <td width="2%" height="25">&nbsp;</td>
			  <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL">
			  <%=strTemp%></td>
			  <td width="2%">&nbsp;</td>
			</tr>
		  </table>
	  </td>
    </tr>
<%} // end of strTemp != null %>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp; 
<%if(!bolEncodingForOther) {%>
	  <strong><font color="blue">NOTE: Subject/Sections appear are the sections handled by the logged in faculty Employee ID: 
	  <%=strEmployeeID%></font></strong>
<%}else{%>	  
		<strong><font color="red" size="4">NOTE: You are now encoding for Faculty: <%=strEmployeeID%></font></strong>
<%}%>	  
	  </td>
    </tr>
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
<% if(strSchCode.startsWith("CIT"))
	  strTemp = " and (exam_name like 'm%' or exam_name like 'f%') ";
   else	
	  strTemp = "";
%>
       <select name="grade_for" <%=strIsReadOnly%>>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and (is_valid=1 or is_valid = 0) and BSC_GRADING_NAME is not null "+strTemp+" order by EXAM_PERIOD_ORDER asc", request.getParameter("grade_for"), false)%>
        </select></td>
      <td valign="bottom" >
	  <select name="offering_sem" onChange="ReloadPage();" <%=strIsReadOnly%>>
          <option value="1">1st Sem</option>
<% strTemp = WI.fillTextValue("offering_sem");
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
      <td valign="bottom" >
<%  strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("gsheet","sy_from","sy_to")' <%=strIsReadOnly%>>
        -
<%  strTemp = WI.fillTextValue("sy_to");
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
      <td width="8%" ></td>
    </tr>
</table>
<%  if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() >0){
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
<%      strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  where "+
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
<%      strTemp = " from faculty_load join e_sub_section on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) "+
			"join subject on (e_sub_section.sub_index = subject.sub_index) where faculty_load.user_index = "+
			strEmployeeIndex+" and e_sub_section.section = '"+WI.fillTextValue("section_name")+
			"' and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
			WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
			" and e_sub_section.offering_sem="+WI.fillTextValue("offering_sem");
%>
        <select name="subject" onChange="ReloadPage();" <%=strIsReadOnly%>>
          <option value="">Select a subject</option>
          <%=dbOP.loadCombo("distinct subject.sub_index","sub_code",strTemp, request.getParameter("subject"), false)%>
        </select></td>
      <td> <strong>
<%  if(WI.fillTextValue("subject").length() > 0) {
	   strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%>
        <%=WI.getStrValue(strTemp)%></strong></td>
<%  }%>
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
      <td height="25" > 
<%     strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  " +
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
        <%
		
		if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%>
        <%}%>
        </strong> </td>
    </tr>
  </table>


<%}//end of if else CPU's Header
} // WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() >0
if(vSecDetail != null){%>
  <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
    <tr>
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION
	  </strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE
	  </strong></font></div></td>
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
<%} if(vEncodedGrade != null && vEncodedGrade.size() > 0){%>
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5"><div align="center">LIST OF STUDENTS WITH NG GRADE</div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" bgcolor="#FFCC66">
      <td width="3%"  height="25" class="thinborder"><strong><font size="1">NO.</font></strong></td>
      <td width="12%" class="thinborder"><font size="1"><strong>STUDENT ID </strong></font></td>
      <td width="25%" class="thinborder"><font size="1"><strong>STUDENT NAME</strong></font></td>
      <td width="15%" class="thinborder"><font size="1"><strong>COURSE</strong></font></td>
      <td width="5%" class="thinborder"><font size="1"><strong>YEAR</strong></font></td>
      <td width="10%" class="thinborder"><font size="1"><strong>GRADE</strong></font></td>
      <td width="10%" class="thinborder"><strong><font size="1">NEW GRADE </font></strong></td>
      <td width="15%" class="thinborder"><font size="1"><strong>NEW REMARK </strong></font></td>
      <td width="5%" class="thinborder"><font size="1"><strong>SELECT</strong></font>
	  <br> <input type="checkbox" name="selAll" value="0" onClick="checkAll();">&nbsp;</td>
    </tr>
<%  j = 0;      	  

	for(int i=0; i<vEncodedGrade.size(); i += 9,++j){%>
    <tr class="nav" id="msg<%=j%>" onMouseOver="navRollOver('msg<%=j%>', 'on')" onMouseOut="navRollOver('msg<%=j%>', 'off')">
      <td class="thinborder"><font size="1"><%=j + 1%></font></td>
      <td  height="25" class="thinborder"><font size="1"><%=(String)vEncodedGrade.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vEncodedGrade.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vEncodedGrade.elementAt(i+3)%><%=WI.getStrValue((String)vEncodedGrade.elementAt(i+4), "::","","")%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=WI.getStrValue(vEncodedGrade.elementAt(i+5),"N/A")%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=WI.getStrValue((String)vEncodedGrade.elementAt(i+8))%></font></td>
      <td align="center" class="thinborder">
      <input name="grade<%=j%>" type="text" size="3" class="textbox" onFocus="navRollOver('msg<%=j%>', 'on');style.backgroundColor='#D3EBFF'" 
      onBlur="navRollOver('msg<%=j%>', 'off');style.backgroundColor='white';updateCheckBox(document.gsheet.grade<%=j%>,document.gsheet.save_<%=j%>);UpdateRemarks('grade<%=j%>','remark<%=j%>',document.gsheet.save_<%=j%>)" 
	  onKeyUp="AllowOnlyFloat('gsheet','grade<%=j%>'); MoveNext(event, document.gsheet.attendance<%=j+1%>,document.gsheet.grade<%=j+1%>);">
      </td>
      <td align="center" class="thinborder">
<%   
String strAllowedRemark = dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0 and is_internal = 1 and remark <> 'no permit' and remark not like 'ng-%'",null , false,false);
%>      
       <select name="remark<%=j%>" style="font-size:10px" tabindex="-1" 
	   onChange="validateGrade(document.gsheet.grade_percent<%=j%>,document.gsheet.grade<%=j%>,document.gsheet.save_<%=j%>,document.gsheet.remark<%=j%>)">
          		<%=strAllowedRemark%>
        </select></td>
      <td align="center" class="thinborder">
	  <input type="checkbox" name="save_<%=j%>" value="<%=(String)vEncodedGrade.elementAt(i)%>"
        onClick="validateGrade(document.gsheet.grade_percent<%=j%>,document.gsheet.grade<%=j%>,document.gsheet.save_<%=j%>,document.gsheet.remark<%=j%>)" tabindex="-1">&nbsp;</td>
    </tr>
	 <input type="hidden" name="cur_index_ui_<%=j%>" value="<%=(String)vEncodedGrade.elementAt(i + 6)%>">
	 <input type="hidden" name="stuid_i<%=j%>" value="<%=(String)vEncodedGrade.elementAt(i + 1)%>">
	 
<%} // end of vEncodedGrade loop %>
  </table>
<input type="hidden" name="disp_count_gs_pending" value="<%=j%>">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="40%">&nbsp;</td>
      <td width="60%">
<%if(bolIsAllowedToEncode) {%>
        <a href="javascript:PageAction(1);"><img name="hide_save" src="../../../images/update.gif" border="0"></a>
        <input name="save_text" type="text" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 9px; border: 0;"
		value="Click to update grade">
	<script language="JavaScript">
	document.gsheet.show_save.value = "1";
	</script>
<%}else{%>
	<br>
	<font size="3" color="#FF0000">Last Date to encode NG Grade has expired</font>
<%}%>
   </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
</table>
<%}//end of showing encoded grade%>
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
Vector vGradeSystem = GS.viewAllGrade(dbOP, request);
if(vGradeSystem != null){%>
var vFailedGrade = "";
function ConvertGrade(){
	var bolError = false;
	if(!document.gsheet.convert_grade.checked)
		return;
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
			<%if(i > 0){%>else <%}%>if(gradeEncoded >= <%=(String)vGradeSystem.elementAt(i + 2)%> &&
					gradeEncoded <= <%=(String)vGradeSystem.elementAt(i + 3)%>)
				gradeEquivalent = <%=(String)vGradeSystem.elementAt(i + 1)%>;
		<%}%>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
