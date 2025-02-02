<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function focusOnGrade()
{
	document.form_.stud_id.focus();
}
function ViewResidency()
{
	var strStudID = document.form_.stud_id.value;
	if(strStudID.length == 0)
	{
		alert("Please enter student ID.");
		return;
	}
	location = "../residency/residency_status.jsp?stud_id="+escape(strStudID);
}
function ReloadPage()
{
	document.form_.page_action.value = '';
	document.form_.submit();
}

function createEnrolInfo() {
	document.form_.page_action.value = '10';
	document.form_.submit();
}


//// - all about ajax..
function AjaxMapName(e, strPos) {
		if(e.keyCode == 13) {
			this.ReloadPage();
			return;
		}


		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2) {
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

///ajax here to load major..
function loadMajor() {
		var objCOA=document.getElementById("load_major");
		
		var objCourseInput = document.form_.course_index[document.form_.course_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=104&all=1&course_ref="+objCourseInput;
		this.processRequest(strURL);
}

</script>
<body bgcolor="#D2AE72" onLoad="focusOnGrade();">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg    = null;
	String strTemp      = null;
	String strUserIndex = null;
	
	Vector vTemp = null;
	
	String strCourseType = null;//0->Under graduate, 1->Doctoral, 2-> doctor of medicine, 3-> with proper, 4-> non semestral.
	String strSQLQuery = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-VERY OLD STUDENT DATA MANAGEMENT","very_old_stud_data_entry.jsp");
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
														"Registrar Management","OLD STUDENT DATA MANAGEMENT",request.getRemoteAddr(),
														"very_old_stud_data_entry.jsp");
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
	

Vector vStudInfo = new Vector();
boolean bolIsFatalErr = false;

boolean bolIsCurHistCreated = false;
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
boolean bolIsCGH = false;
java.sql.ResultSet rs = null;

if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("stud_id").length() > 0) {
	strSQLQuery = "select user_index, fname, mname, lname from user_table where id_number = "+
					WI.getInsertValueForDB(WI.fillTextValue("stud_id"), true, null)+
					" and is_valid = 1 and auth_type_index = 4";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strUserIndex = rs.getString(1);
		vStudInfo.addElement(WebInterface.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4));
	}
	else
		strErrMsg = "ID Number not found.";
	rs.close();
}
if(strUserIndex != null) {
	strSQLQuery = "select cur_hist_index, course_offered.course_code, course_name, major.course_code, major_name, "+
				"course_type from stud_curriculum_hist "+
				"left join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
				"left join major on (major.major_index = stud_curriculum_hist.major_index) "+
				"where user_index = "+strUserIndex+" and stud_curriculum_hist.is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+
				" and semester = "+WI.fillTextValue("semester");
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		if(rs.getString(2) == null) {
			strErrMsg = "Student already has entry in Grade school for this sy-term";
			bolIsFatalErr = true;
		}
		else {
			vStudInfo.addElement(rs.getString(1));//[1] cur_hist_index
			vStudInfo.addElement(rs.getString(2));//[2] course_offered.course_code
			vStudInfo.addElement(rs.getString(3));//[3] course_name
			vStudInfo.addElement(rs.getString(4));//[4] major.course_code
			vStudInfo.addElement(rs.getString(5));//[5] major_name
		}
	}
	rs.close();
}

//System.out.println(vStudInfo);
%>


<form action="./very_old_stud_data_entry.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>::::
          OLD STUDENT DATA MANAGEMENT ::::<br>
          </strong>(Encoding of old student's academic records)</font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
	  <td width="2%" height="25">&nbsp;</td>
      <td width="96%" style="font-size:16px; color:#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 9);
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%}%>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%">Student ID</td>
      <td width="18%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">      </td>
      <td width="69%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:fixed"></label></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%">SY /Term : </td>
      <td colspan="2">
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
	  
        to
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> <font size="1">&nbsp; </font></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input type="button" onClick="ReloadPage();" value="&nbsp;&nbsp; Proceed &nbsp;&nbsp; "></td>
    </tr>
<%if(strUserIndex != null && vStudInfo.size() ==1 && !bolIsFatalErr) {%>
     <tr >
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:14px; font-weight:bold;"><u>Create Student SY-Term Information</u></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="2">
		<select name="course_index" onChange="loadMajor();" style="width:500px">
          <option value=""></option>
      		<%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND is_valid = 1 order by course_name asc",	WI.fillTextValue("course_index"), false)%> 
	  </select>	  
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td colspan="2">
<label id="load_major">
		<select name="major_index">
          <option value="">ALL</option>
<%if(WI.fillTextValue("course_index").length() > 0) {%>
          	<%=dbOP.loadCombo("major_index","major_name"," from	 major where IS_DEL=0 and course_index = " + WI.fillTextValue("course_index") + " order by major_name asc",	WI.fillTextValue("major_index"), false)%> 
<%}%>
		</select> 		  
</label>	  
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Year Level </td>
      <td colspan="2">
	  <select name="year_level">
	  <option value=""></option>
<%
int iDef = Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"), "0"));
for (int i =1 ; i < 7; ++i){
if(i == iDef)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
<%}%>
	</select>
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input type="button" onClick="createEnrolInfo();" value="&nbsp;&nbsp; Create Information &nbsp;&nbsp; "></td>
    </tr>
<%}%>
    <tr >
      <td  colspan="4" height="25"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
