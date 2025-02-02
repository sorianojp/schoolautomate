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
<title>Monthly Remmitance Report</title>
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

 TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size:11px;
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
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}

function ForwardTo(){
//	document.form_.forward_ungrouped.value = "1";
//	document.form_.print_pg.value = "";
//	this.SubmitOnce('form_');
location = "./sss_monthly_unsort.jsp?month_of="+document.form_.month_of.value+
					 "&year_of="+document.form_.year_of.value+
					 "&pt_ft="+document.form_.pt_ft.value+
					 "&employee_category="+document.form_.employee_category.value+
					 "&employer_index="+document.form_.employer_index.value+
					 "&c_index="+document.form_.c_index.value+
					 "&d_index="+document.form_.d_index.value+
					 "&searchEmployee=1&grouped=0";
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	boolean bolPageBreak = false;
	String strImgFileExt = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	int iSearchResult = 0;
	String strPayrollPeriod  = null;
	boolean bolHasTeam = false;	
	boolean bolHasInternal = false;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
										"Admin/staff-Payroll-Reports-Remittances-SSS Premium","sss_monthly_remittance_wup_print.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolHasInternal = (readPropFile.getImageFileExtn("HAS_INTERNAL","0")).equals("1");		
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
														"sss_monthly_remittance_wup_print.jsp");
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
					  
String[] astrPtFt = {"PART-TIME","FULL-TIME"};

double dTemp = 0d;
double dLineTotal = 0d;

double dSubTotal = 0d;
double dEESubTotal = 0d;
double dERSubTotal = 0d;
double dECSubTotal = 0d;

double dGrandTotal = 0d;
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
String strEmployer = "";
String strEmployerSSSNo = "";

int i = 0;
Vector vEmployerInfo = null;

if(WI.fillTextValue("searchEmployee").equals("1")){	
  	vRetResult = PRRemit.getAllMonthlyPremium(dbOP,false);
	if(vRetResult == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		iSearchResult = PRRemit.getSearchCount();
	}
	
	vEmployerInfo = PRRemit.operateOnEmployerProfile(dbOP,4);
	if(vEmployerInfo == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		strEmployerSSSNo = (String)vEmployerInfo.elementAt(6);
		iSearchResult = PRRemit.getSearchCount();
	}
	
	
}

if(strErrMsg == null) 
strErrMsg = "";
%>

