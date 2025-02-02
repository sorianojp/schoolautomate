<%
	WebInterface WI   = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
	String strTemp    = null;

	String strSubSecIndex = WI.fillTextValue("section");
	String strPmtSchIndex = WI.fillTextValue("pmt_sch");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//all about ajax - to display student list with same name.
function unlockGrade(strLabelID, strGSRef) {
		var objCOAInput = document.getElementById(strLabelID);
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=217&gs_ref="+strGSRef+"&pmt_sch=<%=strPmtSchIndex%>";

		this.processRequest(strURL);
}
// end ajax
</script>


<body bgcolor="#D2AE72">
<form name="form_" action="" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;

	int j = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet_encode_unlock_one.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(),
									null);
}

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



%>
<input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF"><strong>:::: GRADE SHEETS UNLOCKING PAGE ::::</strong></font></div></td>
    </tr>
<%if(strErrMsg != null) {%>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;<strong><font size="3" color="#FF0000">
	  <%=WI.getStrValue(strErrMsg,"Error Message: ","","")%></font></strong></td>
    </tr>
<%}%>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold" align="center">
	  <td height="25" width="18%" class="thinborder" bgcolor="#66CCFF"> ID Number </td>
      <td width="25%" class="thinborder" bgcolor="#66CCFF"> Student Name </td>
      <td width="10%" class="thinborder" bgcolor="#66CCFF">Force Un Lock </td>
    </tr>

<%
String strSQLQuery = null;
if(strPmtSchIndex.equals("3"))
	strSQLQuery = "g_sheet_final";
else	
	strSQLQuery = "grade_sheet";
strSQLQuery = "select gs_index, FORCE_LOCK_STAT, id_number, fname, mname, lname from "+strSQLQuery+
				" join user_table on (user_table.user_index = user_index_) "+
				" where "+strSQLQuery+".is_valid = 1 and sub_sec_index = "+strSubSecIndex;

boolean bolIsForcedUnlock = false;

java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
if(rs.getInt(2) == 2)
	bolIsForcedUnlock = true;
else	
	bolIsForcedUnlock = false;
%>
    <tr>
      <td class="thinborder"><%=rs.getString(3)%></td>
      <td class="thinborder"><%=WebInterface.formatName(rs.getString(4),rs.getString(5),rs.getString(6),4)%></td>
      <td class="thinborder"><label id="<%=rs.getString(1)%>" style="font-weight:bold; font-size:9px; color:#FF0000"></label>
	  	<%if(!bolIsForcedUnlock) {%>
		  	<input type="button" value="UnLock" name="_" style="font-size:11px; height:22px; width:60px; border: 1px solid #FF0000;" onClick="unlockGrade('<%=rs.getString(1)%>','<%=rs.getString(1)%>');">
		<%}%>
	  </td>
    </tr>
<%}
rs.close();%>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
