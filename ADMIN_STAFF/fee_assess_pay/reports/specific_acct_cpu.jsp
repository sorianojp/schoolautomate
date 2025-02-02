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
<script language="JavaScript">
//remove all fee from list.


function RemoveFeeName(removeIndex)
{
	document.specific_fee.remove_index.value = removeIndex;
	ReloadPage();
}
function ReloadPage()
{
	document.specific_fee.print_pg.value = "";
	document.specific_fee.show_all.value ="1";
	document.specific_fee.submit();
}

function PrintPg() {
	document.specific_fee.print_pg.value = "1";
	document.specific_fee.submit();
}

function SwitchPage(){
	location = "./specific_acct_cpu_details.jsp?date_from=" +
				document.specific_fee.date_from.value;
}

function UpdateCollegeName(){

	if (document.specific_fee.c_index.selectedIndex != 0) 
		document.specific_fee.c_name.value = 
				document.specific_fee.c_index[document.specific_fee.c_index.selectedIndex].text;
	else
		document.specific_fee.c_name.value= "";
	document.specific_fee.show_all.value = "1";
	document.specific_fee.submit();
}

function SaveJV(){
	document.specific_fee.save_jv.value = "1";
	document.specific_fee.show_all.value = "1";	
	document.specific_fee.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

if(WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./specific_acct_cpu_print.jsp" />
<%return;
}	
	String strErrMsg = null;
	String strTemp = null;

	int iListCount = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","specific_acct.jsp");
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
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"specific_acct.jsp");
**/
//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
Vector vRetResult= null;
Vector vRetResultDtl = null;
Vector vStudList = null;
Vector vARStudents = null;
double dTotalAmount = 0d;
double dTotalRowAmount = 0d;
enrollment.FAFeeAdjustmentCPU fAdjust = new enrollment.FAFeeAdjustmentCPU();
String[] astrSemester = {"Summer", "1st Semester","2nd Semester", "3rd Semester",""};
String strJVNumber = null;

if (WI.fillTextValue("save_jv").equals("1")){
	strJVNumber = fAdjust.createEnrollmentJV(dbOP, request);
	
	if (strJVNumber == null){
		strErrMsg = fAdjust.getErrMsg();
	}
}


if (WI.fillTextValue("show_all").equals("1") &&
		WI.fillTextValue("c_index").length() > 0){

		if ( strJVNumber== null){
			// check if JV Number already exists
			strJVNumber = fAdjust.getJVNumber(dbOP, request);
			if (strJVNumber== null){
				strErrMsg = fAdjust.getErrMsg();
			}
		}


		vRetResult = fAdjust.viewAllAccountWithTransOnDate(dbOP,request);
		if (vRetResult == null)
			strErrMsg= fAdjust.getErrMsg();
			
		vARStudents = fAdjust.calcARStudents(dbOP,request);
		if (vARStudents == null)
			strErrMsg= fAdjust.getErrMsg();
			
		vRetResultDtl = fAdjust.viewAccountWithTransOnDateDetail(dbOP,request);
		if (vRetResultDtl == null)
			strErrMsg = fAdjust.getErrMsg();
			
		if (vRetResultDtl != null){	
			for (int j = 0; j < vRetResultDtl.size();){
				dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(j+2),",",""),"0"));
				j += 3; 
				if ( vRetResultDtl.elementAt(j) != null) {
					break;
				}	
			}	
			vStudList = fAdjust.viewEnrolledStudentsOnDateDetail(dbOP,request);
			if (vStudList != null) 
				strErrMsg = fAdjust.getErrMsg();
		}
}

String[] astrConvSem ={"Summer", "1st Semester", "2nd Semester", "3rd Semester", ""};


double dCreditAmount = 0d;
double dDebitAmount = 0d;
int iGroupNo = 1;
int iCtr = 0;
int iLineCtr = 0;
%>
<form name="specific_fee" action="./specific_acct_cpu.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::DAILY JOURNAL VOUCHER::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>", "</strong></font>","")%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0"  cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="11%">COLLEGE</td>
      <td colspan="2">
        <select name="c_index" onChange="UpdateCollegeName()">
		<option value=""> ALL </option>
		<%=dbOP.loadCombo("c_index", "c_name", " from college where is_del = 0",
							WI.fillTextValue("c_index"),false)%>
        </select>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY / TERM </td>
      <td colspan="2"><%
	strTemp = WI.fillTextValue("sy_from");
	if (strTemp.length() == 0 && WI.fillTextValue("first_load").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}
