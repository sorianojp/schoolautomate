<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
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
	document.fa_type.reloadPage3.value="1";
	document.fa_type.submit();
}
/**
function UpdateSubType()
{
	document.fa_type.updateSubType3.value = "1";
	document.fa_type.prepareToEdit.value = "0";
	ReloadPage();
}
**/
function PrepareToEdit(strInfoIndex)
{
//	document.fa_type.updateSubType3.value = "1";
	document.fa_type.editRecord.value = 0;
	document.fa_type.deleteRecord.value = 0;
	document.fa_type.addRecord.value = 0;
	document.fa_type.prepareToEdit.value = 1;
	document.fa_type.info_index.value = strInfoIndex;
	ReloadPage();
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
	
	ReloadPage();
}
function EditRecord(strTargetIndex)
{
	document.fa_type.editRecord.value = 1;
	document.fa_type.deleteRecord.value = 0;
	document.fa_type.addRecord.value = 0;

	document.fa_type.info_index.value = strTargetIndex;

	ReloadPage();
}

function DeleteRecord(strTargetIndex)
{
	document.fa_type.editRecord.value = 0;
	document.fa_type.deleteRecord.value = 1;
	document.fa_type.addRecord.value = 0;

	document.fa_type.info_index.value = strTargetIndex;
	document.fa_type.prepareToEdit.value == 0;

	ReloadPage();
}
function CancelRecord()
{
	document.fa_type.editRecord.value = 0;
	document.fa_type.deleteRecord.value = 0;
	document.fa_type.addRecord.value = 0;
	document.fa_type.prepareToEdit.value =0;
	document.fa_type.info_index.value = "0";
	document.fa_type.type_name3.value="";

	ReloadPage();
}
//to go back to parent file.
function GoBack()
{
	location = "./fee_adjustment_type_subtype_subtype.jsp?type_name0="+escape(document.fa_type.type_name0.value)+"&type_name1="+
		escape(document.fa_type.type_name1.value)+"&type_name2="+escape(document.fa_type.type_name2.value)+"&is_subtype2=1&sy_from="+
		document.fa_type.sy_from.value+"&sy_to="+document.fa_type.sy_to.value+"&semester="+document.fa_type.semester.value;
}
function ShowHideMultipleDisc() {
//	if(document.fa_type.is_subtype3.selectedIndex == 1)
//		return;
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
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Fee adjustment type","fee_adjustment_type_subtype_subtype_subtype.jsp");
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
														"fee_adjustment_type_subtype_subtype_subtype.jsp");
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

Vector vViewAdjustment = null;
Vector vEditInfo = null;//if edit is clicked.
Vector vTemp = null;

boolean bolEditCalled = false;
boolean bolProceed = true;

FAPmtMaintenance FA = new FAPmtMaintenance();
//create the parent adjustment type if it is first time.
if(request.getParameter("reloadPage3") == null || request.getParameter("reloadPage3").trim().length() ==0) //first time
	FA.addFeeAdjustmentType(dbOP, request, 2);

strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.equals("1"))
{
	strPrepareToEdit="0";

	//add it here and give a message.
	if(FA.addFeeAdjustment(dbOP,request,3))
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
		if(FA.editFeeAdjustment(dbOP,request,3))
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

			if(FA.deleteFeeAdjustment(dbOP,request,3))
				strErrMsg = "Fee adjustment Type deleted successfully.";
			else
			{
				//bolProceed = false;
				strErrMsg = FA.getErrMsg();
			}
		}
	}
}

if(bolProceed)
{
	vViewAdjustment = FA.viewFeeAdjustment(dbOP, 3,request.getParameter("sy_from"),request.getParameter("sy_to"),
											request.getParameter("semester"),request.getParameter("type_name2"));//level is zero.
	if(vViewAdjustment ==null)
		strErrMsg = FA.getErrMsg();
}

if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = FA.viewOneFeeAdjustment(dbOP,3,request.getParameter("info_index"));
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

<form name="fa_type" action="./fee_adjustment_type_subtype_subtype_subtype.jsp" method="post">
<input type="hidden" name="sy_from" value="<%=request.getParameter("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=request.getParameter("sy_to")%>">
<input type="hidden" name="semester" value="<%=request.getParameter("semester")%>">

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          FEE ADJUSTMENT TYPE SUB-TYPE SUB-TYPE SUB-TYPE PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="98%" height="25"> <a href="javascript:GoBack();" target="_self"><img src="../../../images/go_back.gif" border="0"></a> 
        <strong><font size="3" color="#FF0000"><%=strErrMsg%></font></strong> 
        <%
if(!bolProceed)
	return;
