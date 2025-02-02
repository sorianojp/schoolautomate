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
<%if(!bolIsDBTC){%>
    border-left: solid 1px #000000;
	font-size: 10px;	
<%}else{%>
	font-size: 12px;	
<%}%>
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
	String[] astrTerm = {"Cash on Delivery (COD)", "Prepaid", "Given No. of Days", "Specific Day of the Month", 
			"No. of Days after End of Month","Day of Month after End of Month",""};
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
	// use this poara dili na mag cge pangita pila ka elements sa vReqItems na vector
	int iItems = 12;


	vSupplierInfo = PO.getSupDetails(dbOP,request);
	if(vSupplierInfo == null) 
		strErrMsg = PO.getErrMsg();
	else {
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

		if(WI.fillTextValue("print_supplier").length() > 0){
			strTemp = " and SUPPLIER_INDEX = "+ WI.fillTextValue("print_supplier");	
		}else{
			strTemp = "";
		}
		vAddtlCost = PO.showAdditionalCost(dbOP,strReqIndex+strTemp);
		if(vAddtlCost == null)
			strErrMsg = PO.getErrMsg();
	}	



/** REMOVED.. Dec 23, 2013.... 
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

	if(WI.fillTextValue("print_supplier").length() > 0){
		strTemp = " and SUPPLIER_INDEX = "+ WI.fillTextValue("print_supplier");			
	}else{
		strTemp = "";
	}
	
	vSupplierInfo = PO.getSupDetails(dbOP,request);
	
	vAddtlCost = PO.showAdditionalCost(dbOP,strReqIndex+strTemp);
	if(vAddtlCost == null)
		strErrMsg = PO.getErrMsg();
**/	

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
	

%>
<body>
<form name="form_" method="post" action="./purchase_request_print_UPHD.jsp">
<%if(strErrMsg != null){dbOP.cleanUP();%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25" align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
<%
return;}
if(vReqItems!= null){
	int iPageCount = vReqItems.size()/iItems/iNumRows;
	if((vReqItems.size() % (iItems * iNumRows)) > 0) ++iPageCount;
	int iPageNumber = 0;
	for(;iLoop < vReqItems.size();){
		iCountRows = 0;
		dPageAmount = 0d;
		++iPageNumber;

if(vReqInfo != null){%>     
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
	  <td colspan="2" height="170px">&nbsp;</td>
    </tr>
	<tr>
		<td width="85%">&nbsp;</td>
		<td width="15%" valign="bottom" style="padding-left:10px;" height="25px"><%=iPageNumber%> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <%=iPageCount%></td>
	</tr>
	<tr>
	  <td>&nbsp;</td>
	  <td height="25px"><%=WI.getTodaysDate(1)%></td>
    </tr>
	<tr>
	    <td height="15px">&nbsp;</td>
	    <td>&nbsp;</td>
	</tr>
</table>  
 
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<%
		strTemp = "&nbsp;";
		if (vSupplierInfo != null && vSupplierInfo.size() >0 )
			strTemp = (String) vSupplierInfo.elementAt(0);
			
		  %>	
		<td colspan="2" rowspan="3" style="padding-left:150px;"><%=strTemp%>*</td>
		<%
		  	/*if (vSupplierInfo != null && vSupplierInfo.size() >0 )
				strTemp = (String) vSupplierInfo.elementAt(4);
			else
			 	strTemp = "0";
			
			strTemp = WI.getStrValue(strTemp,"6");*/
			
			if(vReqPO != null && vReqPO.size() > 0)
				strTemp = (String)vReqPO.elementAt(13);
			else
				strTemp = "Not set";
			
		  %>
		<td width="48%" height="29" valign="top"><%=WI.getStrValue(strTemp,"Not Set")%><%//=WI.getStrValue(astrTerm[Integer.parseInt(strTemp)],"")%></td>
	</tr>
	
	<tr>
		<td height="29"><%=(String)vReqInfo.elementAt(13)%><%=WI.getStrValue((String)vReqPO.elementAt(2)," / ","","")%></td>
	</tr>
	
	<tr>
		<%
			strTemp = "";
			if (vSupplierInfo != null && vSupplierInfo.size() >0 )
			 strTemp = (String) vSupplierInfo.elementAt(0);
		  %>
		<td height="29" valign="bottom">PROPERTY OFFICE LAS PIÑAS</td>
	</tr>
	
	<tr>
	<%
		strTemp = "";
		if (vSupplierInfo != null && vSupplierInfo.size() >0 )
			strTemp = (String) vSupplierInfo.elementAt(5);
			
		  %>	
		<td width="33%" height="29"><%=WI.getStrValue(strTemp)%></td>
		<%
		strTemp = "";
		if (vSupplierInfo != null && vSupplierInfo.size() >0 )
			strTemp = (String) vSupplierInfo.elementAt(2);
		%>
		<td width="19%"><%=strTemp%></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td height="60" colspan="3">&nbsp;</td>
	</tr>
</table>
  
	
    
  
  
  <%if(vReqItems != null && vReqItems.size() > 0){%>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> <td height="15"></td></tr>
  	<tr>
		<td valign="top" height="365px">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">  
				<%		
				for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=iItems,++iCountRows){	
				%>
				<tr> 
				  <td valign="top" width="6%"  height="15" class=""><div align="center"><%=(iLoop+iItems)/iItems%></div></td>
				  <td valign="top" width="13%" class=""><div><%=(String)vReqItems.elementAt(iLoop+5)%>&nbsp; <%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
				  <td valign="top" width="53%" class=""><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+1)%>/<%=(String)vReqItems.elementAt(iLoop+2)%> 
				  	<%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"(",")","")%> </div></td>
				  <td valign="top" width="14%" class=""><div align="right">
				  	<%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%>&nbsp;</div></td>
				  <td valign="top" width="14%" class=""><div align="right">
				  <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
						&nbsp;
					<%}else{%>
						<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
				  <%}%>&nbsp;</div></td> 
				  <%
				  
				  dPageAmount = Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(((String)vReqItems.elementAt(iLoop+7)),",",""),"0"));
				  dTotalAmount += dPageAmount;
				  %>
				</tr>
				<%}%>  
		  </table>
		</td>
	</tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<%
		strTemp = "&nbsp;";
		if ((String)vReqPO.elementAt(8)!= null){
			strTemp = (String)vReqPO.elementAt(8)+" calendar days from receipt of this PO";
		}
		%>
		<td width="33%" height="30" align="center" valign="bottom"><%=strTemp%></td>
		<td width="34%" style="padding-left:30px;"><!--PURCHASING OFFICER-->&nbsp;</td>
		<td width="33%" align="right"><%=CommonUtil.formatFloat(dTotalAmount,true)%></td>
	</tr>
	<tr>
		<td height="30">&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td height="30">&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
</table>
  
  
  
	<%if (iLoop < vReqItems.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }}}%>
	
	
	

<script>window.print();</script>
  <%}// para dili mag null pointer%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
