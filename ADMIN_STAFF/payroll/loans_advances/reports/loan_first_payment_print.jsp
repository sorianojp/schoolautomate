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
<title>Individual Total Loan balances</title>
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
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp3 = null;
	int iRemaining = 0;
	boolean bolHasTeam = false;

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
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS-Reports-Individual Total balances","loan_first_payment.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");								
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
	String strTypeName = null;	
	boolean[] abolShowList= {false, false, false, false, false};
	int iIndex = 0;
 
	int iSearchResult = 0;
	int iDefault = 0;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dPayable = 0d;
	String strPrevEmp = null;
	String strTemp2 = null;
	double dMonthly = 0d;
	double dMonthlyTotal = 0d;
	double dBalance = 0d;
	int i = 0;
	int iCount = 0;
	boolean bolPageBreak = false;	
	for(; iIndex < 5; iIndex++){
		if(WI.fillTextValue("checkbox"+iIndex).equals("1")){
			abolShowList[iIndex] = true;
		}
	}
 		vRetResult = PRRetLoan.getLoanFirstPayment(dbOP,request);		
	int iMaxRecPerPage =Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	
	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iPage = 1;
	for (;iNumRec < vRetResult.size();iPage++){		
 %>
<body onLoad="javascript:window.print();">
<form name="form_">
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 
    <tr>
      <td height="15" colspan="13" align="center" class="BorderBottom"><strong>Loans First Payment </strong></td>
    </tr>
    <tr> 
      <td width="3%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">COUNT</font></strong></td>
      <td width="7%" align="center" class="BorderBottomLeft"><strong><font size="1">ID</font></strong></td>
      <td width="24%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">EMPLOYEE 
      NAME</font></strong></td>
			<%if (abolShowList[0]){%>
      <td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">REF # </font></strong></td>
			<%}%>
      <td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN CODE </font></strong></td>
      <%if (abolShowList[1]){%>
			<td width="10%" align="center" class="BorderBottomLeft"><strong><font size="1">DATE AVAILED </font></strong></td>
			<%}%>
			<td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">START DATE </font></strong></td>
      <td width="8%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">AMOUNT LOAN </font></strong></td>
			<td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">MONTHLY </font></strong></td>
      <!--
			<td width="12%" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL PAYMENT</font></strong></td>
			-->
      <%if (abolShowList[2]){%>
			<td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN BALANCE</font></strong></td>
			<%}%>
      <%if (abolShowList[3]){%>
			<td width="8%" align="center" nowrap class="BorderBottomLeft"><strong><font size="1">PAYMENT<br>
			  TO DATE<br>
			  (in System)
</font></strong></td>
			<%}%>
			<%if (abolShowList[4]){%>
      <td width="8%" align="center" class="BorderBottomLeftRight"><strong><font size="1">REMAINING PERIOD </font></strong></td>
			<%}%>
    </tr>
    <%
 	strPrevEmp = "";
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20,++iIncr, ++iCount){
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
			strTemp = Integer.toString(iCount)+".";
			strTemp2 = WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), 4);
			strTemp3 = (String)vRetResult.elementAt(i+10);
			iCount++;
		}
	%>
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
      <td class="BorderBottomLeft"><%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
      <td height="24" class="BorderBottomLeft"><font size="1"><strong>&nbsp;&nbsp;<%=strTemp2%></strong></font></td>
      <%if (abolShowList[0]){%>
			<td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp;")%></td>
			<%}%>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%></td>
      <%if (abolShowList[1]){%>
			<td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;")%></td>
			<%}%>
      <%	
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
				strTemp = ConversionTable.replaceString(strTemp,",","");		
				dTotalLoan += Double.parseDouble(strTemp);
			%>							
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+16),"&nbsp;")%></td> 
			<td height="24" align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
      <%	
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+12),true);
			dMonthly = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));			
			dMonthlyTotal += dMonthly;
		  %>				
			<td align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>			
	  <!--
		<td align="right" class="BorderBottomLeft">&nbsp;<%//=strTemp%>&nbsp;</td>
		-->
		<%if (abolShowList[2]){
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dBalance = Double.parseDouble(strTemp);
		dPayable += dBalance;
		%>      
	  <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
		<%}%>
	  <%if (abolShowList[3]){%>
		<%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+15),true);
	  %>	
    <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
		<%}%>
		<%if (abolShowList[4]){%>
		<%		
		//iRemaining = (int)(dBalance/dMonthly);
		//dBalance = dBalance - (dMonthly * iRemaining);
		//if(dBalance > 3)
		//	iRemaining++;
			strTemp = (String)vRetResult.elementAt(i+14);
	  %>			
    <td align="right" class="BorderBottomLeftRight"><%=strTemp%></td>
		<%}%>
    </tr>
    <%
		strPrevEmp = (String)vRetResult.elementAt(i+8);
		}// end for loop %>
    <tr> 
      <td height="24" colspan="3" align="right" class="BorderBottomLeft">TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <%if (abolShowList[0]){%>
			<td class="BorderBottomLeft">&nbsp;</td>
      <%}%>
			<td class="BorderBottomLeft">&nbsp;</td>			
      <%if (abolShowList[1]){%>
			<td class="BorderBottomLeft">&nbsp;</td>
			<%}%>
      <td align="right" class="BorderBottomLeft">&nbsp;</td>			
			<td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalLoan,true)%>&nbsp;</td>			
      <td height="24" align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dMonthlyTotal,true)%>&nbsp;</td>
			
      <!--
			<td align="right" class="BorderBottomLeft"><%//=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</td>
			-->
			<%if (abolShowList[2]){%>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
			<%}%>
      <%if (abolShowList[3]){%>
			<td align="right" class="BorderBottomLeft">&nbsp;</td>
			<%}%>
			<%if (abolShowList[4]){%>
      <td align="right" class="BorderBottomLeftRight">&nbsp;</td>
			<%}%>
    </tr>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
%>
  <input type="hidden" name="print_page">
  <input type="hidden" name="proceed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>