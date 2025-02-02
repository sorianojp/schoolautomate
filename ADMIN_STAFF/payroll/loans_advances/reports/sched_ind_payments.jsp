<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan" %>
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
<title>Schedule of individual Payments</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SaveClicked(){	
	document.form_.saved.value = "1";
	document.form_.proceed.value = "1";
	this.SubmitOnce("form_");
}

function ReloadPage(){	
	document.form_.proceed.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function focusID() {
	document.form_.emp_id.focus();
}

function UpdateToBlank(strTextName){
	if(eval('document.form_.'+strTextName+'.value') == 0){		
		eval('document.form_.'+strTextName+'.value= ""');
	}	
}
function CheckTerm(){
	var vGrade = "";
	eval("vGrade = document.form_.terms.value");
	if (eval(vGrade) > 5){
		alert ("Term should only be from 1 to 5");
		eval("document.form_.terms.value = 5 ");		
		return;
	}
}

-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./sched_ind_payments_print.jsp" />
<% return;}
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT"),"0"));
		}
		
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
			if(iAccessLevel == 0) {
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
			}
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-RETIREMENT-ENCODE_LOADNS-Create Loans","sched_ind_payments.jsp");
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
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	Vector vRetResult = null;
	Vector vSchedule = null;
	Vector vPersonalDetails = null;
		String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";	
	
	if(strSchCode.startsWith("AUF"))
		strTemp = "PS Bank Loans";
	else
		strTemp = "PERAA Loans";
	
	String[] astrLoanType = {"Regular Retirement Fund","Emergency", "Internal Loan","SSS Loans","Pag-ibig Loans", strTemp, "GSIS Loans" };

	String[] astrYear= {"","1st","2nd","3rd","4th","5th"};
	String strLoanCodeIndex = null;
	String strReadOnly = null;
	String strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
	int iTerm = 0;
	int iYear = 0;
	int iMonth = 0;
	int iLoanDtl = 14;
	int iTermUnit = 0;
	double dTotalPay = 0d;
	double dPrincipal = 0d;
	double dInterest = 0d;
	if (WI.fillTextValue("proceed").length() > 0) {
		
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");		
		if (vPersonalDetails == null || vPersonalDetails.size()==0){
			strErrMsg = authentication.getErrMsg();
			vPersonalDetails = null;
		}
		
		vRetResult = PRRetLoan.getLoanPaySchedule(dbOP,request);
		if(vRetResult == null)
			strErrMsg = PRRetLoan.getErrMsg();		
		else{
			iTerm = Integer.parseInt((String)vRetResult.elementAt(2));
			iMonth = Integer.parseInt((String)vRetResult.elementAt(15));
			iYear = Integer.parseInt((String)vRetResult.elementAt(14));
			iTermUnit = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(16),"0"));
			vSchedule = (Vector)vRetResult.elementAt(17);
		}
	}
	
	if(WI.fillTextValue("saved").length() > 0){
		if(!PRRetLoan.SavePaySchedule(dbOP,request)){
			strErrMsg = "Error in Saving";
		}else{
			strErrMsg = "Saving successful";
		}
	}
    if(WI.fillTextValue("viewOnly").length() == 0){
		strLoanCodeIndex = "";
		strReadOnly = "";
    }else{
		strLoanCodeIndex = " and code_index = " + WI.fillTextValue("code_index");		
		strReadOnly = "readonly";
    }
		
