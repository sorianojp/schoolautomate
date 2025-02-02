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
	if(strSchCode.startsWith("AUF")){%>
		<jsp:forward page="./purchase_request_print_AUF.jsp"/>
	<%return;}
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
	// use this poara dili na mag cge pangita pila ka elements sa vReqItems na vector
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
    <%if(strSchCode.startsWith("UI") || strSchCode.startsWith("UDMC")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="4"><div align="center">&nbsp;<br>
          <br>
          <br>
          <br>
          <br>
        </div></td>
    </tr>
	</table>
	<%}else if(strSchCode.startsWith("CLDH")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="11%" rowspan="3" align="center" valign="top"><div align="left"><img src="../../../images/logo/CLDH.gif" width="70" height="70" border="0">                </div></td>
        <td colspan="2" rowspan="3" valign="top"> <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
                <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br></td>
        <td height="25" colspan="2"><DIV align="center">
          <table width="98%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
            <tr>
              <td><div align="center"><strong><font size="+1">PURCHASE ORDER</font></strong></div></td>
            </tr>
          </table>
        </div></td>
      </tr>
      <tr>
        <td height="25"><div align="right">No.&nbsp;&nbsp;</div></td>
        <td height="25" valign="bottom" class="thinborderBottom"><span class="thinborderBottom"><strong><font size="1">&nbsp;&nbsp;<%=(String)vReqPO.elementAt(1)%></font></strong></span></td>
      </tr>
      <tr>
        <td width="14%" height="25"><div align="right">Date :&nbsp;&nbsp;</div></td>
        <td width="14%" valign="bottom" class="thinborderBottom"><strong><font size="1">&nbsp;&nbsp;<%=(String)vReqPO.elementAt(2)%></font></strong></td>
      </tr>
  </table>
<%}else if(strSchCode.startsWith("AUF")){%>
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
      
      <tr>
        <td>Requester: <u><%=(String)vReqInfo.elementAt(3)%></u></td>
        <td colspan="2" align="center">Expected time of delivery </td>
        <td height="20" align="right" valign="bottom">P.O. No :&nbsp;</td>
        <td valign="bottom" class="thinborderBottom"><strong><font size="1"><%=(String)vReqPO.elementAt(1)%></font></strong></td>
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
	<%}else{%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td align="center" width="27%"><div align="right">&nbsp; 
          <%if(strSchCode.startsWith("AUF")){%>
          <%}%>
        </div></td>
      <td height="25" colspan="2" width="46%"><div align="center"> <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
		  <br>
          <br>
          <font size="+1"><strong>PURCHASE ORDER</strong></font> </div></td>
      <td align="center" width="27%"><div align="right">&nbsp;</div></td>
    </tr>	
	</table>
    <%}%>
  
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
    <%
	if(((String)vReqInfo.elementAt(4)).equals("0")){%>
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
      <td width="29%"><div align="right"><font size="1">Page <%=iPageNumber%> of <%=iPageCount%>&nbsp;</font></div></td>
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
  <%}else if(strSchCode.startsWith("CLDH")){%>	
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" cal>
    <tr>
      <td width="1%" height="15">&nbsp;</td>
      <td width="59%">&nbsp;</td>
      <td width="40%">&nbsp;</td>
    </tr>        
    <tr>
      <td height="15">&nbsp;</td>
      <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
        <tr>
          <td width="19%" valign="top" class="thinborderLeft" height="16">To :</td>
		  <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
			 strTemp = (String) vSupplierInfo.elementAt(0);
			 }else{
			 strTemp = "";
			 }
		  %>		
          <td width="81%" rowspan="2" valign="top" class="thinborderBottom" height="18"><font size="1"><strong><%=WI.getStrValue(strTemp,"")%>&nbsp;</strong></font></td>
        </tr>
        
        <tr class="thinborderBottom">
          <td valign="top" class="thinborder" height="18">&nbsp;</td>
          </tr>
        <tr>
          <td valign="top" class="thinborderLeft" height="14">Address :</td>
		  <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
			 strTemp = (String) vSupplierInfo.elementAt(1);
			 }else{
			 strTemp = "";
			 }
		  %>		
          <td rowspan="6" valign="top" class="thinborderBottom" ><font size="1"><strong><%=WI.getStrValue(strTemp,"")%>&nbsp;</strong></font></td>
        </tr>
        <tr class="thinborderBottom">
          <td valign="top" class="thinborderLeft" height="14">&nbsp;</td>
          </tr>
        <tr class="thinborderBottom">
          <td valign="top" class="thinborderLeft" height="14">&nbsp;</td>
          </tr>
        <tr class="thinborderBottom">
          <td valign="top" class="thinborderLeft" height="14">&nbsp;</td>
          </tr>
        <tr class="thinborderBottom">
          <td valign="top" class="thinborderLeft" height="14">&nbsp;</td>
          </tr>
        <tr class="thinborderBottom">
          <td valign="top" class="thinborder" height="14">&nbsp;</td>
          </tr>
      </table></td>
      <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
        <tr>
          <td width="1%" height="16"></td>
          <td width="45%" class="thinborderLeft"><div align="center"><font size="2">Contact Person</font></div></td>
          <td width="23%" rowspan="2" class="thinborder" height="28"><div align="right"><strong>Payment&nbsp;<br>
  Terms&nbsp;</strong></div></td>
		  <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
			 strTemp = (String) vSupplierInfo.elementAt(4);
			 }else{
			 strTemp = "0";
			 }
			 strTemp = WI.getStrValue(strTemp,"6");
		  %>			
          <td width="31%" rowspan="2" class="thinborder">&nbsp;<%=WI.getStrValue(astrTerm[Integer.parseInt(strTemp)],"")%></td>
        </tr>
        <tr>
          <td height="18">&nbsp;</td>
          <td class="thinborder">&nbsp;</td>
          </tr>
        <tr>
          <td height="14">&nbsp;</td>
		  <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
			 strTemp = (String) vSupplierInfo.elementAt(5);
			 }else{
			 strTemp = "";
			 }
		  %>			  
          <td rowspan="4" valign="top" class="thinborder"><font size="1"><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%></strong></font></td>
          <td width="23%" rowspan="2" class="thinborder"><div align="right"><strong>Payment&nbsp;<br>
  Due Date&nbsp;</strong></div></td>
          <td width="31%" rowspan="2" class="thinborder">&nbsp;</td>
        </tr>
        <tr valign="top">
          <td height="14">&nbsp;</td>
		  <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
			 strTemp = (String) vSupplierInfo.elementAt(5);
			 }else{
			 strTemp = "";
			 }
		  %>			
          </tr>
        
        
        <tr>
          <td height="14">&nbsp;</td>
          <td rowspan="2" class="thinborder"><div align="right"><strong>Delivery&nbsp;<br>
  Date&nbsp;</strong></div></td>
          <td rowspan="2" class="thinborder">&nbsp;</td>
        </tr>
        <tr valign="top">
          <td height="14">&nbsp;</td>
          </tr>
        
        <tr valign="top">
          <td height="14">&nbsp;</td>
          <td class="thinborderLeft">&nbsp;Supplier's Code</td>
          <td rowspan="2" class="thinborder"><div align="right"><strong>Purchase&nbsp;<br>
  Req. No.&nbsp;</strong></div></td>
          <td rowspan="2" class="thinborder"><strong><font size="1">&nbsp;<%=(String)vReqInfo.elementAt(13)%></font></strong></td>
        </tr>
        <tr valign="top">
          <td height="14">&nbsp;</td>
		  <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
			 strTemp = (String) vSupplierInfo.elementAt(6);
			 }else{
			 strTemp = "";
			 }
		  %>			  
          <td class="thinborder"><font size="1"><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%></strong></font></td>
        </tr>
        
      </table>
	  </td>
      </tr>
	</table>	
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">  	
    <tr> 
      <td height="15">&nbsp;</td>
      <td colspan="3"><TABLE cellSpacing="0" cellPadding="0" width="100%" border="0">
        <TBODY>
          <TR>
            <TD height="40" style="font-size:9px">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This is to authorize you   to deliver to Central Luzon Doctors&rsquo; Hospital  Educational Institution, Inc. 
              the items   enumerated below at the price and terms and conditions indicated in this   Purchase order. Advise us without delay if you can not comply with the price, terms   and conditions stipulated herein.</TD>
          </TR>
        </TBODY>
      </TABLE></td>
    </tr>
  </table>
  <%}else if(strSchCode.startsWith("UDMC")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" cal>
    <tr>
      <td height="15" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td colspan="2" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td colspan="2" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td width="10%" class="NoBorder">&nbsp;</td>
      <td width="11%" class="NoBorder"><strong><%=(String)vReqPO.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="15" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td colspan="2" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td colspan="2" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td colspan="2" class="NoBorder">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="15" class="NoBorder">&nbsp;</td>
      <td width="3%" class="NoBorder"><%if(false){%>TO:<%}%></td>
	  <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
		 strTemp = (String) vSupplierInfo.elementAt(0);
		 }else{
		 strTemp = "";
		 }
	  %>	  
      <td colspan="2" class="NoBorder"><font size="1"><strong>&nbsp;<%=WI.getStrValue(strTemp,"")%>&nbsp;</strong></font></td>
      <td width="10%" class="NoBorder"><%if(false){%>Date :<%}%></td>
      <td colspan="2" class="NoBorder">&nbsp;<strong><font size="1"><%=(String)vReqPO.elementAt(2)%></font></strong></td>
      <td width="11%" class="NoBorder"><%if(false){%>Terms: <%}%></td>
      <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
	     strTemp = (String) vSupplierInfo.elementAt(4);
		 }else{
		 strTemp = "0";
		 }
		 strTemp = WI.getStrValue(strTemp,"6");
	  %>	  
      <td colspan="2" class="NoBorder"><span class="thinborder">&nbsp;<%=WI.getStrValue(astrTerm[Integer.parseInt(strTemp)],"")%></span></td>
    </tr>        
    <tr>
      <td height="20" class="NoBorder">&nbsp;</td>
      <td colspan="2" class="NoBorder"><%if(false){%>For use:<%}%> </td>
      <td width="28%" class="NoBorder"><strong><font size="1">&nbsp;<%=(String)vReqInfo.elementAt(6)%></font></strong></td>
      <td colspan="2" class="NoBorder"><%if(false){%>Req'n No. : <%}%></td>
      <td width="17%" class="NoBorder"><strong><font size="1">&nbsp;<%=(String)vReqInfo.elementAt(13)%></font></strong></td>
      <td class="NoBorder">&nbsp;</td>
      <td colspan="2" class="NoBorder">&nbsp;</td>
    </tr>
    <tr>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" colspan="2" valign="top" class="NoBorder">&nbsp;</td>
    </tr>
    <tr>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" colspan="2" valign="top" class="NoBorder">&nbsp;</td>
    </tr>
    <tr>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td width="4%" height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td width="4%" height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" valign="top" class="NoBorder">&nbsp;</td>
      <td height="15" colspan="2" valign="top" class="NoBorder">&nbsp;</td>
    </tr>
  </table>	 
  <%}else if(strSchCode.startsWith("AUF")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" cal>
    <tr>
      <td height="6" valign="top" class="NoBorder"></td>
    </tr>
  </table>	 
<%}else if(strSchCode.startsWith("DBTC")){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="15">&nbsp;</td>
      <td width="19%"><font>PO No.</font></td>
      <td width="37%"><strong><font><%=(String)vReqPO.elementAt(1)%></font></strong></td>
      <td width="13%"><font>Requisition No</font></td>
      <td width="29%"><strong><font><%=(String)vReqInfo.elementAt(13)%></font></strong></td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td><font>Supplier </font></td>
      <td style="font-weight:bold;">
	  <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
	     strTemp = (String) vSupplierInfo.elementAt(0);
		 }else{
		 	strTemp = "";
		 }
	  %><%=strTemp%></td>
      <td><font>Request Type</font></td>
      <td><font><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(2))]%></strong></font></td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td><font>PO Date</font></td>
      <td><strong><font><%=(String)vReqPO.elementAt(2)%></font></strong></td>
      <td><font>Requisition Date</font></td>
      <td><strong><font><%=(String)vReqInfo.elementAt(8)%></font></strong></td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td><font>Dept/Office</font></td>
      <td><strong><font><%=WI.getStrValue((String)vReqInfo.elementAt(9), "","/","")+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></font></strong></td>
      <td><font>Request By</font></td>
      <td><strong><font><%=(String)vReqInfo.elementAt(3)%></font></strong></td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td><font>Purpose/Job</font></td>
      <td><strong><font><%=(String)vReqInfo.elementAt(6)%></font></strong></td>
      <td><font>Terms Of Payment </font></td>
      <td><font>
	  <%=WI.getStrValue(vReqPO.elementAt(13), "Not set")%></font></td>
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
        <%}%>	  </td>
    </tr>	
  </table>
