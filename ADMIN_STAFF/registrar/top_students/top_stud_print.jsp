<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
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
</style></head>
<body>
<%@ page language="java" import="utility.*,student.GWA,java.util.Vector " %>
<%
 
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String[] astrConvertToYear = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year"};
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-TOP STUDENTS","top_stud.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","TOP STUDENTS",request.getRemoteAddr(), 
							//							"top_stud.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=comUtil.getErrMsg()%></font></p>
		<%
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	
GWA gwa = new GWA();
Vector vTopStudInfo = null;
vTopStudInfo = gwa.calGWAForASYAndSem(dbOP,request);
dbOP.cleanUP();

if(vTopStudInfo == null)
{
	strErrMsg = gwa.getErrMsg();
	if(strErrMsg == null)
		strErrMsg = "Error in calculating top student list.";
	%>
	<p> <font size=3 face="Verdana, Arial, Helvetica, sans-serif"><%=strErrMsg%></font>
	<%
	return;
}



if(vTopStudInfo != null && vTopStudInfo.size() > 0){%>
  
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="2"><div align="center"><strong>LIST OF TOP STUDENTS 
        FOR COURSE : <%=request.getParameter("cn")%> 
        <%
		  if(WI.fillTextValue("mn").length()>0){%>
        (<%=request.getParameter("mn")%>) 
        <%}%>
        </strong></div></td>
  </tr>
  <tr> 
    <td height="25">Condition for GWA calculation : GWA range - <%=request.getParameter("gwa_from")+" to "+request.getParameter("gwa_to")%></td>
    <td width="30%" colspan="-1">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" colspan="2">Minimum units required : <%=request.getParameter("min_req_unit")%> 
      &nbsp;&nbsp;&nbsp;&nbsp; Minimum final grade : <%=request.getParameter("min_final_grade")%></td>
  </tr>
  <tr> 
    <td height="18">&nbsp;</td>
    <td width="30%" colspan="-1">&nbsp;</td>
  </tr>
  <tr> 
    <td height="18">School Offering Year from/to/semester : <%=request.getParameter("sy_from")+"-"+request.getParameter("sy_to")%>/<%=astrConvertToSem[Integer.parseInt(request.getParameter("offering_sem"))]%></td>
    <td width="30%" colspan="-1">Year Level : <%=astrConvertToYear[Integer.parseInt(request.getParameter("year_level"))]%></td>
  </tr>
  <tr> 
    <td height="25">Total no. of students : <strong><%=vTopStudInfo.size()/5%></strong></td>
    <td colspan="-1"></div></td>
  </tr>
</table>
	
  <table width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="22%" height="25" align="center" ><strong>STUDENT 
        ID</strong></td>
      <td width="52%" align="center" ><strong>STUDENT NAME</strong></td>
      <td width="12%" align="center"><strong>LOAD UNITS</strong></td>
      <td width="14%" align="center"><strong>GWA</strong></td>
    </tr>
<%
for(int i=0; i< vTopStudInfo.size(); ++i){%>
    <tr>
      <td height="25"><%=(String)vTopStudInfo.elementAt(i+3)%></td>
      <td><%=(String)vTopStudInfo.elementAt(i+4)%></td>
      <td align="center"><%=(String)vTopStudInfo.elementAt(i+1)%></td>
      <td align="center"><%=(String)vTopStudInfo.elementAt(i+2)%></td>
    </tr>
<%
i = i+4;
}%>

  </table>
<%
	}//vTopStudInfo is not null
%>
<script language="javascript">
window.print();
</script>

</body>
</html>
