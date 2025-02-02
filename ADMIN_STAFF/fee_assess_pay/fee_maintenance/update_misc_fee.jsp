<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
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
	else if(document.oth_miscfee.is_for_new.checked)
			if(document.oth_miscfee.is_yearly.checked)
				document.oth_miscfee.is_yearly.checked = false;
}

function CheckIfLegal()
{
	if(document.oth_miscfee.update_factor_unit.selectedIndex ==0)
	{
		if(document.oth_miscfee.update_factor.value.length > 0)
		alert("You have selected Update factor <No Change>. Please change to <Percentage> or <Specific amount> type. Otherwise, the fees will be unchanged.");
		//document.update_othsch.amount.value="";
	}
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
	//calculate the amount here.
	var updateFactorUnit = document.oth_miscfee.update_factor_unit.selectedIndex;
	var amount = document.oth_miscfee.amount_prev.value;
	var updateFactor = document.oth_miscfee.update_factor.value;
	if(updateFactorUnit == "") updateFactorUnit = 0;
	if(amount == "" || amount=="null") amount = 0;
	if(updateFactor == "") updateFactor = 0;

	document.oth_miscfee.fee_name.value=document.oth_miscfee.select_fee_name[document.oth_miscfee.select_fee_name.selectedIndex].text;
	//alert(document.oth_miscfee.fee_name.value);
	//alert(updateFactor);
	//alert(amount);
	if(updateFactorUnit == 0) //No change.
	{
		document.oth_miscfee.update_factor.value = 0;
		document.oth_miscfee.amount.value = document.oth_miscfee.amount_prev.value;
	}
	if(updateFactorUnit == 1) //percent.
	{
		document.oth_miscfee.amount.value = Number(amount)+Number(amount)*Number(updateFactor)/100;
	}
	else if(updateFactorUnit == 2) // specific amount.
	{
		document.oth_miscfee.amount.value = updateFactor;
		document.oth_miscfee.update_factor.value = 0;
	}
	//alert(document.oth_miscfee.amount.value);
	//return;

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
function EditRecord()
{
	document.oth_miscfee.editRecord.value = 1;
	document.oth_miscfee.deleteRecord.value = 0;
	document.oth_miscfee.addRecord.value = 0;

	document.oth_miscfee.submit();
}

function DeleteRecord(strTargetIndex)
{
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
	document.oth_miscfee.addRecord.value = "0";
	document.oth_miscfee.editRecord.value = "0";
	document.oth_miscfee.prepareToEdit.value = "0";
	document.oth_miscfee.deleteRecord.value = "0";

	ReloadPage();
}
function ReloadPage()
{
	document.oth_miscfee.copy_all.value="";
	document.oth_miscfee.reloadPage.value="1";
	document.oth_miscfee.submit();
}
function CopyAll()
{
	document.oth_miscfee.copy_all.value="1";
	document.oth_miscfee.submit();
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceUpdate,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
	String[] aStrPrevYrInfo = {"0","0","0","0","0"};//0=optional, 1=handson, 2= subject catg_index, 3=amount. 4= if values is set or not.
	//this value is set in prevYrMiscFeeDetail method.

	boolean bolHandsOn = false;

	boolean bolShowDetail = false;//true only if view is clicked. and sy_from_prev and sy_to_prev are valid.
	if( (request.getParameter("sy_from_prev") != null && request.getParameter("sy_from_prev").trim().length() >0 &&
		request.getParameter("sy_to_prev") != null && request.getParameter("sy_to_prev").trim().length() >0) ||
		(request.getParameter("sy_from") != null && request.getParameter("sy_from").trim().length() >0 &&
		request.getParameter("sy_to") != null && request.getParameter("sy_to").trim().length() >0) ||
		strPrepareToEdit.compareTo("1") ==0)
		bolShowDetail = true;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-update misc fee","update_misc_fee.jsp");
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
														"update_misc_fee.jsp");
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

FAFeeMaintenanceUpdate FA = new FAFeeMaintenanceUpdate();
boolean bolProceed = true;

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	strPrepareToEdit="0";

	//add it here and give a message.
	if(FA.addMiscFee(dbOP,request))
		strErrMsg = "Miscellaneous Fee(Update) added successfully.";
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
		if(FA.editMiscFee(dbOP,request))
		{
			strPrepareToEdit = "0";
			strErrMsg = "Miscellaneous Fee(Update) edited successfully.";
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

			if(FA.delMiscFee(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
				strErrMsg = "Miscellaneous Fee deleted successfully.";
			else
			{
				bolProceed = false;
				strErrMsg = FA.getErrMsg();
			}
		}
	}
}
if(WI.fillTextValue("copy_all").compareTo("1") ==0) //-> copy per year, to copy all year, keep year_level null ;-)
{
	strPrepareToEdit = "0";
	if(FA.copyAllMiscFee(dbOP, request.getParameter("sy_from_prev"),request.getParameter("sy_to_prev"),
			request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("course_index"),
			request.getParameter("major_index"),(String)request.getSession(false).getAttribute("userId"),WI.fillTextValue("year_level")))
		strErrMsg = "Miscellaneous fees copied successfully.";
	else
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
	}
}

