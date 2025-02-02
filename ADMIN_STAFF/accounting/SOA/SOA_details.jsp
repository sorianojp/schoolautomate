<%@ page language="java" import="utility.*, Accounting.SOAManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsForwarded = WI.fillTextValue("is_forwarded").equals("1");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<title>SOA Details</title>
<style type="text/css">
	a{
		text-decoration: none
	}
</style>
</head>

<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function ViewSOAInfo(strSANum){
		var pgLoc = "./view_SOA_info.jsp?sa_num="+strSANum;
		var win=window.open(pgLoc,"ViewSOAInfo",'width=700,height=500,top=30,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

	function GoBack(){
		location = "./SOA_entries.jsp?jumpto="+document.form_.jumpto.value;
	}

	function AjaxMapSANumber() {
		var strCustCode = document.form_.sa_num.value;
		var objCOAInput = document.getElementById("coa_info");
		if(strCustCode.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
			if(this.xmlHttp == null) {
				alert("Failed to init xmlHttp.");
				return;
			}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20004&sa_num="+escape(strCustCode);
		this.processRequest(strURL);
	}

	function updateSANumber(strEntryIndex, strSANumber){
		document.form_.print_page.value = "";
		document.form_.sa_num.value = strSANumber;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}
	
	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("emp_id_");
		
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
		document.getElementById("emp_id_").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function GetSOAInfo(){
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this SOA detail?'))
				return;
		}
		
		document.form_.print_page.value = "";
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
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.emp_id.value = "";
		document.form_.amount.value = "";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function FocusField(){
		if(document.form_.emp_id)
			document.form_.emp_id.focus();
		else
			document.form_.sa_num.focus();
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
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
								"ACCOUNTING-BILLING","SOA_details.jsp");
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
	
	int iSearchResult = 0;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vSOAInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vTemp = null;
	SOAManagement soa = new SOAManagement();
	
	if(WI.fillTextValue("sa_num").length() > 0){
		vSOAInfo = soa.getSOAInformation(dbOP, request);
		if(vSOAInfo == null)
			strErrMsg = soa.getErrMsg();
		else{
			strTemp = WI.fillTextValue("page_action");
			if(strTemp.length() > 0){
				if(soa.operateOnSOADetails(dbOP, request, Integer.parseInt(strTemp)) == null)
					strErrMsg = soa.getErrMsg();
				else{
					if(strTemp.equals("0"))
						strErrMsg = "SOA detail successfully removed.";
					if(strTemp.equals("1"))
						strErrMsg = "SOA detail successfully recorded.";
					if(strTemp.equals("2"))
						strErrMsg = "SOA detail successfully edited.";
					
					strPrepareToEdit = "0";
				}
			}
			
			vRetResult = soa.getSOADetails(dbOP, request, (String)vSOAInfo.elementAt(0));
			
			if(strPrepareToEdit.equals("1")){
				vEditInfo = soa.operateOnSOADetails(dbOP, request, 3);
				if(vEditInfo == null)
					strErrMsg = soa.getErrMsg();
			}
		}
	}
	
%>
<body bgcolor="#D2AE72" onload="FocusField();">
<form name="form_" action="./SOA_details.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SOA DETAIL MANAGEMENT PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		    <td align="right">
				<%if(bolIsForwarded){%>
					<a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0" /></a>
				<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>S/A Number: </td>
			<td>
				<%if(!bolIsForwarded){%>
				<input name="sa_num" type="text" size="16" value="<%=WI.fillTextValue("sa_num")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapSANumber();">
				<%}else{%>
					<input type="hidden" name="sa_num" value="<%=WI.fillTextValue("sa_num")%>" />
					<strong><font size="3" color="#FF0000"><%=WI.fillTextValue("sa_num")%></font></strong>
				<%}%></td>
			<td colspan="2" valign="top"><label id="coa_info" style="position:absolute; width:300px"></label></td>
		</tr>
		<tr>
			<td height="15" width="3%">&nbsp;</td>
		    <td width="17%">&nbsp;</td>
		    <td width="20%">&nbsp;</td>
		    <td width="45%">&nbsp;</td>
		    <td width="15%">&nbsp;</td>
		</tr>
		<%if(!bolIsForwarded){%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="3">
				<a href="javascript:GetSOAInfo();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to view SOA details. </font></td>
	    </tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<%}%>
	</table>
	
<%if(vSOAInfo != null && vSOAInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">S/A Number: </td>
		    <td><%=(String)vSOAInfo.elementAt(1)%></td>
		    <td>Date:</td>
		    <td><%=(String)vSOAInfo.elementAt(2)%></td>
		    <input type="hidden" name="entry_index" value="<%=(String)vSOAInfo.elementAt(0)%>" />
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Type:</td>
		    <td width="30%"><%=(String)vSOAInfo.elementAt(4)%></td>
		    <td width="17%">Currency:</td>
		    <td width="33%"><%=(String)vSOAInfo.elementAt(18)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Amount:</td>
		    <td>
				<%
					strTemp = CommonUtil.formatFloat((String)vSOAInfo.elementAt(16), false);
					strErrMsg = ConversionTable.replaceString(strTemp, ",", "");
				%>				
				<%=(String)vSOAInfo.elementAt(18)%><%=strTemp%></td>
	        <td>Details:</td>
	        <td><a href="javascript:ViewSOAInfo('<%=(String)vSOAInfo.elementAt(1)%>');">VIEW</a></td>
		</tr>
	</table>

<%if((String)vSOAInfo.elementAt(15) == null){//if there is not payment yet.%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="4"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">Employee ID</td>
		    <td width="25%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("emp_id");
				%>
				<input name="emp_id" type="text" class="textbox" size="16" onKeyUp="AjaxMapName();" 
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
					onBlur="style.backgroundColor='white'"></td>
		    <td width="55%" valign="top"><label id="emp_id_" style="position:absolute; width:350px;"></label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Amount:</td>
			<td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vRetResult.elementAt(3);
						strTemp = CommonUtil.formatFloat(strTemp, false);
						strTemp = ConversionTable.replaceString(strTemp, ",", "");
					}
					else
						strTemp = WI.fillTextValue("amount");
				%>
			<input type="text" name="amount" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white';" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','amount')" size="16" maxlength="16" /></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save SOA details.</font>
			        <%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit SOA details.</font>
		                <%}
				}%>
				<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font></td>
		</tr>
	</table>
<%}else{%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center">Save/edit operations not allowed. SOA already paid.</td>
		</tr>
	</table>
<%}

if(vRetResult != null && vRetResult.size() > 0){%>	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="4" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: SOA DETAILS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="50%" align="center" class="thinborder"><strong>Employee</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=7, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%> (<%=(String)vRetResult.elementAt(i+1)%>)</td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), true)%></td>
	      	<td align="center" class="thinborder">
			<%if((String)vSOAInfo.elementAt(15) == null){//if there is not payment yet.
				if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
					<%}%>
				<%}else{%>
					Not authorized.
				<%}
			}else{%>
				Not allowed.
			<%}%></td>
		</tr>
	<%}%>
	</table>
	<%}
}%>	

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page" />
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>" />
	<input type="hidden" name="jumpto" value="<%=WI.fillTextValue("jumpto")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
