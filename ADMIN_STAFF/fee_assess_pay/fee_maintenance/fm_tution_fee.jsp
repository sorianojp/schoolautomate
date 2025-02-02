<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrepareToEdit(strInfoIndex)
{
	document.oth_tutionfee.editRecord.value = 0;
	document.oth_tutionfee.deleteRecord.value = 0;
	document.oth_tutionfee.addRecord.value = 0;
	document.oth_tutionfee.prepareToEdit.value = 1;
	document.oth_tutionfee.info_index.value = strInfoIndex;
	document.oth_tutionfee.submit();

}
function AddRecord()
{
	if(document.oth_tutionfee.prepareToEdit.value == 1)
	{
		EditRecord(document.oth_tutionfee.info_index.value);
		return;
	}
	document.oth_tutionfee.editRecord.value = 0;
	document.oth_tutionfee.deleteRecord.value = 0;
	document.oth_tutionfee.addRecord.value = 1;

	document.oth_tutionfee.hide_save.src = "../../../images/blank.gif";

	document.oth_tutionfee.submit();
}
function EditRecord(strTargetIndex)
{
	document.oth_tutionfee.editRecord.value = 1;
	document.oth_tutionfee.deleteRecord.value = 0;
	document.oth_tutionfee.addRecord.value = 0;

	document.oth_tutionfee.info_index.value = strTargetIndex;

	document.oth_tutionfee.submit();
}

function DeleteRecord(strTargetIndex)
{
	if(!confirm('Are you sure you want to delete this record.'))
		return;
	document.oth_tutionfee.editRecord.value = 0;
	document.oth_tutionfee.deleteRecord.value = 1;
	document.oth_tutionfee.addRecord.value = 0;

	document.oth_tutionfee.info_index.value = strTargetIndex;
	document.oth_tutionfee.prepareToEdit.value == 0;

	document.oth_tutionfee.submit();
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
	document.oth_tutionfee.info_index.value = "0";
	document.oth_tutionfee.addRecord.value = "0";
	document.oth_tutionfee.editRecord.value = "0";
	document.oth_tutionfee.prepareToEdit.value = "0";
	document.oth_tutionfee.deleteRecord.value = "0";

	ReloadPage();
}
function ReloadPage()
{
	document.oth_tutionfee.reloadPage.value="1";
	document.oth_tutionfee.addRecord.value = "";
	document.oth_tutionfee.editRecord.value = "";
	document.oth_tutionfee.deleteRecord.value = "";
	document.oth_tutionfee.submit();
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
 	
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");

	String strTutionType = request.getParameter("tution_fee_catg");
	if(strTutionType == null || strTutionType.length() == 0)
		strTutionType = "1";

	boolean bolHandsOn = false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-tuition fee","fm_tution_fee.jsp");
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
														"fm_tution_fee.jsp");
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
	strPrepareToEdit="0";

	//add it here and give a message.
	if(FA.addTutionFee(dbOP,request))
		strErrMsg = "Tuition Fee added successfully.";
	else
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
	}
}
else //either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(FA.editTutionFee(dbOP,request))
		{
			strErrMsg = "Tuition Fee edited successfully.";
			strPrepareToEdit="0";
		}
		else
		{
			bolProceed = false;
			strErrMsg = FA.getErrMsg();
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			strPrepareToEdit="0";

			if(FA.delTutionFee(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
				strErrMsg = "Tuition Fee deleted successfully.";
			else
			{
				bolProceed = false;
				strErrMsg = FA.getErrMsg();
			}
		}
	}
}

//get all levels created.
Vector vRetResult = new Vector();
Vector vEditInfo = new Vector();

if(bolProceed)
{
	vRetResult = FA.viewTutionFee(dbOP, request,true);//to view all
}

if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = FA.viewTutionFee(dbOP,request, false);//view all is false
	if(vEditInfo == null || vEditInfo.size() == 0)
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Edit information not found. Please refresh page and edit again.";
	}
}

//do not proceed is bolProceed = false;
if(!bolProceed)
{
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="2">
	<b><%=strErrMsg%></b></font></p>
	<%
	return;
}

String strSYFrom = null;
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0) )
		strSYFrom = (String)vEditInfo.elementAt(1);
	else
		strSYFrom = WI.fillTextValue("sy_from");

