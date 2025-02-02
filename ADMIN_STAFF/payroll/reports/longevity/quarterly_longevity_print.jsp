<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn" %>
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
<title>Print Longevity pay</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	
    TD.thinborderNONE {
	font-family: Verdana, Arial, Geneva, Helvetica, sans-serif;
	font-size: 9px;	
    }

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Arial, Geneva, Helvetica, sans-serif;
	font-size: 9px;
    }	
</style>


</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>

<body onLoad="javascript:window.print()">
<form name="form_">

<%  WebInterface WI = new WebInterface(request);

	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;

//add security here.
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
								"Admin/staff-Payroll-REPORTS-Payroll Summary by status","quarterly_longevity.jsp");
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

	Vector vRetResult = null;
	ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
	String strPageAction = WI.fillTextValue("page_action");
	String[] astrQuarterName = {"January - March", "April - June", "July - September", "October - December"};
	String[] astrMonth = {"January", "February", "March", "April", "May", "June", "July", 
						  "August", "September", "October", "November", "December"};
	String strQuarter = WI.fillTextValue("quarter");
	double dTotalAmt = 0d;
	double dTemp = 0d;	
	double dMonth1 = 0d;
	double dMonth2 = 0d;
	double dMonth3 = 0d;
	double dGrandTotal = 0d;
	vRetResult = RptPay.getLongevityPay(dbOP);
	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	boolean bolPageBreak  = false;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"15"));
		

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = vRetResult.size()/(11*iMaxRecPerPage);	
	if(vRetResult.size() % iMaxRecPerPage > 0) ++iTotalPages;
	
	 for (;iNumRec < vRetResult.size();iPage++){
	 iCount = 0;
%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="54"><div align="center"><font size="1"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
             GENERAL PAYROLL<br>
		      LONGEVITY PAY  <%=astrQuarterName[Integer.parseInt(strQuarter)]%> <%=WI.fillTextValue("year_of")%></font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="16" class="thinborderNONE">&nbsp;</td>
    </tr>
    <tr>
      <td height="16" class="thinborderNONE">WE HEREBY ACKNOWLEDGE to have received from <%=SchoolInformation.getSchoolName(dbOP,true,false)%> the sums therein specified opposite our respective names, being in full compensation for our services 
      for the period <%=astrQuarterName[Integer.parseInt(strQuarter)]%> <%=WI.fillTextValue("year_of")%>, except noted in the Remarks Column</td>
    </tr>
    <tr>
      <!--
	  <td height="25" class="thinborderBottom" >&nbsp;</td>
	  -->
      <td height="16" class="thinborderBottom"><div align="right"></div></td>
    </tr>
  </table>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="23%" height="25" class="thinborderBottom"><div align="center"><strong>Name</strong></div></td>
      <td width="8%" class="thinborderBottom"><div align="center"><strong>Basic Salary </strong></div></td>
      <td width="7%" class="thinborderBottom"><div align="center"><strong>ETD</strong></div></td>
      <td width="8%" class="thinborderBottom"><div align="center"><strong><%=astrMonth[Integer.parseInt(strQuarter)*3]%></strong></div></td>
      <td width="8%" class="thinborderBottom"><div align="center"><strong><%=astrMonth[Integer.parseInt(strQuarter)*3 + 1]%></strong></div></td>
      <td width="8%" class="thinborderBottom"><div align="center"><strong><%=astrMonth[Integer.parseInt(strQuarter)*3 + 2]%></strong></div></td>
      <td width="8%" class="thinborderBottom"><div align="center"><strong>TOTAL</strong></div></td>
      <td width="17%" class="thinborderBottom"><div align="center"><strong>Signature</strong></div></td>
      <td width="13%" class="thinborderBottom"><div align="center"><strong>Remarks</strong></div></td>
      <!--
      <td width="10%"><div align="center"><strong><font size="1">SELECT ALL</font><br>
          <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
          </strong></div></td>
	-->
    </tr>
    <% 
		for(; iNumRec<vRetResult.size(); iNumRec+=14,++iIncr, ++iCount){
		dTotalAmt = 0d;
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>	    
    <tr> 
      <td height="20" valign="bottom" class="thinborderNONE"><div align="left">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%></div></td>
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=(String)vRetResult.elementAt(i + 10)%>&nbsp;</div></td>
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=(String)vRetResult.elementAt(i + 9)%>&nbsp;</div></td>
	 	<% dTemp = 0d;
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 11),"0");
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			dMonth1 += dTemp;
			dTotalAmt += dTemp;
		%>	  
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=strTemp%>&nbsp;</div></td>
	 	<% dTemp = 0d;
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 12),"0");
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			dMonth2 += dTemp;
			dTotalAmt += dTemp;
		%>	  	  
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=strTemp%>&nbsp;</div></td>
	 	<% dTemp = 0d;
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 13),"0");
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			dMonth3 += dTemp;
			dTotalAmt += dTemp;
		%>	  	  
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=strTemp%>&nbsp;</div></td>
	  <%
	  	dGrandTotal += dTotalAmt;
	  %>
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dTotalAmt,true)%>&nbsp;</div></td>
      <td class="thinborderBottom">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
    </tr>
    <%}//end of for loop to display employee information.%>	
    <tr>
      <td height="30" class="thinborderNONE"><strong>&nbsp;TOTAL</strong></td>
      <td class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
      <td valign="bottom" class="thinborderNONE"><div align="right"><strong><%=CommonUtil.formatFloat(dMonth1,true)%>&nbsp;</strong></div></td>
      <td valign="bottom" class="thinborderNONE"><div align="right"><strong><%=CommonUtil.formatFloat(dMonth2,true)%>&nbsp;</strong></div></td>
      <td valign="bottom" class="thinborderNONE"><div align="right"><strong><%=CommonUtil.formatFloat(dMonth3,true)%>&nbsp;</strong></div></td>
      <td valign="bottom" class="thinborderBottom"><div align="right"><strong><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;</strong></div></td>
      <td>&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
    </tr>	
	<%for(;iCount < iMaxRecPerPage;++iCount){%>
	<tr> 
      <td height="20" valign="bottom">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom"><div align="right"></div></td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom"><div align="right"></div></td>
      <td valign="bottom">&nbsp;</td>
      <td >&nbsp;</td>
      <td>&nbsp;</td>
    </tr>	
	<%}// second loop%>
  </table>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
	    <td height="33" colspan="3" class="thinborderNONE">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="2" class="thinborderNONE">&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
	  <tr>
		<td colspan="3" class="thinborderNONE">(1) I CERTIFY on my official oath that the above Payroll is correct and that the services have been duly rendered as stated.</td>
		<td width="15%">&nbsp;</td>
		<td colspan="2" class="thinborderNONE">(3) I CERTIFY on my official oath that I have paid to each employee whose name appears in the above roll the amount set opposite his name, he having presented his Residence Certificate.</td>
		<td width="4%">&nbsp;</td>
	  </tr>
	  <tr>
	    <td height="38">&nbsp;</td>
	    <td width="24%" class="thinborderBottom">&nbsp;</td>
	    <td width="7%">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td width="25%" class="thinborderBottom">&nbsp;</td>
	    <td width="17%">&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
	  <tr>
	    <td width="8%" class="thinborderNONE">&nbsp;</td>
			<!--VICTORIA P.PEREZ for LCP-->
	    <td colspan="2" class="thinborderNONE"><%=WI.fillTextValue("personnel_div").toUpperCase()%></td>
	    <td class="thinborderNONE">&nbsp;</td>
			<!--CAROL V. MANDURIAO-->
	    <td colspan="2" class="thinborderNONE"><%=WI.fillTextValue("cash_div").toUpperCase()%></td>
	    <td class="thinborderNONE">&nbsp;</td>
    </tr>
	  <tr>
	    <td class="thinborderNONE">&nbsp;</td>
	    <td colspan="2" class="thinborderNONE">Chief, Personnel Division</td>
	    <td class="thinborderNONE">&nbsp;</td>
	    <td colspan="2" class="thinborderNONE">Chief, Cash Division</td>
	    <td class="thinborderNONE">&nbsp;</td>
    </tr>
	  <tr>
	    <td height="28" colspan="3" class="thinborderNONE">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="2" class="thinborderNONE">&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
	  <tr>
	    <td colspan="3" class="thinborderNONE">(2) APPROVED, payable from appropriation for PERSONAL SERVICES.</td>
	    <td>&nbsp;</td>
	    <td colspan="2" class="thinborderNONE">&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
	  <tr>
	    <td height="33" class="thinborderNONE">&nbsp;</td>
	    <td class="thinborderBottom">&nbsp;</td>
	    <td class="thinborderNONE">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="2" class="thinborderNONE">&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
	  <tr>
	    <td class="thinborderNONE">&nbsp;</td>
			<!--JUANITO A. RUBIO, MD, MHA, CESO II-->
	    <td colspan="2" class="thinborderNONE"><%=WI.fillTextValue("director").toUpperCase()%></td>
	    <td>&nbsp;</td>
	    <td colspan="2" class="thinborderNONE">&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
	  <tr>
	    <td class="thinborderNONE">&nbsp;</td>
	    <td colspan="2" class="thinborderNONE">Executive Director</td>
	    <td>&nbsp;</td>
	    <td colspan="2" class="thinborderNONE">&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
  </table>

    <%if (bolPageBreak){%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>