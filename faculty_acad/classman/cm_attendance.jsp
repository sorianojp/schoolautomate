<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
	document.form_.page_action.value = "0";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.sem_label.value = document.form_.offering_sem[document.form_.offering_sem.selectedIndex].text;
	document.form_.subj_label.value = document.form_.subject[document.form_.subject.selectedIndex].text;
	this.SubmitOnce("form_");
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ReportEnrollment,ClassMgmt.CMAttendance " %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;

	Vector vSecDetail = null;
//add security here.

	if (WI.fillTextValue("print_page").compareTo("1") == 0){
%>
	<jsp:forward page="./cm_attendance_print.jsp" />
<%	return;} 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-Class Management-Attendance","cm_attendance.jsp");
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
														"cm_attendance.jsp");	
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
	String[] astrStatus ={"PRESENT","ABSENT","LATE","SENT OUT"};
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

if (WI.fillTextValue("page_action").compareTo("1") == 0){
	vRetResult = cm.operateOnAttendance(dbOP,request,1);
	if (vRetResult != null)
		strErrMsg = " Class attendance added successfully";
	else
		strErrMsg = cm.getErrMsg();
	
}else if (WI.fillTextValue("page_action").compareTo("0") == 0) {
	vRetResult = cm.operateOnAttendance(dbOP,request,0);
	if (vRetResult != null)
		strErrMsg = " Class attendance removed successfully";
	else
		strErrMsg = cm.getErrMsg();
} 

vRetResult = cm.operateOnAttendance(dbOP,request,4);