<body onLoad="javascript:window.print();">
<form name="form_" method="post" action="./sss_monthly_remittance_wup_print.jsp"> 
  <%
  int iCtr = 1;
  int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
  int iPage = 1; int iCount = 0;
  for(i = 3; i < vRetResult.size();){  %>
  	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
    <tr>
    <td colspan="10" align="center"><div align="center" style="font-size:14px"><strong> Monthly SSS Contribution Collection List
		</strong></div>
    PRIVATE EMPLOYER</td>
  </tr>
  <tr>
  		<td colspan="5" align="left">&nbsp;
			<table>
				<tr>
					<td>&nbsp;&nbsp;&nbsp;
						<strong><font size ="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br />	
						&nbsp;&nbsp;&nbsp;
						<font size ="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>	
						&nbsp;&nbsp;&nbsp;	
						<%
							if(vEmployerInfo != null && vEmployerInfo.size() > 0)
								strTemp = (String)vEmployerInfo.elementAt(5);
							else
								strTemp = "";
						%>				
						<font size ="2"><%=strTemp%></font> <br>
						
					</td>
				</tr>
			</table>
		</td>
  		<td colspan="5" valign="top" align="right">&nbsp;
			<table border="0" cellpadding="0" cellspacing="0" >
				<tr>
					<td class="thinborderALL" align="center">&nbsp;For the month of:&nbsp;</td>					
				</tr>
				<tr>					
					<td class="thinborderBOTTOMLEFTRIGHT">&nbsp;<strong><font size ="2"><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></font>&nbsp;</td>
				</tr>
				<tr><td>&nbsp;</td></tr>
				<tr>
					<td class="thinborderALL" align="center">&nbsp;SSS ID No:&nbsp;</td>					
				</tr>
				<tr>					
					<td class="thinborderBOTTOMLEFTRIGHT">&nbsp;<strong><font size ="2"><%=strEmployerSSSNo%></strong></font>&nbsp;</td>
				</tr>
			</table>
		
		</td>
  </tr>
  <tr>
    <td width="11%" height="18">&nbsp;</td>	
	<td width="2%">&nbsp;</td>
	<td width="20%">&nbsp;</td>
    <td width="19%">&nbsp;</td>
    <td width="6%">&nbsp;</td>
    <td width="11%">&nbsp;</td>	
    <td width="11%">&nbsp;</td>	
    <td width="9%">&nbsp;</td>
  </tr>  
    <tr>
  	<td class="thinborderTOPRIGHT">&nbsp;</td>
	<td align="center" class="thinborderTOPRIGHT" colspan="4" height="20"><strong>NAME OF MEMBER</strong></td>
	<td align="center" colspan="2" class="thinborderTOPRIGHT">
	<strong>SOCIAL SECURITY</strong></td>
	<td width="9%" align="center" class="thinborderTOPRIGHT">&nbsp;	</td>
	<td width="11%" align="center" class="thinborderTOPRIGHT">&nbsp;	</td>
  </tr>
  
  <tr>
  	<td align="right" class="thinborderBOTTOMRIGHT" height="30"><strong>(SS Number)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong></td>
	<td align="center" class="thinborderTOPBOTTOM">&nbsp;</td>
	<td align="left" class="thinborderTOPBOTTOM"><strong>(Surname)</strong></td>
	<td align="left" class="thinborderTOPBOTTOM"><strong>(Given Name)</strong></td>
	<td align="left" class="thinborderTOPBOTTOMRIGHT"><strong>(MI)</strong></td>
	<td align="center" class="thinborderTOPBOTTOMRIGHT"><strong>EMPLOYEE</strong></td>
	<td width="11%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>EMPLOYER</strong></td>	
	<td align="center" class="thinborderBOTTOMRIGHT"><strong>EC</strong></td>	
	<td align="center" class="thinborderBOTTOMRIGHT"><strong>TOTAL</strong></td>
  </tr>  
<%  
	iCount = 0;
for(; i < vRetResult.size();){
 	dLineTotal = 0d;
	iCount+=1;
  %>
  
  <tr>
    <td class="thinborderRIGHT" height="20" align="right"><%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	<td class="NoBorder" >&nbsp;<%=iCtr++%>.&nbsp;</td>
	<td  class="NoBorder" >&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%>&nbsp;</td>
	<td class="NoBorder"  >&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%>&nbsp;</td>
	<td  class="thinborderRIGHT">&nbsp;<%=(WI.getStrValue((String)vRetResult.elementAt(i+5)," ")).charAt(0)%>&nbsp;</td>    
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;		
		dEESubTotal += dTemp;
	%>
    <td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;		
		dERSubTotal += dTemp;
	%>	
    <td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;		
		dECSubTotal += dTemp;		
	%>	
    <td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>	
	<%		
		dSubTotal+= dLineTotal;
	%>
    <td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"")%>&nbsp;</font></div></td>
  </tr>
  <% 
  i = i + 19; 		
  	if(iCount >= iMaxRecPerPage || i >= vRetResult.size() ){
		if(iCount >= iMaxRecPerPage)
			bolPageBreak = true;
		break;
	}
  }//end of inner loop
  %>
  
  <tr>  
    <td colspan="9" class="thinborderTOP">&nbsp;</td>   
  </tr>
  <tr> 
  	<td height="30"><div align="right">&nbsp;</td>
	<td height="30"><div align="right">&nbsp;<strong><%=iCtr-1%></strong>&nbsp;</td>
	<td height="30"><div align="right">&nbsp;</td>
    <td colspan="2" height="30" align="center" class="thinborderALL"><strong>This page total... </strong></td>
    <td class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dEESubTotal,true),"")%>&nbsp;</div></td>
    <td class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dERSubTotal,true),"")%>&nbsp;</div></td>	
    <td class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dECSubTotal,true),"")%>&nbsp;</div></td>	
    <td class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dSubTotal,true),"")%>&nbsp;</div></td>
  </tr>

  </table>
  
  <%if(bolPageBreak){  %>
  	<DIV style="page-break-before:always">&nbsp;</Div>
  <%}%>	
  <%
  
  dEEGrandTotal += dEESubTotal;
  dECGrandTotal += dECSubTotal;
  dERGrandTotal += dERSubTotal;
  dGrandTotal += dSubTotal;
  
  dEESubTotal = 0;
  dECSubTotal = 0;
  dERSubTotal = 0;
  dSubTotal = 0;
  
  
  }// first For loop%> 
  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" > 
<tr><td>&nbsp;</td></tr>
  <tr> 
  	<td width="11%" height="30"><div align="right">&nbsp;</td>
	<td width="2%" height="30"><div align="right">&nbsp;<strong><%=iCtr-1%></strong>&nbsp;</td>
	<td width="20%" height="30"><div align="right">&nbsp;</td>
    <td colspan="2" height="30" align="center" class="thinborderALL"><strong>Grand total </strong></td>
    <td width="11%" class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dEEGrandTotal,true),"")%>&nbsp;</div></td>
    <td width="11%" class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dERGrandTotal,true),"")%>&nbsp;</div></td>	
    <td width="9%" class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dECGrandTotal,true),"")%>&nbsp;</div></td>	
    <td width="11%" class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dGrandTotal,true),"")%>&nbsp;</div></td>
  </tr>
</table>

 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
   	<tr><td>&nbsp;</td></tr>
	<tr><td>&nbsp;</td></tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Prepared by: </td>
      <td>&nbsp;</td>
      <td>Certified by: </td>
      <td height="25">&nbsp;</td>
      <td height="25">Noted by: </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td align="center" valign="bottom"><%=WI.fillTextValue("prepared_by")%></td>
      <td>&nbsp;</td>
      <td align="center" valign="bottom" height="40"><%=WI.fillTextValue("certified_by")%></td>
      <td height="25">&nbsp;</td>
      <td height="25" align="center" valign="bottom"><%=WI.fillTextValue("noted_by")%></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="24%">&nbsp;</td>
      <td width="5%">&nbsp;</td>
      <td width="27%">&nbsp;</td>
      <td width="5%" height="25">&nbsp;</td>
      <td width="26%" height="25">&nbsp;</td>
      <td width="7%">&nbsp;</td>
    </tr>
  </table>

  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="grouped" value="">  
 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>