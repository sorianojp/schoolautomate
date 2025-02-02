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
	document.acn_requisition.submit();
}
function PageAction(strAction)
{
	document.acn_requisition.page_action.value = strAction;
	ReloadPage();
}
function Cancel()
{
	location = "./requisition.jsp";
}
function UpadteUnit()
{
	var pgLoc = "./update_unit.jsp";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ChangePage()
{
	location = "./requisition.jsp?page_operation=0";
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.Requisition,java.util.Vector" %>
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
								"Admin/staff-Accounting-TRANSACTION","requisition.jsp");
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
														"requisition.jsp");
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

Requisition requisition = new Requisition();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	iAction = Integer.parseInt(strTemp);
	if(WI.fillTextValue("page_operation").compareTo("1") ==0 && iAction ==0 )//delete the root.
	{
		if(requisition.OperateOnRequisitionType(dbOP,request,WI.fillTextValue("info_index"),0,null) == null)
			strErrMsg = requisition.getErrMsg();
 	}
	else if(requisition.OperateOnRequisitionDtl( dbOP, request,iAction, null) == null)
	{
		strErrMsg = requisition.getErrMsg();
	}

	if(strErrMsg == null)
		strErrMsg = "Operation successful.";
}

//It is time to view all
if(WI.fillTextValue("req_no").length() > 0)
{
	vReqInfo = requisition.OperateOnRequisitionType(dbOP,request,null,3,WI.fillTextValue("req_no"));
}
if(vReqInfo != null && vReqInfo.size() > 0)
{
	vReqDetail = requisition.OperateOnRequisitionDtl(dbOP,request,4, (String) vReqInfo.elementAt(0));
	if(vReqDetail == null)
		strErrMsg = requisition.getErrMsg();
}

