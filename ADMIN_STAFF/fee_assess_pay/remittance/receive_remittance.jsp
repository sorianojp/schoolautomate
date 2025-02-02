<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
</head>

<script language="JavaScript">
function AddRecord()
{
	document.remittance.addRecord.value = "1";
	this.SubmitOnce("remittance");
}
function ReloadPage()
{
	document.remittance.addRecord.value = "0";
	this.SubmitOnce("remittance");
}
function ChangeRemitIndex(){
	document.remittance.addRecord.value = "0";
	document.remittance.remit_type_index.value = "";
	this.SubmitOnce("remittance");

}
function ResetEntries(){
	document.remittance.addRecord.value = "0";
	document.remittance.remit_type_index.value = "";
	document.remittance.preload_remit_index.value ="";
	this.SubmitOnce("remittance");
}

function AjaxUpdateChange() {
		var strAmtPaid     = document.remittance.amount.value;
		var strAmtTendered = document.remittance.amount_tendered.value;
		if(strAmtPaid.length == 0 || strAmtTendered.length == 0)
			return;
		
		var objCOAInput = document.getElementById("change_");
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=152&amt_tendered="+strAmtTendered+"&amt_paid="+strAmtPaid;
		this.processRequest(strURL);
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FARemittance,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strORNumber = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REMITTANCE-Receive Remittance","receive_remittance.jsp");
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
														"Fee Assessment & Payments","REMITTANCE",request.getRemoteAddr(),
														"receive_remittance.jsp");
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


FARemittance faRemit = new FARemittance(dbOP);

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	strORNumber = faRemit.savePayment(dbOP,request);

	if(strORNumber != null)//forward page to the print.jsp.
	{
		strTemp = response.encodeRedirectURL("./remittance_print.jsp?or_number="+strORNumber+"&print_status=0");
		%>
		<jsp:forward page="<%=strTemp%>" />
	<%}
	else
		strErrMsg = faRemit.getErrMsg();
}
String strInchargeName = "";
Vector vRemitInfo = faRemit.operateOnRemittanceType(dbOP,request,3);
if(vRemitInfo != null && vRemitInfo.size()> 0)
{
	strInchargeName = WI.getStrValue((String)vRemitInfo.elementAt(2));
}
if(strErrMsg == null) strErrMsg = "";
enrollment.FAPaymentUtil paymentUtil = new enrollment.FAPaymentUtil();
%>

<form name="remittance" method="post" action="./receive_remittance.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" ><strong>::::
          RECEIVE REMITTANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td height="25" width="18%">Remittance type&nbsp;</td>
      <td height="25" width="38%"><strong>
        <select name="preload_remit_index" onChange="ChangeRemitIndex();">
          <option value="">Select a type</option>
          <%=dbOP.loadCombo("preload_remit_index","preload_remit_name"," from preload_remittance order by preload_remit_name", WI.fillTextValue("preload_remit_index"), false)%>
        </select>
        </strong></td>
      <td width="42%"> <%//get here cutoff time information.
	  Vector vTempCO = new enrollment.FADailyCashCollectionDtls().getCurrentCutoffStat(dbOP, (String)request.getSession(false).getAttribute("userId"));//System.out.println(vTempCO);
	  //I have to get currency rate.. 
	  String strCurrencyInfo = new locker.Currency().getLatestCurrencyRate(dbOP);
	  if(vTempCO != null){%> <table width="75%" class="thinborderALL" cellpadding="0" cellspacing="0">
          <tr>
            <td height="20" align="right"> <%
		  strTemp = "Time :: "+(String)vTempCO.elementAt(0);
		  if(vTempCO.elementAt(1) != null) {//cut off time is set.
		  	if( ((String)vTempCO.elementAt(2)).compareTo("1") == 0)
				strTemp += "<br><font color=red>Cut off :: "+(String)vTempCO.elementAt(1)+"</font>";
			else
				strTemp += "<br>Cut off :: "+(String)vTempCO.elementAt(1);
		  }
                  if(vTempCO.elementAt(2) != null)
                  	strTemp += "<br>Collection :: "+(String)vTempCO.elementAt(3);
                  %> <strong><%=strTemp%><%=strCurrencyInfo%></strong> </td>
          </tr>
        </table>
        <%}//only if cutoff time is set.%> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Account Name</td>
      <td height="25" colspan="2"><strong>

        <select name="remit_type_index" onChange="ReloadPage();">
        <option value="">Select a type</option><% if (WI.fillTextValue("preload_remit_index").length()  > 0) {%>
      <%=dbOP.loadCombo("REMIT_TYPE_INDEX","TYPE_NAME"," from FA_REMIT_TYPE where IS_VALID=1 and preload_remit_index ="+WI.fillTextValue("preload_remit_index")+" order by TYPE_NAME asc", request.getParameter("remit_type_index"), false)%>
	 <%}%>
        </select>

        </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
	  <td height="25">In-charge :</td>
	  <%strTemp="&nbsp";
	  	if (WI.fillTextValue("remit_type_index").length() > 0){
			strTemp = WI.getStrValue(dbOP.mapOneToOther("fa_remit_type","REMIT_TYPE_INDEX",WI.fillTextValue("remit_type_index"),"person_incharge", " and is_valid = 1"));
		}
	  %>
      <td height="25" colspan="2"><strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
  </table>
