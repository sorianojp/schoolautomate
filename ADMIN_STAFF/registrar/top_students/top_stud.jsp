<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCGH = strSchCode.startsWith("CGH");//bolIsCGH = true;
boolean bolIsCIT = strSchCode.startsWith("CIT");//bolIsCGH = true;
boolean bolIsEAC = strSchCode.startsWith("EAC");
if(strSchCode.startsWith("FATIMA"))
	bolIsEAC = true;
	
boolean bolShowGWAPercent = false;
if(bolIsCIT) {
	response.sendRedirect("./top_stud_CIT.jsp");

return;}
if(strSchCode.startsWith("SPC")) {
	response.sendRedirect("./top_stud_SPC.jsp");

return;}
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
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	if(document.form_.course_index.selectedIndex >=0)
	{
		document.form_.cn.value = document.form_.course_index[document.form_.course_index.selectedIndex].text;
		<%if(!bolIsCGH){%>
			document.form_.mn.value = document.form_.major_index[document.form_.major_index.selectedIndex].text;
		<%}%>
	}
	else
	{
		document.form_.cn.value = "";
		document.form_.mn.value = "";
	}
	document.form_.submit();
}
function ShowTopStud(){
	document.form_.showTopStud.value="1";
	ReloadPage();
}
function showHideGWA() {
	var iSelGwaCon = document.form_.gwa_con.selectedIndex;
	if(iSelGwaCon == 0) {
		hideLayer('gwa_fr_label');
		hideLayer('gwa_to_label');
	}
	else if(iSelGwaCon == 3) {
		showLayer('gwa_fr_label');
		showLayer('gwa_to_label');
	}
	else {
		showLayer('gwa_fr_label');
		hideLayer('gwa_to_label');
	}
}
function PrintPage() {
	document.bgColor = "#FFFFFF";
	if(document.form_.show_few && document.form_.show_few.selectedIndex > 0) {
		var iRowsToKeep = document.form_.show_few[document.form_.show_few.selectedIndex].value;
		var iMaxRow = document.form_.max_disp.value;
		var iRowsToDelete = eval(iMaxRow) - eval(iRowsToKeep);
		var objTable = document.getElementById('myADTableContent');
		++iRowsToKeep;
		if(iRowsToDelete > 0) {
			while(iRowsToDelete > 0) {
				objTable.deleteRow(iRowsToKeep);
				--iRowsToDelete;
			}
			--iRowsToKeep;
			document.getElementById('top_stud_no').innerHTML = iRowsToKeep;
		}
	}

	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	//document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	if(document.getElementById('myADTable00'))
	document.getElementById('myADTable2').deleteRow(0);

	if(document.getElementById('myADTable3')) {
		document.getElementById('myADTable3').deleteRow(0);
		document.getElementById('myADTable3').deleteRow(0);
	}
	
	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function UpdateGWAEquivalent() {
	window.open("./gwa_fail_grade.jsp","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
}
function UpdateSubExcluded() {
	window.open("./gwa_sub_excluded.jsp","PrintWindow",'width=800,height=600,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=auto');
}
function UpdateGWA() {
	window.open("./gwa_setting_preload.jsp","PrintWindow",'width=1000,height=800,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
}
function EnableDisableWholeYr() { 
	if(document.form_.get_acad_scholar.checked)
		showLayer('lbl_compute_academic');
	else {
		document.form_.donot_apply_unit_rule.checked = false;
		hideLayer('lbl_compute_academic');
	}
	if(document.form_.get_acad_scholar.checked) {
		document.form_.remove_ir.checked=true;
		document.form_.remove_fg.checked=true;
	}

	if(!document.form_.show_SY)
		return;
	if(document.form_.get_acad_scholar.checked) {
		document.form_.show_SY.checked = false;
		document.form_.show_SY.disabled = true;
	}
	else
		document.form_.show_SY.disabled = false;
}
function ShowWholeSY() {
	if(!document.form_.show_SY)
		return;
		
	if(document.form_.show_SY.checked)
		document.form_.show_.selectedIndex = 0;
	if(document.form_.get_acad_scholar.checked)
		showLayer('lbl_compute_academic');
	else {
		document.form_.donot_apply_unit_rule.checked = false;
		hideLayer('lbl_compute_academic');
	}
	if(document.getElementById('myADTableContent')) {
		if(document.form_.show_.selectedIndex == 0) 
			showLayer('show_rowto_print');
		else {
			document.form_.show_few.selectedIndex = 0;
			hideLayer('show_rowto_print');
		}
	}
}
</script>
<body bgcolor="#D2AE72" onLoad="showHideGWA();ShowWholeSY();">
<%@ page language="java" import="utility.*,student.GWA,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String[] astrConvertToYear = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-TOP STUDENTS","top_stud.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","TOP STUDENTS",request.getRemoteAddr(),
							//							"top_stud.jsp");
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

GWA gwa = new GWA();
Vector vTopStudInfo = null; Vector vCITInfo = null; Vector vOthInfo = null;
//first sem and second sem -- if selected to show for whole year.
Vector vTopStudFS   = null;
Vector vTopStudSS   = null;

int iStartOfZeroGWA = -1;
/////////////////////////////////////////////////////////////////

///comment => remove this code..
//this comment is used to move the student with 0 gwa in fs or ss to the end of list but on top of the list with gwa = 0;
// if it is not needed, just remove the block of code with that comment.. 

if(WI.fillTextValue("showTopStud").compareTo("1") ==0)
{
	//vTopStudInfo = gwa.calGWAForASYAndSem(dbOP,request);
	
	if(WI.fillTextValue("show_SY").length() > 0) {
		request.setAttribute("show_SY", "1");
		vTopStudInfo = gwa.getTopStudentNew(dbOP,request);
		request.setAttribute("remove_con", "1");
		if(vTopStudInfo != null) {
			Vector vStudWithOneSemGwaZero = new Vector();
			Vector vStudWithZero          = new Vector();
			///find where the gwa starts to be zero.. 
			//remove this code..
			for(int i = 0 ; i < vTopStudInfo.size(); i += 5) {
				if(iStartOfZeroGWA == -1 && Double.parseDouble((String)vTopStudInfo.elementAt(i + 3)) == 1000d) {//0 is taken care in java file.. 
					iStartOfZeroGWA = i;
					for(; i < vTopStudInfo.size(); i += 5)
						vStudWithZero.addElement(vTopStudInfo.elementAt(i));
				}
			}
			if(iStartOfZeroGWA == -1)
				iStartOfZeroGWA = vTopStudInfo.size();
			//end of remove this code..
			request.removeAttribute("show_SY");
			
			///get gwa for 1st sem and 2nd sem.. 
			request.setAttribute("semester", "1");
			vTopStudFS = gwa.getTopStudentNew(dbOP,request);
			if(vTopStudFS == null)
				vTopStudFS = new Vector();
			request.setAttribute("semester", "2");
			vTopStudSS = gwa.getTopStudentNew(dbOP,request);
			if(vTopStudSS == null)
				vTopStudSS = new Vector();//System.out.println("vTopStudFS: " +vTopStudFS);System.out.println("vTopStudSS: " +vTopStudSS);
			///remove this code..			
			if(iStartOfZeroGWA > -1) {
				for(int i = 0; i < vTopStudFS.size(); i += 5) {
					if(Double.parseDouble((String)vTopStudFS.elementAt(i + 3)) == 1000d) {
						if(vStudWithZero.indexOf(vTopStudFS.elementAt(i)) != -1)
							break;
						vStudWithOneSemGwaZero.addElement(vTopStudFS.elementAt(i));
					}
				}
				for(int i = 0; i < vTopStudSS.size(); i += 5) {
					if(Double.parseDouble((String)vTopStudSS.elementAt(i + 3)) == 1000d) {
						if(vStudWithZero.indexOf(vTopStudSS.elementAt(i)) != -1)
							break;
						vStudWithOneSemGwaZero.addElement(vTopStudSS.elementAt(i));
					}
				}
			}
			vStudWithZero.clear();
			if(vStudWithOneSemGwaZero.size() > 0) {
				for(int i = 0 ; i < vTopStudInfo.size(); i += 5) {
					if(i >= iStartOfZeroGWA)
						break;
					if(vStudWithOneSemGwaZero.indexOf(vTopStudInfo.elementAt(i)) != -1) {//System.out.println("I am here..");
						vStudWithZero.addElement(vTopStudInfo.remove(0));
						vStudWithZero.addElement(vTopStudInfo.remove(0));
						vStudWithZero.addElement(vTopStudInfo.remove(0));
						vStudWithZero.addElement(vTopStudInfo.remove(0));
						vStudWithZero.addElement(vTopStudInfo.remove(0));
						iStartOfZeroGWA -= 5;
						i -= 5; 
						continue;
					}
				}
				//insert if there is some data..
				if(vStudWithZero.size() > 0) 
					for(int i = vStudWithZero.size(); vStudWithZero.size() > 0;)
						vTopStudInfo.insertElementAt(vStudWithZero.remove(--i),iStartOfZeroGWA);
			}
			///end of remove this code..
		}
	}
	else
		vTopStudInfo = gwa.getTopStudentNew(dbOP,request);
	//System.out.println(vTopStudInfo);
	if(vTopStudInfo == null)
		strErrMsg = gwa.getErrMsg();
	else {
		dbOP.forceAutoCommitToTrue();
		//long lTimeNow = new java.util.Date().getTime();
		if(bolIsEAC)
			vCITInfo = gwa.getOtherStudentInfoForGWA(dbOP, request);
		//System.out.println((new java.util.Date().getTime() - lTimeNow)/1000);
		//System.out.println(vCITInfo);
		//System.out.println(gwa.getErrMsg());
	}
}
//System.out.println(vTopStudFS);System.out.println(vTopStudSS);

if(strErrMsg == null) strErrMsg = "";
boolean bolShowSY = false;//show full School year. 
if(WI.fillTextValue("show_SY").length() > 0) 
	bolShowSY = true;


Vector vGWAPreloadSetting = null;
if(WI.fillTextValue("gwa_preload").length() > 0) {
	request.setAttribute("info_index", WI.fillTextValue("gwa_preload"));
	vGWAPreloadSetting = gwa.operateOnPreloadGWASetting(dbOP, request, 3);
}
%>

<form name="form_" action="./top_stud.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        TOP STUDENTS PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">Preload Report </td>
      <td colspan="2"><select name="gwa_preload" onChange="document.form_.submit();">
          <option value=""></option>
          <%=dbOP.loadCombo("GWA_PRELOAD","REPORT_NAME"," from GWA_PRELOAD_SETTING order by REPORT_NAME asc",WI.fillTextValue("gwa_preload"), false)%> </select>
		  
		  <a href="javascript:UpdateGWA();"><img src="../../../images/update.gif" border="0"></a>		  </td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td width="9%" height="25" >SY/Term </td>
      <td width="41%" >
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
		  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		readonly="yes">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
      <td width="49%" >Year  
        <select name="year_level">
		<option value="">All Year</option>
<%
strTemp = request.getParameter("year_level");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st</option>
<%}else{%>
          <option value="1">1st</option>
<%}if(strTemp.compareTo("2") ==0){%>
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
        </select>
		
		&nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("get_acad_scholar");
if(vGWAPreloadSetting != null) {
	strTemp = (String)vGWAPreloadSetting.elementAt(11);
	if(strTemp == null)
		strTemp = "";
	else	
		strTemp = " checked";
}%>
	  <input name="get_acad_scholar" type="checkbox" value="checked" <%=strTemp%> onClick="EnableDisableWholeYr();"> 
	  <font style="color:#0000FF; font-size:10px; font-weight:bold">Compute Academic Scholar.<br>
<%
strTemp = WI.fillTextValue("donot_apply_unit_rule");
if(vGWAPreloadSetting != null) {
	strTemp = (String)vGWAPreloadSetting.elementAt(12);
	if(strTemp == null)
		strTemp = "";
	else	
		strTemp = " checked";
}%>
	  <label id="lbl_compute_academic"><input type="checkbox" name="donot_apply_unit_rule" value="checked" <%=strTemp%>> Do not apply Curriculum Unit rule</label></font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td >College</td>
      <td colspan="2" ><select name="c_index" style="width:400px" onChange="ReloadPage();">
        <option value=""></option>
        <%=dbOP.loadCombo("c_index","c_name", " from college where is_del=0 order by c_name asc", request.getParameter("c_index"), false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td >Course </td>
      <td colspan="2" ><select name="course_index" style="width:400px" onChange="ReloadPage();">
          <option value="">All Course</option>
<%
if(WI.fillTextValue("c_index").length() > 0)
	strTemp = " and c_index = "+WI.fillTextValue("c_index");
else	
	strTemp = "";
%>
          <%=dbOP.loadCombo("course_index","course_name",
		  " from course_offered where IS_DEL=0 and is_valid=1 and degree_type=0 "+strTemp+" order by course_name asc",
		  request.getParameter("course_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td ><%if(!bolIsCGH){%>Major<%}%>&nbsp;</td>
      <td colspan="2" >
	  <%if(bolIsCGH){%>
	  <input name="show_SY" type="checkbox" value="checked" <%=WI.fillTextValue("show_SY")%> onClick="ShowWholeSY();"> <font style="color:#0000FF; font-size:10px; font-weight:bold">Show for whole School Year.</font>
	  <%}else{%>
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
        </select>
		<%}//show if not CGH.. %>	  </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2" >Grade equiv. in GWA computation (if grade is empty in grade encoding) 
	  <a href="javascript:UpdateGWAEquivalent();"><img src="../../../images/update.gif" border="0"></a>
	  <br>
	  <table width="75%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
	  <%
	  java.sql.ResultSet rs = dbOP.executeQuery("select GWA_INDEX,GRADE,GRADE_PERCENT,REMARK_abbr,remark from gwa_extn "+
	  "join remark_status on (remark_status.remark_index = gwa_extn.remark_index) order by remark_abbr");
	  while(rs.next()){%>
	  	<tr bgcolor="#EEFEFF">
			<td class="thinborder" width="33%"><%=rs.getString(2)%></td>
			<td class="thinborder" width="33%"><%=rs.getString(3)%></td>
			<td class="thinborder" width="34%"><%=rs.getString(5)%> ::: <%=rs.getString(4)%></td>
		</tr>
	  <%}rs.close();%>
	  </table>	  </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2" >Subject Excluded in GWA Computation
	  <a href="javascript:UpdateSubExcluded();"><img src="../../../images/update.gif" border="0"></a>
	  <br>
	  <table width="75%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
	  <%
rs = dbOP.executeQuery("select sub_code, sub_name, GWA_EX_INDEX,course_code, course_Name  from GWA_EXCLUDED "+
							"join subject on (GWA_EXCLUDED.sub_index = subject.sub_index)  "+
							"left join course_offered on (course_offered.course_index = course_index_)  order by course_code, sub_code");
	  while(rs.next()){%>
	  	<tr bgcolor="#EEFEFF">
			<td class="thinborder" width="33%"><%=rs.getString(1)%></td>
			<td class="thinborder"><%=rs.getString(2)%></td>
		</tr>
	  <%}rs.close();%>
	  </table>	 </td>
    </tr>
    <tr> 
      <td colspan="4" height="10" >&nbsp;</td>
    </tr>
  </table>
  <table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable2">
<%
strTemp = WI.fillTextValue("report_name");
if(vGWAPreloadSetting != null) {
	strTemp = (String)vGWAPreloadSetting.elementAt(1);
}%>
    <tr>
      <td height="19" bgcolor="#FFFFCC" class="thinborder">
        <strong><font size="1">&nbsp; GWA FILTER</font></strong> ::   Report Name: 
        <input name="report_name" type="text" size="55" 
		value="<%=WI.getStrValue(strTemp,"<<For example. Dean's lister/ Top student>>")%>" class="textbox"
		onfocus="document.form_.report_name.select();style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="font-size:11px"></td>
    </tr>
    <tr bgcolor="#dddddd"> 
      <td width="21%" height="25" class="thinborder">&nbsp;1. Show GWA : 
        <select name="gwa_con" onChange="showHideGWA();">
          <option value="0">No Filter</option>
<%
strTemp = WI.fillTextValue("gwa_con");
if(vGWAPreloadSetting != null)
	strTemp = WI.getStrValue(vGWAPreloadSetting.elementAt(2));
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1"<%=strErrMsg%>>Greater than</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>          <option value="2"<%=strErrMsg%>>Less than</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>          <option value="3"<%=strErrMsg%>>Between</option>
        </select>
&nbsp;&nbsp;&nbsp;
<%
if(vGWAPreloadSetting != null)
	strTemp = WI.getStrValue(vGWAPreloadSetting.elementAt(3));
else
	strTemp = WI.fillTextValue("gwa_fr");
%>
      <input name="gwa_fr" type="text" size="3" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','gwa_fr');style.backgroundColor='white'"
		onKeyup="AllowOnlyFloat('form_','gwa_fr');" style="font-size:12px" id="gwa_fr_label">
<label id="gwa_to_label">
&nbsp;&nbsp;to&nbsp;&nbsp;
<%
if(vGWAPreloadSetting != null)
	strTemp = WI.getStrValue(vGWAPreloadSetting.elementAt(4));
else
	strTemp = WI.fillTextValue("gwa_to");
%>
      <input name="gwa_to" type="text" size="3" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','gwa_to');style.backgroundColor='white'"
		onKeyup="AllowOnlyFloat('form_','gwa_to');" style="font-size:12px" >
</label>	  </td>
    </tr>
    <tr bgcolor="#dddddd"> 
      <td height="25" class="thinborder">&nbsp;2. Students with Minimum Units : 
<%
if(vGWAPreloadSetting != null)
	strTemp = WI.getStrValue(vGWAPreloadSetting.elementAt(5));
else
	strTemp = WI.fillTextValue("min_unit");
%>
        <input name="min_unit" type="text" size="3" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','min_unit');style.backgroundColor='white'"
		onKeyup="AllowOnlyInteger('form_','min_unit');" style="font-size:12px" >
&nbsp;&nbsp;&nbsp;&nbsp;3. Students with  Final Grade:
<select name="final_grade_con">
  <option value="0">Greater than</option>
<%
if(vGWAPreloadSetting != null)
	strTemp = WI.getStrValue(vGWAPreloadSetting.elementAt(6));
else
	strTemp = WI.fillTextValue("final_grade_con");
if(strTemp.equals("1"))
	strTemp = " selected";
else
	strTemp = "";
%>  <option value="1"<%=strTemp%>>Less than</option>
</select> 
<%
if(vGWAPreloadSetting != null)
	strTemp = WI.getStrValue(vGWAPreloadSetting.elementAt(7));
else
	strTemp = WI.fillTextValue("final_grade");
%>
      <input name="final_grade" type="text" size="4" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','final_grade');style.backgroundColor='white'"
		onKeyup="AllowOnlyFloat('form_','final_grade');" style="font-size:12px" >	  </td>
    </tr>
    <tr bgcolor="#dddddd"> 
      <td height="25" class="thinborder">
<%
if(vGWAPreloadSetting != null)
	strTemp = WI.getStrValue(vGWAPreloadSetting.elementAt(8));
else
	strTemp = WI.fillTextValue("remove_fg");
if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>
        4. <input type="checkbox" name="remove_fg" value="1" <%=strTemp%>>
        Show Student with all passing grade 
&nbsp;&nbsp;&nbsp;
<%
if(vGWAPreloadSetting != null)
	strTemp = WI.getStrValue(vGWAPreloadSetting.elementAt(9));
else
	strTemp = WI.fillTextValue("remove_ir");
if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>		5. <input type="checkbox" name="remove_ir" value="1" <%=strTemp%>>Remove Irregular student
&nbsp;&nbsp;&nbsp;
	  Show Result 
<%
strTemp = WI.fillTextValue("show_");
if(request.getParameter("show_") == null) 
	strTemp = "10";
%>
	  <select name="show_" onChange="ShowWholeSY();">
	  <option value="">ALL</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="3"<%=strErrMsg%>>Top 3</option>
<%
if(strTemp.equals("10"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="10"<%=strErrMsg%>>Top 10</option>
<%
if(strTemp.equals("15"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="15"<%=strErrMsg%>>Top 15</option>
<%
if(strTemp.equals("20"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="20"<%=strErrMsg%>>Top 20</option>
<%
if(strTemp.equals("25"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="25"<%=strErrMsg%>>Top 25</option>
<%
if(strTemp.equals("30"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="30"<%=strErrMsg%>>Top 30</option>
<%
if(strTemp.equals("35"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="35"<%=strErrMsg%>>Top 35</option>
<%
if(strTemp.equals("40"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="40"<%=strErrMsg%>>Top 40</option>
<%
if(strTemp.equals("45"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="45"<%=strErrMsg%>>Top 45</option>
<%
if(strTemp.equals("50"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="50"<%=strErrMsg%>>Top 50</option>
<%
if(strTemp.equals("55"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="55"<%=strErrMsg%>>Top 55</option>
<%
if(strTemp.equals("60"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="60"<%=strErrMsg%>>Top 60</option>
<%
if(strTemp.equals("65"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="65"<%=strErrMsg%>>Top 65</option>
<%
if(strTemp.equals("75"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="75"<%=strErrMsg%>>Top 75</option>
<%
if(strTemp.equals("100"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	  <option value="100"<%=strErrMsg%>>Top 100</option>
	    </select>	  </td>
    </tr>
    <tr bgcolor="#dddddd">
      <td height="25" class="thinborder">&nbsp;
	  Order by(GWA) : 
<%
if(vGWAPreloadSetting != null)
	strTemp = WI.getStrValue(vGWAPreloadSetting.elementAt(10));
else
	strTemp = WI.fillTextValue("sort_by");
if(strTemp.equals("asc") || strTemp.length() == 0) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input name="sort_by" type="radio" value="asc"<%=strErrMsg%>>Asc
&nbsp;
<%
if(strTemp.equals("desc")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	   <input name="sort_by" type="radio" value="desc"<%=strErrMsg%>>Desc		  
&nbsp;&nbsp;&nbsp; 
<%if(bolIsCGH) {%>
<input type="checkbox" name="p_grade" value="checked" <%=WI.fillTextValue("p_grade")%>>%ge Grade
<%}//show only if cgh%>

&nbsp;&nbsp;&nbsp; (Student Name) : 
<%
if(strTemp.equals("asc2")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input name="sort_by" type="radio" value="asc2"<%=strErrMsg%>>Asc&nbsp;
      <%
if(strTemp.equals("desc2")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	   <input name="sort_by" type="radio" value="desc2"<%=strErrMsg%>>Desc		  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="submit" name="1" value="Show GWA List" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.showTopStud.value=1"></td>
    </tr>
<%if(bolIsCGH){
strTemp = WI.fillTextValue("show_gwa_percent");
if(strTemp.length() > 0) {
	bolShowGWAPercent = true;
	strTemp = " checked";
}
else	
	strTemp = "";
%>
    <tr bgcolor="#dddddd" id="myADTable00">
      <td height="25" class="thinborder">&nbsp;&nbsp; Show GWA - using percentage grade.
	  <input type="checkbox" value="1" name="show_gwa_percent" <%=strTemp%>>
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  Include Student with TC 
	  <input type="checkbox" name="inc_tc" value="checked" <%=WI.fillTextValue("inc_tc")%>>
	  </td>
    </tr>
<%}%>
  </table>

  <%
if(vTopStudInfo != null && vTopStudInfo.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr >
      <td width="100%" height="25">&nbsp;
<%if(bolIsCGH && WI.fillTextValue("year_level").equals("1") ){//if cgh, and first year, i show them option to give TC to all student. 
strTemp = WI.fillTextValue("force_tc");
//if(strTemp.equals("1"))
//	strTemp = " checked";
//else
	strTemp = "";
%>
	<input type="checkbox" name="force_tc" value="1"<%=strTemp%>>&nbsp;
		Give TC to the students in list .
      <input type="submit" name="12" value="Give TC" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.showTopStud.value=1;document.form_.give_tc.value='1'">

<%
strTemp = "";
if(WI.fillTextValue("force_tc").equals("1")) {
	strTemp = WI.fillTextValue("tc_date");
	if(strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);	
}
%>
	  TC Date : 
	<input name="tc_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.tc_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  
	  
	  </td>
      <%}%>
	  
	  
	  </td>
    </tr>
    <tr >
      <td height="25"><div align="right"><font size="1">
	  <label id="show_rowto_print">
	  Print only First few Rows : 
	  <select name="show_few">
	  <option value=""></option>
	  <option value="3">First 3</option>
	  <option value="5">First 5</option>
	  <option value="10">First 10</option>
	  <option value="15">First 15</option>
	  <option value="20">First 20</option>
	  </select>
	  </label>
          <a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
           click to print list</font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" colspan="2" align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
    </tr>
    <tr >
      <td height="20" colspan="2" class="thinborderBOTTOM"><div align="center"><strong>
<%
strTemp = WI.fillTextValue("report_name").toUpperCase();
if(strTemp.length() == 0 || strTemp.equals("<<For example. Dean's lister/ Top student>>".toUpperCase()))
	strTemp = "TOP STUDENT REPORT LIST";
%>
	  <%=strTemp%></strong><br>
      <%if(WI.fillTextValue("show_SY").length() == 0) {%>
	  	<%=astrConvertToSem[Integer.parseInt(request.getParameter("semester"))]%> ,<%}%>
		AY <%=request.getParameter("sy_from")+"-"+request.getParameter("sy_to")%>        </div></td>
    </tr>
    <tr >
      <td height="20" colspan="2" class="thinborderNONE">Course : 
	    <%=request.getParameter("cn")%>
	    <%if(WI.fillTextValue("mn").length()>0){%>
	  (<%=request.getParameter("mn")%>)
	  <%}%>	  </td>
    </tr>
    <tr >
      <td width="34%" class="thinborderNONE">YEAR :<%=astrConvertToYear[Integer.parseInt(WI.getStrValue(request.getParameter("year_level"), "0"))]%> </td>
      <td width="66%" height="20" align="right" class="thinborderNONE">Date &amp; time printed: <%=WI.getTodaysDateTime()%>&nbsp;</td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr>
      <td height="25" colspan="3" class="thinborderNONE"><strong>
<%
int iShowRequest = Integer.parseInt(WI.getStrValue(WI.fillTextValue("show_"),"0"));
if(iShowRequest == 0 || iShowRequest > vTopStudInfo.size()/4)
	iShowRequest = vTopStudInfo.size()/5;	
strTemp = "TOP : <label id='top_stud_no'>"+Integer.toString(iShowRequest)+"</label> STUDENTS";
%>
<%=strTemp%></strong></td>
      <td width="30%">&nbsp;</td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" id="myADTableContent">
    <tr style="font-weight:bold">
      <td width="2%" align="center" class="thinborder" style="font-size:9px">#</td>
      <td width="17%" height="25" align="center" class="thinborder" style="font-size:9px">STUDENT ID</td>
      <td width="25%" align="center" class="thinborder" style="font-size:9px">STUDENT NAME</td>
<%if(bolIsEAC){%>
      <td width="10%" align="center" class="thinborder" style="font-size:9px">COURSE-YR</td>
<%}if(bolIsCIT){%>
      <td width="10%" align="center" class="thinborder" style="font-size:9px">YEAR</td>
      <%}%>
<%if(bolShowSY){%>
      <td width="5%" align="center" class="thinborder" style="font-size:9px"><u>FS</u><br>UNIT</td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px"><u>FS</u><br>GWA</td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px"><u>SS</u><br>UNIT</td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px"><u>SS</u><br>GWA</td>
<%}%>
      <td width="10%" align="center" class="thinborder" style="font-size:9px">TOTAL  UNITS</td>
<%if(bolIsCIT){%>
      <td width="10%" align="center" class="thinborder" style="font-size:9px">PE UNITS </td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px">NSTP UNITS </td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px">BRACKETED</td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px">ACAD UNITS </td>
<%}%>
      <td width="10%" align="center" class="thinborder" style="font-size:9px">GWA</td>
<%if(bolIsCIT){%>
      <td width="10%" align="center" class="thinborder" style="font-size:9px">MIN GRADE </td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px">SUM OF PRODUCTS </td>
<%}%>
      <%if(bolShowGWAPercent){%>
      <td width="14%" align="center" class="thinborder" style="font-size:9px">GWA (%ge)</td>
<%}%>
    </tr>
<%int iIndexOf = 0;
String strUnitTemp = null;
String strGWATemp  = null;
//Vector vTopStudFS   = null;
//Vector vTopStudSS   = null;
if(vTopStudFS == null)
	vTopStudFS = new Vector();
if(vTopStudSS == null)
	vTopStudSS = new Vector();
	
	
String strCourseYr = null;
String strYear = null;
String strPEUnits  = null;
String strNSTPUnits = null;
String strBracketed = null;
String strAcadUnits = null;
String strMinGrade  = null;
String strSumOfProd = null;	
	
for(int i=0,j=0; i< vTopStudInfo.size(); i+=5, ++j){
		strCourseYr = null;strYear = null;
		strPEUnits  = null;
		strNSTPUnits = null;
		strBracketed = null;
		strAcadUnits = null;
		strMinGrade  = null;
		strSumOfProd = null;	
if(vCITInfo != null) {
	iIndexOf = vCITInfo.indexOf(vTopStudInfo.elementAt(i));//System.out.println(vTopStudInfo.elementAt(i));
	if(iIndexOf > -1) {
		vOthInfo = (Vector)vCITInfo.elementAt(iIndexOf + 1);//System.out.println(vOthInfo);

		strCourseYr = (String)vOthInfo.elementAt(0);
		strYear = (String)vOthInfo.elementAt(1);
		
		if(strYear != null)
			strCourseYr = strCourseYr + " - "+strYear;
		
	}
}

%>
    <tr>
      <td class="thinborder"><%=j + 1%>.</td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vTopStudInfo.elementAt(i)%>
	  <input type="hidden" name="stud_id<%=j%>" value="<%=(String)vTopStudInfo.elementAt(i)%>"></td>
      <td class="thinborder">&nbsp;<%=(String)vTopStudInfo.elementAt(i+1)%></td>
<%if(bolIsEAC){%>
      <td class="thinborder"><%=WI.getStrValue(strCourseYr,"&nbsp;")%></td>
<%}if(bolIsCIT){%>
      <td class="thinborder"><%=WI.getStrValue(strYear,"&nbsp;")%></td>
      <%}%>
      <%if(bolShowSY){//show only if show_sy is checked.. 
strTemp = (String)vTopStudInfo.elementAt(i);
iIndexOf = vTopStudFS.indexOf(strTemp);
if(iIndexOf == -1) {
	strUnitTemp = null;strGWATemp = null;
}
else {
	strUnitTemp = (String)vTopStudFS.elementAt(iIndexOf + 2);strGWATemp = (String)vTopStudFS.elementAt(iIndexOf + 3);
	vTopStudFS.removeElementAt(iIndexOf);vTopStudFS.removeElementAt(iIndexOf);vTopStudFS.removeElementAt(iIndexOf);
	vTopStudFS.removeElementAt(iIndexOf);vTopStudFS.removeElementAt(iIndexOf);
}%>
      <td class="thinborder"><%=WI.getStrValue(strUnitTemp,"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strGWATemp,"&nbsp;")%></td>
<%
iIndexOf = vTopStudSS.indexOf(strTemp);
if(iIndexOf == -1) {
	strUnitTemp = null;strGWATemp = null;
}
else {
	strUnitTemp = (String)vTopStudSS.elementAt(iIndexOf + 2);strGWATemp = (String)vTopStudSS.elementAt(iIndexOf + 3);
	vTopStudSS.removeElementAt(iIndexOf);vTopStudSS.removeElementAt(iIndexOf);vTopStudSS.removeElementAt(iIndexOf);
	vTopStudSS.removeElementAt(iIndexOf);vTopStudSS.removeElementAt(iIndexOf);
}%>
      <td class="thinborder"><%=WI.getStrValue(strUnitTemp,"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strGWATemp,"&nbsp;")%></td>
<%}%>
      <td align="center" class="thinborder"><%=(String)vTopStudInfo.elementAt(i+2)%></td>
<%if(bolIsCIT){%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strPEUnits,"&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(strNSTPUnits,"&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(strBracketed,"&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(strAcadUnits,"&nbsp;")%></td>
<%}%>
      <td align="center" class="thinborder"><%=(String)vTopStudInfo.elementAt(i+3)%></td>
<%if(bolIsCIT){%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strMinGrade,"&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(strSumOfProd,"&nbsp;")%></td>
<%}%>
      <%if(bolShowGWAPercent){%>
      <td align="center" class="thinborder"><%=(String)vTopStudInfo.elementAt(i+4)%></td>
<%}%>
    </tr>
<%} //end for loop%>
<input type="hidden" name="max_disp" value="<%=vTopStudInfo.size()/5%>">
  </table>
<%
//show only if CGH
if(bolIsCGH){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="70%" style="font-size:11px;">Certified By: <br>
        <br><br>
	  <%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%>
	  <br>Registrar</td>
      <td width="30%" height="25" style="font-size:11px;">Noted by :<br>
        <br>
        <br>
	  IRIS CHUA-SO, RN, MAN<br>
	  Dean</td>
    </tr>
</table>

<%}//show signatory if cgh.
	}//vTopStudInfo is not null
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="showTopStud">
  <input type="hidden" name="cn" value="<%=WI.fillTextValue("cn")%>">
  <input type="hidden" name="mn" value="<%=WI.fillTextValue("mn")%>">
  <input type="hidden" name="give_tc">
  <%if(bolIsCIT) {%>
  	<input type="hidden" name="no_of_gwadigits" value="3">
  <%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
