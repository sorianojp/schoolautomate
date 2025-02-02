<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;String strTemp3 = null;
	String strStudID = request.getParameter("stud_id");
	int iMaxDisplayed = 0;
	String strDegreeType = "2";
	boolean bolFatalErr = false;
	String strInputType = null;
	String strInputTypeDetails = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	String strInfo5   = WI.getStrValue((String)request.getSession(false).getAttribute("info5"));

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-advising_medicine","advising_medicine.jsp");
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
														"advising_medicine.jsp");
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

Advising advising = new Advising();

if(request.getParameter("sy_from") == null || request.getParameter("sy_from").trim().length() ==0 ||
	request.getParameter("sy_to") == null || request.getParameter("sy_to").trim().length() ==0 || WI.fillTextValue("stud_id").length() ==0)
{
	strErrMsg = "Please enter ID/School Year.";
}

if(strErrMsg == null)
{
	vStudInfo = advising.getStudInfo(dbOP,strStudID, WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
										WI.fillTextValue("semester"));
	if(vStudInfo == null)
	{
		strErrMsg = advising.getErrMsg();
		bolFatalErr = true;
	}
	else /// do all processing here.
	{
		//check if it is auto advise or show list.
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),
			WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(6),WI.fillTextValue("semester"),(String)vStudInfo.elementAt(4),
			(String)vStudInfo.elementAt(5));
		if(vMaxLoadDetail == null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
		else
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
	}
	if(!bolFatalErr && WI.fillTextValue("showList").compareTo("1") ==0) // show list.
	{
		bolShowAdviseList = true;
		vAdviseList = advising.getAdvisingListForOLDCOM(dbOP,WI.fillTextValue("stud_id"),(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),
								false,request.getParameter("sy_from"),request.getParameter("sy_to"),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5),
								(String)vStudInfo.elementAt(6),request.getParameter("semester"));
	}
	else if(!bolFatalErr && WI.fillTextValue("ViewAllAllowedList").compareTo("1") ==0)
	{
		bolShowAdviseList = true;
		//advising.getAllAllowedList(dbOP,request.getAttribute("ci"),String strStudId);
	}
	
}//if school year is entered.



String strReadOnlyUnitToTake = "";
if(strSchCode.startsWith("UB"))
	strReadOnlyUnitToTake = " readonly='yes'";
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
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
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
		alert("Please sechedule to select student load.");
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
function ViewAllAllowedList()
{
	document.advising.viewAllAllowedList.value = 1;
	ReloadPage();//document.advising.submit();
}

