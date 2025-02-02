<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">
function AddMoreDiscounts(strFaFaIndex) {
	var pgLoc = "./fee_adj_add_more.jsp?fa_fa_index="+strFaFaIndex;
	var win=window.open(pgLoc,"NEW_WIN",'width=900,height=600,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateStipend(strFaFaIndex)
{
//popup window here.
	var pgLoc = "./fee_adjustment_allowance_pop.jsp?fa_fa_index="+strFaFaIndex;
	var win=window.open(pgLoc,"AllowanceWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.fa_type.submit();
}
function UpdateSubType()
{
	document.fa_type.updateSubType.value = "1";
	document.fa_type.prepareToEdit.value = "0";

	ReloadPage();
}
function PrepareToEdit(strInfoIndex)
{
	document.fa_type.updateSubType.value = "0";
	document.fa_type.editRecord.value = 0;
	document.fa_type.deleteRecord.value = 0;
	document.fa_type.addRecord.value = 0;
	document.fa_type.prepareToEdit.value = 1;
	document.fa_type.info_index.value = strInfoIndex;
	document.fa_type.submit();

}
function AddRecord()
{
	if(document.fa_type.prepareToEdit.value == 1)
	{
		EditRecord(document.fa_type.info_index.value);
		return;
	}
	document.fa_type.editRecord.value = 0;
	document.fa_type.deleteRecord.value = 0;
	document.fa_type.addRecord.value = 1;

	document.fa_type.hide_save.src = "../../../images/blank.gif";
	
	document.fa_type.submit();
}
function EditRecord(strTargetIndex)
{
	document.fa_type.editRecord.value = 1;
	document.fa_type.deleteRecord.value = 0;
	document.fa_type.addRecord.value = 0;

	document.fa_type.info_index.value = strTargetIndex;

	document.fa_type.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.fa_type.editRecord.value = 0;
	document.fa_type.deleteRecord.value = 1;
	document.fa_type.addRecord.value = 0;

	document.fa_type.info_index.value = strTargetIndex;
	document.fa_type.prepareToEdit.value == 0;

	document.fa_type.submit();
}
function CancelRecord()
{
	document.fa_type.editRecord.value = 0;
	document.fa_type.deleteRecord.value = 0;
	document.fa_type.addRecord.value = 0;
	document.fa_type.prepareToEdit.value =0;
	document.fa_type.info_index.value = "0";
	document.fa_type.type_name0.value="";
	if(document.fa_type.is_subtype && document.fa_type.is_subtype.selectedIndex == 0)
	{
		document.fa_type.discount.value = "";
		document.fa_type.discount_on.value = "";
		document.fa_type.description.value = "";
	}
	document.fa_type.submit();
}
function ShowHideMultipleDisc() {
	if(document.fa_type.is_subtype.selectedIndex == 1)
		return;
	if(document.fa_type.discount_on.selectedIndex == 7) {
		this.showLayer('row_1');
		this.showLayer('row_2');
		this.showLayer('row_3');
	}
	else {
		this.hideLayer('row_1');
		this.hideLayer('row_2');
		this.hideLayer('row_3');
		document.fa_type.dis_misc.value = "";
		document.fa_type.dis_oth.value  = "";
	}
	
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
if( WI.fillTextValue("updateSubType").compareTo("1") ==0){%>
	<jsp:forward page="./fee_adjustment_type_subtype.jsp" />
<%}

	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Fee adjustment type","fee_adjustment_type.jsp");
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
														"Fee Assessment & Payments","PAYMENT MAINTENANCE",request.getRemoteAddr(),
														"fee_adjustment_type.jsp");
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

Vector vViewAdjustment = null;Vector vTemp = null;//this stores information if there is any additional discounts added.
//additional discount can be view by calling FA.operateOnMultipleFeeAdjustment(dbOP, req, 4, strFAFAIndex);
Vector vEditInfo = null;//if edit is clicked.
boolean bolEditCalled = false;
boolean bolProceed = true;

FAPmtMaintenance FA = new FAPmtMaintenance();
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	strPrepareToEdit="0";

	//add it here and give a message.
	if(FA.addFeeAdjustment(dbOP,request,0)) 
		strErrMsg = "Fee adjustment type added successfully.";
	else
	{
		//bolProceed = false;
		strErrMsg = FA.getErrMsg();
	}
}
else //either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(FA.editFeeAdjustment(dbOP,request,0))
			strErrMsg = "Fee adjustment Type edited successfully.";
		else
		{
			strErrMsg = FA.getErrMsg();
			//bolProceed = false;
		}

		strPrepareToEdit="0";
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			strPrepareToEdit="0";

			if(FA.deleteFeeAdjustment(dbOP,request,0))
				strErrMsg = "Fee adjustment Type deleted successfully.";
			else
			{
				//bolProceed = false;
				strErrMsg = FA.getErrMsg();
			}
		}
	}
}


