<%@ page language="java" import="utility.*,enrollment.GradeSystem,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strCollegeName = null;
	String strCollegeIndex = null; String strCollegeIndexCon = null;
	String strDegreeType = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";	//strSchCode = "DLSHSI";


	String strOrgSchCode = strSchCode;
	if(strSchCode.startsWith("MARINER"))
		strSchCode = "EAC";
	
	boolean bolIsSWU = strSchCode.startsWith("SWU");
	

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
  /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:7;
	top:0;
    width:385px;
	height:200;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg(strIndex)
{
	//fill up the major name and course name,
	if(document.enrlist.print_all_course && document.enrlist.print_all_course.checked) {
		if(document.enrlist.course_index)
			document.enrlist.course_index.selectedIndex = 0;
		if(document.enrlist.major_index)
			document.enrlist.major_index.selectedIndex = 0;
	}
	else if(document.enrlist.major_index) {
		if(document.enrlist.major_index.selectedIndex >=0)
			document.enrlist.major_name.value = document.enrlist.major_index[document.enrlist.major_index.selectedIndex].text;
		document.enrlist.course_name.value = document.enrlist.course_index[document.enrlist.course_index.selectedIndex].text;
	}

/* 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	var sT = "#";
	sT = "./elist_print.jsp?";

	//print here
	var win=window.open(sT,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
*/
document.enrlist.target="_blank";
if (document.enrlist.names_only.value == 1){
	document.enrlist.action = "./elist_print_names.jsp";
}else{
	if (document.enrlist.format_2.value==1){
		if (strIndex != 1){
			document.enrlist.action ="./elist_print_2.jsp";
		}else{
			document.enrlist.action ="./elist_print_med.jsp";
		}
	}else{
<% if (strSchCode.startsWith("VMA")) {%> 
		document.enrlist.action ="./elist_print_new_VMA.jsp";
<%}else if (strSchCode.startsWith("UB")) {%> 
		document.enrlist.action ="./elist_print_UB.jsp";
<%}else if (strSchCode.startsWith("WNU") || strSchCode.startsWith("VMA")) {%> 
		document.enrlist.action ="./elist_print_new_WNU.jsp";
<%}else if (strSchCode.startsWith("EAC") || strSchCode.startsWith("MARINER")) {%> 
		if(document.enrlist.form_19.checked)
			document.enrlist.action ="./elist_print_new_EAC_form19.jsp";
		else{
			<%if(strOrgSchCode.startsWith("EAC")){%>
				document.enrlist.action ="./elist_print_new_EAC.jsp";
			<%}else{%>
				document.enrlist.action ="./elist_print_new_MARINER.jsp";
			<%}%>
		}
		/*else if(strSchCode.startsWith("EAC"))
			document.enrlist.action ="./elist_print_new_EAC.jsp";
		else
			document.enrlist.action ="./elist_print_new_MARINER.jsp";*/
			
<%}else if (strSchCode.startsWith("CIT") && WI.fillTextValue("form_19").length() > 0) {%> 
		document.enrlist.action ="./elist_print_new_CIT_form19.jsp";
<%}else if (strSchCode.startsWith("CIT")) {%> 
		document.enrlist.action ="./elist_print_new_CIT.jsp";
<%}else if (strSchCode.startsWith("NEU")) {%> 
		document.enrlist.action ="./elist_print_NEU.jsp";
<%}else if (strSchCode.startsWith("UI")) {%> 
		document.enrlist.action ="./elist_print_new.jsp";
<%}else{%> 
		document.enrlist.action ="./elist_print.jsp";
<%}%> 
	}
}
document.enrlist.submit();
}
function ReloadPage()
{
	document.enrlist.target="_self";
	document.enrlist.action ="./elist.jsp";
	document.enrlist.submit();
}
function ChangeFontSize() {
	if(!document.enrlist.font_size)
		return;
	var vFontSize = document.enrlist.font_size[document.enrlist.font_size.selectedIndex].value;
	eval('document.enrlist.font_size_test.style.fontSize = '+vFontSize);
}
function SearchStudent() {
	var pgLoc = "../../registrar/curriculum/curriculum_subject.jsp?search_=1";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function HideLayer(strDiv) {
	if(strDiv == '1')
		document.all.processing.style.visibility='hidden';	
	else if(strDiv == '2')
		document.all.showPayment.style.visibility='hidden';	
	
}
</script>

<%
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-Enrollment list","elist.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {	
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS-Enrollment List",request.getRemoteAddr(),
														null);
}
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
boolean bolIsETO = false;
if(bolIsSWU){
	strTemp = (String)request.getSession(false).getAttribute("userIndex");
	if(strTemp != null && strTemp.length() > 0){
		strTemp  ="select ETO_INCHARGE_INDEX from CIT_ETO_INCHARGE where ETO_INCHARGE_INDEX = "+strTemp;
		if(dbOP.getResultOfAQuery(strTemp, 0) != null)
			bolIsETO = true;
	}	
}


