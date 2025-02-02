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
<title>Print schedule with payable but no schedule</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
Table.ThinBorder{
	border-right: solid 1px #000000;  
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.NoBorder{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
 
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderTop{
  border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
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
								"Admin/staff-RETIREMENT-ENCODE_LOADNS-Create Loans","no_schedule_payable.jsp");
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
 
	
	int iSearchResult = 0;
	int i = 0;
	int iDefault = 0;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dPayable = 0d;
	
	double dGrandTotalLoan = 0d;
	double dGrandTotalPaid = 0d;
	double dGrandPayable = 0d;
	String strPrevEmp = "";
	
	boolean bolPageBreak  = false;
	int iCount = 0;
 	vRetResult = PRRetLoan.operateOnNoSchedPayable(dbOP,request, 4);
 	int iMaxRecPerPage =Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	if(vRetResult != null && vRetResult.size() > 0){
	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iPage = 1;
	String strCount = null;
	
	for (;iNumRec < vRetResult.size();iPage++){
		dTotalLoan = 0d;
		dTotalPaid = 0d;
		dPayable = 0d;
%>
<form name="form_" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>EMPLOYEES WITH OUTSTANDING <%=WI.getStrValue(strTypeName," ").toUpperCase()%> BALANCES AND NO SCHEDULE </td>
  </tr>
  <tr>
    <td>AS OF <%=WI.getTodaysDate(1)%></td>
  </tr>
  <tr>
    <td align="right">Page <%=iPage%> </td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
    
    <tr> 
      <td width="5%" height="25" align="center" class="BorderBottom"><strong><font size="1">COUNT</font></strong></td>
      <td width="32%" height="25" align="center" class="BorderBottom"><strong><font size="1">EMPLOYEE 
      NAME </font></strong></td>
      <td width="33%" align="center" class="BorderBottom"><strong><font size="1">LOAN NAME </font></strong></td>
      <td width="10%" height="25" align="center" class="BorderBottom"><strong><font size="1">TOTAL 
      LOAN </font></strong></td>
      <td width="10%" align="center" class="BorderBottom"><strong><font size="1">TOTAL PAYMENT</font></strong></td>
      <td width="10%" align="center" class="BorderBottom"><strong><font size="1">LOAN BALANCE</font></strong></td>
    </tr>
  <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20,++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
    <tr> 
		<%
				if(strPrevEmp.equals((String)vRetResult.elementAt(i+8))){
					strTemp = "";
					strCount = "";
 				}else{
					strCount = Integer.toString(iIncr);
 					strTemp = WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), 4);
					++iIncr;
 				}
		%>
      <td height="19" class="NoBorder"><div align="right"><%=strCount%>&nbsp;</div></td>
      <td height="19" class="NoBorder"><font size="1"><strong>&nbsp;&nbsp;<%=strTemp.toUpperCase()%></strong></font></td>
      <td class="NoBorder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalLoan += Double.parseDouble(strTemp);
	%>							
      <td height="19" align="right" class="NoBorder">&nbsp;<%=strTemp%>&nbsp;</td>
      <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalPaid += Double.parseDouble(strTemp);
	%>      
	    <td align="right" class="NoBorder">&nbsp;<%=strTemp%>&nbsp;</td>
	    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dPayable += Double.parseDouble(strTemp);
	%>      
	    <td align="right" class="NoBorder">&nbsp;<%=strTemp%>&nbsp;</td>
    </tr>
		
    <%
		strPrevEmp = (String)vRetResult.elementAt(i+8);
		}%>		
    <tr> 
      <td height="24" colspan="2" align="right" class="BorderTop">PAGE TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <td class="BorderTop">&nbsp;</td>
      <td height="24" align="right" class="BorderTop"><%=CommonUtil.formatFloat(dTotalLoan,true)%>&nbsp;</td>
      <td align="right" class="BorderTop"><%=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</td>
      <td align="right" class="BorderTop"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
    </tr>
		<%
		dGrandTotalLoan += dTotalLoan;
		dGrandTotalPaid += dTotalPaid;
		dGrandPayable += dPayable;
		%>
		<%if (iNumRec >= vRetResult.size()) {%>
    <tr>
      <td height="24" colspan="2" align="right" class="NoBorder">GRAND TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td height="24" align="right" class="NoBorder"><%=CommonUtil.formatFloat(dGrandTotalLoan,true)%>&nbsp;</td>
      <td align="right" class="NoBorder"><%=CommonUtil.formatFloat(dGrandTotalPaid,true)%>&nbsp;</td>
      <td align="right" class="NoBorder"><%=CommonUtil.formatFloat(dGrandPayable,true)%>&nbsp;</td>
    </tr> 
		<%}%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
}
%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>