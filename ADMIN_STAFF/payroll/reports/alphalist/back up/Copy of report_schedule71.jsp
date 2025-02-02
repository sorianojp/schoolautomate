<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

</script>

<body bgcolor="#FFFFFF">
<%@ page language="java" import="utility.*,payroll.ReportPayroll,hr.HRInfoPersonalExtn,
								java.util.Vector" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./report_schedule71_print.jsp" />
<% return;}

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-DTR"),"0"));
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
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Tax Schedule7.1","report_schedule71.jsp");
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

	if ((WI.fillTextValue("taxable_year")).length() > 0){
		vRetResult = rptLedger.generateSchedule71(dbOP);
	}else{
		strErrMsg="Enter Payroll Year";
	}
%>

<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="2"><font size="1"><a href="../alphalist_main.htm"><img src="../../../../../images/go_back.gif" border="0" ></a></font></td>
    </tr>
    <tr > 
      <td height="25" colspan="2"><div align="center"><font color="#000000" size="1" ><strong>Schedule 
          7.1 Alphalist of Employees Terminated before December 31 (Reported under 
          Form 2316)</strong></font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="2"><div align="center"><font size="1">Form Whom 
          Taxes Have Been Witheld for the Taxable Year </font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><font size="3"><b><%=WI.getStrValue(strErrMsg)%> </b></font></td>
    </tr>
    <tr> 
      <td width="14%">Payroll Year</td>
      <td width="86%"><input name="taxable_year" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("taxable_year")%>"
	  onKeyUp="AllowOnlyFloat('form_','taxable_year');" 
	  onBlur="AllowOnlyFloat('form_','taxable_year');style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><font size="3"><b> 
        <input name="image" type="image" src="../../../../../images/form_proceed.gif" img>
        </b></font></td>
    </tr>
    <tr> 
      <td height="10" colspan="2"> <hr size="1"></td>
    </tr>
  </table>
<%if (vRetResult != null && vRetResult.size() > 0){%>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="30"><div align="right"><a href="javascript:PrintPg()"><img src="../../../../../images/print.gif" border="0"></a>
          <font size="1">click to print</font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="14" colspan="6">&nbsp;</td>
      <td colspan="3"><div align="center"><font size="1">.......... NON - TAXABLE..........</font></div></td>
      <td colspan="2"><div align="center"><font size="1">...... TAXABLE ......</font></div></td>
      <td colspan="4">&nbsp;</td>
      <td colspan="2"><div align="center"><font size="1">Year-end Adjustment</font></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="7%" height="14" style="font-size: 9px;"><font size="1">TIN</font></td>
      <td width="6%" ><font size="1">Last Name</font></td>
      <td width="6%" ><font size="1">First Name</font></td>
      <td width="6%" ><font size="1">Middle Name</font></td>
      <td width="4%" ><font size="1">Date of Employment</font></td>
      <td width="4%" ><font size="1">Date of Discharged</font></td>
      <td width="6%" ><div align="right"><font size="1">13th Month &amp; Other 
          Benefits</font></div></td>
      <td width="6%" ><div align="right"><font size="1">SSS, PHIC,Pag-Ibig and 
          Union Dues</font></div></td>
      <td width="6%" ><div align="right"><font size="1">Salaries &amp; Other Compensation</font></div></td>
      <td width="6%" ><div align="right"><font size="1">13th Month &amp; Other 
          Benefits</font></div></td>
      <td width="6%" ><div align="right"><font size="1">Salaries COLA &amp; Others</font></div></td>
      <td width="5%" ><div align="right"><font size="1">Amount of Exemption</font></div></td>
      <td width="6%" ><div align="right"><font size="1">Health &amp; Hospital 
          Premium</font></div></td>
      <td width="6%" ><div align="right"><font size="1">Tax Due (Jan-Dec)</font></div></td>
      <td width="6%" ><div align="right"><font size="1">Tax Witheld (Jan-Nov)</font></div></td>
      <td width="5%" ><div align="right"><font size="1">Tax Witheld (Dec)</font></div></td>
      <td width="6%" ><div align="right"><font size="1">Tax Refund to Employees</font></div></td>
      <td width="6%" ><div align="right"><font size="1">Amount of Tax Withheld 
          as Adjusted</font></div></td>
    </tr>
    <%for(int i = 0; i < vRetResult.size(); i +=17){%>
    <tr> 
      <td height="14" style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i),"&nbsp;")%></td>
      <td style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
      <td style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+13),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+6),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right">0.00</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+14),"&nbsp;"),true)%></div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+7),"&nbsp;"),true)%></div></td>
      <td style="font-size: 9px;"><div align="right"><%=WI.getStrValue((Double)vRetResult.elementAt(i+8),"&nbsp;")%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+9),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+10),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+11),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+12),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+15),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+16),"&nbsp;"),true)%>&nbsp;</div></td>
    </tr>
    <%}%>
  </table>
  <%}// end main checking if (vRetResult != null && vRetResult.size() > 0)%>
<input type="hidden" name="print_page">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>