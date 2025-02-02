<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	var oRows = document.getElementById('myADTable2').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	while(iRowCount > 0) {
		document.getElementById('myADTable2').deleteRow(0);
		--iRowCount;
	}

   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function ViewReport() {
	//document.form_.view_report.value = 1;
}
function ReloadPage() {
	///document.form_.view_report.value = "";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	Vector vTuitionFee = null;
	Vector vOtherFee   = null;
	Vector vRetResult  = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cashier_report_summary.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"cashier_report_summary.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
														"cashier_report_summary.jsp");
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vEmployeeInfo = null;
Authentication auth = new Authentication();
DailyCashCollection DC = new DailyCashCollection();

if(WI.fillTextValue("date_of_col").length() > 0)
{
	if(WI.fillTextValue("date_of_col_to").length() > 0)
		DC.strCollectionDateTo = WI.fillTextValue("date_of_col_to");

	vRetResult  = DC.viewDailyCashColDetailedTuitionOnly(dbOP,request.getParameter("date_of_col"),request.getParameter("emp_id"), request);
	if(vRetResult == null)
		strErrMsg = DC.getErrMsg();
	else {
		vTuitionFee = (Vector)vRetResult.remove(0);
		vOtherFee   = (Vector)vRetResult.remove(0);
		vOtherFee   = new Vector();
	}
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
if(strSchCode.startsWith("UL"))
	strSchCode = "PHILCST";

//strSchCode = "PHILCST";
	
Vector vSACISummary = new Vector();
if(strSchCode.startsWith("UDMC")){
	double dTemp = 0d; int iIndexOf = 0;
	if(vTuitionFee != null && vTuitionFee.size() > 0) {
		for(int i = 0; i < vTuitionFee.size(); i += 9){
			strTemp = (String)vTuitionFee.elementAt(i + 5);
			iIndexOf = vSACISummary.indexOf(strTemp);
			if(iIndexOf == -1) {
				vSACISummary.addElement(strTemp);
				vSACISummary.addElement(vTuitionFee.elementAt(i + 7));
			}
			else {
				dTemp = Double.parseDouble((String)vTuitionFee.elementAt(i + 7)) + Double.parseDouble((String)vSACISummary.elementAt(iIndexOf + 1));
				vSACISummary.setElementAt(String.valueOf(dTemp), iIndexOf + 1); 
			}
		}
	}
	if(vOtherFee != null && vOtherFee.size() > 0) {
		dTemp = 0d;
		for(int i = 0; i < vOtherFee.size(); i += 9)
			dTemp += Double.parseDouble((String)vOtherFee.elementAt(i + 7));
		vSACISummary.addElement("Others");
		vSACISummary.addElement(String.valueOf(dTemp)); 
	}
}
double dTotalDisplayAmt = Double.parseDouble(WI.getStrValue(WI.fillTextValue("disp_amt"), "10000000000"));//max 10billion,, that should be enough.. 

boolean bolShowTransDate = WI.fillTextValue("show_date").equals("checked");
%>

<form name="form_" method="post" action="./cashier_report_detailed.jsp">
<input type="hidden" name="show_all_teller" value="checked">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          DAILY CASHIER'S REPORT - DETAILED ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
     <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY/Term</td>
      <td height="25" colspan="3">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
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
        </select> 
		</td>
    </tr>
   <tr>
      <td height="25">&nbsp;</td>
      <td width="15%" height="25">Collection Date</td>
      <td height="25" colspan="3"><font size="1">
<%
strTemp = WI.fillTextValue("date_of_col");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>
       <input name="date_of_col" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_of_col');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
		to
<%
strTemp = WI.fillTextValue("date_of_col_to");
%>
       <input name="date_of_col_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_of_col_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
		(for one day, leave to field empty.)
		</font></td>
    </tr>
    <tr>
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td width="16%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td width="41%" class="thinborderBOTTOM">&nbsp;&nbsp;&nbsp;<input type="image" src="../../../../../images/form_proceed.gif" onClick="ReloadPage();">      </td>
      <td width="26%" class="thinborderBOTTOM">&nbsp;
<%if(vRetResult != null) {%>
	  <a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a>
	  <font size="1">click to print</font>
<%}%>	  </td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
<%if(strSchCode.startsWith("AUF")){%>
		<td width="31%" align="right">&nbsp;<img src="../../../../../images/logo/AUF_PAMPANGA.gif" width="100" height="100"></td>
<%}%>
      <td width="45%" align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><i><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",","","")%></i></font></font>
		  <br>
		  <font style="font-family:'Century Gothic'"><strong>ACCOUNTING AND FINANCE OFFICE
		  <br><br>
		  DAILY CASHIER'S REPORT
		  </strong></font>
	  </td>
