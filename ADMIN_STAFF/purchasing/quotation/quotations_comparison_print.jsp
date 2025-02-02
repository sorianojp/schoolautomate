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
<style>
TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
}
TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBottom {
  border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
 }

</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<%
    //authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-QUOTATION"),"0"));
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
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"PURCHASING-QUOTATION","quotations_comparison_print.jsp");
	Quotation QTN = new Quotation();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vColumns = null;
	Vector vRows = null;
	Vector vRowCols = null;
	Vector vSuppliers = null;
	String strErrMsg = null;
	String strTemp = null;
	String strSchCode = dbOP.getSchoolIndex();
	String strInfoIndex = WI.fillTextValue("info_index");
	int iLoop = 0;
	int iCount = 0;	
		vReqInfo = QTN.operateOnReqInfoQtn(dbOP,request);		
		if(vReqInfo == null)
			strErrMsg = QTN.getErrMsg();
		else{
			strInfoIndex = (String)vReqInfo.elementAt(0);//requisition_index
			vSuppliers = QTN.showQTNSuppliers(dbOP, strInfoIndex);			
		}
		
		if(WI.fillTextValue("supplier1").length() > 0 || 
		   WI.fillTextValue("supplier2").length() > 0 || 
		   WI.fillTextValue("supplier3").length() > 0){
			vRetResult = QTN.generateQuotationPerSupplier(dbOP,request);
			if(vRetResult == null)
				strErrMsg = QTN.getErrMsg();
			else{
				vRows = (Vector)vRetResult.elementAt(0);				
				vColumns = (Vector)vRetResult.elementAt(1);				
			}
		}	
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="19" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <%if(vRows != null && vRows.size() > 0 && vColumns != null && vColumns.size() > 0){
  double[] dColTotal= new double[vColumns.size()];
  %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
			strTemp = (String) vReqInfo.elementAt(6);
			strTemp += WI.getStrValue(WI.fillTextValue("remarks"),"<br>","","");
		%>
    <tr>
      <td>&nbsp;<%=strTemp%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="23" colspan="5" align="center" class="thinborder"><strong><font color="#000000">PRICE COMPARISON </font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
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
      <td width="12%" height="22" align="center" class="thinborder"><font size="1"><strong>QTY</strong></font> / <font size="1"><strong>UNIT</strong></font></td>
	  <%for(int iCol = 0; vColumns.size() > iCol; iCol+=2) {
	   dColTotal[iCol] = 0;
	  %>
      <td align="center" class="thinborder"><font size="1"><strong>REG PRI </strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DISC PRI </strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>TOTAL AMT</strong></font></td>
	  <%}%>
    </tr>
    <%
	int j = 0;
	String strTemp1 = null;
	String strTemp2 = null;
	String strTemp3 = null;
	double dTemp = 0d;
	for(iLoop = 0,iCount = 1;iLoop < vRows.size();iLoop+=6,++iCount){
		vRowCols = (Vector) vRows.elementAt(iLoop+5);
	%>
    <tr>
      <td class="thinborder"><%=(String)vRows.elementAt(iLoop)%> / <%=(String)vRows.elementAt(iLoop+1)%></td>
      <td height="20" class="thinborder"><%=(String)vRows.elementAt(iLoop+2)%> <%=(String)vRows.elementAt(iLoop+3)%></td>
      <%for(j = 0;j < vRowCols.size(); j+=3){
		  strTemp = (String)vRowCols.elementAt(j + 2);
		  strTemp = ConversionTable.replaceString(strTemp,",","");
		  dTemp = Double.parseDouble(strTemp);
		  dColTotal[(j/3)] = dColTotal[(j/3)] + dTemp;
		  
		  strTemp1 = (String)vRowCols.elementAt(j);
		  strTemp2 = (String)vRowCols.elementAt(j + 1);
		  strTemp3 = (String)vRowCols.elementAt(j + 2);
		  if(dTemp == 0){
			  strTemp1 = "-";
			  strTemp2 = "-";
			  strTemp3 = "-";
		  }
	  %>
      <td align="right" class="thinborder"><%=strTemp1%></td>
      <td align="right" class="thinborder"><%=strTemp2%></td>
      <td align="right" class="thinborder"><%=strTemp3%></td>
	  <%}%>
    </tr>
    <%}%>	
    <tr>
      <td height="20" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
	  <%for(j = 0;j < vRowCols.size(); j+=3){%>		
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
	  <%}%>
    </tr>
    <tr>
      <td height="20" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
	  <%for(j = 0;j < vRowCols.size(); j+=3){%>		
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
	  <%}%>
    </tr>
    <tr>
      <td height="20" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <%for(j = 0;j < vRowCols.size(); j+=3){%>		
	  <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
	  <%}%>
    </tr>
    <tr>
      <td class="thinborder">&nbsp;</td>
      <td height="20" class="thinborder">&nbsp;</td>
      <%for(j = 0;j < vRowCols.size(); j+=3){%>		
	  <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>	  
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dColTotal[(j/3)],true)%></td>	  
	  <%}%>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="38" valign="bottom">
			<strong>Prepared by</strong> :</td>
      <td height="38" valign="bottom" class="thinborderBottom">&nbsp;<%=request.getSession(false).getAttribute("first_name")%></td>
      <td height="38" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
			<%
				if(strSchCode.startsWith("UDMC"))
					//strTemp = CommonUtil.getName(dbOP,"edita",1);
					strTemp = "Mrs. Edita F. Enatsu";
				else
					strTemp = "";
			%>		
      <td width="15%" height="36" valign="bottom"><u></u><strong>Authorized by : </strong></td>
      <td width="32%" height="36" valign="bottom" class="thinborderBottom"><strong>&nbsp;</strong><%=strTemp%></td>
      <td width="53%" height="36" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" valign="bottom">&nbsp;</td>
      <td height="18" align="center" valign="bottom">Executive  Vice-President/Treasurer</td>
      <td height="18" valign="bottom">&nbsp;</td>
    </tr>
  </table>
  <%}//if((vRows != null && vRows.size() > 0 && vColumns != null && vColumns.size() > 0))%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="19" colspan="5">&nbsp;</td>
    </tr>
  </table>  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>