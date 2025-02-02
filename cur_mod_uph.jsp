<%
String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
String strLoginID = (String)request.getSession(false).getAttribute("userId");

if(strAuthIndex == null || strAuthIndex.equals("4") || strLoginID == null || strLoginID.equals("sa-01") ) {%>
	<p align="center" style="font-size:16px; font-weight:bold; color:#FF0000"> You are not allowed to access this page.
<%return;}%>



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="./css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="./css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="./jscript/date-picker.js"></script>
<script language="JavaScript" src="./jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(strResetSection) {
	document.form_.page_action.value = '';
	document.form_.show_list.value = '';
	
	if(document.form_.major_index)
		document.form_.major_index.selectedIndex = -1;
	if(document.form_.cy_f)
		document.form_.cy_f.selectedIndex = -1;
	if(document.form_.sub_)
		document.form_.sub_.selectedIndex = -1;

	document.form_.submit();
}
function ShowList() {
	document.form_.show_list.value = '1';
	document.form_.page_action.value = '';
	document.form_.submit();
}
function DeleteCur(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = '0';
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,java.util.Vector" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strPaymentFor = null;//fine-fine description or other school fee - fee name
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
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
	String strSQLQuery = null;
	java.sql.ResultSet rs = null;
	
	Vector vCurYr   = new Vector();
	Vector vSubList = new Vector();
	String strSYFrom   = WI.fillTextValue("sy_from");
	String strSemester = WI.fillTextValue("semester");
	
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0 && WI.fillTextValue("info_index").length() > 0) {
String strDeleteDate = WI.getTodaysDate()+" 01:01:00";
	
	strSQLQuery = "update curriculum set is_valid = 0, is_del = 1, last_mod_by = "+(String)request.getSession(false).getAttribute("userIndex")+
			", last_mod_date='"+strDeleteDate+"', inactive_reason = 'Deleted thru new page' where cur_index = "+WI.fillTextValue("info_index");
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
			
	strSQLQuery = "update e_sub_section set is_valid = 0, is_del = 1, last_mod_by = "+(String)request.getSession(false).getAttribute("userIndex")+
			", last_mod_date='"+strDeleteDate+"' where cur_index = "+WI.fillTextValue("info_index")+" and degree_type = 0 and is_valid = 1 and offering_sy_From = "+
			strSYFrom+" and offering_sem = "+strSemester;
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	
	strErrMsg = "Curriculm Removed successfully.";
}
	
if(WI.fillTextValue("course_index").length() > 0) {
	strSQLQuery = "select distinct sy_from, sy_to from curriculum where is_valid = 1 and  course_index = "+
		WI.fillTextValue("course_index")+WI.getStrValue(WI.fillTextValue("major_index"), " and major_index = ", "","")+
		" order by sy_from desc"; //System.out.println(strSQLQuery);
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vCurYr.addElement(rs.getString(1));
		vCurYr.addElement(rs.getString(2));
	}
	rs.close();

	if(WI.fillTextValue("cy_f").length() > 0){
		String strCYFRTO = WI.fillTextValue("cy_f");
		
	    String strCYFrom = strCYFRTO.substring(0, strCYFRTO.indexOf("-"));
    	String strCYTo   = strCYFRTO.substring(strCYFRTO.indexOf("-") + 1);

		strSQLQuery = "select cur_index, subject.sub_index, sub_code, sub_name, year, semester from curriculum join subject on (subject.sub_index = curriculum.sub_index) where course_index = "+
		WI.fillTextValue("course_index")+
			" and (major_index is null or major_index = "+WI.getStrValue(WI.fillTextValue("major_index"), null)+") and is_valid = 1 and sy_from = "+strCYFrom+
			" and sy_to = "+strCYTo +" order by sub_code";
		//System.out.println(strSQLQuery);
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vSubList.addElement(rs.getString(1));//[0] cur_index
			vSubList.addElement(rs.getString(2));//[1] sub_index
			vSubList.addElement(rs.getString(3));//[2] sub_code
			vSubList.addElement(rs.getString(4));//[3] sub_name
			vSubList.addElement(rs.getString(5));//[4] year
			vSubList.addElement(rs.getString(6));//[5] semester
		}
		rs.close();
	}

}

