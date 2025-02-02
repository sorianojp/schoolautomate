<%@ page language="java" import="utility.*, citbookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Stocks Inventory</title></head>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-REPORTS","print_inventory_property.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
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
		if(iAccessLevel == 0){
			response.sendRedirect("../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security

	
	String[] astrConvertSem    = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};
	
	int iSearchResult = 0;
	Vector vRetResult = new Vector();
	BookManagement bm = new BookManagement();

	
	
	vRetResult = bm.viewPropertyInventory(dbOP, request, 1);		
	if(vRetResult == null)
		strErrMsg = bm.getErrMsg();
%>
<body <%if(strErrMsg == null){%>onload="window.print();"<%}%>>

	
<%if(strErrMsg!=null){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr><td align="center"><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td></tr>
	</table>
	
<%}if(vRetResult != null && vRetResult.size() > 0 && strErrMsg==null){%>

	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr><td align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></td></tr>
		<tr><td align="center">PROPERTY INVENTORY REPORTS<br /><br /><br /></td></tr>
		
		<tr> 
		  	<td align="center">SY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>  
			<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></td>
		</tr>	
	</table>
<%
	
int iBeginInv = 0;
int iCurrInv  = 0;
int iTotInv   = 0;
int iTolDelivered = 0;
int iReturnedInv = 0;
int iDefInv = 0;
int iEndingInv = 0;

boolean bolIsPageBreak = false;
int iResultSize = 11;
int iLineCount = 0;
int iMaxLineCount = 40;	
int iCount = 0;	
int i = 0;
while(iResultSize <= vRetResult.size()){
iLineCount = 0;
%>
	
	
	
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">		
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<%
			if(WI.fillTextValue("is_book_type").equals("1"))
				strTemp = "Book Title";
			else
				strTemp = "Item Name";
			%>
			<td width="25%" align="center" class="thinborder"><strong><%=strTemp%></strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Beginning Inventory</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Current Inventory</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Total Available Qty</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Ordered Qty</strong></td>			
			<td width="7%" align="center" class="thinborder"><strong>Total Delivered</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Total Accepted</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Returned Inventory</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Returned Defective</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Ending Inventory</strong></td>						
			<td width="7%" align="center" class="thinborder"><strong>Price</strong></td>
		</tr>
	<% 			
		for(; i < vRetResult.size();){	
		iCount++;
		iLineCount++;		
		iResultSize += 11;		
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>			
			
			<%
			iBeginInv = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+7), "0"));
			iCurrInv = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+8), "0"));
			iTotInv = iBeginInv + iCurrInv;
			%>
			<td class="thinborder">&nbsp;<%=iBeginInv%></td>			
			<td class="thinborder">&nbsp;<%=iCurrInv%></td>	
			<td class="thinborder">&nbsp;<%=iTotInv%></td>
			
						
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"0")%></td>
			<%
			iTolDelivered = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5), "0"));
			%>
			<td class="thinborder">&nbsp;<%=iTolDelivered%></td>			
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "0")%></td>
			
			<%
			iReturnedInv = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+9), "0"));
			iDefInv = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+10), "0"));
			
			iEndingInv = (iTotInv - iTolDelivered) + iReturnedInv + iDefInv;
			%>
			<td class="thinborder">&nbsp;<%=iReturnedInv%></td>
			<td class="thinborder">&nbsp;<%=iDefInv%></td>
			
			<td class="thinborder">&nbsp;<%=iEndingInv%></td>				
			
			
			<td class="thinborder" align="right"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "0")%>&nbsp;</td>			
		</tr>
		<%
		i+=11;
		if(iLineCount > iMaxLineCount){
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
<%}

if(iResultSize > vRetResult.size()){%>
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
	}//end if(iResultSize > vRetResut.size())
}//end if vRetResult != null%>	
	

</body>
</html>
<%
dbOP.cleanUP();
%>