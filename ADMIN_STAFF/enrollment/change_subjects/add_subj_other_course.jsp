<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.messageBox {
		height: 250px; width:auto; overflow: auto; border: inset black 1px;
}

.nav {
     /**color: #000000;**/
     /**background-color: #FFFFFF;**/
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     /**background-color: #FAFCDD;**/
     background-color:#BCDEDB;
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function AddSubject()
{
	document.advising.addSubject.value = 1;
	document.advising.fake_focus.value = "1";
	document.advising.submit();
}
function SaveLoad() {
	if(document.advising.reason) {
		//must enter reason.. 
		var strReason = document.advising.reason.value;
		if(strReason.length < 5) {
			alert("Please encode a valid reason");
			return;
		}	
	}

	if( eval(document.advising.sub_load_duplicate.value) > eval(document.advising.maxAllowedLoad.value))
	{
		alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load.");
		//document.advising.sub_load_duplicate.value = eval(document.advising.sub_load_duplicate.value) - eval(inputLoad);
		//eval("document.advising.checkbox"+index+".checked=false");
		return;
	}
	document.advising.saveLoad.value = 1;
	document.advising.hide_save.src = "../../../images/blank.gif";
	document.advising.submit();
}
function ReloadPage()
{
	document.advising.addSubject.value = "";
	document.advising.saveLoad.value = "";
	document.advising.fake_focus.value = "1";
	document.advising.submit();
}

function LoadPopup(secName,sectionIndex,strCurIndex, strSubIndex, strIndexOf)//I have to use combination of subject,course and major.
{
//this will check conflict with the schedule of other subjects taken. pass user id, all the sub_section_index,
//if check box is not checked - it is considered as not selected.
	var subSecList = "";
	var strSubSecStartsWith = "";
	if(eval('document.advising.sec'+strIndexOf+'.value.length') > 0)
		strSubSecStartsWith = eval('document.advising.sec'+strIndexOf+'.value');
	for(var i = 0; i< document.advising.maxDisplay.value; ++i)
	{
		if(i == strIndexOf)
			continue;
		if( eval('document.advising.checkbox'+i+'.checked') )
		{
			if(subSecList.length ==0)
				subSecList =eval('document.advising.sec_index'+i+'.value');
			else
				subSecList =subSecList+","+eval('document.advising.sec_index'+i+'.value');
		}
	}
	if(subSecList.length == 0)
		subSecList = document.advising.sub_sec_csv.value;
	else
		subSecList +=","+document.advising.sub_sec_csv.value;
//alert(subSecList);
	if(subSecList.length == 0) subSecList = "0";

	var loadPg = "../advising/subject_schedule.jsp?form_name=advising&cur_index="+strCurIndex+
		"&sub_index="+strSubIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.advising.sy_from.value+"&syt="+document.advising.sy_to.value+"&semester="+document.advising.semester.value+
		"&sec_index_list="+subSecList+"&course_index="+document.advising.ci.value+
		"&major_index="+document.advising.mi.value+"&degree_type="+document.advising.degree_type.value+"&index_of_="+strIndexOf+	"&sec_startsWith="+escape(strSubSecStartsWith) +
		"&year_level=" + document.advising.year_level.value+"&line_number="+strIndexOf+"&add_oc=1";

	if (eval('document.advising.nstp_val'+strIndexOf)){
		loadPg += "&nstp_val=" + eval('document.advising.nstp_val'+strIndexOf+
										'[document.advising.nstp_val'+strIndexOf+'.selectedIndex].text');
	}

	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}




/** overwrite May 2, 2007
function LoadPopup(secName,sectionIndex, strCurIndex, strSubIndex) //curriculum index is different for all courses.
{
//this will check conflict with the schedule of other subjects taken. pass user id, all the sub_section_index,
//if check box is not checked - it is considered as not selected.
	var subSecList = "";
	var i = eval(document.advising.maxDisplay.value)-eval(document.advising.addSubCount.value);
	for(; i< document.advising.maxDisplay.value; ++i)
	{
		if( eval('document.advising.checkbox'+i+'.checked') )
		{//alert(eval('document.advising.sec_index'+i+'.value'));
			if(subSecList.length ==0)
				subSecList =eval('document.advising.sec_index'+i+'.value');
			else
				subSecList =subSecList+","+eval('document.advising.sec_index'+i+'.value');
		}
	}

	if(subSecList.length == 0) subSecList = document.advising.sub_sec_csv.value;
	else
		subSecList +=","+document.advising.sub_sec_csv.value;

	var loadPg = "../advising/subject_schedule.jsp?form_name=advising&cur_index="+strCurIndex+
		"&sub_index="+strSubIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.advising.sy_from.value+"&syt="+document.advising.sy_to.value+"&semester="+document.advising.semester[document.advising.semester.selectedIndex].value+
		"&sec_index_list="+subSecList+"&course_index="+document.advising.ci.value+
		"&major_index="+document.advising.mi.value+"&degree_type="+document.advising.degree_type.value;

	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,top=10,left=10,scrollbars=yes,,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

**/


function AddLoad(index,subLoad)
{
	//if there is no section schedule yet - do not let user select.
	var inputLoad = eval('document.advising.ut'+index+'.value');
	if(eval('document.advising.sec_index'+index+'.value.length') ==0)
	{
		alert("Please schedule first before selecting a subject.");
		eval("document.advising.checkbox"+index+".checked=false");
		return;
	}

	if( eval("document.advising.checkbox"+index+".checked") )
	{
		document.advising.sub_load_duplicate.value = eval(document.advising.sub_load_duplicate.value) + eval(inputLoad);
		if( eval(document.advising.sub_load_duplicate.value) > eval(document.advising.maxAllowedLoad.value))
		{
			alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load.");
			document.advising.sub_load_duplicate.value = eval(document.advising.sub_load_duplicate.value) - eval(inputLoad);
			eval("document.advising.checkbox"+index+".checked=false");
		}
	}
	else //subtract.
		document.advising.sub_load_duplicate.value = eval(document.advising.sub_load_duplicate.value) - eval(inputLoad);
/**
	if(eval('document.advising.sec_index'+index+'.value.length') ==0)
	{
		alert("Please schedule first before selecting a subject.");
		eval("document.advising.checkbox"+index+".checked=false");
		return;
	}

	if( eval("document.advising.checkbox"+index+".checked") )
	{
		document.advising.sub_load.value = eval(document.advising.sub_load.value) + eval(subLoad);
		if( eval(document.advising.sub_load.value) > eval(document.advising.maxAllowedLoad.value))
		{
			alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load.");
			document.advising.sub_load.value = eval(document.advising.sub_load.value) - eval(subLoad);
			eval("document.advising.checkbox"+index+".checked=false");
		}
	}
	else //subtract.
		document.advising.sub_load.value = eval(document.advising.sub_load.value) - eval(subLoad);
**/

	if( eval(document.advising.sub_load_duplicate.value) < 0)
		document.advising.sub_load_duplicate.value = 0;
	document.advising.sub_load.value = document.advising.sub_load_duplicate.value;

}
function FocusID() {
	if(document.advising.stud_id.value.length == 0)
		document.advising.stud_id.focus();
	if(document.advising.focus_bottom) {
		document.advising.focus_bottom.focus();
		return;
	}
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=advising.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateAddDropCount() {
	return;
	var obj = document.advising.no_of_adddrop;
	if(!obj)
		return;
	if(document.advising.no_of_adddrop_edited.value != '')
		return;
	
	var iCount = 0;
	for(var i = 0; i< document.advising.maxDisplay.value; ++i) {
		if( eval('document.advising.checkbox'+i+'.checked'))
			++iCount;
	}
	if(iCount > 0) 
		obj.value = iCount;

}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.advising.stud_id.value;
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
	document.advising.stud_id.value = strID;
	document.advising.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.advising.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

function PrintFinalClassSchedule() {
	var strStudID   = document.advising.stud_id.value;
	var strSYFrom   = document.advising.sy_from.value;
	var strSYTo     = document.advising.sy_to.value;
	var strSemester = document.advising.semester.value;
	
	if(strStudID == '') {
		alert("Please enter student ID.");
		return;
	}
	if(strSYFrom == '' || strSYFrom == '') {
		alert("Please enter SY From/To.");
		return;
	}
	if(strSemester == '') {
		alert("Please enter Semester");
		return;
	}

	var pgLoc = "../../fee_assess_pay/payment/enrollment_receipt_print_uc_batch.jsp?sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+
		strSemester+"&stud_id="+strStudID;
		
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<%@ page language="java" import="utility.*,enrollment.AdvisingExtn,enrollment.Advising,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strStudID = request.getParameter("stud_id");
	String strDegreeType = null;
	int iMaxDisplayed = 0;
	String strSubSecCSV = null;//this is the subject section already enrolled in CSV to check the conflict ;-)
	String strAddedSubCSV = WI.fillTextValue("added_subject_csv");// list of all the subject added to the list
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

	String strInputType = "";
	String strInputTypeDetails = "";

	int i=0; int j=0;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Advising-Subject from other course","advising_subj_other_course.jsp");
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
														"Enrollment","CHANGE OF SUBJECTS",request.getRemoteAddr(),
														"advising_subj_other_course.jsp");
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
boolean bolIsSuperUser = comUtil.IsSuperUser(dbOP,(String)request.getSession(false).getAttribute("userId"));

//end of authenticaion code.

float fMaxAllowedLoad = 0f; // this is the first field of the vAdvisingList
Vector vAdviseList = null;//filled up by auto advise, 0=sec index,1=section, 2=cur index.
Vector vStudInfo = null;
Vector vEnrolledList = null;

Vector vAllowedSubList = null;
Vector vAddedSubList   = null;

if(WI.fillTextValue("addSubject").compareTo("1") == 0 && WI.fillTextValue("subject_offered").length() > 0) {
	if(strAddedSubCSV == null || strAddedSubCSV.length() ==0)
		strAddedSubCSV = WI.fillTextValue("subject_offered");
	else
		strAddedSubCSV += ","+WI.fillTextValue("subject_offered");
}
if(strAddedSubCSV != null && strAddedSubCSV.length() > 0)
	vAddedSubList = CommonUtil.convertCSVToVector(strAddedSubCSV);
else
	vAddedSubList = new Vector();
if(strAddedSubCSV == null)
	strAddedSubCSV = "";

boolean bolIsTempStud = false;
boolean bolFatalErr = false;
String  strSaveLoadMsg = null;//Message of save load action
String strMaxAllowedLoad = null;
String strOverLoadDetail = null;



Advising advising = new Advising();
AdvisingExtn advisingExtn = new AdvisingExtn();
enrollment.EnrlAddDropSubject enrlAddDropSub = new enrollment.EnrlAddDropSubject();
enrollment.FAFeeMaintenance FFM = new enrollment.FAFeeMaintenance();

if(WI.fillTextValue("sy_from").length() ==0 || WI.fillTextValue("sy_to").length() ==0)
{
	strErrMsg = "Please enter School Year.";
	bolFatalErr = true;
}

if(!bolFatalErr && strStudID.length() > 0)
{
	vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),strStudID,
									WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vStudInfo == null) {
		strErrMsg = enrlAddDropSub.getErrMsg();
		bolFatalErr = true;
	}
	strTemp = dbOP.mapUIDToUIndex(strStudID);
	if(strTemp == null)
		bolIsTempStud = true;
	else {
		if(dbOP.strBarcodeID != null)
			strStudID = dbOP.strBarcodeID;
	}
	//check if student is allowed to enroll from other course -- student is not allowed if he is not advised his regular subjects.
	if(!bolFatalErr) {
		if(advisingExtn.isEnrollingToOtherSubAllowed(dbOP,(String)vStudInfo.elementAt(0),bolIsTempStud,
                                              WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"), WI.fillTextValue("semester")) != 1) {
			bolFatalErr = true;
			strErrMsg = advisingExtn.getErrMsg();
		}
	}
	if(!bolFatalErr) {//get max load information
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(5),
													(String)vStudInfo.elementAt(6),	WI.fillTextValue("sy_from"),
													WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),
													WI.fillTextValue("semester"),(String)vStudInfo.elementAt(7),
													(String)vStudInfo.elementAt(8));
		if(vMaxLoadDetail == null) {
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
		else {//System.out.println(vMaxLoadDetail);
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
			if(vMaxLoadDetail.size() > 1) {
				if(!bolIsTempStud)
					strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
					" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
			}
			else {
				//if(strSchCode.startsWith("CIT"))
					//strMaxAllowedLoad = Double.toString(Double.parseDouble(strMaxAllowedLoad) - 1);
			}
		}
	}
	//add the subjects if clicked.
	if(!bolFatalErr && WI.fillTextValue("saveLoad").compareTo("1") ==0)
	{
		if(advising.checkScheduleBeforeSave(dbOP,request) != null)
		{
			//add the selected subjects here.
			if(advisingExtn.saveAdditionalLoad(dbOP,request,true)) {
				dbOP.forceAutoCommitToTrue();
				if(!FFM.chargeAddDropFeeApplicable(dbOP, (String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"), (String)vStudInfo.elementAt(4), (String)request.getSession(false).getAttribute("userIndex"), true, request)) {
					strErrMsg = "Subjects Added Successfully. But Add Charge Failed to post to ledger. Please manually post.";
				}
				else
					strErrMsg = "Subject/s added successfully.";

				strAddedSubCSV = null;
				vAddedSubList = null;
				strSaveLoadMsg = strErrMsg;
			}
			else {
				strErrMsg = advisingExtn.getErrMsg();
				bolFatalErr = true;
				strSaveLoadMsg = strErrMsg;
			}
		}
		else
		{
			bolFatalErr = true;
			strErrMsg =advising.getErrMsg();
		}
	}

	if(vStudInfo != null && vStudInfo.size() > 5)
		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5),
							"degree_type"," and is_valid=1 and is_del=0");

	if(!bolFatalErr) {//get coure degree type.
		vEnrolledList = enrlAddDropSub.getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),strDegreeType,
							WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"),bolIsTempStud,true);
		if(vEnrolledList ==null)
		{
			bolFatalErr = true;
			strErrMsg = enrlAddDropSub.getErrMsg();
		}
	}
	//get the allowed subject list.
	if(!bolFatalErr && WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("0") != 0) {
		vAllowedSubList = advisingExtn.getAllowedSubList(dbOP,(String)vStudInfo.elementAt(5),(String)vStudInfo.elementAt(6),
                                  WI.fillTextValue("course_index"),WI.getStrValue(WI.fillTextValue("major_index"),null),
                                  WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"),
                                  vAddedSubList,(String)vStudInfo.elementAt(7),
								  (String)vStudInfo.elementAt(8));

		if(vAllowedSubList == null) {
			strErrMsg = advisingExtn.getErrMsg();
		}
	}
	if(strDegreeType != null && (WI.fillTextValue("show_all_subject").length() > 0 || request.getParameter("show_all_subject") == null)) {
		String strSQLQuery = "select sub_index, sub_code from subject where is_del = 0 and exists (select * from e_sub_section where is_valid = 1 and "+
							" offering_sy_from = "+WI.fillTextValue("sy_from") + " and offering_sem = "+WI.fillTextValue("semester")+
							" and sub_index = subject.sub_index) ";
		if(WI.getStrValue(strAddedSubCSV).length() > 0)
			strSQLQuery += " and sub_index not in ("+strAddedSubCSV+") ";

		if (strDegreeType.equals("1"))
			strSQLQuery += " and exists(select * from cculum_masters where is_valid = 1 and sub_index = subject.sub_index) ";
		else if (strDegreeType.equals("2"))
			strSQLQuery += " and exists(select * from cculum_medicine where is_valid = 1 and main_sub_index = subject.sub_index) ";
		else
			strSQLQuery += " and exists(select * from curriculum where is_valid = 1 and sub_index = subject.sub_index) ";

		strSQLQuery += " order by sub_code";
		//System.out.println(strSQLQuery);v
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		vAllowedSubList = new Vector();
		while(rs.next()) {
			vAllowedSubList.addElement(rs.getString(1));
			vAllowedSubList.addElement(rs.getString(2));
		}
		rs.close();
	}

	if(!bolFatalErr && vAddedSubList != null && vAddedSubList.size() > 0) {
		vAdviseList = advisingExtn.getAdviseList(dbOP, strDegreeType,WI.fillTextValue("course_index"),
														WI.fillTextValue("major_index"), vAddedSubList);
		if(vAdviseList == null || vAdviseList.size() ==0)
			strErrMsg = advisingExtn.getErrMsg();//System.out.println(vEnrolledList);
	}
	//System.out.println(vAdviseList);
}