<%if(strSchCode.startsWith("AUF")){%>
		  <td width="24%">&nbsp;</td>
<%}%>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr valign="bottom">
      <td width="35%" height="24"><font size="1">RUN DATE : <%=WI.getTodaysDateTime()%></font></td>
      <td width="42%" height="24"><font size="1">
	  <%if(WI.fillTextValue("or_range").length() > 0) {%>
	  OR Range: <%=WI.fillTextValue("or_from")%> to <%=WI.fillTextValue("or_to")%>
	  <%}else{%>
	  Collection Date: <%=WI.fillTextValue("date_of_col")%><%=WI.getStrValue(WI.fillTextValue("date_of_col_to")," to ","","")%>
	  <%}%>
	  </font></td>
      <td width="23%" align="right"><font size="1">Teller ID #:<%=WI.fillTextValue("emp_id")%></font>&nbsp;&nbsp;</td>
    </tr>
  </table>
<%
double dTotalTuitionAmt = 0d;
double dTotalOthAmt     = 0d;
double dSubTotalCollege = 0d;
double dSubTotalCourse  = 0d;
double dTemp            = 0d;

double dCash       = 0d;
double dCheck      = 0d;
double dCA         = 0d;

double dCreditCard = 0d;
double dEPay       = 0d;

//added for saci.. dBackAccount
double dBackAccount = 0d;

String strCourseName    = null;
String strCollegeName   = null;

String strCourseToDisp  = null;
String strCollegeToDisp = null;
String strORNum = "";//System.out.println(vTuitionFee);
boolean bolIsCashChkPmt = false;//i

boolean bolIsCancelled = false;//only for cldh..
boolean bolIsCLDH      = strSchCode.startsWith("CLDH");
String strStrikeThru   = null;//strike thru' if OR is cancelled.