%>
        <input name="sy_from" type="text" size="4" maxlength="4" 
	  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="DisplaySYTo('specific_fee','sy_from','sy_to')">
-
<%
	strTemp = WI.fillTextValue("sy_to");
	if (strTemp.length() == 0 && WI.fillTextValue("first_load").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}
%>
<input name="sy_to" type="text" class="textbox" value="<%=strTemp%>" 
			size="4" maxlength="4" readonly="true">
<%
	strTemp = WI.fillTextValue("semester");
	if (strTemp.length() == 0 && WI.fillTextValue("first_load").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	}
%>
<select name="semester">
  <option value="1"> 1st </option>
  <% if (strTemp.equals("2")){%>
  <option value="2" selected> 2nd </option>
  <%}else{%>
  <option value="2"> 2nd </option>
  <%} if (strTemp.equals("0")){%>
  <option value="0" selected> Summer</option>
  <%}else{%>
  <option value="0"> Summer</option>
  <%}%>
</select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date</td>
      <td width="19%"><% strTemp = WI.fillTextValue("date_from") ;
	 	if (strTemp.length() ==  0) 
			strTemp = WI.getTodaysDate(1);
	 %>
        <input name="date_from" type="text" size="12" maxlength="12" 
	  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('specific_fee.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;</td>
      <td width="67%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="3%" height="18">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
<% 	if (vRetResult != null && vRetResult.size() > 0) {%> 
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp; </td>
      <td align="right">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> <font size="1">click to print </font></td>
    </tr>
<%}%> 
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3"><strong><font color="#0000FF">&nbsp;&nbsp;JOURNAL VOUCHER NO :  <%=WI.getStrValue(strJVNumber,"&lt; To Generated After Saving &gt;")%>
	  
	  </font> </strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3" align="center" bgcolor="#B9B292"><font color="#FFFFFF"><strong>ENROLMENT JOURNAL VOUCHER <br>
		   (<%=WI.fillTextValue("date_from")%>)
      </strong></font></td>
    </tr>
    <tr>
      <td width="58%"><strong>DEBIT</strong></td>
      <td width="23%" height="25"><div align="center"></div></td>
      <td width="19%" align="center"><strong>Amount</strong></td>
    </tr>
<% 
	if (vARStudents != null && vARStudents.size() > 0) {
		dDebitAmount = Double.parseDouble(ConversionTable.replaceString((String)vARStudents.elementAt(2),",",""));
%> 
    <tr>
      <td>&nbsp;&nbsp;<%=iGroupNo%>. <%=(String)vARStudents.elementAt(0)%>
				<input type="hidden" name="particular<%=iLineCtr%>" value="<%=(String)vARStudents.elementAt(0)%>">	  
      </td>
      <td height="20"><div align="center"><%=(String)vARStudents.elementAt(1)%>
				<input type="hidden" name="coa_index<%=iLineCtr%>" value="<%=(String)vARStudents.elementAt(3)%>">
				<input type="hidden" name="is_credit<%=iLineCtr%>" value="1">
				<input type="hidden" name="group_no<%=iLineCtr%>" value="<%=iGroupNo++%>">
				</div></td>
      <td align="right"><%=(String)vARStudents.elementAt(2)%>&nbsp;&nbsp;
		<input type="hidden" name="amount<%=iLineCtr++%>" 
			value="<%=ConversionTable.replaceString((String)vARStudents.elementAt(2),",","")%>">	  
	  
	  </td>
    </tr>
<%}if (vARStudents != null && vARStudents.elementAt(16) != null){
 	dDebitAmount += Double.parseDouble(ConversionTable.replaceString((String)vARStudents.elementAt(18),",",""));
%>
    <tr>
      <td>&nbsp;&nbsp;<%=iGroupNo%>. <%=(String)vARStudents.elementAt(16)%> 
				<input type="hidden" name="particular<%=iLineCtr%>" value="<%=(String)vARStudents.elementAt(16)%>">	  	  
	  </td>
      <td height="20"><div align="center"><%=(String)vARStudents.elementAt(17)%></div>
				<input type="hidden" name="coa_index<%=iLineCtr%>" value="<%=(String)vARStudents.elementAt(19)%>">
				<input type="hidden" name="is_credit<%=iLineCtr%>" value="1">
				<input type="hidden" name="group_no<%=iLineCtr%>" value="<%=iGroupNo++%>">
	  </td>
      <td align="right"><%=(String)vARStudents.elementAt(18)%>&nbsp;&nbsp;
		<input type="hidden" name="amount<%=iLineCtr++%>" 
			value="<%=ConversionTable.replaceString((String)vARStudents.elementAt(18),",","")%>">	  
	  
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
    <tr>
      <td><strong>CREDIT </strong></td>
      <td height="25">&nbsp;</td>
      <td align="center">&nbsp;</td>
    </tr>
<% if (vARStudents != null && vARStudents.size() > 0){
 	dCreditAmount += Double.parseDouble(ConversionTable.replaceString((String)vARStudents.elementAt(6),",",""));		
	iGroupNo = 1;

%> 
    <tr>
      <td height="18">&nbsp;&nbsp;1. <%=(String)vARStudents.elementAt(4)%>	  
			<input type="hidden" name="particular<%=iLineCtr%>" value="<%=(String)vARStudents.elementAt(4)%>">	 	  
	  </td>
      <td height="18" align="center"><%=(String)vARStudents.elementAt(5)%>
				<input type="hidden" name="coa_index<%=iLineCtr%>" value="<%=(String)vARStudents.elementAt(7)%>">
				<input type="hidden" name="is_credit<%=iLineCtr%>" value="0">
				<input type="hidden" name="group_no<%=iLineCtr%>" value="<%=iGroupNo%>">			
   	  </td>
      <td align="right"><%=(String)vARStudents.elementAt(6)%>&nbsp;&nbsp;
		<input type="hidden" name="amount<%=iLineCtr++%>" 
			value="<%=ConversionTable.replaceString((String)vARStudents.elementAt(6),",","")%>">		  
      </td>
    </tr>
<% if (vARStudents != null && vARStudents.size() > 0 && vARStudents.elementAt(8) != null) {
 	dCreditAmount += Double.parseDouble(ConversionTable.replaceString((String)vARStudents.elementAt(10),",",""));		
%> 
    <tr>
      <td height="18">&nbsp; <%=(String)vARStudents.elementAt(8)%>
			<input type="hidden" name="particular<%=iLineCtr%>" value="<%=(String)vARStudents.elementAt(8)%>">	 	  	  
	  </td>
      <td height="18" align="center"><%=(String)vARStudents.elementAt(9)%>
			<input type="hidden" name="coa_index<%=iLineCtr%>" value="<%=(String)vARStudents.elementAt(11)%>">
			<input type="hidden" name="is_credit<%=iLineCtr%>" value="0">
			<input type="hidden" name="group_no<%=iLineCtr%>" value="<%=iGroupNo%>">			
	  </td>
      <td align="right"><%=(String)vARStudents.elementAt(10)%>&nbsp;&nbsp;
		<input type="hidden" name="amount<%=iLineCtr++%>" 
			value="<%=ConversionTable.replaceString((String)vARStudents.elementAt(10),",","")%>">		  
	  </td>
    </tr>	
<%}
}%>
		
<%String strHandsOn = "0";

for (int i =0 ; i < vRetResult.size(); i+=5) {
 	dCreditAmount += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""));		
	dTotalAmount += 
		 Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""));
