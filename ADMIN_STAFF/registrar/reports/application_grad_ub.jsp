<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
TD.thinborderrtb {
    border-top: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
   TD.thinborderrb {
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderb {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

</style>

<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintPg(strPrint) {
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

	
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myID1');
	obj.deleteRow(0);
//	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myID2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);	
	obj1.deleteRow(0);	
	obj1.deleteRow(0);	
	obj1.deleteRow(0);	
	obj1.deleteRow(0);	
	obj1.deleteRow(0);	
	obj1.deleteRow(0);	
	obj1.deleteRow(0);	
	obj1.deleteRow(0);	
	obj1.deleteRow(0);	
	
	document.getElementById('myID3').deleteRow(0);
	document.getElementById('myID3').deleteRow(0);
	
	document.getElementById('myID4').deleteRow(0);
	//document.getElementById('myID4').deleteRow(0);
	
	//alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
	
}
function FocusID() {
	document.form_.stud_id.focus();
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
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

function DisplaySYTo() {
	var strSYFrom = document.form_.sy_from.value;
	if(strSYFrom.length == 4){
		document.form_.sy_to.value = eval(strSYFrom) + 1;
		document.form_.date_yyyy.value = eval(strSYFrom) + 1;
	}	
	if(strSYFrom.length < 4){
		document.form_.sy_to.value = "";
		document.form_.date_yyyy.value = "";
	}
}
function AddRecord() {
	document.form_.add_record.value ='1';
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72" onLoad="FocusID();" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strReligion 	   = null;
	String strSpouse 	   = null;
	String strDegreeType = null;
	java.sql.ResultSet rs = null;
	String strSQLQuery = null;
	
	WebInterface WI = new WebInterface(request);
	String strDeanName = null;//I have to find.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-application for graduation","application_grad_ub.jsp");
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
														"application_grad_ub.jsp");
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
enrollment.EntranceNGraduationData eData = new enrollment.EntranceNGraduationData();
student.StudentInfo studInfo = new student.StudentInfo();
ReportEnrollment reportEnrl= new ReportEnrollment();

Vector vStudInfo = null;
Vector vForm18Info = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vRetResult = null;
Vector vStudDetail= null;


if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		//get dean name here.
		strDeanName = dbOP.mapOneToOther("course_offered join college on (college.c_index = course_offered.c_index)",
						"course_index",(String)vStudInfo.elementAt(5),"DEAN_NAME",null);
						
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
		vEntranceData = eData.operateOnEntranceData(dbOP, request,4);
		if(vEntranceData == null)
			strErrMsg = eData.getErrMsg();
	}
	
	strReligion = "select religion,spouse_name from info_personal where user_index = "+(String)vStudInfo.elementAt(12);
rs = dbOP.executeQuery(strReligion);
if(rs.next()){
	strReligion = rs.getString(1);
	strSpouse = rs.getString(2);
}rs.close();

}

//save encoded information if save is clicked.
if(WI.fillTextValue("add_record").compareTo("1") ==0){
	if(repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,1,false) == null)
		strErrMsg = repRegistrar.getErrMsg();
}
vForm18Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,false);
if(vForm18Info != null && vForm18Info.size() ==0)
	vForm18Info = null;

vRetResult = reportEnrl.getStudentLoad(dbOP, request.getParameter("stud_id"),request.getParameter("sy_from"),
							request.getParameter("sy_to"),request.getParameter("semester"));

	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();
	else
		vStudDetail = (Vector)vRetResult.elementAt(0);
	
	
%>
<form action="./application_grad_ub.jsp" name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td height="20" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          RECORDS OF APPLICATION FOR GRADUATION PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myID2">
    <tr>
      <td height="20" colspan="8">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr valign="top">
      <td width="1%" height="20">&nbsp;</td>
      <td width="18%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="3%"><label id="coa_info" style="font-size:11px; position:absolute; font-weight:bold; color:#0000FF"></label></td>
      <td colspan="3">&nbsp;</td>
      <td width="16%">&nbsp;</td>
    </tr>
    <tr valign="top">
      <td height="20">&nbsp;</td>
      <td>School Year</td>
      <td colspan="3"><%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	  
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="DisplaySYTo();">
to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");	  
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td width="4%">Term</td>
      <td width="34%"><select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
