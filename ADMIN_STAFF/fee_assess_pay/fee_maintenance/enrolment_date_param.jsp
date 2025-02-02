<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PageAction(strInfoIndex,iAction)
{
	document.fm_variable.page_action.value = iAction ;
	if(strInfoIndex.length > 0)
		document.fm_variable.info_index.value = strInfoIndex;
	document.fm_variable.submit();
}
function ReloadPage()
{
	document.fm_variable.submit();
}
function ClearEntries()
{
 	document.fm_variable.specific_date.value = "";
	document.fm_variable.days.value = "";
	if(document.fm_variable.adj_type.selectedIndex > 0)
		document.fm_variable.amount.value = "";
	document.fm_variable.remark.value = "";
}
function UpdateExcludedCourse() {
	var pgLoc = "./enrolment_date_param_exempted.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateFPDiscountPerCourse() {
	var pgLoc = "./enrolment_date_param_fp_per_course.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateLateFeeAddl() {
	var pgLoc = "./enrolment_date_param_latefee.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceVairable,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Fee Assessment & Payments-enrolment date param","enrolment_date_param.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"enrolment_date_param.jsp");
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
FAFeeMaintenanceVairable fmVariable = new FAFeeMaintenanceVairable();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	if(fmVariable.operateOnDateParameter(dbOP,request,Integer.parseInt(strTemp)) == null)
		strErrMsg = fmVariable.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}
//get all information from table for the current sem.

if(WI.fillTextValue("sy_from").length() > 0)
{
	vRetResult = fmVariable.operateOnDateParameter(dbOP,request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = fmVariable.getErrMsg();
}

Vector vLateFeeAddl = null;
if(WI.fillTextValue("sy_from").length() > 0) {
	vLateFeeAddl = fmVariable.operateOnLateFineAddl(dbOP, request, 4);
}
dbOP.cleanUP();

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<form name="fm_variable" action="./enrolment_date_param.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: ENROLMENT
          DATE PARAMETERS PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="22%">School Year/Term</td>
      <td width="30%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fm_variable","sy_from","sy_to")'>
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp; <select name="offering_sem" >
          <option value="">ALL</option>
          <%
strTemp =WI.fillTextValue("offering_sem");
if(request.getParameter("offering_sem") == null) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="45%"><input name="image" type="image" src="../../../images/refresh.gif">
        <font size="1">or <a href="javascript:ClearEntries();"><img src="../../../images/clear.gif" border="0"></a>clear
        all entries</font></td>
    </tr>
    <tr>
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td><font color="#0000FF">Late Fee for Pmt Sch</font></td>
      <td colspan="4"><a href="javascript:UpdateLateFeeAddl();"><img src="../../../images/update.gif" border="0"></a>
	  <%if(vLateFeeAddl != null && vLateFeeAddl.size() > 0) {%>
	  <table width="80%" cellpadding="0" cellspacing="0" class="thinborder">
          <tr bgcolor="#CCEEFF"> 
            <td class="thinborder">Pmt Schedule</td>
            <td class="thinborder">On or After</td>
            <td class="thinborder">Amount</td>
          </tr>
          <%for(int i = 0; i < vLateFeeAddl.size(); i += 10) {
			strTemp = (String)vLateFeeAddl.elementAt(i + 1);
			if(strTemp.equals("0"))
				strTemp = "DownPayment";
			else	
				strTemp = (String)vLateFeeAddl.elementAt(i + 7);//payment schedule.
			
			if(vLateFeeAddl.elementAt(i + 8) != null)
				strTemp = strTemp + " ("+(String)vLateFeeAddl.elementAt(i + 8)+")"; 
		  %>
		  <tr bgcolor="#FFFFCC"> 
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <td class="thinborder">&nbsp;<%=(String)vLateFeeAddl.elementAt(i + 5)%></td>
            <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat(Double.parseDouble((String)vLateFeeAddl.elementAt(i + 6)),true)%></td>
          </tr>
          <%}%>
		</table>
	  <%}%>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Parameter</td>
      <td width="75%" colspan="4"><select name="adj_parameter">
