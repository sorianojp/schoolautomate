<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
//this is called to enable or disable the room capacity, when capacity is not applicable is checked, capacity is disabled, else it is enabled.
function RefreshPage()
{
	document.rmaintenance.editRecord.value = "";
	document.rmaintenance.deleteRecord.value = "";
	document.rmaintenance.addRecord.value = "";
	this.SubmitOnce('rmaintenance');
}
function EnableDisableCapacity()
{
	if(document.rmaintenance.capacity_not_applicable.checked)
	{
		document.rmaintenance.reg_stud_cap.value="";
		document.rmaintenance.irr_stud_cap.value="";
		document.rmaintenance.total_cap.value="";

		document.rmaintenance.nfs_assignment.checked = true;//without room capacity, i can't have it for room assignment.

		document.rmaintenance.reg_stud_cap.disabled=true;
		document.rmaintenance.irr_stud_cap.disabled=true;
		document.rmaintenance.total_cap.disabled=true;
	}
	else
	{
		document.rmaintenance.reg_stud_cap.disabled=false;
		document.rmaintenance.irr_stud_cap.disabled=false;
		document.rmaintenance.total_cap.disabled=false;
	}
}

function goToNextSearchPage()
{
	document.rmaintenance.editRecord.value = 0;
	document.rmaintenance.deleteRecord.value = 0;
	document.rmaintenance.addRecord.value = 0;
	document.rmaintenance.prepareToEdit.value = 0;

	this.SubmitOnce('rmaintenance');
}
function CancelRecord()
{
	location = "./room_maintenance.jsp?starts_with="+document.rmaintenance.starts_with.value;
}

function PrepareToEdit(strInfoIndex)
{
	document.rmaintenance.editRecord.value = 0;
	document.rmaintenance.deleteRecord.value = 0;
	document.rmaintenance.addRecord.value = 0;
	document.rmaintenance.prepareToEdit.value = 1;

	document.rmaintenance.info_index.value = strInfoIndex;

	this.SubmitOnce('rmaintenance');
}
function AddRecord()
{
	//most importantly - add the regular and irregular stud capacity and put it to total. -- do not add if total value is entered.
	var regStudCapacity = document.rmaintenance.reg_stud_cap.value;
	var iRegStudCapacity = document.rmaintenance.irr_stud_cap.value;
	var totalCapacity = document.rmaintenance.total_cap.value;
	if(regStudCapacity == "")regStudCapacity = 0;
	if(iRegStudCapacity == "")iRegStudCapacity = 0;
	if(totalCapacity == "")totalCapacity = 0;

	//implement javascript for above.
	if(regStudCapacity > 0 || iRegStudCapacity > 0 )
		totalCapacity = Number(regStudCapacity) + Number(iRegStudCapacity);

	document.rmaintenance.total_cap.value = totalCapacity;


	if(document.rmaintenance.prepareToEdit.value == 1)
	{
		EditRecord(document.rmaintenance.info_index.value);
		return;
	}
	document.rmaintenance.editRecord.value = 0;
	document.rmaintenance.deleteRecord.value = 0;
	document.rmaintenance.addRecord.value = 1;

	this.SubmitOnce('rmaintenance');
}
function EditRecord(strInfoIndex)
{
	document.rmaintenance.editRecord.value = 1;
	document.rmaintenance.deleteRecord.value = 0;
	document.rmaintenance.addRecord.value = 0;

	document.rmaintenance.info_index.value = strInfoIndex;
	this.SubmitOnce('rmaintenance');

}

