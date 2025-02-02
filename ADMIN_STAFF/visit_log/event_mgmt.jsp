<%@ page language="java" import="utility.*, visitor.EventManager, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Event Mgmt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript">

	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this terminal info?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}	
	
	function RefreshPage() {
		location = "./event_mgmt.jsp";
	}
	
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Visitor Management-Event Mgmt","event_mgmt.jsp");
	}
	catch(Exception exp) {
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
															"Visitor Management","Event Mgmt",request.getRemoteAddr(),
															"event_mgmt.jsp");
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
	//end of authenticaion code.
	
	EventManager eventMgmt = new EventManager();	
	Vector vRetResult = null;
	boolean bolForwarded = WI.fillTextValue("forwarded").equals("1");
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(eventMgmt.operateOnEvent(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = eventMgmt.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Event information successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Event information successfully recorded.";		
		}
	}
	
	vRetResult = eventMgmt.operateOnEvent(dbOP, request, 4);
	if(vRetResult == null && strTemp.length() == 0)
		strErrMsg = eventMgmt.getErrMsg();

%>
<body bgcolor="#D2AE72" topmargin="0">
<form name="form_" method="post" action="event_mgmt.jsp">
<%if(!bolForwarded){%><jsp:include page="./tabs.jsp?pgIndex=4"></jsp:include><%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Event Name:</td>
	        <td width="80%">
				<%
					strTemp = WI.fillTextValue("event_name");						
				%>
				<textarea name="event_name" cols="40" rows="1" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
						onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("event_name")%></textarea></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Venue:</td>
		  	<td>
				<%
					strTemp = WI.fillTextValue("event_venue");
				%>
				<textarea name="event_venue" cols="40" rows="1" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
						onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("event_venue")%></textarea></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Time:</td>
		  	<td>
			
				<select name="time_from">
			<%
			strTemp = WI.fillTextValue("time_from");
			if(strTemp.equals("6"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="6" <%=strErrMsg%>>6 AM</option>
			<%			
			if(strTemp.length() == 0 || strTemp.equals("7"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="7" <%=strErrMsg%>>7 AM</option>		
			<%			
			if(strTemp.equals("8"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="8" <%=strErrMsg%>>8 AM</option>			
			<%			
			if(strTemp.equals("9"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="9" <%=strErrMsg%>>9 AM</option>		
			<%			
			if(strTemp.equals("10"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="10" <%=strErrMsg%>>10 AM</option>			
			<%			
			if(strTemp.equals("11"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="11" <%=strErrMsg%>>11 AM</option>		
			<%			
			if(strTemp.equals("12"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="12" <%=strErrMsg%>>12 NN</option>
			<%			
			if(strTemp.equals("13"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="13" <%=strErrMsg%>>1 PM</option>				
			<%			
			if(strTemp.equals("14"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="14" <%=strErrMsg%>>2 PM</option>			
			<%			
			if(strTemp.equals("15"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="15" <%=strErrMsg%>>3 PM</option>			
			<%			
			if(strTemp.equals("16"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="16" <%=strErrMsg%>>4 PM</option>			
			<%			
			if(strTemp.equals("17"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="17" <%=strErrMsg%>>5 PM</option>			
			<%			
			if(strTemp.equals("18"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="18" <%=strErrMsg%>>6 PM</option>			
			<%			
			if(strTemp.equals("19"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="19" <%=strErrMsg%>>7 PM</option>			
			<%			
			if(strTemp.equals("20"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="20" <%=strErrMsg%>>8 PM</option>			
			<%			
			if(strTemp.equals("21"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="21" <%=strErrMsg%>>9 PM</option>
				</select>
				
				&nbsp;to&nbsp;
			
				<select name="time_to">				
			<%
			strTemp = WI.fillTextValue("time_to");
			if(strTemp.equals("6"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="6" <%=strErrMsg%>>6 AM</option>
			<%			
			if(strTemp.equals("7"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="7" <%=strErrMsg%>>7 AM</option>		
			<%			
			if(strTemp.equals("8"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="8" <%=strErrMsg%>>8 AM</option>			
			<%			
			if(strTemp.equals("9"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="9" <%=strErrMsg%>>9 AM</option>		
			<%			
			if(strTemp.equals("10"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="10" <%=strErrMsg%>>10 AM</option>			
			<%			
			if(strTemp.equals("11"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="11" <%=strErrMsg%>>11 AM</option>		
			<%			
			if(strTemp.equals("12"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="12" <%=strErrMsg%>>12 NN</option>
			<%			
			if(strTemp.equals("13"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="13" <%=strErrMsg%>>1 PM</option>				
			<%			
			if(strTemp.equals("14"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="14" <%=strErrMsg%>>2 PM</option>			
			<%			
			if(strTemp.equals("15"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="15" <%=strErrMsg%>>3 PM</option>			
			<%			
			if(strTemp.equals("16"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="16" <%=strErrMsg%>>4 PM</option>			
			<%			
			if(strTemp.length() == 0 || strTemp.equals("17"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="17" <%=strErrMsg%>>5 PM</option>			
			<%			
			if(strTemp.equals("18"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="18" <%=strErrMsg%>>6 PM</option>			
			<%			
			if(strTemp.equals("19"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="19" <%=strErrMsg%>>7 PM</option>			
			<%			
			if(strTemp.equals("20"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="20" <%=strErrMsg%>>8 PM</option>			
			<%			
			if(strTemp.equals("21"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="21" <%=strErrMsg%>>9 PM</option>
			</select></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Date:</td>
		  	<td>
				<%
				strTemp = WI.fillTextValue("date_from");
				if(strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
				%>
				<input name="date_from" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_from');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
					<img src="../../images/calendar_new.gif" border="0"></a>

				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../images/calendar_new.gif" border="0"></a>
				</td>
	  	</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
			<%if(iAccessLevel > 1){%>				
				<a href="javascript:PageAction('1', '');"><img src="../../images/save.gif" border="0"></a>
				<font size="1">Click to save entry.</font>

				    
				<a href="javascript:RefreshPage();"><img src="../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>
			<%}else{%>
				Not authorized to save terminal information.
			<%}%>
			</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF EVENTS ::: </strong></div></td>
		</tr>
		<tr>
			<td width="20%" height="25" align="center" class="thinborder"><strong>EVENT NAME  </strong></td>
			<td width="41%" align="center" class="thinborder"><strong>EVENT VENUE</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>TIME</strong></td>
			<td width="17%" align="center" class="thinborder"><strong>DATE</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%
	String[] astrTime = {"","1 AM","2 AM","3 AM","4 AM","5 AM","6 AM","7 AM","8 AM","9 AM","10 AM","11 AM","12 NN",
		"1 PM","2 PM","3 PM","4 PM","5 PM","6 PM","7 PM","8 PM","9 PM","10 PM", "11 PM"};
	
	
	for(int i = 0; i < vRetResult.size(); i += 9){%> 
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<%
			strTemp = astrTime[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"))] + " - " +
					astrTime[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+4),"0"))];
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5))%><%=WI.getStrValue((String)vRetResult.elementAt(i+6)," - ","","")%></td>
			<td align="center" class="thinborder">			
				<%if(iAccessLevel == 2){%>
				<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../images/delete.gif" border="0"></a>
				<%}else{%>
				Not authorized.
				<%}%>
			</td>
		</tr>
	<%}%>
	</table>
<%}%>	

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="forwarded" value="<%=WI.fillTextValue("forwarded")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>