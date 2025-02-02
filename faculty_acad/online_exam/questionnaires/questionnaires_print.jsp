<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>

</script>
<body>
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,java.util.Vector " %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	String strSubName = null;
	Vector vRetResult = new Vector();
	boolean bolFatalErr = false;
		
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		//exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
OLECommonUtil oleComUtil = new OLECommonUtil();

if(!bolFatalErr)
{
	vRetResult = oleComUtil.getQuestionnairList(dbOP,request);
	if(vRetResult == null)
		strErrMsg = oleComUtil.getErrMsg();
}

dbOP.cleanUP();
if(strErrMsg == null) strErrMsg = "";

%>
  <table width="100%" border="0" >
    <tr> 
      <td colspan="5"> <font size="3">&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></font></td>
    </tr>
    
    <tr> 
      <td width="2%">&nbsp;</td>
    <td colspan="4">Questionnaire parameters prepared by : <strong><%=request.getParameter("q_by")%></strong></td>
    </tr>
	</table>
  <table width="100%" border="0" >
    <tr> 
      <td colspan="2"><hr size="1"> </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
    <td>Subject :
<%
strTemp = WI.fillTextValue("s_code");
if(strTemp.compareToIgnoreCase("all") ==0){%>
<strong>All</strong>
<%}else{%>
	<strong> <%=request.getParameter("s_code")%> (<%=request.getParameter("s_name")%>)</strong>
<%}%>
</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      
    <td height="25">Examination Period : <strong><%=request.getParameter("e_name")%></strong></td>
    </tr>
	<tr> 
      <td colspan="2"><hr size="1"> </td>
    </tr>
  </table>
<%
if(vRetResult != null)
{%>
  <table   width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6"><div align="center">LIST OF QUESTIONNAIRES </div></td>
    </tr>
  </table>
	
  
<table   width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr> 
    <td width="10%" height="25" class="thinborder"><div align="center"><strong>SUBJECT CODE</strong></div></td>
    <td width="25%" class="thinborder"><div align="center"><strong>SUBJECT TITLE</strong></div></td>
    <td width="12%" class="thinborder"><div align="center"><strong>EXAMINATION PERIOD</strong></div></td>
    <td width="28%" class="thinborder"><div align="center"><strong>QUESTIONNAIRE NAME</strong></div></td>
    <td width="9%" class="thinborder"><div align="center"><strong>DURATION</strong></div></td>
  </tr>
  <%
for(int i=0;i<vRetResult.size(); ++i)
{%>
  <tr> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
  </tr>
  <%
i = i+5;
}%>
</table>
 <%
 }//end of showing questionnairs
if(strErrMsg == null || strErrMsg.length() == 0){ %>
<script language="JavaScript">
window.print();
</script>
 <%}%>
</body>
</html>
