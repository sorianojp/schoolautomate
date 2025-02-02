<%@ page language="java" import="utility.*,hr.HRLighthouse,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Exit Interview Form</title>
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
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">
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
	
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
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
	
	function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.user_index";
		var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function ReloadPage(){
		document.form_.view_exit_intv_form.value = "1";
		document.form_.submit();
	}
	
	function UpdateExitIntvForm(strExitIntvIndex){
		var sT = "../exit_interview/update_exit_intv_form.jsp?opner_form_name=staff_profile&exit_intv_index="+strExitIntvIndex;
		var win=window.open(sT,"UploadPicture",'dependent=yes,width=700,height=700,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function ViewExitIntvForm(strExitIntvIndex){
		var sT = "../exit_interview/update_exit_intv_form.jsp?read_only=1&opner_form_name=staff_profile&exit_intv_index="+strExitIntvIndex;
		var win=window.open(sT,"ViewExitIntvForm",'dependent=yes,width=700,height=700,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function PrintPg(strExitIntvIndex){
		location = "./exit_intv_form_print.jsp?exit_intv_index="+strExitIntvIndex;
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-CLEARANCE"),"0"));
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
			"Admin/staff-HR Management-Clearance-Post Clearances","emp_exit_intv_form.jsp");
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
	
	Vector vRetResult = null;
	HRLighthouse hrl = new HRLighthouse();
		
	if(WI.fillTextValue("view_exit_intv_form").length() > 0){
		vRetResult = hrl.getEmpExitIntvForms(dbOP, request);
		if(vRetResult == null)
			strErrMsg = hrl.getErrMsg();
	}
	
%>
<body bgcolor="#D2AE72">
<form action="emp_exit_intv_form.jsp" method="post" name="form_">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: EXIT INTERVIEW FORM ::::</strong></font></td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="4"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr> 
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Employee ID </td>
			<td width="25%">
				<input name="user_index" type="text" size="16" value="<%=WI.fillTextValue("user_index")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('user_index','user_index_');">
				<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>				</td>
		    <td width="52%"><label id="user_index_"></label></td>
		</tr>
		<tr>
			<td height="19" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="2">
				<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to view employee exit interview forms</font></td>
	    </tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: EXIT INTERVIEW RECORDS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Position</strong></td>
			<td width="35%" align="center" class="thinborder"><strong>Department/Office</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Date Encoded</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 6, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
			<td class="thinborder">
				<%
					if((String)vRetResult.elementAt(i + 2)== null || (String)vRetResult.elementAt(i + 3)== null)
						strTemp = " ";			
					else
						strTemp = " - ";
				%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"")%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
			<td align="center" class="thinborder">
				<%if(hrl.isExitInterviewDataCompleted(dbOP, request, (String)vRetResult.elementAt(i)) 
				|| !hrl.isOnNotifyList(dbOP, (String)request.getSession(false).getAttribute("userIndex"), 0)){%>
					<a href="javascript:ViewExitIntvForm('<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/view.gif" border="0"></a>
				<%}else{%>
					<a href="javascript:UpdateExitIntvForm('<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/update.gif" border="0"></a>
				<%}%>
					<a href="javascript:PrintPg('<%=(String)vRetResult.elementAt(i)%>')">
						<img src="../../../images/print.gif" border="0"></a></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="view_exit_intv_form">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>