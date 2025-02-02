<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTempStudId = request.getParameter("temp_id");
	
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
		
	
	int iMaxDisplayed = 0;
	String strDegreeType = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	String strInfo5   = 	WI.getStrValue((String)request.getSession(false).getAttribute("info5"));
	
	if (strSchCode != null && strSchCode.startsWith("CPU"))
		strTemp = "_cpu";
	else
		strTemp = "";
				

	Vector[] vAutoAdvisedList = new Vector[2];


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-advising-new","advising_new.jsp");
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
														"advising_new.jsp");
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
boolean bolAutoAdvise = false;
boolean bolShowAdviseList = false;
Vector vAdviseList = new Vector();//filled up by auto advise, 0=sec index,1=section, 2=cur index.
Vector vStudInfo = null;
String strInputType = null;
String strInputTypeDetails = null;

String strBatchNumber = null;///used for SWU.. 

Vector vEnrolledList = null;//only if student is advised already.

Advising advising = new Advising();
enrollment.AdvisingExtn advExtn = new enrollment.AdvisingExtn();


if(bolIsOnlineAdvising)
	advising.setOnlineAdvising();//enables pre-req even if disabled

//if(request.getParameter("sy_from") == null || request.getParameter("sy_from").trim().length() ==0 ||
//	request.getParameter("sy_to") == null || request.getParameter("sy_to").trim().length() ==0 || 
//	WI.fillTextValue("temp_id").length() ==0)
//{
//	strErrMsg = "Please enter ID/School Year.";
//}

if(strErrMsg == null)
{
	vStudInfo = advising.getStudInfo(dbOP,strTempStudId);
		
	if(vStudInfo == null)
		strErrMsg = advising.getErrMsg();
	else /// do all processing here.
	{
	
		if(strSchCode.startsWith("SWU")) {
			strBatchNumber = "select section_name_ from new_application where application_index = "+vStudInfo.elementAt(0);
			strBatchNumber = dbOP.getResultOfAQuery(strBatchNumber, 0) ;
		}
		
		//check if it is auto advise or show list.
		if(WI.fillTextValue("showList").compareTo("1") ==0) // show list.
		{
			bolShowAdviseList = true;

			vAdviseList = advising.getAdvisingListForNew(dbOP, (String)vStudInfo.elementAt(2),
			                (String)vStudInfo.elementAt(3), false,(String)vStudInfo.elementAt(16),
							(String)vStudInfo.elementAt(17),(String)vStudInfo.elementAt(18),
							 (String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5),null,
							 strTempStudId);//System.out.println(vAdviseList);
			
			
		}
		else if(WI.fillTextValue("autoAdvise").compareTo("1") ==0)
		{
			bolAutoAdvise = true;bolShowAdviseList = true;
			//vAdviseList = advising.getAdvisingListForNew(dbOP, request.getParameter("ci"), true);
			vAutoAdvisedList = advising.autoAdviseForNew(dbOP,(String)vStudInfo.elementAt(2), (String)vStudInfo.elementAt(3),
				request.getParameter("sy_from"), request.getParameter("sy_to"),request.getParameter("syf"),
				request.getParameter("syt"),"1","1",request.getParameter("current_sem"));

			if(vAutoAdvisedList == null) strErrMsg = advising.getErrMsg();
			else
			{
				vAdviseList = vAutoAdvisedList[0];
			}
		}
		else if(WI.fillTextValue("ViewAllAllowedList").compareTo("1") ==0)
		{
			bolShowAdviseList = true;
			//advising.getAllAllowedList(dbOP,request.getAttribute("ci"),String strStudId);
		}
	}

	if(vAdviseList != null && vAdviseList.size() > 0)
	{
		strMaxAllowedLoad = (String)vAdviseList.elementAt(0);//this is having max allowed load.
		if(WI.fillTextValue("temp_id").equals("11-4040-649"))
			strMaxAllowedLoad = "26";
	}
}//if school year is entered.
if(vStudInfo != null)
{
	//if student status is not for new --> forward to advising_transfree.jsp ;-), that page will take care of degree type.
	if( ((String)vStudInfo.elementAt(11)).compareToIgnoreCase("new") != 0)
	{
		dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./advising_transferee.jsp?stud_id="+strTempStudId+
			"&sy_from="+(String)vStudInfo.elementAt(16)+"&sy_to="+(String)vStudInfo.elementAt(17)+
			"&semester="+(String)vStudInfo.elementAt(18)+"&online_advising="+WI.fillTextValue("online_advising")));
		return;
	}
	strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",
                                       (String)vStudInfo.elementAt(2), "degree_type",
                                       " and is_valid=1 and is_del=0");

	if(strDegreeType == null)
		strErrMsg = "Error in getting course degree type.";
	else
	{
		if(strDegreeType.equals("1"))
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./advising_masters_doctoral.jsp?stud_id="+
				strTempStudId+"&sy_from="+(String)vStudInfo.elementAt(16)+ 	"&sy_to="+(String)vStudInfo.elementAt(17)+
					"&semester="+(String)vStudInfo.elementAt(18)+"&online_advising="+WI.fillTextValue("online_advising")));

			return;
		}
		else if(strDegreeType.equals("2"))
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./advising_medicine.jsp?stud_id="+strTempStudId+
						"&sy_from="+(String)vStudInfo.elementAt(16)+ 	"&sy_to="+(String)vStudInfo.elementAt(17)+
						"&semester="+(String)vStudInfo.elementAt(18)+"&online_advising="+WI.fillTextValue("online_advising")));

			return;
		}
