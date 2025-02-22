<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,enrollment.EnrlAddDropSubject,java.util.Vector,java.util.Date" buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

//forward the page here.
if(WI.fillTextValue("show_all").compareTo("1") ==0){
	response.sendRedirect("./student_ledger_viewall.jsp?show_coursecode=1&stud_id="+WI.fillTextValue("id_in_url"));
	return;
}

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term","",""};

	boolean bolProceed = true;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Student ledger","student_ledger.jsp");
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
														"Fee Assessment & Payments","STUDENT LEDGER",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	//if called from guidance.
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
														null);
	if(iAccessLevel > 1) 
		iAccessLevel = 1;
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


Vector vBasicInfo = null;
Vector vLedgerInfo = null;

Vector vTimeSch = null;
Vector vAdjustment = null;
Vector vRefund = null;
Vector vDorm = null;
Vector vOthSchFine = null;
Vector vPayment = null;

Vector vAddedSub     = null;
Vector vDroppedSub   = null;
Vector vDissolvedSub = null;

Vector vTuitionFeeDetail = null;

String strUserIndex = null;

boolean bolHideTuition = false;
boolean bolHideNonTuition = false;
if(WI.fillTextValue("show_tuition_").equals("0"))
	bolHideNonTuition = true;
if(WI.fillTextValue("show_tuition_").equals("2"))
	bolHideTuition = true;


FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAStudentLedger faStudLedg = new FAStudentLedger();
EnrlAddDropSubject eADS = new EnrlAddDropSubject();

String strPNRemarks   = null;
String strSQLQuery    = null;
java.sql.ResultSet rs = null;

    Vector vNotEnrolled = new Vector();
    Vector vEnrolled    = new Vector();

String strStudID = WI.fillTextValue("stud_id");

if(strStudID.length() > 0)
{
	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, strStudID,
					request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));
	//check if rfid is scanned.. 
	if(dbOP.strBarcodeID != null)
		strStudID = dbOP.strBarcodeID;
	
	if(vBasicInfo == null)
		vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, strStudID);
	if(vBasicInfo == null) { //may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
		//check if student is basic.
		paymentUtil.setIsBasic(true);
		vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, strStudID,
			request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));
		if(vBasicInfo != null && vBasicInfo.size() > 0) {
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./basic/student_ledger.jsp?stud_id="+strStudID+"&sy_from="+
									request.getParameter("sy_from")+"&sy_to="+request.getParameter("sy_to")+"&semester="+request.getParameter("semester")));
			return;
		}
	}
	else//check if this student is called for old ledger information.
	{
		strUserIndex = (String)vBasicInfo.elementAt(0);
		int iDisplayType = faStudLedg.isOldLedgerInformation(dbOP, strUserIndex,request.getParameter("sy_from"),
											request.getParameter("sy_to"),request.getParameter("semester"));
		if(iDisplayType ==-1) //Error.
		{
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=faStudLedg.getErrMsg()%></font></p>
			<%
			dbOP.cleanUP();
			return;
		}
		if(iDisplayType ==1)//this is called for old ledger information.
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./old_student_ledger_view.jsp?stud_id="+strStudID+"&sy_from="+
				request.getParameter("sy_from")+"&sy_to="+request.getParameter("sy_to")+"&semester="+request.getParameter("semester")));
			return;
		}
	}
	//check if the applicant is having reservation already, if so - take directly to the print page,
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{//long lTime = new java.util.Date().getTime();
	
		/**
		I have to start a thread here.. 
		**/
		//I have to check if subejct fee already set.. 
		final String strSYFrom1 = request.getParameter("sy_from");
		final String strSemester1 = request.getParameter("semester");
		final String strUserIndex1 = (String)vBasicInfo.elementAt(0);
		final CommonUtil con = new CommonUtil();
		
		strSQLQuery = "select enroll_index from enrl_final_cur_list where sy_from = "+request.getParameter("sy_from")+
					" and current_semester = "+request.getParameter("semester")+" and user_index = "+(String)vBasicInfo.elementAt(0)+
					" and tot_subj_fee is null";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);//System.out.println("I am here 1");
		if(strSQLQuery != null) {
			new Thread() {
				public void run() {
					try {
					//System.out.println("I am here 2");
						EnrlReport.FeeExtraction fE = new EnrlReport.FeeExtraction();
						utility.DBOperation dbOPx   = new utility.DBOperation();
						fE.initPerSubjectFeePerStudent(dbOPx, strSYFrom1, strSemester1, strUserIndex1, false);
						dbOPx.cleanUP();//System.out.println("I am here 3");
						con.getName(null, null, 0);
					}
					catch (Exception e) {e.printStackTrace();}
				}
			}.start();
		}
		//System.out.println("I am here 4");
		boolean bolShowOnlyDroppedSub = false;
		if(WI.fillTextValue("show_dropped_only").length() > 0)
			bolShowOnlyDroppedSub = true;
		vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vBasicInfo.elementAt(0),request.getParameter("sy_from"),
			request.getParameter("sy_to"),null,request.getParameter("semester"), bolShowOnlyDroppedSub);
		if(vLedgerInfo == null)
			strErrMsg = faStudLedg.getErrMsg();
		else
		{//System.out.println( (new java.util.Date().getTime() - lTime)/1000);
			vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
			vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
			vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
			vRefund				= (Vector)vLedgerInfo.elementAt(3);
			vDorm 				= (Vector)vLedgerInfo.elementAt(4);
			vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);//System.out.println(vOthSchFine);
			vPayment			= (Vector)vLedgerInfo.elementAt(6);
			if(vTimeSch == null || vTimeSch.size() ==0)
				strErrMsg = faStudLedg.getErrMsg();
			else {
				////get PN Remarks.
				strSQLQuery = "select pn_remarks from FA_STUD_PROMISORY_NOTE where IS_TEMP_STUD_ = 0 and is_valid = 1 and pmt_sch_index = 0 and sy_from = "+
							request.getParameter("sy_from")+" and semester = "+request.getParameter("semester")+" and user_index = "+(String)vBasicInfo.elementAt(0);
				strPNRemarks = dbOP.getResultOfAQuery(strSQLQuery, 0);
			}
			
		}
		if(bolHideTuition) {
			vTuitionFeeDetail = new Vector();
			vTuitionFeeDetail.addElement(new Double(0));
			
			vAdjustment = new Vector();
			
			if(vPayment != null && vPayment.size() > 0) {
				for(int i = 0; i < vPayment.size(); i += 6) {
					strTemp = (String)vPayment.elementAt(i + 3);
					if(strTemp.indexOf("Enrollment/downpayment") > -1 || strTemp.indexOf("Tuition") > -1) {
						vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);
						i = i-6;
					}
				}
			}
		}
		if(bolHideNonTuition) {
			vOthSchFine = new Vector();
			
			if(vPayment != null && vPayment.size() > 0) {
				for(int i = 0; i < vPayment.size(); i += 6) {
					strTemp = (String)vPayment.elementAt(i + 3);
					if(strTemp.indexOf("Enrollment/downpayment") == -1 && strTemp.indexOf("Tuition") == -1) {
						vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);vPayment.remove(i);
						i = i-6;
					}
				}
			}
			
		}


	}
}//System.out.println(vPayment);
//System.out.println("I am here 5");
//[0] enroll_index, [1] sub_fee [2] lab fee [3] total 
Vector vAddDropSubFeeDtls = new Vector();

