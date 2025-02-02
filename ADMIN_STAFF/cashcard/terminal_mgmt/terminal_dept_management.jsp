<%@ page language="java" import="utility.*, cashcard.TerminalManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Terminal Department Management Page</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js" ></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objInput = document.getElementById("emp_id_");
		
		if(strCompleteName.length <=2) {
			objInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objInput, 2);//I want to get innerHTML in this.retObj
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
		document.getElementById("emp_id_").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}

	function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this terminal department?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function RefreshPage(){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.submit();
	}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-TERMINAL MANAGEMENT"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Terminal Management","terminal_dept_management.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo = null;
	Vector vRetResult = null;

	TerminalManagement tm = new TerminalManagement();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(tm.operateOnTerminalDept(dbOP, request, Integer.parseInt(strTemp)) == null )
			strErrMsg = tm.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Terminal department successfully removed";
			else if(strTemp.equals("1"))
				strErrMsg = "Terminal department successfully added.";
			else if(strTemp.equals("2"))
				strErrMsg = "Terminal department successfully edited.";	
				
			strPrepareToEdit = "0";
		}
	}

	if(strPrepareToEdit.equals("1")) {
		vEditInfo = tm.operateOnTerminalDept(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = tm.getErrMsg();
	}
	
	if(WI.fillTextValue("catg_index").length() > 0){
		vRetResult = tm.operateOnTerminalDept(dbOP, request,4);
		if (vRetResult == null && strTemp.length() == 0)
			strErrMsg = tm.getErrMsg();
	}

%>		
<body bgcolor="#D2AE72">
<form name="form_" action="./terminal_dept_management.jsp" method="post">

	<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="4" align="center"><font color="#FFFFFF">
				<strong>:::: TERMINAL DEPT. MANAGEMENT PAGE ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Category Name:</td>
			<td width="80%">
				<%if(vEditInfo != null && vEditInfo.size() > 0){%>
					<input type="hidden" name="catg_index" value="<%=(String)vEditInfo.elementAt(4)%>" />
					<strong><%=(String)vEditInfo.elementAt(5)%></strong>
				<%}else{
					strTemp = WI.fillTextValue("catg_index");
				%>	  
					<select name="catg_index" onchange="RefreshPage();">
						<option value="">Select category</option>
						<%=dbOP.loadCombo("catg_index","category"," from cc_terminal_catg where is_valid = 1 order by category",strTemp,false)%>
					</select>
				<%}%></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>Location Info:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("location_info");
				%>
	  			<textarea name="location_info" cols="65" rows="3" class="textbox" style="font-size:12px"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>	
		<tr>
			<td height="25"></td>
			<td>Dept. Name:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("dept_name");
				%>
				<input type="text" name="dept_name" value="<%=strTemp%>" class="textbox" size="32" maxlength="64"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25"></td>
			<td>Dept. Head ID:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("emp_id");
				%>
				<input name="emp_id" type="text" class="textbox" size="16" value="<%=strTemp%>" 
					onKeyUp="AjaxMapName();" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>
				<font size="1">click to search </font>
				&nbsp;&nbsp;&nbsp;
				<label id="emp_id_" style="font-size:11px;position:absolute;width:300px"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save department information.</font>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit department information.</font>
					<%}
				}%>
				<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font></td>	
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF TERMINAL DEPARTMENT ::: </strong></div></td>
		</tr>
		<tr> 
			<td height="25" width="20%" align="center" class="thinborder"><strong>Department Name</strong></td> 
			<td width="20%" align="center" class="thinborder"><strong>Category</strong></td> 
			<td width="25%" align="center" class="thinborder"><strong>Location Info.</strong></td> 
			<td width="20%" align="center" class="thinborder"><strong>Department Head </strong></td> 
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 6){%>
		<tr> 
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
			<td class="thinborder" align="center">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
					<%}
				}else{%>
					Not authorized.
				<%}%></td>
		</tr>
	<%}%>
	</table>
<%}//end of vRetResult %>

	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
		<tr bgcolor="#FFFFFF">
			<td height="25"colspan="3">&nbsp;</td>
		</tr> 
		<tr bgcolor="#A49A6A"> 
			<td width="50%" height="25" colspan="3">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>