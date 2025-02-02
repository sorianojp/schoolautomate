<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function ChangeType()
{
	if (document.form_.isMem.checked)
		hideLayer('pos_or');
	else
		showLayer('pos_or');
}
function CloseWindow()
{
	window.opener.document.form_.submit()
	window.opener.focus();
	self.close();
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.pos_name.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
    document.form_.page_action.value="";
	this.SubmitOnce('form_');
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-PROGRAM OF ACTIVTIES","prog_obj_update.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","PROGRAM OF ACTIVTIES",request.getRemoteAddr(),
														"prog_obj_update.jsp");
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
Vector vRetResult = new Vector();
Vector vEditInfo = null;
Organization organization = new Organization();

strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
strTemp = WI.fillTextValue("page_action");

if(strTemp.length() > 0){
	if(organization.operateOnPositions(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg =organization.getErrMsg();
	else
	{
		strErrMsg = "Operation is successful.";
		strPrepareToEdit = "0";
	}
}
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = organization.operateOnPositions(dbOP, request, 3);

	if(vEditInfo == null && strErrMsg == null )
			strErrMsg = organization.getErrMsg();
	}

//I have to get here all information.
vRetResult = organization.operateOnPositions(dbOP, request, 4);
%>
<form action="./org_position_update.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          ORGANIZATION - POSITIONS LIST ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="5%" height="25">&nbsp;</td>
      <td width="95%"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0"></a></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="5%">&nbsp;</td>
      <td width="15%">Position Name:</td>
      <td valign="top" width="80%">
      <%
      if (vEditInfo!=null && vEditInfo.size()>0)
      strTemp = (String)vEditInfo.elementAt(1);
      else
      strTemp = WI.fillTextValue("pos_name");%>
      <input name="pos_name" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>" size="25">
     &nbsp;
     <%
	if (vEditInfo!=null && vEditInfo.size()>0)
      strTemp = WI.getStrValue((String)vEditInfo.elementAt(3));
    else
      strTemp = WI.fillTextValue("isMem");

     if (strTemp.equals("1"))
	   	 strTemp = "checked";
       else
	     strTemp = "";
%>
     <input type="checkbox" value="1" name="isMem" <%=strTemp%> onClick="javascript:ChangeType()"><font size="1">click to indicate member position</font>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Position Order:</td>
      <td valign="top">
      <%
      if (vEditInfo!=null && vEditInfo.size()>0)
	      strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
      else
    	  strTemp = WI.fillTextValue("pos_order"); %> 
	 <input name="pos_order" type="text"  class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
        onKeyUp= 'AllowOnlyInteger("form_","pos_order")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","pos_order");style.backgroundColor="white"' >
      </td>
    </tr>
  </table>



  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="21%" height="25">&nbsp;</td>
      <td width="79%" height="25"><font size="1">
      <%if(strPrepareToEdit.compareTo("1") != 0) {%> 
      <a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border="0" name="hide_save"></a> Add position &nbsp;
        <%}else{%> 
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a>Edit Position <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
        Cancel operation
        <%}%>
        </font>      </td>
    </tr>
  </table>
<%if (vRetResult!=null && vRetResult.size()>0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  	<tr>
      <td height="25" colspan="5" bgcolor="#B9B292" align="center" class="thinborder"><font color="#FFFFFF"><strong>LIST
          OF AVAILABLE POSITIONS</strong></font></td>
    </tr>
    <tr>
    	<td width="16%" align="center" class="thinborder" height="25"><font size="1"><strong>ORDER</strong></font></td>
    	<td width="50%" align="center" class="thinborder"><font size="1"><strong>POSITION NAME</strong></font></td>
	    <td width="17%" align="center" class="thinborder">&nbsp;</td>
    	<td width="17%" align="center" class="thinborder">&nbsp;</td>
    </tr>
    <%for (int i = 0; i < vRetResult.size(); i+=4){%>
	<tr>
		<td align="center" class="thinborder"><strong><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></strong></td>
		<td align="center" class="thinborder"><strong><%=(String)vRetResult.elementAt(i+1)%></strong></td>
		<td align="center" class="thinborder"> <font size="1">
        <%  if(iAccessLevel ==2 || iAccessLevel == 3){  %>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0" ></a>
        <%}else{%>&nbsp;<%}%></font></td>
      <td align="center" class="thinborder"> <font size="1">
        <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0" ></a>
        <%}else{%>&nbsp;<%}%></font></td>
	</tr>
	<%}%>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
