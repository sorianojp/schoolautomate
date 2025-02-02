<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function CheckIfLegal()
{
	if(document.update_othsch.update_factor_unit.selectedIndex ==0)
	{
		if(document.update_othsch.update_factor.value.length > 0)
		alert("You have selected Update factor <No Change>. Please change to <Percentage> or <Specific amount> type. Otherwise, the fees will be unchanged.");
		//document.update_othsch.amount.value="";
	}
}
function PrepareToEdit(strInfoIndex)
{
	document.update_othsch.editRecord.value = 0;
	document.update_othsch.deleteRecord.value = 0;
	document.update_othsch.addRecord.value = 0;
	document.update_othsch.prepareToEdit.value = 1;
	document.update_othsch.info_index.value = strInfoIndex;
	document.update_othsch.submit();

}
function AddRecord()
{
//calculate the amount here.
	var updateFactorUnit = document.update_othsch.update_factor_unit.selectedIndex;
	var amount = document.update_othsch.amount_prev.value;
	var updateFactor = document.update_othsch.update_factor.value;
	if(updateFactorUnit == "") updateFactorUnit = 0;
	if(amount == "" || amount=="null") amount = 0;
	if(updateFactor == "") updateFactor = 0;

	document.update_othsch.fee_name.value=document.update_othsch.select_fee_name[document.update_othsch.select_fee_name.selectedIndex].text;
	//alert(document.update_othsch.fee_name.value);
	//alert(updateFactor);
	//alert(amount);
	if(updateFactorUnit == 0) //No change.
	{
		document.update_othsch.update_factor.value = 0;
		document.update_othsch.amount.value = document.update_othsch.amount_prev.value;

	}
	if(updateFactorUnit == 1) //percent.
	{
		document.update_othsch.amount.value = Number(amount)+Number(amount)*Number(updateFactor)/100;
	}
	else if(updateFactorUnit == 2) // specific amount.
	{
		document.update_othsch.amount.value = updateFactor;
		document.update_othsch.update_factor.value = 0;
	}
	//alert(document.update_othsch.amount.value);
	//return;


	if(document.update_othsch.prepareToEdit.value == 1)
	{
		EditRecord(document.update_othsch.info_index.value);
		return;
	}
	document.update_othsch.editRecord.value = 0;
	document.update_othsch.deleteRecord.value = 0;
	document.update_othsch.addRecord.value = 1;

	document.update_othsch.submit();
}
function EditRecord(strTargetIndex)
{
	document.update_othsch.editRecord.value = 1;
	document.update_othsch.deleteRecord.value = 0;
	document.update_othsch.addRecord.value = 0;

	document.update_othsch.info_index.value = strTargetIndex;

	document.update_othsch.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.update_othsch.editRecord.value = 0;
	document.update_othsch.deleteRecord.value = 1;
	document.update_othsch.addRecord.value = 0;

	document.update_othsch.info_index.value = strTargetIndex;
	document.update_othsch.prepareToEdit.value == 0;

	document.update_othsch.submit();
}
function CancelRecord()
{
	//var strSYFrom = document.update_othsch.sy_from.value;
	//var strSYTo = document.update_othsch.sy_to.value;

	//location = "./udpate_other_sch_fee.jsp?sy_from_prev="+strSYFrom+"&sy_to_prev="+strSYTo+"&year_level="+document.update_othsch.year_level[document.update_othsch.year_level.selectedIndex].value;
	document.update_othsch.prepareToEdit.value = 0;
	ReloadPage();
}
function ReloadPage()
{
	document.update_othsch.reloadPage.value = "1";
	document.update_othsch.editRecord.value = 0;
	document.update_othsch.deleteRecord.value = 0;
	document.update_othsch.addRecord.value = 0;
	document.update_othsch.submit();
}
function CopyAll()
{
	document.update_othsch.copy_all.value="1";
	document.update_othsch.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceUpdate,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
	String strAmount = null;

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
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-update other sch fee","update_other_sch_fee.jsp");
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
														"update_other_sch_fee.jsp");
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
	if(FA.addOthSchFee(dbOP,request))
		strErrMsg = "Other School Fee(Update) added successfully.";
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
		if(FA.editOthSchFee(dbOP,request))
			strErrMsg = "Other School Fee(Update) edited successfully.";
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

			if(FA.delOthSchFee(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
				strErrMsg = "Other School Fee deleted successfully.";
			else
			{
				bolProceed = false;
				strErrMsg = FA.getErrMsg();
			}
		}
	}
}
if(WI.fillTextValue("copy_all").compareTo("1") ==0)
{
	if(FA.copyAllOthSchFee(dbOP, request.getParameter("sy_from_prev"),request.getParameter("sy_to_prev"),
			request.getParameter("sy_from"),request.getParameter("sy_to"),(String)request.getSession(false).getAttribute("userId")))
		strErrMsg = "Other school fees copied successfully.";
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
	vEditInfo = FA.viewOthSchFee(dbOP,request.getParameter("info_index"));//view all is false
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
	vRetResult = FA.viewAllOthSchFee(dbOP,request.getParameter("year_level"), request.getParameter("sy_from"), request.getParameter("sy_to"));//to view all
	if(vEditInfo == null || vEditInfo.size() == 0)
		vAllowedUpdateList = FA.getPrevOthSchFee(dbOP,request.getParameter("sy_from_prev"),request.getParameter("sy_to_prev"),
							request.getParameter("year_level"));
	else
		vAllowedUpdateList = FA.getPrevOthSchFee(dbOP,(String)vEditInfo.elementAt(12),(String)vEditInfo.elementAt(13),
							request.getParameter("year_level"));
}

