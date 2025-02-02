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
	document.p_request.page_action.value="";
	document.p_request.submit();
}
function PageAction(strAction)
{
	document.p_request.page_action.value = strAction;
}
function Cancel()
{
	location = "./purchase_request.jsp";
}
function ChangePage()
{
	location = "./purchase_request_search.jsp?page_operation=1";
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
function UpadteUnit()
{
	var pgLoc = "./update_unit.jsp?parentFormName=p_request";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
Vector vPReqInfo   = null;
Vector vPReqDetail = null;
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
	vPReqInfo = PR.OperateOnPRequestType(dbOP,request,null,3,WI.fillTextValue("req_no"));
}
if(vPReqInfo != null && vPReqInfo.size() > 0)
{
	vPReqDetail = PR.OperateOnPRequestDtl(dbOP,request,4, (String) vPReqInfo.elementAt(0));
	if(vPReqDetail == null)
		strErrMsg = PR.getErrMsg();
}

if(strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = PR.OperateOnPRequestDtl(dbOP,request,3, (String) vPReqInfo.elementAt(0));
	if(vEditInfo == null || vEditInfo.size() ==0)
		strErrMsg = PR.getErrMsg();
}

%>
<form name="p_request" method="post" action="./purchase_request.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          PURCHASE </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>REQUEST
          </strong></font><font color="#FFFFFF"><strong> PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
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
	if(vPReqInfo != null && vPReqInfo.size() > 1)
		strTemp = (String)vPReqInfo.elementAt(3);
	else
		strTemp = WI.fillTextValue("date_requested");
	%>
        <input name="date_requested" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('p_request.date_requested');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requested by </td>
      <td colspan="3">
        <%
	if(vPReqInfo != null && vPReqInfo.size() > 1)
		strTemp = (String)vPReqInfo.elementAt(2);
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
	if(vPReqInfo != null && vPReqInfo.size() > 1)
		strTemp = (String)vPReqInfo.elementAt(4);
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
	if(vPReqInfo != null && vPReqInfo.size() > 1)
		strTemp2 = (String)vPReqInfo.elementAt(5);
	else
		strTemp2 = WI.fillTextValue("d_index");

 if(strTemp != null && strTemp.compareTo("0") != 0 && strTemp.length() > 0){%>
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
	if(vPReqInfo != null && vPReqInfo.size() > 1)
		strTemp = (String)vPReqInfo.elementAt(6);
	else
		strTemp = WI.fillTextValue("purpose");
	%>
        <textarea name="purpose" cols="40" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>

<tr>
      <td height="26">&nbsp;</td>
      <td>Request Type</td>
      <td colspan="3"><select name="request_type">
          <option value="New">New</option>
<%
	if(vPReqInfo != null && vPReqInfo.size() > 1)
		strTemp = (String)vPReqInfo.elementAt(9);
	else
		strTemp = WI.fillTextValue("request_type");
if(strTemp.compareTo("Replacement") ==0){%>
         <option value="Replacement" selected>Replacement</option>
<%}else{%>
		 <option value="Replacement">Replacement</option>
<%}%>        </select></td>
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
      <td valign="bottom">Remarks</td>
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
		strTemp = WI.fillTextValue("remark");
%>
        <input type="text" name="remark" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
      </td>
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
        <%
	if(strPrepareToEdit.compareTo("0") == 0 && iAccessLevel > 1)
	{%>
        <input name="image" type="image" onClick='PageAction("1");' src="../../../images/add.gif">
        <font size="1" >click to save entry</font>
        <%}else{%>
        <input name="image" type="image" onClick='PageAction("2");' src="../../../images/edit.gif">
        <font size="1">click to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
        to cancel edit</font>
        <%}%>
        </font></td>
    </tr>
  </table>
<%}//if requisition value is entered.
if(vPReqDetail != null && vPReqDetail.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF">LIST
          OF PURCHASE REQUESTED ITEMS</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  height="25" colspan="9">Requested by : <%=WI.fillTextValue("requested_by")%></td>
    </tr>
    <tr>
      <td width="5%"  height="25"><div align="center"><font size="1"><strong>ITEM
          #</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>QUANTITY</strong></font></div></td>
      <td width="7%"><div align="center"><strong><font size="1">UNIT</font></strong></div></td>
      <td width="38%"><div align="center"><font size="1"><strong>PARTICULARS</strong></font></div></td>
      <td width="13%"><div align="center"><font size="1"><strong>UNIT PRICE</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>TOTAL AMOUNT</strong></font></div></td>
      <td width="9%"><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1">&nbsp;</font></div></td>
      <td width="6%">&nbsp;</td>
    </tr>
    <%
float fSubTotal = 0f;
float fTotal    = 0f;
int iCount      = 0;

for(int i = 0; i<vPReqDetail.size(); ++i)
{
	fSubTotal = Float.parseFloat((String)vPReqDetail.elementAt(i+2))* Float.parseFloat((String)vPReqDetail.elementAt(i+4));
	fTotal += fSubTotal;
	++iCount;
%>
    <tr>
      <td  height="25"><%=iCount%></td>
      <td><font size="1"><%=(String)vPReqDetail.elementAt(i+2)%></font></td>
      <td><font size="1"><%=(String)vPReqDetail.elementAt(i+3)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vPReqDetail.elementAt(i+5)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vPReqDetail.elementAt(i+4)%></font></td>
      <td><font size="1"><%=CommonUtil.formatFloat(fSubTotal,true)%></font></td>
      <td><font size="1"><%=WI.getStrValue((String)vPReqDetail.elementAt(i+6),"&nbsp;")%></font></td>
      <td>
        <%if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vPReqDetail.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
        <%}%>
      </td>
      <td>
        <%if(iAccessLevel ==2){%>
        <a href='javascript:DeleteRecord("<%=(String)vPReqDetail.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        N/A
        <%}%>
      </td>
    </tr>
    <%
i = i+7;
}%>
    <tr>
      <td  height="25" colspan="4"><div align="left"><font size="1"><strong>TOTAL
          ITEM(S) : &nbsp;&nbsp;<%=iCount%></strong></font></div></td>
      <td  height="25" colspan="3"><font size="1"><strong>TOTAL COST : <%=CommonUtil.formatFloat(fTotal,true)%></strong></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}//only if vPReqDetail is not null.
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
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
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
