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
					strTemp = WI.fillTextValue("coa_index");
				%>
        <select name="coa_index">
          <%=dbOP.loadCombo("COA_INDEX","COMPLETE_CODE, ACCOUNT_NAME"," from AC_COA where account_type > 0" +
											" and COA_CF = "+ WI.fillTextValue("is_main_index") + 
											" and not exists(select * from AC_SET_IS_COA where COA_INDEX = COA_INDEX_) " +
											" order by ACCOUNT_CODE_INT asc",strTemp, false)%>
        </select></td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;<input type="checkbox" name="add_all" value="1">Add all accounts to Income statement</td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="100%" colspan="2" align="center"><input type="submit" name="12" value="Save Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'"></td>
    </tr>
  </table>
	
<%if(vRetResult != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: LIST OF ACCOUNTS FOR INCOME STATEMENT:: </strong></font></div></td>
    </tr>
    <tr> 
      <td width="73%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><span class="thinborder" style="font-size:9px; font-weight:bold">ACCOUNT #</span></td>
      <td width="13%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">&nbsp;</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 3){%>
    <tr> 
			<%
				strTemp =(String)vRetResult.elementAt(i + 2);
				strTemp = WI.getStrValue(strTemp,"", "(" +(String)vRetResult.elementAt(i + 1) + ")","");
			%>				
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
      <td align="center" class="thinborder">
		<%if(iAccessLevel == 2){%>
			<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');">Remove</a>
		 <%}else{%>&nbsp;<%}%>	  </td>
    </tr>
<%}%>
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
  
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>