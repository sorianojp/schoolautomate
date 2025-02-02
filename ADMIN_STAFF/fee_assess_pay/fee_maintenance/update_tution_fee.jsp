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
	if(document.tution_fee.update_factor_unit.selectedIndex ==0)
	{
		if(document.tution_fee.update_factor.value.length > 0)
		alert("You have selected Update factor <No Change>. Please change to <Percentage> or <Specific amount> type. Otherwise, the fees will be unchanged.");
		//document.update_othsch.amount.value="";
	}
}
function PrepareToEdit(strInfoIndex)
{
	document.tution_fee.editRecord.value = 0;
	document.tution_fee.deleteRecord.value = 0;
	document.tution_fee.addRecord.value = 0;
	document.tution_fee.prepareToEdit.value = 1;
	document.tution_fee.info_index.value = strInfoIndex;
	document.tution_fee.submit();
}
function AddRecord()
{
	//calculate the amount here.
	var updateFactorUnit = document.tution_fee.update_factor_unit.selectedIndex;
	var amount = document.tution_fee.amount_prev.value;
	var updateFactor = document.tution_fee.update_factor.value;
	if(updateFactorUnit == "") updateFactorUnit = 0;
	if(amount == "" || amount=="null") amount = 0;
	if(updateFactor == "") updateFactor = 0;

	//alert(document.tution_fee.fee_name.value);
	//alert(updateFactor);
	//alert(amount);
	if(updateFactorUnit == 0) //No change.
	{
		document.tution_fee.update_factor.value = 0;
		document.tution_fee.amount.value = document.tution_fee.amount_prev.value;
	}
	if(updateFactorUnit == 1) //percent.
	{
		document.tution_fee.amount.value = Number(amount)+Number(amount)*Number(updateFactor)/100;
	}
	else if(updateFactorUnit == 2) // specific amount.
	{
		document.tution_fee.amount.value = updateFactor;
		document.tution_fee.update_factor.value = 0;
	}
	//alert(document.tution_fee.amount.value);
	//return;

	if(document.tution_fee.prepareToEdit.value == 1)
	{
		EditRecord(document.tution_fee.info_index.value);
		return;
	}
	document.tution_fee.editRecord.value = 0;
	document.tution_fee.deleteRecord.value = 0;
	document.tution_fee.addRecord.value = 1;

	document.tution_fee.submit();
}
function EditRecord(strTargetIndex)
{
	document.tution_fee.editRecord.value = 1;
	document.tution_fee.deleteRecord.value = 0;
	document.tution_fee.addRecord.value = 0;

	document.tution_fee.info_index.value = strTargetIndex;

	document.tution_fee.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.tution_fee.editRecord.value = 0;
	document.tution_fee.deleteRecord.value = 1;
	document.tution_fee.addRecord.value = 0;

	document.tution_fee.info_index.value = strTargetIndex;
	document.tution_fee.prepareToEdit.value == 0;

	document.tution_fee.submit();
}
function CancelRecord()
{
	document.tution_fee.info_index.value = "0";
	document.tution_fee.addRecord.value = "0";
	document.tution_fee.editRecord.value = "0";
	document.tution_fee.prepareToEdit.value = "0";
	document.tution_fee.deleteRecord.value = "0";

	ReloadPage();
}
function ReloadPage()
{
	document.tution_fee.reloadPage.value="1";
	document.tution_fee.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceUpdate,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

	String[] strPrevTutionFeeInfo = {"0","0"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-update tuition fee","update_tution_fee.jsp");
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
														"update_tution_fee.jsp");
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
	if(FA.addTutionFee(dbOP,request))
		strErrMsg = "Tuition Fee(Update) added successfully.";
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
			strErrMsg = "Tuition Fee(Update) edited successfully.";
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
Vector vRetResult = new Vector();//retains the fees created.
Vector vEditInfo = new Vector(); //retains information to edit.


if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = FA.viewTutionFee(dbOP,request,false);//view all is false
	if(vEditInfo == null || vEditInfo.size() == 0)
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Edit information not found. Please refresh page and edit again.";
	}
}
if(bolProceed)	//get the sy_from_prev , sy_to_prev.
	vRetResult = FA.viewTutionFee(dbOP,request,true);

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

<form name="tution_fee" action="./update_tution_fee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: UPDATE
          TUITION FEE RATE MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="3">Please specify how you want to encode fee rate
        <%
/*	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(4);
	else*/
		strTemp = request.getParameter("tution_fee_catg");
	if(strTemp == null) strTemp = "";
	%>
        <select name="tution_fee_catg" onChange="ReloadPage();">
          <%=dbOP.loadCombo("MANUAL_INDEX","CATEGORY"," from FA_TUTION_FEE_CATG", strTemp, false)%>
        </select> </td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="7">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">School year (prev)</td>
      <td width="29%">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0) )
		strTemp = (String)vEditInfo.elementAt(7);
	else
		strTemp = request.getParameter("sy_from_prev");
	if(strTemp == null) strTemp = "";
	%>
        <input name="sy_from_prev" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("tution_fee","sy_from_prev","sy_to_prev")'>
        to
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0))
		strTemp = (String)vEditInfo.elementAt(8);
	else
		strTemp = request.getParameter("sy_to_prev");
	if(strTemp == null) strTemp = "";
	%>
        <input name="sy_to_prev" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
      </td>
      <td colspan="3">Year level
        <%
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
        </select></td>
      <td width="30%">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">New School year </td>
      <td width="29%">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0) )
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("sy_from");
	if(strTemp == null) strTemp = "";
	%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("tution_fee","sy_from","sy_to")'>
        to
        <%
	if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0) )
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("sy_to");
	if(strTemp == null) strTemp = "";
	%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
      </td>
      <td colspan="3">&nbsp;</td>
      <td width="30%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course </td>
      <td colspan="5">
        <%
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
      <td colspan="5"><select name="major_index">
          <option></option>
          <%
