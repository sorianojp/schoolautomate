<%@ page language="java" import="utility.*,purchasing.Requisition,purchasing.PO,purchasing.Supplier,java.util.Vector" %>
<%	
	WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
}
TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
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
								"PURCHASING-PURCHASE ORDER","purchase_request_waive_item_print.jsp");

	Requisition REQ = new Requisition();
	PO PO = new PO();	
	Supplier SUP = new Supplier();
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vReqPO = null;
	Vector vAddtlCost = null;
	Vector vSupplierInfo = null;
	double dDaysRequired  = 0d;
	
	
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
	double dTotalAmount = 0d;
	String strSchCode = dbOP.getSchoolIndex();	

	vReqInfo = PO.operateOnReqInfo(dbOP,request,3);
	if(vReqInfo == null)
		strErrMsg = PO.getErrMsg();
	else
		strReqIndex = (String)vReqInfo.elementAt(1);
	strReqIndex = WI.getStrValue(strReqIndex,"0");
	vReqPO = PO.operateOnPOInfo(dbOP,request,4,strReqIndex);
	if(vReqPO == null)
		strErrMsg = PO.getErrMsg();
	
	vReqItems = PO.operateOnPOItems(dbOP,request,4);
//	if(vReqItems == null){
//		vReqItems = PO.operateOnReqItems(dbOP,request);
		if(vReqItems == null)
			strErrMsg = REQ.getErrMsg();				
	//}
	
	if(WI.fillTextValue("print_supplier").length() > 0){
		strTemp = " and SUPPLIER_INDEX = "+ WI.fillTextValue("print_supplier");	
		vSupplierInfo = PO.getSupDetails(dbOP,request);
	}else{
		strTemp = "";
	}
	
	vAddtlCost = PO.showAdditionalCost(dbOP,strReqIndex+strTemp);	
	if(vAddtlCost == null)
		strErrMsg = PO.getErrMsg();


	if(vReqItems != null)	
	for(;iLoop < vReqItems.size();){
		iCountRows = 0;
		dTotalAmount = 0d;
%>
<body onLoad="window.print()">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
	<%if(!strSchCode.startsWith("UI")){%>
	<tr> 
	 <td align="center" width="27%"><div align="right">&nbsp;
	  <%if(strSchCode.startsWith("CPU")){%>
	  <img src="../../../images/logo/CPU.gif" width="70" height="70" border="0">
	  <%}%>
	  </div></td>	
    <td height="25" colspan="2" width="46%"><div align="center"> 
            <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br><br>
          <br>
          <font size="+1"><strong>PURCHASE ORDER</strong></font> </div></td>
	 <td align="center" width="27%"><div align="right">&nbsp;</div></td>		  
  </tr>
  <%}else{%>
	  <tr> 
		<td height="25" colspan="4"><div align="center">&nbsp;<br>
          <br>
          <br>
          <br>
          <br>
        </div></td>
	  </tr>
  <%}%>
  </table>  
  <%if(strSchCode.startsWith("UI")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="15">&nbsp;</td>
      <td><font size="1">PO Date</font></td>
      <td><strong><font size="1"><%=(String)vReqPO.elementAt(2)%></font></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="1%" height="15">&nbsp;</td>
      <td width="13%"><font size="1">PO No.</font></td>
      <td width="38%"><strong><font size="1"><%=(String)vReqPO.elementAt(1)%></font></strong></td>
      <td width="15%"><font size="1">Supplier</font></td>
	        <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
	     strTemp = (String) vSupplierInfo.elementAt(0);
		 }else{
		 strTemp = "";
		 }
	  %>
      <td width="33%"><strong><font size="1"><strong><%=WI.getStrValue(strTemp,"")%></strong></font></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td><font size="1">Requisition No.</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(13)%></font></strong></td>
      <td><font size="1">Period of Delivery<br>
        </font></td>
      <td><font size="1"> <strong> 
        <% if ((String)vReqPO.elementAt(8)!= null){
			dDaysRequired = Double.parseDouble((String)vReqPO.elementAt(8));
		}else{
			dDaysRequired= 0;
		}
		
		if (dDaysRequired > 0){%>
        </strong><%=(String)vReqPO.elementAt(8)%><strong> calendar days from receipt 
        of this PO
		<%}%>
		</strong></font></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td><font size="1">Requested By</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(3)%></font></strong></td>
      <td><font size="1">Place of Delivery</font><br></td>
      <td><font size="1"> <strong>University of Iloilo, Rizal St., Iloilo City 
        </strong></font></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(3)).equals("0")){%>
    <tr> 
      <td height="15">&nbsp;</td>
      <td><font size="1">Office</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(10)%></font></strong></td>
      <td><font size="1">Invoice no.</font></td>
      <td><strong></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="15">&nbsp;</td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(9),"")+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></font></strong></td>
      <td><font size="1">Invoice no.</font></td>
      <td><strong></strong></td>
    </tr>
    <%}// if(((String)vReqInfo.elementAt(3)).equals(...%>
  </table>
  <%}else if(strSchCode.startsWith("CPU")){%>
    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%" height="15">&nbsp;</td>
      <td width="18%"><font size="1">Supplier</font></td>
      <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
	     strTemp = (String) vSupplierInfo.elementAt(0);
		 }else{
		 strTemp = "";
		 }
	  %>
      <td width="39%"><font size="1"><strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
      <td width="13%">&nbsp;</td>
      <td width="29%"><strong></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
	     strTemp = (String) vSupplierInfo.elementAt(1);
		 }else{
		 strTemp = "";
		 }
	  %>
      <td><font size="1">Address</font></td>
      <td><font size="1"><strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
      <td><font size="1">PO No.</font></td>
      <td><strong><font size="1"><%=(String)vReqPO.elementAt(1)%></font></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td><font size="1">Tel. No.: Fax No.</font></td>
      <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
			 strPhone = (String) vSupplierInfo.elementAt(2);
			 strFax = (String) vSupplierInfo.elementAt(3);
			 if (strPhone == null || strFax == null){
			 	strTemp = "";
			 }else{
				strTemp = "/";
			 }
		 }else{		 
			 strPhone = "";
			 strFax = "";
			 strTemp = "";
		 }
	  %>
      <td><strong><font size="1"><strong><%=WI.getStrValue(strPhone,"")%></strong></font><font size="1"><strong><%=WI.getStrValue(strTemp,"")%></strong></font><font size="1"><strong><%=WI.getStrValue(strFax,"")%></strong></font></strong></td>
      <td>&nbsp;</td>
      <td><strong></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td><font size="1">Credit Terms</font></td>
      <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
	     strTemp = (String) vSupplierInfo.elementAt(4);
		 }else{
		 strTemp = "0";
		 }
		 strTemp = WI.getStrValue(strTemp,"6");
	  %>
      <td><font size="1"><strong><%=WI.getStrValue(astrTerm[Integer.parseInt(strTemp)],"")%></strong></font></td>
      <td><font size="1">PO Date</font></td>
      <td><strong><font size="1"><%=(String)vReqPO.elementAt(2)%></font></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td colspan="4">
	    <%
		if ((String)vReqPO.elementAt(8)!= null){
			dDaysRequired = Double.parseDouble((String)vReqPO.elementAt(8));
		}else{
			dDaysRequired= 0;
		}
		
		if (dDaysRequired > 0){%>
        <font size="1"> Please supply us within (<%=(String)vReqPO.elementAt(8)%>) calendar days after receipt of this Purchase Order with 
        the article/s listed below:</font> 
        <%}%>
		</td>
    </tr>
  </table>
