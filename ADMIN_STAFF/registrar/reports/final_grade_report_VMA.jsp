<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,student.GWA,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

if(strSchCode == null) {%>
		<p style="font-family:Geneva, Arial, Helvetica, sans-serif; font-weight:bold; color:#FF0000;"> You are already logged out. please login again.</p>
<%return;}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
	}

    TD.thinborderGrade {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderLegend {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PrintPage()
{		
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);
	document.getElementById('myTable3').deleteRow(0);

	obj = document.getElementById('myTable2');
	var oRows = obj.getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i)
		obj.deleteRow(0);

	
	window.print();
}

function Search(strReportType){

	if(strReportType == '1'){
		if(document.form_.gwa_score.value == ''){
			alert("Please input general weighted average.");
			return;
		}
	}	
	
	document.form_.search_.value = '1';
	document.form_.submit();
}
	function CallOnLoad() {
		document.all.processing.style.visibility='hidden';	
		document.bgColor = "#FFFFFF";
	}

</script>


<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();" bgcolor="#DDDDDD">
<form name="form_" action="./final_grade_report_VMA.jsp" method="post">
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <!--<label id="page_progress"></label>-->
			<br><img src="../../../Ajax/ajax-loader_small_black.gif">
			</font></p>
			
			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>
<%
	String strErrMsg  = null;
	String strTemp    = null;
	String strTemp2   = null;
		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","final_grade_report_VMA.jsp");
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

//int iAccessLevel = 2;
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"final_grade_report_VMA.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
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

ReportEnrollment enrlReport = new ReportEnrollment();
GWA gwa = new GWA();

Vector vRetResult = new Vector();
Vector vGWA = new Vector();


if(WI.fillTextValue("search_").length() > 0){
	vRetResult = enrlReport.viewEnrollmentListUC2(dbOP, request);
	if(vRetResult == null)
		strErrMsg = enrlReport.getErrMsg();
	else{
		vGWA = gwa.getTopStudentNew(dbOP, request);
		if(vGWA == null)
			strErrMsg = gwa.getErrMsg();
		//System.out.println("vGWA "+vGWA);
		
		vRetResult.remove(0);
	}
}	

String strReportType = null;

%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    <tr>
      <td colspan="5" align="center" valign="bottom" class="thinborderBOTTOM"><strong>:::: STUDENT FINAL GRADE ::::</strong></td>
    </tr>
	<tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
</table>


<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable2">
	
	
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">SY/Term</td>		
		<td>			
			<%strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));%>
			<select name="semester">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select></td>		
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Course</td>
		<td>
		 <select name="course_index">
		 	<option>
 <%=dbOP.loadCombo("Course_index","Course_name"," from course_offered where is_valid=1", WI.fillTextValue("course_index"),false)%>
 			</option>
		 </select></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Year Level</td>
		<td><select name="year_level">
		<% 	strTemp = WI.fillTextValue("year_level");
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
		</select>
		</td>
	</tr>	
	
	<tr><td colspan="3" height="15">&nbsp;</td></tr>
	<tr><td colspan="2">&nbsp;</td>
		<td><a href="javascript:Search('<%=strReportType%>');"><img src="../../../images/form_proceed.gif" border="0" align="absmiddle"></a></td>
	</tr>
	
</table>

<%
String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER","FIFTH SEMESTER"};
String[] astrYearLevel = {" ","FIRST YEAR","SECOND YEAR","THIRD YEAR","FOURTH YEAR","FIFTH YEAR"};
if(vRetResult != null && vRetResult.size() > 0 && vGWA != null && vGWA.size() > 0){%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable3">
	<tr><td align="right"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a></td></tr>
</table>



<%
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);

boolean bolIsPageBreak = false;
int iResultSize = 10;
int iLineCount = 0;
int iMaxLineCount = 8;	

int i = 0;

String strGrade = null;
double dGWA = 0d;
int iPageCount = 0;
Vector vSubList =new Vector();	

