<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	//1 = claas time sched, 2 = sched per section.
	String strPrintType = WI.fillTextValue("print_type");
	String strPrintPg   = WI.fillTextValue("print_all");//1 = yes, -1 is selected.
	if(strPrintPg.length() > 0) {
		if(strPrintType.equals("1")) {%>
			<jsp:forward page="./class_time_sched_print.jsp" />
		<%return;}%>
			<jsp:forward page="./sched_per_section_print.jsp" />
		<%
	}
	
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintALL(){
	//document.form_.print_all.value = '1';
	//document.form_.submit();
	
	//I have to select all and print all
	var iMaxDisp = document.form_.max_disp.value;
	for(i = 0; i < iMaxDisp; ++i) {
		eval('obj = document.form_._'+i);
		obj.checked = true;
	}
	this.PrintSelected();
	
}	
function PrintSelected(){
	var i = 0;
	var iMaxDisp = document.form_.max_disp.value;
	var iChecked = 0;
	
	for(; i < iMaxDisp; ++i) {
		eval('obj = document.form_._'+i);
		if(obj.checked)
			++iChecked;
	}
	if(iChecked == '0') {
		alert("Please selecte atleast one section to print");
		return;
	}
	document.form_.print_all.value = '-1';
	document.form_.submit();
}
function PrintOne(objCheckBox){
	var i = 0;
	var iMaxDisp = document.form_.max_disp.value;
	var iChecked = 0;
	
	for(; i < iMaxDisp; ++i) {
		eval('obj = document.form_._'+i);
		if(obj.checked)
			obj.checked = false;
	}

	objCheckBox.checked = true;
	document.form_.print_all.value = '-1';
	document.form_.submit();
}

function Search(){
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";
	document.form_.search_.value = '1';
	document.form_.print_all.value ='';
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

</script>
<body bgcolor="#D2AE72">
<%
	String strTemp = null;
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS-VMA Reports","class_time_sched.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"class_time_sched.jsp");
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


Vector vSectionList    = new Vector();
String strCourseIndex  = WI.fillTextValue("course_index");
String strSYFrom       = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
String strSemester     = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
String[] astrConverSem = {"Summer", "1st Semester", "2nd Semester", "3rd Semester", "4th Semester", "5th Semester"};

if(WI.fillTextValue("search_").length() > 0 && strCourseIndex.length() > 0 && strSYFrom.length() >0){
	String strSQLQuery = "select degree_type from course_offered where course_index = "+strCourseIndex;
	String strDegreeType = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(WI.fillTextValue("section_name_list").length() > 0)
		strSQLQuery = " and section like '"+WI.fillTextValue("section_name_list")+"%' ";
	else	
		strSQLQuery = "";
	if(strDegreeType.equals("1")) {//masteral
		strSQLQuery = "select distinct section from e_sub_section where is_valid = 1 and offering_sy_from = "+strSYFrom+" and offering_sem = "+
						strSemester +" and exists (select * from cculum_masters where is_valid = 1 and sub_index = e_sub_section.sub_index ) and is_child_offering = 0 and "+
						" is_lec = 0 "+strSQLQuery+" order by section";
	}
	else {
		strSQLQuery = "select distinct section,year from e_sub_section join curriculum on (curriculum.sub_index = e_sub_section.sub_index) "+
					" where e_sub_section.is_valid = 1 and offering_sy_from = "+strSYFrom+" and offering_sem = "+
						strSemester +" and course_index = "+strCourseIndex+	WI.getStrValue(WI.fillTextValue("year_level")," and year = ", "","")+
						" and is_child_offering = 0 and is_lec = 0 "+strSQLQuery+" order by year,section";
	}
	//System.out.println(strSQLQuery);
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) 
		vSectionList.addElement(rs.getString(1));
	rs.close();
}

