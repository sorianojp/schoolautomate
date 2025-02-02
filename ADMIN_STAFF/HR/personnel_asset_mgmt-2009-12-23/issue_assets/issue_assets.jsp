<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Asset Category</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
a:link {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:visited {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:active {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:hover {
	color:#f00;
	font-weight:700;
	}
.tabFont {
	color:#444444;
	font-weight:700;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
}
</style>
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script src="../../../../jscript/common.js"></script>
<script src="../../../../jscript/date-picker.js"></script>
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

	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
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

function AjaxMapProperty() {
	var strPropertyNum = document.form_.property_num.value;
	var objCOAInput = document.getElementById("coa_info");
	if(strPropertyNum.length < 1) {
		objCOAInput.innerHTML = "";
		return ;
	}
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
	var strURL = "../../../../Ajax/AjaxInterface.jsp?is_available=1&methodRef=401&property_num="+escape(strPropertyNum);
 	this.processRequest(strURL);
}
function updateAssetCode(strItemMasterItem, strPropertyNum){
	document.form_.property_num.value = strPropertyNum;
	document.getElementById("coa_info").innerHTML = "";
	document.form_.submit();
}

function ReloadPage(){
	document.form_.reloadPage.value="1";
	document.form_.submit();
}

function CancelOperation(){
	document.form_.property_num.value = "";
	location ="./issue_assets.jsp?";
}

function IssueItem(){
	document.form_.issue_item.value = "1";
	document.form_.submit();
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector, hr.PersonnelAssetManagement" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null; 

	//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../../../index.jsp");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/fatal_error.jsp");

	//end of authenticaion code.

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR-Personnel Asset Management-Issue Assets-Issue Assets","issue_assets.jsp");
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
	
	Vector vDetails = null;
	String strPrepareToEdit =  WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	PersonnelAssetManagement pam = new PersonnelAssetManagement();

	String strPageAction = WI.fillTextValue("issue_item");
	if(strPageAction.length() > 0){
		if(!pam.operateOnItemIssue(dbOP, request))
			strErrMsg = pam.getErrMsg();
		else 
			strErrMsg = "Item successfully issued.";
	}
	
	String strPropertyNum = WI.fillTextValue("property_num");
	if(strPropertyNum.length() > 0){
		vDetails = pam.getPropItemDetails(dbOP, request);
		if(vDetails == null && strPageAction.length() == 0)
			strErrMsg  = pam.getErrMsg();
	}	
%>
<body bgcolor="#D2AE72" onLoad="document.form_.property_num.focus()">
<form action="./issue_assets.jsp" method="post" name="form_">
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center">
				<font color="#FFFFFF" ><strong>:::: PERSONNEL ASSET MANAGEMENT: ISSUE ITEM PAGE::::</strong></font>
			</td>
		</tr>
		<tr>
			<td height="10" colspan="2">&nbsp;</td>
		</tr>
		<tr> 
			<td><a href="../pam_main.jsp" ><img src="../../../../images/go_back.gif" border="0" align="right"></a></td>
		</tr>
	</table>

    <table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="15%">&nbsp;</td>
        <td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td width="15%">&nbsp;</td>
        <td width="35%">&nbsp;</td>
      </tr>
	  <tr>
        <td>Property No. </td>
        <td>
			<input name="property_num" type="text" size="30" value="<%=WI.fillTextValue("property_num")%>" class="textbox"
				onKeyUp="AjaxMapProperty();" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="16"></td>
        <td><label id="coa_info"></label></td>
      </tr>
	  <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
<%if(vDetails!=null && vDetails.size() > 0){%>
      <tr>
        <td height="25">Category:</td>
        <td><%=(String)vDetails.elementAt(0)%></td>
        <td>Description/Name:</td>
        <td><%=(String)vDetails.elementAt(3)%></td>
      </tr>
      <tr>
        <td height="25">Classification:</td>
        <td><%=(String)vDetails.elementAt(1)%></td>
        <td>Asset Unit: </td>
        <td><%=(String)vDetails.elementAt(4)%></td>
      </tr>
      <tr>
        <td height="25">Brand:</td>
        <td><%=(String)vDetails.elementAt(2)%></td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
	  <tr>
        <td height="25" colspan="4">&nbsp;</td>
      </tr>
	 </table>
	 <table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
	  <tr>
        <td height="25">Issued to: </td>
        <td width="13%">
		<input name="issued_to" type="text" size="16" value="<%=WI.fillTextValue("issued_to")%>" class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AjaxMapName('issued_to','issued_to_');"></td>
        <td colspan="3" align="left"><label id="issued_to_"></label></td>
      </tr>
	  <tr>
        <td height="25">Issued by: </td>
        <td>
		<input name="issued_by" type="text" size="16" value="<%=WI.fillTextValue("issued_by")%>" class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AjaxMapName('issued_by','issued_by_');"></td>
		<td colspan="3" align="left"><label id="issued_by_"></label></td>
		<td width="1%">&nbsp;</td>
      </tr>
	  <tr>
        <td height="25">Date Issued: </td>
        <%
			strTemp = WI.fillTextValue("date_fr");
			if(strTemp.length() == 0) 
				strTemp = WI.getTodaysDate(1);
		%>
        <td colspan="2"><input name="date_fr" type="text" size="16" maxlength="10" readonly="yes" value="<%=strTemp%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp; <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0"></a></td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
	  <tr>
        <td height="25">Reason:</td>
        <td colspan="4"><textarea name="reason" style="font-size:12px" cols="65" rows="6" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("reason")%></textarea></td>
      </tr>
	  <tr>
	  	<td height="25">&nbsp;</td>
		<td colspan="4"><input type="checkbox" name="to_be_returned" value="1" checked>
		To be returned </td>
	  </tr>
	  <tr>
        <td height="25" colspan="5">&nbsp;</td>
      </tr>
	  <tr>
        <td height="25">&nbsp;</td>
        <td colspan="4">
		<a href="javascript:IssueItem();"><img src="../../../../images/save.gif" border="0"></a>
		<a href="javascript:CancelOperation();"><img src="../../../../images/cancel.gif" border="0"></a></td>
      </tr>
<%}%>
	  <tr>
        <td width="15%">&nbsp;</td>
        <td colspan="2">&nbsp;</td>
        <td width="15%">&nbsp;</td>
        <td width="35%">&nbsp;</td>
	  </tr>
    </table>

<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="1" height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#0D3371">
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="issue_item">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
