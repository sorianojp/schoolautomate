<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);

	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();	
	}

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
<script language="javascript" src ="../../../jscript/common.js" ></script>
<%
	//authenticate user access level	
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
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY LOG","inv_borrow.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int i = 0;
	int iTemp = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strQuery = "";
	String strInvType = null;
	String strCategory = null;
	String strClassification = null;

	int iSearchResult = 0;

	InventorySearch InvSearch = new InventorySearch();
	vRetResult = InvSearch.searchProperty(dbOP, request);
	
%>

<body onLoad="javascript:window.print();">
<form name="form_">
  <%if(vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" class="thinborder"><strong>PROPERTY NUMBERS </strong></td>
    </tr>
    
    <tr> 
    <td width="10%" class="thinborder" align="center" height="25"><font size="1"><strong>PROPERTY NUMBER</strong></font></td>
      <td width="16%" class="thinborder" align="center"><font size="1"><strong>ITEM INFO</strong></font></td>
      <td width="16%" class="thinborder" align="center"><font size="1"><strong>ITEM DETAILS</strong></font></td>
      <td width="18%" class="thinborder" align="center"><font size="1"><strong>OWNERSHIP</strong></font></td>
      <td width="20%" class="thinborder" align="center"><font size="1"><strong>LOCATION</strong></font></td>
      <td width="14%" class="thinborder" align="center"><font size="1"><strong>OTHER DETAILS</strong></font></td>
    </tr>
    <%for (i = 0; i<vRetResult.size(); i+=21){%>
    <tr> 
     <td class="thinborder"><font size="1">
     <%if(WI.fillTextValue("opner_info").length() > 0) {%>
		   <%if (WI.fillTextValue("propnum").length() > 0) {%>
			  <a href='javascript:CopyPropNum("<%=WI.fillTextValue("propnum")+","+(String)vRetResult.elementAt(i+6)%>");'>
			  <%=(String)vRetResult.elementAt(i+6)%></a>
		  <%}else{%>
			  <a href='javascript:CopyPropNum("<%=(String)vRetResult.elementAt(i+6)%>");'>
			  <%=(String)vRetResult.elementAt(i+6)%></a>
		  <%}%>	  
	  <%}else{%>
	  <%=(String)vRetResult.elementAt(i+6)%>
	  <%}%></font></td>
      <td class="thinborder"><font size="1">
      Item Name: <%=(String)vRetResult.elementAt(i+1)%><br>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"Category: ","<br>","")%><%=WI.getStrValue((String)vRetResult.elementAt(i+16),"Status: ","","")%>
      </font></td>
      <td height="25" class="thinborder"><font size="1">
      <%=WI.getStrValue((String)vRetResult.elementAt(i+15),"Supplier: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"Serial #: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"Product #: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"Details : ","","&nbsp;")%>
      </font></td>
      <td class="thinborder"><font size="1">
      <%=WI.getStrValue((String)vRetResult.elementAt(i+10),"College: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+11),"Department: ","","&nbsp;")%>
      </font></td>
      <td class="thinborder"><font size="1">
      <%=WI.getStrValue((String)vRetResult.elementAt(i+12),"Building: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+13),"Room: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+14),"Description: ","","&nbsp;")%>
      </font></td>
      <td class="thinborder"><font size="1">
	  Log Date: <%=(String)vRetResult.elementAt(i+18)%><br>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+19),"Warranty until: ","<br>","")%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+20),"Expires on: ","","")%>
      </font></td>
    </tr>
    <%}%>
  </table>
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
