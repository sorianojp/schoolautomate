<%@ page language="java" import="utility.*,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = false;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Request Training","set_mandatory_training.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
												(String)request.getSession(false).getAttribute("userId"),
												"HR Management","TRAINING MANAGEMENT",request.getRemoteAddr(),
												"view_training_one_employee.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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

Vector vRetResult = null;
hr.HRMandatoryTrng  mt = new hr.HRMandatoryTrng();
String strEmpID = WI.fillTextValue("emp_id");
java.sql.ResultSet rs = null;
if(strEmpID.length() > 0) {
	String strEmpIndex = dbOP.mapUIDToUIndex(strEmpID);
	if(strEmpIndex == null)
		strErrMsg = "Employee ID not found.";
	else {
		String strSQLQuery = "select HR_PRELOAD_TRAINING_TYPE.training_type, HR_MAND_TRAINING_NAME.mand_training_name "+
				"from HR_MAND_TRAINING_ATTEND "+
				"join HR_MAND_TRAINING on (HR_MAND_TRAINING.training_index = HR_MAND_TRAINING_ATTEND.training_index) "+
				"join HR_MAND_TRAINING_NAME on (HR_MAND_TRAINING_NAME.mand_training_index = HR_MAND_TRAINING.mand_training_index) "+
				"join HR_PRELOAD_TRAINING_TYPE on (HR_MAND_TRAINING_NAME.training_type_index = HR_PRELOAD_TRAINING_TYPE.training_type_index) "+
				"join user_Table on (user_Table.user_index = HR_MAND_TRAINING_ATTEND.user_index) "+
				" where  HR_MAND_TRAINING_ATTEND.user_index = "+strEmpIndex;
		rs = dbOP.executeQuery(strSQLQuery);
	}
}

%>
<body>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::  TRAINING COMPLETED ::::</strong></font></div></td>
    </tr>
<%
int iRowCount = 0;
if(strErrMsg != null){%>
    <tr > 
      <td height="25" colspan="3" > &nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<%}%>
  </table>
<%if(rs != null) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" class="thinborder">
    
    <tr align="center" style="font-weight:bold"> 
      <td width="23%" height="25" class="thinborder">Training Type </td>
      <td width="63%" class="thinborder">Training Name </td>
    </tr>
<%while(rs.next()) {++iRowCount;%>    
	<tr>
      <td height="25" class="thinborder"><%=rs.getString(1)%></td>
      <td class="thinborder"><%=rs.getString(2)%></td>
    </tr>
<%}
rs.close();%>
  </table>
<%}if(iRowCount == 0){%>
	<font style="font-size:14px; font-weight:bold; color:#FF0000"><br>No Training taken</font>
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>