//I have to now list student who are enrolled in this curriculum.. 
Vector vEnrolledCur = new Vector();
Vector vEnrolledSub = new Vector();
Vector vOtherInfo   = new Vector();//[0] how many class program, [2] student having grade in previous sem.. 
	String strCurSubIndex = null;
	String strCurIndex    = null;
	String strSubIndex    = null;
if(WI.fillTextValue("sub_").length() > 0 && WI.fillTextValue("show_list").length() > 0) {
	strCurSubIndex = WI.fillTextValue("sub_");
	strCurIndex    = strCurSubIndex.substring(0, strCurSubIndex.indexOf(","));
	strSubIndex    = strCurSubIndex.substring(strCurSubIndex.indexOf(",") + 1);
	//System.out.println(strCurSubIndex);
	//System.out.println(strCurIndex);
	//System.out.println(strSubIndex);
	 
	
	strSQLQuery = "select id_number, fname, mname, lname, sy_from, current_semester from enrl_final_cur_list "+
					"join user_table on (user_Table.user_index = enrl_final_cur_list.user_index) "+
					" where enrl_final_cur_list.is_valid = 1 and cur_index = "+strCurIndex+
					" and is_temp_stud = 0 order by lname";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vEnrolledCur.addElement(rs.getString(1));//[0] id_number
		vEnrolledCur.addElement(WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));//[1] name
		vEnrolledCur.addElement(rs.getString(5));//[2] sy_from
		vEnrolledCur.addElement(rs.getString(6));//[3] semester
		vEnrolledCur.addElement("0");//[4] is_temp_stud
	}
	rs.close();
	strSQLQuery = "select temp_id, fname, mname, lname, enrl_final_cur_list.sy_from, current_semester from enrl_final_cur_list "+
					"join new_application on (application_index = enrl_final_cur_list.user_index) "+
					"join na_personal_info on (na_personal_info.application_index = new_application.application_index) "+
					" where enrl_final_cur_list.is_valid = 1 and cur_index = "+strCurIndex+
					" and is_temp_stud = 0 order by lname";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vEnrolledCur.addElement(rs.getString(1));//[0] id_number
		vEnrolledCur.addElement(WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));//[1] name
		vEnrolledCur.addElement(rs.getString(5));//[2] sy_from
		vEnrolledCur.addElement(rs.getString(6));//[3] semester
		vEnrolledCur.addElement("1");//[4] is_temp_stud
	}
	rs.close();
	
	CommonUtil.setSubjectInEFCLTable(dbOP);
	
	//get student enrolled in subject.. 
	
	
	//check subject offered in clas program.
	strSQLQuery = "select count(*) from e_sub_section where cur_index = "+strCurIndex+" and offering_sy_From = "+strSYFrom+" and offering_sem = "+strSemester+
		" and is_valid = 1 and degree_type = 0";System.out.println(strSQLQuery);
	rs = dbOP.executeQuery(strSQLQuery);
	rs.next();
	vOtherInfo.addElement(rs.getString(1));
	rs.close();
	strSQLQuery = "select count(*) from e_sub_section where cur_index <> "+strCurIndex+" and offering_sy_From = "+strSYFrom+" and offering_sem = "+strSemester+
		" and is_valid = 1 and sub_index="+strSubIndex;System.out.println(strSQLQuery);
	rs = dbOP.executeQuery(strSQLQuery);
	rs.next();
	vOtherInfo.addElement(rs.getString(1));
	rs.close();
	
}

