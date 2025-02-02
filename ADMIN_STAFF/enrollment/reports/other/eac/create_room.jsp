<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript">	
	function PageAction(strAction, strInfoIndex) {		
		document.form_.page_action.value = strAction;
		if(strAction == '0') {
			if(confirm("Are you sure you want to delete this record?")){
				document.form_.page_action.value ='0';								
			}
			else
				return;
			document.form_.info_index.value = strInfoIndex;	
		}
		document.form_.submit();
	}

</script>
<%@ page language="java" import="utility.*,java.util.Vector, enrollment.EACExamSchedule" %>
<%
	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);
	Vector vRetResult = null;
	String strErrMsg  = null;
	String strTemp    = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}
	try
	{
		dbOP = new DBOperation();
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
	

EACExamSchedule EES = new EACExamSchedule();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(EES.operateOnAllowedRoom(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = EES.getErrMsg();
	else	
		strErrMsg = "Operation successful.";

}

vRetResult = EES.operateOnAllowedRoom(dbOP, request, 4);
%>
<body>
<form name="form_" method="post" action="create_room.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=4"></jsp:include>
	  </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" size="2"><strong>:::: ASSIGN ROOM ::::</strong></font></td>
    </tr>    
		<tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></font></td>
    </tr>	
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
	
	<tr>
	  <td width="2%" height="25">&nbsp;</td>
	  <td width="12%" >Room</td>
	  <td width="86%" >
	  <select name="room_" style="font-size:9px;">
        <%=dbOP.loadCombo("room_index","room_number, description"," from e_room_detail where is_del=0 and not exists (select * from EAC_EXAM_ROOM where ROOM_INDEX = e_room_detail.ROOM_INDEX and is_valid = 1) order by room_number", WI.fillTextValue("room_"), false)%>
      </select></td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >Capacity</td>
	  <td >
	  <input name="capacity_" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("capacity_")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
	  </td>
    </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >Is Reserved </td>
	  <td >
<%
strTemp = WI.fillTextValue("is_reserved");
if(strTemp.length() > 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  
	  <input type="checkbox" name="is_reserved" value="1" <%=strTemp%>>
	  
	  </td>
    </tr>
	<tr>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td >
      	<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1');" />
	  	<font size="1">click to create schedule</font>      </td>
	  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
		<td style="font-weight:bold;" align="center" class="thinborderNONE">List of Rooms Set for Scheduling </td>
	</tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr>
		<td width="15%" class="thinborder">Room Number </td>
		<td width="15%" class="thinborder">Floor</td>
		<td width="20%" class="thinborder">Description (Venue) </td>
		<td width="15%" class="thinborder">Location (Building) </td>
		<td width="10%" class="thinborder">Room Capacity </td>
		<td width="10%" class="thinborder">Delete</td>
	</tr>
<%for(int i =0; i < vRetResult.size(); i += 8) {
strTemp = "bgcolor='#cccccc'";
if(vRetResult.elementAt(i + 7).equals("1") )
	strTemp = "";
%>
  	<tr <%=strTemp%>>
  	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
  	  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3), "&nbsp;")%></td>
  	  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), "&nbsp;")%></td>
  	  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 5), "&nbsp;")%></td>
  	  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6), "&nbsp;")%></td>
  	  <td class="thinborder"><a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
<%}%>
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
</form>
</body>
</html>

<%
if(dbOP!=null)
	dbOP.cleanUP();
%>

