<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function CloseWindow(){
	self.close();
}
</script>
<%@ page language="java" import="utility.*,inventory.InventoryMaintenance,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;	
	String strErrMsg = null;

	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="stock_out_item_print.jsp"/>
	<%return;}

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
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Requisition View","central_req_view.jsp");
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

	InventoryMaintenance InvMaint = new InventoryMaintenance();
	Vector vReqInfo = null;
	Vector vReqItems = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending"};
	String[] astrReqType = {"Donate Items","Dispose / discard items","Consume / use items"};	
			
	vReqInfo = InvMaint.operateOnStockOutInfo(dbOP,request,3);
	if(vReqInfo == null)
		strErrMsg = InvMaint.getErrMsg();
			
	vReqItems = InvMaint.operateOnItemStockOut(dbOP,request,4);
	if(vReqItems == null)
		strErrMsg = InvMaint.getErrMsg();
	
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          REQUISITION - SEARCH VIEW DETAIL PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">
	  <a href="javascript:CloseWindow();">	  
	  <img src="../../../../images/close_window.gif" border="0" align="right"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS </strong></div></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(1)).equals("0")){%>
    <%}else{%>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Request Type</td>
      <td colspan="3"><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(3))]%></strong></td>
    </tr>
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="25%"><strong><%=WI.fillTextValue("req_no")%></strong></td>
      <td width="21%">Requested By :</td>
      <td width="29%"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(5)).equals("0")){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Non-Acad. Office/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>College/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)+"/"+WI.getStrValue((String)vReqInfo.elementAt(8),"All")%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Remarks</td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vReqInfo.elementAt(9))%></strong></td>
    </tr>
  </table>
  <%if(vReqItems != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">  
	  <br>  
	  <tr>
	  	  <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUESTED SUPPLIES</strong></font></div></td>
	  </tr>	  
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr>
      <td width="15%" height="25" class="thinborder"><div align="center"><strong>ITEM CODE </strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>QUANTITY</strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="56%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
    </tr>
    <% int iCountItem = 0;
	for(int i = 0;i < vReqItems.size();i+=11,iCountItem++){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vReqItems.elementAt(i+10),"&nbsp;")%></td>
      <td align="right" class="thinborder"><%=vReqItems.elementAt(i+2)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vReqItems.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=vReqItems.elementAt(i+4)%></td>
    </tr>
    <%} // end for loop%>
    <input type="hidden" name="item_count" value="<%=iCountItem%>">
    <tr>
      <td class="thinborder" height="25" colspan="4"><div align="left"><strong>TOTAL ITEM(S) : <%=iCountItem%></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><div align="center">
	  <a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>
	  <font size="1">click to print search result</font></div></td>
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
  <input type="hidden" name="printPage" value="">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
