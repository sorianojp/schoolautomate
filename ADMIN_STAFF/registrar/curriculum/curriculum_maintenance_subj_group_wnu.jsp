<%@ page language="java" import="utility.*,enrollment.CurriculumSM,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	
//add security here.
	try
	{
		dbOP = new DBOperation();
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_maintenance.jsp");
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
CurriculumSM CSM= new CurriculumSM();
Vector vRetResult = new Vector();
Vector vSubGroup  = new Vector();
String strCourseIndex = WI.fillTextValue("course_index");
String strMajorIndex  = WI.fillTextValue("major_index");
Vector vNonCreditSubj = new Vector();

if(strCourseIndex.equals("selany"))
	strErrMsg = "Please select a course";

strTemp = WI.fillTextValue("cy_info");
if(strTemp.length() > 0 && strErrMsg == null) {
	vRetResult = CSM.getCurriculumInfoWithSubjectGroupWNU(dbOP, strCourseIndex, strMajorIndex, strTemp.substring(0,4), strTemp.substring(5));
	if(vRetResult == null)
		strErrMsg = CSM.getErrMsg();
	else {	
		vSubGroup = (Vector)vRetResult.remove(0);
		vNonCreditSubj = CSM.operateOnNonCreditSubject(dbOP, request, 4);
		if(vNonCreditSubj == null)
			vNonCreditSubj = new Vector();
	}
	
}

///get the non-credit units.. 
String strCourseName = null;
String strMajorName  = null;

String strSQLQuery = null;
strCourseName = dbOP.getResultOfAQuery("select course_name from course_offered where course_index = "+strCourseIndex, 0);
if(strMajorIndex.length() > 0) {
	strMajorName = dbOP.getResultOfAQuery("select major_name from major where major_index = "+strMajorIndex, 0);
	strSQLQuery +=" and major_index = "+strMajorIndex;
}
else	
	strSQLQuery = " and major_index is null";
	

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function GoBack() {
	location = "./curriculum_maintenance_page1.jsp?course_index=<%=strCourseIndex%>&major_index=<%=strMajorIndex%>&cc_index=<%=WI.fillTextValue("cc_index")%>";
}
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
	
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
	
   	document.getElementById('myADTable3').deleteRow(0);

   	document.getElementById('myADTable4').deleteRow(0);
   	document.getElementById('myADTable4').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}
</script>
<body bgcolor="#D2AE72">
<form name="cmaintenance" method="post" action="./curriculum_maintenance_subj_group_wnu.jsp">
<input type="hidden" name="course_index" value="<%=strCourseIndex%>">
<input type="hidden" name="major_index" value="<%=strMajorIndex%>">
<input type="hidden" name="cc_index" value="<%=WI.fillTextValue("cc_index")%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: CURRICULUM INFORMATION WITH SUBJECT GROUP::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td height="25" colspan="2"><%=WI.getStrValue(strErrMsg)%>&nbsp;&nbsp;&nbsp;
	  <a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a>
	  </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">Course:</td>
      <td width="85%"><%=strCourseName%></td>
    </tr></tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major:</td>
      <td><%=WI.getStrValue(strMajorName,"&nbsp;")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Curriculum Year:</td>
      <td>
			<select name="cy_info" onChange="document.cmaintenance.submit();">
			<option value=""></option>
<%
strSQLQuery = "select distinct sy_from, sy_to from curriculum where course_index = "+strCourseIndex+
strSQLQuery+" and is_valid = 1 order by sy_from desc"; 
//System.out.println(strSQLQuery);

java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
strTemp = WI.fillTextValue("cy_info");
String strCYInfo = null;
while(rs.next()) {	
	strCYInfo = rs.getString(1) + "-"+rs.getString(2);
	if(strTemp.equals(strCYInfo))
		strErrMsg = "selected";
	else
		strErrMsg = "";
	%>
		<option value="<%=strCYInfo%>" <%=strErrMsg%>><%=strCYInfo%></option>
<%}rs.close();%>
			</select>	  
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" name="_" value="Refresh page">  
	  
	  </td>
    </tr>
  </table>
<%if(vSubGroup != null && vSubGroup.size() > 0) {%>
<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" id="myADTable3">
	<tr>
	  <td height="25">&nbsp;</td>
	  <td align="right" style="font-size:9px;"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> Click to Print Page</td>
    </tr>
	<tr style="font-weight:bold">
      	<td width="2%" height="25">&nbsp;</td>
		<td>Course: <%=strCourseName%></td>
	</tr>
	<tr style="font-weight:bold">
      	<td width="2%" height="25">&nbsp;</td>
		<td>Major : <%=WI.getStrValue(strMajorName, " - ")%></td>
	</tr>
	<tr style="font-weight:bold">
      	<td width="2%" height="25">&nbsp;</td>
		<td>Curriculum Year: <%=WI.fillTextValue("cy_info")%></td>
	</tr>
</table>

<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
	<tr style="font-weight:bold">
      	<td width="2%" height="25" style="font-size:9px;">&nbsp;</td>
		<td width="14%" style="font-size:9px;" class="thinborderTOPBOTTOMRIGHT">SUB CODE </td>
		<td width="52%" style="font-size:9px;" class="thinborderTOPBOTTOMRIGHT">SUB NAME</td>
		<td width="16%" style="font-size:9px;" class="thinborderTOPBOTTOMRIGHT">SUB GROUP</td>
		<td width="8%" style="font-size:9px;" class="thinborderTOPBOTTOMRIGHT">LEC/LAB UNIT</td>
		<td width="8%" style="font-size:9px;" class="thinborderTOPBOTTOM">LEC/LAB HOURS</td>
	</tr>
<%
while(vSubGroup.size() > 0) {
strTemp = (String)vSubGroup.remove(0);
	while(vRetResult.size() > 0) {
		if(!vRetResult.elementAt(0).equals(strTemp)) 
			break;
			%>
			<tr>
			  <td height="18">&nbsp;</td>
			  <td class="thinborderRIGHT"><%=vRetResult.elementAt(1)%></td>
			  <td class="thinborderRIGHT"><%=vRetResult.elementAt(2)%></td>
			  <td class="thinborderRIGHT"><%=vRetResult.elementAt(3)%></td>
			  <td class="thinborderRIGHT"><%=vRetResult.elementAt(4)%>/<%=vRetResult.elementAt(5)%></td>
			  <td class="thinborderNONE"><%=vRetResult.elementAt(6)%>/<%=vRetResult.elementAt(7)%></td>
			</tr>
	<%vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);}%>
<%if(vSubGroup.size() > 0) {%>
	<tr>
	  <td height="10">&nbsp;</td>
	  <td class="thinborderRIGHT">&nbsp;</td>
	  <td class="thinborderRIGHT">&nbsp;</td>
	  <td class="thinborderRIGHT">&nbsp;</td>
	  <td class="thinborderRIGHT">&nbsp;</td>
	  <td class="thinborderNONE">&nbsp;</td>
    </tr>
<%}else{%>
	<tr>
	  <td height="10">&nbsp;</td>
	  <td class="thinborderTOP">&nbsp;</td>
	  <td class="thinborderTOP">&nbsp;</td>
	  <td class="thinborderTOP">&nbsp;</td>
	  <td class="thinborderTOP">&nbsp;</td>
	  <td class="thinborderTOP">&nbsp;</td>
    </tr>
<%}%>

<%}//end of while loop

}//show only if vSubGroup is not null%>
</table>
	
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr> 
  </table>

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>
