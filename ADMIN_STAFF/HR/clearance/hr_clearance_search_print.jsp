<%@ page language="java" import="utility.*,java.util.Vector,hr.HRClearance" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Clearance Search Results</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</style>
</head>
<script src="../../../jscript/common.js"></script>
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
			"Admin/staff-HR Management-Clearance-Search Clearance Print","hr_clearance_search_print.jsp");
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
	
	HRClearance hrc = new HRClearance();
	
	vRetResult = hrc.OperateOnSearchClearance(dbOP,request);
	if (vRetResult != null) {		
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(8*iMaxRecPerPage);
		if(vRetResult.size()%(8*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr> 
			<td height="25" colspan="5" align="center">
				<strong>:::: SEARCH CLEARANCE RESULTS ::::</strong></td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Clearance Type </td>
		    <td colspan="3" height="25"><%=WI.fillTextValue("clearance_name")%></td>
		</tr>
		<%if(WI.fillTextValue("user_index").length() > 0){%>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>Employee ID </td>
			<td colspan="2"><%=WI.fillTextValue("user_index")%></td>
		</tr>
		<%}%>
	</table>
  	
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
  	</table>
	
  	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<%
			if(WI.fillTextValue("user_index").length() > 0)
				strTemp = "LIST OF CLEARANCES";
			else{
				strTemp = "LIST OF EMPLOYEES ";
				strErrMsg = WI.getStrValue(WI.fillTextValue("with_clearances"),"1");
				if(WI.fillTextValue("with_clearances").equals("1"))
					strTemp += "WITH CLEARANCES";
				else
					strTemp += "WITHOUT CLEARANCES";
			}
		%>
		<tr> 
		  	<td height="20" colspan="5" class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
		</tr>
    	<tr style="font-weight:bold;" align="center">
			<td width="5%" class="thinborder">SL#</td>
			<td width="15%" class="thinborder">EMPLOYEE ID </td> 
			<td width="35%" height="23" class="thinborder">EMPLOYEE NAME </td>
			<td width="45%" class="thinborder">DEPARTMENT/OFFICE</td>
		</tr>
    	<% 
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=8, ++iCount){
				i = iNumRec;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					break;
				}
				else 
					bolPageBreak = false;	
		%>
    	<tr>
      		<td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      		<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td> 
      		<td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;
			<font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
					(String)vRetResult.elementAt(i+5), 4).toUpperCase()%></strong></font></strong></font></td>
				<%
					if((String)vRetResult.elementAt(i + 6)== null || (String)vRetResult.elementAt(i + 7)== null)
						strTemp = " ";			
					else
						strTemp = " - ";
				%>
      		<td class="thinborder">&nbsp;
	   			<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"")%></td>
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