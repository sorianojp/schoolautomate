<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.noBorder {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.BorderTop {
	border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }

</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./payroll_summary_bystatus.jsp">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
<%  WebInterface WI = new WebInterface(request);

	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;

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
								"Admin/staff-Payroll-REPORTS-Payroll Summary by status","payroll_summary_bystatus.jsp");
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
//end of authenticaion code.

	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	Vector vRetLoans  = null;
	Vector vEarnings  = null;
	Vector vDeductions  = null;
	Vector vEarnHeadings  = null;

	ReportPayroll RptPay = new ReportPayroll(request);
	Vector vSummary = null;
	Vector vTemp = null;
	Vector vEarnSummary = null;
	String strPayrollPeriod  = null;
	String[] astrPtFt = {"Part-Time","Full-Time","",""};
//	String strPeriodFr = null;
//	String strPeriodTo = null;
	boolean bolPageBreak = false;
	boolean bolSummary = false;
	int iStringLen = 15;
	
	double dPeriodRate     = 0d;
	double dGrossPay       = 0d;
	double dOtherDeduction = 0d;
	double dTotalDeduction = 0d;
	double dNetPay         = 0d;
	double dNoSalary       = 0d;
	double dTemp           = 0d;
	 int iTotRows = 3;/// THIS IS TO EASILY CONTROL THE NUMBER OF ROWS TO VIEW.
	int iNoSalary = 0;

	vRetResult = RptPay.searchByStatusExt(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	
	if (vRetResult != null && vRetResult.size() > 0) {
	int i = 0; int k = 0; int iCount = 0;
	int iMaxRecPerPage =10; 
	
	if (WI.fillTextValue("num_rec_page").length() > 0){
		iMaxRecPerPage = Integer.parseInt(WI.fillTextValue("num_rec_page"));
	}
	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iColumn = 0;
	int iColCount = 0;

	for (;iNumRec < vRetResult.size();){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="24"><div align="center">&nbsp;</div></td>
      <td height="24"><font size="1">&nbsp;</font></td>
      <%
	 	strTemp = WI.fillTextValue("sal_period_index");		

		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
					break;
		  //strPeriodFr = (String)vSalaryPeriod.elementAt(i + 1);
		  //strPeriodTo = (String)vSalaryPeriod.elementAt(i + 2);
      }
		}
		%>
      <td height="24"><div align="center"><strong><font size="1">
	  <%if (WI.fillTextValue("is_atm").equals("1")){%>
	    (ATM)
	  <%}%> 
	  Employees in the Payroll of <%=astrPtFt[Integer.parseInt(WI.getStrValue(WI.fillTextValue("pt_ft"),"2"))]%><br>
	  <%=WI.getStrValue(strPayrollPeriod,"")%>
	  </font></strong></div></td>
      <td height="24" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="5"><hr size="1" color="#666666"></td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="15%"><div align="center"><font size="1"><strong>ACCOUNT #</strong></font></div></td>
      <td width="69%"><div align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>TOTAL </strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>NET PAY</strong></font></div></td>
    </tr>
    <% 
		int iRow = 0;
//	if (vRetResult != null && vRetResult.size() > 0){
	  for(iCount=1; iNumRec < vRetResult.size(); iNumRec += 37,++iCount,++iIncr){
	  i = iNumRec;
		vRetLoans = (Vector) vRetResult.elementAt(iNumRec+33);
		vEarnings = (Vector) vRetResult.elementAt(iNumRec+34);
		vEarnHeadings= (Vector) vRetResult.elementAt(iNumRec+35);
		vDeductions = (Vector) vRetResult.elementAt(iNumRec+36);
		//vFacultySalary = (Vector) vRetResult.elementAt(i+32);
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;
		iRow = 1;
		iColCount = 0;
	  %>
    <tr> 
      <td align="right" valign="top" class="noBorder"><%=iIncr%>&nbsp;</td>
      <td height="18" valign="top" class="noBorder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1)," ")%><br> &nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+2)), (String)vRetResult.elementAt(i+3),
							((String)vRetResult.elementAt(i+4)), 4)%><br> &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+32)," ")%></td>
      <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr valign="top">
          <td width="15%" height="15" class="noBorder">Salary</td>
          <%  strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+8)),true);
							if(!((String)vRetResult.elementAt(i+28)).equals("1")){				
								dGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
							}
						%>
          <td width="10%" align="right" class="noBorder"> <%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td><%
					for(iColumn = 0; iColumn < vEarnHeadings.size(); iColumn+=2){
							strTemp = (String)vEarnHeadings.elementAt(iColumn);
					  if (strTemp.length() > iStringLen){							
							strTemp = strTemp.substring(0,iStringLen);
					  }							
						%>
          <td width="15%" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
          <%
							strTemp = (String)vEarnHeadings.elementAt(iColumn+1);
							dGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						%>
          <td width="10%" align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          <%iColCount++;
						if(iColCount==3)
								break;
					}%>
          <%// these are just fillers.. para fili maguba ang table					
					for(; iColCount < 3; iColCount++){%>
          <td width="15%" class="noBorder">&nbsp;</td>
          <td width="10%" class="noBorder">&nbsp;</td>
          <%}%>
        </tr>
        <%if(vEarnHeadings != null && vEarnHeadings.size() > 6){										
					iColumn = 6;
					for(;iColumn < vEarnHeadings.size();){
					iColCount = 0;
				%>
				
        <tr valign="top">
          <%for(; iColumn < vEarnHeadings.size(); iColumn+=2,iColCount++){%>
          <%
							strTemp = (String)vEarnHeadings.elementAt(iColumn);
					  if (strTemp.length() > iStringLen){							
							strTemp = strTemp.substring(0,iStringLen);
					  }								
						%>
          <td class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
          <%
							strTemp = (String)vEarnHeadings.elementAt(iColumn+1);
							dGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						%>
          <td  align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          <%if(iColCount ==3)
								break;
						}%>
          <%// fillers po ito for earnings... do not touch
					for(; iColCount < 3; iColCount++){%>
          <td class="noBorder">&nbsp;</td>
          <td class="noBorder">&nbsp;</td>
          <%}%>
        </tr>
        <%} //for(;iColumn < vEarnHeadings.size();)
				}// vEarnHeadings != null && vEarnHeadings.size() > 6%>
        <%if(vDeductions != null && vDeductions.size() > 0){
					iColumn = 0;
					for(; iColumn < vDeductions.size();){
						iColCount = 0;
					%>
        <tr valign="top">
          <%
						for(; iColumn < vDeductions.size(); iColumn+=2,iColCount++){
							iColCount = 0;
							strTemp = (String)vDeductions.elementAt(iColumn);
						%>
          <td class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
          <%
							strTemp = (String)vDeductions.elementAt(iColumn + 1);
							dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						%>
          <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          <%
						if(iColCount==3)
								break;
					} // for loop%>
          <% // fillers sa deductions
					for(; iColCount < 3; iColCount++){%>
          <td class="noBorder" width="15%" >&nbsp;</td>
          <td class="noBorder" width="10%" >&nbsp;</td>
          <%}// complete the columns%>
        </tr>
        <%}// outer for loop
				 } // if(vDeductions != null && vDeductions.size() > 0%>
        <%if(vRetLoans != null && vRetLoans.size() > 0){
					iColumn = 0;
					for(; iColumn < vRetLoans.size();){
						iColCount = 0;
					%>
        <tr valign="top">
          <%
						for(; iColumn < vRetLoans.size(); iColumn+=3,iColCount++){
							iColCount = 0;
				      strTemp = (String) vRetLoans.elementAt(iColumn);
							strTemp = ConversionTable.replaceString(strTemp," ","");
								if (strTemp.length() > iStringLen - 4 && (vRetLoans.elementAt(iColumn+2) != null) ){							
								strTemp = strTemp.substring(0,iStringLen -4);
								}
							strTemp += WI.getStrValue((String)vRetLoans.elementAt(iColumn+2),"&nbsp;");												
						%>
          <td class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
          <%
							strTemp = (String)vRetLoans.elementAt(iColumn + 1);
							dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						%>
          <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          <%
						if(iColCount==3)
							break;
						} // for loop%>
          <% // fillers sa Loans
					for(; iColCount < 3; iColCount++){%>
          <td class="noBorder">&nbsp;</td>
          <td class="noBorder">&nbsp;</td>
          <%}// complete the columns%>
        </tr>
        <%}// outer for loop
				 } // if(vDeductions != null && vDeductions.size() > 0%>
      </table>
      <%if(((String)vRetResult.elementAt(i+28)).equals("1")){
			iNoSalary++;
			dNoSalary += Double.parseDouble((String)vRetResult.elementAt(i+9));
		%> 
		<font color="#FF0000"><strong>&nbsp;Employee on leave</strong></font>		
        <%}%> </td>
      <td align="right" valign="top" class="noBorder"> <%=WI.getStrValue(CommonUtil.formatFloat(dGrossPay,true),"")%>&nbsp;<br>
        <%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"")%>&nbsp;<br>
        <%if (vRetResult.elementAt(i+5) != null && Double.parseDouble((String)vRetResult.elementAt(i+5)) != 0){					    
		dGrossPay += Double.parseDouble((String)vRetResult.elementAt(i+5));
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
	     %>
        <%=WI.getStrValue(strTemp,"")%>&nbsp; 
        <%}%>      </td>
      <%
	  	dNetPay = dGrossPay - dTotalDeduction;
		dGrossPay = 0d;
		dTotalDeduction = 0d;
	  %>
      <td align="right" valign="bottom" class="noBorder"><%=WI.getStrValue(CommonUtil.formatFloat(dNetPay,true)," ")%>&nbsp;</td>
    </tr>
    <tr> 
      <td height="10"></td>
      <td></td>
      <td colspan="3" valign="top"><hr size="1" color="#666666"></td>
    </tr>
    <%//}// end if (vRetResult != null && vRetResult.size() > 0)
	} // end for(i = 0,iCount=1; i < vRetResult.size(); i += 30,++iCount)
	%>
  </table>
    <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break only if it is not last page.
} //end for (iNumRec < vRetResult.size()
%>	
  <DIV style="page-break-before:always" >&nbsp;</DIV>
  <% 
  	vSummary = RptPay.summaryByStatus(dbOP);	
	if(vSummary != null && vSummary.size() > 0){
		vTemp = (Vector) vSummary.elementAt(23);
		vEarnSummary = (Vector) vSummary.elementAt(24);
		dNetPay = 0d;
		dGrossPay = 0d;
		dTotalDeduction = 0d;
  %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="30" colspan="7"><div align="center"><strong><font size="1"><%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></div></td>
    </tr>
    <tr> 
      <td height="18" colspan="7"><hr size="1" color="#666666"></td>
    </tr>
    <tr> 
      <td width="4%"><div align="center"></div></td>
      <td colspan="2"><div align="center"><font size="1">INCOME</font></div></td>
      <td width="4%"><font size="1">&nbsp;</font></td>
      <td width="27%"><div align="center"><font size="1">&nbsp;</font><font size="1">DEDUCTIONS</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td class="noBorder">&nbsp;</td>
      <td colspan="2" valign="top" class="noBorder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr> 
            <td width="77%" class="noBorder">Emp with no Salary</td>
            <td width="23%" align="right" class="noBorder"><%=WI.getStrValue(CommonUtil.formatFloat(dNoSalary,true),"&nbsp;")%>&nbsp;</td>
          </tr>
          <tr> 
            <td class="noBorder">Salary</td>
            <%strTemp = "";
			if (vSummary.elementAt(3) != null){
				strTemp = (String)vSummary.elementAt(3);
				dGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			}
		  %>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%strTemp = "";
		  	dTemp = 0d;
			if (vSummary.elementAt(18) != null){
				strTemp = (String)vSummary.elementAt(18);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">COLA</td>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%}%>
          <%strTemp = "";
			  dTemp = 0d;
			if (vSummary.elementAt(4) != null){
				strTemp = (String)vSummary.elementAt(4);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Overtime</td>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%}%>
          <% strTemp = "";
			  dTemp = 0d;			
			if (vSummary.elementAt(15) != null){
				strTemp = (String)vSummary.elementAt(15);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Night Differential</td>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%}%>
          <%strTemp = "";
			  dTemp = 0d;						
			if (vSummary.elementAt(16) != null){
				strTemp = (String)vSummary.elementAt(16);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Holiday Pay</td>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%}%>
          <%strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(1) != null){
				strTemp = (String)vSummary.elementAt(1);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Hon</td>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%}%>
          <%strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(22) != null){
				strTemp = (String)vSummary.elementAt(22);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Overload</td>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%}%>          
          <%strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(11) != null){
				strTemp = (String)vSummary.elementAt(11);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Addl Pay</td>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%}%>
          <%strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(13) != null){
				strTemp = (String)vSummary.elementAt(13);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Other Bonus </td>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%}%>
          <%strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(17) != null){
				strTemp = (String)vSummary.elementAt(17);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Addl. Resp</td>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%}%>
          <%strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(21) != null){
				strTemp = (String)vSummary.elementAt(21);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Faculty Salary </td>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%}%>																									
          <%
		  if(vEarnSummary!= null && vEarnSummary.size() > 0){
			for(i = 0; i < vEarnSummary.size(); i+=2){
			strTemp = (String)vEarnSummary.elementAt(i+1);
			dGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
		  %>
          <tr> 
            <td class="noBorder">&nbsp;<%=(String)vEarnSummary.elementAt(i)%></td>
            <td align="right" class="noBorder"><%=strTemp%>&nbsp;</td>
          </tr>
          <%}// for(i = 0; i < vTemp.size(); i+=2)
		 }// if vTemp != null%>
		 		  
		  <%strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(0) != null){
				strTemp = (String)vSummary.elementAt(0);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp != 0){%>
          <tr> 
            <td class="noBorder">&nbsp;Adjustment</td>
            <td align="right" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
          </tr>
          <%}%>		  
        </table></td>
      <td>&nbsp;</td>
      <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <% strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(14) != null){
				strTemp = (String)vSummary.elementAt(14);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dTotalDeduction += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td width="71%" class="noBorder">&nbsp;TxWitheld</td>
            <td width="29%" class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <% strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(8) != null){
				strTemp = (String)vSummary.elementAt(8);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dTotalDeduction += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">&nbsp;Pag-Ibig</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <% strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(6) != null){
				strTemp = (String)vSummary.elementAt(6);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dTotalDeduction += dTemp;
			}
		    %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">&nbsp;SSS</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <%strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(7) != null){
				strTemp = (String)vSummary.elementAt(7);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dTotalDeduction += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">&nbsp;PhilHealth</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <%strTemp = "";
					dTemp = 0d;
					if (vSummary.elementAt(20) != null){
						strTemp = (String)vSummary.elementAt(20);
						dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						dTotalDeduction += dTemp;
					}
					%>
          <%if (dTemp > 0){%>					
					<tr>
            <td class="noBorder">&nbsp;Tardiness / undertime </td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <%strTemp = "";
					dTemp = 0d;
					if (vSummary.elementAt(19) != null){
						strTemp = (String)vSummary.elementAt(19);
						dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						dTotalDeduction += dTemp;
					}
					%>
          <%if (dTemp > 0){%>					
					<tr>
            <td class="noBorder">&nbsp;Absences</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <%strTemp = "";
					dTemp = 0d;
					if (vSummary.elementAt(5) != null){
						strTemp = (String)vSummary.elementAt(5);
						dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						dTotalDeduction += dTemp;
					}
					%>
          <%if (dTemp > 0){%>					
					<tr>
            <td class="noBorder">&nbsp;Leave Deduction  </td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <%strTemp = "";
					dTemp = 0d;
					if (vSummary.elementAt(12) != null){
						strTemp = (String)vSummary.elementAt(12);
						dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
						dTotalDeduction += dTemp;
					}
					%>
          <%if (dTemp > 0){%>					
					<tr>
            <td class="noBorder">&nbsp;Other Deduction </td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>															
          <%
		  if(vTemp!= null && vTemp.size() > 0){
			for(i = 0; i < vTemp.size(); i+=2){
			strTemp = (String)vTemp.elementAt(i+1);
			dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
		  %>
          <tr> 
            <td class="noBorder">&nbsp;<%=(String)vTemp.elementAt(i)%></td>
            <td class="noBorder"><div align="right"><%=strTemp%>&nbsp;</div></td>
          </tr>
          <%}// for(i = 0; i < vTemp.size(); i+=2)
		 }// if vTemp != null%>
        </table></td>
      <td>&nbsp;</td>
      <td valign="top"><font size="1">Total Emp : <%=iIncr-1%><br>
        No Salary: <%=iNoSalary%>&nbsp;&nbsp;&nbsp;&nbsp;Pay Slips: <%=(iIncr-1-iNoSalary)%></font></td>
    </tr>
    <tr> 
      <td class="noBorder">&nbsp;</td>
      <td width="15%" align="right" valign="top" class="noBorder">TOTAL&nbsp;&nbsp;</td>
      <td width="13%" align="right" valign="top" class="noBorder"><%=CommonUtil.formatFloat(dGrossPay,true)%>&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top" class="noBorder"><div align="right"><%=CommonUtil.formatFloat(dTotalDeduction,true)%>&nbsp;</div></td>
      <%dNetPay = dGrossPay - dTotalDeduction; %>
      <td width="7%" class="noBorder"><div align="right"><%=CommonUtil.formatFloat(dNetPay,true)%>&nbsp;</div></td>
      <td width="30%"><u><font size="1"><strong>NET PAY</strong></font></u></td>
    </tr>
  </table> 
	<%}//if(vSummary != null && vSummary.size() > 0)%>
  <%
  if(iNoSalary > 0){
	  dNoSalary = 0d;
  %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="2"><hr size="1" color="#333333"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="5"><font size="1">List of Employees without pay slips</font></td>
    </tr>
    <tr> 
      <td width="7%"><font size="1">&nbsp;</font></td>
      <td width="27%"><font size="1">Name</font></td>
      <td width="27%">&nbsp;</td>
      <td width="13%"><div align="center"><font size="1">Basic</font></div></td>
      <td width="26%"><font size="1">&nbsp;</font></td>
    </tr>
    <%for(i=0, iIncr = 1; i < vRetResult.size(); i+=32){
		if(!((String)vRetResult.elementAt(i + 28)).equals("1")){
			continue;
		}
	%>
    <tr> 
      <td class="noBorder"><div align="right"><%=iIncr%>.&nbsp;</div></td>
      <td class="noBorder">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+2)), (String)vRetResult.elementAt(i+3),
							((String)vRetResult.elementAt(i+4)), 4)%>&nbsp;#<%=(i/30) + 1%>&nbsp;pg<%=(i/30/10) + 1%></td>
	  <%if((String)vRetResult.elementAt(30) != null)
	  		strTemp = (String)vRetResult.elementAt(30);
		else
			strTemp = (String)vRetResult.elementAt(31);
	  %>
      <td class="noBorder"><%=strTemp%></td>
      <% 
		strTemp = "";					   
		dNoSalary += Double.parseDouble((String)vRetResult.elementAt(i+9));				
	    strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true);
	%>
      <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
      <td>&nbsp;</td>
    </tr>
    <%++iIncr;
	}// for(i=0, iIncr = 1; i < vRetResult.size(); i+=30)%>
    <tr> 
      <td class="noBorder">&nbsp;</td>
      <td class="noBorder"><div align="right"></div></td>
      <td class="noBorder"><div align="right">Total: </div></td>
      <td class="BorderTop"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dNoSalary,true),"&nbsp;")%>&nbsp;</div></td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}// if i found an employee on leave sa list%>
  
<%} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>