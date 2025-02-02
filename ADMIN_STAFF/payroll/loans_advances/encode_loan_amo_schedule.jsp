<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Encode Loans amortization schedule</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function PageAction(strPageAction, strInfoIndex,strCode){	
	document.form_.donot_call_close_wnd.value = "1";
	if (strPageAction == 0){
		var vProceed = confirm('Delete '+strCode+' ?');
		if(vProceed){
			document.form_.page_action.value = strPageAction;
			document.form_.info_index.value = strInfoIndex;
			document.form_.prepareToEdit.value = "";
			this.SubmitOnce('form_');
		}
	}else if(strPageAction == 5){
		var vProceed = confirm('Are you sure you want to delete all?');
		if(vProceed){
			document.form_.page_action.value = strPageAction;
			document.form_.prepareToEdit.value = "";
			this.SubmitOnce('form_');
		}
	}else{	
		document.form_.page_action.value = strPageAction;
		document.form_.info_index.value = strInfoIndex;
		document.form_.prepareToEdit.value = "";
		this.SubmitOnce("form_");
	}
}

/*
function ComputeDue(){
	if (document.form_.principal_amt.value.length == 0)
		document.form_.principal_amt.value = "0";

	if (document.form_.interest_amt.value.length == 0)
		document.form_.interest_amt.value = "0";

	document.form_.due.value = eval(document.form_.principal_amt.value)+eval(document.form_.interest_amt.value);
	document.form_.due.value = truncateFloat(document.form_.due.value,1,false);
	
	
}
*/
function PrepareToEdit(strInfoIndex){
	document.form_.donot_call_close_wnd.value = "1";		
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function ReloadPage(){
	document.form_.proceed.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(strLoanType){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.prepareToEdit.value = "";
	ClearFields();
	this.SubmitOnce("form_");
}

function ClearFields(){
	//document.form_.principal_amt.value = "0";
	//document.form_.interest_amt.value = "0";
	document.form_.interest_amt.value = "0";
	document.form_.payment_date.value = "";
}

///////////////to reload parent window if this is closed //////////////
function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	
	window.opener.document.form_.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.form_.submit();
		window.opener.focus();
	}
}

-->
</script>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-RETIREMENT-ENCODE_LOADNS-Create Loans","sched_total_monthly_payments.jsp");
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

	//end of authenticaion code.	
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strPageAction = WI.fillTextValue("page_action");
	String strInfoIndex = WI.fillTextValue("info_index");
	String[] astrTermUnit = {"months","years"};
	String strLoanType = WI.fillTextValue("loan_type");
	String strTypeName = "Company";

	if (strPageAction.length() > 0){
		if (strPageAction.compareTo("0")==0) {
			if (PRRetLoan.operateOnAmortization(dbOP,request,0) != null){
				strErrMsg = "Loan code deleted successfully";
			}else{
				strErrMsg = PRRetLoan.getErrMsg();
			}
		}else if(strPageAction.compareTo("1") == 0){
			if (PRRetLoan.operateOnAmortization(dbOP,request,1) != null){
				strErrMsg = " Loan code saved successfully";
			}else{
				strErrMsg = PRRetLoan.getErrMsg();
			}
		}else if(strPageAction.compareTo("2") == 0){
			if (PRRetLoan.operateOnAmortization(dbOP,request,2) != null){
				strErrMsg = " Loan code updated successfully";
				strPrepareToEdit = "";
			}else{
				strErrMsg = PRRetLoan.getErrMsg();
			}
		}	
	}
	
	if (strPrepareToEdit.length() > 0){
		vEditInfo = PRRetLoan.operateOnAmortization(dbOP,request,3);
		if (vEditInfo == null)
			strErrMsg = PRRetLoan.getErrMsg();
	}
	
	vRetResult = PRRetLoan.operateOnAmortization(dbOP,request,4);	
	if (vRetResult != null && strErrMsg == null){
		strErrMsg = PRRetLoan.getErrMsg();	
	}
