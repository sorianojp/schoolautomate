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
<title>REGULAR LOANS MONTHLY REMITTANCES</title>
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
	font-size: 10px;
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
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
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

///ajax here to load dept..
function loadLoanList() {
	var objCOA=document.getElementById("load_loans");
	
	var strLoanType = document.form_.loan_type[document.form_.loan_type.selectedIndex].value;
	var vSize = document.form_.list_size.value;
	if(vSize > 10){
		alert("Limit list size to 10 only");
		document.form_.list_size.value = "10";
	}
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=314"+
							 "&loan_type="+strLoanType+"&sel_name=code_index&show_all=1"+
							 "&list_size="+document.form_.list_size.value;
	this.processRequest(strURL);
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance, payroll.PRAjaxInterface" %>
<%
	PRAjaxInterface prAjax = null;
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolHasConfidential = false;
	boolean bolHasTeam = false;
	boolean bolIsGovernment = false;
	String strHasWeekly = null;
 

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Remittances-Institutional Loans","regular_loans_summary.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");	
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");		
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");		
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
														"regular_loans_summary.jsp");
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
Vector vPeriods = null;
Vector vEmployerInfo = null;
PRRemittance PRRemit = new PRRemittance(request);
	boolean bolShowIssue = WI.fillTextValue("date_issued").length() > 0;
	boolean bolShowStart = WI.fillTextValue("date_start").length() > 0;
String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
String[] astrPtFt = {"PART-TIME","FULL-TIME"};

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";	
	if(strSchCode.startsWith("AUF"))
		strTemp = "PS Bank Loans";
	else
		strTemp = "PERAA Loans";
		
String[] astrLoanType = {"", "", "Internal Loan","SSS Loans","Pag-ibig Loans", strTemp, "GSIS Loans" };
String strLoanType = WI.fillTextValue("loan_type");
int i = 0;
int j = 0;
String strNextCode = null;
String strCurCode = null;
double dLineTotal = 0d;
double[] adPeriodTotal = null;
double dGrandTotal = 0d;
double dTemp = 0d;

	//Vector vEmployer = null;
	//vEmployer = operateOnEmployerProfile(dbOP, 3, strEmployerIndex);

   vRetResult = PRRemit.monthlyLoanRemittanceSummary(dbOP);
	if(vRetResult == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		vPeriods = (Vector)vRetResult.remove(0);
		if(vPeriods != null && vPeriods.size() > 0){
			adPeriodTotal = new double[vPeriods.size()/5];			
		}
		
		iSearchResult = PRRemit.getSearchCount();
	}
 
%>

<body onLoad="window.print();">
<form name="form_" >
  <%if (vRetResult != null && vRetResult.size() > 0 ){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr></tr>
  <tr>
    <td colspan="5" align="center">				
				<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
      <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br></td>
  </tr>
  <tr>
    <td colspan="5" height="24">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="5"><div align="center"><strong>LOAN REMITTANCES<br>
          <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
  </tr>
  <tr>
    <td colspan="5" class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  
  <tr>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td height="27" align="center" class="thinborderBOTTOMLEFT"><strong>DEDUCTION NAME</strong></td>
    <%for(j = 0; j < vPeriods.size(); j+=5){
			strTemp = (String)vPeriods.elementAt(j+1)+ "-"+ (String)vPeriods.elementAt(j+2);
		%>
		<td align="center" class="thinborderBOTTOMLEFT"><strong><%=strTemp%> </strong></td>
		<%}%>
    <td align="center" class="thinborderBOTTOMLEFTRIGHT"><strong>TOTAL</strong></td>
  </tr>
  <%int iCount = 1;
   for(i = 0; i < vRetResult.size();i+=10, iCount++){
		strCurCode = (String)vRetResult.elementAt(i+1);
		dLineTotal = 0d;
   %>
  <tr>
    <td width="5%" class="thinborderBOTTOMLEFT">&nbsp;<%=iCount%>.</td>
		<%
		strTemp = (String)vRetResult.elementAt(i+1);
		%>
    <td width="30%" height="23" class="thinborderBOTTOMLEFT">&nbsp;&nbsp;<%=strTemp%></td>
    <%
		boolean bolIs2ndPeriodOnly = false;
		for(j = 0; j < vPeriods.size(); j+=5){
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), true);
			if(bolIs2ndPeriodOnly) 
				bolIs2ndPeriodOnly = false;
			else if(j == 0 && !vPeriods.elementAt(j).equals(vRetResult.elementAt(i))) {
				strTemp = "0";
				bolIs2ndPeriodOnly = true;
			}
			else {
				if(j > 0){
					if((i + 11) < vRetResult.size()){
						strNextCode = (String)vRetResult.elementAt(i+11);
						if(strNextCode.equals(strCurCode)){
							i+=10;
							strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), true);
						}else{
							strTemp = "0";
						}
					} else{
						strTemp = "0";
					}
				}
			}
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			
			if(dTemp == 0d)
				strTemp = "";
			adPeriodTotal[j/5] += dTemp;
			dLineTotal += dTemp;
			dGrandTotal += dTemp;
 		%>	
    <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
		<%}%>
	<td width="17%" align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dLineTotal, true)%>&nbsp;</td>
    </tr>
  <%}%>
	<tr>
    <td class="thinborderBOTTOMLEFT" height="26">&nbsp;</td>
    <td height="23" align="right" class="thinborderBOTTOMLEFT"><strong>TOTAL</strong></td>
		<%for(j = 0; j < vPeriods.size(); j+=5){%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(adPeriodTotal[j/5], true)%>&nbsp;</td>
		<%}%>
    <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dGrandTotal, true)%>&nbsp;</td>
  </tr>
</table>
<%} // if (vRetResult != null && vRetResult.size() > 0 )%> 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>