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
var imgWnd;
function PrintPg() {
	if(!CheckEmptyGrade())
		return;
		
	document.gsheet.print_page.value = "1";
	document.gsheet.submit();
}

function CheckEmptyGrade(){
	if(document.gsheet.is_empty_grade && document.gsheet.is_empty_grade.value.length > 0){
		alert("1 or more student has no grade.");
		return false
	}
	return true;
}

function PrintFinalGS(strPrintStat) {
	if(!CheckEmptyGrade())
		return;
	document.gsheet.print_page.value = "1";
	if(strPrintStat == '0')
		document.gsheet.donot_print.value = '1';
		
	document.gsheet.submit();
}
function LockGradeSheet() {
	document.gsheet.lock_gs.value = "1";

	document.gsheet.submit();
}
function CopyAll()
{
	document.gsheet.print_page.value = "";
	if(document.gsheet.copy_all.checked)
	{
		if(document.gsheet.date0.value.length == 0 || document.gsheet.time0.value.length ==0) {
			alert("Please enter first Date and time field input.");
			document.gsheet.copy_all.checked = false;
			return;
		}
		ReloadPage();
	}
}
function PageAction(strAction)
{
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value=strAction;
		
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

function ShowProcessing()
{
	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	document.gsheet.submit();
	imgWnd.focus();
}
function CloseProcessing() {
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}

//ajax here.. 
function AjaxUpdateRemark(objRemark, strGSIndex, strLabelInfo) {
	
	var objCOAInput = document.getElementById(strLabelInfo);
			
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=207&gs_="+strGSIndex+"&r_="+
			objRemark[objRemark.selectedIndex].value;

		this.processRequest(strURL);
}
</script>


<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<form name="gsheet" action="./grade_sheet_final_report.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsUB = strSchCode.startsWith("UB");
String strEmptyGrade = "";


boolean bolIsWNU = strSchCode.startsWith("WNU");

	WebInterface WI   = new WebInterface(request);
	if(WI.fillTextValue("print_page").compareTo("1") ==0){//i have to forward this page to print page
		if(strSchCode.startsWith("UDMC")){%>
			<jsp:forward page="./grade_sheet_final_report_print_udmc.jsp" />
		<%}else if(strSchCode.startsWith("CPU")){%>
			<jsp:forward page="./grade_sheet_final_report_print_cpu.jsp" />
		<%}else if(bolIsWNU){%>
			<jsp:forward page="./grade_sheet_final_report_print_wnu.jsp" />
		<%}else if(strSchCode.startsWith("WUP")){%>
			<jsp:forward page="./grade_sheet_final_report_print_wup.jsp" />
		<%}else if(strSchCode.startsWith("SPC")){%>
			<jsp:forward page="./grade_sheet_final_report_print_spc.jsp" />
		<%}else{%>
			<jsp:forward page="./grade_sheet_final_report_print.jsp" />
		<%}
	return;}
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vSecDetail = null;
	int j = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Releasing","grade_sheet_final_report.jsp");
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
									"FACULTY/ACAD. ADMIN","CLASS MANAGEMENT",request.getRemoteAddr(),
									null);
}
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

String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strEmployeeIndex = (String)request.getSession(false).getAttribute("userIndex");
String strSubSecIndex   = null;

if(WI.fillTextValue("encoding_stat").equals("1")){
	strEmployeeID = WI.fillTextValue("emp_id");
	if(strEmployeeID.length() > 0)
		strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
}

Vector vRetResult = null;
Vector vEncodedGrade = new Vector();

//get here necessary information.
if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
						"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
						" and faculty_load.is_valid = 1 and e_sub_section.is_valid =1 and e_sub_section.offering_sy_from = "+
						WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
						" and e_sub_section.offering_sem="+
						WI.fillTextValue("offering_sem")+" and is_lec=0");
						
}
if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}


boolean bolAllowLock = false;
String strSQLQuery   = null;
String strAllowLocErrMsg = null;

