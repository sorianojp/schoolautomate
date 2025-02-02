<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Excluded subject list</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function ResetEntries()
{
	document.lo_sub.resetEntries.value = "1";
	ReloadPage();
}
function ReloadPage()
{
	document.lo_sub.page_action.value = "";
	document.lo_sub.submit();
}
function PageAction(strAction,strInfoIndex)
{
	document.lo_sub.page_action.value = strAction;
	document.lo_sub.info_index.value = strInfoIndex;
	document.lo_sub.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeExcludedForSubject,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI        = new WebInterface(request);

	String[] astrSchYrInfo = null;
	String strSubjectName  = null;
	String strTemp         = null;
	String strErrMsg       = null;
	Vector vRetResult      = null;
	String strDegreeType   = null;


//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Fee Assessment & Payments-list of excluded subjects","list_of_excluded_subjects.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"list_of_excluded_subjects.jsp");
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
astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)
{
	dbOP.cleanUP();
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		School year information not found.</font></p>
		<%
		return;
}
FAFeeExcludedForSubject excludeSub = new FAFeeExcludedForSubject();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() >0)
{
	if(excludeSub.operateOnFeeExcludedOnSubject(dbOP,request,Integer.parseInt(strTemp)) == null)
		strErrMsg = excludeSub.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}
vRetResult = excludeSub.operateOnFeeExcludedOnSubject(dbOP,request,4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = excludeSub.getErrMsg();

if(WI.fillTextValue("sub_index").length() > 0 && WI.fillTextValue("sub_index").compareTo("0") != 0 && WI.fillTextValue("resetEntries").compareTo("1") != 0)
{
	strSubjectName = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",WI.fillTextValue("sub_index"),"sub_name"," and is_del=0");
}
if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("0") != 0)
{
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"degree_type",null);
	if(strDegreeType == null)
		strErrMsg = dbOP.getErrMsg();
}
%>
<form name="lo_sub" action="./list_of_excluded_subjects.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          EXCLUDED SUBJECTS IN FEE ASSESSMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%" height="25">Course Program</td>
      <td height="25" colspan="2"><select name="cc_index" onChange="ResetEntries();">
          <option value="0">Select a Program</option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc", request.getParameter("cc_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course</td>
      <td height="25" colspan="2"><select name="course_index"  onChange="ResetEntries();">
          <option value="0">Select a course</option>
          <%
if(WI.fillTextValue("cc_index").length()>0){%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and cc_index="+
 						request.getParameter("cc_index")+" order by course_name asc", request.getParameter("course_index"), false)%>
          <%}%>
        </select></td>
    </tr>
<!--    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Major</td>
      <td height="25" colspan="2"><select name="major_index" onChange="ResetEntries();">
          <%
if(WI.fillTextValue("course_index").length()>0 && WI.fillTextValue("changeProgram").compareTo("1") != 0){
strTemp = " from major where IS_DEL=0 and course_index="+request.getParameter("course_index")+" order by major_name asc";
%>
          <%=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index="+
 							request.getParameter("course_index")+" order by major_name asc", request.getParameter("major_index"), false)%>
          <%}%>
        </select></td>
    </tr>-->
    <tr>
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">School Year</td>
      <td width="21%" height="25">
        <%
	  strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[0];
	  %>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("lo_sub","sy_from","sy_to")'>
        <%
	  strTemp = WI.fillTextValue("sy_to");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[1];
	  %>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
      </td>
      <td width="60%" height="25">Term
        <select name="semester"  onChange="ReloadPage();">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = astrSchYrInfo[2];
if(strTemp.compareTo("1") ==0){%>
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
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%" height="25">Subject Code</td>
      <td height="25" colspan="4">
	  <select name="sub_index" onChange="ReloadPage();">
	  <option value="0">Select a subject</option>
<%
if(strDegreeType != null && strDegreeType.compareTo("1") ==0){%>
<%=dbOP.loadCombo("distinct cculum_masters.SUB_INDEX","sub_code"," from cculum_masters join subject on (subject.sub_index = cculum_masters.sub_index) where cculum_masters.IS_DEL=0 and cculum_masters.is_valid=1 and course_index="+
 						request.getParameter("course_index")+" order by sub_code asc", request.getParameter("sub_index"), false)%>
<%}else if(strDegreeType != null && strDegreeType.compareTo("2") ==0){//THIS IS NEVER USED. USUALLY, SUBJECTS ARE FROM UNDERGRAD.%>
<%=dbOP.loadCombo("distinct cculum_medicine.MAIN_SUB_INDEX","sub_code"," from cculum_medicine join subject on (subject.sub_index = cculum_medicine.MAIN_sub_index) where cculum_medicine.IS_DEL=0 and cculum_medicine.is_valid=1 AND course_index="+
 						request.getParameter("course_index")+" order by sub_code asc", request.getParameter("sub_index"), false)%>
<%}else{%>
<%=dbOP.loadCombo("distinct curriculum.SUB_INDEX","sub_code"," from curriculum join subject on (subject.sub_index = curriculum.sub_index) where curriculum.IS_DEL=0 and curriculum.is_valid=1 and course_index="+
 						request.getParameter("course_index")+" order by sub_code asc", request.getParameter("sub_index"), false)%>
<%}%>
        </select>
        : <strong><%=WI.getStrValue(strSubjectName)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>click
        to reload subject list(in case school year is changed and page is not
        reloaded yet)</td>
    </tr>
<%
if(strSubjectName != null && strSubjectName.length() > 0)
{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
	  <%
	  if(iAccessLevel > 1){%>
	  <a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border=0></a>click to
        add subject to list
	 <%}else{%>
	 N/A to add (User is having read only access)
	 <%}%>	</td>
    </tr>
<%}%>

  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
	<tr>

      <td align="right"> <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">Click to print list</font>
      </td>
	</tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
	<tr>
      <td height="25" colspan="8" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF">LIST
          OF SUBJECTS EXCLUDED IN FEE ASSESSMENT</font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8"><b>Total Subjects Excluded : <%=vRetResult.size()/4%></b>
        <div align="right"></div></td>
    </tr>
    <tr>
      <td width="20%" height="25"><div align="center"><strong><font size="1">SUBJECT
          CODE </font></strong></div></td>
      <td width="40%"><div align="center"><strong><font size="1">SUBJECT TITLE</font></strong></div></td>
      <td width="35%"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="5%">&nbsp;</td>
      </tr>
<%
for(int i = 0; i< vRetResult.size(); ++i){%>
    <tr>
      <td height="25" valign="top"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td valign="top"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=(String)vRetResult.elementAt(i + 3)%></td>

      <td valign="top">
	  <%
	  if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction(0,<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../images/delete.gif" border=0></a><%}else{%>
	  N/A <%}%></td>
    </tr>
<%
i = i+3;
}%>
  </table>
<table width="100%" height="15" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="10%" height="25">&nbsp;</td>
      <td colspan="4" height="25" align="center"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
          to print list</font></td>
      <td width="5%" height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="resetEntries" value="">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index">

</form>
</body>
</html>

<%
dbOP.cleanUP();
%>
