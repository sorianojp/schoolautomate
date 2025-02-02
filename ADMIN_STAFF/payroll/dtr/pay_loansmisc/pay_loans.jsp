<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRLoansAdv,payroll.PRSalaryExtn"%>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Pay Loans</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style>

.branch{
	display: none;
}
</style>
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
function CloseWindow(){
//	if(document.form_.opner_form_name.value == "form_1"){
//		window.opener.document.form_1.donot_call_close_wnd.value="1";
//	}
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();		
}

function AddLoan(strLoanIndex){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.addloan.value = "1";
	document.form_.loan_index.value = strLoanIndex;
	this.SubmitOnce("form_");
}

function ReloadMain(){
<% if (WI.fillTextValue("opner_form_field").length() != 0){%>
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>[window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>.selectedIndex].value = 
		document.form_.opner_form_field_value.value;
<% }%>

	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();

		window.opener.focus();
	}
}

function UpdateToZero(strTextName){
	if(eval('document.form_.'+strTextName+'.value.length') == 0){		
		eval('document.form_.'+strTextName+'.value= "0"');
	}	
}
function ComputeLoanPayable(strRow){
	var vPrincipal = eval('document.form_.principal_amt'+strRow+'.value');
	var vInterest =  eval('document.form_.interest_amt'+strRow+'.value');
	var vPeriodPay =  null;
	var vTotalPay = 0;
	var vLoanCount = document.form_.loan_count.value;
	  if (vPrincipal.length == 0){
		vPrincipal = "0";
	  }	
	  
	  if (vInterest.length == 0){
		vInterest = "0";
	  }
	  
	  vPeriodPay = eval(vPrincipal) +  eval(vInterest);
	  eval('document.form_.period_pay'+strRow+'.value = vPeriodPay');
}

///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}
///////////////////////////////////////// End of collapse and expand filter ////////////////////

-->
</script>
<%

	DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS/ADVANCES-View Edit","pay_loans.jsp");
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
														"Payroll","LOANS/ADVANCES",request.getRemoteAddr(),
														"pay_loans.jsp");
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
Vector vPersonalDetails = null;
Vector vRetResult = null;
String strEmpIndex = null;

PRLoansAdv prd = new PRLoansAdv(request);
PRSalaryExtn Salary = new PRSalaryExtn ();
if (WI.fillTextValue("emp_id").length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vPersonalDetails == null || vPersonalDetails.size()==0){
		strErrMsg = authentication.getErrMsg();
		vPersonalDetails = null;
	}
	 strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
}
String strLoanIndex = WI.fillTextValue("loan_index");
String strAddLoan = WI.fillTextValue("addloan");
//System.out.println(strAddLoan);
//System.out.println("strLoanIndex " +strLoanIndex);
if (strAddLoan.equals("1")){
	if(Salary.addBonusPaidLoans(dbOP,request, strLoanIndex) == false)
		strErrMsg = "Operation not successful<br>" + Salary.getErrMsg();
}
	vRetResult = prd.getLoansWithPayable(dbOP, strEmpIndex, WI.fillTextValue("index"), 
																			 WI.fillTextValue("index_name"), WI.fillTextValue("sal_period_index"));
 %>

<body bgcolor="#D2AE72" onUnload="ReloadMain();" class="bgDynamic">
<form name="form_" method="post" action="pay_loans.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : LOANS/ADVANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="14%" colspan="4"><strong>&nbsp;&nbsp;</strong> <strong></strong></td>
    </tr>
  </table>

<% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails!=null && vPersonalDetails.size() > 0){ %>
	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="2">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
      <td width="17%"><a href="javascript:CloseWindow();"><img src="../../../../images/close_window.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="6%" height="29">&nbsp;</td>
      <td height="29" colspan="2">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2">Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="29" colspan="2">Department/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td colspan="2">Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td colspan="2">Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%> </strong></td>
    </tr>
    <tr> 
      <td height="19" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <%if (vRetResult != null  && vRetResult.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">  	  
	    <table width="100%" cellpadding="0" cellspacing="0" border="1">
          <tr> 
            <td width="34%" height="25" align="center"> <strong><font size="1">LOAN</font></strong></td>
            <td width="19%" align="center"><font size="1"><strong>PAYABLE 
            PRINCIPAL</strong></font></td>
            <td width="19%" align="center"><font size="1"><strong>PAYABLE 
            INTEREST </strong></font></td>
            <td width="18%" align="center"><font size="1"><strong>TOTAL PAYABLE</strong></font></td>
            <td width="10%" align="center"><font size="1"><strong>OPTION</strong></font>            </td>
          </tr>
          <% int iRow = 0;
		  for (int i = 0;i<vRetResult.size();i+=7){
		  	iRow = Integer.parseInt((String)vRetResult.elementAt(i));
		  %>
          <tr> 
            <%  
				if(((String)vRetResult.elementAt(i+6)).equals("0"))
					strTemp = " - Retirement";
				else if(((String)vRetResult.elementAt(i+6)).equals("1"))
					strTemp = " - Emergency";
				else
					strTemp = "";
			%>
            <td height="34">&nbsp;&nbsp;<font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+4)%><%=WI.getStrValue((String)vRetResult.elementAt(i+5)," - ","",strTemp)%></font></td>
            <%
				strTemp = (String)vRetResult.elementAt(i+2);
			%>
            <td align="right"><font size="1"><strong>
              <input name="principal_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','principal_amt<%=iRow%>');ComputeLoanPayable('<%=iRow%>')" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','principal_amt<%=iRow%>');UpdateToZero('principal_amt<%=iRow%>');
			  ComputeLoanPayable('<%=iRow%>');style.backgroundColor='white'">
&nbsp;            </strong></font></td>
            <%
				strTemp = (String)vRetResult.elementAt(i+3);
			%>				
            <td align="right"><font size="1"><strong> 
              <input name="interest_amt<%=iRow%>" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"
			  onKeyUp="AllowOnlyFloat('form_','interest_amt<%=iRow%>');ComputeLoanPayable('<%=iRow%>')" style="text-align : right"
			  onBlur="AllowOnlyFloat('form_','interest_amt<%=iRow%>');UpdateToZero('interest_amt<%=iRow%>');
			  ComputeLoanPayable('<%=iRow%>');style.backgroundColor='white'">
&nbsp;            </strong></font></td>
            <%
				strTemp = (String)vRetResult.elementAt(i+1);
			%>
            <td align="right"><font size="1"><strong> 
              <input name="period_pay<%=iRow%>" type="text" size="10" maxlength="10" class="textbox_noborder"
			   value="<%=WI.getStrValue(strTemp,"0")%>" style="text-align : right" readonly>
&nbsp;            </strong></font></td>
            <td align="center"><font size="1"><a href='javascript:AddLoan("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/add.gif" width="42" height="32" border="0"></a></font></td>
          </tr>
          <%}%>
		  <input type="hidden" name="loan_count" value="<%=iRow%>">
        </table>	
	</td>
  </tr>
</table>
<%}%>

  <%
  }%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="addloan">
<input type="hidden" name="loan_index">
<input name="emp_id" type="hidden" value="<%=WI.fillTextValue("emp_id")%>"> 
<input type="hidden" name="is_collapsed" value="1">
<input type="hidden" name="index" value="<%=WI.fillTextValue("index")%>"> 
<input type="hidden" name="index_name" value="<%=WI.fillTextValue("index_name")%>"> 
<input type="hidden" name="sal_period_index" value="<%=WI.fillTextValue("sal_period_index")%>"> 
  <!-- this is used to reload parent if Close window is not clicked. -->
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>