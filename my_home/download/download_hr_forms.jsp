<%@ page language="java" import="utility.*, java.util.Vector, hr.HRDownloadMgmt"%>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Link Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-ESS-Download Files","download_hr_forms.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}	
	
	Vector vFiles = null;
	HRDownloadMgmt downloadMgmt = new HRDownloadMgmt();	
	Vector vRetResult = downloadMgmt.getDownloadableForms(dbOP, request);
	if(vRetResult == null)
		strErrMsg = downloadMgmt.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="download_hr_forms.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" align="center" class="footerDynamic">
				<font color="#FFFFFF"><strong>:::: DOWNLOAD  FORMS ::::</strong></font></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<%	for(int i = 0; i < vRetResult.size(); i+=3){
				vFiles = (Vector)vRetResult.elementAt(i+2);	
		%>
		<tr>
			<td height="25" class="thinborder" colspan="3">&nbsp;<strong><%=(String)vRetResult.elementAt(i+1)%></strong></td>
		</tr>
		<%for(int j = 0; j < vFiles.size(); j++){%>
		<tr>
			<td height="25" class="thinborder" width="3%">&nbsp;</td>
		    <td class="thinborderBOTTOM" width="87%">&nbsp;<%=(String)vFiles.elementAt(j)%></td>
		    <td align="center" class="thinborder" width="10%">
				<a href="../../download/<%=(String)vFiles.elementAt(j)%>"><img src="../../images/download.gif" border="0"></a></td>
		</tr>
		<%}}%>
	</table>
<%}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>