int iIndexOf = 0;

String strCourseCode = null;
String strCourseName = null;
if(WI.fillTextValue("course_index").length() > 0){
	strTemp = "select course_name,course_code from course_offered where is_valid = 1 and course_index = "+WI.fillTextValue("course_index");
	java.sql.ResultSet rs =  dbOP.executeQuery(strTemp);
	if(rs.next()){
		strCourseName= rs.getString(1);
		strCourseCode= rs.getString(2);
	}rs.close();	

}



while(iResultSize <= vRetResult.size()){

	iLineCount = 0;
		
	
%>
<table height="50px">
	<tr><td>&nbsp;</td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr><td align="center" style="font-size:11px;" height="20"><strong><%=strSchoolName%><br><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></strong></td></tr>
	<tr><td height="20">&nbsp;</td></tr>
	<tr><td align="center" height="20"><strong>SUMMARY OF GRADES</strong></td></tr>
	<tr><td align="center"><strong><%=WI.getStrValue(strCourseName," ")%> <%=WI.getStrValue(strCourseCode," (",")","")%> - <%=astrYearLevel[Integer.parseInt(WI.fillTextValue("year_level"))]%></strong></td></tr>
	<tr><td align="center" height="20"><strong><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> SY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></strong></td></tr>
	<tr><td align="right" height="20">Page <%=++iPageCount%></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
<tr>
	 	<td width="23%" align="center" class="thinborder">STUDENT ID</td>
		<td width="28%" align="center" class="thinborder">STUDENT NAME</td>
		<td width="17%" align="center" class="thinborder">SUBJECT CODE</td>
		<td width="16%" align="center" class="thinborder">GRADE</td>
		<td width="16%" align="center" class="thinborder">GPA</td>
	</tr>
	<%
		for( ; i < vRetResult.size() ; ){
			++iLineCount;
			vSubList = (Vector) vRetResult.elementAt(i+6);
			
			iIndexOf = vGWA.indexOf((String)vRetResult.elementAt(i+1));		
			if(iIndexOf > -1)
				dGWA = Double.parseDouble((String)vGWA.elementAt(iIndexOf + 3));
			else
				dGWA = 0d;	
				
			iResultSize += 10;		
			
	%>
	<tr>	
	    <td class="thinborder"><%=vRetResult.elementAt(i+1)%></td> 	
		<td class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
		<%
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";
		%>
		<td width="35%" class="thinborder"><%=strTemp%></td>
		<%		
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		%>
		<td width="32%" class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		if(vSubList.size() == 0)
			strTemp = CommonUtil.formatFloat(dGWA,2);
		else
			strTemp = "&nbsp;";
		%>
		<td width="33%" class="thinborder" align="center"><%=strTemp%></td>	
	</tr>
	<%
	while(vSubList.size() > 0){
	%>
	<tr>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
		<%
		if(vSubList.size() > 0)
			strTemp = (String)vSubList.remove(0);
		else
			strTemp = "&nbsp;";
		%>
	    <td class="thinborder"><%=strTemp%></td>
		<%		
		if(vSubList.size() > 0){
			vSubList.remove(0);	
			strTemp = (String)vSubList.remove(0);
			vSubList.remove(0);
		}else
			strTemp = "&nbsp;";
		%>
	    <td class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		if(vSubList.size() == 0)
			strTemp = CommonUtil.formatFloat(dGWA,2);
		else
			strTemp = "&nbsp;";
		%>
	    <td class="thinborder" align="center"><%=strTemp%></td>
    </tr>	
	<%}//end while(vSubList.size() > 0)
	%>
	 <tr>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
	</tr>
	<%	i+=10;
		if(iLineCount >= iMaxLineCount){
			bolIsPageBreak = true;
			break;		
		}else
			bolIsPageBreak = false;	
	}%>	
</table>
	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>
<%}
}%>
<input type="hidden" name="gwa_con" value="0">
<input type="hidden" name="search_">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>