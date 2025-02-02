<%@ page language="java" import="utility.*,payroll.PRTaxReport,hr.HRInfoPersonalExtn,
								java.util.Vector" buffer="16kb"%>
<%
boolean bolHasConfidential = false;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Report Schedule 7.3</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
td{
	font-size:9px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script> 
<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
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
								"Admin/staff-Payroll-REPORTS-Tax Schedule7.1","report_schedule71.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");								
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

	PRTaxReport rptLedger = new PRTaxReport();	
	int iColsSpan = 0;
	int iDefault  = 0;
	double dTemp = 0d;
	Vector vRetResult  = null;
	Vector vEmpTaxCodes = null;
	Vector vExemptCodes = new Vector();
	int iIndexOf = 0;
	vExemptCodes.addElement("0");	vExemptCodes.addElement("Z");
	vExemptCodes.addElement("1");	vExemptCodes.addElement("S");
	vExemptCodes.addElement("2");	vExemptCodes.addElement("HF");
	vExemptCodes.addElement("21"); vExemptCodes.addElement("HF1");
	vExemptCodes.addElement("22"); vExemptCodes.addElement("HF2");
	vExemptCodes.addElement("23"); vExemptCodes.addElement("HF3");
	vExemptCodes.addElement("24"); vExemptCodes.addElement("HF4");			
	vExemptCodes.addElement("3");	vExemptCodes.addElement("ME");
	vExemptCodes.addElement("31"); vExemptCodes.addElement("ME1");
	vExemptCodes.addElement("32"); vExemptCodes.addElement("ME2");
	vExemptCodes.addElement("33"); vExemptCodes.addElement("ME3");
	vExemptCodes.addElement("34"); vExemptCodes.addElement("ME4");	
	int iMainTemp = 0;
	boolean bolPageBreak = false;
	int i = 0;
	int iMainIncr = 0; 
	
	double dTempVal = 0d;
	double[] adGrandTotal = new double[18];
	
 	vRetResult = rptLedger.generateSchedule71(dbOP, request, 3);
	if (vRetResult != null) {	
		int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_stud_page"),"20"));
		int iTotalPages = (vRetResult.size())/(58*iMaxRecPerPage);	
		int iNumRec = 0;//System.out.println(vRetResult);
	
		if((vRetResult.size() % (58*iMaxRecPerPage)) > 0) 
			 ++iTotalPages;
		iMainIncr = 0; 
	  for (;iNumRec < vRetResult.size();iPage++){
			 iMainTemp = iNumRec;
%>

<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="2" align="center"><font color="#000000" size="1" ><strong>Schedule 
          7.3 Alphalist of Employees as of December 31 with no Previous Employers 
      (Reported under Form 2316)</strong></font></td>
    </tr>
    <tr >
      <td height="16" colspan="2" align="center"><font size="1">From Whom 
      Taxes Have Been Withheld for the Taxable Year</font></td>
    </tr>
  </table>
   <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" rowspan="3" align="center">SEQ<br>
      NO</td>
      <td width="3%" rowspan="3" align="center">TIN</td>
      <td height="14" colspan="3" align="center">NAME OF EMPLOYEES </td>
      <td colspan="10" align="center">GROSS COMPENSATION INCOME </td>
    </tr>
    <tr> 
      <td width="6%" rowspan="2" align="center">Last Name</td>
      <td width="6%" rowspan="2" align="center">First Name</td>
      <td width="6%" rowspan="2" align="center">Middle Name</td>
      <td width="6%" rowspan="2" align="center">Gross Compensation Income</td>
      <td height="14" colspan="5" align="center"> NON - TAXABLE</td>
      <td colspan="4" align="center"> TAXABLE</td>
    </tr>
    <tr>
      <td width="5%" height="14" align="center" >13th Month &amp; Other 
          Benefits</td>
      <td width="5%" align="center" >De Minimis Benefits </td>
      <td width="9%" align="center" >SSS, GSIS, PHIC &amp;<br>
        Pag-Ibig Contributions<br>
      and Union Dues</td>
      <td width="8%" align="center" >Salaries &amp; Other Forms of Compensation</td>
      <td width="7%" align="center">Total Non-Taxable Compensation Income</td>
      <td width="4%" align="center" >Basic Salary </td>
      <td width="5%" align="center" >13th Month &amp; Other 
          Benefits</td>
      <td width="9%" align="center" >Salaries  &amp; Other Forms of Compensation </td>
      <td width="9%" align="center" >Total Taxable Compensation Income</td>
    </tr>
<% 
		for(iCount = 1;iMainTemp < vRetResult.size(); iMainTemp += 58, ++iCount){
		i = iMainTemp;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>	
    <tr>
      <td><%=(iMainIncr+iCount)%></td> 
      <td height="20" nowrap><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+10), true)%></td>
      <td align="right"><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+27),"&nbsp;"),true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+28),"&nbsp;"),true)%></td>
      <td align="right"><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+29),"&nbsp;"),true)%>&nbsp;</td>
			<%
				dTemp = Double.parseDouble((String)vRetResult.elementAt(i+22));
				strTemp = (String)vRetResult.elementAt(i+23);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+24);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+25);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+26);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+30);
				dTemp += Double.parseDouble(strTemp);
			%>
      <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;"),true)%></td>
      <td align="right"><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+31),"&nbsp;"),true)%></td>
      <td align="right"><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+41),"&nbsp;"),true)%></td>
      <td align="right"><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+34),"&nbsp;"),true)%></td>
      <td align="right"><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+12),"&nbsp;"),true)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="20" nowrap>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
    </tr>
    <%}%>
  </table>
	<%if (bolPageBreak || iMainTemp == vRetResult.size()){%>
  <DIV style="page-break-before:always">&nbsp;</Div>
  <% }//page break ony if it is not last page.%> 	
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr > 
      <td height="25" colspan="2" align="center"><font color="#000000" size="1" ><strong>Schedule 
          7.3 Alphalist of Employees as of December 31 with no Previous Employers 
      (Reported under Form 2316)</strong></font></td>
    </tr>
    <tr >
      <td height="16" colspan="2" align="center"><font size="1">From Whom 
      Taxes Have Been Withheld for the Taxable Year</font></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="2%" rowspan="2" align="center">SEQ<br>
      NO</td> 
      <td height="7" colspan="2" align="center"><font size="1">EXEMPTION</font></td>
      <td width="11%" rowspan="2" align="center"><font size="1">Premium Paid on Health and/or Hospital Insurance</font></td>
      <td width="11%" rowspan="2" align="center"><font size="1">Net Taxable Compensation Income </font></td>
      <td width="10%" rowspan="2" align="center"><font size="1">Tax Due<br>
        (JAN. - DEC.)
