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
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5" align="center"><font size="2"><strong>
        <%if(vEmployerInfo != null){
					strTemp = (String) vEmployerInfo.elementAt(12);
					strTemp += "<br>" + (String) vEmployerInfo.elementAt(3) + "<br>";
				%>
        <%=strTemp%><br>

        <%}else{%>
        <%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%}%>
      </font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><hr size="1" color="#000000"></td>
  </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="7"><div align="center"><strong>SSS Premiums - <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
		<%if(bolShowER){%>
    <td>&nbsp;</td>
		<%}%>
		<%if(bolShowEC){%>
    <td>&nbsp;</td>
		<%}%>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="5%">&nbsp;</td>
    <td width="14%" align="center"><strong> SSS number </strong></td>
    <td width="33%">&nbsp;</td>
    <td width="12%"><div align="center"><strong>EE</strong></div></td>
		<%if(bolShowER){%>
    <td width="10%"><div align="center"><strong>ER</strong></div></td>
		<%}%>
		<%if(bolShowEC){%>
    <td width="11%"><div align="center"><strong>EC</strong></div></td>
		<%}%>
    <td width="15%"><div align="center"><strong>TOTAL</strong></div></td>
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
    <td height="22" align="right"><strong><%=iIncr%>.</strong>&nbsp;&nbsp;</td>
    <td>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%></td>
    <td>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%> </td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dPageEE += dTemp;
		dLineTotal += dTemp;
	%>
    <td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
		<%if(bolShowER){%>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dPageER += dTemp;
		dLineTotal += dTemp;
	%>	
    <td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
		<%}// end if bolShowER%>
		<%if(bolShowEC){%>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dPageEC += dTemp;
		dLineTotal += dTemp;
	%>	
    <td align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
		<%}// end if bolShowER%>
		<%
			dPageTotal += dLineTotal;
		%>
    <td align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"")%>&nbsp;</td>
  </tr>
	<%}%>
  <tr>
    <td height="21" align="right" class="thinborderTOP">&nbsp;</td>
    <td class="thinborderTOP">&nbsp;</td>
    <td align="right" class="thinborderTOP">Page Total&nbsp;:  </td> 
    <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dPageEE,true)%>&nbsp;</td>
		<%if(bolShowER){%>
    <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dPageER,true)%>&nbsp;</td>
		<%}%>
		<%if(bolShowEC){%>
    <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dPageEC,true)%>&nbsp;</td>
		<%}%>
    <td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;</td>		
  </tr>
	<%	
		dGrandEE += dPageEE;
		dGrandER += dPageER;
		dGrandEC += dPageEC;
		dGrandTotal += dPageTotal;
	%>
	<%if (iNumRec >= vRetResult.size()){%>
  <tr>
    <td height="22" align="right">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="right">Grand Total&nbsp;:  </td>
    <td align="right"><%=CommonUtil.formatFloat(dGrandEE ,true)%>&nbsp;</td>
		<%if(bolShowER){%>
    <td align="right"><%=CommonUtil.formatFloat(dGrandER ,true)%>&nbsp;</td>
		<%}%>
		<%if(bolShowEC){%>
    <td align="right"><%=CommonUtil.formatFloat(dGrandEC ,true)%>&nbsp;</td>
		<%}%>
    <td align="right"><%=CommonUtil.formatFloat(dGrandTotal ,true)%>&nbsp;</td>
  </tr>  
	<%}%>
</table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()%>
	<%if(WI.fillTextValue("prepared_by").length() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>Prepared by : </td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="27%" height="31" align="center" valign="bottom" class="thinborderBOTTOM"><%=WI.fillTextValue("prepared_by")%></td>
    <td width="73%">&nbsp;</td>
  </tr>
  <tr>
    <td align="center"><%=WI.getStrValue(WI.fillTextValue("position"), "HR/PAYROLL OFFICER")%></td>
    <td>&nbsp;</td>
  </tr>
</table>
 <%}%>
<%} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>