if (strErrMsg == null && !bolHideTuition){
//	getStudBasicInfoOLD ->  (stud_Index = 0 , course_type = 10)
	if (vBasicInfo != null && vBasicInfo.size() > 0){
		vAddedSub = eADS.getAddedDroppedList(dbOP, (String)vBasicInfo.elementAt(0),  (String)vBasicInfo.elementAt(10),
											 request.getParameter("sy_from"),request.getParameter("sy_to"),
											 request.getParameter("semester"), true);
		vDroppedSub = eADS.getAddedDroppedList(dbOP, (String)vBasicInfo.elementAt(0),  (String)vBasicInfo.elementAt(10),
											 request.getParameter("sy_from"),request.getParameter("sy_to"),
											 request.getParameter("semester"), false);
		if( (vAddedSub != null && vAddedSub.size() > 0) || (vDroppedSub != null && vDroppedSub.size() > 0) ){
			strSQLQuery = "select enroll_index, tot_subj_fee, handson_fee, lab_fee from enrl_final_cur_list where sy_from = "+request.getParameter("sy_from")+
							" and current_semester = "+request.getParameter("semester")+" and is_temp_stud = 0 and user_index = "+(String)vBasicInfo.elementAt(0);
			rs = dbOP.executeQuery(strSQLQuery);
			while(rs.next()) {
				vAddDropSubFeeDtls.addElement(rs.getString(1));//[0] enroll_index
				vAddDropSubFeeDtls.addElement(CommonUtil.formatFloat(rs.getDouble(2), true));//[1] tot_subj_fee
				vAddDropSubFeeDtls.addElement(CommonUtil.formatFloat(rs.getDouble(3) + rs.getDouble(4), true));//[2] lab fee
				vAddDropSubFeeDtls.addElement(CommonUtil.formatFloat(rs.getDouble(2) + rs.getDouble(3) + rs.getDouble(4), true));//[3] total tuition
			}
			rs.close();
			
		}
		
		
		//get Dissolved subject..
		//vDissolvedSub = eADS.getDissolvedSubjectList(dbOP, (String)vBasicInfo.elementAt(0),  (String)vBasicInfo.elementAt(10),
		//									 request.getParameter("sy_from"),request.getParameter("sy_to"),
		//									 request.getParameter("semester"));
}	}
//System.out.println(vDroppedSub);

//get sy/term Information 
if(vBasicInfo != null && vBasicInfo.size() > 0 && vBasicInfo.elementAt(0) != null) {
	Vector vOldSYTerm   = faStudLedg.getSYTermWithLedger(dbOP, (String)vBasicInfo.elementAt(0));
	if(vOldSYTerm != null) {
		vNotEnrolled = (Vector)vOldSYTerm.remove(0);
		vEnrolled    = (Vector)vOldSYTerm.remove(0);
	}
}
//System.out.println(vNotEnrolled);
//System.out.println(vEnrolled);


if(strErrMsg == null) strErrMsg = "";
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
	
boolean bolSplitOR = false;
if(strSchCode.startsWith("DLSHSI"))
	bolSplitOR = true;
	
String strAddress = null;
String strAge = null;

if(strSchCode.startsWith("UB") && vBasicInfo != null && vBasicInfo.size() > 0){
	strSQLQuery = "select res_house_no, res_city, res_provience, res_zip, res_tel from info_contact "+
			"where user_index = "+(String)vBasicInfo.elementAt(0);
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strAddress = rs.getString(1);
		if(strAddress != null) {
			if(rs.getString(2) != null) 
				strAddress = strAddress + ", "+rs.getString(2);
			if(rs.getString(3) != null) 
				strAddress = strAddress + ", "+rs.getString(3);
			if(rs.getString(4) != null) 
				strAddress = strAddress + " - "+rs.getString(4);
			if(rs.getString(5) != null) 
				strAddress = strAddress + " <br> Tel: "+rs.getString(5);
		}
	}
 	rs.close();
	
	strSQLQuery = "select dob from info_personal where user_index = "+(String)vBasicInfo.elementAt(0);
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next() && rs.getDate(1) != null)
		strAge = Integer.toString(CommonUtil.calculateAGE(rs.getDate(1)));
	rs.close();
}	

boolean bolShowDiscDetail = true;
if(strSchCode.startsWith("PWC"))
	bolShowDiscDetail = false;


String strBatchNumber = null;///used for SWU.. 
if(strSchCode.startsWith("SWU") && vBasicInfo != null && vBasicInfo.size() > 0) {
	strBatchNumber = "select section_name from stud_curriculum_hist where user_index = "+(String)vBasicInfo.elementAt(0)+" and section_name is not null and sy_from = "+request.getParameter("sy_from");
	strBatchNumber = dbOP.getResultOfAQuery(strBatchNumber, 0) ;
}
if(strBatchNumber != null) {
	astrConvertTerm[1] = "1st Term";
	astrConvertTerm[2] = "2nd Term";
	astrConvertTerm[3] = "3rd Term";
	astrConvertTerm[4] = "4th Term";
	astrConvertTerm[5] = "5th Term";
}


