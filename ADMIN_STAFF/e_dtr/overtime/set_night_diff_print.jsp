<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.OverTime,eDTR.eDTRUtil" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = "";

//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Overtime Management-Night Differential Parameter","set_night_diff.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"set_night_diff.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
OverTime ot = new OverTime();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
Vector vRetResult = null;
Vector vEditInfo = null;



vRetResult = ot.operateOnNightDiff(dbOP,request,4);
String[] astrAddOnUnit1 = {"%"," "};
String[] astrAddOnUnit2 = {"Per Hour","Per Duty/Day"};
%>


  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;&nbsp;
	  <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%></td>
    </tr>
  </table>
<% if (vRetResult != null) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td class="thinborder" height="25" colspan="4"><div align="center"><strong>NIGHT 
      DIFFERENTIAL PARAMETERS </strong></div></td>
    </tr>
    <tr>
      <td class="thinborder" width="27%"><div align="center"><strong><font size="1">POSITION</font></strong></div></td> 
      <td class="thinborder" width="27%" height="26"><div align="center"><font size="1"><strong>EFFECTIVITY 
         DATE</strong></font></div></td>
      <td class="thinborder" width="33%"><div align="center"><strong><font size="1">TIME 
          CONSIDERED FOR NIGHT DIFF</font></strong></div></td>
      <td class="thinborder"><div align="center"><strong><font size="1">ADD-ON TO SALARY/WAGE</font></strong></div></td>
    </tr>
 <%
 for (int i = 0; i<vRetResult.size(); i+=14) {
 	if ((String)vRetResult.elementAt(i+1) != null) 
		strTemp = "-" + WI.formatDate((String)vRetResult.elementAt(i+1), 10);
	else strTemp = "- present";
 %>
    <tr>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i+13),"")%></td> 
      <td height="25" class="thinborder">&nbsp;<%=WI.formatDate((String)vRetResult.elementAt(i),10)%>
	  <%=strTemp%></td>
      <td class="thinborder"><div align="center"><%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+3),
	  (String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5))%> - <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+6),(String)vRetResult.elementAt(i+7),
	  (String)vRetResult.elementAt(i+8))%></div></td>
      <td width="24%" class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+9)+  
	    									 astrAddOnUnit1[Integer.parseInt((String)vRetResult.elementAt(i+10))] + " " +  
	   										 astrAddOnUnit2[Integer.parseInt((String)vRetResult.elementAt(i+11))]%></div></td>
    </tr>
 <%}%>
  </table>
 <%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>