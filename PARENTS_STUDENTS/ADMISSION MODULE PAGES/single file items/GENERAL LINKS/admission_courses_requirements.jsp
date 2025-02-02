<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Course Requirements</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder{
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

</style>
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.admissionreq.submit();
}
</script>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.CourseRequirement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;

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

//end of authenticaion code.
	String[] astrSchYrInfo = dbOP.getCurSchYr();
CourseRequirement cRequirement = new CourseRequirement();
Vector vRetResult = null;
vRetResult = cRequirement.operateOnRequirement(dbOP,request,100); // bypass authentication
if(vRetResult == null && strErrMsg == null)
	strErrMsg = cRequirement.getErrMsg();


%>
<form name="admissionreq" action="./admission_courses_requirements.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr  bgcolor="#47768F">
      <td width="87%" height="25" colspan="7" bgcolor="#47768F"><div align="center"><strong><font color="#FFFFFF">:::: 
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
	strTemp = astrSchYrInfo[0];
	%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("admissionreq","sy_from","sy_to")' readonly>
        to 
        <%
strTemp = request.getParameter("sy_to");
if(strTemp == null || strTemp.length() ==0)
		strTemp = astrSchYrInfo[1];
	%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
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
      <td width="26%"><a href='javascript:ReloadPage();'><img src="../../../../images/refresh.gif" width="71" height="23" border="0"></a></td>
    </tr>
    <tr> 
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6" bgcolor="#BECED3" class="thinborder"><div align="center"><strong>LIST OF ADMISSION REQUIREMENTS</strong></div></td>
    </tr>
    <tr> 
      <td width="13%" class="thinborder"><font size="1"><strong>COLLEGE</strong></font></td>
      <td width="37%" align="center" class="thinborder"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="24%" height="25" class="thinborder"><div align="center"><font size="1"><strong>REQUIREMENT</strong></font></div></td>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">STUD STATUS</font></strong></td>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>YEAR LEVEL</strong></font></td>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">ONLY FOR FOREIGN STUD</font></strong></td>
    </tr>
    <%
for(int i = 0; i<vRetResult.size(); i +=15){%>
    <tr> 
      <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 10),"ALL")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 11),"ALL")%> 
        <%
	  if(vRetResult.elementAt(i + 12) != null) {%>
        /<%=(String)vRetResult.elementAt(i + 12)%> 
        <%}%>
      </td>
      <td height="25" align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 9)%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 13),"ALL")%></td>
      <td align="center" class="thinborder"> 
        <%
	  if( ((String)vRetResult.elementAt(i + 6)).compareTo("0") == 0){%>
        ALL 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i + 6)%> 
        <%}%>
      </td>
      <td align="center" class="thinborder"> 
        <%
	  if( ((String)vRetResult.elementAt(i + 8)).compareTo("1") == 0){%>
        <img src="../../../../images/tick.gif" width="11" height="10"> 
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
      <td width="95%"><font size="1"><a href="../../../../download/gspis.doc" target="_blank">
	  <img src="../../../../images/download.gif" width="72" height="27" border="0"></a>click
        to download the General Student Personal Information Sheet (GSPIS)</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