if(vEnrolledList != null && vEnrolledList.size() > 0 && vAllowedSubList != null && vAllowedSubList.size() > 0) {
	//I have to remove from the list if already having subject.. 
	Vector vSubjectEnrolled = new Vector();
	for(int t = 1; t < vEnrolledList.size(); t += 15)
		vSubjectEnrolled.addElement(vEnrolledList.elementAt(t + 2));
	
	for(int t =0; t < vAllowedSubList.size(); t += 2) {
		if(vSubjectEnrolled.indexOf(vAllowedSubList.elementAt(t)) > -1) {
			vAllowedSubList.remove(t);vAllowedSubList.remove(t);
			t = t -2;
		}
	}
}


String strReadOnlyUnitToTake = "";
if(strSchCode.startsWith("UB"))
	strReadOnlyUnitToTake = " readonly='yes'";

String strInfo5 = (String)request.getSession(false).getAttribute("info5");
boolean bolReasonRequired = false;
if(strSchCode.startsWith("UPH") && strInfo5 != null)
	bolReasonRequired = true;


boolean bolIsAllowedToAddDrop = false;
if(!bolFatalErr && vStudInfo != null && vStudInfo.size() > 0) {
	enrollment.SetParameter sP = new enrollment.SetParameter();
	if(!sP.isLockedGeneric(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), "3", (String)vStudInfo.elementAt(0), "0"))
		bolIsAllowedToAddDrop = true;
	else
		strErrMsg = "Add/Drop already closed. Please contact System admin.";
}