if(vTuitionFee != null && vTuitionFee.size() > 0) {
//dTotalTuitionAmt = Double.parseDouble((String)vTuitionFee.remove(0));
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18" colspan="7">&nbsp;</td>
    </tr>
    <tr>
<%if(bolShowTransDate){%>
      <td width="12%">Trans Date </td>
<%}%>
      <td width="14%" height="25">OR #</td>
      <td width="15%" height="25">CLIENT NO.</td>
      <td width="24%">NAME</td>
      <td width="28%"><div align="center"> DESCRIPTION </div></td>
      <td width="6%"><div align="center">TYPE</div></td>
      <td width="13%"><div align="center">AMOUNT</div></td>
    </tr>
    <tr>
      <td height="14" colspan="7"><div align="center"><strong><u>TUITION</u></strong></div></td>
    </tr>
    <%while(vTuitionFee.size() > 2) {
	if(dTotalDisplayAmt <= 0d) {
		vOtherFee.removeAllElements();
		break;
	}
	
	strCollegeName = (String)vTuitionFee.remove(0);
    if(strCollegeName != null){
	strCollegeToDisp = strCollegeName;%>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;COLLEGE::: <%=strCollegeName%></td>
    </tr>
    <%}
strCourseName = (String)vTuitionFee.remove(0);
if(strCourseName != null){
	strCourseToDisp = strCourseName;%>
    <tr>
<%if(bolShowTransDate){%>
      <td>&nbsp;</td>
<%}%>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">COURSE::: <%=strCourseName%></td>
    </tr>
<%}
if(strORNum.equals((String)vTuitionFee.elementAt(0)) )
	bolIsCashChkPmt = true;
else {
	strORNum = (String)vTuitionFee.elementAt(0);
	bolIsCashChkPmt = false;
}
//System.out.println("Printing now -- ");
//System.out.println(vTuitionFee.elementAt(0));
//System.out.println(vTuitionFee.elementAt(1));
//System.out.println(vTuitionFee.elementAt(2));
//System.out.println(vTuitionFee.elementAt(3));
//System.out.println(vTuitionFee.elementAt(4));
//System.out.println(vTuitionFee.elementAt(5));
//System.out.println("end of Printing now -- \r\n");

dTemp = Double.parseDouble((String)vTuitionFee.remove(5));
if(bolIsCLDH && dTemp == 0d) {
	bolIsCancelled = true;
	strStrikeThru =" style='text-decoration:line-through;'";
}
else {
	bolIsCancelled = false;
	strStrikeThru  = "";
}
dTotalDisplayAmt = dTotalDisplayAmt - dTemp;
%>
    <tr>
<%if(bolShowTransDate){%>
      <td><%=(String)vTuitionFee.remove(5)%></td>
<%}else
	vTuitionFee.remove(5);
%>
      <td height="25">&nbsp;<%=(String)vTuitionFee.remove(0)%></td>
      <td height="25">&nbsp;<%if(!bolIsCashChkPmt && !bolIsCancelled){%><%=WI.getStrValue((String)vTuitionFee.remove(0))%><%}else{vTuitionFee.removeElementAt(0);}%></td>
      <td>&nbsp;
        <%if(bolIsCancelled){vTuitionFee.removeElementAt(0);%>
			<font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
		<%}else if(!bolIsCashChkPmt){%>
        <%=(String)vTuitionFee.remove(0)%>
        <%}else{vTuitionFee.removeElementAt(0);}%>      </td>
      <td>&nbsp;
        <%if(!bolIsCashChkPmt){
			strTemp = (String)vTuitionFee.remove(0);
			if(strTemp.startsWith("Back Account "))
				dBackAccount += dTemp;%>
        <%=strTemp%>
        <%}else{vTuitionFee.removeElementAt(0);}%>      </td>
      <td>&nbsp;<%strTemp = (String)vTuitionFee.remove(0);if(!bolIsCancelled){%> <%=strTemp%><%}%></td>
      <td align="right"><%
	  	//dTemp = Double.parseDouble((String)vTuitionFee.remove(0));
		dSubTotalCourse  += dTemp;
		dSubTotalCollege += dTemp;
		dTotalTuitionAmt += dTemp;
		if(strTemp.compareTo("Cash") == 0)
			dCash += dTemp;
		else if(strTemp.compareTo("Chk") == 0)
			dCheck += dTemp;
		else if(strTemp.startsWith("Credit"))
			dCreditCard += dTemp;
		else if(strTemp.startsWith("E"))
			dEPay += dTemp;
		else {
			dCA += dTemp;
			//System.out.println(strTemp);
			//System.out.println("Or Number : "+strORNum);
		}
		
	  %> <%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
    </tr>
<%//System.out.println(vTuitionFee.size());
if(strCourseToDisp != null )
if(vTuitionFee.size() == 0 || vTuitionFee.elementAt(0) != null || vTuitionFee.elementAt(1) != null ){%>
    <tr>
<%if(bolShowTransDate){%>
      <td>&nbsp;</td>
<%}%>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="3"><div align="right">Sub Total <%if(strCourseToDisp != null){%>For <%=strCourseToDisp%><%}%>&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
      <td align="right"><%=CommonUtil.formatFloat(dSubTotalCourse, true)%>&nbsp;</td>
    </tr>
<%strCourseToDisp = null;
dSubTotalCourse = 0d;
}
if(vTuitionFee.size() == 0 || vTuitionFee.elementAt(0) != null){%>
    <tr>
<%if(bolShowTransDate){%>
      <td>&nbsp;</td>
<%}%>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="3"><div align="right">Sub Total
          <%if(strCollegeToDisp != null){%>
          For <%=strCollegeToDisp%>
          <%}%>
          &nbsp;&nbsp;&nbsp;</div></td>
      <td align="right"><%=CommonUtil.formatFloat(dSubTotalCollege,true)%>&nbsp;</td>
    </tr>
<%dSubTotalCollege = 0d;dSubTotalCourse = 0d;}
}//end of while loop.%>
    <tr>
<%if(bolShowTransDate){%>
      <td>&nbsp;</td>
<%}%>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><strong>SUB TOTAL FOR TUITION</strong> </div></td>
      <td>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dTotalTuitionAmt,true)%>&nbsp;</td>
    </tr>
  </table>
