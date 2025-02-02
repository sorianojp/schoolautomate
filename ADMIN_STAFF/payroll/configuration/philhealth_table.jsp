<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Philhealth Contribution Setting</title>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
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
function ComputeContributionR1() {
	var Range1 = document.form_.range_1.value;
	var Range2 = document.form_.range_2.value;
	if(Range1.length == 0 || eval(Range1) == 0)
		return;
	document.form_.range_2.value = eval(Range1) + 999.99;
	this.ComputeContribution(Range1);
}
function ComputeContributionR2() {
	var Range1 = document.form_.range_1.value;
	var Range2 = document.form_.range_2.value;
	if(eval(Range1) != 0)
		return;
	if(Range2.length == 0 || eval(Range2) < 999.99)
		return;
	this.ComputeContribution(eval(Range2) - 999.99);
}
function ComputeContribution(SalBase) {
	var PS      = eval(SalBase) * 125;
	var ES      = PS;
		
	document.form_.sal_base.value = SalBase;
	document.form_.ps.value   = eval(PS)/10000;
	document.form_.es.value   = document.form_.ps.value;
	document.form_.tot.value =2 * eval(document.form_.ps.value);
}
function AnUpClicked() {
	if(document.form_.checkbox.checked) {
		document.form_.range_2.value = "";
		document.form_.range_2.disabled = true;
	}
	else {	
		document.form_.range_2.disabled = false;
		document.form_.range_2.focus();
	}
}
function CancelRecord(){
	location = "./philhealth_table.jsp";
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
	<jsp:forward page="./philhealth_table_print.jsp" />
	<% return;	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Philhealth Table","philhealth_table.jsp");
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
														"Payroll","CONFIGURATION-PH",request.getRemoteAddr(),
														"philhealth_table.jsp");
if(iAccessLevel == 0){
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"philhealth_table.jsp");
}														
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
		if(prConfig.operateOnPHTable(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prConfig.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Philhealth table information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Philhealth table information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Philhealth table information successfully removed.";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = prConfig.operateOnPHTable(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = prConfig.getErrMsg();
}

	vRetResult  = prConfig.operateOnPHTable(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prConfig.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./philhealth_table.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: PHILHEALTH TABLE PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Effectivity Date</td>
      <td width="78%" colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(0);
else	
	strTemp = WI.fillTextValue("imp_date");
if(strTemp.length() == 0 && vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(0);
%>
        <input name="imp_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.imp_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      </td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Monthly Salary Bracket </td>
      <td colspan="2"><%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("sal_bracket");
%>
        <input name="sal_bracket" type="text"  size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        <select name="con_unit">
          <option value="0">Percentage of</option>
          <%
			if(vEditInfo != null && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(2);
			else	
				strTemp = WI.fillTextValue("con_unit");
			if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Fixed Amount</option>
          <%}else{%>
          <option value="1">Fixed Amount</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Monthly Salary Range</td>
      <td colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("range_1");
%>	  
		<input name="range_1" type="text" size="8" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
		onKeyUp="ComputeContributionR1()">
        to 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("range_2");
%>        
		<input name="range_2" type="text" size="8" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode == 47 || event.keyCode > 57) event.returnValue=false;"
		onKeyUp="ComputeContributionR2()">
        <input type="checkbox" name="checkbox" value="1" onClick="AnUpClicked();">
        and Up (NOTE : For &quot;and below&quot; use range1 = 0 and range2 = value)</td>
    </tr>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td height="30">Salary Base</td>
      <td height="30"  colspan="2"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("sal_base");
%>	  <input name="sal_base" type="text"  size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Personal Share (PS)</td>
      <td height="25" colspan="2"><strong> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("ps");
%>        <input name="ps" type="text"  size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        (Salary base * 1.25%)</strong></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td width="19%" height="24">Employer Share (ES)</td>
      <td height="24" colspan="2"><strong> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("es");
%>
        <input name="es" type="text"  size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        (PS = ES)</strong></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27">Total Monthly Premium </td>
      <td height="27" colspan="2"><strong> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("tot");
%>        <input name="tot" type="text"  size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" readonly>
        (PS + ES)</strong></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td height="35" valign="bottom">&nbsp;</td>
      <td height="35" colspan="2" valign="bottom"><font size="1">
				<%if(iAccessLevel > 1){%>
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <!--
				<a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:PageAction('1','');">
        Click to save entries 
        <%}else{%>
        <!--
				<a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
				-->
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;"
				onClick="javascript:PageAction('2','');">				
        Click to edit event 
        <%}%>
        <!--
				<a href="./philhealth_table.jsp"><img src="../../../images/cancel.gif" border="0"></a> 
				-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">				
        Click to clear </font>
				<%}%>
			</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
      <td height="10" colspan="2" valign="bottom">&nbsp;</td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
      to print result</font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="8" align="center" bgcolor="#B9B292" class="thinborder">PHILHEALTH 
          SCHEDULE OF CONTRIBUTIONS FOR EMPLOYED MEMBERS EFFECTIVE <%=(String)vRetResult.elementAt(8)%></td>
    </tr>
    <tr>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>MONTHLY 
      SALARY BRACKET </strong></font></td> 
      <td width="23%" height="25" align="center" class="thinborder"><font size="1"><strong>MONTHLY 
      SALARY  RANGE</strong></font></td>
      <td width="16%" align="center" class="thinborder"><font size="1"><strong>SALARY 
      BASE</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>TOTAL 
      MONTHLY PREMIUM CONTRIBUTION</strong></font></td>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong>PERSONAL 
          SHARE (PS)<br>
      (PS = SB *1.25%)</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>EMPLOYER 
          SHARE (ES)<br>
      (ES =PS) </strong></font></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">EDIT 
      </font> </strong> </td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">DEL</font></strong></td>
    </tr>
    <% for(int i =1; i < vRetResult.size(); i += 10){%>
    <tr>
      <td align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 9)%></font></td> 
      <td height="25" align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 8)%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3),true)%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 6),true)%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 4),true)%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 5),true)%></font></td>
      <td align="center" class="thinborder">  
        <%if(iAccessLevel > 1){%>
        <!--
					<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
					-->
				<input type="button" name="edit2" value=" Edit " style="font-size:11px; height:24px;border: 1px solid #FF0000;" onClick="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
        <%}%>&nbsp;</td>
      <td align="center" class="thinborder">  
        <%if(iAccessLevel == 2){%>
        <!--
					<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
					-->
				<input type="button" name="delete" value="Delete" style="font-size:11px; height:24px;border: 1px solid #FF0000;" onClick="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
        <%}else{%>
	  		N/A
	      <%}%>      </td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
