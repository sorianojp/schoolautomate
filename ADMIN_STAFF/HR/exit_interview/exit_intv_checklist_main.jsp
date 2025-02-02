<%@ page language="java" import="utility.*,hr.HRLighthouse,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Pending Exit Interview Checklist</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/td.js"></script>
<script language="javascript">

	function UpdateExitIntvChecklist(strLocation){
		var pgLoc = strLocation;	
		var win=window.open(pgLoc,"UpdateExitIntvChecklist",'width=700,height=500,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}

	function GoBack(strIsMyHome){
		if(strIsMyHome == '1')
			location = "../../../ess/update_notifications.jsp?my_home=1";
		else
			location = "./exit_intv_main.jsp";
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
		
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-EXIT INTERVIEW MANAGEMENT"),"0"));
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
	
	if (bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"my_home","exit_intv_checklist_main.jsp");
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
	
	
	String strLocation = null;
	Vector vRetResult = null;	
	HRLighthouse hrl = new HRLighthouse();
	
	vRetResult = hrl.getPendingEmployeeLeavingChecklist(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hrl.getErrMsg();	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" action="./exit_intv_checklist_main.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="2" align="center" bgcolor="#A49A6A" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: EMPLOYEE LEAVING CHECKLIST MANAGEMENT PAGE ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25" width="80%">&nbsp;</td>
		    <td width="20%" align="right">
			<%if(bolMyHome){%>
				<a href="javascript:GoBack('1')"><img src="../../../images/go_back.gif" border="0"></a>
			<%}else{%>
				<a href="javascript:GoBack('0')"><img src="../../../images/go_back.gif" border="0"></a>
			<%}%></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" width="24%" align="center" class="thinborder"><strong>Name</strong></td>
			<td width="22%" align="center" class="thinborder"><strong>Division</strong></td>
			<td width="22%" align="center" class="thinborder"><strong>Department</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Resignation Date</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Update</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 6){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4), "&nbsp;")%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder" align="center">
				<%
					strLocation = "./update_exit_intv_checklist.jsp?checklist_index="+(String)vRetResult.elementAt(i);
					if(bolMyHome)
						strLocation += "&my_home=1";
				%>
				<a href="javascript:UpdateExitIntvChecklist('<%=strLocation%>')">
					<img src="../../../images/update.gif" border="0"></a></td>
		</tr>
	<%}%>
	</table>
<%}else{%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="95%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
		</tr>
	</table>
<%}%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A" class="footerDynamic"> 
			<td width="1%" height="25">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
