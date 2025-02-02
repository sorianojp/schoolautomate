<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>ADMISSION REQUIREMENTS</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function CopyAll()
{
	document.course_requirement.copy_all.value = 1;
}

</script>
<body bgcolor="#D2AE72">
<form action="./copy_requirement.jsp" method="post" name="course_requirement">
<%@ page language="java" import="utility.*,enrollment.CourseRequirement,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar-admission requirement","copy_requirement.jsp");
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
														"Registrar Management","ADMISSION REQUIREMENTS",request.getRemoteAddr(),
														"copy_requirement.jsp");
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
CourseRequirement cRequirement = new CourseRequirement();
if(WI.fillTextValue("copy_all").length() > 0) {
	if(cRequirement.copyRequirement(dbOP,(String)request.getSession(false).getAttribute("userId"),
									WI.fillTextValue("sy_from"),WI.fillTextValue("sy_from_new"))  )
		strErrMsg = "Copy requirement is successful";
	else	
		strErrMsg = cRequirement.getErrMsg();
}
Vector vSYInfo = cRequirement.getSchoolYearToCopyFrom(dbOP);
if(vSYInfo == null)
	strErrMsg = cRequirement.getErrMsg();

dbOP.cleanUP();
//end of authenticaion code.
%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:: 
        ADMISSION REQUIREMENTS ::</strong></font></td>
    </tr>
    <tr> 
      <td width="7%" height="25">&nbsp;&nbsp;&nbsp; <strong></strong></td>
      <td width="93%"><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" width="7%">&nbsp;</td>
      <td width="39%">Copy from school Year</td>
      <td width="54%">New School Year</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> <select name="sy_from">
         <%
		 strTemp = WI.fillTextValue("sy_from");
		 
		 for(int i=0; i< vSYInfo.size(); i+= 2){
		 if(strTemp.compareTo( (String)vSYInfo.elementAt(i)) ==0){%>
		 <option value="<%=(String)vSYInfo.elementAt(i)%>" selected><%=(String)vSYInfo.elementAt(i+1)%></option>
		 <%}else{%>
		 <option value="<%=(String)vSYInfo.elementAt(i)%>"><%=(String)vSYInfo.elementAt(i+1)%></option>
		 <%}
		 
		}%>
		 
        </select></td>
      <td><input type="text" name="sy_from_new" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from_new")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("course_requirement","sy_from_new","sy_to_new")'>
        to 
        <input type="text" name="sy_to_new" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to_new")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> 
      </td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" width="7%">&nbsp;</td>
      <td width="93%">&nbsp;
	  <%if(iAccessLevel > 1){%>
	  <input type="image" src="../../../images/copy_all.gif" onClick="CopyAll();">
        click to copy the admission requirements 
        <%}else{%>
        Not authorized to copy requirements 
        <%}%></td>
    </tr>

  </table>



<table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td height="25">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="copy_all">
</form>
</body>
</html>
