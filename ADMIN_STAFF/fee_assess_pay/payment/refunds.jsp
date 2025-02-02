<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script src="../../../jscript/date-picker.js"></script>
<script src="../../../jscript/common.js"></script>
<script src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function UpdateRefundType() {
	var pgLoc = "./refund_type.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id.focus();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PageAction(strAction, strIndex) {
	document.form_.page_action.value = strAction;
	if(strAction == "1")
		document.form_.hide_save.src = "../../../images/blank.gif";
	if(strIndex.length > 0)
		document.form_.info_index.value = strIndex;
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch2() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.refund_to";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
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
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.FAFeeRefund,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	String strImgFileExt = null;

	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT","refunds.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"refunds.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT-DEBIT CREDIT",request.getRemoteAddr(),
														"refunds.jsp");
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
float fOutStandingBalance = 0f; //refund amount.
FAFeeRefund feeRefund = new FAFeeRefund();
enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
Vector vRetResult = null;Vector vBasicInfo = null;Vector vStudRefundTo = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(strTemp.compareTo("1") ==0) {
		strTemp = feeRefund.addRefund(dbOP, request);
		if(strTemp == null)
			strErrMsg = feeRefund.getErrMsg();
		else
			strErrMsg = "Transaction is successful. Transaction Reference number : "+strTemp;
	}
	else if(strTemp.compareTo("0") == 0){
		if(feeRefund.deleteRefund(dbOP, WI.fillTextValue("info_index"),
					(String)request.getSession(false).getAttribute("login_log_index")))
			strErrMsg = "Transaction information removed successfully.";
		else
			strErrMsg = feeRefund.getErrMsg();
	}
}

if(WI.fillTextValue("stud_id").length() > 0)
{//System.out.println(vBasicInfo);System.out.println("I am here.");
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
		strErrMsg = OAdm.getErrMsg();
	else {
		fOutStandingBalance = fOperation.calOutStandingOfPrevYearSem(dbOP, (String)vBasicInfo.elementAt(12),false, false, (String)vBasicInfo.elementAt(10),	(String)vBasicInfo.elementAt(11), (String)vBasicInfo.elementAt(9),	(String)vBasicInfo.elementAt(14));
		//System.out.println("fOutStandingBalance : "+fOutStandingBalance);
		//System.out.println((String)vBasicInfo.elementAt(12));
		//System.out.println((String)vBasicInfo.elementAt(10));
		//System.out.println((String)vBasicInfo.elementAt(11));
		//System.out.println((String)vBasicInfo.elementAt(9));
		//System.out.println((String)vBasicInfo.elementAt(14));
		//System.out.println("fOutStandingBalance before : "+fOutStandingBalance);
		
		fOutStandingBalance += fOperation.calOutStandingCurYr(dbOP,
								(String)vBasicInfo.elementAt(12),
								(String)vBasicInfo.elementAt(10),
								(String)vBasicInfo.elementAt(11),
								(String)vBasicInfo.elementAt(14),
								(String)vBasicInfo.elementAt(9));
		//System.out.println("fOutStandingBalance after: "+fOutStandingBalance);
	}

}
if(WI.fillTextValue("refund_to").length() > 0)
{
	vStudRefundTo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("refund_to"));
	if(vStudRefundTo == null) //may be it is the teacher/staff
		strErrMsg = OAdm.getErrMsg();
}


//view one or all.
vRetResult = feeRefund.viewAllRefund(dbOP, request, 4);

String[] strConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolChargeOtherSY = false;
%>
<form action="./refunds.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          REFUNDS OF PAYMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">&nbsp;</td>
      <td> <a href="../reports/list_stud_outstanding_refund.jsp" target="_blank"><img src="../../../images/show_list.gif" border="0"></a><font size="1">click
        to show list of students with refund(s)</font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" height="25">Student ID</td>
      <td width="19%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox_bigfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="9%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="54%"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td colspan="3"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
<%if(true){%>
    <tr>
      <td></td>
      <td colspan="4" style="font-weight:bold; font-size:9px; color:#0000FF">
<%
strTemp = WI.fillTextValue("charge_other_syterm");
if(strTemp.compareTo("1") ==0) {
	strTemp = " checked";
	bolChargeOtherSY = true;
}
else
	strTemp = "";
%>
        <input name="charge_other_syterm" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();"> Charge To Other SY/Term
<%if(bolChargeOtherSY && vBasicInfo != null){%>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0 && vBasicInfo != null && vBasicInfo.size() > 0)
	strTemp = (String)vBasicInfo.elementAt(10);
%>
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> - 
	  
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0 && vBasicInfo != null && vBasicInfo.size() > 0)
	strTemp = (String)vBasicInfo.elementAt(11);
%>
	  <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
	  
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0 && vBasicInfo != null && vBasicInfo.size() > 0)
	strTemp = (String)vBasicInfo.elementAt(9);
%>
	  <select name="semester">
          <option value="">ALL</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="0" <%=strErrMsg%>>Summer</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd Sem</option>
        </select>
		
