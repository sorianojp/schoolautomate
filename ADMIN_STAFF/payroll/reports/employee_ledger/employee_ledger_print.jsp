<%@ page language="java" import="utility.*,payroll.ReportPayroll,hr.HRInfoPersonalExtn,
								java.util.Vector,java.sql.ResultSet,java.sql.SQLException" buffer="16kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Ledger Printing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style  type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }
	
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
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
<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
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
								"Admin/staff-Payroll-REPORTS-Employee Ledger","employee_ledger.jsp");
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
	
		ResultSet rs;
	Vector vGroupedMiscDed      = new Vector();//holds the list of all misc deduction and there corresponding group
	Vector vGroupedMiscDedTotal = new Vector();//holds the misc group and the amount
	String strSchCode = dbOP.getSchoolIndex();
    if(strSchCode == null)
      strSchCode = "";
	int iIndexOf = 0;  
	String strTempMisc = null;
	String strSQLQuery = "select PRE_DEDUCT_NAME,PR_GROUP_MAP.GROUP_NAME from PR_GROUP_MAP " +
					  " join PRELOAD_DEDUCTION on (PRELOAD_DEDUCTION.PRE_DEDUCT_INDEX = MISC_DED_INDEX) ";
	try{		
		//get all the misc deduction and there  corresponding group
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()){
			vGroupedMiscDed.addElement(rs.getString(1));//[0]ded_name
			vGroupedMiscDed.addElement(rs.getString(2));//[1]group_name
		}
		
		//gets all the distict group name
		strSQLQuery = "select distinct(group_name) from PR_GROUP_MAP";
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()){
			vGroupedMiscDedTotal.addElement(rs.getString(1));//[0]group_name
			vGroupedMiscDedTotal.addElement("0");//[1]total
		}	
		
	 } catch (SQLException sqlE) {
        strErrMsg = "Error in connection. Please try again.";       
        System.out.println(strSQLQuery);
        sqlE.printStackTrace();
        return;
     }
	
	
	
	

	Vector vPersonalDetails = new Vector(); 
	Vector vPersonalData    = null;
	
	ReportPayroll rptLedger = new ReportPayroll(request);	
	HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
	
	Vector vRetResult = null;
	Vector vIncentives = null;
	Vector vLoansAdv  = null;
	Vector vMiscDed  = null;
	Vector vOtherBenefit = null;
	Vector vMiscEarnings = null;
	String strEmpID = WI.fillTextValue("emp_id");	
	
	int j = 1;
	double dTemp = 0d;
	
	double dTotalBasic = 0d;
	double dTotalExtra = 0d;
	double dTotalHonorarium = 0d; 
	double dTotalHoliday = 0d;
	double dTotalOT = 0d;
	double dTotalNDiff = 0d;
	double dTotalCola = 0d;
	double dTotalOtherEarn = 0d;
	double dTotalGross = 0d;
	double dTotalAbsences = 0d;
	double dTotalLateUt = 0d;
	double dTotalLWOP = 0d;
	double dTotalTax = 0d;
	double dTotalSSS = 0d;
	double dTotalPhealth = 0d;
	double dTotalHdmf = 0d;
	double dTotalBen = 0d;
	double dTotalLoanAdv = 0d;
	double dTotalMisc = 0d;
	double dTotalDed = 0d;
	double dTotalAdj = 0d;
	double dTotalNet = 0d;
	
	double dTaxableEarn = 0d;
	double dNonTaxableEarn = 0d;
	double dTotalTaxable = 0d;
	double dTotalNonTaxable = 0d;
	boolean bolSplitEarning = WI.fillTextValue("split_earning").equals("1");	
	
	if (strEmpID.length() > 0){
		vRetResult = rptLedger.searchEmployeeLedger(dbOP);
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
		vPersonalData = hrPx.operateOnPersonalData(dbOP,request,0);	
	}
%>

