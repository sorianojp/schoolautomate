<%@ page language="java" import="utility.*, hr.HRLighthouse, java.util.Vector"%>
<%	
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Notify List</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/common.css" rel="stylesheet" type="text/css">
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
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">
	
	var objCOA;
	var objCOAInput;
	
	function AjaxMapName(strFieldName, strLabelID) {
		objCOA=document.getElementById(strLabelID);
		var strCompleteName = eval("document.form_."+strFieldName+".value");
		eval('objCOAInput=document.form_.'+strFieldName);
		if(strCompleteName.length <= 2) {
			objCOA.innerHTML = "";
			return ;
		}		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
	
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
		"&name_format=4&complete_name="+escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOAInput.value = strID;
		objCOA.innerHTML = "";
	}
	
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function UpdateNotifyList(strCount){
		document.form_.donot_call_close_wnd.value = "1"
		document.form_.notify_target.value = strCount;
		document.form_.submit();
	}
	
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
	}
	
</script>
<%	
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null; 
	
	String[] astrResponsibilites = {"Exit Interview In-charge", "System Admin", "Human Resources", 
									"Payroll/Finance", "Security", "Manager"};
	
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
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Exit Interview Management-Update Notify List","update_notify_list.jsp");
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
	
	Vector vRetResult = new Vector();
	HRLighthouse hrl = new HRLighthouse();
	
	if(WI.fillTextValue("notify_target").length() > 0){
		if(hrl.operateOnExitIntvNotifyList(dbOP, request, 2) == null)
			strErrMsg = hrl.getErrMsg();
		else
			strErrMsg = "Notify list updated successfully.";
	}
	
	vRetResult = hrl.operateOnExitIntvNotifyList(dbOP, request, 4);
	
%>
<body bgcolor="#D2AE72" class="bgDynamic" onUnload="ReloadParentWnd();">
<form name="form_" method="post" action="./update_notify_list.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" >
				<strong>:::: UPDATE RESIGNATION TARGETS ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td height="25" width="5%">&nbsp;</td>
			<td><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	    </tr>
	</table>
	
<%
int iCount = 0;
if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
		<%for(int i = 0; i < vRetResult.size(); i += 4, iCount++){%>
		<tr bgcolor="#CCCCCC">
			<td height="25" width="5%" class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
			<td colspan="3" class="thinborderTOPBOTTOMRIGHT"><strong><%=astrResponsibilites[Integer.parseInt((String)vRetResult.elementAt(i))]%></strong></td>
	  	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="25%">Current: </td>
			<td colspan="2"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "NONE")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="25%">ID Number: </td>
			<td colspan="2"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "NONE")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="25%">New (User Id):</td>
			<td width="20%">
				<input name="user_index_<%=iCount%>" type="text" size="16" class="textbox"
					value="<%=WI.getStrValue((String)vRetResult.elementAt(i+2), WI.fillTextValue("user_index_"+iCount))%>" 					
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('user_index_<%=iCount%>','coa_info_<%=iCount%>');"></td>
			<td width="50%"><label id="coa_info_<%=iCount%>"></label></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td height="25" colspan="2">
				<a href="javascript:UpdateNotifyList('<%=iCount%>');"><img src="../../../images/update.gif" border="0"></a></td>
	    </tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<%}%>
	</table>
<%}%>
			
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A" class="footerDynamic"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="notify_target">
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>">
	<input type="hidden" name="opner_form_field" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_field"),"")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
