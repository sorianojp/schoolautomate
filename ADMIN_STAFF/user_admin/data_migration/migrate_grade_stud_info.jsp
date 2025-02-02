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
function Migrate() {
	document.form_.migrate_.value = "1";
	document.form_.hide_move.src = "../../../images/blank.gif";
	document.form_.show_data.value = "";
	this.SubmitOnce('form_');
}
function ShowData() {
	document.form_.migrate_.value = "";
	document.form_.show_data.value = "1";
	this.SubmitOnce('form_');
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector" %>
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
		//dm.cleanUP();
		return;
	}
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Data Migrate",request.getRemoteAddr(),
														"migrate_grade_stud_info.jsp");
	//iAccessLevel = 2;
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
	
	basicEdu.UserInformation dm = new basicEdu.UserInformation();
	if(WI.fillTextValue("migrate_").compareTo("1") == 0) {
		dm.migrateBasicStud(dbOP, request);
		strErrMsg = dm.getErrMsg();
	}

%>


<body>
<form name="form_" action="./migrate_grade_stud_info.jsp" method="post">
<%if(strErrMsg!= null){%><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font><br><br><br><%}%>
<p><font size="3">NOTE : <br>
    1. Import student information to a table _migrate_basic in main database. <br>
   2. Listed below are the table fields. The table fileds should match. <br>
   &nbsp;&nbsp;stud_id<br>
   &nbsp;&nbsp;entry_stat<br>
   &nbsp;&nbsp;age<br>
   &nbsp;&nbsp;fname<br>
   &nbsp;&nbsp;mname<br>
   &nbsp;&nbsp;lname<br>
   &nbsp;&nbsp;dob<br>
   &nbsp;&nbsp;gender<br>
   &nbsp;&nbsp;school_name<br>
   &nbsp;&nbsp;sy_from<br>
&nbsp;&nbsp;sy_to<br>
&nbsp;&nbsp;g_level<br>
&nbsp;&nbsp;cy_from<br>
&nbsp;&nbsp;cy_to<br>
3. Create a field err_msg (ntext) in _migrate_table<br>
4. Open table INFO_PERSONAL change the filed type of &quot;age&quot; from tinyint to float </font></p>
<p><font size="3">After 1 to 4 are done, click MOVE. <br>
    <br>
  </font><br>
</p>
<p><div align="center"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font> 
  <a href="javascript:Migrate()"><img src="../../../images/move.gif" border="0" name="hide_move"></a><font size="1">Click 
  to move/migrate information</font></div>
</p>
<input type="hidden" name="migrate_">
<input type="hidden" name="show_data">
</form>
</body>
</html>
<%
if(dbOP != null) 
	dbOP.cleanUP();
%>