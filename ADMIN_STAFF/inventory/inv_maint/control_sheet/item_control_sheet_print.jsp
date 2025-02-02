<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-MAINTENANCE"),"0"));
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","item_control_sheet.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}

	Vector vRetResult = null;
	int iTemp = 0;
	int i = 0;
	double dTemp = 0d;
	double dOnHand = 0d;
	boolean bolIsAdd = false;
	
	InventorySearch InvSearch = new InventorySearch();
	vRetResult = InvSearch.viewInventorySheet(dbOP,request);
	if (vRetResult!= null && vRetResult.size() > 1)
		iSearchResult = InvSearch.getSearchCount();	
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="12" align="center" class="thinborder"> <strong><font size="2">INVENTORY LIST</font></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="12" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL 
        RECORDS : &nbsp;&nbsp;<%=iSearchResult%></strong></font> </td>
    </tr>
    <tr>
      <td align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td height="22" align="center" class="thinborder"><font size="1"><strong>PARTICULAR</strong></font></td>
      <td colspan="7" align="center" class="thinborder"><strong>QUANTITY</strong></td>
      <td colspan="3" align="center" class="thinborder"><strong>PRICE</strong></td>
    </tr>
    <tr>
      <td width="6%" align="center" class="thinborder">&nbsp;</td> 
      <td width="15%" height="22" align="center" class="thinborder">&nbsp;</td>
      <td width="8%" align="center" class="thinborder">Purchased</td>
      <td width="7%" align="center" class="thinborder">Sold</td>
      <td width="7%" align="center" class="thinborder">Transfer</td>
      <td width="7%" align="center" class="thinborder">Used</td>
      <td width="7%" align="center" class="thinborder">Returns</td>
      <td width="10%" align="center" class="thinborder">Adjustments</td>
      <td width="9%" align="center" class="thinborder">On Hand </td>
      <td width="8%" align="center" class="thinborder">Unit Cost </td>
      <td width="8%" align="center" class="thinborder">Total Cost </td>
      <td width="8%" align="center" class="thinborder">Selling Price</td>
    </tr>
    <%if (vRetResult != null && vRetResult.size() > 0){
		for (i = 1; i < vRetResult.size(); i+=9){
			bolIsAdd = false;
			if(((String)vRetResult.elementAt(i+8)).equals("1"))
				bolIsAdd = true;
		%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td> 
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"")%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i),"0");
				dTemp = Double.parseDouble(strTemp);
				dOnHand += dTemp;
				if(dTemp == 0d)
					strTemp = "";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+1),"0");
				dTemp = Double.parseDouble(strTemp);
				dOnHand -= dTemp;
				if(dTemp == 0d)
					strTemp = "";
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+2),"0");
				dTemp = Double.parseDouble(strTemp);
				if(bolIsAdd)
					dOnHand += dTemp;
				else
					dOnHand -= dTemp;
				
				if(dTemp == 0d)
					strTemp = "";
			%>			
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3),"0");
				dTemp = Double.parseDouble(strTemp);					
				dOnHand -= dTemp;
				if(dTemp == 0d)
					strTemp = "";
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4),"0");
				dTemp = Double.parseDouble(strTemp);
				dOnHand -= dTemp;
				if(dTemp == 0d)
					strTemp = "";
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5),"0");
				dTemp = Double.parseDouble(strTemp);
				if(bolIsAdd)
					dOnHand += dTemp;
				else
					dOnHand -= dTemp;
				if(dTemp == 0d)
					strTemp = "";
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <td align="right" class="thinborder"><%=dOnHand%>&nbsp;</td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%}
	}%>
  </table>
  <%}// if (vRetResult != null && vRetResult.size() > 0)
     %>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>