if(strSYFrom == null || strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");

%> 


<form name="oth_tutionfee" action="./fm_tution_fee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>::::
          TUITION FEE RATE MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="3">Please specify fee rate Type 
        <%
//	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
//		strTemp = (String)vEditInfo.elementAt(4);
//	else
		strTemp = request.getParameter("tution_fee_catg");
	if(strTemp == null) strTemp = "";
	%>
        <select name="tution_fee_catg" onChange="ReloadPage();">
          <%=dbOP.loadCombo("MANUAL_INDEX","CATEGORY"," from FA_TUTION_FEE_CATG", strTemp, false)%>
        </select>
        <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>
        <font size="1">Click refresh to view fees. </font> </td>
    </tr>
<%
if(strSchoolCode.startsWith("CIT")){%>
    <tr style="font-weight:bold; color:#0000FF;">
      <td height="25">&nbsp;</td>
      <td colspan="3">Applicable SY Range<font style="font-weight:bold; color:#FF0000">*</font> :
	  <select name="id_sy_range" onChange="ReloadPage();">
	  	<option value="">All</option>
          <%=dbOP.loadCombo("ID_RANGE_INDEX","RANGE_SY_FROM,RANGE_SY_TO"," from FA_CIT_IDRANGE where IS_ACTIVE_RECORD=1 and eff_fr_sy = "+strSYFrom+" order by RANGE_SY_FROM asc", WI.fillTextValue("id_sy_range"), false)%> 
	  </select>
<strong><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a><font size="1">click 
        to refresh page</font></strong>	  
	  
	  </td>
    </tr>
<%}%>
	<tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>

<%
if(strTutionType.compareTo("1") ==0) //display depending on the tution type.
{
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="5" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%"> School year</td>
      <td width="41%">

        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("oth_tutionfee","sy_from","sy_to")'>
        to
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("sy_to");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(14);
	else
		strTemp = request.getParameter("semester");
	if(strTemp == null) strTemp = "";
	%>
        <select name="semester">
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
        </select> </td>
      <td width="11%">Year Level </td>
      <td width="32%">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("year_level");
	if(strTemp == null) strTemp = "";
	%>
        <select name="year_level">
          <%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>ALL</option>
          <%}else{%>
          <option value="0">ALL</option>
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
        </select>
      </td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td>
	    <select name="c_index" onChange="ReloadPage();" style="font-size:14px;background:#DFDBD2; width:400;">
          <option></option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where is_del=0 order by c_name asc", WI.fillTextValue("c_index"), false)%> 
        </select>
	  </td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="14%">Course</td>
      <td><font size="1">
        <input type="text" name="scroll_course" size="16" style="font-size:9px" class="textbox" 
	  onKeyUp="AutoScrollList('oth_tutionfee.scroll_course','oth_tutionfee.course_index',true);"
	   onBlur="ReloadPage()">
        (course code to scroll course list)</font> <font size="1">
        <%
strTemp = WI.fillTextValue("remove_not_offered");
if(strTemp.equals("1") || request.getParameter("reloadPage") == null)
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="remove_not_offered" value="1"<%=strTemp%> onClick="ReloadPage();">
Remove the courses not offered. </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = request.getParameter("course_index");
	if(strTemp == null) strTemp = "";
	if(WI.fillTextValue("remove_not_offered").length() > 0 || request.getParameter("reloadPage") == null)
		strErrMsg = " and is_offered = 1";
	else	
		strErrMsg = "";
	if(WI.fillTextValue("c_index").length() > 0)
		strErrMsg += " and c_index = "+WI.fillTextValue("c_index")+" ";
	%>
        <select name="course_index" onChange="ReloadPage();" style="font-size:14px;background:#DFDBD2; width:700;">
          <option value="selany">&lt;Select Any&gt;</option>
          <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name as cname"," from course_offered where IS_DEL=0 AND IS_VALID=1"+strErrMsg+" order by cname asc", strTemp, false)%> 
        </select>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major </td>
      <td><select name="major_index">
          <option></option>
          <%strErrMsg = "";
String strDefValue = null;
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strDefValue = (String)vEditInfo.elementAt(5);
	else
		strDefValue = request.getParameter("major_index");
	if(strDefValue == null) strTemp = "";

if(strTemp != null && strTemp.compareTo("selany") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strDefValue, false)%> 
          <%}%>
        </select> <a href="javascript:ReloadPage();"><img src="../../../images/view.gif" border="0"></a> 
        <font size="1">enter SY and year level/course and major to view tuition 
        fees. </font> </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Fee Type</td>
      <td> <%if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(12);
	else
		strTemp = request.getParameter("fee_catg");
	if(strTemp == null) strTemp = "";
	%> <select name="fee_catg" onChange="ReloadPage();">
          <%
	 if(strTemp.compareTo("0") == 0){%>
          <option value="0" selected>per unit</option>
          <%}else{%>
          <option value="0">per unit</option>
          <%}if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>per lab/lec unit</option>
          <%}else{%>
          <option value="1">per lab/lec unit</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>per subject</option>
          <%}else{%>
          <option value="2">per subject</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>Total tuition fee</option>
          <%}else{%>
          <option value="3">Total tuition fee</option>
          <%}if(strTemp.compareTo("5") == 0){%>
          <option value="5" selected>Per Subject Group (per unit)</option>
          <%}else{%>
          <option value="5">Per Subject Group (per unit)</option>
          <%}%>
        </select> 
        <!-- show amount per lec / lab only if it is selected or show one input only for amount.-->
        <%
 if(strTemp.compareTo("5") == 0) {
 
 if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(6);
	else
		strTemp = request.getParameter("sub_catg");
	if(strTemp == null) strTemp = "";
	%> <select name="sub_catg">
          <%=dbOP.loadCombo("group_index","group_NAME"," from SUBJECT_group where IS_DEL=0 order by group_NAME asc", strTemp, false)%> </select> <%}//only if sub_catg is selected.%> </td>
    </tr>
    <%//SHOW ONLY TO UI
 if(strSchoolCode != null && (strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("WNU") ||
  strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("EAC") || strSchoolCode.startsWith("SPC") ||
  strSchoolCode.startsWith("UPH") || strSchoolCode.startsWith("UB") || strSchoolCode.startsWith("SWU") ||
 			((String)request.getSession(false).getAttribute("userId")).compareTo("1770") == 0) ) {%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td><strong><font color="#0000FF">PER HOUR STUDENT LOAD COMPUTATION </font></strong> 
        <%if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
	strTemp = (String)vEditInfo.elementAt(13);
  else
	strTemp = request.getParameter("compute_per_hour");
 if(strTemp != null && strTemp.compareTo("1") == 0)
 	strTemp = " checked";
  else	
  	strTemp = "";
	%> <input type="checkbox" name="compute_per_hour" value="1" <%=strTemp%>></td>
    </tr>
    <%}%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Fee rate </td>
      <td> <%
