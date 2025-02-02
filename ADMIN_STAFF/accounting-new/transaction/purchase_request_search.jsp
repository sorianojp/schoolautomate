<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language='JavaScript'>
function ReloadPage()
{
	document.p_request.submit();
}
function PageAction(strAction)
{
	document.p_request.page_action.value = strAction;
}
function Cancel()
{
	location = "./purchase_request_search.jsp";
}
function ChangePage()
{
	location = "./purchase_request.jsp?page_operation=0";
}
function PrepareToEdit(strInfoIndex)
{
	document.p_request.page_action.value ="";
	document.p_request.prepareToEdit.value = 1;
	document.p_request.info_index.value = strInfoIndex;
	document.p_request.submit();
}
function DeleteRecord(strInfoIndex)
{
	document.p_request.page_action.value="0";
	document.p_request.info_index.value=strInfoIndex;
	document.p_request.submit();
}

</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.PurchaseRequest,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-TRANSACTION","PR.jsp");
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
														"Accounting","TRANSACTION",request.getRemoteAddr(),
														"PR.jsp");
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
Vector vReqInfo   = null;
Vector vReqDetail = null;
Vector vEditInfo  = null;

int iAction = 0;

PurchaseRequest PR = new PurchaseRequest();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	iAction = Integer.parseInt(strTemp);
	if(PR.OperateOnPRequestDtl( dbOP, request,iAction, null) == null)
	{
		strErrMsg = PR.getErrMsg();
	}

	if(strErrMsg == null)
		strErrMsg = "Operation successful.";
}

//It is time to view all
if(WI.fillTextValue("req_no").length() > 0)
{
	vReqInfo = PR.OperateOnPRequestType(dbOP,request,null,3,WI.fillTextValue("req_no"));
}
if(vReqInfo != null && vReqInfo.size() > 0)
{
	vReqDetail = PR.OperateOnPRequestDtl(dbOP,request,4, (String) vReqInfo.elementAt(0));
	if(vReqDetail == null)
		strErrMsg = PR.getErrMsg();
}

if(strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = PR.OperateOnPRequestDtl(dbOP,request,3, (String) vReqInfo.elementAt(0));
	if(vEditInfo == null || vEditInfo.size() ==0)
		strErrMsg = PR.getErrMsg();
}

%>
<form name="p_request" method="post" action="./purchase_request_search.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          PURCHASE REQUEST PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="14%">Operation </td>
      <td width="83%"><select name="page_operation" onChange="ChangePage();">
          <option value="0">Add </option>
          <%
if(WI.fillTextValue("page_operation").compareTo("1") ==0){%>
          <option value="1" selected>Search/Edit/Delete</option>
          <%}else{%>
          <option value="1">Search/Edit/Delete</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="23%">Date Range</td>
      <td colspan="2">From
        <input name="textfield" type="text" size="10"> <font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/calendar_new.gif" border="0"></a></font>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To
        <input name="textfield9" type="text" size="10"> <a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/calendar_new.gif" border="0"></a>
        <font size="1">&nbsp; </font></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td width="23%">Purchase Requisition No.</td>
      <td colspan="2"><select name="select7">
          <option>Equal to</option>
          <option>Starts with</option>
          <option>Ends with</option>
          <option>Contains</option>
        </select> <input name="textfield8" type="text" size="12"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requested by</td>
      <td colspan="2"><select name="select5">
          <option>Equal to</option>
          <option>Starts with</option>
          <option>Ends with</option>
          <option>Contains</option>
        </select> <input name="textfield82" type="text" size="48"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>College</td>
      <td colspan="2"><select name="select2">
          <option>N/A</option>
        </select> </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Department</td>
      <td colspan="2"><select name="select8">
        </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Office</td>
      <td colspan="2"><select name="select4">
        </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Purpose/Job</td>
      <td colspan="2"><select name="select9">
          <option>Equal to</option>
          <option>Starts with</option>
          <option>Ends with</option>
          <option>Contains</option>
        </select> <input name="textfield10" type="text" size="32"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Request Type</td>
      <td colspan="2"><select name="select12">
          <option>New</option>
          <option>Replacement</option>
        </select></td>
    </tr>
    <tr>
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="39%" height="25">Sort by</td>
      <td width="58%" height="25"><font size="1">&nbsp; </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><select name="select6">
          <option>Date Requested</option>
          <option>Requisition No.</option>
          <option>College</option>
          <option>Department</option>
          <option>Office</option>
          <option>Request Type</option>
        </select> <select name="select14">
          <option>Ascending</option>
          <option>Descending</option>
        </select></td>
      <td height="25"><font size="1">
        <select name="select13">
          <option>Date Requested</option>
          <option>Requisition No.</option>
          <option>College</option>
          <option>Department</option>
          <option>Office</option>
          <option>Request Type</option>
        </select>
        <select name="select10">
          <option>Ascending</option>
          <option>Descending</option>
        </select>
        </font><font size="1">&nbsp;</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/form_proceed.gif" border="0"></a></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="24" colspan="3"><div align="right"><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/print.gif" border="0"></a>click
          to print search result</font></div></td>
    </tr>
    <tr bgcolor="#B9B292">
      <td height="24" colspan="3"><div align="center"><font color="#FFFFFF">SEARCH
          RESULT OF PURCHASE REQUESTED ITEMS</font></div></td>
    </tr>
    <tr>
      <td width="60%" height="25"><div align="left"><b>Total Result : - Showing()</b></div></td>
      <td width="40%"><div align="right">
        </div></td>
      <td width="0%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="10%" height="25"><div align="center"><font size="1"><strong>DATE
          REQUESTED </strong></font></div></td>
      <td width="10%"><div align="center"><strong><font size="1">PURCHASE REQUISITION
          NO. </font></strong></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>REQUESTED BY</strong></font></div></td>
      <td width="30%"><div align="center"><font size="1"><strong>COLLEGE/DEPARTMENT/OFFICE</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>TOTAL ITEMS</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>TOTAL COST</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1">&nbsp;</font></div></td>
      <td width="5%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><font size="1">07/10/2004</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">0,000,000.00</font></td>
      <td><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/view.gif" border="0"></a></font></td>
      <td><div align="right"><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/delete.gif"  border="0"></a></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><div align="right"><font size="1"><strong>GRAND TOTAL COST
          :&nbsp;&nbsp;&nbsp;&nbsp; </strong></font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><div align="center"><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/print.gif" border="0"></a>click
          to print search result</font></div></td>
    </tr>
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
