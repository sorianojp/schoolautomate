<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ShowHideAllowance(strAlloIndex)
{
	if( eval('document.fa_type.allowance'+strAlloIndex+'.selectedIndex ==0') )
		eval('document.fa_type.oth_allo_'+strAlloIndex+'.disabled = false');
	else
		eval('document.fa_type.oth_allo_'+strAlloIndex+'.disabled = true');
}

function ReloadPage()
{
	document.fa_type.submit();
}
function UpdateSubType()
{
	document.fa_type.updateSubType.value = "1";
	ReloadPage();
}
function PrepareToEdit(strInfoIndex)
{
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
	if(document.fa_type.is_subtype.selectedIndex == 0)
	{
		document.fa_type.discount.value = "";
		document.fa_type.discount_on.value = "";
		document.fa_type.description.value = "";
	}


	document.fa_type.submit();
}



</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
if( request.getParameter("updateSubType") != null && request.getParameter("updateSubType").compareTo("1") ==0)
{%>
	<jsp:forward page="./fee_adjustment_type_subtype.jsp" />
<%}

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
Vector vViewAdjustment = null;
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
		if(FA.editFeeAdjustment(dbOP,request,0))
			strErrMsg = "Fee adjustment Type edited successfully.";
		else
		{
			strErrMsg = FA.getErrMsg();
			bolProceed = false;
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
				bolProceed = false;
				strErrMsg = FA.getErrMsg();
			}
		}
	}
}


if(bolProceed)
{
	vViewAdjustment = FA.viewFeeAdjustment(dbOP, 0);//level is zero.
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
dbOP.cleanUP();
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
      <td colspan="3"><strong><%=strErrMsg%></strong></td>
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
      <td width="34%"><input type="text" name="sy_from" maxlength="4" size="4" value="<%=WI.fillTextValue("sy_from")%>"> -
	  <input type="text" name="sy_to" maxlength="4" size="4" value="<%=WI.fillTextValue("sy_to")%>">
        -
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
      <td width="37%"><input type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
</table>
<%
//only if syFrom and sy_to is entered.
if(WI.fillTextValue("sy_from").trim().length() > 0 && WI.fillTextValue("sy_to").trim().length()> 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td>Adjustment type name</td>
      <td width="34%">
        <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("type_name0");
%>
        <input name="type_name0" type="text" size="32" value="<%=strTemp%>"> <input type="hidden" name="old_type" value="<%=strTemp%>">
        <!--for edit-->
      </td>
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
      <td height="25">&nbsp;</td>
      <td width="28%">Exemptions/discounts </td>
      <td  colspan="2">
        <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(0);
else
	strTemp = WI.fillTextValue("discount");
%>
        <input name="discount" type="text" size="16" value="<%=strTemp%>"> <select name="discount_unit">
          <option value="0">amount</option>
          <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("discount_unit");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>%</option>
          <%}else{%>
          <option value="1">%</option>
          <%}%>
        </select>
        <!--&lt;show this and the next row if no sub-type&gt;-->
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Exemptions/discounts type </td>
      <td colspan="2"><select name="discount_on">
          <option value="0">Tuition Fees</option>
          <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("discount_on");

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Miscellaneous Fees</option>
          <%}else{%>
          <option value="1">Miscellaneous Fees</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Free All</option>
          <%}else{%>
          <option value="2">Free All</option>
          <%}//if(strTemp.compareTo("3") ==0){%>
          <!--<option value="3" selected>Other School Fees</option>
          <%//}else{%>
          <option value="3">Other School Fees</option>-->
          <%}%>
        </select>
        <!-- <select name="oth_fee_name">   </select> -->
        <!--&lt;display this last drop down if it is Other School Fees and display the type of other school fees&gt;-->
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Description</td>
      <td colspan="2">
        <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = "";
%>
        <textarea name="description" cols="45" rows="2"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Stipend
        <select name="is_stipend" onChange="ReloadPage();">
          <option value="0">No</option>
          <option value="1">Yes</option>
        </select></td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%
