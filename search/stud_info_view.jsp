<%
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
boolean bolIsLoggedIn = true;
if(request.getSession(false).getAttribute("userIndex") == null)
	bolIsLoggedIn = false;
else {
	if(strAuthTypeIndex != null) {
		int iAuthTypeIndex = Integer.parseInt(strAuthTypeIndex);
		if(iAuthTypeIndex > 3) 
			bolIsLoggedIn = false;
	}
}
if(!bolIsLoggedIn) {%>
	<p style="font-weight:bold; font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
		Not Authorized to view this page.
	</p>
<%return;}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="JavaScript">
function ViewGSPIS(strStudID) {
	location = "../ADMIN_STAFF/admission/stud_personal_info_page2.jsp?removeEdit=1&stud_id="+escape(strStudID);
}</script>
</head>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.PersonalInfoManagement" %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strEditMsg = null;
	Vector[] vStudInfo  = null;
	String strImgFileExt = null; // this makes sure i am using same file extension as i am using in property files. 
	boolean bolIsFromOSA = false;//if true, show the view button to view GSPIS


	String[] astrConvertYr = {"","1st","2nd","3rd","4th","5th","6th"};
	String[] astrConvertSem= {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

	try
	{
		dbOP = new DBOperation();

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Imange file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

        
PersonalInfoManagement pInfo = new PersonalInfoManagement();
vStudInfo = pInfo.viewPermStudPersonalInfo(dbOP,request.getParameter("stud_id"));
if(vStudInfo == null)
	strErrMsg = pInfo.getErrMsg();
else {
	CommonUtil comUtil = new CommonUtil();
	bolIsFromOSA = comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Student Affairs");
}
dbOP.cleanUP();
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="26" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENT'S BASIC PERSONAL INFORMATION ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp; <b><%=WI.getStrValue(strErrMsg)%></b></td>
    </tr>
    <tr> 
      <td height="23">&nbsp; STUDENT ID</td>
      <td width="41%"><%=request.getParameter("stud_id")%></td>
      <td width="41%" rowspan="13" valign="top">
	  <img src="../upload_img/<%=request.getParameter("stud_id")+"."+strImgFileExt%>" width="288" height="288"></td>
    </tr>
<%
if(vStudInfo != null){%>
    <tr> 
      <td height="23">&nbsp; LASTNAME</td>
      <td><%=(String)vStudInfo[0].elementAt(13)%></td>
    </tr>
    <tr> 
      <td height="23">&nbsp; FIRSTNAME</td>
      <td><%=(String)vStudInfo[0].elementAt(11)%></td>
    </tr>
    <tr> 
      
    <td height="23">&nbsp; MIDDLENAME/MI</td>
      <td><%=WI.getStrValue(vStudInfo[0].elementAt(12))%></td>
    </tr>
    <tr> 
      <td height="23">&nbsp; GENDER</td>
      <td><%=WI.getStrValue(vStudInfo[0].elementAt(15))%></td>
    </tr>
    <tr> 
      <td width="18%" height="23">&nbsp; COURSE </td>
      
    <td><%=WI.getStrValue(vStudInfo[0].elementAt(0))%></td>
    </tr>
    <tr> 
      <td width="18%" height="23">&nbsp; MAJOR </td>
      
    <td><%=WI.getStrValue(vStudInfo[0].elementAt(2))%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp; CURRICULUM YEAR</td>
      
    <td><%=WI.getStrValue(vStudInfo[0].elementAt(4))%> to <%=WI.getStrValue(vStudInfo[0].elementAt(5))%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp; YEAR LEVEL</td>
      
    <td> 
      <% if(vStudInfo[0].elementAt(8) != null){%>
      <%=astrConvertYr[Integer.parseInt(((String)vStudInfo[0].elementAt(8)))]%> 
      <%}else{%>
      N/A 
      <%}%>    </td>
    </tr>
    <tr> 
      <td height="25">&nbsp; TERM/SCHOOL YEAR </td>
      
      <td><%=WI.getStrValue(vStudInfo[0].elementAt(6))%> to <%=WI.getStrValue(vStudInfo[0].elementAt(7))%> 
      / <%=astrConvertSem[Integer.parseInt(((String)vStudInfo[0].elementAt(9)))]%></td>
    </tr>
	<tr> 
      <td height="25" colspan="2"><font color="#0033FF"><U>Emergency Contact Information:</U></font></td>
    </tr>
	<tr> 
      <td height="25">&nbsp; CONTACT PERSON </td>
      
    <td><%=WI.getStrValue(vStudInfo[0].elementAt(52))%></td>
    </tr>
	<tr> 
      <td height="25">&nbsp; RELATION </td>
      
    <td><%=WI.getStrValue(vStudInfo[0].elementAt(53))%></td>
    </tr>
	<tr> 
      <td height="25">&nbsp; ADDRESS </td>
      
    <td colspan="2">
	<%=WI.getStrValue((String)vStudInfo[0].elementAt(54),"",",","")%>
	<%=WI.getStrValue((String)vStudInfo[0].elementAt(55),"",",","")%></td>
    </tr>
	<tr> 
      <td height="25">&nbsp;</td>      
    <td colspan="2">
	<%=WI.getStrValue((String)vStudInfo[0].elementAt(56),"",",","")%>
	<%=WI.getStrValue((String)vStudInfo[0].elementAt(57),"","","")%>
	<%=WI.getStrValue((String)vStudInfo[0].elementAt(58)," ","","")%>
	</td>
    </tr>
	<tr> 
      <td height="25">&nbsp; CONTACT NUMBER</td>
      
    <td colspan="2"><%=WI.getStrValue((String)vStudInfo[0].elementAt(59))%></td>
    </tr>
<%}
//show only for OSA logins
if(bolIsFromOSA){%>
    <tr> 
      <td height="13" valign="top">&nbsp;</td>
      <td valign="bottom" colspan="2"><a href='javascript:ViewGSPIS("<%=request.getParameter("stud_id")%>");'><img src="../images/view.gif" border="0"></a> 
	  <font size="1" color="blue"><em>Click to view GSPIS of student</em></font></td>
    </tr>
<%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</body>
</html>