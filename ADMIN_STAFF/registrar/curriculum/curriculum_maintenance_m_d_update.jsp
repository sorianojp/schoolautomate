<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrepareToEdit(strInfoIndex)
{
	document.creq.editRecord.value = 0;
	document.creq.addRecord.value = 0;
	document.creq.prepareToEdit.value = 1;

	document.creq.info_index.value=strInfoIndex;

	document.creq.submit();
}
function AddRecord()
{
	if(document.creq.prepareToEdit.value == 1)
	{
		EditRecord(document.creq.info_index.value);
		return;
	}
	document.creq.editRecord.value = 0;
	document.creq.addRecord.value = 1;

	document.creq.submit();
}
function EditRecord(strTargetIndex)
{
	document.creq.editRecord.value = 1;
	document.creq.addRecord.value = 0;

	document.creq.info_index.value = strTargetIndex;
	document.creq.submit();
}

function CancelRecord()
{
	location = "./curriculum_maintenance_m_d_update.jsp";
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses curriculum - masteral course update","curriculum_maintenance_m_d_update.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_maintenance_m_d_update.jsp");
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

CurriculumMaintenance CC = new CurriculumMaintenance();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	strPrepareToEdit="0";
	if(CC.createRequirement(dbOP,request.getParameter("requirement")))
		strErrMsg = "Requirement added successfully.";
	else
		strErrMsg = CC.getErrMsg();
}
else //edit
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(CC.editRequirement(dbOP,strInfoIndex,request.getParameter("requirement")))
			strErrMsg = "Requirement edited successfully.";
		else
			strErrMsg = CC.getErrMsg();
	}
	/*else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			strPrepareToEdit="0";
			if(CC.delete(dbOP,request.getParameter("info_index") ))
			{
				strErrMsg = "College deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="+2">
				<%=CC.getErrMsg()%></font></p>
				<%
				return;
			}
		}
	}*/
}

//get all levels created.
Vector vRetResult = new Vector();
String strReq = null;

if(request.getParameter("prepareToEdit") != null && request.getParameter("prepareToEdit").compareTo("1") ==0)
{
	vRetResult = CC.viewRequirement(dbOP, request.getParameter("info_index"), false);
	if(vRetResult == null || vRetResult.size () ==0)
	{
		if(strErrMsg == null)
			strErrMsg = CC.getErrMsg();
		else
			strErrMsg = strErrMsg + "<br>"+CC.getErrMsg();
	}
	else strReq = (String)vRetResult.elementAt(1);
}

vRetResult = CC.viewRequirement(dbOP, null,true);
if(vRetResult == null)
{
	if(strErrMsg == null)
		strErrMsg = CC.getErrMsg();
	else
		strErrMsg = strErrMsg + "<br>"+CC.getErrMsg();
}
if(strReq == null) strReq = WI.fillTextValue("requirement");

dbOP.cleanUP();

if(strErrMsg == null) strErrMsg = "";
%>
<form name="creq" action="./curriculum_maintenance_m_d_update.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          COURSES CURRICULUM MAINTENANCE - MASTERS &amp; DOCTORAL DEGREE - UPDATE
          COURSE REQUIREMENTS ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="6%" height="25"><a href="curriculum_maintenance_m_d.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td colspan="2"><strong><%=strErrMsg%></strong></td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course Requirements</td>
      <td width="70%" height="25"> <input name="requirement" type="text" size="32" value="<%=strReq%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
<%if(iAccessLevel > 1){%>
	<tr>
	<td height="25">&nbsp;</td>
	  <td colspan="2">&nbsp;
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to add</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to cancel
        or go to ADD</font>
        <%}%>
      </td>
    </tr>
<%}//if iAccessLevel > 1%>
  </table>
  <table width=100% border=0 bgcolor="#FFFFFF">

    <tr bgcolor="#B9B292">
      <td height="25" colspan="8"><div align="center">LIST OF EXISTING COURSE
          REQUIREMENTS </div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="66%" height="25">&nbsp;</td>
      <td width="34%">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="75%" height="25"><div align="center"><font size="1"><strong>COURSE
          REQUIREMENTS</strong></font></div></td>
      <td width="25%" align="center"><font size="1"><b>EDIT</b></font></td>
    </tr>
 <%
 for(int i= 0; i< vRetResult.size() ; ++i){%>
    <tr bgcolor="#FFFFFF">
      <td align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center">
<%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i++)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}else{%>Not authorized <%}%>
      </td>
    </tr>
<%}%>
  </table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="8">&nbsp;</td>
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

</form>
</body>
</html>
