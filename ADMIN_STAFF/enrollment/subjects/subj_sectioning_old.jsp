<jsp:forward page="./subj_sectioning_old_revised.jsp" />
<!------------------------------------------ this page is not used -------------------------------->


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//this is called when section is selected from drop downlist.
function OfferSubject(strIndex)
{
	document.ssection.offerSubject.value="1";
    document.ssection.info_index.value=strIndex;
	document.ssection.viewSubjectDetail.value="1";
}
function ViewSubjectDetail()
{
	document.ssection.offerSubject.value="";
	document.ssection.viewSubjectDetail.value="1";
}
function SelectSection()
{
	document.ssection.section.value = document.ssection.select_section[document.ssection.select_section.selectedIndex].value;
}
function ReloadCourseIndex()
{
	var strDegreeType = document.ssection.degreeType.value;
	//course index is changed -- so reset all dynamic fields.
	if(document.ssection.sy_from.selectedIndex > -1)
		document.ssection.sy_from[document.ssection.sy_from.selectedIndex].value = "";
	if(document.ssection.major_index.selectedIndex > -1)
		document.ssection.major_index[document.ssection.major_index.selectedIndex].value = "";
if(strDegreeType.length > 0 && strDegreeType != "1" && strDegreeType != "4")
{
	if(document.ssection.year.selectedIndex > -1)
		document.ssection.year[document.ssection.year.selectedIndex].value = "";
	if(document.ssection.semester.selectedIndex > -1)
		document.ssection.semester[document.ssection.semester.selectedIndex].value = "";
}

	document.ssection.offerSubject.value="0";
	document.ssection.submit();
}
function ReloadPage()
{
	document.ssection.offerSubject.value="0";
	document.ssection.submit();
}

//call this to reload the page if necessary
function ReloadIfNecessary()
{
	ReloadPage();
}


/**
*	Call this function to view sction detail of a course curriculum.

function ViewSection()
{
	location = "./subj_sectioning_view.jsp?course_index="+document.ssection.course_index[document.ssection.course_index.selectedIndex].value+"&major_index="+
			document.ssection.major_index[document.ssection.major_index.selectedIndex].value+"&sy_from="+
			document.ssection.sy_from[document.ssection.sy_from.selectedIndex].value+"&sy_to="+
			document.ssection.sy_to.value+"&year="+
			document.ssection.year[document.ssection.year.selectedIndex].value+"&semester="+
			document.ssection.semester[document.ssection.semester.selectedIndex].value+"&school_year_fr="+
			document.ssection.school_year_fr.value+"&school_year_to="+
			document.ssection.school_year_to.value;
}
*/
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vTemp = null;
	int i; int j;
	String strSYTo = null; // this is used in
	String strCurIndex = null;
	String strCurIndex0 = null;

	String strDegreeType = null;
	String strCollegeName = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning old","subj_sectioning_old.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"subj_sectioning_old.jsp");
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

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
SubjectSection SS = new SubjectSection();

Vector vSubToCopy = null;
//copy section detail if offerSubject =1
if(request.getParameter("offerSubject") == null || request.getParameter("offerSubject").compareTo("1") ==0)
{
	if(!SS.copySubSecSchedule(dbOP,(String)request.getSession(false).getAttribute("userId"), request.getParameter("info_index"),
				request.getParameter("school_year_fr"),	request.getParameter("school_year_to"),request.getParameter("offering_sem")) )
	{
		strErrMsg = SS.getErrMsg();
	}
	else
		strErrMsg = "Subject section copied successfully.";


}
if(request.getParameter("viewSubjectDetail") == null || request.getParameter("viewSubjectDetail").compareTo("1") ==0)
{
	vSubToCopy = SS.getSubSecNotOffered(dbOP,request);
	if(vSubToCopy == null)
		strErrMsg = SS.getErrMsg();
}

if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("selany") != 0)
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");

vTemp = comUtil.getAuthorizedCollegeInfo(dbOP, (String)request.getSession(false).getAttribute("userId"));
if(vTemp == null)
	strCollegeName = "Does not belong to any college. Subject section can't be copied";
else	
	strCollegeName = (String)vTemp.elementAt(0);

if(strErrMsg == null) strErrMsg = "";
%>

<form name="ssection" action="./subj_sectioning_old.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          CLASS PROGRAMS PAGE -</strong></font><font color="#FFFFFF"><strong>
          USE PREVIOUS CLASS PROGRAMS PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <font size="3"><b><%=strErrMsg%></b></font> 
      </td>
    </tr>
    <tr> 
      <td height="4">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom" >NOTE: Mix section offerings 
        and Minor subjects can't be offered in this page. Please go to link &lt;New 
        Class Program/Sections&gt; to offer Mix and Minor subject offering.</td>
    </tr>
    <tr> 
      <td height="4">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom" ><font color="#0000FF">IMPORTANT: 
        The list of offering shown are the subjects offered by the college<strong> 
        : <%=strCollegeName%></strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="4">&nbsp;</td>
      <td height="25" valign="bottom" >Offerings for course</td>
      <td width="36%" valign="bottom">Curriculum Year </td>
    </tr>
    <tr> 
      <td width="2%" height="3">&nbsp;</td>
      <td><select name="course_index" onChange="ReloadCourseIndex();">
          <option value="selany">Select Any</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name", request.getParameter("course_index"), false)%> 
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
        to <b><%=strSYTo%></b> <input type="hidden" name="sy_to" value="<%=strSYTo%>"> 
      </td>
    </tr>
    <tr> 
      <td width="2%" height="6">&nbsp;</td>
      <td height="25" valign="bottom">Major </td>
      <td valign="bottom"> 
        <%if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        Year and Term 
        <%}%>
      </td>
    </tr>
    <tr> 
      <td width="2%" height="12">&nbsp;</td>
      <td><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
