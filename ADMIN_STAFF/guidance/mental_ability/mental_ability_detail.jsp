<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function ReloadPage()
{
	this.SubmitOnce('form_');
}
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDMentalAbility, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrSemester = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Mental Ability Test Result","mental_ability_detail.jsp");
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
														"Guidance & Counseling","Mental Ability Test Result",request.getRemoteAddr(),
														"mental_ability_detail.jsp");
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
	GDMentalAbility GDAbility = new GDMentalAbility();
	vRetResult = GDAbility.operateOnMentalAbility(dbOP, request, 3);
	
	if (vRetResult==null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = GDAbility.getErrMsg();

%>
<body bgcolor="#663300" >
<form action="./mental_ability_detail.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
           MENTAL ABILITY TEST RESULT DETAIL ::::</strong></font></div></td>
    </tr>
</table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td colspan="3" height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
      
    </tr>
    <tr> 
      <td width="5%"><p>&nbsp;</p></td>
      <td width="20%" ><strong>Student ID:</strong></td>
      <td width="75%"><%=(String)vRetResult.elementAt(6)%></td>
    </tr>
    <tr> 
      <td width="5%"><p>&nbsp;</p></td>
      <td width="20%"><strong>School Year / Term:</strong> </td>
      <td width="75%"><%=(String)vRetResult.elementAt(3)%>&nbsp;-&nbsp;<%=(String)vRetResult.elementAt(4)%>&nbsp;<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(5))]%></td>
    </tr>
    <tr> 
      <td width="5%"><p>&nbsp;</p></td>
      <td width="20%"><strong>Date of Exam:</strong> </td>
	  <td width="75%"><%=(String)vRetResult.elementAt(7)%></td>
    </tr>
    <tr> 
      <td width="5%"><p>&nbsp;</p></td>
      <td width="20%"><strong>Psychometrician:</strong> </td>
	  <td width="75%"><%=WI.formatName((String)vRetResult.elementAt(10), (String)vRetResult.elementAt(11), (String)vRetResult.elementAt(12),7)%></td>
    </tr>
    <tr> 
      <td width="5%"><p>&nbsp;</p></td>
      <td width="20%"><strong>Raw Score:</strong> </td>
   	  <td width="75%"><%=(String)vRetResult.elementAt(8)%></td>
    </tr>
     <tr> 
      <td width="5%"><p>&nbsp;</p></td>
      <td width="20%"><strong>IQ Classification:</strong></td>
	  <td width="75%"><%=(String)vRetResult.elementAt(2)%></td>
    </tr>
    <tr> 
      <td width="5%"><p>&nbsp;</p></td>
      <td width="20%"><strong>Remarks:</strong></td>
	  <td width="75%"><%=(String)vRetResult.elementAt(13)%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input name = "stud_id" type = "hidden"  value="<%=WI.fillTextValue("stud_id")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
