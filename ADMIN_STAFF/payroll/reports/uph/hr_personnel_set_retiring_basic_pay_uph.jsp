<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoServiceRecord"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
 TD{
 	font-size: 11px;
 }
</style>
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage(strValue) {	
	document.form_.view_result.value= strValue;
	document.form_.submit();
}

function PrintPage(){
	var loadPg = "./hr_personnel_set_retiring_basic_pay_uph_print.jsp?month_of="+document.form_.month_of.value+
		"&year_of="+document.form_.year_of.value+
		"&multiplier="+document.form_.multiplier.value+
		"&num_rec_page="+document.form_.num_rec_page.value;
	var win=window.open(loadPg,"PrintPage",'dependent=yes,width=850,height=900,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
//add security hehol.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation();		
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}

hr.HRRetirementMgmt retMgmt = new hr.HRRetirementMgmt();

Vector vRetResult = null;
int iElemCount = 0;

if(WI.fillTextValue("view_result").length() > 0){
	vRetResult = retMgmt.getRetirementContributionSummary(dbOP, request);
	if(vRetResult == null)
		strErrMsg = retMgmt.getErrMsg();
	else
		iElemCount = retMgmt.getElemCount();
}
double dMultiplier = Double.parseDouble(WI.getStrValue(WI.fillTextValue("multiplier"),".0325"));

%>

<body bgcolor="#FFFFFF">
<form action="./hr_personnel_set_retiring_basic_pay_uph.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EMPLOYEE RETIREMENT REPORT PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="30" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>  
  </table>

 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Month and Year </td>
      <td> <select name="month_of" onChange="ReloadPage('')">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="ReloadPage('')">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),5,1)%> 
        </select></td>
    </tr>    
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="image" src="../../../../images/form_proceed.gif" onClick="javascript:ReloadPage('1');"></td>
    </tr>
    <tr> 
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
  </table>
  
<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	    <td align="right" height="25">
		Number of Employees / rows Per 
          Page :
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( int i = 5; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
		
		<a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>
		</td>
	    </tr>
	<tr><td align="center" height="25"><strong>SUMMARY OF RETIREMENT CONTRIBUTION</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="6%" height="20" align="center" class="thinborder">No.</td>
		<td width="13%" align="center" class="thinborder">EMPLOYEE ID</td>
		<td width="19%" align="center" class="thinborder">LAST NAME</td>
		<td width="16%" align="center" class="thinborder">FIRST NAME</td>
		<td width="19%" align="center" class="thinborder">MIDDLE NAME</td>
		<td width="15%" align="center" class="thinborder">BASIC PAY</td>
		<td width="12%" align="center" class="thinborder">AMOUNT</td>
	</tr>
<%
double dGrandTotal = 0d;
double dTemp = 0d;
int iCount = 0;
for(int i =0 ; i < vRetResult.size(); i+=iElemCount){%>
	<tr>
	    <td align="right" class="thinborder" height="20"><%=++iCount%>.&nbsp;</td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i))%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3)).toUpperCase()%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+1)).toUpperCase()%></td>
	    <td class="thinborder"><%=WI.getStrValue(WI.getStrValue(vRetResult.elementAt(i+2)).toUpperCase(),"&nbsp;")%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+4);
		dTemp  = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));		
		%>
	    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTemp,true)%></td>
		<%
		dTemp = dTemp * dMultiplier;
		
		dGrandTotal += dTemp;
		%>
	    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTemp,true)%></td>
	</tr>
	
<%}%>
	<tr>
	    <td height="20" colspan="6" align="right" class="thinborder"><strong>GRAND TOTAL</strong> &nbsp;</td>
	    <td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(dGrandTotal,true)%></strong></td>
	    </tr>
</table>
<%}%>

<input type="hidden" name="view_result">
<input type="hidden" name="multiplier" value="<%=dMultiplier%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
