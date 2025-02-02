<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
</script>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	if(request.getSession(false).getAttribute("userIndex") == null) {%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			You are already logged out. Please login again.</font></p>
		<%
		return;
	}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.

try	{
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
ClassMgmt.CMStudPerformance studPerformance = new ClassMgmt.CMStudPerformance();
Vector vRetResult = studPerformance.getFieldWorkPerStudent(dbOP, request);
if(vRetResult == null)
	strErrMsg = studPerformance.getErrMsg();

%>
<body bgcolor="#93B5BB">
<form name="cm_op" method="post" action="./fieldwork_ojt.jsp" onSubmit="SubmitOnceButton(this);">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#6A99A2"> 
      <td width="656" height="25"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FIELD WORK INFORMATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="16%" height="25"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr bgcolor="#98B9CD"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><strong>FIELD WORK DETAIL</strong></div></td>
    </tr>
    <tr> 
      <td width="10%" class="thinborder"><div align="center"><strong>Subject Code </strong></div></td>
      <td width="20%" height="25" class="thinborder"><div align="center"><strong>Subject Title </strong></div></td>
      <td width="8%" class="thinborder" style="font-size:11px; font-weight:bold;" align="center">Sy-Term</td>
      <td width="15%" class="thinborder" style="font-size:11px; font-weight:bold;" align="center">Company Information </td>
      <td width="8%" class="thinborder" style="font-size:11px; font-weight:bold;" align="center">Start Date </td>
      <td width="8%" class="thinborder" style="font-size:11px; font-weight:bold;" align="center">End Date </td>
      <td width="16%" class="thinborder" style="font-size:11px; font-weight:bold;" align="center">Work Profile </td>
      <td width="15%" class="thinborder" style="font-size:11px; font-weight:bold;" align="center">Performance</td>
    </tr>
<%
String[] astrConvertTerm ={"Summer","1st Sem","2nd Sem","3rd Sem"};
for(int i =0; i < vRetResult.size(); i += 10){%>
    <tr> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%> - <%=astrConvertTerm[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></td>
      <td class="thinborder"><font color="#0000FF"><%=(String)vRetResult.elementAt(i + 4)%></font><br><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 9)%></td>
    </tr>
<%}//%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5" align="center">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
	<tr bgcolor="#6A99A2"> 
    	<td height="25">&nbsp;</td>
  	</tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>