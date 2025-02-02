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
<title>Print Schedule of Individual payments</title>
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

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.

//	int iAccessLevel = -1;
//	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
//	if(svhAuth == null)
//		iAccessLevel = -1; // user is logged out.
//	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
//		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
//	else {
//		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT-REPORTS"),"0"));
//		if(iAccessLevel == 0) {
//			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT"),"0"));
//		}
//	}
	
//	if(iAccessLevel == -1)//for fatal error.
//	{
//	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
//		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
//		response.sendRedirect("../../../../commfile/fatal_error.jsp");
//		return;
//	}
//	else if(iAccessLevel == 0)//NOT AUTHORIZED.
//	{
//		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
//		return;
//	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-RETIREMENT-ENCODE_LOADNS-Create Loans","loans_advances_entry.jsp");
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
	Vector vSchedule = null;
	Vector vPersonalDetails = null;
	String[] astrLoanType= {"Regular Retirement Fund","Emergency"};
	String[] astrYear= {"","1st","2nd","3rd","4th","5th"};
	int iTerm = 0;
	int iYear = 0;
	int iMonth = 0;
	int iLoanDtl = 14;
	int iTermUnit = 0;
	double dTotalPay = 0d;
	double dPrincipal = 0d;
	double dInterest = 0d;	
	String strLoanCode = null;
	strLoanCode = dbOP.mapOneToOther("ret_loan_code", "is_valid","1",
									 "loan_code"," and code_index = " + WI.fillTextValue("code_index"));
	
	enrollment.Authentication authentication = new enrollment.Authentication();
	vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	vRetResult = PRRetLoan.getLoanPaySchedule(dbOP,request);
	iTerm = Integer.parseInt((String)vRetResult.elementAt(2));
	iMonth = Integer.parseInt((String)vRetResult.elementAt(15));
	iYear = Integer.parseInt((String)vRetResult.elementAt(14));
	iTermUnit = Integer.parseInt((String)vRetResult.elementAt(16));
	vSchedule = (Vector)vRetResult.elementAt(17);
%>
<body onLoad="javascript:window.print();">
<form name="form_" method="post" action="./sched_ind_payments.jsp">
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td height="27" colspan="4"><strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> 
        (EMP # <%=WI.fillTextValue("emp_id")%>)</td>
      <td height="27"> Loan</td>
      <td height="27"><strong><%=WI.getStrValue((String)vRetResult.elementAt(1),"")%></strong></td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="12%" height="27">Loan Code:</td>
      <td width="23%"><%=strLoanCode%></td>
      <td width="9%" height="27">Terms : </td>
      <td width="14%" height="27"><strong><%=WI.getStrValue((String)vRetResult.elementAt(2),"")%></strong></td>
      <td width="12%" height="27">Interest /yr</td>
      <td width="28%" height="27"><strong><%=WI.getStrValue((String)vRetResult.elementAt(10),"")%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="7"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="6" align="center" class="BorderAll"><strong>:: 
      SCHEDULE OF SALARY DEDUCTIONS FOR LOAN PAYMENTS ::</strong></td>
    </tr>
    <tr> 
      <td width="14%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">PAYROLL 
      PERIOD</font></strong></td>
      <td width="17%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL 
      PAYMENT</font></strong></td>
      <td height="25" colspan="2" align="center" class="BorderBottomLeft"><strong><font size="1">PAYMENT 
      ON PRINCIPAL</font></strong></td>
      <td width="24%" align="center" class="BorderBottomLeft"><strong><font size="1">PAYMENT 
      ON INTEREST</font></strong></td>
      <td width="23%" align="center" class="BorderBottomLeftRight"><strong><font size="1">PRINCIPAL 
      BALANCE</font></strong></td>
    </tr>
    <% int j = 0;
			 int i = 0;
	   int iCount = 1;
		 if (iTermUnit == 0) {
        i = iTerm/12; // get number of years
        if(iTerm % 12 > 0){
          i++;
        }
				iTerm = i;
      }		 
	for(i = 1; i <= iTerm ; i++){%>
    <tr> 
      <td height="25" colspan="3">Year <%=i%>, SY <%=(iYear+i-1)%> - <%=(iYear+i)%>, &nbsp;&nbsp;&nbsp;&nbsp;Active Amount :</td>
      <td width="13%" align="right"><strong><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+4),"0"),true)%></strong></td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="6"><hr size="1"></td>
    </tr>
    <%if(vSchedule != null && vSchedule.size() > 0){
	    for(;j < vSchedule.size();j+=9,iCount++){			
		if (iCount > 24){
			iCount = 1;
			break;
		}
//		  if(!((String)vSchedule.elementAt(j+1)).equals(Integer.toString(iYear+i-1)) 
// 		      && ((String)vSchedule.elementAt(j+7)).equals(Integer.toString(iMonth + i-1)))
//		  	break;
	%>
    <tr> 
      <td height="18"><%=(String)vSchedule.elementAt(j)%> <%=(String)vSchedule.elementAt(j+1)%>, <%=(String)vSchedule.elementAt(j+2)%></td>
      <%
	  	strTemp = (String)vSchedule.elementAt(j+3);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTotalPay += Double.parseDouble(strTemp);
	  %>	  
      <td height="18"><div align="right"><%=(String)vSchedule.elementAt(j+3)%></div></td>
      <%
	  	strTemp = (String)vSchedule.elementAt(j+4);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dPrincipal += Double.parseDouble(strTemp);
	  %>	  
      <td height="18" colspan="2"><div align="right"><%=(String)vSchedule.elementAt(j+4)%></div></td>
      <%
	  	strTemp = (String)vSchedule.elementAt(j+5);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dInterest += Double.parseDouble(strTemp);
	  %>	  
      <td><div align="right"><%=(String)vSchedule.elementAt(j+5)%></div></td>
      <td><div align="right"><%=(String)vSchedule.elementAt(j+6)%></div></td>
    </tr>
    <%}
	}%>
    <tr> 
      <td height="19" colspan="6"><hr size="1"></td>
    </tr>
    <%}%>
    <tr> 
      <td>TOTAL :</td>
      <td height="24"><div align="right"><%=CommonUtil.formatFloat(dTotalPay,true)%></div></td>
      <td height="24" colspan="2"><div align="right"><%=CommonUtil.formatFloat(dPrincipal,true)%></div></td>
      <td><div align="right"><%=CommonUtil.formatFloat(dInterest,true)%></div></td>
      <td>&nbsp;</td>
    </tr>
    <!--
    <tr> 
      <td height="25" colspan="6"><div align="center"><font size="1"><a href='javascript:SaveClicked();'><img src="../../../../images/save.gif" border="0" name="hide_save"></a>click 
          to save entries</font></div></td>
    </tr>
	-->
    <%} // end if vRetResult != null%>
  </table>
  <input type="hidden" name="loan_type" value="<%=WI.fillTextValue("loan_type")%>">
  <input type="hidden" name="code_index" value="<%=WI.fillTextValue("code_index")%>">
  <input type="hidden" name="saved">	
  <input type="hidden" name="print_page">
  <input type="hidden" name="proceed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>