if(strTemp != null && strTemp.compareTo("0") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select> <input name="image" type="image" src="../../../images/view.gif">
        <font size="1">enter SY and year level/course and major to view tution
        fees. </font></td>
    </tr>
  </table>
     <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="18%">Fee rate (prev)</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 1 && (request.getParameter("reloadPage") == null || request.getParameter("reloadPage").compareTo("0") == 0) )
{
	strPrevTutionFeeInfo[0] = (String)vEditInfo.elementAt(6);
	strPrevTutionFeeInfo[1] = (String)vEditInfo.elementAt(10);
}
else
	strPrevTutionFeeInfo = FA.getPrevYearFeeInfo(dbOP, request);
%>        <%=strPrevTutionFeeInfo[0]%> Php
        <input type="hidden" name="amount_prev" value="<%=strPrevTutionFeeInfo[0]%>">
		<input type="hidden" name="currency" value="Php"><!-- change this if school is having different currency.-->
        </td>
<%
if(strPrevTutionFeeInfo[0].compareTo("0") != 0) //show only if there is a previous reference.
{%>	</tr>
      <tr>    <td height="25">&nbsp;</td>
      <td>Update factor
        </td>
      <td>
<%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(4);
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
          	<!--<option value="2" selected>specific amount</option>-->
	<%}else{%>
		  	<!--<option value="2">specific amount</option>-->
	<%}%>
        </select>
<%
	if(vEditInfo != null && vEditInfo.size() > 1)
	{
		//check the update factor unit -- display pecentage only of it is percentage else display amount.
		if(strTemp.compareTo("0") == 0) // No change.
			strTemp = "";
		else if(strTemp.compareTo("1") ==0) //percentage;
			strTemp = (String)vEditInfo.elementAt(5);//CommonUtil.formatFloat((String)vEditInfo.elementAt(5),false);
		else //specific amount.
			strTemp = (String)vEditInfo.elementAt(3);//CommonUtil.formatFloat((String)vEditInfo.elementAt(3),true);
	}
	else
		strTemp = request.getParameter("update_factor");
	if(strTemp == null) strTemp = "";
	%>        <input name="update_factor" type="text" size="16" onChange="CheckIfLegal();" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/update.gif" border="0"></a><font size="1">click
        to add</font>
 <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
 <%}%></td>
    </tr>
<%
	}//if iAccessLevel > 1
}//end of showing if previous amount is > 0
if(strErrMsg != null)
{%> <tr>
  	<td height="25">&nbsp;</td>
      <td colspan="5"><b><%=strErrMsg%></b></td>
    </tr>
<%}//this shows the edit/add/delete success info
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
      <td width="22%" align="center"><font size="1">RATE FOR PREV. YR <br>
        (<%=(String)vRetResult.elementAt(5)%> - <%=(String)vRetResult.elementAt(6)%>)</font></td>
      <td width="20%" align="center"><font size="1">PERCENTAGE INCREASE</font></td>
      <td width="22%" align="center"><font size="1">INCREASED AMOUNT</font></td>
      <td width="20%" align="center"><font size="1">NEW RATE (<%=request.getParameter("sy_from")%>-<%=request.getParameter("sy_to")%>)</font></td>
      <td width="8%" align="center"><font size="1">EDIT</font></td>
      <td width="8%" align="center"><font size="1">DELETE</font></td>
    </tr>
    <%
	String  strPercentIncr = "0";
	String  strAmountIncr = "0";
	strTemp = (String)vRetResult.elementAt(2);
	//check if it is percent else ;-)
	if(strTemp.compareTo("1") ==0)
		strPercentIncr = (String)vRetResult.elementAt(3);
	else strPercentIncr = "-";

	if(strTemp.compareTo("0") == 0)//no change.
		strAmountIncr = "0";
	else
	{
		float fAmount = Float.parseFloat( (String)vRetResult.elementAt(1)) - Float.parseFloat( (String)vRetResult.elementAt(4));
		strAmountIncr = CommonUtil.formatFloat(fAmount, true);//in currency format.
	}
%>
    <tr>
      <td align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(4), true)%></td>
      <td align="center"><%=CommonUtil.formatFloat(strPercentIncr, false)%> %</td>
      <td align="center"><%=strAmountIncr%></td>
      <td align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(1), true)%></td>
      <td align="center">
	  <%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(0)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
	  <%}else{%> Not authorized<%}%>
	  </td>
      <td align="center">
	  <%if(iAccessLevel ==2){%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(0)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
	  <%}else{%> Not authorized<%}%>
	  </td>
    </tr>
  </table>
<%
}//end of if condition
%>
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
<input type="hidden" name="tution_fi_index" value="<%=strPrevTutionFeeInfo[1]%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
