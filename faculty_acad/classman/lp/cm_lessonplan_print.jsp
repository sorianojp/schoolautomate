<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMLessonPlan" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.


try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Lesson Plan","cm_lessonplan_print.jsp.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(), 
														"cm_lessonplan_print.jsp.jsp");	
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
String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);

String strSYFrom = WI.fillTextValue("sy_from");
String strSYTo = WI.fillTextValue("sy_to");
if(strSYFrom.length() ==0)
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strSYTo.length() ==0)
	strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");

CMLessonPlan cm = new CMLessonPlan();
Vector vRetResult = null;
Vector vEditInfo = null;

vEditInfo = cm.operateOnContents(dbOP,request,6);

vRetResult = cm.operateOnContents(dbOP,request,4);
	if (vRetResult == null && strErrMsg == null){
		strErrMsg = cm.getErrMsg();
	}

%>
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">	
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
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

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
	TABLE.thinborderALL{
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

</head>
<body onLoad="window.print()">
<form action="cm_lessonplan.jsp" method="post" name="form_" id="form_">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp; </td>
      <td height="25"><strong>SCHOOL YEAR :</strong></td>
      <td height="25"><%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></td>
      <td width="9%" height="25">&nbsp;</td>
      <td width="33%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="2%">&nbsp;</td>
      <td width="14%"><strong>SUBJECT CODE:</strong></td>
      <td width="42%"><%=WI.fillTextValue("subj_label")%> <%=WI.getStrValue(dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),
		  "sub_name"," and is_del=0"),"(",")","")%></td>
      <td><strong>SECTION:</strong></td>
      <td><%=WI.fillTextValue("section_name")%>&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%	if (vRetResult  != null && WI.fillTextValue("sy_to").length() > 0
		 && WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0
		  && WI.fillTextValue("date_for").length() > 0) { %>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="30" colspan="2"><div align="center"><strong><font size="2">LESSON 
          PLAN FOR <%=WI.fillTextValue("date_for")%></font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <% 	int iIndex = 0;
	for (int i = 0; i < vRetResult.size() ; i+=6) {
		if (vRetResult.elementAt(i) != null){ %>
    <tr bgcolor="#D5EAEA"> 
      <td width="30%" height="25" class="thinborder">&nbsp;</td>
      <td width="72%" class="thinborderBottom"><strong><font color="#FF0000"><%=(String)vRetResult.elementAt(i+1)%> </font></strong></td>
    </tr>
    <%}// if elementAt(i) != null%>
    <tr> 
      <td class="thinborder" height="25"><strong><%=((String)vRetResult.elementAt(i+4)).toUpperCase()%></strong></td>
      <td class="thinborder"> <%
	  	if (vEditInfo != null){	
			iIndex = vEditInfo.indexOf(vRetResult.elementAt(i+3));
		if (iIndex != -1){
				strTemp = 	WI.getStrValue((String)vEditInfo.elementAt(iIndex+1),"N/A");
				vEditInfo.removeElementAt(iIndex);
				vEditInfo.removeElementAt(iIndex);
		}else strTemp = "&nbsp;";}%>
		<%=WI.getStrValue(strTemp)%></td>
    </tr>
    <%}%>
  </table>
<%}// end vRetResult != null %>

</form>
</body>
</html>