if(bolProceed && WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0)
{
	vViewAdjustment = FA.viewFeeAdjustment(dbOP, 0,request.getParameter("sy_from"),request.getParameter("sy_to"),
																				request.getParameter("semester"),null);//level is zero.
	if(vViewAdjustment ==null)
		strErrMsg = FA.getErrMsg();
}

if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = FA.viewOneFeeAdjustment(dbOP,0,request.getParameter("info_index"));
	if(vEditInfo == null || vEditInfo.size() == 0)
	{
		strErrMsg = FA.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Edit information not found. Please refresh page and edit again.";
	}
	else
		bolEditCalled = true;
}
if(strErrMsg == null) strErrMsg = "";

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<form name="fa_type" action="./fee_adjustment_type.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          FEE ADJUSTMENT TYPE PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="1%">&nbsp;</td>
      <td colspan="3"><strong><font size="3" color="#FF0000"><%=strErrMsg%></font></strong></td>
    </tr>
    <!--    <tr>
      <td height="25">&nbsp;</td>
      <td>School year and Semester</td>
      <td><input type="text" name="sy_from" maxlength="4" size="4">
        -
        <input type="text" name="sy_to" maxlength="4" size="4">
		&nbsp;&nbsp;&nbsp;<select name="semster">
		</select></td>
      <td><a href="javascript:CancelRecord();"><img src="../../../images/copy_all.gif" border="0"></a>
        copy all </td>
    </tr>-->
    <tr>
      <td height="25">&nbsp;</td>
      <td width="28%">School Yr From - to - Semester</td>
      <td width="34%">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fa_type","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester" onChange="ReloadPage();">
          <option value="">All Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("sy_from").length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.equals("0")){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st Sem</option>
<%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}
if (!strSchCode.startsWith("CPU")) {
	if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}
}%>
        </select></td>
      <td width="37%"><input type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="28%">Adjustment type name</td>
      <td width="34%"> <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("type_name0");
%> <input name="type_name0" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <input type="hidden" name="old_type" value="<%=strTemp%>"> 
        <!--for edit-->      </td>
      <td width="37%">With sub-type? 
        <select name="is_subtype" onChange="ReloadPage();">
          <option value="0">No</option>
          <%
if(bolEditCalled)
	if(vEditInfo.elementAt(0) == null)	strTemp = "1"; //with sub type.
	else strTemp = "0";
else
	strTemp = WI.fillTextValue("is_subtype");
if(strTemp.length() == 0)
	strTemp = "0";

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1" >Yes</option>
          <%}%>
        </select></td>
    </tr>
    <%
if(strTemp.compareTo("0") ==0)
{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Exemptions/discount type </td>
      <td colspan="2"><select name="discount_on" style="font-size:11px" onChange="ShowHideMultipleDisc()">
          <option value="0">Tuition Fee Only</option>
          <%
if(bolEditCalled) {
	strTemp = (String)vEditInfo.elementAt(2);
	if(vEditInfo.elementAt(11) != null || vEditInfo.elementAt(13) != null)
		strTemp = "8";
}
else
	strTemp = WI.fillTextValue("discount_on");

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Miscellaneous Fees Only </option>
          <%}else{%>
          <option value="1">Miscellaneous Fees Only </option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Free All</option>
          <%}else{%>
          <option value="2">Free All</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>TUITION + MISC FEE</option>
          <%}else{%>
          <option value="4">TUITION + MISC FEE</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>MISC FEE + OTH CHARGES</option>
          <%}else{%>
          <option value="5">MISC FEE + OTH CHARGES</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>OTH CHARGES</option>
          <%}else{%>
          <option value="6">OTH CHARGES</option>
          <%}if(strTemp.compareTo("7") ==0){%>
          <option value="7" selected>TUITION+MISC+OTH CHARGES</option>
          <%}else{%>
          <option value="7">TUITION+MISC+OTH CHARGES</option>
          <%}if(strTemp.compareTo("8") ==0){%>
          <option value="8" selected>Show Multiple(ex. 100% tuition, 50% misc, 
          25% other)</option>
          <%}else{%>
          <option value="8">Show Multiple(ex. 100% tuition, 50% misc, 25% other)</option>
          <%}%>
        </select> <%
