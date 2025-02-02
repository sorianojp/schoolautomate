<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, 
																 payroll.PReDTRME, payroll.OvertimeMgmt" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;

WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
	}	
	
	TD.headerWithBorderRight {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>px;
  }
	
	TD.headerWithBorder {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>px;
  }
	
  TD.header {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>px;
  }

  TD.headerNoBorder {
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>px;
  }
		
  TD.thinborderTOP {
    border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
  }
	
  TD.NoBorder {
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
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
  TD.headerthinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>px;
	}
  
  
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<%

	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	int iIndexOf  = -1;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet","psheet_grouped.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");

		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");		
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
														"psheet_grouped.jsp");
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
//	OvertimeMgmt otMgmt = new OvertimeMgmt();
	OvertimeMgmt otMgmt = new OvertimeMgmt(dbOP, WI);
	String strPayrollPeriod  = null;	
	String strHourlyRate = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dDailyRate = 0d;
	
	int iFieldCount = 29;// number of fields in the vector..
	int iNumRec = 0; 
	
	double dTemp = 0d;
 	double dLineTotal = 0d;
	boolean bolPageBreak = false;
	boolean bolMoveNextPage = false;
	int i = 0;
	int iIndex = 0;	  
	Vector vRows = null;
	Vector vRetResult = null;
	Vector vAllowances = null;
	Vector vAllowanceNames = null;
	Vector vAllowanceGroupNames = null;
	Vector vEmpAllowance = null;
	Vector vOTDetail = otMgmt.operateOnOvertimeType(dbOP,request,4,"1");
	Vector vOTWithType  = null;
	Vector vTemp = null;
	int iIncr = 1;
	int iCols = 0;
	int iDeptCol = 2;
	int iOTFieldCount = 1;

 	
	if(vOTDetail != null && vOTDetail.size() > 0)
		iOTFieldCount = vOTDetail.size()/19;
	
	boolean bolNextDept = true;
	String strSalaryBase = null; 
	
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
	String strCutOff = null;
	
	
	//get the allowances
	int iAllowanceCount = 0;
	vAllowances = RptPSheet.getAllowancesForPSheet(dbOP);	
	int alNamesSize = ((Vector)vAllowances.elementAt(1)).size();
	int alGNamesSize = ((Vector)vAllowances.elementAt(0)).size();
	
	//allowance
	if(vAllowances != null && vAllowances.size() > 0){			
		vAllowanceGroupNames = (Vector)vAllowances.elementAt(0);
		if(vAllowanceGroupNames != null && vAllowanceGroupNames.size() > 0)
			iAllowanceCount = 	vAllowanceGroupNames.size();
			
	}
	//end of allowances
	
	
	//////// sub total \\\\\
	double dSubMonthlyRate = 0d;
	double dSubDailyRate = 0d;
	double dSubHourlyRate = 0d;
	double dSubTeachingyRate = 0d;
	double dSubOverloadRate = 0d;
	double dSubLoadUnitsRate = 0d;
	double dSubLoadHoursRate = 0d;	
	double dSubRegDays = 0d;	
	double dSubNDFHours = 0d;
	double dSubAbsences = 0d;
	double dSubTardiness = 0d;
	double dSubUT = 0d;
	double dSubCashConv = 0d;
	
	double[] adSubAllowance = new double[iAllowanceCount];
	double[] adSubOT = new double[iOTFieldCount];
	
 	///// end of sub total \\\\	
	
	
	//////// grand total \\\\\
	double dGrandMonthlyRate = 0d;
	double dGrandDailyRate = 0d;
	double dGrandHourlyRate = 0d;
	double dGrandTeachingyRate = 0d;
	double dGrandOverloadRate = 0d;
	double dGrandLoadUnitsRate = 0d;
	double dGrandLoadHoursRate = 0d;	
	double dGrandRegDays = 0d;	
	double dGrandNDFHours = 0d;
	double dGrandAbsences = 0d;
	double dGrandTardiness = 0d;
	double dGrandUT = 0d;
	double dGrandCashConv = 0d;
	
	double[] adGrandAllowance = new double[iAllowanceCount];
	double[] adGrandOT = new double[iOTFieldCount];
	
 	///// end of grand total \\\\	
	
		
	boolean bolOfficeTotal = false;
 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	vRetResult = RptPSheet.getPayrollSummary(dbOP,WI);	
	
	strTemp = WI.fillTextValue("sal_period_index");
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	  if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		strCutOff =  (String)vSalaryPeriod.elementAt(i + 1) +" - "+(String)vSalaryPeriod.elementAt(i + 2);
		//System.out.println("cut "+ i);
		break;
	  }
	}
	

	if (vRetResult != null) {	
		int iPage = 1; int iCount = 0;
		int iDeptCount = 0; int iOT = 0;
		int iOTType = 0;
		int iAdjType = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		if(vRetResult != null){
		int iTotalPages = (vRetResult.size())/(iFieldCount*iMaxRecPerPage);		
		
		if((vRetResult.size() % (iFieldCount * iMaxRecPerPage)) > 0)
			 ++iTotalPages;

		for (;iNumRec < vRetResult.size();iPage++){ // OUTERMOST FOR LOOP
			dTemp = 0d;
			dLineTotal = 0d;
	
%>
<body onLoad="javascript:window.print();"> 
<form name="form_" 	method="post" action="psheet_grouped.jsp">
 
	<%=WI.fillTextValue("report_title")%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">  
    <tr> 
      <td height="24" align="left"><strong> FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%> <%=WI.getStrValue(strCutOff, "Cut Off : ","","")%></td>
          <%if(WI.fillTextValue("team_index").length() > 0){%>
          <br>
		TEAM : <%=WI.fillTextValue("team_name")%>
			<%}%>
      	</td>	
		<td height="19"  align="right">&nbsp;Date and time printed : <%=WI.getTodaysDateTime()%></td>	
    </tr>	
	</table>
	
	
		<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="13%" height="33"  align="center" class='headerWithBorder' style="border-top:solid 1px #000000;">ID </td>
            <td width="13%" height="33"  align="center" class='headerWithBorder' style="border-top:solid 1px #000000;">NAME 
              OF EMPLOYEE </td>
            <td width="5%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;MONTHLY RATE </td>
            <td width="5%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;DAILY RATE </td>
            <td width="5%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;HOURLY RATE </td>
            <td width="5%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;TEACHING RATE </td>
            <td width="5%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;OVERLOAD RATE </td>
            <td width="5%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;LOAD UNITS </td>
            <td width="5%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;LOAD HOURS </td>
            <td width="5%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;REG DAYS </td>
            <%
		//OT names here
		if(vOTDetail != null && vOTDetail.size() > 0){
			int iRow = 0;
			for(int j = 0; j < vOTDetail.size(); j+=19){
				strTemp = (String)vOTDetail.elementAt(j+1);
				%>
            <td width="5%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;"><%=strTemp%></td>
            <%	
			}//end of for loop vOTDetail
		}//end of vOTDetail	
		%>
	        <td width="6%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;NDF HRS </td>
            <td width="6%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;ABSENCES (Days)</td>
            <td width="6%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;TARDINESS(mins) </td>
            <td width="6%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;UNDERTIME(mins) </td>
            <%		
		//allowance
		
		if(vAllowances != null && vAllowances.size() > 0){			
			vAllowanceGroupNames = (Vector)vAllowances.elementAt(0);
			if(vAllowanceGroupNames != null && vAllowanceGroupNames.size() > 0){
				iAllowanceCount = 	vAllowanceGroupNames.size();
				for(int iCtr2 = 0; iCtr2 < vAllowanceGroupNames.size(); iCtr2+=1){%>
					<td width="6%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;">&nbsp;<%=(String)vAllowanceGroupNames.elementAt(iCtr2)%></td>
				<%}//end of for loop vAllowanceGroupNames
			}//end of vAllowanceGroupNames
		}//end of if vAllowance
	%>
            <td width="6%"  align="center" class="headerthinborder" style="border-top:solid 1px #000000;border-right:solid 1px #000000;">&nbsp;CASH CONVERSION (leave) </td>
          </tr>
          <% 
		for(; i < vRetResult.size();){ // DEPT FOR LOOP
			if(bolNextDept || bolMoveNextPage){
				if(bolNextDept){
					// after adding to the grand total... zero out the department totals
				}		
		
			bolNextDept = false;	
		
			if(iDeptCount == 3){
				iDeptCount = 0;
				iCount++;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					bolMoveNextPage = true;
					continue;
				}
				else 
					bolPageBreak = false;			
			}else
			iDeptCount++;
			if(bolIsSchool)
				strTemp = "College : ";
			else
				strTemp = "Division : ";
				
			strTemp2 = (String)vRetResult.elementAt(i+6);
			strTemp2 = WI.getStrValue(strTemp2," Dept : ","","");	
		%>
          <tr>
            <td height="19" colspan="54" valign="bottom" class='thinborderBOTTOMLEFTRIGHT'><strong><%=(WI.getStrValue((String)vRetResult.elementAt(i+5),strTemp, strTemp2, strTemp2)).toUpperCase()%></strong></td>
          </tr>
	    <%}// bolNextDept || bolMoveNextPage)%>
		<%
		for(; i < vRetResult.size();){// employee for loop
			if( i == 10 ) i -= 10;
			if( vRetResult.elementAt(i+24) != null )
				vEmpAllowance = (Vector)vRetResult.elementAt(i+24);		
			if( vRetResult.elementAt(i+19) != null )
				vOTWithType = (Vector)vRetResult.elementAt(i+19);	 	
			//i = iNumRec;
			if(i+iFieldCount+1 < vRetResult.size()){
				if(i == 0){
					strCurColl = WI.getStrValue(vRetResult.elementAt(i+7)+"","0");		
					strCurDept = WI.getStrValue(vRetResult.elementAt(i+8)+"","");	
				}
				strNextColl = WI.getStrValue(vRetResult.elementAt(i + iFieldCount + 7)+"","0");		
				strNextDept = WI.getStrValue(vRetResult.elementAt(i + iFieldCount + 8)+"","");		
					
				if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
					bolNextDept = true;
				bolOfficeTotal = true;
			}
		}
  
	iCount++;
	if (iCount > iMaxRecPerPage){
		bolPageBreak = true;
 		break;
	}
	else 
		bolPageBreak = false; 
 		%>
          <tr>
            <td valign="bottom" class='thinborder' >&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 1))%></td>
            <td height="22" valign="bottom" class='thinborder' ><strong><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4)%></strong></td>
            <%
	  		//monthly rate
			strTemp = (String)vRetResult.elementAt(i + 9);
			strTemp = WI.getStrValue(strTemp, "0");
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
 			if(dTemp <= 0)
				strTemp = "";
			dSubMonthlyRate += dTemp;	
  	  %>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
	  			//daily rate
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+10),"0");	
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
				if(dTemp <= 0)
					strTemp = "";	
				dSubDailyRate  += dTemp;			
			%>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
	 		//rate per hour
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11),"0"); 	
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
 			if(dTemp <= 0)
				strTemp = "";
			dSubHourlyRate  += dTemp;	
	 %>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
	  		//teahing rate
				strTemp = "";					
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12),"0");
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
				if( dTemp > 0){ 	
					strTemp2 = (String)vRetResult.elementAt(i+13); //unit			
					if(strTemp2.equals("1"))//per unit
						strTemp = strTemp + "/unit";
					else
						strTemp = strTemp + "/hr";	
				}else
					strTemp = "";	
				dSubTeachingyRate += dTemp;
			%>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
	  		//overload rate
			strTemp = "";				
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14),"0");
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp > 0){
				strTemp2 = vRetResult.elementAt(i+15)+""; //unit			
				if(strTemp2.equals("1"))//per unit
					strTemp = strTemp + "/unit";
				else
					strTemp = strTemp + "/hr";	
			}else
				strTemp = "";		
			dSubOverloadRate += dTemp;
			%>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
		//load UNITS
		strTemp = WI.getStrValue(vRetResult.elementAt(i+17)+"","0");
		dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
		if(dTemp <= 0)
			strTemp = "";
		dSubLoadUnitsRate += dTemp;
							
		%>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
		//load hours
		strTemp = WI.getStrValue(vRetResult.elementAt(i+18)+"","0");	
		dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
		if(dTemp <= 0)
			strTemp = "";
		dSubLoadHoursRate  += dTemp;			
		%>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
		//REG DAYS
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+23),"0");
		dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
		if(dTemp <= 0)
			strTemp = "";
		dSubRegDays   += dTemp;					
		%>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
		//OT hrs here
		if(vOTDetail != null && vOTDetail.size() > 0){
			int iRow = 0;			
			for(int j = 0; j < vOTDetail.size(); j+=19,iRow++){
				dTemp = 0;
				strTemp = (String)vOTDetail.elementAt(j+1);				
				if(vOTWithType != null && vOTWithType.size() > 0){//check if exists in emp ot
					iIndexOf = vOTWithType.indexOf(strTemp); 					
					if(iIndexOf != -1){
						strTemp2 = WI.getStrValue((String)vOTWithType.elementAt(iIndexOf-3),"0");
						dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp2, ",", ""));	
						if(dTemp <= 0)
							strTemp2 = "";
					}else
						strTemp2 = "";	
				}else{
					strTemp2 = otMgmt.getOTManualEncoded(vRetResult.elementAt(i)+"", WI.fillTextValue("sal_period_index"), vOTDetail.elementAt(j)+"");					
					if( strTemp2 == null )
						strTemp2 = "";
				} 
		
				adSubOT[iRow] += dTemp;
				%>
            <td width="5%"  align="right" class="thinborder"><%=CommonUtil.formatFloat(strTemp2,true)%>&nbsp;</td>
            <%	
			}//end of for loop vOTDetail
		}//end of vOTDetail	
		%>
            <%
			//ndf
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+20),"0");
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp <= 0)
				strTemp = "";
			dSubNDFHours    += dTemp;									
		%>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
			//absences
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+26),"0");
			if( strTemp == null || strTemp.equals("0") )
				strTemp = WI.getStrValue(otMgmt.getAbsenceManualEncoded(vRetResult.elementAt(i)+"", WI.fillTextValue("sal_period_index")),"0");
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp <= 0)
				strTemp = "";
			dSubAbsences     += dTemp;				
		%>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
			//LATE
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+21),"0");	
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp <= 0)
				strTemp = "";
			dSubTardiness  += dTemp;				
		%>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
		//ut
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+22),"0");	
		dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			if(dTemp <= 0)
				strTemp = "";
			dSubUT   += dTemp;			
		%>
            <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
            <%
		//allowance here		
		
		if(vAllowances != null && vAllowances.size() > 0){			
			vAllowanceNames = (Vector)vAllowances.elementAt(1);	
			if(vAllowanceNames != null && vAllowanceNames.size() > 0){				
				for(int iCtr2 = 0; iCtr2 < vAllowanceNames.size(); iCtr2+=1){	
					dTemp = 0d;				
					vTemp = (Vector)vAllowanceNames.elementAt(iCtr2);
					for(int k = 0; k < vTemp.size(); k++){
						strTemp = "";
						iIndexOf = vEmpAllowance.indexOf((String)vTemp.elementAt(k));						
						if(iIndexOf != -1){ 
							strTemp = WI.getStrValue((String)vEmpAllowance.elementAt(iIndexOf+2),"0");
							dTemp += Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
						}//end of -1						
					}//end of vtemp for loop	
					if(dTemp <= 0)
						strTemp = "";	
					else
						strTemp = CommonUtil.formatFloat(dTemp,true);
					adSubAllowance[iCtr2] += dTemp;
					%>
						<td width="6%"  align="center" class="thinborder">&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%></td>
            <%	
				}//end of for loop vAllowanceNames
			}//end of vAllowanceGroupNames
		}//end of if vAllowance
		
	
		//leave conv
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+27),"");	
		dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
		if(dTemp <= 0)
			strTemp = "";
		dSubCashConv  += dTemp;				
		%>
            <td align="right" valign="bottom" class='thinborderBOTTOMLEFTRIGHT'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
          </tr>
          <% 
 	 iNumRec+=iFieldCount;
 	 i = i + iFieldCount;
	 iIncr++;
	 if(iNumRec < vRetResult.size()){
		 strCurColl = WI.getStrValue(vRetResult.elementAt(iNumRec+7)+"","0");
		 strCurDept = WI.getStrValue(vRetResult.elementAt(iNumRec+8)+"","");
	 }	 

 	if(bolNextDept){
		bolOfficeTotal = true;
		break;
	}

  %>
          <%}//end employee for loop%>
          <%  
  if(bolOfficeTotal || (!bolOfficeTotal && iNumRec >= vRetResult.size())){
  	bolOfficeTotal = false;
	iCount++;

	if (iCount > iMaxRecPerPage)
		bolPageBreak = true;
	else
		bolPageBreak = false;
  %>
          <tr>
            <td height="22" align="center" valign="bottom"  colspan="2" class='thinborder' >Dept Total </td>
            <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubMonthlyRate,true)%>&nbsp;</td>
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubDailyRate,true)%>&nbsp;</td>
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubHourlyRate,true)%>&nbsp;</td>
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubTeachingyRate,true)%>&nbsp;</td>
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubOverloadRate,true)%>&nbsp;</td>	
            <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubLoadUnitsRate,true)%>&nbsp;</td>
            <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubLoadHoursRate,true)%>&nbsp;</td>
            <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubRegDays,true)%>&nbsp;</td>
            <%
			//OT names here
			if(vOTDetail != null && vOTDetail.size() > 0){
				int iRow = 0;
				for(int j = 0; j < iOTFieldCount; j++){%>
            <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(adSubOT[j],true)%>&nbsp;</td>	
            <%	
				}//end of for loop vOTDetail
			}//end of vOTDetail	
		%>
		<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubNDFHours,true)%>&nbsp;</td>	
        <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubAbsences,true)%>&nbsp;</td>
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubTardiness,true)%>&nbsp;</td>	
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dSubUT,true)%>&nbsp;</td>	
    
			
			<%
			//allowances
			for(int l = 0; l < iAllowanceCount; l++ ){
			%>
				<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(adSubAllowance[l],true)%>&nbsp;</td>
			<%
			}
			%>			
			<td height="22" align="right" valign="bottom"  class='thinborderBOTTOMLEFTRIGHT' ><%=dSubUT%>&nbsp;</td>
          </tr>
          <% 
	
		//GRAND TOTAL here and initialize back to zero
		
		
		dGrandMonthlyRate += dSubMonthlyRate ;
		dGrandDailyRate += dSubDailyRate ;
	 	dGrandHourlyRate += dSubHourlyRate ;
	 	dGrandTeachingyRate += dSubTeachingyRate ;
	 	dGrandOverloadRate += dSubOverloadRate ;
	 	dGrandLoadUnitsRate += dSubLoadUnitsRate ;
	 	dGrandLoadHoursRate += dSubLoadHoursRate ;	
	 	dGrandRegDays += dSubRegDays ;	
	 	dGrandNDFHours += dSubNDFHours ;
	 	dGrandAbsences += dSubAbsences ;
	 	dGrandTardiness += dSubTardiness ;
	 	dGrandUT += dSubUT ;
	 	dGrandCashConv += dSubCashConv ;
		
		for(int k = 0; k < iAllowanceCount; k++){
			adGrandAllowance[k] = adSubAllowance[k];
			 adSubAllowance[k] = 0;
		}
		
		for(int k = 0; k < iOTFieldCount; k++){
			adGrandOT[k] = adSubOT[k];
			adSubOT[k] = 0;
		}
		
		
		
		//zero here
		dSubMonthlyRate = 0d;
		dSubDailyRate = 0d;
	 	dSubHourlyRate = 0d;
	 	dSubTeachingyRate = 0d;
	 	dSubOverloadRate = 0d;
	 	dSubLoadUnitsRate = 0d;
	 	dSubLoadHoursRate = 0d;	
	 	dSubRegDays = 0d;	
	 	dSubNDFHours = 0d;
	 	dSubAbsences = 0d;
	 	dSubTardiness = 0d;
	 	dSubUT = 0d;
	 	dSubCashConv = 0d;
		
	
		
		
		}// if(bolOfficeTotal || (!bolOfficeTotal && iNumRec >= vRetResult.size()))
		%>
          <%if(iNumRec >= vRetResult.size()){%>
          <tr>
            <td height="30" colspan="2" valign="bottom"  class="thinborder">Grand Total </td>
			 <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandMonthlyRate,true)%>&nbsp;</td>
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandDailyRate,true)%>&nbsp;</td>
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandHourlyRate,true)%>&nbsp;</td>
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandTeachingyRate,true)%>&nbsp;</td>
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandOverloadRate,true)%>&nbsp;</td>	
            <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandLoadUnitsRate,true)%>&nbsp;</td>
            <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandLoadHoursRate,true)%>&nbsp;</td>
            <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandRegDays,true)%>&nbsp;</td>
            <%
			//OT names here
			if(vOTDetail != null && vOTDetail.size() > 0){
				int iRow = 0;
				for(int j = 0; j < iOTFieldCount; j++){%>
            <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(adGrandOT[j],true)%>&nbsp;</td>	
            <%	
				}//end of for loop vOTDetail
			}//end of vOTDetail	
		%>
		<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandNDFHours,true)%>&nbsp;</td>	
        <td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandAbsences,true)%>&nbsp;</td>
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandTardiness,true)%>&nbsp;</td>	
			<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(dGrandUT,true)%>&nbsp;</td>	
    
			
			<%
			//allowances
			for(int l = 0; l < iAllowanceCount; l++ ){
			%>
				<td height="22" align="right" valign="bottom"  class='thinborder' ><%=CommonUtil.formatFloat(adGrandAllowance[l],true)%>&nbsp;</td>
			<%
			}%>
			
			<td height="22" align="right" valign="bottom"  class='thinborderBOTTOMLEFTRIGHT' ><%=dGrandUT%>&nbsp;</td>
          </tr>
          <%}/// bolPageBreak || iNumRec >= vRetResult.size()%>
          <%
		if(bolPageBreak){
			iCount = 0;
			break;
		}
	 }// end DEPT FOR LOOP %>
        </table>
		<%if (bolPageBreak){%>
<DIV style="page-break-before:always">&nbsp;</Div>
  <%}//page break ony if it is not last page.
   } //end for (iNumRec < vRetResult.size() // END OUTERMOST FOR LOOP
  }// end if vRetResult != null;
 } //end end upper most if (vRetResult !=null)%>  
	<input type="hidden" name="is_grouped" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>