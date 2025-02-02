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
function ReloadPage() {
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}	
function PrintPg() {
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}	
//all about ajax - to display student list with same name.
function AjaxMapName(e) {
		if(e.keyCode == 13) {
			ReloadPage();
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
--></script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.DBOperation,utility.CommonUtil,utility.WebInterface,enrollment.FacultyManagement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);
	
	String strSchCode =(String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	if(WI.fillTextValue("print_pg").compareTo("1") == 0){
		if(strSchCode.startsWith("UB")){
	%>	<jsp:forward page="./teaching_load_slip_print_ub.jsp" />
		<%}else{%>
		<jsp:forward page="./teaching_load_slip_per_college_print.jsp" />
		<%}%>
	<%return;
	}

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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-TEACHING LOAD"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-SUMMARY LOAD"),"0"));
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

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-Faculty Load Print","teaching_load_slip_per_college.jsp");
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
														"teaching_load_slip_per_college.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
**/
Vector vRetResult = null;
FacultyManagement FM = new FacultyManagement();
Vector vUserDetail = null;
Vector vRetSummaryLoad = null;
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");

String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");
							

if(strEmployeeIndex != null) {
	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));
	if(vUserDetail == null)
		strErrMsg = FM.getErrMsg();
	else {
		vRetResult = FM.viewFacultyLoadSummary(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));
		if(vRetResult == null)
			strErrMsg = FM.getErrMsg();
		
		vRetSummaryLoad = FM.getFacultySummaryLoadCollege(dbOP,request);
		if ( vRetSummaryLoad == null) 
			strErrMsg =  FM.getErrMsg();
	}
}else if (WI.fillTextValue("emp_id").length() != 0)
	strErrMsg = " Invalid employee ID ";

//end of authenticaion code.
%>
<form name="form_" action="./teaching_load_slip_per_college.jsp" method="post">  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#A49A6A"> 
    <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          VIEW/PRINT TEACHING LOAD SLIP PAGE ::::</strong></font></div></td>
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
      <td height="25">&nbsp;</td>
      <td>School Year</td>
      <td>
        <%
	strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
        <select name="semester">
		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select></td>
      <td height="25"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr >
      <td></td>
      <td colspan="4"><label id="coa_info"></label></td>
    </tr>
    <tr > 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(vUserDetail != null && vUserDetail.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Employee Name</td>
      <td width="24%"><strong><%=(String)vUserDetail.elementAt(1)%></strong></td>
      <td width="19%">Employment Status</td>
      <td width="35%"><strong><%=(String)vUserDetail.elementAt(2)%></strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td><strong><%=WI.getStrValue(vUserDetail.elementAt(4))%></strong></td>
      <td>Employment Type</td>
      <td><strong><%=(String)vUserDetail.elementAt(7)%></strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>Department</td>
      <td><strong><%=WI.getStrValue(vUserDetail.elementAt(5),"N/A")%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<!--
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="40" valign="bottom" align="right">
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
          <font size="1">click to print load</font></td>
    </tr>
  </table>
-->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong>TEACHING 
          LOAD DETAILS</strong></div></td>
    </tr>
    <tr> 
      <td width="33%" height="25"><font size="1">TOTAL NO. OF SECTION : <strong><%=(String)vUserDetail.elementAt(8)%></strong></font></td>
	  
	<!--
      <td width="26%"> <font size="1">TOTAL UNITS :<strong><%=CommonUtil.formatFloat((String)vUserDetail.elementAt(6),true)%></strong></font></td>
	  
      <td width="37%"><font size="1">TOTAL NO. OF HOURS/WEEK : <strong><%=(String)vUserDetail.elementAt(9)%></strong></font></td>
	-->
    </tr>
  </table>
	  
<%}//end of vUserDetail.
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="9%" height="25"><div align="center"><font size="1"><strong>SUBJECT 
          CODE</strong></font></div></td>
<!--      <td width="16%"><div align="center"><font size="1"><strong>SUBJECT DESCRIPTION 
          </strong></font></div></td>
-->
      <td width="20%"><div align="center"><font size="1"><strong>COLLEGE OFFERING 
          </strong></font></div></td>
<!--
      <td width="4%"><div align="center"><font size="1"><strong>LEC/LAB UNITS 
          </strong></font></div></td>
-->
      <td width="11%"><div align="center"><strong><font size="1">FACULTY LOAD</font></strong></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>SECTION </strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="4%"><div align="center"><font size="1"><strong>ROOM #</strong></font></div></td>
      <td width="4%"><div align="center"><font size="1"><strong>NO. OF STUD.</strong></font></div></td>
    </tr>
    <%
for(int i = 0 ; i < vRetResult.size() ; i +=9){%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i)%></td>
<!--      <td><%=(String)vRetResult.elementAt(i + 1)%></td> 
-->
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
<!--
      <td><%=(String)vRetResult.elementAt(i + 3)%></td>
-->
      <td><div align="center"><%=(String)vRetResult.elementAt(i + 8)%></div></td>
      <td><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
      <td><%=(String)vRetResult.elementAt(i + 7)%></td>
    </tr>
    <%}%>
  </table>
  <%}//if vRetResult != null %>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_pg" value="1">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>