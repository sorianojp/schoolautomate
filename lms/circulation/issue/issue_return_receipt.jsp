<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
    }
-->
</style>
</head>

<body topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.* ,lms.BookIssue, java.util.Vector" %>
<% 
//check if there is valid session
	DBOperation dbOP = null;
	String strErrMsg = null;
	String  strTemp  = null;
	WebInterface WI  = new WebInterface(request);
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	
	Vector vRetResult  = null; Vector vPatronInfo = null;
	String strCode     = WI.fillTextValue("code_no");
	boolean bolIsIssue = false;
	if(WI.fillTextValue("is_issue").length() > 0) 
		bolIsIssue = true;
	
	if(strCode.length() > 0) {
		BookIssue bI = new BookIssue();
		vRetResult   = bI.printIssueReturnRecept(dbOP,strCode, bolIsIssue);
		if(vRetResult == null) 
			strErrMsg = bI.getErrMsg();
		else	
			vPatronInfo = (Vector)vRetResult.remove(0);  
	}
	else {
		if(bolIsIssue)
			strErrMsg = "Please enter issue code.";
		else	
			strErrMsg = "Please enter return code.";
	}
String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};	
String strHeader = null;
if(strErrMsg == null)
	strHeader = "<strong> "+SchoolInformation.getSchoolName(dbOP,true,false)+"</strong> <br>"+
				SchoolInformation.getAddressLine1(dbOP,false,false)+"<br> <font size=1>Academic Year : "+
				vPatronInfo.elementAt(0)+" - "+vPatronInfo.elementAt(1)+","+
				astrConvertToSem[Integer.parseInt((String)vPatronInfo.elementAt(2))]+"</font>";
dbOP.cleanUP();
if(strErrMsg != null) {%>
<table width="100%">
 	<tr>
    	<td width="100%"><b><font size="3" color="#FF0000"><%=strErrMsg%></font></b></td>
    </tr>
</table>	
<%return;}%>
<table width="100%">
   <tr>
    	<td align="center"><%=strHeader%></td>
  </tr>
</table>	
<table width="100%" cellpadding="0" cellspacing="0" border="0">
  <tr> 
    <td colspan="4" align="right">Date and time Printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>
  </tr>
<tr> 
    <td width="8%">Patron:</td>
    <td width="54%"><strong><%=(String)vPatronInfo.elementAt(5)%> (<%=(String)vPatronInfo.elementAt(6)%>) 
	<%if(vPatronInfo.elementAt(8) != null) {%>
		- <%=vPatronInfo.elementAt(8)%> <%=WI.getStrValue((String)vPatronInfo.elementAt(9), "/","","")%>
	<%}%>
	</strong></td>
    <td width="11%">Patron Type:</td>
    <td width="27%"><strong><%=(String)vPatronInfo.elementAt(7)%></strong></td>
  </tr>
<tr>
 <td colspan="4" height="10" align="right">&nbsp;</td>
 </tr>
</table>	 
 <table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
 <tr bgcolor="#DDDDDD">
	 <td width="14%" class="thinborder" height="20">Accession # </td>
	 <td width="13%" class="thinborder">Call Number</td>
	 <td width="18%" class="thinborder">Author</td>
	 <td width="25%" class="thinborder">Book Title</td>
	 <td width="11%" class="thinborder">Due Date</td>
<%if(!bolIsIssue){%>
	 <td width="9%" class="thinborder">Fine Type</td> 
<%}%>
	 <td width="19%" class="thinborder">Fine <%if(bolIsIssue){%>(if Overdue)<%}%></td> 
 </tr>
 <%
 for(int i = 0; i < vRetResult.size(); i += 9){%>
  <tr>
	 <td class="thinborder" height="20"><%=(String)vRetResult.elementAt(i)%></td>
	 <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
	 <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
	 <td class="thinborder">:::<%=(String)vRetResult.elementAt(i + 2)%>:::
	 						<%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"<br>","","")%></td>
	 <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
<%if(!bolIsIssue){%>
	 <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 8),"&nbsp;")%></td> 
<%}%>
	 <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td> 
 </tr>
<%}%>
 
 </table><br>
 <table width="100%" cellpadding="0" cellspacing="0" border="0">
<!--
 <tr>
 	<td width="52%"><strong><%if(bolIsIssue){%>Issued<%}else{%>Returned<%}%> by</strong>: <%=(String)vPatronInfo.elementAt(4)%></td>
 	<td width="48%" align="right">Date and time <%if(bolIsIssue){%>Issued<%}else{%>Returned<%}%> : <%=(String)vPatronInfo.elementAt(3)%>&nbsp;</td>
  </tr>
-->
 <tr>
 	<td width="52%"><strong>Librarian </strong>: <%=(String)vPatronInfo.elementAt(4)%></td>
 	<td width="48%" align="right">Date and time <%if(bolIsIssue){%>Issued<%}else{%>Returned<%}%> : <%=(String)vPatronInfo.elementAt(3)%>&nbsp;</td>
  </tr>
 <tr>
   <td>&nbsp;</td>
   <td align="right">Receipt Code : <%=strCode%>&nbsp;</td>
 </tr>
 
 <tr>
   <td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;_________________________________</td>
 </tr>
 <tr>
   <td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
   <%if(strSchoolCode.startsWith("CIT")){%>Signed By<%}else{%>Borrower's Signature<%}%>  </td>
 </tr>	
 </table>
<script language="javascript">
 window.print();
</script> 

</body>
</html>
<%
dbOP.cleanUP();
%>
	