%>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<form name="advising" action="./add_subj_other_course.jsp" method="post">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" bgcolor="#A49A6A" align="center"><strong> <font color="#FFFFFF">
        :::: SUBJECT(S) FROM OTHER COURSE ADVISING PAGE :::: </font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="8">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%" height="25">Enter Student ID</td>
      <td height="25" width="20%"><input name="stud_id" type="text" size="16" value="<%=WI.getStrValue(strStudID)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="8%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td height="25" width="52%"><!--<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>-->
	  <input type="image" src="../../../images/form_proceed.gif" border="0"
	  onClick="document.advising.addSubject.value='';document.advising.saveLoad.value='';document.advising.fake_focus.value='';">
<%if(strSchCode.startsWith("SPC")) {%>
	<%
	  strTemp = WI.fillTextValue("error_enrl");
	  if(strTemp.compareTo("1") == 0)
	  	strTemp = " checked";
	  else
	  	strTemp = "";
	%>
	  <input type="checkbox" name="error_enrl" value="1"<%=strTemp%>>
        <font color="#0000FF"><strong>Add due to error in Enrollment.</strong></font>
<%}%>
	  </td>
    </tr>
    <tr>
      <td></td>
      <td colspan="4"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">School Year/Term</td>
      <td height="25" colspan="2">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("advising","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
      <td height="25">
	  	  <%if (strSchCode.startsWith("UC")) {%>
	  	<input type="button" name="122" value="Print Final Class Schedule" style="font-size:14px; height:28px;border: 1px solid #FF0000;" onClick="PrintFinalClassSchedule();">
	  <%}%>

</td>
    </tr>
    <tr>
      <td colspan="5"><hr size="1"></td>
    </tr>
  </table>
<% if(!bolFatalErr){//show everything below this.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%" height="25">Student name </td>
      <td width="35%"><strong><%=(String)vStudInfo.elementAt(1)%></strong> <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">      </td>
      <td width="46%" height="25">Date approved:
<%
strTemp = WI.fillTextValue("apv_date");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>        <input name="apv_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('advising.apv_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major</td>
      <td height="25" colspan="2"><strong><%=(String)vStudInfo.elementAt(2)%>
        <%
		if(vStudInfo.elementAt(3) != null){%>
        / <%=(String)vStudInfo.elementAt(3)%>
        <%}%>
        </strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Year level</td>
      <td height="26"><strong><%=WI.getStrValue((String)vStudInfo.elementAt(4),"N/A")%></strong>
        <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(4)%>"></td>
      <td height="26">&nbsp;</td>
    </tr>
  </table>

<% if(vStudInfo != null && vStudInfo.size() > 0 && !bolFatalErr){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9"><div align="center">LIST OF SUBJECTS ADVISED
          ALREADY FOR THIS SEMESTER</div></td>
    </tr>
<%if(strSchCode.startsWith("UC")){
strTemp = FFM.getAddDropFeeRef(dbOP, WI.fillTextValue("sy_from"), true);
if(strTemp != null) {
strTemp = "select amount from fa_oth_sch_fee where othsch_fee_index = "+strTemp;
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp != null)
	strTemp = CommonUtil.formatFloat(strTemp, true);
%>
    <tr>
      <td  height="25">&nbsp;</td>
      <td colspan="4" height="25" style="font-size:16px; font-weight:bold; color:#0000FF">Number of  Charge(s):
	    <input type="text" name="no_of_adddrop" size="3" value="1" <%if(!bolIsSuperUser && false){%>readonly="yes"<%}%> maxlength="2" style="font-weight:bold;font-size:18px; color:#0000FF;font-family:Verdana, Arial, Helvetica, sans-serif;" onKeyUp="document.advising.no_of_adddrop_edited.value='1'">
	  x <%=strTemp%>
	  </td>
    </tr>
<%}
}
if(strOverLoadDetail != null){%>
    <tr>
      <td  height="25">&nbsp;</td>
      <td colspan="4" height="25"><font size="1">Overload detail : <%=strOverLoadDetail%></font></td>
    </tr>
<%}%>

    <tr >
      <td height="25" width="2%">&nbsp;</td>
      <td  colspan="2" height="25">Maximum units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
      <td  colspan="2" height="25">Total student load :
<input type="text" name="sub_load" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;" value="<%=(String)vEnrolledList.elementAt(0)%>"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="14%" height="27" align="center" class="thinborder"><font size="1"><strong>SUBJECT
        CODE</strong></font></td>
      <td width="25%" align="center" class="thinborder"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
	 <% if (!strSchCode.startsWith("CPU")){%>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>LEC. UNITS</strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>LAB. UNITS</strong></font></td>
	  <%}%>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong> UNITS TAKEN</strong></font></td>
	<% if (strSchCode.startsWith("CPU")) {%>
     <td width="9%" align="center" class="thinborder"><font size="1"><strong>STUBCODE</strong></font></td>
	 <%}%>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>SECTION / ROOM</strong></font></td>

      <td width="21%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
    </tr>
    <%
 for(i=1,j=0;i<vEnrolledList.size();++i,++j){
 if(strSubSecCSV == null)
 	strSubSecCSV = (String)vEnrolledList.elementAt(i+5);
 else
 	strSubSecCSV += ","+(String)vEnrolledList.elementAt(i+5);
 %>
    <tr>
      <td height="25" class="thinborder"><%=(String)vEnrolledList.elementAt(i+3)%></td>
      <td class="thinborder"><%=(String)vEnrolledList.elementAt(i+4)%></td>
	<% if(!strSchCode.startsWith("CPU")) {%>
      <td class="thinborder"><%=WI.getStrValue(vEnrolledList.elementAt(i+11),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vEnrolledList.elementAt(i+12),"&nbsp;")%></td>
	 <%}%>
      <td class="thinborder"><div align="center"><%=(String)vEnrolledList.elementAt(i+13)%></div></td>
	<% if (strSchCode.startsWith("CPU")){%>
      <td class="thinborder"><div align="center"><%=(String)vEnrolledList.elementAt(i+5)%></div></td>
	 <%}
	 	strTemp = (String)vEnrolledList.elementAt(i+8);
	 	if (strTemp != null && strTemp.indexOf("null") != -1){
			strTemp = ConversionTable.replaceString(strTemp,"null", "TBA");
 		}
	 %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"N/A")%></td>
      <td class="thinborder"><%=WI.getStrValue(vEnrolledList.elementAt(i+6),"N/A")%>
	  <!-- all the hidden fileds are here. -->
	  <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+1)%>">
	  <input type="hidden" name="checkbox<%=j%>" value="checkbox"><!-- for checking conflict ;-) just a simple work around -->
	  <input type="hidden" name="sec_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+5)%>">
	  <input type="hidden" name="is_lab_only<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+14)%>">
	 <% if (strSchCode.startsWith("CPU")) {%>
	  <input type="hidden" name="by_pass<%=j%>" value="1">
	  <%}%>