if(WI.fillTextValue("is_firsttime").length() ==0 && WI.fillTextValue("c_index").length() ==0 && !bolIsETO)
{

	Vector vCollegeInfo = comUtil.getAuthorizedCollegeInfo(dbOP,(String)request.getSession(false).getAttribute("userId"));
	if(vCollegeInfo == null	)
	{
		strErrMsg = comUtil.getErrMsg();
		%>
		<p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3"><strong><%=strErrMsg%></strong></font></p>
		<%
		dbOP.cleanUP();
		return;
	}
	strCollegeName = ((String)vCollegeInfo.elementAt(0)).toUpperCase();
	strCollegeIndex = (String)vCollegeInfo.elementAt(1);
	if(vCollegeInfo.size() > 4) {
		strCollegeIndexCon = strCollegeIndex;
		for(int i = 4; i < vCollegeInfo.size(); i += 4) 
			strCollegeIndexCon = strCollegeIndexCon+","+(String)vCollegeInfo.elementAt(i + 1);
		strCollegeIndexCon = " in ("+strCollegeIndexCon+")";
	}
	else
		strCollegeIndexCon = " = "+strCollegeIndex;
}
else
{
	strCollegeName = request.getParameter("college_name");
	//get college name from course index. 
	if(WI.fillTextValue("course_index").length() > 0) {
		strTemp = "select c_name from college join course_offered on (course_offered.c_index = college.c_index) where course_offered.course_index = "+
						WI.fillTextValue("course_index");
		strCollegeName = dbOP.getResultOfAQuery(strTemp, 0);
	}				
	if(strCollegeName == null)
		strCollegeName = "";	
	
	strCollegeIndex = request.getParameter("c_index");
	if(WI.fillTextValue("c_index_con").length() > 0) 
		strCollegeIndexCon = WI.fillTextValue("c_index_con");
	else	
		strCollegeIndexCon = " = "+strCollegeIndex;
}

if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("0") != 0)
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");

if(strErrMsg == null) strErrMsg = "";


