<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function focusOnGrade()
{
	document.form_.stud_id.focus();
}
function ViewResidency()
{
	var strStudID = document.form_.stud_id.value;
	if(strStudID.length == 0)
	{
		alert("Please enter student ID.");
		return;
	}
	location = "../residency/residency_status.jsp?stud_id="+escape(strStudID);
}
function ReloadPage()
{
	document.form_.deleteRecord.value = 0;
	document.form_.addRecord.value = 0;
	document.form_.submit();
}
function AddRecord()
{
	document.form_.deleteRecord.value = 0;
	document.form_.addRecord.value = 1;

	//get the remark name,
	document.form_.remarkName.value = document.form_.remark_index[document.form_.remark_index.selectedIndex].text;
//	alert(document.form_.remarkName.value);
	document.form_.submit();
}
function DeleteRecord(strTargetIndex)
{
	document.form_.deleteRecord.value = 1;
	document.form_.addRecord.value = 0;

	document.form_.info_index.value = strTargetIndex;

	document.form_.submit();
}
function DisplaySYTo() {
	var strSYFrom = document.form_.sy_from.value;
	if(strSYFrom.length == 4)
		document.form_.sy_to.value = eval(strSYFrom) + 1;
	if(strSYFrom.length < 4)
		document.form_.sy_to.value = "";
}

// for AUF / CGH ONLY!!!

var iFailedSelectedIndex = -1;
var iPassedSelectedIndex = -1;
function GetFailedSelectedIndex(){
	for (v= document.form_.remark_index.length -1 ; v >= 0; --v){
		if (eval("document.form_.remark_index[" + v + "].text").toLowerCase().indexOf('fail') != -1)
			return v;
	}

}
function GetPassedSelectedIndex(strRemark){
	for (v= document.form_.remark_index.length -1 ; v >= 0; --v){
		if (eval("document.form_.remark_index[" + v + "].text").toLowerCase().indexOf('pass') != -1)
			return v;
	}

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
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

function CopyInternshipPlace() {
	var iSelIndex = document.form_.copy_place.selectedIndex;
	if(iSelIndex == 0)
		document.form_.internship_place.value = '';
	else	
		document.form_.internship_place.value = document.form_.copy_place[document.form_.copy_place.selectedIndex].text;
}
//I have to now make sure it copies
function CopyInternshipPlace2() {
	document.form_.i_place.value = "";
	document.form_.i_hosp.value = "";
	
	var iPlace = document.form_.i_place_sel[document.form_.i_place_sel.selectedIndex].value;
	var iHosp = document.form_.i_hosp_sel[document.form_.i_hosp_sel.selectedIndex].value;
	
	if(iPlace.length > 0) {
		document.form_.internship_place.value =iHosp + "<br>"+ iPlace;
	}
	
}
function CopyInternshipPlace3() {
	var iPlace = document.form_.i_place.value;
	var iHosp  = document.form_.i_hosp.value;
	
	if(iPlace.length > 0) {
		document.form_.internship_place.value =iHosp + "<br>"+ iPlace;
	}
}

</script>
<body bgcolor="#D2AE72" onLoad="focusOnGrade();">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.OfflineAdmission,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg    = null;
	String strTemp      = null;
	String strUserIndex = null;
	
	Vector vTemp = null;
	
	String strCourseType = null;//0->Under graduate, 1->Doctoral, 2-> doctor of medicine, 3-> with proper, 4-> non semestral.
	Vector vStudInfo = null;
	String strSQLQuery = null;
	
	int i = 0;
	int j = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-VERY OLD STUDENT DATA MANAGEMENT","very_old_stud_data_entry.jsp");
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
														"Registrar Management","OLD STUDENT DATA MANAGEMENT",request.getRemoteAddr(),
														"very_old_stud_data_entry.jsp");
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




boolean bolIsCGH = false;
%>


<form action="./very_old_stud_data_entry.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>::::
          OLD STUDENT DATA MANAGEMENT ::::<br>
          </strong>(Encoding of old student's academic records)</font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
	  <td width="2%" height="25">&nbsp;</td>
      <td width="96%"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 9);
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%}%>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%">Student ID</td>
      <td width="18%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">      </td>
      <td width="69%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:fixed"></label></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%">SY /Term : </td>
      <td colspan="2"><input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="DisplaySYTo();">
        to
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
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
        </select> <font size="1">&nbsp; </font></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input type="button" onClick="CheckStudent();" value="&nbsp;&nbsp; Proceed &nbsp;&nbsp; "></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:14px; font-weight:bold;"><u>Create Student SY-Term Information</u></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Year Level </td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input type="button" onClick="CheckStudent();" value="&nbsp;&nbsp; Create Information &nbsp;&nbsp; "></td>
    </tr>
    <tr >
      <td  colspan="4" height="25"><hr size="1"></td>
    </tr>
  </table>
