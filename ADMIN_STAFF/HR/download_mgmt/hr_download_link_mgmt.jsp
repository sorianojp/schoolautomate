<%@ page language="java" import="utility.*, java.util.Vector, hr.HRDownloadMgmt"%>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Link Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function UploadDocuments(strInfoIndex){
		var vFileName = prompt('Please enter file name.', '');
		if(vFileName == null || vFileName.length == 0){
			alert("File name not provided.");
			return;
		}
	
		var sT = "./upload_document.jsp?link_index="+strInfoIndex+"&opner_form_name=form_&file_name="+vFileName;
		var win=window.open(sT,"UploadDocuments",'dependent=yes,width=700,height=200,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function ManageUploads(strInfoIndex){
		var pgLoc = "./manage_uploads.jsp?link_index="+strInfoIndex+"&opner_form_name=form_";
		var win=window.open(pgLoc,"ManageUploads",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}

	function PrepareToEdit(strInfoIndex){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this link?'))
				return;
		}
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function CancelRecord(){
		location ="./hr_download_link_mgmt.jsp";
	}
	
	function FocusField(){
		document.form_.link_name.focus();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Link Management","hr_download_link_mgmt.jsp");
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

	String strPrepareToEdit =  WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vRetResult = null;
	Vector vEditInfo = null;		
	HRDownloadMgmt downloadMgmt = new HRDownloadMgmt();

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(downloadMgmt.operateOnLinks(dbOP, request, Integer.parseInt(strTemp)) == null){
			strErrMsg = downloadMgmt.getErrMsg();

		} else {
			if(strTemp.equals("0"))
				strErrMsg = "Link removed successfully.";
			if(strTemp.equals("1"))
				strErrMsg = "Link recorded successfully.";
			if(strTemp.equals("2"))
				strErrMsg = "Link updated successfully.";
				
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = downloadMgmt.operateOnLinks(dbOP, request, 4);
	if(vRetResult == null && strTemp.length() == 0)
		strErrMsg = downloadMgmt.getErrMsg();
	
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = downloadMgmt.operateOnLinks(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = downloadMgmt.getErrMsg();
	}	
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField();">
<form action="hr_download_link_mgmt.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" align="center" class="footerDynamic">
				<font color="#FFFFFF"><strong>:::: LINK MANAGEMENT PAGE ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Link Name: </td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("link_name");
				%>
				<input name="link_name" type="text" size="64" maxlength="128" class="textbox" value="<%=strTemp%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if (iAccessLevel > 1){
					if (vEditInfo  == null){%>        
						<a href="javascript:PageAction('1','');">
							<img src="../../../images/save.gif" border="0" name="hide_save"></a> 
						<font size="1">click to save link </font> 
					<%}else{ %>        
						<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');">
							<img src="../../../images/edit.gif" border="0"></a> 
						<font size="1">click to save link </font>
					<%}// end else vEdit Info == null%> 
					
					<a href="javascript:CancelRecord();">
						<img src="../../../images/refresh.gif" border="0"></a>
					<font size="1">click to referesh page </font> 
				<%}else{%>
					Not authorized to save link information.
				<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr bgcolor="#B9B292">
			<td height="20" colspan="4" class="thinborder"><div align="center">
				<strong>::: LIST OF REVIEW PERIODS CREATED ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="70%" align="center" class="thinborder"><strong>Link Name </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Uploaded<br>Forms</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%
	int iCount = 1;
	int iFileCount = 0;
	for(int i = 0; i < vRetResult.size(); i += 3, iCount++){
		iFileCount = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2), "0"));
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
		  	<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td align="center" class="thinborder">
				<%if(iFileCount > 0) {%>
	  				<a href="javascript:ManageUploads('<%=(String)vRetResult.elementAt(i)%>');"><%=iFileCount%> File(s)</a>
				<%}else{%>
					0 File(s)
				<%}%>
				<br>
	  			<a href="javascript:UploadDocuments('<%=(String)vRetResult.elementAt(i)%>');">Add More</a>
			</td>
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				No edit/delete privileges.
			<%}%></td>
		</tr>
	<%}%>
	</table>
<%}//if vRetResult is not null%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
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
