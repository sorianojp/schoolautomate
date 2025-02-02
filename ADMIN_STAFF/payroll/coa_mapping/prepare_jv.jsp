<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRCOAMapping, payroll.PReDTRME" %>
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
<title>Employee Mapping</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function CreateJV (){
	document.form_.create_jv.value = "1";
	this.SubmitOnce('form_');
}

function ReloadPage()
{	
	this.SubmitOnce('form_');
}

function goToMain(){
	location = "./coa_main.jsp";
}

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

function ReloadPage() {	
	this.SubmitOnce('form_');
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strHasWeekly = null;
		
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-COA Config-Prepare JV","prepare_jv.jsp");
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
														"PAYROLL","CONFIGURATION",request.getRemoteAddr(),
														"prepare_jv.jsp");
															
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
	Vector vDebit = null;
	Vector vCredit = null;
	Vector vAccounts = null;
	double dTotal = 0d;
	
	PRCOAMapping prCOA = new PRCOAMapping();
	int iSearchResult = 0;
	int iCount = 0;
	int i = 0;
	int iIndexOf = 0;
	Integer iIndex = null;
	String strPayrollPeriod = null;
	String strDateFrom = null;
	String strDateTo = null;
	String strAcctName = null;
	String strAcctCode = null;
	String strJVNumber = null;
	
	if(WI.fillTextValue("create_jv").length() > 0){
		strJVNumber = prCOA.createPayrollJV(dbOP, request);
		if(strJVNumber == null)
			strErrMsg = prCOA.getErrMsg();
		else
			strErrMsg = "JV created successfully : " + strJVNumber;
	}
	 	
	strErrMsg = WI.getStrValue(strErrMsg);	
 	vRetResult = prCOA.generateJVPreparation(dbOP, request);
	if(vRetResult != null){
		vDebit = (Vector) vRetResult.elementAt(0);
		vCredit = (Vector) vRetResult.elementAt(1);
		vAccounts = (Vector) vRetResult.elementAt(2);
	}else{
		strErrMsg = WI.getStrValue(strErrMsg,"","<br>","")+ prCOA.getErrMsg();
	}
	
 	if(strErrMsg == null) 
		strErrMsg = "";
		
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./prepare_jv.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        PAYROLL : Journal Voucher Preparation::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="27"><strong><a href="javascript:goToMain();">MAIN</a>&nbsp;&nbsp;<%=strErrMsg%></strong></td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;Salary period for Yr</td>
      <td> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;Salary Period</td>
      <td width="77%"><strong>
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
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
				strDateFrom = (String)vSalaryPeriod.elementAt(i + 1);
				strDateTo = (String)vSalaryPeriod.elementAt(i + 2) ;
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
        <%}// check if the company has weekly salary type%></td>
    </tr> 
  </table>  
  <!--
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    		
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_misc");
				if(strTemp.length() > 0)
					strTemp = " checked";
				else
					strTemp = "";
			%>			
      <td height="10" colspan="2"><input type="checkbox" value="1" <%=strTemp%> name="show_misc">
show misc </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_loan");
				if(strTemp.length() > 0)
					strTemp = " checked";
				else
					strTemp = "";
			%>
      <td height="10" colspan="2"><input type="checkbox" value="1" <%=strTemp%> name="show_loan">
      show loan</td>
    </tr>
    
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_earnings");
				if(strTemp.length() > 0)
					strTemp = " checked";
				else
					strTemp = "";
			%>			
      <td height="10" colspan="2"><input type="checkbox" value="1" <%=strTemp%> name="show_earnings">
			show earnings </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_allowance");
				if(strTemp.length() > 0)
					strTemp = " checked";
				else
					strTemp = "";
			%>
      <td height="10" colspan="2"><input type="checkbox" value="1" <%=strTemp%> name="show_allowance">
      show allowances</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td> 
			<%
				strTemp = WI.fillTextValue("show_data");
				if(strTemp.length() > 0)
					strTemp = " checked";
				else
					strTemp = "";
			%>			
      <td height="10" colspan="2"><input type="checkbox" value="1" <%=strTemp%> name="show_data">
