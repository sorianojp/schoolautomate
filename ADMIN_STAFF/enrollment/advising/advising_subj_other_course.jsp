<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function VerifyNotNull(index)
{
	var unitToTake = eval('document.advising.ut'+index+'.value');
	if(unitToTake.length ==0 || Number(unitToTake) <0.5)
	{
		alert("Please enter a unit to take.");
		eval('document.advising.ut'+index+'.focus()');
	}
}
/**
* call this function when input box is changed.
*/
var inFocusInputLoadVal = 0;
function SaveInputUnit(index)
{
	inFocusInputLoadVal = eval('document.advising.ut'+index+'.value');
}
function ChangeLoad(iMaxLoadForSub, index)
{
	var maxAllowedInputLoad = eval('document.advising.total_unit'+index+'.value');
	var inputLoad = eval('document.advising.ut'+index+'.value');
	var maxAllowedLoad = document.advising.maxAllowedLoad.value;
	var totalLoad = Number(document.advising.sub_load.value) - Number(inFocusInputLoadVal);

	//can't enter more unit than allowed.
	if(inputLoad> iMaxLoadForSub) {
		alert("Max units allowed for this subject :  "+iMaxLoadForSub);
		eval('document.advising.ut'+index+'.value='+inFocusInputLoadVal);
		return;
	}

	if(Number(inputLoad) > Number(maxAllowedInputLoad))
	{
		alert("Unit can't be more than "+maxAllowedInputLoad);
		eval('document.advising.ut'+index+'.value='+inFocusInputLoadVal);
		return;
	}
	if( eval("document.advising.checkbox"+index+".checked") )
	{
		document.advising.sub_load.value =Number(document.advising.sub_load.value) - Number(inFocusInputLoadVal)+Number(inputLoad);
	}
	inFocusInputLoadVal = inputLoad;
}
function AddSubject()
{
	document.advising.fake_focus.value = "1";
	document.advising.addSubject.value = 1;
	document.advising.submit();
}
function SaveLoad()
{
	if( eval(document.advising.sub_load_duplicate.value) > eval(document.advising.maxAllowedLoad.value)) {
		alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load.");
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
function LoadPopup(secName,sectionIndex, strCurIndex, strSubIndex, strIndexOf) //curriculum index is different for all courses.
{
//this will check conflict with the schedule of other subjects taken. pass user id, all the sub_section_index,
//if check box is not checked - it is considered as not selected.
	var subSecList = "";
	var i = eval(document.advising.maxDisplay.value)-eval(document.advising.addSubCount.value);
	for(; i< document.advising.maxDisplay.value; ++i)
	{
		if(i == strIndexOf)
			continue;
		if( eval('document.advising.checkbox'+i+'.checked') )
		{//alert(eval('document.advising.sec_index'+i+'.value'));
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

	var loadPg = "../advising/subject_schedule.jsp?form_name=advising&cur_index="+strCurIndex+
		"&sub_index="+strSubIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.advising.sy_from.value+"&syt="+document.advising.sy_to.value+"&semester="+document.advising.semester[document.advising.semester.selectedIndex].value+
		"&sec_index_list="+subSecList+"&course_index="+document.advising.ci.value+
		"&major_index="+document.advising.mi.value+"&degree_type="+document.advising.degree_type.value+"&year_level=" + 
		document.advising.year_level.value+"&line_number="+strIndexOf+"&add_oc=1";//add other course.

	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,top=10,left=10,scrollbars=yes,,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
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
		document.advising.sub_load.value = eval(document.advising.sub_load.value) + eval(inputLoad);
		if( eval(document.advising.sub_load.value) > eval(document.advising.maxAllowedLoad.value))
		{
			alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load.");
			document.advising.sub_load.value = eval(document.advising.sub_load.value) - eval(inputLoad);
			eval("document.advising.checkbox"+index+".checked=false");
		}
	}
	else //subtract.
		document.advising.sub_load.value = eval(document.advising.sub_load.value) - eval(inputLoad);


	if( eval(document.advising.sub_load.value) < 0)
		document.advising.sub_load.value = 0;
	document.advising.sub_load_duplicate.value = document.advising.sub_load.value;

}
function ViewCurriculumEval() {
	var pgLoc = "../../registrar/residency/stud_cur_residency_eval.jsp?stud_id="+escape(document.advising.stud_id.value);
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ViewCurriculum()
{
	var pgLoc = "";
	if(document.advising.mn.value.length > 0)
		pgLoc = "../../admission/curriculum_page1.jsp?ci="+document.advising.ci.value+"&cname="+
			escape(document.advising.cn.value)+"&mi="+document.advising.mi.value+"&mname="+escape(document.advising.mn.value)+"&syf="+
			document.advising.syf.value+"&syt="+document.advising.syt.value+"&goNextPage=1&degree_type="+document.advising.degree_type.value;
	else
		pgLoc = "../../admission/curriculum_page1.jsp?ci="+document.advising.ci.value+"&cname="+escape(document.advising.cn.value)+
			"&syf="+document.advising.syf.value+"&syt="+document.advising.syt.value+"&goNextPage=1&degree_type="+document.advising.degree_type.value;

	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ViewResidency()
{
	if(document.advising.stud_id.value.length ==0)
	{
		alert("Please enter student ID.");
		return;
	}
	var pgLoc = "../../registrar/residency/residency_status.jsp?stud_id="+escape(document.advising.stud_id.value);
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusID() {
	if(document.advising.stud_id.value.length == 0)
		document.advising.stud_id.focus();
}
function DelSubject(strEnrollRef) {
	if(!confirm('Are you sure you want to remove this enrolled subject.')) 
		return;
	document.advising.enroll_ref.value=strEnrollRef;
	document.advising.submit();
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
	String strInputType ="";
	String strInputTypeDetails ="";	
	String strTemp2 = null;
	String strSubSecCSV = null;//this is the subject section already enrolled in CSV to check the conflict ;-)
	String strAddedSubCSV = WI.fillTextValue("added_subject_csv");// list of all the subject added to the list

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

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
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
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

//end of authenticaion code.

float fMaxAllowedLoad = 0f; // this is the first field of the vAdvisingList
Vector vAdviseList = null;//filled up by auto advise, 0=sec index,1=section, 2=cur index.
Vector vStudInfo = null;
Vector vEnrolledList = null;

Vector vAllowedSubList = null;
Vector vAddedSubList   = null;


//System.out.println("Print : "+strAddedSubCSV);
if(WI.fillTextValue("addSubject").compareTo("1") == 0 && WI.fillTextValue("subject_offered").length() > 0) {
	if(strAddedSubCSV.length() > 0) 
		vAddedSubList = CommonUtil.convertCSVToVector(strAddedSubCSV);
	else
		vAddedSubList = new Vector();
	//System.out.println(vAddedSubList);
	
	if(vAddedSubList.indexOf(WI.fillTextValue("subject_offered")) == -1)
		vAddedSubList.addElement(WI.fillTextValue("subject_offered"));
	
	strAddedSubCSV = CommonUtil.convertVectorToCSV(vAddedSubList);
}
else if (strAddedSubCSV.length() > 0) 
	vAddedSubList = CommonUtil.convertCSVToVector(strAddedSubCSV);
	

boolean bolIsTempStud = false;
boolean bolFatalErr = false;
String  strSaveLoadMsg = null;//Message of save load action
String strMaxAllowedLoad = null;
String strOverLoadDetail = null;

///remove subject if delete is selected.. 
if(WI.fillTextValue("enroll_ref").length() > 0) {
	strTemp = "update enrl_final_cur_list set is_valid = 0, is_del = 1, last_mod_by = "+(String)request.getSession(false).getAttribute("userIndex")+
				",last_mod_date='"+WI.getTodaysDate(1)+"' where enroll_index = "+WI.fillTextValue("enroll_ref");
	dbOP.executeUpdateWithTrans(strTemp, null, null, false);	
	strTemp = null;			
}



Advising advising = new Advising();
AdvisingExtn advisingExtn = new AdvisingExtn();
enrollment.EnrlAddDropSubject enrlAddDropSub = new enrollment.EnrlAddDropSubject();

if(WI.fillTextValue("sy_from").length() ==0 || WI.fillTextValue("sy_to").length() ==0)
{
	strErrMsg = "Please enter School Year.";
	bolFatalErr = true;
}

if(!bolFatalErr && strStudID.length() > 0)
{
	vStudInfo = advising.getStudInfo(dbOP,strStudID, WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
										WI.fillTextValue("semester"));
	if(vStudInfo == null) {
		strErrMsg = advising.getErrMsg();
		bolFatalErr = true;
	}
	strTemp = dbOP.mapUIDToUIndex(strStudID);
	if(strTemp == null)
		bolIsTempStud = true;
	//check if student is allowed to enroll from other course -- student is not allowed if he is not advised his regular subjects.
	//NOTE UI - ALLOWS , so, i have to allow here. but i can give a message that no subject
	//is taken by the student... anytime if i want to stop, just uncomment the lines below
	/**
	if(!bolFatalErr) {
		if(advisingExtn.isEnrollingToOtherSubAllowed(dbOP,(String)vStudInfo.elementAt(0),bolIsTempStud,
                                              WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"), WI.fillTextValue("semester")) != 1) {
			//bolFatalErr = true;
			strErrMsg = advisingExtn.getErrMsg();
		}
	}**/
	if(!bolFatalErr) {//get max load information
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),
			WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(6),WI.fillTextValue("semester"),
			(String)vStudInfo.elementAt(4),	(String)vStudInfo.elementAt(5));
		if(vMaxLoadDetail == null) {
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
		else {
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
			if(vMaxLoadDetail.size() > 1) {
				if(!bolIsTempStud)
					strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
						" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
			}
			else {
				//if(strSchCode.startsWith("CIT"))
				//	strMaxAllowedLoad = Double.toString(Double.parseDouble(strMaxAllowedLoad) - 1);
			}						
		}
	}
	//add the subjects if clicked.
	if(!bolFatalErr && WI.fillTextValue("saveLoad").compareTo("1") ==0)
	{
		if(advising.checkScheduleBeforeSave(dbOP,request) != null)
		{
			//add the selected subjects here.
			if(advisingExtn.saveAdditionalLoad(dbOP,request,false)) {
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
		strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(2),
							"degree_type"," and is_valid=1 and is_del=0");

	if(!bolFatalErr) {//get coure degree type.
		vEnrolledList = enrlAddDropSub.getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),strDegreeType,
							WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"),bolIsTempStud,true);
		/* It can be empty.*/
		if(vEnrolledList ==null)
		{
			//bolFatalErr = true;
			//strErrMsg = enrlAddDropSub.getErrMsg();
			vEnrolledList = new Vector();
			vEnrolledList.addElement("0");
		}
	}
	//get the allowed subject list.
	if(!bolFatalErr && WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("0") != 0) {
		vAllowedSubList = advisingExtn.getAllowedSubList(dbOP,(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),
                                  WI.fillTextValue("course_index"),WI.getStrValue(WI.fillTextValue("major_index"),null),
                                  WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"),
                                  vAddedSubList,(String)vStudInfo.elementAt(4),
								  (String)vStudInfo.elementAt(5));

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
		//System.out.println(strSQLQuery);
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		vAllowedSubList = new Vector();
		while(rs.next()) {
			vAllowedSubList.addElement(rs.getString(1));
			vAllowedSubList.addElement(rs.getString(2));
		}
		rs.close();
	}
	
	//System.out.println("Added Sub List : "+vAddedSubList);
	if(!bolFatalErr && vAddedSubList != null && vAddedSubList.size() > 0) {
	
		//System.out.println("I am here.:"+vAddedSubList);
		vAdviseList = advisingExtn.getAdviseList(dbOP, strDegreeType,WI.fillTextValue("course_index"),
														WI.fillTextValue("major_index"), vAddedSubList);
		if(vAdviseList == null || vAdviseList.size() ==0)
			strErrMsg = advisingExtn.getErrMsg();
	}
}

//code added to block adding subjects for old student having balance, if no subject is yet advised.
if(!bolIsTempStud && vEnrolledList != null && vEnrolledList.size() == 1 && !strSchCode.startsWith("CIT")) {
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	fOperation.isEnrolling(true);
	
	double dOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));
	if(dOutstanding > 0d) {
		enrollment.SetParameter sParam = new enrollment.SetParameter();
		if(!sParam.allowAdvising(dbOP, (String)vStudInfo.elementAt(0), dOutstanding, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"))) {
			bolFatalErr = true;
			strErrMsg = "Not allowed to add subject. "+sParam.getErrMsg();
		}
	}
}

///i have to remove the subejct already enrolled. 
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
	
	
	
//for CIT, do not drop the subjects PE and NSTP if not added in excption.. 
Vector vSubjNotAllowedToDrop = new Vector();
if(!bolIsTempStud && strSchCode.startsWith("CIT") && vEnrolledList != null && vEnrolledList.size() > 0) {
	 int iYrLevel = Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(6),"0"));
	 if(iYrLevel >= 2) {
		String strSQLQuery = "select sub_code from subject where (sub_Code like 'pe%' or sub_code like 'nstp%') and is_del = 0 "+
			" and not exists (select * from CIT_DROP_NSTPPE_EXCEPTION where is_valid = 1 and SY_F = "+WI.fillTextValue("sy_from")+" and sem = "+WI.fillTextValue("semester")+
			" and sub_i = subject.sub_index and stud_index = "+vStudInfo.elementAt(0)+" and employee_index = "+(String)request.getSession(false).getAttribute("userIndex")+
			" and (last_date is null or last_date >='"+WI.getTodaysDate()+"')) order by sub_code";
		//System.out.println(strSQLQuery);
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			if(iYrLevel == 2 && rs.getString(1).startsWith("NSTP"))
				continue;
			vSubjNotAllowedToDrop.addElement(rs.getString(1));
		} 
		rs.close();
	 }
	 //System.out.println(vSubjNotAllowedToDrop);
}
%>

<body bgcolor="#D2AE72" onLoad="focusID();">
<form name="advising" action="./advising_subj_other_course.jsp" method="post">
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
      <td height="25">&nbsp;</td>
      <td height="35" colspan="3">NOTE: <font color="#0066FF"><strong>Use this
        advising page only if student is enrolling subject not in his/her curriculum.
        Enrolled subject will not be credited to any of his/her subject in his
        curriculum. </strong></font></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="30%" height="25">Enter Student ID (Temporary/Permanent)</td>
      <td height="25" colspan="2"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td height="25">School Year/Term</td>
      <td width="38%" height="25">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("advising","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        <select name="semester">
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
          <%}
		  if (!strSchCode.startsWith("CPU")) {
  		    if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }%>
        </select> </td>
      <td width="28%" height="25"><!--<a href="javascript:ReloadPage();">-->
	  <input type="image" src="../../../images/form_proceed.gif" border="0"
	  onClick="document.advising.addSubject.value='';document.advising.saveLoad.value='';document.advising.fake_focus.value='';">
        </a> </td>
    </tr>
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
  </table>
<% if(!bolFatalErr){//show everything below this.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="62%" height="25">Student name (first,middle,last) :<strong>

        <%=(String)vStudInfo.elementAt(1)%>
        <input name="stud_name" value="<%=(String)vStudInfo.elementAt(1)%>" type="hidden">
        </strong></td>
      <td height="25">Year level : <strong><%=WI.getStrValue(vStudInfo.elementAt(6),"N/A")%></strong>
        <input type="hidden" name="year_level" value="<%=WI.getStrValue(vStudInfo.elementAt(6))%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course :<strong><%=(String)vStudInfo.elementAt(7)%>
        <%
	  if(vStudInfo.elementAt(8) != null){%>
        /<%=WI.getStrValue(vStudInfo.elementAt(8))%>
		<%}%></strong></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Curriculum SY :<strong><%=(String)vStudInfo.elementAt(4)%>
        - <%=(String)vStudInfo.elementAt(5)%></strong></td>
      <td height="26">&nbsp;</td>
    </tr>
  </table>

<% if(vStudInfo != null && vStudInfo.size() > 0 && !bolFatalErr){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9"><div align="center">LIST OF SUBJECTS ADVISED
          ALREADY FOR THIS SEMESTER</div></td>
	        <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
    </tr>
<%
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
      <td width="11%" height="27" align="center" class="thinborder"><font size="1"><strong>SUBJECT
        CODE</strong></font></td>
      <td width="20%" align="center" class="thinborder"><font size="1"><strong>SUBJECT TITLE </strong></font></td>
	  <% if (!strSchCode.startsWith("CPU")){%> 
      <td width="4%" align="center" class="thinborder"><font size="1"><strong>LEC. UNITS</strong></font></td>
      <td width="4%" align="center" class="thinborder"><font size="1"><strong>LAB. UNITS</strong></font></td>
	  <%}%> 
      <td width="4%" align="center" class="thinborder"><font size="1"><strong> UNITS TAKEN</strong></font></td>
	<% if (strSchCode.startsWith("CPU")) {%>
     <td width="7%" align="center" class="thinborder"><font size="1"><strong>STUBCODE</strong></font></td>
	 <%}%> 
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>SECTION / ROOM</strong></font></td>
	  
      <td width="31%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>REMOVE</strong></font></td>
    </tr>
    <%
boolean bolAllowRemove = true;

 for(i=1,j=0;i<vEnrolledList.size();++i,++j){
 if(strSubSecCSV == null)
 	strSubSecCSV = (String)vEnrolledList.elementAt(i+5);
 else
 	strSubSecCSV += ","+(String)vEnrolledList.elementAt(i+5);
	
	bolAllowRemove = true;
	if( vSubjNotAllowedToDrop.indexOf(vEnrolledList.elementAt(i+3)) > -1)
		bolAllowRemove = false;
 %>
    <tr>
      <td height="25" class="thinborder"><%=(String)vEnrolledList.elementAt(i+3)%></td>
      <td class="thinborder"><%=(String)vEnrolledList.elementAt(i+4)%></td>
	<% if(!strSchCode.startsWith("CPU")) {%> 
      <td class="thinborder"><%=(String)vEnrolledList.elementAt(i+11)%></td>
      <td class="thinborder"><%=(String)vEnrolledList.elementAt(i+12)%></td>
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
	  <%}%></td>
      <td class="thinborder" onClick="<%if(bolAllowRemove){%>DelSubject('<%=vEnrolledList.elementAt(i)%>');<%}%>"><%if(bolAllowRemove){%><a href="javascript:#">Remove</a><%}else{%>Not Allowed<%}%></td>
    </tr>
    <%
i = i+14;
}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
<% if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UPH") || strSchCode.startsWith("CSA")) {%> 
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
      <td>&nbsp;</td>
      <td height="24" colspan="4">Course :
        <select name="course_index" onChange="ReloadPage();" style="font-size:11px;">
          <option value="0">Select Any</option>
          <%
//if course program is selected, then filter course offered displayed else, show all courses offered.
if(WI.fillTextValue("cc_index").length()>0 && WI.fillTextValue("cc_index").compareTo("0") != 0)
{
	strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and cc_index="+request.getParameter("cc_index")+
		  	" and degree_type = "+strDegreeType+" order by course_name asc" ;//not allowed to take subject from other degree course.
}
else
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and degree_type = "+strDegreeType+" order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, WI.fillTextValue("course_index"), false)%>
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
      <td height="25">&nbsp; </td>
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
        <%}%>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp;
	  <%
	  if(strSaveLoadMsg != null){%>
	  <font size="3"><strong><%=strSaveLoadMsg%></strong></font>
	  <%}%>	  </td>
  </table>
<%
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
	  <% if (!strSchCode.startsWith("CPU"))  {%>
	  SECTION<%}else{%>STUB CODE<%}%></font></strong></td>
      <td width="4%" align="center"><strong><font size="1">SELECT</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">ASSIGN SECTION</font></strong></td>
    </tr>
    <%
int iTemp = 0;
for(i = 0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed)
{strTemp = ""; strTemp2 = "";
%>
    <tr onDblClick='LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>", "<%=j%>");'>
      <td height="25" align="center"><%=(String)vAdviseList.elementAt(i+1)%> <input type="hidden" name="year_level<%=j%>" value="<%=(String)vAdviseList.elementAt(i+1)%>">
        <input type="hidden" name="sem<%=j%>" value="<%=(String)vAdviseList.elementAt(i+2)%>">
        <input type="hidden" name="sub_code<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>">
        <input type="hidden" name="sub_name<%=j%>" value="<%=(String)vAdviseList.elementAt(i+7)%>">
        <input type="hidden" name="lab_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+4)%>">
        <input type="hidden" name="lec_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+3)%>">
        <input type="hidden" name="total_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>">
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vAdviseList.elementAt(i)%>">
      </td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+2)%></td>
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
      <td align="center">
<!-- make it fixed.
	  <input type="text" value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>" name="ut<%=j%>" size="4" readonly="yes" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;"></td>
-->
<%
strTemp = Float.toString(Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8)));
%>
<input name="ut<%=j%>" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'; javascript:SaveInputUnit(<%=j%>);" onBlur="style.backgroundColor='white'; javascript:VerifyNotNull(<%=j%>);"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" onKeyUp='ChangeLoad("<%=strTemp%>","<%=j%>");' <%=strReadOnlyUnitToTake%>></td>

      <td> 
<% if (strSchCode.startsWith("CPU")){
		strInputType = "hidden";
		strInputTypeDetails = "";
	}else{
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;\"";
	}
%>	  
	  <input type="<%=strInputType%>" value="<%=WI.fillTextValue("sec"+ j)%>" name="sec<%=j%>" <%=strInputTypeDetails%> > 
<% 
	if (strSchCode.startsWith("CPU")){
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;\"";
	}else{
		strInputType = "hidden";
		strInputTypeDetails = "";
	}
%>
	    
	  <input type="<%=strInputType%>" value="<%=WI.fillTextValue("sec_index"+ j)%>" name="sec_index<%=j%>" 
			<%=strInputTypeDetails%>> 	  
	  
	  
	  
	  
	  </td>
      <td align="center"> <input type="checkbox" name="checkbox<%=j%>"
	  value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>"
	  onClick='AddLoad("<%=j%>","<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>")'>
      </td>
      <td align="center"><a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>", "<%=j%>");'><img src="../../../images/schedule.gif" width="55" height="30" border="0"></a></td>
    </tr>
    <% i += 9;}//end of for loop%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">
	  <div align="center"><a href="javascript:SaveLoad();">
	  	<img src="../../../images/save.gif" border="0" name="hide_save"></a>
          <font size="1">click to save subjects</font></div></td>
    </tr>
  </table>
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
 <input type="text" name="set_focus" size="1" maxlength="1" readonly
 	style="background-color: #D2AE72;border-style: inset;border-color: #D2AE72; border-width: 0px">

<%
if(WI.fillTextValue("fake_focus").compareTo("1") ==0){%>
<script language="JavaScript">
	document.advising.set_focus.focus();
</script>
<%}%>
<input type="hidden" name="added_subject_csv" value="<%=WI.getStrValue(strAddedSubCSV)%>">
<input type="hidden" name="addSubject">
<input type="hidden" name="fake_focus" value="<%=WI.fillTextValue("fake_focus")%>">

<input type="hidden" name="sub_sec_csv" value="<%=WI.getStrValue(strSubSecCSV)%>">
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

<input type="hidden" name="enroll_ref">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
