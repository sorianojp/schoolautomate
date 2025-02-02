<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction; 
	document.form_.info_index.value = strInfoIndex;
	
	if(strAction == "1") 
		document.form_.hide_save.src = "../../images/blank.gif";
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,iCafe.ComputerUsage,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

if(WI.fillTextValue("print_pg").length() > 0) {%>
	<jsp:forward page="./iL_usage_users_dtls_print.jsp"/>	
<%return;}

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET LAB OPERATION -old account",
								"iL_old_account.jsp");
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
														"Internet Cafe Management",
														"INTERNET LAB OPERATION",request.getRemoteAddr(),
														"iL_old_account.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}
ComputerUsage compUsage = new ComputerUsage();
iCafe.TimeInTimeOut tinTout = new iCafe.TimeInTimeOut();
enrollment.EnrlAddDropSubject addDropSub = new enrollment.EnrlAddDropSubject();

Vector vRetResult = null;
Vector vStudInfo = null;
long lBalanceUsage = 0l;
	 
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("semester").length() > 0 &&
	WI.fillTextValue("stud_id").length() > 0) {
	
	vStudInfo = addDropSub.getEnrolledStudInfo(dbOP,null, WI.fillTextValue("stud_id"), WI.fillTextValue("sy_from"), 
					 WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
	if(vStudInfo == null || vStudInfo.size() == 0)
		strErrMsg = addDropSub.getErrMsg();
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(compUsage.operateOnOldAccount(dbOP, request, Integer.parseInt(strTemp)) != null)
			strErrMsg = "Operation successful.";
		else	
			strErrMsg = compUsage.getErrMsg();
	}		
	vRetResult = compUsage.operateOnOldAccount(dbOP, request, 4);
	if(strErrMsg == null && vRetResult == null)
		strErrMsg = compUsage.getErrMsg();
}

if(vStudInfo != null && vStudInfo.size() > 0){
	lBalanceUsage = tinTout.getInternetBalanceUsage(dbOP, (String)vStudInfo.elementAt(0), 
						WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
	if(lBalanceUsage == tinTout.lErrorVal) {
		strErrMsg = tinTout.getErrMsg();
		vRetResult = null;
	}
}
 
//end of authenticaion code.
%>
<form action="./iL_old_account.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          USER OLD USAGE RECORD ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td width="66%" height="25">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
      <td width="34%"><strong>
        <div align="right"><font size="1"><strong>Date / Time :</strong> <%=WI.getTodaysDateTime()%></font></div>
        </strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="17%" height="25">Student ID : <strong></strong></td>
      <td><input name="stud_id" type="text" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">SY/Term</td>
      <td> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Usage in mins</td>
      <td><input name="min_used" type="text" size="4" maxlength="4" 
	  	value="<%=WI.fillTextValue("min_used")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        - type &nbsp; <select name="usage_type">
          <option value="0">Balance</option>
          <%
strTemp = WI.fillTextValue("usage_type");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Already used</option>
          <%}else{%>
          <option value="1">Already used</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
    <%
if(vStudInfo != null && vStudInfo.size() > 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Student Name</td>
      <td><%=WebInterface.formatName((String)vStudInfo.elementAt(10),
	  					(String)vStudInfo.elementAt(11),(String)vStudInfo.elementAt(12),4)%></td>
    </tr>
    <tr> 
      <td width="4%">&nbsp;</td>
      <td height="25">Course / Major</td>
      <td><%=(String)vStudInfo.elementAt(2)%><%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Year Level</td>
      <td height="25"><%=WI.getStrValue((String)vStudInfo.elementAt(4),"N/A")%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><a href='javascript:PageAction("1","");'><img src="../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save Usage.</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="4%" height="15">&nbsp;</td>
      <td height="15" colspan="2">TOTAL HOURS REMAINING : <strong><%=ConversionTable.convertMinToHHMM((int)lBalanceUsage)%></strong> 
        </td>
      <td width="27%">&nbsp;</td>
    </tr>
  </table>	  
 <%}
 if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFF9F"> 
      <td height="24" colspan="6"><div align="center"><font color="#0000FF"><strong>OLD 
          USAGE RECORD</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="12%" height="25" align="center"><font size="1"><strong>DATE ENCODED</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>ENCODED BY (ID)</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>MINS</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>USAGE DETAIL</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>EFFECTIVE BALANCE 
        IN MINS</strong></font></td>
      <td width="15%" align="center"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 6 ){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td align="center"><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'>
	  <img src="../../images/delete.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>
 <%}//end of displaying if vRetResult <> null%>
 
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>