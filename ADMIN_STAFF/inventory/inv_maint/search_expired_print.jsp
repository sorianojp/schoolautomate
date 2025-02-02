<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
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
<script language="JavaScript" src="../../../jscript/td.js"></script>
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","search_expired.jsp");
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
	String strTemp2 = null;
	String strTemp3 = null;
	String strQuery = "";	
	InventorySearch InvSearch = new InventorySearch();

	vRetResult = InvSearch.searchExpired(dbOP,request);
	if (vRetResult!= null && vRetResult.size() > 0)
		iSearchResult = InvSearch.getSearchCount();
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="5" class="thinborder"><div align="center"><strong><font size="2">EXPIRED CHEMICALS AS OF <%=WI.getTodaysDate(1)%></font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="5" class="thinborderBOTTOMLEFT"><div align="left"><font size="1"><strong>TOTAL 
          ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font> </div></td>
    </tr>
    <tr> 
      <td width="12%" height="28" align="center" class="thinborder"><font size="1"><strong>QUANTITY</strong></font></td>
      <td width="25%" align="center" class="thinborder"><font size="1"><strong>ITEM</strong></font></td>
      <td width="40%" align="center" class="thinborder"><strong><font size="1">OWNERSHIP</font></strong></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">EXPIRY DATE </font></strong> </td>
    </tr>
    <%
		int iCount = 1;
		if (vRetResult != null && vRetResult.size() > 0){		
			for (int i = 0; i < vRetResult.size(); i+=19, iCount++){
		%>
    <tr> 			
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+1),"&nbsp;")%>&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+8),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i),"")%><%=WI.getStrValue((String) vRetResult.elementAt(i+12),"(",")","")%><font size="1"><%=WI.getStrValue((String) vRetResult.elementAt(i+15),"<br>&nbsp;Code: ","","")%></font></td>
      <%if(vRetResult.elementAt(i+2) == null || ((String) vRetResult.elementAt(i+2)).equals("0")
					|| vRetResult.elementAt(i+3) == null || ((String) vRetResult.elementAt(i+3)).equals("0")){
					strTemp = "";
				}else{
					strTemp = " - ";
				}				
			%>
			
      <td class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+2),"",strTemp,"")%><%=WI.getStrValue((String) vRetResult.elementAt(i+3),"")%>&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+4),"<br>","<br>","&nbsp;")%><%=WI.getStrValue((String) vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+6),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String) vRetResult.elementAt(i+7),"&nbsp;")%></td>
    </tr>
    <%}
	}%>
  </table>
  <%}// if (vRetResult != null && vRetResult.size() > 0)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>