%> 
    <tr>
      <td height="18">&nbsp;
	  				<%=(String)vRetResult.elementAt(i)%>
			<input type="hidden" name="particular<%=iLineCtr%>" value="<%=(String)vRetResult.elementAt(i)%>">	 	  	  
	  </td>
      <td height="18" align="center"><%=(String)vRetResult.elementAt(i+1)%>      
			<input type="hidden" name="coa_index<%=iLineCtr%>" value="<%=(String)vRetResult.elementAt(i+4)%>">
			<input type="hidden" name="is_credit<%=iLineCtr%>" value="0">
			<input type="hidden" name="group_no<%=iLineCtr%>" value="<%=iGroupNo%>">			
	  </td>
      <td align="right"><%=(String)vRetResult.elementAt(i+2)%>&nbsp;&nbsp;
		<input type="hidden" name="amount<%=iLineCtr++%>" 
			value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",","")%>">		  
      </td>
    </tr>
<%}
	if (vARStudents != null && vARStudents.elementAt(12) != null){
 	dCreditAmount += Double.parseDouble(ConversionTable.replaceString((String)vARStudents.elementAt(14),",",""));		
	iGroupNo++;
%> 

    <tr>
      <td height="18">&nbsp;&nbsp;2.&nbsp;<%=(String)vARStudents.elementAt(12)%>
			<input type="hidden" name="particular<%=iLineCtr%>" value="<%=(String)vARStudents.elementAt(12)%>">	  
	  </td>
      <td height="18" align="center"><%=(String)vARStudents.elementAt(13)%>
			<input type="hidden" name="coa_index<%=iLineCtr%>" value="<%=(String)vARStudents.elementAt(15)%>">
			<input type="hidden" name="is_credit<%=iLineCtr%>" value="0">
			<input type="hidden" name="group_no<%=iLineCtr%>" value="<%=iGroupNo%>">		  
	  </td>
      <td align="right"><%=(String)vARStudents.elementAt(14)%>&nbsp;&nbsp;     
		<input type="hidden" name="amount<%=iLineCtr++%>" 
			value="<%=ConversionTable.replaceString((String)vARStudents.elementAt(14),",","")%>">		  
	  </td>
    </tr>
<%}
	iGroupNo = 1;

