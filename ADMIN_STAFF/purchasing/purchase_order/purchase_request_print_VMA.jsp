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
<form name="form_" method="post" action="./purchase_request_print_VMA.jsp">
<%


if(vReqInfo == null){dbOP.cleanUP();%>
	<div align="center"><%=PO.getErrMsg()%></div>
<%return;}

// use this poara dili na mag cge pangita pila ka elements sa vReqItems na vector
int iItems = 12;
if(bolAdditionalData)
	iItems = 22;

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



  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="2" align="center">
		<font style="font-size:14px;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
         <font style="font-size:12px;"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
		</td>
	</tr>
	<tr><td height="25" colspan="2">&nbsp;</td></tr>
	<tr>
		<td width="68%">
		<font style="font-size:12px;">VMA: (034) 444-1092<br>
		FAX NO. (034) 444-1090</font>
		</td>
		<td width="32%">
		<font style="font-size:12px;">VMA-TC: (034) 444-1588<br>TELEFAX: (034) 444-0133</font>
		</td>
	</tr>
	<tr><td height="30" colspan="2">&nbsp;</td></tr>
	<tr><td colspan="2" align="center">
	<font style="font-size:12px;">Email Address: <font color="#0033FF"><a href="#">vmaglobal7@yahoo.com</a></font><br>
	Website: <font color="#0033FF"><a href="#">www.vma.edu.ph</a></font></font>
	</td></tr>
	<tr><td height="25" colspan="2">&nbsp;</td></tr>
	<tr><td height="25" colspan="2" align="center"><strong style="font-size:16px;">PURCHASE ORDER</strong></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="30" colspan="4">&nbsp;</td></tr>
	<tr>
		<td width="13%" height="20" style="font-size:14px;">To </td>
		<%
	  strTemp = "";
	  if (vSupplierInfo != null && vSupplierInfo.size() >0 )
	     strTemp = (String) vSupplierInfo.elementAt(2);
	  %>
		<td width="43%" style="font-size:14px;">: <%=strTemp%></td>
		<td width="14%" style="font-size:14px;">P.O. Number</td>
		<td width="30%" style="font-size:14px;">: <%=(String)vReqPO.elementAt(1)%></td>
	</tr>
	<tr>
		<td height="20" style="font-size:14px;">Charge To </td>
		<%
		if(WI.getStrValue(vReqInfo.elementAt(4)).equals("0"))
			strTemp = (String)vReqInfo.elementAt(10);
		else
			strTemp = WI.getStrValue((String)vReqInfo.elementAt(9))+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All");
		%>
		<td style="font-size:14px;">: <%=strTemp%></td>
		<td style="font-size:14px;">P.O. Date</td>
		<td style="font-size:14px;">: <%=(String)vReqPO.elementAt(2)%></td>
	</tr>

	<tr>
		<td>&nbsp;</td>
		<td height="20">&nbsp;</td>
		<td style="font-size:14px;">Date Needed </td>
		<td style="font-size:14px;">: <%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td height="20">&nbsp;</td>
		<td style="font-size:14px;">Terms</td>         
		<td style="font-size:14px;">: <%=WI.getStrValue(vReqPO.elementAt(13), "Not set")%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td height="20">&nbsp;</td>
		<td style="font-size:14px;">MRAQ Number</td>
		<td style="font-size:14px;">: <%=(String)vReqInfo.elementAt(13)%></td>
	</tr>
</table>
	