if(strTemp == null) 
	strTemp = "";
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr valign="top">
      <td height="20">&nbsp;</td>
      <td>Student ID </td>
      <td><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td colspan="2"></td>
      <td><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td><input name="image" type="image" src="../../../images/form_proceed.gif" onClick="RemovePrintPg();"></td>
      <td>&nbsp;</td>
    </tr>
    <tr valign="top">
      <td height="20">&nbsp;</td>
      <td>Date of Graduation</td>
      <td colspan="6"><select name="date_mm">
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
    <tr valign="top">
      <td height="20">&nbsp;</td>
      <td>Registrar's Name</td>
      <td colspan="6"><%
if(vForm18Info != null)
	strTemp = (String)vForm18Info.elementAt(0);
else
	strTemp = WI.fillTextValue("registrar_name");
%>
        <input name="registrar_name" type="text" size="64" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr valign="top">
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="6"><font size="1">(complete name, degree titles)</font></td>
    </tr>
    <tr valign="top">
      <td height="20">&nbsp;</td>
      <td>Dean's Name</td>
      <td colspan="6"><input name="dean_name" type="text" size="64" value="<%=WI.getStrValue(strDeanName)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr valign="top">
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="6"><font size="1">(complete name, degree titles)</font> </td>
    </tr>
    <tr valign="top">
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="5"><a href="javascript:AddRecord();">
	  <img src="../../../images/save.gif" border="0" name="hide_save"></a>
        Click to save/edit registrar's name.</td>
      <td align="right">
	  <%
	  if(vStudInfo != null && vStudInfo.size() > 0){%>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
        <font size="1">Print report</font>
	  <%}%>
	  </td>
    </tr>
      <tr>
      <td height="20" colspan="8"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0 && vRetResult != null && vRetResult.size() > 0){%>
<br />
<table width="100%"  bgcolor="#FFFFFF"border="0" cellspacing="0" cellpadding="0">

  <tr>
    <td colspan="2"><div align="center"><font size="2"><strong><font size="4" face="Courier New, Courier, monospace">UNIVERSITY OF BOHOL</font></strong><br>
      <strong><font size="2" face="Courier New, Courier, monospace">TAGBILARAN CITY, BOHOL </font></strong>      <br>        
        <strong>OFFICE OF THE REGISTRAR<br/> 
        APPLICATION FOR GRADUATION</strong></font></div></td>
  </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="2">&nbsp;</td>
      <td colspan="6">&nbsp;</td>
    </tr>
    <tr>
      <td width="1%" height="20">&nbsp;</td>
      <td width="20%" class="thinborderrtb"><strong><font size="1">NAME:</font></strong> </td>
      <td width="18" colspan="2" class="thinborderTOPBOTTOM"><strong><font size="1"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></font></strong></td>
      <td width="20%" class="thinborderTOPBOTTOM"><strong><font size="1"><%=((String)vStudInfo.elementAt(0)).toUpperCase()%></font></strong></td>
      <td width="23%" class="thinborderrtb"><strong><font size="1"><%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></font></strong></td>
      <td width="18%" class="thinborderTOPBOTTOM"><font size="1">&nbsp;Date Filed:</font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb">&nbsp;</td>
      <td colspan="2" valign="top" class="thinborderb">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="1" style="font-style:italic">(Last Name)</font></td>
      <td valign="top" class="thinborderb">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="1" style="font-style:italic">(First Name)</font></td>
      <td valign="top" class="thinborderrb">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="1" style="font-style:italic">(Middle Name)</font></td>
      <td valign="top" class="thinborderb"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getTodaysDate(1)%></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb"><strong><font size="1">STUDENT #:</font></strong></td>
      <td colspan="4" class="thinborderrb"><font size="1">&nbsp;<strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong></font></td>
      <td class="thinborderb"><font size="1" >&nbsp;Date of Graduation:</font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb"><font size="1"><strong>ADDRESS:</strong></font></td>
<%
if(vAdditionalInfo != null && vAdditionalInfo.size() > 0 && vAdditionalInfo.elementAt(3) != null) {
	strTemp =WI.getStrValue((String)vAdditionalInfo.elementAt(3))+" "+WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")+" "+
			WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")+" "+WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")+" "+
			WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","");
}
else
	strTemp = "&nbsp;";