if(strPrepareToEdit.compareTo("1") == 0){%> <a href='javascript:AddMoreDiscounts("<%=request.getParameter("info_index")%>");'><img src="../../../images/update.gif" border="0"></a> 
        <font size="1">&lt;Add Other Charges Fees&gt;</font> <%}%> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Exemptions/discount 
        <label id="row_3">(Tuition)</label></td>
      <td colspan="2"> <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(0);
else
	strTemp = WI.fillTextValue("discount");
%> <input name="discount" type="text" size="8" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="discount_unit">
          <option value="0">amount</option>
          <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("discount_unit");
if(strTemp == null)
	strTemp = "";

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>%</option>
          <%}else{%>
          <option value="1">%</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>unit</option>
          <%}else{%>
          <option value="2">unit</option>
          <%}%>
        </select> 
        <!--&lt;show this and the next row if no sub-type&gt;-->
        <strong><font color="#0000FF"> 
        <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("non_sch_adjustment");
if(strTemp.compareTo("1") == 0)
	strTemp = "checked";
else
	strTemp = "";
%>
        <input type="checkbox" name="non_sch_adjustment" value="1" <%=strTemp%>>
	<% if (strSchCode.startsWith("CPU")){%>
	 Non CPU Funded Adjustment 
	 <%}else{%>
        Non School Fee Adjustment
	 <%}%></font></strong> </td>
    </tr>
    <tr id="row_1"> 
      <td height="25">&nbsp;</td>
      <td>Discount (Misc charges)</td>
      <td colspan="2"> <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(11);
else
	strTemp = WI.fillTextValue("dis_misc");
%> <input name="dis_misc" type="text" size="8" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="dis_misc_unit">
          <option value="0">amount</option>
          <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(12);
else
	strTemp = WI.fillTextValue("dis_misc_unit");
if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>%</option>
          <%}else{%>
          <option value="1">%</option>
          <%}%>
        </select></td>
    </tr>
    <tr id="row_2"> 
      <td height="25">&nbsp;</td>
      <td>Discount (Other charges)</td>
      <td colspan="2"> <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(13);
else
	strTemp = WI.fillTextValue("dis_oth");
%> <input name="dis_oth" type="text" size="8" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="dis_oth_unit">
          <option value="0">amount</option>
          <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(14);
else
	strTemp = WI.fillTextValue("dis_oth_unit");
if(strTemp == null)
	strTemp = "";

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>%</option>
          <%}else{%>
          <option value="1">%</option>
          <%}%>
        </select></td>
    </tr>
	
<% 


if (!strSchCode.startsWith("CPU")){ %>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Applicable on Max Unit </td>
      <td colspan="2">
<%
//System.out.println(vEditInfo);
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(16); 
else
	strTemp = WI.fillTextValue("max_unit");
%>
	  <input name="max_unit" type="text" size="4" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
      <font size="1">(Example: 18 units for working scholar)</font> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Scholarship Type</td>
      <td colspan="2">
<%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(15);
else
	strTemp = WI.fillTextValue("discount_type");
%>
	  <select name="discount_type">
<%=dbOP.loadCombo("DISC_TYPE","DISC_NAME"," from FA_FEE_ADJUSTMENT_DIS_TYPE order by disc_type",strTemp, false)%>		
        </select>		</td>
    </tr>
<%}// academic / athletic not applicable for CPU
	else{ %> 
    <tr>
      <td height="25">&nbsp;</td>
      <td>Scholarship Type</td>
      <td colspan="2">
<%if(bolEditCalled)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(15));
  else
	strTemp = WI.fillTextValue("visibility_stat");
	
	if (strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
%>

	  <input type="checkbox" name="visibility_stat" value="1" <%=strTemp%>> <strong>Release through cash disbursement

      </strong>		</td>
    </tr>
<%}%>	
	
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">Description</td>
      <td colspan="2"> 
