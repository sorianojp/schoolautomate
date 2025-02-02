<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
			
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<head>
<title>Close working hour schedule</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function UpdateRecord(){
	document.dtr_op.update_record.value = '1';
	document.dtr_op.donot_call_close_wnd.value = "1";
	this.SubmitOnce('dtr_op');
}
 
function ReloadParentWnd() {
	if(document.dtr_op.donot_call_close_wnd.value.length >0)
		return;

	if(document.dtr_op.close_wnd_called.value == "0") {
		window.opener.document.dtr_op.submit();
		window.opener.focus();
	}
}
</script>

<body bgcolor="#D2AE72" onUnload="javascript:ReloadParentWnd();">
<%
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strPrepareToEdit = null;

	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","close_schedule.jsp");
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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"close_schedule.jsp");	
														
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
	WorkingHour wHour = new WorkingHour(); 
	Vector vRetResult = null;
	Vector vWHDetails = null;
	String[] astrConvertWeekDay= {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};	
	String[] astrConverAMPM = {"AM","PM"};
	String strEmpID = WI.fillTextValue("emp_id");
 	if(WI.fillTextValue("update_record").equals("1")){
		if(!wHour.closeWHSchedule(dbOP, request,WI.fillTextValue("wh_index")))
			strErrMsg = wHour.getErrMsg();
	}	
 	vWHDetails = wHour.getWHDetails(dbOP, WI.fillTextValue("wh_index"));	
%>	
<form action="./close_schedule.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" ><strong>:::: 
      WORKING HOURS MGMT - SET WORKING HOURS PAGE ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25"><strong><font size="2" >&nbsp;<%=WI.getStrValue(strErrMsg)%>&nbsp;</font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="25" colspan="6">&nbsp;Employee ID :<strong><font size="3" color="#FF0000"><%=strEmpID%></font></strong>      </td>
    </tr>
  </table>
<% 

if (strEmpID.length()  > 0 && vWHDetails != null){
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="2"><hr size="1"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
			<%
				strTemp = (String)vWHDetails.elementAt(14);
				strTemp += " - " + (String)vWHDetails.elementAt(15);
				
				strTemp2 = astrConvertWeekDay[Integer.parseInt((String)vWHDetails.elementAt(16))];
			%>
      <td height=30>Effective date : <strong><%=strTemp%> (<%=strTemp2%>)</strong></td>
    </tr>
    <tr>
	    <td>&nbsp;</td>
			<%			
			strTemp2 = (String)vWHDetails.elementAt(1) +  ":"  + 
				CommonUtil.formatMinute((String)vWHDetails.elementAt(2));
			strTemp = (String)vWHDetails.elementAt(3);
			if(strTemp.equals("1"))
				strTemp2 += " PM";
			else
				strTemp2 += " AM";
			
			strTemp2 += " - ";

			strTemp2 += (String)vWHDetails.elementAt(4) +  ":"  + 
				CommonUtil.formatMinute((String)vWHDetails.elementAt(5));
			strTemp = (String)vWHDetails.elementAt(6);
			if(strTemp.equals("1"))
				strTemp2 += " PM";
			else
				strTemp2 += " AM";

			if ((String)vWHDetails.elementAt(8) != null){
				strTemp2 +=  " / ";
				
				strTemp2 += (String)vWHDetails.elementAt(8) +  ":"  + 
					CommonUtil.formatMinute((String)vWHDetails.elementAt(9));
				strTemp = (String)vWHDetails.elementAt(10);
				if(strTemp.equals("1"))
					strTemp2 += " PM";
				else
					strTemp2 += " AM";
				
				strTemp2 += " - ";
	
				strTemp2 += (String)vWHDetails.elementAt(11) +  ":"  + 
					CommonUtil.formatMinute((String)vWHDetails.elementAt(12));
				strTemp = (String)vWHDetails.elementAt(13);
				if(strTemp.equals("1"))
					strTemp2 += " PM";
				else
					strTemp2 += " AM";			
			}
			%>
      <td height=30>Current Schedule : <strong><%=strTemp2%></strong></td>
    </tr>
    
    <tr> 
      <td width="4%">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("date_to");
				if(strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
			%>
      <td width="96%" height=30>Effective Date To: 
        <input name="date_to" type="text" class="textbox"  
		onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','date_to','/');"
		onKeyUP= "AllowOnlyIntegerExtn('dtr_op','date_to','/')"
		value="<%=strTemp%>" size="10" maxlength="10"> 
        <a href="javascript:show_calendar('dtr_op.date_to');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
		
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10" colspan="2"><div align="center">
          <input name="image" type="button" onClick="UpdateRecord();" value=" UPDATE ">
          <font size="1">click to update working hour schedule </font> &nbsp; </div></td>
    </tr> 
  </table>
  <%
	}%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25"s>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

  <!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->

	<%
		if(vWHDetails != null && vWHDetails.size() > 0)
			strTemp = (String)vWHDetails.elementAt(14);
	%>

	<input type="hidden" name="date_fr" value="<%=strTemp%>">
	<input type="hidden" name="wh_index" value="<%=WI.fillTextValue("wh_index")%>">
	<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
	<input type="hidden" name="update_record">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
