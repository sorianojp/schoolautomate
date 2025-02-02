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
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.moveClicked.value = "";
	this.SubmitOnce('form_');
}
function MoveStud(){
	document.form_.moveClicked.value = "1";
	document.form_.showStudents.value = "1";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function ViewStudSchedule(strStudID) {
	var pgLoc = "../reports/student_sched.jsp?stud_id="+escape(strStudID)+"&show_instructor=1&sy_from="+
	document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&offering_sem="+document.form_.semester.value+"&reloadPage=1";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ShowStudents(strIndex){
	document.form_.showValue.value = strIndex;
	document.form_.showStudents.value = "1";
	document.form_.proceedClicked.value = "1";	
	this.SubmitOnce('form_');	
}
function checkAll()
{	
	var maxDisp = document.form_.iMaxDispFr.value;
	if(!document.form_.selectAll.checked)
	{
		for(var i =0; i< maxDisp; ++i)
		{
			eval('document.form_.move_fr_'+i+'.checked=false');			
		}
	}else{	
		for(var i =0; i< maxDisp; ++i)
		{
			eval('document.form_.move_fr_'+i+'.checked=true');			
		}
	}
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ChangeStudentSched,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CHANGE OF SUBJECTS-Move Section / Students",
								"move_section.jsp");
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
															"move_section.jsp");
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
	Vector vRetResult = null;
	Vector vStudFr = null;
	Vector vStudTo = null;
	Vector vStudListFr = null;
	Vector vStudListTo = null;

	if(WI.fillTextValue("proceedClicked").equals("1")) {
		vStudFr = chngStudSched.getSecList(dbOP, request);		
		if(vStudFr == null)
			strErrMsg = chngStudSched.getErrMsg();
	}
	if(WI.fillTextValue("moveClicked").equals("1")){	
		if(chngStudSched.moveSection(dbOP,request))
			strErrMsg = "Student(s) moved successfully.";
		else			
			strErrMsg = chngStudSched.getErrMsg();
	}
	if(WI.fillTextValue("showStudents").equals("1") && WI.fillTextValue("sub_sec_index_fr").length() > 0){
		vRetResult = chngStudSched.getStudList(dbOP,request);		
		if(vRetResult == null || vRetResult.size() == 0)
			strErrMsg = chngStudSched.getErrMsg();	
		else{
			vStudListFr = (Vector)vRetResult.elementAt(0);
			vStudTo = (Vector)vRetResult.elementAt(1);
			vStudListTo = (Vector)vRetResult.elementAt(2);	
		}	
	}
	
