<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function submitForm() {
	document.form_.reloadPage.value='1';
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";	
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
	
}

function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myID1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myID2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myID3').deleteRow(0);
	
	document.getElementById('myID4').deleteRow(0);
	document.getElementById('myID4').deleteRow(0);	

	window.print();//called to remove rows, make bg white and call print.	
}

</script>

<body bgcolor="#D2AE72">
<%
	String strTemp = null;
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS","lec_lab_unit_uphd.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"lec_lab_unit_uphd.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
Vector vTemp      = null;
ReportEnrollment reportEnrl = new ReportEnrollment();

if(WI.fillTextValue("reloadPage").length() > 0){
	vRetResult = reportEnrl.getUPHUnitEnrolled(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();
	
}

String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
	
%>
<form action="./lec_lab_unit_uphd.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          ENROLMENT STATUS STUDENT LOAD ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID2">
    
	<tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%" height="25">SY-Term </td>
      <td width="84%" height="25"> 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%> 
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
%> 
	<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
	  
	  <select name="semester">
          <option value="1">1st Sem</option><%
strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
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
	  <td>Date Enrolled </td>
	  <td style="font-size:9px;">
      <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a> 
	  to 
	  <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>

	  (enter only Date To value to generate list for AS OF) </td>
    </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td height="25">Course</td>
	  <td height="25"><select name="course_index" style="width:500px;">
        <option value="">All</option>
        <%=dbOP.loadCombo("course_index","course_code,course_name"," from course_offered where IS_DEL=0 and is_valid=1 order by course_code asc",
		  		request.getParameter("course_index"), false)%>
      </select></td>
    </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td height="25" colspan="2">
<%
strTemp = WI.fillTextValue("report_type");
if(strTemp.length() == 0)
	strTemp = "1";
	
if(strTemp.equals("1")) {
	strTemp   = " checked";
	strErrMsg = "";
}else{
	strTemp   = "";
	strErrMsg = " checked";
}%>
	  	<input type="radio" value="1" name="report_type" <%=strTemp%>> Show Report Per Course
	 	<input type="radio" value="2" name="report_type" <%=strErrMsg%>> Show Report Per Year Level
	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="4" align="center">
		
	  <input type="submit" name="Login" value="Generate Report" onClick="submitForm();"></td>
    </tr>
  </table>
  
<%

if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID3">
		<tr><td align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> 
			<font size="1">Click to print report</font>		
		</td></tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr><td align="center"><font size="3"><strong>
			<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
			<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false), ",","")%><br>
				<br><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> 
				<%=WI.fillTextValue("sy_from")%><%=WI.getStrValue(WI.fillTextValue("sy_to"),"-","","")%>
			</td></tr>	
			<tr><td height="15">&nbsp;</td></tr>			
  	</table>
	
	<%if(WI.fillTextValue("report_type").equals("1")){%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr style="font-weight:bold">
				<td width="30%" valign="bottom" height="18" class="thinborder">Course Code</td>
				<td width="8%" valign="bottom" class="thinborder"># Students Enrolled </td>
				<td width="10%" valign="bottom" class="thinborder">Lec Unit </td>
				<td width="10%" valign="bottom" class="thinborder">Lab Unit </td>
				<td width="10%" valign="bottom" class="thinborder">Lec Hour </td>
				<td width="10%" valign="bottom" class="thinborder">Lab Hour </td>
			</tr>
			<%for(int i = 4; i < vRetResult.size(); i += 6) {%>
				<tr>
					<td height="18" class="thinborder"><%=vRetResult.elementAt(i)%></td>
					<td class="thinborder">&nbsp;</td>
					<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 1)).doubleValue(), false)%></td>
					<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 2)).doubleValue(), false)%></td>
					<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 3)).doubleValue(), false)%></td>
					<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 4)).doubleValue(), false)%></td>
				</tr>
			<%}%>
				<tr style="font-weight:bold">
				  <td height="18" class="thinborder" align="right">Grand Total: &nbsp; </td>
				  <td class="thinborder">&nbsp;</td>
				  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(0)).doubleValue(), false)%></td>
				  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(1)).doubleValue(), false)%></td>
				  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(2)).doubleValue(), false)%></td>
				  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(3)).doubleValue(), false)%></td>
		  		</tr>
		</table>
	<%}else{%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr style="font-weight:bold">
				<td width="30%" valign="bottom" height="18" class="thinborder">Course Code</td>
				<td width="8%" valign="bottom" class="thinborder"># Students Enrolled</td>
				<td width="10%" valign="bottom" class="thinborder">Lec Unit </td>
				<td width="10%" valign="bottom" class="thinborder">Lab Unit </td>
				<td width="10%" valign="bottom" class="thinborder">Lec Hour </td>
				<td width="10%" valign="bottom" class="thinborder">Lab Hour </td>
			</tr>
			<%for(int i = 4; i < vRetResult.size(); i += 6) {%>
				<tr style="font-weight:bold">
					<td height="18" class="thinborder"><%=vRetResult.elementAt(i)%></td>
					<td class="thinborder">&nbsp;</td>
					<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 1)).doubleValue(), false)%></td>
					<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 2)).doubleValue(), false)%></td>
					<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 3)).doubleValue(), false)%></td>
					<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 4)).doubleValue(), false)%></td>
				</tr>
				<%
				vTemp = (Vector)vRetResult.elementAt(i + 5);
				if(vTemp.size() == 5)
					continue;
				while(vTemp.size() > 0) {%>
					<tr>
						<td height="18" class="thinborder"><%=WI.getStrValue((String)vTemp.remove(0),"&nbsp;")%></td>
						<td class="thinborder">&nbsp;</td>
						<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vTemp.remove(0)).doubleValue(), false)%></td>
						<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vTemp.remove(0)).doubleValue(), false)%></td>
						<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vTemp.remove(0)).doubleValue(), false)%></td>
						<td class="thinborder"><%=CommonUtil.formatFloat(((Double)vTemp.remove(0)).doubleValue(), false)%></td>
					</tr>
				<%}%>
			<%}%>
				<tr style="font-weight:bold">
				  <td height="18" class="thinborder" align="right">Grand Total: &nbsp; </td>
				  <td class="thinborder">&nbsp;</td>
				  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(0)).doubleValue(), false)%></td>
				  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(1)).doubleValue(), false)%></td>
				  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(2)).doubleValue(), false)%></td>
				  <td class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(3)).doubleValue(), false)%></td>
		  		</tr>
  		</table>
	<%}%>
		
<%}%>
	
	
	
  
  
  

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="summary_of_roe" value="<%=WI.fillTextValue("summary_of_roe")%>">
<input type="hidden" name="reloadPage">
</form>


<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>