<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">

</head>
<%@ page language="java" import="utility.*,lms.CatalogReport,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-Reports-Card Print Info-Print","card_print_info_print.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Cataloging","REPORTS",request.getRemoteAddr(),
														"card_print_info_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.


CatalogReport CR   = new CatalogReport();
Vector vRetResult  = null;

//iAction 3 is never used.. 
if(WI.fillTextValue("accession_no").length() > 0) {
	vRetResult = CR.operateOnCatalogReportFormat(dbOP, request, 4);
	if(vRetResult != null)
		vRetResult.remove(0);
	else
		strErrMsg = CR.getErrMsg();
}

%>


<body onLoad="window.print();">
<%
for(int i = 0; i < vRetResult.size(); i += 8){
strErrMsg = ((String)vRetResult.elementAt(i + 1)).toLowerCase();
//System.out.println(strErrMsg);
if(strErrMsg.startsWith("shelf"))
	strErrMsg = " SHELF LIST";
else if(strErrMsg.startsWith("control"))
	strErrMsg = " CONTROL FILE";
else	
	strErrMsg = "";	
if(strErrMsg.length() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr valign="top"> 
      <td>&nbsp;</td>
      <td style="font-weight:bold">&nbsp;</td>
      <td align="right"><%=strErrMsg%></td>
    </tr>
</table>
<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr valign="top"> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="28%"><pre><%=vRetResult.elementAt(i + 2)%></pre></td>
      <td width="70%"><pre><%=vRetResult.elementAt(i + 3)%></pre></td>
    </tr>
</table>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%}//end of for loop..%>
</body>
</html>
<%
dbOP.cleanUP();
%>