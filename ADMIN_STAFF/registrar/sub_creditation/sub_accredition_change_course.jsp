<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=sub_credition.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.sub_credition.page_action.value = "";
	document.sub_credition.submit();
}
function PageAction(strInfoIndex,strPageAction) {
	document.sub_credition.page_action.value = strPageAction;
	document.sub_credition.info_index.value = strInfoIndex;
	document.sub_credition.submit();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.sub_credition.stud_id.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}
		
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
	document.sub_credition.stud_id.value = strID;
	document.sub_credition.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.sub_credition.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>

<body bgcolor="#D2AE72" onLoad="document.sub_credition.stud_id.focus()">
<%@ page language="java" import="utility.*,enrollment.AccreditedExtn,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	int i = 0; int j = 0;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-SUBJECT ACCREDITATION-Subject accridited","subjects_accredition_change_course.jsp");
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
														"Registrar Management","SUBJECT UNITS CREDITATION",request.getRemoteAddr(),
														"subjects_accredition_change_course.jsp");
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

/////////////////////////////////////// student information detail. //////////////////////
boolean bolIsEnrolling = false;
String strStudName     = null;
String strStudIndex    = null;
String strCourseIndex  = null;
String strMajorIndex   = null;
String strCYFrom       = null;
String strCYTo         = null;
String strCourseName   = null;
String strMajorName    = null;
/////////////////////////////////////// end of student information ///////////////////////

AccreditedExtn accrExtn = new AccreditedExtn();
enrollment.OfflineAdmission offlineAdm   = new enrollment.OfflineAdmission();
student.ChangeCriticalInfo changeInfo = new student.ChangeCriticalInfo();

Vector vStudInfo  = null;
Vector vRetResult = null;

Vector vSubListInGS  = null;
Vector vSubListInCur = null;

Vector vYrLevelInfo = null;
String strCreditEarned = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//either add or delete.
	if(accrExtn.operateOnChangeCourseAccridition(dbOP, request,Integer.parseInt(strTemp)) == null)
		strErrMsg = accrExtn.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}


if(WI.fillTextValue("stud_id").length() > 0) {
	//check if student is enrolling.
	vStudInfo = offlineAdm.getBasicEnrolleeInfo(dbOP,WI.fillTextValue("stud_id"));
	if(vStudInfo != null) {
		bolIsEnrolling = true;
		strStudName    = WebInterface.formatName((String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),(String)vStudInfo.elementAt(4),1);
		strStudIndex   = (String)vStudInfo.elementAt(1);
		strCourseIndex = (String)vStudInfo.elementAt(13);
		strMajorIndex  = (String)vStudInfo.elementAt(14);
		strCYFrom      = (String)vStudInfo.elementAt(8);
		strCYTo        = (String)vStudInfo.elementAt(9);
		strCourseName  = dbOP.mapOneToOther("course_offered","course_index",strCourseIndex,"course_name",null);
		strMajorName   = dbOP.mapOneToOther("major","major_index",strMajorIndex,"major_name",null);
	}else {
		vStudInfo = offlineAdm.getStudentBasicInfo(dbOP,WI.fillTextValue("stud_id"));
		bolIsEnrolling = false;
		if(vStudInfo != null) {
			strStudName    = WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),1);
			strStudIndex   = (String)vStudInfo.elementAt(12);
			strCourseIndex = (String)vStudInfo.elementAt(5);
			strMajorIndex  = (String)vStudInfo.elementAt(6);
			strCYFrom      = (String)vStudInfo.elementAt(3);
			strCYTo        = (String)vStudInfo.elementAt(4);
			strCourseName  = (String)vStudInfo.elementAt(7);
			strMajorName   = (String)vStudInfo.elementAt(8);
		}
	}
	if(vStudInfo == null)
		strErrMsg  = offlineAdm.getErrMsg();
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	vYrLevelInfo =changeInfo.operateOnStudCurriculumHist(dbOP,request,strStudIndex,4);
	if(vYrLevelInfo == null)
		strErrMsg = changeInfo.getErrMsg();
	else {
		vSubListInCur = accrExtn.getSubListToAccredit(dbOP,strStudIndex,strCourseIndex, strMajorIndex,strCYFrom,strCYTo);
		if(vSubListInCur == null) {
			strErrMsg = accrExtn.getErrMsg();
		}
		else {
			vSubListInGS  = (Vector)vSubListInCur.elementAt(0);
			vSubListInCur = (Vector)vSubListInCur.elementAt(1);
		}
	}
}


