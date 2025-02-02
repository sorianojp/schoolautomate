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
	if(conf.operateOnMiscFeeMap(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = conf.getErrMsg();
	else	
		strErrMsg = "Successfully updated.";

}
vRetResult = conf.operateOnMiscFeeMap(dbOP, request, 4);
if(vRetResult == null)
	conf.getErrMsg();


//get here misc fee not yet mapped. 
strTemp = "select distinct fee_name, misc_other_charge from fa_misc_fee where is_valid = 1 and not exists (select * from SAP_MISC_FEE_MAP where FEE_NAME_SA = fee_name and IS_OTH_CHARGE = misc_other_charge) order by misc_other_charge asc, fee_name";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
Vector vFeeSA = new Vector();
String[] astrConvertMiscOthCharge = {"(Misc)","(OC)"};
while(rs.next()) {
	vFeeSA.addElement(rs.getString(1));
	vFeeSA.addElement(astrConvertMiscOthCharge[rs.getInt(2)]);
}
rs.close();

%>


<form name="form_" action="./map_ar_fee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: MAP <%if(WI.fillTextValue("is_oc").equals("2")){%>OTHER SCHOOL FEE (TUITION)<%}else{%>MISC/OTHER CHARGES<%}%> ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(WI.fillTextValue("is_oc").equals("2")){%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%">Fee Name (SA) </td>
      <td colspan="3">
		<select name="fee_name_sa">
<%
strTemp = WI.fillTextValue("fee_name_sa");
%>
		<%=dbOP.loadCombo("distinct fa_oth_sch_fee.fee_name","fa_oth_sch_fee.fee_name"," from fa_oth_sch_fee where is_valid = 1 and exists (select * from FA_OTH_SCH_FEE_TUITION where fee_name_t = fee_name) and not exists (select * from SAP_MISC_FEE_MAP where fee_name_sa = fee_name and is_oth_charge = 2) order by fa_oth_sch_fee.fee_name",strTemp,false)%> 
		</select>	  
	  </td>
    </tr>
<%}else{%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%">Fee Name (SA) </td>
      <td colspan="3">
		<select name="fee_name_sa">
<%
strTemp = WI.fillTextValue("fee_name_sa");
for(int i = 0; i < vFeeSA.size(); i += 2) {
	if(strTemp.equals(vFeeSA.elementAt(i)))
		strErrMsg = " selected";
	else
		strErrMsg = "";
	%>
	<option value="<%=vFeeSA.elementAt(i)%><%=vFeeSA.elementAt(i + 1)%>" <%=strErrMsg%>><%=vFeeSA.elementAt(i)%> <%=vFeeSA.elementAt(i + 1)%></option>
	
<%}%>
		</select>	  
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Name (SAP) </td>
      <td colspan="3">
	  <input type="text" name="fee_name_sap" size="60" value="<%=WI.fillTextValue("fee_name_sap")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Code </td>
      <td colspan="3">
	  <input type="text" name="fee_code" size="12" value="<%=WI.fillTextValue("fee_code")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Type </td>
      <td colspan="3">
	  <input type="text" name="fee_type" size="12" value="<%=WI.fillTextValue("fee_type")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Type Short </td>
      <td colspan="3">
	  <input type="text" name="fee_type_short" size="12" value="<%=WI.fillTextValue("fee_type_short")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Account Code </td>
      <td colspan="3">
	  <input type="text" name="sap_account_code" size="32" value="<%=WI.fillTextValue("sap_account_code")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
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
		<td width="23%" class="thinborder">Fee Name (SAP) </td>
		<td width="9%" class="thinborder">Fee Code </td>
		<td width="8%" class="thinborder">Fee Type </td>
		<td width="9%" class="thinborder">Fee Type Short </td>
		<td width="16%" align="center" class="thinborder">SAP Account Code </td>
	    <td width="8%" align="center" class="thinborder">Delete</td>
  	</tr>
<%int iMaxDisp = 0;
for(int i =0; i < vRetResult.size(); i += 8) {%>
  	<tr>
		<td height="24" class="thinborder"><%=++iMaxDisp%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
  	    <td class="thinborder" align="center">
			<input type="submit" name="122" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='0';document.form_.info_index.value=<%=vRetResult.elementAt(i)%>">
		  </td>
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
