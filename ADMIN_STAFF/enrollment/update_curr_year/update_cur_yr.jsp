<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript">
function ReloadPage()
{
	document.update_cur_yr.reloadPage.value="1";
	document.update_cur_yr.updateCurYr.value = "";
	document.update_cur_yr.submit();
}
function ShowResidency()
{
	var strStudID = document.update_cur_yr.stud_id.value;
	var win=window.open('../../registrar/residency/residency_status.jsp?stud_id='+escape(strStudID),"PrintWindow",
		'width=800,height=600,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateCurYr()
{
	document.update_cur_yr.updateCurYr.value = "1";
	document.update_cur_yr.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.UpdateCurriculumYr,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strStudID = WI.fillTextValue("stud_id");
	String strSYTo = null;

	boolean bolIsSuccess = false;

String[] strConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
String[] strConvertYr  = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-UPDATE CURRICULUM YEAR","update_cur_yr.jsp");
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
														"Enrollment","UPDATE CURRICULUM YEAR",request.getRemoteAddr(),
														"update_cur_yr.jsp");
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
Vector vStudInfo = null;
Vector vSchYr = null;

UpdateCurriculumYr updateCurYr = new UpdateCurriculumYr();
SubjectSection SS = new SubjectSection();

if(strStudID.length() > 0)
{
	vStudInfo = updateCurYr.getStudentInfo(dbOP,strStudID);
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = updateCurYr.getErrMsg();
}
if(vStudInfo != null && vStudInfo.size() > 0)
{
//if it is called to update curriculum year, Update here,
	if(WI.fillTextValue("updateCurYr").compareTo("1") ==0)
	{
		if(updateCurYr.updateCurYear( dbOP,strStudID,(String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(8),
                                 request.getParameter("cy_from"),request.getParameter("cy_to")))
		{
			strErrMsg = "<br>UPDATING CURRICULUM YEAR SUCCESSFUL!<br><br><br>Curriculum year updated to "+request.getParameter("cy_from")+"-"+request.getParameter("cy_to");
			bolIsSuccess = true;
		}
		else
			strErrMsg = updateCurYr.getErrMsg();
	}
	vSchYr = SS.getSchYear(dbOP, (String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(8));
	if(vSchYr == null)
		strErrMsg = SS.getErrMsg();
}
//System.out.println(vSchYr);
dbOP.cleanUP();
%>


<form action="./update_cur_yr.jsp" method="post" name="update_cur_yr">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          UPDATE CURRICULUM YEAR :::: </strong> <br>
          </font></div></td>
    </tr>
	</table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
		<td width="2%" height="25" colspan="4">&nbsp;</td>
      <td width="98%"><strong><%=strErrMsg%></strong></td>
    </tr>
  </table>
<%
if(bolIsSuccess)
	return;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="4%" height="25">&nbsp;</td>
      <td width="14%">Student ID</td>
      <td width="27%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="55%"><font size="1">
        <input name="image" type="image" src="../../../images/form_proceed.gif">
        </font></td>
    <tr >
      <td  colspan="4" height="25"><hr size="1"></td>
    </tr>
	</table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="96%">Student name : <%=(String)vStudInfo.elementAt(1)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Enrolled SY From-To/Term: <%=(String)vStudInfo.elementAt(2)%>-<%=(String)vStudInfo.elementAt(3)%>/
        <%=strConvertSem[Integer.parseInt((String)vStudInfo.elementAt(11))]%> </td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td>Course/Major :<strong> <%=(String)vStudInfo.elementAt(7)%>
	  <%if(vStudInfo.elementAt(8) != null){%>
	  /<%=(String)vStudInfo.elementAt(9)%>
	  <%}%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Old Curriculum year : <strong><%=(String)vStudInfo.elementAt(12)%></strong></td>
    </tr>
  </table>
<%
if(vSchYr != null && vSchYr.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td  colspan="3" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td>New Curriculum year :
        <select name="cy_from" onChange="ReloadPage();">
          <%
//get here school year
strTemp = WI.fillTextValue("cy_from");
if(strTemp.length() ==0)//get from student info.
	strTemp = (String)vStudInfo.elementAt(4);
int i = 0;
int j=0;

for(i = 0, j=0 ; i< vSchYr.size();)
{
	if(	((String)vSchYr.elementAt(i)).compareTo(strTemp) == 0)
	{%>
          <option value="<%=(String)vSchYr.elementAt(i)%>" selected><%=(String)vSchYr.elementAt(i)%></option>
          <%	j = i;
	}
	else{
	%>
          <option value="<%=(String)vSchYr.elementAt(i)%>"><%=(String)vSchYr.elementAt(i)%></option>
          <%	}
	i = i+2;

}
if(vSchYr.size() > 0)
	strSYTo = (String)vSchYr.elementAt(j+1);
else
	strSYTo = "";

%>
        </select>
        to <b><%=strSYTo%></b> <input type="hidden" name="cy_to" value="<%=strSYTo%>">
      </td>
    </tr>
    <tr>
      <td colspan="2" height="25"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
if(WI.fillTextValue("reloadPage").compareTo("1") ==0){%>
    <tr>
      <td width="4%" height="25" >&nbsp;</td>
      <td width="96%" ><a href="javascript:UpdateCurYr();"> <img src="../../../images/update.gif" border="0"></a>
        <font size="1">click to update curriculum year </font></td>
    </tr>
<%}%>	</tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:ShowResidency();"><img src="../../../images/view.gif" border="0"></a>
        <font size="1">click to view new residency status</font></td>
    </tr>
  </table>
<%}//if vSchYr is not null
}//vStudInfo not null
%>
 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="reloadPage">
<input type="hidden" name="updateCurYr">
  </form>
</body>
</html>
