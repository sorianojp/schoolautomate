<%@ page language="java" import="utility.*,payroll.ReportPayroll,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIRGURATION-13TH month Schedule","set_schedule.jsp");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"set_schedule.jsp");
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

	ReportPayroll PR13thMonth = new ReportPayroll(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
	  if (WI.fillTextValue("year_of").length() > 0){
		if(PR13thMonth.operateOn13thMonthSch(dbOP, Integer.parseInt(strTemp)) == null)
			strErrMsg = PR13thMonth.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Information successfully removed.";
		}
	  }else{
	  	strErrMsg = "Enter Year";
	  }
	}
	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = PR13thMonth.operateOn13thMonthSch(dbOP,3);
	if(vEditInfo == null)
		strErrMsg = PR13thMonth.getErrMsg();
}

	vRetResult  = PR13thMonth.operateOn13thMonthSch(dbOP,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = PR13thMonth.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./set_schedule.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: 13<sup>th</sup> MONTH PAY SCHEDULING ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30" colspan="2">Year</td>
      <td height="30"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("year_of");
%> <input name="year_of" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	 onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_of');style.backgroundColor='white'"
	 onKeyUp="AllowOnlyInteger('form_','year_of')" > </td>
    </tr>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td height="30" colspan="2">For Month of</td>
      <td width="79%" height="30"> <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(1);
		else	
			strTemp = "0";
	   %> <select name="month_fr">
          <%=dbOP.loadComboMonth(strTemp)%> 
        </select>
        - 
        <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(2);
		else	
			strTemp = "11";
	   %> <select name="month_to">
          <%=dbOP.loadComboMonth(strTemp)%> </select> &nbsp;&nbsp;&nbsp;</td>
    </tr>
    <%if(iAccessLevel > 1) {%>
    <tr> 
      <td height="36" colspan="4" align="center"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../../images/save.gif" name="hide_save" width="48" height="28" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./set_schedule.jsp"><img src="../../../../images/cancel.gif" width="51" height="26" border="0"></a> 
        Click to clear </font></td>
    </tr>
    <%}%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2" valign="bottom">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#D8D569"> 
      <td height="25" colspan="4" align="center" class="thinborder"><strong>13<sup>th</sup> 
        MONTH SCHEDULE</strong></td>
    </tr>
    <tr> 
      <td width="24%" height="25" align="center" class="thinborder"><font size="1"><strong>YEAR</strong></font></td>
      <td width="35%" align="center" class="thinborder"><font size="1"><strong>MONTHS 
      INCLUDED </strong></font></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">EDIT</font> 
      </strong> </td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};
	 for(int i =0; i < vRetResult.size(); i += 4){%>
    <tr> 
      <td height="25" class="thinborder" align="center">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td class="thinborder" align="center">&nbsp;<%=astrConvertMonth[Integer.parseInt(WI.getStrValue((String) vRetResult.elementAt(i+1),"0"))]%> - <%=astrConvertMonth[Integer.parseInt(WI.getStrValue((String) vRetResult.elementAt(i+2),"0"))]%></td>
      <%if(WI.fillTextValue("view_expired").compareTo("1") != 0){%>
      <td class="thinborder" align="center"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a> 
        <%}%> </td>
      <td class="thinborder" align="center"> <%if(iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}%> </td>
      <%}%>
    </tr>
    <%}//end of for loop%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
