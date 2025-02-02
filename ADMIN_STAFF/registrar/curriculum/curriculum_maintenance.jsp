<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

//call this if course type is changed from regular course to summer course or internship course
function ChangeCourseType()
{
	//if(document.cmaintenance.semester.selectedIndex > 4)
		ReloadPage();
}
function ChangeCourseIndex() {
	document.cmaintenance.change_course_index.value = 1;
	this.ReloadPage();
}
function copyCurYr(strCYFrom, strCYTo) {
	document.cmaintenance.sy_from.value = strCYFrom;
	document.cmaintenance.sy_to.value   = strCYTo;
	this.ReloadPage();	
}

//call this to view course curriculum in detail.
function ViewAll()
{
	var strCName = document.cmaintenance.course_index[document.cmaintenance.course_index.selectedIndex].text;
	var strCIndex = document.cmaintenance.course_index[document.cmaintenance.course_index.selectedIndex].value;

	var strMName = document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].text;
	var strMIndex = document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].value;

	var strSYFrom = document.cmaintenance.sy_from.value;
	var strSYTo = document.cmaintenance.sy_to.value;

	if(document.cmaintenance.course_index.selectedIndex <= 0)
	{
		alert("Please select a course.");
		return;
	}
	if(strSYFrom.length <2)
	{
		alert("Please enter <Curriculum year> to view detail course curriculum.");
		return;
	}
	if(strSYTo.length <2)
	{
		alert("Please enter <Curriculum year> to view detail course curriculum.");
		return;
	}
	
	var strPgLoc = "./curriculum_maintenance_viewall.jsp";
	if(document.cmaintenance.prep_prop_stat) 
		strPgLoc = "./curriculum_maintenance_proper_viewall.jsp";

	if(document.cmaintenance.major_index.selectedIndex == 0) //major index is null
	{
		location = strPgLoc+"?ci="+strCIndex+"&cname="+escape(strCName)+
			"&syf="+strSYFrom+"&syt="+strSYTo;
	}
	else
	{
		location = strPgLoc+"?ci="+strCIndex+"&cname="+escape(strCName)+
			"&syf="+strSYFrom+"&syt="+strSYTo+"&mi="+strMIndex+"&mname="+escape(strMName);
	}
}
function ReloadPage()
{
	document.cmaintenance.page_action.value = "";
	document.cmaintenance.reloadPage.value = 1;
	this.SubmitOnce('cmaintenance');
}
function UpdatePreRequisite(sCatg,sCatgIndex)
{
	//enter subject code, subject name, subject category to update pre-requisite.
	var sCode = document.cmaintenance.sub_index[document.cmaintenance.sub_index.selectedIndex].text;

	if(sCode == "selany")
	{
		alert("Subject code/ subject name can't be blank. Please select a subject code");
		return;
	}
	location="./curriculum_subject_pre.jsp?sub_index="+document.cmaintenance.sub_index[document.cmaintenance.sub_index.selectedIndex].value+
				"&viewall=1&catg_name="+escape(sCatg)+"&catg_index="+escape(sCatgIndex)+"&hist=javascript:history.back();";

//	location="./curriculum_subject_pre.jsp?sub_index="+document.cmaintenance.sub_index[document.cmaintenance.sub_index.selectedIndex].value+
//				"&viewall=1&sub_code="+escape(sCode)+"&sub_name="+escape(sName)+
//				"&catg_name="+escape(sCatg)+"&catg_index="+escape(sCatgIndex)+"&hist=javascript:history.back();";
}

