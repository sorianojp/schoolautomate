<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.FAPayment,java.util.Vector" %>
<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Pre enrollment fee","payment_post_temporary_ledger.jsp");
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
int iAccessLevel = 0;

if(strSchoolCode.startsWith("FATIMA")) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
												"Fee Assessment & Payments","TEMPORARY BANK POSTING",request.getRemoteAddr(),null);
}
else {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(), null);
	if(iAccessLevel == 0) 
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","BANK UPLOAD",request.getRemoteAddr(), null);											
}
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

Vector vRetResult    = null;
String strStudIndex  = null;
String strStudName   = null;

String strSYFrom   = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");

Advising  advising   = new Advising();
FAPayment faPayment  = new FAPayment();

if(WI.fillTextValue("stud_id").length() > 0 && strSYFrom.length() > 0 && strSemester.length() > 0) {
	String strSQLQuery = "select user_index, fname, mname, lname from user_table where id_number = '"+WI.fillTextValue("stud_id")+"'";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strStudIndex  = rs.getString(1);
		strStudName   = WI.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4);			
	}
	else {
		strErrMsg = "ID does not exist.";
	}	
	rs.close();
	if(strStudIndex != null) {
		strSQLQuery = "select cur_hist_index from stud_curriculum_hist where user_index = "+strStudIndex+" and sy_from = "+strSYFrom+" and semester = "+strSemester+
					" and is_valid = 1";
		rs = dbOP.executeQuery(strSQLQuery);
		if(!rs.next()) {
			strStudIndex  = null;
			strErrMsg = "Student is not enrolled into selected sy/term.";			
		}	
		rs.close();				
	}	
}
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0 && strStudIndex != null) {
	if(faPayment.operateOnPaymentPostingToLedger(dbOP, request, Integer.parseInt(strTemp), strStudIndex) == null)
		strErrMsg = faPayment.getErrMsg();
	else	
		strErrMsg = "Operation Successful";
}
if(strStudIndex != null) {
	vRetResult = faPayment.operateOnPaymentPostingToLedger(dbOP, request, 4, strStudIndex);
}

String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
if(strErrMsg == null)
	strErrMsg = "";
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.page_action.value="";
	document.form_.submit();
}
function AddRecord()
{
	if(document.form_.stud_id.value != document.form_.prev_id.value) {
		alert("You have change to another ID but have not clicked proceed yet. Click Ok to reload Page.");
		return ;
	}
	document.form_.page_action.value="1";
}
function DeleteRecord(strInfoIndex) {
	document.form_.page_action.value='0';
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud_detail.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


</script>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus()">
<form name="form_" action="./payment_post_temporary_ledger.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>::::
          TEMPORARY POSTING OF PAYMENT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="3"><%=strErrMsg%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">SY/Term</td>
      <td>
	  <%
	  strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() ==0) 
	  	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	  %>
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> <%
	  strTemp = WI.fillTextValue("sy_to");
	  if(strTemp.length() ==0) 
	  	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	  %>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = WI.getStrValue((String)request.getSession(false).getAttribute("cur_sem"));
if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>	  
	  
	  
	  </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" height="25">        Student ID &nbsp; </td>
      <td width="30%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="4%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="10%"><font size="1"> <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
        </font></td>
      <td width="39%">
	  <%if(vRetResult != null) {%>
	  	<font size="3" style="color:red; font-weight:bold"><u>Having Temporary Bank Posting</u></font>
	  <%}%>
	  
	  </td>
    </tr>
  </table>
 <%if(strStudIndex != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
<%
if(strTemp != null && strTemp.length() > 0 && strTemp.endsWith(".0000"))
	strTemp = strTemp.substring(0, strTemp.length() - 2);

%>
    <tr>
      <td height="25" class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">Student name</td>
      <td class="thinborderTOP"><strong><%=strStudName%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payment For </td>
      <td>
<%
strTemp = dbOP.loadCombo("fa_pmt_schedule.PMT_SCH_INDEX","EXAM_NAME"," from fa_pmt_schedule order by fa_pmt_schedule.EXAM_PERIOD_ORDER asc", WI.fillTextValue("payment_for"), false);
%>	  
	  <select name="payment_for">
	  		<%=strTemp%>
		</select>	  </td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%">Amount paid </td>
      <td width="79%"><input name="amount" type="text" size="16" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        Php </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date paid</td>
      <td>
<%
strTemp = WI.fillTextValue("date_paid");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
      <input name="date_paid" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_paid');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payment Note: </td>
      <td>
	  <input type="text" name="payment_note" value="<%=WI.fillTextValue("payment_note")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="75">	  </td> 
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Bank</td>
      <td>
<%
if(strSchoolCode.startsWith("CIT"))
	strTemp = " and bank_index in (1,5)";
else	
	strTemp = "";
%>
	  <select name="bank_index">
      	<%=dbOP.loadCombo("BANK_INDEX","BANK_NAME, BRANCH", " from FA_BANK_LIST where is_valid = 1 "+strTemp+" order by bank_code", request.getParameter("bank_index"), false)%>
      </select>	  </td>
    </tr>
    <tr>
      <td height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">Reference Number </td>
      <td class="thinborderBOTTOM"><input type="text" name="ref_number" value="<%=WI.fillTextValue("ref_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="25"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(iAccessLevel > 1){%>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td colspan="3" height="25"><input type="image" src="../../../images/save.gif" onClick="AddRecord();"><font size="1">click
        to save payment detail</font></td>
      <td width="10%"  height="25">&nbsp;</td>
    </tr>
<%}
%>
</table>
		  <!-- enter here all hidden fields for student. -->
  <input type="hidden" name="stud_index" value="<%=strStudIndex%>">

<%
}//if error message is null -> outer most condition.
%>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="7" bgcolor="#cccccc" class="thinborder" align="center" style="font-weight:bold; font-size:12px;">List of Temporary Payment posted</td>
    </tr>
    <tr align="center" style="font-weight:bold">
      <td class="thinborder" height="25" width="10%">Date Paid </td>
      <td class="thinborder" width="10%">Pmt Schedule </td>
      <td class="thinborder" width="10%">Amount</td>
      <td class="thinborder" width="15%">Bank Name </td>
      <td class="thinborder" width="15%">Refernce Number </td>
      <td class="thinborder" width="20%">Payment Note </td>
      <td class="thinborder" width="10%">Delete</td>
     </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 7) {%> 
    <tr>
      <td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%>&nbsp;</td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4))%>&nbsp;</td>
      <td class="thinborder"><a href="javascript:DeleteRecord('<%=vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
<%}%>

   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	<td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="prev_id" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
