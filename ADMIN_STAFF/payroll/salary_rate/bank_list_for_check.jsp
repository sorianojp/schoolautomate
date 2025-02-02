<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector, 
				payroll.PRSalaryRate" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Bank list for check</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrepareToEdit(strInfoIndex)
{
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = 1;
	document.form_.info_index.value = strInfoIndex;
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.page_action.value = strPageAction;
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
}
function CancelRecord(){
	location = "./bank_list_for_check.jsp";
}

</script>

<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;

	String strPrepareToEdit=WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-bank list for checks.","bank_list_for_check.jsp");
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
														"PAYROLL","SALARY RATE",request.getRemoteAddr(),
														"bank_list_for_check.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

FAPmtMaintenance FA = new FAPmtMaintenance();
PRSalaryRate prSalRate = new PRSalaryRate();

boolean bolProceed = true;

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp != null && strTemp.length() > 0) {
	if(bolIsSchool){
		if(FA.operateOnBankList(dbOP, request, Integer.parseInt(strTemp)) != null) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation Successful.";
		}
		else	
			strErrMsg = FA.getErrMsg();		
	}else{
		if(prSalRate.operateOnBankList(dbOP, request, Integer.parseInt(strTemp)) != null) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation Successful.";
		}
		else	
			strErrMsg = prSalRate.getErrMsg();
	}
		
}

//get all levels created.
Vector vRetResult = null;
Vector vEditInfo = null;

if(strPrepareToEdit.compareTo("1") == 0) {
	if(bolIsSchool){
		vEditInfo = FA.operateOnBankList(dbOP, request, 3);
		if(vEditInfo == null) 
			strErrMsg = FA.getErrMsg();
	}else{
		vEditInfo = prSalRate.operateOnBankList(dbOP, request, 3);
		if(vEditInfo == null) 
			strErrMsg = prSalRate.getErrMsg();		
	}
		
}
if(bolIsSchool)
	vRetResult = FA.operateOnBankList(dbOP, request, 4);
else
	vRetResult = prSalRate.operateOnBankList(dbOP, request, 4);
%>
<form name="form_" action="./bank_list_for_check.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" align="center"><font color="#FFFFFF"><strong>:::: BANK LIST ::::</strong></font></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td width="0%" height="25">&nbsp;</td>
      <td width="7%">Code</td>
      <td colspan="2"> <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("bank_code");
	if(strTemp == null) strTemp = "";
	%> <input name="bank_code" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2">Name</td>
      <td width="50%"> <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("bank_name");
	if(strTemp == null) strTemp = "";
	%> <input name="bank_name" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="32" rowspan="2">&nbsp;</td>
      <td rowspan="2" valign="top">Address</font></td>
      <td colspan="2" rowspan="2" valign="top"> <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = request.getParameter("address");
	if(strTemp == null) strTemp = "";
	%> <textarea name="address" cols="28" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea> </font> 
      </td>
      <td height="27" colspan="2"><div align="left">Branch</font></div></td>
      <td valign="top"> <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("branch");
	if(strTemp == null) strTemp = "";
	%> <input name="branch" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td colspan="3" valign="bottom"> <%
 if(iAccessLevel > 1){
if(strPrepareToEdit.compareTo("0") == 0){%> 
      <input type="submit" name="1" value="Save Info" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('',1);">
      <%}		
else{%> 
      <input type="submit" name="1" value="Edit Info" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('',2);">
&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel or go previous</font> 
<%}
}//if iAccessLevel > 1%></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="2" valign="top">&nbsp;</td>
      <td colspan="3" valign="bottom">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#97ABC1"> 
      <td height="25" colspan="6" class="thinborder" align="center"><strong>LIST 
        OF AFFILIATED BANKS</strong></td>
    </tr>
    <tr> 
      <td width="8%" height="25" class="thinborder"><div align="center"><font size="1"><strong>CODE</strong></font></div></td>
      <td width="21%" class="thinborder"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>BRANCH</strong></font></div></td>
      <td width="22%" align="center" class="thinborder"><font size="1"><strong>ADDRESS</strong></font></td>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>EDIT</strong></font></td>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%for(int i = 0 ; i< vRetResult.size() ; i += 6) {%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td align="center" class="thinborder"> <%if(iAccessLevel > 1){%> 
      <input type="submit" name="1" value="Edit Info" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick='PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'>
        <%}else{%>
        Not authorized 
        <%}%></td>
      <td align="center" class="thinborder"> <%if(iAccessLevel ==2){%> 
      <input type="submit" name="1" value="Delete" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick='PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'>
        <%}else{%>
        Not authorized 
        <%}%></td>
    </tr>
    <%}//end of for loop.%>
  </table>
<%}//show only list of banks found.";%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>