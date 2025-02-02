<%@ page language="java" import="utility.*, enrollment.DocRequestTracking, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Document Requirement Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">

</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="javascript">

	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
	}
	
	function DeleteRequirement(strInfoIndex){
		if(!confirm("Do you want to delete this requirement?"))				
			return;
			
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.req_mgt_index.value = strInfoIndex;
		document.form_.page_action.value = "0";
		document.form_.submit();
	}
		
	function AddRequirement(){				
		document.form_.page_action.value = "1";
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.submit();
	}
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Document Request Tracking","requirement_management.jsp");		
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","Document Request Tracking",request.getRemoteAddr(),
														"requirement_management.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	int iSearchResult = 0;
	
	DocRequestTracking docReq = new DocRequestTracking();
	Vector vRetResult = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(docReq.operateOnRequirement(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = docReq.getErrMsg();
		else{
			if(strTemp.equals("1"))
				strErrMsg = "Requirement Entry successfully added.";
			else
				strErrMsg = "Requirement Entry successfully deleted.";
		}
	}
	
	vRetResult = docReq.operateOnRequirement(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = docReq.getErrMsg();


%>
<body bgcolor="#D2AE72" topmargin="0" onUnload="ReloadParentWnd();">
<form name="form_" method="post" action="requirement_management.jsp">
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>::::
        REQUIREMENT MANAGEMENT ::::</strong></font></td>
    </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td width="3%" height="25">&nbsp;</td>
	<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
</tr>		
</table>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td width="23%">Requirement Name:</td>
		<td><input type="text" name="requirement_name" value="<%=WI.fillTextValue("requirement_name")%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" class="textbox" size="50"></td>
	</tr>	
	<tr><td colspan="3" height="10"></td></tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>
		<a href="javascript:AddRequirement();">
		<img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save requirement</font>
		
		</td>
	</tr>
</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td class="thinborder" colspan="10" align="center" height="23"><strong>LIST OF REQUIREMENT</strong></td></tr>
	<tr>
		<td class="thinborder" width="25%" height="23"><strong>REQUIREMENT NAME</strong></td>		
		<td class="thinborder" width="20%"><strong>OPTION</strong></td>
	</tr>
	<%
	for(int i = 0; i < vRetResult.size(); i+=2){
	%>
	<tr>
		<td class="thinborder" height="23"><%=(String)vRetResult.elementAt(i+1)%></td>		
		<td class="thinborder">	
			<a href="javascript:DeleteRequirement('<%=(String)vRetResult.elementAt(i)%>')">
			<img src="../../../images/delete.gif" border="0" align="absmiddle"></a>
			
		</td>
	</tr>
	<%}%>
</table>
<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>

	<input type="hidden" name="req_mgt_index" value="<%=WI.fillTextValue("req_mgt_index")%>" />
	<input type="hidden" name="page_action" />
	<input type="hidden" name="donot_call_close_wnd"/>
	<input type="hidden" name="close_wnd_called" value="0"/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>