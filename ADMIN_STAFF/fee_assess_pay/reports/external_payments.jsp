<%@ page language="java" import="utility.*,enrollment.FAExternalPay,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.

	if (WI.fillTextValue("print_page").compareTo("1") ==0) {%>
	<jsp:forward page="external_payments_print.jsp" />
	<% return;}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - External Payments","external_payments.jsp");
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
														"external_payments.jsp");
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
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=","<",">"};
String[] astrSortByName    = {"Date","Name","Amount","Fee Type","OR Number"};
String[] astrSortByVal     = {"date_paid","name","amount","fee_name","or_number"};

int iSearchResult = 0;
FAExternalPay fa = new FAExternalPay(request);

if (WI.fillTextValue("reloadPage").equals("1")){
	vRetResult = fa.searchExtnPayments(dbOP);
	if (vRetResult == null)
		strErrMsg = fa.getErrMsg();
	else	
		iSearchResult = fa.getSearchCount();
}

boolean bolIsSearchInternal = false;
if(WI.fillTextValue("search_option").equals("1") || WI.fillTextValue("search_option").equals("2")) {
	bolIsSearchInternal = true;
	astrSortByName[1] = "Last Name";
	astrSortByVal[1]  = "name";
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsWNU = strSchCode.startsWith("WNU");


boolean bolShowSupplies = false;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
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
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript">
<!--
function ReloadPage(){
	document.form_.reloadPage.value ="";
	document.form_.print_page.value = "";
	document.form_.submit();
}
function showList(){
	document.form_.reloadPage.value = "1";
	document.form_.print_page.value = "";
	document.form_.submit();
}

function clearAll(){
	document.form_.date_from.value = "";
	document.form_.date_to.value = "";
}

function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.submit();	
}
function MovePmt(strPmtIndex) {
	var pgLoc = "./external_payments_move.jsp?payment_index="+strPmtIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=500,top=20,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
-->
</script>
<body bgcolor="#D2AE72">
<form action="./external_payments.jsp" method="post" name="form_">

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>:::: 
<%
if(WI.fillTextValue("search_option").equals("1"))
	strTemp = "INTERNAL";
else	
	strTemp = "EXTERNAL";
%>          <%=strTemp%> PAYMENTS PAGE ::::</strong></font></strong></font></div></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
strTemp = WI.fillTextValue("search_option");
if(strTemp.equals("0") || strTemp.length() == 0)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
	  <input name="search_option" type="radio" value="0"<%=strErrMsg%> onClick="ReloadPage();">Search External Payment 
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
      <input name="search_option" type="radio" value="1"<%=strErrMsg%> onClick="ReloadPage();">Search Internal Payment 
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
	  <input name="search_option" type="radio" value="2" <%=strErrMsg%>> Show ALL
	  </td>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:9px; font-weight:bold; color:#0000FF">
<%if(strSchCode.startsWith("PHILCST")){%>
<%
strTemp = WI.fillTextValue("show_supplies");

if(strTemp.equals("1")) {
	strTemp = " checked";
	bolShowSupplies = true;
}
else	
	strTemp = "";
%>	  
	  <input type="checkbox" name="show_supplies" value="1" <%=strTemp%>> Show only Supplies	  
<%}


strTemp = WI.fillTextValue("inc_temp");

if(strTemp.equals("1")) 
	strTemp = " checked";
else	
	strTemp = "";
%>	  
	  <input type="checkbox" name="inc_temp" value="1" <%=strTemp%>>
	   Include Student  not validated  
<%
strTemp = WI.fillTextValue("show_only_temp");

if(strTemp.equals("1")) 
	strTemp = " checked";
else	
	strTemp = "";
%>	  
	  <input type="checkbox" name="show_only_temp" value="1" <%=strTemp%>>   	   Show Only  Student  not validated	  </td>
	</tr>

<%if(bolIsSearchInternal && !strSchCode.startsWith("AUF") && !WI.fillTextValue("search_option").equals("2")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY-TERM</td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0 && request.getParameter("sy_from") == null) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0 && request.getParameter("sy_from") == null) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>"
		 class="textbox" readonly="true">
	  <select name="semester">
	  <option value="1">1st Sem</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="3"<%=strErrMsg%>>3rd Sem</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="0"<%=strErrMsg%>>Summer</option>
	  </select>
Note: To Ignore Sy/Term, remove SY Information.	  </td>
    </tr>
