<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.fa_reserve.submit();
}
function ChangeDormLoc()
{
	document.fa_reserve.changeDormLoc.value="1";
	ReloadPage();
}
function AddRecord()
{
	document.fa_reserve.addRecord.value="1";
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.Authentication,enrollment.HostelManagement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	MessageConstant mConst = new MessageConstant();

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strCurSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	String strCurSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	boolean bolProceed = true;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

	if(strCurSYFrom == null || strCurSYTo == null)
	{
		bolProceed = false;
		strErrMsg = "You are logged out. Please login again.";
	}
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Hostel Management-OCCUPANCY MAINTENANCE- Reservation","reservation.jsp");
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
														"Hostel Management","OCCUPANCY MAINTENANCE",request.getRemoteAddr(),
														"reservation.jsp");
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

Vector vBasicInfo = null;
boolean bolIsStaff = false; //true only if the payee type is internal and not a student type.

FAPaymentUtil paymentUtil = new FAPaymentUtil();
HostelManagement HM = new HostelManagement();

if(WI.fillTextValue("addRecord").compareTo("1") ==0)
{
	if(!HM.reserveARoom(dbOP,request,false))
		strErrMsg = HM.getErrMsg();
	else
	{
		dbOP.cleanUP();
		%>
		<jsp:forward page="./reservation_print.jsp?view=1" />
	<%}
}
if(WI.fillTextValue("stud_id").length() > 0 && bolProceed)
{
	vBasicInfo = paymentUtil.getStudBasicInfo(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
	{
		strErrMsg = paymentUtil.getErrMsg();
		bolIsStaff = true;
		request.setAttribute("emp_id",request.getParameter("stud_id"));
		vBasicInfo = new Authentication().operateOnBasicInfo(dbOP, request,"0");
	}
	//check if the applicant is having reservation already, if so - take directly to the print page,
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{
		Vector vReservationInfo = HM.viewReservationInfo(dbOP, (String)vBasicInfo.elementAt(0));
		if(vReservationInfo != null)
		{
			dbOP.cleanUP();
			%>
			<jsp:forward page="./reservation_print.jsp?view=1&msg=Room%20already%20reserved.%20Please%20print%20slip." />
		<%}
	}
}

if(strErrMsg == null) strErrMsg = "";
%>
<form name="fa_reserve" action="./reservation.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          OCCUPANCY MAINTENANCE - RESERVATION PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="13%">ID Number</td>
      <td width="21%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> </td>
      <td width="62%"><input type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
  </table>
 <%
 if(vBasicInfo != null && vBasicInfo.size() > 0){%>
 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="2"><hr  size="1"></td>
    </tr>
    <tr>
      <td  width="4%"height="25">&nbsp;</td>
      <td width="96%">Account type :<strong>
	  <%
	  if(bolIsStaff){%>
        Employee
        <%}else{%>
        Student
        <%}%>
		</strong></td>
    </tr>
  </table>
  <%if(!bolIsStaff && vBasicInfo != null && vBasicInfo.size()> 0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="42%">Account name : <strong><%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td width="54%">Year/Term : <strong><%=(String)vBasicInfo.elementAt(4)%>/
        <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="2">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
        <%
	  if(vBasicInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
        <%}%>
        </strong></td>
    </tr>
  </table>
<%}else if( vBasicInfo != null && vBasicInfo.size()> 0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td>Account name : <strong><%=WI.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),1)%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%">Employee type :<strong> <%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Employee status : <strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">College/Department/Office : <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/<%=(String)vBasicInfo.elementAt(14)%></strong></td>
    </tr>
</table>
<%}%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td><hr size="1"></td>
  </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="2">Particular (Location/Name : Room/House No.) :
        <select name="location" onChange="ChangeDormLoc();">
          <option value="0">Select a location</option>
          <%
strTemp2 = WI.fillTextValue("location");
strTemp = " from FA_STUD_SCHFAC_DORM_LOC where is_del=0 order by LOCATION asc";
%>
          <%=dbOP.loadCombo("LOCATION_INDEX","LOCATION",strTemp, strTemp2, false)%>
        </select>
        <%//display only if a location is selected.
if(strTemp2.length()> 0 && strTemp2.compareTo("0") != 0){%>
        <select name="dorm_room" onChange="ReloadPage();">
          <option value="0">Select a room</option>
          <%
//very tricky here, show all available rooms and the room reserved by the user. Do not show all the rooms.

strTemp = " from FA_STUD_SCHFAC_DORM_LAYOUT where LOCATION_INDEX="+strTemp2+
				" and is_del=0 and is_valid=1 and room_status = 0 order by room_no asc";

strTemp2 = WI.fillTextValue("dorm_room");
%>
          <%=dbOP.loadCombo("DORMITORY_INDEX","ROOM_NO",strTemp, strTemp2, false)%>
        </select>
      </td>
    </tr>
        <%}
if(strTemp2.length() > 0 && strTemp2.compareTo("0") != 0 && (WI.fillTextValue("changeDormLoc").length() ==0 || WI.fillTextValue("changeDormLoc").compareTo("0") ==0))
{
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="28%" height="25">
        Rental : <%=dbOP.mapOneToOther("FA_STUD_SCHFAC_DORM_LAYOUT","DORMITORY_INDEX",strTemp2,"rental",null)%>
      </td>
      <td width="68%">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Min amount to deposit : Php
        <input name="amount" type="text" size="6" value="<%=WI.fillTextValue("amount")%>" maxlength="6" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Start Date of Occupancy : <font size="1">
        <input name="date_of_occupancy" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_of_occupancy")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('fa_reserve.date_of_occupancy');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
<%if(iAccessLevel > 1){%>
	  <input type="image" src="../../../images/save.gif" onClick="AddRecord();"><font size="1">click
        to confirm reservation <a href="reservation.jsp"><img src="../../../images/cancel.gif" border="0"></a>click
        to cancel entries/reservation</font>
<%}else{%>Not authorized to save<%}%>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
 <%}//if vBasic info is not null
 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
 <input type="hidden" name="changeDormLoc" value="0">
<input type="hidden" name="addRecord" value="0">
<%
if(vBasicInfo != null){%>
<input type="hidden" name="user_index" value="<%=(String)vBasicInfo.elementAt(0)%>">
<%}%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
