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
<title>Payroll Summary For Bank</title>
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
	<jsp:forward page="./generate_bonus_emplist.jsp"/>
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PRTransmittal transmit = new PRTransmittal(request);
	String strPayrollPeriod  = null;	
	String strTemp2 = null;
	double dSalary = 0d;	 
	String strPayEnd = null;
	String strFilename = null;
	
	if(WI.fillTextValue("generate").length() > 0){
		strFilename = transmit.operateOnAddlPayEmpList(dbOP,request);
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
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><font size="1"><a href="javascript:goBack();"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></font>&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr>
			<%
				strTemp = WI.fillTextValue("branch_code");
			%>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;Branch Code : <input type="text" class="textbox_noborder" name="branch_code" value="<%=WI.getStrValue(strTemp,"134")%>" readonly size="10"> </td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><input type="button" name="proceed_btn" value=" GENERATE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:Generate();"></td>
    </tr>
		<tr>
		  <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;Notes: <br>
			&nbsp;&nbsp;&nbsp;1. Employees having problem with the account number and account name will not be included in the bank transmittal.<br>
			&nbsp;&nbsp;&nbsp;2. This bank transmittal file creation will only work for Landbank branches. </td>
	  </tr>
		<%if(strFilename != null && strFilename.length() > 0){%>		
		<tr>
      <!--<td height="25"  colspan="3" bgcolor="#FFFFFF"><font size="1"><a href="javascript:getFile('<%=strFilename%>')"><img src="../../../images/download.gif" width="72" height="27" border="0"></a></font></td>-->
			<td height="25"  colspan="3" bgcolor="#FFFFFF"><font size="1"><a href="../../../download/bonus_transmittal.txt" target="_blank"><img src="../../../images/download.gif" width="72" height="27" border="0"></a></font></td>
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
	<input type="hidden" name="pay_index" value="<%=WI.fillTextValue("pay_index")%>">			
	<input type="hidden" name="atm_account" value="<%=WI.fillTextValue("atm_account")%>">
	<input type="hidden" name="pt_ft" value="<%=WI.fillTextValue("pt_ft")%>">				
	<input type="hidden" name="employee_category" value="<%=WI.fillTextValue("employee_category")%>">				
	<input type="hidden" name="c_index" value="<%=WI.fillTextValue("c_index")%>">				
	<input type="hidden" name="d_index" value="<%=WI.fillTextValue("d_index")%>">					
  <input type="hidden" name="month_of" value="<%=WI.fillTextValue("month_of")%>">
  <input type="hidden" name="year_of" value="<%=WI.fillTextValue("year_of")%>">
	<input type="hidden" name="end_date" value="<%=WI.fillTextValue("end_date")%>">
	<input type="hidden" name="goback" value=""> 	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>