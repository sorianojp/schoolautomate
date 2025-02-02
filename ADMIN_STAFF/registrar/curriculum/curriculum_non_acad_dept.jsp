<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function GoBack()
{
	location = document.cdept.parentURL.value;
}
function PrepareToEdit(strInfoIndex)
{
	document.cdept.page_action.value = "";
	document.cdept.prepareToEdit.value = 1;
	document.cdept.info_index.value = strInfoIndex;
	document.cdept.submit();

}
function PageAction(iAction,strInfoIndex)
{
	document.cdept.info_index.value = strInfoIndex;
	document.cdept.page_action.value = iAction;
	if(iAction ==0 || iAction == 1)
		document.cdept.prepareToEdit.value = "";

	document.cdept.submit(iAction);
}
function CancelRecord()
{
	location = "./curriculum_non_acad_dept.jsp";
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumDept,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Departments","curriculum_non_acad_dept.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","CURRICULUM",request.getRemoteAddr(),
							//							"curriculum_non_acad_dept.jsp");
if(request.getSession(false).getAttribute("userId") == null)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}

//end of authenticaion code.

CurriculumDept CC = new CurriculumDept();

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	if(CC.operateOnNonOfficeDept(dbOP,request,Integer.parseInt(strTemp)) == null)
	{
		strErrMsg = CC.getErrMsg();
	}
	else
	{
		strErrMsg = "Operation successful.";
		strPrepareToEdit = "0";
	}
}

//get all levels created.
Vector vRetResult = new Vector();
Vector vEditInfo = new Vector();

vRetResult = CC.operateOnNonOfficeDept(dbOP,request,4);

if(vRetResult ==null && strErrMsg == null)
{
	strErrMsg = CC.getErrMsg();
}

if(strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = CC.operateOnNonOfficeDept(dbOP,request,3);
	if(vEditInfo == null)
		strErrMsg = CC.getErrMsg();
}

%>

<form name="cdept" action="./curriculum_non_acad_dept.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          DEPARTMENTS ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;
<%
if(WI.fillTextValue("parentURL").length() > 0){%>
	  <a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a>
	  <font size="1">Click here to go back</font>
<%}%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Department code:</td>
      <td width="69%" colspan="2">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = WI.fillTextValue("d_code");
	%>
        <input name="d_code" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td width="8%">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%" >Department name:</td>
      <td colspan="2">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = WI.fillTextValue("d_name");
	%>
        <input name="d_name" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td>&nbsp;</td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td colspan="3">
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href='javascript:PageAction("1","0");'><img src="../../../images/add.gif" border="0"></a><font size="1" >click
        to add </font>
        <%}else{%>
        <a href='javascript:PageAction("2","<%=WI.fillTextValue("info_index")%>");'><img src="../../../images/edit.gif" border="0"></a><font size="1" >click
        to save changes </font><a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1" >click to cancel or go previous </font>
        <%}%>
      </td>
    </tr>
    <%}//if iAccessLevel > 1
if(strErrMsg != null)
{%>
    <tr>
      <td width="3%">&nbsp;</td>
      <td colspan="4"><b><font  size="3"><%=strErrMsg%></font></b></td>
    </tr>
    <%}//this shows the edit/add/delete success info%>
  </table>
<table width="100%" bgcolor="#FFFFFF">
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center">LIST OF EXISTING DEPARTMENTS</div></td>
    </tr>


  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="13%"><div align="center"><font size="1" ><b>DEPT CODE</b></font></div></td>
      <td width="37%" height="25"><div align="center"><font size="1" ><b>DEPARTMENT
          NAME </b></font></div></td>
      <td width="6%" align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>
    <tr>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center">
        <%if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
        <%}else{%>
        Not authorized
        <%}%>
      </td>
      <td align="center">
        <%if(iAccessLevel > 1){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        Not authorized
        <%}%>
      </td>
    </tr>
    <% i = i+2;
	}//end of displaying levels
}//end of displaying existing question level
%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="8"><div align="center"></div></td>
    </tr>
    <tr >
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
<input type="hidden" name="page_action" value="">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="parentURL" value="<%=WI.fillTextValue("parentURL")%>">

</form>
</body>
</html>
<%dbOP.cleanUP();%>