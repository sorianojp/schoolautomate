<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strInputTypeDetails = null;
	String strInputType = null;

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;String strTemp3 = null;
	String strTempStudId = request.getParameter("stud_id");
	int iMaxDisplayed = 0;
	String strDegreeType = null;
	boolean bolFatalErr = false;
	
	boolean bolIsForwarded = WI.fillTextValue("is_forwarded").equals("1");
	boolean bolIsOnlineAdvising = false;
	
	if(WI.fillTextValue("online_advising").length() > 0) { 
		bolIsOnlineAdvising = true;
		bolIsForwarded = true;
		strTempStudId = (String)request.getSession(false).getAttribute("tempId");
		if(strTempStudId == null) {
			strErrMsg = "You are already logged out. Please login again.";
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
			<%
			return;
		}
	}


	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode == null)
		strSchCode = "";
	String strInfo5 = WI.getStrValue((String)request.getSession(false).getAttribute("info5"));	
	
	if (strSchCode.startsWith("CPU")){ // for block sectioning
		strTemp = "_cpu";
	}else{
		strTemp = "";
	}	
	boolean bolIsUI = strSchCode.startsWith("UI");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-advising-new","advising_transferee.jsp");
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
int iAccessLevel = 2;
if(!bolIsOnlineAdvising)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"advising_transferee.jsp");
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

String strMaxAllowedLoad = "0"; // this is the first field of the vAdvisingList
boolean bolShowAdviseList = false;
Vector vAdviseList = new Vector();//filled up by auto advise, 0=sec index,1=section, 2=cur index.
Vector vStudInfo = null;


//added for cit to for enroll in PE and NSTP subjects.
Vector vPENSTPSubToTake = new Vector();
boolean bolIsPEToTakeSet = false;
boolean bolIsNSTPToTakeSet = false;


//show enrolled subject if student is enrolled. 
Vector vEnrolledList = null;

Advising advising = new Advising();
enrollment.AdvisingExtn advExtn = new enrollment.AdvisingExtn();

if(request.getParameter("sy_from") == null || request.getParameter("sy_from").trim().length() ==0 ||
	request.getParameter("sy_to") == null || request.getParameter("sy_to").trim().length() ==0 || 
	WI.fillTextValue("stud_id").length() ==0 ||	WI.fillTextValue("semester").length() == 0)
{
	strErrMsg = "Please enter ID/School Year.";
}
else if(dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id")) != null) {
	strErrMsg = "Please go to Advising (Old) to advise old/second course(old) student.";
}

