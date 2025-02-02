<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
</head>
<script language="javascript"  src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript">
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}
function PageAction(strAction) {
	if(strAction == "0"){
		if(!confirm("Do you want to delete this exam schedule?"))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.reload_page.value = "1";
	this.SubmitOnce('form_');
}

function ReloadPage()
{
    document.form_.page_action.value="";
	document.form_.reload_page.value = "1";
	this.SubmitOnce('form_');
}

function CopyDate(strValue){
	document.form_.copy_date_of_exam.value = strValue;
	this.ReloadPage();
}


</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	Vector vRetResult = null;
	Vector vExamName  = null;
	Vector vEditInfo  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	String strPrepareToEdit = null;
	boolean bolErrorInEdit = false;
	int iMaxDisp = 0;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";
			
	int iTemp = 0;
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW","copy_exam_sched.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",request.getRemoteAddr(),
														"copy_exam_sched.jsp");
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
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(appMgmt.copyExamSchedule(dbOP, request, Integer.parseInt(strTemp))){
			if(strTemp.equals("1"))
				strErrMsg = "Schedule successfully copied.";	
			if(strTemp.equals("0"))
				strErrMsg = "Schedule successfully deleted.";	
		}else
			strErrMsg = appMgmt.getErrMsg();
	}
	
if(WI.fillTextValue("reload_page").length() > 0 && WI.fillTextValue("copy_date_of_exam").length() > 0){
	vRetResult = appMgmt.getExamScheduleByDate(dbOP, request);
	if(vRetResult == null)
		strErrMsg = appMgmt.getErrMsg();
}

String strSYFrom = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");
Vector vDateOfExamList = new Vector();
if(strSYFrom.length() > 0 && strSemester.length() > 0){
	strTemp = 
		" select distinct DATE_OF_EXAM from na_exam_sched where is_valid =1 and SY_FROM = "+strSYFrom+
		" and SEMESTER = "+strSemester+
		" order by DATE_OF_EXAM desc ";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vDateOfExamList.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(1)));
	}rs.close();

	if(vDateOfExamList.size() == 0)
		strErrMsg = "Examination detail not found.";
		
}


%>
<form name="form_" action="./copy_exam_sched.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF">:::: 
          COPY EXAM SCHEDULE PAGE::::</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%> </strong></font></td>
    </tr>
    <tr>
        <td width="4%" height="25">&nbsp;</td>
        <td width="16%">School Year / Term</td>
        <td colspan="2">
<% 
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %> <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %> <input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        / 
        <select name="semester">
          <% strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected="selected">1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")) {
	  	   if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }%>
      </select>
	  	&nbsp; &nbsp;
		<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  
	  </td>
        </tr>
<%if(vDateOfExamList != null && vDateOfExamList.size() > 0){%>
	<tr><td>&nbsp;</td>
		<td colspan="5" valign="top">
			<div onClick="showBranch('branch1');swapFolder('folder1')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
          <b><font color="#0000FF">List of Exam Date(Descending Order)</font></b></div>
		   <span class="branch" id="branch1">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td valign="top" width="25%">
			
						<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
							<%
							int iCount =  0;
							for(int i = 0; i < vDateOfExamList.size(); i+=2){
								
							%>
							<tr>
								<td height="18">
								<input type="radio" name="date_of_exam_<%=++iCount%>" onClick="CopyDate('<%=vDateOfExamList.elementAt(i)%>')"><%=vDateOfExamList.elementAt(i)%>
								</td>
							</tr>
							<%}%>
						</table>			
					</td>
					<td valign="top">
						<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
							<%
							
							for(int i = 1; i < vDateOfExamList.size(); i+=2){
								
							%>
							<tr>
								<td height="18">
								<input type="radio" name="date_of_exam_<%=++iCount%>" onClick="CopyDate('<%=vDateOfExamList.elementAt(i)%>')"><%=vDateOfExamList.elementAt(i)%>
								</td>
							</tr>
							<%}%>
						</table>			
					</td>
				</tr>
			</table>
			</span>
		</td>
		
	</tr>

    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="16%">Exam Schedule</td>      
      <td width="15%"> <input name="copy_date_of_exam" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("copy_date_of_exam")%>" 
	  readonly="yes"> 
      <a href="javascript:show_calendar('form_.copy_date_of_exam');" title="Click to select date" 
	  onMouseOver="window.status='Select date';return true;" 
	  onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td width="65%"></td>
    </tr>
<%}%>    
  </table>
<% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
        <td height="23" align="right">&nbsp;</td>
    </tr>
    <tr> 
      <td height="23" align="right">Copy to 
          <% 
strTemp = WI.fillTextValue("copy_sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %> 
<input name="copy_sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","copy_sy_from","copy_sy_to")'>
        to 
<%  
strTemp = WI.fillTextValue("copy_sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %> 
<input name="copy_sy_to" type="text" size="4" maxlength="4" 
		value="<%=strTemp%>" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        / 
        <select name="copy_sy_sem">
<% 
strTemp = WI.fillTextValue("copy_sy_sem");
if(strTemp.length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected="selected">1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")) {
	  	   if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }%>
      </select>	  
	  &nbsp; &nbsp; &nbsp; &nbsp;
	  Date 
	  &nbsp; &nbsp;
	  <input name="date_from" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("date_from")%>" 
	  readonly="yes"> 
      <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" 
	  onMouseOver="window.status='Select date';return true;" 
	  onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  &nbsp; &nbsp;
	  to
	  &nbsp; &nbsp;
	  <input name="date_to" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("date_to")%>" 
	  readonly="yes"> 
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
	  onMouseOver="window.status='Select date';return true;" 
	  onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  &nbsp; &nbsp;
	  <a href="javascript:PageAction('1');"><img src="../../../images/copy.gif" border="0"></a>
	  <font size="1">click to copy schedule</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="9" class="thinborder"><div align="center"><strong><font color="#FFFFFF" size="1">LIST 
          OF EXAMINATION/INTERVIEW SCHEDULES FOR : <%=WI.fillTextValue("copy_date_of_exam")%></font></strong></div></td>
    </tr>
    <tr> 
      <td width="12%" height="20" class="thinborder"><div align="center"><strong><font size="1">SCHEDULING 
          TYPE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">SCHEDULE 
          CODE</font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">DURATION 
          (MIN)</font></strong></div></td>      
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">START 
          TIME</font></strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><b>VENUE</b></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><b>CONTACT 
          INFORMATION</b></font></div></td>      
    </tr>
    <%
	String [] astrConvType={"Written","Interview"};
	String [] astrConvTime={" AM"," PM"};
for(int i = 0 ; i< vRetResult.size(); ++i, ++iMaxDisp)
{%>
    <tr> 
      <td class="thinborder"><div align="center"><%=astrConvType[Integer.parseInt((String)vRetResult.elementAt(i + 16))]%> ::: <%=(String)vRetResult.elementAt(i+17)%></div></td>
      <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(i+4))%></div></td>
      <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(i+5))%></div></td>      
      <td class="thinborder"><div align="center"><%=CommonUtil.formatMinute((String)vRetResult.elementAt(i+6))+':'+
	  CommonUtil.formatMinute((String)vRetResult.elementAt(i+7))+astrConvTime[Integer.parseInt((String)vRetResult.elementAt(i + 8))]%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+10)%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+18)%> <br>
          <font color="#0000FF"><%=(String)vRetResult.elementAt(i+12)%></font></div></td>
      
    </tr>
    <%
	i = i+18;
}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr><td align="center"><a href="javascript:PageAction('0');"><img src="../../../images/delete.gif" border="0"></a>
	<font size="1">Click to delete all exam schedule</font>
	</td></tr>
  </table>
 <%}//if vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

	
	<input type="hidden" name="reload_page" value="">
    <input type="hidden" name="page_action" >
	<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
</form>
</body>
</html>
<% dbOP.cleanUP();
%>