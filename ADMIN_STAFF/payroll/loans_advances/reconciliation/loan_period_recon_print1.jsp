<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Payslip</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
	
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	document.form_.print_all.value ="";	
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	document.form_.print_all.value ="";	
	this.SubmitOnce('form_');
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2  = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	String strPayrollPeriod  = null;
	
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","loan_payments_recon.jsp");

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
														"loan_payments_recon.jsp");
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
Vector vRetResult = null;
PRRetirementLoan RptPay = new PRRetirementLoan(request);
boolean bolNextEmployee = false;
boolean bolLooped = false;
boolean bolPageBreak = false;
double dTemp = 0d;
double dScheduled = 0d;
double dDiscrepancy = 0d;
double dDiscrepancyTotal = 0d;
double dScheduledTotal = 0d;
double dActualTotal = 0d;
double dOverpayment = 0d;
double dUnderpayment = 0d;




vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);

if(vSalaryPeriod != null && vSalaryPeriod.size() > 0){
  vRetResult = RptPay.generateReconciliation(dbOP);
	if(vRetResult == null){
		strErrMsg = RptPay.getErrMsg();
	}else{	
		iSearchResult = RptPay.getSearchCount();
	}
}
if (vRetResult != null) {

	int i = 0; int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size()-1)/(9*iMaxRecPerPage);	
	if(vRetResult.size() % iMaxRecPerPage > 0) ++iTotalPages;
 for (;iNumRec < vRetResult.size();iPage++){
%>

<body onLoad="window.print();">
<form name="form_" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font color="#000000"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%></strong></font><br>
      </div></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
	<tr class="thinborder"> 
      <td height="23" colspan="6" align="center" class="thinborder"><b>LIST OF EMPLOYEES FOR PRINTING.</b></td>
    </tr>
    <tr class="thinborder"> 
      <td class="thinborder" height="25" align="center">&nbsp;</td>
      <td class="thinborder" align="center"><strong>EMPLOYEE NAME</strong></td>
      <td class="thinborder" align="center"><strong>LOAN CODE </strong></td>
      <td class="thinborder" align="center"><strong>SCHEDULE PAY</strong></td>
      <td class="thinborder" align="center"><strong>ACTUAL PAID</strong></td>
      <td align="center" class="thinborder"><strong>DISCREPANCY</strong></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=9,++iIncr, ++iCount){
		bolLooped = false;
		bolNextEmployee = false;
		dScheduledTotal = 0d;
		dActualTotal = 0d;
		dDiscrepancyTotal = 0d;		
		
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
		
	  <% 	//System.out.println("size " +vRetResult.size());	
		for(; iNumRec < vRetResult.size();iNumRec += 9, ++iCount){
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
			bolPageBreak = false;		
			i = iNumRec;
			strTemp = (String)vRetResult.elementAt(i+6);
			strTemp = WI.getStrValue(strTemp, "0");
			strTemp = ConversionTable.replaceString(strTemp,",","");
			
			strTemp2 = (String)vRetResult.elementAt(i+8);
			strTemp2 = WI.getStrValue(strTemp2, "0");
			strTemp2 = ConversionTable.replaceString(strTemp2,",","");
			
			if(Double.parseDouble(strTemp) == 0d && Double.parseDouble(strTemp2) == 0d){
				continue;
			}		
	  %>	
		<tr bgcolor="#FFFFFF" class="thinborder">   
		  <% 
		  	if(bolLooped && ((String)vRetResult.elementAt(i+1)).equals((String)vRetResult.elementAt(i-8))){
				strTemp = "";	
				strTemp2 = "";							
			}else{
				strTemp = WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
								(String)vRetResult.elementAt(i+4), 4).toUpperCase();
				strTemp2 = iIncr + ".";											
			}			 	
		  %>		
		  <td height="21" class="thinborder">&nbsp;<%=strTemp2%></td>
		  <td class="thinborder" >&nbsp;<font size="1"><strong>&nbsp;<%=strTemp%></strong></font></td>
		  <%
		  	strTemp = (String)vRetResult.elementAt(i+5);
			if(((String)vRetResult.elementAt(i+7)).equals("1"))
				strTemp2 = "int";
			else
				strTemp2 = "";
		  %>		  
		  <td class="thinborder" ><font size="1">&nbsp;<%=strTemp%> <%=WI.getStrValue(strTemp2,"(",")","")%></font></td>
		  <%
		  	strTemp = (String)vRetResult.elementAt(i+8);			
			strTemp = CommonUtil.formatFloat(strTemp,true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			dScheduled = dTemp;
			dScheduledTotal += dTemp;
			
		  %>
		  <td class="thinborder"><div align="right"><font size="1"><%=strTemp%></font>&nbsp;</div></td>
		  <%
		  	strTemp = (String)vRetResult.elementAt(i+6);
			strTemp = CommonUtil.formatFloat(strTemp,true);
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			dDiscrepancy =  dScheduled - dTemp;
			dDiscrepancyTotal += dDiscrepancy;
			dActualTotal += dTemp;
		  %>
		  <td class="thinborder" ><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
		  <%
		  	if(dDiscrepancy == 0d){
				strTemp = "";
			}else{
				strTemp = CommonUtil.formatFloat(dDiscrepancy,true);
			}
		  %>
	      <td class="thinborder" ><div align="right"><%=strTemp%>&nbsp;</div></td>
		</tr>
  	  <%if(i+10 <= vRetResult.size() && !((String)vRetResult.elementAt(i+1)).equals((String)vRetResult.elementAt(i+10))){
	  		break;
	  	}
	  bolLooped= true;	
	  } // end for loop%>
		<tr bgcolor="#FFFFFF" class="thinborder">
		  <td height="25" class="thinborder">&nbsp;</td>
		  <td class="thinborder" >&nbsp;</td>
		  <td class="thinborder" ><div align="right"><strong>TOTAL :&nbsp; </strong></div></td>
		  <td class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dScheduledTotal,true)%></strong>&nbsp;</div></td>
		  <td class="thinborder" ><div align="right"><strong><%=CommonUtil.formatFloat(dActualTotal,true)%></strong>&nbsp;</div></td>
		  <%
		  	if(dDiscrepancyTotal > 0d)
				dOverpayment += dDiscrepancyTotal;
			else
				dUnderpayment += dDiscrepancyTotal;
			
		  %>
		  <td class="thinborder" ><div align="right"><strong><%=CommonUtil.formatFloat(dDiscrepancyTotal,true)%></strong>&nbsp;</div></td>
	    </tr>		  
    <%} // end for loop	%>
    <tr bgcolor="#FFFFFF" class="thinborder">
      <td height="14" width="4%">&nbsp;</td>
      <td width="36%">&nbsp;</td>
      <td width="18%">&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="14%">&nbsp;</td>
    </tr>	
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="22">&nbsp;</td>
      <td width="46%">Total loan overpayments for this period </td>	  
      <td width="16%"><div align="right"><strong><%=CommonUtil.formatFloat(dOverpayment,true)%>&nbsp;</strong></div></td>
      <td width="36%">&nbsp;</td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td>Total loan underpayments for this period </td>
	  <%
		strTemp = Double.toString(dUnderpayment);
		strTemp = ConversionTable.replaceString(strTemp,"-","");	  	
	  %>
      <td><div align="right"><strong><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</strong></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td>Loan overpayments - underpayments for this period </td>
	  <%
	  	dTemp = dOverpayment + dUnderpayment;
		strTemp = Double.toString(dTemp);
		strTemp = ConversionTable.replaceString(strTemp,"-","");
		
	  %>
      <td><div align="right"><strong><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</strong></div></td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>