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
function PrintPg(strSYFrom, strSYTo)
{
	var strCIndex  = document.faculty_page.c_index[document.faculty_page.c_index.selectedIndex].value;
	var strDIndex  = "";
	var strGender  = document.faculty_page.gender[document.faculty_page.gender.selectedIndex].value;
	var strEmpStat = document.faculty_page.emp_status[document.faculty_page.emp_status.selectedIndex].value;
	//if(strGender == "") strGender="%20";
	//if(strEmpStat == "") strEmpStat="%20";


	if(document.faculty_page.d_index.selectedIndex>=0)
		strDIndex=document.faculty_page.d_index[document.faculty_page.d_index.selectedIndex].value;

	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	var sT = "#";
	if(vProceed)
		sT = "./faculty_list_print_load.jsp?c_index="+strCIndex+"&d_index="+strDIndex+"&emp_status="+strEmpStat+"&gender="+strGender+
			"&sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+document.faculty_page.semester[document.faculty_page.semester.selectedIndex].value+
			"&college_name="+escape(document.faculty_page.college_name.value);
	//print here
	if(vProceed) {
		if(document.faculty_page.show_with_load.checked)
			sT += "&show_with_load=1";
		var win=window.open(sT,"PrintWindow",'scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

}
function ChangeCollgeName()
{
	document.faculty_page.college_name.value = document.faculty_page.c_index[document.faculty_page.c_index.selectedIndex].text;
	document.faculty_page.submit();
}
function Proceed()
{
	document.faculty_page.proceed.value= "1";
}
function ReloadPage()
{
	document.faculty_page.submit();
}
function ReloadIfProceedIsON()
{
	if(document.faculty_page.proceed.value =="1")
		document.faculty_page.submit();
}
function ViewDetailLoad(strUserIndex)
{
	strSYFrom = document.faculty_page.sy_from.value;
	strSYTo   = document.faculty_page.sy_to.value;
	strSemester  = document.faculty_page.semester[document.faculty_page.semester.selectedIndex].value;

	location = "./enrollment_ci_faculty_load_sched.jsp?emp_id="+strUserIndex+"&sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strSemester+"&show_list=1&hide_header=1";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector " %>
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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-TEACHING LOAD"),"0"));
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
								"Admin/staff-Enrollment-Faculty-View/Print Plotted Load ",
								"faculty_list_view_load.jsp");
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
													"faculty_list_view_load.jsp");
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

%>

<form name="faculty_page" action="./faculty_list_view_load.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center"><font color="#FFFFFF" ><strong>::::
        FACULTY PAGE - VIEW/PRINT LOAD ::::</strong></font></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="14%" height="25">&nbsp;</td>
      <td width="23%">College </td>
      <td width="63%" valign="bottom"><select name="c_index" onChange="ChangeCollgeName();">
          <option value="0">Select a college</option>
          <% strTemp = WI.getStrValue(WI.fillTextValue("c_index"),"0");%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc",strTemp , false)%>
      </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>

      <td>Department/Office </td>
      <td><select name="d_index">
          <option value="">ALL</option> 
		  <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 "+
			WI.getStrValue(WI.fillTextValue("c_index")," and c_index = ","","") + 
		    " order by d_name asc", WI.fillTextValue("d_index"), false)%>
        </select> </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Gender </td>
      <td height="20"> <select name="gender" onChange="ReloadIfProceedIsON();">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("gender");
