<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.Advising,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;


	String strSchCode       = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	String strAuthTypeIndex = WI.getStrValue((String)request.getSession(false).getAttribute("authTypeIndex"));
	
	if(strSchCode == null)
		strSchCode = "";

	String strStudID   = WI.fillTextValue("stud_id");
	String strSYFrom   = null;
	String strSYTo     = null;
	String strSemester = null;
	
	strSYFrom = WI.fillTextValue("sy_from");
	if(strSYFrom.length() ==0)
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	
	strSYTo = WI.fillTextValue("sy_to");
	if(strSYTo.length() ==0)
		strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	
	strSemester = WI.fillTextValue("semester");
	if(strSemester.length() ==0)
		strSemester = (String)request.getSession(false).getAttribute("cur_sem");
	
	boolean bolIsOnlineAdvising = false;//called from online advising. --> I have to also check if student is allowed to add/drop.. 
	if(WI.fillTextValue("online_advising").length() > 0 && strAuthTypeIndex.equals("4")) {
			bolIsOnlineAdvising = true;
			strStudID = (String)request.getSession(false).getAttribute("userId");
	}
	//1311842
//	System.out.println(bolIsOnlineAdvising);
//	System.out.println(strSYFrom);
//	System.out.println(strSYTo);
//	System.out.println(strSemester);

	String strSubSecCSV = null;//this is the subject section already enrolled in CSV to check the conflict ;-)
	int iMaxDisplayed = 0;
	boolean bolFatalErr = false;

	int j=0; //this is the max display variable.
	String[] astrSchYrInfo = {WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester")};
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

	String strDegreeType = null;
	String strInputType = null;
	String strInputTypeDetails = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CHANGE OF SUBJECTS","change_subject_add.jsp");
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
if(bolIsOnlineAdvising) 
	iAccessLevel = 2;
else	{
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","CHANGE OF SUBJECTS",request.getRemoteAddr(),
														"change_subject_add.jsp");
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

//I have to give an option to set do not check conflict incase user is super user.
boolean bolIsSuperUser = false;
if(!bolIsOnlineAdvising )
	bolIsSuperUser = comUtil.IsSuperUser(dbOP,(String)request.getSession(false).getAttribute("userId"));
//end of authenticaion code.

//--- I have to check if the student is allowed to add/drop.. 
if(bolIsOnlineAdvising) {
	if(!strSchCode.startsWith("NEU")) {
		if(!new enrollment.OverideParameter().isAllowedAddDrop(dbOP, (String)request.getSession(false).getAttribute("userIndex"), strSYFrom, strSemester)) {
			bolFatalErr = true;
			strErrMsg = "You are not allowed to process add/drop. Please open adding/droping for current date.";
		}	
	}
}



String strMaxAllowedLoad = "0"; // this is the first field of the vAdvisingList
String strOverLoadDetail = null;//Overload detail if there is any.

Vector vEnrolledList = new Vector();
Vector vStudInfo = new Vector();
Vector vAdviseList = new Vector();

Advising advising = new Advising();
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();
enrollment.FAFeeMaintenance FFM = new enrollment.FAFeeMaintenance();


if(!bolFatalErr && strStudID.length() > 0 && WI.fillTextValue("sy_from").length() > 0)
{
	vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),strStudID,
                                    astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	if(vStudInfo == null)
	{
		bolFatalErr = true;
		strErrMsg = enrlAddDropSub.getErrMsg();//System.out.println("step - 1" + strErrMsg);
	}
	else {
		if(dbOP.strBarcodeID != null)
			strStudID = dbOP.strBarcodeID;
	}
	if(!bolFatalErr)
	{
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(5),
								(String)vStudInfo.elementAt(6), astrSchYrInfo[0],astrSchYrInfo[1],
								(String)vStudInfo.elementAt(4),astrSchYrInfo[2],(String)vStudInfo.elementAt(7),
								(String)vStudInfo.elementAt(8));
		if(vMaxLoadDetail == null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();//System.out.println("step - 2");
		}
		else
		{
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
			if(vMaxLoadDetail.size() > 1)
				strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
				" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
			//else
				//if(strSchCode.startsWith("CIT"))
					//strMaxAllowedLoad = Double.toString(Double.parseDouble(strMaxAllowedLoad) - 1);
		}
	}
	//Withdraw subject if it is trigged.
	if(!bolFatalErr && WI.fillTextValue("addSubject").compareTo("1") ==0)
	{
		if(advising.checkScheduleBeforeSave(dbOP,request) != null)
		{
			//add the selected subjects here.
			if(enrlAddDropSub.addSubject(dbOP,request)) {
				dbOP.forceAutoCommitToTrue();
				if(WI.fillTextValue("no_charge").equals("1") && !strSchCode.startsWith("UC"))
					strErrMsg = "Subject/s added successfully.";
				else {
					if(!FFM.chargeAddDropFeeApplicable(dbOP, (String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
						WI.fillTextValue("semester"), (String)vStudInfo.elementAt(4), (String)request.getSession(false).getAttribute("userIndex"), true, request)) {
						strErrMsg = "Subjects Added Successfully. But Add Charge Failed to post to ledger. Please manually post.";
					}
					else
						strErrMsg = "Subject/s added successfully.";
				}
//				strErrMsg = "Subject/s added successfully.";
			}
			else
			{
				strErrMsg = enrlAddDropSub.getErrMsg();
				bolFatalErr = true;
			}
		}
		else
		{
			bolFatalErr = true;
			strErrMsg =advising.getErrMsg();
		}
	}
	if(!bolFatalErr) // show enrolled list
	{
		vEnrolledList = enrlAddDropSub.getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2],false,true);
