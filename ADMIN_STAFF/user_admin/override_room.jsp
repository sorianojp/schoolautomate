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
	var tot_cap = 0;
	if(document.op_room.new_reg_cap.value.length > 0 || document.op_room.new_ireg_cap.value.length > 0)
		tot_cap = Number(document.op_room.new_reg_cap.value) + Number(document.op_room.new_ireg_cap.value);
	else
		tot_cap = Number(document.op_room.new_total_cap.value);

	if(isNaN(tot_cap))
	{
		alert("Please enter a valid room capacity");
		return;
	}
	document.op_room.new_total_cap.value = tot_cap;
	document.op_room.addRecord.value="1";
	document.op_room.submit();

}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.OverideParameter,enrollment.EnrollmentRoomMonitor,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","override_room.jsp");

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
														"override_room.jsp");
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
Vector vRoomDetail = null;
if(WI.fillTextValue("addRecord").compareTo("1") ==0)
{
	if(OP.changeRoomCapacity(dbOP,request))
		strErrMsg = "Room capacity changed successfully.";
	else
		strErrMsg = OP.getErrMsg();
}

//get here room detail.
if(WI.fillTextValue("room_index").length() > 0 && WI.fillTextValue("room_index").compareTo("0") != 0)
{
	EnrollmentRoomMonitor ERM = new EnrollmentRoomMonitor();
	vRoomDetail = ERM.viewOneRoom(dbOP,request.getParameter("room_index"));
	if(vRoomDetail == null)
		strErrMsg = ERM.getErrMsg();
}
if(strErrMsg == null) strErrMsg = "";
%>


<form name="op_room" action="./override_room.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          OVERRIDE ROOM CAPACITY PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=strErrMsg%></b></font> </td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="27%" height="25">School Offering Year/Term</td>
      <td width="31%">
<%
if(WI.fillTextValue("addRecord").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else
	strTemp = WI.fillTextValue("offering_yr_from");
%>
		  <input name="offering_yr_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        to
<%
if(WI.fillTextValue("addRecord").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
else
	strTemp = WI.fillTextValue("offering_yr_to");
%>        <input name="offering_yr_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="offering_sem">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("offering_sem");
if(strTemp == null) strTemp = "";

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td width="40%"><input type="image" src="../../images/form_proceed.gif"></td>
    </tr>
  </table>
<%
if(WI.fillTextValue("offering_yr_from").length() > 0 && WI.fillTextValue("offering_yr_to").length()>0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="23%">Select a Room number</td>
      <td width="75%">

        <select name="room_index" onChange="ReloadPage();">
<option value="0">Select a room</option>
<%
strTemp = " from e_room_detail join e_room_assign on (e_room_detail.room_index=e_room_assign.room_index) "+
			"join e_sub_section on (e_room_assign.sub_sec_index=e_sub_section.sub_sec_index) where e_sub_section.is_valid=1 and "+
			"e_sub_section.is_del=0 and e_room_assign.is_valid=1 and e_room_assign.is_del=0 and e_sub_section.offering_sy_from="+
			request.getParameter("offering_yr_from")+" and e_sub_section.offering_sy_to="+request.getParameter("offering_yr_to")+
			" and e_sub_section.offering_sem="+request.getParameter("offering_sem")+" order by room_number asc";
%>
<%=dbOP.loadCombo("distinct e_room_detail.room_index","room_number",strTemp,request.getParameter("room_index"), false)%> </select>
				</td>
    </tr>
  </table>
<%
if(vRoomDetail != null && vRoomDetail.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="33%">Room # : <strong><%=(String)vRoomDetail.elementAt(0)%></strong></td>
      <td width="33%">Type : <strong><%=(String)vRoomDetail.elementAt(1)%></strong></td>
      <td width="32%">Location : <strong><%=(String)vRoomDetail.elementAt(5)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Reg. Students : <strong><%=(String)vRoomDetail.elementAt(2)%> </strong></td>
      <td>Irreg. Students : <strong><%=(String)vRoomDetail.elementAt(3)%></strong>
      </td>
      <td>Total Capacity: <strong><%=(String)vRoomDetail.elementAt(4)%> </strong></td>
    </tr>
  </table>
<input type="hidden" name="old_reg_cap" value="<%=(String)vRoomDetail.elementAt(2)%>">
<input type="hidden" name="old_ireg_cap" value="<%=(String)vRoomDetail.elementAt(3)%>">
<input type="hidden" name="old_total_cap" value="<%=(String)vRoomDetail.elementAt(4)%>">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="2"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><u>New Room Capacity</u></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="22%">Reg. Students
        <input name="new_reg_cap" type="text" size="3" value="<%=WI.fillTextValue("new_reg_cap")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="24%">Irreg. Students
        <input name="new_ireg_cap" type="text" size="3" value="<%=WI.fillTextValue("new_ireg_cap")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="52%">Total Capacity
        <input name="new_total_cap" type="text" size="3" value="<%=WI.fillTextValue("new_total_cap")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> &lt;<font size="1">fill
        this is if other two options are N/A&gt;</font></td>
    </tr>
    <tr>
      <td  colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="" valign="bottom">Approval No.</td>
      <td valign="bottom">Approved By </td>
      <td valign="bottom">Approval Date (<font size="1">mm/dd/yyyy)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="">
<input name="apv_no" type="text" size="16" value="<%=WI.fillTextValue("apv_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>
        <input type="text" name="apv_by" value="<%=WI.fillTextValue("apv_by")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><input name="apv_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("apv_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('op_room.apv_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>
        &nbsp; </td>
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
<%	}//only if vRoomDetail > null
}//only if offering syfrom/to is entered.
%>
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