<%strTemp = WI.fillTextValue("adj_parameter");
if(!strSchCode.startsWith("CGH")){%>
          <option value="0">Full Payment</option>
<%if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Start Enrolment</option>
<%}else{%>
          <option value="1">Start Enrolment</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>End Enrolment</option>
<%}else{%>
          <option value="2">End Enrolment</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>Early Enrolment(on or before specified date)</option>
<%}else{%>
          <option value="3">Early Enrolment(on or before specified date)</option>
<%}
}//do nto show if not CGH
if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>Late Enrolment(on or after specified date)</option>
<%}else{%>
          <option value="4">Late Enrolment(on or after specified date)</option>
<%}
if(!strSchCode.startsWith("CGH")){

if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>Withdraw/Drop Subject</option>
          <%}else{%>
          <option value="5">Withdraw/Drop Subject</option>
          <%}if(strTemp.compareTo("6") == 0){%>
          <option value="6" selected>Start of Class</option>
          <%}else{%>
          <option value="6">Start of Class</option>
          <%}if(strTemp.compareTo("7") ==0){%>
          <option value="7" selected>Add Subject</option>
          <%}else{%>
          <option value="7">Add Subject</option>
          <%}
}//do not show if not CGH.		  %>
        </select> </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="22%">Specific Date</td>
      <td colspan="4"> <font size="1"> 
        <input name="specific_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("specific_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('fm_variable.specific_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date Range</td>
      <td colspan="4"><select name="date_con">
          <option value="0">After</option>
          <%
strTemp = WI.fillTextValue("date_con");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Within</option>
          <%}else{%>
          <option value="1">Within</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Before</option>
          <%}else{%>
          <option value="2">Before</option>
          <%}%>
        </select> &nbsp; <input name="days" type="text" size="6"
	  value="<%=WI.fillTextValue("days")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyIntegerExtn('form_','days','-');style.backgroundColor='white'"
	  onKeypress="AllowOnlyIntegerExtn('form_','days','-');">
        Days of 
        <select name="day_type">
          <option value="0">Start Enrolment </option>
          <%
strTemp = WI.fillTextValue("day_type");
if(strTemp.compareTo("1") ==0) {%>
          <option value="1" selected>Student Registration Date</option>
          <%}else{%>
          <option value="1">Student Registration Date</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Start of Class</option>
          <%}else{%>
          <option value="2">Start of Class</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Adjustment</td>
      <td colspan="4"><select name="adj_type" onChange="ReloadPage();">
          <option value="0">N/A</option>
<%if(!strSchCode.startsWith("CGH")){
strTemp = WI.fillTextValue("adj_type");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Discount</option>
          <%}else{%>
          <option value="1">Discount</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Refund</option>
          <%}else{%>
          <option value="2">Refund</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>Fine</option>
          <%}else{%>
          <option value="3">Fine</option>
          <%}
}%>
        </select></td>
    </tr>
    <%
if(WI.fillTextValue("adj_type").compareTo("0") != 0 || strSchCode.startsWith("CGH") ){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Amount</td>
      <td colspan="4"><input name="amount" type="text" size="6"
	  value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="amount_factor">
          <option value="0">amount</option>
          <%
strTemp = WI.fillTextValue("amount_factor");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>%</option>
          <%}else{%>
          <option value="1">%</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>unit</option>
          <%}else{%>
          <option value="2">unit</option>
          <%}%>
        </select> <select name="fee_type">
          <option value="0">Tuition Fee</option>
          <%
strTemp = WI.fillTextValue("fee_type");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Miscellaneous Fee</option>
          <%}else{%>
          <option value="1">Miscellaneous Fee</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Total Tuition Fee</option>
          <%}else{%>
          <option value="2">Total Tuition Fee</option>
          <%}%>
        </select></td>
    </tr>
    <%} //show only if adjust is not N/A"
%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Remarks</td>
      <td colspan="4"><input name="remark" type="text" size="64" maxlength="128"
	  value="<%=WI.fillTextValue("remark")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><div align="right"><font color="#0000FF">NOTE : </font></div></td>
      <td colspan="4"><font color="#0000FF">Set Remark to <font size="3"><strong>For 
        New Students</strong></font> if the discount or fine is for new students 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"><font color="#0000FF">Set Remark to <font size="3"><strong>For 
        Old Students</strong></font> if the discount or fine is for old students 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"><font size="1" color="#0000FF"><strong>(student status is 
        applicable only for early and late enrollment setting)</strong></font>      </td>
    </tr>
    <tr> 
      <td height="25"> <div align="left"></div></td>
      <td height="25" colspan="5"> <%
