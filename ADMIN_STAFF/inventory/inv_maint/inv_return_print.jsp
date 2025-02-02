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
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
</head>

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
								"INVENTORY-INVENTORY MAINTENANCE","inv_return_print.jsp");
	
	Vector vRetResult = null;
	Vector vItems = null;
	Vector vTemp = null;
	int i = 0;
	int iCtr = 0;
	int iMax = 0;
	int iTemp = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;

	strTemp = WI.fillTextValue("page_action");

	InventoryMaintenance InvMaint = new InventoryMaintenance();

	if(strTemp.length() > 0) {
		if(InvMaint.operateOnReturnItem(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else 
			strErrMsg = InvMaint.getErrMsg();
	}

	vItems = InvMaint.operateOnReturnItem(dbOP, request, 5);
	if (vItems == null && WI.fillTextValue("borrow_no").length()>0)
		strErrMsg = InvMaint.getErrMsg();
		
	vRetResult = InvMaint.operateOnReturnItem(dbOP, request, 4);
	if (vRetResult != null)
		iSearchResult = InvMaint.getSearchCount();
	else if (vRetResult == null && WI.fillTextValue("borrow_no").length()>0 && strErrMsg == null)
		strErrMsg = InvMaint.getErrMsg();
%><body bgcolor="#FFFFFF">
<form name="form_" action="inv_return_print.jsp" method="post" >
  <%if (vItems!=null && vItems.size()>0) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="19"><hr size="1"></td>
    </tr>
    <tr> 
      <td class="thinborder" bgcolor="ffffff" height="25"><div align="center">
          <font color="#000000"><strong>UNRETURNED ITEMS</strong></font>
        </div></td>
    </tr>
    <%	
	for (i = 0; i < vItems.size(); i+=5,++iMax){
	%>
    <tr> 
      <input name="b_index<%=iMax%>" type="hidden" value="<%=(String)vItems.elementAt(i)%>">
      <td class="thinborder" align="center" width="25%" height="25"><div align="left"><font color="#000000" size="1"> 
          &nbsp;&nbsp;<%=(i/5)+1%>: <%=((String)vItems.elementAt(i+3)).toUpperCase()%><%=WI.getStrValue((String)vItems.elementAt(i+2),"(",")","")%></font></div></td>
    </tr>
    <%}// if there are borrowed items%>
    
  </table>
  <%}//if there is a result%>
<%if (vRetResult != null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="6" class="thinborder" align="center"><strong> <font size="2" color="#000000">RETURNED 
        ITEMS</font></strong></td>
    </tr>
    <tr> 
      <td width="10%" height="25" class="thinborder"><div align="center"><strong>Property 
          # </strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>ITEM 
          DETAILS</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1">BORROWER'S 
          DETAIL</font></strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1">ACTUAL 
          RETURN DETAIL </font></strong></div></td>
      <td width="18%" class="thinborder"><div align="center"><strong><font size="1">RETURNED 
          BY</font></strong></div></td>
      <td width="18%" class="thinborder"><div align="center"><strong><font size="1">STATUS 
          / REMARKS</font></strong></div></td>
    </tr>
    <%for (i = 0; i< vRetResult.size(); i+=19) {%>
    <tr> 
      <td class="thinborder" height="25" align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><font size="1"> <strong>Item Name:</strong> <%=(String)vRetResult.elementAt(i+3)%><br>
        <strong>Category:</strong> <%=(String)vRetResult.elementAt(i+2)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"<br><strong>Product No :</strong> ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"<br><strong>Serial No :</strong> ","","")%> </font> </td>
      <td class="thinborder"><font size="1"> <strong>ID number: </strong><%=(String)vRetResult.elementAt(i+9)%><br>
        <strong>Name: </strong><br>
        <%=WI.formatName((String)vRetResult.elementAt(i+6),(String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+8),7)%><br>
        <strong>Borrow Date: </strong><%=(String)vRetResult.elementAt(i+10)%></font> </td>
      <td class="thinborder"> <font size="1"> <strong>Return date: </strong><%=WI.getStrValue((String)vRetResult.elementAt(i+11),"Undefined")%><br>
        <strong>Return time: </strong> 
        <%if (vRetResult.elementAt(i+12) != null){
      iTemp = Integer.parseInt((String)vRetResult.elementAt(i+12));
      if (iTemp <= 12){%>
        <%=iTemp%> 
        <%} else{%>
        <%=(iTemp-12)%> 
        <%}
      if (iTemp <12){%>
        AM 
        <%} else {%>
        PM 
        <%}} else {%>
        Undefined 
        <%}%>
        </font> </td>
      <td class="thinborder"><font size="1"> <strong>ID number: </strong><%=(String)vRetResult.elementAt(i+16)%><br>
        <strong>Name: </strong><br>
        <%=WI.formatName((String)vRetResult.elementAt(i+13),(String)vRetResult.elementAt(i+14),(String)vRetResult.elementAt(i+15),7)%> </font></td>
      <td class="thinborder"><font size="1"> <strong>Status: </strong><%=(String)vRetResult.elementAt(i+17)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+18),"<br><strong>Remark: </strong>","","")%> </font> </td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="maxSel" value="<%=iMax%>">
    <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>