<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Manage Links</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
a:link {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:visited {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:active {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:hover {
	color:#f00;
	font-weight:700;
	}
.tabFont {
	color:#444444;
	font-weight:700;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
}
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script src="../jscript/common.js"></script>
<script language="javascript">

function GoHome(){
	location = "./help_main.jsp";
}

function RefreshPage(){
	document.form_.link_name.value = "";
	this.ReloadPage();
}

function ReloadPage(){
	document.form_.sub_module_name.value = document.form_.sub_module[document.form_.sub_module.selectedIndex].text;
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex) {
	document.form_.sub_module_name.value = document.form_.sub_module[document.form_.sub_module.selectedIndex].text;
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this link?'))
			return;
	}
	
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; 
	String strTemp = null;
	String strInfoIndex = WI.fillTextValue("info_index");
	
	//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HELP".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../index.jsp");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
		response.sendRedirect("../commfile/unauthorized_page.jsp");

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HELP-Manage Links","manage_links.jsp");
	}
	catch(Exception exp)	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
	
	Vector vRetResult = null;
	String strModuleIndex = null;
	String strSubModuleName = WI.fillTextValue("sub_module_name");
	SystemHelpFile shf = new SystemHelpFile();

	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		if(shf.operateOnLink(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = shf.getErrMsg();
		} else {
			if(strPageAction.equals("0"))
				strErrMsg = " Link removed successfully.";
			if(strPageAction.equals("1"))
				strErrMsg = " Link recorded successfully.";
		}
	}
	
	if(WI.fillTextValue("sub_module").length() > 0 && WI.fillTextValue("module").length() > 0){
		vRetResult = shf.operateOnLink(dbOP, request,4);
		if(vRetResult == null)
			strErrMsg = shf.getErrMsg();
	}
		
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./manage_links.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5"><div align="center">
				<font color="#FFFFFF" ><strong>:::: LINK MANAGEMENT PAGE ::::</strong></font></div></td>
		</tr>	
		<tr>
			<td width="3%" height="15">&nbsp;</td>
			<td width="67%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="30%" align="right">
				<input name="go_back" type="button" onClick="GoHome()"
				style="font-size:11px; height:20px;border: 1px solid #FF0000;" value="GO BACK"></td>
		</tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="10" width="3%" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td>Module:</td>
		<% 	
			strTemp = WI.fillTextValue("module");
			strModuleIndex = WI.getStrValue(strTemp, "0");
		%>
			<td width="80%">
				<select name="module" onChange="ReloadPage();">
					<option value="">Select Module</option>
					<%=dbOP.loadCombo("module_index","module_name"," from module "+
					" where is_del = 0 order by module_name",strTemp,false)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Sub-Module:</td>
			<td>
				<select name="sub_module" onChange="ReloadPage();">
					<option value="">Select Sub-Module</option>
						<%=dbOP.loadCombo("sub_mod_index","sub_mod_name"," from sub_module "+
						" where module_index = "+strModuleIndex+
						" order by sub_mod_name", WI.fillTextValue("sub_module"), false)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Name:</td>
			<td>
				<input name="link_name" type="text" size="64" value="<%=WI.fillTextValue("link_name")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="256"></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
			<% if (iAccessLevel > 1){%>
				<input name="save" type="button" style="font-size:11px; height:20px;border: 1px solid #FF0000;" 
					value="SAVE" onClick="javascript:PageAction('1','')">		
			<% } // end iAccessLevel  > 1%>
				<input name="refresh" type="button" style="font-size:11px; height:20px;border: 1px solid #FF0000;" 
					value="REFRESH" onClick="javascript:RefreshPage()">
			</td>
		</tr>
		<tr>
			<td colspan="3">&nbsp;</td>
		</tr>
	</table>
    
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr bgcolor="#B9B292">
			<td height="28" colspan="2" class="thinborder">
				<div align="center"><strong>::: LIST OF LINKS IN <%=strSubModuleName%> SUB-MODULE  :::</strong></div></td>
		</tr>
		<tr>
			<td width="80%" align="center" class="thinborder" height="25"><strong>DETAILS</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>OPTIONS</strong></td>
		</tr>
	<%for(int i =0; i < vRetResult.size(); i += 2){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td align="center" class="thinborder"  >
			<%if(iAccessLevel == 2){%>
				<input name="delete" type="button" style="font-size:11px; height:20px;border: 1px solid #FF0000;" 
					value="DELETE" onClick="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>')">	
			<%}else{%>&nbsp;<%}%></td>
		</tr>
	<%}%>
	</table>
<%}//if vRetResult is not null%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A" class="footerDynamic"> 
			<td width="1%" height="25">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="sub_module_name">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>