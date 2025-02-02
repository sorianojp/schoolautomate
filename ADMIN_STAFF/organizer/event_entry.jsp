<%
if(request.getSession(false).getAttribute("userId") == null){%>
<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
	Please login to access this link.
</font>
<%return;
}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
a:link {
	color: #000000;
	text-decoration: none;
}
a:visited {
	color: #000000;
	text-decoration: none;

}
a:hover {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
a:active {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
</style>

</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function enableReminder() {
	if (document.form_.showReminder.value == "1")
			document.form_.showReminder.value = "";
		else
			document.form_.showReminder.value = "1";
	this.SubmitOnce('form_');

}
function enableRecurrence() {
	if (document.form_.showRecurrence.value == "1")
		document.form_.showRecurrence.value = "";
	else
		document.form_.showRecurrence.value = "1";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function FocusStuff()
{
	document.form_.subject.focus();
}
</script>
<%@ page language="java" import="utility.*, organizer.Event, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	int iTemp = 0;
	String strErrMsg = null;
	String strShowRem = "";
	String strShowRecur = "";
	String strPrepareToEdit = null;
	
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	strShowRem = WI.getStrValue(request.getParameter("showReminder"),"0");
	strShowRecur = WI.getStrValue(request.getParameter("showRecurrence"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Events-Event Entry","event_entry.jsp");
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
/** authenticate this user. -- no need.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Organizer","Events",request.getRemoteAddr(),
														"event_entry.jsp");
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
**/
	Event myEvent = new Event();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myEvent.operateOnEvent(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = myEvent.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vRetResult = myEvent.operateOnEvent(dbOP, request, 3);
		if(vRetResult == null && strErrMsg == null ) 
			strErrMsg = myEvent.getErrMsg();
	}

	if (strErrMsg == null)
	strErrMsg = myEvent.getErrMsg();
%>
<body bgcolor="#8C9AAA" onLoad="FocusStuff();">
<form action="./event_entry.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EVENT DATA ::::</strong></font></div></td>
    </tr>
    <tr>
    <td width="50%">
    	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#DBEAF5">
		    <tr>
    			<td colspan="2"><%=WI.getStrValue(strErrMsg, "&nbsp;")%></td>
    		</tr> 
    		 <tr>
		      	<td width="25%"><div align="left"><font size="1">&nbsp;Event Name: </font></div></td>
		      	<td width="75%"><div align="left"><%strTemp = WI.fillTextValue("subject");%>
		      	<input name="subject" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>"> 
		      	</div></td>
		    </tr>
		     <tr>
    			<td colspan="2">&nbsp;</td>
    		</tr> 
    		<tr>
		      	<td><div align="left"><font size="1">&nbsp;Location: </font></div></td>
		      	<td><div align="left"><%strTemp = WI.fillTextValue("location");%>
		      	<input name="location" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>"> 
		      	</div></td>
		    </tr> 
		     <tr>
    			<td colspan="2">&nbsp;</td>
    		</tr> 
    		<tr>
		      	<td><div align="left"><font size="1">&nbsp;Start :</font></div></td>
		      	<td><div align="left">
		      	<%strTemp = WI.fillTextValue("start_date");
		      		if (strTemp.length()==0)
		      			strTemp = WI.getTodaysDate(1);%>
		      	 <input name="start_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" maxlength="12" readonly="true" value="<%=strTemp%>"> 
        <a href="javascript:show_calendar('form_.start_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a>
		      	</div></td>
		    </tr>
		    <tr>
		      	<td><div align="left"><font size="1">&nbsp;</font></div></td>
		      	<td><div align="left">
		      	 <select name="start_hr">
				<%strTemp = WI.fillTextValue("start_hr");
		  	iTemp = Integer.parseInt(WI.getStrValue(strTemp,"0"));
		for(int i = 1 ; i<=12; ++i) {
		if (iTemp == i){%>
				<option value="<%=i%>" selected><%if(i < 10){%>0<%}%><%=i%></option>
				<%}else{%>
				<option value="<%=i%>"><%if(i < 10){%>0<%}%><%=i%></option>
				<%}}%>
			</select>
			<select name="start_min">
				<%strTemp = WI.fillTextValue("start_min");
	  	iTemp = Integer.parseInt(WI.getStrValue(strTemp,"0"));
		for(int i = 0 ; i<60; i += 15) {
		if (iTemp == i){%>
				<option value="<%=i%>" selected><%if(i < 10){%>0<%}%><%=i%></option>
				<%}else{%>
				<option value="<%=i%>"><%if(i < 10){%>0<%}%><%=i%></option>
				<%}}%>
			</select>
			<select name="start_ampm">
				<% strTemp = WI.fillTextValue("start_ampm");
			if(strTemp.compareTo("0") == 0)	{%>
				<option value="0" selected>AM</option>
				<option value="1" >PM</option>
				<%}else{%>
				<option value="0">AM</option>
				<option value="1" selected>PM</option>
				<%}%>
			</select> 
		      	</div></td>
		    </tr>
		     <tr>
    			<td colspan="2">&nbsp;</td>
    		</tr> 
		    <tr>
		      	<td><div align="left"><font size="1">&nbsp;End : </font></div></td>
		      	<td><div align="left">
		      	<%strTemp = WI.fillTextValue("end_date");

		      		if (strTemp.length()==0)
		      			strTemp = WI.getTodaysDate(1);%>
		      	 <input name="end_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" maxlength="12" readonly="true" value="<%=strTemp%>"> 
        <a href="javascript:show_calendar('form_.end_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a>
        &nbsp;
        <%strTemp = WI.getStrValue(WI.fillTextValue("allDay"),"0");
        if (strTemp.compareTo("1")==0)
        	strTemp2 = "checked";
        	else
        	strTemp2 = "";%>
         	 <input type="checkbox" name="allDay" value="1" onChange="ReloadPage();" <%=strTemp2%>><font size="1">all day event</font>
			</div></td>
		    </tr>
<%if (strTemp.length()>0 && strTemp.compareTo("0")==0){%>
		    <tr>
		      	<td><div align="left"><font size="1">&nbsp;</font></div></td>
		      	<td><div align="left">
		      	 <select name="end_hr">
				<%strTemp = WI.fillTextValue("end_hr");
		  	iTemp = Integer.parseInt(WI.getStrValue(strTemp,"0"));
		for(int i = 1 ; i<=12; ++i) {
		if (iTemp == i){%>
				<option value="<%=i%>" selected><%if(i < 10){%>0<%}%><%=i%></option>
				<%}else{%>
				<option value="<%=i%>"><%if(i < 10){%>0<%}%><%=i%></option>
				<%}}%>
			</select>
			<select name="end_min">
				<%strTemp = WI.fillTextValue("end_min");
	  	iTemp = Integer.parseInt(WI.getStrValue(strTemp,"0"));
		for(int i = 0 ; i<60; i += 15) {
		if (iTemp == i){%>
				<option value="<%=i%>" selected><%if(i < 10){%>0<%}%><%=i%></option>
				<%}else{%>
				<option value="<%=i%>"><%if(i < 10){%>0<%}%><%=i%></option>
				<%}}%>
			</select>
			<select name="end_ampm">
				<%strTemp = WI.fillTextValue("end_ampm");
			if(strTemp.compareTo("0") == 0)	{%>
				<option value="0" selected>AM</option>
				<option value="1" >PM</option>
				<%}else{%>
				<option value="0">AM</option>
				<option value="1" selected>PM</option>
				<%}%>
			</select> 
		      	</div></td>
		    </tr>		
		    <%}%>
		     <tr>
    			<td colspan="2">&nbsp;</td>
    		</tr> 
    		<tr>
		      	<td><div align="left"><font size="1">&nbsp;Notes: </font></div></td>
		      	<td><div align="left">
		      	<%strTemp = WI.fillTextValue("remarks");%>
		      	<textarea name="remarks" cols="33" rows="2" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea> 
		      	</div></td>
		    </tr>
		     <tr>
    			<td colspan="2">&nbsp;</td>
    		</tr> 
		    <tr>
		      	<td><div align="left"><font size="1">&nbsp;Category: </font></div></td>
		      	<td><div align="left">
		     <%strTemp = WI.fillTextValue("cat_index");%>
	         <select name="cat_index">
		    <option value="">Select Category</option>
			<%=dbOP.loadCombo("ORG_CAT_INDEX","CATEGORY"," FROM ORG_CATEGORY ORDER BY CATEGORY", strTemp, false)%>
		    </select>
		      	</div></td>
		    </tr>
 <tr>
    			<td colspan="2">&nbsp;</td>
    		</tr> 
    		 <tr>
    			<td colspan="2">&nbsp;</td>
    		</tr> 
    		 <tr>
    			<td colspan="2">&nbsp;</td>
    		</tr> 
    	</table>
   </td>
    <td width="50%" valign="top">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(false){//do not show reminder.%>
    		<tr bgcolor="#DBEAF5">
		      <td height="25" colspan="5"><font color="#000000" size="1" ><strong><a href="javascript:enableReminder();">:::: REMINDERS ::::</a></strong></font></td>
    		</tr>
    		<%if (strShowRem.compareTo("1")==0){%>
    		<tr>
    		<%strTemp = WI.fillTextValue("alert");%>
    			<td colspan="2"><font size="1">Alert me 
		<select name="alert">
		      	<option value="0" selected>5 minutes</option>
			<%if (strTemp.compareTo("1")==0){%>
		      	<option value="1" selected>15 minutes</option>
			<%} else {%>
				<option value="1">15 minutes</option>
			<%} if (strTemp.compareTo("2")==0){%>
				<option value="2" selected>30 minutes</option>
			<%} else {%>
				<option value="2">30 minutes</option>				
			<%} if (strTemp.compareTo("3")==0){%>				
		      	<option value="3" selected>1 hour</option>
			<%} else {%>		      	
		      	<option value="3">1 hour</option>		      	
			<%} if (strTemp.compareTo("4")==0){%>						      	
		     	<option value="4" selected>2 hours</option>
			<%} else {%>		      			     	
		     	<option value="4">2 hours</option>		     	
			<%} if (strTemp.compareTo("5")==0){%>						      			     	
		     	<option value="5" selected>3 hours</option>
			<%} else {%>		      			     			     	
		     	<option value="5">3 hours</option>		     	
			<%} if (strTemp.compareTo("6")==0){%>						      			     			     	
		     	<option value="6" selected>6 hours</option>
			<%} else {%>		      			     			     			     	
		     	<option value="6">6 hours</option>		     	
			<%} if (strTemp.compareTo("7")==0){%>								     	
		     	<option value="7" selected>12 hours</option>
			<%} else {%>		      			     			     			     	
		     	<option value="7">12 hours</option>		     	
			<%} if (strTemp.compareTo("8")==0){%>								     	
		     	<option value="8" selected>1 day</option>
			<%} else {%>		      			     			     			     	
		     	<option value="8">1 day</option>		     	
			<%} if (strTemp.compareTo("9")==0){%>								     	
		     	<option value="9" selected>2 days</option>
			<%} else {%>		      			     			     			     	
		     	<option value="9">2 days</option>		     	
			<%} if (strTemp.compareTo("10")==0){%>								     	
		     	<option value="10" selected>3 days</option>
			<%} else {%>		      			     			     			     	
		     	<option value="10">3 days</option>		     	
			<%} if (strTemp.compareTo("11")==0){%>								     	
		     	<option value="11" selected>4 days</option>
			<%} else {%>		      			     			     			     	
		     	<option value="11">4 days</option>		     	
			<%} if (strTemp.compareTo("12")==0){%>								     	
		     	<option value="12" selected>5 days</option>
			<%} else {%>		      			     			     			     	
		     	<option value="12">5 days</option>		     	
			<%} if (strTemp.compareTo("13")==0){%>								     	
		     	<option value="13" selected>6 days</option>
			<%} else {%>		      			     			     			     	
		     	<option value="13">6 days</option>		     	
			<%} if (strTemp.compareTo("14")==0){%>								     	
		     	<option value="14" selected>1 week</option>
			<%} else {%>		      			     			     			     	
		     	<option value="14">1 week</option>		     	
		     <%}%>
		</select> before the event</font></td>
    		</tr>
    		<tr>
    			<td colspan="2">&nbsp;
    			 <%strTemp = WI.getStrValue(WI.fillTextValue("netMail"),"0");
		        if (strTemp.compareTo("1")==0)
		        	strTemp2 = "checked";
        		else
		        	strTemp2 = "";%>
    			<input type="checkbox" name="netMail" value="1" <%=strTemp%>><font size="1">send alert to my Inbox</font></td>
    		</tr>
    		<tr>
    			<td colspan="2">&nbsp;
    			 <%strTemp = WI.getStrValue(WI.fillTextValue("otherMail"),"0");
		        if (strTemp.compareTo("1")==0)
		        	strTemp2 = "checked";
        		else
		        	strTemp2 = "";%>
    			<input type="checkbox" name="otherMail" value="1" <%=strTemp2%>><font size="1">send alert to this address <br>&nbsp;
    			<%strTemp = WI.fillTextValue("email");%>
    			<input name="email" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>"></font></td>
    		</tr>
    		<%}%>
<%}//do not show reminder..%>			

    		<tr bgcolor="#DBEAF5">
		      <td height="25" colspan="5"><font color="#000000" size="1" ><strong><a href="javascript:enableRecurrence()">:::: RECURRENCE ::::</a></strong></font></td>
    		</tr>
    		<%
    		strTemp = WI.fillTextValue("start_date");
    		strTemp2= WI.fillTextValue("end_date");
    		if (strTemp.length()>0 && strTemp2.length()>0){
    		if (strShowRecur.compareTo("1")==0 && ConversionTable.compareDate(strTemp,strTemp2)==0){%>
    		<tr>
    		<td colspan="2"><div align="center"><font size="1">Repeat:</font>
    		<%strTemp = WI.fillTextValue("rec_index");%>
    		<select name="rec_index" onChange="javascript:ReloadPage();">
		      	<option value="" selected>Never</option>
		      	<%if (strTemp.compareTo("1")==0){%>
		      	<option value="1" selected>Daily</option>
		      	<%}else{%>
		      	<option value="1">Daily</option>
		      	<%} if (strTemp.compareTo("2")==0) {%>
		      	<option value="2" selected>Yearly</option>
		      	<%}else{%>
		      	<option value="2">Yearly</option>
		      	<%}%>
		      	</select> </div></td>
    		</tr>
    		<tr>
    			<td colspan="2">&nbsp;</td>
    		</tr>
    		<%if (strTemp.compareTo("1")==0){%>
    		<tr>
    			<td width="25%"><font size="1">Repeat every</font></td>
	   			<td width="75%"><font size="1">
	   			<%strTemp = WI.fillTextValue("rep");%>
	   			<input name="rep" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
	  		    onKeyUp= 'AllowOnlyInteger("form_","rep")' onFocus="style.backgroundColor='#D3EBFF'"
				onblur='AllowOnlyInteger("form_","rep");style.backgroundColor="white"'> days/years</font></td>
    		</tr>
    		<%}%>
    		<tr bgcolor="aliceblue">
		      <td height="25" colspan="5" ><font color="#000000" size="1"><strong>:::: RECURRENCE RANGE ::::</strong></font></td>
    		</tr>
    		<tr><%strTemp2 = WI.fillTextValue("recur_type");%>
    			<td><div align="right">
    			<%if (strTemp2.compareTo("0")==0)
    				strTemp3 = "checked";
    			else
    				strTemp3 = "";%>
    				<input type="radio" name="recur_type" value="0" <%=strTemp3%>></div>
    			</td>
    			<td><font size="1">No end</font></td>
    		</tr>
    		<tr>
    			<td><div align="right">
			<%if (strTemp2.compareTo("1")==0)
    				strTemp3 = "checked";
    			else
    				strTemp3 = "";%>
    				<input type="radio" name="recur_type" value="1" <%=strTemp3%>></div>
    			</td>
    			<td><font size="1">End after 
    			<%strTemp = WI.fillTextValue("occ");%>
    			<input name="occ" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
	  				 onKeyUp= 'AllowOnlyInteger("form_","occ")' onFocus="style.backgroundColor='#D3EBFF'"
					 onblur='AllowOnlyInteger("form_","occ");style.backgroundColor="white"'> occurences</font></td>
    		</tr>
    		<tr>
    			<td><div align="right">
    			<%if (strTemp2.compareTo("2")==0)
    				strTemp3 = "checked";
    			else
    				strTemp3 = "";%>
    				<input type="radio" name="recur_type" value="2" <%=strTemp3%>></div>
    			</td>
				<td><font size="1">End by: <input name="rec_end" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" maxlength="12" readonly="true"> 
		        <a href="javascript:show_calendar('form_.rec_end');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0">
		        </a></font>
				 </td>    		
			</tr>
			<%}}%>
			<tr>
    			<td colspan="2">&nbsp;</td>
    		</tr>
			<tr>
			<td colspan="2"><div align="left"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0" name="hide_save"></a> 
        Save event 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Edit cvent <a href="javascript:Cancel();"><img src="../../images/cancel.gif" border="0"></a> 
        Cancel entry 
        <%}%></font></div></td>
			</tr>
    	</table>
    </td>    
    </tr>
</table>
    <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="showRecurrence" value="<%=strShowRecur%>">
	<input type="hidden" name="showReminder" value="<%=strShowRem%>">	
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
