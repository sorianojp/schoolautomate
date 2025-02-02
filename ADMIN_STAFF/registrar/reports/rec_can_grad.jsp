<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintPg() {
	if(document.form_.date_yyyy.value.length != 4) {
		alert("Please fill up date of graduation in YYYY format");
		return ;
	}
	if(document.form_.registrar_name.value.length ==0) {
		alert("Please fill up Complete name of registar.");
		return ;
	}
	if(document.form_.dean_name.value.length ==0) {
		alert("Please fill up Complete name of DEAN.");
		return ;
	}
	document.form_.add_record.value = "";
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function FocusID() {
	document.form_.stud_id.focus();
}
function RemovePrintPg() {
	document.form_.add_record.value = "";
	document.form_.print_pg.value = "";
}
function AddRecord() {
	document.form_.add_record.value = "1";
	document.form_.print_pg.value = "";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//all about ajax.
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

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
if(request.getParameter("print_pg") != null && request.getParameter("print_pg").compareTo("1") ==0){%>
	<jsp:forward page="./rec_can_grad_print.jsp" />
<%return;}

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDeanName = null;//I have to find.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-candidate for grad - form 18","rec_can_grad.jsp");
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
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"rec_can_grad.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.ReportRegistrar repRegistrar = new enrollment.ReportRegistrar();
Vector vStudInfo = null;
Vector vForm18Info = null;
if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		//get dean name here.
		strDeanName = dbOP.mapOneToOther("course_offered join college on (college.c_index = course_offered.c_index)",
						"course_index",(String)vStudInfo.elementAt(5),"DEAN_NAME",null);
	}
}

//save encoded information if save is clicked.
if(WI.fillTextValue("add_record").compareTo("1") ==0){
	if(repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,1,false) == null)
		strErrMsg = repRegistrar.getErrMsg();
}
vForm18Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,false);
if(vForm18Info != null && vForm18Info.size() ==0)
	vForm18Info = null;
%>
<form action="./rec_can_grad.jsp" name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          RECORDS OF CANDIDATE FOR GRADUATION PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr valign="top">
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">Student ID </td>
      <td width="26%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
      </td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="54%"><input name="image" type="image" src="../../../images/form_proceed.gif" onClick="RemovePrintPg();">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>
	  </td>
    </tr>
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Student name : </td>
      <td width="28%"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></td>
      <td width="29%"><%=((String)vStudInfo.elementAt(0)).toUpperCase()%></td>
      <td width="27%"><%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top"><font size="1">(Last Name)</font></td>
      <td valign="top"><font size="1">(First Name)</font></td>
      <td valign="top"><font size="1">(Middle Name)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">CANDIDATE FOR TITLE/DEGREE : <%=((String)vStudInfo.elementAt(7)).toUpperCase()%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">Major : <%=WI.getStrValue(vStudInfo.elementAt(8)," ").toUpperCase()%></td>
    </tr>
	</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="26">&nbsp;</td>
      <td width="21%">Date of Graduation </td>
      <td width="77%"><select name="date_mm">
          <option value="JANUARY">JANUARY</option>
          <%
strTemp = WI.fillTextValue("date_mm");
if(strTemp.startsWith("F")){%>
          <option value="FEBRUARY" selected>FEBRUARY</option>
          <%}else{%>
          <option value="FEBRUARY">FEBRUARY</option>
          <%}if(strTemp.startsWith("MAR")){%>
          <option value="MARCH" selected>MARCH</option>
          <%}else{%>
          <option value="MARCH">MARCH</option>
          <%}if(strTemp.startsWith("AP")){%>
          <option value="APRIL" selected>APRIL</option>
          <%}else{%>
          <option value="APRIL">APRIL</option>
          <%}if(strTemp.startsWith("MAY")){%>
          <option value="MAY" selected>MAY</option>
          <%}else{%>
          <option value="MAY">MAY</option>
          <%}if(strTemp.startsWith("JUN")){%>
          <option value="JUNE" selected>JUNE</option>
          <%}else{%>
          <option value="JUNE">JUNE</option>
          <%}if(strTemp.startsWith("JUL")){%>
          <option value="JULY" selected>JULY</option>
          <%}else{%>
          <option value="JULY">JULY</option>
          <%}if(strTemp.startsWith("AUG")){%>
          <option value="AUGUST" selected>AUGUST</option>
          <%}else{%>
          <option value="AUGUST">AUGUST</option>
          <%}if(strTemp.startsWith("S")){%>
          <option value="SEPTEMBER" selected>SEPTEMBER</option>
          <%}else{%>
          <option value="SEPTEMBER">SEPTEMBER</option>
          <%}if(strTemp.startsWith("O")){%>
          <option value="OCTOBER" selected>OCTOBER</option>
          <%}else{%>
          <option value="OCTOBER">OCTOBER</option>
          <%}if(strTemp.startsWith("N")){%>
          <option value="NOVEMBER" selected>NOVEMBER</option>
          <%}else{%>
          <option value="NOVEMBER">NOVEMBER</option>
          <%}if(strTemp.startsWith("D")){%>
          <option value="DECEMBER" selected>DECEMBER</option>
          <%}else{%>
          <option value="DECEMBER">DECEMBER</option>
          <%}%>
        </select>
        /
        <input name="date_yyyy" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("date_yyyy")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        <font size="1"> (mm/yyyy)</font></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td>Registrar's Name &nbsp;&nbsp; </td>
      <td>
<%
if(vForm18Info != null)
	strTemp = (String)vForm18Info.elementAt(0);
else
	strTemp = WI.fillTextValue("registrar_name");
%>
	  <input name="registrar_name" type="text" size="64" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp; </td>
      <td valign="top"><font size="1">(complete name, degree titles)</font></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td>Dean's Name &nbsp;&nbsp; </td>
      <td><input name="dean_name" type="text" size="64" value="<%=WI.getStrValue(strDeanName)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp; </td>
      <td valign="top"><font size="1">(complete name, degree titles)</font> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:AddRecord();">
	  <img src="../../../images/save.gif" border="0" name="hide_save"></a>
        Click to save/edit registrar's name.</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"> </a></div></td>
      <td><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
        <font size="1">Click to print report</font></td>
    </tr>
  </table>
  <input type="hidden" name="degree_type" value="<%=(String)vStudInfo.elementAt(15)%>">
<%}//only if stud info is > 0%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="add_record">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
