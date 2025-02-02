<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">	
	function PageAction(strAction, strInfoIndex) {		
		document.form_.page_action.value = strAction;
		if(strAction == '0') {
			if(confirm("Are you sure you want to delete this record?")){
				document.form_.page_action.value ='0';								
			}
			document.form_.info_index.value = strInfoIndex;	
		}
		document.form_.submit();
	}
	function ReloadPage() {
		document.form_.page_action.value = '';
		document.form_.info_index.value ='';
		document.form_.submit();
	}
</script>
<%@ page language="java" import="utility.*,java.util.Vector, enrollment.FAFeeMaintenance " %>
<%
	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);
	Vector vRetResult = null;
	String strErrMsg  = null;
	String strTemp    = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-set up trust fund","setup_trust_fund_ub.jsp");
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
	
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"setup_trust_fund_ub.jsp");
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
FAFeeMaintenance FFM = new FAFeeMaintenance();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(FFM.operateOnUBTrustFundSetting(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = FFM.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
String strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() == 0 ) 
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strSYFrom == null)
	strSYFrom = "";

request.setAttribute("sy_f", strSYFrom);
vRetResult = FFM.operateOnUBTrustFundSetting(dbOP, request, 4);

boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) 
	bolIsBasic = true;
%>
<body>
<form name="form_" method="post" action="setup_trust_fund_ub.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" size="2"><strong>:::: ADD/DROP MAIN PAGE ::::</strong></font></td>
    </tr>    
		<tr bgcolor="#FFFFFF">
      <td height="30"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></font></td>
    </tr>	
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
	<tr>
	  <td height="25">&nbsp;</td>
	  <td style="font-size:9px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%> onClick="ReloadPage();"> Is Grade School </td>
	  <td >&nbsp;</td>
    </tr>
<%if(bolIsBasic){%>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >Education Level Name </td>
	  <td >
	  <select name="edu_level" onChange="ReloadPage();">
<%
Vector vEduLevel = new Vector();
vEduLevel.addElement("1");vEduLevel.addElement("Preparatory");
vEduLevel.addElement("2");vEduLevel.addElement("Elementary");
vEduLevel.addElement("3");vEduLevel.addElement("Secondary");
vEduLevel.addElement("4");vEduLevel.addElement("VDT-Preparatory");
vEduLevel.addElement("5");vEduLevel.addElement("VDT-Elementary");
vEduLevel.addElement("6");vEduLevel.addElement("VDT-Secondary");

strTemp = WI.fillTextValue("edu_level");
for(int i = 0; i < vEduLevel.size(); i += 2) {
	if(strTemp.equals(vEduLevel.elementAt(i)))
		strErrMsg = " selected";
	else	
		strErrMsg = "";
	%>
	<option value="<%=vEduLevel.elementAt(i)%>"<%=strErrMsg%>><%=vEduLevel.elementAt(i + 1)%></option>
        <%//=dbOP.loadCombo("distinct EDU_LEVEL","EDU_LEVEL_NAME"," from BED_LEVEL_INFO order by EDU_LEVEL", WI.fillTextValue("edu_level"), false)%>
<%}%>
	  </select>
	  
	  </td>
    </tr>
<%}%>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >SY From/Term </td>
	  <td >
			<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
	  - 
<%
strTemp = WI.fillTextValue("semester");
%> <select name="semester">
   <option value="">Applicable for ALL</option>

<%
if(strTemp.compareTo("0") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
   <option value="0"<%=strErrMsg%>>Summer</option>
<%
if(strTemp.compareTo("1") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1"<%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.compareTo("2") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
        </select>			</td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >Other School Fee Name </td>
	  <td ><select name="oth_sch" >
        <option value=""></option>
<%
//get sy_index
strTemp = "select sy_index from fa_schyr where sy_from = "+strSYFrom;
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
strTemp = " from fa_oth_sch_fee where is_valid = 1 and sy_index = "+strTemp+" and (fee_name like 'entrance fee' or fee_name like 'Varsitarian' or "+
			"fee_name like 'id' or fee_name like 'library card' or fee_name like 'handbook' or fee_name like 'insurance' or fee_name like 'Envelope' or "+
			"fee_name like 'ubssg' or fee_name like 'id sticker' or fee_name like '%') order by fee_name ";	
%>
				
        <%=dbOP.loadCombo("othsch_fee_index","fee_name",strTemp, WI.fillTextValue("oth_sch"), false)%>
      </select></td>
	</tr>
	<tr>
	  <td width="2%" height="25">&nbsp;</td>
	  <td width="23%" >Applicable For </td>
	  <td width="75%" >
	  <select name="is_new">
	  <option value="1">New</option>
<%
strTemp = WI.fillTextValue("is_new");
if(strTemp.equals("0"))
	strTemp = " selected";
else	
	strTemp = "";
%>
	  <option value="0" <%=strTemp%>>Old</option>
	  </select>	  </td>
    </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >Amount</td>
	  <td >
	  <input name="amount" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
	<tr>
	  <td height="21" >&nbsp;</td>
	  <td >Postable Status </td>
	  <td >
	  <select name="is_postable">
	  <option value="0">Non-Postable</option>
<%
strTemp = WI.fillTextValue("is_postable");
if(strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%>
	  <option value="1" <%=strTemp%>>Postable</option>
	  </select>	  </td>
    </tr>
	<tr>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td ><input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1', '');" />
  	  <font size="1">click to save entries</font></td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="7" bgcolor="#cccccc" class="thinborderTOPLEFTRIGHT"><div align="center"><strong><font size="2">List of Trust Fund</font></strong></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFCC" style="font-weight:bold"> 
      <td height="25" class="thinborder" width="35%">FeeName</td>
      <td class="thinborder" width="10%">Student Type</td>
      <td class="thinborder" width="10%">Semester</td>
      <td class="thinborder" width="15%">Amount</td>
      <td class="thinborder" width="10%">Is Postable </td>
      <td class="thinborder" width="10%">Delete</td>
    </tr>
<%
String[] astrConvertStudType = {"OLD", "NEW"};
String[] astrConvertPostableType = {"Non-Postable", "Postable"};
for(int i = 0; i < vRetResult.size(); i += 7) {%>
    <tr> 
      <td height="25" class="thinborder" width="35%"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder" width="10%"><%=astrConvertStudType[Integer.parseInt((String)vRetResult.elementAt(i + 2))]%></td>
      <td class="thinborder" width="10%"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "All")%></td>
      <td class="thinborder" width="15%"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder" width="15%"><%=astrConvertPostableType[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%></td>
      <td class="thinborder" width="10%"><a href="javascript:PageAction(0, '<%=vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
<%}%>
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
</form>
</body>
</html>

<%
if(dbOP!=null)
	dbOP.cleanUP();
%>