%> 	
    <tr>
      <td height="18" colspan="3"><hr size="1" width="100%"></td>
    </tr>
    <tr>
      <td height="18" colspan="3">EXPLANATION</td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="top">&nbsp;
	  <%=iGroupNo%>.<textarea name="explanation<%=iGroupNo++%>" cols="88" rows="2" class="textbox">To record Tuition and Fees Charges to <%=CommonUtil.formatFloat(dTotalRowAmount,false)%> <%=WI.fillTextValue("c_name")%> enrollee(s) for <%=astrSemester[Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"4"))] +  " " + WI.fillTextValue("sy_from") + " -  " + WI.fillTextValue("sy_to") %> enrolled on <%=WI.formatDate(WI.fillTextValue("date_from"),6)%></textarea>	  </td>
    </tr>
<%if (vARStudents != null && vARStudents.elementAt(12) != null){%> 
    <tr>
      <td height="18" colspan="3" valign="top">&nbsp;
	 <%=iGroupNo%>.<textarea name="explanation<%=iGroupNo++%>" cols="88" rows="2" class="textbox"> To record Tuition cash discounts granted to <%=WI.fillTextValue("c_name")%> enrollee(s)</textarea>      </td>
    </tr>
<%}%>
    <tr>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>

<!--
    <tr>
      <td height="25" colspan="2" align="right"><strong>TOTAL</strong></td>
	  <td align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%>&nbsp;&nbsp;</strong></td>
    </tr>
-->
  </table>
<%} 

