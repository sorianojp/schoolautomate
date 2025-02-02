<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript">
//this is called when edit button is clicked -- it moves the value to be edited to the add and set variable
//prepareToEdit =1 - when the add button clicked - if prepareToEdit is set -- then it sets editRecord to 1 and
//addRecord to 0 otherwise, it set addRecord to 1; -- Complicated - huh? -- done to save edit page :D
function PrepareToEdit(strInfoIndex)
{
	document.ccollege.editRecord.value = 0;
	document.ccollege.deleteRecord.value = 0;
	document.ccollege.addRecord.value = 0;
	document.ccollege.prepareToEdit.value = 1;

	document.ccollege.info_index.value = strInfoIndex;
	document.ccollege.submit();

}
function AddRecord()
{
	if(document.ccollege.prepareToEdit.value == 1)
	{
		EditRecord(document.ccollege.info_index.value);
		return;
	}
	document.ccollege.editRecord.value = 0;
	document.ccollege.deleteRecord.value = 0;
	document.ccollege.addRecord.value = 1;

	document.ccollege.submit();
}
function EditRecord(strTargetIndex)
{
	document.ccollege.editRecord.value = 1;
	document.ccollege.deleteRecord.value = 0;
	document.ccollege.addRecord.value = 0;

	document.ccollege.info_index.value = strTargetIndex;
	document.ccollege.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.ccollege.editRecord.value = 0;
	document.ccollege.deleteRecord.value = 1;
	document.ccollege.addRecord.value = 0;

	document.ccollege.info_index.value = strTargetIndex;
	document.ccollege.prepareToEdit.value == 0;

	document.ccollege.submit();
}
function CancelRecord()
{
	location = "./curriculum_college.jsp";
}
function PrintPg() {
	var win=window.open("./curriculum_college_print.jsp","PrintWindow",'width=800,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>


<body bgcolor="#D2AE72" onLoad="document.ccollege.c_code.focus();">
<%@ page language="java" import="utility.*,enrollment.CurriculumCollege,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	Vector vEditInfo = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
	boolean bolIsSuccess = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Colleges","curriculum_college.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_college.jsp");
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

CurriculumCollege CC = new CurriculumCollege();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	strPrepareToEdit="0";
	if(CC.add(dbOP,request))
	{
		strErrMsg = "College added successfully.";
		bolIsSuccess = true;
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font size="3">
		<%=CC.getErrMsg()%></font></p>
		<%
		return;
	}
}
else //either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(CC.edit(dbOP,request))
		{
			strErrMsg = "College edited successfully.";
			strPrepareToEdit="0";
			bolIsSuccess = true;
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font size="3">
			<%=CC.getErrMsg()%></font></p>
			<%
			return;
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			strPrepareToEdit="0";
			if(CC.delete(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
			{
				strErrMsg = "College deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font size="3">
				<%=CC.getErrMsg()%></font></p>
				<%
				return;
			}
		}
	}
}
if(strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = CC.view(dbOP,WI.fillTextValue("info_index"));
	if(vEditInfo == null)
		strErrMsg = CC.getErrMsg();
}

//get all levels created.
Vector vRetResult = new Vector();
vRetResult = CC.viewall(dbOP);
dbOP.cleanUP();

if(vRetResult ==null)
{%>
	<p align="center"> <font size="3">
	<%=CC.getErrMsg()%></font></p>
	<%
	return;
}

%>

<form name="ccollege" method="post" action="./curriculum_college.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: 
          COLLEGES ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" width="42%">College code 
        <%
	if(vEditInfo != null)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = WI.fillTextValue("c_code");
	if(	bolIsSuccess )
		strTemp = "";
	%>
        <input name="c_code" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="56%">College name 
        <%
	if(vEditInfo != null)
		strTemp = (String)vEditInfo.elementAt(0);
	else
		strTemp = WI.fillTextValue("c_name");
	if(	bolIsSuccess )
		strTemp = "";
	%>
        <input name="c_name" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <%
if(strErrMsg != null)
{%>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28" colspan="2">Dean &nbsp; 
        <%
	if(vEditInfo != null)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = WI.fillTextValue("dean_name");
	if(	bolIsSuccess )
		strTemp = "";
%>
        <input name="dean_name" type="text" size="45" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>"> 
        <font size="1">(complete name, degree titles)</font> </td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"> 
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click 
        to add</font> 
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel or go previous</font> 
        <%}%>
      </td>
    </tr>
    <%}%>
    <tr> 
      <td width="2%" height="29">&nbsp;</td>
      <td><div align="left"><font size="3"><%=strErrMsg%></font></div></td>
      <td><div align="right"><font size="3"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>&nbsp;<font size="1">click 
          to print list </font></font></div></td>
    </tr>
    <%}//this shows the edit/add/delete success info%>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(vRetResult.size() > 0)
{%>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="7"><div align="center">LIST
          OF EXISTING COLLEGES</div></td>
    </tr>
    <tr>
      <td><div align="center"><font size="1"><strong>COLLEGE CODE</strong></font></div></td>
      <td height="25"><div align="center"><font size="1"><strong>COLLEGE NAME</strong></font></div></td>
      <td><div align="center"><font size="1"><strong>DEAN</strong></font></div></td>
      <td align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>
    <tr>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td width="42%" height="25"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td width="27%"><%=WI.getStrValue(vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td width="5%">
	  <%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
      <%}else{%>Not authorized<%}%></td>
	  <td width="6%">
	  <%if(iAccessLevel ==2 ){%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
      <%}else{%>Not authorized<%}%></td>
    </tr>
    <% i = i+3;
	}//end of displaying levels
}//end of displaying existing question level
%>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0"></tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="8"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="8"><font size="3"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>&nbsp;<font size="1">click 
        to print list </font></font></td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
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

</form>
</body>
</html>
