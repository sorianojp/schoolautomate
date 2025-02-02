<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strStudID = WI.fillTextValue("stud_id");
	
	int iMaxDisplayed = 0;
	boolean bolFatalErr = false;
	String strInputType ="";
	String strInputTypeDetails ="";
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");	
		
	if (strSchCode == null)
		strSchCode = "";	
		
	String strDegreeType = null;

	Vector[] vAutoAdvisedList = new Vector[2];
	String[] astrSchYrInfo = {(String)request.getSession(false).getAttribute("cur_sch_yr_from"),
								(String)request.getSession(false).getAttribute("cur_sch_yr_to"),
								(String)request.getSession(false).getAttribute("cur_sem")};
								
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	
	boolean bolIsCalledFrOnlineRegdStud = false;
	if(WI.fillTextValue("online_advising").compareTo("1") ==0)
		bolIsCalledFrOnlineRegdStud = true;
	
	if (strSchCode.startsWith("CPU")){ // for block sectioning
		strTemp = "_cpu";
	}else{
		strTemp = "";
	}
	
	boolean bolSameStudent = false;
	if (WI.fillTextValue("stud_id").equals(WI.fillTextValue("prev_id"))){
		bolSameStudent = true;
	}

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Advising Old Students</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//if units to take is null or zero, give error.
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
function ChangeLoad(index)
{
	var maxAllowedInputLoad = eval('document.advising.total_unit'+index+'.value');
	var inputLoad = eval('document.advising.ut'+index+'.value');
	var maxAllowedLoad = document.advising.maxAllowedLoad.value;
	var totalLoad = Number(document.advising.sub_load.value) - Number(inFocusInputLoadVal);

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


//this is the variable stores all the section_index stored so far.
function checkAll()
{
	var maxDisp = document.advising.maxDisplay.value;
	var totalLoad = 0;
	//unselect if it is unchecked.
	if(!document.advising.selAll.checked)
	{
		for(var i =0; i< maxDisp; ++i)
		{
			eval('document.advising.checkbox'+i+'.checked=false');
			document.advising.sub_load.value = 0;
		}
		return;
	}
	for(var i =0; i< maxDisp; ++i)
	{
<% if (strSchCode.startsWith("CPU")){%>
		if(	eval('document.advising.sec_index'+i+'.value.length')> 0)
<%}else{%>
		if(	eval('document.advising.sec'+i+'.value.length')> 0)
<%}%>	{
			//totalLoad += Number(eval('document.advising.checkbox'+i+'.value'));
			totalLoad += Number(eval('document.advising.ut'+i+'.value'));
		}
	}
	if(totalLoad > eval(document.advising.maxAllowedLoad.value) )
	{
		alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load.");
		return;
	}
	else if(totalLoad == 0)
	{
		alert("Please schedule to select student load.");
		document.advising.selAll.checked  = false;
		return;
	}
	//this is the time I will check all.
	for(var i =0; i< maxDisp; ++i)
	{
<% if (strSchCode.startsWith("CPU")){%>
		if(	eval('document.advising.sec_index'+i+'.value.length')> 0)
<%}else{%>
		if(	eval('document.advising.sec'+i+'.value.length')> 0)
<%}%>
		{
			eval('document.advising.checkbox'+i+'.checked = true');
		}
	}
	document.advising.sub_load.value = totalLoad;

}
function ShowList()
{
	document.advising.showList.value = 1;
	document.advising.autoAdvise.value = 0;
	//this.SubmitOnce('advising');
	ReloadPage();
}
function AutoAdvise()
{
	document.advising.autoAdvise.value = 1;
	document.advising.showList.value = 0;
	ReloadPage();//this.SubmitOnce('advising');
}
function ViewAllAllowedList()
{
	document.advising.viewAllAllowedList.value = 1;
	ReloadPage();//this.SubmitOnce('advising');
}

function AddRecord()
{
	document.advising.addRecord.value = 1;
	ReloadPage();//this.SubmitOnce('advising');
}

function ViewCurriculumEval() {
	var pgLoc = "../../registrar/residency/stud_cur_residency_eval.jsp?stud_id="+
	escape(document.advising.stud_id.value)+ "&online_advising="+document.advising.online_advising.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
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
	pgLoc += "&online_advising="+document.advising.online_advising.value;
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
	var pgLoc = "../../registrar/residency/residency_status.jsp?stud_id="+escape(document.advising.stud_id.value)+
	"&online_advising="+document.advising.online_advising.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
/**
*	This displays Total load of the subjects seleced so far
*/
function AddLoad(index,subLoad)
{
//alert(subLoad+",,, "+document.advising.sub_load.value);

	//add if clicked and if not clicked remove it.
	if( eval("document.advising.checkbox"+index+".checked") )
	{


		document.advising.sub_load.value = 
<% if (strSchCode.startsWith("CPU")) { %>
							Number(eval(subLoad)) +
<%}else{%> 
							Number(eval('document.advising.ut'+index+'.value')) +
<%}%> 
							Number(document.advising.sub_load.value);
		//before --> document.advising.sub_load.value = Number(document.advising.sub_load.value) + Number(subLoad);
		if( Number(document.advising.sub_load.value) > Number(document.advising.maxAllowedLoad.value))
		{
			alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load.");
			document.advising.sub_load.value = eval(document.advising.sub_load.value) - eval(subLoad);
			eval("document.advising.checkbox"+index+".checked=false");
		}
	}
	else //subtract.
		document.advising.sub_load.value =Number(document.advising.sub_load.value) - 
<% if (strSchCode.startsWith("CPU")) { %>
										Number(eval(subLoad));
<%}else{%> 
										Number(eval('document.advising.ut'+index+'.value'));
<%}%> 

		//before -- document.advising.sub_load.value = Number(document.advising.sub_load.value) - Number(subLoad);

	if( Number(document.advising.sub_load.value) < 0)
		document.advising.sub_load.value = 0;
}
//set is_lab_only parameter
function SetIsLabOnly(strIndex) {
	if( eval('document.advising.is_lab_only'+strIndex+'.checked') ) 
		eval('document.advising.is_lec_only'+strIndex+'.checked=false')
		
	if( eval('document.advising.is_lab_only'+strIndex+'.checked') ) 
		eval('document.advising.IS_LAB_ONLY'+strIndex+'.value=1');
	else	
		eval('document.advising.IS_LAB_ONLY'+strIndex+'.value=0');
}
//set is_lec_only parameter
function SetIsLecOnly(strIndex) {
	if( eval('document.advising.is_lec_only'+strIndex+'.checked') ) 
		eval('document.advising.is_lab_only'+strIndex+'.checked=false')
		
	if( eval('document.advising.is_lec_only'+strIndex+'.checked') ) 
		eval('document.advising.IS_LAB_ONLY'+strIndex+'.value=2');
	else	
		eval('document.advising.IS_LAB_ONLY'+strIndex+'.value=0');
}
//set NO_CONFLICT parameter
function SetIsNoConflict(strIndex) {
	if( eval('document.advising.no_conflict'+strIndex+'.checked') ) 
		eval('document.advising.NO_CONFLICT'+strIndex+'.value=1');
	else	
		eval('document.advising.NO_CONFLICT'+strIndex+'.value=0');
}

function LoadPopup(secName,sectionIndex, strCurIndex, strSubIndex, strIndex) //curriculum index is different for all courses.
{
//this will check conflict with the schedule of other subjects taken. pass user id, all the sub_section_index,
//if check box is not checked - it is considered as not selected.
	var subSecList        = "";
	var strLabList        = "";
	var strNoConflictList = "";
	var strSemester;
	var strSubSecStartsWith = "";
	if(eval('document.advising.sec'+strIndex+'.value.length') > 0)
		strSubSecStartsWith = eval('document.advising.sec'+strIndex+'.value');
	

	if(document.advising.online_advising.value == "1") 
		strSemester = document.advising.semester.value;
	else
		strSemester = document.advising.semester[document.advising.semester.selectedIndex].value;
	for(var i = 0; i< document.advising.maxDisplay.value; ++i)
	{
		if( eval('document.advising.checkbox'+i+'.checked') )
		{
			if(subSecList.length ==0)
				subSecList =eval('document.advising.sec_index'+i+'.value');
			else
				subSecList =subSecList+","+eval('document.advising.sec_index'+i+'.value');
		}
		//for lab
		if( eval('document.advising.checkbox'+i+'.checked') )
		{
			if(strLabList.length ==0)
				strLabList =eval('document.advising.IS_LAB_ONLY'+i+'.value');
			else
				strLabList =strLabList+","+eval('document.advising.IS_LAB_ONLY'+i+'.value');
		}
		//for is no conflict.
		if( eval('document.advising.checkbox'+i+'.checked') )
		{
			if(strNoConflictList.length ==0)
				strNoConflictList =eval('document.advising.NO_CONFLICT'+i+'.value');
			else
				strNoConflictList =strNoConflictList+","+eval('document.advising.NO_CONFLICT'+i+'.value');
		}
	}
	if(subSecList.length == 0) subSecList = "0";

	var loadPg = "./subject_schedule.jsp?form_name=advising&cur_index="+strCurIndex+
		"&sub_index="+strSubIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.advising.sy_from.value+"&syt="+document.advising.sy_to.value+"&semester="+strSemester+
		"&sec_index_list="+subSecList+"&course_index="+document.advising.ci.value+
		"&major_index="+document.advising.mi.value+"&degree_type="+document.advising.degree_type.value+
		"&online_advising="+document.advising.online_advising.value+
		"&IS_FOR_LAB="+eval('document.advising.IS_LAB_ONLY'+strIndex+'.value')+
		"&lab_list="+strLabList+"&NO_CONFLICT="+
		eval('document.advising.NO_CONFLICT'+strIndex+'.value')+"&no_conflict_list="+
		strNoConflictList+"&sec_startsWith="+escape(strSubSecStartsWith)+
		"&year_level="+document.advising.year_level.value;

//	alert(eval('document.advising.sub_code'+i+'.value'));

	if (eval('document.advising.nstp_val'+strIndex)){
		loadPg += "&nstp_val=" + eval('document.advising.nstp_val'+strIndex+	
										'[document.advising.nstp_val'+strIndex+'.selectedIndex].text');
	}

	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,top=10,left=10,scrollbars=yes,,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function Validate()
{
	var maxDisp  = document.advising.maxDisplay.value;
	if( Number(document.advising.sub_load.value) > Number(document.advising.maxAllowedLoad.value))
	{
		alert("Student can't take more than allowed load <" + document.advising.maxAllowedLoad.value +
				">.Please re-adjust load. Please check the load reference on top of this page.");
		return false;
	}

	var iOneChecked = 0;
	
	for(var i =0; i< maxDisp; ++i)
	{
		if (eval("document.advising.checkbox"+i+".checked")){
<% if (strSchCode.startsWith("CPU")) { %>
			if (eval("document.advising.sec_index"+i+".value.length") ==0){
				alert("Missing stub code for " + eval("document.advising.sub_code"+i+".value"));
				return; 
			} 
<%}else{%>
			if (eval("document.advising.sec"+i+".value.length") ==0){
				alert("Missing Section for " + eval("document.advising.sub_code"+i+".value"));
				return; 
			} 
<%}%> 
			iOneChecked++;
		}
	}
	
	if (iOneChecked != 0){ 
	
		document.advising.action="./gen_advised_schedule.jsp";
		this.SubmitOnce('advising');
		
	}else{
		alert("Select at least 1 subject to advise");
	}
}
function ReloadPage()
{
//	document.advising.action="";
	this.SubmitOnce('advising');
}
function BlockSection()
{
	var strMajorIndCon = document.advising.mi.value;
	
	if(strMajorIndCon.length == 0)
		strMajorIndCon = "";
	else
		strMajorIndCon="&mi="+strMajorIndCon;
		
	var loadPg = "./block_section<%=strTemp%>.jsp?form_name=advising&max_disp="+document.advising.maxDisplay.value+"&ci="+
		document.advising.ci.value+strMajorIndCon+"&syf="+document.advising.syf.value+
	 	"&syt="+document.advising.syt.value+"&sy_from="+document.advising.sy_from.value+"&sy_to="+document.advising.sy_to.value+
	 	"&offering_sem="+document.advising.semester.value+
	 	"&year_level="+document.advising.year_level.value+"&semester="+document.advising.semester.value+
		"&cn="+escape(document.advising.cn.value)+"&mn="+escape(document.advising.mn.value);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusID() {
	document.advising.stud_id.focus();
}
function OpenSearch() {
<%
	strTemp ="";
	if (WI.fillTextValue("sy_from").length() > 0) 
		strTemp = "&sy_from=" + WI.fillTextValue("sy_from");
	else 
		if (astrSchYrInfo!=null) 	
			strTemp = "&sy_from="+astrSchYrInfo[0];
	if (WI.fillTextValue("sy_to").length() > 0) 
		strTemp += "&sy_to=" + WI.fillTextValue("sy_to");
	else 
		if (astrSchYrInfo!=null) 	
			strTemp += "&sy_to="+astrSchYrInfo[1];
	if (WI.fillTextValue("semester").length() > 0) 
		strTemp += "&semester=" + WI.fillTextValue("semester");
	else 
		if (astrSchYrInfo!=null) 	
			strTemp += "&semester="+astrSchYrInfo[2];
%>
	var pgLoc = "../../../search/srch_stud_enrolled.jsp?opner_info=advising.stud_id&is_advised=1<%=strTemp%>";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function AddWorkingStudent(){
//	alert("hello");
	document.advising.add_working_stud.value=1;
	this.SubmitOnce('advising');
}

</script>
<%
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-advising-old","advising_old.jsp");
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
														"advising_old.jsp");

//if it is called from the online advising page of parent student, do not block,, force it to iAccessLevel = 2;
	if(bolIsCalledFrOnlineRegdStud)
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
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//I have to give an option to set do not check conflict incase user is super user.
boolean bolIsSuperUser = comUtil.IsSuperUser(dbOP,(String)request.getSession(false).getAttribute("userId"));
//end of authenticaion code.

String strMaxAllowedLoad = "0"; // this is the first field of the vAdvisingList
String strOverLoadDetail = null;//Overload detail if there is any.

boolean bolAutoAdvise = false;
boolean bolShowAdviseList = false;
boolean bolAllowAddStudent = false;
Vector vAdviseList = null;
Vector vStudInfo = null;

Vector vEnrolledList = null;

String strUserIndex  = null;

Advising advising = new Advising();
enrollment.AdvisingExtn advExtn = new enrollment.AdvisingExtn();
enrollment.WorkingStudent ws = new enrollment.WorkingStudent();


if(astrSchYrInfo == null)//db error
{
	strErrMsg = "You are logged out.Please login again.";
	bolFatalErr = true;
}
if (strStudID.length() > 0) {
	// check if student is a working student;
	vStudInfo = advising.getStudInfo(dbOP,strStudID,
										WI.fillTextValue("sy_from"),
										WI.fillTextValue("sy_to"),
										WI.fillTextValue("semester"));
	
	if(vStudInfo == null)
	{
		bolFatalErr = true;
		strErrMsg = advising.getErrMsg();
	}
	else
		strUserIndex = (String)vStudInfo.elementAt(0);

	// check if stduent is working student for this sem..	
	if (!bolFatalErr){
		if (WI.fillTextValue("add_working_stud").equals("1"))  { 
				if (ws.operateOnWorkingStudents(dbOP, request,WI.fillTextValue("stud_id"),
					WI.fillTextValue("sy_from"),WI.fillTextValue("semester"), 
					(String)vStudInfo.elementAt(10),1) != null) {
					strErrMsg = " Student added in working student lists";
				}else{
					bolFatalErr = true;
					strErrMsg = ws.getErrMsg();

				}
		}else{
				if(!ws.bolStudWorkingStudent(dbOP, strUserIndex, WI.fillTextValue("sy_from"),
								 WI.fillTextValue("semester"), (String)vStudInfo.elementAt(10))){
					bolFatalErr = true;
					bolAllowAddStudent = true;
					strErrMsg = ws.getErrMsg();
				}
		}
	}

}

if(!bolFatalErr && strStudID.length() > 0)
{
	strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",
                                      (String)vStudInfo.elementAt(2), "degree_type",
                                      " and is_valid=1 and is_del=0");

	if (strSchCode.startsWith("CPU") && !strDegreeType.equals("0")){
		strErrMsg = "Only undergrads allowed in Working Students";
		bolFatalErr = true;
	}
		
	if (!bolFatalErr) {
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,
										(String)vStudInfo.elementAt(2),
										(String)vStudInfo.elementAt(3),	WI.fillTextValue("sy_from"),
										WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(6),
										WI.fillTextValue("semester"),(String)vStudInfo.elementAt(4),
										(String)vStudInfo.elementAt(5), true);

		if(vMaxLoadDetail == null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();

		}
		else
		{
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
			if(vMaxLoadDetail.size() > 1)
				strOverLoadDetail = "Maximum load in curriculum for this sem " + 
					(String)vMaxLoadDetail.elementAt(1)+ " overloaded load "+
					(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+
					(String)vMaxLoadDetail.elementAt(2)+")";
		}
	}
	if(!bolFatalErr && WI.fillTextValue("showList").compareTo("1") ==0) // show list.
	{
		bolShowAdviseList = true;
		if(((String)vStudInfo.elementAt(11)).equals("Old")){
			vAdviseList = advising.getAdvisingListForOLD(dbOP,strStudID, request.getParameter("ci"),
							request.getParameter("mi"),false,request.getParameter("sy_from"),
							request.getParameter("sy_to"), request.getParameter("syf"),
							request.getParameter("syt"),request.getParameter("year_level"),
							request.getParameter("semester"),true);
			System.out.println("ari ko di sa old");

		}else if(((String)vStudInfo.elementAt(11)).startsWith("New")){ 
		
			vAdviseList = advising.getAdvisingListForNew(dbOP, request.getParameter("ci"),
			                request.getParameter("mi"), false,request.getParameter("sy_from"),
							request.getParameter("sy_to"),request.getParameter("semester"),
							request.getParameter("syf"),request.getParameter("syt"),
							request.getParameter("year_level"),
							 WI.fillTextValue("user_id"),true);//System.out.println(vAdviseList);
//			System.out.println("ari ko di sa new ");							 
			vAdviseList.removeElementAt(0); // remove the max # of units			
			
			
		}else if(((String)vStudInfo.elementAt(11)).equals("Transferee") || 
				(((String)vStudInfo.elementAt(11)).toLowerCase().indexOf("change") != -1) || 	
				(((String)vStudInfo.elementAt(11)).toLowerCase().indexOf("cross") != -1)){ 								

			System.out.println("ari ko di sa others ");

			vAdviseList = advising.getAdvisingListWOPreReq(dbOP, WI.fillTextValue("stud_id"),
							request.getParameter("ci"), request.getParameter("mi"), 
							request.getParameter("sy_from"), request.getParameter("sy_to"),
							 request.getParameter("syf"),request.getParameter("syt"),
							 request.getParameter("year_level"), request.getParameter("semester"), true);
 		}
		if(vAdviseList ==null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
		
//		System.out.println("vAdviseList: " + vAdviseList );
	}
	/*if(!bolFatalErr && WI.fillTextValue("block_sec").length()>0) // Block section is called - show the block section only for the year/sem the section is having block section.
	{
		strBlockSection = request.getParameter("block_sec");//because this is a block section, i can use any cur index -> (String)vAdviseList.elementAt(0), all the section are same.
		strBlockSecIndex = advising.getSubSecIndex(dbOP,(String)vAdviseList.elementAt(0),strBlockSection,
							request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));
		if(strBlockSecIndex == null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
	}*/
	if(!bolFatalErr && WI.fillTextValue("autoAdvise").compareTo("1") ==0)
	{
		bolAutoAdvise = true;bolShowAdviseList = true;
		vAutoAdvisedList = advising.autoAdviseForOLD(dbOP,strStudID,request.getParameter("ci"),
							request.getParameter("mi"),
							request.getParameter("sy_from"), request.getParameter("sy_to"),
							request.getParameter("syf"),request.getParameter("syt"),
							request.getParameter("year_level"),
							request.getParameter("semester"),request.getParameter("semester"));
							
		if(vAutoAdvisedList == null) {
			strErrMsg = advising.getErrMsg();
//			System.out.println("strErrMsg3 : " + strErrMsg);
		}else
			vAdviseList = vAutoAdvisedList[0];
	}
}

if(strErrMsg == null)
	strErrMsg = "";


if(!bolFatalErr && vStudInfo != null && vStudInfo.size() > 0) {
	vEnrolledList =  new enrollment.EnrlAddDropSubject().getEnrolledList(dbOP,
					(String)vStudInfo.elementAt(0),strDegreeType,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"),false,true);
}



// additional setting to force stop / or allow advising.. 
// setting is in System Admin -> Set param -> Enrollment advising setting.
float fOutstanding      = 0f;

//check if student is having outstanding balance.
if(!bolFatalErr && vStudInfo != null && vStudInfo.size() > 0) {
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0), WI.fillTextValue("sy_from"),
								WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
								
	fOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));
	
	enrollment.SetParameter sParam = new enrollment.SetParameter();
	bolShowAdviseList = sParam.allowAdvising(dbOP, (String)vStudInfo.elementAt(0), (double)fOutstanding, 
											WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
	if(!bolShowAdviseList){
		strErrMsg = sParam.getErrMsg();
//		System.out.println("strErrMsg4 : " + strErrMsg);
	}
//	System.out.println(bolShowAdviseList);
}

if(strErrMsg == null)
	strErrMsg = "";

//I show complete residency status of student if called in CPU.
boolean bolShowResidency = false;

String strAuthTypeIndex = WI.getStrValue(request.getSession(false).getAttribute("authTypeIndex"),"0");
Vector vCPUSubCodeSubSecList = null;

///check if called from CPU>

if(strSchCode != null && strSchCode.startsWith("CPU"))
	bolShowResidency = true;

if (!bolFatalErr && strSchCode.startsWith("CPU") && WI.fillTextValue("block_sec").length() > 0){

	vCPUSubCodeSubSecList = advExtn.getBlockSectionCPU(dbOP, WI.fillTextValue("sy_from"),
														WI.fillTextValue("sy_to"), WI.fillTextValue("semester"),
														WI.fillTextValue("block_sec"));
	if (vCPUSubCodeSubSecList == null){
		strErrMsg = advExtn.getErrMsg();
//		System.out.println("strErrMsg5 : " + strErrMsg);
	}
}	

if(strAuthTypeIndex.compareTo("4") !=0){
%>
<body bgcolor="#D2AE72" onLoad="focusID();">

<%}else{//student logged in for online advising  %>
<body bgcolor="#9FBFD0" >

<%}%>


<form name="advising" method="post" action="./advising_working_stud.jsp">
	<input type="hidden" name="add_working_stud" value="0">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%//change color if student logged in for online admission.%>
    <tr bgcolor="#A49A6A">
	<td height="25" colspan="3" align="center"><strong> <font color="#FFFFFF"> 
        :::: <%=WI.fillTextValue("pgDisp")%>  ADVISING PAGE :::: </font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 2);
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%}%>
  </table>
<%
if(!bolIsCalledFrOnlineRegdStud) {//show input only if it is not called from online registration of student.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="19%" height="25">Temp / Stud &nbsp;&nbsp; ID </td>
      <td width="18%" height="25"> <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="4%" height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" ></a> 
      </td>
      <td width="22%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a> 
      &nbsp;</td>
<% if (vEnrolledList != null)
		strTemp = "class=\"thinborderALL\"";
	else
		strTemp = ""; %>
	  
      <td width="36%" <%=strTemp%>>&nbsp; 
        <%if(vEnrolledList != null){%>
        <font size="3" color="#0000FF"><b>Student is advised already.</b></font> 
        <%}%>
      </td>
    </tr>
    <tr> 
      <td width="1%" height="24">&nbsp;</td>
      <td width="19%" height="24">School Year/Term </td>
      <td height="24" colspan="4"> <%
	  strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() ==0) 
	  	strTemp = astrSchYrInfo[0];
	  %>
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("advising","sy_from","sy_to")'> <%
	  strTemp = WI.fillTextValue("sy_to");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[1];
	  %>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp; <select name="semester" onChange="ReloadPage();">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = astrSchYrInfo[2];
if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")){
			  if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
          }%>
        </select> <input type="hidden" name="offering_sem_name" value="<%=astrConvertSem[Integer.parseInt(strTemp)]%>"> 
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%if (bolAllowAddStudent) {%> 
	  	<a href="javascript:AddWorkingStudent()"><img src="../../../images/update.gif" border=0 width="60" height="26"></a><font size="1">click to add working student </font> 
<%}%> 
		
	  </td>
    </tr>
  </table>
