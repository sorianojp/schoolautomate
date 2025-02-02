<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
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
function ReloadPage() {
	document.form_.fix_floating_ra.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();
}
function ViewRoomSch(strRoomNo)  {
	var strLoc = "";
	<%if(strSchCode.startsWith("CIT") || true){%>
		strLoc = "../../enrollment/subjects/cp/viewRoomAssignment.jsp?school_year_fr="+document.form_.sy_from.value+
				"&school_year_to="+document.form_.sy_to.value+
				"&offering_sem="+document.form_.semester[document.form_.semester.selectedIndex].value+
				"&room_n="+escape(strRoomNo);
	<%}else{%>
		strLoc = "";
	<%}%>
	var win=window.open(strLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	
}


</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Application Fix","check_room_conflict.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														"check_room_conflict.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
enrollment.EnrollmentRoomMonitor ERM = new enrollment.EnrollmentRoomMonitor();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0) {
	vRetResult = ERM.checkRoomAssignmentInConflict(dbOP, request);
	strErrMsg = ERM.getErrMsg();
}

String[] astrConvertWeekDay = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
%>


<form name="form_" action="./check_room_conflict.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CHECK ROOM CONFLICT ERROR ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="14%" height="25">SY / TERM</td>
      <td width="28%"> <%
if(WI.fillTextValue("sy_from").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else
	strTemp = WI.fillTextValue("sy_from");
%> <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="4" maxlength="4"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
        <%
if(WI.fillTextValue("sy_to").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
else
	strTemp = WI.fillTextValue("sy_to");
%> <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="4" maxlength="4" readonly> 
        &nbsp;&nbsp; <select name="semester">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("semester");
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
        </select></td>
      <td width="55%"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
 <%
 if (vRetResult!= null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="26" colspan="4" class="thinborder"><div align="center"><strong>LIST OF ROOMS HAVING CONFLICT </strong></div></td>
    </tr>
    <tr align="center" style="font-weight:bold">
      <td width="5%" class="thinborder">Count</td> 
      <td width="33%" height="27" class="thinborder"><div align="center"><strong>Room Number </strong></div></td>
      <td width="48%" class="thinborder"><div align="center"><strong>Week Day (first conflict) </strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong>View Room Schedule </strong></div></td>
    </tr>
    <%int iCount =0;
 for(int i = 0; i < vRetResult.size(); i += 2){
 	strTemp = (String)vRetResult.elementAt(i + 1);//System.out.println(strTemp);
	strTemp = strTemp.substring(strTemp.indexOf("*")+ 1).trim();
	
	%>
    <tr>
      <td  class="thinborder"><%=++iCount%>.</td> 
      <td height="25"  class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=astrConvertWeekDay[Integer.parseInt(strTemp)]%></td>
      <td class="thinborder"><a href="javascript:ViewRoomSch('<%=vRetResult.elementAt(i)%>')"> 
        <img src="../../../images/view.gif" border="0"></a></td>
    </tr>
    <%
	}//end of printing errors.
	if(vRetResult == null || vRetResult.size() == 0){%>
    <tr bgcolor="#77ccFF"> 
      <td height="25" colspan="4"  class="thinborder">&nbsp;&nbsp;<b>*************** 
        No Error found *************** </b></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr><td width="25">&nbsp;</td></tr>
  </table>
  

 <%} // vRetResult%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25"bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="info_index">
 <input type="hidden" name="page_action">
 <input type="hidden" name="fix_floating_ra">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
