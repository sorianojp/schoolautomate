<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>

<title>Archive File View Detail.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>

</head>

<script language="JavaScript">
function FocusID() {
	document.form_.record_no.focus();
}
function OpenFile() {
	var pgLoc = document.form_.archive_url.value;
	var win=window.open(pgLoc);
	win.focus();
}
function SelectURL() {
	document.form_.archive_url.select();
}
function SearchRecord() {
	var pgLoc = "./search_record.jsp?opner_info=fa_payment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,dataarchive.DAMain,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	Vector vRetResult = null;
	String strTemp = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Data Archive-View Detail","record_viewprint.jsp");
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
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Data Archive","ARCHIVE DETAILS",request.getRemoteAddr(),
															"record_viewprint.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	
DAMain dMain = new DAMain();	
//now get the information.
vRetResult = dMain.operateOnRecordEntry(dbOP,request,3);
if(vRetResult == null || vRetResult.size() ==0)
	strErrMsg = dMain.getErrMsg();

%>
<form name="form_" method="post" action="./record_viewprint.jsp">
<table width="100%" border="0" bgcolor="#A49A6A">
  <tr>
    <td height="25"><div align="center"><font color="#FFFFFF"><strong> ::: RECORD 
          VIEW/PRINTING :::</strong></font></div></td>
  </tr>
</table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
<%
if(strErrMsg != null){%>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=strErrMsg%></font></td>
    </tr>
<%}%>
    <tr> 
      <td width="22%" height="25"><strong>RECORD #</strong></td>
      <td width="20%">
<%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(17);
else	
	strTemp = WI.fillTextValue("record_no");
%>
	  <input name="record_no" type="text" size="20" maxlength="32"
	  value ="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="13%"><a href="javascript:SearchRecord();"><img src="../../images/search.gif" border="0"></a></td>
      <td width="45%"><input type="image" src="../../images/form_proceed.gif"></td>
    </tr>
    <tr> 
      <td width="22%" height="25"><strong>CATEGORY</strong></td>
      <td colspan="3">
<%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(17);
else	
	strTemp = WI.fillTextValue("catg_index");
%>	  <select name="catg_index">
          <%=dbOP.loadCombo("CATG_INDEX","CATG_NAME",
              " from DA_CATG where is_valid = 1 and is_del=0 order by catg_name",strTemp,false)%> 
     </select>
      </td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2" bgcolor="#B9B292" height="25"><div align="center"><strong><font color="#FFFFFF">PERSONAL 
          INFORMATION</font></strong></div></td>
    </tr>
    <tr> 
      <td width="22%" height="15"valign="top"><strong>ID</strong></td>
      <td width="78%" valign="top"><strong> <%=WI.getStrValue(vRetResult.elementAt(11))%></strong></td>
    </tr>
    <tr> 
      <td width="22%" height="21"valign="top"><strong>NAME (lname, fname, mname)</strong></td>
      <td valign="top"> <%=(String)vRetResult.elementAt(14)%>, <%=(String)vRetResult.elementAt(12)%>, <%=WI.getStrValue(vRetResult.elementAt(13))%></td>
    </tr>
    <tr> 
      <td width="22%" height="22" valign="top"><strong>COURSE</strong></td>
      <td valign="top"><%=WI.getStrValue(vRetResult.elementAt(18))%></td>
    </tr>
    <tr> 
      <td height="22" valign="top"><strong>MAJOR</strong></td>
      <td valign="top"><%=WI.getStrValue(vRetResult.elementAt(19))%></td>
    </tr>
    <tr> 
      <td height="22" valign="top"><strong>YEAR GRAD</strong></td>
      <td valign="top"><%=WI.getStrValue(vRetResult.elementAt(8))%></td>
    </tr>
    <tr> 
      <td height="22" valign="top"><strong>COLLEGE</strong></td>
      <td valign="top"><%=WI.getStrValue(vRetResult.elementAt(20))%></td>
    </tr>
    <tr> 
      <td height="22" valign="top"><strong>OFFICE/DEPARTMENT</strong></td>
      <td valign="top"><%=WI.getStrValue(vRetResult.elementAt(21))%></td>
    </tr>
    <tr> 
      <td colspan="2" bgcolor="#B9B292" height="25"><div align="center"><strong><font color="#FFFFFF">ARCHIVE 
          RECORD INFORMATION</font></strong></div></td>
    </tr>
    <tr> 
      <td height="22" valign="top"><strong>ARCHIVE FORMAT</strong></td>
      <td valign="top"><%=WI.getStrValue(vRetResult.elementAt(16))%></td>
    </tr>
    <tr> 
      <td height="22" valign="top"><strong>CD VOLUME #</strong></td>
      <td valign="top"><%=WI.getStrValue(vRetResult.elementAt(3))%></td>
    </tr>
    <tr> 
      <td height="22" valign="top"><strong>STORAGE LOCATION</strong></td>
      <td valign="top"><%=WI.getStrValue(vRetResult.elementAt(4))%></td>
    </tr>
    <tr> 
      <td height="22" valign="top"><strong>RECORD INFORMATION</strong></td>
      <td valign="top"><%=WI.getStrValue(vRetResult.elementAt(5))%></td>
    </tr>
    <tr> 
      <td height="22" valign="top"><strong>URL OF DOCUMENT</strong></td>
      <td valign="top"> <input name="archive_url" value="<%=WI.getStrValue(vRetResult.elementAt(22))%>" class="textbox_noborder" size="60"></td>
    </tr>
<!--
    <tr>
      <td height="22" valign="top">&nbsp;</td>
      <td valign="top"><a href="javascript:OpenFile();">
	  <img src="../../images/openfile.gif" border="0" width="34" height="37"></a>
	  Click to Open file (if Browser does not open the file, use copy URL to open file)</td>
    </tr>
-->
    <tr> 
      <td height="22" valign="top"><strong>SELECT COPY URL</strong></td>
      <td valign="top"> <a href="javascript:SelectURL();">Click to select the 
        URL.</a> Press Ctrl+C and paste in Window Explorer</td>
    </tr>
  </table>
<%}//end of vRetResult
%>
	<table width="100%" cellpadding="0" cellspacing="0" >
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
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