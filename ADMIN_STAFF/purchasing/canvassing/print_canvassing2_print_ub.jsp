<%@ page language="java" import="utility.*,purchasing.Canvassing,purchasing.Requisition,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 9px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 9px;
    }
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<%

	DBOperation dbOP = null;
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-CANVASSING"),"0"));
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
								"Admin/staff-PURCHASING-CANVASSING-Print Canvassing","print_canvassing.jsp");
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
	
	Requisition REQ = new Requisition();
	Canvassing CAN = new Canvassing();	
	purchasing.Supplier supplier = new purchasing.Supplier();
	Vector vReqInfo = null;
	Vector vReqItems = null;	
	boolean bolIsInCanvass = false;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String[] astrSuppliers = new String[5];
	int iCol1 = 20;
	int iCol2 = 20;
	int iCol3 = 60;
	int iSuppliers = 0;

	int iTemp = 1;
	int j = 0;
	for(int i = 0; i < 5; i++){
		strTemp = WI.fillTextValue("supplier"+(i+1));
		for(j = 1; j < 6; j++){
			strTemp2 = WI.fillTextValue("supplier"+j);
			if(strTemp.equals(strTemp2))
				continue;
				
			if(astrSuppliers[i] == null || astrSuppliers[i].length() == 0)
				astrSuppliers[i] = strTemp2;
			else
				astrSuppliers[i] = astrSuppliers[i] + WI.getStrValue(strTemp2,",","","");
		}
	}

	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
	if(vReqInfo != null){
		vReqItems = REQ.operateOnReqItems(dbOP,request,5);
	}

%>
<body onLoad="javascript:window.print();">

<%

if(vReqInfo != null && vReqInfo.size() > 1 && vReqItems != null && vReqItems.size() > 0){
String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP, false, false);
String strSuppIndex = null;

Vector vSuppInfo = null;

int iCount = 0;
for(int i = 1; i < 6; i++){
strSuppIndex = WI.fillTextValue("supplier"+i);
if(strSuppIndex.length() == 0)
	continue;
	
vSuppInfo =  supplier.getSupplierInfo(dbOP, request, strSuppIndex);
if(vSuppInfo == null || vSuppInfo.size() == 0)
	continue;

	
if(iCount > 0){
%>
 <div style="page-break-after:always;">&nbsp;</div>
<%}
vSuppInfo.remove(0);
++iCount;
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr><td align="center" height="25">
	<strong style="font-size:14px;"><%=strSchName%></strong><br>
	<%=strSchAddr%><br><br><br><br><strong style="font-size:13px;">CANVASS FORM</strong>
	</td></tr>
	<tr><td align="center" height="25">&nbsp;</td></tr>
	<tr><td height="25" style="padding-left:20px;"><%=WI.getStrValue(vSuppInfo.elementAt(2))%></td></tr>
	<tr><td height="25" style="padding-left:20px;"><%=WI.getStrValue(vSuppInfo.elementAt(19))%></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="76%" height="25" align="center" class="thinborder"><strong>ITEMS</strong></td>
		<td width="24%" align="center" class="thinborder"><strong>PRICE</strong></td>
	</tr>
	<%
	for(int iLoop = 2;iLoop < vReqItems.size();iLoop+=9){
	%>
	<tr>
	    <td height="25" class="thinborder">&nbsp;<%=(String)vReqItems.elementAt(iLoop+3)%>/<%=(String)vReqItems.elementAt(iLoop+4)%></td>
	    <td align="center" class="thinborder">&nbsp;</td>
    </tr>
	<%}%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="60" valign="bottom"><div style="width:40%; border-bottom: solid 1px  #000000;"></div>Owner Representative</td></tr>
</table>
<%
}//end of supplier loop
}%>  
  

</body>
</html>
<%
dbOP.cleanUP();
%>
