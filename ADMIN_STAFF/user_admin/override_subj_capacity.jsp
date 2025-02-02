<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.op_room.submit();
}
function AddRecord()
{
	document.op_room.addRecord.value="1";
	document.op_room.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.OverideParameter,enrollment.CurriculumSM,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","override_subj_capacity.jsp");

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
														"System Administration","Override Parameters",request.getRemoteAddr(),
														"override_subj_capacity.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

OverideParameter OP = new OverideParameter();
Vector vSubDetail = null;
if(WI.fillTextValue("addRecord").compareTo("1") ==0)
{
	if(OP.changeSubjectMinCapacity(dbOP,request))
		strErrMsg = "Subject minimum capacity changed successfully.";
	else
		strErrMsg = OP.getErrMsg();
}

//get here subject detail.
if(WI.fillTextValue("sub_index").length() > 0 && WI.fillTextValue("sub_index").compareTo("0") != 0)
{
	CurriculumSM SM = new CurriculumSM();
	vSubDetail = SM.view(dbOP,request.getParameter("sub_index"));
	if(vSubDetail == null)
		strErrMsg = SM.getErrMsg();
}
if(strErrMsg == null) strErrMsg = "";
%>


<form name="op_room" action="./override_subj_capacity.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          OVERRIDE MINIMUM SUBJECT CAPACITY PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="2"><font size="3"><b><%=strErrMsg%></b></font> </td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="23%">Select a Subject</td>
      <td width="75%"> <select name="sub_index" onChange="ReloadPage();">
          <option value="0">Select a subject</option>
          <%=dbOP.loadCombo("sub_index","sub_code"," from subject where is_del=0 order by sub_code asc",request.getParameter("sub_index"), false)%>
        </select> </select></td>
    </tr>
    <tr>
      <td  colspan="3" height="25"><hr size="1"></td>
    </tr>
  </table>

<%
if(vSubDetail != null && vSubDetail.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="41%">Subject Code: <strong><%=(String)vSubDetail.elementAt(2)%></strong></td>
      <td width="57%">Subject Desciption : <strong><%=(String)vSubDetail.elementAt(3)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Subject Caegory : <strong><%=(String)vSubDetail.elementAt(5)%> </strong></td>
      <td>Min. no. of students required to enroll: <strong><%=(String)vSubDetail.elementAt(4)%></strong>
      </td>
    </tr>
<input type="hidden" name="old_min_cap" value="<%=(String)vSubDetail.elementAt(4)%>">
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="2"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><u>New Minimum Subject Capacity </u> - >
	  <input name="new_min_cap" type="text" size="3" value="<%=WI.fillTextValue("new_min_cap")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="22%" colspan="" valign="bottom">Approval No.</td>
      <td width="24%" valign="bottom">Approved By </td>
      <td width="52%" valign="bottom">Approval Date (<font size="1">mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan=""> <input name="apv_no" type="text" size="16" value="<%=WI.fillTextValue("apv_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td> <input type="text" name="apv_by" value="<%=WI.fillTextValue("apv_by")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td><input name="apv_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("apv_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('op_room.apv_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
 <%
if( iAccessLevel >1){%>
   <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:AddRecord();"><img src="../../images/save.gif" border="0"></a><font size="1">click
        to save changes</font> </td>
    </tr>
<%}%>
  </table>
<%
}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>

 <input type="hidden" name="addRecord" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

