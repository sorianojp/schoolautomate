<%@ page language="java" import="utility.*, inventory.InventoryMaintenance, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Gate Pass Management Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<style type="text/css">
div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFFFFF;
   
  }
</style>

<script language="javascript"  src ="../../../../jscript/common.js" ></script>

</head>

<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	
	


	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try
	{
	 	dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY MAINTENANCE","gate_pass_mgmt.jsp");								

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}

	
	
	


InventoryMaintenance invMaintenance = new InventoryMaintenance();
String strGatePassNo = WI.fillTextValue("gate_pass_no");	




Vector vRetResult = null;

if(strGatePassNo.length() > 0){
	vRetResult = invMaintenance.operateOnGatePass(dbOP, request, 4, strGatePassNo);
	if(vRetResult == null)	
		strErrMsg  = invMaintenance.getErrMsg();
}

Vector vGPDetails = invMaintenance.operateOnGatePassDetails(dbOP, request, 4, strGatePassNo);
if(vGPDetails == null)	
		strErrMsg  = invMaintenance.getErrMsg();
%>

<body>
<%if(strErrMsg != null){dbOP.cleanUP();%>
<div style="text-align:center"><%=strErrMsg%></div>
<%
return;}


String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchAddress = SchoolInformation.getAddressLine1(dbOP,false,true);
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="3" align="center">
		<font size="3"><%=strSchName%></font><br>
		<font size="2"><%=strSchAddress%></font><br>
		<font size="3"><strong>G A T E &nbsp; P A S S </strong></font>
	</td></tr>
	<tr>
	   <td width="20%">Date and Time Prepared</td>
      <td width="30%">: <%=WI.getStrValue((String)vRetResult.elementAt(3)+" "+(String)vRetResult.elementAt(4))%></td>
      <td width="50%" align="right">GP #: <%=strGatePassNo%></td>
	</tr>
	<tr>
	   <td>Encoded By</td>
	   <td>: <%=WI.getStrValue((String)vRetResult.elementAt(2))%></td>
	   <td align="center">&nbsp;</td>
   </tr>
	<tr>
	   <td colspan="3" align="center" height="30"><font size="2"><strong>( VALID ON THE DATE ISSUED )</strong></font></td>
   </tr>
</table>
<%
if(vGPDetails != null && vGPDetails.size() > 0){
%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="13%" height="20" align="center" class="thinborderTOPBOTTOM"><strong>QTY</strong></td>
		<td width="12%" align="center" class="thinborderTOPBOTTOM"><strong>UNIT</strong></td>
		<td width="33%" class="thinborderTOPBOTTOM"><strong>DESCRIPTION</strong></td>
		<td width="30%" class="thinborderTOPBOTTOM"><strong>PURPOSE</strong></td>
   </tr>
	
	<%
	for(int i = 0; i < vGPDetails.size(); i+=16){
	%>
	<tr>
		<td class="thinborderBOTTOM" align="center" height="18"><%=CommonUtil.formatFloat((String)vGPDetails.elementAt(i+2), true)%></td>
		<td class="thinborderBOTTOM" align="center"><%=(String)vGPDetails.elementAt(i+3)%></td>
		<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vGPDetails.elementAt(i+4),"&nbsp;")%></td>
		<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vGPDetails.elementAt(i+5),"&nbsp;")%></td>
   </tr>
	<%}%>
</table>
<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	   <td height="20">&nbsp;</td>
	   <td>&nbsp;</td>
	   <td align="right">&nbsp;</td>
	   <td>&nbsp;</td>
   </tr>
	<tr>
		<td width="14%" height="20">ORIGIN</td>
	   <td width="36%">: <%=WI.getStrValue((String)vRetResult.elementAt(5))%></td>
	   <td width="24%" align="right">Time Released &nbsp; </td>
	   <td width="26%">: __________</td>
	</tr>
	<tr>
	   <td height="20">DESTINATION</td>
	   <td colspan="3">: <%=WI.getStrValue((String)vRetResult.elementAt(6))%></td>
   </tr>
	<tr>
	   <td height="5" colspan="4" valign="bottom"><div style="border-bottom: solid 1px #000000;"></div></td>
   </tr>
	<tr>
	   <td colspan="4" height="10"></td>
   </tr>
	<tr>
	   <td height="20" colspan="4">SIGNATURE OVER PRINTED NAME</td>
   </tr>
