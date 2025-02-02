<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<Script language="Javascript">
function AddRecord()
{
	document.rtype.deleteRecord.value = 0;
	document.rtype.addRecord.value = 1;

	document.rtype.submit();
}
function DeleteRecord(strInfoIndex)
{
	document.rtype.deleteRecord.value = 1;
	document.rtype.addRecord.value = 0;

	document.rtype.info_index.value = strInfoIndex;
	document.rtype.submit();
}

function ChangeRoomType()
{
	var room_type = document.rtype.room_type[document.rtype.room_type.selectedIndex].value;

	location = "./room_sub_cat_assigned.jsp?room_type="+escape(room_type);
}
function DeleteRoomType()
{
	document.rtype.delRoomType.value = "1";
	document.rtype.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.EnrollmentRoomMonitor,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-ROOMS MONITORING-rooms sub category","room_sub_cat_assigned.jsp");
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
														"Enrollment","ROOMS MONITORING",request.getRemoteAddr(),
														"room_sub_cat_assigned.jsp");
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
boolean bolErrorInOp = false;

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	if(RM.addRoom2SCatg(dbOP,request))
		strErrMsg = "Room type added successfully.";
	else
		bolErrorInOp = true;
}
else if(WI.fillTextValue("delRoomType").compareTo("1") == 0)
{
	if(RM.delRoomType(dbOP,request))
		strErrMsg = "Room type deleted successfully.";
	else
		bolErrorInOp = true;
}
else if(WI.fillTextValue("deleteRecord").compareTo("1") == 0)//either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	if(RM.delRoom2SCatg(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
		strErrMsg = "Room type deleted successfully.";
	else
		bolErrorInOp = true;
}

// if prepareToEdit == 1; get school information to edit.
String strEditInfo = null;
/*strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0)
{
	strEditInfo = RM.viewOneRoom2SCatg(dbOP,request.getParameter("info_index"));
	if(strEditInfo == null)
		strErrMsg = RM.getErrMsg();
}
*/
//get all levels created.
Vector vRetResult = new Vector();
if(request.getParameter("room_type") != null && request.getParameter("room_type").compareTo("selany") != 0 && !bolErrorInOp)
	vRetResult = RM.viewAllRoom2SCatg(dbOP, request);

if(vRetResult ==null || bolErrorInOp)
{%>
	<p> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=RM.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}

%>


<form name="rtype" method="post" action="./room_sub_cat_assigned.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8"><div align="center"><font color="#FFFFFF"><strong>::::
          ROOM TYPE MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8"><a href="./room_maintenance.jsp"><img src="../../../images/go_back.gif" border="0"></a>
      </td>
    </tr>
    <tr>
      <td height="25" colspan="8"><b><%=strErrMsg%></b></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td height="25" width="17%">Type of Room: </td>
      <td colspan="2"><select name="room_type" onChange="ChangeRoomType();">
          <option value="other" selected>Others</option>
          <%=dbOP.loadComboDISTINCT("TYPE","TYPE"," from E_ROOM_TYPE where IS_DEL=0",request.getParameter("room_type") , false)%>
        </select>
<%
if(WI.fillTextValue("room_type").length() ==0 || WI.fillTextValue("room_type").compareTo("other") ==0){%>
		<input type="text" name="other_room_type" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <%}else{%>
        &nbsp;&nbsp;&nbsp;
        <% if(iAccessLevel == 2 ){%>
        <a href='javascript:DeleteRoomType();'><img src="../../../images/delete.gif" width="51" height="22" border="0"></a> Delete the selected room type
        <%}else{%>
        Not authorized
        <%}
		}//only if type of room is selected%>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Subject category</td>
      <td width="40%">
        <%
if(strEditInfo == null)
	strEditInfo = request.getParameter("catg_index");//category index.
%>
        <select name="catg_index">
<option value="0">N/A</option>
          <%=dbOP.loadCombo("catg_index","catg_name"," from subject_catg where IS_DEL=0 order by catg_name asc", strEditInfo, true)%>
        </select></td>
      <td width="40%">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
        <%if(iAccessLevel > 1){%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click
        to add entry</font>
        <%}else{%>
        Not authorized to add
        <%}%>
      </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
  </table>
 <table width="100%" border=0>

    <tr bgcolor="#B9B292">
      <td height="25" colspan="8"><div align="center">LIST OF EXISTING SUBJECT
          CATEGORY THAT CAN HOLD CLASS IN ROOM TYPE</div></td>
    </tr>
  </table>
<%
if(vRetResult != null)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>
    <tr>
      <td width="27%">&nbsp;</td>
      <td width="36%"><strong><%=(String)vRetResult.elementAt(i+1)%></strong></td>
      <td height="25">
	 <% if(iAccessLevel == 2){%>
	 <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
	 <%}else{%>Not authorized<%}%></td>
    </tr>
    <%
i = i+1;
}//end of view all loops %>
  </table>

<%}//end of view all display%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<!-- all hidden fields go here -->
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="delRoomType" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>