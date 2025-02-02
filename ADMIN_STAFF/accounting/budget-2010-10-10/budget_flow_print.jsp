<%@ page language="java" import="utility.*,Accounting.Budget,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Budget Flow</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BUDGET"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
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
								"ACCOUNTING-BUDGET","budget_flow_print.jsp");
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
	Vector vTemp = null;
	Vector vRetResult = null;
	
	Budget budget = new Budget();
	vRetResult = budget.viewBudgetFlow(dbOP, request);
	
	Vector vAuthLevels = budget.operateOnAuthLevel(dbOP, request, 4);
	if(vAuthLevels == null)
		vRetResult = null;
	
	if (vRetResult != null) {		
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(8*iMaxRecPerPage);
		if(vRetResult.size()%(8*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){%>
	
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" align="center"><strong>BUDGET FLOW</strong></td>
		</tr>
		<tr>
			<td height="15" align="center">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="15%" height="25" align="left" style="font-size:9px;">Page <%=iPageNo%> of <%=iTotalPages%></td>
		  	<td width="85%" align="right" style="font-size:9px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;</td>
	  	</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="21%" align="center" class="thinborder"><strong>Expense Name</strong></td>
			<td width="12%" align="center" class="thinborder"><strong><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/<br>Department</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Timetable</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Proposed<br>Budget</strong></td>
		<%for(int iTemp = 0; iTemp < vAuthLevels.size(); iTemp += 5){%>
			<td width="<%=40/(vAuthLevels.size()/5)%>%" align="center" class="thinborder"><strong><%=(String)vAuthLevels.elementAt(iTemp+1)%></strong></td>
		<%}%>
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
				
				vTemp = (Vector)vRetResult.elementAt(i+5);
		%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">
				<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "ALL")%>/<br>
				<%=WI.getStrValue((String)vRetResult.elementAt(i+7), "ALL")%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%>-<br><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
		<%for(int j = 0; j < vTemp.size(); j += 2){
			if((String)vTemp.elementAt(j) == null)
				strTemp = "&nbsp;";
			else
				strTemp = CommonUtil.formatFloat((String)vTemp.elementAt(j), false);
		%>
			<td class="thinborder"><%=strTemp%></td>
		<%}%>
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