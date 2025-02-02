<%@ page language="java" import="utility.*,enrollment.FacultyEvaluation, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;
	document.form_.submit();
}
function focusID() {
	document.form_.sub_code.focus();
	document.form_.sub_code.select();
}
function PreparedToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.preparedToEdit.value = '1';
	document.form_.submit();
}
//ajax here.. 
function AjaxUpdateStat(strSubIndex) {
	var objCOAInput = document.getElementById(strSubIndex);
			
	this.InitXmlHttpObject2(objCOAInput, 2, "<img src='../../../Ajax/ajax-loader_small_black.gif'>");//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=212&subject="+strSubIndex;

	this.processRequest(strURL);
}
function CallOnLoad() {
	document.all.processing.style.visibility='hidden';	
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();CallOnLoad();">
<%
	String strErrMsg = null;
	String strTemp = null;
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling-Faculty Evaluation-Manage Subject","manage_eval_subject.jsp");
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
														"Guidance & Counseling","FACULTY EVALUATION",request.getRemoteAddr(),
														"manage_eval_subject.jsp");
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
<form action="./manage_eval_subject.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
<!-- Printing information. -->
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>
			
			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: MANAGE SUBJECTS FOR EVALUATION ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="3" style="font-weight:bold; font-size:11px; color:#0000FF">
<%
strTemp = WI.fillTextValue("show_con");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>	  <input type="radio" name="show_con" value="0" <%=strErrMsg%> onClick="document.form_.submit();"> Show All subject 
<%
if(strTemp.equals("1"))
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value="1" <%=strErrMsg%> onClick="document.form_.submit();"> Show Subjects set for Evaluation 
<%
if(strTemp.equals("2"))
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value="2" <%=strErrMsg%> onClick="document.form_.submit();"> Show Subjects not set for evaluation	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="26%">Subject code starts with - </td>
      <td width="23%">
	  <input type="text" name="sub_code" value="<%=WI.fillTextValue("sub_code")%>" class="textbox" style="font-size:11px;" size="24"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="64"></td>
      <td width="48%"><input type="submit" name="1" value="&nbsp;&nbsp; Refresh Page &nbsp;&nbsp;" style="font-size:11px; height:22px;border: 1px solid #FF0000;"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="55%" colspan="2" align="center">&nbsp;</td>
      <td width="34%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="136%" height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SUBJECT LIST IN DATABASE </font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="11%" height="25" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Subject code </td>
      <td width="77%" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Subject Description </td>
      <td width="12%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Toggle </td>
    </tr>
<%//System.out.println(vRetResult);
String strSQLQuery = "select sub_code, sub_name, is_fac_eval,sub_index from subject where is_del = 0";
strTemp = WI.fillTextValue("show_con");
if(strTemp.equals("1")) //subjects with eval
	strSQLQuery += " and is_fac_eval = 1";
else if(strTemp.equals("2"))//subjects without eval.
		strSQLQuery += " and is_fac_eval = 0";
strTemp = WI.fillTextValue("sub_code");
if(strTemp.length() >0) 
	strSQLQuery += " and sub_code like '"+strTemp+"%'";

strSQLQuery += " order by sub_code,sub_name";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()){
strTemp = rs.getString(3);
if(strTemp.equals("1"))
	strTemp = "#CCCCCC";
else	
	strTemp = "#FFFFFF";
%>
    <tr bgcolor="<%=strTemp%>"> 
      <td height="20" class="thinborder"><%=rs.getString(1)%></td>
      <td class="thinborder"><%=rs.getString(2)%></td>
      <td align="center" class="thinborder">
<%
strTemp = rs.getString(4);
%>	  
	  <label id="<%=strTemp%>">
	  <a href="javascript:AjaxUpdateStat('<%=strTemp%>');"><img src="../../../images/update.gif" border="0"></a>
	  </label>
	  </td>
    </tr>
<%}
rs.close();%>
  </table>
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