<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
</style>
</head>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;	
	String strTemp = null;
//add security here.
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
								"Admin/staff-PURCHASING-DELIVERY-View delivery update Status","delivery_update_status_print.jsp");
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
	
	Delivery DEL = new Delivery();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vReqPO = null;
	Vector vReturned = null;
	Vector vRetResult = null;
	int iCount = 0;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	String strSchCode = dbOP.getSchoolIndex();	
	int iLoop1 = 0;
	int iLoop2 = 0;
	int iLoop3 = 0;	
	int iCountRows = 0;
	
	String strSuppName = null;
	String strReceiveNo  = null;
	String strReceiveDate = null;
	String strPOIndex = null;
	Vector vAddlInfo = new Vector();
	vReqInfo = DEL.operateOnReqInfoDel(dbOP,request);
	if(vReqInfo == null)
		strErrMsg = DEL.getErrMsg();
	else{
		strPOIndex = (String)vReqInfo.elementAt(0);
		
				
		
		strTemp = "select SUPPLIER_NAME from PUR_SUPPLIER_PROFILE where PROFILE_INDEX = "+(String)vReqInfo.elementAt(14);
		strSuppName = dbOP.getResultOfAQuery(strTemp, 0);
		
		
		vRetResult = DEL.operateOnReqItemsDel(dbOP,request,4,strPOIndex, true,strSchCode);
		if(vRetResult == null)
			strErrMsg = DEL.getErrMsg();
		else{
			vReqPO = (Vector)vRetResult.elementAt(0);
			vReqItems = (Vector)vRetResult.elementAt(1);
			vReturned = (Vector)vRetResult.elementAt(2);
		}	
		
		if(vReqItems != null && vReqItems.size() > 0){
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
				vAddlInfo.addElement(rs.getString(1));//[0]DELIVERY_NO
				vAddlInfo.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(2)));//[1]DELIVERY_DATE
				vAddlInfo.addElement(rs.getString(3));//[2]encode.ID_NUMBER
				vAddlInfo.addElement(rs.getString(4));//[3]FNAME
				vAddlInfo.addElement(rs.getString(5));//[4]MNAME
				vAddlInfo.addElement(rs.getString(6));//[5]LNAME
				vAddlInfo.addElement(rs.getString(7));//[6]approve.ID_NUMBER
				vAddlInfo.addElement(rs.getString(8));//[7]FNAME
				vAddlInfo.addElement(rs.getString(9));//[8]MNAME
				vAddlInfo.addElement(rs.getString(10));//[9]LNAME			
			}rs.close();
		}
	}
	float fTotal = 0f;
	for(;iLoop1 < vReqPO.size() || iLoop2 < vReqItems.size() || iLoop3 < vReturned.size(); ){
		iCountRows = 0;
%>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font>
	  </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
	<tr> 
    <td height="25" colspan="2"><div style="font-weight:bold" align="center"> 
            <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
			Stock Receipt<br>PROPERTY CUSTODIANS OFFICE
        </div></td>
  </tr>
  </table> 
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr>	
		<td height="25"width="12%"><strong>Receive No.:</strong></td>	
		<%
		strTemp = "&nbsp;";
		if(vAddlInfo != null && vAddlInfo.size() >0)
			strTemp = (String)vAddlInfo.elementAt(0);
		%>
		<td width="53%"><%=strTemp%></td>	
		<td width="10%"><strong>Date:</strong> </td>
		<%
		strTemp = "&nbsp;";
		if(vAddlInfo != null && vAddlInfo.size() >0)
			strTemp = (String)vAddlInfo.elementAt(1);
		%>	
		<td width="25%"><%=strTemp%></td>	
	</tr>
  	<tr>
  	    <td height="25"><strong>Supplier:</strong></td>
  	    <td><%=strSuppName%></td>
  	    <td><strong>PO NO.:</strong></td>
  	    <td><%=(String)vReqInfo.elementAt(1)%></td>
      </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr style="font-weight:bold">
		<td style="border-bottom:dashed 1px; border-top:dashed 1px;" width="6%" height="20" align="center">Line No.</td>
		<td style="border-bottom:dashed 1px; border-top:dashed 1px;" width="41%">Description</td>
		<td style="border-bottom:dashed 1px; border-top:dashed 1px;" width="14%" align="center">Unit</td>
		<td style="border-bottom:dashed 1px; border-top:dashed 1px;" width="14%" align="center">Qty Received</td>
		<td style="border-bottom:dashed 1px; border-top:dashed 1px;" width="12%" align="center">Unit Cost</td>
		<td style="border-bottom:dashed 1px; border-top:dashed 1px;" width="13%" align="center">Amount</td>
	</tr>
	<%//iCount = 0;
	for(;iLoop2 < vReqItems.size() && iCountRows < 15;iLoop2+=16,++iCountRows){%>
  	<tr>
  	    <td align="center" height="20"><%=++iCount%></td>
  	    <td><%=(String)vReqItems.elementAt(iLoop2+3)%>/<%=(String)vReqItems.elementAt(iLoop2+4)%><%=WI.getStrValue((String)vReqItems.elementAt(iLoop2+9),"(",")","")%></td>
  	    <td align="center"><%=(String)vReqItems.elementAt(iLoop2+2)%></td>
  	    <td align="center"><%=(String)vReqItems.elementAt(iLoop2+12)%></td>
  	    <td align="right"><%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop2+14),true)%></td>
		<%
		try{
			strTemp = (String)vReqItems.elementAt(iLoop2+15);
			strTemp = ConversionTable.replaceString(strTemp, ",","");
			fTotal += Float.parseFloat(strTemp);
		}catch(Exception e){}
		%>
  	    <td align="right"><%=(String)vReqItems.elementAt(iLoop2+15)%></td>
      </tr>
  	
	<%}%>
	<tr style="font-weight:bold">
  	    <td style="border-top:dashed 1px" height="20" colspan="5" align="right">Total Amount of Received Items -----> &nbsp;</td>
  	    <td style="border-top:dashed 1px" align="right"><%=CommonUtil.formatFloat(fTotal, true)%></td>
      </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr>
		<td width="50%"><strong>Received By:</strong></td>
		<td width="50%"><strong>Approved By:</strong></td>
	</tr>
  	<tr><%
		
		//strTemp = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "Stockman",7)).toUpperCase();
		strTemp = "&nbsp;";
		if(vAddlInfo != null && vAddlInfo.size() >0)
			strTemp = WebInterface.formatName((String)vAddlInfo.elementAt(3),(String)vAddlInfo.elementAt(4),(String)vAddlInfo.elementAt(5),4);
		%>
  	    <td height="40" valign="bottom"><div style="border-bottom:solid 1px #000000; text-align:center; width:70%"><%=WI.getStrValue(strTemp)%></div></td>
  	    <%
		//strTemp = "select DH_NAME from DEPARTMENT where IS_CENTRAL_OFFICE = 1";
		//strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		
		strTemp = "&nbsp;";
		if(vAddlInfo != null && vAddlInfo.size() >0)
			strTemp = WebInterface.formatName((String)vAddlInfo.elementAt(7),(String)vAddlInfo.elementAt(8),(String)vAddlInfo.elementAt(9),4);
		%>
		<td valign="bottom"><div style="border-bottom:solid 1px #000000; text-align:center; width:70%"><%=WI.getStrValue(strTemp)%></div></td>
      </tr>
  	<tr>
  	    <td valign="top"><div style="text-align:center; width:70%">STOCKMAN</div></td>
  	    <td valign="top"><div style="text-align:center; width:70%">PROPERTY CUSTODIAN</div></td>
      </tr>
  </table>
  
  <%if(iLoop1 < vReqPO.size() || iLoop2 < vReqItems.size() || iLoop3 < vReturned.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }%>
</body>
</html>
<%
dbOP.cleanUP();
%>