</table>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	   <td width="25%" height="35" valign="bottom">Requested By : <%=WI.getStrValue((String)vRetResult.elementAt(7))%></td>
	   <td colspan="2" valign="bottom">Verified By : <%=WI.getStrValue((String)vRetResult.elementAt(10))%></td>
	   <td width="25%" valign="bottom">Noted By : <%=WI.getStrValue((String)vRetResult.elementAt(8))%></td>
	   <td width="25%" valign="bottom">Approved By : <%=WI.getStrValue((String)vRetResult.elementAt(9))%></td>
   </tr>
	<tr>
	   <td height="35" colspan="2" valign="bottom">Issued By : <%=WI.getStrValue((String)vRetResult.elementAt(12))%></td>
	   <td colspan="2" valign="bottom">Received By : ___________________</td>
	   <td valign="bottom">Guard : ___________________</td>
   </tr>
	<tr>
	   <td height="35" colspan="5" valign="bottom"><div style="border-bottom:dotted 1px #000000;"></div></td>
   </tr>
</table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	   <td colspan="3" align="center">&nbsp;</td>
   </tr>
	<tr><td colspan="3" align="center">
		<font size="3"><%=strSchName%></font><br>
		<font size="2"><%=strSchAddress%></font><br>
		<font size="3"><strong>ACKNOWLEDGEMENT RECEIPT</strong></font>
	</td></tr>
	<tr>
	   <td width="20%">Date and Time Prepared</td>
      <td width="30%">: <%=WI.getStrValue((String)vRetResult.elementAt(3)+" "+(String)vRetResult.elementAt(4))%></td>
      <td width="50%" align="right">AR #: <%=strGatePassNo%></td>
	</tr>
	
	<tr>
	   <td colspan="3" align="center" height="30"><font size="2"><strong>( VALID ON THE DATE ISSUED )</strong></font></td>
   </tr>
</table>
<%
if(vGPDetails != null && vGPDetails.size() > 0){
%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="13%" height="20" align="center" class="thinborderTOPBOTTOM"><strong>QTY</strong></td>
		<td width="12%" align="center" class="thinborderTOPBOTTOM"><strong>UNIT</strong></td>
		<td width="33%" class="thinborderTOPBOTTOM"><strong>DESCRIPTION</strong></td>
		<td width="30%" class="thinborderTOPBOTTOM"><strong>PURPOSE</strong></td>
   </tr>
	
	<%
	for(int i = 0; i < vGPDetails.size(); i+=16){
	%>
	<tr>
		<td class="thinborderBOTTOM" align="center" height="18"><%=CommonUtil.formatFloat((String)vGPDetails.elementAt(i+2), true)%></td>
		<td class="thinborderBOTTOM" align="center"><%=(String)vGPDetails.elementAt(i+3)%></td>
		<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vGPDetails.elementAt(i+4),"&nbsp;")%></td>
		<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vGPDetails.elementAt(i+5),"&nbsp;")%></td>
   </tr>
	<%}%>
</table>
<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	   <td height="20">&nbsp;</td>
	   <td>&nbsp;</td>
	   <td align="right">&nbsp;</td>
	   <td>&nbsp;</td>
   </tr>
	<tr>
		<td width="14%" height="20">ORIGIN</td>
	   <td width="36%">: <%=WI.getStrValue((String)vRetResult.elementAt(5))%></td>
	   <td width="24%" align="right">Time Released &nbsp; </td>
	   <td width="26%">: ___________</td>
	</tr>
	<tr>
	   <td height="20">DESTINATION</td>
	   <td>: <%=WI.getStrValue((String)vRetResult.elementAt(6))%></td>
      <td align="right">Time Received &nbsp;</td>
      <td>: ___________</td>
	</tr>
	<tr>
	   <td height="5" colspan="4" valign="bottom"><div style="border-bottom: solid 1px #000000;"></div></td>
   </tr>
	<tr>
	   <td colspan="4" height="10"></td>
   </tr>
	<tr>
	   <td height="20" colspan="4">NOTE:</td>
   </tr>
	<tr>
	   <td height="20" colspan="4" style="padding-left:30px;">THAT I HAVE RECEIVED ALL ITEMS STATED IN THE GATEPASS# <%=strGatePassNo%></td>
   </tr>
	<tr>
	   <td valign="bottom" height="30" colspan="4">Confirmed & Received By : ____________________ &nbsp; &nbsp; Date & Time : __________</td>
   </tr>
	<tr>
	   <td height="20" colspan="4">SIGNATURE OVER PRINTED NAME</td>
   </tr>
	<tr>
	   <td height="20" align="center" colspan="4">
			<em>THIS ACKNOWLEDGEMENT RECEIPT MUST BE RETURNED UPON RECEIVED<BR>(PROPERTY COPY)</em>
		</td>
   </tr>
</table>
<div id="processing" class="processing">
<table cellpadding="0" cellspacing="0" border="0" Width="100%" style="border:solid 1px #000000;">
	<tr>
		<td>UPHS-01-PROP-GP-02</td>		
	</tr>
	<tr>
		<td>01-10-2010 &nbsp; &nbsp; &nbsp; REV.01</td>		
	</tr>	
</table>
</div>	

<script>
	window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>