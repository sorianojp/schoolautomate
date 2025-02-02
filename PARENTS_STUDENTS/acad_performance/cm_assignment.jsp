<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="javascript">
function ViewAssignment(strAssignmentIndex,strStat){
	var loadPg = "./cm_assignment_detail.jsp?assignment_ref="+strAssignmentIndex+"&stat="+strStat+"&sy_from="+
	document.form_.sy_from_.value+"&semester="+document.form_.semester_.value;	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,ClassMgmt.CMAssignment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	if(request.getSession(false).getAttribute("userIndex") == null) {%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			You are already logged out. Please login again.</font></p>
		<%
		return;
	}
//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
	//check if elem student.
	String strSQLQuery = "select course_index from stud_curriculum_hist "+
		"join semester_sequence on (semester_sequence.semester_val = semester) "+
		"where is_valid = 1 and user_index = "+
		request.getSession(false).getAttribute("userIndex")+" order by sy_from desc, sem_order desc";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery,0);
	if(strSQLQuery.equals("0")) {//basic
		dbOP.cleanUP();
		
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Not Available for Grade School Student</font></p>
		<%
		return;
	}

CMAssignment cma   = new CMAssignment();
String strSYFrom   = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");

if(strSYFrom.length() == 0) {
	strSYFrom   = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
}

vRetResult = cma.getStudentAssignment(dbOP, request, 4, strSYFrom, strSemester, false);
if(vRetResult == null)
	strErrMsg = cma.getErrMsg();
%>	

<form action="./cm_assignment.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="88%" height="25" colspan="5" bgcolor="#47768F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
      CLASS ASSIGNMENT ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%" height="25">SY-Term</td>
      <td width="34%" height="25"><input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
-
  <select name="semester">
    <option value="1">1st Sem</option>
    <%
if(strSemester.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
    <option value="2"<%=strErrMsg%>>2nd Sem</option>
    <%
if(strSemester.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
    <option value="3"<%=strErrMsg%>>3rd Sem</option>
    <%
if(strSemester.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
    <option value="0"<%=strErrMsg%>>Summer</option>
  </select></td>
      <td width="52%" height="25"><input type="submit" name="132" value="Refresh Display" style="font-size:11px; height:22px;border: 1px solid #FF0000;"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){
Vector vAssignmentWithScore    = (Vector)vRetResult.remove(3);
Vector vAssignmentWithoutScore = (Vector)vRetResult.remove(3);
if(vAssignmentWithoutScore != null && vAssignmentWithoutScore.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="22" colspan="6" bgcolor="#BECED3" class="thinborder" style="font-weight:bold" align="center">- New Assignment List - </td>
    </tr>
    <tr> 
      <td width="17%" class="thinborder" align="center" style="font-weight:bold" height="22">Assignment Name </td>
      <td width="17%" class="thinborder" align="center" style="font-weight:bold">Subj. Code</td>
      <td width="17%" class="thinborder" align="center" style="font-weight:bold">Assignment Date </td>
      <td width="17%" class="thinborder" align="center" style="font-weight:bold">Last Date </td>
      <td width="17%" class="thinborder" align="center" style="font-weight:bold">Assigned by  </td>
      <td width="15%" class="thinborder" align="center" style="font-weight:bold">View Detail </td>
    </tr>
<%int iLateStat = 0; String strBGColor = null;
for(int i = 0; i < vAssignmentWithoutScore.size(); i += 13){
	iLateStat = Integer.parseInt((String)vAssignmentWithoutScore.elementAt(i + 12));
	if(iLateStat == 1)
		strBGColor = " bgcolor='red'";
	else	
		strBGColor = "";
%>
    <tr<%=strBGColor%>> 
      <td height="25" align="center" class="thinborder"><%=(String)vAssignmentWithoutScore.elementAt(i + 4)%></td>
      <td class="thinborder"><%=(String)vAssignmentWithoutScore.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vAssignmentWithoutScore.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vAssignmentWithoutScore.elementAt(i + 6)%></td>
      <td class="thinborder"><%=(String)vAssignmentWithoutScore.elementAt(i + 8)%></td>
      <td class="thinborder" align="center"><a href="javascript:ViewAssignment('<%=vAssignmentWithoutScore.elementAt(i)%>','1')">View</a></td>
    </tr>
<%}%>
  </table>
 <%}//only if vAssignmentWithoutScore is not null and size > 0
if(vAssignmentWithScore != null && vAssignmentWithScore.size() > 0) {%><br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="22" colspan="6" bgcolor="#BECED3" class="thinborder" style="font-weight:bold" align="center">-  Assignment List with Score- </td>
    </tr>
    <tr> 
      <td width="17%" class="thinborder" align="center" style="font-weight:bold" height="22">Assignment Name </td>
      <td width="17%" class="thinborder" align="center" style="font-weight:bold">Subj. Code</td>
      <td width="17%" class="thinborder" align="center" style="font-weight:bold">Assignment Date </td>
      <td width="17%" class="thinborder" align="center" style="font-weight:bold">Assigned by</td>
      <td width="17%" class="thinborder" align="center" style="font-weight:bold">Score</td>
      <td width="15%" class="thinborder" align="center" style="font-weight:bold">View Detail </td>
    </tr>
<%
for(int i = 0; i < vAssignmentWithoutScore.size(); i += 13){%>
    <tr> 
      <td height="25" align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder" align="center"><a href="javascript:ViewAssignment('<%=vRetResult.elementAt(i)%>','0')">View</a></td>
    </tr>
<%}%>
  </table>
 <%}//only if vAssignmentWithoutScore is not null and size > 0
 
}//show only if vRetResult is not null and size > 0%>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="sy_from_" value="<%=request.getParameter("sy_from")%>">
<input type="hidden" name="semester_" value="<%=request.getParameter("semester")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>