function PageAction(strAction, strInfoIndex) {
	document.cmaintenance.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.cmaintenance.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.cmaintenance.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('cmaintenance');
}
function PrepareToEdit(strInfoIndex) {
	document.cmaintenance.page_action.value = "";
	document.cmaintenance.prepareToEdit.value = "1";
	document.cmaintenance.info_index.value = strInfoIndex;
	this.SubmitOnce('cmaintenance');
}
function Cancel() {
	document.cmaintenance.page_action.value = "";
	document.cmaintenance.prepareToEdit.value = "";
	document.cmaintenance.info_index.value = "";
	document.cmaintenance.hour_lec.value = "";
	document.cmaintenance.hour_lab.value = "";
	document.cmaintenance.lec_unit.value = "";
	document.cmaintenance.lab_unit.value = "";
	this.SubmitOnce('cmaintenance');
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vRetResult = new Vector();//this is added to store the subject descirption, category name and category index for Pre-requisite
	
	Vector vCurInfo = null;	
	boolean bolIsLocked = false;//check LOCK_CURRICULUM table.
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses curriculum","curriculum_maintenance.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_maintenance.jsp");
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


boolean bolProceed = true;
strErrMsg = null; //if there is any message set -- show at the bottom of the page.
	CurriculumMaintenance CM = new CurriculumMaintenance();
	Vector vEditInfo  = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(CM.operateOnCurriculumUG(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = CM.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Curriculum information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Curriculum information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Curriculum information successfully removed.";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = CM.operateOnCurriculumUG(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = CM.getErrMsg();
}

	vCurInfo  = CM.operateOnCurriculumUG(dbOP, request,4);
	if(vCurInfo == null && strErrMsg == null)
		strErrMsg = CM.getErrMsg();
if(vCurInfo != null && vCurInfo.size() > 0) 
	bolIsLocked = new enrollment.SetParameter().isCurLocked(dbOP, WI.fillTextValue("course_index"),
		WI.fillTextValue("major_index"), WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"));
		

if(!bolProceed)
{
	dbOP.cleanUP();
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=CM.getErrMsg()%></font></p>
	<%
	return;
}
if(strErrMsg == null) strErrMsg = "";

///get the non-credit units.. 
Vector vNonCreditSubj = null;
if(vCurInfo != null && vCurInfo.size() > 0) {
	vNonCreditSubj = new enrollment.CurriculumSM().operateOnNonCreditSubject(dbOP, request, 4);
}
if(vNonCreditSubj == null)
	vNonCreditSubj = new Vector();
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";

//--- not in use.	
boolean bolShowOrderNo = false;
if(strSchCode.startsWith("SWU"))
	bolShowOrderNo = true;
%>

<form name="cmaintenance" method="post" action="./curriculum_maintenance.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          COURSES CURRICULUM MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td height="25" colspan="2"><b><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg,"Message: ","","")%></font></b> </td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="68%">Course </td>
      <td width="30%">Curriculum year </td>
    </tr></tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><select name="course_index" onChange="ChangeCourseIndex();">
        <option value="selany">Select Any</option>
        <%
//for all course listing strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc"
%>
        <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and degree_type="+
 						request.getParameter("degree_type")+"and cc_index="+request.getParameter("cc_index")+" order by course_name asc", request.getParameter("course_index"), false)%>
      </select></td>
      <td><input name="sy_from" type="text" size="5" maxlength="5" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('cmaintenance','sy_from');style.backgroundColor='white'"
	  onKeyUP="AllowOnlyInteger('cmaintenance','sy_from')">
        to 
        <input name="sy_to" type="text" size="5" maxlength="5" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('cmaintenance','sy_to');style.backgroundColor='white'"
	  onKeyUP="AllowOnlyInteger('cmaintenance','sy_to')"> <a href="javascript:ReloadPage();"></a>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">Major&nbsp;&nbsp; <select name="major_index">
          <option></option>
          <%
strTemp = request.getParameter("course_index");
if(strTemp != null && strTemp.compareTo("selany") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select> </td>
      <td>
<%
Vector vCurYearInfo = null;
strTemp = null;
if(WI.fillTextValue("course_index").length() == 0 || WI.fillTextValue("course_index").compareTo("selany") == 0) 
	strTemp = null;
else	
	strTemp = WI.fillTextValue("major_index");

vCurYearInfo = new enrollment.SubjectSection().getSchYear(dbOP, request.getParameter("course_index"),strTemp);
if(vCurYearInfo != null) {
%>	  
	  <strong><font color="#0000FF" size="1">Existing Cur Year:</font> </strong><br>
	  	
		<%
		for(int i = 0; i < vCurYearInfo.size(); i += 2) {%>
			<a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);">
			<font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a>
		<%i = i + 2;
		if(i < vCurYearInfo.size()){%>
			<a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);">
			<font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a>
		<%}//show two in one line.%>
		<br>
		<%}%>
		
<%}//only if cur info is not null;
%>		</td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><strong>To filter SUBJECT display enter subject code starts 
        with 
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="8" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:15px">
        and click REFRESH</strong></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="24%">&nbsp;</td>
      <td width="6%"><a href="javascript:ViewAll();" target="_self"> </a><a href="javascript:ViewAll();" target="_self"><img src="../../../images/view.gif" width="40" height="29" border="0"></a></td>
      <td width="68%" valign="bottom"><font size="1">click to view complete curriculum 
        OR click to reload page. <a href="javascript:ReloadPage();" target="_self"><img src="../../../images/refresh.gif" border="0"></a></font></td>
    </tr>
    <tr valign="middle"> 
      <td height="25" colspan="4"><hr size="1"> </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Year</td>
      <td> <select name="year">
          <option value="1">1st</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("year");
if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}if(strTemp.compareTo("7") ==0)
{%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}if(strTemp.compareTo("8") ==0)
{%>
          <option value="8" selected>8th</option>
          <%}else{%>
          <option value="8">8th</option>
          <%}%>
        </select>      </td>
      <td colspan="2">