if(strSubSecIndex != null) {//System.out.println(strSubSecIndex);
	//for wnu, do the conversion here.. 
	if(bolIsWNU)
		gsExtn.convertToFinalGradeWNU(dbOP, strSubSecIndex, request);

	//if Locking is called, lock grade sheet. 
	if(WI.fillTextValue("lock_gs").length()> 0) {
		strSQLQuery = "update faculty_load set is_verified = 1, verify_date = '"+WI.getTodaysDate()+
			"', verified_by = "+strEmployeeIndex+" where is_valid = 1 and "+
			" sub_sec_index = "+strSubSecIndex;
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}
	vRetResult = gsExtn.getAllGradesEncoded(dbOP,request,strSubSecIndex);//System.out.println(strSchCode);
	System.out.println(vRetResult);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else if(strSchCode.startsWith("UPH")) {
		//check if already locked.
		strSQLQuery = "select load_index from faculty_load where sub_sec_index = "+strSubSecIndex+" and is_valid = 1 and is_verified = 1";
		if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null)
			strAllowLocErrMsg = " Already Locked";
		else {
			//check if lock is allowed.. 
			strSQLQuery = "select count(*) from enrl_final_Cur_list where sub_sec_index = "+strSubSecIndex+" and sy_from = "+WI.fillTextValue("sy_from")+
						" and is_valid = 1 and current_semester = "+WI.fillTextValue("offering_sem")+" and is_temp_stud = 0 and exists (select cur_hist_index from "+
						"stud_curriculum_hist where sy_from = enrl_final_cur_list.sy_from and semester = current_semester and is_valid = 1 and "+
						"user_index = enrl_final_cur_list.user_index)"; //System.out.println(strSQLQuery);
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null) {
				int iEnrolled = Integer.parseInt(strSQLQuery);
				strSQLQuery = "select count(*) from g_sheet_final where sub_sec_index = "+strSubSecIndex+" and is_valid = 1";//System.out.println(strSQLQuery);
				strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
				if(strSQLQuery != null) {	
					int iGradeEncoded = Integer.parseInt(strSQLQuery);
					if(iEnrolled <= iGradeEncoded)
						bolAllowLock = true;
					else	
						strAllowLocErrMsg = "Locking Disabled. Lacking Grade Encoding.";
				}
			}
		}
	
	}
}

Vector vPMTSchedule = null;
int iNumGrading = 0;
if(vRetResult != null && vRetResult.size() > 1) {
	vPMTSchedule = (Vector)vRetResult.elementAt(0);
	iNumGrading = vPMTSchedule.size() / 2;
}

