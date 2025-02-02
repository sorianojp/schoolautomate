<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../jscript/common.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strAction, strIndex)
{
	document.set_param.info_index.value = strIndex;
	document.set_param.page_action.value = strAction;
//	alert(document.set_param.info_index.value);
}

function ReloadPage()
{
	document.set_param.page_action.value = "";
	document.set_param.submit();
}
function ShowHideEmpID()
{
	if(document.set_param.is_for_one_faculty.checked)
		showLayer("emp_id_");
	else {
		document.set_param.emp_id.value = "";
		hideLayer("emp_id_");
	}


}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.set_param.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.set_param.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	//document.set_param.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameter","set_param_gs.jsp");

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
														"set_param_gs.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Override Parameters","Grade sheet encoding",request.getRemoteAddr(),
															"set_param_gs.jsp");
}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
SetParameter paramGS = new SetParameter();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)//add/ delete.
{
	if(paramGS.operateOnGSheet(dbOP,request,Integer.parseInt(strTemp)) != null)
		strErrMsg = "Operation Successful.";
	else
		strErrMsg = paramGS.getErrMsg();
}
vRetResult = paramGS.operateOnGSheet(dbOP,request,4);
if(vRetResult == null)
{
	if(strErrMsg == null)
		strErrMsg = paramGS.getErrMsg();
}

boolean bolIsNG = false;
if(WI.fillTextValue("is_ng").equals("1"))
	bolIsNG = true;

%>
<form name="set_param" action="./set_param_gs.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          SET PARAMETERS - GRADE SHEET ENCODING/SUBMISSION PAGE <%if(bolIsNG) {%> - FOR NG GRADE <%}%>::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<a href="set_param/grade_setting_main.jsp"><img src="../../images/go_back.gif" border="0"></a><font size="1">go 
        to main</font>&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font>      </td>
    </tr>
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="21%">Set Parameter for</td>
      <td><strong>
        <select name="grade_for">
          <%=dbOP.loadCombo("EXAM_NAME","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and (is_valid =1 or (is_valid = 2 and bsc_grading_name is not null)) order by is_valid, EXAM_PERIOD_ORDER asc", request.getParameter("grade_for"), false)%>
        </select>
        </strong> &nbsp;&nbsp;&nbsp;<a href="javascript:ReloadPage()"><img src="../../images/refresh.gif" border="0"></a></td>
    </tr>
    <!--    <tr>
      <td height="25">&nbsp;</td>
      <td width="15%"><div align="right">From&nbsp;</div></td>
      <td width="78%"><input name="from_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("from_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('set_param.from_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>
      </td>
    </tr>
-->
    <tr>
      <td height="25">&nbsp;</td>
      <td>Offering SY - Sem</td>
      <td>
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('set_param','sy_from','sy_to')">
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        -
        <select name="semester">
          <option value="">ALL</option>
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
      <td height="25">&nbsp;</td>
      <td>Grade Encoding Date </td>
      <td style="font-size:9px;"> Start Date: 
	  <input name="from_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("from_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> <a href="javascript:show_calendar('set_param.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  End Date: 
	  <input name="to_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("to_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> <a href="javascript:show_calendar('set_param.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  
	  </td>
    </tr>
    <%
if( iAccessLevel >1){%>
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td>
<%
strTemp = WI.fillTextValue("is_for_one_faculty");
if(strTemp.compareTo("1") == 0)
	strTemp = "checked";
else
	strTemp = "";
%>
	  <input type="checkbox" name="is_for_one_faculty" value="1" <%=strTemp%> onClick="ShowHideEmpID();">
        Allow Specific Faculty</td>
      <td><input name="emp_id" type="text" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" id="emp_id_" onKeyUp="AjaxMapName(1);">
        (Faculty Employee ID)
		<label id="coa_info"></label>		</td>
<script language="JavaScript">
ShowHideEmpID();
</script>    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="image" src="../../images/save.gif" onClick='PageAction(1,"");'>
        <font size="1">click to save new grade sheet submission time</font></td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr bgcolor="#B9B292">
      <td height="25"><div align="center">GRADE SHEET SUBMISSION DATE <%if(bolIsNG) {%> - FOR NG GRADE <%}%></div></td>
    </tr>
</table>


  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="20%"><div align="center"><strong><font size="1">EXAM NAME</font></strong></div></td>
      <td width="23%"><div align="center"><strong><font size="1">GRADE ENCODING DATE RANGE </font></strong></div></td>
      <td width="27%"><div align="center"><strong><font size="1">FACULY EMP ID</font></strong></div></td>
      <td width="28%"><div align="center"><strong><font size="1">DELETE</font></strong></div></td>
    </tr>
    <%
for(int i =0;i< vRetResult.size(); i +=5){%>
    <tr>
      <td height="25" align="right">&nbsp;</td>
      <td align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+4), "Open Date")%> - <%=(String)vRetResult.elementAt(i+3)%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+2))%></td>
      <td align="center">
        <%
	if( iAccessLevel >1){%>
        <input type="image" onClick='PageAction(0,<%=(String)vRetResult.elementAt(i)%>);' src="../../images/delete.gif">
        <%}else{%>
        Not Allowed to delete
        <%}%>
      </td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="is_ng" value="<%=WI.fillTextValue("is_ng")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
