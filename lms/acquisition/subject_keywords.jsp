<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if(strSchCode == null) {%>
		<p style="font-size:14px; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif;"> Failed to proceed. You are already logged out. Please login again.</p>

<%return;}%>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	
	
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Acquisition".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	
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


String strSubjName = null;
String strSubjIndex = WI.fillTextValue("sub_index");
String strSetupDtlsIndex = WI.fillTextValue("setup_dtls_index");

Vector vEditInfo = null;
Vector vRetResult = null;
lms.LmsAcquision lmsAcq = new lms.LmsAcquision();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(lmsAcq.operateOnLMSAcqSubjectKeywords(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = lmsAcq.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Entry Successfully Deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Entry Successfully Saved.";		
	}
}


vRetResult = lmsAcq.operateOnLMSAcqSubjectKeywords(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = lmsAcq.getErrMsg();
	
if(strSubjIndex.length() > 0){
	strTemp = "select sub_name from subject where sub_index = "+strSubjIndex;	
	strSubjName = dbOP.getResultOfAQuery(strTemp, 0);
	if(strSubjName == null || strSubjName.length() == 0) 
		strErrMsg = "Subject information not found.";	
}

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
	function CloseWindow(){	
		window.opener.document.form_.submit();
		window.opener.focus();
		self.close();
	}
	
	function PageAction(strAction, strInfoIndex){
		if(strAction == "0"){
			if(!confirm("Do you want to delete this entry? "))
				return;
		}
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		document.form_.page_action.value = strAction;
		
		document.form_.submit();
		
	}
	
	function RefreshPage(){
		document.form_.remarks.value = "";		
		document.form_.page_action.value = "";
		document.form_.info_index.value = "";
		document.form_.submit();
	}	
</script>
<body bgcolor="#D2AE72">
<form action="subject_keywords.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor="#A49A6A">
		<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: SUBJECT KEYWORDS ::::</strong></font></div></td>
	</tr>
	<tr>
		<td height="25" bgcolor="#FFFFFF" width="80%"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
		<td height="25" align="right" bgcolor="#FFFFFF"><a href="javascript:CloseWindow();"><img src="../../images/close_window.gif" border="0"></a></td>
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr><td width="3%"></td><td colspan="3" height="25"><strong>SUBJECT COURSE : <%=strSubjName%></strong></td></tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td width="17%">KEYWORDS</td>
		<%
		strTemp = WI.fillTextValue("remarks");				%>
		<td><input name="remarks" type="text" class="textbox"  
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=strTemp%>"></td>
	</tr>
	
	<tr>
		<td colspan="2">&nbsp;</td>
		<td>			
			<a href="javascript:PageAction('1','');"><img src="../../images/save.gif" border="0"></a>
			<font size="1">Click to save entry</font>
			
			<a href="javascript:RefreshPage();"><img src="../../images/cancel.gif" border="0"></a>
			<font size="1">Click to refresh page</font>
		</td>
	</tr>
	<tr><td colspan="3" height="10"></td></tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td height="25" class="thinborder" width="80%"><strong>RECOGNITION NO</strong></td>		
		<td height="25" class="thinborder" align="center"><strong>OPTION</strong></td>
	</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 2){%>
	<tr>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>		
		<td class="thinborder" align="center">			
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../images/delete.gif" border="0"></a>
		</td>
	</tr>
	<%}%>
</table>

<%}%>

<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" >
	<input type="hidden" name="page_action" value="" >
	<input type="hidden" name="setup_dtls_index" value="<%=strSetupDtlsIndex%>" >
	<input type="hidden" name="sub_index" value="<%=strSubjIndex%>" >

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
