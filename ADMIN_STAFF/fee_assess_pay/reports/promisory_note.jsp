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
function PageAction(strAction, strInfoIndex, strDeleteInfo) {
	if(strAction == "0") {
		var bolProceed = confirm("Are you sure you want to remove PN of student : "+strDeleteInfo+"?");
		if(!bolProceed)
			return;
	}
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrintPg(strExam,strAmount,strDueDate,strPN)
{	
	var pgLoc = "./promisory_note_print_cdd.jsp?stud_id="+document.form_.stud_id.value+"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester.value+"&pmt_schedule="+document.form_.pmt_schedule.value+
		"&exam="+strExam+"&amount="+strAmount+"&dueDate="+strDueDate+"&pnNumber="+strPN;
	var win=window.open(pgLoc,"PrintWindow",'width=1000,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	//fill up empty information.
	document.form_.stud_id.value = "";
	document.form_.amt.value = "";
	document.form_.approve_date.value = "";
	document.form_.due_date.value = "";
	document.form_.approve_id.value = "";
	
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch2() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.approve_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AutoCompute() {
	document.form_.auto_compute.value = '1';
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*, enrollment.FAPromisoryNote ,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
			if(iAccessLevel == 0) 
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-PROMISORY NOTE"),"0"));
		}
		//may be called from registrar.
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
			if(iAccessLevel == 0) 
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
								"promisory_note.jsp");
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
														"promisory_note.jsp");
**/


//end of authenticaion code.
FAPromisoryNote FAPromi = new FAPromisoryNote();
Vector vEditInfo = null;
Vector vRetResult = null;
Vector vStudInfo = null;
String strStudMsg = null;
int iCtr = 0;

double dReqdPmtPerSched = 0d;
boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");


String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

strTemp = WI.fillTextValue("page_action");

strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

	if(strTemp.length() > 0) {
		if(FAPromi.operateOnPromisoryNote(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else
			strErrMsg = FAPromi.getErrMsg();
	}
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = FAPromi.operateOnPromisoryNote(dbOP, request, 3);
	
	if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = FAPromi.getErrMsg();
	}

if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0 
&& WI.fillTextValue("semester").length()>0) {
	vStudInfo = FAPromi.operateOnPromisoryNote(dbOP, request, 5);
	if (vStudInfo == null)
		strStudMsg = FAPromi.getErrMsg();

	vRetResult = FAPromi.operateOnPromisoryNote(dbOP, request, 4);
	if (vRetResult == null && strErrMsg == null )
		strErrMsg = FAPromi.getErrMsg();
		
	//if recompute, check the details per exam sched.. 
	if(WI.fillTextValue("auto_compute").length() > 0 && WI.fillTextValue("stud_id").length() > 0 && WI.fillTextValue("pmt_schedule").length() > 0) {
		String strStudIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"), 4);
		if(strStudIndex != null) {
			String strSQLQuery = "select year_level from stud_curriculum_hist where user_index = "+
						strStudIndex+" and is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+
						" and semester = "+WI.fillTextValue("semester");
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			
			enrollment.FAAssessment faAssessment = new enrollment.FAAssessment();
			faAssessment.setIsBasic(bolIsBasic);
			Vector vPmtDetails = faAssessment.getInstallmentSchedulePerStudPerExamSch(dbOP,
				WI.fillTextValue("pmt_schedule"), strStudIndex, WI.fillTextValue("sy_from"),  
				WI.fillTextValue("sy_to"), strSQLQuery, WI.fillTextValue("semester"));
			if(vPmtDetails != null) {
				dReqdPmtPerSched = Double.parseDouble((String)vPmtDetails.elementAt(5));
				if(dReqdPmtPerSched < 1d)
					dReqdPmtPerSched = 0d;
			}
		}
	}	
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsCDD = strSchCode.startsWith("CDD");

boolean bolIsVMUF  = strSchCode.startsWith("VMUF");
if(strSchCode.startsWith("DBTC") || strSchCode.startsWith("AUF") || strSchCode.startsWith("WUP") || strSchCode.startsWith("UB"))
	bolIsVMUF = true;

String strStudID = null;
%>
<form action="./promisory_note.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PROMISORY NOTE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(bolIsVMUF && !strSchCode.startsWith("FATIMA")) {
	strTemp = WI.fillTextValue("is_basic");
	if(strTemp.length() > 0) 
		strTemp = " checked";
	%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="document.form_.page_action.value='';document.form_.prepareToEdit.value='';document.form_.submit();"> Process Promisory Note for Grade School	  </td>
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
<%
strTemp = WI.fillTextValue("semester");
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
<%}//show only if not basic.. %>	   </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" valign="bottom">Exam Period</td>
      <td width="29%" valign="bottom">  
	  <select name="pmt_schedule">
<%
if(bolIsBasic)
	strTemp = "2";
else	
	strTemp = "1";
%>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid="+strTemp+" order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%> 
	  </select>	  </td>
      <td width="53%" >ID filter
      <%strTemp = WI.fillTextValue("id_filter");%>
      <input name="id_filter" type="text" size="16" maxlength="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  &nbsp;&nbsp;<a href="javascript:ReloadPage();"><img src="../../../images/view.gif" border="0"></a> 
	  <font size="1">Click to view list</font>       </td>
    </tr>
   	<tr>
   		<td colspan="4" height="10"><hr size="1" color="#0000FF"></td>
   	</tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Student ID</td>
      <td> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else {	
	strTemp = WI.fillTextValue("stud_id");
	if(dbOP.strBarcodeID != null)
		strTemp = dbOP.strBarcodeID;
}
strStudID = strTemp;
%> <input name="stud_id" type="text" size="16" maxlength="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>      </td>
      <td><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Amount</td>
      <td>
      <%
      if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		else {	
    		strTemp = WI.fillTextValue("amt");
			if(dReqdPmtPerSched > 0d) {
				strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(dReqdPmtPerSched, true), ",","");
			}
		}
		%>
      <input name="amt" type="text" class="textbox" value="<%=strTemp%>" size="15" maxlength="32"
	   onKeyUp= 'AllowOnlyFloat("form_","amt")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","amt");style.backgroundColor="white"'>      
		
		<a href="javascript:AutoCompute();">Compute</a>
		
		</td>
      <td>
      Due Date : 
        <%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("due_date");%> 
	<input name="due_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
	class="textbox"	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.due_date');" title="Click to select date" 
        onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
        <img src="../../../images/calendar_new.gif" border="0"></a>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Approved Date</td>
      <td> <%
 if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(9),"");
