<%@ page language="java" import="utility.*,purchasing.PO,purchasing.Requisition,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);	
	


	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	boolean bolIsVMA = strSchCode.startsWith("VMA");
	
	String strTemp = "";
	if(bolIsVMA)
		strTemp = "VMA";
		
	if(WI.fillTextValue("print_pg").length() > 0){

	%>
		<jsp:forward page="purchase_request_print.jsp"/>
	<%return;}
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
<script language="javascript" src="../../../Ajax/ajax.js"></script>


<script language='JavaScript'>



var strSearchType = "";
function AjaxMapName(strType) {
	strSearchType = strType;
	
	var strCompleteName = "";
	var objCOAInput = "";
	if(strType == "2"){
		strCompleteName = document.form_.prepared_by.value;
	   	objCOAInput = document.getElementById("lbl_prepared_by");		
	}else if(strType == "4"){
		strCompleteName = document.form_.approved_by.value;
		objCOAInput = document.getElementById("lbl_approved_by");
	}else if(strType == "5"){
		strCompleteName = document.form_.verified_by.value;
		objCOAInput = document.getElementById("lbl_verified_by");
	}else if(strType == "6"){
		strCompleteName = document.form_.recommending_approval.value;
		objCOAInput = document.getElementById("lbl_recommending_approval");
	}
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	
		
}
function UpdateName(strFName, strMName, strLName) {
	
}
function UpdateNameFormat(strName) {
	if(strSearchType == "2"){
		document.form_.prepared_by.value = strName;
	   	document.getElementById("lbl_prepared_by").innerHTML = "";
	}else if(strSearchType == "4"){
		document.form_.approved_by.value = strName;
	   	document.getElementById("lbl_approved_by").innerHTML = "";	
	}else if(strSearchType == "5"){
		document.form_.verified_by.value = strName;
	   	document.getElementById("lbl_verified_by").innerHTML = "";	
	}else if(strSearchType == "6"){
		document.form_.recommending_approval.value = strName;
	   	document.getElementById("lbl_recommending_approval").innerHTML = "";	
	}
}


