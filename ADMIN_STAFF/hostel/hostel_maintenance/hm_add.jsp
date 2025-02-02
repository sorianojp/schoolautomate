<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction)
{
	document.hostelM.page_action.value=strAction;
	document.hostelM.submit();
}
function DeleteRecord(strIndex)
{
	document.hostelM.page_action.value="0";
	document.hostelM.info_index.value = strIndex;
	document.hostelM.submit();
}

function CancelRecord()
{
	document.hostelM.prepareToEdit.value = "0";
	document.hostelM.submit();
}
function PrepareToEdit(strIndex)
{
	document.hostelM.info_index.value = strIndex;
	document.hostelM.prepareToEdit.value ="1";
	document.hostelM.submit();
}
function ReloadPage()
{
	document.hostelM.location_name.value = document.hostelM.location[document.hostelM.location.selectedIndex].text;
	document.hostelM.room_no.value="";
	document.hostelM.rental.value="";
	document.hostelM.capacity.value="";
	document.hostelM.no_of_room.value="";
	document.hostelM.description.value="";


	document.hostelM.submit();
}
function UpdateLocName()
{
	document.hostelM.location_name.value = document.hostelM.oth_loc.value;
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.HostelManagement,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Hostel Management-HOSTEL MAINTENANCE- Add","hm_add.jsp");
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
														"Hostel Management","HOSTEL MAINTENANCE",request.getRemoteAddr(),
														"hm_add.jsp");
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

HostelManagement HM = new HostelManagement();
Vector vRetResult = null;
Vector vEditInfo  = null;

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("0") == 0)//delete
{
	strPrepareToEdit="0";
	if(HM.operateOnRoom(dbOP, request,0) != null)
		strErrMsg = "Room deleted successfully.";
	else
		strErrMsg = HM.getErrMsg();
}
else if(strTemp.compareTo("1") == 0)//add
{
	strPrepareToEdit = "0";
	if(HM.operateOnRoom(dbOP, request,1) != null)
		strErrMsg = "Room added successfully.";
	else
		strErrMsg = HM.getErrMsg();
}
else if(strTemp.compareTo("2") == 0)//edit
{
	if(HM.operateOnRoom(dbOP, request,2) != null)
	{
		strPrepareToEdit = "0";
		strErrMsg = "Room edited successfully.";
	}
	else
		strErrMsg = HM.getErrMsg();
}

vRetResult = HM.operateOnRoom(dbOP, request,3);
if(strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = HM.operateOnRoom(dbOP, request,4);
	if(vEditInfo == null)
		strErrMsg = HM.getErrMsg();
}
if(strErrMsg == null) strErrMsg = "";
%>

<form name="hostelM" method="post" action="./hm_add.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          HOSTEL MAINTENANCE - ADD/EDIT/DELETE PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="16%">Location/Name</td>
      <td><select name="location" onChange="ReloadPage()">
          <option value="0">Others</option>
          <%
if(WI.fillTextValue("reloadPage").length() ==0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("location");
%>
          <%=dbOP.loadCombo("LOCATION_INDEX","LOCATION"," from FA_STUD_SCHFAC_DORM_LOC where is_del=0 order by LOCATION asc", strTemp, false)%>
        </select>
        <%
if(WI.fillTextValue("location").length() == 0 || WI.fillTextValue("location").compareTo("0") ==0){%>
        <input type="text" name="oth_loc" onKeyUp="UpdateLocName();" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <%}%>
      </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="19%" height="25">Room # / House # </td>
      <td width="34%">
        <%
if(vEditInfo != null)
	strTemp = WI.getStrValue(vEditInfo.elementAt(2));
else
	strTemp = WI.fillTextValue("room_no");
%>
        <input name="room_no" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="13%">Capacity </td>
      <td width="30%">
        <%
if(vEditInfo != null)
	strTemp = WI.getStrValue(vEditInfo.elementAt(4));
else
	strTemp = WI.fillTextValue("capacity");
%>
        <input name="capacity" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Rental (per month)</td>
      <td>
        <%
if(vEditInfo != null)
	strTemp = WI.getStrValue(vEditInfo.elementAt(3));
else
	strTemp = WI.fillTextValue("rental");
%>
        <input name="rental" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
      </td>
      <td>No.of rooms </td>
      <td>
        <%
if(vEditInfo != null)
	strTemp = WI.getStrValue(vEditInfo.elementAt(5));
else
	strTemp = WI.fillTextValue("no_of_room");
%>
        <input name="no_of_room" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25" valign="top">Description</td>
      <td colspan="2" >
        <%
if(vEditInfo != null)
	strTemp = WI.getStrValue(vEditInfo.elementAt(6));
else
	strTemp = WI.fillTextValue("description");
%>
        <textarea name="description" cols="33" rows="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
      <td >&nbsp;</td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr>
      <td>&nbsp;</td>
      <td  colspan="3">
        <%
	if(strPrepareToEdit.compareTo("0") == 0)
	{%>
        <a href="javascript:PageAction(1);"><img src="../../../images/add.gif" border="0"></a><font size="1">click
        to save entry</font>
        <%}else{%>
        <a href="javascript:PageAction(2);"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
        to cancel &amp; clear entries</font>
        <%}%>
      </td>
      <td >&nbsp;</td>
    </tr>
<%}//if iAccessLevel > 1%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="7" bgcolor="#B9B292"><div align="center">LIST OF
          ROOMS IN <strong><%=request.getParameter("location_name")%> : </strong>TOTAL
          ROOMS:<strong> <%=(vRetResult.size())/8%></strong></div></td>
    </tr>
    <tr>
      <td width="18%" height="26"><div align="center"><font size="1"><strong>ROOM
          #/HOUSE #</strong></font></div></td>
      <td width="11%" ><div align="center"><font size="1"><strong>RENTAL</strong></font></div></td>
      <td width="12%" ><div align="center"><font size="1"><strong>CAPACITY</strong></font></div></td>
      <td width="18%" ><div align="center"><font size="1"><strong>NO.
          OF ROOMS</strong></font></div></td>
      <td width="30%" ><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="4%" align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
<%
for(int i=0 ; i<vRetResult.size(); ++i){%>    <tr>
      <td height="25" ><%=(String)vRetResult.elementAt(i+2)%></td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+3))%>&nbsp;</td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+4))%>&nbsp;</td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+5))%>&nbsp;</td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+6))%>&nbsp;</td>
      <td align="center">
<%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}else{%>Not authorized<%}%>  </td>
      <td align="center">
<%if(iAccessLevel ==2){%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
<%}else{%>Not authorized<%}%>  </td>
    </tr>
<%
i = i+6;
}%>
  </table>
<%} //if there are rooms created already.
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%" height="25">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
 <input type="hidden" name="page_action">
 <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
 <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
 <input type="hidden" name="reloadPage" value="0">
 <input type="hidden" name="location_name">
 </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
