<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_page.value="";
	document.form_.action="./summarized_rating.jsp";
	document.form_.submit();
}

function PrintPg()
{
	document.form_.print_page.value="1";
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData" %>
<%
 
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);
	if (WI.fillTextValue("print_page").length()>0){
		if (WI.fillTextValue("course_index").length() !=0 ){
			if (WI.fillTextValue("degree_type").compareTo("4") == 0 ){
				
%>
				<jsp:forward page="./summarized_rating_print_cg.jsp" />
		<%}else{%>
				<jsp:forward page="./summarized_rating_print.jsp" />
		
		<%}
			return; 
		}else{
			strErrMsg = "Please select course";
		}
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-TESDA Reports","summarized_rating.jsp");
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
														"summarized_rating.jsp");	
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
String strDegreeType = "";
	if (WI.fillTextValue("course_index").length() > 0){
		 strDegreeType = dbOP.mapOneToOther("course_offered","is_del", "0", "degree_type", 
		" and course_index = " + WI.fillTextValue("course_index"));
	}
	
String[] astrYearLevel={"","First Year", "Second Year", "Third Year", "Fourth Year", "Fifth Year"};
%>
<form action="" method="post" name="form_">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::TESDA 
          SUMMARIZED RATING REPORT ::::</strong></font></div></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="3" bgcolor="#FFFFFF">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">COURSE</td>
      <td colspan="3"><select name="course_index" onChange="ReloadPage();">
          <option value="">Select Course</option>
          <%=dbOP.loadCombo("course_index","COURSE_NAME"," from course_offered where is_del=0 and (degree_type<>1 and degree_type<>2 and degree_type <> 3) and course_name not like 'bachelor%' order by course_name" , WI.fillTextValue("course_index"),false)%> </select></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">SCHOOL YEAR</td>
      <td colspan="3"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
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
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
<% if (strDegreeType.compareTo("4") != 0  && WI.fillTextValue("course_index").length() != 0) {

	int iMaxYearLevel = new EntranceNGraduationData().getMaxYearLevel(dbOP,WI.fillTextValue("course_index"));
%>
    <tr >
      <td height="24">&nbsp;</td>
      <td height="24">YEAR LEVEL</td>
      <td colspan="3"> 
        <select name="year_level">
				<% for(int i = 1; i <=iMaxYearLevel; i++) {
					if (WI.fillTextValue("year_level").equals(Integer.toString(i))) {
				%>
					<option value="<%=i%>" selected><%=astrYearLevel[i]%></option>
				<%}else{%>
					<option value="<%=i%>"><%=astrYearLevel[i]%></option>				
				<%} 
				} // end for loop%>
				</select>
	  </td>
    </tr>
<%}%>
    <tr > 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="24">&nbsp;</td>
      <td height="24">Prepared by: </td>
      <td width="37%"><input name="prepared" type="text" class="textbox" id="prepared"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("prepared")%>" size="30"></td>
      <td width="12%">Designation: </td>
      <td width="31%"><input name="designation" type="text" class="textbox" id="designation"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("designation")%>"></td>
    </tr>
    <% if (strDegreeType.compareTo("4") !=0) {%>
    <tr > 
      <td height="24">&nbsp;</td>
      <td height="24">Certified Correct by: </td>
      <td><input name="certified" type="text" class="textbox" id="certified"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("certified")%>" size="30"></td>
      <td>Designation: </td>
      <td><input name="designation1" type="text" class="textbox" id="designation1"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("designation1")%>"></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="24">Attested by:</td>
      <td><input name="attested" type="text" class="textbox" id="attested"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("attested")%>" size="30"></td>
      <td>Designation: </td>
      <td><input name="designation2" type="text" class="textbox" id="designation2"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("designation2")%>"></td>
    </tr>
    <%}else{%>
    <tr > 
      <td height="24">&nbsp;</td>
      <td height="24">Noted by: </td>
      <td><input name="noted" type="text" class="textbox" id="noted"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("noted")%>" size="30"></td>
      <td>Designation: </td>
      <td><input name="designation3" type="text" class="textbox" id="designation3"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("designation3")%>"></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="24">Certified Correct by:</td>
      <td><input name="certified" type="text" class="textbox" id="certified"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("certified")%>" size="30"></td>
      <td>Designation: </td>
      <td><input name="designation4" type="text" class="textbox" id="designation4"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("designation4")%>"></td>
    </tr>
    <%}%>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print report</font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
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
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>