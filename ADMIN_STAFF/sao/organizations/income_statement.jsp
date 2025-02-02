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

function UpdateMainLevel(){
	if (document.form_.income_values.selectedIndex  != 0) {
		document.form_.main_level.value = document.form_.income_values[document.form_.income_values.selectedIndex].text;
	}
}

function Cancel() {
	location = "./income_statement.jsp?organization_id=" + document.form_.organization_id.value + 
	"&sy_from=" + document.form_.sy_from.value  + "&sy_to=" + document.form_.sy_to.value ;
}
function ReloadPage() {
	document.form_.print_page.value="";
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.print_page.value="";
	document.form_.submit();
}

function PrintIncomeStatement(){
	document.form_.print_page.value="1";
	document.form_.submit();
}

function DeleteRecord(strInfoIndex){
	document.form_.print_page.value="";
	document.form_.prepareToEdit.value="";	
	document.form_.page_action.value = "0";
	document.form_.info_index.value=strInfoIndex;
	document.form_.submit();
}


function PageAction(strAction) {
	document.form_.print_page.value="";
	document.form_.page_action.value = strAction;
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function FocusID() {
	document.form_.organization_id.focus();
}
function OpenSearch() {
	var pgLoc = "../search/srch_org.jsp?opner_info=form_.organization_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch2() {
	var pgLoc = "../search/srch_mem.jsp?opner_info=form_.EVALUATION_PREP_BY";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
 if (request.getParameter("print_page") != null && 
 	 request.getParameter("print_page").equals("1")){ %>
	 	<jsp:forward page="./income_statement_print.jsp" />
<%
 }



	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolHasAccess = false;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","year_end_report.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs",
														"ORGANIZATIONS",request.getRemoteAddr(),
														"year_end_report.jsp");
if (iAccessLevel > 0){
	bolHasAccess = true;
}

if (iAccessLevel == 0) 
	iAccessLevel = 2;
	
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
Vector vOrganizationDtl = null;
boolean bolNoRecord = false;//if it is true, it is having yearly report, activate EDIT.

String strOrgIndex = null;
Organization organization = new Organization();
Vector vRetResult = null;
Vector vEditInfo = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if(WI.fillTextValue("organization_id").length() > 0 && WI.fillTextValue("sy_from").length() > 0){
	vOrganizationDtl = organization.operateOnOrganization(dbOP, request,3);
	if(vOrganizationDtl == null)
		strErrMsg = organization.getErrMsg();
	else
	{
		strOrgIndex = (String)vOrganizationDtl.elementAt(0);
		if(WI.fillTextValue("organization_index").length() ==0) 
			request.setAttribute("organization_index",strOrgIndex);
	}
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(organization.operateOnOrgIncomeStatement(dbOP, request,Integer.parseInt(strTemp)) == null)
		strErrMsg = organization.getErrMsg();
	else {
		if (strTemp.equals("2")) 
		strPrepareToEdit ="";
			
		strErrMsg = "Operation successful";
	}
}

if (strPrepareToEdit.equals("1")){
	vEditInfo = organization.operateOnOrgIncomeStatement(dbOP, request,3);
	if (vEditInfo  == null) 
		strErrMsg = organization.getErrMsg();
}


if(WI.fillTextValue("sy_from").length() > 0 && strOrgIndex != null) {
	
	vRetResult = organization.operateOnOrgIncomeStatement(dbOP, request,4);
	if(vRetResult == null)
		strErrMsg = organization.getErrMsg();
}
if(vRetResult == null || vRetResult.size() ==0)
	bolNoRecord = true;

%>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<form action="./income_statement.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          ORGANIZATIONS - YEAR-END INCOME STATEMENT::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" >Organization ID</td>
      <td width="18%"> <input name="organization_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=WI.fillTextValue("organization_id")%>" size="16"></td>
      <td width="6%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="58%">
	  		<a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif"
													border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >School Year</td>
      <td colspan="3">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')">
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly></td>
    </tr>
  </table>
<%
if(vOrganizationDtl != null && vOrganizationDtl.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%" height="25">Organization name : <strong><%=(String)vOrganizationDtl.elementAt(2)%></strong></td>
      <td width="50%" height="25">Date accredited: <strong><%=(String)vOrganizationDtl.elementAt(3)%></strong></td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">College/Department : <strong><%=WI.getStrValue(vOrganizationDtl.elementAt(5))%><%=WI.getStrValue((String)vOrganizationDtl.elementAt(7),"/","","")%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><div align="right"><font size="1"><font size="1"><a 	href="activities_view_all.htm"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>c<font size="1">lick
          to view other activities of the organization</font></font></font></div></td>
    </tr> -->
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%}//only if organization information is correct.
if(WI.fillTextValue("sy_from").length() > 0 && vOrganizationDtl != null 
		&& vOrganizationDtl.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="12%">Cash Flow : </td>
      <td width="83%">
	  <select name="income_expense">
	   	<option value="0" selected> Income </option>
	  <% if (vEditInfo != null) 
	   		  strTemp = (String)vEditInfo.elementAt(3);
		 else
		  	  strTemp = WI.fillTextValue("income_expense");
			  
		 if (strTemp.equals("1")){
	  %> 		
		<option value="1" selected> Expense </option>
	<%}else{%>
		<option value="1"> Expense </option>
	<%}%> 	
      </select>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><select name="income_values" onChange="UpdateMainLevel()">
	  <option value=""> </option>
	  <%=dbOP.loadCombo("distinct income_expense","MAIN_LEVEL",
	  					" from OSA_ORG_INCOME_STATEMENT where is_del = 0 " +
						 " order by income_expense, main_level",WI.fillTextValue("income_values"), false)%>
      </select>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Main Level <font size="1">:</font></td>
      <td><font size="1">
        <%
if(vEditInfo == null)
	strTemp = WI.fillTextValue("main_level");
else
	strTemp = (String)vEditInfo.elementAt(4);
%>
        <input name="main_level" type="text" class="textbox" id="main_level" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="65">
      </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Sub Level
      :</td>
      <td>
  <%
	if(vEditInfo == null)
		strTemp = WI.fillTextValue("sub_level");
	else
		strTemp = WI.getStrValue((String)vRetResult.elementAt(5));
  %>
        <input name="sub_level" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="65">
        <font size="1">(optional) </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Amount&nbsp;&nbsp;:</td>
      <td><font size="1">
        <%
if(vEditInfo == null || vEditInfo.size() == 0)
	strTemp = WI.fillTextValue("amount");
else
	strTemp = (String)vEditInfo.elementAt(6);
%>
        <input name="amount" type="text" class="textbox" id="amount" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="10" onKeyUp="AllowOnlyFloat('form_','amount')">
      </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="25%" height="25"><div align="center">
      <% if (iAccessLevel > 1){ 
			if (vEditInfo == null) { %>
        <a href="javascript:PageAction(1);">
				<img src="../../../images/save.gif" border="0" name="hide_save"></a>
                <font size="1">click to save entries &nbsp;<a href='javascript:Cancel();'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
                to cancel and clear entries</font></font>
        <%}else{%>
                <a href="javascript:PageAction(2);"><img src="../../../images/edit.gif" border="0" name="hide_save"></a>
                <font size="1">click to save changes</font>
				<a href='javascript:Cancel();'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
                to cancel and clear entries</font>
				
		<%}
		}%>
	  </div></td>
    </tr>
    <tr>
      <td height="25"><hr size="1"></td>
    </tr>
  </table>

<%}//WI.fillTextValue("sy_from").length() > 0

	if (vRetResult != null && vRetResult.size() > 0) { 
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr >
    <td height="25" colspan="8"><div align="center"><strong>ORGANIZATION INCOME STATEMENT </strong><br>
    For School Year <%=WI.fillTextValue("sy_from") + " - " + WI.fillTextValue("sy_to")%></div></td>
    </tr>
  <tr>
    <td height="25" colspan="8">&nbsp;</td>
  </tr>
<% 
	String strIncomeExpense = "";
	String strCurrentMain = "";
	String[] astrIncomeExpense = {"INCOME", "EXPENSE"};
	String strAmount = "";
	strTemp ="";
	String strTotalIncome = (String)vRetResult.elementAt(1);
	String strTotalExpense  = "0.00";

	for (int i = 2; i < vRetResult.size() ; i+=5) {

	if (i==2 || !strIncomeExpense.equals((String)vRetResult.elementAt(i+1))) { 
		strIncomeExpense = WI.getStrValue((String)vRetResult.elementAt(i+1),"0.00");
		
 	 if (i != 2) {
		strTotalExpense = WI.getStrValue((String)vRetResult.elementAt(0),"0.00") ;
%> 
  <tr>
    <td width="12%" height="2"></td>
    <td width="8%"></td>
    <td colspan="2"></td>
    <td width="14%"><hr size="1"></td>
    <td width="2%"></td>
    <td width="7%"></td>
    <td width="15%"></td>
  </tr>
  <tr>
    <td width="12%" height="18">&nbsp;</td>
    <td width="8%">&nbsp;</td>
    <td colspan="2"><div align="right">Total Income </div></td>
    <td width="14%"><div align="right"><%=strTotalIncome%></div></td>
    <td width="2%">&nbsp;</td>
    <td width="7%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
  </tr>
  <tr>
    <td width="12%" height="18">&nbsp;</td>
    <td width="8%">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td width="14%">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="7%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
  </tr>

 <%}%> 
  <tr>
    <td width="12%" height="18"><div align="right"><%=Integer.parseInt(strIncomeExpense) + 1%></div></td>
    <td width="8%">&nbsp;</td>
    <td colspan="2">&nbsp;<%=astrIncomeExpense[Integer.parseInt(strIncomeExpense)]%></td>
    <td width="14%">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="7%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
  </tr>
<%}

	if ((String)vRetResult.elementAt(i+3) == null
		|| !strCurrentMain.equals((String)vRetResult.elementAt(i+2))){

		strTemp = (String)vRetResult.elementAt(i+2);
		strCurrentMain = strTemp;

	}else{
		strTemp = "";
	}	

	if ((String)vRetResult.elementAt(i+3) == null) 
		strAmount = (String)vRetResult.elementAt(i+4);
	else
		strAmount = "";

	if (strTemp.length() > 0) { 
%> 

  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td> 
    <td colspan="2">&nbsp;<%=strTemp%></td>
    <td><div align="right"><%=strAmount%></div></td>
    <td>&nbsp;</td>
    <td>&nbsp;
	<% if (strAmount.length() > 0) {%> 
	<a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/edit.gif" border="0"></a>
	 <%}%>	</td>
    <td><% if (strAmount.length() > 0) {%>
      <a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
      <%}%></td>
  </tr>
<%} if ((String)vRetResult.elementAt(i+3) != null) {%>  
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="40%">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
    <td><div align="right"><%=(String)vRetResult.elementAt(i+4)%></div></td>
    <td>&nbsp;</td>
    <td>&nbsp;
      <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/edit.gif" border="0"></a>      </td>
    <td><a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></td>
  </tr>
<%}
 }
  if (strTotalExpense != null && !strTotalExpense.equals("0.00")) {
%> 
  <tr>
    <td width="12%" height="2"></td>
    <td width="8%"></td>
    <td colspan="2"></td>
    <td width="14%"><hr size="1"></td>
    <td width="2%"></td>
    <td width="7%"></td>
    <td width="15%"></td>
  </tr>
  <tr>
    <td width="12%" height="18">&nbsp;</td>
    <td width="8%">&nbsp;</td>
    <td colspan="2"><div align="right">Total Expense </div></td>
    <td width="14%"><div align="right"><%=strTotalExpense%></div></td>
    <td width="2%">&nbsp;</td>
    <td width="7%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
  </tr>
 <%}
 %> 
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="19%">&nbsp;</td>
    <td height="18">&nbsp;</td>
    <td width="69%">&nbsp;</td>
    </tr>
  <tr>
    <td height="18"><div align="right">Total Income: &nbsp;</div></td>
    <td width="12%" height="18" align="right"><%=strTotalIncome%></td>
    <td height="18">&nbsp;</td>
    </tr>
  <tr>
    <td height="18"><div align="right">Less &nbsp; </div></td>
    <td height="18" align="right">&nbsp;</td>
    <td height="18">&nbsp;</td>
    </tr>
  <tr>
    <td height="18"><div align="right">Total Expense:&nbsp;</div></td>
    <td height="18"><div align="right"><%=strTotalExpense%></div></td>
    <td height="18">&nbsp;</td>
  </tr>
  <tr>
    <td height="2"></td>
    <td height="2"><hr size="1"></td>
    <td height="2"></td>
  </tr>
  <tr>
    <td height="18"><div align="right">Net Income / Loss:&nbsp; </div></td>
    <td height="18" align="right">&nbsp;
<% 
	if (strTotalIncome.length()  > 0 && strTotalExpense.length() > 0) {
%> 
	<%=CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString(strTotalIncome,",",""))			
		-  Double.parseDouble(ConversionTable.replaceString(strTotalExpense,",","")),true)%>	 
<%}%> 	</td>
    <td height="18"></td>
    </tr>
  <tr>
    <td height="25" colspan="3"><div align="center">
	<a href="javascript:PrintIncomeStatement()"><img src="../../../images/print.gif" 
			width="58" height="26" border="0"></a>
	<font size="1">print Income Statement</font> 
	
	</div>	</td>
  </tr>
</table>
<%
	}

%> 
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr >
    <td height="25" colspan="9">&nbsp;</td>
  </tr>
  <tr >
    <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="organization_index" value="<%=strOrgIndex%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