function ViewCurriculum()
{
	var pgLoc = "";
	if(document.advising.mn.value.length > 0)
		pgLoc = "../../admission/curriculum_page1.jsp?ci="+document.advising.ci.value+"&cname="+
			escape(document.advising.cn.value)+"&mi="+document.advising.mi.value+"&mname="+escape(document.advising.mn.value)+"&syf="+
			document.advising.syf.value+"&syt="+document.advising.syt.value+"&goNextPage=1&degree_type=2";
	else
		pgLoc = "../../admission/curriculum_page1.jsp?ci="+document.advising.ci.value+"&cname="+escape(document.advising.cn.value)+
			"&syf="+document.advising.syf.value+"&syt="+document.advising.syt.value+"&goNextPage=1&degree_type=2";

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
function LoadPopup(secName,sectionIndex,strCurIndex, strSubIndex, strIndex)//I have to use combination of subject,course and major.
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
		"&major_index="+document.advising.mi.value+"&degree_type=2&line_number="+strIndex;
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
function BlockSection()
{
	var strMajorIndCon = document.advising.mi.value;
	if(strMajorIndCon.length == 0)
		strMajorIndCon = "";
	else
		strMajorIndCon="&mi="+strMajorIndCon;
	var loadPg = "./block_section.jsp?form_name=advising&max_disp="+document.advising.maxDisplay.value+"&ci="+
		document.advising.ci.value+strMajorIndCon+"&syf="+document.advising.syf.value+
	 	"&syt="+document.advising.syt.value+"&sy_from="+document.advising.sy_from.value+"&sy_to="+document.advising.sy_to.value+
	 	"&offering_sem="+document.advising.sem.value+
	 	"&year_level="+document.advising.year_level.value+"&semester="+
		document.advising.sem.value+"&cn="+escape(document.advising.cn.value)+"&mn="+escape(document.advising.mn.value);
	alert(loadPg);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.advising.action="./advising_transferee_medicine.jsp";
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
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
</script>

<body bgcolor="#D2AE72">
<form name="advising" action="" method="post" onSubmit="return Validate();">
<input type="hidden" name="degree_type" value="2">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" bgcolor="#A49A6A" align="center"><strong> <font color="#FFFFFF">
        :::: COLLEGE OF MEDICINE ADVISING PAGE :::: </font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="8">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
	</table>
<%
if(bolFatalErr)
{
	dbOP.cleanUP();
	return;
}
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="29%" height="25">Enter Student ID (Temporary/Permanent)</td>
      <td height="25" colspan="2"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td width="10%">&nbsp; </td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">School Year/Term</td>
      <td width="25%" height="25">
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
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
      <td width="34%" height="25"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0">
        </a> </td>
      <td>&nbsp; </td>
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
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>

  </table>
<% if(strErrMsg == null){//show everything below this.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student Status : <strong><%=((String)vStudInfo.elementAt(11)).toUpperCase()%></strong></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="62%" height="25">Student name (first,middle,last) :<strong>

        <%=(String)vStudInfo.elementAt(1)%>
        <input name="stud_name" value="<%=(String)vStudInfo.elementAt(1)%>" type="hidden">
        </strong></td>
      <td height="25">&nbsp; </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course :<strong><%=(String)vStudInfo.elementAt(7)%>
	  <%
	  if(vStudInfo.elementAt(8) != null){%>
	   /<%=WI.getStrValue(vStudInfo.elementAt(7))%>
	  <%}%>
	   </strong></td>
      <td height="25">Year level: <%=WI.getStrValue(vStudInfo.elementAt(6))%></td>
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
      <td colspan="2" height="25"><hr size="1"></td>
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
      <td colspan="2" height="25"><hr size="1"></td>
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
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td  width="26%" colspan="2" height="25"><a href="javascript:ViewCurriculum();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click
        to view student's course curriculum</font></td>
      <td width="39%" height="25">
	  <a href="javascript:ShowList();"><img src="../../../images/show_list.gif" width="57" height="34" border="0"></a><font size="1">click
        to show list of subjects student may take for the semester</font></td>
      <td colspan="2" width="30%" height="25">&nbsp;</td>
    </tr>
	<tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="5"></td>
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
      <td height="25" colspan="9"><div align="center">LIST OF SUBJECTS THE STUDENT 
          MAY TAKE</div></td>
    </tr>
    <tr> 
      <td width="2%"  height="25">&nbsp;</td>
      <td colspan="6" height="25">Maximum load : <%=strMaxAllowedLoad%></td>
      <td width="52%" height="25">Total student load: 
      <input type="text" name="sub_load" value="0" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;"></td>
      <td width="10%">
        <!--
	  <a href="javascript:BlockSection();"><img src="../../../images/bsection.gif" width="62" height="24" border="0"></a><font size="1">click
        for block sectioning</font>-->      <input name="image" type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="7%" height="25" align="center"><strong><font size="1">YEAR</font></strong></td>
      <td width="7%" height="25" align="center"><strong><font size="1">TERM</font></strong></td>
      <td width="12%" height="25" align="center"><strong><font size="1">SUBJECT
        CODE</font></strong></td>
      <td width="23%" align="center"><strong><font size="1">SUBJECT TITLE </font></strong></td>
      <td width="6%" align="center"><strong><font size="1">TOTAL UNITS</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">UNITS TO TAKE</font></strong></td>
<%
	if (strSchCode.startsWith("CPU"))
		strTemp = "STUB CODE";
	else
		strTemp = "SECTION";
%> 	  
      <td width="12%" align="center"><strong><font size="1"><%=strTemp%></font></strong></td>
      <td width="6%" align="center"><strong><font size="1">SELECT</font></strong>
        <br> <input type="checkbox" name="selAll" value="0" onClick="checkAll();"></td>
      <td width="8%" align="center"><strong><font size="1">ASSIGN SECTION</font></strong></td>
    </tr>
    <% int iTemp = 0;
//vAutoAdvisedList[1] is having the advised list = [0]=sub section index,[1]=section,[2]=sub_code
for(int i = 0,j=0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed)
{
	strTemp = ""; strTemp2 = "";
	if(WI.fillTextValue("block_sec").length()>0)
	{
		strTemp2 = request.getParameter("block_sec");
		strTemp = advising.getSubSecIndex(dbOP,(String)vAdviseList.elementAt(i),strTemp2,request.getParameter("sy_from"),
				  		request.getParameter("sy_to"),request.getParameter("semester"),strDegreeType);
		if(strTemp == null)
		{strTemp2 = "";strTemp="";}
	}


%>
    <tr onDblClick='LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>","<%=j%>");'>
      <td height="25" align="center">
        <!-- all the hidden fileds are here. -->
        <input type="hidden" name="sub_code<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>">
        <input type="hidden" name="sub_name<%=j%>" value="<%=(String)vAdviseList.elementAt(i+7)%>">
        <input type="hidden" name="lab_unit<%=j%>" value="">
        <input type="hidden" name="lec_unit<%=j%>" value="">
        <input type="hidden" name="total_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>">
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vAdviseList.elementAt(i)%>">
        <%=WI.getStrValue(vAdviseList.elementAt(i+1),"&nbsp;")%></td>
      <td align="center"><%=WI.getStrValue(vAdviseList.elementAt(i+2),"&nbsp;")%></td>
      <td><%=(String)vAdviseList.elementAt(i+6)%> </td>
      <td><%=(String)vAdviseList.elementAt(i+7)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+5)%></td>
      <td align="center">
        <%
strTemp3 = WI.fillTextValue("ut"+j);
if(strTemp3.length() ==0)
	strTemp3 = (String)vAdviseList.elementAt(i+5);
%>
        <input name="ut<%=j%>" type="text" size="4" value="<%=strTemp3%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'; javascript:SaveInputUnit(<%=j%>);" onBlur="style.backgroundColor='white'; javascript:VerifyNotNull(<%=j%>);"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" onKeyUp='ChangeLoad("<%=j%>");' <%=strReadOnlyUnitToTake%>></td>
  	  
      <td> 

 <input type="hidden" name="IS_LAB_ONLY<%=j%>" value="<%//=strLecLabStat%>">
	  

<% if (strSchCode.startsWith("CPU")){
		strInputType = "hidden";
		strInputTypeDetails = "";
	}else{
		strInputType = "text";
		strInputTypeDetails = "size=\"12\" style=\"border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;\"";
	}
%>	  
	  <input type="<%=strInputType%>" value="<%=strTemp2%>" name="sec<%=j%>" <%=strInputTypeDetails%> > 
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
<!--        <input type="hidden" value="<%=strTemp%>" name="sec_index<%=j%>">  -->  	  
	  
<!--	  
	  
	  <input type="text" value="<%=strTemp2%>" name="sec<%=j%>" size="12" readonly="yes" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;">
        <input type="hidden" value="<%=strTemp%>" name="sec_index<%=j%>"> 
		
-->	
		
	</td>
      <td align="center"> <input type="checkbox" name="checkbox<%=j%>"
	  value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>"
	  onClick='AddLoad("<%=j%>","<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>")'> 
      </td>
      <td align="center"><a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>","<%=j%>");'><img src="../../../images/schedule.gif" width="55" height="30" border="0"></a></td>
    </tr>
    <% i = i+9;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8"><div align="center"> <input type="image" src="../../../images/form_proceed.gif"></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8">&nbsp; </td>
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



<!-- the hidden fields only if user exist -->
<input type="hidden" name="cn" value="<%=(String)vStudInfo.elementAt(7)%>">
<input type="hidden" name="ci" value="<%=(String)vStudInfo.elementAt(2)%>">
<input type="hidden" name="mn" value="<%=WI.getStrValue(vStudInfo.elementAt(8))%>">
<input type="hidden" name="mi" value="<%=WI.getStrValue(vStudInfo.elementAt(3))%>">
<input type="hidden" name="syf" value="<%=(String)vStudInfo.elementAt(4)%>"> <!-- curriculum year from /to. -->
<input type="hidden" name="syt" value="<%=(String)vStudInfo.elementAt(5)%>">
<input type="hidden" name="maxDisplay" value="<%=iMaxDisplayed%>"><!-- max number of entries displayed.-->
<input type="hidden" name="stud_type" value="<%=(String)vStudInfo.elementAt(11)%>">
<input type="hidden" name="year_level" value="<%=WI.getStrValue(vStudInfo.elementAt(6))%>">


<%} // end of display - if student id is valid
%>
<input type="hidden" name="semester" value="1">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="showList" value="<%=WI.fillTextValue("showList")%>">
<input type="hidden" name="viewAllAllowedLoad" value="<%=WI.fillTextValue("viewAllAllowedLoad")%>">
<input type="hidden" name="maxAllowedLoad" value="<%=strMaxAllowedLoad%>">
<input type="hidden" name="block_sec"><!-- contains value for block section.-->
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

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
