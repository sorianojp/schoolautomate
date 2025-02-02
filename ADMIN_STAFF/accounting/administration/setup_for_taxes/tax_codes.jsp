<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","tax_codes.jsp");
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
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(adm.operateOnTaxCodeNew(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = adm.operateOnTaxCodeNew(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = adm.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = adm.operateOnTaxCodeNew(dbOP, request, 3);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
</script>

<body bgcolor="#D2AE72">
<form action="./tax_codes.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
        SETUP TAXES - TAX CODES PAGE ::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25" colspan="3"><a href="./main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
	&nbsp;&nbsp;<font style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  <tr>
    <td width="7%" height="22">&nbsp;</td>
    <td width="17%" height="22">Tax Type</td>
    <td width="76%"><select name="tax_type_index">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(0);
else	
	strTemp = WI.fillTextValue("tax_type_index");

strTemp = dbOP.loadCombo("TAX_CODE_TYPE_INDEX","TAX_TYPE_CODE"," from AC_COA_TAXCODE_TYPE order by TAX_TYPE_CODE", strTemp, false);
if(strTemp.length() == 0) 
	strTemp = "<option value=''></option>";
%><%=strTemp%>
    </select>
      <a href="tax_type.jsp"><img src="../../../../images/update.gif" width="60" height="26" border="0">click to update list of TAX TYPE</a> </td>
  </tr>
  <tr>
    <td></td>
    <td>Tax Code</td>
    <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("tax_code");
%> 
	  <input name="tax_code" type="text" size="12" maxlength="12" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	

	</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>Description</td>
    <td>
	<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("description_");
%> 
	  <input name="description_" type="text" size="64" maxlength="256" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	
	</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25"> ATC - Industry</td>
    <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("atc_industry");
%> 
	  <input name="atc_industry" type="text" size="32" maxlength="32" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		 
      (if applicable) </td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">ATC - Corporation</td>
    <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("atc_corporation");
%> 
	  <input name="atc_corporation" type="text" size="32" maxlength="32" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	
	
(if applicable) </td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">Tax Rate</td>
    <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("tax_rate");
%> 
	  <input name="tax_rate" type="text" size="5" maxlength="5" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	

      <select name="tax_rate_unit">
        <option value="1">%</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("tax_rate_unit");
if(strTemp.equals("0"))
	strTemp = " selected";
else	
	strTemp = "";
%>
        <option value="0" <%=strTemp%>>specific amount</option>
      </select>      </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>
	<font size="1">
<%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">&nbsp;&nbsp;&nbsp;&nbsp;
	<%}else{%>
		<input type="submit" name="12" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.trans_type.value='';document.form_.trans_code.value=''">
      </font>
	</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="26" colspan="9" align="center" class="thinborder"><strong>:: SCHEDUES OF ALPHANUMERIC TAX CODES (ATC) FOR VALUE-ADDED TAX (VAT) :: </strong></td>
    </tr>
    <tr>
      <td rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">COUNT</td>
      <td rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">TAX CODE </td>
      <td rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">TAX TYPE </td>
      <td rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">DESCRIPTION</td>
      <td height="25" rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">TAX RATE</td>
      <td colspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">ATC</td>
      <td colspan="2" rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">OPTIONS</td>
    </tr>
    <tr>
      <td class="thinborder" align="center" style="font-size:9px;">INDUSTRY</td>
      <td class="thinborder" align="center" style="font-size:9px;">CORPORATION</td>
    </tr>
<%
String[] astrConvertTaxRateUnit = {"Amount","%"};
for(int i = 0, iCount=0; i < vRetResult.size(); i += 10){%>
    <tr>
      <td width="3%" class="thinborder"><%=++iCount%></td>
      <td width="8%" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td width="7%" class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td width="45%" class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td> 
      <td width="7%" height="26" class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%>
	  	<%=astrConvertTaxRateUnit[Integer.parseInt((String)vRetResult.elementAt(i + 4))]%></td>
      <td width="7%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "&nbsp;")%></td>
      <td width="8%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "&nbsp;")%></td>
      <td width="8%" class="thinborder" align="center">
	  	  <%if(iAccessLevel > 1) {%>
	  <input type="submit" name="12" value="&nbsp; Edit &nbsp;" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');"><%}%>
		</td>
      <td width="7%" class="thinborder" align="center">
	  <%if(iAccessLevel ==2 ) {%>
	  <input type="submit" name="12" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');"><%}%>
	  </td>
    </tr>
<%}%>
  </table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="23" width="7%">&nbsp;</td>
    <td width="43%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A">
    <td height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>