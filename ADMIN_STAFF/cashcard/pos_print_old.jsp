<%@ page language="java" import="utility.*,cashcard.Pos,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
-->
</style>
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-CARD MANAGEMENT"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-POS TERMINAL","pos_print.jsp");
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
	//authenticate this user.
	
	Vector vEditInfo  = null;
	Vector vIPResult  = null;
	Vector vOrderDetail = null;
	boolean bolIsBasic = false;
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
	String[] astrConvertSem     = {"Summer","1st Sem","2nd Sem","3rd Sem"};

	Pos cardTrans = new Pos();
	enrollment.FAPaymentUtil pmtUtil = new enrollment.FAPaymentUtil();
	
	vIPResult = cardTrans.operateOnIPFilter(dbOP, request);
	if (vIPResult == null) {%>
		<p style="font-weight:bold; font-color:red; font-size:16px;"><%=cardTrans.getErrMsg()%></p>
	<%
		dbOP.cleanUP();
		return;	
	}
	
	vEditInfo = cardTrans.operateOnTransaction(dbOP, request, 3, null);
	if (vEditInfo == null) {%>
		<p style="font-weight:bold; font-color:red; font-size:16px;"><%=cardTrans.getErrMsg()%></p>
	<%
		dbOP.cleanUP();
		return;	
	}else{
		vOrderDetail = (Vector)vEditInfo.remove(0);	
	}			
%>		
<body onload="window.print();">
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td colspan="4" align="center" class="thinborderBOTTOM"><strong>::::
				<%=(String)vIPResult.elementAt(3)%> ::::</strong></td>
		</tr>
		<tr>
			<td height="20"></td>
			<td>Order Slip# :</td>
			<td><%=(String)vEditInfo.elementAt(2)%></td>
		</tr>		
		<tr>
			<td height="20" width="3%"></td>
			<td width="31%">ID Number:</td>
			<td width="66%"><%=(String)vEditInfo.elementAt(6)%></td>
		</tr>
		<tr>
			<td height="20"></td>
			<td>Name:</td>
			<td><%=WI.formatName((String)vEditInfo.elementAt(7), (String)vEditInfo.elementAt(8), (String)vEditInfo.elementAt(9), 4)%></td>
		</tr>
		
		<tr>
			<td height="20"></td>
			<td>Date:</td>
			<td><%=(String)vEditInfo.elementAt(1)%></td>
		</tr>
		<%if(vOrderDetail != null && vOrderDetail.size() > 0){%>
		<tr>
			<td colspan="3" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
					<tr>
						<td height="20" width="5%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="77%" class="thinborderBOTTOM"><strong>Item Name</strong> </td>
						<td width="6%" class="thinborderBOTTOM"><strong>Qty</strong></td>
						<td align="right" width="12%" class="thinborderBOTTOM"><strong>Price</strong></td>
					</tr>		
				<%			
				int iCount = 1;
				double dTotal = 0d;
					for(int i = 0; i < vOrderDetail.size(); i += 3, iCount++){			
						
				%>
					<tr>
						<td height="20"><%=iCount%>.&nbsp;</td>
						<td>&nbsp;<%=(String)vOrderDetail.elementAt(i)%></td>
						<td><%=(String)vOrderDetail.elementAt(i+1)%></td>
						<%
							dTotal += Double.parseDouble((String)vOrderDetail.elementAt(i+2));	
						%>
						<td align="right"><%=CommonUtil.formatFloat((String)vOrderDetail.elementAt(i+2), true)%></td>
					</tr>
				  <%}%>
					<tr>
						<td height="2" colspan="3" align="right"></td>
						<td><div style="border-bottom:solid 1px #000000;"></div></td>
					</tr>
				</table>
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
					<tr>
						<td width="64%" height="20" class="thinborderBOTTOM">&nbsp;</td>
						<td class="thinborderBOTTOM" width="36%" align="right">TOTAL : &nbsp; &nbsp; &nbsp;<%=CommonUtil.formatFloat(dTotal, true)%></td>
					</tr>		
			</table>			</td>
		</tr>	
		<%}%>
		<tr>
			<td colspan="2"><br/><br/>		      ___________________________</td>		   
		    <td colspan="2" valign="bottom" align="center"><u><%=(String) request.getSession(false).getAttribute("first_name")%></u></td>		    
		</tr>
		<tr>
			<td colspan="2" valign="top">Received by</td>		   
		    <td colspan="2" valign="top" align="center">Cashier</td>		    
		</tr>
	</table>
</body>
</html>
<%
dbOP.cleanUP();
%>