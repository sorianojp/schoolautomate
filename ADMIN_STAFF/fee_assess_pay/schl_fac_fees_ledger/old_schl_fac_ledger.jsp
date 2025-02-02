<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function FocusID() {
	document.old_ledg.stud_id.focus();
}
function ViewLedger()
{
	strStudID = document.old_ledg.stud_id.value;
	if(strStudID.length ==0)
		alert("Please enter ID.");
	else
		location="./schl_fac_ledger_view.jsp?stud_id="+escape(strStudID)+"&type=old";
}
function SubmitPage()
{
	document.old_ledg.submit();
}
function ReloadPage()
{
	document.old_ledg.reloadPage.value="1";
	SubmitPage();
}
function PageAction(strAction)
{
	if(strAction == "1")
		document.old_ledg.hide_save.src = "../../../images/blank.gif";
	document.old_ledg.page_action.value=strAction;
	SubmitPage();
}
function CancelRecord()
{
	document.old_ledg.prepareToEdit.value="0";
	SubmitPage();
}
function PrepareToEdit(strIndex)
{
	document.old_ledg.info_index.value=strIndex;
	document.old_ledg.prepareToEdit.value = "1";
	SubmitPage();
}
function DeleteRecord(strIndex)
{
	document.old_ledg.info_index.value=strIndex;
	document.old_ledg.page_action.value="0";
	SubmitPage();
}
function ShowHideFeeName()
{
	if(document.old_ledg.fee_name.selectedIndex ==0)
	{
		document.old_ledg.oth_fee_name.disabled = false;
		showLayer('oth_fee_');
		//document.old_ledg.oth_mem_type.style ="font-family:Verdana, Arial, Helvetica, sans-serif;";
	}
	else
	{
		//document.old_ledg.oth_mem_type.style ="border: 0;font-family:Verdana, Arial, Helvetica, sans-serif;";
		hideLayer('oth_fee_');
		document.old_ledg.oth_fee_name.disabled = true;
	}
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=old_ledg.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.Authentication,enrollment.FAStudentLedger,java.util.Vector,java.util.StringTokenizer" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	MessageConstant mConst = new MessageConstant();

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;

	boolean bolProceed = true;
    String[] astrConvertMonth = {"JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE","JULY","AUGUST","SEPTMBER","OCTOBER","NOVEMBER","DECEMBER"};
	String[] astrConvertTerm  = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	if(strPrepareToEdit.length() ==0)
		strPrepareToEdit = "0";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-School facility ledger","old_schl_fac_ledger.jsp");
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
														"Fee Assessment & Payments","STUDENT LEDGER",request.getRemoteAddr(),
														"old_schl_fac_ledger.jsp");
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


