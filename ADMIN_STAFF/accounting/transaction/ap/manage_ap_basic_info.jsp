<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete Payee type.'))
			return;
	}
		
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function CancelOperation() {
	var strPayeeType;
	if(document.form_.payee_type[0].checked)
		strPayeeType = "?payee_type=1";
	else
		strPayeeType = "?payee_type=1";
		
	location = "./manage_ap_basic_info.jsp"+strPayeeType;
}

///for searching COA - ajax.. 
var objCOA;
function MapCOAAjax() {
	objCOA=document.getElementById("coa_info");

	var objCOAInput;
	eval('objCOAInput=document.form_.ap_tax_index');
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
		objCOAInput.value+"&coa_field_name=ap_tax_index";
	this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	objCOA.innerHTML = "<font color='blue'>"+strAccountName+"</font>";
}
</script>

<%@ page language="java" import="utility.*,Accounting.AccountPayable,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.

	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-Accounting-Transaction-A/P Manage AP Basic Info","manage_ap_basic_info.jsp");
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
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	AccountPayable AP = new AccountPayable();
	Vector vEditInfo  = null; Vector vRetResult = null; boolean bolAdded = false;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(AP.operateOnAPBasicInfo(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = AP.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Payee Type successfully removed.";
			if(strTemp.compareTo("1") == 0) {
				strErrMsg = "Payee Type successfully added.";
				bolAdded = true;
			}
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Payee Type successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	vRetResult = AP.operateOnAPBasicInfo(dbOP, request,4);	
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = AP.getErrMsg();
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = AP.operateOnAPBasicInfo(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = AP.getErrMsg();
	}

boolean bolIsCompany = !WI.fillTextValue("payee_type").equals("0");
//if(vEditInfo != null) {//determine what is clicked.
//	if(vEditInfo.elementAt(7) == null)
//		bolIsCompany = false;
//	else	
//		bolIsCompany = true;
//}
java.sql.ResultSet rs = null;

String strDefSupplierCode = null;
String strDefSupplierName = null;

%>

<body bgcolor="#D2AE72" onLoad="document.form_.payee_code.focus();">
<form action="./manage_ap_basic_info.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="8"><div align="center"><font color="#FFFFFF" ><strong>:::: AP PAYEE TYPE MANAGEMENT ::::</strong></font></div></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><a href="./manage_ap.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="2">
<%
if(bolIsCompany) {
	strTemp = " checked";
	strErrMsg = "";
}else{
	strTemp = "";
	strErrMsg = " checked";
}
if(bolIsCompany || vEditInfo == null) {%>
	    <input name="payee_type" type="radio" value="1"<%=strTemp%> onClick="document.form_.page_action.value='';document.form_.submit();"> Supplier - Company &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%}if(!bolIsCompany || vEditInfo == null) {%>
        <input name="payee_type" type="radio" value="0"<%=strErrMsg%> onClick="document.form_.page_action.value='';document.form_.submit();"> Supplier - Individual	
<%}%>  </td>
    </tr>
<%if(bolIsCompany) {
strTemp = "";
if(vEditInfo != null) {
	strErrMsg = (String)vEditInfo.elementAt(7);
	strTemp = " or profile_index = "+strErrMsg;
}
else	
	strErrMsg = WI.fillTextValue("supplier_index");
if(strErrMsg == null || bolAdded)
	strErrMsg = "";

strTemp = "select profile_index, supplier_code, supplier_name from PUR_SUPPLIER_PROFILE where is_del = 0 and "+
	"(not exists (select * from AC_AP_BASIC_INFO where supplier_index = profile_index) "+strTemp+") order by supplier_code";
rs = dbOP.executeQuery(strTemp);
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Select a Supplier :	  
	  	<select name="supplier_index" onChange="document.form_.page_action.value='';document.form_.submit();">
<%
while(rs.next()) {
	if(strErrMsg.length() == 0) 
		strErrMsg = rs.getString(1);
		
	if(strErrMsg.equals(rs.getString(1))){
		strDefSupplierCode = rs.getString(2);
		strDefSupplierName = rs.getString(3);
		%>
		<option value="<%=rs.getString(1)%>" selected><%=strDefSupplierCode%> (<%=strDefSupplierName%>)</option>
		<%}else{%>
		<option value="<%=rs.getString(1)%>"><%=rs.getString(2)%> (<%=rs.getString(3)%>)</option>
		<%}
}
%>
		</select>	  
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="../../../purchasing/supplier/suppliers.jsp">Create Supplier Profie</a>
		
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payee Code </td>
      <td width="82%">
<%
if(strDefSupplierCode == null) {
	if(vEditInfo != null)
		strDefSupplierCode = (String)vEditInfo.elementAt(3);
	else	
		strDefSupplierCode = WI.fillTextValue("payee_code");
}%>
	  <input name="payee_code" type="text" size="16" maxlength="12" value="<%=WI.getStrValue(strDefSupplierCode)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  <%if(bolIsCompany){%> readonly<%}%>></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payee Name </td>
      <td>
<%
if(strDefSupplierName == null) {
	if(vEditInfo != null)
		strDefSupplierName = (String)vEditInfo.elementAt(2);
	else	
		strDefSupplierName = WI.fillTextValue("payee_name");
}%>
	  <input name="payee_name" type="text" size="64" maxlength="128" value="<%=WI.getStrValue(strDefSupplierName)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Tin Number </td>
      <td>
<%
	if(vEditInfo != null)
		strTemp = (String)vEditInfo.elementAt(4);
	else	
		strTemp = WI.fillTextValue("tin_number");
%>
	  <input name="tin_number" type="text" size="16" maxlength="24" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Tax Code </td>
      <td>
        <select name="tax_code_ref">
<%
if (vEditInfo != null && vEditInfo.size() > 0)
	strErrMsg = (String) vEditInfo.elementAt(6);
else
	strErrMsg = WI.fillTextValue("tax_code_ref");
String strTemp2 = null;  
strTemp = "select TAX_CODE_INDEX,TAX_CODE,TAX_RATE,TAX_RATE_UNIT,TAX_TYPE_CODE from AC_COA_TAXCODENEW "+
"join AC_COA_TAXCODE_TYPE on (AC_COA_TAXCODE_TYPE.TAX_CODE_TYPE_INDEX = AC_COA_TAXCODENEW.TAX_CODE_TYPE_INDEX)"+
"where is_valid = 1 order by TAX_TYPE_CODE,tax_code";
rs = dbOP.executeQuery(strTemp);
String[] astrConvertTaxRateUnit = {" Amount"," %"};
while(rs.next()){
	strTemp = rs.getString(2)+" ("+rs.getString(3)+ astrConvertTaxRateUnit[rs.getInt(4)]+") - "+rs.getString(5);
if(strErrMsg.equals(rs.getString(1)))
	strTemp2 = " selected";
else
	strTemp2 = "";
%>
		<option value="<%=rs.getString(1)%>" <%=strTemp2%>><%=strTemp%></option>
<%}%>
        </select>
        <font size="1" color="#0000FF"><b>(Manage tax code in Administration-&gt;Set up for taxes module)</b></font></td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>GL A/P Tax Code</td>
      <td>
<% 
if (vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String) vEditInfo.elementAt(9);
else
	 strTemp = WI.fillTextValue("ap_tax_index"); 
%>
	  <input name="ap_tax_index" type="text" size="16" maxlength="20"value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onkeyUP="MapCOAAjax();">
      <font size="1">(This chart of account will be affected whenever a delivery is made by this supplier)</font>	</td>
    </tr>
--> 
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><label id="coa_info" style="font-size:11px;">&nbsp;</label></td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td>
        <%if(!strPrepareToEdit.equals("1")) {%>
		<input type="submit" value=" Save Payee Type " style="font-size:10px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.page_action.value='1';document.form_.prepareToEdit.value='';document.form_.info_index.value=''"> 
        <%}else {%>
        <input type="submit" value=" Edit Payee Type " style="font-size:10px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=(String)vEditInfo.elementAt(0)%>'">
        <%}%>
        &nbsp;&nbsp;&nbsp;
		<input type="button" value=" Cancel Operation " style="font-size:10px; height:22px;border: 1px solid #FF0000;" onClick="CancelOperation();">		
	  </td>
    </tr>
<%}%>	
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="2" style="font-size:11px; font-weight:bold; color:#0000FF" bgcolor="#DDDDDD" class="thinborderTOPLEFTRIGHT"><u>Search Condition</u></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:11px;" bgcolor="#DDDDDD" class="thinborderBOTTOMLEFTRIGHT">Payee Code Starts with : 	  
      <input name="payee_code_sw" type="text" size="16" maxlength="12" value="<%=WI.fillTextValue("payee_code_sw")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px">
	  &nbsp;&nbsp;&nbsp;<a href="#"><img src="../../../../images/refresh.gif" onClick="document.form_.page_action.value='';document.form_.submit();" border="1" height="20">	  </td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
    <tr bgcolor="#DDDDEE"> 
      <td height="25" colspan="6" class="thinborder" align="center"><font color="#FF0000"><strong>List of Supplier  
	  (<%if(bolIsCompany){%>Company<%}else{%>Individual<%}%>) </strong></font></td>
    </tr>
    <tr>
      <td height="25" colspan="6" class="thinborder">&nbsp; Total Results found : <%=vRetResult.remove(0)%>, Showing : 1 to <%=vRetResult.size()/13%></td>
    </tr>
    <tr> 
      <td width="15%" class="thinborder" align="center" style="font-size:9px; font-weight:bold" height="25">Payee Code</td>
      <td width="40%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Payee Name</td>
      <td width="10%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Tin Number</td>
      <td width="10%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Tax Code</td>
      <td width="7%"  class="thinborder" align="center" style="font-size:9px; font-weight:bold">Edit</td>
      <td width="8%"  class="thinborder" align="center" style="font-size:9px; font-weight:bold">Delete</td>
    </tr>
<%
String strBGColor = null;
for(int i = 0; i < vRetResult.size(); i += 13){
	if(vRetResult.elementAt(i + 12).equals("1"))
		strBGColor = "";
	else	
		strBGColor = " bgcolor='#DDDDDD'";
%>
    <tr<%=strBGColor%>> 
      <td height="25" class="thinborder" style="font-size:9px">&nbsp;<%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" style="font-size:9px">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" style="font-size:9px">&nbsp;<%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder" style="font-size:9px">&nbsp;<%=vRetResult.elementAt(i + 11)%></td>
      <td class="thinborder">&nbsp;
	  <%if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/edit.gif" border="0"></a> 
	<%}%>        </td>
      <td class="thinborder">&nbsp;
	 <%if(iAccessLevel == 2 && strBGColor.length() == 0){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/delete.gif" border="0"></a> 
	<%}%></td>
    </tr>
<%}%>
  </table>
<%}//end of vRetResult%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A"> 
    <td width="50%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>