<%}else {//show now fixed information of student%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="19%" height="25">Student ID</td>
      <td width="62%" height="25"> <strong><font size="3"><%=strStudID%></font></strong> 
	  <input type="hidden" name="stud_id" value="<%=strStudID%>"></td>
      <td width="18%" colspan="2"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="19%" height="25">School Year/Term </td>
      <td height="25"> <font size="3"><strong><%=astrSchYrInfo[0]%> - <%=astrSchYrInfo[1]%> 
        (<%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>)</strong></font> 
        <input type="hidden" name="sy_from" value="<%=astrSchYrInfo[0]%>"> 
		<input type="hidden" name="sy_to" value="<%=astrSchYrInfo[1]%>"> 
        <input type="hidden" name="semester" value="<%=astrSchYrInfo[2]%>"> </td>
      <td colspan="2">&nbsp; </td>
    </tr>
  </table>
<%}//end of showing fixed information.

if(bolFatalErr)
{
	dbOP.cleanUP();
	return;
}

if(vStudInfo != null && vStudInfo.size() > 0) { 
	if(fOutstanding > 0.1f || fOutstanding < -0.1f){%>
  <table width="100%" bgcolor="#FFFFFF"><tr><td>
  <table width="50%" bgcolor="#000000"><tr><td height="25" bgcolor="#FFFFFF">
	  <font size="4" color="red"><strong>OLD ACCOUNT 
        : <%=CommonUtil.formatFloat(fOutstanding,true)%></strong></font></td></tr></table>
</td></tr></table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="62%" height="25">Student name (first,middle,last) :<strong>
        <%=(String)vStudInfo.elementAt(1)%>
        <input name="stud_name" value="<%=(String)vStudInfo.elementAt(1)%>" type="hidden">
        </strong></td>
      <td  colspan="3" height="25">Year level: <strong><%=WI.getStrValue(vStudInfo.elementAt(6),"N/A")%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">Course/Major :<strong><%=(String)vStudInfo.elementAt(7)%>
        <%
		if(vStudInfo.elementAt(8) != null){%>
		/ <%=(String)vStudInfo.elementAt(8)%>
		<%}%>
		</strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Curriculum SY :<strong><%=(String)vStudInfo.elementAt(4)%>
        - <%=(String)vStudInfo.elementAt(5)%></strong></td>
      <td  colspan="2" height="26">&nbsp;</td>
      <td width="9%" height="26">&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3" height="25"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td  width="40%" height="25"><a href="javascript:ViewCurriculum();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click 
        to view student's curriculum</font></td>
      <td width="59%" height="25"> 
        <%if(bolShowResidency){%>
	  <a href="javascript:ViewResidency();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click 
        to view student's residency status</font>
		<%}
			
		if (strSchCode != null && !strSchCode.startsWith("CPU")) {
	%>
        <a href="javascript:ViewCurriculumEval();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click 
        to view residency evaluation page</font>
		<%}%>	  </td>
    </tr>
    <%
//I have to check here the downpayment rules. -- check READ_PROPERTY_FILE table.
boolean bolAllowAfterCheckDPRule = 
 advising.shouldWeAdviseCheckOnDownPmt(dbOP, (String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(0),
 WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
 if(!bolAllowAfterCheckDPRule) {
 	bolShowAdviseList = false;
  }else{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><a href="javascript:ShowList();"><img src="../../../images/show_list.gif" width="57" height="34" border="0"></a>
      <font size="1">Show list of subjects student may take for this term </font></td>
      <td>
	  
	<% if ( strSchCode != null && !strSchCode.startsWith("CPU")) {  %>
	  <a href="javascript:AutoAdvise();"><img src="../../../images/advise.gif" width="42" height="37" border="0"></a>
	  <font size="1">click to generate auto advise subjects</font>
	  
	<%}	if (strSchCode != null && strSchCode.startsWith("CPU")) { 	%>
        <a href="javascript:ViewCurriculumEval();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>
		<font size="1">click to view residency evaluation page</font>
	<%}%>	  </td>
    </tr>
 <%}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="2"><font size="3"><%=strErrMsg%></font></td>
    </tr>
  </table>
<%if(bolShowAdviseList && vAdviseList != null && vAdviseList.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <!-- For new it is not required.
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td  colspan="" width="24%" height="25">&nbsp;</td>
      <td colspan="6" height="25"><a href="javascript:ViewAllAllowedList();"><font size="1"><img src="../../../images/view.gif" width="40" height="31" border="0"></font></a><font size="1">click
        to view other subejcts without pre-requisite if student is still under
        load </font></td>
    </tr> -->
    <tr bgcolor="#B9B292">
      <td height="25" colspan="4"><div align="center">LIST OF SUBJECTS THE STUDENT
          MAY TAKE</div></td>
    </tr>
<%
if(strOverLoadDetail != null){%>
    <tr>
      <td  height="25">&nbsp;</td>
      <td colspan="3" height="25"><font size="1">Overload detail : <%=strOverLoadDetail%></font></td>
    </tr>
<%}%>
    <tr>
      <td width="2%"  height="25">&nbsp;</td>
      <td height="25">Max units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
      <td width="32%" height="25" >Total student load:
<%
//if advised already, i have to use it.
if(vEnrolledList != null && vEnrolledList.size() > 0 && WI.fillTextValue("block_sec").length() == 0) 
	strTemp = (String)vEnrolledList.remove(0);
else	
	strTemp = "0";
%>	  
        <input type="text" name="sub_load" value="<%=strTemp%>" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;"></td>
      <td width="30%">
	  <a href="javascript:BlockSection();"><img src="../../../images/bsection.gif" width="62" height="24" border="0"></a>
	  <font size="1">click for block sectioning</font></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="7%" height="25" align="center"><font size="1"><strong>YEAR</strong></font></td>
      <td width="7%" height="25" align="center"><font size="1"><strong>TERM</strong></font></td>
      <td width="12%" height="25" align="center"><font size="1"><strong>SUBJECT 
        CODE</strong></font></td>
      <td width="23%" align="center"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>LEC/LAB UNITS</strong></font></td>
      <td width="9%" align="center"><font size="1"><strong>BUS. UNITS </strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>UNITS TO TAKE</strong></font></td>
 <% if (!strSchCode.startsWith("CPU")) {%>
      <td width="6%" align="center"><font size="1"><strong>IS ONLY LAB</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>IS ONLY LEC</strong></font></td>
<% } if (strSchCode.startsWith("CPU")) 
		strTemp = "STUB CODE";
	else
		strTemp = "SECTION";
%>
	<td width="12%" align="center"><font size="1"><strong><%=strTemp%></strong></font></td>
      <td width="6%" align="center"><strong><font size="1">SELECT 
<% if (!strSchCode.startsWith("CPU")) {%>ALL <br><%}%></font></strong>       
         <input type="checkbox" name="selAll" value="0" onClick="checkAll();">      </td>
      <%if(bolIsSuperUser){%>
      <td width="6%" align="center"><font size="1"><b>NO CONFLICT</b></font></td>
      <%}%>
      <td width="8%" align="center"><font size="1"><strong>ASSIGN SECTION</strong></font></td>
    </tr>
    <% int iTemp = 0;
String strBlockSection = WI.fillTextValue("block_sec");
//if student is already advised... 
String strEnrolledNSTPVal = null;
String strUnitEnrolled    = null; 
String strLecLabStat      = null; int iIndexOf = 0;
String strLecLabSelect    = null; String strTemp3 = null;
boolean bolAuthCheckBox   = false;



for(int i = 0,j=0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed)
{
	strTemp = ""; strTemp2 = "";strUnitEnrolled = null;strLecLabStat = "0";strLecLabSelect = "";bolAuthCheckBox   = false;
	if(vAutoAdvisedList[1] != null && (iTemp = vAutoAdvisedList[1].indexOf(vAdviseList.elementAt(i+6))) != -1)
	{
		strTemp = (String)vAutoAdvisedList[1].elementAt(iTemp-2); //section index.
		strTemp2 = (String)vAutoAdvisedList[1].elementAt(iTemp-1);//section name.
	}
	else if(strBlockSection.length() > 0)//check if block section is called.if so - then display the section information only if the block section available for the year and the section
	{
		//check if year and sem are same as it is for block sections.
		if(WI.fillTextValue("year_level").compareTo((String)vAdviseList.elementAt(i+1)) == 0 &&
			WI.fillTextValue("semester").compareTo((String)vAdviseList.elementAt(i+2)) == 0
			&& !strSchCode.startsWith("CPU"))//matching ;-)
		{
			strTemp2 = strBlockSection;
			strTemp = advising.getSubSecIndex(dbOP,(String)vAdviseList.elementAt(i),strBlockSection,request.getParameter("sy_from"),
							request.getParameter("sy_to"),request.getParameter("semester"),strDegreeType);
		}

		if (strSchCode.startsWith("CPU") && vCPUSubCodeSubSecList != null){
			iIndexOf = vCPUSubCodeSubSecList.indexOf((String)vAdviseList.elementAt(i+6));
			if (iIndexOf != -1){
				strTemp = (String)vCPUSubCodeSubSecList.elementAt(iIndexOf +1);
			}else{
				strTemp = null;
			}
		}
		
		if(strTemp == null){
			strTemp2 = "";
			strTemp="";
		}

	}
	else if(vEnrolledList != null && vEnrolledList.size() > 0) {
		iIndexOf = vEnrolledList.indexOf((String)vAdviseList.elementAt(i+7));//sub name.
		if(iIndexOf != -1 && !((String)vEnrolledList.elementAt(iIndexOf - 1)).startsWith((String)vAdviseList.elementAt(i+6))) 
			iIndexOf = vEnrolledList.indexOf((String)vAdviseList.elementAt(i+7),iIndexOf+1);
		if(iIndexOf != -1 && !((String)vEnrolledList.elementAt(iIndexOf - 1)).startsWith((String)vAdviseList.elementAt(i+6))) 
			iIndexOf = vEnrolledList.indexOf((String)vAdviseList.elementAt(i+7),iIndexOf+1);
			
		if(iIndexOf != -1 && ((String)vEnrolledList.elementAt(iIndexOf - 1)).startsWith((String)vAdviseList.elementAt(i+6))) {//subject matching.
			strTemp2 = (String)vEnrolledList.elementAt(iIndexOf + 3);
			strTemp  = (String)vEnrolledList.elementAt(iIndexOf + 1);
			strUnitEnrolled    = (String)vEnrolledList.elementAt(iIndexOf + 9);
			strEnrolledNSTPVal = (String)vEnrolledList.elementAt(iIndexOf - 1);
			strLecLabStat      = (String)vEnrolledList.elementAt(iIndexOf + 10);bolAuthCheckBox = true;
			if(strEnrolledNSTPVal.endsWith("CWTS"))
				 strEnrolledNSTPVal = "CWTS";
			else if(strEnrolledNSTPVal.endsWith("LTS"))
				 strEnrolledNSTPVal = "LTS";
			else if(strEnrolledNSTPVal.endsWith("ROTC"))
				 strEnrolledNSTPVal = "ROTC";
			else if(strEnrolledNSTPVal.endsWith("MTS"))
				 strEnrolledNSTPVal = "MTS";
			else	
			 	strEnrolledNSTPVal = null;
			iIndexOf = iIndexOf - 4;
			vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);
			vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);
			vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);
			vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);
			vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);
		}
	}
%>
    <tr> 
      <td height="25" align="center"> 
        <!-- all the hidden fileds are here. -->
        <input type="hidden" name="year_level<%=j%>" value="<%=WI.getStrValue(vAdviseList.elementAt(i+1))%>"> 
        <input type="hidden" name="sem<%=j%>" value="<%=(String)vAdviseList.elementAt(i+2)%>"> 
        <input type="hidden" name="sub_code<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>"> 
        <input type="hidden" name="sub_name<%=j%>" value="<%=(String)vAdviseList.elementAt(i+7)%>"> 
        <input type="hidden" name="lab_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+4)%>"> 
        <input type="hidden" name="lec_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+3)%>"> 
        <input type="hidden" name="total_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>"> 
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vAdviseList.elementAt(i)%>">
        <%=WI.getStrValue(vAdviseList.elementAt(i+1),"N/A")%></td>
      <td align="center"><%=WI.getStrValue(vAdviseList.elementAt(i+2),"N/A")%></td>
      <td><%=(String)vAdviseList.elementAt(i+6)%> 
	  <%if(((String)vAdviseList.elementAt(i+6)).indexOf("NSTP") != -1){
if(strEnrolledNSTPVal == null)
	strEnrolledNSTPVal = WI.fillTextValue("nstp_val");
%> <select name="nstp_val<%=j%>" style="font-weight:bold;">
          <%=dbOP.loadCombo("distinct NSTP_VAL","NSTP_VAL"," from NSTP_VALUES order by NSTP_VALUES.NSTP_VAL asc", strEnrolledNSTPVal, false)%> </select> <%}//only if subject is NSTP %> </td>
      <td><%=(String)vAdviseList.elementAt(i+7)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+3)%>/<%=(String)vAdviseList.elementAt(i+4)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+5)%></td>
      <td align="center"> 
