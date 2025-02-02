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
<title>Print Employee Loan balances</title>
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
	boolean bolMyHome = false;	
	String strEmpID = null;
//add security here.
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;
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
	strEmpID = (String)request.getSession(false).getAttribute("userId");
	if (strEmpID != null ){
		if(bolMyHome){
			iAccessLevel  = 2;
			request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
		}
	}

	strEmpID = WI.fillTextValue("emp_id");
	if(strEmpID.length() == 0)
		strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
	strEmpID = WI.getStrValue(strEmpID, "");

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
								"Admin/staff-RETIREMENT-ENCODE_LOADNS-Create Loans","emp_loans_balance_print.jsp");
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
	String strLoanType = null;
	String strCodeIndex = null;
	String[] astrLoanType = {"Regular Retirement Loan","Emergency Loan","Institutional/Company Loan", "SSS Loan", "PAG-IBIG Loan", 
							"PERAA Loan","GSIS Loan"};
	String strTypeName = null;	
	
	String[] astrSortByName    = {"Lastname","Loan Name"};
	String[] astrSortByVal     = {"lname","loan_name"};
	
	int iSearchResult = 0;
	int i = 0;
	int iDefault = 0;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dPayable = 0d;


	enrollment.Authentication authentication = new enrollment.Authentication();
	vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (vPersonalDetails == null || vPersonalDetails.size()==0){
		strErrMsg = authentication.getErrMsg();
		vPersonalDetails = null;
	}	
	vRetResult = PRRetLoan.getEmpLoanWithBalance(dbOP,request);		
	if(vRetResult == null)
		strErrMsg = PRRetLoan.getErrMsg();		
	else{
	iSearchResult = PRRetLoan.getSearchCount();
	}

%>
<body onLoad="javascript:window.print();">
<form name="form_" method="post" action="emp_loans_balance_print.jsp">
  <%if(vRetResult != null && vRetResult.size() > 0){%>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%">&nbsp;</td> 
      <td width="97%" height="27">OUTSTANDING BALANCES of <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 1).toUpperCase()%></strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td> 
      <td height="27"> AS OF <%=WI.getTodaysDate(1)%></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="15" colspan="6" class="BorderBottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="9%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">COUNT</font></strong></td>
      <td width="40%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN NAME </font></strong></td>
      <td width="17%" align="center" class="BorderBottomLeft"><strong><font size="1">REF NO </font></strong></td>
      <td width="17%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">LOANED AMOUNT </font></strong></td>
      <td width="17%" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL PAYMENT</font></strong></td>
      <td width="17%" align="center" class="BorderBottomLeftRight"><strong><font size="1">LOAN BALANCE</font></strong></td>
    </tr>
    <%
	int iCount = 1;
	for(i = 0; i < vRetResult.size(); i+=13,iCount++){
	%>
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=iCount%>&nbsp;</td>
      <td class="BorderBottomLeft"><%=astrLoanType[Integer.parseInt((String)vRetResult.elementAt(i+2))]%>&nbsp;(<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%>)</td>
      <td class="BorderBottomLeft"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
      <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalLoan += Double.parseDouble(strTemp);
	%>							
      <td height="24" align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalPaid += Double.parseDouble(strTemp);
	%>      
	  <td align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dPayable += Double.parseDouble(strTemp);
	%>      
	  <td align="right" class="BorderBottomLeftRight">&nbsp;<%=strTemp%>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="24" colspan="2" class="BorderBottomLeft">TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <td class="BorderBottomLeft">&nbsp;</td>
      <td height="24" align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalLoan,true)%>&nbsp;</td>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</td>
      <td align="right" class="BorderBottomLeftRight"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
    </tr>
  </table>
  <%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>