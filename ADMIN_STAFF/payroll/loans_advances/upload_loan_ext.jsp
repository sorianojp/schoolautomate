<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan,payroll.PRMiscDeduction" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.

	ReadPropertyFile readPropFile = new ReadPropertyFile();
	boolean bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Existing Loans</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!-- 
function ReloadPage(){
	this.SubmitOnce("form_");
}

function uploadLoan(){
	document.form_.upload_loan.value = "1";
	this.SubmitOnce("form_");
}

function ClearFields(){
	document.form_.terms.value = "";
	document.form_.loan_amount.value = "";
	document.form_.release_date.value = "";
	document.form_.start_date.value = "";
} 
 
function UpdateToBlank(strTextName){
	if(eval('document.form_.'+strTextName+'.value') == 0){
		eval('document.form_.'+strTextName+'.value= ""');
	}
} 

function CancelRecord(){
	location = "./upload_loan_ext.jsp?";
} 
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
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
								"Admin/staff-Payroll-LOANS-Reports-Upload Existing Loans","upload_loan_ext.jsp");
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
	Vector vRetResult = null;
	Vector vLoanInfo = null;
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	String strLoanType = WI.getStrValue(WI.fillTextValue("loan_type"), "2");
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";	

	if(strSchCode.startsWith("AUF"))
		strTemp = "PS Bank Loans";
	else
		strTemp = "PERAA Loans";
	
	String[] astrLoanType = {"", "", "Internal Loan","SSS Loans","Pag-ibig Loans", strTemp, "GSIS Loans" };

	String[] astrTermUnit = {"months","years"};
	String[] astrInterestUnit = {"per year","per month"};
	String strMaxtTerm = null;

	if(WI.fillTextValue("upload_loan").length() > 0){
		if(!PRRetLoan.uploadExistingLoansWithExternal(dbOP, request))
			strErrMsg = PRRetLoan.getErrMsg();
		else
			strErrMsg = "Operation Successful";
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./upload_loan_ext.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
      PAYROLL : LOANS : UPLOAD EXISTING LOANS PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;<font size="2" color="#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="15%" height="26">&nbsp;Loan Type</td>
      <td width="35%"><select name="loan_type" onChange="ReloadPage();">
        <%for(int i = 2; i < astrLoanType.length; i++){
					if(i == 5 && !bolIsSchool)
						continue;
						
					if(i == 6 && !bolIsGovernment)
						continue;
					
					if(strLoanType.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=astrLoanType[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrLoanType[i]%></option>
        <%}
				}%>
      </select></td>
      <td width="13%" height="26">&nbsp;</td>
      <td width="33%">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="26">&nbsp;Loan Code</td>
			<%
				strTemp = WI.fillTextValue("code_index");
				vLoanInfo = PRRetLoan.operateOnLoanCode(dbOP,request,5, WI.getStrValue(strTemp,"0"));
			%>			
      <td height="26" colspan="3"><font size="1"><strong>
        <select name="code_index" onChange="ReloadPage();">
          <option value="">Select Loan</option>
          <%=dbOP.loadCombo("code_index","loan_name, loan_code",
		                    " from ret_loan_code where is_valid = 1 and loan_type = " + strLoanType + 
												" order by loan_code", strTemp ,false)%>
        </select>
      </strong></font></td>
    </tr>
		<%if(strLoanType.equals("2")){%>
    <tr>
      <td>&nbsp;</td>
      <%
	  	if(vLoanInfo != null && vLoanInfo.size() > 0){
				strTemp = (String)vLoanInfo.elementAt(12) + " " + astrTermUnit[Integer.parseInt((String)vLoanInfo.elementAt(13))];
				strMaxtTerm = (String)vLoanInfo.elementAt(12);
			}else{
				strTemp = "";
				strMaxtTerm = "0";
			}
 	  %>
	  <input type="hidden" name="max_term" value="<%=strMaxtTerm%>">
      <td height="26">&nbsp;Max. Term</td>
      <td><strong><%=WI.getStrValue(strTemp,"")%></strong></td>
      <td height="26">&nbsp;Interest</td>
      <%
	  	if(vLoanInfo != null && vLoanInfo.size() > 0){
				strTemp = (String)vLoanInfo.elementAt(6);
			strTemp = CommonUtil.formatFloat(strTemp, false);
			strTemp = ConversionTable.replaceString(strTemp,",","");
						
			if(Double.parseDouble(strTemp) == 0)
					strTemp = "";
					
			strTemp = WI.getStrValue(strTemp,"","% " +astrInterestUnit[Integer.parseInt((String)vLoanInfo.elementAt(7))],"");			
			}else
				strTemp = "";
	  %>
      <td><strong><%=strTemp%></strong></td>
    </tr>
		<%}%>
    <tr>
      <td height="17" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <%
	vLoanInfo = PRRetLoan.operateOnLoanCode(dbOP,request,5,WI.getStrValue(strTemp,"0"));
	%>
    
    <tr>
      <td height="27">&nbsp;</td>
      <td>Format</td>
      <td><p>1. Emp ID - Employee ID <br>
        2. loaned amount - original amount loaned (no comma)<br>
        3. payable amount - payable balance (no comma)<br>
      4. monthly amount - monthly amortization (no comma)<br>
      5. release date - date when loan was released (mm/dd/yyyy format)<br>
      6. start date - date to start the loan schedule in the system (mm/dd/yyyy format)<br>
      7. frequency of deduction - (0 - every salary period, 1 - first salary period, 2 - second salary period)<br>
      8. Collection Period - only for external loans. Put null or an empty space for internal loans.</p>      </td>
    </tr>
    <tr>
      <td width="3%" height="27">&nbsp;</td>			 
      <td width="12%">Loan CSV </td>
      <td width="85%"><font size="1">
        <textarea name="loan_csv" cols="40" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("loan_csv")%></textarea>
      </font></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td colspan="2"><strong>Note: </strong> Loans for employees with weekly salary schedule is not supported in this page</td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="30" align="center">
        <input type="button" name="save" value="UPLOAD" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:uploadLoan();">
        <font size="1"> click to upload entries</font>
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">        <font size="1">click to cancel/clear entries </font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="upload_loan">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>