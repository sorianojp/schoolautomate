<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function ShowHideLayer()
{
	if(document.faculty_page.emp_status.selectedIndex ==0)
	{
		document.faculty_page.emp_status_oth.disabled = false;
		showLayer('oth_');
	}
	else
	{
		hideLayer('oth_');
		document.faculty_page.emp_status_oth.disabled = true;
	}
}
function PrintPage()
{
	var strCIndex = document.faculty_page.c_index[document.faculty_page.c_index.selectedIndex].value;
	var strDIndex = "0";
	if(document.faculty_page.d_index.selectedIndex>=0)
		strDIndex=document.faculty_page.d_index[document.faculty_page.d_index.selectedIndex].value;

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
function ChangeCollgeName()
{
	document.faculty_page.college_name.value = document.faculty_page.c_index[document.faculty_page.c_index.selectedIndex].text;
	document.faculty_page.submit();
}
function PrepareToEdit(strInfoIndex)
{
	document.faculty_page.editRecord.value = 0;
	document.faculty_page.deleteRecord.value = 0;
	document.faculty_page.addRecord.value = 0;
	document.faculty_page.prepareToEdit.value = 1;
	document.faculty_page.info_index.value = strInfoIndex;

	document.faculty_page.submit();
}
function AddRecord()
{
	if(document.faculty_page.prepareToEdit.value == 1)
	{
		EditRecord(document.faculty_page.info_index.value);
		return;
	}
	document.faculty_page.editRecord.value = 0;
	document.faculty_page.deleteRecord.value = 0;
	document.faculty_page.addRecord.value = 1;

	document.faculty_page.submit();
}
function EditRecord(strTargetIndex)
{
	document.faculty_page.editRecord.value = 1;
	document.faculty_page.deleteRecord.value = 0;
	document.faculty_page.addRecord.value = 0;

	document.faculty_page.info_index.value = strTargetIndex;
	document.faculty_page.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.faculty_page.editRecord.value = 0;
	document.faculty_page.deleteRecord.value = 1;
	document.faculty_page.addRecord.value = 0;

	document.faculty_page.info_index.value = strTargetIndex;
	document.faculty_page.prepareToEdit.value == 0;

	document.faculty_page.submit();
}
function CancelRecord()
{
	document.faculty_page.editRecord.value = 0;
	document.faculty_page.prepareToEdit.value = 0;
	var otherPage = document.faculty_page.other_page.value;
	if(otherPage =="1") //it is called from another page, now go there.
		location = "./enrollment_faculty_edit_delete_view.jsp?proceed=1&c_index="+document.faculty_page.other_page_cindex.value+
				"&d_index="+document.faculty_page.other_page_dindex.value;
	else
		document.faculty_page.submit();
}
function ReloadPage()
{
	document.faculty_page.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

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

FacultyManagement FM = new FacultyManagement();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	strPrepareToEdit="0";
	if(FM.createFaculty(dbOP,request))
		strErrMsg = "Faculty added successfully.";
	else
		strErrMsg = FM.getErrMsg();
}
else //either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(FM.editFaculty(dbOP,request))
			strErrMsg = "Faculty edited successfully.";
		else
			strErrMsg = FM.getErrMsg();
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			strPrepareToEdit="0";
			if(FM.deleteFaculty(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
				strErrMsg = "Faculty deleted successfully.";
			else
				strErrMsg = FM.getErrMsg();

		}
	}
}

//get all faculties created.
Vector vRetResult = null;
Vector vEditInfo  = null;
if(strPrepareToEdit.compareTo("1") ==0)
{
	//get edit information.
	vEditInfo = FM.viewOneFacultyDetail(dbOP, request.getParameter("info_index"));
	if(vEditInfo == null)
		strErrMsg = FM.getErrMsg();
}
vRetResult = FM.viewFacultyPerDeptCollege( dbOP, request.getParameter("c_index"),request.getParameter("d_index"));

if(strErrMsg == null) strErrMsg = "";
%>
<form action="./enrollment_faculty_add.jsp" method="post" name="faculty_page">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          FACULTY PAGE - ADD ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="18%">College </td>
      <td width="78%" valign="bottom">
        <select name="c_index" onChange="ChangeCollgeName();">
		<option value="-1">Select a college</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("c_index");
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%>
       </select>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Department </td>
      <td><select name="d_index">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp2 = (String)vEditInfo.elementAt(6);
else
	strTemp2 = WI.fillTextValue("d_index");

