<%
String strStudID    = (String)request.getSession(false).getAttribute("userId");
String strSYFrom    = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo      = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strSemester  = (String)request.getSession(false).getAttribute("cur_sem");


if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function SetSYTerm() {
	document.form_.is_sy_set.value = '1';
	
	objButton = document.getElementById('_setSY');
	objButton.disabled=true;
	
	objInProgress = document.getElementById("_setSYImg");
	objInProgress.style.visibility='visible';
	
	document.form_.amount_.value = '';
	document.form_.submit();
}
function ResetSYTerm() {
	document.form_.is_sy_set.value = '';
	document.form_.amount_.value = '';
	document.form_.submit();
}
function PrintPermit(strPmtSch) {
	var loadPg = "../../ADMIN_STAFF/fee_assess_pay/reports/admission_slip_batch_print_generic.jsp?sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+"&offering_sem="+
	document.form_.semester.value+"&semester="+document.form_.semester.value+
	"&pmt_schedule="+strPmtSch+"&print_one=1";
	
	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body>
<jsp:include page="./inc.jsp?pgIndex=4" />

<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	if(WI.fillTextValue("sy_from").length() > 0) {
		strSYFrom    = WI.fillTextValue("sy_from");
		strSYTo      = WI.fillTextValue("sy_to");
		strSemester  = WI.fillTextValue("semester");
	}
	

	String strErrMsg = null;
	String strTemp   = null;
	String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};

//add security here.
	try
	{
		dbOP = new DBOperation();
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
String strConvertSem[] = {"Summer","First Term","Second Term","Third Term"};
boolean bolIsSYSet = false;
if(WI.fillTextValue("is_sy_set").equals("1"))
	bolIsSYSet = true;

Vector vUserInfo = null;
Vector vScheduledPmtNew = null;

int iEnrollStat = -2;// 0 = not enrolled, 1 = enrolled, 2 = enrolling, 3 = enrolled in advanced Sy-term.
String strSQLQuery = null;
boolean bolIsFatalErr = false; /// if true, do not proceed to payment.. 
//get to fatal err if iEnrollStat != 1 ---- 
OfflineAdmission offlineAdm = new OfflineAdmission();
onlinepayment.OnlinePayment op = new onlinepayment.OnlinePayment();
if(WI.fillTextValue("amount_").length() > 0 && WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0 && WI.fillTextValue("pmt_method").length() > 0) {
	//I am all set to pay online.. 
	//get URL to forward.. 
	String strForwordURL = "select PHP_SERVER_URL from ONLINE_PMT_INST_PROFILE";
	strForwordURL = dbOP.getResultOfAQuery(strForwordURL, 0);
	if(strForwordURL == null) {
		strErrMsg = "Instituion Information not yet set.";
	}
	else {
		String strCheckSum = op.initOnlinePayment(dbOP, request);
		if(strCheckSum == null) 
			strErrMsg = op.getErrMsg();
		else {
			String strURL = request.getRequestURL().toString();
			strTemp = request.getServletPath().toString();			
			strURL = strURL.substring(0,strURL.indexOf(strTemp) + 1);
			if(!op.createMySQLEntries(dbOP,strCheckSum, strURL)) 
				strErrMsg = op.getErrMsg();
			else {
				strForwordURL = strForwordURL + "?trans_ref="+strCheckSum;
				dbOP.cleanUP();
				//System.out.println(strForwordURL);
				response.sendRedirect(response.encodeURL(strForwordURL));
				return;
			}
		}
	}
}

if(bolIsSYSet) {
	vUserInfo = offlineAdm.getStudentBasicInfo(dbOP, strStudID);
	if(vUserInfo == null) 
		strErrMsg = offlineAdm.getErrMsg();
	else {///check if enrolled, or enrolled in advanced sy-term.
		//strSYFrom,strSemester = user intend to pay.. this sy-term must be either same or greater.. If less, than, not allowed.. 
		iEnrollStat = CommonUtil.compareSYTerm(strSYFrom, strSemester, (String)vUserInfo.elementAt(10), (String)vUserInfo.elementAt(9));
		if(iEnrollStat == 0)
			iEnrollStat = 1;
	}
}
if(bolIsSYSet && vUserInfo != null && iEnrollStat != 1) {
	strErrMsg = "Failed to Proceed. Not Enrolled, Please check SY-Term selected.";
	bolIsFatalErr = true;
}

//get payment sched and os balance information here.
double dOutStandingBal = 0d; double dRunningBal = 0d;
enrollment.FAFeeOperation fOperation  = new enrollment.FAFeeOperation();
enrollment.FAAssessment FA = new enrollment.FAAssessment();
//FAPaymentUtil pmtUtil = new FAPaymentUtil();
//FAPayment faPayment = new FAPayment();


String strPmtSchIndex = null;
long lTime = new java.util.Date().getTime();
if(iEnrollStat == 1) {
	vScheduledPmtNew = FA.getInstallmentSchedulePerStudAllInOne(dbOP,(String)vUserInfo.elementAt(12),strSYFrom, strSYTo,(String)vUserInfo.elementAt(14),strSemester);
	if(vScheduledPmtNew == null || vScheduledPmtNew.size() == 0) {
		strErrMsg = FA.getErrMsg();
		bolIsFatalErr = true;
	}
	else {
		dOutStandingBal = Double.parseDouble(ConversionTable.replaceString((String)vScheduledPmtNew.elementAt(6),",",""));
		strPmtSchIndex = (String)vScheduledPmtNew.elementAt(7);
		strPmtSchIndex = "select pmt_sch_index from fa_pmt_schedule where exam_name = '"+strPmtSchIndex+"' and is_valid > 0";
		strPmtSchIndex = dbOP.getResultOfAQuery(strPmtSchIndex, 0);
	}
}

Vector vPmtSch = new Vector();
java.sql.ResultSet rs = null;
strSQLQuery = "select pmt_sch_index, exam_name from fa_pmt_schedule where is_valid = 1";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vPmtSch.addElement(rs.getString(1));
	vPmtSch.addElement(rs.getString(2));
}
rs.close();
%>
<form name="form_" action="./print_permit.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#47768F"><div align="center"><font color="#FFFFFF"><strong>::::
      PRINT PERMIT PAGE ::::</strong></font></div></td>
    </tr>
  </table>
