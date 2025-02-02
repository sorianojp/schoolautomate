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
	String strTemp3 = null;

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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();

    Vector vCollegeDeptList = null;//[0]college index,[1] dept index, [2] college name, [3] dept name.
    Vector vRetResult       = null;//[0]college index, [1] dept inde, [2] employee ID, [3] fname, [4] mname, [5] lname, [6] total load, [7] vLoadSchedDetail
    Vector vLoadSchedDetail = null;//[0]subj code, [1] subj name, [2] Section, [3] schedule, [4] Room number, [5] no of stud.


if(WI.fillTextValue("search_page").length() > 0) {
	enrollment.FacultyManagementExtn fmExtn = new enrollment.FacultyManagementExtn();
	vRetResult = fmExtn.viewDetailedFacultyLoadPerCollege(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = fmExtn.getErrMsg();	
	else
		vCollegeDeptList = (Vector)vRetResult.remove(0);
}

String[] astrConvertToTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<body>
<form action="./summary_faculty_load_detailed_per_college.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td height="25" colspan="3"><div align="center"><strong>:::: FACULTY : SUMMARY OF FACULTY LOAD PER COLLEGE/DEPARTMENT PAGE ::::</strong></div></td>
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
        </select>

	  &nbsp;&nbsp;&nbsp; 
<%
if(strSchCode.startsWith("EAC") && request.getParameter("sy_from") == null)
	strTemp = " checked";
else
	strTemp = WI.fillTextValue("inc_subname");
%>
	  <input type="checkbox" name="inc_subname" value="checked" <%=strTemp%>> Include Subject Description

		</td>
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
          <%
strTemp3 = WI.fillTextValue("d_index");
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and ("+WI.getStrValue(strTemp, "c_index=",""," c_index = 0 or c_index is null")+") order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable2">
    <tr> 
      <td width="3%" height="39">&nbsp;</td>
      <td width="97%"><a href="javascript:SearchPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print summary</font></div></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) { //System.out.println(vRetResult.size() + ":::"+vRetResult);%>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" style="font-weight:bold" align="center">
	  	DETAILED FACULTY LOAD PER COLLEGE/DEPT For AY : <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>, <%=astrConvertToTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold"> 
      <td width="15%" height="25" class="thinborder"><font size="1">Subject Code</font></td>
      <td width="30%" class="thinborder"><font size="1">Subject Title </font></td>
      <td width="15%" class="thinborder"><font size="1">Section</font></td> 
      <td width="20%" class="thinborder"><font size="1">Schedule</font></td>
      <td width="10%" class="thinborder"><font size="1">Room Number </font></td>
      <td width="10%" class="thinborder"><font size="1">Number Of Stud </font></td>
    </tr>
	<%
	enrollment.FacultyManagement FM = new enrollment.FacultyManagement();
	String strFacultyIndex = null;
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSYTo   = WI.fillTextValue("sy_to");
	String strSem    = WI.fillTextValue("semester");
	
	String strCollegeIndex = null; String strDeptIndex = null;
	String strCollegeNameToDisp = null;
	for(int i = 0 ; i < vCollegeDeptList.size(); i += 4) {
		strCollegeIndex = (String)vCollegeDeptList.elementAt(i);
		strDeptIndex    = (String)vCollegeDeptList.elementAt(i + 1);
		strCollegeNameToDisp = (String)vCollegeDeptList.elementAt(i + 2);
		if(strCollegeNameToDisp == null)
			strCollegeNameToDisp = (String)vCollegeDeptList.elementAt(i + 3);
		else if(vCollegeDeptList.elementAt(i + 3) != null)
			strCollegeNameToDisp = strCollegeNameToDisp +"/ "+vCollegeDeptList.elementAt(i + 3);
		%>
    <tr style="font-weight:bold"> 
      <td width="15%" height="25" class="thinborder" colspan="6"><font size="1"><%=strCollegeNameToDisp%></font></td>
    </tr>
		<%
		if(strCollegeIndex == null) strCollegeIndex = "";
		if(strDeptIndex == null) strDeptIndex = "";		 
		while(true && vRetResult.size() > 0) {
			if( !strCollegeIndex.equals(WI.getStrValue(vRetResult.elementAt(1),"")) || !strDeptIndex.equals(WI.getStrValue(vRetResult.elementAt(2),"")) )
				break;
			strFacultyIndex = String.valueOf(vRetResult.remove(0));//faculty Index.
			vRetResult.remove(0);vRetResult.remove(0);
			%>
			<tr style="font-weight:bold"> 
			  <td width="15%" height="25" class="thinborder" colspan="6"><font size="1"><%=vRetResult.remove(1)%>(<%=vRetResult.remove(0)%>) , Total Load : <%=vRetResult.remove(0)%></font></td>
			</tr>
		<%
		vLoadSchedDetail = (Vector)vRetResult.remove(0);
		vLoadSchedDetail = FM.viewFacultyLoadSummary(dbOP,strFacultyIndex,strSYFrom, strSYTo, strSem);
		if(vLoadSchedDetail == null)
			vLoadSchedDetail = new Vector();
		//[0] = sub_code, [1] = sub_name,[2]=college_offering,[3]=lec/lab unit,[4]=section
		//[5]=schedule,[6]=room_no, [7]= no_of_enrolled_stud -- called in view load slip.[8] = load unit.
		while(vLoadSchedDetail.size() > 0) {
		vLoadSchedDetail.remove(8);vLoadSchedDetail.remove(3);vLoadSchedDetail.remove(2);
		%>
			<tr> 
			  <td width="15%" height="25" class="thinborder"><font size="1"><%=vLoadSchedDetail.remove(0)%></font></td>
			  <td width="35%" class="thinborder"><font size="1"><%=vLoadSchedDetail.remove(0)%></font></td>
			  <td width="15%" class="thinborder"><font size="1"><%=vLoadSchedDetail.remove(0)%></font></td> 
			  <td width="15%" class="thinborder"><font size="1"><%=vLoadSchedDetail.remove(1)%></font></td>
			  <td width="10%" class="thinborder"><font size="1"><%=vLoadSchedDetail.remove(0)%></font></td>
			  <td width="10%" class="thinborder" align="center"><font size="1"><%=vLoadSchedDetail.remove(0)%></font></td>
			</tr>
		<%}	
		
		/**if(vLoadSchedDetail == null) 
			vLoadSchedDetail = new Vector();
		while(vLoadSchedDetail.size() > 0) {%>
			<tr> 
			  <td width="15%" height="25" class="thinborder"><font size="1"><%=vLoadSchedDetail.remove(0)%></font></td>
			  <td width="35%" class="thinborder"><font size="1"><%=vLoadSchedDetail.remove(0)%></font></td>
			  <td width="15%" class="thinborder"><font size="1"><%=vLoadSchedDetail.remove(0)%></font></td> 
			  <td width="15%" class="thinborder"><font size="1"><%=vLoadSchedDetail.remove(0)%></font></td>
			  <td width="10%" class="thinborder"><font size="1"><%=vLoadSchedDetail.remove(0)%></font></td>
			  <td width="10%" class="thinborder" align="center"><font size="1"><%=vLoadSchedDetail.remove(0)%></font></td>
			</tr>
		<%}//end of printing load schedule..**/ 
		}//end if while(true) printing faculty per college/dept.
		
	}//end of outer for loop for college.%>
	
  </table>
<%}//only if vRetResult is not null%>
<input type="hidden" name="search_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>