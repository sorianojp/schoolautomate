<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	DBOperation dbOP = null;

	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS-subjects","statistics_subjects.jsp");
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
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function GoOtherFormat() {
	location = "./statistics_subjects_other.jsp";
}
function PrintPg()
{
//	document.stat_subj.target="_blank";
//	document.stat_subj.action ="./statistics_subjects_print.jsp";
//	document.stat_subj.submit();
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	var sT = "./statistics_subjects_print.jsp?sub_stat="+
		document.stat_subj.sub_stat[document.stat_subj.sub_stat.selectedIndex].value+"&date_from="+
		document.stat_subj.date_from.value+"&date_to="+document.stat_subj.date_to.value+
		"&c_index="+document.stat_subj.c_index[document.stat_subj.c_index.selectedIndex].value+
		"&catg_index="+document.stat_subj.catg_index[document.stat_subj.catg_index.selectedIndex].value+
		"&sub_index="+document.stat_subj.sub_index[document.stat_subj.sub_index.selectedIndex].value+
		"&offering_yr_from="+document.stat_subj.offering_yr_from.value+
		"&offering_yr_to="+document.stat_subj.offering_yr_to.value+
		"&offering_sem="+document.stat_subj.offering_sem[document.stat_subj.offering_sem.selectedIndex].value;

	//print here
	var win=window.open(sT,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FormProceed()
{
	document.stat_subj.target="_self";
	document.stat_subj.action ="./statistics_subjects.jsp";
	document.stat_subj.proceed.value = "1";
	
	///set college name, subject group and subject code.
/**
	if(document.stat_subj.c_index.selectedIndex > 0) 
		document.stat_subj.college_name.value = document.stat_subj.c_index[document.stat_subj.c_index.selectedIndex].text;
	else	
		document.stat_subj.college_name.value = "";
	if(document.stat_subj.catg_index.selectedIndex > 0) 
		document.stat_subj.sgroup_name.value = document.stat_subj.catg_index[document.stat_subj.catg_index.selectedIndex].text;
	else	
		document.stat_subj.sgroup.value = "";
	if(document.stat_subj.sub_index.selectedIndex > 0) 
		document.stat_subj.subject_code.value = document.stat_subj.sub_index[document.stat_subj.sub_index.selectedIndex].text;
	else	
		document.stat_subj.subject_code.value = "";
**/	
}
function ReloadPage()
{
	document.stat_subj.target="_self";
	document.stat_subj.action ="./statistics_subjects.jsp";
	document.stat_subj.proceed.value = "";
	///set college name, subject group and subject code.
//	if(document.stat_subj.c_index.selectedIndex > 0) 
//		document.stat_subj.college_name.value = document.stat_subj.c_index[document.stat_subj.c_index.selectedIndex].text;
//	else	
//		document.stat_subj.college_name.value = "";
//	if(document.stat_subj.catg_index.selectedIndex > 0) 
//		document.stat_subj.sgroup_name.value = document.stat_subj.catg_index[document.stat_subj.catg_index.selectedIndex].text;
//	else	
//		document.stat_subj.sgroup.value = "";
	if(document.stat_subj.sub_index.selectedIndex > 0) 
		document.stat_subj.subject_code.value = document.stat_subj.sub_index[document.stat_subj.sub_index.selectedIndex].text;
	else	
		document.stat_subj.subject_code.value = "";
	this.SubmitOnce('stat_subj');
}
function ReloadSubjectCatg() {
	document.stat_subj.sub_index.selectedIndex = 0;
	this.ReloadPage();
}
function PrintThisPage() {
	var strInfo = "<div align=\"center\"><strong><font size=3><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </font></strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div><br>";
	this.insRowVarTableID('myADTable',0, 1, strInfo);
	
	if(document.getElementById("myADTable0"))
		document.getElementById('myADTable0').deleteRow(0);
	
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(1);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(1);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable00').deleteRow(0);
	
	document.bgColor = "#FFFFFF";
	alert("Click OK to print this page");
	window.print();
}
function ToggleIsConfirmed(iStat) {
	if(iStat == 1) {
		if(document.stat_subj.inc_not_validated.checked && document.stat_subj.only_not_validated.checked)
			document.stat_subj.only_not_validated.checked = false;
	}
	if(iStat == 2) {
		if(document.stat_subj.inc_not_validated.checked && document.stat_subj.only_not_validated.checked)
			document.stat_subj.inc_not_validated.checked = false;
	}
}
function checkAll()
{
	var maxDisp = document.stat_subj.max_disp.value;
	var totalLoad = 0;
	//unselect if it is unchecked.
	if(!document.stat_subj.selAll.checked) {
		for(var i =0; i< maxDisp; ++i)
			eval('document.stat_subj.checkbox'+i+'.checked=false');
		return;
	}
	for(var i =0; i< maxDisp; ++i)
		eval('document.stat_subj.checkbox'+i+'.checked = true');
}
function RemoveDissolvedSub() {
	document.stat_subj.target="_self";
	document.stat_subj.action ="./statistics_subjects.jsp";
	document.stat_subj.proceed.value = "1";
	
	var tobeRemoved = 0;
	var maxDisp = document.stat_subj.max_disp.value;
	for(var i =0; i< maxDisp; ++i)
		if(eval('document.stat_subj.checkbox'+i+'.checked'))
			++tobeRemoved;
			
	if(tobeRemoved == 0) {
		alert("Please select atleast one subject to dissolve.");
		return;
	}
	
	var vProceed = 
	confirm("Do you agree to dissolve total "+tobeRemoved+" subject offering. This will remove faculty load, students enrolled and room assignment.");
	if(!vProceed)
		return;

	document.stat_subj.dissolve_sub.value = "1";
	this.SubmitOnce("stat_subj");
}
function updateLecLabLabel() {
	if(document.stat_subj.close_unit && document.getElementById('close_')) {
		document.getElementById('close_').innerHTML = document.stat_subj.close_unit.value;
	}
	if(document.stat_subj.open_unit && document.getElementById('open_')) {
		document.getElementById('open_').innerHTML = document.stat_subj.open_unit.value;
	}
	if(document.stat_subj.dissolve_unit && document.getElementById('dissolve_')) {
		document.getElementById('dissolve_').innerHTML = document.stat_subj.dissolve_unit.value;
	}
		
}
function loadDept() {
	var objCOA=document.getElementById("load_dept");
	var objCollegeInput = document.stat_subj.c_index[document.stat_subj.c_index.selectedIndex].value;
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
	this.processRequest(strURL);
}
</script>
<body bgcolor="#D2AE72" onLoad="updateLecLabLabel();">
<%
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","STATISTICS",request.getRemoteAddr(),
														"statistics_subjects.jsp");
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

Vector vRetResult = new Vector();
StatEnrollment SE = new StatEnrollment();

Vector vRegIrreg   = new Vector();
String strRegIrreg = null;
boolean bolShowRegIrreg = WI.fillTextValue("show_regirreg").equals("1");



//dissolved subject can be dissolved. Clicking "dissolve subject" removes faculty loading, and room assignment.
if(WI.fillTextValue("dissolve_sub").compareTo("1") == 0) {
	SE.dissolveSubject(dbOP, request);
	strErrMsg = SE.getErrMsg();
}

if(WI.fillTextValue("proceed").compareTo("1") ==0)
{
	vRetResult = SE.getSubjectStat(dbOP,request);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = SE.getErrMsg();
	else {
		if(bolShowRegIrreg) {
			vRegIrreg = SE.getRegIrregStudEnrolledInSection(dbOP, request, WI.fillTextValue("offering_yr_from"),WI.fillTextValue("offering_sem"));
			if(vRegIrreg == null)
				vRegIrreg = new Vector();
		}
	}
}


boolean bolIsPHILCST = strSchCode.startsWith("PHILCST");
enrollment.SubjectSection SS = new enrollment.SubjectSection();

if(strErrMsg == null) 
	strErrMsg = "";

Vector vLecLabUnit    = new Vector();;
boolean bolShowLecLab = false;

if(WI.fillTextValue("show_leclab").length() > 0) {
	bolShowLecLab = true;
	
	String strSQLQuery = "select distinct sub_code, sub_name, lec_unit, lab_unit, hour_lec, hour_lab from subject "+
		"join curriculum on (curriculum.sub_index = subject.sub_index) where subject.is_del = 0 and curriculum.is_valid = 1 order by sub_code";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vLecLabUnit.addElement(rs.getString(1));//[0] sub_code
		vLecLabUnit.addElement(rs.getString(2));//[1] sub_name
		vLecLabUnit.addElement(rs.getString(3));//[2] lec_unit
		vLecLabUnit.addElement(rs.getString(4));//[3] lab_unit
		vLecLabUnit.addElement(rs.getString(5));//[4] hour_lec
		vLecLabUnit.addElement(rs.getString(6));//[5] hour_lab
	}
	rs.close();
}	

