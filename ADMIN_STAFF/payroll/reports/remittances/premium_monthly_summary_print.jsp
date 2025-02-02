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
<title>Monthly premium remittance printing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_pg.value = "1";
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
	String strPayrollPeriod  = null;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","premium_monthly_summary_print.jsp");

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
														"premium_monthly_summary_print.jsp");
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

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};

double dTemp = 0d;
int i = 0;
int iEmpCount = 0;
int iTotalEmp = 0;

double dShare = 0d;
double dShareEE = 0d;
double dShareER = 0d;
String strPremiumType = WI.getStrValue(WI.fillTextValue("premium_type"),"0");
String strPremiumName = "";
if(strPremiumType.equals("1")){
	strPremiumName = "SSS";
}else{
	strPremiumName = "Philhealth";
}

  vRetResult = PRRemit.generateRemittancesSummary(dbOP);

%>

<body onLoad="javascript:window.print();">
<form name="form_">
  <%if (vRetResult != null && vRetResult.size() > 0 ){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td> 
        <div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td>&nbsp;</td>
        <td colspan="5">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td><div align="center"></div></td>
        <td colspan="5" class="thinborderBOTTOM"><div align="center"><strong><%=strPremiumName%> Premiums - <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
        <td>&nbsp;</td>
      </tr>
      
      <tr>
        <td>&nbsp;</td>
        <td align="center" class="thinborderBOTTOMLEFT">          <center>
          </center>        </td>
        <td colspan="2" align="center" class="thinborderBOTTOMLEFT"><strong>EMPLOYEES</strong></td>
        <td colspan="2" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong>EMPLOYER</strong></td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td width="10%">&nbsp;</td>
        <td width="12%" align="center" class="thinborderBOTTOMLEFT"><strong>Number of Employees</strong></td>
        <td width="17%" align="center" class="thinborderBOTTOMLEFT"><strong>SHARE</strong></td>
        <td width="17%" align="center" class="thinborderBOTTOMLEFT"><strong>AMOUNT</strong></td>
        <td width="17%" align="center" class="thinborderBOTTOMLEFT"><strong>SHARE</strong></td>
        <td width="17%" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong>AMOUNT</strong></td>
        <td width="10%">&nbsp;</td>
      </tr>
	  <%for(i = 0; i < vRetResult.size();i+=3){
	  iEmpCount = 0;
	  dShare = 0d;
	  %>
      <tr>
        <td height="19">&nbsp;</td>
		<%
			iEmpCount = Integer.parseInt((String)vRetResult.elementAt(i+2));
			iTotalEmp += iEmpCount;
		%>
        <td align="right" class="thinborderBOTTOMLEFT"><%=iEmpCount%>&nbsp;</td>
		<%
			strTemp = (String)vRetResult.elementAt(i);
			strTemp = CommonUtil.formatFloat(strTemp,true);
		%>
        <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			dShare = dTemp * iEmpCount;
			strTemp = CommonUtil.formatFloat(dShare,true);
			if(dShare <= 0d)
				strTemp = "-&nbsp;";
			dShareEE += dShare;
		%>
        <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = (String)vRetResult.elementAt(i+1);
			strTemp = CommonUtil.formatFloat(strTemp,true);
		%>		
        <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			dShare = dTemp * iEmpCount;
			strTemp = CommonUtil.formatFloat(dShare,true);
			if(dShare <= 0d)
				strTemp = "-&nbsp;";
			dShareER += dShare;
		%>		
        <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
	  <%}%>
      <tr>
        <td height="19">&nbsp;</td>
        <td colspan="2"><strong>TOTAL EMPLOYEES : <%=iTotalEmp%></strong></td>
        <td align="right"><%=CommonUtil.formatFloat(dShareEE,true)%>&nbsp;</td>
        <td>&nbsp;</td>
        <td align="right"><%=CommonUtil.formatFloat(dShareER,true)%>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>	  
  </table>
    <%} // if (vRetResult != null && vRetResult.size() > 0 )%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>