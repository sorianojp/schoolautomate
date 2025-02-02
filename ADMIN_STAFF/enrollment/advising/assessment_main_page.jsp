<%@ page language="java" import="utility.*" %>
<%
String strTemp = (String)request.getSession(false).getAttribute("school_code");
if(strTemp == null)
	strTemp = "";
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintEnrollmentForm() {
	var studID = '';
	if(document.form_.stud_id && document.form_.stud_id.value.length > 0)
		studID = document.form_.stud_id.value;
	else
		studID =  prompt("Please enter Student's ID.", "Temp/ perm ID.");
	if(studID == null || studID == '')
		return;
	if(studID.length == 0)  {
		alert("Failed to process request. Stud. ID is empty.");
		return;
	}

	var win=window.open("./gen_advised_schedule_print.jsp?stud_id="+studID,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AjaxMapName(strRef, e) {
	if(e.keyCode == 13) {
		this.PrintEnrollmentForm();
		return;
	}
	var strSearchCon = "&search_temp=2";
	var strCompleteName;
	strCompleteName = document.form_.stud_id.value;
	if(strCompleteName.length <3)
		return;
	var objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
	//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	document.form_.stud_id.focus();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<body bgcolor="#D2AE72">
<form name="form_" action="./assessment_main_page.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
        ENROLLMENT - ASSESSMENT MAIN PAGE ::::</strong></font></div></td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25"><a href="javascript:OpenSearch();">Search student</a></td>
  </tr>
<%if(!strTemp.startsWith("CDD")){%>
  <tr>
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="javascript:PrintEnrollmentForm();">Print Enrollment Form </a>
	<%if(strTemp.startsWith("SPC")){%>
		&nbsp;&nbsp;&nbsp;&nbsp;<input name="stud_id" type="text" size="20" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1', event);">
	  
	  <label id="coa_info" style="position:absolute; width:400px;"></label>
	  <input type="text" size="0" class="textbox_noborder">
	<%}%>
	</td>
  </tr>
<%}%>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td><a href="../../registrar/student_ids/validate_and_print_reg_form.jsp">Print Registration Form </a></td>
  </tr>
<%
if(strTemp.startsWith("AUF") || strTemp.startsWith("CGH") || strTemp.startsWith("CPU") || strTemp.startsWith("PHILCST") || strTemp.startsWith("UL") || 
	strTemp.startsWith("CLDH") || strTemp.startsWith("UDMC") || strTemp.startsWith("VMUF") || strTemp.startsWith("CSA") || strTemp.startsWith("CDD") || 
	strTemp.startsWith("FATIMA") || strTemp.startsWith("EAC") || strTemp.startsWith("VMA") || strTemp.startsWith("PWC")){
%>  <tr>
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%" align="center"><div align="left"><a href="./assessment_optional_fee.jsp">Edit/Add/Delete Optional Fee Charging</a> </div></td>
  </tr>
<%if(strTemp.startsWith("PHILCST") || strTemp.startsWith("UL") || strTemp.startsWith("CSA") || 
	strTemp.startsWith("FATIMA") || strTemp.startsWith("EAC") || strTemp.startsWith("CDD") || strTemp.startsWith("VMA") ){%>
<tr>
  <td height="25">&nbsp;</td>
  <td height="25">&nbsp;</td>
  <td>&nbsp;</td>
  <td><a href="./assessment_fee_exclude.jsp">Exclude Misc/Other charges from Assessment</a></td>
</tr>
<%}

}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" width="1%">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></td>
  </tr>
  <tr bgcolor="#A49A6A">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
</form>
</body>
</html>