%>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<form name="form_" method="post" action="./sched_ind_payments.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: SCHEDULE OF INDIVIDUAL PAYMENTS PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></font></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="16%" height="27">Employee ID :</td>
      <td width="15%"><font size="1"><strong> 
        <input name="emp_id" class="textbox"onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="12" maxlength="12" <%=strReadOnly%>>
        </strong></font></td>
      <td width="66%" height="27" colspan="3"> <font size="1"> 
        <%if(WI.fillTextValue("viewOnly").length() == 0){%>
					<a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a>	
        <a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a> 
        <!--(NOTE : If this page is called from encode loans data page, no need for 
        encoding of loan code)-->
        <%}%>
        </font></td>
    </tr>
    <tr> 
      <td height="10" colspan="6"><hr size="1"></td>
    </tr>
  </table>  
  <% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){ %>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Employee Name</td>
      <td width="76%" height="27"><strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Employee ID</td>
      <td height="27"><strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="21%" height="27"> <%if(bolIsSchool){%>
        College 
        <%}else{%>
        Division 
        <%}%>
        /Office</td>
      <%
		strTemp = (String)vPersonalDetails.elementAt(13);
		if (strTemp == null){
			strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
		}else{
			strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
		}
		%>
      <td height="27"><strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Position</td>
      <td height="27"><strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="28">Status</td>
      <td height="28"><strong><%=(String)vPersonalDetails.elementAt(16)%> </strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">Loan Code</td>
      <%
	  	strTemp = WI.fillTextValue("code_index");
	  %>	  
      <td height="27"><font size="1"><strong>
	  	<%if(!WI.fillTextValue("viewOnly").equals("1")){%>
        <select name="code_index" onChange="ReloadPage();">
          <%=dbOP.loadCombo("retirement_loan.code_index","loan_code", " from ret_loan_code " +
		  					" join retirement_loan on (ret_loan_code.code_index = retirement_loan.code_index)" +
							" where retirement_loan.is_valid = 1 and retirement_loan.is_finished = 0 " +
							" and user_index = " + strEmpIndex,  strTemp,false)%> 
        </select>
		<%}else{%>
		<input type="hidden" name="code_index" value="<%=WI.fillTextValue("code_index")%>">
		<%}%>
        </strong></font></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%}%>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="21%" height="27">Loan Type</td>
      <td width="26%" height="27"><strong><%=astrLoanType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(4),"0"))]%></strong></td>
      <td height="27">Loan Bank </td>
      <td height="27"><strong><%=WI.getStrValue((String)vRetResult.elementAt(0),"")%></strong></td>
    </tr>
    <tr> 
      <td height="19" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Amount Loaned</td>
      <td height="27"><strong><%=WI.getStrValue((String)vRetResult.elementAt(1),"")%></strong></td>
      <td width="20%" height="27">Interest Rate (%) </td>
      <td width="30%" height="27"><strong><%=WI.getStrValue((String)vRetResult.elementAt(10),"")%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Terms</td>
      <td height="27"><strong><%=WI.getStrValue((String)vRetResult.elementAt(2),"")%></strong></td>
      <td height="27">Release Date</td>
      <td height="27"><strong><%=WI.getStrValue((String)vRetResult.elementAt(3),"")%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF"> 
      <td height="25" colspan="6" align="center" class="BorderAll"><strong>:: 
          SCHEDULE OF SALARY DEDUCTIONS FOR LOAN PAYMENTS ::</strong></td>
    </tr>
    <tr> 
      <td width="14%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">PAYROLL 
      PERIOD</font></strong></td>
      <td width="17%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL 
      PAYMENT</font></strong></td>
      <td height="25" colspan="2" align="center" class="BorderBottomLeft"><strong><font size="1">PAYMENT 
      ON PRINCIPAL</font></strong></td>
      <td width="24%" align="center" class="BorderBottomLeft"><strong><font size="1">PAYMENT 
      ON INTEREST</font></strong></td>
      <td width="23%" align="center" class="BorderBottomLeftRight"><strong><font size="1">PRINCIPAL 
      BALANCE</font></strong></td>
    </tr>
    <% int j = 0;
	   int iCount = 1;
		 int i = 0;
		 if (iTermUnit == 0) {
        i = iTerm/12; // get number of years
        if(iTerm % 12 > 0){
          i++;
        }
				iTerm = i;				
      }
	for(i = 1; i <= iTerm ; i++){%>
    <tr> 
      <td height="25" colspan="3">Year <%=i%>, <%=(iYear+i-1)%> - <%=(iYear+i)%>&nbsp;&nbsp;&nbsp;</td>
      <td width="13%">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="6"><hr size="1"></td>
    </tr>
    <%if(vSchedule != null && vSchedule.size() > 0){
	    for(;j < vSchedule.size();j+=9,iCount++){			
		if (iCount > 24){
			iCount = 1;
			break;
		}
//		  if(!((String)vSchedule.elementAt(j+1)).equals(Integer.toString(iYear+i-1)) 
// 		      && ((String)vSchedule.elementAt(j+7)).equals(Integer.toString(iMonth + i-1)))
//		  	break;
	%>
    <tr> 
      <td height="18"><%=(String)vSchedule.elementAt(j)%> <%=(String)vSchedule.elementAt(j+1)%>, <%=(String)vSchedule.elementAt(j+2)%></td>
      <%
	  	strTemp = (String)vSchedule.elementAt(j+3);
 		dTotalPay += Double.parseDouble(strTemp);
	  %>
	  <td height="18" align="right"><%=(String)vSchedule.elementAt(j+3)%></td>
      <%
	  	strTemp = (String)vSchedule.elementAt(j+4);
 		dPrincipal += Double.parseDouble(strTemp);
	  %>	  
      <td height="18" colspan="2" align="right"><%=(String)vSchedule.elementAt(j+4)%></td>
      <%
	  	strTemp = (String)vSchedule.elementAt(j+5);
 		dInterest += Double.parseDouble(strTemp);
	  %>
      <td align="right"><%=(String)vSchedule.elementAt(j+5)%></td>  
      <td align="right"><%=(String)vSchedule.elementAt(j+6)%></td>
    </tr>
    <%}
	}%>
    <tr> 
      <td height="19" colspan="6"><hr size="1"></td>
    </tr>
    <%}%>
    <tr> 
      <td>TOTAL :</td>	  
      <td height="24" align="right"><%=CommonUtil.formatFloat(dTotalPay,true)%></td>
      <td height="24" colspan="2" align="right"><%=CommonUtil.formatFloat(dPrincipal,true)%></td>
      <td align="right"><%=CommonUtil.formatFloat(dInterest,true)%></td>
      <td align="right">&nbsp;</td>
    </tr>
    <!--
	<tr> 
      <td height="25" colspan="6"><div align="center"><font size="1"><a href='javascript:SaveClicked();'><img src="../../../../images/save.gif" border="0" name="hide_save"></a>click 
          to save entries</font></div></td>
    </tr>
	-->
    <tr> 
      <td height="25"  colspan="6"><div align="center"><font size="1"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0" ></a> 
          click to print</font></div></td>
    </tr>    
  </table>
  <%} // end if vRetResult != null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="loan_type" value="<%=WI.fillTextValue("loan_type")%>">
  <input type="hidden" name="viewOnly" value="<%=WI.fillTextValue("viewOnly")%>">
  <input type="hidden" name="saved">	
  <input type="hidden" name="print_page">
  <input type="hidden" name="proceed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>