%>
</td>
    </tr>
  <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td>Adjustment type name: <strong><%=request.getParameter("type_name0")%></strong>
		<input name="type_name0" type="hidden" value="<%=request.getParameter("type_name0")%>"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Adjustment sub-type name: <strong><%=request.getParameter("type_name1")%></strong>
		<input name="type_name1" type="hidden" value="<%=request.getParameter("type_name1")%>"></td>
    </tr>
	<tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Adjustment sub-type sub-type name: <strong><%=request.getParameter("type_name2")%></strong>
		<input name="type_name2" type="hidden" value="<%=request.getParameter("type_name2")%>"></td>
    </tr>
    <tr>
      <td colspan="2"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Sub-type
        name </td>
      <td width="52%">
        <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("type_name3");
%>
	  <input name="type_name3" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      		<input type="hidden" name="old_type" value="<%=strTemp%>"><!--for edit-->
      </td>
      <td width="18%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="28%">Exemptions/discount
        <label id="row_3">(Tuition)</label></td>
      <td  colspan="2">
        <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(0);
else
	strTemp = WI.fillTextValue("discount");
%>
        <input name="discount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <select name="discount_unit">
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
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>unit</option>
          <%}else{%>
          <option value="2">unit</option>
          <%}%>
        </select>
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
<% if (strSchCode.startsWith("CPU")) {%>
	Non CPU Funded Adjustment	
<%}else{%> 
    Non School Fee Adjustment
<%}%> 		
		</font></strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Exemptions/discounts type </td>
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
if(strTemp == null)
	strTemp = "";
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
        </select> 
        <%
if(strPrepareToEdit.compareTo("1") == 0){%>
        <a href='javascript:AddMoreDiscounts("<%=request.getParameter("info_index")%>");'><img src="../../../images/update.gif" border="0"></a> 
        <font size="1">&lt;Add Other Charges Fees&gt;</font> 
        <%}%>
        <strong><font color="#0000FF"> </font></strong></td>
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
if(strSchCode.startsWith("CPU")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Scholarship Type </td>
      <td colspan="2">
	  <input type="checkbox" name="visibility_stat" value="1" <%=strTemp%>>
	  <strong> Release through cash disbursement</strong></td>
    </tr>
<%}//show only if cpu 
else{ %>
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
        </select></td>
    </tr>
<%} // academic / atheletic type not required for cpu %>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Description</td>
      <td colspan="2">
        <%
if(bolEditCalled)
	strTemp = WI.getStrValue(vEditInfo.elementAt(4));
else
	strTemp = "";
%>
        <textarea name="description" cols="45" rows="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to add</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>
      </td>
    </tr>
<%}//iAccessLevel > 1%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5"><div align="center">LIST OF AVAILABLE SUB-TYPE FOR SUB-TYPE OF <strong><%=request.getParameter("type_name2")%></strong></div></td>
    </tr>
  </table>
<%
if(vViewAdjustment != null && vViewAdjustment.size() > 0)
{%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="15%" height="25"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>DISCOUNT</strong></font></div></td>
      <td width="10%" align="center"><font size="1"><strong>DISCOUNT TYPE</strong></font></td>
      <td width="20%"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="20%"><strong><font size="1">ADDITIONAL DISCOUNT</font></strong></td>
      <td width="6%"><strong><font size="1">NON SCH FEE</font></strong></td>
      <td width="4%"><strong><font size="1">Max Units</font></strong></td>
      <td width="6%"><div align="center"><font size="1"><strong>STIPEND</strong></font></div></td>
      <td width="6%" align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td width="7%"><font size="1"><strong>DELETE</strong></font></td>
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
      <td height="25" align="center"><%=(String)vViewAdjustment.elementAt(i+5)%><font size="1"><b><%=WI.getStrValue(astrConvertDiscountType[Integer.parseInt((String)vViewAdjustment.elementAt(i + 8))], "<br>","","")%></b></font></td>
      <td align="center"><%=(String)vViewAdjustment.elementAt(i+1)%> </td>
      <td align="center"><%=(String)vViewAdjustment.elementAt(i+2)%> </td>
      <td align="center">&nbsp;<%=WI.getStrValue(vViewAdjustment.elementAt(i+4))%></td>
      <td valign="top"><%=strTemp%></td>
      <td align="center">&nbsp; <%if( ((String)vViewAdjustment.elementAt(i+6)).compareTo("1") == 0){%> <img src="../../../images/tick.gif"> <%}%> </td>
      <td align="center">&nbsp;<%=WI.getStrValue(vViewAdjustment.elementAt(i+10))%></td>
      <td align="center"> <%
	  if(vViewAdjustment.elementAt(i+1) != null && ((String)vViewAdjustment.elementAt(i+1)).compareTo("-") !=0){%> <a href='javascript:UpdateStipend("<%=(String)vViewAdjustment.elementAt(i)%>");'><img src="../../../images/update.gif" border="0"></a> 
        <%}else{%> &nbsp; <%}%> </td>
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
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="reloadPage3" value="0">

<script language="JavaScript">
this.ShowHideMultipleDisc();
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>