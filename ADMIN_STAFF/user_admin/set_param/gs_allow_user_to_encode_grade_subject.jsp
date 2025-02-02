<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.messageBox {
	height: 100px; width:170px; overflow: auto; border: inset black 1px; background-color:#DDDDDD
}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strAction, strIndex)
{
	document.set_param.info_index.value = strIndex;
	document.set_param.page_action.value = strAction;
//	alert(document.set_param.info_index.value);
}

function ReloadPage()
{
	document.set_param.page_action.value = "";
	document.set_param.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameter","set_param_gs.jsp");

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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														"set_param_gs.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
SetParameter paramGS = new SetParameter();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)//add/ delete.
{
	if(paramGS.operateOnAllowOtherUserToEncodeSubject(dbOP,request,Integer.parseInt(strTemp)) != null)
		strErrMsg = "Operation Successful.";
	else
		strErrMsg = paramGS.getErrMsg();
}
vRetResult = paramGS.operateOnAllowOtherUserToEncodeSubject(dbOP,request,4);
if(vRetResult == null)
{
	if(strErrMsg == null)
		strErrMsg = paramGS.getErrMsg();
}

String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("allow_user"));

%>
<form name="set_param" action="./gs_allow_user_to_encode_grade_subject.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          SET PARAMETERS - GRADE SHEET RESTRICTED SUBJECT LIST ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font>      </td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="7%">Allow User </td>
      <td width="91%" style="font-size:14px; font-weight:bold"><%=WI.fillTextValue("allow_user")%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SUBJECT</td>
      <td>
	  	<select name="subject">
          <%=dbOP.loadCombo("sub_index","sub_code, sub_name"," from subject where IS_DEL=0 and not exists "+
		  					"(select * from GRADE_ENCODE_INCHARGE_SUBJECT where AUTHORIZED_USER="+strEmployeeIndex+" and SUB_INDEX = subject.sub_index) order by sub_code",WI.fillTextValue("subject"), false)%>
		</select>	  </td>
    </tr>
    <%
if( iAccessLevel >1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="image" src="../../../images/save.gif" onClick='PageAction(1,"");'>
        <font size="1">click to save new grade sheet submission time</font></td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr bgcolor="#B9B292">
      <td height="25" div align="center" style="font-weight:bold; color:#FFFFFF">LIST OF AUTHORIZED USERS TO ENCODE OTHER FACULTIES GRADE</div></td>
    </tr>
</table>


  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold" align="center">
      <td width="30%" height="25" class="thinborder"><font size="1">Subject Code </font></td>
      <td width="60%" class="thinborder"><font size="1">Subject name</font></td>
      <td width="10%" class="thinborder"><font size="1">Delete</font></td>
    </tr>
    <%
for(int i =0;i< vRetResult.size(); i +=5){ %>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder" align="center">
        <%
	if( iAccessLevel >1){%>
        <input type="image" onClick='PageAction(0,<%=(String)vRetResult.elementAt(i)%>);' src="../../../images/delete.gif">
        <%}else{%>
        Not Allowed to delete
        <%}%>      </td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="allow_user" value="<%=WI.fillTextValue("allow_user")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
