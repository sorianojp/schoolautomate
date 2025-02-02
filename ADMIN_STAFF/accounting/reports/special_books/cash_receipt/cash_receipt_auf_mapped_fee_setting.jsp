<%@ page language="java" import="utility.*, java.util.Vector" %>
<%
WebInterface WI          = new WebInterface(request);
DBOperation dbOP         = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.


String strReportType = WI.fillTextValue("report_format");
String strErrMsg     = null;
String strTemp       = null;
Accounting.CashReceiptBook CRB = new Accounting.CashReceiptBook();

Vector vRetResult  = null; 
Vector vEncoded    = null;
Vector vNotEncoded = null;

dbOP = new DBOperation();
String strPageOption = WI.fillTextValue("page_option");


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(CRB.operateOnOtherIncomeDisplaySetting(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = CRB.getErrMsg();
	else{	
		if(strTemp.equals("0"))
			strErrMsg = "Entry successfully deleted.";
		else		
			strErrMsg = "Entry successfully mapped.";
	}
}


	vRetResult = CRB.operateOnOtherIncomeDisplaySetting(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = CRB.getErrMsg();


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../../Ajax/ajax.js"></script>
<script language="javascript">

function PageAction(strAction, strInfoIndex) {
	if(strAction == "0"){
		if(!confirm("Do you want to delete this entry? "))
			return;
	}
	
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./cash_receipt_auf_mapped_fee_setting.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A" align="center"><font color="#FFFFFF"> <strong>:::: MAPPED FEE ADDITIONAL SETTING ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="2">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    
    <tr>
      <td width="3%" height="24">&nbsp;</td>
      <td width="15%"> Fee Name </td>
      <td width="82%">
<%
	strTemp = " where not exists (select * " + 
		 " from AC_FEE_COLLECTION_MAP_OTHER_CONF where FEE_NAME_MAP = MAPPED_FEE_NAME and page_option = "+strPageOption+") order by AC_FEE_COLLECTION_MAP.fee_name_map";
%>
	  <select name="map_fee_name">
	  <%=dbOP.loadCombo("distinct AC_FEE_COLLECTION_MAP.fee_name_map"," AC_FEE_COLLECTION_MAP.fee_name_map", " from AC_FEE_COLLECTION_MAP " + 
							strTemp,WI.fillTextValue("map_fee_name"),false)%>
	  </select>	  </td>
    </tr>
	
    <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="14%" height="25">&nbsp;</td>
      <td width="86%" height="25" style="font-size:10px;">
	  	<a href="javascript:PageAction('1','');"><img src="../../../../../images/save.gif" border="0"></a>click to save info</td>
    </tr>
    <tr> 
      <td height="" colspan="2">&nbsp;</td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr bgcolor="#CCCCCC">
		  <td width="85%" height="25" class="thinborder" style="font-size:9px; font-weight:bold" align="center"> 
		  <%if(strPageOption.equals("0")){%>
		  	Mapped Fee to Display Details
		  <%}else{%>
		  	Mapped Fee to Have a Total
		  <%}%>
		  </td>
		  <td width="15%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">DELETE</td>
		</tr>
		<%for (int i = 0; i < vRetResult.size() ; i+= 2) {%>
			<tr>
			  <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%> </td>
			  <td class="thinborder" align="center">
			 <% if (iAccessLevel == 2) {%> 
				<input type="submit" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
				 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>')">
			 <%}else{%> N/A <%}%>	  </td>
			</tr>
		<%}%> 
	</table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td width="100%" height="25" colspan="2">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="page_action">  
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">  
<input type="hidden" name="page_option" value="<%=strPageOption%>">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>