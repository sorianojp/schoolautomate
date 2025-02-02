

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	this.SubmitOnce("form_");
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.fac_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<%@ page language="java" import="utility.*, enrollment.SubjectSectionCPU, java.util.Vector"%>
<%

	DBOperation dbOP = null;

	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	int iCtr = 0;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CLASS PROGRAMS","fac_load_report.jsp");
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
														"Enrollment","CLASS PROGRAMS",request.getRemoteAddr(),
														"fac_load_report.jsp");
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

Vector vRetResult = new Vector();
SubjectSectionCPU subSecCPU = new SubjectSectionCPU();

if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0 && WI.fillTextValue("semester").length()>0)
{%>
	<jsp:forward page="./fac_load_print.jsp" />
	<%
}	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./fac_load_report.jsp" method="post">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>FACULTY LOADING REPORT </strong></font></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr> 
      <td height="25"></td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="20%">Print Entries in:</td>
      <td colspan="2">
      <%strTemp = WI.fillTextValue("underG");
      if (strTemp.equals("1"))
      	strTemp2 = "checked";
   	  else
      	strTemp2 = "";%>
      <input type="checkbox" name="underG" value="1" <%=strTemp2%>> Undergraduate 
      <%strTemp = WI.fillTextValue("postG");
      if (strTemp.equals("1"))
      	strTemp2 = "checked";
   	  else
      	strTemp2 = "";%>
      <input type="checkbox" name="postG" value="1" <%=strTemp2%>> Post Graduate 
      <%strTemp = WI.fillTextValue("med");
      if (strTemp.equals("1"))
      	strTemp2 = "checked";
   	  else
      	strTemp2 = "";%>
      <input type="checkbox" name="med" value="1" <%=strTemp2%>> Medicine      </td>
    </tr>
    <tr> 
      <td height="25" width="2%"></td>
      <td>School year/ Term</td>
      <td colspan="2"><%strTemp = WI.fillTextValue("sy_from");
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
        </select> 	
	   &nbsp;<input type="image" src="../../../../images/form_proceed.gif">      </td>
    </tr>
    <tr>
    	<td height="25">&nbsp;</td>
    	<td>Faculty ID: </td>
    	<td width="34%">
    	<%strTemp = WI.fillTextValue("fac_id");%>
    	<input name="fac_id" type="text" size="32" maxlength="96" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
        <td width="44%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
