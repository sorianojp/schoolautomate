<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript"><!--
function CloseWindow(){
	window.opener.focus();
	self.close()
}
-->
</script>
<body>
<%@ page language="java" import="utility.*,utility.SysTrack,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-System Tracking","final_gs_mod_detail.jsp");
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
														"System Administration","System Tracking",request.getRemoteAddr(),
														"final_gs_mod_detail.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
SysTrack ST = new SysTrack(request);
vRetResult = ST.viewDetailGradeModification(dbOP,WI.fillTextValue("info_index"));
if(vRetResult == null)
	strErrMsg = ST.getErrMsg();
	
String[] astrSemester = {"Summer","1st Sem","2nd Sem"," 3rd Sem"};

%>
<form name="form_" action="" method="post">
    <input type="hidden" name="info_index">
	<input type="hidden" name="view_details">
    <%=WI.getStrValue(strErrMsg)%> 

    <% if(vRetResult != null && vRetResult.size() > 0){%>
  <a href="javascript: CloseWindow()"><img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></p> 
  <br>
<br>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="2" class="thinborderLEFT"><div align="center"> 
          <strong>GRADE MODIFICATION DETAIL</strong></div></td>
    </tr>
    <tr> 
      <td height="20" colspan="2" class="thinborder">&nbsp;</td>
    </tr>
    <tr> 
      <td width="23%" class="thinborder">Student ID</td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(3)%></td>
    </tr>
    <tr> 
      <td  class="thinborder">Name of Student</td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(4)%></td>
    </tr>
    <tr> 
      <td  class="thinborder">Subject</td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(7)%></td>
    </tr>
    <tr> 
      <td  class="thinborder">School Year /Semester</td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(5) + "  ::  "  + astrSemester[Integer.parseInt((String)vRetResult.elementAt(6))]%></td>
    </tr>
  </table><br>
  <font size = "1">Format of Detail of Modification: <em>Grade (unit) :: Remarks</em></font> 
  <table width="100%" border="0" cellpadding="3" cellspacing="0" class="thinborder">
    <tr> 
      <td width="23%" height="26"  class="thinborder"><strong>DATE MODIFIED</strong></td>
      <td width="33%" class="thinborder"><strong>REASON</strong></td>
      <td width="44%" class="thinborder"><strong>DETAIL OF MODIFICATION</strong></td>
    </tr>
    <% for(int i = 0; i < vRetResult.size() ; i+=10){%>
    <tr> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    </tr>
    <%}%>
  </table>

  <%} // end if vretResutl%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
