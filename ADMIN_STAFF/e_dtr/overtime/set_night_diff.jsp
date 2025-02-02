<%@ page language="java" import="utility.*,java.util.Vector,eDTR.OverTime,eDTR.eDTRUtil" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Night Differential Management</title>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function AddRecord(){
	document.form_.print_page.value="";
	document.form_.page_action.value="1";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.print_page.value="";
	document.form_.page_action.value="0";
	document.form_.info_index.value=strInfoIndex;
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.print_page.value="";
	document.form_.page_action.value="2";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.print_page.value="";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value=strInfoIndex;
	this.SubmitOnce("form_");
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location = "./set_night_diff.jsp";
}

function PrintPage(){
	document.form_.page_action.value="";
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>

<body bgcolor="#D2AE72" class="bgDynamic">
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = "";

//add security here.
	if (WI.fillTextValue("print_page").compareTo("1")  == 0) {%>
		<jsp:forward page="./set_night_diff_print.jsp" />
	<% return;}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Dtr Operations-Night Differential Parameter","set_night_diff.jsp");
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
														"eDaily Time Record","DTR OPERATIONS ",request.getRemoteAddr(), 
														"set_night_diff.jsp");	
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
OverTime ot = new OverTime();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
Vector vRetResult = null;
Vector vEditInfo = null;

if (WI.fillTextValue("page_action").compareTo("0") == 0) {
	if (ot.operateOnNightDiff(dbOP,request,0) != null)
		strErrMsg = " Night differential setting removed successfully";
	else strErrMsg = ot.getErrMsg();
}else if (WI.fillTextValue("page_action").compareTo("1") == 0) {
	if (ot.operateOnNightDiff(dbOP,request,1) != null)
		strErrMsg = " Night differential setting added successfully";
	else strErrMsg = ot.getErrMsg();
}else if (WI.fillTextValue("page_action").compareTo("2") == 0) {
	if (ot.operateOnNightDiff(dbOP,request,2) != null){
		strErrMsg = " Night differential setting updated successfully";
		strPrepareToEdit = "";
	}else strErrMsg = ot.getErrMsg();
}

if (strPrepareToEdit.compareTo("1") ==0){
	vEditInfo = ot.operateOnNightDiff(dbOP,request,3);
	if (vEditInfo == null){
		strErrMsg = ot.getErrMsg();
	}
}

