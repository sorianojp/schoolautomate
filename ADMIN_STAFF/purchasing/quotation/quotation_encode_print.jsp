<%@ page language="java" import="utility.*,purchasing.Quotation,java.util.Vector" %>
<%	
	WebInterface WI = new WebInterface(request);
	String strSupplierIndex = WI.fillTextValue("supplier_index");
	
	
	boolean bolShowGrandTotal = true;
	
	//do not show if there are many suppliers and they select all in printing.	
	if(WI.fillTextValue("no_of_supplier").length() > 0 && strSupplierIndex.length() == 0)
		bolShowGrandTotal = false;
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
	font-size: 10px;
}
</style>
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
								"PURCHASING-QUOTATION","quotation_encode_print.jsp");
		
	Quotation QTN = new Quotation();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vReqItemsPO = null;
	Vector vReqItemsQtn = null;
	
	double dGrandTotal = 0d;
	
	String strSchCode = WI.getStrValue(dbOP.getSchoolIndex());		
	
	boolean bolIsWUP = strSchCode.startsWith("WUP");
	
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};
	String[] astrReqType = {"New","Replacement"};
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String strHasCredited = WI.fillTextValue("has_credited");
	String strErrMsg = null;
	String strTemp = null;
	String strTemp1 = null;	
	String strTemp2 = null;
	String strTemp3 = null;
	int iLoop = 0;
	int iCount = 0;
	
	vReqInfo = QTN.operateOnReqInfoQtn(dbOP,request);
	if(vReqInfo == null)
		strErrMsg = QTN.getErrMsg();
	else{
		vRetResult = QTN.operateOnReqItemsQtn(dbOP,request,4,(String)vReqInfo.elementAt(0));
		if(vRetResult == null)
			strErrMsg = QTN.getErrMsg();
		else{
			vReqItemsPO = (Vector)vRetResult.elementAt(0);
			vReqItemsQtn = (Vector)vRetResult.elementAt(1);				
		}				
	}
