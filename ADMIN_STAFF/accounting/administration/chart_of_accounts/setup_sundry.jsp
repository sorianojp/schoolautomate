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
<script language="javascript">
///for searching COA
var iCount = 0;
function PageAction(strAction) {
	if(strAction == 0) {
		if(iCount == 0) {
			alert("Please select atleast one record to remove.");
			return;
		}
		if(!confirm('Are you sure you want to remove account type from sundry to non-sundry type.'))
			return;
	}
	document.form_.page_action.value = strAction;
}
function updateCount(objChkBox) {
	if(objChkBox.checked)
		++iCount;
	else	
		--iCount;
}
//0 = for save, 1 = for delete.
function SelALL(strIndex) {
	var objChkBox;
	var iMaxCount = 0;
	var bolIsChecked = false;
	if(strIndex == 1) {
		iMaxCount = document.form_.max_disp.value;
		if(document.form_.sel_all.checked)
			bolIsChecked = true;
		iCount = 1;
	}
	else {	
		iMaxCount = document.form_.max_disp_.value;
		if(document.form_.sel_all_save.checked)
			bolIsChecked = true;
	}
		
	if(iMaxCount == 0) {
		alert("No list found.");
		return;
	}
		
	for(var i=0; i < iMaxCount; ++i) {
		if(strIndex == 1)
			eval('objChkBox=document.form_.info_index_'+i);
		else
			eval('objChkBox=document.form_.save_'+i);
		
		if(!objChkBox)
			continue;
		objChkBox.checked = bolIsChecked;
	}		
}
function SearchCOA() {
	document.form_.page_action.value = '';
	document.form_.submit();
}
function MapCOAAjax() {
		var objCOA=document.getElementById("coa_info");
		
		var objCOAInput = document.form_.coa_code;
		if(objCOAInput.value.length < 3)
			return;
			
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?extra_con=and%20is_sundry%3D0&show_header=0&methodRef=1&coa_entered="+
			document.form_.coa_code.value+"&coa_field_name=coa_code";
		//alert(strURL);	
		this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	document.getElementById("coa_info").innerHTML = "<b>"+strAccountName+"</b>";
}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.coa_code.focus()">
<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","setup_sundry.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
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
Administration adm = new Administration();
Vector vRetResult = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(adm.opeateOnSundryAccountSetting(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}
vRetResult = adm.opeateOnSundryAccountSetting(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = adm.getErrMsg();
%>
<form action="./setup_sundry.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SET UP SUNDRY ACCOUNT::::</strong></font></strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="12%">Account #</td>
      <td width="15%">
	  <input name="coa_code" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("coa_code")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="69%"><a href="javascript:SearchCOA();">Search Account</a></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="3">
<%
boolean bolShowSave = false;
int j =0;
String strSQLQuery = WI.fillTextValue("coa_code");
if(strSQLQuery.length() > 0) {
strSQLQuery = "select coa_index, COMPLETE_CODE, ACCOUNT_NAME from ac_coa where (COMPLETE_CODE like '"+strSQLQuery+"%' or ACCOUNT_NAME like '"+strSQLQuery+
					"%') and is_Valid = 1 and is_sundry=0 order by coa_cf, COMPLETE_CODE_INT";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);

if(rs.next()) {bolShowSave = true;%>	  
	  	<table width="700" cellpadding="0" cellspacing="0" class="thinborder">
			<tr>
				<td class="thinborder" width="25%">Account Code</td>
				<td class="thinborder" width="63%">Account Name</td>
				<td class="thinborder" align="center" width="15%">Save All<br>
				  <input type="checkbox" name="sel_all_save" onClick="SelALL(0);"></td>
			</tr>
		</table>
	  <div style="height:300; width:700; overflow:auto; border:groove;">
	  	<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
		  <td class="thinborder" width="25%"><%=rs.getString(2)%></td>
		  <td class="thinborder" width="65%"><%=rs.getString(3)%></td>
		  <td class="thinborder" align="center"><input type="checkbox" name="save_0" value="<%=rs.getString(1)%>"></td>
		</tr>
		<%while(rs.next()){%>
			<tr>
			  <td class="thinborder"><%=rs.getString(2)%></td>
			  <td class="thinborder"><%=rs.getString(3)%></td>
			  <td class="thinborder" align="center"><input type="checkbox" name="save_<%=++j%>" value="<%=rs.getString(1)%>"></td>
			</tr>
		<%}%>
		<input type="hidden" name="max_disp_" value="<%=++j%>">
		</table>
	  </div>
<%}
}%>
	  </td>
    </tr>
    <tr> 
      <td height="38">&nbsp;</td>
      <td height="38">Enter Sundry Name and save </td>
      <td height="38" colspan="2" valign="bottom">
	  <%if(iAccessLevel > 1 && bolShowSave) {%>
	  <input name="sundry_name" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("sundry_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
	  
	     <input type="submit" name="123" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1');">
      <%}%></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="5" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: LIST OF SUNDRY ACCOUNT IN REOCRD ::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="5%" height="25" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Count</td>
      <td width="15%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Sundry Name </td>
      <td width="15%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Account Number</td>
      <td width="56%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Account Name</td>
      <td width="9%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Delete<br>
	  <input type="checkbox" name="sel_all" onClick="SelALL(1);"></td>
    </tr>
<%
j =0;
for(int i = 0; i < vRetResult.size() ; i += 4, ++j){%>
    <tr> 
      <td height="22" class="thinborder"><%=j + 1%>.</td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" align="center"><%if(iAccessLevel ==2 ) {%>
        <input type="checkbox" name="info_index_<%=j%>" value="<%=vRetResult.elementAt(i)%>" onClick="updateCount(document.form_.info_index_<%=j%>);">
      <%}%></td>
    </tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=j%>">
  </table>
  <table bgcolor="#FFFFFF" width="100%">
  	<tr align="center">
		<td>
		<input type="submit" name="122" value="Delete Selected Records" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="PageAction('0');">
		</td>
	</tr>
  </table>
  
<%}//end of vRetResult.. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>