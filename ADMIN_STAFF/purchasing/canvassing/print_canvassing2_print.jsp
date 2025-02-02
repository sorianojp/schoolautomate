<%@ page language="java" import="utility.*,purchasing.Canvassing,purchasing.Requisition,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
	if(strSchCode.startsWith("UB")){%>
		<jsp:forward page="./print_canvassing2_print_ub.jsp"/>
	<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<form name="form_">
  <%if(vReqInfo != null && vReqInfo.size() > 1){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="20"><strong>CANVASS FORM</strong></td>
    </tr>
  <tr>
    <td width="89%" height="22">&nbsp;<%=(String)vReqInfo.elementAt(5)%></td>
    </tr>
</table>
  <%if(vReqItems != null && vReqItems.size() > 3){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td class="thinborder">&nbsp;</td>
      <td height="26" class="thinborder">&nbsp;</td>	  
      <%
			for(j = 1; j < 6; j++){
				if(WI.fillTextValue("supplier"+j).length() == 0)
					continue;
					iSuppliers++;
			%>
			<td colspan="3" align="center" class="thinborder">&nbsp;<%=WI.fillTextValue("supplier_name"+j)%></td>
			<%}%>
    </tr>
    <tr>
      <td width="<%=(25-iSuppliers)%>%" align="center" class="thinborder"><strong>ITEM 
      / PARTICULARS / DESCRIPTION </strong></td> 
      <td width="<%=(13-iSuppliers)%>%" height="26" align="center" class="thinborder"><strong>QTY / UNIT</strong></td>	  
			<%
			for(j = 1; j < 6; j++){
				if(WI.fillTextValue("supplier"+j).length() == 0)
					continue;
			%>
      <td align="center" class="thinborder"><strong>REG PRI </strong></td>
      <td align="center" class="thinborder"><strong>DISC PRI </strong></td>
      <td align="center" class="thinborder"><strong>TOTAL AMT</strong></td>
			<%}%>
    </tr>
    <%for(int iLoop = 2;iLoop < vReqItems.size();iLoop+=9){%>
    <tr>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop+3)%>/<%=(String)vReqItems.elementAt(iLoop+4)%></td>
      <td height="25" class="thinborder"><%=(String)vReqItems.elementAt(iLoop+1)%>&nbsp;<%=(String)vReqItems.elementAt(iLoop+2)%></td>
			<%
			for(j = 1; j < 6; j++){
				if(WI.fillTextValue("supplier"+j).length() == 0)
					continue;				
			%>			
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
			<%}%>
    </tr>
    <%}%>
  </table>	
  <%}%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="3">&nbsp;</td>
    </tr>
  <tr>
    <td width="14%">PREPARED BY : </td>
    <td width="31%">&nbsp;<u>&nbsp;&nbsp;<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%>&nbsp;&nbsp;</u></td>
    <td width="55%">&nbsp;</td>
  </tr>
</table>
  <%}%>
  <!-- all hidden fields go here -->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
