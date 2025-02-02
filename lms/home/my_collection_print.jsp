<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="">
<%@ page language="java" import="utility.*,lms.LmsMyHome,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;

	if( (String)request.getSession(false).getAttribute("userId") == null) {
		//do not proceed - proceed to login.
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LMS-MY Home - My Collection","my_collection.jsp");
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
LmsMyHome myHome = new LmsMyHome();
Vector vRetResult = null;
int[] aiMaxBookAllowed = null;
//view all. 
vRetResult = myHome.operateOnMyCollection(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = myHome.getErrMsg();
else if(vRetResult != null) {
	aiMaxBookAllowed = myHome.maxBookListAllowed(dbOP, (String)request.getSession(false).getAttribute("userId"),true);
	if(aiMaxBookAllowed == null) 
		strErrMsg = myHome.getErrMsg();
}
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" bgcolor="" class="thinborderALL"><div align="center"><font color="" ><strong>:::: 
          MY COLLECTION RECORD ::::</strong></font></div></td>
    </tr>
<%
if(strErrMsg != null){%>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<%}%>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
 if(aiMaxBookAllowed != null){%>
    <tr> 
      <td width="2%" height="25" class="thinborderLEFT">&nbsp;</td>
      <td width="98%" class="thinborderRIGHT"><strong><font size="2">MAX ALLOWED BOOK : <%=aiMaxBookAllowed[0]%>, You can add <%=aiMaxBookAllowed[1]%> more book(s) to your Collection list.</font></strong></td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1">SPECIAL 
          NOTE</font></strong></div></td>
      <td width="15%" height="25" class="thinborder"><div align="center"><font size="1"><strong>COLLECTION 
          TYPE </strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>ACCESSION 
          NO. / BARCODE</strong></font></div></td>
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>::: 
          TITLE ::: <br>
          SUB TITILE</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>AUTHOR</strong></font></div></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>BOOK 
          STATUS</strong></font></div></td>
      <td class="thinborder" width="6%" align="center"><strong><font size="1">CIRCULATION 
        TYPE </font></strong></td>
      <td class="thinborder" width="6%" align="center"><strong><font size="1">LOCATION</font></strong></td>
    </tr>
    <%
String[] astrConvertCheckOut = {" (Not for Checkout)"," (For Checkout)"};	
for(int i = 0; i < vRetResult.size(); i += 15){%>
    <tr> 
      <td class="thinborder" valign="top"><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+1))%></font></td>
      <td height="25" class="thinborder" valign="top">&nbsp;<font size="1"><img src="../images/<%=(String)vRetResult.elementAt(i + 8)%>" border="1"> 
        &nbsp;<%=(String)vRetResult.elementAt(i + 7)%></font></td>
      <td class="thinborder" valign="top"><font size="1"> <%=(String)vRetResult.elementAt(i+2)%>/<%=(String)vRetResult.elementAt(i + 3)%> </font></td>
      <td class="thinborder" valign="top"><font size="1">&nbsp;:::<%=(String)vRetResult.elementAt(i + 4)%>::: <br>
        &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 5))%></font></td>
      <td class="thinborder" valign="top"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 9),"N/A")%></font></td>
      <td class="thinborder" valign="top"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td class="thinborder" valign="top">&nbsp; <%=(String)vRetResult.elementAt(10)%> <%=astrConvertCheckOut[Integer.parseInt((String)vRetResult.elementAt(11))]%> </td>
      <td class="thinborder" valign="top">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(12),"N/A")%></td>
    </tr>
    <%}%>
  </table>
<script language="JavaScript">
	window.print();
</script>
<%}//end of vRetResult not null.%>

</body>
</html>
<%
dbOP.cleanUP();
%>