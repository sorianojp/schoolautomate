<%@ page language="java" import="utility.*,purchasing.Quotation,purchasing.Requisition,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Quotation request</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print()">
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	double dTotalAmount = 0d;
	double dGrandTotal = 0d;
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-UPDATE QUOTATION STATUS"),"0"));
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
								"Admin/staff-PURCHASING-UPDATE QUOTATION STATUS-Update QUOTATION Status","request_requotation2.jsp");
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
	Quotation QTN = new Quotation();
	Vector vReqInfo = null;
	Vector vRetResult  = null;
	Vector vColumns = null;
	Vector vRows = null;
	Vector vRowCols = null;
	Vector vSuppliers = null;
	String strReqIndex = WI.fillTextValue("req_index");
	int iLoop = 0;
	int iCount = 1;

	vRetResult = QTN.generateQuotationPerSupplier(dbOP,request);
	if(vRetResult != null){
		vRows = (Vector)vRetResult.elementAt(0);				
		vColumns = (Vector)vRetResult.elementAt(1);				
	}
%>	
<form name="form_">
  <%if(vRows != null && vRows.size() > 0 && vColumns != null && vColumns.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="23" colspan="5" align="center" class="thinborder"><strong>LIST 
        OF REQUISITION ITEM(S) WITH QUOTATION</strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="26" colspan="2" class="thinborder">&nbsp;</td>
      <%for(int iCol = 0; vColumns.size() > iCol; iCol+=2) {%>
      <td colspan="3" align="center" class="thinborder"><%=(String)vColumns.elementAt(iCol)%></td>
		  <%}%>
		</tr>
    <tr>
      <td width="25%" align="center" class="thinborder"><font size="1"><strong>ITEM 
      / PARTICULARS / DESCRIPTION </strong></font></td> 
      <td width="12%" height="26" align="center" class="thinborder"><font size="1"><strong>QTY</strong></font> / <font size="1"><strong>UNIT</strong></font></td>
	  <%for(int iCol = 0; vColumns.size() > iCol; iCol+=2) {%>
      <td align="center" class="thinborder"><font size="1"><strong>REG PRI </strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DISC PRI </strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>TOTAL AMT</strong></font></td>
	    <%}%>
    </tr>
    <%
	int j = 0;
	for(iLoop = 0,iCount = 1;iLoop < vRows.size();iLoop+=6,++iCount){
		vRowCols = (Vector) vRows.elementAt(iLoop+5);
	%>
    <tr>
      <td class="thinborder"><%=(String)vRows.elementAt(iLoop)%> / <%=(String)vRows.elementAt(iLoop+1)%></td> 
      <td height="25" class="thinborder"><%=(String)vRows.elementAt(iLoop+2)%> <%=(String)vRows.elementAt(iLoop+3)%></td>
	  <%for(j = 0;j < vRowCols.size(); j+=3){%>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder">&nbsp;</td>	    
	    <%}%>
		</tr>
    <%}%>
  </table>
  <%}// end if(vRows != null && vRows.size() > 0 && vColum..%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
