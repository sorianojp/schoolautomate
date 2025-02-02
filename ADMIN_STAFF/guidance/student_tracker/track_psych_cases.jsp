<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function ViewDetails(strInfoIndex, strStudIndex)
{
	var pgLoc = "../pyschological_cases/view_dtls_psych_cases.jsp?stud_id="+strStudIndex+"&info_index="+strInfoIndex+"&psyc_res_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}

<!--
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID()
{
	document.form_.stud_id.focus();
}
-->
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDPsychological, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrSemester = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Student Tracker-Psychological Status","track_psych_cases.jsp");
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
														"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
														"track_psych_cases.jsp");
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
	GDPsychological GDPsych = new GDPsychological();
	vRetResult = GDPsych.operateOnPsychCase(dbOP, request, 4);
	
	if (strErrMsg == null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = GDPsych.getErrMsg();
%>
<body bgcolor="#663300" onload="FocusID()">
<form action="./track_psych_cases.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: PSYCHOLOGICAL CASE TRACKING PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td colspan="3" height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
   </tr>
    <tr> 
      <td width="5%"><p>&nbsp;</p></td>
      <td width="95%" colspan="2">School Year : 
        <%strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
        <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
/
<select name="semester">
  <%strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
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
      <td height="25" width="50%">Student ID &nbsp;: 
        <%strTemp = WI.fillTextValue("stud_id");%>
     <input name="stud_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">  </td>
      <td height="25" width="45%"><a href="javascript:StudSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      <font size="1">click to search for student ID</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
    </table>
<%if (vRetResult != null && vRetResult.size()>0){%>	  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#A9C0CD"> 
      <td height="25" colspan="9" class="thinborder">
        <div align="center"><font color="#FFFFFF"><strong>SUMMARY OF PSYCHOLOGICAL 
          CASES</strong></font></div></td>
    </tr>
    <tr> 
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>SY/TERM</strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>DATE OF EXAM</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>EXAMINED 
          BY </strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>RESULTS &amp; 
          INTERPRETATIONS</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong><font size="1">CONCLUSIONS AND 
          RECOMMNEDATIONS </font></strong></div></td>
      <td width="16%" class="thinborder" colspan="3"><div align="center"><strong><font size="1">OPTIONS </font></strong></div></td>
    </tr>
    <%for (int i = 0; i< vRetResult.size(); i+=18){%>
    <tr> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;-&nbsp;<%=(String)vRetResult.elementAt(i+2)%><br><%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+3))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
      <td class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+12), (String)vRetResult.elementAt(i+13), (String)vRetResult.elementAt(i+14),7)%></td>
      <td class="thinborder"><%strTemp = (String)vRetResult.elementAt(i+16);
      if (strTemp.length()>20){%>
      <%=strTemp.substring(0,20)%>...more<%}else{%><%=strTemp%><%}%></td>
      <td class="thinborder"><%strTemp = (String)vRetResult.elementAt(i+17);
      if (strTemp.length()>20){%>
      <%=strTemp.substring(0,20)%>...more<%}else{%><%=strTemp%><%}%></td>
      <td width="16%" class="thinborder" colspan="3"><div align="center"><a href='javascript:ViewDetails(<%=((String)vRetResult.elementAt(i))%>, "<%=((String)vRetResult.elementAt(i+4))%>")'>
	  <img src="../../../images/view.gif" width="40" height="31" border="0"></a></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><div align="center"> </div></td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>