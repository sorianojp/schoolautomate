<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.submit();
}
function ajaxUpdatePNUnclaimed(obj, strLabelID, strPNRef) {
	
	var strNewVal = obj.value;
	if(strNewVal == '')
		strNewVal = "0";
		
	var strParam = "pn_ref="+strPNRef+"&new_val="+strNewVal;
	var objCOAInput = document.getElementById(strLabelID);
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=119&"+strParam;
	this.processRequest(strURL);
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*, enrollment.FAPromisoryNote ,java.util.Vector, java.util.Date" buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assess & Payment - Reports - Promisory Note record unclaimed Permit.",
								"promisory_record_unclaimed_permit.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
%>
<form action="./promisory_record_unclaimed_permit.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="tHeader1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: RECORD UNCLAIMED PERMIT ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="tHeader2">
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="relaunchPage();"> Process Promisory Note for Grade School	  </td>
    </tr>
-->
    <tr> 
      <td height="25">&nbsp;</td>
      <td>SY/TERM</td>
      <td colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 

<%if(bolIsBasic){%>
<input type="hidden" name="semester" value="1">
<%}else{%>
	  <select name="semester">
          <%strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
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
          <%}%>
        </select>
<%}%>	  </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Exam Period</td>
      <td width="53%">  
<%
if(bolIsBasic)
	strTemp = "2";
else	
	strTemp = "1";
%>
	  <select name="pmt_schedule">
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid="+strTemp+" order by EXAM_PERIOD_ORDER asc",request.getParameter("pmt_schedule"), false)%> </select>      </td>
      <td width="29%">&nbsp;</td>
    </tr>
<%if(!bolIsBasic){%>
   	<tr>
   		<td colspan="4" height="25">&nbsp;</td>
   	</tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td>
      <%strTemp = WI.fillTextValue("c_index");%>
      <select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		strTemp, false)%> </select>      </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td>
	<%if (strTemp==null || strTemp.length()==0 )
		strTemp = " from course_offered where is_del = 0 and is_valid = 1 order by course_name asc";
	else
		strTemp = " from course_offered where is_del = 0 and is_valid = 1 and c_index = "+strTemp+
		" order by course_name asc";
		
	String strTemp2 = WI.fillTextValue("course_index");%>
      <select name="course_index">
          <option value="">All</option>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, strTemp2, false)%>
        </select>      </td>
      <td>Year Level: 
      <%strTemp = WI.fillTextValue("yr_lvl");%>
      <select name="yr_lvl">
		<option value="">N/A</option>      
	<%if (strTemp.equals("1")){%>
		<option value="1" selected>1</option>
	<%} else {%>
		<option value="1">1</option>
	<%} if (strTemp.equals("2")){%>
		<option value="2" selected>2</option>
	<%} else {%>
		<option value="2">2</option>
	<%} if (strTemp.equals("3")){%>
		<option value="3" selected>3</option>
	<%} else {%>
		<option value="3">3</option>
	<%} if (strTemp.equals("4")){%>		
		<option value="4" selected>4</option>
	<%} else {%>
		<option value="4">4</option>
	<%} if (strTemp.equals("5")){%>
		<option value="5" selected>5</option>
	<%} else {%>
		<option value="5">5</option>
	<%} if (strTemp.equals("6")){%>
		<option value="6" selected>6</option>
	<%} else {%>
		<option value="6">6</option>
	<%}%>
      </select>      </td>
    </tr>
<%}else{%>
	<input type="hidden" name="sortYr" value="1">
	<input type="hidden" name="printBy" value="2">
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2">
      <a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" border="0"></a>      </td>
    </tr>
  </table>
  
  <%
  String strSYFrom = WI.fillTextValue("sy_from");
  String strSemester = WI.fillTextValue("semester");
  if(strSYFrom.length() > 0) {
  %>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td align="center" bgcolor="#EEEEEE" height="25" class="thinborderTOPLEFTRIGHT"><strong>PROMISORY NOTE LISTING </strong></td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr style="font-weight:bold;" align="center" bgcolor="#CCCCCC">
			<td height="25" width="3%" style="font-size:9px;" class="thinborder">Count</td>
		    <td width="12%" style="font-size:9px;" class="thinborder">Student ID </td>
		    <td width="20%" style="font-size:9px;" class="thinborder">Student Name </td>
		    <td width="10%" style="font-size:9px;" class="thinborder">Course</td>
		    <td width="10%" style="font-size:9px;" class="thinborder">PN Amount </td>
		    <td width="10%" style="font-size:9px;" class="thinborder">Due Date </td>
		    <td width="10%" style="font-size:9px;" class="thinborder">Unclaimed Permit </td>
	    </tr>
<%
int iMaxDisp = 0;
String strSQLQuery = "select PN_INDEX, id_number, fname, mname, lname, course_code,YEAR_LEVEL,AMOUNT,DUE_DATE, "+
	"AUF_UNCLAIMED_PERMIT from FA_STUD_PROMISORY_NOTE "+
	"join user_table on (user_table.user_index = FA_STUD_PROMISORY_NOTE.user_index) "+
	"join course_offered on (course_offered.course_index = FA_STUD_PROMISORY_NOTE.course_index) "+
	"where sy_from = "+strSYFrom+" and semester = "+strSemester+
	" and PMT_SCH_INDEX = "+WI.fillTextValue("pmt_schedule")+" and 	FA_STUD_PROMISORY_NOTE.is_valid = 1 "+
	" and amount > 0 order by course_code, lname, fname";
java.sql.ResultSet rs= dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
strTemp = rs.getString(1);%>
		<tr>
		  <td height="25" style="font-size:9px;" class="thinborder"><%=++iMaxDisp%>.</td>
		  <td style="font-size:9px;" class="thinborder"><%=rs.getString(2)%></td>
		  <td style="font-size:9px;" class="thinborder"><%=WebInterface.formatName(rs.getString(3),rs.getString(4),rs.getString(5),4)%></td>
		  <td style="font-size:9px;" class="thinborder"><%=rs.getString(6)%><%=WI.getStrValue(rs.getString(7), "-", "","")%></td>
		  <td style="font-size:9px;" class="thinborder"><%=CommonUtil.formatFloat(rs.getDouble(8), true)%></td>
		  <td style="font-size:9px;" class="thinborder"><%=ConversionTable.convertMMDDYYYY(rs.getDate(9))%></td>
		  <td style="font-size:9px;" class="thinborder">
		  <input type="text" name="up_<%=iMaxDisp%>" value="<%=CommonUtil.formatFloat(rs.getDouble(10), true)%>"
		  size="10" onKeyUp="AllowOnlyFloat('form_','up_<%=iMaxDisp%>');"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="ajaxUpdatePNUnclaimed(document.form_.up_<%=iMaxDisp%>, '<%=iMaxDisp%>', '<%=strTemp%>');style.backgroundColor='white'">
		  <label id="<%=iMaxDisp%>" style="font-size:8px; font-weight:bold; color:#FF0000"></label>
		  </td>
	  </tr>
<%}rs.close();%>
	</table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="tFooter">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="post_fine">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>