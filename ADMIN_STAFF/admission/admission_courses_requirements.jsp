<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.admissionreq.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CourseRequirement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar-admission requirement","course_requirement.jsp");
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

//end of authenticaion code.

CourseRequirement cRequirement = new CourseRequirement();
Vector vRetResult = null;
vRetResult = cRequirement.operateOnRequirement(dbOP,request,4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = cRequirement.getErrMsg();


%>
<form name="admissionreq" action="./admission_courses_requirements.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr  bgcolor="#47768F">
      <td width="87%" height="25" colspan="7" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF">:::: 
          LIST OF ADMISSION REQUIREMENTS ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%">&nbsp;</td>
      <td><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="18%">School year </td>
      <td width="27%"> 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("admissionreq","sy_from","sy_to")'>
        to 
        <%
strTemp = request.getParameter("sy_to");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> 
      </td>
      <td width="25%">Year level 
        <%
strTemp = WI.fillTextValue("year_level");
%>
        <select name="year_level">
          <%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>All</option>
          <%}else{%>
          <option value="0">All</option>
          <%}if(strTemp.compareTo("1") ==0){%>
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
          <%}if(strTemp.compareTo("7") ==0){%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}%>
        </select> </td>
      <td width="26%"><a href='javascript:ReloadPage();'><img src="../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" border="1" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6"><div align="center">LIST OF ADMISSION REQUIREMENTS</div></td>
    </tr>
    <tr> 
      <td width="13%"><font size="1"><strong>COLLEGE</strong></font></td>
      <td width="37%" align="center"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="24%" height="25"><div align="center"><font size="1"><strong>REQUIREMENT</strong></font></div></td>
      <td width="6%" align="center"><strong><font size="1">STUD STATUS</font></strong></td>
      <td width="6%" align="center"><font size="1"><strong>YEAR LEVEL</strong></font></td>
      <td width="6%" align="center"><strong><font size="1">ONLY FOR FOREIGN STUD</font></strong></td>
    </tr>
    <%
for(int i = 0; i<vRetResult.size(); i +=15){%>
    <tr> 
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 10),"ALL")%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 11),"ALL")%> 
        <%
	  if(vRetResult.elementAt(i + 12) != null) {%>
        /<%=(String)vRetResult.elementAt(i + 12)%> 
        <%}%>
      </td>
      <td height="25" align="center"><%=(String)vRetResult.elementAt(i + 9)%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 13),"ALL")%></td>
      <td align="center"> 
        <%
	  if( ((String)vRetResult.elementAt(i + 6)).compareTo("0") == 0){%>
        ALL 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i + 6)%> 
        <%}%>
      </td>
      <td align="center"> 
        <%
	  if( ((String)vRetResult.elementAt(i + 8)).compareTo("1") == 0){%>
        <img src="../../images/tick.gif"> 
        <%}else{%>
        &nbsp; 
        <%}%>
      </td>
    </tr>
    <%}%>
  </table>
 <%}%>



  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="5%">&nbsp;</td>
      <td width="95%"><font size="1"><a href="../../download/gspis.doc" target="_blank">
	  <img src="../../images/download.gif" width="72" height="27" border="0"></a>click
        to download the General Student Personal Information Sheet (GSPIS)</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>

  </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