function DeleteRecord(strInfoIndex)
{
	document.rmaintenance.editRecord.value = 0;
	document.rmaintenance.deleteRecord.value = 1;
	document.rmaintenance.addRecord.value = 0;

	document.rmaintenance.info_index.value = strInfoIndex;
	document.rmaintenance.prepareToEdit.value == 0;

	this.SubmitOnce('rmaintenance');
}
function UpdateRoomCapacity(strRoomIndex) {
	var win=window.open("./room_capacity_specificSY.jsp?room_index="+strRoomIndex,"PrintWindow",'width=800,height=600,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateOwnerShip(strRoomIndex) {
	var win=window.open("./room_ownership.jsp?room_index="+strRoomIndex,"PrintWindow",'width=800,height=600,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}</script>
<body bgcolor="#D2AE72">

<form name="rmaintenance" action="./room_maintenance.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.EnrollmentRoomMonitor,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-ROOMS MONITORING-rooms maintenance","room_maintenance.jsp");
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
														"Enrollment","ROOMS MAINTENANCE",request.getRemoteAddr(),
														"room_maintenance.jsp");
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

EnrollmentRoomMonitor RM = new EnrollmentRoomMonitor();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(RM.addRoom(dbOP,request))
	{
		strErrMsg = "Room added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=RM.getErrMsg()%></font></p>
		<%
		return;
	}
}
else//either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(RM.editRoom(dbOP,request))
		{
			strPrepareToEdit = "0";
			strErrMsg = "Room edited successfully.";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			<%=RM.getErrMsg()%></font></p>
			<%
			return;
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			strPrepareToEdit = "0";
			if(RM.delRoom(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
			{
				strErrMsg = "Room deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
				<%=RM.getErrMsg()%></font></p>
				<%
				return;
			}
		}
	}
}
// if prepareToEdit == 1; get school information to edit.
Vector vEditInfo = new Vector();
if(strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = RM.viewOneRoom(dbOP,request.getParameter("info_index"));
	if(vEditInfo.size() ==0 || vEditInfo == null)
		strErrMsg = RM.getErrMsg();
}



int iSearchResult = 0;
//get all levels created.
Vector vRetResult = new Vector();
vRetResult = RM.viewAllRoom(dbOP,request);

iSearchResult = RM.iSearchResult;

if(vRetResult ==null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=RM.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}

%>



  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ROOMS MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
    <%
if(strErrMsg != null)
{%>
    <tr > 
      <td>&nbsp;</td>
      <td colspan="4"><b><font size="3"><%=strErrMsg%></font></b></td>
    </tr>
    <%}%>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">Click REFRESH to reload the page<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr > 
      <td width="2%" height="25" rowspan="2"></td>
      <td height="25" colspan="2" valign="bottom">Room number </td>
      <td width="54%" height="25" colspan=2 valign="bottom">Type of room </td>
    </tr>
    <tr > 
      <td height="25" colspan="2"> <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(0);//school index.
else
	strTemp = request.getParameter("room_number");
if(strTemp == null) strTemp = "";
%> <input name="room_number" type="text" size="16" value="<%=strTemp%>" class="textbox" maxlength="12"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="54%" height="25" colspan=2 valign="top"> <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);//school index.
else
	strTemp = request.getParameter("room_type");
%> <select name="room_type">
          <%=dbOP.loadComboDISTINCT("E_ROOM_TYPE.TYPE","E_ROOM_TYPE.TYPE"," from E_ROOM_TYPE where IS_DEL=0 order by E_ROOM_TYPE.TYPE asc",strTemp , false)%> </select> <%if(iAccessLevel > 1){%> <a href="./room_sub_cat_assigned.jsp"><img src="../../../images/update.gif" border=0></a><font size="1">&nbsp;click 
        to add room type </font> <%}%> </td>
    </tr>
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><u>Location</u></td>
      <td  colspan="2" valign="bottom">Description </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td width="8%" height="25">Floor </td>
      <td width="36%"><select name="floor">
          <option>Basement 1</option>
          <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(6);//school index.
else
	strTemp = WI.fillTextValue("floor");
