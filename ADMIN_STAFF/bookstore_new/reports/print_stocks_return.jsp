<%@ page language="java" import="utility.*, citbookstore.BookReports,citbookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Stocks Ordered</title></head>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolFatalErr = false;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-REPORTS","print_stocks_return.jsp");
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
	
	strTemp = "";
	if(WI.fillTextValue("book_catg").length() >0){	
		if(WI.fillTextValue("book_catg").equals("2"))
	 		strTemp = " (COLLEGE DISTRIBUTION CENTER)";	
		else{
			if(WI.fillTextValue("classification").length() >0){
				if( Integer.parseInt(WI.fillTextValue("classification")) > 10)	
					strTemp = " (HIGH SCHOOL DISTRIBUTION CENTER)";	
				else
			 		strTemp = " (ELEMENTARY DISTRIBUTION CENTER)";	
			}		 	
		}	
	}
	
	boolean bolIsDefective = WI.fillTextValue("defective_").equals("1");
	boolean bolIsNotDefective = WI.fillTextValue("_not_defective").equals("1");
	
	//System.out.println(bolIsDefective);
	//System.out.println(bolIsNotDefective);
	
	
	String strCSV = WI.fillTextValue("strCSV");	
	
	Vector vBookIndex = new Vector();
	vBookIndex = CommonUtil.convertCSVToVector(strCSV);
	
	int iSearchResult = 0;
	Vector vRetResult = null;
	BookReports br = new BookReports();
	
	BookManagement bm = new BookManagement();
	
	vRetResult = bm.searchBooks(dbOP, request,0);
	
	if(vRetResult == null)
		strErrMsg = bm.getErrMsg();
	else{
		if(!bm.returnDistInvToPropert(dbOP, request, (Vector)vBookIndex))
			strErrMsg = bm.getErrMsg();	
	}
	
%>
<body <%if(strErrMsg==null){%> onload="window.print();"<%}%>>
	
	<%if(strErrMsg!=null){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="">
		<tr>	
			<td colspan="2" align="center"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<%}%>



	
	
	
<%if(vRetResult != null && vRetResult.size() > 0 && strErrMsg == null){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="">
	<tr>
		<td height="25" colspan="2" align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
		
			<br />INSTRUCTIONAL MATERIALS DISTRIBUTION CENTER<br /><br />
		
		
		</font></td>
	</tr>
	<tr><td height="20"><div align="center">STOCKS RETURN <%=strTemp%></div></td></tr>	
	<tr><td height="15">&nbsp;</td></tr>
</table>

<%
boolean bolIsPageBreak = false;
int iResultSize = 17;
int iLineCount = 0;
int iMaxLineCount = 35;	
int iCount = 0;	
int i = 0;
int iIndexOf = 0;
while(iResultSize <= vRetResult.size()){
iLineCount = 0;
%>

	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="18" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="18%" align="center" class="thinborder"><strong>Book Title </strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Item Code </strong></td>
			
			<%if(bolIsNotDefective || (bolIsDefective && bolIsNotDefective)){%>
			<td width="5%" align="center" class="thinborder"><strong>Return Qty</strong></td>
			<%}if(bolIsDefective || (bolIsDefective && bolIsNotDefective)){%>
			<td width="5%" align="center" class="thinborder"><strong>Defective Qty</strong></td>			
			<%}%>
			<td width="5%" align="center" class="thinborder"><strong>Released Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Paid Unreleased Qty</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Unpaid Unreleased Qty</strong></td>			
		</tr>	
		<%
		for( ; i<vRetResult.size() ; ){			
			iCount++;
			iLineCount++;		
			iResultSize += 17;	
			
			iIndexOf = vBookIndex.indexOf(vRetResult.elementAt(i));
			
			if(iIndexOf == -1){
				i+=17;			
				iCount--;
				continue;
			}			
		%>
	
		<tr>
			<td height="18" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			
			<%
				strTemp = (String)vBookIndex.elementAt(iIndexOf+1);
				if(strTemp.equals("0"))
					strTemp = (String)vRetResult.elementAt(i+7);
					
				
			%>
			
			<%if(bolIsNotDefective || (bolIsDefective && bolIsNotDefective)){%>
			<td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"0")%></td>	
			<%}if(bolIsDefective || (bolIsDefective && bolIsNotDefective)){%>		
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+15), "0")%></td>
			<%}%>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13), "0")%></td>	
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+12), "0")%></td>			
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10), "0")%></td>
		</tr>
		
		<%
		i+=17;
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
	
	
<%}if(iResultSize > vRetResult.size()){%>	
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr><td colspan="3" height="25">&nbsp;</td></tr>
		<tr>
			<td height="25" width="28%">FOR IMDC USE ONLY</td>
			<td width="36%" align="center"><%=request.getSession(false).getAttribute("first_name")%> <%=WI.getTodaysDateTime()%></td>
			<td width="36%" align="right">&nbsp;</td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td align="center" class="thinborderTOP" style="font-size:12px" valign="top">VERIFIED BY/DATE</td>
		  <td align="right">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td align="right">&nbsp;</td>
	  </tr>
		<tr align="center">		  
		  <td><table width="90%" cellpadding="0" cellspacing="0" border="0"><tr><td class="thinborderBOTTOM">&nbsp;</td></tr></table></td>
		  <td height="25">&nbsp;</td>
		  <td><table width="90%" cellpadding="0" cellspacing="0" border="0"><tr><td class="thinborderBOTTOM">&nbsp;</td></tr></table></td>
	  </tr>
		<tr align="center">
		  <td>DELIVERED BY/DATE </td>
		  <td>&nbsp;</td>		  
		  <td>RECEIVED BY FULL NAME AND SIGNATURE </td>
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