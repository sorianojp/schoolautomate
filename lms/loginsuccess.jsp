<html>

<head>
<meta http-equiv="Content-Language" content="en-us">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>Login Success</title>
</head>
<style type="text/css">
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 16px;	
    }
</style>

<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

<% 

	String strUserId = (String)request.getSession(false).getAttribute("userId");
	if(strUserId == null)
		strUserId = "";
	
%>



<body bgcolor="#BED6E0">
<%if(strUserId.length() > 0){%>
<table border="0" width="100%" class="thinborderALL">
  <tr> 
    <td colspan="2" bgcolor="#000080" height="25" align="center"> 
      <font color="#FFFFFF"><strong>Login Success Page</strong></font></td>
  </tr>
  <tr> 
    <td colspan="2"></td>
  </tr>
  <tr> 
    <td colspan="2"><div align="center"><b><br>
        <u> Please read below the License Agreement</u></b></div></td>
  </tr>
  <tr> 
    <td colspan="2">&nbsp; </td>
  </tr>
  <tr> 
    <td width="82%"> <div align="justify">Please note that every activity is monitored 
        closely. For any problem in the system, contact System Administrator for 
        details. You can follow the links to access your personal information 
        or browsing book Information. It is recommended to logout everytime you 
        leave your PC. </div>
      <p align="justify">If you do not agree with the conditions or you are not 
        <b> <%= strUserId %> </b> Logout now. 
		Click <a href="./patron_info/patron_summary.jsp">My Home</a> to go to your circulation summary page. </td>
    <td width="18%" valign="top">
	<table class="thinborderALL">
	<tr>
	      <td><img src="../upload_img/<%=strUserId.toUpperCase() + "."+(String)request.getSession(false).getAttribute("image_extn")%>" width="150" height="150"></td>
        </tr></table></td>
  </tr>
  <tr> 
    <td></td>
    <td></td>
  </tr>
  <tr> 
    <td width="82%"></td>
    <td width="18%"></td>
  </tr>
</table>
<%}else{%>
<table width="100%" cellpadding="5" cellspacing="10">
  <tr> 
    <td><div align="center"><br><br><br>
         <font size="5">You are Logged out. Please login again.</font></div></td>
  </tr>
</table>
<%}%>
</body>

</html>