<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if ( WI.fillTextValue("print_page").equals("1")){%>
	<jsp:forward page="./post_charges_print.jsp" />
<%	return;} %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
table.thinborder{
	border-top : solid  1px #BB0004;
	border-right : solid 1px #BB0004;
	font-size: 11px;
}

TD.thinborder {
    border-left: solid 1px #BB0004;
    border-bottom: solid 1px #BB0004;
	font-size: 11px;
} 
TD.thinborderBOTTOM {
    border-bottom: solid 1px #BB0004;
	font-size: 11px;
} 
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.print_page.value = "";
	document.form_.page_action.value = "";	
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.print_page.value = "";
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == "1"){
		document.form_.hide_save.src = "../../../images/blank.gif";
		
		if (document.form_.fee_type_exist.value == "1" 
			&& !document.form_.allow_duplicate.checked){
			
			var confirmAddDuplicate = confirm("Fee Type already exist. Allow duplicate Entry");
			
			if (confirmAddDuplicate){
				document.form_.allow_duplicate.checked = true;
			}else{
				document.form_.hide_save.src = "../../../images/save.gif";
				return;
			}
		}
	}
	document.form_.submit();
}
function OpenSearch() {
	document.form_.print_page.value = "";
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function HideSaveButton(){
	if (document.form_.hide_save != null) 
		document.form_.hide_save.src = "../../../images/blank.gif";
}

function PrintPage(){
	document.form_.print_page.value="1";
	document.form_.page_action.value = "";
	document.form_.submit();
}

function viewDuplicate(){
	document.form_.print_page.value = "";
	document.form_.page_action.value = "";	
	var pgLoc = "./post_charges_pop.jsp?sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value;
	var win=window.open(pgLoc,"PrintWindow",'dependent=yes,width=600,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;

	float fUnitPrice = 0f;
	float fNoOfUnit = 0f;
	float fTotalCharge = 0f;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Post Charges","post_charges.jsp");
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
														"post_charges.jsp");
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

Vector vStudInfo  = null;
Vector vRetResult = null;
Vector vSecList   = new Vector();

FAPaymentUtil paymentUtil = new FAPaymentUtil();
enrollment.FAFeePost feePost  = new enrollment.FAFeePost();
String strFeeTypeExist = "0";

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

if(WI.fillTextValue("id_number_starts").length()>0 || WI.fillTextValue("view_all_rec").length() > 0) {
	vRetResult = feePost.operateOnPostingCharge(dbOP,request,3);
	if (vRetResult == null){
		strErrMsg = feePost.getErrMsg();
	}//System.out.println(vRetResult);
}
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<form name="form_" action="./post_charges.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>:::: 
          POST OTHER SCHOOL FEES PAGE ::::</strong></font></div></td>
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
	  readonly="yes"> <select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(WI.fillTextValue("page_value").length() ==0)
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
      <td width="50%">&nbsp;&nbsp;&nbsp;&nbsp;
      <input name="123" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.print_page.value = '';document.form_.page_action.value = ''" value="Refresh >>"></td>
    </tr>
<input type="hidden" name="specific_stud" value="1">
<!--
    <tr > 
      <td height="25">&nbsp;</td>
      <td colspan="3"> 
        <font color="#9966FF" size="3"><strong>Post charge to a Specific Student.</strong></font></td>
    </tr>
    <tr bgcolor="#DDDDDD">
      <td height="25">&nbsp;</td>
      <td colspan="3" >Date Posted Range :
        <input name="date_posted_fr" type="text" class="textbox" id="date_attendance" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_fr")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <input name="date_posted_to" type="text" class="textbox" id="date_attendance2" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_to")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
-->
    <% if(strTemp.length() > 0 && false){%>
    <tr bgcolor="#DDDDDD">
      <td height="20">&nbsp;</td>
      <td colspan="3" style="font-size:10px;">USE FILTER TO LIMIT VIEW. <strong>ID NUMBER</strong> OF 
        STUDENT STARTS WITH 
<%
	strTemp = WI.fillTextValue("id_number_starts");	
    if(strTemp.length() > 0) {
    
      if (WI.fillTextValue("stud_id").length() > 0){
        if (WI.fillTextValue("stud_id").length() >= strTemp.length() && 
            strTemp.length() > 0 && !WI.fillTextValue("stud_id").startsWith(strTemp)){         
          strTemp = WI.fillTextValue("stud_id").substring(0,strTemp.length()-1);
        }
      }
    }	
%>        
        <input type="text" name="id_number_starts" size="12"
			value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp;&nbsp;
        <input name="1234" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.print_page.value = '';document.form_.page_action.value = ''" value="Refresh >>">
      </td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#DDDDDD"> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2"><strong><font color="#FF0000">SORTING CONDITIONS</font></strong> 
        : 
	<% if (WI.fillTextValue("view_all_rec").length() > 0) strTemp = "checked";
	else strTemp = "";%>
        <input type="checkbox" name="view_all_rec" value="1" <%=strTemp%>>
      check to view all</td>
    </tr>
    <tr bgcolor="#DDDDDD"> 
      <td height="25">&nbsp;</td>
      <td width="36%"><select name="sort_by1">
        <option value="0">Sort by</option>
        <%if (WI.fillTextValue("sort_by1").equals("1")){%>
        <option value="1" selected>Date Posted</option>
        <%}else{%>
        <option value="1">Date Posted</option>
        <%}if (WI.fillTextValue("sort_by1").equals("2")){%>
        <option value="2" selected>Fee Name</option>
        <%}else{%>
        <option value="2">Fee Name</option>
        <%}if (WI.fillTextValue("sort_by1").equals("3")){%>
        <option value="3" selected>ID Number</option>
        <%}else{%>
        <option value="3">ID Number</option>
		<%}if (WI.fillTextValue("sort_by1").equals("4")){%>
        <option value="4" selected>Lastname</option>
        <%}else{%>
        <option value="4">Lastname</option>
		<%}if (WI.fillTextValue("sort_by1").equals("5")){%>
        <option value="5" selected>Course</option>
        <%}else{%>
        <option value="5">Course</option>
		<%}if (WI.fillTextValue("sort_by1").equals("6")){%>
        <option value="6" selected>Year Level</option>
        <%}else{%>
        <option value="6">Year Level</option>
        <%}%>
      </select>
      <select name="sort_by1_cond">
		  <option value=" asc">Ascending</option>
		  <% if (WI.fillTextValue("sort_by1_cond").startsWith("d")){%>
		  <option value="desc" selected>Descending</option>
		  <%}else{%>
		  <option value="desc">Descending</option>
		  <%}%>
      </select></td>
      <td width="62%"><select name="sort_by2">
          <option value="0">Sort by</option>
		  <%if (WI.fillTextValue("sort_by2").compareTo("1") == 0){%>
		  <option value="1" selected>Date Posted</option>
		  <%}else{%>
		  <option value="1">Date Posted</option>
		  <%}if (WI.fillTextValue("sort_by2").compareTo("2") == 0){%>
		  <option value="2" selected>Fee Name</option>
		  <%}else{%>
		  <option value="2">Fee Name</option>
		  <%}if (WI.fillTextValue("sort_by2").compareTo("3") == 0){%>
		  <option value="3" selected>ID Number</option>
		  <%}else{%>
		  <option value="3">ID Number</option>
		<%}if (WI.fillTextValue("sort_by1").equals("4")){%>
        <option value="4" selected>Lastname</option>
        <%}else{%>
        <option value="4">Lastname</option>
		<%}if (WI.fillTextValue("sort_by1").equals("5")){%>
        <option value="5" selected>Course</option>
        <%}else{%>
        <option value="5">Course</option>
		<%}if (WI.fillTextValue("sort_by1").equals("6")){%>
        <option value="6" selected>Year Level</option>
        <%}else{%>
        <option value="6">Year Level</option>
	  <%}%>
		 </select> 
		  <select name="sort_by2_cond">
		  <option value=" asc">Ascending</option>
		  <% if (WI.fillTextValue("sort_by2_cond").startsWith("d")){%>
		  <option value="desc" selected>Descending</option>
		  <%}else{%>
		  <option value="desc">Descending</option>
		  <%}%>
	  </select></td>
    </tr>
  </table>
    <%}%>
<!--
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="18"><hr size="1"></td>
    </tr>
  </table>
-->
<% if(WI.fillTextValue("sy_from").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="58%" class="thinborderBOTTOM"><div align="center"><strong>FEE CHARGE(S) DETAILS </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="18">&nbsp;</td>
      <td width="46%" valign="bottom">Fee type</td>
      <td width="52%" valign="bottom">Fee rate</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><select name="fee_type" onChange="document.form_.fee_changed.value='1';ReloadPage();">
	  <option value="0">Select a fee type</option>
          <%
 	strTemp = " from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and year_level=0 and "+
		"sy_index=(select sy_index from FA_SCHYR where sy_from="+request.getParameter("sy_from")+" and sy_to="+
		request.getParameter("sy_to")+") and amount > 0.1 order by FEE_NAME asc";
 %>
          <%=dbOP.loadCombo("OTHSCH_FEE_INDEX","FEE_NAME",strTemp, request.getParameter("fee_type"), false)%> 
        </select></td>
      <td><strong> 
        <%
strTemp = request.getParameter("fee_type");
if(strTemp == null || strTemp.trim().length() ==0 || strTemp.compareTo("0") ==0)
	strTemp = "0.00";
else { 
	strTemp = WI.fillTextValue("amount");
	if(WI.fillTextValue("fee_changed").length() > 0 && WI.fillTextValue("fee_type").length() > 0)
		strTemp = dbOP.mapOneToOther("FA_OTH_SCH_FEE","OTHSCH_FEE_INDEX",WI.fillTextValue("fee_type"),"AMOUNT",null);
}
%>
<input type="text" name="amount" value="<%=WI.getStrValue(strTemp)%>">
        <!--<%=strTemp%>--> 
        </strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Unit quantity/usage/requested: 
        <input name="no_of_units" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("no_of_units")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td ><font color="#0000FF"><strong>Amount payable : 
        <%
	  fUnitPrice = Float.parseFloat(strTemp);
	  fNoOfUnit = Float.parseFloat(WI.getStrValue(WI.fillTextValue("no_of_units"),"1"));
	  fTotalCharge = fUnitPrice * fNoOfUnit;
	  %>
        <%=CommonUtil.formatFloat(fTotalCharge,true)%></strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Date Posted <font size="1">
<%
strTemp = WI.fillTextValue("date_posted");
if(strTemp.length() ==0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_posted" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_posted');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font></td>
      <td >
        <input name="12345" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.print_page.value = '';document.form_.page_action.value = ''" value="Refresh >>">
      
	  <font size="1">Click to update amount payable</font></td>
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
      <td  colspan="3"><strong><font color="#0000FF"><u>FEE CHARGE TO :</u></font></strong></td>
    </tr>
    <%
strTemp = WI.fillTextValue("specific_stud");
if(strTemp.length() == 0){%>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Course</td>
      <td colspan="2"><select name="course_index" onChange="ReloadPage()">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 order by course_name asc",
		  		request.getParameter("course_index"), false)%> </select></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Major</td>
      <td colspan="2"><select name="major_index" onChange="ChangeMajor()">
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
      <td colspan="3" >To filter SUBJECT display enter subject code starts with 
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        and click REFRESH<a href="javascript:ReloadPage();">
        <input name="123456" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.print_page.value = '';document.form_.page_action.value = ''" value="Refresh >>">
        </a>      </td>
    </tr>

    <tr > 
      <td height="25">&nbsp;</td>
      <td >Subject</td>
      <td colspan="2"><select name="sub_index" onChange="ReloadPage();">
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
      <td colspan="2"><select name="section">
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
      <td width="17%"> <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" 
      class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
      onChange = "javascript:HideSaveButton()"></td>
      <td width="62%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}//show stud.
%>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><hr size="1"> 
        <!-- enter here all hidden fields for student. -->
        <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>"> 
        <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(4)%>">      
      </td>
    </tr>
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="48%" >Student name :<strong> <%=(String)vStudInfo.elementAt(1)%> </strong></td>
      <td width="50%" >Current Year/Term:<strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%> 
      (<%=astrConvertTerm[Integer.parseInt((String)vStudInfo.elementAt(5))]%>)</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" >Course / Major:<strong> <%=(String)vStudInfo.elementAt(2)%> 
        <%
	  if(vStudInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vStudInfo.elementAt(3))%> 
        <%}%>
        </strong></td>
    </tr>
    <%  Vector vPostList =feePost.feeTypeExist(dbOP,(String)vStudInfo.elementAt(0), 
							WI.fillTextValue("sy_from"),WI.fillTextValue("semester"), 
							WI.fillTextValue("fee_type"));	
		if (vPostList != null && vPostList.size() > 0) {
			strFeeTypeExist = "1";
	%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td ><div align="center"><strong> 
          <input type="checkbox" name="allow_duplicate" value="1">
          <font color="#FF0000">Fee already exist for student. <br>
          Allow duplicate entry.</font></strong></div></td>
      <td> <table width="60%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
          <tr bgcolor="#FFDFE0"> 
            <td width="50%" height="20" class="thinborder"><div align="center">DATE 
                POSTED</div></td>
            <td width="50%" class="thinborder"> <div align="center">AMOUNT</div></td>
          </tr>
          <%for (int i = 0; i< vPostList.size() ; i+=2) {%>
          <tr> 
            <td height="20" class="thinborder"><div align="right">&nbsp; <%=(String)vPostList.elementAt(i)%>&nbsp;</div></td>
            <td class="thinborder"><div align="right">&nbsp;<%=(String)vPostList.elementAt(i+1)%>&nbsp;</div></td>
          </tr>
          <%}%>
        </table></td>
    </tr>
    <%}%>
  </table>
<%}//if student info is not null
boolean bolShowSave = false;
if(iAccessLevel > 1)
	bolShowSave = true;
else	
	strErrMsg = "Not authorized to save.";
if(bolShowSave) {
	if(vStudInfo != null && vStudInfo.size() > 0) {
		if (dbOP.mapOneToOther("stud_curriculum_Hist","sy_from",WI.fillTextValue("sy_from"),
		"cur_hist_Index", " and semester =  " +  WI.fillTextValue("semester")  +
		" and user_index =  " + (String)vStudInfo.elementAt(0) + " and is_valid = 1") == null){

		bolShowSave = false;
		strErrMsg = " <br>Student is not enrolled. Please use PAYMENT -> OTHER SCHOOL FEES<br><br>";
		
	}else if( ((String)vStudInfo.elementAt(8)).compareTo(WI.fillTextValue("sy_from")) != 0 ||
			((String)vStudInfo.elementAt(9)).compareTo(WI.fillTextValue("sy_to")) != 0 ||
			((String)vStudInfo.elementAt(5)).compareTo(WI.fillTextValue("semester")) != 0) {
				if(WI.fillTextValue("over_ride_syste").length() == 0) {
					bolShowSave = false;
					strTemp = "";
				}else 
					strTemp = " checked";
					
			strErrMsg = "Can't post charge to previous account of student. Current enrollment information does not match with the school yr/ term entered. <br>" +
			
			
			"<input type=checkbox name=over_ride_syste value=1 onClick=ReloadPage();> "+
			"Click on check box to override system setting and allow posting.";
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
<input name="submit5" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.print_page.value = '';document.form_.page_action.value = '1'" value="Save Entries >>">
</a> 
        <font size="1">click to save entries</font>
    <%}else{%><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font><%}%></td>
    </tr>
  </table>
<%}//only if fTotalCharge > 0f)
//and if the student's current enrollment information is same as the WI.fillTextValue("sy_from"),
if(vRetResult != null && vRetResult.size() > 0 ) {%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="46%" height="25" bgcolor="#FFFFFF">&nbsp;&nbsp;<a href="javascript:viewDuplicate()"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>view 
        duplicate entries</td>
      <td width="54%" bgcolor="#FFFFFF"><div align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click 
          to print charges</div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong>LIST 
          OF FEE CHARGE(S) POSTED</strong></div></td>
    </tr>
  </table>
    <%
if(WI.fillTextValue("specific_stud").length() > 0 && vRetResult.size() >0){
	if (true || WI.fillTextValue("id_number_starts").length()>0 || WI.fillTextValue("view_all_rec").length() > 0) {
%>
   <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#999999">
   <tr bgcolor="#FFFFFF">
      <td width="17%" align="center"><strong><font size="1">STUDENT</font></strong></td>
      <td width="10%" align="center"><strong><font size="1">COURSE/MAJOR - YEAR LEVEL </font></strong></td>
      <td width="9%" height="25"><div align="center"><font size="1"><strong>DATE 
          POSTED</strong></font></div></td>
      <td width="7%" align="center"><font size="1"><strong>POSTED BY</strong></font></td>
      <td width="24%" align="center"><font size="1"><strong>FEE NAME</strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>FEE RATE/ CHARGE</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>NO OF UNIT</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>TOTAL CHARGE</strong></font></td>
<!--
      <td width="13%" >&nbsp;</td>
-->
   </tr>
<%
//	System.out.println("vRetResult : " + vRetResult);
	for(int i = 0 ; i < vRetResult.size(); i += 14) {%>
    <tr bgcolor="#FFFFFF">
      <td><%=(String)vRetResult.elementAt(i + 5)%> (<%=(String)vRetResult.elementAt(i + 6)%>)</td>
      <td><%=vRetResult.elementAt(i + 13)%></td>
      <td height="25"><%=(String)vRetResult.elementAt(i + 12)%></td>
      <td >&nbsp;
	  <%=WI.getStrValue(vRetResult.elementAt(i + 10),"<font color=blue>Auto Posted</font>")%></td>
      <td ><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td ><div align="right"><%=(String)vRetResult.elementAt(i + 2)%>&nbsp;</div>      </td>
      <td align="center"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td align="center"><div align="right"><%=(String)vRetResult.elementAt(i + 4)%>&nbsp;</div></td>
<!--
      <td align="center"> 
	  <%if(iAccessLevel ==2){%>
	  	<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'>	<img src="../../../images/delete.gif" border="0"></a>
	  <%}%></td>
-->
    </tr>
    <%}//end of for loop.%>
  </table>
	<%}
	}else {//end of display if charging is per stud.. if(WI.fillTextValue("specific_stud").length() > 0
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
<!--
      <td width="6%" >&nbsp;</td>
-->
    </tr>
    <%for(int i = 0 ; i < vRetResult.size(); i += 15) {%>
    <tr bgcolor="#FFFFFF"> 
       <td ><%=WI.getStrValue((String)vRetResult.elementAt(i + 14),"ALL")%></td>
     <td><%=WI.getStrValue(vRetResult.elementAt(i + 5),"ALL")%>/ <%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"ALL")%></td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"ALL")%>/ <%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"ALL")%></td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i + 9),"ALL")%></td>
      <td height="25"><%=(String)vRetResult.elementAt(i + 11)%></td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i + 12),"<font color=blue>Auto Posted</font>")%></td>
      <td ><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td ><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i + 4)%></td>
<!--
      <td align="center"> <%if(iAccessLevel ==2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border="0"></a> <%}%></td>
-->
    </tr>
  <% }//end of for loop.%>
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
 <input type="hidden" name="page_value" value="1">
 <input type="hidden" name="print_page">
 <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
 <input type="hidden" name="fee_type_exist" value="<%=strFeeTypeExist%>">
 <input type="hidden" name="fee_changed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