</td>
    </tr>
    <%
i = i+14;
}%>
  </table>
<%if(bolIsAllowedToAddDrop){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
<% if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UPH") || true) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4" style="font-weight:bold; font-size:11px; color:#0000FF">
<%
strTemp = WI.fillTextValue("show_all_subject");
if(strTemp.length() > 0 || request.getParameter("show_all_subject") == null )
	strTemp = " checked";
%>	  	<input type="checkbox" name="show_all_subject" value="1" <%=strTemp%>
			onClick="document.advising.course_index.selectedIndex=0;document.advising.cc_index.selectedIndex=0;document.advising.major_index.selectedIndex=0;ReloadPage();"> Show All Subjects.
	  </td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="25"> <div align="left"></div></td>
      <td height="25" colspan="4">Course Program(Optional to select) :
        <select name="cc_index" onChange="ReloadPage();">
          <option value="0">Select a Program</option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc", request.getParameter("cc_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="4">Course :
        <select name="course_index" onChange="ReloadPage();" style="width:550px">
          <option value="0">Select Any</option>
          <%
//if course program is selected, then filter course offered displayed else, show all courses offered.
String strDegreeTypeCon = strDegreeType;
if(strDegreeType.equals("4"))
	strDegreeTypeCon = " 0 or degree_type = 4";

if(WI.fillTextValue("cc_index").length()>0 && WI.fillTextValue("cc_index").compareTo("0") != 0)
{
	strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and cc_index="+request.getParameter("cc_index")+
		  	" and (degree_type = "+strDegreeTypeCon+") order by course_name asc" ;//not allowed to take subject from other degree course.
}
else
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and (degree_type = "+strDegreeTypeCon+") order by course_name asc";

%>
          <%=dbOP.loadCombo("course_index","course_code,course_name",strTemp, WI.fillTextValue("course_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">Major :
        <select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.length() > 0 && strTemp.compareTo("0") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"> <a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" border="0"></a>
        <font size="1">click to show subjects offered by this course</font> </td>
    </tr>
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25"><input type="text" class="textbox_noborder" style="font-size:8px;" size="1" name="focus_bottom"></td>
      <td height="25" colspan="4">Subject to take
        <select name="subject_offered" onChange='AddSubject();'>
          <option value="">Select Subject code</option>
          <%

strTemp = WI.fillTextValue("subject_offered");
if(vAllowedSubList != null){
		for(i = 0; i< vAllowedSubList.size(); i +=2)
		{
		if(strTemp.compareTo((String)vAllowedSubList.elementAt(i)) ==0){%>
          <option selected value="<%=(String)vAllowedSubList.elementAt(i)%>"><%=(String)vAllowedSubList.elementAt(i+1)%></option>
          <%}else{%>
          <option value="<%=(String)vAllowedSubList.elementAt(i)%>"><%=(String)vAllowedSubList.elementAt(i+1)%></option>
          <%}
		}//end of for loop
	}//end of if condition if vAllowedSubList is not null.%>
        </select>
        : <b>
        <%
strTemp = WI.fillTextValue("subject_offered");
if(WI.fillTextValue("addSubject").compareTo("1") ==0)
	strTemp = null;
%>
        <%=WI.getStrValue(dbOP.mapOneToOther("SUBJECT","sub_index",strTemp,"sub_name",null))%></b></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="12%" height="25">&nbsp;</td>
      <td width="15%">&nbsp;</td>
      <td width="18%">&nbsp;</td>
      <td width="53%">
        <%
if(iAccessLevel > 1 && vAllowedSubList != null && vAllowedSubList.size() > 0){%>
        <a href="javascript:AddSubject();"><img src="../../../images/add.gif"  border="0"></a><font size="1">click
        to add to list subjects to take for scheduling</font>
        <%}%>
      </td>
    </tr>
<%if(strSaveLoadMsg != null) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp;
	  <font size="3"><strong><%=strSaveLoadMsg%></strong></font>
	  </td>
    </tr>
<%}%>
  </table>
<%}
if(vAdviseList != null && vAdviseList.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="10" align="center">SELECTED SUBJECT(S) FOR SCHEDULING</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td  colspan="4" height="25">Maximum units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
      <td  colspan="5" height="25">Total student load :
        <input type="text" name="sub_load_duplicate" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;" value="<%=(String)vEnrolledList.elementAt(0)%>"></td>
    </tr>
    <tr>
      <td width="8%" height="25" align="center"><strong><font size="1">YEAR</font></strong></td>
      <td width="8%" height="25" align="center"><strong><font size="1">TERM</font></strong></td>
      <td width="13%" height="25" align="center"><strong><font size="1">SUBJECT
        CODE</font></strong></td>
      <td width="26%" align="center"><strong><font size="1">SUBJECT TITLE </font></strong></td>
      <td width="7%" align="center"><strong><font size="1">UNITS (LEC/LAB)</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">TOTAL UNITS</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">UNITS TO TAKE</font></strong></td>
      <td width="22%" align="center"><strong><font size="1">
	  <% if (!strSchCode.startsWith("CPU")){%>
		  SECTION <%}else{%> STUB CODE<%}%> </font></strong></td>
      <td width="4%" align="center"><strong><font size="1">SELECT</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">ASSIGN SECTION</font></strong></td>
    </tr>
    <%
int iTemp = 0;
for(i = 0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed)
{
%>
    <tr onDblClick='LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>","<%=j%>");'
	class="nav" id="msg<%=j%>" onMouseOver="navRollOver('msg<%=j%>', 'on')" onMouseOut="navRollOver('msg<%=j%>', 'off')">
      <td height="20" align="center"><%=WI.getStrValue(vAdviseList.elementAt(i+1),"N/A")%> <input type="hidden" name="year_level<%=j%>" value="<%=(String)vAdviseList.elementAt(i+1)%>">
        <input type="hidden" name="sem<%=j%>" value="<%=(String)vAdviseList.elementAt(i+2)%>">
        <input type="hidden" name="sub_code<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>">
        <input type="hidden" name="sub_name<%=j%>" value="<%=(String)vAdviseList.elementAt(i+7)%>">
        <input type="hidden" name="lab_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+4)%>">
        <input type="hidden" name="lec_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+3)%>">
        <input type="hidden" name="total_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>">
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vAdviseList.elementAt(i)%>">
      </td>
      <td align="center"><%=WI.getStrValue(vAdviseList.elementAt(i+2),"N/A")%></td>
      <td><%=(String)vAdviseList.elementAt(i+6)%>
        <%if(((String)vAdviseList.elementAt(i+6)).indexOf("NSTP") != -1 || ((String)vAdviseList.elementAt(i+7)).indexOf("ROTC") != -1){%>
        <select name="nstp_val<%=j%>" style="font-weight:bold;">
          <%=dbOP.loadCombo("distinct NSTP_VAL","NSTP_VAL"," from NSTP_VALUES order by NSTP_VALUES.NSTP_VAL asc", WI.fillTextValue("nstp_val"), false)%>
        </select>
        <%}//only if subject is NSTP %>
      </td>
      <td><%=(String)vAdviseList.elementAt(i+7)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+3)%>/<%=(String)vAdviseList.elementAt(i+4)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+5)%></td>
      <td align="center"><input type="text" value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>" name="ut<%=j%>" size="4" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;" <%=strReadOnlyUnitToTake%>></td>
      <td>
	 <!--
	  <input type="text" name="sec<%=j%>" size="12" readonly="yes" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;">
        <input type="hidden" name="sec_index<%=j%>">
	-->

<input type="hidden" name="IS_LAB_ONLY<%=j%>" value="0">


<% if (strSchCode.startsWith("CPU")){
		strInputType = "hidden";
		strInputTypeDetails = "";
	}else{
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;\"";
	}
%>
	  <input type="<%=strInputType%>" name="sec<%=j%>" <%=strInputTypeDetails%> >
<%
	if (strSchCode.startsWith("CPU")){
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;\"";
	}else{
		strInputType = "hidden";
		strInputTypeDetails = "";
	}
%>
	  <input type="<%=strInputType%>" name="sec_index<%=j%>"  <%=strInputTypeDetails%>>

<!--
	  <input type="text" name="sec<%//=j%>" size="12" readonly="yes" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;">
        <input type="hidden" name="sec_index<%//=j%>">
-->



	</td>
      <td align="center"> <input type="checkbox" name="checkbox<%=j%>"
	  value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>"
	  onClick='AddLoad("<%=j%>","<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>")'>
      </td>
      <td align="center"><a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>","<%=j%>");'><img src="../../../images/schedule.gif" width="40" height="20" border="0"></a></td>
    </tr>
    <% i += 9;}//end of for loop%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="2" valign="top">&nbsp;</td>
    </tr>
