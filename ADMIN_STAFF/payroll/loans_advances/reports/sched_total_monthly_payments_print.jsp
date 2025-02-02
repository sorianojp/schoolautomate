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
<title>Print Schedule of Total Monthly payments</title>
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
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.
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
	String[] astrLoanType= {"Regular Retirement Fund","Emergency Loans","All Loans"};
	String[] astrSem= {"","1st Semester","2nd Semester"};
	int iSearchResult = 0;
	int i = 0;
	double dTotalPay = 0d;
	double dPrincipal = 0d;
	double dInterest = 0d;
	String strBank  = null;	
	
	strBank = dbOP.mapOneToOther("AC_COA_BANKCODE","bank_index",WI.fillTextValue("bank_index"),"bank_name","");
	
	vRetResult = PRRetLoan.getMonthlyPaySchedule(dbOP,request);		
	
%>
<body onLoad="javascript:window.print();">
<form name="form_" method="post" action="../../../retirement/reports/sched_total_monthly_payments_print.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="97%" height="27"><font color="#000000" size="2" face="Verdana, Arial, Helvetica, sans-serif">Schedule 
        of Monthly Principal &amp; Interest Payments for the</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27"><%=astrLoanType[Integer.parseInt(WI.getStrValue(WI.fillTextValue("loan_type"),"2"))]%> Released <%=astrSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%> (<%=WI.fillTextValue("release_date")%>)</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27"><%=WI.getStrValue(strBank,"Lending Bank: ","","")%></td>
    </tr>
    <tr> 
      <td height="10" colspan="2"><hr size="1"></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="33%" height="27">Total number of borrowers: </td>
      <td height="27"><div align="left"><strong>&nbsp;&nbsp;<%=(String)vRetResult.elementAt(0)%></strong></div></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27"> Total amount of released loans :</td>
      <td width="64%" height="27"><div align="left"><strong>&nbsp;&nbsp;<%=(String)vRetResult.elementAt(2)%></strong></div></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Effective interest rate (per annum) :</td>
      <td height="27"><div align="left"><strong>&nbsp;&nbsp;<%=(String)vRetResult.elementAt(1)%></strong></div></td>
    </tr>
    <tr> 
      <td height="10" colspan="3" class="BorderBottom"><hr size="1"></td>
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
    <%for(i = 3;i < vRetResult.size(); i+=4){%>
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
      <td height="25"><div align="center"></div></td>
    </tr>
  </table>
  <%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>