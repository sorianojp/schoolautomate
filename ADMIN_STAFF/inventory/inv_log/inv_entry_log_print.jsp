<%@ page language="java" import="utility.*, inventory.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Inventory Entry Log</title>
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-LOG"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY LOG","inv_entry_log_print.jsp");
	
	Vector vRetResult = null;
	Vector vPODtls = null;
	Vector vPOItems = null;
	int i = 0;
	String strErrMsg = null;
	String strType = null;
	String strInvType = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;
	String strFinCol = null;
	String[] astrEntryType = {"DONATION","PURCHASE","EXISTING STOCKS"};	
	
	double dTemp = 0d;
	
	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

	InventoryLog InvLog = new InventoryLog();
	
	vRetResult = InvLog.operateOnInventoryEntryMain(dbOP, request, 4);
	if (vRetResult == null && strErrMsg == null && WI.fillTextValue("inv_date").length()>0)
		strErrMsg = InvLog.getErrMsg();

%>
<body onLoad="window.print()">
<form name="form_" action="./inv_entry_log_print.jsp" method="post">
  <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="4" class="thinborder"><div align="center"> 
          <p><strong><font size="2"> INVENTORY ENTRY LIST FOR THE DATE (<%=WI.fillTextValue("inv_date")%>)</font></strong></p>
        </div></td>
    </tr>
    <tr> 
      <td width="15%" height="25" class="thinborder"><div align="center"><font size="1"><strong>ENTRY 
          TYPE </strong></font></div></td>
      <td width="35%" class="thinborder" align="center"><font size="1"><strong>REFERENCE</strong></font></td>
      <td width="34%" class="thinborder" align="center"><font size="1"><strong>ITEM</strong></font></td>
      <td width="16%" class="thinborder" align="center"><font size="1"><strong>QTY</strong></font></div></td>
    </tr>
    <%for (i=0; i< vRetResult.size(); i+=19) {%>
    <tr> 
      <td class="thinborder"><font size="1">&nbsp;<%=astrEntryType[Integer.parseInt((String)vRetResult.elementAt(i+1))]%> </font></td>
      <td class="thinborder"><font size="1">
        <%if (vRetResult.elementAt(i+5) != null){%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%>
        <%} else {%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+6),"PO Number : ","<br>","&nbsp;")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%>
        <%}%>
      </font></td>
			<%strTemp =(String)vRetResult.elementAt(i+16);			
			dTemp = Double.parseDouble(strTemp);
			if(dTemp > 1){
				dTemp = dTemp * Double.parseDouble((String)vRetResult.elementAt(i+2));
				strTemp = CommonUtil.formatFloat(dTemp,true) ;
				strTemp += " " + (String)vRetResult.elementAt(i+18);
			}else{
				strTemp = "";
			}				
			%>				
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+15),"Item Code: ","<br>","")%><%=((String)vRetResult.elementAt(i+3))%></font></td>
      <td align="right" class="thinborder"><font size="1"> <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2),false)%>&nbsp;<%=((String)vRetResult.elementAt(i+4))%><br>
&nbsp;<%=WI.getStrValue(strTemp,"(",")" ,"")%></font></td>
    </tr>
    <%}%>
  </table>
  <%}//if results exists%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>