<%if(WI.fillTextValue("degree_type").equals("3")){%>
	  Prep/Prop Status:  
	   <select name="prep_prop_stat">
          <option value="1">Preparatory</option>
			<%
			strTemp = WI.fillTextValue("prep_prop_stat");
			if(strTemp.compareTo("2") ==0){%>
				<option value="2" selected>Proper</option>
			<%}else{%>
				<option value="2">Proper</option>
			<%}%>
        </select>
<%}%>		
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Term </td>
      <td height="25"><select name="semester" onChange="ChangeCourseType();">
          <option value="1">1st Sem</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(14);
else	
	strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("6") ==0){%>
<!--          <option value="6" selected>Internship/Clerkship</option>-->
          <%}else{%>
<!--          <option value="6">Internship/Clerkship</option> -->
          <%}%>
        </select></td>
      <td height="25">&nbsp; </td>
      <td height="25">&nbsp; </td>
    </tr>
    <tr>
      <td height="25" width="2%"><div align="center"> </div></td>
      <td width="6%">&nbsp;</td>
      <td width="23%">&nbsp;</td>
      <td width="9%">&nbsp; </td>
      <td width="60%">&nbsp;</td>
    </tr>
  </table>
<%
//do not show this if cur year is not entered. 
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0) {//curriculum year information is lacking.%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="8"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="25" rowspan="2">&nbsp;</td>
      <td width="24%" rowspan="2"><font size="1"><strong>SUBJECT CODE</strong> 
        <input type="text" name="scroll_sub" size="12" style="font-size:12px" 
	  onKeyUp = "AutoScrollListSubject('scroll_sub','sub_index',true,'cmaintenance');">
        (scroll)</font></td>
      <td width="44%" rowspan="2"><strong><font size="1">
	  Subject Order Number: 
	  <select name="order_no" style="width:50px; font-size:10px;">
	  <option value=""></option>
<%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(16);
else	
	strTemp = WI.fillTextValue("order_no");

int iDefault = Integer.parseInt(WI.getStrValue(strTemp, "0"));
	for(int i = 1; i < 15; ++i) {
		if(i == iDefault)
			strTemp = " selected";
		else	
			strTemp = "";
		%>
		<option value="<%=i%>" <%=strTemp%>><%=i%></option>	  
	<%}%>
	  </select>
	  <font style="font-size:9px; font-weight:normal">
	  (optional to set)
	  </font>
	  </font></strong></td>
      <td colspan="2"><div align="center"><font size="1"><strong>HOURS</strong></font></div></td>
      <td colspan="2"><div align="center"><font size="1"><strong>UNITS</strong></font></div></td>
      <td width="10%" rowspan="2"><div align="center"><font size="1"><strong>VIEW</strong></font></div></td>
    </tr>
    <tr> 
      <td width="5%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>LEC.</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>LAB.</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("sub_index");
%>
	  <select name="sub_index" onChange="ReloadPage();" style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size: 12px;width: 600px;">
          <option value="selany">Select Any</option>
<%=dbOP.loadCombo("sub_index","sub_code, sub_name"," from subject where IS_DEL=0 "+
WI.getStrValue(WI.fillTextValue("starts_with")," and sub_code like '","%'","")+ " order by sub_code asc", strTemp, false)%> 
        </select></td>
<%
if(strTemp == null || strTemp.compareTo("selany") ==0)
	strTemp = "";
else
	vRetResult = CM.getSubjectInfo(dbOP,strTemp);
if(vRetResult == null)
	strErrMsg = CM.getErrMsg();

if(vRetResult != null && vRetResult.size() > 0)
{%>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else {
	strTemp = WI.fillTextValue("hour_lec");
	if(vRetResult.size() > 3 && ((String)vRetResult.elementAt(5)).length() > 0) 
		strTemp = (String)vRetResult.elementAt(5);//get if already created
}
%>
        <input name="hour_lec" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else {	
	strTemp = WI.fillTextValue("hour_lab");
	if(vRetResult.size() > 3 && ((String)vRetResult.elementAt(6)).length() > 0) 
		strTemp = (String)vRetResult.elementAt(6);//get if already created
}	
%>	  <input name="hour_lab" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else {	
	strTemp = WI.fillTextValue("lec_unit"); 
	if(vRetResult.size() > 3 && ((String)vRetResult.elementAt(3)).length() > 0) 
		strTemp = (String)vRetResult.elementAt(3);//get if already created
}
%>	  <input name="lec_unit" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else {
	strTemp = WI.fillTextValue("lab_unit");
	if(vRetResult.size() > 3 && ((String)vRetResult.elementAt(4)).length() > 0) 
		strTemp = (String)vRetResult.elementAt(4);//get if already created
}
%>	  <input name="lab_unit" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td><div align="right"><a href='javascript:UpdatePreRequisite("<%=(String)vRetResult.elementAt(1)%>","<%=(String)vRetResult.elementAt(2)%>");'> 
          <img src="../../../images/prerequisite.gif" border="0"></a>&nbsp;</div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="6"> <div align="left"><strong><font size="1">SUBJECT GROUP&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></strong> 
          <select name="group_name">
            <%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(10);
else {	
	if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
		strTemp = (String)vEditInfo.elementAt(1);
	else	
		strTemp = WI.fillTextValue("sub_index");

	if(strTemp.length() > 0 && strTemp.compareTo("0") != 0 && strTemp.compareTo("selany") != 0)
		strTemp = dbOP.mapOneToOther("SUBJECT","sub_index",strTemp,"GROUP_INDEX",null);
	else	
		strTemp = "";
}
%>
            <%=dbOP.loadCombo("group_index","group_name"," from subject_group where IS_DEL=0 order by group_name asc", strTemp, false)%> 
          </select>
        </div></td>
      <td>&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="14%" height="58" >&nbsp;</td>
      <td width="86%"  height="58" ><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
    <%}%>
  </table>
<%}//if(WI.fillTextValue("sy_from").length() == 0 || WI.fillTextValue("sy_to").length() == 0)
if(vCurInfo != null && vCurInfo.size() > 0) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#FFFFCC">
      <td height="25" colspan="6" class="thinborderLEFT"><div align="center"><strong>CURRICULUM CREATED 
          FOR CY (<%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>, SEMESTER :<%=WI.fillTextValue("semester")%>) </strong></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="5%" class="thinborder">ORDER # </td> 
      <td width="15%" height="25" class="thinborder">SUB CODE</td>
      <td width="41%" class="thinborder">SUB NAME</td>
      <td width="11%" class="thinborder">SUB GROUP</td>
      <td width="8%" class="thinborder">LEC/LAB HOUR</td>
      <td width="8%" class="thinborder"><strong>LEC/LAB UNIT</strong></td>
 <%if(!bolIsLocked){%><td width="17%" class="thinborder"><strong>EDIT/ DELETE</strong></td><%}else{%>
      <td width="17%" class="thinborder">&nbsp;</td>
      <%}%>
    </tr>
