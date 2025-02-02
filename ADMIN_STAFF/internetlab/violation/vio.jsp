<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == "1")
		document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage() {
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.ic_user";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,iCafe.Violation,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INTERNET CAFE MANAGEMENT-VIOLATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INTERNET CAFE MANAGEMENT"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET OTHER SERVICES - Create service",
								"vio.jsp");
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
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Internet Cafe Management",
														"INTERNET OTHER SERVICES",request.getRemoteAddr(),
														"vio.jsp");
**/


//end of authenticaion code.
Violation vio = new Violation();
Vector vEditInfo = null;
Vector vRetResult = null;
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(vio.operateOnViolation(dbOP, request, Integer.parseInt(strTemp)) == null) {
		strErrMsg = vio.getErrMsg();
	}
	else {
		strErrMsg = "Operation is successful.";
		strPrepareToEdit = "0";
	}
}
//I have to get here information.
if(strPrepareToEdit.compareTo("0") != 0) {
	vEditInfo = vio.operateOnViolation(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = vio.getErrMsg();
}
//I have to get here the services created so far.
if(WI.fillTextValue("v_year").length() > 0) {
	vRetResult = vio.operateOnViolation(dbOP, request, 4);
	if(strErrMsg == null && vRetResult == null)
		strErrMsg = vio.getErrMsg();
}



%>
<form action="./vio.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>::::
          VIOLATION RECORDING PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="46%">DATE - TIME : <%=WI.getTodaysDateTime()%></td>
      <td width="52%"> Year :
        <select name="v_year">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("v_year");
%>
          <%=dbOP.loadComboYear(strTemp,2,1)%> </select>
        &nbsp;&nbsp;&nbsp;&nbsp;<a href='javascript:ReloadPage();'><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">User ID</td>
      <td width="82%">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(8);
else
	strTemp = WI.fillTextValue("ic_user");
%> <input name="ic_user" type="text" length="16" maxlength="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="28" height="23" border="0"></a>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Attendant ID</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(10);
else
	strTemp = WI.fillTextValue("ic_attendant");
%> <input name="ic_attendant" type="text" length="16" maxlength="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Violation Type</td>
      <td>
	  <select name="v_type">
      	<option value="0">Low</option>
<%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("v_type");
//System.out.println(strTemp);
if(strTemp.equals("1")){%>
     	<option value="1" selected>Medium</option>
<%}else{%>
     	<option value="1">Medium</option>
<%}if(strTemp.equals("2") ) {%>
      	<option value="2" selected>High</option>
<%}else{%>
      	<option value="2">High</option>
<%}if(strTemp.equals("3")) {%>
     	<option value="3" selected>Very High</option>
<%}else{%>
      	<option value="3">Very High</option>
<%}%>
	  </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Violation Date</td>
      <td>
<%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("v_date");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);

%>	  <input name="v_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.v_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        <font size="1">&nbsp; Time : </font>
        <select name="v_hr">
          <option value="8">8 AM</option>
          <%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("v_hr");
if(strTemp.equals("9")){%>
          <option value="9" selected>9 AM</option>
<%}else{%>
          <option value="9">9 AM</option>
<%}if(strTemp.equals("10") ) {%>
          <option value="10" selected>10 AM</option>
<%}else{%>
          <option value="10">10 AM</option>
<%}if(strTemp.equals("11")) {%>
          <option value="11" selected>11 AM</option>
<%}else{%>
          <option value="11">11 AM</option>
<%}if(strTemp.equals("12")) {%>
          <option value="12" selected>12 PM</option>
<%}else{%>
          <option value="12">12 PM</option>
<%}if(strTemp.equals("13")) {%>
          <option value="13" selected>1 PM</option>
<%}else{%>
          <option value="13">1 PM</option>
<%}if(strTemp.equals("14")) {%>
          <option value="14" selected>2 PM</option>
<%}else{%>
          <option value="14">2 PM</option>
<%}if(strTemp.equals("15")) {%>
          <option value="15" selected>3 PM</option>
<%}else{%>
          <option value="15">3 PM</option>
<%}if(strTemp.equals("16")) {%>
          <option value="16" selected>4 PM</option>
<%}else{%>
          <option value="16">4 PM</option>
<%}if(strTemp.equals("17")) {%>
          <option value="17" selected>5 PM</option>
<%}else{%>
          <option value="17">5 PM</option>
<%}if(strTemp.equals("18")) {%>
          <option value="18" selected>6 PM</option>
<%}else{%>
          <option value="18">6 PM</option>
<%}if(strTemp.equals("19")) {%>
          <option value="19" selected>7 PM</option>
<%}else{%>
          <option value="19">7 PM</option>
<%}if(strTemp.equals("20")) {%>
          <option value="20" selected>8 PM</option>
<%}else{%>
          <option value="20">8 PM</option>
<%}if(strTemp.equals("21")) {%>
          <option value="21" selected>9 PM</option>
<%}else{%>
          <option value="21">9 PM</option>
<%}if(strTemp.equals("22")) {%>
          <option value="22" selected>10 PM</option>
<%}else{%>
          <option value="22">10 PM</option>
<%}if(strTemp.equals("23")) {%>
          <option value="23" selected>11 PM</option>
<%}else{%>
          <option value="23">11 PM</option>
<%}if(strTemp.equals("1")) {%>
          <option value="1" selected>1 AM</option>
<%}else{%>
          <option value="1">1 AM</option>
<%}if(strTemp.equals("2")) {%>
          <option value="2" selected>2 AM</option>
<%}else{%>
          <option value="2">2 AM</option>
<%}if(strTemp.equals("3")) {%>
          <option value="3" selected>3 AM</option>
<%}else{%>
          <option value="3">3 AM</option>
<%}if(strTemp.equals("4")) {%>
          <option value="4" selected>4 AM</option>
<%}else{%>
          <option value="4">4 AM</option>
<%}if(strTemp.equals("5")) {%>
          <option value="5" selected>5 AM</option>
<%}else{%>
          <option value="5">5 AM</option>
<%}if(strTemp.equals("6")) {%>
          <option value="6" selected>6 AM</option>
<%}else{%>
          <option value="6">6 AM</option>
<%}if(strTemp.equals("7")) {%>
          <option value="7" selected>7 AM</option>
<%}else{%>
          <option value="7">7 AM</option>
<%}%>
        </select>
        </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Block Internet Usage</td>
      <td>
