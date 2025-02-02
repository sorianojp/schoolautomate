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
<%@ page language="java" import="utility.*,purchasing.Delivery,purchasing.Supplier,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

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
								"Admin/staff-PURCHASING-DELIVERY-View delivery Status","delivery_non_po_view.jsp");
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
	vReqInfo = DEL.operateOnReqInfoDel(dbOP,request);
	if(vReqInfo == null)
		strErrMsg = DEL.getErrMsg();
	else{
		vSupplierInfo = Sup.operateOnSupplierInfo(dbOP,request,3,WI.fillTextValue("supplier_code"));
		vRetResult = DEL.viewPOItemDeliveries(dbOP, request);
		if(vRetResult == null)
			strErrMsg = DEL.getErrMsg();
	}

%>	
<form name="form_" method="post" action="./delivery_non_po_view.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          DELIVERY - VIEW NON PO RECEIVE STATUS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong><font color="#FFFFFF">DETAILS FOR  REQUISITION NO. : <%=(String)vReqInfo.elementAt(1)%></font></strong></div></td>
    </tr>
    
    <tr> 
      <td height="25" width="4%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(6))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(8))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(10)) == null){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(11)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)+"/"+WI.getStrValue((String)vReqInfo.elementAt(11),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
  </table>
  <%
  if(vSupplierInfo != null && vSupplierInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="2"><div align="center"><strong><font color="#FFFFFF">SUPPLIER  INFORMATION</font></strong></div></td>
    </tr>
        
    <tr> 
      <td height="26">&nbsp;</td>
      <td width="21%">Supplier Name : </td>
      <td width="76%"><strong><%=(String)vSupplierInfo.elementAt(2)%></strong></td>
    </tr>
  </table>  
  <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0">
  		<tr>
			<td><div align="right">
			<a href="javascript:PrintPage();">
			<img src="../../../images/print.gif" border="0">
			</a>
			<font size="1">click to print</font>
			</div></td>
		</tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" bgcolor="#B9B292" colspan="8" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
        OF PO ITEM(S) DELIVERED</strong></font></div></td>
    </tr>
    <tr>
      <td width="12%" height="25" align="center" class="thinborder"><strong>DATE RECEIVED </strong></td>
      <td width="8%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="28%" align="center" class="thinborder"><strong>ITEM / PARTICULARS 
        / DESCRIPTION </strong></td>
      <td width="12%" align="center" class="thinborder"><strong>UNIT PRICE </strong></td>
      <td width="13%" align="center" class="thinborder"><strong>TOTAL PRICE </strong></td>	  
      <td width="17%" align="center" class="thinborder"><strong>RECEIVE STATUS</strong></td>
      <!--
	  <td width="10%" class="thinborder"><div align="center"><strong>DATE RECEIVED</strong></div></td>
	  -->
    </tr>
    <%iCount = 1;
	for(int iLoop = 0;iLoop < vRetResult.size();iLoop+=11,++iCount){
		if(bolLooped && strPrevDate.equals((String)vRetResult.elementAt(iLoop+6))){
			strTemp = "";
		}else{
			strTemp = (String)vRetResult.elementAt(iLoop+6);
		}
	%>
    <tr>
      <td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(iLoop+1)%>&nbsp;</div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=(String)vRetResult.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vRetResult.elementAt(iLoop+3)%> / <%=(String)vRetResult.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+5),true),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+10),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=astrReceiveStat[Integer.parseInt((String)vRetResult.elementAt(iLoop+9))]%></div></td>
	    <!--
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(iLoop+7)%></div></td>
	  -->
    </tr>
    <%
			bolLooped = true;
			strPrevDate = (String)vRetResult.elementAt(iLoop+6);
		}%>
    <tr>
      <td height="25" colspan="8" class="thinborder"><div align="left"><strong>TOTAL 
        ITEM(S) : <%=iCount - 1%> </strong></div></td>
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
	<input type="hidden" name="po_item_index" value="<%=WI.fillTextValue("po_item_index")%>">	
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="supplier_code" value="<%=WI.fillTextValue("supplier_code")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
