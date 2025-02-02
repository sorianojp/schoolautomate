<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function PageLoad(){
 	document.form_.req_no.focus();
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";	
	this.SubmitOnce('form_');
}
function PageAction(strAction,strIndex){
  document.form_.printPage.value = "";
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = strAction;
	document.form_.strIndex.value = strIndex;
	this.SubmitOnce('form_');
}
function CancelClicked(){
	location = "./delivery_status_non_po.jsp?req_no=<%=WI.fillTextValue("req_no")%>";
}

function OpenSearch(){
	document.form_.printPage.value = "";
	var pgLoc = "../requisition/requisition_view_search.jsp?opner_info=form_.req_no&is_supply=form_.is_supply";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
}

function ChangeItem(strPOItemIndex){
	var pgLoc = "../purchase_order/purchase_request_change_item.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=650,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}

function ReloadPage()
{
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function CopyAll()
{
	document.form_.printPage.value = "";
	if(document.form_.copy_all.checked)
	{
		if(document.form_.invoice1.value.length == 0 || document.form_.ship_method1.value.length == 0) {
			alert("Please enter first invoice field input and shipping method");
			document.form_.copy_all.checked = false;
			return;
		}
		ReloadPage();
	}
}
function CopyInvoice(){
	var vItems = document.form_.strNumOfItems.value;
	if (vItems.length == 0)
		return;	
	for (var i = 1 ; i < eval(vItems)+1;++i)
		eval('document.form_.invoice'+i+'.value=document.form_.invoice1.value');				
}
function CopyShip(){
	var vItems = document.form_.strNumOfItems.value;
	if (vItems.length == 0)
		return;	
	for (var i = 1 ; i < eval(vItems)+1;++i)
		eval('document.form_.ship_method'+i+'.value=document.form_.ship_method1.value');				
}
function CopyStatus(){
	var vItems = document.form_.strNumOfItems.value;
	if (vItems.length == 0)
		return;	
	for (var i = 1 ; i < eval(vItems)+1;++i)
		eval('document.form_.status_'+i+'.value=document.form_.status_1.value');				
}

function ViewItem(strIndex, strCode){
	var pgLoc = "delivery_non_po_view.jsp?req_no="+document.form_.req_no.value+
							"&supplier_code="+strCode+"&po_item_index="+strIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-DELIVERY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-DELIVERY-View delivery update Status","delivery_status_non_po.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.

	String strSchCode = dbOP.getSchoolIndex();	
   if(WI.fillTextValue("printPage").equals("1")){
	  if(!strSchCode.startsWith("CPU")){%>
		<jsp:forward page="delivery_status_non_po_print.jsp"/>
	  <%}else{%>
		<jsp:forward page="delivery_status_cpu_nonpo_print.jsp"/>
	  <%}
    }
	
	Delivery DEL = new Delivery();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vReqPO = null;
	Vector vReqItemsRet = null;
	Vector vRetResult = null;
	int iCount = 1;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	
	if (WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = DEL.operateOnNonPOReqInfo(dbOP,request);
		if(vReqInfo == null)
			strErrMsg = DEL.getErrMsg();
		else{			
			if(WI.fillTextValue("pageAction").length() > 0){
				vRetResult = DEL.operateOnNonPOItemsDel(dbOP, request,
													  Integer.parseInt(WI.fillTextValue("pageAction")), (String)vReqInfo.elementAt(0));
				if(vRetResult == null)
					strErrMsg = DEL.getErrMsg();
				else
					strErrMsg = "Operation Successful";
			}

			vRetResult = DEL.operateOnNonPOItemsDel(dbOP,request,4,(String)vReqInfo.elementAt(0));
			if(vRetResult == null || vRetResult.size() == 0)
				strErrMsg = DEL.getErrMsg();
			else{
				vReqPO = (Vector)vRetResult.elementAt(0);
				vReqItems = (Vector)vRetResult.elementAt(1);
				vReqItemsRet = (Vector)vRetResult.elementAt(2);
			}	
	  }
	}
%>	
<form name="form_" method="post" action="delivery_status_non_po.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          DELIVERY - RECEIVE NON PO ITEMS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="24%">REQUISITION NO. :</td>
      <td width="29%"> <%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp = WI.fillTextValue("req_no");
	  }else{
	  		strTemp = "";
      }%> <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="44%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a><font size="1">click 
        to search requisition no.</font></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
  </table>  
<%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS </strong></div></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(12)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(1))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(3)).equals("0")){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
  </table>
  <%if((vReqPO != null && vReqPO.size() > 0) || 
       (vReqItems != null && vReqItems.size() > 0) ||
	   (vReqItemsRet != null && vReqItemsRet.size() > 0)){%>
  <table bgcolor="#FFFFFF" width="100%" border="0">
  		<tr>
			<td><div align="right">
			<a href="javascript:PrintPage();">
			<img src="../../../images/print.gif" border="0">
			</a>
			<font size="1">click to print</font>
			</div></td>
		</tr>
  </table>
  <%if(vReqPO != null && vReqPO.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" bgcolor="#B9B292" colspan="9" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF UNDELIVERED NON-PO ITEM(S)</strong></font></div></td>
    </tr>
    <tr> 
      <td width="6%" height="25" align="center" valign="bottom" class="thinborder"><strong>ITEM#</strong></td>
      <td width="4%" align="center" valign="bottom" class="thinborder"><strong>QTY</strong></td>
      <td width="5%" align="center" valign="bottom" class="thinborder"><strong>UNIT</strong></td>
      <td width="18%" align="center" valign="bottom" class="thinborder"><strong>ITEM / PARTICULARS 
      / DESCRIPTION </strong></td>
      <td width="12%" align="center" valign="bottom" class="thinborder"><strong>SUPPLIER 
      CODE </strong></td>	  
      <td width="13%" align="center" valign="bottom" class="thinborder"><strong>&nbsp;SHIPPING 
          METHOD</strong><br>    
      <a href="javascript:CopyShip();"><font size="1"><strong>Copy First </strong></font></a></td>      
      <td width="10%" align="center" valign="bottom" class="thinborder"><strong>INVOICE NO<font size="1"><strong> 
        <br>
          <font size="1"><a href="javascript:CopyInvoice();">Copy First</a></font></strong></font></strong></td>
      <td width="20%" align="center" valign="bottom" class="thinborder"><strong>RECEIVE STATUS</strong><br>  
      <strong><font size="1"><a href="javascript:CopyStatus();">Copy First </a></font></strong></td>
      <td width="12%" align="center" valign="bottom" class="thinborder"><strong>DATE RECEIVED</strong></td>
    </tr>
    <%for(int iLoop = 0;iLoop < vReqPO.size();iLoop+=12,++iCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center">
        <input type="hidden" name="po_qty_<%=iCount%>" value="<%=(String)vReqPO.elementAt(iLoop+1)%>">
        <input type="hidden" name="delivered_qty_<%=iCount%>" value="<%=(String)vReqPO.elementAt(iLoop+11)%>">
        <input name="new_deliver_qty_<%=iCount%>" type="text" class="textbox" tabindex="-1" 
				onBlur="AllowOnlyFloat('form_','new_deliver_qty_<%=iCount%>');style.backgroundColor='white';"
				onKeyUp="AllowOnlyFloat('form_','new_deliver_qty_<%=iCount%>');"
				onFocus="style.backgroundColor='#D3EBFF'"
				value="<%=(String)vReqPO.elementAt(iLoop+10)%>" size="3" maxlength="10" style="text-align:right">
      </div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqPO.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqPO.elementAt(iLoop+3)%> / <%=(String)vReqPO.elementAt(iLoop+4)%> <%=WI.getStrValue((String)vReqPO.elementAt(iLoop+7),"(",")","")%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqPO.elementAt(iLoop+5)%></div></td>
      <td class="thinborder">
        <select name="ship_method<%=iCount%>">
          <option value="">Select Type</option>
          <%=dbOP.loadCombo("SHIPPING_INDEX","METHOD_NAME"," from PUR_PRELOAD_SHIPPING order by METHOD_NAME", strTemp, false)%> 
        </select></td>      
      <td class="thinborder"><div align="center">
          <input name="invoice<%=iCount%>" type="text" class="textbox" tabindex="-1" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="10">
        </div></td>
      <td class="thinborder"><div align="center"> 
          <% 
		  if(((String)vReqInfo.elementAt(10)).equals("1")){%>
          <select name="status_<%=iCount%>">
            <option value="0">Not Received</option>
            <%if(((String)vReqPO.elementAt(iLoop+6)).equals("3")){%>
            <option value="1">Received and OK</option>
            <option value="2">Received and not OK</option>
            <option value="3" selected>Returned</option>
            <%}else{%>
            <option value="1">Received and OK</option>
            <option value="2">Received and not OK</option>
            <option value="3">Returned</option>
            <%}%>
          </select>
          <%}else{%>
          N/A 
          <%}%>
          <input type="hidden" name="itemIndex_<%=iCount%>" value="<%=(String)vReqPO.elementAt(iLoop)%>">
        </div></td>
      <td class="thinborder"> <div align="center"> 
          <input name="date_status_<%=iCount%>" type="text" size="9" maxlength="10" readonly="yes" value="<%=WI.getTodaysDate(1)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <a href="javascript:show_calendar('form_.date_status_<%=iCount%>');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
          <img src="../../../images/calendar_new.gif" border="0"></a></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%></strong> 
          <input type="hidden" name="strNumOfItems" value="<%=iCount - 1%>">
        </div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%">
  	<tr>
		<td height="20">&nbsp;</td>
	</tr>	
  </table>
  <%}//end vReqPO != null && vReqPO.size() > 3%>
  <%if(vReqItems != null && vReqItems.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" bgcolor="#B9B292" colspan="8" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF DELIVERED NON-PO ITEM(S) </strong></font></div></td>
    </tr>
    <tr> 
      <td width="6%" height="25" align="center" class="thinborder"><strong>ITEM#</strong></td>
      <td width="4%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="26%" align="center" class="thinborder"><strong>ITEM / PARTICULARS 
          / DESCRIPTION </strong></td>
      <td width="18%" align="center" class="thinborder"><strong>SUPPLIER 
          CODE </strong></td>
      <td width="16%" align="center" class="thinborder"><strong>RECEIVE STATUS</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>DATE RECEIVED</strong></td>
      <td width="7%" align="center" class="thinborder">&nbsp;</td>
    </tr>
    <%iCount = 1;
	for(int iLoop = 0;iLoop < vReqItems.size();iLoop+=12,++iCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td align="right" class="thinborder"><%=(String)vReqItems.elementAt(iLoop+11)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop+2)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop+3)%> / <%=(String)vReqItems.elementAt(iLoop+4)%><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+8),"(",")","")%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop+5)%></td>
      <td class="thinborder"><%=astrReceiveStat[Integer.parseInt((String)vReqItems.elementAt(iLoop+6))]%></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+7)%></div></td>
      <td class="thinborder"><div align="center"><a href="javascript:ViewItem('<%=(String)vReqItems.elementAt(iLoop)%>', '<%=(String)vReqItems.elementAt(iLoop+5)%>');"><img src="../../../images/view.gif" border="0" ></a></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="8" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%> </strong></div></td>
    </tr>
  </table>
  <%}// end vReqItems != null && vReqItems.size() > 3%>
  <%if(vReqItemsRet != null && vReqItemsRet.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" bgcolor="#B9B292" colspan="7" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF RETURNED NON-PO ITEM(S) </strong></font></div></td>
    </tr>
    <tr> 
      <td width="8%" height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="28%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS 
      / DESCRIPTION </strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong>SUPPLIER 
      CODE </strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong>RECEIVE STATUS</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>CHANGE ITEM</strong></div></td>
    </tr>
    <%iCount = 1;
	for(int iLoop = 0;iLoop < vReqItemsRet.size();iLoop+=10,++iCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItemsRet.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><%=(String)vReqItemsRet.elementAt(iLoop+2)%></td>
      <td class="thinborder"><%=(String)vReqItemsRet.elementAt(iLoop+3)%> / <%=(String)vReqItemsRet.elementAt(iLoop+4)%><%=WI.getStrValue((String)vReqItemsRet.elementAt(iLoop+8),"(",")","")%></td>
      <td class="thinborder"><%=(String)vReqItemsRet.elementAt(iLoop+5)%></td>
      <td class="thinborder"><%=astrReceiveStat[Integer.parseInt((String)vReqItemsRet.elementAt(iLoop+6))]%></td>
      <td class="thinborder">
	  	<div align="center"> 
	  		<a href="javascript:PageAction(0,<%=(String)vReqItemsRet.elementAt(iLoop)%>);"> 
            <img src="../../../images/select.gif" border="0"> </a> 
		</div>
      </td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="7" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%> </strong></div></td>
    </tr>
  </table>
  <%}// end if(vReqItemsRet != null && vReqItemsRet.size() > 3%>
  
  <%if(vReqPO != null && vReqPO.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
	<%
		strTemp = WI.fillTextValue("received_by");
	%>
      <td height="25">Received by: 
        <input type="text" name="received_by" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><a href="javascript:PageAction(1,0);"> 
          <img src="../../../images/save.gif" border="0"> </a><font size="1">click to save update</font> 
          <a href="javascript:CancelClicked();"> <img src="../../../images/cancel.gif" border="0"> 
          </a> <font size="1">click to cancel</font> </div></td>
    </tr>
  </table>
  <%}if((vReqPO == null && vReqPO.size() < 0) || (vReqItems == null && vReqItems.size() < 0)){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"><div align="center"> 
          <a href="javascript:CancelClicked();"><img src="../../../images/go_back.gif" border="0"></a>
		  <font size="1">click to go back</font></div></td>
    </tr>
  </table>  
  <%}}}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"></td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>"> 
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="strIndex" value="">
  <input type="hidden" name="printPage" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
