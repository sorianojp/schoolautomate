<%@ page language="java" import="utility.*, citbookstore.BookLogs,citbookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>View/Delete Book Logs</title>
</head>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","view_book_logs_history.jsp");
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
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-BOOK MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		//iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security

	
	BookLogs bl = new BookLogs();
	BookManagement bm = new BookManagement();
	Vector vRetResult = null;


	vRetResult = bl.viewBookLogHistory(dbOP, request);
	if(vRetResult == null)			
		strErrMsg = bl.getErrMsg();		

%>
<body <%if(strErrMsg == null){%>onload="window.print();"<%}%>>
	

<%if(vRetResult != null && vRetResult.size() > 0){%>



<%
boolean bolIsPageBreak = false;
int iResultSize = 12;
int iLineCount = 0;
int iMaxLineCount = 30;	
int i = 0;
while(iResultSize <= vRetResult.size()){
iLineCount = 0;
%>


	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
	<tr><td align="center"><font size="3"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td></tr>
	<tr><td align="center">History Supply Log Report<br /> <br /></td></tr>
	<tr><td align="center"><%=WI.getStrValue(WI.fillTextValue("date_fr"),"")%>
		<%if(WI.fillTextValue("date_to").length()>0){%> - 
	 	<%=WI.getStrValue(WI.fillTextValue("date_to"))%>
	 	<%}%><br /> <br /></td></tr>
</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">		
		<tr>			
			<td height="23" width="12%" align="center" class="thinborder"><strong>Item Code </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Book Title </strong></td>
			<td width="13%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="5%"  align="center" class="thinborder"><strong>Log Qty</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Log Date</strong></td>
			<td width="6%" align="center" class="thinborder"><strong>PO No.</strong></td>
			<td width="6%" align="center" class="thinborder"><strong>DR No.</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Logged By</strong></td>
		  	<td width="5%" align="center" class="thinborder"><strong>Operation</strong></td>			
		</tr>

		<%	for(; i < vRetResult.size();){			
			iLineCount++;		
			iResultSize += 12;	%>
		
		<tr>			
			<td height="23" class="thinborder"><%=(String)vRetResult.elementAt(i+11)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "N/A")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "N/A")%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
			<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+8));
			%>
			<td class="thinborder"><%=strTemp%></td>
			<%
			strTemp = (String)vRetResult.elementAt(i+10);
			if(strTemp == null)
				strTemp = "&nbsp;";
			else{
				if(strTemp.equals("1"))
					strTemp = "ADD";
				else
					strTemp = "DELETE";
			}
			
			%>
			<td class="thinborder"><%=strTemp%></td>
		</tr>
		
		<%
			i+=12;
			if(iLineCount >= iMaxLineCount){
				bolIsPageBreak = true;
				break;		
			}else
				bolIsPageBreak = false;	
		%>
		
	<%}%>
	</table>
	
	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>
	
<%}if(iResultSize > vRetResult.size()){%>	
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
			<tr><td colspan="3" height="25">&nbsp;</td></tr>
			<tr>
				<td height="25" width="28%">FOR IMDC USE ONLY</td>
				<td width="36%" align="center"></td>
				<td width="36%" align="right">&nbsp;</td>
			</tr>
			
			<tr>
		  		<td height="20">&nbsp;</td>
		  		<td>&nbsp;</td>
		  		<td align="right">&nbsp;</td>
	  		</tr>
			<tr align="center">		  
		  		<td><table width="90%" cellpadding="0" cellspacing="0" border="0"><tr><td class="thinborderBOTTOM">&nbsp;</td></tr></table></td>
		  		<td height="25">&nbsp;</td>
		  		<td><table width="90%" cellpadding="0" cellspacing="0" border="0">
					<tr><td class="thinborderBOTTOM" align="center">&nbsp;
					<%=request.getSession(false).getAttribute("first_name")%> <%=WI.getTodaysDateTime()%></td></tr></table></td>
	  		</tr>
			<tr align="center">
		  		<td>APPROVED BY/DATE </td>
		  		<td>&nbsp;</td>		  
		  		<td>VERIFIED BY/DATE</td>
	  		</tr>
	</table>
		
<%
	}//end if(iResultSize > vRetResult.size())
	
	
}%>
	
</body>
</html>
<%
dbOP.cleanUP();
%>