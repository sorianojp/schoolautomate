<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function CopyAll()
{
	if(document.gsheet.copy_all.checked)
	{
		var totalGrades = eval(document.gsheet.total_grade_count.value);
		var strDate = document.gsheet.date0.value;
		var strTime = document.gsheet.time0.value;
		if(strDate.length ==0 || strTime.length ==0)
		{
			alert("Please enter first date and time field to copy.");
			return ;
		}
		for(var i =1; i< totalGrades; ++i)
		{
			eval('document.gsheet.date'+i+'.value = '+strDate);
			eval('document.gsheet.time'+i+'.value= '+strTime);
		}
	}
}
function PageAction(strAction)
{
	document.gsheet.page_action.value=strAction;
}
function ReloadPage()
{
	document.gsheet.submit();
}

</script>


<body bgcolor="#D2AE72">
<form name="gsheet" action="./grade_sheet.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade verify view all",
								"grade_sheet_verify_view_all.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Sheets Verification",request.getRemoteAddr(),
									null);

}

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

Vector vSectionDetail = null;//schedule and instructor name,
GradeSystem GS = new GradeSystem();
vSectionDetail = GS.getSectionDetail(dbOP, request.getParameter("sub_section"));
if(vSectionDetail == null && WI.fillTextValue("sub_section") != null && WI.fillTextValue("sub_section").compareTo("0") != 0)
	strErrMsg = GS.getErrMsg();
if(strErrMsg == null)
{
	if(WI.fillTextValue("page_action").compareTo("0") ==0) //save grade sheet.
	{
		if(GS.createGradeSheet(dbOP, request))
			strErrMsg = "Grades created successfully.";
		else
			strErrMsg = GS.getErrMsg();
	}
}

if(strErrMsg == null) strErrMsg = "";
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="57%" height="25"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FINAL GRADE SHEETS LISTING PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%"></td>
      <td width="34%" height="25"> <div align="left">SCHOOL YEAR : </div></td>
      <td width="64%">TERM : </td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td></td>
      <td height="25">SHOW : 
        <select name="select">
          <option>per subject</option>
          <option>per instructor</option>
          <option>ALL</option>
        </select></td>
      <td><div align="left">STATUS : 
          <select name="select4">
            <option>No Grade Encoded </option>
            <option>Grades Partially Encoded</option>
            <option>Verification Pending</option>
            <option>Verified</option>
            <option>ALL</option>
          </select>
        </div></td>
    </tr>
    <tr> 
      <td></td>
      <td height="25">Subject Code</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td></td>
      <td height="25" colspan="2"><select name="select2">
        </select>
        : <strong>$subj_desc</strong></td>
    </tr>
    <tr> 
      <td></td>
      <td height="25">Faculty Employee ID</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td></td>
      <td height="25" colspan="2"><select name="select3">
        </select>
        : <strong>$employee_name</strong></td>
    </tr>
  </table>
<%}else{%>

  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td  height="25" colspan="6" ><div align="center">LIST OF GRADE SHEETS FOR 
          STATUS <strong>$STATUS</strong></div></td>
    </tr>
    <tr> 
      <td width="16%"  height="25" ><div align="center"><font size="1"><strong>SUBJECT 
          CODE </strong></font></div></td>
      <td width="20%" ><div align="center"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
      <td width="15%" ><div align="center"><font size="1"><strong>SECTION</strong></font></div></td>
      <td width="32%" ><div align="center"><font size="1"><strong>INSTRUCTOR</strong></font></div></td>
      <td width="9%" ><div align="center"><font size="1"><strong>STATUS</strong></font></div></td>
      <td width="8%" ><div align="center"><strong><font size="1">EDIT STATUS</font></strong></div></td>
    </tr>
    <%
int j=0;
for(int i=0; i<vStudList.size(); ++i,++j){%>
    <input type="hidden" name="cur_hist<%=j%>" value="<%=(String)vStudList.elementAt(i)%>">
    <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vStudList.elementAt(i+1)%>">
    <tr> 
      <td  height="25" ><font size="1"><%=(String)vStudList.elementAt(i+6)%></font></td>
      <td ><font size="1"><%=(String)vStudList.elementAt(i+5)%></font></td>
      <td ><font size="1"><%=(String)vStudList.elementAt(i+2)%></font></td>
      <td ><font size="1"><%=(String)vStudList.elementAt(i+4)%></font></td>
      <td align="center">&nbsp;</td>
      <td ><div align="center"> 
          <input name="image" type="image" onClick="PageAction(0);" src="../../../images/edit.gif">
        </div></td>
    </tr>
    <%
i = i+6;
}
%>
    <input type="hidden" name="total_grade_count" value="2">
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="41%" height="41">&nbsp;</td>
      <td width="59%"><input type="image" src="../../../images/print.gif" onClick="PageAction(0);">
        <font size="1">click to print list</font></td>
    </tr>
</table>
<%		}//only if vStudList is not null -- there are students having empty grades.
	} //only if vSectionDetail is not null
}//only if school year from/ to is entered.
%>
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
          </tr>
  </table>
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
