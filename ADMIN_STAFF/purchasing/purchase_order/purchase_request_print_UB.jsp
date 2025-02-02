<%@ page language="java" import="utility.*,purchasing.Requisition,purchasing.PO,purchasing.Supplier,java.util.Vector" %>
<%	

/**
I have to extract all supplier in 1 PO.

in requisition of item, there is a selection of supplier, amount and unit already 
incase the will not canvass anymore.

if they canvass and make a quotation for item for diff. supplier then
they must approve the budget ready for PO and they have to select which supplier
they are going approved.

there will be a possibility that 1 item can have many supplier
and 1 PO can have diff supplier

for example 1 PO has 2 items<br>
item 1 - can have 1 or more suppliers
item 2 - can have 1 or more suppliers

so each supplier I have to make a PO printout.
if they dont make any canvass, get the supplier list from requisition item

*/


	WebInterface WI = new WebInterface(request);

	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
body{
	font-size: 11px;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}

td{
	font-size: 11px;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}
th{
	font-size: 11px;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
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
	Supplier SUP 			= new Supplier();
	Vector vReqInfo 		= null;
	Vector vReqItems 		= null;
	Vector vReqPO 			= null;
	Vector vAddtlCost 		= null;
	Vector vSupplierInfo 	= null;
	Vector vSupplierAddInfo = new Vector();
	Vector vDelInfo 		= new Vector();
	Vector vSupplierList 	= null;
	
	boolean bolAdditionalData = true; //this this info also when checking vector element
	
	double dDaysRequired  	= 0d;
	int iNumRows 			= 0;
	
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrTerm = {"Cash on Delivery (COD)", "Prepaid", "Given No. of Days", "Specific Day of the Month", 
		"No. of Days after End of Month","Day of Month after End of Month",""};
	String strErrMsg = null;
	String strReqIndex = WI.fillTextValue("req_index");
	String strTemp = null;
	String strFax = null;
	String strPhone = null;
	String strPOIndex = null;
	int iLoop = 0;
	int iCountRows = 0;
	double dPageAmount = 0d;
	double dTotalAmount = 0d;
	double dGrandTotal = 0d;
	int iWidth = 0;
	
	vSupplierList = PO.showPOSuppliers(dbOP, WI.fillTextValue("req_no"), WI.fillTextValue("print_supplier"));

	if(vSupplierList == null)
		strErrMsg = PO.getErrMsg();
	else{
		vReqInfo = PO.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null)
			strErrMsg = PO.getErrMsg();
		else
			strReqIndex = (String)vReqInfo.elementAt(1);
				
		vReqPO = PO.operateOnPOInfo(dbOP,request,4,strReqIndex);
		if(vReqPO == null)
			strErrMsg = PO.getErrMsg();
		else
			strPOIndex = (String)vReqPO.elementAt(0);
	}
	
	iNumRows = 25;
	
		
		
String strGrandTotal = null;		
%>

<body onLoad="window.print()">
<%


if(vReqInfo == null){dbOP.cleanUP();%>
	<div align="center"><%=PO.getErrMsg()%></div>
<%return;}

// use this poara dili na mag cge pangita pila ka elements sa vReqItems na vector
int iItems = 12;
if(bolAdditionalData)
	iItems = 22;

