<%@ page language="java" import="utility.*,purchasing.Quotation,java.util.Vector" %>
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ViewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	document.form_.donot_call_close_wnd.value = 1;
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SearchSupplier(strIndex){	
	var selectedIndex = document.form_.supplier.selectedIndex;	
	document.form_.con_person_disp.value = eval('document.form_.con_person_'+selectedIndex+'.value');	
	document.form_.con_no_disp.value = eval('document.form_.con_no_'+selectedIndex+'.value');
	document.form_.search_supplier.value = 1;
	if(strIndex == 1)
		return;
	document.form_.donot_call_close_wnd.value = 1;
	this.SubmitOnce('form_');
}
function CancelClicked(){
	document.form_.donot_call_close_wnd.value = 1;
	location = "./quotation_encode_pop_up_additional_cost.jsp?req_index=<%=WI.fillTextValue("req_index")%>";
}
function CloseWindow(){
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();		
}
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();	
}
function PageAction(strAction,strInfoIndex,strDelete){
	document.form_.donot_call_close_wnd.value = 1;
	if(strAction == 0){
		if(!confirm('Delete '+strDelete+'?'))
			return;
	}
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
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
								"PURCHASING-QUOTATION","quotation_encode_pop_up_additional_cost.jsp");
	Quotation QTN = new Quotation();
	Vector vRetResult = null;
	Vector vRetAction = null;
	Vector vTemp = null;
	Vector vRetSearch = null;
	String strTemp = null;
	String strErrMsg = null;
	String strReqIndex = WI.fillTextValue("req_index");
	String strInfoIndex = WI.fillTextValue("info_index");
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		vRetAction = QTN.operateOnAdditionalCost(dbOP,request,Integer.parseInt(strTemp));
		if(vRetAction == null)
			strErrMsg = QTN.getErrMsg();
		else if(!strTemp.equals("3")){
			strErrMsg = "Operation Successful";
			strInfoIndex = "";
		}
	}
	if(WI.fillTextValue("search_supplier").length() > 0 || strInfoIndex.length() > 0){
		vRetSearch = QTN.showSupplierQuotation(dbOP,request);
		if(vRetSearch == null)
			strErrMsg = QTN.getErrMsg();
	}
	vRetResult = QTN.operateOnAdditionalCost(dbOP,request,4);
	if(vRetResult == null)
		strErrMsg = QTN.getErrMsg();
