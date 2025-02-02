<%@ page language="java" import="utility.*, citbookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.nav {     
	 font-weight:normal;
}
.nav-highlight {    
     background-color:#BCDEDB;
}

</style>
<title>Stocks Inventory</title></head>
<script language="javascript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-REPORTS-PROPERTY INVENTORY","view_returned_prop_inv_print.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-REPORTS-PROPERTY INVENTORY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		if(iAccessLevel == 0){
			response.sendRedirect("../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security

	
	
	Vector vRetResult = new Vector();
	BookManagement bm = new BookManagement();

	String strSYFrom = WI.fillTextValue("sy_from");
	String strSemester = WI.fillTextValue("offering_sem");
	
	int iAction = Integer.parseInt(WI.getStrValue(WI.fillTextValue("iAction"),"0");
	
	if(strSYFrom.length() > 0 && strSemester.length() > 0){
		vRetResult = bm.getReturnedItems(dbOP, request, strSYFrom, strSemester, iAction);		
		if(vRetResult == null)
			strErrMsg = bm.getErrMsg();		
	}
	
	String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester", "Fourth Semester"};
	
%>
<body <%if(strErrMsg == null){%>onload="window.print();"<%}%>>
<%if(strErrMsg!=null){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr><td align="center"><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td></tr>
	</table>
	
<%}if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
	<tr><td><div align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
	  <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></div></td></tr>
	 <tr><td align="center">PROPERTY INVENTORY REPORTS<br />
	 	ITEM RETURNED
	 </td></tr>
	 <tr> 
		<td align="center"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>,
		SY <%=WI.fillTextValue("sy_from")%>-<%=Integer.parseInt(WI.fillTextValue("sy_from")) +1%>  
		</td>
	</tr>
	<tr><td height="14"></td></tr>
</table>


	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">		
		<tr>			
			<td width="10%" height="20" align="center" class="thinborder"><strong>Item Code</strong></td>
			<%
			if(WI.fillTextValue("is_book_type").equals("1"))
				strTemp = "Book Title";
			else
				strTemp = "Item Name";
			%>
			<td width="25%" align="center" class="thinborder"><strong><%=strTemp%></strong></td>			
			<td width="7%" align="center" class="thinborder"><strong>Returned QTY</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Price</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Return by</strong></td>			
			<td align="center" class="thinborder"><strong>Return date</strong></td>			
		</tr>
	<% 		
		for(int i = 0; i < vRetResult.size(); i+=11){
	%>
		<tr>			
			<td height="20" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1))%></td>
			<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>			
			<td class="thinborder" align="right"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%></td>			
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>				
			<%
			strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+8),(String)vRetResult.elementAt(i+9),4);
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>				
		</tr>
	<%}%>
	</table>
	
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>