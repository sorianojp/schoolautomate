<%@ page language="java" import="utility.*,purchasing.PO,purchasing.Requisition,purchasing.Quotation,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	if(WI.fillTextValue("print_pg").equals("1")){%>
		<jsp:forward page="purchase_request_update_entries_print.jsp"/>
	<%return;}
	if(WI.fillTextValue("print_pg").equals("2")){%>
		<jsp:forward page="purchase_request_print.jsp"/>
	<%return;}

	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

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
function ViewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function EditPO(strPOItemIndex,strReqIndex,strPOIndex,strReqItemIndex){	
	document.form_.focus_area.value = "2";
	document.form_.print_pg.value = "";
	var pgLoc = "./purchase_request_pop_up.jsp?po_item_index="+strPOItemIndex+"&req_index="+strReqIndex+
	"&isForPop=1&po_index="+strPOIndex+"&req_item_index="+strReqItemIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=550,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageLoad(){
	var pageNo = "";
	pageNo = <%=WI.getStrValue(WI.fillTextValue("focus_area"),"2")%>
	if(eval('document.form_.req_no'+pageNo))
		eval('document.form_.req_no'+pageNo+'.focus()');
	else
		document.form_.req_no.focus();
 	//document.form_.req_no.focus();
}
function ProceedClicked(){
	document.form_.focus_area.value = "";
	document.form_.print_pg.value = "";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function SaveClicked(){
	document.form_.print_pg.value = "";
	document.form_.saveClicked.value = "1";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function CancelClicked(){
	location = "./purchase_request_update_status.jsp";
}
function OpenSearchPO(){
	document.form_.print_pg.value = "";
	var pgLoc = "./purchase_request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPg(strPrintRef){
	document.form_.print_pg.value = strPrintRef;
	this.SubmitOnce('form_');
}
function QuoteItem(strIndex,strReqIndex,strInfoIndex){
    document.form_.print_pg.value = "";
	var pgLoc = "../quotation/quotation_encode_pop_up_additional_cost.jsp?req_index="+strReqIndex+"&page_action=3&info_index="+
		strInfoIndex+"&supplier="+strIndex;
	var win=window.open(pgLoc,"PrintWindow",  'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function DeleteCost(strIndex,strDelete){
	if(!confirm('Delete '+strDelete+'?'))
		return;
	document.form_.delete_cost.value = 1;
	document.form_.info_index.value = strIndex;
	this.SubmitOnce('form_');
}
</script>
<%

//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-PURCHASE ORDER"),"0"));
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
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"PURCHASING-PURCHASE ORDER","purchase_request_update_entries.jsp");
	Requisition REQ = new Requisition();
	PO PO = new PO();
	Quotation QTN = new Quotation();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vReqPO = null;
	Vector vReqItemsQtn = null;
	Vector vAddtlCost = null;
	boolean bolIsInPO = false;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String strErrMsg = null;
	String strTemp = null;
	String strTemp1 = null;
	String strTemp2 = null;
	
	String strInfoIndex = WI.fillTextValue("info_index");	
	int iLoop = 0;
	int iCount = 0;
	String strReqIndex  = null;
	Vector vSuppliers  = null;
	
	boolean bolAdditionalData = true;

	if (WI.fillTextValue("proceedClicked").equals("1")){
		if(WI.fillTextValue("delete_cost").length() > 0){
			vReqInfo = QTN.operateOnAdditionalCost(dbOP,request,0);
			if(vReqInfo == null)
				strErrMsg = QTN.getErrMsg();
			else
				strErrMsg = "Operation Successful.";				
		}
		
		vReqInfo = PO.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null)
			strErrMsg = PO.getErrMsg();
		else			
			strReqIndex = (String)vReqInfo.elementAt(1);		
		

		if(vReqInfo != null && vReqInfo.size() > 1){
			vReqPO = PO.operateOnPOInfo(dbOP,request,4,strReqIndex);
			if(vReqPO != null){
			
				bolIsInPO = true;	
						
				/*vReqItems = PO.operateOnPOItems(dbOP,request,4);
				if(vReqItems == null)
					strErrMsg = PO.getErrMsg();	*/
					
				vReqItems = PO.operateOnPOItems(dbOP,request, 4, "", bolAdditionalData);			
				if (vReqItems == null)			
					strErrMsg = PO.getErrMsg();	
					
					
				vReqItemsQtn = PO.showItemsQuoted(dbOP,request,strReqIndex);
				if(vReqItemsQtn == null)
					strErrMsg = PO.getErrMsg();	

			}else{
				strErrMsg = PO.getErrMsg();
			}			
		}

		vAddtlCost = PO.showAdditionalCost(dbOP,strReqIndex);
		if(vAddtlCost == null)
			strErrMsg = PO.getErrMsg();
		
		if((vReqItems == null || vReqItems.size() < 1) && strErrMsg == null)
			strErrMsg = "No item encoded for this Requisition.";
	}
		
/*	if (WI.fillTextValue("proceedClicked").equals("1")){
		if(WI.fillTextValue("delete_cost").length() > 0){
			vReqInfo = QTN.operateOnAdditionalCost(dbOP,request,0);
			if(vReqInfo == null)
				strErrMsg = QTN.getErrMsg();
			else
				strErrMsg = "Operation Successful.";				
		}
		
		vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null)
			strErrMsg = REQ.getErrMsg();
		else{
			strInfoIndex = (String)vReqInfo.elementAt(0);
			if(WI.fillTextValue("saveClicked").equals("1")){
				if(PO.operateOnReqStatusPO(dbOP,request))
					strErrMsg = "Status Saved.";
				else
					strErrMsg = PO.getErrMsg();
			}			
		
			vReqPO = PO.operateOnReqInfoPO(dbOP,request,3,strInfoIndex);

			if(vReqPO != null){
				bolIsInPO = true;				
				vReqItems = PO.operateOnReqItemsPO(dbOP,request,4,strInfoIndex);
				if(vReqItems == null)
					strErrMsg = PO.getErrMsg();
				vReqItemsQtn = PO.showItemsQuoted(dbOP,request,strInfoIndex);
				if(vReqItemsQtn == null)
					strErrMsg = PO.getErrMsg();	
			}
			else		
				strErrMsg = "No PO encoded. Please Encode PO first.";
				
			vAddtlCost = PO.showAdditionalCost(dbOP,strInfoIndex);
			if(vAddtlCost == null)
				strErrMsg = PO.getErrMsg();
		}
	}
	*/
Vector vPOSupplier = null;
if(vReqInfo != null && vReqInfo.size() > 0) 
	vPOSupplier = PO.showPOSuppliers(dbOP, (String)vReqInfo.elementAt(0));
		
%>
<body bgcolor="#D2AE72" onLoad="PageLoad();">
<form name="form_" method="post" action="./purchase_request_update_entries.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PURCHASE </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>ORDER</strong></font><font color="#FFFFFF"><strong> 
          - UPDATE PO ENTRIES PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="28%">PO No. :</td>
      <td width="25%"> 
	  <%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp1 = WI.fillTextValue("req_no");
	  }else{
	  		strTemp1 = "";
      }%> <input type="text" name="req_no" class="textbox" value="<%=strTemp1%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="44%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search po no.</font></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%if(vReqPO != null && vReqPO.size() > 2 && bolIsInPO){%>
    <tr> 
      <td height="25"> 
      <td>PO No. : <strong><%=(String)vReqPO.elementAt(1)%>
        <input type="hidden" name="old_po_num" value="<%=(String)vReqPO.elementAt(1)%>">
        </strong></td>
      <td>PO Date : <strong><%=(String)vReqPO.elementAt(2)%></strong> </td>
      <td colspan="2">&nbsp;</td>  
	</tr>    
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<%}%>
  </table>  
<%if(vReqInfo != null && vReqInfo.size() > 1 && bolIsInPO){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR THIS PURCHASE ORDER</strong></div></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(13)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(2))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(6)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(11))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
    </tr>
	<%if(((String)vReqInfo.elementAt(4)).equals("0")){%> 
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></strong></td>
    </tr>
	<%}%>
	<tr> 
      <td height="26" colspan="6">&nbsp;</td>      
    </tr>	
  </table>
  <%if(vReqItemsQtn != null && vReqItemsQtn.size() > 3){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">		
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUISITION ITEM(S) WITH QUOTATION</strong></font></div></td>
    </tr>
    <tr> 
      <td width="5%" height="26" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="4%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="4%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS 
          / DESCRIPTION </strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="21%" class="thinborder"><div align="center"><strong>PRICE QUOTED</strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong>DISCOUNT</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>FINAL PRICE</strong></div></td>
    </tr>
    <%for(iLoop = 0,iCount = 1;iLoop < vReqItemsQtn.size();iLoop+=12,++iCount){%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItemsQtn.elementAt(iLoop)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+2)%> / 
	  <%=(String)vReqItemsQtn.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div><%=(String)vReqItemsQtn.elementAt(iLoop+4)%> 
          <%
			strTemp1 = "";
			strTemp2 = "";
			strErrMsg = "";
			for(; (iLoop + 12) < vReqItemsQtn.size() ;){
			 if(!(((String)vReqItemsQtn.elementAt(iLoop+9)).equals((String)vReqItemsQtn.elementAt(iLoop + 21))))
					break;
			 if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false)+"%<br>&nbsp;";				
          	 }else{
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true)+ 
				astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+11))]+"<br>&nbsp;";
          	 }
			 strErrMsg += (String)vReqItemsQtn.elementAt(iLoop+5) + 
			 			   astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]+ "<br>&nbsp;";
			 strTemp2 += (String)vReqItemsQtn.elementAt(iLoop + 8) + "<br>&nbsp;";%>
          <br>
          <%=(String)vReqItemsQtn.elementAt(iLoop + 12 + 4)%> 
          <%iLoop += 12;}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=strErrMsg + (String)vReqItemsQtn.elementAt(iLoop+5)+
	  		astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]%></div></td>
      <td class="thinborder"><div align="right"> <%=strTemp1%> 
          <%if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false)%>% 
          <%}else{%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true)+
		  astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+11))]%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=strTemp2 + (String)vReqItemsQtn.elementAt(iLoop+8)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="8" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%">
  	<tr>
		<td>&nbsp;</td>
	</tr>
  </table>
  <%}%>
  <%if(vReqItems != null && vReqItems.size() > 3){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">		
    <tr> 
      <td height="25" colspan="9" bgcolor="#B9B292" class="thinborder">
			<div align="center"><font color="#FFFFFF"><strong>
			LIST OF PO ITEM(S)
			</strong></font></div></td>
    </tr>
    <tr> 
      <td width="6%"  height="25"  class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="29%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS 
      / DESCRIPTION </strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong>SUPPLIER CODE 
          </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>BRAND</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT</strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong>EDIT</strong></div></td>
    </tr>
    <%
	String strGrandTotal = null;
	int iLoopCount = 12;
	if(bolAdditionalData && bolIsInPO){
		iLoopCount = 22;
		strGrandTotal = (String)vReqItems.remove(0);
	}
	for(iLoop = 0, iCount = 1;iLoop < vReqItems.size();iLoop+=iLoopCount,iCount++){%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="right"><%=(String)vReqItems.elementAt(iLoop+5)%>&nbsp;</div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+1)%> / <%=(String)vReqItems.elementAt(iLoop+2)%></div></td>
	  <%
	  strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+3),"&nbsp;");
	  if(bolAdditionalData && bolIsInPO)
	  	strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+16),strTemp);
		
	
	  %>
      <td class="thinborder"><div align="left"><%=strTemp%></div></td>
	  <%
	  strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"&nbsp;");
	  if(bolAdditionalData && bolIsInPO)
	  	strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+18),strTemp);
	  %>
      <td class="thinborder"><%=strTemp%></td>
	  <%
	  strTemp = WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;");
	  if(bolAdditionalData && bolIsInPO)
	  	strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+12),strTemp);
	  %>
      <td class="thinborder"><div align="right"><%=strTemp%></div></td>
	  <%
	  	if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0"))
	  		strTemp = "&nbsp;";
		else
			strTemp = CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true);
		
		if(bolAdditionalData && bolIsInPO)
	  		strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+19),strTemp);
	  %>
      <td class="thinborder"><div align="right"><%=strTemp%></div></td>
      <td class="thinborder"> <div align="center"> 
          <%if (vReqPO.elementAt(3) != null){
	  		if(!((String)vReqPO.elementAt(3)).equals("1") && !((String)vReqPO.elementAt(3)).equals("3")){
	  %>
          <a href="javascript:EditPO('<%=vReqItems.elementAt(iLoop)%>','<%=strReqIndex%>','<%=vReqPO.elementAt(0)%>',
	  '<%=vReqItems.elementAt(iLoop+8)%>');"> <img src="../../../images/edit.gif" border="0"></a> 
          <%}else{%>
          APPROVED <%if(((String)vReqPO.elementAt(3)).equals("3")){%> - First Level <%}%>
          <%}
	  }%>
        </div></td>
    </tr>
    <%}%>
    <tr> 
      <td  height="25" colspan="9"  class="thinborder"><strong>TOTAL 
        ITEM(S) :&nbsp;&nbsp;<%=iCount-1%></strong><input type="text" name="req_no2" readonly size="2" 
			style="background-color:#FFFFFF;border-width: 0px;"></td></tr>
  </table>
   <table bgcolor="#FFFFFF" width="100%">
  	<tr>
		<td>&nbsp;</td>
	</tr>
  </table>
  <%if(vAddtlCost != null && vAddtlCost.size() > 2){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>ADDITIONAL 
          COST FOR THIS QUOTATION</strong></font></div></td>
    </tr>
    <tr>
      <td width="35%" class="thinborder"><div align="center"><strong>SUPPLIER 
          NAME</strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>COST 
      NAME </strong></div></td>
      <td width="28%" height="25" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>EDIT</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>DELETE</strong></div></td>
    </tr>
	<%for(iLoop = 0;iLoop < vAddtlCost.size();iLoop+=5){%>
    <tr>
      <td  height="25" class="thinborder"><%=vAddtlCost.elementAt(iLoop+2)%>
	  <%/*strTemp1 = "";
	  	strTemp2 = "";
	  for(;(iLoop+3+5) < vRetResult.size();){
	  		if(!((String)vRetResult.elementAt(iLoop+1)).equals((String)vRetResult.elementAt(iLoop+1+5)))
	  			break;
			strTemp1 += (String)vRetResult.elementAt(iLoop+3)+"<br>";
			strTemp2 += (String)vRetResult.elementAt(iLoop+4)+"<br>";
			iLoop+=5;
	    }*/%>
	  </td>
      <td class="thinborder"><%=/*strTemp1+*/(String)vAddtlCost.elementAt(iLoop+3)%></td>
      <td class="thinborder"><div align="right"><%=/*strTemp2+*/(String)vAddtlCost.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="center">
	  <a href="javascript:QuoteItem('<%=vAddtlCost.elementAt(iLoop+1)%>','<%=strReqIndex%>',
	  '<%=vAddtlCost.elementAt(iLoop)%>')">
	  <img src="../../../images/edit.gif" border="0"></a>
	  </div></td>
      <td class="thinborder"><div align="center">
	  <a href="javascript:DeleteCost('<%=vAddtlCost.elementAt(iLoop)%>',
	  '<%=(String)vAddtlCost.elementAt(iLoop+2)+"("+(String)vAddtlCost.elementAt(iLoop+3)+")"%>');">
	  <img src="../../../images/delete.gif" border="0"></a></div></td>
    </tr>
	<%}%>
  </table>
  <%}%>
  <table bgcolor="#FFFFFF" width="100%">
  	<tr>
		<td>&nbsp;</td>
	</tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="66%" align="center"><a href="javascript:PrintPg('2');"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print PO </font></td> 
      <td width="34%" colspan="5"><div align="center">
	  <a href="javascript:PrintPg('1');">
	  <img src="../../../images/print.gif" border="0"></a><font size="1">click to print this list</font>
	  </div></td>
    </tr>
  </table>
  <%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"><div align="center"> 
          <a href="javascript:CancelClicked();"> 
		  <img src="../../../images/go_back.gif" border="0"> 
          </a>
		  <font size="1">click to go back</font></div></td>
    </tr>
  </table>  
  <%}}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="isForPO" value="1">
  <input type="hidden" name="isForEntry" value="1">
  <input type="hidden" name="saveClicked" value="">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="delete_cost">
	<input type="hidden" name="focus_area" value="<%=WI.fillTextValue("focus_area")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
