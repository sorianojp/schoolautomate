<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Inventory Master List - Print page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
		border-top: solid 1px #000000;
    	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
	    border-left: solid 1px #000000;
    	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
   	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOPBOTTOM {
   	border-top: solid 1px #000000;
   	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>

<%
	DBOperation dbOP = null;
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-LOG"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}

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
		dbOP = new DBOperation(null);
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
	String strErrMsg = null;
	String strTemp = null;
	String strFinCol = null;

	InventoryLog InvLog = new InventoryLog();
	vRetResult = InvLog.operateOnInventoryRegistry(dbOP, request, 4);

	if (vRetResult == null && strErrMsg == null )
		strErrMsg = InvLog.getErrMsg();

%>
<body onLoad="window.print()">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY LOG - INVENTORY REGISTRY PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <%if (vRetResult!= null && vRetResult.size()>0) {
  int iCount = 0;
  int iRowsPrinted = 0;
  for(int i = 0; i < vRetResult.size();) {
  	if(i > 0) {%>
		
	<%}
	iRowsPrinted = 0;
  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold">
      <td width="15%" align="center" class="thinborder">Count </td> 
      <td width="22%" height="25" align="center" class="thinborder">Item Name</td>
      <td width="13%" align="center" class="thinborder">Category</td>
      <td width="14%" align="center" class="thinborder">Class</td>
      <td width="11%" align="center" class="thinborder">Purchasing Unit</td>
      <td width="11%" align="center" class="thinborder">Dispensing Unit</td>
      <td width="15%" align="center" class="thinborder">Attributes</td>
    </tr>
    <%
	for (i=0;i<vRetResult.size(); i+=27){
		if(++iRowsPrinted > iDefValue)
			break;
		
		strTemp = (String)vRetResult.elementAt(i+14);
		 if (strTemp.equals("0"))
			strFinCol = " bgcolor = '#EEEEEE'";
		else 
			strFinCol = " bgcolor = '#FFFFFF'";
    %>
    <tr <%=strFinCol%>>
      <td class="thinborder"><%=++iCount%></td> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%><%=WI.getStrValue((String)vRetResult.elementAt(i+22)," (",")","")%><%=WI.getStrValue((String)vRetResult.elementAt(i+18),"<br>&nbsp;code: ","","")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+17),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(((String)vRetResult.elementAt(i+5)),"","<br>","&nbsp;")%> 
        <%=WI.getStrValue(((String)vRetResult.elementAt(i+8)),"&nbsp;("," "+(String)vRetResult.elementAt(i+7)+")","&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder"> 
        <%if (((String)vRetResult.elementAt(i+9)).equals("1")){%>EXPIRES<br> <%}
		  if (((String)vRetResult.elementAt(i+10)).equals("1")){%>TRANSFERRABLE<br><%}
		  if (((String)vRetResult.elementAt(i+11)).equals("1")){%>BORROWABLE<br><%}
		  if (((String)vRetResult.elementAt(i+12)).equals("1")){%>CONSUMABLE<%}
		  if (((String)vRetResult.elementAt(i+13)).equals("1")){%>COMPUTER COMPONENT<%}%>&nbsp;      
	  </td>
    </tr>
    <%}%>
  </table>
  <%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>