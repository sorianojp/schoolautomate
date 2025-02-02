<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn" %>
<%
///added code for HR/companies.
WebInterface WI = new WebInterface(request);
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
boolean bolHasTeam = false;
boolean bolRemoveOtherEarnings = true;

	DBOperation dbOP = null;	
	String strErrMsg = null;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Non Taxable Income (Yearly)","year_non_tax_income.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"year_non_tax_income_print_eac.jsp");
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
	ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
	Vector vRetResult = RptPay.generateYearNonTaxableEAC(dbOP);
	
	if( vRetResult == null || vRetResult.size() == 0)
		strErrMsg = RptPay.getErrMsg();
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TD.BOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMTOPLEFTRIGHT {
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMTOPLEFT {
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMTOPLEFT {
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.BOTTOMRIGHT {
	border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
</style>
</head>
<body onLoad="window.print()">
<%if(strErrMsg != null) {%>
	<p style="font-size:18px; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif"><%=strErrMsg%></p>
<%}if(vRetResult != null && vRetResult.size() > 0) {
Vector vSummary = (Vector)vRetResult.remove(0);
int iRowsPerPage = Integer.parseInt(WI.fillTextValue("num_rec_page"));
int iCount = 0;
int iPageCount = 1;

String strDateTime   = WI.getTodaysDateTime();
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddress    = SchoolInformation.getAddressLine1(dbOP,false,false);

String strReportTitle = "For Month ";
String strastrConvertMonth[] = {"January","Febrary","March","April","May","June","July","August","September","October","November","December"};
if(WI.fillTextValue("month_to").length() > 0 && !WI.fillTextValue("month_to").equals(WI.fillTextValue("month_fr"))) {
	strReportTitle += strastrConvertMonth[Integer.parseInt(WI.fillTextValue("month_fr"))]+" - "+
					strastrConvertMonth[Integer.parseInt(WI.fillTextValue("month_to"))];
}
else 
	strReportTitle += " of "+strastrConvertMonth[Integer.parseInt(WI.fillTextValue("month_fr"))];
strReportTitle +=" "+ WI.fillTextValue("year_of");

for(int i = 0; i < vRetResult.size();) {
	if(i > 0) {%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
	<%}
	iCount = 0;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">  	
  	<tr>      
      <td height="10" align="center"><strong><font size="3"><%=strSchoolName%></font></strong> <br />
	  <font size ="1"><%=strAddress%></font>
	  </td>
    </tr>  
		<tr> 
			<td height="30" align="center"><strong><font>NON-TAXABLE INCOME REPORT 
			<br>
			<%=strReportTitle%></font></strong></td>
		</tr>
  </table>
  <table width="100%" cellpadding="0" cellspacing="0">
		 <tr>
		  <td width="50%" style="font-size:9px;">Page No: <%=iPageCount++%></td>
		  <td width="50%" align="right" style="font-size:9px;">Date and time printed : <%=strDateTime%></td>
		</tr>
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="thinborder">  
    	<tr align="center" style="font-weight:bold">      
     		<td height="22" colspan="4" class="BOTTOM" >&nbsp;</td>
			<td class="BOTTOMTOPLEFT"  align="center">A</td> 
			<td class="BOTTOMTOPLEFT" >B</td> 
			<td class="BOTTOMTOPLEFT" >C</td>
			<td class="BOTTOMTOPLEFT" >D</td> 
			<td class="BOTTOMTOPLEFT" >E</td>
			<td class="BOTTOMTOPLEFT" >F</td> 
			<td class="BOTTOMTOPLEFT" >G</td> 
			<td class="BOTTOMTOPLEFT" >H</td>
			<td class="BOTTOMTOPLEFT" >I</td> 
			<td class="BOTTOMTOPLEFTRIGHT" >J</td> 
 		</tr>
		<tr align="center" style="font-weight:bold">      
     		<td width="5%" height="22" class="BOTTOMLEFT" >ID No.</td>
	 		<td width="12%" class="BOTTOMLEFT" >LAST NAME</td>
	 		<td width="13%" class="BOTTOMLEFT" >FIRST NAME</td>
			<td width="10%" class="BOTTOMLEFT" >TAX STATUS</td>
			<td width="6%" class="BOTTOMLEFT" >SUM OF BASIC SALARY</td> 
			<td width="6%" class="BOTTOMLEFT" >SUM OF MISC AMOUNT</td> 
			<td width="6%" class="BOTTOMLEFT" >SUM OF OVERTIME</td>
			<td width="6%" class="BOTTOMLEFT" >SUM OF OTHER TX INCOME</td> 
			<td width="6%" class="BOTTOMLEFT" >SUM OF GROSS INCOME</td>			
			<td width="6%" class="BOTTOMLEFT" >SUM OF WITHOLDING TAX</td> 
			<td width="6%" class="BOTTOMLEFT" >SUM OF EMPLOYEE SSS PREMIUM</td>
			<td width="6%" class="BOTTOMLEFT" >SUM OF EMPLOYEE PHIC PREMIUM</td> 
			<td width="6%" class="BOTTOMLEFT" >SUM OF EMPLOYEE HDMF PREMIUM</td>
			<td width="6%" class="BOTTOMLEFTRIGHT" >SUM OF OTHER NTX INCOME</td>  
 		</tr>
	<%for(; i < vRetResult.size(); i += 17, ++iCount){
		if(iCount >=iRowsPerPage)
			break;
	%>
			<tr align="right">
			  <td height="22" class="BOTTOMLEFT" align="left"><%//=i/17%><%=vRetResult.elementAt(i + 1)%></td>
			  <td class="BOTTOMLEFT" align="left"><%=vRetResult.elementAt(i + 4)%></td>
			  <td class="BOTTOMLEFT" align="left"><%=vRetResult.elementAt(i + 2)%></td>
			  <td class="BOTTOMLEFT" align="left"><%=vRetResult.elementAt(i + 5)%></td>
			  <td class="BOTTOMLEFT" ><%=vRetResult.elementAt(i + 6)%></td>
			  <td class="BOTTOMLEFT" ><%=vRetResult.elementAt(i + 7)%></td>
			  <td class="BOTTOMLEFT" ><%=vRetResult.elementAt(i + 8)%></td>
			  <td class="BOTTOMLEFT" ><%=vRetResult.elementAt(i + 9)%></td>
			  <td class="BOTTOMLEFT" ><%=vRetResult.elementAt(i + 16)%></td>
			  <td class="BOTTOMLEFT" ><%=vRetResult.elementAt(i + 11)%></td>
			  <td class="BOTTOMLEFT" ><%=vRetResult.elementAt(i + 12)%></td>
			  <td class="BOTTOMLEFT" ><%=vRetResult.elementAt(i + 13)%></td>
			  <td class="BOTTOMLEFT" ><%=vRetResult.elementAt(i + 14)%></td>
			  <td class="BOTTOMLEFTRIGHT" ><%=vRetResult.elementAt(i + 15)%></td>
		  </tr>
		  <%if(i + 17 >= vRetResult.size()) {%>
  		<tr align="right" style="font-weight:bold">
		  <td height="22" colspan="4" class="BOTTOMLEFT" >GRAND TOTAL: &nbsp;&nbsp;</td>
		  <td class="BOTTOMLEFT" ><%=vSummary.elementAt(0)%></td>
		  <td class="BOTTOMLEFT" ><%=vSummary.elementAt(1)%></td>
		  <td class="BOTTOMLEFT" ><%=vSummary.elementAt(2)%></td>
		  <td class="BOTTOMLEFT" ><%=vSummary.elementAt(3)%></td>
		  <td class="BOTTOMLEFT" ><%=vSummary.elementAt(10)%></td>
		  <td class="BOTTOMLEFT" ><%=vSummary.elementAt(5)%></td>
		  <td class="BOTTOMLEFT" ><%=vSummary.elementAt(6)%></td>
		  <td class="BOTTOMLEFT" ><%=vSummary.elementAt(7)%></td>
		  <td class="BOTTOMLEFT" ><%=vSummary.elementAt(8)%></td>
		  <td class="BOTTOMLEFTRIGHT" ><span class="BOTTOMLEFT"><%=vSummary.elementAt(9)%></span></td>
	  </tr>
		  <%}%>
	  <%}%>
	</table>
<%}

}%>
</body>
</html>
<%
dbOP.cleanUP();
%>