<%@ page language="java" import="utility.*,java.util.Vector,eDTR.OverTime,eDTR.eDTRUtil"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Set Overtime Parameters</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
	function ReloadPage(){
		document.form_.print_page.value="";
		this.SubmitOnce("form_");
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		this.SubmitOnce("form_");
	}

	function ClearDate(){
		document.form_.date_to.value ="";
		document.form_.date_from.value ="";
	}
	
	function DeleteRecord(strInfoIndex){
		document.form_.page_action.value = "0";
		document.form_.info_index.value = strInfoIndex;
		document.form_.print_page.value="";		
		this.SubmitOnce("form_");
	}
	
	function CancelEdit(){
		location = "./set_overtime_param.jsp?emp_id=" + document.form_.emp_id.value;
	}
	
	function SaveRecord(){
		document.form_.page_action.value ="1";
		document.form_.print_page.value="";
		this.SubmitOnce("form_");
	}

	function EditRecord(){
		document.form_.page_action.value ="2";
		document.form_.print_page.value="";
		this.SubmitOnce("form_");
	}
	
	function PrepareToEdit(strInfoIndex){
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.print_page.value="";
		this.SubmitOnce("form_");
	}
	
	function ShowAll() {
	var pgLoc = "./set_overtime_param_all.jsp?show_all=1";
	var win=window.open(pgLoc,"ShowAll",'dependent=yes,width=750,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
	
	function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
	
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
-->
</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;


//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./set_overtime_param_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Staff-eDaily Time Record-OVERTIME MANAGEMENT-Set Overtime Parameters","set_overtime_param.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT",request.getRemoteAddr(),
														"set_overtime_param.jsp");
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT-Set Overtime Parameters",request.getRemoteAddr(), 
														"set_overtime_param.jsp");	
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

OverTime ot = new OverTime ();
Vector vEditInfo = null;
Vector vEmpInfo = null;
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (strTemp.compareTo("0") == 0){
	if (ot.operateOnOTParameter(dbOP,request,0) != null){
		strErrMsg = " Overtime parameter removed successfully.";
	}else{
		strErrMsg = ot.getErrMsg();
	}
}else if (strTemp.compareTo("1") == 0){
	if (ot.operateOnOTParameter(dbOP,request,1) != null){
		strErrMsg = " Overtime parameter recorded successfully.";
	}else{
		strErrMsg = ot.getErrMsg();
	}
}else if (strTemp.compareTo("2") == 0){
	if (ot.operateOnOTParameter(dbOP,request,2) != null){
		strErrMsg = " Overtime parameter edited successfully.";
		strPrepareToEdit = "";
	}else{
		strErrMsg = ot.getErrMsg();
	}
}
if(strPrepareToEdit.compareTo("1") ==0){
	vEditInfo = ot.operateOnOTParameter(dbOP,request,3);
	if (vEditInfo == null && strErrMsg == null) 
		strErrMsg = ot.getErrMsg();
}

enrollment.Authentication authentication = new enrollment.Authentication();

if (WI.fillTextValue("emp_id").length() > 0){
    vEmpInfo = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vEmpInfo == null){
		strErrMsg = authentication.getErrMsg();
	}
}

if (WI.fillTextValue("emp_id").length() != 0){
	vRetResult = ot.operateOnOTParameter(dbOP,request,4);
	if (vRetResult == null && strErrMsg == null) 	strErrMsg = ot.getErrMsg();
}

%>
<body bgcolor="#D2AE72" onLoad="document.form_.emp_id.focus()" class="bgDynamic">
<form name="form_" method="post" action="./set_overtime_param.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      SET OVERTIME PARAMETERS PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size =\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%></td>
    </tr>
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="13%">Employee ID </td>
      <td width="19%"><input name="emp_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16" maxlength="16"
	   onKeyUp="AjaxMapName(1);">      </td>
      <td width="9%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="9%"><font size="1"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0" ></a></font></td>
      <td width="48%"><label id="coa_info"></label></td>
    </tr>
  </table>
<% if(vEmpInfo != null) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="49%" height="26"><font size="1">Employee Name</font></td>
      <td width="48%" height="26"><font size="1">Employee Status</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" valign="top">&nbsp;<strong><%=WI.formatName((String)vEmpInfo.elementAt(1), (String)vEmpInfo.elementAt(2),
							(String)vEmpInfo.elementAt(3), 4)%></strong></td>
      <td valign="top">&nbsp;<strong><%=WI.getStrValue((String)vEmpInfo.elementAt(16))%></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25"><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</font></td>
      <td height="25"><font size="1">Position</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
<% strTemp = WI.getStrValue((String)vEmpInfo.elementAt(13));
   if (strTemp.length() == 0)
   	  strTemp = WI.getStrValue((String)vEmpInfo.elementAt(14));
	else
   	  strTemp += WI.getStrValue((String)vEmpInfo.elementAt(14)," :: ","","");