%>
<form name="acn_requisition" method="post" action="./requisition.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          REQUISITION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
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
<%
if(WI.fillTextValue("page_operation").compareTo("1") != 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="21%">Requisition No.</td>
      <td width="15%"><input name="req_no" type="text" size="12" class="textbox" value="<%=WI.fillTextValue("req_no")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="20%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td width="41%">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(WI.fillTextValue("req_no").length() >0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td>Date</td>
      <td colspan="2">
        <%
	if(vReqInfo != null && vReqInfo.size() > 1)
		strTemp = (String)vReqInfo.elementAt(3);
	else
		strTemp = WI.fillTextValue("date_requested");
	%>
        <input name="date_requested" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('acn_requisition.date_requested');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requested by </td>
      <td colspan="3">
        <%
	if(vReqInfo != null && vReqInfo.size() > 1)
		strTemp = (String)vReqInfo.elementAt(2);
	else
		strTemp = WI.fillTextValue("requested_by");
	%>
        <input name="requested_by" type="text" size="50" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>College</td>
      <td colspan="3">
        <%
	if(vReqInfo != null && vReqInfo.size() > 1)
		strTemp = (String)vReqInfo.elementAt(4);
	else
		strTemp = WI.fillTextValue("c_index");
	%>
	  <select name="c_index" onChange="ReloadPage();">
          <option value="0">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",strTemp, false)%>
        </select></td>
    </tr>
<%
	String strTemp2 = null;
	if(vReqInfo != null && vReqInfo.size() > 1)
		strTemp2 = (String)vReqInfo.elementAt(5);
	else
		strTemp2 = WI.fillTextValue("d_index");

 if(strTemp != null && strTemp.compareTo("0") != 0){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Department</td>
      <td colspan="3"><select name="d_index">
         <%=dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 and c_index= "+strTemp+" order by d_name asc",strTemp2, false)%>
        </select></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Non-Acad. Office/Dept</td>
      <td colspan="3"><select name="d_index">
          <%=dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 and (c_index= 0 or c_index is null) order by d_name asc",strTemp2, false)%>
        </select></td>
    </tr>
    <%}%>
    <tr>
      <td height="26">&nbsp;</td>
      <td valign="top">Purpose/Job</td>
      <td colspan="3">
        <%
	if(vReqInfo != null && vReqInfo.size() > 1)
		strTemp = (String)vReqInfo.elementAt(6);
	else
		strTemp = WI.fillTextValue("purpose");
	%>
        <textarea name="purpose" cols="40" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="12%" valign="bottom">Quantity</td>
      <td width="43%" valign="bottom">Unit</td>
      <td width="42%" valign="bottom">Unit Price</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = WI.fillTextValue("quantity");
	%>
        <input name="quantity" type="text" size="5" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td><select name="unit_index">
<%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(7);
	else
		strTemp = WI.fillTextValue("unit_index");
%>
<%=dbOP.loadCombo("unit_index","unit"," from ACN_UNIT where IS_DEL=0 order by unit asc",strTemp, false)%>
        </select>
 <a href="javascript:UpadteUnit();"><img src="../../../images/update.gif" width="60" height="25" border="0"></a>     </td>
      <td>
<%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = WI.fillTextValue("unit_price");
%>
	  <input type="text" name="unit_price" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">Particulars</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">Last Date of Request</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(5);
	else
		strTemp = WI.fillTextValue("particular");
%>
	  <input name="particular" type="text" size="50" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td>
<%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
	else
		strTemp = WI.fillTextValue("last_date_of_req");
%>
	  <input name="last_date_of_req" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('acn_requisition.last_date_of_req');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><font size="1">
        <input type="image" src="../../../images/save.gif"></a>
        click to save entries&nbsp;&nbsp;&nbsp;&nbsp; <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>click
        to cancel/clear entries </font></td>
    </tr>
  </table>
<%}//if requisition value is entered.

//show above if page_operation =0.
}else{
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="14%">Date Range</td>
      <td colspan="2">From
        <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('acn_requisition.date_from');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;to
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('acn_requisition.date_to');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requisition No.</td>
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
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Sort by</td>
      <td width="34%" height="25"><select name="select6">
          <option>Date Requested</option>
          <option>Requisition No.</option>
          <option>College</option>
          <option>Department</option>
          <option>Non-Acad Office/Department</option>
        </select> </td>
      <td width="49%"><select name="select10">
          <option>Date Requested</option>
          <option>Requisition No.</option>
          <option>College</option>
          <option>Department</option>
          <option>Non-Acad Office/Department</option>
        </select>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><select name="select14">
          <option>Ascending</option>
          <option>Descending</option>
        </select></td>
      <td height="25"><select name="select12">
          <option>Ascending</option>
          <option>Descending</option>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/form_proceed.gif" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><div align="right"><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/print.gif" border="0"></a>click
          to requisition </font></div></td>
    </tr>
  </table>
<%}%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF">LIST
          OF REQUESTED ITEMS</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  height="25" colspan="9">Requested by : </td>
    </tr>
    <tr>
      <td width="5%"  height="25"><div align="center"><font size="1"><strong>ITEM
          #</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>QUANTITY</strong></font></div></td>
      <td width="7%"><div align="center"><strong><font size="1">UNIT</font></strong></div></td>
      <td width="38%"><div align="center"><font size="1"><strong>PARTICULARS</strong></font></div></td>
      <td width="13%"><div align="center"><font size="1"><strong>UNIT PRICE</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>TOTAL</strong></font></div></td>
      <td width="9%"><div align="center"><font size="1"><strong>LAST DATE OF REQUEST
          </strong></font></div></td>
      <td width="5%"><div align="center"><font size="1">&nbsp;</font></div></td>
      <td width="6%">&nbsp;</td>
    </tr>
    <tr>
      <td  height="25">1</td>
      <td><font size="1">&nbsp;999999</font></td>
      <td><font size="1">milligram(s)</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">0,000,000.00</font></td>
      <td><font size="1">07/10/2004</font></td>
      <td><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/edit.gif" border="0"></a></font></td>
      <td><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/delete.gif"  border="0"></a></font></td>
    </tr>
    <tr>
      <td  height="25"><font size="1">2&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td  height="25" colspan="4"><div align="left"><font size="1"><strong>TOTAL
          ITEM(S) : &nbsp;&nbsp;$TOTAL_ITEMS&nbsp;&nbsp;</strong></font></div></td>
      <td  height="25"><font size="1"><strong>TOTAL COST : </strong></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
</table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="24" colspan="3"><div align="right"><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/print.gif" border="0"></a>click
          to print search result</font></div></td>
    </tr>
    <tr>
      <td height="24" colspan="3" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF">SEARCH
          RESULT </font></div></td>
    </tr>
    <tr>
      <td width="60%" height="25"><div align="left"><b>Total Result : - Showing()</b></div></td>
      <td width="40%"><div align="right">Jump To page:
          <select name="jumpto" onChange="goToNextSearchPage();">

          </select>
        </div></td>
      <td width="0%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="10%" height="25"><div align="center"><font size="1"><strong>DATE
          REQUESTED </strong></font></div></td>
      <td width="10%"><div align="center"><strong><font size="1">REQUISITION NO.
          </font></strong></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>REQUESTED BY</strong></font></div></td>
      <td width="33%"><div align="center"><font size="1"><strong>COLLEGE/DEPARTMENT/OFFICE</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>TOTAL ITEMS</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>TOTAL COST</strong></font></div></td>
      <td width="6%"><div align="center"><font size="1">&nbsp;</font></div></td>
      <td width="7%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><font size="1">07/10/2004</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">0,000,000.00</font></td>
      <td>&nbsp;</td>
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
      <td colspan="2"><div align="right"><font size="1"><strong>TOTAL COST :&nbsp;&nbsp;&nbsp;&nbsp;
          </strong></font></div></td>
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
  </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</body>
</html>
<%
dbOP.cleanUP();
%>
