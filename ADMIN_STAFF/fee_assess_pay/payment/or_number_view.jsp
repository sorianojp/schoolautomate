<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PRINT RECEIPT BY OR NUMBER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function focusOR() {
	document.form_.or_number.focus();
}
function FormProceed() {
	//I have to make sure for philcst, they select the correct OR.
	if(document.form_.print_type) {
		if(!document.form_.print_type[0].checked && !document.form_.print_type[1].checked) {
			alert("Please select either AR/OR to print.");
			return;
		}
	}
	if(document.form_.or_number.value.length == 0) {
		alert("Please enter OR Number");
		document.form_.or_number.focus();
		return;
	}
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72" onLoad="javascript:focusOR();">
<%@ page language="java" import="utility.DBOperation,utility.CommonUtil, utility.WebInterface,enrollment.FAPayment" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strPaymentFor = null;//0=TUTION, 1=OTHER SCHOOL FEE, 2= FINE, 3= SCHOOL FACILITY, 4 = variable school facility payment
	String strTuitionFeeType = null;//0=> payment during enrollment. > 0= installment payment.
	String strTemp = request.getParameter("or_number");
	String strErrMsg = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5 = WI.getStrValue((String)request.getSession(false).getAttribute("info5"));

	strErrMsg = null;


	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-assessedfees(enrollment)","assessedfees.jsp");
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


	if(strTemp == null || strTemp.trim().length() ==0)
	{
		strErrMsg = "Please enter OR Number.";
		strTemp = "";
	}
	else {//check if OR is already cancelled..
		String strSQLQuery = "select payment_index from FA_CANCEL_OR where OR_NUMBER = '"+strTemp+"' and is_valid = 1";
		if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null) {
			strErrMsg = "OR is already cancelled. Failed to reprint.";
			strTemp = "";
		}
	}

	if(strErrMsg == null) {
		boolean bolReturn = false;
		if(strSchCode == null)
			strSchCode = "";
		if(strSchCode.startsWith("PHILCST")){
			strTemp = WI.fillTextValue("print_type");
			if(strTemp.equals("1")){//print OR
				response.sendRedirect(response.encodeRedirectURL("./one_receipt_PHILCST.jsp?or_number="+request.getParameter("or_number")));
			}
			else {//print AR
				response.sendRedirect(response.encodeRedirectURL("./one_receipt_PHILCST_AR.jsp?or_number="+request.getParameter("or_number")));
			}
			bolReturn = true;
		}
            else {
              String strORFormName = utility.CommonUtil.getORFileName(null, request);
              if(strORFormName != null) {
                strORFormName +="?or_number="+request.getParameter("or_number")+"&reprint_=1";
                response.sendRedirect(response.encodeRedirectURL(strORFormName));
                bolReturn = true;
              }
            }
            /**
		if(strSchCode.startsWith("SPC")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_SPC.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("UB")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UB.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("WUP")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_WUP.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("CDD")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_CDD.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("UPH")){
		if(strInfo5.length() > 0)
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UPHS.jsp?or_number="+request.getParameter("or_number")));
		else
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UPH1.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("VMA")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_VMA.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("UC")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UC.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("EAC")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_EAC.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("FATIMA")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_FATIMA.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("CIT")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_CIT.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("UL")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UL.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("DBTC")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_DBTC.jsp?or_number="+strTemp));
			bolReturn = true;
		}
		if(strSchCode.startsWith("PIT")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_PIT.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("CSA")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_CSA.jsp?or_number="+request.getParameter("or_number")));
			bolReturn = true;
		}
		if(strSchCode.startsWith("AUF")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_AUF.jsp?or_number="+strTemp));
			bolReturn = true;
		}
		if(strSchCode.startsWith("WNU")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_WNU.jsp?or_number="+strTemp));
			bolReturn = true;
		}
		else if(strSchCode.startsWith("CLDH")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_CLDH.jsp?or_number="+strTemp));
			bolReturn = true;
		}
		else if(strSchCode.startsWith("CGH")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_CGH.jsp?reprint_=1&or_number="+strTemp));
			bolReturn = true;
		}
		else if(strSchCode.startsWith("UDMC")){
			response.sendRedirect(response.encodeRedirectURL("./one_receipt_UDMC.jsp?or_number="+strTemp));
			bolReturn = true;
		}
            **/

		if(bolReturn) {
			dbOP.cleanUP();
			return;
		}
	}