</font></td>
      <td width="10%" rowspan="2" align="center" ><font size="1">TAX WITHHELD<br>
        (JAN. - NOV.)
</font></td>
      <td colspan="2" align="center" ><font size="1">YEAR - END ADJUSTMENT</font></td>
      <td width="11%" rowspan="2" align="center" ><font size="1">Amount of Tax Withheld as Adjusted</font></td>
      <td width="5%" rowspan="2" align="center" >&nbsp;</td>
    </tr>
    <tr>
      <td width="10%" height="7" align="center"><font size="1">Code</font></td>
      <td width="10%" align="center" ><font size="1">Amount</font></td>
      <td width="10%" align="center" ><font size="1">Amount withheld and paid for in December </font></td>
      <td width="10%" align="center" ><font size="1">Tax Refund to Employees</font></td>
    </tr>
		<% 
		for(iCount = 1;iNumRec < vRetResult.size();iNumRec += 58, ++iCount, iMainIncr++){
		i = iNumRec;
 		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		} else 
			bolPageBreak = false;			
	  %>
    <tr>
      <td><%=iMainIncr+1%></td> 
			<%
				strTemp = (String)vRetResult.elementAt(i+48);
				iIndexOf = vExemptCodes.indexOf(strTemp);
				if(iIndexOf != -1){
					strTemp = (String) vExemptCodes.elementAt(iIndexOf+1);
				}else{
					strTemp = "n/a";
				}
			%>
      <td height="14">&nbsp;<%=WI.getStrValue(strTemp)%></td>
      <td align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+15), true)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+16);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+17);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>			
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+18);				
			%>
      <td align="right"><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+46);
				dTemp = Double.parseDouble(strTemp);			
			%>	
      <td align="right"><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+47);
				dTemp += Double.parseDouble(strTemp);
			%>
      <td align="right"><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+49);
				dTemp -= Double.parseDouble(strTemp);
			%>
      <td align="right"><%=CommonUtil.formatFloat(strTemp, true)%></td>
			
      <td align="right"><%=CommonUtil.formatFloat(dTemp, true)%></td>
      <td align="right">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="14">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
    </tr>
    <%}%>
  </table>	

	<%if (iNumRec < vRetResult.size()){%>
  <DIV style="page-break-before:always">&nbsp;</Div>
  <% }//page break ony if it is not last page.
	  } //end for (iNumRec < vRetResult.size()
  } //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>