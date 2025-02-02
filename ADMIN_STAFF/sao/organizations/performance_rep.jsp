<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function UpadtePerformance() {
	location = "./performance_report_update.jsp?organization_id="+
		escape(document.form_.organization_id.value);
}
function FocusID() {
	document.form_.organization_id.focus();
}
function OpenSearch() {
	var pgLoc = "../search/srch_org.jsp?opner_info=form_.organization_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp  = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","performance_rep.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs",
														"ORGANIZATIONS",request.getRemoteAddr(),
														"performance_rep.jsp");
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
Vector vRetResult = new Vector();
boolean bolNoRecord = false;
boolean bolRetainValue = false;//if it is true, use wi.fillTextValue(..);

if(WI.fillTextValue("organization_id").length() > 0){
	Organization organization = new Organization();
	vRetResult = organization.operateOnOrganization(dbOP, request,3);
	if(vRetResult == null)
		strErrMsg = organization.getErrMsg();
}
%>
<body bgcolor="#D2AE72" onLoad="FocusID()">
<form action="./performance_rep.jsp" method="post" name="form_">
<%
	strTemp = WI.fillTextValue("sy_from");
	if (strTemp.length() == 0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_sy_from");
%> 
<input type="hidden" name="sy_from" value="<%=strTemp%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          ORGANIZATIONS - PERFORMANCE REPORT PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="23%" >Organization ID number:</td>
      <td width="26%"> <input name="organization_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=WI.fillTextValue("organization_id")%>" size="25"></td>
      <td width="47%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td><input type="image" src="../../../images/form_proceed.gif"></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="27%">Organization name </td>
      <td width="68%"><strong><%=(String)vRetResult.elementAt(2)%></strong></td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>College/Department</td>
      <td><strong><%=WI.getStrValue(vRetResult.elementAt(5))%><%=WI.getStrValue((String)vRetResult.elementAt(7),"/","","")%></strong></td>
    </tr>
-->
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization description </td>
      <td><strong><%=(String)vRetResult.elementAt(11)%></strong></td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization vision </td>
      <td><strong><%=(String)vRetResult.elementAt(12)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization mission</td>
      <td><strong><%=(String)vRetResult.elementAt(13)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization adviser</td>
      <td><strong>
        <%if (vRetResult.elementAt(9)!=null){%>
        <%=(String)vRetResult.elementAt(14)%>
        <%} else {%>
        <%=(String)vRetResult.elementAt(8)%>
        <%}%>
      </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Status </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date accredited </td>
      <td><strong><%=WI.getStrValue((String)vRetResult.elementAt(3))%></strong></td>
    </tr>	
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td height="25">
	  <a href="javascript:UpadtePerformance();"><img src="../../../images/update.gif" border="0"></a>
        <font size="1">Click to create or update performance report</font></td>
    </tr>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
