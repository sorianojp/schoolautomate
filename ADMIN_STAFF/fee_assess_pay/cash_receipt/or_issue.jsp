<%@ page language="java" import="utility.*,Accounting.CashReceiptBook,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
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
			if(!confirm('Are you sure you want to delete this OR issue?'))
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
		location = "./or_issue.jsp";
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-CASH RECEIPT-OR Issue","or_issue.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","CASH RECEIPT",request.getRemoteAddr(),
															"or_issue.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo = null;
	Vector vRetResult = null;
	
	CashReceiptBook crb =  new CashReceiptBook();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(crb.operateOnORIssued(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = crb.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "OR issue successfully removed.";
			else if(strTemp.equals("1"))
				strErrMsg = "OR issue successfully recorded.";
			else
				strErrMsg = "OR issue successfully edited.";
				
			strPrepareToEdit = "0";
		}
	}
	
	if(strPrepareToEdit.equals("1")){
		vEditInfo = crb.operateOnORIssued(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = crb.getErrMsg();
	}
	
	int iSearchResult = 0;
	vRetResult = crb.operateOnORIssued(dbOP, request, 4);
	if(vRetResult == null){
		if( strTemp.length() == 0)
			strErrMsg = crb.getErrMsg();
	}
	else
		iSearchResult = crb.getSearchCount();
%>
<form name="form_" action="./or_issue.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: ISSUE OR PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">OR Range: </td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("or_from");
				%>
				<input type="text" name="or_from" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" />
				-
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(7);
					else
						strTemp = WI.fillTextValue("or_to");
				%>
				<input type="text" name="or_to" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Issue Date: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(10);
					else{
						strTemp = WI.fillTextValue("issue_date");
						if(strTemp.length() == 0) 
							strTemp = WI.getTodaysDate(1);
					}
				%>
				<input name="issue_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.issue_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Teller ID : </td>
		  	<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("emp_id");
				%>
				<input name="emp_id" type="text" class="textbox" size="16" onKeyUp="AjaxMapName();" 
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
					onBlur="style.backgroundColor='white'">&nbsp;
				<label id="coa_info" style="position:absolute; width:350px;"></label></td>
	  	</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save team information.</font>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
							<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit team information.</font>
					<%}
				}%>
				<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>
			<%}else{%>
				Not authorized to save or issue information.
			<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: ISSUED OR LISTING :::</strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="3">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(crb.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="2"> &nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/crb.defSearchSize;		
				if(iSearchResult % crb.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+crb.getDisplayRange()+")";
				
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
				<%}}%>		  </td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Date Issued</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Issued To</strong></td>
			<td width="35%" align="center" class="thinborder"><strong>OR Range</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 11, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%></td>
		    <td class="thinborder">
				&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 4)%>
				(<%=(String)vRetResult.elementAt(i+5)%>)</td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%> - <%=(String)vRetResult.elementAt(i+7)%></td>
		    <td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				N/A
			<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#B8CDD1">
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
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