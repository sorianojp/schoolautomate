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
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SaveClicked(){	
	document.form_.saved.value = "1";
	document.form_.proceed.value = "1";
	this.SubmitOnce("form_");
}

function ReloadPage(){
	document.form_.print_page.value="";
	document.form_.proceed.value = "1";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
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
	<jsp:forward page="./indv_total_loan_bal_print.jsp" />
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
								"Admin/staff-RETIREMENT-ENCODE_LOADNS-Create Loans","indv_total_loan_bal.jsp");
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
	String strLoanType = null;
	String strFSType = WI.fillTextValue("faculty_staff");
	String[] astrLoanType= {"Regular Retirement Loan","Emergency Loan"};
	String[] astrFSType = {"FACULTY","STAFF" };
	int iSearchResult = 0;
	int i = 0;
	int iDefault = 0;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dPayable = 0d;

	if (WI.fillTextValue("proceed").length() > 0) {
		vRetResult = PRRetLoan.getIndLoanBal(dbOP,request);		
		if(vRetResult == null)
			strErrMsg = PRRetLoan.getErrMsg();		
		else{
		iSearchResult = PRRetLoan.getSearchCount();
		}
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./indv_total_loan_bal.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::RETIREMENT 
          - REPORTS - INDIVIDUAL TOTAL LOAN BALANCES PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;<strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
	  <%
	  	strTemp = WI.fillTextValue("end_date");
	  %>
      <td width="29%" height="27">End Date : <strong>
        <input name="end_date" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp,"")%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.end_date');"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </strong></td>
       <%
	  	strLoanType = WI.fillTextValue("loan_type");
	  %>
	  <td width="68%">Loan Type : 
        <select name="loan_type" onChange="ReloadPage();">
          <option value="0">Regular Retirement Loan</option>
          <%if(strLoanType.equals("1")){%>
          <option value="1" selected>Emergency Loan</option>
          <%}else{%>
          <option value="1">Emergency Loan</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">
		  <%
		  strFSType = WI.getStrValue(WI.fillTextValue("faculty_staff"),"0");
		  if(strFSType.compareTo("0") == 0)
			strTemp = " checked";
		  else	
			strTemp = "";
		 %>
		 <input type="radio" name="faculty_staff" value="0"<%=strTemp%> onClick="ReloadPage();">Faculty
		 <%if(strTemp.length() == 0) 
			strTemp = " checked";
		   else
			strTemp = "";
		 %>
		  <input type="radio" name="faculty_staff" value="1"<%=strTemp%> onClick="ReloadPage();">Staff 
		  
	  </td>
      <td height="27"><font size="1"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="97%" height="27">OUTSTANDING <font color="#000000"><%=astrLoanType[Integer.parseInt(WI.getStrValue(strLoanType,"0"))]%></font> BALANCES OF THE <%=astrFSType[Integer.parseInt(strFSType)]%> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27"> AS OF <%=WI.fillTextValue("end_date")%></td>
    </tr>
    <tr> 
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5"><div align="right">Number of employees per page 
          <select name="num_rows">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"20"));
				for(i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font></div></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/PRRetLoan.defSearchSize;		
	if(iSearchResult % PRRetLoan.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr> 
      <td height="25" colspan="5"><div align="right">Jump To page: 
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
        </div></td>
    </tr>
    <%}%>
    <tr> 
      <td width="6%" height="25" class="BorderAll"><div align="center"><strong><font size="1">COUNT</font></strong></div></td>
      <td width="40%" height="25" class="BorderAll"><div align="center"><strong><font size="1">EMPLOYEE 
          NAME </font></strong></div></td>
      <td width="18%" height="25" class="BorderAll"><div align="center"><strong><font size="1">TOTAL 
          LOAN </font></strong></div></td>
      <td width="18%" class="BorderAll"><div align="center"><strong><font size="1">TOTAL PAYMENT</font></strong></div></td>
      <td width="18%" class="BorderAll"><div align="center"><strong><font size="1">LOAN BALANCE</font></strong></div></td>
    </tr>
    <%
	int iCount = 1;
	for(i = 0; i < vRetResult.size(); i+=7,iCount++){
	%>
    <tr> 
      <td height="24" class="BorderBottomLeft"><div align="right"><%=iCount%>&nbsp;</div></td>
      <td height="24" class="BorderBottomLeft"><div align="left"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2),
							(String)vRetResult.elementAt(i+3), 4)%></strong></font></div></td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalLoan += Double.parseDouble(strTemp);
	%>							
      <td height="24" class="BorderBottomLeft"><div align="right">&nbsp;<%=strTemp%>&nbsp;</div></td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalPaid += Double.parseDouble(strTemp);
	%>      
	  <td class="BorderBottomLeft"><div align="right">&nbsp;<%=strTemp%>&nbsp;</div></td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dPayable += Double.parseDouble(strTemp);
	%>      
	  <td class="BorderBottomLeftRight"><div align="right">&nbsp;<%=strTemp%>&nbsp;</div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="24" colspan="2" class="BorderBottomLeft"><div align="right">TOTAL :&nbsp;&nbsp;&nbsp;</div></td>
      <td height="24" class="BorderBottomLeft"><div align="right"><%=CommonUtil.formatFloat(dTotalLoan,true)%>&nbsp;</div></td>
      <td class="BorderBottomLeft"><div align="right"><%=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</div></td>
      <td class="BorderBottomLeftRight"><div align="right"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</div></td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="proceed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>