<%if(vStudInfo != null && vStudInfo.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td height="25">&nbsp;</td>
      <td>Student Name : <strong><%%></strong></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td>Course/Major (curriculum year) <font size="1"><strong>NOTE:</strong>
        To edit course or curriculm please edit student's information.</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong><%=(String)vStudInfo.elementAt(7)%>
        <%
	  if((String)vStudInfo.elementAt(8) != null){%>
        /<%=(String)vStudInfo.elementAt(8)%>
        <%}%>
        (<%=(String)vStudInfo.elementAt(3)+" - "+ (String)vStudInfo.elementAt(4)%>)</strong></td>
</tr>
<tr>
	<td colspan="2"><hr size="1"></td>
</tr>
  </table>
<%
if(false) {
String strSubIndex = null;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%">&nbsp;</td>
      <td colspan="2"><font size="1"><strong><%=strErrMsg%></strong> &nbsp;&nbsp;
        <a href="javascript:ViewResidency();"><img src="../../../images/view.gif" border="0"></a>click
        to view Residency status of student</font></td>
    </tr>
  </table>
<%
if(vTemp != null)
{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="7" ><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25" >&nbsp;</td>
      <td width="41%"  height="25" ><div align="left"><font size="1">
          <%if(WI.fillTextValue("is_internship").compareTo("1") == 0){%>
          <input name="is_internship" type="checkbox" value="1" checked onClick="ReloadPage();">
          <%}else{%>
          <input name="is_internship" type="checkbox" value="1" onClick="ReloadPage();">
          <%}%>
          (check if INTERNSHIP/CLERKSHIP/CADETSHIP subject) <strong><br>
          SUBJECT CODE</strong></font></div></td>
      <td width="9%" ><strong><font size="1">UNIT</font></strong></td>
      <td width="14%" ><div align="left"><font size="1"><strong>CREDITS EARNED</strong></font></div></td>
      <td width="9%" ><center>
        <font size="1"><strong>GRADE </strong></font>
      </center>      </td>
<%if(bolIsCGH){%>
      <td width="9%" ><center>
        <font size="1"><strong>REMARKS</strong></font>
      </center>      </td>
<%}%>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" ><select name="subject" onChange="ReloadPage();">
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i+1)%></option>

        </select></td>
      <td valign="top"><input name="credit_earned" type="text" size="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=fCredit%>"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td valign="top">
<%
	if (strSchCode.startsWith("AUF") || strSchCode.startsWith("CGH"))
		strTemp = "UpdateRemarks('grade');";
	else
		strTemp = "";
%>
	  <input name="grade" type="text" size="4" maxlength="5" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="<%=strTemp%>style.backgroundColor='white'"
	  onKeyPress="if(event.keyCode == 115 || event.keyCode ==83 || event.keyCode == 47) event.returnValue=true; else if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
<%if(bolIsCGH){%>
      <td align="center"><input name="grade_percent" type="text" size="3" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';UpdateRemarks('grade_percent');"
	  	  onKeyUp="AllowOnlyFloat('form_','grade_percent');"></td>
<%}%>
      <td valign="top"><select name="remark_index">
          <%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("remark_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td></td>
      <td colspan="6">Subject Title : <%=strSubName%></td>
    </tr>

<%if(WI.fillTextValue("is_internship").compareTo("1") ==0){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="5" >Inclusive date of internship/clerkship :
        <input name="internship_date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("internship_date_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.internship_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;&nbsp;to
        &nbsp;&nbsp; <input name="internship_date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("internship_date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.internship_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;</td>
    </tr>
<%if(strSchCode.startsWith("AUF")){%>
    <tr bgcolor="#DDDDDD">
      <td height="25" class="thinborderTOPLEFT">&nbsp;</td>
      <td  height="25" colspan="5" style="font-size:11px;" class="thinborderTOPRIGHT">Hospital Name :<select name="i_hosp_sel" onChange="CopyInternshipPlace2();" style="width:392px;">
	  <option value="">Select to copy</option>
<%=dbOP.loadCombo("HOSP_NAME","HOSP_NAME"," from INTERNSHIP_HOSP_PRELOAD order by hosp_name",null, false)%>
	  </select>
	  &nbsp;&nbsp;&nbsp;
	  Place :<select name="i_place_sel" onChange="CopyInternshipPlace2();" style="width:250px;">
	  <option value="">Select to copy</option>
<%=dbOP.loadCombo("IPLACE","IPLACE"," from INTERNSHIP_PLACE_PRELOAD order by IPLACE",null, false)%>
	  </select>	</td>
    </tr>
    <tr bgcolor="#DDDDDD">
      <td height="25" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td  height="25" colspan="5" style="font-size:11px;" class="thinborderBOTTOMRIGHT">(or) Enter Hospital Name : 
	  <input name="i_hosp" type="text" size="60" maxlength="92" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="CopyInternshipPlace3();style.backgroundColor='white'">
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;
	  Place : 
	  <input name="i_place" type="text" size="32" maxlength="32" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="CopyInternshipPlace3();style.backgroundColor='white'">	  </td>
    </tr>

<%}else{%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="5" >	  <select name="copy_place" onChange="CopyInternshipPlace();">
	  <option value="">Select to copy</option>
<%=dbOP.loadCombo("distinct INTERNSHIP_PLACE","INTERNSHIP_PLACE"," from g_sheet_final where INTERNSHIP_PLACE is not null",null, false)%>
	  </select>	</td>
    </tr>
<%}%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="5" >Hospital Name and place taken :
        <input name="internship_place" type="text" size="60" maxlength="128" value="<%=WI.fillTextValue("internship_place")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">(Note : add &lt;br&gt; for 2nd line)</font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="5" >Duration :
        <input name="internship_dur" type="text" size="5" value="<%=WI.fillTextValue("internship_dur")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <select name="internship_dur_unit">
          <option value="0">Hours</option>
<%
strTemp = WI.fillTextValue("internship_dur_unit");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Weeks</option>
<%}else{%>
          <option value="1">Weeks</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Months</option>
<%}else{%>          <option value="2">Months</option>
<%}%>        </select></td>
    </tr>
<%}%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" >&nbsp;</td>
      <td  colspan="4" > <div align="left"> <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click
          to add</font> </div></td>
    </tr>
  </table>
<%
//get here the list of grade created already for this year/sem course
	vTemp = GS.viewFinalGradePerYrSem(dbOP, request);
	//System.out.println(GS.getErrMsg());
	if(vTemp != null && vTemp.size() > 0)
	{%>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="11" bgcolor="#B9B292" class="thinborder"><div align="center">LIST OF
          GRADE FOR <%=WI.getStrValue(request.getParameter("year"),"(N/A)")%>
          YEAR- <%=request.getParameter("semester")%> SEM
          <%
		  if(request.getParameter("is_internship") != null && request.getParameter("is_internship").compareTo("1") ==0) //it is internship
          {%>
          <strong>(Internship)</strong>
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td width="16%"  height="25" class="thinborder"><font size="1"><strong>SUBJECT
          CODE</strong></font></td>
      <td width="30%" class="thinborder"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="7%" class="thinborder"><font size="1"><strong>UNIT</strong></font></td>
      <td width="7%" class="thinborder"><font size="1"><strong>CREDITS EARNED</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong> GRADE<%if(bolIsCGH){%><br>FP<%}%></strong></font></td>
<%if(bolIsCGH){%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>GRADE <br>%ge</strong></font></td>
<%}%>
      <td width="12%" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
      <td width="10%" class="thinborder"><font size="1"><strong>Encoded By</strong></font></td>
      <td width="10%" class="thinborder"><font size="1"><strong>Date Encoded</strong></font></td>
      <td width="7%" class="thinborder">&nbsp;</td>
    </tr>
    <%//System.out.println(vTemp);
	int p=0;
	for(i=0; i< vTemp.size(); ++i,++p)
	{//System.out.println((String)vTemp.elementAt(3) + " : "+(String)vTemp.elementAt(4));
	fCredit  = Float.parseFloat(WI.getStrValue(vTemp.elementAt(i+3),"0"))+Float.parseFloat(WI.getStrValue(vTemp.elementAt(i+4),"0"));
	
	iIndexOf = vGradeEncodingInfo.indexOf(new Integer((String)vTemp.elementAt(i)));
	if(iIndexOf == -1) {
		strTemp = null;
		strErrMsg = null;
	}
	else {
		strTemp = (String)vGradeEncodingInfo.elementAt(iIndexOf + 1);
		strErrMsg = (String)vGradeEncodingInfo.elementAt(iIndexOf + 3);
	}
	
	%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vTemp.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+2)%></td>
      <td class="thinborder"><%=fCredit%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+7)%></td>
      <td class="thinborder">
        <%//Display F for failed grade.
	  //if( ((String)vTemp.elementAt(i+6)).toLowerCase().indexOf("fail") != -1){%>
        <!--F-->
        <%//}else{%>
        <%=(String)vTemp.elementAt(i+5)%>
        <%//}%>		</td>
<%if(bolIsCGH){%>
      <td class="thinborder"><font size="1"><%=WI.getStrValue(GS.vCGHGrade.elementAt(p * 2 + 1))%></font>&nbsp;</td>
<%}%>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+6)%></td>
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strErrMsg, "&nbsp;")%></td>
      <td class="thinborder"> <a href='javascript:DeleteRecord("<%=(String)vTemp.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></td>
    </tr>
<%
if(vTemp.elementAt(i+8) != null){%>
    <tr>
      <td height="15" colspan="10" class="thinborder">&nbsp; <font size="1"><%=(String)vTemp.elementAt(i + 8)%></font></td>
    </tr>
    <%}
	i = i+8;
}%>
  </table>
 <%
 	}//if(strCYFrom.length()>0)
  }//if subject list is not null;
 }//if vTemp !=null - student is having grade created already.
}//biggest loop == only if the Proceed for Student id is cliecked - checkStudent.compareTo("1") ==0
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="remarkName">
<input type="hidden" name="course_type" value="<%=strCourseType%>">