%>
<form name="form_" method="post" action="./encode_loan_amo_schedule.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <%if(strLoanType.equals("3")){
		strTypeName = "SSS";		
	%>
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
      PAYROLL : LOANS : ENCODE SSS LOAN AMORTIZATION SCHEDULE PAGE ::::</strong></font></td>
    </tr>
    <%}else if(strLoanType.equals("4")){
		strTypeName = "PAG-IBIG";
	%>
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong> 
        :::: PAYROLL : LOANS : ENCODE PAG-IBIG LOAN AMORTIZATION SCHEDULE PAGE 
    ::::</strong></font></td>
    </tr>
    <%}else if(strLoanType.equals("5")){
		strTypeName = "PERAA";
	%>
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong> 
        :::: PAYROLL : LOANS : ENCODE PERAA LOAN AMORTIZATION SCHEDULE PAGE 
    ::::</strong></font></td>
    </tr>	
    <%}%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25"><font size="1"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0"></a></font>click 
        to close window</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="4"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></font></td>
    </tr>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="16%">Payroll Period</td>
      <%
	  	if (vEditInfo!= null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(1);
		else
		  	strTemp = WI.fillTextValue("payment_date");
	  %>
      <td width="80%" colspan="2"><strong> 
        <input name="payment_date" type="text" class="textbox"
 	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="10" maxlength="10" readonly="yes">
        <a href="javascript:show_calendar('form_.payment_date');"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </strong></td>
    </tr>
	<!--
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Principal</td>
	  <%
	//  	if (vEditInfo!= null && vEditInfo.size() > 0)
	//		strTemp = (String) vEditInfo.elementAt(3);
	//	else	  
	//	  	strTemp = WI.fillTextValue("principal_amt");
	  %>
      <td colspan="2"><strong> 
        <input name="principal_amt" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="12" 
		onKeyUp="AllowOnlyIntegerExtn('form_','principal_amt','.');ComputeDue()" style="text-align: right">
        </strong> amount</td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Interest</td>
	  <%
	  //	if (vEditInfo!= null && vEditInfo.size() > 0)
		//	strTemp = (String) vEditInfo.elementAt(4);
		//else	  
		 // 	strTemp = WI.fillTextValue("interest_amt");
	  %>
      <td colspan="2"><strong> 
        <input name="interest_amt" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="12" 
		onKeyUp="AllowOnlyIntegerExtn('form_','interest_amt','.');ComputeDue()" style="text-align: right"
		onChange="ComputeDue()">
        </strong> amount</td>
    </tr>
	-->
    <tr> 
      <td height="38">&nbsp;</td>
      <td height="38">Interest Due</td>
	    <%
	  	if (vEditInfo!= null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(4);
		else	  
		  	strTemp = WI.fillTextValue("interest_amt");
	  %>	  
      <td height="38" colspan="2"><strong>
        <input name="interest_amt" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" style="text-align: right" size="10" maxlength="12">
        </strong></td>
    </tr>
    <tr> 
      <td height="31" colspan="4"><div align="center"><font size="1"></font></div>
        <div align="center">
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1, "","");'> <img src="../../../images/save.gif" border="0" id="hide_save"></a><font size="1"> 
          click to save entries</font> 
          <%}else{%>
          <a href="javascript:PageAction(2,'<%=strInfoIndex%>','');"> 
          <img src="../../../images/edit.gif"border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> 
          click to save changes</font> 
          <%}%>
          <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
          <font size="1" face="Verdana, Arial, Helvetica, sans-serif"> click to 
          </font><font size="1" face="Verdana, Arial, Helvetica, sans-serif">clear 
          fields </font></div></td>
    </tr>
  </table>	  
 <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF"> 
      <td height="25" colspan="4" align="center" class="BorderAll"><strong>:: 
        AMORTIZATION SCHEDULE FOR <%=strTypeName%> LOAN ::</strong></td>
    </tr>
    <tr> 
      <td width="13%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">DATE</font></strong></td>
      <td width="22%" align="center" class="BorderBottomLeft"><strong><font size="1">PRINCIPAL AMOUNT </font></strong></td>
      <td width="22%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">INTEREST AMOUNT </font></strong></td>
      <!--
	  <td width="22%" height="24" class="BorderBottomLeft"><div align="center"><strong><font size="1">PRINCIPAL</font></strong></div></td>	  
      <td width="27%" class="BorderBottomLeft"><div align="center"><strong><font size="1">INTEREST</font></strong></div></td>
	  -->
      <td width="16%" align="center" class="BorderBottomLeftRight">
		   <strong>
	     <font size="1">OPTION</font>		   </strong>		   <!--<br><a href="javascript:PageAction('5', '','')">DELETE ALL</a>-->		 </td>
    </tr>
    <%for(int i = 0; i < vRetResult.size() ; i+=15){%>
    <tr> 
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="right" class="BorderBottomLeft">&nbsp;</td>
      <td height="29" align="right" class="BorderBottomLeft"><%=(String)vRetResult.elementAt(i+4)%>&nbsp;</td>
      <!--
	  <td height="29" class="BorderBottomLeft"><div align="right"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;</div></td>	  
      <td class="BorderBottomLeft"><div align="right"><%=(String)vRetResult.elementAt(i+4)%>&nbsp;</div></td>
	  -->
      <td class="BorderBottomLeftRight"><div align="center"><font size="1"><a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"> 
          <img src="../../../images/edit.gif" border=0 > </a> <a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>','<%=(String)vRetResult.elementAt(i+1)%>')"><img src="../../../images/delete.gif" border="0"></a></font></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td>TOTALS :</td>
      <td>&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
  <input type="hidden" name="show_close" value="<%=WI.fillTextValue("show_close")%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
  <input type="hidden" name="code_index" value="<%=WI.fillTextValue("code_index")%>">
  <input type="hidden" name="loan_type" value="<%=WI.fillTextValue("loan_type")%>">
	<input type="hidden" name="ret_loan_index" value="<%=WI.fillTextValue("ret_loan_index")%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>