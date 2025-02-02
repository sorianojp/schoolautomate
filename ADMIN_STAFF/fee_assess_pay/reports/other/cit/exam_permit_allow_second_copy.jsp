<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

//print admission slip.
function allowExamPermitReprint() {
	strReason = prompt('Please enter reason for Reprint','');
	if(strReason == null || strReason.length == 0) {
		alert("Please enter reason for reprint.");
		return;
	}
	document.form_.reason1.value=strReason;
	document.form_.page_action.value='1';
	document.form_.show_result.value='1';
	document.form_.submit();
}
function ForceAllowReprint() {
	if(document.form_.reason.value == '') {
		alert("Please enter reason.");
		return null;
	}
	document.form_.page_action.value = '2';
	document.form_.show_result.value = '1';
	
	document.form_.submit();
}
function EnterPressed(e) {
	if(e.keyCode == 13)
		ForceAllowReprint();

}
function FocusID() {
	if(document.form_.reason)
		document.form_.reason.focus();
	else	
		document.form_.stud_id.focus();
}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-EXAM PERMIT-ALLOW REPRINT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}




//add security here.
	try
	{
		dbOP = new DBOperation();
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

boolean bolIsBasic = false;
String strExamName = null;
String strExamPeriod = null;
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

String strStudID   = WI.fillTextValue("stud_id");
String strSYFrom   = WI.fillTextValue("sy_from");
String strSYTo     = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");
strExamPeriod      = WI.fillTextValue("pmt_schedule");

Vector vRetResult  = null;//get subject schedule information.

boolean bolAllowPrinting = false;
boolean bolAllowForced   = false;


Vector vStudInfo   = null; double dDueForThisPeriod = 0d;
if(WI.fillTextValue("show_result").length() > 0) {
	enrollment.EnrlAddDropSubject enrlStudInfo = new enrollment.EnrlAddDropSubject();
	vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),	strStudID,strSYFrom, strSYTo, strSemester);
	if(vStudInfo == null) 
		strErrMsg = enrlStudInfo.getErrMsg();
}

if(vStudInfo != null && vStudInfo.size() > 0) {
		String strTimePrinted = WI.getTodaysDate(28);
		String strAuthID = (String)request.getSession(false).getAttribute("userIndex");
	//I have to check if already printed, if printed, need not check anymore balance.. 
	String strAdmSlipPrintIndex = null;
	strTemp = "select ADM_SLIP_PRN_INDEX from ADM_SLIP_PRN_COUNT where user_index = "+
				vStudInfo.elementAt(0)+" and pmt_sch_index = "+strExamPeriod+" and is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;

	strAdmSlipPrintIndex = dbOP.getResultOfAQuery(strTemp, 0);
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.equals("1")) {
		strTemp = "update ADM_SLIP_PRN_COUNT set ALLOW_REPRINT = 1 where ADM_SLIP_PRN_INDEX = "+strAdmSlipPrintIndex;
					
		if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) > 0) {
			strTemp = "insert into ADM_SLIP_PRN_EXCEPTION (ADM_SLIP_PRN_INDEX,ALLOWED_BY,REASON,CREATE_DATE,ALLOW_TYPE, CREATE_TIME) values ("+
					strAdmSlipPrintIndex+","+(String)request.getSession(false).getAttribute("userIndex")+","+
					WI.getInsertValueForDB(WI.fillTextValue("reason1"), true, null)+",'"+WI.getTodaysDate()+"',0, "+strTimePrinted+")";
			dbOP.executeUpdateWithTrans(strTemp, null, null, false);
		}
	}
	else if(strTemp.equals("2")) {//force allow.
		if(strAdmSlipPrintIndex == null) {
			strTemp = "insert into 	ADM_SLIP_PRN_COUNT (USER_INDEX,ADM_SLIP_NUMBER,PMT_SCH_INDEX,SY_FROM,SEMESTER,"+
						"CREATED_BY,ALLOW_REPRINT) values ("+vStudInfo.elementAt(0)+",'0',"+strExamPeriod+","+strSYFrom+","+strSemester+","+
						(String)request.getSession(false).getAttribute("userIndex")+",1)";//, '"+WI.getTodaysDate()+"',"+strTimePrinted+","+strAuthID+")";
			if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) > 0) {
				strTemp = "select ADM_SLIP_PRN_INDEX from ADM_SLIP_PRN_COUNT where user_index = "+
							vStudInfo.elementAt(0)+" and pmt_sch_index = "+strExamPeriod+" and is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;
				strAdmSlipPrintIndex = dbOP.getResultOfAQuery(strTemp, 0);
			}
		}
					
		if(strAdmSlipPrintIndex != null) {
			strTemp = "insert into ADM_SLIP_PRN_EXCEPTION (ADM_SLIP_PRN_INDEX,ALLOWED_BY,REASON,CREATE_DATE,ALLOW_TYPE, CREATE_TIME) values ("+
					strAdmSlipPrintIndex+","+(String)request.getSession(false).getAttribute("userIndex")+","+
					WI.getInsertValueForDB(WI.fillTextValue("reason"), true, null)+",'"+WI.getTodaysDate()+"',1, "+strTimePrinted+")";
			dbOP.executeUpdateWithTrans(strTemp, null, null, false);
		}
	}
	
	strTemp = "select ALLOW_REPRINT from ADM_SLIP_PRN_COUNT where user_index = "+vStudInfo.elementAt(0)+" and pmt_sch_index = "+strExamPeriod+
				" and is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp == null) {
		strErrMsg = "Admission slip is not yet printed.";
		bolAllowForced = true;
	}
	else {
		if(strTemp.equals("0")) {
			bolAllowPrinting = true;
		}
		else
			strErrMsg = "Admission slip is now opened for printing.";
	}
}


