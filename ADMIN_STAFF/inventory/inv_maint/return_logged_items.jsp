<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript">
function PageLoad(){
 	document.form_.req_no.focus();
}

function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;

	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function OpenSearchPO(){
	var pgLoc = "../../purchasing/purchase_order/purchase_request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CopyNoProp(){
	var iMaxDisp = document.form_.no_prop_items.value;
	if (iMaxDisp.length == 0)
		return;
	for (var i = 1 ; i < eval(iMaxDisp)+1;++i)
		eval('document.form_.reason'+i+'.value=document.form_.reason1.value');
}

function CopyLogged(){
	var iMaxDisp = document.form_.max_items.value;
	if (iMaxDisp.length == 0)
		return;
	for (var i = 1 ; i < eval(iMaxDisp)+1;++i)
		eval('document.form_.reason_log_'+i+'.value=document.form_.reason_log_1.value');
}

function CheckNoProp()
{
	document.form_.printPage.value = "";
	var iMaxDisp = document.form_.no_prop_items.value;
	if (iMaxDisp.length == 0)
		return;
	if (document.form_.selAllWout.checked ){
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.return_wout_'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.return_wout_'+i+'.checked=false');

}

function CheckAll()
{
	document.form_.printPage.value = "";
	var iMaxDisp = document.form_.max_items.value;
	if (iMaxDisp.length == 0)
		return;
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.return_'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.return_'+i+'.checked=false');

}

function PageAction(strAction,strIndex){
  document.form_.printPage.value = "";
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = strAction;
	document.form_.strIndex.value = strIndex;
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%@ page language="java" import="utility.*,purchasing.Delivery, inventory.InventoryMaintenance, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-RETURN"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
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
								"Admin/staff-PURCHASING-Delivery-View delivery update Status","return_logged_items.jsp");
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

	Delivery DEL = new Delivery();
	InventoryMaintenance InvMaint = new InventoryMaintenance();
	Vector vReqInfo = null;
	Vector vWithProp = null;
	Vector vNoProp = null;
	Vector vRetResult = null;
	int iCount = 1;
	int i = 0;
	String[] astrReqStatus = {"Disapproved","Approved","Pending"};
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"","Received(Status OK)","Received (Status not OK)","Returned"};
	String strReadOnly = null;

	strTemp = WI.fillTextValue("pageAction");
	if (WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = DEL.operateOnReqInfoDel(dbOP,request);
		if(vReqInfo == null)
			strErrMsg = DEL.getErrMsg();
		else{
			if(strTemp.length() > 0){
				if(InvMaint.operateOnLoggedItemReturn(dbOP, request, Integer.parseInt(strTemp)) == null)
					strErrMsg = InvMaint.getErrMsg();
				else
					strErrMsg = "Operation Successful";
			}

			vRetResult = InvMaint.operateOnLoggedItemReturn(dbOP,request,4);
			if(vRetResult == null)
				strErrMsg = InvMaint.getErrMsg();
			else{
				vNoProp = (Vector)vRetResult.elementAt(0);
				vWithProp = (Vector)vRetResult.elementAt(1);
			}
	  }
	}
