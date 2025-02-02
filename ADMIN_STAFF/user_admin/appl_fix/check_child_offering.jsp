<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.fix_floating_ra.value = "";
	document.form_.page_action.value = "";
	this.SubmitOnce("form_");
}
function RemoveSection(strInfoIndex) {
	document.form_.fix_floating_ra.value = "";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = 0;
	this.SubmitOnce("form_");
}
function RemoveFloatingRA() {
	document.form_.fix_floating_ra.value = "1";
	document.form_.page_action.value = 0;
	this.SubmitOnce("form_");
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Application Fix","check_child_offering.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														"check_child_offering.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
AllProgramFix apf = new AllProgramFix();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0) {
	vRetResult = apf.operateOnCPChildOfferingErr(dbOP, request, Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_action"), "4")));
	strErrMsg = apf.getErrMsg();//message set for successful removal.
}
%>


<form name="form_" action="./check_child_offering.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CHECK CLASSPROGRAM OFFERING ERROR ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="14%" height="25">SY / TERM</td>
      <td width="28%"> <%
if(WI.fillTextValue("sy_from").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else
	strTemp = WI.fillTextValue("sy_from");
%> <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="4" maxlength="4"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
        <%
if(WI.fillTextValue("sy_to").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
else
	strTemp = WI.fillTextValue("sy_to");
%> <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="4" maxlength="4" readonly> 
        &nbsp;&nbsp; <select name="semester">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="55%"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="20" colspan="4"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
 <%
 boolean bolIsPrinted = false;
 if (vRetResult!= null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="26" colspan="5" class="thinborder"><div align="center"><strong>LIST 
          OF SECTIONS HAVING SUB-OFFERING BUT NOT HAVING MAIN OFFERING</strong></div></td>
    </tr>
    <tr> 
      <td width="15%" height="27" class="thinborder"><div align="center"><strong>SUBJECT 
          CODE</strong></div></td>
      <td width="42%" class="thinborder"><div align="center"><strong>SUBJECT NAME</strong></div></td>
      <td width="30%" class="thinborder"><div align="center"><strong>SECTION </strong></div></td>
      <td width="6%" class="thinborder"><font size="1"><strong>NO OF ENROLLEE</strong></font></td>
      <td width="7%" class="thinborder"><div align="center"><strong>FIX</strong></div></td>
    </tr>
    <%
 while(vRetResult.size() > 0){
 	if( ((String)vRetResult.elementAt(0)).compareTo("1") != 0)
		break;
	bolIsPrinted = true;
	%>
    <tr> 
      <td height="25"  class="thinborder"><%=(String)vRetResult.elementAt(2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(4)%></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(5)%></div></td>
      <td class="thinborder"><a href="javascript:RemoveSection(<%=(String)vRetResult.elementAt(1)%>)"> 
        <img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%
	vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
	vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
	}//end of printing errors.
	if(!bolIsPrinted){%>
    <tr bgcolor="#77ccFF"> 
      <td height="25" colspan="5"  class="thinborder">&nbsp;&nbsp;<b>*************** 
        No Error found *************** </b></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr><td width="25">&nbsp;</td></tr>
  </table>
  
    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="26" colspan="5" class="thinborder"><div align="center"><strong>LIST 
          OF SECTIONS HAVING TWO MAIN OFFERING (ONE MUST BE REMOVED)</strong></div></td>
    </tr>
    <tr> 
      <td width="15%" height="27" class="thinborder"><div align="center"><strong>SUBJECT 
          CODE</strong></div></td>
      <td width="42%" class="thinborder"><div align="center"><strong>SUBJECT NAME</strong></div></td>
      <td width="30%" class="thinborder"><div align="center"><strong>SECTION </strong></div></td>
      <td width="6%" class="thinborder"><font size="1"><strong>NO OF ENROLLEE</strong></font></td>
      <td width="7%" class="thinborder"><div align="center"><strong>FIX</strong></div></td>
    </tr>
    <%bolIsPrinted = false;
 while(vRetResult.size() > 0){
	if( ((String)vRetResult.elementAt(0)).compareTo("0") != 0)
		break;
	bolIsPrinted = true;
	%>
    <tr> 
      <td height="25"  class="thinborder"><%=(String)vRetResult.elementAt(2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(4)%></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(5)%></div></td>
      <td class="thinborder"><a href="javascript:RemoveSection(<%=(String)vRetResult.elementAt(1)%>)"> 
        <img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%
	vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
	vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
	}//end of printing errors.
	if(!bolIsPrinted){%>
    <tr bgcolor="#77ccFF"> 
      <td height="25" colspan="5"  class="thinborder">&nbsp;&nbsp;<b>*************** 
        No Error found *************** </b></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr><td width="25">&nbsp;</td></tr>
  </table>
  
    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="26" colspan="5" class="thinborder"><div align="center"><strong>LIST 
          OF SECTIONS HAVING LAB OFFERING ONLY - IT SHOULD HAVE A LEC OFFERING 
          OR SHOULD BE REMOVED</strong></div></td>
    </tr>
    <tr> 
      <td width="15%" height="27" class="thinborder"><div align="center"><strong>SUBJECT 
          CODE</strong></div></td>
      <td width="42%" class="thinborder"><div align="center"><strong>SUBJECT NAME</strong></div></td>
      <td width="30%" class="thinborder"><div align="center"><strong>SECTION </strong></div></td>
      <td width="6%" class="thinborder"><font size="1"><strong>NO OF ENROLLEE</strong></font></td>
      <td width="7%" class="thinborder"><div align="center"><strong>FIX</strong></div></td>
    </tr>
    <%bolIsPrinted = false;
 while(vRetResult.size() > 0){
	if( ((String)vRetResult.elementAt(0)).compareTo("3") != 0)
		break;
	bolIsPrinted = true;
	%>
    <tr> 
      <td height="25"  class="thinborder"><%=(String)vRetResult.elementAt(2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(4)%></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(5)%></div></td>
      <td class="thinborder"><a href="javascript:RemoveSection(<%=(String)vRetResult.elementAt(1)%>)"> 
        <img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%
	vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
	vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
	}//end of printing errors.
	if(!bolIsPrinted){%>
    <tr bgcolor="#77ccFF"> 
      <td height="25" colspan="5"  class="thinborder">&nbsp;&nbsp;<b>*************** 
        No Error found *************** </b></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr><td width="25">&nbsp;</td></tr>
  </table>
  
    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="26" colspan="2" class="thinborder"><div align="center"><strong>NUMBER 
          OF FLOATING ROOM ASSIGNMENT (CLASS PROGRAM REFERENCE IS LOST)</strong></div></td>
    </tr>
    <tr> 
      <td width="93%" height="27" class="thinborder">&nbsp;</td>
      <td width="7%" class="thinborder"><div align="center"><strong>FIX</strong></div></td>
    </tr>
 <%bolIsPrinted = false;
 if(vRetResult.size() > 0 && ((String)vRetResult.elementAt(0)).compareTo("4") == 0){
	bolIsPrinted = true;
	%>
    <tr> 
      <td height="25"  class="thinborder"><%=(String)vRetResult.elementAt(1)%></td>
      <td class="thinborder"><a href="javascript:RemoveFloatingRA();"><img src="../../../images/delete.gif" width="60" height="26" border="0"></a></td>
    </tr>
     <%}if(!bolIsPrinted){%>
	<tr bgcolor="#77ccFF"> 
      <td height="25" colspan="4"  class="thinborder">&nbsp;&nbsp;<b>*************** No Error found *************** </b></td>
    </tr>
    <%}%>
 </table>
 <%} // vRetResult%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25"bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="info_index">
 <input type="hidden" name="page_action">
 <input type="hidden" name="fix_floating_ra">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