//		System.out.println(vEnrolledList);
		if(vEnrolledList ==null)
		{//System.out.println("step - 3");
			//bolFatalErr = true;
			strErrMsg = enrlAddDropSub.getErrMsg();
			//This happens only if student has drop all.
			vEnrolledList = new Vector();vEnrolledList.addElement("0");
		}
		//else
		{
			vAdviseList = advising.getAdvisingListForOLD(dbOP,strStudID,(String)vStudInfo.elementAt(5),(String)vStudInfo.elementAt(6),true,
						request.getParameter("sy_from"),request.getParameter("sy_to"), (String)vStudInfo.elementAt(7),
						(String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(4),request.getParameter("semester"));
			if(vAdviseList ==null)
				strErrMsg = advising.getErrMsg();
			//System.out.println(strErrMsg);
		}
	}
}
if(vStudInfo != null && vStudInfo.size() > 0)
{
	strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",
                                       (String)vStudInfo.elementAt(5), "degree_type",
                                       " and is_valid=1 and is_del=0");

	if(strDegreeType == null)
		strErrMsg = "Error in getting course degree type.";
	else
	{
		if(strDegreeType.compareTo("1") == 0)
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./add_subject_masteral.jsp?no_charge="+WI.fillTextValue("no_charge")+"&stud_id="+strStudID+"&sy_from="+
				WI.fillTextValue("sy_from")+ "&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")+"&online_advising="+WI.fillTextValue("online_advising")));

			return;
		}
		else if(strDegreeType.compareTo("2") == 0)
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./add_subject_medicine.jsp?no_charge="+WI.fillTextValue("no_charge")+"&stud_id="+strStudID+"&sy_from="+WI.fillTextValue("sy_from")+
			"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")+"&online_advising="+WI.fillTextValue("online_advising")));

			return;
		}
	}
}



String strReadOnlyUnitToTake = "";
if(strSchCode.startsWith("UB") || bolIsOnlineAdvising )
	strReadOnlyUnitToTake = " readonly='yes' style='border:0px;' ";
	
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


String strNSTPDefaultVal = null;
if(strSchCode.startsWith("NEU") && vStudInfo != null && vStudInfo.size() > 0) {
	strNSTPDefaultVal = "select nstp_val from enrl_final_cur_list where is_temp_stud = 0 and user_index = "+
							vStudInfo.elementAt(0)+" and nstp_val is not null order by enroll_index desc";
	//System.out.println(strNSTPDefaultVal);
	strNSTPDefaultVal = dbOP.getResultOfAQuery(strNSTPDefaultVal, 0);
}

String strBlockSection = WI.fillTextValue("block_sec");

boolean bolIsEligibleForBlock = true;
String strIsBlockFoced = "0";
Vector vForcedBlock = null;
if(vEnrolledList != null && vEnrolledList.size() > 2) {
	bolIsEligibleForBlock = false;
}
else if( vAdviseList != null && vAdviseList.size() > 0) {
	enrollment.SubjectSection SS = new enrollment.SubjectSection();
	
	vForcedBlock = SS.getForcedBlockSectionList(dbOP, request, request.getParameter("sy_from"), request.getParameter("semester"));
	
	//get if not eligible..
	//System.out.println(vAdviseList);
	bolIsEligibleForBlock = SS.isStudentAllowedForBlock(dbOP, request, request.getParameter("semester"), (String)vStudInfo.elementAt(4), 
								(String)vStudInfo.elementAt(5), (String)vStudInfo.elementAt(6), (String)vStudInfo.elementAt(7), (String)vStudInfo.elementAt(8), 
								vAdviseList);
	
	 //System.out.println(bolIsEligibleForBlock);
	//I have to make bolIsForecedBlock to true if block section is selcted. 
	if(vForcedBlock != null && vForcedBlock.size() > 0) {
		if(strBlockSection.length() > 0) 
			strIsBlockFoced = "1";
	}
}
%>


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
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//if units to take is null or zero, give error.
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function VerifyNotNull(index)
{
	var unitToTake = eval('document.chngsubject.ut'+index+'.value');
	if(unitToTake.length ==0) // || Number(unitToTake) <0.5) updated for english +
	{
		alert("Please enter a unit to take.");
		//eval('document.chngsubject.ut'+index+'.focus()');
	}
}
/**
* call this function when input box is changed.
*/
var inFocusInputLoadVal = 0;