<%

if (bolSameStudent) 
	strTemp3 = WI.fillTextValue("ut"+j);
else
	strTemp3 = "";

if(strTemp3.length() ==0 && strUnitEnrolled == null) {
	if(((String)vStudInfo.elementAt(11)).equals("Old"))
		strTemp3 = Float.toString(Float.parseFloat((String)vAdviseList.elementAt(i+3))
					+ Float.parseFloat((String)vAdviseList.elementAt(i+4)));
	else
	if(((String)vStudInfo.elementAt(11)).equals("New"))
		strTemp3 = Float.toString(Float.parseFloat((String)vAdviseList.elementAt(i+3))
					+ Float.parseFloat((String)vAdviseList.elementAt(i+4)));	
}
else if(strTemp3.length() ==0)	
	strTemp3 = strUnitEnrolled;

if(strLecLabStat.equals("1"))
	strLecLabSelect = " checked";
else	
	strLecLabSelect = "";


%>
<input type="text" value="<%=strTemp3%>" name="ut<%=j%>" size="3" maxlength="3" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'; javascript:SaveInputUnit(<%=j%>);" onBlur="style.backgroundColor='white'; javascript:VerifyNotNull(<%=j%>);"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" onKeyUp='ChangeLoad("<%=j%>");'></td>
      <% if (!strSchCode.startsWith("CPU")) {%>
      <td align="center"> <%
	  if(vAdviseList.elementAt(i+4) != null && Float.parseFloat((String)vAdviseList.elementAt(i+4)) > 0f &&
	     vAdviseList.elementAt(i+3) != null && Float.parseFloat((String)vAdviseList.elementAt(i+3)) > 0f /**&&
		 Float.parseFloat((String)vAdviseList.elementAt(i+8)) > 0f**/ ){%> 
		 <input type="checkbox" value="1" name="is_lab_only<%=j%>" onClick="SetIsLabOnly(<%=j%>);"<%=strLecLabSelect%>> 
        <%}else{%> 
        <!--<img src="../../../images/x.gif">-->
        &nbsp; <%}%> 
      <td align="center">
        <%
	  if(vAdviseList.elementAt(i+4) != null && Float.parseFloat((String)vAdviseList.elementAt(i+4)) > 0f &&
	     vAdviseList.elementAt(i+3) != null && Float.parseFloat((String)vAdviseList.elementAt(i+3)) > 0f /**&&
		 Float.parseFloat((String)vAdviseList.elementAt(i+8)) > 0f**/ ){
		 
		 if(strLecLabStat.compareTo("2") == 0)
			strLecLabSelect = " checked";
		else	
			strLecLabSelect = "";
		 %>
        <input type="checkbox" value="1" name="is_lec_only<%=j%>" onClick="SetIsLecOnly(<%=j%>);"<%=strLecLabSelect%>> 
        <%}else{%>
        &nbsp; 
        <%}%>      </td>
<%} %>
      <td> <input type="hidden" name="IS_LAB_ONLY<%=j%>" value="<%=strLecLabStat%>">