if (vRetResult == null && strErrMsg == null){
	strErrMsg = cm.getErrMsg();	
}
%>
<body bgcolor="#93B5BB">
<form action="cm_attendance.jsp" method="post" name="form_" id="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
    <input type="hidden" name="show_delete">
    <input type="hidden" name="show_save">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          CLASS ATTENDANCE MAINTENANCE PAGE::::</strong></font><font color="#FFFFFF"></font></div></td>
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
      <td width="28%" >Date of Attendance</td>
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
      <td ><input name="date_attendance" type="text" class="textbox" id="date_attendance"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.fillTextValue("date_attendance")%>" size="11" readonly="yes">
        <a href="javascript:show_calendar('form_.date_attendance');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td colspan="2" > <a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a> 
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
        <select name="subject" id="subject" onChange="ReloadPage();">
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
<%
	if (vRetResult != null) {
		Vector vRecorded = (Vector)vRetResult.elementAt(0);	
		Vector vUnrecorded = (Vector)vRetResult.elementAt(1);
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td>&nbsp;</td>
      <td height="25" width="60%">TOTAL STUDENTS ENROLLED IN THIS CLASS : <strong><%=Integer.parseInt((String)vRecorded.elementAt(0)) + Integer.parseInt((String)vUnrecorded.elementAt(0))%></strong></td>
      <td width="39%" height="25"><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a>click 
          to print attendance</font></div></td>
    </tr>
  <tr bgcolor="#EBF5F5">
      <td height="25" colspan="3"><div align="center"><strong>LIST OF STUDENTS 
          OFFICIALLY ENROLLED </strong></div></td>
  </tr>
</table>
<% 
if (vUnrecorded.size() > 1){
%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="12%" height="27" rowspan="2" align="center"><font size="1"><strong>STUDENT 
        ID</strong></font></td>
      <td height="21" colspan="3" align="center"><strong><font size="1">STUDENT 
        NAME</font></strong></td>
      <td width="15%" rowspan="2" align="center"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="5%" rowspan="2" align="center"><font size="1"><strong>YEAR </strong></font></td>
      <td width="15%" rowspan="2" align="center"><font size="1"><strong>STATUS</strong></font></td>
      <td width="21%" rowspan="2" align="center"><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
    <tr> 
      <td width="14%" height="19" align="center"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="14%" align="center"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="4%" align="center"><font size="1"><strong>MI</strong></font></td>
    </tr>
	<% iCtr = 0;//System.out.println(vUnrecorded.size());
		for(int k=1; k<vUnrecorded.size(); k+=7, iCtr++){%>
    <tr> 
      <td height="25"><div align="center"><font size="1"><%=(String)vUnrecorded.elementAt(k)%></font></div></td>
      <td><font size="1"><%=(String)vUnrecorded.elementAt(k+3)%></font></td>
      <td><font size="1"><%=(String)vUnrecorded.elementAt(k+1)%></font></td>
      <td><div align="center"><font size="1"><%=(WI.getStrValue((String)vUnrecorded.elementAt(k+2), "  ")).charAt(0)%></font></div></td>
      <td><font size="1"><%=(String)vUnrecorded.elementAt(k+4)%> </font></td>
      <td><div align="center"><font size="1"><%=(String)vUnrecorded.elementAt(k+5)%></font></div></td>
      <td><div align="center"> 
          <select name="status<%=iCtr%>" id="status" style="font-size: 10px; ">
 		  <%for (int j = 0; j < astrStatus.length; j++){%>
            <option value="<%=j%>"><%=astrStatus[j]%></option>
		 <%}%>
          </select>
        </div></td>
      <td><div align="center">
          <input name="remarks<%=iCtr%>" type="text" class="textbox" id="date_attendance"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="20">
		<input type="hidden" name="uindex<%=iCtr%>" value="<%=(String)vUnrecorded.elementAt(k+6)%>">
        </div></td>
    </tr>
<%}// end of for loop%>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" dwcopytype="CopyTableCell">
    <tr bgcolor="#6A99A2"> 
      <td height="20" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#6A99A2"> 
      <td height="25" bgcolor="#FFFFFF"><div align="center"> <a href="javascript:AddRecord()"><img src="../../images/save.gif" border=0></a> 
          <font size="1">click to save changes/entries</font></div></td>
    </tr>
    <tr bgcolor="#6A99A2">
      <td height="20" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
<%} if (vRecorded.size() > 1){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="12%" height="27" rowspan="2" align="center"><font size="1"><strong>STUDENT 
        ID</strong></font></td>
      <td height="27" colspan="3" align="center"><strong><font size="1">STUDENT 
        NAME</font></strong></td>
      <td width="14%" rowspan="2" align="center"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="4%" rowspan="2" align="center"><font size="1"><strong>YEAR </strong></font></td>
      <td width="14%" rowspan="2" align="center"><font size="1"><strong>STATUS</strong></font></td>
      <td width="14%" rowspan="2" align="center"><font size="1"><strong>REMARKS</strong></font></td>
      <td rowspan="2" align="center"><font size="1"><strong>SELECT</strong></font></td>
    </tr>
    <tr> 
      <td width="14%" align="center"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="14%" align="center"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="4%" align="center"><font size="1"><strong>MI</strong></font></td>
    </tr>
    <%	for(int k=1; k<vRecorded.size(); k+=10,iCtr2++){%>
    <tr> 
      <td height="25"><div align="center"><font size="1"><%=(String)vRecorded.elementAt(k)%></font></div></td>
      <td><font size="1"><%=(String)vRecorded.elementAt(k+3)%></font></td>
      <td><font size="1"><%=(String)vRecorded.elementAt(k+1)%></font></td>
      <td><div align="center"><font size="1"><%=(WI.getStrValue((String)vRecorded.elementAt(k+2), " ")).charAt(0)%></font></div></td>
      <td><font size="1"><%=(String)vRecorded.elementAt(k+4)%> </font></td>
      <td><div align="center"><font size="1"><%=(String)vRecorded.elementAt(k+5)%></font></div></td>
      <td><div align="center"><%=astrStatus[Integer.parseInt((String)vRecorded.elementAt(k+7))]%></div></td>
      <td><font size="1"><%=WI.getStrValue((String)vRecorded.elementAt(k+8),"&nbsp")%></font></td>
      <td><div align="center">
          <input type="checkbox" name="checkbox<%=iCtr2%>" value="<%=(String)vRecorded.elementAt(k+9)%>">
        </div></td>
    </tr>
    <%}// end of for loop%>
  </table>
 <table width="100%" border="0" cellpadding="2" cellspacing="0" dwcopytype="CopyTableCell">
    <tr bgcolor="#6A99A2"> 
      <td height="20" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#6A99A2"> 
      <td height="25" bgcolor="#FFFFFF"><div align="center"> <a href="javascript:DeleteRecord()"><img src="../../images/delete.gif" width="55" height="28" border=0></a> 
          <font size="1">click to delete entries</font></div></td>
    </tr>
    <tr bgcolor="#6A99A2">
      <td height="20" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <%}// vRecorded.size() > 1
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
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