<%}%>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">Date of Payment</td>
      <td width="81%"> 
        <input name="date_from" type="text" class="textbox" id="date_from" readonly="yes"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.fillTextValue("date_from")%>" size="10"> <a href="javascript:show_calendar('form_.date_from');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <input name="date_to" type="text" class="textbox" id="date_to"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="10"
	  readonly="yes">
      <a href="javascript:show_calendar('form_.date_to');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:clearAll();"><img src="../../../images/clear.gif" width="55" height="19" border="0"></a></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Fee Type</td>
      <td height="10"><select name="fee_type" style="font-size:11px">
          <option value=""> ALL </option>
          <!--<option value="0">Fine</option>-->
<%if(bolIsSearchInternal)
	strTemp = 
		" from fa_oth_sch_fee   " + 
		" where  exists ( select * from fa_stud_payment where  fa_stud_payment.OTHSCH_FEE_INDEX = "+
		" fa_oth_sch_fee.OTHSCH_FEE_INDEX   and name is null " + 
		" and fa_stud_payment.is_valid = 1 and user_index is not null)" + 
		" or exists ( select * from fa_stud_payable where fa_stud_payable.user_Index is not null " + 
		" and payment_index is not null and  reference_index = fa_oth_sch_fee.OTHSCH_FEE_INDEX) " ;
  else
	strTemp = 
		" from fa_oth_sch_fee   " + 
		" where  exists ( select * from fa_stud_payment where  fa_stud_payment.OTHSCH_FEE_INDEX = "+
		" fa_oth_sch_fee.OTHSCH_FEE_INDEX  " + 
		" and fa_stud_payment.is_valid = 1 and user_index is null and name is not null)" + 
		" or exists ( select * from fa_stud_payable where fa_stud_payable.user_Index is null " + 
		" and payment_index is not null and  reference_index = fa_oth_sch_fee.OTHSCH_FEE_INDEX) ";
	if(bolShowSupplies)
		strTemp += " and exists (select * from FA_OTH_SCH_FEE_SUPPLIES where SUPPLY_FEE_NAME = fa_oth_sch_fee.fee_name) ";
  	
	strTemp += " order by fa_oth_sch_fee.fee_name";
		  //<% strTemp = " from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and year_level=0 and "+
		//"sy_index=(select sy_index from FA_SCHYR where sy_from="+request.getParameter("sy_from")+" and sy_to="+
		//request.getParameter("sy_to")+") order by FEE_NAME asc";
		%>
          <%=dbOP.loadCombo("distinct fa_oth_sch_fee.FEE_NAME","fa_oth_sch_fee.FEE_NAME",strTemp, request.getParameter("fee_type"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Amount </td>
      <td height="10"><select name="amount_con">
          <%=fa.constructGenericDropList(WI.fillTextValue("amount_con"),astrDropListGT,astrDropListValGT)%> </select> <input name="amount" type="text" class="textbox" id="amount" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("amount")%>" size="32"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%if(bolIsSearchInternal){%>Last Name<%}else{%>Name of Payee<%}%></td>
      <td height="10"><select name="payee_con">
          <%=fa.constructGenericDropList(WI.fillTextValue("payee_con"),astrDropListEqual,astrDropListValEqual)%> </select> 
<%if(bolIsSearchInternal){%>
	  <input name="lname" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("lname")%>" size="32">
<%}else{%>
	  <input name="payee" type="text" class="textbox" id="payee"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("payee")%>" size="32">
<%}%>	  </td>
    </tr>
<%if(bolIsSearchInternal){%>
    <tr> 
      <td>&nbsp;</td>
      <td>Student ID </td>
      <td height="10">
	  <input name="stud_id" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("stud_id")%>" size="32"
	  onKeyUp="AjaxMapName('1');">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>	  </td>
    </tr>
<%if(strSchCode.startsWith("CSA")){%>
    <tr>
      <td>&nbsp;</td>
      <td>College</td>
      <td height="10">
        <select name="c_index">
          <option value="">All College</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del = 0",WI.fillTextValue("c_index"),false)%>
        </select>
	  </td>
    </tr>
<%}%>

<%}%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10"></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10"><a href="javascript:showList()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="15">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td><strong>SORT OPTIONS</strong></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="25" colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr bgcolor="#FFFFFF"> 
            <td width="5%">&nbsp;</td>
            <td width="22%" height="29"><select name="sort_by1">
                <option value="">N/A</option>
                <%=fa.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
            <td width="26%"><select name="sort_by2">
                <option value="">N/A</option>
                <%=fa.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> </td>
            <td width="47%" height="29"><select name="sort_by3">
                <option value="">N/A</option>
                <%=fa.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> </td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td>&nbsp;</td>
            <td height="29"><select name="sort_by1_con">
                <option value="asc">Ascending</option>
                <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Descending</option>
                <%}else{%>
                <option value="desc">Descending</option>
                <%}%>
              </select></td>
            <td><select name="sort_by2_con">
                <option value="asc">Ascending</option>
                <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Descending</option>
                <%}else{%>
                <option value="desc">Descending</option>
                <%}%>
              </select></td>
            <td height="29"><select name="sort_by3_con">
                <option value="asc">Ascending</option>
                <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Descending</option>
                <%}else{%>
                <option value="desc">Descending</option>
                <%}%>
              </select> </td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="10">&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
