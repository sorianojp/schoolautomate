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
														"migrate_studledger.jsp");
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
		dm.migrateLedger();
		strErrMsg = dm.getErrMsg();
	}

}
%>


<body>
<form name="form_" action="./migrate_studledger.jsp" method="post">
<%if(strErrMsg!= null){%><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font><br><br><br><%}%>
  <p><font size="3">NOTE : <br>
    1. Create all student IDs before migrating.<br>
    2. All informations left in database after migration are not migrated due 
    to error. Error messages will be included in migration status message.<br></font> 
    <br>
  </p><br>
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
  </p>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="25" class="thinborder"><div align="center"><strong>FIELD NAME 
          OF SB_DATAMIGRATE TO MIGRATE</strong></div></td>
      <td class="thinborder"><strong>DATA TO MIGRATE</strong></td>
    </tr>
    <tr> 
      <td width="37%" height="25" class="thinborder"> <div align="center"> 
          <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td width="63%" class="thinborder">STUD ID</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">SCHOOL YEAR FROM</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">SCHOOL YEAR TO</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="semester" value="<%=WI.fillTextValue("semester")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">SEMESTER</td>
    </tr>
    <tr> 
    
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="trans_type" value="<%=WI.fillTextValue("trans_type")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">TRANSACTION TYPE (INDICATE WHAT STANDS FOR CREDIT) 
        <select name="credit_map" style="font-size:10px;font-weight:bold">
          <option value="c">Starts with C</option>
          <option value="0">0</option>
          <option value="1">1</option>
        </select> </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="trans_date" value="<%=WI.fillTextValue("trans_date")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">TRANSACTION DATE (must be a smalldatetime field)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="trans_name" value="<%=WI.fillTextValue("trans_name")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">TRANSACTION NAME</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="or_number" value="<%=WI.fillTextValue("or_number")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">OR NUMBER</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="amount" value="<%=WI.fillTextValue("amount")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">AMOUNT</td>
    </tr>


  </table>
<p>
<div align="center"><a href="#"><img src="../../../images/online_help.gif" border="0"></a><font size="1"> 
  Click to view data not yet migrated&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font> 
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