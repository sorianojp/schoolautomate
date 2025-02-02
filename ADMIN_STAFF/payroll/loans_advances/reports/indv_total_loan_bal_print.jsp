<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Individual Total Loan Balances</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
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
TD.BorderNone{
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
	String strTemp2 = null;
	String strTemp3 = null;
	String strPrevEmp = null;

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
								"Admin/staff-RETIREMENT-ENCODE_LOANS-Create Loans","indv_total_loan_bal_print.jsp");
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
	String strLoanType = WI.fillTextValue("loan_type");
	String[] astrLoanType = {"Regular Retirement Loan","Emergency Loan","Institutional/Company Loan", 
							"SSS Loan", "PAG-IBIG Loan", "PERAA Loan","GSIS Loan",""};
	String strTypeName = astrLoanType[Integer.parseInt(WI.getStrValue(WI.fillTextValue("loan_type"),"7"))];
	boolean[] abolShowList= {false, false, false, false, false};
	int iIndex = 0;
	
	int iSearchResult = 0;
	int i = 0;
	int iCount = 0;
	boolean bolPageBreak = false;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dPayable = 0d;
	int iRemaining = 0;
	double dMonthly = 0d;
	double dBalance = 0d;
	for(; iIndex < 5; iIndex++){
		if(WI.fillTextValue("checkbox"+iIndex).equals("1")){
			abolShowList[iIndex] = true;
		}
	}	
	vRetResult = PRRetLoan.getIndLoanBal(dbOP,request);
