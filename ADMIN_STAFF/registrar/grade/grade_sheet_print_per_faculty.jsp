<%
	WebInterface WI   = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";

	String strGradeForName = WI.fillTextValue("grade_name_");//strSchCode = "CLDH";

	boolean bolIsCGH = false; //for cldh - i must have finals to record in %ge.
	if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") || (strSchCode.startsWith("CLDH") && strGradeForName.toLowerCase().startsWith("final")) )
		bolIsCGH = true;//bolIsCGH = true;

	String strTemp    = null;
	boolean bolIsCSA = strSchCode.startsWith("CSA");	
	
	//for PIT and final grade, move to grade_sheet_PIT.jsp
	if(strSchCode.startsWith("PIT") && strGradeForName.toLowerCase().startsWith("final")){%>
		<jsp:forward page="./grade_sheet_PIT.jsp"/>	
	<%}
		
	if(WI.fillTextValue("print_page").equals("1")){
	//i have to forward this page to print page
		if (!strSchCode.startsWith("CPU")) {
	%>
		<jsp:forward page="./grade_sheet_print.jsp" />
	<%}else{%>
		<jsp:forward page="./grade_sheet_final_report_print_cpu.jsp"/>
	<% } // end if else

	return;
	}
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
<script language="JavaScript">
var imgWnd;


function PrintPg() {
	document.gsheet.print_page.value = "1";
	this.SubmitOnce('gsheet');
}
function PageAction(strAction)
{
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value=strAction;

	//I have to check here, if cgh, faculty must click convert percentage to QP..
	if(strAction == 1) {
		<%if(bolIsCGH) {%>
			if(!document.gsheet.convert_grade || !document.gsheet.convert_grade.checked) {
				alert("Please click Convert grade to convert percentage to Final point.");
				return;
			}
		<%}//if cgh, user must click convert grade.%>
		//I need to check if there is atleast one check box is selected.
		var iMaxDisp = document.gsheet.disp_count_gs_pending.value;
		var objChkBox; var bolReturn = true;
		for( i = 0; i < iMaxDisp; ++i) {
			eval('objChkBox=document.gsheet.save_'+i);
			if(!objChkBox)
				continue;
			if(objChkBox.checked) {
				bolReturn = false;
				break;
			}				
		}
		if(bolReturn) {
			alert("Please select atleast one checkbox for saving grade.");
			return;
		}
	}
	if(document.gsheet.show_save.value == "1")
		document.gsheet.hide_save.src = "../../../images/blank.gif";
	if(document.gsheet.show_delete.value == "1")
		document.gsheet.hide_delete.src = "../../../images/blank.gif";
	if(strAction ==0)
		document.gsheet.delete_text.value = "deleting in progress....";
	if(strAction ==1)
		document.gsheet.save_text.value = "Saving in progress....";


	this.ShowProcessing();
}
function ReloadPage()
{
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value="";
	if(document.gsheet.show_save.value == "1")
		document.gsheet.hide_save.src = "../../../images/blank.gif";
	if(document.gsheet.show_delete.value == "1")
		document.gsheet.hide_delete.src = "../../../images/blank.gif";
	this.ShowProcessing();
}
function ResetPage()
{
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value="";
	document.gsheet.subject.selectedIndex = 0;
	this.ShowProcessing();
}


function ShowProcessing() {

	if(document.gsheet.grade_for) {
		document.gsheet.grade_name_.value = document.gsheet.grade_for[document.gsheet.grade_for.selectedIndex].text;
	}

	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	this.SubmitOnce('gsheet');
	imgWnd.focus();
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}

</script>


<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<form name="gsheet" action="./grade_sheet_print_per_faculty.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%

	DBOperation dbOP  = null;
	String strErrMsg  = null;
	Vector vSecDetail = null;

	int j = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(),
									null);
}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(),
									null);
}

//I have to check if grade sheet is locked..
if(new enrollment.SetParameter().isGsLocked(dbOP))
	iAccessLevel = 0;

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
enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
enrollment.GradeSystem  GS = new enrollment.GradeSystem();
GradeSystemExtn gsExtn     = new GradeSystemExtn();

String strEmployeeID    = (String)request.getSession(false).getAttribute("userId_fac");
String strEmployeeIndex = (String)request.getSession(false).getAttribute("userIndex_fac");;


String strSubSecIndex   = null;

