<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	
	this.SubmitOnce('form_');
}
function FocusID() {
	document.form_.stud_id.focus();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,student.ChangeCriticalInfo,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Payments-ASSESSMENT-fixed tuition fee entry.","fixed_tuition_entry_info.jsp");
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
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"fixed_tuition_entry_info.jsp");
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
Vector vRetResult = null;
Vector vStudInfo  = null;//current enrollment information.
	
ChangeCriticalInfo criticalInfo = new ChangeCriticalInfo();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(criticalInfo.operateOnEntryInfoForFixedTuition(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = criticalInfo.getErrMsg();
	else	
		strErrMsg = "Operation is successful.";
}
if(WI.fillTextValue("stud_id").length() > 0) {
	enrollment.FAPaymentUtil pmtUtil = new enrollment.FAPaymentUtil();
	vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
	if(vStudInfo == null)
		strErrMsg = pmtUtil.getErrMsg();
}
if(vStudInfo != null) {
	vRetResult = criticalInfo.operateOnEntryInfoForFixedTuition(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = criticalInfo.getErrMsg();
}	
%>
<form action="./fixed_tuition_entry_info.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENT ENTRY INFORMATION UPDATE PAGE (FOR FIXED TUTION FEE) ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%"></td>
	  <td width="98%" > <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%" >Student ID :</td>
      <td width="23%" ><input type="text" name="stud_id" size="18" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      </td>
      <td width="62%" height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="28" height="23" border="0"></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" >Entry Status</td>
      <td width="83%"><select name="entry_status">
          <%strTemp = WI.fillTextValue("entry_status");%>
          <%=dbOP.loadCombo("status_index","status"," from user_status where status <> 'old' and is_for_student = 1 order by status asc", 
					strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >School Year/Term</td>
      <td> <%strTemp = WI.fillTextValue("sy_from");%> 
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%strTemp = WI.fillTextValue("sy_to");%> 
		<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" 
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="0">Summer</option>
<%strTemp = WI.fillTextValue("semester");
  if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("1") ==0){%>
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
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >Course </td>
      <td><select name="course_index" onChange="ReloadPage();">
      <option value="">Select a Course</option>
<%=dbOP.loadCombo("course_index","course_name"," from course_offered where is_valid=1 and is_del=0 order by course_name asc",WI.fillTextValue("course_index"), false)%> </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Major</td>
      <td><select name="major_index">
          <option></option>
<%
if(WI.fillTextValue("course_index").length() > 0){%>
<%=dbOP.loadCombo("major_index","major_name"," from major where is_del=0 and course_index="+WI.fillTextValue("course_index")+" order by major_name asc", WI.fillTextValue("major"), false)%> 
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >Year Level</td>
      <td><select name="year_level">
          <option value="">N/A</option>
          <%
	  	if(vRetResult != null)
	  		strTemp = (String)vRetResult.elementAt(4);
		else	
			strTemp = WI.fillTextValue("year_level");
		if(strTemp == null)
			strTemp = "";
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td> <%
	  if(iAccessLevel > 1){%> <a href="javascript:PageAction('1','','');"><img src="../../../images/save.gif" border="0"></a> 
        <font size="1" >Click to change Student's Entry Status</font> <%}else{%>
        Not authorized to modify student's ID 
        <%}%> </td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0) {%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="6"> 
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFDF"> 
      <td width="2%" height="25" class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
      <td width="55%" class="thinborderTOPBOTTOM"><div align="center"><font size="1"><strong>COURSE 
          ::: MAJOR</strong></font></div></td>
      <td width="15%" class="thinborderALL"><div align="center"><font size="1"><strong>SY 
          :: TERM</strong></font></div></td>
      <td width="9%" class="thinborderTOPBOTTOMRIGHT"><div align="center"><font size="1"><strong>YR 
          LEVEL</strong></font></div></td>
      <td width="9%" class="thinborderTOPBOTTOMRIGHT"><div align="center"><font size="1"><strong>STUD 
          STATUS</strong></font></div></td>
      <td width="10%" class="thinborderTOPBOTTOMRIGHT"><font size="1"><strong>REMOVE</strong></font></td>
    </tr>
    <%
	String[] astrConvertTerm = {"SU","FS","SS","TS"};
	String[] astrConvertYr = {"N/A","1st","2nd","3rd","4th","5th","6th","7th","8th","9th"};
 for(int i = 0; i < vRetResult.size(); i += 10){%>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i + 8)%> <%=WI.getStrValue((String)vRetResult.elementAt(i + 9)," ::: ","","")%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%> - <%=(String)vRetResult.elementAt(i + 3)%> :: <%=astrConvertTerm[Integer.parseInt((String)vRetResult.elementAt(i + 4))]%></td>
      <td align="center"><%=astrConvertYr[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 5),"0"))]%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborderRIGHT">&nbsp;
	  <%if(iAccessLevel == 2) {%>
	  	<a href="javascript:PageAction(0,'<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
	  <%}%>
	  </td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOMRIGHT">&nbsp;</td>
    </tr>
  </table>
<%}//if vRetResult != null
}//if vStudInfo != null
%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="79%" height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="">
 </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
