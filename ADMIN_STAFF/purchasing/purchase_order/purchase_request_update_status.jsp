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
	
	boolean bolIsICA = false;
	String strInfo5 = (String)request.getSession(false).getAttribute("info5");
	if(strInfo5 != null && strInfo5.startsWith("ICA") && strSchCode.startsWith("EAC"))
		bolIsICA = true;
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
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>

function AjaxMapName() {
	var strCompleteName = document.form_.approved_by.value;
	var objCOAInput = document.getElementById("lbl_approved_by");	
	
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
	document.form_.approved_by.value = strName;
   	document.getElementById("lbl_approved_by").innerHTML = "";	
}


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
	document.form_.saveClicked.value = "";
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-UPDATE PO STATUS"),"0"));
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
								"Admin/staff-PURCHASING-UPDATE PO STATUS-Update PO Status","purchase_request_update_status.jsp");
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
	PO PO = new PO();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vReqPO = null;
	Vector vSuppliers = null;
	Vector vAddtlCost = null;
	boolean bolIsInPO = false;
	boolean bolSeparatePOLater = false;
	boolean bolIsApproved = false;
	boolean bolAdditionalData = true;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strReqIndex = WI.fillTextValue("req_index");

	Vector vPoNumber = null;
	
	if (strSchCode.startsWith("UI"))
		bolSeparatePOLater = true;
	
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		PO.createExistPreloadFund(dbOP);
		if(WI.fillTextValue("req_no").length() == 0){
		strErrMsg = "Please enter PO";
		}else{
		vReqInfo = PO.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null){
			strErrMsg = PO.getErrMsg();
		}else{
			strReqIndex = (String)vReqInfo.elementAt(1);			
			if(WI.fillTextValue("saveClicked").equals("1")){				
				if (!bolSeparatePOLater){
					vPoNumber = PO.operateOnFinalPO(dbOP,request);
					if(vPoNumber != null && vPoNumber.size() > 0)
						strErrMsg = "Status Finalized.";
					else
						strErrMsg = PO.getErrMsg();
				}else{
					if(PO.operateOnReqStatusPO(dbOP,request)) {
						strErrMsg = "Status Saved.";
					}
					else
						strErrMsg = PO.getErrMsg();				
				}
			}			
		}
		
		if (vReqInfo != null && vReqInfo.size() > 0){
			if ((String)vReqInfo.elementAt(0) == null)
				vSuppliers = PO.showPOSuppliers(dbOP,strReqIndex);
			else
				vSuppliers = PO.showPOSuppliers(dbOP,(String)vReqInfo.elementAt(0));			
		}		
		
	//	if (WI.fillTextValue("print_supplier").length() > 0 || bolSeparatePOLater){		
			if(vReqInfo != null && vReqInfo.size() > 1){
				vReqPO = PO.operateOnPOInfo(dbOP,request,4,strReqIndex);							
				if(vReqPO != null && vReqPO.size() > 0){
					bolIsInPO = true;								
					//System.out.println("vSuppliers " +vSuppliers);
					strTemp = WI.fillTextValue("print_supplier");
					if(strTemp.length() == 0 && vSuppliers != null && vSuppliers.size() > 0)
						strTemp = (String)vSuppliers.elementAt(0);
						
					vReqItems = PO.operateOnPOItems(dbOP,request,4, strTemp, bolAdditionalData);
					if(vReqItems == null)
						strErrMsg = PO.getErrMsg();
					
					if (vReqPO.elementAt(3) != null && ((String)vReqPO.elementAt(3)).equals("1"))
						bolIsApproved = true;
				}else
					strErrMsg = PO.getErrMsg();
					
			}
	//	}
	
		strTemp = "";
		if(WI.fillTextValue("print_supplier").length() > 0)
			strTemp = " and SUPPLIER_INDEX = "+ WI.fillTextValue("print_supplier");	
			
		if(vReqInfo != null && vReqInfo.size() > 1){					
			vAddtlCost = PO.showAdditionalCost(dbOP,strReqIndex + strTemp);
			if(vAddtlCost == null)
				strErrMsg = PO.getErrMsg();
		}
		
//		if((vReqItems == null || vReqItems.size() < 1) && strErrMsg == null)
//			strErrMsg = "No item encoded for this Requisition.";
		}
	}// end if WI.fillTextValue("proceedClicked").equals("1")){	
	
	int iElemCount = 12;
	if(bolAdditionalData)
		iElemCount = 22;
		
	if(vSuppliers == null)
		vSuppliers = new Vector();

