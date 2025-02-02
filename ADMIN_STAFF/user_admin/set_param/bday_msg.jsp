<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
<%
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
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
	this.SubmitOnce('form_');
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	
	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	String [] astrTarget = {"Employee", "Student"};
	String strMyMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administration-Set Parameters-Birthday Message","bday_msg.jsp");
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
														"System Administration","Set parameters",request.getRemoteAddr(),
														"bday_msg.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	MessageSystem msgSys = new MessageSystem();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(msgSys.operateOnBirthDayMsg(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = msgSys.getErrMsg();
	}
	
		
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = msgSys.operateOnBirthDayMsg(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = msgSys.getErrMsg();
	}
	//view all 
	
	vRetResult = msgSys.operateOnBirthDayMsg(dbOP, request, 4);
	if (strErrMsg==null)
		strErrMsg=msgSys.getErrMsg();
	
%>


<body bgcolor="#D2AE72">
<form name="form_" action="./bday_msg.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          BIRTHDAY MESSAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>Message</td>
  	<%if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(0);
	else	
		strTemp = WI.fillTextValue("bday_msg");
	%>
      <td height="25" colspan="2" valign="middle">
     <textarea name="bday_msg" cols="50" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
<%if(bolIsSchool){%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Target</td>
      <td height="25" colspan="2" valign="middle"><font size="1">
      <%
      String strTarget = null;
      if(vEditInfo != null && vEditInfo.size() > 0)
		strTarget = (String)vEditInfo.elementAt(1);
		else	
		strTarget = WI.fillTextValue("msg_target");
	
      if(strTarget.compareTo("0") == 0)
			strTemp = "checked";
		else
			strTemp = "";
		%> 
      <input name="msg_target" type="radio" value="0" <%=strTemp%>>Employee
      &nbsp;
      <%
       if(strTemp.length() == 0)
			strTemp = "checked";
		else
			strTemp = "";
		%> 
      <input name="msg_target" type="radio" value="1" <%=strTemp%>>Student</font>
      </td>
    </tr>
<%}else{%>
	<input type="hidden" name="msg_target" value="0">
<%}%>
    <tr> 
      <td height="15" colspan="4"><font size="1">&nbsp; </font><font size="1">&nbsp; 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border="0" name="hide_save"></a> Click to add entry
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> Click to edit event
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> Click to clear entries </font>
        <%}%>
        </td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="23" colspan="6" class="thinborder"> <div align="center"> <strong><font size="2">BIRTHDAY MESSAGES</font></strong></div></td>
    </tr>
    <tr> 
      <td width="15%" height="23" class="thinborder"> <div align="center"><font size="1"><strong>TARGET</strong></font></div></td>
      <td width="65%" class="thinborder"> <div align="center"><font size="1"><strong>MESSAGE</strong></font></div></td>
      <td colspan="2" align="center" class="thinborder" width="20%"> <font size="1"><strong>&nbsp; 
        OPTIONS</strong> </font> <div align="center"></div></td>
    </tr>
    <%
    for (int i = 0; i<vRetResult.size(); i+=2) { %>
    <tr> 
      <td class="thinborder" height="25"><%=astrTarget[Integer.parseInt((String)vRetResult.elementAt(i+1))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td width="7%" class="thinborder"> <font size="1"> 
        <% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i+1)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized to edit 
        <%}%>
        </font></td>
      <td width="10%" class="thinborder"><font size="1"> 
        <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i+1)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized to delete 
        <%}%>
        </font></td>
    </tr>
    <%}%>
  </table>
    <%}%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
