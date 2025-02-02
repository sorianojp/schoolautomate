<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");

	if (strSchCode == null) 
		strSchCode = "";
	
	String strTemp = null;
	if (strSchCode.startsWith("CGH")){
		strTemp = "_cgh";
	}else{
		strTemp ="";
	}
%>

</head>
<script language="JavaScript" src="../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript" src="../../Ajax/ajax.js" type="text/javascript"></script>
<script language="JavaScript">
function AddRecord() {
	//if names are not save, reset proceedAddRecord
	if(document.offlineRegd.fname.value != document.offlineRegd.fname_old.value || 
		document.offlineRegd.mname.value != document.offlineRegd.mname_old.value || 
		document.offlineRegd.lname.value != document.offlineRegd.lname_old.value)
		document.offlineRegd.proceedAddRecord.value = '';


	document.offlineRegd.addRecord.value = "1";
	this.SubmitOnce("offlineRegd");
}
function ClearEntry()
{
	location = "./admission_registration_new.jsp?stud_status=New";
}
function DisplaySYTo() {
	var strSYFrom = document.offlineRegd.sy_from.value;
	if(strSYFrom.length == 4)
		document.offlineRegd.sy_to.value = eval(strSYFrom) + 1;
	if(strSYFrom.length < 4)
		document.offlineRegd.sy_to.value = "";
}
function ViewAdmissionSlip(index){
	var pgLoc = "./entrance_admission_slip_new_print<%=strTemp%>.jsp?temp_id="+index;
	var win=window.open(pgLoc,"AdmissionSlip",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintEnrollmentForm() {
	var studID = prompt("Please enter Student's ID.", "Temp/ perm ID.");
        if(studID == null)
        	return;
	if(studID.length == 0)  {
		alert("Failed to process request. Student ID is empty.");
		return;
	}
	var pgLoc = "./entrance_admission_slip_new_print<%=strTemp%>.jsp?temp_id="+studID;
	var win=window.open(pgLoc,"AdmissionSlip",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=offlineRegd.old_stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
var calledRef;
//all about ajax - to display student list with same name.
function AjaxMapName(strRef) {
	var strSearchCon = "&search_temp=2";

		calledRef = strRef;
		var strCompleteName;
		if(strRef == "0") {
			strSearchCon = "";

			if(document.offlineRegd.old_stud_id)
				strCompleteName = document.offlineRegd.old_stud_id.value;
			else
				strCompleteName = document.offlineRegd.stud_id.value;
			if(strCompleteName.length <3)
				return;
		}
		else {

			strCompleteName = document.offlineRegd.lname.value;
			if(strCompleteName.length == 0)
				return;
			if(document.offlineRegd.fname.value.length > 0)
				strCompleteName = strCompleteName+","+document.offlineRegd.fname.value;
		}

		/// this is the point i must check if i should call ajax or not..
		if(this.bolReturnStrEmpty && this.startsWith(this.strPrevEntry,strCompleteName, false) == 0)
			return;
		this.strPrevEntry = strCompleteName;

		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
		//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	if(calledRef == "0") {
		if(document.offlineRegd.old_stud_id)
			document.offlineRegd.old_stud_id.value = strID;
		else
			document.offlineRegd.stud_id.value = strID;

		document.getElementById("coa_info").innerHTML = "";
	}

}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>

<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";

	String[] astrSchYrInfo = null;
	String strProceedVal = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Registration","admission_registration.jsp");
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
														"Admission Maintenance","Registration",request.getRemoteAddr(),
														"admission_registration_new.jsp");
														
if (iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","Registration",request.getRemoteAddr(),
														"admission_registration_new.jsp");
}
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

//end of authenticaion code.

OfflineAdmission offlineAdm = new OfflineAdmission();
boolean bolClearEntry = false; // only if page is successful.
boolean bolAllowPrint = false;

if(WI.fillTextValue("addRecord").equals("1"))
{//addrecord now.
	boolean bProceed = false;
	if(WI.fillTextValue("proceedAddRecord").compareTo("1") == 0)
		bProceed = true;

	strTemp = offlineAdm.createCPUApplicant(dbOP,request,bProceed,1);
	if(strTemp == null)
		strErrMsg = offlineAdm.getErrMsg();
	else if(strTemp.equals("1")){
		strErrMsg = offlineAdm.getErrMsg();
		strProceedVal = "1";
	}
	else{
		if(offlineAdm.autoScheduling(dbOP,request,strTemp,
		   " Student basic information for enrollment process is created successfully. reference ID = "+strTemp)){
			strErrMsg = "Student basic information for enrollment process is created successfully. reference ID = "+strTemp;
			bolAllowPrint = true;
		}
		else{
			strErrMsg = offlineAdm.getErrMsg();
			bolAllowPrint = false;
		}
	}
}

astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)
{
	dbOP.cleanUP();
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		School year information not found.</font></p>
		<%
		return;
}
%>
<form action="./admission_registration_new.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          ADMISSION SLIP REGISTRATION::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="3%"></td>
      <td width="87%" height="25"> <strong><font size="3"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></strong> </td>
      <td width="10%">
	  <%if(!bolAllowPrint){%>
	  	<a href="javascript:PrintEnrollmentForm();"><img src="../../images/print.gif" width="60" height="26" border="0"></a>
	  <%}else{%>
	  	<a href="javascript:ViewAdmissionSlip('<%=strTemp%>');"><img src="../../images/view.gif" width="40" height="31" border="0"></a>
	  <%}%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" height="25"> School Year</td>
      <td width="19%"> <% strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[0];
	  %> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo();"> <%
	  strTemp = WI.fillTextValue("sy_to");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[1];
	  %>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
      </td>
      <td width="7%" height="25">Term :</td>
      <td width="28%"><select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = astrSchYrInfo[2];
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  
		  if (!strSchCode.startsWith("CPU")) { 
			  if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }
		  %>
        </select></td>
      <td width="28%"><div align="right"><font size="1">