boolean bolIs2ndLevelApprovalPOAndRequisition = false;
boolean bolShowUpdatePOStatFinalApproval = false;//for the schools having 2nd level approval of requisition
String strSQLQuery = "select prop_val from read_property_file where prop_name = 'ENABLE_2ND_APPROVAL_PO'";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null && (strSQLQuery.equals("2") || strSQLQuery.equals("3")) ) {//1 = requisition, 2= po, 3 = all.
	bolIs2ndLevelApprovalPOAndRequisition = true;
	//I have to check if user is authenticated to view final approval of po and requisition
	String strMainIndex = "select module_index from module where module_name = 'purchasing'";
	strMainIndex = dbOP.getResultOfAQuery(strMainIndex, 0);
	strSQLQuery = "select sub_mod_index from sub_module where module_index = "+strMainIndex+
					" and sub_mod_name = 'Final Approval of PO'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null) {
		strSQLQuery = "select auth_list_index from user_auth_list where is_valid = 1 and sub_mod_index = "+
						strSQLQuery+" and user_index = "+(String)request.getSession(false).getAttribute("userIndex");
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null)
			bolShowUpdatePOStatFinalApproval = true;
	}
}
%>	
<form name="form_" method="post" action="./purchase_request_update_status.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PURCHASE </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>ORDER</strong></font><font color="#FFFFFF"><strong> 
          - UPDATE PO STATUS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="28%"> PO No. :</td>
      <td width="25%"> 
			<%
				if(vPoNumber != null && vPoNumber.size() > 0){
					strTemp = (String)vPoNumber.elementAt(0);
				}else if(WI.fillTextValue("req_no").length() > 0){
		  		strTemp = WI.fillTextValue("req_no");
	 		  }else{
		  		strTemp = "";
      	}
			%>
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
  <%if(!strSchCode.startsWith("UI")){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 		
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<strong>For Supplier:</strong>&nbsp; 
        <%if (vSuppliers != null && vSuppliers.size() > 0){%>
        <select name="print_supplier" onChange="ProceedClicked();">
          <%
		  strTemp = WI.fillTextValue("print_supplier");
		  for(int iLoop = 0;iLoop < vSuppliers.size();iLoop+=2){
		  if(strTemp.equals((String)vSuppliers.elementAt(iLoop))){%>
          <option value="<%=vSuppliers.elementAt(iLoop)%>" selected><%=vSuppliers.elementAt(iLoop+1)%></option>
          <%}else{%>
          <option value="<%=vSuppliers.elementAt(iLoop)%>"><%=vSuppliers.elementAt(iLoop+1)%></option>
          <%}}%>
        </select><br>
        &nbsp;&nbsp;&nbsp;&nbsp;<font size="1">For PO with more than one Supplier: A new PO would be created 
        for the selected supplier.</font> 
        <%}else if (vSuppliers != null && (vSuppliers.size() == 2)){%>
        <strong> <%=(String)vSuppliers.elementAt(1)%>.</strong> 
		<%if(WI.fillTextValue("print_supplier").length() == 0){%>
		<font size="1">Please click proceed again to display details </font>
		<%}%>
		<input type="hidden" name="print_supplier" value="<%=(String)vSuppliers.elementAt(0)%>">
		<%}else{%>
		No Supplier Found for this PO.
		<%}%>
      </td>		
    </tr>
  </table>     
  <%}%>
  <%if(vReqItems != null && vReqItems.size() > 3){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" bgcolor="#B9B292" colspan="9" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF PO ITEMS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="3%" height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="29%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS 
          / DESCRIPTION </strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>BRAND</strong></div></td>
	  <td width="11%" class="thinborder"><div align="center"><strong>DISCOUNT</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      
      <td width="11%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%
	String strGrandTotal = null;
	if(bolAdditionalData && bolIsInPO)	
		strGrandTotal = (String)vReqItems.remove(0);
	
	for(int iLoop = 0;iLoop < vReqItems.size();iLoop+=iElemCount){
		if(vReqItems.elementAt(iLoop+7) != null)
			dTotalAmount += Double.parseDouble(ConversionTable.replaceString((String)vReqItems.elementAt(iLoop+7),",",""));
	%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=(iLoop+12)/12%></div></td>
      <td class="thinborder"><div align="right"><%=(String)vReqItems.elementAt(iLoop+5)%>&nbsp;</div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+1)%> / <%=(String)vReqItems.elementAt(iLoop+2)%></div></td>
	  <%
	  strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+3),"&nbsp;");
	  if(bolAdditionalData && bolIsInPO)
	  	strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+16),strTemp);
	  %>
      <td class="thinborder"><div><%=strTemp%></div></td>
	  <%
	  strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"&nbsp;");
	  if(bolAdditionalData && bolIsInPO)
	  	strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+18),strTemp);
	  %>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
	  <%
	  strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+10),"&nbsp;");
	    if(bolAdditionalData && bolIsInPO)
  		strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+14),strTemp);
	  %>
	  <td class="thinborder" align="right"><%=strTemp%></td>
	   <%
	  strTemp = WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;");
	  if(bolAdditionalData && bolIsInPO)
	  	strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+12),strTemp);
	  %>
      <td class="thinborder"><div align="right"><%=strTemp%>&nbsp;</div></td>
      
	  
	  <%
	  	if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0"))
	  		strTemp = "&nbsp;";
		else
			strTemp = CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true);
		
		if(bolAdditionalData && bolIsInPO)
	  		strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+19),strTemp);
	  %>
      <td class="thinborder"><div align="right"><%=strTemp%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><div align="left"><strong>TOTAL ITEM(S) : <%=vReqItems.size()/12%></strong></div></td>
      <td height="25" colspan="3" class="thinborder"><div align="right"><strong>TOTAL AMOUNT : </strong></div></td>
	   <td class="thinborder">&nbsp;</td>
	   <%
		  if(strGrandTotal != null)
		  	strTemp = strGrandTotal;
		else
			strTemp = WI.getStrValue(CommonUtil.formatFloat(dTotalAmount,true),"0");
		  %>
      <td  height="25" class="thinborder"><div align="right"><strong><%=WI.getStrValue(strTemp,"0")%></strong></div></td>
    </tr>
  </table>
  <%if(vAddtlCost != null && vAddtlCost.size() > 2){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="20" colspan="3" class="thinborder"><div align="center"><font color="#FFFFFF"><strong> 
          ADDITIONAL COST FOR THIS PO </strong></font></div></td>
    </tr>
    <%for(int iLoop = 0;iLoop < vAddtlCost.size();iLoop+=5){%>
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
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="85%" class="thinborder"> <div align="right">Grand Total: </div></td>
      <%
	  	dGrandTotal += dTotalAmount;
	  %>
      <td width="15%" height="25" class="thinborder"><div align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dGrandTotal,true),"0")%></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <%strTemp = WI.fillTextValue("print_supplier");%>
      <td height="18" colspan="5"><div align="left"></div></td>
    </tr>
    <tr> 
      <td width="1%" height="25"><div align="center"></div></td>
      <td width="8%">STATUS : </td>
      <td width="38%"> 
	  	<select name="status">
	  <%
		strTemp = WI.fillTextValue("status");
	 	if(vReqPO != null && (((String)vReqPO.elementAt(3)) != null))
			strTemp = (String)vReqPO.elementAt(3);
	  	if(strTemp.equals("1"))
	  		strErrMsg = "selected";
		else
			strErrMsg = "";
			
			
		if(strErrMsg.length() > 0 || !bolIs2ndLevelApprovalPOAndRequisition || (bolIs2ndLevelApprovalPOAndRequisition && bolShowUpdatePOStatFinalApproval) ){	
	  %>
          <option value="1" <%=strErrMsg%>>Approved</option>
	  <%}if(!bolShowUpdatePOStatFinalApproval && bolIs2ndLevelApprovalPOAndRequisition){
	  	if(strTemp.equals("3") || strTemp.length() == 0)
	  		strErrMsg = "selected";
		else
			strErrMsg = "";
	  %><option value="3" <%=strErrMsg%>>Approved - First Level</option>
	  <%}
	  	if(strTemp.equals("2") || strTemp.length() == 0)
	  		strErrMsg = "selected";
		else
			strErrMsg = "";
	  %><option value="2" <%=strErrMsg%>>Pending</option>
	  <%
	  	if(strTemp.equals("0"))
	  		strErrMsg = "selected";
		else
			strErrMsg = "";
	  %><option value="0" <%=strErrMsg%>>Disapproved</option>
        </select></td>
      <td width="12%"><%if(bolIsICA){%>
        Approved By:
      <%}%></td><td width="41%"><%if(bolIsICA){
	  strTemp = WI.fillTextValue("");
	  if(vReqPO != null && vReqPO.size() > 0)
	  	strTemp = WI.getStrValue(vReqPO.elementAt(17));
	  %>
	  <input name="approved_by" type="text" size="25" class="textbox" value="<%=strTemp%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">
	<label id="lbl_approved_by" style="width:400px; position:absolute;"></label>
	  <%}%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date :</td>
      <td> <%if(vReqPO != null && (((String)vReqPO.elementAt(4)) != null))
			strTemp = (String)vReqPO.elementAt(4);		
		 else if(WI.fillTextValue("date_status").length() > 0)
	  		strTemp = WI.fillTextValue("date_status");
		 else
			strTemp = WI.getTodaysDate(1);
	  %> <input name="date_status" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_status');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td>BUDGET : </td>
      <td width="41%"> <%if(WI.fillTextValue("budget").length() > 0)
	  		strTemp = WI.fillTextValue("budget");
	    else if(vReqPO != null && (((String)vReqPO.elementAt(5)) != null))
			strTemp = (String)vReqPO.elementAt(5);
		else
			strTemp = "";%> <select name="budget">
          <option value="1">Within Budget</option>
          <%if(strTemp.equals("0")){%>
          <option value="0" selected>Not in the Budget</option>
          <%}else{%>
          <option value="0">Not in the Budget</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>Days to deliver:</td>
      <td> <% if(WI.fillTextValue("days_required").length() > 0)
	  		strTemp = WI.fillTextValue("days_required");
	     else if(vReqPO != null && (((String)vReqPO.elementAt(8)) != null))
			strTemp = (String)vReqPO.elementAt(8);		 
		 else
			strTemp = "";
			%> <input name="days_required" type="text" size="3" maxlength="3" value="<%=WI.getStrValue(strTemp,"0")%>" class="textbox"
		onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font size="1">no of days required for the supplier to deliver the items.</font>      </td>
      <td>Date :</td>
      <td> <%if(vReqPO != null && (((String)vReqPO.elementAt(6)) != null))
			strTemp = (String)vReqPO.elementAt(6);		
		 else if(WI.fillTextValue("date_budget").length() > 0)
	  		strTemp = WI.fillTextValue("date_budget");
		 else
			strTemp = WI.getTodaysDate(1);
	  %> <input name="date_budget" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_budget');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="4">Payment Charged to : 
        <% if(WI.fillTextValue("fund").length() > 0)
	  		strTemp = WI.fillTextValue("fund");
	     else if(vReqPO != null && (((String)vReqPO.elementAt(7)) != null))
			strTemp = (String)vReqPO.elementAt(7);		 
		 else
			strTemp = "";%> 
		  <select name="fund">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("FUND_INDEX","FUND_NAME"," from PUR_PRELOAD_FUND order by FUND_NAME asc", strTemp, false)%> 
		  </select> 
		<!--
		<a href='javascript:ViewList("PUR_PRELOAD_FUND","FUND_INDEX","FUND_NAME","FUND NAME",
									  "PUR_PO_INFO ","CHARGED_TO_FUND", 
				                       " and PUR_PO_INFO.is_del = 0","","fund")'> 
        <img src="../../../images/update.gif" width="60" height="25" border="0"></a>	
        <font size="1"> click to add to the list </font>
		-->		</td>
    </tr>
	<%if(!bolIsApproved){%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="4"><div align="center"> <a href="javascript:SaveClicked();"><img src="../../../images/save.gif" border="0"></a> 
          <font size="1">click to save as different PO</font> <a href="javascript:PrintPg();"> 
          </a> <a href="javascript:CancelClicked();"><img src="../../../images/cancel.gif" border="0"> 
          </a> <font size="1">click to cancel</font> </div></td>
    </tr>
	<%}else{%>
    <tr>
      <td height="30">&nbsp;</td>
      <td colspan="4"><div align="center">
	  <a href="javascript:PrintPg();">          
          <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print list</font>
					<%if(!strSchCode.startsWith("UI")){%>
					<input type="checkbox" name="include_president" value="1">
          <font size="1">Include President as signatory?</font> 
					<%}%>
					</div></td>
    </tr>
	<%}%>
  </table>
  <%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"><div align="center"><font size="1"> 
          <a href="javascript:CancelClicked();"> 
		  <img src="../../../images/go_back.gif" border="0"> 
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
  <input type="hidden" name="isForPO" value="1">
  <input type="hidden" name="saveClicked" value="">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="req_index" value="<%=strReqIndex%>">
  <input type="hidden" name="supplier_count" value="<%=(vSuppliers.size() / 2)%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