strTemp = request.getParameter("course_index");
if(strTemp != null && strTemp.compareTo("selany") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select> </td>
      <td width="36%"> 
        <%if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        <select name="year" onChange="ReloadIfNecessary();">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("year");
if(strTemp == null) strTemp = "";
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
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}if(strTemp.compareTo("7") ==0)
{%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}if(strTemp.compareTo("8") ==0)
{%>
          <option value="8" selected>8th</option>
          <%}else{%>
          <option value="8">8th</option>
          <%}%>
        </select> <select name="semester" onChange="ReloadIfNecessary();">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";

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
        </select> 
        <%}//only if degree type is not care giver type.%>
      </td>
    </tr>
    <%
if(strDegreeType != null && strDegreeType.compareTo("3") ==0){%>
    <tr> 
      <td height="6">&nbsp;</td>
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
      <td valign="bottom">&nbsp;</td>
    </tr>
    <%}//only if strDegree type is 3
%>
  </table>
<%
//if it is having school year - display resulet - else do not display anything below this
if(vTemp.size() > 0)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td height="25">Class program for school year/term : </td>
      <td height="25"> <input name="school_year_fr" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("school_year_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ssection","school_year_fr","school_year_to")'>
        to
        <input name="school_year_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("school_year_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp; <select name="offering_sem" onChange="ReloadIfNecessary();">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("offering_sem");
if(strTemp == null) strTemp = "";

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
        </select> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">From what school year/term : </td>
      <td height="25"> <input name="prev_schyr_fr" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("prev_schyr_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ssection","prev_schyr_fr","prev_schyr_to")'>
        to
        <input name="prev_schyr_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("prev_schyr_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp; <select name="prev_offering_sem" onChange="ReloadIfNecessary();">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("prev_offering_sem");
if(strTemp == null) strTemp = "";

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
        </select> </td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td width="35%">&nbsp;</td>
      <td width="63%"><input type="image" src="../../../images/view.gif" onClick="ViewSubjectDetail();">
        <font size="1">Click to view the subject/section schedule available for 
        <strong>re-offer</strong></font></td>
    </tr>
    <tr>
      <td colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%
if(vSubToCopy != null && vSubToCopy.size() > 0)
{%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="20%" height="25" align="center"><font size="1"><strong>SUBJECT
        CODE</strong></font></td>
      <td width="12%" align="center"><font size="1"><strong>SECTION</strong></font></td>
      <td width="20%" align="center"><font size="1"><strong>SUBJECT TYPE</strong></font></td>
      <td width="41%" align="center"><font size="1"><strong>SCHEDULE(Days/Time)</strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>OFFER</strong></font></td>
    </tr>
    <%
String[] strConvertAMPM = {"AM","PM"};
String[] strConvertWeek = {"Sun","Mon","Tue","Wed","Thurs","Fri","Sat"};
for(i = 0; i< vSubToCopy.size(); ++i)
{%>
    <tr>
      <td height="25" align="center"><%=(String)vSubToCopy.elementAt(i+10)%></td>
      <td align="center"><%=(String)vSubToCopy.elementAt(i+8)%></td>
      <td align="center"><%=(String)vSubToCopy.elementAt(i+9)%></td>
      <td> <%=strConvertWeek[Integer.parseInt((String)vSubToCopy.elementAt(i+1))]%>
        - <%=(String)vSubToCopy.elementAt(i+2)%>:<%=(String)vSubToCopy.elementAt(i+3)%>
        <%=strConvertAMPM[Integer.parseInt((String)vSubToCopy.elementAt(i+4))]%>
        to <%=(String)vSubToCopy.elementAt(i+5)%>:<%=(String)vSubToCopy.elementAt(i+6)%>
        <%=strConvertAMPM[Integer.parseInt((String)vSubToCopy.elementAt(i+7))]%>
      </td>
      <td align="center">
	  <%if(iAccessLevel > 1){%>
	  <input type="image" src="../../../images/offer.gif" onClick='OfferSubject("<%=(String)vSubToCopy.elementAt(i)%>");'>
        <%}else{%>
        NA
        <%}%>
      </td>
    </tr>
    <%	i = i +10;
	}
}//if vSubToCopy is not null.
%>
  </table>
<%}//if vTemp != null
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<%
if(strCurIndex == null)
{
	strTemp = request.getParameter("cur_index");
	if(strTemp == null || strTemp.compareTo("0") ==0)
		strTemp = request.getParameter("cur_index0");
	if(strTemp == null || strTemp.trim().length() ==0) strTemp = strCurIndex0;
	if(strTemp == null) strTemp = "0";
}
else
	strTemp = strCurIndex;
%>
<input type="hidden" name="cur_index" value="<%=strTemp%>">
<input type="hidden" name="viewSubjectDetail" view="<%=WI.fillTextValue("viewSubjectDetail")%>">
<input type="hidden" name="offerSubject" value="0">
<input type="hidden" name="info_index" value="0">
<input type="hidden" name="degreeType" value="<%=WI.getStrValue(strDegreeType)%>">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>
