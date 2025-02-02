<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

if(WI.fillTextValue("batch_print").equals("1")){%>
	<jsp:forward page="print_cp_plotted_batch.jsp" />	
<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Class Program</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//strPrintStat = 0 = view only.
function ReloadPage()
{
	document.ssection.form_proceed.value="";
	document.ssection.batch_print.value = '';
	document.ssection.submit();
}
function FormProceed()
{
	document.ssection.batch_print.value = '';
	document.ssection.form_proceed.value="1";
}

///ajax here to load major..
function loadMajor() {
		var objCOA=document.getElementById("load_major");
		
		var objCourseInput = document.ssection.course_index[document.ssection.course_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=104&all=1&course_ref="+objCourseInput;
		this.processRequest(strURL);
}
function SelOne(objChkBox) {
	if(objChkBox.checked)
		objChkBox.checked = false;
	else	
		objChkBox.checked = true;
}
function PrintOne(strSection) {
	var printLoc = "./print_cp_plotted_one.jsp?course_index="+document.ssection.course_index[document.ssection.course_index.selectedIndex].value+
					"&major_index="+document.ssection.major_index[document.ssection.major_index.selectedIndex].value+"&year_level="+
					document.ssection.year_level[document.ssection.year_level.selectedIndex].value+"&school_year_fr="+
					document.ssection.school_year_fr.value+"&school_year_to="+
					document.ssection.school_year_to.value+"&offering_sem="+
					document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value+"&section="+
					escape(strSection)+"&cy_f="+
					document.ssection.cy_f[document.ssection.cy_f.selectedIndex].value;
	
	if(document.ssection.inc_mixed.checked)
		printLoc += "&inc_mixed=1";

	var win=window.open(printLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ViewOne(strSection, strIsMWF) {
	var printLoc = "./ViewCPOffering.jsp?course_index="+document.ssection.course_index[document.ssection.course_index.selectedIndex].value+
					"&major_index="+document.ssection.major_index[document.ssection.major_index.selectedIndex].value+"&year_level="+
					document.ssection.year_level[document.ssection.year_level.selectedIndex].value+"&school_year_fr="+
					document.ssection.school_year_fr.value+"&school_year_to="+
					document.ssection.school_year_to.value+"&offering_sem="+
					document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value+"&section="+
					escape(strSection)+"&cy_f="+
					document.ssection.cy_f[document.ssection.cy_f.selectedIndex].value+"&show_list_only=1";
	
	if(document.ssection.inc_mixed.checked)
		printLoc += "&inc_mixed=1";
	if(strIsMWF == '1')
		printLoc += "&show_mwf=1";

	var win2=window.open(printLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win2.focus();
}
function SelALL(strChecked) {
	var selStat = false;
	var selALL  = false;
	if(strChecked == '1') {
		if(document.ssection.sel_all1.checked) {
			document.ssection.sel_all0.checked = false;
			selStat = true;
			selALL  = true;
		}
	}
	else {
		if(document.ssection.sel_all0.checked) {
			document.ssection.sel_all1.checked = false;
			selStat = true;
		}
	}
	
	var iMaxDisp = document.ssection.max_disp.value;
	if(iMaxDisp < 1) 
		return;
	
	var objChkBox;
	if(!selStat) {//uncheck all
		for(i = 0; i < iMaxDisp; ++i) {
			eval('objChkBox = document.ssection._'+i);
			if(!objChkBox)
				continue;
			objChkBox.checked = false;
		}
	}
	else {//selec is called.
		if(selALL) {
			for(i = 0; i < iMaxDisp; ++i) {
				eval('objChkBox = document.ssection._'+i);
				if(!objChkBox)
					continue;
				objChkBox.checked = true;
			}
		}
		else {//select block only. 
			for(i = 0; i < iMaxDisp; ++i) {
				eval('objChkBox = document.ssection._'+i);
				if(!objChkBox)
					continue;
				
				if(objChkBox.value.indexOf("/") == -1)
					objChkBox.checked = true;
				else	
					objChkBox.checked = false;
			}
		}
	}
}
function PrintPg() {
	document.ssection.batch_print.value = '1';
	document.ssection.submit();
}
function ViewConflict() {
	var strPgLoc = "../subject_list_with_conflict.jsp?sy_from="+document.ssection.school_year_fr.value+
					"&semester="+document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value;
	var win2=window.open(strPgLoc,"PrintWindow",'width=600,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win2.focus();
}
</script>

<body bgcolor="#FFFFFF" topmargin='0' bottommargin='0'>
<%
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-print class program per college/dept offering","print_per_college_dept_offering.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														null);
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
//end of authenticaion code.

SubjectSection SS = new SubjectSection();
Vector vRetResult = null;

if(WI.fillTextValue("form_proceed").compareTo("1") ==0) {
	vRetResult = SS.getSectionOffered(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SS.getErrMsg();
}

String strCourseProgram = WI.getStrValue(WI.fillTextValue("course_program"), "0");

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form name="ssection" action="./print_cp_plotted_main.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr>
      <td height="25" colspan="4" align="center"><strong>:::: PRINT PLOTTED CLASS PROGRAM ::::</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"> <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" >School year/Term : 
        <%
strTemp = WI.fillTextValue("school_year_fr");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="school_year_fr" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ssection","school_year_fr","school_year_to")'> 
<%
strTemp = WI.fillTextValue("school_year_to");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        - 
        <input name="school_year_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
        - 
        <select name="offering_sem">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
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
        </select></td>
      <td width="29%" >
	  <%if(strSchCode.startsWith("CIT")){%>
	  	<a href="javascript:ViewConflict();">View Conflict in Class Program</a> 
	  <%}%>
	  </td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
<%
if(strCourseProgram.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="course_program" value="0" <%=strErrMsg%> onClick="ReloadPage();"> Under Graduage Programs 
<%
if(strCourseProgram.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="course_program" value="1" <%=strErrMsg%> onClick="ReloadPage();"> Masteral Programs 
<%
if(strCourseProgram.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="course_program" value="2" <%=strErrMsg%> onClick="ReloadPage();"> Medicine Program 
	  </td>
    </tr>
-->
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="10%" height="25">Course </td>
      <td colspan="2">
<% 	
/**
if(strCourseProgram.equals("0"))
	strTemp = " and degree_type <> 1 and degree_type <> 2";
else 
	strTemp = " and degree_type = "+strTemp;
**/
strTemp = "";

%> 
<select name="course_index" onChange="loadMajor();">
          <option value="">Select a Course</option>
      <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND is_valid = 1 "+strTemp+" order by course_name asc",	WI.fillTextValue("course_index"), false)%> </select>	  </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td>Major </td>
      <td colspan="2">
<label id="load_major">
		<select name="major_index">
          <option value="">ALL</option>
<%if(WI.fillTextValue("course_index").length() > 0) {%>
          	<%=dbOP.loadCombo("major_index","major_name"," from	 major where IS_DEL=0 and course_index = " + WI.fillTextValue("course_index") + " order by major_name asc",	WI.fillTextValue("major_index"), false)%> 
<%}%>
		</select> 		  
</label></td>
    </tr>
<%if(true){//!strCourseProgram.equals("1")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Year</td>
      <td colspan="2">
	  <select name="year_level">
	  <option value=""></option>
<%
int iDef = Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"), "0"));
for (int i =1 ; i < 7; ++i){
if(i == iDef)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
<%}%>
	</select>		</td>
    </tr>
<%}
Vector vCurYr = SS.getSchYear(dbOP, request);
%>    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Curr. Year </td>
      <td colspan="2" style="font-weight:bold; color:#0000FF; font-size:11px;">
	  <select name="cy_f">
	  <option value="">ALL</option>
<%
strTemp = WI.fillTextValue("cy_f");
for(int i = 0; i < vCurYr.size(); i += 2) {
if(strTemp.equals(vCurYr.elementAt(i)))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="<%=vCurYr.elementAt(i)%>"<%=strErrMsg%>><%=vCurYr.elementAt(i) + " - "+vCurYr.elementAt(i + 1)%></option>
<%}%>	  
	  </select>
<%
if(request.getParameter("form_proceed") == null)
	strTemp = " checked";
else	
	strTemp = WI.fillTextValue("inc_mixed");
%>	  
	  <input type="checkbox" name="inc_mixed" value="checked" <%=strTemp%>> Include Mixed Offering	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="3" align="center">
        <input name="image" type="image" onClick="FormProceed();" src="../../../../images/form_proceed.gif">      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3"><div align="center"></div></td>
    </tr>
  </table>
<%

String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"}; 

if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
	<tr>
	  <td align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>Print Selectd Sections.</td>
	</tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
	  <td colspan="2" align="center">SUBJECT OFFERINGS</td>
	</tr>
	<tr>
	  <td colspan="2" align="center"><%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, SY <%=WI.fillTextValue("school_year_fr")%> - <%=WI.fillTextValue("school_year_to")%></td>
	</tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr style="font-weight:bold">
    <td width="5%" class="thinborder">Count</td>
  	<td width="15%" class="thinborder" align="center">Select<br><font size="1"> 
	<font size="1">
	<input type="checkbox" name="sel_all1" onClick="SelALL('1');">
	</font> All
	<input type="checkbox" name="sel_all0" onClick="SelALL('0');"> All Block</font>	</td>
    <td width="10%" class="thinborder" align="center">Print One </td>
    <td width="10%" class="thinborder" align="center">View One (MWF) </td>
    <td width="10%" class="thinborder" align="center">View One </td>
  	<td width="50%" class="thinborder" height="25">Section</td>
  </tr>
<%
int iMaxDisp = 0;
for(int i = 0; i < vRetResult.size(); ++i) {
++iMaxDisp;%>
   <tr>
     <td class="thinborder"><%=i + 1%>. </td>
  	<td class="thinborder" align="center"><input type="checkbox" name="_<%=i%>" value="<%=vRetResult.elementAt(i)%>"></td>
    <td class="thinborder" align="center"><a href='javascript:PrintOne("<%=vRetResult.elementAt(i)%>");'><img src="../../../../images/print.gif" border="0"></a></td>
    <td class="thinborder" align="center"><a href='javascript:ViewOne("<%=vRetResult.elementAt(i)%>","1");'><img src="../../../../images/view.gif" border="0"></a></td>
    <td class="thinborder" align="center"><a href='javascript:ViewOne("<%=vRetResult.elementAt(i)%>","0");'><img src="../../../../images/view.gif" border="0"></a></td>
  	<td class="thinborder" height="25" onClick="SelOne(document.ssection._<%=i%>);"><%=vRetResult.elementAt(i)%></td>
   </tr>
<%}%>
  </table>
<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
<%}%>

<input type="hidden" name="form_proceed">
<input type="hidden" name="batch_print">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
