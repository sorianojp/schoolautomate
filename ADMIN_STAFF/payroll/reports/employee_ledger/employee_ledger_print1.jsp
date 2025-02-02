<%@ page language="java" import="utility.*,payroll.ReportPayroll,hr.HRInfoPersonalExtn,
								java.util.Vector" buffer="16kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Ledger Printout</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style  type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;	
    }
	
    TD.thinborderNONE {
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;
    }
	TD.thinborderHeader {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 9px;
    }
	
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>

<body onLoad="javascript:window.print();">
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
								"Admin/staff-Payroll-REPORTS-Print Ledger","employee_ledger_print.jsp");
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

	Vector vPersonalDetails = new Vector(); 
	Vector vPersonalData    = null;

	String strEmpID = WI.fillTextValue("emp_id");
	ReportPayroll rptLedger = new ReportPayroll(request);	
	Vector vRetResult = null;
	Vector vIncentives = null;
	Vector vLoansAdv  = null;
	Vector vMiscDed  = null;
	Vector vOtherBenefit = null;
	double dTemp = 0d;
	int j = 0;

	HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
	int iColsSpan = 0;

	if (strEmpID.length() > 0){
		vRetResult = rptLedger.searchEmployeeLedger(dbOP);
		enrollment.Authentication authentication = new enrollment.Authentication();
	    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
		vPersonalData = hrPx.operateOnPersonalData(dbOP,request,0);	
	}
%>

