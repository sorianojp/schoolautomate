<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function CheckValidHour() {
	var vTime =document.form_.time_from_hr.value
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_from_hr.value = "12";
	}
	vTime =document.form_.time_to_hr.value
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_to_hr.value = "12";
	}
}
function CheckValidMin() {
	if(eval(document.form_.time_from_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_from_min.value = "00";
	}
	if(eval(document.form_.time_to_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_to_min.value = "00";
	}
}
//called for add or edit.
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.user_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

var objCOA;
	var objCOAInput;
	function AjaxMapName() {
		var strIDNumber = document.form_.user_id.value;
		objCOAInput = document.getElementById("coa_info");
		eval('objCOA=document.form_.user_id');
		if(strIDNumber.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+escape(strIDNumber);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOA.value = strID;
		objCOAInput.innerHTML = "";		
	}	
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}

</script>

<%@ page language="java" import="utility.*,lms.MgmtAnnouncement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-ANNOUNCEMENTS","ann_create.jsp");
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
														"LIB_Administration","ANNOUNCEMENTS",request.getRemoteAddr(),
														"ann_create.jsp");
if(iAccessLevel == 0) {//may be called by cataloger
	iAccessLevel = 
		comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Cataloging","ANNOUNCEMENTS",request.getRemoteAddr(),
														null);
}
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
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	MgmtAnnouncement mgmtAnn = new MgmtAnnouncement(dbOP);
	Vector vEditInfo  = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(mgmtAnn.operateOnAnnouncement(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mgmtAnn.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Announcement successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Announcement successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Announcement successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtAnn.operateOnAnnouncement(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mgmtAnn.getErrMsg();
	}
%>

<body bgcolor="#DEC9CC">
<form action="./ann_create.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5">
      <td height="25" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>::::
          ANNOUNCEMENT MANAGEMENT - CREATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
<%
if(strErrMsg != null) {%>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong>
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
<%}%>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td width="2%" height="25"></td>
      <td width="11%">Ann. Target</td>
      <td width="24%">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("PATRON_TYPE_INDEX");
%>	  <select name="PATRON_TYPE_INDEX" onChange="ReloadPage();">
	  <option value="">General (for all)</option>
          <%=dbOP.loadCombo("PATRON_TYPE_INDEX","PATRON_TYPE"," from LMS_PATRON_TYPE order by PATRON_TYPE asc",strTemp, false)%>
	  </select>	  </td>
      <td width="9%">Library ID</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("user_id");
%>	  <input name="user_id" type="text" size="16" class="textbox"  onKeyUp="AjaxMapName();"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="64" value="<%=WI.getStrValue(strTemp)%>">
	  <!--<a href="javascript:StudSearch();"><img src="../../images/search.gif" width="65" height="29" border="0"></a>	  -->
	  &nbsp; &nbsp;
	  <label id="coa_info" style="width:300px; position:absolute; "></label></td>
	</tr>
    <tr >
      <td height="19" colspan="5"><hr size="1" color="#0099FF"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="35%" valign="bottom">Subject</td>
      <td width="21%" valign="bottom">Start Date</td>
      <td width="43%" valign="bottom">Expiry Date</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("SUBJECT");
%>	  <input name="SUBJECT" type="text" size="30" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="64" value="<%=strTemp%>"></td>
      <td>
 <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("start_date");
%> <input name="start_date" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" readonly
	  value="<%=strTemp%>"> <a href="javascript:show_calendar('form_.start_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("end_date");
%> <input name="end_date" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>">
        <a href="javascript:show_calendar('form_.end_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">Announced by</td>
      <td colspan="2" valign="bottom"><strong>Message</strong> ::: (NOTE : for line break in message add &lt;br&gt;)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("ANNOUNCED_BY");
%>	  <input name="ANNOUNCED_BY" type="text" size="30" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="64" value="<%=strTemp%>"></td>
      <td colspan="2" valign="bottom">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(7);
else
	strTemp = WI.fillTextValue("DESCRIPTION");
if(strTemp.length() == 0)
	strTemp = "First Line \r\n<br> Add br to insert a line break in message.";
%>	  <textarea name="DESCRIPTION" cols="45" rows="5" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="33">&nbsp;</td>
      <td colspan="3" valign="bottom">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(8);
else
	strTemp = WI.fillTextValue("auto_del");
if(strTemp.compareTo("1") == 0)
	strTemp = "checked";
else
	strTemp = "";
%> <input type="checkbox" name="auto_del" value="1" <%=strTemp%>>
        Automatically delete expired events after
        <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(9);
else
	strTemp = WI.fillTextValue("auto_del_day");
%> <input type="text" name="auto_del_day" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        day(s)</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><hr size="1" color="#0099FF"></td>
    </tr>
    <%
if(iAccessLevel > 1) {%>
    <tr valign="bottom">
      <td height="40">&nbsp;</td>
      <td colspan="3" ><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href="javascript:PageAction(1);"><img src="../../images/save.gif" border="0"></a>
        Click to save entries
        <%}else{%>
        <a href="javascript:PageAction(2);"><img src="../../images/edit.gif" border="0"></a>
        Click to edit event
        <%}%>
        <a href="./ann_create.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries <a href="javascript:ViewEvent();"><img src="../../images/view.gif" border="0"></a> 
        View all events </font></td>
    </tr>
    <%}%>
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