/**
	System.out.println("vARStudents :" + vARStudents);
	System.out.println("vRetResultDtl : " + vRetResultDtl);
	System.out.println(" WI.getStrValue(strJVNumber).length() : " +  WI.getStrValue(strJVNumber).length());
	System.out.println("vRetResult : " + vRetResult);
	System.out.println("dCreditAmount : " + dCreditAmount);
	System.out.println("dDebitAmount : " + dDebitAmount);
**/	

 if (vARStudents != null && vARStudents.size() > 0 && vRetResultDtl != null 
	&& vRetResultDtl.size() > 0 && WI.getStrValue(strJVNumber).length() == 0 
	&& vRetResult != null && vRetResult.size() > 0
	&& CommonUtil.formatFloat(dCreditAmount,true).equals(CommonUtil.formatFloat(dDebitAmount,true))) {%> 

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
	  <td> <div align="center"><a href='javascript:SaveJV()'><img src="../../../images/save.gif" border="0"></a><font size="1">click to save journal voucher</font> </div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  </table>
<%}
	if (!CommonUtil.formatFloat(dCreditAmount,true).equals(CommonUtil.formatFloat(dDebitAmount,true))){
%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
	  <td> <div align="center"><strong><font color="#FF0000">The Debit Amount is NOT EQUAL with the Credit Amount. <br>
  &nbsp;&nbsp;Please check mapping of accounts and the support documents below for the missing entries</font></strong></div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
  </table>
<% }

 if (vRetResultDtl != null && vRetResultDtl.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <%strTemp = WI.fillTextValue("date_from");
  	if (strTemp.length() > 0) {
		strTemp = " on " +  WI.formatDate(strTemp,6);
	}
	
	if (WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0) 
		strTemp +=  " - " +
			astrConvSem[Integer.parseInt(request.getParameter("semester"))] + 
			" " +  request.getParameter("sy_from") + " - " +  request.getParameter("sy_to");
		
  %>   
  
    <tr>
      <td height="25" colspan="7" bgcolor="#EEF0FB"><div align="center"><strong>SUPPORTING DOCUMENTS </strong></div></td>
    </tr>
    <tr>
      <td height="25" colspan="7"><%=WI.fillTextValue("c_name")%> <br>
      Summary of Charges of 
      Enrolment  <%=strTemp%><br>
      <br></td>
    </tr>
    <tr>
      <td class="bottomBorder"><font size="1">&nbsp;NAME OF FEES</font></td>
      <td class="bottomBorder"><div align="center"><font size="1">First Year </font></div></td>
      <td class="bottomBorder"><div align="center"><font size="1">Second Year </font></div></td>
      <td class="bottomBorder"><div align="center"><font size="1">Third Year </font></div></td>
      <td class="bottomBorder"><div align="center"><font size="1">Fourth Year</font></div></td>
      <td height="20" class="bottomBorder"><div align="center"><font size="1">Fifth Year </font></div></td>
      <td align="center" class="bottomBorder"><font size="1">TOTAL</font></td>
    </tr>
    <tr>
      <td width="27%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="12%" height="18">&nbsp;</td>
      <td width="13%" align="center">&nbsp;</td>
    </tr>
<% 	String strHandsOn = "0";

	boolean bolInfiniteLoop = true;
	boolean bolFormatFloat = false;
for (int i =0 ; i < vRetResultDtl.size();) {
	bolInfiniteLoop = true;
	dTotalRowAmount = 0d;
	if(i > 0) {
		bolFormatFloat = true;
	}
%> 
    <tr>
      <td height="20"><font size="1">&nbsp;
        <% if (i < vRetResultDtl.size() && vRetResultDtl.elementAt(i) != null){%>
   	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i),"--")%>
        <% vRetResultDtl.setElementAt(null, i);
	   
	   }%>
      </font></td>
      <td align="right">
	    <font size="1">
	    <% if (i < vRetResultDtl.size() &&  vRetResultDtl.elementAt(i) == null &&
	  		 ((String)vRetResultDtl.elementAt(i+1)).equals("1")){

			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(i+2),",",""),"0"));
	   %> 
	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i+2),"--")%>
	    <% i += 3;
	  
	  }else{%> 
	    0.00 
	    <%}%>	  
      </font></td>
      <td align="right">
	    <font size="1">
	    <% if (i < vRetResultDtl.size() &&  vRetResultDtl.elementAt(i) == null && 
	  		 ((String)vRetResultDtl.elementAt(i+1)).equals("2")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(i+2),",",""),"0"));
	   %> 
	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i+2),"--")%>
	    <%i += 3;}else{%> 
	    0.00
	    <%}%>	  
      </font></td>
      <td align="right">
	    <font size="1">
	    <% if (i < vRetResultDtl.size() && vRetResultDtl.elementAt(i) == null &&
	  		 ((String)vRetResultDtl.elementAt(i+1)).equals("3")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(i+2),",",""),"0"));
	   %> 
	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i+2),"--")%>
	    <%i += 3;}else{%> 
	    0.00 
	    <%}%>	  
      </font></td>
      <td align="right">
	    <font size="1">
	    <% if (i < vRetResultDtl.size() && vRetResultDtl.elementAt(i) == null &&
	  		 ((String)vRetResultDtl.elementAt(i+1)).equals("4")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(i+2),",",""),"0"));
	   %> 
	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i+2),"--")%>
	    <%i += 3;}else{%> 
	    0.00 
	    <%}%>	  
      </font></td>
      <td height="20" align="right">
	    <font size="1">
	    <% if (i < vRetResultDtl.size() && vRetResultDtl.elementAt(i) == null &&
	  		 ((String)vRetResultDtl.elementAt(i+1)).equals("5")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(i+2),",",""),"0"));
	   %> 
	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i+2),"--")%>
	    <%i += 3;}else{%> 
	    0.00 
	    <%}%>	  
      </font></td>
      <td align="right">
	  		<font size="1"><strong><%=CommonUtil.formatFloat(dTotalRowAmount,bolFormatFloat)%></strong>&nbsp;	  </font></td>
    </tr>

