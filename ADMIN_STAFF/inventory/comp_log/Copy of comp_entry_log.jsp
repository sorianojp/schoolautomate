<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Inventory Entry Log</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.proceedClicked.value = "1";
	document.form_.page_action.value = strAction;	
	document.form_.pageReloaded.value = "0";
	this.SubmitOnce('form_');
}

function ReloadPage()
{
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
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
	var pgLoc = "../../purchasing/purchase_order/purchase_request_view_search.jsp?opner_info=form_.po_num";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateDonors() {
	var pgLoc = "./donors.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateItem(strSupply){
	var loadPg = "../../purchasing/requisition/update_item.jsp?opner_form_name=form_&opner_form_field=item_idx&is_supply="+strSupply;
	var win=window.open(loadPg,"UpdateCity",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ClearPropertyNo(){
	document.form_.prop_num.value ="";
}
</script>
</head>
<%
	DBOperation dbOP = null;	
	//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-COMPUTERLOG"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-COMPUTERLOG"),"0"));
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
								"Admin/staff-Inventory - COMP_LOG- COMPUTER_ENTRY_LOG","comp_entry_log.jsp");
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
	
	Vector vPODtls = null;
	Vector vPOItems = null;
	Vector vCompInfo = null;
	Vector vRetResult = null;
	int i = 0;
	String strErrMsg = null;
	String strType = null;
	String strProcessor = null;
	String strInvType = null;
	String strDonorIndex = null;	
	String strPageAction = null;
	String strTemp = null;
	String strTemp2 = null;	
	String strPrepareToEdit = null;
	int iSearchResult = 0;
	String strFinCol = null;	

	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	InventoryLog InvLog = new InventoryLog();
	strPageAction = WI.fillTextValue("page_action");
	strTemp2 = WI.fillTextValue("entry_type");
	
	if(strPageAction.length() == 0 && !strPrepareToEdit.equals("1")){
		if (WI.fillTextValue("prop_num").length() > 0){
			vCompInfo = InvLog.operateOnComputerInv(dbOP,request,3);
		}
	}
	
	if (strTemp2.length() > 0) {
	   if (strTemp2.equals("1")){
		  vPODtls = InvLog.getPODtls(dbOP, request, 1);
		  if (vPODtls != null){
		  /*
			 vPOItems = InvLog.getPODtls(dbOP, request, 2);
			   if (vPOItems != null) {
				  if(strTemp.length() > 0 && strTemp.equals("1")) {
					 if(InvLog.operateOnComputerInv(dbOP, request, 1) != null ) {
						strErrMsg = "Operation successful.";
						strPrepareToEdit = "0";
					 } else{
						strErrMsg = InvLog.getErrMsg();
					 }
				   }
			    } else{
					strErrMsg = InvLog.getErrMsg();
				}
		   */
		   } else {
				strErrMsg = InvLog.getErrMsg();
		   }
		   
		} else {// if (strTemp2.equals("1")) entry for donations and old stocks		
		  if(strPageAction.length() > 0) {
			 if(InvLog.operateOnComputerInv(dbOP, request, Integer.parseInt(strPageAction)) == null ){
				strErrMsg = InvLog.getErrMsg();
			 }else{
				strPrepareToEdit = "0";
				if(strPageAction.equals("1"))
				   strErrMsg = "Computer Log successful.";	

				if(strPageAction.equals("2"))
				   strErrMsg = "Computer Log successfully edited.";				
			 }
		   }
	    } // else {// if (strTemp2.equals("1"))
	}//if (strTemp2.length() > 0)
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./comp_entry_log.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY LOG - COMPUTER ENTRY LOG PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="30">&nbsp;</td>      
      <td width="18%">Property #</td>
      <td width="30%" valign="middle">
	  <%if(WI.fillTextValue("pageAction").equals("1") && vCompInfo != null)
	  		strTemp = (String)vCompInfo.elementAt(10);
	    else if(WI.fillTextValue("prop_num").length() > 0)
	  		strTemp = WI.fillTextValue("prop_num");
	  	else
			strTemp = "";
	  %> <strong> 
        <input type="text" name="prop_num" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong></td>
      <td width="48%" valign="middle"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="30" width="4%">&nbsp;</td>
      <td colspan="3">NOTE: <br>
        1. To edit a Unit, enter the property number and click <strong>PROCEED</strong>. 
        <br>
        2. The system will create the property number upon saving if it does not 
        exist yet. </td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td colspan="4">&nbsp;</td>
    </tr>
  </table>
  <%if(WI.fillTextValue("proceedClicked").equals("1") && !WI.fillTextValue("pageReloaded").equals("1")){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
    <tr> 
      <td width="4%" height="30">&nbsp;</td>
      <td width="18%">Entry Type </td>
      <td colspan="2" valign="middle"> 
	  <%  if (vCompInfo!= null && vCompInfo.size() > 0){
			strType = (String) vCompInfo.elementAt(1);
			strPrepareToEdit = "1";
	  	 }else{
		 	strType = WI.fillTextValue("entry_type");
		 }
	  %>
	      <select name="entry_type" onChange="ClearPropertyNo();ReloadPage();">
          <option value="" selected>Select Type</option>
          <%if (strType.equals("0")){%>
          <option value="0" selected>Donation</option>
          <option value="1">Purchase</option>
          <option value="2">On Hand</option>
          <%}else if (strType.equals("1")){%>
          <option value="0">Donation</option>
          <option value="1" selected>Purchase</option>
          <option value="2">On Hand</option>
          <%} else if (strType.equals("2")) {%>
          <option value="0">Donation</option>
          <option value="1">Purchase</option>
          <option value="2" selected>On Hand</option>
          <%} else {%>
          <option value="0">Donation</option>
          <option value="1">Purchase</option>
          <option value="2">On Hand</option>
          <%}%>
        </select></td>
    </tr>
    <%if (strType.equals("1")){%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Purchase Order No.</td>
      <td width="22%" height="30" valign="middle"> 
	     <%if(WI.fillTextValue("po_num").length() > 0){		 
		 	strTemp = WI.fillTextValue("po_num");
		   }else{
			strTemp = "";
		   }		 
		 %> <input name="po_num" type="text" class="textbox" size="20" maxlength="20" value="<%=strTemp%>"> 
      </td>
      <td width="56%" height="30" valign="middle"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <%} else if(strType.equals("0")) {%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Donor Type</td>
      <td height="30" colspan="2" valign="middle"> 
	    <select name="type_index" onChange="ReloadPage();">
          <option value="">Select Type</option>
          <%
		   if (vCompInfo!= null && vCompInfo.size() > 0){
		      strTemp = (String) vCompInfo.elementAt(3);
		   }else{			
			  strTemp = WI.fillTextValue("type_index");
  		   }		  
		  %>
          <%=dbOP.loadCombo("donor_type_index","donor_type"," from inv_preload_donor_type order by donor_type", strTemp, false)%> 
		 </select> <a href='javascript:viewList("inv_preload_donor_type","DONOR_TYPE_INDEX","DONOR_TYPE","DONOR TYPE",
		"INV_DONOR_LIST","DONOR_TYPE_INDEX","","","type_index")'><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Donor's Name</td>
      <td height="30" colspan="2" valign="middle"> <select name="donor_index" onChange="ReloadPage();">
          <option value="">Select donor</option>
          <%
		   if (vCompInfo!= null && vCompInfo.size() > 0){
		      strDonorIndex = (String) vCompInfo.elementAt(4);
		   }else{
			  strDonorIndex = WI.fillTextValue("donor_index");
		   }		   
		if (strTemp.length()>0){%>
          <%=dbOP.loadCombo("donor_index","name"," from inv_donor_list where is_valid = 1 and donor_type_index = "+strTemp+" order by name", strDonorIndex, false)%> 
          <%}%>
        </select> <font size="1"><a href="javascript:UpdateDonors();"><img src="../../../images/update.gif"  border="0"> 
        </a> click to update list of DONORS </font></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="18" colspan="2" valign="middle">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="19" colspan="4"><hr size="1"> </td>
    </tr>
  </table>
  <%}// if(WI.fillTextValue("proceedClicked").equals("1")) %>
  
  <%if (WI.getStrValue(strType,"").equals("1")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr  bgcolor="#A49A60"> 
      <td width="4%" height="27">&nbsp;</td>
      <td colspan="2"><font color="#FFFFFFF"><strong>ENDORSEMENT DETAILS</strong></font></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td width="19%">College</td>
	 <%if(WI.fillTextValue("po_num").length() > 0){		 
		strTemp = WI.fillTextValue("po_num");
	   }else{
		strTemp = "";
	   }		 
	 %>
      <td width="77%"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Department</td>
      <td><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type</td>
      <td><strong>&nbsp;</strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Building</td>
      <td> <%if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(10),"");
      else
		strTemp = WI.fillTextValue("bldg_index");%> 
		<select name="bldg_index" onChange="ReloadPage();">
         <option value="">N/A</option>
          <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strTemp, false)%> 
		</select> 
		<img src="../../../images/update.gif"  border="0">
		<font size="1"> click to update list of BUILDINGS</font></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Room</td>
      <td> <%if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp2 = WI.getStrValue((String)vCompInfo.elementAt(9),"");
      else
	     strTemp2 = WI.fillTextValue("room_idx");%> <select name="room_idx" onchange="ReloadPage();">
          <option value="">N/A</option>
 		  <%
		  	if (strTemp.length()>0){
			strTemp = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strTemp+
			" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";
		   %>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%> 
          <%}%>
        </select> <font size="1"><img src="../../../images/update.gif"  border="0"> 
        click to update list of LABORATORY/STOCK ROOM</font></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Location Description</td>
      <td>
		  <%
		  if (vCompInfo!=null && vCompInfo.size()>0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(16),"");
		  else
			strTemp = WI.fillTextValue("loc_desc");
		  %> 
        <input name="loc_desc" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%} else if ((WI.getStrValue(strType,"").equals("0") && WI.getStrValue(strDonorIndex,"").length()>0) 
              || WI.getStrValue(strType,"").equals("2")){
  %>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="2"><strong><u>LOCATION</u></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="19%">College</td>
      <td width="77%"> <%
      if (vCompInfo!=null && vCompInfo.size()>0)
      strTemp = WI.getStrValue((String)vCompInfo.elementAt(6),"0");
      else
      strTemp = WI.fillTextValue("c_index");%> <select name="c_index" onChange="ReloadPage();">
          <option value="0">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department</td>
      <td> <%if (vCompInfo!=null && vCompInfo.size()>0)
		  strTemp2 = WI.getStrValue((String)vCompInfo.elementAt(7),"");
		else
		  strTemp2 = WI.fillTextValue("d_index");			  
	   %> <select name="d_index">
          <% if(strTemp!=null && strTemp.compareTo("0") !=0){%>
          <option value="0">All</option>
          <%}%>
          <%if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) {
		        strTemp = " and (c_index = 0 or c_index is null) ";
			%>
          <option value="0">Select Office</option>
          <% } else {
			    strTemp = " and c_index = " +  strTemp;			
		   }%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp2, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Building</td>
      <td> <%if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(9),"");
      else
		strTemp = WI.fillTextValue("bldg_index");
		%> <select name="bldg_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strTemp, false)%> </select> <img src="../../../images/update.gif"  border="0"><font size="1"> 
        click to update list of BUILDINGS</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Room</td>
      <td> <%if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp2 = WI.getStrValue((String)vCompInfo.elementAt(8),"");
      else
	     strTemp2 = WI.fillTextValue("room_idx");%> <select name="room_idx" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
				if (strTemp.length()>0){
				strTemp = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strTemp+
				" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";
				%>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strTemp, strTemp2, false)%> 
          <%}%>
        </select> <font size="1"><img src="../../../images/update.gif"  border="0"> 
        click to update list of LABORATORY/STOCK ROOM</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Location Description</td>
      <td> 
		  <%
		  if (vCompInfo!=null && vCompInfo.size()>0)
			strTemp = WI.getStrValue((String)vCompInfo.elementAt(16),"");
		  else
			strTemp = WI.fillTextValue("loc_desc");
		  %> 
	 <input name="loc_desc" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="20" colspan="3"><hr size="1"></td>
    </tr>
	</table>
    <%}// end else if ((WI.getStrValue(strType... %>  
	
  <%if ((WI.getStrValue(strType,"").equals("0") && WI.getStrValue(strDonorIndex,"").length()>0) 
       || WI.getStrValue(strType,"").equals("1") || WI.getStrValue(strType,"").equals("2")){              
    %>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<% 
		if(!strPrepareToEdit.equals("1")) {
	%>    
	<tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="19%">Property #</td>
      <td width="77%"> 
	  <%
   	  if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(10),"");
      else
	    strTemp = WI.fillTextValue("prop_no");
	  %> 
	  <input name="prop_no" type="text" class="textbox" size="32" maxlength="32" value="<%=WI.getStrValue(strTemp,"")%>"> 
        <font size="1"> &nbsp;</font><font size="1">(required)</font></td>
    </tr>
    <%}else{%>
   	<%if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(10),"");
     else
	    strTemp = WI.fillTextValue("prop_no");
	 %> 
	  <input name="prop_no" type="hidden" class="textbox" value="<%=WI.getStrValue(strTemp,"")%>"> 	
	<%}%>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td>Serial #</td>
      <td> <%
   	  if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(11),"");
      else
      strTemp = WI.fillTextValue("serial_no");%> <input name="serial_no" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"> 
        <font size="1"> &nbsp;(if Applicable)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Product #</td>
      <td> <%
      if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(12),"");
      else
      strTemp = WI.fillTextValue("prod_no");%> <input name="prod_no" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"> 
        <font size="1"> &nbsp;(if Applicable)</font></td>
    </tr>
    <%if (WI.fillTextValue("entry_type").equals("0") || WI.fillTextValue("entry_type").equals("2")){%>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Processor Type</td>
      <td>
        <%  if (vCompInfo!= null && vCompInfo.size() > 0){
			strProcessor = (String) vCompInfo.elementAt(15);
	  	 }else{
		 	strProcessor = WI.fillTextValue("processor_type");
		 }
	  %>
        <select name="processor_type">
          <option value="" selected>Select Type</option>
          <%if (WI.getStrValue(strProcessor,"").equals("0")){%>
          <option value="0" selected>Server</option>
          <option value="1">Workstation</option>
          <%}else if (WI.getStrValue(strProcessor,"").equals("1")){%>
          <option value="0">Server</option>
          <option value="1" selected>Workstation</option>
          <%} else {%>
          <option value="0">Server</option>
          <option value="1">Workstation</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Price</td>
      <td> <%
      if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(5),"");
      else
      strTemp = WI.fillTextValue("price");%> <input name="price" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Status</td>
      <td> 
	  <%
   	  if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(13),"");
      else
	    strTemp = WI.fillTextValue("stat_index");
	  %> 	   
		<select name="stat_index">
          <option value="">Select category</option>
          <%=dbOP.loadCombo("inv_stat_index","inv_status"," from inv_preload_status order by inv_status", strTemp, false)%> 
		</select> <font size="1">
		<a href='javascript:viewList("INV_PRELOAD_STATUS","INV_STAT_INDEX","INV_STATUS","INVENTORY STATUS",
			"INV_ITEM","INV_STAT_INDEX","","","stat_index")'><img src="../../../images/update.gif" border="0">
		</a> 
        click to update STATUS list</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Warranty Until </td>
      <td> <%
   	  if (vCompInfo!=null && vCompInfo.size()>0)
      	strTemp = WI.getStrValue((String)vCompInfo.elementAt(14),"");
      else
	      strTemp = WI.fillTextValue("warranty");
	  %> <input name="warranty" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.warranty');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>	
  </table>
  <%}// end if ((WI.getStrValue(strType,"").equals(".... %>
  <%if ((WI.getStrValue(strType,"").equals("0") && WI.getStrValue(strDonorIndex,"").length()>0) 
       || WI.getStrValue(strType,"").equals("1") || WI.getStrValue(strType,"").equals("2")){              
  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2"> <div align="center"><font size="1"> 
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1,"");'> <img src="../../../images/save.gif" border="0" name="hide_save"></a> 
          Click to add entry 
          <%}else{%>		  
		  <%  if (vCompInfo!= null && vCompInfo.size() > 0){
				strTemp = (String) vCompInfo.elementAt(0);
			  }			 
		  %>
          <a href='javascript:PageAction(2, "<%=WI.getStrValue(strTemp,"")%>");'><img src="../../../images/edit.gif" border="0"></a> 
          Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
          Click to cancel 
          <%}%>
          </font> </div></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%">&nbsp;</td>
    </tr>
  </table>
  <%}// end check if ((WI.getStrValue(strType ...%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="7" class="thinborder"><div align="center"> 
          <p><strong><font size="2"> COMPONENTS FOR THE SELECTED CPU</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td  height="25" colspan="7" align="left" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL 
        ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font> </td>
    </tr>
    <tr> 
      <td width="13%" height="25" class="thinborder"><div align="center"><font size="1"><strong>ENTRY 
          TYPE </strong></font></div></td>
      <td width="13%" class="thinborder" align="center"><font size="1"><strong>ITEM 
        NAME </strong></font></td>
      <td width="15%" class="thinborder" align="center"><font size="1"><strong>ATTACHMENT 
        TYPE </strong></font></td>
      <td width="14%" class="thinborder" align="center"><font size="1"><strong>SIZE/CAPACITY</strong></font></td>
      <td width="17%" class="thinborder" align="center"><font size="1"><strong>BRAND</strong></font></td>
      <td width="17%" class="thinborder" align="center"><font size="1"><strong>STATUS</strong></font></td>
      <td width="11%" class="thinborder">&nbsp;</td>
    </tr>
    <%for (i=0; i< vRetResult.size(); i+=7) {%>
    <tr> 
      <td align="center" class="thinborder"><font size="1"> 
        <%if (((String)vRetResult.elementAt(i+1)).equals("0")){%>
        DONATION 
        <%}else if (((String)vRetResult.elementAt(i+1)).equals("1")){%>
        PURCHASE 
        <%}else{%>
        EXISTING STOCKS 
        <%}%>
        </font> </td>
      <td align="center" class="thinborder"><font size="1"><%=((String)vRetResult.elementAt(i+2))%></font></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="left" class="thinborder"> <a href="./inv_entry_log_items.jsp?entry_type=<%=(String)vRetResult.elementAt(i+1)%>&entry_index=<%=(String)vRetResult.elementAt(i)%>&inventory_type=<%=WI.fillTextValue("inventory_type")%>"> 
        <img src="../../../images/update.gif" border="0"></a> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%}%>
    
    <tr> 
      <td height="25"><div align="center"></div></td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

  	<input type="hidden" name="info_index"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="proceedClicked" value="">
    <input type="hidden" name="page_action">
	<input type="hidden" name="pageReloaded" value="">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