%>
<form name="form_" action="./cur_mod_uph.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          TEMPORARY - OR DATE MODIFICATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY-Term</td>
      <td height="25" style="font-weight:bold; font-size:14px;">2013-2014, 2nd Sem
	  
	  <input type="hidden" name="sy_from" value="2013">
	  <input type="hidden" name="sy_to" value="2014">
	  <input type="hidden" name="semester" value="2">	  </td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="12%" height="25">Course</td>
      <td width="84%" height="25">
	  <select name="course_index" onChange="ReloadPage();" style="font-size:14px; width:500px;">
	  	<option value=""></option>
		<%=dbOP.loadCombo("course_index","course_code,course_name"," from course_offered where IS_DEL=0 AND is_valid = 1 and degree_type = 0 and is_offered = 1 and exists (select course_index from curriculum where is_valid = 1 and course_index = course_offered.course_index) order by course_name asc",	WI.fillTextValue("course_index"), false)%> 
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Major</td>
      <td height="25">
	  <select name="major_index" style="font-size:14px;">
	<%if(WI.fillTextValue("course_index").length() > 0) {%>
				<%=dbOP.loadCombo("major_index","major_name"," from	 major where IS_DEL=0 and course_index = " + WI.fillTextValue("course_index") + " order by major_name asc",	WI.fillTextValue("major_index"), false)%> 
	<%}%>
		</select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Cur Year </td>
      <td height="25">
		<select name="cy_f" onChange="document.form_.submit();">
		<option value=""></option>
		<%
		strTemp = WI.fillTextValue("cy_f");
		for(int i = 0; i < vCurYr.size(); i += 2) {
			if(strTemp.equals(vCurYr.elementAt(i)+"-"+vCurYr.elementAt(i+1)))
				strErrMsg = " selected";
			else	
				strErrMsg = "";
		%>
			<option value="<%=vCurYr.elementAt(i)+"-"+vCurYr.elementAt(i+1)%>"<%=strErrMsg%>><%=vCurYr.elementAt(i) + "-"+vCurYr.elementAt(i + 1)%></option>
		<%}%>	  
	</select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>subject </td>
      <td height="25">
	  <select name="sub_" style="width:600px;">
<%
String strTemp2 = null;
strTemp = WI.fillTextValue("sub_");
for(int i = 0; i < vSubList.size(); i += 6) {
	strTemp2 = (String)vSubList.elementAt(i) + ","+(String)vSubList.elementAt(i + 1);
	if(strTemp.equals(strTemp2))
		strErrMsg = " selected";
	else	
		strErrMsg = "";
	%>
		<option value="<%=strTemp2%>"<%=strErrMsg%>><%=vSubList.elementAt(i + 2)%> (<%=vSubList.elementAt(i + 3)%>): Year :<%=vSubList.elementAt(i + 4)%> Semester:<%=vSubList.elementAt(i + 5)%> </option>
<%}%>
	  </select>	  </td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>
	  <input type="button" name="12" id="_update_date" value=" Show List >> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="ShowList();">
	  </td>
    </tr>
  </table>
<%if(WI.fillTextValue("sub_").length() > 0 && WI.fillTextValue("show_list").length() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="50%" height="25"><%if(vOtherInfo != null && vOtherInfo.size() > 0) {%>	
	  	Class Program: <%=vOtherInfo.elementAt(0)%> (Curriculum), <%=vOtherInfo.elementAt(1)%> (Subject)
		<%}%>
		</td>
      <td width="50%" align="right">
	  <%if(strCurIndex != null) {%>
	  		<input type="button" name="12" id="_update_date" value=" Delete Subject From Curriculm >> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="DeleteCur('<%=strCurIndex%>');">
	  <%}%>
	  </td>
    </tr>
    <tr>
      <td height="25" colspan="2" align="center" bgcolor="#cccccc" style="font-weight:bold">List of Students Enrolled in Curriculum</td>
    </tr>
  </table>
  <%if(vEnrolledCur != null && vEnrolledCur.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold" align="center">
      <td height="22" width="20%" class="thinborder">Student ID </td>
      <td width="45%" class="thinborder">Student Name </td>
      <td width="15%" class="thinborder">SY-Term</td>
      <td width="10%" class="thinborder">Is Temp Student </td>
    </tr>
	<%for(int i = 0; i < vEnrolledCur.size(); i += 5) {%>
		<tr>
		  <td height="22" class="thinborder"><%=vEnrolledCur.elementAt(i)%></td>
		  <td class="thinborder"><%=vEnrolledCur.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=vEnrolledCur.elementAt(i + 2)%> - <%=vEnrolledCur.elementAt(i + 3)%></td>
		  <td class="thinborder"><%=vEnrolledCur.elementAt(i + 4)%></td>
		</tr>
	<%}%>
  </table>
  <%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="center" style="font-weight:bold">No Student enrolled.. </td>
    </tr>
  </table>
  <%}%>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="show_list">
  <input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>