if(strTemp.compareTo("Basement 2") ==0){%>
          <option selected>Basement 2</option>
          <%}else{%>
          <option>Basement 2</option>
          <%}if(strTemp.compareTo("Basement 3") ==0){%>
          <option selected>Basement 3</option>
          <%}else{%>
          <option>Basement 3</option>
          <%}if(strTemp.compareTo("Basement 4") ==0){%>
          <option selected>Basement 4</option>
          <%}else{%>
          <option>Basement 4</option>
          <%}if(strTemp.compareTo("Ground") ==0){%>
          <option selected>Ground</option>
          <%}else{%>
          <option>Ground</option>
          <%}if(strTemp.compareTo("1st") ==0){%>
          <option selected>1st</option>
          <%}else{%>
          <option>1st</option>
          <%}if(strTemp.compareTo("2nd") ==0){%>
          <option selected>2nd</option>
          <%}else{%>
          <option>2nd</option>
          <%}if(strTemp.compareTo("3rd") ==0){%>
          <option selected>3rd</option>
          <%}else{%>
          <option>3rd</option>
          <%}if(strTemp.compareTo("4th") ==0){%>
          <option selected>4th</option>
          <%}else{%>
          <option>4th</option>
          <%}if(strTemp.compareTo("5th") ==0){%>
          <option selected>5th</option>
          <%}else{%>
          <option>5th</option>
          <%}if(strTemp.compareTo("6th") ==0){%>
          <option selected>6th</option>
          <%}else{%>
          <option>6th</option>
          <%}if(strTemp.compareTo("7th") ==0){%>
          <option selected>7th</option>
          <%}else{%>
          <option>7th</option>
          <%}if(strTemp.compareTo("8th") ==0){%>
          <option selected>8th</option>
          <%}else{%>
          <option>8th</option>
          <%}if(strTemp.compareTo("9th") ==0){%>
          <option selected>9th</option>
          <%}else{%>
          <option>9th</option>
          <%}if(strTemp.compareTo("10th") ==0){%>
          <option selected>10th</option>
          <%}else{%>
          <option>10th</option>
          <%}if(strTemp.compareTo("11th") ==0){%>
          <option selected>11th</option>
          <%}else{%>
          <option>11th</option>
          <%}if(strTemp.compareTo("12th") ==0){%>
          <option selected>12th</option>
          <%}else{%>
          <option>12th</option>
          <%}if(strTemp.compareTo("13th") ==0){%>
          <option selected>13th</option>
          <%}else{%>
          <option>13th</option>
          <%}if(strTemp.compareTo("14th") ==0){%>
          <option selected>14th</option>
          <%}else{%>
          <option>14th</option>
          <%}if(strTemp.compareTo("15th") ==0){%>
          <option selected>15th</option>
          <%}else{%>
          <option>15th</option>
          <%}if(strTemp.compareTo("16th") ==0){%>
          <option selected>16th</option>
          <%}else{%>
          <option>16th</option>
          <%}if(strTemp.compareTo("17th") ==0){%>
          <option selected>17th</option>
          <%}else{%>
          <option>17th</option>
          <%}if(strTemp.compareTo("18th") ==0){%>
          <option selected>18th</option>
          <%}else{%>
          <option>18th</option>
          <%}if(strTemp.compareTo("19th") ==0){%>
          <option selected>19th</option>
          <%}else{%>
          <option>19th</option>
          <%}if(strTemp.compareTo("20th") ==0){%>
          <option selected>20th</option>
          <%}else{%>
          <option>20th</option>
          <%}if(strTemp.compareTo("21st") ==0){%>
          <option selected>21st</option>
          <%}else{%>
          <option>21st</option>
          <%}if(strTemp.compareTo("22nd") ==0){%>
          <option selected>22nd</option>
          <%}else{%>
          <option>22nd</option>
          <%}if(strTemp.compareTo("23rd") ==0){%>
          <option selected>23rd</option>
          <%}else{%>
          <option>23rd</option>
          <%}if(strTemp.compareTo("24th") ==0){%>
          <option selected>24th</option>
          <%}else{%>
          <option>24th</option>
          <%}if(strTemp.compareTo("25th") ==0){%>
          <option selected>25th</option>
          <%}else{%>
          <option>25th</option>
          <%}%>
        </select></td>
      <td  colspan="2" valign="bottom"> <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(7);//school index.
else
	strTemp = request.getParameter("desc");
if(strTemp == null) strTemp = "";
%> <input name="desc" type="text" size="48" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Building</td>
      <td height="25"> <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);//school index.
else
	strTemp = request.getParameter("location");
if(strTemp == null) strTemp = "";
%> <input name="location" type="text" size="32" value="<%=strTemp%>" class="textbox" maxlength="64"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td  colspan="2" valign="bottom">Status/Remarks</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><u>Capacity</u></td>
      <td  colspan="2" valign="bottom"> <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(8);//school index.
