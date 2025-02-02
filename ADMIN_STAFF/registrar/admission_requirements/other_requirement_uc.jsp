<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;

	document.form_.submit();
}


</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,sap.Configuration,java.util.Vector" %>
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
		return;
	}
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","ADMISSION REQUIREMENTS",request.getRemoteAddr(),
														"other_requirement_uc.jsp");
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

Vector vRetResult     = new Vector();
java.sql.ResultSet rs = null;
String strSQLQuery    = null;
strTemp = WI.fillTextValue("page_action");

if(strTemp.length() > 0) {
	if(strTemp.equals("1"))
		strSQLQuery = "insert into NA_ADMISSION_REQ_OTHER_UC (requirement_other) values ("+WI.getInsertValueForDB(WI.fillTextValue("requirement_"), true, null)+")";
	else	
		strSQLQuery = "delete from NA_ADMISSION_REQ_OTHER_UC where other_req_index = "+WI.fillTextValue("info_index");
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
}
strSQLQuery = "select other_req_index, requirement_other from NA_ADMISSION_REQ_OTHER_UC order by requirement_other";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vRetResult.addElement(rs.getString(1));
	vRetResult.addElement(rs.getString(2));
}
rs.close();
%>


<form name="form_" action="./other_requirement_uc.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: SET REQUIREMENT AS OTHER REQUIREMENT ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%">Requirement</td>
      <td colspan="3">
		<select name="requirement_">
          <%=dbOP.loadCombo("distinct NA_ADMISSION_REQ.requirement","NA_ADMISSION_REQ.requirement", " from NA_ADMISSION_REQ where is_valid = 1 and show_in_tor = 0 and not exists (select * from na_admission_req_other_uc where requirement_other = NA_ADMISSION_REQ.requirement) order by NA_ADMISSION_REQ.requirement", WI.fillTextValue("requirement_"),false)%> 
		</select>	  </td>
    </tr>
    <tr>
      <td height="45">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td width="31%" align="center"><input type="submit" name="122" value="Set as Other Requirement" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='1';"></td>
      <td width="41%" align="center">&nbsp;</td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr bgcolor="#CCCCCC" style="font-weight:bold">
		<td height="22" class="thinborder" width="10%">Count#</td>
		<td width="79%" class="thinborder">Other Requirement </td>
		<td width="11%" align="center" class="thinborder">Delete</td>
  	</tr>
	<%
	int iCount = 0;
	while(vRetResult.size() > 0) {%>
		<tr>
		  <td height="22" class="thinborder"><%=++iCount%></td>
		  <td class="thinborder"><%=vRetResult.remove(1)%></td>
		  <td align="center" class="thinborder">
		  <a href="javascript:PageAction('<%=vRetResult.remove(0)%>','0');"><input type="button" name="_" value="Delete" border="0"></a>
		  </td>
    	</tr>
	<%}%>
  </table>
  
 
  
  
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
