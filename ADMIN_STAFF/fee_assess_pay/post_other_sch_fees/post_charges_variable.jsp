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
	this.SubmitOnce("form_");
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == "1")
		document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce("form_");
}
function ComputeTotalPayable() {
	var unitPrice = document.form_.amount.value;
	var unit      = document.form_.no_of_units.value;
	if(unit.length == 0) 
		unit = 1;
	if(unitPrice.length == 0)
		unitPrice = 0;
	
	document.form_.total_payable.value = eval(unitPrice) * eval(unit);
}

function PrintPage(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
 if (WI.fillTextValue("print_page").compareTo("1") == 0){%>
 <jsp:forward page="./post_charges_variable_print.jsp" />
<%return;}

	float fUnitPrice = 0f;
	float fNoOfUnit = 0f;
	float fTotalCharge = 0f;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Post Charges","post_charges_variable.jsp");
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
														"Fee Assessment & Payments","Post Charges",request.getRemoteAddr(),
														"post_charges_variable.jsp");
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
Vector vSecList   = new Vector();

FAPaymentUtil paymentUtil = new FAPaymentUtil();
enrollment.FAFeePost feePost  = new enrollment.FAFeePost();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(feePost.operateOnPostingCharge(dbOP, request,Integer.parseInt(strTemp)) == null)
		strErrMsg = feePost.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
if(WI.fillTextValue("stud_id").length() > 0)//only if student id is entered.
{
	vStudInfo = paymentUtil.getStudBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null) 
		strErrMsg = paymentUtil.getErrMsg();
}
//get the sections available for a subject.
if(WI.fillTextValue("sub_index").length() > 0){
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	vSecList = reportEnrl.getSubSecList(dbOP,request.getParameter("sy_from"),
						request.getParameter("sy_to"),request.getParameter("semester"),
						request.getParameter("sub_index"), null);
}



vRetResult = feePost.operateOnPostingCharge(dbOP, request,3);
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form name="form_" action="./post_charges_variable.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>:::: 
          POST VARIABLE CHARGE PAGE ::::</strong></font></div></td>
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
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
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
      <td >&nbsp;</td>
      <td colspan="2"> <%
strTemp = WI.fillTextValue("specific_stud");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else
	strTemp = "";
%> <input type="checkbox" name="specific_stud" value="1"<%=strTemp%> onClick="ReloadPage();"> 
        <font color="#9966FF" size="3"><strong>Click to post charge to a Specific 
        Student.</strong></font></td>
    </tr>
    <tr bgcolor="#DDDDDD"> 
      <td height="18">&nbsp;</td>
      <td colspan="3" style="font-size:11px;">Date Posted Range :
        <input name="date_posted_fr" type="text" class="textbox" id="date_attendance" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_fr")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <input name="date_posted_to" type="text" class="textbox" id="date_attendance2" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_to")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
