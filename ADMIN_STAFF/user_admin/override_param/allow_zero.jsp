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
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to remove this record."))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.OverideParameter,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String[] astrConvertSem ={"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","allow_zero.jsp");

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
														"System Administration","Override Parameters",request.getRemoteAddr(),
														"allow_zero.jsp");
//IF NOT ALLOWED, CHECK IF ALLOWED FOR OVERRIDE PARAMETER -> STUDENT LOAD
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Override Parameters","Student Load",
														request.getRemoteAddr(),
														"allow_zero.jsp");

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

OverideParameter OP = new OverideParameter();
Vector vStudDetail = null;
strTemp = WI.fillTextValue("page_action");

if(WI.fillTextValue("stud_id").length() > 0  && WI.fillTextValue("sy_from").length() > 0)
{
	vStudDetail = OP.getStudentLoadInfo(dbOP,request.getParameter("stud_id"),WI.fillTextValue("sy_from"),
									WI.fillTextValue("sy_to"),WI.fillTextValue("semester"), false);
	if(vStudDetail == null)
		strErrMsg = OP.getErrMsg();
}
if(strTemp.length() > 0) {
	if(OP.operateOnAllowZeroDP(dbOP,request, Integer.parseInt(strTemp)) != null )
		strErrMsg = "Successful";
	else
		strErrMsg = OP.getErrMsg();
}

Vector vRetResult = OP.operateOnAllowZeroDP(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null) {
	strErrMsg = OP.getErrMsg();
}


dbOP.cleanUP();

if(strErrMsg == null) 
	strErrMsg = "";
%>
<form name="form_" action="./allow_zero.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          ALLOW ZERO DOWNPAYMENT ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="28" width="1%">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=strErrMsg%></b></font> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School Year : </td>
      <td colspan="3">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
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
        </select></td>
    </tr>
    <tr>
      <td colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25" width="1%">&nbsp;</td>
      <td width="15%">Student ID</td>
      <td width="22%"> </select> <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="8%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="54%"><input type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr >
      <td  colspan="5" ><hr size="1"></td>
    </tr>
  </table>

 <%
 if(vStudDetail != null && vStudDetail.size() > 0){%>
<input type="hidden" name="year_level" value="<%=(String)vStudDetail.elementAt(4)%>">
<input type="hidden" name="user_index" value="<%=(String)vStudDetail.elementAt(0)%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
      <td width="98%">Student name : <strong><%=(String)vStudDetail.elementAt(1)%></strong></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td>Course/Major :<strong> <%=(String)vStudDetail.elementAt(2)%>
        <%
	  if(vStudDetail.elementAt(3) != null){%>
        / <%=(String)vStudDetail.elementAt(3)%>
        <%}%>
        </strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Enrolling YR : <strong><%=WI.getStrValue(vStudDetail.elementAt(4),"N/A")%>
        </strong> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td  colspan="4"><hr size="1"></td>
    </tr>
    
<%
if( iAccessLevel >1){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="10%" colspan="">Reason</td>
      <td width="88%" colspan="2"><input type="text" name="reason" value="<%=WI.fillTextValue("reason")%>" class="textbox" size="75"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input type="image" src="../../../images/save.gif" onClick="PageAction('1','');"></td>
    </tr>
<%}%>
  </table>
 <%}//only if student id is not null %>
 
 <%if(vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#CCCCCC">
      <td height="25" colspan="4" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">LIST OF STUDENT ALLOWED TO PAY ZERO DOWNPAYMENT</td>
    </tr>
    <tr style="font-weight:bold" align="center" bgcolor="#FFFFCC">
      <td class="thinborder" height="25" style="font-size:9px;" width="15%">ID NUMBER</td>
      <td class="thinborder" style="font-size:9px;" width="20%">STUDENT NAME</td>
      <td class="thinborder" style="font-size:9px;" width="50%">REASON</td>
      <td class="thinborder" style="font-size:9px;" width="10%">DELETE</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 4){%>
    <tr>
      <td class="thinborder" height="25" style="font-size:9px;">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" style="font-size:9px;">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" style="font-size:9px;">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 3))%></td>
      <td class="thinborder" style="font-size:9px;" align="center"><a href="javascript:PageAction('0', <%=vRetResult.elementAt(i)%>)"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>	
 <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" align="center">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="page_action">
 <input type="hidden" name="info_index">
</form>
</body>
</html>

