<%@ page language="java" import="utility.*,enrollment.VMAEnrollmentReports,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
	   if(!confirm("Do you want to delete this entry?"))
	   	  return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	
	document.form_.page_action.value = strAction;
	document.form_.submit();
}


function PrepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value = '1';
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function ReloadPage(){
	document.form_.info_index.value = '';
	document.form_.prepareToEdit.value = '';
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72">
<%
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	int iElemSubTotal = 0;
	int iHSSubTotal = 0;
	int iPreElemSubTotal = 0;	
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS-VMA Reports","section_mgt.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"section_mgt.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.


VMAEnrollmentReports enrlReport = new VMAEnrollmentReports();
Vector vRetResult = new Vector();
Vector vEditInfo  = new Vector();

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(enrlReport.operateOnSection(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = enrlReport.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Entry Successfully Deleted";
		if(strTemp.equals("1"))
			strErrMsg = "Entry Successfully Saved";
		if(strTemp.equals("2"))
			strErrMsg = "Entry Successfully Updated";
		strPrepareToEdit = "";
	}

}
vRetResult = enrlReport.operateOnSection(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = enrlReport.getErrMsg();
	 
if(strPrepareToEdit.length() > 0){
	vEditInfo = enrlReport.operateOnSection(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = enrlReport.getErrMsg();
}

	
%>
<form action="./section_mgt.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor="#A49A6A">	
		<td width="100%" height="25" bgcolor="#A49A6A"><div align="center">
		<font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: SECTION MANAGEMENT ::::</strong></font></div></td>
	</tr>
	<tr bgcolor="#FFFFFF"><td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%">Section Name</td>
		<%
		strTemp = WI.fillTextValue("section_name");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		%>
		<td>			 
			<input type="text" name="section_name" value="<%=strTemp%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" size="20" maxlength="32">
		</td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td>
		<%
		if(iAccessLevel > 1){
			if(strPrepareToEdit.length() == 0){
		%>
			<a href="javascript:PageAction('1','');">
			<img src="../../../../images/save.gif" border="0"></a>
			<font size="1">Click to save section</font>
			<%}else{%>
			<a href="javascript:PageAction('2','');">
			<img src="../../../../images/edit.gif" border="0"></a>
			<font size="1">Click to update section</font>
			<%}%>
			<a href="javascript:ReloadPage();">
			<img src="../../../../images/cancel.gif" border="0"></a>
			<font size="1">Click to refresh page</font>
		<%}%>
		</td>
	</tr>
</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<TR><td>&nbsp;</td></TR>
	<tr><td align="center" height="25"><strong>LIST OF SECTION NAME</strong></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td height="25" class="thinborder" width="60%"><strong>Section Name</strong></td>
		<td class="thinborder"><strong>Option</strong></td>
	</tr>
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=3){
	%>
	<tr>
		<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
		<td class="thinborder">
		<%if(((String)vRetResult.elementAt(i + 2)).equals("0")){
			if(iAccessLevel > 1){
		%>
			<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
			<img src="../../../../images/edit.gif" border="0"></a>
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
			<img src="../../../../images/delete.gif" border="0"></a>
			
			<%}%>
		<%}else{%>
			Section Name is in used.
		<%}%>
		</td>
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
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>" />
<input type="hidden" name="page_action" value="" />

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>