//i have to check if student is locked.
String strLockedByInfo = null;//for CIT only..
if(strSchCode.startsWith("CIT") && vBasicInfo != null && vBasicInfo.size() > 0) {
	enrollment.SetParameter sParam = new enrollment.SetParameter();

	if(sParam.isStudLockedByDept(dbOP, (String)vBasicInfo.elementAt(0), null, null)) {
		strLockedByInfo = sParam.getErrMsg();
		int iIndexOf = strLockedByInfo.indexOf("<br>");
		strLockedByInfo = strLockedByInfo.substring(iIndexOf + 5);
		strLockedByInfo = strLockedByInfo.replaceAll("Department:", "");
	}
	if(!sParam.allowAdvising(dbOP, (String)vBasicInfo.elementAt(0), 0d, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"))) {
		if(strLockedByInfo == null)
			strLockedByInfo = "Blocked by System Admin/ETO";
		else	
			strLockedByInfo = "Blocked by System Admin/ETO AND<br> "+strLockedByInfo;
	}
	else if(strLockedByInfo != null) 
		strLockedByInfo = "Blocked by: <br>"+strLockedByInfo;

}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">

<style type="text/css">
  /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:7;
	top:0;
    width:285px;
	height:200;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }
  div.showPayment{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    left:7;
	top:0;
    width:400px;
	height:200;/** it expands on its own.. **/
	overflow:auto;
	visibility:hidden
  }

</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var pgLoc = "./student_ledger_print.jsp?stud_id="+escape(document.stud_ledg.stud_id.value)+"&sy_from="+
			document.stud_ledg.sy_from.value+"&sy_to="+document.stud_ledg.sy_to.value+"&semester="+
			document.stud_ledg.semester[document.stud_ledg.semester.selectedIndex].value;
		if(document.stud_ledg.inc_adddrop && document.stud_ledg.inc_adddrop.checked) 
			pgLoc += "&inc_adddrop=1";
		
		var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function FocusID() {
	document.stud_ledg.stud_id.focus();
}
function ReloadPage() {
	document.stud_ledg.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=stud_ledg.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function studIDInURL() {
	var studID = document.stud_ledg.stud_id.value;
	if(studID.length > 0)
		document.stud_ledg.id_in_url.value = escape(studID);
	else	
		document.stud_ledg.id_in_url.value = "";
	ReloadPage();
}
function ViewAUFLedger() {
	var iStartLine = prompt('Please enter staring line number. If line number is > 0, it is considered Ledger is already having date of one sem before.','0');
	if(iStartLine == null || iStartLine == '0')
		iStartLine = '';
	else	
		iStartLine = "&start_line="+iStartLine;
		
	location = "./auf_ledger_formatted.jsp?stud_id="+document.stud_ledg.stud_id.value+
		"&sy_from="+document.stud_ledg.sy_from.value+
		"&sy_to="+document.stud_ledg.sy_to.value+
		"&semester="+document.stud_ledg.semester[document.stud_ledg.semester.selectedIndex].value+
		iStartLine;
}
function GoToBasic() {
	location = "./basic/student_ledger.jsp";
}
/*** this ajax is called to record semestral remarks **/
function ajaxUpdateRemark() {
	//if there is no change, just return here..
	var strRemark = document.stud_ledg.sem_remark.value;
	var strParam = "stud_ref="+document.stud_ledg.user_index.value+"&sy_from="+document.stud_ledg.sy_from.value+
					"&semester="+document.stud_ledg.semester.value+"&sem_remark="+escape(strRemark);
	var objCOAInput = document.getElementById("coa_info_remark");
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=116&"+strParam;
	this.processRequest(strURL);
}


//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.stud_ledg.stud_id.value;
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
	document.stud_ledg.stud_id.value = strID;
	document.stud_ledg.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.stud_ledg.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}


