<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
 <style type="text/css">
    TD.NoBorder {
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: 10px;  
		}
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function loadSalPeriods() {
	var strMonth = document.form_.month_of.value;
	var strYear = document.form_.year_of.value;
	var strWeekly = null;
	
	if(document.form_.is_weekly){
		if(document.form_.is_weekly.checked)
			strWeekly = "1";
		else
			strWeekly = "";
	}
	
	var objCOAInput = document.getElementById("sal_periods");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
}

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
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME,
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
								"Admin/staff-Payroll-REPORTS-Payroll Summary(Per Office)","payroll_summary_per_office.jsp");
								
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
	// date updated march 10, 2008
	// procedure before this date was to hard code the items you want to list in the payslip
	double dPeriodRate   = 0d;
	double dCollegeTotal = 0d;
	double dGrossSalary     = 0d;
	double dHonorarium   = 0d;
	double dOtherDeduction = 0d;
	double dTotalDeduction = 0d;
	double dNetpay       = 0d;
	double dTempSalary   = 0d;
	double dAbsenceAmt   = 0d;	
	double dTemp  = 0d;
	double dUnreleasedSalary = 0d;
	double dNetSalary  = 0d;
	PayrollSheet RptPSheet = new PayrollSheet(request);	
	String strPayrollPeriod  = null;
	String strTemp2 = null;
	String strDailyRate = null;
	String strHourlyRate = null;
	String strSlash = null;
	Vector vRetResult = null;
	Vector vPayPerCollege = null;
	Vector vFacAbsences = null;	

	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vOTDetail = null;
	Vector vSalDetail = null;	
	Vector vRows = null;
	Vector vEarnDedCols = null;

	Vector vEarnCols = null;
	Vector vDedCols = null;	
	Vector vEarnDed = null;
	
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount =0;
	int iColCounter = 0;
		
	int iFieldCount = 75;// number of fields in the vector..

if(WI.fillTextValue("year_of").length() > 0) {
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	vColleges = CC.viewall(dbOP);

	//vRows = RptPSheet.getPerEmployeeDetail(dbOP);
	vRetResult = RptPSheet.getPSheetItems(dbOP);
 	if(vRetResult == null){
		strErrMsg = RptPSheet.getErrMsg();
	}else{
		vRows = (Vector)vRetResult.elementAt(0);
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);			
		vEarnDedCols = (Vector)vRetResult.elementAt(3);		
		
 		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size() - 2;

 		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size() - 1;	

 		if (vEarnDedCols != null && vEarnDedCols.size() > 0)
			iEarnDedCount = vEarnDedCols.size() - 1;	
					
		iSearchResult = RptPSheet.getSearchCount();		
	}
	