int iIndexOf = 0;
String strEmptyGradeErrMsg = null;
//I have to find it for SPC.. 
if(strSchCode.startsWith("SPC") && iNumGrading > 0 && strSubSecIndex != null) {
	int iTotalStud = (vRetResult.size() -1 )/(9 + iNumGrading);
	
	strSQLQuery = "select pmt_sch_index, count(distinct user_index_) from grade_sheet where is_valid =1 and sub_sec_index= "+strSubSecIndex+" group by pmt_sch_index";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		if(rs.getInt(2) < iTotalStud) {
			iIndexOf = vPMTSchedule.indexOf(rs.getString(1));
			if(iIndexOf > -1) {
			 	strTemp = (String)vPMTSchedule.elementAt(iIndexOf + 1);
				if(strEmptyGradeErrMsg == null) 
					strEmptyGradeErrMsg = "Lacking grade in following.";
				strEmptyGradeErrMsg += "<br> Total "+Integer.toString(iTotalStud - rs.getInt(2))+" No(s) of student in "+strTemp.toUpperCase();
			}
		}
	}
	rs.close();
	strSQLQuery = "select count(distinct user_index_) from g_sheet_final where is_valid =1 and sub_sec_index= "+strSubSecIndex; System.out.println(strSQLQuery);
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		if(rs.getInt(1) < iTotalStud) {
			if(strEmptyGradeErrMsg == null) 
				strEmptyGradeErrMsg = "Lacking grade in following.";
			strEmptyGradeErrMsg += "<br> Total "+Integer.toString(iTotalStud - rs.getInt(1))+" No(s) of student in FINALS";
		}
	}
	rs.close();
	
}
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
    <input type="hidden" name="show_delete">
    <input type="hidden" name="show_save">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          GRADE SHEETS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="1%" height="25" rowspan="4" >&nbsp;</td>
      <td width="22%" valign="bottom" >Term</td>
      <td width="27%" valign="bottom" >School Year</td>
      <td colspan="2" >&nbsp; </td>
      <td width="35%" >&nbsp;</td>
    </tr>
    <tr> 
      <td valign="bottom" > <select name="offering_sem" onChange="ReloadPage();">
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
      <td valign="bottom" > <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("gsheet","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td colspan="2" > <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a> 
      </td>
      <td width="35%" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <%if(strSchCode.startsWith("UL")){%>
	  	<input type="checkbox" name="show_partial" value="checked" <%=WI.fillTextValue("show_partial")%>> Remove Student without grade
	  <%}%>
	  </td>
    </tr>
  </table>
<%
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() >0){
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
			WI.fillTextValue("sy_from")+" and e_sub_section.OFFERING_SY_TO="+WI.fillTextValue("sy_to")+
			" and e_sub_section.OFFERING_SEM = "+WI.fillTextValue("offering_sem")+" and faculty_load.user_index = "+
			strEmployeeIndex;
%>
        <select name="section_name" onChange="ReloadPage();">
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
%>
        <select name="subject" onChange="ReloadPage();">
          <option value="">Select a subject</option>
          <%=dbOP.loadCombo("distinct subject.sub_index","sub_code",strTemp, request.getParameter("subject"), false)%> 
          <%}%>
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
<%if(vSecDetail != null){%>
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
	<td colspan="5">&nbsp; </td>
	</tr>
<%if(strEmptyGradeErrMsg == null) {%>
	<tr>
	  <td>&nbsp;</td>
      <td>
<%if(strAllowLocErrMsg != null){%>
	  	<font style="font-size:18px; color:red; font-weight:bold"><%=strAllowLocErrMsg%></font>
<%}else if(bolAllowLock){%>
	  	<input type="button" name="_" value="<<< Lock/Finalize Grade Sheet >>>" onClick="LockGradeSheet();"style="font-size:11px; height:30px; width:180px; border: 1px solid #FF0000;">
<%}else{%>
	  	<input type="button" name="_" value="<<< View Final Grade Sheet >>>" onClick="PrintFinalGS('0');"style="font-size:11px; height:30px; width:180px; border: 1px solid #FF0000;">
<%}%>	  </td>
      <td>&nbsp;</td>
      <td><input type="button" name="_2" value="<<< Print Final Grade Sheet >>>" onClick="PrintFinalGS('1');"style="font-size:11px; height:30px; width:180px; border: 1px solid #FF0000;"></td>
      <td>&nbsp;</td>
	</tr>
<%}else{%>
	<tr>
	  <td colspan="5" style="font-size:18px; color:#FF0000"><%=strEmptyGradeErrMsg%></td>
    </tr>   
<%}%>
</table>
<%  int iCountRow = 0;
	if (vRetResult != null && vRetResult.size() > 0){ 
	int i = 0;
if(!strSchCode.startsWith("WUP") && !strSchCode.startsWith("UPH")){%>
  <table width="100%" border="1" cellspacing="0" cellpadding="1" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%" height="25"><font color="#000099" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>ID. 
        Number</strong></font></td>
      <td width="25%"><div align="center"><font color="#000099" size="1"><strong>Name Of Student </strong></font></div></td>
      <td width="25%"><div align="center"><font color="#000099" size="1"><strong>Course</strong></font></div></td>
      <% 
	int k =  0;
	for (i = 0; i < iNumGrading; ++i){ 
		strTemp = (String)vPMTSchedule.elementAt((i*2)+1);
		if(bolIsUB){
			if(strTemp.toLowerCase().startsWith("p")) 				
				continue;
			
		}		
	%>
      <td><div align="center"><font color="#000099" size="1"><strong><%=WI.getStrValue(strTemp, String.valueOf(i+1))%></strong></font></div></td>
      <%} // end for loop%>
      <td width="15%"><div align="center"><font color="#000099" size="1"><strong>Remarks</strong></font></div></td>
 <%if(false){%>
      <td width="15%"><div align="center"><font color="#000099" size="1"><strong>Update Remarks</strong></font></div></td>
 <%}%>
    </tr>
    <%	String strFontColor = null; 
		int iRowSize = 8;
		if (strSchCode.startsWith("UC") || strSchCode.startsWith("SPC"))
			iRowSize = 9;
		
	for( i = 1; i<vRetResult.size(); i+=iRowSize+(iNumGrading)){
	//System.out.println(i);
	if( WI.getStrValue((String)vRetResult.elementAt(i+7)).toLowerCase().startsWith("f"))
		strFontColor = " color=red";
	else	
		strFontColor = "";
	%>
    <tr> 
      <td height="25"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+3)+WI.getStrValue((String)vRetResult.elementAt(i+4),"/","","&nbsp")%></font></td>
      <% for (k = 0; k < iNumGrading; ++k) {
	  
	  	if(bolIsUB){				
			strTemp = (String)vPMTSchedule.elementAt((k*2)+1);
			if(strTemp.toLowerCase().startsWith("p")) 					
				continue;
		
			if(strTemp.toLowerCase().startsWith("final")){
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+iRowSize+k));			
				if( (strTemp.length() == 0 || strTemp.startsWith("&nbsp")))				
					strEmptyGrade = "1";
			}
			
		}
	  %>
      <td align="center"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+iRowSize+k)%></font></td>
      <%}
	  
	strTemp = (String)vRetResult.elementAt(i+7);
	
	if (strSchCode.startsWith("AUF") && 
			strTemp.toLowerCase().startsWith("fail")){
		strTemp = "Failed";
	}	  
	  %>
      <td><font size="1"<%=strFontColor%>><%=strTemp%></font></td>
 <%if(false){%>
      <td>
	  <%
	  strTemp = (String)vRetResult.elementAt(i+7);
	  strSQLQuery = "select remark_index from remark_status where remark = '"+strTemp+"' and is_del = 0";
	  strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	  %> 
	  <label id="<%=iCountRow%>" style="font-size:9px; font-weight:bold; color:#993300">
	  <select name="remark<%=iCountRow%>" style="font-size:10px" tabindex="-1" onChange="AjaxUpdateRemark(document.gsheet.remark<%=iCountRow%>,'<%=vRetResult.elementAt(i)%>', '<%=iCountRow++%>')">
          <%=dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0 and is_internal = 1 order by remark",strSQLQuery , false,false)%>
      </select>
	  </label>	  </td>
<%}%>
    </tr>
    <%}%>
  </table>
