<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

	function PrintPg(){
	
	if(!confirm("Click OK to print page."))
		return;

	document.bgColor = "#FFFFFF";

	document.getElementById("table1").deleteRow(0);
	document.getElementById("table1").deleteRow(0);
	
	document.getElementById("table2").deleteRow(0);
	document.getElementById("table2").deleteRow(0);
	document.getElementById("table2").deleteRow(0);
	document.getElementById("table2").deleteRow(0);
	document.getElementById("table2").deleteRow(0);
	document.getElementById("table2").deleteRow(0);
	
	document.getElementById("table5").deleteRow(0);
	
	document.getElementById("table3").deleteRow(0);
	document.getElementById("table3").deleteRow(0);
	document.getElementById("table3").deleteRow(0);
	document.getElementById("table3").deleteRow(0);
	document.getElementById("table3").deleteRow(0);
	document.getElementById("table3").deleteRow(0);
	document.getElementById("table3").deleteRow(0);
	document.getElementById("table3").deleteRow(0);
	document.getElementById("table3").deleteRow(0);
	
	
	
	document.getElementById("table4").deleteRow(0);
	document.getElementById("table4").deleteRow(0);
	

	window.print();
	
}

function PrintNumber(strFieldName){
	if(strFieldName.length == 0){
		alert("Field information not found.");
		return null;
	}
	
	var pgURL = "./exit_interview_frequency_answer.jsp?field_name="+strFieldName+
		"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&c_index_con="+document.form_.c_index_con.value+
		"&course_index="+document.form_.course_index.value+
		"&major_index="+document.form_.major_index.value+
		"&year_level="+document.form_.year_level.value+
		"&semester="+document.form_.semester.value;
	var win=window.open(pgURL,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function ReloadPage(strShowStat){
	document.form_.show_statistics.value = strShowStat;
	document.form_.submit();
}
function PrintInterview(strStudId) {
	if(strStudId.length == 0){
		alert("Student ID not found.");
		return;
	}
	

	var pgURL = "./exit_interview_print.jsp?stud_id="+strStudId+
	"&sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester.value;
	var win=window.open(pgURL,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AjaxMapName() {
		var strCompleteName = document.form_.stud_id.value;
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
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=-1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");	
	if (strSchCode == null)
		strSchCode = "";

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-Guidance-Reports-Other","exit_interview_mgmt.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
	
	

osaGuidance.GDExitInterview gdExitInterview = new osaGuidance.GDExitInterview();
Vector vRetResult = null;
	

if(WI.fillTextValue("show_statistics").length() > 0)	{
	vRetResult = gdExitInterview.generateInterviewFrequency(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = gdExitInterview.getErrMsg();
}
	
	
%>
<body bgcolor="#D2AE72">
<form action="exit_interview_frequency.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="table1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          GUIDANCE EXIT INTERVIEW REPORT PAGE ::::</strong></font></div></td>
    </tr>
	<tr bgcolor="#FFFFFF"><td width="88%" height="25" style="padding-left:30px;"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
	    <td width="12%" align="right">
		<a href="main.jsp"><img src="../../../../../images/go_back.gif" border="0"></a>		</td>
	</tr>
</table>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  id="table2">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">SY-Term</td>
		<td>
		<%	strTemp = WI.fillTextValue("sy_from");
			if(strTemp.length() ==0) 
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> 
		<%	strTemp = WI.fillTextValue("sy_to");
			if(strTemp.length() ==0) 
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		%>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
	  &nbsp;	  
	   <select name="semester">
	<%	strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		if(strTemp.equals("0"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="0" <%=strErrMsg%>>Summer</option>
	<%	if(strTemp.equals("1"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="1" <%=strErrMsg%>>1st Sem</option>
	<%	if(strTemp.equals("2"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="2" <%=strErrMsg%>>2nd Sem</option>
	<%	if(strTemp.equals("3"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="3" <%=strErrMsg%>>3rd Sem</option>
	<%	if(strTemp.equals("4"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="4" <%=strErrMsg%>>4th Sem</option>
        </select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>College</td>
	    <td>
			<select name="c_index_con" onChange="ReloadPage('');" style="width:300px;">
				<option value="">Select Any</option>
				<%=dbOP.loadCombo("c_index"," c_name "," from college where is_del = 0 ",WI.fillTextValue("c_index_con"), false)%>
			</select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Course</td>
	    <td>
			<select name="course_index" onChange="ReloadPage('');" style="width:300px;">
				<option value="">Select All</option>
				<%	strTemp = " from COURSE_OFFERED where IS_VALID =1 and IS_OFFERED = 1 ";
					if(WI.fillTextValue("c_index").length() > 0)
						strTemp += " and c_index = "+WI.fillTextValue("c_index");
					strTemp += " order by course_code";
				%>
				<%=dbOP.loadCombo("course_index"," course_code, course_name ",strTemp,WI.fillTextValue("course_index"), false)%>
			</select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Major</td>
	    <td>
			<select name="major_index" onChange="ReloadPage('');" style="width:300px;">
				<option value="">Select All</option>
				<%	
				if(WI.fillTextValue("course_index").length() > 0){
				strTemp = " from major where is_del =0 and course_index = "+WI.fillTextValue("course_index")+
					"order by course_code";
				%>
				<%=dbOP.loadCombo("major_index"," course_code, major_name ",strTemp,WI.fillTextValue("major_index"), false)%>
				<%}%>
			</select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Year Level</td>
	    <td>
		<select name="year_level" onChange="ReloadPage('');">
			<option value="">Select Any</option>
			<%	strTemp = WI.fillTextValue("year_level");
				if(strTemp.equals("1"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="1" <%=strErrMsg%>>1st Year</option>
			<%	if(strTemp.equals("2"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="2" <%=strErrMsg%>>2nd Year</option>
			<%	if(strTemp.equals("3"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="3" <%=strErrMsg%>>3rd Year</option>
			<%	if(strTemp.equals("4"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="4" <%=strErrMsg%>>4th Year</option>
			<%	if(strTemp.equals("5"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="5" <%=strErrMsg%>>5th Year</option>
			<%	if(strTemp.equals("6"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="6" <%=strErrMsg%>>6th Year</option>
		</select>		</td>
	    </tr>
	
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>
		<a href="javascript:ReloadPage('1');"><img src="../../../../../images/form_proceed.gif" border="0"></a>		</td>
	</tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table5">
	<tr>
	    <td align="right" height="25"><a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>
		</td>
	    </tr>
	<tr><td align="center" height="25">
	<font style="font-size:14px"><%=SchoolInformation.getSchoolName(dbOP, true, false)%></font><br>
	<font style="font-size:12px"><%=SchoolInformation.getAddressLine1(dbOP, false, false)%></font><br><br>
	<strong>FREQUENCY REPORT ON EXIT INTERVIEW ANSWERS</strong>
	
	<%
	String strCIndex = WI.fillTextValue("c_index_con");
	String strCourseIndex = WI.fillTextValue("course_index");
	strErrMsg = "";
	if(strCourseIndex.length() > 0){
		if(strCIndex.length() == 0){
			strTemp = "select c_index from course_offered where course_index = "+strCourseIndex;
			strCIndex =dbOP.getResultOfAQuery(strTemp, 0);
		}
		strTemp = "select course_name from course_offered where course_index = "+strCourseIndex;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null && strTemp.length() > 0)
			strErrMsg = "<br>"+strTemp.toUpperCase();
	}
	
	if(strCIndex != null && strCIndex.length() > 0){
		strTemp = "select c_name from college where c_index = "+strCIndex;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null && strTemp.length() > 0)
			strErrMsg = "<br>"+strTemp.toUpperCase()+strErrMsg;
	}
	%><%=strErrMsg%><br>School Year <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>
	
	</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20" colspan="3"><strong>Part II. General Curriculum</strong></td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">1. Please rate your satisfaction with your present course in the following areas:</td>		
	</tr>
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2" valign="bottom">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">1- Needs Improvement</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">2- Moderately Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">3- Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">4- Very Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">5- Outstanding</td>
				</tr>
			</table>	
		</td>	
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr style="font-weight:bold;">
				  <td colspan="2" valign="bottom" style="padding-left:20px;" height="20">&nbsp;</td>
				  <td valign="bottom">&nbsp;</td>
				  <td valign="bottom">1</td>
				  <td valign="bottom">2</td>
				  <td valign="bottom">3</td>
				  <td valign="bottom">4</td>
				  <td valign="bottom">5</td>
			  </tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">a. </td>
					<td width="40%" valign="bottom">Curriculum Design ( Courses in the Curriculum)</td>			
					<%
					vRetResult.remove(0);
					%>		
					<td width="7%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>					
				 	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>				 	
			  	  	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td width="31%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">b.</td>
					<td valign="bottom"> Overall quality of instruction</td>		
					<%
					vRetResult.remove(0);
					%>		
					
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">c.</td>
					<td valign="bottom">  Relevance of course work to everyday life</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">d.</td>
					<td valign="bottom"> Opportunity for Specialization</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">e.</td>
					<td valign="bottom"> Laboratory Facilities and Equipement</td>
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>							
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">f.</td>
					<td valign="bottom"> Computer Facilities</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">g.</td>
					<td valign="bottom"> Tutoring and other academic assistance</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">h.</td>
					<td valign="bottom"> Opportunities to participate in research </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">i.</td>
					<td valign="bottom"> Opportunities for community service</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">j.</td>
					<td valign="bottom"> Opportunities to develop leadership potentials</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">k.</td>
					<td valign="bottom"> Sense of belongingness in the department</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">l.</td>
					<td valign="bottom"> Sense of identity being a UB student</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">m.</td>
					<td valign="bottom"> Amount of contact with faculty</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">n.</td>
					<td valign="bottom"> Interaction with other students</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>				
			</table>	
		</td>	
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td colspan="2" valign="bottom" height="20">
					2. Over - All impact of the General Curriculum</td>		
					<%
					vRetResult.remove(0);
					%>
					<td width="7%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				 	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
			  	  	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				  	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				  	<td width="31%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
			</table>
		</td>	
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20" colspan="3"><strong>Part III. Skills Acquired</strong></td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">1. Rate yourself in terms of the skills you are acquired in your stay in the University:</td>		
	</tr>
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2" valign="bottom">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">1- Needs Improvement</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">2- Moderately Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">3- Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">4- Very Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">5- Outstanding</td>
				</tr>
			</table>	
		</td>	
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr style="font-weight:bold;">
				  <td colspan="2" valign="bottom" style="padding-left:20px;" height="20">&nbsp;</td>
				  <td valign="bottom">&nbsp;</td>
				  <td valign="bottom">1</td>
				  <td valign="bottom">2</td>
				  <td valign="bottom">3</td>
				  <td valign="bottom">4</td>
				  <td valign="bottom">5</td>
			  </tr>
			  <tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">a.</td>
					<td width="40%" valign="bottom"> Academic Preparation</td>		
					<%
					vRetResult.remove(0);
					%>
					<td width="7%" valign="bottom"><%=vRetResult.remove(0)%></td>
				 	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
			  	  	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				  	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				  	<td width="31%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
			  </tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">b.</td>
					<td valign="bottom"> Interpersonal Skills</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">c.</td>
					<td valign="bottom">  Ability to get along with people of different Races/cultures </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">d.</td>
					<td valign="bottom"> Religious beliefs and convictions</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">e.</td>
					<td valign="bottom"> Understanding of the problems facing our nation</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">f.</td>
					<td valign="bottom"> Understanding of global issues</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">g.</td>
					<td valign="bottom"> Mathematical skills</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">h.</td>
					<td valign="bottom"> Computer Skills </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">i.</td>
					<td valign="bottom"> Planning and Organizational Skills</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">j.</td>
					<td valign="bottom"> Oral and Communication Skills</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">k.</td>
					<td valign="bottom"> Decision - Making Skills</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">l.</td>
					<td valign="bottom"> Financial Management Skills</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">m.</td>
					<td valign="bottom"> Critical thingking Skills</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">n.</td>
					<td valign="bottom"> Problem - Solving Skills</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">o.</td>
					<td valign="bottom"> Conflict Resolution Skills </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">p.</td>
					<td valign="bottom"> Teamwork and Teambuilding </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">q.</td>
					<td valign="bottom"> Ethics and Tolerance Skills </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">r.</td>
					<td valign="bottom"> Personal Management Skills </td>
					<td valign="bottom">&nbsp;</td>
					<td valign="bottom">&nbsp;</td>
					<td valign="bottom">&nbsp;</td>
					<td valign="bottom">&nbsp;</td> 
					<td valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">s.</td>
					<td valign="bottom"> Design and Planning Skills </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">t.</td>
					<td valign="bottom"> Research and Investagation Skills </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">u.</td>
					<td valign="bottom"> Listening Skills </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">v.</td>
					<td valign="bottom"> Human Relations and Interpersonal Skills </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">w.</td>
					<td valign="bottom"> Management and Administration Skills </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">x.</td>
					<td valign="bottom"> Valuing Skills </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">y.</td>
					<td valign="bottom"> Personal and Career Development Skills </td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>									
			</table>	
		</td>	
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td colspan="2" valign="bottom" height="20">
					2. Over - All Self - Evaluation</td>		
					<%
					vRetResult.remove(0);
					%>
					<td width="7%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				 	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
			  	  	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				  	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				  	<td width="31%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
			</table>
		</td>	
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20" colspan="3"><strong>Part IV. Administration, Faculty, and Student Services Staff</strong></td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">1. Rate the Adminstrators, Faculty Members, Staff and Student Service in your stay in the University:</td>		
	</tr>
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2" valign="bottom">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">1- Needs Improvement</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">2- Moderately Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">3- Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">4- Very Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">5- Outstanding</td>
				</tr>
			</table>	
		</td>	
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr style="font-weight:bold;">
				  <td colspan="2" valign="bottom" style="padding-left:20px;" height="20">&nbsp;</td>
				  <td valign="bottom">&nbsp;</td>
				  <td valign="bottom">1</td>
				  <td valign="bottom">2</td>
				  <td valign="bottom">3</td>
				  <td valign="bottom">4</td>
				  <td valign="bottom">5</td>
			  </tr>
			  <tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">1. </td>
					<td width="40%" valign="bottom">How is your relationship with your administrators?</td>		
					<%
					vRetResult.remove(0);
					%>
					<td width="7%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				 	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
			  	  	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				  	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				  	<td width="31%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
			  </tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">2.</td>
					<td valign="bottom"> How is your relationship with your teachers?</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:20px;" height="20">3.</td>
					<td valign="bottom">  How is your relationship with the following areas?</td>
					<td valign="bottom" colspan="5">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Health Services</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Guidance Center</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Student Affairs</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Library Services</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Registrar</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>	
				<tr>
					<td colspan="2" valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Treasurer</td>		
					<%
					vRetResult.remove(0);
					%>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
					<td valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>			
				<tr>
					<td colspan="3" valign="bottom" height="20">Over - all rating</td>		
					<%
					vRetResult.remove(0);
					%>
					<td width="7%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				 	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
			  	  	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				  	<td width="6%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				  	<td width="31%" valign="bottom"><%=vRetResult.remove(0)%>&nbsp;</td>
				</tr>			
			</table>	
		</td>	
	</tr>	
</table>
<table   id="table3" width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20" colspan="3"><strong>Part V. General Considerations</strong></td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">1. What are some of the weakness of UB as an educational institution?</td>		
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2"><a href="javascript:PrintNumber('field_63')"><img src="../../../../../images/print.gif" border="0"></a>
		<font size="1">Click to print list of student's answers</font>
		</td>
	</tr>
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">2. What are some of the strengths of UB as an educational institution?</td>		
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2"><a href="javascript:PrintNumber('field_64')"><img src="../../../../../images/print.gif" border="0"></a>
		<font size="1">Click to print list of student's answers</font>
		</td>
	</tr>
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
</table>


<%}//end of vRetResult!=null && vRetResult.size()>0%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"   id="table4">
	<tr><td>&nbsp;</td></tr>
	<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>
<input type="hidden" name="show_statistics" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>