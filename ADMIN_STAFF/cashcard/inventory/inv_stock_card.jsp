<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date, java.util.Calendar, 
																hmsOperation.RestItems" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css" />
<title>Item Stock Card</title>
<script language="JavaScript" src="../../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" type="text/javascript">
function ReloadPage(){
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');	
}

function CancelRecord() 
{
	location = "./inv_stock_card.jsp"; 
}

function PrintPg(){
	document.form_.print_pg.value = 1;
	this.SubmitOnce('form_');
}
 function focusCode(){
	document.form_.item_code.focus();
} 

function AjaxSearchCode() {
	var objCOAInput = document.getElementById("item_code_");
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strCode = document.form_.item_code.value;
			
	if(strCode.length <= 2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=500&item_code="+escape(strCode);
	
	this.processRequest(strURL);
} 

function updateItemCode(strCode, strItemMFIndex) {
	document.form_.item_code.value = strCode;
	document.getElementById("item_code_").innerHTML = "";
	//"<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}

</script>
</head>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
	if (WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./rest_inv_stock_card_print.jsp"/>
	  
		<% 
	return;}		
	 	
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Inventory","inv_stock_card.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"CASH CARD","Inventory",request.getRemoteAddr(),
														"inv_stock_card.jsp");
	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	RestItems restItems = new RestItems();
	Vector vItemInfo = null;
	Vector vRetResult = null;
	boolean bolHasBeginning = false;
	int iSearchResult = 0;
	String strEntryType = null;
	double dBalance = 0d;
	double dTemp  = 0d;
	int i = 0;
	
	Calendar calTemp = Calendar.getInstance();
	String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};
	String strMonths = WI.fillTextValue("month_of");
 	String strYear = WI.fillTextValue("year_of");
	if(strMonths.length() == 0)
		strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
	if(strYear.length() == 0)
		strYear = Integer.toString(calTemp.get(Calendar.YEAR));

	
	String strShowOpt = WI.getStrValue(WI.fillTextValue("DateDefaultSpecify"), "1");
		
	vItemInfo = restItems.getRestItemInfo(dbOP,request);
	if(vItemInfo == null)
		strErrMsg = restItems.getErrMsg();
		
	if(vItemInfo != null && vItemInfo.size() > 0){
		vRetResult = restItems.viewItemLedger(dbOP, request, (String)vItemInfo.elementAt(0));
		if(vRetResult == null)
			strErrMsg = restItems.getErrMsg();
		else
			iSearchResult = restItems.getSearchCount();
	}
%>
<body bgcolor="#eeeeee" topmargin="0" onload="focusCode();">
<form action="inv_stock_card.jsp" method="post" name="form_">
  <jsp:include page="./tabs.jsp?pgIndex=3"></jsp:include> 
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="21" colspan="3"><font size="+1" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  <tr>
    <td width="19%" height="25" align="right"><b><font color="#000066">Item Code : </font></b></td>
    <td width="17%" height="25"><font color="#000066">
      <input name="item_code" type="text" size="20" maxlength="16"  
			onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
			onkeyup="AjaxSearchCode();" value="<%=WI.fillTextValue("item_code")%>"/>
    </font></td>
    <td width="64%"><label id="item_code_" style="position:absolute; width:400px;"></label></td>
  </tr>
  <tr>
    <td height="25" align="right"><strong><font color="#000066">Canteen  : </font></strong></td>
    <td height="25" colspan="2"><select name="restaurant_index" onchange="ReloadPage();">
      <% strTemp= WI.fillTextValue("restaurant_index");%>
      <option value="">Select</option>
      <%=dbOP.loadCombo("TERMINAL_DEPT_INDEX","DEPT_NAME", " from CC_TERMINAL_DEPT where is_valid = 1 " +
												" order by DEPT_NAME",strTemp,false)%>
    </select></td>
  </tr>
  <tr>
    <td height="25" align="right"><strong><font color="#000066">Date View Option&nbsp;</font></strong> </td>
    <td height="25" colspan="2"><select name="DateDefaultSpecify" onchange='ReloadPage();'>
      <option value="1">Specify date</option>
      <% if (WI.fillTextValue("DateDefaultSpecify").equals("2")){ %>
      <option value="2" selected="selected">Month / year</option>
      <%}else{%>
      <option value="2">Month / year</option>
      <%}%>
    </select></td>
  </tr>
	<%if (strShowOpt.equals("1")){%>
  <tr>
    <td height="25" align="right"><strong><font color="#000066">Specific Date range&nbsp;</font></strong></td>
    <td height="25" colspan="2">From
      <input name="from_date" type="text" size="10" maxlength="10"
	  value="<%=WI.fillTextValue("from_date")%>" class="textbox"
	  onkeyup="AllowOnlyIntegerExtn('form_','from_date','/');"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','from_date','/')" />
      <a href="javascript:show_calendar('form_.from_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0" /></a> &nbsp;&nbsp;to
        &nbsp;&nbsp;
        <input name="to_date" type="text" size="10" maxlength="10"
		value="<%=WI.fillTextValue("to_date")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'"
		onkeyup = "AllowOnlyIntegerExtn('form_','to_date','/')"
		onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','to_date','/')" />
        <a href="javascript:show_calendar('form_.to_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0" /></a></td>
  </tr>
	<%}else if (strShowOpt.equals("2")) {%>
  <tr>
    <td height="25" align="right"><strong><font color="#000066">Month / Year&nbsp;</font></strong></td>
    <td height="25" colspan="2"><select name="month_of">
      <%
	  int iDefMonth = Integer.parseInt(strMonths);
	  	for (i = 1; i <= 12; ++i) {
	  		if (iDefMonth == i)
				strTemp = " selected";
			else
				strTemp = "";
	   %>
      <option value="<%=i%>" <%=strTemp%>><%=astrMonth[i]%></option>
      <%} // end for lop%>
    </select>
-
<select name="year_of">
  <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
</select></td>
  </tr>
	<%}%>
  <tr>
    <td height="25" align="right">&nbsp;</td>
		<%
			strTemp = WI.fillTextValue("view_all");
			if(strTemp.equals("1"))
				strTemp = " checked";
			else
				strTemp = "";
		%>
    <td height="25" colspan="2"><input type="checkbox" name="view_all" value="1" <%=strTemp%>>
    view all results</td>
  </tr>
  <tr>
    <td height="25" align="right">&nbsp;</td>
    <td height="25" colspan="2"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onclick="javascript:ReloadPage();" />
      <font size="1">click to display item information</font></td>
  </tr>
  <tr>
    <td height="10" colspan="3"><hr size="1" /></td>
  </tr>
