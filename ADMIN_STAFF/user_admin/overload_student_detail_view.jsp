<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.form_.print_page.value = "";
	document.form_.submit();
}
function PrintPage() {
	document.form_.print_page.value = "1";
	document.form_.submit();
}
</script>

<body>
<%@ page language="java" import="utility.*,enrollment.OverideParameter,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	float fOverLoadUnit = 0f;

	boolean bolShowSummary = false;
	if(WI.fillTextValue("show_summary").length() > 0)
		bolShowSummary = true;

	String[] astrConvertSem ={"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","overload_student_detail_view_view.jsp");

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
														"System Administration","Override Parameters",request.getRemoteAddr(),
														"overload_student_detail_view.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

OverideParameter OP = new OverideParameter();
Vector vStudDetail = null;
Vector vRetResult = null;
Vector vEnrolledSubjectList = null;

if(!bolShowSummary)
	vRetResult = 	OP.operateOnOverLoadSubDetail(dbOP, request,3);
else
	vRetResult = 	OP.operateOnOverLoadSubjectSummary(dbOP, request,4);

if(vRetResult == null)
	strErrMsg = OP.getErrMsg();
%>


<form name="form_" action="./overload_student_detail_view.jsp" method="post">
<%
if(WI.fillTextValue("print_page").length() == 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#CCDDDD">
      <td height="20" colspan="6"><div align="center"><strong>::::
          OVERLOAD SUBJECT DETAIL ::::</strong></div></td>
    </tr>
	</table>
<%}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <%if(strErrMsg != null){%>
	<tr>
		<td height="20" width="2%">&nbsp;</td>
    	<td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <%}
if(WI.fillTextValue("print_page").length() == 0){%>
	<tr>
		<td height="10" width="2%">&nbsp;</td>
    	<td colspan="4"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>School Year : </td>
      <td colspan="3"> <%
strTemp = WI.fillTextValue("offering_yr_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="offering_yr_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","offering_yr_from","offering_yr_to")'>
        -
        <%
strTemp = WI.fillTextValue("offering_yr_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="offering_yr_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="offering_sem">
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
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
        </select></td>
    </tr>
    <tr>
      <td height="20" width="2%">&nbsp;</td>
      <td width="13%">Student ID</td>
      <td width="24%"> <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="7%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a></td>
      <td width="54%"> <a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp;</td>
      <td >COURSE</td>
      <td  colspan="3" ><select name="course_index" onChange="ReloadPage();">
          <option value="">All Course</option>
          <%=dbOP.loadCombo("course_index","course_name",
		  " from course_offered where IS_DEL=0 order by course_name asc",
		  WI.getStrValue(WI.fillTextValue("course_index"),"0"), false)%> </select></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp;</td>
      <td >MAJOR</td>
      <td  colspan="3" ><select name="major_index" onChange="ReloadPage();">
          <option value="">All Major</option>
          <%=dbOP.loadCombo("major_index","major_name",
		  " from major where IS_DEL=0 and course_index = "+
		  WI.getStrValue(WI.fillTextValue("course_index"),"0")+
		  " order by major_name asc",
		  WI.getStrValue(WI.fillTextValue("major_index"), "0"), false)%> </select></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">&nbsp;</td>
      <td >&nbsp;</td>
      <td  colspan="3" >
<%
strTemp = WI.fillTextValue("show_summary");
if(strTemp.length() == 0)
	strTemp = "";
else
	strTemp = " checked";
%>	  <input type="checkbox" name="show_summary" value="1"<%=strTemp%>>
        <font color="#0000FF" size="1">Show Summary (Displays total number of units overloaded
        by a student)</font></td>
    </tr>
  </table>

 <%}//only if print page is not called.
 if(vRetResult != null && vRetResult.size() > 0){%>
<%
if(WI.fillTextValue("print_page").length() == 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="20" colspan="6"><div align="right"><font size="1"><a href="javascript:PrintPage();"><img src="../../images/print.gif" border="0"></a>Click
          to Print this result </font></div></td>
  </table>
    </tr>
<%}//do not show print button if print page is clicked
else{//show header - school name and school address.
%>
<p><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
          <!-- Pangasinan 2420 Philippines -->
</div></p>
<%}if(bolShowSummary){//show summary, else show subject detail. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#ccdddd">
      <td height="20" colspan="6"><div align="center"><strong>OVERLOAD
          SUBJECT SUMMARY</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="17%" height="20"><div align="center"><strong>STUDENT ID </strong></div></td>
      <td width="18%" align="center"><strong>STUDENT NAME</strong></td>
      <td width="50%"><div align="center"><font size="1"><strong>COURSE/MAJOR</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>MAX ALLOWED UNIT</strong></font></div></td>
      <td width="8%"><div align="center"><strong>UNITS OVERLOADED</strong></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 8){%>
    <tr>
      <td height="20"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i + 6)%>
	  	<%=WI.getStrValue((String)vRetResult.elementAt(i + 7), "/","","")%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></td>
    </tr>
<%}%>
  </table>

<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#ccdddd">
      <td height="20" colspan="6"><div align="center"><strong>OVERLOAD
          SUBJECT DETAIL</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="21%" height="20"><div align="center"><font size="1"><strong>SUBJECT
          CODE</strong></font></div></td>
      <td width="44%"><div align="center"><font size="1"><strong>SUBJECT
          DESCRIPTION</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>UNITS
          OVERLOADED</strong></font></div></td>
      <td width="9%"><div align="center"><strong><font size="1">SPECIAL RATE</font></strong></div></td>
    </tr>
    <%
	String strStudID = "";
	for(int i = 0 ; i < vRetResult.size(); i += 10){
		if(strStudID.compareTo((String)vRetResult.elementAt(i + 2)) != 0 ){%>
    <tr>
      <td height="20" colspan="4"><strong><font size="1"><%=(String)vRetResult.elementAt(i + 2)%> (<%=(String)vRetResult.elementAt(i + 3)%>)</font></strong></td>
    </tr>
	<%strStudID =(String)vRetResult.elementAt(i + 2);}%>
    <tr>
      <td height="20"><%=(String)vRetResult.elementAt(i + 6)%> </td>
      <td><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td><%
	  if( ((String)vRetResult.elementAt(i + 9)).compareTo("1") == 0){%> <img src="../../images/tick.gif"> <%}%> &nbsp;</td>
    </tr>
    <%}%>
  </table>
<%}//how detail.

}//end of display if vRetResult > 0%>

<input type="hidden" name="print_page">
</form>
<%
if(WI.fillTextValue("print_page").length() > 0){%>
<script language="javascript">
window.print();
</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
