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
	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){%>
    <jsp:forward page="./regular_loans_summary_print.jsp"/>
<% 
return;}

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

if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.monthlyLoanRemittanceSummary(dbOP); System.out.println(vRetResult);
	if(vRetResult == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		vPeriods = (Vector)vRetResult.remove(0);
		if(vPeriods != null && vPeriods.size() > 0){
			adPeriodTotal = new double[vPeriods.size()/5];			
		}
		
		iSearchResult = PRRemit.getSearchCount();
	}
}

if(strErrMsg == null) 
strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="./regular_loans_summary.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr  bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL :  LOANS MONTHLY REMITTANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3"><font size="1"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="23" colspan="3"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Month and Year </td>
      <td> <select name="month_of">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select></td>
    </tr>
    
    	
    <tr>
      <td height="24">&nbsp;</td>
      <td>Period Name </td>
			<%
					strTemp = WI.fillTextValue("period_index");
			%>			
      <td><select name="period_index">
        <option value="">Select Period Name</option>
        <%=dbOP.loadCombo("PERIOD_INDEX","PERIOD_NAME", " from pr_preload_period order by period_name",strTemp,false)%>
      </select></td>
    </tr>
    	 

    <tr>
      <td height="25">&nbsp;</td>
      <td>Loan Type </td>
      <td><select name="loan_type" onChange="loadLoanList();">
        <option value="">ALL</option>
        <%for(i = 2; i < astrLoanType.length; i++){
					if(i == 5 && !bolIsSchool)
						continue;
					
					if(i == 6 && !bolIsGovernment)
						continue;
					
					if(strLoanType.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=astrLoanType[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrLoanType[i]%></option>
        <%}
				}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Loan Name </td>
			<%				
				if(request.getParameterValues("code_index") == null || request.getParameterValues("code_index")[0].length() == 0)
					strTemp = "selected";
				else
					strTemp = "";
			%>
      <td><label id="load_loans">
        <select name="code_index" size="<%=WI.getStrValue(WI.fillTextValue("list_size"),"4")%>" multiple>
          <option value="" <%=strTemp%>>ALL</option>
          <%=prAjax.loadList(dbOP, request, "code_index","loan_name, loan_code",  " from ret_loan_code where is_valid = 1 " +
												WI.getStrValue(strLoanType, " and loan_type = ","","") +
												"order by loan_type, loan_code","code_index")%>
        </select>
      </label>
        <input type="text" name="list_size" value="<%=WI.getStrValue(WI.fillTextValue("list_size"), "4")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','list_size');loadLoanList();" size="4"
			onKeyUp="AllowOnlyInteger('form_','list_size');"></td>
    </tr>
		<%if(bolHasTeam){%>
		
		<%}%>
    
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%"><a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a><font size="1">click 
        to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#000000"></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0 ){%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="18"><div align="right"><font size="2"> Number of Employees / rows Per 
          Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 5; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
  </table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="5">&nbsp;</td>
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
		//strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), true);
		boolean bolIs2ndPeriodOnly = false;
		
		for(j = 0; j < vPeriods.size(); j+=5){
			//bolIs2ndPeriodOnly = false;
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
 		%>	
    <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
		<%}%>
	<td width="17%" align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dLineTotal, true)%>&nbsp;</td>
    </tr>
  <%}%>
</table>
<%} // if (vRetResult != null && vRetResult.size() > 0 )%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>