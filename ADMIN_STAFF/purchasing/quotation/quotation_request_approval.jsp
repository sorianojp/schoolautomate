<%@ page language="java" import="utility.*,purchasing.Quotation,purchasing.Requisition,java.util.Vector" %>
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
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function CancelClicked(){
	location = "./quotation_request_approval.jsp";
}
function OpenSearch(){
	document.form_.print_pg.value = "";
	var pgLoc = "../canvassing/canvassing_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}function PrintPg(){
	document.form_.print_pg.value = 1;
	this.SubmitOnce('form_');
}
function UpdatePOSignatory(){
	document.form_.print_pg.value = "";
	var pgLoc = "../purchase_order/purchasing_officers.jsp?sign_type=1";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%
	if(WI.fillTextValue("print_pg").equals("1")){%>
	<jsp:forward page="quotation_request_update_print.jsp"/>
	<!--<jsp:forward page="quotations_comparison_print.jsp"/>-->
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
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-QUOTATION"),"0"));
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
								"Admin/staff-PURCHASING-UPDATE QUOTATION STATUS-Update QUOTATION Status","quotation_request_approval.jsp");
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
	Vector vRetResult  = null;
	Vector vColumns = null;
	Vector vRows = null;
	Vector vRowCols = null;
	Vector vSuppliers = null;
	Vector vAddtlCost = null;
	boolean bolIsApproved = false;
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strReqIndex = WI.fillTextValue("req_index");
	String strHasItems = WI.getStrValue(WI.fillTextValue("has_credited"),"");
	String strSchCode = dbOP.getSchoolIndex();
	String strTemp1 = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strStatus = null;
	int iLoop = 0;
	int iCount = 0;
	boolean bolHasSupplier = false;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		if(WI.fillTextValue("req_no").length() == 0){
		strErrMsg = "Please enter Canvass Number";
		}else{
			vReqInfo = QTN.operateOnReqInfoQtn(dbOP,request);
			if(vReqInfo == null){
				strErrMsg = QTN.getErrMsg();
			}else{
				strReqIndex = (String)vReqInfo.elementAt(0);
				if(WI.fillTextValue("saveClicked").equals("1")){				
					if(QTN.approveReqBudget(dbOP,request))
						strErrMsg = "Status Saved.";
					else
						strErrMsg = QTN.getErrMsg();
				}
				strReqIndex = WI.getStrValue(strReqIndex, "0");
				strStatus = dbOP.mapOneToOther("pur_req_budget_stat " + 
							" join pur_requisition_info on (pur_req_budget_stat.requisition_index = pur_requisition_info.requisition_index)",
							" pur_req_budget_stat.is_valid","1","BUDGET_STATUS",
							" and pur_requisition_info.is_del = 0 " + 
							" and pur_req_budget_stat.REQUISITION_INDEX = "+strReqIndex);					
		
				if(strStatus != null && strStatus.length() > 0){
					if(strStatus.equals("1"))
						bolIsApproved = true;
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
	}// end if WI.fillTextValue("proceedClicked").equals("1")){
	
%>	
<form name="form_" method="post" action="quotation_request_approval.jsp">
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
      <td width="17%">Canvass No. :</td>
      <td width="28%"> <%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp = WI.fillTextValue("req_no");
	  }else{
	  		strTemp = "";
      }%> <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="52%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a><font size="1">click 
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
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR  CANVASS NO : <%=vReqInfo.elementAt(1)%></strong></div></td>
    </tr>
    <tr>
      <td height="25" width="4%">&nbsp;</td>
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
    <%}
if(true)	{
%>
    <tr>
      <td height="18">&nbsp;</td>
      <td colspan="2"><a href="quotation_request_update_for_approval.jsp?proceedClicked=1&req_no=<%=WI.fillTextValue("req_no")%>">Click here to go to other format</a>       
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%}%>	
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
      <td width="13%" height="19">Supplier 2</td>
      <td width="84%" height="19"><select name="supplier2">
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
      <a href="javascript:ProceedClicked();"> View Comparison</a></td>
      </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19" colspan="2"><font size="1">Note: selected suppliers are only for viewing and printing.</font></td>
      </tr>
  </table>	
  <%if(vRows != null && vRows.size() > 0 && vColumns != null && vColumns.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="5" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUISITION ITEM(S) WITH QUOTATION</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="26" colspan="2" class="thinborder">&nbsp;</td>
      <%for(int iCol = 0; vColumns.size() > iCol; iCol+=2) {%>
      <td colspan="3" class="thinborder"><div align="center"><%=(String)vColumns.elementAt(iCol)%></div></td>
	  <%}%>
    </tr>
    <tr>
      <td width="25%" class="thinborder"><div align="center"><font size="1"><strong>ITEM 
      / PARTICULARS / DESCRIPTION </strong></font></div></td> 
      <td width="12%" height="26" class="thinborder"><div align="center"><font size="1"><strong>QTY</strong></font> / <font size="1"><strong>UNIT</strong></font></div></td>
	  <%for(int iCol = 0; vColumns.size() > iCol; iCol+=2) {%>
      <td class="thinborder"><div align="center"><font size="1"><strong>REG PRI </strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>DISC PRI </strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>TOTAL AMT</strong></font></div></td>
	  <%}%>
    </tr>
    <%
	int j = 0;
	for(iLoop = 0,iCount = 1;iLoop < vRows.size();iLoop+=6,++iCount){
		vRowCols = (Vector) vRows.elementAt(iLoop+5);
	%>
    <tr>
      <td class="thinborder"><div align="left"><%=(String)vRows.elementAt(iLoop)%> / <%=(String)vRows.elementAt(iLoop+1)%></div></td> 
      <td height="25" class="thinborder"><div align="left"><%=(String)vRows.elementAt(iLoop+2)%> <%=(String)vRows.elementAt(iLoop+3)%></div></td>
	  <%for(j = 0;j < vRowCols.size(); j+=3){%>
      <td class="thinborder"><div align="right"><%=(String)vRowCols.elementAt(j)%></div></td>
      <td class="thinborder"><div align="right"><%=(String)vRowCols.elementAt(j + 1)%></div></td>
      <td class="thinborder"><div align="right"><%=(String)vRowCols.elementAt(j + 2)%></div></td>
	  <%}%>
    </tr>
    <%}%>		
  </table>
  <%}// end if(vRows != null && vRows.size() > 0 && vColum..%>
  <%if(vAddtlCost != null && vAddtlCost.size() > 2){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="3" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>ADDITIONAL 
          COST FOR THIS REQUISITION</strong></font></div></td>
    </tr>
    <tr> 
      <td width="35%" class="thinborder"><div align="center"><strong>SUPPLIER 
          NAME</strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>COST NAME 
          </strong></div></td>
      <td width="28%" height="25" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%
	for(iLoop = 2;iLoop < vAddtlCost.size();iLoop+=5){%>
    <tr> 
      <td  height="25" class="thinborder"><%=vAddtlCost.elementAt(iLoop+2)%> <%/*strTemp1 = "";
	  	strTemp2 = "";
	  for(;(iLoop+3+5) < vRetResult.size();){
	  		if(!((String)vRetResult.elementAt(iLoop+1)).equals((String)vRetResult.elementAt(iLoop+1+5)))
	  			break;
			strTemp1 += (String)vRetResult.elementAt(iLoop+3)+"<br>";
			strTemp2 += (String)vRetResult.elementAt(iLoop+4)+"<br>";
			iLoop+=5;
	    }*/%> </td>
      <td class="thinborder"><%=/*strTemp1+*/(String)vAddtlCost.elementAt(iLoop+3)%></td>
      <td class="thinborder"><div align="right"><%=/*strTemp2+*/(String)vAddtlCost.elementAt(iLoop+4)%></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <%strTemp = WI.fillTextValue("print_supplier");%>
      <td height="18" colspan="5"><div align="left"></div></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%">BUDGET : </td>
      <%
				if(WI.fillTextValue("status").length() > 0)
	  			strTemp = WI.fillTextValue("status");
	     	else if(strStatus != null)
					strTemp = strStatus;		 
				else
					strTemp = "2";
		  %>
      <td width="24%"> <select name="budget">
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
      <td width="12%">Signatory : </td>
	  <%
	  	strTemp = WI.fillTextValue("quot_signatory");
	  %>
      <td width="47%"><select name="quot_signatory">
          <option value="">Select signatory</option>
          <%=dbOP.loadCombo("user_table.user_index","FNAME+ ' ' + MNAME + ' ' + LNAME", " from user_table " +
		  " join pur_po_officers on(pur_po_officers.user_index = user_table.user_index)" +
		  " where user_table.is_valid = 1 and  pur_po_officers.is_valid = 1 and sign_type = 1 order by lname", strTemp, false)%> </select> <a href='javascript:UpdatePOSignatory()'><img src="../../../images/update.gif" width="60" height="26" border="0" id="compute"></a><font size="1">click 
      to update list of signatory</font></td>
    </tr>
    <tr> 
      <td height="25" rowspan="2">&nbsp;</td>
      <td height="30">Date :</td>
	  <%
	  	strTemp = WI.fillTextValue("date_budget");
	  %>
      <td> <input name="date_budget" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_budget');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td>Remarks :</td>
      <td rowspan="2"><textarea name="remarks" cols="32" rows="2"></textarea></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="30" colspan="5"> <div align="center"> 
          <%if(!bolIsApproved){%>
          <a href="javascript:SaveClicked();"><img src="../../../images/save.gif" border="0"></a> 
          <font size="1">click to SAVE </font> <a href="javascript:PrintPg();"> 
          </a> 
          <%}%>
          <a href="javascript:CancelClicked();"><img src="../../../images/cancel.gif" border="0">          </a> <font size="1">click to CANCEL</font></div></td>
    </tr>		
  </table>  
	<%if(bolHasSupplier){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="bottom">
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
    <tr valign="bottom"> 
      <td height="28" colspan="5" align="center"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> <font size="1">click 
      to print canvass form</font></td>
    </tr>		
  </table>  
	<%}// end if bolHasSupplier%>
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
  <input type="hidden" name="saveClicked" value="">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="req_index" value="<%=strReqIndex%>">
  <input type="hidden" name="has_credited" value="<%=strHasItems%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