<%}else{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="15">&nbsp;</td>
      <td><font size="1">PO No.</font></td>
      <td><strong><font size="1"><%=(String)vReqPO.elementAt(1)%></font></strong></td>
      <td><font size="1">PO Date</font></td>
      <td><strong><font size="1"><%=(String)vReqPO.elementAt(2)%></font></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td><font size="1">Requisition No.</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(13)%></font></strong></td>
      <td><font size="1">Requested By</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(3)%></font></strong></td>
    </tr>
    <tr> 
      <td width="2%" height="15">&nbsp;</td>
      <td width="19%"><font size="1">Request Type</font></td>
      <td width="37%"><font size="1"><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(2))]%></strong></font></td>
      <td width="13%"><font size="1">Purpose/Job</font></td>
      <td width="29%"><strong><font size="1"><%=(String)vReqInfo.elementAt(6)%></font></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td><font size="1">Requisition Status</font></td>
      <td><strong><font size="1"><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(11))]%></font></strong></td>
      <td><font size="1">Requisition Date</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(8)%></font></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(4)).equals("0")){%>
		<tr> 
		  <td height="15">&nbsp;</td>
		  <td><font size="1">Office</font></td>
		  <td><strong><font size="1"><%=(String)vReqInfo.elementAt(10)%></font></strong></td>
		  <td><font size="1">Date Needed</font></td>
		  <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></font></strong></td>
		</tr>
	<%}else{%>
		<tr> 
		  <td height="15">&nbsp;</td>
		  <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</font></td>
		  <td><strong><font size="1"><%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></font></strong></td>
		  <td><font size="1">Date Needed</font></td>
		  <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></font></strong></td>
		</tr>
    <%}// if(((String)vReqInfo.elementAt(3)).equals(...%>
  </table>