//	vPayPerCollege  = RptPSheet.getFacultyPaySummary(dbOP);
//	System.out.println(vPayPerCollege);
//	vFacAbsence = RptPSheet.getFacultyAbsentSummary(dbOP);
	//System.out.println(vFacAbsence);
}
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25" colspan="5" align="center"><strong>::: 
			PAYROLL: PAYROLL SUMMARY (PER OFFICE) PAGE :::</strong></td>
		</tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3"> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="14%">Salary Period</td>
      <td colspan="3"><strong>
			<label id="sal_periods">
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
				</label>
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
  <%if (vRows!= null && vRows.size() > 0){%>  
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18"><div align="right"><font><a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/RptPSheet.defSearchSize;		
	if(iSearchResult % RptPSheet.defSearchSize > 0) ++iPageCount;
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
  <%
	//System.out.println("--------------------------------------------------------------");
	for(int o = 0; o < vRows.size(); o+=iFieldCount){
	vEarnings = (Vector)vRows.elementAt(o+53);
	vDeductions = (Vector)vRows.elementAt(o+54);
	vSalDetail = (Vector)vRows.elementAt(o+55); 
	vOTDetail = (Vector)vRows.elementAt(o+56); 
	vFacAbsences = (Vector)vRows.elementAt(o+57); 
	vPayPerCollege = (Vector)vRows.elementAt(o+58); 	
	//System.out.println("vDeductions-----  " + vDeductions);
  dOtherDeduction = 0d;
  dNetSalary = 0d;
  dGrossSalary = 0d;
  dTotalDeduction = 0d;
  dUnreleasedSalary = 0d;
  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#000000">	
    <tr> 
      <% strTemp = "";
				strTemp = WI.formatName((String)vRows.elementAt(o+4), (String)vRows.elementAt(o+5),
							(String)vRows.elementAt(o+6), 4);
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
      <td height="20" valign="top" class="thinborderTOPBOTTOM"><table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td width="24%" height="16" valign="top">&nbsp;</td>
          <td width="24%"><div align="center"><strong><font size="1">Period</font></strong></div></td>
          <td width="26%"><div align="center"><strong><font size="1">ABSENT</font></strong></div></td>
          <td width="26%">&nbsp;</td>
        </tr>
        <tr>
          <td height="16"><font size="1"><strong>Dept.</strong></font></td>
          <td><div align="center"><font size="1"><strong>Rate</strong></font></div></td>
          <td><div align="center"><font size="1"><strong>AMT.</strong></font></div></td>
          <td><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
        </tr>
    </table></td>
      <td valign="top" class="thinborderTOPBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td height="16"><div align="center"><font size="1"><strong>Total</strong></font></div></td>
        </tr>
        <tr>
          <td height="16"><div align="center"><font size="1"><strong>earnings</strong></font></div></td>
        </tr>
        
      </table></td>
      <td valign="top" class="thinborderTOPBOTTOM"><table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td width="50%" height="16">&nbsp;</td>
          <td width="50%">&nbsp;</td>
        </tr>
        <tr>
          <td height="16">&nbsp;</td>
          <td><div align="center"><font size="1"><strong>COLA</strong></font></div></td>
        </tr>
        
        <!--
		  <tr> 
            <td height="18">&nbsp;</td>
            <td><font size="1"><strong>ADJUSTMENT AMOUNT</strong></font></td>
            <td><font size="1">&nbsp;</font></td>
            <%/* 
				if (vRows != null && vRows.size() > 0){ 
				  if (Double.parseDouble(ConversionTable.replaceString((String) vRows.elementAt(20),",","")) < 0){
					strTemp = "(" + ConversionTable.replaceString((String) vRows.elementAt(20),"-","") + ")";
					dTotalDeduction -= Double.parseDouble(ConversionTable.replaceString((String) vRows.elementAt(20),",",""));
				  }else{
					strTemp =(String) vRows.elementAt(20);
					dGrossSalary += Double.parseDouble(ConversionTable.replaceString((String) vRows.elementAt(20),",",""));			
				  }
				}	*/
			   %>
            <td><div align="right"><font size="1">&nbsp;<strong><%//=WI.getStrValue(strTemp,"0")%></strong></font></div></td>
          </tr>
		  -->
      </table></td>
      <td valign="top" class="thinborderTOPBOTTOM"><table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td width="6%" height="16">&nbsp;</td>
          <td width="53%" height="16"><strong><font size="1">DEDUCTION</font></strong></td>
          <td width="41%">&nbsp;</td>
        </tr>
        <tr>
          <td height="16">&nbsp;</td>
          <td height="16"><strong><font size="1">TYPE</font></strong></td>
          <td><div align="right"><strong><font size="1">AMT.&nbsp;&nbsp;</font></strong></div></td>
        </tr>
      </table></td>
      <td valign="top" class="thinborderTOPBOTTOM">&nbsp;</td>
    </tr>
    <tr> 
      <td height="187" valign="top" class="thinborderBOTTOM"> 
        <div align="left"> 
          <table width="100%" border="0" cellpadding="0" cellspacing="0">            
            <tr> 
              <td width="24%" height="13"  class="NoBorder">&nbsp;Admin</td>
              <% 			  	
			  if ((String)vRows.elementAt(o+2) == null || ((String)vRows.elementAt(o+2)).equals("0")){
					  strTemp = CommonUtil.formatFloat((String)vRows.elementAt(o+7),true);
  					dGrossSalary = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
					  strTemp = WI.getStrValue(strTemp,"0");
					  dTempSalary = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
					 if (vPayPerCollege != null && vPayPerCollege.size() > 0){						
						for(int j = 0;j < vPayPerCollege.size(); j+=3){
 						  if (vPayPerCollege.elementAt(j+1) == null || ((String)vPayPerCollege.elementAt(j+1)).equals("0")){
							 dTempSalary += ((Double)vPayPerCollege.elementAt(j)).doubleValue();							
						  }
						}
					  }
					}else{
						strTemp = " ";
					}				
				%>
              <td width="24%" align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
              <% dTemp = 0d;
			    if ((String)vRows.elementAt(o+2) == null || ((String)vRows.elementAt(o+2)).equals("0")){
					strTemp = (String) vRows.elementAt(o+47);//AWOL_AMT
					dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));					
					strTemp  = CommonUtil.formatFloat(dTemp,2);
					dGrossSalary -= dTemp;
			    }
				if(dTemp == 0d)
				  strTemp = "";
		      %>
              <td width="26%" align="right" class="thinborderNONE"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
              <td width="26%" align="right" class="NoBorder"> 
                <%if ((String)vRows.elementAt(o+9) == null || ((String)vRows.elementAt(o+9)).equals("0")){%>
                <%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%> 
                <%}%>&nbsp;                  </td>
            </tr>
            <%if (vColleges != null && vColleges.size() > 0){%>
            <%for(i = 0;i<vColleges.size();i+=4){
						strSlash = "";
						dTempSalary = 0d;
						dAbsenceAmt = 0d;
						%>				
            <tr> 
              <td width="24%" height="13" class="NoBorder">&nbsp;<strong><%=WI.getStrValue((String)vColleges.elementAt(i+1),"")%></strong></td>
              <% dTempSalary = 0d;
			  	strTemp = null;
			  if ((String)vRows.elementAt(o+2) != null && !((String)vRows.elementAt(o+2)).equals("0")){
				if(((String) vColleges.elementAt(i)).equals((String)vRows.elementAt(o+2))){
				  strTemp = (String)vRows.elementAt(o+7);			
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
              <td width="24%" align="right" class="NoBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
              <% dAbsenceAmt = 0d;
			 if ((String)vRows.elementAt(o+2) != null && !((String)vRows.elementAt(o+2)).equals("0")){
		  		if(((String) vColleges.elementAt(i)).equals((String)vRows.elementAt(o+2))){
					strTemp = (String) vRows.elementAt(o+47);//AWOL_AMT
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
              <td width="26%" align="right" class="thinborderNONE"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
			<%
			dTemp = 0d;
			if ((String)vRows.elementAt(o+9) != null && !((String)vRows.elementAt(o+9)).equals("0")){
			  dTemp = dTempSalary - dAbsenceAmt;
			  dGrossSalary += dTemp;
			  strTemp = CommonUtil.formatFloat(dTemp,true);
			}// end if vPersonalDetails!=null
			if(dTemp == 0d)
				strTemp = "";
			%> 
              <td width="26%" align="right" class="NoBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            </tr>
            <%}// end for(int i = 0;i<vCollege...%>
            <%}/// end if %>
            <tr> 
              <td width="24%" height="13" class="NoBorder">&nbsp;Hon.</td>
					<% dTemp = 0d;
						if (vRows != null && vRows.size() > 0){ 
						strTemp = CommonUtil.formatFloat((String)vRows.elementAt(o+31),true);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
						dGrossSalary += dTemp;
						}
						if(dTemp == 0d)
						strTemp = "";			  	
					%>
              <td width="24%" align="right" class="NoBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
              <td width="26%" align="right" class="thinborderNONE">&nbsp;
              <div align="right"></div></td>
              <td width="26%" align="right" class="NoBorder">&nbsp;
              <div align="right"></div></td>
            </tr>
          <% dTemp = 0d;
		  	  // Other incentives
				 strTemp = (String) vRows.elementAt(o+18);
				 dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
	
						// Allowances total na lang
				 if(vEarnings != null && vEarnings.size() > 0){
						strTemp = (String)vEarnings.elementAt(0);
						dTemp += Double.parseDouble(strTemp);
				 }
			 dGrossSalary += dTemp;
			if(dTemp > 0d){
		  %>			
            <tr>
              <td height="13" class="NoBorder">Other Earnings </td>
              <td align="right" class="NoBorder"><%=WI.getStrValue(CommonUtil.formatFloat(dTemp,true),"")%>&nbsp;</td>
              <td align="right" class="thinborderNONE">&nbsp;</td>
              <td align="right" class="NoBorder">&nbsp;</td>
            </tr>
			<%}%>
          </table>
        </div></td>
      <td valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td height="13"><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%>&nbsp;</font></div></td>
        </tr>
      </table></td>
      <td valign="top" class="thinborderBOTTOMLEFT"> <table width="100%" border="0" cellpadding="0" cellspacing="0">
          
          <tr> 
            <td width="50%" height="18"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dUnreleasedSalary,true)%></font></div></td>
            <% 
				// COLA
				strTemp = CommonUtil.formatFloat((String) vRows.elementAt(o+25),true);
				dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		   %>
            <td width="50%"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%></font></div></td>
          </tr>
          
          <!--
		  <tr> 
            <td height="18">&nbsp;</td>
            <td><font size="1"><strong>ADJUSTMENT AMOUNT</strong></font></td>
            <td><font size="1">&nbsp;</font></td>
            <%/* 
				if (vRows != null && vRows.size() > 0){ 
				  if (Double.parseDouble(ConversionTable.replaceString((String) vRows.elementAt(20),",","")) < 0){
					strTemp = "(" + ConversionTable.replaceString((String) vRows.elementAt(20),"-","") + ")";
					dTotalDeduction -= Double.parseDouble(ConversionTable.replaceString((String) vRows.elementAt(20),",",""));
				  }else{
					strTemp =(String) vRows.elementAt(20);
					dGrossSalary += Double.parseDouble(ConversionTable.replaceString((String) vRows.elementAt(20),",",""));			
				  }
				}	*/
			   %>
            <td><div align="right"><font size="1">&nbsp;<strong><%//=WI.getStrValue(strTemp,"0")%></strong></font></div></td>
          </tr>
		  -->
          
        </table></td>
      <td valign="top" class="thinborderBOTTOMLEFT">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">        
        <tr>
          <td width="6%" height="13">&nbsp;</td>
          <td width="53%" class="NoBorder">Pag-ibig Premium</td>
          <% dTemp = 0d;
			if (vRows != null && vRows.size() > 0){ 
				strTemp = (String) vRows.elementAt(o+41);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";
		   %>
          <td width="41%" align="right" class="NoBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
        </tr>
        <tr>
          <td height="13">&nbsp;</td>
          <td class="NoBorder">SSS</td>
          <% dTemp = 0d;
			if (vRows != null && vRows.size() > 0){ 
				strTemp = CommonUtil.formatFloat((String) vRows.elementAt(o+39),true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";
		   %>
          <td align="right" class="NoBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
        </tr>
        <tr>
          <td height="13">&nbsp;</td>
          <td class="NoBorder">PhilHealth</td>
          <% dTemp = 0d;
			if (vRows != null && vRows.size() > 0){ 
				strTemp = (String) vRows.elementAt(o+40);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";
		   %>
          <td align="right" class="NoBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
        </tr>       
        <tr>
          <td height="13">&nbsp;</td>
          <td class="NoBorder">W/ Tax</td>
          <% dTemp = 0d;
			if (vRows != null && vRows.size() > 0){ 
				strTemp = CommonUtil.formatFloat((String) vRows.elementAt(o+46),true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));				
			}			
			dTotalDeduction += dTemp;
			if(dTemp == 0d)
			  strTemp = "";	
		   %>
          <td align="right" class="NoBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
        </tr>
			<%			
			for(iCols = 1, iColCounter = 1;iColCounter <= iDedColCount; iCols ++, iColCounter+=2){
				strTemp = (String)vDedCols.elementAt(iColCounter);			
			%>		
        <tr>
          <td height="13">&nbsp;</td>
          <td class="NoBorder"><%=strTemp%></td>
			  <%
				strTemp = (String)vDeductions.elementAt(iCols);
				dTemp = Double.parseDouble(strTemp);
				dTotalDeduction += dTemp;
				if(dTemp == 0d)
					strTemp = "";									
				%>					
          <td align="right" class="NoBorder"><%=strTemp%>&nbsp;</td>
        </tr>
        <%}%>
        <tr>
          <td height="13">&nbsp;</td>
          <td class="NoBorder">Others</td>
          <% 
				strTemp = (String) vRows.elementAt(o+33);//LEAVE_DEDUCTION_AMT
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				
				//System.out.println("LEAVE_DEDUCTION_AMT " + dOtherDeduction);
						// misc_deduction
				if (vRows.elementAt(o + 45) != null){	
					strTemp = (String)vRows.elementAt(o + 45); 
					strTemp = ConversionTable.replaceString(strTemp,",","");
					if (strTemp.length() > 0){				
						dOtherDeduction += Double.parseDouble(strTemp);
					}			
				}			
				//System.out.println("misc_deduction " + dOtherDeduction);
				strTemp = (String) vRows.elementAt(o+48);//LATE_UNDER_AMT
				dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
				strTemp = CommonUtil.formatFloat(dOtherDeduction,2);
				dTotalDeduction += dOtherDeduction;
				//System.out.println("LATE_UNDER_AMT " + strTemp);
				if(dOtherDeduction ==0d)
					strTemp = "";
		   %>
          <td align="right" class="NoBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
        </tr>
      </table></td>
      <td valign="top" class="thinborderBOTTOMLEFT">&nbsp;</td>
    </tr>
    <tr>
      <td height="20" width="34%">&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td width="17%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="60%"><font size="1">GROSS PAY:</font></td>
          <td width="40%"><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%>&nbsp;</font></div></td>
        </tr>
      </table></td>
      <td width="24%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="64%"><span class="thinborderTOP"><font size="1"><strong>&nbsp;&nbsp;&nbsp;TOTAL DEDUCTION</strong></font></span></td>
          <td width="36%"><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%>&nbsp;&nbsp;&nbsp;</font></div></td>
          </tr>
      </table></td>
      <td width="16%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="53%">NET PAY </td>
            <%
				dNetSalary += dGrossSalary - dTotalDeduction + dUnreleasedSalary;
			%>		  
          <td width="47%"><div align="right"><font size="1"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%>&nbsp;</strong></font></div></td>
        </tr>
      </table></td>
    </tr>
  </table>
  <%}%>
  <%}// display if (vRows!= null && vRows.size() > 2%>
  <%if (vRows != null && vRows.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <%}%>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">  
	<input type="hidden" name="is_for_sheet" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>