/*		else if(strDegreeType.compareTo("4") ==0) {//non semestral
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./advising_nonsem.jsp?temp_id="+strTempStudId+"&sy_from="+WI.fillTextValue("sy_from")+
			"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")));

			return;
		}*/
		//System.out.println(vStudInfo);
		//remove advising if called to remove all
		if(WI.fillTextValue("invalidate_advising").length() > 0) {
			enrollment.NAApplicationForm naApplForm = new enrollment.NAApplicationForm();
			if(!naApplForm.invalidateAdvising(dbOP, true, WI.fillTextValue("temp_id"),
				(String)request.getSession(false).getAttribute("userId"), 
				(String)request.getSession(false).getAttribute("login_log_index"),WI.fillTextValue("sy_from"), 
				WI.fillTextValue("sy_to"), WI.fillTextValue("semester")) ) 
				strErrMsg = naApplForm.getErrMsg();
		}
		
		vEnrolledList =  new enrollment.EnrlAddDropSubject().getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),strDegreeType,
							WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(18),true);//System.out.println(vEnrolledList);
		
		/*** add this code to include the subjects taken from other course to the list of advise subject.. **/
		if(vEnrolledList != null && vEnrolledList.size() > 0 && vAdviseList != null && vAdviseList.size() > 0) {
			int iIndexOfTemp = 0;
			Vector vTempEnrlList = new Vector();
			for(int i = 1; i < vEnrolledList.size(); i += 14) 
				vTempEnrlList.addElement(vEnrolledList.elementAt(i + 2));
			for(int i = 1; i < vAdviseList.size(); i += 10) {
				iIndexOfTemp = vTempEnrlList.indexOf(vAdviseList.elementAt(i + 8));
				if(iIndexOfTemp == -1)
					continue;
				vTempEnrlList.remove(iIndexOfTemp);
			}
			if(vTempEnrlList.size() > 0) {
				for(int i = 1; i < vEnrolledList.size(); i += 14) {
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
					vAdviseList.addElement(vEnrolledList.elementAt(i + 2));
					vAdviseList.addElement(vEnrolledList.elementAt(i + 2));
				}			
			}
		}
		/*** End of code to include the subjects taken from other course to the list of advise subject.. **/
		
		//System.out.println("vEnrolledList: "+vEnrolledList);
		//System.out.println("vAdviseList: "+vAdviseList);
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



