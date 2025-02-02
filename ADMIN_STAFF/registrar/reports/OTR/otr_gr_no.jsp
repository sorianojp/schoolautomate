<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if(strSchCode == null) {%>
		<p style="font-size:14px; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif;"> Failed to proceed. You are already logged out. Please login again.</p>

<%return;}%>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	
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

	//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"otr_gr_no.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

String strCourseName = null;
String strCourseIndex = WI.fillTextValue("course_index");

Vector vEditInfo = null;
Vector vRetResult = null;
enrollment.ReportRegistrar repReg = new enrollment.ReportRegistrar();

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(repReg.operateOnOTRGRNo(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = repReg.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Entry Successfully Deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Entry Successfully Saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Entry Successfully Updated.";
		strPrepareToEdit = "0";
	}
}


vRetResult = repReg.operateOnOTRGRNo(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = repReg.getErrMsg();

/**
if(strCourseIndex.length() > 0){
	strTemp = "select course_name from course_offered where course_index = "+strCourseIndex;	
	strCourseName = dbOP.getResultOfAQuery(strTemp, 0);
	if(strCourseName == null || strCourseName.length() == 0) 
		strErrMsg = "Student course information not found.";	
}
**/

if(strPrepareToEdit.equals("1")){
	vEditInfo = repReg.operateOnOTRGRNo(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = repReg.getErrMsg();
}


%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transcript of Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript" src ="../../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
	function CloseWindow(){	
		window.opener.document.form_.submit();
		window.opener.focus();
		self.close();
	}
	
	function PageAction(strAction, strInfoIndex){
		if(strAction == "0"){
			if(!confirm("Do you want to delete this entry? "))
				return;
		}
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		document.form_.page_action.value = strAction;
		
		document.form_.submit();
		
	}
	
	function RefreshPage(){
		document.form_.recognition_no.value = "";
		document.form_.date_issued.value = "";
		document.form_.page_action.value = "";
		document.form_.info_index.value = "";
		document.form_.prepareToEdit = "0";
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex){		
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
</script>
<body bgcolor="#D2AE72">
<form action="./otr_gr_no.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor="#A49A6A">
		<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: CHED RECOGNITION NO ::::</strong></font></div></td>
	</tr>
	<tr>
		<td height="25" bgcolor="#FFFFFF" width="80%"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
		<td height="25" align="right" bgcolor="#FFFFFF"><a href="javascript:CloseWindow();"><img src="../../../../images/close_window.gif" border="0"></a></td>
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td width="3%"></td><td colspan="3" height="25">
		COURSE : 
		<select name="course_index" onChange="RefreshPage();" style="width:500px; font-size:11px;">
			<%=dbOP.loadCombo("course_index", "course_code, course_name", " from course_offered where is_valid = 1 and is_offered = 1 order by course_code", WI.fillTextValue("course_index"), false)%>		
		</select>
		</strong></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td width="17%">RECOGNITION NO</td>
		<%
		strTemp = WI.fillTextValue("recognition_no");
		if(vEditInfo != null  && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		%>
		<td><input name="recognition_no" type="text" class="textbox"  
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=strTemp%>"></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td width="17%">DATE ISSUED</td>
		<%
		strTemp = WI.fillTextValue("date_issued");
		if(strTemp.length() ==0)
			strTemp = WI.getTodaysDate(1);
			
		if(vEditInfo != null  && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);	
		
		%>
		<td><input name="date_issued" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_issued');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" 
			onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td>
			<%if(strPrepareToEdit.equals("0")){%>
			<a href="javascript:PageAction('1','');"><img src="../../../../images/save.gif" border="0"></a>
			<font size="1">Click to save entry</font>
			<%}else{%>
			<a href="javascript:PageAction('2','');"><img src="../../../../images/edit.gif" border="0"></a>
			<font size="1">Click to update entry</font>
			<%}%>
			<a href="javascript:RefreshPage();"><img src="../../../../images/cancel.gif" border="0"></a>
			<font size="1">Click to refresh page</font>
		</td>
	</tr>
	<tr><td colspan="3" height="10"></td></tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td height="25" class="thinborder" width="50%"><strong>RECOGNITION NO</strong></td>
		<td height="25" class="thinborder" width="30%"><strong>DATE ISSUED</strong></td>
		<td height="25" class="thinborder"><strong>OPTION</strong></td>
	</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 3){%>
	<tr>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder">
			<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../../images/edit.gif" border="0"></a>
			&nbsp; &nbsp;
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../../images/delete.gif" border="0"></a>
		</td>
	</tr>
	<%}%>
</table>

<%}%>

<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" >
	<input type="hidden" name="page_action" value="" >
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>" >
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
