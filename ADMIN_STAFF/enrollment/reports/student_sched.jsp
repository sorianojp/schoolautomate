<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
	var strHideInstructor;
	if(document.studsch.show_instructor.checked)
		strHideInstructor = "1";
	else
		strHideInstructor = "0";
	var loadPg = "./student_sched_print.jsp?offering_sem="+document.studsch.offering_sem[document.studsch.offering_sem.selectedIndex].value+
		"&sy_from="+document.studsch.sy_from.value+"&sy_to="+
		document.studsch.sy_to.value+"&stud_id="+
		escape(document.studsch.stud_id.value)+"&show_instructor="+strHideInstructor;

	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusID() {
	document.studsch.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=studsch.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.studsch.stud_id.value;
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
	document.studsch.stud_id.value = strID;
	document.studsch.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.studsch.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
//add security here.
	try
	{
		dbOP = new DBOperation();
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

boolean bolHidePrint = false;//hide only if from guidance/
String strSchCode = (String)request.getSession(false).getAttribute("school_code");

int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","STUDENT TRACKER",request.getRemoteAddr(),
														null);
	if(strSchCode.startsWith("UB"))
		bolHidePrint = true;
}											
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance","STUDENT TRACKER",request.getRemoteAddr(),
														null);
	if(strSchCode.startsWith("UB"))
		bolHidePrint = true;
}
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","CHANGE OF SUBJECTS",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","STUDENT SCHEDULE",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Circulation","ISSUE/RENEW",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Executive Management System","ENROLLMENT",request.getRemoteAddr(),
														null);
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
Vector vStudDetail= null;

ReportEnrollment reportEnrl= new ReportEnrollment();
if(WI.fillTextValue("reloadPage").length() > 0)
{
	vRetResult = reportEnrl.getStudentLoad(dbOP, request.getParameter("stud_id"),request.getParameter("sy_from"),
							request.getParameter("sy_to"),request.getParameter("offering_sem"));
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();
	else
		vStudDetail = (Vector)vRetResult.elementAt(0);
}
dbOP.cleanUP();
if(strErrMsg == null) strErrMsg = "";
%>
<form action="./student_sched.jsp" method="post" name="studsch">

  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          STUDENT'S SCHEDULE PAGE ::::</strong></font></strong></font></div></td>
    </tr>
  </table>


  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong> </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">School Year : </td>
      <td> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("studsch","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td colspan="3">Term :
        <select name="offering_sem">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
        </select>
		
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <%if(strSchCode.startsWith("SPC")){%>
	  	<a href="./student_sched_plotting.jsp">View Student Plotted Schedule</a>
	  <%}%>

		
		
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">
<%
strTemp = WI.fillTextValue("show_instructor");
if(strTemp.compareTo("1") == 0)
	strTemp = "checked";
else
	strTemp = "";
%>	  <input type="checkbox" name="show_instructor" value="1" <%=strTemp%>>
        Show Instructor detail</td>
    </tr>
    <tr>
      <td  colspan="6" height="10"><hr size="1"></td>
    </tr>
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td height="25">Student ID : </td>
      <td width="20%" height="25"><input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="7%" height="25"><input type="image" src="../../../images/form_proceed.gif"></td>
      <td width="51%">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>
	  </td>
    </tr>
    <td  colspan="6" height="10"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudDetail != null && vStudDetail.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%" height="25">Student Name : </td>
      <td width="37%" height="25"><strong><%=(String)vStudDetail.elementAt(2)%></strong></td>
      <td width="45%" height="25">Year : <strong><%=WI.getStrValue(vStudDetail.elementAt(4),"N/A")%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major : </td>
      <td height="25"><strong><%=(String)vStudDetail.elementAt(3)%></strong></td>
      <td align="right">
	  <%if(!bolHidePrint) {%>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
        to print schedule &nbsp;&nbsp;&nbsp;&nbsp;</font>
		<%}%>
		</td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="13%" height="34"><div align="center"><font size="1"><strong>SUBJECT
          CODE </strong></font></div></td>
      <td width="23%"><div align="center"><font size="1"><strong>SUBJECT TITLE </strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="13%"><div align="center"><font size="1"><strong>SECTION &amp;
          ROOM #</strong></font></div></td>
<%
if(WI.fillTextValue("show_instructor").compareTo("1") == 0){%>
      <td width="13%"><div align="center"><strong><font size="1">INSTRUCTOR</font></strong></div></td>
<%}%>
      <td width="6%"><div align="center"><font size="1"><strong>LEC. UNITS </strong></font></div></td>
      <td width="6%"><div align="center"><font size="1"><strong>LAB. UNITS</strong></font></div></td>
      <td width="6%"><div align="center"><font size="1"><strong>UNITS TAKEN</strong></font></div></td>
    </tr>
 <%
 float fTotalLoad = 0;//System.out.println(vRetResult);
 for(int i=1; i< vRetResult.size(); ++i){
 if( !((String)vRetResult.elementAt(i+9)).startsWith("("))
  fTotalLoad += Float.parseFloat((String)vRetResult.elementAt(i+9));
 %>
    <tr>
      <td height="25"><%=(String)vRetResult.elementAt(i)%></td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=(String)vRetResult.elementAt(i+2)%></td>
      <td><%=(String)vRetResult.elementAt(i+4)%><!--/<%=(String)vRetResult.elementAt(i+4)%>(<%=(String)vRetResult.elementAt(i+5)%>) -- Room location--></td>
<%
if(WI.fillTextValue("show_instructor").compareTo("1") == 0){%>
       <td><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
<%}%>      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+9)%></td>
    </tr>
<% i = i+10;
}%>
    <tr bgcolor="#FFFFFF">
      <td colspan="8" height="25"><div align="center">TOTAL LOAD UNITS : <%=fTotalLoad%></div></td>
    </tr>
  </table>




  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="18">&nbsp;</td>
      <td width="71%" valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
    </tr>
<%if(!bolHidePrint) {%>
   <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><div align="center"></div></td>
      <td width="26%" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
        to print schedule &nbsp;&nbsp;&nbsp;</font></td>
    </tr>
<%}%>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<%
}//if student info not null
%>
<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
