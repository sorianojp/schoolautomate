<%@ page language="java" import="utility.*,payroll.PRTaxReport,hr.HRInfoPersonalExtn,
								java.util.Vector" buffer="16kb"%>
<%
boolean bolHasConfidential = false;
String[] strColorScheme = CommonUtil.getColorScheme(6);
WebInterface WI = new WebInterface(request);
//strColorScheme is never null. it has value always.
%>								
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Report Schedule 7.2</title>
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
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
	}	
	
	TD.headerWithBorderRight {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
	
	TD.headerWithBorder {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
	
  TD.header {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }

  TD.headerNoBorder {
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
		
  TD.thinborderTOP {
    border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }
	
  TD.NoBorder {
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }	
	
  TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }
	
  TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
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
	this.SubmitOnce("form_");
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

//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./report_schedule72_print.jsp" />
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
								"Admin/staff-Payroll-REPORTS-Tax Schedule7.2","report_schedule72.jsp");
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
	Vector vRetResult  = null;
	int iDefault  = 0;
	int i = 0;
	double dTemp = 0d;
	int iIndexOf = 0;
	Vector vExemptCodes = new Vector();
	
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
		//vRetResult = rptLedger.generateSchedule723(dbOP,2);
		vRetResult = rptLedger.generateSchedule71(dbOP, request, 2);
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
      <td height="25" colspan="2"><div align="center"><font color="#000000" size="1" ><strong>Schedule 
          7.2 Alphalist of Employees whose Compensation Income are Exempt from 
          withholding Tax but subject to Income Tax (Reported Under Form 2316)</strong></font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="2">&nbsp;</td>
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
        <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewList();"></td>
    </tr>
    <tr> 
      <td height="10" colspan="2"> <hr size="1"></td>
    </tr>
  </table>
<%if (vRetResult != null && vRetResult.size() > 1){%>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="30">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("font_size");
				if(strTemp.length() == 0)
					strTemp = "10";
			%>			
      <td align="right"><font size="2">Font size of details:
          <select name="font_size">
            <%for(i = 8; i < 13; i++){%>
            <%if(strTemp.equals(Integer.toString(i))){%>
            <option value="<%=i%>" selected><%=i%> px</option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> px</option>
            <%}
						}%>
          </select>
      </font></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("size_header");
				if(strTemp.length() == 0)
					strTemp = "10";
			%>			
      <td align="right"><font size="2">Font size of header:
          <select name="size_header">
            <%for(i = 8; i < 13; i++){%>
            <%if(strTemp.equals(Integer.toString(i))){%>
            <option value="<%=i%>" selected><%=i%> px</option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> px</option>
            <%}
						}%>
          </select>
      </font></td>
    </tr>
    <tr> 
			<%
				strTemp = WI.fillTextValue("BIR_format");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td width="39%" height="30"> 
        <input type="checkbox" name="BIR_format" value="1" onClick="ViewList();" <%=strTemp%>>
     Show BIR Format</td>
      <td width="61%" align="right">Number of Employees Per Page: 
        <select name="num_stud_page">
          <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"1"));
				for(i = 15; i <= 45 ; i++) {
					if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select> <a href="javascript:PrintPg();"> <img src="../../../../images/print.gif" border="0"></a> 
        <font size="1">click to print list</font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="3%" rowspan="3" align="center" class="headerWithBorder">TIN</td>
      <td height="14" colspan="3" align="center" class="headerWithBorder">NAME OF EMPLOYEES</td>
      <td colspan="8" align="center" class="headerWithBorder">GROSS COMPENSATION INCOME</td>
      <td colspan="2" rowspan="2" align="center" class="headerWithBorder">EXEMPTION</td>
      <td width="6%" rowspan="3" align="center" class="headerWithBorder">Premium Paid on Health and/or Hospital Insurance </td>
      <td width="6%" rowspan="3" align="center" class="headerWithBorder">Net Taxable Compensation Income</td>
      <td width="7%" rowspan="3" align="center" class="headerWithBorder">Tax 
      Due </td>
      <%if(WI.fillTextValue("BIR_format").length() == 0){%>
			<td align="center" class="headerWithBorder">&nbsp;</td>
      <td colspan="2" align="center" class="headerWithBorder">&nbsp;</td>
      <td align="center" class="headerWithBorder">&nbsp;</td>
			<%}%>
    </tr>
    <tr> 
      <td width="6%" rowspan="2" align="center" class="headerWithBorder">Last Name</td>
      <td width="6%" rowspan="2" align="center" class="headerWithBorder"><font size="1">First Name</font></td>
      <td width="6%" rowspan="2" align="center" class="headerWithBorder">Middle Name</td>
      <td width="6%" rowspan="2" align="center" class="headerWithBorder">Gross Compensation Income</td>
      <td height="14" colspan="4" align="center" class="headerWithBorder">  NON - TAXABLE </td>
      <td width="6%" rowspan="2" align="center" class="headerWithBorder">Total Non-Taxable/Exempt Compensation Income </td>
      <td colspan="2" align="center" class="headerWithBorder">  TAXABLE </td>
      <%if(WI.fillTextValue("BIR_format").length() == 0){%>
			<td align="center" class="headerWithBorder">&nbsp;</td>
      <td colspan="2" align="center" class="headerWithBorder">Year-end Adjustment</td>
      <td align="center" class="headerWithBorder">&nbsp;</td>
			<%}%>
    </tr>
    <tr>
      <td width="6%" height="14" align="center" class="headerWithBorder" >13th 
        Month Pay &amp; Other Benefits</td>
      <td width="6%" align="center" class="headerWithBorder" >De Minimis Benefits </td>
      <td width="6%" align="center" class="headerWithBorder" >SSS, 
        GSIS, PHIC,Pag-Ibig Contributions and Union Dues</td>
      <td width="6%" align="center" class="headerWithBorder" >Salaries 
        &amp; Other Forms of Compensation</td>
      <td width="6%" align="center" class="headerWithBorder" >Basic Salary </td>
      <td width="6%" align="center" class="headerWithBorder" >Salaries &amp; Other Forms of Compensation </td>
      <td width="6%" align="center" class="headerWithBorder" >Code</td>
      <td width="6%" align="center" class="headerWithBorder" >Amount</td>
			<%if(WI.fillTextValue("BIR_format").length() == 0){%>
      <td width="6%" align="center" class="headerWithBorder" >Tax 
        Witheld (Jan-Nov)</td>
      <td width="6%" align="center" class="headerWithBorder" >Tax 
        Witheld (Dec)</td>
      <td width="6%" align="center" class="headerWithBorder" >Tax 
        Refund to Employees</td>
      <td width="6%" align="center" class="headerWithBorder" >Amount 
        of Tax Withheld as Adjusted</td>
				<%}%>
    </tr>
    <%for(i = 0; i < vRetResult.size(); i += 58){%>
    <tr> 
      <td height="14" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+10), true)%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+27), true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
				if(dTemp <= 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+28), true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
				if(dTemp <= 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+29), true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
				if(dTemp <= 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				dTemp = Double.parseDouble((String)vRetResult.elementAt(i+22));
				strTemp = (String)vRetResult.elementAt(i+23);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+24);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+25);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+26);
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+30);
				dTemp += Double.parseDouble(strTemp);
			%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTemp, true)%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+11), true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
				if(dTemp <= 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+31), true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
				if(dTemp <= 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(i+57), "0.00"), true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
				if(dTemp <= 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+48);
 				iIndexOf = vExemptCodes.indexOf(strTemp);
				if(iIndexOf != -1){
					strTemp = (String) vExemptCodes.elementAt(iIndexOf+1);
				}else{
					strTemp = "n/a";
				}
			%>
      <td height="14" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+15), true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
				if(dTemp <= 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+16), true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
				if(dTemp <= 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+17), true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
				if(dTemp <= 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+18);				
			%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%if(WI.fillTextValue("BIR_format").length() == 0){%>
			<%
				strTemp = (String)vRetResult.elementAt(i+46);
				dTemp = Double.parseDouble(strTemp);			
			%>	
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+47);
				dTemp += Double.parseDouble(strTemp);
			%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+49), true);
				strTemp = ConversionTable.replaceString(strTemp, ",","");
				dTemp -= Double.parseDouble(strTemp);
			%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTemp, true)%></td>
			<%}%>
    </tr>
    <%}%>
  </table>
  <%}// end main checking if (vRetResult != null && vRetResult.size() > 0)%>
<input type="hidden" name="print_page">
<input type="hidden" name="encoding_type" value="1"> 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>