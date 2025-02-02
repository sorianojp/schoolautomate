<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>

div.requisition_no{
    display:block;   
	width:13%;
    position:absolute;
    left:100;
	top:50;  
	background:#FFFFFF;   
  }

 div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:50;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFFFFF;
   
  }

TD.thinborderBottom {    
  border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborder {    
  border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderTOP {    
  border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}
TD.thinborderTOPLEFT {    
  border-top: solid 1px #000000;
  border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderLEFTRIGHT {    
  border-right: solid 1px #000000;
  border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}


TD.thinborderTOPRIGHT {    
  border-top: solid 1px #000000;
  border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderTOPLEFTRIGHT {    
  border-top: solid 1px #000000;
  border-right: solid 1px #000000;
  border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderLEFT {    
  border-left: solid 1px #000000;  
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderRIGHT {    
  border-right: solid 1px #000000;  
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderRIGHTBOTTOM {    
  border-right: solid 1px #000000;  
  border-bottom: solid 1px #000000;  
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderRIGHTBOTTOMLEFT {    
  border-right: solid 1px #000000;  
  border-bottom: solid 1px #000000;  
   border-left: solid 1px #000000;  
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}

TD.NoBorder {    
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}
 
TABLE.thinborder {    
  border-top: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}

TABLE.NoBorder {    
	font-family: Verdana, Geneva, Helvetica, sans-serif;
	font-size: 11px;
}

</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,purchasing.Delivery,purchasing.Supplier,java.util.Vector" %>
<%
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;	
		
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-DELIVERY"),"0"));
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
								"Admin/staff-PURCHASING-DELIVERY-View delivery Status","delivery_status_view.jsp");
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
	

	
	
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	    
	Delivery DEL = new Delivery();	
	String strBorder = "";
	String strBorderBottom = "";
	boolean bolPrePrinted = WI.fillTextValue("is_pre_printed").equals("1");
	int iNumRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	
	if(bolPrePrinted){
		strBorder = "NoBorder";
		strBorderBottom = "NoBorder";		
	}else{
		strBorder = "thinborder";
		strBorderBottom = "thinborderBottom";	
	}

	Vector vDelInfo = null;
	Vector vRetResult = null;

 	int iCount = 1;
 
	vRetResult = DEL.getDeliveryInfo(dbOP,request, WI.fillTextValue("delivery_index"),false);
  	if(vRetResult != null && vRetResult.size() > 0)
		vDelInfo = (Vector) vRetResult.elementAt(0);
%>	
<form name="form_" method="post" action="./delivery_details_print_vma.jsp">
  <%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> and VMA TRAINING CENTER</strong><br>
	  <em>(formerly Visayan Maritime Academy)</em><br>
<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
<%=SchoolInformation.getAddressLine2(dbOP,false,false)%><br><br>
	PROPERTY CUSTODIAN<br><br>RECEIVING REPORT
</td>
    </tr>
    <tr>
      <td height="25" colspan="4" align="center">&nbsp;</td>
    </tr>
    <!--<tr>
      <td width="24%" height="25">&nbsp;</td>
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "RECEIVING REPORT";
			%>		
      <td width="52%" align="center"><%=strTemp%></td>
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "RR No.";
				strTemp = "";
			%>			
      <td width="10%" >&nbsp;<%=strTemp%></td>
	  <%	  
//	  strTemp = (String)vDelInfo.elementAt(1);	
	  strTemp = "";  

	  
	 // strErrMsg = strBorderBottom;
	  strErrMsg = "";
	  %>
      <td width="14%" valign="bottom" class=<%=strErrMsg%>><strong>&nbsp;<%=strTemp%></strong></td>
    </tr>-->
	</table>	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="bottom" width="43%" class="<%=strBorderBottom%>"><%=(String)vDelInfo.elementAt(6)%></td>
		<td valign="bottom" width="14%">&nbsp;</td>
		<td valign="bottom" width="8%">Date</td>
		<td valign="bottom" colspan="3" class="<%=strBorderBottom%>">: <%=(String)vDelInfo.elementAt(2)%></td>
		</tr>
	<tr>
	    <td valign="top" align="center"><strong>Supplier</strong></td>
	    <td>&nbsp;</td>
	    <td colspan="2">&nbsp;</td>
	    <td colspan="2">&nbsp;</td>
	</tr>
	
	<tr>
		<td height="20" valign="bottom" width="43%" class="<%=strBorderBottom%>"><%=(String)vDelInfo.elementAt(7)%></td>
		<td width="14%">&nbsp;</td>
		<td valign="bottom" colspan="2">Delivery Receipt No</td>
		<td colspan="2" valign="bottom" class="<%=strBorderBottom%>">: <%=(String)vDelInfo.elementAt(3)%></td>
	</tr>
	<tr>
	    <td valign="top" align="center">Address</td>
	    <td>&nbsp;</td>
	    <td colspan="2">&nbsp;</td>
	    <td colspan="2">&nbsp;</td>
	</tr>
	
	<tr>
		<td height="25" colspan="2">&nbsp;</td>
		<td valign="bottom" colspan="2">Purchase Order No</td>
		<td colspan="2" valign="bottom" class="<%=strBorderBottom%>">: <%=(String)vDelInfo.elementAt(5)%></td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td height="25">&nbsp;</td>
		<td valign="bottom">MRAQ No.</td>
		<td width="10%" valign="bottom" class="<%=strBorderBottom%>">: <%=(String)vDelInfo.elementAt(20)%></td>
		<td width="8%" valign="bottom">MR No.</td>
		<td width="17%" valign="bottom" class="<%=strBorderBottom%>">: <%=WI.fillTextValue("mr_no")%></td>
	</tr>
</table> 
  <br>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="<%=strBorder%>">
		<%if(bolPrePrinted){%>
    <tr>
      <td width="5%" height="20" align="center">&nbsp;</td>
      <td width="6%" align="center">&nbsp;</td>
      <%if(false){%><td width="12%" align="center">&nbsp;</td><%}%>
      <td align="center">&nbsp;</td>
      <%if(false){%><td width="10%" align="center">&nbsp;</td><%}%>
      <td width="10%" align="center">&nbsp;</td>
      <td width="11%" align="center">&nbsp;</td>
    </tr>
		<%}else{%>
    <tr>
      <td width="5%" height="20" align="center" class="<%=strBorder%>"><strong>QTY</strong></td>
      <td width="6%" align="center" class="<%=strBorder%>"><strong>UNIT</strong></td>
      <%if(false){%><td width="12%" align="center" class="<%=strBorder%>"><strong>CODE</strong></td><%}%>
	  <%
	 // strTemp = "ITEM / PARTICULARS / DESCRIPTION";
	  strTemp = "DESCRIPTION";
	  %>
      <td width="46%" align="center" class="<%=strBorder%>"><strong><%=strTemp%></strong></td>
      <%if(false){%><td width="10%" align="center" class="<%=strBorder%>"><strong>EXP. DATE </strong></td><%}%>
      <td width="10%" align="center" class="<%=strBorder%>"><strong>Unit Price</strong></td>
      <td width="11%" align="center" class="<%=strBorder%>"><strong>TOTAL</strong></td>
    </tr>		
		<%}%>
    <%
	iCount = 1;
	double dTotal = 0d;
	for(int i = 1;i < vRetResult.size();i+=12,++iCount){%>
    <tr>
      <td height="20" align="center" class="<%=strBorder%>"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;&nbsp;</td>
      <td align="center" class="<%=strBorder%>"><%=(String)vRetResult.elementAt(i+2)%></td>
      <%if(false){%><td class="<%=strBorder%>">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td><%}%>
      <td class="<%=strBorder%>">&nbsp;<%=(String)vRetResult.elementAt(i+3)%> / <%=(String)vRetResult.elementAt(i+4)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"(",")","")%></td>
      <%if(false){%><td class="<%=strBorder%>">&nbsp;</td><%}%>
    <%
		strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = CommonUtil.formatFloat(strTemp, true);
	%>
      <td align="right" class="<%=strBorder%>"><%=strTemp%>&nbsp;</td>
      <%
		strTemp = (String)vRetResult.elementAt(i+11);
		try{
			dTotal += Double.parseDouble(strTemp);
		}catch(Exception e){
			dTotal += 0d;
		}
		strTemp = CommonUtil.formatFloat(strTemp, true);
	  %>
      <td align="right" class="<%=strBorder%>"><%=strTemp%>&nbsp;</td>
    </tr>
    <%}
	for(;iCount < iNumRows;++iCount){%>
    <tr>
      <td height="20" align="right" class="<%=strBorder%>">&nbsp;</td>
      <td align="right" class="<%=strBorder%>">&nbsp;</td>
      <%if(false){%><td class="<%=strBorder%>">&nbsp;</td><%}%>
      <td class="<%=strBorder%>">&nbsp;</td>
      <%if(false){%><td class="<%=strBorder%>">&nbsp;</td><%}%>
      <td align="right" class="<%=strBorder%>">&nbsp;</td>
      <td align="right" class="<%=strBorder%>">&nbsp;</td>
    </tr>
    <%}%>
	<tr>
      <td height="20" align="right" class="<%=strBorder%>">&nbsp;</td>
      <td align="right" class="<%=strBorder%>">&nbsp;</td>
      <%if(false){%><td class="<%=strBorder%>">&nbsp;</td><%}%>
      <td class="<%=strBorder%>">&nbsp;</td>
      <%if(false){%><td class="<%=strBorder%>">&nbsp;</td><%}%>
      <td align="right" class="<%=strBorder%>"><strong>TOTAL</strong></td>
      <td align="right" class="<%=strBorder%>"><strong><%=CommonUtil.formatFloat(dTotal, true)%></strong></td>
    </tr>

	<tr>
	    <td width="5%">&nbsp;</td>
	    <td height="25" colspan="6">PURPOSE :</td></tr>
	<%
	int iIndexOf = 0;
	strTemp = WI.getStrValue((String)vDelInfo.elementAt(19));
	strErrMsg = strTemp;
	if(strTemp.length()  >70){
		iIndexOf = strTemp.lastIndexOf(" ");
		strErrMsg = strTemp.substring(0, iIndexOf);
		strTemp = strTemp.substring(iIndexOf+1);
	}else
		strTemp = null;
	%>
	<tr>
	    <td align="justify">&nbsp;</td>
		<td valign="bottom" align="justify" height="25" colspan="6"><div  style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strErrMsg)%></div> </td>
	</tr>	
	<tr>
	    <td align="justify">&nbsp;</td>
		<td valign="bottom" align="justify" height="25" colspan="6"><div  style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp)%></div></td>
	</tr>
</table>
<br><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td class="thinborderTOPLEFTRIGHT" height="25" width="33%"> &nbsp; &nbsp; Received by:</td>
		<td class="thinborderTOPRIGHT"> &nbsp; &nbsp; Checked and Inspected by:</td>
		<td width="33%" class="thinborderTOPRIGHT"> &nbsp; &nbsp; Noted by:</td>
	</tr>
	
	
	<tr>
		<td valign="bottom" class="thinborderLEFTRIGHT" height="40" align="center"><div style="border-bottom:solid 1px #000000; width:80%;"></div>Warehouseman</td>
		<td class="thinborderRIGHT"  valign="bottom" align="center" ><div style="border-bottom:solid 1px #000000; width:80%;"></div>Property Custodian</td>
		<td valign="bottom" class="thinborderRIGHT" height="40" align="center"><div style="border-bottom:solid 1px #000000; width:80%;"></div>Administrative Officer</td>
	</tr>
	<tr>
	    <td valign="bottom" class="thinborderRIGHTBOTTOMLEFT" height="20" align="center">&nbsp;</td>
	    <td class="thinborderRIGHTBOTTOM">&nbsp;</td>
	    <td class="thinborderRIGHTBOTTOM" valign="bottom" height="20" align="center">&nbsp;</td>
	    </tr>
</table>


<div id="processing" class="processing">
<table cellpadding="0" cellspacing="0" border="0" Width="100%" style="border:solid 1px #000000;">
	<tr>
		<td>Form ID.</td>
		<td>: Property 0022</td>
	</tr>
	<tr>
		<td>Rev. Number</td>
		<td>: 01</td>
	</tr>
	<tr>
		<td>Rev. Date</td>
		<td>: 09.01.06</td>
	</tr>
</table>
</div>
<div id="requisition_no" class="requisition_no">
<table cellpadding="0" cellspacing="0" border="0" Width="100%">	
	<tr>
		<td width="100%"><div style="border-bottom: solid 1px #000000;"><%=WI.getStrValue(WI.fillTextValue("mr_no"),"&nbsp;")%></div></td>		
	</tr>
</table>
</div>
		
	<%}%>
  <!-- all hidden fields go here -->
	<input type="hidden" name="is_pre_printed" value="<%=WI.fillTextValue("is_pre_printed")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>