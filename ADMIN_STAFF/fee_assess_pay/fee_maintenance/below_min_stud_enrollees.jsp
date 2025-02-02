<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Medicine Load Hours Rate</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.fm_variable.page_action.value = "";
	document.fm_variable.submit();
}
function PageAction(strInfoIndex,iAction)
{
	document.fm_variable.page_action.value = iAction ;
	if(strInfoIndex.length > 0)
		document.fm_variable.info_index.value = strInfoIndex;
	if(iAction ==1)
		document.fm_variable.hide_save.src = "../../../images/blank.gif";
	document.fm_variable.submit();
}
function ShowHideLoadHrTo()
{
	if(document.fm_variable.no_of_stud_con.selectedIndex == 3)
		showLayer('rangeTo_');
	else
		hideLayer('rangeTo_');

}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceVairable,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String strDegreeType = null;
	String strPrepareToEdit  ="0";//by default edit is not available.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Fee Assessment & Payments-Below min student enrollees","below_min_stud_enrollees.jsp");
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
														"below_min_stud_enrollees.jsp");
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
Vector vEditInfo  = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	if(fmVariable.operateOnRequestedSubParam(dbOP,request,Integer.parseInt(strTemp)) == null)
		strErrMsg = fmVariable.getErrMsg();
	else
	{
		strErrMsg = "Operation successful.";
		strPrepareToEdit = "0";
	}
}
//get all information from table for the current sem.

if(WI.fillTextValue("sy_from").length() > 0)
{
	vRetResult = fmVariable.operateOnRequestedSubParam(dbOP,request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = fmVariable.getErrMsg();
}

if(WI.fillTextValue("course_index").length() > 0) {
	strDegreeType = dbOP.mapOneToOther("course_offered","course_index",WI.fillTextValue("course_index"),"degree_type",null);
}

String strSchoolCode = WI.getStrValue(request.getSession(false).getAttribute("school_code"));


%>

<form name="fm_variable" action="./below_min_stud_enrollees.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          BELOW MINIMUM STUDENT ENROLEES PARAMETERS PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td width="7%" height="25">&nbsp;</td>
      <td width="12%" height="25">SY/TERM</td>
      <td width="40%" height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fm_variable","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp; <select name="semester" >
          <option value="">ALL</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
      <td width="41%" height="25"><input type="image" src="../../../images/refresh.gif"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">COURSE</td>
      <td height="25" colspan="2"><select name="course_index" onChange="ReloadPage();">
          <option value="">ALL Course</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc",
		  						WI.fillTextValue("course_index"), false)%> </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">MAJOR</td>
      <td height="25" colspan="2"><select name="major_index" onChange="ReloadPage();">
          <option value="">ALL Major</option>
          <%
if(WI.fillTextValue("course_index").length() > 0)
{
%>
          <%=dbOP.loadCombo("major_index","major_name"," from major where is_del=0 and course_index="+WI.fillTextValue("course_index"),
		  			 WI.fillTextValue("major_index"), false)%>
          <%}%>
        </select> </td>
    </tr>
    <%
if(strDegreeType != null && strDegreeType.compareTo("1") != 0 && strDegreeType.compareTo("4") != 0){%>
    <%}//only if yearleve is valid for the course selected
%>
    <tr>
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
      <td width="23%" height="25">No. of Students in a class</td>
      <td height="25"> <select name="no_of_stud_con" onChange="ShowHideLoadHrTo();">
          <option value="0">Equal to</option>
          <%
strTemp = WI.fillTextValue("no_of_stud_con");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Less than</option>
          <%}else{%>
          <option value="1">Less than</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>More than</option>
          <%}else{%>
          <option value="2">More than</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>Between</option>
          <%}else{%>
          <option value="3">Between</option>
          <%}%>
        </select> <input name="no_of_stud_fr" type="text" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("no_of_stud_fr")%>"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <input name="no_of_stud_to" type="text" size="4" maxlength="4" class="textbox" id="rangeTo_"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("no_of_stud_to")%>"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <script language="JavaScript">
ShowHideLoadHrTo();
</script>
    </tr>
