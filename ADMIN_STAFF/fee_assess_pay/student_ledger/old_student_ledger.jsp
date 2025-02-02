<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	ShowLedgerDetail();
	document.ledger_old.submit();
}
function UpdateCatg() {
	var pgLoc = "./old_student_ledger_category.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrepareToEdit(strInfoIndex)
{
	document.ledger_old.editRecord.value = 0;
	document.ledger_old.deleteRecord.value = 0;
	document.ledger_old.addRecord.value = 0;
	document.ledger_old.prepareToEdit.value = 1;

	document.ledger_old.info_index.value = strInfoIndex;

	document.ledger_old.submit();

}
function AddRecord()
{
	if(document.ledger_old.prepareToEdit.value == 1)
	{
		EditRecord(document.ledger_old.info_index.value);
		return;
	}
	document.ledger_old.editRecord.value = 0;
	document.ledger_old.deleteRecord.value = 0;
	document.ledger_old.addRecord.value = 1;

	document.ledger_old.submit();
}
function EditRecord(strTargetIndex)
{
	document.ledger_old.editRecord.value = 1;
	document.ledger_old.deleteRecord.value = 0;
	document.ledger_old.addRecord.value = 0;

	document.ledger_old.info_index.value = strTargetIndex;
	document.ledger_old.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.ledger_old.editRecord.value = 0;
	document.ledger_old.deleteRecord.value = 1;
	document.ledger_old.addRecord.value = 0;

	document.ledger_old.info_index.value = strTargetIndex;
	document.ledger_old.prepareToEdit.value == 0;

	document.ledger_old.submit();
}
function CancelRecord()
{
	document.ledger_old.prepareToEdit.value = 0;
	document.ledger_old.editRecord.value = 0;
	document.ledger_old.submit();
}
function ShowLedgerDetail()
{
	document.ledger_old.showLedgerDetail.value = "1";
	document.ledger_old.prepareToEdit.value = 0;
	document.ledger_old.editRecord.value = 0;
}
//for debit -- or number is disabled, but for credit, enable it again.
function ShowHideORNumber()
{
	if(document.ledger_old.transaction_type.selectedIndex <1) //credit
		document.ledger_old.or_number.disabled = true;
	else
		document.ledger_old.or_number.disabled = false;
}
function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var pgLoc = "./old_student_ledger_print.jsp?stud_id="+escape(document.ledger_old.stud_id.value)+"&sy_from="+
			document.ledger_old.sy_from.value+"&sy_to="+document.ledger_old.sy_to.value+"&semester="+
			document.ledger_old.semester[document.ledger_old.semester.selectedIndex].value;

	var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function focusMM() {
	if(document.ledger_old.focus_mm.value == 1)
		document.ledger_old.stud_id.focus();
	if(document.ledger_old.focus_mm.value == 2)
		document.ledger_old.sy_from.focus();
	if(document.ledger_old.focus_mm.value == 3)
		document.ledger_old.mm.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=ledger_old.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.ledger_old.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.ledger_old.stud_id.value = strID;
	document.ledger_old.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.ledger_old.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>

<body bgcolor="#D2AE72" onLoad="javascript:focusMM();">
<%@ page language="java" import="utility.*,enrollment.FAStudentLedger,enrollment.FAPaymentUtil,java.util.Vector,java.util.StringTokenizer"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & OLD STUDENT ACCOUNT MGMT-Old student account mgmt","old_student_ledger.jsp");
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
														"Fee Assessment & Payments","OLD STUDENT ACCOUNT MGMT",request.getRemoteAddr(),
														"old_student_ledger.jsp");
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
//if ID is basic info ID, forward the page.
if(WI.fillTextValue("stud_id").length() > 0 &&
		dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("stud_id")+"'","user_index", " and IS_BASIC_EDU = 1") != null) {
	dbOP.cleanUP();
	response.sendRedirect(response.encodeRedirectURL("./basic_old_stud_ledger_mgmt.jsp?stud_id="+
		WI.fillTextValue("stud_id")));
	return;
}

Vector vStudInfo = new Vector();
Vector vLedgerHist = new Vector();
Vector vEditInfo = null;
boolean bolErr = false; //only if there is any error in operation.
String strTemp2 = null;

FAPaymentUtil pmtUtil = new FAPaymentUtil();
FAStudentLedger studLedger = new FAStudentLedger();

vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));

if(vStudInfo == null || vStudInfo.size() == 0)
	strErrMsg = pmtUtil.getErrMsg();
