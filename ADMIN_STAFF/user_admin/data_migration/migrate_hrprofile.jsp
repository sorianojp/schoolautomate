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
	DataMigrate dm = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		if (WI.fillTextValue("user_name").length() > 0 && WI.fillTextValue("table_name").length() > 0){
			dm = new DataMigrate(request);
		}
		else {
			strErrMsg = "Please enter all database information.";
		}
	}
	catch(Exception exp)
	{	if(dm != null)
			dm.cleanUP();
		dm = null;
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		//dm.cleanUP();
		return;
	}
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;
if(dm != null) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dm.dbOPLiveDB,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Data Migrate",request.getRemoteAddr(),
														"migrate_hrprofile.jsp");
	//iAccessLevel = 2;
	if(iAccessLevel == -1)//for fatal error.
	{
		dm.dbOPLiveDB.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)
	{
		dm.dbOPLiveDB.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	if(WI.fillTextValue("migrate_").compareTo("1") == 0) {
		dm.migrateHRProfile();
		strErrMsg = dm.getErrMsg();
	}

}
%>


<body>
<form name="form_" action="./migrate_hrprofile.jsp" method="post">
<%if(strErrMsg!= null){%><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font><br><br><br><%}%>
  <p><font size="3">NOTE : To migrate HR PROFILE, <br>
    1. Create a database SB_DataMigrate (if does not exist)<br>
    2. Transfer the hr profile table to be migrated.<br>
    4. Provide sql login user name and password to access SB_DataMigrate. For 
    example : user = sa, password = 123<br>
    3. Fill up the following data.<br>
    5. If SB_DataMigrate is lacking any filed, please leave it empty.<br>
    6. To migrate only employment type and Employment status, enter only emp type 
    and/or emp status field value.<br>
    7. To migrate employee information <font color="#FF0000"><strong>*</strong></font> 
    values are must.<br>
    8. If gender is not selected, male will be inserted into database.<br>
    9. If a valid date value is not found, null value will be inserted.</font><font size="3"><br>
    <br>
    <br>
    </font> SB_DataMigrate Database Information : <br>
    Name of Table 
    <input type="text" name="table_name" value="<%=WI.fillTextValue("table_name")%>" size="7" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    ; User name 
    <input type="text" name="user_name" value="<%=WI.fillTextValue("user_name")%>" size="7" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    ; Password 
    <input type="password" name="password" value="<%=WI.fillTextValue("password")%>" size="12" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    <br>
    <br>
