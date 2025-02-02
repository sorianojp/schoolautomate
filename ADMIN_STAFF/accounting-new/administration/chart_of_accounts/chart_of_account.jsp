<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../jscript/td.js"></script>
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
function ShowHideStatus() {
	if(document.form_.account_type.selectedIndex == 0) {
		hideLayer('status_');
		hideLayer('open_bal_');
	}
	else {	
		showLayer('status_');
		showLayer('open_bal_');
	}
}
function UpdateTaxCode() {
	var loadPg = "./tax_code.jsp";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AddSubType(strParentLevel, strParentLevelName) {
	document.form_.parent_level.value = strParentLevel;
	document.form_.parent_level_name.value = strParentLevelName;
}
</script>

<body bgcolor="#D2AE72" onLoad="ShowHideStatus();">
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
								"Admin/staff-Accounting-Administration","chart_of_account.jsp");
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
	if(adm.operateOnChartOfAccount(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = adm.operateOnChartOfAccount(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = adm.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = adm.operateOnChartOfAccount(dbOP, request, 3);

String strCOACFName = WI.fillTextValue("coa_cf");
if(strCOACFName.length() > 0) {
	 strCOACFName = dbOP.getResultOfAQuery("select CF_NAME from AC_COA_CF where COA_CF="+strCOACFName,0);
	if(strCOACFName == null) 
		strCOACFName = "";
}
Vector vHeaderAccount = new Vector();
strTemp = "select coa_index, COMPLETE_CODE from ac_coa where is_valid = 1 and ACCOUNT_TYPE = 0 and coa_cf = "+
			WI.fillTextValue("coa_cf")+" and coa_index <> "+WI.getStrValue(WI.fillTextValue("info_index"),"0")+
			" order by COMPLETE_CODE_INT";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);

while(rs.next()) {
	vHeaderAccount.addElement(rs.getString(1));//coa_index
	vHeaderAccount.addElement(rs.getString(2));//complete code. 
}
rs = dbOP.executeQuery("select ACC_NO_FORMAT,LENGTH from AC_COA_AC_LEN");
rs.next();
int iAccountFormat = rs.getInt(1);
int iAccountLen    = rs.getInt(2);
rs.close();
	

%>
<form action="./chart_of_account.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CHART OF ACCOUNTS - UPDATE LIST OF SUB-ACCOUNTS TYPE PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td width="98%" style="font-size:13px; color:#FF0000; font-weight:bold">
	  <a href="./chart_of_account_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a> &nbsp;&nbsp;
	  <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">Account Classification Name : <b><%=strCOACFName%></b></td>
      <td >Starting Code Number : <strong><%=WI.fillTextValue("coa_cf")%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
		  <table class="thinborderALL" cellpadding="0" cellspacing="0" bgcolor="#CCCCCC">
		  <tr><td>Creating Under Account : </td>
		  <td><select name="parent_level" style="color:#0000FF">
		  		<option value="">Under Main Account</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(14);
else	
	strTemp = WI.fillTextValue("parent_level");
if(strTemp == null)
	strTemp = "";
			  for(int i =0; i < vHeaderAccount.size() ; i += 2){
			  	if(strTemp.equals(vHeaderAccount.elementAt(i)))
					strErrMsg = " selected";
				else	
					strErrMsg = "";
				%><option value="<%=vHeaderAccount.elementAt(i)%>"<%=strErrMsg%>><%=vHeaderAccount.elementAt(i + 1)%></option>
			<%}%>  	
		  	</select>		  	</td>
		  </tr>
		  </table>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Account Name</td>
      <td height="25" colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("account_name");
%>	  <input name="account_name" type="text" size="80" maxlength="256" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td height="25">Account Type </td>
      <td width="38%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("account_type");
%>	  <select name="account_type" style="font-size:10px;" onChange="ShowHideStatus();">
        <option value="0">Header (Non-Postable)</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="1"<%=strErrMsg%>>Detail Account (Postable)</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="2"<%=strErrMsg%>>Detail Check Account (Postable)</option>
      </select></td>
      <td width="46%">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">Code Number </td>
      <td height="25">
	  <%if(iAccountFormat == 0) {%><%=WI.fillTextValue("coa_cf")%> - <%}%>
<%
if(vEditInfo != null && vEditInfo.size() > 0) {
	strTemp = (String)vEditInfo.elementAt(3);
	int iIndexOf = strTemp.indexOf("-");
	strTemp = strTemp.substring(iIndexOf+1);
}
else	
	strTemp = WI.fillTextValue("account_code");
%>        <input name="account_code" type="text" size="12" maxlength="<%=iAccountLen-1%>" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','account_code');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','account_code');"></td>
      <td height="25" id="status_">Status : 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("is_active");
%>        <select name="is_active">
          <option value="1">Active Account</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="0"<%=strErrMsg%>>In-active Account</option>
        </select></td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr id="open_bal_"> 
      <td>&nbsp;</td>
      <td>Opening Bal. </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("opening_bal");
%>	  <input name="opening_bal" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','opening_bal');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','opening_bal');"></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Tax Code </td>
      <td colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("tax_code");