Vector vRetResult    = null;
Vector vPendingGrade = null;
Vector vEncodedGrade = null;
Vector vCGHGrade     = null;

//get here necessary information.

if (!strSchCode.startsWith("CPU")){
	if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
		strSubSecIndex =
			dbOP.mapOneToOther("E_SUB_SECTION join faculty_load " +
					 " on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
					"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index",
					" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
					" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
					WI.fillTextValue("sy_from")+ " and e_sub_section.offering_sy_to = "+
					WI.fillTextValue("sy_to")+ " and e_sub_section.offering_sem="+
					WI.fillTextValue("offering_sem")+" and is_lec=0");
	}
}else{
	strSubSecIndex = WI.fillTextValue("sub_sec_index");
}

if(strSubSecIndex != null && strSubSecIndex.length() > 0) {//get here subject section detail.
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

//Get here the pending grade to be encoded list and list of grades encoded.
if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
	vRetResult = gsExtn.getStudListForGradeSheetEncoding(dbOP, WI.fillTextValue("grade_for"),
												strSubSecIndex,false);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else {
		vEncodedGrade = (Vector)vRetResult.elementAt(0);
		vPendingGrade = (Vector)vRetResult.elementAt(1);
	}
}

String strGradeName = null;
if(WI.fillTextValue("grade_for").length() > 0) 
	strGradeName = dbOP.mapOneToOther("FA_PMT_SCHEDULE", "PMT_SCH_INDEX", WI.fillTextValue("grade_for"), "EXAM_NAME", null);

%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">

<input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
<input type="hidden" name="show_delete">
<input type="hidden" name="show_save">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="7"><div align="center"><font color="#FFFFFF"><strong>::::
          GRADE SHEETS PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;<strong><font size="3" color="#FF0000">
	  <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
    </tr>
<%
strTemp = null;
if(strEmployeeIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strEmployeeIndex, 9);
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td height="25" colspan="7">
		  <table width="100%" cellpadding="0" cellspacing="0">
			<tr>
			  <td width="2%" height="25">&nbsp;</td>
			  <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
			  <td width="2%">&nbsp;</td>
			</tr>
		  </table>
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp; <strong><font color="blue">NOTE:
        Subject/Sections appear are the sections handled by the logged in faculty
      Employee ID: <%=strEmployeeID%></font></strong>	  </td>
    </tr>
    <tr>
      <td width="1%" height="25" rowspan="4" >&nbsp;</td>
      <td width="25%" height="25" valign="bottom" >Grades for</td>
      <td width="22%" valign="bottom" >Term</td>
      <td width="27%" valign="bottom" >School Year</td>
      <td colspan="2" >&nbsp; </td>
      <td width="8%" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" valign="bottom" >
        <select name="grade_for">
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and (is_valid=1 or is_valid = 0) and BSC_GRADING_NAME is not null order by EXAM_PERIOD_ORDER asc", request.getParameter("grade_for"), false)%>
        </select></td>
      <td valign="bottom" >
	  <select name="offering_sem" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

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
      <td valign="bottom" >
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("gsheet","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes">      </td>
      <td colspan="2" >
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>      </td>
      <td width="8%" >&nbsp;</td>
    </tr>
</table>
<%
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() >0){

	if (!strSchCode.startsWith("CPU")) {
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%"></td>
      <td width="39%" height="25" valign="bottom" >Section Handled</td>
      <td valign="bottom" >Instructor (Name of logged in user)</td>
    </tr>
    <tr>
      <td></td>
      <td height="25" >
        <%
strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  where "+
			"faculty_load.is_valid = 1 and e_sub_section.is_valid = 1 and e_sub_section.OFFERING_SY_FROM ="+
			WI.fillTextValue("sy_from")+" and e_sub_section.OFFERING_SEM = "+WI.fillTextValue("offering_sem")+" and faculty_load.user_index = "+
			strEmployeeIndex;
%>
        <select name="section_name" onChange="ResetPage();">
          <option value="">Select a section</option>
          <%=dbOP.loadCombo("distinct section","section",strTemp, request.getParameter("section_name"), false)%>
        </select> </td>
      <td height="25" > <strong>
        <%if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%>
        <%}%>
        </strong> </td>
    </tr>
    <tr>
      <td width="1%"></td>
      <td height="25">Subject Handled</td>
      <td>Subject Title </td>
    </tr>
    <tr>
      <td width="1%"></td>
      <td height="25" >
        <%
strTemp = " from faculty_load join e_sub_section on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) "+
			"join subject on (e_sub_section.sub_index = subject.sub_index) where faculty_load.user_index = "+
			strEmployeeIndex+" and e_sub_section.section = '"+WI.fillTextValue("section_name")+
			"' and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
			WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
			" and e_sub_section.offering_sem="+WI.fillTextValue("offering_sem");
//System.out.println(strTemp);%>
        <select name="subject" onChange="ReloadPage();">
          <option value="">Select a subject</option>
          <%=dbOP.loadCombo("distinct subject.sub_index","sub_code",strTemp, request.getParameter("subject"), false)%>
        </select></td>
      <td> <strong>
        <%
if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%>
        <%=WI.getStrValue(strTemp)%></strong></td>
      <%}%>
    </tr>
  </table>