show data</td>
    </tr>
  </table>  
	-->
   <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
     <tr> 
      <td height="10">&nbsp;</td> 
			<%
				strTemp = WI.fillTextValue("include_bonus");
				if(strTemp.length() > 0)
					strTemp = " checked";
				else
					strTemp = "";
			%>			
      <td height="10" colspan="2"><input type="checkbox" value="1" <%=strTemp%> name="include_bonus">include bonuses</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td width="97%" height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="10">&nbsp;</td>
      <td height="10" colspan="3"><font size="1">
      <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
click to display  list to print</font></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
  </table>	
  <% //System.out.println("vRetResult " + vRetResult);
  if(vDebit != null && vDebit.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ffff99" class="thinborder">
      <td height="25" colspan="4" align="center" class="thinborder"><strong>DEBIT</strong></td>
    </tr>
    <tr bgcolor="#ffff99" class="thinborder">
      <td class="thinborder" height="25" align="center">&nbsp;</td>
      <td class="thinborder" width="52%" align="center"><strong>ACCOUNT NAME </strong></td>
      <td class="thinborder" width="26%" align="center"><strong>ACCOUNT CODE </strong></td>
      <td class="thinborder" width="17%" align="center"><strong>AMOUNT</strong></td>
    </tr>
    <% 	
		dTotal = 0d;
		//System.out.println("size " +vRetResult.size());
		for(i = 0; i < vDebit.size(); i += 3,++iCount){
				strAcctName = null;	
				strAcctCode = null;				
		
			 iIndex = (Integer)vDebit.elementAt(i);
			 iIndexOf = vAccounts.indexOf(iIndex);
			if(iIndexOf != -1){
				strAcctName = (String)vAccounts.elementAt(iIndexOf+2);
				strAcctCode = (String)vAccounts.elementAt(iIndexOf+1);
			}
		%>
    <tr bgcolor="#FFFFFF" class="thinborder">
      <td width="5%" height="25" class="thinborder">&nbsp;<%=iCount+1%>.</td> 
			<input type="hidden" name="debit_coa_<%=iCount%>" value="<%=iIndex%>">			
			<input type="hidden" name="debit_remark_<%=iCount%>" value="<%=strAcctName%>">			
			<td class="thinborder" >&nbsp;<%=WI.getStrValue(strAcctName)%></td>
			<td class="thinborder" >&nbsp;<%=WI.getStrValue(strAcctCode)%></td>
			<%
				strTemp = (String)vDebit.elementAt(i+1);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				strTemp2 = ConversionTable.replaceString(strTemp, ",","");
				dTotal += Double.parseDouble(strTemp2);
			%>
			<input type="hidden" name="debit_amount_<%=iCount%>" value="<%=strTemp2%>">
      <td align="right" class="thinborder" ><%=strTemp%>&nbsp;</td> 
    </tr>
    <%} // end for loop%>
		<input type="hidden" name="debit_count" value="<%=iCount%>">
    <tr bgcolor="#FFFFFF" class="thinborder">
      <td height="25" colspan="3" align="right" class="thinborder">TOTAL DEBIT : </td>
      <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dTotal, true)%>&nbsp;</td>
    </tr>
  </table>
	<%}%>
	  <% //System.out.println("vRetResult " + vRetResult);
  if(vCredit != null && vCredit.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ffff99" class="thinborder">
      <td height="25" colspan="4" align="center" class="thinborder"><strong>CREDIT</strong></td>
    </tr>
    <tr bgcolor="#ffff99" class="thinborder">
      <td class="thinborder" height="25" align="center">&nbsp;</td>
      <td class="thinborder" width="52%" align="center"><strong>ACCOUNT NAME </strong></td>
      <td class="thinborder" width="26%" align="center"><strong>A<strong>CCOUNT CODE </strong></strong></td>
      <td class="thinborder" width="17%" align="center"><strong>AMOUNT</strong></td>
    </tr>
    <% 	
		iCount = 0;
		dTotal = 0d;
		//System.out.println("size " +vRetResult.size());
		for(i = 0; i < vCredit.size(); i += 3,++iCount){		
				strAcctName = null;	
				strAcctCode = null;				
		
			 iIndex = (Integer)vCredit.elementAt(i);
			 iIndexOf = vAccounts.indexOf(iIndex);
			if(iIndexOf != -1){
				strAcctName = (String)vAccounts.elementAt(iIndexOf+2);
				strAcctCode = (String)vAccounts.elementAt(iIndexOf+1);
			}		
		%>
    <tr bgcolor="#FFFFFF" class="thinborder">
      <td width="5%" height="25" class="thinborder" >&nbsp;<%=iCount+1%>.</td>
			<input type="hidden" name="credit_remark_<%=iCount%>" value="<%=strAcctName%>">
			<input type="hidden" name="credit_coa_<%=iCount%>" value="<%=iIndex%>">	
      <td class="thinborder" >&nbsp;<%=WI.getStrValue(strAcctName)%></td> 
      <td class="thinborder" >&nbsp;<%=WI.getStrValue(strAcctCode)%></td> 
			<%
				strTemp = (String)vCredit.elementAt(i+1);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				strTemp2 = ConversionTable.replaceString(strTemp, ",","");
				dTotal += Double.parseDouble(strTemp2);
			%>			
			<input type="hidden" name="credit_amount_<%=iCount%>" value="<%=strTemp2%>">
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
    </tr>
    <%} // end for loop%>
		<input type="hidden" name="credit_count" value="<%=iCount%>">
    <tr bgcolor="#FFFFFF" class="thinborder">
      <td height="25" colspan="3" align="right" class="thinborder">TOTAL CREDIT : </td>
      <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dTotal, true)%>&nbsp;</td>
    </tr>
  </table>
	<%}%>
	<% //System.out.println("vRetResult " + vRetResult);
  if(vAccounts != null && vAccounts.size() > 0) {%>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    	
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td class="thinborder" height="25" align="center">&nbsp;</td>
      <td class="thinborder" width="52%" align="center"><strong>CHART OF ACCOUNTS</strong></td>
      <td class="thinborder" width="43%" align="center"><strong> Complete Code</strong></td>
    </tr>
    <% 	
		iCount = 0;
		//System.out.println("size " +vRetResult.size());
		for(i = 0; i < vAccounts.size(); i += 5,++iCount){		
		%>
    <tr bgcolor="#FFFFFF" class="thinborder"> 						
       <td width="5%" height="25" class="thinborder">&nbsp;<%=iCount+1%>.</td>
			<%
				strTemp = (String)vAccounts.elementAt(i+1);
				strTemp += "<br>&nbsp;" +(String)vAccounts.elementAt(i+2);
			%>
      <td class="thinborder" >&nbsp;<%=strTemp%></td> 
      <td class="thinborder" >&nbsp;</td>
    </tr>
	<%} // end for loop%>
  </table>
  <%} // end if vRetResult != null && vRetResult.size() %>
	<%if(vDebit != null && vDebit.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td>JV Number </td>
			<%
				strTemp = WI.fillTextValue("jv_number");
			%>
      <td height="25"><input name="jv_number" type="text" size="23" maxlength="24" value="<%=strTemp%>" class="textbox"
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        optional <font size="1">(if blank, JV Number will be generated by the system)</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Date</td>
      <td height="25"><%
strTemp = WI.fillTextValue("jv_date");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="jv_date" type="text" size="10" maxlength="10" value="<%=strTemp%>" class="textbox"
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.jv_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="4%">&nbsp;</td> 
      <td width="18%">&nbsp;</td>
      <td width="78%" height="25"><font size="1">
        <input type="button" name="proceed_btn2" value=" Create " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:CreateJV();">
      </font></td>
    </tr>
  </table>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="create_jv">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>