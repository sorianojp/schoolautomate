<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../jscript/common.js" ></script>
<style>
.nav {
     color: #000000;
     background-color: #FFFFFF;
}
.nav-highlight {
     color: #000000;
     background-color: #FAFCDD;
}

a:link {
	color: #000000;
	text-decoration: none;
}
a:visited {
	color: #000000;
	text-decoration: none;

}
a:hover {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
a:active {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
</style>
<%@ page language="java" import="utility.*, organizer.SBEmail, java.util.Vector " %>
<%
	String strCatIndex = dbOP.mapOnetoOther("FORUM_SUB_CATG",
                                                 "SUB_CATG_INDEX", 
                                                 WI.fillTextValue("subcat_index"),
                                                 "CATG_INDEX",
                                                 " AND IS_VALID = 1");
	Vector vLinkList = myForum.operateOnSubCatMaintenance(dbOP, req, 4);
%>
<body>
<form action="./forum_cat_header.jsp" method="post" name="form_">
<table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr align="right">
		<td height="25" bgcolor="white">
		<img src="../../images/devicetab_left.gif" border="0">Subcategory 1<img src="../../images/devicetab_right.gif" border="0">
		<img src="../../images/devicetab_leftOff.gif" border="0">
		Subcategory 2
		<img src="../../images/devicetab_rightOff.gif" border="0">
		<img src="../../images/devicetab_leftOff.gif" border="0">
		Subcategory 3
		<img src="../../images/devicetab_rightOff.gif" border="0">
		</td>
	</tr>
	</table>
	<input type="hidden" name="cat_index" value="<%=WI.fillTextValue("cat_index")%>">
</form>
</body>
</html>
