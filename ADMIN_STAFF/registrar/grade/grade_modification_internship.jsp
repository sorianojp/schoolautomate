<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: block;
	margin-left: 16px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

//// - all about ajax.. 
function AjaxMapName() {
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
		return;
	var iMaxDisp = document.form_.max_disp.value;
	if(iMaxDisp.length == 0)
		return;
	var strToCopy = document.form_.copy_place[iSelIndex].value;
	var obj;
	for(var i = 0; i < iMaxDisp; ++i) {
		eval('obj = document.form_.place_'+i);
		if(!obj)
			continue;
		obj.value=strToCopy;
	}
}
//I have to now make sure it copies
function CopyInternshipPlace2() {
	document.form_.i_place.value = "";
	document.form_.i_hosp.value = "";
	
	var iPlace = document.form_.i_place_sel[document.form_.i_place_sel.selectedIndex].value;
	var iHosp = document.form_.i_hosp_sel[document.form_.i_hosp_sel.selectedIndex].value;
	
	if(iPlace.length == 0)
		return;
	var iMaxDisp = document.form_.max_disp.value;
	if(iMaxDisp.length == 0)
		return;
		
	var strToCopy = iHosp + "<br>"+ iPlace;
	var obj;
	for(var i = 0; i < iMaxDisp; ++i) {
		eval('obj = document.form_.place_'+i);
		if(!obj)
			continue;
		obj.value=strToCopy;
	}
}
function CopyInternshipPlace3() {
	var iPlace = document.form_.i_place.value;
	var iHosp  = document.form_.i_hosp.value;

	if(iPlace.length == 0)
		return;
	var iMaxDisp = document.form_.max_disp.value;
	if(iMaxDisp.length == 0)
		return;
		
	var strToCopy = iHosp + "<br>"+ iPlace;
	var obj;
	for(var i = 0; i < iMaxDisp; ++i) {
		eval('obj = document.form_.place_'+i);
		if(!obj)
			continue;
		obj.value=strToCopy;
	}
}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Modification Internship","grade_modification_internship.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Modification",request.getRemoteAddr(),
									"grade_modification_internship.jsp");
}
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

GradeSystem GS    = new GradeSystem();
Vector vStudInfo  = null;
Vector vRetResult = new Vector();
strTemp = WI.fillTextValue("page_action");

