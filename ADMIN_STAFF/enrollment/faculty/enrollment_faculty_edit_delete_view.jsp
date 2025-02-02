<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrintPage()
{
	var strCIndex = document.faculty_page.c_index[document.faculty_page.c_index.selectedIndex].value;
	var strDIndex = document.faculty_page.d_index[document.faculty_page.d_index.selectedIndex].value;

	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	var sT = "#";
	if(vProceed)
		sT = "./enrollment_faculty_list_print.jsp?c_index="+strCIndex+"&d_index="+strDIndex;

	//print here
	if(vProceed)
	{
		var win=window.open(sT,"PrintWindow",'scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

}
function ReloadPage()
{
	document.faculty_page.submit();
}
function Proceed()
{
	document.faculty_page.proceed.value = "1";
}
function DeleteRecord(strIndex)
{
	document.faculty_page.deleteRecord.value = "1";
	document.faculty_page.info_index.value = strIndex;
	ReloadPage();
}
function EditInfo(strIndex,strCollegeIndex,strDeptIndex)
{
	//other_page=1 means called from edit_view page.

	location = "./enrollment_faculty_add.jsp?other_page=1&prepareToEdit=1&info_index="+strIndex+"&c_index="+strCollegeIndex+"&d_index="+strDeptIndex;
}


</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-add","enrollment_faculty_add.jsp");
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
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"enrollment_faculty_add.jsp");
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

Vector vRetResult = null;
FacultyManagement FM = new FacultyManagement();
strTemp = request.getParameter("deleteRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	if(FM.deleteFaculty(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
		strErrMsg = "Faculty deleted successfully.";
	else
		strErrMsg = FM.getErrMsg();
}

if(request.getParameter("proceed") != null && request.getParameter("proceed").compareTo("1") ==0)
	vRetResult = FM.viewFacultyPerDeptCollege( dbOP, request.getParameter("c_index"),request.getParameter("d_index"));
if(vRetResult == null)
	strErrMsg = FM.getErrMsg();

if(strErrMsg == null) strErrMsg = "";
%>
<form action="./enrollment_faculty_edit_delete_view.jsp" method="post" name="faculty_page">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          FACULTY PAGE - EDIT/DELETE ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="16%" height="25">&nbsp;</td>
      <td width="17%">College </td>
      <td width="67%" valign="bottom"><select name="c_index" onChange="ReloadPage();">
          <option value="0">All</option>
<%
	strTemp = request.getParameter("c_index");
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Department </td>
      <td><select name="d_index">
	  <option value="0">All</option>
          <%
strTemp2 = request.getParameter("d_index");

//only if there is a college selected.
if(strTemp != null && strTemp.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp2, false)%>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="image" src="../../../images/form_proceed.gif" onClick="Proceed();"></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="25">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8"><div align="center">LIST OF FACULTIES</div></td>
    </tr>
    <tr>
      <td width="21%"><div align="center"><font size="1">COLLEGE</font></div></td>
      <td width="20%" height="25"><div align="center"><font size="1">DEPARTMENT</font></div></td>
      <td width="10%"><div align="center"><font size="1">EMPLOYEE ID </font></div></td>
      <td width="21%"><div align="center"><font size="1">EMPLOYEE NAME</font></div></td>
      <td width="5%"><div align="center"><font size="1">GENDER</font></div></td>
      <td width="8%"><div align="center"><font size="1">EMP. STATUS</font></div></td>
      <td width="5%" align="center"><font size="1">EDIT</font></td>
      <td width="5%" align="center"><font size="1">DELETE</font></td>
    </tr>
<%
	int iTotal = 0;
	String[] astrConvertGender = {"M","F"};

for(int i=0; i<vRetResult.size(); ++i){
++iTotal; %>
    <tr>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+7))%></td>
      <td height="25">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+8))%></td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),1)%></td>
      <td><%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(i+6))]%></td>
      <td><%=(String)vRetResult.elementAt(i+5)%></td>
      <td>
	  <%if(iAccessLevel > 1){%>
	  <a href='javascript:EditInfo("<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i+9)%>","<%=(String)vRetResult.elementAt(i+10)%>");'><img src="../../../images/edit.gif" border="0"></a>
	  <%}else{%>Not authorized<%}%>
	  </td>
      <td height="26">
	  <%if(iAccessLevel == 2){%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
	  <%}else{%>Not authorized<%}%>
	  </td>
    </tr>
<% i = i+10;
}%>
    <tr>
      <td  colspan="4" height="25"><font size="1">TOTAL NUMBER OF FACULTIES :
        <strong><%=iTotal%></strong></font></td>
      <td  colspan="4" height="25"><font size="1"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click
        to print this list</font></td>
    </tr>
  </table>
 <%}//display if vRetResult not null
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" >&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="proceed" value="<%=WI.fillTextValue("proceed")%>">
<input type="hidden" name="deleteRecord" value="0">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>