if(iAccessLevel > 1){%> <a href='javascript:PageAction("",1);'><img src="../../../images/save.gif" border="0"></a> 
        <font size="1">click to add/save entries &nbsp;</font> <%}else{%>
        ONLY VIEW PERMITTED 
        <%}%> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><%if(strSchCode.startsWith("UC") || strSchCode.startsWith("DLSHSI")){%>
	  <a href="javascript:UpdateFPDiscountPerCourse();"><img src="../../../images/update.gif" border="0"></a> 
        <font size="1">Set Full Payment Discount Per Course</font>
		<%}%>
	  </td>
      <td height="25" colspan="2" align="right"> <a href="javascript:UpdateExcludedCourse();"><img src="../../../images/update.gif" border="0"></a> 
        <font size="1">Click to update/view courses do not offer discount</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="45%" height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<%
if(WI.fillTextValue("sy_from").length() > 0){
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = "ALL SEM";
else if(strTemp.compareTo("0") == 0)
	strTemp = "SUMMER";
else if(strTemp.compareTo("1") == 0)
	strTemp = "1ST SEM";
else if(strTemp.compareTo("2") == 0)
	strTemp = "2ND SEM";
else if(strTemp.compareTo("3") == 0)
	strTemp = "3RD SEM";
else
	strTemp = "UNDEFINED";
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5"><div align="center">LIST OF ENROLMENT
          DATE PARAMETERS FOR SY <%=request.getParameter("sy_from")+" - "+request.getParameter("sy_to")%>,
          <%=strTemp%></div></td>
    </tr>
  </table>
<%} if(vRetResult != null && vRetResult.size() > 0){

String[] astrConvertToParameter = {"Full Payment","Start of Enrollment","End of Enrollment","Early Enrollment",
										"Late Enrollment","Withdraw/Drop subject","Start of class","Add Subject"};
String[] astrConvertToDateRange = {"After","Within","Before"};
String[] astrConvertToDayType   = {"Start of Enrollment","Student registration Date","Start of class"};
String[] astrConvertToAdjType   = {"N/A","Discount","Refund","Fine"};
String[] astrConvertToAmountUnit= {"Amount","%","unit"};
String[] astrConvertToFeeType   = {"Tuition Fee","Miscellaneous Fee","Total Tuition Fee"};
%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="19%"><div align="center"><font size="1"><strong>PARAMETER NAME</strong></font></div></td>
      <td width="25%" height="25"><div align="center"><font size="1"><strong>SPECIFIC/RANGE
          DATE</strong></font></div></td>
      <td width="23%"><div align="center"><font size="1"><strong>ADJUSTMENT IMPLEMENTATION</strong></font></div></td>
      <td width="19%"><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
      <td width="7%">&nbsp;</td>
    </tr>
    <%//System.out.println(vRetResult.size());System.out.println(vRetResult);
	for(int i = 0 ; i< vRetResult.size() ; i += 11){%>
    <tr>
      <td><div align="center"><font size="1"><%=astrConvertToParameter[Integer.parseInt((String)vRetResult.elementAt(i+1))]%></font></div></td>
      <td height="25"><div align="center"><font size="1">
<%
strTemp = (String)vRetResult.elementAt(i+2);
if(strTemp == null)//it is having date range.
{
	if(vRetResult.elementAt(i+3) != null && vRetResult.elementAt(i + 4) != null && vRetResult.elementAt(i + 5) != null)
		strTemp = astrConvertToDateRange[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" " +
			(String)vRetResult.elementAt(i+4)+" days of "+astrConvertToDayType[Integer.parseInt((String)vRetResult.elementAt(i+5))];
	else
		strTemp = "&nbsp;";
}
%>
          <%=strTemp%></font></div></td>
      <td><div align="center"><font size="1">
          <%
strTemp = "";
if(vRetResult.elementAt(i+6) != null)
	strTemp = astrConvertToAdjType[Integer.parseInt((String)vRetResult.elementAt(i+6))]+" - " ;
if(vRetResult.elementAt(i+7) != null)
	strTemp +=	CommonUtil.formatFloat((String)vRetResult.elementAt(i+7),true);
if(vRetResult.elementAt(i+8) != null)
	strTemp += astrConvertToAmountUnit[Integer.parseInt((String)vRetResult.elementAt(i+8))];
if(vRetResult.elementAt(i+9) != null)
	strTemp += " - "+astrConvertToFeeType[Integer.parseInt((String)vRetResult.elementAt(i+9))];
strTemp = WI.getStrValue(strTemp, "&nbsp;");
%>
          <%=strTemp%></font></div></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+10),"&nbsp;")%></td>
      <td>
        <%if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        N/A
        <%}%>
      </td>
    </tr>
    <%}%>
  </table>
 <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#ffffff">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
 <input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

</form>
</body>
</html>
