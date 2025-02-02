<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Circular Memo</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	String strErrMsg = null;
	String strTemp = null;
	boolean bolPageBreak = false;
		
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO MANAGEMENT"),"0"));
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
			"Admin/staff-HR Management-Memo Management-Circular Memo Print","circular_memo_print.jsp");
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
	Vector vDates = null;
	hr.HRMemoManagement  mt = new hr.HRMemoManagement();
	int iSearchResult = 0;
	int i = 0;
	vRetResult = mt.operateOnMemoCirculation(dbOP, request, 5);
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
  		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr> 
				<td height="25" colspan="3" align="center"><strong>:::: MEMO CIRCULAR ::::</strong></td>
			</tr>
			<tr>
				<td height="10" colspan="3">&nbsp;</td>
			</tr>
		</table>
		
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				<td width="4%">&nbsp;</td>
				<td width="17%" height="25">Memo Name: </td>
				<td width="79%"><%=WI.fillTextValue("memo_name")%></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td height="25">Date of Memo : </td>
				<td height="23"><%=WI.fillTextValue("memo_date")%></td>
			</tr>
			<tr>
				<td height="10" colspan="3">&nbsp;</td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" class="thinborder" align="center"><strong>LIST OF EMPLOYEES</strong></td>
		</tr>
    	<tr>
			<td width="5%" class="thinborder">&nbsp;</td>
			<td width="10%" class="thinborder" align="center"><strong><font size="1">EMPLOYEE ID</font></strong></td> 
			<td width="38%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
			<td width="42%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
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
      		<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      		<td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;
	  			<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
					(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
				<%
					if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null)
						strTemp = " ";			
					else
						strTemp = " - ";
				%>
      		<td class="thinborder">&nbsp;
	   			<%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%>	  		</td>
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