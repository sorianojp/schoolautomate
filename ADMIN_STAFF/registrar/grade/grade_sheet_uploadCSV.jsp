<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function Teaser()
{
	var pgLoc = "./grade_sheet_previewCSV.jsp?CSV="+document.gsheet.csv_area.value;
	var win=window.open(pgLoc,"myfile",'dependent=yes,width=600,height=600,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction)
{
	document.gsheet.page_action.value=strAction;
	document.gsheet.auto_format.value = '';
	//this.SubmitOnce('gsheet');
}
function ReloadPage()
{
	document.gsheet.auto_format.value = '';
	document.gsheet.page_action.value="";
	this.SubmitOnce('gsheet');
}
function ResetPage()
{
	document.gsheet.page_action.value="";
	document.gsheet.subject.selectedIndex = 0;
	document.gsheet.auto_format.value = '';
	this.SubmitOnce('gsheet');
}
function AutoFormat() {
	if(!document.gsheet.add_zero.checked && !document.gsheet.add_comma.checked) {
		alert("Please select autoformat condition.");
		return;
	}
	document.gsheet.auto_format.value = '1';
	this.SubmitOnce('gsheet');
}

</script>



<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vSecDetail = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet_uploadCSV.jsp");
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

String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
String strSubSecIndex   = null;

Vector vRetResult = null;

String strFormattedGrade = "";

if(WI.fillTextValue("auto_format").length() > 0) {
	boolean bolAddZero  = WI.fillTextValue("add_zero").length() > 0;
	boolean bolAddComma = WI.fillTextValue("add_comma").length() > 0;
	
	String strGradeInput = WI.fillTextValue("csv_area");
	strFormattedGrade = ConversionTable.replaceString(strGradeInput, "\r\n",",");
	if(strGradeInput.length() > 0 && false) {
		int iIndexOf = 0;
		String strID = null;String strGrade = null; String strRemark = null;
		while(strGradeInput.length() > 0) {
			iIndexOf = strGradeInput.indexOf(",");
			strID = strGradeInput.substring(0, iIndexOf);
			strGradeInput = strGradeInput.substring(iIndexOf + 1);
			
			iIndexOf = strGradeInput.indexOf(",");
			strGrade = strGradeInput.substring(0, iIndexOf);
			strGradeInput = strGradeInput.substring(iIndexOf + 1);
		
			iIndexOf = strGradeInput.indexOf("\r\n");
			if(iIndexOf > -1) {
				strRemark = strGradeInput.substring(0, iIndexOf);
				if(strRemark.endsWith(","))
					strRemark = strRemark.substring(0,strRemark.length() - 1);
				strGradeInput = strGradeInput.substring(iIndexOf + 2);
			}
			else {
				strRemark = strGradeInput;
				strGradeInput = "";
			}
			if(strID.startsWith("'"))
				strID = strID.substring(1);
			if(bolAddZero && !strID.startsWith("0"))
				strID = "0" + strID;
				
			strFormattedGrade+= strID+","+strGrade+","+strRemark;
			if(strGradeInput.length() > 0) 
				strFormattedGrade += ",\r\n";
		}
		///System.out.println(vGradeInput);		
	}
	
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("1") == 0) //save grade sheet.
{
	vRetResult = gsExtn.uploadCSVtoGradeSheet(dbOP, request);
	if (vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else
		strErrMsg = (String)vRetResult.elementAt(0);
}
//get here necessary information.
if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
						"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
						" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
						WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
						" and e_sub_section.offering_sem="+
						WI.fillTextValue("offering_sem")+" and is_lec=0");
						
}
if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null && strErrMsg == null)
		strErrMsg = reportEnrl.getErrMsg();
}

