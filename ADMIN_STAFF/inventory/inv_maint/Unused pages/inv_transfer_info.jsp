<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
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
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function PageAction(strAction,strInfoIndex)
{		
	if(strAction==0){	 
		if(!confirm("This will reassign all related records. "+
		"Do you want to continue?"))
                             return;
	}	
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value= strAction;
	this.SubmitOnce("form_");
}

function ProceedClicked(){
	document.form_.proceedclicked.value = "1";
	document.form_.focus_area.value = "1";
	this.SubmitOnce('form_');
}

function ReloadCollege() {
	document.form_.proceedclicked.value = "1";
	document.form_.focus_area.value = "2";
	document.form_.pageReloaded.value = "1";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex, strPropNo) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.prop_no.value = strPropNo;
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
function OpenSearch()
{
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.transfer_by";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusStuff() {
	var pageNo = <%=WI.getStrValue(WI.fillTextValue("focus_area"),"1")%>
	eval('document.form_.area'+pageNo+'.focus()');
}

function SearchProperty(){
	var pgLoc = "./search_property.jsp?opner_info=form_.prop_no&transfer=1";
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchTransaction(){
	var pgLoc = "./inv_transfer_view_list.jsp";
	var win=window.open(pgLoc,"SearchTransaction",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
</head>

<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-INVENTORY MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY MAINTENANCE","inv_transfer_info.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
//	Vector vEntryDetails = null;
	Vector vPropDtls = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strBldgFr = null;
	String strBldgTo = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;
	String strFinCol = null;

	
	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

	InventoryMaintenance InvMaint = new InventoryMaintenance();

    if(WI.fillTextValue("prop_no").length()>0)
    {  
	   vPropDtls = InvMaint.operateOnTransferItems(dbOP, request, 5);
	   if (vPropDtls ==  null)
		strErrMsg = InvMaint.getErrMsg();
    }	

	if(WI.fillTextValue("trans_no").length()>0){
		vEditInfo = InvMaint.operateOnTransferInfo(dbOP, request, 3);
		if(vEditInfo == null || vEditInfo.size() == 0) {
			strErrMsg = InvMaint.getErrMsg();	
			strPrepareToEdit = "0";	
		}else{
			strPrepareToEdit = "1";	   	
		}
	}

	if(strTemp.length() > 0) {
		if(InvMaint.operateOnTransferInfo(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else 
			strErrMsg = InvMaint.getErrMsg();
	}	

	vRetResult = InvMaint.operateOnTransferInfo(dbOP, request, 4);
	if (vRetResult == null && strErrMsg == null && WI.fillTextValue("trans_no").length()>0)
		strErrMsg = InvMaint.getErrMsg();
%>
<body bgcolor="#D2AE72" onLoad="FocusStuff();">
<form name="form_" action="inv_transfer_info.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - TRANSFER INFO PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6"><font size="2" color="red"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></td>
    </tr>
    <tr> 
      <td width="2%" height="30"><input type="text" name="area1" readonly="yes" size="2" style="background-color:#FFFFFF;border-width: 0px;"> 
      </td>
      <td width="19%"><strong>Transfer #</strong></td>
      <td width="17%" valign="middle"> <%strTemp = WI.fillTextValue("trans_no");%> <input name="trans_no" type="text" size="16" maxlength="32"
	  value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="9%" valign="middle"><font size="1"><a href="javascript:SearchTransaction();"><img src="../../../images/search.gif" alt="search" border="0"></a></font></td>
      <td width="32%" valign="middle"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td width="21%" valign="middle"><a href="./inv_transfer_items.jsp?trans_no=<%=WI.fillTextValue("trans_no")%>">Add Items</a></td>
    </tr>
    <tr> 
      <td height="19" colspan="6">&nbsp;</td>
    </tr>
  </table>
  <%if (WI.fillTextValue("proceedclicked").length() > 0 || WI.fillTextValue("page_action").length() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#C78D8D"> 
      <td height="30" colspan="4" ><strong><font color="#FFFFFF">TRANSFER DETAILS</font></strong></td>
    </tr>
    <tr> 
      <td width="0%" height="30">&nbsp;</td>
      <td width="27%">Transfer Date :</td>
      <td width="29%"> <%
      if (vEditInfo != null && vEditInfo.size()>0)
    	  strTemp = WI.getStrValue((String)vEditInfo.elementAt(2),"");
	  else
	      strTemp = WI.fillTextValue("trans_date");%> <input name="trans_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.trans_date');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
      <td width="44%" height="30" valign="middle">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Requested by :</td>
      <td > <%
      if (vEditInfo != null && vEditInfo.size()>0)
    	  strTemp = WI.getStrValue((String)vEditInfo.elementAt(12),"");
	  else
	      strTemp = WI.fillTextValue("transfer_by");%> <input name="transfer_by" type="text" class="textbox" size="32" maxlength="32" value="<%=strTemp%>"> 
      </td>
      <td><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" hspace="0" vspace="0" border="0"></a></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Reason:</td>
      <td colspan="2"> <%
	      if (vEditInfo != null && vEditInfo.size()>0)
    		  strTemp = WI.getStrValue((String)vEditInfo.elementAt(4),"");
		  else
			strTemp = WI.fillTextValue("reason_index");%> <select name="reason_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("trans_reason_index","reason"," from inv_preload_trans_reason order by reason", strTemp, false)%> </select> <font size="1"><a href='javascript:viewList("inv_preload_trans_reason","trans_reason_index","reason","TRANSFER REASON",
		"INV_TRANSFER_LOG","REASON","","","reason_index")'><img src="../../../images/update.gif" width="60" height="25" border="0"></a> 
        click to update list of REASONS</font></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Full Reason :</td>
      <td colspan="2"> <%
      if (vEditInfo != null && vEditInfo.size()>0)
    	  strTemp = WI.getStrValue((String)vEditInfo.elementAt(5),"");
	  else
	      strTemp = WI.fillTextValue("reason");%> 
        <textarea name="reason" cols="45" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea> 
      </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2"><strong><u>SOURCE STOCK ROOM:</u></strong></td>
      <td width="73%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="23%">College (Ownership):</td>
      <td> <%
       if (vEditInfo != null && vEditInfo.size()>0 && !WI.fillTextValue("pageReloaded").equals("1"))
    	  strTemp = WI.getStrValue((String)vEditInfo.elementAt(6),"");
	  else
	       strTemp = WI.fillTextValue("c_index_fr");%> <select name="c_index_fr" onChange="ReloadCollege();">
          <option value="0">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Department :</td>
      <td> <%
      if (vEditInfo != null && vEditInfo.size()>0)
    	  strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(7),"");
	  else
      strTemp2 = WI.fillTextValue("d_index_fr");%> 
        <select name="d_index_fr">
          <% if(strTemp!=null && strTemp.compareTo("0") !=0){%>
          <option value="">All</option>
          <%}  
if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
	else strTemp = " and c_index = " +  strTemp;
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp2, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Building :</td>
      <td>
        <%if (vEditInfo!=null && vEditInfo.size()>0  && !WI.fillTextValue("pageReloaded").equals("1"))
      	strBldgFr = WI.getStrValue((String)vEditInfo.elementAt(19),"");
      else
		strBldgFr = WI.fillTextValue("bldg_index_fr");		
		//System.out.println("strBldgFr " + strBldgFr);
		%>

        <select name="bldg_index_fr" onChange="ReloadCollege();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strBldgFr, false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Laboratory/Stock Room :</td>
      <td> 
        <%if (vEditInfo!=null && vEditInfo.size()>0 && !WI.fillTextValue("pageReloaded").equals("1"))
      	strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(8),"");
      else
	     strTemp2 = WI.fillTextValue("room_idx_fr");
		 //System.out.println("strTempRoom " + strTemp2);
		 %>
        <select name="room_idx_fr">
          <option value="">N/A</option>
          <%
		  	if (strTemp.length()>0){
			strBldgFr = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strBldgFr+
			" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";
		   %>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strBldgFr, strTemp2, false)%> 
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2"><strong><u>TRANSFER TO :</u></strong></td>
      <td width="73%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="23%">College :</td>
      <td> <%
       if (vEditInfo != null && vEditInfo.size()>0 && !WI.fillTextValue("pageReloaded").equals("1"))
    	  strTemp = WI.getStrValue((String)vEditInfo.elementAt(9),"");
	  else
	       strTemp = WI.fillTextValue("c_index_to");%>
 	  <select name="c_index_to" onChange="ReloadCollege();">
          <option value="0">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Department :</td>
      <td> <%
      if (vEditInfo != null && vEditInfo.size()>0)
    	  strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(10),"");
	  else
      	  strTemp2 = WI.fillTextValue("d_index");%> 
        <select name="d_index_to">
          <% if(strTemp!=null && strTemp.compareTo("0") !=0){%>
          <option value="">All</option>
          <%}  
			if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
				else strTemp = " and c_index = " +  strTemp;
		  %>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp2, false)%> </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Building :</td>
      <td>
        <%if (vEditInfo != null && vEditInfo.size() > 0 && !WI.fillTextValue("pageReloaded").equals("1"))
      		strBldgTo = WI.getStrValue((String)vEditInfo.elementAt(20),"");
      	  else
			strBldgTo = WI.fillTextValue("bldg_index_to");

			//System.out.println("reloaded " + WI.fillTextValue("pageReloaded"));
			//System.out.println("strTempbto " + strTemp);
		%>
        <select name="bldg_index_to" onChange="ReloadCollege();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("BLDG_INDEX","BLDG_NAME"," from E_ROOM_BLDG where IS_DEL=0 order by BLDG_NAME", strBldgTo, false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25"><input type="text" name="area2" readonly="yes" size="2" style="background-color:#FFFFFF;border-width: 0px;"></td>
      <td>&nbsp;</td>
      <td>Laboratory/Stock Room :</td>
      <td> 
        <%
		  if (vEditInfo!=null && vEditInfo.size()>0 && !WI.fillTextValue("pageReloaded").equals("1"))
       		strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(11),"");
	      else
	    	strTemp2 = WI.fillTextValue("room_idx_to");
		 %>
        <select name="room_idx_to">
          <option value="">N/A</option>
          <% //System.out.println("strBldgTo " + strBldgTo);
			// System.out.println("strTemp2bldg" + strTemp2);
		  	if (strBldgTo.length()>0){
			strBldgTo = " from E_ROOM_DETAIL join E_ROOM_BLDG on (E_ROOM_DETAIL.LOCATION = E_ROOM_BLDG.BLDG_NAME) where BLDG_INDEX = "+strBldgTo+
			" and E_ROOM_DETAIL.is_del = 0 order by ROOM_NUMBER";
		   %>
          <%=dbOP.loadCombo("ROOM_INDEX","ROOM_NUMBER", strBldgTo, strTemp2, false)%> 
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td colspan="4" height="51"><div align="center">&nbsp; <font size="1"> 
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1,"");'> <img src="../../../images/save.gif" border="0" name="hide_save"></a> 
          Click to add entry 
          <%}else{%>
          <a href='javascript:PageAction(2, "<%=(String)vEditInfo.elementAt(0)%>");'><img src="../../../images/edit.gif" border="0"></a> 
          Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
          Click to cancel 
          <%}%>
          </font></div></td>
    </tr>
  </table>
  <% if(vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="6" class="thinborder"><div align="center"> 
          <p><strong><font size="2">TRANSFER ITEMS</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td width="12%" height="25" class="thinborder"><div align="center"><font size="1"><strong>PROPERTY 
          # </strong></font></div></td>
      <td width="28%" class="thinborder"><div align="center"><font size="1"><strong>ITEM NAME/SERIAL #/PRODUCT #</strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>QTY 
          TRANSFERED </strong></font></div></td>
      <td width="24%" class="thinborder"><div align="center"><font size="1"><strong>ORIGINAL 
          LOCATION </strong></font></div></td>
      <td width="22%" class="thinborder"><div align="center"><font size="1"><strong>TRANSFER 
          LOCATION </strong></font></div></td>
      <td width="7%" align="center" class="thinborder"> <div align="left"><font size="1"><strong>&nbsp;</strong></font></div>
        <div align="center"></div></td>
    </tr>
   <%//	System.out.println("vRetResult.size() " + vRetResult.size());
   for (i = 0; i< vRetResult.size(); i+=23){%>
    <tr> 
      <td class="thinborder" height="25">&nbsp;</td>
      <td class="thinborder">&nbsp; </td>
      <td class="thinborder" align="center">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder"> <font size="1">&nbsp; </font> </td>
      <td class="thinborder">
      <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i+2)%>");'><img src="../../../images/edit.gif" border="0"></a>
      <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
      </td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <%}%>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="page_action">
   	<input type="hidden" name="print_pg">
   	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
   	<input type="hidden" name="focus_area">
	<input type="hidden" name="proceedclicked">
	<input type="hidden" name="pageReloaded">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>