if(strTemp.length() > 0) {
	if(GS.operateOnGradeModificationInternship(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = GS.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
vRetResult = GS.operateOnGradeModificationInternship(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = GS.getErrMsg();
else {
	vStudInfo = (Vector)vRetResult.remove(0);
	if(vRetResult.size() == 0)
		strErrMsg = "No grade information found. Please encode grade information first before encoding internship information.";
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";strSchCode = "AUF";
String strSQLQuery = null;
if(WI.fillTextValue("i_hosp").length() > 0) {
	strSQLQuery = "insert into INTERNSHIP_PLACE_PRELOAD (IPLACE) values ("+WI.getInsertValueForDB(WI.fillTextValue("i_place"), true, null)+")"; 
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	strSQLQuery = "insert into INTERNSHIP_HOSP_PRELOAD (HOSP_NAME) values ("+WI.getInsertValueForDB(WI.fillTextValue("i_hosp"), true, null)+")";
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false); 
}
%>

<form name="form_" action="./grade_modification_internship.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" align="center"><font color="#FFFFFF"><strong>:::: Internship Modification Page ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="2" ><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="2">Student ID: &nbsp; <input name="stud_id" type="text" size="16"
	  	value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">      
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="submit" name="1" value="&nbsp;&nbsp;Reload Page&nbsp;&nbsp;" style="font-size:11px; height:24px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';">
	  </td>
    </tr>
    <tr valign="top">
      <td height="25" width="2%">&nbsp;</td>
      <td width="46%">SY/ Term:
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" readonly="yes"> 
	  <select name="semester">
          <option value="1">1st Sem</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = WI.getStrValue(request.getSession(false).getAttribute("cur_sem"));

if(strTemp.compareTo("2") ==0)
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%if(strTemp.compareTo("3") ==0)
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
<%if(strTemp.compareTo("0") ==0)
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="0"<%=strErrMsg%>>Summer</option>

        </select> </td>
      <td width="52%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" >Student name : <strong><%=(String)vStudInfo.elementAt(0)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >Course/Major : <strong><%=(String)vStudInfo.elementAt(1)%>
         <%=WI.getStrValue((String)vStudInfo.elementAt(2),"/","","")%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td width="98%" height="25" >Year : <strong>
	  <%=WI.getStrValue((String)vStudInfo.elementAt(3),"N/A")%></strong></td>
    </tr>
<%if(strSchCode.startsWith("AUF")){%>
    <tr bgcolor="#DDDDDD">
      <td height="25" class="thinborderTOPLEFT">&nbsp;</td>
      <td  height="25" colspan="6" style="font-size:11px;" class="thinborderTOPRIGHT">Hospital Name :
	  <select name="i_hosp_sel" onChange="CopyInternshipPlace2();" style="width:392px;">
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
      <td  height="25" colspan="6" style="font-size:11px;" class="thinborderBOTTOMRIGHT">(or) Enter Hospital Name : 
	  <input name="i_hosp" type="text" size="60" maxlength="92" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="CopyInternshipPlace3();style.backgroundColor='white'">
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;
	  Place : 
	  <input name="i_place" type="text" size="32" maxlength="32" value="" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="CopyInternshipPlace3();style.backgroundColor='white'">
	  
	  </td>
    </tr>

<%}else{%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td>
	  <select name="copy_place" onChange="CopyInternshipPlace();">
	  <option value="">Select to copy</option>
	  <option value="">Clear ALL</option>
<%=dbOP.loadCombo("distinct INTERNSHIP_PLACE","INTERNSHIP_PLACE"," from g_sheet_final where INTERNSHIP_PLACE is not null",null, false)%>
	  </select>
	  </td>
<%}%>
    </tr>
    <tr>
      <td colspan="2"><hr size="1"></td>
    </tr>
  </table>

<%}//only if vStudInfo is not null.
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#EEEEEE">
      <td height="25" width="15%" class="thinborder">Subject Code </td>
      <td width="10%" class="thinborder">Date From </td>
      <td width="10%" class="thinborder">Date To </td>
      <td width="40%" class="thinborder">Internship Place </td>
      <td width="10%" class="thinborder">Duration </td>
      <td width="10%" class="thinborder">Duration Unit</td>
      <td width="5%" class="thinborder">Select</td>
    </tr>
<%int j = 0;
for(int i = 0; i < vRetResult.size(); i += 8, ++j){%>
     <tr>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">
<%
strTemp = (String)vRetResult.elementAt(i + 3);
if(strTemp == null)
	strTemp = WI.fillTextValue("date_fr_"+j);
%>
	  <input name="date_fr_<%=j%>" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur='VerifyMMDDYYYY(document.form_.date_fr_<%=j%>);style.backgroundColor="white";' style="font-size:9px"></td>
      <td class="thinborder">
<%
strTemp = (String)vRetResult.elementAt(i + 4);
if(strTemp == null)
	strTemp = WI.fillTextValue("date_to_"+j);
%>
	  		<input name="date_to_<%=j%>" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="VerifyMMDDYYYY(document.form_.date_to_<%=j%>);style.backgroundColor='white'" style="font-size:9px"></td>
      <td class="thinborder">
<%
strTemp = (String)vRetResult.elementAt(i + 5);
if(strTemp == null)
	strTemp = WI.fillTextValue("place_"+j);
%>
	  <input name="place_<%=j%>" type="text" size="60" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:9px"></td>
      <td class="thinborder">
<%
strTemp = (String)vRetResult.elementAt(i + 6);
if(strTemp == null)
	strTemp = WI.fillTextValue("duration_"+j);
%>
	  <input name="duration_<%=j%>" type="text" size="5" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:9px"></td>
      <td class="thinborder"><select name="dur_unit_<%=j%>" style="font-size:9px">
<%
strTemp = (String)vRetResult.elementAt(i + 7);
if(strTemp == null)
	strTemp = WI.fillTextValue("dur_unit_"+j);
%>
        <option value="0">Hours</option>
<%
if(strTemp.compareTo("1") ==0){%>
        <option value="1" selected>Weeks</option>
        <%}else{%>
        <option value="1">Weeks</option>
        <%}if(strTemp.compareTo("2") ==0){%>
        <option value="2" selected>Months</option>
        <%}else{%>
        <option value="2">Months</option>
        <%}%>
      </select></td>
      <td class="thinborder" align="center">
	  <input type="checkbox" name="checkbox_<%=j%>" value="<%=vRetResult.elementAt(i)%>">
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="7" align="center" style="font-size:9px;">
	  <input type="submit" name="1" value="&nbsp;::: Save Selected Records :::&nbsp;" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';">
	  
	  </td>
    </tr>
  </table>
<input type="hidden" name="max_disp" value="<%=j%>">
<%}%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