//strSchCode = "AUF";
%>
<body bgcolor="#D2AE72" onLoad="ChangeFontSize();">
<form action="" method="post" name="enrlist">
<%if(strSchCode.startsWith("SPC") || (strSchCode.startsWith("NEU") && WI.fillTextValue("c_index").length() ==0)){%>
	<div id="processing" class="processing"><!-- style="visibility:hidden">-->
	<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
		  <tr>
			<td valign="top" align="right"><a href="javascript:HideLayer(1)">Close Window X</a></td>
		  </tr>
		  <tr>
		  <%
		  strTemp = "List of Courses to Print";
		  if(strSchCode.startsWith("NEU"))
		  	strTemp = "List of College to Exclude";
		  %>
			  <td valign="top" align="center"><u><b><%=strTemp%></b></u></td>
		  </tr>
		  <tr>
			  <td valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0">	
					<%
					int iCount = 0;
					String strSQLQuery = "select course_index, course_code, course_name from course_offered where is_valid = 1 and is_offered = 1 order by course_code";
					if(strSchCode.startsWith("NEU"))
						strSQLQuery = "select c_index, c_code, c_name from college where is_del=0 order by c_name asc ";
					java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
					Vector vCourseInfo = new Vector();
					while(rs.next()) {
						vCourseInfo.addElement(rs.getString(1));
						vCourseInfo.addElement(rs.getString(2));
						vCourseInfo.addElement(rs.getString(3));
					}
					rs.close();	
					%>
						<tr>
							<td>
								<table width="100%" cellpadding="0" cellspacing="0" border="0">
									<%
									for(int i =0; i < vCourseInfo.size(); i += 6){%>
										<tr>
											<td width="5%"><input type="checkbox" name="_<%=iCount++%>" value="<%=vCourseInfo.elementAt(i)%>"></td>
											<td style="font-size:9px;"><%=vCourseInfo.elementAt(i + 1)%></td>
										</tr>
									<%}%>
								</table>
							</td>
							<td>&nbsp;</td>
							<td>
								<table width="100%" cellpadding="0" cellspacing="0" border="0">
									<%
									for(int i =3; i < vCourseInfo.size(); i += 6){%>
										<tr>
											<td width="5%"><input type="checkbox" name="_<%=iCount++%>" value="<%=vCourseInfo.elementAt(i)%>"></td>
											<td style="font-size:9px;"><%=vCourseInfo.elementAt(i + 1)%></td>
										</tr>
									<%}%>
								</table>
							<input type="hidden" name="_count" value="<%=iCount%>">
							</td>
						
				</table>
			  </td>
		  </tr>
	</table>
	</div>
<%}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          <%if(WI.fillTextValue("form_19").length() > 0) {%>
		  FORM - 19 <%}else{%>ENROLLMENT LIST <%}%>PAGE ::::<br>
          <font size="1"><%=strCollegeName.toUpperCase()%></font><br>
          </strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="3%" height="25">&nbsp;</td>
      <td height="25" colspan="3"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>School Year</td>
      <td>Term</td>
      <td>
<%
if(strSchCode.startsWith("AUF") || strSchCode.startsWith("UDMC") || strSchCode.startsWith("UL") || 
	strSchCode.startsWith("CDD") || strSchCode.startsWith("CIT") || strSchCode.startsWith("EAC") || strSchCode.startsWith("PWC")) {
	strTemp = WI.fillTextValue("form_19");
	if(strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
%>	  <input type="checkbox" name="form_19" value="1" <%=strTemp%>>
	  <font color="#0000FF"><strong><%if(!strSchCode.startsWith("AUF") && !strSchCode.startsWith("CIT") && !strSchCode.startsWith("EAC")){%> Show Grade<%}else{%>Print Form 19<%}%></strong></font>
<%} if(strSchCode.startsWith("CGH")){%>
		<font size="1">Section 
		<select name="section_name" style="font-size:11px">
		<option value=""></option>
<%=dbOP.loadCombo("distinct section","section"," from e_sub_section where offering_sy_from="+
			WI.getStrValue(WI.fillTextValue("sy_from"),"0")+" and offering_sem="+
			WI.getStrValue(WI.fillTextValue("semester"),"0")+" and is_valid = 1 order by e_sub_section.section",
			request.getParameter("section_name"), false)%>
		</select>
		&nbsp;<a href="javascript:SearchStudent();">Sub.Code</a></font>
        <input name="sub_code_" type="text" size="12" value="<%=WI.fillTextValue("sub_code_")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px"> 
<%}%>	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td width="26%">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("enrlist","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">      </td>
      <td width="18%"> 
       <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
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
      </select></td>
      <td width="53%">&nbsp;
<%if(strSchCode.startsWith("UDMC")) {%>
	  Gender : 
<!--
        <select name="gender">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("gender").compareTo("F") == 0){%>
          <option value="F" selected>Female</option>
<%}else{%>
          <option value="F">Female</option>
<%}if(WI.fillTextValue("gender").compareTo("M") ==0){%>
          <option value="M" selected>Male</option>
<%}else{%>
          <option value="M">Male</option>
<%}%>
        </select>
-->
        <select name="gender_x">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("gender").compareTo("F") == 0){%>
          <option value="F" selected>Female</option>
<%}else{%>
          <option value="F">Female</option>
<%}if(WI.fillTextValue("gender").compareTo("M") ==0){%>
          <option value="M" selected>Male</option>
<%}else{%>
          <option value="M">Male</option>
<%}%>
        </select>


<%}%>	  
<%if(strSchCode.startsWith("CGH")){%>
		<font style="font-size:9px;">
			<input type="radio" name="stud_stat" value="0"> Show Only New &nbsp;&nbsp;
			<input type="radio" name="stud_stat" value="1"> Show Only Old &nbsp;&nbsp;
			<input type="radio" name="stud_stat" value="2"> Show All
		</font>
<%}%>
		</td>
    </tr>