vRetResult = ot.operateOnNightDiff(dbOP,request,4);
String[] astrAddOnUnit1 = {"%"," "};
String[] astrAddOnUnit2 = {"Per Hour","Per Duty/Day"};
%>
<form action="./set_night_diff.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      SET NIGHT DIFFERENTIAL (ND) PARAMETERS PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;&nbsp;
	  <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td colspan="2">Effectivity Date From : &nbsp; 
	  <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(0);
	  	else strTemp = WI.fillTextValue("eff_date_from"); %>
        <input onFocus="style.backgroundColor='#D3EBFF'"  value="<%=strTemp%>" onBlur="style.backgroundColor='white'"
	    readonly="yes" class="textbox" name="eff_date_from" type="text" size="10" maxlength="10"> 
        <a href="javascript:show_calendar('form_.eff_date_from');" title="Click to select date" 
		onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;To 
        : 
	  <% if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(1));
	  	else strTemp = WI.fillTextValue("eff_date_to"); %>

        <input name="eff_date_to" type="text"   readonly="yes"   size="10" maxlength="10" class="textbox" value="<%=strTemp%>"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.eff_date_to');" title="Click to select date" 
		onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Position :: 
	  <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(2);
	  	else strTemp = WI.fillTextValue("emp_type_index"); %>
	  
        <select name="emp_type_index">
          <option value="0">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc",
		   strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Time Considered for ND: &nbsp;&nbsp;&nbsp;From 
	  	  <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(3);
	  	else strTemp = WI.fillTextValue("hh_from"); %>

        <input name="hh_from" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"   value="<%=strTemp%>"
		onblur="AllowOnlyInteger('form_','hh_from');style.backgroundColor='white'"  size="2" maxlength="2" 
		onKeyUp="AllowOnlyInteger('form_','hh_from');">: 
		
			  <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(4);
	  	else strTemp = WI.fillTextValue("mm_from"); %>
        <input name="mm_from" type="text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'"   value="<%=strTemp%>"
		   onKeyUp="AllowOnlyInteger('form_','mm_from');" onBlur="AllowOnlyInteger('form_','mm_from');style.backgroundColor='white'" 
		   size="2" maxlength="2"> <select name="ampm_from" >
          <option value=1>PM</option>
	  <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(5);
	  	else strTemp = WI.fillTextValue("ampm_from"); 
		 if (strTemp.compareTo("0")==0) {%>
          <option value=0 selected>AM</option>
          <% }else{%>
          <option value=0>AM</option>
          <%}%>
        </select>
        to 
	  <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(6);
	  	else strTemp = WI.fillTextValue("hh_to"); %>
        <input name="hh_to" onKeyUp="AllowOnlyInteger('form_','hh_to');" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	 onblur="AllowOnlyInteger('form_','hh_to');style.backgroundColor='white'" type="text" size="2" maxlength="2" value="<%=strTemp%>"> 
        : 
	  <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(7);
	  	else strTemp = WI.fillTextValue("mm_to"); %>
        <input name="mm_to"  onKeyUp="AllowOnlyInteger('form_','mm_to');" type="text"  size="2" maxlength="2" value="<%=strTemp%>"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','mm_to');style.backgroundColor='white'" 
		class="textbox"> 
		<select name="ampm_to">
          <option value="0">AM</option>
	  <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(8);
	  	else strTemp = WI.fillTextValue("ampm_to"); 
			if (strTemp.compareTo("1")== 0) {%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"> Add-on to Salary/Wage : &nbsp;&nbsp;&nbsp; 
	  <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(9);
	  	else strTemp = WI.fillTextValue("add_on_amt"); %>
	  	<input name="add_on_amt" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onblur="AllowOnlyIntegerExtn('form_','add_on_amt','.');style.backgroundColor='white'"    value="<%=strTemp%>"
		onKeyUP="AllowOnlyIntegerExtn('form_','add_on_amt','.')" size="8" maxlength="8"> 
        <select name="add_on_unit1">
          <option value="0">Percentage</option>
	  <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(10);
	  	else strTemp = WI.fillTextValue("add_on_unit1"); 
		 if (strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Specific Amount</option>
		  <%}else{%>
		  <option value="1" >Specific Amount</option>
		  <%}%>
        </select> 
		<select name="add_on_unit2">
          <option value="0">Per Hour</option>
	  <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(11);
	  	else strTemp = WI.fillTextValue("add_on_unit2"); 
		 if (strTemp.compareTo("1") == 0) {%>		  
          <option value="1" selected>Per Duty/Day</option>
		  <%}else{%>
		  <option value="1">Per Duty/Day</option>
		  <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td width="16%" height="35" valign="bottom">&nbsp;</td>
      <td width="79%" height="35" valign="bottom">
	 <% if (iAccessLevel > 1) {
	 		if(vEditInfo == null) {
	 %>	 <a href="javascript:AddRecord()"><img src="../../../images/save.gif" border="0"></a><font size="1">click 
        to save entries </font>
	  <%}else{%>
		 <a href="javascript:EditRecord()"><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
        to update entries </font>	  	
	  <%}%>	  		
		<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
        to cancel/clear entries</font>
	 <%}%>
	 </td>
    </tr>
    <tr> 
      <td height="20" colspan="3">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="82%" height="10" colspan="2" valign="bottom"> <hr width="98%" size="1" noshade> 
      </td>
    </tr>
    <tr>
      <td height="10" colspan="2" align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
        to print table</font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><strong>NIGHT 
        DIFFERENTIAL PARAMETERS </strong></td>
    </tr>
    <tr>
      <td width="27%" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
      <td width="27%" height="26" align="center" class="thinborder"><font size="1"><strong>EFFECTIVITY 
        DATE</strong></font></td>
      <td width="33%" align="center" class="thinborder"><strong><font size="1">TIME 
        CONSIDERED FOR NIGHT DIFF</font></strong></td>
      <td align="center" class="thinborder"><strong><font size="1">ADD-ON TO SALARY/WAGE</font></strong></td>
      <td colspan="2" align="center" class="thinborder"><strong><font size="1"><strong>OPTIONS</strong></font></strong></td>
    </tr>
 <%
 for (int i = 0; i<vRetResult.size(); i+=14) {
 	if ((String)vRetResult.elementAt(i+1) != null) 
		strTemp = "-" + WI.formatDate((String)vRetResult.elementAt(i+1), 10);
	else strTemp = "- present";
 %>
    <tr>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i+13),"ALL")%></td> 
      <td height="25" class="thinborder">&nbsp;<%=WI.formatDate((String)vRetResult.elementAt(i),10)%>
	  <%=strTemp%></td>
      <td align="center" class="thinborder">      <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+3),
	  (String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5))%> - <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+6),(String)vRetResult.elementAt(i+7),
	  (String)vRetResult.elementAt(i+8))%></td>
      <td width="24%" align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+9)+  
	    									 astrAddOnUnit1[Integer.parseInt((String)vRetResult.elementAt(i+10))] + " " +  
	   										 astrAddOnUnit2[Integer.parseInt((String)vRetResult.elementAt(i+11))]%></td>
      <td width="7%" height="25" align="center" class="thinborder"> 
			<%if(iAccessLevel > 1){%>
	      <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i+12)%>);'>
	      <img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
			<%}else{%>
			N/A
			<%}%>
			</td>
      <td width="8%" class="thinborder"> 
			<%if(iAccessLevel == 2){%>
			<div align="center">
	  <a href='javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i+12)%>);'>
	  <img src="../../../images/delete.gif" width="55" height="28" border="0"></a></div>
			<%}else{%>
				N/A
			<%}%>
			</td>
    </tr>
 <%}%>
  </table>
 <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="print_page">
 <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
 <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
 <input type="hidden" name="page_action">
</form>
</body>
</html>

<%
	dbOP.cleanUP();
%>