//if true, user is advising for block section alone.. 
boolean bolIsEligibleForBlock = true;
String strIsBlockFoced = "0";
boolean bolIsBlockSectionActive = false;
Vector vForcedBlock = null;
if( vAdviseList != null && vAdviseList.size() > 0) {
	enrollment.SubjectSection SS = new enrollment.SubjectSection();
	vForcedBlock = SS.getForcedBlockSectionList(dbOP, request, request.getParameter("sy_from"), request.getParameter("semester"));
	
	strTemp = (String)vAdviseList.remove(0);
	bolIsEligibleForBlock = SS.isStudentAllowedForBlock(dbOP, request, request.getParameter("semester"), (String)vStudInfo.elementAt(6), 
								(String)vStudInfo.elementAt(2), (String)vStudInfo.elementAt(3), (String)vStudInfo.elementAt(4), (String)vStudInfo.elementAt(5), 
								vAdviseList);
	vAdviseList.insertElementAt(strTemp, 0);

	//I have to make bolIsForecedBlock to true if block section is selcted. 
	if(vForcedBlock != null && vForcedBlock.size() > 0) {
		bolIsBlockSectionActive = true;
		
		//System.out.println(vEnrolledList);
		//System.out.println(vEnrolledList.size());
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

//System.out.println("Forced Block: "+strIsBlockFoced);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Advising New Students</title>
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
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
<% if (strSchCode.startsWith("CPU")){%>
		if(	eval('document.advising.sec_index'+i+'.value.length')> 0)
<%}else{%>
		if(	eval('document.advising.sec'+i+'.value.length')> 0)
<%}%>
		{
			totalLoad += Number(eval('document.advising.checkbox'+i+'.value'));
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
<% if (strSchCode.startsWith("CPU")){%>
		if(	eval('document.advising.sec_index'+index+'.value.length') == 0){
			alert ("Please enter stub code for the subject");
			return;
		}
<%}else{%>
		if(	eval('document.advising.sec'+index+'.value.length') == 0){
			alert ("Please enter section for the subject");
			return;
		}
<%}%>	
	
	
		document.advising.sub_load.value = Number(document.advising.sub_load.value) + Number(subLoad);
		if( Number(document.advising.sub_load.value) > Number(document.advising.maxAllowedLoad.value))
			alert("Student can't take more than allowed load <"+document.advising.maxAllowedLoad.value+">.Please re-adjust load.");
	}
	else //subtract.
		document.advising.sub_load.value = Number(document.advising.sub_load.value) - Number(subLoad);
	if( Number(document.advising.sub_load.value) < 0)
		document.advising.sub_load.value = 0;

}
function LoadPopup(secName,sectionIndex,strCurIndex, strSubIndex, strIndexOf)//I have to use combination of subject,course and major.
{
	<%if(strIsBlockFoced.equals("1")){%>
		alert("Individual Scheduling is locked.");
		return;
	<%}%>
//this will check conflict with the schedule of other subjects taken. pass user id, all the sub_section_index,
//if check box is not checked - it is considered as not selected.
	var subSecList = "";
	var strSubSecStartsWith = "";
	if(eval('document.advising.sec'+strIndexOf+'.value.length') > 0)
		strSubSecStartsWith = eval('document.advising.sec'+strIndexOf+'.value');
	for(var i = 0; i< document.advising.maxDisplay.value; ++i) {
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
	if(subSecList.length == 0) subSecList = "0";
	//alert(subSecList);

	var loadPg = "./subject_schedule.jsp?form_name=advising&cur_index="+strCurIndex+
		"&sub_index="+strSubIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.advising.sy_from.value+"&syt="+document.advising.sy_to.value+"&semester="+document.advising.current_sem.value+
		"&sec_index_list="+subSecList+"&course_index="+document.advising.ci.value+
		"&major_index="+document.advising.mi.value+"&degree_type="+document.advising.degree_type.value+"&index_of_="+strIndexOf+	"&sec_startsWith="+escape(strSubSecStartsWith) +
		"&year_level=" + document.advising.year_level.value+"&line_number="+strIndexOf+"&online_advising="+document.advising.online_advising.value;

	if (eval('document.advising.nstp_val'+strIndexOf)){
		loadPg += "&nstp_val=" + eval('document.advising.nstp_val'+strIndexOf+	
										'[document.advising.nstp_val'+strIndexOf+'.selectedIndex].text');
	}

	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function Validate()
{
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
		//I have to check if student has taken subject with zero load.
		var maxDisp = document.advising.maxDisplay.value;
		var iOneChecked = 0; 
		for(var i =0; i< maxDisp; ++i) {
			if(eval('document.advising.checkbox'+i+'.checked') ){
				iOneChecked++;
			}
			
			if (eval("document.advising.checkbox"+i+".checked")){
<% if (strSchCode.startsWith("CPU")) { %>
				if (eval("document.advising.sec_index"+i+".value.length") ==0){
					alert("Missing stub code for " + eval("document.advising.sub_code"+i+".value"));
					return false; 
				} 
<%}else{%>
				if (eval("document.advising.sec"+i+".value.length") ==0){
					alert("Missing Section for " + eval("document.advising.sub_code"+i+".value"));
					return false; 
				} 
<%}%> 
				iOneChecked++;
			}
		}
		if(iOneChecked == 0) {
			alert("Sudent load can't be zero.");
			return false;
		}
	}
	if( document.advising.current_sem.value.length ==0)
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
	document.advising.autoAdvise.value = "";
	document.advising.showList.value = "1";
	var strMajorIndCon = document.advising.mi.value;
	if(strMajorIndCon.length == 0)
		strMajorIndCon = "";
	else
		strMajorIndCon="&mi="+strMajorIndCon;
	var loadPg = "./block_section<%=strTemp%>.jsp?form_name=advising&max_disp="+document.advising.maxDisplay.value+"&ci="+
		document.advising.ci.value+strMajorIndCon+"&syf="+document.advising.syf.value+
	 	"&syt="+document.advising.syt.value+"&sy_from="+document.advising.sy_from.value+"&sy_to="+document.advising.sy_to.value+
	 	"&offering_sem="+document.advising.current_sem.value+
	 	"&year_level=1&semester=1&cn="+escape(document.advising.cn.value)+"&mn="+escape(document.advising.mn.value)+"&online_advising="+document.advising.online_advising.value;
	//alert(loadPg);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage()
{
	document.advising.action="./advising_new.jsp";
	this.SubmitOnce('advising');
}
function focusID() {
	document.advising.temp_id.focus();
}
<%if(!bolIsOnlineAdvising){%>
	function OpenSearch() {
		var pgLoc = "../../../search/srch_stud_temp.jsp?opner_info=advising.temp_id&is_advised=1&sy_from="+
		document.advising.sy_from.value+"&sy_to="+ document.advising.sy_to.value;
		var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
<%}%>
function UpdateNSTPText(){
	if (document.advising.nstp_val) {
		document.advising.nstp_val_text.value = 
				document.advising.nstp_val[document.advising.nstp_val.selectedIndex].text ;
	}
}

<%if(!bolIsOnlineAdvising){%>

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.advising.temp_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_temp=1&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.advising.temp_id.value = strID;
	document.advising.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.advising.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
<%}%>

function updatePlanFatima() {
	<%if(vStudInfo == null || vStudInfo.size() == 0) {%>
		return;
	<%}else{%>
	
	var strCurID = "<%=WI.fillTextValue("temp_id")%>";
	if(strCurID != document.advising.temp_id.value) {
		document.advising.submit();
		return;
	}
	
	var strPlanRef = document.advising.plan_ref[document.advising.plan_ref.selectedIndex].value;
	//alert(strPlanRef);

	var strParam = "stud_ref=<%=(String)vStudInfo.elementAt(0)%>&sy_from=<%=(String)vStudInfo.elementAt(16)%>"+
					"&semester=<%=(String)vStudInfo.elementAt(18)%>&is_tempstud=<%=(String)vStudInfo.elementAt(10)%>&new_plan="+strPlanRef;
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
	return;
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

<body <%if(!bolIsForwarded){%>onLoad="focusID();alertSize();CallSelALL();"<%}else{%>onLoad="CallSelALL();"<%}%>>
<form name="advising" action="./advising_new.jsp" method="post" onSubmit="return Validate();">
<input type="hidden" name="degree_type" value="<%=WI.getStrValue(strDegreeType)%>">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" bgcolor="#A49A6A" align="center"><strong> <font color="#FFFFFF">
        :::: NEW STUDENT ADVISING PAGE :::: </font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="8"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="top">
      <td width="1%" height="25">&nbsp;</td>
      <td width="21%" height="25"> Temporary Student ID </td>
      <td width="19%" height="25">
	  	<input name="temp_id" type="text" size="16" value="<%=WI.fillTextValue("temp_id")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"
		<%if(bolIsForwarded){%> readonly="yes" style="font-size:16px; border:0px; font-weight:bold" <%}else{%> onKeyUp="AjaxMapName('1');"<%}%>>
      </td>
      <td width="19%" height="25"><%if(!bolIsForwarded){%><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" ></a><%}%>      </td>
        <%if(vEnrolledList != null)
			strTemp = "class=\"thinborderALL\"";
		  else
		  	strTemp = "";
		
		%>

      <td colspan="2" <%=strTemp%>> &nbsp;
        <%if(vEnrolledList != null){%>
	  	<font size="3" color="#0000FF"><b>Student is advised already. <a href="javascript:InvalidateAdvising();">Click Here to remove all</a></b></font>
	  <%}%>
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>
      </td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="21%" height="25">School Year </td>
      <td width="19%" height="25">
<%
strTemp = WI.fillTextValue("sy_from");

if (strTemp.length() == 0 && vStudInfo != null){
	strTemp = (String)vStudInfo.elementAt(16);
}

//if(strTemp.length() ==0)
//	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox_noborder"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("advising","sy_from","sy_to")' readonly>
         
<%
strTemp = WI.fillTextValue("sy_to");

if (strTemp.length() == 0 && vStudInfo != null){
	strTemp = (String)vStudInfo.elementAt(17);
}

%>        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox_noborder"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
      </td>
      <td width="19%" height="25">
<%if(!bolIsForwarded){%>
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0" onClick="ResetSelALL();"> </a>      
<%}%>
	  </td>
      <td colspan="2">
<%if(!bolIsForwarded){%>
	  <a href="javascript:ReloadPage();"> </a>&nbsp;<a href="./advising_new.jsp"><img src="../../../images/clear.gif" width="56" height="19" border="0"></a> 
<%}%>
      </td>
    </tr>
<%
if(strErrMsg != null)
{%>	<tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="4"><strong><%=strErrMsg%></strong></td>
        <td width="16%"></td>
    </tr>
<%}%>
<%if( (strSchCode.startsWith("FATIMA") || strInfo5.startsWith("jonelta")) && vStudInfo != null){
//get here if already set plan.
	String strStudFatimaPlanRef = null;
	enrollment.FAStudMinReqDP faMinDP = new enrollment.FAStudMinReqDP(dbOP);
	Vector vStudInstallmentPlanFatima = faMinDP.getPlanInfoOfAStudent(dbOP, (String)vStudInfo.elementAt(16), (String)vStudInfo.elementAt(18), (String)vStudInfo.elementAt(0), true);
	if(vStudInstallmentPlanFatima != null && vStudInstallmentPlanFatima.size() > 0)
		strStudFatimaPlanRef = (String)vStudInstallmentPlanFatima.elementAt(0);
%>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
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
        <td width="16%"></td>
    </tr>
<%}%>	
  </table>
<% if(strErrMsg == null){//show everything below this.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student Status : <strong>NEW</strong></td>
      <td  colspan="2" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="62%" height="25">Student name  :<strong>
        <%=(String)vStudInfo.elementAt(1)%>
        <input name="stud_name" value="<%=(String)vStudInfo.elementAt(1)%>" type="hidden">
      </strong></td>
      <td  colspan="2" height="25">Year level: <strong>
        <%
	  if(strDegreeType.equals("1") || strDegreeType.equals("4")){%>
        N/A
        <%}else{%>
        1st year
        <%}%>
        </strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course :<strong><%=(String)vStudInfo.elementAt(7)%>
        <%
	  if(vStudInfo.elementAt(8) != null){%>
        - <%=(String)vStudInfo.elementAt(8)%>
        <%}%>
        </strong></td>
      <td  colspan="2" height="25">Term:
        <%
//strTemp = WI.fillTextValue("current_sem");
int iTempo = Integer.parseInt((String)vStudInfo.elementAt(18));
if(iTempo == 0)
	strTemp = "Summer";
else if(iTempo == 1) strTemp = "1st Semester";
else if(iTempo == 2) strTemp = "2nd Semester";
else if(iTempo == 3) strTemp = "3rd Semester";
else if(iTempo == 4) strTemp = "4th Semester";
if(strBatchNumber != null) {
	if(iTempo == 1) strTemp = "1st Term";
	else if(iTempo == 2) strTemp = "2nd Term";
	else if(iTempo == 3) strTemp = "3rd Term";
	else if(iTempo == 4) strTemp = "4th Term";
	else if(iTempo == 4) strTemp = "5th Term";
}


%>
        <strong><%=strTemp%></strong> <input type="hidden" name="current_sem" value="<%=(String)vStudInfo.elementAt(18)%>">
        <!--  <select name="current_sem">
	<option value="1">1st</option>
	<%if(strTemp.compareTo("2") ==0){%>
	<option value="2" selected>2nd</option>
	<%}else{%>
	<option value="2">2nd</option>
	<%}if(strTemp.compareTo("3") ==0){%>
	<option value="3" selected>3rd</option>
	<%}else{%>
	<option value="3">3rd</option>
	<%}%>  </select>-->
      </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Curriculum SY :<strong><%=(String)vStudInfo.elementAt(4)%>
        - <%=(String)vStudInfo.elementAt(5)%></strong></td>
      <td height="26" style="font-weight:bold; font-size:22px;"><%if(strBatchNumber != null) {%>Batch: <%=strBatchNumber%><%}%></td>
      <td width="9%" height="26">&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3"><hr size="1"></td>
    </tr>
 </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
boolean bolAllowAfterCheckDPRule = true;
//if(bolShowAdviseList)
	bolAllowAfterCheckDPRule = advising.shouldWeAdviseCheckOnDownPmt(dbOP, (String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(0), 
								(String)vStudInfo.elementAt(16), (String)vStudInfo.elementAt(17), (String)vStudInfo.elementAt(18));
	//System.out.println(advising.getErrMsg());
 
 if(!bolAllowAfterCheckDPRule) {
 	bolShowAdviseList = false;
	strErrMsg = advising.getErrMsg();
  }else{%>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td  width="26%" height="25"><a href="javascript:ViewCurriculum();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click
        to view student's course curriculum</font></td>
      <td width="39%" height="25"><a href="javascript:ShowList();"><img src="../../../images/show_list.gif" width="57" height="34" border="0" onClick="ResetSelALL();"></a><font size="1">click
        to show list of subjects student may take for the semester</font></td>
      <!--
      <td width="30%" height="25">
	  <a href="javascript:AutoAdvise();">
	  	<img src="../../../images/advise.gif" width="42" height="37" border="0"></a><font size="1">click
        to generate auto advise subjects</font>
	  </td>
-->
    </tr>
<%}
if(bolAutoAdvise)
strErrMsg = advising.getErrMsg();
 if(strErrMsg == null) strErrMsg = "";
 %>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="3"><strong><%=strErrMsg%></strong></td>
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
if(vEnrolledList != null && vEnrolledList.size() > 0) 
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
      <td width="10%"><input name="image" type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
  </table>
<div class="messageBox" id="div_msgBox">
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFDD">
    <tr bgcolor="#CCCCCC">
      <td width="3%" height="25" align="center"><strong><font size="1">YEAR</font></strong></td>
      <td width="2%" height="25" align="center"><strong><font size="1">TERM</font></strong></td>
      <td width="10%" height="25" align="center"><strong><font size="1">SUBJECT CODE</font></strong></td>
      <td width="20%" align="center"><strong><font size="1">SUBJECT TITLE </font></strong></td>
      <td width="5%" align="center"><strong><font size="1">LEC/LAB</font></strong></td>
      <td width="5%" align="center"><strong><font size="1">TOTAL UNITS</font></strong></td>
      <td width="5%" align="center"><strong><font size="1">UNITS TO TAKE</font></strong></td>
<%
	if (strSchCode.startsWith("CPU"))
		strTemp = "STUB CODE";
	else
		strTemp = "SECTION";
%>
      <td width="12%" align="center"><strong><font size="1"><%=strTemp%></font></strong></td>
      <td width="20%" align="center"><strong><font size="1">SCHEDULE</font></strong></td>
      <td width="5%" align="center"><strong><font size="1">SELECT 
		<% if (!strSchCode.startsWith("CPU")) {%> ALL <%}%>
	  </font></strong>
        <br> <input type="checkbox" name="selAll" value="0" 
		<%if(strIsBlockFoced.equals("1")){%>onClick="return false"<%}else{%>onClick="checkAll();"<%}%>></td>
      <td width="8%" align="center"><strong><font size="1">ASSIGN SECTION</font></strong></td>
    </tr>
    <% int iTemp = 0;
//vAutoAdvisedList[1] is having the advised list = [0]=sub section index,[1]=section,[2]=sub_code
String strTemp2 = null;//System.out.println(vAutoAdvisedList[1].toString());

//only if vEnrolledList is not null and block section is not called.
String strEnrolledNSTPVal = null;
String strUnitEnrolled    = null; int iIndexOf = 0;//System.out.println(vEnrolledList);
boolean bolAuthCheckBox   = false;

String strTimeSch = null;
for(int i = 1,j=0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed) {
 	strTimeSch = null;

	strEnrolledNSTPVal = null;bolAuthCheckBox   = false;
	strTemp = ""; strTemp2 = "";
	if( vAutoAdvisedList[1] != null && (iTemp = vAutoAdvisedList[1].indexOf(vAdviseList.elementAt(i+6))) != -1)
	{
		strTemp = (String)vAutoAdvisedList[1].elementAt(iTemp-2); //section index.
		strTemp2 = (String)vAutoAdvisedList[1].elementAt(iTemp-1);//section name.
	}
	else if(WI.fillTextValue("block_sec").length()>0 && WI.getStrValue(vAdviseList.elementAt(i+1)).equals("1") && ((String)vStudInfo.elementAt(18)).equals(vAdviseList.elementAt(i+2)) ) {
		if (!strSchCode.startsWith("CPU")){
		strTemp2 = request.getParameter("block_sec");
		strTemp = advising.getSubSecIndex(dbOP,(String)vAdviseList.elementAt(i),strTemp2,
						request.getParameter("sy_from"),
				  		request.getParameter("sy_to"),request.getParameter("current_sem"),
						strDegreeType);
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
			strTimeSch = (String)vEnrolledList.elementAt(iIndexOf + 2);

			strTemp2 = (String)vEnrolledList.elementAt(iIndexOf + 3);
			strTemp  = (String)vEnrolledList.elementAt(iIndexOf + 1);

			strUnitEnrolled    = (String)vEnrolledList.elementAt(iIndexOf + 9);
			strEnrolledNSTPVal = (String)vEnrolledList.elementAt(iIndexOf - 1);bolAuthCheckBox   = true;
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
			vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);
		}
	}

%>
    <tr onDblClick='LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+8)%>","<%=j%>");'
	 class="nav" id="msg<%=j%>" onMouseOver="navRollOver('msg<%=j%>', 'on')" onMouseOut="navRollOver('msg<%=j%>', 'off')">
      <td height="20" align="center" style="font-size:11px;">
        <!-- all the hidden fileds are here. -->
        <input type="hidden" name="sub_code<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>">
        <input type="hidden" name="sub_name<%=j%>" value="<%=(String)vAdviseList.elementAt(i+7)%>">
        <input type="hidden" name="lab_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+4)%>">
        <input type="hidden" name="lec_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+3)%>">
        <input type="hidden" name="total_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>">
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vAdviseList.elementAt(i)%>">
		<input type="hidden" name="ut<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>">
        <%=WI.getStrValue(vAdviseList.elementAt(i+1),"&nbsp;")%></td>
      <td align="center" style="font-size:11px;"><%=WI.getStrValue(vAdviseList.elementAt(i+2),"&nbsp;")%></td>
      <td style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+6)%>
	  <%if( ((String)vAdviseList.elementAt(i+6)).indexOf("NSTP") != -1 || ((String)vAdviseList.elementAt(i+7)).indexOf("ROTC") != -1){
if(strEnrolledNSTPVal == null)
	strEnrolledNSTPVal = WI.fillTextValue("nstp_val");
%>
        <select name="nstp_val<%=j%>" style="font-weight:bold;">
<%=dbOP.loadCombo("distinct NSTP_VAL","NSTP_VAL"," from NSTP_VALUES order by NSTP_VALUES.NSTP_VAL asc", strEnrolledNSTPVal, false)%>
</select>
<%}//only if subject is NSTP %>  	  </td>
      <td style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+7)%></td>
      <td align="center" style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+3)%>/<%=(String)vAdviseList.elementAt(i+4)%></td>
      <td align="center" style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+5)%></td>
      <td align="center" style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+5)%></td>
      <td style="font-size:11px;"> 

<% if (strSchCode.startsWith("CPU")){
		strInputType = "hidden";
		strInputTypeDetails = "";
	}else{
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:11px;\"";
	}
	if(strIsBlockFoced.equals("1") || bolIsBlockSectionActive)
		strInputTypeDetails += " readonly='yes'";

%>	  
	  <input type="<%=strInputType%>" value="<%=strTemp2%>" name="sec<%=j%>" <%=strInputTypeDetails%>> 
<!--	  
	  <input type="text" value="<%=strTemp2%>" name="sec<%=j%>" size="12" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;">
-->

<% 
	if (strSchCode.startsWith("CPU")){
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:11px;\"";
	}else{
		strInputType = "hidden";
		strInputTypeDetails = "";
	}
%>
	    
	  <input type="<%=strInputType%>" value="<%=strTemp%>" name="sec_index<%=j%>"  <%=strInputTypeDetails%>> 
<!--        <input type="hidden" value="<%=strTemp%>" name="sec_index<%=j%>">  -->      </td>

      <td>
	  	<label id="_<%=j%>" style="font-size:11px;"><%=WI.getStrValue(strTimeSch)%></label>	  </td>
      <td align="center"> 
<%
if(bolAuthCheckBox)
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox"<%=strTemp%> name="checkbox<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>" 
	  <%if(strIsBlockFoced.equals("1")){%>onClick="return false"<%}else{%>onClick='AddLoad("<%=j%>","<%=(String)vAdviseList.elementAt(i+5)%>")'<%}%>><!--makes it readonly.-->      </td>
      <td align="center">
	  <%if(strIsBlockFoced.equals("1")){%>N/A<%}else{%>
	  <a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+8)%>","<%=j%>");'><img src="../../../images/schedule.gif" width="40" height="20" border="0"></a>
	  <%}%>
	  </td>
    </tr>
    <% i = i+9;}%>
  </table>
</div>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8"><div align="center"> <input type="image" src="../../../images/form_proceed.gif"></div></td>
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
      <td colspan="6" height="25">
	  <font size="3"><strong><%=strTemp%></strong></font></td>
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
<input type="hidden" name="nstp_val_text" value="<%=WI.fillTextValue("nstp_val_text")%>">


<%} // end of display - if student id is valid
%>
<input type="hidden" name="semester" value="1">
<input type="hidden" name="reloadPage" value="0">
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
<input type="hidden" name="stud_type" value="New/Regular">

<input type="hidden" name="year_level" value="1"%>
<input type="hidden" name="sem" value="1">

<input type="hidden" name="win_width" value="<%=WI.fillTextValue("win_width")%>">
<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>">
<input type="hidden" name="online_advising" value="<%=WI.fillTextValue("online_advising")%>">

<input type="hidden" name="is_forced_block" value="<%=strIsBlockFoced%>">

<input type="hidden" name="invalidate_advising" value="">

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
