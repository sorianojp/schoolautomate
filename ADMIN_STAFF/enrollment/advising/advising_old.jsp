<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " buffer="16kb" %>
<%
	request.getSession(false).setAttribute("advising","1");
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
	String strInfo5 = WI.getStrValue((String)request.getSession(false).getAttribute("info5"));	
		
	if (strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");	
		
	String strDegreeType = null;

	Vector[] vAutoAdvisedList = new Vector[2];
	String[] astrSchYrInfo = {(String)request.getSession(false).getAttribute("cur_sch_yr_from"),
								(String)request.getSession(false).getAttribute("cur_sch_yr_to"),
								(String)request.getSession(false).getAttribute("cur_sem")};
								
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	if(WI.fillTextValue("sy_from").length() > 0) {
		astrSchYrInfo[0] = WI.fillTextValue("sy_from");
		astrSchYrInfo[1] = WI.fillTextValue("sy_to");
		astrSchYrInfo[2] = WI.fillTextValue("semester");
	}
	
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
boolean bolIsSuperUser = false;
if(!bolIsCalledFrOnlineRegdStud) 
	bolIsSuperUser = comUtil.IsSuperUser(dbOP,(String)request.getSession(false).getAttribute("userId"));
//end of authenticaion code.

String strMaxAllowedLoad = "0"; // this is the first field of the vAdvisingList
String strOverLoadDetail = null;//Overload detail if there is any.

boolean bolAutoAdvise = false;
boolean bolShowAdviseList = false;
Vector vAdviseList = new Vector();
Vector vStudInfo = new Vector();

Vector vEnrolledList = null;

String strUserIndex  = null;

//added for cit to for enroll in PE and NSTP subjects.
Vector vPENSTPSubToTake = new Vector();
boolean bolIsPEToTakeSet = false;
boolean bolIsNSTPToTakeSet = false;

Advising advising = new Advising();
enrollment.AdvisingExtn advExtn = new enrollment.AdvisingExtn();

if(bolIsCalledFrOnlineRegdStud)
		advising.setOnlineAdvising();//enables pre-req even if disabled

if(astrSchYrInfo == null)//db error
{
	strErrMsg = "You are logged out.Please login again.";
	bolFatalErr = true;
}
if(!bolFatalErr && strStudID.length() > 0)
{
	vStudInfo = advising.getOldStudInfo(dbOP,strStudID,
										WI.fillTextValue("sy_from"),
										WI.fillTextValue("sy_to"),
										WI.fillTextValue("semester"), true);
	if(vStudInfo == null)
	{
		bolFatalErr = true;
		strErrMsg = advising.getErrMsg();
	}
	else
		strUserIndex = (String)vStudInfo.elementAt(0);
	if(!bolFatalErr)
	{
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,
										(String)vStudInfo.elementAt(2),
										(String)vStudInfo.elementAt(3),	WI.fillTextValue("sy_from"),
										WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(6),
										WI.fillTextValue("semester"),(String)vStudInfo.elementAt(4),
										(String)vStudInfo.elementAt(5));//System.out.println(vMaxLoadDetail);
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
			else {
				//if(strSchCode.startsWith("CIT"))
				//	strMaxAllowedLoad = Double.toString(Double.parseDouble(strMaxAllowedLoad) - 1);
			}
		}
	}
	if(!bolFatalErr && WI.fillTextValue("showList").compareTo("1") ==0) // show list.
	{
		bolShowAdviseList = true;
		vAdviseList = advising.getAdvisingListForOLD(dbOP,strStudID, (String)vStudInfo.elementAt(2),
						(String)vStudInfo.elementAt(3),false,request.getParameter("sy_from"),
						request.getParameter("sy_to"), (String)vStudInfo.elementAt(4),
						(String)vStudInfo.elementAt(5),WI.getStrValue(vStudInfo.elementAt(6)),
						request.getParameter("semester"));
		//System.out.println(vAdviseList);
		if(vAdviseList ==null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
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
							
		if(vAutoAdvisedList == null) 
			strErrMsg = advising.getErrMsg();
		else
			vAdviseList = vAutoAdvisedList[0];
	}
}

if(strErrMsg == null)
	strErrMsg = "";

