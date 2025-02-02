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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<body onLoad="window.print()">
<%	
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	double dTotalAmount = 0d;
	double dGrandTotal = 0d;
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-UPDATE QUOTATION STATUS-Update QUOTATION Status","quotation_request_update_print.jsp");
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
	Requisition REQ = new Requisition();
	Vector vRetResult = null;
	Vector vReqInfo = null;
	Vector vReqItems = null;	
	Vector vAddtlCost = null;
	Vector vReqItemsQtn = null;
	boolean bolIsApproved = false;
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strReqIndex = WI.fillTextValue("req_index");
	String strHasCredited = WI.fillTextValue("has_credited");
	String strSchCode = dbOP.getSchoolIndex();
	String strTemp1 = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strStatus = null;
	int iLoop = 0;
	int iCount = 0;
	
	vReqInfo = QTN.operateOnReqInfoQtn(dbOP,request);
	if(vReqInfo != null && vReqInfo.size() > 1){		
		if (vReqInfo.elementAt(0) != null){						
			strReqIndex = (String)vReqInfo.elementAt(0);
		}		
		vRetResult = QTN.operateOnReqItemsQtn(dbOP, request, 4, strReqIndex);
		if(vRetResult == null)
			strErrMsg = QTN.getErrMsg();
		else{
			vReqItems = (Vector)vRetResult.elementAt(0);
			vReqItemsQtn = (Vector)vRetResult.elementAt(1);				
		}
		vAddtlCost = QTN.operateOnReqItemsQtn(dbOP,request,4,strReqIndex);		
	}
	
//	vAddtlCost = QTN.operateOnReqItemsQtn(dbOP,request,4,strReqIndex);
	
%>	
<form name="form_" method="post" action="quotation_request_update_print.jsp">
  <%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td align="center" width="27%"><div align="right">&nbsp; 
          <%if(strSchCode.startsWith("CPU")){%>
          <img src="../../../images/logo/CPU.gif" width="70" height="70" border="0"> 
          <%}%>
        </div></td>
      <td height="25" colspan="2" width="46%"><div align="center"> <strong> <%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <br>
          <font size="+2"><strong>CANVASS FORM</strong></font></div></td>
      <td align="center" width="27%"><div align="right">&nbsp;</div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="20%"><font size="1">Requisition No.</font></td>
      <td width="26%"><strong><font size="1"><%=WI.fillTextValue("req_no")%></font></strong></td>
      <td width="20%"><font size="1">Requested By</font></td>
      <td width="31%"><strong><font size="1"><%=(String)vReqInfo.elementAt(2)%></font></strong></td>
    </tr>
  </table>
  <%if(vReqItems != null && vReqItems.size() > 0){%>  
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
      <td width="32%" class="thinborder"><div align="center"><strong>PARTICULARS/ITEM 
          DESCRIPTION</strong></div></td>
    </tr>
    <%for(iLoop = 0,iCount = 1;iLoop < vReqItems.size();iLoop += 7,++iCount){%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=vReqItems.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+4)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="5" class="thinborder"><div align="left"> <strong>TOTAL 
          ITEM(S) : <%=iCount-1%></strong></div></td>
    </tr>
  </table>
  <%}%>
  <%if(vReqItemsQtn != null && vReqItemsQtn.size() > 0){%>
  <br>
  <%
  if(strHasCredited.length() > 0){%>
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
      <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+4),(String)vReqItemsQtn.elementAt(iLoop+14))%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+13),"(",")","")%> 
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
			 strTemp3 += (String)vReqItemsQtn.elementAt(iLoop + 11) + "<br>";%>
          <br>
          <%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop + 17 + 4),"","","(uncredited)")%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+17 + 13),"(",")","")%> 
          <%iLoop += 17;}%>
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
      <td class="thinborder"><div align="right"><%=strTemp2 + (String)vReqItemsQtn.elementAt(iLoop+8)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="10" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount-1%></strong></div></td>
    </tr>
  </table>
  <%}// end if strHasCredited.length() > 0%>
  <%}// end for vReqItemsQtn != null %>
  <br>
  <%if(vReqItemsQtn != null && iLoop < vReqItemsQtn.size()){%>
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
	for(iCount = 1;iLoop < vReqItemsQtn.size();iLoop+=17,++iCount){
	%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=iCount%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItemsQtn.elementAt(iLoop)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItemsQtn.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+4),(String)vReqItemsQtn.elementAt(iLoop+14))%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+13),"(",")","")%> 
          <%
			strTemp1 = "";
			strTemp2 = "";		
			strTemp3 = "";
			strErrMsg = "";
			for(; (iLoop + 17) < vReqItemsQtn.size() ;){
			 if(!(((String)vReqItemsQtn.elementAt(iLoop+9)).equals((String)vReqItemsQtn.elementAt(iLoop + 24))))
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
			 strTemp3 += (String)vReqItemsQtn.elementAt(iLoop + 11) + "<br>";%>
          <br>
          <%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop + 17 + 4),"","",(String)vReqItemsQtn.elementAt(iLoop + 17 + 14))%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+14 + 13),"(",")","")%> 
          <%iLoop += 17;}%>
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
      <td class="thinborder"><div align="right"><%=strTemp2 + (String)vReqItemsQtn.elementAt(iLoop+8)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="10" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount-1%></strong></div></td>
    </tr>
  </table>
  <%}// end getting items from non credited suppliers%>
  <%if(vAddtlCost != null && vAddtlCost.size() > 2){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="3" class="thinborder"><div align="center"><strong>ADDITIONAL 
          COST FOR THIS REQUISITION</strong></div></td>
    </tr>
    <tr> 
      <td width="35%" class="thinborder"><div align="center"><strong>SUPPLIER 
          NAME</strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>COST NAME 
          </strong></div></td>
      <td width="28%" height="25" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%
	for(iLoop = 2;iLoop < vAddtlCost.size();iLoop+=5){%>
    <tr> 
      <td  height="25" class="thinborder"><%=vAddtlCost.elementAt(iLoop+2)%> <%/*strTemp1 = "";
	  	strTemp2 = "";
	  for(;(iLoop+3+5) < vRetResult.size();){
	  		if(!((String)vRetResult.elementAt(iLoop+1)).equals((String)vRetResult.elementAt(iLoop+1+5)))
	  			break;
			strTemp1 += (String)vRetResult.elementAt(iLoop+3)+"<br>";
			strTemp2 += (String)vRetResult.elementAt(iLoop+4)+"<br>";
			iLoop+=5;
	    }*/%> </td>
      <td class="thinborder"><%=/*strTemp1+*/(String)vAddtlCost.elementAt(iLoop+3)%></td>
      <td class="thinborder"><div align="right"><%=/*strTemp2+*/(String)vAddtlCost.elementAt(iLoop+4)%></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="17%" height="25"><strong>Canvassed By  : </strong>&nbsp;</td>
      <td width="30%" class="thinborderBottom">&nbsp;</td>
      <td width="15%" align="center">&nbsp;</td>
      <td width="38%" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderBottom">&nbsp;</td>
      <td style="font-weight:bold" align="center">&nbsp;</td>
      <td style="font-weight:bold" align="center">Authorized By </td>
    </tr>
  </table>
  <%}%>
  
  <!-- all hidden fields go here -->
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
  <input type="hidden" name="req_index" value="<%=strReqIndex%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
