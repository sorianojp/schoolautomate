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
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to remove this record."))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	
	document.form_.submit();
}
//all about ajax - to display student list with same name.
var strPos;
function AjaxMapName(pos) {
	strPos = pos;
		var strCompleteName = document.form_.stud_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strPos == 2) {
			strCompleteName = document.form_.emp_id.value;
			objCOAInput = document.getElementById("coa_info2");
		}
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);
		if(strPos == 2)
			strURL += "&is_faculty=1";

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	if(strPos == 2) {
		document.form_.emp_id.value = strID;
		document.getElementById("coa_info2").innerHTML = "";
	}
	else {
		document.form_.stud_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
	}
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>

<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String[] astrConvertSem ={"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","eto.jsp");
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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","Allow Dropping NSTP/PE",request.getRemoteAddr(),
														null);

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vEnrolledList  = new Vector();
Vector vAllowDropList = new Vector();
boolean bolEnrolled   = false;


String strSQLQuery    = null;
java.sql.ResultSet rs = null;

String strStudIndex = null;
String strSYFrom    = WI.fillTextValue("sy_from");
String strSemester  = WI.fillTextValue("semester");
String strInfoIndex = null; int iTemp = 0;

if(WI.fillTextValue("stud_id").length() > 0) {
	strStudIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
	if(strStudIndex == null)
		strErrMsg = "Student ID does not exist.";
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0 && strStudIndex != null) {
	if(strTemp.equals("1")) {
		String strEmpIndex = WI.fillTextValue("emp_id");
		String strLastDate = WI.fillTextValue("last_date");
		if(strEmpIndex.length() > 0) {
			strSQLQuery = "select user_index from user_Table where auth_type_index <> 4 and is_Valid = 1 and id_number = '"+strEmpIndex+"'";
			strEmpIndex = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strEmpIndex == null)
				strErrMsg = "Employee ID not found.";
		}
		else {
			strEmpIndex = null;
			strErrMsg = "Please fill up employee ID.";
		}
		if(strEmpIndex != null) {
			if(strLastDate.length() > 0) {
				strLastDate = ConversionTable.convertTOSQLDateFormat(strLastDate);
				if(strLastDate == null || strLastDate.length() == 0) 
					strLastDate = null;
			}
			else
				strLastDate = null;
			strSQLQuery = "insert into CIT_DROP_NSTPPE_EXCEPTION (stud_index, employee_index, last_date, sy_f, sem, encoded_by, create_date, sub_i) values ( "+
							strStudIndex+", "+strEmpIndex+","+WI.getInsertValueForDB(strLastDate, true, null)+","+strSYFrom+","+strSemester+","+
							(String)request.getSession(false).getAttribute("userIndex")+", '"+WI.getTodaysDate()+"',";	
			iTemp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("enrl_max"), "0"));
			for(int i = 0; i < iTemp; ++i) {
				strInfoIndex = WI.fillTextValue("_"+i);
				if(strInfoIndex.length() == 0) 
					continue;
				//System.out.println(strSQLQuery+strInfoIndex+")");
				dbOP.executeUpdateWithTrans(strSQLQuery+strInfoIndex+")", null, null, false);
			}
			strErrMsg = "Request processed successfully.";
		}
	}//end of iAction = 1
	if(strTemp.equals("0")) {
		strInfoIndex = WI.fillTextValue("info_index");
		if(strInfoIndex.length() > 0) {
			strSQLQuery = "update CIT_DROP_NSTPPE_EXCEPTION set is_valid = 0, lmd = '"+WI.getTodaysDate()+"', lmb = "+
							(String)request.getSession(false).getAttribute("userIndex")+" where nstppe_exception_index = "+strInfoIndex;
			if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) == -1) {
				strErrMsg = "Error in SQLQuery. Failed to remove record.";
				System.out.println(strSQLQuery);
			}
			else	
				strErrMsg = "Exception removed successfully.";
		}
	}

}

if(strSYFrom.length() > 0 && strStudIndex != null) {
	strSQLQuery = "select nstppe_exception_index, sub_code, sub_name, id_number, fname, mname, lname, last_date from CIT_DROP_NSTPPE_EXCEPTION "+
				"join subject on (subject.sub_index = sub_i) "+
				"join user_table on (user_index = employee_index) "+
				"where stud_index = "+strStudIndex+" and sy_f = "+strSYFrom+" and sem = "+strSemester+" and CIT_DROP_NSTPPE_EXCEPTION.is_valid = 1 order by sub_code";
	//System.out.println(strSQLQuery);
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vAllowDropList.addElement(rs.getString(1));//[0] nstppe_exception_index
		vAllowDropList.addElement(rs.getString(2));//[1] sub_code
		vAllowDropList.addElement(rs.getString(3));//[2] sub_name
		vAllowDropList.addElement(rs.getString(4));//[3] id_number
		vAllowDropList.addElement(WebInterface.formatName(rs.getString(5), rs.getString(6), rs.getString(7), 4));//[4] name
		vAllowDropList.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(8), true));//[5] last_date
		vAllowDropList.addElement("----"+rs.getString(2)+"----");//[6] , 1 = not yet dropped.. .
	}
	rs.close();
	
	
	CommonUtil.setSubjectInEFCLTable(dbOP);
	strSQLQuery = "select efcl_sub_index, sub_code, sub_name from enrl_final_cur_list "+
				"join subject on (sub_index = efcl_sub_index) "+
				"where user_index = "+strStudIndex+" and sy_from = "+strSYFrom+
				" and current_semester = "+strSemester+" and is_valid = 1 and (sub_code like 'nstp%' or sub_code like 'pe%') order by sub_code";//System.out.println(strSQLQuery);
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		bolEnrolled = true;
		iTemp = vAllowDropList.indexOf("----"+rs.getString(2)+"----");
		if(iTemp > -1) {
			vAllowDropList.setElementAt("1", iTemp);
			continue;
		}

		vEnrolledList.addElement(rs.getString(1));//[0] sub_index
		vEnrolledList.addElement(rs.getString(2));//[1] sub_code
		vEnrolledList.addElement(rs.getString(3));//[2] sub_name
	}
	rs.close();
}