<%
boolean bolIsElectiveAutoAdded = false;
Integer objInt = null; int iIndexOf = 0;

String strCreditUnitLec = null;
String strCreditUnitLab = null;

for(int i = 0; i < vCurInfo.size(); i += 17){
	objInt = new Integer((String)vCurInfo.elementAt(i + 1));
	iIndexOf = vNonCreditSubj.indexOf(objInt);
	
	if(iIndexOf > -1) {
		strCreditUnitLec = (String)vNonCreditSubj.elementAt(iIndexOf + 3);
		strCreditUnitLab = (String)vNonCreditSubj.elementAt(iIndexOf + 4);
		if(strCreditUnitLec != null && !strCreditUnitLec.equals("0"))
			strCreditUnitLec = "("+strCreditUnitLec+".0)";
		else	
			strCreditUnitLec = "0.0";
			
		if(strCreditUnitLab != null && !strCreditUnitLab.equals("0"))
			strCreditUnitLab = "("+strCreditUnitLab+".0)";		
		else	
			strCreditUnitLab = "0.0";
	}
	else {
		strCreditUnitLec = null;
		strCreditUnitLab = null;
	}
	
	if(vCurInfo.elementAt(i + 15) != null && ((String)vCurInfo.elementAt(i + 15)).compareTo("1") == 0)
		bolIsElectiveAutoAdded = true;
	else	
		bolIsElectiveAutoAdded = false;	
		
		strTemp = (String)vCurInfo.elementAt(i + 16);
		if(strTemp.equals("0"))
			strTemp = "&nbsp;";
		%>
    <tr>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vCurInfo.elementAt(i + 11)%></td>
      <td class="thinborder">&nbsp;<%=(String)vCurInfo.elementAt(i + 12)%></td>
      <td class="thinborder">&nbsp;<%=(String)vCurInfo.elementAt(i + 13)%></td>
      <td class="thinborder"><%=(String)vCurInfo.elementAt(i + 4)%>/<%=(String)vCurInfo.elementAt(i + 5)%></td>
      <td class="thinborder"><%if(strCreditUnitLec != null) {%>
	  	<%=strCreditUnitLec%>/<%=strCreditUnitLab%>
	  <%}else{%>
	  	<%=(String)vCurInfo.elementAt(i + 2)%>/<%=(String)vCurInfo.elementAt(i + 3)%>
	  <%}%>	  </td>
      <%if(!bolIsLocked){%><td class="thinborder"><font size="1">&nbsp; 
        <%
if(iAccessLevel > 1 && !bolIsElectiveAutoAdded){%>
        <a href='javascript:PrepareToEdit("<%=(String)vCurInfo.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}if(iAccessLevel == 2 && !bolIsElectiveAutoAdded){%>
        <a href='javascript:PageAction("0","<%=(String)vCurInfo.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}if(bolIsElectiveAutoAdded){%>
		Elective (can't be modified)<%}%>
        </font></td><%}else{%>
       
      <td width="17%" class="thinborder" align="center"><font color="#0000FF">Locked</font></td>
      <%}%>
   </tr>
<%}//end of for loop.%>
  </table>

<%}%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr> 
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="changeSubject" value="0">
<input type="hidden" name="hist" value="./curriculum_maintenance.jsp">
<input type="hidden" name="cc_index" value="<%=WI.fillTextValue("cc_index")%>">
<input type="hidden" name="degree_type" value="<%=WI.fillTextValue("degree_type")%>">

<input type="hidden" name="change_course_index"><!-- only when course index is changed. -->

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>
