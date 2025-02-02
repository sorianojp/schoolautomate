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


function OpenSearchDel(){
	if(document.form_.search_po.checked)
		var pgLoc = "../purchase_order/purchase_request_view_search.jsp?opner_info=form_.req_no";
	else
		var pgLoc = "delivery_view_search.jsp?opner_info=form_.req_no";
		
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
<%@ page language="java" import="utility.*,purchasing.Delivery, purchasing.Returns, java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

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
								"Admin/staff-PURCHASING-DELIVERY-View delivery update Status","delivery_update_status.jsp");
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
   if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="delivery_update_status_cpu_print.jsp"/>
   <%}
    
	
	Delivery DEL = new Delivery();	
	Returns RET = new Returns();	
	Vector vReqInfo = null;
 	Vector vRetResult = null;
	Vector vItems = null;
	int iCount = 1;	
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"","Received(Status OK)","Received (Status not OK)",""};	
	
	if (WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = DEL.operateOnReqInfoDel(dbOP,request);
		if(vReqInfo == null)
			strErrMsg = DEL.getErrMsg();
		else{			
		  if(Integer.parseInt(WI.getStrValue((String)vReqInfo.elementAt(3),"0")) != 1){
		  	strErrMsg = "PO not yet approved";
		  }else{		  
				if(WI.fillTextValue("pageAction").length() > 0){
					vRetResult = RET.operateOnReqItemsReturn(dbOP, request, Integer.parseInt(WI.fillTextValue("pageAction")));
					if(vRetResult == null)
						strErrMsg = RET.getErrMsg();
					else
						strErrMsg = "Operation Successful";
			}

			vRetResult = RET.operateOnReqItemsReturn(dbOP,request,4);
			if(vRetResult == null)
				strErrMsg = RET.getErrMsg();
		 }
	  }
	}
%>	
<form name="form_" method="post" action="delivery_return_received_items.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3"  align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>:::: 
          DELIVERY - RETURN RECEIVED ITEMS TO SUPPLIER PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="30" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="30">&nbsp;</td>
      <td width="13%">Delivery  No. / Po Number:</td>
			<%if(WI.fillTextValue("req_no").length() > 0){
		  		strTemp = WI.fillTextValue("req_no");
			  }else{
	  			strTemp = "";
      	}%> 			
      <td width="85%"><input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:OpenSearchDel();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search po no.</font>
			<%
				if(WI.fillTextValue("search_po").equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
			%>
			<input type="checkbox" name="search_po" value="1" <%=strTemp%> onClick="javascript:ProceedClicked();"><font size="1">search for PO</font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
	<%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="2%" height="26">&nbsp;</td>
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
      <td height="25" width="2%">&nbsp;</td>
      <td width="21%">Requisition No. :</td>
      <td width="27%"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
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
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(11)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)+"/"+WI.getStrValue((String)vReqInfo.elementAt(11),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr> 
      <td width="8%" height="25" class="thinborder"  align="center"><strong>ITEM#</strong></td>
      <td width="14%" class="thinborder"  align="center"><strong>QTY</strong></td>
      <td width="15%" class="thinborder"  align="center"><strong>UNIT</strong></td>
      <td width="45%" class="thinborder"  align="center"><strong>ITEM / PARTICULARS  / DESCRIPTION </strong></td>
      <td width="18%" class="thinborder"  align="center"><strong>RETURN
      <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
      </strong>all</td>
    </tr>
		<%iCount = 1;
		int iItems = 0;
		for(int iLoop = 0;iLoop < vRetResult.size();iLoop+=12){
			vItems = (Vector) vRetResult.elementAt(iLoop+11);
		%>
    <tr>
      <td height="25" colspan="5" class="thinborder">Delivery # : <%=(String)vRetResult.elementAt(iLoop+2)%><br>
        Delivery Date : <%=(String)vRetResult.elementAt(iLoop+4)%></td>
    </tr>
    <%
		for(iItems = 0;iItems < vItems.size();iItems += 7,++iCount){%>
    <tr> 
      <td height="25" class="thinborder" align="center"><%=iCount%>&nbsp;</td>
			<input name="item_del_index_<%=iCount%>" type="hidden" value="<%=(String)vItems.elementAt(iItems)%>">
			<input name="itemIndex_<%=iCount%>" type="hidden" value="<%=(String)vItems.elementAt(iItems+1)%>">
			<%
				strTemp = (String)vItems.elementAt(iItems+2);				
			%>
      <td class="thinborder" align="right">
				<input type="hidden" name="delivered_qty_<%=iCount%>" value="<%=strTemp%>">
        <input name="return_qty_<%=iCount%>" type="text" class="textbox" tabindex="-1" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
				value="<%=strTemp%>" size="3" maxlength="10">
			</td>
      <td class="thinborder" align="center"><%=(String)vItems.elementAt(iItems+3)%>&nbsp;</td>
      <td class="thinborder" align="left">&nbsp;<%=(String)vItems.elementAt(iItems+4)%> / <%=(String)vItems.elementAt(iItems+5)%><%=WI.getStrValue((String)vItems.elementAt(iItems+6),"(",")","")%></td>
      <td class="thinborder" align="center">
			<input type="checkbox" name="return_<%=iCount%>" value="1">
			</td>
    </tr>
    <%}%>
		<%}%>
    <tr> 
      <td height="25" colspan="5" class="thinborder" align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%> </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("return_no");
			%>
	    <td height="10">Return reference # :      </td>
      <td><input type="text" name="return_no" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">Leave </font><font size="1">blank if delivery # should be system generated </font></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("return_date");
				if(strTemp == null || strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
			%>
      <td height="10">Return date:        </td>
      <td><input name="return_date" type="text" size="9" maxlength="10" class="textbox"
				 value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" 
				 onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.return_date');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp= WI.fillTextValue("reason_index");
			%>
      <td width="21%">Reason for returning :<br></td>
      <td width="76%"><select name="reason_index">
        <option value="">Select Reason</option>
        <%=dbOP.loadCombo("reason_index","reason"," from pur_preload_reason order by reason", strTemp, false)%>
      </select>
        <font size="1"> <a href='javascript:viewList("pur_preload_reason","reason_index","reason",
				"REASON","PUR_RETURN_ITEM","REASON_INDEX"," and is_valid = 1","","reason_index")'> <img src="../../../images/update.gif" border="0"></a></font><font size="1">click to UPDATE list of reasons</font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2">Remarks : <br>
      <textarea name="remarks" cols="40" rows="3"></textarea></td>
    </tr>
    <tr>
      <td height="25" colspan="3" align="center">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" align="center">
			 <font size="1">
			  <a href="javascript:PageAction(1,0);">
					<img src="../../../images/save.gif" border="0"></a>click to SAVE item status change &nbsp;&nbsp;&nbsp;&nbsp;
				<a href="javascript:ProceedClicked();">
					<img src="../../../images/cancel.gif" border="0"></a>click to Cancel item status change </font>			</td>
    </tr>
  </table>
	<%}// if vRetResult != null %>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="is_for_return" value="1">
	<input type="hidden" name="max_items" value ="<%=iCount-1%>">
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
