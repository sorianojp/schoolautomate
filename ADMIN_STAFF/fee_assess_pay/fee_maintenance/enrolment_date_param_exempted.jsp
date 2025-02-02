<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PageAction(strInfoIndex,iAction)
{
	document.form_.page_action.value = iAction ;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.submit();
}
function ClearEntries()
{
 	document.form_.specific_date.value = "";
	document.form_.days.value = "";
	if(document.form_.adj_type.selectedIndex > 0)
		document.form_.amount.value = "";
	document.form_.remark.value = "";
}
function UpdateExcludedCourse() {
	var pgLoc = "./enrolmnet_date_param_exempted.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceVairable,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Fee Assessment & Payments-enrolment date param","enrolment_date_param_exempted.jsp");
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
														"enrolment_date_param_exempted.jsp");
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
FAFeeMaintenanceVairable fmVariable = new FAFeeMaintenanceVairable();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	if(fmVariable.operateOnEnrollmentDiscountExempt(dbOP,request,Integer.parseInt(strTemp)) == null)
		strErrMsg = fmVariable.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}
//get all information from table for the current sem.

if(WI.fillTextValue("sy_from").length() > 0)
{
	vRetResult = fmVariable.operateOnEnrollmentDiscountExempt(dbOP,request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = fmVariable.getErrMsg();
}

%>

<form name="form_" action="./enrolment_date_param_exempted.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: ENROLMENT
          DATE PARAMETERS PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="22%">School Year/Term</td>
      <td width="30%">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp; <select name="offering_sem" >
          <option value="">ALL</option>
          <%
strTemp =WI.fillTextValue("offering_sem");
if(request.getParameter("offering_sem") == null) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="45%"><input name="image" type="image" src="../../../images/refresh.gif">
        <font size="1">or <a href="javascript:ClearEntries();"><img src="../../../images/clear.gif" border="0"></a>clear
        all entries</font></td>
    </tr>
    <tr>
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="0%" height="25">&nbsp;</td>
      <td width="25%" align="right">COURSE REFERENCE&nbsp;&nbsp;&nbsp;</td>
      <td width="75%"><select name="course_index" onChange="ReloadCourseIndex();">
          <option value="">Select a course</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 order by course_name asc", 
	request.getParameter("course_index"), false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><div align="right"></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"> <div align="left"></div></td>
      <td height="25" colspan="2"> <%
if(iAccessLevel > 1){%> <a href='javascript:PageAction("",1);'><img src="../../../images/save.gif" border="0"></a> 
        <font size="1">click to add/save entries &nbsp;</font> <%}else{%>
        ONLY VIEW PERMITTED 
        <%}%> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="45%" height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5"><div align="center">LIST OF COURSE 
          NOT OFFERING DISCOUNTS</div></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="78%" height="25"><div align="center"><font size="1"><strong>COURSE 
          NAME </strong></font></div></td>
      <td width="22%"><div align="center"><strong><font size="1">SEMESTER</font></strong></div></td>
      <td width="22%">&nbsp;</td>
    </tr>
    <%//System.out.println(vRetResult.size());System.out.println(vRetResult);
	for(int i = 0 ; i< vRetResult.size() ; i += 3){%>
    <tr> 
      <td height="25"><div align="center"><%=(String)vRetResult.elementAt(i + 1)%></div></td>
      <td><div align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 2),"ALL")%></div></td>
      <td> <%if(iAccessLevel ==2){%> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        N/A 
        <%}%> </td>
    </tr>
    <%}%>
  </table>
 <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#ffffff">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
 <input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>