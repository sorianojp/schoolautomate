<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strStudID = request.getParameter("stud_id");
	int iMaxDisplayed = 0;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";	
	String strInfo5 = WI.getStrValue((String)request.getSession(false).getAttribute("info5"));
	
	boolean bolIsCalledFrOnlineRegdStud = false;//System.out.println(WI.fillTextValue("online_advising"));
	if(WI.fillTextValue("online_advising").equals("1")) {
		bolIsCalledFrOnlineRegdStud = true;
		strStudID = null;
		if(request.getSession(false).getAttribute("tempId") != null)
			strStudID = (String)request.getSession(false).getAttribute("tempId");
		else if(request.getSession(false).getAttribute("userId") != null)
			strStudID = (String)request.getSession(false).getAttribute("userId");
		if(strStudID == null)
			bolIsCalledFrOnlineRegdStud = false;
		//System.out.println(bolIsCalledFrOnlineRegdStud);
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-advising-new","advising_masters_doctoral.jsp");
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
if(bolIsCalledFrOnlineRegdStud)
	iAccessLevel = 2;
else	
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"advising_masters_doctoral.jsp");
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
Vector vAdviseList = new Vector();//filled up by auto advise, 0=sec index,1=section, 2=cur index.
Vector vStudInfo = new Vector();
String strInputType = null;
String strInputTypeDetails = null;

boolean bolIsTempStud = false;

Vector vEnrolledList = null;

Advising advising = new Advising();

if(bolIsCalledFrOnlineRegdStud)
	advising.setOnlineAdvising();//enables pre-req even if disabled

if(WI.fillTextValue("sy_from").length() ==0 || WI.fillTextValue("sy_to").length() ==0)
{
	strErrMsg = "Please enter School Year.";
}

if(strErrMsg == null)
{
	vStudInfo = advising.getStudInfo(dbOP,strStudID, WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
										WI.fillTextValue("semester"));
	if(vStudInfo == null)
		strErrMsg = advising.getErrMsg();
	else /// get allowed sub list.
	{
		if(!vStudInfo.elementAt(10).equals("0")) 
			bolIsTempStud = true;
			
		vAdviseList = advising.getAdvisingListForMasteral(dbOP,strStudID,
                         (String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),
						 WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
						 WI.fillTextValue("semester"),(String)vStudInfo.elementAt(4),
						 (String)vStudInfo.elementAt(5));
		if(vAdviseList == null || vAdviseList.size() ==0)
		{
			strErrMsg = advising.getErrMsg();
		}
		else {
			vEnrolledList =  new enrollment.EnrlAddDropSubject().getEnrolledList(dbOP,
						(String)vStudInfo.elementAt(0),"1",
						WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
						WI.fillTextValue("semester"),bolIsTempStud,true);

		/*** add this code to include the subjects taken from other course to the list of advise subject..
		-- I have to get other information in vEnrolledList
		//System.out.println(vEnrolledList.size());
		//System.out.println(vEnrolledList);
		if(vEnrolledList != null && vEnrolledList.size() > 0 && vAdviseList != null && vAdviseList.size() > 0) {
			int iIndexOfTemp = 0;
			Vector vTempEnrlList = new Vector();
			for(int i = 1; i < vEnrolledList.size(); i += 15) 
				vTempEnrlList.addElement(vEnrolledList.elementAt(i + 2));
			for(int i = 0; i < vAdviseList.size(); i += 10) {
				iIndexOfTemp = vTempEnrlList.indexOf(vAdviseList.elementAt(i + 5));
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
		}**/
		/*** End of code to include the subjects taken from other course to the list of advise subject.. **/



		}
	}

//	if(vAdviseList != null && vAdviseList.size() > 0)
//	{
//		strMaxAllowedLoad = (String)vAdviseList.elementAt(0);//this is having max allowed load.
//	}
}//if school year is entered.

// additional setting to force stop / or allow advising.. 
// setting is in System Admin -> Set param -> Enrollment advising setting.
double dOutstanding      = 0d;

//check if student is having outstanding balance.
if(vStudInfo != null && vStudInfo.size() > 0 && !bolIsTempStud) {
	if(!strSchCode.startsWith("CIT")) {
		enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
		fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0), WI.fillTextValue("sy_from"),
									WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
		dOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));
	}
	enrollment.SetParameter sParam = new enrollment.SetParameter();
	boolean bolShowAdviseList = sParam.allowAdvising(dbOP, (String)vStudInfo.elementAt(0), dOutstanding, 
											WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
	if(!bolShowAdviseList) {
		strErrMsg = sParam.getErrMsg();
		vAdviseList = null;
	}
	//System.out.println(bolShowAdviseList);
	//System.out.println(sParam.getErrMsg());
	
}

