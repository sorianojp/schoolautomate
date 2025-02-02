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
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance,hr.HRInfoPersonalExtn" %>
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
Vector vPersonalInfo = null;//has bday
Vector vPersonalInfoExtn = null;//has pag-ibig num
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
double dEmpTotal = 0d;
double dEmpGrandTotal = 0d;

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

HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
enrollment.Authentication authentication = new enrollment.Authentication();



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
    <td colspan="10" align="center"><div align="center" style="font-size:14px">
	<!--<strong><font size ="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br />	
	<font size ="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br />	<br />-->
	<strong>
	 MONTHLY PAG-IBIG PREMIUM REMITTANCE	</strong><BR />
	<font size ="2">for the month of <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></font>
	</div>    </td>
  </tr>
 
 <tr>     
	  <td height="19" class="thinborderNONE" align="right"  colspan="10">&nbsp;Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>    
  </tr>
 
 <tr>   
	<td width="2%">&nbsp;</td>
	<td width="11%">&nbsp;</td>
    <td width="12%">&nbsp;</td>
    <td width="12%">&nbsp;</td>
    <td width="10%">&nbsp;</td>	
    <td width="9%">&nbsp;</td>	
    <td width="8%">&nbsp;</td>
	 <td width="10%">&nbsp;</td>
	  <td width="14%">&nbsp;</td>
  </tr>   
  
  <tr>  	
	<td align="center" class="thinborderRIGHT">&nbsp;</td>
	<td align="center" class="thinborderTOPBOTTOMRIGHT" height="30"><strong>&nbsp;LNAME</strong></td>
	<td align="center" class="thinborderTOPBOTTOMRIGHT"><strong>&nbsp;FNAME</strong></td>
	<td align="center" class="thinborderTOPBOTTOMRIGHT"><strong>&nbsp;MIDNAME</strong></td>
	<td align="center" class="thinborderTOPBOTTOMRIGHT"><strong>EE SHARE </strong></td>
	<td width="9%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>ER SHARE </strong></td>	
	<td width="8%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>TOTAL </strong></td>	
	<td align="center" class="thinborderTOPBOTTOMRIGHT"><strong>TIN</strong></td>
	<td width="14%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>BDATE</strong></td>
	<td width="12%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>Pag-IBIG Number</strong></td>
		
	<!--<td width="13%" align="center" class="thinborderBOTTOMRIGHT"><strong>TOTAL</strong></td>-->
  </tr>   
  
<%  
	iCount = 0;
for(; i < vRetResult.size();){
	//get personal info
	vPersonalInfo = authentication.getBasicInfo(dbOP, (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i), request);	
	vPersonalInfoExtn = hrPx.viewPersonalExtn(dbOP, (String)vRetResult.elementAt(i));	
	
	
 	dLineTotal = 0d;
	iCount+=1;
  %>
  
  <tr>   
	<td  class="thinborderRIGHT" align="right" width="2%" height="20"><%=iCtr++%>&nbsp;&nbsp;</td>
	<td  class="thinborderBOTTOMRIGHT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%>&nbsp;</td>
	<td  class="thinborderBOTTOMRIGHT"  >&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%>&nbsp;</td>
	<td  class="thinborderBOTTOMRIGHT">&nbsp;<%=(WI.getStrValue((String)vRetResult.elementAt(i+5)," "))%>&nbsp;</td>    
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dEEGrandTotal += dTemp;
		dEmpTotal = dTemp;
	%>
    <td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dERGrandTotal += dTemp;
		dEmpTotal += dTemp;
		dEmpGrandTotal += dEmpTotal;
	%>		
    <td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dEmpTotal,true)%>&nbsp;</font></div></td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;		
		dECGrandTotal += dTemp;		
	%>	
    <!--
	<td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>	
	<%		
		dGrandTotal+= dLineTotal;
	%>
    <td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"")%>&nbsp;</font></div></td>-->
  
  	<%
	   //TIN
	   strTemp = "";
	   if(vPersonalInfoExtn != null || vPersonalInfoExtn.size() > 0)
	   		strTemp = WI.getStrValue(vPersonalInfoExtn.elementAt(5), "");
			
   %>
   <td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
   <%
	   //DOB
	   strTemp = "";
	   if(vPersonalInfo != null || vPersonalInfo.size() > 0)
	   		strTemp = WI.getStrValue(vPersonalInfo.elementAt(5), "");
			
   %>
   <td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
   <td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%>&nbsp;</font></div></td>
  </tr>
  <% 
  i = i + 19; 		
  	if(iCount >= iMaxRecPerPage || i >= vRetResult.size() ){
		if(iCount >= iMaxRecPerPage)
			bolPageBreak = true;
		break;
	}
  }//end of inner loop
  dEEGrandTotal += dEESubTotal;
  dECGrandTotal += dECSubTotal;
  dERGrandTotal += dERSubTotal;
  dGrandTotal += dSubTotal;
  
  dEESubTotal = 0;
  dECSubTotal = 0;
  dERSubTotal = 0;
  dSubTotal = 0;  
  
  if( i >= vRetResult.size() ){
  %>
  
   <tr>
    <td align="center" class="thinborderRIGHT">&nbsp;</td>
	<td align="right" class="thinborderBOTTOMRIGHT"  height="30" colspan="3"><strong>Grand Total &nbsp;&nbsp;</strong></td>
	<td align="right" class="thinborderBOTTOMRIGHT"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dEEGrandTotal,true),"")%>&nbsp;</strong></td>
	<td width="9%" align="right" class="thinborderBOTTOMRIGHT"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dERGrandTotal,true),"")%>&nbsp;</strong></td>	
	<td width="9%" align="right" class="thinborderBOTTOMRIGHT"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dEmpGrandTotal,true),"")%>&nbsp;</strong></td>
	<td align="center" class="thinborderBOTTOMRIGHT" colspan="3" >&nbsp;</td>
  </tr>
  <%}//end of grand total%>
  
  
  <tr>  
    <td colspan="9" >&nbsp;</td>   
  </tr>  
  </table>
  
  <%if(bolPageBreak){  %>
  	<DIV style="page-break-before:always">&nbsp;</Div>
  <%}%>	
  <%
  
 
  
  
  }// first For loop%> 
  
<!--
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
-->
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="grouped" value="">  
 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>