String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
/**
if(WI.fillTextValue("equiv_code").length() > 0 && WI.fillTextValue("equiv_code").compareTo("0") != 0){// I have to get the curriculum detail infromation.
	strCurInfo = GSTransferee.getCurIndex(dbOP,request.getParameter("equiv_code"),(String)vTemp.elementAt(4),(String)vTemp.elementAt(5),
                              (String)vTemp.elementAt(6),(String)vTemp.elementAt(7),strDegreeType);
	if(strCurInfo == null)
		strErrMsg = GSTransferee.getErrMsg();
}
**/
%>


<form action="./sub_accredition_change_course.jsp" method="post" name="sub_credition">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          CHANGE COURSE INFORMATION MANAGEMENT (SAME SCHOOL):::: </strong> </font></div></td>
    </tr>
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
		<td width="2%" height="25" colspan="4">&nbsp;</td>
      <td width="98%"><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr valign="top">
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%">Student ID</td>
      <td width="15%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="10%"> <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>      </td>
      <td width="56%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    <tr >
      <td  colspan="6" height="25"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="25%" >Name: </td>
      <td width="73%" > <%=strStudName%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Current Course/Major: </td>
      <td><%=strCourseName%>
        <%if(strMajorName != null){%>
        /<%=strMajorName%>
        <%}%>
        (curriculum year: <%=strCYFrom+" - "+strCYTo%>)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" ><strong>CURRICULUM HISTORY <font size="1">(If you find
        any discrepancy please modify in &lt;change critical student info&gt;
        link or contact ADMIN)</font></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td ><font size="1"><strong>SCHOOL YEAR - TERM</strong></font></td>
      <td><font size="1"><strong>COURSE/MAJOR (CURRICULUM YEAR)</strong></font></td>
    </tr>
    <%
if(vYrLevelInfo != null)
	for(i = 0; i< vYrLevelInfo.size() ;i +=16){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td ><%=(String)vYrLevelInfo.elementAt(i+1)%> - <%=(String)vYrLevelInfo.elementAt(i+2)%>
        - <%=astrConvertSem[Integer.parseInt((String)vYrLevelInfo.elementAt(i+3))]%></td>
      <td><%=(String)vYrLevelInfo.elementAt(i+7)%>
        <%
	  if(vYrLevelInfo.elementAt(i+8) != null){%>
        - <%=(String)vYrLevelInfo.elementAt(i+8)%>
        <%}%>
        (<%=(String)vYrLevelInfo.elementAt(i+9)%> - <%=(String)vYrLevelInfo.elementAt(i+10)%>)</td>
    </tr>
    <%}%>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%}//only if student info is not null.
