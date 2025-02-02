<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function DisplaySYTo() {
	var strSYFrom = document.form_.sy_from.value;
	if(strSYFrom.length == 4)
		document.form_.sy_to.value = eval(strSYFrom) + 1;
	if(strSYFrom.length < 4)
		document.form_.sy_to.value = "";
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function LoadUpdate(){
	location = "./faculty_subj_list_load_update.jsp?emp_id="+document.form_.emp_id.value +
	"&sy_from="+document.form_.sy_from.value+"&semester="+document.form_.semester.value + 
	"&sy_to="+document.form_.sy_to.value;
}

function ReloadPage(){
	document.form_.submit();
}

function PrintPage(){
	location = "./faculty_subj_list_load_print.jsp?emp_id="+document.form_.emp_id.value +
	"&sy_from="+document.form_.sy_from.value+"&semester="+document.form_.semester.value+"&sy_to="+
	document.form_.sy_to.value;
}

//all about ajax - to display student list with same name.
function AjaxMapName(e) {
		if(e.keyCode == 13) {
			this.ReloadPage();
			return;
		}
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
-->
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.Authentication,enrollment.FacultyManagement, enrollment.FacultyManagementExtn,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strSyFrom = null;
	String strSyTo = null;
	boolean[] bolConflict = {false}; // this is passed to getSubjectScheduleTime to check if the subject is conflict with the previous
	boolean bolIsRestricted = false;

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-CAN TEACH"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-REPORTS"),"0"));
			bolIsRestricted = true;
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	if(WI.fillTextValue("is_report").length() > 0)
		bolIsRestricted = true;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-schedule","faculty_sched.jsp");
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"faculty_sched.jsp");
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
**/
//end of authenticaion code.
FacultyManagementExtn fm = new FacultyManagementExtn();
FacultyManagement FM = new FacultyManagement();
Vector vRetResult = new Vector();
Vector vPersonalDetails = new Vector();
String strEmpID = WI.fillTextValue("emp_id");
String strMaxLoad =  fm.getFacMaxLoad(dbOP,request);
String[] astrConvSem = {"Summer", "1st", "2nd", "3rd"};
String strSem = WI.fillTextValue("semester");

if (strEmpID.length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
}//System.out.println(vPersonalDetails);
%>
<form name="form_" method="post" action="./faculty_subj_list_load.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FACULTY PAGE - LIST OF SUBJECTS FACULTY CAN TEACH PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr > 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="14%">Employee ID</td>
      <td width="31%"> <input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event);"></td>
      <td width="53%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a><font size="1">click 
        to search </font></td>
    </tr>
    <tr >
      <td></td>
      <td colspan="3"><label id="coa_info"></label></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>School Year</td>
      <td> <%
	strSyFrom = WI.fillTextValue("sy_from");
if(strSyFrom.length() ==0)
	strSyFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	

%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSyFrom%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo()'>
        - 
        <%
strSyTo = WI.fillTextValue("sy_to");
if(strSyTo.length() ==0)
	strSyTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSyTo%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
      <td height="25"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><font color="#0000FF" size="1"><strong>NOTE: 
        SY/Term entry is optional. Entering SY/Term Info diplays faculty load 
        information. List of Subjects faculty can teach is not dependent on SY/Term 
        information.</strong></font> </td>
    </tr>
    <tr > 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
 <%
if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Employee Name</td>
      <td width="24%"> &nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></td>
      <td width="19%">Employment Status</td>
      <td width="35%">&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(16),"")%></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>  
      <td>College</td>
      <td>&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(13),"")%></td>
      <td>Employment Type</td>
      <td>&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(15),"")%></td>
    </tr>
    <tr > 
      <td height="24">&nbsp;</td>
      <td>Department</td>
      <td>&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"")%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
