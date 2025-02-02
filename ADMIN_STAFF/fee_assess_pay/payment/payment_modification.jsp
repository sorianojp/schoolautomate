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
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function EditRecord()
{
	document.fa_payment.editRecord.value = "1";
}
function DeleteRecord()
{
	document.fa_payment.deleteRecord.value = "1";
}
function ReloadPage()
{
	document.fa_payment.editRecord.value="";
	document.fa_payment.deleteRecord.value="";
	document.fa_payment.submit();
}
function focusID() {
	if(document.fa_payment.focus_id.value == 1)
		document.fa_payment.or_number.focus();
}
function AjaxMapName(e, strPos) {
		if(e.keyCode == 13) {
			this.ReloadPage();
			return;
		}


		var strCompleteName;
		strCompleteName = document.fa_payment.stud_id_new.value;
		if(strCompleteName.length < 2) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}

		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.fa_payment.stud_id_new.value = strID;
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.fa_payment.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,enrollment.FAPayment,java.util.Vector" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strPaymentFor = null;//fine-fine description or other school fee - fee name
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsWNU = strSchCode.startsWith("WNU");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Modifications","payment_modification.jsp");
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
														"payment_modification.jsp");
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

FAPayment faPayment = new FAPayment();
enrollment.FAElementaryPayment faPaymentBASIC = new enrollment.FAElementaryPayment();
Vector vRetResult = null;
strTemp = WI.fillTextValue("editRecord");
if(strTemp.compareTo("1") ==0) {
	if(WI.fillTextValue("page_action").equals("10")) {// for bank
		if(WI.fillTextValue("reason").length() == 0) {
			strErrMsg = "Please enter reason for modification.";
		}
		else {
			strTemp = "update fa_stud_payment set bank_post_index = "+WI.fillTextValue("bank_post_index")+",LAST_MODIFY_DATE='" +WI.getTodaysDateTime()+
						"',MODIFIED_BY=" + (String)request.getSession(false).getAttribute("userIndex") + ",MODIFY_REASON=" + 
							WI.getInsertValueForDB(request.getParameter("reason"),true, null) +" where or_number = '"+WI.fillTextValue("or_number")+"'";
			if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1) {
				strErrMsg = "Failed to update payment information.";
			}
			else	
				strErrMsg = "Bank Information successfully changed.";
		}
	}
	else {
		if(!faPayment.editDeltePayment(dbOP, request, false))
			strErrMsg = faPayment.getErrMsg();
		else
			strErrMsg = "Payment changed successfully.";
	}
}
strTemp = WI.fillTextValue("deleteRecord");
if(strTemp.compareTo("1") ==0)
{
	if(!faPayment.editDeltePayment(dbOP, request, true))
		strErrMsg = faPayment.getErrMsg();
	else
		strErrMsg = "Payment deleted successfully.";
}

if(strErrMsg == null && WI.fillTextValue("or_number").length() > 0){
	//check if this is basic 
	if(dbOP.mapOneToOther("FA_ELEMENTARY_PAYMENT","OR_NUMBER","'"+WI.fillTextValue("or_number")+"'",
                                         "ELEM_PMT_INDEX"," and is_valid = 1") != null) {
		dbOP.cleanUP();
		%>
				<jsp:forward page="./basic_pmt_modification.jsp" />
		<%
		return;
		//forward page.
	}
	vRetResult = faPayment.viewPmtDetail(dbOP, request.getParameter("or_number"));
	if(vRetResult == null) {
		strErrMsg = faPayment.getErrMsg();
	}
	else if(WI.fillTextValue("page_action").equals("10") && vRetResult.elementAt(50).equals("0")) {
		strErrMsg = "OR does not belong to Bank Payment.";
		vRetResult = null;
	}
	
}
//System.out.println(vRetResult);}
if(vRetResult != null && vRetResult.size() > 0)//determine payment for detail.
{
	if( ((String)vRetResult.elementAt(4)).compareTo("0") ==0)
		strPaymentFor = "Tution";
	else if( ((String)vRetResult.elementAt(4)).compareTo("1") ==0)//other school fee
		strPaymentFor = "Other school fee - "+(String)vRetResult.elementAt(5);
	else if( ((String)vRetResult.elementAt(4)).compareTo("2") ==0)//fine
		strPaymentFor = "Fine - "+(String)vRetResult.elementAt(17);
}

  %>
<form name="fa_payment" action="./payment_modification.jsp" method="post">
<input type="hidden" name="focus_id">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          PAYMENT MODIFICATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="payment_modification_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
        Go to main page&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <% if(strErrMsg != null){%>
        <font size="3">Message: <strong><%=strErrMsg%></strong></font>
        <%
	  if(request.getParameter("editRecord") != null && request.getParameter("editRecord").trim().length() > 0)
	  	return; //it is not for the first time.
	}%>
      </td>
    </tr>
  </table>
<script language="JavaScript">
document.fa_payment.focus_id.value = 1;
</script>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="18%" height="25">Reference Number </td>
      <td width="78%" height="25"><input name="or_number" type="text" size="16" value="<%=WI.fillTextValue("or_number")%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="4%" height="25">&nbsp;</td>
      <td width="44%" height="25">Student ID: <strong><%=WI.getStrValue(vRetResult.elementAt(25))%></strong></td>
      <td width="52%" height="25"  colspan="4">Course/Major :<strong> <%=WI.getStrValue(vRetResult.elementAt(19))%>/<%=WI.getStrValue(vRetResult.elementAt(20))%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student name :<strong>
        <%
