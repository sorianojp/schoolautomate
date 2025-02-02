<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == "1")
		document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function ViewLedger(strStudID) {
	var pgLoc = "./ledger.jsp?stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=500,scrollbars=yes,top=10,left=10,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Donation","post_donation.jsp");
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
														"Fee Assessment & Payments","DONATION",request.getRemoteAddr(),
														"post_donation.jsp");
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

Vector vStudInfo = null;
Vector vRetResult = null;

enrollment.FADonation faDonation  = new enrollment.FADonation();
enrollment.FAPaymentUtil paymentUtil = new enrollment.FAPaymentUtil();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(faDonation.operateOnPostDonation(dbOP, request,Integer.parseInt(strTemp)) == null)
		strErrMsg = faDonation.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
if(WI.fillTextValue("stud_id").length() > 0)//only if student id is entered.
{
	vStudInfo = paymentUtil.getStudBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null) 
		strErrMsg = paymentUtil.getErrMsg();
}

if(WI.fillTextValue("view_all").length() > 0 || WI.fillTextValue("stud_id").length() > 0){
	vRetResult = faDonation.operateOnPostDonation(dbOP, request,4);
	if(strErrMsg == null && vRetResult == null)
		strErrMsg = faDonation.getErrMsg();
}
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
%>
<form name="form_" action="./post_donation.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>:::: 
          POST DONATION ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" width="2%">&nbsp;</td>
      <td width="14%" >School Year</td>
      <td width="34%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> 
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
      <td width="50%"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>Student ID &nbsp; </td>
      <td> <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp; <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" ></a> 
      </td>
      <td height="25">
<%
strTemp = WI.fillTextValue("view_all");
if(strTemp.length() > 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="checkbox" name="view_all" value="checkbox"<%=strTemp%>>
        View donation payable for this sem</td>
  </tr>

  </table>
</table>
<%
if(vStudInfo != null && vStudInfo.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="6" height="25"><hr size="1"> 
      </td>
    </tr>
    <tr> 
      <td  width="2%" height="26">&nbsp;</td>
      <td width="43%" >Student name :<strong> <%=(String)vStudInfo.elementAt(1)%> </strong></td>
      <td  colspan="4" >Current Year/Term:<strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%> 
        (<%=astrConvertTerm[Integer.parseInt((String)vStudInfo.elementAt(5))]%>)</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5" >Course / Major:<strong> <%=(String)vStudInfo.elementAt(2)%> 
        <%
	  if(vStudInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vStudInfo.elementAt(3))%> 
        <%}%>
        </strong></td>
    </tr>
  </table>
<%}//if student info is not null
boolean bolShowSave = false;
if(iAccessLevel > 1)
	bolShowSave = true;
else	
	strErrMsg = "Not authorized to save.";

//bolShowSave is false if the chage is for a specific student and student information is not found. 
if(bolShowSave && (vStudInfo == null || vStudInfo.size() ==0) )
	bolShowSave = false;

if(bolShowSave){%>
   
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="25%" height="25"> &nbsp;&nbsp;&nbsp; Payable Amount</td>
      <td width="30%"><input name="amount" type="text" size="12" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td width="45%" align="center">&nbsp;</td>
    </tr>
    <tr >
      <td height="25"> &nbsp;&nbsp;&nbsp; Date Posted </td>
      <td>
        <%
strTemp = WI.fillTextValue("date_imposed");
if(strTemp.length() ==0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_imposed" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_imposed');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
      <td align="center"><a href='javascript:PageAction("1","");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">click to save entries</font> </td>
    </tr>
  </table>
<%}else{//show error message. bolSave = false%>
<!--   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td align="center">
		<font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font>
	  </td></tr></table>-->
<%}

if(vRetResult != null && vRetResult.size() > 0) {%>

  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#999999">
    <tr> 
      <td height="25" colspan="6" bgcolor="#B9B292"><div align="center"><strong>PAYABLE 
          DONATION DETAIL</strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="29%" align="center"><strong><font size="1">STUD ID</font></strong></td>
      <td width="17%" height="25"><div align="center"><font size="1"><strong>DATE 
          POSTED</strong></font></div></td>
      <td width="17%" align="center"><font size="1"><strong>POSTED BY</strong></font></td>
      <td width="16%" align="center"><font size="1"><strong>DONATION PAYABLE</strong></font></td>
      <td width="11%" align="center"><font size="1"><strong>VIEW LEDGER</strong></font></td>
      <td width="10%" ><div align="center"><font size="1"><strong>DELETE</strong></font></div></td>
    </tr>
    <%for(int i = 0 ; i < vRetResult.size(); i += 7) {%>
    <tr bgcolor="#FFFFFF"> 
      <td><%=(String)vRetResult.elementAt(i + 2)%> (<%=(String)vRetResult.elementAt(i + 3)%>)</td>
      <td height="25" align="center"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td ><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td align="center"><a href='javascript:ViewLedger("<%=(String)vRetResult.elementAt(i + 2)%>");'><img src="../../../images/view.gif" border="0"></a></td>
      <td align="center"> 
<%if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border="0"></a><%}%></td>
    </tr>
<%}//end of for loop.
%>
  </table>
<%}//only if vRetResult is not null 
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="5" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="page_action" value="">
 <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