if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(12);
	else
		strTemp = request.getParameter("fee_catg");
	if(strTemp == null) strTemp = "";	  
if(strTemp.length() ==0 || strTemp.compareTo("1") != 0) //do not show for lec or lab unit
{
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(8);
	else
		strTemp = request.getParameter("amount");
	if(strTemp == null) strTemp = "";
	%> <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <!--hide or show-->
        <%}else{

	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(10);
	else
		strTemp = request.getParameter("amt_per_lab");
	if(strTemp == null) strTemp = "";
	%> <input name="amt_per_lab" type="text" size="8" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <font size="1">(amount for lab)</font> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(9);
	else
		strTemp = request.getParameter("amt_per_lec");
	if(strTemp == null) strTemp = "";
	%> <input name="amt_per_lec" type="text" size="8" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
  	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <font size="1">(amount for lec) </font> <%}
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
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}else if(strTutionType.compareTo("2") ==0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr>
   <td width="4%">&nbsp;</td>
   <td width="15%">&nbsp;</td>
   <td width="32%">&nbsp;</td>
   <td width="48%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td> School
        year</td>
      <td>
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0) )
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("sy_from");
	if(strTemp == null) strTemp = "";
	%>        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        to
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("sy_to");
	if(strTemp == null) strTemp = "";
	%><input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(14);
	else
		strTemp = request.getParameter("semester");
	if(strTemp == null) strTemp = "";
	%>
        <select name="semester">
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
        </select> </td>
      <td>Year Level
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("year_level");
	if(strTemp == null) strTemp = "";
	%>	   <select name="year_level">
          <%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>ALL</option>
          <%}else{%>
          <option value="0">ALL</option>
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
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Subject
        category<strong> </strong></td>
      <td height="25">
	<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(6);
	else
		strTemp = request.getParameter("sub_catg");
	if(strTemp == null) strTemp = "";
	%>    <select name="sub_catg">
          <%=dbOP.loadCombo("CATG_INDEX","CATG_NAME"," from SUBJECT_CATG where IS_DEL=0 order by CATG_NAME asc", strTemp, false)%>
        </select>
      </td>
      <td> <a href="javascript:ReloadPage();"><img src="../../../images/view.gif" border="0"></a> 
        <font size="1">enter SY and year level/subject category to view tuition 
        fees. </font></td>
    </tr>

    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Fee Type</td>
      <td colspan="2" height="26">
<%if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(12);
	else
		strTemp = request.getParameter("fee_catg");
	if(strTemp == null) strTemp = "";
	%>
	        <select name="fee_catg" onChange="ReloadPage();">
        <%
	 if(strTemp.compareTo("0") == 0){%>
	      <option value="0" selected>per unit</option>
	 <%}else{%><option value="0">per unit</option>
	<%}if(strTemp.compareTo("1") == 0){%>
		<option value="1" selected>per lab/lec unit</option>
	<%}else{%><option value="1">per lab/lec unit</option>
	<%}if(strTemp.compareTo("2") == 0){%>
		<option value="2" selected>per subject</option>
	<%}else{%><option value="2">per subject</option>
	<%}%>
        </select><!-- show amount per lec / lab only if it is selected or show one input only for amount.-->
      </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Fee
        rate </td>
      <td colspan="2" height="26">
<%
if(strTemp.length() ==0 || strTemp.compareTo("1") != 0) //do not show for lec or lab unit
{
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(8);
	else
		strTemp = request.getParameter("amount");
	if(strTemp == null) strTemp = "";
	%>
	  <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><!--hide or show-->

<%}else{

	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(10);
	else
		strTemp = request.getParameter("amt_per_lab");
	if(strTemp == null) strTemp = "";
	%>
        <input name="amt_per_lab" type="text" size="8" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">(amount for lab)</font>
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(9);
	else
		strTemp = request.getParameter("amt_per_lec");
	if(strTemp == null) strTemp = "";
	%>
	    <input name="amt_per_lec" type="text" size="8" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">(amount for lec) </font>


<%}
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(11);
	else
		strTemp = request.getParameter("currency");
	if(strTemp == null) strTemp = "";
	%>
	<select name="currency">
          <%if(strTemp.compareToIgnoreCase("php") ==0){%> <option value="Php" selected>Php</option>
		  <%}else{%> <option value="Php">Php</option>
		  <%}if(strTemp.compareToIgnoreCase("US$") ==0){%><option value="US$" selected>US$</option>
		  <%}else{%><option value="US$">US$</option><%}%>
        </select>


	  </td>
    </tr>
    <tr>
      <td height="25">
      <td>&nbsp; </td>
      <td colspan="2" height="25">&nbsp;</td>
      <td width="1%">&nbsp;</td>
    </tr>
  </table>

<%}else if(strTutionType.compareTo("3") == 0){//by subject.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> School year</td>
      <td width="33%"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0) )
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("sy_from");
	if(strTemp == null) strTemp = "";
	%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp='DisplaySYTo("oth_tutionfee","sy_from","sy_to")'>
        to 
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("sy_to");
	if(strTemp == null) strTemp = "";
	%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(14);
	else
		strTemp = request.getParameter("semester");
	if(strTemp == null) strTemp = "";
	%>
        <select name="semester">
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
      </select> </td>
      <td width="10%" align="RIGHT">Year Level</td>
      <td width="41%" colspan="3"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("year_level");
	if(strTemp == null) strTemp = "";
	%> <select name="year_level">
          <%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>ALL</option>
          <%}else{%>
          <option value="0">ALL</option>
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
    </tr>
    <tr> 
      <td  width="3%"height="25">&nbsp;</td>
      <td width="13%">Subject code</td>
      <td colspan="5"> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(7);
	else
		strTemp = request.getParameter("sub_code");
	if(strTemp == null) strTemp = "";
	%> <select name="sub_code" onChange="ReloadPage();">
          <option value="">Select a subject</option>
          <%=dbOP.loadCombo("SUB_INDEX","SUB_CODE"," from SUBJECT where IS_DEL=0 order by sub_code asc", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Sub name</td>
      <td colspan="3" height="26">&nbsp; <%
	  if(WI.fillTextValue("sub_code").length() > 0){%> <%=dbOP.mapOneToOther("subject","sub_index",WI.fillTextValue("sub_code"),"sub_name",null)%> <%}%></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Course</td>
      <td colspan="3" height="26"><font size="1">
        <input type="text" name="scroll_course" size="16" style="font-size:9px" class="textbox" 
	  onKeyUp="AutoScrollList('oth_tutionfee.scroll_course','oth_tutionfee.sub_index_course',true);">
(enter course code to scroll course list)
&nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("remove_not_offered");
if(strTemp.equals("1") || request.getParameter("reloadPage") == null)
	strTemp = " checked";
else	
	strTemp = "";
%>
<input type="checkbox" name="remove_not_offered" value="1"<%=strTemp%> onChange="ReloadPage();"> Remove the courses not offered.

      </font></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26" colspan="4"><%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = request.getParameter("course_index");
	if(strTemp == null) 
		strTemp = "";
	if(WI.fillTextValue("remove_not_offered").length() > 0 || request.getParameter("reloadPage") == null)
		strErrMsg = " and is_offered = 1";
	else	
		strErrMsg = "";
	%>
        <select name="sub_index_course" style="font-size:11px;background:#DFDBD2;">
          <option value="0">&lt;Select Any&gt;</option>
          <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name as cname"," from course_offered where IS_DEL=0 AND IS_VALID=1"+strErrMsg+" order by cname asc", strTemp, false)%>
        </select></td>
    </tr>
 <%strErrMsg = "";//SHOW ONLY TO UI
 if(strSchoolCode != null && (strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("DBTC")
  || strSchoolCode.startsWith("SPC"))) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="5"><strong><font color="#0000FF">PER HOUR STUDENT LOAD COMPUTATION </font></strong> 
<%if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
	strTemp = (String)vEditInfo.elementAt(13);
  else
	strTemp = request.getParameter("compute_per_hour");
 if(strTemp != null && strTemp.compareTo("1") == 0)
 	strTemp = " checked";
  else	
  	strTemp = "";
	%>        <input type="checkbox" name="compute_per_hour" value="1" <%=strTemp%>></td>
    </tr>
 <%}%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Fee Type</td>
      <td colspan="3" height="26"> <%if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(12);
	else
		strTemp = request.getParameter("fee_catg");
	if(strTemp == null) strTemp = "";
	%> <select name="fee_catg" onChange="ReloadPage();">
          <%
	 if(strTemp.compareTo("0") == 0){%>
          <option value="0" selected>per unit</option>
          <%}else{%>
          <option value="0">per unit</option>
          <%}if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>per lab/lec unit</option>
          <%}else{%>
          <option value="1">per lab/lec unit</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>per subject</option>
          <%}else{%>
          <option value="2">per subject</option>
          <%}if(strTemp.compareTo("4") == 0){%>
          <option value="4" selected>Per Hour</option>
          <%}else{%>
          <option value="4">Per Hour</option>
          <%}%>
        </select> 
        <!-- show amount per lec / lab only if it is selected or show one input only for amount.-->      </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Fee rate </td>
      <td colspan="3" height="26"> <%