//amount to display when fees is selected.
strTemp = request.getParameter("select_fee_name");
if(strTemp == null || strTemp.trim().length() == 0)
	strTemp = "0";
strAmount = dbOP.mapOneToOther("FA_OTH_SCH_FEE","OTHSCH_FEE_INDEX",strTemp,"amount"," and is_del=0 and is_valid=1");
if(strAmount == null) strAmount = "0.00";
strAmount = CommonUtil.formatFloat(strAmount,true);
dbOP.cleanUP();

//do not proceed is bolProceed = false;
if(!bolProceed)
{
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="2">
	<b><%=strErrMsg%></b></font></p>
	<%
	return;
}
%>



<form name="update_othsch" action="./update_other_sch_fee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          UPDATE OTHER SCHOOL FEES MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="20%">School Year(previous)</td>
      <td  colspan="2">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(12);
	else
		strTemp = request.getParameter("sy_from_prev");
	if(strTemp == null) strTemp = "";
	%>
        <input name="sy_from_prev" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("update_othsch","sy_from_prev","sy_to_prev")'>
        to
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(13);
	else
		strTemp = request.getParameter("sy_to_prev");
	if(strTemp == null) strTemp = "";
	%>
        <input name="sy_to_prev" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> </td>


      <td>Year Level:
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = request.getParameter("year_level");
	if(strTemp == null) strTemp = "";
	%>       <select name="year_level">
          <%if(strTemp.compareTo("0") ==0){%> <option value="0" selected>All</option>
		  <%}else{%> <option value="0">All</option>
		  <%}if(strTemp.compareTo("1") ==0){%><option value="1" selected>1st</option>
		  <%}else{%><option value="1">1st</option>
		  <%}if(strTemp.compareTo("2") ==0){%> <option value="2" selected>2nd</option>
		  <%}else{%> <option value="2">2nd</option>
		  <%}if(strTemp.compareTo("3") ==0){%><option value="3" selected>3rd</option>
		  <%}else{%><option value="3">3rd</option>
		  <%}if(strTemp.compareTo("4") ==0){%> <option value="4" selected>4th</option>
		  <%}else{%> <option value="4">4th</option>
		  <%}if(strTemp.compareTo("5") ==0){%><option value="5" selected>5th</option>
		  <%}else{%><option value="5">5th</option>
		  <%}if(strTemp.compareTo("6") ==0){%> <option value="6" selected>6th</option>
		  <%}else{%> <option value="6">6th</option>
		  <%}if(strTemp.compareTo("7") ==0){%><option value="7" selected>7th</option>
		  <%}else{%><option value="7">7th</option><%}%>


        </select>
      </td>
    </tr>

	    <tr>
      <td height="25">&nbsp;</td>
      <td>New Updated SY</td>
      <td  colspan="3">
<%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("sy_from");
	if(strTemp == null) strTemp = "";
	%>	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("update_othsch","sy_from","sy_to")'>
        to
<%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("sy_to");
	if(strTemp == null) strTemp = "";
	%>        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        <input type="image" src="../../../images/view.gif" onClick="ReloadPage();">
        <font size="1"><em>View fees detail for this year </em> <strong>(OR)</strong>
        <a href='javascript:CopyAll();'><img src="../../../images/copy_all.gif" border="0"></a>copy
        all fee from prev. school year.</font> </td>
    </tr>
