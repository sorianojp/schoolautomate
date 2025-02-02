<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}

</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.Transaction,java.util.Vector" %>
<%
 
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-SET SCHOOL YEAR & TERM","sy.jsp");
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
														"Admission Maintenance","SET SCHOOL YEAR & TERM",request.getRemoteAddr(), 
														"sy.jsp");	
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

	Transaction PTCash = new Transaction();
	Vector vRetResult = null;		
	String strPageAction = WI.fillTextValue("page_action");
	String strTemp = null;
		
	if(strPageAction.length() > 0){
	  if(PTCash.operateOnMinMaxPettyCash(dbOP,request,Integer.parseInt(strPageAction)) == null)
		strErrMsg = PTCash.getErrMsg();	
	}
	vRetResult = PTCash.operateOnMinMaxPettyCash(dbOP,request,4);
		
if(strErrMsg == null) strErrMsg = "";
%>
	

<form name="form_" method="post" action="petty_cash_setup_amount.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="131%" height="27" colspan="8"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SET MAXIMUM/MINIMUM PETTY CASH FUND AMOUNT PAGE ::::</strong></font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3" style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp; 
        <a href="petty_cash.jsp"><img src="../../../../images/go_back.gif" border="0"></a> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Current Minimum Amount in Record</td>
      <td>New Minimum Amount (Php)</td>
    </tr>
    <tr> 
      <td width="8%">&nbsp;</td>
      <%
	  	if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(0);
	  %>
      <td width="34%"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%></td>
      <td> <strong><font size="1"> 
        <input name="min_amount" type="text" size="12" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("min_amount")%>"
	  onKeyUp="AllowOnlyFloat('form_','min_amount');"	 
	  onBlur="AllowOnlyFloat('form_','min_amount');style.backgroundColor='white'">
        </font></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Current Maximum Amount in Record</td>
      <td width="58%">New Maximum Amount (Php)</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <%
	  	if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(1);
	  %>
      <td><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%></td>
      <td width="58%"> <strong><font size="1"> 
        <input name="max_amount" type="text" size="12" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("max_amount")%>"
	  onKeyUp="AllowOnlyFloat('form_','max_amount');"	 
	  onBlur="AllowOnlyFloat('form_','max_amount');style.backgroundColor='white'">
        </font></strong></td>
    </tr>
    <%
	if(iAccessLevel ==2){%>
    <tr>
      <td>&nbsp;</td>
	  <%
	  	if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(4);
	  %>
      <td>Current Balance: <%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><strong>Alarm Setting :</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <%
	  if(vRetResult != null && vRetResult.size() > 0){
		  if(((String)vRetResult.elementAt(3)).equals("1"))
			strTemp = "checked";
		  else
		  	strTemp = "";
	  }else{
	  	strTemp = "checked";
	  }	
	  %>
      <td colspan="2"> <input type="checkbox" name="inc_unclaimed" value="1" <%=strTemp%>>
        Include voucher(s) unclaimed by payee from petty cash amount released 
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2"><strong>Warn if amount goes below : - </strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>Current Setting </td>
      <td>New Setting </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <%
	  if(vRetResult != null && vRetResult.size() > 0)
		strTemp = (String)vRetResult.elementAt(2);
	  else
	  	strTemp = "";
	  %>
      <td><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%></td>
      <td> <strong><font size="1"> 
        <input name="warn_amount" type="text" size="12" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("warn_amount")%>"
	  onKeyUp="AllowOnlyFloat('form_','warn_amount');"	 
	  onBlur="AllowOnlyFloat('form_','warn_amount');style.backgroundColor='white'">
        </font></strong> </td>
    </tr>
    <%
	  if(vRetResult == null || vRetResult.size() == 0){
	  %>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>Starting Balance</td>
      <td><strong><font size="1"> 
        <input name="start_bal" type="text" size="12" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("start_bal")%>"
	  onKeyUp="AllowOnlyFloat('form_','start_bal');"	 
	  onBlur="AllowOnlyFloat('form_','start_bal');style.backgroundColor='white'">
        </font></strong></td>
    </tr>
    <%}// end if(vRetResult == null || vRetResult.size() == 0) %>
    <%}%>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href='javascript:PageAction(1);'><img src="../../../../images/edit.gif" border="0"></a> 
        <font size="1">click to edit current petty cash min./max. amount in record</font></td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
	
  
  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>


<!-- all hidden fields go here -->
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>