function OpenSearch(){
	document.form_.print_pg.value = "";
	var pgLoc = "../requisition/requisition_view_search.jsp?opner_info=form_.req_no&is_supply=form_.is_supply";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearchPO(){
	document.form_.print_pg.value = "";
	var pgLoc = "./purchase_request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageLoad(){
 	document.form_.req_no.focus();
}
function ProceedClicked(){
	document.form_.print_pg.value = "";
	document.form_.save_clicked.value = "";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function UsePONumber(strPONumber){
	document.form_.req_no.value = strPONumber;
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function SavePO(){
	var strPONumber = prompt("Enter PO Number.","Enter PO Number / Click OK to Autogenerate.");
	if(strPONumber == null)
		return;	
	if(strPONumber == "Enter PO Number / Click OK to Autogenerate.")
		strPONumber = "";
	document.form_.po_number.value = strPONumber;
	document.form_.print_pg.value = "";
	document.form_.save_clicked.value = "1";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function EditPONumber(strNumber){
	var strPONumber = prompt("Enter New Number.",strNumber);
	if(strPONumber == null || strPONumber == strNumber )
		return;	
	document.form_.po_number.value = strPONumber;
	document.form_.print_pg.value = "";
	document.form_.edit_po.value = "1";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function CancelRecord(){
	location = './purchase_request.jsp';
}
function PrintPg(){
	document.form_.print_pg.value = 1;
	<%if(strSchCode.startsWith("TSUNEISHI")){%>
	if(confirm("Is General Manager to be printed on PO?")) {
		document.form_.is_gm_in_po.value = '1';
	}
	<%}%>	
	this.SubmitOnce('form_');
}
function checkAll()
{
	var maxDisp = document.form_.row_count.value;

	//unselect if it is unchecked.
	if(!document.form_.selAll.checked)
	{
		for(var i =0; i< maxDisp; ++i)
		{
			eval('document.form_.item'+i+'.checked=false');
		}
		return;
	}
	//this is the time I will check all.
	for(var i =0; i< maxDisp; ++i)
	{
		eval('document.form_.item'+i+'.checked = true');
	}
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdatePOSignatory(){
	var pgLoc = "./purchasing_officers.jsp?sign_type=0";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function UpdatePmtTerm() {
	var strPmtTerm = prompt('Please enter payment term.', '');
	if(strPmtTerm == null || strPmtTerm.length == 0) 
		return;
	document.form_.pmt_term_new.value = strPmtTerm;
	document.form_.update_pmt_term.value = '1';
	document.form_.proceedClicked.value = '1';
	document.form_.print_pg.value = "";
	document.form_.save_clicked.value = "";
	document.form_.submit();
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
								"PURCHASING-PURCHASE ORDER","purchase_request.jsp");
								
	Requisition REQ = new Requisition();
	PO PO = new PO();
	Vector vRetResult = null;	
	Vector vReqInfo = null;
	Vector vReqItems = null;	
	Vector vReqPO = null;
	Vector vAddtlCost = null;
	Vector vPOList = null;
	Vector vSupplierList = null;
	
	
	
	boolean bolIsInPO = false;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strErrMsg = null;
	
	String strInfoIndex = WI.fillTextValue("info_index");
	double dTotalAmount = 0d;
	boolean bolShowPOSign = false; // this is to control wether you want to show PO Signatories... 
	//if(strSchCode.startsWith("AUF"))
	//	bolShowPOSign = true;
		
	String strReqIndex = null;
	int iStart = 0;
//	Vector vSuppliers  = null;

	boolean bolAdditionalData = true; //this this info also when checking vector element
	
	
	if(WI.fillTextValue("save_clicked").equals("1")){			
		vRetResult = PO.operateOnReqInfoPO(dbOP,request,1,"0");
		if(vRetResult == null)
			strErrMsg = PO.getErrMsg();
		else		
			strErrMsg = "PO saved.";
	}
	
	if(WI.fillTextValue("edit_po").length() > 0){			
		if(!PO.updatePONumber(dbOP,request,(String)vReqInfo.elementAt(0)))
			strErrMsg = PO.getErrMsg();
		else		
			strErrMsg = "PO saved.";
	}
	

	if(WI.fillTextValue("proceedClicked").equals("1")){
	
		/*
		I have to check if there's supplier in info provided
		*/
		vSupplierList = PO.showPOSuppliers(dbOP, WI.fillTextValue("req_no"), null);
		if(vSupplierList == null)
			strErrMsg = PO.getErrMsg();
		else{
			vReqInfo = PO.operateOnReqInfo(dbOP,request,3);
			if(vReqInfo == null)
				strErrMsg = PO.getErrMsg();
			else{
				strReqIndex = (String)vReqInfo.elementAt(1);
				vReqPO = PO.operateOnPOInfo(dbOP,request,4,strReqIndex);
				
				if(vReqPO != null && vReqPO.size() > 0){
					//I can update the payment terms her.e. 
					if(WI.fillTextValue("update_pmt_term").length() > 0 && WI.fillTextValue("pmt_term_new").length() > 0) {
						String strSQLQuery = "update PUR_PO_INFO set PAYMENT_TERM = "+
							WI.getInsertValueForDB(WI.fillTextValue("pmt_term_new"), true, null)+
							" where PO_INDEX = "+(String)vReqPO.elementAt(0);
						if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) != -1)
							vReqPO.setElementAt(WI.fillTextValue("pmt_term_new"), 13);
					}
						
				
					bolIsInPO = true;					
					vReqItems = PO.operateOnPOItems(dbOP,request, 4, "", bolAdditionalData);				
				}else{
					vReqItems = PO.operateOnReqItems(dbOP,request,bolAdditionalData, null);				
					
				}
			}
		}

		if((vReqItems == null || vReqItems.size() == 0) && strErrMsg == null)
			strErrMsg = "No item encoded for this Requisition.";	
	}
%>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<form name="form_" method="post" action="./purchase_request_VMA.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PURCHASE </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>ORDER</strong></font><font color="#FFFFFF"><strong> 
          - CREATE PO PAGE ::::</strong></font></div></td>
    </tr>	
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>	
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="28%">Requisition No. / PO No. :</td>
      <td width="25%"> 
	  <%if(vReqPO != null && vReqPO.size() > 2 && bolIsInPO){
	  		if (vReqPO.size()/9 > 1)
				strTemp = WI.fillTextValue("req_no");
			else
				strTemp = (String)vReqPO.elementAt(1);
		}
	  	else if(WI.fillTextValue("req_no").length() > 0)
	  		strTemp = WI.fillTextValue("req_no");
	 	else
	  		strTemp = "";%> 
	<input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="44%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a><font size="1">click 
        to search requisition no.</font></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> 
        <%if(vReqPO == null && (vReqItems != null && vReqItems.size() > 0)){
		  iStart = 1;
	  	  vPOList = (Vector) vReqItems.remove(0); 
	  	  if(vPOList!= null && vPOList.size() > 0){
	  %>
        PO No. : 
        <%  for(int j = 0;j<vPOList.size();j++){
	  %>
	  <a href="javascript:UsePONumber('<%=(String)vPOList.elementAt(j)%>');"><%=(String)vPOList.elementAt(j)%></a> 
	  <%}
	   }	
	  }else{
	  	iStart = 0;
	  }%>
	  </td>
      <td height="25"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="25"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click 
        to search po no.</font></td>
    </tr>
    <%if(vReqPO != null && vReqPO.size() > 2 && bolIsInPO){%>
    <tr> 
      <td height="25"> 
      <td>PO No. : <strong> 
		
		<%=(String)vReqPO.elementAt(1)%>
        <input type="hidden" name="old_po_num" value="<%=(String)vReqPO.elementAt(1)%>">

        </strong></td>
      <td colspan="3">PO Date : <strong><%=(String)vReqPO.elementAt(2)%></strong> </td>
    </tr>
    <tr>
      <td height="18">
      <td>
        <%if(vReqPO != null && vReqPO.size() > 2 && bolIsInPO){%>
		  <%if(vReqPO.size()/9 > 1){%>
			  Select from the PO found
          <%}else{%>
		  <a href="javascript:EditPONumber('<%=(String)vReqPO.elementAt(1)%>');">Click Here to Edit 
          PO Number</a> 
		  <%}%>
        <%}%>
        &nbsp; </td>
      <td colspan="3">&nbsp;</td>
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
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS </strong></div></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong>&nbsp;<%=(String)vReqInfo.elementAt(13)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%">&nbsp; <strong><%=(String)vReqInfo.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong>&nbsp;<%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(2))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong>&nbsp;<%=(String)vReqInfo.elementAt(6)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong>&nbsp;<%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(11))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong>&nbsp;<%=(String)vReqInfo.elementAt(8)%></strong></td>
    </tr>
	<%if(((String)vReqInfo.elementAt(4)).equals("0")){%> 
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong>&nbsp;<%=(String)vReqInfo.elementAt(10)%></strong></td>
      <td>Date Needed :</td>
      <td><strong>&nbsp;<%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong>&nbsp;<%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong>&nbsp;<%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></strong></td>
    </tr>
	<%}%>	
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%if(vReqItems != null && vReqItems.size() > 3){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  	<%if(bolIsInPO){%>	
	<tr>
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF PO ITEMS</strong></font></div></td>
    </tr>
    <%}else if(WI.fillTextValue("is_supply").equals("0") && !bolIsInPO){%>    
    <tr> 
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUESTED ITEMS</strong></font></div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUESTED SUPPLIES</strong></font></div></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="11" class="thinborder">Requested by : <strong><%=(String)vReqInfo.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td width="4%"  height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="31%" class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/DESCRIPTION 
          </strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>BRAND</strong></div></td>
	  <td width="8%" class="thinborder"><div align="center"><strong>DISCOUNT</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      
      <td width="9%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
      <%if(!bolIsInPO && vReqItems != null && vReqItems.size() > 3){%>
      <td width="4%" class="thinborder"><div align="center"><strong>SELECT<br>
          <input type="checkbox" name="selAll" value="0" onClick="checkAll();">
          </strong></div></td>
      <%}%>
    </tr>
    <% 
	String strGrandTotal = null;
	int iLoopCount = 12;
	if(bolAdditionalData){
		iLoopCount = 22;
		strGrandTotal = (String)vReqItems.remove(0);
	}
	int iRowCount = 0;
	for(int iLoop = 0;iLoop < vReqItems.size();iLoop+=iLoopCount,++iRowCount){
		if(vReqItems.elementAt(iLoop+7) != null && !bolAdditionalData)
			dTotalAmount += Double.parseDouble(ConversionTable.replaceString((String)vReqItems.elementAt(iLoop+7),",",""));
	%>
    <tr valign="top"> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+iLoopCount)/iLoopCount%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+5)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+1)%> / <%=(String)vReqItems.elementAt(iLoop+2)%></div></td>
	  <%
	  strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+3),"&nbsp;");
	  if(bolAdditionalData)
	  	strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+16),strTemp);
	  %>
      <td class="thinborder"><div align="left"><%=strTemp%></div></td>
      <%
	  strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"&nbsp;");
	  if(bolAdditionalData)
	  	strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+18),strTemp);
	  %>
	  <td class="thinborder"><%=strTemp%></td>
	  <%
	  strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+10),"&nbsp;");
	  if(bolAdditionalData)
  		strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+14),strTemp);
	  %>
	  <td class="thinborder" align="right"><%=strTemp%></td>
	  <%
	  strTemp = WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;");
	  if(bolAdditionalData)
	  	strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+12),strTemp);
	  %>
      <td class="thinborder"><div align="right"><%=strTemp%></div></td>
	  
	  <%
	  	if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0"))
	  		strTemp = "&nbsp;";
		else
			strTemp = CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true);
		
		if(bolAdditionalData)
	  		strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+19),strTemp);
	  %>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%></div></td>
      <%if(!bolIsInPO && vReqItems != null && vReqItems.size() > 3){%>
      <td class="thinborder"><div align="center"> 
          <input type="hidden" name="item_req_index<%=iRowCount%>" value="<%=(String)vReqItems.elementAt(iLoop+8)%>">
          <input type="checkbox" name="item<%=iRowCount%>" value="1">
        </div></td>
      <%}%>
    </tr>
    <%}%>
    <input type="hidden" name="row_count" value="<%=iRowCount%>">
    <tr> 
      <td height="25" colspan="4" class="thinborder"><div align="left"><strong>TOTAL ITEM(S) : <%=vReqItems.size()/iLoopCount%></strong></div></td>
      <td height="25" colspan="4" class="thinborder"><div align="right"><strong>TOTAL AMOUNT : </strong></div></td>
		  <%
		if(strGrandTotal != null)
		  	strTemp = strGrandTotal;
		else
			strTemp = WI.getStrValue(CommonUtil.formatFloat(dTotalAmount,true),"0");
		  %>
      <td height="25" class="thinborder"><div align="right"><strong><%=WI.getStrValue(strTemp,"0")%></strong></div></td>
      <%if(!bolIsInPO && vReqItems != null && vReqItems.size() > 3){%>
      <td class="thinborder">&nbsp;</td>
      <%}%>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%if(vAddtlCost != null && vAddtlCost.size() > 2){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="3" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>
	  <%if(bolIsInPO){%>
	  ADDITIONAL COST FOR THIS PO
	  <%}else{%>
	  ADDITIONAL COST FOR THIS REQUISITION
	  <%}%>
	  </strong></font></div></td>
    </tr>
    <tr> 
      <td width="35%" class="thinborder"><div align="center"><strong>SUPPLIER 
               NAME</strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong>COST 
                NAME </strong></div></td>
      <td width="25%" height="25" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>     
	<%for(int iLoop = 0;iLoop < vAddtlCost.size();iLoop+=5){%>     
    <tr> 
      <td class="thinborder"><%=vAddtlCost.elementAt(iLoop+2)%>
	  <%strTemp = "";
	  	strErrMsg = "";
	  for(;(iLoop+4+5) < vAddtlCost.size();){
	  		if(!((String)vAddtlCost.elementAt(iLoop+1)).equals((String)vAddtlCost.elementAt(iLoop+1+5)))
	  			break;
			strTemp += (String)vAddtlCost.elementAt(iLoop+3)+"<br>";
			strErrMsg += (String)vAddtlCost.elementAt(iLoop+4)+"<br>";
			iLoop+=5;
	    }%>
	  </td>
      <td class="thinborder"><%=strTemp+(String)vAddtlCost.elementAt(iLoop+3)%></td>
      <td height="25" class="thinborder"><div align="right"><%=strErrMsg+(String)vAddtlCost.elementAt(iLoop+4)%></div></td>
    </tr>
	<%}%>
  </table>
  <%}
  }%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<%