if(WI.fillTextValue("is_stipend").compareTo("1") ==0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="10%"><div align="center"></div></td>
      <td width="8%">Type 1</td>
      <td width="81%"><select name="allowance1" onChange="ShowHideAllowance(1);">
          <option value="0">Others(Pl specify)</option>
<%=dbOP.loadCombo("ALLO_TYPE_INDEX","NAME"," from FA_FEE_ADJ_ALLO_TYPE where is_del=0 order by NAME asc",strTemp, false)%>
        </select> <input type="text" name="oth_allo_1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Amount </td>
      <td> <input name="amount_1" type="text" size="16">
        (Php)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="10%"><div align="center"></div></td>
      <td width="8%">Type 2</td>
      <td width="81%"><select name="allowance2" onChange="ShowHideAllowance(2);">
          <option value="0">Others(Pl specify)</option>
        <%=dbOP.loadCombo("ALLO_TYPE_INDEX","NAME"," from FA_FEE_ADJ_ALLO_TYPE where is_del=0 order by NAME asc",strTemp, false)%>
</select> <input type="text" name="oth_allo_2"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Amount </td>
      <td> <input name="amount_2" type="text" size="16">
        (Php)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="10%"><div align="center"></div></td>
      <td width="8%">Type 3</td>
      <td width="81%"><select name="allowance3" onChange="ShowHideAllowance(3);">
          <option value="0">Others(Pl specify)</option>
        <%=dbOP.loadCombo("ALLO_TYPE_INDEX","NAME"," from FA_FEE_ADJ_ALLO_TYPE where is_del=0 order by NAME asc",strTemp, false)%>
</select> <input type="text" name="oth_allo_3"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Amount </td>
      <td> <input name="amount_3" type="text" size="16">
        (Php)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="10%"><div align="center"></div></td>
      <td width="8%">Type 4</td>
      <td width="81%"><select name="allowance4" onChange="ShowHideAllowance(4);">
          <option value="0">Others(Pl specify)</option>
        <%=dbOP.loadCombo("ALLO_TYPE_INDEX","NAME"," from FA_FEE_ADJ_ALLO_TYPE where is_del=0 order by NAME asc",strTemp, false)%>
</select> <input type="text" name="oth_allo_4"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Amount </td>
      <td> <input name="amount_4" type="text" size="16">
        (Php)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="10%"><div align="center"></div></td>
      <td width="8%">Type 5</td>
      <td width="81%"><select name="allowance5" onChange="ShowHideAllowance(5);">
          <option value="0">Others(Pl specify)</option>
        <%=dbOP.loadCombo("ALLO_TYPE_INDEX","NAME"," from FA_FEE_ADJ_ALLO_TYPE where is_del=0 order by NAME asc",strTemp, false)%>
</select> <input type="text" name="oth_allo_5"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Amount </td>
      <td> <input name="amount_5" type="text" size="16">
        (Php)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="10%"><div align="center"></div></td>
      <td width="8%">Type 6</td>
      <td width="81%"><select name="allowance6" onChange="ShowHideAllowance(6);">
          <option value="0">Others(Pl specify)</option>
        <%=dbOP.loadCombo("ALLO_TYPE_INDEX","NAME"," from FA_FEE_ADJ_ALLO_TYPE where is_del=0 order by NAME asc",strTemp, false)%>
</select> <input type="text" name="oth_allo_6"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Amount </td>
      <td> <input name="amount_6" type="text" size="16">
        (Php)</td>
    </tr>
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%}//only if there is allowanace
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="1%"height="25">&nbsp;</td>
      <td colspan="3">
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{
	  if(!bolEditCalled)
	  {%>
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to add</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>
      </td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="88%" colspan="2">
        <%
	  if(bolEditCalled)
	  {%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}else{%>
        <a href="javascript:UpdateSubType();"><img src="../../../images/update.gif" border="0"></a>
        <font size="1">click to create or update sub-types for this type (show
        this if there is a sub-type)</font>
        <%}%>
      </td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5"><div align="center">LIST
          OF MAIN FEE ADJUSTMENT TYPE</div></td>
    </tr>
  </table>
<%
if(vViewAdjustment != null && vViewAdjustment.size() > 0)
{%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="19%" height="25"><div align="center"><strong><font size="1">NAME</font></strong></div></td>
      <td width="17%"><div align="center"><strong><font size="1">EXEMPTIONS/DISCOUNTS
          (AMOUNT/%)</font></strong></div></td>
      <td width="17%" align="center"><strong><font size="1">EXEMPTIONS/DISCOUNTS
        TYPE </font></strong></td>
      <td width="36%"><div align="center"><strong><font size="1">DESCRIPTION</font></strong></div></td>
      <td width="5%">&nbsp;</td>
      <td width="6%">&nbsp;</td>
    </tr>
    <%
for(int i=0; i< vViewAdjustment.size(); ++i){%>
    <tr >
      <td height="25" align="center"><%=(String)vViewAdjustment.elementAt(i+5)%></td>
      <td align="center"><%=(String)vViewAdjustment.elementAt(i+1)%> </td>
      <td align="center"><%=(String)vViewAdjustment.elementAt(i+2)%> </td>
      <td align="center">&nbsp;<%=WI.getStrValue(vViewAdjustment.elementAt(i+4))%></td>
      <td align="center"> <a href='javascript:PrepareToEdit("<%=(String)vViewAdjustment.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a></td>
      <td align="center"> <a href='javascript:DeleteRecord("<%=(String)vViewAdjustment.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <% i = i+5;
}%>
    <tr >
  </table>
<%}

}//only if sy_from and sy_to is entered.
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


</form>
</body>
</html>