if(vStudInfo != null && vStudInfo.size() > 0)
{
	strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",
                                       (String)vStudInfo.elementAt(2), "degree_type",
                                       " and is_valid=1 and is_del=0");

	String strWindowWidth = WI.fillTextValue("win_width");

	if(strDegreeType == null)
		strErrMsg = "Error in getting course degree type.";
	else
	{
		if(strDegreeType.compareTo("1") == 0)
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./advising_masters_doctoral.jsp?stud_id="
			+strStudID+"&sy_from="+WI.fillTextValue("sy_from")+
			"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")+"&win_width="+strWindowWidth+"&online_advising="+WI.fillTextValue("online_advising")));

			return;
		}
		else if(strDegreeType.compareTo("2") == 0)
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./advising_medicine.jsp?stud_id="+
							strStudID+"&sy_from="+WI.fillTextValue("sy_from")+
							"&sy_to="+WI.fillTextValue("sy_to")+
							"&semester="+WI.fillTextValue("semester")+"&win_width="+strWindowWidth+"&online_advising="+WI.fillTextValue("online_advising")));
			return;
		}
		
		if(WI.fillTextValue("invalidate_advising").length() > 0) {
			enrollment.NAApplicationForm naApplForm = new enrollment.NAApplicationForm();
			if(!naApplForm.invalidateAdvising(dbOP, false, strStudID,
				(String)request.getSession(false).getAttribute("userId"), 
				(String)request.getSession(false).getAttribute("login_log_index"),WI.fillTextValue("sy_from"), 
				WI.fillTextValue("sy_to"), WI.fillTextValue("semester")) ) 
				strErrMsg = naApplForm.getErrMsg();
		}

				
		vEnrolledList =  new enrollment.EnrlAddDropSubject().getEnrolledList(dbOP,
						(String)vStudInfo.elementAt(0),strDegreeType,
						WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
						WI.fillTextValue("semester"),false,true);
		/*** add this code to include the subjects taken from other course to the list of advise subject.. **/
		//System.out.println(vEnrolledList.size());
		//System.out.println(vEnrolledList);
		if(vEnrolledList != null && vEnrolledList.size() > 0 && vAdviseList != null && vAdviseList.size() > 0) {
			int iIndexOfTemp = 0;
			Vector vTempEnrlList = new Vector();
			for(int i = 1; i < vEnrolledList.size(); i += 15) 
				vTempEnrlList.addElement(vEnrolledList.elementAt(i + 2));
			for(int i = 0; i < vAdviseList.size(); i += 10) {
				iIndexOfTemp = vTempEnrlList.indexOf(vAdviseList.elementAt(i + 9));
				if(iIndexOfTemp == -1)
					continue;
				vTempEnrlList.remove(iIndexOfTemp);
			}
			if(vTempEnrlList.size() > 0) {
				for(int i = 1; i < vEnrolledList.size(); i += 15) {
					iIndexOfTemp = vTempEnrlList.indexOf(vEnrolledList.elementAt(i + 2));
					if(iIndexOfTemp == -1)
						continue;					
					//I have to add here the subjects already enrolled but not from same course.. 
					vAdviseList.addElement(vEnrolledList.elementAt(i + 1));
					vAdviseList.addElement(null);
					vAdviseList.addElement(null);
					vAdviseList.addElement(vEnrolledList.elementAt(i + 11));
					vAdviseList.addElement(vEnrolledList.elementAt(i + 12));
					vAdviseList.addElement(vEnrolledList.elementAt(i + 13));
					vAdviseList.addElement(vEnrolledList.elementAt(i + 3));
					vAdviseList.addElement(vEnrolledList.elementAt(i + 4));
					vAdviseList.addElement("0");
					vAdviseList.addElement(vEnrolledList.elementAt(i + 2));
				}			
			}
		}
		/*** End of code to include the subjects taken from other course to the list of advise subject.. **/


	}
}

// additional setting to force stop / or allow advising.. 
// setting is in System Admin -> Set param -> Enrollment advising setting.
double dOutstanding      = 0d;

//check if student is having outstanding balance.
if(vStudInfo != null && vStudInfo.size() > 0) {
	if(!bolIsCIT) {
		enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0), WI.fillTextValue("sy_from"),
									WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
		dOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));
	}
	enrollment.SetParameter sParam = new enrollment.SetParameter();
	if(!strSchCode.startsWith("PHILCST")) {
		bolShowAdviseList = sParam.allowAdvising(dbOP, (String)vStudInfo.elementAt(0), dOutstanding, 
												WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
		if(!bolShowAdviseList)
			strErrMsg = sParam.getErrMsg();
	}
	//System.out.println(bolShowAdviseList);
	//System.out.println(sParam.getErrMsg());
	
}

if(strErrMsg == null)
	strErrMsg = "";

String strReadOnlyUnitToTake = "";
if(strSchCode.startsWith("UB") || bolIsCalledFrOnlineRegdStud )
	strReadOnlyUnitToTake = " readonly='yes' style='border:0px;' ";

//I show complete residency status of student if called in CPU.
boolean bolShowResidency = false;

String strAuthTypeIndex = WI.getStrValue(request.getSession(false).getAttribute("authTypeIndex"),"0");
Vector vCPUSubCodeSubSecList = null;

boolean bolIsForwarded = WI.fillTextValue("is_forwarded").equals("1");




