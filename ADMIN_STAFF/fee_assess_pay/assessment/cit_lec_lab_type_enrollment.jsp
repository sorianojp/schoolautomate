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
function UpdateEnrollment() {
	document.form_.page_action.value = '1';
	
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Payments-FEE MAINTENANCE-update lec-lab enrollment.","cit_lec_lab_type_enrollment.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"cit_lec_lab_type_enrollment.jsp");
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
Vector vRetResult     = new Vector();
String strSQLQuery    = null;
java.sql.ResultSet rs = null;

if(WI.fillTextValue("page_action").length() > 0) {
	
	int iMaxCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_count"), "0"));
	if(iMaxCount == 0) {
		strErrMsg = "No Result found.";
	}
	else {
		String strEnrlIndex = null;
		for(int i =0; i < iMaxCount; ++i) {
			strTemp = WI.fillTextValue("_type"+i);
			if(strTemp.length() == 0) 
				continue;
			strEnrlIndex = WI.fillTextValue("_"+i);
			if(strEnrlIndex.length() == 0) 
				continue;
			strSQLQuery = "update enrl_final_cur_list set is_only_lab = "+strTemp+" where enroll_index = "+strEnrlIndex;
			dbOP.executeUpdateWithTrans(strSQLQuery,  (String)request.getSession(false).getAttribute("login_log_index"),"ENRL_FINAL_CUR_LIST", true);
		}
	}
	
}

if(WI.fillTextValue("sy_from").length() > 0) {
	strSQLQuery = "select enroll_index, id_number, fname, mname, lname, sub_code, sub_name,course_code, year_level, UNIT_ENROLLED, "+
		"hour_lec, hour_lab, lec_unit, lab_unit,IS_ONLY_LAB from ENRL_FINAL_CUR_LIST "+
		"join STUD_CURRICULUM_HIST on (STUD_CURRICULUM_HIST.user_index = ENRL_FINAL_CUR_LIST.user_index) "+
		"	and STUD_CURRICULUM_HIST.sy_from = ENRL_FINAL_CUR_LIST.sy_from"+
		"	and semester = CURRENT_SEMESTER "+
		"join user_Table on (STUD_CURRICULUM_HIST.user_index = user_Table.user_index) "+
		"join course_offered on (STUD_CURRICULUM_HIST.course_index = course_offered.course_index) "+
		"join curriculum on (curriculum.cur_index = ENRL_FINAL_CUR_LIST.cur_index) "+
		"join subject on (subject.sub_index = curriculum.sub_index) "+
		"where ENRL_FINAL_CUR_LIST.sy_from = "+WI.fillTextValue("sy_from")+" and ENRL_FINAL_CUR_LIST.CURRENT_SEMESTER = "+WI.fillTextValue("semester")+
		"and ENRL_FINAL_CUR_LIST.is_valid = 1 and is_temp_stud = 0 and course_offered.DEGREE_TYPE = 0 and lec_unit + lab_unit <> UNIT_ENROLLED "+
		"and exists (select * from fa_tution_fee join fa_schyr on (fa_schyr.sy_index = fa_tution_fee.sy_index) "+
		"where fa_tution_fee.is_valid = 1 and fa_schyr.sy_from = enrl_final_cur_list.sy_from and fee_type_catg = 4 and sub_index = subject.sub_index) "+
		"order by lname, sub_code";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vRetResult.addElement(rs.getString(1));//[0] enroll_index
		vRetResult.addElement(rs.getString(2));//[1] id_number
		vRetResult.addElement(WebInterface.formatName(rs.getString(3),rs.getString(4),rs.getString(5),4));//[2] Name
		vRetResult.addElement(rs.getString(6));//[3] sub_code
		vRetResult.addElement(rs.getString(7));//[4] sub_name
		vRetResult.addElement(rs.getString(8));//[5] course_code
		vRetResult.addElement(rs.getString(9));//[6] year_level
		vRetResult.addElement(rs.getString(10));//[7] UNIT_ENROLLED
		vRetResult.addElement(rs.getString(11));//[8] hour_lec
		vRetResult.addElement(rs.getString(12));//[9] hour_lab
		vRetResult.addElement(rs.getString(13));//[10] lec_unit
		vRetResult.addElement(rs.getString(14));//[11] lab_unit
		vRetResult.addElement(rs.getString(15));//[12] IS_ONLY_LAB
	}
	rs.close();
}

%>
<form action="./cit_lec_lab_type_enrollment.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LIST OF STUDENT TAKING DRY LAB AS COMPLETION UNIT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%"></td>
	  <td width="98%" > <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">School Year/Term</td>
      <td width="22%"> 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> 
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> 
		<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="0">Summer</option>
<%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
      <td width="63%"><input type="button" name="_" value="Refresh Page" onClick="document.form_.page_action.value='';document.form_.submit();"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center" style="font-weight:bold; font-size:11px;" bgcolor="#FFCC99">List of student with completion unit enrolled in dry lab</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#CCCCCC" style="font-weight:bold" align="center"> 
      <td height="22" class="thinborder" width="5%">Count</td>
      <td class="thinborder" width="10%">Student ID</td>
      <td class="thinborder" width="15%">Student Name</td>
      <td class="thinborder" width="10%">Subject</td>
      <td class="thinborder" width="10%">Course-Year</td>
      <td class="thinborder" width="5%">Unit Enrolled</td>
      <td class="thinborder" width="5%">Lec unit</td>
      <td class="thinborder" width="5%">Lab Unit</td>
      <td class="thinborder" width="5%">Lec Hour</td>
      <td class="thinborder" width="5%">Lab Hour</td>
      <td class="thinborder" width="5%">Enrolled In</td>
      <td class="thinborder" width="5%">Update</td>
    </tr>
	<%
	int iCount = 0;
	String[] astrConvertLecLabType = {"Lec-Lab","Lab","Lec"};
	String strBGColor = "";
	while(vRetResult.size() > 0) {
	strTemp = (String)vRetResult.elementAt(12);
	if(strTemp.equals("0"))
		strBGColor = " bgcolor='#FFCC66'";
	else	
		strBGColor = "";// bgcolor="#FFCC66"
	%>
		<tr<%=strBGColor%>>
		  <td height="22" class="thinborder"><%=++iCount%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(1)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(2)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(3)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(5)%> - <%=vRetResult.elementAt(6)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(7)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(10)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(11)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(8)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(9)%></td>
		  <td class="thinborder"><%=astrConvertLecLabType[Integer.parseInt((String)vRetResult.elementAt(12))]%></td>
		  <td class="thinborder">
		  <select name="_type<%=iCount%>">
		  	<option value=""></option>
		  	<option value="0">Lec-Lab</option>
			<option value="1">Lab Only</option>
			<option value="2">Lec Only</option>
		  </select>		  
		  <input type="hidden" name="_<%=iCount%>" value="<%=vRetResult.elementAt(0)%>">
		  </td>
	    </tr>
	<%vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);}%>
	<input type="hidden" name="max_count" value="<%=iCount%>">
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center">
	  	<input type="button" name="_" value="<<< Update Lec/Lab Enrollment >>>" onClick="UpdateEnrollment();"style="font-size:11px; height:30px; width:160px; border: 1px solid #FF0000;">
	 </td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    
    <tr bgcolor="#FFFFFF"> 
      <td width="711%" height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