<%
//show only if view is clicked so i can show year level
if(bolShowDetail)
{%><tr>
      <td height="25">&nbsp;</td>
      <td>Fee Name </td>
      <td  colspan="3">
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(10);
	else
		strTemp = request.getParameter("select_fee_name");
	if(strTemp == null) strTemp = "";
	%>
	 <select name="select_fee_name" onChange="ReloadPage();">
	 <option value="0">Select a fee</option>
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
<input type="text" name="fee_name" value="<%=(String)vEditInfo.elementAt(1)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
<%}%>
<input type="hidden" name="fee_name" value="<%=request.getParameter("fee_name")%>">
        <font size="1"><em>(fees available for year <%=request.getParameter("sy_from_prev")%>-<%=request.getParameter("sy_to_prev")%>
        to add to new school year)</em></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Rate (prev)</td>
      <td  colspan="2">
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strAmount = CommonUtil.formatFloat((String)vEditInfo.elementAt(11), true);
	%>
	        <%=strAmount%> Php
<input type="hidden" name="amount_prev" value="<%=strAmount%>">
<input type="hidden" name="currency" value="Php"><!-- change this if school is having different currency.-->


        </td>
      <td width="51%">&nbsp;</td>
    </tr>
<%
//if(strAmount.length() > 1)
//{%>    <tr>
      <td height="25">&nbsp;</td>
      <td>Remarks</td>
      <td  colspan="3">
<%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(7);
	else
		strTemp = request.getParameter("remark");
	if(strTemp == null) strTemp = "";
	%>	 <input name="remark" type="text" size="75" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> </td>
    </tr><tr>
      <td height="25">&nbsp;</td>
      <td>Update Factor </td>
      <td  colspan="3">
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(8);
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
			strTemp = (String)vEditInfo.elementAt(9);//CommonUtil.formatFloat((String)vEditInfo.elementAt(9),false);
		else //specific amount.
			strTemp = (String)vEditInfo.elementAt(5);//CommonUtil.formatFloat((String)vEditInfo.elementAt(5),true);
	}
	else
		strTemp = request.getParameter("update_factor");
	if(strTemp == null) strTemp = "";
	%>        <input name="update_factor" type="text" size="16" onChange="CheckIfLegal();" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
    </tr>
<%
if(iAccessLevel > 1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td colspan="3">&nbsp;
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click
        to add fee name</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>
      </td>

      </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
        <%
if(strErrMsg != null)
{%> <tr>
  	<td height="25" width="7%">&nbsp;</td>
      <td colspan="2"><b><%=strErrMsg%></b></td>
    </tr>
    <%}//this shows the edit/add/delete success info
}//show only if strAmount length > 1 means -- a fee name is selected.	%>

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
      <td width="40%" height="25" align="center"><font size="1">FEE NAME</font></td>
      <td width="12%" align="center"><font size="1">RATE FOR PREV. YR</font></td>
      <td width="10%" align="center"><font size="1">PERCENTAGE INCREASE</font></td>
      <td width="12%" align="center"><font size="1">INCREASED AMOUNT</font></td>
      <td width="10%" align="center"><font size="1">NEW RATE (<%=request.getParameter("sy_from")%>-<%=request.getParameter("sy_to")%>)</font></td>
      <td width="8%" align="center"><font size="1">EDIT</font></td>
      <td width="8%" align="center"><font size="1">DELETE</font></td>
    </tr>
    <%
String  strPercentIncr = "0";
String  strAmountIncr = "0";
for(int i=0; i< vRetResult.size(); ++i)
{
strTemp = (String)vRetResult.elementAt(i+5);
//check if it is percent else ;-)
if(strTemp.compareTo("1") ==0)
	strPercentIncr = (String)vRetResult.elementAt(i+4);
else strPercentIncr = "-";

if(strTemp.compareTo("0") == 0)//no change.
	strAmountIncr = "0";
else
{
	float fAmount = Float.parseFloat( (String)vRetResult.elementAt(i+2)) - Float.parseFloat( (String)vRetResult.elementAt(i+6));
	strAmountIncr = CommonUtil.formatFloat(fAmount, true);//in currency format.
}


%>
    <tr>
      <td height="25" align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6), true)%></td>
      <td align="center"><%=CommonUtil.formatFloat(strPercentIncr, false)%></td>
      <td align="center"><%=strAmountIncr%></td>
      <td align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), true)%></td>
      <td align="center">
        <%if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
        <%}else{%>
        Not authorized
        <%}%>
      </td>
      <td align="center">
        <%if(iAccessLevel > 1){%>
        <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}else{%>
        Not authorized
        <%}%>
      </td>
    </tr>
    <%
	i = i+8;
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
<input type="hidden" name="amount" value="0">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="copy_all" value="0">

</form>
</body>
</html>
