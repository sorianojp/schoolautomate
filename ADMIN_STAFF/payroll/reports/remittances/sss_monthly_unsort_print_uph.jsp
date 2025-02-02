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
<title>SSS unsorted monthly remittance printing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">

TD.thinborder{
	border-bottom: solid 1px #000000;   
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TABLE.thinborder {
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}


.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>

<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	String strPayrollPeriod  = null;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","sss_monthly_unsort.jsp");

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
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"sss_monthly_unsort.jsp");
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

Vector vRetResult = null;
Vector vEmployerInfo = null;
PRRemittance PRRemit = new PRRemittance(request);

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
String[] astrPtFt = {"PART-TIME","FULL-TIME"};

double dTemp = 0d;
double dLineTotal = 0d;
boolean bolPageBreak = false;
int i = 0;
boolean bolShowER = WI.fillTextValue("er").length() > 0;
boolean bolShowEC = WI.fillTextValue("ec").length() > 0;
double dPageEE = 0d;
double dPageER = 0d;
double dPageEC = 0d;
double dPageTotal = 0d;

double dGrandEE = 0d;
double dGrandER = 0d;
double dGrandEC = 0d;
double dGrandTotal = 0d;

  vRetResult = PRRemit.SSSMonthlyPremium(dbOP);
	if(vRetResult != null && vRetResult.size() > 0)
		vEmployerInfo = (Vector)vRetResult.elementAt(0);
			
  if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
	
	String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
	  String strSchAddr = SchoolInformation.getAddressLine1(dbOP,false,false);
	  int iPageCount = 0;
	
	int iNumRec = 3;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = vRetResult.size()/(19*iMaxRecPerPage);	
	if(vRetResult.size() % (19*iMaxRecPerPage) > 0) ++iTotalPages;
	for (;iNumRec < vRetResult.size();iPage++){
		dPageEE = 0d;
		dPageER = 0d;
		dPageEC = 0d;
		dPageTotal = 0d;
%>

<body onLoad="javascript:window.print();">
<form name="form_">
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font size="2"><strong>        
        <%=strSchName%><br><%=strSchAddr%></strong><br><br>       
      </font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="5"><div align="center"><strong>SSS CONTRIBUTION  PREMIUM REMITTANCE<br>
            For the month of <u><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))].toUpperCase()%> <%=WI.fillTextValue("year_of")%></u></strong></div></td>
    </tr>
    <tr >
        <td height="20" colspan="5" align="right"><font size="1">Page <%=++iPageCount%> of <%=iTotalPages%></font></td>
    </tr>
  </table>  
  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">  
  <tr>
 	<td class="thinborder" width="10%" height="20" align="center">EMPLOYEE ID</td>
	<td class="thinborder" width="14%" align="center">SSS ID</td>
	<td class="thinborder" width="14%" align="center">LAST NAME</td>
	<td class="thinborder" width="16%" align="center">FIRST NAME</td>
	<td class="thinborder" width="13%" align="center">MIDDLE NAME</td>
	<td class="thinborder" width="9%" align="center">EE SHARE</td>
	<td class="thinborder" width="9%" align="center">ER SHARE</td>
	<td class="thinborder" width="9%" align="center">TOTAL</td>
	<td class="thinborder" width="6%" align="center">EC</td>
 </tr>
  
  
  
      <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=19, iCount++, iIncr++){
		i = iNumRec;
		dLineTotal = 0d;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
	
	
	
	<tr>
     <td class="thinborder" height="20"><%=(String)vRetResult.elementAt(i+3)%></td>
     <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%></td>
     <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
     <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4)).toUpperCase()%></td>
     <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5)).toUpperCase()%></td>
	 <%			
		strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = ConversionTable.replaceString(strTemp,",","");

		dTemp = Double.parseDouble(strTemp);		
		dPageEE += dTemp;
		dLineTotal += dTemp;
	%>
     <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTemp,true)%></td>
	 <%
		strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);		
		dPageER += dTemp;
		dLineTotal += dTemp;
		dGrandTotal += dLineTotal;
	%>
     <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTemp,true)%></td>
	 
     <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
	 <%	
		strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp = Double.parseDouble(strTemp);		
		dPageEC += dTemp;	
		dGrandEC += dTemp;	
	%>
     <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTemp,true)%></td>
 </tr>
	
	
	
  
	<%}%>
  	
	<%if (iNumRec >= vRetResult.size()){%>
  <tr>
     <td class="thinborder" height="20" align="right" colspan="7"><strong>GRAND TOTAL</strong> &nbsp;</td>
     <td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(dGrandTotal ,true)%></strong></td>
     <td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(dGrandEC ,true)%></strong></td>
 </tr> 
	<%}%>
</table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()%>	
<%} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>