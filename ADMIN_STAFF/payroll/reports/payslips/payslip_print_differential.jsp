<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Payslip - Differential</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

	TD.thinborderHeader {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPLEFTRIGHT {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPRIGHT {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPLEFT {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPBOTTOMRIGHT {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOMRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
</style>
</head>

<script language="JavaScript">
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
</script>

<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, hr.HRInfoPersonalExtn" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;	

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-EmployeePayslip","payslip_print_differential.jsp");
								
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

	Vector vSalaryRange 	= null;//detail of salary period.
	Vector vPersonalDetails = new Vector(); 
	Vector vMiscDeductions  = null;
	Vector vLoans           = null;
	double dDifferential    = 0d;
	HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
	ReportPayroll RptPay = new ReportPayroll(request);	
		
	String strEmpID = WI.fillTextValue("emp_id");
	String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
	String strPayrollPeriod = null;
	String strDiffIndex = WI.fillTextValue("differential_index");
	String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
							"September","October","November","December"};
							
if (strEmpID.length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");	
}

if(strDiffIndex.length() > 0) {			
	dDifferential = RptPay.computeEmpDifferential(dbOP, strDiffIndex);
}

double dTotalDeduction = 0d;
double dTemp = 0d;
String[] astrPtFt = {"Part-Time","Full-Time",""};
	
%>

<body onLoad="CloseWnd();">
<form>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#000000">
    <tr> 
      <td colspan="3"><div align="center"><font size="1"> Employee Receipt No. 
          <%=WI.fillTextValue("rec_no")%>&nbsp;Additional Month Differential Payroll</font></div></td>
      <td><div align="center"></div></td>
    </tr>
    <tr> 
      <td colspan="3"><font size="1">Received from company, the amount stated 
        below, which is accepted in full for the period&nbsp;<%=WI.getStrValue(strPayrollPeriod,"0")%></font></td>
      <td><font size="1"> Employee Receipt No. <%=WI.fillTextValue("rec_no")%>&nbsp;</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="13%">&nbsp;</td>
      <td width="26%">&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td colspan="2">Name : 
        <%			
	  if (vPersonalDetails != null && vPersonalDetails.size() > 0 ) {%> <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> <%}%> &nbsp; </td>
      <td><div align="right"><font size="1"><%=WI.getStrValue(WI.fillTextValue("emp_id"),"EmpNo. ","","")%>&nbsp;</font></div></td>
      <td><font size="1">&nbsp;&nbsp;Name : 
        <%			
	  if (vPersonalDetails != null && vPersonalDetails.size() > 0 ) {%>
        <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> 
        <%}%>
        </font></td>
    </tr>
    <tr> 
      <%	
		if (vPersonalDetails!= null && vPersonalDetails.size() > 0 ) {			
			strTemp = (String)vPersonalDetails.elementAt(15);
		}else{
			strTemp = null;	
		}			
		%>
      <td colspan="3"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <font size="1"><%=astrPtFt[Integer.parseInt(WI.getStrValue(WI.fillTextValue("pt_ft"),"2"))]%> <%=WI.getStrValue(strTemp,"",","," ")%> 
        <%if(vPersonalDetails.elementAt(13) != null && vPersonalDetails.elementAt(14) != null){
			strTemp = ";";
		  }else{
			strTemp = "";	
		  }
		%>
        <%=WI.getStrValue((String)vPersonalDetails.elementAt(13),"")%> <%=strTemp%> <%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"")%> 
        <%if(WI.fillTextValue("is_atm").equals("1")){%>
        &nbsp;(ATM) 
        <%}%>
        </font> <div align="right"></div></td>
      <td> <font size="1"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=astrPtFt[Integer.parseInt(WI.getStrValue(WI.fillTextValue("pt_ft"),"2"))]%> 
        <%	
		if (vPersonalDetails!= null && vPersonalDetails.size() > 0 ) {			
			strTemp = (String)vPersonalDetails.elementAt(15);
		}else{
			strTemp = null;	
		}			
		%>
        <%=WI.getStrValue(strTemp," ")%></font></td>
    </tr>
    <tr> 
      <td colspan="2">&nbsp;</td>
      <td><div align="right"><font size="1"><%=WI.getStrValue(WI.fillTextValue("bank_account"),"Bank Acct: ","","")%>&nbsp;</font></div></td>
      <td><font size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="18"><div align="left"><font size="1"><strong>EARNINGS</strong></font></div></td>
      <td height="18"><font size="1">&nbsp;<strong>DEDUCTION</strong></font></td>
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td width="32%" height="181" valign="top" class="thinborderTOPLEFT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="63%"><font size="1">Salary Differential</font></td>
            <%
				strTemp = CommonUtil.formatFloat(dDifferential,true);				
			%>
            <td width="37%" height="15"><div align="right"><font size="1"><%=WI.getStrValue(strTemp," ")%>&nbsp;</font></div></td>
          </tr>
        </table></td>
      <td colspan="2" valign="top" class="thinborderTOPLEFT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <%if(vLoans != null && vLoans.size() > 0){
		  	  for(int i = 0; i < vLoans.size(); i+=6){
		  %>
          <%
		  	  strTemp = (String)vLoans.elementAt(i+1);
			  dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			  dTotalDeduction += dTemp;
		  %>
          <%if(dTemp > 0){%>
          <tr> 
            <%  
				if(((String)vLoans.elementAt(i+4)).equals("0"))
					strTemp = " - Retirement";
				else if(((String)vLoans.elementAt(i+4)).equals("1"))
					strTemp = " - Emergency";
				else
					strTemp = "";
			%>
            <td width="55%" height="15"><font size="1">&nbsp;&nbsp;<%=(String)vLoans.elementAt(i+2)%><%=WI.getStrValue((String)vLoans.elementAt(i+3)," - ","",strTemp)%></font></td>
            <td width="45%"><div align="right"><font size="1"><%=(String)vLoans.elementAt(i+1)%>&nbsp;&nbsp;</font></div></td>
          </tr>
          <%}%>
          <%}
		  }%>
          <%if(vMiscDeductions != null && vMiscDeductions.size() > 0){
		  	  for(int i = 0; i < vMiscDeductions.size(); i+=4){
		  %>
          <%
		  	  strTemp = (String)vMiscDeductions.elementAt(i+1);
			  dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			  dTotalDeduction += dTemp;
		  %>
          <%if(dTemp > 0){%>
          <tr> 
            <td height="15"><font size="1">&nbsp;&nbsp;<%=(String)vMiscDeductions.elementAt(i+2)%></font></td>
            <td><div align="right"><font size="1"><%=(String)vMiscDeductions.elementAt(i+1)%>&nbsp;&nbsp;</font></div></td>
          </tr>
          <%}// end dTemp > 0%>
          <%}
		  }%>
        </table></td>
      <td width="29%" valign="top" class="thinborderTOPLEFTRIGHT"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <%if(vPersonalDetails.elementAt(13) != null && vPersonalDetails.elementAt(14) != null){
				strTemp = ";";
			  }else{
			  	strTemp = "";	
			  }
			%>
            <td colspan="2" height="20"><div align="center"><font size="1"><%=WI.getStrValue((String)vPersonalDetails.elementAt(13),"")%><%=strTemp%> <%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"")%></font></div></td>
          </tr>
          <tr> 
            <td width="66%" height="20">&nbsp;</td>
            <td width="34%">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2" height="20"><font size="1">&nbsp;Period of <%=WI.getStrValue(strPayrollPeriod,"0")%></font></td>
          </tr>
          <tr> 
            <td height="10"></td>
            <td></td>
          </tr>
          <tr> 
            <td height="20"><font size="1">&nbsp;Gross Earnings</font></td>
            <td><div align="right"><font size="1"><%=CommonUtil.formatFloat(dDifferential,true)%>&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="20"><font size="1">&nbsp;Total Deductions</font></td>
            <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%>&nbsp;</font></div></td>
          </tr>
          <%
		  	dTemp = dDifferential - dTotalDeduction;
		  %>
          <tr> 
            <td height="20"><font size="1">&nbsp;NET PAY</font></td>
            <td><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</font></div></td>
          </tr>
          <tr> 
            <td height="10"></td>
            <td></td>
          </tr>
          <tr> 
            <td colspan="2" height="20"><font size="1">&nbsp;Payment RECEIVED:</font></td>
          </tr>
          <tr> 
            <td colspan="2" height="18"><font size="1">&nbsp;<%=WI.getStrValue(WI.fillTextValue("bank_account"),"Bank Acct: ","","")%>&nbsp;&nbsp;</font></td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="38" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="61%" height="18"><font size="1">&nbsp;TOTAL</font></td>
            <td width="24%"><div align="right"><strong><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dDifferential,true),"0.00")%></font></strong></div></td>
          </tr>
        </table></td>
      <td colspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="54%" height="18"><font size="1">&nbsp;TOTAL</font></td>
            <td width="46%"><div align="right"><strong><font size="1"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%></strong>&nbsp;&nbsp;</font></strong></div></td>
          </tr>
        </table></td>
      <td valign="top" class="thinborderBOTTOMLEFTRIGHT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="8%" height="18"><font size="1">&nbsp;</font></td>
            <td width="31%" class="thinborderBOTTOM">&nbsp;</td>
            <td width="12%">&nbsp;</td>
            <td width="38%" class="thinborderBOTTOM">&nbsp;</td>
            <td width="11%">&nbsp;</td>
          </tr>
          <tr> 
            <td height="18">&nbsp;</td>
            <td><div align="center"><font size="1">Date</font></div></td>
            <td>&nbsp;</td>
            <td><div align="center"><font size="1">Signature</font></div></td>
            <td>&nbsp;</td>
          </tr>
        </table></td>
    </tr>
  </table>
  <input type="hidden" name="sal_period_index" value="<%=WI.fillTextValue("sal_period_index")%>">
  <input type="hidden" name="bank_account" value="<%=WI.fillTextValue("bank_account")%>">
  <input type="hidden" name="pt_ft" value="<%=WI.fillTextValue("pt_ft")%>">
  <input type="hidden" name="is_atm" value="<%=WI.fillTextValue("is_atm")%>">
  <input type="hidden" name="diff_amount" value="<%=WI.fillTextValue("diff_amount")%>">
  <input type="hidden" name="finalize" value="<%=WI.fillTextValue("finalize")%>">  
</form>

<script src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//get this from common.js
//this.autoPrint();
//window.setInterval("javascript:window.close();",0);
//this.closeWnd = 1;
//or use this so that the window will not close
window.setInterval("javascript:window.print();",0);
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>