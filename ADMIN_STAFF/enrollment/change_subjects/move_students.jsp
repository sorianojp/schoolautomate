<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.move_.value = "";
	document.form_.submit();
}
function ReloadSubjectTo() {
	document.form_.reloadSubjectTo.value = "1";
	this.ReloadPage();
}	
function MoveStud(strIndex){
	document.form_.move_.value = strIndex;
}
function viewStudSchedule(strStudID) {
	var pgLoc = "../reports/student_sched.jsp?stud_id="+escape(strStudID)+"&show_instructor=1&sy_from="+
	document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&offering_sem="+document.form_.semester.value+"&reloadPage=1";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SelALL() {
	var iMaxDisp = document.form_.iMaxDispFr.value;
	var bolIsSelected = document.form_.sel_all.checked;

	var obj;
	for(var i = 0; i < iMaxDisp; ++i) {
		eval('obj=document.form_.move_fr'+i);
		if(!obj)
			continue;
		obj.checked = bolIsSelected;
	}
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ChangeStudentSched,enrollment.SubjectSection,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CHANGE OF SUBJECTS-Move Students","move_students.jsp");
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
														"Enrollment","CHANGE OF SUBJECTS",request.getRemoteAddr(),
														"move_students.jsp");
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
ChangeStudentSched chngStudSched = new ChangeStudentSched();
enrollment.ReportEnrollment reportEnrl = new enrollment.ReportEnrollment();

Vector vStudFr = null;
Vector vStudTo = null;

Vector vSecDetailFr = null;
Vector vSecDetailTo = null;

Vector vStudListFr = null;
Vector vStudListTo = null;
String strTemp2 = null;

//move the student from or TO.
if(WI.fillTextValue("move_").length() > 0) {
	if(chngStudSched.moveStudent(dbOP, request)) {
		strErrMsg = "Students moved successfully.";
	}
	else	
		strErrMsg = chngStudSched.getErrMsg();
}