<%}//show only if vTuitionFee is not null.

if(vOtherFee != null && vOtherFee.size() > 1){
	dSubTotalCollege = 0d;
	dSubTotalCourse  = 0d;
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
<%if(bolShowTransDate){%>
      <td width="14%">Trans Date </td>
<%}%>
      <td width="14%" height="19"><!--OR #-->&nbsp;</td>
      <td width="15%" height="19"><!--CLIENT NO.-->&nbsp;</td>
      <td width="24%"><!--NAME-->&nbsp;</td>
      <td width="28%"><div align="center"> <!--DESCRIPTION -->&nbsp;</div></td>
      <td width="6%"><div align="center"><!--TYPE-->&nbsp;</div></td>
      <td width="13%"><div align="center"><!--AMOUNT-->&nbsp;</div></td>
    </tr>
    <tr>
      <td height="14" colspan="7"><div align="center"><strong><u>OTHERS</u></strong></div></td>
    </tr>
    <%while(vOtherFee.size() > 0) {
	if(dTotalDisplayAmt <= 0d)
		break;
		
	strCollegeName = (String)vOtherFee.remove(0);
    if(strCollegeName != null){
	strCollegeToDisp = strCollegeName;%>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;COLLEGE::: <%=strCollegeName%></td>
    </tr>
    <%dSubTotalCollege = 0d;}
strCourseName = (String)vOtherFee.remove(0);
if(strCourseName != null){
	strCourseToDisp = strCourseName;%>
    <tr>
<%if(bolShowTransDate){%>
      <td>&nbsp;</td>
<%}%>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">COURSE::: <%=strCourseName%></td>
    </tr>
<%dSubTotalCourse = 0d;}
//System.out.println(" new print :: "+dSubTotalCourse+ " :: "+strCourseName); %>
    <tr>
<%if(bolShowTransDate){%>
      <td>&nbsp;<%=(String)vOtherFee.remove(6)%></td>
<%}else
	vOtherFee.remove(6);
%>
      <td height="25">&nbsp;<%=(String)vOtherFee.remove(0)%></td>
      <td height="25">&nbsp;<%=WI.getStrValue((String)vOtherFee.remove(0))%></td>
      <td>&nbsp;<%=(String)vOtherFee.remove(0)%></td>
      <td>&nbsp;<%=(String)vOtherFee.remove(0)%></td>
      <td>&nbsp;<%strTemp = (String)vOtherFee.remove(0);%> <%=strTemp%></td>
      <td align="right"><%
	  	dTemp = Double.parseDouble((String)vOtherFee.remove(0));
		dSubTotalCourse  += dTemp;
		dSubTotalCollege += dTemp;
		dTotalOthAmt += dTemp;
		if(strTemp.compareTo("Cash") == 0)
			dCash += dTemp;
		else if(strTemp.compareTo("Chk") == 0)
			dCheck += dTemp;
		else if(strTemp.startsWith("Credit"))
			dCreditCard += dTemp;
		else if(strTemp.startsWith("E"))
			dEPay += dTemp;
		else
			dCA += dTemp;
	  %><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
    </tr>
<%dTotalDisplayAmt = dTotalDisplayAmt - dTemp;

if(strCourseToDisp != null)
if(vOtherFee.size() == 0 || vOtherFee.elementAt(1) != null || vOtherFee.elementAt(0) != null){%>
    <tr>
<%if(bolShowTransDate){%>
      <td>&nbsp;</td>
<%}%>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="3"><div align="right">Sub Total For <%=strCourseToDisp%>&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
      <td align="right"><%=CommonUtil.formatFloat(dSubTotalCourse,true)%>&nbsp;</td>
    </tr>
<%
dSubTotalCourse = 0d;
strCourseToDisp = null;
}
if(vOtherFee.size() == 0 || vOtherFee.elementAt(0) != null){%>
    <tr>
<%if(bolShowTransDate){%>
      <td>&nbsp;</td>
<%}%>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="3"><div align="right">Sub Total For <%=strCollegeToDisp%>&nbsp;&nbsp;&nbsp;</div></td>
      <td align="right"><%=CommonUtil.formatFloat(dSubTotalCollege,true)%>&nbsp;</td>
    </tr>
<%dSubTotalCollege = 0d;}
}//end of while loop.%>
    <tr>
<%if(bolShowTransDate){%>
      <td>&nbsp;</td>
<%}%>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><strong>SUB TOTAL FOR OTHERS</strong> </div></td>
      <td>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dTotalOthAmt,true)%>&nbsp;</td>
    </tr>
  </table>
