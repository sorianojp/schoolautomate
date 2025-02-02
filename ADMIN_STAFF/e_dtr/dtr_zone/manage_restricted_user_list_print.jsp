<%@ page language="java" import="utility.*, java.util.Vector, eDTR.DTRZoning" %>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Manage Restricted User List</title>
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
			"Admin/staff-eDaily Time Record-DTR ZONING-Manage Restricted User List","manage_restricted_user_list.jsp");
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
	vRetResult = dtrz.operateOnDTRRestrictedUser(dbOP, request, 4);	

	if (vRetResult != null) {		
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(8*iMaxRecPerPage);
		if(vRetResult.size()%(8*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){%>	

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    	<tr>
      		<td height="25" colspan="3"><div align="center"><strong>:::: MANAGE RESTRICTED USER LIST ::::</strong></div></td>
    	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td colspan="2"><strong>SEARCH PARAMETERS</strong></td>
		</tr>
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="17%">Location: </td>
			<td width="80%"><%=WI.fillTextValue("loc_name")%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Employee Status: </td>
			<td><%=WI.getStrValue(WI.fillTextValue("emp_status"), "ALL")%></td>
		</tr>
		<%if(bolIsSchool){%>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Employee Catg: </td>
			<td><%=WI.getStrValue(WI.fillTextValue("emp_catg"), "ALL")%></td>
		</tr>
		<%}%>
		<tr>
			<td height="20">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>:</td>
			<td><%=WI.getStrValue(WI.fillTextValue("c_name"), "ALL")%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Department:</td>
			<td><%=WI.getStrValue(WI.fillTextValue("d_name"), "ALL")%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>ID Number: </td>
			<td><%=WI.getStrValue(WI.fillTextValue("emp_id_number"), "ALL")%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
  	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="15%" height="25" align="left" style="font-size:9px;">Page <%=iPageNo%> of <%=iTotalPages%></td>
		  	<td width="85%" align="right" style="font-size:9px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;</td>
	  	</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr> 
		  	<td height="20" colspan="8" class="thinborder">
				<div align="center"><strong>::: LOCATION USER LIST ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="33%" align="center" class="thinborder"><strong>Employee Name</strong></td>
			<td width="19%" align="center" class="thinborder"><strong>Restriction From</strong></td>
			<td width="23%" align="center" class="thinborder"><strong>Synch Status</strong></td>
		</tr>
		<% 
			int iResultCount = (iPageNo - 1) * iMaxRecPerPage + 1;
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=8, ++iCount, ++iResultCount){
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
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">
				<%=WebInterface.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5), 4)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
			<%
				if(((String)vRetResult.elementAt(i+7)).equals("1"))
					strTemp = "Sycnronized";
				else
					strTemp = "Not synchronized";
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