<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
</script>
<body bgcolor="#93B5BB">
<%@ page language="java" import="utility.*,ClassMgmt.CMAttendance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","cm_attendance_set_total_days.jsp");
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
int iAccessLevel = 2;

CMAttendance cmsAttendance = new CMAttendance(request);
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cmsAttendance.operateOnTotalDays(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = cmsAttendance.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = cmsAttendance.operateOnTotalDays(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = cmsAttendance.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = cmsAttendance.operateOnTotalDays(dbOP, request, 3);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
%>
<form action="./cm_attendance_set_total_days.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          CLASS ATTENDANCE - SET TOTAL NO. OF SCHOOL DAYS PER SEMESTER ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  	<font style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="15%" style="font-size:9px; font-weight:bold">&nbsp;SY-TERM</td>
      <td width="85%" height="25">
<%
	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        <%
	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
-
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
<select name="semester">
  <option value="0">Summer</option>
  <%
strTemp = WI.fillTextValue("semester");
	if(strTemp.length() ==0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.equals("1")){%>
  <option value="1" selected>1st Sem</option>
  <%}else{%>
  <option value="1">1st Sem</option>
  <%}if(strTemp.equals("2")){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.equals("3") && !strSchCode.startsWith("CPU") ){%>
  <option value="3" selected>3rd Sem</option>
  <%}else if(!strSchCode.startsWith("CPU")){%>
  <option value="3">3rd Sem</option>
  <%}%>
</select>
&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" style="font-size:9px; font-weight:bold">&nbsp;Total Attendance </td>
      <td height="25">
	  <input name="total_days" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("total_days")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','total_days');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','total_days')"></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" align="center"><%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="submit" name="122" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="122" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');"></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="27" colspan="4" align="center" bgcolor="#EBF5F5" class="thinborder">
		  <strong>:: LIST OF SET TOTAL NO. OF SCHOOL DAYS PER SEMESTER ::</strong></td>
    </tr>
    <tr> 
      <td width="23%" height="27" align="center" class="thinborder" style="font-size:9px; font-weight:bold">SCHOOL YEAR</td>
      <td width="20%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">SEMESTER</td>
      <td width="34%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">TOTAL NO. OF DAYS</td>
      <td width="23%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;</td>
    </tr>
<%
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};
for(int i = 0; i < vRetResult.size(); i += 4){%>
    <tr> 
      <td height="25" class="thinborder">
	  	<%=vRetResult.elementAt(i + 1)%> - <%=Integer.parseInt((String)vRetResult.elementAt(i + 1)) + 1%></td>
      <td class="thinborder"><%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i + 2))]%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%if(iAccessLevel ==2 ){%>
        <input type="submit" name="123" value="Delete" style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
        <%}else{%>
        &nbsp;
      <%}%></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26">&nbsp;</td>
    </tr>
    <tr bgcolor="#6A99A2"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">

</form>
</body>
</html>

<%
dbOP.cleanUP();
%>