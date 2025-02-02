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

	function CopyStudentList(){
		document.form_.copy_list.value = "1";
		document.form_.show_detail.value = "1";
		document.form_.submit();
	}
	
	function ShowDetail(){
		document.form_.show_detail.value = "1";
		document.form_.submit();
	}
	
	function checkAllSaveItems() {
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
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


if(WI.fillTextValue("copy_list").length() > 0){
	FAPmt.copyExcludedSubjectStudent(dbOP, request, Integer.parseInt(WI.fillTextValue("iAction")));
	strErrMsg = FAPmt.getErrMsg();	
}



if(WI.fillTextValue("show_detail").length() > 0){
	vRetResult = FAPmt.getExcludedSubjStudFromDiscount(dbOP, request, Integer.parseInt(WI.fillTextValue("iAction")));
	if(vRetResult == null)
		strErrMsg = FAPmt.getErrMsg();		
}


%>

<form action="./copy_exclude_subject_student.jsp" method="post" name="form_">

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: COPY EXCLUDED SUBJECT / STUDENT PAGE ::::</strong></font></div></td>
</tr>
</table>
  
  <jsp:include page="./tabs.jsp?pgIndex=2"></jsp:include>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="25" style="padding-left: 25px;"><font color="#FF0000" size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="3%"></td>
		<td colspan="4">
			<%
			strTemp = WI.fillTextValue("iAction");
			if(strTemp.length() == 0 || strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
			%><input type="radio" name="iAction" value="1" <%=strErrMsg%> onClick="document.form_.submit();" > Show Excluded Subject
			
			<%			
			if(strTemp.equals("2"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
			%><input type="radio" name="iAction" value="2" <%=strErrMsg%> onClick="document.form_.submit();" > Show Excluded Student		</td>
	</tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Copy From SY-Term</td>
		
		<td width="80%">
			
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_from_prev"));
			%>
			<input name="sy_from_prev" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from_prev","sy_to_prev")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to_prev"));
			%>
			<input name="sy_to_prev" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("semester_prev"));
			%>	
				
			<select name="semester_prev">
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
			</select> &nbsp; &nbsp;<a href="javascript:ShowDetail();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Copy To SY-Term</td>
	  <td><%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_from_curr"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
        <input name="sy_from_curr" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from_curr","sy_to_curr")'>
-
<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to_curr"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
<input name="sy_to_curr" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
<%
				strTemp = WI.getStrValue(WI.fillTextValue("semester_curr"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
<select name="semester_curr">
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
</select></td>
    </tr>
</table>


<%
int iCount = 1;
String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester", "Fourth Semester"};
if(vRetResult != null && vRetResult.size() > 0){%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="5" height="15"></td></tr>
	<tr>
		<td width="3%">&nbsp;</td>
		<td width="17%">&nbsp;</td>
		<td>&nbsp;</td>
		<%
		if(WI.fillTextValue("iAction").equals("1"))
			strTemp = "subject";
		else
			strTemp = "student";
		%>
		<td align="right" height="25">
		<a href="javascript:CopyStudentList();"><img src="../../../../images/copy.gif" border="0"></a>
		<font size="1">Click to copy list of <%=strTemp%></font>
		</td>
	</tr>
	<%
	if(WI.fillTextValue("iAction").equals("1"))
		strTemp = "subject";
	else
		strTemp = "student";
	%>
	<tr><td height="25" align="center" colspan="5"><strong>LIST OF EXCLUDED <%=strTemp.toUpperCase()%>
		<%=WI.fillTextValue("sy_from_prev")%>-<%=WI.fillTextValue("sy_to_prev")%>, 
		<%=astrConvertSem[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester_prev")))]%>
	</strong></td></tr>
</table>

<%	if(WI.fillTextValue("iAction").equals("1")){ %>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td class="thinborder" height="25" width="20%" align="center"><strong>SUBJECT CODE</strong></td>
		<td class="thinborder" align="center"><strong>SUBJECT NAME</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>Select All<br>
			<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">
		</strong></td>
	</tr>
	
	<%
		for(int i = 0; i < vRetResult.size(); i+=4, iCount++){
		
	%>
	
	<tr>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+3)%></td>
		<td class="thinborder" height="25" align="center">
			<input type="checkbox" name="save_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">
		</td>
	</tr>
	
	<%}%>
	
</table>

	<%}else{%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td class="thinborder" height="25" width="15%"><strong>ID Number</strong></td>
		<td class="thinborder" width=""><strong>Student Name</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>Course - Year</strong></td>		
		<td class="thinborder" width="15%" align="center"><strong>Select All<br>
			<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">
		</strong></td>
	</tr>
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=6, iCount++){
	%>
	<tr>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+3)%></td>
		<td class="thinborder" height="25" align=""><%=(String)vRetResult.elementAt(i+4)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+5), "- ", "", "")%></td>		
		<td class="thinborder" height="25" align="center">
			<input type="checkbox" name="save_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">
		</td>
	</tr>
	
	<%}%>
	
</table>
<%}%>

	<input type="hidden" name="item_count" value="<%=iCount%>" >


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="3" height="15"></td></tr>
	
	<%
	if(WI.fillTextValue("iAction").equals("1"))
		strTemp = "subject";
	else
		strTemp = "student";
	%>
	
	<tr>
		<td align="right" height="25">
		<a href="javascript:CopyStudentList();"><img src="../../../../images/copy.gif" border="0"></a>
		<font size="1">Click to copy list of <%=strTemp%></font>
		</td>
	</tr>
</table>

<%}//end vRetResult%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>

<input type="hidden" name="show_detail" >
<input type="hidden" name="copy_list" >

</form>


</body>
</html>
<%
dbOP.cleanUP();
%>
