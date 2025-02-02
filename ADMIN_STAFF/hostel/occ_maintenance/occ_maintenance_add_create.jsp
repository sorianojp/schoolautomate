<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.fa_account.submit();
}
function ChangeDormLoc()
{
	document.fa_account.changeDormLoc.value="1";
	ReloadPage();
}
function AddRecord()
{
	document.fa_account.addRecord.value="1";
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.Authentication,enrollment.FASchoolFacility,enrollment.HostelManagement,java.util.Vector" %>
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
								"Admin/Hostel Management-OCCUPANCY MAINTENANCE- Add/Create occupancy","occ_maintenance_add_create.jsp");
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
														"occ_maintenance_add_create.jsp");
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
Vector vAccountInfo = null;
Vector vReservationInfo = null;
Vector vRoomInfo = null;
boolean bolIsStaff = false; //true only if the payee type is internal and not a student type.

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
FASchoolFacility schFacility = new FASchoolFacility();
HostelManagement HM = new HostelManagement();

if(WI.fillTextValue("addRecord").compareTo("1") ==0)
{
	if(!HM.confirmRoomAllotment(dbOP,null,request))
		strErrMsg = HM.getErrMsg();
	else
	{
		strErrMsg = "Room alloted successfully.";
		bolProceed = false;
	}
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
	//get account detail.
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{
		vAccountInfo = schFacility.viewOneAccountDetail(dbOP,(String)vBasicInfo.elementAt(0),request.getParameter("fee_name"));
		if(vAccountInfo == null)
			strErrMsg = schFacility.getErrMsg();
	}
}

if(strErrMsg == null) strErrMsg = "";
%>
<form name="fa_account" action="./occ_maintenance_add_create.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          OCCUPANCY MAINTENANCE - ADD/CREATE ACCOUNTS PAGE ::::<br>
          </strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><a href="fm_schl_fees_account_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
	<%
	if(!bolProceed){
	dbOP.cleanUP();return;
	}%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="33%">Fee name :
        <select name="fee_name" onChange="ReloadPage();">
          <option value="0">Select a fee</option>
          <%
strTemp = " from FA_SCH_FACILITY join FA_SCHYR on (FA_SCH_FACILITY.sy_index=FA_SCHYR.sy_index) "+
				"where is_del=0 and is_valid=1 and sy_from="+strCurSYFrom+" and sy_to="+strCurSYTo+" and facility_type=1 order by fee_name,facility_type asc";
%>
          <%=dbOP.loadCombo("SCH_FAC_FEE_INDEX","FEE_NAME",strTemp, WI.fillTextValue("fee_name"), false)%>
        </select></td>
      <td width="63%">School Year<strong> : <%=strCurSYFrom%> - <%=strCurSYTo%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
	  <td>Select the Occupant status:</td>
	  <td><select name="occupant_status" onChange="ReloadPage();">
          <option value="0">Occupying partially(sharing the room)</option>
<%
strTemp = WI.fillTextValue("occupant_status");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Occupying complete room(not sharing room)</option>
<%}else{%>
          <option value="1">Occupying complete room(not sharing room)</option>
<%}%>
        </select></td>
    </tr>
	<tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="9%">Enter ID </td>
      <td width="25%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="62%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>