if(strErrMsg == null)
{
	vStudInfo = advising.getStudInfo(dbOP,strTempStudId,WI.fillTextValue("sy_from"),
					WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vStudInfo == null)
	{
		strErrMsg = advising.getErrMsg();
		bolFatalErr = true;
	}
	if(!bolFatalErr)
	{
	//check if this is new -- forward if this is new / orl.
	if(((String)vStudInfo.elementAt(11)).equals("New"))
	{
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./advising_new.jsp?temp_id="+strTempStudId+"&sy_from="+WI.fillTextValue("sy_from")+
			"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")+"&online_advising="+WI.fillTextValue("online_advising")));
			return;
	}
	else if(((String)vStudInfo.elementAt(11)).compareTo("Old") ==0)
	{
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./advising_old.jsp?stud_id="+strTempStudId+"&sy_from="+WI.fillTextValue("sy_from")+
			"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")+"&online_advising="+WI.fillTextValue("online_advising")));
			return;
	}

		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strTempStudId,(String)vStudInfo.elementAt(2),
															(String)vStudInfo.elementAt(3),WI.fillTextValue("sy_from"),
															WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(6),
															WI.fillTextValue("semester"),(String)vStudInfo.elementAt(4),
															(String)vStudInfo.elementAt(5));
		if(vMaxLoadDetail == null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
		else
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
	}
	//check if it is auto advise or show list.
	if(!bolFatalErr && WI.fillTextValue("showList").compareTo("1") ==0) // show list.
	{
		bolShowAdviseList = true;
		vAdviseList = advising.getAdvisingListWOPreReq(dbOP,strTempStudId,(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),
					request.getParameter("sy_from"),request.getParameter("sy_to"), (String)vStudInfo.elementAt(4),
					(String)vStudInfo.elementAt(5),(String)vStudInfo.elementAt(6),request.getParameter("semester"));
		if(vAdviseList ==null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
	}

}//if school year is entered.
if(vStudInfo != null)
{
	strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",
                                       (String)vStudInfo.elementAt(2), "degree_type",
                                       " and is_valid=1 and is_del=0");

	if(strDegreeType == null)
		strErrMsg = "Error in getting course degree type.";
	else
	{
		if(strDegreeType.compareTo("1") == 0)
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./advising_transferee_md.jsp?stud_id=" + strTempStudId + 
							"&sy_from="+WI.fillTextValue("sy_from")+ "&sy_to="+WI.fillTextValue("sy_to")+"&semester="+
							WI.fillTextValue("semester")+"&online_advising="+WI.fillTextValue("online_advising")));

			return;
		}
		else if(strDegreeType.compareTo("2") == 0)
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./advising_transferee_medicine.jsp?stud_id=" + strTempStudId + 
							"&sy_from="+WI.fillTextValue("sy_from")+"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+
							WI.fillTextValue("semester")+"&online_advising="+WI.fillTextValue("online_advising")));

			return;
		}
		
		vEnrolledList =  new enrollment.EnrlAddDropSubject().getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),strDegreeType,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"),true,true);

		/*** add this code to include the subjects taken from other course to the list of advise subject.. **/
		//System.out.println(vAdviseList.size());
		//System.out.println(vAdviseList);
		if(vEnrolledList != null && vEnrolledList.size() > 0 && vAdviseList != null && vAdviseList.size() > 0) {
			int iIndexOfTemp = 0;
			Vector vTempEnrlList = new Vector();
			for(int i = 1; i < vEnrolledList.size(); i += 15) 
				vTempEnrlList.addElement(vEnrolledList.elementAt(i + 2));
			for(int i = 0; i < vAdviseList.size(); i += 10) {
				iIndexOfTemp = vTempEnrlList.indexOf(vAdviseList.elementAt(i + 8));
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


Vector vCPUSubCodeSubSecList = null;

if (strSchCode.startsWith("CPU") && WI.fillTextValue("block_sec").length() > 0){

//	System.out.println("execute : getBlockSectionCPU " );

	vCPUSubCodeSubSecList = advExtn.getBlockSectionCPU(dbOP, WI.fillTextValue("sy_from"),
														WI.fillTextValue("sy_to"), WI.fillTextValue("semester"),
														WI.fillTextValue("block_sec"));
														
//	System.out.println(vCPUSubCodeSubSecList);
	
	if (vCPUSubCodeSubSecList == null)
		strErrMsg = advExtn.getErrMsg();
}

String strReadOnlyUnitToTake = "";
if(strSchCode.startsWith("UB") || bolIsOnlineAdvising)
	strReadOnlyUnitToTake = " readonly='yes' style='border:0px;'";


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
boolean bolIsBlockSectionActive = false;
Vector vForcedBlock = null;
if( vAdviseList != null && vAdviseList.size() > 0) {
	vForcedBlock = new enrollment.SubjectSection().getForcedBlockSectionList(dbOP, request, request.getParameter("sy_from"), request.getParameter("semester"));
	
	//I have to make bolIsForecedBlock to true if block section is selcted. 
	if(vForcedBlock != null && vForcedBlock.size() > 0)
		bolIsBlockSectionActive = true;
}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
	<%if(bolIsUI){%>
	return;
	<%}%>
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
		if(	eval('document.advising.sec'+i+'.value.length')> 0)
		{
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
		return;
	}
	//this is the time I will check all.
	for(var i =0; i< maxDisp; ++i)
	{
		if(	eval('document.advising.sec'+i+'.value.length')> 0)
		{
			eval('document.advising.checkbox'+i+'.checked = true');
		}
	}
	document.advising.sub_load.value = totalLoad;

}
//this is the variable stores all the section_index stored so far.
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
	//document.advising.submit();
	ReloadPage();
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

	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
		document.advising.sub_load.value = Number(eval('document.advising.ut'+index+'.value')) +Number(document.advising.sub_load.value);
		if( Number(document.advising.sub_load.value) > Number(document.advising.maxAllowedLoad.value))
			alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load.");
	}
	else //subtract.
		document.advising.sub_load.value =Number(document.advising.sub_load.value) - Number(eval('document.advising.ut'+index+'.value'));
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

