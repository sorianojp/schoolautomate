<%
String strUserIndex = (String) request.getSession(false).getAttribute("userIndex");
if( strUserIndex == null || strUserIndex.length() == 0 ){
%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">You are not allowed to view this page.</font></p>
<%return;}%>
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Verify","grade_sheet_verify.jsp");
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
									"Registrar Management","GRADES-Grade Sheets Verification",request.getRemoteAddr(),
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

enrollment.GradeSystemExtn GSExtn = new enrollment.GradeSystemExtn();
Vector vRetResult = new Vector();

boolean bolHasDept = false;
boolean bolViewingPurpose = false;
String strCIndex = WI.fillTextValue("c_index");
String strDIndex = WI.fillTextValue("d_index");
String strCollegeName = null;
String strDeptName = null;
	
strTemp = "select GRADE_SHEET_VERIFY_MGMT_SWU.c_index, GRADE_SHEET_VERIFY_MGMT_SWU.d_index, c_name, d_name,FOR_VIEWING "+
	" from GRADE_SHEET_VERIFY_MGMT_SWU "+
	" left join college on (college.c_index = GRADE_SHEET_VERIFY_MGMT_SWU.c_index)"+
	" left join department on (department.d_index = GRADE_SHEET_VERIFY_MGMT_SWU.d_index)"+
	" where is_valid =1 and user_index ="+strUserIndex;
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
if(rs.next()){
	strCIndex = rs.getString(1);
	strDIndex = rs.getString(2);		
	strCollegeName = rs.getString(3);
	strDeptName = rs.getString(4);
	bolViewingPurpose = rs.getString(5).equals("1");
}rs.close();

if(WI.fillTextValue("c_index").length() > 0)
	strCIndex = WI.fillTextValue("c_index");

	//i have to check if that college has department and that department has already assign employee
if((strDIndex == null || strDIndex.length() == 0) && (strCIndex != null && strCIndex.length() > 0)){
	
	strTemp = "select d_index from GRADE_SHEET_VERIFY_MGMT_SWU where is_valid =1 and c_index = "+strCIndex;
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		if(rs.getString(1) != null)
			bolHasDept = true;			
	}rs.close();
	
	
	
	if(bolHasDept){
		//check if c_index is only there, meaning it controls all department.
		strTemp = " select d_index from DEPARTMENT where IS_DEL = 0 and IS_COLLEGE_DEPT = 1 "+
			" and C_INDEX = "+strCIndex+
			" and not exists( "+
			" 	select * from GRADE_SHEET_VERIFY_MGMT_SWU where IS_VALID = 1 "+
			" 	and d_INDEX = DEPARTMENT.d_INDEX "+
			" ) ";
		rs = dbOP.executeQuery(strTemp);
		strDIndex = null;
		while(rs.next()){
			if(strDIndex == null)
				strDIndex = rs.getString(1);
			else
				strDIndex += ","+rs.getString(1);
		}rs.close();
	}
}
	

if(WI.fillTextValue("d_index").length() > 0)
	strDIndex = WI.fillTextValue("d_index");



if(WI.fillTextValue("get_faculty_list").length() > 0){
	vRetResult = GSExtn.getFacultyListForGradeVerificationSWU(dbOP, request, strCIndex, strDIndex);
	if(vRetResult == null)
		strErrMsg = GSExtn.getErrMsg();
}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
a{
	text-decoration: none;
}
.nav {
     /**color: #000000;**/
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     background-color:#BCDEDB;
}
</style>
</head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function ReloadPage(){
	document.form_.submit();
}
function GetFacultyList(){
	document.form_.get_faculty_list.value = "1";
	this.setExamName();
	document.form_.submit();
}	

function VerifyGrade(strIDNumber){

	var strForViewing = "0";

	<%if(bolViewingPurpose){%>
	alert("Please take note that your account is for viewing purpose only.");
	strForViewing = "1";
	<%}%>
	
	var strIsGraduating = "";
	if(document.form_.graduating_only && document.form_.graduating_only.checked)
		strIsGraduating = "&graduating_only=checked";
		
	location = "./grade_sheet_verify_swu.jsp?sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&offering_sem="+document.form_.offering_sem.value+
		"&grade_for="+document.form_.pmt_schedule.value+
		"&emp_id="+strIDNumber+strIsGraduating+
		"&for_viewing="+strForViewing;
}

