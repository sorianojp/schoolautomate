<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function ViewRecords()
{
	document.form_.print_page.value="";	
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

</script>
<body>
<form name="form_" 	method="post" action="./payroll_summary_per_office.jsp">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME,
								enrollment.CurriculumCollege" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
//add security here.

if (WI.fillTextValue("print_page").length() > 0){ 
%>
	<jsp:forward page="./payroll_summary_per_office_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","payroll_summary_per_office.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
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
														"Payroll","REPORTS",request.getRemoteAddr(),
														"payroll_summary_per_office.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();	
	
	
	Vector vColleges = null;
	CurriculumCollege CC = new CurriculumCollege();	
	
	int i = 0;
	int iStart = 19;

	double dPeriodRate   = 0d;
	double dCollegeTotal = 0d;
	double dGrossSalary     = 0d;
	double dHonorarium   = 0d;
	double dOtherDeduction = 0d;
	double dTotalDeduction = 0d;
	double dNetpay       = 0d;
	double dTempSalary   = 0d;
	double dAbsenceAmt   = 0d;	
	double dPagIbigLoan = 0d;
	double dSSSLoan = 0d;
	double dOtherLoan = 0d;
	double dUnion1 = 0d;
	double dUnion2 = 0d;
	double dCoop = 0d;
	double dRevFund = 0d;
	double ddb = 0d;
	double dInsurance = 0d;
	double dUnionDues = 0d;
	double dOtherCons = 0d;
	double dTemp  = 0d;
	double dUnreleasedSalary = 0d;
	double dNetSalary  = 0d;
	
	Vector vLoans = null;
	Vector vMiscDed = null;
	Vector vOtherCons = null;
	Vector vOtherSummary = null;	
	Vector vRetResult = null;
	Vector vPayPerCollege = null;
	Vector vFacAbsences = null;	
	Vector vVarAllowances = null;
	ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
	String strPayrollPeriod  = null;
	String strTemp2 = null;
	String strDailyRate = null;
	String strHourlyRate = null;
	String strSlash = null;

if(WI.fillTextValue("year_of").length() > 0) {
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	vColleges = CC.viewall(dbOP);

	vRetResult = RptPay.getPerEmployeeDetail(dbOP);
	if(vRetResult == null){
		strErrMsg = RptPay.getErrMsg();
	}else{
		iSearchResult = RptPay.getSearchCount();
	}
	
//	vPayPerCollege  = RptPay.getFacultyPaySummary(dbOP);
//	System.out.println(vPayPerCollege);
//	vFacAbsence = RptPay.getFacultyAbsentSummary(dbOP);
	//System.out.println(vFacAbsence);
}
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font color="#000000" ><strong>:::: 
          PAYROLL: PAYROLL SUMMARY PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3"> <select name="month_of" onChange="ReloadPage();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="14%">Salary Period</td>
      <td colspan="3"><strong>
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          <%}//end of if condition.		  
		 }//end of for loop.%>
        </select>
        </strong>
        <% 
				if(strHasWeekly.equals("1")){
					strTemp = WI.fillTextValue("is_weekly");
					if(strTemp.compareTo("1") == 0) 
						strTemp = " checked";
					else	
						strTemp = "";
				%>
        <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font size="1">for weekly </font>
        <%}// check if the company has weekly salary type%>      </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Bank</td>
      <%
		strTemp = WI.fillTextValue("bank_index");		
  	  %>
      <td height="10" colspan="3"><select name="bank_index">
          <option value="">Select Bank</option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_NAME, BRANCH", " from FA_BANK_LIST", strTemp,false)%> </select></td>
    </tr>
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td width="1%" height="10">&nbsp;</td>
      <td width="14%" height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><input name="image" type="image" onClick="ViewRecords()" src="../../../images/form_proceed.gif">      </td>
    </tr>	
  </table>
  <%if (vRetResult!= null && vRetResult.size() > 0){%>  
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18"><div align="right"><font><a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/RptPay.defSearchSize;		
	if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr> 
      <td><div align="right"><font size="2">Jump To page: 
          <select name="jumpto" onChange="SearchEmployee();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          </font></div></td>
    </tr>
	<%}%>
  </table>
  <%for(int o = 0; o < vRetResult.size(); o+=35){
  dOtherDeduction = 0d;
  dNetSalary = 0d;
  dGrossSalary = 0d;
  dTotalDeduction = 0d;
  dUnreleasedSalary = 0d;
  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#000000">	
    <tr> 
      <% strTemp = "";
		strTemp = WI.formatName((String)vRetResult.elementAt(o+2), (String)vRetResult.elementAt(o+3),
							(String)vRetResult.elementAt(o+4), 4);
        strTemp = strTemp.toUpperCase();
	  %>
      <td width="7%" height="10">&nbsp;<font size="1">Name</font> </td>
      <td height="10" colspan="2"><font size="1"><strong>&nbsp;<%=WI.getStrValue(strTemp," ")%></strong></font></td>
      <td width="11%">&nbsp;</td>
      <td width="50%" height="10"><strong><font color="#0000FF">PAYROLL DATE : 
        <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#000000">	
    <tr> 
      <td height="187" colspan="2" valign="top" class="thinborderTOPLEFTBOTTOM"> 
        <div align="left"> 
          <table width="100%" border="0" cellpadding="0" cellspacing="0">
            <tr> 
              <td height="16" valign="top">&nbsp;</td>
              <td><div align="center"><strong><font size="1">Period</font></strong></div></td>
              <td><div align="center"><strong><font size="1">Daily/Hrs.</font></strong></div></td>
              <td colspan="2"><div align="center"><strong><font size="1">ABSENT</font></strong></div></td>
              <td>&nbsp;</td>
            </tr>
            <tr> 
              <td height="16" class="thinborderBOTTOM"><font size="1"><strong>Dept.</strong></font></td>
              <td class="thinborderBOTTOM"><div align="center"><font size="1"><strong>Rate</strong></font></div></td>
              <td class="thinborderBOTTOM"><div align="center"><font size="1"><strong>Rate</strong></font></div></td>
              <td class="thinborderBOTTOM"><div align="center"><font size="1"><strong>NO.</strong></font></div></td>
              <td class="thinborderBOTTOM"><div align="center"><font size="1"><strong>AMT.</strong></font></div></td>
              <td class="thinborderBOTTOM"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
            </tr>
            <tr> 
              <td width="16%" height="13"  class="thinborderNONE"><font size="1">&nbsp;Admin</font></td>
              <% 			  	
			  if ((String)vRetResult.elementAt(o+9) == null || ((String)vRetResult.elementAt(o+9)).equals("0")){
					  strTemp = (String)vRetResult.elementAt(o+5);			
  					  dGrossSalary = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					  strTemp = WI.getStrValue(strTemp,"0");
					  dTempSalary = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
					 if (vPayPerCollege != null && vPayPerCollege.size() > 0){						
						for(int j = 0;j < vPayPerCollege.size(); j+=3){
 						  if (vPayPerCollege.elementAt(j+1) == null){
							 dTempSalary += ((Double)vPayPerCollege.elementAt(j)).doubleValue();							
						  }
						}
					  }
					}else{
						strTemp = " ";
					}				
				%>
              <td width="13%"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
              <% if ((String)vRetResult.elementAt(o+9) == null || ((String)vRetResult.elementAt(o+9)).equals("0")){
					 if (vRetResult != null && vRetResult.size() > 0){ 
						 strDailyRate = (String)vRetResult.elementAt(o+iStart+13);			
						 strHourlyRate = (String)vRetResult.elementAt(o+iStart+14);
					  }else{
						strDailyRate = " ";
						strHourlyRate = " ";
					  }
					  
					  if((String)vRetResult.elementAt(o+iStart+13) == null || (String)vRetResult.elementAt(o+iStart+14) == null)
						  strSlash = " ";				
					  else
						  strSlash = "/";									
				  }else{
						strDailyRate = " ";
						strHourlyRate = " ";
 				  }	
				%>
              <td width="24%" class="thinborderNONE"><div align="right"> 
                  <%=WI.getStrValue(strDailyRate," ")%><%=strSlash%><%=WI.getStrValue(strHourlyRate," ")%></div></td>
              <td width="12%"  class="thinborderNONE">&nbsp;</td>
              <% dTemp = 0d;
			    if ((String)vRetResult.elementAt(o+9) == null || ((String)vRetResult.elementAt(o+9)).equals("0")){
					strTemp = (String) vRetResult.elementAt(o+8);//AWOL_AMT
					dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
					dGrossSalary -= dTemp;
			    }
				if(dTemp == 0d)
				  strTemp = "";
		      %>
              <td width="15%" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
              <td width="20%" class="thinborderNONE"><div align="right"> 
                  <%if ((String)vRetResult.elementAt(o+9) == null || ((String)vRetResult.elementAt(o+9)).equals("0")){%>
                  <%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%> 
                  <%}%>&nbsp;
                </div></td>
            </tr>
            <%if (vColleges != null && vColleges.size() > 0){%>
            <%for(i = 0;i<vColleges.size();i+=4){
			strSlash = "";
			dTempSalary = 0d;
			dAbsenceAmt = 0d;
			%>				
            <tr> 
              <td width="16%" height="13" class="thinborderNONE">&nbsp;<%=WI.getStrValue((String)vColleges.elementAt(i+1),"")%></td>
              <% dTempSalary = 0d;
			  	strTemp = null;
			  if ((String)vRetResult.elementAt(o+9) != null && !((String)vRetResult.elementAt(o+9)).equals("0")){
				if(((String) vColleges.elementAt(i)).equals((String)vRetResult.elementAt(o+9))){
				  strTemp = (String)vRetResult.elementAt(o+5);			
				  //dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				}
				 strTemp = WI.getStrValue(strTemp,"0");
				 dTempSalary = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				 if (vPayPerCollege != null && vPayPerCollege.size() > 0){
					for(int j = 0;j < vPayPerCollege.size(); j+=3){
					  if (((String)vPayPerCollege.elementAt(j+1)).equals((String) vColleges.elementAt(i))){
						dTempSalary += ((Double)vPayPerCollege.elementAt(j)).doubleValue();
						break;
					  }
					}					
				  }
				  //dGrossSalary +=dTempSalary;
				  strTemp = CommonUtil.formatFloat(dTempSalary,true);				  	
			   }
			   
			   if(dTempSalary == 0d)
			   	strTemp = "";
  			   %>
              <td width="13%" class="thinborderNONE"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
              <% 
				  if ((String)vRetResult.elementAt(o+9) != null && !((String)vRetResult.elementAt(o+9)).equals("0")){
					 if (vRetResult != null && vRetResult.size() > 0){
						if(((String) vColleges.elementAt(i)).equals((String)vRetResult.elementAt(o+9))){
						  strDailyRate = (String)vRetResult.elementAt(o+iStart+13);			
						  strHourlyRate = (String)vRetResult.elementAt(o+iStart+14);			
						  if((String)vRetResult.elementAt(o+iStart+13) == null || (String)vRetResult.elementAt(o+iStart+14) == null)
							  strSlash = " ";				
						  else
							  strSlash = "/";
						}else{
						  strDailyRate = " ";
						  strHourlyRate = " ";		
						}
					  }else{
						 strDailyRate = " ";
						 strHourlyRate = " ";	
					  }						
				   }else{
					 strDailyRate = " ";
					 strHourlyRate = " ";	
				   }
	
				
  			   %>
              <td width="24%" class="thinborderNONE"><div align="right"> <%=WI.getStrValue(strDailyRate," ")%><%=strSlash%><%=WI.getStrValue(strHourlyRate," ")%></div></td>
              <td width="12%" class="thinborderNONE">&nbsp;</td>
              <% dAbsenceAmt = 0d;
			 if ((String)vRetResult.elementAt(o+9) != null && !((String)vRetResult.elementAt(o+9)).equals("0")){
		  		if(((String) vColleges.elementAt(i)).equals((String)vRetResult.elementAt(o+9))){
					strTemp = (String) vRetResult.elementAt(o+8);//AWOL_AMT
						//dGrossSalary -= Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				}else{
					strTemp = "";
				}				
			 	strTemp = WI.getStrValue(strTemp,"0");
			 	dAbsenceAmt = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				//System.out.println("indexmain --------- "+(String) vColleges.elementAt(i));	
			 	if (vFacAbsences != null && vFacAbsences.size() > 0){
				  //System.out.println("vFacAbsences "+vFacAbsences);						
				  for(int j = 0;j < vFacAbsences.size(); j+=3){				  		
					//System.out.println("index "+(String)vFacAbsences.elementAt(j+2));					
					//System.out.println("colleger "+(String) vColleges.elementAt(i));
				  	if (vFacAbsences.elementAt(j+2)!= null)	{
						if (((String)vFacAbsences.elementAt(j+2)).equals((String) vColleges.elementAt(i))){							
							dAbsenceAmt += ((Double)vFacAbsences.elementAt(j+1)).doubleValue();
							break;
						}
					}					
				  }					
			  	}				
			  //	dGrossSalary -=dAbsenceAmt;
			  	strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
			}
			if(dAbsenceAmt == 0d)
				strTemp = "";
		   %>
              <td width="15%" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
			<%
			dTemp = 0d;
			if ((String)vRetResult.elementAt(o+9) != null && !((String)vRetResult.elementAt(o+9)).equals("0")){
			  dTemp = dTempSalary - dAbsenceAmt;
			  dGrossSalary += dTemp;
			  strTemp = CommonUtil.formatFloat(dTemp,true);
			}// end if vPersonalDetails!=null
			if(dTemp == 0d)
				strTemp = "";
			%> 
              <td width="20%" class="thinborderNONE"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
            </tr>
            <%}// end for(int i = 0;i<vCollege...%>
            <%}/// end if %>
            <tr> 
              <td width="16%" height="13" class="thinborderNONE"><font size="1">&nbsp;Hon.</font></td>
			<% dTemp = 0d;
			  if (vRetResult != null && vRetResult.size() > 0){ 
				strTemp = (String)vRetResult.elementAt(o+7);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				dGrossSalary += dTemp;
			  }
			  if(dTemp == 0d)
				strTemp = "";			  	
			%>
              <td width="13%" class="thinborderNONE"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
              <td width="24%" class="thinborderNONE">&nbsp;</td>
              <td width="12%" class="thinborderNONE">&nbsp;</td>
              <td width="15%" class="thinborderNONE">&nbsp;</td>
              <td width="20%" class="thinborderNONE">&nbsp;</td>
            </tr>
          </table>
        </div></td>
      <td width="25%" valign="top" class="thinborderTOPLEFTBOTTOM"> <table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td height="16" colspan="2"><strong><font size="1">DEDUCTION</font></strong></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td height="16" colspan="2" class="thinborderBOTTOM"><strong><font size="1">TYPE</font></strong></td>
            <td class="thinborderBOTTOM">&nbsp;</td>
            <td class="thinborderBOTTOM"><div align="right"><strong><font size="1">AMT.&nbsp;&nbsp;</font></strong></div></td>
          </tr>
          <tr> 
            <td width="3%" height="13">&nbsp;</td>
            <td width="63%"><font size="1">Pag-ibig Premium</font></td>
            <td width="6%">&nbsp;</td>
            <% dTemp = 0d;
			if (vRetResult != null && vRetResult.size() > 0){ 
				strTemp = (String) vRetResult.elementAt(o+11);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";
		   %>
            <td width="25%"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">SSS</font></td>
            <td><font size="1">&nbsp;</font></td>
            <% dTemp = 0d;
			if (vRetResult != null && vRetResult.size() > 0){ 
				strTemp = (String) vRetResult.elementAt(o+12);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";
		   %>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">PhilHealth</font></td>
            <td><font size="1">&nbsp;</font></td>
            <% dTemp = 0d;
			if (vRetResult != null && vRetResult.size() > 0){ 
				strTemp = (String) vRetResult.elementAt(o+13);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";
		   %>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <% 
			 strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(o+iStart+9),true);				
			 dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";		
		   %>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">Union Dues</font></td>
            <td>&nbsp;</td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">W/ Tax</font></td>
            <td><font size="1">&nbsp;</font></td>
            <% dTemp = 0d;
			if (vRetResult != null && vRetResult.size() > 0){ 
				strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(o+14),true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";	
		   %>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">Educational Loan</font></td>
            <td>&nbsp;</td>
          <%
			strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(o+iStart+2),true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			dTotalDeduction += dTemp;			
			if(dTemp == 0d)
			  strTemp = "";			
		   %>			
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">SSS Loan</font></td>
            <td>&nbsp;</td>
          <% strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(o+iStart),true);
			 dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";				
		   %>			
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">Pag-ibig Loan</font></td>
            <td>&nbsp;</td>
          <% strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(o+iStart+1),true);
			 dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";				
		   %>		
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">Credit Union(1)</font></td>
            <td>&nbsp;</td>
          <%
		    strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(o+iStart+3),true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";				
		   %>			
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">Credit Union(2)</font></td>
            <td>&nbsp;</td>
          <% 
		     strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(o+iStart+4),true);
			 dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			 dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";				
		   %>			   
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">Coop. Store</font></td>
            <td>&nbsp;</td>
          <%
			 strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(o+iStart+5),true);
			 dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";				
		   %>			
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">Revolving Fund</font></td>
            <td>&nbsp;</td>
          <%
			 strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(o+iStart+6),true);
			 dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";				
		   %>			
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">Insurance</font></td>
            <td>&nbsp;</td>
          <%
			 strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(o+iStart+10),true);
			 dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";				
		   %>			
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">D/B</font></td>
            <td>&nbsp;</td>
          <%	    
			 strTemp = CommonUtil.formatFloat((String) vRetResult.elementAt(o+iStart+7),true);
			 dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";				
		   %>			
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="13">&nbsp;</td>
            <td><font size="1">Others</font></td>
            <td><font size="1">&nbsp;</font></td>
            <% 
				strTemp = (String) vRetResult.elementAt(o+15);//LEAVE_DEDUCTION_AMT
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
	
				strTemp = (String) vRetResult.elementAt(o+16);//MISC_DEDUCTION (Addl ded)
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));								

				strTemp = (String) vRetResult.elementAt(o+17);//LATE_UNDER_AMT
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				
			 // other deductions encoded in misc deductions page
				strTemp = (String) vRetResult.elementAt(o+iStart+8);
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

				// other contributions
				strTemp = (String) vRetResult.elementAt(o+iStart+11);
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
				strTemp = CommonUtil.formatFloat(dOtherDeduction,true);

				dTotalDeduction += dOtherDeduction;
				if(dOtherDeduction ==0d)
					strTemp = "";
		   %>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
        </table></td>
      <td width="25%" valign="top" class="thinborderBOTTOMLEFTRIGHT"> <table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="4%" height="16" class="thinborderTOP">&nbsp;</td>
            <td width="69%" class="thinborderTOP">&nbsp;</td>
            <td width="9%" class="thinborderTOP">&nbsp;</td>
            <td width="18%" class="thinborderTOP">&nbsp;</td>
          </tr>
          <tr> 
            <td height="16" class="thinborderBOTTOM">&nbsp;</td>
            <td class="thinborderBOTTOM">&nbsp;</td>
            <td class="thinborderBOTTOM">&nbsp;</td>
            <td class="thinborderBOTTOM">&nbsp;</td>
          </tr>
          <tr> 
            <td height="18">&nbsp;</td>
            <td><font size="1"><strong>TOTAL</strong></font></td>
            <td>&nbsp;</td>
            <%/* This was removed because they dont want to show/include the additional pay in the payslip
		if (vRetResult != null && vRetResult.size() > 0){  
			strTemp = (String) vRetResult.elementAt(27); // addl_resp_amt
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

			if (vSalIncentives != null && vSalIncentives.size() > 0){ 
				strTemp = ((Double) vSalIncentives.elementAt(0)).toString();
				dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			}	

			strTemp = (String) vRetResult.elementAt(26);// HOLIDAY_PAY_AMT
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

			strTemp = (String) vRetResult.elementAt(17);//ADDL_PAYMENT_AMT
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

			strTemp = (String) vRetResult.elementAt(22);//ADHOC_BONUS
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

			strTemp = (String) vRetResult.elementAt(25);//NIGHT_DIFF_AMT
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

			strTemp = (String) vRetResult.elementAt(10);//OT_AMT
			dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		} */	
	   %>
            <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%></font></div></td>
          </tr>
          <% dTemp = 0d;
		  	 // Other incentives.
			 strTemp = (String) vRetResult.elementAt(o+18);
			 dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

  			  // Allowances total na lang
			 strTemp = (String) vRetResult.elementAt(o+iStart+13);
			 dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			 			 
			 dGrossSalary += dTemp;
			if(dTemp > 0d){
		  %>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2"><font size="1"><strong>Other Earnings </strong></font></td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dTemp,true),"")%></font></div></td>
          </tr>
          <%} // end if dTemp > 0%>
          <tr> 
            <td height="18">&nbsp;</td>
            <td><font size="1"><strong>COLA</strong></font></td>
            <td><font size="1">&nbsp;</font></td>
            <% 
				strTemp = (String) vRetResult.elementAt(o+6);
				dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		   %>
            <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%></font></div></td>
          </tr>
          <tr>
            <td height="18">&nbsp;</td>
            <td><font size="1"><strong>Prev. Pay</strong></font></td>
            <td>&nbsp;</td>
           <% 
				strTemp = (String) vRetResult.elementAt(o+iStart+12);
				dUnreleasedSalary = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		   %>
            <td><div align="right"><font size="1"><%=CommonUtil.formatFloat(dUnreleasedSalary,true)%></font></div></td>
          </tr>
          <tr> 
            <td class="thinborderTOP" height="18">&nbsp;</td>
            <td class="thinborderTOP"><font size="1"><strong>GROSS PAY</strong></font></td>
            <td class="thinborderTOP"><font size="1">&nbsp;</font></td>
            <td class="thinborderTOP"><div align="right"><font size="1">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%></font></div></td>
          </tr>
          <tr> 
            <td height="18">&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td class="thinborderTOP" height="18">&nbsp;</td>
            <td class="thinborderTOP"><font size="1"><strong>TOTAL DEDUCTIONS</strong></font></td>
            <td class="thinborderTOP"><font size="1">&nbsp;</font></td>
            <td class="thinborderTOP"><div align="right"><font size="1">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%></font></div></td>
          </tr>
          <!--
		  <tr> 
            <td height="18">&nbsp;</td>
            <td><font size="1"><strong>ADJUSTMENT AMOUNT</strong></font></td>
            <td><font size="1">&nbsp;</font></td>
            <%/* 
				if (vRetResult != null && vRetResult.size() > 0){ 
				  if (Double.parseDouble(ConversionTable.replaceString((String) vRetResult.elementAt(20),",","")) < 0){
					strTemp = "(" + ConversionTable.replaceString((String) vRetResult.elementAt(20),"-","") + ")";
					dTotalDeduction -= Double.parseDouble(ConversionTable.replaceString((String) vRetResult.elementAt(20),",",""));
				  }else{
					strTemp =(String) vRetResult.elementAt(20);
					dGrossSalary += Double.parseDouble(ConversionTable.replaceString((String) vRetResult.elementAt(20),",",""));			
				  }
				}	*/
			   %>
            <td><div align="right"><font size="1">&nbsp;<strong><%//=WI.getStrValue(strTemp,"0")%></strong></font></div></td>
          </tr>
		  -->
          <tr> 
            <td height="13">&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td class="thinborderTOP" height="20">&nbsp;</td>
            <td class="thinborderTOP">&nbsp;</td>
            <td class="thinborderTOP">&nbsp;</td>
            <td class="thinborderTOP">&nbsp;</td>
          </tr>
          <tr> 
            <td class="thinborderNONE" height="20">&nbsp;</td>
            <td class="thinborderNONE"><font size="1"><strong>NET PAY </strong></font></td>
            <td class="thinborderNONE"><font size="1">&nbsp;</font></td>
            <%
				dNetSalary += dGrossSalary - dTotalDeduction + dUnreleasedSalary;
			%>
            <td class="thinborderNONE"><div align="right"><font size="1">&nbsp;<strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%></strong></font></div></td>
          </tr>
        </table></td>
    </tr>
  </table>
  <%}%>
  <%}// display if (vRetResult!= null && vRetResult.size() > 2%>
  <%if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <%}%>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>