function LoadPopup(secName,sectionIndex,strCurIndex, strSubIndex, strIndex)//I have to use combination of subject,course and major.
{
//this will check conflict with the schedule of other subjects taken. pass user id, all the sub_section_index,
//if check box is not checked - it is considered as not selected.
	var subSecList = "";
	var strLabList = "";
	var strSubSecStartsWith = "";
	if(eval('document.advising.sec'+strIndex+'.value.length') > 0)
		strSubSecStartsWith = eval('document.advising.sec'+strIndex+'.value');
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
	}
	if(subSecList.length == 0) subSecList = "0";
	if(strLabList.length == 0) strLabList = "0";

	var loadPg = "./subject_schedule.jsp?form_name=advising&cur_index="+strCurIndex+
		"&sub_index="+strSubIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.advising.sy_from.value+"&syt="+document.advising.sy_to.value+"&semester="+document.advising.semester[document.advising.semester.selectedIndex].value+
		"&sec_index_list="+subSecList+"&course_index="+document.advising.ci.value+
		"&major_index="+document.advising.mi.value+"&degree_type="+document.advising.degree_type.value+
		"&IS_FOR_LAB="+eval('document.advising.IS_LAB_ONLY'+strIndex+'.value')+"&lab_list="+strLabList+
		"&sec_startsWith="+escape(strSubSecStartsWith) +"&year_level=" + document.advising.year_level.value+"&line_number="+strIndex+"&online_advising="+document.advising.online_advising.value;
		
	if (eval('document.advising.nstp_val'+strIndex)){
		loadPg += "&nstp_val=" + eval('document.advising.nstp_val'+strIndex+	
										'[document.advising.nstp_val'+strIndex+'.selectedIndex].text');
	}
		
	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
			return false;
		}
	<%}%>
	if( Number(document.advising.sub_load.value) > Number(document.advising.maxAllowedLoad.value))
	{
		alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load. Please check the load referece on top of this page.");
		return false;
	}
	if( Number(document.advising.sub_load.value) == 0)
	{
	<%if(bolIsUI){%>
	document.advising.action="./gen_advised_schedule.jsp";
	return true;
	<%}%>

		alert("Sudent load can't be zero.");
		return false;
	}
	if( document.advising.sem.value.length ==0)
	{
		alert("Please enter the enrolling semester of the student.");
		return false;
	}
	document.advising.action="./gen_advised_schedule.jsp";
	//document.advising.submit();
	return true;
}
function BlockSection()
{
	document.advising.showList.value = "1";
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
	//alert(loadPg);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage()
{
	document.advising.action="./advising_transferee.jsp";
	document.advising.submit();
}

function focusID() {
	document.advising.stud_id.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud_temp.jsp?opner_info=advising.stud_id&is_advised=1&sy_from="+
	document.advising.sy_from.value+"&sy_to="+ document.advising.sy_to.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateNSTPText(){
	if (document.advising.nstp_val) {
		document.advising.nstp_val_text.value = 
				document.advising.nstp_val[document.advising.nstp_val.selectedIndex].text ;
	}
}


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
					"&semester=<%=WI.fillTextValue("semester")%>&is_tempstud=1&new_plan="+strPlanRef;
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
</script>
<body bgcolor="#D2AE72" onLoad="focusID();alertSize();CallSelALL()">
<form name="advising" action="./advising_transferee.jsp" method="post" onSubmit="return Validate();">
<input type="hidden" name="degree_type" value="<%=WI.getStrValue(strDegreeType)%>">
<input type="hidden" name="pgDisp" value="<%=WI.fillTextValue("pgDisp")%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" bgcolor="#A49A6A" align="center"><strong> <font color="#FFFFFF">
        :::: <%=WI.fillTextValue("pgDisp")%> STUDENT ADVISING PAGE :::: </font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="8"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="22%" height="25">Temporary Student ID </td>
      <td width="19%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		<%if(bolIsForwarded){%> readonly="yes" style="font-size:14px; border:0px;" <%}else{%> <%}%>>
	  </td>
	  <td width="26%">
<%if(!bolIsForwarded){%>
	  <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" ></a>
<%}%>
	  </td>
	  <% if (vEnrolledList != null) 
		  	strTemp = "class=\"thinborderALL\"";
		else
			strTemp = "";
	  %>
      <td width="31%" height="25" <%=strTemp%>> &nbsp;
        <%if(vEnrolledList != null){%>
	  	<font size="3" color="#0000FF"><b>Student is advised already.</b></font>
	  <%}%></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="22%" height="25">School Year </td>
      <td height="25" colspan="3">
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
        &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
          <option value="0">Summer</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		  if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")) {
  		    if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }%>
        </select> <input type="hidden" name="offering_sem_name" value="<%=astrConvertSem[Integer.parseInt(strTemp)]%>">      
<%if(!bolIsForwarded){%>
		<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a> &nbsp; <a href="./advising_transferee.jsp"><img src="../../../images/clear.gif" width="56" height="19" border="0"></a>
<%}%>
		</td>
    </tr>
<%if((strSchCode.startsWith("FATIMA") || strInfo5.startsWith("jonelta")) && vStudInfo != null && vStudInfo.size() > 0){
//get here if already set plan.
	String strStudFatimaPlanRef = null;
	enrollment.FAStudMinReqDP faMinDP = new enrollment.FAStudMinReqDP(dbOP);
	Vector vStudInstallmentPlanFatima = faMinDP.getPlanInfoOfAStudent(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0), true);
	if(vStudInstallmentPlanFatima != null && vStudInstallmentPlanFatima.size() > 0)
		strStudFatimaPlanRef = (String)vStudInstallmentPlanFatima.elementAt(0);
%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4" style="font-size:9px; font-weight:bold; color:#0000FF">Installation Plan: 
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

<%if(strErrMsg != null){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4"><strong><%=strErrMsg%></strong></td>
    </tr>
    <%}%>
  </table>
<% if(strErrMsg == null){//show everything below this.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Student Status : <strong><%=((String)vStudInfo.elementAt(11)).toUpperCase()%></strong></td>
      <td height="26">&nbsp;</td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="62%" height="25">Student name (first,middle,last) :
	  <strong> 
	  	<%=(String)vStudInfo.elementAt(1)%>
        <input name="stud_name" value="<%=(String)vStudInfo.elementAt(1)%>" type="hidden">
      </strong>		</td>
      <td height="25">Year level: <%=WI.getStrValue(vStudInfo.elementAt(6),"N/A")%>
<!--
        <select name="year_level">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.length() ==0)
	strTemp = WI.getStrValue(vStudInfo.elementAt(6));

if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select> </td>
    </tr>
-->    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course :<strong><%=(String)vStudInfo.elementAt(7)%>
        <%
	  if(vStudInfo.elementAt(8) != null){%>
        - <%=WI.getStrValue(vStudInfo.elementAt(8))%>
        <%}%>
        </strong></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Curriculum SY :<strong><%=(String)vStudInfo.elementAt(4)%>
        - <%=(String)vStudInfo.elementAt(5)%></strong></td>
      <td height="26">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
if( ((String)vStudInfo.elementAt(11)).compareTo("Cross Enrollee") != 0){%>
    <tr >
      <td colspan="2"><hr size="1"></td>
    </tr>
    <tr >
      <td width="1%" height="25">&nbsp;</td>
      <td width="99%">Previous course/major :<strong> <%=(String)vStudInfo.elementAt(13)%>
        <%
		if(vStudInfo.elementAt(14) != null){%>
        / <%=(String)vStudInfo.elementAt(14)%>
        <%}%>
        </strong></td>
    </tr>
<%}else{//this is called to display cross enrollee info.%>
    <tr >
      <td colspan="2"><hr size="1"></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Current School name &nbsp;: <strong><%=(String)vStudInfo.elementAt(12)%></strong></td>
    </tr>
    <tr >
      <td width="1%" height="25">&nbsp;</td>
      <td width="99%">Current Course/major :<strong> <%=(String)vStudInfo.elementAt(13)%>
        <%
		if(vStudInfo.elementAt(14) != null){%>
        / <%=(String)vStudInfo.elementAt(14)%>
        <%}%>
        </strong></td>
    </tr>
<%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
<%
boolean bolAllowAfterCheckDPRule = true;
//if(bolShowAdviseList)
	bolAllowAfterCheckDPRule = advising.shouldWeAdviseCheckOnDownPmt(dbOP, (String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(0), WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
 if(!bolAllowAfterCheckDPRule) {//System.out.println(advising.getErrMsg());
 	bolShowAdviseList = false;
	strErrMsg = advising.getErrMsg();
  }else{%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2" height="25"><a href="javascript:ViewCurriculum();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click
        to view student's course curriculum</font></td>
      <td width="60%" height="25"> <a href="javascript:ShowList();"><img src="../../../images/show_list.gif" width="57" height="34" border="0"></a><font size="1">click
        to show list of subjects student may take for the semester</font> </td>
    </tr>
<%}%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
<%
if(bolShowAdviseList && vAdviseList != null && vAdviseList.size() > 0){%>

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
      <td height="25" colspan="10"><div align="center">LIST OF SUBJECTS THE STUDENT
          MAY TAKE</div></td>
    </tr>
<%
//if(strSchCode.startsWith("CIT"))
//	strMaxAllowedLoad = Double.toString(Double.parseDouble(strMaxAllowedLoad) - 1);
%>
    <tr>
      <td width="2%"  height="25">&nbsp;</td>
      <td colspan="6" height="25">Max units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
      <td width="29%" height="25">Total student load:
<%
//if advised already, i have to use it.
if(vEnrolledList != null && vEnrolledList.size() > 0 && WI.fillTextValue("block_sec").length() == 0) 
	strTemp = (String)vEnrolledList.remove(0);
else
	strTemp = "0";
%>	  
      <input type="text" name="sub_load" value="<%=strTemp%>" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;"></td>
      <td width="29%">
	  <%if(!bolIsBlockSectionActive){%>
	  	<a href="javascript:BlockSection();"><img src="../../../images/bsection.gif" width="62" height="24" border="0"></a><font size="1">click
        for block sectioning</font>
	  <%}%>
	  </td>
      <td width="10%"><input name="image" type="image" src="../../../images/form_proceed.gif" width="81" height="21" border="0"></td>
    </tr>
  </table>
<div class="messageBox" id="div_msgBox">
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFDD">
    <tr bgcolor="#CCCCCC">
      <td width="3%" height="25" align="center"><font size="1"><strong>YEAR</strong></font></td>
      <td width="2%" height="25" align="center"><font size="1"><strong>TERM</strong></font></td>
      <td width="10%" height="25" align="center"><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td width="20%" align="center"><font size="1"><strong>SUBJECT TITLE </strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>SUBJECT PRE-REQUISITE</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>LEC/LAB UNITS</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>TOTAL UNITS</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>UNITS TO TAKE</strong></font></td>
<% if (!strSchCode.startsWith("CPU") && !strSchCode.startsWith("CIT")){%> 
      <td width="5%" align="center"><font size="1"><strong>IS ONLY LAB</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>IS ONLY LEC</strong></font></td>
<%}
	if (strSchCode.startsWith("CPU"))
		strTemp = "STUB CODE";
	else
		strTemp = "SECTION";
%> 
      <td width="10%" align="center"><font size="1"><strong><%=strTemp%></strong></font></td>
      <td width="20%" align="center"><strong><font size="1">SCHEDULE</font></strong></td>
      <td width="5%" align="center"><strong><font size="1">SELECT 
<% if (!strSchCode.startsWith("CPU")){%> 
	  ALL<br>
<%}%>
	  </font></strong> 
         <input type="checkbox" name="selAll" value="0" onClick="checkAll();"></td>
      <td width="5%" align="center"><font size="1"><strong>ASSIGN SECTION</strong></font></td>
    </tr>
    <% int iTemp = 0;
String strBlockSection = WI.fillTextValue("block_sec");

String strEnrolledNSTPVal = null;
String strUnitEnrolled    = null; 
String strLecLabStat      = null; int iIndexOf = 0;
String strLecLabSelect    = null;
boolean bolAuthCheckBox   = false;

String strTimeSch = null;
for(int i = 0,j=0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed)
{
 	strTimeSch = null;
	
	strTemp = ""; strTemp2 = "";strUnitEnrolled = null;strLecLabStat = "0";strLecLabSelect = "";bolAuthCheckBox   = false;
	//System.out.println(WI.fillTextValue("semester"));
	//System.out.println(vAdviseList.elementAt(i+2));
	//System.out.println(WI.getStrValue(vStudInfo.elementAt(6),"N/A"));
	//System.out.println(vAdviseList.elementAt(i+2));
	
	if(strBlockSection.length() > 0 && WI.fillTextValue("semester").equals((String)vAdviseList.elementAt(i+2)) && WI.getStrValue(vStudInfo.elementAt(6),"N/A").equals(vAdviseList.elementAt(i+1)) ) { //make sure block section is for year-term enrolling 
	//check if block section is called.if so - then display the section information only if the block section available for the year and the section
	
	
		/*
		//check if year and sem are same as it is for block sections.
		if(WI.fillTextValue("year_level").compareTo((String)vAdviseList.elementAt(i+1)) == 0 &&
			WI.fillTextValue("semester").compareTo((String)vAdviseList.elementAt(i+2)) == 0)//matching ;-)
		{
			strTemp2 = strBlockSection;
			strTemp = advising.getSubSecIndex(dbOP,(String)vAdviseList.elementAt(i),strTemp2,request.getParameter("sy_from"),
				  		request.getParameter("sy_to"),request.getParameter("semester"),strDegreeType);
			if(strTemp == null)
			{strTemp2 = "";strTemp="";}
		}

		*/
	
		if (!strSchCode.startsWith("CPU")){
			strTemp2 = request.getParameter("block_sec");
			strTemp = advising.getSubSecIndex(dbOP,(String)vAdviseList.elementAt(i),strTemp2,
						request.getParameter("sy_from"),
				  		request.getParameter("sy_to"),request.getParameter("semester"),
						strDegreeType);//System.out.println("Temp: "+strTemp);System.out.println("strTemp2: "+strTemp2);System.out.println("strDegreeType: "+strDegreeType);
						//System.out.println("strTemp2: "+request.getParameter("semester"));
		}else{
			if ( vCPUSubCodeSubSecList!= null && vCPUSubCodeSubSecList.size() >0){	
				strTemp2 = request.getParameter("block_sec");
				iIndexOf = vCPUSubCodeSubSecList.indexOf((String)vAdviseList.elementAt(i+6));
				if (iIndexOf != -1) {
					strTemp = (String)vCPUSubCodeSubSecList.elementAt(iIndexOf+1);
				}else{
					strTemp = null;
				}
				
			}else{
				strTemp = null;
			}
		}
		if(strTemp == null)
		{strTemp2 = "";strTemp="";}
	


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
			
			strTimeSch = (String)vEnrolledList.elementAt(iIndexOf + 2);
			strUnitEnrolled    = (String)vEnrolledList.elementAt(iIndexOf + 9);
			strEnrolledNSTPVal = (String)vEnrolledList.elementAt(iIndexOf - 1);
			strLecLabStat      = (String)vEnrolledList.elementAt(iIndexOf + 10);bolAuthCheckBox   = true;
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
	//if(iIndexOf > -1)
	//	vPENSTPSubToTake.setElementAt(String.valueOf(j), iIndexOf + 1);
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
    <tr onDblClick='LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+8)%>","<%=j%>");'
	 class="nav" id="msg<%=j%>" onMouseOver="navRollOver('msg<%=j%>', 'on')" onMouseOut="navRollOver('msg<%=j%>', 'off')">
      <td height="20" align="center" style="font-size:11px;"> 
        <!-- all the hidden fileds are here. -->
        <input type="hidden" name="year_level<%=j%>" value="<%=(String)vAdviseList.elementAt(i+1)%>"> 
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
%> <select name="nstp_val<%=j%>" style="font-weight:bold;">
          <%=dbOP.loadCombo("distinct NSTP_VAL","NSTP_VAL"," from NSTP_VALUES order by NSTP_VALUES.NSTP_VAL asc", strEnrolledNSTPVal, false)%> </select> <%}//only if subject is NSTP %> </td>
      <td style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+7)%></td>
      <td align="center" style="font-size:11px;"><%=WI.getStrValue(vAdviseList.elementAt(i+9),"&nbsp;")%></td>
      <td align="center" style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+3)%>/<%=(String)vAdviseList.elementAt(i+4)%></td>
      <td align="center" style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+5)%></td>
      <td align="center" style="font-size:11px;"> 
<%
strTemp3 = WI.fillTextValue("ut"+j);
if(strTemp3.length() ==0 && strUnitEnrolled == null)
	strTemp3 = (String)vAdviseList.elementAt(i+5);
else if(strTemp3.length() ==0)	
	strTemp3 = strUnitEnrolled;

if(strLecLabStat.compareTo("1") == 0)
	strLecLabSelect = " checked";
else	
	strLecLabSelect = "";
	

%> <input name="ut<%=j%>" type="text" size="4" value="<%=strTemp3%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'; javascript:SaveInputUnit(<%=j%>);" onBlur="style.backgroundColor='white'; javascript:VerifyNotNull(<%=j%>);"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" onKeyUp='ChangeLoad("<%=j%>");' <%=strReadOnlyUnitToTake%>></td>
<% if (!strSchCode.startsWith("CPU") && !strSchCode.startsWith("CIT")) {%> 
      <td align="center" style="font-size:11px;"> <%
	  if(vAdviseList.elementAt(i+4) != null && Float.parseFloat((String)vAdviseList.elementAt(i+4)) > 0f &&
	     vAdviseList.elementAt(i+3) != null && Float.parseFloat((String)vAdviseList.elementAt(i+3)) > 0f){%> 
		 <input type="checkbox" value="1" name="is_lab_only<%=j%>" onClick="SetIsLabOnly(<%=j%>);"<%=strLecLabSelect%>>
        <%}else{%> 
        <!--<img src="../../../images/x.gif">-->
        &nbsp;
        <%}%> </td>
      <td align="center" style="font-size:11px;">
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
        <%}%>	  </td>
<%} // do not show is lec or is lab only for CPU%> 
      <td style="font-size:11px;"> <input type="hidden" name="IS_LAB_ONLY<%=j%>" value="<%=strLecLabStat%>">
	  

<% if (strSchCode.startsWith("CPU")){
		strInputType = "hidden";
		strInputTypeDetails = "";
	}else{
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:11px\"";
	}
	if(bolIsBlockSectionActive) 
		strInputTypeDetails += " readonly='yes' ";
%>	  
	  <input type="<%=strInputType%>" value="<%=strTemp2%>" name="sec<%=j%>" <%=strInputTypeDetails%> <%if(bolIsOnlineAdvising){%>readonly='yes'<%}%>> 
<!--	  
	  <input type="text" value="<%=strTemp2%>" name="sec<%=j%>" size="12" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;">
-->

<% 
	if (strSchCode.startsWith("CPU")){
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:11px\"";
	}else{
		strInputType = "hidden";
		strInputTypeDetails = "";
	}
%>
	    
	  <input type="<%=strInputType%>" value="<%=strTemp%>" name="sec_index<%=j%>"  <%=strInputTypeDetails%>> 
<!--        <input type="hidden" value="<%=strTemp%>" name="sec_index<%=j%>">  -->      </td>
      <td style="font-size:11px;"><label id="_<%=j%>" style="font-size:11px;"><%=WI.getStrValue(strTimeSch)%></label></td>
      <td align="center" style="font-size:11px;"> 
<%
if(bolAuthCheckBox)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="checkbox"<%=strTemp%> name="checkbox<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>" onClick='AddLoad("<%=j%>","<%=(String)vAdviseList.elementAt(i+5)%>")'>      </td>
      <td align="center"> <a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+8)%>","<%=j%>");'><img src="../../../images/schedule.gif" width="40" height="20" border="0"></a></td>
    </tr>
    <% i = i+9;}%>
  </table>
