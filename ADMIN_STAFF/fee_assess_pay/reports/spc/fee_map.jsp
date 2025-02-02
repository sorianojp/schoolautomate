<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
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
<%@ page language="java" import="utility.*,enrollment.SPC,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//authenticate user access level
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth.get("FEE ASSESSMENT & PAYMENTS") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}


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
Vector vRetResult   = null;
SPC  spc = new SPC();

if (WI.fillTextValue("page_action").equals("0")){
	if (spc.mapOtherSchFee(dbOP, request,0) != null)
		strErrMsg = " Fee mapping removed successfully";
	else
		strErrMsg= spc.getErrMsg();
}
else if (WI.fillTextValue("page_action").equals("1")){
	if (spc.mapOtherSchFee(dbOP, request,1) != null)
		strErrMsg = " Fee mapping added successfully";
	else
		strErrMsg= spc.getErrMsg();
}

vRetResult = spc.mapOtherSchFee(dbOP, request, 4);

%>


<form name="form_" action="./fee_map.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: MAP OTHE SCHOOL FEES::::</strong></font></div></td>
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
		<option value=""></option>
	  	<%=dbOP.loadCombo("distinct fa_oth_sch_Fee.fee_name"," fa_oth_sch_Fee.fee_name", " from fa_oth_sch_Fee  where fa_oth_sch_fee.is_valid = 1 and not exists (select * from SPC_OTHSCH_FEE_MAP where fee_name_sa = fee_name) order by fee_name",WI.fillTextValue("fee_name_sa"),false)%>
		</select>	  </td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Name (MAP) </td>
      <td colspan="3">
	  <input type="text" name="fee_name_spc" size="60" value="<%=WI.fillTextValue("fee_name_spc")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
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
		<td height="22" class="thinborder" width="6%">Count#</td>
		<td width="42%" class="thinborder">Fee Name (SA) </td>
		<td width="42%" class="thinborder">Fee Name (MAPPED) </td>
		<td width="10%" align="center" class="thinborder">Delete</td>
  	</tr>
<%int iMaxDisp = 0;
String strBGColor = "";
String strFeeNameSA = "";
for(int i =0; i < vRetResult.size(); i += 4) {
	if(!strFeeNameSA.equals(vRetResult.elementAt(i + 1))) {
		strFeeNameSA = (String)vRetResult.elementAt(i + 1);
		if(strBGColor.equals("#66CC99"))
			strBGColor = "#99CCCC";
		else	
			strBGColor = "#66CC99";
	}
		%>
  	<tr bgcolor="<%=strBGColor%>">
		<td height="24" class="thinborder"><%=++iMaxDisp%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		<td class="thinborder" align="center">
			<input type="button" name="122" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
		  onClick="PageAction('<%=vRetResult.elementAt(i)%>','0')">	  </td>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