<%}//END OF DISPLAY FOR OTHER CHARGES.
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="25%" height="18">&nbsp;</td>
      <td width="45" height="18">&nbsp;</td>
      <td width="13%" height="18">&nbsp;</td>
    </tr>
<%
if(dCash > 0d){%>
    <tr>
      <td height="25" colspan="2"><div align="right"><strong>TOTAL CASH</strong>&nbsp;&nbsp;</div></td>
      <td height="25"><div align="right"><strong><%=CommonUtil.formatFloat(dCash, true)%>&nbsp;</strong></div></td>
    </tr>
<%}
if(dCheck > 0d){%>
    <tr>
      <td height="25" colspan="2"><div align="right"><strong>TOTAL CHECK&nbsp;&nbsp;</strong></div></td>
      <td height="25"><div align="right"><strong><%=CommonUtil.formatFloat(dCheck, true)%>&nbsp;</strong></div></td>
    </tr>
<%}
if(dCreditCard > 0d){%>
    <tr>
      <td height="25" colspan="2"><div align="right"><strong>TOTAL Credit Card Payment&nbsp;&nbsp;</strong></div></td>
      <td height="25"><div align="right"><strong><%=CommonUtil.formatFloat(dCreditCard, true)%>&nbsp;</strong></div></td>
    </tr>
<%}
if(dEPay > 0d){%>
    <tr>
      <td height="25" colspan="2"><div align="right"><strong>TOTAL E-Pay&nbsp;&nbsp;</strong></div></td>
      <td height="25"><div align="right"><strong><%=CommonUtil.formatFloat(dEPay, true)%>&nbsp;</strong></div></td>
    </tr>
<%}
if(dCA > 0d){%>
   <tr>
      <td height="25" colspan="2"><div align="right"><strong>TOTAL CASH ADVANCE&nbsp;&nbsp;</strong></div></td>
      <td height="25"><div align="right"><strong><%=CommonUtil.formatFloat(dCA, true)%>&nbsp;</strong></div></td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="2"><div align="right"><strong>TOTAL COLLECTION OF DAY</strong>&nbsp;&nbsp;</div></td>
      <td height="25"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalOthAmt + dTotalTuitionAmt, true)%>&nbsp;</strong></div></td>
    </tr>
<%if(strSchCode.startsWith("WNU")){
strTemp = (String)vRetResult.remove(0);
if(strTemp != null && !strTemp.equals("0.00")) {%>
    <tr>
      <td height="25" colspan="3" style="font-weight:bold; font-size:11px;">
	  	<u>Note : Total NSTP Fee Collected for the day : <%=strTemp%></u></td>
    </tr>
<%}//show only for WNU.
}

if(strSchCode.startsWith("UDMC") && dBackAccount > 0d){%>
    <tr style="font-weight:bold" align="right">
      <td height="25" colspan="2">TOTAL BACK ACCOUNT COLLECTED  </td>
      <td height="25"><%=CommonUtil.formatFloat(dBackAccount, true)%></td>
    </tr>
<%}
if(vSACISummary != null && vSACISummary.size() > 0) {%>
    <tr>
      <td height="18" colspan="3">
	  	<table width="35%" cellpadding="0" cellspacing="0" class="thinborder">
		<%for(int i = 0; i < vSACISummary.size(); i += 2){%>
			<tr>
				<td width="60%" class="thinborder"><%=vSACISummary.elementAt(i)%></td>
				<td width="40%" class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vSACISummary.elementAt(i + 1), true)%>&nbsp;</td>
		<%}%>
		</table>
	  </td>
      
    </tr>

<%}%>
    <tr>
      <td height="18" colspan="2">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
<%
if(WI.fillTextValue("or_range").length() == 0) {%>
    <tr>
      <td height="25">Official Receipts Used :</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
<%}//show only if or range is not entered.%>
  </table>

<%}//////////////////// end of report ////////////////////%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="or_range" value="<%=WI.fillTextValue("or_range")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
