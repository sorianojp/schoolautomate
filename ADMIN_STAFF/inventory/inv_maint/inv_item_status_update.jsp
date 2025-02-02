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
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value= strAction;
	this.SubmitOnce("form_");
}
function ReloadPage()
{
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
function CountDown()
{
	alert(document.form_.timeLeft.value);
}

function SearchProperty(){
	var pgLoc = "./search_property.jsp?opner_info=form_.prop_num";
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
								"INVENTORY-INVENTORY LOG","inv_item_status_update.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vItemData = null;

	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;

	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

	InventoryMaintenance InvMaint = new InventoryMaintenance();
	InventoryLog InvLog = new InventoryLog();

	if (WI.fillTextValue("prop_num").length()>0) {		
		if(strTemp.length() > 0) {
			if(InvMaint.operateOnStatusUpdate(dbOP, request, Integer.parseInt(strTemp)) != null ){
				strErrMsg = "Operation successful.";
				strPrepareToEdit = "0";
			} else 
			strErrMsg = InvMaint.getErrMsg();
		}
	
		if(strPrepareToEdit.compareTo("1") == 0) {
			vEditInfo = InvMaint.operateOnStatusUpdate(dbOP, request, 3);
			if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = InvMaint.getErrMsg();
		}

		vItemData = InvLog.viewPropertyDetails(dbOP, WI.fillTextValue("prop_num"), true);
		if (vItemData == null)	
			strErrMsg = InvLog.getErrMsg();
			
		vRetResult = InvMaint.operateOnStatusUpdate(dbOP, request, 4);
		if (vRetResult == null && strErrMsg == null)
			strErrMsg = InvMaint.getErrMsg();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="inv_item_status_update.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - ITEM STATUS UPDATE PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;<font size="3" color="red"><%=WI.getStrValue(strErrMsg,"")%></font></td>
    </tr>
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td width="20%"><strong>Property number </strong></td>
      <td width="20%">
      <%strTemp = WI.fillTextValue("prop_num");%> 
      <input name="prop_num" type="text" size="16" maxlength="32" value="<%=strTemp%>" class="textbox" 
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="9%"><font size="1"><a href="javascript:SearchProperty();"><img src="../../../images/search.gif" alt="search" border="0"></a></font></td>
      <td width="48%" align="left"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
	<%if (vItemData != null && vItemData.size()>0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4" bgcolor="#C78D8D"><strong><font color="#FFFFFF">PROPERTY 
        DETAILS</font></strong></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="4"><strong><u>PROPERTY DESCRIPTION</u></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">Category : <strong><%=WI.getStrValue((String)vItemData.elementAt(5),"Unknown")%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">Description : <strong><%=(String)vItemData.elementAt(1)%></strong></td>
      <td width="34%">&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="31%">Property Number : <strong><%=(String)vItemData.elementAt(6)%></strong></td>
      <td width="29%">Serial Number : <strong><%=WI.getStrValue((String)vItemData.elementAt(7),"Unknown")%></strong></td>
      <td>Product Number : <strong><%=WI.getStrValue((String)vItemData.elementAt(8),"Unknown")%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Log Date : <strong><%=WI.getStrValue((String)vItemData.elementAt(18),"Unknown")%></strong></td>
      <td>Warranty Until : <strong><%=WI.getStrValue((String)vItemData.elementAt(19),"Unknown")%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">Supplier : <strong><%=WI.getStrValue((String)vItemData.elementAt(15),"Unknown")%></strong></td>
    </tr>
    <tr>
    	<td colspan="5"><hr size="1"></hr></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="4"><strong><u>LOCATION</u></strong></td>
    </tr>
    <%
				strTemp = (String)vItemData.elementAt(10);
				if(strTemp != null && strTemp.length() > 0){
		%>
		<tr> 
      <td height="26">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td colspan="3">College : <strong><%=strTemp%></strong></td>
    </tr>
		<%}%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">Department : <strong><%=WI.getStrValue((String)vItemData.elementAt(11),"&nbsp;")%></strong></td>
    </tr>

    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">Building : <strong><%=WI.getStrValue((String)vItemData.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <tr>
      <td height="35">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">Room : <strong><%=WI.getStrValue((String)vItemData.elementAt(13),"Unknown")%></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#C78D8D"> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2" height="25" valign="middle"><font color="#FFFFFF"><strong>STATUS 
        DETAILS</strong></font></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>Current Status : </td>
			<%
				if (vItemData != null && vItemData.size() > 0)
					strTemp = (String)vItemData.elementAt(16);
			%>
      <td><%=strTemp%></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td width="15%">Status:</td>
      <td width="82%"> <%
		if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(4);
		else
			strTemp = WI.fillTextValue("stat_index");%> <select name="stat_index">
          <option value="">Select category</option>
          <%=dbOP.loadCombo("inv_stat_index","inv_status"," from inv_preload_status " + 
					" where is_default = 0 order by inv_status", strTemp, false)%> </select>
        <font size="1"><a href='javascript:viewList("inv_preload_status","inv_stat_index","inv_status","INVENTORY STATUS",
						"inv_item, inv_stat_update_log","inv_stat_index, status_fr",
						"and inv_item.is_valid = 1, and inv_stat_update_log.is_valid = 1","is_default = 0","stat_index")'><img src="../../../images/update.gif" border="0"></a>						
        click to update STATUS list</font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Remarks: </td>
      <td><%
		if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(9),"");
		else
			strTemp = WI.fillTextValue("remark");%> <textarea name="remark" cols="45" rows="2" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>      </td>
    </tr>
    <tr> 
      <td height="35" colspan="3"><div align="center"><font size="1"> 
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1,"");'> <img src="../../../images/save.gif" border="0" name="hide_save"></a> 
          Click to add entry 
          <%}else{%>
          <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
          Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
          Click to cancel 
          <%}%>
          </font></div></td>
    </tr>
  </table>
  <%if (vRetResult!=null && vRetResult.size()>0) {%>
 <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="6" class="thinborder"><div align="center"> 
          <p><strong><font size="2" color="#FFFFFF">STATUS UPDATE LOG</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder" align="center" width="15%"><font size="1"><strong>UPDATE DATE</strong></font></td>
      <td class="thinborder" align="center" width="20%"><strong><font size="1">UPDATED BY</font></strong></td>
      <td class="thinborder" align="center" width="15%"><strong><font size="1">STATUS FROM</font></strong></td>
      <td class="thinborder" align="center" width="15%"><strong><font size="1">STATUS TO</font></strong></td>
      <td class="thinborder" align="center" width="25%"><strong><font size="1">REMARKS</font></strong></td>
      <td align="center" class="thinborder" width="10%">&nbsp; </td>
    </tr>
	<%for ( i = 0; i< vRetResult.size(); i+=10) {%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+6),(String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+8),7)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></font></td>
	  <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td class="thinborder">&nbsp;<font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"")%></font></td>
      <td class="thinborder" align="center">
      <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
      </td>
    </tr>
    <%}%>
  </table>
<%		}//if result exists
	} //if item details are found%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="page_action">
   	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>