<%
if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" style="font-weight:bold; color:#FF0000; font-size:16px;">Failed to Proceed ==> (Message): <%=strErrMsg%></td>
    </tr>
  </table>
<%}
if(!bolIsSYSet){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%" style="font-size:20px; font-weight:bold">SY-TERM</td>
      <td width="50%" height="25"> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox_bigfont" style="font-size:20px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
 <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox_bigfont" style="font-size:20px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester" style="font-size:20px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif">
         <option value="1">1st Term</option>
<%
if(strSemester.compareTo("2") ==0){%>
          <option value="2" selected>2nd Term</option>
<%}else{%>
          <option value="2">2nd Term</option>
<%}if(strSemester.compareTo("3") ==0){%>
          <option value="3" selected>3rd Term</option>
<%}else{%>
          <option value="3">3rd Term</option>
<%}if(strSemester.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
      </select>       
	  &nbsp;&nbsp;&nbsp;&nbsp;
	   <input type="button" name="12" value=" Proceed >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="SetSYTerm();" id="_setSY">
	   &nbsp;&nbsp;&nbsp;
	   <label id="_setSYImg" style="visibility:hidden;">
	   <img src="../../Ajax/ajax-loader_small_black.gif">
	   </label>
	   
      </td>
      <td width="35%" style="font-size:24px; font-weight:bold" align="right">&nbsp;</td>
    </tr>
  </table>
	
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%" height="25" style="font-size:20px; font-weight:bold"><%=strConvertSem[Integer.parseInt(strSemester)]%>, <%=strSYFrom%> - <%=strSYTo.substring(2)%>&nbsp;&nbsp;&nbsp;&nbsp;
	    <input type="button" name="12" value=" Reset SY-Term >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="ResetSYTerm();" id="_resetButton">      
		
		&nbsp;&nbsp;&nbsp;
	   <label id="_setSYImg" style="visibility:hidden;">
	   <img src="../../Ajax/ajax-loader_small_black.gif">
	   </label>
		
	  </td>
      <td width="50%" style="font-size:24px; font-weight:bold" align="right">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="sy_from" value="<%=strSYFrom%>">
<input type="hidden" name="sy_to" value="<%=strSYTo%>">
<input type="hidden" name="semester" value="<%=strSemester%>">
<%}if(vUserInfo != null && vUserInfo.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="39%" height="25">Student ID :<strong> <%=strStudID%></strong></td>
      <td width="59%" height="25"  colspan="4">Student Name: <strong><%=WI.formatName((String)vUserInfo.elementAt(0),(String)vUserInfo.elementAt(1),(String)vUserInfo.elementAt(2),4 )%></strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Last Enrolled SY-Term: <strong><%=strConvertSem[Integer.parseInt((String)vUserInfo.elementAt(9))]%>, <%=(String)vUserInfo.elementAt(10)%> - <%=((String)vUserInfo.elementAt(11)).substring(2)%></strong></td>
      <td  colspan="4">Last Enrolled Course-Yr: <b>
	  <%=(String)vUserInfo.elementAt(24)%><%=WI.getStrValue((String)vUserInfo.elementAt(25), " ", "","")%>
	  <%=WI.getStrValue((String)vUserInfo.elementAt(14), "-", "","")%>
	  </b>
	  </td>
    </tr>
  </table>
<%if(!bolIsFatalErr) {%>	
	
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr bgcolor="#B9B292">
		  <td width="20%" height="25" align="center" bgcolor="#BECED3" class="thinborder"><strong><font size="1">PAYMENT SCHEDULE</font></strong></td>
		  <td width="20%" align="center" bgcolor="#BECED3" class="thinborder"><font size="1"><strong>REQUIRED AMOUNT</strong></font></td>
		  <td width="20%" bgcolor="#BECED3" class="thinborder" align="center"><font size="1"><strong>PAYABLE BALANCE</strong></font></td>
		  <td width="15%" bgcolor="#BECED3" class="thinborder" align="center"><font size="1"><strong>PRINT PERMIT </strong></font></td>
		</tr>
			<%int iIndexOf = 0;//System.out.println(vScheduledPmtNew);
			double dCumulativeBal = 0d; double dPay = 0d; int iCount = 0;
			for(int i = 7; i < vScheduledPmtNew.size(); i += 2, ++iCount) {
				double dTemp = ((Double)vScheduledPmtNew.elementAt(i + 1)).doubleValue();
				//System.out.println(vScheduledPmtNew.elementAt(i));
				//System.out.println(vScheduledPmtNew.elementAt(i + 1));
				if( (i + 2) < vScheduledPmtNew.size())
				//System.out.println(vScheduledPmtNew.elementAt(i + 2));
				if( (i + 3) < vScheduledPmtNew.size())
				//System.out.println(vScheduledPmtNew.elementAt(i + 3));
				if(dTemp < 0d) {
					if( (i + 3) <  vScheduledPmtNew.size()) {
						vScheduledPmtNew.setElementAt(new Double(((Double)vScheduledPmtNew.elementAt(i + 3)).doubleValue() + dTemp), i + 3);
					}
					dTemp = 0d;
					
				}
				dCumulativeBal += dTemp;
				if((i + 3) > vScheduledPmtNew.size() && dOutStandingBal != dCumulativeBal)
					dCumulativeBal = dOutStandingBal;
				
				dPay = dCumulativeBal;
				if(dPay < 1d) 
					dPay = 0d;
			%>
			<tr>
			  <td height="25" class="thinborder" style="font-size:18px;"><%=vScheduledPmtNew.elementAt(i)%></td>
			  <td align="right" class="thinborder" style="font-size:18px;"><%=CommonUtil.formatFloat(dTemp, true)%></td>
			  <td class="thinborder" align="right" style="font-size:18px;"><%=CommonUtil.formatFloat(dPay, true)%></td>
			  <td class="thinborder" align="center">
			  <%if(dPay <= 0d) {
			  	strTemp = (String)vScheduledPmtNew.elementAt(i);
				iIndexOf = strTemp.indexOf(" ");
				if(iIndexOf > 0)
					strTemp = strTemp.substring(0, iIndexOf);
			  %>
			  	<input type="button" name="12" id="_<%=iCount%>" value=" Print <%=strTemp%> Permit" style="font-size:11px; height:28px;border: 1px solid #FF0000; width:150px" onClick="PrintPermit('<%=vPmtSch.elementAt(vPmtSch.indexOf(vScheduledPmtNew.elementAt(i)) - 1)%>');">
			  <%}else{%>
			  	&nbsp;
			  <%}%>
			  </td>
			</tr>
		<%}%>
	  </table>


	<br>
	
	<font style="font-weight:bold; font-size:14px;"><u>INSTRUCTION: </u></font><br>
	<p>- Use a any blank letter size bond paper. </p>
	<p>- Print the permit for the current examination period and show to exam proctors during examinations.</p>
	<p align="justify">- Students may also proceed to the registrar’s/accounting office to have their permits printed (if students do not have access to a printer). There is no extra charge for exam permit printing.</p> 
	


<%
}%>


<%} //only if basic info is not null;
%>
<input type="hidden" name="is_sy_set" value="<%=WI.fillTextValue("is_sy_set")%>">
<input type="hidden" name="amount_" value="">
<%if(strPmtSchIndex != null){%>
	<input type="hidden" name="pmt_schedule" value="<%=strPmtSchIndex%>">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>