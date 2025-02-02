<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","close_coa.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult  = null;	
Administration adm = new Administration();
if(WI.fillTextValue("coa_cf").length() > 0) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		adm.closeAccount(dbOP, request, Integer.parseInt(strTemp));
		strErrMsg = adm.getErrMsg();
	}
	vRetResult = adm.closeAccount(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = adm.getErrMsg();
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../../jscript/formatFloat.js"></script>
<script language="javascript">
function MapCOAAjax(strIsBlur) {
		var objCOA;
		objCOA=document.getElementById("coa_info");
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			document.form_.coa_index.value+"&coa_field_name=coa_index&is_blur="+strIsBlur;
		this.processRequest(strURL);
}
function COASelected(strAccountName) {
	document.getElementById("coa_info").innerHTML = strAccountName;
	
	document.form_.page_action.value = '';
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";

	document.form_.year_.value = document.form_.close_yr[document.form_.close_yr.selectedIndex].value - 1;
	
	document.form_.submit();
}
function UpdateTotalBal(dMonthBal, objPrevBal, strUpdateBal) {
	var strPrevBal = objPrevBal.value;

	if(isNaN(strPrevBal))
		document.getElementById(strUpdateBal).innerHTML = this.formatFloat(dMonthBal, 2, true);
	else {
		var strBalance = eval(dMonthBal) + eval(strPrevBal);
		strBalance = this.formatFloat(strBalance, 2, true);
		document.getElementById(strUpdateBal).innerHTML = strBalance;
	}

}
function SelALL() {
	var iMaxDisp = document.form_.max_disp.value;
	if(iMaxDisp == '')
		return;
	var bolIsChecked = document.form_.sel_all.checked;
	
	for(var i = 0; i < eval(iMaxDisp); ++i) {
		if(bolIsChecked)
			eval('document.form_.checkbox_'+i+'.checked = true');
		else	
			eval('document.form_.checkbox_'+i+'.checked = false');			
	}
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./close_coa_ALL_pm.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" style="font-weight:bold; color:#FFFFFF">:::: Month/Year end closing of account ::::</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; font-weight:bold; color:#FF0000">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="19%">Select YR/Month</td>
      <td width="77%">
	  	<select name="close_yr">
<%=dbOP.loadComboYear(WI.fillTextValue("close_yr"),2,0)%>	  	
		</select> 
	  	- 
	  	<select name="close_mm">
<%
java.sql.ResultSet rs = null;
String strSQLQuery    = null;
%>          <%=dbOP.loadComboMonth(WI.fillTextValue("close_mm"))%>
        </select></td>
    </tr>
    
    <tr> 
      <td height="26">&nbsp;</td>
      <td>COA CF </td>
      <td style="font-size:9px;">
		<select name="coa_cf">
<%
strSQLQuery = "select COA_CF,CF_NAME from AC_COA_CF order by COA_CF";
strTemp = WI.fillTextValue("coa_cf");
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	if(rs.getString(1).equals(strTemp))
		strErrMsg = " selected";
	else	
		strErrMsg = "";
	%><option value="<%=rs.getString(1)%>" <%=strErrMsg%>><%=rs.getString(2)%></option>
<%}%>		
		</select>	  
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:ReloadPage();"><img src="../../../../../images/refresh.gif" border="0"></a> Click to load the page.
	  </td>
    </tr>
	<tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td style="font-size:9px;"></td>
	</tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="22" class="thinborder" colspan="7"><font color="#0000FF" style="font-weight:bold">Note :</font> <br>White backgroud &nbsp;: <b>Chart of account not closed.</b><br>
	  <font color="#CCCCCC">Grey Background :</font> <b>Chart of account alerady closed.</b><br>
	  <font color="#FF0000">Red background  &nbsp;&nbsp;:</font> <b>Next month is alerady closed</b><br>
	  <font color="#0000FF">Blue background &nbsp;:</font> <b>Actual Monthly balance in system and monthly balance recorded when account was closed : does not match</b><br>	  </td>
    </tr>
    <tr bgcolor="#88DDDD" align="center" style="font-weight:bold"> 
      <td height="22" class="thinborder" width="25%">Account Name </td>
      <td class="thinborder" width="10%">Account Code </td>
      <td class="thinborder" width="15%">Monthly Balance </td>
      <td class="thinborder" width="15%">Previous Month Balance </td>
      <td class="thinborder" width="13%">Total balance </td>
      <td class="thinborder" width="15%">Remarks</td>
      <td class="thinborder" width="7%">Select<br>
	  <input type="checkbox" name="sel_all" onClick="SelALL()"></td>
    </tr>
<% 
int j = 0; String strMonthBal = null; String strPrevMonthBal = null; String strRemarks = null; double dTotalBal = 0d;
String strBGColor = null;

double dIncomeStatementAmt = 0d;
Vector vTempIS = null;
Accounting.IncomeStatement IS = new Accounting.IncomeStatement();
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
//add only fiscal year income statement.
if(WI.fillTextValue("coa_cf").equals("2") && strSchCode.startsWith("CLDH") && WI.fillTextValue("close_mm").equals("4")) {
	vTempIS = IS.getIncomeStatementMonthlyYearly(dbOP, request);
	if(vTempIS != null && vTempIS.size() > 0) 
		dIncomeStatementAmt = Double.parseDouble(ConversionTable.replaceString((String)vTempIS.remove(0), ",", ""));
//System.out.println(vTempIS);
//System.out.println(IS.getErrMsg());
}

for(int i = 0; i < vRetResult.size(); i += 14, ++j){

strRemarks = "";strBGColor = "";
if(vRetResult.elementAt(i + 5) == null)
	strRemarks = "Not Closed";
else {
	strBGColor = " bgcolor='#CCCCCC'";
	if(vRetResult.elementAt(i + 11).equals("0"))
		strRemarks = "Month next to selected month is closed already.";
	if(vRetResult.elementAt(i + 12).equals("1") && !((String)vRetResult.elementAt(i + 2)).equals("2-6220"))
		strRemarks = "Monthly balance recorded does not match with monthly balance when it was closed.";
	if(vRetResult.elementAt(i + 13).equals("1") && !((String)vRetResult.elementAt(i + 2)).equals("2-6220"))
		strRemarks = "Last month balance does not match with last month balance when it was closed";
}

if(vRetResult.elementAt(i + 6) == null)
	strMonthBal = (String)vRetResult.elementAt(i + 3);
else	
	strMonthBal = (String)vRetResult.elementAt(i + 6);
if(strMonthBal == null)
	strMonthBal = "0.00";	
	
if(dIncomeStatementAmt != 0d && ((String)vRetResult.elementAt(i + 2)).equals("2-6220") && strBGColor.length() == 0) {
	strMonthBal = CommonUtil.formatFloat(dIncomeStatementAmt + Double.parseDouble(ConversionTable.replaceString(strMonthBal,",","")), true);
}

if(vRetResult.elementAt(i + 7) == null)
	strPrevMonthBal = (String)vRetResult.elementAt(i + 4);
else	
	strPrevMonthBal = (String)vRetResult.elementAt(i + 7);
if(strPrevMonthBal == null)
	strPrevMonthBal = "0.00";	
else	
	strPrevMonthBal = ConversionTable.replaceString(strPrevMonthBal,",","");
	
dTotalBal = Double.parseDouble(ConversionTable.replaceString(strMonthBal,",","")) + 
			Double.parseDouble(ConversionTable.replaceString(strPrevMonthBal,",",""));
dTotalBal = Double.parseDouble(ConversionTable.replaceString(CommonUtil.formatFloat(dTotalBal,true),",",""));
//System.out.println(" strMonthBal : "+strMonthBal+" :: strPrevMonthBal : "+strPrevMonthBal+" ::: dTotalBal : "+dTotalBal);

%>
    <tr<%=WI.getStrValue(strBGColor)%>>
      <td height="25" class="thinborder"><%=j + 1%>. <%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" align="right"><%=strMonthBal%> &nbsp;
	  <%if(dIncomeStatementAmt != 0d && ((String)vRetResult.elementAt(i + 2)).equals("2-6220") && strBGColor.length() == 0) {%>
	  <font color="#0000FF">Added Net Income : <%=CommonUtil.formatFloat(dIncomeStatementAmt, true)%></font>
	  <%}%>
	  <input type="hidden" name="month_bal_<%=j%>" value="<%=strMonthBal%>">
	  </td>
      <td class="thinborder" align="right"><input type="text" name="prev_month_<%=j%>" value="<%=strPrevMonthBal%>" 
	  onKeyUp="UpdateTotalBal('<%=ConversionTable.replaceString(strMonthBal,",","")%>',document.form_.prev_month_<%=j%>, '_<%=j%>');" 
	  style="font-size:10px; text-align:right" size="12" onBlur="AllowOnlyFloat('form_','prev_month_<%=j%>');"> &nbsp;</td>
      <td class="thinborder" align="right"><label id="_<%=j%>"><%=CommonUtil.formatFloat(dTotalBal,true)%></label></td>
      <td class="thinborder" style="font-size:9px;"><%=strRemarks%> &nbsp;</td>
      <td class="thinborder" align="center"><input type="checkbox" name="checkbox_<%=j%>" value="<%=vRetResult.elementAt(i)%>">
	  <input type="hidden" name="close_index_<%=j%>" value="<%=WI.getStrValue(vRetResult.elementAt(i + 5))%>">
	  
	  </td>
    </tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=j%>">
    <tr>
      <td height="22" class="thinborder" colspan="7" align="center"><br>
	  <input type="submit" name="1" value="Close Selected Accounts" style="font-size:11px; height:26px;border: 1px solid #FF0000;"
	   onClick="document.form_.page_action.value='1'"> &nbsp;&nbsp;&nbsp;
	   
	   <input type="submit" name="1" value="Open Selected Accounts" style="font-size:11px; height:26px;border: 1px solid #FF0000;"
	   onClick="document.form_.page_action.value='0'">
	  </td>
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
<input type="hidden" name="page_action">

<!-- added for income statement computation -->
<input type="hidden" name="fiscal_yr" value="1">
<input type="hidden" name="year_" value="<%=WI.fillTextValue("year_")%>">
<input type="hidden" name="title_index" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>