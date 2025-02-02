<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Tax Table</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function CancelRecord(){
	location = "./tax_table.jsp";
}

function PrintPg()
{
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./tax_table_print.jsp" />
<% return;	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Tax Table","tax_table.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"tax_table.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

	PayrollConfig prConfig = new PayrollConfig();
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prConfig.operateOnTaxTable(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prConfig.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Tax table information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Tax table information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Tax table information successfully removed.";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = prConfig.operateOnTaxTable(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = prConfig.getErrMsg();
}

	vRetResult  = prConfig.operateOnTaxTable(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prConfig.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./tax_table.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: TAX TABLE PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="2" align="center">TAXABLE INCOME</td>
      <td align="center">TAX DUE</td>
    </tr>
    <tr> 
      <td width="2%" height="18">&nbsp;</td>
      <td width="28%" align="center">RANGE 1</td>
      <td width="28%" align="center">RANGE 2</td>
      <td width="42%">ex. P 500 + 10% of the excess over 10,000</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">
	  <select name="range_1_con" 
	  	style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="1">Over</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("range_1_con");
if(strTemp == null)
	strTemp = "";
	
if(strTemp.compareTo("0") == 0){%>
          <option value="0" selected>Not over</option>
<%}else{%>
          <option value="0">Not over</option>
<%}%>
        </select> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("range_1");
%>
		<input name="range_1" type="text" size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25">
	  <select name="range_2_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="1">Over</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("range_2_con");
if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("0") == 0){%>
          <option value="0" selected>But not over</option>
<%}else{%>
          <option value="0">But not over</option>
<%}%>
        </select> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("range_2");
%>
		<input name="range_2" type="text" size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("tax1");
%>	  <input name="tax1" type="text" size="6" maxlength="8" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        + 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("tax2");
%>        <input name="tax2" type="text" size="5" maxlength="8" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        % of excess over 
<!--
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("tax2_above");
%>        <input name="tax2_above" type="text" size="6" maxlength="12" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" readonly>
-->RANGE 1		</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
	<% if(iAccessLevel > 1){%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="9%" height="25">&nbsp;</td>
      <td width="65%" height="25"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>        
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');"> 
        Click to save entries 
        <%}else{%>
        <input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2', '');">
        Click to save changes 
        <%}%>
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
        Click to clear entries </font></td>
      <td width="24%" height="25">&nbsp;</td>
    </tr>
	<%}%>
  </table>
 <%
 if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
      to print result</font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="3" align="center" class="thinborder"><font color="#FFFFFF"><strong>TAX 
          TABLE ENTRIES </strong></font></td>
    </tr>
    <tr> 
      <td width="28%" height="25" align="center" class="thinborder"><strong>TAXABLE 
          INCOME </strong></td>
      <td width="48%" align="center" class="thinborder"><strong>TAX DUE</strong></td>
      <td width="24%" class="thinborder">&nbsp;</td>
    </tr>
<%
for(int i = 0; i < vRetResult.size() ; i += 10){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 9)%></td>
      <td align="center" class="thinborder"><font size="1">&nbsp; 
<%
if(iAccessLevel > 1){%>        
        <input type="button" name="edit2" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
<%}if(iAccessLevel == 2){%>
&nbsp;
				<input type="button" name="delete" value="Delete" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
<%}%>
        </font></td>
    </tr>
<%}%>
  </table>
 <%}//if vRetResult is not null%>
 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
