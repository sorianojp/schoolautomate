<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#F2DFD2">
<%@ page language="java" import="utility.*,lms.Search,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LMS-Search-simple","search_simple_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

int iSearchResult = 0;

Search searchBook = new Search(request);
if(WI.fillTextValue("searchCollection").compareTo("1") == 0){
	vRetResult = searchBook.searchBookSimple(dbOP);
	if(vRetResult == null)
		strErrMsg = searchBook.getErrMsg();
	else	
		iSearchResult = searchBook.getSearchCount();
}
if(strErrMsg != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
</table>
	  
<%}else if(vRetResult != null && vRetResult.size() > 0){%>
  
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
  <%
  strTemp = "select loc_name from LMS_LIBRARY_LOC where loc_index = "+WI.fillTextValue("LOC_INDEX");
  strTemp = dbOP.getResultOfAQuery(strTemp, 0);
  %> 
    <td height="25" bgcolor="#DDDDEE" class="thinborderALL"><div align="center"><strong><font color="#FF0000">LIBRARY 
        BOOK COLLECTION SEARCH RESULT <%=WI.getStrValue(strTemp,"(",")","")%></font></strong></div></td>
  </tr>
  <tr> 
    <td width="72%" height="25" class="thinborderLEFTRIGHT"><b> Total Collection : 
      <%=iSearchResult%></b></td>
  </tr>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td width="13%" height="25" class="thinborder"><div align="center"><font size="1"><strong>COLLECTION 
        TYPE </strong></font></div></td>
    <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>ACCESSION 
        NO. / BARCODE</strong></font></div></td>
	<td width="13%" class="thinborder"><div align="center"><font size="1"><strong>CALL NUMBER</strong></font></div></td>		
    <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>::: 
        TITLE ::: <br>
        SUB TITILE</strong></font></div></td>
    <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>AUTHOR</strong></font></div></td>
	<td width="10%" class="thinborder"><div align="center"><font size="1"><strong>EDITION</strong></font></div></td>
    <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>BOOK 
        STATUS</strong></font></div></td>
  </tr>
  <%
for(int i = 0; i < vRetResult.size(); i += 12){%>
  <tr> 
    <td height="25" class="thinborder">&nbsp;<font size="1"><img src="../images/<%=(String)vRetResult.elementAt(i + 7)%>" border="1"> 
      &nbsp;<%=(String)vRetResult.elementAt(i + 6)%></font></td>
    <td class="thinborder"><font size="1"> 
      <%if(WI.fillTextValue("opner_info").length() > 0) {%>
      <a href='javascript:CopyAccessionNo("<%=(String)vRetResult.elementAt(i+1)%>");'> 
      <%=(String)vRetResult.elementAt(i+1)%>/ <%=(String)vRetResult.elementAt(i + 2)%></a> 
      <%}else{%>
      <%=(String)vRetResult.elementAt(i+1)%>/ <%=(String)vRetResult.elementAt(i + 2)%> 
      <%}%>
      </font></td>
	  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>
    <td class="thinborder"><font size="1">&nbsp;:::<%=(String)vRetResult.elementAt(i + 3)%>::: <br>
      &nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 4))%></font></td>
    <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"N/A")%></font></td>
	<td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 11))%></font></td>
    <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></font></td>
  </tr>
  <%}%>
</table>
<script language="JavaScript">
window.print();
window.setInterval("javascript:window.close();",0);
</script>
<%}//end of vRetResult not null.%>
</body>
</html>
<%
dbOP.cleanUP();
%>