<form name="form_" action="employee_ledger.jsp">
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%">Payroll Year</td>
			<%
			if(WI.fillTextValue("start_year").equals(WI.fillTextValue("end_year"))){
				strTemp = WI.fillTextValue("start_year");
			}else{
				strTemp = WI.fillTextValue("start_year") + "-" + WI.fillTextValue("end_year");
			}
			%>
      <td colspan="3"><%=strTemp%></td>
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
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#FFFFFF">
      <td rowspan="3" align="center" class="thinborderHeader"><strong>PAYROLL 
        SCHEDULE</strong></td>
      <td rowspan="3" align="center" class="thinborderHeader">BASIC 
        SALARY<br>
        (period)</td>
      <td align="center" class="thinborderHeader">Addl. Comp. </td>
      <td rowspan="3" align="center" class="thinborderHeader">Incentives / Honorarium / Allowances </td>
      <td colspan="4" rowspan="2" align="center" class="thinborderHeader">A D D I T I O N A L </td>
      <td rowspan="3" align="center" class="thinborderHeader">Other earnings </td>
      <td rowspan="3" align="center" class="thinborderHeader">Gross 
        Salary<br>
        (period)<br>      </td>
      <td height="25" colspan="10" align="center" class="thinborderHeader"><strong>D E D U C T I O N S </strong></td>
      <td rowspan="3" align="center" class="thinborderHeader">Total 
        Deductions (period)</td>
      <td rowspan="3" align="center" class="thinborder"><font size="1">Adjust</font></td>
      <td rowspan="3" align="center" class="thinborderHeader">NET 
        SALARY<br>
        (period) </td>
    </tr>
    <tr>
      <td align="center" class="thinborderHeader">PART-TIME/<br>
        EXTRA 
        LOAD</td>
      <td rowspan="2" align="center" class="thinborderHeader">Absences</td>
      <td rowspan="2" align="center" class="thinborderHeader">Late/ 
        UT</td>
      <td rowspan="2" align="center" class="thinborderHeader">Leave 
        w/out pay</td>
      <td height="33" rowspan="2" align="center" class="thinborderHeader"> W/ Holding Tax</td>
      <td rowspan="2" align="center" class="thinborderHeader">SSS</td>
      <td rowspan="2" align="center" class="thinborderHeader">PHIC</td>
      <td rowspan="2" align="center" class="thinborderHeader">PAG-IBIG</td>
      <td rowspan="2" align="center" class="thinborderHeader">Benefits /
        Prem.</td>
      <td rowspan="2" align="center" class="thinborderHeader">Loans 
        / Advances</td>
      <td rowspan="2" align="center" class="thinborderHeader">Misc. Deductions</td>
    </tr>
    <tr class="thinborder">
      <td height="27" align="center" class="thinborderHeader">Salary Equiv.</td>
      <td align="center" class="thinborderHeader">Holiday</td>
      <td align="center" class="thinborderHeader">Overtime</td>
      <td align="center" class="thinborderHeader">Night Diff</td>
      <td align="center" class="thinborderHeader">COLA</td>
    </tr>
    <%if (vRetResult != null && vRetResult.size() > 0)
		for(int i = 0;i <  vRetResult.size();i+=39){				
		 vIncentives = (Vector) vRetResult.elementAt(i+33);		 
		 vLoansAdv = (Vector) vRetResult.elementAt(i+34);	 
		 vMiscDed = (Vector) vRetResult.elementAt(i+35);
		 vOtherBenefit = (Vector) vRetResult.elementAt(i+36);	
		 vMiscEarnings = (Vector) vRetResult.elementAt(i+37);	
		 
		 //this is for misc_ded groupings
		 if(vGroupedMiscDedTotal != null && vGroupedMiscDedTotal.size() > 0){
			 for(int m = 0; m < vGroupedMiscDedTotal.size() ; m+=2 )
			 	vGroupedMiscDedTotal.setElementAt("0",m+1);//initialize back to 0
		 }		 
	%>
    <tr class="thinborder">
      <td height="25" class="thinborder"><div align="center"> <%=WI.getStrValue((String)vRetResult.elementAt(i + 23),"0")%> - <%=WI.getStrValue((String)vRetResult.elementAt(i + 24),"0")%> </div></td>
      <%
			dTemp = 0d;
			strTemp = (String)vRetResult.elementAt(i);			
			dTemp = Double.parseDouble(strTemp);
			dTotalBasic += dTemp;
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</td>
			<%
				dTemp = 0d;
				// ADDL_RESP_AMT
				strTemp = (String)vRetResult.elementAt(i+7);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				// overload_amt
				strTemp = (String)vRetResult.elementAt(i+38);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				strTemp = CommonUtil.formatFloat(dTemp, 2);
				dTotalExtra +=  dTemp;
				if(dTemp == 0d)
					strTemp = "";
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				strTemp2 = null;
			 if(WI.fillTextValue("is_detailed").length() > 0){				   
			  /* This is the old emp_ledger.print code but it has outOfBOunds.
			  so, i just copy the code from emp_ledger.jsp 
			  for(j = 1; j < vIncentives.size();j+=2){			   			 
					 strTemp = WI.getStrValue((String)vIncentives.elementAt(j),"");
					 if(strTemp2 == null){
						 strTemp2 = WI.getStrValue((String)vIncentives.elementAt(j+1),""," :: " + strTemp,"");
					 }else{
						 strTemp2 += WI.getStrValue((String)vIncentives.elementAt(j+1),"<br>"," :: " + strTemp,"");
					 }					 
				 }*/				
				 for(j = 3; j < vIncentives.size();j+=3){
				 	strTemp = "";
				 	if(((String)vIncentives.elementAt(j+2)).equals("1"))
						strTemp = "*";
					 strTemp += WI.getStrValue((String)vIncentives.elementAt(j),"");
					 if(strTemp2 == null){
						 strTemp2 = WI.getStrValue((String)vIncentives.elementAt(j+1),""," :: " + strTemp,"");
					 }else{
						 strTemp2 += WI.getStrValue((String)vIncentives.elementAt(j+1),"<br>"," :: " + strTemp,"");
					 }					 
				 }
				
			 }else{
	 	    strTemp2 =(String)vIncentives.elementAt(0);
		   }
			 	strTemp = (String)vIncentives.elementAt(0);
				dTemp = Double.parseDouble(strTemp);
				if(dTemp == 0d)
					strTemp2 = "-";
				dTotalHonorarium += dTemp;
			 %>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp2)%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 5), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalHoliday += dTemp;
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalOT += dTemp;
			
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 6), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalNDiff += dTemp;
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 8), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalCola += dTemp;
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
				dTemp = 0d;
				// ADDL_PAYMENT_AMT
				strTemp = (String)vRetResult.elementAt(i + 10);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				// ADHOC_BONUS
				strTemp = (String)vRetResult.elementAt(i + 11);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));

				// substitute_sal
				strTemp = (String)vRetResult.elementAt(i + 26);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				// faculty_salary
				strTemp = (String)vRetResult.elementAt(i + 27);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				// fac_allowance
				strTemp = (String)vRetResult.elementAt(i + 30);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				// put here
				// kay dili na taxable ang tax refund... 
				dTaxableEarn = dTemp;	
				
				// tax_refund
				strTemp = (String)vRetResult.elementAt(i + 32);
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				dNonTaxableEarn = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				
				strTemp = (String)vMiscEarnings.elementAt(0);
				dTemp += Double.parseDouble(strTemp);

				if(bolSplitEarning){
					if(vMiscEarnings != null && vMiscEarnings.size() > 0){
						dTaxableEarn += Double.parseDouble((String)vMiscEarnings.elementAt(1));
						dNonTaxableEarn += Double.parseDouble((String)vMiscEarnings.elementAt(2));
					}	
					strTemp = "**" +CommonUtil.formatFloat(dTaxableEarn,true);
					strTemp += "<br>" +CommonUtil.formatFloat(dNonTaxableEarn,true) +"";
				}else{
					strTemp = CommonUtil.formatFloat(dTemp,true);
					if(dTemp <= 0d)
						strTemp = "-";
				}
					
				dTotalTaxable += dTaxableEarn;
				dTotalNonTaxable += dNonTaxableEarn;
									
				dTotalOtherEarn += dTemp;
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 1), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalGross += dTemp;
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 9), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalAbsences += dTemp;
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 13), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalLateUt += dTemp;
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 12), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalLWOP += dTemp;
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 19), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalTax += dTemp;
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 16), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalSSS += dTemp;
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>			
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 17), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalPhealth += dTemp;
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 18), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalHdmf += dTemp;
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>			
			<%
				strTemp2 = null;
			 if(WI.fillTextValue("is_detailed").length() > 0){
			   for(j = 1; j < vOtherBenefit.size();j+=2){
					 strTemp = WI.getStrValue((String)vOtherBenefit.elementAt(j),"");
					 if(strTemp2 == null){
						 strTemp2 = WI.getStrValue((String)vOtherBenefit.elementAt(j+1),""," :: " + strTemp,"");
					 }else{
						 strTemp2 += WI.getStrValue((String)vOtherBenefit.elementAt(j+1),"<br>"," :: " + strTemp,"");
					 }					 
				 }
			 }else{
	 	    strTemp2 =(String)vOtherBenefit.elementAt(0);
		   }
			 	strTemp = (String)vOtherBenefit.elementAt(0);
				dTemp = Double.parseDouble(strTemp);
				if(dTemp == 0d)
					strTemp2 = "-";
				dTotalBen += dTemp;
			 %>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp2)%></td>
			<%
				strTemp2 = null;
			 if(WI.fillTextValue("is_detailed").length() > 0){
			   for(j = 1; j < vLoansAdv.size();j+=2){
					 strTemp = WI.getStrValue((String)vLoansAdv.elementAt(j),"");
					 if(strTemp2 == null){
						 strTemp2 = WI.getStrValue((String)vLoansAdv.elementAt(j+1),""," :: " + strTemp,"");
					 }else{
						 strTemp2 += WI.getStrValue((String)vLoansAdv.elementAt(j+1),"<br>"," :: " + strTemp,"");
					 }					 
				 }
			 }else{
	 	    strTemp2 =(String)vLoansAdv.elementAt(0);
		   }
			 	strTemp = (String)vLoansAdv.elementAt(0);
				dTemp = Double.parseDouble(strTemp);
				if(dTemp == 0d)
					strTemp2 = "-";
				dTotalLoanAdv += dTemp;
			 %>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp2)%></td>
			<%
				strTemp2 = null;
			 if(WI.fillTextValue("is_detailed").length() > 0){
			   for(j = 1; j < vMiscDed.size();j+=2){
			   		  //FATIMA wants to view misc ded by group.sul10172012
				  if(vGroupedMiscDedTotal != null && vGroupedMiscDedTotal.size() > 0 && vGroupedMiscDed != null && vGroupedMiscDed.size() > 0){	
					  strTempMisc =  WI.getStrValue((String)vMiscDed.elementAt(j+1),"dummyStrOnly@123");
					  iIndexOf = vGroupedMiscDed.indexOf(strTempMisc);
					  if( iIndexOf != -1){//misc has group
						//get the group name
						strTempMisc = (String)vGroupedMiscDed.elementAt(iIndexOf+1);							
						iIndexOf = 	vGroupedMiscDedTotal.indexOf(strTempMisc);		
						if(iIndexOf != -1){
							dTemp = Double.parseDouble(WI.getStrValue((String)vGroupedMiscDedTotal.elementAt(iIndexOf+1),"0")) + Double.parseDouble(WI.getStrValue((String)vMiscDed.elementAt(j),"0"));								
							vGroupedMiscDedTotal.setElementAt(""+dTemp,iIndexOf+1);//initialize back to 0								
						}//end of index_of group total
					  }//end of index_of list misc_ded
				  }else{//end of if vGroupedMiscDedTotal != null			   
					 strTemp = WI.getStrValue((String)vMiscDed.elementAt(j),"");
					 if(strTemp2 == null){
						 strTemp2 = WI.getStrValue((String)vMiscDed.elementAt(j+1),""," :: " + strTemp,"");
					 }else{
						 strTemp2 += WI.getStrValue((String)vMiscDed.elementAt(j+1),"<br>"," :: " + strTemp,"");
					 }			
					}//end of else 		 
				 }//end of loop
				  //im gonna format the groupname
				 if(vGroupedMiscDedTotal != null && vGroupedMiscDedTotal.size() > 0 && vGroupedMiscDed != null && vGroupedMiscDed.size() > 0){	
				  	strTemp2 = null;	
					dTemp = 0;
					 for(j = 0; j < vGroupedMiscDedTotal.size();j+=2){
						strTemp = WI.getStrValue((String)vGroupedMiscDedTotal.elementAt(j+1),"");
						if(Double.parseDouble(strTemp) == 0)							
							continue;										
						 dTemp += Double.parseDouble(strTemp);	
						 if(strTemp2 == null){
							 strTemp2 = WI.getStrValue((String)vGroupedMiscDedTotal.elementAt(j),""," :: " + strTemp,"");
						 }else{
							 strTemp2 += WI.getStrValue((String)vGroupedMiscDedTotal.elementAt(j),"<br>"," :: " + strTemp,"");
						 }			
				  	}//end of for loop	
					//add the other miscDeduction
					if(Double.parseDouble((String)vMiscDed.elementAt(0)) > 0){
						dTemp = Double.parseDouble((String)vMiscDed.elementAt(0)) - dTemp;
						if(dTemp > 0){//if there are misc_ded w/o group
							 if(strTemp2 == null)
								 strTemp2 = "Others <br>::" + dTemp;	
							 else
								 strTemp2 += "<br> Others <br>::" + dTemp;
						}	
					}
				 }//end of formatting..if vGroupedMiscDedTotal != null && ..
				 
			 }else{
	 	    strTemp2 =(String)vMiscDed.elementAt(0);
		   }
			 	strTemp = (String)vMiscDed.elementAt(0);
				dTemp = Double.parseDouble(strTemp);
				if(dTemp == 0d)
					strTemp2 = "-";
				dTotalMisc += dTemp;
			 %>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp2)%></td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 25), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalDed += dTemp;
			%>				
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 20), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalAdj += dTemp;
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 2), true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp == 0d)
				strTemp = "";
			dTotalNet += dTemp;
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
    </tr>
    <%}// end for loop%>
    <tr class="thinborder">
      <td height="14" class="thinborder">&nbsp;</td>
			

 

      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalBasic,true)%>&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalExtra ,true)%>&nbsp;</td>
      <td align="right" valign="top" class="thinborder"><%=CommonUtil.formatFloat(dTotalHonorarium,true)%>&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalHoliday,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalOT,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalNDiff,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalCola,true)%></td>
			<%
			if(bolSplitEarning){
				strTemp = "**" +CommonUtil.formatFloat(dTotalTaxable,true);
				strTemp += "<br>" +CommonUtil.formatFloat(dTotalNonTaxable,true) +"";				
			}else{
				strTemp = CommonUtil.formatFloat(dTotalOtherEarn,true);
			}
			%>				
      <td align="right" class="thinborder"><%=strTemp%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalGross,true)%></td>
      <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dTotalAbsences,true)%></td>
      <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dTotalLateUt,true)%></td>
      <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dTotalLWOP,true)%></td>
      <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dTotalTax,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalSSS,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalPhealth,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalHdmf,true)%></td>
      <td align="right" valign="top" class="thinborder"><%=CommonUtil.formatFloat(dTotalBen,true)%></td>
      <td align="right" valign="top" class="thinborder"><%=CommonUtil.formatFloat(dTotalLoanAdv,true)%></td>
      <td align="right" valign="top" class="thinborder"><%=CommonUtil.formatFloat(dTotalMisc,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalDed,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalAdj,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalNet,true)%> </td>
    </tr>
    <tr class="thinborder">
      <td height="14" width="5%">&nbsp;</td>
      <td width="5%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="5%" valign="top">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="4%" >&nbsp;</td>
      <td width="4%" >&nbsp;</td>
      <td width="4%" >&nbsp;</td>
      <td width="4%" >&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="5%" valign="top">&nbsp;</td>
      <td width="5%" valign="top">&nbsp;</td>
      <td width="5%" valign="top">&nbsp;</td>
      <td width="5%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="5%"></td>
    </tr>
  </table>
  <%}// end main checking if (vRetResult != null && vRetResult.size() > 0)%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="viewonly" value="<%=WI.fillTextValue("viewonly")%>">
	<input type="hidden" name="search_employee">
  <input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>