if(strTemp.equals("0")){%>
          <option value="0" selected>Male</option>
          <%}else{%>
          <option value="0">Male</option>
          <%}if(strTemp.equals("1")){%>
          <option value="1" selected>Female</option>
          <%}else{%>
          <option value="1">Female</option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Employment Tenure </td>
      <td height="20"> <select name="emp_status" onChange="ReloadIfProceedIsON();">
          <option value="">ALL</option>
           <%=dbOP.loadCombo("STATUS_INDEX","STATUS"," from USER_STATUS where is_for_student=0 order by STATUS asc", WI.fillTextValue("emp_status"), false)%>
        </select> </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">School Year/Term</td>
      <td height="25">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("faculty_page","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly>
        -
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

		  if(strTemp.equals("2"))
		  {%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.equals("3"))
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.equals("0"))
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20" style="font-size:9px; font-weight:bold; color:blue">
<%
if(WI.fillTextValue("show_with_load").length() > 0 || request.getParameter("proceed") == null)
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="show_with_load" value="1"<%=strTemp%>> 
	  Show Faculty with load 
	  </td>
      <td height="25"><input type="image" src="../../../images/form_proceed.gif" onClick="Proceed();"></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
  </table>
<%
String strSYFrom = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");

if(WI.fillTextValue("proceed").equals("1") && strSYFrom.length() > 0)
{
	strErrMsg = null;

	FacultyManagement FM = new FacultyManagement();
	String strExtraCon = "";
	if(request.getParameter("gender")!= null && request.getParameter("gender").trim().length() > 0)
	 	strExtraCon = " and INFO_FACULTY_BASIC.GENDER="+request.getParameter("gender");
	if(request.getParameter("emp_status") != null && request.getParameter("emp_status").trim().length() > 0)
		strExtraCon += " and user_status.status_index="+request.getParameter("emp_status");
	if(request.getParameter("d_index") != null && request.getParameter("d_index").trim().length() > 0)
		strExtraCon += " and INFO_FACULTY_BASIC.d_index="+request.getParameter("d_index");
//System.out.println(request.getParameter("sy_from"));
//System.out.println(request.getParameter("sy_to"));
	if(WI.fillTextValue("show_with_load").length() > 0) 
		strExtraCon += " and exists (select * from faculty_load where is_valid = 1 and exists (select * from e_sub_section where "+
		" sub_sec_index = faculty_load.sub_sec_index and offering_sy_from = "+strSYFrom+" and offering_sem="+strSemester+") and "+
		"INFO_FACULTY_BASIC.user_index = faculty_load.user_index) ";

Vector vRetResult = FM.viewFacPerCollegeWithLoadStat(dbOP, request.getParameter("c_index"),null,strSYFrom,
														request.getParameter("sy_to"), strSemester, strExtraCon,false,0f,"0","");
if(vRetResult == null || vRetResult.size() == 0)
	strErrMsg = FM.getErrMsg();
if(strErrMsg != null){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
	<td width="2%" height="25">&nbsp;</td>
      <td><%=strErrMsg%></td>
    </tr>
  </table>
<%}//if there is an errMsg
else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="8" align="center" class="thinborder">LIST OF FACULTIES UNDER 
      <strong><%=request.getParameter("college_name")%></strong></td>
    </tr>
    <tr bgcolor="#FFFFCC"> 
      <td width="16%" height="25" align="center" class="thinborder"><strong><font size="1">COLLEGE 
        :: DEPT</font></strong></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE ID</font></strong></td>
      <td width="33%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">GENDER</font></strong></td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">EMP. STATUS</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">MAX LOAD</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">TOTAL UNITS LOAD</font></strong></td>
      <td width="6%" height="25" align="center" class="thinborder"><strong><font size="1">VIEW 
        DETAIL</font></strong></td>
    </tr>
    <%
int i = 0;int j=1;
 for(; i< vRetResult.size(); ++i,++j){%>
    <tr> 
      <td height="25" class="thinborder"><%=(j)%>.&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5))%></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td height="25" align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder"><div align="center">
          <%if( ((String)vRetResult.elementAt(i+8)).compareTo("0") == 0){%>
          <font color="#0000FF">Not Set</font>
          <%}else{%>
          <%=WI.getStrValue((String)vRetResult.elementAt(i+8))%>
          <%}%>
        </div></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>
      <td height="25" align="center" class="thinborder"> <a href='javascript:ViewDetailLoad("<%=(String)vRetResult.elementAt(i+1)%>");'><img src="../../../images/view.gif" border="0"></a></td>
    </tr>
    <% i = i+9;
}%>
    <tr> 
      <td height="25"  colspan="3" class="thinborder">TOTAL NUMBER OF FACULTIES FOR 
        THIS COLLEGE : <strong><%=i/10%></strong></td>
      <td height="25"  colspan="5" class="thinborderBOTTOM"> <a href='javascript:PrintPg("<%=request.getParameter("sy_from")%>","<%=request.getParameter("sy_to")%>");'><img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print this list</font></td>
    </tr>
  </table>
<%
	} // if there is no error in getting faculty list.
  }//if proceed is clicked.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" >&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="proceed" value="<%=WI.fillTextValue("proceed")%>">
<input type="hidden" name="college_name" value="<%=WI.fillTextValue("college_name")%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
