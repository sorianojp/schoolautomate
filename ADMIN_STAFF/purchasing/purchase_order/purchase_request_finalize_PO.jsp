<%@ page language="java" import="utility.*,purchasing.PO,purchasing.Requisition,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);

	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update PO request</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
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
	location = "./purchase_request_update_status.jsp";
}
function OpenSearchPO(){
	document.form_.print_pg.value = "";
	var pgLoc = "./purchase_request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPg(){
	document.form_.print_pg.value = 1;
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	double dTotalAmount = 0d;
	
//add security here.

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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-PURCHASE ORDER-Finalize PO","purchase_request_finalize_PO.jsp");
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
	
	Requisition REQ = new Requisition();
	PO PO = new PO();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vReqPO = null;
	Vector vSuppliers = null;
	Vector vAddtlCost = null;
	boolean bolIsInPO = false;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strReqIndex = WI.fillTextValue("req_index");
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = PO.operateOnReqInfo(dbOP,request,3);
		//System.out.println("vReqInfo " + vReqInfo);
		if(vReqInfo == null){
			strErrMsg = PO.getErrMsg();
		}else{			
			strReqIndex = (String)vReqInfo.elementAt(1);
			if(WI.fillTextValue("saveClicked").equals("1")){
//				System.out.println("Separation!");
				if(PO.operateOnFinalPO(dbOP,request) != null)
				strErrMsg = "Saved!";					
			}			
		}
		
		if (vReqInfo != null && vReqInfo.size() > 0){
			if ((String)vReqInfo.elementAt(0) == null){
				vSuppliers = PO.showPOSuppliers(dbOP,strReqIndex);
			}else{
				//System.out.println("Supplier 2");
				vSuppliers = PO.showPOSuppliers(dbOP,(String)vReqInfo.elementAt(0));
			}
		}
		
		if (WI.fillTextValue("print_supplier").length() > 0){			
			if(vReqInfo != null && vReqInfo.size() > 1){
				vReqPO = PO.operateOnPOInfo(dbOP,request,4,strReqIndex);							
				if(vReqPO != null){
					bolIsInPO = true;			
					vReqItems = PO.operateOnPOItems(dbOP,request,4);
				}else{
					strErrMsg = PO.getErrMsg();
				}			
			}
		
//			if((vReqItems == null || vReqItems.size() < 1) && strErrMsg == null)
//				strErrMsg = "No item encoded for this Requisition.";
		}
	}	
	
if(WI.fillTextValue("print_pg").equals("1")){%>
<jsp:forward page="purchase_request_print.jsp"/>
<%return;}
%>	
<form name="form_" method="post" action="./purchase_request_finalize_PO.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PURCHASE </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>ORDER</strong></font><font color="#FFFFFF"><strong> 
          - PRINT FINAL PO PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="28%"> PO No. :</td>
      <td width="25%"> <%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp = WI.fillTextValue("req_no");
	  }else{
	  		strTemp = "";
      }%>
      <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
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
      <td>PO No. : <strong><%=(String)vReqPO.elementAt(1)%><input type="hidden" name="old_po_num" value="<%=(String)vReqPO.elementAt(1)%>"></strong></td>
      <td>PO Date : <strong><%=(String)vReqPO.elementAt(2)%></strong> </td>
      <td colspan="2">&nbsp;</td>	  
	</tr>    
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<%}%>
  </table>  
<%if(vReqInfo != null && vReqInfo.size() > 1){%>
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
  </table>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
		<%
		strTemp = WI.fillTextValue("print_supplier");
		%>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<strong>For Supplier:</strong>&nbsp; 
        <%if (vSuppliers != null && (vSuppliers.size()/2 > 1)){%>	
		<select name="print_supplier" onChange="ProceedClicked();">
          <option value="">Select Supplier</option>
          <%for(int iLoop = 0;iLoop < vSuppliers.size();iLoop+=2){
		  if(strTemp.equals((String)vSuppliers.elementAt(iLoop))){%>
          <option value="<%=vSuppliers.elementAt(iLoop)%>" selected><%=vSuppliers.elementAt(iLoop+1)%></option>
          <%}else{%>
          <option value="<%=vSuppliers.elementAt(iLoop)%>"><%=vSuppliers.elementAt(iLoop+1)%></option>
          <%}}%>
        </select>
        <font size="1">For PO with more than one Supplier: A separate PO would 
        be created for the selected supplier.</font>
		<%}else if (vSuppliers != null && (vSuppliers.size() == 2)){%>
        <strong><%=(String)vSuppliers.elementAt(1)%></strong> 
        <input type="hidden" name="print_supplier" value="<%=(String)vSuppliers.elementAt(0)%>">
		<%}else{%>
		&nbsp;
		<%}%>
	   </td>		
    </tr>
  </table>
  <%if(vReqItems != null && vReqItems.size() > 3){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="100%" height="25" bgcolor="#B9B292" colspan="8" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF PO ITEMS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="8%" height="25" align="center" class="thinborder"><strong>ITEM#</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="26%" align="center" class="thinborder"><strong>ITEM / PARTICULARS 
          / DESCRIPTION </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>SUPPLIER 
          CODE </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>BRAND</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>AMOUNT</strong></td>
    </tr>
    <%for(int iLoop = 0;iLoop < vReqItems.size();iLoop+=12){%>
    <tr> 
      <td  height="25" align="center" class="thinborder"><%=(iLoop+12)/12%></td>
      <td align="center" class="thinborder"><%=(String)vReqItems.elementAt(iLoop+5)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop+6)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop+1)%> / <%=(String)vReqItems.elementAt(iLoop+2)%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+3),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"&nbsp;")%></td>
      <td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%></td>
      <% if(vReqItems.elementAt(iLoop+7) != null){
		  dTotalAmount += Double.parseDouble(ConversionTable.replaceString((String)vReqItems.elementAt(iLoop+7),",",""));	  }
	  %>
      <td align="right" class="thinborder"> 
        <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
        &nbsp; 
        <%}else{%>
        <%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%> 
        <%}%>        </td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><strong>TOTAL 
        ITEM(S) : <%=vReqItems.size()/12%></strong></td>
      <td height="25" colspan="3" align="right" class="thinborder"><strong>TOTAL 
        AMOUNT : </strong></td>
      <td  height="25" align="right" class="thinborder"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dTotalAmount,true),"0")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <%
	  strTemp = WI.fillTextValue("print_supplier");
	  %>
      <td height="25" colspan="5"><div align="center"> 
	  	  <%if(!(vSuppliers.size() == 2)){%>
		  <a href="javascript:SaveClicked();"> 
          <img src="../../../images/save.gif" border="0"></a> <font size="1">click 
          to save as different PO</font>
		  <%}else{%>
		  <a href="javascript:PrintPg();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font> 
		  <%}%>
		  <a href="javascript:CancelClicked();"><img src="../../../images/cancel.gif" border="0"> 
          </a> <font size="1">click to cancel</font> </div></td>
    </tr>
    <tr> 
      <td width="1%" height="18">&nbsp;</td>
      <td width="99%" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <%}else{%>
  <%if (WI.fillTextValue("print_supplier").length() < 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"><div align="center"><font size="1"> 
          <a href="javascript:CancelClicked();"> 
		  <img src="../../../images/go_back.gif" border="0"> 
          </a>click to go back</font></div></td>
    </tr>
  </table>  
  <%}}}%>
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
  <input type="hidden" name="saveClicked" value="">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="req_index" value="<%=strReqIndex%>">
  <input type="hidden" name="is_final" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
