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
<title>MONTHLY MISCELLANEOUS DEDUCTIONS</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD.thinborderLEFT {
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderBOTTOM{
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
TD.thinborderBOTTOMLEFTRIGHT{
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
TD.thinborderLEFTRIGHT{
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderTOP{
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderTOPLEFT{
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
TD.thinborderTOPLEFTRIGHT{
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","monthly_misc_ded.jsp");

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
														"monthly_misc_ded.jsp");
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
ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
String strBenefitName = null;					  
String strSchCode = dbOP.getSchoolIndex();	
boolean bolPageBreak = false;
double dPageTotal  = 0d;
double dGrandTotal  = 0d;

  vRetResult = RptPay.gePeriodOtherContribution(dbOP);
	if (vRetResult != null) {	
	int i = 0; int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));	

	strBenefitName = dbOP.mapOneToOther("hr_benefit_incentive" + 
			" join hr_preload_benefit_type on (hr_benefit_incentive.benefit_type_index = hr_preload_benefit_type.benefit_type_index)",
			"BENEFIT_INDEX", WI.fillTextValue("benefit_index"),"BENEFIT_NAME + ' ('+sub_type+')'","");

				 
	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = vRetResult.size()/(10*iMaxRecPerPage);	
	if(vRetResult.size() % (10*iMaxRecPerPage) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){	   
	   dPageTotal = 0d;
%>

<body onLoad="javascript:window.print();">
<form name="form_">
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <%if(strSchCode.startsWith("LCP")){%>
    <tr>
      <td height="18">&nbsp;</td>
      <td><div align="center">Republic of the Philippines </div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td><div align="center">Department of Health </div></td>
      <td>&nbsp;</td>      
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td><div align="center">LUNG CENTER OF THE PHILS. </div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td><div align="center">LUNG CENTER OF THE PHILIPPINES</div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td><div align="center">Quezon Avenue, Quezon City </div></td>
      <td>&nbsp;</td>
    </tr>
	<%}else{%>
    <tr>
      <td height="18">&nbsp;</td>
      <td><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td>
      <td>&nbsp;</td>
    </tr>
	<%}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    
    <tr>
      <td height="18">&nbsp;</td>
      <td><div align="center"><strong><%=(WI.getStrValue(strBenefitName,"")).toUpperCase()%> CONTRIBUTION </strong></div></td>
      <td>&nbsp;</td>
    </tr>		
    
    <tr>
      <td  width="15%" height="18" valign="bottom">&nbsp;</td>
      <td width="70%" height="18" valign="bottom">&nbsp;</td>
      <td width="15%" height="18" valign="bottom">Page: <%=iPage%> of <%=iTotalPages%>&nbsp;&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="bottom"><div align="center"><strong><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%>, <%=WI.fillTextValue("year_of")%></strong></div></td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">  
  <tr>
    <td>&nbsp;</td>
    <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
    <td class="thinborderBOTTOM">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>  
  <tr>
    <td>&nbsp;</td>
    <td height="21" colspan="2" class="thinborderBOTTOMLEFT"><div align="center">EMPLOYEE</div></td>
    <td class="thinborderBOTTOMLEFTRIGHT"><div align="center">AMOUNT</div></td>
    <td>&nbsp;</td>
  </tr>
	<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=10,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>  
  <tr>
    <td width="13%">&nbsp;</td>
    <td width="6%" height="21" class="thinborderLEFT"><div align="right"><%=iIncr%>.&nbsp;</div></td>
	<td width="48%">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
				(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></td>
	<%
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true);
	%>
    <td width="20%" class="thinborderLEFTRIGHT"><div align="right"><%=strTemp%>&nbsp;</div></td>
	<%
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dPageTotal += Double.parseDouble(strTemp);
	%>
    <td width="13%">&nbsp;</td>
  </tr>
  <%}// end for loop%>
<tr> 
      <td height="24">&nbsp;</td>
      <td height="24" colspan="2" class="thinborderTOPLEFT"><div align="center">P A G E &nbsp;&nbsp;&nbsp;T O T A L </div></td>
      <%
	  	dGrandTotal += dPageTotal;
	  %>
      <td class="thinborderTOPLEFTRIGHT"><div align="right"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;</div></td>
      <td>&nbsp;</td>
    </tr>	
	<%if ( iNumRec >= vRetResult.size()) {%>    	
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="2" class="thinborderTOPLEFT"><div align="center">G R A N D&nbsp; &nbsp;&nbsp;T O T A L </div></td>
      <td class="thinborderTOPLEFTRIGHT"><div align="right"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;</div></td>
      <td>&nbsp;</td>
    </tr>
	<%}%>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20" colspan="3" class="thinborderTOP"><div align="right">CERTIFIED CORRECT BY: </div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="24" colspan="3">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>	
</table>
  <%if (iNumRec < vRetResult.size()){%>
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