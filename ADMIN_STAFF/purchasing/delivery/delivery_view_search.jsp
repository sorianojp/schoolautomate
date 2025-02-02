<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
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
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage(){	
    document.form_.printPage.value = "";	
 	this.SubmitOnce('form_');
}
function ViewItem(strIndex){
	var pgLoc = "delivery_details_view.jsp?delivery_index="+strIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
<%if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strID)
{
	window.opener.document.<%=strFormName%>.proceedClicked.value=1;
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strID;	
	window.opener.focus();
	<%
	if(strFormName != null){%>	
	window.opener.document.<%=strFormName%>.submit();	
	<%}%>	
	self.close();
}<%}%>
</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="./delivery_view_search_print.jsp"/>
	<%}
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-DELIVERY"),"0"));
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
								"Admin/staff-PURCHASING-DELIVERY-View delivery search","delivery_view_search.jsp");
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
	
	Delivery DEL = new Delivery();
	Vector vRetResult = null;
	String[] astrPORecStatus = {"Not Received","Received (All)","Received (Partial)"};
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"PO No.","Supplier Name","Date Received"};
	String[] astrSortByVal     = {"PO_NUMBER","supplier_name","delivery_date"};
	String strInvoice = null;
	String strDateReceived = null;
	String strTotalItem = null;
	String strTotal = null;
	
	
	int iSearch = 0;
	int iDefault = 0;
	boolean bolShowView = true;
	if(!DEL.POReceivingFix(dbOP))
		strErrMsg = DEL.getErrMsg();
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = DEL.searchDeliveries(dbOP, request);
		if(vRetResult == null)
			strErrMsg = DEL.getErrMsg();
		else
			iSearch = DEL.getSearchCount();		
	}
%>
<form name="form_" method="post" action="delivery_view_search.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          DELIVERY - SEARCH/VIEW DELIVERIES PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
	  <tr>
	    <td width="2%" height="25">&nbsp;</td>
	    <td width="20%">Delivery No. : </td>
	    <td width="78%"><select name="delivery_no_select">
        <%=DEL.constructGenericDropList(WI.fillTextValue("delivery_no_select"),astrDropListEqual,astrDropListValEqual)%>
      </select>
        <input type="text" name="delivery_no" class="textbox" value="<%=WI.fillTextValue("delivery_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	  <tr>
	    <td height="25">&nbsp;</td>
	    <td>Delivery Date: </td>
	    <td><%strTemp = WI.fillTextValue("delivery_date_fr");%>
        <input name="delivery_date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.delivery_date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <%strTemp = WI.fillTextValue("delivery_date_to");%>
        <input name="delivery_date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.delivery_date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>PO No. : </td>
      <td><select name="po_no_select">
        <%=DEL.constructGenericDropList(WI.fillTextValue("po_no_select"),astrDropListEqual,astrDropListValEqual)%>
      </select>
        <input type="text" name="po_no" class="textbox" value="<%=WI.fillTextValue("po_no")%>"
	       onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Invoice No. : </td>
      <td> 
	      <select name="invoice_no_select">
          <%=DEL.constructGenericDropList(WI.fillTextValue("invoice_no_select"),astrDropListEqual,astrDropListValEqual)%> 
		  </select> 
		  <input type="text" name="invoice_no" class="textbox" value="<%=WI.fillTextValue("invoice_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    
	  <tr>
	    <td height="25">&nbsp;</td>
	    <td>Invoice Date : </td>
	    <td><%strTemp = WI.fillTextValue("invoice_date_fr");%>
        <input name="invoice_date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.invoice_date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <%strTemp = WI.fillTextValue("invoice_date_to");%>
        <input name="invoice_date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.invoice_date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
  <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td colspan="3"><strong>Sort</strong></td>
    </tr>
    <tr> 
      <td height="8">&nbsp;</td>
      <td width="31%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=DEL.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="33%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=DEL.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="34%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=DEL.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="3">&nbsp; </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="3"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0" ></a>      </td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="2"><div align="right">Number of PO(s) Per Page: 
          <select name="num_rec_page">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPage();"> 
		  <img src="../../../images/print.gif" border="0"></a> 
          <font size="1"> click to print list&nbsp;</font></div></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
   <%	int iPageCount = iSearch/DEL.defSearchSize;		
			if(iSearch % DEL.defSearchSize > 0) ++iPageCount;		
			if(iPageCount > 1){%>
  	<tr> 
      <td height="10">
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=DEL.getDisplayRange()%>)</font></strong>
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
          
        </div></td>
    </tr> 
		<%}%> 
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292" colspan="2" class="thinborderTOPLEFTRIGHT">
	  <div align="center"><font color="#FFFFFF"><strong>LIST OF PO DELIVERIES</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr>
      <td width="12%" align="center" class="thinborder"><strong>DELIVERY NO.  </strong></td> 
      <td width="12%" height="25" align="center" class="thinborder"><strong>PO NO.</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>INVOICE</strong></td>
      <td width="31%" align="center" class="thinborder"><strong>SUPPLIER </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>DATE  RECEIVED</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>VIEW</strong></td>
    </tr>
    <%for(int i = 0;i < vRetResult.size();i+=9){%>
    <tr>
      <td align="right" class="thinborder">
				<%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href="javascript:CopyID('<%=(String)vRetResult.elementAt(i+3)%>');"> <%=(String)vRetResult.elementAt(i+3)%></a>
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+3)%>
        <%}%>&nbsp;</td> 
      <td height="32" align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;</td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+8)%></td>		  	  
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%>&nbsp;</td>
      <td class="thinborder"><div align="center"> 
	  <a href="javascript:ViewItem('<%=(String)vRetResult.elementAt(i)%>');">
	  <img src="../../../images/view.gif" border="0" >	  </a></div></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
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
  <input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
  <input type="hidden" name="proceedClicked" value=""> 
  <input type="hidden" name="printPage" value="">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