%>
<form action="./class_time_sched.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
	<tr bgcolor="#A49A6A">	
		<td width="100%" height="25" bgcolor="#A49A6A"><div align="center">
		<font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: <%if(strPrintType.equals("1")){%>CLASS TIME SCHEDULE<%}else{%>SCHEDULE PER SECTION<%}%> ::::</strong></font></div></td>
	</tr>
	<tr bgcolor="#FFFFFF"><td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">SY/Term: </td>
		
		<td colspan="3">			
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strSYFrom%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'; document.form_.search_.value = '';document.form_.submit();"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				

			<select name="offering_sem" onChange="document.form_.search_.value = '';document.form_.submit();">
			<%if(strSemester.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strSemester.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strSemester.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strSemester.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>	  </td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Course</td>
		<td colspan="3"> 
		<select name="course_index" onChange="document.form_.section_name_list.value='';document.form_.search_.value = '';document.form_.submit();">
		<option value=""></option>		
		<%=dbOP.loadCombo("course_index","course_code, course_name", " from course_offered where is_valid = 1 and is_offered = 1 order by course_code" , strCourseIndex, false)%> 
		</select>		</td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>		
		<td>Year</td>
		<td colspan="3">
		<select name="year_level" onChange="document.form_.search_.value = '';document.form_.submit();">
		<option value=""></option>
<%
strTemp = WI.fillTextValue("year_level");
if(strTemp.equals("1"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="1" <%=strErrMsg%>>1</option>
<%
if(strTemp.equals("2"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="2" <%=strErrMsg%>>2</option>
<%
if(strTemp.equals("3"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="3" <%=strErrMsg%>>3</option>
<%
if(strTemp.equals("4"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="4" <%=strErrMsg%>>4</option>
<%
if(strTemp.equals("5"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="5" <%=strErrMsg%>>5</option>
<%
if(strTemp.equals("6"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		<option value="6" <%=strErrMsg%>>6</option>			
		</select>		</td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Section Name </td>
<%
strTemp = WI.fillTextValue("section_name_list");
if(strTemp.length() == 0 && WI.fillTextValue("course_index").length() > 0) {
	strTemp = "select course_code from course_offered where course_index = "+WI.fillTextValue("course_index");
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp == null)
		strTemp = "";
}
%>
	  <td colspan="3" style="font-size:9px;"><input name="section_name_list" type="text" size="8" maxlength="8" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';">
      (Optional -- name should be starts with) </td>
    </tr>
	

	<td><td colspan="3">&nbsp;</td></td>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td><a href="javascript:Search();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
	</tr>
</table>
<%if(vSectionList != null && vSectionList.size() > 0) {%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="22" colspan="3" align="center" class="thinborderBOTTOM" style="font-size:14px; font-weight:bold" valign="bottom">List of Sections Offered
			<div align="right">
			<a href="javascript:PrintALL();"><img src="../../../../images/print.gif" border="0"></a> Print ALL &nbsp;&nbsp;&nbsp;&nbsp;
			<a href="javascript:PrintSelected('1');"><img src="../../../../images/print.gif" border="0"></a> Print Selected &nbsp;&nbsp;&nbsp;&nbsp;
			</div>
			
			</td>
		</tr>
<%
int i = 0;
for(; i< vSectionList.size(); ++i) {%>
		<tr>
			<td width="23%" height="22" class="thinborderBOTTOM" style="font-size:14px;">&nbsp; <%=vSectionList.elementAt(i)%></td>
		    <td width="11%" align="center" class="thinborderBOTTOM" style="font-size:14px;">
			<input type="checkbox" name="_<%=i%>" value="<%=vSectionList.elementAt(i)%>">
			
			</td>
		    <td width="66%" class="thinborderBOTTOM" style="font-size:14px;">
			<a href="javascript:PrintOne(document.form_._<%=i%>)"><img src="../../../../images/print.gif" border="0"></a>
			</td>
		</tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=i%>">
	</table>
  
<%}%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>" />
<!--
print type 
1 = class time sched.. 
2 = sched per section.
-->
<input type="hidden" name="print_type" value="<%=strPrintType%>">
<input type="hidden" name="print_all">
</form>

 <!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div> 

</body>
</html>
<%
dbOP.cleanUP();
%>