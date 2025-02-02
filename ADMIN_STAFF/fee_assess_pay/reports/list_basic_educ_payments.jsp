<%@ page language="java" import="utility.*,enrollment.FAElementaryPayment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.

	if (WI.fillTextValue("print_page").compareTo("1") ==0) {%>
	<jsp:forward page="list_basic_educ_payments_print.jsp" />
	<% return;}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - Reports ","list_basic_educ_payments.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
														"list_basic_educ_payments.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal","More than","Less Than"};
String[] astrDropListValGT = {"=","greater","less"};
String[] astrSortByName    = {"Date","Educ Level", "Year Level","Last Name","First Name","Amount"};
String[] astrSortByVal     = {"date_paid","edu_level","year_level","fa_elementary_payment.lname",
								"fa_elementary_payment.fname","fa_elementary_payment.amount"};
int iSearchResult = 0;
FAElementaryPayment fa = new FAElementaryPayment(request);

if (WI.fillTextValue("reloadPage").compareTo("1") == 0){
	vRetResult = fa.searchBasicPayments(dbOP);
	if (vRetResult == null)
		strErrMsg = fa.getErrMsg();
	else	
		iSearchResult = fa.getSearchCount();
}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
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
-->
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function ReloadPage(){
	document.form_.reloadPage.value ="";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}