//if true, user is advising for block section alone.. 
boolean bolIsEligibleForBlock = true;
String strIsBlockFoced = "0";
boolean bolIsBlockSectionActive = false;
Vector vForcedBlock = null;
if( vAdviseList != null && vAdviseList.size() > 0) {
	enrollment.SubjectSection SS = new enrollment.SubjectSection();
	
	vForcedBlock = SS.getForcedBlockSectionList(dbOP, request, request.getParameter("sy_from"), request.getParameter("semester"));
	
	//get if not eligible..
	//System.out.println(vAdviseList);
	bolIsEligibleForBlock = SS.isStudentAllowedForBlock(dbOP, request, request.getParameter("semester"), (String)vStudInfo.elementAt(6), 
								(String)vStudInfo.elementAt(2), (String)vStudInfo.elementAt(3), (String)vStudInfo.elementAt(4), (String)vStudInfo.elementAt(5), 
								vAdviseList);
	//System.out.println("vAdviseList: "+vAdviseList);
	 
	//I have to make bolIsForecedBlock to true if block section is selcted. 
	if(vForcedBlock != null && vForcedBlock.size() > 0) {
		bolIsBlockSectionActive = true;
		
		if(WI.fillTextValue("block_sec").length() > 0) 
			strIsBlockFoced = "1";
		else if(vEnrolledList != null && vEnrolledList.size() > 0) {
			//I have to check if enrolled/advised in blocked section.
			for(int abc = 1; abc < vEnrolledList.size(); abc += 15) {
				//System.out.println(vEnrolledList.elementAt(abc + 7));
				if(vForcedBlock.indexOf(vEnrolledList.elementAt(abc + 7)) > -1) {
					strIsBlockFoced = "1";
					break;
				}
			}
		}
	}
}



String strNSTPDefaultVal = null;
if(true || strAuthTypeIndex.compareTo("4") !=0){
///check if called from CPU>

if(strSchCode.startsWith("CPU") || bolIsCIT)
	bolShowResidency = true;

if (strSchCode.startsWith("CPU") && WI.fillTextValue("block_sec").length() > 0){

	vCPUSubCodeSubSecList = advExtn.getBlockSectionCPU(dbOP, WI.fillTextValue("sy_from"),
														WI.fillTextValue("sy_to"), WI.fillTextValue("semester"),
														WI.fillTextValue("block_sec"));
	if (vCPUSubCodeSubSecList == null)
		strErrMsg = advExtn.getErrMsg();
}	

if(strSchCode.startsWith("CIT") && vAdviseList != null && vAdviseList.size() > 0) {
 int iYrLevel = Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(6),"0"));
 if(iYrLevel >= 2) {
 	String strSQLQuery = "select sub_code from subject where (sub_Code like 'pe%' or sub_code like 'nstp%') and is_del = 0 order by sub_code";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		if(iYrLevel == 2 && rs.getString(1).startsWith("NSTP"))
			continue;
		
		vPENSTPSubToTake.addElement(rs.getString(1));
		vPENSTPSubToTake.addElement(null);//position of PE/NSTP subject.. so i can check if it is already selected.
	} 
	rs.close();
 }

}

//get Default value of NSTP.. 
if(strSchCode.startsWith("NEU") && vAdviseList != null && vAdviseList.size() > 0) {
	strNSTPDefaultVal = "select nstp_val from enrl_final_cur_list where is_temp_stud = 0 and user_index = "+
							vStudInfo.elementAt(0)+" and nstp_val is not null order by enroll_index desc";
	//System.out.println(strNSTPDefaultVal);
	strNSTPDefaultVal = dbOP.getResultOfAQuery(strNSTPDefaultVal, 0);
}





%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Advising Old Students</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<style>
/**
.messageBox {
	<%if(WI.fillTextValue("win_width").length() > 0) {%>
		height: 250px; width:<%=WI.fillTextValue("win_width")%>px; overflow: auto; border: inset black 1px;
	<%}else{%>
		height: 250px; width:1060px; overflow: auto; border: inset black 1px;
	<%}%>
}
**/
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//if units to take is null or zero, give error.
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
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

