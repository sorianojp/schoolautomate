<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function UpdateRecord()
{
	document.form_.close_wnd_called.value = "1";
	document.form_.page_action.value = "1";
	this.SubmitOnce('form_');
}

function ReloadParentWnd() {

	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		if (window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.searchApplicant){
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.searchApplicant.value = 1;
		}

		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
		window.opener.focus();
	}
}

function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	if (window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.searchApplicant)
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.searchApplicant.value = 1;
	
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();
}


</script>
<body bgcolor="#D2AE72"   onUnload="ReloadParentWnd();">
<%
	Vector vExamResults  = null;
	Vector vApplicantData = null;
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-EXAMINATION SCHEDULING","applicant_status_update.jsp");
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
														"Admission Maintenance","EXAMINATION SCHEDULING",request.getRemoteAddr(),
														"applicant_status_update.jsp");
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
	ApplicationMgmt appMgmt = new ApplicationMgmt();
		
//	request.setAttribute("temp_id",request.getParameter("temp_id"));
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(appMgmt.operateOnApplicantStatus(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";			
		}
		else
			strErrMsg = appMgmt.getErrMsg();
	}		
	vExamResults = appMgmt.operateOnApplicantStatus(dbOP, request, 3);
	vApplicantData = appMgmt.operateOnApplicantStatus(dbOP, request, 4);		
%>
<form name="form_" method="post" action="./applicant_status_update.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td height="25" colspan="2"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
          APPLICANT STATUS PAGE::::</font></strong></div></td>
    </tr>
    <tr> 
      <td width="87%" height="25" bgcolor="#FFFFFF"><font size="3"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
      <td width="13%" bgcolor="#FFFFFF">	 
	 <% if (WI.fillTextValue("opner_form_name").length() > 0){%>
	  <a href="javascript:CloseWindow();">
	  		<img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a>
	 <%}%>		</td>
    </tr>	
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td height="25" colspan="2">Applicant Name : <strong><%=WI.formatName((String)vApplicantData.elementAt(0), (String)vApplicantData.elementAt(1), (String)vApplicantData.elementAt(2),7)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Date Applied : <strong><%=((String)vApplicantData.elementAt(3))%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Course/Major Applied : <strong><%=WI.getStrValue(WI.getStrValue((String)vApplicantData.elementAt(5),((String)vApplicantData.elementAt(4)) + "/","",
	  (String)vApplicantData.elementAt(4)),"Not Available")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%String [] strAppStat = {"Denied", "Approved", "Under further evaluation"}; %>
      <td width="52%" height="25">Current Application Status : <strong>
      <%if((String)vApplicantData.elementAt(6)!= null){%><%=strAppStat[Integer.parseInt((String)vApplicantData.elementAt(6))]%><%} else {%>Not Available<%}%></strong></td>
      <td width="45%">Status Updated : <strong>
      <%if((String)vApplicantData.elementAt(7)!= null){%><%=((String)vApplicantData.elementAt(7))%><%} else {%>Not Updated<%}%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="6"><div align="center"><strong><font color="#FFFFFF">PERFORMANCE 
          LIST </font></strong></div></td>
    </tr>
    <tr> 
      <td width="34%" height="25"><div align="center"><strong><font size="1">ENTRANCE 
      EXAM NAME</font></strong></div></td>
      <td width="17%"><div align="center"><strong><font size="1">DATE TAKEN</font></strong></div></td>
      <td width="11%"><div align="center"><strong><font size="1">SCORE/RATE</font></strong></div></td>
      <td width="14%"><div align="center"><strong><font size="1">MAXIMUM SCORE/ 
      RATE</font></strong></div></td>
      <td width="13%"><div align="center"><b><font size="1">PASSING SCORE/RATE</font></b></div></td>
      <b> </b> 
      <td align="center"><strong><font size="1">REMARKS</font></strong></td>
    </tr>
 <%   for (int i = 0;i<vExamResults.size();){ %>
      <tr> 
      <td height="25"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i)%></font></div></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i+1)%></font></div></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i+2)%></font></div></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i+3)%></font></div></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vExamResults.elementAt(i+4)%></font></div></td>
      <td width="11%" height="25" align="center"><font size="1"><%=(String)vExamResults.elementAt(i+5)%></font></td>
    </tr>
   	<% i = i + 6;
   	} //for (int i = 0;i<vExamResults.size();)%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
    </tr>
    <tr> <%if (WI.fillTextValue("can_update").compareTo("1")==0){%>
      <td width="28%">&nbsp;</td>
      <td height="25" width="28%"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Update 
        Applicant Status to : </font></td>
      <td ><font size="2" face="Verdana, Arial, Helvetica, sans-serif"> 
        <select name="exam_result" id="exam_result">
          <option value="1">Approved</option>
          <option value="0">Denied</option>
          <option value="2">Evaluation in Process</option>
        </select>
        </font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="28%" height="25"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Status 
        updated on :</font><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp; 
        </font></td>
      <td width="50%"><input name="upd_on" type="text" class="textbox" size="10" maxlength="10" readonly="yes">
      <a href="javascript:show_calendar('form_.upd_on');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30" colspan="3"><div align="center"><a href='javascript:UpdateRecord();'><img src="../../../images/save.gif" border="0"></a><font size="1">click 
          to save changes</font></div></td>
    </tr>
	<%}%>
  </table>
  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="temp_id" value="<%=WI.fillTextValue("temp_id")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="stud_index" value="<%=WI.fillTextValue("stud_index")%>">
<input type="hidden" name="can_update" value="<%=WI.fillTextValue("can_update")%>">

  <input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">	
	
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
<!-- this is very important - onUnload do not call close window -->	

</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>