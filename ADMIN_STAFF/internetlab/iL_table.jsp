<%@ page language="java" import="utility.*,iCafe.TimeInTimeOut,iCafe.ComputerUsage,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	int iRefreshTime = 0;
	String strErrMsg = null;
	String strTemp = WI.getStrValue(WI.fillTextValue("refresh_time"),"3");

	iRefreshTime = Integer.parseInt(strTemp);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<META HTTP-EQUIV="REFRESH" CONTENT="<%=iRefreshTime*60%>; URL=javascript:ReloadPage();" >
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>

<script language="JavaScript">
function ReloadPage() {
	document.form_.logout_.value = "";
	document.form_.submit();
}
function TransferStudent(strIndex){
	location = "./iL_assign.jsp";
}
function LogOut() {
	document.form_.logout_.value = "1";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET LAB OPERATION - comp usage",
								"iL_table.jsp");
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
														"Internet Cafe Management",
														"INTERNET LAB OPERATION",request.getRemoteAddr(),
														"iL_table.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
TimeInTimeOut tinStud   = new TimeInTimeOut();
ComputerUsage compUsage = new ComputerUsage();

Vector vRetResult = null;
Vector vLocInfo   = null;
if(WI.fillTextValue("logout_").length() > 0) {
	tinStud.forceLogout(dbOP, request);
	strErrMsg = tinStud.getErrMsg();
}

vLocInfo   = tinStud.internetCafeAvailability(dbOP, request.getRemoteAddr());
if(vLocInfo == null) 
	strErrMsg = tinStud.getErrMsg();
else {
	//get here lab usage detail.
	vRetResult = compUsage.viewComputerUsage(dbOP, request.getRemoteAddr());
	if(vRetResult == null)
		strErrMsg = compUsage.getErrMsg();
}


%>
<form action="./iL_table.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INTERNET LAB OPERATION - VIEW INTERNET LAB USAGE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="47%">DATE - TIME : <strong><%=WI.getTodaysDateTime()%></strong></td>
      <td width="52%"> ATTENDANT NAME : <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></td>
    </tr>
  </table>

<%
if(vLocInfo != null && vLocInfo.size() > 0){%>	  
  <table width="100%" border="0" cellpadding="1" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFF9F"> 
      <td height="25" colspan="8"><div align="center"><font color="#0000FF"><strong>LIST 
          OF COMPUTERS IN USE</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="30" colspan="3"><font size="1">TOTAL NO. OF COMPUTER(S)/ COMPUTERS 
        FREE : <strong><%=(String)vLocInfo.elementAt(1)%>/<%=(String)vLocInfo.elementAt(2)%></strong></font></td>
      <td height="30" colspan="5"><div align="right"><font size="1">LOCATION : 
          <%=(String)vLocInfo.elementAt(0)%>&nbsp;&nbsp;&nbsp; </font></div></td>
    </tr>
    <%
if(vRetResult != null && vRetResult.size() > 0){%>
    <tr bgcolor="#FFFFFF"> 
      <td width="10%"><div align="center"><font size="1"><strong>COMP. NAME </strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>STUD ID</strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>STUD NAME (lname,fname, 
          mi)</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>LOGIN TIME</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>EXPTD. LOGOUT 
          TIME</strong></font></div></td>
      <td width="10%"><strong><font size="1">BALANCE USAGE IN MINS</font></strong></td>
      <td width="12%" height="24"><div align="center"><font size="1"><strong>TRANSFER 
          PC </strong></font></div></td>
      <td width="13%"><font size="1"><strong><a href="javascript:LogOut();">LOG OUT</a></strong> (click to logout 
        selected PCs)</font></td>
    </tr>
    <%//System.out.println(vRetResult);
String strFontColor = null;//if user should log out, change the color to grey.
int j = 0;
for(int i = 0; i < vRetResult.size(); i += 13,++j){
if( ((String)vRetResult.elementAt(i + 9)).compareTo("1") == 0)
	strTemp = "color=red";
else
	strTemp = "";
if( ((String)vRetResult.elementAt(i + 8)).compareTo("1") == 0)
	strFontColor = "#999900";
else
	strFontColor = "#000000";
%>
    <tr bgcolor="#FFFFFF"> 
      <td><font color="<%=strFontColor%>"> 
        <%=WI.getStrValue(vRetResult.elementAt(i),"<font color=#0099CC>Not Assigned</font>")%></font></td>
      <td><font color="<%=strFontColor%>"> 
        <font size="1" <%=strTemp%>><%=(String)vRetResult.elementAt(i + 2)%></font></font></td>
      <td><font color="<%=strFontColor%>"><%=(String)vRetResult.elementAt(i + 3)%></font></td>
      <td><font color="<%=strFontColor%>"><%=(String)vRetResult.elementAt(i + 4)%></font></td>
      <td><font color="<%=strFontColor%>"><%=(String)vRetResult.elementAt(i + 5)%></font></td>
      <td><font color="<%=strFontColor%>"><%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td align="right"><a href="javascript:TransferStudent(<%=(String)vRetResult.elementAt(i + 7)%>);"> 
        <img src="../../images/update.gif" border="0"></a><font size="1"> transfer 
        </font></td>
      <td align="center">
	  <input type="checkbox" value="1" name="<%=j%>">
	  <input type="hidden" name="stud_id<%=j%>" value="<%=(String)vRetResult.elementAt(i + 7)%>">
	  </td>
    </tr>
    <%}//end of for loop%>
	 <input type="hidden" name="max_stud_" value="<%=j%>">
<%
}//end of display if vRetResult != null
%>
  </table>
 <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="30" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
</table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">NOTE: This page will refresh after every <%=iRefreshTime%> minutes 
        : New refresh time (mins) : 
<select name="refresh_time">
<%
for(int i = 1 ; i < 16; ++i){
	if(iRefreshTime == i){%>
	<option value="<%=i%>" selected><%=i%></option>
<%}else{%>
	<option value="<%=i%>"><%=i%></option>
<%}
}%>
</select> &nbsp;&nbsp;&nbsp;<a href="javascript:ReloadPage();"><img src="../../images/refresh.gif" border="0"></a>
		</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="logout_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>