<%if(strSchCode.startsWith("DBTC")){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Date of Enrollment </td>
      <td colspan="2">
	  <input name="enrl_date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("enrl_date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('enrlist.enrl_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		to
		<input name="enrl_date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("enrl_date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('enrlist.enrl_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  </td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td  colspan="4" height="25"><hr size="1"></td>
    </tr>
<%if(strSchCode.startsWith("PWC") || bolIsETO || strSchCode.startsWith("NEU")){%>
    <tr >
      <td height="10">&nbsp;</td>
      <td>College</td>
      <td colspan="2">
	  <select name="c_index" onChange="ReloadPage();" style="font-size:11px; width:500px;">
          <option value="">Select Any</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where is_del=0 order by c_name asc", request.getParameter("c_index"), false)%> 
      </select>
	  </td>
    </tr>
<%}else{%>
    <tr >
      <td height="10">&nbsp;</td>
      <td>Course</td>
      <td colspan="2">&nbsp;
<%
String strCourseType = null;
if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("semester").equals("1")) {
	strCourseType = dbOP.mapOneToOther("course_offered", "course_index", WI.fillTextValue("course_index"),"degree_type" ,null);
	if(strCourseType != null && strCourseType.equals("2")){//college of medicine.
		strTemp = WI.fillTextValue("show_2nd_sem");
		if(strTemp.length() > 0) 
			strTemp = " checked";
		else	
			strTemp = "";%>
		<input type="checkbox" name="show_2nd_sem" value="1" <%=strTemp%>>
		<font size="1" color="#0000FF"><b>&nbsp; Show 2nd Sem in Printout(for Yearly enrollment)</b></font>
			
        <%	}
}%>	  
<%if(strSchCode.startsWith("EAC")){%>
	<input type="checkbox" name="print_all_course" value="checked" <%=WI.fillTextValue("print_all_course")%>> Print all Course
<%}%>
<%if(strSchCode.startsWith("UB")){%>
	<input type="checkbox" name="print_all" value="checked" <%=WI.fillTextValue("print_all")%>> Print ALL Colleges and ALL Courses
<%}%>

<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr > 
      <td height="20">&nbsp;</td>
      <td colspan="2">
	  <select name="course_index" onChange="ReloadPage();" style="font-size:11px; width:500px;">
          <option value="">Select Any</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_offered = 1 and is_valid=1 and c_index "+
		  strCollegeIndexCon+" order by course_name asc", request.getParameter("course_index"), false)%> 
      </select></td>
      <td> <%
if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0 && 
   WI.fillTextValue("names_only").compareTo("1")!=0){%>
        Year : 
        <select name="year_level">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>1st</option>
<%}else{%>
          <option value="1">1st</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
<%}else{%>
          <option value="4">4th</option>
<%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
<%}else{%>
          <option value="5">5th</option>
<%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
<%}else{%>
          <option value="6">6th</option>
<%}%>
        </select> <%}%> </td>
    </tr>
