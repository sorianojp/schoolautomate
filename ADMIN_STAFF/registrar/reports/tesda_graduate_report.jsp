<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_page.value="";
	document.form_.action="./tesda_graduate_report.jsp";
	document.form_.submit();
}

function PrintPg()
{
	
	if (document.form_.prepared.value.length == 0 || 
	    document.form_.certified.value.length == 0 || 
		document.form_.attested.value.length == 0){
	
		alert(" All names are required.");
		document.form_.prepared.focus();
	}else{
		document.form_.print_page.value="1";
		document.form_.submit();
	}
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*" %>
<%
 
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);
	
	//if lent. == set err.else forward.
	
	if (WI.fillTextValue("print_page").length()>0){
		if (WI.fillTextValue("course_index").length() !=0 ){
			if (WI.fillTextValue("certified").length() == 0 || WI.fillTextValue("attested").length() == 0){
				strErrMsg = " Please encode all names";
			}else{
				if (WI.fillTextValue("terminal").length() > 0){%>
				<jsp:forward page="./tesda_terminal_report_print.jsp" />				
				<%}else if (WI.fillTextValue("cg_enrolment").length()> 0){%>
				<jsp:forward page="./caregiver_enrolment_print.jsp" />
				<%}else{%>
				<jsp:forward page="./tesda_graduate_report_print.jsp" />				
			<%}
			return; 
			}
		}else{
			strErrMsg = "Please select course";
		}
	}

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
<form action="" method="post" name="form_">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::TESDA 
          REPORT ::::</strong></font></div></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="3" bgcolor="#FFFFFF">
    <tr > 
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
    <tr > 
      <td width="1%" height="25">&nbsp;</td>
      <td width="19%">COURSE</td>
      <td width="80%" colspan="3"><select name="course_index">
          <option value="">Select Course</option>
          <%=dbOP.loadCombo("course_index","COURSE_NAME"," from course_offered where is_del=0 and degree_type<> 1 and degree_type<>2 and course_name not like 'bachelor%' order by course_name" , WI.fillTextValue("course_index"),true)%> 
		 </select>
	  </td>
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
strTemp = WI.fillTextValue("yr_grad");
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
    <tr > 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="3" bgcolor="#FFFFFF">
    <tr > 
      <td height="24"><font size="1">Program/Course Certification N. (UTPRAS) 
        :</font></td>
      <td width="65%" height="24"><input name="utpras" type="text" class="textbox" id="utpras"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("utpras")%>" size="30"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="3" bgcolor="#FFFFFF">
    <tr >
      <td height="24" colspan="3"><font size="1">Date of Issue: </font></td>
      <td height="24"><input name="doi" type="text" class="textbox" id="doi" readonly="yes"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("doi")%>" size="12"> 
        <a href="javascript:show_calendar('form_.doi');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
<% if (WI.fillTextValue("terminal").length() > 0){%>
    <tr > 
      <td height="24" colspan="3"><font size="1">Municipality / Province</font></td>
      <td width="80%" height="24"><input name="mun_prov" type="text" class="textbox" id="mun_prov"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("mun_prov")%>" size="30"></td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="3" bgcolor="#FFFFFF">
    <tr > 
      <td height="24"><font size="1">Prepared by: </font></td>
      <td><input name="prepared" type="text" class="textbox" id="prepared"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("prepared")%>" size="30"></td>
      <td><font size="1">Designation:</font></td>
      <td><input name="designation3" type="text" class="textbox" id="designation3"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("designation1")%>"></td>
    </tr>
    <tr > 
      <td height="24"><font size="1">Certified Correct by: </font></td>
      <td width="37%"><input name="certified" type="text" class="textbox" id="certified"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("certified")%>" size="30"></td>
      <td width="12%"><font size="1">Designation: </font></td>
      <td width="31%"><input name="designation1" type="text" class="textbox" id="designation1"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("designation1")%>"></td>
    </tr>
    <tr > 
      <td height="24"><font size="1">Attested by:</font></td>
      <td><input name="attested" type="text" class="textbox" id="attested"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("attested")%>" size="30"></td>
      <td><font size="1">Designation: </font></td>
      <td><input name="designation2" type="text" class="textbox" id="designation2"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("designation2")%>"></td>
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
<input type="hidden" name="sort_by1" value="lname">
<input type="hidden" name="sort_by2" value="fname">
<input type="hidden" name="sort_by1_con" value="asc">
<input type="hidden" name="sort_by2_con" value="asc">
<input name="cg_enrolment" type="hidden" value="<%=WI.fillTextValue("cg_enrolment")%>">
<input name="terminal" type="hidden" value="<%=WI.fillTextValue("terminal")%>">

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>