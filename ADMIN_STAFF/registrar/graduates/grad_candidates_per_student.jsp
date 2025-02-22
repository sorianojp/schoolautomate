<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function UpdateGradDate(){
	var pgLoc = "./graduation_date_setting.jsp?sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester.value;
	var win=window.open(pgLoc,"UpdateGradDate",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageAction(strAction){
	if(strAction == '0') {
		if(!confirm("Do you want to delete this information?"))
			return;
	}
	
	document.form_.show_stud_info.value = "";
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

function ReloadPage(){
	document.form_.show_stud_info.value = "1";
	document.form_.submit();
}

function AjaxMapName(e) {
		if(e==13)
			document.form_.submit();

		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.show_stud_info.value = "1";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

function Focus(){
	document.form_.stud_id.focus();	
	if(document.form_.show_stud_info.value.length == 0)
		document.form_.stud_id.value = "";	
}

//end of ajax to finish loading.. 
</script>
<body bgcolor="#D2AE72" onLoad="Focus();">
<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolShowEditInfo = false;
//add security here.

	if (WI.fillTextValue("print_page").length()>0){%>
				<jsp:forward page="grad_candidates_print.jsp" />
	<%	return; 
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_candidates.jsp");
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
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_candidates.jsp");
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

EntranceNGraduationData eng = new EntranceNGraduationData();
enrollment.OfflineAdmission OA = new enrollment.OfflineAdmission();

String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
String[] astrConvertToYr  = {"N/A","1ST YR","2ND YR","3RD YR","4TH YR","5TH YR","6TH YR","7TH YR"};

Vector vRetResult = null;
Vector vRetCandidates = null;

Vector vStudInfo = null;

String strGradDate = WI.fillTextValue("graduation_date");
String strStudId = WI.fillTextValue("stud_id");
String strSYFrom = WI.fillTextValue("sy_from_enrolled");
String strSYTo = WI.fillTextValue("sy_to_enrolled");
String strSemester = WI.fillTextValue("semester_enrolled");
String strInfoIndex = "";
String strCourseIndex = WI.fillTextValue("course_index");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(eng.operateOnCandidatesListPerStud(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = eng.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg  ="Student graduation information successfully removed.";
		if(strTemp.equals("1"))
			strErrMsg  ="Student graduation information successfully saved.";
		if(strTemp.equals("2"))
			strErrMsg  ="Student graduation information successfully updated.";		
	}
}

if(WI.fillTextValue("show_stud_info").length() > 0){
	vStudInfo = OA.getStudentBasicInfo(dbOP,strStudId);
	if(vStudInfo == null)
		strErrMsg = OA.getErrMsg();		
	else{
		strCourseIndex = (String)vStudInfo.elementAt(5);
		
		strSYFrom = (String)vStudInfo.elementAt(10);
		strSYTo = (String)vStudInfo.elementAt(11);
		strSemester = (String)vStudInfo.elementAt(9);
	
		vRetResult = eng.operateOnCandidatesListPerStud(dbOP, request, 4);		
		if(vRetResult == null){
			if(strErrMsg == null)
			strErrMsg = eng.getErrMsg();	
		}else{
			strInfoIndex = (String)vRetResult.elementAt(0);			
			
			strSYFrom = (String)vRetResult.elementAt(7);
			strSYTo = (String)vRetResult.elementAt(8);
			strSemester = (String)vRetResult.elementAt(9);
		}
	}
}
	


%>
<form name="form_" action="./grad_candidates_per_student.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CANDIDATES OF GRADUATION MANAGEMENT PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="97%" height="25" colspan="4" ><font size="2"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td width="17%" height="25" >SY-Term</td>
      <td width="50%" height="25" >
<%
	if (WI.fillTextValue("sy_from").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}else{
		strTemp = WI.fillTextValue("sy_from");
	}
%>
	  <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
	if (WI.fillTextValue("sy_to").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}else{
		strTemp = WI.fillTextValue("sy_to");
	}
%>
        <input name="sy_to" type="text" class="textbox" id="sy_to" readonly
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4">
        &nbsp; 
<%
	strTemp = WI.fillTextValue("semester");
	if(strTemp.length() == 0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	if(strTemp == null) strTemp = "";
%>
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
<%

if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="30%" rowspan="2" >
	  <a href="javascript:UpdateGradDate();"><img src="../../../images/update.gif" border="0"></a>
	  <font size="1">Click to update graduation date</font>
	  </td>
    </tr>
    <tr>
        <td height="25" >&nbsp;</td>
        <td height="25" >ID Number</td>
        <td height="25" ><input name="stud_id" type="text" class="textbox"  
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.fillTextValue("stud_id")%>" onKeyUp="AjaxMapName(event.keyCode);">
		&nbsp; &nbsp;
		<label id="coa_info" style="font-size:11px; position:absolute; width:400px; font-weight:bold; color:#0000FF"></label>		</td>
        </tr>
    <tr>
        <td height="25" >&nbsp;</td>
        <td height="25" >&nbsp;</td>
        <td height="25" colspan="2" ><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>    
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){
%>
 	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
        <td height="25">&nbsp;</td>
        <td>&nbsp;</td>
        <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Student Name</td>
	  <%
	  strTemp = WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4);
	  %>
      <td colspan="2"><strong><%=strTemp%></strong></td>
      </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course/Major(cy)</td>
	  <input type="hidden" name="course_index" value="<%=strCourseIndex%>">
      <td colspan="2"><strong><%=(String)vStudInfo.elementAt(7)%>
        <%if(vStudInfo.elementAt(8) != null){%>
        /<%=(String)vStudInfo.elementAt(8)%>
        <%}%>
        (<%=(String)vStudInfo.elementAt(3)%> to <%=(String)vStudInfo.elementAt(4)%>
        )</strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>YEAR LEVEL</td>
      <td width="33%"><strong><%=astrConvertToYr[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(14),"0"))]%></strong></td>
      <td width="47%"><!--SY (TERM ) &nbsp;&nbsp;: &nbsp;&nbsp;<%=strSYFrom + "-" +strSYTo%> (<%=astrConvertToSem[Integer.parseInt(strSemester)]%>)--></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Status</td>
	  <%
	  strTemp = WI.getStrValue(vStudInfo.elementAt(20));
	  if(strTemp.length() >0){
		 strTemp =" select status from USER_STATUS where STATUS_INDEX = "+strTemp;
		 strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	}else	strTemp = "&nbsp;";
	  %>
      <td colspan="2"><strong><%=strTemp%></strong></td>
    </tr>
    
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
 
 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	
	<%
	if(vRetResult != null && vRetResult.size() > 0){
		strTemp = WI.getStrValue((String)vRetResult.elementAt(1),"0");
		
		String[] astrStatus = {"Pending","Passed"};
		strTemp = astrStatus[Integer.parseInt(strTemp)];
	%>
 	
 	<tr>
 	    <td height="25">&nbsp;</td>
 	    <td>Graduation Status</td>
 	    <td><%=strTemp%></td>
    </tr>
	<%}%>
	
	<tr>
 	    <td height="25">&nbsp;</td>
 	    <td>Last Enrolled SY-Term</td>
		<%
		strTemp = WI.fillTextValue("sy_from_enrolled");
		if(strTemp.length() == 0)
			strTemp = WI.getStrValue(strSYFrom);
		%>
 	    <td>
		<input name="sy_from_enrolled" type="text" class="textbox" id="sy_from_enrolled"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  onKeyUp='DisplaySYTo("form_","sy_from_enrolled","sy_to_enrolled")'>
	  -
	  <%
		strTemp = WI.fillTextValue("sy_to_enrolled");
		if(strTemp.length() == 0)
			strTemp = WI.getStrValue(strSYTo);
		%>
	  <input name="sy_to_enrolled" type="text" class="textbox" id="sy_to_enrolled"
	  onfocus="style.backgroundColor='#D3EBFF'" readonly onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4">
	  &nbsp;
	  <select name="semester_enrolled">
          <option value="1">1st Sem</option>
<%
strTemp = WI.fillTextValue("semester_enrolled");
if(strTemp.length() == 0)
	strTemp = WI.getStrValue(strSemester);
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>		</td>
 	    </tr>
	
 	<tr>
 	    <td height="25">&nbsp;</td>
 	    <td>Graduation Date</td>
		<%
		strTemp = WI.fillTextValue("date_grad");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(3);
			
		if(strTemp.length()  >0)
			strGradDate = strTemp;
		if(strTemp.length() == 0 && strGradDate.length() > 0)
			strTemp = strGradDate;
		
		
		strTemp = " select GRADUATION_DATE from GRADUATION_DATE_SETTING "+
				" join COURSE_OFFERED on (COURSE_OFFERED.C_INDEX = GRADUATION_DATE_SETTING.C_INDEX) "+
				" where COURSE_INDEX = "+strCourseIndex+
				" and SY_FROM = "+WI.fillTextValue("sy_from")+
				" and SEMESTER = "+WI.fillTextValue("semester");
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		strTemp = null;
		if(rs.next())
			strTemp = ConversionTable.convertMMDDYYYY(rs.getDate(1));
		rs.close();
		%>
 	    <td><%=WI.getStrValue(strTemp)%>
		<input type="hidden" name="date_grad" value="<%=WI.getStrValue(strTemp)%>">
		</td>
 	    </tr>
 	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%" valign="top">Address</td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(4);
		%>
		<td>
			<textarea name="address" rows="2" cols="50" style="text-transform:uppercase; font-weight:bold;"><%=WI.getStrValue(strTemp)%></textarea>		</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Sponsor</td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(5));
		%>
		<td>
		<input name="sponsor_1" type="text" class="textbox" size="40"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=strTemp%>">		</td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>&nbsp;</td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(6));
		%>
		<td>
		<input name="sponsor_2" type="text" class="textbox" size="40"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=strTemp%>">		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td valign="top">MISSING REQUIREMENTS / SUBJECTS (optional)</td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(2));
		%>
	    <td>
		<textarea name="missing_requirement" class="textbox" rows="4" cols="50"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  style="font-size:11px"><%=strTemp%></textarea>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td valign="top">&nbsp;</td>
	    <td>
			
			<%
			if(vRetResult != null && vRetResult.size() > 0){
			%>
			&nbsp;&nbsp;
			<a href="javascript:PageAction('2');"><img src="../../../images/edit.gif" border="0"></a>
			<font size="1">Click to update information</font>		
			&nbsp;&nbsp;
			<a href="javascript:PageAction('0');"><img src="../../../images/delete.gif" border="0"></a>
			<font size="1">Click to remove information</font>		
			<%}else{%>
			<a href="javascript:PageAction('1');"><img src="../../../images/save.gif" border="0"></a>
			<font size="1">Click to save information</font>
			<%}%>			</td>
	    </tr>
 </table>
 
 <%}%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
  <input type="hidden" name="show_stud_info" value="<%=WI.fillTextValue("show_stud_info")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index" value="<%=WI.getStrValue(strInfoIndex)%>">
  <input type="hidden" name="graduation_date" value="<%=strGradDate%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