if(bolIsSearchInternal)
	strTemp = "INTERNAL";
else
	strTemp = "EXTERNAL";

%>    <tr> 
      <td height="25" colspan="7" bgcolor="#cccccc" class="thinborderTOPLEFTRIGHT"><div align="center"><strong><font size="2">LIST 
          OF <%=strTemp%> PAYMENTS</font></strong></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center"> 
      <td width="10%" height="25" class="thinborder"><strong>DATE</strong></td>
      <td width="23%" class="thinborder"><strong>PAYEE NAME</strong></td>
<%if(bolIsSearchInternal){%>
      <td width="12%" class="thinborder" style="font-weight:bold">ID NUMBER </td>
      <td width="10%" class="thinborder"><strong>COURSE - YR</strong></td>
<%}%>
      <td width="26%" class="thinborder"><strong>DESCRIPTION</strong></td>
      <td width="12%" class="thinborder"><strong>AMOUNT </strong></td>
      <td width="15%" class="thinborder"><strong>OR NUMBER</strong></td>
      <td width="11%" class="thinborder"><strong><font size="1">TELLER</font></strong></td>
<%if(!bolIsSearchInternal) {%>
      <td width="11%" class="thinborder"><strong><font size="1">MOVE PMT TO ID</font></strong></td>
<%}%>	  
    </tr>
    <% double dTotal = 0d; double dCurrentAmount = 0d;
		for (int i= 0; i < vRetResult.size() ; i+=10) {
		dCurrentAmount = Double.parseDouble((String)vRetResult.elementAt(i+4));
		dTotal +=dCurrentAmount;
	%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td  class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
<%if(bolIsSearchInternal){%>
      <td  class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 8),"&nbsp;")%></td>
      <td  class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%></td>
<%}%>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2) + WI.getStrValue((String)vRetResult.elementAt(i+3),"(",")","")%></td>
      <td class="thinborder" align="right"> <%=CommonUtil.formatFloat(dCurrentAmount,true)%></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+5)%></div></td>
      <td class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+6)%>&nbsp;</div></td>
<%if(!bolIsSearchInternal) {%>
      <td class="thinborder" align="center"><a href="javascript:MovePmt(<%=(String)vRetResult.elementAt(i + 7)%>);">Move</a></td>
<%}%>
    </tr>
<%}%>
    <tr> 
      <td height="25" colspan="<%if(bolIsSearchInternal){%>6<%}else{%>4<%}%>"  class="thinborder" align="right">
	  <strong>Total Amount for this Page:&nbsp; <%=CommonUtil.formatFloat(dTotal,true)%></strong></td>
      <td colspan="3"  class="thinborder">&nbsp;</td>
<%if(!bolIsSearchInternal) {%>
      <td  class="thinborder">&nbsp;</td>
<%}%>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
   <% if (vRetResult!= null) {%>
    <tr> 
      <td height="20" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td align="right" >
	  Rows Per Page : 
	  <select name="rows_per_page">
  	<% for (int i = 20; i < 50; i++) {
			if (WI.fillTextValue("rows_per_page").equals(Integer.toString(i))) {
	%> 
			  <option value="<%=i%>" selected><%=i%> </option>	
		<%}else{%>
			  <option value="<%=i%>"><%=i%> </option>
	   <%}
	   }
	%> 
	  </select>
	   	 &nbsp;&nbsp;</td>
	 <td width="50%" valign="bottom">
	 
	  <a href="javascript:PrintPg();">&nbsp;&nbsp;<img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print Lists</font>
		  
		  <input type="checkbox" name="remove_header" value="checked" <%=WI.fillTextValue("remove_header")%>> Remove Header in Printing
		  
	  </td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
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