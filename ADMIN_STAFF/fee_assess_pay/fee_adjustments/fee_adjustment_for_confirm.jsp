<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
td{
	font-size:11px;
}

</style>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage()
{
	this.SubmitOnce("fa_payment");
}


function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=fa_payment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CancelJV(){
	var iMaxDisplay = Number(document.fa_payment.max_display.value);
	var bolContinue = false;
	
	for( var i = 0; i< iMaxDisplay; i++){
		if (eval("document.fa_payment.checkbox"+i+".checked")){
			bolContinue = true;
			break;
		}
	}
	if (!bolContinue){
		alert(" Please select at least 1 Scholarship/Adjustment to Cancel");
		return;
	}
	document.fa_payment.page_action.value="1";
	document.fa_payment.hide_src.src="../../../images/blank.gif";
	document.fa_payment.submit();
	
}

</script>

<body bgcolor="#D2AE72" >
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

	String[] astrConvertSem= {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

	WebInterface WI = new WebInterface(request);

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","fee_adjustment_for_cancel.jsp");
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
												"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
												"fee_adjustment_for_cancel.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
} else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}


//end of authenticaion code.

Vector vRetResult = null;


int iCtr = 0;

//float fTotalAdjustment = 0f;

enrollment.FAFeeAdjustmentCPU fAdjust = new enrollment.FAFeeAdjustmentCPU();
//FAPayment faPayment = new FAPayment();
String strYearLevel  = null;

if(WI.fillTextValue("sy_from").length() > 0 && 
	WI.fillTextValue("semester").length() > 0 &&
	WI.fillTextValue("jv_no").length() > 0) {
	
	vRetResult = fAdjust.viewAllForConfirmation(dbOP,request);
	
}

%>
<form name="fa_payment" action="./fee_adjustment_for_confirm.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          FEE ADJUSTMENT CONFIRMATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="18%" height="25">School Year / Term </td>
      <td width="30%" height="25">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%><input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")'>
-
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
-
<select name="semester">
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		  if(strTemp.equals("1")){%>
  <option value="1" selected>1st Sem</option>
  <%}else{%>
  <option value="1">1st Sem</option>
  <%}if(strTemp.equals("2")){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}
		  if (!strSchCode.startsWith("CPU")) {
		     if(strTemp.equals("3")){%>
  <option value="3" selected>3rd Sem</option>
  <% }else{%>
  <option value="3">3rd Sem</option>
  <% }		  
		  } 
			if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%} %>
</select></td>
      <td width="48%">
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif"  border="0"></a></td>
    </tr>
<% 
	if (WI.fillTextValue("sy_from").length() >0 && 
			WI.fillTextValue("semester").length()> 0){
%>

    <tr>
      <td height="20">&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Journal Voucher No.</td>
      <td height="25"><select name="jv_no" onChange="ReloadPage()">
        <option  value=""></option>
        <%=dbOP.loadCombo("distinct jv_no","jv_no", 
			" from TEMP_FEE_ADJUST where (is_rejected = null or is_rejected = 0) " + 
			" and jv_no is not null and sy_from=" + WI.fillTextValue("sy_from") +
			" and semester="+ WI.fillTextValue("semester"),
			WI.fillTextValue("jv_no"),false)%>
      </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%}%> 	
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	  <tr>
  			<td height="25" colspan="3" bgcolor="#D6E0FE" class="thinborder"><div align="center"><strong>LIST OF APPROVED ADJUSTMENTS </strong></div></td>
	  </tr>
	  <tr>
	    <td width="47%" class="thinborder"><strong>&nbsp;ADJUSTMENT TYPE</strong></td>
	    <td width="39%" height="25" class="thinborder"> <div align="center"><strong>STUDENT NAME </strong></div></td>
        <td width="14%" class="thinborder"><div align="center"><strong>AMOUNT </strong></div></td>
    </tr>
<%
	strTemp = "";
	String strFaFaIndex = "";
	
	for (int j = 0; j < vRetResult.size() ; j += 13, iCtr++) {
		strTemp ="";
		if (!strFaFaIndex.equals((String)vRetResult.elementAt(j+9))){
			strFaFaIndex  = (String)vRetResult.elementAt(j+9);
			strTemp = (String)vRetResult.elementAt(j) + 
			WI.getStrValue((String)vRetResult.elementAt(j+1)," - " ,"","") +
			WI.getStrValue((String)vRetResult.elementAt(j+2)," - " ,"","") +
			WI.getStrValue((String)vRetResult.elementAt(j+3)," - " ,"","") +
			WI.getStrValue((String)vRetResult.elementAt(j+4)," - " ,"","") +
			WI.getStrValue((String)vRetResult.elementAt(j+5)," - " ,"","");
		}
%> 
    <tr >
      <td class="thinborder">&nbsp; <%=strTemp%> </td>
	    <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(j+11)%></td>
	    <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vRetResult.elementAt(j+6),"-")%>&nbsp;&nbsp;</div></td>
    </tr>
<%}%> 
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><div align="center"><img src="../../../images/save.gif" alt="Cancel Journal Voucher" name="hide_src" width="48" height="28" border="0"><font size="1">click to cancel journal voucher </font></div></td>
    </tr>
  </table>
<%  } // vStudInfo  != null%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action" value="">
<input type="hidden" value="<%=iCtr%>" name="max_display">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