//i have to get grade sheet security exemption. i allow to move and delete grade if grade is No Attendance,
//	boolean bolByPassGSS = false;
//	strTemp = dbOP.mapOneToOther("read_property_file","PROP_NAME","'BYPASS_GSS'","PROP_VAL",null);
//	if(strTemp != null && strTemp.compareTo("1") == 0 && comUtil.IsSuperUser(dbOP, (String)request.getSession(false).getAttribute("userId")) )//and super user.
//		bolByPassGSS = true;
	%>
	<form name="form_" action="./move_section.jsp" method="post">
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr> 
		  <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
			  MOVE SECTION PAGE ::::</strong></font></div></td>
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
		  <td width="86%" height="25" colspan="2"> &nbsp;&nbsp; <%
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
			</select>
		  </td>
		</tr>
		<tr> 
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="12%" height="25">Course</td>
		  <td width="86%" height="25" colspan="2"> &nbsp;&nbsp; <select name="course" onChange="ReloadPage();">
			  <option value="">All</option>
			  <%=dbOP.loadCombo("COURSE_INDEX","COURSE_NAME"," from COURSE_OFFERED where IS_DEL=0 order by COURSE_NAME", 
			  WI.fillTextValue("course"), false)%> </select> </td>
		</tr>
		<tr> 
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="12%" height="25">Major</td>
		  <td width="86%" height="25" colspan="2"> &nbsp;&nbsp; 
		  <select name="major" onChange="ReloadPage();">
			  <option value="">N/A&nbsp;&nbsp;</option>
			  <%=dbOP.loadCombo("MAJOR_INDEX","MAJOR_NAME"," from MAJOR where IS_DEL=0 and COURSE_INDEX = "+
			  WI.getStrValue(WI.fillTextValue("course"),"0"),WI.fillTextValue("major"), false)%> </select> </td>
		</tr>
		<tr> 
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="12%" height="25">Year Level</td>
		  <td width="86%" height="25" colspan="2"> &nbsp;&nbsp; 
			<select name="year_level" onChange="ReloadPage();">
			  <option value="">All &nbsp; &nbsp;&nbsp;</option>
			  <%if(WI.fillTextValue("year_level").equals("1")){%>
			  <option value="1" selected>1st </option>
			  <option value="2">2nd </option>
			  <option value="3">3rd </option>
			  <option value="4">4th </option>
			  <option value="5">5th </option>
			  <%}else if(WI.fillTextValue("year_level").equals("2")){%>
			  <option value="1">1st </option>
			  <option value="2" selected>2nd </option>
			  <option value="3">3rd </option>
			  <option value="4">4th </option>
			  <option value="5">5th </option>
			  <%}else if(WI.fillTextValue("year_level").equals("3")){%>
			  <option value="1">1st </option>
			  <option value="2">2nd </option>
			  <option value="3" selected>3rd </option>
			  <option value="4">4th </option>
			  <option value="5">5th </option>
			  <%}else if(WI.fillTextValue("year_level").equals("4")){%>
			  <option value="1">1st </option>
			  <option value="2">2nd </option>
			  <option value="3">3rd </option>
			  <option value="4" selected>4th </option>
			  <option value="5">5th </option>
			  <%}else if(WI.fillTextValue("year_level").equals("5")){%>
			  <option value="1">1st </option>
			  <option value="2">2nd </option>
			  <option value="3">3rd </option>
			  <option value="4">4th </option>
			  <option value="5" selected>5th </option>
			  <%}else{%>
			  <option value="1">1st </option>
			  <option value="2">2nd </option>
			  <option value="3">3rd </option>
			  <option value="4">4th </option>
			  <option value="5">5th </option>
			  <%}%>
			</select> </td>
		</tr>
		<tr> 
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="12%" height="25">&nbsp;</td>
		  <td width="86%" height="25" colspan="2"> &nbsp;&nbsp; <a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
		</tr>
	  </table>
	<%if(WI.fillTextValue("proceedClicked").equals("1") && vStudFr != null && vStudFr.size() > 0){%>
	  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18" colspan="3"><hr size="1" color="#FFCC00"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> 
	 <%
	 if(vStudFr != null && vStudFr.size() > 0){
	 strTemp = WI.fillTextValue("sub_sec_index_fr");
	%>
        Section 
        <select name="sub_sec_index_fr" onChange="ShowStudents(1)">
          <option value="">Select a Section</option>
          <%for(int i = 0 ; i < vStudFr.size(); ++i){		  
		  
		  if(WI.fillTextValue("sub_sec_index_to").compareTo((String)vStudFr.elementAt(i)) == 0)
			continue;
		  
		if(strTemp.compareTo((String)vStudFr.elementAt(i)) == 0) {%>
          <option value="<%=(String)vStudFr.elementAt(i)%>" selected><%=(String)vStudFr.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vStudFr.elementAt(i)%>"><%=(String)vStudFr.elementAt(i)%></option>
          <%}
	}%>
        </select> <%}%> </td>
      <td height="25"> <%
	if(vStudTo != null && vStudTo.size() > 0){
	strTemp = WI.fillTextValue("sub_sec_index_to");
	%>
        Section 
        <select name="sub_sec_index_to" onChange="ShowStudents(2)">
          <option value="">Select a Section</option>
          <%
	for(int i = 0 ; i < vStudTo.size(); ++i){
	//if the sub section index is same , do not proceed. 
	if(WI.fillTextValue("sub_sec_index_fr").compareTo((String)vStudTo.elementAt(i)) ==0)
		continue;
		
		if(strTemp.compareTo((String)vStudTo.elementAt(i)) == 0) {%>
          <option value="<%=(String)vStudTo.elementAt(i)%>" selected><%=(String)vStudTo.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vStudTo.elementAt(i)%>"><%=(String)vStudTo.elementAt(i)%></option>
          <%}
	}%>
        </select> <%}%> </td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"> <br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NOTE : 1. Students 
        in <font color="#FF0000"><strong>RED</strong></font> are having conflict 
        and should not be moved.<br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. If all students 
        are moved, Remove faculty loaded to that section. <br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3. Students having 
        final grades will not be moved.</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="50%" valign="top"> <%
	int j = 0; 
	//boolean bolGradeEncoded = false;
	if(vStudListFr != null && vStudListFr.size() > 0 && WI.fillTextValue("sub_sec_index_fr").length() > 0){%> 
	
	<table width="100%" bgcolor="#FFCC00" border="0" cellspacing="1" cellpadding="1">
          <tr> 
            <td height="25" colspan="4" bgcolor="#BFBF80"><div align="center"><font size="1"><strong>LIST 
                OF STUDENTS UNDER <%=WI.fillTextValue("sub_sec_index_fr")%></strong></font></div></td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td height="24" colspan="2"><font color="#0000FF">TOTAL NO.OF STUDENTS 
              :<strong> <%=(String)vStudListFr.elementAt(0)%></strong></font></td>
            <td width="24%"><div align="right"><strong><font size="1">SELECT ALL &nbsp;</font></strong></div></td>
            <td height="24"><div align="center">
			<%if((WI.fillTextValue("selectAll").length() > 0) && !(WI.fillTextValue("showValue").equals("1"))
			     && !(WI.fillTextValue("moveClicked").equals("1")))
				strTemp = "checked";
			else
				strTemp = "";
			%>
			<input type="checkbox" name="selectAll" value="0" onClick="checkAll();" <%=strTemp%>>
			</div></td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td width="26%" height="25"><div align="center"><strong><font size="1">STUDENT 
                ID</font></strong></div></td>
            <td colspan="2"><div align="center"><strong><font size="1">NAME</font></strong></div></td>
            <td width="9%" height="25"><div align="center"><strong><font size="1">MOVE</font></strong></div></td>
          </tr>
          <%j = 0; 
			  for(int i = 1; i < vStudListFr.size(); i += 4){
			/*if(bolByPassGSS)
			  	bolGradeEncoded = false;
			  else {
			  	if(dbOP.mapOneToOther("g_sheet_final","sub_sec_index",
				WI.fillTextValue("sub_sec_index_fr"),"GS_INDEX"," and is_valid = 1 and is_del = 0") == null)
					bolGradeEncoded = false;
				else	
					bolGradeEncoded = true;
			  }*/
			  %>
          <tr bgcolor="#FFFFFF"> 
            <td height="25"> <a href='javascript:ViewStudSchedule("<%=(String)vStudListFr.elementAt(i + 1)%>");' title="Show Complete schedule"> 
              <font size="1" color="#003399"><%=(String)vStudListFr.elementAt(i + 1)%></font></a></td>
            <td colspan="2"><%=(String)vStudListFr.elementAt(i + 2)%></td>
            <td align="center">
			<%if(WI.fillTextValue("move_fr_"+j).length() > 1 && !(WI.fillTextValue("showValue").equals("1"))
				&& !(WI.fillTextValue("moveClicked").equals("1")))
				strTemp = "checked";			
			else
				strTemp = "";			
			if((vStudListFr.elementAt(i + 3)) != null && 
			   (Integer.parseInt((String)vStudListFr.elementAt(i + 3)) > 0)){%>
			<font style="font-size:8px" color="#FF0000">Having F.Grade</font>
			<%}else{%>			
			<input type="checkbox" name="move_fr_<%=j%>" value="<%=(String)vStudListFr.elementAt(i)%>" <%=strTemp%>> 
			<%++j;}%>
            </td>
          </tr>
          <%}//end of for loop%>
          <input type="hidden" name="iMaxDispFr" value="<%=j%>">
        </table>
        <%}//only if vStudFr is not null%> </td>
      <td width="50%" valign="top"> 
	  	<%if(vStudListTo != null && vStudListTo.size() > 0 
	  		&& WI.fillTextValue("sub_sec_index_to").length() > 0 
			&& !(WI.fillTextValue("showValue").equals("1"))){%> 
	  <table width="99%" border="0" align="right" cellpadding="1" cellspacing="1" bgcolor="#FFCC00">
          <tr> 
            <td height="25" colspan="2" bgcolor="#DDDDBF"><div align="center"><strong><font size="1"> 
                LIST OF STUDENTS UNDER <%=WI.fillTextValue("sub_sec_index_to")%></font></strong> </div></td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td height="24" colspan="2"><font color="#0000FF">TOTAL NO.OF STUDENTS 
              :<strong> <%=(String)vStudListTo.elementAt(0)%></strong></font></td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td width="26%" height="25"><div align="center"><strong><font size="1">STUDENT 
                ID</font></strong></div></td>
            <td width="65%"><div align="center"><strong><font size="1">NAME</font></strong></div></td>
          </tr>
          <%
			  for(int i = 1; i < vStudListTo.size(); i += 3){
			//		if(dbOP.mapOneToOther("g_sheet_final","sub_sec_index",
			//		WI.fillTextValue("sub_sec_index_to"),"GS_INDEX"," and is_valid = 1 and is_del = 0") == null)
			//			bolGradeEncoded = false;
			//		else	
			//			bolGradeEncoded = true;
			  %>
          <tr bgcolor="#FFFFFF"> 
            <td height="25"> <a href='javascript:ViewStudSchedule("<%=(String)vStudListTo.elementAt(i + 1)%>");' title="Show Complete schedule"> 
              <font size="1" color="#003399"><%=(String)vStudListTo.elementAt(i + 1)%></font></a></td>
            <td><%=(String)vStudListTo.elementAt(i + 2)%></td>
          </tr>
          <%}//end of for loop%>
        </table>
        <%}//only if vStudTo is not null %> </td>
    </tr>
    <tr>
      <td height="25" align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" align="center"> <%if(vStudListFr != null && vStudListFr.size() > 1 
	  									&& WI.fillTextValue("sub_sec_index_to").length() > 0){%> 
	  <input type="submit" border="0" value="MOVE >>" onClick="MoveStud();"> 
        <%}%> </td>
      <td align="center">&nbsp; </td>
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
	  <input type="hidden" name="proceedClicked" value="">
	  <input type="hidden" name="showStudents" value="">
	  <input type="hidden" name="moveClicked" value="">
	  <input type="hidden" name="showValue" value="">
	</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
