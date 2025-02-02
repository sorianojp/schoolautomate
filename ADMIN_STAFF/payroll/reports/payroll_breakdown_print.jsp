<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
		TD.thinborderNONE {
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 12px;
		}

    TD.thinborderBOTTOM {
			border-bottom: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			size:12px;		
    }

		TD.thinborderTop {
			border-top: solid 1px #000000;			
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 12px;
		}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
 
<body onLoad="javascript:window.print();">
<form name="form_">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
 	String strHasWeekly = null;
	int iSearchResult = 0;
	int i = 0;	
 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","payroll_breakdown.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","REPORTS",request.getRemoteAddr(),
														"payroll_breakdown.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	ReportPayrollExtn RptPayExtn = new ReportPayrollExtn(request);
	String strPayrollPeriod  = null;	
	String strTemp2 = null;
	double dSalary = 0d;
	double dPageTotal = 0d;	
	double dGrandTotal = 0d;
	boolean bolPageBreak = true;
	
	vRetResult = RptPayExtn.payrollBreakdown(dbOP);
 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
 	
	strTemp = WI.fillTextValue("sal_period_index");
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	   if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		  strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		  break;
	   }
	}

	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size())/(3*iMaxRecPerPage);	
	if((vRetResult.size() % (3*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	 	dPageTotal =0d;		

%> 
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" align="center" class="thinborderNONE"><font size="1">&nbsp; </font><strong>PAYROLL 
      DATE : <%=WI.getStrValue(strPayrollPeriod,"")%></strong></td>
     </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td align="center" class="thinborderNONE">&nbsp;</td>
      <td align="center" class="thinborderNONE">&nbsp;</td>
      <td align="center" class="thinborderNONE">&nbsp;</td>
      <td align="center" class="thinborderNONE">&nbsp;</td>
      <td align="center" class="thinborderNONE">&nbsp;</td>
    </tr>
    <tr> 
      <td width="5%" align="center" class="thinborderNONE">&nbsp;</td>
      <td width="3%" align="center" class="thinborderNONE">&nbsp;</td>
      <td width="60%" align="center" class="thinborderNONE">&nbsp; </td>
			<%
				strTemp = "Net Salary";
				if(WI.fillTextValue("show_option").equals("1"))
					strTemp = "Gross Salary";
			%>			
      <td width="28%" align="center" class="thinborderNONE"><%=strTemp%> </td>
      <td width="4%" align="center" class="thinborderNONE">&nbsp;</td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=3,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>

    <tr> 
      <td height="18" class="thinborderNONE"><div align="right"><%=iCount%></div></td>
      <td class="thinborderNONE">&nbsp;</td>
 	  <%
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i),(String)vRetResult.elementAt(i+1));
		strTemp = WI.getStrValue(strTemp);
	  %>
      <td class="thinborderNONE">&nbsp;<%=strTemp%></td>
	  <%
	  	strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+2),true);
		dPageTotal += Double.parseDouble(ConversionTable.replaceString(strTemp,",","")); 
	  %>
      <td class="thinborderNONE"><div align="right"><%=strTemp%>&nbsp;</div></td>
      <td class="thinborderNONE">&nbsp;</td>
    </tr>
	 <%  } // end for loop 
	 	dGrandTotal += dPageTotal;
 	 %>
	<tr>
	  <td height="23" class="thinborderNONE">&nbsp;</td>
	  <td class="thinborderNONE">&nbsp;</td>
	  <td align="right" class="thinborderNONE">Page Total&nbsp;</td>
	  <td align="right" class="thinborderTop"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;</td>
	  <td class="thinborderNONE">&nbsp;</td>
	</tr>
  <%if ( iNumRec >= vRetResult.size()) {%>
	<tr>
      <td height="30" class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
      <td align="right" valign="bottom" class="thinborderNONE">Grand Total </td>
      <td align="right" valign="bottom" class="thinborderNONE"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
	</tr>
	<%}%>
  </table>
  
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><div align="left"></div></td>
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