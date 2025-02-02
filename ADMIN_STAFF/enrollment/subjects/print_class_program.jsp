<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Organization</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//strPrintStat = 0 = view only.
function PrintPage(strSection, strPrintStat)
{
	var strDegreeType = document.ssection.degree_type.value;
	var strPrepPropStat ="0";
	var strYrSemCon     = "";//alert(strDegreeType);
	if(strDegreeType == "3")
		strPrepPropStat = document.ssectoin.prep_prop_stat[document.ssectoin.prep_prop_stat.selectedIndex].value;
	if(strDegreeType != 1 && strDegreeType != 4)
		strYrSemCon = "&year="+document.ssection.year[document.ssection.year.selectedIndex].value+
				"&semester="+document.ssection.semester[document.ssection.semester.selectedIndex].value;

	var vProceed = true;
	if(strPrintStat == 1)
		vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed) {
		var iMaxDisp = document.ssection.max_disp.value;
		var strSecList = ""; var strTemp;
		for(var i = 0; i < iMaxDisp; ++i) {
			eval('strTemp=document.ssection.multiple_'+i);
			if(!strTemp)
				continue;
			if(!strTemp.checked)
				continue;
				
			strSecList = strSecList + escape(strTemp.value)+",";
		}
		if(strSecList.length > 0) 
			strSecList = "&addl_section="+strSecList + escape(strSection);
		
		var pgLoc = "./subj_sectioning_print_MWF_per_section.jsp?course_index="+document.ssection.course_index.value+"&major_index="+
				document.ssection.major_index.value+"&school_year_fr="+document.ssection.school_year_fr.value+"&school_year_to="+
				document.ssection.school_year_to.value+strYrSemCon+"&sy_from="+
				document.ssection.sy_from[document.ssection.sy_from.selectedIndex].value+"&sy_to="+document.ssection.sy_to.value+
				"&offering_sem="+document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value+
				"&prep_prop_stat="+strPrepPropStat+"&print_section="+escape(strSection)+
				"&sched_per_section="+document.ssection.sched_per_section.value+
				"&print_stat="+strPrintStat+strSecList;

		var win=window.open(pgLoc,"PrintWindow",'width=850,height=600,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function ReloadCourseIndex()
{
	//course index is changed -- so reset all dynamic fields.
	if(document.ssection.sy_from.selectedIndex > -1)
		document.ssection.sy_from[document.ssection.sy_from.selectedIndex].value = "";
	if(document.ssection.major_index.selectedIndex > -1)
		document.ssection.major_index[document.ssection.major_index.selectedIndex].value = "";

	ReloadPage();
}
function ReloadPage()
{
	document.ssection.form_proceed.value="";
	document.ssection.submit();
}
function FormProceed()
{
	document.ssection.form_proceed.value="1";
}
function GoToClassTimeSched() {
	location = "./cp/class_time_sched_cdd.jsp?print_type=1";
}
function GoToClassProgramPlotting() {
	location = "./cp/print_cp_plotted_main.jsp";
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolFatalErr = false;
	int i,j;

	String strDegreeType = null;
	String strSYTo = null;
	Vector vTemp = new Vector();
	String[] astrSchYrInfo = null;
	Vector vSecList = new Vector();
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-edit subject section","edit_section.jsp");
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
int iAccessLevel = 2;
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"edit_section.jsp");
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

SubjectSection SS = new SubjectSection();


if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("selany") != 0)
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");

astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)
{
	strErrMsg = "School year information not found.";
	bolFatalErr = true;
}

if(WI.fillTextValue("form_proceed").compareTo("1") ==0)
{
	vSecList = SS.viewSecList(dbOP,request);
	if(vSecList == null)
		strErrMsg = SS.getErrMsg();
}
if(strErrMsg == null) 
	strErrMsg = "";
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");


%>
<form name="ssection" action="./print_class_program.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="26" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          PRINT CLASS PROGRAM ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <font size="3"><b><%=strErrMsg%></b></font>      </td>
    </tr>
    <% if(bolFatalErr){
	dbOP.cleanUP();//System.out.println(" I am here");
	return;
}%>
    <tr> 
      <td height="4">&nbsp;</td>
      <td width="48%" height="25" >Class program for SY-Term : 
        <%
	  strTemp = WI.fillTextValue("school_year_fr");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[0];
	  %>
        <input name="school_year_fr" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ssection","school_year_fr","school_year_to")'> 
        <%
	  strTemp = WI.fillTextValue("school_year_to");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[1];
	  %>
        - 
      <input name="school_year_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
      -
<%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = astrSchYrInfo[2];
%>
	  <select name="offering_sem">
	  		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
      </select></td>
      <td> 
		
		<a href="javascript:GoToClassTimeSched();">GO To Class Time Schedule</a>	  
		&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:GoToClassProgramPlotting();">GO To Class Progm. Plotting</a>	  
		
		</td>
    </tr>
    <tr> 
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24" colspan="2" >Course Program(Optional to select) : 
        <select name="cc_index" onChange="ReloadPage();">
          <option value="0">Select a Program</option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc", request.getParameter("cc_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td width="2%" height="4">&nbsp;</td>
      <td height="25" valign="bottom">Course</td>
      <td width="50%" valign="bottom">Curriculum Year </td>
    </tr>
    <tr> 
      <td width="2%" height="3">&nbsp;</td>
      <td><select name="course_index" onChange="ReloadCourseIndex();" style="width:500px;">
          <option value="0">Select Any</option>
          <%
