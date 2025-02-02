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
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ReloadPage() {
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET LAB OPERATION - comp usage",
								"iL_assign.jsp");
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
														"iL_assign.jsp");
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
Vector vLocInfo   = tinStud.internetCafeAvailability(dbOP, request.getRemoteAddr());
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(compUsage.operateOnAssignUser(dbOP, request, Integer.parseInt(strTemp), false) == null) 
		strErrMsg = compUsage.getErrMsg();
	else	
		strErrMsg = "Operation is successful.";
}
if(vLocInfo == null) 
	strErrMsg = tinStud.getErrMsg();
else {
	//get here lab usage detail.
	vRetResult = compUsage.operateOnAssignUser(dbOP, request, 4, false);
	if(vRetResult == null)
		strErrMsg = compUsage.getErrMsg();
}


%>
<form action="./iL_assign.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INTERNET LAB OPERATION - VIEW INTERNET LAB USAGE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="47%">DATE - TIME : <%=WI.getTodaysDateTime()%></td>
      <td width="52%"> ATTENDANT NAME : <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></td>
    </tr>
  </table>

<%
if(vLocInfo != null && vLocInfo.size() > 0){%>	  
  <table width="100%" border="0" cellpadding="1" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFF9F"> 
      <td height="25" colspan="6"><div align="center"><font color="#0000FF"><strong>LIST 
          OF COMPUTERS TO BE ASSIGNED</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="30" colspan="4"><font size="1">TOTAL NO. OF COMPUTER(S)/ COMPUTERS 
        FREE: <strong><%=(String)vLocInfo.elementAt(1)%>/<%=(String)vLocInfo.elementAt(2)%></strong></font></td>
      <td height="30" colspan="2"><div align="right"><font size="1">LOCATION : 
          <%=(String)vLocInfo.elementAt(0)%>&nbsp;&nbsp;&nbsp; </font></div></td>
    </tr>
    <%
if(vRetResult != null && vRetResult.size() > 0){%>
    <tr bgcolor="#FFFFFF"> 
      <td width="13%"><div align="center"><font size="1"><strong>STUD ID</strong></font></div></td>
      <td width="27%"><div align="center"><font size="1"><strong>STUD NAME (lname,fname, 
          mi)</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>LOGIN TIME</strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>EXPTD. LOGOUT 
          TIME</strong></font></div></td>
      <td width="12%"><strong><font size="1">TOTAL MINS USED</font></strong></td>
      <td width="29%" height="24"><div align="center"><font size="1"><strong>ASSIGN 
          PC </strong></font></div></td>
    </tr>
    <%//System.out.println(vRetResult);
int p = -1;
strTemp = WI.fillTextValue("assign_ref");
for(int i = 0; i < vRetResult.size(); i += 7){
if(vRetResult.elementAt(i + 3) != null)
	continue;
++p;
%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td align="center">
<%if(p == 0){
Vector vTemp = compUsage.getListOfComputerCanBeAssigned(dbOP, request.getRemoteAddr());
if(vTemp == null) {%>
<%=compUsage.getErrMsg()%>;
<%}else{//list computers available.%>	  
	<select name="assign_ref">
<%for(int k = 0; k < vTemp.size(); k += 2){
	if(strTemp.compareTo((String)vTemp.elementAt(k)) == 0){%>
		<option value="<%=(String)vTemp.elementAt(k)%>" selected><%=(String)vTemp.elementAt(k+1)%></option>	
	<%}else{%>
		<option value="<%=(String)vTemp.elementAt(k)%>"><%=(String)vTemp.elementAt(k+1)%></option>	
	<%}
}//end of for loop%>
	</select>
	  <a href='javascript:PageAction(1,"");'> 
        <img src="../../images/assign.gif" border="0"></a>
<input type="hidden" name="tin_tout_ref" value="<%=(String)vRetResult.elementAt(i)%>">
<%}//end of else.
}//if p == 0%>
	  </td>
    </tr>
    <%}//end of for loop
}//end of display if vRetResult != null
%>
  </table>
   
  <table width="100%" border="0" cellpadding="1" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="7"><div align="center"><font color="#0000FF"></font></div></td>
    </tr>
    <tr bgcolor="#FFFF9F"> 
      <td height="25" colspan="7"><div align="center"><font color="#0000FF"><strong>LIST 
          OF COMPUTERS ALREADY ASSIGNED</strong></font></div></td>
    </tr>
    <%
if(vRetResult != null && vRetResult.size() > 0){%>
    <tr bgcolor="#FFFFFF">
      <td width="13%"><font size="1"><strong>COMPUTER NAME</strong></font></td>
      <td width="13%"><div align="center"><font size="1"><strong>STUD ID</strong></font></div></td>
      <td width="27%"><div align="center"><font size="1"><strong>STUD NAME (lname,fname, 
          mi)</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>LOGIN TIME</strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>EXPTD. LOGOUT 
          TIME</strong></font></div></td>
      <td width="12%"><strong><font size="1">TOTAL MINS USED</font></strong></td>
      <td width="29%" height="24"><div align="center"><font size="1"><strong>REMOVE 
          ASSIGNED PC</strong></font></div></td>
    </tr>
    <%//System.out.println(vRetResult);
for(int i = 0; i < vRetResult.size(); i += 7){
if(vRetResult.elementAt(i + 3) == null)
	continue;
%>
    <tr bgcolor="#FFFFFF">
      <td><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td align="center"><a href="javascript:PageAction(0,<%=(String)vRetResult.elementAt(i)%>);"> 
        <img src="../../images/delete.gif" border="0"></a><font size="1">&nbsp; 
        </font></td>
    </tr>
    <%}//end of for loop
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
      <td width="87%" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>