if(strTemp.length() ==0 || strTemp.compareTo("1") != 0) //do not show for lec or lab unit
{
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(8);
	else
		strTemp = request.getParameter("amount");
	if(strTemp == null) strTemp = "";
	%> <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <!--hide or show-->
        <%}else{

	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(10);
	else
		strTemp = request.getParameter("amt_per_lab");
	if(strTemp == null) strTemp = "";
	%> <input name="amt_per_lab" type="text" size="8" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font size="1">(amount for lab)</font> <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(9);
	else
		strTemp = request.getParameter("amt_per_lec");
	if(strTemp == null) strTemp = "";
	%> <input name="amt_per_lec" type="text" size="8" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font size="1">(amount for lec) </font> <%}
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
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td colspan="4">&nbsp;</td>
    </tr>
  </table>
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="10%"> School
        year</td>
      <td width="29%">
       <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0) )
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("sy_from");
	if(strTemp == null) strTemp = "";
	%>        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        to
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("sy_to");
	if(strTemp == null) strTemp = "";
	%><input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(14);
	else
		strTemp = request.getParameter("semester");
	if(strTemp == null) strTemp = "";
	%>
        <select name="semester">
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
      </select> </td>
      <td width="9%" align="right">Year level </td>
      <td width="47%">
	  <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("year_level");
	if(strTemp == null) strTemp = "";
	%>	   <select name="year_level">
          <%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>ALL</option>
          <%}else{%>
          <option value="0">ALL</option>
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
        </select>
        <a href="javascript:ReloadPage();"><img src="../../../images/view.gif" border="0"></a> 
      <font size="1">enter SY and year level to view tuition fees. </font> </td>
<td width="4%">&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Fee Type</td>
      <td colspan="4" height="26">
<%if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(12);
	else
		strTemp = request.getParameter("fee_catg");
	if(strTemp == null) strTemp = "";
	%>
	        <select name="fee_catg" onChange="ReloadPage();">
        <%
	 if(strTemp.compareTo("0") == 0){%>
	      <option value="0" selected>per unit</option>
	 <%}else{%><option value="0">per unit</option>
	<%}if(strTemp.compareTo("1") == 0){%>
		<option value="1" selected>per lab/lec unit</option>
	<%}else{%><option value="1">per lab/lec unit</option>
	<%}if(strTemp.compareTo("2") == 0){%>
		<option value="2" selected>per subject</option>
	<%}else{%><option value="2">per subject</option>
	<%}%>
        </select><!-- show amount per lec / lab only if it is selected or show one input only for amount.-->
      </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">Fee
        rate </td>
      <td colspan="4" height="26">
<%
if(strTemp.length() ==0 || strTemp.compareTo("1") != 0) //do not show for lec or lab unit
{
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(8);
	else
		strTemp = request.getParameter("amount");
	if(strTemp == null) strTemp = "";
	%>
	  <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><!--hide or show-->

<%}else{

	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(10);
	else
		strTemp = request.getParameter("amt_per_lab");
	if(strTemp == null) strTemp = "";
	%>
        <input name="amt_per_lab" type="text" size="8" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">(amount for lab)</font>
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(9);
	else
		strTemp = request.getParameter("amt_per_lec");
	if(strTemp == null) strTemp = "";
	%>
	    <input name="amt_per_lec" type="text" size="8" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">(amount for lec) </font>


<%}
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(11);
	else
		strTemp = request.getParameter("currency");
	if(strTemp == null) strTemp = "";
	%>
	<select name="currency">
          <%if(strTemp.compareToIgnoreCase("php") ==0){%> <option value="Php" selected>Php</option>
		  <%}else{%> <option value="Php">Php</option>
		  <%}if(strTemp.compareToIgnoreCase("US$") ==0){%><option value="US$" selected>US$</option>
		  <%}else{%><option value="US$">US$</option><%}%>
        </select>


	  </td>
    </tr>
</table>
 <%}//end of display depending on the tution fees type
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(iAccessLevel > 1){
if(strSchoolCode.startsWith("UC") || strSchoolCode.startsWith("SWU") || strSchoolCode.startsWith("UPH")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-weight:bold; color:#0000FF; font-size:11px;">Fee Applicable to: 
	  <select name="new_old_stat">
	  	<option value="0"></option>
<%
if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
	strTemp = (String)vEditInfo.elementAt(16);
else
	strTemp = request.getParameter("new_old_stat");
if(strTemp == null) 
	strTemp = "";
String strTemp2 = null;
if(strTemp.equals("1"))
	strTemp2 = " selected";
else	
	strTemp2 = "";
%>		
		<option value="1"<%=strTemp2%>>New</option>
<%
if(strTemp.equals("2"))
	strTemp2 = " selected";
else	
	strTemp2 = "";
%>		
		<option value="2"<%=strTemp2%>>Old</option>
	  </select>
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25" width="3%">&nbsp; </td>
      <td><%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0" name="hide_save"></a><font size="1">click
        to add</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%></td>
    </tr>
	<%}//if iAccessLevel > 1
if(strErrMsg != null)
{%> <tr>
  	<td height="25">&nbsp;</td>
      <td><b><font size=3><%=strErrMsg%></font></b></td>
    </tr>
    <%}//this shows the edit/add/delete success info%>
<tr>
  	<td height="25">&nbsp;</td>
      <td>NOTE : BY SPECIFIC SUBJECT tuition type fees are displayed in blue color</td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td height="25"><div align="center">LIST OF TUITION FEES</div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr align="center" style="font-weight:bold"> 
      <td width="45%" height="25"><div align="center"><font size="1"><strong>FEE 
          FOR</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>FEE (Php/$) </strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>YEAR LEVEL</strong></font></div></td>
      <td width="7%"><div align="center"><strong><font size="1">TERM</font></strong></div></td>
<%if(strSchoolCode != null && (strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("UB")) ){%>
      <td width="7%"><div align="center"><font size="1"><strong>COMPUTE PER HOUR</strong></font></div></td>
<%}if(strSchoolCode.startsWith("UC") || strSchoolCode.startsWith("SWU") || strSchoolCode.startsWith("UPH")){%>
      <td width="7%"><font size="1">NEW/OLD</font></td>
<%}%>
      <td width="7%" align="center"><strong><font size="1">&nbsp;EDIT</font></strong></td>
      <td width="9%" align="center"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%//System.out.println(vRetResult);
boolean bolIsCourseType = true;
if(WI.fillTextValue("tution_fee_catg").compareTo("1") != 0) 
	bolIsCourseType = false;
boolean bolShowEdit = true;//if per subject, and per course is selected, i should not show edit. 
	
String[] convertYearLevel = {"ALL","1st","2nd","3rd","4th","5th","6th","7th","8th","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;","&nbsp;"};//System.out.println(vRetResult);
String[] convertTERM = {"S","1ST","2ND","3RD","4TH","ALL"};//System.out.println(vRetResult);


//System.out.println(vRetResult);
for(int i = 0 ; i< vRetResult.size() ; i +=8 ) {
if( vRetResult.elementAt(i+3) != null && ((String)vRetResult.elementAt(i+3)).startsWith("<font")) {
	if(bolIsCourseType)
		bolShowEdit = false;
	else	
		bolShowEdit = true;
}
else {
	if(bolIsCourseType)
		bolShowEdit = true;
	else	
		bolShowEdit = false;		
}
%>
    <tr> 
      <td height="25" align="center"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+1)%> <%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center"><%=convertYearLevel[Integer.parseInt((String)vRetResult.elementAt(i+4))]%></td>
      <td align="center"><%=convertTERM[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+6),"5"))]%></td>
<%if(strSchoolCode != null && strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("DBTC") || strSchoolCode.startsWith("UB")){%>
      <td align="center"> <%if( vRetResult.elementAt(i + 5) != null && ((String)vRetResult.elementAt(i + 5)).compareTo("1") == 0){%> <img src="../../../images/tick.gif">
<%}else{%><img src="../../../images/x.gif"><%}%></td>
<%}if(strSchoolCode.startsWith("UC") || strSchoolCode.startsWith("SWU") || strSchoolCode.startsWith("UPH")){
strTemp = (String)vRetResult.elementAt(i + 7);
if(strTemp.equals("0"))
	strTemp = "&nbsp;";
else if(strTemp.equals("1"))
	strTemp = "New";
else	
	strTemp = "Old";
%>
      <td align="center"><%=strTemp%></td>
<%}%>
      <td align="center"> <%if(iAccessLevel > 1 && bolShowEdit){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
        <%}else{%>
        N/A 
        <%}%> </td>
      <td align="center"> <%if(iAccessLevel ==2){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%>
        N/A 
        <%}%> </td>
    </tr>
    <%
	}//end of for loop
%>
  </table>
<%}//if vRetResult.size() > 0 %>
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