if(vReqItems != null && vReqItems.size() > 0 && bolIsVMA){
%>    
	<tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td width="20%">Prepared By</td>
      <td width="78%" colspan="3"> 
			<% 
			strTemp = "";
			if(vReqPO != null && vReqPO.size() > 1)
	   	  		strTemp = (String)vReqPO.elementAt(15);				
		if(WI.getStrValue(strTemp).length() == 0){
		%> <input name="prepared_by" type="text" size="50" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('2');">
		  &nbsp;
		 <label id="lbl_prepared_by" style="width:400px; position:absolute;"></label>
		 <%}else{%><%=strTemp%><%}%>
		
		 </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Verified By </td>
      <td colspan="3"> 
		<% 
	strTemp = "";
		if(vReqPO != null && vReqPO.size() > 1)
	   	  	strTemp = (String)vReqPO.elementAt(14);
		if(WI.getStrValue(strTemp).length() == 0){
		%> <input name="verified_by" type="text" size="50" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('5');">
		  &nbsp;
		 <label id="lbl_verified_by" style="width:400px; position:absolute;"></label>
		 <%}else{%><%=strTemp%><%}%>
		</td>
    </tr>
	<tr> 
      <td height="26">&nbsp;</td>
      <td>Recommending Approval</td>
      <td colspan="3"> 
			<% 
			strTemp = "";
			if(vReqPO != null && vReqPO.size() > 1)
		   	  	strTemp = (String)vReqPO.elementAt(16);
		if(WI.getStrValue(strTemp).length() == 0){
		%> <input name="recommending_approval" type="text" size="50" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('6');">
		 &nbsp;
		 <label id="lbl_recommending_approval" style="width:400px; position:absolute;"></label>
		  <%}else{%><%=strTemp%><%}%>
		 </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Approved By </td>
      <td colspan="3"> 
			<% 
			strTemp = "";
			if(vReqPO != null && vReqPO.size() > 1)
		   	  	strTemp = (String)vReqPO.elementAt(17);	
			if(WI.getStrValue(strTemp).length() == 0){
		%> <input name="approved_by" type="text" size="50" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('4');">
		 &nbsp;
		 <label id="lbl_approved_by" style="width:400px; position:absolute;"></label>
		 <%}else{%><%=strTemp%><%}%>
		 </td>
    </tr>
	
	<%}
	
	if(!bolIsInPO && vReqItems != null && vReqItems.size() > 3){%>
    <tr>

	<%if(bolShowPOSign){%>
	<%
		strTemp = WI.fillTextValue("po_signatory");
	%>
      <td height="25" colspan="3">PURCHASING OFFICER: 
        <select name="po_signatory">
          <option value="">Select signatory</option>
          <%//=dbOP.loadCombo("user_table.user_index","FNAME+ ' ' + MNAME + ' ' + LNAME", " from user_table " +%>
					<%=dbOP.loadCombo("user_table.user_index","FNAME+ ' ' + LNAME", " from user_table " +
		  " join pur_po_officers on(pur_po_officers.user_index = user_table.user_index)" +
		  " where user_table.is_valid = 1 and  pur_po_officers.is_valid = 1 and sign_type = 0 order by lname", strTemp, false)%> 
		</select>
        <a href='javascript:UpdatePOSignatory()'><img src="../../../images/update.gif" width="60" height="26" border="0" id="compute"></a>      </td>
    </tr>
	<%}%>
    <tr>
	   <%
			strTemp = WI.fillTextValue("po_date");	
			if(strTemp.length() == 0)	
				strTemp = WI.getTodaysDate(1);
			
		%>					
      <td height="25" colspan="3">PO Date : 
        <input name="po_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.po_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
	
    <tr> 
      <td height="25" colspan="3"><div align="center"> <a href="javascript:SavePO();"> <img src="../../../images/save.gif" border="0"></a> 
	  <font size="1">click to save PO</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
	  <font size="1">click to cancel</font></div></td>
    </tr>
    <%}else if(bolIsInPO && vReqItems != null && vReqItems.size() > 3){
		//vRetResult = PO.showPOSuppliers(dbOP,(String)vReqInfo.elementAt(0));
		strTemp = WI.fillTextValue("print_supplier");%>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Payment Term (optional) : 
	  <%=WI.getStrValue(vReqPO.elementAt(13), "Not Set")%>
	  <a href="javascript:UpdatePmtTerm();">
		<img src="../../../images/update.gif" border="0">	  </a>	  	</td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><div align="center"><a href="javascript:PrintPg();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print PO</font> &nbsp;&nbsp;For Supplier:&nbsp; 
          <select name="print_supplier">
            <option value="">All</option>
            <%for(int iLoop = 0;iLoop < vSupplierList.size();iLoop+=2){
		  		if(strTemp.equals((String)vSupplierList.elementAt(iLoop))){%>
            <option value="<%=vSupplierList.elementAt(iLoop)%>" selected><%=vSupplierList.elementAt(iLoop+1)%></option>
            <%}else{%>
            <option value="<%=vSupplierList.elementAt(iLoop)%>"><%=vSupplierList.elementAt(iLoop+1)%></option>
            <%}}%>
          </select>
        </div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
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
    
  <input type="hidden" name="save_clicked">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="po_number">
  <input type="hidden" name="edit_po">
  <input type="hidden" name="update_pmt_term" value="">
  <input type="hidden" name="pmt_term_new" value="">
  
  <input type="hidden" name="is_gm_in_po">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
