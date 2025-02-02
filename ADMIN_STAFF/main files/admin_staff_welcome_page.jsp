<%
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strAuthTypeIndex != null && (strAuthTypeIndex.equals("4") || strAuthTypeIndex.equals("6"))) {
	response.sendRedirect("../../commfile/logout.jsp?logout_url=../ADMIN_STAFF/main%20files/admin_staff_contentFrame.jsp");
return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="CACHE-CONTROL" content="no-cache"/> 
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript">
function LoadLeftFrame()
{
	//parent.linkFrame.location="./admin_staff_main_links.jsp";
}
</script>
<%
String strUserId = (String)request.getSession(false).getAttribute("userId");
if(strUserId == null)
{%>
		<jsp:forward page="./admin_staff_contentFrame.jsp?errorMessage=You%20are%20loggedout.%20Please%20login%20again." />
<%}		
String strName = (String)request.getSession(false).getAttribute("first_name");
if(strName == null) strName ="<NOT FOUND>";

///I have to execute auto run here. 
//utility.AutoRun aR = new utility.AutoRun(null);
//System.out.print(" I am here.");
%>
<body bgcolor="#D2AE72" onLoad="LoadLeftFrame();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          ADMIN/STAFF MAIN PAGE::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="4"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font></td>
    </tr>
<%
String strTemp = null;
String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
if(strUserIndex != null) {
	utility.DBOperation dbOP = new utility.DBOperation();
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 8);
	dbOP.cleanUP();
}
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td height="25" colspan="4">
	  <table width="100%" cellpadding="0" cellspacing="0">
		<tr>
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
		  <td width="2%">&nbsp;</td>
		</tr>
	  </table>
	  </td>
    </tr>
<%}%>
    <tr > 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="4"><div align="center"><strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">WELCOME 
          <%=strName.toUpperCase()%> TO THE ADMIN/STAFF MAIN PAGE!</font></strong></div></td>
    </tr>
    
    <tr > 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25">&nbsp; </td>
      <td width="84%" height="25" colspan="-1"> <div align="justify"> 
          <p><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Please 
            note that every activity is monitored closely. For any problem in 
            the system, contact System Administrator for details. Click the links 
            under MENU to select operation. It is recommended to logout by clicking 
            the logout button everytime you leave your PC.</font></p>
          <p><font size="2" face="Verdana, Arial, Helvetica, sans-serif">If you 
            do not agree with the conditions or you are not <b> <%= strUserId %> 
            </b> Logout now.</font> </p>
        </div></td>
      <td width="8%" height="25" colspan="-1">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
