<%@ page language="java" import="utility.*,payroll.PRTaxReport,hr.HRInfoPersonalExtn,
								java.util.Vector" buffer="16kb"%>
<%
boolean bolHasConfidential = false;
String[] strColorScheme = CommonUtil.getColorScheme(6);
WebInterface WI = new WebInterface(request);
//strColorScheme is never null. it has value always.
%>								
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Report Schedule 7.2</title>
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
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
	}	
	
	TD.headerWithBorderRight {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
	
	TD.headerWithBorder {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
	
  TD.header {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }

  TD.headerNoBorder {
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
		
  TD.thinborderTOP {
    border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }
	
  TD.NoBorder {
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }	
	
  TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }
	
  TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }	
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script> 

<body bgcolor="#FFFFFF" onLoad="jjavascript:window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;	

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
								"Admin/staff-Payroll-REPORTS-Tax Schedule7.2","report_schedule72.jsp");
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
	Vector vRetResult  = null;
	int iDefault  = 0;
	int i = 0;
	double dTemp = 0d;
	int iIndexOf = 0;
	int iMainIncr = 1;
	boolean bolPageBreak  = false;
	Vector vExemptCodes = new Vector();
	double dTempVal = 0d;
	double[] adGrandTotal = new double[16];
	
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

	vRetResult = rptLedger.generateSchedule71(dbOP, request, 2);
	if (vRetResult != null) {	
		int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_stud_page"),"20"));
		int iTotalPages = (vRetResult.size())/(58*iMaxRecPerPage);	
		int iNumRec = 0;//System.out.println(vRetResult);
		int iMainTemp = 0;
	
		if((vRetResult.size() % (58*iMaxRecPerPage)) > 0) 
			 ++iTotalPages;

	  for (;iNumRec < vRetResult.size();iPage++){
			 iMainTemp = iNumRec;
%>

<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr > 
      <td height="25" colspan="2"><div align="center"><font color="#000000" size="1" ><strong>ALPHALIST OF EMPLOYEES WHOSE COMPENSATION INCOME ARE EXEMPT FROM WITHHOLDING TAX BUT SUBJECT TO INCOME TAX <br>
          (Reported Under Form 2316)</strong></font></div></td>
    </tr>
  </table>
   <table bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="3%" rowspan="3" align="center" class="headerWithBorder">SEQ<br>
NO</td>
      <td width="7%" rowspan="3" align="center" class="headerWithBorder">TIN</td>
      <td height="14" colspan="3" align="center" class="headerWithBorder">NAME OF EMPLOYEES</td>
      <td colspan="8" align="center" class="headerWithBorder">GROSS COMPENSATION INCOME</td>
      <td colspan="2" rowspan="2" align="center" class="headerWithBorder">EXEMPTION</td>
      <td width="6%" rowspan="3" align="center" class="headerWithBorder">Premium Paid on Health and/or Hospital Insurance </td>
      <td width="6%" rowspan="3" align="center" class="headerWithBorder">Net Taxable Compensation Income</td>
      <td width="6%" rowspan="3" align="center" class="headerWithBorder">Tax 
      Due </td>
      <%if(WI.fillTextValue("BIR_format").length() == 0){%>
			<td align="center" class="headerWithBorder">&nbsp;</td>
      <td colspan="2" align="center" class="headerWithBorder">&nbsp;</td>
      <td align="center" class="headerWithBorder">&nbsp;</td>
			<%}%>
    </tr>
    <tr> 
      <td width="6%" rowspan="2" align="center" class="headerWithBorder">Last Name</td>
      <td width="6%" rowspan="2" align="center" class="headerWithBorder"><font size="1">First Name</font></td>
      <td width="6%" rowspan="2" align="center" class="headerWithBorder">Middle Name</td>
      <td width="6%" rowspan="2" align="center" class="headerWithBorder">Gross Compensation Income</td>
      <td height="14" colspan="4" align="center" class="headerWithBorder">  NON - TAXABLE </td>
      <td width="6%" rowspan="2" align="center" class="headerWithBorder">Total Non-Taxable/Exempt Compensation Income </td>
      <td colspan="2" align="center" class="headerWithBorder">  TAXABLE </td>
      <%if(WI.fillTextValue("BIR_format").length() == 0){%>
			<td align="center" class="headerWithBorder">&nbsp;</td>
      <td colspan="2" align="center" class="headerWithBorder">Year-end Adjustment</td>
      <td align="center" class="headerWithBorder">&nbsp;</td>
			<%}%>
    </tr>
    <tr>
      <td width="6%" height="14" align="center" class="headerWithBorder" >13th 
        Month Pay &amp; Other Benefits</td>
      <td width="6%" align="center" class="headerWithBorder" >De Minimis Benefits </td>
      <td width="6%" align="center" class="headerWithBorder" >SSS, 
        GSIS, PHIC,Pag-Ibig Contributions and Union Dues</td>
      <td width="6%" align="center" class="headerWithBorder" >Salaries 
        &amp; Other Forms of Compensation</td>
      <td width="6%" align="center" class="headerWithBorder" >Basic Salary </td>
      <td width="6%" align="center" class="headerWithBorder" >Salaries &amp; Other Forms of Compensation </td>
      <td width="4%" align="center" class="headerWithBorder" >Code</td>
      <td width="6%" align="center" class="headerWithBorder" >Amount</td>
			<%if(WI.fillTextValue("BIR_format").length() == 0){%>
      <td width="6%" align="center" class="headerWithBorder" >Tax 
        Witheld (Jan-Nov)</td>
      <td width="6%" align="center" class="headerWithBorder" >Tax 
        Witheld (Dec)</td>
      <td width="6%" align="center" class="headerWithBorder" >Tax 
        Refund to Employees</td>
      <td width="6%" align="center" class="headerWithBorder" >Amount 
        of Tax Withheld as Adjusted</td>
				<%}%>
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
      <td align="right" class="thinborder"><%=iMainIncr%>&nbsp;</td> 
      <td height="14" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+10), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[0] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+27), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[1] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+28), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[2] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+29), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[3] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
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
				adGrandTotal[4] += dTemp;
			%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTemp, true)%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+11), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[5] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+31), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[6] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+57), "0.00"), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[7] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+48);
 				iIndexOf = vExemptCodes.indexOf(strTemp);
				if(iIndexOf != -1){
					strTemp = (String) vExemptCodes.elementAt(iIndexOf+1);
				}else{
					strTemp = "n/a";
				}
			%>
      <td height="14" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+15), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[8] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+16), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[9] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+17), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[10] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+18), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[11] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%if(WI.fillTextValue("BIR_format").length() == 0){%>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+46), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));

				dTemp = dTempVal;
				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[12] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+47), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));

				dTemp += dTempVal;
				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[13] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+49), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));

				dTemp -= dTempVal;
				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[14] += dTempVal;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				adGrandTotal[15] += dTemp;
			%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTemp, true)%></td>
			<%}%>
    </tr>
		<%}%>
		<%if ( iNumRec >= vRetResult.size()) {%>
    <tr>
      <td align="right" class="thinborder">&nbsp;</td>
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[0], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[1], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[2], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[3], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[4], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[5], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[6], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[7], true)%></td>
      <td height="25" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[8], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[9], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[10], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[11], true)%></td>
			<%if(WI.fillTextValue("BIR_format").length() == 0){%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[12], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[13], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[14], true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[15], true)%></td>
			<%}%>
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