if(vSubListInGS != null && vSubListInGS.size() > 0){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="28%"  height="25" ><div align="left"><font size="1"><strong>
          SUBJECT CODE</strong></font></div></td>
      <td width="70%" ><div align="left"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" ><select name="subject" onChange="ReloadPage();">
          <option value="0">Select a subject to accredit</option>
<%
strTemp = "";
for(i = 0 ; i < vSubListInGS.size(); i += 4){
	if(WI.fillTextValue("subject").compareTo((String)vSubListInGS.elementAt(i)) ==0){
	strCreditEarned = (String)vSubListInGS.elementAt(i+3);
	strTemp = (String)vSubListInGS.elementAt(i+2);%>
	<option value="<%=(String)vSubListInGS.elementAt(i)%>" selected><%=(String)vSubListInGS.elementAt(i+1)%></option>
    <%}else{%>
	<option value="<%=(String)vSubListInGS.elementAt(i)%>"><%=(String)vSubListInGS.elementAt(i+1)%></option>
    <%}
	}//end of for loop%>
	</select></td>
      <td ><%=strTemp%></td>
    </tr>

  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="28%"  height="25" ><div align="left"><font size="1"><strong>
          </strong></font><font color="#0000FF" size="1" ><strong>EQUIV. SUBJECT
          CODE</strong></font></div></td>
      <td width="47%" ><div align="left"><font color="#0000FF" size="1" ><strong>EQUIV.
          SUBJECT TITLE</strong></font><font color="#0000FF" size="1" >&nbsp;</font><font size="1"></font></div></td>
      <td width="11%" ><div align="left"><font color="#0000FF" size="1"><strong>CREDITS
          EARNED</strong></font></div></td>
      <td width="12%" ><font color="#0000FF" size="1"><strong>ACCREDITED CREDIT</strong></font></td>
    </tr>
<%//do not show add button if subject is not selected.
if(WI.fillTextValue("subject").length() > 0 && WI.fillTextValue("subject").compareTo("0") != 0){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" >
	  <select name="equiv_sub" onChange="ReloadPage();">
          <option value="0">Select the subject accredited</option>
<%//System.out.println(vSubListInCur);
String strSubIndex = null;
strTemp = "";
for(i = 0 ; i < vSubListInCur.size(); i += 6){
	if(WI.fillTextValue("equiv_sub").compareTo((String)vSubListInCur.elementAt(i)) ==0){
	strTemp     = (String)vSubListInCur.elementAt(i+2);
	strSubIndex = (String)vSubListInCur.elementAt(i+5);
	%>
	<option value="<%=(String)vSubListInCur.elementAt(i)%>" selected><%=(String)vSubListInCur.elementAt(i+1)%></option>
    <%}else{%>
	<option value="<%=(String)vSubListInCur.elementAt(i)%>"><%=(String)vSubListInCur.elementAt(i+1)%></option>
    <%}
	}//end of for loop%>
	</select>
<input type="hidden" name="sub_index_" value="<%=strSubIndex%>">
	  </td>
      <td ><%=strTemp%></td>
      <td ><%=WI.getStrValue(strCreditEarned)%>
	  <input type="hidden" name="prev_unit" value="<%=WI.getStrValue(strCreditEarned)%>">
	  </td>
      <td ><input name="equiv_credit" type="text" size="4" class="textbox" value="<%=WI.getStrValue(strCreditEarned)%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="70%" colspan="2">
        <%
if(iAccessLevel > 1)
{%>
        <a href='javascript:PageAction("","1");'><img src="../../../images/add.gif" border="0"></a><font size="1">click
        to add</font>
<%}%>
      </td>
    </tr>
<%}//if wi.fillTextValue(subject) is having some values.%>
    <tr>
      <td height="20" width="2%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="70%" colspan="2">&nbsp; </td>
    </tr>
</table>
<%}//only if vSubListToAccredit is not null

strErrMsg = null;
if(WI.fillTextValue("stud_id").length() > 0) {
	vRetResult = accrExtn.operateOnChangeCourseAccridition(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = accrExtn.getErrMsg();
}
if(strErrMsg != null){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" align="center" height="25"><font size="3"><%=strErrMsg%></font></td>
	</tr>
  </table>
<%}
if(vRetResult != null && vRetResult.size() > 0){%>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF"><strong>-
          LIST OF CREDITED SUBJECTS -</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" ><div align="left"><font size="1"><strong>SUBJECT CODE</strong></font></div></td>
      <td width="30%" ><div align="left"><font size="1"><strong>SUBJECT DESCRIPTION</strong></font></div></td>
      <td width="28%" ><strong><font color="#0000FF" size="1" >EQUIV. SUBJECT
        CODE</font></strong></td>
      <td width="6%" ><div align="left"><font color="#0000FF" size="1"><strong>CREDITS
          EARNED</strong></font></div></td>
      <td width="8%" ><font color="#0000FF" size="1"><strong>ACCREDITED CREDIT</strong></font></td>
      <td width="7%" >&nbsp;</td>
    </tr>
<%
for(i = 0 ; i< vRetResult.size(); i+=7){%>
   <tr>
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'>
	  			<img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
 <%}%>

 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="page_action">
<%
if(vStudInfo != null) {%>
<input type="hidden" name="stud_index" value="<%=strStudIndex%>">
<%}%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
