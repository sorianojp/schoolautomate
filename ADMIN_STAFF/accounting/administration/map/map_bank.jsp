<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../Ajax/ajax.js"></script>
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
function UpdateTaxCode() {
	var loadPg = "./tax_code.jsp";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			document.form_.coa_.value+"&coa_field_name=coa_&is_blur="+strIsBlur;
		this.processRequest(strURL);
}
function COASelected(strAccountName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>

<body bgcolor="#D2AE72">
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
								"Admin/staff-Accounting-Administration","map_bank.jsp");
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
	if(adm.operateOnBankMappingNew(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strErrMsg = "Bank added successfully.";
	}
}
vRetResult = adm.operateOnBankMappingNew(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = adm.getErrMsg();

%>
<form action="./map_bank.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td  height="27" colspan="8" bgcolor="#B5AB73"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          LINK BANKS PAGE ::::</strong></font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp;</td>
      <td colspan="2" style="font-size:13px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%" style="font-size:11px;">Bank Code</td>
      <td width="80%" height="25">
	  <select name="bank_index" style="font-size:11px; color:#0000FF">
      	<%=dbOP.loadCombo("BANK_INDEX","BANK_NAME, BRANCH", " from FA_BANK_LIST where is_valid = 1 and not exists (select * from FA_COLLEGE_CASHINBANK where FA_COLLEGE_CASHINBANK.bank_index = fa_bank_list.bank_index) order by bank_code", request.getParameter("bank_index"), false)%>
      </select></td>
    </tr>
    
    <tr> 
      <td>&nbsp;</td>
      <td style="font-size:11px;" valign="top">Chart of Account #</td>
      <td valign="top">
	  <input name="coa_" type="text" size="16" value="<%=WI.fillTextValue("coa_")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="MapCOAAjax('0');"></td>
    </tr>
    <tr> 
      <td></td>
      <td></td>
      <td><label id="coa_info" style="font-size:11px; position:absolute"></label></td>
    </tr>
    <tr> 
      <td height="37">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%if(iAccessLevel > 1) {%>
	  <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
<%}%>
	</td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: 
          LIST OF BANKS IN RECORD :: </strong></font></div></td>
    </tr>
    <tr> 
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>BANK CODE</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>BANK NAME</strong></font></div></td>
      <td width="9%" height="25" class="thinborder"><div align="center"><font size="1"><strong>CHART OF ACCOUNT 
          NO. </strong></font></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong><font size="1">CHART OF ACCOUNT NAME</font></strong></div></td>
      <td width="5%" class="thinborder">&nbsp;</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i +=5){%>
    <tr> 
      <td class="thinborder"><font size="1"><!--ALLIED--><%=vRetResult.elementAt(i + 3)%></font></td>
      <td class="thinborder"><font size="1"><!--Allied Bank Corporation--><%=vRetResult.elementAt(i + 4)%></font></td>
      <td class="thinborder"><font size="1"><!--1324--><%=vRetResult.elementAt(i + 1)%></font></td>
      <td height="25" class="thinborder"><font size="1"><!--Allied Savings for Account #1241464-->
		  <%=vRetResult.elementAt(i + 2)%></font></td>
      <td class="thinborder">
<%if(iAccessLevel > 1) {%>	  
	  <input type="submit" name="125" value="Delete" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
<%}else{%>&nbsp;<%}%>	  </td>
    </tr>
<%}%>
  </table>
<%}//show only if vRetResult is not null %>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="27" bgcolor="#B5AB73">&nbsp;</td>
    </tr>
  </table>


<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>