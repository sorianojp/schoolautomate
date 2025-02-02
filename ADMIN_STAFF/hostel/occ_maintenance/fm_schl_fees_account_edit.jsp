<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
function ReloadPage()
{
	document.fa_account.submit();
}
function ChangeDormLoc()
{
	document.fa_account.changeDormLoc.value="1";
	ReloadPage();
}
function EditRecord()
{
	document.fa_account.editRecord.value="1";
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.Authentication,enrollment.HostelManagement,java.util.Vector" %>
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
	String strInfoIndex = WI.fillTextValue("info_index");


	if(strCurSYFrom == null || strCurSYTo == null)
	{
		bolProceed = false;
		strErrMsg = "You are logged out. Please login again.";
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Hostel Management-OCCUPANCY MAINTENANCE- Edit occupancy account","fm_schl_fees_account_edit.jsp");
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
														"fm_schl_fees_account_edit.jsp");
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
boolean bolIsStaff = false; //true only if the payee type is internal and not a student type.

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAPayment faPayment = new FAPayment();
HostelManagement HM = new HostelManagement();

if(WI.fillTextValue("editRecord").compareTo("1") ==0)
{
	if(!HM.changeRoomAllotment(dbOP, strInfoIndex,request.getParameter("dorm_room")))
		strErrMsg = HM.getErrMsg();
	else
	{
		strErrMsg = "Room changed successfully.";
		bolProceed = false;
	}
}
if(WI.fillTextValue("stud_id").length() > 0)
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
		vAccountInfo = HM.viewHostelAccountInfo(dbOP,request.getParameter("stud_id"));
		if(vAccountInfo == null)
		{
			strErrMsg = HM.getErrMsg();
			bolProceed = false;
		}
		else
			strInfoIndex = (String)vAccountInfo.elementAt(0);
	}
}
if(vBasicInfo == null || vBasicInfo.size() ==0)
{
	bolProceed = false;
	if(strErrMsg == null)
		strErrMsg = "Occupant information not found.";
}

if(strErrMsg == null) strErrMsg = "";
%>
<form name="fa_account" action="./fm_schl_fees_account_edit.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="30" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHOOL FACILITIES FEES MAINTENANCE PAGE ::::<br>
          <font size="1">EDIT INTERNAL ACCOUNT</font> </strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><a href="<%=request.getParameter("prev_url")%>"><img src="../../../images/go_back.gif" border="0"></a>&nbsp;&nbsp;&nbsp;
        <strong><%=strErrMsg%></strong></td>
    </tr>
<%
if(!bolProceed)
	return;
%>

    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="50%">Fee name : <strong><%=(String)vAccountInfo.elementAt(10)%></strong></td>
      <td width="46%">School Year<strong> : <%=strCurSYFrom%> - <%=strCurSYTo%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td  width="4%"height="25">&nbsp;</td>
      <td width="50%">ID Number : <strong><%=request.getParameter("stud_id")%></strong></td>

    <td width="46%">Account category :<strong>
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
if(!bolIsStaff){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="50%">Account name : <strong><%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td width="46%">School year : <strong><%=strCurSYFrom%> - <%=strCurSYTo%></strong></td>
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
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Year/Term : <strong><%=(String)vBasicInfo.elementAt(4)%>/
        <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}else{%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td>Account name : <strong><%=WI.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),1)%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%" colspan="2">Employee type :<strong> <%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Employee status : <strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">College/Department/Office : <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/<%=(String)vBasicInfo.elementAt(14)%></strong></td>
    </tr>
</table>
<%}
if(vAccountInfo != null && vAccountInfo.size() > 0){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="2"><hr size="1"></td>
    </tr>
  </table>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%">Particular (Room/Door) :
        <select name="location" onChange="ChangeDormLoc();">
          <option value="0">Select a location</option>
          <%
if(WI.fillTextValue("editRecord").length() ==0)//first time, so get information from the edit info.
	strTemp2 = (String)vAccountInfo.elementAt(1);
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
//because it is edit, do not show the current room.
strTemp = " from FA_STUD_SCHFAC_DORM_LAYOUT where LOCATION_INDEX="+strTemp2+" and is_del=0 and is_valid=1 and room_status = 0 order by room_no asc";
%>
          <%=dbOP.loadCombo("DORMITORY_INDEX","ROOM_NO",strTemp, WI.fillTextValue("dorm_room"), false)%>
        </select>
        <%}%>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Deposit : <strong><%=(String)vAccountInfo.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">O.R. No. :<strong> <%=(String)vAccountInfo.elementAt(7)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date paid : <strong><%=(String)vAccountInfo.elementAt(8)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Start date of Occupancy : <strong><%=(String)vAccountInfo.elementAt(9)%></strong></td>
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
	  <input type="image" src="../../../images/save.gif" onClick="EditRecord();"><font size="1">click
        to save changes<a href="javascript:ReloadPage();"><img src="../../../images/cancel.gif" border="0"></a>
        click to cancel changes</font>
 <%}else{%>Not authorized to edit <%}%>
		</td>
    </tr>
  </table>
 <%}//only if vAccountInfo is not null
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prev_url" value="<%=WI.fillTextValue("prev_url")%>">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">

</form>
</body>
</html>