//get all levels created.
Vector vRetResult = new Vector();
Vector vEditInfo = new Vector();
Vector vAllowedUpdateList = new Vector();


if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = FA.viewMiscFee(dbOP,request.getParameter("info_index"));//view all is false
	if(vEditInfo == null || vEditInfo.size() == 0)
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Edit information not found. Please refresh page and edit again.";
	}
}
if(bolProceed)
{
	//get the sy_from_prev , sy_to_prev.
	vRetResult = FA.viewAllMiscFee(dbOP,request.getParameter("course_index"),request.getParameter("major_index"),
							request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("year_level"));
	if(vEditInfo == null || vEditInfo.size() == 0)
		vAllowedUpdateList = FA.getPrevMiscFee(dbOP,request.getParameter("course_index"),request.getParameter("major_index"),
							request.getParameter("sy_from_prev"),request.getParameter("sy_to_prev"),request.getParameter("year_level"));
	else
		vAllowedUpdateList = FA.getPrevMiscFee(dbOP,(String)vEditInfo.elementAt(5),(String)vEditInfo.elementAt(6),
								(String)vEditInfo.elementAt(18),(String)vEditInfo.elementAt(19),request.getParameter("year_level"));
//System.out.println((String)vEditInfo.elementAt(18));
//System.out.println((String)vEditInfo.elementAt(19));
}

//amount to display when fees is selected.
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(16);//misc fee index
	else
		strTemp = request.getParameter("select_fee_name");
if(strTemp == null || strTemp.trim().length() == 0)
	strTemp = "0";
//get strAmount here.
if(!FA.prevYrMiscFeeDetail(dbOP,strTemp,aStrPrevYrInfo))//get the amount here.
{
	bolProceed = false;
	strErrMsg = FA.getErrMsg();
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
%>


<form name="oth_miscfee" action="./update_misc_fee.jsp" method="post">

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          UPDATE MISCELLANEOUS/OTHER CHARGES FEES MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
<!--    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4">Check if fee is only for new enrollees 
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(20);
	else
		strTemp = request.getParameter("is_for_new");
	if(strTemp == null || strTemp.compareTo("0") ==0) strTemp = "";
	else
		strTemp = " checked";
	%>
        <input type="checkbox" name="is_for_new" value="1"<%=strTemp%> onClick="SwitchNewYearlyFee();"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4">Check if fee is for once a Year 
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(21);
	else
		strTemp = request.getParameter("is_yearly");
	if(strTemp == null || strTemp.compareTo("0") ==0) strTemp = "";
	else
		strTemp = " checked";
	%>
        <input type="checkbox" name="is_yearly" value="1"<%=strTemp%> onClick="SwitchNewYearlyFee();"></td>
    </tr> It should follow the previous year info-->
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td width="16%">School year (previous)</td>
      <td width="30%">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0) )
		strTemp = (String)vEditInfo.elementAt(18);
	else
		strTemp = request.getParameter("sy_from_prev");
	if(strTemp == null) strTemp = "";
	%>
        <input name="sy_from_prev" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("oth_miscfee","sy_from_prev","sy_to_prev")'>
        to
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(19);
	else
		strTemp = request.getParameter("sy_to_prev");
	if(strTemp == null) strTemp = "";
	%>
        <input name="sy_to_prev" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
      </td>
      <td colspan="2">Year level
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = request.getParameter("year_level");
	if(strTemp == null) strTemp = "";
	%>
        <select name="year_level" onChange="ReloadPage();">
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
        </select>
      </td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td width="16%">New School year</td>
      <td width="30%">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0) )
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("sy_from");
	if(strTemp == null) strTemp = "";
	%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("oth_miscfee","sy_from","sy_to")'>
        to
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("sy_to");
	if(strTemp == null) strTemp = "";
	%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
      </td>
      <td>&nbsp;</td>
      <td width="25%" colspan="-1">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course </td>
      <td colspan="3">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(5);
	else
		strTemp = request.getParameter("course_index");
	if(strTemp == null) strTemp = "";
	%>
        <select name="course_index" onChange="ReloadPage();">
          <option value="0">Select Any</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", strTemp, false)%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Major </td>
      <td colspan="3"><select name="major_index">
          <option></option>
          <%
