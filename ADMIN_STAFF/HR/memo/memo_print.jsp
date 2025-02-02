<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Create Memo Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<% 
	String strErrMsg = null;
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{		
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Memo Management-Create Memo Details","memo_print.jsp");
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

	Vector vRetResult = null;
	hr.HRMemoManagement  mt = new hr.HRMemoManagement();

	vRetResult = mt.operateOnMemoDetails(dbOP, request,3);
	if(vRetResult == null)
		strErrMsg = mt.getErrMsg();
	else
		vRetResult.remove(0);
%>
<body onLoad="window.print();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td align="center"><strong>:::: MEMO DETAILS ::::</strong></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strErrMsg != null) {%>
  	<tr > 
      <td width="2%" height="25" >&nbsp;</td>
      <td width="98%" height="25" colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
<%dbOP.cleanUP();return;}%>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25" align="right" style="font-size:9px;">Date Time Printed: <%=WI.getTodaysDateTime()%></td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td width="18%">TYPE OF MEMO </td>
	  <td width="80%" height="25"><%=vRetResult.elementAt(4)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>MEMO NAME</td>
      <td height="25"><%=vRetResult.elementAt(2)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><strong><u>MEMO CONTENT</u> </strong></td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18" colspan="2">
	  <!--<div style="width:200px; overflow:scroll;">-->
	  
<%
strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(3),"\r\n","<br>");
%>
	  <%=ConversionTable.replaceString(strTemp,"\r\n","<br>")%>
	  </td>
    </tr>
  </table>

</body>
</html>
<%
dbOP.cleanUP();
%>