<%@ page language="java" import="utility.*, inventory.InventoryMaintenance, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Gate Pass Management Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../../jscript/date-picker.js" ></script>
<script language="javascript"  src="../../../../Ajax/ajax.js"></script>
<script>
function PageAction(strAction,strInfoIndex)
{		
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	document.form_.page_action.value= strAction;
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}
function ReloadPage()
{
	document.form_.print_page.value = "";
	document.form_.proceed.value = "1";
	this.SubmitOnce('form_');
}


function OpenSearch()
{
	var pgLoc = "./gate_pass_search.jsp?opner_info=form_.gate_pass_no&opener_form_name=form_";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function EncodeDetails(strGatePassNo){
	if(strGatePassNo.length == 0)
		return;
		
	var pgLoc = "./gate_pass_details.jsp?gate_pass_no="+strGatePassNo;
	var win=window.open(pgLoc,"EncodeDetails",'width=1000,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


var strSearchType = "";
function AjaxMapName(strType) {
	strSearchType = strType;
	
	var strCompleteName = "";
	var objCOAInput = "";
	if(strType == "1"){
		strCompleteName = document.form_.requested_by.value;
	   objCOAInput = document.getElementById("lbl_request");
	}else if(strType == "2"){
		strCompleteName = document.form_.noted_by.value;
	   objCOAInput = document.getElementById("lbl_note");
	}else if(strType == "3"){
		strCompleteName = document.form_.approved_by.value;
	   objCOAInput = document.getElementById("lbl_approve");
	}else if(strType == "4"){
		strCompleteName = document.form_.verified_by.value;
	   objCOAInput = document.getElementById("lbl_verified");
	}
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	
		
}
function UpdateName(strFName, strMName, strLName) {
	
}
function UpdateNameFormat(strName) {
	if(strSearchType == "1"){
		document.form_.requested_by.value = strName;
	   document.getElementById("lbl_request").innerHTML = "";;
	}else if(strSearchType == "2"){
		document.form_.noted_by.value = strName;
	   document.getElementById("lbl_note").innerHTML = "";;
	}else if(strSearchType == "3"){
		document.form_.approved_by.value = strName;
	   document.getElementById("lbl_approve").innerHTML = "";;
	}else if(strSearchType == "4"){
		document.form_.verified_by.value = strName;
	   document.getElementById("lbl_verified").innerHTML = "";;
	}
}

function PrintPage(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}

</script>
</head>

<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	
	


	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try
	{
	 	dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY MAINTENANCE","gate_pass_mgmt.jsp");								

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}

	
	
	


InventoryMaintenance invMaintenance = new InventoryMaintenance();
String strGatePassNo = WI.fillTextValue("gate_pass_no");	

if(WI.fillTextValue("print_page").length() > 0){
	if( !invMaintenance.finalizedGatePass(dbOP, request, strGatePassNo) )
		strErrMsg = invMaintenance.getErrMsg();
	else{
		dbOP.cleanUP();%>		
		<jsp:forward page="./gate_pass_print.jsp"></jsp:forward>		
	<%	return;
	}
}


Vector vRetResult = null;
Vector vEditInfo = null;



strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	vRetResult = invMaintenance.operateOnGatePass(dbOP, request, Integer.parseInt(strTemp), strGatePassNo);
	if( vRetResult == null )
		strErrMsg = invMaintenance.getErrMsg();
	else{
		if(strTemp.equals("1") || strTemp.equals("2")){
			strGatePassNo = WI.getStrValue((String)vRetResult.elementAt(0));
		}
		if(strTemp.equals("1"))
			strErrMsg = "Gate Pass information successfully saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Gate Pass information successfully updated.";
		if(strTemp.equals("0"))
			strErrMsg = "Gate Pass information successfully deleted.";
	}
}


if(strGatePassNo.length() > 0){
	vRetResult = invMaintenance.operateOnGatePass(dbOP, request, 4, strGatePassNo);
	if(vRetResult == null)	
		strErrMsg  = invMaintenance.getErrMsg();
}

Vector vGPDetails = invMaintenance.operateOnGatePassDetails(dbOP, request, 4, strGatePassNo);

boolean bolShowForm = false;
if( WI.fillTextValue("proceed").length() > 0 && ( strGatePassNo.length() == 0 || (strGatePassNo.length() > 0 && vRetResult != null && vRetResult.size() > 0)))
	bolShowForm = true;
	
boolean bolIsFinalized = false;
if(vRetResult != null && vRetResult.size() > 0 && WI.getStrValue(vRetResult.elementAt(11)).equals("1"))
	bolIsFinalized = true;
%>

<body bgcolor="#D2AE72">
<form name="form_" action="gate_pass_mgmt.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GATE PASS MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6"><font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td width="12%"><strong>Gate Pass #</strong></td>
      <td width="18%" >
      <%
	  
		  strTemp = WI.fillTextValue("gate_pass_no");
		  if(strGatePassNo.length() > 0)
		  	strTemp = strGatePassNo;
	  %> 
      <input name="gate_pass_no" type="text" size="16" maxlength="32" value="<%=strTemp%>" class="textbox" 
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="5%" valign="middle"><font size="1"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" alt="search" border="0"></a></font></td>
      <td width="23%" valign="middle">
      <a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" border="0"></a>      </td>
      <td width="39%" valign="middle">
			<%if(strGatePassNo.length() > 0 && bolShowForm && !bolIsFinalized){%><a href="javascript:EncodeDetails('<%=strGatePassNo%>');">Encode Gate Pass Details</a><%}%>		</td>
    </tr>
    <tr>
      
       <td>&nbsp;</td>
		  <td colspan="5">To create new gate pass, leave text field empty.</td>
    </tr>
    <tr> 
      <td height="19" colspan="6"><hr size="1"></td>
    </tr>
	</table>
	<%if(bolShowForm){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#C78D8D"> 
      <td height="24">&nbsp;</td>
      <td height="24" colspan="4"><strong><font color="#FFFFFF">GATE PASS INFORMATION</font></strong></td>
    </tr>
    <tr> 
      <td colspan="5" height="10">&nbsp;</td>
    </tr>
<%if(strGatePassNo.length() == 0){%>
    <tr>
       <td>&nbsp;</td>
       <td height="20" colspan="4"><strong>GATE PASS NO WILL BE GENERATED AFTER SAVING</strong></td>
    	</tr>
<%}%>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td colspan="2" valign="top">Origin</td>
		<%
		strTemp = WI.fillTextValue("origin");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(5));
		%>
      <td width="81%" height="30" colspan="2">
		<textarea name="origin" cols="45" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>
		</td>
    </tr>
	  <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td colspan="2" valign="top">Destination</td>
		<%
		strTemp = WI.fillTextValue("destination");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(6));
		%>
      <td height="30" colspan="2">
		<textarea name="destination" cols="45" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>
		</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Requested by :</td>
		<%
		strTemp = WI.fillTextValue("requested_by");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(7));
		%>
      <td height="30" colspan="2" valign="middle">
			<input name="requested_by" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox" 
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
			&nbsp; &nbsp;
			<label id="lbl_request" style="position:absolute; width:400px;"></label>
		</td>
    </tr>
	 
	 
	 <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Noted by :</td>
		<%
		strTemp = WI.fillTextValue("noted_by");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(8));
		%>
      <td height="30" colspan="2" valign="middle">
			<input name="noted_by" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox" 
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('2');">
			&nbsp; &nbsp;
			<label id="lbl_note" style="position:absolute; width:400px;"></label>
		</td>
    </tr>
	 
	 <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Approved by :</td>
		<%
		strTemp = WI.fillTextValue("approved_by");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(9));
		%>
      <td height="30" colspan="2" valign="middle">
			<input name="approved_by" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox" 
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('3');">
			&nbsp; &nbsp;
			<label id="lbl_approve" style="position:absolute; width:400px;"></label>
		</td>
    </tr>
	 
	 <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Verified by :</td>
		<%
		strTemp = WI.fillTextValue("verified_by");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(10));
		%>
      <td height="30" colspan="2" valign="middle">
			<input name="verified_by" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox" 
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('4');">
			&nbsp; &nbsp;
			<label id="lbl_verified" style="position:absolute; width:400px;"></label>
		</td>
    </tr>
	 
	 
	 
	 
	 
	 
	 
	 
    
    