//if user index is null, the student is ex-studetn, so display only name,
if( vRetResult.elementAt(0) != null){%>
        <%=(String)vRetResult.elementAt(18)%>
        <%}else{%>
        <%=(String)vRetResult.elementAt(1)%>
        <%}%>
        </strong></td>
      <td  colspan="4" height="25">Year :<strong><%=WI.getStrValue(vRetResult.elementAt(21))%></strong>
	  <input type="hidden" name="stud_id" value="<%=WI.getStrValue(vRetResult.elementAt(25))%>">
	  <input type="hidden" name="sy_from_p" value="<%=WI.getStrValue(vRetResult.elementAt(23))%>">
	  <input type="hidden" name="semester_p" value="<%=WI.getStrValue(vRetResult.elementAt(22))%>">
	  
	  
	  </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9"><div align="center">PAYMENT
          DETAILS </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="22%">Amount Paid: <strong><%=(String)vRetResult.elementAt(11)%></strong></td>
      <td width="44%">Payment For : <strong><%=strPaymentFor%></strong></td>
      <td width="30%">Date Paid : <strong><%=(String)vRetResult.elementAt(15)%></strong></td>
    </tr>
    <%
strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("0") ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Correct Amount</td>
      <td colspan="2"><strong> 
        <input name="amount" type="text" size="16" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong></td>
    </tr>
    <%}else if(strTemp.compareTo("1") ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date of Payment</td>
      <td colspan="2"><input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      <%if(bolIsWNU) {%>
	  	<font style="font-size:10px; font-weight:bold; color:#FF0000">
			Payment Date Modification must be later than <%=(String)vRetResult.elementAt(15)%></font>
	  <%}%>	  </td>
    </tr>
    <%}else if(strTemp.compareTo("2") ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><font size="3"> 
        <%
	  if( ((String)vRetResult.elementAt(31)).compareTo("1") ==0){%>
        <strong><font color="#0000FF">Full paid during installment payment</font></strong> 
        <%}%>
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>New Payment MODE</td>
      <td colspan="2"> <select name="payment_mode">
          <option value="0">Full</option>
          <%
strTemp = WI.fillTextValue("payment_mode");
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>Installment</option>
          <%}else{%>
          <option value="1">Installment</option>
          <%}%>
        </select></td>
    </tr>
    <%}else if(strTemp.compareTo("3") ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%}else if(strTemp.compareTo("4") ==0){//change school year information.%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>New SY Information</td>
      <td colspan="2"> <%
strTemp = WI.getStrValue((String)vRetResult.elementAt(23));
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")'> <%
strTemp = WI.getStrValue((String)vRetResult.elementAt(24));
%>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.getStrValue((String)vRetResult.elementAt(22));
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>
<%}else if(strTemp.compareTo("5") == 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>New OR Number</td>
      <td colspan="2">
<%if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") || strSchCode.startsWith("CIT") || WI.fillTextValue("allow_orchng_all").length() > 0 || 
	(((String)vRetResult.elementAt(4)).compareTo("0") == 0 && ((String)vRetResult.elementAt(27)).equals("0")) ){%>	  
	  <input name="or_number_new" type="text" size="16" value="<%=WI.fillTextValue("or_number_new")%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%}else{%>
<b>Can't modify OR Number. OR Number modification is only for downpayment type.</b>
<%}%>	 </td>
    </tr>
<%}else if(strTemp.equals("6")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>New Instalment Schedule</td>
      <td colspan="2">
<%
	strTemp = (String)vRetResult.elementAt(27);
	if(Integer.parseInt(WI.getStrValue(strTemp,"0")) > 0) {%>
	<select name="pmt_schedule">
      <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid > 0 order by is_valid, EXAM_PERIOD_ORDER asc",
		strTemp, false)%> 
		</select> 
	<%}else{%>
        No Payment schedule found. 
        <%}%></td>
    </tr>
<%}else if(strTemp.equals("7")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>New Student ID </td>
      <td colspan="2"><strong>
        <input name="stud_id_new" type="text" size="24" value="<%=WI.fillTextValue("stud_id_new")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event, '1');">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:400px"></label>
      </strong></td>
    </tr>
<%}else if(strTemp.equals("10")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Bank Posted </td>
      <td colspan="2">
	  <b><%=vRetResult.elementAt(51)%></b>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>New Bank </td>
      <td colspan="2">
	  <%
	  strTemp = "select bank_post_index from fa_stud_payment where payment_index = "+vRetResult.elementAt(30);
	  strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	  %>
	  <select name="bank_post_index">
      <%=dbOP.loadCombo("bank_index","bank_code, bank_name"," from fa_bank_list where is_valid = 1 and is_used_bank_post = 1 order by bank_code",strTemp, false)%>
	  </select>
	  
	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Reason : </td>
      <td colspan="2"><input type="text" name="reason" value="<%=WI.fillTextValue("reason")%>" maxlength="256" size="60" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <%
if(iAccessLevel > 1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><strong> </strong></td>
      <td colspan="2"> <%if(WI.fillTextValue("page_action").compareTo("3") != 0){%> <input type="image" src="../../../images/save.gif" onClick="EditRecord();"> 
        <font size="1">Click to correct the amount</font> <%}if(iAccessLevel ==2 && WI.fillTextValue("page_action").compareTo("3") ==0){%> <input type="image" src="../../../images/delete.gif" onClick="DeleteRecord();"> 
        <font size="1">Delete to remove the payment</font> <%}else{%>
        <!--Not authorized--> 
        <%}%> </td>
    </tr>
    <%}%>
  </table>
 <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="17%" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="editRecord" value="0">

<input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">

<input type="hidden" name="allow_orchng_all" value="<%=WI.fillTextValue("allow_orchng_all")%>">



</form>
</body>
</html>
<%
dbOP.cleanUP();
%>