else
	strTemp = request.getParameter("status");
if(strTemp == null) strTemp = "";
%> <input name="status" type="text" size="48" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr > 
      <td height="12">&nbsp;</td>
      <td  colspan="4"height="12"> <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);//school index.
else
	strTemp = request.getParameter("reg_stud_cap");

if(strTemp == null) strTemp = "";
%> <input name="reg_stud_cap" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('rmaintenance','reg_stud_cap');style.backgroundColor='white'"
	   onKeyUp="AllowOnlyInteger('rmaintenance','reg_stud_cap');"> <font size="1">Regular 
        Studs. </font> <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);//school index.
else
	strTemp = request.getParameter("irr_stud_cap");
if(strTemp == null) strTemp = "";
%> <input name="irr_stud_cap" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('rmaintenance','irr_stud_cap');style.backgroundColor='white'"
	   onKeyUp="AllowOnlyInteger('rmaintenance','irr_stud_cap');"> <font size="1">Irregular 
        Studs.</font></td>
    </tr>
    <tr > 
      <td height="13">&nbsp;</td>
      <td colspan="4" height="13"> <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);//school index.
else
	strTemp = request.getParameter("total_cap");
if(strTemp == null) strTemp = "";
%> <input name="total_cap" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('rmaintenance','total_cap');style.backgroundColor='white'"
	   onKeyUp="AllowOnlyInteger('rmaintenance','total_cap');"> <font size="1">fill 
        this for total capacity if no need to specify number of regular or irregular 
        students</font></td>
    </tr>
    <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(9);//school index.
else
	strTemp = WI.fillTextValue("capacity_not_applicable");
