<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strIndex, strAction) {
	if(strIndex.length > 0)
		document.form_.index.value = strIndex;
	document.form_.page_action.value = strAction;
	document.form_.edit_clicked.value = "";

	this.SubmitOnce('form_');
}
function PrepareToEdit(strIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.index.value = strIndex;
	document.form_.edit_clicked.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.index.value = "";
	document.form_.edit_clicked.value = "";

	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.edit_clicked.value = "";
	document.form_.page_action.value = "";

	this.SubmitOnce('form_');
}
//function goToNextSearchPage() {

//}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ApplicationSchedule,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ADMISSION SCHEDULING","admission_sched.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","ADMISSION SCHEDULING",request.getRemoteAddr(),
														"admission_sched.jsp");
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
	ApplicationSchedule appSch = new ApplicationSchedule();
	Vector vRetResult = null;
	Vector vEditInfo  = null;

strTemp = WI.fillTextValue("page_action");
String strInfoIndex = WI.fillTextValue("index");

if(strTemp.length() > 0) {
	//add it here and give a message.
	if(strTemp.compareTo("1") == 0) {
		if(appSch.add(dbOP,request)) {
			strErrMsg = "Schedule added successfully.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = appSch.getErrMsg();
	}
	else if(strTemp.compareTo("0") == 0) {//remove
		if(appSch.delete(dbOP,strInfoIndex,(String)request.getSession(false).getAttribute("login_log_index")))
			strErrMsg = "Schedule removed successfully.";
		else
			strErrMsg = appSch.getErrMsg();
	}
	else if(strTemp.compareTo("2") == 0) {//remove
		if(appSch.edit(dbOP,request)) {
			strErrMsg = "Schedule changed successfully.";
			strPrepareToEdit= "0";
		}
		else
			strErrMsg = appSch.getErrMsg();
	}

}
//if edit is called, i have to set vEditInfo;
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = appSch.view(dbOP,strInfoIndex);
	if(vEditInfo == null && strErrMsg == null)
		strErrMsg = appSch.getErrMsg();
	
}
int iSearchResult = 0;
vRetResult = appSch.viewAllSchedule(dbOP,request);
iSearchResult = appSch.iSearchResult;

boolean bolShowEdit = false;
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("edit_clicked").length() > 0) {
	bolShowEdit = true;
}
%>
<form name="form_" method="post" action="./admission_sched.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
          ADMISSION SCHEDULING PAGE::::</font></strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Schedule admission by</td>
      <td width="78%"> <%
if(vEditInfo == null) {%> <select name="schedule_by" onChange="ReloadPage();">
          <option value="0">Specific course</option>
          <%
 strTemp = WI.fillTextValue("schedule_by");
 if(strTemp.compareTo("1") ==0){
 %>
          <option value="1" selected>All courses</option>
          <%}else{%>
          <option value="1">All courses</option>
          <%}%>
        </select> <%}%> </td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="18%">Admission for course </td>
      <td> 
<%
if(bolShowEdit)
	strTemp = (String)vEditInfo.elementAt(0);
else 
	strTemp = request.getParameter("course_offered");
%>
	  <%if(!WI.fillTextValue("schedule_by").equals("1")){%> <select name="course_offered">
          <%=dbOP.loadCombo("COURSE_INDEX","COURSE_NAME"," from COURSE_OFFERED where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 and is_visible = 1 order by COURSE_NAME asc", strTemp, true)%> 
        </select> <%}else{%>
        ALL 
        <%}%> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Year level </td>
      <td height="25"><select name="year_level">
          <option value="">ALL Year Level</option>
<%
if(bolShowEdit)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("year_level");
if(strTemp == null)
	strTemp = "";

if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3" >3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}
		  
		  if (strSchCode.startsWith("CPU")){
			  if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
	          <%}else{%>
          <option value="6">6th</option>
    	      <%}
			} 
		  %>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Term</td>
      <td height="25"><select name="semester">
          <option value="">ALL Semester</option>
<%
if(bolShowEdit)
	strTemp = (String)vEditInfo.elementAt(2);