</table>
<%if(vItemInfo != null && vItemInfo.size() > 0){%>
<table width="100%" border="0" cellpadding="1" cellspacing="1">
  <tr>
    <td width="16%" height="25" align="right"><b><font color="#000066"><strong><font color="#000066">Item Name  :</font></strong></font></b></td>
		<%
			strTemp = (String)vItemInfo.elementAt(4);
		%>
    <td width="29%" height="25"><b><font color="#000066">&nbsp;<%=strTemp%></font></b></td>
    <td width="16%" height="25" align="right"><strong><font color="#000066">Purchase Unit  : </font></strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(6);
		%>
    <td width="39%"><b><font color="#000066">&nbsp;<%=WI.getStrValue(strTemp)%></font></b></td>
  </tr>
  <tr>
    <td height="25" align="right"><strong><font color="#000066">Item Code  :</font></strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(3);
		%>
    <td height="25"><b><font color="#000066">&nbsp;<%=strTemp%></font></b></td>
    <td align="right"><strong><font color="#000066">Selling Unit  : </font></strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(8);
		%>
    <td><b><font color="#000066">&nbsp;<%=WI.getStrValue(strTemp)%></font></b></td>
  </tr>
  <tr>
    <td height="25" align="right"><b><font color="#000066">Category 
      :</font></b></td>
		<%
			strTemp = (String)vItemInfo.elementAt(2);
		%>
    <td height="25"><b><font color="#000066">&nbsp;<%=strTemp%></font></b></td>
    <td align="right"><strong><font color="#000066">Conversion  :</font></strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(9);
		%>
    <td><b><font color="#000066">&nbsp;<%=WI.getStrValue(strTemp)%></font></b></td>
  </tr>
  <tr>
    <td height="27" align="right"><strong><font color="#000066">Selling Price  :</font></strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(10);
			strTemp = CommonUtil.formatFloat(strTemp, true);
		%>
    <td height="27"><b><font color="#000066">&nbsp;<%=strTemp%></font></b></td>
    <td align="right"><strong><font color="#000066">Current Balance :</font></strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(15);
		%>
    <td><b><font color="#000066">&nbsp;<%=WI.getStrValue(strTemp)%></font></b></td>
  </tr>
  <tr>
    <td height="27" align="right"><b><font color="#000066">Item Cost :</font></b></td>
		<%
			strTemp = (String)vItemInfo.elementAt(14);
			strTemp = CommonUtil.formatFloat(strTemp, true);
		%>
    <td height="27"><b><font color="#000066">&nbsp;<%=strTemp%></font></b></td>
    <td align="right"><strong><font color="#000066">Reorder Qty. :</font></strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(13);
			if(WI.getStrValue(strTemp).equals("1"))			
				strTemp = (String)vItemInfo.elementAt(16);
			else
				strTemp = "n/a";
			
		%>
    <td><b><font color="#000066">&nbsp;<%=strTemp%></font></b></td>
  </tr>
  <tr>
    <td height="10" colspan="4">&nbsp;</td>
  </tr>
</table>
	<%}%>
 <%if(vRetResult != null && vRetResult.size() > 0){%>
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
		<%
		if(WI.fillTextValue("view_all").length() == 0){
		int iPageCount = iSearchResult/restItems.defSearchSize;
		if(iSearchResult % restItems.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1){
		%>
   <tr>
     <td align="right">
				Jump To page:
          <select name="jumpto" onchange="ReloadPage();">
            <%
					strTemp = request.getParameter("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
					 for(i = 1; i <= iPageCount; ++i){
						if(i == Integer.parseInt(strTemp) ){%>
            <option selected="selected" value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
				   }
					}
					%>
          </select>
		 </td>
   </tr>
	<%}
		 }%>
   <tr>
     <td align="right"><font size="2">Number of records per page :</font>
         <select name="num_rec_page">
           <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i =20; i <=45 ; i++) {
				if ( i == iDefault) {%>
           <option selected="selected" value="<%=i%>"><%=i%></option>
           <%}else{%>
           <option value="<%=i%>"><%=i%></option>
           <%}
			}%>
         </select>
         <input type="button" name="cancel3" value=" Print " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onclick="javascript:PrintPg();" />
       <font color="#000066">Click to PRINT listing</font></td></tr>
 </table>
 <table width="100%" height="54" border="0" cellpadding="0" cellspacing="0">  
  <tr>
    <td width="12%" height="25" align="center" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><font color="#000066" size="1"><b>DATE</b></font></td>
    <td width="40%" align="center" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><b><font color="#000066" size="1">PARTICULAR</font></b></td>
    <td width="12%" align="center" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><b><font color="#000066" size="1">STOCK IN </font></b></td>
    <td width="12%" align="center" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><b><font color="#000066" size="1">STOCK OUT </font></b></td>
    <td width="12%" align="center" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><b><font color="#000066" size="1">ADJUSTMENT</font></b></td>
    <td width="12%" align="center" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><b><font color="#000066" size="1">BALANCE  </font></b></td>
  </tr>
	<% 
 	for(i = 0;i < vRetResult.size(); i+=9){
		strEntryType = (String)vRetResult.elementAt(i+5);
		strEntryType = WI.getStrValue(strEntryType);
		if(!bolHasBeginning && strEntryType.equals("2"))
			bolHasBeginning = true;		
	%>
  <tr>
    <td height="21" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
		<%
			strTemp = (String)vRetResult.elementAt(i+4);
		%>
    <td bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
			strTemp = "";
			dTemp  = 0d;
			if(strEntryType.equals("1") || strEntryType.equals("2")){
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+1),"0");
				dTemp = Double.parseDouble(strTemp);
				if(bolHasBeginning)
					dBalance += dTemp;
			}
			strTemp = CommonUtil.formatFloat(strTemp, false);
			if(dTemp == 0d)
				strTemp = "";
		%>
    <td align="right" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+2),"0");
			dTemp = Double.parseDouble(strTemp);
			if(bolHasBeginning)
				dBalance -= dTemp;
				
			strTemp = CommonUtil.formatFloat(strTemp, false);
			if(dTemp == 0d)
				strTemp = "";			
		%>		
    <td align="right" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
		<%
			dTemp  = 0d;
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3),"0");			
			if(bolHasBeginning){
				strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+6));
				dTemp = Double.parseDouble(strTemp);
				if(strTemp2.equals("1")){
					dBalance += dTemp;
					strTemp = CommonUtil.formatFloat(strTemp, false);				
				}else if(strTemp2.equals("2")){
					dBalance -= dTemp;
					strTemp = "(" + CommonUtil.formatFloat(strTemp, false) + ")";
				}
			}
			
			if(dTemp == 0d)
				strTemp = "";			
		%>	
		<td align="right" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
		<%
			if(bolHasBeginning)
				strTemp = CommonUtil.formatFloat(dBalance, false);
			else
				strTemp = "&nbsp;";
		%>
    <td align="right" bgcolor="#D3D3D3" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
  </tr>
	<%}%>
 </table>
	<%}%>
 <table width="100%" height="22" border="0" cellpadding="0" cellspacing="0">  
  <tr>
    <td height="15" colspan="5" align="right">&nbsp; </td>
  </tr>
</table>
	<input type="hidden" name="print_pg"> 
	<input type="hidden" name="page_action"> 	
	<input type="hidden" name="show_stockin" value="1">
</form>
  </body>
</html>
<%
dbOP.cleanUP();
%>