<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<title>Transaction Log</title></head>
<%@ page language="java" import="utility.*, docTracking.deped.DocumentTracking, java.util.Vector"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","transaction_log.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}	
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING-MANAGE TRANSACTIONS"),"0"));
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	int iSearchResult = 0;
	Vector vRetResult = null;
	DocumentTracking docTracking = new DocumentTracking();

	vRetResult = docTracking.getTransactionLog(dbOP, request);
	if(vRetResult == null)
		strErrMsg = docTracking.getErrMsg();
	else
		iSearchResult = docTracking.getSearchCount();
%>
<body onload="window.print()">
  <%if(vRetResult != null && vRetResult.size() > 0){

if(WI.fillTextValue("date_to").length() > 0) 
	strTemp = WI.fillTextValue("date_fr")+" to "+WI.fillTextValue("date_to");
else	
	strTemp = WI.fillTextValue("date_fr");
%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" class="thinborder">
				<div align="center"><strong>::: LIST OF TRANSACTIONS FOR DATE (<%=strTemp%>)::: </strong></div></td>
		</tr>
		
		<tr>
			<td height="25" width="10%" align="center" class="thinborder"><strong>Office/Dept</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Barcode ID </strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Received By </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Received Date/Time </strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Released By </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Released Date/Time </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Action</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 25, iCount++){
	%>
		<tr>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3));
				strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+4));
				
				if(strTemp.length() > 0 && strErrMsg.length() > 0)
					strTemp += "/ ";
				strTemp += strErrMsg;
			%>
			<td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
		  	<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+18)%></td>
			<td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+19), (String)vRetResult.elementAt(i+20), (String)vRetResult.elementAt(i+21), 4)%></td>			
			<td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+7)), 4)%></td>
			<td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+22), (String)vRetResult.elementAt(i+23), (String)vRetResult.elementAt(i+24), 4)%></td>
			<%
				if((String)vRetResult.elementAt(i+11) == null)
					strTemp = "";
				else
					strTemp = WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+11)), 4);
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+13);
				if(strTemp == null)
					strTemp = "-In Process-";
				else if(strTemp.equals("1")){//forwarded
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15));
					strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+16));
					
					if(strTemp.length() > 0 && strErrMsg.length() > 0)
						strTemp += "/ ";
					strTemp += strErrMsg;
					strTemp = "FWD to "+strTemp+". (Resposible Personnel: "+(String)vRetResult.elementAt(i+14)+")";
				}
				else if(strTemp.equals("2"))//closed
					strTemp = "Completed";
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
		</tr>
	<%}%>
	</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>