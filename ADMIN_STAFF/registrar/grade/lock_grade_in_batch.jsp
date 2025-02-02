<%@ page language="java" import="utility.*,enrollment.GradeSystem,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - REPORTS","lock_grade_in_batch.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
<p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","GRADES",request.getRemoteAddr(),
														"lock_grade_in_batch.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

GradeSystem GradeSystem = new GradeSystem();
String strSYFrom   = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");

if(strSYFrom.length() == 0) {
	strSYFrom   = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
}
  
Vector vRetResult = null;
   
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(GradeSystem.operateOnGradeAllowViewToStud(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = GradeSystem.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}
	
vRetResult = GradeSystem.operateOnGradeAllowViewToStud(dbOP, request, 4);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PageAction(strAction)
{
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" action="lock_grade_in_batch.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5" align="center" style="font-weight:bold; color:#FFFFFF"> :::: LOCK GRADE IN BATCH PAGE ::::</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%">SY-TERM</td>
      <td height="25" colspan="2"><input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
		    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		    onkeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" />
        -
        <select name="semester" >
          <option value="1">1st Sem</option>
<%
if(strSemester.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strSemester.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
<%
if(strSemester.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="0"<%=strErrMsg%>>Summer</option>
        </select>
      </td>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%">EXAM PERIOD</td>
      <td><select name="pmt_sch" >
          <%=dbOP.loadCombo("pmt_sch_index","exam_name"," from FA_PMT_SCHEDULE  where is_valid=1 and exam_name not like 'final%' order by EXAM_PERIOD_ORDER asc",WI.fillTextValue("pmt_sch") , false)%>
        </select>
      </td>
    <tr>
    <tr>
      <td height="10" colspan="6">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="83%" height="15"><a href="javascript:PageAction('1');"><img src="../../../images/add.gif" border="0" /></a>
        </div></td>
    </tr>
	<tr>
      <td height="10" colspan="6">&nbsp;</td>
    </tr>
  </table>
   
<%if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="22" colspan="7" bgcolor="#cccccc" class="thinborderTOP"><div align="center"><strong>VIEW DETAIL</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="13%" class="thinborder" height="22">Exam Period</td>
      <td width="8%" class="thinborder">Date Locked</td>
    </tr>
	<% for (int i =0; i<vRetResult.size(); i+=5){%>
		<tr align="center" >
		  <td class="thinborder" height="22"><%=(String)vRetResult.elementAt(i+1)%></td>
		  <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
		</tr>
    <%}%>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" >&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
</form>
</body>
</html>