<%}else{%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%"></td>
      <td width="39%" height="25" valign="bottom" >Stub Code :: Subject</td>
      <td valign="bottom" >Instructor </td>
    </tr>
    <tr>
      <td></td>
      <td height="25" > <%
strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  " +
			" join subject on (e_sub_section.sub_index = subject.sub_index) where "+
			" faculty_load.is_valid = 1 and e_sub_section.is_valid = 1 and is_main =1 " +
			" and MIX_SEC_REF_INDEX is null  and is_lec = 0 and e_sub_section.OFFERING_SY_FROM ="+
			WI.fillTextValue("sy_from")+" and e_sub_section.OFFERING_SY_TO="+WI.fillTextValue("sy_to")+
			" and e_sub_section.OFFERING_SEM = "+WI.fillTextValue("offering_sem")+
			" and faculty_load.user_index = "+
			strEmployeeIndex + " order by e_sub_section.sub_sec_index";
%> <select name="sub_sec_index" onChange="ReloadPage();">
          <option value="">Select a section</option>
          <%=dbOP.loadCombo("e_sub_section.sub_sec_index",
		  					" e_sub_section.sub_sec_index , sub_code",
							strTemp, request.getParameter("sub_sec_index"), false)%>
        </select> </td>
      <td height="25" > <strong>
        <%if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%>
        <%}%>
        </strong> </td>
    </tr>
  </table>


