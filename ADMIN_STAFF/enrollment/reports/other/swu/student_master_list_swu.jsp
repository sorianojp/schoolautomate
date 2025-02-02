<%@ page language="java" import="utility.*,enrollment.ReportEnrollmentSWU,java.util.Vector,java.util.Calendar,java.text.*,java.util.Date " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../../Ajax/ajax.js"></script>

<script language="JavaScript">

function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";	
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}


function PrintPg(strSearchType){

var strTemp = "";
if(strSearchType == '0')
	strTemp = "./master_list_per_college_print.jsp";
if(strSearchType == '1')
	strTemp = "./master_list_all_print.jsp";
if(strSearchType == '2')
	strTemp = "./master_list_per_college_year_level_print.jsp";	
if(strSearchType == '3')
	strTemp = "./master_list_new_students_print.jsp";	
if(strSearchType == '4'){
	if(document.form_.working_type.value == '1')
		strTemp = "./master_list_working_nas_print.jsp";
	else
		strTemp = "./master_list_working_athlete_print.jsp";
}
if(strSearchType == '5')
		strTemp = "./master_list_foreign_print.jsp";		
if(strSearchType == '6')
	strTemp = "./master_list_withdrawn_student_print.jsp";	
if(strSearchType == '7')
	strTemp = "./master_list_per_course_year_level_print.jsp";	
if(strSearchType == '8')
	strTemp = "./master_list_muslim_print.jsp";	

if(strSearchType == '9')
	strTemp = "./master_list_per_instructor.jsp";	
	
if(strTemp.length == 0){
	alert("Please select an option to print.");
	return;
}
	
		
	var printLoc = strTemp+"?search_type="+strSearchType+
	"&sy_from="+document.form_.sy_from.value+
	"&semester="+document.form_.semester.value+
	"&rows_per_pg="+document.form_.rows_per_pg.value;
if(strSearchType == '5'){
	printLoc += "&nationality="+document.form_.nationality.value+
		"&search_nationality="+document.form_.search_nationality.value;
}
if(strSearchType != "1" && strSearchType != "9")	
	printLoc += "&c_index="+document.form_.c_index.value;
if(strSearchType == "2" || strSearchType == "7")	
	printLoc += "&year_level="+document.form_.year_level.value;
if(strSearchType == '4')
	printLoc += "&working_type="+document.form_.working_type.value;
if(strSearchType == '7' || strSearchType == '0')
	printLoc += "&course_index="+document.form_.course_index.value;
if(strSearchType == '9')
	printLoc += "&emp_id="+document.form_.emp_id.value;
	
	var win=window.open(printLoc,"PrintWindow",'width=900,height=400,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
								"Admin/staff-Enrollment-REPORTS","student_master_list_swu.jsp");
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
														"student_master_list_swu.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";




String strSearchType = WI.fillTextValue("search_type");
String strWorkingType = WI.fillTextValue("working_type");
String strSearchNationality = WI.fillTextValue("search_nationality");
%>
<form action="./student_master_list_swu.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          STUDENT MASTER LIST ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="31%">
			<%
			strTemp = WI.fillTextValue("search_type");
			if(strTemp.equals("0") || strTemp.length() == 0){
				strErrMsg = "checked";
				strSearchType = "0";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="0" <%=strErrMsg%> onClick="document.form_.submit();">Show Student per College	  </td>
		<td width="29%">
			<%			
			if(strTemp.equals("1")){
				strErrMsg = "checked";
				strSearchType = "1";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="1" <%=strErrMsg%> onClick="document.form_.submit();">Show all students(Alpha)	  </td>
		<td width="37%">
			<%			
			if(strTemp.equals("2")){
				strErrMsg = "checked";
				strSearchType = "2";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="2" <%=strErrMsg%> onClick="document.form_.submit();">Show by College and Year Level	  </td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>
			<%			
			if(strTemp.equals("3")){
				strErrMsg = "checked";
				strSearchType = "3";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="3" <%=strErrMsg%> onClick="document.form_.submit();">Show New Students		</td>
		<td>
			<%			
			if(strTemp.equals("4")){
				strErrMsg = "checked";
				strSearchType = "4";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="4" <%=strErrMsg%> onClick="document.form_.submit();">Show working scholars only		</td>
		<td>
			<%			
			if(strTemp.equals("5")){
				strErrMsg = "checked";
				strSearchType = "5";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="5" <%=strErrMsg%> onClick="document.form_.submit();">Show Foreigner Students Only		</td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>
			<%			
			if(strTemp.equals("6")){
				strErrMsg = "checked";
				strSearchType = "6";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="6" <%=strErrMsg%> onClick="document.form_.submit();">Show Withdrawn Enrollment		</td>
		<td>
			<%			
			if(strTemp.equals("7")){
				strErrMsg = "checked";
				strSearchType = "7";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="7" <%=strErrMsg%> onClick="document.form_.submit();">Show by College and Year Level with Course		</td>
		<td>
			<%			
			if(strTemp.equals("8")){
				strErrMsg = "checked";
				strSearchType = "8";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="8" <%=strErrMsg%> onClick="document.form_.submit();">Show Muslim/Islam Students		</td>
	</tr>
	<tr>
	   <td height="25">&nbsp;</td>
	   <td>
			<%			
			if(strTemp.equals("9")){
				strErrMsg = "checked";
				strSearchType = "9";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="9" <%=strErrMsg%> onClick="document.form_.submit();">Show List per Instructor		</td>
	   <td>&nbsp;</td>
	   <td>&nbsp;</td>
	   </tr>
</table>	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td colspan="4" height="15"></td></tr>
<%if(strSearchType.equals("4")){%>
	<tr>		
		<td valign="bottom" height="18" colspan="4">Select working scholar type</td>
	</tr>
	<tr>
		<td width="3%">&nbsp;</td>
		<td colspan="3">
			<%
			strTemp = WI.fillTextValue("ws_");
			if(strTemp.equals("1") || strTemp.length() == 0){
				strWorkingType = "1";
				strErrMsg = "checked";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="ws_" value="1" <%=strErrMsg%>  onClick="document.form_.submit();">Non Academic Students
			<%			
			if(strTemp.equals("2")){
				strWorkingType = "2";
				strErrMsg = "checked";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="ws_" value="2" <%=strErrMsg%>  onClick="document.form_.submit();">Athletes		</td>
	</tr>
<%}
if(strSearchType.equals("5")){%>
	<tr>
		<td>&nbsp;</td>
		<td colspan="2">
			<%	
			strTemp = WI.fillTextValue("search_nationality_from");
			if(strTemp.length() == 0 || strTemp.equals("0")){
				strErrMsg = "checked";
				strSearchNationality = "0";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_nationality_from" value="0" <%=strErrMsg%> onClick="document.form_.submit();">Search from GSPIS
			&nbsp; &nbsp; 
			<%			
			if(strTemp.equals("1")){
				strErrMsg = "checked";
				strSearchNationality = "1";
			}
			else
				strErrMsg = "";
			%>
			<input type="radio" name="search_nationality_from" value="1" <%=strErrMsg%> onClick="document.form_.submit();">Search from Foreign Student List
		</td>
	</tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="13%">Nationality</td>
		<td colspan="4">
		<select name="nationality" style="width:300px;">
			<option value="">All</option>
			<%
			String strCondition = null;
			strTemp = WI.getStrValue(WI.fillTextValue("search_nationality_from"),"0");
			if(strTemp.equals("0")){
				strErrMsg = "nationality_index";
				strTemp = "nationality";
				strCondition = " from HR_PRELOAD_NATIONALITY  where is_local=0 order by nationality";
			}else{
				strErrMsg = "ALIEN_NATIONALITY_INDEX";
				strTemp = "NATIONALITY";
				strCondition = 
					" from NA_ALIEN_NATIONALITY "+
					" where exists( "+
					" 	select * from NA_FOREIGN_STUD_LIST where ALIEN_NATIONALITY_INDEX = NA_ALIEN_NATIONALITY.ALIEN_NATIONALITY_INDEX "+
					" 	and IS_DEL = 0 and IS_TEMP_STUD = 0 "+
					" )order by NATIONALITY ";
			}
			
			%>
			<%=dbOP.loadCombo(strErrMsg,strTemp,strCondition, WI.fillTextValue("nationality"), false)%> 
		</select></td>
	</tr>	
<%}%>
	
	
	<tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%" height="25">School year </td>
      <td width="46%" height="25"> <%
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
	  readonly="yes"> &nbsp; &nbsp;
	  
	  
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
      <td width="38%">&nbsp;	  </td>
    </tr>
	<%
	strTemp = "select c_index  from college where is_college =1 and IS_DEL=0 order by c_name asc";
	String strCIndex = null;
	
	if(!strSearchType.equals("1") && !strSearchType.equals("9")){
		strCIndex = dbOP.getResultOfAQuery(strTemp, 0);	%>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="13%">College</td>
		
		<td colspan="4"><select name="c_index" <%if(strSearchType.equals("7") || strSearchType.equals("0")){%> onChange="document.form_.submit();"<%}%>>
          <%if(!strSearchType.equals("0") && !strSearchType.equals("2") && !strSearchType.equals("8") && !strSearchType.equals("5")){%><option value="">All</option><%}%>
          <%=dbOP.loadCombo("c_index","c_name"," from college where is_college =1 and IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select></td>
	</tr>
	
	<%}
	if(strSearchType.equals("7") || strSearchType.equals("0")){%>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="13%">Course</td>
		<td colspan="3">
		<%
		if(strCIndex != null && strCIndex.length() > 0)
		{
			strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and is_offered = 1 and c_index="+WI.fillTextValue("c_index")+
					" order by course_name asc" ;
		}
		else
			strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 order by course_name asc";
		%>
			<select name="course_index">
				<%=dbOP.loadCombo("course_index","course_code, course_name", strTemp, WI.fillTextValue("course_index"),false)%>
			</select>		</td>
	</tr>
	
	<%}if(strSearchType.equals("2") || strSearchType.equals("7")){%>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="13%">Year Level</td>
		<td colspan="2">
			<select name="year_level">
		<%
		strTemp = WI.fillTextValue("year_level");
		if(strTemp.length() == 0 || strTemp.equals("1"))
			strErrMsg = "selected";
		else
			strErrMsg = "";			
		%><option value="1" <%=strErrMsg%>>1st Year</option>
		<%
		if(strTemp.equals("2"))
			strErrMsg = "selected";
		else
			strErrMsg = "";			
		%><option value="2" <%=strErrMsg%>>2nd Year</option>
		<%
		if(strTemp.equals("3"))
			strErrMsg = "selected";
		else
			strErrMsg = "";			
		%><option value="3" <%=strErrMsg%>>3rd Year</option>
		<%
		if(strTemp.equals("4"))
			strErrMsg = "selected";
		else
			strErrMsg = "";			
		%><option value="4" <%=strErrMsg%>>4th Year</option>
		<%
		if(strTemp.equals("5"))
			strErrMsg = "selected";
		else
			strErrMsg = "";			
		%><option value="5" <%=strErrMsg%>>5th Year</option>
		<%
		if(strTemp.equals("6"))
			strErrMsg = "selected";
		else
			strErrMsg = "";			
		%><option value="6" <%=strErrMsg%>>6th Year</option>
			</select>		</td>
	</tr>
	
<%}if(strSearchType.equals("9")){%>
	<tr>
	   <td height="25">&nbsp;</td>
	   <td>Faculty ID:</td>
	   <td colspan="2">
		<input name="emp_id" type="text" size="15" maxlength="32" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	    onKeyUp="AjaxMapName();"><label id="coa_info" style="position:absolute; width:300px;"></label>
		</td>
	   </tr>
<%}%>
	
	
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID3">
	<tr><td align="center">
	Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 45;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i = 1; i < 70; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	&nbsp; &nbsp;
	<a href="javascript:PrintPg('<%=strSearchType%>');"><img src="../../../../../images/print.gif" border="0"></a> 
		<font size="1">Click to print report</font>		
	</td></tr>
	<td height="15">&nbsp;</td>
</table>


	
	
	
  
  
  

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID4">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="working_type" value="<%=strWorkingType%>">
<input type="hidden" name="search_nationality" value="<%=strSearchNationality%>">
</form>


<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>