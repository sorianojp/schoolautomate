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
function ReloadPage()
{
	document.form_.pmt_sch_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
	this.SubmitOnce('form_');
}
function PrintPg(){
	document.bgColor = "#FFFFFF";
	document.getElementById('tHeader1').deleteRow(0);
	document.getElementById('tHeader1').deleteRow(0);	
	
	var oRows = document.getElementById('tHeader2').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i)
		document.getElementById('tHeader2').deleteRow(0);
	
	document.getElementById('tDataHead').deleteRow(0);
	document.getElementById('tDataHead').deleteRow(0);
	
	document.getElementById('tFooter').deleteRow(0);
	document.getElementById('tFooter').deleteRow(0);
	window.print();
}
function relaunchPage() {
	var strIsBasic = "";
	if(document.form_.is_basic && document.form_.is_basic.checked)
		strIsBasic = "?is_basic=1";	
	location = "./promisory_general_summary.jsp"+strIsBasic;
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*, enrollment.FAPromisoryNote ,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

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
			if(iAccessLevel == 0) 
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-PROMISORY NOTE"),"0"));
		}
		//may be called from registrar.
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));		
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assess & Payment - Reports - Promisory Note.",
								"promisory_general_summary.jsp");
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
														"Fee Assessment & Payments",
														"REPORTS",request.getRemoteAddr(),
														"promisory_general_summary.jsp");
**/

//end of authenticaion code.
FAPromisoryNote FAPromi = new FAPromisoryNote();
Vector vRetResult = null;
int iCtr = 0;
int iTemp = 0;
int iDeptTotal = 0;
int iGrandTotal = 0;
double dGrandTotal = 0d;
double dDeptTotal = 0d;
double dTemp = 0d;
String strTempChecker = "";
String strTempIndex = "";
boolean bolNewGroup = true;
String strTempTitle = null;
String[] astrSemester =  {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0 
&& WI.fillTextValue("semester").length()>0 && WI.fillTextValue("pmt_schedule").length()>0)
{	
	vRetResult = FAPromi.getPromiSummaryGeneral(dbOP, request);
	if (vRetResult == null)
		strErrMsg = FAPromi.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsVMUF  = strSchCode.startsWith("VMUF");
if(strSchCode.startsWith("DBTC") || strSchCode.startsWith("AUF"))
	bolIsVMUF = true;
boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
%>
<form action="./promisory_general_summary.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="tHeader1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: PROMISORY NOTE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="tHeader2">
<%if(bolIsVMUF) {
	if(bolIsBasic) 
		strTemp = " checked";
	else	
		strTemp = "";
	%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="relaunchPage();"> Process Promisory Note for Grade School	  </td>
    </tr>
<%}if(strSchCode.startsWith("AUF") || strSchCode.startsWith("CDD")) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="adjust_pn" value="checked" <%=WI.fillTextValue("adjust_pn")%>> 
	  Adjust PN Amount If Paid For Tuition <font style="font-weight:normal; size:9px"><I>(student will not be included in report if payment amount &gt; PN amount)</I></font> </td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>SY/TERM</td>
      <td colspan="2"> <%
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
<%if(bolIsBasic){%>
<input type="hidden" name="semester" value="1">
<%}else{%>
	  <select name="semester">
          <%strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Term</option>
          <%}else{%>
          <option value="1">1st Term</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Term</option>
          <%}else{%>
          <option value="2">2nd Term</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Term</option>
          <%}else{%>
          <option value="3">3rd Term</option>
          <%}%>
        </select>
<%}%>		</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Exam Period</td>
      <td width="21%">  <select name="pmt_schedule">
<%
if(bolIsBasic)
	strTemp = "2";
else	
	strTemp = "1";
