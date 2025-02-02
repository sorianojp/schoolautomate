<%@ page language="java" import="utility.*,payroll.ReportPayroll,hr.HRInfoPersonalExtn,
								java.util.Vector" buffer="16kb"%>
<%
boolean bolHasConfidential = false;

String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
								
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function ViewList()
{
	document.form_.print_page.value="";
}

function FocusYear() {
	document.form_.taxable_year.focus();
}
</script>

<body bgcolor="#FFFFFF" onLoad="FocusYear();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./report_schedule74old_print.jsp" />
<% return;}

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
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-TAX Schedules-Schedule7.4","report_schedule74.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");								
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
	int iDefault  = 0;
		
	if ((WI.fillTextValue("taxable_year")).length() > 0){
		vRetResult = rptLedger.generateSchedule74(dbOP);
	}else{
		strErrMsg="Enter Payroll Year";
	}
%>

<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="2"><font size="1"><a href="alphalist_main.jsp"><img src="../../../../images/go_back.gif" border="0" ></a></font></td>
    </tr>
    <tr > 
      <td height="25" colspan="2" align="center"><font color="#000000" size="1" ><strong>Schedule 
          7.4 Alphalist of Employees as of December 31 with Previous Employers 
      within the year(Reported under Form 2316)</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="2" align="center"><font size="1">From Whom 
      Taxes Have Been Withheld for the Taxable Year </font></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><font size="3"><b><%=WI.getStrValue(strErrMsg)%> </b></font></td>
    </tr>
    <tr> 
      <td width="14%">Payroll Year</td>
      <td width="86%"><input name="taxable_year" type="text" size="6" maxlength="4" value="<%=WI.fillTextValue("taxable_year")%>"
	  onKeyUp="AllowOnlyInteger('form_','taxable_year');" style="text-align: right"
	  onBlur="AllowOnlyInteger('form_','taxable_year');style.backgroundColor='white'"></td>
    </tr>
		<%if(bolHasConfidential){%>
    <tr>
      <td>Show Option</td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";
			%>	
      <td><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
		<%}%>
    <tr> 
      <td>&nbsp;</td>
      <td>
      <!--
			  <input name="image" type="image" src="../../../../images/form_proceed.gif" img>
			-->
			<input type="submit" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewList();">      </td>
    </tr>
    <tr> 
      <td height="10" colspan="2"> <hr size="1"></td>
    </tr>
  </table>
<%if (vRetResult != null && vRetResult.size() > 1){%>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="30"><div align="right">
          <div align="left"></div>
          <div align="right">Number of Employees Per Page: 
            <select name="num_stud_page">
              <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"1"));
				for(int i = 20; i <= 45 ; i++) {
					if ( i == iDefault) {%>
              <option selected value="<%=i%>"><%=i%></option>
              <%}else{%>
              <option value="<%=i%>"><%=i%></option>
              <%}}%>
            </select>
            <a href="javascript:PrintPg();"> <img src="../../../../images/print.gif" border="0"></a> 
            <font size="1">click to print list</font></div>
        </div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="20" colspan="4">&nbsp;</td>
      <td colspan="12" align="center"><font size="1">GROSS COMPENSATION INCOME</font></td>
      <td colspan="5">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="20" colspan="4">&nbsp;</td>
      <td colspan="6" align="center"><font size="1">PREVIOUS EMPLOYER</font></td>
      <td colspan="6" align="center"><font size="1">PRESENT EMPLOYER</font></td>
      <td colspan="5">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="20" colspan="4">&nbsp;</td>
      <td colspan="3" align="center"><font size="1">...... NON - TAXABLE......</font></td>
      <td colspan="3" align="center"><font size="1">...... TAXABLE ......</font></td>
      <td colspan="3" align="center"><font size="1">.......... NON - TAXABLE..........</font></td>
      <td colspan="3" align="center"><font size="1">.... TAXABLE....</font></td>
      <td colspan="5">&nbsp;</td>
      <td colspan="2"><div align="center"><font size="1">Year-end Adjustment</font></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="14" rowspan="2" style="font-size: 9px;"><font size="1">TIN</font></td>
      <td width="3%" rowspan="2" ><font size="1">Last Name</font></td>
      <td width="3%" rowspan="2" ><font size="1">First Name</font></td>
      <td width="3%" rowspan="2" ><font size="1">Middle Name</font></td>
      <td width="4%" rowspan="2" align="right" ><font size="1">13th Month 
        &amp; Other Benefits</font></td>
      <td width="4%" rowspan="2" align="right" ><font size="1">SSS, PHIC, 
        Pag-Ibig and Union Dues</font></td>
      <td width="6%" rowspan="2" align="right" ><font size="1">Salaries &amp; 
        Other Comp</font></td>
      <td width="4%" rowspan="2" align="right" ><font size="1">13th Month 
        &amp; Other Benefits</font></td>
      <td width="4%" rowspan="2" align="right" ><font size="1">Salaries COLA 
        &amp; Others</font></td>
      <td width="5%" rowspan="2" align="right" ><font size="1">Total Taxable 
        (Prev Employer)</font></td>
      <td width="4%" rowspan="2" align="right" ><font size="1">13th Month &amp; Other Benefits</font></td>
      <td width="5%" rowspan="2" align="right" ><font size="1">SSS, PHIC,Pag-Ibig and Union 
        Dues</font></td>
      <td width="7%" rowspan="2" align="right" ><font size="1">Salaries &amp; Other Compensation</font></td>
      <td width="4%" rowspan="2" align="right" ><font size="1">13th Month &amp; Other Benefits</font></td>
      <td width="4%" rowspan="2" align="right" ><font size="1">Salaries COLA &amp; Others</font></td>
      <td width="5%" rowspan="2" align="right" ><font size="1">Total Taxable (Prev &amp; Present 
        Employer)</font></td>
      <td width="5%" rowspan="2" align="right" ><font size="1">Amount of 
        Exemption</font></td>
      <td width="4%" rowspan="2" ><div align="right"><font size="1">Health &amp; 
          Hospital Premium</font></div></td>
      <td width="3%" rowspan="2" ><div align="right"><font size="1">Tax Due (Jan-Dec)</font></div></td>
      <td colspan="2" ><div align="center"><font size="1">Tax Witheld<br>
          (Jan-Nov)</font> </div>      </td>
      <td width="4%" rowspan="2" ><div align="right"><font size="1">Tax Witheld 
          (Dec)</font></div></td>
      <td width="5%" rowspan="2" ><div align="right"><font size="1">Tax Refund 
          to Employees</font></div></td>
      <td width="4%" rowspan="2" ><div align="right"><font size="1">Amount of 
          Tax Withheld as Adjusted</font></div></td>
    </tr>
    <tr> 
      <td width="4%" ><font size="1">Previous Employer</font></td>
      <td width="4%" ><font size="1">Present Employer</font></td>
    </tr>
    <%for(int i = 1; i < vRetResult.size(); i +=23){%>
    <tr> 
      <td height="14" style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i),"&nbsp;")%></td>
      <td style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
      <td style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+5),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+4),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+6),"&nbsp;"),true)%></div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+7),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+8),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+9),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+18),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+10),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right">0.00&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+18),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+11),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+20),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+12),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+13),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+14),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+15),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+16),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+17),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+21),"&nbsp;"),true)%>&nbsp;</div></td>
      <td style="font-size: 9px;"><div align="right"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(i+22),"&nbsp;"),true)%>&nbsp;</div></td>
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