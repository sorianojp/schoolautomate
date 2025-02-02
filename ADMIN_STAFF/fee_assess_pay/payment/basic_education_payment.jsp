<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ShowHideCheckNO()
{
	if(document.form_.payment_type.selectedIndex == 1) {
		document.form_.CHECK_FR_BANK_INDEX.disabled = false;
		document.form_.CHECK_NO.disabled = false;
	}
	else {
		document.form_.CHECK_FR_BANK_INDEX.selectedIndex = 0;
		document.form_.CHECK_FR_BANK_INDEX.disabled = true;
		document.form_.CHECK_NO.disabled = true;
	}
	//show or hide emp ID input fields.
	if(document.form_.payment_type.selectedIndex == 2)
	{
		showLayer('_empID');
		showLayer('_empID1');
	}
	else
	{
		hideLayer('_empID');
		hideLayer('_empID1');
		document.form_.SD_EMP_ID.value = "";
	}

}
function AddRecord() {
	document.form_.add_record.value = 1;
	document.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud_basic.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage() {
	document.form_.add_record.value = "";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAElementaryPayment,java.util.Vector" buffer="16kb" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	WebInterface WI = new WebInterface(request);


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Basic Edu pmt","basic_education_payment.jsp");
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
														"basic_education_payment.jsp");
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

FAPaymentUtil pmtUtil = new FAPaymentUtil();
FAElementaryPayment faPayment = new FAElementaryPayment();
strTemp = WI.fillTextValue("add_record");

if(strTemp != null && strTemp.compareTo("1") ==0)
{
	if(faPayment.savePayment(dbOP,request))
	{
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./basic_edu_pmt_print.jsp?view_status=0&or_number="+
		request.getParameter("or_number")) );
		return;
	}
	else
		strErrMsg = faPayment.getErrMsg();
}

//I have to get elementary student information.
basicEdu.UserInformation uI = new basicEdu.UserInformation();
Vector vStudBasicInfo = null;
if(WI.fillTextValue("stud_id").length() > 0) {
	vStudBasicInfo = uI.operateOnBasicInfo(dbOP, request, 4);
	if(vStudBasicInfo == null && strErrMsg == null)
		strErrMsg = uI.getErrMsg();
}

%>

<form name="form_" action="./basic_education_payment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          BASIC EDUCATION PAYMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><b><font size="3"> <%=WI.getStrValue(strErrMsg)%></font></b></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">
	  <%//get here cutoff time information.
	  Vector vTempCO = new enrollment.FADailyCashCollectionDtls().getCurrentCutoffStat(dbOP, (String)request.getSession(false).getAttribute("userId"));//System.out.println(vTempCO);
	  //I have to get currency rate..
	  String strCurrencyInfo = new locker.Currency().getLatestCurrencyRate(dbOP);
	  if(vTempCO != null){%>
		  <table width="70%" class="thinborderALL" cellpadding="0" cellspacing="0">
		  <tr><td height="20" align="right">
		  <%
		  strTemp = "Time :: "+(String)vTempCO.elementAt(0);
		  if(vTempCO.elementAt(1) != null) {//cut off time is set.
		  	if( ((String)vTempCO.elementAt(2)).compareTo("1") == 0)
				strTemp += "<br><font color=red>Cut off :: "+(String)vTempCO.elementAt(1)+"</font>";
			else
				strTemp += "<br>Cut off :: "+(String)vTempCO.elementAt(1);
		  }
                  if(vTempCO.elementAt(2) != null)
                  	strTemp += "<br>Collection :: "+(String)vTempCO.elementAt(3);
                  %>
              <strong><%=strTemp%><%=strCurrencyInfo%></strong> </td>
          </tr>
		  </table>
	   <%}//only if cutoff time is set.%>
	  </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%" height="25">Education Level : </td>
      <td width="38%" height="25"><select name="EDU_LEVEL">
          <option value="0">Preparatory</option>
          <option value="1">Elementary</option>
          <option value="2">High School </option>
        </select></td>
      <td width="47%" height="25">School Year :
        <%
strTemp = WI.fillTextValue("SY_FROM");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="SY_FROM" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","SY_FROM","SY_TO")'>
        -
        <%