<%
 if (bolInfiniteLoop) {
 	System.out.println("specific_acct_cpu_details.jsp");
 	System.out.println("i : " + i);
	System.out.println("vRetResult.size() : " + vRetResultDtl.size());
	System.out.println("vRetResult.elementAt(i) : " + vRetResultDtl.elementAt(i));
	System.out.println("(String)vRetResult.elementAt(i+1) : " + (String)vRetResultDtl.elementAt(i+1));
	break;
 }
}%> <tr>
      <td height="20" class="topBorder">&nbsp;</td>
      <td align="right" class="topBorder">&nbsp;</td>
      <td align="right" class="topBorder">&nbsp;</td>
      <td align="right" class="topBorder">&nbsp;</td>
      <td align="right" class="topBorder">&nbsp;</td>
      <td height="20" align="right" class="topBorder">&nbsp;</td>
      <td align="right" class="topBorder">&nbsp;</td>
    </tr>
  </table>
  
 <% 
 	
 	if (vStudList != null && vStudList.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="9">&nbsp;</td>
  </tr>
  <tr>
  <%strTemp = WI.fillTextValue("date_from");
  	if (strTemp.length() > 0) {
		strTemp = " on " +  WI.formatDate(strTemp,6);
	}
	
	
	if (WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0) 
		strTemp +=  " - " +
			astrConvSem[Integer.parseInt(request.getParameter("semester"))] + 
			" " +  request.getParameter("sy_from") + " - " +  request.getParameter("sy_to");
		
  %> 
  <td colspan="9"><%=WI.fillTextValue("c_name")%> Enrolment Report <%=strTemp%></td>
  </tr>
  <tr>
    <td colspan="9">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="9">Supporting List </td>
  </tr>
  <tr>
    <td colspan="9">&nbsp;</td>
  </tr>
  <tr>
    <td width="4%" class="bottomBorder"><div align="center"><font size="1">Srl</font></div></td>
    <td width="14%" class="bottomBorder"><font size="1">ID Number </font></td>
    <td width="23%" class="bottomBorder"><font size="1">Student Name </font></td>
    <td width="11%" class="bottomBorder"><font size="1">Course-Yr </font></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Tuition &amp; NSTP </font></div></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Misc Fees </font></div></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Lab. Fees </font></div></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Total Fee </font></div></td>
    <td width="8%" class="bottomBorder"><div align="center"><font size="1">Discount</font></div></td>
  </tr>
<% 	iCtr = 1;
	for (int i =  0; i < vStudList.size() ; i+= 10) {%> 
  <tr>
    <td height="20" align="right"><font size="1"><%=iCtr++%>&nbsp;</font></td>
    <td><font size="1">&nbsp;<%=(String)vStudList.elementAt(i)%></font></td>
    <td><font size="1"><%=(String)vStudList.elementAt(i+1)%></font></td>
    <td><font size="1">&nbsp;<%=(String)vStudList.elementAt(i+2) + 
								WI.getStrValue((String)vStudList.elementAt(i+3),"(",")","") + 
								WI.getStrValue((String)vStudList.elementAt(i+4),"-","","")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+5),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+6),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+7),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+8),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+9),"0.00")%></font></td>
  </tr>

<%}%>   <tr>
    <td align="right" class="topBorder">&nbsp;</td>
    <td class="topBorder">&nbsp;</td>
    <td class="topBorder">&nbsp;</td>
    <td class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
  </tr>
  </table>
  
  
<%} // vStudList != null
} // 

%> 



  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="c_name" value="<%=WI.fillTextValue("c_name")%>">
<input type="hidden" name="show_all" value="0">
<input type="hidden" name="print_pg">
<input type="hidden" name="max_line_number" value="<%=iLineCtr%>">
<input type="hidden" name="group_nos" value="<%=iGroupNo-1%>">
<input type="hidden" name="save_jv" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
