<%@ page language="java" import="utility.*,java.util.Vector,hr.HRClearance" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Clearance Status Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-CLEARANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
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
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Clearance-View Clearance Status Print","hr_view_clearance_status_print.jsp");
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

	Vector vItems = null;
	Vector vUserInfo = null;
	Vector vRetResult = null;
	Vector vClearances = null;
	
	int i = 0;
	int iSearchResult = 0;
	
	HRClearance hrc = new HRClearance();
	
	enrollment.Authentication auth = new enrollment.Authentication();
    request.setAttribute("emp_id", WI.fillTextValue("emp_id"));
	vUserInfo = auth.operateOnBasicInfo(dbOP, request, "0");
	if(vUserInfo != null)
		vRetResult = hrc.ViewClearanceStatus(dbOP, request, (String)vUserInfo.elementAt(0));
	
	if (vRetResult != null) {
		int iCount = 0;
		int iNumRec = 0;
		vClearances = (Vector)vRetResult.remove(0);
		vItems = (Vector)vRetResult.remove(0);	
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr> 
			<td height="25" colspan="5" align="center">
				<strong>:::: CLEARANCE STATUS ::::</strong></td>
		</tr>
	</table>
<%if(vUserInfo!=null && vUserInfo.size() > 0){%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
        	<td height="25" colspan="2">Employee Information: </td>
	    	<td colspan="3">&nbsp;</td>
      	</tr>
		<tr> 
			<td width="5%" height="25">&nbsp;</td>
			<td width="18%">Employee ID:</td>
			<td width="77%" colspan="3"><%=WI.fillTextValue("emp_id")%></td>
	    </tr>
		<tr>
			<td width="5%" height="25">&nbsp;</td>
			<td width="18%">Name:</td>
		    <td colspan="3"><%=WebInterface.formatName((String)vUserInfo.elementAt(1), (String)vUserInfo.elementAt(2), (String)vUserInfo.elementAt(3), 4)%></td>
	    </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Department/Office:</td>
		  <%
		  	if((String)vUserInfo.elementAt(13)== null || (String)vUserInfo.elementAt(14)== null)
				strTemp = " ";			
			else
				strTemp = " - ";
		  %>
		  <td colspan="3">
		  <%=WI.getStrValue((String)vUserInfo.elementAt(13),"")%>
		  <%=strTemp%>
		  <%=WI.getStrValue((String)vUserInfo.elementAt(14),"")%> 
		  </td>
	  </tr>
	  <tr>
	  	<td colspan="3">&nbsp;</td>
	  </tr>
  	</table>
<%} if (vClearances != null &&  vClearances.size() > 0) {%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
  	</table>
	
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<%
			if(WI.fillTextValue("view_all_clearance").equals("1"))
				strTemp = "ALL";
			else
				strTemp = "UNCLEARED";
		%>
		<tr> 
		  	<td height="20" colspan="7" class="thinborder"><div align="center"><strong>LIST OF <%=strTemp%> CLEARANCES </strong></div></td>
		</tr>
    	<tr>
			<td width="7%" height="23" class="thinborder">&nbsp;</td>
			<td width="20%" align="center" class="thinborder"><strong><font size="1">CLEARANCE NAME</font></strong></td>
			<td width="19%" align="center" class="thinborder"><strong><font size="1">REMARK</font></strong></td>
			<td width="23%" align="center" class="thinborder"><strong><font size="1">POSTED BY</font></strong></td>
			<td width="18%" align="center" class="thinborder"><strong><font size="1">DATE POSTED</font></strong></td>
			<%if(WI.fillTextValue("view_all_clearance").equals("1")){%>
			<td width="13%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
			<%}%>
		</tr>
    	<% 
			for(iCount = 1; iNumRec<vClearances.size(); iNumRec+=7, ++iCount){
				i = iNumRec;
		%>
    	<tr>
      		<td height="25" class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
			<td class="thinborder"><%=(String)vClearances.elementAt(i)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vClearances.elementAt(i+1), "&nbsp;")%></td>
			<td class="thinborder">
			<%=WebInterface.formatName((String)vClearances.elementAt(i+2),(String)vClearances.elementAt(i+3), (String)vClearances.elementAt(i+4), 7)%></td>
      		<td class="thinborder"><%=(String)vClearances.elementAt(i+6)%></td>
			<%if(WI.fillTextValue("view_all_clearance").equals("1")){
				strTemp = (String)vClearances.elementAt(i+5);
				if(strTemp.equals("1"))
					strTemp = "CLEARED";
				else
					strTemp = "UNCLEARED";
			%>
      		<td class="thinborder"><%=strTemp%></td>
			<%}%>
   		</tr>
    	<%} //end for loop%>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	<%}if(vClearances==null && vRetResult!=null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
  	</table>
	
  	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<%
			if(WI.fillTextValue("view_all_clearance").equals("1"))
				strErrMsg = "NO POSTED CLEARANCES.";
			else
				strErrMsg = "NO UNCLEARED CLEARANCES.";
		%>
		<tr>
			<td height="25" colspan="6"><strong>CLEARANCE STATUS: <%=strErrMsg%></strong></td>
		</tr>
		<tr>
      		<td height="25" colspan="6">&nbsp;</td>
    	</tr>
	</table>	
	<%}
	
	if (vItems != null &&  vItems.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<%
		if(WI.fillTextValue("view_all_items").equals("1"))
			strTemp = "ALL";
		else
			strTemp = "TO BE RETURNED";
	%>
	<tr> 
	  	<td height="20" colspan="8" class="thinborder"><div align="center"><strong>LIST OF <%=strTemp%> ISSUED ITEMS</strong></div></td>
	</tr>
    <tr>
		<td width="7%"  height="23" class="thinborder">&nbsp;</td>
		<td width="25%" align="center" class="thinborder"><strong><font size="1">PROPERTY #. </font></strong></td>
		<td width="24%" align="center" class="thinborder"><strong><font size="1">DATE ISSUED </font></strong></td>
		<td width="27%" align="center" class="thinborder"><strong><font size="1">ISSUED BY </font></strong></td>
		<%if(WI.fillTextValue("view_all_items").equals("1")){%>
		<td width="17%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
		<%}%>
	</tr>
	<% 
		iNumRec = 0;
		iCount = 0;
		for(iCount = 1; iNumRec<vItems.size(); iNumRec+=7, ++iCount){
			i = iNumRec;	
	%>
    <tr>
    	<td height="25" class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
    	<td class="thinborder"><%=(String)vItems.elementAt(i)%></td>
     	<td class="thinborder"><%=vItems.elementAt(i+6)%></td>
      	<td class="thinborder">
			<%=WebInterface.formatName((String)vItems.elementAt(i+2),(String)vItems.elementAt(i+3),(String)vItems.elementAt(i+4),7)%></td>
		<%	if(WI.fillTextValue("view_all_items").equals("1")){
				strErrMsg = (String)vItems.elementAt(i+1);				
				if(strErrMsg != null)
					strErrMsg = "RETURNED";
				else{//else if the returned date is not null
					if(((String)vItems.elementAt(i+5)).equals("1"))
						strErrMsg = "UNRETURNED";
					else
						strErrMsg = "NOT TO BE RETURNED";
				}
		%>
		<td class="thinborder"><%=strErrMsg%></td> <%}%>
      </tr>
    	<%} //end for loop%>
	</table>
<%}if(vItems==null  && vRetResult!=null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<%
		if(WI.fillTextValue("view_all_items").equals("1"))
			strErrMsg = "NO ITEMS ISSUED.";
		else
			strErrMsg = "NO TO BE RETURNED ITEMS ISSUED.";
	%>
	<tr>
		<td height="25" colspan="6"><strong>ISSUED ITEMS STATUS: <%=strErrMsg%></strong></td>
	</tr>
	</table>
<%}}%>
</body>
</html>
<%
dbOP.cleanUP();
%>