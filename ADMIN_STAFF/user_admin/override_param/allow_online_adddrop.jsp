<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="javascript" src ="../../../jscript/date-picker.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value = '';
	document.form_.submit();
}
function PageAction(strInfoIndex, strAction) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this entry.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.page_action.value="";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

</script>

<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,enrollment.OverideParameter,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	//String[] astrConvertSem ={"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","allow_online_adddrop.jsp");

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
														null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Override Parameters","ALLOW ADD-DROP",
															request.getRemoteAddr(),
															null);

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
boolean bolIsAuthorized = true;

OverideParameter OP = new OverideParameter();
Vector vRetResult   = null;
Vector vStudInfo = null;
if(WI.fillTextValue("stud_id").length() > 0  && WI.fillTextValue("sy_from").length() > 0) {
	vStudInfo = OP.operateOnAllowOnlineAddDrop(dbOP, request, 5);
	if(vStudInfo == null) 
		strErrMsg = OP.getErrMsg();
	else {
		bolIsAuthorized = false;
		String strFacCollege = (String)request.getSession(false).getAttribute("info_faculty_basic.c_index");
		//System.out.println(strFacCollege);
		if(strFacCollege != null && strFacCollege.equals((String)vStudInfo.elementAt(2)))	
			bolIsAuthorized = true;
		else	
			strErrMsg = "You are not authorized to process this student. Student belong to different College.";
	}
	//System.out.println(bolIsAuthorized);
}
if(vStudInfo != null && bolIsAuthorized) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(OP.operateOnAllowOnlineAddDrop(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = OP.getErrMsg();
		else
			strErrMsg = "Operation successful.";
	}
	
	//get here subject detail.
	if(WI.fillTextValue("stud_id").length() > 0  && WI.fillTextValue("sy_from").length() > 0) {
		vRetResult = OP.operateOnAllowOnlineAddDrop(dbOP, request, 4);
		if(strErrMsg == null)
			strErrMsg = OP.getErrMsg();
	}
}
%>


<form name="form_" action="./allow_online_adddrop.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: ALLOW ADD/DROP ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="28" width="2%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School Year : </td>
      <td colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
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
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%">Student ID</td>
      <td width="20%"> <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Allow Date </td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("allow_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
 <input name="allow_date" type= "text"  class="textbox" 
		   onFocus="style.backgroundColor='#D3EBFF'" 
		   onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','allow_date','/')" 
		   onKeyUp="AllowOnlyIntegerExtn('form_','allow_date','/')" value = "<%=strTemp%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('form_.allow_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  </td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;</td>
      <td colspan="3" ><a href="javascript:ReloadPage();"><img src="../../../images/view.gif" border="0"></a><font size="1">View Information</font>
	  <a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> <font size="1">click to save overload subject information.</font></td>
    </tr>
    <tr>
      <td height="25" valign="bottom">&nbsp;</td>
      <td >&nbsp;</td>
      <td  colspan="2" >&nbsp;</td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold" bgcolor="#CCCCCC">
      <td width="25%" height="22" class="thinborder"><font size="1">Date Allowed </font></td>
      <td width="25%" class="thinborder"><font size="1">SY-Term</font></td>
      <td width="30%" class="thinborder"><font size="1">Allowed By</font></td>
<!--
      <td width="10%" class="thinborder"><font size="1">Is Used</font></td>
-->
      <td width="8%" class="thinborder"><font size="1">Invalidate</font></td>
    </tr>
    <%
	String strBGColor = null;
	for(int i = 0 ; i < vRetResult.size(); i += 6){
		if(((String)vRetResult.elementAt(i + 5)).equals("1"))
			strBGColor = "bgcolor='#cccccc'";//strTemp = "Y";
			
		else	
			strBGColor = "";//strTemp = "N";
	%>
    <tr <%=strBGColor%>>
      <td height="22" class="thinborder"><%=vRetResult.elementAt(i + 3)%> </td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%> - <%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
<!--
      <td class="thinborder" style="font-size:16px;" align="center"><%=strTemp%></td>
-->
      <td class="thinborder"> 
	  <%if(strBGColor.length() == 0) {
	  	if(iAccessLevel == 2){%> 
	  		<a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a> 
		<%}
		}else{%>N/A<%}%>	  </td>
    </tr>
    <%}%>
  </table>
<%}//end of display if vRetResult > 0%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
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
