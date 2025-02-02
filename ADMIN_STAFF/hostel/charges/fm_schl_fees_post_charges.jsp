<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function SubmitPage()
{
	document.post_charge.submit();
}
function ReloadPage()
{
	document.post_charge.reloadPage.value="1";
	SubmitPage();
}
function PageAction(strAction)
{
	document.post_charge.page_action.value=strAction;
	SubmitPage();
}
function ChangeFeeName()
{
	document.post_charge.prepareToEdit.value="0";
	SubmitPage();
}
function PrepareToEdit(strIndex)
{
	document.post_charge.info_index.value=strIndex;
	document.post_charge.prepareToEdit.value = "1";
	SubmitPage();
}
function DeleteRecord(strIndex)
{
	document.post_charge.info_index.value=strIndex;
	document.post_charge.page_action.value="0";
	SubmitPage();
}
function CancelRecord()
{
	ChangeFeeName();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.Authentication,enrollment.HostelManagement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	MessageConstant mConst = new MessageConstant();

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strCurSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	String strCurSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	boolean bolProceed = true;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
    String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","Septmber","October","November","December"};

	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	if(strPrepareToEdit.length() ==0)
		strPrepareToEdit = "0";

	if(strCurSYFrom == null || strCurSYTo == null)
	{
		bolProceed = false;
		strErrMsg = "You are logged out. Please login again.";
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Hostel Management-CHARGES- Post Charges","fm_schl_fees_post_charges.jsp");
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
														"Hostel Management","CHARGES",request.getRemoteAddr(),
														"fm_schl_fees_post_charges.jsp");
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
Vector vPostedCharge = null;//charges posted already.
Vector vToPostCharge = null;//charges not posted yet
Vector vEditInfo = null;
Vector vHostelAccountInfo = null; // if it is null - person is not a occupant.
boolean bolIsStaff = false; //true only if the payee type is internal and not a student type.

FAPaymentUtil paymentUtil = new FAPaymentUtil();
HostelManagement HM = new HostelManagement();

if(WI.fillTextValue("page_action").compareTo("0") ==0)
{
	strPrepareToEdit = "0";
	if(HM.operateOnPostCharges(dbOP,request,0) == null)
		strErrMsg = HM.getErrMsg();
	else
		strErrMsg = "Posted charge removed successfully.";
}
else if(WI.fillTextValue("page_action").compareTo("1") ==0)
{
	strPrepareToEdit = "0";
	if(HM.operateOnPostCharges(dbOP,request,1) == null)
		strErrMsg = HM.getErrMsg();
	else
		strErrMsg = "Charge posted successfully.";
}
else if(WI.fillTextValue("page_action").compareTo("2") ==0)
{
	if(HM.operateOnPostCharges(dbOP,request,2) == null)
		strErrMsg = HM.getErrMsg();
	else
	{
		strPrepareToEdit = "0";
		strErrMsg = "Posted charge edited successfully.";
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
		vPostedCharge = HM.operateOnPostCharges(dbOP,request,3);
		//if(vPostedCharge == null) System.out.println(HM.getErrMsg());
		//get edit information if it is called.
		if(strPrepareToEdit.compareTo("1") ==0)
		{
			vEditInfo = HM.operateOnPostCharges(dbOP,request,4);
			if(vEditInfo == null)
				strErrMsg = HM.getErrMsg();
		}
		if(vEditInfo != null)
			strTemp = (String)vEditInfo.elementAt(1);
		else
			strTemp = null;
		if(WI.fillTextValue("month_availed").length() > 0)//it is not first time -- so check
		{
			vToPostCharge = HM.getVariablePayableToPost(dbOP,(String)vBasicInfo.elementAt(0),request.getParameter("fee_name"),
				request.getParameter("year_availed"),request.getParameter("month_availed"),strTemp ); //include variable pay index for edit.
			if(vToPostCharge == null)
				strErrMsg = HM.getErrMsg();
		}
		//get hostel account information.
		vHostelAccountInfo = HM.viewHostelAccountInfo(dbOP,request.getParameter("stud_id"));
		if(vHostelAccountInfo == null)
			strErrMsg = HM.getErrMsg();
	}
}

if(strErrMsg == null) strErrMsg = "";
%>

<form name="post_charge" action="./fm_schl_fees_post_charges.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHOOL FACILITIES FEES MAINTENANCE - POST CHARGES PAGE :::: </strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"> &nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="42%">Fee name :
        <select name="fee_name" onChange="ChangeFeeName();">
          <option value="0">Select a fee</option>
          <%
strTemp = " from FA_SCH_FACILITY join FA_SCHYR on (FA_SCH_FACILITY.sy_index=FA_SCHYR.sy_index) "+
				"where is_del=0 and is_valid=1 and sy_from="+strCurSYFrom+" and sy_to="+strCurSYTo+" and facility_type=1 order by fee_name,facility_type asc";
%>
          <%=dbOP.loadCombo("SCH_FAC_FEE_INDEX","FEE_NAME",strTemp, WI.fillTextValue("fee_name"), false)%>
        </select></td>
      <td width="54%">School Year<strong> : <%=strCurSYFrom%> - <%=strCurSYTo%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="9%">Enter ID </td>
      <td width="27%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="60%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
 if(vBasicInfo != null && vBasicInfo.size() > 0){%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td  width="4%"height="25">&nbsp;</td>
      <td width="96%">Account type :<strong>
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
      <td width="42%">Account name : <strong><%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td width="54%">Year/Term : <strong><%=(String)vBasicInfo.elementAt(4)%>/
        <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="2">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
        <%
	  if(vBasicInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
        <%}%>
        </strong></td>
    </tr>
<input type="hidden" name="year_level" value="<%=(String)vBasicInfo.elementAt(4)%>">
<input type="hidden" name="semester" value="<%=(String)vBasicInfo.elementAt(5)%>">
<input type="hidden" name="sy_from" value="<%=(String)vBasicInfo.elementAt(8)%>">
<input type="hidden" name="sy_to" value="<%=(String)vBasicInfo.elementAt(9)%>">

  </table>
<%}else if( vBasicInfo != null && vBasicInfo.size()> 0){%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td>Account name : <strong><%=WI.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),1)%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%">Employee type :<strong> <%=(String)vBasicInfo.elementAt(15)%></strong></td>
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
<%}
if(vHostelAccountInfo == null){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="4%"></td>
		<td>Account information not found.</td>
	</tr>
</table>
<%}else{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="25"></td>
      <td width="46%">Loction/Room #/Rent : <%=(String)vHostelAccountInfo.elementAt(2)%>/<%=(String)vHostelAccountInfo.elementAt(4)%>/
        <%=(String)vHostelAccountInfo.elementAt(5)%></td>
      <td colspan="2">Date of Occupancy: <%=(String)vHostelAccountInfo.elementAt(9)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Charges for the month of :
        <select name="month_availed">
          <option value="0">January</option>
          <%
strTemp = WI.fillTextValue("month_availed");
for(int i=1; i< 12; ++i){
	if(strTemp.compareTo(Integer.toString(i)) ==0)
	{%>
          <option value="<%=i%>" selected><%=astrConvertMonth[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrConvertMonth[i]%></option>
          <%}
}%>
        </select> </td>
      <td width="16%">Year :
        <input name="year_availed" type="text" size="4" value="<%=WI.fillTextValue("year_availed")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="34%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td>Charges(unit) :
        <select name="variable_pay">
          <%
//only if there are any payable left to pay.
if(vEditInfo != null && WI.fillTextValue("reloadPage").compareTo("1") !=0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("variable_pay");

if(vToPostCharge!= null && vToPostCharge.size() > 0){
	for(int i =0; i< vToPostCharge.size() ; ++i){
	if(strTemp.compareTo((String)vToPostCharge.elementAt(i)) ==0){%>
          <option selected value="<%=(String)vToPostCharge.elementAt(i)%>"><%=(String)vToPostCharge.elementAt(i+1)%>(<%=(String)vToPostCharge.elementAt(i+2)%>)</option>
          <%}else{%>
          <option value="<%=(String)vToPostCharge.elementAt(i)%>"><%=(String)vToPostCharge.elementAt(i+1)%>(<%=(String)vToPostCharge.elementAt(i+2)%>)</option>
          <%}
	i = i+2;
	}
 }%>
        </select></td>
      <td colspan="2">Amount payable : Php
        <%
//only if there are any payable left to pay.
if(vEditInfo != null && WI.fillTextValue("reloadPage").compareTo("1") !=0)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("amount");
if(vToPostCharge != null && vToPostCharge.size()> 0){%>
        <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <%}%>
      </td>
    </tr>
    <%
	  if(vToPostCharge != null && vToPostCharge.size() ==0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Particulars <font size="1">(consumption readings):
        <input name="textfield" type="text" size="56" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"> All charges are posted. </td>
    </tr>
    <%}%>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(iAccessLevel > 1){%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%" height="25" colspan="3">
	  <%
	if(strPrepareToEdit.compareTo("0") == 0)
	{%>
        <a href="javascript:PageAction(1);"><img src="../../../images/save.gif" border="0"></a><font size="1">click
        to save entry</font>
        <%}else{%>
        <a href="javascript:PageAction(2);"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
        to cancel &amp; clear entries</font>
        <%}%>
		</td>
    </tr>
<%}//if iAccessLevel > 1%>
  </table>
<%
if(vPostedCharge  != null && vPostedCharge.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="13" bgcolor="#B9B292"><div align="center">LIST
          OF CHARGES AND AMOUNT PAYABLES FOR <%=astrConvertMonth[Integer.parseInt(request.getParameter("month_availed"))]%>
		  &nbsp;<%=request.getParameter("year_availed")%></div></td>
    </tr>
    <tr > <td width="4%" >&nbsp;</td>
      <td width="28%" height="25" ><strong><font size="1">CHARGES</font></strong></td>
      <td width="27%" ><strong><font size="1">UNIT</font></strong></td>
      <td width="24%" ><strong><font size="1">AMOUNT PAYABLE</font></strong></td>
      <td width="7%" align="center"><strong><font size="1">EDIT</font></strong></td>
      <td width="10%" ><strong><font size="1">DELETE</font></strong></td>
    </tr>
<%
float fTotalPayable = 0;
for(int i=0; i< vPostedCharge.size() ; ++i){
fTotalPayable += Float.parseFloat((String)vPostedCharge.elementAt(i+4));
%>
    <tr>
      <td width="4%" ></td>
	  <td height="25"><%=(String)vPostedCharge.elementAt(i+2)%></td>
      <td height="25"><%=(String)vPostedCharge.elementAt(i+3)%></td>
      <td height="25"><%=CommonUtil.formatFloat((String)vPostedCharge.elementAt(i+4),true)%></td>
      <td align="center">
<%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vPostedCharge.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}else{%>Not authorized<%}%>	  </td>
      <td>
<%if(iAccessLevel > 1){%>
	  <a href='javascript:DeleteRecord("<%=(String)vPostedCharge.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
<%}else{%>Not authorized<%}%>
	  </td>
    </tr>
<%
i = i+4;
}%>

    <tr >
      <td height="25" colspan="3"><div align="right">TOTAL AMOUNT PAYABLE :</div></td>
      <td  colspan="2" height="25"> <strong>&nbsp; Php <%=CommonUtil.formatFloat(fTotalPayable,true)%></strong></td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<%		}//if vPostedCharge != null
	}//if vHostelAccountInfo  != null
}//if vBasicInfo != null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="reloadPage" value="0">
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
