<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../jscript/td.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(document.form_.emp_id.value.length ==0) {
		if(strAction != '0' && strAction != '3') {
			alert("Please enter Member ID.");
			return;
		}
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>
<body bgcolor="#DEC9CC">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"lms-Administration-PATRON MANAGEMENT","outside_patron.jsp");
	}
	catch(Exception exp) {
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
														"LIB_Administration","PATRON MANAGEMENT",request.getRemoteAddr(),
														"outside_patron.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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
Vector vEditInfo  = null; boolean bolClean = false;
lms.MgmtPatron mgmtPatron = new lms.MgmtPatron();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	vEditInfo = mgmtPatron.operateOnOutsideMember(dbOP, request, Integer.parseInt(strTemp));
	if(vEditInfo != null) {
		strErrMsg = "Request processed successfully.";
		if(vEditInfo.size() == 0) 
			vEditInfo = null;
	}
	else {	
		strErrMsg = mgmtPatron.getErrMsg();
		if(strTemp.equals("6"))
			bolClean = true;
	}
}
Vector vRetResult = mgmtPatron.operateOnOutsideMember(dbOP, request, 4);
%>

<form action="./outside_patron.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A8A8D5">
      <td height="25" colspan="5" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>::::
          OUTSIDE MEMBER MANAGEMENT ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="32%">Patron ID<font size="1">&nbsp;(Outside Member ID)</font></td>
      <td width="21%">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("emp_id");
%>
	  <input type="text" name="emp_id" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="45%"><input type="button" onClick="PageAction('6','')" value="Proceed.."></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:9px; font-weight:bold; color:#0000FF">Note : Please prefix any character to this ID to avoid any conflict with any existing employee or student ID </td>
    </tr>
    
    <tr>
      <td  colspan="4" height="10"><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
if(WI.fillTextValue("emp_id").length() > 0){%>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="21%">&nbsp;</td>
      <td valign="bottom" align="right" width="16%">&nbsp; </td>
      <td valign="bottom" align="right">&nbsp;</td>
      <td width="7%" valign="bottom">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" valign="bottom"><font size="1">First name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Middle 
        name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Last 
        name</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Name</td>
      <td colspan="3"> 
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("fname");
if(bolClean)
	strTemp = "";
%>
	  <input type="text" name="fname" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp; 
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("mname");
if(bolClean)
	strTemp = "";
%>
		 <input type="text" name="mname" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp; 
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("lname");
if(bolClean)
	strTemp = "";
%>
		<input type="text" name="lname" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Gender</td>
      <td colspan="3"> 
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("gender");
if(bolClean)
	strTemp = "";
%>	   <select name="gender">
          <option value="0">Male</option>
          <%
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Female</option>
<%}else{%>
          <option value="1">Female</option>
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date of Birth</td>
      <td> 
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("dob");
if(bolClean)
	strTemp = "";
%>
	   <input name="dob" type="text" size="12" maxlength="12" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		 onKeyUp="AllowOnlyIntegerExtn('form_','dob','/');">      </td>
      <td colspan="2"><a href="javascript:show_calendar('form_.dob',<%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        (mm/dd/yyyy)</td>
    </tr>
    
    <tr> 
      <td>&nbsp;</td>
      <td>Contact Nos.</td>
      <td height="25" colspan="3"><font size="1"> 
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("tel_no");
if(bolClean)
	strTemp = "";
%>        <input name="tel_no" type="text" size="32" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">Address</td>
      <td colspan="3"> 
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("address");
if(bolClean)
	strTemp = "";
%>
	       <textarea name="address" cols="65" rows="4" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td align="center">
<%if(vEditInfo == null){%>
	  <input type="button" name="_save" value="Create Outside Member" onClick="PageAction(1,'');">
<%}%>
	  </td>
      <td align="center">
<%if(vEditInfo != null) {%>
	  <input type="button" name="_save2" value="Edit Outside Member" onClick="PageAction(2,'<%=vEditInfo.elementAt(0)%>');">
<%}%>
	  </td>
      <td align="center">
<%if(vEditInfo != null) {%>
	<input type="button" name="_save3" value="Inactivate Outside Member" onClick="PageAction(3,'<%=vEditInfo.elementAt(0)%>');">
<%}%>
	  </td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}//do not show if ID is not entered.. 

if(vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td height="25" colspan="8" align="center" bgcolor="#99CC99" style="font-size:11px; font-weight:bold;" class="thinborder">::: Existing Outside members ::: </td>
    </tr>
    <tr style="font-weight:bold" align="center">
      <td height="25" class="thinborder" width="12%">Member ID </td>
      <td class="thinborder" width="18%">Member Name</td>
      <td class="thinborder" width="7%">Gender</td>
      <td class="thinborder" width="8%">Date of Birth </td>
      <td class="thinborder" width="15%">Contact Number </td>
      <td class="thinborder" width="25%">Contact Address </td>
      <td class="thinborder" width="7%">Edit </td>
      <td class="thinborder" width="8%">Delete</td>
    </tr>
<%
String[] astrGender = {"M","F"};
for(int i = 0; i < vRetResult.size(); i += 9){%>
    <tr>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),(String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <td class="thinborder"><%=astrGender[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder"><input type="button" value="Edit" onClick="PageAction('3', '<%=vRetResult.elementAt(i)%>')"></td>
      <td class="thinborder"><input name="button" type="button" onClick="PageAction('0', '<%=vRetResult.elementAt(i)%>')" value="Delete"></td>
    </tr>
<%}%>	
  </table>
<%}%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%" height="25">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A8A8D5">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">
<input type="hidden" name="info_index">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