else	
strTemp = WI.fillTextValue("semester");
if(strTemp == null)
	strTemp = "";
		   if(strTemp.equals("1"))
		  {%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}
  	   if (!strSchCode.startsWith("CPU")) { 
		  if(strTemp.equals("3")){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.equals("4")){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.equals("5")){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}
		  } // removed 3rd and 4th sem
		  
		  if(strTemp.equals("0")){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Admission start date</td>
      <td height="25">
<%
if(bolShowEdit)
	strTemp = (String)vEditInfo.elementAt(3);
else	
strTemp = WI.fillTextValue("start_date");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="start_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.start_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Admission end date</td>
      <td height="25">
<%
if(bolShowEdit)
	strTemp = (String)vEditInfo.elementAt(4);
else	
strTemp = WI.fillTextValue("end_date");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="end_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.end_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="43">&nbsp;</td>
      <td height="43">&nbsp;</td>
      <td height="43" valign="bottom"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0 && iAccessLevel > 1) {%>
        <a href='javascript:PageAction("",1);'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save entries 
        <%}else if(iAccessLevel > 1){%>
        <a href='javascript:PageAction("",2);'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font> </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" class="thinborderALL">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="7" align="center"><strong><font size="1">LIST OF 
        SET ADMISSION SCHEDULES</font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr>
      <td width="67%" height="25" class="thinborderLEFT"><b><font size="2" face="Verdana, Arial, Helvetica, sans-serif"> 
       &nbsp;Total Schedules : <%=iSearchResult%> - Showing(<%=appSch.strDispRange%>)</font></b></td>
      <td width="33%" class="thinborderRIGHT">&nbsp;
	  <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/appSch.defSearchSize;
		if(iSearchResult % appSch.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
		<div align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Jump
          To page: </font>
          <select name="jumpto" onChange="ReloadPage();">

		<%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
					<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}else{%>
					<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%
					}
			}
			%>
			 </select>

		<%}%>

        </div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="35%" height="25" align="center" class="thinborder"><strong><font size="1">COURSE</font></strong></td>
      <td width="6%" height="25" align="center" class="thinborder"><strong><font size="1"> YEAR </font></strong></td>
      <td width="9%" height="25" align="center" class="thinborder"><strong><font size="1">SEMESTER</font></strong></td>
      <td width="16%" height="25" align="center" class="thinborder"><strong><font size="1">START 
        DATE</font></strong></td>
      <td width="12%" height="25" align="center" class="thinborder"><strong><font size="1">END DATE</font></strong></td>
      <td height="25" colspan="2" align="center" class="thinborder">&nbsp;</td>
    </tr>
    <%
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","5th Sem","ALL"};
String[] astrConvertYr  = {"ALL","1st","2nd","3rd","4th","5th","6th","7th","8th"};
for(int i = 0 ; i< vRetResult.size(); ++i) {%>
    <tr> 
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"ALL")%>&nbsp;</font></td>
      <td class="thinborder"><font size="1"><%=astrConvertYr[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2),"0"))]%>&nbsp;</font></td>
      <td class="thinborder"><font size="1"><%=astrConvertSem[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"6"))]%>&nbsp;</font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+4)%>&nbsp;</font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+5)%>&nbsp;</font></td>
      <td width="11%" class="thinborder"> <font size="1"> 
        <%if(iAccessLevel == 2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/edit.gif" border=0></a> 
        <%}else{%>
        Not authorized to edit 
        <%}%>
        </font></td>
      <td width="11%" class="thinborder"> <font size="1"> 
        <%if(iAccessLevel == 2){%>
        <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0")'><img src="../../../images/delete.gif" border=0></a> 
        <%}else{%>
        Not authorized to delete 
        <%}%>
        </font></td>
    </tr>
    <%
	i = i+6;
}%>
  </table>
 <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
      </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
 <input type="hidden" name="index" value="<%=WI.fillTextValue("index")%>">
 <input type="hidden" name="page_action">
 <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
 <input type="hidden" name="edit_clicked"><!-- set this for first time edit is clicked-->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>