<%@ page language="java" import="utility.*, java.util.Vector, eDTR.DTRZoning, payroll.PRAjaxInterface" %>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
		
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Manage Restricted User List</title>
</head>

 <script language="javascript" src="../../../jscript/common.js"></script> 
<%		
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	int iIndexOf  = 0;
 
			
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("EDAILY TIME RECORD-DTR ZONING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("EDAILY TIME RECORD"),"0"));
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
			"Admin/staff-eDaily Time Record-DTR ZONING-Manage Faculty Room","add_fac_room.jsp");
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
	DTRZoning dtrz    = new DTRZoning();
 	
	String strLocIndex = WI.fillTextValue("loc_index");
	String[] astrRoom = null;
	Vector vSelected = new Vector();
	Vector vLocInfo    = null; 
	vRetResult = dtrz.operateOnFacRoomAssign(dbOP, request, 4);
%>
<body onload="window.print();">
<form name="form_" action="./add_fac_room.jsp" method="post">
  <%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr> 
		  	<td height="20" colspan="6" align="center" class="thinborder">
			    <strong>::: LOCATION ROOM LIST :::</strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr>
			<td height="25" width="7%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="16%" align="center" class="thinborder"><strong>Room Number </strong></td>
			<td width="27%" align="center" class="thinborder"><strong>Room Location (Floor) </strong></td>
			<td width="33%" align="center" class="thinborder"><strong>Room Location (Building) </strong></td>
			<td width="17%" align="center" class="thinborder"><strong>List of Other DTR Terminal In case assigned to mutiple Location</strong></td>
		</tr>
		<%	int iCount = 1;
			for(int i = 0; i < vRetResult.size(); i += 6, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 1), "All")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 2), "All")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3), "All")%></td>
			<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "None")%></td>
		</tr>
		<%}%>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" align="center">&nbsp;</td>
		</tr>
	</table>
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>