<%@ page language="java" import="utility.*,java.util.Vector,hr.HRNotification" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(6);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Leave</title>
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
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function UpdateLeaveApplication(strInfoIndex, strEmpId, strSYFrom){
	var pgLoc = "../../<%if(bolIsSchool){%>ADMIN_STAFF<%}else{%>main<%}%>/HR/leave/leave_apply.jsp?supervisor=1&my_home=1&prepareToEdit=1&page_action=3&print_list=''&info_index="+strInfoIndex+"&emp_id="+strEmpId+"&sy_from="+strSYFrom+"&opner_form_name=form_";
	var win=window.open(pgLoc,"UpdateLeaveApplication",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	int iPendingApplications = 0;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if (bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../../index.jsp");
		
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"my_home","update_leave.jsp");
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
	HRNotification hrNot = new HRNotification();
	int i = 0;
	
	vRetResult = hrNot.subordinatePendingLeaveApps(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
	if(vRetResult == null)
		strErrMsg = hrNot.getErrMsg();
	else
		iPendingApplications = Integer.parseInt((String)vRetResult.remove(0));//get the number of pending leave applications
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="update_leave.jsp" method="post" name="form_">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF"><strong>:::: UPDATE LEAVE APPLICATIONS PAGE ::::</strong></font>			</td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td><a href="../update_notifications.jsp?my_home=1"><img src="../../images/go_back.gif" border="0" align="right"></a></td>
		</tr>
		<tr>
			<td><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	</table>
	<%if(vRetResult != null && vRetResult.size() > 1){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder" align="center">
				<strong>PENDING LEAVE APPLICATIONS (<%=iPendingApplications%>) </strong></td>
		</tr>
		<tr>
			<td width="5%"  height="23" rowspan="2" class="thinborder">Count</td>
			<td width="29%" rowspan="2" align="center" class="thinborder"><strong><font size="1">NAME</font></strong></td>
			<td width="28%" colspan="2" align="center" class="thinborder"><strong><font size="1">DATE</font></strong></td>
			<td width="28%" rowspan="2"  align="center" class="thinborder"><strong><font size="1">REASON</font></strong></td>
			<td width="10%" rowspan="2"  align="center" class="thinborder"><strong><font size="1">UDPATE </font></strong></td>
		</tr>
		<tr>
		  <td width="15%" align="center" class="thinborder"><strong><font size="1">FROM</font></strong></td>
	      <td width="14%" align="center" class="thinborder"><strong><font size="1">TO</font></strong></td>
	  </tr>
		<% 	
			int iCount = 1;
			for (i = 0; i < vRetResult.size(); i+=8,iCount++){
		%>
		<tr>
			<td class="thinborder">&nbsp;<%=iCount%></td>
			<td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;
				<%=(String)vRetResult.elementAt(i+1)%></strong></font>			</td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>		
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3), "&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), "&nbsp;")%></td>
			<td align="center" class="thinborder">
				<a href="javascript:UpdateLeaveApplication('<%=vRetResult.elementAt(i)%>','<%=vRetResult.elementAt(i+5)%>', '<%=vRetResult.elementAt(i + 6)%>');">
				<img src="../../images/update.gif" border="0"></a>
			</td>
		</tr>
		<%} //end for loop%>
	</table>
	<%}else{ // end vRetResult != null && vRetResult.size() > 0 %>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr> 
			<td height="20"><font size="2" color="#FF0000"><strong>NO PENDING LEAVE APPLICATIONS.</strong></font></td>
		</tr>
	</table>
	<%}%>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	<input type="hidden" name="reloadPage" value="0">
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>