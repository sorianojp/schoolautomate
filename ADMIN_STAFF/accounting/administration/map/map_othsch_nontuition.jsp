<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Click Ok to confirm delete.'))
			return;
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}

///for ajax.. 
var objCOA;
function MapCOAAjax(strCoaFieldName, strParticularFieldName) {
		objCOA=document.getElementById(strParticularFieldName);
		if(strParticularFieldName == 'coa_info_d')
			document.getElementById('coa_info_c').innerHTML='';
		else
			document.getElementById('coa_info_d').innerHTML='';
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var objCOAInput;
		eval('objCOAInput=document.form_.'+strCoaFieldName);
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name="+strCoaFieldName;
		this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	//objCOA.innerHTML = "<b>"+strAccountName+"</b>";
	objCOA.innerHTML = "";
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
								"Admin/staff-Accounting-Administration","map_othsch_nontuition.jsp");
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
	if(adm.operateOnOthSchFeeNonTuitionMappingNEW(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strErrMsg = "Operation successful.";

	}
}

	vRetResult = adm.operateOnOthSchFeeNonTuitionMappingNEW(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = adm.getErrMsg();
%>
<form action="./map_othsch_nontuition.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: LINK OTHER SCHOOL FEE - NON TUITION ::::</strong></font></div></td>
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
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-weight:bold; font-size:11px; color:#0000FF">&nbsp;</td>
      <td colspan="2" style="font-size:11px;" align="right">
	  <a href="../map_coa_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a> Go Back To Main</td>
    </tr>
    
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Fee Name (SA) </td>
      <td colspan="3">
		<select name="fee_name_sa" onChange="document.form_.page_action.value='';document.form_.fee_name_map.value=document.form_.fee_name_sa[document.form_.fee_name_sa.selectedIndex].value;">
	<option value=""></option>
<%
	strTemp = " where not exists (select * from FA_COLLEGE_OTHSCH_FEE where FEE_NAME_SA = fee_name) " + 
		 " and is_valid = 1 and not exists (select * from FA_OTH_SCH_FEE_TUITION where FEE_NAME_T = fee_name) ";
		
%>
	  <%=dbOP.loadCombo("distinct fa_oth_sch_fee.fee_name","fa_oth_sch_fee.fee_name", " from fa_oth_sch_fee " + strTemp,	WI.fillTextValue("college"),false)%>
		</select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Name (MAPPED) </td>
      <td colspan="3">
	  <input type="text" name="fee_name_map" size="60" value="<%=WI.fillTextValue("fee_name_map")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td>COA Debit </td>
      <td colspan="3">
		<input name="coa_d" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("coa_d")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('coa_d', 'coa_info_d');" autocomplete="off">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>COA Credit </td>
      <td colspan="3"><input name="coa_c" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("coa_c")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('coa_c', 'coa_info_c');" autocomplete="off"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Display Order </td>
      <td colspan="3">
	  <select name="disp_order">
<%
strTemp = WI.fillTextValue("disp_order");
int iDef = 0;
if(strTemp.length() > 0)
	iDef = Integer.parseInt(strTemp);
	
	for(int i =1; i < 501; ++i) {
		if(iDef == i)
			strTemp = " selected";
		else	
			strTemp = "";
		%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
		<%}%>
		</select>	  </td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td colspan="3"><label id="coa_info_d" style="font-size:11px; position:absolute"></label><label id="coa_info_c" style="font-size:11px; position:absolute"></label></td>
    </tr>
    <tr>
      <td height="45">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td width="32%" align="center"><input type="submit" name="122" value="Add Mapping" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='1';"></td>
      <td width="40%" align="center">&nbsp;</td>
      <td width="10%" align="center">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr bgcolor="#CCCCCC" style="font-weight:bold">
		<td height="22" class="thinborder" width="4%">Order#</td>
		<td width="20%" class="thinborder"> Name (SA) </td>
		<td width="20%" class="thinborder">MAP Name </td>
		<td width="15%" align="center" class="thinborder">DEBIT Account </td>
        <td width="15%" align="center" class="thinborder">CREDIT Account </td>
	    <td width="5%" align="center" class="thinborder">Delete</td>
  	</tr>
<%
for(int i =0; i < vRetResult.size(); i += 8) {%>
  	<tr>
		<td height="24" class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 1)%><br><%=vRetResult.elementAt(i + 2)%></td>
        <td class="thinborder"><%=vRetResult.elementAt(i + 3)%><br><%=vRetResult.elementAt(i + 4)%></td>
  	    <td class="thinborder" align="center">
			<input type="submit" name="122" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
		  onClick="PageAction('0','<%=vRetResult.elementAt(i)%>')">	  </td>
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
