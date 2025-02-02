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
</style>
</head>
<body bgcolor="#FFFFFF">
<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp1 = null;
	String strTemp2 = null;

//authenticate user access level	
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
	
	dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"PURCHASING-PURCHASE ORDER","purchase_request_update_entries_print.jsp");
	Requisition REQ = new Requisition();
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vReqPO = null;
	Vector vReqItemsQtn = null;
	Vector vAddtlCost = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String strTemp = null;
	int iLoop = 0;
	int iCount = 0;
	
	
	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
	if(vReqInfo == null)
		strErrMsg = REQ.getErrMsg();
	else{				

			strReqIndex = (String)vReqInfo.elementAt(0);
			vRetResult = REQ.operateOnNonPOReqItems(dbOP,request);	
			if(vRetResult != null && vRetResult.size() > 0)	{
				vReqItems = (Vector) vRetResult.elementAt(0);
				vSelItems = (Vector) vRetResult.elementAt(1);
			}
		if(((vReqItems == null || vReqItems.size() < 1) && (vSelItems == null || vSelItems.size() == 0)) && strErrMsg == null)
			strErrMsg = "No item encoded for this Requisition.";					
		
		}
		vAddtlCost = PO.showAdditionalCost(dbOP,(String)vReqInfo.elementAt(1));
			if(vAddtlCost == null)
				strErrMsg = PO.getErrMsg();	
	}
		
/*	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
	if(vReqInfo == null)
		strErrMsg = REQ.getErrMsg();	
	
	vReqPO = PO.operateOnReqInfoPO(dbOP,request,3,(String)vReqInfo.elementAt(0));
	if(vReqPO == null)
		strErrMsg = PO.getErrMsg();
	
	vReqItems = PO.operateOnReqItemsPO(dbOP,request,4,(String)vReqInfo.elementAt(0));			
	if(vReqItems == null){
		vReqItems = REQ.operateOnReqItems(dbOP,request,4);
		if(vReqItems == null)
			strErrMsg = REQ.getErrMsg();				
	}	*/
