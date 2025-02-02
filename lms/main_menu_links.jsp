<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="./css/treelinkcss.css" rel="stylesheet" type="text/css">
<link href="./css/regmainlinkcssHEALTH.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	line-height:1.2;
}
</style>
</head>
<script language="JavaScript" type="text/JavaScript">
<!--
function NoHomeYet() {
	alert("HOME IS NOT FOUND.");
}
//-->
</script>
<body bgcolor="#006699" topmargin="0">
<%@ page language="java" import="utility.*" %>
<%
//check if user is logged in, if logged, check authentication list here and allow the authentic user to access the system.
DBOperation dbOP = null;
CommonUtil comUtil = new CommonUtil();
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strErrMsg = null;

boolean bolGrantAll = false;

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		strErrMsg = "error in opening connection.";
	}
String strSchoolCode = dbOP.getSchoolIndex();
if(strSchoolCode == null)
	strSchoolCode = "";
String strAboutLibrary = "./about_lib/about.htm";
if(strSchoolCode.startsWith("WNU"))
	strAboutLibrary = "./about_lib_001/";
	
boolean bolIsDBTC = strSchoolCode.startsWith("DBTC");

if(strUserId != null) {
	//open dbConnection here to check if user is registered already.
	if(strErrMsg == null) {
		//check if user has filled up the form.
		//check here the authentication of the user. 
		if(comUtil.IsSuperUser(dbOP,strUserId))
			bolGrantAll = true;	//grant all ;-)
	}
}
else
	strErrMsg = "";		
//System.out.println("testing : strErrMsg ="+strErrMsg);
if(strErrMsg != null && strErrMsg.length() > 0)
{%>
<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif" size="2"><b><%=strErrMsg%></b></font>
<%//System.out.println("testing");
if(dbOP != null) dbOP.cleanUP();
return;
}%>

<jsp:include page="./loginframe_inc.jsp?"></jsp:include>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td width="10%" height="28"><img src="./images/arrow_blue.gif"></td>
    <td width="90%"><a href="<%=strAboutLibrary%>" target="mainFrame" style="font-size:14px;">The Library</a></td>
  </tr>
<%
if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"LIB_Administration")){%>
  <tr> 
    <td height="28"><img src="./images/arrow_blue.gif"></td>
    <td><a href="./administration/admin_links.jsp" target="_self" style="font-size:14px;">Administration</a></td>
  </tr>
<%}if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"LIB_Cataloging")){%>
  <tr> 
    <td height="28"><img src="./images/arrow_blue.gif"></td>
    <td><a href="cataloging/cataloging_links.jsp" target="_self" style="font-size:14px;">Cataloging</a></td>
  </tr>
<%}if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"LIB_Circulation")){%>
  <tr> 
    <td height="28"><img src="./images/arrow_blue.gif"></td>
    <td><a href="circulation/circulation_links.jsp" style="font-size:14px;">Circulation</a></td>
  </tr>
<%}if(false) //no need to have inventory. moved to catalogging inventory.
if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"LIB_Inventory")){%>
  <tr> 
    <td height="28"><img src="./images/arrow_blue.gif"></td>
    <td><a href="./inventory/inventory_links.htm" style="font-size:14px;">Inventory</a></td>
  </tr>
<%}if(!strSchoolCode.startsWith("CGH") && !strSchoolCode.startsWith("UDMC"))
if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"LIB_Acquisition")){%>
  <tr> 
    <td height="28"><img src="./images/arrow_blue.gif"></td>
    <td><a href="./acquisition/summary.jsp" style="font-size:14px;" target="mainFrame">Acquisition</a></td>
  </tr>
<%}%>
  <tr> 
    <td height="28"><img src="./images/arrow_blue.gif"></td>
    <td><a href="search/search_opac.jsp" target="mainFrame" style="font-size:14px;">OPAC</a></td>
  </tr>
  <tr> 
    <td height="28"><img src="./images/arrow_blue.gif"></td>
    <td><a href="recommend/recommend_create.jsp" target="mainFrame" style="font-size:14px;">Recommend Collection</a></td>
  </tr>
<%if(bolGrantAll || comUtil.IsAuthorizedModule(dbOP,strUserId,"LIB_Library Attendance")){%>
  <tr>
    <td height="28"><img src="./images/arrow_blue.gif"></td>
    <td><a href="lib_attendance/lib_attendance_links.jsp" target="_self" style="font-size:14px;">Library Attendance </a></td>
  </tr>
<%}%>
  <tr> 
    <td height="28"><img src="./images/arrow_blue.gif"></td>
    <td><a href="links/show_links.jsp" target="mainFrame" style="font-size:14px;">Links</a></td>
  </tr>
<%if(strUserId != null) {%>
  <tr>
    <td height="28"><img src="./images/arrow_blue.gif"></td>
    <td><a href="./patron_info/patron_summary.jsp?myhome=1" target="mainFrame" style="font-size:14px;">My Home </a></td>
  </tr>
<%}%>
</table>
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>