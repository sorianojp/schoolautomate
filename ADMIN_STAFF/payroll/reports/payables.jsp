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
	String strCodeIndex = null;
	String[] astrPayableType = {"","Loans only", "Misc. Deductions only"};
	String strTypeName = null;	
	
	int iSearchResult = 0;
	int i = 0;
	int iDefault = 0;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dPayable = 0d;
	String strPrevEmp = null;
	String strTemp2 = null;

	if (WI.fillTextValue("proceed").length() > 0) {
		vRetResult = PRRetLoan.getIndLoanBal(dbOP,request);		
		if(vRetResult == null)
			strErrMsg = PRRetLoan.getErrMsg();		
		else{
		iSearchResult = PRRetLoan.getSearchCount();
		}
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="indv_total_loan_bal.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::LOANS 
      - REPORTS - INDIVIDUAL TOTAL LOAN BALANCES PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="3">&nbsp;<strong><a href="../loans_report_main.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a>&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="15%" height="27">Payable</td>
      <%
	  	strLoanType = WI.fillTextValue("loan_type");
	  %>	  
      <td width="82%" height="27">
	  <select name="loan_type" onChange="ReloadPage();">	  	
		<option value="" selected>ALL</option>
		<%for(i = 2; i < 7; i++){%>        
        <%if(strLoanType.equals(Integer.toString(i))){
		strTypeName = astrLoanType[i];
		%>
        <option value="<%=i%>" selected><%=astrLoanType[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrLoanType[i]%></option>
        <%}%>
		<%}// end for loop%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td height="27">
			<!--
			<a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
			<font size="1">click to list loan balances</font>			</td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="97%" height="27">OUTSTANDING <%=WI.getStrValue(strTypeName," ").toUpperCase()%> BALANCES</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27"> AS OF <%=WI.getTodaysDate(1)%></td>
    </tr>
    <tr> 
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="6"><div align="right">Number of employees per page 
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
      <td height="25" colspan="6"><div align="right">Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
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
      <td height="15" colspan="6" class="BorderBottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="5%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">COUNT</font></strong></td>
      <td width="43%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">EMPLOYEE 
      NAME </font></strong></td>
      <td width="16%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN NAME </font></strong></td>
      <td width="12%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL 
      LOAN </font></strong></td>
      <!--
			<td width="12%" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL PAYMENT</font></strong></td>
			-->
      <td width="12%" align="center" class="BorderBottomLeftRight"><strong><font size="1">LOAN BALANCE</font></strong></td>
    </tr>
    <%
	int iCount = 1;
	strPrevEmp = "";
	for(i = 0; i < vRetResult.size(); i+=20){
		if(strPrevEmp.equals((String)vRetResult.elementAt(i+8))){
			strTemp2 = "";
			strTemp = "";
		}else{			
			strTemp = Integer.toString(iCount);
			strTemp2 = WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), 4);
			iCount++;
		}
	%>
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
      <td height="24" class="BorderBottomLeft"><font size="1"><strong>&nbsp;&nbsp;<%=strTemp2%></strong></font></td>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalLoan += Double.parseDouble(strTemp);
	%>							
      <td height="24" align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalPaid += Double.parseDouble(strTemp);
	%>      
	  <!--
		<td align="right" class="BorderBottomLeft">&nbsp;<%//=strTemp%>&nbsp;</td>
		-->
    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dPayable += Double.parseDouble(strTemp);
		%>      
	  <td align="right" class="BorderBottomLeftRight">&nbsp;<%=strTemp%>&nbsp;</td>
    </tr>
    <%
		strPrevEmp = (String)vRetResult.elementAt(i+8);
		}// end for loop %>
    <tr> 
      <td height="24" colspan="2" align="right" class="BorderBottomLeft">TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <td class="BorderBottomLeft">&nbsp;</td>
      <td height="24" align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalLoan,true)%>&nbsp;</td>
      <!--
			<td align="right" class="BorderBottomLeft"><%//=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</td>
			-->
      <td align="right" class="BorderBottomLeftRight"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
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
  <input type="hidden" name="print_page">
  <input type="hidden" name="proceed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>