//only if there is a college selected.
if(strTemp.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp2, false)%>
<%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Employee ID</td>
      <td height="20">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(0);
else
	strTemp = WI.fillTextValue("emp_id");
%>
        <input name="emp_id" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Employee Name&nbsp; </td>
      <td height="20">
        <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("fname");
%>
        <input name="fname" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        (fname)
        <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("mname");
%>
        <input name="mname" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        (mname)
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("lname");
%>
        <input name="lname" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        (lname)

        </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Gender
        </td>
      <td height="20"> <select name="gender">
          <option value="0">Male</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(7);
else
	strTemp = WI.fillTextValue("gender");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Female</option>
          <%}else{%>
          <option value="1">Female</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Employment
        Status </td>
      <td height="20">
	    <select name="emp_status" onChange="ShowHideLayer();">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("emp_status");
%>
          <option value="0">Others(Pl specify)</option>
          <%=dbOP.loadCombo("STATUS_INDEX","STATUS"," from USER_STATUS where is_for_student=0 order by STATUS asc", strTemp, false)%>

        </select>
        <input name="emp_status_oth" type="text" size="16" value="<%=WI.fillTextValue("emp_status_oth")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" id="oth_"></td>
    </tr>
    <tr>
      <td colspan="3" height="20"><hr size="1"></td>
      <td width="0%" valign="bottom">&nbsp;</td>
      <td width="0%" valign="bottom">&nbsp;</td>
    </tr>
  </table>
<%
if(iAccessLevel > 1){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="14%" height="25"><div align="center"></div></td>
      <td width="86%" height="25" colspan="2">
        <%
strTemp = strPrepareToEdit;
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to add</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to cancel
        or go previous</font>
        <%}%>
      </td>
    </tr>
  </table>
<%}
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="7"><div align="center">LIST
          OF FACULTIES UNDER <strong><%=request.getParameter("college_name")%></strong></div></td>
    </tr>
    <tr>
      <td width="26%" height="25"><div align="center"><font size="1">COLLEGE :: 
          DEPT</font></div></td>
      <td width="20%"><div align="center"><font size="1">EMPLOYEE ID</font></div></td>
      <td width="20%"><div align="center"><font size="1">EMPLOYEE NAME</font></div></td>
      <td width="6%"><div align="center"><font size="1">GENDER</font></div></td>
      <td width="10%"><div align="center"><font size="1">EMP. STATUS</font></div></td>
	  <td width="9%" align="center"><font size="1">EDIT</font></td>
	  <td width="9%" align="center"><font size="1">DELETE</font></td>
    </tr>
<%
	int iTotal = 0; //total faculty.
	String[] astrConvertGender = {"M","F"};

	for(int i=0; i<vRetResult.size(); ++i){
	++iTotal;%>
	  <tr>
      <td height="25">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+8))%></td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),1)%></td>
      <td><%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(i+6))]%></td>
      <td><%=(String)vRetResult.elementAt(i+5)%></td>
	  <td>
	  <%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
	  <%}else{%>Not authorized<%}%>
	  </td>
      <td>
	  <%if(iAccessLevel == 2){%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
	  <%}else{%>Not authorized<%}%>
	  </td>

    </tr>
<% i = i+10;
}%>
    <tr>
      <td  colspan="4" height="25"><font size="1">TOTAL NUMBER OF FACULTIES FOR
        THIS COLLEGE : </font><strong><%=iTotal%></strong></td>
      <td  colspan="3" height="25" align="right">
	  <a href="javascript:PrintPage();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>
        <font size="1">click to print this list</font></td>
    </tr>
  </table>
<%}//only if vRetResult is not null.
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" >&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="college_name" value="<%=WI.fillTextValue("college_name")%>">
<input type="hidden" name="other_page" value="<%=WI.fillTextValue("other_page")%>">
<%
if(WI.fillTextValue("other_page").compareTo("1") ==0 && WI.fillTextValue("other_page_cindex").length() == 0)
	strTemp = request.getParameter("c_index");
else
	strTemp = request.getParameter("other_page_cindex");
%>
<input type="hidden" name="other_page_cindex" value="<%=strTemp%>">
<%
if(WI.fillTextValue("other_page").compareTo("1") ==0 && WI.fillTextValue("other_page_cindex").length() == 0)
	strTemp = request.getParameter("d_index");
else
	strTemp = request.getParameter("other_page_dindex");
if(strTemp == null || strTemp.compareTo("null") ==0) strTemp = "";
%>
<input type="hidden" name="other_page_dindex" value="<%=strTemp%>">

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
