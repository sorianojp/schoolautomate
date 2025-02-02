<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TD.thinborderBottomLeft {
    border-left: solid 1px #FFFFFF;
    border-bottom: solid 1px #FFFFFF;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBottomLeftRight {
	border-left: solid 1px #FFFFFF;
	border-right: solid 1px #FFFFFF;
    border-bottom: solid 1px #FFFFFF;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;
}
TR.BottomBorder{
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
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

<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,payroll.ReportPayroll,hr.HRInfoPersonalExtn,
								java.util.Vector" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
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
      <td height="25" colspan="2"><div align="center"><font size="1"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          Office of the Treasurer</font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="2"><div align="center"><font color="#000000" size="1" ><strong>Schedule 
          7.1 Alphalist of Employees Terminated before December 31 (Reported under 
          Form 2316)</strong></font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="23" colspan="2"><div align="center"><font size="1">Form 
          Whom Taxes Have Been Witheld for the Taxable Year <%=WI.fillTextValue("taxable_year")%></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><font size="3"><b><%=WI.getStrValue(strErrMsg)%> </b></font></td>
    </tr>

  </table>
<%if (vRetResult != null && vRetResult.size() > 0){%>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="14" colspan="18">&nbsp;</td>
    </tr>
    <tr> 
      <td class="thinborderBottomLeft" height="14" colspan="6">&nbsp;</td>
      <td class="thinborderBottomLeft" colspan="3"><div align="center"><font size="1">.......... 
          NON - TAXABLE..........</font></div></td>
      <td class="thinborderBottomLeft" colspan="2"><div align="center"><font size="1">..... 
          TAXABLE .....</font></div></td>
      <td class="thinborderBottomLeft" colspan="4">&nbsp;</td>
      <td class="thinborderBottomLeft" colspan="2"><div align="center"><font size="1">Year-end 
          Adjustment</font></div></td>
      <td width="6%" rowspan="2" valign="bottom" class="thinborderBottom" ><div align="right">Amount 
          of Tax Withheld as Adjusted</div></td>
    </tr>
    <tr> 
      <td width="5%" height="14" valign="bottom" class="thinborderBottom"><div align="center">TIN</div></td>
      <td width="6%" valign="bottom" class="thinborderBottom" ><div align="left">Last Name</div></td>
      <td width="6%" valign="bottom" class="thinborderBottom" ><div align="left">First Name</div></td>
      <td width="6%" valign="bottom" class="thinborderBottom" ><div align="left">Middle Name</div></td>
      <td width="4%" valign="bottom" class="thinborderBottom" ><div align="left">Date of Employment</div></td>
      <td width="4%" valign="bottom" class="thinborderBottom" ><div align="left">Date of Discharged</div></td>
      <td width="6%" valign="bottom" class="thinborderBottom" ><div align="right">13th Month &amp; 
          Other Benefits</div></td>
      <td width="6%" valign="bottom" class="thinborderBottom" ><div align="right">SSS, PHIC, Pag-Ibig 
          and Union Dues</div></td>
      <td width="5%" valign="bottom" class="thinborderBottom" ><div align="right">Salaries &amp; 
          Other Compensation</div></td>
      <td width="5%" valign="bottom" class="thinborderBottom" ><div align="right">13th Month &amp; 
          Other Benefits</div></td>
      <td width="6%" valign="bottom" class="thinborderBottom" ><div align="right">Salaries COLA 
          &amp; Others</div></td>
      <td width="6%" valign="bottom" class="thinborderBottom" ><div align="right">Amount of Exemption</div></td>
      <td width="5%" valign="bottom" class="thinborderBottom" ><div align="right">Health &amp; 
          Hospital Premium</div></td>
      <td width="6%" valign="bottom" class="thinborderBottom" ><div align="right">Tax Due<br>
          (Jan-Dec)</div></td>
      <td width="6%" valign="bottom" class="thinborderBottom" ><div align="right">Tax Witheld 
          (Jan-Nov)</div></td>
      <td width="5%" valign="bottom" class="thinborderBottom" ><div align="right">Tax Witheld 
          (Dec)</div></td>
      <td width="6%" valign="bottom" class="thinborderBottom" ><div align="right">Tax Refund to 
          Employees</div></td>
    </tr>
    <%for(int i = 0; i < vRetResult.size(); i +=17){%>
    <tr> 
      <td height="14" class="thinborderBottomLeft"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td class="thinborderBottomLeft"><%=WI.getStrValue((String)vRetResult.elementAt(i),"&nbsp;")%></td>
      <td class="thinborderBottomLeft"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
      <td class="thinborderBottomLeft"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td class="thinborderBottomLeft"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td class="thinborderBottomLeft"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td class="thinborderBottomLeft"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+13),"&nbsp;"),true)%>&nbsp;</div></td>
      <td class="thinborderBottomLeft"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+6),"&nbsp;"),true)%>&nbsp;</div></td>
      <td class="thinborderBottomLeft"><div align="right">0.00</div></td>
      <td class="thinborderBottomLeft"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+14),"&nbsp;"),true)%></div></td>
      <td class="thinborderBottomLeft"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+7),"&nbsp;"),true)%></div></td>
      <td class="thinborderBottomLeft"><div align="right"><%=WI.getStrValue((Double)vRetResult.elementAt(i+8),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborderBottomLeft"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+9),"&nbsp;"),true)%>&nbsp;</div></td>
      <td class="thinborderBottomLeft"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+10),"&nbsp;"),true)%>&nbsp;</div></td>
      <td class="thinborderBottomLeft"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+11),"&nbsp;"),true)%>&nbsp;</div></td>
      <td class="thinborderBottomLeft"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+12),"&nbsp;"),true)%>&nbsp;</div></td>
      <td class="thinborderBottomLeft"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+15),"&nbsp;"),true)%>&nbsp;</div></td>
      <td class="thinborderBottomLeftRight"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+16),"&nbsp;"),true)%>&nbsp;</div></td>
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