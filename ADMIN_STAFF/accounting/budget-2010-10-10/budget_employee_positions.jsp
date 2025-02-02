<%@ page language="java" import="utility.*,Accounting.Budget,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Staff Position</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
			if(this.xmlHttp == null) {
				alert("Failed to init xmlHttp.");
				return;
			}
			
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		document.form_.emp_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this employee?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function RefreshPage(strAuthLevelIndex){
		location = "./budget_employee_positions.jsp?auth_level_index="+strAuthLevelIndex;
	}
	
	function ReloadPage(){
		document.form_.page_action.value = "";
		document.form_.info_index.value = "";	
		document.form_.submit();
	}
	
	function FocusField(){
		if(document.form_.emp_id)
			document.form_.emp_id.focus();
	}
	
</script>
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BUDGET"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
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
								"ACCOUNTING-BUDGET","budget_employee_positions.jsp");
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
	Vector vEditInfo = null;
	
	Budget budget = new Budget();
	
	if(WI.fillTextValue("auth_level_index").length() > 0){
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			if(budget.operateOnUserAuthList(dbOP, request, Integer.parseInt(strTemp)) == null)
				strErrMsg = budget.getErrMsg();
			else{
				if(strTemp.equals("0"))
					strErrMsg = "User successfully removed.";
				if(strTemp.equals("1"))
					strErrMsg = "User successfully recorded.";
			}
		}
		
		vRetResult = budget.operateOnUserAuthList(dbOP, request, 4);
	}
%>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="./budget_employee_positions.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: BUDGET LEVEL IN-CHARGE MANAGEMENT PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Level Name: </td>
			<td width="80%">
				<select name="auth_level_index" onChange="ReloadPage();">
          			<option value="">Select Level</option>
          			<%=dbOP.loadCombo("auth_level_index","level_name", " from ac_budget_auth_level where is_valid = 1 and is_restricted = 0 order by order_no", WI.fillTextValue("auth_level_index"),false)%> 
        		</select></td>
		</tr>
	</table>

<%if(WI.fillTextValue("auth_level_index").length() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Employee ID: </td>
			<td width="25%">
				<input name="emp_id" type="text" class="textbox" size="16" onKeyUp="AjaxMapName();" 
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("emp_id")%>"
					onBlur="style.backgroundColor='white'"></td>
			<td width="55%" valign="top"><label id="coa_info" style="position:absolute; width:350px;"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save employee information..</font>
					&nbsp;
					<a href="javascript:RefreshPage('<%=WI.fillTextValue("auth_level_index")%>');">
						<img src="../../../images/refresh.gif" border="0"></a>
					<font size="1">Click to refresh page.</font>
				    <%}else{%>
					Not authorized.
				<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>
<%}

if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: STAFF LISTING ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="10%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="60%" align="center" class="thinborder"><strong>Name</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Delete</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 3, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel == 2){%>					
					<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/delete.gif" border="0"></a>					
				<%}else{%>
					Not authorized.
				<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>