<%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("description");
%> <textarea name="description" cols="45" rows="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
if(iAccessLevel > 1){%>
    <tr>
      <td  width="1%"height="25">&nbsp;</td>
      <td colspan="3">
        <%

	  if(!bolEditCalled)
	  {%>
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
		<font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to add</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>
      </td>
    </tr>
    <%
	}//if iAccessLevel > 1
}//only if there is a subtype
else{
if(iAccessLevel > 1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="88%" colspan="2">
        <a href="javascript:UpdateSubType();"><img src="../../../images/update.gif" border="0"></a>
        <font size="1">click to create or update sub-types for this type</font>&nbsp;
		<%
	  if(bolEditCalled)
	  {%>
        <br><a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>

      </td>
    </tr>
    <%}//if iAccessLevel > 1
}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5" bgcolor="#B9B292"><div align="center">LIST
          OF MAIN FEE ADJUSTMENT TYPE</div></td>
    </tr>
  </table>
<%
if(vViewAdjustment != null && vViewAdjustment.size() > 0)
{%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="15%" height="25"><div align="center"><strong><font size="1">NAME</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">DISCOUNT</font></strong></div></td>
      <td width="10%" align="center"><strong><font size="1">DISCOUNT TYPE </font></strong></td>
      <td width="15%"><div align="center"><strong><font size="1">DESCRIPTION</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">ADDITIONAL DISCOUNT</font></strong></div></td>
      <td width="5%"><strong><font size="1">NON SCH FEE</font></strong></td>
      <td width="4%"><strong><font size="1"> ALL SEM?</font></strong></td>
      <td width="4%"><strong><font size="1">Max Units</font></strong></td>
      <td width="7%"><div align="center"><strong><font size="1">STIPEND</font></strong></div></td>
      <td width="5%" align="center"><strong><font size="1">EDIT</font></strong></td>
      <td width="5%"><strong><font size="1">DELETE</font></strong></td>
    </tr>
<%
String[] astrConvertDiscountType = {"","","","","","","","","","","","","","",""};//can accomodate 15.. 
strTemp = "select DISC_TYPE, DISC_NAME from FA_FEE_ADJUSTMENT_DIS_TYPE where disc_type > 0 order by DISC_TYPE";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
while(rs.next())
	astrConvertDiscountType[rs.getInt(1)] = rs.getString(2);	
rs.close();

//String[] astrConvertDiscountType={"","Academic","Athletic"};
for(int i=0; i< vViewAdjustment.size(); ++i){
vTemp = FA.operateOnMultipleFeeAdjustment(dbOP, request, 4, (String)vViewAdjustment.elementAt(i));
if(vTemp != null)
	strTemp = (String)vTemp.elementAt(0);
else	
	strTemp = "&nbsp;";
%>
    <tr > 
      <td height="25" align="center"><%=(String)vViewAdjustment.elementAt(i+5)%>
	  <font size="1"><b><%=WI.getStrValue(astrConvertDiscountType[Integer.parseInt((String)vViewAdjustment.elementAt(i + 8))], "<br>","","")%></b></font></td>
      <td align="center"><%=(String)vViewAdjustment.elementAt(i+1)%> </td>
      <td align="center"><%=(String)vViewAdjustment.elementAt(i+2)%> </td>
      <td align="center">&nbsp;<%=WI.getStrValue(vViewAdjustment.elementAt(i+4))%></td>
      <td valign="top"><%=strTemp%></td>
      <td align="center">&nbsp; 
	  <%  if( (WI.getStrValue((String)vViewAdjustment.elementAt(i+6))).equals("1")){%> 
	  				<img src="../../../images/tick.gif"> <%}%>	  </td>
      <td align="center">&nbsp;
        <%if(vViewAdjustment.elementAt(i + 7) == null){%> <img src="../../../images/tick.gif">
        <%}%></td>
      <td align="center">&nbsp;<%=WI.getStrValue(vViewAdjustment.elementAt(i+10))%></td>
      <td align="center"> <%
	  if(vViewAdjustment.elementAt(i+1) != null && ((String)vViewAdjustment.elementAt(i+1)).compareTo("-") !=0){%> <a href='javascript:UpdateStipend("<%=(String)vViewAdjustment.elementAt(i)%>");'> 
        <img src="../../../images/update.gif" border="0"></a> <%}else{%> &nbsp; <%}%></td>
      <td align="center"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vViewAdjustment.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%></td>
      <td align="center"> <%if(iAccessLevel ==2){%> <a href='javascript:DeleteRecord("<%=(String)vViewAdjustment.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%></td>
    </tr>
    <% i = i+10;
}%>
    <tr > 
  </table>
<%}
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="updateSubType" value="0">
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="deleteRecord" value="0">

<script language="JavaScript">
this.ShowHideMultipleDisc();
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>