<% if (WI.fillTextValue("remit_type_index").length() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date of Remittance</td>
      <td height="25"><%
strTemp = WI.fillTextValue("date_of_payment");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%> <input name="create_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('remittance.create_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Amount Paid </td>
      <td height="25"><strong>
        <input name="amount" type="text" size="16" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" onKeyUp="AjaxUpdateChange();">
        </strong></td>
      <td>&nbsp; </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Amount Tendered </td>
      <td height="25">
	  		<input name="amount_tendered" type="text" size="16" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxUpdateChange();">
	  </td>
      <td>
			<div id="change_div">
			<table cellpadding="0" cellspacing="0">
      			<td style="font-size:18px;">Change: &nbsp;</td>
      			<td style="font-size:18px; font-weight:bold; color:#FF0000"><label id="change_"></label></td>
			</table>
		</div>		
	  </td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%" height="25">Remitted by</td>
      <td width="29%" height="25"><strong>
        <input name="remit_by" type="text" size="32" value="<%=WI.fillTextValue("remit_by")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </strong></td>
      <td width="51%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Type of Payment</td>
      <td height="25" colspan="2">
        <select name="mode_payment" onChange="ReloadPage();">
          <option value="0">Cash</option>
		  <% if (WI.fillTextValue("mode_payment").compareTo("1") == 0) { %>
		  <option value="1" selected>Check</option>
		  <%}else{%>
		  <option value="1">Check</option>
		  <%}%>
        </select>	   </td>
    </tr>
<% if (WI.fillTextValue("mode_payment").compareTo("1") == 0 ){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Bank Name (Branch)</td>
      <td height="25" colspan="2"><strong>
        <input name="bank" type="text" class="textbox" id="bank"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("bank")%>" size="32">
        </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Check Number</td>
      <td height="25" colspan="2"><strong>
        <input name="check_number" type="text" size="32" value="<%=WI.fillTextValue("check_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">(if payment is in check)</font></strong></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Description</td>
      <td height="25" colspan="2"><strong>
        <input name="description" type="text" size="64" maxlength="128" value="<%=WI.fillTextValue("description")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td height="22">&nbsp;</td>
      <td height="22" colspan="2"><strong> </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">OR NUMBER</td>
      <td height="25" colspan="2"><font size="1"><b>
        <input name="or_number" type="text" size="18" value="<%=paymentUtil.generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userIndex"), true)%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </b></font></td>
    </tr>
    <tr>
      <td colspan="4" height="25">&nbsp;</td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr>
      <td colspan="4" height="25"><div align="center"><font size="1" >
          <a href="javascript:AddRecord()"><img src="../../../images/save.gif" border= 0 ></a>
          click to save entires <a href="javascript:ResetEntries()" onMouseOver="window.status='Cancel entries'; return true"><img src="../../../images/cancel.gif" border="0"></a>click
          to cancel and clear entries</font></div></td>
    </tr>
    <%}//if iAccessLevel > 1%>
  </table>
 <%}//only if remit type is selected. "
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="15%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="addRecord" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
