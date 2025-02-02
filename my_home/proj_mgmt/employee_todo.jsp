<%@ page language="java" import="utility.*, projMgmt.GTIProjectTodo, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
	if(request.getSession(false).getAttribute("userIndex") == null){%>
		<p style="font-size:16px; color:#FF0000;">You are logged out.</p>
		<%return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Todo</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript">
	
	function ReloadPage(){
		document.form_.page_action.value = "";
		document.form_.info_index.value = "";
		document.form_.submit();
	}
	
	function AcknowledgeTodo(strAction, strInfoIndex) {		
		document.form_.page_action.value = strAction;
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function AddComment(strInfoIndex){
		var pgLoc = "./add_comments.jsp?info_index="+strInfoIndex;	
		var win=window.open(pgLoc,"AddComment",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function ViewDetails(strInfoIndex){
		var pgLoc = "./view_details.jsp?info_index="+strInfoIndex;	
		var win=window.open(pgLoc,"ViewDetails",'width=900,height=500,top=80,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function Finish(strInfoIndex){
		var pgLoc = "./update_finish.jsp?info_index="+strInfoIndex;	
		var win=window.open(pgLoc,"Finish",'width=900,height=500,top=80,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function AjaxUpdateComp(labelID, strRef) {
		strNewCost = prompt('Please enter completion percentage','');
		if(strNewCost == null || strNewCost.length == 0) 
			return;
			
		//update here.. 
		var objCOAInput = document.getElementById(labelID);
	
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20101&new_cost="+strNewCost+"&ref="+strRef;
		
		this.processRequest(strURL);	
	}
	
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Project Management-Employee Todo","employee_todo.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	int iSearchResult = 0;
	Vector vRetResult = null;

	GTIProjectTodo proj = new GTIProjectTodo();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(proj.operateOnProjectTodo(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = proj.getErrMsg();
		else {
			if(strTemp.equals("5"))
				strErrMsg = "Project todo successfully acknowledged.";
		}
	}	
	
	vRetResult = proj.viewEmployeeTodo(dbOP, request);
	if(vRetResult == null){
		if(strTemp.length() == 0)
			strErrMsg = proj.getErrMsg();
	}
	else
		iSearchResult = proj.getSearchCount();
%>

<body bgcolor="#D2AE72">
<form name="form_" method="post" action="employee_todo.jsp">
<br />
<jsp:include page="./tabs.jsp?pgIndex=6"></jsp:include>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>
				<%				
					strErrMsg = WI.fillTextValue("view_type");
					if(strErrMsg.equals("1") || strErrMsg.length() == 0)
						strTemp = "checked";
					else
						strTemp = "";
					
				%>					
				<input name="view_type" type="radio" value="1" <%=strTemp%> onClick="ReloadPage();">View All 
				
				<%	
					if(strErrMsg.equals("2"))
						strTemp = "checked";
					else
						strTemp = "";
				%>	
				<input name="view_type" type="radio" value="2" <%=strTemp%> onClick="ReloadPage();">View Pending
				
				<%				
					if(strErrMsg.equals("3"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input name="view_type" type="radio" value="3" <%=strTemp%> onClick="ReloadPage();">View Acknowledged</td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>	
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder"><div align="center">
				<strong>::: EMPLOYEE TODO LIST ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="5">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(proj.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td height="25" colspan="4" class="thinborderBOTTOM">&nbsp;
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
			<td height="25" width="12%" align="center" class="thinborder"><strong>Priority</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Project</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Client</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Time Scope</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Comp. %</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Status</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Finish</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Details</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Comments</strong></td>
		</tr>
	<%
		boolean bolIsAcknowledged = false;
		int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 9, iCount++){
			bolIsAcknowledged = ((String)vRetResult.elementAt(i+7)).equals("1");
	%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1), "&nbsp;")%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%>-<%=(String)vRetResult.elementAt(i+5)%></td>
			<td align="center" class="thinborder">
			<%if(bolIsAcknowledged){%>
				<label id="updateComp<%=iCount%>" onDblClick="AjaxUpdateComp('updateComp<%=iCount%>','<%=(String)vRetResult.elementAt(i)%>');">
			<%}%>
			<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+8), false)%>
			<%if(bolIsAcknowledged){%>			
				</label>
			<%}%>%</td>
			<td class="thinborder">
				<%if(bolIsAcknowledged){%>
					Acknowledged.
				<%}else{%>
					<a href="javascript:AcknowledgeTodo('5', '<%=(String)vRetResult.elementAt(i)%>');">
						<font color="#FF0000"><strong>Acknowledge</strong></font></a>
				<%}%></td>
			<td align="center" class="thinborder">
				<%if(bolIsAcknowledged){%>
					<a href="javascript:Finish('<%=(String)vRetResult.elementAt(i)%>')">
						<font color="#FF0000"><strong>Finish</strong></font></a>
				<%}else{%>
					&nbsp;
				<%}%></td>
			<td align="center" class="thinborder">
				<a href="javascript:ViewDetails('<%=(String)vRetResult.elementAt(i)%>')">
					<font color="#FF0000"><strong>View</strong></font></a></td>
			<td align="center" class="thinborder">
				<a href="javascript:AddComment('<%=(String)vRetResult.elementAt(i)%>')">
					<font color="#FF0000"><strong>Add</strong></font></a></td>
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
	<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
