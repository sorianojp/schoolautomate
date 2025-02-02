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
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
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
	ReloadPage();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

function AllowTempPermit() {
	if(document.form_.reason.value == '') {
		alert("Please enter reason.");
		return null;
	}
	document.form_.page_action.value = '1';
	
	document.form_.show_result.value = '1';
	document.form_.submit();
}
function EnterPressed(e, strPageAction) {
	if(e.keyCode == 13) {
		if(strPageAction == '1')
			AllowTempPermit();
		else {
			ReloadPage();
		}	
	}

}
function ReloadPage() {
	document.form_.page_action.value = '';
	document.form_.show_result.value = '1';
	document.form_.submit();
}
function FocusID() {
	document.form_.stud_id.focus();
}


//print admission slip.
function PrintTempPermit() {
	var pgURL = "./exam_permit_temp_print.jsp?stud_id="+document.form_.stud_id.value+
		"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
		"&pmt_schedule="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
	var win=window.open(pgURL,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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

boolean bolAllowPrinting = false; String strPrevValidUntil = null;
//boolean bolAllowForced   = false;


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
	if(strTemp.equals("1")) {//save now temp permit.. 
		String strValidUntil = WI.fillTextValue("valid_until");
		if(strValidUntil.length() > 0) {
			strValidUntil = ConversionTable.convertTOSQLDateFormat(strValidUntil);
			if(strValidUntil == null || strValidUntil.length() == 0) 
				strErrMsg = "Please enter valid until in mm/dd/yyyy format.";
			else {
				if(strAdmSlipPrintIndex == null) {//first time.. 
					strTemp = "insert into 	ADM_SLIP_PRN_COUNT (USER_INDEX,ADM_SLIP_NUMBER,PMT_SCH_INDEX,SY_FROM,SEMESTER,"+
								"CREATED_BY,ALLOW_REPRINT,PERMIT_VALIDITY,DATE_PRINTED,TIME_PRINTED,PRINTED_BY) values ("+vStudInfo.elementAt(0)+",'0',"+strExamPeriod+","+strSYFrom+","+strSemester+","+
								(String)request.getSession(false).getAttribute("userIndex")+",1,'"+strValidUntil+"', '"+WI.getTodaysDate()+"',"+strTimePrinted+","+strAuthID+")";
					if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) > 0) {
						strTemp = "select ADM_SLIP_PRN_INDEX from ADM_SLIP_PRN_COUNT where user_index = "+
									vStudInfo.elementAt(0)+" and pmt_sch_index = "+strExamPeriod+" and is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;
						strAdmSlipPrintIndex = dbOP.getResultOfAQuery(strTemp, 0);
					}
				}
				else {//multiple time.. 
					strTemp = "update ADM_SLIP_PRN_COUNT set PERMIT_VALIDITY = '"+strValidUntil+"' where ADM_SLIP_PRN_INDEX="+strAdmSlipPrintIndex;
					dbOP.executeUpdateWithTrans(strTemp, null, null, false);
				}
				//I have to save also.. 
				if(strAdmSlipPrintIndex != null) {
					strTemp = "insert into ADM_SLIP_PRN_EXCEPTION (ADM_SLIP_PRN_INDEX,ALLOWED_BY,REASON,CREATE_DATE,ALLOW_TYPE,PERMIT_VALID_DATE, CREATE_TIME) values ("+
							strAdmSlipPrintIndex+","+(String)request.getSession(false).getAttribute("userIndex")+","+
							WI.getInsertValueForDB(WI.fillTextValue("reason"), true, null)+",'"+WI.getTodaysDate()+"',2,'"+strValidUntil+"', "+strTimePrinted+")";
					dbOP.executeUpdateWithTrans(strTemp, null, null, false);
					
					//print now temp permit.. 
					bolAllowPrinting = true;
				}
				
			}
		
		}
		else {
			strErrMsg = "Please enter valid until date in mm/dd/yyyy format.";
		}

	}
	else if(false && strTemp.equals("2")) {//page action 2 is not defined.. 
		if(strAdmSlipPrintIndex == null) {
			strTemp = "insert into 	ADM_SLIP_PRN_COUNT (USER_INDEX,ADM_SLIP_NUMBER,PMT_SCH_INDEX,SY_FROM,SEMESTER,"+
						"CREATED_BY,ALLOW_REPRINT,DATE_PRINTED,TIME_PRINTED,PRINTED_BY) values ("+vStudInfo.elementAt(0)+",'0',"+strExamPeriod+","+strSYFrom+","+strSemester+","+
						(String)request.getSession(false).getAttribute("userIndex")+",1,'"+WI.getTodaysDate()+"', "+strTimePrinted+","+strAuthID+")";
			if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) > 0) {
				strTemp = "select ADM_SLIP_PRN_INDEX from ADM_SLIP_PRN_COUNT where user_index = "+
							vStudInfo.elementAt(0)+" and pmt_sch_index = "+strExamPeriod+" and is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;
				strAdmSlipPrintIndex = dbOP.getResultOfAQuery(strTemp, 0);
			}
		}
					
		if(strAdmSlipPrintIndex != null) {
			strTemp = "insert into ADM_SLIP_PRN_EXCEPTION (ADM_SLIP_PRN_INDEX,ALLOWED_BY,REASON,CREATE_DATE,ALLOW_TYPE, CREATE_TIME) values ("+
					strAdmSlipPrintIndex+","+strAuthID+","+
					WI.getInsertValueForDB(WI.fillTextValue("reason"), true, null)+",'"+WI.getTodaysDate()+"',1, "+strTimePrinted+")";
			dbOP.executeUpdateWithTrans(strTemp, null, null, false);
		}
	}
	
	///get if temp is already issued and printed.. 
	if(strAdmSlipPrintIndex != null) {
		strTemp = "select PERMIT_VALIDITY, ALLOW_REPRINT from ADM_SLIP_PRN_COUNT where ADM_SLIP_PRN_INDEX = "+strAdmSlipPrintIndex;
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		if(rs.next()) {
			strPrevValidUntil = ConversionTable.convertMMDDYYYY(rs.getDate(1), true);
			if(rs.getInt(2) > 0)
				bolAllowPrinting = true;
		}
		rs.close();
	}
	
}


