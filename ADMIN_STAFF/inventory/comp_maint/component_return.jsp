<%@ page language="java" import="utility.*, inventory.InvCPUMaintenance, java.util.Vector"%>
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
function CheckRange(iRangeFr, iRangeTo)
{
	if (iRangeFr.length == 0 || iRangeTo.length == 0)
		return;	

	if (eval('document.form_.selAll'+iRangeFr+'.checked') ){
		for (var i = eval(iRangeFr) ; i <= eval(iRangeTo) ;++i)
			eval('document.form_.item_idx'+i+'.checked=true');
	}
	else
		for (var i = eval(iRangeFr) ; i <= eval(iRangeTo) ;++i)
			eval('document.form_.item_idx'+i+'.checked=false');
		
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.return_by";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchTransaction(){
	var pgLoc = "./search_comp_borrow.jsp?opner_info=form_.borrow_no&item_type=0";
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-COMP_MAINTENANCE"),"0"));
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
								"INVENTORY-COMP_MAINTENANCE","component_return.jsp");
	
	Vector vRetResult = null;
	Vector vItems = null;
	Vector vTemp = null;
	int i = 0;
	int iCtr = 0;
	int iMax = 0;
	int iTemp = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;

	strTemp = WI.fillTextValue("page_action");

	InvCPUMaintenance CPUMaint = new InvCPUMaintenance();

	if(strTemp.length() > 0) {
		if(CPUMaint.operateOnReturnComponent(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else 
			strErrMsg = CPUMaint.getErrMsg();
	}

	vItems = CPUMaint.operateOnReturnComponent(dbOP, request, 5);
	if (vItems == null && WI.fillTextValue("borrow_no").length()>0)
		strErrMsg = CPUMaint.getErrMsg();
		
	vRetResult = CPUMaint.operateOnReturnComponent(dbOP, request, 4);
	if (vRetResult != null)
		iSearchResult = CPUMaint.getSearchCount();
	else if (vRetResult == null && WI.fillTextValue("borrow_no").length()>0 && strErrMsg == null)
		strErrMsg = CPUMaint.getErrMsg();
%><body bgcolor="#D2AE72">
<form name="form_" action="component_return.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAINTENANCE - RETURN ITEM PAGE ::::</strong></font></div></td>
    </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5"><font size="3"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></td>
    </tr>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td width="20%"><strong>Borrow transaction #</strong></td>
      <td width="21%" valign="middle">
      <%strTemp = WI.fillTextValue("borrow_no");%> 
      <input name="borrow_no" type="text" size="16" maxlength="32" value="<%=strTemp%>" class="textbox" 
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="6%" valign="middle"><font size="1"><a href="javascript:SearchTransaction();"><img src="../../../images/search.gif" alt="search" border="0"></a></font></td>
      <td width="50%" valign="middle"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
	</table>
  <%if (vItems!=null && vItems.size()>0) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
 	<tr> 		
      <td colspan="4" bgcolor="C78D8D" height="25"><font color="#FFFFFF"><strong>&nbsp; 
        &nbsp;&nbsp;&nbsp;UNRETURNED ITEMS</strong></font></td>
 	</tr>
	<%	
	for (i = 0; i < vItems.size(); i+=5,++iMax){
	%>
 	<tr>
	 	<input name="b_index<%=iMax%>" type="hidden" value="<%=(String)vItems.elementAt(i)%>"> 		
      <td align="center" width="25%" height="25"><div align="left"><font color="#000000" size="1"> 
          &nbsp;&nbsp;<%=(i/5)+1%>: <%=((String)vItems.elementAt(i+3)).toUpperCase()%><%=WI.getStrValue((String)vItems.elementAt(i+2),"(",")","")%></font></div></td>
 		<td align="center" width="5%"><font size="1">
 		<%strTemp = WI.fillTextValue("item_idx"+iMax);
 		if (strTemp.length()>0) {%>
		<input name="item_idx<%=iMax%>" value="<%=(String)vItems.elementAt(i+1)%>" type="checkbox" checked><%} else {%>
 		<input name="item_idx<%=iMax%>" value="<%=(String)vItems.elementAt(i+1)%>" type="checkbox"><%}%></font></td>	
 		<td align="left" width="17%"><%strTemp = WI.fillTextValue("stat_index"+iMax);%>
		<select name="stat_index<%=iMax%>" style="font-size:9px">
          <option value="">Select status</option>
		<%=dbOP.loadCombo("inv_stat_index","inv_status"," from inv_preload_status " + 
		" where is_default = 0 order by inv_status", strTemp, false)%>
    </select></td>	
 		<td align="left" width="53%">
 		<%strTemp = WI.fillTextValue("reason"+iMax);%>
            <input name="reason<%=iMax%>" type="text" size="32" maxlength="512" value="<%=strTemp%>" class="textbox" 
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
	</tr>
	<%}// if there are borrowed items%>
  </table>
  <%}//if there is a result%>
  <%if (WI.fillTextValue("borrow_no").length() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
    <tr bgcolor="#C78D8D"> 
      <td height="30">&nbsp;</td>
      <td height="30" colspan="2"><strong><font color="#FFFFFF">RETURN DETAILS</font></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td width="13%"> Return Date :</td>
      <td width="84%" height="30" valign="middle">
       <%strTemp = WI.fillTextValue("return_date");
       if (strTemp.length()==0)
       		strTemp = WI.getTodaysDate(1);%>
      <input name="return_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
    <a href="javascript:show_calendar('form_.return_date');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td > Return Hour :</td>
      <td height="30" valign="middle">
       <%strTemp = WI.fillTextValue("ret_hr");%>
        <select name="ret_hr">
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
        </select>
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td >Returned by :</td>
      <td height="30" valign="middle">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td align="right">ID Number:&nbsp;</td>
      <td>
      <input name="return_by" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("return_by")%>" class="textbox" 
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="65">&nbsp;</td>
      <td >&nbsp;</td>
      <td valign="middle"><font size="1">
      <a href='javascript:PageAction(1,"");'>
     <img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry </font></td>
    </tr>
  </table>
  <%}%>
<%if (vRetResult != null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="8" class="thinborder" align="center"><strong>
      <font size="2" color="#FFFFFF">RETURNED ITEMS</font></strong></td>
    </tr>
    <tr>
    <td  height="25" colspan="4" class="thinborderBOTTOMLEFT" align="left"><font size="1"><strong>TOTAL 
          ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
      <td colspan="3" align="right" class="thinborderBOTTOM"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/CPUMaint.defSearchSize;
		if(iSearchResult % CPUMaint.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%><select name="jumpto" onChange="ReloadPage();" style="font-size:11px">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%	}
			}// end page printing
			%>
          </select>
          <%} else {%>&nbsp;<%} //if no pages %></td>
    </tr>
    <tr> 
      <td width="10%" height="25" class="thinborder"><div align="center"><strong>Property 
          # </strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>ITEM 
          DETAILS</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1">BORROWER'S 
          DETAIL</font></strong></div></td>
     
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1">ACTUAL 
          RETURN DETAIL </font></strong></div></td>
      <td width="18%" class="thinborder"><div align="center"><strong><font size="1">RETURNED 
          BY</font></strong></div></td>
      <td width="18%" class="thinborder"><div align="center"><strong><font size="1">STATUS 
          / REMARKS</font></strong></div></td>
			<!--
      <td width="8%" align="center" class="thinborder">&nbsp; </td>
			-->
    </tr>
	<%for (i = 0; i< vRetResult.size(); i+=19) {%>
    <tr> 
      <td class="thinborder" height="25" align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><font size="1">
      <strong>Item Name:</strong> <%=(String)vRetResult.elementAt(i+3)%><br>
 	  <strong>Category:</strong> <%=(String)vRetResult.elementAt(i+2)%>
 	  <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"<br><strong>Product No :</strong> ","","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"<br><strong>Serial No :</strong> ","","")%>	
 	  </font>
      </td>
      <td class="thinborder"><font size="1">
      <strong>ID number: </strong><%=(String)vRetResult.elementAt(i+9)%><br>
       <strong>Name: </strong><br><%=WI.formatName((String)vRetResult.elementAt(i+6),(String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+8),7)%><br>
	   <strong>Borrow Date: </strong><%=(String)vRetResult.elementAt(i+10)%></font>
      </td>
      <td class="thinborder">
      <font size="1">
      <strong>Return date: </strong><%=WI.getStrValue((String)vRetResult.elementAt(i+11),"Undefined")%><br>
      <strong>Return time: </strong>
      <%if (vRetResult.elementAt(i+12) != null){
      iTemp = Integer.parseInt((String)vRetResult.elementAt(i+12));
      if (iTemp <= 12){%><%=iTemp%><%} else{%><%=(iTemp-12)%><%}
      if (iTemp <12){%>AM<%} else {%>PM<%}} else {%>Undefined<%}%>
      </font>
      </td>
      <td class="thinborder"><font size="1">
      <strong>ID number: </strong><%=(String)vRetResult.elementAt(i+16)%><br>
       <strong>Name: </strong><br><%=WI.formatName((String)vRetResult.elementAt(i+13),(String)vRetResult.elementAt(i+14),(String)vRetResult.elementAt(i+15),7)%>
	  </font></td>
      <td class="thinborder"><font size="1">
       <strong>Status: </strong><%=(String)vRetResult.elementAt(i+17)%>
       <%=WI.getStrValue((String)vRetResult.elementAt(i+18),"<br><strong>Remark: </strong>","","")%>	
       </font>
      </td>
      <!--
			<td class="thinborder">
      <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
      </td>
			-->
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
    <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="maxSel" value="<%=iMax%>">
    <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>