<%}%>
  <%if(vReqItems != null){%>
  <table width="100%" border="0" class="thinborder" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	<tr>
    <td  height="15" colspan="6" class="thinborder"><div align="center"><strong>LIST OF PO ITEMS</strong></div></td>
	</tr>	    
    <tr> 
      <td width="6%" height="15" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/ITEM 
          DESCRIPTION </strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%for(;iLoop < vReqItems.size() && iCountRows < 15;iLoop+=12,++iCountRows){%>
    <tr> 
      <td  height="15" class="thinborder"><div align="center"><%=(iLoop+12)/12%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+5)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+1)%>/<%=(String)vReqItems.elementAt(iLoop+2)%> <%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"(",")","")%> </div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborder"><div align="right">
	  <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%>&nbsp;</div></td> 
	  <%dTotalAmount += Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(((String)vReqItems.elementAt(iLoop+7)),",",""),"0"));%>
    </tr>
    <%}for(;iCountRows < 15;++iCountRows){%>
    <tr> 
      <td  height="15" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>      
    </tr>
    <%}%>
    <tr> 
      <td  height="15" colspan="4" class="thinborder">&nbsp;</td>
      <td class="thinborder"><div align="left"><strong>PAGE 
        AMOUNT : </strong></div></td>
      <td class="thinborder"><div align="right"><strong>
	  <%if(dTotalAmount > 0){%>
	  <%=CommonUtil.formatFloat(dTotalAmount,true)%>
	  <%}else{%>
	  &nbsp;
	  <%}%>
	  </strong>&nbsp;</div>
	  </td>
    </tr>
    <tr> 
      <td  height="15" colspan="4" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vReqItems.size()/12%></strong></div></td>
      <td  class="thinborder"><div align="left"><strong>TOTAL 
        AMOUNT : </strong></div></td>
      <td  class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></strong>&nbsp;</div></td>
    </tr>
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
    <tr> 
      <td width="42%" class="thinborder"><div align="center"><strong>SUPPLIER 
      NAME</strong></div></td>
      <td width="29%" class="thinborder"><div align="center"><strong>COST 
      NAME </strong></div></td>
      <td width="29%" height="15" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>     
	<%for(iLoop = 0;iLoop < vAddtlCost.size();iLoop+=5){%>     
    <tr> 
      <td height="15" class="thinborder">&nbsp;<%=vAddtlCost.elementAt(iLoop+2)%>
	  <%strTemp = "";
	  	strErrMsg = "";
	  for(;(iLoop+4+5) < vAddtlCost.size();){
	  		if(!((String)vAddtlCost.elementAt(iLoop+1)).equals((String)vAddtlCost.elementAt(iLoop+1+5)))
	  			break;
			strTemp += (String)vAddtlCost.elementAt(iLoop+3)+"<br>";
			strErrMsg += (String)vAddtlCost.elementAt(iLoop+4)+"<br>";
			iLoop+=5;
	    }%>
	  </td>
      <td class="thinborder">&nbsp;<%=strTemp+(String)vAddtlCost.elementAt(iLoop+3)%></td>
      <td class="thinborder"><div align="right">
	  <%if(WI.fillTextValue("print_pg").equals("2")){%>
	  &nbsp;
	  <%}else{%>
	  <%=strErrMsg+(String)vAddtlCost.elementAt(iLoop+4)%>
	  <%}%>
	  &nbsp;</div></td>
    </tr>
	<%}%>
  </table>
  <%}%>
  <br>
  <%if(strSchCode.startsWith("CPU")){%>
  <table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr> 
      <td height="55" colspan="2" align="right" valign="middle" style="font-size: 9px;"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="4%" height="27">&nbsp;</td>
            <td width="23%" valign="bottom" class="thinborderBottom"><div align="center"><font size="1"><strong><%=WI.formatName((String)vReqPO.elementAt(9), (String)vReqPO.elementAt(10),
							(String)vReqPO.elementAt(11), 7).toUpperCase()%></strong></font></div></td>
            <td width="5%">&nbsp;</td>
            <td width="4%">&nbsp;</td>
            <td width="29%" valign="bottom" class="thinborderBottom"><div align="center"><strong><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"VP for Finance",7)),"").toUpperCase()%></strong></strong></div>
              </div></td>
            <td width="4%">&nbsp;</td>
            <td width="3%">&nbsp;</td>
            <td width="24%" valign="bottom" class="thinborderBottom"><div align="center"> 
                <div align="center"> <strong> 
                  <%if (WI.fillTextValue("include_president").length() > 0){%>
                  <%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"University President",7)),"").toUpperCase()%> 
                  <%}%>
                  </strong></div>
              </div></td>
            <td width="4%">&nbsp;</td>
          </tr>
          <tr> 
            <td><div align="center"></div></td>
            <td valign="top"><div align="center"><font size="1">Purchasing Officer</font></div></td>
            <td><div align="center"></div></td>
            <td><div align="center"></div></td>
            <td valign="top"><div align="center"><font size="1">Vice President 
                for Finance &amp; Enterprises</font></div></td>
            <td><div align="center"></div></td>
            <td><div align="center"></div></td>
            <td valign="top"><div align="center"><font size="1"> 
                <%if (WI.fillTextValue("include_president").length() > 0){%>
                President 
                <%}%>
                </font></div></td>
            <td><div align="center"></div></td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td width="50%" height="70" align="right" valign="middle" style="font-size: 9px;"><div align="justify"><strong>Subject 
          to the following terms and conditions:<br>
          </strong>We hereby declare it to be known and accepted by us that in 
          case of failure, delay or defect in the delivery of the article(s) covered 
          by this order within the period specified in the letter of accreditation 
          shall give the University the right to cancel this order.</div></td>
      <td width="50%" align="center" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr valign="top"> 
            <td height="26" colspan="3"><div align="center"><strong><font size="1">I 
                hereby agree in full to the above terms and conditions</font></strong></div></td>
          </tr>
          <tr> 
            <td width="22%">&nbsp;</td>
            <td width="56%" class="thinborderBottom">&nbsp;</td>
            <td width="22%">&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td valign="bottom"><div align="center"><font size="1">SUPPLIER</font></div></td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td valign="top"><div align="center"><font size="1">(Signature over 
                Printed Name)</font></div></td>
            <td>&nbsp;</td>
          </tr>
        </table></td>
    </tr>
  </table>
  <%}// only for CPU%>
</body>
</html>
<%
dbOP.cleanUP();
%>
