<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=op_room.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.op_room.submit();
}
function AddRecord()
{
	document.op_room.addRecord.value="1";
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.OverideParameter,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String[] astrConvertSem ={"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","override_student_load.jsp");

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
														"override_student_load.jsp");
//IF NOT ALLOWED, CHECK IF ALLOWED FOR OVERRIDE PARAMETER -> STUDENT LOAD
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Override Parameters","Student Load",
														request.getRemoteAddr(),
														"override_student_load.jsp");

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
Vector vStudDetail = null;
if(WI.fillTextValue("addRecord").compareTo("1") ==0 && WI.fillTextValue("offering_yr_from").length() > 0)
{
	if(OP.changeStudMaxLoad(dbOP,request))
		strErrMsg = "Students maximum load is changed successfully to "+request.getParameter("new_max_load");
	else
		strErrMsg = OP.getErrMsg();
}

//get here subject detail.
if(WI.fillTextValue("stud_id").length() > 0  && WI.fillTextValue("offering_yr_from").length() > 0)
{
	vStudDetail = OP.getStudentLoadInfo(dbOP,request.getParameter("stud_id"),WI.fillTextValue("offering_yr_from"),
									WI.fillTextValue("offering_yr_to"),WI.fillTextValue("offering_sem"));
	if(vStudDetail == null)
		strErrMsg = OP.getErrMsg();
}
dbOP.cleanUP();

if(strErrMsg == null) strErrMsg = "";
%>


<form name="op_room" action="./override_student_load.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          OVERRIDE STUDENT LOAD PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="28" width="1%">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=strErrMsg%></b></font> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School Year : </td>
      <td colspan="3">
        <%
strTemp = WI.fillTextValue("offering_yr_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="offering_yr_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp=" DisplaySYTo('op_room','offering_yr_from','offering_yr_to')">
        -
        <%
strTemp = WI.fillTextValue("offering_yr_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="offering_yr_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" readonly>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="offering_sem">
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25" width="1%">&nbsp;</td>
      <td width="15%">Student ID</td>
      <td width="22%"> </select> <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="8%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a></td>
      <td width="54%"><input type="image" src="../../images/form_proceed.gif"></td>
    </tr>
    <tr >
      <td  colspan="5" ><hr size="1"></td>
    </tr>
  </table>

 <%
 if(vStudDetail != null && vStudDetail.size() > 0){%>
<input type="hidden" name="year_level" value="<%=(String)vStudDetail.elementAt(4)%>">
<input type="hidden" name="user_index" value="<%=(String)vStudDetail.elementAt(0)%>">
 <input type="hidden" name="max_load" value="<%=(String)vStudDetail.elementAt(5)%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
      <td width="98%">Student name : <strong><%=(String)vStudDetail.elementAt(1)%></strong></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td>Course/Major :<strong> <%=(String)vStudDetail.elementAt(2)%>
        <%
	  if(vStudDetail.elementAt(3) != null){%>
        / <%=(String)vStudDetail.elementAt(3)%>
        <%}%>
        </strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Enrolling YR : <strong><%=(String)vStudDetail.elementAt(4)%>
        <%
	  if( ((String)vStudDetail.elementAt(8)).length() > 0){%>
        (<%=(String)vStudDetail.elementAt(8)%>)
        <%}%>
        </strong> </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Status:<strong> <%=(String)vStudDetail.elementAt(7)%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Total maximum units allowed in this term: <strong><%=(String)vStudDetail.elementAt(5)%></strong></td>
    </tr>
<%
if( vStudDetail.elementAt(6) != null){%>
   <tr >
      <td height="25">&nbsp;</td>
      <td height="25"><strong><font color="#0000FF">Overloaded maximum allowed
        unit in this term : <%=(String)vStudDetail.elementAt(6)%></font></strong></td>
    </tr>
<%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><u>New total maximum units allowed in this term</u> - >
        <input name="new_max_load" type="text" size="3" value="<%=WI.fillTextValue("new_max_load")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td  colspan="4"><hr size="1"></td>
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
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td> <input type="text" name="apv_by" value="<%=WI.fillTextValue("apv_by")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>
<%
strTemp = WI.fillTextValue("apv_date");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>
	  <input name="apv_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('op_room.apv_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a></td>
    </tr>
<%
if( iAccessLevel >1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input type="image" src="../../images/overload.gif" onClick="AddRecord();">
        <font size="1">click to overload the student</font></td>
    </tr>
<%}%>
  </table>
 <%}//only if student id is not null
 %>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="addRecord">
</form>
</body>
</html>