</div>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><div align="center"> <input type="image" src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp; </td>
    </tr>
  </table>
 <%}//end of displaying the advise list if bolShowAdviseList is TRUE
 %>
 <%
 //print error message if vAdviseList is null or not having any information.
 if(vAdviseList == null || vAdviseList.size() ==0)
 {
 strTemp = advising.getErrMsg();
 if(strTemp == null && WI.fillTextValue("showList").compareTo("1") ==0 )
 	strTemp = "Please try again. If same Error continues please contact system admin to check error status.";
 if(strTemp == null) strTemp = "";
 %>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25"><strong><%=strTemp%></strong></td>
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

<input type="hidden" name="stud_type" value="<%=(String)vStudInfo.elementAt(11)%>">


<%} // end of display - if student id is valid
%>
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="showList" value="<%=WI.fillTextValue("showList")%>">
<input type="hidden" name="viewAllAllowedLoad" value="<%=WI.fillTextValue("viewAllAllowedLoad")%>">
<input type="hidden" name="maxAllowedLoad" value="<%=strMaxAllowedLoad%>">
<input type="hidden" name="block_sec"><!-- contains value for block section.-->
<input type="hidden" name="nstp_val_text" value="<%=WI.fillTextValue("nstp_val_text")%>">
<%
strTemp = WI.fillTextValue("accumulatedLoad");
if(strTemp.length() ==0)
	strTemp = "0";
%>
<input type="hidden" name="accumulatedLoad" value="<%=strTemp%>">

<input type="hidden" name="sem" value="<%=WI.fillTextValue("semester")%>">

 <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="win_width" value="<%=WI.fillTextValue("win_width")%>">
<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>">

<input type="hidden" name="online_advising" value="<%=WI.fillTextValue("online_advising")%>">

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