//Get here the pending grade to be encoded list and list of grades encoded.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCGH = strSchCode.startsWith("CGH");
%>
<body bgcolor="#D2AE72">
<form name="gsheet" action="./grade_sheet_uploadCSV.jsp" method="post" onSubmit="SubmitOnceButton(this);">
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
	  <%=WI.getStrValue(strErrMsg,"MESSAGE: <br>","","")%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp; <strong><font color="blue">NOTE: 
        Subject/Sections appear are the sections handled by the logged in faculty 
        Employee ID: <%=strEmployeeID%></font></strong></td>
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
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and (is_valid=1 or is_valid = 0) order by EXAM_PERIOD_ORDER asc", request.getParameter("grade_for"), false)%>
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
	  readonly="yes"> 
      </td>
      <td colspan="2" >
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a> 
      </td>
      <td width="8%" >&nbsp;</td>
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
        <%strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  where "+
			"faculty_load.is_valid = 1 and e_sub_section.is_valid = 1 and e_sub_section.OFFERING_SY_FROM ="+
			WI.fillTextValue("sy_from")+" and e_sub_section.OFFERING_SY_TO="+WI.fillTextValue("sy_to")+
			" and e_sub_section.OFFERING_SEM = "+WI.fillTextValue("offering_sem")+" and faculty_load.user_index = "+
			strEmployeeIndex;%>
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
%>
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
	<td>&nbsp;</td>
	  <td align="center">&nbsp;</td>
	  <td align="center">&nbsp;</td>
	  <td align="center">&nbsp;</td>
	<td>&nbsp;</td>
	</tr>   
	<tr>
		<td>&nbsp;</td>
		<td align="left" colspan="2"><font style="font-size:11px">Date of Exam: &nbsp;
		<%strTemp = WI.fillTextValue("date_of_exam");%>
        <input name="date_of_exam" type="text" size="12" class="textbox"
	    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" maxlength="12"></font></td>
   		<td align="left" colspan="2"><font style="font-size:11px">Time: 
   		<%strTemp = WI.fillTextValue("time_of_exam");%>
        <input name="time_of_exam" type="text" size="24" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" maxlength="24">
	  </font></td>
	</tr>
</table>		
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td width="5%">&nbsp;</td>
		<td width="90%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="3">&nbsp;<font size="1"><strong>CSV VALUES: 
<%if(bolIsCGH){%><font color="#990000">Important Note : System will convert %ge grade to Final Point and save both grades. But if final point is entered instead of %ge grade, system will save only Final Point and %ge grade will be ignored. <%}%></font></strong></font></td>
	</tr>
	<tr>
		
      <td colspan="3">&nbsp;<font size="1"><strong>CSV values must be in format: 
        <font color="#0000FF">id number, grade, remark </font></strong></font></td>
	</tr>
	<tr>
	  <td colspan="3">&nbsp;Example : 06-0001-456,90,Passed,06-00100,70,Failed </td>
    </tr>
	<tr>
	  <td colspan="3" height="35" style="font-size:11px; color:#0000FF; font-weight:bold">
	  <input type="checkbox" name="add_zero" value="checked" <%=WI.fillTextValue("add_zero")%>> Add 0 to the ID
	  <input type="checkbox" name="add_comma" value="checked" <%=WI.fillTextValue("add_comma")%>> Add comma at end of each line (end of each set)
	  &nbsp;&nbsp;&nbsp;
	  <a href="javascript:AutoFormat();"><font color="#FF0000">Click here to auto format</font></a>	  </td>
    </tr>
	<tr>
		<td>&nbsp;</td>
		<td>
		<%
		if (vRetResult!= null && vRetResult.size()>0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(1),"");
		else
			strTemp = WI.fillTextValue("csv_area");
		//if(vFormattedGrade != null && vFormattedGrade.size() > 0) 
			//strTemp = CommonUtil.convertVectorToCSV(vFormattedGrade);
		if(strFormattedGrade != null && strFormattedGrade.length() > 0) 
			strTemp = strFormattedGrade;%>
		<textarea rows="35" cols="75" name="csv_area" class="textbox"><%=strTemp%></textarea></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td colspan="3" align="center">
		<input type="submit" name="1" value="<<< Upload Grade >>>" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1');">
		<!--
		<a href="javascript:PageAction(1);">
		<img name="hide_save" src="../../../images/save.gif" border="0"></a>--> &nbsp;
		&nbsp;<a href="javascript:Teaser();"><img src="../../../images/view.gif" border="0"></a><font size="1">click to preview CSV entries</font>		</td>
	</tr>
</table>
<%}//if section is selected.
 }//only if SY from infromation is filled in%> 
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">

<input type="hidden" name="auto_format">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
