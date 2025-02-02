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
<title>Total monthly remittances per office</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	int iSearchResult = 0;
	String strPayrollPeriod  = null;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","monthly_total_per_office_print.jsp");

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
														"monthly_total_per_office_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
Vector vEmployerInfo = null;
PRRemittance PRRemit = new PRRemittance(request);

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};

String strPremiumType = WI.getStrValue(WI.fillTextValue("premium_type"),"0");
String strPremiumName = "";
if(strPremiumType.equals("1"))
	strPremiumName = "SSS";
else
	strPremiumName = "Philhealth";

double dTemp = 0d;
int i = 0;

double dEEGrandTotal = 0d;
double dERGrandTotal = 0d;
double dECGrandTotal = 0d;
double dGrandTotal = 0d;
double dLineTotal = 0d;
String strEmployer  = null;

  vRetResult = PRRemit.generatePerOfficeMonthlyRemitances(dbOP);
	if(vRetResult != null && vRetResult.size() > 0){
		vEmployerInfo = (Vector)vRetResult.elementAt(0);
		iSearchResult = PRRemit.getSearchCount();
	}
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
        <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(12);
        else
	        strTemp = SchoolInformation.getSchoolName(dbOP,true,false);
        %>
		  <td colspan="6">&nbsp;<strong>NAME OF INSTITUTION</strong> : <%=strTemp%></td>
	  </tr>
		<tr>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(3);
        else
	        strTemp = SchoolInformation.getAddressLine1(dbOP,false,false);
		  %>
		  <td colspan="6">&nbsp;<strong>ADDRESS</strong> : <%=strTemp%></td>
	  </tr>
		<tr>
		  <td colspan="6">&nbsp;</td>
	  </tr>
		<tr>
			<td colspan="6"><div align="center"><strong><%=(strPremiumName).toUpperCase()%></strong> Premiums - <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></div></td>
		</tr>
		<tr>
			<td height="18">&nbsp;</td>
			<td>&nbsp;Records found : <%=iSearchResult%></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<%if(WI.fillTextValue("premium_type").equals("1")){%>
			<td>&nbsp;</td>
			<%}%>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td width="1%">&nbsp;</td>
			<td width="37%">&nbsp;</td>
			<%
				if(strPremiumType.equals("1"))
					strTemp = "EE";
				else
					strTemp = "PS";				
			%>
			<td width="16%" align="center"><strong><%=strTemp%></strong></td>
			<%
				if(strPremiumType.equals("1"))
					strTemp = "ER";
				else
					strTemp = "ES";				
			%>				
			<td width="16%" align="center"><strong><%=strTemp%></strong></td>
			<%if(WI.fillTextValue("premium_type").equals("1")){%>
			<td width="14%" align="center"><strong>EC</strong></td>
			<%}%>
			<td width="16%" align="center"><strong>TOTAL</strong></td>
		</tr>
		<%for(i = 1; i < vRetResult.size();i+= 7){
			dLineTotal = 0d;
		%>
		<tr>
			<td>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
				strTemp = WI.getStrValue(strTemp, (String)vRetResult.elementAt(i+2));
			%>
			<td><font size="1">&nbsp;<%=WI.getStrValue(strTemp)%></font> </td>
		<%	dTemp = 0d;
			strTemp = (String)vRetResult.elementAt(i+4);
			strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");
	
			dTemp = Double.parseDouble(strTemp);		
			if(!WI.fillTextValue("premium_type").equals("1"))	
				dLineTotal += dTemp;
			//dLineTotal += dTemp;
			dEEGrandTotal += dTemp;
		%>
			<td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
			<%	dTemp = 0d;
			strTemp = (String)vRetResult.elementAt(i+5);
			strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");
	
			dTemp = Double.parseDouble(strTemp);		
			dLineTotal += dTemp;
			dERGrandTotal += dTemp;
		%>	
			<td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
			<%	dTemp = 0d;
			strTemp = (String)vRetResult.elementAt(i+6);
			strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");
	
			dTemp = Double.parseDouble(strTemp);		
			dLineTotal += dTemp;
			dECGrandTotal += dTemp;
		%>	
			<%if(WI.fillTextValue("premium_type").equals("1")){%>
			<td align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
			<%}%>
		<%
			dGrandTotal+= dLineTotal;
		%>
			<td align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"")%>&nbsp;</font></td>
		</tr>
		<%}// first For loop%>  
		
		<tr>
			<td>&nbsp;</td>
			<td><div align="right"><strong>TOTAL </strong></div></td>
			<td align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dEEGrandTotal,true),"")%>&nbsp;</td>
			<td align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dERGrandTotal,true),"")%>&nbsp;</td>
			<%if(WI.fillTextValue("premium_type").equals("1")){%>
			<td align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dECGrandTotal,true),"")%>&nbsp;</td>
			<%}%>
			<td align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dGrandTotal,true),"")%>&nbsp;</td>
		</tr>
	</table>
    <%} // if (vRetResult != null && vRetResult.size() > 0 )%>
    <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>