function CallSelALL() {
	<%if(WI.fillTextValue("selAll").length() > 0) {%>
		document.advising.selAll.checked = true;
		return checkAll();
	<%}%>
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
		document.advising.selAll.checked = false;
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
	<%if(strSchCode.startsWith("FATIMA")){%>
		if(document.advising.plan_ref.selectedIndex == 0) {
			//if(!confirm("Please click OK if student does not have any plan"))
			//	return;
			alert("Please select installation plan");
			return;
		}
	<%}%>
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
	"&online_advising=1";//+document.advising.online_advising.value;
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
		
<% if (strSchCode.startsWith("CPU")){%>
		if(	eval('document.advising.sec_index'+index+'.value.length') == 0){
			alert ("Please enter stub code for the subject");
			eval("document.advising.checkbox"+index+".checked= false") ;
			return;
		}
<%}else{%>
		if(	eval('document.advising.sec'+index+'.value.length') == 0){
			alert ("Please enter section for the subject");
			eval("document.advising.checkbox"+index+".checked = false");
			return;
		}
<%}%>	

		document.advising.sub_load.value = Number(eval('document.advising.ut'+index+'.value')) +
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
		document.advising.sub_load.value =Number(document.advising.sub_load.value) - Number(eval('document.advising.ut'+index+'.value'));
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
	if(eval('document.advising.sec'+strIndex+'.value.length') > 0)
		strSubSecStartsWith = eval('document.advising.sec'+strIndex+'.value');
	

	if(document.advising.online_advising.value == "1") 
		strSemester = document.advising.semester.value;
	else
		strSemester = document.advising.semester[document.advising.semester.selectedIndex].value;
		
	for(var i = 0; i< document.advising.maxDisplay.value; ++i)
	{
		if(i == strIndex)
			continue;
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
		strNoConflictList+"&sec_startsWith="+escape(strSubSecStartsWith) +
		"&year_level=" + document.advising.year_level.value+"&line_number="+strIndex;
		
	if (eval('document.advising.nstp_val'+strIndex)){
		loadPg += "&nstp_val=" + eval('document.advising.nstp_val'+
						strIndex + '[document.advising.nstp_val'+strIndex+'.selectedIndex].text');
	}

	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,top=10,left=10,scrollbars=yes,,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
var iErrCount = 0;

function Validate()
{
	iErrCount = 0;
	validateNSTPPECIT();//added for CIT.
	if(iErrCount > 0) 
		return;
		
		
	<%if(strSchCode.startsWith("FATIMA")){%>
		if(document.advising.plan_ref.selectedIndex == 0) {
			//if(!confirm("Please click OK if student does not have any plan"))
			//	return;
			alert("Please select installation plan");
			return;
		}
	<%}%>
	var maxDisp  = document.advising.maxDisplay.value;
	if( Number(document.advising.sub_load.value) > Number(document.advising.maxAllowedLoad.value))
	{
		alert("Student can't take more than allowed load <" + document.advising.maxAllowedLoad.value +
				">.Please re-adjust load. Please check the load reference on top of this page.");
		return;
	}

	var iOneChecked = 0;
	
	for(var i =0; i< maxDisp; ++i)
	{
		if (eval("document.advising.checkbox"+i+".checked")){
			iOneChecked++;
			break;
		}
	}
	
	if (iOneChecked != 0){ 
	
		document.advising.action="./gen_advised_schedule.jsp";
		this.SubmitOnce('advising');
		
	}else{
		alert("Select at least 1 subject to advise");
	}
		
	return;
}
function ReloadPage()
{
	document.advising.action="./advising_old.jsp";
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


function ViewPhoto(){
	// update this getImageFileExtn;
	var pgLoc = "../../../upload_img/" + document.advising.stud_id.value+".jpg"; 
	var win=window.open(pgLoc,"ViewPhoto",'width=450,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');


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


//for plan of fatima.
function updatePlanFatima() {
	<%if(vStudInfo == null || vStudInfo.size() == 0) {%>
		return;
	<%}else{%>
	
	var strCurID = "<%=WI.fillTextValue("stud_id")%>";
	if(strCurID != document.advising.stud_id.value) {
		document.advising.submit();
		return;
	}
	
	var strPlanRef = document.advising.plan_ref[document.advising.plan_ref.selectedIndex].value;
	//alert(strPlanRef);

	var strParam = "stud_ref=<%=(String)vStudInfo.elementAt(0)%>&sy_from=<%=WI.fillTextValue("sy_from")%>"+
					"&semester=<%=WI.fillTextValue("semester")%>&is_tempstud=0&new_plan="+strPlanRef;
	var objCOAInput = document.getElementById("coa_info_splan");
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=123&"+strParam;
	this.processRequest(strURL);	
	<%}%>
}


function alertSize() {
	<%
	if(WI.fillTextValue("win_width").length() > 0){%>
		return;
	<%}%>
  var myWidth = 0, myHeight = 0;
  if( typeof( window.innerWidth ) == 'number' ) {
    //Non-IE
    myWidth = window.innerWidth;
    myHeight = window.innerHeight;
  } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
    //IE 6+ in 'standards compliant mode'
    myWidth = document.documentElement.clientWidth;
    myHeight = document.documentElement.clientHeight;
  } 
  else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
    //IE 4 compatible
    myWidth = document.body.clientWidth;
    myHeight = document.body.clientHeight;
  }
  //window.alert( 'Width = ' + myWidth );
  //window.alert( 'Height = ' + myHeight );
  	document.advising.win_width.value = myWidth - 35;
	//alert(document.advising.win_width.value);
}

function ResetSelALL() {
	if(document.advising.selAll)
		document.advising.selAll.checked=false;
}

function InvalidateAdvising() {
	if(!confirm('Are you sure you want to remove all advised subjects.'))
		return;
	document.advising.invalidate_advising.value = '1';
	document.advising.submit();
}

</script>

<body <%if (!bolFatalErr){%>onLoad="focusID();alertSize();CallSelALL()" <%}else{%>onLoad="CallSelALL();"<%}%>>

<%}else{//student logged in for online advising  

//this is the deal now in DBTC, if online advising, student can advise only once. as there are cases, the advising is changed by college and should not be changed by 
//student anymore..  , set bolShowAdviseList to false.. 
if(strSchCode.startsWith("DBTC") && vEnrolledList != null && bolIsCalledFrOnlineRegdStud) {
	bolShowAdviseList = false; bolFatalErr = true;
	strErrMsg = "Not allowed to advise again. Please contact system admin to modify advised subject.";
}

%>
<body bgcolor="#9FBFD0" >

<%}%>


<form name="advising" action="./advising_old.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%//change color if student logged in for online admission.%>
    <tr <%if(strAuthTypeIndex.compareTo("4") != 0){%>bgcolor="#A49A6A"<%}%>>
	<td height="25" colspan="3" align="center"><strong> <font color="#FFFFFF"> 
        :::: <%=WI.fillTextValue("pgDisp")%> STUDENT ADVISING PAGE :::: </font></strong></td>
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
if(bolFatalErr)
{
	dbOP.cleanUP();
	return;
}

if(!bolIsCalledFrOnlineRegdStud) {//show input only if it is not called from online registration of student.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="top"> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="20%" height="25">Enter Student ID </td>
      <td width="17%" height="25"> <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  <%if(bolIsForwarded){%> readonly="yes"<%}else{%> onKeyUp="AjaxMapName('1');"<%}%>>
	  </td>
      <td width="4%" height="25"><%if(!bolIsForwarded){%><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" ></a><%}%></td>
      <td width="22%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0" onClick="ResetSelALL()"></a> 
&nbsp;	  </td>
<% if (vEnrolledList != null)
		strTemp = "class=\"thinborderALL\"";
	else
		strTemp = ""; %>
	  
      <td width="36%" <%=strTemp%>>&nbsp; 
        <%if(vEnrolledList != null){%>
        <font size="3" color="#0000FF"><b>Student is advised already.<a href="javascript:InvalidateAdvising();">Click Here to remove all</a></b></font> 
        <%}%>
      <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>	  </td>
    </tr>
    <tr> 
      <td width="1%" height="24">&nbsp;</td>
      <td width="20%" height="24">School Year/Term </td>
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
	  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = astrSchYrInfo[2];
%>
	  <select name="semester" onChange="ReloadPage();">
		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> <input type="hidden" name="offering_sem_name" value="<%=astrConvertSem[Integer.parseInt(strTemp)]%>">      </td>
    </tr>
<%if((strSchCode.startsWith("FATIMA") || strInfo5.startsWith("jonelta")) && vStudInfo != null && vStudInfo.size() > 0){
//get here if already set plan.
	String strStudFatimaPlanRef = null;
	enrollment.FAStudMinReqDP faMinDP = new enrollment.FAStudMinReqDP(dbOP);
	Vector vStudInstallmentPlanFatima = faMinDP.getPlanInfoOfAStudent(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0), false);
	if(vStudInstallmentPlanFatima != null && vStudInstallmentPlanFatima.size() > 0)
		strStudFatimaPlanRef = (String)vStudInstallmentPlanFatima.elementAt(0);
%>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="5" style="font-size:9px; font-weight:bold; color:#0000FF">Installation Plan: 
		<select name="plan_ref" style="font-size:11px" onChange="updatePlanFatima()">
          <option value=""></option>
          <%if(strInfo5.equals("jonelta")) {%>
			  <%=dbOP.loadCombo("plan_ref","PLAN_NAME"," from FA_STUD_PLAN_FATIMA where is_valid = 1 order by PLAN_NAME", strStudFatimaPlanRef, false)%>
		  <%}else{%>
			  <%=dbOP.loadCombo("plan_ref","PLAN_NAME,INSTALLMENT_FEE"," from FA_STUD_PLAN_FATIMA where is_valid = 1 order by PLAN_NAME", strStudFatimaPlanRef, false)%>
		  <%}%>
        </select><label id="coa_info_splan" style="font-size:9px; font-weight:bold"></label>
	  </td>
    </tr>
<%}%>
  </table>
<%}else {//show now fixed information of student%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="20%" height="25">Student ID</td>
      <td width="49%" height="25"> <strong><font size="3"><%=strStudID%></font></strong> 
	  <input type="hidden" name="stud_id" value="<%=strStudID%>"></td>
      <td width="30%" colspan="2"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>      </td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="20%" height="25">School Year/Term </td>
      <td height="25"> <font size="3"><strong><%=astrSchYrInfo[0]%> - <%=astrSchYrInfo[1]%> 
        (<%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>)</strong></font> 
        <input type="hidden" name="sy_from" value="<%=astrSchYrInfo[0]%>"> 
		<input type="hidden" name="sy_to" value="<%=astrSchYrInfo[1]%>"> 
        <input type="hidden" name="semester" value="<%=astrSchYrInfo[2]%>"> </td>
      <td colspan="2"><%if(vEnrolledList != null){%>
        <font size="3" color="#0000FF"><b>You are already advised.<a href="javascript:InvalidateAdvising();">Click Here to remove all</a></b></font> 
        <%}%></td>
    </tr>
  </table>
<%}//end of showing fixed information.%>

<%if(vStudInfo != null && vStudInfo.size() > 0) { 
if(bolShowAdviseList && strSchCode.startsWith("EAC"))
	dOutstanding = 0d;
	
if(dOutstanding > 0.1d){%>
  <table width="100%" bgcolor="#FFFFFF"><tr><td>
  <table width="50%" bgcolor="#000000"><tr><td height="25" bgcolor="#FFFFFF">
	  <font size="4" color="red"><strong>
	  <%if(strSchCode.startsWith("EAC")) {%>
			Advisory: Please Settle Accounts in Accounting Office
	  <%}else{%>
			OLD ACCOUNT: <%=CommonUtil.formatFloat(dOutstanding,true)%>
	  <%}%>
	  </strong></font></td></tr></table>
</td></tr></table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td width="0%" height="25">&nbsp;</td>
      <td width="61%" height="25">Student name  :<strong>
        <%=(String)vStudInfo.elementAt(1)%>
        <input name="stud_name" value="<%=(String)vStudInfo.elementAt(1)%>" type="hidden">
      </strong></td>
      <td width="26%" height="25">Year level: <strong><%=WI.getStrValue(vStudInfo.elementAt(6),"N/A")%></strong></td>
      <td width="13%" rowspan="3">
	  <%if(WI.fillTextValue("stud_id").length() > 0) {%>
	  <img src="../../../upload_img/<%=WI.fillTextValue("stud_id")%>.jpg" height="75" width="75" border="2">
	  <%}%>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Course/Major :<strong><%=(String)vStudInfo.elementAt(7)%>
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
      <td height="26"><a href="javascript:ViewPhoto()">View Student Photo(Large size) </a> </td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3"><hr size="1"></td>
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
		<%}%> 
	 	
	  </td>
    </tr>
    <%
//I have to check here the downpayment rules. -- check READ_PROPERTY_FILE table.
boolean bolAllowAfterCheckDPRule = true;
//if(bolShowAdviseList)
	bolAllowAfterCheckDPRule = advising.shouldWeAdviseCheckOnDownPmt(dbOP, (String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(0), WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
 if(!bolAllowAfterCheckDPRule) {//System.out.println(advising.getErrMsg());
 	bolShowAdviseList = false;
	strErrMsg = advising.getErrMsg();
  }else{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><a href="javascript:ShowList();"><img src="../../../images/show_list.gif" width="57" height="34" border="0" onClick="ResetSelALL()"></a>
      <font size="1">Show list of subjects student may take for this term </font></td>
      <td>
	  
	<% if ( strSchCode != null && !strSchCode.startsWith("CPU") && false) {  %>
	  <a href="javascript:AutoAdvise();"><img src="../../../images/advise.gif" width="42" height="37" border="0"></a>
	  <font size="1">click to generate auto advise subjects</font>
	  
	<%}	if (strSchCode != null && strSchCode.startsWith("CPU")) { 	%>
        <a href="javascript:ViewCurriculumEval();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>
		<font size="1">click to view residency evaluation page</font>
	<%}%> 
	  
	  
	  </td>
    </tr>
 <%}%>
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
      <td height="25" colspan="5"><div align="center">LIST OF SUBJECTS THE STUDENT
          MAY TAKE</div></td>
    </tr>
<%
if(strOverLoadDetail != null){%>
    <tr>
      <td  height="25">&nbsp;</td>
      <td colspan="4" height="25"><font size="1">Overload detail : <%=strOverLoadDetail%></font></td>
    </tr>
<%}%>
    <tr>
      <td width="2%"  height="25">&nbsp;</td>
      <td width="31%" height="25">Max units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
      <td width="29%" height="25" >Total student load:
<%
//if advised already, i have to use it.
if(vEnrolledList != null && vEnrolledList.size() > 0 && WI.fillTextValue("block_sec").length() == 0) 
	strTemp = (String)vEnrolledList.remove(0);
else	
	strTemp = "0";
%>	  
      <input type="text" name="sub_load" value="<%=strTemp%>" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;"></td>
      <td width="29%">
	  <%if(bolIsEligibleForBlock){%>
	  	<a href="javascript:BlockSection();"><img src="../../../images/bsection.gif" width="62" height="24" border="0"></a><font size="1">click for block sectioning</font>
	  <%}else{%>
	  	<font size="1" style="font-weight:bold">Not Eligible for Block Section</font>
	  <%}%>
	  </td>
      <td width="9%"><a href="javascript:Validate();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<div class="messageBox" id="div_msgBox">
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFDD">
    <tr bgcolor="#CCCCCC">
      <td width="2%" height="25" align="center"><font size="1"><strong>YEAR</strong></font></td>
      <td width="3%" height="25" align="center"><font size="1"><strong>TERM</strong></font></td>
      <td width="12%" height="25" align="center"><font size="1"><strong>SUBJECT 
        CODE</strong></font></td>
      <td width="23%" align="center"><font size="1"><strong>SUBJECT TITLE </strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>LEC/LAB UNITS</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>TOTAL UNITS</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>UNITS TO TAKE</strong></font></td>
 <% if (!strSchCode.startsWith("CPU") && !strSchCode.startsWith("CIT")) {%>
      <td width="6%" align="center"><font size="1"><strong>IS ONLY LAB</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>IS ONLY LEC</strong></font></td>
<% } if (strSchCode.startsWith("CPU")) 
		strTemp = "STUB CODE";
	else
		strTemp = "SECTION";
%>
	<td width="12%" align="center"><font size="1"><strong><%=strTemp%></strong></font></td>
      <td align="center" width="20%"><strong><font size="1">SCHEDULE</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">SELECT 
<% if (!strSchCode.startsWith("CPU")) {%>ALL <br><%}%></font></strong>       
         <input type="checkbox" name="selAll" value="0" 
		 <%if(strIsBlockFoced.equals("1")){%>onClick="return false"<%}else{%>onClick="checkAll();"<%}%>>      </td>
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

String strTimeSch = null;
for(int i = 0,j=0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed)
{
 	strTimeSch = null;

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
			if(strTemp == null)
			{strTemp2 = "";strTemp="";}
		}

		if (strSchCode.startsWith("CPU") && vCPUSubCodeSubSecList != null){
			iIndexOf = vCPUSubCodeSubSecList.indexOf((String)vAdviseList.elementAt(i+6));
			if (iIndexOf != -1){
				strTemp = (String)vCPUSubCodeSubSecList.elementAt(iIndexOf +1);
			}
		}
	}
	else if(vEnrolledList != null && vEnrolledList.size() > 0) {
		iIndexOf = vEnrolledList.indexOf((String)vAdviseList.elementAt(i+7));//sub name.
		if(iIndexOf != -1 && !((String)vEnrolledList.elementAt(iIndexOf - 1)).startsWith((String)vAdviseList.elementAt(i+6))) 
			iIndexOf = vEnrolledList.indexOf((String)vAdviseList.elementAt(i+7),iIndexOf+1);
		if(iIndexOf != -1 && !((String)vEnrolledList.elementAt(iIndexOf - 1)).startsWith((String)vAdviseList.elementAt(i+6))) 
			iIndexOf = vEnrolledList.indexOf((String)vAdviseList.elementAt(i+7),iIndexOf+1);
			
		if(iIndexOf != -1 && ((String)vEnrolledList.elementAt(iIndexOf - 1)).startsWith((String)vAdviseList.elementAt(i+6))) {//subject matching.
			strTimeSch = (String)vEnrolledList.elementAt(iIndexOf + 2);

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
	
	iIndexOf = vPENSTPSubToTake.indexOf(vAdviseList.elementAt(i+6));
	if(iIndexOf > -1) {
		if( ((String)vAdviseList.elementAt(i + 6)).toLowerCase().startsWith("pe")) {
			if(!bolIsPEToTakeSet) {
				vPENSTPSubToTake.setElementAt(String.valueOf(j), iIndexOf + 1);
				bolIsPEToTakeSet = true;
			}
		}
		else {
			if(!bolIsNSTPToTakeSet) {
				vPENSTPSubToTake.setElementAt(String.valueOf(j), iIndexOf + 1);
				bolIsNSTPToTakeSet = true;
			}
		}
	}
%>
    <tr onDblClick='LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>","<%=j%>");'
	class="nav" id="msg<%=j%>" onMouseOver="navRollOver('msg<%=j%>', 'on')" onMouseOut="navRollOver('msg<%=j%>', 'off')"> 
      <td height="20" align="center" style="font-size:11px;"> 
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
      <td align="center" style="font-size:11px;"><%=WI.getStrValue(vAdviseList.elementAt(i+2),"N/A")%></td>
      <td style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+6)%> 
	  <%if(((String)vAdviseList.elementAt(i+6)).indexOf("NSTP") != -1 || ((String)vAdviseList.elementAt(i+7)).indexOf("ROTC") != -1){
if(strEnrolledNSTPVal == null)
	strEnrolledNSTPVal = WI.fillTextValue("nstp_val");

if(strNSTPDefaultVal != null)
	strNSTPDefaultVal = " where nstp_values.nstp_val = '"+strNSTPDefaultVal+"' ";
else	
	strNSTPDefaultVal = "";

%> <select name="nstp_val<%=j%>" style="font-weight:bold;">
          <%=dbOP.loadCombo("distinct NSTP_VAL","NSTP_VAL"," from NSTP_VALUES "+strNSTPDefaultVal+" order by NSTP_VALUES.NSTP_VAL asc", strEnrolledNSTPVal, false)%> </select> <%}//only if subject is NSTP %> </td>
      <td style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+7)%></td>
      <td align="center" style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+3)%>/<%=(String)vAdviseList.elementAt(i+4)%></td>
      <td align="center" style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+5)%></td>
      <td align="center" style="font-size:11px;"> 
<%

if (bolSameStudent) 
	strTemp3 = WI.fillTextValue("ut"+j);
else
	strTemp3 = "";

if(strTemp3.length() ==0 && strUnitEnrolled == null)
	strTemp3 = Float.toString(Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8)));
