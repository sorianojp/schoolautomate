<%@ page language="java" import="utility.*,payroll.PRRetirementLoan ,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Loans</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
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
	font-size: 11px;
    }

-->
</style>

<script>
<!--
function ReloadPage()
{
	document.form_.print_page.value="";
	document.form_.start_search.value="";
	this.SubmitOnce("form_");
}

function SearchResult()
{
	document.form_.start_search.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function ViewDetails(strEmpID){
	location = "./search_view_dtls.jsp?emp_id="+strEmpID;
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function updateBenefitName(){	
	if (document.form_.benefit_index.selectedIndex == 0){
		document.form_.benefit_name.value = "";		
	}else{
		document.form_.benefit_name.value = 
			document.form_.benefit_index[document.form_.benefit_index.selectedIndex].text;						
	}
	
	document.form_.print_page.value="";	
	this.SubmitOnce("form_");	
}
-->
</script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

// if this page is calling print page, i have to forward page to print page.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./search_by_loan_print.jsp?" />
<% return;}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS/ADVANCES-Search","search_by_loan.jsp");
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
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"'='","'<'","'>'"};
String[] astrSortByName    = {"Employee ID","Lastname","Firstname"};
String[] astrSortByVal     = {"id_number","lname","fname"};

String strLoanType = null;
String strCodeIndex = null;
String[] astrLoanType = {"Regular Retirement Loan","Emergency Loan","Institutional/Company Loan", "SSS Loan", "PAG-IBIG Loan", 
						"PERAA Loan","GSIS Loan"};
String strTypeName = null;	

int iSearchResult = 0;
int i = 0;
PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);

if (WI.fillTextValue("start_search").compareTo("1") == 0){
	vRetResult = PRRetLoan.searchLoansByType(dbOP);
	if(vRetResult == null)
		strErrMsg = PRRetLoan.getErrMsg();
	else	
		iSearchResult = PRRetLoan.getSearchCount();
}
%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="search_by_loan.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: ADVANCES/DEDUCTIONS : SEARCH ENTRIES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="5"><strong><font size="2">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr> 
      <td width="2%" height="24">&nbsp;</td>
      <td width="16%">Employee ID </td>
      <td width="82%" colspan="3"><select name="id_number_con">
          <%=PRRetLoan.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input name="id_number" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("id_number")%>" size="12"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Loan</td>
	  <%	
	  	strLoanType = WI.fillTextValue("loan_type");	
	  %>
      <td colspan="3">
	  <select name="loan_type" onChange="ReloadPage();">
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
      <td height="25">&nbsp;</td>
      <td>Loan Name </td>
	  <%
	  	strCodeIndex = WI.fillTextValue("code_index");
	  %>
      <td colspan="3"><select name="code_index" onChange="ReloadPage();">
        <option value="">Select Loan</option>
        <%=dbOP.loadCombo("code_index","loan_name, loan_code",
		                    " from ret_loan_code where is_valid = 1 and loan_type = " + WI.getStrValue(strLoanType,"2"),
							strCodeIndex ,false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date released</td>
      <td colspan="3">From
        <%strTemp = WI.fillTextValue("released_fr");%>
        <input name="released_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.released_fr');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
		<img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <%strTemp = WI.fillTextValue("released_to");%>
        <input name="released_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.released_to');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
		<img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>First Payment</td>
      <td colspan="3">From 
        <%strTemp = WI.fillTextValue("first_pay_fr");%> 
		<input name="first_pay_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.first_pay_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("first_pay_to");%> 
		<input name="first_pay_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.first_pay_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
    <tr> 
      <td height="19" colspan="5"><hr size="1"></td>
    </tr>
  </table>
	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="13">&nbsp;</td>
      <td height="13" colspan="3">SORT BY :</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td width="23%" height="29"><select name="sort_by1">
          <option value="">N/A</option>
          <%=PRRetLoan.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td><select name="sort_by2">
          <option value="">N/A</option>
          <%=PRRetLoan.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> </td>
      <td height="29"><select name="sort_by3">
          <option value="">N/A</option>
          <%=PRRetLoan.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select>
      </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29"><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="23%"><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="51%" height="29"><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="10" colspan="4">&nbsp; </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10"><a href="javascript:SearchResult()"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" dwcopytype="CopyTableRow">
    <tr> 
      <td height="10" colspan="3"><div align="right"><font size="2">Number of 
          Employees Per Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 16; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4" bgcolor="#B9B292"><div align="center"><strong><strong>PAYROLL: 
          ADVANCES/DEDUCTIONS</strong> RESULT </strong></div></td>
    </tr>
    <tr> 
      <td height="28" colspan="3"><strong><font size="1">TOTAL RESULT : </font><%=iSearchResult%> - Showing(<%=PRRetLoan.getDisplayRange()%>)</strong></td>
      <td height="28"> &nbsp;<%
		int iPageCount = iSearchResult/PRRetLoan.defSearchSize;
		if(iSearchResult % PRRetLoan.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="SearchResult();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i ){
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
    <tr> 
      <td width="12%" height="28"><div align="center"><font size="1"><strong>EMPLOYEE 
      ID </strong></font></div></td>
      <td width="49%"><div align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></div></td>
      <td><div align="center"><font size="1"><strong>RELEASED</strong></font></div></td>
      <td><div align="center"><strong><font size="1"> DETAILS</font></strong></div></td>
    </tr>
    <% for (int j = 0; j < vRetResult.size() ; j+=7) {%>
    <tr> 
      <td height="33">&nbsp;<%=(String)vRetResult.elementAt(j+1)%></td>
      <td height="33"><div align="left">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(j+2),(String)vRetResult.elementAt(j+3),(String)vRetResult.elementAt(j+4),4).toUpperCase()%></div></td>
      <td width="19%">&nbsp;</td>
      <td width="20%"><div align="center"><a href="javascript:ViewDetails('<%=(String)vRetResult.elementAt(j+1)%>')"><img src="../../../../images/view.gif" border="0" ></a></div></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>	
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_page">
<input type="hidden" name="start_search">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>