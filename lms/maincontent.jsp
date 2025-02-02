<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>maincontent</title>
<link href="../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<%
String strUserId = (String)request.getSession(false).getAttribute("userId");
String strName =(String)request.getSession(false).getAttribute("first_name");
if(strName == null) strName = strUserId;
if(strName == null) strName = "";

String strUserIDField = "_"+Long.toString(new java.util.Date().getTime());
String strPwdField    = strUserIDField + "0";

%>
<script language="javascript" src="../jscript/common.js"></script>
<script language="JavaScript">
function FocusID() {
<%if(strUserId == null || strUserId.trim().length() == 0){%>
	document.form_.<%=strUserIDField%>.focus();
<%}//to avoid java script error when user is already logged in .. but iit is very rare..%>
}
</script>
<body bgcolor="#E9E9E9" leftmargin="2" topmargin="2" onLoad="FocusID();">
<div align="justify">
  <table width="100%" border="0">
    <tr>
      <td width="36%" height="74" valign="top" >
<%
if(strUserId == null || strUserId.trim().length() == 0)
{%>
<form name="form_"  action="../commfile/login.jsp" method="post" target="_parent" onSubmit="SubmitOnceButton(this);">
          <table width="100%" border="0" bgcolor="#ADC4D3" class="thinborderALL">
            <tr>
              <td width="47%" valign="middle" bgcolor="#ADC4D3"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><font color="#000099" size="1"><strong>Login
                name</strong></font></font> </td>
              <td width="53%" bgcolor="#ADC4D3"><p>
	  <input type="text" name="<%=strUserIDField%>" size="16" class="username_field" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" autocomplete="off">
	  <input type="hidden" name="user_id"  value="<%=strUserIDField%>">
<!--
	  <input type="text" name="user_id" class="username_field" onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
-->
              </td>
            </tr>
            <tr>
              <td valign="middle" bgcolor="#ADC4D3"><font color="#FF6600" size="1" face="Verdana, Arial, Helvetica, sans-serif"><font color="#000099"><strong>Password</strong></font></font>
                <font size="1">&nbsp;&nbsp; </font></td>
              <td width="53%" bgcolor="#ADC4D3">
	  <input type="password" name="<%=strPwdField%>" size="16" class="password_field" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" autocomplete="off">
	  <input type="hidden" name="password"  value="<%=strPwdField%>">
	  <input type="hidden" name="is_secured" value="1"><!-- this is must to provide 1-->
<!--
	  	<input type="password" name="password" class="password_field" onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
-->
			   </td>
            </tr>
            <tr>
              <td height="33" colspan="2" bgcolor="#ADC4D3" > <div align="center">&nbsp;&nbsp;
                  <input type="submit" name="Submit" value="&nbsp;Login&nbsp;"
				  style="font-size:14px; height:24px;border: 1px solid #FF0000; font-family:Verdana, Arial, Helvetica, sans-serif">
                </div></td>
            </tr>
          </table>
	<input type="hidden" name="body_color" value="#E9E9E9">
	<!-- relative to commfile -->
	<input type="hidden" name="welcome_url" value="../lms/index.jsp">
	<input type="hidden" name="login_type" value="admin_staff">
        </form>
<%}%>
		</td>
      <td width="64%" valign="top"><p><strong><font size="1" color="#003366" face="Verdana, Arial, Helvetica, sans-serif">Online
          Library Management System</font></strong><font color="#000000" size="1">
          provides power and productivity to small, medium and huge library centers.
          With this feature-rich Online LMS, there is never a need to worry on
          valuable data. All of your data, including archival data, remains instantly
          accessible all the time&#8212;with no system slowdown. Up-to-date information
          on books, members and status reports is just a click away. Broadcasting
          feature is added in the system to help not only the administrations
          but also the members in information dissemination. Security of data
          is never a question with multiple implementation procedures, from associating
          username to links the user is authorized to visit, access level rights,
          to recording of every transaction that the system is handling. Online
          LMS is user-friendly and valuable in giving much needed information,
          anytime, anywhere.</font></td>
    </tr>
  </table>
  <font color="#003366" size="2" face="Arial, Helvetica, sans-serif"><strong><font face="Verdana, Arial, Helvetica, sans-serif">FEATURES
  :</font></strong></font>
  <table width="100%" border="0">
    <tr>
      <td width="44%" valign="top"> <p><font color="#000066" size="1" face="Verdana, Arial, Helvetica, sans-serif">&#8226;
          <strong>ALL In ONE System.</strong> </font><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Administration,
          Cataloging, Circulation, Online Public Access Catalog (OPAC), Online
          Students Status Query (OSTQ), Bulletin Board, and Feedback System, all
          integrated in one system. </font></p>
        <p><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><em><strong><font color="#003399">Online 
          Student&#8217;s Status Query (OSSQ) </font></strong></em><br>
          * allows students to check his/her borrowing status such as what book(s)
          are issued to him/her, overdue books, due dates, and updated fines.</font></p>
        <p><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><em><font color="#003399">Bulletin
          Board</font></em></strong><br>
          * a page which serves as bulletin or announcement board allowing the
          administrator and library staff to post announce-ments or reminders
          visible to librarians only, to students, or everybody using the system.
          </font></p>
        <p><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><em><strong><font color="#003399">Feedback
          System </font></strong></em><br>
          * let everybody (whether member or nonmember) post comments about the
          system, and also recommend books which the user deemed important to
          be made available in the library.</font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
          </font></p>
        </td>
      <td width="1%">&nbsp;</td>
      <td width="55%" valign="top"><p><font color="#000066" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong><font size="1">&#8226;
          INTERNET Ready.</font></strong> </font><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Using
          the latest technology in software development, the system can be uploaded
          on the net without problem on its compatibility.</font></p>
        <p><font color="#000066" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&#8226;
          Unlimited Users License.</strong></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif">
          Only one license is needed for each institution installation. No need
          for licensing the clients to access the system. </font></p>
        <p><font color="#000066" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&#8226;
          Multilevel Security Implementation</strong></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif">
          through the use of username/password, no simultaneous logging in of
          one username, access level rights, limited attempts, and recording of
          transactions.</font></p>
        <p><font color="#000066" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&#8226;
          Comprehensive Search Tool.</strong></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif">
          With multiple search criteria set in the system, there is no need to
          know more data to get the information desired. </font></p>
        <p><font color="#000066" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&#8226;
          Comprehensive Report Generation.</strong> </font><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Whatever
          type of report the library needs to generate are provided by the system.</font></p>
        <p><font color="#000066" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&#8226;
          Personalized Info Page.</strong></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif">
          Links for personal homepage showing personal info, membership status,
          book borrowing status, changing of password, and even announcement intended
          for you are provided giving fast and easy access to individual information.
          </font></p></td>
    </tr>
  </table>

</div>
</body>

</html>
