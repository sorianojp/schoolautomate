<%@ page language="java" import="utility.*,osaGuidance.StudentPersonalDataCIT,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	
	//add security here.
	try	{
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
	
	//authenticate this user.
	int iAccessLevel = 2;
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1;
	else {
		strTemp = (String)request.getSession(false).getAttribute("authTypeIndex");
		if(strTemp != null && strTemp.equals("4"))
			iAccessLevel = 0;
	}
																
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student Personal Data</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">

	function UpdateAddr(strBlockIndex){
		var objCOA = "";
		strAddr = document.form_.addr.value;
		if(strAddr == '1' || strAddr == '11')
			objCOA = window.opener.document.getElementById('_res_addr');
		else if(strAddr == '2' || strAddr == '12')
			objCOA = window.opener.document.getElementById('_con_addr');
		else if(strAddr == '3' || strAddr == '13')
			objCOA = window.opener.document.getElementById('_emgn_addr');
		else if(strAddr == '4' || strAddr == '14')
			objCOA = window.opener.document.getElementById('_mail_addr');
		else if(strAddr == '5' || strAddr == '15')
			objCOA = window.opener.document.getElementById('_city_addr');
		
		this.InitXmlHttpObject2(objCOA, 2,"<img src='../../../../Ajax/ajax-loader_small_black.gif'>");//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=20402&user_ref="+document.form_.user_ref.value+"&addr="+document.form_.addr.value+"&block_ref="+strBlockIndex;
		this.processRequest(strURL);
	}
	
	
</script>
<%	
	String strUserIndex = WI.fillTextValue("user_ref");
	if(strUserIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Student reference is not found. Please close this window and click on the Part II link to try again..</p>
	<%
	dbOP.cleanUP();
	return;}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="other_info.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: CITY/TOWN - PROVINCE - ZIP CODE INFORMATION ::::</strong></font></div></td>
		</tr>
<%if(strErrMsg != null) {%>
		<tr> 
			<td width="90%" height="25"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right"></td>
		</tr>
<%}%>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr align="center" bgcolor="#CCCCCC">
			<td height="25" class="thinborder" width="50%"><strong>City/Town</strong></td>
		    <td class="thinborder" width="30%"><strong>Province</strong></td>
		    <td class="thinborder" width="10%"><strong>Zip Code </strong></td>
		    <td class="thinborder" width="10%"><strong>Update</strong></td>
		</tr>
<%
strTemp = "select BLOCK_INDEX,ZIP_CODE_INFO,TOWN_INFO,CITY_INFO from PRELOAD_ZIP order by town_info,CITY_INFO,ZIP_CODE_INFO";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
while(rs.next()) {%>
		<tr>
			<td height="20" class="thinborder"><%=rs.getString(3)%></td>
		    <td class="thinborder"><%=rs.getString(4)%></td>
		    <td class="thinborder"><%=rs.getString(2)%></td>
		    <td class="thinborder"><input type="button" value="Update" onClick="UpdateAddr('<%=rs.getString(1)%>')"></td>
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
	
	<input type="hidden" name="user_ref" value="<%=strUserIndex%>">
	<input type="hidden" name="addr" value="<%=WI.fillTextValue("addr")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>