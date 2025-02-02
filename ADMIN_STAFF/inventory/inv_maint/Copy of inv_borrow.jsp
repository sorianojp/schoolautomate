<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Inventory Maintenance - Borrow Item</title>
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
function OpenSearch()
{
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.borrow_by";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch2()
{
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.borrow_by";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchProperty(){
	var pgLoc = "./search_property.jsp?opner_info=form_.propnum&borrow=1&propnum="+document.form_.propnum.value;
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchTransaction(){
	var pgLoc = "./search_borrow.jsp?opner_info=form_.borrow_no";
	var win=window.open(pgLoc,"SearchTransaction",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
								"INVENTORY-INVENTORY MAINTENANCE","inv_borrow.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int i = 0;
	int iTemp = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;
	String strInvType = null;

	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

	InventoryMaintenance InvMaint = new InventoryMaintenance();

	if(strTemp.length() > 0) {
		if(InvMaint.operateOnBorrowItems(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else 
			strErrMsg = InvMaint.getErrMsg();
	}	
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = InvMaint.operateOnBorrowItems(dbOP, request, 3);	
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = InvMaint.getErrMsg();
	}
	
	vRetResult = InvMaint.operateOnBorrowItems(dbOP, request, 4);
	if (vRetResult == null && strErrMsg == null && WI.fillTextValue("borrow_no").length()>0)
		strErrMsg = InvMaint.getErrMsg();
%>

<body bgcolor="#D2AE72">
<form name="form_" action="inv_borrow.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - BORROW ITEM PAGE ::::</strong></font></div></td>
    </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5"><font size="1">&nbsp;<%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></td>
    </tr>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td width="20%"><strong>Borrow transaction #</strong></td>
      <td width="21%" >
      <%strTemp = WI.fillTextValue("borrow_no");%> 
      <input name="borrow_no" type="text" size="16" maxlength="32" value="<%=strTemp%>" class="textbox" 
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="6%" valign="middle"><font size="1"><a href="javascript:SearchTransaction();"><img src="../../../images/search.gif" alt="search" border="0"></a></font></td>
      <td width="50%" valign="middle">
      <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
      </td>
    </tr>
    <tr> 
      <td height="19" colspan="5"><hr size="1"></td>
    </tr>
	</table>
	<%if (WI.fillTextValue("borrow_no").length() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#C78D8D"> 
      <td height="30">&nbsp;</td>
      <td height="30" colspan="4"><strong><font color="#FFFFFF">BORROWING DETAILS</font></strong></td>
    </tr>
    <tr> 
      <td colspan="5" height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td colspan="2">Borrow Date :</td>
      <td height="30" colspan="2"> <%
      if (vEditInfo!=null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(18);
      else
    	  strTemp = WI.fillTextValue("borrow_date");%> <input name="borrow_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.borrow_date');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Borrowed by :</td>
      <td height="30" colspan="2" valign="middle"><label> <font size="1"></font></label></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="12%" align="right">ID Number:&nbsp;</td>
      <td width="30%" > <%if (vEditInfo != null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(9);
        else
    	  strTemp = WI.fillTextValue("borrow_by");%> <input name="borrow_by" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox" 
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="51%" height="30" valign="middle"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" hspace="0" vspace="0" border="0"></a><font size="1">Employee 
        search</font> <a href="javascript:OpenSearch2();"><img src="../../../images/search.gif" width="37" height="30" hspace="0" vspace="0" border="0"></a><font size="1">Student 
        search</font> </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Reason for use :</td>
      <td height="30" colspan="2" valign="middle"> <%
      if (vEditInfo!=null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(12);
      else
    	  strTemp = WI.fillTextValue("reason_index");%> <select name="reason_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("trans_reason_index","reason"," from inv_preload_trans_reason order by reason", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Full Reason : </td>
      <td colspan="2" valign="middle"> <%
      if (vEditInfo != null && vEditInfo.size()>0)
	      strTemp = WI.getStrValue((String)vEditInfo.elementAt(13),"");
      else
    	  strTemp = WI.fillTextValue("reason");%> 
        <textarea name="reason" cols="45" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" ><%=strTemp%></textarea> 
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Property #s : </td>
      <td colspan="2" valign="middle"> <%
      if (vEditInfo != null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(14);
      else
    	  strTemp = WI.fillTextValue("propnum");%> 
        <textarea name="propnum" rows="5" cols="55" class="textbox" 
	     onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=strTemp%></textarea> 
        <font size="1"><a href="javascript:SearchProperty();"><img src="../../../images/search.gif" alt="search" border="0"></a></font> 
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Return Date : </td>
      <td colspan="2"> 
	  <%
      if (vEditInfo!=null && vEditInfo.size()>0)
	      strTemp = WI.getStrValue((String)vEditInfo.elementAt(15),"");
      else
    	  strTemp = WI.fillTextValue("return_date");	  
	  %> <input name="return_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.return_date');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Return Time :</td>
      <td height="30" colspan="2" valign="middle"> <%
		if (vEditInfo!= null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(16),"");
		else
    	   strTemp = WI.fillTextValue("return_hr");%> <select name="return_hr">
          <option value="8">8 AM</option>
          <%if(strTemp.equals("9")){%>
          <option value="9" selected>9 AM</option>
          <%}else{%>
          <option value="9">9 AM</option>
          <%}if(strTemp.equals("10") ) {%>
          <option value="10" selected>10 AM</option>
          <%}else{%>
          <option value="10">10 AM</option>
          <%}if(strTemp.equals("11")) {%>
          <option value="11" selected>11 AM</option>
          <%}else{%>
          <option value="11">11 AM</option>
          <%}if(strTemp.equals("12")) {%>
          <option value="12" selected>12 PM</option>
          <%}else{%>
          <option value="12">12 PM</option>
          <%}if(strTemp.equals("13")) {%>
          <option value="13" selected>1 PM</option>
          <%}else{%>
          <option value="13">1 PM</option>
          <%}if(strTemp.equals("14")) {%>
          <option value="14" selected>2 PM</option>
          <%}else{%>
          <option value="14">2 PM</option>
          <%}if(strTemp.equals("15")) {%>
          <option value="15" selected>3 PM</option>
          <%}else{%>
          <option value="15">3 PM</option>
          <%}if(strTemp.equals("16")) {%>
          <option value="16" selected>4 PM</option>
          <%}else{%>
          <option value="16">4 PM</option>
          <%}if(strTemp.equals("17")) {%>
          <option value="17" selected>5 PM</option>
          <%}else{%>
          <option value="17">5 PM</option>
          <%}if(strTemp.equals("18")) {%>
          <option value="18" selected>6 PM</option>
          <%}else{%>
          <option value="18">6 PM</option>
          <%}if(strTemp.equals("19")) {%>
          <option value="19" selected>7 PM</option>
          <%}else{%>
          <option value="19">7 PM</option>
          <%}if(strTemp.equals("20")) {%>
          <option value="20" selected>8 PM</option>
          <%}else{%>
          <option value="20">8 PM</option>
          <%}if(strTemp.equals("21")) {%>
          <option value="21" selected>9 PM</option>
          <%}else{%>
          <option value="21">9 PM</option>
          <%}if(strTemp.equals("22")) {%>
          <option value="22" selected>10 PM</option>
          <%}else{%>
          <option value="22">10 PM</option>
          <%}if(strTemp.equals("23")) {%>
          <option value="23" selected>11 PM</option>
          <%}else{%>
          <option value="23">11 PM</option>
          <%}if(strTemp.equals("1")) {%>
          <option value="1" selected>1 AM</option>
          <%}else{%>
          <option value="1">1 AM</option>
          <%}if(strTemp.equals("2")) {%>
          <option value="2" selected>2 AM</option>
          <%}else{%>
          <option value="2">2 AM</option>
          <%}if(strTemp.equals("3")) {%>
          <option value="3" selected>3 AM</option>
          <%}else{%>
          <option value="3">3 AM</option>
          <%}if(strTemp.equals("4")) {%>
          <option value="4" selected>4 AM</option>
          <%}else{%>
          <option value="4">4 AM</option>
          <%}if(strTemp.equals("5")) {%>
          <option value="5" selected>5 AM</option>
          <%}else{%>
          <option value="5">5 AM</option>
          <%}if(strTemp.equals("6")) {%>
          <option value="6" selected>6 AM</option>
          <%}else{%>
          <option value="6">6 AM</option>
          <%}if(strTemp.equals("7")) {%>
          <option value="7" selected>7 AM</option>
          <%}else{%>
          <option value="7">7 AM</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="48">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td height="48" colspan="2" valign="middle"><font size="1"> 
        <%
		if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'> <img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to cancel 
        <%}%>
        </font></td>
    </tr>
  </table>  
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="3" class="thinborder"><div align="center"> 
          <p><strong><font size="2">BORROW ITEM DETAILS</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td width="13%" height="25" class="thinborder" align="center"><font size="1"><strong>PROPERTY 
        NO.</strong></font></td>
      <td width="39%" class="thinborder" align="center"><font size="1"><strong>ITEM 
        DETAILS</strong></font></td>
      <td width="33%" class="thinborder" align="center"><strong><font size="1">DETAIL</font></strong></td>
    </tr>
    <% 
	for (i =0; i<vRetResult.size(); i+=18){%>
    <tr> 
      <td class="thinborder" height="37"><font size="1"><%=(String)vRetResult.elementAt(i+15)%></font></td>
      <td class="thinborder"><font size="1">Item Name: <%=(String)vRetResult.elementAt(i+2)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+17),"<br>Product No: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+16),"<br>Serial No: ","","")%> </font></td>
      <td class="thinborder"><font size="1">Borrowed Date <%=(String)vRetResult.elementAt(i+14)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+12),"<br>Due Date: ","","")%> </font></td>
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
   	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>