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

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(CRB.operateOnFeeMapping(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = CRB.getErrMsg();
	else{	
		if(strTemp.equals("0"))
			strErrMsg = "Entry successfully deleted.";
		else		
			strErrMsg = "Entry successfully mapped.";
	}
}


	vRetResult = CRB.operateOnFeeMapping(dbOP, request, 4);
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
<form name="form_" method="post" action="./map_fee.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A" align="center"><font color="#FFFFFF"> <strong>:::: OTHER SCHOOL FEE MAPPING  ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="2">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%">Fee Map Code </td>
      <td width="82%">
        <input name="fee_name_map" type="text" size="20" value="<%=WI.fillTextValue("fee_name_map")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';"> 
		
		
		
	  </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td> Fee Name </td>
      <td>
<%
	strTemp = " where not exists (select * " + 
		 " from  AC_FEE_COLLECTION_MAP where FEE_NAME_ORIG = fee_name) and is_valid = 1 order by fa_oth_sch_fee.fee_name";
%>
	  <select name="othsch_fee_name">
	  <%=dbOP.loadCombo("distinct fee_name"," fee_name", " from fa_oth_sch_fee " + 
							strTemp,WI.fillTextValue("othsch_fee_name"),false)%>
	  </select>	  </td>
    </tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td height="25">&nbsp;</td>
		<td colspan="4">		
		<%
		strTemp = WI.fillTextValue("is_itemize");
		if(strTemp.length() > 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<input type="checkbox" name="is_itemize" value="1" <%=strErrMsg%> >Is Itemize
		&nbsp; &nbsp; &nbsp;
		<%
		strTemp = WI.fillTextValue("is_sundry");
		if(strTemp.length() > 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<input type="checkbox" name="is_sundry" value="1" <%=strErrMsg%> >Is Sundry
		</td>
	</tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Display Order </td>
      <td> <select name="map_order">
	  <%int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("map_order"), "1"));
	  for(int i = 1 ; i < 50; ++i) {
	  	if( i == iDefVal)
			strTemp = " selected";
		else	
			strTemp = "";
		%><option value="<%=i%>"<%=strTemp%>><%=i%></option>
	  <%}%>
  	  </select></td>
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
    <tr>
      <td height="25" colspan="6" class="thinborder" style="font-size:9px;">Total Mapped : <%=vRetResult.size()/6%></td>
    </tr>
    <tr>
      <td width="6%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">DISP ORDER </td>
      <td width="28%" height="25" class="thinborder" style="font-size:9px; font-weight:bold" align="center"> FEE TO DISPLAY </td>
      <td width="42%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">OTHER SCHOOL FEE </td>
      <td width="8%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Is Itemize?</td>
      <td width="7%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Is Sundry?</td>
      <td width="9%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">DELETE</td>
    </tr>
<%
String[] strBGColor = {"#B9E3D8","#79b3a8","#e0e0d0"};
int iColCount = 0;
strErrMsg = "";
for (int i = 0; i < vRetResult.size() ; i+= 6) {
	if(strErrMsg.length() == 0)
		strErrMsg = (String)vRetResult.elementAt(i+3);
	else if(!strErrMsg.equals(vRetResult.elementAt(i+3)) ) {
		strErrMsg = (String)vRetResult.elementAt(i+3);
		++iColCount;
	}
	if(iColCount == 3)
		iColCount = 0;
%> 
    <tr bgcolor="<%=strBGColor[iColCount]%>">
	<%
	strTemp = (String)vRetResult.elementAt(i+3);
	if(strTemp.equals("0"))
		strTemp = "&nbsp;";
	%>
      <td class="thinborder"><%=strTemp%></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%> </td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%> </td>
	  <%
	  strTemp = (String)vRetResult.elementAt(i+4);
	  if(strTemp != null && strTemp.equals("1"))
	  	strTemp = "<img src='../../../../../images/tick.gif' border='0'>";
	  else
		strTemp = "";	
	  %>
      <td class="thinborder" align="center">&nbsp;<%=strTemp%></td>
	  <%
	  strTemp = (String)vRetResult.elementAt(i+5);
	  if(strTemp != null && strTemp.equals("1"))
	  	strTemp = "<img src='../../../../../images/tick.gif' border='0'>";
	  else
		strTemp = "";	
	  %>
      <td class="thinborder" align="center">&nbsp;<%=strTemp%></td>
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
<input type="hidden" name="show_list">  
<input type="hidden" name="page_action">  
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>