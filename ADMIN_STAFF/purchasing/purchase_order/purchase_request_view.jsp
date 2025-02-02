<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function CloseWindow(){
	self.close();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,purchasing.PO,purchasing.Requisition,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="purchase_request_print.jsp"/>
	<%return;}

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
								"Admin/staff-PURCHASING-PURCHASE ORDER-View PO","purchase_request_view.jsp");
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

	Requisition REQ = new Requisition();
	PO PO = new PO();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vReqPO = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Approved - First Level"};
	String[] astrReqType = {"New","Replacement"};
	double dTotalAmount = 0d;
	String strSupplierIndex = "";
	
	vReqInfo = PO.operateOnReqInfo(dbOP,request,3);

	//System.out.println("vReqInfo " + vReqInfo);
//	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
	if(vReqInfo == null)
		strErrMsg = REQ.getErrMsg();
	else{
//		vReqPO = PO.operateOnReqInfoPO(dbOP,request,3,(String)vReqInfo.elementAt(0));
		vReqPO = PO.operateOnPOInfo(dbOP,request,4,(String)vReqInfo.elementAt(1));
		if(vReqPO == null){
			strErrMsg = PO.getErrMsg();		
		}else{
		  	strSupplierIndex = (String)vReqPO.elementAt(12);
		vReqItems = PO.operateOnPOItems(dbOP,request,4);	
		//vReqItems = PO.operateOnReqItemsPO(dbOP,request,4,(String)vReqInfo.elementAt(0));
		if(vReqItems == null)
			strErrMsg = PO.getErrMsg();
		}
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          PO - SEARCH VIEW DETAIL PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">
	  <a href="javascript:CloseWindow();">	  
	  <img src="../../../images/close_window.gif" border="0" align="right"></a></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR THIS PURCHASE ORDER</strong></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>PO No. : </td>
      <td><strong><%=(String)vReqPO.elementAt(1)%></strong></td>
      <td>PO Date :</td>
      <td><strong><%=(String)vReqPO.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="21%">Requisition No. :</td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(13)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(2))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(6)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(11))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(4)).equals("0")){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=vReqInfo.elementAt(10)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
  </table>
  <%}if(vReqItems != null && vReqItems.size() > 3){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" bgcolor="#B9B292" colspan="8" class="thinborder"> 
        <div align="center"><font color="#FFFFFF"><strong>LIST OF PO ITEMS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="7%" height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>QUANTITY</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="28%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS/ 
          DESCRIPTION </strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE</strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong>BRAND</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%for(int iLoop = 0;iLoop < vReqItems.size();iLoop+=12){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+12)/12%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+5)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+1)%> / <%=(String)vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+3),"&nbsp;")%></div></td>
      <td class="thinborder"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%></div></td>
      <% if(vReqItems.elementAt(iLoop+7) != null){
		  dTotalAmount += Double.parseDouble(ConversionTable.replaceString((String)vReqItems.elementAt(iLoop+7),",",""));	  }
	  %>
      <td class="thinborder"><div align="right"> 
          <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
          &nbsp; 
          <%}else{%>
          <%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%> 
          <%}%>
        </div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vReqItems.size()/12%></strong></div></td>
      <td height="25" colspan="3" class="thinborder"><div align="right"><strong>TOTAL 
          AMOUNT : </strong></div></td>
      <td height="25" class="thinborder"><div align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dTotalAmount,true),"0")%>&nbsp;</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><div align="center">
	  <a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
		  <font size="1">click to print</font></div></td>
    </tr>
    <tr> 
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_supplier" value="<%=strSupplierIndex%>">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="isForPO" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>