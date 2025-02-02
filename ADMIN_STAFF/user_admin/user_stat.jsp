<%@ page language="java" import="utility.*,enrollment.Authentication,java.util.Vector,java.util.StringTokenizer" %>
<%
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>User Status</title>
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

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
.textbox {
	background-color: #FDFDFD;
	border-style: inset;
	border-width: 1px;
	border-color: #194685;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
-->
</style></head>
<script language="JavaScript">
function ReloadPage()
{
	document.u_stat.submit();
}
function ViewAuthentication(strID)
{
	location = "./authentication/authentication.jsp?emp_id="+escape(strID);
}
function SubmitForm()
{
	document.u_stat.submitForm.value = "1";
}

</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-User management","user_stat.jsp");

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
														"System Administration","User Management",request.getRemoteAddr(),
														"user_stat.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

strTemp = WI.fillTextValue("submitForm");
Vector vRetResult = null;
int iSearchResult = 0;
Authentication auth = new Authentication();
if(strTemp.compareTo("1") ==0)
{
	vRetResult = auth.getUserStat(dbOP,request);
	if(vRetResult == null)
		strErrMsg = auth.getErrMsg();

	iSearchResult = auth.iSearchResult;

}
if(strErrMsg == null) strErrMsg = "";
%>

<form action="./user_stat.jsp" method="post" name="u_stat">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          USERS STATUS ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="11%"><font size="2">User Type</font></td>
      <td><select name="user_type" onChange="ReloadPage();">
          <option value="0">Specify Login ID</option>
          <%
strTemp = WI.fillTextValue("user_type");
if(strTemp.length() ==0) strTemp = "0";
if(strTemp.compareTo("-2") ==0){%>
          <option value="-2" selected>All Active members</option>
<%}else{%>
		<option value="-2">All Active members</option>
<%}
if(bolIsSchool) {
	if(strTemp.compareTo("-1") ==0){%>
			  <option value="-1" selected>Students</option>
	<%}else{%>
			  <option value="-1">Students</option>
	<%}
}%>
          <%=dbOP.loadCombo("MEM_TYPE_INDEX","MEMBER_TYPE"," from SCHOOL_MEM_TYPE where IS_VALID=1 and is_student=0 order by MEMBER_TYPE asc", strTemp, false)%>
        </select> &nbsp;
        <%
if(strTemp.compareTo("0") == 0) {%>
        <input name="user_id" type="text" size="16" value="<%=WI.fillTextValue("user_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <%}%>
      </td>
      <td width="47%">
        <%
if(strTemp.compareTo("0") == 0) {%>
        <input type="image" onClick="SubmitForm();" src="../../images/form_proceed.gif">
        <%}%>
      </td>
    </tr>
    <%
if(strTemp.compareTo("0") != 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><font size="2">Sort by</font></td>
      <td width="37%"><select name="sort_by">
          <option value="0">None</option>
          <%
strTemp = WI.fillTextValue("sort_by");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Login ID</option>
          <%}else{%>
          <option value="1">Login ID</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Lastname</option>
          <%}else{%>
          <option value="2">Lastname</option>
          <%}%>
        </select> <select name="sort_by_con">
          <option value="asc">Ascending</option>
          <%
strTemp = WI.fillTextValue("sort_by_con");
if(strTemp.compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
      <td width="47%"><input type="image" src="../../images/refresh.gif" onClick="SubmitForm();"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3"> NOTE: Users having less than 30mins IDLE time are considered
        active member/ currently logged on to system.</td>
    </tr>
    <%}%>
    <tr>
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
<table width="100%" border="0" bgcolor="#FFFFFF">
<tr>
      <td width="66%" ><b> <font size="2">Total users : <%=iSearchResult%> - Showing(<%=auth.strDispRange%>)</font></b></td>
      <td width="34%">
	  <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/auth.defSearchSize;
		if(iSearchResult % auth.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
		<div align="right"><font size="2">Jump To page:</font>
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>

		<%}%>

        </div></td>
    </tr>
  </table>


    <table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td height="22" bgcolor="#B9B292"><div align="center"><b><font color="#FFFFFF">-
          LIST OF USER(S) - TOTAL NO : <%=vRetResult.size()/5%></font></b></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td width="12%" height="25"><div align="center"><strong>LOGIN ID</strong></div></td>
      <td width="23%"><div align="center"><strong>NAME (fname,lname)</strong></div></td>
      <td width="25%"><div align="center"><strong>LAST LOGIN DATE/TIME</strong></div></td>
      <td width="15%"><div align="center"><strong>LOGIN IP<br>
          (if user logged in)</strong></div></td>
      <td width="11%" align="center"><strong>IDLE TIME</strong></td>
      <td width="14%"><div align="center"><strong>VIEW AUTHENTICATION</strong></div></td>
    </tr>
    <%
 for(int i=0; i<vRetResult.size() ; ++i){%>
    <tr>
      <td height="25" align="center"><%=(String)vRetResult.elementAt(i)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td align="center"><a href='javascript:ViewAuthentication("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/view.gif" width="30" height="23" border="0"></a></td>
    </tr>
    <%
i = i+4;
}%>
  </table>
<%}%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
<input name="submitForm" type="hidden" value="<%=WI.fillTextValue("submitForm")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