<%}else{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="15">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td style="font-size:9px;">Name of Supplier </td>
      <td colspan="3" style="font-size:9px; font-weight:bold">
	  <%if (vSupplierInfo != null && vSupplierInfo.size() >0 ){
	     strTemp = (String) vSupplierInfo.elementAt(0);
		 }else{
		 	strTemp = "";
		 }
	  %><%=strTemp%>
	  </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td><font size="1">PO No.</font></td>
      <td><strong><font size="1"><%=(String)vReqPO.elementAt(1)%></font></strong></td>
      <td><font size="1">PO Date</font></td>
      <td><strong><font size="1"><%=(String)vReqPO.elementAt(2)%></font></strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td><font size="1">Requisition No.</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(13)%></font></strong></td>
      <td><font size="1">Requested By</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(3)%></font></strong></td>
    </tr>
    <tr> 
      <td width="2%" height="20">&nbsp;</td>
      <td width="19%"><font size="1">Request Type</font></td>
      <td width="37%"><font size="1"><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(2))]%></strong></font></td>
      <td width="13%"><font size="1">Purpose/Job</font></td>
      <td width="29%"><strong><font size="1"><%=(String)vReqInfo.elementAt(6)%></font></strong></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td><font size="1">Requisition Status</font></td>
      <td><strong><font size="1"><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(11))]%></font></strong></td>
      <td><font size="1">Requisition Date</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(8)%></font></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(4)).equals("0")){%>
		<tr> 
		  <td height="20">&nbsp;</td>
		  <td><font size="1">Office</font></td>
		  <td><strong><font size="1"><%=(String)vReqInfo.elementAt(10)%></font></strong></td>
		  <td><font size="1">Date Needed</font></td>
		  <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></font></strong></td>
		</tr>
	<%}else{%>
		<tr> 
		  <td height="20">&nbsp;</td>
		  <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</font></td>
		  <td><strong><font size="1"><%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></font></strong></td>
		  <td><font size="1">Date Needed</font></td>
		  <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></font></strong></td>
		</tr>
    <%}// if(((String)vReqInfo.elementAt(3)).equals(...%>
	<tr> 
      <td height="20">&nbsp;</td>
      <td colspan="4" style="font-weight:bold; font-size:9px;">Please deliver the folling items to Tsuneishi Technical Services (Phils), Inc.</td>
    </tr>	
  </table>