%>	  <select name="tax_code" style="font-size:11px; color:#0000FF">
<%=dbOP.loadCombo("TAX_CODE_INDEX","TAX_CODE +' ::: '+DESCRIPTION,tax_rate",
			" from AC_COA_TAXCODE order by TAX_CODE asc",strTemp, false)%>
      </select> 
<strong><a href="javascript:UpdateTaxCode();"><img src="../../../../images/update.gif" border="0" ></a>        </strong><font size="1">Update  Tax Code</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td colspan="2">
	  <%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="button" name="Submit" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');document.form_.Submit.disabled=true;document.form_.submit();">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="button" name="EditInfo" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');document.form_.EditInfo.disabled=true;document.form_.submit();">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="button" name="Cancel" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.Cancel.disabled=true;PageAction('','');document.form_.account_name.value='';document.form_.account_code.value='';document.form_.opening_bal.value='';document.form_.submit();"></td>
    </tr>
  </table>
 <% if (vRetResult !=null){ %>  
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td colspan="5" bgcolor="#666666" height="25" class="thinborder"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF ACCOUNT TYPE UNDER </font></strong><font color="#FFFF00"><strong><%=strCOACFName%></strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><font size="1"><strong>ACCOUNT # </strong>&nbsp;</font></div></td>
      <td class="thinborder" align="center"><font size="1"><strong> NAME</strong></font></td>
      <td width="30%" class="thinborder" align="center"><font size="1"><strong>TYPE </strong></font></td>
      <td width="16%" class="thinborder" align="center"><font size="1"><strong>BALANCE</strong></font></td>
      <td width="21%" class="thinborder" align="center"><font size="1"><strong>MODIFY</strong></font></td>
    </tr>
    <tr style="color:#0000FF; font-weight:bold;"> 
      <td width="14%" height="25" class="thinborder"><%=WI.fillTextValue("coa_cf")%>-0000</td>
      <td width="19%" class="thinborder"><strong><%=strCOACFName%></strong></td>
      <td class="thinborder">Header (Non-Postable)</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="center">Not Applicable</td>
    </tr>
    <%int iHeaderLevel = 1; 
	String strIndent = null;
	String[] astrConvertAccountType ={"Header (Non-Postable)", "Detail Account", "Detail Check Account"};
	String strRowStyle = null;//if header type, i have to put it in blue color.. 
	for (int i =0; i < vRetResult.size() ; i+=15){ 
	if(vRetResult.elementAt(i + 7).equals("0"))
		strRowStyle = " style='color:#0000FF;'";
	else	
		strRowStyle = "";
	//find indentation.. 
	iHeaderLevel = Integer.parseInt((String)vRetResult.elementAt(i + 12));
	strIndent = "";
	for(int p = 0; p < iHeaderLevel; ++p)
		strIndent = "-"+strIndent;
	strIndent = strIndent + ">";	
	%>
    <tr<%=strRowStyle%>> 
      <td width="14%" height="25" class="thinborder">&nbsp;<%=strIndent%> <%=vRetResult.elementAt(i + 5)%></td>
      <td width="19%" class="thinborder"><%=strIndent%> <%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=astrConvertAccountType[Integer.parseInt((String)vRetResult.elementAt(i + 7))]%></td>
      <td class="thinborder">
	  <%if(vRetResult.elementAt(i + 11) != null) {%>
		  <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 11),true)%>
	  <%}else{%>&nbsp;<%}%>
	  </td>
      <td class="thinborder">
	  <input type="button" name="Edit<%=i%>" value="Edit" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.Edit<%=i%>.disabled=true;PreparedToEdit('<%=vRetResult.elementAt(i)%>');document.form_.submit();">&nbsp;
      <input type="button" name="Delete<%=i%>" value="Delete" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.Delete<%=i%>.disabled=true;PageAction('0','<%=vRetResult.elementAt(i)%>');document.form_.submit();">&nbsp;
<%if(false && strRowStyle.length() > 0) {%>
      <input type="button" name="AddSub<%=i%>" value="Add Sub" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.AddSub<%=i%>.disabled=true;AddSubType('<%=vRetResult.elementAt(i)%>','<%=vRetResult.elementAt(i + 5)%>');document.form_.submit();">
<%}%>
	  </td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="coa_cf" value="<%=WI.fillTextValue("coa_cf")%>">

<!--
<input type="hidden" name="parent_level" value="<%=WI.fillTextValue("parent_level")%>">
-->

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>