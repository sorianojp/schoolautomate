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
function ReloadPage(){
	document.form_.print_page.value = "";
	document.form_.submit();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function DeleteRecord(){
	var vProceed = confirm("Are you sure you want to remove the attendance information.");
	if(!vProceed)
		return;
	document.form_.page_action.value = "0";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function PrintPage(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}


function Proceed(){
	document.form_.print_page.value='';
	document.form_.page_action.value=''
	document.form_.submit();
}


function SetSummaryOption(){
	document.form_.set_summary_option.value = document.form_.summary_option.value;
	ShowSelectOption();
}

function ShowSelectOption(){

	  var strOption = document.form_.set_summary_option.value;
	  if(strOption == 2){	  	
		document.getElementById('summary_per_month').style.visibility="visible";
		document.getElementById('summary_per_month').style.display="block";
		document.form_.summary_date.value = "";
		document.getElementById('summary_per_date').style.visibility="hidden";
		document.getElementById('summary_per_date').style.display="none";		
	  }		  
	  else if(strOption == 3){	  	
		document.getElementById('summary_per_date').style.visibility="visible";
		document.getElementById('summary_per_date').style.display="block";		
		document.form_.summary_year.value = "";
		document.getElementById('summary_per_month').style.visibility="hidden";
		document.getElementById('summary_per_month').style.display="none";		
	  }	
	  
	  else{
		document.getElementById('summary_per_date').style.visibility="hidden";
		document.getElementById('summary_per_date').style.display="none";
		document.form_.summary_date.value = "";		
		document.form_.summary_year.value = "";
		document.getElementById('summary_per_month').style.visibility="hidden";
		document.getElementById('summary_per_month').style.display="none";		
	  
	  }
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ReportEnrollment,ClassMgmt.CMAttendance " %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;

	Vector vSecDetail = null;
//add security here.

	if (WI.fillTextValue("print_page").compareTo("1") == 0){
%>
	<jsp:forward page="./attendance_summary_report_print.jsp" />
<%	return;} 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"STUDENT AFFAIRS-STUDENT TRACKER","attendance_summary_report.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"STUDENT AFFAIRS","STUDENT TRACKER",request.getRemoteAddr(), 
														"attendance_summary_report.jsp");	

if(iAccessLevel == 0)														
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(), 
														"cm_attendance_view_summary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
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
	String strEmployeeID    = (String)request.getSession(false).getAttribute("userId");
	String strEmployeeIndex = (String)request.getSession(false).getAttribute("userIndex");
	String strSubSecIndex   = null;
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	enrollment.AttendanceMonitoringCDD attendance= new enrollment.AttendanceMonitoringCDD();
	Vector vRetResult = null;
	
	

if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
		"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
		" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
		" and faculty_load.is_valid = 1 and e_sub_section.is_valid =1 and e_sub_section.offering_sy_from = "+
		WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
		" and e_sub_section.offering_sem="+
		WI.fillTextValue("offering_sem")+" and is_lec=0 and e_sub_section.is_valid = 1");
						
}

int iElemCount = 0;
if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
		
	vRetResult = attendance.generateAttendanceSummary(dbOP, request, strSubSecIndex);
	if(vRetResult == null)
		strErrMsg = attendance.getErrMsg();
	else
		iElemCount = attendance.getElemCount();
}
	


%>
<body bgcolor="#93B5BB" onLoad="ShowSelectOption();">
<form action="attendance_summary_report.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
    <input type="hidden" name="show_delete">
    <input type="hidden" name="show_save">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          CLASS ATTENDANCE - PER PERIOD ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;<strong><font size="3" color="#FF0000"> 
        <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp; <strong><font color="blue">NOTE: 
        Subject/Sections appear are the sections handled by the logged in faculty 
        Employee ID: <%=strEmployeeID%></font></strong></td>
    </tr>
    <tr> 
      <td width="2%" height="25" rowspan="5" >&nbsp;</td>
      <td width="21%" valign="bottom" >Term</td>
      <td colspan="3" valign="bottom" >School Year </td>
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
      <td width="21%" valign="bottom" > <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes"> </td>
      <td width="56%" colspan="2" >
	  <a href="javascript:Proceed();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
        <td valign="bottom" height="25" >
		<select name="summary_option" onChange="SetSummaryOption()">
	  <%
	  strTemp = WI.fillTextValue("set_summary_option");	 
	  	if(strTemp.equals("1"))
	  		strErrMsg = "selected";
		else
			strErrMsg = "";
	  %><option value="1" <%=strErrMsg%> >Per Sem</option>
	   <%
	  	if(strTemp.equals("2"))
	  		strErrMsg = "selected";
		else
			strErrMsg = "";
	  %><option value="2" <%=strErrMsg%> >Per Month</option>
	   <%
	  	if(strTemp.equals("3"))
	  		strErrMsg = "selected";
		else
			strErrMsg = "";
	  %><option value="3" <%=strErrMsg%> >Per Day</option>
	  </select>				</td>
	  
        <td colspan="3" valign="bottom" >
		<div id="summary_per_month">
		<select name="summary_month">
			<%=dbOP.loadComboMonth(WI.fillTextValue("summary_month"))%>
		</select>
		 <input name="summary_year" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("summary_year")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	   onKeyUp="AllowOnlyInteger('form_','summary_year')"
	  onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','summary_year')">
		</div>
		<div id="summary_per_date">
		<input name="summary_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("summary_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.summary_date');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" 
			onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		</div>
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
      <td>Subject Title</td>
    </tr>
    <tr> 
      <td width="1%"></td>
      <td height="25" > 