<script language="javascript">
<%
//I have to add here converting grade from percent to final point.
Vector vGradeSystem = GS.viewAllGrade(dbOP, request);
if(vGradeSystem != null){%>
function CovertGrade(){
	var bolError = false;
	var gradeEncoded   = ""; var gradeEquivalent = "";
	gradeEncoded = document.form_.grade_percent.value;
	if(gradeEncoded.length == 0)
		return;
	gradeEquivalent = "";
	<%//double dGrade = 100d;
	for(int p =0; p < vGradeSystem.size(); p += 7){	%>
		<%if(p > 0){%>else <%}%>if(gradeEncoded >= <%=(String)vGradeSystem.elementAt(p + 2)%> &&
			gradeEncoded <= <%=(String)vGradeSystem.elementAt(p + 3)%>)//for 80.5 grade - faculties giving grade in point :-|
				gradeEquivalent = <%=(String)vGradeSystem.elementAt(p + 1)%>;
		<%}//System.out.println(dGrade);%>
		//if grade equivalent is having final point, change it, else continue;

	if(gradeEquivalent.length == 0) {
		bolError = true;
	}
	else
		document.form_.grade.value=gradeEquivalent;

	if(bolError)
		alert("Error in converting grade. Please check grade encoded.");

}
<%}else{%>
function CovertGrade(){
	alert("Grade system is not set. Please check link :: Grade System :: and fill up the grade system.");
	return;
}
<%}%>

function UpdateRemarks(strGradeFieldName){
	var vGrade = "";
	eval('vGrade=document.form_.'+strGradeFieldName+'.value');

	if(vGrade.length == 0 || vGrade <= 5)
		return;

/**
	if (vGrade <60 || vGrade > 100){
		alert (" Invalid grade");
//		eval("document.form_."+strGrade+".focus()");
//		eval("document.form_."+strGrade+".select()");
		return;
	}

**/
	if (vGrade < 75){
		if (iFailedSelectedIndex == -1)
			iFailedSelectedIndex = GetFailedSelectedIndex();
		document.form_.remark_index.selectedIndex = iFailedSelectedIndex;
	}
	else if (vGrade >= 75){
		if (iPassedSelectedIndex == -1)
			iPassedSelectedIndex = GetPassedSelectedIndex();
		document.form_.remark_index.selectedIndex = iPassedSelectedIndex;
	}
	<%if(bolIsCGH){%>
		this.CovertGrade();
	<%}%>

}

</script>


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