%>
      <td colspan="4" class="thinborderrb"><font size="1">&nbsp;<strong><%=strTemp%></strong></font></td>
      <td class="thinborderb"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.fillTextValue("date_grad")%><%=WI.fillTextValue("date_mm")%>&nbsp;<%=WI.fillTextValue("date_yyyy")%></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb"><font size="1"><strong>CITIZENSHIP:</strong></font></td>
      <td colspan="5" class="thinborderb"><font size="1">&nbsp;<%=WI.getStrValue((String)vStudInfo.elementAt(23), "&nbsp;").toUpperCase()%></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb"><font size="1"><strong>CIVIL STATUS:</strong></font></td>
<%
if(vAdditionalInfo != null && vAdditionalInfo.size() > 0 && vAdditionalInfo.elementAt(3) != null) {
	strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(12)).toUpperCase();
}
else
	strTemp = "&nbsp;";
%>
      <td colspan="5" class="thinborderb"><font size="1">&nbsp;<%=strTemp%></font></td>
    </tr>
    <tr>
	<%
	strTemp = (String)vStudInfo.elementAt(16);
	if(strTemp.equals("M"))
		strTemp = "MALE";
	else
		strTemp = "FEMALE";
	%>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb"><font size="1"><strong>SEX:</strong></font></td>
      <td colspan="5" class="thinborderb"><font size="1">&nbsp;<%=strTemp%></font></td>
    </tr>
    <tr>
	<%
		if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
			strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1)).toUpperCase();
		else
			strTemp = "&nbsp;";
	%>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb"><font size="1"><strong>DATE OF BIRTH:</strong></font></td>
      <td colspan="5" class="thinborderb"><font size="1">&nbsp;<%=strTemp%></font></td>
    </tr>
    <tr>
	<%
		strTemp = "&nbsp;";
		if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
			strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2)).toUpperCase();
		
	%>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb"><font size="1"><strong>PLACE OF BIRTH:</strong></font></td>
      <td colspan="5" class="thinborderb"><font size="1">&nbsp;<%=strTemp%></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb"><font size="1"><strong>RELIGION:</strong></font></td>
      <td colspan="5" class="thinborderb"><font size="1">&nbsp;<%=WI.getStrValue(strReligion).toUpperCase()%></font></td>
    </tr>
	<%
		if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
			strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(8)).toUpperCase();
		else
			strTemp = "&nbsp;";
	%>
    <tr>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb"><font size="1"><strong>FATHER:</strong></font></td>
      <td colspan="5" class="thinborderb"><font size="1">&nbsp;<%=strTemp%></font></td>
    </tr>
	<%
		if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
			strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(9)).toUpperCase();
		else
			strTemp = "&nbsp;";
	%>
    <tr>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb"><font size="1"><strong>MOTHER:</strong></font></td>
      <td colspan="5" class="thinborderb"><font size="1">&nbsp;<%=strTemp%></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td class="thinborderrb"><font size="1"><strong>SPOUSE:</strong></font></td>
      <td colspan="5" class="thinborderb"><font size="1">&nbsp;<%=WI.getStrValue(strSpouse).toUpperCase()%></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="6" class="thinborderb">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="6" class="thinborderb"><font size="1"><strong>CANDIDATE FOR GRADUATION OF: (Course) </strong></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="6" class="thinborderb"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;<%=((String)vStudInfo.elementAt(7)).toUpperCase()%></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="4" class="thinborderrb"><font size="1"><strong>Major in:</strong> <%=WI.getStrValue(vStudInfo.elementAt(8)," ").toUpperCase()%></font></td>
      <td colspan="2" class="thinborderb"><font size="1"><strong>Minor in: </strong></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="4" class="thinborderrb"><font size="1"><strong>TITLE OF THESIS(for graduate studies only): </strong></font></td>
      <td colspan="2" class="thinborderb">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="6" class="thinborderb">&nbsp;</td>
    </tr>
    
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="6" class="thinborderb">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="2" class="thinborderrb"><font size="1"><strong>PRELIMINARY EDUCATION:</strong></font></td>
      <td colspan="3" align="center" class="thinborderrb"><font size="1"><strong>Name of School</strong></font></td>
      <td align="center" class="thinborderb"><font size="1" ><strong>Year Graduated</strong></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="2" class="thinborderrb"><font size="1"><strong>Elementary:</strong></font></td>
	  <%
			if(vEntranceData != null)
				strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
			else	
				strTemp = "&nbsp;"; 
		%>	
      <td colspan="3" class="thinborderrb"><font size="1">&nbsp;&nbsp;<%=strTemp%></font></td>
 	  <%
			if(vEntranceData != null)
				strTemp = WI.getStrValue((String)vEntranceData.elementAt(20));
			else	
				strTemp = "&nbsp;"; 
		%>	
     <td align="center" class="thinborderb"><font size="1"><%=strTemp%></font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="2" class="thinborderrb"><font size="1"><strong>Secondary:</strong></font></td>
 	  <%
			if(vEntranceData != null)
				strTemp = WI.getStrValue((String)vEntranceData.elementAt(5));
			else	
				strTemp = "&nbsp;"; 
		%>	
      <td colspan="3" class="thinborderrb"><font size="1">&nbsp;&nbsp;<%=strTemp%></font></td>
  	  <%
			if(vEntranceData != null)
				strTemp = WI.getStrValue((String)vEntranceData.elementAt(22));
			else	
				strTemp = "&nbsp;"; 
		%>	
     <td align="center" class="thinborderb"><font size="1"><%=strTemp%></font></td>
    </tr>
    <tr>
      <td height="20" colspan="7">&nbsp;</td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
 