String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP, false, false);
boolean bolPrintEOF = false;
boolean bolPrintPurpose = false;
for(int iSuppCtr = 0; iSuppCtr < vSupplierList.size(); iSuppCtr += 2){
	bolPrintEOF = false;
 	bolPrintPurpose = false;
	
	//vReqItems = PO.operateOnPOItems(dbOP,request,4);
	vReqItems = PO.operateOnPOItems(dbOP,request, 4, (String)vSupplierList.elementAt(iSuppCtr), bolAdditionalData, false);
	
	if(vReqItems == null || vReqItems.size() == 0)
		continue;
	
	iLoop = 0;
	dTotalAmount = 0d;
	dGrandTotal = 0d;
	
	strTemp = " and SUPPLIER_INDEX = "+ (String)vSupplierList.elementAt(iSuppCtr);	
	
	vAddtlCost = PO.showAdditionalCost(dbOP,strReqIndex+strTemp);
	if(vAddtlCost == null)
		vAddtlCost = new Vector();
		
	vSupplierInfo = SUP.getSupplierInfo(dbOP, request, (String)vSupplierList.elementAt(iSuppCtr));
	if(vSupplierInfo == null)
		vSupplierInfo = new Vector();
	else
		vSupplierInfo.remove(0);//element count
	
	
if(vReqItems!= null){

	if(bolAdditionalData)
		strGrandTotal = (String)vReqItems.remove(0);
		
	int iPageCount = vReqItems.size()/iItems/iNumRows;
	if((vReqItems.size() % (iItems * iNumRows)) > 0) ++iPageCount;
	int iPageNumber = 0;
	
	for(;iLoop < vReqItems.size();){
		iCountRows = 0;
		dPageAmount = 0d;
		++iPageNumber;
		
	
	if(iSuppCtr > 0){%>
		<div style="page-break-after:always;">&nbsp;</div>
	<%}
	
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td class="thinborder" width="11%" rowspan="3" align="center">
			<img src="../../../images/logo/UB_BOHOL.gif" border="0" height="80" width="80">
		</td>
		<td class="thinborderBOTTOM" width="51%" rowspan="3" align="center" valign="top"><strong style="font-size:14px;"><%=strSchName%></strong><br><%=strSchAddr%>
		<br><br><br><strong style="font-size:15px;">P U R C H A S E &nbsp; &nbsp; O R D E R</strong></td>
		<td class="thinborder" width="38%" height="35" align="center" valign="bottom" style="font-size:12px;"><strong><%=(String)vReqPO.elementAt(1)%></strong><br>Order Number</td>
	</tr>
	<tr>
		<td class="thinborder" width="38%" height="35" align="center" valign="bottom" style="font-size:12px;"><strong><%=(String)vReqPO.elementAt(2)%></strong><br>Date of Order</td>
	</tr>
	<tr>
	<%
		if(WI.getStrValue(vReqInfo.elementAt(4)).equals("0"))
			strTemp = (String)vReqInfo.elementAt(10);
		else
			strTemp = WI.getStrValue((String)vReqInfo.elementAt(9))+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All");
		%>
		<td class="thinborder" width="38%" height="35" align="center" valign="bottom" style="font-size:12px;"><strong><%=strTemp%></strong><br>Department</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td height="10"></td></tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">    
	<tr><%
	  strTemp = "";
	  if (vSupplierInfo != null && vSupplierInfo.size() >0 )
	     strTemp = (String) vSupplierInfo.elementAt(2);
	  %>
	    <td class="thinborder" height="25" colspan="4"><strong style="font-size:12px;">Supplier:</strong><%=strTemp%></td>
    </tr>
	<tr>
		<td class="thinborder" height="25" colspan="4" align="center"><em>You are hereby request to deliver to the Property Custodian the following articles at the prices indicated below</em></td>
	</tr>	    
    <tr style="font-weight:bold;">
	    <td class="thinborder" align="center" height="25">Articles/Items</td>
	    <td class="thinborder" width="13%" align="center">Quantity/ Unit</td>
	    <td class="thinborder" width="13%" align="center">Unit Price</td>
	    <td class="thinborder" width="13%" align="center">Amount</td>
    </tr>
	
    <%		
	for(;iLoop < vReqItems.size();iLoop+=iItems,++iCountRows){	
	if(iCountRows > iNumRows)
		break;
	%>
    <tr>
	    <td class="thinborder" height="25"><%=(String)vReqItems.elementAt(iLoop+1)%>/<%=(String)vReqItems.elementAt(iLoop+2)%> <%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"(",")","")%></td>
	    <td class="thinborder" align="center"><%=(String)vReqItems.elementAt(iLoop+5)%> <%=(String)vReqItems.elementAt(iLoop+6)%></td>
		<%
	  strTemp = WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;");
	  if(bolAdditionalData)
	  	strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+12),strTemp);
	  %>
	    <td class="thinborder" align="right">&nbsp;<%=strTemp%></td>
		<%
		if(bolAdditionalData)
	  	  	dPageAmount += Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(((String)vReqItems.elementAt(iLoop+19)),",",""),"0"));
		else
			dPageAmount += Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(((String)vReqItems.elementAt(iLoop+7)),",",""),"0"));
		
	  	if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0"))
	  		strTemp = "&nbsp;";
		else
			strTemp = CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true);
		
		if(bolAdditionalData)
	  		strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+19),strTemp);
	  %>
	    <td  class="thinborder" align="right">&nbsp;<%=strTemp%></td>
    </tr>
    <%}
	dTotalAmount = dPageAmount;	
	
	if(iLoop+iItems >= vReqItems.size()){
	++iCountRows;%>	
	<tr> 
      
      <td height="15" align="right" class="thinborder">&nbsp;</td>
      <td height="15" align="right" class="thinborder">&nbsp;</td>
      <td height="15" align="right" class="thinborder"><strong>TOTAL></strong></td>
      <td height="15" align="right" class="thinborder"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></strong></td>
	</tr>
	<%}%>
