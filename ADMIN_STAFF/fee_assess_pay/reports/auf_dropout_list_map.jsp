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
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,java.util.Vector" %>
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

DailyCashCollection dcc = new DailyCashCollection();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(dcc.operateOnAUFDropoutListMap(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = dcc.getErrMsg();
	else	
		strErrMsg = "Successfully updated.";

}
vRetResult = dcc.operateOnAUFDropoutListMap(dbOP, request, 4);
if(vRetResult == null)
	dcc.getErrMsg();

%>


<form name="form_" action="./auf_dropout_list_map.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: MAP OTHER CHARGES
         ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%">Fee Name (SA) </td>
      <td colspan="3">
		<select name="fee_name_sa">
<%
strTemp = WI.fillTextValue("fee_name_sa");
%>
		<%=dbOP.loadCombo("distinct fa_misc_fee.fee_name","fa_misc_fee.fee_name"," from fa_misc_fee where is_valid = 1 and misc_other_charge=1 and not exists (select * from AUF_DROPOUTLIST_MAP where FEE_NAME_SA = fee_name) order by fa_misc_fee.fee_name",strTemp,false)%> 
		</select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Name (MAP) </td>
      <td colspan="3">
	  <input type="text" name="fee_name_sap" size="60" value="<%=WI.fillTextValue("fee_name_sap")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    
    <tr>
      <td height="45">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td width="31%" align="center"><input type="submit" name="122" value="Add Mapping" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='1';"></td>
      <td width="41%" align="center">&nbsp;</td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr bgcolor="#CCCCCC" style="font-weight:bold">
		<td height="22" class="thinborder" width="4%">Count#</td>
		<td width="23%" class="thinborder">Fee Name (SA) </td>
		<td width="23%" class="thinborder">Fee Name (MAP) </td>
		<td width="8%" align="center" class="thinborder">Delete</td>
  	</tr>
<%int iMaxDisp = 0;
for(int i =0; i < vRetResult.size(); i += 4) {%>
  	<tr>
		<td height="24" class="thinborder"><%=++iMaxDisp%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		<td class="thinborder" align="center">
			<input type="submit" name="122" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='0';document.form_.info_index.value=<%=vRetResult.elementAt(i)%>">	  </td>
  	</tr>
<%}%>
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
<input type="hidden" name="info_index">
<input type="hidden" name="is_oc" value="<%=WI.fillTextValue("is_oc")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
