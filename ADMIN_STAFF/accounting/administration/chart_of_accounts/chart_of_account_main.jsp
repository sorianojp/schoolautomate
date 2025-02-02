<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
function AddCOA(strCOACF) {
	location = "./chart_of_account.jsp?coa_cf="+strCOACF;
}
function ConfirmDel(strInfoIndex) {
	if(confirm("Do you want to delete."))
		return this.PageAction('0',strInfoIndex);
}
</script>

<body bgcolor="#D2AE72">
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
								"Admin/staff-Accounting-Administration","chart_of_account_main.jsp");
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
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Administration adm = new Administration();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(adm.operateOnCOACF(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = adm.operateOnCOACF(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = adm.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = adm.operateOnCOACF(dbOP, request, 3);


boolean bolAFormatToggleAllowed = false;
int iAccountFormat = 0; int iAccountLen = 0;
java.sql.ResultSet rs = dbOP.executeQuery("select ACC_NO_FORMAT,LENGTH from AC_COA_AC_LEN");
rs.next();
iAccountFormat = rs.getInt(1);
iAccountLen    = rs.getInt(2);
rs.close();

if(dbOP.getResultOfAQuery("select COA_INDEX from AC_COA WHERE IS_VALID = 1", 0) == null)
	bolAFormatToggleAllowed = true;
if(WI.fillTextValue("toggle").length() > 0) {
	if(WI.fillTextValue("toggle").equals("1")) {///update account code length.
		if(dbOP.executeUpdateWithTrans("update AC_COA_AC_LEN set LENGTH = "+
			WI.fillTextValue("coa_len"), null, null, false) != -1)
			iAccountLen = Integer.parseInt(WI.fillTextValue("coa_len"));
	}
	else {
		if(iAccountFormat == 1)
			iAccountFormat = 0;
		else		
			iAccountFormat = 1;
		dbOP.executeUpdateWithTrans("update AC_COA_AC_LEN set ACC_NO_FORMAT = "+
			Integer.toString(iAccountFormat), null, null, false);
	}
}



%>
<form action="./chart_of_account_main.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr bgcolor="#A49A6A"> 
    <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        CHART OF ACCOUNTS : LIST OF ACCOUNT CLASSIFICATIONS PAGE ::::</strong></font></div></td>
  </tr>
  <tr > 
    <td width="3%" height="25">&nbsp;</td>
    <td width="97%" style="font-size:13px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
  </tr>
</table>


<table width="100%" border="0" align="center" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td>&nbsp;</td>
    <td>Chart of Account Length </td>
    <td colspan="5">
	<%if(bolAFormatToggleAllowed){//ALLOW TO EDIT.. %>
		<select name="coa_len">
		<option value="5">5 digit code</option>
<%
if(iAccountLen == 6)
	strTemp = " selected";
else	
	strTemp = "";
%>
		<option value="6"<%=strTemp%>>6 digit code</option>
<%
if(iAccountLen == 7)
	strTemp = " selected";
else	
	strTemp = "";
%>		<option value="7"<%=strTemp%>>7 digit code</option>
<%
if(iAccountLen == 8)
	strTemp = " selected";
else	
	strTemp = "";
%>		<option value="8"<%=strTemp%>>8 digit code</option>
<%
if(iAccountLen == 9)
	strTemp = " selected";
else	
	strTemp = "";
%>		<option value="9"<%=strTemp%>>9 digit code</option>
<%
if(iAccountLen == 10)
	strTemp = " selected";
else	
	strTemp = "";
%>		<option value="10"<%=strTemp%>>10 digit code</option>
<%
if(iAccountLen == 11)
	strTemp = " selected";
else	
	strTemp = "";
%>		<option value="11"<%=strTemp%>>11 digit code</option>
<%
if(iAccountLen == 12)
	strTemp = " selected";
else	
	strTemp = "";
%>		<option value="12"<%=strTemp%>>12 digit code</option>
	</select> &nbsp;&nbsp;&nbsp;
	<input type="submit" name="124" value=" Update Account Code Length " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.toggle.value='1';">
<%}//show only if no coa is created.
else {%>
	Account code is fixed to <%=iAccountLen%> digit code.

<%}%>	</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Chart of Account Format : </td>
    <td colspan="5">
	<%if(iAccountFormat == 0){%>
	Classification - Code : Example : <font color="#0000FF"><b>1-1000</b></font><%}else{%>
	Code : Example : <font color="#0000FF"><b>0001</b></font>
	<%}%> &nbsp;&nbsp;
<%if(bolAFormatToggleAllowed){%>
      <input type="submit" name="124" value=" Toggle " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.toggle.value='2';">
      <br>
      <font size="1"><b>NOTE : Must finalize account format before creating chart of account</b></font>
<%}else{%>
      <br>
      <font size="1"><b>NOTE : Account format is finalized.</b></font>
<%}%>	  </td>
    </tr>
  <tr>
    <td height="10" colspan="7"><hr size="1"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Classification : 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("cf_name");
%>     <input name="cf_name" type="text" size="24" maxlength="32" style="font-size:9px;" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    <td colspan="3">Classification Code : 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(0);
else	
	strTemp = WI.fillTextValue("coa_cf");
%>	<select name="coa_cf">
	<%int iCF = Integer.parseInt(WI.getStrValue(strTemp, "1") );
	for(int i =1; i < 10; ++i){
		if(iCF == i)
			strTemp = " selected";
		else	
			strTemp = "";
		%>
		<option value="<%=i%>"<%=strTemp%>><%=i%></option>
	<%}%>
	</select>	</td>
    <td colspan="2">
<%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
		<input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');"> &nbsp;&nbsp;&nbsp;&nbsp;
	<%}else{%>
		<input type="submit" name="12" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">&nbsp;&nbsp;&nbsp;&nbsp;
	<%}
}%>	  
		<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.cf_name.value=''">	</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td colspan="4">Account Type : 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("is_debit_type");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>
	<input name="is_debit_type" type="radio" value="1"<%=strTemp%>>Debit 
<%
if(strTemp.length() == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	<input name="is_debit_type" type="radio" value="0"<%=strTemp%>>Credit	</td>
    <td colspan="2" style="font-size:10px; font-weight:bold; color:#0000FF">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("is_balance_forwarded");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>
	<input type="checkbox" name="is_balance_forwarded" value="1" <%=strTemp%>>
	Is Yearly Balance Forwareded </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td colspan="6" style="font-size:10px; color:#0000FF; font-weight:bold">Blue Color ::: Account Balance is forwared to Next Year </td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <tr bgcolor="#B9B292"> 
    <td class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
    <td class="thinborderTOPBOTTOM"><strong>NAME</strong></td>
    <td colspan="3" class="thinborderTOPBOTTOM"><strong>STARTING CODE NUMBER</strong></td>
    <td class="thinborderTOPBOTTOM">&nbsp;</td>
    <td class="thinborderTOPBOTTOMRIGHT">&nbsp;</td>
  </tr>
<%String[] astrConvertIsDebit = {"<b>C</b>redit","<b>D</b>ebit"}; 
for (int i =0; i < vRetResult.size() ; i+=5){ %>
  <tr> 
    <td height="25" width="1%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="34%" class="thinborderBOTTOMRIGHT">
	<%if(vRetResult.elementAt(i + 4).equals("1")){%><font style="font-weight:bold; color:#0000FF"><%}%>
	<%=vRetResult.elementAt(i + 1)%>
	<%if(vRetResult.elementAt(i + 4).equals("1")){%></font><%}%>
	</td>
    <td width="8%" height="25" class="thinborderBOTTOMRIGHT"><%=vRetResult.elementAt(i)%></td>
    <td width="8%" class="thinborderBOTTOMRIGHT"><%=astrConvertIsDebit[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></td>
    <td width="14%" class="thinborderBOTTOMRIGHT">&nbsp;
        <%if(iAccessLevel > 1) {%>
        <input type="submit" name="122" value="Edit" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
        <%}%>    </td>
    <td height="25" width="14%" class="thinborderBOTTOMRIGHT">&nbsp;
      <%if(iAccessLevel ==2 && vRetResult.elementAt(i + 2).equals("0")) {%>
      <input type="submit" name="123" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="ConfirmDel('<%=vRetResult.elementAt(i)%>');">
      <%}%>    </td>
    <td width="21%" class="thinborderBOTTOMRIGHT"><a href="javascript:AddCOA('<%=vRetResult.elementAt(i)%>');"><img src="../../../../images/update.gif" border="0" ></a>	
	&nbsp;&nbsp;
	<a href="./chart_of_account_search_print.jsp?open_bal=1&print_pg=1&ac_coa_cf=<%=vRetResult.elementAt(i)%>"><img src="../../../../images/print.gif" border="0"></a>	</td>
  </tr>
  <%}//end of for loop.
}//end if vRetResult is not null.%>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="15%" height="25">&nbsp;</td>
    <td width="41%">&nbsp;</td>
    <td width="44%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">NOTE: </td>
    <td valign="middle"></tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td colspan="2" valign="middle"><input type="button" name="1222" value=" &nbsp; Edit &nbsp;" style="font-size:11px; height:23px;border: 1px solid #FF0000;">
      - click to edit the classification name and code number</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td colspan="2" valign="middle"> <input type="button" name="12222" value="Delete" style="font-size:11px; height:23px;border: 1px solid #FF0000;">
      - 
      click to delete the classification from the list</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td colspan="2" valign="middle"><img src="../../../../images/update.gif" >- 
      click to update the list of accounts under this classification</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A"> 
    <td height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="toggle">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>