<%@ page language="java" import="utility.*,purchasing.Requisition,purchasing.PO,purchasing.Supplier,java.util.Vector" %>
<%	
	WebInterface WI = new WebInterface(request);

	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	boolean bolIsDBTC = strSchCode.startsWith("DBTC");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TABLE.thinborder {
<%if(!bolIsDBTC){%>
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-size: 10px;	
<%}else{%>
	font-size: 12px;	
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}
TABLE.thinborderALL {
<%if(!bolIsDBTC){%>
    border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-size: 10px;	
<%}else{%>
	font-size: 12px;	
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}
TD.thinborder {
<%if(!bolIsDBTC){%>
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-size: 10px;
<%}else{%>
	font-size: 12px;	
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}
TD.thinborderBottom {
<%if(!bolIsDBTC){%>
    border-bottom: solid 1px #000000;
	font-size: 10px;	
<%}else{%>
	font-size: 12px;	
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}
TD.thinborderBottomRight {
<%if(!bolIsDBTC){%>
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-size: 10px;	
<%}else{%>
	font-size: 12px;	
<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}
TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-size: 10px;	
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}
TD.thinborderRight {
    border-right: solid 1px #000000;
	font-size: 10px;	
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}
TD.thinborderTop {
    border-top: solid 1px #000000;
	font-size: 10px;	
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}

TD.NoBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
<%if(bolIsDBTC){%>
	font-size: 12px;
<%}else{%>
	font-size: 10px;
<%}%>
}
</style>
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
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"PURCHASING-PURCHASE ORDER","purchase_request_print.jsp");

	Requisition REQ = new Requisition();
	PO PO = new PO();	
	Supplier SUP = new Supplier();
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vReqPO = null;
	Vector vAddtlCost = null;
	Vector vSupplierInfo = null;
	double dDaysRequired  = 0d;
	int iNumRows = 0;
	
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrTerm = {"Cash on Delivery (COD)", "Prepaid", "Given No. of Days", "Specific Day of the Month", "No. of Days after End of Month","Day of Month after End of Month",""};
	String strErrMsg = null;
	String strReqIndex = WI.fillTextValue("req_index");
	String strTemp = null;
	String strFax = null;
	String strPhone = null;
	int iLoop = 0;
	int iCountRows = 0;
	double dPageAmount = 0d;
	double dTotalAmount = 0d;
	double dGrandTotal = 0d;
	int iWidth = 0;
	// use this poara dili na mag cge pangita pila ka elements sa vReqItems na vector - what is this meaning.
	int iItems = 12;

	vReqInfo = PO.operateOnReqInfo(dbOP,request,3);
	if(vReqInfo == null)
		strErrMsg = PO.getErrMsg();
	else
		strReqIndex = (String)vReqInfo.elementAt(1);
			
	vReqPO = PO.operateOnPOInfo(dbOP,request,4,strReqIndex);
	if(vReqPO == null)
		strErrMsg = PO.getErrMsg();
	
	vReqItems = PO.operateOnPOItems(dbOP,request,4);
	if(vReqItems == null){
		vReqItems = PO.operateOnReqItems(dbOP,request);
		if(vReqItems == null)
			strErrMsg = REQ.getErrMsg();				
	}
//System.out.println(vReqItems);
	if(WI.fillTextValue("print_supplier").length() > 0){
		strTemp = " and SUPPLIER_INDEX = "+ WI.fillTextValue("print_supplier");	
		vSupplierInfo = PO.getSupDetails(dbOP,request);
	}else{
		strTemp = "";
	}
	vAddtlCost = PO.showAdditionalCost(dbOP,strReqIndex+strTemp);
	if(vAddtlCost == null)
		strErrMsg = PO.getErrMsg();
	

/*	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
	if(vReqInfo == null)
		strErrMsg = REQ.getErrMsg();
	else
		strReqIndex = (String)vReqInfo.elementAt(0);
			
	vReqPO = PO.operateOnReqInfoPO(dbOP,request,3,strReqIndex);
	if(vReqPO == null)
		strErrMsg = PO.getErrMsg();
	
	vReqItems = PO.operateOnReqItemsPO(dbOP,request,4,strReqIndex);
	if(vReqItems == null){
		vReqItems = REQ.operateOnReqItems(dbOP,request,4);
		if(vReqItems == null)
			strErrMsg = REQ.getErrMsg();				
	}
	
	if(WI.fillTextValue("print_supplier").length() > 0)
		strTemp = " and SUPPLIER_INDEX = "+ WI.fillTextValue("print_supplier");	
	else
		strTemp = "";
	vAddtlCost = PO.showAdditionalCost(dbOP,strReqIndex+strTemp);	
	if(vAddtlCost == null)
		strErrMsg = PO.getErrMsg();
*/		
	iNumRows = 15;
	if(strSchCode.startsWith("CPU")){
		iNumRows = 13;
	}
	else if(strSchCode.startsWith("UDMC")){
		iNumRows = 25;
	}
	else if(strSchCode.startsWith("DBTC")){
		iNumRows = 12;
	}
	
	if(vReqItems!= null){
	int iPageCount = vReqItems.size()/iItems/iNumRows;
	if((vReqItems.size() % (iItems * iNumRows)) > 0) ++iPageCount;
	int iPageNumber = 0;
	for(;iLoop < vReqItems.size();){
		iCountRows = 0;
		dPageAmount = 0d;
		++iPageNumber;
%>
<body onLoad="window.print()">
<form name="form_" method="post" action="./purchase_request_print.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>  
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="26%" rowspan="3" align="right" valign="top"><img src="../../../images/logo/AUF_PAMPANGA.gif" width="70" height="70" border="0"></td>
        <td colspan="2" align="center" valign="top" style="font-size:14px;">Angeles University Foundation</td>
        <td height="18" colspan="2">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2" align="center" valign="top" style="font-size:9px;">Angeles City, Phlippines<br>
		<font style="font-size:12px; font-weight:bold">
		PURCHASING AND SUPPLY OFFICE		</font>		</td>
        <td width="14%" height="18" align="right" valign="bottom">Date :&nbsp;</td>
        <td width="14%" height="18" valign="bottom" class="thinborderBottom"><strong><font size="1">&nbsp;<%=(String)vReqPO.elementAt(2)%></font></strong></td>
      </tr>
      <tr>
        <td colspan="2" align="center"><strong><font size="+1">PURCHASE ORDER</font></strong></td>
        <td height="25" align="right" valign="bottom">&nbsp;</td>
        <td height="25" valign="bottom">&nbsp;</td>
      </tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="35%">Requester: <u><%=(String)vReqInfo.elementAt(3)%></u></td>
        <td colspan="2" align="center" width="37%">Expected time of delivery </td>
        <td height="20" align="right" valign="bottom" width="14%">P.O. No :&nbsp;</td>
        <td valign="bottom" class="thinborderBottom" width="14%"><strong><font size="1"><%=(String)vReqPO.elementAt(1)%></font></strong></td>
      </tr>
      <tr>
        <td>Purpose: <u><%=WI.getStrValue((String)vReqInfo.elementAt(6))%></u></td>
        <td colspan="2" align="center">
        <% if ((String)vReqPO.elementAt(8)!= null){
			dDaysRequired = Double.parseDouble((String)vReqPO.elementAt(8));
		}else{
			dDaysRequired= 0;
		}
		
		if (dDaysRequired > 0){%>
        <u><%=(String)vReqPO.elementAt(8)%> working day(s)</u>
		<%}else{%>
		_______________________
		<%}%>
		
		</td>
        <td height="20" align="right" valign="bottom">R.F # :&nbsp;</td>
        <td valign="bottom" class="thinborderBottom"><strong><font size="1"><%=(String)vReqInfo.elementAt(13)%></font></strong></td>
      </tr>
  </table>		
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" cal>
    <tr>
      <td height="6" valign="top" class="NoBorder"></td>
    </tr>
  </table>	 
  <%if(vReqItems != null){%>
	<table width="100%" border="0" class="thinborderALL" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr> 
      <td width="45%" class="thinborderBottomRight"><div align="center"><strong>Name & Description of item/s</strong></div></td>
      <td width="11%" height="15" class="thinborderBottomRight"><div align="center"><strong>Quantity</strong></div></td>
      <td width="13%" class="thinborderBottomRight"><div align="center"><strong>Unit cost</strong></div></td>
      <td width="13%" class="thinborderBottomRight"><div align="center"><strong>Total cost</strong></div></td>
      <td width="18%" align="center" class="thinborderBottom"><strong>Supplier</strong></td>
    </tr>
	
    <%		
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=iItems,++iCountRows){	//System.out.println(iLoop + " : "+iItems);
	%>
    <tr> 
      <td class="thinborderRight"><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+1)%>/<%=(String)vReqItems.elementAt(iLoop+2)%> <%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"(",")","")%> </div></td>
      <td height="15" class="thinborderRight"><div align="right"><%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+5), false)%> <%=(String)vReqItems.elementAt(iLoop+6)%>&nbsp;</div></td>
      <td class="thinborderRight"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborderRight"><div align="right">
	  <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%>&nbsp;</div></td> 
	    <td class="NoBorder">&nbsp;<%=WI.getStrValue((String)vReqItems.elementAt(iLoop+3),"&nbsp;")%></td>
	    <%dPageAmount += Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(((String)vReqItems.elementAt(iLoop+7)),",",""),"0"));%>
    </tr>
    <%}for(;iCountRows < iNumRows;++iCountRows){%>
    <tr> 
      <td height="15" class="thinborderRight">&nbsp;</td>
      <td class="thinborderRight">&nbsp;</td>
      <td class="thinborderRight">&nbsp;</td>
      <td class="thinborderRight">&nbsp;</td>      
      <td class="NoBorder">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="15" class="thinborderTop">&nbsp;</td>
      <td colspan="3" class="thinborderTop" align="right">Page Total: <%=CommonUtil.formatFloat(dPageAmount, true)%>&nbsp;</td>
      <td class="thinborderTop">&nbsp;</td>
    </tr>
	  <%if(dPageAmount > 0){
	  	dTotalAmount += dPageAmount;
	  %>
  </table>	
	<%if (iLoop < vReqItems.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }}}%>
    <%if(vAddtlCost != null && vAddtlCost.size() > 2){%>
  <br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="15" colspan="3" class="thinborder"><div align="center"><strong>ADDITIONAL COST FOR THIS PO</strong></div></td>
    </tr>
    <%for(int i = 0;i < vAddtlCost.size();i+=5){
		//dGrandTotal += Double.parseDouble(ConversionTable.replaceString((String)vAddtlCost.elementAt(i+4),",",""));
	%>
    <tr> 
      <td width="42%" height="20" class="thinborder">&nbsp;<%=vAddtlCost.elementAt(i+2)%> <%strTemp = "";
	  	strErrMsg = "";	  
	  for(;(i+4+5) < vAddtlCost.size();){	  
	  		if(!((String)vAddtlCost.elementAt(i+1)).equals((String)vAddtlCost.elementAt(i+1+5)))
	  			break;
			strTemp += (String)vAddtlCost.elementAt(i+3)+"<br>";
			strErrMsg += (String)vAddtlCost.elementAt(i+4)+"<br>";			
			i+=5;
	    }%> </td>
      <td width="29%" class="thinborder"><%=strTemp+(String)vAddtlCost.elementAt(i+3)%></td>
      <td width="29%" class="thinborder"><div align="right"> 
          <%if(WI.fillTextValue("print_pg").equals("2")){%>
          &nbsp; 
          <%}else{%>
          <%=strErrMsg+(String)vAddtlCost.elementAt(i+4)%> 
          <%
		  dGrandTotal += Double.parseDouble(ConversionTable.replaceString((String)vAddtlCost.elementAt(i+4),",",""));
		  %>
          <%}%>
        </div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="15" colspan="2" class="thinborder"><div align="right"><strong>GRAND 
          TOTAL : </strong></div></td>
      <td class="thinborder">
	  <div align="right"><strong><%=CommonUtil.formatFloat(dGrandTotal+dTotalAmount,true)%>&nbsp;</strong></div>
	  </td>
    </tr>
	
  </table>
  <%}%>
  <br>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		
		<tr>
		  <td width="31%" valign="top" class="NoBorder">(1)&nbsp;Prepared by: </td>
		  <td width="2%" class="NoBorder">&nbsp;</td>
		  <td width="15%" class="NoBorder">&nbsp;</td>
		  <td width="2%" valign="top" class="NoBorder">&nbsp;</td>
		  <td width="23%" colspan="2" class="NoBorder">
		   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		   (2)&nbsp;Verified by: </td>
		  <td class="NoBorder">&nbsp;</td>
		  <td class="NoBorder">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="23" align="center" valign="bottom" class="thinborderBottom"><font size="1"><strong><font size="1"><strong>
		    <%//=WI.formatName((String)vReqPO.elementAt(9), (String)vReqPO.elementAt(10),(String)vReqPO.elementAt(11), 7).toUpperCase()%>
		  </strong></font>&nbsp;</strong></font>
		  <%//=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Purchasing Officer",7)),"").toUpperCase()%>		  </td>
		  <td>&nbsp;</td>
		  <td valign="bottom" class="thinborderBottom">&nbsp;</td>
		  <td valign="top">&nbsp;</td>
		  <td colspan="2" valign="bottom" class="thinborderBottom" align="center">&nbsp;<%//=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Budget Officer",7)),"").toUpperCase()%></td>
		  <td>&nbsp;</td>
		  <td valign="bottom" class="thinborderBottom">&nbsp;</td>
	  </tr>
		<tr>
		  <td align="center" valign="top" class="NoBorder">Purchasing &amp; Supply Officer </td>
		  <td align="center" class="NoBorder">&nbsp;</td>
		  <td align="center" class="NoBorder">Date</td>
		  <td valign="top" class="NoBorder">&nbsp;</td>
		  <td colspan="2" align="center" class="NoBorder">Budget Officer </td>
		  <td class="NoBorder">&nbsp;</td>
		  <td align="center" class="NoBorder">Date</td>
	  </tr>
		<tr>
		  <td colspan="3" valign="top" class="NoBorder">(3)/&nbsp; / &nbsp;Recommended / &nbsp;/ &nbsp;Not Recommended </td>
		  <td valign="top" class="NoBorder">&nbsp;</td>
		  <td colspan="4" class="NoBorder">
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  (4) / &nbsp;&nbsp;/ Approved &nbsp;&nbsp;/ &nbsp;/ Disapproved </td>
	  </tr>
		<tr>
		  <td height="23" valign="bottom" class="thinborderBottom" align="center">&nbsp;<%//=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"VP for Finance",7)),"").toUpperCase()%></td>
		  <td>&nbsp;</td>
		  <td valign="bottom" class="thinborderBottom">&nbsp;</td>
		  <td valign="top">&nbsp;</td>
		  <td colspan="2" valign="bottom" class="thinborderBottom">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td valign="bottom" class="thinborderBottom">&nbsp;</td>
	  </tr>
		<tr>
		  <td align="center" valign="top" class="NoBorder">VP for Finance </td>
		  <td class="NoBorder">&nbsp;</td>
		  <td align="center" class="NoBorder">Date</td>
		  <td valign="top" class="NoBorder">&nbsp;</td>
		  <td colspan="2" align="center" class="NoBorder">Approving Authority </td>
		  <td class="NoBorder">&nbsp;</td>
		  <td align="center" class="NoBorder">Date</td>
	  </tr>
		<tr> 
			<td colspan="5" valign="top" class="NoBorder">&nbsp;Payment Charged to : / &nbsp;/ &nbsp;AUF Funds &nbsp;/ &nbsp;/ &nbsp;Trust Funds&nbsp; / &nbsp;/ &nbsp;Others 
			
			<div style="font-weight:bold">
				AUF-FORM-AFO-31<br>
				March 2, 2009 - Rev. 01			</div>			</td>
			<td width="10%" valign="top" class="NoBorder">&nbsp;</td>
			<td width="2%" class="NoBorder">&nbsp;</td>
			<td width="15%" class="NoBorder">&nbsp;</td>
		</tr>
	</table>
		<%}//for(;iLoop < vReqItems.size();){%>
  <%}// para dili mag null pointer%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
