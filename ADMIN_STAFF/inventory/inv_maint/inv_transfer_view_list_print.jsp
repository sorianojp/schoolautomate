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
								"INVENTORY-INVENTORY MAINTENANCE","inv_transfer_view_list_print.jsp");
	
	Vector vRetResult = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	
	InventoryMaintenance InvMaint = new InventoryMaintenance();

	vRetResult = InvMaint.operateOnTransItemList(dbOP, request);
	if (vRetResult != null)
		iSearchResult = InvMaint.getSearchCount();
	else if (vRetResult == null && WI.fillTextValue("date_fr").length()>0)
		strErrMsg = InvMaint.getErrMsg();
%>
<body bgcolor="#FFFFFF">
<form name="form_" action="inv_transfer_view_list_print.jsp" method="post" >
  <%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="6" class="thinborder"><div align="center"> 
          <p><strong><font size="2">TRANSFER DETAILS</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td width="9%" height="25" class="thinborder"><div align="center"><font size="1"><strong>PROPERTY 
          # </strong></font></div></td>
      <td width="22%" class="thinborder"><div align="center"><font size="1"><strong>ITEM 
          CATEGORY/NAME/SERIAL #/PRODUCT #</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>QTY 
          TRANSFERED </strong></font></div></td>
      <td width="24%" class="thinborder"><div align="center"><font size="1"><strong>ORIGINAL 
      LOCATION </strong></font></div></td>
      <td width="24%" class="thinborder"><div align="center"><font size="1"><strong>TRANSFER 
      LOCATION </strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>TRANSFER 
      DATE</strong></font></div></td>
      <%if(false){%>
      <%}%>
    </tr>
    <%for (i = 0; i<vRetResult.size(); i+=16){%>
    <tr> 
      <td class="thinborder" height="25"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"> Item Name: <%=(String)vRetResult.elementAt(i+3)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"<br>Product No: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"<br>Serial No: ","","")%></font> </td>
      <td class="thinborder" align="center"> <font size="1"><%=(String)vRetResult.elementAt(i+6)%></font></td>
      <td class="thinborder"><font size="1"> <%=WI.getStrValue((String)vRetResult.elementAt(i+12),"College : ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+11),"<br>Department: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"<br>Room: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"<br>Location: ","","")%> </font></td>
      <td class="thinborder"> <font size="1"> <%=WI.getStrValue((String)vRetResult.elementAt(i+14),"College : ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+13),"<br>Department: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"Room: ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+10),"<br>Location: ","","")%> </font> </td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+15),"")%></font></td>
      <%if(false){%>
      <%}%>
    </tr>
    <%}%>
  </table>
  <%}%>
  <input type="hidden" name="print_pg">
</form>
<script language="JavaScript">
window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>