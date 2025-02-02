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
	if(document.endorsement_.prepareToEdit.value != 1)
		document.endorsement_.submit();
}
function PageAction(strAction)
{
	document.endorsement_.page_action.value = strAction;
}
function Cancel()
{
	location = "./endorsement_order.jsp";
}
function UpadteUnit()
{
	var pgLoc = "./update_unit.jsp?parentFormName=endorsement_";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ChangePage()
{
	location = "./endorsement_order_search.jsp?page_operation=1";
}
function PrepareToEdit(strInfoIndex)
{
	document.endorsement_.page_action.value ="";
	document.endorsement_.prepareToEdit.value = 1;
	document.endorsement_.info_index.value = strInfoIndex;
	document.endorsement_.submit();
}
function DeleteRecord(strInfoIndex)
{
	document.endorsement_.page_action.value="0";
	document.endorsement_.info_index.value=strInfoIndex;
	document.endorsement_.submit();
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.PurchaseRequest,Accounting.EndorsementOrder,java.util.Vector" %>
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
Vector vPReqInfo   = null;
Vector vEditInfo   = null;
Vector vEODetail   = null;

int iAction = 0;

PurchaseRequest PR  = new PurchaseRequest();
EndorsementOrder EO = new EndorsementOrder();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	iAction = Integer.parseInt(strTemp);
	if(EO.OperateOnEndorsementOrder( dbOP, request,iAction,null) == null)
	{
		strErrMsg = EO.getErrMsg();
	}

	if(strErrMsg == null)
	{
		strErrMsg = "Operation successful.";
		strPrepareToEdit = "0";
	}
}

//It is time to view all
if(WI.fillTextValue("req_no").length() > 0)
{
	vPReqInfo = PR.OperateOnPRequestType(dbOP,request,null,3,WI.fillTextValue("req_no"));
}

if(strPrepareToEdit.compareTo("1") ==0 && vPReqInfo != null)
{
	vEditInfo = EO.OperateOnEndorsementOrder(dbOP,request,3,null);
	if(vEditInfo == null || vEditInfo.size() ==0)
		strErrMsg = PR.getErrMsg();
}
else if(vPReqInfo != null)
{//I am inserting null values for the fields not in purchase request table.
	vEditInfo = PR.viewPRequestDetail(dbOP,WI.fillTextValue("req_dtl_index"));
	if(vEditInfo == null)
		strErrMsg = PR.getErrMsg();
	else
	{
		vEditInfo.removeElementAt(0);
		vEditInfo.insertElementAt(WI.fillTextValue("item_received_by"),0);//ITEM_RECEIVED_BY
		vEditInfo.insertElementAt(WI.fillTextValue("endorsed_by"),0);//ENDORSED_BY
		vEditInfo.insertElementAt(WI.fillTextValue("date_endorsed"),0);//DATE_ENDORSED
		vEditInfo.insertElementAt(WI.fillTextValue("endorse_form_no"),0);//ENDORSE_FORM_NO
		vEditInfo.insertElementAt(null,0);//ENDORSEMENT_INDEX
	}
}

//I have to get here the endorsements created.
if(vPReqInfo != null)//
{
	vEODetail = EO.OperateOnEndorsementOrder(dbOP,request,4,WI.fillTextValue("req_no"));
	if(vEODetail == null)
		strErrMsg = EO.getErrMsg();
}

%>
<form name="endorsement_" method="post" action="./endorsement_order.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          ENDORSEMENT ORDER PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="12%">Operation </td>
      <td width="85%"><select name="page_operation" onChange="ChangePage();">
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
      <td width="21%">Purchase Request No. </td>
      <td width="16%"><input name="req_no" type="text" size="12" class="textbox" value="<%=WI.fillTextValue("req_no")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="10%"><font size="1"><a href="search_purchase%20request.htm" target="_blank"><img src="../../../images/search.gif" border="0"></a></font></td>
      <td width="42%"><input type="image" src="../../../images/form_proceed.gif"></td>
      <td width="8%">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="6"><hr size="1"></td>
    </tr>
	</table>

<%
if(vPReqInfo != null && vPReqInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="2" valign="bottom">Date Requested</td>
      <td valign="bottom">Requested by </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2"><strong><%=(String)vPReqInfo.elementAt(3)%></strong></td>
      <td><strong><%=(String)vPReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" valign="bottom">College/Department/Office</td>
      <td valign="bottom">Purpose/Job</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2"><strong>
	  <%
	  if(vPReqInfo.elementAt(7) != null){%>
	  <%=(String)vPReqInfo.elementAt(7)%>
	  <%}%>
	  <%=(String)vPReqInfo.elementAt(8)%>
	  </strong></td>
      <td><strong><%=(String)vPReqInfo.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" valign="bottom">Request Type </td>
      <td width="53%" valign="bottom">Items Received by</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2"><strong><%=(String)vPReqInfo.elementAt(9)%></strong></td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("item_received_by");
%>
	  <input name="item_received_by" type="text" size="34" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="3%" height="26">&nbsp;</td>
      <td>List of Purchase requested Items:
        <select name="req_dtl_index" onChange="ReloadPage();">
          <option value="0">Select a requested item from particular</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("req_dtl_index");
%>
          <%=dbOP.loadCombo("REQ_DTL_INDEX","PARTICULAR"," from ACN_PURCHASE_REQ_DTL "+
	"join ACN_PURCHASE_REQ on (ACN_PURCHASE_REQ.PURCHASE_REQ_INDEX=ACN_PURCHASE_REQ_DTL.PURCHASE_REQ_INDEX) "+
	" where ACN_PURCHASE_REQ_DTL.IS_DEL=0 and ACN_PURCHASE_REQ_DTL.is_valid=1 and ACN_PURCHASE_REQ.req_no='"+
	ConversionTable.replaceString(WI.fillTextValue("req_no"),"'","''")+"' order by particular asc",strTemp, false)%>
        </select></td>
    </tr>
  </table>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="3%" height="26">&nbsp;</td>
      <td colspan="2" valign="bottom">Endorsement Form No. </td>
      <td width="23%"  valign="bottom">Date Endorsed </td>
      <td width="46%"  valign="bottom">Endorsed by </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" valign="bottom">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("endorse_form_no");
%>
	  <input type="text" name="endorse_form_no" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("date_endorsed");
%>
        <input name="date_endorsed" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('endorsement_.date_endorsed');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("endorsed_by");
%>	  <input name="endorsed_by" type="text" size="36" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
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
		strTemp = (String)vEditInfo.elementAt(6);
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
		strTemp = (String)vEditInfo.elementAt(9);
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
		strTemp = (String)vEditInfo.elementAt(10);
	else
		strTemp = WI.fillTextValue("particular");
%>
	  <input name="particular" type="text" size="50" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td>
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(11));
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
if(vEODetail != null && vEODetail.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF">LIST
          OF ENDORSED ITEMS</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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

for(int i = 0; i<vEODetail.size(); ++i)
{
	fSubTotal = Float.parseFloat((String)vEODetail.elementAt(i+6))* Float.parseFloat((String)vEODetail.elementAt(i+9));
	fTotal += fSubTotal;
	++iCount;
%>
    <tr>
      <td  height="25"><%=iCount%></td>
      <td><font size="1"><%=(String)vEODetail.elementAt(i+6)%></font></td>
      <td><font size="1"><%=(String)vEODetail.elementAt(i+8)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vEODetail.elementAt(i+10)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vEODetail.elementAt(i+9)%></font></td>
      <td><font size="1"><%=CommonUtil.formatFloat(fSubTotal,true)%></font></td>
      <td><font size="1"><%=WI.getStrValue((String)vEODetail.elementAt(i+11),"&nbsp;")%></font></td>
      <td>
        <%if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vEODetail.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
        <%}%>
      </td>
      <td>
        <%if(iAccessLevel ==2){%>
        <a href='javascript:DeleteRecord("<%=(String)vEODetail.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        N/A
        <%}%>
      </td>
    </tr>
    <%
i = i+11;
}%>
    <tr>
      <td  height="25" colspan="4"><div align="left"><font size="1"><strong>TOTAL
          ITEM(S) : &nbsp;&nbsp;<%=iCount%></strong></font></div></td>
      <td  height="25" colspan="3"><font size="1"><strong>TOTAL COST : <%=CommonUtil.formatFloat(fTotal,true)%></strong></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}//vPReqInfo is not null.

}//only if vEODetail is not null.
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
