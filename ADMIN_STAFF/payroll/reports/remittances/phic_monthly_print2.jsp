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
<title>PAG-IBIG LOANS MONTHLY REMITTANCES</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.noBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.noBorderSmall{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOMLEFTSmall {
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
	font-size: 10px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderLEFT {
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderLEFTSmall {
	border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 9px;
}

TD.thinborderALL {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	border-right: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TABLE.thinborder{
	border-top: solid 1px #000000;
  border-right: solid 1px #000000;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>
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
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","phic_monthly.jsp");

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
														"phic_monthly.jsp");
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
PRRemittance PRRemit = new PRRemittance(request);
double dTemp  = 0d;
double dPagePersonal = 0d;
double dPageEmployer = 0d;
double dPersonalTotal = 0d;
double dEmployerTotal = 0d;

double dPageTotal = 0d;
double dGrandTotal = 0d;
boolean bolPageBreak = false;

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
String[] astrPtFt = {"PART-TIME","FULL-TIME"};
String[] astrRemarks = {"A", "B", "C", "D", "E", ""};
String[] astrRptType = {"REGULAR RF-1","ADDITION TO PREVIOUS RF-1","DEDUCTION TO PREVIOUS RF-1"};

String strEmpType = "0";
String strRptType = WI.fillTextValue("report_type");
Vector vEmployerInfo = null;
vRetResult = PRRemit.PHICMonthlyPremium(dbOP);
if(vRetResult != null && vRetResult.size() > 0){
		vEmployerInfo = (Vector)vRetResult.elementAt(0);
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strEmpType = (String)vEmployerInfo.elementAt(2);
	

	int i = 0; int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		

	int iNumRec = 1;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = vRetResult.size()/(21*iMaxRecPerPage);	
	if(vRetResult.size() % (21*iMaxRecPerPage) > 0) ++iTotalPages;
	for (;iNumRec < vRetResult.size();iPage++){
	dPagePersonal = 0d;
	dPageEmployer = 0d;
%>

<body onLoad="javascript:window.print();">
<form name="form_">
 
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
    <td width="2%" class="thinborderLEFT">&nbsp; </td>
    <td width="14%">&nbsp;</td>
    <td width="14%">&nbsp;</td>
    <td width="14%">&nbsp;</td>
    <td width="19%" class="thinborderLEFT">&nbsp;</td>
    <td width="6%">&nbsp;</td>
    <td width="9%">&nbsp;</td>
    <td width="9%">&nbsp;</td>
    <td width="13%">&nbsp;</td>
  </tr>  
  <tr>
    <td colspan="4" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="11%">&nbsp;</td>
        <td width="24%"><strong><font size="+1">RF - 1</font></strong><br>
          REVISED JAN 2008 </td>
        <td width="65%">Republic of the Philippines<br>
PHILIPPINE HEALTH INSURANCE CORPORATION<br>
<strong>EMPLOYER'S REMITTANCE REPORT </strong></td>
      </tr>
    </table></td>
    <td colspan="5" rowspan="2" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td colspan="8" align="center"><strong> F O R &nbsp;&nbsp;P H I L H E A L T H &nbsp;&nbsp;U S E </strong></td>
      </tr>
      <tr>
        <td width="7%">&nbsp;</td>
        <td colspan="4">Date Received : </td>
        <td width="5%">&nbsp;</td>
        <td width="13%">Action Taken </td>
        <td width="13%">&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td width="10%">&nbsp;</td>
        <td width="11%">By:</td>
        <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td colspan="2" align="center">Signature over Printed Name </td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td colspan="3" class="thinborderBOTTOMLEFT">
		<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td class="noBorder">PHILHEALTH NO.&nbsp;</td>
		<%
			if(vEmployerInfo != null && vEmployerInfo.size() > 0)
				strTemp = (String)vEmployerInfo.elementAt(8);
			else
				strTemp = "";
		%>		
    <td class="thinborderBOTTOM"><strong><%=WI.getStrValue(strTemp)%></strong></td>
  </tr>
  <tr>
    <td width="28%" class="noBorder">EMPLOYER TIN&nbsp;</td>
		<%
			if(vEmployerInfo != null && vEmployerInfo.size() > 0)
				strTemp = (String)vEmployerInfo.elementAt(7);
			else
				strTemp = "";
		%>		
    <td width="72%" class="thinborderBOTTOM"><strong><%=WI.getStrValue(strTemp)%></strong></td>
    </tr>
	</table>	</td>
    </tr>
  <tr>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
		<%
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strTemp = (String) vEmployerInfo.elementAt(12);
		else
			strTemp = SchoolInformation.getSchoolName(dbOP,true,false);
		%>			
    <td colspan="3" class="thinborderBOTTOM"><table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
  <tr>
    <td width="14%" height="21" class="noBorder">&nbsp;</td>
    <td width="18%" height="21" class="noBorder">&nbsp;</td>
    <td width="68%" >&nbsp;</td>
  </tr>
  <tr>
    <%
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strTemp = (String) vEmployerInfo.elementAt(12);
		else
			strTemp = SchoolInformation.getSchoolName(dbOP,true,false);
		%>			
    <td height="21" colspan="2" class="noBorder">COMPLETE EMPLOYER NAME</td>
    <td class="thinborderBOTTOM"><strong><%=WI.getStrValue(strTemp)%></strong></td>
  </tr>
  <tr>
    <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(3);
        else
	        strTemp = SchoolInformation.getAddressLine1(dbOP,false,false);
		  %>			
    <td height="21" colspan="2" class="noBorder">COMPLETE MAILING ADDRESS</td>
    <td class="thinborderBOTTOM"><strong><%=strTemp%></strong></td>
  </tr>
  <tr>
    <%
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strTemp = (String)vEmployerInfo.elementAt(5);
		else
			strTemp = "";
	%>			
    <td class="noBorder">Tel. No. </td>
    <td colspan="2" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp)%></td>
    </tr>
		</table>		</td>
    <td valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td height="18" colspan="3" class="thinborder"><strong>EMPLOYER TYPE </strong></td>
        </tr>
      <tr>
        <td class="thinborder">&nbsp;</td>
        <%
			 if(strEmpType.equals("1"))
				strTemp = "X";
			 else
				strTemp = "&nbsp;";
			 %>
        <td height="18" class="thinborderALL"><div align="center"><strong><%=strTemp%></strong></div></td>
        <td class="noBorder">&nbsp;PRIVATE</td>
        <%
			 if(strEmpType.equals("3"))
				strTemp = "X";
			 else
				strTemp = "&nbsp;";
			 %>
        </tr>
      
      <tr>
        <td width="6%" class="thinborder">&nbsp;</td>
        <%
			 if(strEmpType.equals("2"))
				strTemp = "X";
			 else
				strTemp = "&nbsp;";
			 %>
        <td width="6%" height="18" class="thinborderALL"><div align="center"><strong><%=strTemp%></strong></div></td>
        <td width="43%" class="noBorder">&nbsp;GOVERNMENT</td>
        <%
			 if(strEmpType.equals("4"))
				strTemp = "X";
			 else
				strTemp = "&nbsp;";
			 %>
        </tr>
      <tr>
        <td class="thinborder">&nbsp;</td>
        <td height="18" class="thinborderALL">&nbsp;</td>
        <td class="noBorder"> &nbsp;HOUSEHOLD</td>
      </tr>
    </table></td>
    <td colspan="3" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td height="18" colspan="3" class="thinborder"><strong>REPORT TYPE </strong></td>
      </tr>
			<%for(i = 0; i < 3;i++){%>
      <tr>
        <td width="5%" class="thinborder">&nbsp;</td>
       <%
			 if(strRptType.equals(Integer.toString(i)))
				strTemp = "X";
			 else
				strTemp = "&nbsp;";
			 %>
        <td width="10%" height="18" class="thinborderALL"><div align="center"><strong><%=strTemp%></strong></div></td>
        <td width="85%" class="noBorder">&nbsp;<%=astrRptType[i]%> </td>
      </tr>
      <%}%>
    </table></td>
    <td valign="top" class="thinborderBOTTOMLEFT"><strong>APPLICABLE PERIOD </strong><strong><br>
      <br>
      <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></td>
  </tr>
  
  <tr>
    <td align="center" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td height="14" colspan="3" align="center" class="thinborderBOTTOMLEFT">NAME OF EMPLOYEES </td>
    <td rowspan="2" align="center" class="thinborderBOTTOMLEFT">PHILHEALTH NO. </td>
    <td rowspan="2" align="center" class="thinborderBOTTOMLEFT">MONTHLY SALARY BRACKET </td>
    <td colspan="2" align="center" class="thinborderBOTTOMLEFT">NHIP PREMIUM CONTRIBUTION </td>
    <td rowspan="2" align="center" class="thinborderBOTTOMLEFT">MEMBER STATUS </td>
  </tr>
  <tr>
    <td align="center" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td height="13" align="center" class="thinborderBOTTOMLEFT">SURNAME</td>
    <td height="13" align="center" class="thinborderBOTTOMLEFT">GIVEN NAME </td>
    <td height="13" align="center" class="thinborderBOTTOMLEFT">MIDDLE NAME </td>
    <td align="center" class="thinborderBOTTOMLEFT">PS</td>
    <td align="center" class="thinborderBOTTOMLEFT">ES</td>
  </tr>
	<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=21,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>  
  <tr>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=iIncr%></td>
    <td height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+6)%><font size="1">&nbsp;</font></td>
    <td class="thinborderBOTTOMLEFT">&nbsp;<font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+15),"&nbsp;")%></td>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+16)%></td>
    <% 
		strTemp = (String)vRetResult.elementAt(i+11);		
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dPagePersonal += dTemp;
		%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
	<% strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));	
		dPageEmployer  += dTemp;
	%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
    <td align="right" class="thinborderBOTTOMLEFT">&nbsp; </td>
    </tr>
  <%}%>
	<%for(;iCount<=iMaxRecPerPage; ++iCount){%>	
  <tr>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td height="23" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
  </tr>  
  <%}%>
  
  <tr>
    <td colspan="4" rowspan="7" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
          <tr>
            <td height="22" colspan="5" align="center" class="thinborderBOTTOM"><strong>ACKNOWLEDGEMENT RECEIPT </strong><strong>(ME-5/POR/OR/PAR)</strong></td>
          </tr>
          <tr>
            <td height="33" class="thinborderBOTTOM">APPLICABLE PERIOD </td>
            <td class="thinborderBOTTOMLEFT"> REMITTED AMOUNT </td>
            <td class="thinborderBOTTOMLEFT"> ACKNOWLEDGEMENT RECEIPT NO.</td>
            <td class="thinborderBOTTOMLEFT">TRANSACTION DATE </td>
            <td class="thinborderBOTTOMLEFT">NO. OF EMPLOYEES </td>
          </tr>
          <tr>
            <td height="39">&nbsp;</td>
            <td class="thinborderLEFT">&nbsp;</td>
            <td class="thinborderLEFT">&nbsp;</td>
            <td class="thinborderLEFT">&nbsp;</td>
            <td class="thinborderLEFT">&nbsp;</td>
          </tr>
      </table></td>
    <td colspan="2" rowspan="2" valign="top" class="thinborderLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="63%" align="center">SUBTOTAL</td>
            <td width="37%"><strong>(PS + ES)</strong></td>
          </tr>
      </table></td>
		<%
			dPersonalTotal += dPagePersonal;
			dEmployerTotal += dPageEmployer;
			dPageTotal = dPagePersonal + dPageEmployer;
			dGrandTotal = dPersonalTotal + dEmployerTotal;
		%>			
    <td rowspan="2" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dPagePersonal,true)%>&nbsp;</td>
    <td rowspan="2" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dPageEmployer,true)%>&nbsp;</td>
    <td height="13" class="thinborderLEFT">CERTIFIED CORRECT :</td>
  </tr>
  <tr>
    <td height="13" class="thinborderBOTTOMLEFT">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2" rowspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="63%" align="center" class="noBorderSmall">(To be accomplished on every page)</td>
        <td width="37%">&nbsp;</td>
      </tr>
    </table></td>
    <td colspan="2" rowspan="2" align="center" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dPageTotal,true)%></td>
    <td height="13" align="center" class="thinborderLEFTSmall">SIGNATURE OVER PRINTED NAME </td>
  </tr>
  <tr>
    <td height="13" class="thinborderBOTTOMLEFT">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2" valign="top" class="thinborderLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="63%" height="14" align="center">GRAND TOTAL </td>
          <td width="37%"><strong>(PS + ES)</strong></td>
        </tr>
      </table></td>
		<%
			if (iNumRec >= vRetResult.size())
				strTemp = CommonUtil.formatFloat(dPersonalTotal,true);
			else
				strTemp = "--";		
		%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
		<%
			if (iNumRec >= vRetResult.size())
				strTemp = CommonUtil.formatFloat(dEmployerTotal,true);
			else
				strTemp = "--";		
		%>		
    <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
    <td height="13" align="center" valign="top" class="thinborderLEFTSmall">OFFICIAL DESIGNATION </td>
  </tr>
  <tr>
    <td colspan="2" rowspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="63%" align="center" class="noBorderSmall">(To be accomplished on the last page) </td>
        <td width="37%">&nbsp;</td>
      </tr>
    </table></td>
		<%
			if (iNumRec >= vRetResult.size())
				strTemp = CommonUtil.formatFloat(dGrandTotal,true);
			else
				strTemp = "--";		
		%>			
    <td colspan="2" rowspan="2" align="center" class="thinborderBOTTOMLEFT"><%=strTemp%></td>
    <td height="13" class="thinborderBOTTOMLEFT">&nbsp;</td>
  </tr>
  <tr>
    <td height="13" align="center" class="thinborderBOTTOMLEFTSmall">DATE</td>
  </tr>
</table>
  <%if (bolPageBreak){%>
  <DIV style="page-break-before:always" >&nbsp;</DIV>
  <%}//page break ony if it is not last page.
  } //end for (iNumRec < vRetResult.size()%>

<%}// if vRetResult != null%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>