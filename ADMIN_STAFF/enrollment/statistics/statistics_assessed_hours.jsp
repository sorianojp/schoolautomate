<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS-Assessed Hours","statistics_assessed_hours.jsp");
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
														"Enrollment","STATISTICS",request.getRemoteAddr(),
														"statistics_assessed_hours.jsp");
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
StatEnrollment SE = new StatEnrollment();
Vector vRetResult = null;
if(WI.fillTextValue("reloadPage").length() > 0 && WI.fillTextValue("reloadPage").compareTo("1") !=0)
{
	vRetResult = SE.getAssessedHoursPerCollege(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SE.getErrMsg();
}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div>";
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);	
	this.insRow(0, 1, strInfo);
	
	
	document.getElementById('printTable').deleteRow(0);
	document.getElementById('footer').deleteRow(0);
	document.getElementById('footer').deleteRow(0);
	window.print();
}
function ReloadPage()
{
	this.SubmitOnce("form_");
}
</script>
<body bgcolor="#D2AE72">

<form action="./statistics_assessed_hours.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable">
    <tr align="center" bgcolor="#999966"> 
      <td height="25" colspan="3"><font color="#FFFFFF"><strong>:::: STATISTICS 
        - ASSESSMENT PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="25"></td>
      <td colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td width="14%">School Year</td>
      <td width="84%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
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
        </select> &nbsp;&nbsp; <a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr> 
      <td height="18"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>College/School </td>
      <td><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Course </td>
      <td><select name="course_index">
          <option value="">All</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where is_visible =1 and IS_DEL=0 and is_valid=1 " +WI.getStrValue(request.getParameter("c_index")," and c_index =","","") + " order by course_name asc",
		  		request.getParameter("course_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Assessment </td>
      <td><select name="assessed" id="assessed">
          <option value="">Hours</option>
          <% if (WI.fillTextValue("assessed").length() >0){%>
          <option value="1" selected>Units</option>
          <%}else{%>
          <option value="1">Units</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0){
	if (WI.fillTextValue("assessed").length() == 0) strTemp =  "0";
	else strTemp = "";
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="printTable">
    <tr>
      <td height="35" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
        <font size="1">click to print &nbsp;</font></td>
    </tr>
    <tr> 
      <td height="25" align="center"><strong>LIST OF ASSESSMENT </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="6%" align="center" class="thinborder">&nbsp;</td>
      <td width="64%" align="center" class="thinborderBOTTOM"> Course</td>
      <td width="10%" height="25" align="center" class="thinborder"><% if (strTemp.length() != 0){%> Lec Hours <%}else{%> Total Acad Units<%}%></td>
      <td width="10%" align="center" class="thinborder"><% if (strTemp.length() != 0){%> Lab Hours <%}else{%> Total Enrolled Units<%}%></td>
      <td width="10%" align="center" class="thinborder">Total</td>
    </tr>
    <% Vector vCollegeTotal =  (Vector)vRetResult.elementAt(0);
	for (int i = 1; i < vRetResult.size(); i+=5){
	   if (vRetResult.elementAt(i) != null) {
	%>
    <tr bgcolor="#CCCCCC"> 
      <td height="25" colspan="4" class="thinborder">&nbsp;College Name : <strong><%=(String)vRetResult.elementAt(i)%></strong></td>
      <td align="center" class="thinborder"><strong><%=(String)vCollegeTotal.elementAt(0)%></strong></td>
    </tr>
    <%vCollegeTotal.removeElementAt(0);
	}%>
    <tr> 
      <td align="center" class="thinborder">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td height="25" class="thinborder"><div align="right">&nbsp;<%=(String)vRetResult.elementAt(i+2)%>&nbsp;</div></td>
      <td class="thinborder"><div align="right">&nbsp;<%=(String)vRetResult.elementAt(i+3)%>&nbsp;</div></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
    </tr>
    <%}// end for loop%>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="footer">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
