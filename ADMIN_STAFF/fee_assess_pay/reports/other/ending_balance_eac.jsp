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
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);

   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function ReloadPage() {

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

if(WI.fillTextValue("show_list").length() > 0) {
	//System.out.println("Printoing.. ");	
	//System.out.println("Printoing.. "+feeEx.getCollectionReport(dbOP, request));
	//System.out.println(feeEx.getErrMsg());
	vRetResult = feeEx.getCollectionReport(dbOP, request);
	if(vRetResult == null)
		strErrMsg = feeEx.getErrMsg();
}

%>

<form name="form_" method="post" action="./collection_report_fatima.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ENDING BALANCE REPORT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="11%" height="25">SY/Term</td>
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
        </select>        </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="2">
	  <select name="college_ref">
          <option value="">ALL</option>
<%
strTemp = " from college where IS_VALID=1 order by c_name asc";
%>
          <%=dbOP.loadCombo("c_index","c_name",strTemp, request.getParameter("c_index"), false)%> 
        </select>
		</td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Year Level </td>
      <td colspan="2">
	  <select name="year_level">
	  <option value="">ALL</option>
<%
strTemp = WI.fillTextValue("year_level");
int iDefVal = Integer.parseInt(WI.getStrValue(strTemp, "0"));
		for(int i = 1; i < 7; ++i) {
			if(iDefVal == i)
				strTemp = " selected";
			else	
				strTemp ="";
		%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Student ID </td>
      <td colspan="2">	  
	  	<input name="stud_id" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">
		<input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='1'">	  </td>
    </tr>
    <tr> 
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" colspan="2" class="thinborderBOTTOM" align="right">
	  <%if(vRetResult != null) {%>
	  Number of Rows Per Page 
	  <select name="no_of_rows">
	  <%
	  int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("no_of_rows"), "40"));
	  for(int i = 40; i < 60; ++i) {
		if(iDefVal == i)
			strTemp = "selected";
		else	
			strTemp = "";
	  %>
	  	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
	  <%}%></select>
	  <%}//d onot show if there is no return result.. %>
	  &nbsp;</td>
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
      <td height="20" colspan="2" valign="top"><div align="center"><strong>COLLECTION REPORT<br>
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
      <td width="5%" style="font-size:9px;" align="left" class="thinborder">Count</td> 
      <td width="20%" height="24" style="font-size:9px;" align="left" class="thinborder">Student ID </td>
      <td width="20%" style="font-size:9px;" align="left" class="thinborder">Student Name </td>
      <td width="20%" style="font-size:9px;" align="left" class="thinborder">Course</td>
      <td width="20%" style="font-size:9px;" align="left" class="thinborder">Year</td>
      <td width="20%" style="font-size:9px;" align="left" class="thinborder">Date Enrolled </td>
      <!--<td width="8%" style="font-size:9px;" class="thinborder">Old Account</td>-->
      <td width="8%" style="font-size:9px;" class="thinborder">Tot Assessment</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Total Discount </td>
      <td width="8%" style="font-size:9px;" class="thinborder">Total Adjustment </td>
      <td width="8%" style="font-size:9px;" class="thinborder">Payment</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Balance</td>
    </tr>
	<%
	double dTemp = 0d;
	
	double dBalance    = 0d;
	double dOldAccount = 0d;
	double dCurCharge  = 0d;
	double dDiscount   = 0d;
	double dAdjustment = 0d;
	double dPayment    = 0d;
	//System.out.println(vRetResult);

	double dTotalBalance    = 0d;
	double dTotalOldAccount = 0d;
	double dTotalCurCharge  = 0d;
	double dTotalDiscount   = 0d;
	double dTotalAdjustment = 0d;
	double dTotalPayment    = 0d;

	
	Vector vInfo = null;
	int iCount = 0; 
	for(int i = 0; i < vRetResult.size(); i += 7){
		vInfo = (Vector)vRetResult.elementAt(i + 6);
		if(vInfo == null)
			vInfo = new Vector();
		
		dOldAccount = 0d;
		dCurCharge  = 0d;
		dDiscount   = 0d;
		dAdjustment = 0d;
		dPayment    = 0d;

		if(vInfo.size() > 4) {
			//dOldAccount = ((Double)vInfo.elementAt(1)).doubleValue();
			dCurCharge  = ((Double)vInfo.elementAt(0)).doubleValue();
			dDiscount   = ((Double)vInfo.elementAt(2)).doubleValue();
			dAdjustment = ((Double)vInfo.elementAt(3)).doubleValue();
			dPayment    = ((Double)vInfo.elementAt(4)).doubleValue();
			
			dBalance = dOldAccount + dCurCharge - dDiscount +  dAdjustment - dPayment;
		}
		dTotalBalance    += dBalance;
		dTotalOldAccount += dOldAccount;
		dTotalCurCharge  += dCurCharge;
		dTotalDiscount   += dDiscount;
		dTotalAdjustment += dAdjustment;
		dTotalPayment    += dPayment;
		
	%>
    <tr align="right">
      <td align="left" class="thinborder"><%=++iCount%>.</td> 
      <td height="24" align="left" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td align="left" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td align="left" class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td align="left" class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td align="left" class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <!--<td class="thinborder"><%=CommonUtil.formatFloat(dOldAccount, true)%></td>-->
      <td class="thinborder"><%=CommonUtil.formatFloat(dCurCharge, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dDiscount, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dAdjustment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dPayment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dBalance, true)%></td>
    </tr>
	<%}%>
    <tr align="right" style="font-weight:bold">
      <td align="left" class="thinborder">&nbsp;</td>
      <td height="24" align="left" class="thinborder">TOTAL : </td>
      <td align="left" class="thinborder">&nbsp;</td>
      <td align="left" class="thinborder">&nbsp;</td>
      <td align="left" class="thinborder">&nbsp;</td>
      <td align="left" class="thinborder">&nbsp;</td>
      <!--<td class="thinborder"><%=CommonUtil.formatFloat(dTotalOldAccount, true)%></td>-->
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalCurCharge, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalDiscount, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalAdjustment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalPayment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalBalance, true)%></td>
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
<input type="hidden" name="show_list">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
