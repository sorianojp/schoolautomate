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

//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./monthly_total_per_office_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Remittances-Premium Per Office (Total)","monthly_total_per_office.jsp");

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
														"monthly_total_per_office.jsp");
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

String strPremiumType = WI.getStrValue(WI.fillTextValue("premium_type"),"0");
String strPremiumName = "";
if(strPremiumType.equals("1")){
	strPremiumName = "SSS";
}else{
	strPremiumName = "Philhealth";
}

double dTemp = 0d;
int i = 0;

double dEEGrandTotal = 0d;
double dERGrandTotal = 0d;
double dECGrandTotal = 0d;
double dGrandTotal = 0d;
double dLineTotal = 0d;
String strEmployer  = null;

if(WI.fillTextValue("searchEmployee").equals("1"))
  vRetResult = PRRemit.generatePerOfficeMonthlyRemitances(dbOP);

if(vRetResult == null)
	strErrMsg = PRRemit.getErrMsg();
else
	iSearchResult = PRRemit.getSearchCount();
%>

<body class="bgDynamic">
<form name="form_" method="post" action="monthly_total_per_office.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: <%=(strPremiumName).toUpperCase()%> PREMIUM MONTHLY REMITTANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="5"><font size="1"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="23" colspan="5" style="color:#FF0000;font-size:14px;"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Month and Year </td>
      <td colspan="3"> <select name="month_of">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select></td>
    </tr>
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><select name="pt_ft" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select></td>
    </tr>	
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3"><select name="employee_category" onChange="ReloadPage();">                    
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("employee_category").equals("0")){%>
		  <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>          
          <%}else if (WI.fillTextValue("employee_category").equals("1")){%>
		  <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>          
          <%}else{%>
		  <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>          
          <%}%>
        </select> </td>
    </tr>
	<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Employer name </td>
      <td colspan="3"><select name="employer_index" onChange="ReloadPage();">
        <%
strEmployer = WI.fillTextValue("employer_index");
boolean bolIsDefEmployer = false;
java.sql.ResultSet rs = null;
strTemp = "select employer_index,employer_name,is_default from pr_employer_profile where is_del = 0 order by is_default desc";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	strTemp = rs.getString(1);
	if(strEmployer.length() == 0 || strEmployer.equals(strTemp)) {
		strErrMsg = " selected";
		if(rs.getInt(3) == 1)
			bolIsDefEmployer = true;
		if(strEmployer.length() == 0)
			strEmployer = strTemp;
	}
	else	
		strErrMsg = "";
		
%>
        <option value="<%=strTemp%>" <%=strErrMsg%>><%=rs.getString(2)%></option>
        <%}
rs.close();
%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><%if(bolIsSchool){%>
        College
          <%}else{%>
          Division
      <%}%></td>
      <td colspan="3"><select name="c_index" onChange="ReloadPage();">
        <option value="">N/A</option>
        <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	

if(bolIsDefEmployer)
	strTemp = " from college where is_del= 0 and not exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index <>"+strEmployer+")";
else
	strTemp = " from college where is_del= 0 and exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index ="+strEmployer+")";
%>
        <%=dbOP.loadCombo("c_index","c_name", strTemp,strCollegeIndex,false)%>
      </select></td>
    </tr>
		<%if(strCollegeIndex.length() == 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"><select name="d_index" onChange="ReloadPage();">
        <option value="">N/A</option>
        <% 
if(bolIsDefEmployer)
	strTemp = " from department where is_del= 0 and (c_index is null or c_index = 0) and not exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.d_index = department.d_index and employer_index <>"+strEmployer+")";
else
	strTemp = " from department where is_del= 0 and (c_index is null or c_index = 0) and exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.d_index = department.d_index and employer_index ="+strEmployer+")";
%>
        <%=dbOP.loadCombo("d_index","d_name", strTemp,WI.fillTextValue("d_index"),false)%>
      </select></td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Remittance for : </td>
			<%
				strPremiumType = WI.fillTextValue("premium_type");
			%>
	    <td colspan="3">
			<select name="premium_type" onChange="ReloadPage();">
        <option value="0">Philhealth</option>
        <%if(strPremiumType.equals("1")){%>
        <option value="1" selected>SSS</option>
        <%}else{%>
        <option value="1">SSS</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%" colspan="3">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font>			</td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>
	<%if (vRetResult != null && vRetResult.size() > 0){%>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td><hr size="1" color="#000000"></td>
      </tr>
      <tr>
        <td height="18"><div align="right"><font><a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
      </tr>
    </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
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
				strTemp = (String)vRetResult.elementAt(i+2);
				if(strTemp == null)
					strTemp = (String)vRetResult.elementAt(i+3);
				else if(vRetResult.elementAt(i+3) != null)
					strTemp = strTemp +"-"+(String)vRetResult.elementAt(i+3);
					 
				
				//strTemp = WI.getStrValue(strTemp, (String)vRetResult.elementAt(i+2));
			%>
			<td><font size="1">&nbsp;<%=WI.getStrValue(strTemp)%></font> </td>
		<%	dTemp = 0d;
			strTemp = (String)vRetResult.elementAt(i+4);
			strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");
	
			dTemp = Double.parseDouble(strTemp);	
			if(!WI.fillTextValue("premium_type").equals("1"))	
				dLineTotal += dTemp;
			dEEGrandTotal += dTemp;
		%>
			<td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
		<%	dTemp = 0d;
			strTemp = (String)vRetResult.elementAt(i+5);
			strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");
	
			dTemp = Double.parseDouble(strTemp);		
			dLineTotal += dTemp;
			dERGrandTotal += dTemp;
		%>	
			<td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
		<%	dTemp = 0d;
			strTemp = (String)vRetResult.elementAt(i+6);
			strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");
	
			dTemp = Double.parseDouble(strTemp);		
			dLineTotal += dTemp;
			dECGrandTotal += dTemp;
		%>	
			<%if(WI.fillTextValue("premium_type").equals("1")){%>
			<td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
			<%}%>
		<%
			dGrandTotal+= dLineTotal;
		%>
			<td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"")%>&nbsp;</font></div></td>
		</tr>
		<%}// first For loop%>  
		
		<tr>
			<td>&nbsp;</td>
			<td><div align="right"><strong>TOTAL </strong></div></td>
			<td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dEEGrandTotal,true),"")%>&nbsp;</div></td>
			<td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dERGrandTotal,true),"")%>&nbsp;</div></td>
			<%if(WI.fillTextValue("premium_type").equals("1")){%>
			<td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dECGrandTotal,true),"")%>&nbsp;</div></td>
			<%}%>
			<td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dGrandTotal,true),"")%>&nbsp;</div></td>
		</tr>
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