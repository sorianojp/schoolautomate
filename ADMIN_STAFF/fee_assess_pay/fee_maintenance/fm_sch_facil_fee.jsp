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
	document.schfac_fee.prepareToEdit.value = 1;
	document.schfac_fee.reloadPage.value = "0";
	document.schfac_fee.info_index.value = strInfoIndex;
	document.schfac_fee.submit();

}
function AddRecord()
{
	if(document.schfac_fee.prepareToEdit.value == 1)
	{
		EditRecord(document.schfac_fee.info_index.value);
		return;
	}
	document.schfac_fee.page_action.value = "1";
	document.schfac_fee.submit();
}
function EditRecord(strTargetIndex)
{
	document.schfac_fee.page_action.value = "2";
	document.schfac_fee.info_index.value = strTargetIndex;
	document.schfac_fee.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.schfac_fee.page_action.value = "0";
	document.schfac_fee.info_index.value = strTargetIndex;
	document.schfac_fee.submit();
}
function CancelRecord()
{
	document.schfac_fee.page_action.value= "";
	document.schfac_fee.info_index.value = "";
	document.schfac_fee.prepareToEdit.value = "0";
	document.schfac_fee.submit();
}
function ReloadPage()
{
	document.schfac_fee.reloadPage.value="1";
	document.schfac_fee.submit();
}
function CallMultipleCharges()//Take me to multiple charge page.
{
	if(document.schfac_fee.fee_name.value == "")
	{
		alert("Please enter fee name.");
		return ;
	}
	if(document.schfac_fee.sy_from.value == "" || document.schfac_fee.sy_to.value=="")
	{
		alert("Please enter school year from/to.");
		return;
	}
	location = "./fm_schl_fees_multiple_entry.jsp?fee_name="+escape(document.schfac_fee.fee_name.value)+"&account_type="+
		document.schfac_fee.account_type[document.schfac_fee.account_type.selectedIndex].value+"&sy_from="+
		document.schfac_fee.sy_from.value+"&sy_to="+document.schfac_fee.sy_to.value;
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FASchoolFacility,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
	boolean bolIsReloadCalled = false;
	if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
		bolIsReloadCalled = true;
	String strFeeType = null;//single charge or multiple charge. - for multiple charge proceed.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-Sch facility fee","fm_sch_facil_fee.jsp");
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
														"fm_sch_facil_fee.jsp");
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

FASchoolFacility schFacility = new FASchoolFacility();
boolean bolProceed = true;

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("1") == 0)
{
	strPrepareToEdit="0";
	//add it here and give a message.
	if(schFacility.opOnSchFacTypeSingleFee(dbOP,request,1) != null)
		strErrMsg = "School facility fee added successfully.";
	else
	{
		bolProceed = false;
		strErrMsg = schFacility.getErrMsg();
	}
}
else if(strTemp.compareTo("2") ==0)
{
	if(schFacility.opOnSchFacTypeSingleFee(dbOP,request,2) != null)
	{
		strPrepareToEdit = "0"; //only if there is an error.
		strErrMsg = "School facility fee edited successfully.";
	}
	else
	{
		bolProceed = false;
		strErrMsg = schFacility.getErrMsg();
	}
}
else if(strTemp.compareTo("0") ==0)
{
	strPrepareToEdit="0";
	if(schFacility.opOnSchFacTypeSingleFee(dbOP,request,0) != null)
		strErrMsg = "School facility fee deleted successfully.";
	else
	{
		bolProceed = false;
		strErrMsg = schFacility.getErrMsg();
	}
}

//get all levels created.
Vector vRetResult = new Vector();
Vector vEditInfo = new Vector();

if(bolProceed)
	vRetResult = schFacility.opOnSchFacTypeSingleFee(dbOP,request,3);//to view all

if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo =  schFacility.opOnSchFacTypeSingleFee(dbOP,request,4);//to view one
	if(vEditInfo == null || vEditInfo.size() == 0)
	{
		bolProceed = false;
		strErrMsg = schFacility.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Edit information not found. Please try again.";
	}
}

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
if(strErrMsg == null) strErrMsg = "";
%>


<form name="schfac_fee" action="./fm_sch_facil_fee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="30" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHOOL FACILITIES FEES MAINTENANCE PAGE ::::<br>
          <font size="1">UPDATE LIST OF SCHOOL FACILITIES FEES</font> </strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4"> &nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="24%">Fee name </td>
      <td width="71%"  colspan="2">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && !bolIsReloadCalled)
		strTemp = (String)vEditInfo.elementAt(0);
	else
		strTemp = WI.fillTextValue("fee_name");
	%>
        <input name="fee_name" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Fee type</td>
      <td  colspan="2"><select name="facility_type" onChange="ReloadPage();">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && !bolIsReloadCalled)
		strFeeType = (String)vEditInfo.elementAt(2);
	else
		strFeeType = WI.fillTextValue("facility_type");