<%}%>
		</td>

	  </td>
    </tr>
<%}%>
  </table>
<%
if(vBasicInfo != null && vBasicInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="24"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="69%" height="25">Student ID :<strong> <%=WI.fillTextValue("stud_id")%></strong></td>
      <td width="29%"  colspan="4" rowspan="3" valign="top" align="left"> <%if(strImgFileExt != null){%> <table bgcolor="#000000">
          <tr bgcolor="#FFFFFF">
            <td> <img src="../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()%>.<%=strImgFileExt%>" width="85" height="85">
            </td>
          </tr>
        </table>
        <%}%> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student name :<strong> <%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Current SY(Sem)/Yr Level: <strong><%=(String)vBasicInfo.elementAt(10)%> - <%=(String)vBasicInfo.elementAt(11)%> (<%=strConvertToSem[Integer.parseInt((String)vBasicInfo.elementAt(9))]%>)/
	  <%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></strong>
<%if(!bolChargeOtherSY){%>
<input type="hidden" name="sy_from" value="<%=(String)vBasicInfo.elementAt(10)%>">
<input type="hidden" name="sy_to" value="<%=(String)vBasicInfo.elementAt(11)%>">
<input type="hidden" name="semester" value="<%=(String)vBasicInfo.elementAt(9)%>">
<%}%>
<input type="hidden" name="year_level" value="<%=(String)vBasicInfo.elementAt(14)%>">
<input type="hidden" name="stud_index" value="<%=(String)vBasicInfo.elementAt(12)%>">
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major : <strong><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></strong></td>
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">DEBIT/CREDIT
          DETAILS </font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Outstanding balance</td>
      <td><strong>Php <%=CommonUtil.formatFloat((fOutStandingBalance),true)%></strong></td>
      <td> <%
strTemp = WI.fillTextValue("is_credit");
if(strTemp.equals("0") || request.getParameter("is_credit") == null)
	strTemp = " checked";
else
	strTemp = "";
%> <input type="radio" name="is_credit" value="0"<%=strTemp%>>
        Debit
        <%
if(strTemp.length() == 0)
	strTemp = " checked";
else
	strTemp = "";
%> <input type="radio" name="is_credit" value="1" <%=strTemp%>>
        Credit</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Debit/Credit Type</td>
      <td colspan="2">
		  <select name="refund_type">
    	      <%=dbOP.loadCombo("REFUND_TYPE_INDEX","REFUND_TYPE_NAME,IS_TUITION_TYPE_NAME"," from FA_STUD_REFUND_TYPE where is_valid = 1 order by refund_type_name", request.getParameter("refund_type"), false)%>
		  </select>	  
		  <a href="javascript:UpdateRefundType();"><img src="../../../images/update.gif" border="0" height="22" width="60"></a>
		  
	  </td>
    </tr>
    <%//}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Debit/Credit</td>
      <td> <%
strTemp = WI.fillTextValue("amount");
if(strTemp.length() ==0)
	strTemp = CommonUtil.formatFloat((1 * fOutStandingBalance),true);
strTemp = ConversionTable.replaceString(strTemp,",","");
//if(strTemp.startsWith("-"))
//	strTemp = strTemp.subString(1);

%> <input name="amount" type="text" size="18" value="<%=strTemp%>" class="textbox"
    onKeyUp="AllowOnlyIntegerExtn('form_','amount','.');" onFocus="style.backgroundColor='#D3EBFF'"
	onblur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'"></td>
      <td>Transaction Date  :
        <%
strTemp = WI.fillTextValue("refund_date");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%> <input name="refund_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.refund_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Mode</td>
      <td><font size="1">
        <select name="refund_mode" onChange="ReloadPage();">
          <option value="0">Cash</option>
          <%
strTemp = WI.fillTextValue("refund_mode");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Check</option>
          <%}else{%>
          <option value="1">Check</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Money transfer</option>
          <%}else{%>
          <option value="2">Money transfer</option>
          <%}%>
        </select>
        </font></td>
      <td> <%
if(WI.fillTextValue("refund_mode").compareTo("1") ==0){%>
        Check # :
        <input name="check_no" type="text" size="18" value="<%=WI.fillTextValue("check_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <%}%> </td>
    </tr>
    <%
