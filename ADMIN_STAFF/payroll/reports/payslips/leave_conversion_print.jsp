<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Payslip - Leave Conversion</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborder {
			border-top: solid 1px #000000;
			border-right: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 11px;	
		}
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

<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRLeaveConversion,
																 hr.HRInfoPersonalExtn" %>
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
	Vector vEditInfo				= null;
	Vector vLeaves = null;
	int l = 0;
	
	double dConverted    = 0d;
	HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
	PRLeaveConversion prLeave = new PRLeaveConversion();	
		
	String strEmpID = WI.fillTextValue("emp_id");
	String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
	String strPayrollPeriod = null;
	String[] astrConvertMonth = {"January", "February", "March", "April", "May", "June", "July",
															 "August", "September", "October", "November", "December"};
	String strConvIndex = WI.fillTextValue("conversion_index");
	
	strTemp = WI.getStrValue(WI.fillTextValue("total_amount"),"0");
	strTemp = ConversionTable.replaceString(strTemp,",","");
	dConverted = Double.parseDouble(strTemp);
								
	if (strEmpID.length() > 0) {
			enrollment.Authentication authentication = new enrollment.Authentication();
			vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");	
	}
	
	if(strConvIndex.length() > 0){
		vEditInfo = prLeave.operateOnLeaveConversion(dbOP, request, 4, strConvIndex);
		if(vEditInfo == null){
 			strErrMsg = prLeave.getErrMsg();		
		}else{
			vLeaves = (Vector)vEditInfo.elementAt(1);
			vLoans = (Vector)vEditInfo.elementAt(4);
			vMiscDeductions = (Vector)vEditInfo.elementAt(6);
		}
		//vLoans = salaryExtn.getSavedLoans(dbOP, "conversion_index", strConvIndex);
		//vMiscDeductions= salaryExtn.getSavedMiscDeductions(dbOP, "conversion_index", strConvIndex);		
		
		if(WI.fillTextValue("finalize").length() > 0){
			if(!prLeave.releaseLeaveCredit(dbOP,request,strConvIndex))
				strErrMsg = "Error";
		}
	}	

double dTotalDeduction = 0d;
double dTemp = 0d;
String[] astrPtFt = {"Part-Time","Full-Time",""};
	
%>

