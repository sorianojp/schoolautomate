<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, 
																payroll.PReDTRME, payroll.PRTransmittal" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Bonus ATM Transmittal</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
  	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }
    TD.thinborderBOLDBOTTOM {
    border-bottom: solid 2px #000000;
  	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }		
    TD.thinborderBOTTOMTOP {
    border-bottom: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }		
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function Generate()
{
	document.form_.generate.value = "1";
	this.SubmitOnce('form_');
}
function goBack(){
	document.form_.goback.value="1";
	this.SubmitOnce("form_");
}
function getFile(strFilename){
	location = strFilename;
}

function ReloadPage(){
	document.form_.generate.value = "";
	this.SubmitOnce('form_');
}

function updateAccounts(){
	var pgLoc = "../reports/transmittal/bank_info.jsp?opner_form_name=form_";
	var win=window.open(pgLoc,"updateAccounts",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
</script>
<body>
<form name="form_" 	method="post" action="./bonus_atm_transmittal.jsp">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	int i = 0;	
	
//add security here.
if (WI.fillTextValue("goback").length() > 0){ %>
	<jsp:forward page="./manual_bonus_encoding.jsp"/>
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","bonus_atm_transmittal.jsp");
								
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
														"PAYROLL","DTR",request.getRemoteAddr(),
														"bonus_atm_transmittal.jsp");
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
	Vector vAccountInfo = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PRTransmittal transmit = new PRTransmittal(request);
	String strPayrollPeriod  = null;	
	String strTemp2 = null;
	double dSalary = 0d;	 
	String strPayEnd = null;
	String strFilename = null;
	String strBank = "";
	
	if(WI.fillTextValue("bank_info_index").length() > 0){
		vAccountInfo = transmit.operateOnBankAccounts(dbOP,request, 3, WI.fillTextValue("bank_info_index"));
		if(vAccountInfo != null && vAccountInfo.size() > 0)
			strBank = (String)vAccountInfo.elementAt(4);
 		if(strBank != null && WI.fillTextValue("generate").length() > 0){
			strFilename = transmit.operateOnAddlPayEmpList(dbOP, request, strBank);
 			if(strFilename == null)
				strErrMsg = transmit.getErrMsg();
			else
				strErrMsg = "File Creation successful<br>" + WI.getStrValue(transmit.getErrMsg(),"");
  		}	
	}
	
	if(WI.fillTextValue("generate").length() > 0){
		
		if(strFilename == null)
			strErrMsg = transmit.getErrMsg();
		else
			strErrMsg = "File Creation successful<br>" + WI.getStrValue(transmit.getErrMsg(),"");
	}
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr > 
			<td height="25" colspan="5" align="center"><strong>::: BANK TRANSMITTAL FILE CREATION ::: </strong></td>
		</tr>
	</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="2" bgcolor="#FFFFFF"><font size="1"><a href="javascript:goBack();"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></font>&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr>
      <td width="20%" height="25" align="right" bgcolor="#FFFFFF"> &nbsp;Bank Format : </td>
      <td width="80%" height="25" bgcolor="#FFFFFF">
			<select name="bank_info_index" onChange="ReloadPage();">
        <%strTemp= WI.fillTextValue("bank_info_index");%>
        <option value="">Select Account</option>
        <%=dbOP.loadCombo("bank_info_index","bank_name, branch_code", " from pr_comp_banks " +
				" join pr_supported_bank on (pr_comp_banks.bank_main_index = pr_supported_bank.bank_main_index) " +
				"   where is_valid = 1 order by bank_name", strTemp, false)%>
      </select>
			<a href='javascript:updateAccounts();'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr>
      <td height="25" align="right" bgcolor="#FFFFFF">&nbsp;Bank Name : </td>
			<%
				if(vAccountInfo != null && vAccountInfo.size()  > 0)
					strTemp = (String)vAccountInfo.elementAt(1);
				else
					strTemp = "";
			%>			
      <td height="25" bgcolor="#FFFFFF">&nbsp;<%=strTemp%></td>
    </tr>
    <tr>
			<%
				if(vAccountInfo != null && vAccountInfo.size()  > 0)
					strTemp = (String)vAccountInfo.elementAt(2);
				else
					strTemp = "";
			%>
      <td height="25" align="right" bgcolor="#FFFFFF">&nbsp;Branch Code : </td>
			
      <td height="25" bgcolor="#FFFFFF">
			<input type="text" class="textbox_noborder" name="branch_code" value="<%=WI.getStrValue(strTemp)%>" size="16" maxlength="16" readonly></td>
    </tr>
    <tr>
      <td height="25" align="right" bgcolor="#FFFFFF">&nbsp;Account No : </td>
			<%
				if(vAccountInfo != null && vAccountInfo.size()  > 0)
					strTemp = (String)vAccountInfo.elementAt(3);
				else
					strTemp = "";
				strTemp = WI.getStrValue(strTemp);
			%>
			<input type="hidden" name="comp_account" value="<%=strTemp%>">
      <td height="25" bgcolor="#FFFFFF">&nbsp;<%=strTemp%></td>
    </tr>
		<%if(strBank.equals("2")){// UCPB%>
    <tr>
      <td height="25" align="right" bgcolor="#FFFFFF">Date to be credited : </td>
			<%
				strTemp = WI.fillTextValue("credit_date");
			%>
      <td height="25" bgcolor="#FFFFFF">
			<input name="credit_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.credit_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
		<%}%>
		<%if(strBank.equals("3") || strBank.equals("7") ){// RCBC || BDO %>
    <tr>
      <td height="25" align="right" bgcolor="#FFFFFF">Transaction Date  : </td>
			<%
				strTemp = WI.fillTextValue("transaction_date");
			%>
      <td height="25" bgcolor="#FFFFFF">
			<input name="transaction_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.transaction_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
	<%}%>
	<%if(strBank.equals("3") ){// RCBC  %>
    <tr>
      <td height="25" align="right" bgcolor="#FFFFFF">Account Type : </td>
			<%
				strTemp = WI.fillTextValue("account_type");
				if(strTemp.equals("S"))
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td height="25" bgcolor="#FFFFFF"><input type="radio" name="account_type" value="S" <%=strTemp%>>
        Savings account
			<%
 				if(strTemp.length() == 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>				
          <input type="radio" name="account_type" value="C" <%=strTemp%>>
          Current Account </td>
    </tr>
    <tr>
      <td height="25" align="right" bgcolor="#FFFFFF">Company Code : </td>
			<%
				strTemp = WI.fillTextValue("comp_code");
			%>
      <td height="25" bgcolor="#FFFFFF"><input type="text" class="textbox" name="comp_code" value="<%=WI.getStrValue(strTemp)%>" size="3" maxlength="2"></td>
    </tr>
		<%}%>
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("all_employers");
				if(strTemp.equals("1"))
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td height="25" bgcolor="#FFFFFF"><input type="checkbox" name="all_employers" value="1" <%=strTemp%>>
      Generate for all employers</td>
    </tr>
    <tr>
      <td height="25"  colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="2" bgcolor="#FFFFFF"><input type="button" name="proceed_btn" value=" GENERATE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:Generate();"></td>
    </tr>
		<tr>
		  <td height="25"  colspan="2" bgcolor="#FFFFFF">&nbsp;Notes:<br>
			&nbsp;&nbsp;&nbsp;1. Only generate transmittal file for banks using their corresponding format. (ex. Use Landbank format only for employees with Landbank accounts).<br>
			&nbsp;&nbsp;&nbsp;2. Employees having problem with the account number and/or account name will not be included in the bank transmittal. The system will only check for the specific length of the account numbers and will not check whether the account is valid or not.<br>
			&nbsp;&nbsp;&nbsp;3. Banks supported  : Landbank, UCPB, RCBC and Chinabank only.(Depending on which banks are enabled)<br> 
			&nbsp;&nbsp;&nbsp;4. There is a need to update the filename and/or extension for RCBC and Chinabank.</td>
	  </tr>
		<%if(strFilename != null && strFilename.length() > 0){%>		
		<tr>
      <!--<td height="25"  colspan="3" bgcolor="#FFFFFF"><font size="1"><a href="javascript:getFile('<%=strFilename%>')"><img src="../../../images/download.gif" width="72" height="27" border="0"></a></font></td>-->
			<%
				if(strBank.equals("1"))
					strTemp = "../../../download/"+strFilename;
				else if(strBank.equals("2"))
					strTemp = "../../../download/CM_bonus.txt";
				else if(strBank.equals("3"))
					strTemp = "../../../download/"+strFilename;
				else
					strTemp = "../../../download/"+strFilename;
			%>
			<td height="25"  colspan="2" bgcolor="#FFFFFF"><font size="1">
			<a href="<%=strTemp%>" target="_blank">
			<img src="../../../images/download.gif" width="72" height="27" border="0"></a></font>			</td>
    </tr>
		<%}%>
  </table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="generate" value="">  
  <input type="hidden" name="sort_by1" value="<%=WI.fillTextValue("sort_by1")%>">
  <input type="hidden" name="sort_by1_con" value="<%=WI.fillTextValue("sort_by1_con")%>">	
  <input type="hidden" name="sort_by2" value="<%=WI.fillTextValue("sort_by2")%>">
  <input type="hidden" name="sort_by2_con" value="<%=WI.fillTextValue("sort_by2_con")%>">	
  <input type="hidden" name="sort_by3" value="<%=WI.fillTextValue("sort_by3")%>">
  <input type="hidden" name="sort_by3_con" value="<%=WI.fillTextValue("sort_by3_con")%>">		
	<input type="hidden" name="bank_index" value="<%=WI.fillTextValue("bank_index")%>">		
	<input type="hidden" name="pay_index" value="<%=WI.fillTextValue("pay_index")%>">
	<input type="hidden" name="atm_account" value="<%=WI.fillTextValue("atm_account")%>">
	<input type="hidden" name="pt_ft" value="<%=WI.fillTextValue("pt_ft")%>">				
	<input type="hidden" name="employee_category" value="<%=WI.fillTextValue("employee_category")%>">				
	<input type="hidden" name="c_index" value="<%=WI.fillTextValue("c_index")%>">				
	<input type="hidden" name="d_index" value="<%=WI.fillTextValue("d_index")%>">					
  <input type="hidden" name="month_of" value="<%=WI.fillTextValue("month_of")%>">
  <input type="hidden" name="year_of" value="<%=WI.fillTextValue("year_of")%>">
	<input type="hidden" name="end_date" value="<%=WI.fillTextValue("end_date")%>">
	<input type="hidden" name="group_index" value="<%=WI.fillTextValue("group_index")%>">	
	<input type="hidden" name="employer_index" value="<%=WI.fillTextValue("employer_index")%>">			
	<input type="hidden" name="goback" value=""> 	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>