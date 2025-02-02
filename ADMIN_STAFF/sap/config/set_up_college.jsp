<%if(request.getSession(false).getAttribute("is_sap") == null) {%>
	<p style="font-family:Verdana, Arial, Helvetica, sans-serif; font-weight:bold; font-size:18px; color:#FF0000">You are either logged out or not authorized to view this link. </p>
	<%return;

}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;

	document.form_.submit();
}


</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,sap.Configuration,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation();

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
Vector vRetResult  = null;

Configuration conf = new Configuration();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(conf.operateOnCollege(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = conf.getErrMsg();
	else	
		strErrMsg = "Successfully updated.";

}
vRetResult = conf.operateOnCollege(dbOP, request, 4);
if(vRetResult == null)
	conf.getErrMsg();
%>


<form name="form_" action="./set_up_college.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: SET COLLEGE - COST CENTER INFORMATION ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr bgcolor="#CCCCCC" style="font-weight:bold">
		<td height="22" class="thinborder">Count#</td>
		<td class="thinborder">College Code</td>
		<td class="thinborder">College Name</td>
		<td class="thinborder">Group Code</td>
		<td class="thinborder">Section Code</td>
		<td class="thinborder">Profit Center</td>
		<td class="thinborder" align="center">Select</td>
	</tr>
<%int iMaxDisp = 0;
for(int i =0; i < vRetResult.size(); i += 6) {%>
  	<tr>
		<td height="24" class="thinborder"><%=iMaxDisp + 1%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		<td class="thinborder"><input size="6" type="text" name="sap_grp_code_<%=iMaxDisp%>" value="<%=WI.getStrValue(vRetResult.elementAt(i + 3))%>" class="textbox"></td>
		<td class="thinborder"><input size="6" type="text" name="sap_section_code_<%=iMaxDisp%>" value="<%=WI.getStrValue(vRetResult.elementAt(i + 4))%>" class="textbox"></td>
		<td class="thinborder"><input size="6" type="text" name="sap_profit_center_<%=iMaxDisp%>" value="<%=WI.getStrValue(vRetResult.elementAt(i + 5))%>" class="textbox"></td>
		<td class="thinborder" align="center"><input type="checkbox" name="info_index_<%=iMaxDisp++%>" value="<%=vRetResult.elementAt(i)%>"></td>
	</tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">  
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
  	  <td width="4%" height="24">&nbsp;</td>
  	  <td width="28%">&nbsp;</td>
  	  <td width="16%"><input type="submit" name="122" value="-- SAVE/Update Information --" style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='2';"></td>
  	  <td width="6%">&nbsp;</td>
  	  <td width="38%"><input type="submit" name="1222" value="-- Delete Information --" style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='0';"></td>
  	  <td width="4%">&nbsp;</td>
  	  <td width="4%" align="center">&nbsp;</td>
    </tr>
  </table>  
  
  
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