else if(strTemp3.length() ==0)	
	strTemp3 = strUnitEnrolled;

if(strLecLabStat.equals("1"))
	strLecLabSelect = " checked";
else	
	strLecLabSelect = "";
	
%>	  <input type="text" value="<%=strTemp3%>" name="ut<%=j%>" size="3" maxlength="3" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'; javascript:SaveInputUnit(<%=j%>);" onBlur="style.backgroundColor='white'; javascript:VerifyNotNull(<%=j%>);"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" onKeyUp='ChangeLoad("<%=j%>");' style="border:0; font-size:11px;" <%=strReadOnlyUnitToTake%>></td>
<% if (!strSchCode.startsWith("CPU") && !strSchCode.startsWith("CIT")) {%>
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
	
	if(strIsBlockFoced.equals("1") || bolIsBlockSectionActive)
		strInputTypeDetails += " readonly='yes'";

%>	  
	  <input type="<%=strInputType%>" value="<%=strTemp2%>" name="sec<%=j%>" <%=strInputTypeDetails%>  <%if(bolIsCalledFrOnlineRegdStud){%>readonly='yes'<%}%>> 
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
      <td><label id="_<%=j%>" style="font-size:11px;"><%=WI.getStrValue(strTimeSch)%></label></td>
      <td align="center"> 
<%
if(bolAuthCheckBox)
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox"<%=strTemp%> name="checkbox<%=j%>"
	  value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>"
	  <%if(strIsBlockFoced.equals("1")){%>onClick="return false"<%}else{%>onClick='AddLoad("<%=j%>","<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>")'<%}%>> 
        <input type="hidden" name="NO_CONFLICT<%=j%>" value="0">      </td>
      <%if(bolIsSuperUser){%>
      <td align="center"> <input type="checkbox" value="1" name="no_conflict<%=j%>" onClick="SetIsNoConflict(<%=j%>);"></td>
      <%}%>
      <td align="center">
	  <%if(strIsBlockFoced.equals("1")){%>N/A<%}else{%>
	  <a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>","<%=j%>");'><img src="../../../images/schedule.gif" width="40" height="20" border="0"></a>
	  <%}%>
	  </td>
    </tr>
    <% i = i+9;}%>
  </table>