function setExamName(){
	document.form_.exam_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" action="grade_sheet_verify_swu_main.jsp" method="post">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">    
<tr bgcolor="#A49A6A"><td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: GRADE SHEETS PAGE ::::</strong></font></div></td></tr>
<tr><td height="25" style="padding-left:30px;"><strong><%=WI.getStrValue(strErrMsg)%></strong></td></tr>    
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%">Exam Period</td>
		<td>
			<select name="pmt_schedule" style="width:100px;" onChange="ReloadPage();">
				<%
				strTemp = " from FA_PMT_SCHEDULE where IS_VALID =1 and (exam_name like 'midterm%' or exam_name like 'final%')";
				%>
				<%=dbOP.loadCombo("PMT_SCH_INDEX","exam_name", strTemp, WI.fillTextValue("pmt_schedule"), false)%>
			</select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>SY-Term</td>
	    <td>
		
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="ReloadPage();style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">		
	&nbsp;
	<select name="offering_sem" onChange="ReloadPage();">
		<%
		
		strTemp = WI.fillTextValue("offering_sem");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
			
		if(strTemp.length() == 0 || strTemp.equals("1"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="1" <%=strErrMsg%>>1st Semester</option>
		
		<%
		if(strTemp.equals("2"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="2" <%=strErrMsg%>>2nd Semester</option>
		<%
		if(strTemp.equals("3"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="3" <%=strErrMsg%>>3rd Semester</option>
		<%
		if(strTemp.equals("4"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="4" <%=strErrMsg%>>4th Semester</option>
		<%
		if(strTemp.equals("0"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="0" <%=strErrMsg%>>Summer</option>
	</select>		</td>
	    </tr>

	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%">College</td>
		<td>
		<%
		if(strCollegeName != null && strCollegeName.length() > 0){
		%>
		<strong><%=strCollegeName%></strong>
		<input type="hidden" name="c_index" value="<%=WI.getStrValue(strCIndex)%>">
		<%}else{%>
			<select name="c_index" style="width:400px;" onChange="GetFacultyList();">				
				<%
				strTemp = " from college where is_del = 0  and is_college =1 order by c_name";
				
				%>
				<%=dbOP.loadCombo("c_index","c_name", strTemp, WI.fillTextValue("c_index"), false)%>
			</select><%}%>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Department</td>
	    <td>
		<%
		if(strDeptName != null && strDeptName.length() > 0){
		%>
		<strong><%=strDeptName%></strong>
		<input type="hidden" name="d_index" value="<%=WI.getStrValue(strDIndex)%>">
		<%}else{%>
		<select name="d_index" style=" width:400px;" onChange="GetFacultyList();">
			<option value="">Select any</option>
			<%
			strTemp = " from department where IS_DEL = 0 and IS_COLLEGE_DEPT = 1 ";
			if(WI.fillTextValue("c_index").length() > 0)
				strTemp += " and c_index = "+WI.fillTextValue("c_index");
			strTemp += "order by d_name";			
			%><%=dbOP.loadCombo("d_index","d_name", strTemp, WI.fillTextValue("d_index"), false)%>
		</select><%}%>
		</td>
	    </tr>	
	
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>
		<a href="javascript:GetFacultyList();"><img src="../../../images/form_proceed.gif" border="0"></a>
		</td>
	</tr>

</table>

<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td width="55%">&nbsp;</td>
	    <td width="45%">&nbsp;</td>
	</tr>
	
	<tr>
		<td>
			<strong>NOTE :</strong><br>
			<%if(bolViewingPurpose){%><div style="text-align:center"><strong style="color:#FF0000">FOR VIEWING PURPOSE ONLY</strong></div>
			<br><%}%>
			<input type="button" name="_2" disabled="disabled" border="0" 
				style="font-size:11px; height:25px; width:25px; background-color:#FAB785; border:solid 1px #000000;	" />Grade not encoded
			<br><input type="button" name="_2" disabled="disabled" border="0" 
				style="font-size:11px; height:25px; width:25px; background-color:#CCCCCC; border:solid 1px #000000;	" />Grade not submitted			
			
			<br><input type="button" name="_2" disabled="disabled" border="0" 
				style="font-size:11px; height:25px; width:25px; background-color:#00FFFF; border:solid 1px #000000;" />Grade is submitted but not verified
			<br><input type="button" name="_2" disabled="disabled" border="0" 
				style="font-size:11px; height:25px; width:25px; background-color:#33CC00; border:solid 1px #000000;	" />Grade is submitted and verified		</td>
	    <td valign="bottom">
		<%
		if(WI.fillTextValue("exam_name").toLowerCase().startsWith("final")){%>
			<input type="checkbox" name="graduating_only" value="checked" <%=WI.fillTextValue("graduating_only")%> onClick="GetFacultyList();"> 
	  	Process Graduating Student Only (Applicable for finals only)
		<%}%>
		</td>
	</tr>
	<tr><td>&nbsp;</td>
	    <td>&nbsp;</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<%
	Vector vSubList = null;
	int iMaxCount = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	int iSubCount  = 0;
	for(int i = 0; i < vRetResult.size(); i+=6){
		vSubList = (Vector)vRetResult.elementAt(i+4);
		if(vSubList == null || vSubList.size() == 0)
			continue;
			
		iSubCount = iMaxCount;
	%>
	<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
		<td class="thinborder" height="25" width="10%"><a href="javascript:VerifyGrade('<%=vRetResult.elementAt(i)%>');"><%=vRetResult.elementAt(i)%></a></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4);
		%>
		<td class="thinborder" width="19%"><%=strTemp%></td>
		
		<%
		while(iSubCount > 0){
			strErrMsg = "";
			strTemp = "&nbsp;";
			if(vSubList.size() > 0){			
				strTemp = WI.getStrValue(vSubList.remove(0));//grade encoded or not
				if(strTemp.equals("1"))
					strErrMsg = "#FAB785";					
				if(strTemp.equals("2"))
					strErrMsg = "#CCCCCC";			
				if(strTemp.equals("3"))
					strErrMsg = "#00FFFF";			
				if(strTemp.equals("4"))						
					strErrMsg = "#33CC00";			
					
				strTemp = (String)vSubList.remove(0)+WI.getStrValue((String)vSubList.remove(0),"<br>Section:","","");
			}
		%>
		<td height="25" align="center" bgcolor="<%=strErrMsg%>" class="thinborder"><font size="1"><%=strTemp%></font></td>
		<% --iSubCount;}%>
		
	</tr>
	<%}%>
	
</table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr bgcolor="#FFFFFF"><td width="84%">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
<input type="hidden" name="get_faculty_list" value="">
<input type="hidden" name="exam_name" value="<%=WI.fillTextValue("exam_name")%>">



</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
