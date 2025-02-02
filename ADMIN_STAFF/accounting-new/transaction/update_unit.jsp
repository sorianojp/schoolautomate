<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Unit</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction)
{	
	document.uunit.page_action.value = strAction;
}
function PrepareToEdit(strInfoIndex)
{
	document.uunit.page_action.value =""; 
	document.uunit.prepareToEdit.value = 1;
	document.uunit.info_index.value = strInfoIndex;
	document.uunit.submit();	
}

function DeleteRecord(strInfoIndex)
{	
	document.uunit.page_action.value="0";
	document.uunit.info_index.value=strInfoIndex;
	document.uunit.submit();
}
function CancelRecord()
{
	location = "./update_unit.jsp";
}
function CloseWindow()
{
	eval('window.opener.document.'+document.uunit.parentFormName.value+'.submit()');
	window.opener.focus();
	self.close();
}


</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.Requisition,java.util.Vector " %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-TRANSACTION","update_unit.jsp");
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
														"Accounting","TRANSACTION",request.getRemoteAddr(),
														"update_unit.jsp");
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
	
Requisition requisition = new Requisition();
Vector vRetResult = new Vector();
Vector vEditInfo  = new Vector();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	vRetResult = requisition.OperateOnUnit(dbOP,request,Integer.parseInt(strTemp));
	if(vRetResult != null)
		strPrepareToEdit = "0";
	strErrMsg = requisition.getErrMsg();
}

//get all levels created.
vRetResult =	requisition.OperateOnUnit(dbOP,request,4);
if((vRetResult == null || vRetResult.size() ==0) && WI.fillTextValue("info_index").length() > 0 && strErrMsg == null)
	strErrMsg = requisition.getErrMsg();

if(strPrepareToEdit != null && strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = requisition.OperateOnUnit(dbOP,request,3);
	if(vEditInfo == null)
		strErrMsg = requisition.getErrMsg();
}
dbOP.cleanUP();

if(strErrMsg == null) strErrMsg = "";
%>


<form name="uunit" method="post" action="./update_unit.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="8"><div align="center"><font color="#FFFFFF"><strong>:::: 
          UNIT MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td colspan="8" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=strErrMsg%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3" height="25"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a> 
        <font size="1"><strong>Click to close window</strong></font></td>
      <td width="28%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="16%">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="3" height="25">Unit 
        <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = WI.fillTextValue("unit");
	%>
        <input name="unit" type="text" size="16" value="<%=strTemp%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      </td>
      <td colspan="4"> 
        <%
	if(strPrepareToEdit.compareTo("0") == 0 && iAccessLevel > 1)
	{%>
        <input type="image" src="../../../images/add.gif" onClick="PageAction(1);"><font size="1" >click 
        to save entry</font>  
        <%}else{%>
        <input type="image" src="../../../images/edit.gif" onClick="PageAction(2);"><font size="1">click 
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
        to cancel edit</font> 
        <%}%>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
      <td height="25" colspan="3">&nbsp; </td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border=0 bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="8"><div align="center">LIST OF EXISTING UNIT</div></td>
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
      <td width="27%">&nbsp;</td>
      <td width="36%"><strong><%=(String)vRetResult.elementAt(i+1)%></strong></td>
      <td width="10%" height="25">
<%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}%>	  </td>
      <td width="27%">
<%if(iAccessLevel ==2){%>
  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
<%}else{%>Not authorized to delete<%}%>  </td>
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
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">  
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="parentFormName" value="<%=WI.fillTextValue("parentFormName")%>">
</form>
</body>
</html>
