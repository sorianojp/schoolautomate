<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Additional month pay Employee list</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PRAddlPay" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
try
	{
		dbOP = new DBOperation();
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
														"PAYROLL","DTR",request.getRemoteAddr(),
														null);
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

boolean bolShowActual = false;
boolean bolShowProj   = false;

if(WI.fillTextValue("split_report_actual").length() > 0) 
	bolShowActual = true;
else if(WI.fillTextValue("split_report_proj").length() > 0) 
	bolShowProj = true;

double dBasicTotal = 0d;
double dAdminTotal = 0d;
double dAllowanceTotal = 0d;
double dBasicSupplTotal = 0d;
double dDeminimisTotal = 0d;
double dTeachingTotal = 0d;
double dTotal = 0d;

PRAddlPay prAddl = new PRAddlPay();
Vector vRetResult = null; 
int i = 0;
int iRowCount = 0;
int iPageNo   = 1;
int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"1000000"));
vRetResult = prAddl.getAddlMonthPayReportEACSplit(dbOP,request);

String strSchName  = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddr1    = SchoolInformation.getAddressLine1(dbOP,false,false);
String strAddr2    = SchoolInformation.getAddressLine2(dbOP,false,false);
String strTitle    = WI.fillTextValue("bonus_name") + " for the Year " + WI.fillTextValue("year_of");
if(bolShowActual && bolShowProj)
	strTitle += " - ALL";
else if(bolShowActual) 
	strTitle += " - ACTUAL";
else
	strTitle += " - PROJECTION";
	
String strDateTime = WI.getTodaysDateTime();
	//System.out.println(vRetResult);
	//vRetResult = null;
if (vRetResult != null) {
	int iTotalPages = vRetResult.size()/(11*iMaxRecPerPage);				
	if(vRetResult.size()%(11*iMaxRecPerPage) > 0)
		iTotalPages++;	
				
for (i = 0; i < vRetResult.size();++iPageNo){
	if(i > 0) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center"><font size="2"><strong><%=strSchName%></strong></font><br>
	   <font size="1">
			<%=strAddr1%><br><%=strAddr2%>
			<div align="right">
				Date and Time Printed: <%=strDateTime%> &nbsp;&nbsp; &nbsp; &nbsp; Page <%=iPageNo%> of <%=iTotalPages%>
			</div>
	   </font></td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    
    <tr class="thinborder"> 
      <td height="23" colspan="10" align="center" class="thinborder"><strong><%=strTitle%></strong></td>	  
    </tr>
    <tr style="font-weight:bold" align="center">
      <td width="3%" class="thinborder" style="font-size:9px;" height="25">COUNT</td>
      <td width="7%" class="thinborder" style="font-size:9px;">EMP ID</td> 
      <td width="20%" class="thinborder" style="font-size:9px;"> NAME</td>
      <td width="10%" class="thinborder" style="font-size:9px;">Basic Sal</td>
      <td width="10%" class="thinborder" style="font-size:9px;">Admin Pay</td>
      <td width="10%" class="thinborder" style="font-size:9px;">Allowance(Confi)</td>
      <td width="10%" class="thinborder" style="font-size:9px;">Basic Suppl</td>
      <td width="10%" class="thinborder" style="font-size:9px;">De-Minimis</td>
<%if(bolShowActual){%>
      <td width="10%" class="thinborder" style="font-size:9px;">Teaching Pay</td>
<%}%>
      <td width="10%" class="thinborder" style="font-size:9px;">Total <%if(bolShowActual){%>Actual<%}else{%>Projection<%}%></td>
    </tr>
		<% 
		for(iRowCount = 1; i <vRetResult.size(); i += 11, ++iRowCount){
			if (iRowCount > iMaxRecPerPage)
				break;
				
				dBasicTotal      += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 3), ",", ""));
				dAdminTotal      += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 4), ",", ""));
				dAllowanceTotal  += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 5), ",", ""));
				dBasicSupplTotal += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 6), ",", ""));
				dDeminimisTotal  += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 7), ",", ""));
				dTeachingTotal   += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 8), ",", ""));
				dTotal           += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 10), ",", ""));
				
				
		%>		
			<tr bgcolor="#FFFFFF" class="thinborder">
			  <td class="thinborder"><%=i/11 + 1%></td>
			  <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td> 
			  <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
			  <td align="right" class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
			  <td align="right" class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
			  <td align="right" class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
			  <td align="right" class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
			  <td align="right" class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
			<%if(bolShowActual){%>
			  <td align="right" class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
			<%}%>
			  <td align="right" class="thinborder" style="font-weight:bold"><%=vRetResult.elementAt(i + 10)%></td>
		    </tr>
		<%} // end for loop%>
		<tr bgcolor="#FFFFFF" class="thinborder" style="font-weight:bold">
			  <td height="25" colspan="3" class="thinborder" align="right" style="font-size:11px;">GRAND TOTAL: </td>
			  <td align="right" class="thinborder" style="font-size:11px;"><%=CommonUtil.formatFloat(dBasicTotal, true)%></td>
			  <td align="right" class="thinborder" style="font-size:11px;"><%=CommonUtil.formatFloat(dAdminTotal, true)%></td>
			  <td align="right" class="thinborder" style="font-size:11px;"><%=CommonUtil.formatFloat(dAllowanceTotal, true)%></td>
			  <td align="right" class="thinborder" style="font-size:11px;"><%=CommonUtil.formatFloat(dBasicSupplTotal, true)%></td>
			  <td align="right" class="thinborder" style="font-size:11px;"><%=CommonUtil.formatFloat(dDeminimisTotal, true)%></td>
			  <%if(bolShowActual){%>
			  	<td align="right" class="thinborder" style="font-size:11px;"><%=CommonUtil.formatFloat(dTeachingTotal, true)%></td>
			  <%}%>
			  <td align="right" class="thinborder" style="font-size:11px;"><%=CommonUtil.formatFloat(dTotal, true)%></td>
    	</tr>
  </table>  
<%
	} //end for (i < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>

</body>
</html>
<%
dbOP.cleanUP();
%>