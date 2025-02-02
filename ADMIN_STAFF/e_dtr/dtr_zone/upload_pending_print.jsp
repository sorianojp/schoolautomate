<%@ page language="java" import="utility.*, java.util.Vector, eDTR.DTRZoning" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Upload Pending List</title>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<body onload="window.print();">
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record-DTR ZONING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record"),"0"));
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
			"Admin/staff-eDaily Time Record-DTR ZONING-Upload Pending","upload_pending.jsp");
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
	
	boolean bolPageBreak = false;
	int i = 0;
	int iSearchResult = 0;
	Vector vRetResult = null;
	
	DTRZoning dtrz = new DTRZoning();
	vRetResult = dtrz.getPendingList(dbOP, request, 4);

	if (vRetResult != null) {		
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(7*iMaxRecPerPage);
		if(vRetResult.size()%(7*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){%>	

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    	<tr>
      		<td height="25" colspan="2"><div align="center"><strong>:::: UPLOAD PENDING LIST ::::</strong></div></td>
    	</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">Location: </td>
			<td width="80%"><%=WI.getStrValue(WI.fillTextValue("loc_name"), "ALL")%></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="15%" height="25" align="left" style="font-size:9px;">Page <%=iPageNo%> of <%=iTotalPages%></td>
		  	<td width="85%" align="right" style="font-size:9px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;</td>
	  	</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="6" class="thinborder">
				<div align="center"><strong>::: SEARCH RESULTS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Time In </strong></td>
			<td width="18%" align="center" class="thinborder"><strong>Time Out</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Location</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Failed Reason</strong></td>
		</tr>
		<% 
			int iResultCount = (iPageNo - 1) * iMaxRecPerPage + 1;
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=7, ++iCount, ++iResultCount){
				i = iNumRec;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					break;
				}
				else 
					bolPageBreak = false;	
		%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iResultCount%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		    <td class="thinborder">
			<%if(vRetResult.elementAt(i+2) == null) {%>
				&nbsp;
			<%}else{%>
				<%=WI.getTodaysDateTime(Long.parseLong((String)vRetResult.elementAt(i+2)))%>
			<%}%>
			</td>
			<td class="thinborder">
			<%if(vRetResult.elementAt(i+3) == null) {%>
				&nbsp;
			<%}else{%>
				<%=WI.getTodaysDateTime(Long.parseLong((String)vRetResult.elementAt(i+3)))%>
			<%}%>
			</td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%><br /><%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
		</tr>
		<%} //end for loop%>
	</table>
	<%if (bolPageBreak){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
	} //end end upper most if (vRetResult !=null)%>
</body>
</html>
<%
dbOP.cleanUP();
%>