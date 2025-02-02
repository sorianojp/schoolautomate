<%@ page language="java" import="utility.*,payroll.PRLoansAdv,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Loans</title>
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

String[] astrSortByName    = {"Employee ID","Lastname","Firstname","Current Balance"};
String[] astrSortByVal     = {"id_number","lname","fname","balance"};


int iSearchResult = 0;

PRLoansAdv searchLoans = new PRLoansAdv(request);



if (WI.fillTextValue("start_search").compareTo("1") == 0){
	vRetResult = searchLoans.searchLoansAdvances(dbOP);
	if(vRetResult == null)
		strErrMsg = searchLoans.getErrMsg();
	else	
		iSearchResult = searchLoans.getSearchCount();
}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="search_entry.jsp" method="post" name="form_" id="form_">
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
      <td height="25">&nbsp;</td>
      <td>Employee ID </td>
      <td colspan="3">
	  <%
	  	strTemp = WI.fillTextValue("id_number_con");
	  %>
	  <select name="id_number_con">
          <%=searchLoans.constructGenericDropList(strTemp,astrDropListEqual,astrDropListValEqual)%> </select> <input name="id_number" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("id_number")%>" size="12"></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">Current Balance</td>
      <td width="80%" colspan="3"> 
	  <select name="balance_con">          
          <%=searchLoans.constructGenericDropList(WI.fillTextValue("balance_con"),astrDropListGT,astrDropListValGT)%> 
      </select> 
        <input name="cur_bal" type="text" class="textbox" size="16" maxlength="16" 
		 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		 onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		 value="<%=WI.fillTextValue("cur_bal")%>">
		<input type="hidden" name="current_balance" value="<%=WI.getStrValue(WI.fillTextValue("current_balance"),"LOANS")%>"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Total Application</td>
      <td colspan="3">
	  <select name="total_con">
          <%=searchLoans.constructGenericDropList(WI.fillTextValue("total_con"),astrDropListGT,astrDropListValGT)%> </select> <input name="total" type="text" class="textbox" id="total" size="4" maxlength="4" value="<%=WI.fillTextValue("total")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <input type="hidden" name="total_application" value="<%=WI.getStrValue(WI.fillTextValue("total_application"),"LOANS")%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Total Active Accounts</td>
      <td colspan="3">
	  <select name="active_con">
          <%=searchLoans.constructGenericDropList(WI.fillTextValue("active_con"),astrDropListGT,astrDropListValGT)%> </select>
        <input name="active" type="text" class="textbox" id="active" size="4" maxlength="4"  value="<%=WI.fillTextValue("active")%>" 
		   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <input type="hidden" name="active_loans" value="<%=WI.getStrValue(WI.fillTextValue("active_loans"),"LOANS")%>"></td>
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
      <td height="28">&nbsp;</td>
      <td width="23%" height="28"><select name="sort_by1">
          <option value="">N/A</option>
          <%=searchLoans.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td><select name="sort_by2">
          <option value="">N/A</option>
          <%=searchLoans.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> </td>
      <td height="28"><select name="sort_by3">
          <option value="">N/A</option>
          <%=searchLoans.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select>
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
      <td height="10"><a href="javascript:SearchLoans()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" dwcopytype="CopyTableRow">
    <tr> 
      <td height="10" colspan="3" align="right"><font size="2">Number of 
          Employees Per Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i = 16; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#B9B292"><strong><strong>PAYROLL: 
          ADVANCES/DEDUCTIONS</strong> RESULT </strong></td>
    </tr>
    <tr> 
      <td height="28" colspan="3"><strong><font size="1">TOTAL RESULT : </font><%=iSearchResult%> - Showing(<%=searchLoans.getDisplayRange()%>)</strong></td>
      <td height="28" colspan="2" align="right"> <%
		int iPageCount = iSearchResult/searchLoans.defSearchSize;
		if(iSearchResult % searchLoans.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        Jump To page: 
          <select name="jumpto" onChange="SearchLoans();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
        <%}%>        </td>
    </tr>
    <tr> 
      <td width="15%" height="28" align="center"><font size="1"><strong>EMPLOYEE 
      ID </strong></font></td>
      <td width="30%" align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></td>
      <td height="28" align="center"><font size="1"><strong>TOTAL APPLICATION</strong></font></td>
      <td align="center"><font size="1"><strong>CURRENT BALANCE</strong></font></td>
      <td align="center"><strong><font size="1">CLICK TO DETAILS</font></strong></td>
    </tr>
    <% for (int j = 0; j < vRetResult.size() ; j+=8) {%>
    <tr> 
      <td height="25">&nbsp;<%=(String)vRetResult.elementAt(j+1)%></td>
      <td height="25">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(j+2),(String)vRetResult.elementAt(j+4),(String)vRetResult.elementAt(j+3),4).toUpperCase()%></td>
      <td width="14%" height="25" align="center"><%=(String)vRetResult.elementAt(j+5)%></td>
      <td width="15%" height="25" align="center"> <%=CommonUtil.formatFloat((String)vRetResult.elementAt(j+7),true)%></td>
      <td width="11%" align="center"><a href="javascript:ViewDetails('<%=(String)vRetResult.elementAt(j+1)%>')"><img src="../../../images/view.gif" border="0" ></a></td>
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