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
function PrepareToEdit(strInfoIndex, strCName)
{
	document.scatg.editRecord.value = 0;
	document.scatg.deleteRecord.value = 0;
	document.scatg.addRecord.value = 0;
	document.scatg.prepareToEdit.value = 1;

	document.scatg.catg_name.value = strCName;
	document.scatg.info_index.value = strInfoIndex;

	document.scatg.catg_name.focus();

}
function AddRecord()
{
	if(document.scatg.prepareToEdit.value == 1)
	{
		EditRecord(document.scatg.info_index.value);
		return;
	}
	document.scatg.editRecord.value = 0;
	document.scatg.deleteRecord.value = 0;
	document.scatg.addRecord.value = 1;

	document.scatg.submit();
}
function EditRecord(strTargetIndex)
{
	document.scatg.editRecord.value = 1;
	document.scatg.deleteRecord.value = 0;
	document.scatg.addRecord.value = 0;

	document.scatg.info_index.value = strTargetIndex;
	document.scatg.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.scatg.editRecord.value = 0;
	document.scatg.deleteRecord.value = 1;
	document.scatg.addRecord.value = 0;

	document.scatg.info_index.value = strTargetIndex;
	document.scatg.prepareToEdit.value == 0;

	document.scatg.submit();
}


</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumSCatg,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Subjects Maintenance -subject category","curriculum_subject_catg.jsp");
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
														"curriculum_subject_catg.jsp");
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

CurriculumSCatg SC = new CurriculumSCatg();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(SC.add(dbOP,request))
	{
		strErrMsg = "Subject added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=SC.getErrMsg()%></font></p>
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
		if(SC.edit(dbOP,request))
		{
			strErrMsg = "Subject edited successfully.";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			<%=SC.getErrMsg()%></font></p>
			<%
			return;
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			if(SC.delete(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
			{
				strErrMsg = "Subject deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
				<%=SC.getErrMsg()%></font></p>
				<%
				return;
			}
		}
	}
}

//get all levels created.
Vector vRetResult = new Vector();
vRetResult = SC.viewall(dbOP);
dbOP.cleanUP();

if(vRetResult ==null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=SC.getErrMsg()%></font></p>
	<%
	return;
}

%>


<form name="scatg" method="post" action="../../registrar/curriculum/./curriculum_subject_catg.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          FIXED ASSETS &amp; DEPRECIATION - ADD/CREATE - UPDATE ASSET TYPE PAGE
          ::::</strong></font><font color="#FFFFFF"></font></div></td>
    </tr>
    <tr>
      <td colspan="8" height="25"><font size="3"><%=strErrMsg%></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" height="25"><a href="fixed_assets_depre.jsp" target="_self"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td>&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="3" height="25">Asset Type
        <input name="catg_name" type="text" size="16" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
      <td colspan="3">
<%if(iAccessLevel > 1){%>
	  <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a>
	  <font size="1">click to save entry/changes</font>
<%}else{%>Not authorized to add/edit/delete<%}%>
	  </td>
      <td width="10%">&nbsp;</td>
    </tr>
    <%
    if(strErrMsg != null)
    {%>
    <%}//this shows the edit/add/delete success info%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
      <td width="24%" height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table> <table width="100%" border=0 bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8"><div align="center">LIST OF EXISTING ASSET TYPE</div></td>
    </tr>
  </table>
<%
if(vRetResult != null)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

<%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>

    <tr>
      <td width="27%">&nbsp;</td>
      <td width="36%"><strong><%=(String)vRetResult.elementAt(i+1)%></strong></td>
      <td width="10%" height="25">
<%if(iAccessLevel > 1){%>
      <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i+1)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
<%}%>	  </td>
      <td width="27%">
<%if(iAccessLevel ==2){%>
      <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
<%}%>	  </td>
    </tr>
<%
i = i+1;
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
<input type="hidden" name="info_index" value="0">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="0">
<input type="hidden" name="deleteRecord" value="0">

</form>
</body>
</html>