<%
 }//end of if else CPU's Header
}
if(vSecDetail != null){%>
  <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
    <tr>
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%>
    <tr>
      <td>&nbsp;</td>
      <td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td>&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<% if (strSchCode.startsWith("CPU") || bolIsCGH || strSchCode.startsWith("CLDH") ) {%>
    <tr>
      <td>&nbsp;</td>
      <td colspan="3"><div align="center">&nbsp;&nbsp;&nbsp;&nbsp;Date:
          <input name="date_exam" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_exam")%>" size="10">
          &nbsp;&nbsp;&nbsp;&nbsp;Time :
          <input name="time_exam" type="text" size="8" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			value="<%=WI.fillTextValue("time_exam")%>">
          &nbsp;&nbsp;</div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%}%>
  </table>
<%}
if(vPendingGrade != null && vPendingGrade.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FF0000">
    <tr>
      <td align="center" height="25" style="font-weight:bold" class="thinborderTOPLEFTRIGHT"> List of Students Not having Grades</td> 
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FF0000" class="thinborder">
    <tr style="font-weight:bold" align="center">
      <td width="2%" height="25" style="font-size:9px" class="thinborder">COUNT</td>
      <td width="15%" style="font-size:9px" class="thinborder">STUDENT ID</td>
      <td width="28%" style="font-size:9px" class="thinborder">STUDENT NAME</td>
      <td width="10%" style="font-size:9px" class="thinborder">COURSE</td>
      <td width="10%" style="font-size:9px" class="thinborder">YEAR</td>
    </tr>
<%for(int i=0; i<vPendingGrade.size(); i +=10,++j){%>
    <tr>
      <td><font size="1"><%=j + 1%></font></td>
      <td  height="25" class="thinborder"><font size="1"><%=(String)vPendingGrade.elementAt(i+3)%></font>
      <td class="thinborder"><font size="1" ><%=(String)vPendingGrade.elementAt(i+4)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vPendingGrade.elementAt(i+5)%>
        <% if(vPendingGrade.elementAt(i + 6) != null){%>
        :: <%=(String)vPendingGrade.elementAt(i+6)%>
        <%}%>
		<% if (strSchCode.startsWith("CPU")) {%>
			<%=WI.getStrValue(vPendingGrade.elementAt(i+7))%>
		<%}%>
        </font></td>
      <td align="center" class="thinborder"><font size="1"><%=WI.getStrValue(vPendingGrade.elementAt(i+7),"N/A")%></font></td>
    </tr>
    <%}//end of for loop%>
  </table>
<input type="hidden" name="disp_count_gs_pending" value="<%=j%>">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="6%">&nbsp;</td>
      <td width="94%" colspan="2">&nbsp;</td>
    </tr>
  </table>
<%}//end of disp of pending grade,
 if(vEncodedGrade != null && vEncodedGrade.size() > 0){%>
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5"><div align="center">LIST OF STUDENTS WITH GRADE
          ENCODED</div></td>
    </tr>
  </table>
 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5" align="right">Number of lines per page: 
<%
int iNoOfLines = Integer.parseInt(WI.getStrValue(WI.fillTextValue("first_page"), "0"));
if(iNoOfLines == 0) 
	iNoOfLines = 45;
%>
<select name="first_page">
<%for(int i = 20; i < 60; ++i) {
	if(i == iNoOfLines)	
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>"<%=strTemp%>><%=i%></option>
<%}%>
</select>
&nbsp;
&nbsp;
	  <a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font size="1">Click to print grade sheet</font>
	</td>

    </tr>
  </table>

<% 
boolean bolIsWNU = strSchCode.startsWith("WNU");
//bolIsWNU = strGradeForName.toLowerCase().startsWith("final");

if (!strSchCode.startsWith("CPU")){%>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%"  height="25" ><strong><font size="1">NO.</font></strong></td>
      <td width="11%"  height="25" align="center" ><font size="1"><strong>STUDENT
        ID </strong></font></td>
      <td width="23%" align="center" ><font size="1"><strong>STUDENT NAME
      </strong></font></td>
      <td width="32%" align="center"><font size="1"><strong>COURSE</strong></font></td>
      <td width="4%" align="center"><font size="1"><strong>YEAR</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>CREDIT EARNED</strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>GRADE<%if(bolIsCGH){%><br>Final Point<%}%></strong></font></td>
<%if(bolIsCGH || bolIsWNU){%>
      <td width="7%" align="center"><font size="1"><strong>GRADE %ge</strong></font></td>
<%}%>
      <td width="8%" align="center"><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
<%
	j = 0;
	String strFontColor = null;//gsExtn.vCGHGrade.clear();
for(int i=0; i<vEncodedGrade.size(); i += 9,++j){
if( ((String)vEncodedGrade.elementAt(i+8)).toLowerCase().startsWith("f"))
	strFontColor = " color=red";
else
	strFontColor = "";
%>
    <tr>
      <td><font size="1"<%=strFontColor%>><%=j + 1%></font></td>
      <td  height="25" ><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+1)%></font>
    <input type="hidden" name="gs_index<%=j%>" value="<%=(String)vEncodedGrade.elementAt(i)%>">	  </td>
      <td ><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+2)%></font></td>
      <td ><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+3)%>
        <% if(vEncodedGrade.elementAt(i + 4) != null){%>
        :: <%=(String)vEncodedGrade.elementAt(i+4)%>
        <%}%>
        </font></td>
      <td align="center"><font size="1"<%=strFontColor%>><%=WI.getStrValue(vEncodedGrade.elementAt(i+5),"N/A")%></font></td>
      <td align="center"><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+6)%></font></td>
      <td align="center"><font size="1"<%=strFontColor%>><%=WI.getStrValue(vEncodedGrade.elementAt(i+7),"&nbsp;")%></font></td>
<%if(bolIsCGH || bolIsWNU){//System.out.println(gsExtn.vCGHGrade.elementAt(j * 2 + 1));%>
      <td align="center"><font size="1"<%=strFontColor%>>
	  	<%if(gsExtn.vCGHGrade.size() > (j * 2 + 1) ){%><%=WI.getStrValue(gsExtn.vCGHGrade.elementAt(j * 2 + 1))%><%}%>
	  </font>&nbsp;</td>
<%}

	strTemp = (String)vEncodedGrade.elementAt(i+8);

	if (strSchCode.startsWith("AUF") &&
			strTemp.toLowerCase().startsWith("fail")){
		strTemp = "Failed";
	}

