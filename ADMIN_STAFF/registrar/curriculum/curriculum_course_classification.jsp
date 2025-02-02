<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//this is called when edit button is clicked -- it moves the value to be edited to the add and set variable
//prepareToEdit =1 - when the add button clicked - if prepareToEdit is set -- then it sets editRecord to 1 and
//addRecord to 0 otherwise, it set addRecord to 1; -- Complicated - huh? -- done to save edit page :D
function PrepareToEdit(strInfoIndex, strCCName, strCCCode,strCCOrder)
{
	document.cclassification.editRecord.value = 0;
	document.cclassification.deleteRecord.value = 0;
	document.cclassification.addRecord.value = 0;
	document.cclassification.prepareToEdit.value = 1;

	document.cclassification.cc_code.value = strCCCode;
	document.cclassification.cc_name.value = strCCName;
	document.cclassification.info_index.value = strInfoIndex;
	document.cclassification.cc_order.value = strCCOrder;

	document.cclassification.submit();

}
function AddRecord()
{
	if(document.cclassification.prepareToEdit.value == 1)
	{
		EditRecord(document.cclassification.info_index.value);
		return;
	}
	document.cclassification.editRecord.value = 0;
	document.cclassification.deleteRecord.value = 0;
	document.cclassification.addRecord.value = 1;
	document.cclassification.submit();
}
function EditRecord(strTargetIndex)
{
	document.cclassification.editRecord.value = 1;
	document.cclassification.deleteRecord.value = 0;
	document.cclassification.addRecord.value = 0;

	document.cclassification.info_index.value = strTargetIndex;

	document.cclassification.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.cclassification.editRecord.value = 0;
	document.cclassification.deleteRecord.value = 1;
	document.cclassification.addRecord.value = 0;

	document.cclassification.info_index.value = strTargetIndex;
	document.cclassification.prepareToEdit.value == 0;

	document.cclassification.submit();
}
function CancelRecord()
{
	location = "./curriculum_course_classification.jsp";
}
function PrintPg() {
	var win=window.open("./curriculum_course_classification_print.jsp","PrintWindow",'width=800,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>

<body bgcolor="#D2AE72" onLoad="document.cclassification.cc_order.focus();">
<%@ page language="java" import="utility.*,enrollment.CurriculumCClassification,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

	boolean bolIsSuccess = false;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Course Classfication",
								"curriculum_course_classification.jsp");
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
														"curriculum_course_classification.jsp");
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

CurriculumCClassification CC = new CurriculumCClassification();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	strPrepareToEdit="0";

	//add it here and give a message.
	if(CC.add(dbOP,request))
	{
		strErrMsg = "Course program added successfully.";
		bolIsSuccess = true;
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font  size="3">
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
			strErrMsg = "Course program edited successfully.";
			bolIsSuccess = true;
			strPrepareToEdit="0";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font  size="3">
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
				strErrMsg = "Course program deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font  size="3">
				<%=CC.getErrMsg()%></font></p>
				<%
				return;
			}
		}
	}
}

//get all levels created.
Vector vRetResult = null;
vRetResult = CC.viewall(dbOP);
dbOP.cleanUP();

if(vRetResult ==null)
{%>
	<p align="center"> <font  size="3">
	<%=CC.getErrMsg()%></font></p>
	<%
	return;
}

%>

<form name="cclassification" action="./curriculum_course_classification.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          COURSE PROGRAMS ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">Order Number</td>
      <td height="25">Course Program Code</td>
      <td> Course Program Name</td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
<%
	strTemp = request.getParameter("cc_order");
	if(strTemp == null || bolIsSuccess) strTemp = "";
	%> 	  
      <td width="17%" height="25"><input name="cc_order" type="text" size="3" maxlength="2"	class="textbox" 
									onfocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
									onblur="style.backgroundColor='white';AllowOnlyInteger('cclassification','cc_order')"
									onKeyUp="AllowOnlyInteger('cclassification','cc_order')"></td>
      <td width="31%" height="25"> <%
	strTemp = request.getParameter("cc_code");
	if(strTemp == null || bolIsSuccess) strTemp = "";
	%> <input type="text" name="cc_code" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="50%"> <%
	strTemp = request.getParameter("cc_name");
	if(strTemp == null || bolIsSuccess) strTemp = "";
	%> <input type="text" name="cc_name" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td colspan="7">&nbsp;</td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"> <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%> <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1" >click 
        to add</font> <%}else{%> <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" >click 
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1" >click to cancel or go previous</font> <%}%> </td>
    </tr>
    <%}//if iAccessLevel > 1
if(strErrMsg != null)
{%>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td colspan="3"><b><font color="#FF0000" size="3">&nbsp;<%=strErrMsg%></font></b></td>
    </tr>
    <%}//this shows the edit/add/delete success info%>
    <tr> 
      <td colspan="7"><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>&nbsp;<font size="1">click 
          to print list </font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(vRetResult.size() > 0)
{%>
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6"><div align="center"><strong>LIST OF EXISTING 
          COURSE PROGRAMS</strong></div></td>
    </tr>
    <tr> 
      <td colspan="7">&nbsp;</td>
    </tr>
    <%

for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="7%"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"", "]","&nbsp;")%></td>
      <td width="23%"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td width="43%"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td width="8%"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i+2)%>","<%=(String)vRetResult.elementAt(i+1)%>","<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
        <%}else{%>
        Not authorized to edit
        <%}%></td>
      <td width="15%"> <%if(iAccessLevel ==2){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%>
        Not authorized to delete
        <%}%></td>
    </tr>
    <% i = i+3;
	}//end of displaying levels
}//end of displaying existing question level
%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><div align="center"><strong></strong></div></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>

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