function UpdateSYTerm(strSYFrom, strSYTo, strTerm) {
	document.stud_ledg.sy_from.value = strSYFrom;
	document.stud_ledg.sy_to.value = strSYTo;
	//if(strTerm == '0')
	//	strTerm = '4';
	//strTerm = eval(strTerm) - 1;
	document.stud_ledg.semester.selectedIndex = strTerm;
	
	document.all.processing.style.visibility='hidden';
	document.all.processing2.style.visibility='visible';
	document.stud_ledg.submit();
}
function HideLayer(strDiv) {
	if(strDiv == '1')
		document.all.processing.style.visibility='hidden';	
	else if(strDiv == '2')
		document.all.showPayment.style.visibility='hidden';	
	
}
function ShowTuition(iShowType) {
	if(iShowType == 1) {
		var pgLoc = "./show_all_payment.jsp?stud_id="+escape(document.stud_ledg.stud_id.value);
		var win=window.open(pgLoc,"PrintWindow",'width=1000,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
		return;
	}
	document.stud_ledg.show_tuition_.value=iShowType;
	document.stud_ledg.submit();
}

function ViewAssessment(strPgForward) {
	var strStudID = document.stud_ledg.stud_id.value;
	if(strStudID.length == 0) {
		alert("Please enter student ID.");
		return;
	}
	pgLoc="?is_confirmed=1&stud_id="+document.stud_ledg.stud_id.value+"&sy_from="+document.stud_ledg.sy_from.value+"&sy_to="+document.stud_ledg.sy_to.value+"&semester="+
		document.stud_ledg.semester[document.stud_ledg.semester.selectedIndex].value;
	pgLoc = "../payment/re_print_assessment.jsp"+pgLoc;
	if(strPgForward != '')
		pgLoc += "&prevent_forward=1";
	
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ChargeSlip() {
	var strStudID = document.stud_ledg.stud_id.value;
	if(strStudID.length == 0) {
		alert("Please enter student ID.");
		return;
	}
	pgLoc="?stud_id="+document.stud_ledg.stud_id.value+"&sy_from="+document.stud_ledg.sy_from.value+"&sy_to="+document.stud_ledg.sy_to.value+"&semester="+
		document.stud_ledg.semester[document.stud_ledg.semester.selectedIndex].value;
	pgLoc = "../reports/charge_slip_UB.jsp"+pgLoc;
	
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function StatementOfAccount() {
	var strStudID = document.stud_ledg.stud_id.value;
	if(strStudID.length == 0) {
		alert("Please enter student ID.");
		return;
	}
	pgLoc="?stud_id="+document.stud_ledg.stud_id.value+"&sy_from="+document.stud_ledg.sy_from.value+"&sy_to="+document.stud_ledg.sy_to.value+"&semester="+
		document.stud_ledg.semester[document.stud_ledg.semester.selectedIndex].value;
	pgLoc = "../reports/statement_of_account_print.jsp"+pgLoc;
	
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function GoToInstallmentPmt() {
	var strLoc = "../payment/install_assessed_fees_payment.jsp";
	if(document.stud_ledg.stud_id.value.length > 0) 
		strLoc += "?stud_id="+document.stud_ledg.stud_id.value;
	location = strLoc;
	
}
function GoToBatchPrintLedger() {
	location = "./student_ledger_batch.jsp";
}
function PrintPermit() {
	var loadPg = "../../../ADMIN_STAFF/fee_assess_pay/reports/admission_slip_main.jsp?sy_from="+document.stud_ledg.sy_from.value+
	"&sy_to="+document.stud_ledg.sy_to.value+"&semester="+
	document.stud_ledg.semester.value+"&stud_id="+document.stud_ledg.stud_id.value+
	"&pmt_schedule=1&print_pg=1&called_ledger=1&print_by=1";
	
	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<form name="stud_ledg" action="./student_ledger.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF"><strong>::::
          STUDENT'S LEDGER PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp; <%=strErrMsg%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 7);
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
      <td height="25">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%" height="25">SY-TERM</td>
      <td height="25" colspan="4"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("stud_ledg","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester">
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> <input type="checkbox" name="show_all" value="1" onClick="studIDInURL();">
        <font size="1">SHOW LEDGER from start </font>
<%if(strSchCode.startsWith("SPC")){%>
		<input type="button" value="Go to Installment Payment" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="GoToInstallmentPmt();">
<%}%>
<%if(strSchCode.startsWith("VMA")){%>
		<input type="button" value="Go to Batch Print Ledger" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="GoToBatchPrintLedger();">
<%}%>

	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student ID &nbsp;</td>
      <td width="15%" height="25"><input name="stud_id" type="text" size="16" value="<%=strStudID%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="3%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="65%">
	  <input type="Submit" value="Show Ledger" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.stud_ledg.show_tuition_.value=''"> &nbsp;

	  <!--<input type="image" src="../../../images/form_proceed.gif">-->
<%if(strSchCode.startsWith("AUF") || strSchCode.startsWith("UI") || strSchCode.startsWith("VMUF") || 
strSchCode.startsWith("WNU") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("PHILCST")
 || strSchCode.startsWith("UL") || strSchCode.startsWith("CSA")){%>
	<input type="checkbox" onClick="GoToBasic();">
	<font style="font-size:9px; font-weight:bold; color:#0000FF">Go to Grade school Ledger.</font>
    <%}%>	  
	  </td>
      <td width="2%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
  <tr>
    <td></td>
    <td>
		<table width="50%"><tr><td>
			<label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>
		</td></tr></table>
	</td>
  </tr>
<%if(false){%>
  <tr>
  	<td width="2%"></td>
  	  <td width="98%" height="25"> SHOW DROPPED SUBJECT FEE DETAIL ONLY
<%
strTemp = WI.fillTextValue("show_dropped_only");
if(strTemp.compareTo("1") == 0)
	strTemp = "Checked";
else
	strTemp = "";
%>
        <input type="checkbox" name="show_dropped_only" value="1" onClick="ReloadPage();" <%=strTemp%>>
        [YES] 
		
	  </td>
  </tr>
<%}if(strUserIndex != null){%>
  <tr>
    <td></td>
    <td height="25">
	<%if(strSchCode.startsWith("AUF")){%>
		&nbsp; View Ledger in AUF Format <a href="javascript:ViewAUFLedger();"> <img src="../../../images/view.gif" border="0"></a>
	<%}%>
	<a href="javascript:ViewAssessment('1');">View Assessment Detail</a> &nbsp;&nbsp;
<%if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UB") || strSchCode.startsWith("SWU")){%>
	<a href="javascript:ViewAssessment('');">Study Load</a>
<%}if(strSchCode.startsWith("UB")  || strSchCode.startsWith("SWU")){
	if(strSchCode.startsWith("UB")){
%>
	 &nbsp;&nbsp; <a href="javascript:ChargeSlip();">Charge Slip</a>
<%}	if(strSchCode.startsWith("SWU")){%>	 
	 &nbsp;&nbsp; <a href="javascript:PrintPermit();">Print Exam Permit</a>	
<%}%>
	&nbsp;&nbsp; <a href="javascript:StatementOfAccount();">Statement Of Account</a>	 
<%}%>
	  </td>
  </tr>
<%}%>
  </table>
<%
if(vBasicInfo != null && vBasicInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="37%" height="25">Student ID :<strong> <%=strStudID%></strong></td>
      <td width="61%" height="25"  colspan="4">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
        <%
	  if(vBasicInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
        <%}%>
        </strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td  colspan="4" height="25">Current Year(Term) :<strong> <%=WI.getStrValue(vBasicInfo.elementAt(4),"N/A")%>
        (<%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%>)</strong>
		<font  style="font-weight:bold; font-size:22px;"><%if(strBatchNumber != null) {%>&nbsp;&nbsp;&nbsp;&nbsp;Batch: <%=strBatchNumber%><%}%></font>
	  </td>
    </tr>
<%if(strSchCode.startsWith("UB")){%>
    <tr>
      <td>&nbsp;</td>
      <td valign="top"></td>
      <td  colspan="4"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="top"><u>Student Address: </u>
	  <br><font size="1">
	  <%=WI.getStrValue(strAddress, "Not Set")%>
	  </font>
	  </td>
      <td  colspan="4" height="25" valign="top">Student Age: <%=WI.getStrValue(strAge,"DOB not set")%></td>
    </tr>
<%}
if(strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">
	  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr> 
				<td width="15%" valign="top" style="font-weight:bold; color:#FF0000"><br>Semestral Remark:</td>
				<td>
<%
strTemp = "select sem_remark from stud_curriculum_hist where sy_from = "+WI.fillTextValue("sy_from")+
				" and semester = "+WI.fillTextValue("semester")+" and is_valid = 1 and user_index = "+(String)vBasicInfo.elementAt(0);
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp == null)
	strTemp = "";
%>				<textarea name="sem_remark" style="font-size:11px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; background-color:#CCCCCC" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#cccccc'" rows="4" cols="85"><%=strTemp%></textarea>
				<font style="color:#FF0000">
				<a href="javascript:ajaxUpdateRemark();">Update Remark</a>
				
				<label id="coa_info_remark" style="font-size:9px; font-weight:bold"></label>
				</font>
				<br>&nbsp;				</td>
			</tr>
		</table>	  </td>
    </tr>
<%}
if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("UPH")){
String strPlanInfo = "select PLAN_NAME from FA_STUD_MIN_REQ_DP_PER_STUD "+
					"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
					" where is_temp_stud = 0 and stud_index = "+vBasicInfo.elementAt(0)+
					" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester");
strPlanInfo = dbOP.getResultOfAQuery(strPlanInfo, 0);
if(strPlanInfo != null){
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-weight:bold; color:#0000FF; font-size:12px;"><u>Plan Subscribed: <%=strPlanInfo.toUpperCase()%></u></td>
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
<%}
}%>
  </table>

<%
if(vTimeSch != null && vTimeSch.size() > 0){
double dBalance = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue(); //System.out.println("dBalance : "+dBalance);
double dCredit = 0d;
double dDebit = 0d;
String strTransDate = null;
int iIndex = 0;
boolean bolDatePrinted = false;
//System.out.println(" 1c. dBalance : "+dBalance);
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td width="11%" height="25" align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <%if(bolSplitOR){%><td width="11%" align="center" class="thinborder"><strong>Reference No.</strong></td><%}%>
      <td width="40%" align="center" bgcolor="#B9B292" class="thinborder"><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>COLLECTED BY (ID)
          </strong></font></div></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="17%" align="center" class="thinborder"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <%if(bolSplitOR){%><td class="thinborder">&nbsp;</td><%}%>
      <td colspan="4" align="right" class="thinborder">OLD ACCOUNTS<%=faStudLedg.getDormOldAccountInfo(true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
//System.out.println(" 1. dBalance : "+dBalance);
for(int i=0; i<vTimeSch.size(); ++i){
strTransDate = ConversionTable.convertMMDDYYYY((Date)vTimeSch.elementAt(i));
bolDatePrinted = false;

if(vTuitionFeeDetail.contains((Date)vTimeSch.elementAt(i))){
dDebit = ((Double)vTuitionFeeDetail.elementAt(1)).doubleValue();
dBalance += dDebit;
//System.out.println(" 2. dDebit : "+dDebit);
//System.out.println(" 2. dBalance : "+dBalance);

bolDatePrinted = true;
%>
    <tr >
      <td height="25" class="thinborder"><%=strTransDate%></td>
      <%if(bolSplitOR){%><td class="thinborder">&nbsp;</td><%}%>
      <td class="thinborder">Tuition Fee</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(2)).doubleValue();
dBalance += dDebit;
%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <%if(bolSplitOR){%><td class="thinborder">&nbsp;</td><%}%>
      <td class="thinborder">Miscellaneous Fee</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();
if(dDebit > 0d){
dBalance += dDebit;%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <%if(bolSplitOR){%><td class="thinborder">&nbsp;</td><%}%>
      <td class="thinborder">Other Charges</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%}
dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
//	System.out.println("dDebit: "+dDebit);
//	System.out.println("dBalance: "+dBalance);
if(dDebit > 0d){
dBalance += dDebit;%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <%if(bolSplitOR){%><td class="thinborder">&nbsp;</td><%}%>
      <td class="thinborder">Hands on</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%}
//show this if there is any discounts.
if(vTuitionFeeDetail.elementAt(5) != null){
double dTemp = ((Double)vTuitionFeeDetail.elementAt(5)).doubleValue();
if(dTemp > 0)
	dCredit = dTemp;
else
	dDebit  =  -1 * dTemp;
dBalance -= dTemp;
%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <%if(bolSplitOR){%><td class="thinborder">&nbsp;</td><%}%>
      <td class="thinborder"><%=vTuitionFeeDetail.elementAt(6)%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder">&nbsp; <%if(dDebit > 0d){%> <%=CommonUtil.formatFloat(dDebit,true)%> <%}%> </td>
      <td align="right" class="thinborder">&nbsp; <%if(dCredit > 0d){%> <%=CommonUtil.formatFloat(dCredit,true)%> <%}%> </td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%}if(vTuitionFeeDetail.elementAt(8) != null){%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <%if(bolSplitOR){%><td class="thinborder">&nbsp;</td><%}%>
      <td colspan="5" class="thinborder">NOTE : <%=(String)vTuitionFeeDetail.elementAt(8)%></td>
    </tr>
    <%}
} //for tuition fee detail.

//add or drop subject history here,

//adjustment here
//System.out.println(vAdjustment);
int iIndexOf2 = 0;			
Vector vDiscountAddlDetail = faStudLedg.vDiscountAddlDetail;
String strGrant = null;
String strGrantNote = null;

if(vDiscountAddlDetail == null)
	vDiscountAddlDetail = new Vector();
	
while( (iIndex = vAdjustment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	//System.out.println("dBalance Before: "+dBalance);
	dCredit = Double.parseDouble((String)vAdjustment.elementAt(iIndex-3));
	dBalance -= dCredit;
	
	//System.out.println("dCredit: "+dCredit);
	//System.out.println("dBalance: "+dBalance);
	iIndexOf2 = vDiscountAddlDetail.indexOf(new Integer((String)vAdjustment.elementAt(iIndex + 2)));
	if(iIndexOf2 == -1) {
		strTemp = null;
		strErrMsg = null;
	}
	else {
		strTemp = (String)vDiscountAddlDetail.elementAt(iIndexOf2 + 1);
		if(vDiscountAddlDetail.elementAt(iIndexOf2 + 2) != null && ((String)vDiscountAddlDetail.elementAt(iIndexOf2 + 2)).length() > 0) 
			strErrMsg = (String)vDiscountAddlDetail.elementAt(iIndexOf2 + 2);
		if(strSchCode.startsWith("UB")){
			if(vDiscountAddlDetail.elementAt(iIndexOf2 + 3) != null && ((String)vDiscountAddlDetail.elementAt(iIndexOf2 + 3)).length() > 0) 
				strGrantNote = (String)vDiscountAddlDetail.elementAt(iIndexOf2 + 3);
		}
	}
	
	strGrant = (String)vAdjustment.elementAt(iIndex-4);
	if(!bolShowDiscDetail && strGrant != null && strGrant.length() > 20 && strGrant.indexOf("<br>") > 0) {
		strGrant = strGrant.substring(0, strGrant.indexOf("<br>"));
	}
%>
    <tr >
      <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
      <%if(bolSplitOR){%><td class="thinborder">&nbsp;</td><%}%>
      <td class="thinborder"><%=strGrant%>(Grant)
	  <%=WI.getStrValue(strErrMsg, "<br>Approval #: ","","")%>
	  <%=WI.getStrValue(strGrantNote, "<br>","","")%>	  </td>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <td  align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dCredit,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
//remove the element here.
vAdjustment.removeElementAt(iIndex);vAdjustment.removeElementAt(iIndex-1);vAdjustment.removeElementAt(iIndex-2);
vAdjustment.removeElementAt(iIndex-3);vAdjustment.removeElementAt(iIndex-4);
}

//Refund here
while( (iIndex = vRefund.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dDebit = Double.parseDouble((String)vRefund.elementAt(iIndex-1));
	dBalance += dDebit;
%>
    <tr >
      <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
      <%if(bolSplitOR){%><td class="thinborder">&nbsp;</td><%}%>
      <td class="thinborder">
	  <%if(vRefund.elementAt(iIndex - 2) != null){%>
	  <%=(String)vRefund.elementAt(iIndex-2)%>
	  <%}else{%>
	  <%=(String)vRefund.elementAt(iIndex-3)%>(Refund)
	  <%}%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder">
	  <%if(dDebit >= 0d){%> <%=CommonUtil.formatFloat(dDebit,true)%><%}%></td>
      <td align="right" class="thinborder">&nbsp;
	  <%if(dDebit < 0d){%> <%=CommonUtil.formatFloat(dDebit,true)%><%}%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
//remove the element here.
vRefund.removeElementAt(iIndex);vRefund.removeElementAt(iIndex-1);vRefund.removeElementAt(iIndex-2);
vRefund.removeElementAt(iIndex-3);
}
//dormitory charges
while( (iIndex = vDorm.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dDebit = Double.parseDouble((String)vDorm.elementAt(iIndex-1));
	dBalance += dDebit;
%>
    <tr >
      <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
      <%if(bolSplitOR){%><td class="thinborder">&nbsp;</td><%}%>
      <td class="thinborder"><%=(String)vDorm.elementAt(iIndex-2)%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
//remove the element here.
vDorm.removeElementAt(iIndex);vDorm.removeElementAt(iIndex-1);vDorm.removeElementAt(iIndex-2);
}

//Other school fees/fine/school facility fee charges(except dormitory)
//System.out.println(vOthSchFine);
int iIndexOfPostedBy = 0;
while( (iIndex = vOthSchFine.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
iIndexOfPostedBy = (iIndex - 2)/3;
if(faStudLedg.vOthSchFeePostedBy.size() > iIndexOfPostedBy) {
	strTemp = (String)faStudLedg.vOthSchFeePostedBy.elementAt(iIndexOfPostedBy);
	faStudLedg.vOthSchFeePostedBy.remove(iIndexOfPostedBy);
}
else
	strTemp = null;
	
	dDebit = Double.parseDouble((String)vOthSchFine.elementAt(iIndex-1));
	dBalance += dDebit;
%>
    <tr >
      <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
      <%if(bolSplitOR){%><td class="thinborder">&nbsp;</td><%}%>
      <td class="thinborder"><%=(String)vOthSchFine.elementAt(iIndex-2)%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
//remove the element here.
//vOthSchFine.removeElementAt(iIndex + 1);
vOthSchFine.removeElementAt(iIndex);vOthSchFine.removeElementAt(iIndex-1);vOthSchFine.removeElementAt(iIndex-2);
}

//vPayment goes here, ;-)
while( (iIndex = vPayment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dCredit = Double.parseDouble((String)vPayment.elementAt(iIndex-2));
	dBalance -= dCredit;
%>
    <tr >
      <td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
      <%if(bolSplitOR){%><td class="thinborder"><%=WI.getStrValue(vPayment.elementAt(iIndex-1))%></td><%}%>
      <td class="thinborder"><%if(!bolSplitOR){%><%=WI.getStrValue(vPayment.elementAt(iIndex-1))%> <%}%><%=(String)vPayment.elementAt(iIndex+1)%>
	  <%if(strPNRemarks != null && WI.getStrValue((String)vPayment.elementAt(iIndex+1)).endsWith("- PN")){%>
	  	<br>PN Remark: <%=strPNRemarks%>
	  <%}%>	  </td>
      <td align="center" class="thinborder"><%=(String)vPayment.elementAt(iIndex + 3)%></td>
      <td  align="right" class="thinborder">&nbsp;
	  <%//show only the refunds in debit column.
	  if(dCredit < 0d || 
	  	(vPayment.elementAt(iIndex+1) != null && ((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
	  <%=CommonUtil.formatFloat(-1 * dCredit,true)%>
	  <%}%></td>
      <td align="right" class="thinborder">&nbsp;
	  <%if(dCredit >= 0d && 
	  	(vPayment.elementAt(iIndex+1) == null || !((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
	  <%=CommonUtil.formatFloat(dCredit,true)%>
	  <%}%>	  </td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%//System.out.println("Balance: "+dBalance);
//remove the element here.
vPayment.removeElementAt(iIndex+3);
vPayment.removeElementAt(iIndex+2);
vPayment.removeElementAt(iIndex+1);
vPayment.removeElementAt(iIndex);
vPayment.removeElementAt(iIndex-1);
vPayment.removeElementAt(iIndex-2);
}%>
    <%
}%>
  </table> 
<% 
int iIndexOf = 0;
String strSubjFee = null;
String strLabFee  = null;
String strTotFee  = null;
if (vAddedSub != null && vAddedSub.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>  
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><strong>LIST 
          OF ADDED SUBJECTS</strong></div></td>
    </tr>
    <tr align="center" style="font-weight:bold"> 
      <td width="15%" height="25" class="thinborder"><font size="1">Subject</font></td>
      <td width="15%" class="thinborder"><font size="1">Section </font></td>
      <td width="5%" class="thinborder"><font size="1">Units</font></td>
      <td width="12%" class="thinborder"><font size="1">Date Approved</font></td>
      <td width="28%" class="thinborder"><font size="1">Reason For Adding</font></td>
      <td width="8%" class="thinborder"><font size="1">Added By</font></td>
      <td width="8%" class="thinborder"><font size="1">Subject Fee<br>(Tuition)</font></td>
      <td width="8%" class="thinborder"><font size="1">Handson Fee</font></td>
    </tr>
    <% for (int i = 0; i < vAddedSub.size(); i+=18){
		iIndexOf = vAddDropSubFeeDtls.indexOf((String)vAddedSub.elementAt(i));
		if(iIndexOf == -1) {
			strSubjFee = null;
			strLabFee  = null;
			strTotFee  = null;
		}
		else {
			strSubjFee = (String)vAddDropSubFeeDtls.elementAt(iIndexOf + 1);
			strLabFee  = (String)vAddDropSubFeeDtls.elementAt(iIndexOf + 2);
			strTotFee  = (String)vAddDropSubFeeDtls.elementAt(iIndexOf + 3);
			vAddDropSubFeeDtls.remove(iIndexOf);vAddDropSubFeeDtls.remove(iIndexOf);vAddDropSubFeeDtls.remove(iIndexOf);vAddDropSubFeeDtls.remove(iIndexOf);
		}
	%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vAddedSub.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vAddedSub.elementAt(i+6)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vAddedSub.elementAt(i+12)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vAddedSub.elementAt(i+14),"&nbsp")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vAddedSub.elementAt(i+15),"&nbsp")%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vAddedSub.elementAt(i+16)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue(strSubjFee, "&nbsp;")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue(strLabFee, "&nbsp;")%></font></td>
    </tr>
    <%}//end for loop%>
  </table>

<%} if (vDroppedSub != null && vDroppedSub.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="6">&nbsp;</td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   <tr bgcolor="#FFFFAF"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><strong>LIST 
          OF DROPPED SUBJECTS</strong></div></td>
    </tr>
    <tr style="font-weight:bold;" align="center"> 
      <td width="15%" height="25" class="thinborder"><font size="1">Subject</font></td>
      <td width="15%" class="thinborder"><font size="1">Section </font></td>
      <td width="5%" class="thinborder"><font size="1">Units</font></td>
      <td width="12%" class="thinborder"><font size="1">Date Approved</font></td>
      <td width="28%" class="thinborder"><font size="1">Reason For Dropping</font></td>
      <td width="8%" class="thinborder"><font size="1">Dropped By</font></td>
      <td width="8%" class="thinborder"><font size="1">Subject Fee<br>(Tuition)</font></td>
      <td width="8%" class="thinborder"><font size="1">Handson Fee</font></td>
    </tr>
    <% for (int i = 0; i < vDroppedSub.size(); i+=18){
		iIndexOf = vAddDropSubFeeDtls.indexOf((String)vDroppedSub.elementAt(i));
		if(iIndexOf == -1) {
			strSubjFee = null;
			strLabFee  = null;
			strTotFee  = null;
		}
		else {
			strSubjFee = (String)vAddDropSubFeeDtls.elementAt(iIndexOf + 1);
			strLabFee  = (String)vAddDropSubFeeDtls.elementAt(iIndexOf + 2);
			strTotFee  = (String)vAddDropSubFeeDtls.elementAt(iIndexOf + 3);
			vAddDropSubFeeDtls.remove(iIndexOf);vAddDropSubFeeDtls.remove(iIndexOf);vAddDropSubFeeDtls.remove(iIndexOf);vAddDropSubFeeDtls.remove(iIndexOf);
		}
	%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vDroppedSub.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDroppedSub.elementAt(i+6)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDroppedSub.elementAt(i+12)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vDroppedSub.elementAt(i+14),"&nbsp")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vDroppedSub.elementAt(i+15),"&nbsp")%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDroppedSub.elementAt(i+16)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue(strSubjFee, "&nbsp;")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue(strLabFee, "&nbsp;")%></font></td>
    </tr>
    <%}//end for loop%>
  </table>
<%} if (vDissolvedSub != null && vDissolvedSub.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="6">&nbsp;</td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   <tr bgcolor="#FFFFAF"> 
      <td height="25" colspan="7" class="thinborder"><div align="center"><strong>LIST OF DISSOLVED SUBJECTS</strong></div></td>
    </tr>
    <tr style="font-weight:bold;" align="center"> 
      <td width="15%" height="25" class="thinborder"><font size="1">Subject</font></td>
      <td width="15%" class="thinborder"><font size="1">Section </font></td>
      <td width="5%" class="thinborder"><font size="1">Units</font></td>
      <td width="12%" class="thinborder"><font size="1">Date Dissolved</font></td>
      <td width="36%" class="thinborder"><font size="1">Dissolved By</font></td>
      <td width="8%" class="thinborder"><font size="1">Subject Fee<br>(Tuition)</font></td>
      <td width="8%" class="thinborder"><font size="1">Handson Fee</font></td>
    </tr>
    <% for (int i = 0; i < vDissolvedSub.size(); i+=13){
		iIndexOf = vAddDropSubFeeDtls.indexOf((String)vDissolvedSub.elementAt(i));
		if(iIndexOf == -1) {
			strSubjFee = null;
			strLabFee  = null;
			strTotFee  = null;
		}
		else {
			strSubjFee = (String)vAddDropSubFeeDtls.elementAt(iIndexOf + 1);
			strLabFee  = (String)vAddDropSubFeeDtls.elementAt(iIndexOf + 2);
			strTotFee  = (String)vAddDropSubFeeDtls.elementAt(iIndexOf + 3);
			vAddDropSubFeeDtls.remove(iIndexOf);vAddDropSubFeeDtls.remove(iIndexOf);vAddDropSubFeeDtls.remove(iIndexOf);vAddDropSubFeeDtls.remove(iIndexOf);
		}
	%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vDissolvedSub.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDissolvedSub.elementAt(i+6)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDissolvedSub.elementAt(i+9)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vDissolvedSub.elementAt(i+10),"&nbsp")%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vDissolvedSub.elementAt(i+12)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue(strSubjFee, "&nbsp;")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue(strLabFee, "&nbsp;")%></font></td>
    </tr>
    <%}//end for loop%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
        to print ledger
<%if ( (vDroppedSub != null && vDroppedSub.size() > 0) || (vAddedSub != null && vAddedSub.size() > 0) || (vDissolvedSub != null && vDissolvedSub.size() > 0) ){%>		
		<input type="checkbox" name="inc_adddrop" value="checked" <%=WI.fillTextValue("inc_adddrop")%>> Include add/drop/dissolve list in ledger prinout
<%}%>
		</font></td>
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
  </table>
<%}//only if vTimeSch is not null
%>
<input type="hidden" name="user_index" value="<%=(String)vBasicInfo.elementAt(0)%>">


<!--<div id="processing" style="position:absolute; top:35px; width:250px; height:50px;  visibility:visible">-->

<div id="processing2" class="processing"  style="visibility:hidden">
	<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
	  <tr>
	  	<td align="center"><img src='../../../Ajax/ajax-loader_big_black.gif'></td>
	  </tr>
	</table>
</div>
<div id="processing" class="processing"  style="visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
	  <tr>
	  	<td valign="top" align="right"><a href="javascript:HideLayer(1)">Close Window X</a></td>
	  </tr>
	  <%if(vNotEnrolled != null && vNotEnrolled.size() > 0) {%>
	  <tr>
		  <td valign="top" align="center"><u><b>OLD BALANCE LEDGER</b></u></td>
	  </tr>
	  <tr>
		  <td valign="top">
		  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<%while(vNotEnrolled.size() > 0) {%>
				  <tr>
					  <td width="33%" style="font-size:11px;"><a href="javascript:UpdateSYTerm('<%=vNotEnrolled.remove(0)%>','<%=vNotEnrolled.remove(0)%>','<%=vNotEnrolled.remove(0)%>')"><%=vNotEnrolled.remove(0)%></a></td>
					  <td width="33%" style="font-size:11px;"><%if(vNotEnrolled.size() > 0){%><a href="javascript:UpdateSYTerm('<%=vNotEnrolled.remove(0)%>','<%=vNotEnrolled.remove(0)%>','<%=vNotEnrolled.remove(0)%>')"><%=vNotEnrolled.remove(0)%></a><%}%></td>
					  <td width="33%" style="font-size:11px;"><%if(vNotEnrolled.size() > 0){%><a href="javascript:UpdateSYTerm('<%=vNotEnrolled.remove(0)%>','<%=vNotEnrolled.remove(0)%>','<%=vNotEnrolled.remove(0)%>')"><%=vNotEnrolled.remove(0)%></a><%}%></td>
				  </tr>
				<%}%>
			</table>
		  </td>
	  </tr>
	  <%}%>
	  <%if(vEnrolled != null && vEnrolled.size() > 0) {%>
	  <tr>
		  <td valign="top" align="center"><u><b>ENROLLED SY-TERM</b></u></td>
	  </tr>
	  <%if(strLockedByInfo != null) {%>
	  <tr>
		  <td valign="top" style="font-size:10px; font-weight:bold"><%=strLockedByInfo%></td>
	  </tr>
	  <%}%>
	  <tr>
		  <td valign="top">
		  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<%while(vEnrolled.size() > 0) {%>
				  <tr>
					  <td width="33%" style="font-size:11px;"><a href="javascript:UpdateSYTerm('<%=vEnrolled.remove(0)%>','<%=vEnrolled.remove(0)%>','<%=vEnrolled.remove(0)%>')"><%=vEnrolled.remove(0)%></a></td>
					  <td width="33%" style="font-size:11px;"><%if(vEnrolled.size() > 0){%><a href="javascript:UpdateSYTerm('<%=vEnrolled.remove(0)%>','<%=vEnrolled.remove(0)%>','<%=vEnrolled.remove(0)%>')"><%=vEnrolled.remove(0)%></a><%}%></td>
					  <td width="33%" style="font-size:11px;"><%if(vEnrolled.size() > 0){%><a href="javascript:UpdateSYTerm('<%=vEnrolled.remove(0)%>','<%=vEnrolled.remove(0)%>','<%=vEnrolled.remove(0)%>')"><%=vEnrolled.remove(0)%></a><%}%></td>
				  </tr>
				<%}%>
			</table>
		  </td>
	  </tr>
	  <%}%>
	  <tr>
		  <td valign="bottom" align="center" height="25px" class="thinborderTOP" style="font-size:9px;">
			<input type="button" value="Show Only Tuition" onClick="ShowTuition('0');" style="font-size:11px; height:25px;border: 1px solid #FF0000; background:#FFCC99; color:#990099"> &nbsp;
			<input type="button" value="Show Only Non-Tuition" onClick="ShowTuition('2');" style="font-size:11px; height:25px;border: 1px solid #FF0000; background:#FFCC99; color:#990099"> <br>
			<input type="button" value="Show All Payments Made For all SY" onClick="ShowTuition('1');" style="font-size:11px; height:25px;border: 1px solid #FF0000; background:#FFCC99; color:#990099"> &nbsp;
	<!--
			<input type="button" value="Show Only Adjustment" onClick="ShowTuition('3');" style="font-size:11px; height:25px;border: 1px solid #FF0000; background:#FFCC99; color:#990099"> &nbsp;
	-->
		  </td>
	  </tr>
</table>
</div>

<div id="showPayment" class="showPayment">
<label id="showPamyment_"><img src='../../../Ajax/ajax-loader_big_black.gif'></label>
</div>


<%} //only if basic info is not null;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="id_in_url">
<input type="hidden" name="show_tuition" value="<%=WI.getStrValue(WI.fillTextValue("show_tuition"),"1")%>">
<input type="hidden" name="show_tuition_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>