<%if(!strSchCode.startsWith("UB")){%>
    <tr > 
      <td width="4%" height="25">&nbsp;</td>
      <td width="5%">Major </td>
      <td width="60%"><select name="major_index">
          <option></option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.compareTo("0") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
      <td> <%if(strDegreeType != null && strDegreeType.compareTo("3") ==0 
	 && WI.fillTextValue("names_only").compareTo("1") != 0){%>
        Prep or Proper: 
        <select name="prep_prop_stat">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Preparatory</option>
<%}else{%>
          <option value="1">Preparatory</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
<%}else{%>
          <option value="2">Proper</option>
<%}%>
        </select> <%}%> </td>
    </tr>
<%}//do not show for UB -- no major.


}//do not show course if not pwc.. %>
    <tr > 
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td width="31%" height="26">&nbsp;</td>
    </tr>
<%if(strSchCode.startsWith("UL") || strSchCode.startsWith("PHILCST") || strSchCode.startsWith("CDD") || strSchCode.startsWith("DLSHSI")) {
if(!strSchCode.startsWith("CDD") && !strSchCode.startsWith("DLSHSI")){
%>
    <tr >
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26">Print Foreign Student Condition: 
	  <select name="print_foreign_stud">
	  	<option value=""></option>
<%
strTemp = WI.fillTextValue("print_foreign_stud");
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="0"<%=strErrMsg%>>Print Local student Only</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="1"<%=strErrMsg%>>Print Foreign student Only</option>
	  </select>	  </td>
      <td height="26">&nbsp;</td>
    </tr>
<%}//do not show for CDD.%>
    <tr >
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
	  <%
	  strTemp = "Printed BY";
	  if(strSchCode.startsWith("DLSHSI"))
	  	strTemp = "Prepared by";
	  %>
      <td height="26" colspan="2"><%=strTemp%>:
	  <%
	  strTemp = WI.fillTextValue("printed_by");
	  if(strSchCode.startsWith("DLSHSI")){	  	
	  	strTemp = WI.getStrValue(strTemp, (String)request.getSession(false).getAttribute("first_name"));
	  }
	  %> 
        <input name="printed_by" type="text" size="32" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      Designation: 
	  
	  <%
	  strTemp = WI.fillTextValue("printed_by_designation");
	  if(strSchCode.startsWith("DLSHSI")){	  	
	  	strTemp = WI.getStrValue(strTemp, "Coordinator, Enrollment Services");
	  }
	  %>
      <input name="printed_by_designation" type="text" size="32" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
<%
if(strSchCode.startsWith("CDD") || strSchCode.startsWith("DLSHSI")){
%>
	<tr >
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
	  <%
	  strTemp = "Checked BY";
	  if(strSchCode.startsWith("DLSHSI"))
	  	strTemp = "Noted by";
	  %>
      <td height="26" colspan="2"><%=strTemp%>: 
	  <%
	  strTemp = WI.fillTextValue("printed_by");
	  if(strSchCode.startsWith("DLSHSI")){	  	
	  	strTemp = WI.getStrValue(strTemp, WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)));
	  }
	  %>
        <input name="checked_by" type="text" size="32" maxlength="64" value="<%=WI.fillTextValue("checked_by")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      Designation: 
	  <%
	  strTemp = WI.fillTextValue("checked_by_designation");
	  if(strSchCode.startsWith("DLSHSI")){	  	
	  	strTemp = WI.getStrValue(strTemp, "Registrar");
	  }
	  %>
      <input name="checked_by_designation" type="text" size="32" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
<%}
}%>
    <tr > 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="2"> Number of lines to be printed per page : 
        <select name="stud_per_pg">
<%
strTemp = request.getParameter("stud_per_pg");
if(strTemp == null) {
	strTemp = "18";
	if(strSchCode.startsWith("CIT"))
		strTemp = "40";
	if(strSchCode.startsWith("VMA"))
		strTemp = "10";
}
int iDef = Integer.parseInt(strTemp);

