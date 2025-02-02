<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SUBJECT SECTION MAINTENANCE</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrepareToEdit(strOldSection)
{
	document.ssection.old_section.value=strOldSection;
	document.ssection.section.value=strOldSection;
	document.ssection.section.focus();
}
function EditRecord()
{
	if(document.ssection.old_section.value.length ==0)
	{
		alert("Edit section information missing. Please click edit the section you want to edit.");
		return;
	}
	if(document.ssection.section.value.length ==0)
	{
		alert("Section can't be empty. Please enter new section.");
		return;
	}

	document.ssection.page_action.value="1";
	document.ssection.submit();
}
function DeleteRecord(strOldSection)
{
	var vProceed = confirm("Are you sure you want to delete the section. Deleting section will remove all section sechedules for this section.? Click cancel to cancel this operation.");

	if(vProceed)
	{
		document.ssection.page_action.value="0";
		document.ssection.old_section.value=strOldSection;
		document.ssection.submit();
	}
}
function CancelRecord()
{
	document.ssection.page_action.value = "";
	document.ssection.old_section.value = "";
	document.ssection.section.value = "";
}
function ReloadPage()
{
	document.ssection.page_action.value = "";
	document.ssection.old_section.value = "";
	document.ssection.submit();
}
function CloseWindow()
{
	window.opener.document.ssection.submit();
	window.opener.focus();
	self.close();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-edit subject section","edit_section.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"edit_section.jsp");
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

SubjectSection SS = new SubjectSection();
Vector vRetResult = new Vector();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	vRetResult = SS.operateOnEditSection(dbOP,request,Integer.parseInt(strTemp));
	if(vRetResult == null)
		strErrMsg = SS.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}

//get all levels created.
vRetResult =	SS.operateOnEditSection(dbOP,request,2);
if((vRetResult == null || vRetResult.size() ==0) && strErrMsg == null)
	strErrMsg = SS.getErrMsg();

dbOP.cleanUP();

if(strErrMsg == null) strErrMsg = "";
%>


<form name="ssection" method="post" action="./edit_section.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          SUBJECT SECTION MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a>
        <font size="1"><strong>Click to close window</strong></font></td>
    </tr>
    <tr>
      <td colspan="6" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Offering School year/term
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ssection","sy_from","sy_to")'>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp = WI.fillTextValue("sy_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp; <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
      <td>&nbsp; </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Old Subject Section &nbsp; <input name="old_section" type="text" size="30" readonly="yes" class="textbox_noborder"></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="35%" height="25">New Subject Section
        <input name="section" type="text" size="16" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress="if(event.keyCode==39 || event.keyCode==34) event.returnValue=false;">
      </td>
      <td colspan="2">
        <%if(iAccessLevel > 1){%>
        <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0">
        </a> <font size="1">click to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
        to cancel edit</font>
        <%}else{%>
        Not authorized to edit
        <%}%>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td width="34%">&nbsp; </td>
      <td width="30%">&nbsp; </td>
    </tr>
  </table>
  <table width="100%" border=0 bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8"><div align="center"><font color="#FFFFFF"><strong>LIST
          OF EXISTING SUBJECT SECTIONS FOR <%=request.getParameter("sy_from") +" - "+request.getParameter("sy_to")+ " " +
		  request.getParameter("semester_inword")%></strong></font></div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>
    <tr>
      <td width="21%">&nbsp;</td>
      <td width="33%"><strong><%=(String)vRetResult.elementAt(i)%></strong></td>
      <td width="12%" height="25">
        <%if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
        <%}%>
      </td>
      <td width="34%">
        <%if(iAccessLevel ==2){%>
        <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        NA
        <%}%>
      </td>
    </tr>
    <%
}//end of view all loops %>
  </table>

<%}//end of view all display%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<!-- all hidden fields go here -->
<input type="hidden" name="page_action">
<input type="hidden" name="semester_inword" value="<%=WI.fillTextValue("semester_inword")%>">
</form>
</body>
</html>
