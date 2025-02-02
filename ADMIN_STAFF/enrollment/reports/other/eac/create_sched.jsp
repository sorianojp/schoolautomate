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
	if(EES.operateOnSchedule(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = EES.getErrMsg();
	else	
		strErrMsg = "Operation successful.";

}
if(WI.fillTextValue("pmt_schedule").length() > 0) 
	vRetResult = EES.operateOnSchedule(dbOP, request, 4);
%>
<body>
<form name="form_" method="post" action="create_sched.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=2"></jsp:include>
	  </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" size="2"><strong>:::: EAXM SCHEDULE MAIN PAGE ::::</strong></font></td>
    </tr>    
		<tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></font></td>
    </tr>	
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
	<tr>
	  <td width="2%" height="25">&nbsp;</td>
	  <td width="17%" >SY From/Term </td>
	  <td width="81%" >
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
			<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
	  - 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%> <select name="semester">
   <option value="0">Summer</option>
<%
if(strTemp.compareTo("1") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1"<%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.compareTo("2") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.compareTo("3") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
        </select>			
		
      <input type="button" name="refresh" value=" Display Schedules Created " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('');" />
		
		</td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >Exam Name  </td>
	  <td ><select name="pmt_schedule" >
        <%=dbOP.loadCombo("pmt_sch_index","exam_name"," from fa_pmt_schedule where is_valid=1 order by exam_period_order", WI.fillTextValue("pmt_schedule"), false)%>
      </select></td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >Date Range </td>
	  <td ><font size="1">
	  <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a> 
        to 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a> 
        
	  
	  (example Feb 1 to Feb 4) </font></td>
    </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >Time Range </td>
	  <td >
<%
Vector vTime = new Vector();
vTime.addElement("7");vTime.addElement("7 AM");
vTime.addElement("7.25");vTime.addElement("7:15 AM");
vTime.addElement("7.5");vTime.addElement("7:30 AM");
vTime.addElement("7.75");vTime.addElement("7:45 AM");
vTime.addElement("8");vTime.addElement("8 AM");
vTime.addElement("8.25");vTime.addElement("8:15 AM");
vTime.addElement("8.5");vTime.addElement("8:30 AM");
vTime.addElement("8.75");vTime.addElement("8:45 AM");
vTime.addElement("9");vTime.addElement("9 AM");
vTime.addElement("9.25");vTime.addElement("9:15 AM");
vTime.addElement("9.5");vTime.addElement("9:30 AM");
vTime.addElement("9.75");vTime.addElement("9:45 AM");
vTime.addElement("10");vTime.addElement("10 AM");
vTime.addElement("10.25");vTime.addElement("10:15 AM");
vTime.addElement("10.5");vTime.addElement("10:30 AM");
vTime.addElement("10.75");vTime.addElement("10:45 AM");
vTime.addElement("11");vTime.addElement("11 AM");
vTime.addElement("11.25");vTime.addElement("11:15 AM");
vTime.addElement("11.5");vTime.addElement("11:30 AM");
vTime.addElement("11.75");vTime.addElement("11:45 AM");
vTime.addElement("12");vTime.addElement("12 PM");
vTime.addElement("12.25");vTime.addElement("12:15 PM");
vTime.addElement("12.5");vTime.addElement("12:30 PM");
vTime.addElement("12.75");vTime.addElement("12:45 PM");
vTime.addElement("13");vTime.addElement("1 PM");
vTime.addElement("13.25");vTime.addElement("1:15 PM");
vTime.addElement("13.5");vTime.addElement("1:30 PM");
vTime.addElement("13.75");vTime.addElement("1:45 PM");
vTime.addElement("14");vTime.addElement("2 PM");
vTime.addElement("14.25");vTime.addElement("2:15 PM");
vTime.addElement("14.5");vTime.addElement("2:30 PM");
vTime.addElement("14.75");vTime.addElement("2:45 PM");
vTime.addElement("15");vTime.addElement("3 PM");
vTime.addElement("15.25");vTime.addElement("3:15 PM");
vTime.addElement("15.5");vTime.addElement("3:30 PM");
vTime.addElement("15.75");vTime.addElement("3:45 PM");
vTime.addElement("16");vTime.addElement("4 PM");
vTime.addElement("16.25");vTime.addElement("4:15 PM");
vTime.addElement("16.5");vTime.addElement("4:30 PM");
vTime.addElement("16.75");vTime.addElement("4:45 PM");
vTime.addElement("17");vTime.addElement("5 PM");
vTime.addElement("17.25");vTime.addElement("5:15 PM");
vTime.addElement("17.5");vTime.addElement("5:30 PM");
vTime.addElement("17.75");vTime.addElement("5:45 PM");
vTime.addElement("18");vTime.addElement("6 PM");
vTime.addElement("18.25");vTime.addElement("6:15 PM");
vTime.addElement("18.5");vTime.addElement("6:30 PM");
vTime.addElement("18.75");vTime.addElement("6:45 PM");
vTime.addElement("19");vTime.addElement("7 PM");
vTime.addElement("19.25");vTime.addElement("7:15 PM");
vTime.addElement("19.5");vTime.addElement("7:30 PM");
vTime.addElement("19.75");vTime.addElement("7:45 PM");
vTime.addElement("20");vTime.addElement("8 PM");
%>
	  <select name="start_time">
<%
strTemp = WI.fillTextValue("start_time");
if(strTemp.length() == 0)
	strTemp = "8";
for(int i = 0; i < vTime.size(); i += 2) {
	if(strTemp.equals(vTime.elementAt(i))) 
		strErrMsg = "selected";
	else	
		strErrMsg = "";
%>	<option value="<%=vTime.elementAt(i)%>" <%=strErrMsg%>><%=vTime.elementAt(i + 1)%></option>
<%}%>
	  </select>
	  
	  to 
	  <select name="end_time">
<%
strTemp = WI.fillTextValue("end_time");
if(strTemp.length() == 0)
	strTemp = "18";
for(int i = 0; i < vTime.size(); i += 2) {
	if(strTemp.equals(vTime.elementAt(i))) 
		strErrMsg = "selected";
	else	
		strErrMsg = "";
%>	<option value="<%=vTime.elementAt(i)%>" <%=strErrMsg%>><%=vTime.elementAt(i + 1)%></option>
<%}%>
	  </select>
	  
	  
	  <font size="1">(example 8:30 to 5:00 pm)</font></td>
    </tr>
	
	
	<tr>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td >
      	<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1');" />
	  	<font size="1">click to create schedule</font>
      </td>
	  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
		<td style="font-weight:bold;" align="center" class="thinborderNONE">List of Schedule Created</td>
	</tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {
Vector vTemp = null;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr>
		<td width="35%" class="thinborder">Exam Schedule</td>
		<td width="54%" class="thinborder">Time</td>
		<td width="11%" class="thinborder">Delete</td>
	</tr>
<%for(int i =0; i < vRetResult.size(); i += 6) {
vTemp = (Vector)vRetResult.elementAt(i + 5);
%>
  	<tr>
  	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%> - <%=(String)vRetResult.elementAt(i + 2)%></td>
  	  <td class="thinborder"><%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vRetResult.elementAt(i + 3)))%> - <%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vRetResult.elementAt(i + 4)))%></td>
  	  <td class="thinborder"><a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../../../images/delete.gif" border="0"></a></td>
    </tr>
  	<tr>
  	  <td class="thinborder" align="center" colspan="3">
		  <table width="80%" cellpadding="0" cellspacing="0">
			<%while(vTemp.size() > 0) {vTemp.remove(0);%>
				<tr>
					<td><%=vTemp.remove(0)%></td>
					<td><%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vTemp.remove(0)))%> - <%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vTemp.remove(0)))%></td>
					<%if(vTemp.size() > 0)
						vTemp.remove(0);
					%>
					<td>&nbsp;</td>
					<td><%if(vTemp.size() > 0) {%><%=vTemp.remove(0)%><%}else{%>&nbsp;<%}%></td>
					<td><%if(vTemp.size() > 0) {%>
						<%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vTemp.remove(0)))%> - <%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vTemp.remove(0)))%>
						<%}else{%>&nbsp;<%}%>
					</td>
					<td>&nbsp;</td>
					<%if(vTemp.size() > 0)
						vTemp.remove(0);
					%>
					<td><%if(vTemp.size() > 0) {%><%=vTemp.remove(0)%><%}else{%>&nbsp;<%}%></td>
					<td><%if(vTemp.size() > 0) {%>
						<%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vTemp.remove(0)))%> - <%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vTemp.remove(0)))%>
						<%}else{%>&nbsp;<%}%>
					</td>
				</tr>
			<%}%>
		  </table>
	  </td>
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