%>
<form name="form_" method="post" action="return_logged_items.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"  align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>::::
          RETURN LOGGGED ITEMS PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="30" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="3%" height="30">&nbsp;</td>
      <td width="20%">PO No. :</td>
			<%if(WI.fillTextValue("req_no").length() > 0){
		  		strTemp = WI.fillTextValue("req_no");
			  }else{
	  			strTemp = "";
      	}%>
      <td width="27%"><input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="50%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a>
				<font size="1">click to search po no.</font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
	<%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4" align="center"><strong>REQUISITION DETAILS FOR PURCHASE ORDER NO. : <%=(String)vReqInfo.elementAt(1)%></strong></td>
    </tr>
		<input type="hidden" name="po_index" value="<%=(String)vReqInfo.elementAt(0)%>">
    <tr>
      <td height="25">&nbsp;</td>
      <td>PO Status:</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(3))]%></strong></td>
      <td>PO Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="21%">Requisition No. :</td>
      <td width="26%"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
      <td width="19%">Requested by :</td>
      <td width="31%"> <strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(6))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(8))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(10)) == null){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Non-Acad. Office/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(11)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>College/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)+"/"+WI.getStrValue((String)vReqInfo.elementAt(11),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
  </table>
	<%if(vNoProp != null && vNoProp.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST
          OF LOGGED PO ITEM(S) </strong></font><strong><font color="#FFFFFF">NOT YET DISTRIBUTED </font></strong></div></td>
    </tr>
    <tr>
      <td width="12%" align="center" class="thinborder"><strong>DATE LOGGED </strong></td>
      <td width="13%" height="27" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="33%" align="center" class="thinborder"><strong>ITEM / PARTICULARS / DESCRIPTION</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="21%" align="center" class="thinborder"><strong>REASON<br>
      <font size="1"><a href="javascript:CopyNoProp();">Copy First </a></font>      </strong></td>
      <td width="9%" align="center" class="thinborder"><strong>RETURN
          <input type="checkbox" name="selAllWout" value="0" onClick="CheckNoProp();">
      </strong>all</td>
    </tr>
    <% for(i = 0,iCount = 1;i < vNoProp.size();i+=10,++iCount){%>
    <tr>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vNoProp.elementAt(i+5),(String)vNoProp.elementAt(i+6))%></td>
			<input name="entry_index_no_<%=iCount%>" type="hidden" value="<%=(String)vNoProp.elementAt(i)%>">
			<%
				strTemp = (String)vNoProp.elementAt(i+1);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				//System.out.println("123             3 " + (String)vNoProp.elementAt(i+9));
				if(((String)vNoProp.elementAt(i+9)).equals("0") ||
					 ((String)vNoProp.elementAt(i+9)).equals("3"))
						strReadOnly = " readonly";
				else
						strReadOnly = "";
			%>
      <td height="26" class="thinborder">
			<input type="hidden" name="delivered_qty_<%=iCount%>" value="<%=strTemp%>">
      <input name="return_qty_<%=iCount%>" type="text" class="textbox" tabindex="-1"
				onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyFloat('form_','return_qty_<%=iCount%>');"
				onBlur="AllowOnlyFloat('form_','return_qty_<%=iCount%>');style.backgroundColor='white'"
				value="<%=strTemp%>" size="4" maxlength="10" style="text-align:right" <%=strReadOnly%>>
      <%=(String)vNoProp.elementAt(i+8)%></td>
      <td class="thinborder">&nbsp;<%=(String)vNoProp.elementAt(i+2)%>&nbsp;<%=(String)vNoProp.elementAt(i+3)%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vNoProp.elementAt(i+4), true);
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <td align="center" class="thinborder">
			<input name="reason<%=iCount%>" type="text" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'"
				size="18" maxlength="255" style="text-align:left"></td>
      <td align="center" class="thinborder">
			<input type="checkbox" name="return_wout_<%=iCount%>" value="1"></td>
    </tr>
    <%}%>
    <tr>
		<input type="hidden" name="no_prop_items" value ="<%=iCount-1%>">
      <td height="25" colspan="3" class="thinborder"><strong>TOTAL ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></td>
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
	<%} // if(vNoProp != null && vNoProp.size() > 0)%>

	<%if(vWithProp != null && vWithProp.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST
          OF LOGGED PO ITEM(S)</strong></font><strong><font color="#FFFFFF"> ALREADY DISTRIBUTED </font></strong></div></td>
    </tr>
    <tr>
      <td width="12%" height="27" align="center" class="thinborder"><strong>PROPERTY # </strong></td>
      <td width="13%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="45%" align="center" class="thinborder"><strong>ITEM / PARTICULARS / DESCRIPTION</strong></td>
      <td width="21%" align="center" class="thinborder"><strong>REASON<font size="1"><a href="javascript:CopyLogged();"><br>
      Copy First </a></font></strong></td>
      <td width="9%" class="thinborder"><div align="center"><strong>RETURN
            <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
      </strong>all</div></td>
    </tr>
    <% for(i = 0,iCount = 1;i < vWithProp.size();i+=13,++iCount){%>
    <tr>
      <input name="itemIndex_<%=iCount%>" type="hidden" value="<%=(String)vWithProp.elementAt(i)%>">
			<input name="entry_index_<%=iCount%>" type="hidden" value="<%=(String)vWithProp.elementAt(i+6)%>">
      <td height="26" class="thinborder">&nbsp;<%=WI.getStrValue((String)vWithProp.elementAt(i+5),"&nbsp;")%></td>
			<%
				strTemp = (String)vWithProp.elementAt(i+7);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				if(((String)vWithProp.elementAt(i+12)).equals("0") ||
					 ((String)vWithProp.elementAt(i+12)).equals("3"))
						strReadOnly = " readonly";
				else
						strReadOnly = "";
				%>
      <td class="thinborder">
				<input type="hidden" name="entry_unit_<%=iCount%>" value="<%=(String)vWithProp.elementAt(i+9)%>">
				<input type="hidden" name="distribution_unit_<%=iCount%>" value="<%=(String)vWithProp.elementAt(i+10)%>">
				<input type="hidden" name="conversion_qty_<%=iCount%>" value="<%=(String)vWithProp.elementAt(i+11)%>">
				<input type="hidden" name="distributed_qty_<%=iCount%>" value="<%=strTemp%>">
				<input name="ret_dist_qty_<%=iCount%>" type="text" class="textbox" tabindex="-1"
				onBlur="AllowOnlyFloat('form_','ret_dist_qty_<%=iCount%>');style.backgroundColor='white'"
				onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyFloat('form_','ret_dist_qty_<%=iCount%>');"
				value="<%=strTemp%>" size="4" maxlength="10" style="text-align:right" <%=strReadOnly%>>
      &nbsp;<%=(String)vWithProp.elementAt(i+8)%></td>
      <td class="thinborder">&nbsp;<%=(String)vWithProp.elementAt(i+2)%>&nbsp;<%=(String)vWithProp.elementAt(i+3)%></td>
			<td align="center" class="thinborder">
				<input name="reason_log_<%=iCount%>" type="text" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'"
				size="18" maxlength="255" style="text-align:left"></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vWithProp.elementAt(i+4), true);
			%>
      <td align="center" class="thinborder"><input type="checkbox" name="return_<%=iCount%>" value="1"></td>
    </tr>
    <%}%>
		<input type="hidden" name="max_items" value ="<%=iCount-1%>">
    <tr>
      <td height="25" colspan="3" class="thinborder"><strong>TOTAL
          ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>

	<%}// if vWithProp != null %>
	<%if((vWithProp != null && vWithProp.size() > 0) || (vNoProp != null && vNoProp.size() > 0)){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="100%" height="25" colspan="2" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2" align="center"><font size="1">
				<a href="javascript:PageAction(1,0);"><img src="../../../images/save.gif" border="0"></a>
				click to SAVE item status change &nbsp;&nbsp;&nbsp;&nbsp;
				<a href="javascript:ProceedClicked();"><img src="../../../images/cancel.gif" border="0"></a>
				 click to Cancel item status change </font>
			</td>
    </tr>
  </table>
	<%}%>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="strIndex" value="">
  <input type="hidden" name="printPage" value="">
	<input type="hidden" name="is_endorsed" value="1">
	<input type="hidden" name="search_po" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

