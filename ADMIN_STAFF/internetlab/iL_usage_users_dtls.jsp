<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.print_pg.value = "";
	document.form_.submit();
}
function PrintPg() {
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function UpdateUsage(strLabelID, strInfoIndex) {
	if(!confirm("Are you sure you want to edit usage in mins?"))
		return;
	strTotalMins = prompt("Please enter new usage in mins.","");
	if(strTotalMins == null)
		return;
	
	document.form_.info_index.value = strInfoIndex;
	document.form_.mins_used.value  = strTotalMins;
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,iCafe.ComputerUsage,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

if(WI.fillTextValue("print_pg").length() > 0) {%>
	<jsp:forward page="./iL_usage_users_dtls_print.jsp"/>	
<%return;}

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-USAGE DETAILS -user usage detail",
								"iL_usage_users_dtls.jsp");
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
														"Internet Cafe Management",
														"USAGE DETAILS",request.getRemoteAddr(),
														"iL_usage_users_dtls.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}
ComputerUsage compUsage = new ComputerUsage();
iCafe.TimeInTimeOut tinTout = new iCafe.TimeInTimeOut();
enrollment.EnrlAddDropSubject addDropSub = new enrollment.EnrlAddDropSubject();

Vector vRetResult = null;
Vector vStudInfo = null;
long lBalanceUsage = 0l;
boolean bolShowAttendant = false;

boolean bolIsStaff = false;

if(WI.fillTextValue("info_index").length() > 0 && WI.fillTextValue("mins_used").length() > 0) {
	if(compUsage.operateOnEditTinTout(dbOP, request, 2) == null)
		strErrMsg = compUsage.getErrMsg();
	else	
		strErrMsg = "Usage minutes successfully changed.";
}	

	 
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("semester").length() > 0 &&
	WI.fillTextValue("stud_id").length() > 0) {
	
	vStudInfo = addDropSub.getEnrolledStudInfo(dbOP,null, WI.fillTextValue("stud_id"), WI.fillTextValue("sy_from"), 
					 WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
	if(vStudInfo == null || vStudInfo.size() == 0) {
		//may be faculty.
		request.setAttribute("emp_id",WI.fillTextValue("stud_id"));
		vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
		if(vStudInfo != null)
			bolIsStaff = true; 
	}
	
	if(vStudInfo == null || vStudInfo.size() == 0)
		strErrMsg = addDropSub.getErrMsg();
}
if(vStudInfo != null && vStudInfo.size() > 0) {

	if (WI.fillTextValue("show_attendant").length() ==1)
		bolShowAttendant = true;

	vRetResult = compUsage.getComputerUsageDetailPerUser(dbOP, WI.fillTextValue("stud_id"),
		WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"),
		WI.fillTextValue("date_from"), WI.fillTextValue("date_to"));
	if(vRetResult == null || vRetResult.size() == 0)
		strErrMsg = compUsage.getErrMsg();	
}
if(vStudInfo != null && vStudInfo.size() > 0){
	if(bolIsStaff)
		lBalanceUsage = 99999;
	else	
		lBalanceUsage = tinTout.getInternetBalanceUsage(dbOP, (String)vStudInfo.elementAt(0), 
						WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
	if(lBalanceUsage == tinTout.lErrorVal) {
		strErrMsg = tinTout.getErrMsg();
		vRetResult = null;
	}
}
 
//end of authenticaion code.
%>
<form action="./iL_usage_users_dtls.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          USAGE DETAILS - USERS PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td width="66%" height="25">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
      <td width="34%"><strong>
        <div align="right"><font size="1"><strong>Date / Time :</strong> <%=WI.getTodaysDateTime()%></font></div>
        </strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="17%" height="25"> Enter ID :</td>
      <td><input name="stud_id" type="text" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">SY/Term</td>
      <td> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date Range</td>
      <td><input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a> 
        &nbsp;To 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a> 
        <font size="1">(empty date show for complet SY/Term) </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
<% if (WI.fillTextValue("show_attendant").length() == 1) strTemp = "checked"; 
	else
	strTemp = "";
%>
      <td colspan="2"><input type="checkbox" name="show_attendant" value="1" <%=strTemp%>>
        <font size = 1> tick to show name of attendant </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
    <%
if(vStudInfo != null && vStudInfo.size() > 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>
        <%if(bolIsStaff){%>
        Employee
        <%}else{%>
        Student
        <%}%>
        Name</td>
      <td>
<%if(bolIsStaff){%>
	  <%=WebInterface.formatName((String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),
					(String)vStudInfo.elementAt(3),4).toUpperCase()%> 
<%}else{%>
	  <%=WebInterface.formatName((String)vStudInfo.elementAt(10),
	  					(String)vStudInfo.elementAt(11),(String)vStudInfo.elementAt(12),4)%>
<%}%>
		</td>
    </tr>
<%if(!bolIsStaff){%>
    <tr> 
      <td width="4%">&nbsp;</td>
      <td height="25">Course / Major</td>
      <td><%=(String)vStudInfo.elementAt(2)%><%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Year Level</td>
      <td height="25"><%=WI.getStrValue((String)vStudInfo.elementAt(4),"N/A")%></td>
    </tr>
<%}%>
  </table>
 <%}
 if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="4%" height="15">&nbsp;</td>
      <td height="15" colspan="2">TOTAL HOURS REMAINING : 
	<% if(lBalanceUsage == 99999){%>
        <strong><font color="#0000FF">Unlimited</font></strong> 
        <%} else if (lBalanceUsage < 0){
	  	lBalanceUsage *= -1l;%>
	  	<strong><font color="#FF0000"><%=ConversionTable.convertMinToHHMM((int)lBalanceUsage)%> excess usage</font></strong>
	<%}else{%>
		<strong><%=ConversionTable.convertMinToHHMM((int)lBalanceUsage)%></strong> 		
	<%}%> 
        </td>
      <td width="27%"><font size="1"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a>click 
        to print details</font></td>
    </tr>
  </table>	  
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFF9F"> 
      <td height="24" colspan="8"><div align="center"><font color="#0000FF"><strong>USAGE 
          DETAILS </strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="9%" height="25" align="center"><font size="1"><strong>DATE</strong></font></td>
      <td width="11%" align="center"><font size="1"><strong>LOGIN TIME</strong></font></td>
      <td width="11%" align="center"><font size="1"><strong>LOGOUT TIME</strong></font></td>
      <td width="11%" align="center"><font size="1"><strong>COMPUTER NAME</strong></font></td>
      <td width="22%" align="center"><font size="1"><strong>LOCATION</strong></font></td>
<% if (bolShowAttendant){%>
      <td width="20%" align="center"><font size="1"><strong>ATTENDANT</strong></font></td>
<%}%>
      <!--      <td width="23%" align="center"><font size="1"><strong>OTHER SERVICES REQUESTED</strong></font></td>
-->
      <td width="15%" align="center"><font size="1"><strong>TOTAL HOURS USED</strong></font></td>
    </tr>
<%
boolean bolEditAllowed = false;

for(int i = 1; i < vRetResult.size(); i += 11){
bolEditAllowed = vRetResult.elementAt(i + 10).equals("1");
%>
    <tr bgcolor="<%if(bolEditAllowed){%>#DDDDDD<%}else{%>#FFFFFF<%}%>"> 
      <td height="25"><font size="1">&nbsp;
	  	<%if(bolEditAllowed){%><label id="<%=i%>" onClick="UpdateUsage('<%=i%>','<%=vRetResult.elementAt(i)%>')"><%}%><%=(String)vRetResult.elementAt(i+7)%><%if(bolEditAllowed){%></label><%}%>
	  </font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5),"Not Assigned")%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
<% if (bolShowAttendant){%>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></td>
<%}%>
      <!--      <td><font size="1">$sub_type_name - $cost</font></td>-->
      <td><font size="1"><strong><%=(String)vRetResult.elementAt(i+3)%></strong></font></td>
    </tr>
    <%}%>
    <tr bgcolor="#FFFFFF"> 
<% if (bolShowAttendant)
	strTemp = "colspan=6";
	else strTemp = "colspan=5"; %>
      <td height="25" <%=strTemp%> align="right"><strong><font size="1">GRAND TOTAL</font></strong> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(0)%></td>
    </tr>
  </table>
 <%}//end of displaying if vRetResult <> null%>
 
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_pg">

<input type="hidden" name="mins_used">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>