<%}%>
  <%if(vReqItems != null){%>
  <%if(strSchCode.startsWith("CLDH")){%>
<table width="100%" border="0" class="thinborder" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	<tr>
    <td  height="15" colspan="6" class="thinborder"><div align="center"><strong>LIST OF PO ITEMS</strong></div></td>
	</tr>	    
    <tr> 
      <td width="6%" height="15" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>            
      <td class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/ITEM 
          DESCRIPTION </strong></div></td>
	  <td width="7%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>		  
	  <td width="7%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>		 
      <td width="14%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
	
    <%		
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=iItems,++iCountRows){	
	%>
    <tr> 
      <td  height="15" class="thinborder"><div align="center"><%=(iLoop+iItems)/iItems%></div></td>      
      <td class="thinborder"><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+1)%>/<%=(String)vReqItems.elementAt(iLoop+2)%> <%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"(",")","")%> </div></td>
	  <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+5)%></div></td>      	  
	  <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+6)%></div></td>	  
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborder"><div align="right">
	  <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%>&nbsp;</div></td> 
	  <%dPageAmount += Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(((String)vReqItems.elementAt(iLoop+7)),",",""),"0"));%>
    </tr>
    <%}for(;iCountRows < iNumRows;++iCountRows){%>
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
	  <%if(dPageAmount > 0){
	  	dTotalAmount += dPageAmount;
	  %>
	  <%=CommonUtil.formatFloat(dPageAmount,true)%>
	  <%}else{%>
	  &nbsp;
	  <%}%>
	  </strong>&nbsp;</div>
	  </td>
    </tr>
  </table>  
  <%}else if(strSchCode.startsWith("UDMC")){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
		    
    <tr> 
      <td width="14%" height="15" class="NoBorder"><div align="center"></div></td>            
      <td width="44%" class="NoBorder"><div align="center"></div></td>
	  <td width="14%" class="NoBorder"><div align="right"><strong>REG PRI&nbsp; </strong></div></td>		 
      <td width="14%" class="NoBorder"><div align="right"><strong>DISC PR&nbsp; </strong></div></td>
      <td width="14%" class="NoBorder"><div align="right"><strong>TOTAL AMT &nbsp;&nbsp;</strong></div></td>
    </tr>
	
    <%		
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=iItems,++iCountRows){	
	%>
    <tr> 
      <td  height="19" class="NoBorder">&nbsp;<%=(String)vReqItems.elementAt(iLoop+5)%>&nbsp;<%=(String)vReqItems.elementAt(iLoop+6)%>&nbsp;</td>      
      <td class="NoBorder"><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+1)%>/<%=(String)vReqItems.elementAt(iLoop+2)%> <%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"(",")","")%> </div></td>
	  <td class="NoBorder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+11),true),"&nbsp;")%>&nbsp;</div></td>	  
      <td class="NoBorder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%>&nbsp;</div></td>
      <td class="NoBorder"><div align="right">
	  <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
	  <%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
	  <%}%>&nbsp;</div></td> 
	  <%dPageAmount += Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(((String)vReqItems.elementAt(iLoop+7)),",",""),"0"));%>
    </tr>
	<%}%>
	<tr> 
      <td  height="15" colspan="3" class="NoBorder">&nbsp;</td>
      <td class="NoBorder"><div align="left"><strong>PAGE 
      AMOUNT : </strong></div></td>
      <td class="NoBorder"><div align="right"><strong>
	  <%if(dPageAmount > 0){
	  	dTotalAmount += dPageAmount;
	  %>
	  <%=CommonUtil.formatFloat(dPageAmount,true)%>
	  <%}else{%>
	  &nbsp;
	  <%}%>
	  </strong>&nbsp;</div>	  </td>
    </tr>	
    <%for(;iCountRows < iNumRows;++iCountRows){%>
    <tr> 
      <td  height="15" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>      
    </tr>
    <%}%>    
  </table>   
	<%}else if(strSchCode.startsWith("AUF")){%>	
	<table width="100%" border="0" class="thinborderALL" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
		    
    <tr> 
      <td width="11%" height="15" class="thinborderBottomRight"><div align="center"><strong>QTY</strong></div></td>
      <td width="45%" class="thinborderBottomRight"><div align="center"><strong>ITEM/PARTICULARS/ITEM DESCRIPTION </strong></div></td>
      <td width="13%" class="thinborderBottomRight"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="13%" class="thinborderBottomRight"><div align="center"><strong>TOTAL PRICE </strong></div></td>
      <td width="18%" align="center" class="thinborderBottom"><strong>Supplier/s</strong></td>
    </tr>
	
    <%		
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=iItems,++iCountRows){	
	%>
    <tr> 
      <td height="15" class="NoBorder"><div align="right"><%=(String)vReqItems.elementAt(iLoop+5)%><%=(String)vReqItems.elementAt(iLoop+6)%>&nbsp;</div></td>
      <td class="NoBorder"><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+1)%>/<%=(String)vReqItems.elementAt(iLoop+2)%> <%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"(",")","")%> </div></td>
      <td class="NoBorder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%>&nbsp;</div></td>
      <td class="NoBorder"><div align="right">
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
      <td height="15" class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>      
      <td class="NoBorder">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td  height="15" colspan="2" class="NoBorder">&nbsp;</td>
      <td class="NoBorder"><div align="left"><strong>PAGE AMOUNT : </strong></div></td>
      <td class="NoBorder"><div align="right"><strong>
	  <%if(dPageAmount > 0){
	  	dTotalAmount += dPageAmount;
	  %>
	  <%=CommonUtil.formatFloat(dPageAmount,true)%>
	  <%}else{%>
	  &nbsp;
	  <%}%>
	  </strong>&nbsp;</div>	  </td>
      <td class="NoBorder">&nbsp;</td>
    </tr>
  </table>	
  <%}else{%>
  <br>
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
	
    <%		
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=iItems,++iCountRows){	
	%>
    <tr> 
      <td  height="15" class="thinborder"><div align="center"><%=(iLoop+iItems)/iItems%></div></td>
      <td class="thinborder"><div align="right"><%=(String)vReqItems.elementAt(iLoop+5)%>&nbsp;</div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=(String)vReqItems.elementAt(iLoop+1)%>/<%=(String)vReqItems.elementAt(iLoop+2)%> <%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"(",")","")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborder"><div align="right">
	  <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%>&nbsp;</div></td> 
	  <%dPageAmount += Double.parseDouble(WI.getStrValue(ConversionTable.replaceString(((String)vReqItems.elementAt(iLoop+7)),",",""),"0"));%>
    </tr>
    <%}
	boolean bolIsNFPrinted = false;
	for(;iCountRows < iNumRows;++iCountRows){%>
    <tr> 
      <td  height="15" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="center" style="font-size:10px;"><%if(!bolIsNFPrinted){bolIsNFPrinted=true;%> ************* NOTHING FOLLOWS ************* <%}else{%>&nbsp;<%}%></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>      
    </tr>
    <%}%>