%>
<body bgcolor="#D2AE72" onLoad="FocusID();<%if(bolAllowPrinting){%>allowExamPermitReprint();<%}%>">
<form name="form_" action="./exam_permit_allow_second_copy.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PRINT ADMISSION SLIP PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-size:16px; font-weight:bold; color:#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td height="25">Student ID </td>
      <td height="25" colspan="2">
	  <input name="stud_id" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="13%" height="25">SY/TERM</td>
      <td height="25" colspan="2"> <%
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

		// force to 1 (regular for basic ) if not summer and if basic
		if (WI.fillTextValue("is_basic").equals("1") && !strTemp.equals("0"))  
			strTemp = "1";
	
		  if(strTemp.equals("1")){
		  %>
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
        </select> &nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td height="25">Exam Period</td>
      <td width="14%" height="25"><select name="pmt_schedule">
        <%if(bolIsBasic){%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=2 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}else{%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}%>
      </select></td>
      <td width="71%">
	  <%//if(dDueForThisPeriod > 0d) {%>
	  	<!--
		<font style="font-weight:bold; font-size:14px; color:#FF0000">Balance for this Period: <%=CommonUtil.formatFloat(dDueForThisPeriod,true)%>
		-->
	  <%//}%>	  </td>
    </tr>
<%if(bolAllowForced) {%>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Reason to Allow Printing </td>
      <td height="25" colspan="2">
	  <input name="reason" type="text" size="75" maxlength="256" value="<%=WI.fillTextValue("reason")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  style="font-size:18px; font-family:Verdana, Arial, Helvetica, sans-serif" onKeyUp="EnterPressed(event);">
	  
	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
	  <input type="button" name="1" value="&nbsp;&nbsp;Allow Printing Admission Slip&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="ForceAllowReprint();">
		</td>
    </tr>
<%}else{%>
<input type="hidden" name="reason1">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> 
	  <input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1'"></td>
    </tr>
<%}%>
  </table>


<%if(vStudInfo != null && vStudInfo.size() > 0){%>
<!--
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="2" style="font-size:9px;" align="right"><a href="javascript:printExamPermit();"><img src="../../../../../images/print.gif" border="0"></a>Print Admission Slip &nbsp;&nbsp;</td>
  </tr>
</table>
-->
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="71%" height="18"><font size="2"><%=(String)vStudInfo.elementAt(1)%></font></td>
    <td width="29%" style="font-weight:bold"><%=astrConvertSem[Integer.parseInt(strSemester)]%>, AY <%=strSYFrom+" - "+strSYTo%> </td>
  </tr>
  <tr>
<%
strTemp = (String)vStudInfo.elementAt(15);
if(strTemp != null) {
	if(vStudInfo.elementAt(30).equals("1"))
		strTemp = "Returnee";
	else if(strTemp.startsWith("N"))
		strTemp = "Freshmen";
}
%>
    <td height="18" style="font-size:11px;"><%=strStudID%> &nbsp;&nbsp;&nbsp;[<%=strTemp%>]&nbsp;&nbsp;&nbsp;&nbsp;
	<%=(String)vStudInfo.elementAt(16)%>
        <%if(vStudInfo.elementAt(6) != null){%>
/ <%=WI.getStrValue(vStudInfo.elementAt(22))%>
<%}%> - 
<%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></td>
    <td style="font-size:11px"><%=WI.getTodaysDateTime()%></td>
  </tr>
  
</table>

<%if(vRetResult != null && vRetResult.size() > 0 && false) {%>
	<table width="100%" cellpadding="0" cellspacing="0" height="225px"><tr><td valign="top" bgcolor="#FFFFFF">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
		  <tr style="font-weight:bold">
			<td width="1%" height="18" style="font-size:11px;">&nbsp;</td>
			<td width="14%" style="font-size:11px;">SUBJECT</td>
			<td width="25%" style="font-size:11px;">SUBJECT TITLE</td>
			<td width="5%" style="font-size:11px;">UNITS</td>
			<td width="10%" style="font-size:11px;">SECTION</td>
			<td width="25%" style="font-size:11px;">INSTRUCTOR</td>
			<td width="20%" style="font-size:11px;">SIGNATURE</td>
		  </tr>
		   <%for(int i=1; i< vRetResult.size(); i += 11){
		   strTemp = (String)vRetResult.elementAt(i+1);
		   if(strTemp != null && strTemp.length() > 30)
		   	strTemp = strTemp.substring(0,30);
			%>
			  <tr>
				<td height="18" style="font-size:11px;">&nbsp;</td>
				<td style="font-size:11px;"><%=(String)vRetResult.elementAt(i)%></td>
				<td style="font-size:11px;"><%=strTemp%></td>
				<td style="font-size:11px;"><%=(String)vRetResult.elementAt(i+9)%></td>
				<td style="font-size:11px;"><%=(String)vRetResult.elementAt(i+3)%></td>
				<td style="font-size:11px;"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
				<td style="font-size:11px;">_________________</td>
			  </tr>
		  <%}%>
		</table>
	</td></tr></table>
<%}
}//vRetResult is not null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="show_result">
  <input type="hidden" name="page_action">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>