<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
</head>
<%@ page language="java" import="utility.*, health.Immunization,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	int iMaxCount = 0;

	int iTemp = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = "";

	int iSearchResult = 0;



//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Immunizations","immunizations_listings.jsp");
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
														"Health Monitoring","Immunizations",request.getRemoteAddr(),
														"immunizations_listing.jsp.jsp");
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
Immunization immune = new Immunization();

vRetResult = immune.viewListings(dbOP, request);
%>
<body>
<%if (vRetResult != null && vRetResult.size()>0){%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%"><div align="center"> 
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%> <br>
<br>
      </p></div></td>
      </tr>
       <tr>
       <td>&nbsp;</td>
       </tr>
</table>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr > 
      <td height="25" colspan="3" class="thinborder"><div align="center"><strong>IMMMUNIZATION LISTING</strong></div></td>
    </tr>
     
    <tr> 
      <td width="28%" height="25" class="thinborder"><div align="center" ><font size="1"><strong>ID NO.</strong></font></div></td>
      <td width="33%" class="thinborder"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
      <td width="39%" class="thinborder"><div align="center"><font size="1"><strong><%strTemp = WI.fillTextValue("srch");
      if (strTemp.length()>0){%>DEPARTMENT/OFFICE<%}else{%>COURSE/MAJOR<%}%></strong></font></div></td>
    </tr>
   <%for (int i = 0; i < vRetResult.size(); i+=7){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%></font></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
    </tr>
    <%}%>
  </table>
<script language="JavaScript">
window.print();
</script>  
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>