function showList(){
	document.form_.reloadPage.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function clearAll(){
	document.form_.date_from.value = "";
	document.form_.date_to.value = "";
}

function PrintPg(){
	document.form_.print_page.value = "1";
	this.SubmitOnce("form_");	
}
-->
</script>
<body bgcolor="#D2AE72">
<form action="./list_basic_educ_payments.jsp" method="post" name="form_">

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A" > 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LIST OF BASIC EDUCATION PAYMENTS ::::</strong></font></strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> 
      </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26" colspan="4"><strong>Date of Payment &nbsp;&nbsp;&nbsp; 
        <input name="date_from" type="text" class="textbox" readonly="yes"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.fillTextValue("date_from")%>" size="10">
        <a href="javascript:show_calendar('form_.date_from');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        &nbsp;to &nbsp; 
        <input name="date_to" type="text" class="textbox" id="date_to5"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="10"
	  readonly="yes">
        <font size="1"> <a href="javascript:show_calendar('form_.date_to');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:clearAll();"><img src="../../../images/clear.gif" width="55" height="19" border="0"></a></font></strong><font size="1">click 
        to clear dates</font></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td><strong>Teller ID</strong></td>
      <td><input name="teller_id" type="text" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("teller_id")%>" size="16"></td>
      <td height="26"><strong>School Year</strong></td>
      <td valign="bottom"><strong> 
        <input name="sy_from" type="text" class="textbox" maxlength="4"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  value="<%=WI.fillTextValue("sy_from")%>" size="4" onKeyUp="AllowOnlyInteger('form_','sy_from')">
        <font size="1"> </font></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><strong>Student ID</strong></td>
      <td><select name="stud_id_con">
          <%=fa.constructGenericDropList(WI.fillTextValue("stud_id_con"),astrDropListEqual,astrDropListValEqual)%> </select> 
        <input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		value="<%=WI.fillTextValue("stud_id")%>" size="16"></td>
      <td height="26"><strong>OR Number</strong></td>
      <td valign="bottom"><select name="or_number_con" id="or_number_con" >
          <%=fa.constructGenericDropList(WI.fillTextValue("or_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input name="or_number" type="text" class="textbox" id="or_number" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("or_number")%>" size="16"></td>
    </tr>
    <tr> 
      <td width="1%" height="26">&nbsp;</td>
      <td width="13%"><strong>First Name</strong></td>
      <td width="38%"><select name="fname_con" >
          <%=fa.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input name="fname" type="text" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("fname")%>" size="16"> 
      </td>
      <td width="13%" height="26"><strong>Amount </strong></td>
      <td width="35%" valign="bottom"><select name="amount_con">
          <%=fa.constructGenericDropList(WI.fillTextValue("amount_con"),astrDropListGT,astrDropListValGT)%> </select> 
		  <input name="amount" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'" value="<%=WI.fillTextValue("amount")%>" size="16"
	  onKeyUp="AllowOnlyFloat('form_','amount');"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><strong>Middle Name</strong></td>
      <td><select name="mname_con">
          <%=fa.constructGenericDropList(WI.fillTextValue("mname_con"),astrDropListEqual,astrDropListValEqual)%> </select> 
	  <input name="mname" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("mname")%>" size="16"> 
      <td height="10"><strong>Educ Level</strong></td>
      <td height="10"><select name="edu_level" id="edu_level">
          <option value="">ALL</option>
	  <% if (WI.fillTextValue("edu_level").compareTo("0") == 0){%>
          <option value="0" selected>Preparatory</option>
	  <%}else{%>
          <option value="0">Preparatory</option>
	  <%} if (WI.fillTextValue("edu_level").compareTo("1") == 0){%>
          <option value="1" selected>Elementary</option>
	  <%}else{%>	
          <option value="1">Elementary</option>	  
  	  <%} if (WI.fillTextValue("edu_level").compareTo("2") == 0){%>
          <option value="2" selected>High School </option>
	  <%}else{%>
          <option value="2">High School </option>	
	  <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><strong>Last Name</strong></td>
      <td><select name="lname_con" >
          <%=fa.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select> .
		  <input name="lname" type="text" class="textbox" id="lname4" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("lname")%>" size="16"></td>
      <td height="10"><strong>Year Level</strong></td>
      <td height="10"><select name="year_level">
          <option value="">All</option>
	  <% if (WI.fillTextValue("year_level").compareTo("1") == 0){%>
          <option value="1" selected>1st</option>
	  <%}else{%>
          <option value="1">1st</option>
	  <%} if (WI.fillTextValue("year_level").compareTo("2") == 0){%>		  
          <option value="2" selected>2nd</option>
	  <%}else{%>
          <option value="2">2nd</option>
	  <%} if (WI.fillTextValue("year_level").compareTo("3") == 0){%>		  
          <option value="3" selected>3rd</option>
	  <%}else{%>
          <option value="3">3rd</option>
	  <%} if (WI.fillTextValue("year_level").compareTo("4") == 0){%>		  
          <option value="4" selected>4th</option>
	  <%}else{%>
          <option value="4">4th</option>
	  <%} if (WI.fillTextValue("year_level").compareTo("5") == 0){%>		  
          <option value="5" selected>5th</option>
	  <%}else{%>
          <option value="5">5th</option>
	  <%} if (WI.fillTextValue("year_level").compareTo("6") == 0){%>		  
          <option value="6" selected>6th</option>
	  <%}else{%>
          <option value="6">6th</option>
	 <%}%>		  
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>School Name</strong></td>
      <td height="25" colspan="3"><select name="sch_index" id="sch_index">
          <option value=""> ALL</option>
          <%=dbOP.loadCombo("SCH_INDEX","SCH_NAME"," from SCHOOL_LIST order by SCH_NAME",WI.fillTextValue("sch_index"),false)%> </select></td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="bottom"><a href="javascript:showList()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="15" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="25" colspan="4"><strong>SORT OPTIONS</strong></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="25" colspan="4"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr bgcolor="#FFFFFF"> 
            <td width="1%">&nbsp;</td>
            <td width="7%"><select name="sort_by1">
                <option value="">N/A</option>
                <%=fa.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select></td>
            <td width="24%" height="29"><select name="sort_by1_con">
                <option value="asc">Ascending</option>
                <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Descending</option>
                <%}else{%>
                <option value="desc">Descending</option>
                <%}%>
              </select> </td>
            <td width="10%"><select name="sort_by2">
                <option value="">N/A</option>
                <%=fa.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
            <td width="24%"><select name="sort_by2_con">
                <option value="asc">Ascending</option>
                <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Descending</option>
                <%}else{%>
                <option value="desc">Descending</option>
                <%}%>
              </select></td>
            <td width="8%"><select name="sort_by3">
                <option value="">N/A</option>
                <%=fa.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> </td>
            <td width="27%" height="29"><select name="sort_by3_con">
                <option value="asc">Ascending</option>
                <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Descending</option>
                <%}else{%>
                <option value="desc">Descending</option>
                <%}%>
              </select> </td>
          </tr>
        </table></td>
    </tr>
  </table>
 <% if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" >
    <tr> 
      <td height="25" ><strong>&nbsp;TOTAL RESULT : <%=iSearchResult%> 
        - Showing(<%=fa.getDisplayRange()%>)</strong></td>
      <td>&nbsp;
        <%
		int iPageCount = iSearchResult/fa.defSearchSize;
		if(iSearchResult % fa.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page: 
          <select name="jumpto" onChange="showList();">
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
          </select></div>
          <%}%>
        </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" bgcolor="#cccccc" class="thinborder"><div align="center"><strong><font size="2">LIST 
          OF BASIC EDUCATION PAYMENTS</font></strong></div></td>
    </tr>
    <tr align="center"> 
      <td width="10%" height="25" class="thinborder"><strong>DATE</strong></td>
      <td width="16%" class="thinborder"><strong>STUDENT ID</strong></td>
      <td width="34%" class="thinborder"><strong>STUDENT NAME</strong></td>
      <td width="14%" class="thinborder"><strong>AMOUNT </strong></td>
      <td width="14%" class="thinborder"><strong>OR NUMBER</strong></td>
      <td width="12%" class="thinborder"><strong>TELLER ID</strong></td>
    </tr>
    <% double dTotal = 0d; double dCurrentAmount = 0d;
		for (int i= 0; i < vRetResult.size() ; i+=12) {
		dCurrentAmount = Double.parseDouble((String)vRetResult.elementAt(i+9));
		dTotal +=dCurrentAmount;
	%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td  class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td  class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5),4)%></td>
      <td class="thinborder" align="right"> <%=CommonUtil.formatFloat(dCurrentAmount,true)%></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+8)%></div></td>
      <td class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+1)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM"><div align="right"><strong>Total Amount for 
          this Page : </strong></div></td>
      <td align="right" class="thinborderBOTTOM"><strong><%=CommonUtil.formatFloat(dTotal,true)%></strong></td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
   <% if (vRetResult!= null) {%>
    <tr> 
      <td height="20">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><div align="center"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click 
          to print List</font></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>