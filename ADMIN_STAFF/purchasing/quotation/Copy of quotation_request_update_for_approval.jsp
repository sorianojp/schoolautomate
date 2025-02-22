<%@ page language="java" import="utility.*,purchasing.Quotation,purchasing.Requisition,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Quotation request</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function ViewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageLoad(){
 	document.form_.req_no.focus();
}
function ReloadPage(){
	this.SubmitOnce('form_');
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function SaveClicked(){
	document.form_.saveClicked.value = "1";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function CancelClicked(){
	location = "./quotation_request_update_for_approval.jsp";
}
function OpenSearch(){
	document.form_.print_pg.value = "";
	var pgLoc = "../requisition/requisition_view_search.jsp?opner_info=form_.req_no&is_supply=form_.is_supply";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}function PrintPg(){
	document.form_.print_pg.value = 1;
	this.SubmitOnce('form_');
}
function UpdatePOSignatory(){
	var pgLoc = "../purchase_order/purchasing_officers.jsp?sign_type=1";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%
	if(WI.fillTextValue("print_pg").equals("1")){%>
		<jsp:forward page="purchase_request_print.jsp"/>
	<%return;}
	
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	double dTotalAmount = 0d;
	double dGrandTotal = 0d;
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-UPDATE QUOTATION STATUS"),"0"));
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
								"Admin/staff-PURCHASING-UPDATE QUOTATION STATUS-Update QUOTATION Status","quotation_request_update_for_approval.jsp");
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
	
	Requisition REQ = new Requisition();
	Quotation QTN = new Quotation();
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vSuppliers = null;
	Vector vAddtlCost = null;
	Vector vReqItemsQtn = null;
	boolean bolIsApproved = false;
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strReqIndex = WI.fillTextValue("req_index");
	String strSchCode = dbOP.getSchoolIndex();
	String strTemp1 = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strStatus = null;
	int iLoop = 0;
	int iCount = 0;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		if(WI.fillTextValue("req_no").length() == 0){
		strErrMsg = "Please enter Requisition Number";
		}else{
		vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null){
			strErrMsg = REQ.getErrMsg();
		}else{
			strReqIndex = (String)vReqInfo.elementAt(1);
			if(WI.fillTextValue("saveClicked").equals("1")){				
				if(QTN.approveReqBudget(dbOP,request))
					strErrMsg = "Status Saved.";
				else
					strErrMsg = QTN.getErrMsg();
			}
		}
		
		if (vReqInfo != null && vReqInfo.size() > 0){
			if ((String)vReqInfo.elementAt(0) == null){
				vSuppliers = QTN.showQTNSuppliers(dbOP,strReqIndex);
			}else{
				//System.out.println("Supplier 2");
				vSuppliers = QTN.showQTNSuppliers(dbOP,(String)vReqInfo.elementAt(0));
			}
		}
		
		if(vReqInfo != null && vReqInfo.size() > 1){
			if (vReqInfo.elementAt(0) != null){					
					//System.out.println("Supplier 2");					
				strReqIndex = (String)vReqInfo.elementAt(0);
			}
			if(WI.fillTextValue("print_supplier").length() == 0){
				vReqItemsQtn = QTN.getRequestItems(dbOP,request,strReqIndex);
				//System.out.println("vReqItemsQtn " + vReqItemsQtn);
			}else{
				vReqItemsQtn = QTN.getRequestItems(dbOP,request,strReqIndex);
				//vReqItems = 
			}
		}
		strStatus = dbOP.mapOneToOther("PUR_REQ_BUDGET_STAT","is_valid","1","BUDGET_STATUS",
		" and REQUISITION_INDEX = "+strReqIndex);
		if(strStatus != null && strStatus.length() > 0){
			if(strStatus.equals("1")){
				bolIsApproved = true;
			}
		}
			
//		vAddtlCost = PO.showAdditionalCost(dbOP,strReqIndex + strTemp);
//		if(vAddtlCost == null)
//			strErrMsg = PO.getErrMsg();
		
//		if((vReqItems == null || vReqItems.size() < 1) && strErrMsg == null)
//			strErrMsg = "No item encoded for this Requisition.";
		}
	}// end if WI.fillTextValue("proceedClicked").equals("1")){
	
