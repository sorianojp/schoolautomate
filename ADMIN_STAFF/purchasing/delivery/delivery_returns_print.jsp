<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,purchasing.Returns,purchasing.Supplier,
																java.util.Vector, purchasing.Delivery" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
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
								"Admin/staff-PURCHASING-DELIVERY-View delivery Status","delivery_returns_print.jsp");
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
	String strSchCode = dbOP.getSchoolIndex();	
    
	Returns RET = new Returns();	
	Delivery DEL = new Delivery();	
	Supplier Sup = new Supplier();
	//operateOnSupplierInfo
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vSupplierInfo =null;
	int iCount = 1;
	boolean bolLooped = false;
	String strPrevDate = null;	
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	vReqInfo = RET.getReturninfo(dbOP,request,WI.fillTextValue("return_index"));
 	if(vReqInfo == null)
		strErrMsg = RET.getErrMsg();
	else{
		vSupplierInfo = Sup.operateOnSupplierInfo(dbOP,request,3,WI.fillTextValue("supplier_code"));
		vRetResult = RET.getReturnedItems(dbOP, request);
		if(vRetResult == null)
			strErrMsg = RET.getErrMsg();
	}

%>	
<form name="form_">
<%if(vReqInfo != null) {%>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;PO Number : </td>
      <td><strong>&nbsp;<%=(String)vReqInfo.elementAt(1)%></strong></td>
      <td>&nbsp;PO Date :</td>
      <td><strong>&nbsp;<%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr>
      <td height="20" width="3%">&nbsp;</td>
      <td width="14%">&nbsp;Reason : </td>
      <td width="33%"><strong>&nbsp;<%=(String)vReqInfo.elementAt(3)%></strong></td>
      <td width="19%">&nbsp;Return Date : </td>
      <td width="31%"> <strong>&nbsp;<%=WI.getStrValue((String)vReqInfo.elementAt(5), (String)vReqInfo.elementAt(6))%></strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>&nbsp;Remarks : </td>
      <td colspan="3"><strong>&nbsp;<%=(String)vReqInfo.elementAt(4)%></strong></td>
    </tr>
  <%if(vSupplierInfo != null && vSupplierInfo.size() > 0){%>
	  <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;Supplier : </td>
      <td colspan="3"><span class="thinborderBottom"><strong>&nbsp;<%=(String)vSupplierInfo.elementAt(2)%></strong></span></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;Address : </td>
      <td colspan="3"><span class="thinborderBottom"><strong>&nbsp;<%=(String)vSupplierInfo.elementAt(19)%></strong></span></td>
    </tr>
	  <%}%>
	  <tr>
      <td height="20" colspan="5">&nbsp;</td>
    </tr> 
  </table>
	
  <%}//if(vReqInfo != null)
  
  if(vRetResult != null && vRetResult.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="6" align="center" class="thinborder"><strong>LIST 
        OF PO ITEM(S) RETURNED </strong></td>
    </tr>
    <tr>
      <td width="8%" height="25" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="28%" align="center" class="thinborder"><strong>ITEM / PARTICULARS 
        / DESCRIPTION </strong></td>
      <td width="12%" align="center" class="thinborder"><strong>UNIT PRICE </strong></td>
      <td width="13%" align="center" class="thinborder"><strong>TOTAL PRICE </strong></td>	  
      <!--
	  <td width="10%" class="thinborder"><div align="center"><strong>DATE RECEIVED</strong></div></td>
	  -->
    </tr>
    <%iCount = 1;
	for(int iLoop = 0;iLoop < vRetResult.size();iLoop+=8,++iCount){			
	%>
    <tr>
			<%
				strTemp = (String)vRetResult.elementAt(iLoop+1);
			%>
      <td height="25" align="right" class="thinborder"><%=(String)vRetResult.elementAt(iLoop+2)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(iLoop+3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(iLoop+4)%> / <%=(String)vRetResult.elementAt(iLoop+5)%></td>
      <td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+6),true),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+7),true),"&nbsp;")%>&nbsp;</td>
      <!--
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(iLoop+7)%></div></td>
	  -->
    </tr>
    <%
			bolLooped = true;
			strPrevDate = (String)vRetResult.elementAt(iLoop+6);
		}%>
  </table>
  <%}%>
  <!-- all hidden fields go here -->
	<input type="hidden" name="req_no" value="<%=WI.fillTextValue("req_no")%>">
	<input type="hidden" name="return_index" value="<%=WI.fillTextValue("return_index")%>">	
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="supplier_code" value="<%=WI.fillTextValue("supplier_code")%>">
	<input type="hidden" name="search_po" value="<%=WI.getStrValue(WI.fillTextValue("search_po"),"1")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
