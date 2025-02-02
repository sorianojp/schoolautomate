<%@ page language="java" import="utility.*,search.SearchStudent,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

	//I have to make sure per logged in with correct ID.
	String strSQLQuery = null;
	java.sql.PreparedStatement pstmt;
	String strPassword = WI.fillTextValue("password");
	String strUserID   = WI.fillTextValue("login_id");
	java.sql.ResultSet rs = null;
	
	boolean bolLoggedIn = false;
	
	strErrMsg = null;
	if(strUserID.length() >0 && strPassword.length() >0 ) {
		strSQLQuery = "select password from login_info where user_id = ? and is_valid = 1 and (expire_date is null or expire_date >='"+
			WI.getTodaysDate()+"')";
		pstmt = dbOP.getPreparedStatement(strSQLQuery);
		pstmt.setString(1, strUserID);
		rs = pstmt.executeQuery();
		
		String strPwdInDB = null;
		if(rs.next())
			strPwdInDB = rs.getString(1);
		rs.close();
		if(strPwdInDB == null || !strPwdInDB.equals(strPassword)) {
			strErrMsg = "Wrong user ID / Passwrod.";
		}
		else 
			bolLoggedIn = true;
		if(WI.fillTextValue("sy_to").length() == 0) 
			strErrMsg = "Please enter SY/Term Info.";
	}