for(int i = 6; i < 60; ++i) {
	if( i == iDef)
		strTemp = " selected";
	else
		strTemp = "";
%>
      <option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
        </select> </td>
    </tr>
    <tr > 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="2">Font size of Printout: 
        <select name="font_size" onChange="ChangeFontSize();" onkeyUp="ChangeFontSize();">
          <option value="6">6</option>
          <%
strTemp = request.getParameter("font_size");
if(strTemp == null) {
	strTemp = "11";
	if(strSchCode.startsWith("UL"))
		strTemp = "14";
}
if(strTemp.compareTo("7") == 0) {%>
          <option value="7" selected>7 px</option>
          <%}else{%>
          <option value="7">7 px</option>
          <%}if(strTemp.compareTo("8") == 0) {%>
          <option value="8" selected>8 px</option>
          <%}else{%>
          <option value="8">8 px</option>
          <%}if(strTemp.compareTo("9") == 0) {%>
          <option value="9" selected>9 px</option>
          <%}else{%>
          <option value="9">9 px</option>
          <%}if(strTemp.compareTo("10") == 0) {%>
          <option value="10" selected>10 px</option>
          <%}else{%>
          <option value="10">10 px</option>
          <%}if(strTemp.compareTo("11") == 0) {%>
          <option value="11" selected>11 px</option>
          <%}else{%>
          <option value="11">11 px</option>
          <%}if(strTemp.compareTo("12") == 0) {%>
          <option value="12" selected>12 px</option>
          <%}else{%>
          <option value="12">12 px</option>
          <%}if(strTemp.compareTo("14") == 0) {%>
          <option value="14" selected>14 px</option>
          <%}else{%>
          <option value="14">14 px</option>
          <%}if(strTemp.compareTo("15") == 0) {%>
          <option value="15" selected>15 px</option>
          <%}else{%>
          <option value="15">15 px</option>
          <%}if(strTemp.compareTo("16") == 0) {%>
          <option value="16" selected>16 px</option>
          <%}else{%>
          <option value="16">16 px</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <input type="text" name="font_size_test" 
		style="border:0px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;" value="::: Actual size of Font :::" size="45">      </td>
    </tr>
    <tr > 
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18" valign="top"><font color="#0000FF" size="1">(::: Actual 
        size of Font ::: shows the font view in printout)</font></td>
      <td rowspan="3" style="font-size:9px; font-weight:bold">Exclude Student in List : <br>
      <textarea name="exclude_stud" class="textbox" rows="4"><%=WI.fillTextValue("exclude_stud")%></textarea></td>
    </tr>
    <tr >
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24">Show Table border : 
	  <select name="show_border">
	  <option value="1">Yes</option>
<%
strTemp = WI.fillTextValue("show_border");
if(strTemp.compareTo("0") == 0) {%>
	<option value="0" selected>No</option>
<%}else{%>
	<option value="0">No</option>
<%}%> 
	  </select></td>
    </tr>
    <tr > 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <%
	if(strDegreeType != null && strDegreeType.compareTo("2") ==0 && WI.fillTextValue("names_only").compareTo("1")!=0)
			strTemp= "1";
		else
			strTemp= "0";
%>
      <td height="24"><div align="center" style="font-size:9px">
	  <a href="javascript:PrintPg(<%=strTemp%>);"><img src="../../../images/print.gif" border="0"></a> 
          click to print list
<%if(strSchCode.startsWith("UB") || strSchCode.startsWith("DLSHSI")){%>		  
	<%
	strTemp = WI.fillTextValue("print_to_excel");
	if(strTemp.equals("1"))
		strErrMsg = "checked";
	else
		strErrMsg  = "";
	%><input type="checkbox" name="print_to_excel" value="1" <%=strErrMsg%>>Import to excel
<%}%>
		  </div></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="is_firsttime" value="0">
<input type="hidden" name="college_name" value="<%=strCollegeName%>">
<input type="hidden" name="c_index" value="<%=strCollegeIndex%>">
<input type="hidden" name="course_name">
<input type="hidden" name="major_name">
<input type="hidden" name="names_only" value="<%=WI.fillTextValue("names_only")%>">
<input type="hidden" name="format_2" value="<%=WI.fillTextValue("format_2")%>">
<input type="hidden" name="installDir" value="installDir">
<input type="hidden" name="c_index_con" value="<%=WI.getStrValue(strCollegeIndexCon)%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
