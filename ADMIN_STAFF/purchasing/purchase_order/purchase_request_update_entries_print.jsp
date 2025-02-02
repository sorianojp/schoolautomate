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
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,purchasing.Requisition,purchasing.PO,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

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
	PO PO = new PO();	
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
	
	
	vReqInfo = PO.operateOnReqInfo(dbOP,request,3);
	if(vReqInfo == null)
		strErrMsg = PO.getErrMsg();
	else{				
		vReqPO = PO.operateOnPOInfo(dbOP,request,4,(String)vReqInfo.elementAt(1));
		if(vReqPO != null){	
			vReqItems = PO.operateOnPOItems(dbOP,request,4);
			if(vReqItems == null)
				strErrMsg = PO.getErrMsg();
			vReqItemsQtn = PO.showItemsQuoted(dbOP,request,(String)vReqInfo.elementAt(1));
			if(vReqItemsQtn == null)
				strErrMsg = PO.getErrMsg();	
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
      <td><font size="1">PO No.</font></td>
      <td><strong><font size="1"><%=(String)vReqPO.elementAt(1)%></font></strong></td>
      <td><font size="1">PO Date</font></td>
      <td><strong><font size="1"><%=(String)vReqPO.elementAt(2)%></font></strong></td>
    </tr>
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
      <td height="22">&nbsp;</td>
      <td><font size="1">Office</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(10)%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></font></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="2">&nbsp;</td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></font></strong></td>
    </tr>
    <%}%>
  </table>
  <%if(vReqItemsQtn != null && vReqItemsQtn.size() > 1){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="center"><strong>LIST 
          OF PO ITEM(S) WITH QUOTATION</strong></div></td>
    </tr>
    <tr> 
      <td width="5%" height="26" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="4%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="4%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>PARTICULARS 
          / ITEM DESCRIPTION </strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="21%" class="thinborder"><div align="center"><strong>PRICE QUOTED</strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong>DISCOUNT</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>FINAL PRICE</strong></div></td>
    </tr>
    <%for(iLoop = 0,iCount = 1;iLoop < vReqItemsQtn.size();iLoop+=12,++iCount){%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItemsQtn.elementAt(iLoop)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItemsQtn.elementAt(iLoop+4)%> 
          <%
			strTemp1 = "";
			strTemp2 = "";
			strErrMsg = "";
			for(; (iLoop + 12) < vReqItemsQtn.size() ;){
			 if(!(((String)vReqItemsQtn.elementAt(iLoop+9)).equals((String)vReqItemsQtn.elementAt(iLoop + 21))))
					break;
			 if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false) + "% <br>&nbsp;";
				
          	 }else{
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true) + 
				astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+11))]+"<br>&nbsp;";
          	 }
			 strErrMsg += (String)vReqItemsQtn.elementAt(iLoop+5) + 
			 			   astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]+ "<br>&nbsp;";
			 strTemp2 += (String)vReqItemsQtn.elementAt(iLoop + 8) + "<br>&nbsp;";%>
          <br>
          <%=(String)vReqItemsQtn.elementAt(iLoop + 12 + 4)%> 
          <%iLoop += 12;}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=strErrMsg + (String)vReqItemsQtn.elementAt(iLoop+5)+
	  		astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]%></div></td>
      <td class="thinborder"><div align="right"> <%=strTemp1%> 
          <%if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false)%>% 
          <%}else{%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true)+
		  astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+11))]%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=strTemp2 + (String)vReqItemsQtn.elementAt(iLoop+8)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%">
  	<tr>
		<td>&nbsp;</td>
	</tr>
  </table>
  <%}if(vReqItems != null && vReqItems.size() > 3){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" class="thinborder"><div align="center"><strong>LIST 
          OF PO ITEM(S)</strong></div></td>
    </tr>
    <tr> 
      <td width="6%"  height="25"  class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/ITEM 
          DESCRIPTION </strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT</strong></div></td>
    </tr>
    <%for(iLoop = 0,iCount = 1;iLoop < vReqItems.size();iLoop+=12, iCount++){%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+5)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+1)%> / 
	  <%=(String)vReqItems.elementAt(iLoop+2)%> <%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"(",")","")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right">
	  <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td  height="25" colspan="6"  class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) :&nbsp;&nbsp;<%=iCount-1%></strong></div></td>
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
</body>
</html>
<%
dbOP.cleanUP();
%>
