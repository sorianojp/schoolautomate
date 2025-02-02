<%
String strMethodType = request.getMethod();
if(!strMethodType.toLowerCase().equals("post")) {%>
	<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">
		Wrong Call. Please consult support.</p>
<%return;}


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

<%@ page language="java" import="utility.*,enrollment.Login,enrollment.NAApplCommonUtil" %>
<%
 //only used to load the combo box in the course offered drop list.
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strUserId = null;
	String strPassword = null;
	boolean bolNewUser = false; 
	
	//session object. is_parent_ = 1, parent_id = xx, parent_name = xx.
	String strParentIndex = null; String strParentName = null;
	
	String strCurSchYrFrom = null;
	String strCurSchYrTo = null;
	String strCurSemester = null;
	String strSchoolIndex = null;//keep school index in session.
	String strInfo5 = null;//another school code -- like JOneltal, Cavite,, etc.. 
	
	String strTermType    = null;
	String strMaxTerm     = null;
	String strSQLQuery    = null;
	java.sql.ResultSet rs = null;
	
	WebInterface WI = new WebInterface(request);
	Login login = new Login();

	String strImageExtn   = null;// Image extension.
	
	String strChatStatus = null;//1 = chat is activated.. 

	//get the login - temp_stud
	String strLoginType = request.getParameter("login_type");

	if(strLoginType == null || strLoginType.trim().length() ==0)
	{
		strErrMsg = "Can't login. Please contact admin with this error message : New Application Login falilure. Login type missing.";
	}
	else {
		try
		{
			/** start of mess here.. -- do not remove this piece of code, System will crash without this code.. 
			utility.LicenseFile lF = new utility.LicenseFile();
			if(!lF.isLicensed(false)) {
				lF.cleanUP();
				response.sendRedirect(response.encodeRedirectURL("./register.jsp"));
				return;
			}
			lF.cleanUP();
			**/
			// end of mess here..
		
		
			ReadPropertyFile readPropFile = new ReadPropertyFile();
			strImageExtn = readPropFile.getImageFileExtn("imgFileUploadExt");

			dbOP = new DBOperation();
			String[] strCurSchYr = dbOP.getCurSchYr();
			strCurSchYrFrom = strCurSchYr[0];
			strCurSchYrTo = strCurSchYr[1];
			strCurSemester = strCurSchYr[2];
			strSchoolIndex = dbOP.getSchoolIndex();
			strInfo5 = "select info5 from sys_info";
			strInfo5 = dbOP.getResultOfAQuery(strInfo5, 0);
			
			if(strSchoolIndex == null) {
				strErrMsg = dbOP.getErrMsg();
			}
			
			//I have to make sure i set the Debug mode for printing.
			new Debug().setDebugProperty(dbOP);
			
			strChatStatus = readPropFile.readProperty(dbOP, "CHAT_ACTIVE","0");
			
			strSQLQuery = "select prop_name, prop_val from read_property_file where prop_name in ('TERM_TYPE','MAX_TERM')";
			rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next()){
				if(rs.getString(1).equals("TERM_TYPE"))
					strTermType = rs.getString(2);
				else	
					strMaxTerm  = rs.getString(2);
			}
			if(rs.next()){
				if(rs.getString(1).equals("TERM_TYPE"))
					strTermType = rs.getString(2);
				else	
					strMaxTerm  = rs.getString(2);
			}
			rs.close();

		}
		catch(Exception exp)
		{
			exp.printStackTrace();
			strErrMsg = "Error in opening connection";
		}
	}
	strUserId = request.getParameter("user_id");
	strPassword = request.getParameter("password");
	String strPageURL = WI.fillTextValue("page_url");
	
	
	//security implementation to avoid saving of pwd or auto complete
	if(WI.fillTextValue("is_secured").equals("1")) {
		strUserId = request.getParameter(request.getParameter("user_id"));
		strPassword = request.getParameter(request.getParameter("password"));
	}

	if(strUserId == null || strUserId.trim().length() ==0 || strPassword == null || strPassword.trim().length() ==0) {
		strErrMsg = "User id or password can't be blank.";
	}
	
	///I must check if this IP is blocked from accessing the system.
	if(new AccessSecurityLog().checkIsIPBlocked(dbOP, request.getRemoteAddr()))
		strErrMsg = "IP is blocked. Please contact system admin for further instruction.";	
	
	if(strErrMsg != null && strPageURL.length() > 0) {
		request.getSession(false).setAttribute("err_",strErrMsg);
		response.sendRedirect(response.encodeRedirectURL(strPageURL));
	}
	if(strErrMsg != null)
	{%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%>
		</font></p>
		<%
		if(dbOP != null)
			dbOP.cleanUP();
		return;
	}
	
	//I have to check if parent.. 
	if(strLoginType.equals("parent_student")) {
		strSQLQuery = "select PARENT_INDEX, FNAME,MNAME,LNAME,password_ from PARENT_SMS_SPC where login_id = ?";
		java.sql.PreparedStatement pstmt = dbOP.getPreparedStatement(strSQLQuery);
		pstmt.setString(1,strUserId);
		
		rs = pstmt.executeQuery();
		if(rs.next()) {
			strParentIndex = rs.getString(1);
			strParentName = WI.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4);
			String strPwdInDB = rs.getString(5);
			rs.close();

			if(strPwdInDB.equals(strPassword)) {			
				//I have to find the first student ID.. 
				strSQLQuery = "select id_number, user_table.user_index from PARENT_SMS_MAIN "+
				"join user_table on (user_table.user_index = PARENT_SMS_MAIN.user_index) where parent_index = "+
				strParentIndex;
				rs = dbOP.executeQuery(strSQLQuery);
				if(rs.next()) {
					strUserId = rs.getString(1);
					login.strUserIndex = rs.getString(2);
					
					rs.close();
					
					request.getSession(false).invalidate();
					request.getSession(true);
					request.getSession(false).setAttribute("parent_i",strParentIndex);
					request.getSession(false).setAttribute("parent_n",strParentName);
				}
				else {
					strErrMsg = "Student ID not attached to this login ID. Please contact system admin.";
					rs.close();	
				}
			}
			else {
				strErrMsg = "Login Failed. Please check ID/Password or Contact System admin to Reset.";				
			}
		}
			//strParentName = null;
	}
	////////////// if parent login fails.////////////////////////////////////////
	if(strErrMsg != null && strPageURL.length() > 0) {
		request.getSession(false).setAttribute("err_",strErrMsg);
		response.sendRedirect(response.encodeRedirectURL(strPageURL));
	}
	if(strErrMsg != null)
	{%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%>
		</font></p>
		<%
		if(dbOP != null)
			dbOP.cleanUP();
		return;
	}
	////////////////////////////////// end of if parent login fails.//////////////////////	
	
	

	//login the user.
	//I am merging temp student here.. 
	if(strLoginType.equals("parent_student") && strParentIndex == null) { 
		//may be id below to temp ID.. 
		strSQLQuery = "select user_index from login_info where user_id = "+WI.getInsertValueForDB(strUserId, true, null);
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery == null) {
			strSQLQuery = "select application_index from new_application where temp_id = "+WI.getInsertValueForDB(strUserId, true, null);
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null) {
				strLoginType = "temp_stud";
			}
		}
	}

	if(strLoginType.compareTo("temp_stud") ==0)
		bolNewUser = true;

	strErrMsg = null;
	String strLoginURL = "";
	if(bolNewUser)
	{
		if(!login.isTempUserAuthentic(dbOP,strUserId, strPassword, request.getRemoteAddr()))
			strErrMsg = login.getErrMsg();
		else {
			String strTempStudIndex = null;
			/** get the sy-term registered for new student.. **/
			strSQLQuery = "select application_index,schyr_from, schyr_to, semester from new_application "+
							"join APPL_FORM_SCHEDULE on (APPL_FORM_SCHEDULE.APPL_SCH_INDEX = new_application.APPL_SCH_INDEX) "+
							"where temp_id = '"+strUserId+"' and new_application.is_valid = 1";
			rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next()) {
				strTempStudIndex = rs.getString(1);
				strCurSchYrFrom  = rs.getString(2);
				strCurSchYrTo    = rs.getString(3);
				strCurSemester   = rs.getString(4);
			}
 			rs.close();
		
			request.getSession(false).invalidate();
			request.getSession(true);
			request.getSession(false).setAttribute("tempId",strUserId);
			request.getSession(false).setAttribute("tempIndex",strTempStudIndex);
			request.getSession(false).setAttribute("first_name",new CommonUtil().getTempName(dbOP,strUserId,true));
			request.getSession(false).setAttribute("authTypeIndex","0");

			request.getSession(false).setAttribute("cur_sch_yr_from",strCurSchYrFrom);
			request.getSession(false).setAttribute("cur_sch_yr_to",strCurSchYrTo);
			request.getSession(false).setAttribute("cur_sem",strCurSemester);

			request.getSession(false).setAttribute("login_log_index",Integer.toString(login.iLoginLogIndex));
			request.getSession(false).setAttribute("school_code",strSchoolIndex);
			request.getSession(false).setAttribute("info5",strInfo5);
			
			strLoginURL = request.getParameter("welcome_url");
			if(strLoginURL == null || strLoginURL.trim().length() ==0)
				strLoginURL = "../PARENTS_STUDENTS/ADMISSION%20MODULE%20PAGES/single%20file%20items/ADMISSION%20FOR%20NEW_TRANSFERRE%20STUDENTS/index_newstud.htm";
		}
	}
	else
	{	
		login.setServletReq(request);
		boolean bolLogIn = false;
		if(strParentIndex != null)
			bolLogIn = true;
		else {
			bolLogIn = login.isUserAuthentic(dbOP,strUserId, strPassword, request.getRemoteAddr());
		}
			
		if(!bolLogIn)
			strErrMsg = login.getErrMsg();
		else {
			if(strParentIndex == null) {//do not enter if parent.. 
				//I have to check if this is first time login. if so, let the user change user ID and pwd.
				request.getSession(false).invalidate();
				request.getSession(true);
				request.getSession(false).setAttribute("userId_",strUserId);
				String[] astrFirstLogonInfo = login.isFirstTimeLogin(dbOP, strUserId);//System.out.println(iIsFirstLogin);
				if(astrFirstLogonInfo == null) {
					strErrMsg = login.getErrMsg();
				}
				else if(astrFirstLogonInfo[0].compareTo("1") == 0) {//it is first time login and requested to change password and user ID.
					//forward this page.
					dbOP.cleanUP();
					request.getSession(false).setAttribute("init_id",astrFirstLogonInfo[1]);
					response.sendRedirect(response.encodeRedirectURL("./chng_loginid_pwd.jsp"));
					return;
				}
				else {
					//map login ID to employee ID.
					strUserId = dbOP.mapLoginIDToIDNumber(strUserId);
					if(strUserId == null) 
						strErrMsg = "Error in getting ID.";
					else if(astrFirstLogonInfo[0].compareTo("2") == 0) {//change only password.
						dbOP.cleanUP();
						request.getSession(false).setAttribute("errorMsg",astrFirstLogonInfo[2]);
						request.getSession(false).setAttribute("userId_",strUserId);					
						request.getSession(false).setAttribute("pwd",strPassword);					
						response.sendRedirect(response.encodeRedirectURL("./chng_pwd.jsp"));
						return;
					}					
				}
			}
				
			if(strErrMsg == null) {		
			//System.out.println("I am here.. settting the user index: "+strUserId);	

			//System.out.println("user ID: "+strUserId);	
			//System.out.println("userIndex: "+login.strUserIndex);	

				//request.getSession(false).invalidate();
				//request.getSession(true);
				request.getSession(false).setAttribute("userId",strUserId);
				request.getSession(false).setAttribute("userIndex",login.strUserIndex);
				
				strSQLQuery = "select fname, mname, lname from user_table where user_index = "+login.strUserIndex;
				rs = dbOP.executeQuery(strSQLQuery);
				if(rs.next())
					strSQLQuery = WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4);
				else	
					strSQLQuery = null;
				rs.close();
				
				request.getSession(false).setAttribute("first_name",strSQLQuery);
				strSQLQuery = "select AUTH_TYPE_INDEX from user_table where user_index = "+login.strUserIndex;
				strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
								
				request.getSession(false).setAttribute("authTypeIndex",strSQLQuery);
				
				//get the college and department of the employee.. 
				if(strSQLQuery == null || (strSQLQuery != null && !strSQLQuery.equals("4"))) {
					strSQLQuery = "select c_index, d_index from info_faculty_basic where user_index = "+login.strUserIndex+" and is_valid = 1";
					rs = dbOP.executeQuery(strSQLQuery);
					if(rs.next()) {
						request.getSession(false).setAttribute("info_faculty_basic.c_index",rs.getString(1));
						request.getSession(false).setAttribute("info_faculty_basic.d_index",rs.getString(2));
					}
					rs.close();
				} 
	
				request.getSession(false).setAttribute("cur_sch_yr_from",strCurSchYrFrom);
				request.getSession(false).setAttribute("cur_sch_yr_to",strCurSchYrTo);
				request.getSession(false).setAttribute("cur_sem",strCurSemester);
	
				request.getSession(false).setAttribute("login_log_index",Integer.toString(login.iLoginLogIndex));
				request.getSession(false).setAttribute("school_code",strSchoolIndex);
				request.getSession(false).setAttribute("info5",strInfo5);
			
				//added new parameter -- image extension.
				request.getSession(false).setAttribute("image_extn",strImageExtn);
				
				//chat status.. 
				request.getSession(false).setAttribute("chat_stat",strChatStatus);
				
				////add authentication list of module/sub module with read/write access to session.
				new CommonUtil().setAuthList(dbOP, strUserId, request);
				//System.out.println( ((java.util.Hashtable)request.getSession(false).getAttribute("svhAuth")).toString());
				//System.out.println((String)request.getSession(false).getAttribute("login_log_index"));
				//forwarding is not so straight --- get the auth type and forward appropriate page.
				strLoginURL = request.getParameter("welcome_url");
				
				//if student and trying to login to admin, force forward.. 
				//If student logs in ,, I must direct to student page.. 
				String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
				if(strAuthTypeIndex!= null && (strAuthTypeIndex.equals("4") || strAuthTypeIndex.equals("6")) &&
					strLoginURL.indexOf("PARENTS_STUDENTS") == -1) {
					if(strLoginURL.indexOf("ADMIN_STAFF") != -1)
						strLoginURL = "../PARENTS_STUDENTS/parents_student_index.htm";
					else	
						strLoginURL = "../PARENTS_STUDENTS/main_files/login_success.htm";
				}

				
				if(strLoginURL == null || strLoginURL.trim().length() ==0)
					strErrMsg = "Welcome page not found. Please contact admin.";
			}
			
		}
	}

	dbOP.cleanUP();
	if(strErrMsg == null) {
		request.getSession(false).setAttribute("term_type",strTermType);
		request.getSession(false).setAttribute("max_term",strMaxTerm);
		
		response.sendRedirect(response.encodeRedirectURL(strLoginURL));
	}
	else if(strPageURL.length() > 0) {
		request.getSession(false).setAttribute("err_",strErrMsg);
		response.sendRedirect(response.encodeRedirectURL(strPageURL));
	}
	else
	{%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%>
		</font></p>
		<%
	}

//store, tempId,userId, first_name,authTypeIndex if user successfully logs in.
%>

</body>
</html>




