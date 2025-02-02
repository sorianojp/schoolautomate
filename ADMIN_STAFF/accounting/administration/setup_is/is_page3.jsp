<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction,strIndex){
	if(strAction == 0){
		if(!confirm('Are you sure you want to remove this information.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strIndex;
	document.form_.submit();
}
function DeleteAll() {
	if(!confirm('Are you sure you want to remove this information.'))
		return;
	document.form_.del_button.disabled= true;
	document.form_.page_action.value = '0';
	document.form_.submit();
}
function SelAll() {
	var iMaxDisp = document.form_.max_disp.value;
	var bolIsChecked = document.form_.sel_all.checked;
	
	for(var i = 0; i < iMaxDisp; ++i) {
		if(bolIsChecked)
			eval('document.form_.chkbox_'+i+'.checked=true');
		else	
			eval('document.form_.chkbox_'+i+'.checked=false');
	}
}
</script>
<%@ page language="java" import="utility.*,Accounting.IncomeStatement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-IncomeStatement-Set up balance sheet-Page2","is_page3.jsp");
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
														"Accounting","IncomeStatement",request.getRemoteAddr(), 
														"is_page3.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
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
	
	IncomeStatement incomeState = new IncomeStatement();	
	Vector vRetResult        = null;
  	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(incomeState.operateOnISSetupCOA(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = incomeState.getErrMsg();
		else {
			strErrMsg = "Income Statement set up information updated successfully.";	
		}
	}
	vRetResult = incomeState.operateOnISSetupCOA(dbOP, request, 4);


String strCF = null;
if(WI.fillTextValue("is_main_index").length() > 0) 
	strCF = dbOP.getResultOfAQuery("select COA_CF_REF from AC_SET_IS_MAIN where IS_MAIN_INDEX="+WI.fillTextValue("is_main_index"),0);

String strISTitle = "select is_title_index from AC_SET_IS_MAIN where is_main_index = "+WI.fillTextValue("is_main_index");
strISTitle = dbOP.getResultOfAQuery(strISTitle, 0);
%>
<form name="form_" method="post" action="is_page3.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td height="25" align="center" style="font-weight:bold; color:#FFFFFF">:::: SETUP FOR INCOME STATEMENT - ENTRIES PAGE ::::</td>
    </tr>
  </table>	 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="98%" colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>    
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td colspan="2">Chart of account Reference :
<%
String strCoaHeaderAccount = "select coa_header from ac_set_is_sub where is_sub_index = "+WI.fillTextValue("sub_index");
strCoaHeaderAccount = dbOP.getResultOfAQuery(strCoaHeaderAccount, 0);
strCoaHeaderAccount = "select complete_code from ac_coa where coa_index = "+strCoaHeaderAccount;
strCoaHeaderAccount = dbOP.getResultOfAQuery(strCoaHeaderAccount, 0);
while(strCoaHeaderAccount.endsWith("0"))
	strCoaHeaderAccount = strCoaHeaderAccount.substring(0, strCoaHeaderAccount.length() - 1);
strCoaHeaderAccount = " and complete_code like '"+strCoaHeaderAccount+"%'";

	strTemp = WI.fillTextValue("coa_index");
	strErrMsg = " (select * from AC_SET_IS_COA "+
          "join AC_SET_IS_SUB on (AC_SET_IS_SUB.is_sub_index = AC_SET_IS_COA.is_sub_index) "+
          "join AC_SET_IS_MAIN on (AC_SET_IS_MAIN.is_main_index = AC_SET_IS_SUB.is_main_index) "+
          "where is_title_index = "+strISTitle+" and COA_INDEX = COA_INDEX_)";



String strCoaIndexAll = "select coa_index from ac_coa where  account_type > 0 and COA_CF = "+ strCF +
						" and IS_ACTIVE = 1 and is_valid = 1 and not exists " +strErrMsg+strCoaHeaderAccount;

java.sql.ResultSet rs = dbOP.executeQuery(strCoaIndexAll);
strCoaIndexAll = null;
while(rs.next()) {
	if(strCoaIndexAll == null)
		strCoaIndexAll = rs.getString(1);
	else
		strCoaIndexAll = strCoaIndexAll + ", "+rs.getString(1);
}
rs.close();
%>
        <select name="coa_index" style="font-size:11px; width:415">
          <%=dbOP.loadCombo("COA_INDEX","COMPLETE_CODE, ACCOUNT_NAME"," from AC_COA where account_type > 0 and COA_CF = "+ strCF + 
			" and IS_ACTIVE = 1 and is_valid = 1 and not exists " +strErrMsg+strCoaHeaderAccount+" order by ACCOUNT_CODE_INT asc",strTemp, false)%>
        </select></td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;<input type="checkbox" name="add_all" value="1">Add all accounts to Income statement</td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="100%" colspan="2" align="center">
	  	<input type="submit" name="12" value="Save Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">	  </td>
    </tr>
  </table>
	
<%if(vRetResult != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: LIST OF ACCOUNTS FOR INCOME STATEMENT:: </strong></font></div></td>
    </tr>
    <tr> 
      <td width="73%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><span class="thinborder" style="font-size:9px; font-weight:bold">ACCOUNT #</span></td>
      <td width="13%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">SELECT<br>
	  <input type="checkbox" name="sel_all" onClick="SelAll()"></td>
    </tr>
<%int j = 0;
for(int i = 0; i < vRetResult.size(); i += 3, ++j){%>
    <tr> 
<%
	strTemp =(String)vRetResult.elementAt(i + 2);
	strTemp = WI.getStrValue(strTemp,"", "(" +(String)vRetResult.elementAt(i + 1) + ")","");
%>				
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
      <td align="center" class="thinborder"><input type="checkbox" name="chkbox_<%=j%>" value="<%=vRetResult.elementAt(i)%>">
		<%//if(iAccessLevel == 2){%>
			<!--<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');">Remove</a>-->
		 <%//}else{%><%//}%>	  </td>
    </tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=j%>">
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr> 
      <td height="25" align="center">
<%if(iAccessLevel == 2){%>
	  	<input type="button" name="del_button" value="Delete Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="DeleteAll();">
<%}else{%>Not having previledge to delete.<%}%>	  </td>
    </tr>
  </table>
<%}%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    
    <tr>
      <td height="27" bgcolor="#B5AB73">&nbsp;</td>
    </tr>
  </table>


  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
  
  <!-- page information -->
	<input type="hidden" name="sub_index" value="<%=WI.fillTextValue("sub_index")%>">
  <input type="hidden" name="is_main_index" value="<%=WI.fillTextValue("is_main_index")%>">
  
  <input type="hidden" name="coa_index_all" value="<%=strCoaIndexAll%>">
  
  
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>