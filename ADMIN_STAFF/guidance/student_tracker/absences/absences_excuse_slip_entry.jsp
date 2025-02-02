<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
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
<!--
function StudSearch() {
	var pgLoc = "../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID()
{
	document.form_.stud_id.focus();
}
-->
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDAbsence, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	Vector vBasicInfo = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;

	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Student Tracker-Absences","absences_excuse_slip_entry.jsp");
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
														"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"STUDENT AFFAIRS","Student Tracker",request.getRemoteAddr(), null);
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
boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");

//end of authenticaion code.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
if(WI.fillTextValue("stud_id").length() > 0) 
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));

if (vBasicInfo !=null && vBasicInfo.size()>0) {
	if(vBasicInfo.elementAt(7) == null)
		bolIsBasic = true;
		
	GDAbsence GDAbsent = new GDAbsence();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(GDAbsent.operateOnAbsence(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = GDAbsent.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = GDAbsent.operateOnAbsence(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = GDAbsent.getErrMsg();
	}

			
	vRetResult = GDAbsent.operateOnAbsence(dbOP, request, 4);
	
	if (strErrMsg == null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = GDAbsent.getErrMsg();
}
else 
	strErrMsg = OAdm.getErrMsg();
%>
<body bgcolor="#D2AE72" onLoad="FocusID()">
<form name="form_" action="./absences_excuse_slip_entry.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EXCUSE SLIP ENTRY FORM 
          PAGE::::</strong></font></div></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="2%"><p>&nbsp;</p></td>
      <td width="17%">School Year</td>
      <td colspan="2">
      <%
      strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
        <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
	<%strTemp = WI.fillTextValue("sy_to");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
	<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
	/
	<select name="semester">
 		 <%
		strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0 )
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		%>
		<%=dbOP.loadSemester(bolIsBasic, strTemp, request)%>
	</select>
	</td>
   </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Student ID</td>
      <td width="31%" height="25"><%strTemp = WI.fillTextValue("stud_id");%>
     <input name="stud_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      <a href="javascript:StudSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="50%" height="25"><a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
	 <tr> 
      <td height="25" colspan="4"> <hr size="1"></td>
    </tr>
  <%if (vBasicInfo!= null && vBasicInfo.size()>0){
	strTemp =(String)vBasicInfo.elementAt(19);
    %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Student Name :<strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></td>
      <td height="25">Gender : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(16),"Not defined")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Brithdate : <strong><%=WI.getStrValue(strTemp, "Undefined")%></strong></td>
      <td height="25">Age :<strong><%if (strTemp !=null && strTemp.length()>0){%><%=CommonUtil.calculateAGEDatePicker(strTemp)%><%}else{%>Undefined<%}%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Course/Major : 
	  <%if(bolIsBasic) {%>
	  <strong><%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vBasicInfo.elementAt(14)))%></strong>
	  <%}else{%>
	  <strong><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></strong>
	  <%}%>
	  </td>
    </tr>
<%if(!bolIsBasic){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Year Level : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
<%}%>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
    </table>
   
     <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="17%">Date Absent : </td>
      <td height="25" width="20%">
        <%
       if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		else		
			strTemp = WI.fillTextValue("date_absent_fr");
		 if (strTemp == null || strTemp.length()==0)
        	  	strTemp = WI.getTodaysDate(1);%>
		<input name="date_absent_fr" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.date_absent_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td height="25" width="50%"><%
       if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(2),"");
		else		
			strTemp = WI.fillTextValue("date_absent_to");%>
		<input name="date_absent_to" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.date_absent_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
      <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Subject:<input type="text" name="filter_sub" value='<%=WI.fillTextValue("filter_sub")%>' class="textbox" 
			onKeyUp="AutoScrollListSubject('filter_sub','sub_code',true,'form_');">
        (scroll subject) <div align="right"></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">
      <%
       if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(3),"");
		else		
			strTemp = WI.fillTextValue("sub_code");
      %>
      <select name="sub_code" style="font-size:10px">
	  <%if(bolIsBasic)
	  		strTemp = " 2";
	   	else
			strTemp = " 0";
	  %>
          <%=dbOP.loadCombo("sub_index","sub_code+'&nbsp;&nbsp; ('+sub_name+')' as sub_list"," from subject where IS_DEL="+strTemp+" order by sub_list asc", WI.fillTextValue("sub_code"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom">Time : <%
       if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(5),"");
		else		
			strTemp = WI.fillTextValue("absent_time");%>
     <input name="absent_time" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom">Reasons : <%
       if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
		else		
			strTemp = WI.fillTextValue("absent_reason");%></td>
    </tr>
    <tr> 
      <td height="71">&nbsp;</td>
      <td height="71" colspan="3">
    <textarea name="absent_reason" cols="40" rows="4" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>
       </td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="48">&nbsp;</td>
      <td height="48" colspan="3"><font size="1"><strong>RECOMMENDATIONS: </strong>
        <%if (strPrepareToEdit.compareTo("1")==0){%><a href='./recommendation.jsp?absent_index=<%=((String)vEditInfo.elementAt(0))%>' target="_blank">
	  <img src="../../../../images/update.gif" border="0"></a> 
        click to update the recommendations for this student<%}else{%>edit case
        to access this area<%}%></font></td>
    </tr>
    <tr> 
      <td height="60" colspan="4" valign="middle"><div align="center"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%></font></div></td>
    </tr>
     <%}%>
  </table>
  <%if (vRetResult!=null && vRetResult.size()>0 && vBasicInfo != null) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#D8D569"> 
      <td height="25" colspan="5" class="thinborder"><div align="center">EXCUSE SLIP FORM ENTRIES 
          FOR <strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></div></td>
    </tr>
    <tr> 
      <td height="25" width="25%" class="thinborder"><div align="center"><font size="1"><strong>DATE OF ABSENCE</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT / TIME</strong></font></div></td>
      <td width="40%" class="thinborder"><div align="center"><font size="1"><strong>REASON</strong></font></div></td>
      <td colspan="2" class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
    <%for (int i=0; i<vRetResult.size(); i+=11){%>
    <tr>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%><%=WI.getStrValue((String)vRetResult.elementAt(i+2)," to ","","&nbsp;")%></font></td>
      <td class="thinborder"><font size="1">Subject: <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"Not Defined")%><br>
      	  Time: <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"Not Defined")%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+6)%></font></td>
      <td width="7%" class="thinborder"><% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/edit.gif" border="0"></a> 
        <%}else{%>&nbsp;<%}%></td>
      <td width="8%" class="thinborder"><% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../../images/delete.gif" border="0"></a> 
        <%}else{%>&nbsp;<%}%></td>
    </tr>
    <%}%>
  </table>
  <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="3%" height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#A49A6A"> 
    <td height="25">&nbsp;</td>
  </tr>
</table>
	<input name="info_index" type ="hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
	<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>