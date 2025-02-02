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
								"Admin/staff-Accounting-Administration","exclude_balance_forward.jsp");
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
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult  = null;	
Administration adm = new Administration();
strTemp = WI.fillTextValue("page_action"); 
if(strTemp.length() > 0) {
	if(adm.operateOnExcludeCOABalanceForward(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else	
		strErrMsg = "Request successful.";
}
vRetResult = adm.operateOnExcludeCOABalanceForward(dbOP, request, 4);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../../Ajax/ajax.js"></script>
<script language="javascript">
function ShowDetail(strPrintStat) {
	strCOANumber = document.form_.coa.value;
	if(strCOANumber.length == 0) {
		alert("Please enter chart of account number.");
		return;
	}
	document.form_.print_stat.value = strPrintStat;
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function MapCOAAjax(strIsBlur) {
		var objCOA;
		objCOA=document.getElementById("coa_info");
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			document.form_.coa.value+"&coa_field_name=coa&is_blur="+strIsBlur;
		this.processRequest(strURL);
}
function COASelected(strAccountName) {
	document.getElementById("coa_info").innerHTML = "End of Processing..";
}
function DeleteRecord(strInfoIndex) {
	if(!confirm('Do you want to remove this information.'))
		return;
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = '0';
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./exclude_balance_forward.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" style="font-weight:bold; color:#FFFFFF">:::: Exclude chart of account in balance forwarding ::::</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; font-weight:bold; color:#FF0000">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="19%">Enter Chart of Account </td>
      <td width="77%">
	  <input name="coa" type="text" size="20" maxlength="32" value="<%=WI.fillTextValue("coa")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="MapCOAAjax('0');">
	  <br><label id="coa_info" style="font-size:11px;"></label>
	  </td>
    </tr>
    
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td style="font-size:9px;">
        <input type="submit" name="12" value=" Exclude Chart of Account " style="font-size:11px; height:26px;border: 1px solid #FF0000;"  onClick="document.form_.page_action.value='1'">
      </td>
    </tr>
	<tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td style="font-size:9px;"></td>
	</tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#88DDDD" align="center" style="font-weight:bold"> 
      <td height="22" class="thinborder" width="25%">Account Name </td>
      <td class="thinborder" width="10%">Account Code </td>
      <td class="thinborder" width="15%">Classification Name  </td>
      <td class="thinborder" width="7%">Delete</td>
    </tr>
<% 
for(int i = 0; i < vRetResult.size(); i += 4){%>
    <tr>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" align="center">
	  	<input type="button" name="1" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;"  onClick="DeleteRecord('<%=vRetResult.elementAt(i)%>');">
	  </td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>