if(strFeeType.length() ==0)
	strFeeType = "0";
	%>

          <option value="0">Single fee charges </option>
<%
if(strFeeType.compareTo("1") ==0){%>
          <option value="1" selected>Multiple fee charges</option>
<%}else{%>
          <option value="1">Multiple fee charges</option>
<%}%>
        </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Accounts</td>
      <td  colspan="2"><select name="account_type">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && !bolIsReloadCalled)
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = WI.fillTextValue("account_type");
	%>
          <option value="0">Internal</option>
<%
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>External</option>
<%}else{%> <option value="1">External</option>
<%}if(strTemp.compareTo("2") ==0){%>
		<option value="2" selected>Both</option>
<%}else{%>
		<option value="2">Both</option>
<%}%>
        </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>School Year</td>
      <td  colspan="2">
        <%
strTemp = WI.fillTextValue("offering_yr_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("schfac_fee","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("offering_yr_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        <a href="javascript:ReloadPage();"><img src="../../../images/view.gif" border="0"></a>
		<font size="1"> Click to view all the school facility fee created (please enter school year)</font>
      </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td  colspan="2">
	  <%
	  //display if strFeeType is multiple fee type.
	  if(strFeeType.compareTo("1") ==0){%>
	  <a href="javascript:CallMultipleCharges();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  <%}%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" height="24"><hr size="1"></td>
    </tr>
 <%
 if(strFeeType.compareTo("0") ==0){//display only if single fee type.
 %>
    <tr>
      <td  width="5%"height="24">&nbsp;</td>
      <td width="14%">Fee rate </td>
      <td width="32%">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && !bolIsReloadCalled)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = WI.fillTextValue("amount");
	%>
        <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
      </td>

	  <td width="49%">Unit
        <select name="usage_unit">
          <option>per hour</option>
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && !bolIsReloadCalled)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = WI.fillTextValue("usage_unit");
	if(strTemp.compareTo("per day") ==0){%>
          <option selected>per day</option>
<%}else{%><option>per day</option>
<%}if(strTemp.compareTo("per week") ==0){%>
          <option selected>per week</option>
<%}else{%> <option>per week</option>
<%}if(strTemp.compareTo("per month") ==0){%>
          <option selected>per month</option>
<%}else{%><option>per month</option>
<%}if(strTemp.compareTo("per request") == 0){%>
          <option selected>per request</option>
<%}else{%> <option>per request</option>
<%}if(strTemp.compareTo("per card") ==0){%>
          <option selected>per card</option>
<%}else{%>          <option>per card</option>
 <%}%>       </select></td>
    </tr>

<%}//only if strFeeType is "0"
%>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr>
      <td  width="5%"height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td colspan="2">&nbsp;
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a><font size="1">click
        to save entry</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>
      </td>
    </tr>
<%}//if iAccessLevel > 1%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
String[] astrConvertFeeType = {"Single fee charges","Multiple fee charges"};
if(vRetResult != null && vRetResult.size() > 0)
{%>
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5" bgcolor="#B9B292"><div align="center">LIST
          OF SCHOOL FACILITIES FEES WITH SINGLE CHARGE ENTRY - FOR SCHOOL YEAR
          <%=request.getParameter("sy_from")%>-<%=request.getParameter("sy_to")%></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="20%" height="25"><div align="center"><font size="1"><strong>FEE
          NAME</strong></font></div></td>
      <td width="24%"><div align="center"><font size="1"><strong>FEE TYPE</strong></font></div></td>
      <td width="13%"><div align="center"><font size="1"><strong>FEE RATE </strong></font></div></td>
      <td width="6%"><div align="center"><strong><font size="1">UNIT</font></strong></div></td>
      <td width="5%" align="center"><strong><font size="1">EDIT</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>
    <tr>
      <td height="25" align="center"><%=(String)vRetResult.elementAt(i)%></td>
      <td align="center"><%=astrConvertFeeType[Integer.parseInt((String)vRetResult.elementAt(i+2))]%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+1))%>&nbsp;</td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+3))%>&nbsp;</td>
      <td align="center">
	  <%if(iAccessLevel > 1){%>
 		<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i+5)%>");'><img src="../../../images/edit.gif" border="0"></a>
	<%}else{%>Not authorized<%}%>
		</td>
      <%if(iAccessLevel == 2){%>
		<td align="center"> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i+5)%>");'><img src="../../../images/delete.gif" border="0"></a>
      <%}else{%>Not authorized<%}%>
		</td>
    </tr>
    <% i = i+5;
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
strTemp = WI.fillTextValue("info_index");
if(strTemp.length() ==0) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="reloadPage" value="<%=WI.fillTextValue("reloadPage")%>">

</form>
</body>
</html>