Vector vBasicInfo = null;
Vector vEditInfo = null;
Vector vLedgerInfo = null;
boolean bolIsStaff = false; //true only if the payee type is internal and not a student type.

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAStudentLedger studLedg = new FAStudentLedger();
//System.out.println(WI.fillTextValue("page_action"));
if(WI.fillTextValue("page_action").compareTo("0") ==0)//delete
{
	strPrepareToEdit = "0";
	if(studLedg.operateOnOldLedgerHM(dbOP,request,0,null) == null)
		strErrMsg = studLedg.getErrMsg();
	else
		strErrMsg = "Information deleted successfully.";
}
else if(WI.fillTextValue("page_action").compareTo("1") ==0)//add
{
	strPrepareToEdit = "0";
	if(studLedg.operateOnOldLedgerHM(dbOP,request,1,null) == null)
		strErrMsg = studLedg.getErrMsg();
	else
		strErrMsg = "Information added successfully.";
}
else if(WI.fillTextValue("page_action").compareTo("2") ==0)
{
	if(studLedg.operateOnOldLedgerHM(dbOP,request,2,null) == null)
		strErrMsg = studLedg.getErrMsg();
	else
	{
		strPrepareToEdit = "0";
		strErrMsg = "Information edited successfully.";
	}
}
if(WI.fillTextValue("stud_id").length() > 0 && bolProceed)
{
	vBasicInfo = paymentUtil.getStudBasicInfo(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
	{
		strErrMsg = paymentUtil.getErrMsg();
		bolIsStaff = true;
		request.setAttribute("emp_id",request.getParameter("stud_id"));
		vBasicInfo = new Authentication().operateOnBasicInfo(dbOP, request,"0");
	}
	//get posted charge detail.
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{
		//get edit information if it is called.
		if(strPrepareToEdit.compareTo("1") ==0)
		{
			vEditInfo = studLedg.operateOnOldLedgerHM(dbOP,request,4,null);
			if(vEditInfo == null)
				strErrMsg = studLedg.getErrMsg();
		}
		vLedgerInfo = studLedg.operateOnOldLedgerHM(dbOP,request,3,null);
		if(vLedgerInfo == null && strErrMsg == null)
			strErrMsg = studLedg.getErrMsg();
	}
}

if(strErrMsg == null) strErrMsg = "";
%>

<form name="old_ledg" action="./old_schl_fac_ledger.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          OLD OCCUPANTS LEDGER DATA MANAGEMENT PAGE ::::<br>
          </strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  colspan="4" height="25">&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="34%" height="25">Enter ID Number
        <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="8%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="56%" height="25"><input type="image" onClick="ReloadPage();" src="../../../images/form_proceed.gif" align="middle">
        (OR) <a href="javascript:ViewLedger();"><img src="../../../images/view.gif" border="0"></a><font size="1">view
        old occupant ledger</font></td>
    </tr>
    <tr>
      <td  colspan="4" height="25"><hr size="1"></td>
    </tr>
  </table>

<%
 if(vBasicInfo != null && vBasicInfo.size() > 0){%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td width="98%">Account type :<strong>
        <%
	  if(bolIsStaff){%>
        Employee
        <%}else{%>
        Student
        <%}%>
        </strong></td>
    </tr>
  </table>
<%
if(!bolIsStaff && vBasicInfo != null && vBasicInfo.size()> 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="44%">Account name : <strong><%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td width="54%">Year/Term : <strong><%=(String)vBasicInfo.elementAt(4)%>/
        <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
        <%
	  if(vBasicInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
        <%}%>
        </strong></td>
    </tr>
  </table>
<%}else if( vBasicInfo != null && vBasicInfo.size()> 0){%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td>Account name : <strong><%=WI.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),1)%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%">Employee type :<strong> <%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Employee status : <strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">College/Department/Office : <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/<%=(String)vBasicInfo.elementAt(14)%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2"><hr size="1"></td>
    </tr>
  </table>
<%}%>
  <table bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Transaction type</td>
      <td width="82%"><select name="transaction_type" onChange="ReloadPage();">
          <option value="1">Debit</option>
          <%
if(vEditInfo != null && WI.fillTextValue("reloadPage").compareTo("0") ==0)
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
</table>
  <table bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Month Availed </td>
      <td width="23%"><select name="month_availed" onChange="ReloadPage();">
          <option value="0">JANUARY</option>
          <%
if(vEditInfo != null && WI.fillTextValue("reloadPage").compareTo("0") ==0)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("month_availed");

