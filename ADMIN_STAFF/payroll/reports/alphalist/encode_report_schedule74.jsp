<%@ page language="java" import="utility.*,payroll.ReportPayroll,hr.HRInfoPersonalExtn,
								java.util.Vector" buffer="16kb"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Encode Report Schedule 7.4</title>
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
<script language="JavaScript">
function ViewList()
{
	document.form_.print_page.value="";
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function PrevSal(strEmpID,strUserIndex){
	var pgLoc = "emp_prev_salary.jsp?emp_id="+strEmpID+"&year_of="+document.form_.taxable_year.value+
							"&user_index="+strUserIndex+"&encoding_type=1";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=510,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function FocusYear() {
	document.form_.taxable_year.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="javascript:FocusYear();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

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
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Previous Salary Encoding","encode_report_schedule74.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}

	ReportPayroll rptLedger = new ReportPayroll(request);	
	int iColsSpan = 0;
	Vector vRetResult  = null;
	double dTaxRefund = 0d;
	double dTaxWitheld = 0d;
	
	
	if ((WI.fillTextValue("taxable_year")).length() == 4){
		vRetResult = rptLedger.getEmpWithPrevEmployer(dbOP);
		if(vRetResult == null || vRetResult.size() == 0){
			strErrMsg= rptLedger.getErrMsg();
		}
	}else{
		strErrMsg="Enter valid payroll year";
	}
%>

<form name="form_">
  <table width="100%" height="119" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="23" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF"><strong>:::: PAYROLL: ENCODING 
        PREVIOUS SALARY DETAILS ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><font size="1"><a href="alphalist_main.jsp"><img src="../../../../images/go_back.gif" border="0" ></a></font><font size="3"><b><%=WI.getStrValue(strErrMsg)%> </b></font></td>
    </tr>
    <tr> 
      <td width="14%" height="22">Payroll Year</td>
      <td width="86%"><input name="taxable_year" type="text" size="6" maxlength="4" value="<%=WI.fillTextValue("taxable_year")%>"
	  onKeyUp="AllowOnlyInteger('form_','taxable_year');" style="text-align: right"
	  onBlur="AllowOnlyInteger('form_','taxable_year');style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>
        <!--
				<input name="image" type="image" src="../../../../images/form_proceed.gif" img>
				-->
				<input type="submit" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewList();">				
      </td>
    </tr>
    <tr> 
      <td height="14" colspan="2"> <hr size="1"></td>
    </tr>
  </table>
<%if (vRetResult != null && vRetResult.size() > 0){%>	
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="28" colspan="4" bgcolor="#B9B292"><strong>EMPLOYEES WITH PREVIOUS 
        EMPLOYER FOR THE YEAR <%=WI.fillTextValue("taxable_year")%> </strong></td>
    </tr>
    <tr bgcolor="#ffff99">
      <td width="6%">&nbsp;</td>
      <td width="24%" height="24">&nbsp;&nbsp;<strong>TIN</strong></td>
      <td width="51%" >&nbsp;&nbsp;<strong>Employee Name</strong></td>
      <td width="19%">&nbsp;</td>
    </tr>
    <%int iCount = 1;			
	for(int i = 0; i < vRetResult.size(); i +=8,iCount++){
	%>
    <tr>
      <td>&nbsp;<%=iCount%></td>
      <td height="28">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
      <td>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+2)).toUpperCase(), (String)vRetResult.elementAt(i+3),
							(WI.getStrValue((String)vRetResult.elementAt(i+4))).toUpperCase(), 4)%></td>
      <td><div align="center"><a href='javascript:PrevSal("<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"0")%>","<%=WI.getStrValue((String)vRetResult.elementAt(i),"0")%>")'><img src="../../../../images/update.gif" width="60" height="26" border="0"></a></div></td>
    </tr>
    <%}%>
  </table>
  <%}// end main checking if (vRetResult != null && vRetResult.size() > 0)%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="20" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="20" colspan="3" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
 
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>