%>
	  <option value="0">Downpayment</option>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid="+strTemp+" order by EXAM_PERIOD_ORDER asc",request.getParameter("pmt_schedule"), false)%> </select>		</td>
      <td width="61%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size()>0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="tDataHead">
		<tr>
			<td align="right" height="25"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print </font></td>
		</tr>
		<tr>
			<td align="center" bgcolor="#EEEEEE" height="25"><strong>PROMISORY NOTES</strong></td>
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" >
    <tr>
      <td colspan="2"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr>
      <td colspan="2"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="top"><div align="center"><strong>LISTING
          OF PROMISORY NOTES <%if(bolIsBasic) {%> (For Grade School)<%}%><br>
		  <%if(!bolIsBasic){%><%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%>&nbsp;&nbsp; <%}%>AY :
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%><br>
		  <%=WI.fillTextValue("pmt_sch_name")%>
          </strong></div></td>
    </tr>
    <tr valign="bottom">
      <td width="42%" height="24">&nbsp;</td>
      <td height="24" align="right">Date and time printed : &nbsp;<%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>
      </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		
		<tr>
			<td colspan="6" height="10">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="6" height="10">&nbsp;</td>
		</tr>
		<tr>
			<td class="thinborderBOTTOM" width="3%" height="25">&nbsp;</td>
			<td class="thinborderBOTTOM" width="60%">&nbsp;DEPARTMENT</td>
			<td class="thinborderBOTTOM" width="7%" align="right">&nbsp;NO.</td>
			<td class="thinborderBOTTOM" align="right" width="30%">AMOUNT&nbsp;</td>
		</tr>
		<%for (iCtr = 0; iCtr < vRetResult.size(); iCtr+=5){
				strTempIndex = (String)vRetResult.elementAt(iCtr+1);
			if (iCtr == 0 || (iCtr > 0 && !strTempIndex.equals((String)vRetResult.elementAt(iCtr-4))))
			{
				iTemp = iDeptTotal;
				iGrandTotal += iDeptTotal;
				iDeptTotal = 0;
		
				dTemp = dDeptTotal;
				dGrandTotal += dDeptTotal;
				dDeptTotal = 0;
				bolNewGroup = true;
			}
		else
			bolNewGroup = false;

		if (bolNewGroup && !bolIsBasic){
			if (iCtr>0){%>
			<tr>
				<td height="25" class="thinborderTOP">&nbsp;</td>
				<td align="right"class=" thinborderTOP">DEPARTMENT TOTAL:&nbsp;</td>
				<td align="right" class="thinborderTOP"><%=iTemp%> </td>
				<td align="right" class="thinborderTOP"><strong><%=CommonUtil.formatFloat(dTemp,true)%></strong><br><img src="doubleline.jpg" width="100"></td>
			</tr>
			<%}%>
			<tr>
				<td colspan="4" height="25">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(iCtr)%></td>
			</tr>
		<%}%>
		<tr>
			<%
				iTemp = Integer.parseInt((String)vRetResult.elementAt(iCtr+3));
				iDeptTotal += iTemp;
				
				dTemp = ((Double) vRetResult.elementAt(iCtr+4)).doubleValue();
				dDeptTotal += dTemp;
			%>
			<td height="25">&nbsp;</td>
			<td>&nbsp;<%=(String)vRetResult.elementAt(iCtr+2)%></td>
			<td align="right"><%=iTemp%> </td>
			<td align="right"><%=CommonUtil.formatFloat(dTemp,true)%> </td>
		</tr>
		<%if ((iCtr+5)>=vRetResult.size()) {
		if(!bolIsBasic) {%>
		<tr>
				<td height="25" class="thinborderTOP">&nbsp;</td>
				<td align="right"class=" thinborderTOP">DEPARTMENT TOTAL:&nbsp;</td>
				<td align="right" class="thinborderTOP"><%=iDeptTotal%></td>
				<td align="right" class="thinborderTOP"><strong><%=CommonUtil.formatFloat(dDeptTotal,true)%></strong><br><img src="doubleline.jpg" width="100"></td>
		</tr>
		<%}
		iGrandTotal +=iDeptTotal;
		dGrandTotal+=dDeptTotal;
		%>
		<tr>
				<td height="25" class="thinborderTOP">&nbsp;</td>
				<td align="left" class="thinborderTOP">GRAND TOTAL:&nbsp;</td>
				<td align="right" class="thinborderTOP"><%=iGrandTotal%></td>
				<td align="right" class="thinborderTOP"><strong><%=CommonUtil.formatFloat(dGrandTotal,true)%></strong><br><img src="doubleline.jpg" width="100"></td>
		</tr>
		<%}%>
		<%}%>
	</table>
  <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="tFooter">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="pmt_sch_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>