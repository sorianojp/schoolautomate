<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";


//if student, return here. 
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")) {
	%>
	<p style="font-weight:bold; font-size:16px; color:#FF0000">You are not authorized to access this page.</p>
<%return;}

utility.WebInterface WI = new utility.WebInterface(request);
String strTemp = null; String strErrMsg = null;


String strDefaultTerm = (String)request.getSession(false).getAttribute("cur_sem");
if(strDefaultTerm == null)
	strDefaultTerm = "";

String strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../../Ajax/ajax.js" ></script>
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<script language="JavaScript">
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
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.stud_id.blur();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

function PrintPg(printRef) {
	if(document.form_.stud_id.value.length == 0) {
		alert("Please enter student ID.");
		return;
	}
	var strStudID = document.form_.stud_id.value;
	strCharAt = strStudID.charAt(strStudID.length - 1)
	if(strCharAt  == 'T' || strCharAt == 't') {
		strStudID = strStudID.substring(0, strStudID.length - 1);
		document.form_.stud_id.value = strStudID;
	}
	
	pgLoc="?is_confirmed=1&stud_id="+document.form_.stud_id.value+"&sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+
		document.form_.semester[document.form_.semester.selectedIndex].value;
	if(printRef == '0') {
		pgLoc = "../../../enrollment/advising/gen_advised_schedule_print_cit.jsp"+pgLoc;
	}
	if(printRef == '1') {
		pgLoc = "../../../fee_assess_pay/payment/re_print_assessment.jsp"+pgLoc+"&temp_sl=1";
	}
	if(printRef == '2') {
		pgLoc = "../../../fee_assess_pay/payment/re_print_assessment.jsp"+pgLoc+"&from_admission=1";
	}
	if(printRef == '3') {
		pgLoc = "../../../fee_assess_pay/payment/re_print_assessment.jsp"+pgLoc+"&prevent_forward=1";
	}

	var win=window.open(pgLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function updateSYIfDefaultIsSummer() {
	<%
	if(!strDefaultTerm.equals("0")){%>
		return;
	<%}%>
	//increment sy if term changed from summer to regular sem.
	if(document.form_.semester.selectedIndex == 1) {
		document.form_.sy_from.value = "<%=Integer.parseInt(strSYFrom) + 1%>";
		document.form_.sy_to.value = "<%=Integer.parseInt(strSYTo) + 1%>";
	}

}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<form name="form_" action="./cit_main.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A" align="center"><font color="#FFFFFF" ><strong>::::
       STUDENT LOAD PRINT PAGE ::::</strong></font></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr valign="top">
    <td height="25">&nbsp;</td>
    <td>Student ID </td>
    <td>&nbsp;</td>
    <td>
	<input name="stud_id" type="text" size="20" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');" autocomplete="off">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>	</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>SY/Term</td>
    <td>&nbsp;</td>
    <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester" onChange="updateSYIfDefaultIsSummer();">
          <option value="0">Summer</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
	
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd Sem</option>
        </select>		</td>
  </tr>
  <tr>
    <td height="25" width="12%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%">&nbsp;</td>
  </tr>
<%if(strSchCode.startsWith("CIT")){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="javascript:PrintPg('0')">Print Student Enrollment Form</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="javascript:PrintPg('1')">Print Temporary Study Load</a></td>
  </tr>
<%}%>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="javascript:PrintPg('2')">Print Official Study Load</a></td>
  </tr>
<%if(!strSchCode.startsWith("SWU")) {%>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="javascript:PrintPg('3')">Print Assessment Detail</a></td>
  </tr>
<%}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr> 
    <td height="25" width="1%">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></td>
  <tr bgcolor="#A49A6A"> 
    <td width="50%" colspan="3">&nbsp;</td>
  </tr>
</table>
</form>
</body>
</html>
