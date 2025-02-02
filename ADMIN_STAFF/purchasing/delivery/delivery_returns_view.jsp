<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,purchasing.Returns,purchasing.Supplier,
																java.util.Vector, purchasing.Delivery" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;	
//add security here.
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="./delivery_returns_print.jsp"/>
	<%}

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
								"Admin/staff-PURCHASING-DELIVERY-View delivery Status","delivery_status_view.jsp");
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
<form name="form_" method="post" action="./delivery_returns_view.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          DELIVERY - VIEW RETURN DETAILS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>PO Number : </td>
      <td><strong><%=(String)vReqInfo.elementAt(1)%></strong></td>
      <td>PO Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr>
      <td height="25" width="4%">&nbsp;</td>
      <td width="22%">Reason : </td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(3)%></strong></td>
      <td width="20%">Return Date </td>
      <td width="28%"> <strong><%=WI.getStrValue((String)vReqInfo.elementAt(5), (String)vReqInfo.elementAt(6))%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Remarks : : </td>
      <td><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr> 
  </table>
  <%
  if(vSupplierInfo != null && vSupplierInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="2"><div align="center"><strong><font color="#FFFFFF">SUPPLIER  INFORMATION</font></strong></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="21%">Supplier Code : </td>
      <td width="76%"><strong><%=(String)vSupplierInfo.elementAt(1)%></strong></td>
    </tr>    
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Supplier Name : </td>
      <td><strong><%=(String)vSupplierInfo.elementAt(2)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Address : </td>
      <td><strong><%=(String)vSupplierInfo.elementAt(19)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Contact Person : </td>
      <td><strong><%=(String)vSupplierInfo.elementAt(12)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Contact Number : </td>
      <td><strong><%=(String)vSupplierInfo.elementAt(4)%></strong></td>
    </tr>

  </table>  
  <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0">
  		<tr>
			<td><div align="right">
			<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
			<font size="1">click to print</font>
			</div></td>
		</tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" bgcolor="#B9B292" colspan="6" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
        OF PO ITEM(S) RETURNED </strong></font></div></td>
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
      <td class="thinborder"><%=(String)vRetResult.elementAt(iLoop+3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(iLoop+4)%> / <%=(String)vRetResult.elementAt(iLoop+5)%></td>
      <td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+6),true),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+7),true),"&nbsp;")%>&nbsp;</td>
      <!--
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(iLoop+7)%></div></td>
	  -->
    </tr>
    <%
		}%>
    <tr>
      <td height="25" colspan="6" class="thinborder"><strong>TOTAL 
        ITEM(S) : <%=iCount - 1%> </strong></td>
    </tr>
  </table>
  <%}}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"></td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="req_no" value="<%=WI.fillTextValue("req_no")%>">
	<input type="hidden" name="return_index" value="<%=WI.fillTextValue("return_index")%>">	
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="supplier_code" value="<%=WI.fillTextValue("supplier_code")%>">
	<input type="hidden" name="search_po" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
