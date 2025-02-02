<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll" %>
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
<title>Increment Lists</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	
    TD.thinborderNONE {
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 9px;	
    }

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Arial,  Geneva, Helvetica, sans-serif;
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
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolPageBreak = false;
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
								"Admin/staff-Payroll-REPORTS-Payroll Summary by status","emp_period_step_inc.jsp");
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
	ReportPayroll RptPay = new ReportPayroll(request);
	double dMonthlyDiff = 0d;
	double dMonthTotal  = 0d;
	double dDaysTotal = 0d;
	double dLineTotal = 0d;
	double dHazard = 0d;
	double dLongevity = 0d;
	double dGross = 0d;
	double dLRI = 0d;
	double dNetPay = 0d;
	double dTemp = 0d;
	String[] astrMonth = {"January", "February", "March", "April", "May", "June", 
						  "July", "August", "September", "October", "November", "December"};
	String strMonthOf = WI.fillTextValue("month_of");
	vRetResult = RptPay.getPeriodStepIncrements(dbOP);
		if(vRetResult != null)
		iSearchResult = RptPay.getSearchCount();
	if (vRetResult != null) {
	
		int iPage = 1; int iCount = 0;
		boolean bolShowHeader = false;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
			

		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(26*iMaxRecPerPage);	
	    if(vRetResult.size() % iMaxRecPerPage > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	 bolShowHeader = true;

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="54"><div align="center"><font size="1"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
             GENERAL PAYROLL<br>
		      STEP INCREMENT <br>
      FOR THE PERIOD <%=astrMonth[Integer.parseInt(strMonthOf)]%> <%=WI.fillTextValue("year_of")%></font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="16" class="thinborderNONE">&nbsp;</td>
    </tr>
    <tr>
      <td height="16" class="thinborderNONE">WE HEREBY ACKNOWLEDGE to have received from <%=SchoolInformation.getSchoolName(dbOP,true,false)%> the sums therein specified opposite our respective names, being in full compensation for our services<br> 
      for the period <%=astrMonth[Integer.parseInt(strMonthOf)]%> <%=WI.fillTextValue("year_of")%>, except noted in the Remarks Column</td>
    </tr>
    <tr>
      <!--
	  <td height="25" class="thinborderBottom" >&nbsp;</td>
	  -->
      <td height="16" class="thinborderBottom"><div align="right">PAGE <%=iPage%></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
    <tr> 
	  <!--
      <td  width="7%" height="25" class="thinborder" ><div align="center"><strong>EMPLOYEE ID</strong></div></td>
	  -->
      <td width="18%" class="thinborderBottom"><div align="center"><strong>NAME</strong></div></td>
      <td width="5%" class="thinborderBottom"><div align="center"><strong>POSITION</strong></div></td>
      <td width="5%" class="thinborderBottom"><div align="center"><strong>INCREMENT DATE </strong></div></td>
      <td width="5%" class="thinborderBottom"><div align="center"><strong>OLD RATE </strong></div></td>
      <td width="5%" class="thinborderBottom"><div align="center"><strong>NEW RATE </strong></div></td>
	  <td width="5%" class="thinborderBottom"><div align="center"><strong>MONTHLY DIFF. </strong></div></td>
	  <td width="4%" class="thinborderBottom"><div align="center"><strong>NO. OF MONTH </strong></div></td>
	  <td width="4%" class="thinborderBottom"><div align="center"><strong>NO. OF DAYS </strong></div></td>
	  <td width="4%" class="thinborderBottom"><div align="center"><strong>AMT. MOS. </strong></div></td>
	  <td width="4%" class="thinborderBottom"><div align="center"><strong>AMT DAYS </strong></div></td>
	  <td width="5%" class="thinborderBottom"><div align="center"><strong>STEP INCREMENT </strong></div></td>
	  <td width="5%" class="thinborderBottom"><div align="center"><strong>25% HAZARD DIFF. </strong></div></td>
	  <td width="4%" class="thinborderBottom"><div align="center"><strong>5%/10% LONGE DIFF. </strong></div></td>
	  <td width="5%" class="thinborderBottom"><div align="center"><strong>GROSS PAY </strong></div></td>
	  <td width="4%" class="thinborderBottom"><div align="center"><strong>LESS 9% LRI </strong></div></td>
	  <td width="4%" class="thinborderBottom"><div align="center"><strong>NET PAY </strong></div></td>
	  <td width="9%" class="thinborderBottom"><div align="center"><strong>SIGNATURE</strong></div></td>
	  <td width="5%" class="thinborderBottom"><div align="center"><strong>REMARKS</strong></div></td>
	  <!--
      <td width="10%"><div align="center"><strong><font size="1">SELECT ALL</font><br>
          <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
          </strong></div></td>
	-->
    </tr>
    <% 
		for(iCount = 1; iNumRec < vRetResult.size();){
		dMonthlyDiff  = 0d;
		dMonthTotal = 0d;
		dDaysTotal  = 0d;		
		i = iNumRec;		
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
	
    <%if(bolShowHeader){
  	bolShowHeader = false;
  %>
  <tr>
    <td colspan="18" height="11"></td>
  </tr>   
  <tr>
    <td>&nbsp;</td>
    <td colspan="17">&nbsp;<strong><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"","",(String)vRetResult.elementAt(i+8))%></strong></td>
  </tr> 
  <%}%>	
  
    <% 
		for(; iNumRec<vRetResult.size(); iNumRec+=26,++iIncr, ++iCount){
		dMonthlyDiff  = 0d;
		dMonthTotal = 0d;
		dDaysTotal  = 0d;		
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
    <tr> 
      <!--
	  <td height="25" class="thinborder">&nbsp;<font size="1"><%=(String)vRetResult.elementAt(i + 3)%></font></td>
	  -->
      <td height="19" valign="bottom" class="thinborderNONE"><div align="left"><font size="1">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%></font></div></td>
      <td valign="bottom" class="thinborderNONE"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 9)%></font></td>
      <td valign="bottom" class="thinborderNONE"><div align="right"><font size="1"><%=(String)vRetResult.elementAt(i + 11)%>&nbsp;</font></div></td>
      <td valign="bottom" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 12),"&nbsp;")%>&nbsp;</font></div></td>	  
      <td valign="bottom" class="thinborderNONE"><div align="right"><font size="1"><%=(String)vRetResult.elementAt(i + 10)%>&nbsp;</font></div></td>
	  <%
	  	dTemp = 0d;
		if(vRetResult.elementAt(i + 10) != null && vRetResult.elementAt(i + 12) != null){
			strTemp = (String)vRetResult.elementAt(i + 10);
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);

			strTemp = (String)vRetResult.elementAt(i + 12);
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dMonthlyDiff = dTemp - Double.parseDouble(strTemp);			
		}
	  %>	  
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dMonthlyDiff,true)%>&nbsp;</div></td>
      <td valign="bottom" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 14),"&nbsp;")%>&nbsp;</font></div></td>
      <td valign="bottom" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 13),"&nbsp;")%>&nbsp;</font></div></td>
	  <%
			strTemp = (String)vRetResult.elementAt(i + 14);
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			dMonthTotal  = dMonthlyDiff * dTemp;
	  %>	  
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dMonthTotal,true)%>&nbsp;</div></td>
	  <%
			strTemp = (String)vRetResult.elementAt(i + 13);
 			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			dDaysTotal = dMonthlyDiff/31 * dTemp;
 	  %>	  
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dDaysTotal,true)%>&nbsp;</div></td>
	  <%
	  	dLineTotal  = dMonthTotal + dDaysTotal;
		dGross = dLineTotal;
	  %>
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</div></td>
	  <%
	  	dHazard = dLineTotal * 0.25;
		dGross += dHazard;
	  %>
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dHazard,true)%>&nbsp;</div></td>
	  <%
		strTemp = (String)vRetResult.elementAt(i + 15);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);
	  	dLongevity  = dLineTotal * dTemp;
		dGross += dLongevity;
	  %>	  
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dLongevity,true)%>&nbsp;</div></td>
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dGross,true)%>&nbsp;</div></td>
	  <%
	  	dLRI = dLineTotal * 0.09;
	  %>
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dLRI,true)%>&nbsp;</div></td>
	  <%
	  	dNetPay  = dGross - dLRI;
	  %>	  
      <td valign="bottom" class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dNetPay,true)%></div></td>
      <td class="thinborderBottom">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
    </tr>
	<%
	
		if(iNumRec + 27  <= vRetResult.size() && 
			 (!(WI.getStrValue((String) vRetResult.elementAt(iNumRec+1),"")).equals(WI.getStrValue((String) vRetResult.elementAt(iNumRec+27),"")) 
		   || !(WI.getStrValue((String) vRetResult.elementAt(iNumRec+2),"")).equals(WI.getStrValue((String) vRetResult.elementAt(iNumRec+28),"")))){
			bolShowHeader = true;
			iNumRec +=26;
			++iIncr;
			++iCount;
			break;
		}

	} // end inner for loop%>
    <%}//end of for loop to display employee information.%>	
    <tr>
	  <!--
      <td height="18">&nbsp;</td>
	  -->
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>  
  <%if (bolPageBreak){%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
  <input type="hidden" name="page_action">
  <input type="hidden" name="sal_grade">
  <input type="hidden" name="emp_index">
  <input type="hidden" name="emplist_index">
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>