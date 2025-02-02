<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode ="";
	
	String strInfo5 = (String)request.getSession(false).getAttribute("info5");
	
	boolean bolIsUPHD = false;
	if(strSchCode.startsWith("UPH") && strInfo5 == null)	
		bolIsUPHD = true;	
		
boolean bolIsAUF = strSchCode.startsWith("AUF");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>

div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFFFFF;
   
  }

TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
}
TABLE.thinborderALL {
    border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
}
TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderLEFTBottomRIGHT {
    border-bottom: solid 1px #000000;
 	border-left: solid 1px #000000;
  	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderBottomRight {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderLeftRight {
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

TD.thinborderRight {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

TD.NoBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();" topmargin="0" bottommargin="0">
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;	
 		
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
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
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
								"Admin/staff-PURCHASING-DELIVERY-View delivery Status","issuance_details_print.jsp");
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
		
 	Delivery deliveryItem = new Delivery();	

	Vector vItemDetails = null;
	Vector vRetResult    = null;
	int iIndexOf = 0; 

 	int iCount = 1;
	int iCountRows = 0;
	int iNumRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	String strSupplierName = null;
	vRetResult = deliveryItem.getIssuanceInfoAUF(dbOP,request);
	
 	if(vRetResult == null)
		strErrMsg = deliveryItem.getErrMsg();
	else{
		vItemDetails = (Vector) vRetResult.remove(vRetResult.size() - 1);
		
		strTemp = " select supplier_name "+ 
			" from pur_delivery "+
			" join pur_po_info on (pur_delivery.po_index = pur_po_info.po_index)  "+
			" join pur_supplier_profile on (pur_po_info.supplier_index = pur_supplier_profile.profile_index)  "+
			" where delivery_index =  "+(String)vRetResult.elementAt(0);
		strSupplierName = dbOP.getResultOfAQuery(strTemp, 0);
		
	}


if(strErrMsg != null)	{dbOP.cleanUP();
%>	
<div style="text-align:center; font-size:12px; color:#FF0000;"><strong><%=strErrMsg%></strong></div>
<%return;}%>

<form name="form_" >
  <%if(vRetResult != null && vRetResult.size() > 1){%>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  	<tr>
		<td width="8%" rowspan="2" class="thinborder" align="center"><img src="../../../images/logo/UB_BOHOL.gif" width="70" height="70" border="0"></td>
		<td width="56%" rowspan="2" class="thinborderBottom" valign="top" align="center">
			<strong style="font-size:14px;"><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong><br>
			<%=SchoolInformation.getAddressLine1(dbOP, false, false)%><br>
			OFFICE OF THE PROPERTY CUSTODIAN<br><br>ISSUANCE RECEIPT</td>
		<td width="36%" height="40" class="thinborder" valign="bottom" align="center">
			<div style="text-align:center; border-bottom:solid 1px #000000; width:60%"><%=(String)vRetResult.elementAt(4)%></div>DATE</td>
	</tr>
	<tr>		
		<td height="40" class="thinborder" valign="bottom" align="center">
		<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(10));
		strErrMsg = WI.getStrValue((String)vRetResult.elementAt(11));
		if(strTemp.length() > 0 && strErrMsg.length() > 0)
			strTemp += "/";
		strTemp += strErrMsg;
		%>
			<div style="text-align:center; border-bottom:solid 1px #000000; width:98%"><%=strTemp%></div>DEPARTMENT</td>
	</tr>
	<tr>
		<td valign="top" colspan="3" class="thinborder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="">
  	<tr>
		<td style="padding:2px;" width="8%" height="30" class="" valign="bottom">Supplier</td>
		<td style="padding:2px;" valign="bottom" class=""><div style="border-bottom: solid 1px #000000; width:95%"><%=WI.getStrValue(strSupplierName)%></div></td>
		<td class="thinborderLeft" width="25%"  style="padding:2px;" valign="middle">
			<input name="_2" disabled="disabled" border="0" 
				style="font-size:11px; height:15px; width:25px; background-color:#FFFFFF; border:solid 1px #000000;	" /> Partial Delivery<br>
			<input name="_2" disabled="disabled" border="0" 
				style="font-size:11px; height:15px; width:25px; background-color:#FFFFFF; border:solid 1px #000000;	" /> Complete Delivery
		</td>
		<td width="32%" valign="top" class="thinborderLeft" style="padding-bottom:1px;">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td height="20" valign="bottom" width="38%">Invoice No.</td>
					<td valign="bottom" width="62%"><div style="border-bottom: solid 1px #000000; width:95%">: <%=(String)vRetResult.elementAt(3)%></div></td>
				</tr>
				<tr>
					<td height="20" valign="bottom">Date</td>
					<td valign="bottom"><div style="border-bottom: solid 1px #000000; width:95%">: <%=(String)vRetResult.elementAt(5)%></div></td>
				</tr>
			</table>	
		</td>
	</tr>
  </table>
		</td>
	</tr>
  </table>
  

  
  <%if(vItemDetails != null && vItemDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="">
    
    <tr>
		<td width="13%" align="center" class="thinborder"><strong>Quantity / Unit</strong></td>
      <td width="46%" height="25" align="center" class="thinborder"><strong>Description </strong></td>
      
      <td width="13%" align="center" class="thinborder"><strong>Unit Price </strong></td>
      <td width="14%" align="center" class="thinborderLEFTBottomRIGHT"><strong>Amount</strong></td>
      </tr>
    <%iCount = 1; 
	String strInvoiceNumber = (String)vRetResult.elementAt(3);
	double dTotal = 0d;
		for(int i = 0;i < vItemDetails.size();i+=8,++iCount, iCountRows++){%>	
    <tr>
		<td align="center" class="thinborder"><%=CommonUtil.formatFloat((String)vItemDetails.elementAt(i),false)%>&nbsp;<%=(String)vItemDetails.elementAt(i+6)%>&nbsp;</td>
      <td height="22" class="thinborder">&nbsp;<%=(String)vItemDetails.elementAt(i+4)%><%=WI.getStrValue((String)vItemDetails.elementAt(i+7),"(",")","")%></td>
      
      <td align="right" class="thinborder"><%=(String)vItemDetails.elementAt(i+2)%></td>
	  <%
	  try{
	  	dTotal += Double.parseDouble(ConversionTable.replaceString((String)vItemDetails.elementAt(i+3), ",", ""));
	  }catch(Exception e){}
	  %>
      <td align="right" class="thinborderLEFTBottomRIGHT"><%=(String)vItemDetails.elementAt(i+3)%></td>
      </tr>
		<%}for(;iCountRows < iNumRows;++iCountRows){%>
    <tr>
      <td height="22" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborderLEFTBottomRIGHT">&nbsp;</td>
      </tr>		
    <%}%>
	<tr>
      <td height="22" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><strong>TOTAL</strong></td>
      <td align="right" class="thinborderLEFTBottomRIGHT"><strong><%=CommonUtil.formatFloat(dTotal,true)%></strong></td>
      </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="" bgcolor="#FFFFFF">
  	<tr>
		<td class="thinborderLeft" width="50%" valign="top" style="text-indent:50px; padding:5px;">
			I certify that the merchandise listed was received on the date indicated
		above in good condition.		</td>
		<td class="thinborderLeftRight" width="50%" valign="top" style="padding:5px;">Issued by:</td>
	</tr>
	<tr>
		<td class="thinborder" height="50" align="center" valign="bottom">
		<div style="text-align:center; border-bottom:solid 1px #000000; width:90%"><%=WI.getStrValue(vRetResult.elementAt(8), "&nbsp;")%></div>Name & Signature/Date Signed</td>
		<td class="thinborderLEFTBottomRIGHT" height="50" align="center" valign="bottom">
		<div style="text-align:center; border-bottom:solid 1px #000000; width:90%">&nbsp;</div>Name & Signature</td>
	</tr>
  </table>
  
	

<%
if(bolIsUPHD){
%>  
<div id="processing" class="processing">
<table cellpadding="0" cellspacing="0" border="0" Width="100%" style="border:solid 1px #000000;">
	<tr>
		<td>UPHS-01-PROP-MI-02</td>		
	</tr>
	<tr>
		<td>01-10-2010 &nbsp; &nbsp; &nbsp; REV.01</td>		
	</tr>	
</table>
</div>	   
<%}%>

  <%}}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>