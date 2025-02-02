<%@ page language="java" import="utility.*,java.util.Vector,hr.PersonnelAssetManagement"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Issued Item Status Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../../jscript/td.js"></script>
<script src="../../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL ASSET MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel Asset Management-Issued Asset Status Print","issued_asset_status_print.jsp");
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
	
	Vector vRetResult = null;
	boolean bolPageBreak = false;
	int i = 0;
	int iSearchResult = 0;
	
	PersonnelAssetManagement  pam = new PersonnelAssetManagement();
	vRetResult = pam.operateOnIssuedItemStatus(dbOP, request, 4);
	if (vRetResult != null) {			
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(10*iMaxRecPerPage);	
		if(vRetResult.size()%(10*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td colspan="3" height="25" bgcolor="#FFFFFF" align="center"><strong>:::: ITEMS ISSUED STATUS ::::</strong></td>
    </tr>
	<tr> 
		<td colspan="3">&nbsp;</td>
	</tr>
	<tr> 
		<td width="20%" height="25"><strong>ISSUED TO: </strong></td>
		<td colspan="2"><%=WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%></td>
	</tr>
	<tr> 
		<td colspan="3">&nbsp;</td>
	</tr>
	<tr>
			<td height="25" align="left" style="font-size:9px;">Page <%=iPageNo%> of <%=iTotalPages%></td>
		  	<td width="80%" colspan="2" align="right" style="font-size:9px;">Date and time Printed : <%=WI.getTodaysDateTime()%>&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
	<tr> 
	  	<td height="20" colspan="5" bgcolor="#FFFFFF" class="thinborder" align="center"><strong>LIST OF ISSUED ITEMS </strong></td>
	</tr>
    <tr>
		<td width="9%"  height="23" class="thinborder">&nbsp;</td>
		<td width="18%" align="center" class="thinborder"><strong><font size="1">PROPERTY #. </font></strong></td>
		<td width="18%" align="center" class="thinborder"><strong><font size="1">DATE ISSUED </font></strong></td>
		<td width="18%" align="center" class="thinborder"><strong><font size="1">ISSUED BY </font></strong></td>
		<td width="18%" align="center" class="thinborder"><strong><font size="1">TO BE RETURNED?</font></strong></td> 
	</tr>
	<% 
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=14, ++iCount){
				i = iNumRec;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					break;
				}
				else 
					bolPageBreak = false;			
		%>
    <tr>
    	<td height="25" class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
    	<td class="thinborder"><%=(String)vRetResult.elementAt(i+13)%></td>
     	<td class="thinborder"><%=vRetResult.elementAt(i+6)%></td>
      	<td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i+8),(String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+10),7)%></td>
		<%
			strTemp = (String)vRetResult.elementAt(i+12);
			if(strTemp.equals("1"))
				strTemp = "YES";
			else
				strTemp = "NO";
		%>
      	<td class="thinborder"><%=strTemp%></td> 
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