function SaveInputUnit(index)
{
	inFocusInputLoadVal = eval('document.chngsubject.ut'+index+'.value');
}
function ChangeLoad(index)
{
	var maxAllowedInputLoad = eval('document.chngsubject.total_unit'+index+'.value');
	var inputLoad = eval('document.chngsubject.ut'+index+'.value');
	var maxAllowedLoad = document.chngsubject.maxAllowedLoad.value;
	var totalLoad = Number(document.chngsubject.sub_load.value) - Number(inFocusInputLoadVal);

	if(Number(inputLoad) > Number(maxAllowedInputLoad))
	{
		eval('document.chngsubject.ut'+index+'.value='+inFocusInputLoadVal);
		return;
	}
	if( eval("document.chngsubject.checkbox"+index+".checked") )
	{
		document.chngsubject.sub_load.value =Number(document.chngsubject.sub_load.value) - Number(inFocusInputLoadVal)+Number(inputLoad);
	}
	inFocusInputLoadVal = inputLoad;
}

function ReloadPage()
{
	this.SubmitOnce('chngsubject');
}
function AddSubject() {
	if(document.chngsubject.reason) {
		//must enter reason.. 
		var strReason = document.chngsubject.reason.value;
		if(strReason.length < 5) {
			alert("Please encode a valid reason");
			return;
		}	
	}
	document.chngsubject.addSubject.value="1";
	document.chngsubject.hide_save.src = "../../../images/blank.gif";
	ReloadPage();
}
function AddLoad(index,subLoad)
{
	//if there is no section schedule yet - do not let user select.
	if(eval('document.chngsubject.sec_index'+index+'.value.length') ==0)
	{
		alert("Please schedule first before selecting a subject.");
		eval("document.chngsubject.checkbox"+index+".checked=false");
		return;
	}

	if( eval("document.chngsubject.checkbox"+index+".checked") )
	{

		document.chngsubject.sub_load.value = Number(eval('document.chngsubject.ut'+index+'.value')) +Number(document.chngsubject.sub_load.value);
		//document.chngsubject.sub_load.value = eval(document.chngsubject.sub_load.value) + eval(subLoad);
		if( eval(document.chngsubject.sub_load.value) > eval(document.chngsubject.maxAllowedLoad.value))
		{
			alert("Student can't take more than allowed load <"+document.chngsubject.maxAllowedLoad.value+">.Please re-adjust load.");
			document.chngsubject.sub_load.value = eval(document.chngsubject.sub_load.value) - eval(subLoad);
			eval("document.chngsubject.checkbox"+index+".checked=false");
		}
	}
	else //subtract.
		document.chngsubject.sub_load.value =Number(document.chngsubject.sub_load.value) - Number(eval('document.chngsubject.ut'+index+'.value'));
		//document.chngsubject.sub_load.value = eval(document.chngsubject.sub_load.value) - eval(subLoad);


	if( eval(document.chngsubject.sub_load.value) < 0)
		document.chngsubject.sub_load.value = 0;

}
/**
function LoadPopup(secName,sectionIndex, strCurIndex) //curriculum index is different for all courses.
{
	var subSecList = "";
	var i = eval(document.chngsubject.maxDisplay.value)-eval(document.chngsubject.addSubCount.value);
	for(; i< document.chngsubject.maxDisplay.value; ++i)
	{
		if( eval('document.chngsubject.checkbox'+i+'.checked') )
		{//alert(eval('document.chngsubject.sec_index'+i+'.value'));
			if(subSecList.length ==0)
				subSecList =eval('document.chngsubject.sec_index'+i+'.value');
			else
				subSecList =subSecList+","+eval('document.chngsubject.sec_index'+i+'.value');
		}
	}

	if(subSecList.length == 0) subSecList = document.chngsubject.sub_sec_csv.value;
	else
		subSecList +=","+document.chngsubject.sub_sec_csv.value;
//alert(subSecList);
	var loadPg = "../advising/subject_schedule.jsp?form_name=chngsubject&cur_index="+strCurIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.chngsubject.sy_from.value+"&syt="+document.chngsubject.sy_to.value+"&semester="+document.chngsubject.semester.value+
		"&sec_index_list="+subSecList;
	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
**/
//set is_lab_only parameter
function SetIsLabOnly(strIndex) {
	if( eval('document.chngsubject.is_lab_only'+strIndex+'.checked') )
		eval('document.chngsubject.is_lec_only'+strIndex+'.checked=false')

	if( eval('document.chngsubject.is_lab_only'+strIndex+'.checked') )
		eval('document.chngsubject.IS_LAB_ONLY'+strIndex+'.value=1');
	else
		eval('document.chngsubject.IS_LAB_ONLY'+strIndex+'.value=0');
}
//set is_lec_only parameter
function SetIsLecOnly(strIndex) {
	if( eval('document.chngsubject.is_lec_only'+strIndex+'.checked') )
		eval('document.chngsubject.is_lab_only'+strIndex+'.checked=false')

	if( eval('document.chngsubject.is_lec_only'+strIndex+'.checked') )
		eval('document.chngsubject.IS_LAB_ONLY'+strIndex+'.value=2');
	else
		eval('document.chngsubject.IS_LAB_ONLY'+strIndex+'.value=0');
}
//set NO_CONFLICT parameter
function SetIsNoConflict(strIndex) {
	if( eval('document.chngsubject.no_conflict'+strIndex+'.checked') )
		eval('document.chngsubject.NO_CONFLICT'+strIndex+'.value=1');
	else
		eval('document.chngsubject.NO_CONFLICT'+strIndex+'.value=0');
}

