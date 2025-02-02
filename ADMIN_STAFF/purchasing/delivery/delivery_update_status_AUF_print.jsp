<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>

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
	String strSchCode = dbOP.getSchoolIndex();	
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	    
	Delivery DEL = new Delivery();	
	String strBorder = "";
	String strBorderBottom = "";
	boolean bolPrePrinted = WI.fillTextValue("is_pre_printed").equals("1");
	
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
<form name="form_" method="post" action="./delivery_status_view.jsp">
  <%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4" align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br></td>
    </tr>
    <tr>
      <td height="25" colspan="4" align="center">&nbsp;</td>
    </tr>
    <tr>
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
			%>			
      <td width="10%" >&nbsp;<%=strTemp%></td>
      <td width="14%" valign="bottom" class=<%=strBorderBottom%>><strong>&nbsp;<%=(String)vDelInfo.elementAt(1)%></strong></td>
    </tr>
	</table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
    <tr> 
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "Supplier :";
			%>
      <td width="10%" height="25" valign="bottom">&nbsp;<%=strTemp%></td>
      <td height="25" colspan="2" valign="bottom" class=<%=strBorderBottom%>>&nbsp;<strong><%=(String)vDelInfo.elementAt(6)%></strong></td>
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "DATE :";
			%>			
      <td width="6%" height="25" valign="bottom">&nbsp;<%=strTemp%></td>
      <td width="11%" height="25" valign="bottom" class=<%=strBorderBottom%>><strong>&nbsp;<%=(String)vDelInfo.elementAt(2)%></strong></td>
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "P.O. NO. ";
			%>			
      <td width="10%" height="25" valign="bottom">&nbsp;<%=strTemp%></td>
      <td width="14%" height="25" valign="bottom" class=<%=strBorderBottom%>><strong>&nbsp;<%=(String)vDelInfo.elementAt(5)%></strong></td>
    </tr>
    <tr>
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "Address :";
			%>		
      <td height="25" valign="bottom">&nbsp;<%=strTemp%></td>
      <td height="25" colspan="2" valign="bottom" class=<%=strBorderBottom%>><strong>&nbsp;<%=(String)vDelInfo.elementAt(7)%></strong></td>
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "Inv. No/Del. R. No ";
			%>			
      <td height="25" colspan="2" valign="bottom">&nbsp;<%=strTemp%></td>
      <td height="25" colspan="2" valign="bottom" class=<%=strBorderBottom%>><strong>&nbsp;<%=(String)vDelInfo.elementAt(3)%></strong></td>
    </tr>
    <tr>
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "Date of Invoice/ Actual Receipt";
			%>		 
      <td height="25" colspan="2" valign="bottom">&nbsp;<%=strTemp%></td>
      <td width="31%" height="25" valign="bottom" class=<%=strBorderBottom%>><strong>&nbsp;<%=WI.getStrValue((String)vDelInfo.elementAt(4))%></strong></td>
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "Terms";
			%>			
      <td valign="bottom"><strong>&nbsp;<%=strTemp%>&nbsp;</strong></td>
      <td colspan="3" valign="bottom" class=<%=strBorderBottom%>>&nbsp;</td>
    </tr>
    <tr>
      <td height="14" colspan="7" valign="bottom">&nbsp;</td>
    </tr>
  </table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="<%=strBorder%>">
		<%if(bolPrePrinted){%>
    <tr>
      <td width="11%" height="25" align="center">&nbsp;</td>
      <td width="12%" align="center">&nbsp;</td>
      <td width="46%" align="center">&nbsp;</td>
      <td width="10%" align="center">&nbsp;</td>
      <td width="10%" align="center">&nbsp;</td>
      <td width="11%" align="center">&nbsp;</td>
    </tr>
		<%}else{%>
    <tr>
      <td width="11%" height="25" align="center" class="<%=strBorder%>"><strong>QTY</strong><strong> UNIT</strong></td>
      <td width="12%" align="center" class="<%=strBorder%>"><strong>CODE</strong></td>
      <td width="46%" align="center" class="<%=strBorder%>"><strong>ITEM / PARTICULARS 
        / DESCRIPTION </strong></td>
      <td width="10%" align="center" class="<%=strBorder%>"><strong>EXP. DATE </strong></td>
      <td width="10%" align="center" class="<%=strBorder%>"><strong>UP</strong></td>
      <td width="11%" align="center" class="<%=strBorder%>"><strong>AMOUNT</strong></td>
    </tr>		
		<%}%>
    <%iCount = 1;
	for(int i = 1;i < vRetResult.size();i+=12,++iCount){%>
    <tr>
      <td height="25" align="right" class="<%=strBorder%>"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;<%=(String)vRetResult.elementAt(i+2)%>&nbsp;</td>
      <td class="<%=strBorder%>">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
      <td class="<%=strBorder%>">&nbsp;<%=(String)vRetResult.elementAt(i+3)%> / <%=(String)vRetResult.elementAt(i+4)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"(",")","")%></td>
      <td class="<%=strBorder%>">&nbsp;</td>
      <%
				strTemp = (String)vRetResult.elementAt(i+10);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>
      <td align="right" class="<%=strBorder%>"><%=strTemp%>&nbsp;</td>
      <%
				strTemp = (String)vRetResult.elementAt(i+11);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>
      <td align="right" class="<%=strBorder%>"><%=strTemp%>&nbsp;</td>
    </tr>
    <%}%>
		<%for(;iCount < 21;++iCount){%>
    <tr>
      <td height="25" align="right" class="<%=strBorder%>">&nbsp;</td>
      <td class="<%=strBorder%>">&nbsp;</td>
      <td class="<%=strBorder%>">&nbsp;</td>
      <td class="<%=strBorder%>">&nbsp;</td>
      <td align="right" class="<%=strBorder%>">&nbsp;</td>
      <td align="right" class="<%=strBorder%>">&nbsp;</td>
    </tr>
    <%}%>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "Received By : ";
			%>		
      <td height="25" align="center"><%=strTemp%></td>
      <td align="center">&nbsp;</td>
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "Verified By: ";
			%>			
      <td align="center"><%=strTemp%></td>
      <td align="center">&nbsp;</td>
			<%
				if(bolPrePrinted)
					strTemp = "";
				else
					strTemp = "Certified Correct By : ";
			%>			
      <td align="center"><%=strTemp%></td>
    </tr>
    <tr>
      <td width="30%" height="25" align="center" valign="bottom" class=<%=strBorderBottom%>><strong><%=(String)vDelInfo.elementAt(16)%></strong></td>
      <td width="5%">&nbsp;</td>
      <td width="30%" align="center" valign="bottom" class=<%=strBorderBottom%>><strong><%=(String)vDelInfo.elementAt(18)%></strong></td>
      <td width="5%" align="right">&nbsp;</td>
      <td width="30%" align="right" valign="bottom" class=<%=strBorderBottom%>>&nbsp;</td>
    </tr>
  </table>	
  <%}%>
  <!-- all hidden fields go here -->
	<input type="hidden" name="is_pre_printed" value="<%=WI.fillTextValue("is_pre_printed")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>