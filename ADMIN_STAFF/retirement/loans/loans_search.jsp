<%@ page language="java" import="utility.*,payroll.PRRetirementLoan,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript" src="../../../jscript/common.js"></script>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
	this.SubmitOnce("form_");
}

function SearchLoans()
{
	document.form_.start_search.value = "1";
	
	if(document.form_.bank_index.value.length > 0)
		document.form_.bank.value = document.form_.bank_index[document.form_.bank_index.selectedIndex].text;
	ReloadPage();
}

function ViewDetails(strEmpID){
	location = "./search_view_dtls.jsp?emp_id="+strEmpID;
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function updateSearchCondition(){	
	if (document.form_.cur_bal.value.length > 0){	
		document.form_.current_balance.value = 
			document.form_.balance_con[document.form_.balance_con.selectedIndex].text;						
	}else{
			document.form_.current_balance.value = "";		
	}

	if (document.form_.total.value.length > 0){	
		document.form_.total_application.value = 
			document.form_.total_con[document.form_.total_con.selectedIndex].text;						
	}else{
			document.form_.total_application.value = "";		
	}

	if (document.form_.active.value.length > 0){	
		document.form_.active_loans.value = 
			document.form_.active_con[document.form_.active_con.selectedIndex].text;						
	}else{
			document.form_.active_loans.value = "";		
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
	<jsp:forward page="./search_entry_print.jsp?" />
<% return;}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS/ADVANCES-Search","search_entry.jsp");
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
String[] astrSortByName    = {"Employee ID","Lastname","Firstname","Amount Loaned", "Loan Type","College","Dept/Office"};
String[] astrSortByVal     = {"id_number","lname","fname","amount", "loan_type", "college.c_index", "department.d_index"};
String strTemp2 = null;
String strTemp3 = null;
double dTotalPayment = 0d;

int iSearchResult = 0;

PRRetirementLoan searchLoans = new PRRetirementLoan(request);

if (WI.fillTextValue("start_search").compareTo("1") == 0){
	vRetResult = searchLoans.searchRetirementLoans(dbOP);
	if(vRetResult == null)
		strErrMsg = searchLoans.getErrMsg();
	else	
		iSearchResult = searchLoans.getSearchCount();
}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form  method="post" name="form_" action="./loans_search.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          RETIREMENT -LOANS - SEARCH/VIEW LOANS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Emp. ID :</td>
      <td><select name="id_number_con">
          <%=searchLoans.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
        <input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16"></td>
      <td>Loan Bank : </td>
	  <%
	  	strTemp = WI.fillTextValue("bank_index");
	  %>
      <td><select name="bank_index">
          <option value="">Select Bank</option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_NAME", " from AC_COA_BANKCODE WHERE is_valid = 1", strTemp,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Last Name :</td>
      <td width="34%"><select name="lname_con">
          <%=searchLoans.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
        <input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16"> 
      </td>
      <td width="12%">Loan Code : </td>
      <td width="37%"><select name="loan_code_con">
          <%=searchLoans.constructGenericDropList(WI.fillTextValue("loan_code_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
        <input type="text" name="loan_code" value="<%=WI.fillTextValue("loan_code")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>First Name :</td>
      <td><select name="fname_con">
          <%=searchLoans.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
        <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16"> 
      </td>
      <td>Loan Type :</td>
      <td><select name="loan_type">
          <option value="">Select Type</option>		  
        <%if(WI.fillTextValue("loan_type").equals("1")){%>
		  <option value="0">Regular Retirement Fund</option>
          <option value="1" selected>Emergency</option>
        <%}else if(WI.fillTextValue("loan_type").equals("0")){%>
		  <option value="0" selected>Regular Retirement Fund</option>
          <option value="1">Emergency</option>
        <%}else{%>
		  <option value="0">Regular Retirement Fund</option>
          <option value="1">Emergency</option>		  
		<%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>College :</td>
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>	  
      <td><select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        </select></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="1%" height="26">&nbsp;</td>
      <td width="16%"><div align="left">Dept./ Office :</div></td>
      <td colspan="3"><select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Amount Loaned : </td>
      <td height="26" colspan="3"><select name="amount_con">
          <%=searchLoans.constructGenericDropList(WI.fillTextValue("amount_con"),astrDropListGT,astrDropListValGT)%> 
        </select>		
		<%
		strTemp = WI.fillTextValue("amount_loan");
		%>
        <font size="1"><strong>
        <input name="amount_loan" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=strTemp%>" size="12" maxlength="12" 
		onKeyUp="AllowOnlyIntegerExtn('form_','amount_loan','.');"
		onBlur="AllowOnlyIntegerExtn('form_','amount_loan','.');style.backgroundColor='white'">
        </strong></font> </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26" valign="bottom"><strong><u>SORT</u></strong> </td>
      <td height="26" colspan="3" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="38">&nbsp;</td>
      <td height="38" colspan="4">1) 
        <select name="sort_by1">
          <option value="">N/A</option>
          <%=searchLoans.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
        </select>
        <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select>
        2) 
        <select name="sort_by2">
          <option value="">N/A</option>
          <%=searchLoans.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select>
        <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
		if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="38">&nbsp;</td>
      <td height="38" colspan="4">3) 
        <select name="sort_by3">
          <option value="">N/A</option>
          <%=searchLoans.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select>
        <select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select>
        4) 
        <select name="sort_by4">
          <option value="">N/A</option>
          <%=searchLoans.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> 
        </select>
        <select name="sort_by4_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="38">&nbsp;</td>
      <td height="38" colspan="4">5) 
        <select name="sort_by5">
          <option value="">N/A</option>
          <%=searchLoans.constructSortByDropList(WI.fillTextValue("sort_by5"),astrSortByName,astrSortByVal)%> 
        </select>
        <select name="sort_by5_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by5_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="38"><div align="center"><font size="1"></font></div></td>
      <td height="38">&nbsp;</td>
      <td height="38" colspan="3" valign="bottom"><font size="1"><a href="javascript:SearchLoans()"><img src="../../../images/form_proceed.gif" border="0"></a> 
        </font></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26" colspan="5"><div align="right"><font><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a></font><font size="1">click 
          to PRINT Search Result</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:: 
          SEARCH RESULT :: </strong></font></div></td>
    </tr>
    <tr bgcolor="#E1CEBD"> 
      <%
	  	if(WI.fillTextValue("loan_type").length() > 0){
			if (WI.fillTextValue("loan_type").equals("0")){
				strTemp = "Regular Retirement Fund";
			}else{
				strTemp = "Emergency";
			}
		}else{
			strTemp = "";
		}
	  %>
      <td height="25" colspan="2" bgcolor="#E1CEBD">&nbsp;<%=WI.getStrValue(strTemp,"LOAN TYPE : ","","&nbsp;")%></td>
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(WI.fillTextValue("bank"),"LOAN BANK : ","","&nbsp;")%></td>
    </tr>
    <tr> 
      <td width="7%"><div align="center"><font size="1"><strong>LOAN CODE</strong></font></div></td>
      <td width="26%" height="25"><div align="center"><font size="1"><strong>EMPLOYEE 
          NAME </strong></font></div></td>
      <td width="34%"><div align="center"><font size="1"><strong>COLLEGE/DEPT.OFFICE</strong></font></div></td>
      <td width="10%" height="25"><div align="center"><font size="1"><strong>AMOUNT 
          LOANED </strong></font></div></td>
      <td width="12%"><div align="center"><strong><font size="1">TOTAL PAYMENT</font></strong></div></td>
      <td width="11%"><div align="center"><strong><font size="1">LOAN BALANCE</font></strong></div></td>
    </tr>
    <%for(int i = 0;i<vRetResult.size();i+=10){%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i+5)%></td>
      <td height="25"><%=WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2),
							(String)vRetResult.elementAt(i+3), 4)%></td>
      <%if((String)vRetResult.elementAt(i + 7)== null || (String)vRetResult.elementAt(i + 8)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>
      <td height="25">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"&nbsp;")%> </td>
      <td height="25"><div align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true)%>&nbsp;</div></td>
      <%
	  	dTotalPayment = Double.parseDouble((String)vRetResult.elementAt(i+4)) - Double.parseDouble((String)vRetResult.elementAt(i+6));
	  %>
      <td height="25"><div align="right"><%=CommonUtil.formatFloat(dTotalPayment,true)%></div></td>
      <td height="25"><div align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true)%>&nbsp;</div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="2"><strong><font size="1">TOTAL NO. OF BORROWER 
        :</font></strong></td>
      <td height="25"><div align="right">TOTAL :&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="bank">
  <input type="hidden" name="print_page">
  <input type="hidden" name="start_search">
</form>
</body>
</html>
