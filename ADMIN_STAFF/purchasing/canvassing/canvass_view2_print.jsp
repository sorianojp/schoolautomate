<%@ page language="java" import="utility.*,purchasing.Quotation,java.util.Vector" %>
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
								"Admin/staff-PURCHASING-CANVASSING-Canvassing View","canvass_view.jsp");
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
	Quotation QTN = new Quotation();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vColumns = null;
	Vector vRows = null;
	Vector vRowCols = null;
	String strErrMsg = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};
	String[] astrReqType = {"New","Replacement"};
	String strInfoIndex = WI.fillTextValue("info_index");
	String strTemp  = null;
	String strTemp2 = null;
	String strTemp3 = null;
	int iLoop = 0;
	int iCount = 0;
	boolean bolHasSupplier = false;
	String[] astrSuppliers = new String[5];
	double dTemp = 0d;
	
	int iTemp = 1;
	int j = 0;
	for(iLoop = 0; iLoop < 5; iLoop++){
		strTemp = WI.fillTextValue("supplier"+(iLoop+1));		
		for(j = 1; j < 6;j++){
			strTemp2 = WI.fillTextValue("supplier"+j);
			if(strTemp.equals(strTemp2))
				continue;
				
			if(astrSuppliers[iLoop] == null || astrSuppliers[iLoop].length() == 0)
				astrSuppliers[iLoop] = strTemp2;
			else
				astrSuppliers[iLoop] = astrSuppliers[iLoop] + WI.getStrValue(strTemp2,",","","");
		}
	}
	
	int iDefault = 0;
	String strSchCode = dbOP.getSchoolIndex();
	
		vReqInfo = QTN.operateOnReqInfoQtn(dbOP,request, WI.fillTextValue("canvass_no"));		
		for(int i = 1; i < 6; i++){
			if(WI.fillTextValue("supplier"+i).length() > 0){
				bolHasSupplier = true;
				break;
			}				
		}		
		if(bolHasSupplier){
			vRetResult = QTN.generateQuotationPerSupplier(dbOP,request, WI.fillTextValue("canvass_no"));
			if(vRetResult != null){
				vRows = (Vector)vRetResult.elementAt(0);				
				vColumns = (Vector)vRetResult.elementAt(1);				
			}
		}		

%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <%if(vRows != null && vRows.size() > 0 && vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="23" colspan="5"><strong>CANVASS FORM</strong></td>
    </tr>
    <tr>
      <td height="23" colspan="5"><%=(String)vReqInfo.elementAt(6)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td class="thinborder">&nbsp;</td>
      <td height="26" class="thinborder">&nbsp;</td>
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
	for(iLoop = 0,iCount = 1;iLoop < vRows.size();iLoop+=6,++iCount){
		vRowCols = (Vector) vRows.elementAt(iLoop+5);
	%>
    <tr>
      <td class="thinborder"><%=(String)vRows.elementAt(iLoop)%> / <%=(String)vRows.elementAt(iLoop+1)%></td>
      <td height="25" class="thinborder"><%=(String)vRows.elementAt(iLoop+2)%> <%=(String)vRows.elementAt(iLoop+3)%></td>
      <%for(j = 0;j < vRowCols.size(); j+=3){
		  strTemp = (String)vRowCols.elementAt(j + 2);
		  strTemp = ConversionTable.replaceString(strTemp,",","");
		  dTemp = Double.parseDouble(strTemp);
		  
		  strTemp = (String)vRowCols.elementAt(j);
		  strTemp2 = (String)vRowCols.elementAt(j + 1);
		  strTemp3 = (String)vRowCols.elementAt(j + 2);
		  if(dTemp == 0){
			  strTemp = "&nbsp;";
			  strTemp2 = "&nbsp;";
			  strTemp3 = "&nbsp;";
		  }			
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
      <td align="right" class="thinborder"><%=strTemp2%></td>
      <td align="right" class="thinborder"><%=strTemp3%></td>
      <%}%>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}%>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
