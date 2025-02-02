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
<title>Schedule of Total Monthly Payments</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function ReloadPage(){
	document.form_.proceed.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./sched_total_monthly_payments_print.jsp" />
<% return;}
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
			if(iAccessLevel == 0) {
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
			}						
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
	String strLoanType = null;
	String strCodeIndex = null;
	String[] astrLoanType = {"Regular Retirement Loan","Emergency Loan","Institutional/Company Loan", "SSS Loan", "PAG-IBIG Loan", 
							"PERAA Loan","GSIS Loan"};
							
	int iSearchResult = 0;
	int i = 0;
	double dTotalPay = 0d;
	double dPrincipal = 0d;
	double dInterest = 0d;	

	if (WI.fillTextValue("proceed").length() > 0) {
		vRetResult = PRRetLoan.getMonthlyLoanPaySchedule(dbOP,request);		
		if(vRetResult == null)
			strErrMsg = PRRetLoan.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="sched_total_monthly_payments.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: SCHEDULE OF TOTAL MONTHLY PAYMENTS PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="6%" height="27">&nbsp;</td>
      <td>&nbsp;Loan Type :</td>
      <%
	  	strLoanType = WI.fillTextValue("loan_type");
	  %>	  
      <td><select name="loan_type" onChange="ReloadPage();">
        <%for(i = 2; i < 7; i++){%>
        <%if(strLoanType.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=astrLoanType[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrLoanType[i]%></option>
        <%}%>
        <%}// end for loop%>
      </select></td>
    </tr>
    
    <tr>
      <td>&nbsp;</td>
      <td width="14%" height="27">&nbsp;Loan Name : </td>
      <td width="80%"><select name="code_index" onChange="ReloadPage();">
        <option value="">All</option>
        <%=dbOP.loadCombo("code_index","loan_name, loan_code ",
		                    " from ret_loan_code where is_valid = 1 and loan_type = " + WI.getStrValue(strLoanType,"2"),
							strCodeIndex ,false)%>
      </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27" colspan="2"><font size="1"><a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a></font><font size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%">&nbsp;</td>
      <td width="35%" height="27">Total number of borrowers: </td>
      <td><div align="right"></div></td>
      <td height="27">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27"> Total amount of released loans :</td>
      <td width="24%">&nbsp;</td>
      <td width="40%" height="27"><strong> </strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Effective interest rate (per annum) :</td>
      <td><div align="right"></div></td>
      <td height="27">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10" colspan="4" class="BorderBottom"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="19%" height="25" class="BorderBottomLeft"><div align="center"><strong>PAY 
          PERIOD</strong></div></td>
      <td width="26%" height="25" class="BorderBottomLeft"><div align="center"><strong>PRINCIPAL 
          PAYMENT</strong></div></td>
      <td width="27%" height="25" class="BorderBottomLeft"><div align="center"><strong>INTEREST 
          PAYMENT </strong></div></td>
      <td width="28%" class="BorderBottomLeftRight"><div align="center"><strong>TOTAL 
          PAYMENT </strong></div></td>
    </tr>
    <%for(i = 0;i < vRetResult.size(); i+=4){%>
    <tr> 
      <td height="20" class="BorderBottomLeft"><%=(String)vRetResult.elementAt(i)%></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+1);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dPrincipal += Double.parseDouble(strTemp);
	  %>
      <td class="BorderBottomLeft"><div align="right"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;</div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+2);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dInterest += Double.parseDouble(strTemp);
	  %>
      <td class="BorderBottomLeft"><div align="right"><%=(String)vRetResult.elementAt(i+2)%>&nbsp;</div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+3);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTotalPay += Double.parseDouble(strTemp);
	  %>
      <td class="BorderBottomLeftRight"><div align="right"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;</div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td>TOTALS :</td>
      <td height="24"><div align="right"><%=CommonUtil.formatFloat(dPrincipal,true)%>&nbsp;</div></td>
      <td height="24"><div align="right"><%=CommonUtil.formatFloat(dInterest,true)%>&nbsp;</div></td>
      <td><div align="right"><%=CommonUtil.formatFloat(dTotalPay,true)%>&nbsp;</div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0" ></a>click 
          to print</font></div></td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="proceed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>