<%if(strEmptyGradeErrMsg == null) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="1" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="<%=4+iNumGrading%>">
	  Number of Students Per Page : 
	  <select name="num_stud_page">
<% 
int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"50"));
if(bolIsUB)
	iDefault = 50;
	
	for( i = 16; i <=50 ; i++) {
		if ( i == iDefault) {%>
	  <option selected value="<%=i%>"><%=i%></option>
	<%}else{%>
	  <option value="<%=i%>"><%=i%></option>
	<%}}%>
	 </select>&nbsp;&nbsp;&nbsp;
	  <a href="javascript:PrintPg()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print report</font> <br>
<%
	if (bolIsWNU || strSchCode.startsWith("UI") || strSchCode.startsWith("LNU") || strSchCode.startsWith("CPU") )
		strTemp = "checked";
	else
		strTemp ="";
%>

		  <input type="checkbox" name="separate_grades" value="1" <%=strTemp%>><font size="1"> check to separate student with different subject code</font> </td>

    </tr>
  </table>
<%}//do not allow print.. if peding subject.. %>

<%}%>

<%} //end vRetResult size  == 0
} // vSecDetail != null
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="83%"><p>&nbsp;</p>
            </td>
          </tr>
        </table></td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="donot_print">
<input type="hidden" name="lock_gs">
<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="emp_id" value="<%=strEmployeeID%>">

<input type="hidden" name="is_empty_grade" value="<%=strEmptyGrade%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
