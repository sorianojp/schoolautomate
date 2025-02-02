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
	{
		if(dm != null) {	
			strErrMsg = dm.getErrMsg();
			dm.cleanUP();
		}
		else 
			strErrMsg = "Error in opening connection...";
		dm = null;
		exp.printStackTrace();
		%>
		<p align="center"><%=strErrMsg%></p>
		<%
		//dm.cleanUP();
		return;
	}
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;
if(dm != null) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dm.dbOPLiveDB,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Data Migrate",request.getRemoteAddr(),
														"migrate_sub.jsp");
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
		dm.migrateSubject();
		strErrMsg = dm.getErrMsg();
	}

}
%>
<body >
<form action="./migrate_sub.jsp" method="post" name="form_">
<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%><br>


<font size="3">NOTE : To migrate, <br>
1. Create a database SB_DataMigrate (if does not exist)<br>
2. Transfer the subject table to be migrated.<br>
4. Provide sql login user name and password to access SB_DataMigrate. For example : user = sa, password = 123<br>
3. Fill up the following data.<br>
4. Subject information will be removed from SB_DataMigrate table if successfully 
migrated. <br>
5. If SB_DataMigrate is lacking any field, please leave it empty.<br>
6. Select option whether to allow duplicate subject code.<br>
<strong>7. After subject is migrated, please edit subject group, subject category and pre-requisite</strong><br><br>
<br>
</font>
  <input type="checkbox" value="1" name="allow_duplicate">
  <font color="#0000FF">Allow duplicate subject code.</font><br>
  <br>
SB_DataMigrate Database Information : <br>
Name of Table 
<input name="table_name" type="text" id="table_name" class="textbox"value="<%=WI.fillTextValue("table_name")%>" size="7" style="font-size:14px">
; User name 
<input name="user_name" type="text" class="textbox" value="<%=WI.fillTextValue("user_name")%>" size="7" style="font-size:14px">
; Password 
<input name="password" type="password" class="textbox" value="<%=WI.fillTextValue("password")%>" size="12" style="font-size:14px">
<br>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#FFFFAF"> 
    <td height="25" class="thinborder"><div align="center"><strong>FIELD NAME 
        OF SB_DATAMIGRATE TO MIGRATE</strong></div></td>
    <td class="thinborder"><strong>DATA TO MIGRATE</strong></td>
  </tr>
  <tr> 
    <td width="50%" height="25" class="thinborder"> <div align="center"> 
        <input type="text" name="sub_code" value="<%=WI.fillTextValue("sub_code")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td width="50%" class="thinborder">SUBJECT CODE</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="sub_name" value="<%=WI.fillTextValue("sub_name")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">SUBJECT TITLE</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="max_stud" value="<%=WI.fillTextValue("max_stud")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
    <td class="thinborder">MAXIMUM STUDENT REQUIRED</td>
  </tr>
  <tr> 
    <td height="25" class="thinborder"><div align="center"> 
        <input type="text" name="min_stud" value="<%=WI.fillTextValue("min_stud")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </div></td>
    <td class="thinborder">MINIMUM STUDENT REQUIRED (DISSOLVES SUBJECT)</td>
  </tr>
</table>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#FFFFAF"> 
    <td height="27" class="thinborder"><div align="center"><strong>VALID CONDITION 
        COLUMN NAME</strong></div></td>
    <td class="thinborder"><strong>VALID CONDITION VALUE</strong></td>
  </tr>
  <tr> 
    <td width="50%" height="25" class="thinborder"> <div align="center"> 
        <input name="valid_name" type="text" class="textbox" id="valid_name"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("valid_name")%>" size="32" style="font-size:14px">
      </div></td>
    <td width="50%" class="thinborder"><input name="valid_value" type="text" class="textbox" id="valid_value"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("valid_value")%>" size="16" style="font-size:14px"></td>
  </tr>
</table>
<br>
  Items with ( <font size="3"><font color="#FF0000"><strong>*</strong></font></font>) 
  are required<br>
<br>
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
	if (dm != null) 
		dm.cleanUP();
%>