//if course program is selected, then filter course offered displayed else, show all courses offered.
if(WI.fillTextValue("cc_index").length()>0 && WI.fillTextValue("cc_index").compareTo("0") != 0)
{
	strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and cc_index="+request.getParameter("cc_index")+
		  	" order by course_name asc" ;
}
else
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, WI.fillTextValue("course_index"), false)%> 
        </select></td>
      <td><select name="sy_from" onChange="ReloadPage();">
          <%
//get here school year
vTemp = SS.getSchYear(dbOP, request);
strTemp = request.getParameter("sy_from");//System.out.println(strTemp);
if(strTemp == null) strTemp = "";

for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).compareTo(strTemp) == 0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i)%></option>
          <%	j = i;
	}
	else{
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i)%></option>
          <%	}
	i = i+2;

}
if(vTemp.size() > 0)
	strSYTo = (String)vTemp.elementAt(j+1);
else
	strSYTo = "";

%>
        </select>
        to <b><%=strSYTo%></b> <input type="hidden" name="sy_to" value="<%=strSYTo%>">      </td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td height="25" valign="bottom">Major </td>
      <td valign="bottom"> 
        <%if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        Year and Term 
        <%}%>      </td>
    </tr>
    <tr> 
      <td width="2%" height="12">&nbsp;</td>
      <td><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
strTemp = request.getParameter("course_index");
if(strTemp != null && strTemp.compareTo("selany") != 0 && strTemp.compareTo("0") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select> </td>
      <td width="50%"> 
<%if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        <select name="year" onChange="ReloadPage();">
		<option value=""></option>
<%
strTemp = request.getParameter("year");
if(strTemp == null) 
	strTemp = "";
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st</option>
<%if(strTemp.equals("2")){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.equals("4")){%>
          <option value="4" selected>4th</option>
<%}else{%>
          <option value="4">4th</option>
<%}if(strTemp.equals("5")){%>
          <option value="5" selected>5th</option>
<%}else{%>
          <option value="5">5th</option>
<%}if(strTemp.equals("6")){%>
          <option value="6" selected>6th</option>
<%}else{%>
          <option value="6">6th</option>
<%}if(strTemp.equals("7")){%>
          <option value="7" selected>7th</option>
<%}else{%>
          <option value="7">7th</option>
<%}if(strTemp.equals("8")){%>
          <option value="8" selected>8th</option>
<%}else{%>
          <option value="8">8th</option>
<%}%>
        </select> <select name="semester" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";

if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> 
        <%}//only if degree type is not care giver type.%>      </td>
    </tr>
    <%
if(strDegreeType != null && strDegreeType.compareTo("3") ==0){%>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" >Select Preparatory/Proper : 
        <select name="prep_prop_stat" onChange="ReloadPage();">
          <option value="1">Preparatory</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select> </td>
      <td>&nbsp;</td>
    </tr>
    <%}//only if strDegree type is 3
%>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" ><div align="center"></div></td>
      <td><input name="image" type="image" onClick="FormProceed();" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><div align="center"></div></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vSecList != null && vSecList.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" bgcolor="#B9B292"><div align="center">LIST OF 
          SECTION(S) FOR THIS CLASS PROGRAM</div></td>
    </tr>
    <tr> 
      <td width="5%" height="25" align="center">&nbsp;</td>
      <td width="52%"><strong>SECTION</strong></td>
      <td width="36%">&nbsp;</td>
      <td width="7%">&nbsp;	  </td>
    </tr>
    <%
int iTotalSec = 0;
for(i=0; i<vSecList.size();++i){
++iTotalSec;%>
    <tr> 
      <td height="25" align="center"><input type="checkbox" name="multiple_<%=(iTotalSec-1)%>" value="<%=(String)vSecList.elementAt(i)%>"></td>
      <td><%=(String)vSecList.elementAt(i)%></td>
      <td><a href='javascript:PrintPage("<%=(String)vSecList.elementAt(i)%>","1")'><img src="../../../images/print.gif" border="0" onClick="document.ssection.multiple_<%=(iTotalSec-1)%>.checked=false"></a> 
        <font size="1">click to print class program</font></td>
      <td>
<%if(WI.fillTextValue("sched_per_section").compareTo("1") == 0){%>
<a href='javascript:PrintPage("<%=(String)vSecList.elementAt(i)%>","0")'>
		<img src="../../../images/view.gif" border="0"></a> 
 <%}%>
	  </td>
    </tr>
    <%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>TOTAL SECTION(S) : <strong><%=iTotalSec%></strong>
	  <input type="hidden" name="max_disp" value="<%=iTotalSec%>"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}//only if vSecList.size()>0%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="69%" height="25">&nbsp;</td>
      <td width="31%"><div align="right"> </div></td>
    </tr>
  </table>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="form_proceed" value="<%=WI.fillTextValue("form_proceed")%>">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">

<input type="hidden" name="sched_per_section" value="<%=WI.fillTextValue("sched_per_section")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