else	
	strTemp = WI.fillTextValue("approve_date");%> 
	<input name="approve_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.approve_date');" title="Click to select date" 
        onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
        <img src="../../../images/calendar_new.gif" border="0"></a>      </td>
      <td>      
      Approved By(ID) : 
      <%
		 if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(10),"");
		else	
	      strTemp = WI.fillTextValue("approve_id");%>
        <input name="approve_id" type="text" size="12" maxlength="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:OpenSearch2();"><img src="../../../images/search.gif" border="0"></a>      </td>
    </tr>
<%
if(WI.fillTextValue("stud_id").length() > 0) {
strTemp = CommonUtil.getName(dbOP, strStudID, 4);
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>PN Remark </td>
      <td colspan="2">
	  <input name="pn_remark" type="text" size="65" value="<%=WI.fillTextValue("pn_remark")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	<%if(bolIsCDD){%>
	<tr>
      <td height="25">&nbsp;</td>
      <td>Applied by</td>
      <td colspan="2">
	  <input name="pn_applied_by" type="text" size="65" value="<%=WI.fillTextValue("pn_applied_by")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>	
	<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Student Name</td>
      <td colspan="2" style="font-size:13px; font-weight:bold; color:#0066FF"><%=WI.getStrValue(strTemp)%></td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
	
<%if(iAccessLevel > 1 && WI.fillTextValue("stud_id").length()>0){%>	  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
	<tr>		
      <td width="18%">&nbsp;</td>
      <td width="82%">
      <%if (vStudInfo!=null && vStudInfo.size()>0){%>
	  <table  bgcolor="#F0F0F0" width="60%" border="0" cellspacing="0" cellpadding="5" class="thinborder">
		<tr bgcolor="#DDDDDD">
			<td width="20%" height="30" class="thinborder"><font size="1"><strong>EXAM NAME</strong></font></td>
			<td class="thinborder" width="20%"><font size="1"><strong>AMOUNT</strong></font></td>
			<td class="thinborder" width="20%"><font size="1"><strong>DUE DATE</strong></font></td>
			<%if(bolIsCDD){%>
			<td class="thinborder" width="20%"><font size="1"><strong>PN Number</strong></font></td>
			<td class="thinborder" width="20%">&nbsp;</td><%}%>
		</tr>
		
		<%		
		for (iCtr = 0; iCtr < vStudInfo.size(); iCtr+=4){%>
		<tr>
			<td class="thinborder">&nbsp;<font size="1"><%=(String)vStudInfo.elementAt(iCtr)%></font></td>
			<td class="thinborder">&nbsp;<font size="1"><%=(String)vStudInfo.elementAt(iCtr+1)%></font></td>
			<td class="thinborder">&nbsp;<font size="1"><%=WI.getStrValue(vStudInfo.elementAt(iCtr+2),"xxxxx")%></font></td>
			<%if(bolIsCDD){%>
			<td class="thinborder">&nbsp;<font size="1"><%=WI.getStrValue(vStudInfo.elementAt(iCtr+3),"&nbsp;")%></font></td>
			<td class="thinborder">&nbsp;<input name="submit22" type="submit" 
			style="font-size:11px; height:18px;border: 1px solid #FF0000;" 
			value="PRINT" 
			onClick="PrintPg('<%=vStudInfo.elementAt(iCtr)%>','<%=(String)vStudInfo.elementAt(iCtr+1)%>','<%=(String)vStudInfo.elementAt(iCtr+2)%>','<%=(String)vStudInfo.elementAt(iCtr+3)%>');">			
			</td>
			<%}%>
			
			
		</tr>
		<%}%>
	  </table>
      <%} else {%>
		<font size="3" color="red">&nbsp;<%=WI.getStrValue(strStudMsg)%></font>
      <%}%>
      </td>
	</tr>
    <tr> 
      <td height="59">&nbsp;</td>
      <td >
	  <%if(strPrepareToEdit.compareTo("0") == 0) {%>
	  <a href='javascript:PageAction("1","");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
	  <%}else{%>
	  <a href='javascript:PageAction("2","");'><img src="../../../images/edit.gif" border="0"></a>
	  
	  <font size="1">click to save entries/changes 
	  <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>click to cancel/clear 
        entries </font><%}%></td>
    </tr>
  </table>
<%}//if iAccessLevel > 1

if(vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("id_filter").length()>0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFF9F"> 
      <td height="23" colspan="7" class="thinborder"><div align="center"><font color="#0000FF"><strong>PROMISORY 
          NOTE DETAILS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="41%" height="23" class="thinborder"><div align="center"><font size="1"><strong>ID 
          (NAME)</strong></font></div></td>
      <td width="17%" class="thinborder"><div align="center"><font size="1"><strong>COURSE-YR</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>DUE 
          DATE </strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>PN REMARK</strong></font></div></td>
      <td width="8%" class="thinborder">&nbsp;</td>
      <td width="10%" class="thinborder">&nbsp;</td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size() ; i += 14){%>
    <tr> 
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%> (<%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%>)</font></td>
      <td class="thinborder"><font size="1">&nbsp;
	  <%=WI.getStrValue(vRetResult.elementAt(i+5))%> 
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+6),"-","","")%></font></td>
      <td class="thinborder"><font size="1">&nbsp;
	  <%=WI.getStrValue(vRetResult.elementAt(i+11),"xxxxxx")%></font></td>
      <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+7),true)%></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+12),"")%></font></td>
      <td class="thinborder"> <%if(iAccessLevel > 1){%> <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);"><img src="../../../images/edit.gif" border="0"></a> 
        <%}%> </td>
      <td class="thinborder"> <%if(iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i+1)%>");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}%> </td>
    </tr>
    <%}//end of for loop%>
  </table>
<%}//end of if vRetResult is not null.%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input name="info_index" type="hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
    <input type="hidden" name="page_action">
	<input type="hidden" name="auto_compute">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>