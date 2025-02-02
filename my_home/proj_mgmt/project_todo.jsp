<%@ page language="java" import="utility.*, java.util.Vector, projMgmt.GTIProjectTodo"%>
<%
	WebInterface WI = new WebInterface(request);
	String strUser = WI.getStrValue((String)request.getSession(false).getAttribute("userIndex"));
	if(request.getSession(false).getAttribute("userIndex") == null){%>
		<p style="font-size:16px; color:#FF0000;">You are logged out.</p>
		<%return;
	}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">

<title>GTI Project Todo</title></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript">

	function loadClient(){
		var objCOA=document.getElementById("load_client");
		var objProject = document.form_.project_index.value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20100&sel_name=client_index&project_index="+objProject;
		this.processRequest(strURL);
	}

	function ReloadPage(){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this todo info?'))
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
		location = "./project_todo.jsp";
	}
	
	function ViewDetails(strInfoIndex){
		var pgLoc = "./view_details.jsp?info_index="+strInfoIndex;	
		var win=window.open(pgLoc,"ViewDetails",'width=900,height=500,top=80,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function AddComment(strInfoIndex){
		var pgLoc = "./add_comments.jsp?info_index="+strInfoIndex;	
		var win=window.open(pgLoc,"AddComment",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}

	function UpdateCategories(){
		var pgLoc = "./update_categories.jsp";	
		var win=window.open(pgLoc,"UpdateCategories",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function UpdateProjects(){
		var pgLoc = "./update_projects.jsp";	
		var win=window.open(pgLoc,"UpdateProjects",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function UpdatePriority(){
		var pgLoc = "./update_priority.jsp";	
		var win=window.open(pgLoc,"UpdatePriority",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
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
		//document.dtr_op.submit();
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
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Project Management-Project Todo","project_todo.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null; 
	Vector vRetResult = null;

	GTIProjectTodo proj = new GTIProjectTodo();
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(proj.operateOnProjectTodo(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = proj.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Project todo successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Project todo successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Project todo successfully edited.";
			if(strTemp.equals("5"))
				strErrMsg = "Project todo successfully acknowledged.";
			
			strPrepareToEdit = "0";
		}
	}
	
	int iSearchResult = 0;
	vRetResult = proj.operateOnProjectTodo(dbOP, request, 4);
	if(vRetResult != null)
		iSearchResult = proj.getSearchCount();
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = proj.operateOnProjectTodo(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = proj.getErrMsg();		
	}
%>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#D2AE72">
<form name="form_" action="project_todo.jsp" method="post">
<br />
<jsp:include page="./tabs.jsp?pgIndex=1"></jsp:include>

	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Project: </td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("project_index");
				%>
				<select name="project_index" onChange="loadClient();">
					<option value="">Select Project</option>
					<%=dbOP.loadCombo("project_index","project_name"," from gti_project where is_valid = 1 "+
									  " order by project_name", strTemp, false)%> 
				</select>
				&nbsp;
				<a href="javascript:UpdateProjects();"><img src="../../images/update.gif" border="0" /></a>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Client: </td>
			<td>
				<%
					strErrMsg = 
						" from gti_client_project "+
						" join gti_client on (gti_client.client_index = gti_client_project.client_index) "+
						" where gti_client_project.is_valid = 1 "+
						" and project_index = "+WI.getStrValue(strTemp, "0");
				
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("client_index");
				%>
				<label id="load_client">
				<select name="client_index">
					<option value="">Select Client</option>
					<%=dbOP.loadCombo("gti_client_project.client_index","client_code", strErrMsg, strTemp, false)%>
				</select>
				</label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Category: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("catg_index");
				%>
				<select name="catg_index">
					<option value="">Select Category</option>
					<%=dbOP.loadCombo("catg_index","catg_name"," from gti_todo_catg where is_valid = 1 "+
									  " order by catg_name", strTemp, false)%> 
				</select>
				&nbsp;
				<a href="javascript:UpdateCategories();"><img src="../../images/update.gif" border="0" /></a>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Priority: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("priority_ref");
				%>
				<select name="priority_ref">
					<option value="">Select Priority</option>
					<%=dbOP.loadCombo("priority_ref","priority_name"," from gti_todo_priority "+
									  " order by priority_ref", strTemp, false)%> 
				</select>
				&nbsp;
				<a href="javascript:UpdatePriority();"><img src="../../images/update.gif" border="0" /></a>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Short Desc: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(8);
					else
						strTemp = WI.fillTextValue("short_desc");
				%>
				<input type="text" name="short_desc" value="<%=strTemp%>" class="textbox" maxlength="128" 
					size="64" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Long Desc: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(9);
					else
						strTemp = WI.fillTextValue("long_desc");
				%>
				<textarea name="long_desc" style="font-size:12px" cols="80" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Start Date: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(10);
					else
						strTemp = WI.fillTextValue("start_date");
				%>
				<input name="start_date" type="text" size="16" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp;
				<a href="javascript:show_calendar('form_.start_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>End Date: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(11);
					else
						strTemp = WI.fillTextValue("end_date");
				%>
				<input name="end_date" type="text" size="16" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.end_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Remarks: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(14);
					else
						strTemp = WI.fillTextValue("remarks");
				%>
				<textarea name="remarks" style="font-size:12px" cols="80" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Assigned by: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(21);
					else
						strTemp = WI.fillTextValue("assigned_by");
				%>
				<input name="assigned_by" type="text" size="16" value="<%=strTemp%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('assigned_by','assigned_by_');">
				&nbsp;
				<label id="assigned_by_" style="position:absolute; width:350px"></label>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Assigned to: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(17);
					else
						strTemp = WI.fillTextValue("assigned_to");
				%>
				<input name="assigned_to" type="text" size="16" value="<%=strTemp%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('assigned_to','assigned_to_');">
				&nbsp;
				<label id="assigned_to_" style="position:absolute; width:350px"></label>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Orig. assigned to: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(25);
					else
						strTemp = WI.fillTextValue("orig_to");
				%>
				<input name="orig_to" type="text" size="16" value="<%=strTemp%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('orig_to','orig_to_');">
				&nbsp;
				<label id="orig_to_" style="position:absolute; width:350px"></label>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../images/save.gif" border="0"></a>
					<font size="1">Click to save todo.</font>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
							<img src="../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit todo.</font>
					<%}
				}%>
				<a href="javascript:RefreshPage();"><img src="../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: TODO LIST ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="5">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(proj.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td height="25" colspan="3" class="thinborderBOTTOM">&nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/proj.defSearchSize;		
				if(iSearchResult % proj.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+proj.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="ReloadPage();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
		  		<%}%>
			</td>
		</tr>
		<tr>
			<td height="25" width="15%" align="center" class="thinborder"><strong>Priority</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Project</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Client</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Details</strong></td>	
			<td width="10%" align="center" class="thinborder"><strong>Comments</strong></td>	
			<td width="10%" align="center" class="thinborder"><strong>Status</strong></td>			
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	boolean bolIsAcknowledged = false;
		String strAssignedTo = null;
		for(int i = 0; i < vRetResult.size(); i += 33){
			bolIsAcknowledged = ((String)vRetResult.elementAt(i+15)).equals("1");
			strAssignedTo = (String)vRetResult.elementAt(i+29);
	%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;")%></td>
			<td align="center" class="thinborder">
				<a href="javascript:ViewDetails('<%=(String)vRetResult.elementAt(i)%>')">
					<font color="#FF0000"><strong>VIEW</strong></font></a></td>
			<td align="center" class="thinborder">
				<%if(bolIsAcknowledged && strAssignedTo.equals(strUser)){%>
					<a href="javascript:AddComment('<%=(String)vRetResult.elementAt(i)%>')">
						<font color="#FF0000"><strong>ADD</strong></font></a>
				<%}else{%>
					N/A
				<%}%></td>
			<td align="center" class="thinborder">
				<%if(bolIsAcknowledged){%>
					Acknowledged.
				<%}else{
					if(strAssignedTo.equals(strUser)){%>
						<a href="javascript:PageAction('5', '<%=(String)vRetResult.elementAt(i)%>');">
							<strong><font color="#FF0000">Acknowledge</font></strong></a>
					<%}else{%>
						Pending.
					<%}
				}%>
				</td>
			<td align="center" class="thinborder">
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../images/edit.gif" border="0"></a>
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