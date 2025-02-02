<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex, strGiftName) {
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
	location = "./cash_gift_list.jsp";
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Cash Gift List","cash_gift_list.jsp");
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
														"cash_gift_list.jsp");
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
	Vector vEditInfo  = null;
	Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prConfig.operateOnCashGift(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prConfig.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Cash gift information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Cash gift information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Cash gift information successfully removed.";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = prConfig.operateOnCashGift(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = prConfig.getErrMsg();
}

	vRetResult  = prConfig.operateOnCashGift(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prConfig.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="cash_gift_list.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL: CASH GIFT SETTING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td>Cash Gift Name  : </td>
			 <%
			if(vEditInfo != null && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(2);
			else	
				strTemp = WI.fillTextValue("gift_name");
			%>			
      <td width="77%"> <input name="gift_name" type="text" size="12" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    
    <tr> 
      <td height="10">&nbsp;</td>
      <td width="19%" height="10">Cash gift amount </td>
      <td height="10"> 
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(1);
		else	
			strTemp = WI.fillTextValue("amount");
		strTemp = ConversionTable.replaceString(strTemp,",","");
	  %> 
	  <input name="amount" type="text" size="8" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="35" colspan="3" align="center"><%if(iAccessLevel > 1){%>
				<font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <!--
					<a href='javascript:PageAction(1,"","");'><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
					-->
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','','');">					
        Click to save entries 
        <%}else{%>
        <!--
					<a href='javascript:PageAction(2, "","");'><img src="../../../../images/edit.gif" border="0"></a> 
					-->
        <input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2', '','');">
        Click to edit event 
        <%}%>
        <!--
          <a href="cash_gift_list.jsp"><img src="../../../../images/cancel.gif" border="0"></a> 
					-->
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">					
        Click to clear </font>
				<%}%></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"><div align="center"></div></td>
      <td height="25" colspan="4" align="center" bgcolor="#B9B292" class="thinborderBOTTOMLEFTRIGHT"><font color="#FFFFFF"><strong>CASH GIFT  SETTING</strong></font></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="15%">&nbsp;</td> 
      <td width="25%" height="25" align="center" class="thinborder"><strong>NAME</strong></td>
      <td width="23%" align="center" class="thinborder"><strong>CASH GIFT AMOUNT </strong></td>
      <td width="11%" align="center" class="thinborder"><strong>EDIT       </strong> </td>
      <td width="11%" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong>DELETE</strong></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <% for(int i =0; i < vRetResult.size(); i += 3){%>
    <tr>
      <td>&nbsp;</td> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%>&nbsp;</td>
      <td align="center" class="thinborder"> 
        <%if(iAccessLevel > 1){%> 
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/edit.gif" border="0"></a> 
        <%}%>      </td>
      <td align="left" class="thinborderBOTTOMLEFTRIGHT"> 
        <%if(iAccessLevel == 2){%> 
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i+2)%>");'><img src="../../../../images/delete.gif" border="0"></a> 
   	    <%}else{%>
	  	N/A
	    <%}%>	    </td>
      <td>&nbsp;</td>
    </tr>
    <%}//end of for loop%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25"  colspan="3"  class="footerDynamic">&nbsp;</td>
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