if(WI.fillTextValue("refund_mode").compareTo("2") ==0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="18%">Enter Student ID </td>
      <td width="19%"> <input name="refund_to" type="text" size="16" value="<%=WI.fillTextValue("refund_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="61%"><a href="javascript:OpenSearch2();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Transaction Note</td>
      <td colspan="2"><input type="text" name="refund_note" value="<%=WI.fillTextValue("refund_note")%>" maxlength="128" size="65" class="textbox"
    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3"><strong><font color="#0000FF">NOTE: Transaction reference
        number will be generated after saving.</font></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>Click
        to reload the page.</td>
    </tr>
    <%//}//only if fOutStandingBalance > 0f%>
  </table>

 <%if(vStudRefundTo != null && vStudRefundTo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="24"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="69%" height="25">Student ID :<strong> <%=WI.fillTextValue("refund_to")%></strong></td>
      <td width="29%"  colspan="4" rowspan="3" valign="top" align="left">
	  <%if(strImgFileExt != null){%> <table bgcolor="#000000">
          <tr bgcolor="#FFFFFF">
            <td> <img src="../../../upload_img/<%=WI.fillTextValue("refund_to").toUpperCase()%>.<%=strImgFileExt%>" width="85" height="85">
            </td>
          </tr>
        </table>
        <%}%>
	</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student name :<strong> <%=WebInterface.formatName((String)vStudRefundTo.elementAt(0),
	  (String)vStudRefundTo.elementAt(1),(String)vStudRefundTo.elementAt(2),4)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Year :<strong> <%=WI.getStrValue((String)vStudRefundTo.elementAt(14),"N/A")%></strong>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major : <strong><%=(String)vStudRefundTo.elementAt(7)%> <%=WI.getStrValue((String)vStudRefundTo.elementAt(8),"/","","")%></strong></td>
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
  </table>
<%}//only if vStudRefundTo information is not null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25" align="center">
<%//if(iAccessLevel > 1 && fOutStandingBalance < -0.1f){
if(iAccessLevel > 1){%>
	  <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
          <font size="1">click to save/verify REFUND </font>
<%}%>		  </td>
    </tr>
  </table>
<%//if(strSchCode.startsWith("EAC")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="center"><strong> <font color="#0000FF">
<%
strTemp = WI.fillTextValue("show_all");
if(strTemp.compareTo("1") ==0)
	strTemp = " checked";
else
	strTemp = "";
%>
        <input name="show_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();"> CHECK TO VIEW DEBIT/CREDIT UNTIL TODAY.</font></strong></td>
    </tr>
  </table>
<%

if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="11"><div align="center"><strong><font color="#FFFFFF">LIST
          OF REFUND TRANSACTION FOR THIS ACCOUNT</font></strong></div></td>
    </tr>
    <tr style="font-weight:bold;" align="center">
      <td width="10%"><font size="1">Transaction Ref# </font></td>
      <td width="7%"><font size="1">SY-Term</font></td>
      <td width="10%" height="25"><font size="1">Transaction Date </font></td>
      <td width="10%"><font size="1">Description</font></td>
      <td width="30%"><font size="1">Transaction Note</font></td>
      <td width="12%"><font size="1">Debit/Credit Type</font></td>
      <td width="7%" align="center"><font size="1">Encoded By </font></td>
      <td width="7%"><font size="1">Debit</font></td>
      <td width="7%"><font size="1">Credit</font></td>
      <!--<td width="6%"><div align="center"><font size="1"><strong>EDIT</strong></font></div></td>-->
      <td width="7%"><font size="1">Delete</font></td>
    </tr>
    <%
	boolean bolIsDebit = false;
	for(int i = 0 ; i < vRetResult.size() ; i += 16){
	if( ((String)vRetResult.elementAt(i + 6)).startsWith("-"))
		bolIsDebit = false;
	else
		bolIsDebit = true;%>
    <tr>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 1)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 9)+"-"+(String)vRetResult.elementAt(i + 10)+"("+
	  (String)vRetResult.elementAt(i + 11)+")"%></font></td>
      <td height="25"><font size="1"><%=(String)vRetResult.elementAt(i + 8)%></font></td>
      <td><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 7)," CASH")/*check number if there is any.*/%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 12)," Transfered to : ","","")/*if transfered to any account.*/%></font></td>
      <td height="25"><font size="1">&nbsp; <%=WI.getStrValue(vRetResult.elementAt(i + 14))%></font></td>
      <td><font size="1"><%=vRetResult.elementAt(i + 15)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 13)%></font></td>
      <td height="25"><font size="1"><%if(bolIsDebit){%><%=(String)vRetResult.elementAt(i + 6)%><%}else{%>&nbsp;<%}%></font></td>
      <td><font size="1"><%if(!bolIsDebit){%><%=((String)vRetResult.elementAt(i + 6)).substring(1)%><%}else{%>&nbsp;<%}%></font></td>
      <!--      <td align="center"><img src="../../../images/edit.gif"></td>-->
      <td align="center"> <%
//if the refund is not from the same year/ sem, i should not allow any more.
/*if( ((String)vBasicInfo.elementAt(10)).compareTo((String)vRetResult.elementAt(i + 9)) == 0 &&
	((String)vBasicInfo.elementAt(11)).compareTo((String)vRetResult.elementAt(i + 10)) == 0 &&
	((String)vBasicInfo.elementAt(9)).compareTo((String)vRetResult.elementAt(i + 11)) == 0){*/%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'>
        <img src="../../../images/delete.gif" border="0"></a> <%//}else{%>
        <!--N/A-->
        <%//}%> </td>
    </tr>
    <%}//end of for loop.%>
  </table>
<%}//only if vRetResult is not null and having
}//only if vStudRefundTo is not null.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
