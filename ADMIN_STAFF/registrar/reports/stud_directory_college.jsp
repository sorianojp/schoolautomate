<%@ page language="java" import="utility.*,basicEdu.BasicGEExtn,java.util.Vector,java.util.Date " %>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"), "");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student's Directory</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">
	var imgWnd;

	function ShowProcessing() {
		imgWnd=
		window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
		document.form_.submit();
		imgWnd.focus();
	}
	
	function CloseProcessing() {
		if (imgWnd && imgWnd.open && !imgWnd.closed) 
			imgWnd.close();
	}
	
	function PrintPg() {
	/**
		if(document.form_.sy_from.value.length == 0 || document.form_.sy_to.value.length == 0){
			alert("Please provide school year information.");
			return;
		}
		
		if(document.form_.offering_sem.value.length == 0){
			alert("Please provide semester information.");
			return;
		}
		
		if(document.form_.c_index.value.length == 0){
			alert("Please provide college information.");
			return;
		}
		
		if(document.form_.course_index.value.length == 0){
			alert("Please provide course information.");
			return;
		}
		
		if(document.form_.grade_level.value.length == 0){
			alert("Please provide year level information.");
			return;
		}
	**/
		document.form_.semester_name.value = document.form_.offering_sem[document.form_.offering_sem.selectedIndex].text;
		document.form_.print_page.value = "1";
		this.ShowProcessing();
	}
	
	function ReloadPage() {
		document.form_.print_page.value = "";
		this.ShowProcessing();
	}
	
	///ajax here to load major..
	function loadMajor() {
		var objCOA=document.getElementById("load_major");
 		var objCourseInput = document.form_.course_index[document.form_.course_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=104&course_ref="+objCourseInput+"&sel_name=major_index&all=1";
		//alert(strURL);
		this.processRequest(strURL);
	}
	
</script>
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Student Directory","stud_directory_college.jsp");
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
															"Registrar Management","REPORTS",request.getRemoteAddr(),
															"stud_directory_college.jsp");
	
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_home_button_content.htm");
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
	
	//BasicGEExtn bedExtn = new BasicGEExtn();
	
	if(WI.fillTextValue("print_page").length() > 0){
		//if(bedExtn.generateStudentDirectory(dbOP, request) == null)
			//strErrMsg = bedExtn.getErrMsg();
		//else{%>
			<jsp:forward page="./stud_directory_college_print.jsp" />
		<%
			return;
		//}
	}
	
%>
<body onUnload="CloseProcessing();">
<form name="form_" action="./stud_directory_college.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="5" align="center">
				<strong>:::: STUDENT'S DIRECTORY ::::</strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="5%">&nbsp;</td>
		  	<td width="17%">S.Y. - Semester: </td>
			<td width="78%"> 
				<input name="sy_from" type="text" size="4" maxlength="4" class="textbox"
					value="<%=WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"))%>"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
				-
				<input name="sy_to" type="text" size="4" maxlength="4" class="textbox"
					value="<%=WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"))%>" 				
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					readonly="yes">
				&nbsp;&nbsp;&nbsp;
				<select name="offering_sem">
					<option value="">N/A</option>
					<%
					if(request.getParameter("sy_from") == null)
						strTemp = (String)request.getSession(false).getAttribute("cur_sem");
					else	
						strTemp = WI.fillTextValue("offering_sem");
					if(strTemp == null)
						strTemp = "";
					
					if(strTemp.equals("1")){%>
						<option value="1" selected>1st Sem</option>
					<%}else{%>
						<option value="1">1st Sem</option>
					<%}if(strTemp.equals("2")){%>
						<option value="2" selected>2nd Sem</option>
					<%}else{%>
						<option value="2">2nd Sem</option>
					<%}
					
					if (!strSchCode.startsWith("CPU")) {
						if(strTemp.equals("3")){%>
							<option value="3" selected>3rd Sem</option>
						<%}else{%>
							<option value="3">3rd Sem</option>
						<%}
					}
					
					if(strTemp.equals("0")){%>
						<option value="0" selected>Summer</option>
					<%}else{%>
						<option value="0">Summer</option>
					<%}%>
					</select></td>
		</tr>
		<% 	
			String strCollegeIndex = WI.fillTextValue("c_index");	
		%>
		<tr> 
			<td height="24">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>: </td>
			<td colspan="3">
				<select name="c_index" onChange="ReloadPage();">
					<option value="">Select College</option>
					<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
				</select></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>Course:</td>
			<td colspan="3">
				<%						
					strTemp = 
						" from course_offered where is_del = 0 and is_valid = 1 "+
						" and c_index = "+strCollegeIndex+
						" order by course_name asc ";
				%>
				<select name="course_index" onChange="loadMajor();">
          			<option value="">Select Course</option>
					<%if (strCollegeIndex.length() > 0){%>
          			<%=dbOP.loadCombo("course_index","course_name", strTemp, WI.fillTextValue("course_index"), false)%>
					<%}%>
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Major:</td>
			<td colspan="3">
			<label id="load_major">
	  			<select name="major_index">
					<option value="">Select Major</option>
          			<%=dbOP.loadCombo("major_index","major_name"," from major where course_index="+WI.getStrValue(WI.fillTextValue("major_index"), "-1")+" order by major_name",WI.fillTextValue("major_index"), false)%> 
        		</select>
	  		</label>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Year Level: </td>
			<td>
				<select name="grade_level">
					<option value="">N/A</option>
				<%
				strTemp = WI.fillTextValue("grade_level");
				if(strTemp.equals("1")){%>
					<option value="1" selected>1st</option>
				<%}else{%>
					<option value="1">1st</option>
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>2nd</option>
				<%}else{%>
					<option value="2">2nd</option>
				<%}if(strTemp.equals("3")){%>
					<option value="3" selected>3rd</option>
				<%}else{%>
					<option value="3">3rd</option>
				<%}if(strTemp.equals("4")){%>
					<option value="4" selected>4th</option>
				<%}else{%>
					<option value="4">4th</option>
				<%}if(strTemp.equals("5")){%>
					<option value="5" selected>5th</option>
				<%}else{%>
					<option value="5">5th</option>
				<%}if(strTemp.equals("6")){%>
					<option value="6" selected>6th</option>
				<%}else{%>
					<option value="6">6th</option>
				<%}%>
				</select></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
				<font size="1">Click to print student's directory.</font></td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page">
	<input type="hidden" name="is_college" value="1">
	<input type="hidden" name="semester_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
