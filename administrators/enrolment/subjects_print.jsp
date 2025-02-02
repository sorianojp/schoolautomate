<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<body>
<%@ page language="java" import="utility.*,ems.Enrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	String strGraphInfo = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Administrators-Enrollment","enrollees.jsp");
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
														"Executive Management System","ENROLLMENT",request.getRemoteAddr(),
														"enrollees.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../administrators/administrators_bottom_content.jsp");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
Enrollment enrlInfo = new Enrollment();
if(WI.fillTextValue("sy_from").length() > 0)
{
	vRetResult = enrlInfo.getSubjectOffering(dbOP,request);
	if(vRetResult == null)
		strErrMsg = enrlInfo.getErrMsg();
	else if(WI.fillTextValue("plot2D").length() > 0 || WI.fillTextValue("plot3D").length() > 0 || 
			WI.fillTextValue("showData").length() > 0)
	{//System.out.println("I am here ");
		//plot here graph if it is called for graph.
		String strXAxisName = "School Year Level --->";String strYAxisName = "OFFERING SUBJECTS";
		int iWidthOfGraph   = 600;int iHeightOfGraph  = 500;
		String strBGColor = "#C5CACB";
		String strColumnColor="#FC9604";
		boolean bolPlot2DGraph = true;
		if(WI.fillTextValue("plot3D").length() > 0)
			bolPlot2DGraph = false;
		strGraphInfo = enrlInfo.plotSubjectOfferingGraph(vRetResult, bolPlot2DGraph,strXAxisName, strYAxisName,
									 iWidthOfGraph, iHeightOfGraph, strBGColor, strColumnColor);
		if(strGraphInfo == null)
			strErrMsg = enrlInfo.getErrMsg();//System.out.println(vRetResult);
//	System.out.println(strGraphInfo);
	}
}
String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","ALL"};

dbOP.cleanUP();
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size=3><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
</table>
<%
if(vRetResult == null || vRetResult.size()  == 0)
	return;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#97ABC1"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF">SUBJECTS 
          STATISTICS <strong>: (<%=request.getParameter("sy_from_prev") +" - "+request.getParameter("sy_to_prev")%>) 
          TO (<%=request.getParameter("sy_from") +" - "+request.getParameter("sy_to")%>) 
          : &amp;TERM : <%=astrConvertToSem[Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"4"))]%> 
          <br>
          SUBJECT OFFERINGS STATUS : <%=WI.getStrValue(request.getParameter("offering_status"),"N/A").toUpperCase()%></strong></font></div></td>
    </tr>
  </table>
<%if(WI.fillTextValue("showData").length() > 0 || 
	(WI.fillTextValue("plot2D").length() == 0 && WI.fillTextValue("plot3D").length() ==0) ){%>
  <table   width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="27%" height="25"><div align="center"><font size="1"><strong>SCHOOL 
          YEAR</strong></font></div></td>
      <td width="24%"><div align="center"><font size="1"><strong>SUBJECT OFFERING 
          STATUS</strong></font></div></td>
      <td width="28%"><div align="center"><font size="1"><strong>NO. OF SUBJECTS</strong></font></div></td>
    </tr>
<%
for(int i = 1; i< vRetResult.size(); i+=5){

	strTemp = (String)vRetResult.elementAt(i+3)+" - "+(String)vRetResult.elementAt(i+4);
%>
<!--Open-->
<%strErrMsg = WI.fillTextValue("offering_status");
if(strErrMsg.length() ==0 || strErrMsg.startsWith("O")){%>
    <tr> 
      <td height="25" align="center"><%=strTemp%></td>
      <td height="25">OPEN</td>
      <td height="25"><%=(String)vRetResult.elementAt(i)%></td>
    </tr>
<%
strTemp = "";
}if(strErrMsg.length() ==0 || strErrMsg.startsWith("C")){%>
<!--Closed-->
    <tr> 
      <td height="25" align="center"><%=strTemp%></td>
      <td height="25">CLOSED</td>
      <td height="25"><%=(String)vRetResult.elementAt(i+1)%></td>
    </tr>
<%
strTemp = "";
}if(strErrMsg.length() ==0 || strErrMsg.startsWith("D")){%>
<!--Dissolved-->
    <tr> 
      <td height="25" align="center"><%=strTemp%></td>
      <td height="25">DISSOLVED</td>
      <td height="25"><%=(String)vRetResult.elementAt(i+2)%></td>
    </tr>
<%}

}//end of for loop%>  
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="6" >&nbsp;</td>
    </tr>
</table>
<%}//only if WI.fillTextValue("plot2D").length() ==0 or show data and graph)
if(strGraphInfo != null){%>
<%=WI.getStrValue(strGraphInfo)%>
<%}%>

<!--  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="6" ><div align="right"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border=0></a>click 
          to print</div></td>
    </tr>
</table>-->


<script language="javascript">
window.print();
window.setInterval("javascript:window.close();",0);
</script>


</body>
</html>
