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
	document.cdept.editRecord.value = 0;
	document.cdept.deleteRecord.value = 0;
	document.cdept.addRecord.value = 0;
	document.cdept.prepareToEdit.value = 1;
	document.cdept.info_index.value = strInfoIndex;
	document.cdept.submit();

}
function AddRecord()
{
	if(document.cdept.prepareToEdit.value == 1)
	{
		EditRecord(document.cdept.info_index.value);
		return;
	}
	document.cdept.editRecord.value = 0;
	document.cdept.deleteRecord.value = 0;
	document.cdept.addRecord.value = 1;

	document.cdept.submit();
}
function EditRecord(strTargetIndex)
{
	document.cdept.editRecord.value = 1;
	document.cdept.deleteRecord.value = 0;
	document.cdept.addRecord.value = 0;

	document.cdept.info_index.value = strTargetIndex;

	document.cdept.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.cdept.editRecord.value = 0;
	document.cdept.deleteRecord.value = 1;
	document.cdept.addRecord.value = 0;

	document.cdept.info_index.value = strTargetIndex;
	document.cdept.prepareToEdit.value == 0;

	document.cdept.submit();
}
function CancelRecord()
{
	location = "./department.jsp";
}
function PrintPg() {
	var win=window.open("./department_print.jsp","PrintWindow",'width=800,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumDept,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
//add security here.
	try
	{
		dbOP = new DBOperation();
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
int iAccessLevel = 2;
if(request.getSession(false).getAttribute("userIndex") == null)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../index.jsp");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
//end of authenticaion code.

CurriculumDept CC = new CurriculumDept();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	strPrepareToEdit="0";

	//add it here and give a message.
	if(CC.add(dbOP,request))
	{
		strErrMsg = "Department added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font  size="3">	<%=CC.getErrMsg()%></font></p>
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
			strErrMsg = "Department edited successfully.";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font size="3"><%=CC.getErrMsg()%></font></p>
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
				strErrMsg = "Department deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font size="3"><%=CC.getErrMsg()%></font></p>
				<%
				return;
			}
		}
	}
}

//get all levels created.
Vector vRetResult = new Vector();
vRetResult = CC.viewall(dbOP);

if(vRetResult ==null)
{%>
	<p align="center"> <font size="3"><%=CC.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}

Vector vEditInfo = new Vector();
if(strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
	vEditInfo = CC.view(dbOP,request.getParameter("info_index"));

%>

<form name="cdept" action="./department.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>:::: 
          MANAGER DEPARTMENT ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >Department code</td>
      <td colspan="2"> <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("d_code");
	if(strTemp == null) strTemp = "";
	%> <input name="d_code" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="8%">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%" >Department name</td>
      <td colspan="2"> <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("d_code");
	if(strTemp == null) strTemp = "";
	%> <input name="d_name" type="text" size="48" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Dept. Head</td>
      <td colspan="2"> <%
if(vEditInfo != null && vEditInfo.size() > 1)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = request.getParameter("dh_name");
if(strTemp == null) strTemp = "";
%> <input name="dh_name" type="text" size="48" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	
      </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Under division of</td>
      <td width="50%"> <select name="c_index">
          <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("c_index");
	if(strTemp == null) strTemp = "";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, true)%> </select> </td>
      <td width="19%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td colspan="3"> <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%> <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1" >click 
        to add </font> <%}else{%> <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" >click 
        to save changes </font><a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1" >click to cancel or go previous </font> <%}%> </td>
    </tr>
    <%}//if iAccessLevel > 1
if(strErrMsg != null)
{%>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="2"><b><font  size="3"><%=strErrMsg%></font></b></td>
      <td colspan="2"><div align="right"></div></td>
    </tr>
    <%}//this shows the edit/add/delete success info%>
  </table>
<table width="100%" bgcolor="#FFFFFF">
<%
if(vRetResult.size() > 0)
{%>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center">LIST OF EXISTING DEPARTMENTS</div></td>
    </tr>


  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="6%"><div align="center"><font size="1" ><b>DEPT CODE</b></font></div></td>
      <td width="35%" height="25"><div align="center"><font size="1" ><b>DEPARTMENT 
          NAME </b></font></div></td>
      <td width="15%"><div align="center"><strong><font size="1">DEPT. HEAD</font></strong></div></td>
      <td width="30%"><div align="center"><font size="1"><b>DIVISION  NAME </b></font></div></td>
      <td width="7%" align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>
    <tr> 
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=(String)vRetResult.elementAt(i+2)%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td ><%=(String)vRetResult.elementAt(i+3)%></td>
      <td align="center"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized
        <%}%> </td>
      <td align="center"> <%if(iAccessLevel > 1){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized
        <%}%> </td>
    </tr>
    <% i = i+5;
	}//end of displaying levels
}//end of displaying existing question level
%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
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