</div>
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
<input type="hidden" name="pgDisp" value="<%=WI.fillTextValue("pgDisp")%>">
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


<!-- for online registration i have to keep this information -->
<input type="hidden" name="online_advising" value="<%=WI.fillTextValue("online_advising")%>">

<% 
	if (bolSameStudent)
		strTemp = WI.fillTextValue("stud_id");
	else
		strTemp = "";
%>

<input type="hidden" name="prev_id" value="<%=strTemp%>">

<input type="hidden" name="win_width" value="<%=WI.fillTextValue("win_width")%>">
<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>">

<input type="hidden" name="is_forced_block" value="<%=strIsBlockFoced%>">

<input type="hidden" name="invalidate_advising" value="">

<%
for(int i = 0; i < vPENSTPSubToTake.size(); i += 2) {
	if(vPENSTPSubToTake.elementAt(i + 1) != null)
		continue;
	vPENSTPSubToTake.remove(i); vPENSTPSubToTake.remove(i);
	i = i - 2;
}
%>
<script language="javascript">
function validateNSTPPECIT() {
	var strErrMsg = "";
	<%for(int i = 0; i < vPENSTPSubToTake.size(); i += 2){%>
		if(!document.advising.checkbox<%=vPENSTPSubToTake.elementAt(i + 1)%>.checked) {
			if(strErrMsg == '')
				strErrMsg = 'You must enroll in following subjects.';
			strErrMsg += "\r\n"+document.advising.sub_code<%=vPENSTPSubToTake.elementAt(i + 1)%>.value;
			++iErrCount;
		}
	<%}%>
	if(strErrMsg != '')
		alert(strErrMsg);
}
</script>
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