%>
      <td align="center"><font size="1"<%=strFontColor%>><%=strTemp%></font></td>
    </tr>
<%}%>
  </table>

<%}else{ // start of  CPU's Domain %>

  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%"  height="25" ><font size="1" face="Geneva, Arial, Helvetica, sans-serif">NO.</font></td>
      <td width="11%"  height="25" align="center"><font size="1" face="Geneva, Arial, Helvetica, sans-serif">CLASSIFICA-<br>
        TION EX,<br>
      BSE2       </font></td>
      <td width="39%" ><div align="center"><font size="1" face="Geneva, Arial, Helvetica, sans-serif"><strong>NAMES</strong></font></div></td>
      <td width="5%" align="center"><strong><font size="1" face="Geneva, Arial, Helvetica, sans-serif"><strong>GRADE</strong></font></strong></td>
      <td width="6%" align="center"><strong><font size="1" face="Geneva, Arial, Helvetica, sans-serif">CREDIT</font></strong></td>
      <td width="7%" align="center"><font size="1" face="Geneva, Arial, Helvetica, sans-serif">GRADE REMARK</font></td>
      <td width="7%" align="center"><strong><font size="1" face="Geneva, Arial, Helvetica, sans-serif">ATTEN-<br>
DANCE<br>
S-<br>
P-</font></strong></td>
      <td width="15%" align="center"><font size="1" face="Geneva, Arial, Helvetica, sans-serif">FINAL REMARK </font></td>
      <td width="6%" align="center"><font size="1" face="Geneva, Arial, Helvetica, sans-serif"><strong>SELECT ALL</strong></font>
	    <font size="1" face="Geneva, Arial, Helvetica, sans-serif"><br>
	    <input type="checkbox" name="selAll" value="0" onClick="checkAll();">
      </font></td>
    </tr>
<%
	j = 0;
String strFontColor = null;
int intMaxRows = 9; // final..
boolean bolFinal = false;

if (strGradeName.toLowerCase().startsWith("final")){
	intMaxRows = 11;
	bolFinal = true;
}


for(int i=0; i<vEncodedGrade.size(); i += intMaxRows,++j){
if( ((String)vEncodedGrade.elementAt(i+8)).toLowerCase().startsWith("f"))
	strFontColor = " color=red";
else
	strFontColor = "";
%>
    <tr>
      <td><font size="1"<%=strFontColor%>><%=j + 1%></font></td>
      <td  height="25" ><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+3)%>
          <% if(vEncodedGrade.elementAt(i + 4) != null){%>
:: <%=(String)vEncodedGrade.elementAt(i+4)%>
<%}%>
      </font><font size="1"<%=strFontColor%>><%=WI.getStrValue(vEncodedGrade.elementAt(i+5))%></font></td>
      <td ><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+2)%></font></td>
      <td align="center"><strong><font size="1"<%=strFontColor%>><%=WI.getStrValue(vEncodedGrade.elementAt(i+7),"&nbsp;")%></font></strong></td>
      <td align="center"><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+6)%></font></td>
      <td align="center"><font size="1"<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+8)%></font></td>
      <td align="center"><font size="1"<%=strFontColor%>>
	  <%if (bolFinal) {%>
		  <%=WI.getStrValue((String)vEncodedGrade.elementAt(i+9),"&nbsp;")%>
	  <%}else{%> &nbsp;<%}%>
	  </font></td>
      <td align="center"><font size="1"<%=strFontColor%>>
	  <% if (bolFinal) {%>
		  <%=WI.getStrValue((String)vEncodedGrade.elementAt(i+10),"&nbsp;")%>
	  <%}else{%> &nbsp;<%}%>
	  </font></td>
      <td align="center"><input type="hidden" name="gs_index<%=j%>" value="<%=(String)vEncodedGrade.elementAt(i)%>"><input type="checkbox" name="del_<%=j%>" value="1"></td>
    </tr>
<%}%>
  </table>


<%}%>

  <input type="hidden" name="disp_count_gs_encoded" value="<%=j%>">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    
    <tr>
      <td width="40%">&nbsp;</td>
      <td width="60%">&nbsp;</td>
    </tr>
</table>
<%}//end of showing encoded grade
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="emp_id" value="<%=strEmployeeID%>">
<input type="hidden" name="grade_name_">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
