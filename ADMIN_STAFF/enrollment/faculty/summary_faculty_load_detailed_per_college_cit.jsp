<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function SearchPage() {
	document.form_.search_page.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage(){
	document.form_.search_page.value = "";
	this.SubmitOnce('form_');
}
function PrintPg() {
	if(!document.form_.search_page) {
		alert("Please wait.. Page is loading.");
		return;
	}
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	

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
								"Admin/staff-Enrollment-Faculty-Summary Load","summary_faculty_load_per_college_dept.jsp");
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

///I have to get details here. 
Vector vRetResult = new Vector();
String strSQLQuery = "";

if(WI.fillTextValue("sy_from").length() > 0) {
	if(WI.fillTextValue("c_index").length() > 0) 
		strSQLQuery = " and inf_faculty_basic.c_index = "+WI.fillTextValue("c_index");
	if(WI.fillTextValue("d_index").length() > 0) 
		strSQLQuery = " and inf_faculty_basic.d_index = "+WI.fillTextValue("d_index");
	
	strSQLQuery = "select id_number, fname, mname, lname, c_code, d_code, sub_code, sub_name, section, is_lec, load_unit, lec_um, lab_um from faculty_load "+
				  "join user_table on (user_table.user_index = faculty_load.user_index) "+
				  "join info_faculty_basic on (info_faculty_basic.user_index = faculty_load.user_index) "+
				  "left join college on (college.c_index = info_faculty_basic.c_index) "+
				  "left join department on (department.d_index = info_faculty_basic.d_index) "+
				  "join e_sub_section on (e_sub_section.sub_sec_index = faculty_load.sub_sec_index) "+
				  "join subject on (subject.sub_index = e_sub_section.sub_index) "+
				  "left join ( "+
				  	"select max(lec_unit) as lec_um, max(lab_unit) as lab_um, sub_index as si from curriculum where is_valid = 1 group by sub_index "+
				  ") as DT_C on DT_C.si = subject.sub_index "+
				  "where offering_sy_from = "+WI.fillTextValue("sy_from")+" and offering_sem = "+
				  WI.fillTextValue("semester")+" and faculty_load.is_valid =1  "+
				  "order by lname, fname, sub_code";
}

String[] astrConvertToTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
%>
<body>
<form action="./summary_faculty_load_detailed_per_college_cit.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td height="25" colspan="3"><div align="center"><strong>:::: FACULTY : SUMMARY OF FACULTY LOAD ::::</strong></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="12%" height="25">School Year</td>
      <td width="85%" height="25">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp; <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
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
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">College</td>
      <td height="25"><select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%
	strTemp = WI.fillTextValue("c_index");

if(strTemp == null || strTemp.trim().length() == 0) strTemp = "0";
if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%=strTemp2%></td>
      <td height="25"><select name="d_index">
          <option value="">All</option>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and ("+
		  	WI.getStrValue(strTemp, "c_index=",""," c_index = 0 or c_index is null")+") order by d_name asc",WI.fillTextValue("d_index"), false)%> </select></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td width="3%" height="39">&nbsp;</td>
      <td width="97%"><a href="javascript:SearchPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print summary</font></div></td>
    </tr>
  </table>
<%if(strSQLQuery.length() > 0) { //System.out.println(vRetResult.size() + ":::"+vRetResult);%>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" style="font-weight:bold" align="center">
  	   FACULTY LOAD For  <%=astrConvertToTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="5%" class="thinborder"><font size="1">Count</font></td>
      <td width="10%" class="thinborder"><font size="1">Faculty ID</font></td>
      <td width="25%" class="thinborder"><font size="1">Faculty Name</font></td> 
      <td width="15%" height="25" class="thinborder"><font size="1">College-Dept</font></td>
      <td width="15%" class="thinborder"><font size="1">Subject Code </font></td>
      <td width="5%" class="thinborder"><font size="1">Subject Type</font></td>
      <td width="5%" class="thinborder"><font size="1">Load Type</font></td>
      <td width="5%" class="thinborder"><font size="1">Load Unit</font></td>
      <!--<td width="20%" class="thinborder"><font size="1">Subject Name </font></td> -->
      <td width="15%" class="thinborder"><font size="1">Section</font></td>
    </tr>
	<%
	
	String strSubjectType = null;
	String strLoadType    = null;
	
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	int iCount = 0;
		while(rs.next()) {
		strTemp = rs.getString(5);
		if(strTemp == null)
			strTemp = rs.getString(6);
		else	
			strTemp = strTemp + WI.getStrValue(rs.getString(6), " - ", "", "");
		strSubjectType = "Lec";
		strLoadType = rs.getString(10);
		if(strLoadType.equals("1")) {
			strLoadType = "Lab";
			strSubjectType = "Lec/Lab";
		}
		else {//Load type is lec.. 
			if(rs.getDouble(13) == 0) {//lec only subject.. 
				strLoadType = "Lec";
				strSubjectType = "Lec";
			}
			else {//may be lab only or lec/lab.. 
				if(rs.getDouble(12) == 0) {
					strLoadType = "Lab";
					strSubjectType = "Lab";
				}
				else {
					strLoadType = "Lec";
					strSubjectType = "Lec/Lab";
				}
			}
		}
		%>
			<tr>
			  <td class="thinborder"><%=++iCount%></td>
			  <td class="thinborder"><%=rs.getString(1)%></td>
			  <td class="thinborder"><%=WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4)%></td> 
			  <td height="25" class="thinborder"><%=strTemp%></td>
			  <td class="thinborder"><%=rs.getString(7)%></td>
			  <td class="thinborder"><%=strSubjectType%></td>
			  <td class="thinborder"><%=strLoadType%></td>
			  <td class="thinborder"><%=CommonUtil.formatFloat(rs.getDouble(11), true)%></td>
			  <!--<td class="thinborder"><font size="1"><%=rs.getString(8)%></font></td>-->
			  <td class="thinborder"><%=rs.getString(9)%></td>
		    </tr>
		<%}
		rs.close();%>
  </table>
<%}//only if vRetResult is not null%>
<input type="hidden" name="search_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>