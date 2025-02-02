<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function ViewDetails(strInfoIndex, strStudIndex)
{
	var pgLoc = "./view_dtls_psych_cases.jsp?stud_id="+strStudIndex+"&info_index="+strInfoIndex+"&psyc_res_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
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
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ExaminerSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.examiner_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReferralSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.ref_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID()
{
	document.form_.stud_id.focus();
}
-->
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDPsychological, java.util.Vector " buffer="16kb"%>
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
	String[] astrSemester = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Psychological Cases-Add/Create","add_psych_cases.jsp");
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
														"Guidance & Counseling","Psychological Cases",request.getRemoteAddr(),
														"add_psych_cases.jsp");
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
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
if(WI.fillTextValue("stud_id").length() > 0) 
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));

if (vBasicInfo !=null && vBasicInfo.size()>0)
{
	GDPsychological GDPsych = new GDPsychological();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(GDPsych.operateOnPsychCase(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = GDPsych.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = GDPsych.operateOnPsychCase(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = GDPsych.getErrMsg();
	}
			
	vRetResult = GDPsych.operateOnPsychCase(dbOP, request, 4);
	
	if (strErrMsg == null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = GDPsych.getErrMsg();
}
else 
	strErrMsg = OAdm.getErrMsg();
%>
<body bgcolor="#663300" onload="FocusID()">
<form action="./add_psych_cases.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: ADD PSYCHOLOGICAL CASES PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td colspan="3" height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
      
    </tr>
    <tr> 
      <td width="5%"><p>&nbsp;</p></td>
      <td width="95%" colspan="2">School Year / Term: 
        <%if (vEditInfo != null && vEditInfo.size()>0)
	        strTemp = (String)vEditInfo.elementAt(1);
        else
       		 strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
        <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%if (vEditInfo != null && vEditInfo.size()>0)
	        strTemp = (String)vEditInfo.elementAt(2);
        else
			strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
/
<select name="semester">
  <%if (vEditInfo != null && vEditInfo.size()>0)
	        strTemp = (String)vEditInfo.elementAt(3);
        else
			strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}if(strTemp.compareTo("1") ==0){%>
  <option value="1" selected>1st Sem</option>
  <%}else{%>
  <option value="1">1st Sem</option>
  <%}if(strTemp.compareTo("2") == 0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") == 0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}%>
</select></td>      
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" width="50%">Student ID &nbsp;: 
        <%strTemp = WI.fillTextValue("stud_id");%>
     <input name="stud_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">  </td>
      <td height="25" width="45%"><a href="javascript:StudSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      <font size="1">click to search for student ID</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
    <%if (vBasicInfo!= null && vBasicInfo.size()>0){
	strTemp =(String)vBasicInfo.elementAt(19);
    %>
    <tr> 
      <td height="25" colspan="3"> <div align="right"> 
          <hr size="1">
        </div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Student Name :<strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></td>
      <td height="25">Gender : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(16),"Not defined")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Brithdate : <strong><%=WI.getStrValue(strTemp, "Undefined")%></strong></td>
      <td height="25">Age :<strong><%if (strTemp !=null && strTemp.length()>0){%><%=CommonUtil.calculateAGEDatePicker(strTemp)%><%}else{%>Undefined<%}%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Course/Major : <strong><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Year Level : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Place of Examination : 
       <%
      if (vEditInfo != null && vEditInfo.size()>0)
    		strTemp= (String)vEditInfo.elementAt(5);
	      else
    	   strTemp = WI.fillTextValue("location");%>
     <input name="location" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="64" maxlength="128"></td>
      <td height="25">Date of Examination : 
        <%
       if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
		else		
			strTemp = WI.fillTextValue("exam_date");

		 if (strTemp == null || strTemp.length()==0)
        	  	strTemp = WI.getTodaysDate(1);
		%>
		<input name="exam_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.exam_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
    </tr>    
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Examined by (ID number) : 
          <%
        if (vEditInfo != null && vEditInfo.size()>0)
    	    strTemp = (String)vEditInfo.elementAt(11);
        else
	        strTemp = WI.fillTextValue("examiner_id");%>
     <input name="examiner_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
	  <a href="javascript:ExaminerSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      <font size="1">click to search for employee ID</font>
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Date of Report : 
                <%
       if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(15);
		else		
			strTemp = WI.fillTextValue("report_date");

		 if (strTemp == null || strTemp.length()==0)
        	  	strTemp = WI.getTodaysDate(1);
		%>
		<input name="report_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.report_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
      <td height="25">Tests Administered : <font size="1">
        <%if (strPrepareToEdit.compareTo("1")==0){%><a href='./tests.jsp?psyc_res_index=<%=((String)vEditInfo.elementAt(0))%>' target="_blank">
	  <img src="../../../images/update.gif" border="0"></a> 
        click to update Tests Administered to this student<%}else{%>edit case
        to access this area<%}%></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Referred by (ID number) : 
         <% 
          if (vEditInfo != null && vEditInfo.size()>0)
    		strTemp= (String)vEditInfo.elementAt(7);
	      else
    	     strTemp = WI.fillTextValue("ref_id");%>
     <input name="ref_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
	  <a href="javascript:ReferralSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      <font size="1">click to search for employee ID</font>
      </td>
    </tr>
    <tr> 
      <td height="44">&nbsp;</td>
      <td height="44" colspan="2" valign="middle">Reason for Referral : <font size="1">
        <%if (strPrepareToEdit.compareTo("1")==0){%><a href='./referral.jsp?psyc_res_index=<%=((String)vEditInfo.elementAt(0))%>' target="_blank">
	  <img src="../../../images/update.gif" border="0"></a>  
        click to update reasons for referral to this student<%}else{%>edit case
        to access this area<%}%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <% 
      if (vEditInfo != null && vEditInfo.size()>0)
    		strTemp= (String)vEditInfo.elementAt(16);
      else
	        strTemp = WI.fillTextValue("result");%>
      <td height="25">Results and Interpretations :<br> <textarea name="result" cols="30" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
      <%
      if (vEditInfo != null && vEditInfo.size()>0)
    		strTemp= (String)vEditInfo.elementAt(17);
      	else
        	strTemp = WI.fillTextValue("conclusion");%>
      <td height="25">Conclusions and Recommendations :<br> <textarea name="conclusion" cols="30" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="60">&nbsp;</td>
      <td height="60" colspan="2" valign="bottom"><div align="center"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
	  <%}%>
<%if (vRetResult != null && vRetResult.size()>0 && vBasicInfo != null){%>	  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#A9C0CD"> 
      <td height="25" colspan="9" class="thinborder">
        <div align="center"><font color="#FFFFFF"><strong>SUMMARY OF PSYCHOLOGICAL 
          REPORT </strong></font></div></td>
    </tr>
    <tr> 
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>SY/TERM</strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>DATE OF EXAM</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>EXAMINED 
          BY </strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>RESULTS &amp; 
          INTERPRETATIONS</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong><font size="1">CONCLUSIONS AND 
          RECOMMNEDATIONS </font></strong></div></td>
      <td width="16%" class="thinborder" colspan="3"><div align="center"><strong><font size="1">OPTIONS </font></strong></div></td>
    </tr>
    <%for (int i = 0; i< vRetResult.size(); i+=18){%>
    <tr> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;-&nbsp;<%=(String)vRetResult.elementAt(i+2)%><br><%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+3))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
      <td class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+12), (String)vRetResult.elementAt(i+13), (String)vRetResult.elementAt(i+14),7)%></td>
      <td class="thinborder"><%strTemp = (String)vRetResult.elementAt(i+16);
      if (strTemp.length()>20){%>
      <%=strTemp.substring(0,20)%>...more<%}else{%><%=strTemp%><%}%></td>
      <td class="thinborder"><%strTemp = (String)vRetResult.elementAt(i+17);
      if (strTemp.length()>20){%>
      <%=strTemp.substring(0,20)%>...more<%}else{%><%=strTemp%><%}%></td>
      <td width="5%" class="thinborder"><a href='javascript:ViewDetails(<%=((String)vRetResult.elementAt(i))%>, "<%=((String)vRetResult.elementAt(i+4))%>")'>
	  <img src="../../../images/view.gif" width="40" height="31" border="0"></a></td>
      <td width="5%" class="thinborder"><font size="1"><% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized to edit 
        <%}%></font></td>
      <td width="6%" class="thinborder"><font size="1"> <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized to delete 
        <%}%></font></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><div align="center"> </div></td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
