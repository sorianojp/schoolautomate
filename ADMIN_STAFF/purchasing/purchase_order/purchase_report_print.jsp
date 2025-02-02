<%@ page language="java" import="utility.*,purchasing.PO,purchasing.Requisition,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();		
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
 
<body onLoad="javascript:window.print();">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-PURCHASE ORDER"),"0"));
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
								"Admin/staff-PURCHASING-PURCHASE ORDER-Approved Requests","purchase_report.jsp");
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
		
	Requisition REQ = new Requisition();
	PO PO = new PO();
	Vector vRetResult = null;
 	int iSearch = 0;
	int i = 0;
 	String[] astrSupplyType = {"Non-Supplies / Equipmment","Supplies","Chemical","Computers/Parts"};	
	 vRetResult = PO.searchItemsOrdered(dbOP,request);
	
	boolean bolPageBreak = false;
	double dPageTotal = 0d;
	double dGrandTotal = 0d;
	double dTemp = 0d;
	if (vRetResult != null) {	
	int iPage = 1; 
	int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size())/(7*iMaxRecPerPage);	
	if((vRetResult.size() % (7*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	 	dPageTotal = 0d;		
%>
<form name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <%if(WI.fillTextValue("is_supply").length() > 0){%>
		<tr>
      <td height="22">Inventory Type : </td>
      <td>&nbsp;<%=astrSupplyType[Integer.parseInt(WI.fillTextValue("is_supply"))]%></td>
    </tr>
		<%}%>		
    <tr>
      <td height="22">Category : </td>
      <td>&nbsp;<%=WI.getStrValue(WI.fillTextValue("category_name"),"ALL")%></td>
    </tr>		
		<%if(WI.fillTextValue("po_date_fr").length() > 0){%>
    <tr>
      <td height="22">Date : </td>
      <td>&nbsp;<%=WI.fillTextValue("po_date_fr")%><%=WI.getStrValue(WI.fillTextValue("po_date_to")," - ","","")%></td>
    </tr>
		<%}%>
    <tr>
      <td width="20%">&nbsp;</td>
      <td width="80%">&nbsp;</td>
    </tr>		
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  
    <tr>
      <td width="100%" height="25" colspan="2" align="center"class="thinborderTOPLEFTRIGHT"><strong>LIST 
          OF PURCHASED ITEMS</strong></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="47%" align="center" class="thinborder"><strong>ITEM DESCRIPTION </strong></td>
      <td width="17%" align="center" class="thinborder"><strong>SUPPLIES</strong></td> 
      <td width="14%" height="21" align="center" class="thinborder"><strong>PO NO.</strong></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>UNIT 
          PRICE</strong></font></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong><strong>TOTAL 
          PRICE</strong></strong></font></td>
    </tr>
    <% 
		for(iCount = 0; iNumRec<vRetResult.size(); iNumRec+=7,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>	
    <tr>
      <td valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i)%>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"/","","")%></font></td>
      <td valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%> <%=(String)vRetResult.elementAt(i+3)%></font></td> 
      <td height="25" valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
			%>
      <td align="right" valign="top" class="thinborder"><font size="1"><%=strTemp%></font></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+6);
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dPageTotal += dTemp;
				dGrandTotal += dTemp;
				strTemp = CommonUtil.formatFloat(dTemp,true);				
			%>			
      <td align="right" valign="top" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
    </tr>
		<%}%>
    <tr>
      <td height="25" colspan="4" align="right" valign="top" class="thinborder"><strong>Page Total : </strong></td>
      <td align="right" valign="top" class="thinborder"><strong><%=CommonUtil.formatFloat(dPageTotal,true)%></strong>&nbsp;</td>
    </tr>  

  </table>  
	<%if (iNumRec >= vRetResult.size()){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	  <tr>
	    <td width="14%" align="right" valign="top">&nbsp;</td>
	    <td height="18" colspan="4" align="right" valign="top">&nbsp;</td>
	    <td align="right" valign="top">&nbsp;</td>
    </tr>
	  <tr>
	    <td align="right">&nbsp;</td>
      <td height="25" colspan="4" align="right"><strong>Grand Total : </strong></td>
      <td width="13%" align="right"><strong><%=CommonUtil.formatFloat(dGrandTotal,true)%></strong>&nbsp;</td>
    </tr>
	  <tr>
	    <td align="right" valign="top">&nbsp;</td>
	    <td height="18" colspan="4" align="right" valign="top">&nbsp;</td>
	    <td align="right" valign="top">&nbsp;</td>
    </tr>
	  <tr>
	    <td>Prepared by :</td>
	    <td height="20" colspan="4"><%=WI.fillTextValue("prepared_by")%></td>
	    <td align="right" valign="top">&nbsp;</td>
    </tr>
	  <tr>
	    <td valign="bottom">Conforme :</td>
	    <td height="34" colspan="4" valign="bottom"><%=WI.fillTextValue("conforme")%></td>
	    <td align="right" valign="top">&nbsp;</td>
    </tr>   		  		
  </table>
	<%}%>	
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>	
  <!-- all hidden fields go here -->
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>