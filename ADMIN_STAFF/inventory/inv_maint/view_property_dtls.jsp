<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
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
</head>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
</script>

<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY LOG","view_property_dtls.jsp");
	
	Vector vRetResult = null;
	int i = 0;
	int iTemp = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strQuery = "";

	InventoryLog InvLog = new InventoryLog();
	strTemp = WI.fillTextValue("info_index");
	vRetResult = InvLog.viewPropertyDetails(dbOP, strTemp, false);
	if(vRetResult == null)
		strErrMsg = InvLog.getErrMsg();

%>
<body bgcolor="#D2AE72">
<form action="./view_property_dtls.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY: PROPERTY DETAILS PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
   <tr>
   	<td width="5%">&nbsp;</td>
    <td width="30%">&nbsp;</td>
   	<td width="15%">&nbsp;</td>
   	<td width="50%">&nbsp;</td>
   </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Property Number :<strong><%=(String)vRetResult.elementAt(6)%></strong></td>
      <td >Item Type : <strong><%
      strTemp = (String)vRetResult.elementAt(21);
      if (strTemp.equals("0")){%>Non Supply<%} else if (strTemp.equals("1")) {%>
      Supply<%} else if (strTemp.equals("2")) {%>Chemical<%} else {%>Unknown<%}%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Item Name : <strong><%=(String)vRetResult.elementAt(1)%></strong></td>
      <td >Item Category :<strong><%=WI.getStrValue((String)vRetResult.elementAt(5),"Unknown")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Status:<strong><%=WI.getStrValue((String)vRetResult.elementAt(16),"Unknown")%></strong></td>
      <td >Is Available : <strong><%if (((String)vRetResult.elementAt(17)).equals("0")){%>Yes<%} else {%>No<%}%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Quantity : <strong><%=WI.getStrValue((String)vRetResult.elementAt(2),"Unknown")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#C78D8D"><font color="#FFFFFF"><strong>&nbsp;ITEM DETAILS</strong></font></td>
    </tr>
      <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Supplier : <strong><%=WI.getStrValue((String)vRetResult.elementAt(15),"Unknown")%></strong></td>
      <td >Price: <strong><%=WI.getStrValue((String)vRetResult.elementAt(4),"Unknown")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Serial Number : <strong><%=WI.getStrValue((String)vRetResult.elementAt(7),"Unknown")%></strong></td>
      <td >Product Number: <strong><%=WI.getStrValue((String)vRetResult.elementAt(8),"Unknown")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Additional Details : <strong><%=WI.getStrValue((String)vRetResult.elementAt(9),"None")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#C78D8D"><font color="#FFFFFF">&nbsp;<strong>OWNERSHIP & LOCATION</strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">College : <strong><%=WI.getStrValue((String)vRetResult.elementAt(10),"&nbsp;")%></strong></td>
      <td >Department : <strong><%=WI.getStrValue((String)vRetResult.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Building : <strong><%=WI.getStrValue((String)vRetResult.elementAt(12),"&nbsp;")%></strong></td>
      <td>Room : <strong><%=WI.getStrValue((String)vRetResult.elementAt(13),"Unknown")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Location Details : <strong><%=WI.getStrValue((String)vRetResult.elementAt(14),"Unknown")%></strong></td>
   </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#C78D8D"><font color="#FFFFFF">&nbsp;<strong>OTHER DETAILS</strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Log Date : <strong><%=WI.getStrValue((String)vRetResult.elementAt(18),"Unknown")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Warranty Date until: <strong><%=WI.getStrValue((String)vRetResult.elementAt(19),"Unknown")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Expiry Date : <strong><%=WI.getStrValue((String)vRetResult.elementAt(20),"N/A")%></strong></td>
    </tr>
   <tr> 
      <td height="25" colspan="4">&nbsp;</td>
   </tr>

  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
