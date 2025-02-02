<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//// - all about ajax.. 
function AjaxMapName(strPos) {
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
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

//print admission slip.
function printExamPermit() {
	var pgURL = "./exam_permit_print.jsp?stud_id="+document.form_.stud_id.value+
		"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
		"&pmt_schedule="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
	var win=window.open(pgURL,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ViewStudent(viewstat) {
	var pgURL = "./exam_permit_statistics_view_detail.jsp?sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
		"&pmt_schedule="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value+
		"&view_status="+viewstat+
		"&d_index="+document.form_.d_index.value+
		"&course_index="+document.form_.course_index.value+
		"&c_index="+document.form_.c_index.value;
	var win=window.open(pgURL,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

function ReloadPage(strShowInfo){
	document.form_.show_result.value = strShowInfo;
	document.form_.submit();	
}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-EXAM PERMIT-STATISTICS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}




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

boolean bolIsBasic = false;
String strExamName = null;
String strExamPeriod = null;
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

String strSYFrom   = WI.fillTextValue("sy_from");
String strSYTo     = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");
strExamPeriod      = WI.fillTextValue("pmt_schedule");

Vector vRetResult  = null;//get subject schedule information.
if(WI.fillTextValue("pmt_schedule").length() > 0 && WI.fillTextValue("show_result").length() > 0) {
	enrollment.ReportEnrollment RE = new enrollment.ReportEnrollment();
	vRetResult = RE.examPermitSummary(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RE.getErrMsg();
}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./exam_permit_statistics.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ADMISSION SLIP STATUS ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-size:16px; font-weight:bold; color:#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="19%" height="25">SY/TERM</td>
      <td height="25" colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

		// force to 1 (regular for basic ) if not summer and if basic
		if (WI.fillTextValue("is_basic").equals("1") && !strTemp.equals("0"))  
			strTemp = "1";
	
		  if(strTemp.equals("1")){
		  %>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td height="25">Exam Period</td>
      <td height="25"><select name="pmt_schedule">
        <%if(bolIsBasic){%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=2 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}else{%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}%>
      </select></td>     
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td height="25">College</td>
        <td height="25" colspan="2">
		<select name="c_index" style="width:400px;" onChange="ReloadPage('');">
			<option value="">Select any</option>
			<%=dbOP.loadCombo("c_index","c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"),false)%>
		</select>
		</td>
       
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td height="25">Department</td>
        <td height="25" colspan="2">
		<select name="d_index" style="width:400px;" onChange="ReloadPage('');">
			<option value="">Select any</option>
			<%
			strTemp = " from department where IS_COLLEGE_DEPT = 1 and IS_DEL =0 ";
			if(WI.fillTextValue("c_index").length() > 0)
				strTemp += " and c_index = "+WI.fillTextValue("c_index");
			strTemp += " order by d_name";
			%>
			<%=dbOP.loadCombo("d_index","d_name", strTemp, WI.fillTextValue("d_index"), false)%>
		</select>
		</td>
       
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td height="25">Course</td>
        <td height="25" colspan="2">
		<select name="course_index" style="width:400px;" onChange="ReloadPage('');">
			<option value="">Select any</option>
			<%
			strTemp = " from course_offered where IS_DEL = 0 and IS_VALID =1 and IS_OFFERED = 1";
			if(WI.fillTextValue("c_index").length() > 0)
				strTemp += " and c_index = "+WI.fillTextValue("c_index");
			if(WI.fillTextValue("d_index").length() > 0)
				strTemp += " and d_index = "+WI.fillTextValue("d_index");
			strTemp += " order by course_name";
			
			%>
			<%=dbOP.loadCombo("course_index","course_name",strTemp, WI.fillTextValue("course_index"),false)%>
		</select>
		</td>
        
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> 
	  <input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="ReloadPage('1');"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="22" bgcolor="#CCCCCC" align="center" class="thinborderBOTTOM" style="font-weight:bold">SUMMARY OF ADMISSION SLIP</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="30"></td>
      <td width="29%" style="font-size:18px;">Total Students Enrolled</td>
      <td width="69%" style="font-size:18px;"><%=vRetResult.elementAt(0)%></td>
    </tr>
    <tr>
      <td height="30"></td>
      <td style="font-size:18px;"> Students with Permit </td>
	  <%
	  strTemp = (String)vRetResult.elementAt(1);
	  %>
      <td style="font-size:18px;"><%=strTemp%>
	  <%if(Integer.parseInt(strTemp) > 0){%>
	  <a href="javascript:ViewStudent('1')"><img src="../../../../../images/view.gif" border="0"></a><%}%>
	  </td>
    </tr>
    <tr>
      <td height="30"></td>
      <td style="font-size:18px;">Students with Temp Permit </td>
	  <%
	  strTemp = (String)vRetResult.elementAt(2);
	  %>
      <td style="font-size:18px;"><%=strTemp%>
	  <%if(Integer.parseInt(strTemp) > 0){%>
	  <a href="javascript:ViewStudent('2')"><img src="../../../../../images/view.gif" border="0"></a><%}%>
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  View permit grouped by Reason 
	  <a href="javascript:ViewStudent('20')"><img src="../../../../../images/view.gif" border="0"></a>
	  </td>
    </tr>
    <tr>
      <td height="30"></td>
      <td style="font-size:18px; color:#FF0000">Students without Permit </td>
	  <%
	  strTemp = (String)vRetResult.elementAt(3);
	  %>
      <td style="font-size:18px; color:#FF0000"><%=strTemp%>
	  <%if(Integer.parseInt(strTemp) > 0){%>
	  <a href="javascript:ViewStudent('0')"><img src="../../../../../images/view.gif" border="0"></a><%}%>
	  </td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="show_result">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>