<%
if(strTemp.length() > 0){%>
    <tr bgcolor="#DDDDDD"> 
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:11px;">USE FILTER TO LIMIT VIEW. <strong>ID NUMBER</strong> OF 
        STUDENT STARTS WITH 
        <input type="text" name="id_number_starts" size="12"
			value="<%=WI.fillTextValue("id_number_starts")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp;&nbsp; <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="1"></a></td>
    </tr>
<%}%>
    <tr > 
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(WI.fillTextValue("sy_from").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9" bgcolor="#B9B292"><div align="center"><strong>FEE 
          CHARGE(S) DETAILS </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="18">&nbsp;</td>
      <td width="46%" valign="bottom">Amount</td>
      <td width="52%" valign="bottom">Total Payable</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><input name="amount" type="text" size="10" maxlength="10" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="javascript:ComputeTotalPayable();"></td>
      <td><strong> 
        <%
	  fUnitPrice = Float.parseFloat(WI.getStrValue(WI.fillTextValue("amount"),"0"));
	  fNoOfUnit = Float.parseFloat(WI.getStrValue(WI.fillTextValue("no_of_units"),"1"));
	  fTotalCharge = fUnitPrice * fNoOfUnit;
	  %>
        <input name="total_payable" type="text" class="textbox_noborder" value="<%=CommonUtil.formatFloat(fTotalCharge,true)%>"
		style="font-size:16px;">
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Fee Name : 
        <input name="note" type="text" size="64" maxlength="64" value="<%=WI.fillTextValue("note")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Unit quantity/usage/requested: 
        <input name="no_of_units" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("no_of_units")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="javascript:ComputeTotalPayable();"></td>
      <td ><font color="#0000FF">&nbsp;Date Posted <font size="1"> 
        <%
strTemp = WI.fillTextValue("date_posted");
if(strTemp.length() ==0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_posted" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_posted');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="12%" height="25" colspan="9"><hr size="1"></td>
    </tr>
  </table>
<%}//only if wi.fillTextValue("sy_from").length() > 0
if(fTotalCharge > 0f){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25">&nbsp;</td>
      <td  colspan="2"><strong><font color="#0000FF"><u>FEE CHARGE TO :</u></font></strong> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </td>
    </tr>
<%
if(WI.fillTextValue("specific_stud").length() == 0){%>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Course</td>
      <td><select name="course_index" onChange="ReloadPage()">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 order by course_name asc",
		  		request.getParameter("course_index"), false)%> </select></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Major</td>
      <td><select name="major_index" onChange="ChangeMajor()">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
<%if(strSchCode.startsWith("VMUF")){%>
    <tr > 
      <td height="25">&nbsp;</td>
      <td colspan="2" >To filter SUBJECT display enter subject code starts with 
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        and click REFRESH<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> 
      </td>
    </tr>

    <tr > 
      <td height="25">&nbsp;</td>
      <td >Subject</td>
      <td><select name="sub_index" onChange="ReloadPage();">
          <option value="">ALL</option>
<%
strTemp = WI.fillTextValue("starts_with");
if(strTemp.length() > 0)
	strTemp = " from subject where is_del=0 and sub_code like '"+WI.fillTextValue("starts_with")+
				"%' order by sub_code";
else	
	strTemp = " from SUBJECT where IS_DEL=0 order by sub_code";
%>		  
          <%=dbOP.loadCombo("SUB_INDEX","SUB_CODE",strTemp,WI.fillTextValue("sub_index") , false)%> 
		  </select> <font color="#0000FF"> 
        <%
	  if(WI.fillTextValue("sub_index").length() > 0) {%>
        <%=dbOP.mapOneToOther("SUBJECT","sub_index",WI.fillTextValue("sub_index"),
		"sub_name",null)%> 
        <%}%>
        </font> </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Section </td>
      <td><select name="section">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("section");
if(vSecList == null)
	vSecList = new Vector();
for(int i=0; i<vSecList.size();i +=2){
	if(strTemp.compareTo((String)vSecList.elementAt(i)) ==0){%>
          <option value="<%=(String)vSecList.elementAt(i)%>" selected><%=(String)vSecList.elementAt(i+1)%></option>
          <%}else{%>
          <option value="<%=(String)vSecList.elementAt(i)%>"><%=(String)vSecList.elementAt(i+1)%></option>
          <%}
}%>
        </select></td>
    </tr>
<%}//show only if it is vmuf%>

    <%}else{//only if WI.fillTextValue("specific_stud") == 1%>
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%" >Specific Student ID &nbsp; </td>
      <td width="79%"> <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 	
      </td>
    </tr>
    <%}//show stud.
%>
  </table>

<%
if(vStudInfo != null && vStudInfo.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="6" height="25"><hr size="1"> 
        <!-- enter here all hidden fields for student. -->
        <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>"> 
        <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(4)%>"> 
      </td>
    </tr>
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
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
strErrMsg = null;
boolean bolShowSave = false;
if(iAccessLevel > 1)
	bolShowSave = true;
else	
	strErrMsg = "Not authorized to save.";
if(bolShowSave) {
	if(vStudInfo != null && vStudInfo.size() > 0) {
		if( ((String)vStudInfo.elementAt(8)).compareTo(WI.fillTextValue("sy_from")) != 0 ||
			((String)vStudInfo.elementAt(9)).compareTo(WI.fillTextValue("sy_to")) != 0 ||
			((String)vStudInfo.elementAt(5)).compareTo(WI.fillTextValue("semester")) != 0) {
			//bolShowSave = false;
			//strErrMsg = "Can't post charge to previous account of student. Current enrollment information does not match with the school yr/ term entered.";
			strErrMsg = "Please check complete student ledger after posting charges.";
		}
	}
}
//bolShowSave is false if the chage is for a specific student and student information is not found. 
if(bolShowSave && WI.fillTextValue("specific_stud").length() > 0 && (vStudInfo == null || vStudInfo.size() ==0) )
	bolShowSave = false;
%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td align="center">
<%if(bolShowSave){%>
<a href='javascript:PageAction("1","");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">click to save entries<font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></font>
    <%}else{%><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font><%}%></td>
    </tr>
  </table>
<%}//only if fTotalCharge > 0f)
//and if the student's current enrollment information is same as the WI.fillTextValue("sy_from"),

if(vRetResult != null && vRetResult.size() > 0) {%>

  <table width="100%" border="0" cellpadding="0" cellspacing="1">
    <tr> 
      <td height="25" colspan="9" bgcolor="#FFFFFF"><div align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" alt="Print list of posted charges" width="58" height="26" border="0"></a><font size="1">print 
          list of posted charges</font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="9" bgcolor="#B9B292"><div align="center"><strong>LIST 
          OF FEE CHARGE(S) POSTED</strong></div></td>
    </tr>
    <% if(WI.fillTextValue("specific_stud").length() > 0){%>
    <tr> 
      <td width="15%" align="center" bgcolor="#FFFFFF"><strong><font size="1">STUD 
        ID</font></strong></td>
      <td width="7%" bgcolor="#FFFFFF"><strong><font size="1">COURSE-YR</font></strong></td>
      <td width="7%" height="25" bgcolor="#FFFFFF"><div align="center"><font size="1"><strong>DATE 
          POSTED</strong></font></div></td>
      <td width="8%" align="center" bgcolor="#FFFFFF"><font size="1"><strong>POSTED 
        BY</strong></font></td>
      <td width="40%" align="center" bgcolor="#FFFFFF"><font size="1"><strong>FEE 
        NAME</strong></font></td>
      <td width="10%" align="center" bgcolor="#FFFFFF"><font size="1"><strong>FEE 
        RATE/ CHARGE</strong></font></td>
      <td width="7%" align="center" bgcolor="#FFFFFF"><font size="1"><strong>NO 
        OF UNIT</strong></font></td>
      <td width="7%" align="center" bgcolor="#FFFFFF"><font size="1"><strong>TOTAL 
        CHARGE</strong></font></td>
      <td width="6%" bgcolor="#FFFFFF" ><div align="center"><font size="1"></font></div></td>
    </tr>
    <%for(int i = 0 ; i < vRetResult.size(); i += 14) {%>
    <tr> 
      <td bgcolor="#FFFFFF"><%=(String)vRetResult.elementAt(i + 5)%> (<%=(String)vRetResult.elementAt(i + 6)%>)</td>
      <td bgcolor="#FFFFFF"><%=(String)vRetResult.elementAt(i + 13)%></td>
      <td height="25" bgcolor="#FFFFFF"><%=(String)vRetResult.elementAt(i + 12)%></td>
      <td bgcolor="#FFFFFF" ><%=(String)vRetResult.elementAt(i + 10)%></td>
      <td bgcolor="#FFFFFF" ><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td bgcolor="#FFFFFF" ><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td align="center" bgcolor="#FFFFFF"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td align="center" bgcolor="#FFFFFF"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td align="center" bgcolor="#FFFFFF"> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%}//end of for loop.%>
  </table>
<%}else {//end of display if charging is per stud.. if(WI.fillTextValue("specific_stud").length() > 0
   %>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#999999">
    <tr bgcolor="#FFFFFF"> 
       
      <td width="5%" align="center"><strong><font size="1">TERM</font></strong></td>
     <td width="15%" align="center"><strong><font size="1">COURSE/MAJOR</font></strong></td>
      <td width="20%"><strong><font size="1">SUB CODE/ SUB NAME</font></strong></td>
      <td width="10%"><strong><font size="1">SECTION</font></strong></td>
      <td width="7%" height="25"><strong><font size="1">DATE POSTED</font></strong></td>
      <td width="10%" align="center"><strong><font size="1">POSTED BY</font></strong></td>
      <td width="25%" align="center"><strong><font size="1">FEE NAME</font></strong></td>
      <td width="7%" align="center"><font size="1"><strong>FEE RATE/ CHARGE</strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>NO OF UNIT</strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>TOTAL CHARGE</strong></font></td>
      <td width="6%" ><div align="center"><font size="1"></font></div></td>
    </tr>
    <%for(int i = 0 ; i < vRetResult.size(); i += 15) {%>
    <tr bgcolor="#FFFFFF"> 
       <td ><%=WI.getStrValue((String)vRetResult.elementAt(i + 14),"ALL")%></td>
     <td><%=WI.getStrValue(vRetResult.elementAt(i + 5),"ALL")%>/ <%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"ALL")%></td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"ALL")%>/ <%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"ALL")%></td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i + 9),"ALL")%></td>
      <td height="25"><%=(String)vRetResult.elementAt(i + 11)%></td>
      <td ><%=(String)vRetResult.elementAt(i + 12)%></td>
      <td ><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td ><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td align="center"> <%if(iAccessLevel ==2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border="0"></a> <%}%></td>
    </tr>
    <%}//end of for loop.%>
  </table>
<%}//end of else.



}//only if vRetResult is not null 
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="5" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="page_action" value="">
 <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
 <input type="hidden" name="post_variable" value="1">
 <input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