if(strTemp.compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
    <tr > 
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25"><input type="checkbox" name="capacity_not_applicable" value="1" <%=strTemp%> onClick="EnableDisableCapacity();"> 
        <font size="1">tick if room <strong>capacity is not applicable </strong></font></td>
    </tr>
    <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(10);//school index.
else
	strTemp = WI.fillTextValue("nfs_assignment");
if(strTemp.compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
    <tr > 
      <td height="24">&nbsp;</td>
      <td colspan="4" height="24"><input type="checkbox" name="nfs_assignment" value="1" <%=strTemp%>> 
        <font size="1">tick if room is<strong> not used for subject assignment</strong></font></td>
    </tr>
    <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(11);//school index.
else
	strTemp = WI.fillTextValue("skip_conflict_check");
if(strTemp.compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
    <tr > 
      <td height="24">&nbsp;</td>
      <td colspan="4" height="24"><input type="checkbox" name="skip_conflict_check" value="1" <%=strTemp%>> 
        <font size="1">tick if room <strong>conflict is not checked</strong> during 
        room assignment (Used for sharing a room/ facility like GYM/Swimming pool 
        during same time by more than one section/course/colleges)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4" bgcolor="#BBDDFF" class="thinborderALL"><div align="center"><strong>Additional 
          Information (Optional) </strong></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25" class="thinborderLEFTRIGHT">&nbsp;&nbsp;Last date 
        of inspection : 
	<%
	if(vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(12);//last inspection date.
	else
		strTemp = WI.fillTextValue("last_inspect");
	%>
			
        <input name="last_inspect" type="text" size="12" maxlength="12" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('rmaintenance.last_inspect',
	  <%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        (mm/dd/yyyy)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25" class="thinborderLEFTRIGHT">&nbsp;
	<%
	if(vEditInfo.size() > 0 && vEditInfo.elementAt(4) != null) {%>
	  Click here to update Room capacity for specific Term : <a href="javascript:UpdateRoomCapacity(<%=WI.fillTextValue("info_index")%>)"><img src="../../../images/update.gif" border=0></a>
    <%}else{%>
	  Edit room information to add/change TERM Specific room capacity
	<%}%></td>
	</tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25" class="thinborderBOTTOMLEFTRIGHT">&nbsp;
	 <%
	if(vEditInfo.size() > 0 && vEditInfo.elementAt(4) != null) {%>
		Click here to update Room Ownership : <a href="javascript:UpdateOwnerShip(<%=WI.fillTextValue("info_index")%>)"><img src="../../../images/update.gif" border=0></a>
	<%}else{%>
		Edit room information to add/change ROOM OWNERSHIP
	<%}%>  
	  </td>
    </tr>
    <%
if(iAccessLevel > 1){%>
    <tr > 
      <td height="13">&nbsp;</td>
      <td colspan="4" height="13"> <%
if(strPrepareToEdit.compareTo("0") == 0)
{%> <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click 
        to add/save</font> <%}else{%> <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
        to save</font> changes <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel &amp; clear entries</font> <%}%> </td>
    </tr>
    <%}%>
    <tr > 
      <td  colspan="5" height="25">&nbsp;</td>
    </tr>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center">LIST
          OF EXISTING ROOMS</div></td>
    </tr>
    <tr>
      <td height="25" colspan="6">To filter room display enter room number starts
        with
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        and click REFRESH to reload the page <a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
      </td>
    </tr>
</table>
<%
if(vRetResult != null && vRetResult.size() >0)//6 in one set ;-)
{%>

  <table width="100%" border="0" bgcolor="#FFFFFF">

    <tr>
      <td width="41%" > Total room alloted: <%=iSearchResult%> - showing(<%=RM.strDispRange%>)</td>
      <td width="30%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/RM.defSearchSize;
		if(iSearchResult % RM.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="goToNextSearchPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr > 
      <td height="13" colspan="2" class="thinborder"><div align="center"><font size="1"><strong>LOCATION</strong></font></div>
        <div align="center"><font size="1"></font></div></td>
      <td width="13%" rowspan="2" class="thinborder"><div align="center"><font size="1"><strong>ROOM 
          #</strong></font></div></td>
      <td width="13%" rowspan="2" class="thinborder"><div align="center"><font size="1"><strong>LAST 
          INSPECTION DATE</strong></font></div></td>
      <td width="17%" rowspan="2" class="thinborder"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="11%" rowspan="2" class="thinborder"><div align="center"><font size="1"><strong>TYPE 
          OF ROOM</strong></font></div></td>
      <td width="15%" rowspan="2" class="thinborder"><strong><font size="1">STATUS/ REMARKS</font></strong></td>
      <td width="8%" rowspan="2" align="center" class="thinborder"><strong><font size="1">FOR SUBJECT 
        ASSIGNMENT</font></strong></td>
      <td width="15%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">CHECK 
          ROOM CONFLICT</font></strong></div></td>
      <td height="15" colspan="3" class="thinborder"><div align="center"><font size="1"><strong>CAPACITY<br>
          (no. of students)</strong></font></div>
        <div align="center"><font size="1"></font></div>
        <font size="1">&nbsp;</font></td>
      <td width="7%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>EDIT</strong>&nbsp;</font></td>
      <td width="9%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <tr > 
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>BUILDING</strong></font></div></td>
      <td width="5%" height="12" class="thinborder"><div align="center"><font size="1"><strong>FLOOR</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>REG.</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>IRREG.</strong></font></div></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>TOT</strong></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); ++i)
{%>
    <tr > 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+9),"&nbsp;")%></td>
      <td align="center" class="thinborder"> <% if(((String)vRetResult.elementAt(i+11)).compareTo("1") ==0)
	  {%> <img src="../../../images/x.gif" width="12" height="14"> 
        <%}else{%> <img src="../../../images/tick.gif"> <%}%> </td>
      <td align="center" class="thinborder"> <% if(((String)vRetResult.elementAt(i+12)).compareTo("1") ==0)
	  {%> <img src="../../../images/x.gif" width="12" height="14"> 
        <%}%>
        &nbsp; </td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td class="thinborder"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%> <font size="1">Not authorized</font> <%}%> </td>
      <td class="thinborder"> <%if(iAccessLevel == 2){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%> <font size="1">Not authorized </font> <%}%> </td>
    </tr>
    <%
i = i+13;
}//end of loop %>
  </table>

<%}//end of displaying %>

 <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<!-- all hidden fields go here -->
<%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="deleteRecord" value="0">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
