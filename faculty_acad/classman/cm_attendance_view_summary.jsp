<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
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

function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.sem_label.value = document.form_.offering_sem[document.form_.offering_sem.selectedIndex].text;
	document.form_.subj_label.value = document.form_.subject[document.form_.subject.selectedIndex].text;
	document.form_.submit();
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
	<jsp:forward page="./cm_attendance_view_summary_print.jsp" />
<%	return;} 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-Class Management-Attendance","cm_attendance_view_summary.jsp");
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
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(), 
														"cm_attendance_view_summary.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	String strEmployeeID    = (String)request.getSession(false).getAttribute("userId");
	String strEmployeeIndex = (String)request.getSession(false).getAttribute("userIndex");
	String strSubSecIndex   = null;
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	Vector vRetResult = null;
	
	

if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
		"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
		" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
		" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
		WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
		" and e_sub_section.offering_sem="+
		WI.fillTextValue("offering_sem")+" and is_lec=0 and e_sub_section.is_valid = 1");
						
}

if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}
	
CMAttendance cm = new CMAttendance(request);
int iCtr = 0;int iCtr2 = 0;

/**
if (WI.fillTextValue("page_action").compareTo("1") == 0){
	vRetResult = cm.operateOnAttendancePeriod(dbOP,request,1);
	if (vRetResult != null)
		strErrMsg = " Class attendance added successfully";
	else
		strErrMsg = cm.getErrMsg();
	
}else if (WI.fillTextValue("page_action").compareTo("0") == 0) {
	vRetResult = cm.operateOnAttendancePeriod(dbOP,request,0);
	if (vRetResult != null)
		strErrMsg = " Class attendance removed successfully";
	else
		strErrMsg = cm.getErrMsg();
} 
**/
vRetResult = cm.operateOnAttendancePeriod(dbOP,request,5);
if (vRetResult == null && strErrMsg == null){
	strErrMsg = cm.getErrMsg();	
}
%>
<body bgcolor="#93B5BB">
<form action="cm_attendance_view_summary.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
    <input type="hidden" name="show_delete">
    <input type="hidden" name="show_save">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          CLASS ATTENDANCE - PER PERIOD ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;<strong><font size="3" color="#FF0000"> 
        <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp; <strong><font color="blue">NOTE: 
        Subject/Sections appear are the sections handled by the logged in faculty 
        Employee ID: <%=strEmployeeID%></font></strong></td>
    </tr>
    <tr> 
      <td width="1%" height="25" rowspan="4" >&nbsp;</td>
      <td width="22%" valign="bottom" >Term</td>
      <td width="23%" valign="bottom" >School Year</td>
      <td width="28%" >Period of attendance </td>
      <td width="26%" colspan="2" >&nbsp; </td>
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
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("gsheet","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes"> </td>
      <td><strong>ALL</strong></td>
      <td colspan="2" >
	  <input type="submit" name="12" value=" Reload Page " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.print_page.value='';document.form_.page_action.value=''"></td>
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
        <strong> <%=WI.getStrValue(strTemp)%></strong></td>
      <%}%>
    </tr>
  </table>
<%if(vSecDetail != null){%>
  <table width="100%" border="0" cellspacing="1" cellpadding="2" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
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
  </table>		
<%if (vRetResult != null && vRetResult.size() > 0) {
String strDaysOfClass = (String)vRetResult.remove(0);
Vector vPmtSchInfo    = (Vector)vRetResult.remove(0);
int iOneRecordSizeInVector = 8 + vPmtSchInfo.size()/2;

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="1%">&nbsp;</td>
      <td height="25" width="51%">&nbsp;</td>
      <td width="48%" height="25"><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a>click 
          to print attendance</font></div></td>
    </tr>
    <tr >
      <td>&nbsp;</td>
      <td height="25">Total Students Listed   : <strong><%=vRetResult.size() /iOneRecordSizeInVector%></strong></td>
      <td height="25">Number of Days of Class : <strong><%=strDaysOfClass%></strong></td>
    </tr>
  <tr bgcolor="#EBF5F5">
      <td height="25" colspan="3"><div align="center"><strong>LIST OF STUDENTS 
          WITH ATTENDANCE </strong></div></td>
  </tr>
</table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td width="15%" height="27" align="center"><font size="1"><strong>STUDENT ID</strong></font></td> 
      <td width="10%" align="center"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>MI</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>YEAR </strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>TOTAL ABSENT </strong></font></td>
<%for(int i = 0; i <vPmtSchInfo.size(); i += 2) {%> 
      <td width="5%" align="center"><font size="1"><strong><%=((String)vPmtSchInfo.elementAt(i + 1)).toUpperCase()%></strong></font></td>
<%}%>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i +=iOneRecordSizeInVector) {%> 
    <tr>
      <td width="15%" height="27" align="center" style="font-size:9px;"><%=vRetResult.elementAt(i)%></td> 
      <td width="10%" align="center" style="font-size:9px;"><%=vRetResult.elementAt(i + 3)%></td>
      <td width="10%" align="center" style="font-size:9px;"><%=vRetResult.elementAt(i + 1)%></td>
      <td width="5%" align="center" style="font-size:9px;"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+2)," ").charAt(0)%></font></td>
      <td width="15%" align="center" style="font-size:9px;"><%=vRetResult.elementAt(i + 4)%></td>
      <td width="5%" align="center" style="font-size:9px;"><%=vRetResult.elementAt(i + 5)%></td>
      <td width="5%" align="center" style="font-size:9px;"><%=vRetResult.elementAt(i + 7)%></td>
<%for(int p = 0; p <vPmtSchInfo.size(); p += 2) {%> 
      <td width="5%" align="center" style="font-size:9px;"><%=vRetResult.elementAt(i + 8 + p/2)%></td>
<%}//System.out.println(iOneRecordSizeInVector);%>
    </tr>
<%}//end of for loop.%>
  </table>
  <%
  } // if vRetResult == null
} // if vSubSecDetail not found%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#6A99A2"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#6A99A2"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="iResult" value = "<%=iCtr%>">
<input type="hidden" name="iResult2" value= "<%=iCtr2%>">
<input type="hidden" name="showCList" value="">
<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="sem_label">
<input type="hidden" name="subj_label">
<input type="hidden" name="exam_period_label">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
