<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);

   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function ReloadPage() {
	document.form_.exam_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
}
function DeleteProj() {
	document.form_.delete_proj.value='1';
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","major_exam_summary.jsp");
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
														"major_exam_summary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

String strSchCode = (String)request.getSession(false).getAttribute("school_code");

//get different grant here.
FeeExtraction feeEx = new FeeExtraction();

Vector vRetResult = null;

if(WI.fillTextValue("delete_proj").length() > 0) {
	dbOP.executeUpdateWithTrans("update FA_FEE_HISTORY_PROJECTED_COL_RUNDATE set IS_RUNNING = 0, TO_PROCESS = 0", null, null, false);	 
	strErrMsg = "Lock removed. Click Refresh to generate the report.";
}
else if(WI.fillTextValue("pmt_schedule").length() > 0) {
	vRetResult = feeEx.getProjectedCollectionNew(dbOP, request);
	strErrMsg = feeEx.getErrMsg();	
}


%>

<form name="form_" method="post" action="./projected_collection_wnu.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PROJECTED COLLECTION::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">
	  <font style="font-size:14px; color:#0000FF; font-weight:bold">
		NOTE : Please note, students already enrolled in next sy/term are not inlcuded in report.
		<font style="font-weight:normal; font-size:9px;">(This may result inconsistant data)</font>		</font>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="20%" height="25">School year /Term</td>
      <td height="25" colspan="2"> 
<%
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
        </select>
        </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Payment Schedule</td>
      <td height="25" colspan="2"><select name="pmt_schedule">
          <%
//i have to check if i should use the fa_pmt_schedule_extn or fa_pmt_schedule table.
String strSYFrom = request.getParameter("sy_from");
String strSYTo   = null;

if(strSYFrom == null) {
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	strTemp   = (String)request.getSession(false).getAttribute("cur_sem");
}
else {
	strSYFrom = request.getParameter("sy_from");
	strSYTo   = request.getParameter("sy_to");
	strTemp   = request.getParameter("semester");
}
strTemp = dbOP.loadCombo("fa_pmt_schedule_extn.PMT_SCH_INDEX","EXAM_NAME",
		" from fa_pmt_schedule_extn  join fa_pmt_schedule on (fa_pmt_schedule_extn.pmt_sch_index = fa_pmt_schedule.pmt_sch_index)"+
		" where fa_pmt_schedule_extn.is_del=0 and fa_pmt_schedule_extn.is_valid=1 and sy_from="+strSYFrom+
		" and sy_to="+strSYTo+" and semester="+strTemp+
		 " order by fa_pmt_schedule_extn.EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false);
//System.out.println("Printing : "+(String)vStudInfo.elementAt(8)+","+(String)vStudInfo.elementAt(9)+","+(String)vStudInfo.elementAt(5));
if(strTemp.length() ==0)
	strTemp = dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc",
		request.getParameter("pmt_schedule"), false);
%>
          <%=strTemp%> </select>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <input type="image" src="../../../../images/refresh.gif" onClick="ReloadPage();"></td>
    </tr>
    <tr> 
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      <td width="31%" class="thinborderBOTTOM">&nbsp; <%if(vRetResult != null) {%> <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> 
        <font size="1">click to print</font> <%}%> </td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null) {
String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"};%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr>
      <td colspan="2"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="top"><div align="center"><strong>PROJECTED COLLECTION <br>
		  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>&nbsp;&nbsp; AY :
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
          </strong></div></td>
    </tr>
    <tr valign="bottom">
      <td width="42%" height="24">&nbsp;</td>
      <td height="24" align="right">Date and time printed : &nbsp;<%=WI.getTodaysDateTime()%> &nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr align="center" style="font-weight:bold"> 
      <td width="20%" height="24" style="font-size:9px;" align="left" class="thinborder">College</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Old Account</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Curr. Charges</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Total Discount </td>
      <td width="8%" style="font-size:9px;" class="thinborder">Total Adjustment </td>
      <td width="8%" style="font-size:9px;" class="thinborder">Payment</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Prelim</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Midterm</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Pre Final </td>
      <td width="8%" style="font-size:9px;" class="thinborder">Finals</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Balance</td>
    </tr>
	<%
	int iRowIndex = 0;//this indicates what exam is selected.
	strTemp = WI.fillTextValue("exam_name").toLowerCase();
	if(strTemp.startsWith("prelim"))
		iRowIndex = 1;
	if(strTemp.startsWith("mid"))
		iRowIndex = 2;
	if(strTemp.startsWith("semi")) 
		iRowIndex = 3;
	if(strTemp.startsWith("fin")) 
		iRowIndex = 4;
	//System.out.println(strTemp);
	//System.out.println(iRowIndex);
		
	double dTemp = 0d;
	double dBalance = 0d;
	
	double dTotalOldAccount = 0d;
	double dTotalCurCharge  = 0d;
	double dTotalPayment    = 0d;
	double dTotalPrelim     = 0d;
	double dTotalMidterm    = 0d;
	double dTotalPreFinal   = 0d;
	double dTotalFinals     = 0d;
	double dTotalAdjustment = 0d;
	double dTotalDiscount   = 0d;
	
	
	double dOldAccount = 0d;
	double dCurCharge  = 0d;
	double dPayment    = 0d;
	double dPrelim     = 0d;
	double dMidterm    = 0d;
	double dPreFinal   = 0d;
	double dFinals     = 0d;
	double dAdjustment = 0d;
	double dDiscount   = 0;
	//System.out.println(vRetResult);
	
	for(int i = 0; i < vRetResult.size(); i += 10){
		dOldAccount = ((Double)vRetResult.elementAt(i + 1)).doubleValue();
		dCurCharge  = ((Double)vRetResult.elementAt(i + 2)).doubleValue() - dOldAccount;
		dPayment    = ((Double)vRetResult.elementAt(i + 3)).doubleValue();
		dPrelim     = ((Double)vRetResult.elementAt(i + 4)).doubleValue();
		dMidterm    = ((Double)vRetResult.elementAt(i + 5)).doubleValue();
		dPreFinal   = ((Double)vRetResult.elementAt(i + 6)).doubleValue();
		dFinals     = ((Double)vRetResult.elementAt(i + 7)).doubleValue();
		
		dDiscount   = ((Double)vRetResult.elementAt(i + 8)).doubleValue();
		dAdjustment = ((Double)vRetResult.elementAt(i + 9)).doubleValue();
		
		
		if(iRowIndex == 2) {//generating in miterm
			dMidterm += dPrelim;
			dPrelim = 0d;
		}
		if(iRowIndex == 3) {//generating in pre-final
			dPreFinal += dPrelim + dMidterm;
			dPrelim = 0d; dMidterm = 0d;
		}
		if(iRowIndex == 4) {//generating in final
			dFinals = dPrelim + dMidterm + dPreFinal;
			dPrelim = 0d; dMidterm = 0d; dPreFinal = 0d;
		}
		
		dTotalOldAccount += dOldAccount;
		dTotalCurCharge  += dCurCharge;
		dTotalPayment    += dPayment;
		dTotalPrelim     += dPrelim;
		dTotalMidterm    += dMidterm;
		dTotalPreFinal   += dPreFinal;
		dTotalFinals     += dFinals;
		
		dTotalAdjustment += dAdjustment;
		dTotalDiscount   += dDiscount;
		
		if(iRowIndex != 4)//generating for final
			dFinals = 0d;
	%>
    <tr align="right"> 
      <td height="24" align="left" class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dOldAccount, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dCurCharge, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dDiscount, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dAdjustment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dPayment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dPrelim, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dMidterm, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dPreFinal, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dFinals, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dFinals+dPreFinal+dMidterm+dPrelim, true)%></td>
    </tr>
	<%}%>
    <tr align="right" style="font-weight:bold">
      <td height="24" align="left" class="thinborder">TOTAL : </td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalOldAccount, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalCurCharge, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalDiscount, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalAdjustment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalPayment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalPrelim, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalMidterm, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalPreFinal, true)%></td>
      <td class="thinborder"><%if(iRowIndex != 4){%>0.00<%}else{%><%=CommonUtil.formatFloat(dTotalFinals, true)%><%}%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalFinals, true)%></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="69%" height="24"><font size="1">Printed by : <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></font></td>
      <td width="12%">&nbsp;</td>
      <td width="19%">&nbsp;</td>
    </tr>
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
<input type="hidden" name="exam_name">
<input type="hidden" name="delete_proj">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
