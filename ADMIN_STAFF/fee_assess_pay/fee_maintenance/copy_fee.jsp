<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function CopyAll()
{
	document.form_.copy_all.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.save_text.value = "Copying Records. Please wait...";
	this.SubmitOnce("form_");
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceCopyFee"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-Copy Fee","copy_fee.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"copy_fee.jsp");
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

FAFeeMaintenanceCopyFee FACopyFee = new FAFeeMaintenanceCopyFee();
if(WI.fillTextValue("copy_all").compareTo("1") == 0) {
	int iRowUpdated = FACopyFee.copyFee(dbOP, request);
	if(iRowUpdated == -1)
		strErrMsg = "Message : "+FACopyFee.getErrMsg();
	else 
		strErrMsg = "Message : Copy successful. Total Record Copied : "+iRowUpdated;
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>


<form name="form_" action="./copy_fee.jsp" method="post">

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          COPY RECORD ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<!--    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-weight:bold; font-size:11px; color:#0000FF">
<%
strTemp = WI.fillTextValue("is_basic");
if(strTemp.equals("1"))
	strTemp = " checked";
else		
	strTemp = "";
%>	  
	 	<input type="checkbox" name="is_basic" value="1"<%=strTemp%>> Copy Only Grade School  </td>
    </tr>-->
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="24%">School year (previous)</td>
      <td width="73%"> <%
strTemp = WI.fillTextValue("sy_from_prev");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from_prev" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from_prev","sy_to_prev")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to_prev");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to_prev" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">&nbsp;&nbsp; <select name="sem_from">
		 <option value="">N/A</option>
		 <% strTemp = WI.fillTextValue("sem_from");
		   if (strTemp.compareTo("0") == 0){%>
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
        </select> &nbsp;&nbsp; </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="24%">New School year</td>
      <td width="73%"> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp; 
        <select name="sem_to">
	  	 <option value=""> N/A</option>
		  <% strTemp = WI.fillTextValue("sem_to"); 
	  	  	if (strTemp.compareTo("0") == 0) {%>
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
        </select>      </td>
    </tr>
<%
if(WI.fillTextValue("operation").compareTo("4") != 0 && WI.fillTextValue("operation").compareTo("5") != 0
	 && WI.fillTextValue("operation").compareTo("6") != 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td> <select name="course_index">
          <option value="">All Course</option>
<%if(strSchCode.startsWith("CIT")){
if(WI.fillTextValue("course_index").equals("0"))
	strTemp = " selected";
else	
	strTemp = "";
%>
		  <option value="0"<%=strTemp%>>Copy BASIC</option>
<%}%>
          <%=dbOP.loadCombo("course_index","course_name",
		  " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", WI.fillTextValue("course_index"), false)%> </select> </td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href='javascript:CopyAll();'><img src="../../../images/copy_all.gif" border="0" name="hide_save"></a>
	  <input type="text" name="save_text" value="copy selected record to new school year." size="50"
	  style="font-size:11px;border: 0;font-family:Verdana, Arial, Helvetica, sans-serif;"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="copy_all" value="0">
<input type="hidden" name="operation" value="<%=WI.fillTextValue("operation")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
