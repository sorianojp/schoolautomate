<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 9px}
-->
</style>
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
	function ShowDetail(){
		document.form_.show_detail.value = "1";
		document.form_.submit();
	}
	function PageAction(strAction, strInfoIndex){
		if(strAction == "0"){
			if(!confirm("Do you want to unexclude this student?"))
				return;
		}	
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		document.form_.page_action.value = strAction;
		document.form_.show_detail.value = "1";
		document.form_.submit();
	}
	
	function ResetPage() {		
		document.form_.info_index.value= "";
		document.form_.page_action.value = "";
		document.form_.show_detail.value = "1";
		document.form_.submit();
	}

	var objCOA;
	var objCOAInput;
	function AjaxMapName() {
		var strIDNumber = document.form_.stud_id.value;
		objCOAInput = document.getElementById("coa_info");
		
		eval('objCOA=document.form_.stud_id');
		if(strIDNumber.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strIDNumber);
		
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOA.value = strID;
		objCOAInput.innerHTML = "";		
	}
		
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-PAYMENT MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}		
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation();
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

FAPmtMaintenance FAPmt = new FAPmtMaintenance();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(FAPmt.operateOnExcludeStudFromDiscount(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = FAPmt.getErrMsg();
	else{
		if(strTemp.equals("0"))	
			strErrMsg = "Student removed from exclude list.";
		if(strTemp.equals("1"))	
			strErrMsg = "Student Excluded from discount computation.";
	}
}


if(WI.fillTextValue("show_detail").length() > 0){
vRetResult = FAPmt.operateOnExcludeStudFromDiscount(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = FAPmt.getErrMsg();
}


%>

<form action="./exclude_student.jsp" method="post" name="form_">

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: EXCLUDE STUDENT PAGE ::::</strong></font></div></td>
</tr>
</table>
 
  <jsp:include page="./tabs.jsp?pgIndex=1"></jsp:include>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="25" style="padding-left: 25px;"><font color="#FF0000" size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">SY/Term</td>
		
		<td width="80%">
			
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>	
				
			<select name="semester" onChange="ResetPage();">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>&nbsp; &nbsp;
		<a href="javascript:ShowDetail();"><img src="../../../../images/form_proceed.gif" border="0"></a>
		</td>
	</tr>
	<%if(WI.fillTextValue("show_detail").length() > 0){%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>ID Number</td>
		<td>
			<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">
			&nbsp;&nbsp;
			<label id="coa_info" style="width:300px; position:absolute"></label></td>
	</tr>
	
	
	<tr><td height="10" colspan="3"></td></tr>
	
	<tr>
		<td colspan="2" height="25">&nbsp;</td>
		<td>
			<a href="javascript:PageAction('1', '');"><img src="../../../../images/save.gif" border="0"></a>
				<font size="1">click to exclude student</font>
		</td>
	</tr>	
	<%}%>
</table>



<%if(vRetResult != null && vRetResult.size() > 0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="5" height="15"></td></tr>
	<tr><td height="25" align="center"><strong>LIST OF EXCLUDED STUDENT</strong></td></tr>
</table>


<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td class="thinborder" height="25" width="15%"><strong>ID Number</strong></td>
		<td class="thinborder" width=""><strong>Student Name</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>Course - Year</strong></td>		
		<td class="thinborder" width="15%" align="center"><strong>Option</strong></td>
	</tr>
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=6){
	%>
	<tr>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+3)%></td>
		<td class="thinborder" height="25" align=""><%=(String)vRetResult.elementAt(i+4)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+5), "- ", "", "")%></td>		
		<td class="thinborder" height="25" align="center">
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../../images/delete.gif" border="0"></a>
		</td>
	</tr>
	
	<%}%>
	
</table>

<%}%>


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>

<input type="hidden" name="page_action" >
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" >
<input type="hidden" name="show_detail">

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