<body onLoad="CloseWnd();">
<form>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#000000">
    <tr> 
      <td colspan="3"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
      </font></div></td>
    </tr>
    <tr> 
      <td colspan="3"><div align="center">LEAVE CONVERSION PAYSLIP</div></td>
    </tr>
    <tr> 
      <td colspan="3"><div align="center"><%=WI.getTodaysDate(11)%></div></td>
    </tr>
    <tr> 
      <td colspan="2">NAME :        
        <%			
	  if (vPersonalDetails != null && vPersonalDetails.size() > 0 ) {%>
        <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong>
      <%}%></td>
      <td width="50%">PERIOD: YEAR <%=WI.fillTextValue("year_of")%></td>
    </tr>
    <tr> 
      <%	
		if (vPersonalDetails!= null && vPersonalDetails.size() > 0 ) {			
			strTemp = (String)vPersonalDetails.elementAt(15);
		}else{
			strTemp = null;	
		}			
		%>
      <td width="19%">BANK ACCOUNT NO. :
        <div align="right"></div></td>
      <td colspan="2">&nbsp;<%=WI.getStrValue(WI.fillTextValue("bank_account"))%></td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#000000">
    <tr> 
      <td height="18" align="right"><font size="1"><strong>EARNINGS</strong></font>&nbsp;</td>
      <td width="50%" height="18" align="right"><font size="1">&nbsp;<strong>DEDUCTION&nbsp;</strong></font></td>
    </tr>
    <tr> 
      <td width="50%" height="91" valign="top" class="thinborderTOPLEFT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="68%"><font size="1">RATE / DAY </font></td>
            <td width="32%" height="15"><div align="right"><font size="1"><%=WI.fillTextValue("daily_rate")%>&nbsp;</font></div></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td height="15">&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td height="15">&nbsp;</td>
          </tr>
          <tr>
            <td height="15" colspan="2" class="thinborderNONE">
						<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">        
            <%if(vLeaves != null && vLeaves.size() > 0){%>
          <tr>
            <td width="68%" align="center" class="thinborder"><font size="1"><strong>LEAVE NAME </strong></font></td>
              <td width="32%" align="center" class="thinborder"><strong><font size="1">CONVERTED</font></strong></td>
            </tr>
          <%
				  for (l = 0; l < vLeaves.size(); l+=4){%>
            <tr>
              <%
							strTemp = (String)vLeaves.elementAt(l+1);
							%>
              <td height="18" class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
              <%
								strTemp = CommonUtil.formatFloat((String)vLeaves.elementAt(l+2), false);								
 							%>
              <td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"0")%></td>
            </tr>
            <%}%>
          <%}// end if vLeaves != null%>
          </table></td>
          </tr>
          <!--
					<tr>
            <td class="thinborderNONE">CONVERTED LEAVES</td>						
            <td height="15"><div align="right"><font size="1"><%=WI.fillTextValue("total_days")%>&nbsp;</font></div></td>
          </tr>
					-->
          <tr>
            <td>&nbsp;</td>
            <td height="15">&nbsp;</td>
          </tr>
          
        </table></td>
      <td valign="top" class="thinborderTOPLEFTRIGHT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
       <%if(vLoans != null && vLoans.size() > 0){
		  	   for(int i = 1; i < vLoans.size(); i+=8){
		 	 %>
			<%
				strTemp = (String)vLoans.elementAt(i+1);
			  dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			  dTotalDeduction += dTemp;
		  %>
          <%if(dTemp > 0){%>
          <tr> 
            <%  
				if(((String)vLoans.elementAt(i+6)).equals("0"))
					strTemp = " - Retirement";
				else if(((String)vLoans.elementAt(i+6)).equals("1"))
					strTemp = " - Emergency";
				else
					strTemp = "";
			%>
            <td width="55%" height="15"><font size="1">&nbsp;&nbsp;<%=(String)vLoans.elementAt(i+4)%><%=WI.getStrValue((String)vLoans.elementAt(i+5)," - ","",strTemp)%></font></td>
            <td width="45%"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;&nbsp;</font></div></td>
          </tr>
          <%}%>
          <%}
		  }%>
          <%if(vMiscDeductions != null && vMiscDeductions.size() > 0){
		  	  for(int i = 1; i < vMiscDeductions.size(); i+=4){
		  %>
          <%
		  	  strTemp = (String)vMiscDeductions.elementAt(i+2);
			  dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			  dTotalDeduction += dTemp;
		  %>
          <%if(dTemp > 0){%>
          <tr> 
            <td height="15"><font size="1">&nbsp;&nbsp;<%=(String)vMiscDeductions.elementAt(i+1)%></font></td>
            <td><div align="right"><font size="1"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;&nbsp;</font></div></td>
          </tr>
          <%}// end dTemp > 0%>
          <%}
		  }%>
      </table>
			 </td>
    </tr>
    <tr> 
      <td height="38" rowspan="2" valign="top" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="61%" height="18"><font size="1">&nbsp;GROSS PAY</font></td>
            <td width="24%"><div align="right"><strong><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dConverted,true),"0.00")%>&nbsp;</font></strong></div></td>
          </tr>
        </table></td>
      <td valign="top" class="thinborderLEFTRIGHT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="54%" height="18" class="thinborderNONE">&nbsp;TOTAL DEDUCTIONS </td>
            <td width="46%" class="thinborderNONE"><div align="right"><strong><strong><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"0")%></strong>&nbsp;&nbsp;</strong></div></td>
          </tr>
        </table></td>
    </tr>
    <tr>
      <td height="19" valign="top" class="thinborderBOTTOMLEFTRIGHT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td width="54%" height="18"><font size="1">&nbsp;NET PAY  </font></td>
          <td width="46%"><div align="right"><strong><font size="1"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dConverted-dTotalDeduction,true),"0")%></strong>&nbsp;&nbsp;</font></strong></div></td>
        </tr>
      </table></td>
    </tr>
  </table>
	<input type="hidden" name="conversion_index" value="<%=WI.fillTextValue("conversion_index")%>">
  <input type="hidden" name="sal_period_index" value="<%=WI.fillTextValue("sal_period_index")%>">
  <input type="hidden" name="bank_account" value="<%=WI.fillTextValue("bank_account")%>">
  <input type="hidden" name="total_amount" value="<%=WI.fillTextValue("total_amount")%>">
  <input type="hidden" name="finalize" value="<%=WI.fillTextValue("finalize")%>">  
</form>

<script src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//get this from common.js
<%if(WI.fillTextValue("skip_print").length() == 0){%>
	this.autoPrint();
	window.setInterval("javascript:window.close();",0);
	this.closeWnd = 1;
<%}%>
//or use this so that the window will not close
//window.setInterval("javascript:window.print();",0);
</script>

</body>
</html>
<%
dbOP.cleanUP();
%>