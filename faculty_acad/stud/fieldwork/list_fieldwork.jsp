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
	var vProceed = confirm("Are you sure you want to remove the ojt/field work information.");
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
	document.form_.exam_period_label.value = document.form_.pmt_sch_index[document.form_.pmt_sch_index.selectedIndex].text;
	this.SubmitOnce("form_");
}
function AddOJTInfo(strStudIndex, strStudID) {
	var strSubSecIndex = document.form_.section.value;
	if(strSubSecIndex == '') {
		alert("Subject section information is missing.");
		return;
	}
	var strSYFrom = document.form_.sy_from.value;
	if(strSYFrom == '') {
		alert("School Year information is missing.");
		return;
	}
	var strSemester = document.form_.offering_sem[document.form_.offering_sem.selectedIndex].value;
	if(strSemester == '') {
		alert("Semester information is missing.");
		return;
	}
	var strSubIndex = document.form_.subject.value;
	if(strSubIndex == '') {
		alert("Subject information is missing.");
		return;
	}
	var strSectionName = document.form_.section_name[document.form_.section_name.selectedIndex].value;
	location = "./encode_fieldwork.jsp?section="+strSubSecIndex+
		"&stud_index="+strStudIndex+"&stud_id="+strStudID+"&sy_from="+strSYFrom+
		"&offering_sem="+strSemester+"&subject="+strSubIndex+"&section_name="+
		escape(strSectionName);
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ReportEnrollment,ClassMgmt.CMStudPerformance " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;

	Vector vSecDetail = null;
//add security here.
try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-Class Management-Attendance","list_fieldwork.jsp");
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
														"list_fieldwork.jsp");	
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

Vector vRetResult  = null;
Vector vNotEncoded = null;	
CMStudPerformance sP = new CMStudPerformance();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	
}
vRetResult = sP.operateOnFieldWork(dbOP, request, 4);
if(vRetResult != null)
	vNotEncoded = (Vector)vRetResult.remove(0);
else if(strErrMsg == null) 
	strErrMsg = sP.getErrMsg();

%>
<body bgcolor="#93B5BB">
<form action="list_fieldwork.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          OJT/FIELD WORK DETAIL ::::</strong></font></div></td>
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
      <td width="2%" height="25">&nbsp;</td>
      <td width="22%" valign="bottom" >Term</td>
      <td width="26%" valign="bottom" >School Year</td>
      <td width="50%" colspan="2" >&nbsp; </td>
    </tr>
    <tr> 
      <td valign="bottom" >&nbsp;</td>
      <td valign="bottom" ><select name="offering_sem" onChange="ReloadPage();">
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
      <td ><%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("gsheet","sy_from","sy_to")'>
-
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes"></td>
      <td ><input type="submit" name="12" value=" Reload Page " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.print_page.value='';document.form_.page_action.value=''"></td>
    </tr>
  </table>
<%if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() >0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%"></td>
      <td width="38%" height="25" valign="bottom" >Section Handled</td>
      <td width="60%" valign="bottom" >Instructor (Name of logged in user)</td>
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
      <td width="2%"></td>
      <td height="25">Subject Handled</td>
      <td>Subject Title</td>
    </tr>
    <tr> 
      <td width="2%"></td>
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
<%strTemp = null; 
if(WI.fillTextValue("subject").length() > 0)
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%>
        <strong> <%=WI.getStrValue(strTemp)%></strong></td>
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
      <td align="center"><%=WI.getStrValue(vSecDetail.elementAt(i))%></td>
      <td align="center"><%=WI.getStrValue(vSecDetail.elementAt(i+1))%></td>
      <td align="center"><%=WI.getStrValue(vSecDetail.elementAt(i+2))%></td>
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
<%}if(vRetResult != null && (vRetResult.size() > 0 || vNotEncoded.size() > 0) ){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td>&nbsp;</td>
      <td height="25" width="60%">TOTAL STUDENTS ENROLLED IN THIS CLASS :</td>
      <td width="39%" height="25"><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>click 
          to print OJT Work Detail </font></div></td>
    </tr>
  <tr bgcolor="#EBF5F5">
      <td height="25" colspan="3"><div align="center"><strong>LIST OF STUDENTS 
          OFFICIALLY ENROLLED </strong></div></td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="2%" height="25" align="center" class="thinborder"><font size="1"><strong>SL #</strong></font></td> 
      <td width="12%" height="25" align="center" class="thinborder"><font size="1"><strong>STUDENT ID</strong></font></td> 
      <td width="18%" align="center" class="thinborder"><font size="1"><strong>STUDENT NAME </strong></font></td>
      <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">COMPANY</td>
      <td width="8%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">DURATION</td>
      <td width="35%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">WORK PROFILE </td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;</td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;</td>
    </tr>
<%int iCount = 0;
while(vNotEncoded.size()>0){
strTemp = (String)vNotEncoded.elementAt(1);%>
    <tr>
      <td height="25" class="thinborder" style="font-size:9px;"><%=++iCount%>.</td> 
      <td class="thinborder" style="font-size:9px;"><%=vNotEncoded.remove(1)%></td> 
      <td class="thinborder" style="font-size:9px;"><%=vNotEncoded.remove(1)%></td>
      <td class="thinborder" style="font-size:9px;">&nbsp;</td>
      <td class="thinborder" style="font-size:9px;">&nbsp;</td>
      <td class="thinborder" style="font-size:9px;">&nbsp;</td>
      <td align="center" class="thinborder" style="font-size:9px;">
	  	<a href="javascript:AddOJTInfo('<%=vNotEncoded.remove(0)%>','<%=strTemp%>');">Add</a></td>
      <td align="center" class="thinborder" style="font-size:9px;">&nbsp;</td>
    </tr>
<%}for(int i =0; i < vRetResult.size(); i += 13){%>
    <tr>
      <td height="25" class="thinborder" style="font-size:9px;"><%=++iCount%>.</td> 
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 1)%></td> 
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 3)%><br><font color="#0000FF"><%=vRetResult.elementAt(i + 6)%></font></td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 8)%> to <%=vRetResult.elementAt(i + 9)%></td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 10)%></td>
      <td align="center" class="thinborder" style="font-size:9px;"><a href="javascript:AddOJTInfo('<%=vRetResult.elementAt(i + 12)%>','<%=vRetResult.elementAt(i + 1)%>');">Edit</a></td>
      <td align="center" class="thinborder" style="font-size:9px;">&nbsp;</td>
    </tr>
<%}%>
  </table>
<%}%>
<table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#6A99A2"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#6A99A2"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