<% if (strSchCode.startsWith("CPU")){
		strInputType = "hidden";
		strInputTypeDetails = "";
	}else{
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;\"";
	}
%>	  
	  <input type="<%=strInputType%>" value="<%=strTemp2%>" name="sec<%=j%>" <%=strInputTypeDetails%> > 
<% 
	if (strSchCode.startsWith("CPU")){
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;\"";
	}else{
		strInputType = "hidden";
		strInputTypeDetails = "";
	}
%>
	    
	  <input type="<%=strInputType%>" value="<%=strTemp%>" name="sec_index<%=j%>" 
			<%=strInputTypeDetails%>>      </td>
      <td align="center"> 
<%
if(bolAuthCheckBox)
	strTemp = " checked";
else	
	strTemp = "";
	
	
%>
	  <input type="checkbox"<%=strTemp%> name="checkbox<%=j%>"
	  value="<%=(String)vAdviseList.elementAt(i+5)%>"
	  onClick='AddLoad("<%=j%>","<%=(String)vAdviseList.elementAt(i+5)%>")'> 
        <input type="hidden" name="NO_CONFLICT<%=j%>" value="0">
	</td>
      <%if(bolIsSuperUser){%>
      <td align="center"> <input type="checkbox" value="1" name="no_conflict<%=j%>" onClick="SetIsNoConflict(<%=j%>);"></td>
      <%}%>
      <td align="center"><a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+8)%>","<%=j%>");'><img src="../../../images/schedule.gif" width="55" height="30" border="0"></a></td>
    </tr>
    <% i = i+9;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><div align="right"></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8"><div align="center"> <a href="javascript:Validate();"><img src="../../../images/form_proceed.gif" border="0"></a></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8">&nbsp; </td>
    </tr>
    <tr>
