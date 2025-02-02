<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function AddRecord(){
	document.form_.page_action.value = "1";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value="0";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function ReloadPage()
{
	document.form_.page_action.value = "";
	this.SubmitOnce("form_");
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameters","lock_fee_assessment.jsp");
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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Set Parameters-Lock Fees",request.getRemoteAddr(),
														null);
}

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

Vector vRetResult = new Vector();
SetParameter paramGS = new SetParameter();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)//add/ delete.
{
	if(paramGS.operateOnLockFeeLD(dbOP,request,Integer.parseInt(strTemp)) != null)
		strErrMsg = "Operation Successful.";
	else
		strErrMsg = paramGS.getErrMsg();
}
vRetResult = paramGS.operateOnLockFeeLD(dbOP,request,4);
if(vRetResult == null)
{
	if(strErrMsg == null)
		strErrMsg = paramGS.getErrMsg();
}
String[] astrSemester = {"Summer","1st Sem","2nd Sem"," 3rd Sem"};
%>
<form name="form_" action="./lock_fee_assessment.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SET PARAMETERS - FEES AND ASSESSMENT LOCKING PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="23%">Offering SY - Sem</td>
      <td colspan="2"> <% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        - 
        <% strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        - 
        <select name="semester">
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
        </select>
        &nbsp;&nbsp;<a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" width="71" height="23" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Last date to edit fees</td>
      <td width="11%"><input name="last_date" type="text" class="textbox" id="last_date"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("last_date")%>" size="12" maxlength="12" readonly="yes"> 
      </td>
      <td width="62%"><a href="javascript:show_calendar('form_.last_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <%
if( iAccessLevel >1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:AddRecord()"><img src="../../../images/save.gif" border='0'></a><font size="1">click 
        to save setting </font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr bgcolor="#B9B292">
      <td height="25"><div align="center"><strong>LAST DATE OF CHANGING/EDITING 
          OF FEES</strong></div></td>
    </tr>
</table>


  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="7%">&nbsp;</td>
      <td width="31%"><div align="center"><strong><font size="1">SCHOOL YEAR</font></strong></div></td>
      <td width="25%"><div align="center"><strong><font size="1">SEMESTER</font></strong></div></td>
      <td width="37%"><div align="center"><strong><font size="1">DATE LOCKED</font></strong></div></td>
      <td width="37%"><div align="center"><strong><font size="1">DELETE</font></strong></div></td>
    </tr>
    <%
for(int i =0;i< vRetResult.size(); i +=5){%>
    <tr>
      <td height="25" align="right">&nbsp;</td>
      <td align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center">
	  <% if (vRetResult.elementAt(i+2) == null) strTemp = "ALL";
	  	else strTemp = astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+2))];%>
	  <%=strTemp%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+3))%></td>
      <td align="center">
        <%
	if( iAccessLevel >1){
		if (vRetResult.elementAt(i+4) == null){
	%>
        <a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%> N/A <%}
		}else{%>N/A
      </td>
    </tr>
    <%}}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
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