<%if(!bolIsRestricted){%>
    <tr> 
      <td width="2%" height="35">&nbsp;</td>
      <td height="35" colspan="3"><a href="javascript:LoadUpdate()"><img src="../../../images/update.gif" border="0" ></a><font size="2" color="#0000FF">click 
        to update list of subjects faculty can teach and maximum load units </font></td>
      <td height="35">&nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="22%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><div align="right"><font size="1"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0" ></a>click 
          to print the list</font></div></td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="2"><div align="center"><strong>LIST OF SUBJECTS 
          FACULTY CAN TEACH</strong></div></td>
    </tr>
  <tr> 
      <td width="1%" height="25" bgcolor="#FFFFFF">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Maximum 
        Load Units/Hours : <strong><font color="#FF0000"><%=WI.getStrValue(strMaxLoad,"Not Set")%></font></strong></td>
    <td width="1%" height="25" bgcolor="#FFFFFF"><div align="right"></div></td>
  </tr>
</table>
  
<table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" >
  <tr> 
    <td width="13%" height="25" ><div align="center"><strong>SUBJECT GROUP</strong></div></td>
    <td width="12%" height="25"><div align="center"><strong>SUBJECT CODE</strong></div></td>
    <td width="34%" ><div align="center"><strong>SUBJECT TITLE </strong></div></td>
  </tr>
<% 
	vRetResult = fm.operateOnFacCanTeach(dbOP, request, 4);
	if (vRetResult != null && vRetResult.size()>0){
	for (int i = 0; i< vRetResult.size() ; i+=6) {
%>
  <tr> 
    <td height="25" >&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp")%></td>
    <td >&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
    <td >&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
  </tr>
  <%} // end for loop
}else{ strErrMsg = fm.getErrMsg();  %>
  <tr> 
    <td height="25" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
  </tr>
<%}
	String strEmpIndex = (String)vPersonalDetails.elementAt(0);
   	vPersonalDetails = FM.viewFacultyDetail(dbOP,strEmpIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));//System.out.println(FM.getErrMsg());
%>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18">&nbsp;</td>
      <td height="15" colspan="7">&nbsp;</td>
    </tr>
    <tr> 
      <td height="29" bgcolor="#B9B292">&nbsp;</td>
      <td height="29" colspan="7" bgcolor="#B9B292"><div align="center"><strong>LIST OF SUBJECTS 
          CURRENTLY HANDLED</strong></div></td>
    </tr>
    <tr> 
      <td width="0%" height="29">&nbsp;</td>
      <td height="29" valign="bottom">School Year : <%=strSyFrom%> - <%=strSyTo%> </td>
      <td height="29" colspan="4" valign="bottom">Term : <strong><%=astrConvSem[Integer.parseInt(strSem)]%></strong></td>
      <td width="44%" height="29" valign="bottom">Current Load: <strong>
	  <%if(vPersonalDetails != null && vPersonalDetails.size() > 0) {%>
	  <%=WI.getStrValue((String)vPersonalDetails.elementAt(6),"0")%>
	  <%}else{%>0<%}%></strong></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%" height="25"><div align="center"><font size="1"><strong>SUBJECT 
          CODE</strong></font></div></td>
      <td width="22%"><div align="center"><font size="1"><strong>SUBJECT TITLE 
          </strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>LEC/LAB UNITS 
          </strong></font></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>SECTION </strong></font></div></td>
      <td width="25%"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>ROOM #</strong></font></div></td>
    </tr>
    <%	
	if(vPersonalDetails == null)
		strErrMsg = FM.getErrMsg();
 

	vRetResult = FM.viewFacultyLoadSummary(dbOP,strEmpIndex, WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
				WI.fillTextValue("semester"));
	
	if (vRetResult !=null && vRetResult.size() > 0){				
	for(int i = 0 ; i < vRetResult.size() ; i +=9){%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i)%></td>
      <td><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
    </tr>
    <%}}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <td width="12%"></tr>
    <tr>
      <td width="84%">&nbsp;</td>
      <td width="16%" height="25">&nbsp; </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<%} // end no detail.. no show%>

  <input type="hidden" name="opner_fac_name" value="<%=WI.fillTextValue("opner_fac_name")%>">
  <input type="hidden" name="opner_fac_index" value="<%=WI.fillTextValue("opner_fac_index")%>">
  <input type="hidden" name="is_report" value="<%=WI.fillTextValue("is_report")%>">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