<table width="100%" bgcolor="#FFFFFF"  border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="50%" valign="top">
			<%if(vRetResult.size() > 0){%>
			<table width="79%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="17%" height="20" align="center"></td>
					<td width="48%" align="center"><strong><u><font size="1">SUBJECTS</font></u></strong></td>
					<td width="35%" align="center"><strong><u><font size="1">UNITS</font></u></strong></td>
				</tr>
				
		   <%
					
					 float fTotalLoad = 0;
					 for(int i=1; i< vRetResult.size(); i++){
						 if( !((String)vRetResult.elementAt(i+9)).startsWith("("))
					  		fTotalLoad += Float.parseFloat((String)vRetResult.elementAt(i+9));
					 %>
				<tr>
					<td valign="bottom">
				  </td>
			
					<td valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%;"><font size="1">&nbsp; &nbsp;<%=(String)vRetResult.elementAt(i)%></font></div></td>
					<td valign="bottom" align="right" height="22">
						<div style="border-bottom:solid 1px #000000; text-align:center; width:90%;"><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></div></td>
				</tr>
				<%
				i = i+10;
				}
			%>
		  </table>
			<%}else{%>&nbsp;<%}%>
	  </td>
		
		<td width="2%" valign="top"></td>
		<td width="48%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr><td colspan="2">&nbsp;</td></tr>
					<tr>
					  <td colspan="2">&nbsp;</td>
			  </tr>
					<tr>
					  <td width="26%">&nbsp;</td>
					<%
					strTemp = WebInterface.formatName((String)vStudInfo.elementAt(0), (String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),7);
					%>
			          <td width="72%" height="20" align="center"><strong><font size="1"><%=strTemp.toUpperCase()%></font></strong></td>
			  </tr>
					<tr>
					  <td height="20">&nbsp;</td>
					
			          <td align="center"><font style="font-style:italic" size="1">Name and Signature of Applicant </font></td>
			  </tr>
					<tr>
					  <td></td>
					  <td height="20" align="center"></td>
			  </tr>
					<tr><td></td>
					<%
					strTemp = " select fname, mname, lname from INFO_FACULTY_BASIC "+
						" join HR_EMPLOYMENT_TYPE  on (HR_EMPLOYMENT_TYPE .EMP_TYPE_INDEX = INFO_FACULTY_BASIC.EMP_TYPE_INDEX) "+
						" join USER_TABLE on (USER_TABLE.USER_INDEX = INFO_FACULTY_BASIC.USER_INDEX) "+
						" where EMP_TYPE_NAME like 'Alumni Officer%' "+
						" and INFO_FACULTY_BASIC.IS_VALID =1 "+
						" and( EXPIRE_DATE is null or EXPIRE_DATE > '"+WI.getTodaysDate()+"') ";
					rs = dbOP.executeQuery(strTemp);
					strTemp = null;
					if(rs.next())
						strTemp = WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 7);
					rs.close();
					%>
					  <td height="20" align="center" valign="bottom"><u><%=WI.getStrValue(strTemp).toUpperCase()%></u></td>
					</tr>
					<tr>
					  <td align="center" class="thinborderTOP" style="font-size:9px;" valign="top"><strong>STUDIO UNO</strong> </td>
					  <td height="20" align="center"><font size="1">Alumni Officer</font></td>
			  </tr>
					<tr>
					  <td align="center" style="font-size:9px;" valign="top">&nbsp;</td>
					  <td height="20" align="center"></td>
			  </tr>
					<tr>
					  <td align="center" style="font-size:9px;" valign="bottom"><strong><font size="1">Approved:</font></strong></td>
					  <td height="20" align="center"><font size="1"><%=WI.getStrValue(WI.fillTextValue("dean_name")).toUpperCase()%></font></td>
			  </tr>
					<tr>
					  <td align="center" style="font-size:9px;" valign="bottom">&nbsp;</td>
					  <td height="20" align="center"><font size="1">Dean</font></td>
			  </tr>
					<tr>
					  <td align="center" style="font-size:9px;" valign="bottom">&nbsp;</td>
					  <td height="20" align="center"></td>
			  </tr>