<%//if(!bolIsFinalized){%>    
    <tr> 
      <td height="48">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td height="48" colspan="2" valign="middle"><font size="1"> 
		<%
		if(strGatePassNo.length() > 0 && vRetResult != null && vRetResult.size() > 0){
		%>      
			<a href="javascript:PageAction('2','');"> <img src="../../../../images/edit.gif" border="0"></a> 
        Click to update information 
		<%}else{%>
        <a href="javascript:PageAction('1','');"> <img src="../../../../images/save.gif" border="0"></a> 
        Click to save information 
      <%}%> 
		
		 <a href="javascript:location='gate_pass_mgmt.jsp';"> <img src="../../../../images/cancel.gif" border="0"></a> 
        Click to cancel operation 
		
        </font></td>
    </tr>
<%//}%>
  </table>  


<%
if(vGPDetails != null && vGPDetails.size() > 0){
%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	   <td height="22" align="right">
		<%//if(!bolIsFinalized || WI.fillTextValue("allow_print").length() > 0){%>
		<a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>
			<font size="1">Click to print gate pass and finalized</font>
		<%//}%>
		</td>
	</tr>
	<tr><td align="center" height="22"><strong>LIST OF GATE PASS DETAILS</strong></td></tr>
</table>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="13%" height="20" align="center" class="thinborder"><strong>QUANTITY</strong></td>
		<td width="12%" align="center" class="thinborder"><strong>UNIT</strong></td>
		<td width="33%" align="center" class="thinborder"><strong>DESCRIPTION</strong></td>
		<td width="30%" align="center" class="thinborder"><strong>PURPOSE</strong></td>
	   </tr>
	
	<%
	for(int i = 0; i < vGPDetails.size(); i+=16){
	%>
	<tr>
		<td class="thinborder" align="center" height="18"><%=CommonUtil.formatFloat((String)vGPDetails.elementAt(i+2), true)%></td>
		<td class="thinborder" align="center"><%=(String)vGPDetails.elementAt(i+3)%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vGPDetails.elementAt(i+4),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vGPDetails.elementAt(i+5),"&nbsp;")%></td>
	   </tr>
	<%}%>
</table>
<%}%>

<%}// end if proceed is clicked%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input name="info_index" type="hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="page_action">
	 <input type="hidden" name="print_page">
	 <input type="hidden" name="proceed" value="<%=WI.fillTextValue("proceed")%>">
	 <input type="hidden" name="allow_print" value="">
   	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>