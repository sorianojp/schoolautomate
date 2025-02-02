<%@ page language="java" import="utility.*,payroll.PRTaxReport,hr.HRInfoPersonalExtn,
								java.util.Vector" buffer="16kb"%>
<%
boolean bolHasConfidential = false;

String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
								
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Report Schedule 7.4</title>
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
td{
	font-size:9px
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
	<jsp:forward page="./report_schedule74_print.jsp" />
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

	PRTaxReport rptLedger = new PRTaxReport();	
	int iColsSpan = 0;
	int iDefault  = 0;
	Vector vRetResult  = null;
 	Vector vEmpTaxCodes = null;
	Vector vExemptCodes = new Vector();
	Vector vPrevEmpSal = null;
	int iIndexOf = 0;
	double dTemp = 0d;
	double dNonTaxable = 0d;
	double dPrevTaxable = 0d;
	
	vExemptCodes.addElement("0");	vExemptCodes.addElement("Z");
	vExemptCodes.addElement("1");	vExemptCodes.addElement("S");
	vExemptCodes.addElement("2");	vExemptCodes.addElement("HF");
	vExemptCodes.addElement("21"); vExemptCodes.addElement("HF1");
	vExemptCodes.addElement("22"); vExemptCodes.addElement("HF2");
	vExemptCodes.addElement("23"); vExemptCodes.addElement("HF3");
	vExemptCodes.addElement("24"); vExemptCodes.addElement("HF4");			
	vExemptCodes.addElement("3");	vExemptCodes.addElement("ME");
	vExemptCodes.addElement("31"); vExemptCodes.addElement("ME1");
	vExemptCodes.addElement("32"); vExemptCodes.addElement("ME2");
	vExemptCodes.addElement("33"); vExemptCodes.addElement("ME3");
	vExemptCodes.addElement("34"); vExemptCodes.addElement("ME4");	


	if ((WI.fillTextValue("taxable_year")).length() > 0){
		vRetResult = rptLedger.generateSchedule71(dbOP, request, 4);
	}else{
		strErrMsg = " Enter Payroll Year";
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
        Taxes Have Been Withheld for the Taxable Year</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><font size="3"><b><%=WI.getStrValue(strErrMsg)%> </b></font></td>
    </tr>
    <tr> 
      <td width="14%"><font size="2">Payroll Year</font></td>
      <td width="86%"><input name="taxable_year" type="text" size="6" maxlength="4" value="<%=WI.fillTextValue("taxable_year")%>"
	  onKeyUp="AllowOnlyInteger('form_','taxable_year');" style="text-align: right"
	  onBlur="AllowOnlyInteger('form_','taxable_year');style.backgroundColor='white'"></td>
    </tr>
		<%if(bolHasConfidential){%>
    <tr>
      <td><font size="2">Show Option</font></td>
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
      </select>
        <%
				strTemp = WI.fillTextValue("include_mwe");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
        <input type="checkbox" name="include_mwe" value="1" <%=strTemp%>>
Include Minimum wage Earners</td>
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
      <td width="100%" height="30" align="right"><font size="2">Number of Employees Per Page: </font>
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
        click to print list
			</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td width="7%" rowspan="4">SEQ<br>
      NO</td>
      <td width="7%" rowspan="4">TIN</td>
      <td height="14" colspan="3">NAME OF EMPLOYEES </td>
      <td colspan="15" align="center">GROSS COMPENSATION INCOME </td>
    </tr>
    <tr>
      <td width="6%" rowspan="3" align="center">Last Name</td>
      <td width="6%" rowspan="3" align="center">First Name</td>
      <td width="6%" rowspan="3" align="center">Middle Name</td>
      <td width="6%" rowspan="3" align="center">Gross Compensation Income</td>
      <td height="14" colspan="9" align="center">PREVIOUS EMPLOYER </td>
      <td colspan="5" align="center">PRESENT EMPLOYER </td>
    </tr>
    <tr> 
      <td height="14" colspan="5" align="center"><font size="1"> NON - TAXABLE</font></td>
      <td colspan="4" align="center"><font size="1"> TAXABLE </font></td>
      <td colspan="5" align="center"><font size="1"> NON - TAXABLE</font></td>
    </tr>
    <tr>
      <td height="14" align="center" >13th Month &amp; Other 
        Benefits</td>
      <td align="center" >De Minimis Benefits </td>
      <td align="center" >SSS, GSIS, PHIC,Pag-Ibig Contributions and 
        Union Dues</td>
      <td align="center" >Salaries &amp; Other Forms of Compensation</td>
      <td align="center">Total Non-Taxable/Exempt Compensation Income</td>
      <td width="6%" align="center" >Basic Salary </td>
      <td width="6%" align="center" >13th Month &amp; Other 
          Benefits</td>
      <td width="6%" align="center" >Salaries  &amp; Other Forms of Compensation </td>
      <td width="6%" align="center" >Total Taxable Compensation Income</td>
      <td height="14" align="center" >13th Month &amp; Other 
        Benefits</td>
      <td align="center" >De Minimis Benefits </td>
      <td align="center" >SSS, GSIS, PHIC,Pag-Ibig Contributions and 
        Union Dues</td>
      <td align="center" >Salaries &amp; Other Forms of Compensation</td>
      <td align="center">Total Non-Taxable/Exempt Compensation Income</td>
    </tr>
    <%
			int iCount = 1;
			for(int i = 0; i < vRetResult.size(); i +=58, iCount++){
			vPrevEmpSal = (Vector)vRetResult.elementAt(i+50);
		%>
    <tr>
      <td ><%=iCount%></td> 
      <td height="20"  nowrap><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td ><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td ><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td ><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td align="right" ><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+10), true)%></td>
			<%
				dNonTaxable = 0d;
				// non taxable bonus
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(1);
					dNonTaxable = Double.parseDouble(strTemp);
				}else
					strTemp = "";
			%>
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
			<%
				// de_minimis_
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(2);
					dNonTaxable += Double.parseDouble(strTemp);
				}else
					strTemp = "";
			%>
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
			<%
				// contributions
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(3);
					dNonTaxable += Double.parseDouble(strTemp);
				}else
					strTemp = "";
			%>			
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
			<%
				// non_taxable_salary
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(4);
					dNonTaxable += Double.parseDouble(strTemp);
				}else
					strTemp = "";
			%>	
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(dNonTaxable, true)%></td>
			<%
				// basic_salary
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(7);
					dPrevTaxable += Double.parseDouble(strTemp);
				}else
					strTemp = "";
			%>	
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
			<%
				// taxable_bonus
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(5);
					dPrevTaxable += Double.parseDouble(strTemp);
				}else
					strTemp = "";
			%>
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
			<%
				// taxable_sal
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(6);
					dPrevTaxable += Double.parseDouble(strTemp);
				}else
					strTemp = "";
			%>			
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+13),true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+27),true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+28),true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+29),true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+11),true)%></td>
    </tr>
    <%}%>
  </table>
  <br>
	<table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">    
    <tr>
      <td width="7%" rowspan="3" align="center" >SEQ<br>
      NO</td> 
      <td height="7" colspan="3" align="center" >PRESENT EMPLOYER </td>
      <td width="7%" rowspan="3" align="center" ><font size="1">Total  Compensation Present </font></td>
      <td width="7%" rowspan="3" align="center" >Total Taxable (Previous &amp; Present Employers) </td>
      <td height="7" colspan="2" rowspan="2" align="center" >EXEMPTION</td>
      <td width="6%" rowspan="3" align="center">Premium Paid on Health and/or Hospital Insurance</td>
      <td width="4%" rowspan="3" align="center">Net Taxable Compensation Income </td>
      <td width="4%" rowspan="3" align="center">Tax Due<br>
        (JAN. - DEC.)</td>
      <td width="6%" rowspan="3" align="center" >TAX WITHHELD<br>
        (JAN. - NOV.)</td>
      <td colspan="2" rowspan="2" align="center" >YEAR - END ADJUSTMENT</td>
      <td width="6%" rowspan="3" align="center" >Amount of Tax Withheld as Adjusted</td>
    </tr>
    <tr>
      <td height="7" colspan="3" align="center" >TAXABLE</td>
    </tr>
    <tr>
      <td width="3%" align="center" >Basic Salary </td>
      <td width="4%" align="center" >13th Month &amp; Other 
      Benefits</td>
      <td width="7%" align="center" >Salaries  &amp; Other Forms of Compensation </td>
      <td width="7%" height="7" align="center" >Code</td>
      <td width="6%" align="center" >Amount</td>
      <td width="6%" align="center" >AMOUNT WITHHELD AND PAID FOR IN DECEMBER</td>
      <td width="6%" align="center" >OVERWITHHELD TAX REFUNDED TO EMPLOYEE </td>
    </tr>
    <%
		iCount =1;
		for(int i = 0; i < vRetResult.size(); i +=58, iCount++){%>
    <tr>
      <td ><%=iCount%></td> 
			<td align="right" ><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+31),"&nbsp;"),true)%></td>
			<td align="right" ><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+41),"&nbsp;"),true)%></td>
			<%
				dTemp = Double.parseDouble((String)vRetResult.elementAt(i+32));
				strTemp = (String)vRetResult.elementAt(i+33);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+34);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+35);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+36);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+37);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+38);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+39);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+40);
				dTemp += Double.parseDouble(strTemp);
				
				strTemp = (String)vRetResult.elementAt(i+42);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+43);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+44);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+45);
				dTemp += Double.parseDouble(strTemp);
			%>
			<td align="right" ><%=CommonUtil.formatFloat(dTemp, true)%></td>
			<td align="right" ><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+12),"&nbsp;"),true)%></td>
			<td align="right" ><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+14),"&nbsp;"),true)%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+48);
				iIndexOf = vExemptCodes.indexOf(strTemp);
				if(iIndexOf != -1){
					strTemp = (String) vExemptCodes.elementAt(iIndexOf+1);
				}else{
					strTemp = "n/a";
				}
			%>
      <td height="14" >&nbsp;<%=WI.getStrValue(strTemp)%></td>
      <td align="right" ><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+15), true)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+16);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>
      <td align="right" ><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+17);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>			
      <td align="right" ><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+18);				
			%>
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+46);
				dTemp = Double.parseDouble(strTemp);			
			%>	
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+47);
				dTemp += Double.parseDouble(strTemp);
			%>
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+49);
				dTemp -= Double.parseDouble(strTemp);
			%>
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%></td>
			
      <td align="right" ><%=CommonUtil.formatFloat(dTemp, true)%></td>
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