<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,eSC.CampusQuery,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	if(request.getSession(false).getAttribute("userIndex") == null) {%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			You are already logged out. Please login again.</font></p>
		<%
		return;
	}
//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.

//end of authenticaion code.

CampusQuery CQ = new CampusQuery(request);
vRetResult = CQ.getAttendancePerStudent(dbOP, request);
if(vRetResult == null)
	strErrMsg = CQ.getErrMsg();



%>	

<form action="./campus_attendance.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="88%" height="25" colspan="5" bgcolor="#47768F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
      CAMPUS ATTENDANCE DETAIL PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="3%" height="25">&nbsp;</td>
      <td width="46%" height="25">
<%
strTemp = WI.fillTextValue("show_type");
if(strTemp.length() == 0 || strTemp.equals("0") )
	strTemp = "checked";
else	
	strTemp = "";
%>
	  <input name="show_type" type="radio" value="0" <%=strTemp%> onClick="document.form_.submit();"> Date Range </td>
      <td height="25" colspan="2">
<%if(strTemp.length() == 0) 
	strTemp = "checked";
else	
	strTemp = "";
%>
	  <input name="show_type" type="radio" value="1" <%=strTemp%> onClick="document.form_.submit();"> SY-Term</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">
<%if(strTemp.length() == 0) {//meaning Syfrom is having value

strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
	  <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../images/calendar_new.gif" border="0"></a> to
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../images/calendar_new.gif" border="0"></a>
<%}%>		
	  </td>
      <td width="36%" height="25">
<%if(WI.fillTextValue("show_type").equals("1")) {
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
-
<select name="semester">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
	
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%><option value="2"<%=strErrMsg%>>2nd Sem</option>
<%if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>  <option value="3"<%=strErrMsg%>>3rd Sem</option>
<%if(strTemp.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>  <option value="0"<%=strErrMsg%>>Summer</option>
</select>
<%}//show only if sy/term selected.%>
</td>
      <td width="15%">
	  	<input type="submit" name="132" value="Refresh Display" style="font-size:11px; height:22px;border: 1px solid #FF0000;">	  
	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="2" bgcolor="#BECED3" class="thinborder" style="font-weight:bold" align="center">- Attendance Report - </td>
    </tr>
    <tr> 
      <td width="14%" height="25" class="thinborder"><div align="center"><strong>Date</strong></div></td>
      <td width="86%" class="thinborder" align="center"><strong>Timein-Timeout</strong></td>
    </tr>
<%for(int i = 0; i< vRetResult.size(); i +=3){
	strErrMsg = (String)vRetResult.elementAt(i);//date.
	
	strTemp = "<b>"+(String)vRetResult.elementAt(i + 1)+"</b>";
	strTemp += "-"+WI.getStrValue(vRetResult.elementAt(i + 2),"xxxx");

	while((i + 4) < vRetResult.size() &&  strErrMsg.equals(vRetResult.elementAt(i + 3)) ) {
		i += 3;
		strTemp += "; <b>"+(String)vRetResult.elementAt(i + 1)+"</b>";
		strTemp += "-"+WI.getStrValue(vRetResult.elementAt(i + 2),"xxxx");
	}
			
	%>
    <tr> 
      <td height="25" align="center" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=strTemp%>
	  </td>
    </tr>
<%}%>
  </table>
 <%}//only if vRetResult is not null %>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>