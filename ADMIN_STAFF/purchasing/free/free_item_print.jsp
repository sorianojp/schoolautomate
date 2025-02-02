<%@ page language="java" import="utility.*,purchasing.Requisition,purchasing.PO,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Free Items</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<%		

	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}

	if(WI.fillTextValue("my_home").equals("1"))
		iAccessLevel = 2 ;
	
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
								"Admin/staff-PURCHASING-REQUISITION-Requisition Items","free_item.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authentication code.

	Requisition REQ = new Requisition();	
	PO PO = new PO();
	Vector vReqInfo = null;
	Vector vFreeItems = null;
	Vector vRetResult = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	vReqInfo = PO.operateOnReqInfo(dbOP,request,3);		
	vFreeItems = PO.operateOnFreeItems(dbOP,request,4);		
%>
<form name="form_">
  <%		
	if(vReqInfo != null){%>
  <%if(vFreeItems != null){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	  <tr>
	  	  <td width="100%" height="25" align="center" class="thinborderTOPLEFTRIGHT">
		      <strong>LIST OF FREE ITEMS FOR PO : <%=WI.fillTextValue("req_no")%></strong></td>
	  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    
    <tr> 
      <td width="9%" height="25" align="center" class="thinborder"><strong>ITEM#</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td width="14%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="22%" align="center" class="thinborder"><strong>ITEM</strong></td>
      <td width="43%" align="center" class="thinborder"><strong>PARTICULARS/ITEM DESCRIPTION </strong></td>
    </tr>
    <% int iCountItem = 1;
		for(int i = 0;i < vFreeItems.size();i+=14,iCountItem++){%>
	<tr> 
      <td height="25" align="center" class="thinborder"><%=iCountItem%></td>
      <td align="center" class="thinborder"><%=vFreeItems.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=vFreeItems.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=vFreeItems.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=vFreeItems.elementAt(i+5)%></td>
    </tr>
	<%} // end for loop%>
	<input type="hidden" name="item_count" value="<%=iCountItem-1%>">
    <tr> 
      <td class="thinborder" height="25" colspan="5">
	      <strong>TOTAL ITEM(S) : <%=iCountItem-1%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}
}else{%>
 <input type="hidden" name="is_supply">
<%}%>
<input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="cancelClicked" value="">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="printPage" value=""> 	
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>"> 
	<input type="hidden" name="focus_area" value="<%=WI.fillTextValue("focus_area")%>">
	<input type="hidden" name="isForPO" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>