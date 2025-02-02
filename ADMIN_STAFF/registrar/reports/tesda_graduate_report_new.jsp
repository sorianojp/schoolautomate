<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsDBTC = strSchCode.startsWith("DBTC");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{

	if(document.form_.course_index.value.length == 0 
		|| document.form_.sy_from.value.length == 0 
		|| document.form_.semester.value.length == 0 ){
		alert("Please provide course and graduation data");
		return;	
	}
	
	if (document.form_.prepared_by.value.length == 0 || 
	    document.form_.certified.value.length == 0  
		<%if(bolIsDBTC){%> || document.form_.reviewed_by.value.length == 0<%}%>	){
	
	
		alert(" All names are required.");
		document.form_.prepared_by.focus();
	}else{
		document.form_.print_page.value="1";
		document.form_.submit();
	}
}


function CharExemption(objInput, strExempChar) {
	
	var strIntVal = objInput.value;
	if(strIntVal.length == 0)
		return;
		
	var newIntVal = "";
	var lastChar;
	var lastOccurance = 0;	
	for(i = 0; i < strIntVal.length; ++i) {
		lastChar = strIntVal.charAt(i);
		if(strExempChar.indexOf(lastChar) > -1)
			continue;
			
		newIntVal += lastChar;
	}
	strIntVal = newIntVal;
	objInput.value= strIntVal;
}



</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*" %>
<%
 
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);
	
	String strIsEnrollment = WI.getStrValue(WI.fillTextValue("is_enrollment"),"0");
	
	strTemp = "sy_from="+WI.fillTextValue("sy_from")+
		"&sy_to="+WI.fillTextValue("sy_to")+
		"&semester="+WI.fillTextValue("semester")+
		"&course_index="+WI.fillTextValue("course_index")+
		"&prepared_by="+WI.fillTextValue("prepared_by")+
		"&certified="+WI.fillTextValue("certified")+
		"&is_enrollment="+strIsEnrollment+
		"&designation1="+WI.fillTextValue("designation1")+
		"&designation2="+WI.fillTextValue("designation2");
	if(bolIsDBTC)
		strTemp += "&reviewed_by="+WI.fillTextValue("reviewed_by")+
			"&designation3="+WI.fillTextValue("designation3");
	if(WI.fillTextValue("print_page").length() > 0){		
			response.sendRedirect("terminal_report_print_page1.jsp?"+strTemp);		
	return;}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-TESDA Reports","tesda_graduate_report.jsp");
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
														"tesda_graduate_report.jsp");	
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
	

%>
<form action="tesda_graduate_report_new.jsp" method="post" name="form_">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::TESDA 
          REPORT ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="3%" height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
    <tr > 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">COURSE</td>
      <td width="80%" colspan="3"><select name="course_index">
          <option value="">Select Course</option>
          <%=dbOP.loadCombo("course_index","COURSE_NAME"," from course_offered where is_del=0 and degree_type<> 1 and degree_type<>2 and course_name not like 'bachelor%' order by course_name" , WI.fillTextValue("course_index"),true)%> 
		 </select>	  </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">YEAR GRADUATED</td>
      <td colspan="3"> 
	  <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> 
<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        Term : 
        <select name="semester" id="semester">
          <%=CommonUtil.constructTermList(dbOP, request, WI.fillTextValue("semester"))%>
        </select></td>
    </tr>
    <tr > 
      <td height="24" colspan="2">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr > 
      <td height="24"><font size="1">Prepared By: </font></td>
      <td width="37%">
	  <input name="prepared_by" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeyUp="CharExemption(document.form_.prepared_by, '\'');"
	  value="<%=WI.fillTextValue("prepared_by")%>" size="30"></td>
      <td width="12%"><font size="1">Designation: </font></td>
      <td width="31%">
	  <input name="designation1" type="text" class="textbox"  onKeyUp="CharExemption(document.form_.designation1, '\'');"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("designation1")%>"></td>
    </tr>
	
	<%if(bolIsDBTC){%>
	<tr > 
      <td height="24"><font size="1">Reviewed By: </font></td>
      <td width="37%">
	  <input name="reviewed_by" type="text" class="textbox"  onKeyUp="CharExemption(document.form_.reviewed_by, '\'');"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("reviewed_by")%>" size="30"></td>
      <td width="12%"><font size="1">Designation: </font></td>
      <td width="31%">
	  <input name="designation3" type="text" class="textbox"  onKeyUp="CharExemption(document.form_.designation3, '\'');"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("designation3")%>"></td>
    </tr>
	<%}%>
    <tr > 
      <td height="24"><font size="1">Certified True and Correct</font></td>
      <td>
	  <input name="certified" type="text" class="textbox" onKeyUp="CharExemption(document.form_.certified, '\'');"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("certified")%>" size="30"></td>
      <td><font size="1">Designation: </font></td>
      <td>
	  <input name="designation2" type="text" class="textbox" onKeyUp="CharExemption(document.form_.designation2, '\'');"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("designation2")%>"></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print report</font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="print_page">
<input type="hidden" name="is_enrollment" value="<%=strIsEnrollment%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>