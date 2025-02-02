<%@ page language="java" import="utility.*,purchasing.PO,purchasing.Requisition,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();		
	
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
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage(){	
  document.form_.printPage.value = "";	
	if(document.form_.cat_index)
	 	document.form_.category_name.value = document.form_.cat_index[document.form_.cat_index.selectedIndex].text;
	this.SubmitOnce('form_');
}

function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}

function ChangeType(){
	document.form_.cat_index.value = "";
	document.form_.category_name.value = "";	
	this.SubmitOnce('form_');
}

</script>
<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="./purchase_report_print.jsp"/>
	<%}
 	
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
								"Admin/staff-PURCHASING-PURCHASE ORDER-Approved Requests","purchase_report.jsp");
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
	Vector vRetResult = null;
	Vector vPOItems = null;	
	int iSearch = 0;
	int iDefault = 0;
	boolean bolLooped = false;
	String[] astrSupplyType = {"Non-Supplies / Equipmment","Supplies","Chemical","Computers/Parts"};	
	String[] astrSortByName    = {"Item Name","PO Number","Price"};
	String[] astrSortByVal     = {"item_name","po_number","unit_price"};
	String strSupply = null;
	String strCategory = null;
	String strItem  = null;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = PO.searchItemsOrdered(dbOP,request);
		if(vRetResult == null)
			strErrMsg = PO.getErrMsg();
		else
			iSearch = PO.getSearchCount();
	}
	
%>
<form name="form_" method="post" action="purchase_report.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PURCHASE </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>ORDER</strong></font><font color="#FFFFFF"><strong> 
          - VIEW/SEARCH PO PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%">Inventory Type</td>
      <td width="81%">
			<%
			strSupply = WI.fillTextValue("is_supply");
		  %>
        <select name="is_supply" onChange="ChangeType();">
          <option value="">ALL</option>
          <%for(int i = 0; i < 4; i++){%>
          <%if(strSupply.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected><%=astrSupplyType[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrSupplyType[i]%></option>
          <%}%>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td> Item Category</td>
      <td>
			<%
			strCategory = WI.fillTextValue("cat_index");
		  %>
        <select name="cat_index" onChange="ReloadPage();">
          <option value="">Select Category</option>
          <%=dbOP.loadCombo("inv_cat_index","inv_category"," from inv_preload_category " +
		  					WI.getStrValue(strSupply,"where is_supply_cat = ","","") +								
								"order by inv_category", strCategory, false)%>
        </select>
      <input type="hidden" name="category_name" value="<%=WI.fillTextValue("category_name")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Item :</td>
      <td>
			<%
	  	strTemp = WI.fillTextValue("item");
			strItem = WI.getStrValue(strTemp,"-1");
	  %>
        <select name="item" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("item_index","item_name"," from pur_preload_item " +
					WI.getStrValue(WI.getStrValue(strCategory,"")," where inv_cat_index =","","") +
 		  " order by ITEM_NAME asc",strItem, false)%>
        </select></td>
    </tr>
    
    <tr>
      <td height="27">&nbsp;</td>
      <td>PO Date</td>
      <td>
        <%strTemp = WI.fillTextValue("po_date_fr");%>
        <input name="po_date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.po_date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("po_date_to");%>
        <input name="po_date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.po_date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20"><hr size="1" color="#000000"></td>
    </tr>
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
		<tr> 
			<td  width="3%" height="25">&nbsp;</td>
			<td width="10%">Sort by</td>
			<td width="25%">
		<select name="sort_by1">
		<option value="">N/A</option>
					<%=PO.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
			</select></td>
			<td width="25%"><select name="sort_by2">
		<option value="">N/A</option>
					<%=PO.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
				</select></td>
			<td width="36%"><select name="sort_by3">
		<option value="">N/A</option>
					<%=PO.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
				</select></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td><select name="sort_by1_con">
				<option value="asc">Ascending</option>
				<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
				<option value="desc" selected>Descending</option>
				<%}else{%>
				<option value="desc">Descending</option>
				<%}%>
			</select></td>
			<td><select name="sort_by2_con">
				<option value="asc">Ascending</option>
				<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
				<option value="desc" selected>Descending</option>
				<%}else{%>
				<option value="desc">Descending</option>
				<%}%>
			</select></td>
			<td><select name="sort_by3_con">
				<option value="asc">Ascending</option>
				<% if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
				<option value="desc" selected>Descending</option>
				<%}else{%>
				<option value="desc">Descending</option>
				<%}%>
			</select></td>
		</tr>
		<tr>
			<td height="19">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2"><font size="1">
				<input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ProceedClicked();">
			</font></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="18">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
	</table>	
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<%if(!(WI.fillTextValue("opner_info").length() > 0)){%>
    <tr>
			<%
				strTemp = WI.fillTextValue("prepared_by");
			%>		
      <td width="15%" height="28">Prepared by :      </td>
      <td width="85%" height="28"><input type="text" name="prepared_by" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
			<%
				strTemp = WI.fillTextValue("conforme");
			%>		
      <td height="28">Conforme:      </td>
      <td height="28"><input type="text" name="conforme" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="28" colspan="2"><div align="right">Number of PO(s) Per Page: 
          <select name="num_stud_page">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1"> click to print list&nbsp;</font></div></td>
    </tr>
	<%}%>
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr> 
      <td height="10">
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=PO.getDisplayRange()%>)</font></strong>
     <%
		int iPageCount = iSearch/PO.defSearchSize;
		double dTotalItems = 0d;
		double dTotalAmount = 0d;
		if(iSearch % PO.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%>
		&nbsp;</td>
		
      <td> <div align="right">Jump to page: 
          <select name="jumpto" onChange="ProceedClicked();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
				}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292" colspan="2" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF PURCHASED ITEMS</strong></font></div></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="47%" align="center" class="thinborder"><strong>ITEM DESCRIPTION </strong></td>
      <td width="17%" align="center" class="thinborder"><strong>SUPPLIES</strong></td> 
      <td width="14%" height="21" align="center" class="thinborder"><strong>PO NO.</strong></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>UNIT 
          PRICE</strong></font></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong><strong>TOTAL 
          PRICE</strong></strong></font></td>
    </tr>
    <% 
	for(int i = 0;i < vRetResult.size();i+=7){
 	%>
    <tr>
      <td valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i)%>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"/","","")%></font></td>
      <td valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%> <%=(String)vRetResult.elementAt(i+3)%></font></td> 
      <td height="25" valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
			%>
      <td align="right" valign="top" class="thinborder"><font size="1"><%=strTemp%></font></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
			%>			
      <td align="right" valign="top" class="thinborder"><font size="1"><%=strTemp%></font></td>
    </tr>
    <%
 	}%>
  </table>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
  </table>
  <%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="18" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="isForPO" value="1">
  <input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
  <input type="hidden" name="status" value="1">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>