<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="5"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%">Payroll Year</td>
      <td colspan="3"><%=WI.fillTextValue("start_year")%></td>
    </tr>
    <tr> 
      <td colspan="5"> <hr size="1"></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20" colspan="4">Employee Name : 
        <% if (vPersonalDetails != null && vPersonalDetails.size() > 0 ) {%> <%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
				(String)vPersonalDetails.elementAt(3), 4)%> <%}%> </td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <%	
		if (vPersonalData!= null && vPersonalData.size() > 0 ) {			
			strTemp = (String)vPersonalData.elementAt(4);
		}else{
			strTemp = null;	
		}			
		%>
      <td height="20" colspan="3">SSS No. : &nbsp;<%=WI.getStrValue(strTemp,"")%></td>
      <%	
		if (vPersonalDetails!= null && vPersonalDetails.size() > 0 ) {			
			strTemp = (String)vPersonalDetails.elementAt(16);
		}else{
			strTemp = null;	
		}			
		%>
      <td width="58%" height="20">Employment Status : <%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <%	
		if (vPersonalData!= null && vPersonalData.size() > 0 ) {			
			strTemp = (String)vPersonalData.elementAt(5);
		}else{
			strTemp = null;	
		}			
		%>
      <td height="20" colspan="3">TIN No. : <%=WI.getStrValue(strTemp,"")%></td>
      <%	
		if (vPersonalDetails!= null && vPersonalDetails.size() > 0 ) {			
			strTemp = (String)vPersonalDetails.elementAt(15);
		}else{
			strTemp = null;	
		}			
		%>
      <td height="20">Employment Type/Position : <%=WI.getStrValue(strTemp,"")%></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20" colspan="4"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Department: 
        <%if(vPersonalDetails != null && vPersonalDetails.size() > 0){%> 
        <%if(vPersonalDetails.elementAt(13) != null){%> 
        <%=(String)vPersonalDetails.elementAt(13)%> ; 
        <%}if(vPersonalDetails.elementAt(14) != null){%> 
        <%=(String)vPersonalDetails.elementAt(14)%> 
        <%}%> 
      <%}%> </td>
    </tr>
  </table>
	
  <table width="107%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFFF">
      <td rowspan="3" class="thinborderHeader"><div align="center"><strong>PAYROLL 
        SCHEDULE</strong></div></td>
      <td rowspan="3" class="thinborderHeader"><div align="center">BASIC 
        SALARY<br>
        (period)</div></td>
      <td class="thinborderHeader"><div align="center">Addl. Comp. </div></td>
      <td rowspan="3" class="thinborderHeader"><div align="center">Incentives / Honorarium / Allowances </div></td>
      <td colspan="4" rowspan="2" class="thinborderHeader"><div align="center">A D D I T I O N A L </div></td>
      <td rowspan="3" class="thinborderHeader"><div align="center">Other earnings </div></td>
      <td rowspan="3" class="thinborderHeader"><div align="center">Gross 
        Salary<br>
        (period)<br>
      </div></td>
      <td height="25" colspan="10" class="thinborderHeader"><div align="center"><strong>D E D U C T I O N S </strong></div></td>
      <td rowspan="3" class="thinborderHeader"><div align="center">Total 
        Deductions (period)</div></td>
      <td rowspan="3" class="thinborder"><div align="center"><font size="1">Adjust</font></div></td>
      <td rowspan="3" class="thinborderHeader"><div align="center">NET 
        SALARY<br>
        (period) </div></td>
    </tr>
    <tr>
      <td class="thinborderHeader"><div align="center">PART-TIME/<br>
        EXTRA 
        LOAD</div></td>
      <td rowspan="2" class="thinborderHeader"><div align="center">Absences</div></td>
      <td rowspan="2" class="thinborderHeader"><div align="center">Late/ 
        UT</div></td>
      <td rowspan="2" class="thinborderHeader"><div align="center">Leave 
        w/out pay</div></td>
      <td height="33" rowspan="2" class="thinborderHeader"><div align="center"> W/ Holding Tax</div></td>
      <td rowspan="2" class="thinborderHeader"><div align="center">SSS</div></td>
      <td rowspan="2" class="thinborderHeader"><div align="center">PHIC</div></td>
      <td rowspan="2" class="thinborderHeader"><div align="center">PAG-IBIG</div></td>
      <td rowspan="2" class="thinborderHeader"><div align="center">Benefits /
        Prem.</div></td>
      <td rowspan="2" class="thinborderHeader"><div align="center">Loans 
        / Advances</div></td>
      <td rowspan="2" class="thinborderHeader"><div align="center">Misc. Deductions</div></td>
    </tr>
    <tr class="thinborder">
      <td height="27" class="thinborderHeader"><div align="center">Salary Equiv.</div></td>
      <td class="thinborderHeader"><div align="center">Holiday</div></td>
      <td class="thinborderHeader"><div align="center">Overtime</div></td>
      <td class="thinborderHeader"><div align="center">Night Diff</div></td>
      <td class="thinborderHeader"><div align="center">COLA</div></td>
    </tr>
    <%if (vRetResult != null && vRetResult.size() > 0)
		for(int i = 0;i <  vRetResult.size();i+=39){				
		 vIncentives = (Vector) vRetResult.elementAt(i+33);		 
		 vLoansAdv = (Vector) vRetResult.elementAt(i+34);	 
		 vMiscDed = (Vector) vRetResult.elementAt(i+35);
		 vOtherBenefit = (Vector) vRetResult.elementAt(i+36);	
	%>
    <tr class="thinborder">
      <td height="25" class="thinborder" width="5%"><div align="center"> <font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 23),"0")%></font> - <font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 24),"0")%></font> </div></td>
      <td class="thinborder" width="5%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i),"0")%></font>&nbsp;</div></td>
			<%
				dTemp = 0d;
				strTemp = (String)vRetResult.elementAt(i+7);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				strTemp = (String)vRetResult.elementAt(i+38);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				strTemp = CommonUtil.formatFloat(dTemp, 2);
				if(dTemp == 0d)
					strTemp = "";
			%>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"&nbsp;")%></font></div></td>
      <td class="thinborder" width="5%"><div align="right">
          <%
			 if(WI.fillTextValue("is_detailed").length() > 0){
			   for(j = 1; j < vIncentives.size();j+=2){%>
          <font size="1"><%=WI.getStrValue((String)vIncentives.elementAt(j+1),"0")%> :: <%=WI.getStrValue((String)vIncentives.elementAt(j),"0")%> <br>
          </font>
          <%}
			 }else{%>
          <%=(String)vIncentives.elementAt(0)%>
          <%}%>
        &nbsp;</div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"0")%>&nbsp;</font></div></td>
      <%
				dTemp = 0d;
				// ADDL_PAYMENT_AMT
				strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i + 10),",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				// ADHOC_BONUS
				strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i + 11),",","");
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// substitute_sal
				strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i + 26),",","");
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				// faculty_salary
				strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i + 27),",","");
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				// fac_allowance
				strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i + 30),",","");
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				// tax_refund
				strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i + 32),",","");
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
			%>
      <td class="thinborder" width="4%"><div align="right"><%=dTemp%>&nbsp;</div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 1),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 9),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 13),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 12),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 19),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 16),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 17),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 18),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="5%"><div align="right">
          <% 
			 if(WI.fillTextValue("is_detailed").length() > 0){
			   for(j = 1; j < vOtherBenefit.size();j+=2){%>
          <font size="1"><%=WI.getStrValue((String)vOtherBenefit.elementAt(j + 1),"0")%> :: <%=WI.getStrValue((String)vOtherBenefit.elementAt(j),"0")%></font> <br>
          <%}
					}else{%>
          <%=(String)vOtherBenefit.elementAt(0)%>
          <%}%>
        &nbsp;</div></td>
      <td class="thinborder" width="5%"><div align="right">
          <% 
			if(WI.fillTextValue("is_detailed").length() > 0){
			  for(j = 1; j < vLoansAdv.size();j+=2){%>
          <font size="1"><%=WI.getStrValue((String)vLoansAdv.elementAt(j + 1),"&nbsp;")%> :: <%=WI.getStrValue((String)vLoansAdv.elementAt(j),"0")%></font> <br>
          <%}
					}else{%>
          <%=(String)vLoansAdv.elementAt(0)%>
          <%}%>
        &nbsp;</div></td>
      <td class="thinborder" width="5%"><div align="right">
          <% 
			if(WI.fillTextValue("is_detailed").length() > 0){
			  for(j = 1; j < vMiscDed.size();j+=2){%>
          <font size="1"><%=WI.getStrValue((String)vMiscDed.elementAt(j + 1),"0")%> :: <%=WI.getStrValue((String)vMiscDed.elementAt(j),"0")%> </font> <br>
          <%}
				}else{%>
          <%=(String)vMiscDed.elementAt(0)%>
          <%}%>
        &nbsp;</div></td>
      <td class="thinborder" width="5%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 25),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="4%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 20),"0")%>&nbsp;</font></div></td>
      <td class="thinborder" width="5%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"0")%>&nbsp;</font></div></td>
    </tr>
    <%}// end for loop%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>