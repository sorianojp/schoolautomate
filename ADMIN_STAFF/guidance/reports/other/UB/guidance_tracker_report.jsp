
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(strShowStat){
	document.form_.show_statistics.value = strShowStat;
	document.form_.submit();
}

function ViewStudent(strTrackIndex) {

	var strIsBasic = "0";
	if(document.form_.is_basic.checked)
		strIsBasic = "1";

	var pgURL = "./guidance_tracker_report_stud_list.jsp?track_extn_index="+strTrackIndex+
	"&sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester.value;
if(document.form_.c_index)
	pgURL += "&c_index="+document.form_.c_index.value;
if(document.form_.course_index)
	pgURL += "&course_index="+document.form_.course_index.value;

pgURL+=
	"&is_basic="+strIsBasic+
	"&year_level="+document.form_.year_level.value;
	var win=window.open(pgURL,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>

<%@ page language="java" import="utility.*,osaGuidance.GDTrackerServices,java.util.Vector" %>
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
								"Admin/staff-Students Affairs-Guidance-Reports-Other","leave_absence.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


GDTrackerServices trackService = new GDTrackerServices();

Vector vRetResult 	= null;

if(WI.fillTextValue("show_statistics").length() > 0){

	vRetResult = trackService.generateStudTrackerReport(dbOP, request, 2);
	if(vRetResult == null)
		strErrMsg = trackService.getErrMsg();
		
	
}

%>

<body>
<form action="guidance_tracker_report.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A" colspan="2"><div align="center"><font color="#FFFFFF"><strong>::::
          GUIDANCE TRACKER PAGE ::::</strong></font></div></td>
    </tr>
	<tr><td width="88%" height="25" style="padding-left:30px;"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
	    <td width="12%" align="right">
		<a href="main.jsp"><img src="../../../../../images/go_back.gif" border="0"></a>		</td>
	</tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	    <td height="25">&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("is_basic");
		boolean bolIsBasic = false;
		if(strTemp.equals("1")){
			strErrMsg = "checked";
			bolIsBasic = true;
		}else
			strErrMsg = "";
		%>
	    <td colspan="2"><input type="checkbox" name="is_basic" value="1" <%=strErrMsg%> onClick="ReloadPage('');">Click to view basic education students.</td>
	    </tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">SY-Term</td>
		<td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
	  &nbsp;
	  
	   <select name="semester">
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.equals("0"))	   
	strErrMsg = "selected";
else
	strErrMsg = "";
%><option value="0" <%=strErrMsg%>>Summer</option>
<%
if(strTemp.equals("1"))	   
	strErrMsg = "selected";
else
	strErrMsg = "";
%><option value="1" <%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.equals("2"))	   
	strErrMsg = "selected";
else
	strErrMsg = "";
%><option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))	   
	strErrMsg = "selected";
else
	strErrMsg = "";
%><option value="3" <%=strErrMsg%>>3rd Sem</option>
<%
if(strTemp.equals("4"))	   
	strErrMsg = "selected";
else
	strErrMsg = "";
%><option value="4" <%=strErrMsg%>>4th Sem</option>
        </select>		</td>
	</tr>
<%
if(!bolIsBasic){
%>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>College</td>
	    <td>
			<select name="c_index" onChange="ReloadPage('');" style="width:300px;">
				<option value="">Select Any</option>
				<%=dbOP.loadCombo("c_index"," c_name "," from college where is_del = 0 ",WI.fillTextValue("c_index"), false)%>
			</select>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Course</td>
	    <td>
			<select name="course_index" onChange="ReloadPage('');" style="width:300px;">
				<option value="">Select Any</option>
				<%
				strTemp = " from COURSE_OFFERED where IS_VALID =1 and IS_OFFERED = 1 ";
				if(WI.fillTextValue("c_index").length() > 0)
					strTemp += " and c_index = "+WI.fillTextValue("c_index");
				strTemp += " order by course_code";
				%>
				<%=dbOP.loadCombo("course_index"," course_code, course_name ",strTemp,WI.fillTextValue("course_index"), false)%>
			</select>		</td>
	    </tr>
<%}%>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Year Level</td>
	    <td>
		<select name="year_level" onChange="ReloadPage('');">
			<option value="">Select Any</option>
			<%			
			strTemp = WI.fillTextValue("year_level");
			
			
		if(!bolIsBasic){			
			if(strTemp.equals("1"))
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
	<%}else{%>		
			<%=dbOP.loadCombo("g_level","level_name"," from BED_LEVEL_INFO order by g_level",WI.fillTextValue("year_level"),false)%>
	<%}%>
			
			
			
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
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td>&nbsp;</td></tr>
<tr><td height="22" bgcolor="#CCCCCC" align="center" class="thinborderBOTTOM" style="font-weight:bold">SUMMARY OF STUDENT TRACKER</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%
	for(int i = 0; i < vRetResult.size(); i+=8){
	%>
	<tr> 
      <td width="2%" height="30"></td>
      <td width="29%" style="font-size:18px;"><%=vRetResult.elementAt(i+1)%></td>
      <td style="font-size:18px;"><%=vRetResult.elementAt(i+2)%>
	  <a href="javascript:ViewStudent('<%=vRetResult.elementAt(i)%>')"><img src="../../../../../images/view.gif" border="0"></a>
	  </td>
    </tr>
	<%}%>
</table>
<%}%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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