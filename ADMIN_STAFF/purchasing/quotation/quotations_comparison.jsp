<%@ page language="java" import="utility.*,purchasing.Quotation,java.util.Vector" %>
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
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function OpenSearchPO(){
	var pgLoc = "../canvassing/canvassing_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function QuoteItem(strQuote,strIndex,strReqIndex,strInfoIndex,strIsCredited){
    document.form_.printPage.value = "";
	if(strQuote == 0)
		var pgLoc = "./quotation_encode_pop_up.jsp?req_item_index="+strIndex+"&encode_pop=1&req_index="+strReqIndex+"&is_credited="+strIsCredited;
	else if(strQuote == 1)
		var pgLoc = "./quotation_encode_pop_up_additional_cost.jsp?req_index="+strReqIndex;		
	else
		var pgLoc = "./quotation_encode_pop_up_additional_cost.jsp?req_index="+strReqIndex+"&page_action=3&info_index="+
		strInfoIndex+"&supplier="+strIndex;
	var win=window.open(pgLoc,"PrintWindow",  'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function PageLoad(){
	document.form_.req_no.focus();
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
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="./quotations_comparison_print.jsp"/>
	<%}
    //authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-QUOTATION"),"0"));
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
								"PURCHASING-QUOTATION","quotations_comparison.jsp");
	Quotation QTN = new Quotation();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vColumns = null;
	Vector vRows = null;
	Vector vRowCols = null;
	Vector vSuppliers = null;
	String strErrMsg = null;
	String strTemp1 = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strHasItems = WI.getStrValue(WI.fillTextValue("has_credited"),"");
	String strSchCode = dbOP.getSchoolIndex();
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};
	String[] astrReqType = {"New","Replacement"};
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String strInfoIndex = WI.fillTextValue("info_index");
	int iLoop = 0;
	int iCount = 0;
	boolean bolHasSupplier = false;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		if(WI.fillTextValue("delete_cost").length() > 0){
			vReqInfo = QTN.operateOnAdditionalCost(dbOP,request,0);
			if(vReqInfo == null)
				strErrMsg = QTN.getErrMsg();
			else
				strErrMsg = "Operation Successful.";				
		}
		vReqInfo = QTN.operateOnReqInfoQtn(dbOP,request);		
		if(vReqInfo == null)
			strErrMsg = QTN.getErrMsg();
		else{
			strInfoIndex = (String)vReqInfo.elementAt(0);//requisition_index
			vSuppliers = QTN.showQTNSuppliers(dbOP, strInfoIndex);			
		}
		
			for(int i = 1; i < 6; i++){
				if(WI.fillTextValue("supplier"+i).length() > 0){
					bolHasSupplier = true;
					break;
				}				
			}
		
			if(bolHasSupplier){
				vRetResult = QTN.generateQuotationPerSupplier(dbOP,request);
				if(vRetResult == null)
					strErrMsg = QTN.getErrMsg();
				else{
					vRows = (Vector)vRetResult.elementAt(0);				
					vColumns = (Vector)vRetResult.elementAt(1);				
				}
			}
		
	}