//add security here.
/**
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-assessedfees(enrollment)","assessedfees.jsp");
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
**/
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"assessedfees.jsp");


if(iAccessLevel == -1)//for fatal error.
{

	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
//end of authenticaion code.


java.util.Vector vRetResult = null;
if(strTemp.length() > 0)
{
	///if this is remittance type, i have to forward this to remittance page.
	if( dbOP.mapOneToOther("FA_REMITTANCE","OR_NUMBER","'"+strTemp+"'","REMITTANCE_INDEX",
							" and is_valid = 1 and is_del=0") != null) {//forward to remittance
		dbOP.cleanUP();
	%>
		<jsp:forward page="../remittance/remittance_print.jsp?or_number=<%=response.encodeURL(strTemp)%>" />
	<%return;
	}

	///for elementary or..
	if( dbOP.mapOneToOther("FA_ELEMENTARY_PAYMENT","OR_NUMBER","'"+strTemp+"'","ELEM_PMT_INDEX",
							" and is_valid = 1 and is_del=0") != null) {//forward to elementary payment receipt.
		dbOP.cleanUP();
	%>
		<jsp:forward page="./basic_edu_pmt_print.jsp?or_number=<%=response.encodeURL(strTemp)%>" />
	<%return;
	}



	//GET THE PAYMENT TYPE AND FORWARD DEPENDING ON THE PAYMENT.
	FAPayment faPayment = new FAPayment();
	vRetResult = faPayment.viewPmtDetail(dbOP,strTemp);
	if(vRetResult == null || vRetResult.size() ==0) {
		strErrMsg = faPayment.getErrMsg();
	}
	else
	{
		strPaymentFor = (String)vRetResult.elementAt(4);
		if(strPaymentFor.compareTo("0") ==0)
			strTuitionFeeType = (String)vRetResult.elementAt(27);
		else
			strTuitionFeeType = null;
	}
}
dbOP.cleanUP();

if(strErrMsg == null)
	strErrMsg = "";

if(strPaymentFor != null)
{
	if(strPaymentFor.compareTo("0") ==0 && strTuitionFeeType != null && strTuitionFeeType.compareTo("0") ==0  ) //this is for the enrollment payment receipt.
	{%>
			<jsp:forward page="./payment_prior_enrolment_print.jsp?or_number=<%=response.encodeURL(strTemp)%>" />
	<%}
	else if(strPaymentFor.compareTo("0") ==0 || strPaymentFor.compareTo("7") ==0)
	{%>
			<jsp:forward page="./install_assessed_fees_print_receipt.jsp?or_number=<%=response.encodeURL(strTemp)%>" />
	<%}
	else if(strPaymentFor.compareTo("4") ==0)//for dormitory.
	{%>
			<jsp:forward page="./schoolfacfees_print_receipt.jsp?or_number=<%=response.encodeURL(strTemp)%>" />
	<%}
	else//for fine or school facility like internet fee..
	{%>
			<jsp:forward page="./otherschoolfees_print_receipt.jsp?or_number=<%=response.encodeURL(strTemp)%>" />
	<%}
}
//may be this is for Deposit for dormitory -- it is quite rare though.
if(strTemp.length() > 0)
{%>
			<jsp:forward page="./schoolfacfees_print_receipt.jsp?or_number=<%=response.encodeURL(strTemp)%>" />
<%}
%>
<form name="form_" action="./or_number_view.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: PRINT RECEIPT BY OR NUMBER ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp; &nbsp; &nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strSchCode.startsWith("PHILCST")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25">
	  <input type="radio" name="print_type" value="1"> Print OR &nbsp;&nbsp;&nbsp;&nbsp;
	  <input type="radio" name="print_type" value="2"> Print AR </td>
      <td colspan="2">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">Enter Reference Number: </td>
      <td width="28%" height="25"><input name="or_number" type="text" size="20" value="<%=strTemp%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="50%" colspan="2">
	  <input type="button" value="Re-print OR" onClick="FormProceed()"></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25">&nbsp;</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
	</tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