%>	
<form name="form_" method="post" action="quotation_request_update_for_approval.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          QUOTATION - UPDATE/PRINT REQUISITION FOR APPROVAL PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="28%"> Requisition No. :</td>
      <td width="25%"> <%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp = WI.fillTextValue("req_no");
	  }else{
	  		strTemp = "";
      }%> <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="44%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a><font size="1">click 
        to search requisition no.</font></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>

  </table>  
<%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR BUDGET 
          APPROVAL </strong></div></td>
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
      <td height="30">&nbsp;</td>
      <td>Non-Acad. Office/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>College/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}%>	
  </table>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table> 
  <%if(!strSchCode.startsWith("UI")){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
		<%
		strTemp = WI.fillTextValue("print_supplier");
		%>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<strong>For Supplier:</strong>&nbsp; 
        <%if (vSuppliers != null && (vSuppliers.size()/2 > 1)){%>
        <select name="print_supplier" onChange="ProceedClicked();">
          <option value="">ALL</option>
          <%for(iLoop = 0;iLoop < vSuppliers.size();iLoop+=2){
		  if(strTemp.equals((String)vSuppliers.elementAt(iLoop))){%>
          <option value="<%=vSuppliers.elementAt(iLoop)%>" selected><%=vSuppliers.elementAt(iLoop+1)%></option>
          <%}else{%>
          <option value="<%=vSuppliers.elementAt(iLoop)%>"><%=vSuppliers.elementAt(iLoop+1)%></option>
          <%}}%>
        </select><br>
        &nbsp;&nbsp;&nbsp;&nbsp;
	<%}else if (vSuppliers != null && (vSuppliers.size() == 2)){%>
        <strong> <%=(String)vSuppliers.elementAt(1)%>.</strong> 
		<%if(WI.fillTextValue("print_supplier").length() == 0){%>
		<font size="1">Please click proceed again to display details </font>
		<%}%>
		<input type="hidden" name="print_supplier" value="<%=(String)vSuppliers.elementAt(0)%>">
		<%}else{%>
        No Supplier Found for this requisition. 
        <%}%>
	   </td>		
    </tr>
  </table>     
  <%}%>
  <%if(vReqItems != null && vReqItems.size() > 3){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" bgcolor="#B9B292" colspan="8" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUESTED ITEMS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="6%" height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="35%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS 
          / DESCRIPTION </strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>BRAND</strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%for(iLoop = 0;iLoop < vReqItems.size();iLoop+=10){%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=(iLoop+10)/10%></div></td>
      <td class="thinborder"><div align="right"><%=(String)vReqItems.elementAt(iLoop+5)%>&nbsp;</div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+1)%> / <%=(String)vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+3),"&nbsp;")%></div></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%>&nbsp;</div></td>
      <% if(vReqItems.elementAt(iLoop+7) != null){
		  dTotalAmount += Double.parseDouble(ConversionTable.replaceString((String)vReqItems.elementAt(iLoop+7),",",""));	  }
	  %>
      <td class="thinborder"><div align="right"> 
          <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
          &nbsp; 
          <%}else{%>
          <%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%> 
          <%}%>
          &nbsp;</div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vReqItems.size()/10%></strong></div></td>
      <td height="25" colspan="3" class="thinborder"><div align="right"><strong>TOTAL 
          AMOUNT : </strong></div></td>
      <td  height="25" class="thinborder"><div align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dTotalAmount,true),"0")%>&nbsp;</strong></div></td>
    </tr>
  </table>
  <%}%>
  <%if(vAddtlCost != null && vAddtlCost.size() > 2){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="20" colspan="3" class="thinborder"><div align="center"><font color="#FFFFFF"><strong> 
          ADDITIONAL COST FOR THIS REQUISITION</strong></font></div></td>
    </tr>
    <%for(iLoop = 0;iLoop < vAddtlCost.size();iLoop+=5){%>
    <tr> 
      <td width="35%" class="thinborder"><%=vAddtlCost.elementAt(iLoop+2)%> <%strTemp = "";
	  	strErrMsg = "";
	  for(;(iLoop+4+5) < vAddtlCost.size();){
		if(!((String)vAddtlCost.elementAt(iLoop+1)).equals((String)vAddtlCost.elementAt(iLoop+1+5)))
			break;
	    
		if(vAddtlCost.elementAt(iLoop+4) != null){
		  dGrandTotal += Double.parseDouble(ConversionTable.replaceString((String)vAddtlCost.elementAt(iLoop+4),",",""));
	    }
			
		strTemp += (String)vAddtlCost.elementAt(iLoop+3)+"<br>";
		strErrMsg += (String)vAddtlCost.elementAt(iLoop+4)+"<br>";
		iLoop+=5;			
	    }%> </td>
      <td width="19%" class="thinborder"><%=strTemp+(String)vAddtlCost.elementAt(iLoop+3)%></td>
	  <% if(vAddtlCost.elementAt(iLoop+4) != null){
		  dGrandTotal += Double.parseDouble(ConversionTable.replaceString((String)vAddtlCost.elementAt(iLoop+4),",",""));	  
	   }%>
      <td width="25%" height="25" class="thinborder"><div align="right"><%=strErrMsg+(String)vAddtlCost.elementAt(iLoop+4)%></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <%if(vReqItemsQtn != null && vReqItemsQtn.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="9" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUESTED ITEMS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="5%" height="26" class="thinborder"><div align="center"><font size="1"><strong>QTY</strong></font></div></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>UNIT</strong></font></div></td>
      <td width="22%" class="thinborder"><div align="center"><font size="1"><strong>ITEM 
          / PARTICULARS / DESCRIPTION </strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">BRAND</font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>SUPPLIER 
          CODE </strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>PRICE 
          QUOTED</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>DISCOUNT</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>UNIT 
          PRICE</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>TOTAL 
          AMOUNT</strong></font></div></td>
    </tr>
    <%//System.out.println("size " + vReqItemsQtn.size());
	for(iLoop = 0,iCount = 0;iLoop < vReqItemsQtn.size();iLoop+=11,++iCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=vReqItemsQtn.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItemsQtn.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItemsQtn.elementAt(iLoop+3)%> / <%=vReqItemsQtn.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><%=WI.getStrValue(vReqItemsQtn.elementAt(iLoop+10),"&nbsp;")%></td>
      <td class="thinborder"><div align="center"><%=vReqItemsQtn.elementAt(iLoop+5)%> 
          <%
			strTemp1 = "";
			strTemp2 = "";
			strTemp3 = "";
			strErrMsg = "";			
			for(; (iLoop + 11) < vReqItemsQtn.size() ;){
			//System.out.println("iLoop " +(String)vReqItemsQtn.elementAt(iLoop));
			//System.out.println("iLoop11 " +(String)vReqItemsQtn.elementAt(iLoop + 11));
			 if(!(((String)vReqItemsQtn.elementAt(iLoop)).equals((String)vReqItemsQtn.elementAt(iLoop + 11))))
					break;			 
			 strErrMsg += (String)vReqItemsQtn.elementAt(iLoop+6)+ "<br>";
			 strTemp1 += (String)vReqItemsQtn.elementAt(iLoop+7)+ "<br>";
			 strTemp2 += (String)vReqItemsQtn.elementAt(iLoop+8)+ "<br>";
			 strTemp3 += (String)vReqItemsQtn.elementAt(iLoop+9)+ "<br>";%>
          <br>
          <%=(String)vReqItemsQtn.elementAt(iLoop + 11 + 4)%> 
          <%iLoop += 11;}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=strErrMsg + (String)vReqItemsQtn.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="right"> <%=strTemp1 + (String)vReqItemsQtn.elementAt(iLoop+7)%></div></td>
      <td class="thinborder"><div align="right"><%=strTemp2 + (String)vReqItemsQtn.elementAt(iLoop+8)%></div></td>
      <td class="thinborder"><div align="right"><%=strTemp3 + (String)vReqItemsQtn.elementAt(iLoop+9)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount%> 
          <input type="hidden" name="num_of_items" value="<%=iCount%>">
          </strong></div></td>
    </tr>
  </table>
  <%}// end for vReqItemsQtn != null %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <%strTemp = WI.fillTextValue("print_supplier");%>
      <td height="18" colspan="5"><div align="left"></div></td>
    </tr>
    <tr> 
      <td width="5%" height="25"><div align="center"></div></td>
      <td width="12%">BUDGET : </td>
	  <% if(WI.fillTextValue("status").length() > 0)
	  		strTemp = WI.fillTextValue("status");
	     else if(strStatus != null)
			strTemp = strStatus;		 
		 else
			strTemp = "0";
	  %>
      <td width="31%"> <select name="budget">
          <option value="1">Approved</option>
          <%if(strTemp.equals("2")){%>
          <option value="2" selected>Pending</option>
          <option value="0">Disapproved</option>
          <%}else if(strTemp.equals("0")){%>
          <option value="2">Pending</option>
          <option value="0" selected>Disapproved</option>
          <%}else{%>
          <option value="2">Pending</option>
          <option value="0">Disapproved</option>
          <%}%>
        </select></td>
      <td width="10%">Signatory : </td>
      <td width="42%"><select name="po_signatory">
          <option value="">Select signatory</option>
          <%=dbOP.loadCombo("user_table.user_index","FNAME+ ' ' + MNAME + ' ' + LNAME", " from user_table " +
		  " join pur_po_officers on(pur_po_officers.user_index = user_table.user_index)" +
		  " where user_table.is_valid = 1 and  pur_po_officers.is_valid = 1 and sign_type = 1 order by lname", strTemp, false)%> 
        </select> <a href='javascript:UpdatePOSignatory()'><img src="../../../images/update.gif" width="60" height="26" border="0" id="compute"></a><font size="1">click 
        to update list of signatory</font></td>
    </tr>
    <tr> 
      <td height="25" rowspan="2">&nbsp;</td>
      <td height="30">Date :</td>
      <td> 
        <input name="date_budget" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_budget');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td>Remarks :</td>
      <td rowspan="2"><textarea name="remarks" cols="32" rows="3"></textarea></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%if(!bolIsApproved){%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3"><a href="javascript:SaveClicked();"><img src="../../../images/save.gif" border="0"></a> 
        <font size="1">click to SAVE </font> <a href="javascript:PrintPg();"> 
        </a> <a href="javascript:CancelClicked();"><img src="../../../images/cancel.gif" border="0"> 
        </a> <font size="1">click to CANCEL</font></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="46">&nbsp;</td>
      <td><div align="center"> </div></td>
      <td colspan="3"><a href="javascript:PrintPg();"> <img src="../../../images/print.gif" border="0"></a> 
        <font size="1">click to print requisiton for budget office approval</font></td>
    </tr>
    <%}%>
  </table>  
  <%if((vReqInfo != null && vReqInfo.size() > 1) || (vReqItemsQtn != null && vReqItemsQtn.size() > 0)){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"><div align="center"><font size="1"> 
          <a href="javascript:CancelClicked();"> </a><a href="javascript:CancelClicked();"><img src="../../../images/go_back.gif" border="0"></a><a href="javascript:CancelClicked();"> 
          </a>click to go back</font></div></td>
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
  <input type="hidden" name="saveClicked" value="">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="req_index" value="<%=strReqIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
