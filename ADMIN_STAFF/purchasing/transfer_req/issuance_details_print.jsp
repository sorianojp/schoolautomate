<%@ page language="java" import="utility.*,inventory.InventoryMaintenance,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode ="";
		
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
	font-size: 10px;	
}
TABLE.thinborderALL {
    border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
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
TD.thinborderBottomRight {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderRight {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.NoBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
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
	
	boolean bolUPHD = false;
	boolean bolGetReqInfo = false;
	if(strSchCode.startsWith("UPH")){
		strTemp = SchoolInformation.getInfo5(dbOP, false, false);
		if(strTemp == null){
			bolUPHD = true;
			bolGetReqInfo = true;//this will get more info for issuance info.
		}
	}
		String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};
 	InventoryMaintenance invMaint = new InventoryMaintenance();	

	Vector vIssuanceInfo = null;
	Vector vRetResult    = null;
	Vector vPOInfo       = null; int iIndexOf = 0; String strInvoiceNumber = null;

 	int iCount = 1;
	int iSearchResult = 0;
	int iCountRows = 0;
	int iNumRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	vRetResult = invMaint.getIssuanceInfo(dbOP,request, WI.fillTextValue("issuance_index"), false, bolGetReqInfo);
 	if(vRetResult == null)
		strErrMsg = invMaint.getErrMsg();
	else{
		iSearchResult = invMaint.getSearchCount();
		vIssuanceInfo = (Vector) vRetResult.elementAt(0);
		//I have to get here po information.
		vPOInfo = invMaint.getPOInfo(dbOP, (String)vIssuanceInfo.elementAt(4), request);
	}
	if(vPOInfo == null)
		vPOInfo = new Vector();
	else if(vPOInfo.size() > 0) 
		strInvoiceNumber = (String)vPOInfo.remove(0);

%>	
<form name="form_" >
  <%if(vIssuanceInfo != null && vIssuanceInfo.size() > 1){
  
 
if(bolIsAUF) {%>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="24%" rowspan="4" align="right" valign="top"><img src="../../../images/logo/AUF_PAMPANGA.gif" width="70" height="70" border="0"></td>
        <td colspan="2" align="center" valign="top" style="font-size:14px;">Angeles University Foundation</td>
        <td height="18" colspan="2">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2" align="center" valign="top" style="font-size:9px;">Angeles City, Phlippines<br>
		<font style="font-size:12px; font-weight:bold">
		PURCHASING AND SUPPLY OFFICE		</font>		</td>
        <td height="18" align="right" valign="bottom">&nbsp;</td>
        <td height="18" valign="bottom">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2" rowspan="2" align="center"><strong><font size="+1">RECEIVING AND ISSUANCE FORM</font></strong></td>
        <td height="25" align="right" valign="bottom">R.I. No. :</td>
        <td height="25" valign="bottom" class="thinborderBottom"><strong><%=(String)vIssuanceInfo.elementAt(0)%></strong></td>
      </tr>
      <tr>
        <td width="12%" height="25" align="right" valign="bottom">&nbsp;</td>
        <td width="14%" valign="bottom">&nbsp;</td>
      </tr>
  </table>  
<%}else if(bolUPHD){%>  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr> 
      <td align="center" width="18%"><div align="right">&nbsp;
	  </div></td>
      <td width="64%" height="25" align="center"><div align="left">&nbsp;</div>
        <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br> 
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
		<strong><font size="+1"><br>
		MATERIAL ISSUANCE</font></strong><br> 
		<br> </td>
      <td width="18%" align="center">&nbsp;</td>
     </tr>
  </table>
  
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="17">&nbsp;</td>
      <td class="NoBorder"><strong>ITEM SOURCE</strong></td>
      <td class="NoBorder">&nbsp;</td>
      <td width="15%" class="NoBorder">&nbsp;</td>
      <td width="34%" class="NoBorder">&nbsp;</td>
    </tr>
		<%if(WI.getStrValue(vIssuanceInfo.elementAt(5)).equals("0")){%> 
    <tr>
      <td height="17">&nbsp;</td>
      <td class="NoBorder">Office </td>
      <td class="NoBorder"><strong><%=(String)vIssuanceInfo.elementAt(8)%></strong></td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
    </tr>
		<%}else{%>
    <tr>
      <td height="17">&nbsp;</td>
      <td class="NoBorder"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</td>
      <td class="NoBorder"><strong><%=(String)vIssuanceInfo.elementAt(7)+"/"+WI.getStrValue((String)vIssuanceInfo.elementAt(8),"All")%></strong></td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
    </tr>
		<%}%>
    <tr>
      <td height="17">&nbsp;</td>
      <td colspan="4" class="NoBorder"><hr size="1"></td>
    </tr>
    
    <tr> 
      <td width="2%" height="17">&nbsp;</td>
      <td width="18%" class="NoBorder">Purpose/Job</td>
      <td width="31%" class="NoBorder"><strong><%=(String)vIssuanceInfo.elementAt(13)%></strong></td>
      <td class="NoBorder">Requested By</td>
      <td class="NoBorder"><strong><%=(String)vIssuanceInfo.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td height="17">&nbsp;</td>
      <td class="NoBorder">Requisition Status</td>
      <td class="NoBorder"><strong><%=astrReqStatus[Integer.parseInt((String)vIssuanceInfo.elementAt(16))]%></strong></td>
      <td class="NoBorder">Requisition Date</td>
      <td class="NoBorder"><strong><%=(String)vIssuanceInfo.elementAt(15)%></strong></td>
    </tr>
    <%if(WI.getStrValue(vIssuanceInfo.elementAt(9)).equals("0")){%> 
    <tr> 
      <td height="17">&nbsp;</td>
      <td class="NoBorder">Office</td>
      <td class="NoBorder"><strong><%=(String)vIssuanceInfo.elementAt(12)%></strong></td>
      <td class="NoBorder">Date Needed</td>
      <td class="NoBorder"><strong><%=WI.getStrValue((String)vIssuanceInfo.elementAt(14),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="17">&nbsp;</td>
      <td class="NoBorder"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</td>
      <td class="NoBorder"><strong><%=(String)vIssuanceInfo.elementAt(11)+"/"+WI.getStrValue((String)vIssuanceInfo.elementAt(12),"All")%></strong></td>
      <td class="NoBorder">Date Needed</td>
      <td class="NoBorder"><strong><%=WI.getStrValue((String)vIssuanceInfo.elementAt(14),"&nbsp;")%></strong></td>
    </tr>
    <%} // end if  (((String)vIssuanceInfo.elementAt(3)).equals("0"))%>
  </table>
<%}

if(!bolUPHD){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="12%">Requester</td>
      <td width="27%" class="thinborderBottom"><%=WI.getStrValue(vIssuanceInfo.elementAt(3), "&nbsp;")%></td>
      <td width="4%">P.O# </td>
      <td width="19%" class="thinborderBottom">&nbsp;<%=WI.getStrValue(vIssuanceInfo.elementAt(4), "&nbsp;")%></td>
      <td width="18%" align="right">Date of invoice: </td>
      <td width="17%" class="thinborderBottom"><strong>&nbsp;<%=(String)vIssuanceInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%
 } 
 if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    
    <tr>
      <td width="46%" height="25" align="center" class="thinborderBottomRight"><strong>Name &amp; Description of Item/s </strong></td>
      <td width="13%" align="center" class="thinborderBottomRight"><strong>Quantity</strong></td>
      <td width="13%" align="center" class="thinborderBottomRight"><strong>Unit Cost </strong></td>
      <td width="14%" align="center" class="thinborderBottomRight"><strong>Total Cost </strong></td>
      <td width="14%" align="center" class="thinborderBottom"><strong>Invoice No </strong></td>
    </tr>
    <%iCount = 1; double dUnitCost = 0d;
		for(int i = 1;i < vRetResult.size();i+=6,++iCount, iCountRows++){
			iIndexOf = vPOInfo.indexOf((String)vRetResult.elementAt(i + 5));
			if(iIndexOf > -1) {
				dUnitCost = ((Double)vPOInfo.elementAt(iIndexOf + 1)).doubleValue();
			}
			else
				dUnitCost = 0d;
		%>	
    <tr>
      <td height="22" class="thinborderRight">&nbsp;<%=(String)vRetResult.elementAt(i+1)%><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"(",")","")%></td>
      <td align="right" class="thinborderRight"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2),false)%>&nbsp;<%=(String)vRetResult.elementAt(i+3)%>&nbsp;</td>
      <td align="right" class="thinborderRight">
	  <%if(dUnitCost > 0d) {%>
	  	<%=CommonUtil.formatFloat(dUnitCost, true)%>
	  <%}%>
	  &nbsp;</td>
      <td align="right" class="thinborderRight">
	  <%if(dUnitCost > 0d) {%>
	  	<%=CommonUtil.formatFloat(dUnitCost * Double.parseDouble((String)vRetResult.elementAt(i+2)) , true)%>
	  <%}%>
	  
	  &nbsp;</td>
      <td align="right" class="NoBorder">&nbsp;&nbsp;
	  <%if(strInvoiceNumber != null) {%>
	  	<%=strInvoiceNumber%>
	  <%strInvoiceNumber = null;}%>
	  </td>
    </tr>
		<%}for(;iCountRows < iNumRows;++iCountRows){%>
    <tr>
      <td height="22" class="thinborderRight">&nbsp;</td>
      <td align="right" class="thinborderRight">&nbsp;</td>
      <td align="right" class="thinborderRight">&nbsp;</td>
      <td align="right" class="thinborderRight">&nbsp;</td>
      <td align="right" class="NoBorder">&nbsp;</td>
    </tr>		
    <%}%>
  </table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td width="34%">(1) Prepared by : </td>
    <td width="4%">&nbsp;</td>
    <td width="13%">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td colspan="4" rowspan="2">(3) Received above items from the<br>
      Purchasing and Supply Office in good order </td>
    </tr>
  <tr>
    <td height="22" align="center" class="thinborderBOTTOM">&nbsp;<%=WI.fillTextValue("prepared_by")%></td>
    <td>&nbsp;</td>
    <td align="center" class="thinborderBOTTOM">&nbsp;</td>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td align="center">Purchasing &amp; Supply Officer </td>
    <td>&nbsp;</td>
    <td align="center">Date</td>
    <td>&nbsp;</td>
    <td width="25%">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="17%">&nbsp;</td>
    <td width="3%">&nbsp;</td>
  </tr>
  <tr>
    <td>(2) Inspected by : </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="22" align="center" class="thinborderBOTTOM">&nbsp;<%=WI.fillTextValue("inspected_by")%></td>
    <td>&nbsp;</td>
    <td align="center" class="thinborderBOTTOM">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center" class="thinborderBOTTOM"><%=(String)vIssuanceInfo.elementAt(2)%></td>
    <td>&nbsp;</td>
    <td align="center" class="thinborderBOTTOM">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td align="center">Internal Auditor </td>
    <td>&nbsp;</td>
    <td align="center">Date</td>
    <td>&nbsp;</td>
    <td align="center">Requester</td>
    <td>&nbsp;</td>
    <td align="center">Date</td>
    <td>&nbsp;</td>
  </tr>
<%if(bolIsAUF) {%>
  <tr>
    <td>cc: AFO, PSO, Requester</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td class="NoBorder">
	<div style="font-weight:bold;">
	AUF-FORM-AFO-32<br>
	March 2, 2009 - Rev. 01
	</div>
	</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
 <%}%>
</table>


<%
if(bolUPHD){
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