<%
strTemp = WI.fillTextValue("registrar_name");
if(strTemp.length() == 0)
	strTemp = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "university registrar",1));  
%>
					<tr>
					  <td align="center" style="font-size:9px;" valign="bottom">&nbsp;</td>
					  <td height="20" align="center"><font size="1"><%=strTemp%></font></td>
			  </tr>
					<tr>
					  <td align="center" style="font-size:9px;" valign="bottom">&nbsp;</td>
					  <td height="20" align="center"><font size="1">Registrar</font></td>
			  </tr>
			</table>
		</td>
	</tr>
</table>


<%}//end if vRetResult != null && vRetResult.size() > 0%>

<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
   <tr>
	 <td colspan="2" align="left">&nbsp;&nbsp;&nbsp;<strong><font size="1">Important:</font></strong></td>
    </tr>
   <tr>
	 <td colspan="2" align="left" height="20">&nbsp;&nbsp;&nbsp;<font size="1">All candidates for the graduation are requested to accomplished this form and file the same time at the Registrar's Office on the Semester in which &nbsp;&nbsp;&nbsp;the candidate expect to graduate.</font></td>
  </tr>
   
   <tr>
     <td colspan="2" align="left">   
  <td>  </tr>
   <tr>
     <td colspan="2" align="left">   
     <td>     </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0"  id="myID4">
    <tr>
      <td width="2%" height="20">&nbsp;</td>
      <td width="21%">&nbsp;</td>
      <td width="77%" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
        <font size="1">Click to print report&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
    </tr>
  </table>
  <input type="hidden" name="degree_type" value="<%=(String)vStudInfo.elementAt(15)%>">
<%}//only if stud info is > 0%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0" id="myID3">
  <tr>
    <td height="20" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