%>
<body bgcolor="#D2AE72" onLoad="FocusID();<%if(bolAllowPrinting){%>PrintTempPermit();<%}%>">
<form name="form_" action="./exam_permit_temp_main.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PRINT TEMP ADMISSION SLIP PAGE ::::</strong></font></div></td>
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
	  onKeyUp="AjaxMapName('1');EnterPressed(event, '')">
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
    <tr>
      <td>&nbsp;</td>
      <td height="25">Reason to Allow Printing </td>
      <td height="25" colspan="2">
	  <input name="reason" type="text" size="75" maxlength="256" value="<%=WI.fillTextValue("reason")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  style="font-size:18px; font-family:Verdana, Arial, Helvetica, sans-serif" onKeyUp="EnterPressed(event,'1');">	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Valid Until </td>
      <td height="25" colspan="2">
	  <input name="valid_until" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("valid_until")%>"
	    onfocus="style.backgroundColor='#D3EBFF'" class="textbox" 
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','valid_until','/');"
			onKeyUp = "AllowOnlyIntegerExtn('form_','valid_until','/')">
        <a href="javascript:show_calendar('form_.valid_until');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
	  
	  
	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
	  <input type="button" name="1" value="&nbsp;&nbsp;Allow & Print Temporary Admission Slip&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="AllowTempPermit();">		
		
		<%if(strPrevValidUntil != null) {%>
			<br><br><u>Temp permit already allowed until Date : <%=strPrevValidUntil%>. To Reprint, Unlock Re-print. To extend date, save again with new permit validity date.</u>
		<%}%>
		
		</td>
    </tr>
  </table>

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