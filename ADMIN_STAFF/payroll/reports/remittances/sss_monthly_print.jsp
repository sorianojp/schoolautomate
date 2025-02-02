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
<title>SSS Monthly Remittance</title>
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
	document.form_.print_all.value ="";	
	this.SubmitOnce('form_');
}

function PrintSlip(emp_id, sal_period_index,sal_index,strBankAcct,strReceiptNo,strStatus,strIsAtm,strTenure)
{
	var pgLoc = "./payroll_slip_print2.jsp?emp_id="+emp_id+"&sal_period_index="+sal_period_index+
				"&sal_index="+sal_index+"&bank_account="+strBankAcct+"&rec_no="+strReceiptNo+
				"&rec_no="+strReceiptNo+"&pt_ft="+strStatus+"&is_atm="+strIsAtm+"&tenure="+strTenure+
				"&finalize=1";
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintALL() {
	document.form_.print_all.value ="1";
	document.form_.print_pg.value = "";
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
	
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","sss_monthly_print.jsp");

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
														"sss_monthly_print.jsp");
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
double dOfficeTotal = 0d;
double dStatusTotal = 0d;
double dGrandTotal = 0d;

double dEEOfficeTotal = 0d;
double dEROfficeTotal = 0d;
double dECOfficeTotal = 0d;

double dEEStatusTotal = 0d;
double dERStatusTotal = 0d;
double dECStatusTotal = 0d;

double dEEGrandTotal = 0d;
double dERGrandTotal = 0d;
double dECGrandTotal = 0d;


boolean bolPtFtHeader = true;
boolean bolShowHeader = true;

boolean bolPtFtTotal = false;
boolean bolOfficeTotal = false;

String strCurColl = "";
String strNextColl = "";
String strCurDept = "";
String strNextDept = "";


int i = 0;

  vRetResult = PRRemit.SSSMonthlyPremium(dbOP);
	if(vRetResult != null && vRetResult.size() > 0)
		vEmployerInfo = (Vector)vRetResult.elementAt(0);

if(strErrMsg == null) 
strErrMsg = "";
%>

<body onLoad="javascript:window.print();">
<form name="form_" method="post" action="./sss_monthly_print.jsp">
  <%if (vRetResult != null && vRetResult.size() > 0 ){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="6">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="6"><div align="center"><font size="2"><strong>
				<%if(vEmployerInfo != null){
					strTemp = (String) vEmployerInfo.elementAt(12);
					strTemp += "<br>" + (String) vEmployerInfo.elementAt(3) + "<br>";
				%>
				<%=strTemp%>
				<%}else{%>
				<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
				<%}%>
    </font></div>		</td>
  </tr>
  <tr>
    <td colspan="6">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="6"><div align="center"><strong>SSS Premiums - <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="1%">&nbsp;</td>
    <td width="37%">&nbsp;</td>
    <td width="16%" align="center"><strong>EE</strong></td>
    <td width="16%" align="center"><strong>ER</strong></td>
    <td width="14%" align="center"><strong>EC</strong></td>
    <td width="16%" align="center"><strong>TOTAL</strong></td>
  </tr>
  <%
  for(i = 3; i < vRetResult.size();){%>
  <%
  	dEEOfficeTotal = 0d;
  	dEROfficeTotal = 0d;
  	dECOfficeTotal = 0d;
	dOfficeTotal = 0d;
  if(bolPtFtHeader){
  	bolPtFtHeader = false;
  %>
  <tr>
    <td>&nbsp;</td>
    <td><strong>&nbsp;<%=astrPtFt[Integer.parseInt((String)vRetResult.elementAt(i+9))]%> EMPLOYEES </strong></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>  
  <%}%>
    <%if(bolShowHeader){
  	bolShowHeader = false;
  %>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;<strong><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"","",(String)vRetResult.elementAt(i+8))%></strong></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr> 
  <%}%>
  <%for(; i < vRetResult.size();){  
 	dLineTotal = 0d;			
	
	if(i+20 < vRetResult.size()){
		if(i == 3){
		strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+7),"");		
		strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+8),"");	
		}
		strNextColl = WI.getStrValue((String)vRetResult.elementAt(i+26),"");		
		strNextDept = WI.getStrValue((String)vRetResult.elementAt(i+27),"");		
		// i+9 is for pt ft status
		if(!((String)vRetResult.elementAt(i+9)).equals((String)vRetResult.elementAt(i+28))){
			bolPtFtHeader = true;
			bolShowHeader = true;
			bolOfficeTotal = true;
		}
		if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
			bolShowHeader = true;
			bolOfficeTotal = true;
		}
	}
  %>
  
  <tr>
    <td>&nbsp;</td>
    <td><font size="1">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%></font> </td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dEEOfficeTotal+=dTemp;
		dEEStatusTotal+=dTemp;
		dEEGrandTotal += dTemp;
	%>
    <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dEROfficeTotal+= dTemp;
		dERStatusTotal+= dTemp;
		dERGrandTotal += dTemp;
	%>	
    <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dECOfficeTotal+=dTemp;		
		dECStatusTotal+=dTemp;
		dECGrandTotal += dTemp;
	%>	
    <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<%
		dOfficeTotal +=dLineTotal;
		dStatusTotal +=dLineTotal;
		dGrandTotal+= dLineTotal;
	%>
    <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"")%>&nbsp;</font></div></td>
  </tr>
  <% 
  i = i + 19;  	
	 if(i < vRetResult.size()){
		 strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+7),"");
		 strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+8),"");
	 }	 
  	if(bolPtFtHeader || bolShowHeader){
		if(bolPtFtHeader){
			bolPtFtTotal = true;
			bolOfficeTotal = true;
		}
		break;
	}

  }%>
  
  <%if(bolOfficeTotal || (!bolOfficeTotal && i >= vRetResult.size())){
  	bolOfficeTotal = false;
  %>
  <tr>
    <td height="24">&nbsp; </td>
    <td align="right"><strong>TOTAL</strong></td>
    <td align="right" class="thinborderTOP"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dEEOfficeTotal,true),"")%>&nbsp;</font></td>
    <td align="right" class="thinborderTOP">
      <font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dEROfficeTotal,true),"")%>&nbsp;</font></td>
    <td align="right" class="thinborderTOP">
      <font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dECOfficeTotal,true),"")%>&nbsp;</font></td>
    <td align="right" class="thinborderTOP">
      <font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dOfficeTotal,true),"")%>&nbsp;</font></td>
  </tr>
  <%}%>
  <%if(bolPtFtTotal || (!bolPtFtTotal && i >= vRetResult.size())){
  	bolPtFtTotal = false;
  %>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="right"><strong>TOTAL <%=astrPtFt[Integer.parseInt((String)vRetResult.elementAt(i-10))]%></strong></div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dEEStatusTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dERStatusTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dECStatusTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dStatusTotal,true),"")%>&nbsp;</div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>   
  <%
  dEEStatusTotal = 0d;
  dERStatusTotal = 0d;
  dECStatusTotal = 0d;
  dStatusTotal = 0d;
  }%>
  
  <%}// first For loop%>  
  
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="right"><strong>GRAND TOTAL </strong></div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dEEGrandTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dERGrandTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dECGrandTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dGrandTotal,true),"")%>&nbsp;</div></td>
  </tr>
</table>
<%} // if (vRetResult != null && vRetResult.size() > 0 )%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">  
  <tr>
    <td width="50%" height="25">&nbsp;</td>
    </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="print_all" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>