<%if(!bolAllowPrint){%>click to print admission slip
<%}else{%> click to view admission slip <%}%> 
</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%" height="25" valign="bottom">Gender
        <select name="gender">
          <option value="M">Male</option>
          <% strTemp = WI.fillTextValue("gender");
			if(strTemp.compareTo("F") == 0)
			{%>
          <option value="F" selected>Female</option>
          <%}else{%>
          <option value="F">Female</option>
          <%}%>
        </select></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="15">&nbsp;</td>
    </tr>
    <tr>
      <td height="15"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<% if (!strSchCode.startsWith("CGH")) {%> 
    <tr>
      <td width="15%" height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;HS Student ID </td>
<%if(bolClearEntry)
	strTemp = "";
else
	strTemp = WI.fillTextValue("old_stud_id");
%>	  
      <td width="18%" height="25"><input name="old_stud_id" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16"></td>
      <td width="67%"><font size="1"><a href="javascript:OpenSearch()"><img src="../../images/search.gif" width="37" height="30" border=0></a>encode only if student is a HS Graduate of this University</font></td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%}%>	
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="35%" height="25" valign="bottom">Student last name </td>
      <td width="34%" valign="bottom">Student first name </td>
      <td width="30%" height="25" valign="bottom">Student middle name </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"> <%if(bolClearEntry)
	strTemp = "";
else
	strTemp = WI.fillTextValue("lname");
%> <input name="lname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td> <%
if(bolClearEntry) 	strTemp = "";
else strTemp = WI.fillTextValue("fname");
%> <input name="fname" type="text" size="20" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td height="25"> <% if(bolClearEntry) strTemp = "";
else strTemp = WI.fillTextValue("mname");
%> <input name="mname" type="text" size="20" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="25" colspan="9"><strong><font color="#000099">NOTE : Temp ID
        will be given after saving info.</font></strong></td>
    </tr>
    <tr>
      <td height="23" colspan="9">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="7"><div align="center"></div></td>
      <td width="26%" height="25"><a href="javascript:AddRecord();"><img src="../../images/save.gif" name="hide_save" width="48" height="28" border="0"></a>
        <font size="1" >click to save entries</font></td>
      <td width="53%" height="25"><a href="javascript:ClearEntry();"><img src="../../images/clear.gif" width="55" height="19" border="0"></a>
        <font size="1" >click to clear entries</font></td>
    </tr>

    <tr>
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="proceedAddRecord" value="<%=strProceedVal%>">
<input type="hidden" name="lname_old" value="<%=WI.fillTextValue("lname")%>">
<input type="hidden" name="fname_old" value="<%=WI.fillTextValue("fname")%>">
<input type="hidden" name="mname_old" value="<%=WI.fillTextValue("mname")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