boolean bolIsForwarded = WI.fillTextValue("is_forwarded").equals("1");
if(bolIsCalledFrOnlineRegdStud)
	bolIsForwarded  = true;

String strReadOnlyUnitToTake = "";
if(strSchCode.startsWith("UB") || bolIsCalledFrOnlineRegdStud)
	strReadOnlyUnitToTake = " readonly='yes' style='border:0px;' ";
else	
	strReadOnlyUnitToTake = " style='font-size:11px;'";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
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
	if(totalLoad == 0)
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

function AddRecord()
{
	document.advising.addRecord.value = 1;
	ReloadPage();//document.advising.submit();
}
function ViewCurriculum()
{
	var pgLoc = "";
	if(document.advising.mn.value.length > 0)
		pgLoc = "../../admission/curriculum_page1.jsp?ci="+document.advising.ci.value+"&cname="+
			escape(document.advising.cn.value)+"&mi="+document.advising.mi.value+"&mname="+escape(document.advising.mn.value)+"&syf="+
			document.advising.syf.value+"&syt="+document.advising.syt.value+"&goNextPage=1&degree_type=1";
	else
		pgLoc = "../../admission/curriculum_page1.jsp?ci="+document.advising.ci.value+"&cname="+escape(document.advising.cn.value)+
			"&syf="+document.advising.syf.value+"&syt="+document.advising.syt.value+"&goNextPage=1&degree_type=1";
	pgLoc += "&online_advising="+document.advising.online_advising.value;
	
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
	}
	else //subtract.
		document.advising.sub_load.value = Number(document.advising.sub_load.value) - Number(subLoad);
	if( Number(document.advising.sub_load.value) < 0)
		document.advising.sub_load.value = 0;

}
function LoadPopup(secName,sectionIndex, strCurIndex,strSubIndex, strIndex) //curriculum index is different for all courses.
{
//this will check conflict with the schedule of other subjects taken. pass user id, all the sub_section_index,
//if check box is not checked - it is considered as not selected.
	var subSecList = "";
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
	}
	if(subSecList.length == 0) subSecList = "0";

	var loadPg = "./subject_schedule.jsp?form_name=advising&cur_index="+strCurIndex+
		"&sub_index="+strSubIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.advising.sy_from.value+"&syt="+document.advising.sy_to.value+"&semester="+document.advising.sem.value+
		"&sec_index_list="+subSecList+"&course_index="+document.advising.ci.value+
		"&major_index="+document.advising.mi.value+"&degree_type=1&line_number="+strIndex+"&online_advising="+document.advising.online_advising.value;
	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=200,left=150,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function Validate()
{
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

	if( document.advising.sem.value.length ==0)
	{
		alert("Please enter the enrolling semester of the student.");
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

/**
function Validate()
{
	<%if(strSchCode.startsWith("FATIMA")){%>
		if(document.advising.plan_ref.selectedIndex == 0) {
			if(!confirm("Please click OK if student does not have any plan"))
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
		alert("Sudent load can't be zero.");
		return false;
	}
	if( document.advising.sem.value.length ==0)
	{
		alert("Please enter the enrolling semester of the student.");
		return false;
	}
	document.advising.action="./gen_advised_schedule.jsp";
	document.advising.submit();
	return true;
}
**/

function ReloadPage()
{
	document.advising.action="./advising_masters_doctoral.jsp";
	document.advising.submit();
}
function ViewResidency()
{
	if(document.advising.stud_id.value.length ==0)
	{
		alert("Please enter student ID.");
		return;
	}
	var pgLoc = "../../registrar/residency/residency_status.jsp?stud_id="+escape(document.advising.stud_id.value);
	pgLoc += "&online_advising="+document.advising.online_advising.value;
	
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
function focusID() {
	document.advising.stud_id.focus();
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

<body onLoad="focusID();alertSize(); ">
<form name="advising" action="" method="post"><!-- onSubmit="return Validate();">-->
<input type="hidden" name="degree_type" value="1">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" bgcolor="#A49A6A" align="center"><strong> <font color="#FFFFFF">
        :::: MASTERAL/DOCTORAL STUDENT ADVISING PAGE :::: </font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="8" style="font-size:14px; font-weight:bold; color:#FF0000">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="23%" height="25">Enter Student ID (Temporary/Permanent)</td>
      <td height="25" colspan="2"><input name="stud_id" type="text" size="16" value="<%=strStudID%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		<%if(bolIsForwarded){%> readonly="yes" style="border:0px; font-size:18px;"<%}else{%> <%}%>>
		
		<%if(vEnrolledList != null){%>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <font size="3" color="#0000FF"><b>Student is advised already.</b></font> 
        <%}%>
		
		
		
		
      </td>
      <td width="10%">&nbsp; </td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">School Year/Term</td>
      <td width="31%" height="25">
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
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
        <select name="semester">
		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
      </select> </td>
      <td width="34%" height="25"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0">
        </a> </td>
      <td>&nbsp; </td>
    </tr>
<%if((strSchCode.startsWith("FATIMA") || strInfo5.startsWith("jonelta")) && vStudInfo != null && vStudInfo.size() > 0){
//get here if already set plan.
	String strStudFatimaPlanRef = null;
	enrollment.FAStudMinReqDP faMinDP = new enrollment.FAStudMinReqDP(dbOP);
	Vector vStudInstallmentPlanFatima = faMinDP.getPlanInfoOfAStudent(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), (String)vStudInfo.elementAt(0), bolIsTempStud);
	if(vStudInstallmentPlanFatima != null && vStudInstallmentPlanFatima.size() > 0)
		strStudFatimaPlanRef = (String)vStudInstallmentPlanFatima.elementAt(0);
%>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="5" style="font-size:9px; font-weight:bold; color:#0000FF">Installation Plan: 
		<select name="plan_ref" style="font-size:10px" onChange="updatePlanFatima()">
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
	<tr>
      <td colspan="5"><hr size="1"></td>
    </tr>

  </table>
<% if(strErrMsg == null){//show everything below this.
if(dOutstanding > 0.1d){
	if(strSchCode.startsWith("EAC"))
		dOutstanding = 0d;
		
	if(dOutstanding > 0.1d){
%>
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
<%}}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%" height="25">Student name :<strong>

        <%=(String)vStudInfo.elementAt(1)%>
        <input name="stud_name" value="<%=(String)vStudInfo.elementAt(1)%>" type="hidden">
        </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course :<strong><%=(String)vStudInfo.elementAt(7)%>
	  <%
	  if(vStudInfo.elementAt(8) != null){%>
	   /<%=WI.getStrValue(vStudInfo.elementAt(8))%>
	  <%}%>
	   </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Curriculum SY :<strong><%=(String)vStudInfo.elementAt(4)%>
        - <%=(String)vStudInfo.elementAt(5)%></strong></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6"><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td  width="26%" colspan="2" height="25"><a href="javascript:ViewCurriculum();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click
        to view student's course curriculum</font></td>
      <td width="39%" height="25"><a href="javascript:ViewResidency();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click 
        to view student's residency status</font></td>
      <td colspan="2" width="30%" height="25">&nbsp; </td>
    </tr>
	<tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="5"></td>
    </tr>
  </table>
<%
//I have to check here the downpayment rules. -- check READ_PROPERTY_FILE table.
boolean bolAllowAfterCheckDPRule = 
 advising.shouldWeAdviseCheckOnDownPmt(dbOP, (String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(0),
 WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
 if(!bolAllowAfterCheckDPRule) 
	vAdviseList = null;
  
if(vAdviseList != null && vAdviseList.size() > 0){%>

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
      <td height="25" colspan="9"><div align="center">LIST OF SUBJECTS OFFERED
          FOR THIS SEMESTER</div></td>
    </tr>
<%
//if advised already, i have to use it.
if(vEnrolledList != null && vEnrolledList.size() > 0 && WI.fillTextValue("block_sec").length() == 0) 
	strTemp = (String)vEnrolledList.remove(0);
else	
	strTemp = "0";
%>	  
    <tr>
      <td width="2%"  height="25">&nbsp;</td>
      <td colspan="6" height="25">Total student load:
        <input type="text" name="sub_load" value="<%=strTemp%>" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;"></td>
      <td width="32%" height="25">&nbsp;</td>
      <td width="30%" align="right"><input name="image" type="image" src="../../../images/form_proceed.gif">&nbsp;&nbsp;</td>
    </tr>
  </table>
<div class="messageBox" id="div_msgBox">
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFDD">
    <tr bgcolor="#CCCCCC">
      <td width="15%" height="25" align="center"><strong><font size="1">COURSE
        REQUIREMENT</font></strong></td>
      <td width="10%" align="center"><strong><font size="1">SUBJECT CODE</font></strong></td>
      <td width="25%" align="center"><strong><font size="1">SUBJECT TITLE </font></strong></td>
      <td width="4%" align="center"><strong><font size="1"> UNITS</font></strong></td>
<% if (!strSchCode.startsWith("CPU")) {%> 
      <td width="4%" align="center"><strong><font size="1">UNITS TO TAKE</font></strong></td>
<%}%> 
      <td width="15%" align="center"><strong><font size="1">
	 <% if (!strSchCode.startsWith("CPU")){%>
	  SECTION  <%}else{%>  STUB CODE  <%}%>
	  </font></strong></td>
      <td width="20%" align="center"><strong><font size="1">SCHEDULE</font></strong></td>
      <td width="5%" align="center"><strong><font size="1">SELECT 
	 <% if (!strSchCode.startsWith("CPU")){%> ALL <%}%></font></strong>
        <br> <input type="checkbox" name="selAll" value="0" onClick="checkAll();"></td>
      <td width="5%" align="center"><strong><font size="1">ASSIGN SECTION</font></strong></td>
    </tr>
    <% int iTemp = 0;
//vAutoAdvisedList[1] is having the advised list = [0]=sub section index,[1]=section,[2]=sub_code
String strTemp2 = null;//System.out.println(vAutoAdvisedList[1].toString());
String strCourseReq = ""; int iIndexOf  = 0;
String strTimeSch = null; String strUnitEnrolled = null;
boolean bolAuthCheckBox   = false;

for(int i = 0,j=0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed)
{
 	strTimeSch = null;

	strTemp = ""; strTemp2 = "";
	strUnitEnrolled = "";bolAuthCheckBox   = false;

if(vEnrolledList != null && vEnrolledList.size() > 0) {
		iIndexOf = vEnrolledList.indexOf((String)vAdviseList.elementAt(i+4));//sub name.
		if(iIndexOf != -1 && !((String)vEnrolledList.elementAt(iIndexOf - 1)).startsWith((String)vAdviseList.elementAt(i+3))) 
			iIndexOf = vEnrolledList.indexOf((String)vAdviseList.elementAt(i+4),iIndexOf+1);
		if(iIndexOf != -1 && !((String)vEnrolledList.elementAt(iIndexOf - 1)).startsWith((String)vAdviseList.elementAt(i+3))) 
			iIndexOf = vEnrolledList.indexOf((String)vAdviseList.elementAt(i+4),iIndexOf+1);
			
		if(iIndexOf != -1) {//subject matching.
			strTimeSch = (String)vEnrolledList.elementAt(iIndexOf + 2);

			strTemp2 = (String)vEnrolledList.elementAt(iIndexOf + 3);
			strTemp  = (String)vEnrolledList.elementAt(iIndexOf + 1);
			strUnitEnrolled    = (String)vEnrolledList.elementAt(iIndexOf + 9);
			
			bolAuthCheckBox = true;
			
			iIndexOf = iIndexOf - 4;
			vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);
			vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);
			vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);
			vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);
			vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);vEnrolledList.removeElementAt(iIndexOf);
		}
	}


%>
    <tr onDblClick='LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i+2)%>","<%=(String)vAdviseList.elementAt(i+5)%>","<%=j%>");'
	 class="nav" id="msg<%=j%>" onMouseOver="navRollOver('msg<%=j%>', 'on')" onMouseOut="navRollOver('msg<%=j%>', 'off')">
      <td height="20" style="font-size:11px;"> 
	  <!-- all the hidden fileds are here. -->
        <input type="hidden" name="sub_code<%=j%>" value="<%=(String)vAdviseList.elementAt(i+3)%>">
        <input type="hidden" name="sub_name<%=j%>" value="<%=(String)vAdviseList.elementAt(i+4)%>">
        <input type="hidden" name="lab_unit<%=j%>" value="&nbsp;">
        <input type="hidden" name="lec_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>">
        <input type="hidden" name="total_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>">
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vAdviseList.elementAt(i+2)%>">
<!--
		<input type="hidden" name="ut<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>">
-->
        <%
	  if(strCourseReq.compareTo((String)vAdviseList.elementAt(i)) != 0)
	  {
	  	strCourseReq = (String)vAdviseList.elementAt(i);
		fMaxAllowedLoad += Float.parseFloat((String)vAdviseList.elementAt(i+1));
		%>
        <%=(String)vAdviseList.elementAt(i)+"("+(String)vAdviseList.elementAt(i+1)+" units)"%>
        <%}%></td>
      <td style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+3)%></td>
      <td style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+4)%></td>
      <td align="center" style="font-size:11px;"><%=(String)vAdviseList.elementAt(i+6)%></td>
<%
if(strUnitEnrolled.length() == 0)
	strUnitEnrolled = (String)vAdviseList.elementAt(i+6);

if (!strSchCode.startsWith("CPU")) {%> 
      <td align="center"><%//=(String)vAdviseList.elementAt(i+6)%>
	  <input type="text" value="<%=strUnitEnrolled%>" name="ut<%=j%>" size="3" maxlength="3" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" <%=strReadOnlyUnitToTake%>>	  </td>
<%}%> 
      <td> 
	  

<% if (strSchCode.startsWith("CPU")){
		strInputType = "hidden";
		strInputTypeDetails = "";
	}else{
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;\"";
	}
%>	  
	  <input type="<%=strInputType%>" value="<%=strTemp2%>" name="sec<%=j%>" <%=strInputTypeDetails%>   <%if(bolIsCalledFrOnlineRegdStud){%>readonly='yes'<%}%>> 
<!--	  
	  <input type="text" value="<%=strTemp2%>" name="sec<%=j%>" size="12" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;">
-->

<% 
	if (strSchCode.startsWith("CPU")){
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;\"";
	}else{
		strInputType = "hidden";
		strInputTypeDetails = "";
	}
%>
	    
	  <input type="<%=strInputType%>" value="<%=strTemp%>" name="sec_index<%=j%>"  <%=strInputTypeDetails%>> 
<!--        <input type="hidden" value="<%=strTemp%>" name="sec_index<%=j%>">  -->	  </td>
      <td style="font-size:11px;"><label id="_<%=j%>" style="font-size:11px;"><%=WI.getStrValue(strTimeSch)%></label></td>
      <td align="center" style="font-size:11px;"> 
<%
if(bolAuthCheckBox)
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="checkbox<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>" onClick='AddLoad("<%=j%>","<%=(String)vAdviseList.elementAt(i+6)%>")'<%=strTemp%>>      
	  </td>
      <td align="center" style="font-size:11px;"> <a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i+2)%>","<%=(String)vAdviseList.elementAt(i+5)%>","<%=j%>");'><img src="../../../images/schedule.gif" width="40" height="20" border="0"></a></td>
    </tr>
    <% i = i+6;}%>
  </table>
