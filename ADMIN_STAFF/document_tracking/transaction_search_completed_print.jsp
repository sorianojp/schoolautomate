<%@ page language="java" import="utility.*, docTracking.deped.DocumentTracking, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Search Completed Transactions</title></head>
<script language="javascript" src="../../jscript/common.js"></script>
<body onload="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","transaction_search_completed.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING-SEARCH"),"0"));
	
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
	
	boolean bolPageBreak = false;
	int i = 0;
	int iSearchResult = 0;
	int iDiff = 0;
	String strCurrentDate = "";
	String strReleaseDate = null;
	Vector vRetResult = null;
	
	DocumentTracking dts = new DocumentTracking();	
	vRetResult = dts.searchCompletedTransactions(dbOP, request);
	
	if (vRetResult != null){
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(7*iMaxRecPerPage);
		if(vRetResult.size()%(7*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){%>
		
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="9" bgcolor="#FFFFFF" class="thinborder">
				<div align="center"><strong>::: LIST OF TRANSACTIONS ::: </strong></div></td>
		</tr>
		<tr>
			<td width="10%" rowspan="2" align="center" class="thinborder"><strong>DATE</strong></td>
			<td width="5%"  rowspan="2" align="center" class="thinborder"><strong>Ref.<br />No.</strong></td>
			<td width="40%" rowspan="2" align="center" class="thinborder"><strong>PARTICULARS</strong></td>
			<td width="15%" rowspan="2" align="center" class="thinborder"><strong>RERERRED TO </strong></td>
			<td width="10%" rowspan="2" align="center" class="thinborder"><strong>ACTION TAKEN</strong></td>
			<td height="20" colspan="4" align="center" class="thinborder"><strong>NO. OF DAYS ACTED </strong></td>
		</tr>
		<tr>
			<td width="5%" height="20" align="center" class="thinborder"><strong>1-4</strong></td>
			<td align="center" class="thinborder" width="5%"><strong>5-9</strong></td>
			<td align="center" class="thinborder" width="5%"><strong>10-14</strong></td>
			<td align="center" class="thinborder" width="5%"><strong>15+</strong></td>
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
					
				strReleaseDate = (String)vRetResult.elementAt(i);
				
				if(strCurrentDate.equals(strReleaseDate)){
					strTemp = "";
				}
				else{
					strCurrentDate = strReleaseDate;
					strTemp = strCurrentDate;
				}
				
				iDiff = ConversionTable.differenceInDays(Long.parseLong((String)vRetResult.elementAt(i+5)), Long.parseLong((String)vRetResult.elementAt(i+6)));
		%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<strong><%=(String)vRetResult.elementAt(i+2)%></strong><br />&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;</td>
			<%
				if(iDiff <= 4)
					strTemp = Integer.toString(iDiff);
				else
					strTemp = "";
			%>
			<td class="thinborder" align="center"><%=strTemp%></td>
			<%
				if(iDiff > 4 && iDiff <= 9)
					strTemp = Integer.toString(iDiff);
				else
					strTemp = "";
			%>
			<td class="thinborder" align="center"><%=strTemp%></td>
			<%
				if(iDiff > 9 && iDiff <= 14)
					strTemp = Integer.toString(iDiff);
				else
					strTemp = "";
			%>
			<td class="thinborder" align="center"><%=strTemp%></td>
			<%
				if(iDiff > 14)
					strTemp = Integer.toString(iDiff);
				else
					strTemp = "";
			%>
			<td class="thinborder" align="center"><%=strTemp%></td>
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