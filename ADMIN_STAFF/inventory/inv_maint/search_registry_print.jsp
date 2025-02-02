<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);

	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();	
	}

%><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","search_registry.jsp");
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
	String strInvType  = null;
	String strCategory = null;
	String strClassification = null;

	InventorySearch InvSearch = new InventorySearch();
	 vRetResult = InvSearch.searchItemCode(dbOP,request);
	if (vRetResult!= null && vRetResult.size() > 0)
		iSearchResult = InvSearch.getSearchCount();
%>
<body onLoad="javascript:window.print();">
<form name="form_" method="post" >
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="5" align="center" class="thinborder"><strong><font size="2">ITEM CODES </font></strong></td>
    </tr>
    
    <tr>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>ITEM CODE </strong></font></td> 
      <td width="32%" height="22" align="center" class="thinborder"><font size="1"><strong>ITEM</strong></font></td>
      <td width="18%" align="center" class="thinborder"><font size="1"><strong>CATEGORY</strong></font></td>
      <td width="18%" align="center" class="thinborder"><font size="1"><strong>CLASS</strong></font></td>
      <td width="18%" align="center" class="thinborder"><font size="1"><strong>BRAND</strong></font></td>
    </tr>
    <%if (vRetResult != null && vRetResult.size() > 0){
		for (int i = 0; i < vRetResult.size(); i+=6){
	%>
    <tr>
      <td class="thinborder"><font size="1">
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyItemCode("<%=(String)vRetResult.elementAt(i+1)%>");'> <%=(String)vRetResult.elementAt(i+1)%></a>
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+1)%>
        <%}%>
      </font></td> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i + 2),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i + 3),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i + 4),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i + 5),"&nbsp;")%></td>
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