%>
<form name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
	<tr> 
    <td height="25" colspan="2"><div align="center"> 
            <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
        </div></td>
  </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="22">&nbsp;</td>
      <td><font size="1">Requisition No.</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(13)%></font></strong></td>
      <td><font size="1">Requested By</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(3)%></font></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="22">&nbsp;</td>
      <td width="20%"><font size="1">Request Type</font></td>
      <td width="26%"><font size="1"><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(2))]%></strong></font></td>
      <td width="20%"><font size="1">Purpose/Job</font></td>
      <td width="31%"><strong><font size="1"><%=(String)vReqInfo.elementAt(6)%></font></strong></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td><font size="1">Requisition Status</font></td>
      <td><strong><font size="1"><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(11))]%></font></strong></td>
      <td><font size="1">Requisition Date</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(8)%></font></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(4)).equals("0")){%>
    <tr> 
      <td height="23">&nbsp;</td>
      <td><font size="1">Non-Acad. Office/Dept</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(10)%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></font></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="2">&nbsp;</td>
      <td><font size="1">College/Dept</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></font></strong></td>
    </tr>
    <%}%>
  </table>
  <%if(vReqItems != null && vReqItems.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="10" class="thinborder"><div align="center"><font color="#000000"><strong>REQUISITION 
          ITEMS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="7%"  height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="34%" class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/DESCRIPTION 
          </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong>BRAND</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <% iRowCount = 0;
	for(iLoop = 0;iLoop < vReqItems.size();iLoop+=10,++iRowCount){
		
	%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+10)/10%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+5)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+1)%> 
          / <%=(String)vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+3),"&nbsp;")%></div></td>
      <td class="thinborder"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"> 
          <% //if(vReqItems.elementAt(iLoop+7) != null){
		  //dTotalAmount += Double.parseDouble(ConversionTable.replaceString((String)vReqItems.elementAt(iLoop+7),",",""));	  }
	      %>
          <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
          &nbsp; 
          <%}else{%>
          <%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%> 
          <%}%>
        </div></td>
    </tr>
    <%}%>
    <input type="hidden" name="row_count" value="<%=iRowCount%>">
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vReqItems.size()/9%></strong></div>
        <div align="right"></div>
        <div align="right"></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%">
  	<tr>
		<td>&nbsp;</td>
	</tr>
  </table>
  <%}%>
  <%if(vSelItems != null && vSelItems.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="10" class="thinborder"><div align="center"><font color="#000000"><strong>REQUISITION 
          ITEMS WITH SUPPLIER</strong></font></div></td>
    </tr>
    <tr> 
      <td width="7%"  height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="34%" class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/DESCRIPTION 
          </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong>BRAND</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <% iRowCount = 0;
	for(iLoop = 0;iLoop < vSelItems.size();iLoop+=10,++iRowCount){
		
	%>
    
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+10)/10%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vSelItems.elementAt(iLoop+5)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vSelItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vSelItems.elementAt(iLoop+1)%> / <%=(String)vSelItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vSelItems.elementAt(iLoop+3),"&nbsp;")%></div></td>
      <td class="thinborder"><%=WI.getStrValue((String)vSelItems.elementAt(iLoop+9),"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vSelItems.elementAt(iLoop+4),true),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"> 
          <% //if(vReqItems.elementAt(iLoop+7) != null){
		  //dTotalAmount += Double.parseDouble(ConversionTable.replaceString((String)vReqItems.elementAt(iLoop+7),",",""));	  }
	      %>
          <%if(vSelItems.elementAt(iLoop+7) == null || ((String)vSelItems.elementAt(iLoop+7)).equals("0")){%>
          &nbsp; 
          <%}else{%>
          <%=CommonUtil.formatFloat((String)vSelItems.elementAt(iLoop+7),true)%> 
          <%}%>
          
        </div></td>

    </tr>
    <%}%>
    
    <input type="hidden" name="row_count2" value="<%=iRowCount%>">
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vReqItems.size()/9%></strong></div>
        <div align="right"></div>
        <div align="right"></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" colspan="5"><div align="center"></div></td>
    </tr>
  </table>
  <%}%>
  <%if(vAddtlCost != null && vAddtlCost.size() > 2){%>
  <br>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="3" class="thinborder"><div align="center"><strong>ADDITIONAL COST FOR THIS PO</strong></div></td>
    </tr>
    <tr> 
      <td width="35%" class="thinborder"><div align="center"><strong>SUPPLIER 
               NAME</strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong>COST 
                NAME </strong></div></td>
      <td width="25%" height="25" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>     
	<%for(iLoop = 0;iLoop < vAddtlCost.size();iLoop+=5){%>     
    <tr> 
      <td class="thinborder"><%=vAddtlCost.elementAt(iLoop+2)%>
	  <%strTemp = "";
	  	strErrMsg = "";
	  for(;(iLoop+4+5) < vAddtlCost.size();){
	  		if(!((String)vAddtlCost.elementAt(iLoop+1)).equals((String)vAddtlCost.elementAt(iLoop+1+5)))
	  			break;
			strTemp += (String)vAddtlCost.elementAt(iLoop+3)+"<br>";
			strErrMsg += (String)vAddtlCost.elementAt(iLoop+4)+"<br>";
			iLoop+=5;
	    }%>
	  </td>
      <td class="thinborder"><%=strTemp+(String)vAddtlCost.elementAt(iLoop+3)%></td>
      <td height="25" class="thinborder"><div align="right"><%=strErrMsg+(String)vAddtlCost.elementAt(iLoop+4)%></div></td>
    </tr>
	<%}%>
  </table>
  <%}%>
<%}%>
</form>
<script language="JavaScript">
	window.setInterval("javascript:window.print()",0);
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