<%
strTemp = WI.fillTextValue("force_update");
if(strTemp.length() > 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>    <input type="checkbox" name="force_upate" value="1"<%=strTemp%>>
    <strong>Update profile if exists</strong><br>
  </p>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#FFFFAF"> 
    <td height="25" class="thinborder"><div align="center"><strong>FIELD NAME 
        OF SB_DATAMIGRATE TO MIGRATE</strong></div></td>
    <td class="thinborder"><strong>DATA TO MIGRATE</strong></td>
  </tr>
  <tr> 
    <td width="37%" height="25" class="thinborder"> <div align="center"> 
        <input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
    <td width="63%" class="thinborder">EMPLOYEE ID</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
    <td class="thinborder">FIRST NAME</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="mname" value="<%=WI.fillTextValue("mname")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
    <td class="thinborder">MIDDLE NAME</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
    <td class="thinborder">LAST NAME</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="gender" value="<%=WI.fillTextValue("gender")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
      <td class="thinborder">GENDER (INDICATE WHAT MALE STANDS FOR) 
        <select name="gender_map" style="font-size:10px;font-weight:bold">
        <option value="M">M</option>
        <option value="Male">Male</option>
        <option value="0">0</option>
        <option value="1">1</option>
      </select>
    </td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="dob_" value="<%=WI.fillTextValue("dob_")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
      <td class="thinborder">DATE OF BIRTH (source data type 
	  <select name="dob_dtype" style="font-size:9px;font-weight:bold">
	  <option value="1">Date</option>
<%
strTemp = WI.fillTextValue("dob_dtype");
if(strTemp.compareTo("2") == 0) {%>	  
	  <option value="2" selected>Charater(YYYY/MM/DD)</option>
<%}else{%>
	  <option value="2">Charater(YYYY/MM/DD)</option>
<%}if(strTemp.compareTo("3") == 0) {%>
	  <option value="3" selected>Charater(MM/YYYY/DD)</option>
<%}else{%>
	  <option value="3">Charater(MM/YYYY/DD)</option>
<%}if(strTemp.compareTo("4") == 0) {%>
	  <option value="4" selected>Charater(DD/MM/YYYY)</option>
<%}else{%>
	  <option value="4">Charater(DD/MM/YYYY)</option>
<%}%>	  </select>) </td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="doe_" value="<%=WI.fillTextValue("doe_")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
      <td class="thinborder">DATE OF EMPLOYMENT (source data type 
        <select name="doe_dtype" style="font-size:9px;font-weight:bold">
          <option value="1">Date</option>
          <%
strTemp = WI.fillTextValue("doe_dtype");
if(strTemp.compareTo("2") == 0) {%>
          <option value="2" selected>Charater(YYYY/MM/DD)</option>
          <%}else{%>
          <option value="2">Charater(YYYY/MM/DD)</option>
          <%}if(strTemp.compareTo("3") == 0) {%>
          <option value="3" selected>Charater(MM/YYYY/DD)</option>
          <%}else{%>
          <option value="3">Charater(MM/YYYY/DD)</option>
          <%}if(strTemp.compareTo("4") == 0) {%>
          <option value="4" selected>Charater(DD/MM/YYYY)</option>
          <%}else{%>
          <option value="4">Charater(DD/MM/YYYY)</option>
          <%}%>
        </select>) </td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="con_number" value="<%=WI.fillTextValue("con_number")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
    <td class="thinborder">CONTACT NUMBER(CURRENT CONTACT NUMBER)</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="con_addr" value="<%=WI.fillTextValue("con_addr")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
    <td class="thinborder">ADDRESS (CURRENT CONTACT ADDR)</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="emp_type" value="<%=WI.fillTextValue("emp_type")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
    <td class="thinborder">EMPLOYMENT TYPE</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="cur_stat" value="<%=WI.fillTextValue("cur_stat")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
    <td class="thinborder">EMPLOYMENT STATUS</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="college" value="<%=WI.fillTextValue("college")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
    <td class="thinborder">COLLEGE (NAME OF COLLEGE)</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="dept" value="<%=WI.fillTextValue("dept")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
    <td class="thinborder">DEPARTMENT (NAME OF DEPARTMENT)</td>
  </tr>
</table><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#FFFFAF"> 
    <td height="25" class="thinborder"><div align="center"><strong>VALID CONDITION 
        COLUMN NAME</strong></div></td>
    <td class="thinborder"><strong>VALID CONDITION COLUMN VALUE</strong></td>
  </tr>
  <tr> 
    <td width="50%" height="25" class="thinborder"> <div align="center"> 
        <input type="text" name="valid_name" value="<%=WI.fillTextValue("valid_name")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
    <td width="50%" class="thinborder"><input type="text" name="valid_value" value="<%=WI.fillTextValue("valid_value")%>" size="32" 
	class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  </tr>
</table>

<p>
<div align="center"><a href="#"><img src="../../../images/online_help.gif" border="0"></a><font size="1"> 
  Click to view datas not yet migrated&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font> 
  <a href="javascript:Migrate()"><img src="../../../images/move.gif" border="0" name="hide_move"></a><font size="1">Click 
  to move/migrate information</font></div>
</p>
<input type="hidden" name="migrate_">
<input type="hidden" name="show_data">
</form>
</body>
</html>
<%
if(dm != null) 
	dm.cleanUP();
%>