<%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = WI.getStrValue(vEditInfo.elementAt(6));
else
	strTemp = WI.fillTextValue("block_fr");
%>	  <input name="block_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.block_fr');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        &nbsp;To
<%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = WI.getStrValue(vEditInfo.elementAt(7));
else
	strTemp = WI.fillTextValue("block_to");
%>        <input name="block_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.block_to');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Description</td>
      <td valign="top">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("v_desc");
%> <textarea name="v_desc" cols="60" rows="5" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
  </table>

<%if(iAccessLevel > 1){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="30%" height="59">&nbsp;</td>
      <td width="70%" height="59">
	  <%if(strPrepareToEdit.compareTo("0") == 0) {%>
	  <a href='javascript:PageAction("1","");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
	  <%}else{%>
	  <a href='javascript:PageAction("2","");'><img src="../../../images/edit.gif" border="0"></a>
	  <%}%>
	  <font size="1">click to save entries/changes
	  <a href="./vio.jsp?v_year=<%=WI.fillTextValue("v_year")%>"><img src="../../../images/cancel.gif" border="0"></a>click to cancel/clear
        entries </font></td>
    </tr>
  </table>
<%}//if iAccessLevel > 1

if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFF9F">
      <td height="23" colspan="8" class="thinborder"><div align="center"><font color="#0000FF"><strong>VIOLATION
          RECORDED </strong></font></div></td>
    </tr>
    <tr>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>ID
          (NAME)</strong></font></div></td>
      <td width="5%" height="23" class="thinborder"><font size="1"><strong> TYPE</strong></font></td>
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>DATE
          : TIME</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>ATTENDANT</strong></font></div></td>
      <td width="15%" class="thinborder" align="center"><font size="1"><strong>I-BLOCK
        DATE</strong></font></td>
      <td width="5%" class="thinborder">&nbsp;</td>
      <td width="5%" class="thinborder">&nbsp;</td>
    </tr>
    <%
String[] astrConvertType = {"Low","Medium","High","Very High"};
for(int i = 0; i < vRetResult.size() ; i += 12){%>
    <tr>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)+ "<br><font size=1>"+(String)vRetResult.elementAt(i + 9)+"</font>"%></td>
      <td class="thinborder"><%=astrConvertType[Integer.parseInt((String)vRetResult.elementAt(i + 1))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%> ::: <%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vRetResult.elementAt(i + 4)))%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 10)+ "<br><font size=1>"+(String)vRetResult.elementAt(i + 11)+"</font>"%></td>
      <td class="thinborder">
	  <%if( vRetResult.elementAt(i + 6) != null) {%>
	  	<%=(String)vRetResult.elementAt(i + 6)%> to <%=(String)vRetResult.elementAt(i + 7)%>
	  <%}else{%>&nbsp;<%}%>
	  </td>
      <td class="thinborder"> <%if(iAccessLevel > 1){%> <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);"><img src="../../../images/edit.gif" border="0"></a>
        <%}%> </td>
      <td class="thinborder"> <%if(iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
        <%}%> </td>
    </tr>
    <%}//end of for loop%>
  </table>
<%}//end of if vRetResult is not null.%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
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