strTemp = WI.fillTextValue("SY_TO");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="SY_TO" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">School Name : <font size="1">&nbsp;</font></td>
      <td height="25" colspan="2"><select name="SCH_NAME">
          <%=dbOP.loadCombo("SCH_INDEX","SCH_NAME"," from SCHOOL_LIST order by SCH_NAME",strTemp,false)%> </select> </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="26">&nbsp;</td>
      <td width="10%" height="26">Student ID </td>
      <td width="25%" height="26" valign="top"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="26" border="0"></a></td>
      <td height="26">Year Level </td>
      <td height="26" colspan="3"> <select name="year_level">
          <option value="1">1st</option>
          <option value="2">2nd</option>
          <option value="3">3rd</option>
          <option value="4">4th</option>
          <option value="5">5th</option>
          <option value="6">6th</option>
        </select>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

		<a href="javascript:ReloadPage();"> <img src="../../../images/refresh.gif" border="1"></a>Click
        to refresh.</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">Last Name</td>
      <td height="25">
<%
if(vStudBasicInfo != null && vStudBasicInfo.size() > 0)
	strTemp = (String)vStudBasicInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("lname");
%>
	  <input type="text" name="lname" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="20"></td>
      <td width="8%" height="25">First Name </td>
      <td width="24%">
<%
if(vStudBasicInfo != null && vStudBasicInfo.size() > 0)
	strTemp = (String)vStudBasicInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("fname");
%>	  <input type="text" name="fname" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="20"></td>
      <td width="3%">Middle Name</td>
      <td width="28%">
<%
if(vStudBasicInfo != null && vStudBasicInfo.size() > 0)
	strTemp = (String)vStudBasicInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("mname");
%>
	  <input type="text" name="mname" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="20"></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="19" colspan="7"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudBasicInfo != null && vStudBasicInfo.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center">PAYMENT
          DETAILS </div></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">Amount paid </td>
      <td width="28%"> <input name="AMOUNT" type="text" size="12" value="<%=WI.fillTextValue("AMOUNT")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        Php </td>
      <td width="19%">Check #</td>
      <td width="33%"> <%
strTemp = "";
if(request.getParameter("payment_type") == null || 	 request.getParameter("payment_type").trim().length() ==0 ||
	request.getParameter("payment_type").compareTo("0") == 0)
{
	strTemp = "disabled";
}%> <input name="CHECK_NO" type="text" size="16" value="<%=WI.fillTextValue("CHECK_NO")%>" <%=strTemp%> class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <br>
        <select name="CHECK_FR_BANK_INDEX" style="font-size:10px" >
          <option value=""></option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE +':::'+BRANCH"," from FA_BANK_LIST where is_valid = 1 order by bank_code", request.getParameter("CHECK_FR_BANK_INDEX"), false)%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date paid</td>
      <td> <%
strTemp = WI.fillTextValue("DATE_PAID");
if(strTemp.length() ==0)
	strTemp = new enrollment.FADailyCashCollectionDtls().getProbableDateofPayment(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%> <input name="DATE_PAID" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.DATE_PAID');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td colspan="2">Reference number</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Payment type</td>
      <td valign="top"><font size="1">
        <select name="payment_type" onChange="ShowHideCheckNO();">
          <option value="0">Cash</option>
          <%
strTemp = WI.fillTextValue("payment_type");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Check</option>
          <%}else{%>
          <option value="1">Check</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Salary deduction</option>
          <%}else{%>
          <option value="2">Salary deduction</option>
          <%}%>
        </select>
        <br>
        <input name="text" type="text" class="textbox_noborder" id="_empID" value="Emp ID:" size="6" readonly="yes">
        <input type="text" name="SD_EMP_ID" value="<%=WI.fillTextValue("SD_EMP_ID")%>" size="12" id="_empID1" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </font> <script language="JavaScript">
ShowHideCheckNO();
</script> </td>
      <td colspan="2" valign="top"><font size="1"><b>
        <input name="or_number" type="text" size="16" value="<%=pmtUtil.generateORNumber(dbOP,(String)request.getSession(false).getAttribute("userId"))%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <!--		<%
	   	//strTemp = paymentUtil.generateORNumber(dbOP);
	   //	if(strTemp == null)
	   //		strTemp = paymentUtil.getErrMsg();
		//else{%>
        <input type="hidden" name="or_number" value="<%//=strTemp%>">
        <%//}%>
        <%//=strTemp%> -->
        </b></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp; </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25"><a href="javascript:AddRecord();"><img name="hide_save" src="../../../images/save.gif" border="0"></a>
        <font size="1">click to save entries&nbsp;</font></td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="10%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><div align="center"><font size="1"></font></div></td>
      <td width="5%" height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<%}%>
  <table width="100%" height="15" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td>&nbsp;</td>
  </tr>
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="add_record">
</form>
</body>
</html>