%>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<form name="form_" method="post" action="quotations_comparison.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          QUOTATION - QUOTATIONS COMPARISON PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="25%">Canvass No. :</td>
      <td width="31%"><%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp1 = WI.fillTextValue("req_no");
	    }else{
	  		strTemp1 = "";
        }%>
      <input type="text" name="req_no" class="textbox" value="<%=strTemp1%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="41%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search canvass no.</font></td>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"> </a></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%if(vReqInfo != null && vReqInfo.size() > 2){%>
    <tr>
      <td height="25">
      <td>Canvass No. :<strong><%=vReqInfo.elementAt(1)%></strong></td>
      <td colspan="3">Canvass Date : <strong><%=vReqInfo.elementAt(2)%></strong> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="19" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR  CANVASS NO : <%=vReqInfo.elementAt(1)%></strong></div></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=vReqInfo.elementAt(3)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"><strong><%=vReqInfo.elementAt(4)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(5))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=vReqInfo.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(7))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(9)) == null){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>	
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="19" colspan="3">SUPPLIERS:</td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19">Supplier 1 </td>
      <td height="19"><select name="supplier1">
          <option value="">Select Supplier</option>
          <%for(iLoop = 0;iLoop < vSuppliers.size();iLoop+=2){
		   if(WI.fillTextValue("supplier1").equals((String)vSuppliers.elementAt(iLoop))){%>
          <option value="<%=vSuppliers.elementAt(iLoop)%>" selected><%=vSuppliers.elementAt(iLoop+1)%></option>
          <%}else{%>
          <option value="<%=vSuppliers.elementAt(iLoop)%>"><%=vSuppliers.elementAt(iLoop+1)%></option>
          <%}
		  }%>
        </select></td>
    </tr>
    <tr>
      <td width="3%" height="19">&nbsp;</td>
      <td width="15%" height="19">Supplier 2</td>
      <td width="82%" height="19"><select name="supplier2">
        <option value="">Select Supplier</option>
        <%for(iLoop = 0;iLoop < vSuppliers.size();iLoop+=2){
		  		if(WI.fillTextValue("supplier2").equals((String)vSuppliers.elementAt(iLoop))){%>
        <option value="<%=vSuppliers.elementAt(iLoop)%>" selected><%=vSuppliers.elementAt(iLoop+1)%></option>
        <%}else{%>
        <option value="<%=vSuppliers.elementAt(iLoop)%>"><%=vSuppliers.elementAt(iLoop+1)%></option>
        <%}}%>
      </select></td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19">Supplier 3 </td>
      <td height="19"><select name="supplier3">
        <option value="">Select Supplier</option>
        <%for(iLoop = 0;iLoop < vSuppliers.size();iLoop+=2){
		  		if(WI.fillTextValue("supplier3").equals((String)vSuppliers.elementAt(iLoop))){%>
        <option value="<%=vSuppliers.elementAt(iLoop)%>" selected><%=vSuppliers.elementAt(iLoop+1)%></option>
        <%}else{%>
        <option value="<%=vSuppliers.elementAt(iLoop)%>"><%=vSuppliers.elementAt(iLoop+1)%></option>
        <%}}%>
      </select></td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19">Supplier 4 </td>
      <td height="19"><select name="supplier4">
        <option value="">Select Supplier</option>
        <%for(iLoop = 0;iLoop < vSuppliers.size();iLoop+=2){
		  		if(WI.fillTextValue("supplier4").equals((String)vSuppliers.elementAt(iLoop))){%>
        <option value="<%=vSuppliers.elementAt(iLoop)%>" selected><%=vSuppliers.elementAt(iLoop+1)%></option>
        <%}else{%>
        <option value="<%=vSuppliers.elementAt(iLoop)%>"><%=vSuppliers.elementAt(iLoop+1)%></option>
        <%}}%>
      </select></td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19">Supplier 5 </td>
      <td height="19"><select name="supplier5">
        <option value="">Select Supplier</option>
        <%for(iLoop = 0;iLoop < vSuppliers.size();iLoop+=2){
		  		if(WI.fillTextValue("supplier5").equals((String)vSuppliers.elementAt(iLoop))){%>
        <option value="<%=vSuppliers.elementAt(iLoop)%>" selected><%=vSuppliers.elementAt(iLoop+1)%></option>
        <%}else{%>
        <option value="<%=vSuppliers.elementAt(iLoop)%>"><%=vSuppliers.elementAt(iLoop+1)%></option>
        <%}}%>
      </select>
      <a href="javascript:ProceedClicked();">View Comparison</a></td>
    </tr>
  </table>
  <%if(vRows != null && vRows.size() > 0 && vColumns != null && vColumns.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="5" align="center" class="thinborder"><font color="#FFFFFF"><strong>LIST 
      OF REQUISITION ITEM(S) WITH QUOTATION</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td class="thinborder">&nbsp;</td>
      <td height="26" class="thinborder">&nbsp;</td>
	  <%for(int iCol = 0; vColumns.size() > iCol; iCol+=2) {%>
      <td colspan="3" align="center" class="thinborder"><%=(String)vColumns.elementAt(iCol)%></td>
	  <%}%>
    </tr>
    <tr>
      <td width="25%" align="center" class="thinborder"><font size="1"><strong>ITEM 
      / PARTICULARS / DESCRIPTION </strong></font></td> 
      <td width="12%" height="26" align="center" class="thinborder"><font size="1"><strong>QTY</strong></font> / <font size="1"><strong>UNIT</strong></font></td>
	  <%for(int iCol = 0; vColumns.size() > iCol; iCol+=2) {%>
      <td align="center" class="thinborder"><font size="1"><strong>REG PRI </strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DISC PRI </strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>TOTAL AMT</strong></font></td>
	  <%}%>
    </tr>
    <%
	int j = 0;
	for(iLoop = 0,iCount = 1;iLoop < vRows.size();iLoop+=6,++iCount){
		vRowCols = (Vector) vRows.elementAt(iLoop+5);
	%>
    <tr>
      <td class="thinborder"><%=(String)vRows.elementAt(iLoop)%> / <%=(String)vRows.elementAt(iLoop+1)%></td> 
      <td height="25" class="thinborder"><%=(String)vRows.elementAt(iLoop+2)%> <%=(String)vRows.elementAt(iLoop+3)%></td>
	  <%for(j = 0;j < vRowCols.size(); j+=3){%>
      <td align="right" class="thinborder"><%=(String)vRowCols.elementAt(j)%></td>
      <td align="right" class="thinborder"><%=(String)vRowCols.elementAt(j + 1)%></td>
      <td align="right" class="thinborder"><%=(String)vRowCols.elementAt(j + 2)%></td>
      <%}%>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5" class="thinborder"><strong>TOTAL 
        ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></td>
    </tr>
  </table>
  <%}if((vRows != null && vRows.size() > 0 && vColumns != null && vColumns.size() > 0)){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><div align="center"> <a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"> </a> <font size="1">click to print this details</font></div></td>
    </tr>
  </table>
  <%}
  }%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="printPage">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="has_credited" value="<%=strHasItems%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