<br>
  <table width="100%" border="0" class="" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
		    
    <tr> 
      <td width="7%" height="15" class="thinborderTOPLEFTBOTTOM"><div align="center"><strong>QTY</strong></div></td>
      <td width="7%" class="thinborderTOPLEFTBOTTOM"><div><strong>UNIT</strong></div></td>
      <td class="thinborderTOPLEFTBOTTOM"><div align="center"><strong>NAME &amp; DESCRIPTION OF MATERIALS</strong></div></td>
      <td width="14%" class="thinborderTOPLEFTBOTTOM"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="14%" class="thinborderALL"><div align="center"><strong>TOTAL PRICE</strong></div></td>
    </tr>
	
    <%		
	for(;iLoop < vReqItems.size();iLoop+=iItems,++iCountRows){	
	if(iCountRows > iNumRows)
		break;
	%>
    <tr> 
      <td style="font-size:14px;" height="15" class="thinborderLEFT"><div align="center"><%=(String)vReqItems.elementAt(iLoop+5)%>&nbsp;</div></td>
      <td style="font-size:14px;" class="thinborderLEFT"><div align="left"><%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td style="font-size:14px;" class="thinborderLEFT"><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+1)%>/<%=(String)vReqItems.elementAt(iLoop+2)%> <%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"(",")","")%> </div></td>
	  <%
	  strTemp = WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;");
	  if(bolAdditionalData)
	  	strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+12),strTemp);
	  %>
      <td style="font-size:14px;" class="thinborderLEFT"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
      <%
	  	if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0"))
	  		strTemp = "&nbsp;";
		else
			strTemp = CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true);
		
		if(bolAdditionalData)
	  		strTemp = WI.getStrValue((String)vReqItems.elementAt(iLoop+19),strTemp);
	  %>
	  <td style="font-size:14px;" class="thinborderLEFTRIGHT"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%></div></td> 
	  <%
	  
	  	if(bolAdditionalData)
	  	  	dPageAmount += Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(((String)vReqItems.elementAt(iLoop+19)),",",""),"0"));
		else
			dPageAmount += Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(((String)vReqItems.elementAt(iLoop+7)),",",""),"0"));
		
		%>
    </tr>
    <%}
	dTotalAmount = dPageAmount;	
	/*bolPrintEOF = false;
boolean bolPrintPurpose = false;*/

	if(iLoop+iItems >= vReqItems.size()){
	++iCountRows;
	%>
	<tr> 
      
      <td height="15" align="center" class="thinborderLEFT">&nbsp;</td>
      <td height="15" align="center" class="thinborderLEFT">&nbsp;</td>
	  <td height="15" align="center" class="thinborderLEFT">------------ NOTHING FOLLOWS ------------</td>
      <td height="15" align="center" class="thinborderLEFT">&nbsp;</td>
      <td height="15" align="center" class="thinborderLEFTRIGHT">&nbsp;</td>
	</tr>	
		
	<%}
	for(;iCountRows < (iNumRows-1);++iCountRows){%>
    <tr> 
      <td height="15" class="thinborderLEFT">&nbsp;</td>
      <td height="15" class="thinborderLEFT">&nbsp;</td>
      <td height="15" class="thinborderLEFT">&nbsp;</td>
      <td height="15" class="thinborderLEFT">&nbsp;</td>
      <td height="15" class="thinborderLEFTRIGHT">&nbsp;</td>
    </tr>
    <%}
	
	if(iLoop+iItems >= vReqItems.size() && WI.getStrValue((String)vReqInfo.elementAt(6)).length() > 0){
	++iCountRows;%>
	<tr> 
      
      <td height="15" align="center" class="thinborder">&nbsp;</td>
      <td height="15" align="center" class="thinborder">&nbsp;</td>
	  <td height="15" align="center" class="thinborder">PURPOSE : <%=WI.getStrValue((String)vReqInfo.elementAt(6))%></td>
      <td height="15" align="center" class="thinborder">&nbsp;</td>
      <td height="15" align="center" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
	</tr>
	<tr> 
      <td height="15" align="right" colspan="5" class="thinborderBOTTOMLEFTRIGHT"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></strong></td>
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
			dGrandTotal += Double.parseDouble(ConversionTable.replaceString((String)vAddtlCost.elementAt(iLoop+4),",",""));		
			iLoop+=5;
	    }%> </td>
      <td width="29%" class="thinborder"><%=strTemp+(String)vAddtlCost.elementAt(iLoop+3)%></td>
	  <%
	  
	  	if(WI.fillTextValue("print_pg").equals("2"))
	  		strTemp = "&nbsp;";
		else{
			strTemp = strErrMsg+(String)vAddtlCost.elementAt(iLoop+4);
			dGrandTotal += Double.parseDouble(ConversionTable.replaceString((String)vAddtlCost.elementAt(iLoop+4),",",""));
		}
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
	<tr>
		<td width="29%" height="25"><strong>TO BE DELIVERED TO</strong></td>
	    <td width="71%"><strong>VMA GLOBAL COLLEGE</strong></td>
	</tr>
	<tr><td colspan="2" height="35"><strong>VERY IMPORTANT</strong></td></tr>
	<tr>
		<td colspan="2">
		1.Deliveries covered by our Order should be addressed to Visayan Maritime Academy & Training Center, Sum-ag, Bacolod City.
		</td>
	</tr>
	<tr>
		<td colspan="2">
		2.Quality subject to approved Stock Clerk’s signature is for acknowledgement of quality only.
		</td>
	</tr>
	<tr>
		<td colspan="2">
		3.Original invoices and/or Original Delivery Receipts of Deliveries should be submitted to our Accountant covering vouchers can be processed for payment.
		</td>
	</tr>
	<tr>
		<td colspan="2">
		4.Failure to comply either the requirement of this PO will be sufficient reason for the 
			cancellation of the whole order and part there of shall charge to supplier for any lose or damages entailed.
		</td>
	</tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr><td colspan="2">THIS PURCHASE ORDER MUST BE ATTACHED TO YOUR BILL COVERING THIS ORDER.</td></tr>