<%
if(strAuthTypeIndex.compareTo("4") ==0){//student logged in for online advising %>
    <tr bgcolor="#47768F">
<%}else{%>
    <tr bgcolor="#A49A6A">
<%}%>      <td height="25" colspan="8">&nbsp;</td>
    </tr>
  </table>
 <%}//end of displaying the advise list if bolShowAdviseList is TRUE
 %>
 <%
 //print error message if vAdviseList is null or not having any information.
 if(vAdviseList == null || vAdviseList.size() ==0)
 {
 strTemp = advising.getErrMsg();
 if(strTemp == null && (WI.fillTextValue("showList").compareTo("1") ==0 || WI.fillTextValue("autoAdvise").compareTo("1") ==0))
 	strTemp = "Please try again. If same Error continues please contact system admin to check error status.";
 if(strTemp == null) strTemp = "";
 %>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25"><strong><font size="3"><%=strTemp%></font></strong></td>
    </tr>
  </table>
 <%} // shows error message.%>



<!-- the hidden fields only if temp user exist -->
<input type="hidden" name="cn" value="<%=(String)vStudInfo.elementAt(7)%>">
<input type="hidden" name="ci" value="<%=(String)vStudInfo.elementAt(2)%>">
<input type="hidden" name="mn" value="<%=WI.getStrValue(vStudInfo.elementAt(8))%>">
<input type="hidden" name="mi" value="<%=WI.getStrValue(vStudInfo.elementAt(3))%>">
<input type="hidden" name="syf" value="<%=(String)vStudInfo.elementAt(4)%>">
<input type="hidden" name="syt" value="<%=(String)vStudInfo.elementAt(5)%>">
<input type="hidden" name="maxDisplay" value="<%=iMaxDisplayed%>"><!-- max number of entries displayed.-->
<input type="hidden" name="year_level" value="<%=WI.getStrValue(vStudInfo.elementAt(6))%>">
<input type="hidden" name="stud_type" value="<%=(String)vStudInfo.elementAt(10)%>">
<input type="hidden" name="prep_prop_status" value="">

<%
	//System.out.println(vStudInfo);
} // end of display - if student id is valid
%>

<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="showList" value="<%=WI.fillTextValue("showList")%>">
<input type="hidden" name="autoAdvise" value="<%=WI.fillTextValue("autoAdvise")%>">
<input type="hidden" name="viewAllAllowedLoad" value="<%=WI.fillTextValue("viewAllAllowedLoad")%>">
<input type="hidden" name="maxAllowedLoad" value="<%=strMaxAllowedLoad%>">
<input type="hidden" name="block_sec"><!-- contains value for block section.-->
<%
strTemp = WI.fillTextValue("accumulatedLoad");
if(strTemp.length() ==0)
	strTemp = "0";
%>
<input type="hidden" name="accumulatedLoad" value="<%=strTemp%>">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">
<input type="hidden" name="pgDisp" value="<%=WI.fillTextValue("pgDisp")%>">


<!-- for online registration i have to keep this information -->
<input type="hidden" name="online_advising" value="<%=WI.fillTextValue("online_advising")%>">

<% 
	if (bolSameStudent)
		strTemp = WI.fillTextValue("stud_id");
	else
		strTemp = "";
%>

<input type="hidden" name="prev_id" value="<%=strTemp%>">

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
