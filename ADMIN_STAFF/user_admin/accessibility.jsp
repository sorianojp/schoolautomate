<%@ page language="java" import="utility.*,enrollment.Authentication,java.util.Vector,java.util.StringTokenizer" %>
<%
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex,strAction)
{
	document.page_auth.info_index.value = strInfoIndex;
	document.page_auth.page_action.value = strAction;
}
function ResetPin(strInfoIndex) {
	document.page_auth.info_index.value = strInfoIndex;
	document.page_auth.page_action.value = "6";
	document.page_auth.submit();
}
function ReloadPage() {
	document.page_auth.submit();
}
function AjaxMapName() {
	//return;
		var strCompleteName = document.page_auth.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.page_auth.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	
	document.page_auth.page_action.value='';
	document.page_auth.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body bgcolor="#D2AE72" onLoad="document.page_auth.emp_id.focus()">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strEmpUserIndex = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","accessibility.jsp");

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
														"System Administration","Override Parameters",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","User Management - Accessibility",request.getRemoteAddr(),
															null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","USER MANAGEMENT-RESET PASSWORD",request.getRemoteAddr(),
															null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","Enrollment-Advising Rules",request.getRemoteAddr(),
															null);
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

Vector vRetResult = new Vector();
Vector vAuthList = new Vector();
Authentication auth = new Authentication();

String strInfoIndex = "";
boolean bolFatalErr = false;

	vRetResult = auth.operateOnBasicInfo(dbOP, request,"0");
	if(vRetResult == null)
	{
		strErrMsg = auth.getErrMsg();bolFatalErr= true;
	}
	else
	{
		strTemp = request.getParameter("page_action");
		if(strTemp != null && strTemp.trim().length() > 0)
		{
			if(strTemp.compareTo("0") == 0) //delete authentication -
			{
				if(auth.operateOnAuthentication(dbOP,(String)vRetResult.elementAt(0),request,"2") == null)
					strErrMsg = auth.getErrMsg();
				else
					strErrMsg = "Authentication deleted successfully.";
			}
			else if(strTemp.compareTo("1") ==0)//delete the user.
			{
				if(!auth.deleteUser(dbOP,(String)vRetResult.elementAt(0),(String)request.getSession(false).getAttribute("login_log_index")))
					strErrMsg = auth.getErrMsg();
				else
					strErrMsg = "User deleted successfully.";
			}
			else if(strTemp.compareTo("2") ==0)//block user
			{
				if(!auth.blockOrReactivateUser(dbOP,(String)vRetResult.elementAt(0),(String)request.getSession(false).getAttribute("login_log_index"),true))
					strErrMsg = auth.getErrMsg();
				else
					strErrMsg = "User access blocked.";
			}
			else if(strTemp.compareTo("3") ==0)//Reset password.
			{
				if(!auth.resetPasswordOrNoOfTries(dbOP,request.getParameter("emp_id"),(String)vRetResult.elementAt(0),
	    			(String)request.getSession(false).getAttribute("login_log_index"),true))
					strErrMsg = auth.getErrMsg();
				else
					strErrMsg = "User's password is reset. The default new password is same as user id.";
			}
			else if(strTemp.compareTo("4") ==0)//Re-activate user.
			{
				if(!auth.blockOrReactivateUser(dbOP,(String)vRetResult.elementAt(0),(String)request.getSession(false).getAttribute("login_log_index"),false))
					strErrMsg = auth.getErrMsg();
				else
					strErrMsg = "User is re-activated. User can now login to the system using previous user name and password.";
			}
			else if(strTemp.compareTo("5") ==0)//reset retries
			{
				if(!auth.resetPasswordOrNoOfTries(dbOP,request.getParameter("emp_id"),(String)vRetResult.elementAt(0),
	    			(String)request.getSession(false).getAttribute("login_log_index"),false))
					strErrMsg = auth.getErrMsg();
				else
					strErrMsg = "No of retries of user is reset. User can now login to the system using previous user name and password";
			}
			else if(strTemp.compareTo("6") ==0)//reset retries
			{
				if(!auth.resetPinCode(dbOP,(String)vRetResult.elementAt(0),
	    			(String)request.getSession(false).getAttribute("login_log_index")) )
					strErrMsg = auth.getErrMsg();
				else
					strErrMsg = "Pincode information reset successfully. User will have to enter new pin code at first logon.";
			}
		}
		vAuthList  = auth.operateOnAuthentication(dbOP,(String)vRetResult.elementAt(0), request,"0");
	}



if(strErrMsg == null) strErrMsg = "";

String[] astrConvertGender = {"Male","Female"};
%>


<form name="page_auth" action="./accessibility.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          ACCESSIBILITY PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;
	  <strong><font color="#FF0000" size="3"><%=strErrMsg%></font></strong></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="12%">Login ID</td>
      <td width="23%"><input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();"></td>
      <td width="9%"><input name="image" type="image" src="../../images/form_proceed.gif"></td>
      <td width="55%"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td  colspan="5" height="25"><hr size="1"></td>
    </tr>
  </table>
  <%
