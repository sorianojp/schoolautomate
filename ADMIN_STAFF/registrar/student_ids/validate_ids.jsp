<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=new_id.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AddRecord()
{
	document.new_id.addRecord.value = "1";
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.RegAssignID,enrollment.Advising,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

	String strErrMsg = null;
	String strTemp = null;
	Vector vStudInfo = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-STUDENT IDs - Validate IDs","validate_ids.jsp");
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
														"Registrar Management","STUDENT IDs",request.getRemoteAddr(),
														"validate_ids.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)//db error
{
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=dbOP.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}

if(strErrMsg == null)
{
	strTemp = WI.fillTextValue("addRecord");
	if(strTemp != null && strTemp.compareTo("1") ==0)
	{
		RegAssignID regAssignID = new RegAssignID();
		if(!regAssignID.confirmOldStudEnrollment(dbOP, request.getParameter("stud_id"),(String)request.getSession(false).getAttribute("userId")))
			strErrMsg = regAssignID.getErrMsg();
		else
			strErrMsg = "Student enrolled successfully.";
	}
}

if(request.getParameter("stud_id") == null || request.getParameter("stud_id").trim().length() ==0)
	strErrMsg = "Please enter student ID.";

if(strErrMsg == null)
{
	Advising advising = new Advising();
	vStudInfo = advising.getStudInfo(dbOP,request.getParameter("stud_id"));
	if(vStudInfo == null)
	{
		strErrMsg = "Error in getting student information. <br> Description : "+
			advising.getErrMsg();
	}
	else
	{
		astrSchYrInfo[0]=(String)vStudInfo.elementAt(16);//take sy from/to/sem from student registration information.
		astrSchYrInfo[1]=(String)vStudInfo.elementAt(17);
		astrSchYrInfo[2]=(String)vStudInfo.elementAt(18);
	}
}

dbOP.cleanUP();
if(strErrMsg == null) strErrMsg = "";
%>

<form name="new_id" action="./validate_ids.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          VALIDATE IDs PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td width="4%" height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25" >&nbsp;</td>
      <td width="13%" height="25" >Student ID </td>
      <td width="19%" > <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td width="13%" ><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="51%" colspan="2" >&nbsp; <input type="image" src="../../../images/form_proceed.gif" onClick="document.form_.addRecord.value='';">
      </td>
    </tr>
    <tr>
      <td colspan="6" height="25" ><hr size="1"></td>
    </tr>
    <%
if(vStudInfo != null && vStudInfo.size()> 0){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="5" height="25" >Student name : <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="5" height="25" >Course /Major: <strong><%=(String)vStudInfo.elementAt(7)%>
        <%
	   if(vStudInfo.elementAt(8) != null){%>
        / <%=(String)vStudInfo.elementAt(8)%>
        <%}%>
        </strong></td>
    </tr>
    <tr>
      <td height="26" >&nbsp;</td>
      <td height="26" colspan="3" >Enrolling year level: <strong> <%=WI.getStrValue(vStudInfo.elementAt(6))%></strong></td>
      <td height="26" colspan="2" >School Year/Term: <strong><%=astrSchYrInfo[0]%>
        - <%=astrSchYrInfo[1]%> / <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%></strong>
      </td>
    </tr>
    <tr>
      <td colspan="6" height="25" ><hr size="1"></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;</td>
      <td height="25" colspan="2" ><input type="image" onClick="AddRecord();" src="../../../images/save.gif">
        <font size="1">click to save validation</font></td>
    </tr>
    <%}%>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="8" height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="0">
  </form>
</body>
</html>