<!--
    <tr> 
      <td  height="15" colspan="4" class="thinborder" style="font-weight:bold" align="center"><%=new ConversionTable().convertAmoutToFigure(dPageAmount, "","Centavos").toUpperCase()%></td>
      <td class="thinborder"><div align="left"><strong>PAGE 
        AMOUNT : </strong></div></td>
      <td class="thinborder"><div align="right"><strong>
	  <%if(dPageAmount > 0){
	  	dTotalAmount += dPageAmount;
	  %>
	  <%=CommonUtil.formatFloat(dPageAmount,true)%>
	  <%}else{%>
	  &nbsp;
	  <%}%>
	  </strong>&nbsp;</div>
	  </td>
    </tr>
-->
  </table>
  <%}// end if not cldh%>
	<%if (iLoop < vReqItems.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }}}%>
   <%if(!strSchCode.startsWith("UDMC")){%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
      <tr> 
      <td  height="15" colspan="4" class="thinborder" style="font-weight:bold" align="center"><%=new ConversionTable().convertAmoutToFigure(dPageAmount, "","Centavos").toUpperCase()%></td>
      <td width="14%"  class="thinborder"><div align="left"><strong>TOTAL AMOUNT : </strong></div></td>
      <td width="14%"  class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></strong>&nbsp;</div></td>
    </tr>
  </table>
  <%}%>
  <%if(vAddtlCost != null && vAddtlCost.size() > 2){%>
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
      <td width="29%" class="thinborder"><div align="right"> 
          <%if(WI.fillTextValue("print_pg").equals("2")){%>
          &nbsp; 
          <%}else{%>
          <%=strErrMsg+(String)vAddtlCost.elementAt(iLoop+4)%> 
          <%
		  dGrandTotal += Double.parseDouble(ConversionTable.replaceString((String)vAddtlCost.elementAt(iLoop+4),",",""));
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
  <%if(strSchCode.startsWith("CLDH")){%>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">	
    <tr> 
      <td height="55" colspan="2" align="right" valign="middle">
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
        <tr>
          <td height="12" class="thinborderLeft">Prepared by: </td>
          <td class="thinborderLeft">Checked by:</td>
          <td class="thinborderLeft">Approved by:</td>
          <%if (WI.fillTextValue("include_president").length() > 0){%>
		  <td class="thinborderLeft"><div align="center"><font size="1">President</font></div></td>
		  <%}%>		  
          <td class="thinborderLeft">Supplier's copy received by:</td>
          <td class="thinborderLeft">Accounting copy received by:</td>
        </tr>
        <tr>
          <td height="21" class="thinborderLeft">&nbsp;</td>
          <td class="thinborderLeft">&nbsp;</td>
          <td class="thinborderLeft">&nbsp;</td>
		  <%if (WI.fillTextValue("include_president").length() > 0){%>
          <td class="thinborder"><div align="center"><strong>            
            <%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"University President",7)),"").toUpperCase()%>            
          </strong></div></td>
		  <%}%>
          <td class="thinborder">&nbsp;</td>
          <td class="thinborder">&nbsp;</td>		  
        </tr>
        <tr>
		<%if (WI.fillTextValue("include_president").length() > 0)
		  	iWidth = 15;
		  else
		  	iWidth = 18;
		%>		
          <td width="<%=iWidth%>%" height="15" class="thinborder">&nbsp;</td>
		<%if (WI.fillTextValue("include_president").length() > 0)
		  	iWidth = 16;
		  else
		  	iWidth = 18;
		%>		  
          <td width="<%=iWidth%>%" class="thinborder">&nbsp;</td>
		<%if (WI.fillTextValue("include_president").length() > 0)
		  	iWidth = 14;
		  else
		  	iWidth = 19;
		%>          
		  <td width="<%=iWidth%>%" class="thinborder">&nbsp;</td>
		  <%if (WI.fillTextValue("include_president").length() > 0){
		  iWidth = 18;
		  %>
          <td width="<%=iWidth%>%" valign="bottom" class="thinborder" style="font-size: 9px;">&nbsp;</td>
		  <%}%>
		<%if (WI.fillTextValue("include_president").length() > 0)
		  	iWidth = 16;
		  else
		  	iWidth = 22;
		%>		  
          <td width="<%=iWidth%>%" valign="bottom" class="thinborder" style="font-size: 9px;"><div align="center">Signature over Printed Name </div></td>
		<%if (WI.fillTextValue("include_president").length() > 0)
		  	iWidth = 16;
		  else
		  	iWidth = 23;
		%>		  
          <td width="<%=iWidth%>%" valign="bottom" class="thinborder" style="font-size: 9px;"><div align="center">Signature over printed name</div></td>
        </tr>
      </table></td>
    </tr>
    <tr> 
      <td height="55" colspan="2" align="right" valign="middle">
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
        
        <tr>
          <td width="77%" height="21" rowspan="2" class="thinborder">Central Luzon Doctors&rsquo; Hospital  Educational Institution, Inc. reserves the   right to cancel this Purchase Order if item(s) ordered is/are note delivered on   due date; if there are suppliers' material misrepresentation; substandard   quality of products. Indicate the Purchase Order No.and Date in your invoice to   facilitate the processing of payment. <STRONG>Submit the <U>original</U> copy of   your invoice together with the original copy of this PO for processing of   payment. </STRONG><BR></td>
          <td width="23%" height="14" class="thinborder"><strong>&nbsp;<font  size="3">P O No</font></strong></td>
          </tr>
        <tr>
          <td class="thinborder"><div align="center"><strong><font size="1"><%=(String)vReqPO.elementAt(1)%></font></strong></div></td>
        </tr>
      </table>
	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tr>
			<td class="NoBorder"><div align="center">Original (white): Supplier; Duplicate (yellow): Accts. Dept; Triplicate (green): Purchasing Dept. file</div></td>
		  </tr>
	   </table>
	
	  </td>
    </tr>			
  </table>
  <%}else if(strSchCode.startsWith("AUF")){%>  
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		
		<tr>
		  <td colspan="3" class="NoBorder">&nbsp;</td>
		  <td width="2%" valign="top" class="NoBorder">&nbsp;</td>
		  <td width="23%" align="right" class="NoBorder">&nbsp;</td>
		  <td valign="top" class="NoBorder">&nbsp;</td>
		  <td class="NoBorder">&nbsp;</td>
		  <td class="NoBorder">&nbsp;</td>
	  </tr>
		<tr>
		  <td width="31%" valign="top" class="NoBorder">(1)&nbsp;Prepared by: </td>
		  <td width="2%" class="NoBorder">&nbsp;</td>
		  <td width="15%" class="NoBorder">&nbsp;</td>
		  <td valign="top" class="NoBorder">&nbsp;</td>
		  <td colspan="2" align="center" class="NoBorder">(2)&nbsp;Verified by: </td>
		  <td class="NoBorder">&nbsp;</td>
		  <td class="NoBorder">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="23" align="center" valign="bottom" class="thinborderBottom"><font size="1"><strong>
		  <%//=WI.formatName((String)vReqPO.elementAt(9), (String)vReqPO.elementAt(10),(String)vReqPO.elementAt(11), 7).toUpperCase()%>&nbsp;</strong></font>
		  <%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Purchasing Officer",7)),"").toUpperCase()%>
		  </td>
		  <td>&nbsp;</td>
		  <td valign="bottom" class="thinborderBottom">&nbsp;</td>
		  <td valign="top">&nbsp;</td>
		  <td colspan="2" valign="bottom" class="thinborderBottom" align="center">&nbsp;<%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Budget Officer",7)),"").toUpperCase()%></td>
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
		  <td colspan="4" align="center" class="NoBorder">(4) / &nbsp;&nbsp;/ Approved &nbsp;&nbsp;/ &nbsp;/ Disapproved </td>
	  </tr>
		<tr>
		  <td height="23" valign="bottom" class="thinborderBottom" align="center">&nbsp;<%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"VP for Finance",7)),"").toUpperCase()%></td>
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
				March 2, 2009 - Rev. 01
			</div>
			</td>
			<td width="10%" valign="top" class="NoBorder">&nbsp;</td>
			<td width="2%" class="NoBorder">&nbsp;</td>
			<td width="15%" class="NoBorder">&nbsp;</td>
		</tr>
	</table>
	<%}%>

  <%if(!strSchCode.startsWith("CLDH") && !strSchCode.startsWith("UDMC") 
	  && !strSchCode.startsWith("AUF") && !strSchCode.startsWith("UI")){
  %>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr align="center" valign="bottom" style="font-weight:bold"> 
			<td width="2%" height="27">&nbsp;</td>
			<td width="18%" class="thinborderBottom" style="font-size:9px">&nbsp;<%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Purchasing Officer",7)),"Ma. Niña L. Canicon").toUpperCase()%></td>
			<td width="2%">&nbsp;</td>
			<td width="18%" class="thinborderBottom" style="font-size:9px">&nbsp;<%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Admin Manager",7)),"Dale B. Bontilao").toUpperCase()%></strong></td>
			<td width="2%">&nbsp;</td>
<%if(WI.fillTextValue("is_gm_in_po").length() > 0) {%>
			<td width="18%" class="thinborderBottom" style="font-size:9px">&nbsp;<%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"General Manager",7)),"").toUpperCase()%></td>
			<td width="2%">&nbsp;</td>
<%}else{%>
			<td width="18%" class="thinborderBottom" style="font-size:9px">&nbsp;<%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"President",7)),"").toUpperCase()%></td>
			<td width="2%">&nbsp;</td>
<%}%>
		</tr>
		<tr align="center"> 
			<td></td>
			<td valign="top"><font size="1">Purchasing Officer</font></td>
			<td></td>
			<td valign="top"><font size="1">Admin Manager </font></td>
			<td></td>
<%if(WI.fillTextValue("is_gm_in_po").length() > 0) {%>
			<td valign="top"><font size="1">General Manager </font></td>
			<td></td>
<%}else{%>
			<td valign="top"><font size="1">President</font></td>
			<td></td>
<%}%>
		</tr>
	</table> 
  <% } // if(!strSchCode.startsWith("CLDH"))%>

<%}// para dili mag null pointer%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