for(int i=1; i< 12; ++i){
	if(strTemp.compareTo(Integer.toString(i)) ==0)
	{%>
          <option value="<%=i%>" selected><%=astrConvertMonth[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrConvertMonth[i]%></option>
          <%}
}%>
        </select></td>
      <td width="13%">Year
<%
if(vEditInfo != null && WI.fillTextValue("reloadPage").compareTo("0") ==0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("year_availed");
%>
        <input name="year_availed" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="46%" colspan="2"><input type="image" src="../../../images/form_proceed.gif" onClick="ReloadPage();">
        <font size="1">(proceed to view transaction detail)</font></td>
    </tr>
  </table>
 <%if(WI.fillTextValue("transaction_type").compareTo("0") != 0){%>
   <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" height="25">Charges for &nbsp;&nbsp; </td>
      <td width="82%" height="25" colspan="4"><select name="fee_name" onChange="ShowHideFeeName();">
<option value="0">Create a charge name</option>
<%
if(vEditInfo != null && WI.fillTextValue("reloadPage").compareTo("0") ==0)
	strTemp = (String)vEditInfo.elementAt(8);
else
	strTemp = WI.fillTextValue("fee_name");
%>
          <%=dbOP.loadCombo("FEE_NAME_INDEX","FEE_NAME"," from LEDG_OLD_DORM_FEE where is_del=0", strTemp, false)%>
        </select>
		 <input name="oth_fee_name" type="text" size="16" id="oth_fee_" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
<%
if(strTemp.compareTo("0") != 0 && strTemp.length() >0){%>
<script language="JavaScript">
hideLayer('oth_fee_');
</script>
<%}%>

    </tr>
  </table>
 <%}else{%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Transaction Date </td>
      <td width="82%">
        <%
String strMM = "";
String strDD = "";
String strYYYY = "";
if(vEditInfo != null && WI.fillTextValue("reloadPage").compareTo("0") ==0)
{
	strTemp = (String)vEditInfo.elementAt(4);
	StringTokenizer strToken = new StringTokenizer(strTemp, "/");
	if(strToken.hasMoreElements())
		strMM =(String)strToken.nextElement();
	if(strToken.hasMoreElements())
		strDD =(String)strToken.nextElement();
	if(strToken.hasMoreElements())
		strYYYY =(String)strToken.nextElement();
}
else
{
	strMM = WI.fillTextValue("mm");
	strDD = WI.fillTextValue("dd");
	strYYYY = WI.fillTextValue("yyyy");
}

%>
        <input name="mm" type="text" size="2" maxlength="2" value="<%=strMM%>">
        /
        <input name="dd" type="text" size="2" maxlength="2" value="<%=strDD%>">
        /
        <input name="yyyy" type="text" size="4" maxlength="4" value="<%=strYYYY%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>O.R. Number</td>
      <td>
<%
if(vEditInfo != null && WI.fillTextValue("reloadPage").compareTo("0") ==0)
	strTemp = (String)vEditInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("or_number");
%>
        <input name="or_number" type="text" size="16" maxlength="24" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
      </td>
    </tr>
   </table>
<%}//end of display depending on transaction type.
if(iAccessLevel > 1){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
   <tr>
      <td height="25">&nbsp;</td>
      <td width="16%">Amount </td>
      <td width="82%">
<%
if(vEditInfo != null && WI.fillTextValue("reloadPage").compareTo("0") ==0)
	strTemp = (String)vEditInfo.elementAt(7);
else
	strTemp = WI.fillTextValue("amount");
%>
        <input name="amount" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%
	if(strPrepareToEdit.compareTo("0") == 0)
	{%>
        <a href="javascript:PageAction(1);"><img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click
        to save entry</font>
        <%}else{%>
        <a href="javascript:PageAction(2);"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
        to cancel &amp; clear entries</font>
        <%}%>
      </td>
    </tr>
  </table>
<%}//if iAccessLevel > 1
if(vLedgerInfo != null && vLedgerInfo.size() > 0){%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#B9B292"><div align="center">TRANSACTION
          DETAIL FOR <strong><%=astrConvertMonth[Integer.parseInt(request.getParameter("month_availed"))]%> <%=request.getParameter("year_availed")%>
		  </strong></div></td>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td width="31%" height="25"><div align="center"><font size="1"><strong>PARTICULAR</strong></font></div></td>
      <td width="29%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
      <td width="11%"><font size="1"><strong>EDIT</strong></font></td>
      <td width="29%"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
<%
for(int i = 0; i<vLedgerInfo.size(); ++i){
strTemp = (String)vLedgerInfo.elementAt(i+3);
if(strTemp.compareTo("0") ==0)//credit,get or number.
	strTemp = (String)vLedgerInfo.elementAt(i+6)+"("+(String)vLedgerInfo.elementAt(i+4)+")";
else
	strTemp = (String)vLedgerInfo.elementAt(i+5);
%>
    <tr>
      <td height="25"><%=strTemp%></td>
      <td><%=CommonUtil.formatFloatToLedger((String)vLedgerInfo.elementAt(i+7))%></td>
      <td>
<%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vLedgerInfo.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}else{%>Not authorized<%}%>	  </td>
      <td>
<%if(iAccessLevel > 1){%>
	  <a href='javascript:DeleteRecord("<%=(String)vLedgerInfo.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
<%}else{%>Not authorized<%}%>	  </td>
    </tr>
<%
i = i+8;
}%>
  </table>
<%
	}//only if ledger info is not null;
}//only if basic info exists -- the occupant is there on database.
%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="31%" height="25"><div align="right"> </div></td>
      <td width="69%">&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<%
if(vBasicInfo != null){%>
<input type="hidden" name="user_index" value="<%=(String)vBasicInfo.elementAt(0)%>">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