else
{
	//check and save information here.
	if(WI.fillTextValue("addRecord").compareTo("1") ==0)
	{
		strPrepareToEdit = "0";
		if(!studLedger.operateOnOldLedger(dbOP,request,1))
		{
			strErrMsg = studLedger.getErrMsg();
			bolErr = true;
		}
		else	strErrMsg = "Record saved successfully.";
	}
	else if(WI.fillTextValue("deleteRecord").compareTo("1") ==0)
	{
		strPrepareToEdit = "0";
		if(!studLedger.operateOnOldLedger(dbOP,request,0))
		{ strErrMsg = studLedger.getErrMsg();bolErr = true;}
		else
			strErrMsg = "Record deleted successfully.";
	}
	else if(WI.fillTextValue("editRecord").compareTo("1") ==0)
	{

		if(!studLedger.operateOnOldLedger(dbOP,request,2))
		{strErrMsg = studLedger.getErrMsg();bolErr = true;}
		else
		{strPrepareToEdit = "0";strErrMsg = "Record infomation changed successfully.";}
	}
	if(!bolErr) //get ledger history.
	{
		vLedgerHist = studLedger.viewOldStudLedger(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("sy_from"),
			request.getParameter("sy_to"),request.getParameter("semester"));
		if(vLedgerHist == null)
			strErrMsg = studLedger.getErrMsg();
	}
}
//get edit info if strPrepareToEdit is 1
//System.out.println(strPrepareToEdit);
if(strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = studLedger.viewOldLedger(dbOP, request.getParameter("info_index"));
	if(vEditInfo == null)
		strErrMsg = studLedger.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";


if(strErrMsg == null) strErrMsg = "";
%>
<form name="ledger_old" action="./old_student_ledger.jsp" method="post">
<input type="hidden" name="focus_mm">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          OLD STUDENT ACCOUNT MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="top">
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" colspan="2">Student ID &nbsp; </td>
      <td width="16%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
      </td>
      <script language="JavaScript">
document.ledger_old.focus_mm.value = "1";
</script>
      <td width="8%"> &nbsp;<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
        &nbsp; </td>
      <td width="63%"><input name="image2" type="image" src="../../../images/form_proceed.gif">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>
	  </td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1">
	  <!-- hidden student information here -->
	  <input type="hidden" value="<%=(String)vStudInfo.elementAt(0)%>" name="stud_index">
	  <input type="hidden" value="<%=(String)vStudInfo.elementAt(4)%>" name="year_level">

	  </td>
    </tr>
    <tr>
      <td  width="1%" height="25">&nbsp;</td>
      <td width="43%" height="25">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%></strong></td>
      <td height="25"  colspan="4">Course/Major : <strong><%=(String)vStudInfo.elementAt(2)%>
        <%if(vStudInfo.elementAt(3) != null){%>
		/ <%=WI.getStrValue(vStudInfo.elementAt(3))%>
		<%}%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Current Year :<strong> <%=(String)vStudInfo.elementAt(4)%></strong>
      </td>
      <td  colspan="4" height="25">Current Term : <strong><%=(String)vStudInfo.elementAt(5)%></strong></td>
    </tr>
    <tr>
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">School Year :
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ledger_old","sy_from","sy_to")'>
        to
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
<script language="JavaScript">
document.ledger_old.focus_mm.value = "2";
</script>
      <td  colspan="2" height="25">Term :
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3")==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
      </td>
      <td width="30%" height="25"><input name="image" type="image" onClick="ShowLedgerDetail()" src="../../../images/form_proceed.gif"></td>
      <td width="4%" height="25">&nbsp;</td>
    </tr>
  </table>
<%
if(WI.fillTextValue("showLedgerDetail").compareTo("1") ==0)
{%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Transaction type</td>
      <td><select name="transaction_type" onChange="ShowHideORNumber();">
          <option value="1">Debit</option>
<%
if(vEditInfo != null && !bolErr)
	strTemp2 = (String)vEditInfo.elementAt(3);
else
	strTemp2 = WI.fillTextValue("transaction_type");
if(strTemp2.compareTo("0") ==0)
{%>
          <option value="0" selected>Credit</option>
<%}else{%>
          <option value="0">Credit</option>
<%}%>
        </select></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Transaction Date </td>
      <td>
        <%
if(vEditInfo != null && !bolErr)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("transaction_date");
String strMM = "";
String strDD = "";
String strYYYY = "";
StringTokenizer strToken = new StringTokenizer(strTemp, "/");
if(strToken.hasMoreElements())
	strMM =(String)strToken.nextElement();
if(strToken.hasMoreElements())
	strDD =(String)strToken.nextElement();
if(strToken.hasMoreElements())
	strYYYY =(String)strToken.nextElement();

if(strMM.length() == 0)
	strMM = WI.fillTextValue("mm");
if(strDD.length() == 0)
	strDD = WI.fillTextValue("dd");
if(strYYYY.length() == 0)
	strYYYY = WI.fillTextValue("yyyy");
%>
        <input name="mm" type="text" size="2" maxlength="2" value="<%=strMM%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="dd" type="text" size="2" maxlength="2" value="<%=strDD%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        /
        <input name="yyyy" type="text" size="4" maxlength="4" value="<%=strYYYY%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
<script language="JavaScript">
document.ledger_old.focus_mm.value = "3";
</script>
<%if(strSchCode.startsWith("EAC")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Particulars</td>
      <td>
<%
/**
if(vEditInfo != null && !bolErr)
	strTemp = (String)vEditInfo.elementAt(8);
else
	strTemp = WI.fillTextValue("catg_index");
**/
if(vEditInfo != null && !bolErr)
	strTemp = WI.getStrValue(vEditInfo.elementAt(5));
else
	strTemp = WI.fillTextValue("transaction_name");
%>
		  <select name="transaction_name">
		  	<option value=""></option>
    	      <%=dbOP.loadCombo("LEDG_OLD_DATA_CATG.description","LEDG_OLD_DATA_CATG.description"," from LEDG_OLD_DATA_CATG order by LEDG_OLD_DATA_CATG.description", strTemp, false)%>
		  </select>	  
		  <a href="javascript:UpdateCatg();"><img src="../../../images/update.gif" border="0" height="22" width="60"></a>
	  </td>
    </tr>
<%}else{%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Particulars </td>
      <td>
<%
if(vEditInfo != null && !bolErr)
	strTemp = WI.getStrValue(vEditInfo.elementAt(5));
else
	strTemp = WI.fillTextValue("transaction_name");
%>	  <input name="transaction_name" type="text" size="64" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>O.R. Number</td>
      <td>
<%
if(strTemp2 == null || strTemp2.length() ==0 || strTemp2.compareTo("1") ==0)//transaction type.
	strTemp2 = "disabled";
else
	strTemp2 = "";
if(vEditInfo != null && !bolErr)
	strTemp = WI.getStrValue(vEditInfo.elementAt(6));
else
	strTemp = WI.fillTextValue("or_number");
%>
	  <input name="or_number" type="text" size="16" maxlength="24" value="<%=strTemp%>" <%=strTemp2%> class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="18%">Amount </td>
      <td width="80%">Php
<%
if(vEditInfo != null && !bolErr)
	strTemp = (String)vEditInfo.elementAt(7);
else
	strTemp = WI.fillTextValue("amount");
%>
        <input name="amount" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> </td>
    </tr>
<%if(iAccessLevel >1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click
        to add</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>      </td>
    </tr>
<%}//if iAccessLevel > 1%>
  </table>

<%
if(vLedgerHist	!= null && vLedgerHist.size() > 1){%>
  <table   width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td width="11%" height="25" align="center"><font size="1"><strong>DATE</strong></font></td>
      <!--<td width="11%" align="center"><font size="1"><strong>CATEGORY</strong></font></td>-->
      <td align="center" width="40%" ><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="13%" align="center"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="13%" align="center"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="17%" align="center"><font size="1"><strong>BALANCE</strong></font></td>
      <td width="17%" align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td width="17%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>

	<tr>
      <td height="25" align="center">&nbsp;</td>
      <!--<td align="center">&nbsp;</td>-->
      <td align="center">Previous outstanding balance
	  <%
	  if(((String)vLedgerHist.elementAt(0)).startsWith("-")){%>
	  (Excess)<%}%>	  </td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(0))%></td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
    </tr>
<%
for(int i = 1; i< vLedgerHist.size() ; ++i)
{%>
    <tr>
      <td height="25" align="center">&nbsp;<%=(String)vLedgerHist.elementAt(i+2)%></td>
      <!--<td align="center">&nbsp;<%=WI.getStrValue(vLedgerHist.elementAt(i+9), "Default")%></td>-->
      <td align="center">&nbsp;<%=WI.getStrValue(vLedgerHist.elementAt(i+3))%>
	  <%
	  //if or number existing -- show it.
	  if(vLedgerHist.elementAt(i+1) != null){%>
	  /OR No. <%=(String)vLedgerHist.elementAt(i+1)%>
	  <%}%></td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(i+4))%></td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(i+5))%></td>
      <td align="center">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerHist.elementAt(i+7))%></td>
      <td align="center">
<%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vLedgerHist.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}else{%>Not authorized<%}%>	  </td>
      <td align="center">
<%if(iAccessLevel == 2){%>
	  <a href='javascript:DeleteRecord("<%=(String)vLedgerHist.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
<%}else{%>Not authorized<%}%>	  </td>
    </tr>
<%
i = i+11;
}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td height="25"><div align="left"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
          to print ledger</font></div></td>
    </tr>
</table>
 <%}//if vLedgerHist != null ;


 }//if student information exists.
}//if ShowLedgerDetail is 1
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
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
<input type="hidden" name="showLedgerDetail" value="<%=WI.fillTextValue("showLedgerDetail")%>">
<input type="hidden" name="prev_trans_type" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
