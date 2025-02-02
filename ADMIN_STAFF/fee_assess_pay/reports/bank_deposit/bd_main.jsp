<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if(WI.fillTextValue("print_pg").equals("1")){%>
		<jsp:forward page="./bd_main_print.jsp"></jsp:forward>
	<%return;}

	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String[] astrConvertToYear = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee assessment & payment-Bank Deposit management","bd_main.jsp");
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
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
														"bd_main.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
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
Vector vRetResult = null;
FAPayment faPmt = new FAPayment();

if(WI.fillTextValue("page_action").length() > 0) {
	if(faPmt.operateOnBankDeposits(dbOP, request, Integer.parseInt(WI.fillTextValue("page_action"))) != null)
		strErrMsg = "Bank deposit information updated.";
	else
		strErrMsg = faPmt.getErrMsg();
}
if(WI.fillTextValue("show_result").length() > 0)
	vRetResult = faPmt.operateOnBankDeposits(dbOP, request, 4);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
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
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to remove this information?'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.show_result.value = 1;
	document.form_.submit();
}
function PrintPage() {
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

/**
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
**/
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);

	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
//all about ajax - to display student list with same name.
function AjaxMapORNumber() {
	var strORNumber = document.form_.or_number.value;
	var objCOAInput = document.getElementById("coa_info");

	if(strORNumber.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=102&or_number="+escape(strORNumber);

	this.processRequest(strURL);
}
function AjaxSelected(strORNumber, strName, strAmount) {
	document.form_.or_number.value = strORNumber;
	var strAjaxPrevVal = "<font size='1' color=blue>OR Number : "+strORNumber+" ,Name : "+strName+" ,Amount :"+strAmount+"</font>";
	document.form_.prev_ajax_val.value = strAjaxPrevVal;
	document.getElementById("coa_info").innerHTML = strAjaxPrevVal;
	//document.form_.submit();
}
function AdjustSize(strFormName, strFieldName) {
	var objField;
	eval('objField=document.'+strFormName+'.'+strFieldName);
	var charLen = objField.value.length;
	if(charLen < 5) {
		objField.size = 5;
		return;
	}
	objField.size = charLen +1;
}
function PrintPage() {
	document.form_.print_pg.value = '1';
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" action="./bd_main.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>::::
        BANK DEPOSIT MANAGEMENT ::::</strong></font></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr valign="top">
      <td height="25" >&nbsp;</td>
      <td >OR Number  </td>
<input type="hidden" name="prev_ajax_val" value="<%=WI.fillTextValue("prev_ajax_val")%>">
      <td ><input name="or_number" type="text" size="32" value="<%=WI.fillTextValue("or_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp='AjaxMapORNumber();'></td>
      <td ><label id="coa_info"><%=WI.fillTextValue("prev_ajax_val")%></label></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="11%" height="25" >Bank</td>
      <td width="37%" ><select name="bank_index" style="font-size:10px;">
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH"," from FA_BANK_LIST where bank_code in ('cbc','sbtc') and is_valid = 1  order by bank_code", request.getParameter("bank_index"), false)%>
      </select></td>
      <td width="50%" >Amount  :
        <input name="amount" type="text" size="5" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'" onKeyUp='AdjustSize("form_","amount");AllowOnlyFloat("form_","amount")'></td>
    </tr>
    <tr>
      <td height="10" align="center">&nbsp;</td>
      <td height="10" colspan="3" align="center"><input type="submit" name="12" value="Save Information" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1';document.form_.page_action.value='1'"></td>
    </tr>
    <tr bgcolor="#DDDDDD">
      <td height="10" align="center">&nbsp;</td>
      <td height="10" colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF"><u>Filter Display Information :</u></td>
    </tr>
    <tr>
      <td height="10" align="center">&nbsp;</td>
      <td height="10" colspan="3" style="font-size:11px;">OR  starts with :
      <input name="or_search_no" type="text" size="16" value="<%=WI.fillTextValue("or_search_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  &nbsp;&nbsp;&nbsp;
	  OR Date Range :
	  <input name="date_fr" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" readonly
	   onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_fr")%>" size="10" maxlength="10">
		<a href="javascript:show_calendar('form_.date_fr');"><img src="../../../../images/calendar_new.gif" border="0"></a>
		&nbsp;
		<input name="date_to" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" readonly
		onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="10" maxlength="10">
		<a href="javascript:show_calendar('form_.date_to');"><img src="../../../../images/calendar_new.gif" border="0"></a>

	  &nbsp;&nbsp;
	  <input type="submit" name="122" value="Refresh Search" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1';"></td>
    </tr>
    <tr>
      <td height="10" align="center">&nbsp;</td>
      <td height="10" colspan="3">
	  	<input type="checkbox" name="print_selected_bank" value="checked" <%=WI.fillTextValue("print_selected_bank")%>> Show for selected Bank
	  </td>
    </tr>
    <tr>
      <td colspan="4" height="10" align="center">&nbsp;</td>
    </tr>
  </table>
  <%
if(vRetResult != null && vRetResult.size() > 0){
%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td class="thinborder" width="5%" height="25" align="right">
	  <input type="checkbox" name="show_summary" value="1"> Print Summary &nbsp;&nbsp;&nbsp;
	  <a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>
	  Print Report</td>
	</tr>
  </table>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td class="thinborder" width="5%" height="25">SL #</td>
      <td class="thinborder" width="17%">OR Number  </td>
      <!--<td class="thinborder" width="24%">Payee Name </td>-->
      <td class="thinborder" width="33%">Bank Code : Branch </td>
      <td class="thinborder" width="12%">Amount</td>
      <td class="thinborder" width="9%">Remove</td>
    </tr>
<%boolean bolNewPrint = false;
int j = 0;
for(int i = 1; i < vRetResult.size(); ++j){
	bolNewPrint = true;
	vRetResult.removeElementAt(i);
	vRetResult.removeElementAt(i);
for(; i < vRetResult.size(); i += 4){
	if(vRetResult.elementAt(i) == null)
		break;
	%>
    <tr>
      <td class="thinborder"><%if(bolNewPrint){%><%=j + 1%>.<%}else{%>&nbsp;<%}%></td>
      <td class="thinborder" height="22">
	  	<%if(bolNewPrint){%>
			<%=(String)vRetResult.remove(i)%><br><font color="red"> Total Amount : <%=(String)vRetResult.remove(i)%></font>
	  <%}else{%>&nbsp;<%}%></td>
      <!--<td class="thinborder"><%//=(String)vRetResult.elementAt(i + 2)%></td>-->
      <td class="thinborder"><%=(String)vRetResult.elementAt(i)%> : <%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i + 3)%>');">Remove</a></td>
    </tr>
<%bolNewPrint = false;}
}%>
  </table>
<input type="hidden" name="max_disp" value="<%=j%>">

  <%
	}//vRetResult is not null
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="show_result">
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
  <input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
