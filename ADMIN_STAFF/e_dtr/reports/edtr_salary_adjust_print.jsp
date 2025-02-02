<%@ page language="java" import="utility.*, java.util.Vector, eDTR.ReportEDTRExtn, eDTR.TimeInTimeOut, 
																					java.util.Calendar, payroll.PReDTRME"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summary of Adjustments for payroll</title>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="Javascript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Report - Employees with Adjustments",
								"emp_dtr_adjustments.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"dtr_view.jsp");	
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

ReportEDTRExtn RptExtn = new ReportEDTRExtn(request);
TimeInTimeOut tRec = new TimeInTimeOut();
PReDTRME prEdtrME = new PReDTRME();
Vector vSalaryPeriod = null;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
strTemp = WI.fillTextValue("info_index");

String strDateFr = null;
String strDateTo = null;
Calendar calendar = Calendar.getInstance();
String strMonths = WI.fillTextValue("strMonth");
String strYear = WI.fillTextValue("sy_");
int iMonth = 0;
int i = 0;
int iJumpTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("jumpto"),"1"));
boolean bolPageBreak = false;
double dAmountDiff = 0d;
double dDeducted = 0d;

if(strMonths.length() == 0)
	strMonths = Integer.toString(calendar.get(Calendar.MONTH) + 1);
if(strYear.length() == 0)
	strYear = Integer.toString(calendar.get(Calendar.YEAR));

iMonth = Integer.parseInt(strMonths);

int iAction = Integer.parseInt(WI.getStrValue(strTemp,"0"));
String strPayrollPeriod = null;
	vSalaryPeriod = prEdtrME.getSalaryPeriods(dbOP, request, Integer.toString(iMonth-1), strYear);
	strTemp = WI.fillTextValue("sal_period_index");
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 1) +" - "+(String)vSalaryPeriod.elementAt(i + 2);
	  }//end of if condition.		  
	}//end of for loop.

	vRetResult = RptExtn.operateOnSalAdjustments(dbOP);
	if (vRetResult != null) {
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iTotalPages = vRetResult.size()/(14*iMaxRecPerPage);				
		int iIncr    = 1;
		int iPageNo = 1;
		if(vRetResult.size()%(14*iMaxRecPerPage) > 0)
			iTotalPages++;		
		for (;iNumRec < vRetResult.size();iPageNo++){
%>
<form name="form_">
  <table width="100%" border="0" cellpadding="1" cellspacing="0" class="thinborder">
			<tr> 
				<td height="25" colspan="9" align="center" class="thinborder">
				<strong>LIST OF EMPLOYEE DEDUCTIONS (<%=strPayrollPeriod%>)</strong>
				</td>
			</tr>
			<tr>
			  <td width="11%" align="center" class="thinborder"><strong><font size="1">EMP ID</font></strong></td> 
				<td width="28%" height="25" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
				<td width="9%" align="center" class="thinborder"><font size="1"><strong>DEDUCTED<br>
			  AWOL</strong></font></td>
				<td width="9%" align="center" class="thinborder"><font size="1"><strong>AWOL<br>
TO DEDUCT </strong></font></td>
				<td width="9%" align="center" class="thinborder"><font size="1"><strong> DIFFERENCE</strong></font></td>
				<td width="9%" align="center" class="thinborder"><font size="1"><strong><font size="1"><strong><font size="1"><strong>DEDUCTED<br>
LATE/UT</strong></font></strong></font></strong></font></td>
				<td width="9%" align="center" class="thinborder"><font size="1"><strong>LATE/UT<br>
TO DEDUCT</strong></font></td>
				<td width="9%" align="center" class="thinborder"><font size="1"><strong> DIFFERENCE </strong></font></td>
     </tr>
		<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=14,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
		%>
		 <tr>
		 	 <input type="hidden" name="id_number_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
		   <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
			<td height="20" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 4)%></td> 
			<%
				strTemp = (String)vRetResult.elementAt(i+8);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				dDeducted = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>            
			<%
				strTemp = (String)vRetResult.elementAt(i+12);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				dAmountDiff = dDeducted - Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat(dAmountDiff, true);
				if(dAmountDiff == 0d)
					strTemp = "";
			%>			
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+9);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				dDeducted = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+10);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				dAmountDiff = dDeducted - Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat(dAmountDiff, true);
				if(dAmountDiff == 0d)
					strTemp = "";
			%>			
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
	  </tr>	
		<%}%>
	</table>
<%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>	
</form>
</body>
</html>
<% dbOP.cleanUP(); %>