<%if(bolIsAllowedToAddDrop){%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="20%" valign="top"><%if(bolReasonRequired){%>Reason for dropping: <%}%></td>
      <td width="40%" valign="top"><%if(bolReasonRequired){%><textarea name="reason" cols="40" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("reason")%></textarea><%}%></td>
      <td width="36%" valign="bottom">
	  <a href="javascript:SaveLoad();">
	  <img src="../../../images/save.gif" border="0" name="hide_save" onClick="UpdateAddDropCount();"></a>
          <font size="1">click to save subjects</font>
	  </td>
    </tr>
<%}%>
  </table>
<!--
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4">
	  <div align="center"><a href="javascript:SaveLoad();">
	  <img src="../../../images/save.gif" border="0" name="hide_save" onClick="UpdateAddDropCount();"></a>
          <font size="1">click to save subjects</font></div></td>
    </tr>
  </table>
-->
<%}//only if vAdviseList is > 0
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="4" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="4" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <%}//end of displaying the advise list if bolShowAdviseList is TRUE

}//only if vAdvise list is > 0
%>
 <input type="input" name="set_focus" size="1" maxlength="1" readonly
 	style="background-color: #D2AE72;border-style: inset;border-color: #D2AE72; border-width: 0px">

<%
if(WI.fillTextValue("fake_focus").compareTo("1") ==0){%>
<script language="JavaScript">
document.advising.set_focus.focus();
</script>
<%}%>
<input type="hidden" name="added_subject_csv" value="<%=strAddedSubCSV%>">
<input type="hidden" name="addSubject">
<input type="hidden" name="fake_focus" value="<%=WI.fillTextValue("fake_focus")%>">

<input type="hidden" name="sub_sec_csv" value="<%=strSubSecCSV%>">
<input type="hidden" name="maxDisplay" value="<%=j%>">
<input type="hidden" name="maxAllowedLoad" value="<%=strMaxAllowedLoad%>">
<input type="hidden" name="addSubCount" value="<%=iMaxDisplayed%>">

<input type="hidden" name="ci" value="<%=WI.fillTextValue("course_index")%>">
<input type="hidden" name="mi" value="<%=WI.getStrValue(WI.fillTextValue("major_index"))%>">

<input type="hidden" name="saveLoad">
<input type="hidden" name="is_confirmed" value="<%=WI.fillTextValue("is_confirmed")%>">
<%
if(bolIsTempStud){%>
<input type="hidden" name="is_temp_stud" value="1">
<%}else{%>
<input type="hidden" name="is_temp_stud" value="0">
<%}%>


<input type="hidden" name="focus_point">
<input type="hidden" name="no_of_adddrop_edited" value="">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