</table> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<%
		strTemp = "";
		if(vReqPO != null && vReqPO.size() > 1)	   	  	
			strTemp = (String)vReqPO.elementAt(15);	
		%>
		<td align="center" height="40" width="30%" valign="bottom"><div style="border-bottom:solid 1px; width:90%"><%=WI.getStrValue(strTemp).toUpperCase()%></div></td>
		<td align="center" width="10%" valign="bottom"><div style="border-bottom:solid 1px; width:90%"></div></td>
		<%
		strTemp = "";
			if(vReqPO != null && vReqPO.size() > 1)
		   	  	strTemp = (String)vReqPO.elementAt(16);
		%>
		<td align="center" width="30%" valign="bottom"><div style="border-bottom:solid 1px; width:90%"><%=WI.getStrValue(strTemp)%></div></td>
		<td align="center" width="10%" valign="bottom"><div style="border-bottom:solid 1px; width:90%"></div></td>
	</tr>
	<tr>
	    <td align="center">Prepared by</td>
	    <td align="center">Date</td>
	    <td align="center">Recommending Approval</td>
	    <td align="center">Date</td>
	 </tr>
	 <tr>
	 	<%
		strTemp = "";
		if(vReqPO != null && vReqPO.size() > 1)
	   	  	strTemp = (String)vReqPO.elementAt(14);
		
		%>
		<td align="center" height="40" valign="bottom"><div style="border-bottom:solid 1px; width:90%"><%=WI.getStrValue(strTemp)%></div></td>
		<td align="center" valign="bottom"><div style="border-bottom:solid 1px; width:90%"></div></td>
		<%
		strTemp = "";
			if(vReqPO != null && vReqPO.size() > 1)
		   	  	strTemp = (String)vReqPO.elementAt(17);	
		%>
		<td align="center" valign="bottom"><div style="border-bottom:solid 1px; width:90%"><%=WI.getStrValue(strTemp)%></div></td>
		<td align="center" valign="bottom"><div style="border-bottom:solid 1px; width:90%"></div></td>
	</tr>
	<tr>
	    <td align="center">Verified by</td>
	    <td align="center">Date</td>
	    <td align="center">Approved by</td>
	    <td align="center">Date</td>
	 </tr>
</table> 
  
  
<%  }// para dili mag null pointer
  
}%>
  
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
