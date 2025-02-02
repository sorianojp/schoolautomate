<%@ page language="java" import="utility.*, projMgmt.GTIProject, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){%>
		<p style="font-size:16px; color:#FF0000;">You are logged out.</p>
		<%return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Manpower</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript">	

	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this user?'))
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
	
	function RefreshPage() {
		var loc = "./update_manpower.jsp";
		if(document.form_.project_index.value.length > 0)			
			loc += "?project_index="+document.form_.project_index.value;
		
		location = loc;
	}
	
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
	
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
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
	
</script>

<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Project Management-Update Manpower","update_manpower.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null; 
	Vector vRetResult = null;

	GTIProject proj  = new GTIProject();
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(proj.operateOnProjectManpower(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = proj.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "User successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "User successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "User successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}

	vRetResult = proj.operateOnProjectManpower(dbOP, request,4);	
	//get vEditInfo if it is called.
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = proj.operateOnProjectManpower(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = proj.getErrMsg();		
	}
%>

<body bgcolor="#D2AE72">
<form name="form_" method="post" action="update_manpower.jsp">
<br />
<jsp:include page="./tabs.jsp?pgIndex=5"></jsp:include>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Project: </td>
			<td width="80%">
				<select name="project_index" onChange="document.form_.submit();">
					<option value="">Select Project</option>
					<%=dbOP.loadCombo("project_index","project_name"," from gti_project where is_valid = 1 "+
									  " order by project_name", WI.fillTextValue("project_index"), false)%> 
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>ID Number: </td>
			<td>
				<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('emp_id','emp_id_');">
				&nbsp;&nbsp;
				<label id="emp_id_" style="position:absolute; width:350px"></label>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:PageAction('1', '');"><img src="../../images/save.gif" border="0"></a>
					<font size="1">Click to save project.</font>				   
				<a href="javascript:RefreshPage();"><img src="../../images/refresh.gif" border="0"></a>
					<font size="1">Click to refresh page.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="4" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>::: MANPOWER ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="40%" align="center" class="thinborder"><strong>Project</strong></td>
			<td width="35%" align="center" class="thinborder"><strong>Employee</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 3, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td align="center" class="thinborder">
				<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../images/delete.gif" border="0"></a></td>
		</tr>
	<%}%>	
	</table>
<%}%>	

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
