

<%@ page language="java" import="utility.*, enrollment.DocRequestTracking, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Document Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">

</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function DeleteDocument(strInfoIndex){
		if(!confirm("Do you want to delete this document?"))				
			return;
		
		document.form_.donot_call_close_wnd.value = "1";	
		document.form_.doc_index.value = strInfoIndex;
		document.form_.page_action.value = "0";
		document.form_.submit();
	}
	
	function EditDocument(strInfoIndex, strDocName){		
		document.form_.donot_call_close_wnd.value = "1";	
		document.form_.doc_name_old.value = strDocName;
		document.form_.doc_index.value = strInfoIndex;
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1"
		document.form_.submit();
	}
	
	function UpdateDocument(){
		document.form_.donot_call_close_wnd.value = "1";	
		document.form_.page_action.value = "2";
		document.form_.submit();
	}
	
	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
	
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPage();
	}
	
	function ReloadPage(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.page_action.value = "";
		document.form_.doc_index.value = "";	
		document.form_.doc_name_new.value = "";		
		document.form_.prepareToEdit.value = "";
		document.form_.duration.value = "";		
		document.form_.submit();		
	}
	
	function RequestDocument(){	
		document.form_.donot_call_close_wnd.value = "1";			
		document.form_.page_action.value = "1";
		document.form_.submit();
	}
	
	function AddRequirement(strInfoIndex) {
		var pgLoc = "add_document_requirement.jsp?doc_index="+strInfoIndex;
		var win=window.open(pgLoc,"AddRequirement",'width=600,height=300,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

	
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;	
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Document Request Tracking","document_management.jsp");		
	}
	catch(Exception exp) {
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
														"Registrar Management","Document Request Tracking",request.getRemoteAddr(),
														"document_management.jsp");
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
	
	int iSearchResult = 0;
	
	DocRequestTracking docReq = new DocRequestTracking();
	Vector vRetResult = null;
	Vector vEditInfo = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	
	
	strTemp = WI.fillTextValue("page_action");		
	if(strTemp.length() > 0){
		if(docReq.operateOnDocument(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = docReq.getErrMsg();
		else{
			if(strTemp.equals("1"))
				strErrMsg = "Document successfully added.";
			if(strTemp.equals("0"))
				strErrMsg = "Document successfully deleted.";				
			if(strTemp.equals("2"))
				strErrMsg = "Document successfully updated.";
		}
		strPrepareToEdit = "0";
	}
	
	
	
	vRetResult = docReq.operateOnDocument(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = docReq.getErrMsg();
		
	if(strPrepareToEdit.equals("1")){		
		vEditInfo = docReq.operateOnDocument(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = docReq.getErrMsg();
	}


%>
<body bgcolor="#D2AE72" topmargin="0" onUnload="ReloadParentWnd();">
<form name="form_" method="post" action="document_management.jsp">
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>::::
        DOCUMENT MANAGEMENT ::::</strong></font></td>
    </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td width="3%" height="25">&nbsp;</td>
	<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
</tr>		
</table>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td width="17%">Document Name:</td>
		<%
		strTemp = WI.fillTextValue("doc_name_new");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		%>		
		<td><input type="text" name="doc_name_new" value="<%=strTemp%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" class="textbox" size="60"></td>
	</tr>
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td width="17%">Duration:</td>
		<%
		strTemp = WI.fillTextValue("duration");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
		%>
		<td><input type="text" name="duration" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','duration');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','duration');" size="5" maxlength="5" value="<%=strTemp%>"/>
			<font size="1">(how many days to release)</font>	
		</td>
	</tr>
	<tr><td colspan="3" height="10"></td></tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>
		<%if(strPrepareToEdit.equals("0")){%>
		<input type="image" name="save_" src="../../../images/save.gif" border="0" onClick="RequestDocument();">		
		<font size="1">Click to save document</font>
		<%}else{%>		
		<input type="image" name="edit_" src="../../../images/edit.gif" border="0" onClick="UpdateDocument();">	
		<font size="1">Click to update document</font>	
		<%}%>		
		<input type="image" name="cancel_" src="../../../images/cancel.gif" border="0" onClick="ReloadPage();">		
		<font size="1">Click to reload page</font>
		</td>
	</tr>
</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td class="thinborder" colspan="10" align="center" height="23"><strong>LIST OF DOCUMENT TO BE REQUESTED</strong></td></tr>
	<tr>
		<td class="thinborder" width="25%" height="23"><strong>DOCUMENT NAME</strong></td>
		<td class="thinborder" width="7%" height="23" align="center"><strong>DURATION</strong></td>
		<td class="thinborder" width=""><strong>REQUIREMENTS</strong></td>
		<td class="thinborder" width="30%"><strong>OPTION</strong></td>
	</tr>
	<%
	String strCurrDoc = null;
	String strPrevDoc = "";
	String strDuration = null;
	String strDocRequirement = "";
	int iIndexOf = 0;
	boolean bolDisplayData = false;
	for(int i = 0; i < vRetResult.size(); i+=4){
		strCurrDoc = (String)vRetResult.elementAt(i+1);		
		strDuration = (String)vRetResult.elementAt(i+2);
		
		if((String)vRetResult.elementAt(i+3) != null)
			if(strDocRequirement.length()==0)
				strDocRequirement = (String)vRetResult.elementAt(i+3)+";";
			else
				strDocRequirement += "<br>"+(String)vRetResult.elementAt(i+3)+";";
		
		iIndexOf = i + 5;
		if(iIndexOf > vRetResult.size())
			iIndexOf = iIndexOf - 5;
		
		strPrevDoc = (String)vRetResult.elementAt(iIndexOf);
			
		if(!strPrevDoc.equals(strCurrDoc))
			bolDisplayData = true;
		else
			bolDisplayData = false;			
			
		if(bolDisplayData){				
			bolDisplayData = false;
		
	%>
	<tr>
		<td class="thinborder" height="23"><%=strCurrDoc%></td>
		<td class="thinborder" height="23" align="center"><%=strDuration%></td>
		<td class="thinborder" ><%=WI.getStrValue(strDocRequirement,"&nbsp;")%></td>
		<td class="thinborder">
			<input type="button" value="Add Requirement" onClick="AddRequirement('<%=(String)vRetResult.elementAt(i)%>');">
			
			<a href="javascript:EditDocument('<%=(String)vRetResult.elementAt(i)%>','<%=strCurrDoc%>')">
			<img src="../../../images/edit.gif" border="0" align="absmiddle"></a>
			
			<a href="javascript:DeleteDocument('<%=(String)vRetResult.elementAt(i)%>')">
			<img src="../../../images/delete.gif" border="0" align="absmiddle"></a>
		</td>
	</tr>
		<%
		strDocRequirement = "";
		}
	}%>
</table>
<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>" />
	<input type="hidden" name="doc_index" value="<%=WI.fillTextValue("doc_index")%>" />
	<input type="hidden" name="doc_name_old" value="<%=WI.fillTextValue("doc_name_old")%>" />
	<input type="hidden" name="page_action" />
	
	
	<input type="hidden" name="donot_call_close_wnd"/>
	<input type="hidden" name="close_wnd_called" value="0"/>
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>