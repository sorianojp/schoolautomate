<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-class program without room","classprogram_without_room.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		strTemp = "<form name=ssection><input type=hidden name=showsubject></form>";
		%><%=strTemp%><%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
															"classprogram_without_room.jsp");
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

%>


<form name="form_" action="./classprogram_without_room.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CLASS PROGRAM WITHOUT ROOM ASSIGNMENT ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">NOTE: Enter school year information to check 
        if class program is not having room assignment </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%" height="25">SY/Term</td>
      <td width="42%"> <%
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else
	strTemp = WI.fillTextValue("sy_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
        <%
if(request.getParameter("sy_to") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
else
	strTemp = WI.fillTextValue("sy_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
<%
if(request.getParameter("semester") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
else
	strTemp = WI.fillTextValue("semester");
%>
		<select name="semester">
	  		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> </td>
      <td width="44%"><input type="submit" value="Show Report" name="_1"></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%
if(WI.fillTextValue("sy_from").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#3366FF" class="thinborder"><font color="#FFFFFF"><b> 
        ::: LIST OF SECTION LACKING ROOM ASSIGNMENT ::: </b></font></td>
    </tr>
    <tr align="center" style="font-weight:bold"> 
      <td width="15%" height="25" bgcolor="#FFFFAF" class="thinborder">Sub Code </td>
      <td width="35%" bgcolor="#FFFFAF" class="thinborder">Sub Name </td>
      <td width="15%" bgcolor="#FFFFAF" class="thinborder">Section</td>
	  <td width="20%" bgcolor="#FFFFAF" class="thinborder">Offered by college </td>
      <td width="15%" bgcolor="#FFFFAF" class="thinborder">Offered by Dept </td>
    </tr>
<%
java.sql.ResultSet rs = null; int iTotalLackingInfo = 0;
String strSQLQuery = "select sub_code, sub_name, section, c_name, d_name from e_sub_section " +
		"join subject on (e_sub_section.sub_index = subject.sub_index) "+
  		"left join college on (college.c_index = offered_by_college) "+
  		"left join department on (department.d_index = offered_by_dept) "+
  		"where is_valid = 1 and is_lec = 0 and exists " +
  		"(select * from e_room_assign where is_valid = 1 and e_sub_section.sub_sec_index = e_room_assign.sub_sec_index and room_index is null)"+
		" and offering_sy_from ="+WI.fillTextValue("sy_from")+" and offering_sem = "+WI.fillTextValue("semester")+
  		" order by sub_code, sub_name, section";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()){++iTotalLackingInfo;%>
    <tr> 
      <td height="25" class="thinborder"><%=rs.getString(1)%></td>
      <td class="thinborder"><%=rs.getString(2)%></td>
      <td class="thinborder"><%=rs.getString(3)%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(4),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(5),"&nbsp;")%></td>
    </tr>
<%}if(iTotalLackingInfo == 0) {%>
    <tr> 
      <td height="25" class="thinborder" colspan="5" style="font-weight:bold; color:#0000FF; font-size:14px;">All Class programs are having room assignment</td>
    </tr>
<%}%>
  </table>
<%}//only if sy info is entered.
%>
<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="show_result">
<input type="hidden" name="sub_sec_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
