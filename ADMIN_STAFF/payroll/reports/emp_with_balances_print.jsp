<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan,payroll.ReportPayrollExtn" %>
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
<title>Employee balances</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
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
		
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
			if(iAccessLevel == 0) {
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
			}						
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
								"Admin/staff-RETIREMENT-ENCODE_LOADNS-Create Loans","emp_with_balances.jsp");
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
	ReportPayrollExtn rptMisc = new ReportPayrollExtn(request);
	Vector vLoans = null;
	Vector vPersonalDetails = null;
	Vector vPostCharges = null;
	int iCount = 1;
	String[] astrLoanType = {"Retirement","Emergency","Institutional/Company", "SSS ", "PAG-IBIG", 
							"PERAA","GSIS"};
	
	int i = 0;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dPayable = 0d;	

	enrollment.Authentication authentication = new enrollment.Authentication();
	vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (vPersonalDetails == null || vPersonalDetails.size()==0){
		strErrMsg = authentication.getErrMsg();
		vPersonalDetails = null;
	}
		
	vLoans = PRRetLoan.getEmpLoanWithBalance(dbOP,request);		
	vPostCharges = rptMisc.getUnpaidPostCharges(dbOP);
%>
<body onLoad="window.print();">
<form name="form_">
  <%if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>  
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <%
				strTemp = (String)vPersonalDetails.elementAt(13);
				if (strTemp == null)
					strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
				else
					strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
			%>
      <td height="30"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="97%">Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%> </strong></td>
    </tr>
    <tr>
      <td height="7" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
	<%}%>
	<%if((vLoans != null && vLoans.size() > 0)
		|| (vPostCharges != null && vPostCharges.size() > 0)){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="97%" height="18">OUTSTANDING BALANCES AS OF <%=WI.getTodaysDate(1)%></td>
    </tr>
  </table>  
	<%}%>
	<%if(vLoans != null && vLoans.size() > 0){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">    
    <tr>
      <td height="20" colspan="5" valign="bottom" class="thinborder"><strong>LOANS</strong></td>
    </tr>
    <tr> 
      <td width="10%" height="25" align="center" class="thinborder"><strong><font size="1">COUNT</font></strong></td>
      <td width="45%" align="center" class="thinborder"><strong><font size="1">LOAN NAME </font></strong></td>
      <td width="15%" height="25" align="center" class="thinborder"><strong><font size="1">TOTAL 
      LOAN </font></strong></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">TOTAL PAYMENT</font></strong></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1"> BALANCE</font></strong></td>
    </tr>
    <%
	iCount = 1;
	for(i = 0; i < vLoans.size(); i+=13,iCount++){
	%>
    <tr> 
      <td height="24" align="right" class="thinborder"><%=iCount%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=astrLoanType[Integer.parseInt((String)vLoans.elementAt(i+2))]%> (<%=WI.getStrValue((String)vLoans.elementAt(i+1),"&nbsp;")%>)</td>
      <%	
		strTemp = CommonUtil.formatFloat((String)vLoans.elementAt(i+3),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalLoan += Double.parseDouble(strTemp);
	%>							
      <td height="24" align="right" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vLoans.elementAt(i+5),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalPaid += Double.parseDouble(strTemp);
	%>      
	  <td align="right" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vLoans.elementAt(i+4),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dPayable += Double.parseDouble(strTemp);
	%>      
	  <td align="right" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
      <!--
	  <td class="BorderBottomLeftRight"><div align="center"><a href="javascript:ViewDetails('<%=(String)vLoans.elementAt(i+6)%>')"><img src="../../../images/view.gif" border="0" ></a></div></td>
	  -->
    </tr>
    <%}%>
    <tr> 
      <td height="24" colspan="2" align="right" class="thinborder">TOTAL :&nbsp;&nbsp;</td>
      <td height="24" align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalLoan,true)%>&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
    </tr>
  </table>
	<%}%>
  <br>
  <%if(vPostCharges != null && vPostCharges.size() > 1){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr>
      <td height="20" colspan="3" valign="bottom" class="thinborderALL"><strong>POST CHARGES</strong></td>
      <td height="20" valign="bottom">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="10%" height="25" align="center" class="thinborder"><strong><font size="1">COUNT</font></strong></td>
      <td width="45%" align="center" class="thinborder"><strong><font size="1">POST CHARGE NAME </font></strong></td>
      <td width="15%" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong><font size="1">BALANCE</font></strong></td>
      <td width="15%" align="center">&nbsp;</td>
      <td width="15%" align="center">&nbsp;</td>
    </tr>
    <%
	iCount = 1;
	dPayable = 0d;
	for(i = 1; i < vPostCharges.size(); i+=3,iCount++){
	%>
    <tr> 
      <td height="24" align="right" class="thinborder"><%=iCount%>&nbsp;</td>
      <td class="thinborder"><%=WI.getStrValue((String)vPostCharges.elementAt(i+1),"&nbsp;")%></td>
      <%	
				strTemp = CommonUtil.formatFloat((String)vPostCharges.elementAt(i+2),true);
				strTemp = ConversionTable.replaceString(strTemp,",","");		
				dPayable += Double.parseDouble(strTemp);
			%>      
	  <td align="right" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=strTemp%>&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="24" colspan="2" align="right" class="thinborder">TOTAL :&nbsp;&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
    </tr>
  </table>
	<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>