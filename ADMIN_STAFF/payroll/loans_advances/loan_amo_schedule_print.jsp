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
<title>Print Loans schedule</title>
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

<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

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
	Vector vPersonalDetails = null;
	String[] astrTermUnit = {"months","years"};
	String strLoanType = WI.fillTextValue("loan_type");
	String strTypeName = null;
	String strLoanCode = null;
	double dTotalPay = 0d;
	double dPrincipal = 0d;
	double dInterest = 0d;

	if (WI.fillTextValue("emp_id").length() > 0) {
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
				
		if (vPersonalDetails == null || vPersonalDetails.size()==0){
			strErrMsg = authentication.getErrMsg();
			vPersonalDetails = null;
		}

		strLoanCode = dbOP.mapOneToOther("ret_loan_code", "is_valid","1",
								 "loan_code"," and code_index = " + WI.fillTextValue("code_index"));

		if(strLoanType.equals("3"))
			strTypeName = "SSS";
		else if	(strLoanType.equals("4"))
			strTypeName = "PAG-IBIG";	
	
		vRetResult = PRRetLoan.operateOnAmortization(dbOP,request,4);
	}


%>
<form name="form_" method="post" action="./loan_amo_schedule_print.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td height="27" colspan="2"><strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> (EMP # <%=WI.fillTextValue("emp_id")%>)</td>
      <td height="27"> Loan</td>
      <td height="27"><strong><%=WI.getStrValue(WI.fillTextValue("loan_amount"),"")%></strong></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="17%" height="27">Loan Code:</td>
      <td width="29%"><%=strLoanCode%></td>
      <td width="11%" height="27">Terms : </td>
      <td width="40%" height="27"><strong><%=WI.getStrValue(WI.fillTextValue("terms"),"")%> month(s) </strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2" align="center" class="BorderAll"><strong> 
      AMORTIZATION SCHEDULE FOR <%=strTypeName%> LOAN <%=WI.fillTextValue("loan_name")%></strong></td>
    </tr>
    <tr> 
      <td width="48%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">PAYROLL 
      PERIOD</font></strong></td>
      <td width="52%" height="24" align="center" class="BorderBottomLeftRight"><strong><font size="1">AMOUNT 
      DUE </font></strong></td>
	  <!--
      <td width="22%" height="24" class="BorderBottomLeft"><div align="center"><strong><font size="1">PRINCIPAL</font></strong></div></td>
      <td width="27%" class="BorderBottomLeftRight"><div align="center"><strong><font size="1">INTEREST</font></strong></div></td>
	  -->
    </tr>
    <%for(int i = 0; i < vRetResult.size() ; i+=15){%>
    <tr> 
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+2);
			strTemp = CommonUtil.formatFloat(strTemp, true);
			if(((String)vRetResult.elementAt(i+6)).equals("2"))
				strTemp = "**" + strTemp;
			else{
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTotalPay += Double.parseDouble(strTemp);
			}
			%>
      <td height="24" align="right" class="BorderBottomLeftRight"><%=strTemp%>&nbsp;</td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+3);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dPrincipal += Double.parseDouble(strTemp);
	  %>
	  <!--
      <td height="24" class="BorderBottomLeft"><div align="right"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;</div></td>
      <%
	  	//strTemp = (String)vRetResult.elementAt(i+4);
		//strTemp = ConversionTable.replaceString(strTemp,",","");
		//dInterest += Double.parseDouble(strTemp);
	  %>
      <td class="BorderBottomLeftRight"><div align="right"><%//=(String)vRetResult.elementAt(i+4)%>&nbsp;</div></td>
	  -->
    </tr>
    <%}%>
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td>TOTALS :</td>
      <td height="24" align="right"><%=CommonUtil.formatFloat(dTotalPay,true)%>&nbsp;</td>
	  <!--
      <td height="24"><div align="right"><%=CommonUtil.formatFloat(dPrincipal,true)%>&nbsp;</div></td>
      <td><div align="right"><%=CommonUtil.formatFloat(dInterest,true)%>&nbsp;</div></td>
	  -->
    </tr>
  </table>
  <%}%>
  <input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
  <input type="hidden" name="code_index" value="<%=WI.fillTextValue("code_index")%>">
  <input type="hidden" name="loan_type" value="<%=WI.fillTextValue("loan_type")%>">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>