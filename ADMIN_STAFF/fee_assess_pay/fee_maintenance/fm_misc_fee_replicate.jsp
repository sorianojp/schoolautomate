<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function UpdateNationality(table,indexname,colname,labelname){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
		"&opner_form_name=oth_miscfee";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SwitchNewYearlyFee()
{
	if(document.oth_miscfee.is_yearly.checked)
	{
		if(document.oth_miscfee.is_for_new.checked)
		{
			document.oth_miscfee.is_for_new.checked = false;
			return;
		}
	}
	if(document.oth_miscfee.is_for_new.checked){
		if(document.oth_miscfee.is_yearly.checked)
			document.oth_miscfee.is_yearly.checked = false;
		if(document.oth_miscfee.is_for_old.checked)
			document.oth_miscfee.is_for_old.checked = false;
	}
	if(document.oth_miscfee.is_for_old.checked){
		if(document.oth_miscfee.is_yearly.checked)
			document.oth_miscfee.is_yearly.checked = false;
		if(document.oth_miscfee.is_for_new.checked)
			document.oth_miscfee.is_for_new.checked = false;
	}
}
/**
* Charge Only once is valid only if the fee is for hands on. Sometimes, the there are more than one hands on, but the fee should be
* included only once instead
*/
function CheckIfForHandsOn()
{
	if(!document.oth_miscfee.is_handson.checked && document.oth_miscfee.is_charged_once.checked)
	{
		document.oth_miscfee.is_charged_once.checked = false;
		alert("This is valid only if the fee is for hands on fee type. Please click handson first before clicking this charge type.");
	}
}
function CopyMiscFeeName()
{
	document.oth_miscfee.fee_name.value = document.oth_miscfee.fee_name_reference[document.oth_miscfee.fee_name_reference.selectedIndex].value;
}
function PrepareToEdit(strInfoIndex)
{
	document.oth_miscfee.editRecord.value = 0;
	document.oth_miscfee.deleteRecord.value = 0;
	document.oth_miscfee.addRecord.value = 0;
	document.oth_miscfee.prepareToEdit.value = 1;
	document.oth_miscfee.info_index.value = strInfoIndex;
	document.oth_miscfee.submit();

}
function AddRecord()
{
	if(document.oth_miscfee.prepareToEdit.value == 1)
	{
		EditRecord(document.oth_miscfee.info_index.value);
		return;
	}
	document.oth_miscfee.editRecord.value = 0;
	document.oth_miscfee.deleteRecord.value = 0;
	document.oth_miscfee.addRecord.value = 1;

	document.oth_miscfee.submit();
}
function EditRecord(strTargetIndex)
{
	document.oth_miscfee.editRecord.value = 1;
	document.oth_miscfee.deleteRecord.value = 0;
	document.oth_miscfee.addRecord.value = 0;

	document.oth_miscfee.info_index.value = strTargetIndex;

	document.oth_miscfee.submit();
}

function DeleteRecord(strTargetIndex)
{
	if(!confirm('Are you sure you want to delete this record.'))
		return;
	document.oth_miscfee.editRecord.value = 0;
	document.oth_miscfee.deleteRecord.value = 1;
	document.oth_miscfee.addRecord.value = 0;

	document.oth_miscfee.info_index.value = strTargetIndex;
	document.oth_miscfee.prepareToEdit.value == 0;

	document.oth_miscfee.submit();
}
//for help
function WhatIsHandsOn()
{
	var win=window.open("../../../onlinehelp/whatis_handson.htm","HelpFile",
	'dependent=yes,width=300,height=300,screenX=200,screenY=300,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function CancelRecord()
{
	document.oth_miscfee.info_index.value = "0";
	document.oth_miscfee.prepareToEdit.value = "0";

	ReloadPage();
}
function ReloadPage()
{
	if(!document.oth_miscfee.is_handson.checked && document.oth_miscfee.is_charged_once.checked)
	{
		document.oth_miscfee.is_charged_once.checked = false;
	}

	document.oth_miscfee.reloadPage.value="1";
	document.oth_miscfee.addRecord.value = "0";
	document.oth_miscfee.editRecord.value = "0";
	document.oth_miscfee.deleteRecord.value = "0";
	document.oth_miscfee.submit();
}
function UpdateMiscFeeName() {
	var pgLoc = "./fm_misc_fee_update_fee_name.jsp";
	var win=window.open(pgLoc,"myfile",'dependent=yes,width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

	boolean bolHandsOn = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-misc fee","fm_misc_fee_replicate.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"fm_misc_fee_replicate.jsp");
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

FAFeeMaintenance FA = new FAFeeMaintenance();
boolean bolProceed = true;

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(!FA.replicateMiscFee(dbOP,request))
		bolProceed = false;
	strErrMsg = FA.getErrMsg();
}
//get all levels created.
Vector vRetResult = null;
Vector vEditInfo = null;

if(bolProceed)
{
	vRetResult = FA.viewMiscFee(dbOP, request,true);//to view all
}


//do not proceed is bolProceed = false;
if(!bolProceed)
{
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="2">
	<b><%=strErrMsg%></b></font></p>
	<%
	dbOP.cleanUP();
	return;
}

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

boolean bolIsVMUF   = strSchoolCode.startsWith("VMUF");
boolean bolIsFatima = strSchoolCode.startsWith("FATIMA");
boolean bolIsUC     = false;//strSchoolCode.startsWith("UC");
boolean bolIsVMA    = strSchoolCode.startsWith("VMA");
boolean bolIsDLSHSI = strSchoolCode.startsWith("DLSHSI");


String strSYFrom = null;

	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0) )
		strSYFrom = (String)vEditInfo.elementAt(0);
	else
		strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom == null || strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");

%> 
<form name="oth_miscfee" action="./fm_misc_fee_replicate.jsp" method="post">

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          MISCELLANEOUS FEES MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<b><font size="3"><%=WI.getStrValue(strErrMsg)%></font></b></td>
    </tr>
 <%
if(strSchoolCode.startsWith("CIT")){%>
    <tr style="font-weight:bold; color:#0000FF;">
      <td height="25">&nbsp;</td>
      <td colspan="3">Applicable SY Range<font style="font-weight:bold; color:#FF0000">*</font> :
	  <select name="id_sy_range" onChange="ReloadPage();">
          <%=dbOP.loadCombo("ID_RANGE_INDEX","RANGE_SY_FROM,RANGE_SY_TO"," from FA_CIT_IDRANGE where IS_ACTIVE_RECORD=1 and eff_fr_sy = "+strSYFrom+" order by RANGE_SY_FROM asc", WI.fillTextValue("id_sy_range"), false)%> 
	  </select>	
<strong><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a><font size="1">click 
        to refresh page</font></strong>	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"><strong><u><font color="#FF0000">FEE PARAMETERS: Tick/click
        the small box of applicable parameters for indicated fee</font></u></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(13);
	else
		strTemp = request.getParameter("is_for_new");
	if(strTemp == null || strTemp.compareTo("0") ==0) strTemp = "";
	else
		strTemp = " checked";
	%> <input type="checkbox" name="is_for_new" value="1"<%=strTemp%> onClick="SwitchNewYearlyFee();">
        Charged Only to NEW Enrolees
		<select name="is_for_new_stat">
			<option value="1">New</option>
<%
if(strErrMsg.equals("2"))
	strTemp = " selected";
else	
	strTemp = "";
%>
			<option value="2"<%=strTemp%>>Cross-enrollee</option>
<%
if(strErrMsg.equals("3"))
	strTemp = " selected";
else	
	strTemp = "";
%>			<option value="3"<%=strTemp%>>Transferee</option>
		</select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(19);
	else
		strTemp = request.getParameter("is_for_old");
	if(strTemp == null || strTemp.compareTo("0") ==0) strTemp = "";
	else
		strTemp = " checked";
	%> <input type="checkbox" name="is_for_old" value="1"<%=strTemp%> onClick="SwitchNewYearlyFee();">
        Charged Only to OLD Students</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(14);
	else
		strTemp = request.getParameter("is_yearly");
	if(strTemp == null || strTemp.compareTo("0") ==0) strTemp = "";
	else
		strTemp = " checked";
	%> <input type="checkbox" name="is_yearly" value="1"<%=strTemp%> onClick="SwitchNewYearlyFee();">
        Charged ONCE a Year<font size="1"> (Example: If ID are charged every once
        a year even if old student)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(16);
	else
		strTemp = request.getParameter("is_charged_once");
	if(strTemp == null || strTemp.compareTo("0") ==0) strTemp = "";
	else
		strTemp = " checked";
	%> <input type="checkbox" name="is_charged_once" value="1"<%=strTemp%> onClick="CheckIfForHandsOn();">
        Charged ONLY ONCE<font size="1"> (Example: Lab. Deposit which is added
        even if more than 1 lab. subject taken. Also Clinical Fee - valid if fee
        is for handson.)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(15);
	else
		strTemp = request.getParameter("is_for_alien");
	if(strTemp == null || strTemp.compareTo("0") ==0) strTemp = "";
	else
		strTemp = " checked";
	%> <input type="checkbox" name="is_for_alien" value="1"<%=strTemp%>>
        Charged for FOREIGN Nationals
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(18);
	else
		strTemp = request.getParameter("nationality");
	if(strTemp == null) strTemp = "";//System.out.println(strTemp);
%> <select name="nationality">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("ALIEN_NATIONALITY_INDEX","NATIONALITY"," from NA_ALIEN_NATIONALITY order by NATIONALITY asc", strTemp, false)%> </select> <a href='javascript:UpdateNationality("NA_ALIEN_NATIONALITY","ALIEN_NATIONALITY_INDEX","NATIONALITY","NATIONALITY");'>
        <img src="../../../images/update.gif" border="0"></a><font size="1">click
        to update list of Nationality</font></td>
    </tr>
<%if(strSchoolCode.startsWith("FATIMA")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(22);
	else
		strTemp = request.getParameter("is_graduating");
	if(strTemp == null || strTemp.compareTo("0") ==0) 
		strTemp = "";
	else
		strTemp = " checked";
%>
      <input type="checkbox" name="is_graduating" value="1"<%=strTemp%>> Charged Only to Graduating Students </td>
    </tr>
<%}if(bolIsUC){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(23);
	else
		strTemp = request.getParameter("is_attcnb");
	if(strTemp == null || strTemp.compareTo("0") ==0) 
		strTemp = "";
	else
		strTemp = " checked";
%>
      <input type="checkbox" name="is_attcnb" value="1"<%=strTemp%>> Charged Only to ATTC/NB Students </td>
    </tr>
<%}if(true || bolIsVMA){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(24);
	else
		strTemp = request.getParameter("is_returnee");
	if(strTemp == null || strTemp.compareTo("0") ==0) 
		strTemp = "";
	else
		strTemp = " checked";
%>
      <input type="checkbox" name="is_returnee" value="1"<%=strTemp%>> Charged Only to Returnee Students </td>
    </tr>
<%}if(bolIsVMUF) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(21);
	else
		strTemp = request.getParameter("gender_specific");
	
	if(strTemp == null || strTemp.compareTo("0") ==0) 
		strTemp = "";
%> 
Select gender if Fee is gender specific: 
	<select name="gender_specific">
		<option value=""></option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
 		<option value="0"<%=strErrMsg%>>Male</option>
<%
strErrMsg = "";
if(strTemp.equals("0"))
	strTemp = " selected";
else	
	strTemp = "";
%>
		<option value="1"<%=strErrMsg%>>Female</option>
	</select>	  </td>
    </tr>
<%}if(bolIsDLSHSI){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(25);
	else
		strTemp = request.getParameter("is_regular_stud");
	if(strTemp == null || strTemp.length() == 0) 
		strTemp = "0";
%>
      Charge to specific Regular/Irregular Student: 
	  <select name="is_regular_stud">
	  	<option value="0"></option>
<%if(strTemp.equals("1"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		
		<option value="1" <%=strErrMsg%>>Charge To Regular Only</option>
<%if(strTemp.equals("2"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>		
		<option value="2" <%=strErrMsg%>>Charge to Irregular Only</option>
	  </select>
	  
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
      <td><strong><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a><font size="1">click
        to refresh page</font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="5"><hr size="1" color="#6633CC"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">School year </td>
      <td width="28%"> 
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("oth_miscfee","sy_from","sy_to")'>
        to
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("sy_to");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td width="23%">Year level
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("year_level");
	if(strTemp == null) strTemp = "";
	%> <select name="year_level">
          <%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>All</option>
          <%}else{%>
          <option value="0">All</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}if(strTemp.compareTo("7") ==0){%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}%>
        </select> </td>
      <td width="33%">Semester:
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(17);
	else
		strTemp = request.getParameter("semester");
	if(strTemp == null) strTemp = "";
	%> <select name="semester">
          <option value="">ALL</option>
          <%
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course Program </td>
      <td>
	  	<select name="cc_index" onChange="ReloadPage();">
          <option value="0">Select a Program</option>
          <%//=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc",
		  //request.getParameter("cc_index"), false)%>
        </select></td>
    </tr>
-->
    <tr>
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="3">
	    <select name="c_index" onChange="ReloadPage();" style="font-size:14px;background:#DFDBD2; width:400;">
          <option></option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where is_del=0 order by c_name asc", WI.fillTextValue("c_index"), false)%> 
        </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course </td>
      <td colspan="3"><font size="1">
        <input type="text" name="scroll_course" size="16" style="font-size:9px" class="textbox"
	  onKeyUp="AutoScrollList('oth_miscfee.scroll_course','oth_miscfee.course_index',true);"
	   onBlur="ReloadPage()">
        (enter course code to scroll course list)</font> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">
	    <%
  if(WI.fillTextValue("cc_index").length() > 0 && !WI.fillTextValue("cc_index").equals("0"))
		strTemp2 = " from course_offered where CC_INDEX = "+WI.fillTextValue("cc_index")+
			" and IS_DEL=0 AND IS_VALID=1 order by cname asc";
  else if(WI.fillTextValue("c_index").length() > 0)
		strTemp2 = " from course_offered where C_INDEX = "+WI.fillTextValue("c_index")+
			" and IS_DEL=0 AND IS_VALID=1 order by cname asc";
  else
	  	strTemp2 = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by cname asc";

	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null ||
	   request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = request.getParameter("course_index");
	if(strTemp == null || strTemp.compareTo("selany") == 0) strTemp = "";
	%> <select name="course_index" onChange="ReloadPage();" style="font-size:14px;background:#DFDBD2; width:700;">
          <option value="">&lt;All Courses&gt;</option>
          <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name as cname",strTemp2, strTemp, false)%> </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Major </td>
      <td colspan="3">Entries for major will be created if a course has major.</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(9);
	else
		strTemp = request.getParameter("is_optional");
	if(strTemp == null) strTemp = "";

	if(strTemp.compareTo("0") ==0 || strTemp.length() == 0)
	{%> <input name="is_optional" type="checkbox" value="1">
        <%}else{%> <input name="is_optional" type="checkbox" checked value="1">
        <%}%>
        Optional Fee<font size="1">&nbsp;</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(8);
	else
		strTemp = request.getParameter("is_handson");
	if(strTemp == null) strTemp = "";

	if(strTemp.compareTo("0") ==0 || strTemp.length() == 0)
	{%> <input name="is_handson" type="checkbox" value="1" onClick="ReloadPage();">
        <%}else{
	bolHandsOn = true;%> <input name="is_handson" type="checkbox" value="1" checked onClick="ReloadPage();">
        <%}%>
        Check if hands on <a href="javascript:WhatIsHandsOn();"><img src="../../../images/online_help.gif" border="0"></a><font size="1">What
        is hands on </font></td>
    </tr>
    <%
	if(bolHandsOn)
	{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">Hands on Sub Category &nbsp;&nbsp; <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(6);
	else
		strTemp = request.getParameter("catg_index");
	if(strTemp == null) strTemp = "";
	%> <select name="catg_index">
          <%=dbOP.loadCombo("catg_index","catg_name"," from subject_catg where IS_DEL=0 order by catg_name asc", strTemp, false)%> </select> &nbsp; <font size="1"><em>only if hands on selected</em>.</font></td>
    </tr>
    <%}%>
    <tr>
      <td colspan="5" height="25"><hr size="1" color="#6633CC"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Fee name Ref.</td>
      <td  colspan="3"><select name="fee_name_reference" onChange="CopyMiscFeeName();" >
          <option value="">Select to copy misc fee name</option>
          <%=dbOP.loadCombo("distinct FEE_NAME","fee_name"," from FA_MISC_FEE where IS_DEL=0 and is_valid=1 order by FA_MISC_FEE.fee_name asc", null, false)%> </select> <a href="javascript:UpdateMiscFeeName();"><img src="../../../images/update.gif" border="0"></a>
        <font size="1">Click to update Fee name</font></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Fee name</td>
      <td  colspan="3"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("fee_name");
	if(strTemp == null) strTemp = "";
	%> <input name="fee_name" type="text" size="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee rate</td>
      <td width="42%"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(10);
	else
		strTemp = request.getParameter("amount");
	if(strTemp == null) strTemp = "";//System.out.println(strTemp);
	%> <input type="text" name="amount" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(11);
	else
		strTemp = request.getParameter("currency");
	if(strTemp == null) strTemp = "";
	%> <select name="currency">
          <%if(strTemp.compareToIgnoreCase("php") ==0){%>
          <option value="Php" selected>Php</option>
          <%}else{%>
          <option value="Php">Php</option>
          <%}if(strTemp.compareToIgnoreCase("US$") ==0){%>
          <option value="US$" selected>US$</option>
          <%}else{%>
          <option value="US$">US$</option>
          <%}%>
        </select> <%
 //only if hands on is true;
// if(bolHandsOn)
 {
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(7);//System.out.println(strTemp);}
	else
		strTemp = request.getParameter("amt_per_unit");
	if(strTemp == null) strTemp = "1";
	%> <select name="amt_per_unit">
          <!-- SHOW ONLY IF HANDS ON IS SET -->
          <%
	 if(strTemp.compareTo("0") == 0 && bolHandsOn){%>
          <option value="0" selected>Per unit</option>
          <%}else if(bolHandsOn){%>
          <option value="0">Per unit</option>
          <%}if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Per type</option>
          <%}else{%>
          <option value="1">Per type</option>
          <%}if(strTemp.compareTo("2") ==0 && bolHandsOn){//per hour%>
          <option value="2" selected>Per hour</option>
          <%}else if(bolHandsOn){%>
          <option value="2">Per hour</option>
          <%}%>
          <!--<option>per subject</option> NOT USED NOW -->
        </select> <%}//show if bolHandsOn is true;%> </td>
      <td colspan="2">Remarks
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(12);
	else
		strTemp = request.getParameter("remark");
	if(strTemp == null) strTemp = "";
	%> <input name="remark" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <%
	if(vEditInfo != null && vEditInfo.size() > 1) {
%>
    <%}
   if(iAccessLevel > 1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click
        to add</font>
      </td>
    </tr>
<%}//if iAccessLevel > 1%>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(vRetResult != null && vRetResult.size() > 0)
{%>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="12"><div align="center">LIST OF MISCELLANEOUS FEES</div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="47%" height="25"><div align="center"><font size="1"><strong>FEE NAME</strong></font></div></td>
      <td width="22%"><div align="center"><font size="1"><strong>FEE (Php/$) </strong></font></div></td>
      <td width="16%" align="center"><strong><font size="1">FEE CHARGE TYPE</font></strong></td>
      <td width="16%" align="center"><font size="1"><strong>YEAR LEVEL</strong></font></td>
      <td width="16%"><div align="center"><font size="1"><strong>SEM</strong></font></div></td>
      <td width="16%"><div align="center"><font size="1"><strong>CHARGED ONCE</strong></font></div></td>
      <td width="16%"><font size="1"><strong>ONLY FOR FOREIGN STUDENT</strong></font></td>
      <td width="16%"><div align="center"><font size="1"><strong>ONLY FOR NEW</strong></font></div></td>
      <td width="7%" align="center"><font size="1"><strong>ONLY FOR OLD</strong></font></td>
      <td width="7%" align="center"><font size="1"><strong><font size="1">YEARLY FEE</font></strong></font></td>
<%if(bolIsVMUF){%>
      <td width="7%" align="center" style="font-size:9px; font-weight:bold">Gender</td>
<%}if(bolIsFatima){%>
     <td width="7%" align="center" style="font-size:9px; font-weight:bold">Is Graduating </td>
<%}if(bolIsUC){%>
     <td width="7%" align="center" style="font-size:9px; font-weight:bold">Is ATTC/NB </td>
<%}if(bolIsVMA){%>
     <td width="7%" align="center" style="font-size:9px; font-weight:bold">Returnee</td>
     <%}%>
<%if(bolIsDLSHSI){%>
      <td width="7%" align="center" style="font-size:9px; font-weight:bold">Charge Reg/Irreg </td>
<%}%>
      <td width="8%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
String[] convertYearLevel = {"All","1st","2nd","3rd","4th","5th","6th","7th","8th"};
String[] strConvertSem    = {"summer","1st","2nd","3rd","4th","All"};
String[] astrConvertToFeeType = {"Per Unit","Per Type","Per Hour","Amt*UE"};
String strOptional = null;
String strHandsOn = null;

String strIsGraduating = null;
String strIsAttcnbStud = null;
String strIsReturnee   = null;

for(int i = 0 ; i< vRetResult.size() ; i+=23)
{
if( ((String)vRetResult.elementAt(i+2)).compareTo("1") ==0)
	strHandsOn = "(Hands on)";
else
	strHandsOn = "";
if( ((String)vRetResult.elementAt(i+3)).compareTo("1") ==0)
	strOptional = "(Optional)";
else
	strOptional = "";
//strTemp = strHandsOn+strOptional;  - i HAVE CHANGED THIS AFTER A REQUEST TO REMOVE HANDS ON IN DISPLAY.
strTemp = strOptional;

	if(vRetResult.elementAt(i + 19).equals("1"))
		strIsGraduating = "<font style='font-size:14px; color=red; font-weight:bold'>Y</font>";
	else	
		strIsGraduating = "&nbsp;";
	if(vRetResult.elementAt(i + 20).equals("1"))
		strIsAttcnbStud = "<font style='font-size:14px; color=red; font-weight:bold'>Y</font>";
	else	
		strIsAttcnbStud = "&nbsp;";

	if(vRetResult.elementAt(i + 21).equals("1"))
		strIsReturnee = "<font style='font-size:14px; color=red; font-weight:bold'>Y</font>";
	else	
		strIsReturnee = "&nbsp;";
	
%>
    <tr>
      <td height="25"><%=(String)vRetResult.elementAt(i+4)%><%=strTemp%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+6)%> <%=(String)vRetResult.elementAt(i+7)%></td>
      <td align="center"><%=astrConvertToFeeType[Integer.parseInt((String)vRetResult.elementAt(i+5))]%></td>
      <td align="center"><%=convertYearLevel[Integer.parseInt((String)vRetResult.elementAt(i+8))]%></td>
      <td align="center"><%=strConvertSem[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+13),"5"))]%></td>
      <td align="center"> <%
	  if(((String)vRetResult.elementAt(i+12)).compareTo("1") ==0){%> <img src="../../../images/tick.gif"> <%}else{%> &nbsp; <%}%> </td>
      <td align="center"> <%
	  if(((String)vRetResult.elementAt(i+11)).compareTo("1") ==0){%> <img src="../../../images/tick.gif"> <%=WI.getStrValue((String)vRetResult.elementAt(i+14),"(",")","")%> <%}else{%> &nbsp; <%}%> </td>
      <td align="center" style="font-size:8px; color:blue"> <%
	  strTemp = (String)vRetResult.elementAt(i+9);
	  if(strTemp.equals("0"))
		  strTemp = "&nbsp;";
	  else if(strTemp.equals("1"))
	  	strTemp = "<img src='../../../images/tick.gif'";
	  else if(strTemp.equals("2"))
	  	strTemp = "Cross Enrollee";
	  else if(strTemp.equals("3"))
	  	strTemp = "Transferee";
	  else	
		  strTemp = "&nbsp;";
	  		
	  %> <%=strTemp%> </td>
      <td align="center"> <%if(((String)vRetResult.elementAt(i+15)).compareTo("1") ==0){%> <img src="../../../images/tick.gif"> <%}else{%> &nbsp; <%}%> </td>
      <td align="center"> <%if(((String)vRetResult.elementAt(i+10)).compareTo("1") ==0){%> <img src="../../../images/tick.gif"> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsVMUF){%>
      <td align="center">
		<%
		strTemp = 	(String)vRetResult.elementAt(i+18);
		if(strTemp == null)
			strTemp = "&nbsp;";
		else {
			if(strTemp.equals("0"))
				strTemp = "M";
			else
				strTemp = "F";
		}%>
        <%=strTemp%>		</td>
<%}if(bolIsFatima){%>
      <td align="center"><%=strIsGraduating%></td>
<%}if(bolIsUC){%>
      <td align="center"><%=strIsAttcnbStud%></td>
<%}if(bolIsVMA){%>
      <td align="center"><%=strIsReturnee%></td>
<%}%>
<%if(bolIsDLSHSI){
strTemp = (String)vRetResult.elementAt(i+22);
if(strTemp.equals("0"))
	strTemp = "All";
else if(strTemp.equals("1")) 
	strTemp = "Reg";
else
	strTemp = "Irreg";
%>
      <td align="center"><%=strTemp%></td>
<%}%>
      <td align="center" style="font-size:11px;"> <%if(iAccessLevel ==2 ){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}else{%>
        Not authorized
        <%}%> </td>
    </tr>
    <%
	}//end of displaying levels
}//end of displaying existing question level
%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="reloadPage" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