%>
<body onLoad="window.print()">
<% if(vRetResult != null){%>
<form name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
	<tr> 
	 <td align="center" width="27%"><div align="right">&nbsp;
	  <%if(strSchCode.startsWith("CPU")){%>
	  <img src="../../../images/logo/CPU.gif" width="70" height="70" border="0">
	  <%}%>
	  </div></td>
    <td height="25" colspan="2" width="46%"><div align="center">
            <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
			<font size="+2"><strong>CANVASS FORM</strong></font>
        </div></td>
	<td align="center" width="27%"><div align="right">&nbsp;</div></td>
  </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="20%"><font size="1">Canvassing No.</font></td>
      <td width="26%"><strong><font size="1"><%=vReqInfo.elementAt(1)%></font></strong></td>
      <td width="20%"><font size="1">Canvassing Date </font></td>
      <td width="31%"><strong><font size="1"><%=vReqInfo.elementAt(2)%></font></strong></td>
    </tr>
  </table>
  <%if(vReqItemsPO != null && vReqItemsPO.size() > 3){%>
  <table width="100%" border="0" class="thinborder" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="5" class="thinborder"><div align="center"><strong>LIST 
          OF ITEMS WITHOUT QUOTATION</strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="20" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="26%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
      <td width="32%" class="thinborder"><div align="center"><strong>PARTICULARS/ITEM DESCRIPTION</strong></div></td>
    </tr>
    <%for(iLoop = 0,iCount = 1;iLoop < vReqItemsPO.size();iLoop += 7,++iCount){%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=vReqItemsPO.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItemsPO.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItemsPO.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItemsPO.elementAt(iLoop+4)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="5" class="thinborder"><div align="left">
	  <strong>TOTAL ITEM(S) : <%=iCount-1%></strong></div></td>
    </tr>
  </table>
  <%}if(vReqItemsQtn != null && vReqItemsQtn.size() > 3){%>
  <br>
  <%if(strHasCredited.length() > 0){%>
  <table width="100%" border="0" class="thinborder" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="10" class="thinborder"><div align="center"><strong>LIST 
          OF ITEMS WITH QUOTATION FROM CREDITED SUPPLIERS</strong></div></td>
    </tr>
    <tr> 
      <td width="2%" height="20" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="2%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong>PARTICULARS 
          / ITEM DESCRIPTION </strong></div></td>
      <td width="17%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong> PRICE QUOTED</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>DISCOUNT</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT</strong></div></td>
    </tr>
    <%
	for(iLoop = 0,iCount = 1;iLoop < vReqItemsQtn.size();iLoop+=17,++iCount){
		if ((String)vReqItemsQtn.elementAt(iLoop+4) == null){
			break;
		}
	%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItemsQtn.elementAt(iLoop)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+3)%></div></td>
	  <%
	  strTemp = WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+4),(String)vReqItemsQtn.elementAt(iLoop+14));
	  %>
      <td class="thinborder"><div align="left"><%=strTemp%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+13),"(",")","")%> 
          <%
			strTemp1 = "";
			strTemp2 = "";		
			strTemp3 = "";
			strErrMsg = "";
			for(; (iLoop + 17) < vReqItemsQtn.size() ;){
			 if(!(((String)vReqItemsQtn.elementAt(iLoop+9)).equals((String)vReqItemsQtn.elementAt(iLoop + 26))))
					break;
			 if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false) + "% <br>";
				
          	 }else{
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true) +
				            astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+12))] +"<br>";
          	 }
			 strErrMsg += (String)vReqItemsQtn.elementAt(iLoop+5) + 
			 			   astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]+ "<br>";
			 strTemp2 += (String)vReqItemsQtn.elementAt(iLoop + 8) + "<br>";
			 try{
			 	strTemp = WI.getStrValue(vReqItemsQtn.elementAt(iLoop + 8));
				dGrandTotal += Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			 }catch(Exception e){
			 	dGrandTotal += 0d;
			 }
			 
			 strTemp3 += (String)vReqItemsQtn.elementAt(iLoop + 11) + "<br>";%>
          <br>
          <%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop + 17 + 4),"","","(uncredited)")%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+17 + 13),"(",")","")%> 
          <%
		  //if im here meaning there are many suppliers or many brand for 1 items
		  //which means dont show grand total
		  bolShowGrandTotal = false;
		  iLoop += 17;
		  
		  }%>
        </div></td>
      <td class="thinborder"><div align="right"><%=strErrMsg + (String)vReqItemsQtn.elementAt(iLoop+5)+
	  		astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]%></div></td>
      <td class="thinborder"><div align="right"><%=strTemp1%> 
          <%if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false)%>% 
          <%}else{%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true)+
		  	astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+12))]%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=strTemp3 + (String)vReqItemsQtn.elementAt(iLoop+11)%></div></td>
	  <%
	  try{
		strTemp = WI.getStrValue(vReqItemsQtn.elementAt(iLoop + 8));
		dGrandTotal += Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
	 }catch(Exception e){
		dGrandTotal += 0d;
	 }
	  %>
      <td class="thinborder"><div align="right"><%=strTemp2 + (String)vReqItemsQtn.elementAt(iLoop+8)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="10" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount-1%></strong></div></td>
    </tr>
  </table>
  <%}%>
  <br>
  <%if(iLoop < vReqItemsQtn.size()){%>
  <table width="100%" border="0" class="thinborder" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="10" class="thinborder"><div align="center"><strong>LIST 
          OF ITEMS WITH QUOTATION FROM UNCREDITED SUPPLIERS</strong></div></td>
    </tr>
    <tr> 
      <td width="2%" height="20" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="2%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong>PARTICULARS / ITEM DESCRIPTION </strong></div></td>
      <td width="17%" class="thinborder"><div align="center"><strong>SUPPLIER CODE </strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong> PRICE QUOTED</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>DISCOUNT</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT</strong></div></td>
    </tr>
    <%
	for(iCount = 1;iLoop < vReqItemsQtn.size();iLoop+=17,++iCount){
	%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItemsQtn.elementAt(iLoop)%></div></td>
      <td class="thinborder"><%=(String)vReqItemsQtn.elementAt(iLoop+1)%></td>
      <td class="thinborder"><%=(String)vReqItemsQtn.elementAt(iLoop+2)%></td>
      <td class="thinborder"><%=(String)vReqItemsQtn.elementAt(iLoop+3)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+4),(String)vReqItemsQtn.elementAt(iLoop+14))%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+13),"(",")","")%> 
        <%
			strTemp1 = "";
			strTemp2 = "";		
			strTemp3 = "";
			strErrMsg = "";
			for(; (iLoop + 17) < vReqItemsQtn.size() ;){
			 if(!(((String)vReqItemsQtn.elementAt(iLoop+9)).equals((String)vReqItemsQtn.elementAt(iLoop + 26))))
					break;
			 if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false) + "% <br>";
				
          	 }else{
          		strTemp1 += CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true) +
				            astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+12))] +"<br>";
          	 }
			 strErrMsg += (String)vReqItemsQtn.elementAt(iLoop+5) + 
			 			   astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]+ "<br>";
			 strTemp2 += (String)vReqItemsQtn.elementAt(iLoop + 8) + "<br>";
			
			  try{
				strTemp = WI.getStrValue(vReqItemsQtn.elementAt(iLoop + 8));
				dGrandTotal += Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
			 }catch(Exception e){
				dGrandTotal += 0d;
			 }
	  
			 strTemp3 += (String)vReqItemsQtn.elementAt(iLoop + 11) + "<br>";%>
        <br>
        <%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop + 17 + 4),"","",(String)vReqItemsQtn.elementAt(iLoop + 17 + 14))%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+17 + 13),"(",")","")%> 
        <%
		 //if im here meaning there are many suppliers or many brand for 1 items
		  //which means dont show grand total
		  bolShowGrandTotal = false;
		iLoop += 17;}%>
      </td>
      <td class="thinborder"><div align="right"><%=strErrMsg + (String)vReqItemsQtn.elementAt(iLoop+5)+
	  		astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+10))]%></div></td>
      <td class="thinborder"><div align="right"><%=strTemp1%> 
          <%if(((String)vReqItemsQtn.elementAt(iLoop+7)).equals("1")){%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),false)%>% 
          <%}else{%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vReqItemsQtn.elementAt(iLoop+6)),true)+
		  	astrQuoteUnit[Integer.parseInt((String)vReqItemsQtn.elementAt(iLoop+12))]%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=strTemp3 + (String)vReqItemsQtn.elementAt(iLoop+11)%></div></td>
	  <%
	  try{
		strTemp = WI.getStrValue(vReqItemsQtn.elementAt(iLoop + 8));
		dGrandTotal += Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
	 }catch(Exception e){
		dGrandTotal += 0d;
	 }
	  %>
      <td class="thinborder"><div align="right"><%=strTemp2 + (String)vReqItemsQtn.elementAt(iLoop+8)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="10" class="thinborder"><strong>TOTAL 
        ITEM(S) : <%=iCount-1%></strong></td>
    </tr>
  </table>
  <%}// end if(iLoop < vReqItemsQtn.size())%>
  <%}%>
  
  <%if(vRetResult.size() > 2){%>
  <br>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="3" align="center" class="thinborder"><strong>ADDITIONAL 
        COST FOR THIS QUOTATION</strong></td>
    </tr>
    <tr>
      <td width="35%" align="center" class="thinborder"><strong>SUPPLIER 
        NAME</strong></td>
      <td width="24%" align="center" class="thinborder"><strong>COST 
        NAME </strong></td>
      <td width="28%" height="25" align="center" class="thinborder"><strong>AMOUNT</strong></td>
    </tr>
	<%for(iLoop = 2;iLoop < vRetResult.size();iLoop+=5){%>
    <tr>
      <td  height="25" class="thinborder"><%=vRetResult.elementAt(iLoop+2)%>
	  <%/*strTemp1 = "";
	  	strTemp2 = "";
	  for(;(iLoop+3+5) < vRetResult.size();){
	  		if(!((String)vRetResult.elementAt(iLoop+1)).equals((String)vRetResult.elementAt(iLoop+1+5)))
	  			break;
			strTemp1 += (String)vRetResult.elementAt(iLoop+3)+"<br>";
			strTemp2 += (String)vRetResult.elementAt(iLoop+4)+"<br>";
			iLoop+=5;
	    }*/%>	  </td>
      <td class="thinborder"><%=/*strTemp1+*/(String)vRetResult.elementAt(iLoop+3)%></td>
	  <%
	  try{
		strTemp = WI.getStrValue(vRetResult.elementAt(iLoop + 4));
		dGrandTotal += Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
	 }catch(Exception e){
		dGrandTotal += 0d;
	 }
	  %>
      <td class="thinborder"><div align="right"><%=/*strTemp2+*/(String)vRetResult.elementAt(iLoop+4)%></div></td>
    </tr>
	<%}%>
  </table>
  <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="19%" height="25"><strong>CANVASSED BY : </strong>&nbsp;</td>
      <td width="25%" class="thinborderBottom">&nbsp;</td>
	  <%
	  if(bolIsWUP)
	  	strTemp = "Grand Total : "+ CommonUtil.formatFloat(dGrandTotal, true);
	  else
	  	strTemp = "&nbsp;";
		
	if(!bolShowGrandTotal)
		strTemp = "&nbsp;";
	  %>
      <td width="56%" align="right"><strong><%=strTemp%></strong></td>
    </tr>
  </table>
</form>
<%}else{%>
<script language="JavaScript">
	alert("Please re enter correct canvassing number");
</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