boolean bolIsEmployee = WI.fillTextValue("search_employee").equals("checked");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../jscript/common.js"></script>
<script language="JavaScript">
function FocusID() {
	if(document.form_.login_id.value.length == 0) 
		document.form_.login_id.focus();
	else
		document.form_.emp_id.focus();
	
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<form action="./generic_search.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SEARCH STUDENT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Login ID : <input type="password" name="login_id" value="<%=WI.fillTextValue("login_id")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
	  Password : <input type="password" name="password" value="<%=WI.fillTextValue("password")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%">Last Name or ID </td>
      <td width="33%"><input type="text" name="id_" value="<%=WI.fillTextValue("id_")%>" class="textbox" size="36" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="49%">
	  <input type="checkbox" name="search_employee" value="checked" <%=WI.fillTextValue("search_employee")%> onClick="document.form_.submit();"> Search Employee (uncheck to search student)
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY/Term Enrolled </td>
      <td>
<%
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else	
	strTemp = WI.fillTextValue("sy_from");
if(strTemp != null && strTemp.length() != 4)
	strTemp = "";
%>
	  <input name="sy_from" type="text" size="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="ChkShowOnlyEnrolled(); style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' maxlength=4>
        to 
<%
if(strTemp != null && strTemp.length() > 0) 
	strTemp = Integer.toString(Integer.parseInt(strTemp) + 1) ;
else	
	strTemp = "";
%>
      <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly> &nbsp;&nbsp; <select name="semester">
          <option value="">N/A</option>
 <%
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
else	
	strTemp = WI.fillTextValue("semester");
if(strTemp == null)
	strTemp = "";
		
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
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
	  </td>
      <td><input type="submit" name="_" value="Search <%if(bolIsEmployee){%>Employee<%}else{%>Student<%}%>"></td>
    </tr>
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="27%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="34%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%	if(bolLoggedIn && strErrMsg == null) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="66%" ></td>
    </tr>
  </table>
<%
strSQLQuery = WI.fillTextValue("id_");
strSQLQuery = ConversionTable.replaceString(strSQLQuery, "'", "''");
if(strSQLQuery != null && strSQLQuery.length() > 0)
	strSQLQuery = " and (lname like '"+strSQLQuery+"%' or id_number like '"+strSQLQuery+"%')";

int iCount = 0;

if(!bolIsEmployee) {
		//I have to search.. 
		strSQLQuery += " and stud_curriculum_hist.sy_from ="+WI.fillTextValue("sy_from")+" and stud_curriculum_hist.semester = "+WI.fillTextValue("semester");
		
		strSQLQuery = "select id_number, lname, fname, mname, course_offered.course_code, major.course_code, year_level,"+
						"DOB, contact_mob_no,emgn_per_name, emgn_house_no, emgn_city, emgn_provience, emgn_country,emgn_zip, emgn_tel "+
						"from stud_curriculum_hist "+
						"join user_table on (stud_curriculum_hist.user_index = user_table.user_index) "+
						"join info_personal on (info_personal.user_index = stud_curriculum_hist.user_index) "+
						"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
						"left join major on (major.major_index = stud_curriculum_hist.major_index) "+
						"left join info_contact on (info_contact.user_index = stud_curriculum_hist.user_index) "+
						"where stud_curriculum_hist.is_valid = 1 and user_table.is_valid = 1  "+strSQLQuery+
						" order by lname, fname ";
		rs = dbOP.executeQuery(strSQLQuery);
		
%>
	<table  bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0" class="thinborder">
		<tr>
		  <td  width="4%" class="thinborder" align="center" style="font-weight:bold">SL No </td> 
		  <td  width="10%" height="25" class="thinborder"><div align="center"><strong><font size="1">Student ID</font></strong></div></td>
		  <td width="10%" class="thinborder"><div align="center"><strong><font size="1">Last Name</font></strong></div></td>
		  <td width="10%" class="thinborder"><div align="center"><strong><font size="1">First Name</font></strong></div></td>
		  <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Middle Name</font></strong></div></td>
		  <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Course Code</font></strong></div></td>
		  <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Major Code</font></strong></div></td>
		  <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Year Level</font></strong></div></td>
		  <td width="5%" class="thinborder"><div align="center"><strong><font size="1">DOB</font></strong></div></td>
		  <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Contact Mobile</font></strong></div></td>
		  <td width="10%" class="thinborder"><div align="center"><strong><font size="1">Emergency Contact Name</font></strong></div></td>
		  <td width="25%" class="thinborder"><div align="center"><strong><font size="1">Emergency Address</font></strong></div></td>
		</tr>
	<%
	while(rs.next()){
	strSQLQuery = rs.getString(1);
	strTemp = rs.getString(11);//emgn_house_no
	if(strTemp != null && strTemp.length() > 0)
		strTemp = strTemp + ",";
	else
		strTemp = "";
	strTemp += WI.getStrValue(rs.getString(12));//emgn_city
	strTemp += WI.getStrValue(rs.getString(13),",","","");//emgn_provience
	strTemp += WI.getStrValue(rs.getString(14),"<br>","","");//emgn_country
	strTemp += WI.getStrValue(rs.getString(15),"-","","");//emgn_zip
	strTemp += WI.getStrValue(rs.getString(16),"<br>","","");//emgn_tel
	
	
	%>
		<tr>
		  <td class="thinborder"><%=++iCount%>.</td>
		  <td height="25" class="thinborder"><%=strSQLQuery%></td>
		  <td class="thinborder"><%=WI.getStrValue(rs.getString(2), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(rs.getString(3), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(rs.getString(4), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(rs.getString(5), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(rs.getString(6), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(rs.getString(7), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(ConversionTable.convertMMDDYYYY(rs.getDate(8), true), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(rs.getString(9), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(rs.getString(10), "&nbsp;")%></td>
		  <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		</tr>
	<%}
	rs.close();%>
  </table>
<%}else{
	strSQLQuery = "select id_number, user_table.lname, user_table.fname, user_table.mname, c_name, d_name, emp_type_name, blood_group,sss_number, tin,"+
					"contact_name, contact_no_mob,address from user_table "+
					"join info_faculty_basic on (info_Faculty_basic.user_index = user_table.user_index) "+ 
					"left join college on (college.c_index = info_faculty_basic.c_index) "+
					"left join department on (department.d_index = info_faculty_basic.d_index) "+
					"join HR_EMPLOYMENT_TYPE on (HR_EMPLOYMENT_TYPE.emp_type_index = info_faculty_basic.emp_type_index) "+
					"join HR_INFO_PERSONAL on (HR_INFO_PERSONAL.user_index = user_table.user_index) "+
					"left join HR_INFO_CON_EMER on (HR_INFO_CON_EMER.user_index = user_table.user_index) where user_table.is_valid = 1 and "+
					"info_faculty_basic.is_valid = 1 and HR_INFO_PERSONAL.is_valid = 1 and (HR_INFO_CON_EMER.is_valid is null or HR_INFO_CON_EMER.is_valid = 1) "+
					strSQLQuery+" order by user_table.lname, user_table.fname";
	rs = dbOP.executeQuery(strSQLQuery);
	%>
	<table  bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr style="font-weight:bold">
      <td  width="4%" class="thinborder" align="center" style="font-weight:bold">SL No </td> 
      <td  width="10%" height="25" class="thinborder" style="font-size:9px" align="center">Employee ID</td>
      <td width="10%" class="thinborder" style="font-size:9px" align="center">Last Name</td>
      <td width="10%" class="thinborder" style="font-size:9px" align="center">First Name</td>
      <td width="5%" class="thinborder" style="font-size:9px" align="center">Middle Name</td>
      <td width="5%" class="thinborder" style="font-size:9px" align="center">College</td>
      <td width="5%" class="thinborder" style="font-size:9px" align="center">Department</td>
      <td width="5%" class="thinborder" style="font-size:9px" align="center">Designation</td>
      <td width="5%" class="thinborder" style="font-size:9px" align="center">Blood Group </td>
      <td width="5%" class="thinborder" style="font-size:9px" align="center">SSS</td>
      <td width="5%" class="thinborder" style="font-size:9px" align="center">TIN</td>
      <td width="5%" class="thinborder" style="font-size:9px" align="center">Contact Mobile</td>
      <td width="10%" class="thinborder" style="font-size:9px" align="center">Emergency Contact Name</td>
      <td width="25%" class="thinborder" style="font-size:9px" align="center">Emergency Address</td>
    </tr>
<%
iCount = 0;
while(rs.next()){
	strSQLQuery = "select id_number, user_table.lname, user_table.fname, user_table.mname, c_name, d_name, emp_type_name, blood_group,sss_number, tin,"+
					"contact_no_mob,contact_name, address from user_table "+
					"join info_faculty_basic on (info_Faculty_basic.user_index = user_table.user_index) "+ 
					"left join college on (college.c_index = info_faculty_basic.c_index) "+
					"left join department on (department.d_index = info_faculty_basic.d_index) "+
					"join HR_EMPLOYMENT_TYPE on (HR_EMPLOYMENT_TYPE.emp_type_index = info_faculty_basic.emp_type_index) "+
					"join HR_INFO_PERSONAL on (HR_INFO_PERSONAL.user_index = user_table.user_index) "+
					"left join HR_INFO_CON_EMER on (HR_INFO_CON_EMER.user_index = user_table.user_index) where user_table.is_valid = 1 and "+
					"info_faculty_basic.is_valid = 1 and HR_INFO_PERSONAL.is_valid = 1 and (HR_INFO_CON_EMER.is_valid is null or HR_INFO_CON_EMER.is_valid = 1) "+
					strSQLQuery+" order by user_table.lname, user_table.fname";

%>
    <tr>
      <td class="thinborder"><%=++iCount%>.</td>
      <td height="25" class="thinborder"><%=WI.getStrValue(rs.getString(1), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(2), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(3), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(4), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(5), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(6), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(7), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(8), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(9), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(10), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(11), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(12), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(rs.getString(13), "&nbsp;")%></td>
    </tr>
<%}
rs.close();%>
  </table>
<%}//show only if employee.. %>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25"><div align="right"> </div></td>
      <td width="31%">&nbsp;</td>
    </tr>
  </table>
<%}//if there is any data .. %>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
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