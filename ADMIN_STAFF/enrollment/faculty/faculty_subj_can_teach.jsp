<%if(request.getParameter("forward_page") != null && request.getParameter("forward_page").compareTo("1") == 0){%>
<jsp:forward page="./faculty_sched_multiple.jsp" />
<%}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function reloadPage(){	
	if(document.form_.sub_group.selectedIndex == 0) {
		alert("Please select a subject group");
		return;
	}
	if(document.form_.sub_index.selectedIndex == 0) {
		alert("Please select a subject");
		return;
	}
	document.form_.submit();
}

function UpdateChangeSubject(){
 	if (document.form_.sub_index.selectedIndex==0)
		document.form_.sub_code.value = "";
	else
		document.form_.sub_code.value = document.form_.sub_index[document.form_.sub_index.selectedIndex].text;
}

function UpdateSubjectGroup(){
	document.form_.sub_index.selectedIndex = 0;
	//document.form_.sub_code.value = "";
	document.form_.submit();
}



function PrintPage(){
//	document.form_.print_page.value = "1";
//	document.form_.submit();
	document.bgColor = "#FFFFFF";
	//return; 	
    document.getElementById('myTable1').deleteRow(0);
    document.getElementById('myTable2').deleteRow(0);
    document.getElementById('myTable2').deleteRow(0);
    document.getElementById('myTable2').deleteRow(0);
    document.getElementById('myTable2').deleteRow(0);
    document.getElementById('myTable3').deleteRow(0);
    document.getElementById('myTable4').deleteRow(0);
    document.getElementById('myTable4').deleteRow(0);
	alert("Click OK to print this page");
	window.print();
	
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean[] bolConflict = {false}; // this is passed to getSubjectScheduleTime to check if the subject is conflict with the previous

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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-REPORTS"),"0"));
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
								"Admin/staff-Enrollment-Faculty-reports","faculty_subj_can_teach.jsp");
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
														"faculty_subj_can_teach.jsp");
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

String strOfferingYrFrom = WI.fillTextValue("sy_from");
String strOfferingYrTo =  WI.fillTextValue("sy_to");
String strOfferingSem  =  WI.fillTextValue("semester");
String strSubIndex =  WI.fillTextValue("sub_index");

Vector vFacultyList  = null;
	
if(strErrMsg == null && strOfferingYrFrom.length() > 0 && strOfferingYrTo.length() > 0 
 && strOfferingSem.length() > 0 && strSubIndex.compareTo("0")!=0)
{
	FacultyManagement FM = new FacultyManagement();
	
	vFacultyList = FM.viewFacPerCollegeWithLoadStat(dbOP, "0","0",strOfferingYrFrom,strOfferingYrTo,strOfferingSem,"",false,0f,"0",strSubIndex);
	
	
	if(vFacultyList == null)
		strErrMsg = FM.getErrMsg();
}
%>
<form name="form_" action="./faculty_subj_can_teach.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          FACULTY PAGE - LOADING/SCHEDULING ::::</strong></font></div></td>
    </tr>
    <%