function LoadPopup(secName,sectionIndex, strCurIndex, strSubIndex, strIndex) //curriculum index is different for all courses.
{
	<%if(strIsBlockFoced.equals("1")){%>
		alert("Individual Scheduling is locked.");
		return;
	<%}%>

//this will check conflict with the schedule of other subjects taken. pass user id, all the sub_section_index,
//if check box is not checked - it is considered as not selected.
	var subSecList        = "";
	var strLabList        = "";
	var strNoConflictList = "";
	var strSemester;
	var strSubSecStartsWith = "";
	if(eval('document.chngsubject.sec'+strIndex+'.value.length') > 0)
		strSubSecStartsWith = eval('document.chngsubject.sec'+strIndex+'.value');


	strSemester = document.chngsubject.semester[document.chngsubject.semester.selectedIndex].value;

	for(var i = 0; i< document.chngsubject.maxDisplay.value; ++i)
	{
		if( eval('document.chngsubject.checkbox'+i+'.checked') ||
			eval('document.chngsubject.checkbox'+i+'.value.length > 0'))
		{

			if(subSecList.length ==0)
				subSecList =eval('document.chngsubject.sec_index'+i+'.value');
			else
				subSecList =subSecList+","+eval('document.chngsubject.sec_index'+i+'.value');
		}
		//for lab
		if( eval('document.chngsubject.checkbox'+i+'.checked')  ||
			eval('document.chngsubject.checkbox'+i+'.value.length > 0'))
		{
			if (eval('document.chngsubject.IS_LAB_ONLY'+i)){
				if(strLabList.length ==0)
					strLabList =eval('document.chngsubject.IS_LAB_ONLY'+i+'.value');
				else
					strLabList =strLabList+","+
								eval('document.chngsubject.IS_LAB_ONLY'+i+'.value');
			}
		}
		//for is no conflict.
		if( eval('document.chngsubject.checkbox'+i+'.checked')  ||
			eval('document.chngsubject.checkbox'+i+'.value.length > 0'))
		{
			if (eval('document.chngsubject.NO_CONFLICT'+i)){
				if(strNoConflictList.length ==0)
					strNoConflictList =eval('document.chngsubject.NO_CONFLICT'+i+'.value');
				else
					strNoConflictList =strNoConflictList+","+
									eval('document.chngsubject.NO_CONFLICT'+i+'.value');
			}
		}
	}
	if(subSecList.length == 0) subSecList = "0";

	var loadPg = "../advising/subject_schedule.jsp?form_name=chngsubject&cur_index="+strCurIndex+
		"&sub_index="+strSubIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.chngsubject.sy_from.value+"&syt="+document.chngsubject.sy_to.value+"&semester="+strSemester+
		"&sec_index_list="+subSecList+"&course_index="+document.chngsubject.ci.value+
		"&major_index="+document.chngsubject.mi.value+"&degree_type="+document.chngsubject.degree_type.value+
		"&IS_FOR_LAB="+eval('document.chngsubject.IS_LAB_ONLY'+strIndex+'.value')+
		"&lab_list="+strLabList+"&NO_CONFLICT="+
		eval('document.chngsubject.NO_CONFLICT'+strIndex+'.value')+"&no_conflict_list="+
		strNoConflictList+"&sec_startsWith="+escape(strSubSecStartsWith) +
		"&year_level=" + document.chngsubject.year_level.value+"&line_number="+strIndex+"&online_advising="+document.chngsubject.online_advising.value;

	if (eval('document.chngsubject.nstp_val'+strIndex)){
		loadPg += "&nstp_val=" + eval('document.chngsubject.nstp_val'+
						strIndex + '[document.chngsubject.nstp_val'+strIndex+'.selectedIndex].text');
	}

	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,top=10,left=10,scrollbars=yes,,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	<%if(!bolIsOnlineAdvising){%>
	document.chngsubject.stud_id.focus();
	<%}%>
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=chngsubject.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function GoToDrop() {

	location = "./change_subject_drop.jsp?sy_from="+document.chngsubject.sy_from.value+"&sy_to="+document.chngsubject.sy_to.value+
		"&semester="+document.chngsubject.semester[document.chngsubject.semester.selectedIndex].value+
		"&stud_id="+document.chngsubject.stud_id.value+"&online_advising="+document.chngsubject.online_advising.value;
}
function UpdateAddDropCount() {
	return;
	var obj = document.chngsubject.no_of_adddrop;
	if(!obj)
		return;
	if(document.chngsubject.no_of_adddrop_edited.value != '')
		return;
	
	var iCount = 0;
	for(var i = 0; i< document.chngsubject.maxDisplay.value; ++i) {
		if( eval('document.chngsubject.checkbox'+i+'.checked'))
			++iCount;
	}
	if(iCount > 0) 
		obj.value = iCount;

}
//// - all about ajax.. 
function AjaxMapName(strPos) {
<%if(!bolIsOnlineAdvising){%>
		var strCompleteName;
		strCompleteName = document.chngsubject.stud_id.value;
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
<%}%>
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.chngsubject.stud_id.value = strID;
	document.chngsubject.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.chngsubject.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
function PrintFinalClassSchedule() {
	var strStudID   = document.chngsubject.stud_id.value;
	var strSYFrom   = document.chngsubject.sy_from.value;
	var strSYTo     = document.chngsubject.sy_to.value;
	var strSemester = document.chngsubject.semester.value;
	
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


function BlockSection()
{
	var strMajorIndCon = document.chngsubject.mi.value;
	
	if(strMajorIndCon.length == 0)
		strMajorIndCon = "";
	else
		strMajorIndCon="&mi="+strMajorIndCon;
		
	var loadPg = "../advising/block_section.jsp?form_name=chngsubject&max_disp="+document.chngsubject.maxDisplay.value+"&ci="+
		document.chngsubject.ci.value+strMajorIndCon+"&syf="+document.chngsubject.syf.value+
	 	"&syt="+document.chngsubject.syt.value+"&sy_from="+document.chngsubject.sy_from.value+"&sy_to="+document.chngsubject.sy_to.value+
	 	"&offering_sem="+document.chngsubject.semester[document.chngsubject.semester.selectedIndex].value+
	 	"&year_level="+document.chngsubject.year_level.value+"&semester="+document.chngsubject.semester[document.chngsubject.semester.selectedIndex].value+
		"&cn=-&mn=-";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CallSelALL() {
	<%if(WI.fillTextValue("selAll").length() > 0) {%>
		document.chngsubject.selAll.checked = true;
		return checkAll();
	<%}%>
}
//this is the variable stores all the section_index stored so far.
function checkAll()
{
	var maxDisp = document.chngsubject.maxDisplay.value;
	var totalLoad = 0;
	//unselect if it is unchecked.
	if(!document.chngsubject.selAll.checked)
	{
		for(var i =0; i< maxDisp; ++i)
		{
			eval('document.chngsubject.checkbox'+i+'.checked=false');
			document.chngsubject.sub_load.value = 0;
		}
		return;
	}
	for(var i =0; i< maxDisp; ++i)
	{
<% if (strSchCode.startsWith("CPU")){%>
		if(	eval('document.chngsubject.sec_index'+i+'.value.length')> 0)
<%}else{%>
		if(	eval('document.chngsubject.sec'+i+'.value.length')> 0)
<%}%>	{
			//totalLoad += Number(eval('document.chngsubject.checkbox'+i+'.value'));
			totalLoad += Number(eval('document.chngsubject.ut'+i+'.value'));
		}
	}
	if(totalLoad > eval(document.chngsubject.maxAllowedLoad.value) )
	{
		alert("Student can't take more than allowed load <"+document.chngsubject.maxAllowedLoad.value+">.Please re-adjust load.");
		return;
	}
	else if(totalLoad == 0)
	{	
		alert("Please schedule to select student load.");
		document.chngsubject.selAll.checked = false;
		return;
	}
	//this is the time I will check all.
	for(var i =0; i< maxDisp; ++i)
	{
<% if (strSchCode.startsWith("CPU")){%>
		if(	eval('document.chngsubject.sec_index'+i+'.value.length')> 0)
<%}else{%>
		if(	eval('document.chngsubject.sec'+i+'.value.length')> 0)
<%}%>
		{
			eval('document.chngsubject.checkbox'+i+'.checked = true');
		}
	}
	document.chngsubject.sub_load.value = totalLoad;

}

</script>
<body bgcolor="#D2AE72" onLoad="FocusID();CallSelALL();">
<form action="./change_subject_add.jsp" method="post" name="chngsubject">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: CHANGE
          OF SUBJECTS - ADD ::::</strong></font></strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%" height="25">Enter Student ID </td>
      <td width="20%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.getStrValue(strStudID)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%if(bolIsOnlineAdvising) {%> style="border:0px; font-size:18px;" readonly="yes"<%}else{%> onKeyUp="AjaxMapName('1');"<%}%>>      </td>
      <td width="8%"><%if(!bolIsOnlineAdvising) {%><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a><%}%></td>
      <td width="35%" height="25"><input type="image" src="../../../images/form_proceed.gif" border="0">
	  
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
<%}%>	  </td>
      <td width="17%" align="right"><a href="javascript:GoToDrop();"><font style="font-size:11px; font-weight:bold; color:#FF0000">Go To Drop</font></a>&nbsp;</td>
    </tr>
    <tr>
      <td></td>
      <td colspan="5"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">School Year/Term </td>
      <td height="25" colspan="2"> 
	   <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("chngsubject","sy_from","sy_to")' <%if(bolIsOnlineAdvising){%> readonly='yes'<%}%>>
        to
        
		<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
<%if(bolIsOnlineAdvising){%>
		<option value="<%=strSemester%>"><%=astrConvertSem[Integer.parseInt(strSemester)]%></option>
<%}else{%>
          <option value="1">1st Sem</option>
<%
		 if(strSemester.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}

		  if (!strSchCode.startsWith("CPU")){
		    if(strSemester.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }if (strSemester.equals("0")){
		  %>
          <option value="0" selected>Summer</option>
		  <%}else{%>
          <option value="0">Summer</option>
		  <%}%>
<%}%>
        </select> </td>
      <td height="25" colspan="2">
	  	  	  <%if (strSchCode.startsWith("UC")) {%>
	  	<input type="button" name="122" value="Print Final Class Schedule" style="font-size:14px; height:28px;border: 1px solid #FF0000;" onClick="PrintFinalClassSchedule();">
	  <%}%>
	  </td>
    </tr>
  </table>
<% if(vStudInfo != null && vStudInfo.size() > 0 && !bolFatalErr){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td colspan="5"><hr size="1"></td>
    </tr>
    <tr >
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Student name </td>
      <td width="40%"> <strong><%=(String)vStudInfo.elementAt(1)%></strong>
	        <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">	  </td>
      <td width="14%">Date approved </td>
      <td width="25%">
<%
strTemp = WI.fillTextValue("apv_date");
if(strTemp.length() == 0 || bolIsOnlineAdvising)
	strTemp = WI.getTodaysDate(1);
%>	  <input name="apv_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%if(!bolIsOnlineAdvising){%>
       <a href="javascript:show_calendar('chngsubject.apv_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>	   </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major</td>
      <td height="25" colspan="3"><strong><%=(String)vStudInfo.elementAt(2)%>
        <%
		if(vStudInfo.elementAt(3) != null){%>
        / <%=(String)vStudInfo.elementAt(3)%>
        <%}%>
        </strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Year level</td>
      <td height="25" colspan="3"><strong><%=(String)vStudInfo.elementAt(4)%></strong>
	  <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(4)%>"></td>
    </tr>
    <tr >
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">SUBJECTS
          ENROLLED</font></div></td>
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
	    <input type="text" name="no_of_adddrop" size="3" value="1" <%if(!bolIsSuperUser && false){%>readonly="yes"<%}%> maxlength="2" style="font-weight:bold;font-size:18px; color:#0000FF;font-family:Verdana, Arial, Helvetica, sans-serif;" onKeyUp="document.chngsubject.no_of_adddrop_edited.value='1'">
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
      <td height="25">&nbsp;</td>
      <td  colspan="2" height="25">Maximum units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
      <td  colspan="2" height="25">Total student load :
<input type="text" name="sub_load" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;" value="<%=(String)vEnrolledList.elementAt(0)%>"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
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
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>
	 <% if (!strSchCode.startsWith("CPU")) {%>
	  SECTION / ROOM
	 <%}else{%>
	  ROOM
	 <%}%>
	  </strong></font></td>

      <td width="21%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
    </tr>
    <%
//		System.out.println(vEnrolledList);
String strBGColor = "";
 for(int i=1;i<vEnrolledList.size();++i,++j){
	 if(enrlAddDropSub.vDropSubList.indexOf(vEnrolledList.elementAt(i)) == -1) {///if W grade, do not check conflict.. 
		 if(strSubSecCSV == null)
			strSubSecCSV = (String)vEnrolledList.elementAt(i+5);
		 else
			strSubSecCSV += ","+(String)vEnrolledList.elementAt(i+5);
		strBGColor = "";
	 }
	 else	
	 	strBGColor = " bgcolor='#FF0000'";
 %>
    <tr<%=strBGColor%>>
      <td height="25" class="thinborder"><%=(String)vEnrolledList.elementAt(i+3)%></td>
      <td class="thinborder"><%=(String)vEnrolledList.elementAt(i+4)%></td>
	<% if(!strSchCode.startsWith("CPU")) {%>
      <td class="thinborder"><%=(String)vEnrolledList.elementAt(i+11)%></td>
      <td class="thinborder"><%=(String)vEnrolledList.elementAt(i+12)%></td>
	 <%}%>
      <td class="thinborder"><div align="center"><%=(String)vEnrolledList.elementAt(i+13)%></div></td>
	<% if (strSchCode.startsWith("CPU")){%>
      <td class="thinborder"><div align="center"><%=(String)vEnrolledList.elementAt(i+5)%></div></td>
	 <%}%>
      <td class="thinborder"><%=WI.getStrValue(vEnrolledList.elementAt(i+8),"N/A")%></td>
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
<%
if(vAdviseList != null && vAdviseList.size() > 0){%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18">&nbsp;</td>
    </tr>
<%if(bolIsEligibleForBlock) {%>
    <tr>
      <td height="18" align="right">
	  	<a href="javascript:BlockSection();"><img src="../../../images/bsection.gif" width="62" height="24" border="0"></a><font size="1">click for block sectioning</font>
	  </td>
    </tr>
<%}%>	
	<tr >
      <td height="25" bgcolor="#B9B292"><div align="center">SUBJECTS LIST ALLOWED TO ADD </div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25" align="center"><strong><font size="1">YEAR</font></strong></td>
      <td width="2%" height="25" align="center"><strong><font size="1">TERM</font></strong></td>
      <td width="12%" height="25" align="center"><strong><font size="1">SUBJECT
        CODE</font></strong></td>
      <td width="23%" align="center"><strong><font size="1">SUBJECT <strong>TITLE</strong></font></strong></td>
      <td width="5%" align="center"><strong><font size="1">LEC/LAB UNITS</font></strong></td>
      <td width="5%" align="center"><strong><font size="1">TOTAL UNITS</font></strong></td>
      <td width="5%" align="center"><strong><font size="1">UNITS TO TAKE</font></strong></td>
 <% if (!strSchCode.startsWith("CPU") && !strSchCode.startsWith("CIT") && !bolIsOnlineAdvising ) {%>
      <td width="5%" align="center"><font size="1"><strong>IS ONLY LAB</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>IS ONLY LEC</strong></font></td>
<%}
   if (strSchCode.startsWith("CPU"))
		strTemp = "STUB CODE";
	else
		strTemp = "SECTION";
%>

      <td width="12%" align="center"><strong><font size="1"><%=strTemp%></font></strong></td>
      <td width="20%" align="center"><strong><font size="1">SCHEDULE</font></strong></td>
      <td width="5%" align="center"><strong><font size="1">SELECT</font></strong>
	  
	  <input type="checkbox" name="selAll" value="0" 
		<%if(strIsBlockFoced.equals("1")){%>onClick="return false"<%}else{%>onClick="checkAll();"<%}%>>
		
		</td>
<%if(bolIsSuperUser){%>
      <td width="5%" align="center"><font size="1"><b>NO CONFLICT</b></font></td>
<%}%>
      <td width="5%" align="center"><strong><font size="1">ASSIGN SECTION</font></strong></td>
    </tr>
    <% int iTemp = 0;
for(int i = 0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed) {
	strTemp = null;
	
	if(strBlockSection.length()>0 && WI.getStrValue(vAdviseList.elementAt(i+1)).equals(WI.fillTextValue("year_level")) && 
									WI.fillTextValue("semester").equals(vAdviseList.elementAt(i+2)) ) {
		strTemp = advising.getSubSecIndex(dbOP,(String)vAdviseList.elementAt(i),strBlockSection,
						request.getParameter("sy_from"),
						request.getParameter("sy_to"),request.getParameter("semester"),
						strDegreeType);
		strTemp2 = strBlockSection;
	}
	if(strTemp == null)
		{strTemp2 = "";strTemp="";}

%>
    <tr onDblClick='LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>","<%=j%>");'
	 class="nav" id="msg<%=j%>" onMouseOver="navRollOver('msg<%=j%>', 'on')" onMouseOut="navRollOver('msg<%=j%>', 'off')">
      <td height="20" align="center">
        <!-- all the hidden fileds are here. -->
        <input type="hidden" name="year_level<%=j%>" value="<%=(String)vAdviseList.elementAt(i+1)%>">
        <input type="hidden" name="sem<%=j%>" value="<%=(String)vAdviseList.elementAt(i+2)%>">
        <input type="hidden" name="sub_code<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>">
        <input type="hidden" name="sub_name<%=j%>" value="<%=(String)vAdviseList.elementAt(i+7)%>">
        <input type="hidden" name="lab_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+4)%>">
        <input type="hidden" name="lec_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+3)%>">
        <input type="hidden" name="total_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>">
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vAdviseList.elementAt(i)%>">
        <%=(String)vAdviseList.elementAt(i+1)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+2)%></td>
      <td><%=(String)vAdviseList.elementAt(i+6)%>
<%if(((String)vAdviseList.elementAt(i+6)).indexOf("NSTP") != -1 || ((String)vAdviseList.elementAt(i+7)).indexOf("ROTC") != -1){

if(strNSTPDefaultVal != null)
	strNSTPDefaultVal = " where nstp_values.nstp_val = '"+strNSTPDefaultVal+"' ";
else	
	strNSTPDefaultVal = "";
%>
        <select name="nstp_val<%=j%>" style="font-weight:bold;">
<%=dbOP.loadCombo("distinct NSTP_VAL","NSTP_VAL"," from NSTP_VALUES "+strNSTPDefaultVal+" order by NSTP_VALUES.NSTP_VAL asc", WI.fillTextValue("nstp_val"), false)%>
        </select>
        <%}//only if subject is NSTP %>      </td>
      <td><%=(String)vAdviseList.elementAt(i+7)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+3)%>/<%=(String)vAdviseList.elementAt(i+4)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+5)%></td>
      <td align="center"><input type="text" value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>" name="ut<%=j%>" size="4" class="textbox"
onFocus="style.backgroundColor='#D3EBFF'; javascript:SaveInputUnit(<%=j%>);"
onBlur="style.backgroundColor='white'; AllowOnlyFloat('chngsubject','ut<%=j%>');VerifyNotNull(<%=j%>);"
	   onKeyUp='AllowOnlyFloat("chngsubject","ut<%=j%>");ChangeLoad("<%=j%>");' <%=strReadOnlyUnitToTake%>></td>

<% if (!strSchCode.startsWith("CPU") && !strSchCode.startsWith("CIT") && !bolIsOnlineAdvising ) {%>
      <td align="center">
        <%
	  if(vAdviseList.elementAt(i+4) != null && Float.parseFloat((String)vAdviseList.elementAt(i+4)) > 0f &&
	     vAdviseList.elementAt(i+3) != null && Float.parseFloat((String)vAdviseList.elementAt(i+3)) > 0f /**&&
		 Float.parseFloat((String)vAdviseList.elementAt(i+8)) > 0f**/ ){%>
        <input type="checkbox" value="1" name="is_lab_only<%=j%>" onClick="SetIsLabOnly(<%=j%>);">
        <%}else{%>
        <!--<img src="../../../images/x.gif">-->
        &nbsp;
        <%}%>      </td>
      <td align="center">
        <%
	  if(vAdviseList.elementAt(i+4) != null && Float.parseFloat((String)vAdviseList.elementAt(i+4)) > 0f &&
	     vAdviseList.elementAt(i+3) != null && Float.parseFloat((String)vAdviseList.elementAt(i+3)) > 0f /**&&
		 Float.parseFloat((String)vAdviseList.elementAt(i+8)) > 0f**/ ){%>
        <input type="checkbox" value="1" name="is_lec_only<%=j%>" onClick="SetIsLecOnly(<%=j%>);">
        <%}else{%>
        &nbsp;
        <%}%>      </td>
<%} %>
      <td> <input type="hidden" name="IS_LAB_ONLY<%=j%>" value="0">


<% if (strSchCode.startsWith("CPU")){
		strInputType = "hidden";
		strInputTypeDetails = "";
	}else{
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;\"";
	}
%>
	  <input type="<%=strInputType%>" name="sec<%=j%>" <%=strInputTypeDetails%> <%if(bolIsOnlineAdvising){%>readonly='yes'<%}%> value="<%=strTemp2%>">
<%
	if (strSchCode.startsWith("CPU")){
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;\"";
	}else{
		strInputType = "hidden";
		strInputTypeDetails = "";
	}
%>
	  <input type="<%=strInputType%>" name="sec_index<%=j%>"  <%=strInputTypeDetails%> value="<%=strTemp%>">

<!--
	  <input type="text" name="sec<%//=j%>" size="12" readonly="yes" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;">
        <input type="hidden" name="sec_index<%//=j%>">
-->	  </td>
      <td><label id="_<%=j%>" style="font-size:11px;"></label></td>
      <td align="center"> <input type="checkbox" name="checkbox<%=j%>"
	  value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>"
	  <%if(strIsBlockFoced.equals("1")){%>onClick="return false"<%}else{%>onClick='AddLoad("<%=j%>","<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>")'<%}%>>      </td>
<%if(bolIsSuperUser){%>
      <td align="center">
	  <input type="checkbox" value="1" name="no_conflict<%=j%>" onClick="SetIsNoConflict(<%=j%>);"></td>
<%}%>
<input type="hidden" name="NO_CONFLICT<%=j%>" value="0">
      <td align="center"><a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>","<%=j%>");'><img src="../../../images/schedule.gif" width="40" height="20" border="0"></a></td>
    </tr>
    <% i = i+9;}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="2" valign="top">&nbsp;</td>
    </tr>
<%if(bolIsAllowedToAddDrop) {%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="20%" valign="top"><%if(bolReasonRequired){%>Reason for dropping: <%}%></td>
      <td width="40%" valign="top"><%if(bolReasonRequired){%><textarea name="reason" cols="40" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("reason")%></textarea><%}%></td>
      <td width="36%" valign="bottom">
	  <a href="javascript:AddSubject();">
	  <img src="../../../images/save.gif" border="0" name="hide_save" onClick="UpdateAddDropCount();"></a>
	  <font size="1">Click to save added subjects</font>
	  </td>
    </tr>
<%}%>
  </table>
<input type="hidden" name="ci" value="<%=(String)vStudInfo.elementAt(5)%>">
<input type="hidden" name="mi" value="<%=WI.getStrValue(vStudInfo.elementAt(6))%>">

<%
	}//if vAdviseLIst is not null.
}//only if student information is not null
%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%if(vStudInfo != null && vStudInfo.size() > 0) {%>
<input type="hidden" name="syf" value="<%=vStudInfo.elementAt(7)%>">
<input type="hidden" name="syt" value="<%=vStudInfo.elementAt(8)%>">
<%}%>

<input type="hidden" name="addSubject" value="0">
<input type="hidden" name="maxAllowedLoad" value="<%=strMaxAllowedLoad%>">
<input type="hidden" name="sub_sec_csv" value="<%=strSubSecCSV%>">
<input type="hidden" name="maxDisplay" value="<%=j%>">
<input type="hidden" name="addSubCount" value="<%=iMaxDisplayed%>">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">

<input type="hidden" name="no_charge" value="<%=WI.fillTextValue("no_charge")%>">
<input type="hidden" name="no_of_adddrop_edited" value="">
<input type="hidden" name="online_advising" value="<%=WI.fillTextValue("online_advising")%>">
<input type="hidden" name="block_sec"><!-- contains value for block section.-->

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