%>
      <td height="25" valign="top">&nbsp;&nbsp;<strong><%=strTemp%></strong></td>
      <td valign="top">&nbsp;<strong><%=WI.getStrValue((String)vEmpInfo.elementAt(15))%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Effectivity Date : </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td width="70%" height="10"> <strong>&nbsp;&nbsp;From</strong> 
        <% if (vEditInfo != null) strTemp =(String)vEditInfo.elementAt(2);
	     else strTemp = WI.fillTextValue("date_from");%> <input name="date_from" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" class="textbox"
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp; 
        <strong>To</strong>&nbsp; <% if (vEditInfo != null) strTemp =WI.getStrValue((String)vEditInfo.elementAt(3));
	     else strTemp = WI.fillTextValue("date_to");%> <input name="date_to" type="text" size="10" maxlength="10" readonly value="<%=strTemp%>" class="textbox"
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp; 
        <font size="1">(leave blank if still applicable)</font> <a href="javascript:ClearDate();"> 
        </a></td>
      <td width="25%" height="10"><a href="javascript:ClearDate();"><img src="../../../images/clear.gif" width="55" height="19" border="0" ></a><font size="1"> 
        clear the dates</font></td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td colspan="2" valign="bottom">Time Not Considered Overtime </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><strong>&nbsp;&nbsp;From</strong> 
        <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(4);
		    else strTemp = WI.fillTextValue("hr_from");%> <input value ="<%=strTemp%>" name="hr_from" type="text" size="2" maxlength="2"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','hr_from')">
        : 
        <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(5);
		    else strTemp = WI.fillTextValue("min_from");%> <input value ="<%=strTemp%>"  name="min_from" type="text" size="2" maxlength="2"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','min_from')"> 
        <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(6);
		    else strTemp = WI.fillTextValue("ampm_from");%> <select name="ampm_from" id="ampm_from">
          <option value=0>AM</option>
          <% if (strTemp.equals("1")) {%>
          <option value=1 selected>PM</option>
          <% }else{%>
          <option value=1>PM</option>
          <%}%>
        </select> <strong>To</strong> <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(7);
		    else strTemp = WI.fillTextValue("hr_to");%> <input name="hr_to" type="text" size="2" maxlength="2" value="<%=strTemp%>"  class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  onKeyUp="AllowOnlyInteger('form_','hr_to')">
        : <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(8);
		    else strTemp = WI.fillTextValue("min_to");%> <input value="<%=strTemp%>" name="min_to" type="text" size="2" maxlength="2"  class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  onKeyUp="AllowOnlyInteger('form_','min_to')"> 
        <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(9);
	    else strTemp = WI.fillTextValue("ampm_to");%> <select name="ampm_to" >
          <option value="0">AM</option>
          <% if (strTemp.compareTo("1")== 0) {%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="35" colspan="3"> <div align="center"> 
          <%if (iAccessLevel > 1){
   	   if (vEditInfo == null) {%>
          <a href="javascript:SaveRecord()"><img src="../../../images/save.gif" width="48" height="28" border="0"></a> 
          <font size="1">click to add record </font> 
          <% }else{ %>
          <a href="javascript:EditRecord()"><img src="../../../images/edit.gif" border="0"> 
          </a> <font size="1">click to save changes</font> <a href='javascript:CancelEdit();'><img src="../../../images/cancel.gif" border="0"></a> 
          <font size="1">click to cancel or go previous</font> 
          <%} // end if else vEditInfo == null 
	} // end iAccessLevel > 1%>
          &nbsp;</div></td>
    </tr>
  </table>
  <% if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="49%" valign="bottom">&nbsp;<a href="javascript:ShowAll();"><img src="../../../images/show_list.gif" width="57" height="34" border="0"></a><font size="1">click 
        to show all employees</font></td>
      <td width="51%" height="10" colspan="2" valign="bottom"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a>click 
          to print table</font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="7" align="center" bgcolor="#B9B292">LIST OF 
      EMPLOYEES OVERTIME PARAMETERS</td>
    </tr>
    <tr> 
      <td width="12%" height="26" align="center"><font size="1"><strong>EMPLOYEE 
      ID </strong></font></td>
      <td width="24%" align="center"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td align="center"><strong><font size="1">
        <%if(bolIsSchool){%>
        COLLEGE
        <%}else{%>
        DIVISION
        <%}%>
      /OFFICE</font></strong></td>
      <td align="center"><strong><font size="1">TIME</font></strong></td>
      <td align="center"><strong><font size="1">EFFECTIVITY DATE</font></strong></td>
      <td colspan="2" align="center"><strong><font size="1">OPTIONS</font></strong></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size() ; i+=13) {%>
    <tr> 
      <td height="25"><font size="1"><%=(String)vRetResult.elementAt(i+12)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+10)%></font></td>
      <td width="20%"><font size="1"><%=(String)vRetResult.elementAt(i+11)%></font></td>
      <td width="12%"><font size="1"><%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+4),
	  					(String)vRetResult.elementAt(i+5),
	  					(String)vRetResult.elementAt(i+6)) + " - " + 
						eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
	  					(String)vRetResult.elementAt(i+8),
	  					(String)vRetResult.elementAt(i+9))%></font></td>
      <td width="17%"><font size="1"><%=((String)vRetResult.elementAt(i+2)) + " - " + ((String)vRetResult.elementAt(i+3))%></font></td>
      <td width="6%" height="25" align="center"> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a></td>
      <td width="9%" align="center"> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></td>
    </tr>
    <%} // end for loop%>
  </table>
 <%} // vRetResult != null  
 } // end vEmpInfo = nul %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
