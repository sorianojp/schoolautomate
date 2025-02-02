
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">	
</head>

<body topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,lms.CatalogReport,java.util.Vector" %>
<%
	WebInterface WI      = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-REPORTS","periodical_report.jsp");
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


/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Cataloging","LIBRARY COLLECTION",request.getRemoteAddr(),
														"add_collection_standard.jsp");
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
*/

String[] astrDropListEqual = {"Any Keywords","All Keywords","Contains","Equal to","Starts with","Ends with"};
String[] astrDropListValEqual = {"any","all","contains","equals","starts","ends"};
String[] astrDropListBoolean = {"and","or","not"};
String[] astrDropListValBoolean = {"and","or","not"};
String[] astrSortByName    = {"Accession No","Title","Author"};
String[] astrSortByVal     = {"accession_no","book_title","author_name"};

Vector vRetResult = null;
CatalogReport CR = new CatalogReport();
int iElemCount = 0;
int iSearchResult  = 0;


vRetResult = CR.generatePeriodicalReport(dbOP, request);
if(vRetResult == null)
	strErrMsg = CR.getErrMsg();
else{
	iSearchResult = CR.getSearchCount();
	iElemCount = CR.getElemCount();
}

	

if(vRetResult != null && vRetResult.size() > 0){



int iRowCount = 1;
int iNoOfStudPerPage = 45;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
	
	

int iPageCount = 1;
int iTotalStud = (vRetResult.size()/iElemCount);
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud % iNoOfStudPerPage > 0)
	++iTotalPageCount;
boolean bolPageBreak = false;
for(int i = 0; i < vRetResult.size(); ){
	iRowCount = 1;
	if(bolPageBreak){
		bolPageBreak = false;
		%>
		<div style="page-break-after:always;">&nbsp;</div>
	<%}


%>
  
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	
	<tr> 
      <td height="25" colspan="2" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong>
	  	<br><%=SchoolInformation.getAddressLine1(dbOP, false, false)%><br><br><strong>PERIODICAL REPORT</strong></td>
    </tr>
    
</table>
<br><br>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="26%" height="25" class="thinborder"><strong>Title of Periodicals</strong></td>
		<td width="22%" class="thinborder"><strong>Article Title</strong></td>
		<td width="18%" class="thinborder"><strong>Author</strong></td>
		<td width="19%" class="thinborder"><strong>Subject of Article</strong></td>
		<td width="15%" class="thinborder"><strong>Date</strong></td>
	</tr>
	<%
	
	String[] astrConvertMM = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };
	
	
	for(; i < vRetResult.size(); ){
		strTemp = "";
		if(WI.getStrValue(vRetResult.elementAt(i+10)).length() > 0)
			strTemp = astrConvertMM[Integer.parseInt((String)vRetResult.elementAt(i+10))];
		if(WI.getStrValue(vRetResult.elementAt(i+11)).length() > 0)
			strTemp += " "+WI.getStrValue(vRetResult.elementAt(i+11));
		if(WI.getStrValue(vRetResult.elementAt(i+12)).length() > 0){
			if(WI.getStrValue(vRetResult.elementAt(i+11)).length() > 0 || WI.getStrValue(vRetResult.elementAt(i+10)).length() > 0)
				strTemp += ", ";
			strTemp += WI.getStrValue(vRetResult.elementAt(i+12));
		}
	%>
	<tr>
		<td class="thinborder" height="22"><%=WI.getStrValue(vRetResult.elementAt(i+2),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+13),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<%
		i+=iElemCount;
		if(++iRowCount > iNoOfStudPerPage){					
			bolPageBreak = true;
			break;
		}
	}
	
	if(iNoOfStudPerPage > iRowCount){	
		for(int x = iNoOfStudPerPage; x >= iRowCount; x--){%>
	<tr><td height="22" class="thinborder">&nbsp;</td>
	    <td height="22" class="thinborder">&nbsp;</td>
	    <td height="22" class="thinborder">&nbsp;</td>
	    <td height="22" class="thinborder">&nbsp;</td>
	    <td height="22" class="thinborder">&nbsp;</td>
	</tr>
	<%}
	}%>	
</table>
  <div style="text-align:center">Page <%=iPageCount++%> of <%=iTotalPageCount%></div>
  
<%}}%>

	
</body>
</html>
<%
dbOP.cleanUP();
%>