if(strErrMsg != null)
{%>
    <tr>
      <td width="2%" height="27">&nbsp;</td>
      <td width="98%"><%=strErrMsg%></td>
    </tr>
    <%dbOP.cleanUP();return;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
    <tr>
      <td height="25">&nbsp;</td>
      <td>School Year : </td>
      <td>
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Subject Group: </td>
      <td><select name="sub_group" onChange="UpdateSubjectGroup();">
          <option value="">Select Subject Group</option>
          <%=dbOP.loadCombo("group_index","group_name"," from subject_group where IS_DEL=0 order by group_name asc", WI.fillTextValue("sub_group"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="19%">Subject Title(code) : </td>
      <td width="79%"><b> 
        <select name="sub_index" style="width:500px;">
		<option value="0">Select a Subject</option>
          <% if (WI.fillTextValue("sub_group").length()!=0){ %>
          <%=dbOP.loadCombo("sub_index","sub_code, sub_name"," from subject where IS_DEL=0 and GROUP_INDEX = " +  WI.fillTextValue("sub_group") + "order by sub_code asc",  WI.fillTextValue("sub_index"), false)%> 
          <%}else{%>
          <%=dbOP.loadCombo("sub_index","sub_code, sub_name"," from subject where IS_DEL=0 order by sub_code asc",  WI.fillTextValue("sub_index"), false)%> 
          <%}%>
        </select>
        </b></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:reloadPage();"><img src="../../../images/view.gif" width="40" border="0" height="31"></a><font size="1">Click 
        to view List</font></td>
    </tr>
  </table>
<% if (vFacultyList != null && vFacultyList.size() > 0) {%>
<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" id="myTable3">
   <tr>
      <td height="25" colspan="9"><div align="right"><a href="javascript:PrintPage()"><img border="0" src="../../../images/print.gif" width="58" height="26"></a><font size="1">click 
          to print list</font></div></td>
    </tr>
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="9" bgcolor="#B9B292"><div align="center"><strong>List of Faculty can teach for subject : </strong>
            <label id="sub_code" style="font-weight:bold"></label>
          </div></td>
    </tr>
<script>
if(document.form_.sub_index.selectedIndex > 0) {
	var objSub = document.getElementById("sub_code");
	if(objSub)
		objSub.innerHTML = document.form_.sub_index[document.form_.sub_index.selectedIndex].text;
}
</script>
  </table>
  <table width="100%" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>COLLEGE 
          :: DEPT</strong></font></div></td>
      <td width="13%" height="20" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE 
          ID</strong></font></div></td>
      <td width="32%" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE 
          NAME(LNAME,FNAME,MI)</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>GENDER</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>EMP. 
          STATUS</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>MAX 
          ALLOWED LOAD</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>TOTAL 
          LOAD</strong></font></div></td>
    </tr>
    <%
 for(int i = 0 ; i< vFacultyList.size(); ++i){%>
    <tr> 
      <td class="thinborder" height="25">&nbsp;<%=WI.getStrValue(vFacultyList.elementAt(i+5))%></td>
      <td class="thinborder">&nbsp;<%=(String)vFacultyList.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vFacultyList.elementAt(i+2)%></td>
      <td class="thinborder" align="center"><%=(String)vFacultyList.elementAt(i+4)%></td>
      <td class="thinborder" align="center"><%=(String)vFacultyList.elementAt(i+3)%></td>
      <td class="thinborder" align="center"> <%if( ((String)vFacultyList.elementAt(i+8)).compareTo("0") == 0){%> <font color="#0000FF">Not Set</font> <%}else{%> <%=WI.getStrValue((String)vFacultyList.elementAt(i+8))%> <%}%></td>
      <td class="thinborder" align="center"><%=WI.getStrValue((String)vFacultyList.elementAt(i+6))%></td>
    </tr>
    <%i = i+9;}
	}//end if exist %>    
</table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable4"bgcolor="#FFFFFF">
    <tr>
      <td width="84%">&nbsp;</td>
      <td width="16%" height="25">&nbsp; </td>
    </tr>
    <tr>
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table><input type="hidden" name="fac_name">
  <input type="hidden" name="fac_index">

  <input type="hidden" name="opner_fac_name" value="<%=WI.fillTextValue("opner_fac_name")%>">
  <input type="hidden" name="opner_fac_index" value="<%=WI.fillTextValue("opner_fac_index")%>">

  <input type="hidden" name="multiple_assign" value="<%=WI.fillTextValue("multiple_assign")%>">
  <input type="hidden" name="sub_off_yrf" value="<%=WI.fillTextValue("sub_off_yrf")%>">
  <input type="hidden" name="sub_off_yrt" value="<%=WI.fillTextValue("sub_off_yrt")%>">
  <input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>">
  <!--
  <input type="hidden" name="sub_index" value="<%=WI.fillTextValue("sub_index")%>">
  -->
  <input type="hidden" name="forward_page">

  </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