if(strTemp != null && strTemp.compareTo("0") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select> <input name="image" type="image" src="../../../images/view.gif">
        <font size="1"><em>View fees detail for this year </em> <strong>(OR)</strong>
        <a href='javascript:CopyAll();'><img src="../../../images/copy_all.gif" border="0"></a>copy
        all fee from prev. school year.</font></td>
    </tr>
    <%
if(bolShowDetail)//show until the view all table..
{%>
 <!--   <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
        <%
	//if aStrPrevYrInfo is set use this value -- else consider other factors.
	if(aStrPrevYrInfo[4].compareTo("1") ==0)
		strTemp = aStrPrevYrInfo[0];
	else
	{
		if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
			strTemp = (String)vEditInfo.elementAt(10);
		else
			strTemp = request.getParameter("is_optional");
	}
	if(strTemp == null) strTemp = "";


	if(strTemp.compareTo("0") ==0 || strTemp.length() == 0)
	{%>
        <input name="is_optional" type="checkbox" value="1">
        <%}else{%>
        <input name="is_optional" type="checkbox" checked value="1">
        <%}%>
        Optional Fee<font size="1">&nbsp;</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
        <%
	if(aStrPrevYrInfo[4].compareTo("1") ==0)
		strTemp = aStrPrevYrInfo[1];
	else
	{
		if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
			strTemp = (String)vEditInfo.elementAt(9);
		else
			strTemp = request.getParameter("is_handson");
	}
	if(strTemp == null) strTemp = "";

	if(strTemp.compareTo("0") ==0 || strTemp.length() == 0)
	{%>
        <input name="is_handson" type="checkbox" value="1" onClick="ReloadPage();">
        <%}else{
	bolHandsOn = true;%>
        <input name="is_handson" type="checkbox" value="1" checked onClick="ReloadPage();">
        <%}%>
        Check if hands on <a href="javascript:WhatIsHandsOn();"><img src="../../..//images/online_help.gif" border="0"></a><font size="1">What
        is hands on </font></td>
    </tr>
    <%
	if(bolHandsOn)
	{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">Hands on Sub Category &nbsp;&nbsp;
        <%
	if(aStrPrevYrInfo[4].compareTo("1") ==0)
		strTemp = aStrPrevYrInfo[2];
	else
	{
		if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
			strTemp = (String)vEditInfo.elementAt(7);
		else
			strTemp = request.getParameter("catg_index");
	}
	if(strTemp == null) strTemp = "";
	%>
        <select name="catg_index">
          <%=dbOP.loadCombo("catg_index","catg_name"," from subject_catg where IS_DEL=0 order by catg_name asc", strTemp, false)%>
        </select> &nbsp; <font size="1"><em>only if hands on selected</em>.</font></td>
    </tr>
    <%}%>-->
    <tr>
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Fee
        name</td>
      <td  colspan="2">

<%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(16);//misc fee index
	else
		strTemp = request.getParameter("select_fee_name");
	if(strTemp == null) strTemp = "";
	%>
	 <select name="select_fee_name" onChange="ReloadPage();">
	 <option value="0">ALL</option>
<%
if(vAllowedUpdateList!= null)
	for(int i=0; i < vAllowedUpdateList.size(); ++i)
	{
		if(strTemp.compareTo((String)vAllowedUpdateList.elementAt(i)) ==0)
		{%>
		<option selected value="<%=(String)vAllowedUpdateList.elementAt(i++)%>"><%=(String)vAllowedUpdateList.elementAt(i)%></option>
	<%}else{%>
		<option value="<%=(String)vAllowedUpdateList.elementAt(i++)%>"><%=(String)vAllowedUpdateList.elementAt(i)%></option>
	<%}
	}%>

	        </select>
<%
//if edit info is clicked, and fee name is not displayed in the selected previous list - show a edit box. -
//this is done to edit the fees not having update information.
if( (vAllowedUpdateList == null || vAllowedUpdateList.size() ==0) && vEditInfo != null && vEditInfo.size()>1)
{%>
<input type="text" name="fee_name" value="<%=(String)vEditInfo.elementAt(3)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%}%>
<input type="hidden" name="fee_name" value="<%=request.getParameter("fee_name")%>">
        <font size="1"><em>(fees available for year <%=request.getParameter("sy_from_prev")%>-<%=request.getParameter("sy_to_prev")%>
        to add to new school year)</em></font></td>
    </tr>
		    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee rate (prev)</td>
      <td  colspan="4">
<%
	if(aStrPrevYrInfo[4].compareTo("1") ==0)
		aStrPrevYrInfo[3] = CommonUtil.formatFloat(aStrPrevYrInfo[3], true);
	else
	{
		if(vEditInfo != null && vEditInfo.size() > 1)
			aStrPrevYrInfo[3] = CommonUtil.formatFloat((String)vEditInfo.elementAt(17), true);
	}
	%>
	        <%=aStrPrevYrInfo[3]%> Php
<input type="hidden" name="amount_prev" value="<%=aStrPrevYrInfo[3]%>">
<input type="hidden" name="currency" value="Php"><!-- change this if school is having different currency.-->
<%
 //only if hands on is true;
 if(bolHandsOn)
 {
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(8);//System.out.println(strTemp);}
	else
		strTemp = request.getParameter("amt_per_unit");
	if(strTemp == null) strTemp = "";
	%>       <select name="amt_per_unit"><!-- SHOW ONLY IF HANDS ON IS SET -->

	 <%
	 if(strTemp.compareTo("0") == 0){%>
	      <option value="0" selected>per unit</option>
	 <%}else{%><option value="0">per unit</option>
	<%}if(strTemp.compareTo("1") == 0){%>
		<option value="1" selected>per type</option>
	<%}else{%><option value="1">per type</option>
	<%}%>
          <!--<option>per subject</option> NOT USED NOW -->

        </select>
<%}//show if bolHandsOn is true;%>

        </td></tr>

    <tr>
      <td height="25" width="6%">&nbsp;</td>
      <td>Remarks</td>
      <td colspan="3">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(13);
	else
		strTemp = request.getParameter("remark");
	if(strTemp == null) strTemp = "";
	%>
        <input name="remark" type="text" size="75" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>

    </tr>
          <td height="25">&nbsp;</td>
      <td>Update factor
        </td>
      <td  colspan="3">
<%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(14);
	else
		strTemp = request.getParameter("update_factor_unit");
	if(strTemp == null) strTemp = "";
	%>        <select name="update_factor_unit">
	<%if(strTemp.compareTo("0") ==0){%>
			<option value="0" selected>No change</option>
	<%}else{%>
			<option value="0">No change</option>
	<%}if(strTemp.compareTo("1") ==0){%>
          	<option value="1" selected>percentage</option>
	<%}else{%>
			<option value="1">percentage</option>
	<%}if(strTemp.compareTo("2") ==0){%>
          	<option value="2" selected>specific amount</option>
	<%}else{%>
		  	<option value="2">specific amount</option>
	<%}%>
        </select>
<%
	if(vEditInfo != null && vEditInfo.size() > 1)
	{
		//check the update factor unit -- display pecentage only of it is percentage else display amount.
		if(strTemp.compareTo("0") == 0) // No change.
			strTemp = "";
		else if(strTemp.compareTo("1") ==0) //percentage;
			strTemp = (String)vEditInfo.elementAt(15);//CommonUtil.formatFloat((String)vEditInfo.elementAt(15),false);
		else //specific amount.
			strTemp = (String)vEditInfo.elementAt(11);//CommonUtil.formatFloat((String)vEditInfo.elementAt(11),true);
	}
	else
		strTemp = request.getParameter("update_factor");
	if(strTemp == null) strTemp = "";
	%>        <input name="update_factor" type="text" size="16" onChange="CheckIfLegal();" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </td>
    </tr>

 <%if(iAccessLevel > 1){%>
   <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click
        to add fee name</font>
        <%}else{%>
        <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>
      </td>
    </tr>
<%}//if iAccessLevel > 1
if(strErrMsg != null)
{%> <tr>
  	<td height="25">&nbsp;</td>
      <td colspan="5"><b><%=strErrMsg%></b></td>
    </tr>
    <%}//this shows the edit/add/delete success info

}//bolShowDetail
%>

  </table>
<%
if(vRetResult != null && vRetResult.size()> 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5" bgcolor="#B9B292"><div align="center">UPDATED
          FEE LIST FOR YEAR - <%=request.getParameter("sy_from")%>-<%=request.getParameter("sy_to")%></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="40%" height="25" align="center"><strong><font size="1">FEE NAME</font></strong></td>
      <td width="12%" align="center"><strong><font size="1">RATE FOR PREV. YR</font></strong></td>
      <td width="10%" align="center"><strong><font size="1">PERCENTAGE INCREASE</font></strong></td>
      <td width="12%" align="center"><strong><font size="1">INCREASED AMOUNT</font></strong></td>
      <td width="10%" align="center"><strong><font size="1">NEW RATE (<%=request.getParameter("sy_from")%>-<%=request.getParameter("sy_to")%>)</font></strong></td>
      <td width="8%" align="center"><font size="1"><strong>CHARGED ONCE</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>ONLY FOR FOREIGN STUDENT</strong></font></td>
      <td width="8%" align="center"><strong><font size="1">ONLY FOR NEW </font></strong></td>
      <td width="8%" align="center"><font size="1"><strong>ONLY FOR OLD</strong></font></td>
      <td width="8%" align="center"><strong><font size="1">YEARLY FEE</font></strong></td>
      <td width="8%" align="center"><strong><font size="1">EDIT</font></strong></td>
      <td width="8%" align="center"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%
String  strPercentIncr = "0";
String  strAmountIncr = "0";
for(int i=0; i< vRetResult.size(); ++i)
{
strTemp = (String)vRetResult.elementAt(i+4);
//check if it is percent else ;-)
if(strTemp.compareTo("1") ==0)
	strPercentIncr = (String)vRetResult.elementAt(i+3);
else strPercentIncr = "-";

if(strTemp.compareTo("0") == 0)//no change.
	strAmountIncr = "0";
else
{
	float fAmount = Float.parseFloat( (String)vRetResult.elementAt(i+2)) - Float.parseFloat( (String)vRetResult.elementAt(i+5));
	strAmountIncr = CommonUtil.formatFloat(fAmount, true);//in currency format.
}


%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+5), true)%></td>
      <td align="center"><%=CommonUtil.formatFloat(strPercentIncr, false)%> %</td>
      <td align="center"><%=strAmountIncr%></td>
      <td align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), true)%></td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center"> <%
	  if(((String)vRetResult.elementAt(i+8)).compareTo("1") ==0){%> <img src="../../../images/tick.gif"> <%}else{%> &nbsp; <%}%> </td>
      <td align="center">&nbsp;</td>
      <td align="center"> <%
	  if(((String)vRetResult.elementAt(i+9)).compareTo("1") ==0){%> <img src="../../../images/tick.gif"> <%}else{%> &nbsp; <%}%> </td>
      <td align="center"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%> </td>
      <td align="center"> <%if(iAccessLevel == 2 ){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%> </td>
    </tr>
    <%
	i = i+9;
		}//end of for loop.
	}//end of showing result if there is fee created -- viewall.

//}//end of bolShowDisplay
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
<input type="hidden" name="amount">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="copy_all" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
