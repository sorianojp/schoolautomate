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
														"migrate_enrollment.jsp");
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
	
	DataMigrate dm = new DataMigrate();
	if(WI.fillTextValue("migrate_").compareTo("1") == 0) {
		dm.migrateEnrollmentData(dbOP, request);
		strErrMsg = dm.getErrMsg();
	}

%>


<body>
<form name="form_" action="./migrate_enrollment.jsp" method="post">
<%if(strErrMsg!= null){%><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font><br><br><br><%}%>

SY From/To - Semester : <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        to
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp; <select name="semester">
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
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
        </select> 

  <p><font size="3">NOTE : <br>
    1. Two table _enrolldata_pmt and _enrolldata_sub must be available in main table <br>
   2. Listed below are the table fields.<br>
   <b>_enrolldata_pmt</b> <br>
   &nbsp;&nbsp;student_no<br>
   &nbsp;&nbsp;downpayment<br>
   &nbsp;&nbsp;or_num<br>
   &nbsp;&nbsp;payment_date<br>
   <br><br>
    <b>_enrolldata_sub</b> <br>
   &nbsp;&nbsp;student_no<br>
   &nbsp;&nbsp;section_name<br>
   &nbsp;&nbsp;subject_code<br>
   &nbsp;&nbsp;subject_name<br>
   &nbsp;&nbsp;units<br>
   &nbsp;&nbsp;nstp_val<br>
  
  
  <br><br><br>
  Total Students to Migrate : <%=dbOP.getResultOfAQuery("select count(*) from _enrolldata_pmt", 0)%> 
  <br><br>
  Total Subjects to Migrate : <%=dbOP.getResultOfAQuery("select count(*) from _enrolldata_sub", 0)%>
  
  </font><br>
    <br>
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