if(WI.fillTextValue("sub_index_fr").length() > 0 && WI.fillTextValue("sub_index_to").length() > 0 && 
	WI.fillTextValue("sy_to").length() > 0) {
	vStudFr = chngStudSched.getSubjectSecList(dbOP, WI.fillTextValue("sub_index_fr"), WI.fillTextValue("sy_from"),
                                  WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
	vStudTo = chngStudSched.getSubjectSecList(dbOP, WI.fillTextValue("sub_index_to"), WI.fillTextValue("sy_from"),
                                  WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
}
if(WI.fillTextValue("sub_sec_index_fr").length() > 0) {
	vSecDetailFr = reportEnrl.getSubSecSchDetail(dbOP,WI.fillTextValue("sub_sec_index_fr"));
	vStudListFr  = chngStudSched.getStudListEnrolledInASection(dbOP, WI.fillTextValue("sub_sec_index_fr"), WI.fillTextValue("sub_sec_index_to"), WI.fillTextValue("nstp_L"), null);
	if(vStudListFr == null || vStudListFr.size() == 0)
		strErrMsg = chngStudSched.getErrMsg();
}
if(WI.fillTextValue("sub_sec_index_to").length() > 0) {
	vSecDetailTo = reportEnrl.getSubSecSchDetail(dbOP,WI.fillTextValue("sub_sec_index_to"));
	vStudListTo  = chngStudSched.getStudListEnrolledInASection(dbOP, WI.fillTextValue("sub_sec_index_to"), WI.fillTextValue("sub_sec_index_to"), WI.fillTextValue("nstp_R"), null);
	if(vStudListTo == null || vStudListTo.size() == 0)
		strErrMsg = chngStudSched.getErrMsg();
}

//i have to get grade sheet security exemption. i allow to move and delete grade if grade is No Attendance,
boolean bolByPassGSS = false;
boolean bolIsSuperUser = comUtil.IsSuperUser(dbOP, (String)request.getSession(false).getAttribute("userId"));

strTemp = dbOP.mapOneToOther("read_property_file","PROP_NAME","'BYPASS_GSS'","PROP_VAL",null);
if(strTemp != null && strTemp.compareTo("1") == 0 && bolIsSuperUser )//and super user.
	bolByPassGSS = true;

%>
<form name="form_" action="./move_students.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          MOVE STUDENTS PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="3"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"MESSAGE : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%" height="25">School Year/Term</td>
      <td width="86%" height="25" colspan="2"> 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
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
        </select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<%
if(WI.fillTextValue("sy_to").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18" colspan="3"><hr size="1" color="#FFCC00"></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="45%" height="25">Subject Code 
        <select name="sub_index_fr" onChange="ReloadPage();" style="width:200px;">
		<option value="">Select a subject</option>
<%=dbOP.loadComboDISTINCT("subject.sub_index","sub_code"," from subject join e_sub_section on (e_sub_section.sub_index = subject.sub_index) where e_sub_section.IS_DEL=0 and "+
"e_sub_section.is_valid = 1 and e_sub_section.offering_sy_from = "+WI.fillTextValue("sy_from")+" and offering_sem = "+WI.fillTextValue("semester")+
	" order by sub_code asc",request.getParameter("sub_index_fr"), false)%>
        </select></td>
      <td width="53%" height="25">Subject Code 
        <select name="sub_index_to" onChange="ReloadSubjectTo();" style="width:200px;">
		<option value="">Select a subject</option>

<%
if(WI.fillTextValue("reloadSubjectTo").length() > 0)
	strTemp = WI.fillTextValue("sub_index_to");
else	
	strTemp = WI.fillTextValue("sub_index_fr");

if(!bolIsSuperUser)
	strErrMsg = " and subject.sub_index = "+WI.getStrValue(WI.fillTextValue("sub_index_fr"), "0");
else	
	strErrMsg = "";

%>
<%=dbOP.loadComboDISTINCT("subject.sub_index","sub_code"," from subject join e_sub_section on (e_sub_section.sub_index = subject.sub_index) where e_sub_section.IS_DEL=0 and "+
"e_sub_section.is_valid = 1 and e_sub_section.offering_sy_from = "+WI.fillTextValue("sy_from")+" and offering_sem = "+WI.fillTextValue("semester")+
	strErrMsg+" order by sub_code asc",strTemp, false)%>
        </select></td>
    </tr>
<%if(strSchCode.startsWith("NEU")){
	boolean bolIsLeftNSTP  = false;
	boolean bolIsRightNSTP = false;

//i have to check if subject selected is nstp.. 
	strTemp2 = "select sub_index from subject join subject_group on (subject_group.group_index = subject.group_index) "+
				"join subject_catg on (subject_catg.catg_index = subject.catg_index) where sub_index = "+WI.fillTextValue("sub_index_fr") +
				" and subject.is_del = 0 and (sub_code like 'nstp%' or catg_name like 'nstp%' or group_name like 'nstp%')";
	if(dbOP.getResultOfAQuery(strTemp2, 0) != null)
		bolIsLeftNSTP = true;
	if(strTemp.equals(WI.fillTextValue("sub_index_fr")))
		bolIsRightNSTP = bolIsLeftNSTP;
	else {
		strTemp2 = "select sub_index from subject join subject_group on (subject_group.group_index = subject.group_index) "+
					"join subject_catg on (subject_catg.catg_index = subject.catg_index) where sub_index = "+strTemp +
					" and subject.is_del = 0 and (sub_code like 'nstp%' or catg_name like 'nstp%' or group_name like 'nstp%')";
		if(dbOP.getResultOfAQuery(strTemp2, 0) != null)
			bolIsRightNSTP = true;
	}
	

if(bolIsLeftNSTP || bolIsRightNSTP) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
<%if(bolIsLeftNSTP) {%>
	  NSTP Component: 
	  <select name="nstp_L">
	    <option value=""></option>
<%
strTemp2 = WI.fillTextValue("nstp_L");
if(strTemp2.equals("CWTS"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="CWTS"<%=strErrMsg%>>CWTS</option>
<%
if(strTemp2.equals("LTS"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="LTS"<%=strErrMsg%>>LTS</option>
<%
if(strTemp2.equals("ROTS"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="ROTS"<%=strErrMsg%>>ROTS</option>
	  </select>
<%}%>
	  </td>
      <td>
<%if(bolIsRightNSTP) {%>
	  NSTP Component: 
	  <select name="nstp_R">
	    <option value=""></option>
<%
strTemp2 = WI.fillTextValue("nstp_R");
if(strTemp2.equals("CWTS"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="CWTS"<%=strErrMsg%>>CWTS</option>
<%
if(strTemp2.equals("LTS"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="LTS"<%=strErrMsg%>>LTS</option>
<%
if(strTemp2.equals("ROTS"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="ROTS"<%=strErrMsg%>>ROTS</option>
	  </select>
<%}%>
	  </td>
    </tr>
<%}
}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>
	  <%if(WI.fillTextValue("sub_index_fr").length() > 0){%>
	  <%=dbOP.mapOneToOther("subject","sub_index",WI.getStrValue(WI.fillTextValue("sub_index_fr"),"0"),"sub_name",null)%><%}%></strong></td>
      <td height="25"><strong>
	  <%if(strTemp.length() > 0){%>
	  <%=dbOP.mapOneToOther("subject","sub_index",WI.getStrValue(strTemp,"0"),"sub_name",null)%><%}%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">
	<% if (!strSchCode.startsWith("CPU")) {%>	
	  Section 
	<%}else{%> 
	  StubCode 
<% } 
if(vStudFr != null && vStudFr.size() > 0){
strTemp = WI.fillTextValue("sub_sec_index_fr");
%>
        <select name="sub_sec_index_fr" onChange="ReloadPage();">
		<option value="">Select a Section</option>
<%for(int i = 0 ; i < vStudFr.size(); i += 2){

	if (strSchCode.startsWith("CPU")) 
		strTemp2 = (String)vStudFr.elementAt(i);
	else
		strTemp2 = (String)vStudFr.elementAt(i + 1);

	if(strTemp.compareTo((String)vStudFr.elementAt(i)) == 0) {%>
	<option value="<%=(String)vStudFr.elementAt(i)%>" selected><%=strTemp2%></option>
	<%}else{%>
	<option value="<%=(String)vStudFr.elementAt(i)%>"><%=strTemp2%></option>
	<%}
}%>
        </select>
<%}%>		</td>
      <td height="25">	<% if (!strSchCode.startsWith("CPU")) {%>	
	  Section 
	<%}else{%> 
	  StubCode 
<% } 

if(vStudTo != null && vStudTo.size() > 0){
strTemp = WI.fillTextValue("sub_sec_index_to");
%>        <select name="sub_sec_index_to" onChange="ReloadPage();">
		<option value="">Select a Section</option>
<%
for(int i = 0 ; i < vStudTo.size(); i += 2){
//if the sub section index is same , do not proceed. 
if(WI.fillTextValue("sub_sec_index_fr").compareTo((String)vStudTo.elementAt(i)) ==0)
	continue;
	if (strSchCode.startsWith("CPU")) 
		strTemp2 = (String)vStudTo.elementAt(i);
	else
		strTemp2 = (String)vStudTo.elementAt(i + 1);
	
	
	if(strTemp.compareTo((String)vStudTo.elementAt(i)) == 0) {%>
	<option value="<%=(String)vStudTo.elementAt(i)%>" selected><%=strTemp2%></option>
	<%}else{%>
	<option value="<%=(String)vStudTo.elementAt(i)%>"><%=strTemp2%></option>
	<%}
}%>
        </select>
<%}%>		</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="top">
<%if(vSecDetailFr != null && vSecDetailFr.size() > 0){%>
<table bgcolor="#000000">    
	<tr> 
      <td bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM 
                #</strong></font></div></td>
      <td bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
    </tr>
    <%
	for(int i = 1; i<vSecDetailFr.size(); i+=3){%> 
	<tr bgcolor="#FFFFFF">
	<td align="center"><%=(String)vSecDetailFr.elementAt(i)%></td>
	<td align="center"><%=(String)vSecDetailFr.elementAt(i+1)%></td>
	  <td align="center"><%=(String)vSecDetailFr.elementAt(i+2)%></td>
	</tr>  
	<%} //end of for loop.%> 
 </table>
 <%}//only if vSecDetailFr != null%>	 </td>
      <td height="25" valign="top"><strong>
<%if(vSecDetailTo != null && vSecDetailTo.size() > 0){%>
<table bgcolor="#000000">    
	<tr> 
      <td bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM 
                #</strong></font></div></td>
      <td bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
    </tr>
    <%
	for(int i = 1; i<vSecDetailTo.size(); i+=3){%> 
	<tr bgcolor="#FFFFFF">
	<td align="center"><%=(String)vSecDetailTo.elementAt(i)%></td>
	<td align="center"><%=(String)vSecDetailTo.elementAt(i+1)%></td>
	  <td align="center"><%=(String)vSecDetailTo.elementAt(i+2)%></td>
	</tr>  
	<%} //end of for loop.%> 
 </table>
 <%}//only if vSecDetailTo != null%>
	  </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Instructor : <strong> 
<%if(vSecDetailFr != null && vSecDetailFr.size() > 0){%>
        <%=WI.getStrValue(vSecDetailFr.elementAt(0),"NOT ASSIGNED")%> 
 <%}%>       </strong></td>
      <td height="25">Instructor : <strong>
<%if(vSecDetailTo != null && vSecDetailTo.size() > 0){%>
        <%=WI.getStrValue(vSecDetailTo.elementAt(0),"NOT ASSIGNED")%> 
 <%}%>       </strong></td>
    </tr>
    <tr> 
      <td height="40">&nbsp;</td>
      <td height="40" colspan="2"><div align="center"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a> 
          <font size="1">click to show list of students under the specified subjects</font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("bypass_");
if(strTemp.compareTo("1") == 0) 
	strTemp = "checked";
else	
	strTemp = "";
%>	  <input type="checkbox" name="bypass_" value="1"<%=strTemp%>>
        Click to by pass conflict check. (NOTE : It is strongly recommended not 
        to by pass conflict check)<br>
        <br>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NOTE : 1. Students in <font color="#FF0000"><strong>RED</strong></font> 
        are having conflict and should not be moved.<br>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. 
        If all students are moved, Remove faculty loaded to that section. <br>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        3. Students having final grades will not be moved.</td>
    </tr>
  </table>
  	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td width="50%" valign="top">
<%
int j = 0; 
boolean bolGradeEncoded = false;
if(vStudListFr != null && vStudListFr.size() > 0){%>
			<table width="100%" bgcolor="#FFCC00" border="0" cellspacing="1" cellpadding="1">
				<tr> 
					<td height="25" colspan="3" bgcolor="#BFBF80"><div align="center"><font size="1"><strong>LIST 
					OF STUDENTS UNDER <%=(String)vStudListFr.elementAt(1)%> / 
					<%=(String)vStudListFr.elementAt(3)%></strong></font></div></td>
				</tr>
				<tr bgcolor="#FFFFFF"> 
					<td height="24" colspan="3"><font color="#0000FF">TOTAL NO.OF STUDENTS :<strong> 
					 <%=(String)vStudListFr.elementAt(0)%></strong></font></td>
				</tr>
			  <tr bgcolor="#FFFFFF"> 
				<td width="26%" height="25"><div align="center"><strong><font size="1">STUDENT 
					ID</font></strong></div></td>
				<td width="65%"><div align="center"><strong><font size="1">NAME</font></strong></div></td>
				<td width="9%" height="25"><div align="center"><strong><font size="1">MOVE<br>
				<input type="checkbox" name="sel_all" value="1" onClick="SelALL();">
				
				</font></strong></div></td>
			  </tr>
			  <%j = 0; 
			  for(int i = 4; i < vStudListFr.size(); i += 4,++j){
			  if(bolByPassGSS)
			  	bolGradeEncoded = false;
			  else {
			  	if(dbOP.mapOneToOther("g_sheet_final","sub_sec_index",
				WI.fillTextValue("sub_sec_index_fr"),"GS_INDEX"," and is_valid = 1 and is_del = 0") == null)
					bolGradeEncoded = false;
				else	
					bolGradeEncoded = true;
			  }
			  %>
			  <tr bgcolor="#FFFFFF"> 
				<td height="25">
<input type="hidden" name="stud_indexLHS<%=j%>" value="<%=(String)vStudListFr.elementAt(i)%>">
				<a href='javascript:viewStudSchedule("<%=(String)vStudListFr.elementAt(i + 1)%>");' title="Show Complete schedule">
				<font size="1" color="#003399"><%=(String)vStudListFr.elementAt(i + 1)%></font></a></td>
				<td><%=(String)vStudListFr.elementAt(i + 2)%></td>
				<td align="center">
<%
//make it read only if it is conflict. and bypass_ conflict is not opted.
if(WI.fillTextValue("bypass_").compareTo("1") != 0 && ( (String)vStudListFr.elementAt(i + 3)).compareTo("1") == 0) {%><font style="font-size:8px">Conflict</font><%}
else if(bolGradeEncoded){%>
	<font style="font-size:8px" color="#FF0000">Having F.Grade</font>
<%}else{%>				
				<input type="checkbox" name="move_fr<%=j%>" value="<%=(String)vStudListFr.elementAt(i)%>">
<%}%>				</td>
			  </tr>
			  <%}//end of for loop%><input type="hidden" name="iMaxDispFr" value="<%=j%>">
        </table>
<%}//only if vStudFr is not null%>
		</td>
		<td width="50%" valign="top">
<%if(vStudListTo != null && vStudListTo.size() > 0){%>
		<table width="100%" bgcolor="#FFCC00" border="0" cellspacing="1" cellpadding="1">
			<tr> 
				<td height="25" colspan="3" bgcolor="#DDDDBF"><div align="center"><strong><font size="1">
				LIST OF STUDENTS UNDER <%=(String)vStudListTo.elementAt(1)%> 
                  / <%=(String)vStudListTo.elementAt(3)%></font></strong>
              </div></td>
			</tr>
			<tr bgcolor="#FFFFFF"> 				
            <td height="24" colspan="3"><font color="#0000FF">TOTAL NO.OF STUDENTS 
              :<strong> <%=(String)vStudListTo.elementAt(0)%></strong></font></td>
			</tr>
		  <tr bgcolor="#FFFFFF"> 
			<td width="26%" height="25"><div align="center"><strong><font size="1">STUDENT 
				ID</font></strong></div></td>
			<td width="65%"><div align="center"><strong><font size="1">NAME</font></strong></div></td>
			<td width="9%" height="25"><div align="center"><strong><font size="1">MOVE</font></strong></div></td>
		  </tr>
		  <%j=0;
		  for(int i = 4; i < vStudListTo.size(); i += 4,++j){
			  	if(dbOP.mapOneToOther("g_sheet_final","sub_sec_index",
				WI.fillTextValue("sub_sec_index_to"),"GS_INDEX"," and is_valid = 1 and is_del = 0") == null)
					bolGradeEncoded = false;
				else	
					bolGradeEncoded = true;
		  %>
			  <tr bgcolor="#FFFFFF"> 
				<td height="25">
<input type="hidden" name="stud_indexRHS<%=j%>" value="<%=(String)vStudListTo.elementAt(i)%>">
				<a href='javascript:viewStudSchedule("<%=(String)vStudListTo.elementAt(i + 1)%>");' title="Show Complete schedule">
				<font size="1" color="#003399"><%=(String)vStudListTo.elementAt(i + 1)%></font></a></td>
				<td><%=(String)vStudListTo.elementAt(i + 2)%></td>
				<td align="center">
<%
//make it read only if it is conflict. and bypass_ conflict is not opted.
if(WI.fillTextValue("bypass_").compareTo("1") != 0 && ( (String)vStudListTo.elementAt(i + 3)).compareTo("1") == 0) {%><font style="font-size:8px">Conflict</font><%}
else if(bolGradeEncoded){%>
	<font style="font-size:8px" color="#FF0000">Having F.Grade</font>
<%}else if(false){%>				
				<input type="checkbox" name="move_to<%=j%>" value="<%=(String)vStudListTo.elementAt(i)%>">
<%}%>				
				</td>
			  </tr>
		  <%}//end of for loop%><input type="hidden" name="iMaxDispTo" value="<%=j%>">
        </table>
<%}//only if vStudTo is not null %>
		</td>
	</tr>
	<tr>
		<td height="25" align="center">
<%if(vStudListFr != null || vStudListTo != null){%>	
		<input type="submit" border="0" value="MOVE >>" onClick="MoveStud(0);">
<%}%>		</td>
		<td align="center">
<%if(vStudListTo != null && vStudListTo.size() > 0 && false){%>
		<input type="submit" value="<< MOVE" onClick="MoveStud(1);">
<%}%>		</td>
	</tr>

	</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26"><div align="center"></div></td>
      <td><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="41" colspan="2"><div align="center"></div></td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="reloadSubjectTo" value="<%=WI.fillTextValue("reloadSubjectTo")%>">
  <input type="hidden" name="move_">
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