<%strTemp = " from faculty_load join e_sub_section on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) "+
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
      <td> 
<% if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%>	
        <strong> <%=WI.getStrValue(strTemp)%></strong>
		<input type="hidden" name="subject_name" value="<%=WI.getStrValue(strTemp)%>">
		<%
		strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_code"," and is_del=0");
		%>
		<input type="hidden" name="subject_code" value="<%=WI.getStrValue(strTemp)%>">
		</td>
      <%}%>
    </tr>
  </table>
<%if(vSecDetail != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="5">&nbsp;</td>
      </tr>
    <tr> 
      <td width="15%" colspan="2">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM 
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%>
    <tr> 
      <td colspan="2">&nbsp;</td>
      <td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="5">
	  
	  </td>
      </tr>
  </table>		
<%
} // if vSubSecDetail not found%>




<%
if(vRetResult != null && vRetResult.size() > 0){
Vector vHeaderList = (Vector)vRetResult.remove(0);
Vector vStudList = (Vector)vRetResult.remove(0);
%>

<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	    <td align="right" height="25">
		<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>
		</td>
	    </tr>
	<tr><td align="center" height="25">SUMMARY OF STUDENT ABSENCES</td></tr>
</table>
<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="3%" height="25" class="thinborder" align="center"><strong style="font-size:10px;">COUNT</strong></td>
	    <td width="13%" class="thinborder" align="center"><strong style="font-size:10px;">ID NUMBER</strong></td>
	    <td class="thinborder" align="center"><strong style="font-size:10px;">STUDENT NAME</strong></td>
	    <td width="20%" class="thinborder" align="center"><strong style="font-size:10px;">COURSE & YEAR</strong></td>
	    <%		
		if(vHeaderList != null && vHeaderList.size() > 0){
		for(int i = 0 ; i < vHeaderList.size(); ++i){
		%>
		<td width="10%" class="thinborder" align="center"><strong style="font-size:10px;"><%=WI.getStrValue(vHeaderList.elementAt(i))%></strong></td>		
		<%}}%>
		<td width="5%" class="thinborder" align="center"><strong style="font-size:10px;">TOTAL HOUR(S)</strong></td>
	</tr>
	
	<%
	Vector vAbsentList = null;
	int iIndexOf = 0;
	Vector vTemp = null;
	String strUserIndex = null;
	int iCount = 0;
	int iTemp  = 0;
	for(int i = 0 ; i < vStudList.size(); i+=iElemCount){
	strUserIndex = (String)vStudList.elementAt(i);
	vAbsentList = (Vector)vStudList.elementAt(i+8);
	%>
	<tr>
	    <td height="25" class="thinborder" align="right"><%=++iCount%>.&nbsp;</td>
	    <td class="thinborder">&nbsp;<%=vStudList.elementAt(i+1)%></td>
		<%
		strTemp = WebInterface.formatName((String)vStudList.elementAt(i+2),(String)vStudList.elementAt(i+3),(String)vStudList.elementAt(i+4),4);
		%>
	    <td class="thinborder">&nbsp;<%=strTemp%></td>
		<%
		strTemp = (String)vStudList.elementAt(i+5)+WI.getStrValue((String)vStudList.elementAt(i+6)," / ","","")
			+WI.getStrValue((String)vStudList.elementAt(i+7)," - ","","");
		%>
	    <td class="thinborder">&nbsp;<%=strTemp%></td>
		 <%
		 if(vHeaderList != null && vHeaderList.size() > 0){
		for(int j = 0 ; j < vHeaderList.size(); ++j){
			iIndexOf = vAbsentList.indexOf(strUserIndex+"_"+vHeaderList.elementAt(j));
			
			
		%>
	    <td class="thinborder" valign="top">
		<%
		if(iIndexOf > -1){
		%>
			<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
			<%
			strTemp = (String)vAbsentList.elementAt(iIndexOf + 1);
			vTemp = CommonUtil.convertCSVToVector(strTemp);
			while(vTemp.size() > 0){
			iTemp = 0;	
			%>
				<tr>
					<%while(vTemp.size() > 0){
					if(++iTemp > 1)
						break;
					%>
					<td><%=vTemp.remove(0)%></td>
					<%}%>
				</tr>
			<%}%>
			</table>
		<%}else{%>&nbsp;<%}%>		
		</td>
		<%}}%>
		<td class="thinborder" align="center"><%=(String)vStudList.elementAt(i+9)%></td>
	    </tr>
	<%}%>
</table>
<%}%>







<table width="100%" border="0" cellpadding="2" cellspacing="0">
<tr bgcolor="#6A99A2"><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr bgcolor="#6A99A2"><td height="25">&nbsp;</td></tr>
</table>

<input type="hidden" name="showCList" value="">
<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="sem_label">
<input type="hidden" name="subj_label">
<input type="hidden" name="exam_period_label">
<input type="hidden" name="set_summary_option" value="<%=WI.getStrValue(WI.fillTextValue("set_summary_option"),"1")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
