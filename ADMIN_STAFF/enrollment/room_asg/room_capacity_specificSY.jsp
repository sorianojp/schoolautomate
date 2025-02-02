<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex)
{
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PreparedToEdit(strInfoIndex, strRoomIndex) {
	document.form_.room_index.value = strRoomIndex;
	document.form_.info_index.value = strInfoIndex;
	document.form_.preparedToEdit.value   = "1";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function CalcelAction() {
	document.form_.info_index.value = "";
	document.form_.preparedToEdit.value   = "";
	document.form_.page_action.value = "";
	document.form_.total_cap.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.info_index.value = "";
	this.SubmitOnce('form_');
}


</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.EnrollmentRoomMonitor,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-ROOMS MONITORING-rooms maintenance","room_capacity_specificSY.jsp");
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
														"room_capacity_specificSY.jsp");
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

EnrollmentRoomMonitor ERM = new EnrollmentRoomMonitor();
Vector vRetResult = new Vector();
Vector vRoomDetail = null;
Vector vEditInfo = null;

String strRoomIndex = WI.fillTextValue("room_index");
if(strRoomIndex.length() > 0) {
	vRoomDetail = ERM.viewOneRoom(dbOP, strRoomIndex);
	if(vRoomDetail == null)
		strErrMsg = ERM.getErrMsg();
}
if(strErrMsg == null) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(ERM.operateOnRoomCapTermSpecific(dbOP, request,Integer.parseInt(strTemp)) == null)
			strErrMsg = ERM.getErrMsg();
		else	
			strErrMsg = "Operation successful.";
	}
}

vRetResult  = ERM.operateOnRoomCapTermSpecific(dbOP, request,4);
if(strPreparedToEdit.compareTo("1") == 0) {
	vEditInfo = ERM.operateOnRoomCapTermSpecific(dbOP, request,3);
	if(vEditInfo == null) 
		strErrMsg = ERM.getErrMsg();
}
%>


<form name="form_" action="./room_capacity_specificSY.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ROOM CAPACITY PAGE (SPECIFIC TERM) ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;&nbsp;&nbsp;
	  <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
	</table>

<%
if(vRoomDetail != null && vRoomDetail.size() > 0 && vRoomDetail.elementAt(4) != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="14%">Room Information</td>
      <td width="83%"><font size="1"><strong>Room No ::: Original Capacity ::: 
        Building ::: Floor</strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1"><strong><%=(String)vRoomDetail.elementAt(0)%> ::: <%=(String)vRoomDetail.elementAt(4)%> ::: <%=(String)vRoomDetail.elementAt(5)%> ::: 
        <%=(String)vRoomDetail.elementAt(6)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Term</td>
      <td> <select name="semester">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
	
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
        </select> </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td>New Capacity (Total)</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("total_cap");
%>	  <input name="total_cap" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="AllowOnlyInteger('form_','total_cap');style.backgroundColor='white'"
	   onKeyUp="AllowOnlyInteger('form_','total_cap');"></td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> 
        Click to reload the page.</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1"> 
        <%if(strPreparedToEdit.compareTo("1") == 0 && iAccessLevel > 1){%>
        <a href="javascript:PageAction(2,'');"><img src="../../../images/edit.gif" border="0"></a>Click 
        to Edit <a href="javascript:CalcelAction();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to Cancel Action 
        <%}else if(iAccessLevel > 1){%>
        <a href="javascript:PageAction(1,'');"><img src="../../../images/add.gif" border="0"></a>Click 
        to add information 
        <%}%>
        </font></td>
    </tr>
    <%}//if iAccessLevel > 1
%>
  </table>
<%}//only if there is a room information.
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center">TERM SPECIFIC ROOM CAPACITY</div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr > 
      <td width="58%" height="25" class="thinborder"><div align="center"><font size="1"><strong>ROOM 
          NO ::: BUILDING ::: FLOOR ::: ORIGINAL CAPACITY</strong></font></div></td>
      <td width="11%" height="25" class="thinborder"><div align="center"><font size="1"><strong>SEMESTER</strong></font></div></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>NEW 
        CAPACITY</strong></font></td>
      <td width="20%" align="center" class="thinborder"><font size="1"><strong>MODIFY</strong></font></td>
    </tr>
    <%

for(int i = 0 ; i< vRetResult.size() ; i += 8)
{%>
    <tr > 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%> ::: <%=(String)vRetResult.elementAt(i + 5)%> :::
	  <%=(String)vRetResult.elementAt(i + 6)%> ::: <%=(String)vRetResult.elementAt(i + 4)%> </td>
      <td class="thinborder">&nbsp;<%=dbOP.getHETerm(Integer.parseInt((String)vRetResult.elementAt(i + 1)))%> </td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%> </td>
      <td align="center" class="thinborder">
        <%if(iAccessLevel >1){%>
        <a href='javascript:PreparedToEdit("<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i + 7)%>");'> 
        <img src="../../../images/edit.gif" border="0"></a>&nbsp;&nbsp;&nbsp; 
        <%}if(iAccessLevel == 2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border="0"></a> 
        <%}%>
      </td>
<%}//END OF FOR LOOP.%>
  </table>
<%}//end of displaying the created exising payment schedule entries.
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="room_index" value="<%=WI.fillTextValue("room_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>