%>
<body bgcolor="#D2AE72" onLoad="SearchSupplier('1');" onUnload="ReloadParentWnd();">
<form name="form_" method="post" action="./quotation_encode_pop_up_additional_cost.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          QUOTATION - ENCODE QUOTATION - ADDITIONAL COST PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="85%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        &nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong> </td>
      <td width="15%"><div align="right"><a href="javascript:CloseWindow();"> 
          <img src="../../../images/close_window.gif" border="0"> </a></div></td>
    </tr>
  </table>
  <%if(vRetResult != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="46%">Canvassing No. : <strong><%=vRetResult.elementAt(0)%></strong></td>
      <td width="50%">Canvassing Date : <strong><%=vRetResult.elementAt(1)%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="10">(NOTE : Show below all the items quoted by 
        the selected supplier )</td>
    </tr>
  </table>  
  <table width="100%" height="225" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="3">Supplier : 
	  	<%if(vRetResult.size() > 2){
			vTemp = (Vector)vRetResult.elementAt(2);			
			for(int iLoop = 0;iLoop < vTemp.size();iLoop+=4){%>	
			<input type="hidden" name="con_no_<%=(iLoop+3)/4%>" value="<%=vTemp.elementAt(iLoop)%>">
			<input type="hidden" name="con_person_<%=(iLoop+3)/4%>" value="<%=vTemp.elementAt(iLoop+1)%>">
		  <%}
		  }
		  strTemp = WI.fillTextValue("supplier");%>
        <select name="supplier" onChange="SearchSupplier('2');">
          <option value="">Select supplier</option>
		  <%for(int iLoop = 4;iLoop < vTemp.size();iLoop+=4){
		  		if(((String)vTemp.elementAt(iLoop+2)).equals(strTemp)){%>
					<option value="<%=vTemp.elementAt(iLoop+2)%>" selected><%=vTemp.elementAt(iLoop+3)%></option>
				<%}else{%>
		  			<option value="<%=vTemp.elementAt(iLoop+2)%>"><%=vTemp.elementAt(iLoop+3)%></option>
		  <%}}%>
        </select>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><u>Contact Information :</u></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" height="25">Contact Person : </td>
      <td><input type="text" name="con_person_disp" value="<%=WI.fillTextValue("con_person_disp")%>" class="textbox_noborder" size="80">
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Contact Nos. : </td>
      <td><input type="text" name="con_no_disp" value="<%=WI.fillTextValue("con_no_disp")%>" class="textbox_noborder" size="80">
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><u>Additional Cost :</u></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Cost Name :</td>
      <td height="25">
	  	<%if(vRetAction != null && vRetAction.size() > 0)
			strTemp = (String)vRetAction.elementAt(0);
		  else			
			strTemp = WI.fillTextValue("cost_index");%>
		<select name="cost_index">
          <option value="">Select Cost Name</option>
          <%=dbOP.loadCombo("COST_NAME_INDEX","COST_NAME"," from PUR_PRELOAD_COST_NAME order by COST_NAME asc", strTemp, false)%>
		</select> 
		<a href='javascript:ViewList("PUR_PRELOAD_COST_NAME","COST_NAME_INDEX","COST_NAME","COST NAME",
		 						     "PUR_QUOTATION_ADDL_COST","COST_NAME_INDEX", 
				                     " and IS_VALID = 1","","cost_index")'>
        <img src="../../../images/update.gif" width="60" height="25" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Amount :</td>
      <td height="25">
	  <%if(vRetAction != null && vRetAction.size() > 0)
			strTemp = (String)vRetAction.elementAt(1);
		else			
			strTemp = WI.fillTextValue("amount");%>
	  <input type="text" name="amount" class="textbox" value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'"
	   onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyFloat('form_','amount')">
	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><div align="center"><font size="1">
	  	<%if(strInfoIndex.length() > 0){%>
	    <a href="javascript:PageAction(2,'<%=strInfoIndex%>','');"> 
        <img src="../../../images/edit.gif" border="0"> </a> click to EDIT Additional Cost details
		<%}else{%>
		<a href="javascript:PageAction(1,'','');"> 
        <img src="../../../images/add.gif" border="0"> </a> click to ADD Additional Cost details
		<%}%>
		<a href="javascript:CancelClicked();">
		<img src="../../../images/cancel.gif" border="0"></a>click to CANCEL entries
        </font></div>
	  </td>
    </tr>
  </table>
  <%if(vRetSearch != null){
  		vTemp = (Vector)vRetSearch.elementAt(0);
		if(vTemp != null && vTemp.size() > 2){
  %>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="5" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>ITEM(S) 
          QUOTED</strong></font></div></td>
    </tr>
    <tr>
      <td width="39%" height="25" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS / DESCRIPTION</strong>
	  </div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>PRICE QUOTED</strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong>DISCOUNT</strong></div></td>
      <td width="17%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="17%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT </strong></div></td>
    </tr>
	<%int iLoop = 0;
	for(;iLoop < vTemp.size(); iLoop+=5){%>
    <tr>
      <td height="25" class="thinborder"><%=vTemp.elementAt(iLoop)%></td>
      <td class="thinborder"><div align="right"><%=vTemp.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="right"><%=vTemp.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="right"><%=vTemp.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="right"><%=vTemp.elementAt(iLoop+4)%></div></td>
    </tr>
	<%}%>
    <tr> 
      <td height="25" colspan="5" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=((iLoop+5)/5)-1%></strong></div></td>
    </tr>    
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">
	  </td>
    </tr>
  </table>
  <%if(vRetSearch.size() > 1){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr bgcolor="#B9B292"> 
          <td height="25" colspan="4" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>ADDITIONAL 
              COST FOR THIS QUOTATION</strong></font></div></td>
        </tr>
        <tr> 
          <td width="50%" class="thinborder"><div align="center"><strong>COST 
          NAME </strong></div></td>
          <td width="26%" height="25" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
          <td width="11%" class="thinborder"><div align="center"><strong>EDIT</strong></div></td>
          <td width="13%" class="thinborder"><div align="center"><strong>DELETE</strong></div></td>
        </tr>
	 <%for(int iLoop = 1;iLoop < vRetSearch.size();iLoop+=3){%>
        <tr> 
          <td class="thinborder"><div align="left"><%=vRetSearch.elementAt(iLoop+1)%></div></td>
          <td height="25" class="thinborder"><div align="right"><%=vRetSearch.elementAt(iLoop+2)%></div></td>
          <td class="thinborder"><div align="center">
	      <a href="javascript:PageAction('3','<%=vRetSearch.elementAt(iLoop)%>','')"> 
          <img src="../../../images/edit.gif" border="0"> </a> </div></td>
          <td class="thinborder"><div align="center"> 
	      <a href="javascript:PageAction('0','<%=vRetSearch.elementAt(iLoop)%>','<%=vRetSearch.elementAt(iLoop+1)%>')"> 
          <img src="../../../images/delete.gif" border="0"> </a> </div></td>
        </tr>
  <%}%>    
  </table>
  <%  }//if(vRetSearch.size() > 1){
  	}//if(vRetSearch != null){
  }//if(vRetResult != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">
	  </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="req_index" value="<%=strReqIndex%>">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="search_supplier">
  <input type="hidden" name="donot_call_close_wnd">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
