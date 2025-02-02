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
								"Admin/staff-Registrar Management-GRADES-Grade Modification Internship","grade_modification_thesis.jsp");
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
									"grade_modification_thesis.jsp");
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
	if(GS.operateOnGradeModificationThesis(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = GS.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
vRetResult = GS.operateOnGradeModificationThesis(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = GS.getErrMsg();
else {
	vStudInfo = (Vector)vRetResult.remove(0);
	if(vRetResult.size() == 0)
		strErrMsg = "No grade information found. Please encode grade information first before encoding thesis information.";
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<form name="form_" action="./grade_modification_thesis.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" align="center"><font color="#FFFFFF"><strong>:::: Thesis Modification Page ::::</strong></font></td>
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
    <tr>
      <td colspan="2"><hr size="1"></td>
    </tr>
  </table>

<%}//only if vStudInfo is not null.
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#EEEEEE">
      <td height="25" width="21%" class="thinborder">Subject Code </td>
      <td width="12%" class="thinborder">Thesis Type </td>
      <td width="62%" class="thinborder">Title</td>
      <td width="5%" class="thinborder">Select</td>
    </tr>
<%int j = 0;
for(int i = 0; i < vRetResult.size(); i += 5, ++j){%>
     <tr>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">
<%
strTemp = (String)vRetResult.elementAt(i + 3);
if(strTemp == null)
	strTemp = WI.fillTextValue("type_"+j);
%>
	<select name="type_<%=j%>">
		<option value="1">Thesis</option>
<%
if(strTemp.equals("2"))
	strTemp = " selected";
else	
	strTemp = "";
%>		<option value="2" <%=strTemp%>>Project Paper</option>
<%
if(strTemp.equals("3"))
	strTemp = " selected";
else	
	strTemp = "";
%>		<option value="3" <%=strTemp%>>Dissertation</option>
	</select>

	  </td>
      <td class="thinborder">
<%
strTemp = (String)vRetResult.elementAt(i + 4);
if(strTemp == null)
	strTemp = WI.fillTextValue("title_"+j);
%>
	  <input name="title_<%=j%>" type="text" size="60" maxlength="256" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:9px"></td>
      <td class="thinborder" align="center">
	  <input type="checkbox" name="checkbox_<%=j%>" value="<%=vRetResult.elementAt(i)%>">	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="4" align="center" style="font-size:9px;">
	  <input type="submit" name="1" value="&nbsp;::: Save Selected Records :::&nbsp;" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';">	  </td>
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