</div>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8" align="center">
	  <a href="javascript:Validate();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  </td>
    </tr>
    <tr>
      <td height="25" colspan="8">&nbsp; </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
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
<input type="hidden" name="syf" value="<%=(String)vStudInfo.elementAt(4)%>"> <!-- curriculum year from /to. -->
<input type="hidden" name="syt" value="<%=(String)vStudInfo.elementAt(5)%>">
<input type="hidden" name="maxDisplay" value="<%=iMaxDisplayed%>"><!-- max number of entries displayed.-->
<input type="hidden" name="stud_type" value="<%=(String)vStudInfo.elementAt(11)%>">

<%
strTemp = WI.fillTextValue("stud_type");
if(strTemp.startsWith("New") || true){%>
	<input type="hidden" name="temp_id" value="<%=strStudID%>">
<%}%>


<%} // end of display - if student id is valid
%>
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="showList" value="<%=WI.fillTextValue("showList")%>">
<input type="hidden" name="autoAdvise" value="<%=WI.fillTextValue("autoAdvise")%>">
<input type="hidden" name="viewAllAllowedLoad" value="<%=WI.fillTextValue("viewAllAllowedLoad")%>">
<input type="hidden" name="maxAllowedLoad" value="<%=fMaxAllowedLoad%>">
<input type="hidden" name="block_sec"><!-- contains value for block section.-->
<%
strTemp = WI.fillTextValue("accumulatedLoad");
if(strTemp.length() ==0)
	strTemp = "0";
%>
<input type="hidden" name="accumulatedLoad" value="<%=strTemp%>">
<input type="hidden" name="sem" value="<%=WI.fillTextValue("semester")%>">


<input type="hidden" name="win_width" value="<%=WI.fillTextValue("win_width")%>">
<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>">


<input type="hidden" name="online_advising" value="<%=WI.fillTextValue("online_advising")%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
