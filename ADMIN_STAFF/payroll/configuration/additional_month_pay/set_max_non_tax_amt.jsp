<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAYROLL: SET ADDITIONAL MONTH PAY PARAMETERS : NUMBER OF MONTHS FOR ADDITIONAL MONTH PAY PAGE</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./set_max_non_tax_amt.jsp";
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}


function focusID() {
	document.form_.emp_id.focus();
}

-->
</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./set_max_non_tax_amt_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Set Additional Month  Pay Parameters","set_num_of_mths_pay.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"set_max_non_tax_amt.jsp");
if(iAccessLevel == 0){
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION-SETADDLMNTH",request.getRemoteAddr(), null);
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
Vector vRetResult = null;
Vector vEditInfo = null;

PayrollConfig pr = new PayrollConfig();

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");

if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (pr.operateOnMaxNonTax(dbOP,request,0) != null){
			strErrMsg = "  Maximum non taxable amount removed successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (pr.operateOnMaxNonTax(dbOP,request,1) != null){
			strErrMsg = " Maximum non taxable amount posted successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (pr.operateOnMaxNonTax(dbOP,request,2) != null){
			strErrMsg = " Maximum non taxable amount updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}
}
if (strPrepareToEdit.length() > 0){
	vEditInfo = pr.operateOnMaxNonTax(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = pr.getErrMsg();
}

vRetResult = pr.operateOnMaxNonTax(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}


%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./set_max_non_tax_amt.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: SET ADDITIONAL MONTH PAY PARAMETERS ::::<br>
          <font size="1">(</font><font color="#FFFFFF" size="1" ><strong>MAXIMUM NON-TAXABLE 
          PAY PAGE</strong></font><font size="1">)</font></strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2"><a href="addtl_mth_pay_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a> 
        &nbsp;&nbsp; &nbsp;<%=WI.getStrValue(strErrMsg,"<font size='3' color='#FF0000'><strong>","</strong></font>","")%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td>Effectivity Date : 
        <%	if(vEditInfo!=null) strTemp= (String)vEditInfo.elementAt(1);
	else strTemp= WI.fillTextValue("date_from");%> <input name="date_from" type="text" class="textbox" id="date_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" alt="Click to set " width="20" height="16" border="0"></a> 
        to 
        <%	if(vEditInfo!=null) strTemp= WI.getStrValue((String)vEditInfo.elementAt(2));
	else strTemp= WI.fillTextValue("date_to");%> 
	<input name="date_to" type="text" class="textbox" id="date_to"
	 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	 value="<%=strTemp%>" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Maximum Non-Taxable Amount :
        <%	if(vEditInfo!=null) strTemp= WI.getStrValue((String)vEditInfo.elementAt(3));
	else strTemp= WI.fillTextValue("max_non_tax");%> <input onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" 
	  name="max_non_tax" type="text" id="max_non_tax" size="9" maxlength="9" class="textbox" onKeyUp="AllowOnlyFloat('form_','max_non_tax')">      </td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td width="95%" height="35" align="center" valign="bottom">  
        <% if (iAccessLevel > 1) {
	  if (vEditInfo == null) {%>
        <!--
					<a href="javascript:AddRecord()"><img src="../../../../images/save.gif" width="48" height="28"  border="0"></a>
					-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
				<font size="1">click to save entries </font> 
        <%}else{%>
        <!--
					<a href="javascript:EditRecord()"><img src="../../../../images/edit.gif" width="40" height="26"  border="0"></a>
					-->
				<input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:EditRecord();">
				<font size="1">click to change entries </font> 
        <%} // end else if vEditInfo == null %>
        <!--
					<a href="javascript:CancelRecord()"><img src="../../../../images/cancel.gif" width="51" height="26" border="0"></a>
					-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
				<font size="1">click to cancel/clear entries</font> 
        <%} // end iAccessLevel > 1%>        </td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <% if (vRetResult != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="4" align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0" ></a><font size="1">click 
      to print list </font></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4" align="center" bgcolor="#B9B292">MAXIMUM 
      NON-TAXABLE ADDITIONAL PAY</td>
    </tr>
    <tr> 
      <td width="289" height="26" align="center"><font size="1"><strong>EFFECTIVITY 
        DATE</strong></font></td>
      <td align="center"><strong><font size="1">MAXIMUM NON-TAXABLE AMOUNT 
      </font></strong></td>
      <td colspan="2" align="center"><strong><font size="1"><strong>OPTIONS</strong></font></strong></td>
    </tr>
<% for (int i=0; i < vRetResult.size(); i+=4){%>
    <tr> 
      <td height="25">&nbsp;<%=(String)vRetResult.elementAt(i+1) + WI.getStrValue((String)vRetResult.elementAt(i+2)," - " ,""," - PRESENT")%></td>
      <td width="341" align="center">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>
      <td width="67" align="center"> <% if (iAccessLevel > 1) {%>
        <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a> 
        <%}else{%> 
        NA 
        <%}%></td>
      <td width="79" align="center"> <% if (iAccessLevel == 2) {%>
        <a href='javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%>
        NA 
        <%}%>        </td>
    </tr>
<%} // end for loop%>
  </table>
<%} // end vRetResult != null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