dbOP.cleanUP();

if(strErrMsg == null) 
	strErrMsg = "";
%>
<form name="form_" action="./allow_dropping_nstp_pe_subject.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: ALLOW DROPPING NSTP-PE SUBJECT ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="28" width="1%">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=strErrMsg%></b></font> </td>
    </tr>
    <tr valign="top">
      <td height="25" width="1%">&nbsp;</td>
      <td width="15%">Student ID </td>
      <td width="22%"> </select> <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  onKeyUp="AjaxMapName(1);"></td>
      <td width="8%"><input type="image" onClick="ReloadPage();" src="../../../../images/form_proceed.gif">	  </td>
      <td width="54%">
	  	<label id="coa_info"></label>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY/Term : </td>
      <td colspan="3">
	  <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
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
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>	  </td>
    </tr>
  </table>
<%if(vEnrolledList != null && vEnrolledList.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td colspan="9" bgcolor="#FFFFFF" align="center" style="font-weight:bold; font-size:14px;" class="thinborderBOTTOM">List of NSTP-PE Subjects Enrolled</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
    <tr style="font-weight:bold" bgcolor="#33bbee">
      <td width="20%" height="25" class="thinborder">Subject Code</td>
      <td width="70%" class="thinborder">Subject Description </td>
      <td width="10%" class="thinborder" align="center">Select</td>
    </tr>
	<%
	iTemp = 0;
	for(int i =0; i < vEnrolledList.size(); i += 3) {%>
    <tr>
      <td height="25" class="thinborder"><%=vEnrolledList.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vEnrolledList.elementAt(i + 2)%></td>
      <td class="thinborder" align="center"><input type="checkbox" name="_<%=iTemp++%>" value="<%=vEnrolledList.elementAt(i)%>"></td>
    </tr>
	<%}%>
  </table>
  <input type="hidden" name="enrl_max" value="<%=iTemp%>">
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td> <u><strong>Allow Drop:</strong></u> <br>
	  Employee ID: 
	  <input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  onKeyUp="AjaxMapName(2);">
	  <label id="coa_info2" style="position:absolute; width:400px;"></label>
	  &nbsp;&nbsp;&nbsp;
	  <!--
	  Last Date of Exception(Optional): 
	  <input name="last_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("last_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  <a href="javascript:show_calendar('form_.last_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
		&nbsp;&nbsp;&nbsp;
	  -->
		<input type="button" name="_" value="Allow Drop" style="width:100px; height:26px; font-weight:bold" onClick="AllowDrop();">
	  </td>
    </tr>
  </table>
	
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
<%if(vAllowDropList != null && vAllowDropList.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td colspan="9" bgcolor="#FFFFFF" align="center" style="font-weight:bold; font-size:14px;" class="thinborderBOTTOM">Subject(s) Added to DROP Exception</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
    <tr style="font-weight:bold" bgcolor="#CCCCCC">
      <td width="15%" height="25" class="thinborder">Subject Code</td>
      <td width="55%" class="thinborder">Subject Description </td>
      <td width="20%" class="thinborder">Employee ID Allowed</td>
      <td width="10%" class="thinborder" align="center">Remove</td>
    </tr>
	<%
	for(int i =0; i < vAllowDropList.size(); i += 7) {%>
    <tr>
      <td height="25" class="thinborder"><%=vAllowDropList.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vAllowDropList.elementAt(i + 2)%></td>
      <td width="10%" class="thinborder"><%=vAllowDropList.elementAt(i + 3)%> <br><%=vAllowDropList.elementAt(i + 4)%></td>
      <td class="thinborder" align="center">
	  <%if(vAllowDropList.elementAt(i + 6).equals("1")){%>
	  	<a href="javascript:PageAction('0', '<%=vAllowDropList.elementAt(i)%>')"><img src="../../../../images/delete.gif" border="0"></a>
	  <%}else{%>
	  	Already Dropped.
	  <%}%>
	  </td>
		
    </tr>
	<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" align="center">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="page_action">
 <input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
