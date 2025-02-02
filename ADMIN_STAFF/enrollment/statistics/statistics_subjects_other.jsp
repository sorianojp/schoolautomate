<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;

	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS-subjects","statistics_subjects.jsp");
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
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.show_list.value = '';
	document.form_.submit();
}

function PrintThisPage() {
	var strInfo = "<div align=\"center\"><strong><font size=3><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </font></strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div><br>";
	this.insRowVarTableID('myADTable',0, 1, strInfo);
	
	if(document.getElementById("myADTable0"))
		document.getElementById('myADTable0').deleteRow(0);
	
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(1);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(1);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable00').deleteRow(0);
	
	document.bgColor = "#FFFFFF";
	alert("Click OK to print this page");
	window.print();
}

</script>
<body bgcolor="#D2AE72">
<%
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","STATISTICS",request.getRemoteAddr(),
														"statistics_subjects_other.jsp");
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

Vector vRetResult = new Vector();
StatEnrollment SE = new StatEnrollment();

if(WI.fillTextValue("show_list").length() > 0)	{
	vRetResult = SE.getStudEnrolledPerCourseSectionFatima(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = SE.getErrMsg();

}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";



%>
<form name="form_" action="./statistics_subjects_other.jsp" method="post">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><strong>SUBJECT OFFERING LISTING </strong></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr> 
      <td width="4%" height="25"></td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="3">School offereing year/term: 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp; <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
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
    </tr>
    <tr> 
      <td height="19" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td width="15%">Course</td>
      <td colspan="2"><select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("course_index","course_code, course_name"," from course_offered where is_valid = 1 order by course_code asc",
		  		request.getParameter("course_index"), false)%> </select> 
	  </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Sections</td>
      <td colspan="2">
<%if(WI.fillTextValue("sy_from").length() > 0) {%>
	  <select name="section_name">
          <option value="">All</option>
<%
strTemp = WI.fillTextValue("course_index");
if(strTemp.length() > 0) {
	strTemp = " and exists (select * from curriculum where is_valid = 1 and course_index = "+strTemp+" and is_valid = 1 and sub_index = e_sub_section.sub_index) ";
}
%>          <%=dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section"," from e_sub_section where is_valid = 1 and is_lec = 0 and offering_sy_from = "+WI.fillTextValue("sy_from")+
		  " and offering_sem = "+WI.fillTextValue("semester")+strTemp+" order by section asc",
		  		request.getParameter("section_name"), false)%> </select>
	  
<%}%>	  
	  </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td width="18%"><input name="image" type="image" onClick="document.form_.show_list.value='1';" src="../../../images/form_proceed.gif"></td>
      <td width="63%">&nbsp;</td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0 && false){%>
    <tr> 
      <td height="25"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintThisPage();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print statistics</font></div></td>
    </tr>
    <tr> 
      <td height="20" colspan="4">&nbsp; </td>
    </tr>
    <%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" width="50%" align="center" style="font-weight:bold;">&nbsp;&nbsp;SUBJECT OFFERING FOR AY
	  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>, 
          <%=dbOP.getHETerm(Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester"), "-1")))%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center">
      <td width="5%" class="thinborder" style="font-weight:bold; font-size:9px;">COUNT</td>
      <td width="50%" class="thinborder" style="font-weight:bold; font-size:9px;">SUBJECT CODE (DESCRIPTION)</td>
      <td width="15%" class="thinborder" style="font-weight:bold; font-size:9px;">SECTION</td>
      <td width="25%" class="thinborder" style="font-weight:bold; font-size:9px;">SCHEDULE</td>
      <td width="8%" class="thinborder" style="font-weight:bold; font-size:9px;">REGULAR ENROLLED </td>
      <td width="8%" class="thinborder" style="font-weight:bold; font-size:9px;">IRREGULAR ENROLLED</td>
      <td width="8%" height="20" class="thinborder" style="font-weight:bold; font-size:9px;">TOTAL ENROLLED </td>
      <td width="8%" class="thinborder" style="font-weight:bold; font-size:9px;">ROOM NUMBER </td>
      <td width="8%" class="thinborder" style="font-weight:bold; font-size:9px;">CAPACITY</td>
    </tr>
<%
for(int i = 0, iCount=0; i < vRetResult.size(); i += 11){%>
    <tr>
      <td class="thinborder"><%=++iCount%>.</td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%> :: <%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 10)%></td>
      <td height="25" class="thinborder" align="center"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder" align="center"><%=vRetResult.elementAt(i + 6)%></td>
      <td height="25" class="thinborder" align="center"><%=vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder" align="center"><%=vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder" align="center"><%=vRetResult.elementAt(i + 9)%></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable00">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="show_list">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