<%
 if(vBasicInfo != null && vBasicInfo.size() > 0){%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
      <td height="25" colspan="2"><hr size="1"></td>
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
<%}
if(!bolIsStaff && vBasicInfo != null && vBasicInfo.size()> 0){%>

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
<%}
if(vAccountInfo != null && vAccountInfo.size() > 0){
%>
<input type="hidden" name="acc_info_reference" value="<%=(String)vAccountInfo.elementAt(4)%>">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="2"><hr size="1"></td>
    </tr>
  </table>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
vReservationInfo = HM.viewReservationInfo(dbOP, (String)vBasicInfo.elementAt(0));
if(vReservationInfo == null){%>
    <tr>
      <td width="4%"></td>
      <td><strong><%=HM.getErrMsg()%></strong></td>
    </tr>
    <%}%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%">Particular (Room/Door) :
        <select name="location" onChange="ChangeDormLoc();">
          <option value="0">Select a location</option>
          <%
if(WI.fillTextValue("reloadPage").length() ==0 && vReservationInfo != null)
	strTemp2 = (String)vReservationInfo.elementAt(2);
else
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
//if the occupant want to occupy complete room - show only the open room, if occupant wants to occupy partially - show all the
//vacant and partially occupied rooms.
if(WI.fillTextValue("occupant_status").compareTo("0") ==0) //partial
	strTemp = " (room_status = 0 or room_status = 3)";
else
	strTemp = " room_status=0";


strTemp = " from FA_STUD_SCHFAC_DORM_LAYOUT where (LOCATION_INDEX="+strTemp2+
	" and is_del=0 and is_valid=1 and"+strTemp+" ) or (dormitory_index in (select dormitory_index from FA_STUD_SCHFAC_DRESERVE "+
	"where user_index="+(String)vBasicInfo.elementAt(0)+" and is_valid=1 and is_del=0 and  is_confirmed=0))  order by room_no asc";
//System.out.println(strTemp);
if(WI.fillTextValue("reloadPage").length() ==0 && vReservationInfo != null)
	strTemp2 = (String)vReservationInfo.elementAt(4);
else
	strTemp2 = WI.fillTextValue("dorm_room");
%>
          <%=dbOP.loadCombo("DORMITORY_INDEX","ROOM_NO",strTemp, strTemp2, false)%>
        </select>
        <%}
if(strTemp2.length() > 0 && strTemp2.compareTo("0") != 0 && (WI.fillTextValue("changeDormLoc").length() ==0 || WI.fillTextValue("changeDormLoc").compareTo("0") ==0)){
%>
        Rental : <%=dbOP.mapOneToOther("FA_STUD_SCHFAC_DORM_LAYOUT","DORMITORY_INDEX",strTemp2,"rental",null)%>
      </td>
    </tr>
 <%
 if(WI.fillTextValue("occupant_status").compareTo("0") ==0){
 vRoomInfo = HM.getRoomInfo(dbOP,strTemp2);%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
<%if(vRoomInfo != null){%>
	  Maximum capacity of room &nbsp;&nbsp;&nbsp;: <strong><%=(String)vRoomInfo.elementAt(2)%></strong>
        <br>
        Total Occupants as of today : <strong><%=(String)vRoomInfo.elementAt(3)%></strong>
        <br>
        Remaining no of Occupants &nbsp;: <strong><%=(String)vRoomInfo.elementAt(4)%></strong>
        <%}else{%>
        <%=WI.getStrValue(HM.getErrMsg())%>
        <%}%>
      </td>
    </tr>
 <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><a href='javascript:Help("../../../onlinehelp/dormitory_help.htm");'><img src="../../../images/online_help.gif" border="0"></a>
        Help for above terms. </td>
    </tr>
    <tr>
      <td colspan="2"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Deposit Amount: <strong><%=(String)vAccountInfo.elementAt(0)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">O.R. No. :<strong> <%=(String)vAccountInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date paid : <strong><%=(String)vAccountInfo.elementAt(2)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Start date of Occupancy : <strong><%=(String)vAccountInfo.elementAt(3)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="3%" height="25">&nbsp;</td>
      <td width="96%" height="25" colspan="3">
	  <%if(iAccessLevel > 1){%>
	  <input type="image" src="../../../images/save.gif" onClick="AddRecord();">
	  <font size="1">click to save entry<a href="fm_schl_fees_account_add.jsp"><img src="../../../images/cancel.gif" border="0"></a>
        click to cancel or go previous</font>
	 <%}else{%>Not authorized to Save/create<%}%></td>
    </tr>
<%
	}//only if dorm_room is selected.
%>
  </table>
 <%
 }//only if account informaiton is not null;
 %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <%
  if(vReservationInfo != null){%>
  <input type="hidden" name="reservation_index" value="<%=(String)vReservationInfo.elementAt(0)%>">
  <input type="hidden" name="res_dorm_index" value="<%=(String)vReservationInfo.elementAt(4)%>">
 <%}%>
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="changeDormLoc" value="0">
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