int iIndexOf = 0;
String strLecLabUnit = null;

double dSubTotalLec = 0d;
double dSubTotalLab = 0d;

double dTempLec = 0d;
double dTempLab = 0d;

%>
<form name="stat_subj" action="" method="post">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><strong>STATISTICS 
          - SUBJECTS PAGE </strong><strong>FOR 
          AY : <%=WI.fillTextValue("offering_yr_from")%> - <%=WI.fillTextValue("offering_yr_to")%>, 
          <%=dbOP.getHETerm(Integer.parseInt(WI.getStrValue(WI.fillTextValue("offering_sem"), "-1")))%></strong></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr> 
      <td height="25"></td>
      <td colspan="3"><font size="3"><b><%=strErrMsg%></b></font> </td>
    </tr>
<%if(strSchCode.startsWith("FATIMA")){%>
    <tr>
      <td height="25"></td>
      <td colspan="3"><a href="javascript:GoOtherFormat();"><font style="font-weight:bold; color:#FF0000">Go to Other Format</font></a></td>
    </tr>
<%}%>
    <tr> 
      <td height="25"></td>
      <td colspan="3">School offereing year/term: 
        <%
strTemp = WI.fillTextValue("offering_yr_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="offering_yr_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("stat_subj","offering_yr_from","offering_yr_to")'>
        to 
        <%
strTemp = WI.fillTextValue("offering_yr_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="offering_yr_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp; <select name="offering_sem">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("offering_sem");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="19" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td width="4%" height="19"></td>
      <td width="15%" valign="bottom"><font size="1"><strong>SUBJECT STATUS</strong> 
        </font></td>
      <td colspan="2" valign="bottom"><font size="1"><strong> 
        <!--DATE RANGE-->
        </strong></font>
        <hr size="1"></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td><select name="sub_stat">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("sub_stat");
if(strTemp.compareTo("Open") ==0){%>
          <option value="Open" selected>Open</option>
          <%}else{%>
          <option value="Open">Open</option>
          <%}if(strTemp.compareTo("Close") ==0){%>
          <option value="Close" selected>Close</option>
          <%}else{%>
          <option value="Close">Close</option>
          <%}if(strTemp.compareTo("Dissolve") ==0){%>
          <option value="Dissolve" selected>Dissolve</option>
          <%}else{%>
          <option value="Dissolve">Dissolve</option>
          <%}%>
        </select></td>
      <td colspan="2"> 
        <!--From &nbsp;&nbsp; <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('stat_subj.date_from');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To &nbsp;&nbsp; <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('stat_subj.date_to');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      -->
        <%
		strTemp = WI.fillTextValue("inc_not_validated");
		if(strTemp.compareTo("1") == 0) 
			strTemp = " checked";
		else	
			strTemp = "";
		%> <input type="checkbox" name="inc_not_validated" value="1" <%=strTemp%> onClick="ToggleIsConfirmed(1);">
        Include Not valided student &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%
		strTemp = WI.fillTextValue("only_not_validated");
		if(strTemp.compareTo("1") == 0) 
			strTemp = " checked";
		else	
			strTemp = "";
		%> <input type="checkbox" name="only_not_validated" value="1"<%=strTemp%> onClick="ToggleIsConfirmed(2);">
        Show only students not validated</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="2"><strong>Show By :</strong></td>
      <td width="63%" style="font-size:9px; font-weight:bold; color:#0000FF">
	   <%if(strSchCode.startsWith("FATIMA") || true){
			strTemp = WI.fillTextValue("show_regirreg");
			if(strTemp.compareTo("1") == 0) 
				strTemp = " checked";
			else	
				strTemp = "";
			%> <input type="checkbox" name="show_regirreg" value="1"<%=strTemp%>>
			Show Regular/Irregular Student enrolled
	    <%}%>	  </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>College offered</td>
      <td colspan="2"><select name="c_index" onChange="loadDept();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select> </td>
    </tr>
    <tr>
      <td height="25"></td>
      <td>Dept Offered </td>
      <td colspan="2">
<label id="load_dept">
<select name="d_index">
        <option value="">ALL</option>
<%
if(WI.fillTextValue("c_index").length() > 0) {
	strTemp = " from department where is_del=0 and c_index="+WI.fillTextValue("c_index") ;
%>
        <%=dbOP.loadCombo("d_index","d_name",strTemp, WI.fillTextValue("d_index"), false)%>
<%}%>
      </select>	  
</label>
	  </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Sub Catg</td>
      <td colspan="2"><select name="catg_index" onChange="ReloadSubjectCatg();">
          <option value="">All</option>
          <%=dbOP.loadCombo("CATG_INDEX","CATG_NAME"," from SUBJECT_CATG where IS_DEL=0 order by CATG_NAME asc",
		  		request.getParameter("catg_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td> Subject</td>
      <td colspan="2"><select name="sub_index" onChange="ReloadPage();" style="font-size:11px">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("catg_index");
if(strTemp.length() > 0)
	strTemp = " and catg_index ="+WI.fillTextValue("catg_index");
%>
          <%=dbOP.loadCombo("sub_index","sub_code"," from subject where IS_DEL=0"+strTemp+" order by sub_code asc",
  		request.getParameter("sub_index"), false)%> </select> <font size="1"> 
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'stat_subj');">
        (enter sub code to scroll)</font></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>&nbsp;</td>
      <td colspan="2"><font size="3" color="#0000FF"> 
        <%
if(WI.fillTextValue("sub_index").length() > 0){%>
        <%=dbOP.mapOneToOther("SUBJECT","sub_index",WI.fillTextValue("sub_index"),
	  					"sub_name",null)%> 
        <%}%>
        </font></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Arrange Result</td>
      <td colspan="2"><select name="sort_by1" style="font-size:11px;">
          <option value="">N/A</option>
          <%
strTemp = WI.fillTextValue("sort_by1");
if(strTemp.compareTo("sub_code") == 0){%>
          <option value="sub_code" selected>Subject Code</option>
<%}else{%>
          <option value="sub_code">Subject Code</option>
<%}if(strTemp.compareTo("sub_name") == 0){%>
          <option value="sub_name" selected>Subject Description</option>
<%}else{%>
          <option value="sub_name">Subject Description</option>
<%}if(strTemp.compareTo("tot_enrolled") == 0){%>
          <option value="tot_enrolled" selected>Total enrolled</option>
<%}else{%>
          <option value="tot_enrolled">Total enrolled</option>
<%}%>
        </select> <select name="sort_by1_con" style="font-size:11px;">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select>
        AND 
        <select name="sort_by2" style="font-size:11px;">
          <option value="">N/A</option>
          <%
strTemp = WI.fillTextValue("sort_by2");
if(strTemp.compareTo("sub_code") == 0){%>
          <option value="sub_code" selected>Subject Code</option>
<%}else{%>
          <option value="sub_code">Subject Code</option>
<%}if(strTemp.compareTo("sub_name") == 0){%>
          <option value="sub_name" selected>Subject Description</option>
<%}else{%>
          <option value="sub_name">Subject Description</option>
<%}if(strTemp.compareTo("tot_enrolled") == 0){%>
          <option value="tot_enrolled" selected>Total enrolled</option>
<%}else{%>
          <option value="tot_enrolled">Total enrolled</option>
<%}%>
        </select> <select name="sort_by2_con" style="font-size:11px;">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td colspan="2"> <font color="#0000FF" size="1">(NOTE : if no arrange option 
        is slected, result is arranged by college code asc, subject code asc, 
        tot enrolled desc)</font></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="3"> 
        <%
		strTemp = WI.fillTextValue("remove_schedule");
		if(request.getParameter("dissolve_sub") == null)
			strTemp = "1";
			
		if(strTemp.compareTo("1") == 0) 
			strTemp = " checked";
		else	
			strTemp = "";
		%>
        <input type="checkbox" name="remove_schedule" value="1"<%=strTemp%>>
        Remove Schedule Info 
        <%
		strTemp = WI.fillTextValue("remove_offering");
		if(strTemp.compareTo("1") == 0) 
			strTemp = " checked";
		else	
			strTemp = "";
		if(!bolIsPHILCST) {%>
        <input type="checkbox" name="remove_offering" value="1"<%=strTemp%>> Remove Offering College Info 
        <%}
		strTemp = WI.fillTextValue("remove_capacity");
		if(strTemp.compareTo("1") == 0) 
			strTemp = " checked";
		else	
			strTemp = "";
		%>
        <input type="checkbox" name="remove_capacity" value="1"<%=strTemp%>> Remove Max and Min Capacity Info
<%if(bolIsPHILCST) {
		strTemp = WI.fillTextValue("show_leclab");
		if(strTemp.compareTo("1") == 0  || request.getParameter("show_leclab") == null) 
			strTemp = " checked";
		else	
			strTemp = "";
%>		
        <input type="checkbox" name="show_leclab" value="1"<%=strTemp%>> Show Lec/Lab Units.
<%}%>	  </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td width="18%"><input name="image" type="image" onClick="FormProceed();" src="../../../images/form_proceed.gif"></td>
      <td>(Note :: requested subjects are not considered as dissoloved subject)</td>
    </tr>
    <%if(vRetResult != null && vRetResult.size() > 0){%>
    <tr> 
      <td height="25"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintThisPage();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print statistics</font></div></td>
    </tr>
    <tr> 
      <td height="20" colspan="4">&nbsp; </td>
    </tr>
    <%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){
	strTemp = WI.fillTextValue("sub_stat");
	Vector vTemp = (Vector)vRetResult.elementAt(0);
	if(strTemp.length() ==0 || strTemp.compareTo("Open") ==0 ){
		if(vTemp != null && vTemp.size() > 0){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr >
      <td height="25" width="50%" class="thinborder">&nbsp;&nbsp;SUBJECT STATUS :<strong> OPEN</strong></td>
      <td width="30%" class="thinborder">TOTAL OPEN SUBJECTS: <%=Integer.parseInt(WI.getStrValue(vTemp.elementAt(0),"0"))%></td>
<%if(bolShowLecLab){%>
      <td width="20%" class="thinborder">TOTAL LEC/LAB: <label id="open_"></label></td>
<%}%>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr>
<%if(WI.fillTextValue("remove_offering").compareTo("1") != 0) {%>
      <td width="7%" align="center"><font size="1"><strong>OFFERING <%if(bolIsPHILCST){%>CODE<%}else{%>COLLEGE<%}%></strong></font></td>
      <%}%>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td width="30%" align="center" class="thinborder"><font size="1"><strong>SUBJECT DESCRIPTION</strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>SECTION</strong></font></td>
<%if(!WI.fillTextValue("remove_schedule").equals("1")) {%>
      <td width="40%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
<%}if(bolShowLecLab) {%>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>LEC/LAB</strong></font></td>
<%}%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>TOTAL STUD. ENROLLED</strong></font></td>
<%if(WI.fillTextValue("remove_capacity").compareTo("1") != 0) {%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>MIN CAPACITY</strong></font></td>
      <td width="6%" height="27" align="center" class="thinborder"><font size="1"><strong>MAX CAPACITY</strong></font></td>
<%}%>
    </tr>
    <%
 for(int i=1; i< vTemp.size(); ++i){
 //System.out.println(vTemp.elementAt(i + 8));
	if(bolShowRegIrreg) {
		iIndexOf = vRegIrreg.indexOf(new Integer((String)vTemp.elementAt(i + 8)));
		if(iIndexOf == -1) 
			strRegIrreg = "0/0";
		else {
			strRegIrreg = WI.getStrValue((String)vRegIrreg.elementAt(iIndexOf + 1), "0") +"/"+WI.getStrValue((String)vRegIrreg.elementAt(iIndexOf + 2), "0");
			vRegIrreg.remove(iIndexOf);vRegIrreg.remove(iIndexOf);vRegIrreg.remove(iIndexOf);
		}
		strRegIrreg = "<br>"+strRegIrreg;
	}
	else	
		strRegIrreg = "&nbsp;";
	
 if(bolIsPHILCST) {
 	strErrMsg = SS.convertOfferingCodeToPHILCSTFormat((String)vTemp.elementAt(i + 9),
					WI.fillTextValue("offering_sem"));
 }
 else	
 	strErrMsg = (String)vTemp.elementAt(i);%>
    <tr>
<%if(WI.fillTextValue("remove_offering").compareTo("1") != 0) {%>
      <td class="thinborderTOP"><%=strErrMsg%></td>
      <%}%>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vTemp.elementAt(i+3),"&nbsp;")%></td>
<%if(!WI.fillTextValue("remove_schedule").equals("1")) {%>
      <td class="thinborder"><%=WI.getStrValue(vTemp.elementAt(i+7),"&nbsp;")%></td>
<%}if(bolShowLecLab) {
iIndexOf = vLecLabUnit.indexOf((String)vTemp.elementAt(i+1));

while(iIndexOf > -1) {
	if(vLecLabUnit.elementAt(iIndexOf + 1).equals(vTemp.elementAt(i+2)))
		break;
	iIndexOf = vLecLabUnit.indexOf((String)vTemp.elementAt(i+1), iIndexOf + 2);
}
if(iIndexOf > -1) {
	if(vLecLabUnit.elementAt(iIndexOf + 2) == null)
		dTempLec = 0d;
	else	
		dTempLec = Double.parseDouble((String)vLecLabUnit.elementAt(iIndexOf + 2));
	if(vLecLabUnit.elementAt(iIndexOf + 3) == null)
		dTempLab = 0d;
	else	
		dTempLab = Double.parseDouble((String)vLecLabUnit.elementAt(iIndexOf + 3));
	
	strLecLabUnit = CommonUtil.formatFloat(dTempLec, false) + "/"+CommonUtil.formatFloat(dTempLab, false);
	
	dSubTotalLec += dTempLec;
	dSubTotalLab += dTempLab;
	//vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);
}
else
	strLecLabUnit = "0/0";

%>
      <td width="5%" align="center" class="thinborder"><%=strLecLabUnit%></td>
<%}%>
      <td height="25" class="thinborder" align="center"><%=WI.getStrValue(vTemp.elementAt(i+4),"&nbsp;")%>
	  <font color="#0000FF"><%=strRegIrreg%></font></td>
<%if(WI.fillTextValue("remove_capacity").compareTo("1") != 0) {%>
      <td class="thinborder"><div align="center"><%=WI.getStrValue(vTemp.elementAt(i+5),"&nbsp;")%></div></td>
      <td height="25" class="thinborder" align="center"><%=WI.getStrValue(vTemp.elementAt(i+6),"&nbsp;")%></td>
<%}%>
    </tr>
    <%i=i+9;
 }%>
  </table>
<%
strLecLabUnit = CommonUtil.formatFloat(dSubTotalLec, false) + "/"+CommonUtil.formatFloat(dSubTotalLab, false);
dSubTotalLec = 0d;
dSubTotalLab = 0d;
%>
<input type="hidden" name="open_unit" value="<%=strLecLabUnit%>">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="18">&nbsp;</td>
      <td width="71%" valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
    </tr>
    <tr>
</table>
<%}else{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr >
      <td height="25" width="50%">&nbsp;&nbsp;SUBJECT STATUS :<strong> OPEN</strong></td>
      <td width="50%">TOTAL OPEN SUBJECTS: 0</td>
    </tr>
  </table>
<%}
}
vTemp = (Vector)vRetResult.elementAt(1);
if(strTemp.length() ==0 || strTemp.compareTo("Close") ==0 ){
if(vTemp != null && vTemp.size() > 0){
	%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr >
      <td height="25" width="50%" class="thinborder">&nbsp;&nbsp;SUBJECT STATUS :<strong> CLOSED</strong></td>
      <td width="30%" class="thinborder">TOTAL CLOSED SUBJECTS: <%=Integer.parseInt(WI.getStrValue(vTemp.elementAt(0),"0"))%></td>
<%if(bolShowLecLab){%>
      <td width="20%" class="thinborder">TOTAL LEC/LAB: <label id="close_"></label></td>
<%}%>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr>
    <tr>
<%if(WI.fillTextValue("remove_offering").compareTo("1") != 0) {%>
      <td width="7%" align="center"><font size="1"><strong>OFFERING <%if(bolIsPHILCST){%>CODE<%}else{%>COLLEGE<%}%></strong></font></td>
<%}%>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td width="30%" align="center" class="thinborder"><font size="1"><strong>SUBJECT DESCRIPTION</strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>SECTION</strong></font></td>
<%if(!WI.fillTextValue("remove_schedule").equals("1")) {%>
      <td width="40%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
<%}if(bolShowLecLab) {%>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>LEC/LAB</strong></font></td>
<%}%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>TOTAL STUD. ENROLLED</strong></font></td>
<%if(WI.fillTextValue("remove_capacity").compareTo("1") != 0) {%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>MIN CAPACITY</strong></font></td>
      <td width="6%" height="27" align="center" class="thinborder"><font size="1"><strong>MAX CAPACITY</strong></font></td>
<%}%>
    </tr>
    <%
 for(int i=1; i< vTemp.size(); ++i){
	if(bolShowRegIrreg) {
		iIndexOf = vRegIrreg.indexOf(new Integer((String)vTemp.elementAt(i + 8)));
		if(iIndexOf == -1) 
			strRegIrreg = "0/0";
		else {
			strRegIrreg = WI.getStrValue((String)vRegIrreg.elementAt(iIndexOf + 1), "0") +"/"+WI.getStrValue((String)vRegIrreg.elementAt(iIndexOf + 2), "0");
			vRegIrreg.remove(iIndexOf);vRegIrreg.remove(iIndexOf);vRegIrreg.remove(iIndexOf);
		}
		strRegIrreg = "<br>"+strRegIrreg;
	}
	else	
		strRegIrreg = "&nbsp;";


 if(bolIsPHILCST) {
 	strErrMsg = SS.convertOfferingCodeToPHILCSTFormat((String)vTemp.elementAt(i + 9),
					WI.fillTextValue("offering_sem"));
 }
 else	
 	strErrMsg = (String)vTemp.elementAt(i);%>
    <tr>
<%if(WI.fillTextValue("remove_offering").compareTo("1") != 0) {%>
      <td class="thinborderTOP"><%=strErrMsg%></td>
      <%}%>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vTemp.elementAt(i+3),"&nbsp;")%></td>
<%if(!WI.fillTextValue("remove_schedule").equals("1")) {%>
      <td class="thinborder"><%=WI.getStrValue(vTemp.elementAt(i+7),"&nbsp;")%></td>
<%}if(bolShowLecLab) {
iIndexOf = vLecLabUnit.indexOf((String)vTemp.elementAt(i+1));

while(iIndexOf > -1) {
	if(vLecLabUnit.elementAt(iIndexOf + 1).equals(vTemp.elementAt(i+2)))
		break;
	iIndexOf = vLecLabUnit.indexOf((String)vTemp.elementAt(i+1), iIndexOf + 2);
}
if(iIndexOf > -1) {
	if(vLecLabUnit.elementAt(iIndexOf + 2) == null)
		dTempLec = 0d;
	else	
		dTempLec = Double.parseDouble((String)vLecLabUnit.elementAt(iIndexOf + 2));
	if(vLecLabUnit.elementAt(iIndexOf + 3) == null)
		dTempLab = 0d;
	else	
		dTempLab = Double.parseDouble((String)vLecLabUnit.elementAt(iIndexOf + 3));
	
	strLecLabUnit = CommonUtil.formatFloat(dTempLec, false) + "/"+CommonUtil.formatFloat(dTempLab, false);
	
	dSubTotalLec += dTempLec;
	dSubTotalLab += dTempLab;
	//vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);
}
else
	strLecLabUnit = "0/0";

%>
      <td width="5%" align="center" class="thinborder"><%=strLecLabUnit%></td>
<%}%>
      <td class="thinborder"><div align="center"><%=WI.getStrValue(vTemp.elementAt(i+4),"&nbsp;")%><font color="#0000FF"><%=strRegIrreg%></font></div></td>
<%if(WI.fillTextValue("remove_capacity").compareTo("1") != 0) {%>
      <td class="thinborder"><div align="center"><%=WI.getStrValue(vTemp.elementAt(i+5),"&nbsp;")%></div></td>
      <td height="25" class="thinborder"><div align="center"><%=WI.getStrValue(vTemp.elementAt(i+6),"&nbsp;")%></div></td>
<%}%>    </tr>
    <%i=i+9;
 }%>
  </table>
<%
strLecLabUnit = CommonUtil.formatFloat(dSubTotalLec, false) + "/"+CommonUtil.formatFloat(dSubTotalLab, false);
dSubTotalLec = 0d;
dSubTotalLab = 0d;
%>
<input type="hidden" name="close_unit" value="<%=strLecLabUnit%>">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="18">&nbsp;</td>
      <td width="71%" valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
    </tr>
    <tr>
</table>
<%}else{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr >
      <td height="25" width="50%">&nbsp;&nbsp;SUBJECT STATUS :<strong> CLOSED</strong></td>
      <td width="50%">TOTAL CLOSED SUBJECTS: 0</td>
    </tr>
  </table>
<%}
}vTemp = (Vector)vRetResult.elementAt(2);
if(strTemp.length() ==0 || strTemp.compareTo("Dissolve") ==0 ){
if(vTemp != null && vTemp.size() > 0){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr >
      <td height="25" width="50%" class="thinborder">&nbsp;&nbsp;SUBJECT STATUS :<strong> DISSOLVED</strong></td>
      <td width="30%" class="thinborder">TOTAL DISSOLVED SUBJECTS: <%=Integer.parseInt(WI.getStrValue(vTemp.elementAt(0),"0"))%></td>
<%if(bolShowLecLab){%>
      <td width="20%" class="thinborder">TOTAL LEC/LAB: <label id="dissolve_"></label></td>
<%}%>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr> 
      <%if(WI.fillTextValue("remove_offering").compareTo("1") != 0) {%>
      <td width="7%" align="center"><font size="1"><strong>OFFERING <%if(bolIsPHILCST){%>CODE<%}else{%>COLLEGE<%}%></strong></font></td>
      <%}%>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td width="30%" align="center" class="thinborder"><font size="1"><strong>SUBJECT DESCRIPTION</strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>SECTION</strong></font></td>
<%if(!WI.fillTextValue("remove_schedule").equals("1")) {%>
      <td width="40%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
<%}if(bolShowLecLab) {%>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>LEC/LAB</strong></font></td>
<%}%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>TOTAL STUD. ENROLLED</strong></font></td>
      <%if(WI.fillTextValue("remove_capacity").compareTo("1") != 0) {%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>MIN CAPACITY</strong></font></td>
      <td width="6%" height="27" align="center" class="thinborder"><font size="1"><strong>MAX 
        CAPACITY</strong></font></td>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">SELECT ALL</font></strong> <br> <input type="checkbox" name="selAll" value="1" onClick="checkAll();"></td>
      <%}%>
    </tr>
    <%
	int j = 0; 
 for(int i=1; i< vTemp.size(); ++i,++j){

	if(bolShowRegIrreg) {
		iIndexOf = vRegIrreg.indexOf(new Integer((String)vTemp.elementAt(i + 8)));
		if(iIndexOf == -1) 
			strRegIrreg = "0/0";
		else {
			strRegIrreg = WI.getStrValue((String)vRegIrreg.elementAt(iIndexOf + 1), "0") +"/"+WI.getStrValue((String)vRegIrreg.elementAt(iIndexOf + 2), "0");
			vRegIrreg.remove(iIndexOf);vRegIrreg.remove(iIndexOf);vRegIrreg.remove(iIndexOf);
		}
		strRegIrreg = "<br>"+strRegIrreg+ "&nbsp;"+vTemp.elementAt(i + 8);
	}
	else	
		strRegIrreg = "&nbsp;";

 if(bolIsPHILCST) {
 	strErrMsg = SS.convertOfferingCodeToPHILCSTFormat((String)vTemp.elementAt(i + 9),
					WI.fillTextValue("offering_sem"));
 }
 else	
 	strErrMsg = (String)vTemp.elementAt(i);%>
    <tr>
<%if(WI.fillTextValue("remove_offering").compareTo("1") != 0) {%>
      <td class="thinborderTOP"><%=strErrMsg%></td>
      <%}%>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vTemp.elementAt(i+3),"&nbsp;")%></td>
<%if(!WI.fillTextValue("remove_schedule").equals("1")) {%>
      <td class="thinborder"><%=WI.getStrValue(vTemp.elementAt(i+7),"&nbsp;")%></td>
<%}if(bolShowLecLab) {
iIndexOf = vLecLabUnit.indexOf((String)vTemp.elementAt(i+1));

while(iIndexOf > -1) {
	if(vLecLabUnit.elementAt(iIndexOf + 1).equals(vTemp.elementAt(i+2)))
		break;
	iIndexOf = vLecLabUnit.indexOf((String)vTemp.elementAt(i+1), iIndexOf + 2);
}
if(iIndexOf > -1) {
	if(vLecLabUnit.elementAt(iIndexOf + 2) == null)
		dTempLec = 0d;
	else	
		dTempLec = Double.parseDouble((String)vLecLabUnit.elementAt(iIndexOf + 2));
	if(vLecLabUnit.elementAt(iIndexOf + 3) == null)
		dTempLab = 0d;
	else	
		dTempLab = Double.parseDouble((String)vLecLabUnit.elementAt(iIndexOf + 3));
	
	strLecLabUnit = CommonUtil.formatFloat(dTempLec, false) + "/"+CommonUtil.formatFloat(dTempLab, false);
	
	dSubTotalLec += dTempLec;
	dSubTotalLab += dTempLab;
	//vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);vLecLabUnit.remove(iIndexOf);
}
else
	strLecLabUnit = "0/0";

%>
      <td width="5%" align="center" class="thinborder"><%=strLecLabUnit%></td>
<%}%>
      <td class="thinborder"><div align="center"><%=WI.getStrValue(vTemp.elementAt(i+4),"&nbsp;")%><font color="#0000FF"><%=strRegIrreg%></font></div></td>
      <%if(WI.fillTextValue("remove_capacity").compareTo("1") != 0) {%>
      <td class="thinborder"><div align="center"><%=WI.getStrValue(vTemp.elementAt(i+5),"&nbsp;")%></div></td>
      <td height="25" class="thinborder"><div align="center"><%=WI.getStrValue(vTemp.elementAt(i+6),"&nbsp;")%></div></td>
      <td class="thinborder" align="center">
		<input type="checkbox" name="checkbox<%=j%>" value="<%=(String)vTemp.elementAt(i+8)%>"></td>
      <%}%>
    </tr>
    <%i=i+9;
 }%>
  </table>
<%
strLecLabUnit = CommonUtil.formatFloat(dSubTotalLec, false) + "/"+CommonUtil.formatFloat(dSubTotalLab, false);
dSubTotalLec = 0d;
dSubTotalLab = 0d;
%>
<input type="hidden" name="dissolve_unit" value="<%=strLecLabUnit%>">

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable0">
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td width="71%" valign="top">&nbsp; <a href="javascript:RemoveDissolvedSub();"><img src="../../../images/delete.gif" border="0"></a> 
        <font size="1">Remove dissolved subject offering, room assignment, faculty 
        load and students enrolled</font> 
		<input type="hidden" name="max_disp" value="<%=j%>"></td>
    </tr>
  </table>
<%}else if(vTemp != null && vTemp.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr >
      <td height="25" width="50%">&nbsp;&nbsp;SUBJECT STATUS :<strong> DISSOLVED</strong></td>
      <td width="50%">TOTAL DISSOLVED SUBJECTS: 0<%//=Integer.parseInt(WI.getStrValue(vTemp.elementAt(0),"0"))%></td>
    </tr>
  </table>
 <%}
}


}//only if vRetResult.size() > 0)%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable00">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="proceed">

 <input type="hidden" name="collge_name">
 <input type="hidden" name="sgroup_name">
 <input type="hidden" name="subject_code">
 
 <input type="hidden" name="dissolve_sub">
 
<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
