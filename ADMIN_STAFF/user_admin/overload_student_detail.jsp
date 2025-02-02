<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;
	if(strPageAction == 1)
		document.form_.hide_save.value = "../../../images/blank.gif";
	document.form_.submit();
}
function ShowOverLoadSubDetail() {
	if(document.form_.overload_sub_detail.checked){//check if all information are entered.
		if(document.form_.offering_yr_from.value.length == 0 ||
			document.form_.offering_yr_from.value.length == 0) {
			alert("Please enter Student ID, Schoolyear information.");
			document.form_.overload_sub_detail.checked = false;
			return;
		}
		//I have to send this page to other location.
		location = "./overload_student_detail_view.jsp?stud_id="+
		escape(document.form_.stud_id.value)+"&offering_yr_from="+
		document.form_.offering_yr_from.value+"&offering_yr_to="+
		document.form_.offering_yr_to.value+"&offering_sem="+
		document.form_.offering_sem[document.form_.offering_sem.selectedIndex].value;
	}
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.OverideParameter,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	float fOverLoadUnit = 0f;

	String[] astrConvertSem ={"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","overload_student_detail.jsp");

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
														"System Administration","Override Parameters",request.getRemoteAddr(),
														"overload_student_detail.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

OverideParameter OP = new OverideParameter();
Vector vStudDetail = null;
Vector vRetResult = null;
Vector vEnrolledSubjectList = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(OP.operateOnOverLoadSubDetail(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = OP.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}

//get here subject detail.
if(WI.fillTextValue("stud_id").length() > 0  && WI.fillTextValue("offering_yr_from").length() > 0)
{
	vStudDetail = OP.getStudentLoadInfo(dbOP,request.getParameter("stud_id"),WI.fillTextValue("offering_yr_from"),
									WI.fillTextValue("offering_yr_to"),WI.fillTextValue("offering_sem"));
	if(vStudDetail == null)
		strErrMsg = OP.getErrMsg();
	else {
		strTemp = dbOP.mapOneToOther("OVR_STUD_LOAD","USER_INDEX",
					(String)vStudDetail.elementAt(0),"(NEW_MAX_LOAD - SEM_MAX_LOAD)",
                     " and offering_sy_from="+WI.fillTextValue("offering_yr_from")+
					 " and offering_sem="+WI.fillTextValue("offering_sem")+
					 " and is_valid = 1 and is_del=0");
		if(strTemp != null)
			fOverLoadUnit = Float.parseFloat(strTemp);
		if(fOverLoadUnit <= 0)
			strErrMsg = "Please overload the student first.";//System.out.println(fOverLoadUnit);
		else { // i have to get the student's subjet detail
			enrollment.ReportEnrollment repEnrollment = new enrollment.ReportEnrollment();
			vEnrolledSubjectList = repEnrollment.getStudentLoad(dbOP, WI.fillTextValue("stud_id"),
				WI.fillTextValue("offering_yr_from"),WI.fillTextValue("offering_yr_to"),
				WI.fillTextValue("offering_sem"));
			if(vEnrolledSubjectList == null)
				strErrMsg = repEnrollment.getErrMsg();
		}
	}

	//I have to get the list of subject overloaded .
	vRetResult = 	OP.operateOnOverLoadSubDetail(dbOP, request,3);
}



%>


<form name="form_" action="./overload_student_detail.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          OVERLOAD SUBJECT DETAIL ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="28" width="2%">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School Year : </td>
      <td colspan="2"> <%
strTemp = WI.fillTextValue("offering_yr_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="offering_yr_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","offering_yr_from","offering_yr_to")'>
        -
        <%
strTemp = WI.fillTextValue("offering_yr_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="offering_yr_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="offering_sem">
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
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
      <td align="right"><a href="./overload_student_report.jsp">Go to overload Report</a></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%">Student ID</td>
      <td width="24%"> <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="7%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a></td>
      <td width="54%"> <a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;</td>
      <td >&nbsp;</td>
      <td  colspan="3" ><input type="checkbox" name="overload_sub_detail" value="1" onClick="ShowOverLoadSubDetail();">
        Click to Show Report of Student with Overloaded subject detail. </td>
    </tr>
    
    <tr >
      <td  colspan="5" ><hr size="1"></td>
    </tr>
  </table>

 <%
 if(vStudDetail != null && vStudDetail.size() > 0){%>
<input type="hidden" name="over_sload_index" value="<%=(String)vStudDetail.elementAt(9)%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="2">Student name : <strong><%=(String)vStudDetail.elementAt(1)%></strong></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">Course/Major :<strong> <%=(String)vStudDetail.elementAt(2)%>
        <%
	  if(vStudDetail.elementAt(3) != null){%>
        / <%=(String)vStudDetail.elementAt(3)%>
        <%}%>
        </strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td width="48%" height="25">Enrolling YR : <strong><%=(String)vStudDetail.elementAt(4)%>
        <%
	  if( ((String)vStudDetail.elementAt(8)).length() > 0){%>
        (<%=(String)vStudDetail.elementAt(8)%>)
        <%}%>
        </strong> </td>
      <td width="50%">Status:<strong> <%=(String)vStudDetail.elementAt(7)%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Total maximum units allowed in this term: <strong><%=(String)vStudDetail.elementAt(5)%></strong></td>
    </tr>
    <%
if( vStudDetail.elementAt(6) != null){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><font color="#0000FF">Overloaded maximum
        allowed unit in this term : <%=(String)vStudDetail.elementAt(6)%></font></strong></td>
    </tr>
    <%}%>
  </table>

<%
}//only if vStud info is not null
if(fOverLoadUnit > 0f){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td  colspan="2"><hr size="1"></td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td width="94%" colspan="" valign="bottom">Subject Code
        <select name="sub_index" onChange="ReloadPage();">
          <option value="">Select a subject to add</option>
          <%
		strTemp = WI.fillTextValue("sub_index");
		if(vEnrolledSubjectList != null && vEnrolledSubjectList.size() > 0){
			for(int i = 1 ; i < vEnrolledSubjectList.size() ; i += 11){
				if(strTemp.compareTo((String)vEnrolledSubjectList.elementAt(i + 10)) == 0){%>
          <option value="<%=(String)vEnrolledSubjectList.elementAt(i + 10)%>" selected><%=(String)vEnrolledSubjectList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vEnrolledSubjectList.elementAt(i + 10)%>"><%=(String)vEnrolledSubjectList.elementAt(i)%></option>
          <%}
			}
		}%>
        </select>
        Subject Units Overloading
        <input name="load_unit" type="text" size="3" value="<%=WI.fillTextValue("load_unit")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><font color="#0000FF"><%=WI.getStrValue(dbOP.mapOneToOther("subject","sub_index",WI.fillTextValue("sub_index"),"sub_name",null))%></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><font color="#0000FF">
	  <%
	  strTemp = WI.fillTextValue("IS_NEW_RATE");
	  if(strTemp.compareTo("1") == 0)
	  	strTemp = "checked";
	  else
	   	strTemp = "";%>
        <input type="checkbox" name="IS_NEW_RATE" value="1" <%=strTemp%>>
        Click to use Special Rate for overloaded subject.</font></td>
    </tr>
    <tr>
      <td height="45">&nbsp;</td>
      <td valign="bottom"><a href='javascript:PageAction("","1");'> <img src="../../images/save.gif" border="0" name="hide_save"></a>
        <font size="1">click to save overload subject information.</font></td>
    </tr>
  </table>
  <%}//only if over load unit > 0
  if(vRetResult != null && vRetResult.size() > 0){
  %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="6"><strong><font size="1">MAX SEM LOAD:<%=(String)vRetResult.elementAt(4)%>
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  MAX ALLOWED LOAD: <%=(String)vRetResult.elementAt(5)%> </font></strong></td>
    </tr>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center"><strong>SUBJECT OVERLOAD
          DETAIL</strong></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="21%" height="25"><div align="center"><font size="1"><strong>SUBJECT
          CODE</strong></font></div></td>
      <td width="44%" height="25"><div align="center"><font size="1"><strong>SUBJECT
          DESCRIPTION</strong></font></div></td>
      <td width="7%" height="25"><div align="center"><font size="1"><strong>UNITS
          OVERLOADED</strong></font></div></td>
      <td width="9%"><div align="center"><strong><font size="1">SPECIAL RATE</font></strong></div></td>
      <td width="9%" height="25"><div align="center"><font size="1"><strong>DELETE</strong></font></div></td>
    </tr>
    <%
	for(int i = 0 ; i < vRetResult.size(); i += 10){%>
    <tr>
      <td height="25"><%=(String)vRetResult.elementAt(i + 6)%> </td>
      <td height="25"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td height="25"><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td><%
	  if( ((String)vRetResult.elementAt(i + 9)).compareTo("1") == 0){%>
	  <img src="../../images/tick.gif">
	  <%}%>&nbsp;</td>
      <td height="25"> <%if(iAccessLevel == 2){%> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'>
        <img src="../../images/delete.gif" border="0"></a> <%}%></td>
    </tr>
    <%}%>
  </table>
<%}//end of display if vRetResult > 0%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="over_load_unit" value="<%=fOverLoadUnit%>">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