//	int i = 0; int k = 0; int iNumGrading = 0; int iCount = 0;
	int iMaxRecPerPage =Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	
 if(vRetResult != null && vRetResult.size() > 0){
	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr = 1;
	int iPage = 1;
	for (;iNumRec < vRetResult.size();iPage++){
		strPrevEmp = "";
%>
<body onLoad="javascript:window.print();">
<form name="form_">
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td colspan="12" class="thinborderBOTTOM">&nbsp;OUTSTANDING <%=WI.getStrValue(strTypeName," ").toUpperCase()%> BALANCES</td>
  </tr>
  <tr>
    <td height="25" colspan="12">&nbsp;AS OF <%=WI.getTodaysDate(1)%></td>
  </tr>
  <tr> 
    <td height="25" colspan="12" align="right" class="BorderNone">Page <%=iPage%> </td>
  </tr>
  <tr> 
    <td width="3%" height="19" class="BorderBottom">&nbsp;</td>
    <td width="6%" align="center" class="BorderBottom"><strong><font size="1">ID</font></strong></td>
    <td width="23%" align="center" class="BorderBottom"><font size="1"><strong>NAME 
      OF EMPLOYEE</strong>&nbsp;</font></td>
		<%if (abolShowList[0]){%>
    <td width="8%" align="center" class="BorderBottom"><strong><font size="1">REF # </font></strong></td>
		<%}%>
    <td width="11%" align="center" class="BorderBottom"><strong><font size="1">LOAN CODE </font></strong></td>
		<%if (abolShowList[1]){%>
    <td width="9%" align="center" class="BorderBottom"><strong><font size="1">DATE AVAILED </font></strong></td>
		<%}%>
    <td width="8%" align="center" class="BorderBottom"><strong><font size="1">AMOUNT LOAN </font></strong></td>
		<%if (abolShowList[2]){%>
    <td width="8%" align="center" class="BorderBottom"><strong><font size="1">MONTHLY </font></strong></td>
		<%}%>
    <!--
		<td width="11%" align="center" class="BorderBottom"><strong><font size="1">TOTAL 
      PAYMENT</font></strong></td>
		-->
    <td width="8%" align="center" class="BorderBottom"><strong><font size="1">LOAN BALANCE</font></strong></td>
		<%if (abolShowList[3]){%>
    <td width="8%" align="center" class="BorderBottom"><strong><font size="1">PAYMENT TO DATE</font></strong></td>
		<%}%>
		<%if (abolShowList[4]){%>
    <td width="8%" align="center" class="BorderBottom"><strong><font size="1">REMAINING PERIOD </font></strong></td>
		<%}%>
  </tr>
  <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;
			
		if(strPrevEmp.equals((String)vRetResult.elementAt(i+8))){
			strTemp2 = "";
			strTemp = "";
			strTemp3 = "";
		}else{			
			strTemp = Integer.toString(iIncr)+".";
			strTemp2 = WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), 4);
			strTemp3 = (String)vRetResult.elementAt(i+10);
			iIncr++;
		}
	%>
  <tr> 
    <td valign="bottom" class="BorderNone"><div align="right"><font size="1"><%=strTemp%></font>&nbsp;</div></td>
    <td valign="bottom" class="BorderNone">&nbsp;<%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
    <td height="18" valign="bottom" class="BorderNone"><font size="1"><strong>&nbsp;&nbsp;<%=WI.getStrValue(strTemp2, "&nbsp;")%></strong></font></td>
    <%if (abolShowList[0]){%>
		<td valign="bottom" class="BorderNone">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp;")%></td>
		<%}%>
    <td valign="bottom" class="BorderNone">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%></td>
    <%if (abolShowList[1]){%>
		<td valign="bottom" class="BorderNone">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;")%></td>
		<%}%>
    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalLoan += Double.parseDouble(strTemp);
		%>
    <td align="right" valign="bottom" class="BorderNone">&nbsp; <%=strTemp%></td>
		<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+12),true);
			dMonthly = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));					
		if (abolShowList[2]){		
		%>			
    <td align="right" valign="bottom" class="BorderNone"><%=strTemp%></td>
		<%}%>
    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalPaid += Double.parseDouble(strTemp);
	%>
		<!--
    <td align="right" valign="bottom" class="BorderNone">&nbsp; <%=strTemp%>&nbsp;</td>
		-->
    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dBalance = Double.parseDouble(strTemp);
		dPayable += dBalance;
	%>
    <td align="right" valign="bottom" class="BorderNone">&nbsp; <%=strTemp%></td>
    <%if (abolShowList[3]){%>
		<td align="right" valign="bottom" class="BorderNone"><%=strTemp%></td>
		<%}%>
		<%if (abolShowList[4]){%>
		<%		
		//iRemaining = (int)(dBalance/dMonthly);
		//dBalance = dBalance - (dMonthly * iRemaining);
		//if(dBalance > 3)
		//	iRemaining++;
			strTemp = (String)vRetResult.elementAt(i+14);
	  %>			
    <td align="right" class="BorderNone" valign="bottom"><%=strTemp%></td>
		<%}%>
  </tr>
  
  <%
	strPrevEmp = (String)vRetResult.elementAt(i+8);
	} // end for loop%>
  <tr> 
    <td colspan="13" class="BorderNone"><hr size="1"></td>
  </tr>
  <%if ( iNumRec >= vRetResult.size()) {%>
  <tr> 
    <td height="19" colspan="3" align="right" class="BorderBottom">TOTAL : 
    &nbsp; </td>
    <%if (abolShowList[0]){%>
		<td height="19" align="right" class="BorderBottom">&nbsp;</td>
		<%}%>
    <td class="BorderBottom">&nbsp;</td>
    <%if (abolShowList[1]){%>
		<td align="right" class="BorderBottom">&nbsp;</td>
		<%}%>
    <td align="right" class="BorderBottom"><%=CommonUtil.formatFloat(dTotalLoan,true)%></td>
		<%if (abolShowList[2]){%>
    <td align="right" class="BorderBottom">&nbsp;</td>
		<%}%>
    <!--
		<td align="right" class="BorderBottom"><%=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</td>
		-->
    <td align="right" class="BorderBottom"><%=CommonUtil.formatFloat(dPayable,true)%></td>
    <%if (abolShowList[3]){%>
		<td align="right" class="BorderBottom">&nbsp;</td>
		<%}%>
		<%if (abolShowList[4]){%>
    <td align="right" class="BorderBottom">&nbsp;</td>
		<%}%>
  </tr>
  <%}else{// end iNumStud >= vRetResult.size()%>
  <tr> 
    <td colspan="12"  class="thinborder"><div align="center"><font size="1">************** 
        CONTINUED ON NEXT PAGE ****************</font></div></td>
  </tr>
  <%}//end else%>
</table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
}
%>

  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="release_date" value="<%=WI.fillTextValue("release_date")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>