<%
if(strSchoolCode.startsWith("VMUF")) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Multiplying Factor</td>
      <td width="70%" height="25"><input name="mul_factor" type="text" size="4" maxlength="4"
	  value="<%=WI.fillTextValue("mul_factor")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
      <input type="hidden" name="mul_factor_type" value="0"></td>
    </tr>
<%}else if(strSchoolCode.length() > 0) {%>
	<tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><select name="mul_factor_type">
	  <option value="1">Fee Per Unit</option>
<%
strTemp = WI.fillTextValue("mul_factor_type");
if(strTemp.compareTo("2") == 0){%>	  
	  <option value="2" selected>Fee Per Type</option>
<%}else{%>
	  <option value="2">Fee Per Type</option>
<%}%>
	  </select></td>
      <td width="70%" height="25"><input name="mul_factor" type="text" size="5" maxlength="5"
	  value="<%=WI.fillTextValue("mul_factor")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
      </td>
    </tr>
<%}%>

    <tr> 
      <td height="25">&nbsp;</td>
      <td>Applicable for </td>
      <td>
<select name="alien_status">
          <option value="0">Applicable to all</option>
          <%
strTemp = WI.fillTextValue("alien_status");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Local student only</option>
<%}else{%>
          <option value="1">Local student only</option>
<%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>Foreign student only</option>
<%}else{%>
          <option value="2">Foreign student only</option>
<%}%>
        </select></td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2"> <%
	  if(strPrepareToEdit.compareTo("1") != 0 && iAccessLevel > 1){%> <a href='javascript:PageAction("",1);'><img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click 
        to add a new entry </font> <%}else if(strPrepareToEdit.compareTo("1") ==0 && iAccessLevel > 1){%> <a href='javascript:PageAction("",2);'><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel &amp; clear entries</font> <%}%> </td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
    <%
if(WI.fillTextValue("sy_from").length() > 0){
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = "ALL SEM";
else if(strTemp.compareTo("0") == 0)
	strTemp = "SUMMER";
else if(strTemp.compareTo("1") == 0)
	strTemp = "1ST SEM";
else if(strTemp.compareTo("2") == 0)
	strTemp = "2ND SEM";
else if(strTemp.compareTo("3") == 0)
	strTemp = "3RD SEM";
else
	strTemp = "UNDEFINED";
%>
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="3"><div align="center">LIST OF EXISTING NO. OF 
          STUDENTS PARAMETERS FOR BELOW MIN. STUDENTS FOR SY <%=request.getParameter("sy_from")+" - "+request.getParameter("sy_to")%>, <%=strTemp%></div></td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
String[] astrConvertToLoadCon = {" Equals to ","Less than ","Greater than ","Between "};
%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="18%" height="25"><div align="center"><font size="1"><strong>NO.
          OF STUDENTS IN A CLASS </strong></font></div></td>
      <td width="17%" height="25"><div align="center"><font size="1"><strong>MULTIPLYING
          FACTOR</strong></font></div></td>
      <td width="28%"><div align="center"><font size="1"><strong>COURSE</strong></font></div></td>
      <td width="22%"><div align="center"><strong><font size="1">MAJOR</font></strong></div></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%
String[] astrConvertYrLevel = {"ALL","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};
String[] astrConvertStudCon = {"Equals ","Less Than ","More Than ","Between "};
for(int i = 0 ; i< vRetResult.size(); i +=12)
{%>
    <tr>
      <td height="25"><%=astrConvertStudCon[Integer.parseInt((String)vRetResult.elementAt(i+8))]%>
	  	<%=(String)vRetResult.elementAt(i+9)%>
		<%if(vRetResult.elementAt(i+10) != null){%>
		and <%=(String)vRetResult.elementAt(i+10)%>
		<%}%>
		</td>
      <td height="25"><%=(String)vRetResult.elementAt(i+11)%></td>
      <td height="25"><%=WI.getStrValue(vRetResult.elementAt(i+6),"ALL")%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+7),"ALL")%></td>
      <td width="15%">
        <%if(iAccessLevel > 1){%>
        <!--<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
        &nbsp;&nbsp; &nbsp; -->
        <%}if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        N/A
        <%}%>
      </td>
      <%}%>
    </tr>
  </table>
<%}//if vRetResult is not null;

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>

    <tr bgcolor="#B8CDD1">
      <td height="25"bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
 <input type="hidden" name="page_action" value="">
 <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
