<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
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

	Vector vAddlInfo = new Vector();
	Vector vItemDetails = null;
	Vector vRetResult    = null;
	int iIndexOf = 0; 

 	int iCount = 1;
	int iCountRows = 0;
	int iNumRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	
	String strDeptHead = null;//college / dept head
	
	String strCName = null;
	String strDName = null;
	String strPOIndex = null;
	String strSupplierName = null;
	vRetResult = deliveryItem.getIssuanceInfoAUF(dbOP,request);
 	if(vRetResult == null)
		strErrMsg = deliveryItem.getErrMsg();
	else{
		strPOIndex = (String)vRetResult.elementAt(1);
		strTemp = "select MAX(DELIVERY_INDEX) from PUR_DELIVERY where IS_VALID =1 and PO_INDEX = "+strPOIndex;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		
		strTemp = " select DELIVERY_NO, DELIVERY_DATE ,  "+
				" encode.ID_NUMBER, encode.FNAME, encode.MNAME, encode.LNAME, "+
				" approve.ID_NUMBER, approve.FNAME, approve.MNAME, approve.LNAME "+
				" from PUR_DELIVERY  "+
				" join USER_TABLE as encode on (encode.USER_INDEX = receiver) "+
				" join USER_TABLE as approve on (approve.USER_INDEX = CHECKER) "+
				" where PUR_DELIVERY.IS_VALID =1 and PO_INDEX = "+strPOIndex+" and DELIVERY_INDEX = "+strTemp;
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		if(rs.next()){
			vAddlInfo.addElement(rs.getString(1));
			vAddlInfo.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(2)));
			vAddlInfo.addElement(rs.getString(3));
			vAddlInfo.addElement(rs.getString(4));
			vAddlInfo.addElement(rs.getString(5));
			vAddlInfo.addElement(rs.getString(6));
			vAddlInfo.addElement(rs.getString(7));
			vAddlInfo.addElement(rs.getString(8));
			vAddlInfo.addElement(rs.getString(9));
			vAddlInfo.addElement(rs.getString(10));			
		}rs.close();
	
		strCName = WI.getStrValue((String)vRetResult.elementAt(10));
		strDName = WI.getStrValue((String)vRetResult.elementAt(11));
		
		strTemp = "select DEAN_NAME from COLLEGE where C_NAME = "+WI.getInsertValueForDB(strCName, true, null);
		strCName = dbOP.getResultOfAQuery(strTemp, 0);
		
		strTemp = "select DH_NAME from DEPARTMENT where D_NAME = "+WI.getInsertValueForDB(strDName, true, null);
		strDName = dbOP.getResultOfAQuery(strTemp, 0);
		
		if(strDName != null)
			strDeptHead = strDName;
		else
			strDeptHead = strCName;
		
	
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr>
		<td align="center"><%=SchoolInformation.getSchoolName(dbOP, true, false)%><br><%=SchoolInformation.getAddressLine1(dbOP, false, false)%><br>
		Office of the Property Custodian<br>RECEIPT OF AN INSTRUMENT OR ARTICLES</td>
	</tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr>
		<td height="25" width="15%">DEPARTMENT:</td>
		<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(10));
		strErrMsg = WI.getStrValue((String)vRetResult.elementAt(11));
		if(strTemp.length() > 0 && strErrMsg.length() > 0)
			strTemp += " / ";
		strTemp += strErrMsg;
		%>
		<td width="53%"><%=strTemp%></td>
		<td width="32%"><%=(String)vRetResult.elementAt(6)%></td>
	</tr>
  	<tr>
  	    <td height="25">HEAD/INCHARGE</td>
  	    <td><%=WI.getStrValue(strDeptHead)%></td>
		<%
		strTemp = "&nbsp;";
		if(vAddlInfo != null && vAddlInfo.size() > 0)
			strTemp = (String)vAddlInfo.elementAt(1);
		%>
  	    <td><%=strTemp%></td>
  	    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
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
		<%}%>
	<tr>
      <td height="22" colspan="3" align="right" class="thinborder"><strong>TOTAL AMOUNT</strong></td>
      <td align="right" class="thinborderLEFTBottomRIGHT"><strong><%=CommonUtil.formatFloat(dTotal,true)%></strong></td>
      </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0">
   	<tr><td colspan="4">*CONDITIONS*</td></tr>
	<tr><td colspan="4" style="text-align:justify;">1. That, as department head, I will exercise control and supervision for the proper use and maintenance of equipment.</td></tr>
	<tr><td colspan="4" style="text-align:justify;">2. Should the items be transferred to another department, I will furnish this office a copy of the receipt covering
			said transfer.
		</td></tr>
	<tr><td colspan="4" style="text-align:justify;">3. At the end of the year. I will furnish this office a list of all the equipment under my custody.</td></tr>
	<tr><td colspan="4" style="text-align:justify;">4. I will answer for any damage or loss of the articles or instruments borrowed.</td></tr>
	<tr>
	    <td width="25%" height="25" align="center">REQUESTED BY:</td>
	    <td width="25%" align="center">APPROVED BY:</td>
	    <td width="25%" align="center">ISSUED BY:</td>
	    <td width="25%" align="center">RECEIVED BY:</td>
	</tr>
	<tr>
	    <td align="center" valign="bottom" height="40"><div style="border-bottom:solid 1px; width:95%"><%=WI.getStrValue(vRetResult.elementAt(8))%></div></td>		
		<%
		//strTemp = "select DH_NAME from DEPARTMENT where IS_CENTRAL_OFFICE = 1";
		//strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		
		strTemp = "&nbsp;";
		if(vAddlInfo != null && vAddlInfo.size() >0)
			strTemp = WebInterface.formatName((String)vAddlInfo.elementAt(7),(String)vAddlInfo.elementAt(8),(String)vAddlInfo.elementAt(9),4);
		%>
	    <td align="center" valign="bottom"><div style="border-bottom:solid 1px; width:95%"><%=WI.getStrValue(strTemp)%></div></td>
		<%
		//strTemp = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "Stockman",7)).toUpperCase();
		strTemp = "&nbsp;";
		if(vAddlInfo != null && vAddlInfo.size() >0)
			strTemp = WebInterface.formatName((String)vAddlInfo.elementAt(3),(String)vAddlInfo.elementAt(4),(String)vAddlInfo.elementAt(5),4);		
		%>
	    <td align="center" valign="bottom"><div style="border-bottom:solid 1px; width:95%"><%=WI.getStrValue(strTemp)%></div></td>
	    <td align="center" valign="bottom"><div style="border-bottom:solid 1px; width:95%"><%=WI.getStrValue(vRetResult.elementAt(8))%></div></td>
	</tr>
	<tr>
	    <td align="center">Dept: Head/Incharge</td>
	    <td align="center">Property Custodian</td>
	    <td align="center">Stockman</td>
	    <td align="center">&nbsp;</td>
	</tr>
   </table>
  <%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>