if(vRetResult != null && vRetResult.size() > 0)
{
strEmpUserIndex = (String)vRetResult.elementAt(0);
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">Name</font></td>
      <td><font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(1),(String)vRetResult.elementAt(2),(String)vRetResult.elementAt(3),1)%></strong></font></td>
      <td><font size="1">Gender</font></td>
      <td><font size="1"><strong><%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(4))]%></strong></font></td>
    </tr>
    <tr>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td><font size="1">Date of Employment</font></td>
      <td><font size="1"><strong><%=(String)vRetResult.elementAt(6)%></strong></font></td>
      <td><font size="1">Date of Birth</font></td>
      <td><font size="1"><strong><%=(String)vRetResult.elementAt(5)%></strong>(mm/dd/yyyy)
        </font></td>
    </tr>
    <tr>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td><font size="1">Address</font></td>
      <td><font size="1"><strong><%=(String)vRetResult.elementAt(8)%></strong></font></td>
      <td><font size="1">Contact Nos.</font></td>
      <td><font size="1"><strong><%=(String)vRetResult.elementAt(7)%></strong></font></td>
    </tr>
    <tr>
      <td  colspan="5"height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25"><font size="1">&nbsp;</font></td>
      <td width="18%"><font size="1">Employment Type</font></td>
      <td width="34%"><font size="1"><strong><%=(String)vRetResult.elementAt(15)%></strong></font></td>
      <td width="13%"><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></font></td>
      <td width="34%"><font size="1"><strong><%=WI.getStrValue(vRetResult.elementAt(13))%>
	  <%
	  if(vRetResult.elementAt(13) != null && vRetResult.elementAt(14) != null){%>
	  /<%=WI.getStrValue(vRetResult.elementAt(14))%><%}%></strong></font></td>
    </tr>
    <tr>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td height="25"><font size="1">Employment Status</font></td>
      <td height="25"><font size="1"><strong><%=WI.getStrValue((String)vRetResult.elementAt(16))%>
        </strong></font></td>
      <td height="25"><font size="1">Office/Department</font></td>
      <td height="25"><font size="1"><strong>
	  <%
	  if(vRetResult.elementAt(13) == null && vRetResult.elementAt(14) != null){%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(14))%>
	  <%}%>
	  </strong></font></td>
    </tr>
    <tr>
      <td  colspan="5" height="25"><hr size="1"></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="1%" height="25"><font size="1">&nbsp;</font></td>
      <td width="33%"><font size="1">Access type : <strong><%=WI.getStrValue((String)vRetResult.elementAt(17))%></strong></font></td>
      <td width="33%"><font size="1">User type : <strong><%=WI.getStrValue((String)vRetResult.elementAt(18))%></strong></font></td>
      <td width="33%"><font size="1">&nbsp;</font></td>
    </tr>
  </table>

<%if(vAuthList != null){%>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4" bgcolor="#B9B292"><div align="center">LIST OF
          MODULES THIS USER HAS ACCESS TO</div></td>
    </tr>
    <tr>
      <td height="25"><div align="center"><font size="1"><strong>MODULES</strong></font></div></td>
      <td><div align="center"><strong><font size="1">SUB-MODULES</font></strong></div></td>
      <td><div align="center"><font size="1"><strong>ACCESS MODE</strong></font></div></td>
      <td>&nbsp;</td>
    </tr>
<%//System.out.println(vAuthList);
String[] astrConvertAccesType = {"Read Only","Read/Write(FULL)","Read/Write(Edit)"};
for(int i = 0; i< vAuthList.size(); ++i)
{
	strTemp = WI.getStrValue(vAuthList.elementAt(i+2));
	if(strTemp.compareTo("0") ==0) strTemp = "ALL";
	else	strTemp = WI.getStrValue(vAuthList.elementAt(i+4));

	strTemp2 = WI.getStrValue(vAuthList.elementAt(i+3));
	if(strTemp2.compareTo("0") ==0) strTemp2 = "ALL";
	else	strTemp2 = WI.getStrValue(vAuthList.elementAt(i+5));
%>
    <tr>
      <td width="33%" height="25" align="center"><%=strTemp%></td>
      <td width="39%" align="center"><%=strTemp2%></td>
      <td width="15%" align="center"><%=astrConvertAccesType[Integer.parseInt((String)vAuthList.elementAt(i+1))]%></td>
      <td width="13%" align="center"><input type="image" src="../../images/delete.gif" onClick='PageAction("<%=(String)vAuthList.elementAt(i)%>","0");'></td>
    </tr>
<%
i = i+5;
}%>
  </table>
<%
	}//if vAuthList != null;

if( iAccessLevel >1){%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="40" >&nbsp;</td>
      <td width="31%" height="40" ><input name="image2" type="image" onClick='PageAction("<%=strEmpUserIndex%>","2");' src="../../images/block_user.gif">
        <font size="1">click
      to block user</font>	  </td>
      <td width="33%" height="40" ><input name="image4" type="image" onClick='PageAction("<%=strEmpUserIndex%>","3");' src="../../images/reset_password.gif">
        <font size="1">click
      to reset password</font></td>
      <td width="32%" valign="bottom"><a href="javascript:ResetPin('<%=strEmpUserIndex%>')">RESET PINCODE</a></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" ><!--<img src="../../images/undelete.gif" width="64" height="26"><font size="1">click
        to undelete user</font>-->
        <input name="image3" type="image" onClick='PageAction("<%=strEmpUserIndex%>","4");' src="../../images/reactivate_user.gif">
        <font size="1">click
      to reactivate user</font></td>
      <td height="25" ><input name="image5" type="image" onClick='PageAction("<%=strEmpUserIndex%>","5");' src="../../images/reset_retries.gif">
        <font size="1">click
      to reset retries</font></td>
      <td valign="top">(User will be asked for new pincode in next log on) </td>
    </tr>
  </table>
 <%
 }//only if accesslevel is full or edit ;-)
 	}//only if user information is not null;
 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
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
