<%
String strBodyColor = request.getParameter("body_color");
if(strBodyColor == null || strBodyColor.trim().length() == 0)
	strBodyColor = "#9FBFD0";//this is for new applicant.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Login page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<body bgcolor="<%=strBodyColor%>">

<%@ page language="java" import="utility.*,enrollment.Login" %>
<%
 //only used to load the combo box in the course offered drop list.
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strUserId = null;
	String strPassword = null;
	boolean bolNewUser = false;
	//get the login - temp_stud
	String strLoginType = request.getParameter("login_type");
	if(strLoginType == null) strLoginType="";

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		strErrMsg = "Error in opening connection";
	%>	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%>
		</font></p>
		<%
		if(dbOP != null)
			dbOP.cleanUP();
		return;
	}

	//logout the user.
	Login login = new Login();

	if((String)request.getSession(false).getAttribute("tempId") != null || (strLoginType.length() > 0 && strLoginType.compareTo("temp_stud") ==0))
		bolNewUser = true;

	strErrMsg = null;
	if(bolNewUser)
	{
		strUserId = (String)request.getSession(false).getAttribute("tempId");
		login.logoutTempUser(dbOP, strUserId, request.getRemoteAddr());
	}
	else
	{
		/**
		strUserId = (String)request.getSession(false).getAttribute("userId");
		//map employee ID to login id. 
		String strLoginID = dbOP.mapIDNumberToLoginID(strUserId);		
		//forwarding is not so straight --- get the auth type and forward appropriate page.
		login.logoutUser(dbOP, strLoginID, request.getRemoteAddr());
		//I have to reset the chat information here. 
		**/
		String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
		if(strUserIndex != null) {
			String strSQLQuery = "update login_log set logout_time='" + new utility.WebInterface().getTodaysDateTime() +
    			"' where login_log_index = "+(String)request.getSession(false).getAttribute("login_log_index");
			dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);

			strSQLQuery = "update user_table set is_active_ = 0 where user_index = "+
				strUserIndex;
			dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
		}
		
	}

	String strLogoutURL = request.getParameter("logout_url");
	if(strLogoutURL == null || strLogoutURL.trim().length() ==0)
		strErrMsg = "Please click home to go to home page.";

	request.getSession(false).removeAttribute("tempIndex");
	request.getSession(false).removeAttribute("tempId");
	request.getSession(false).removeAttribute("userId");
	request.getSession(false).removeAttribute("first_name");
	request.getSession(false).removeAttribute("authTypeIndex");
	request.getSession(false).removeAttribute("cur_sch_yr_from");
	request.getSession(false).removeAttribute("cur_sch_yr_to");
	request.getSession(false).removeAttribute("cur_sem");
	request.getSession(false).removeAttribute("school_code");
	request.getSession(false).removeAttribute("image_extn");
	request.getSession(false).removeAttribute("chat_stat");
	
	request.getSession(false).removeAttribute("login_log_index");
	request.getSession(false).removeAttribute("userIndex");

	request.getSession(false).invalidate();
	request.getSession(true);
	//System.out.println(strLogoutURL);
	dbOP.cleanUP();

	if(strErrMsg == null)
	{
		//remove history and forward.
		request.getSession(false).setAttribute("logout_url",strLogoutURL);
		response.sendRedirect(response.encodeRedirectURL("./forbid.jsp"));
		return;
	}
	else
	{%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%>
		</font></p>
		<%
	}
%>

</body>
</html>




