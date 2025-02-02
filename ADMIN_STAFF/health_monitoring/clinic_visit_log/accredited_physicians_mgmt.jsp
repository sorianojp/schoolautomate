<%@ page language="java" import="utility.*, health.AUFHealthProgram, java.util.Vector " %>
<%
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(8);
	//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Accredited Physician Mgmt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function RefreshPage(){
		document.form_.name.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this physician info?'))
				return;
		}
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}

	function PrepareToEdit(strInfoIndex) {
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	//called for add or edit and delete.
	function ReloadParentWnd() {
		if(document.form_.is_forwarded.value.length == 0)
			return;
	
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
	}
	
</script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;	

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","accredited_physicians_mgmt.jsp");
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
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
															"accredited_physicians_mgmt.jsp");
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
	
	String strIsForwarded = WI.fillTextValue("is_forwarded");
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	AUFHealthProgram hp = new AUFHealthProgram();	
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(hp.operateOnAccreditedPhysicians(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = hp.getErrMsg();
		else {				
			if(strTemp.equals("0"))
				strErrMsg = "Physician information successfully removed.";
			else if(strTemp.equals("1"))
				strErrMsg = "Physician information successfully recorded.";
			else
				strErrMsg = "Physician information successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}		
	
	vRetResult = hp.operateOnAccreditedPhysicians(dbOP,request, 4);
	if(vRetResult == null && strTemp.length() == 0)
		strErrMsg = hp.getErrMsg();
	
	if(strPrepareToEdit.equals("1")){
		vEditInfo = hp.operateOnAccreditedPhysicians(dbOP,request, 3);
		if(vEditInfo == null)
			strErrMsg = hp.getErrMsg();
	}
%>
<body bgcolor="#8C9AAA" class="bgDynamic" onUnload="ReloadParentWnd();">
<form action="./accredited_physicians_mgmt.jsp" method="post" name="form_">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F"> 
			<td height="25" class="footerDynamic" colspan="3"><div align="center"><font color="#FFFFFF">
				<strong>:::: ACCREDITED PHYSICIANS MANAGEMENT PAGE ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%" colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Name: </td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("name");
				%>
				<input name="name" type="text" size="64" value="<%=strTemp%>" class="textbox" maxlength="128"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="40" colspan="3" align="center" valign="middle">
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save physician info.</font>
				<%}else {%>
					<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<font size="1">Click to edit physician info.</font>					
				<%}%>
				
				<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>
			<%}else{%>
				Not allowed to save accredited physician information.
			<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" border="0" class="thinborder">
		<tr bgcolor="#FFFF9F"> 
      		<td height="25" colspan="7" align="center" class="thinborder">
				<font size="2"><strong>LIST OF ACCREDITED PHYSICIANS</strong></font></td>
    	</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="80%" align="center" class="thinborder"><strong>Name</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 2, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/delete.gif" border="0"></a>
					<%}
				}else{%>
					Not allowed.
				<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="is_forwarded" value="<%=strIsForwarded%>">
	
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  	
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>