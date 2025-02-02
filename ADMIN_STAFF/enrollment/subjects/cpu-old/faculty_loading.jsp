<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Subject Section Scheduling Page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" SRC="../../../../jscript/td.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}


function PageAction2(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index2.value = strInfoIndex;
	document.form_.page_action2.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit2(strInfoIndex) {
	document.form_.info_index2.value = strInfoIndex;
	document.form_.page_action2.value = "";
	document.form_.prepareToEdit2.value = "1";
	this.SubmitOnce('form_');
}
function Cancel2() 
{
	document.form_.info_index2.value = "";
	document.form_.page_action2.value = "";
	document.form_.prepareToEdit2.value = "";
	this.SubmitOnce('form_');
}
function ModifyCounsInfo()
{
	document.form_.save_couns.value = "1";	
	this.SubmitOnce('form_');	
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.fac_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,enrollment.SubjectSection, enrollment.SubjectSectionCPU, java.util.Vector, java.util.Date" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	WebInterface WI = new WebInterface(request);
	Vector vTemp = new Vector();
	int iCtr = 0;
	String[] astrSemester =  {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strPrepareToEdit2 = WI.getStrValue(WI.fillTextValue("prepareToEdit2"),"0");

	boolean bolFatalErr = false;

	//this is necessary for different types of subject offering.
	//degree_type=0->UG,1->Doctoral,2->medicine,3->with prep proper, 4-> care giver.
	//for care giver,doctoral, do not show year level, for prep_prop, show prep/prop status.
	String strDegreeType = null;

	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning","faculty_loading.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		strTemp = "<form name=ssection><input type=hidden name=showsubject></form>";
		%><%=strTemp%><%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"faculty_loading.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	if(!response.isCommitted())
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
	else
	%>
		<script language="JavaScript">
		location = "../../../../commfile/fatal_error.jsp";
		</script>
	<%
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	if(!response.isCommitted())
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	else
	%>
		<script language="JavaScript">
		location = "../../../../commfile/unauthorized_page.jsp";
		</script>
	<%
	return;
}

//end of authenticaion code.

strTemp = WI.fillTextValue("page_action");
strErrMsg = null; //if there is any message set -- show at the bottom of the page.
Vector vEditInfo = null;
Vector vRetResult = null;

/**duplicate for non acad**/
Vector vEditInfo2 = null;
Vector vRetResult2 = null;
Vector vCounsInfo = null;

SubjectSectionCPU subSecCPU = new SubjectSectionCPU();

if(strTemp.length() > 0) {
		if(subSecCPU.operateOnFacultyLoading(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else
			strErrMsg = subSecCPU.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = subSecCPU.operateOnFacultyLoading(dbOP, request, 3);
	
	if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = subSecCPU.getErrMsg();
	}

strTemp = WI.fillTextValue("page_action2");
if(strTemp.length() > 0) {
		if(subSecCPU.operateOnAddlLoading(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit2 = "0";
			}
		else
			strErrMsg = subSecCPU.getErrMsg();
	}
	
	if(strPrepareToEdit2.compareTo("1") == 0) {
		vEditInfo2 = subSecCPU.operateOnAddlLoading(dbOP, request, 3);
	
	if(vEditInfo2 == null && strErrMsg == null ) 
			strErrMsg = subSecCPU.getErrMsg();
	}
	
	if (WI.fillTextValue("save_couns").equals("1"))
	{
		if(subSecCPU.operateOnCounselingSched(dbOP, request, 1) != null ) 
			strErrMsg = "Operation successful.";
		else
			strErrMsg = subSecCPU.getErrMsg();
	}
	
if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0 
&& WI.fillTextValue("semester").length()>0 )
{
	vCounsInfo = subSecCPU.operateOnCounselingSched(dbOP, request, 3);
	vRetResult = subSecCPU.operateOnFacultyLoading(dbOP, request, 4);
	if (vRetResult == null && strErrMsg == null)
		strErrMsg = subSecCPU.getErrMsg();


	vRetResult2 = subSecCPU.operateOnAddlLoading(dbOP, request, 4);
	if (vRetResult2 == null && strErrMsg == null)
		strErrMsg = subSecCPU.getErrMsg();
}

%>
<body bgcolor="#D2AE72">
<form name="form_" action="./faculty_loading.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          CLASS PROGRAMS - FACULTY LOADING PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3"> <font size="3"><b><%=WI.getStrValue(strErrMsg,"&nbsp;")%></b></font>
      </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
  		<td width="4%" height="25">&nbsp;</td>
  		<td width="20%">School year/Term:</td>
  		<td colspan="2"> 
  		<%strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");%>
  		<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%strTemp = WI.fillTextValue("sy_to");
        if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp; 
        <%
        strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0 )
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
        %>
        <select name="semester">
          <option value="0">Summer</option>
          <%if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}%>
      </select></td>
        <td width="38%"><a href="javascript:ReloadPage()"><img src="../../../../images/refresh.gif" border="0"></a></td>
  	</tr>
  	<tr>
  		<td height="25">&nbsp;</td>
  		<td>Faculty ID: </td>
  		<td width="32%">
  		<%
  		if (vEditInfo!= null && vEditInfo.size()>0)
	  		strTemp = (String)vEditInfo.elementAt(7);
  		else
	  		strTemp = WI.fillTextValue("fac_id");%>
  		<input name="fac_id" type="text" size="32" maxlength="96" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	    <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" border="0"></a></td>
      <td><input type="image" src="../../../../images/form_proceed.gif"></td>
  	</tr>
	<tr>
		<td colspan="5">&nbsp;</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Stub Code: </td>
		<td colspan="3">
		<%
		if (vEditInfo!= null && vEditInfo.size()>0)
	  		strTemp = (String)vEditInfo.elementAt(1);
  		else
			strTemp = WI.fillTextValue("stub_code");%>
		<input name="stub_code" type="text" class="textbox" value="<%=strTemp%>" size="12" maxlength="12"
	   onKeyUp= 'AllowOnlyInteger("form_","stub_code")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","stub_code");style.backgroundColor="white"'>
		&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
		Load:&nbsp;&nbsp;
		&nbsp;
		<%
		if (vEditInfo!= null && vEditInfo.size()>0)
	  		strTemp = comUtil.formatFloat(((Double)vEditInfo.elementAt(2)).doubleValue(),false);
  		else
			strTemp = WI.fillTextValue("credit_load");%>
		<input name="credit_load" type="text" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
	   onKeyUp= 'AllowOnlyFloat("form_","credit_load")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","credit_load");style.backgroundColor="white"'>
		<font size="1">(units)</font>
		&nbsp;&nbsp;&nbsp;&nbsp;
		&nbsp;
		<%
		if (vEditInfo!= null && vEditInfo.size()>0)
	  		strTemp = comUtil.formatFloat(((Double)vEditInfo.elementAt(3)).doubleValue(),false);
  		else
			strTemp = WI.fillTextValue("credit_load");%>
		<input name="hour_load" type="text" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
	   onKeyUp= 'AllowOnlyFloat("form_","hour_load")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","hour_load");style.backgroundColor="white"'> <font size="1">(hours)</font></td>
	</tr>
	<tr>
		<td height="40">&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="3">
		<%if(strPrepareToEdit.compareTo("0") == 0) {%>
	  <a href='javascript:PageAction("1","");'><img src="../../../../images/save.gif" border="0" name="hide_save"></a>
	  <%}else{%>
	  <a href='javascript:PageAction("2","");'><img src="../../../../images/edit.gif" border="0"></a>
	  
	  <font size="1">click to save entries/changes 
	  <a href="javascript:Cancel();"><img src="../../../../images/cancel.gif" border="0"></a>click to cancel/clear 
        entries </font><%}%></td>
	</tr>
  </table>
	<%if (vRetResult != null && vRetResult.size()>0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr bgcolor="#FFFF9F">
			<td colspan="7" height="25" align="center" class="thinborder"><strong>
			Academic Load for <%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%> 
			<%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong>
			</td>
		</tr>
		<tr>
			<td width="7.5%" align="center" class="thinborder"><font size="1"><strong>STUB CODE</strong></font></td>
			<td width="25%" align="left" class="thinborder">&nbsp;<font size="1"><strong>SUBJECT CODE ::: &nbsp;DESCRIPTION</strong></font></td>
			<td width="10%" align="center" class="thinborder">&nbsp;<font size="1"><strong>UNITS</strong></font></td>
			<td width="10%" align="center" class="thinborder">&nbsp;<font size="1"><strong>HOURS</strong></font></td>
			<td width="27.5%" align="left" class="thinborder">&nbsp;<font size="1"><strong>SCHEDULE</strong></font></td>
			<td width="10%" class="thinborder">&nbsp;</td>
			<td width="10%" class="thinborder">&nbsp;</td>
		</tr>
		<%for (iCtr = 0; iCtr < vRetResult.size(); iCtr+=8){%>
			<tr>
				<td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(iCtr+1)%></font></td>
				<td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(iCtr+4)%> ::: <br><%=(String)vRetResult.elementAt(iCtr+5)%></font></td>
				<td class="thinborder"><font size="1">&nbsp;
				<%=comUtil.formatFloat(((Double)vRetResult.elementAt(iCtr+2)).doubleValue(),false)%> unit(s)</font></td>
				<td class="thinborder"><font size="1">&nbsp;
				<%=comUtil.formatFloat(((Double)vRetResult.elementAt(iCtr+3)).doubleValue(),false)%> hour(s)</font></td>
				<td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(iCtr+6)%></font></td>
				<td class="thinborder"><%if(iAccessLevel > 1){%> <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(iCtr)%>);"><img src="../../../../images/edit.gif" border="0"></a><%}%></td>
				<td class="thinborder"><%if(iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(iCtr)%>");'><img src="../../../../images/delete.gif" border="0"></a><%}%></td>
			</tr>
		<%}%>
	</table>
	<%}%>
	<%if (WI.fillTextValue("fac_id").length()>0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td colspan="3">&nbsp;</td>
		</tr>
		<tr bgcolor="#DDDDDD">
			<td colspan="3" align="center" height="25"><strong>Non Academic Load</strong></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="20%">&nbsp;</td>
			<td width="75%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Load Name: </td>
			<%
			if (vEditInfo2!=null && vEditInfo2.size()>0)
				strTemp = (String)vEditInfo2.elementAt(1);
			else
				strTemp = WI.fillTextValue("load_info");%>
			<td><input name="load_info" type="text" size="64" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Load Description: </td>
			<%
			if (vEditInfo2!=null && vEditInfo2.size()>0)
				strTemp = WI.getStrValue((String)vEditInfo2.elementAt(2),"");
			else
			strTemp = WI.fillTextValue("load_sched");%>
			<td><input name="load_sched" type="text" size="64" maxlength="256" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Non Acad Load</td>
			<td>
			<%
		if (vEditInfo2!= null && vEditInfo2.size()>0)
	  		strTemp = comUtil.formatFloat(((Double)vEditInfo2.elementAt(3)).doubleValue(),false);
  		else
			strTemp = WI.fillTextValue("addl_unit");%>
		<input name="addl_unit" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
	   onKeyUp= 'AllowOnlyFloat("form_","addl_unit")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","addl_unit");style.backgroundColor="white"'>
		<font size="1">(units)</font>
		&nbsp;&nbsp;&nbsp;&nbsp;
		&nbsp;
		<%
		if (vEditInfo2!= null && vEditInfo2.size()>0)
	  		strTemp = comUtil.formatFloat(((Double)vEditInfo2.elementAt(4)).doubleValue(),false);
  		else
			strTemp = WI.fillTextValue("addl_hour");%>
		<input name="addl_hour" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="5"
	   onKeyUp= 'AllowOnlyFloat("form_","addl_hour")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","addl_hour");style.backgroundColor="white"'> 
		<font size="1">(hours)</font></td>
		</tr>
		<tr>
		<td height="40">&nbsp;</td>
		<td>&nbsp;</td>
		<td >
		<%if(strPrepareToEdit2.compareTo("0") == 0) {%>
	  <a href='javascript:PageAction2("1","");'><img src="../../../../images/save.gif" border="0" name="hide_save"></a>
	  <%}else{%>
	  <a href='javascript:PageAction2("2","");'><img src="../../../../images/edit.gif" border="0"></a>
	  
	  <font size="1">click to save entries/changes 
	  <a href="javascript:Cancel2();"><img src="../../../../images/cancel.gif" border="0"></a>click to cancel/clear 
        entries </font><%}%></td>
	</tr>
	</table>
	<%if (vRetResult2!=null && vRetResult2.size()>0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr bgcolor="#FFFF9F">
			<td colspan="7" height="25" align="center" class="thinborder"><strong>
			Non Academic Load for <%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%> 
			<%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong>
			</td>
		</tr>
		<tr>
			<td width="20%" height="25" class="thinborder">&nbsp;<font size="1"><strong>Load Name</strong></font></td>
			<td width="40%" class="thinborder">&nbsp;<font size="1"><strong>Load Description</strong></font></td>
			<td width="10%" class="thinborder">&nbsp;<font size="1"><strong>Load Units</strong></font></td>
			<td width="10%" class="thinborder">&nbsp;<font size="1"><strong>Load Hours</strong></font></td>
			<td width="10%" class="thinborder">&nbsp;</td>
			<td width="10%" class="thinborder">&nbsp;</td>
		</tr>
		<%for (iCtr = 0; iCtr < vRetResult2.size(); iCtr+=5){%>
		<tr>
			<td class="thinborder">&nbsp;<font size="1"><%=(String)vRetResult2.elementAt(iCtr+1)%></font></td>
			<td class="thinborder">&nbsp;<font size="1"><%=WI.getStrValue((String)vRetResult2.elementAt(iCtr+2))%></font></td>
			<td class="thinborder">&nbsp;<font size="1">
			<%=comUtil.formatFloat(((Double) vRetResult2.elementAt(iCtr+3)).doubleValue(),false)%></font></td>
			<td class="thinborder">&nbsp;<font size="1">			
			<%=comUtil.formatFloat(((Double) vRetResult2.elementAt(iCtr+3)).doubleValue(),false)%></font></td>
			<td class="thinborder"><%if(iAccessLevel > 1){%> <a href="javascript:PrepareToEdit2(<%=(String)vRetResult2.elementAt(iCtr)%>);"><img src="../../../../images/edit.gif" border="0"></a><%}%></td>
			<td class="thinborder"><%if(iAccessLevel == 2){%> <a href='javascript:PageAction2("0","<%=(String)vRetResult2.elementAt(iCtr)%>");'><img src="../../../../images/delete.gif" border="0"></a><%}%></td>
		</tr>
		<%}%>
	</table>
	<%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td colspan="3">&nbsp;</td>
		</tr>
		<tr bgcolor="#DDDDDD">
			<td colspan="3" align="center" height="25"><strong>Counselling Schedule</strong></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="20%">&nbsp;</td>
			<td width="75%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Study Load: </td>
			<%
			if (vCounsInfo != null && vCounsInfo.size()>0)
			strTemp = comUtil.formatFloat(((Double) vCounsInfo.elementAt(5)).doubleValue(),false);
			strTemp = WI.fillTextValue("study_load");%>
			<td><input name="study_load" type="text" class="textbox" value="<%=strTemp%>" size="5" maxlength="10"
	   onKeyUp= 'AllowOnlyFloat("form_","study_load")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","study_load");style.backgroundColor="white"'>	
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Counseling time: </td>
			<%
			if (vCounsInfo!= null && vCounsInfo.size()>0)
				strTemp = WI.getStrValue((String)vCounsInfo.elementAt(6),"");
			else
				strTemp = WI.fillTextValue("couns_time");%>
			<td><input name="couns_time" type="text" size="64" maxlength="256" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Degree: </td>
			<%
			if (vCounsInfo != null && vCounsInfo.size()>0)
				strTemp = WI.getStrValue((String)vCounsInfo.elementAt(7),"");
			else
				strTemp = WI.fillTextValue("degree");%>
			<td><input name="degree" type="text" size="64" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>School Name: </td>
			<%
			if (vCounsInfo != null && vCounsInfo.size()>0)
				strTemp = WI.getStrValue((String)vCounsInfo.elementAt(8),"");
			else
				strTemp = WI.fillTextValue("school_name");%>
			<td><input name="school_name" type="text" size="64" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		
			</td>
		</tr>
		<tr>
		<td height="40">&nbsp;</td>
		<td>&nbsp;</td>
		<td><a href='javascript:ModifyCounsInfo();'>
	  <%if(vCounsInfo == null) {%><img src="../../../../images/save.gif" border="0" name="hide_save">
	  <%}else{%><img src="../../../../images/edit.gif" border="0"><%}%></a></td>
	</tr>
	</table>
	<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>

	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
    <input type="hidden" name="page_action">

<!-duplicate stuff for non-acad->
	<input name = "info_index2" type = "hidden"  value="<%=WI.fillTextValue("info_index2")%>">
    <input type="hidden" name="prepareToEdit2" value="<%=strPrepareToEdit2%>">
    <input type="hidden" name="page_action2">
    
<!--for saving counseling data-->
	<input type="hidden" name="save_couns">

</form>
</body>
</html>

<%
dbOP.cleanUP();
%>