<!--    <tr> 
      <td  height="15" colspan="4" class="thinborder">&nbsp;</td>
      <td class="thinborder"><div align="left"><strong>PAGE AMOUNT : </strong></div></td>
	  <%
	  //dTotalAmount += dPageAmount;
	  strTemp = "&nbsp;";
	  if(dPageAmount > 0)
	  	strTemp = CommonUtil.formatFloat(dPageAmount,true);
	  %>
      <td class="thinborder"><div align="right"><strong><%=strTemp%></strong></div>
	  </td>
    </tr>-->
  </table>

	<%if (iLoop < vReqItems.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    
	}//end of outer loop


if(vAddtlCost != null && vAddtlCost.size() > 2){%>
  <br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="15" colspan="3" class="thinborder"><div align="center"><strong>ADDITIONAL 
          COST FOR THIS PO</strong></div></td>
    </tr>
    <%for(iLoop = 0;iLoop < vAddtlCost.size();iLoop+=5){
		//dGrandTotal += Double.parseDouble(ConversionTable.replaceString((String)vAddtlCost.elementAt(iLoop+4),",",""));
	%>
    <tr> 
      <td width="42%" height="20" class="thinborder">&nbsp;<%=vAddtlCost.elementAt(iLoop+2)%> <%strTemp = "";
	  	strErrMsg = "";	  
	  for(;(iLoop+4+5) < vAddtlCost.size();){	  
	  		if(!((String)vAddtlCost.elementAt(iLoop+1)).equals((String)vAddtlCost.elementAt(iLoop+1+5)))
	  			break;
			strTemp += (String)vAddtlCost.elementAt(iLoop+3)+"<br>";
			strErrMsg += (String)vAddtlCost.elementAt(iLoop+4)+"<br>";			
			iLoop+=5;
	    }%> </td>
      <td width="29%" class="thinborder"><%=strTemp+(String)vAddtlCost.elementAt(iLoop+3)%></td>
	  <%
	  
	  	//if(WI.fillTextValue("print_pg").equals("2"))
	  	//	strTemp = "&nbsp;";
		//else{
			strTemp = strErrMsg+(String)vAddtlCost.elementAt(iLoop+4);
			dGrandTotal += Double.parseDouble(ConversionTable.replaceString((String)vAddtlCost.elementAt(iLoop+4),",",""));
		//}
	  %>
      <td width="29%" class="thinborder"><div align="right"><%=strTemp%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="15" colspan="2" class="thinborder"><div align="right"><strong>GRAND TOTAL : </strong></div></td>
      <td class="thinborder">
	  <div align="right"><strong><%=CommonUtil.formatFloat(dGrandTotal+dTotalAmount,true)%></strong></div>
	  </td>
    </tr>
	
  </table>
  <%}%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td><strong>APPROVED:</strong></td></tr>
	<tr>
	<%
	strTemp = "DR. Cristeta B. Tirol";
	%>
		<td align="center" height="35" valign="bottom" style="font-size:12px;"><strong><%=strTemp.toUpperCase()%></strong><br>VP-Finance</td>
	</tr>
</table>
 
 
  
  
<%  }// para dili mag null pointer
  
}%>
  
</body>
</html>
<%
dbOP.cleanUP();
%>
