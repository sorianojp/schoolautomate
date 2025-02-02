<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig, payroll.PReDTRME,
									payroll.PRMiscDeduction, payroll.OvertimeMgmt, payroll.PRSalary"%>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script>
<!--
function PrintPage(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}
function PageAction(strAction, strInfoIndex) {
	document.form_.print_pg.value="";
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../../images/blank.gif";
	document.form_.submit();
}

function PrepareToEdit(strIndex){
	document.form_.print_pg.value="";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strIndex;
	document.form_.submit();
}

function CancelRecord(){
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	document.form_.print_pg.value="";
	this.SubmitOnce('form_');
}

function OpenSearch() {
	var pgLoc = "../../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage() {
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	document.form_.print_pg.value="";
	this.SubmitOnce('form_');
}

function CopyID(strID)
{
	document.form_.emp_id.value=strID;
	document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}

function SelectCode(){
	var selectedIndex = document.form_.ot_type_index.selectedIndex;	
	if(selectedIndex == 0){
		document.form_.rate.value = "";
		document.form_.rate_unit.value = "";
		document.form_.rate_unit_val.value = "";		
		return;
	}
	document.form_.rate.value = eval('document.form_.rate_'+selectedIndex+'.value');	
	document.form_.rate_unit.value = eval('document.form_.rate_unit_'+selectedIndex+'.value');
	document.form_.rate_unit_val.value = eval('document.form_.rate_unit_val_'+selectedIndex+'.value');
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
	String strHasWeekly = null;

//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./overtime_encoding_print.jsp" />
<%return;}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-OT Encoding (Period/Day)","overtime_encoding.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");								
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


	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-DTR"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		CommonUtil comUtil = new CommonUtil();
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"overtime_encoding.jsp");
		
		if(iAccessLevel == 0){//NOT AUTHORIZED.
			dbOP.cleanUP();
			response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
			return;
		}
	}

	
	
	PayrollConfig Pconfig = new PayrollConfig();
	PRMiscDeduction prd = new PRMiscDeduction(request);
	PReDTRME prEdtrME = new PReDTRME();
	OvertimeMgmt OTMgmt = new OvertimeMgmt();
	PRSalary Salary = new PRSalary();
	
	Vector vRetResult = null;
	Vector vEditInfo= null;	
	Vector vPersonalDetails = null;
	Vector vEmpList         = null;
	Vector vSalaryPeriod 	= null;//detail of salary period.
	Vector vTypes = null;
	Vector vSalaryDetails = null;
		
	String strEmpID = WI.fillTextValue("emp_id");
	String strPageAction = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
	String[] astrRateType = {"%","Flat Rate", "Specific Rate"};
	
	String strPayrollPeriod = null;
	String strCutOff = null;
	String strSalDateFr = null;
	String strSalDateTo = null;
	int iTotalHours = 0;
	int iTotalMin = 0;
	int iTemp = 0;
	
	double dHourlyRate = 0d;
	double dTotalOT = 0d;
	boolean bolIsPerDay = WI.fillTextValue("is_per_day").equals("1");
	
	boolean bolReleased = false;
	payroll.PRConfidential prCon = new payroll.PRConfidential();
	boolean bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);

	bolReleased = OTMgmt.checkOtEncoded(dbOP, request);
	//if (strEmpID.length() > 0 && WI.fillTextValue("sal_period_index").length() > 0) {
	if (strEmpID.length() > 0) {
		if(bolCheckAllowed){
			enrollment.Authentication authentication = new enrollment.Authentication();
			vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
			vEmpList = prd.getEmployeesList(dbOP);
	
			if(vPersonalDetails == null){
				strErrMsg = "Employee Profile not Found";
			}
		}else
	   strErrMsg = prCon.getErrMsg();
		vTypes = OTMgmt.operateOnOvertimeType(dbOP,request,4);
	
	}//System.out.println(vPersonalDetails);
	if(WI.fillTextValue("year_of").length() > 0) {
		vSalaryPeriod = prEdtrME.getEmployeePeriods(dbOP, request, strEmployeeIndex);
		if(vSalaryPeriod == null)
			strErrMsg = prEdtrME.getErrMsg();
	}	
	
	if (strPageAction.length() > 0){
		if (strPageAction.compareTo("0")==0) {
			if (OTMgmt.operateOnOvertimeEncoding(dbOP,request,0) != null){
				strErrMsg = " OT Type removed successfully ";
			}else{
				strErrMsg = OTMgmt.getErrMsg();
			}
		}else if(strPageAction.compareTo("1") == 0){
			if (OTMgmt.operateOnOvertimeEncoding(dbOP,request,1) != null){
				strErrMsg = " OT Type posted successfully ";
			}else{
				strErrMsg = OTMgmt.getErrMsg();
			}
		}else if(strPageAction.compareTo("2") == 0){
			if (OTMgmt.operateOnOvertimeEncoding(dbOP,request,2) != null){
				strErrMsg = " OT Type updated successfully ";
				strPrepareToEdit = "";
			}else{
				strErrMsg = OTMgmt.getErrMsg();
			}
		}
	}
	
	if (strPrepareToEdit.compareTo("1") == 0){
		vEditInfo = OTMgmt.operateOnOvertimeEncoding(dbOP,request,3);
	
		if (vEditInfo == null)
			strErrMsg = OTMgmt.getErrMsg();	
	}
	if(!WI.fillTextValue("reset_page").equals("1")){
		vRetResult  = OTMgmt.operateOnOvertimeEncoding(dbOP,request,4);	
	}
%>
<form action="overtime_encoding.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL - DTR - ENCODING OVERTIME PAGE ::::</strong></font></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3">&nbsp;<font size="2" color="#FF0000"><strong><font size="1"><a href="./overtime_main.jsp"><img src="../../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></strong></font><%=WI.getStrValue(strErrMsg,"")%></td>
      <td width="46%"><div align="right">
        <%
	  		if (vEmpList != null && vEmpList.size() > 0){
			  %>
        <%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.indexOf((String)vEmpList.elementAt(0))){%>
        <a href="javascript:CopyID('<%=vEmpList.elementAt(0)%>');">FIRST</a>
        <%}else{%>
FIRST
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) > 0){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) - 1)%>');"> PREVIOUS</a>
<%}else{%>
PREVIOUS
<%}%>
<%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) < vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) + 1)%>');"> NEXT</a>
<%}else{%>
NEXT
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=((String)vEmpList.elementAt(vEmpList.size()-1)).toUpperCase()%>');">LAST</a>
<%}else{%>
LAST
<%}%>
<%}// if (vEmpList != null && vEmpList.size() > 0)%>
      </div></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Employee ID</td>
      <td width="80%"><input name="emp_id" type="text" size="16" value="<%=strEmpID%>" class="textbox" onKeyUp="AjaxMapName(1);"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../../../images/search.gif" width="37" height="30" border="0"></a><label id="coa_info"></label></td>
    </tr>
		<%if(bolIsPerDay){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("ot_date");
				if(strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
			%>
      <td><strong>
        <input name="ot_date" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes">
        <a href="javascript:show_calendar('form_.ot_date');"><img src="../../../../../images/calendar_new.gif" border="0"></a></strong></td>
    </tr>
		<%} else {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td> <select name="month_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
        </select>
        -
        <select name="year_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
        </select>
        (Must be filled up to display salary period information)      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Salary Period</td>
      <td>
	  <select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="ReloadPage();">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};		
	 	strTemp = WI.fillTextValue("sal_period_index");
		for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
		  if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
			strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
			strTemp2 += "Whole Month";
		  }else{
			strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
			strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//			strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//				(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		  }
			
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		strCutOff = (String)vSalaryPeriod.elementAt(i + 1) +" - "+(String)vSalaryPeriod.elementAt(i + 2);
		strSalDateFr = (String)vSalaryPeriod.elementAt(i + 6);
		strSalDateTo = (String)vSalaryPeriod.elementAt(i + 7);
		%>		
			<option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
			<%}else{%>
			<option value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
			<%}//end of if condition.
		 }//end of for loop.
		 /**
		 if(strSalDateFr != null && strSalDateTo != null){
			 vSalaryDetails = Salary.getSalaryDetails(dbOP, strEmployeeIndex, strSalDateFr, strSalDateTo);
			 if(vSalaryDetails != null && vSalaryDetails.size() > 0){
				 strTemp = (String)vSalaryDetails.elementAt(4);
				 dHourlyRate = Double.parseDouble(strTemp);
			 }else{
				 strTemp = "";
			 }
		 }
		 */
		 %>
        </select> 
			<!--
			<input type="hidden" name="hourly_rate" value="<%//=strTemp%>">
			-->
			<% 
				if(strHasWeekly.equals("1")){
					strTemp = WI.fillTextValue("is_weekly");
					if(strTemp.compareTo("1") == 0) 
						strTemp = " checked";
					else	
						strTemp = "";
				%>
      <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ReloadPage();">
      <font size="1">for weekly </font>
      <%}// check if the company has weekly salary type%></td>
    </tr>
		<%}%>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ReloadPage();"></a><font size="1">
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
        Click
        to reload page.</font></td>
    </tr>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
  </table>	
	<%if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">Employee Name : </td>
      <td><strong>&nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID : </td>
      <td><strong>&nbsp;<%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : </td>
      <%
		strTemp = (String)vPersonalDetails.elementAt(13);
		if (strTemp == null){
			strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
		}else{
			strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
		}
		%>
      <td><strong>&nbsp;<%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : </td>
      <td><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="25%">Employment Status<strong> : </strong></td>
      <td width="72%"><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td  height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>		
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="25%">Overtime Type Code :</td>
			<% if (vTypes != null && vTypes.size() >0){
			for(int i = 0,iCount = 1;i < vTypes.size();i+=19,iCount++){%>
          <input type="hidden" name="rate_<%=iCount%>" value="<%=vTypes.elementAt(i+3)%>">
          <input type="hidden" name="rate_unit_<%=iCount%>" value="<%=vTypes.elementAt(i+5)%>">
					<input type="hidden" name="rate_unit_val_<%=iCount%>" value="<%=vTypes.elementAt(i+4)%>">
			<%}
			}%>
			
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(6);
					else 
						strTemp = WI.fillTextValue("ot_type_index"); 	
			%>					
      <td width="72%" height="26"> 
        <select name="ot_type_index" onChange="SelectCode();">
          <option value="">Select OT Type</option>
          <% if (vTypes != null && vTypes.size() >0){
					for(int i = 0;i < vTypes.size();i+=19){
		  			if(strTemp.equals(((Integer)vTypes.elementAt(i)).toString())){%>
	          <option value="<%=vTypes.elementAt(i)%>" selected><%=vTypes.elementAt(i+1)%></option>
  	        <%}else{%>
    	      <option value="<%=vTypes.elementAt(i)%>"><%=vTypes.elementAt(i+1)%></option>
      	  <%}}
					}%>
        </select>
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(3);
					else 
						strTemp = WI.fillTextValue("rate"); 	
			%>					
				<input type="text" class="textbox_noborder" name="rate" readonly="yes" size="6" 
				style="text-align:right" value="<%=strTemp%>">
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(8);
					else 
						strTemp = WI.fillTextValue("rate_unit"); 	
			%>									
        <input type="text" class="textbox_noborder" name="rate_unit" readonly="yes" size="16" value="<%=strTemp%>">
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(4);
					else 
						strTemp = WI.fillTextValue("rate_unit_val"); 	
			%>					
				<input type="hidden" name="rate_unit_val" size="10" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Worked Duration :</td>
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(5);
					else 
						strTemp = WI.fillTextValue("hours_work"); 				
			%>		
      <td height="26">
			<input name="hours_work" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyInteger('form_','hours_work')" value="<%=strTemp%>" size="6" maxlength="6" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','hours_work')">
			(hrs) 
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(11);
					else 
						strTemp = WI.fillTextValue("minutes_work"); 				
			%>	
			and	
			<input name="minutes_work" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyInteger('form_','minutes_work')" value="<%=strTemp%>" size="6" maxlength="6" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','minutes_work')">
			(minutes) 
			</td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="26">&nbsp;</td>
    </tr>
    <tr> 
      <td height="43" colspan="3" align="center">  			
        <%if(!bolReleased && iAccessLevel > 1){%>
				<% if(vEditInfo != null) {%>
				<!--
          <a href='javascript:PageAction(2,<%=WI.fillTextValue("info_index")%>);'><img src="../../../../../images/edit.gif" width="40" height="26" border="0"></a>
					-->
				<input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2','<%=WI.fillTextValue("info_index")%>');">
				<font size="1">click to save changes</font>
        <%}else{%>
        <!--
					<a href='javascript:PageAction(1,"");'><img src="../../../../../images/save.gif" border="0" name="hide_save"></a>
					-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
				<font size="1">click to add</font> 
        <%}%>
			  
       	<!--
				  <a href="javascript:CancelRecord();"><img src="../../../../../images/cancel.gif" width="51" height="26" border="0"></a>
					-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">					
				<font size="1">click to cancel</font>
				<%} // end if  !bolReleased%>
			</td>
    </tr>
  </table>
	<%}%>
	<%if (vRetResult!=null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td colspan="8"><div align="right"><a href="javascript:PrintPage();"><img src="../../../../../images/print.gif"  border="0"></a> 
          <font size="1">click to print list</font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="8" align="center" bgcolor="#B9B292" class="thinborder"><strong><font color="#FFFFFF">:: 
          LIST OF OVERTIME FOR THE PAY PERIOD <%=WI.getStrValue(strPayrollPeriod,"")%> ::</font></strong></td>
    </tr>
    <tr> 
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>COUNT</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>CODE</strong></font></td>
      <td width="28%" height="25" align="center" class="thinborder"><strong>NAME</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>RATE</strong></td>
      <td width="11%" align="center" class="thinborder"><strong>WORKED DURATION</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>OVERTIME PAY</strong></td>
      <td width="11%" align="center" class="thinborder"><strong>DATE</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>OPTIONS</strong></td>
    </tr>
    <%
		//System.out.println("vRetResult " +vRetResult);
		for(int i = 0,iCount = 1; i < vRetResult.size();i +=13,iCount++){%>
    <tr>
      <td valign="top" class="thinborder">&nbsp;<%=iCount%></td>
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td align="right" valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%> <%=astrRateType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+4),"0"))]%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
				iTemp = Integer.parseInt(ConversionTable.replaceString(strTemp,",",""));				
				if(iTemp == 0)
					strTemp = "";
				iTotalHours += iTemp;

				strTemp2 = (String)vRetResult.elementAt(i+11);				
				iTemp = Integer.parseInt(ConversionTable.replaceString(strTemp2,",",""));				
				iTotalMin += iTemp;
			%>
      <td align="right" valign="top" class="thinborder"><%=WI.getStrValue(strTemp,"", " hr(s) and","")%>&nbsp;<%=WI.getStrValue(strTemp2,"", " min ","")%></td>			
			<%
				strTemp = (String)vRetResult.elementAt(i+7);			
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTotalOT +=  Double.parseDouble(strTemp);
			%>
      <td align="right" valign="top" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat((String)vRetResult.elementAt(i+7),true),"&nbsp;")%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+12);
			%>
      <td valign="top" class="thinborder"><%=WI.getStrValue(strTemp,strCutOff)%></td>
      <td align="center" class="thinborder">
			<%if(!bolReleased){ 
				if((bolIsPerDay && strTemp != null && strTemp.length() > 0) || 
				(!bolIsPerDay && (strTemp == null || strTemp.length() == 0))){
				if (iAccessLevel > 1) {%>
						<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../../images/edit.gif" border="0"></a>
				<%}else{%>
						&nbsp;
				<%}				
				if (iAccessLevel == 2) {%>
        	<a href='javascript:PageAction(0,"<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../../../images/delete.gif" border="0"></a>
        <%}else{%>
					N/A
			  <%}
				}else{%>		
					&nbsp;
				<%}%>
			<%} else{// end if !bolReleased%>
			Payroll Saved
			<%}%>			</td>
    </tr>
		<%}%>
    
    <tr> 
      <td height="26" valign="top" class="thinborder">&nbsp;</td>
      <td height="26" valign="top" class="thinborder">&nbsp;</td>
      <td height="26" class="thinborder">&nbsp;</td>
      <td height="26" align="right" class="thinborder"><strong>TOTAL :</strong></td>
			<%
				iTotalHours +=  iTotalMin / 60;				
				iTotalMin = iTotalMin % 60;
				strTemp = Integer.toString(iTotalHours);
				
				if(iTotalHours == 0)
					strTemp = "";				
				strTemp2 = Integer.toString(iTotalMin);				
			%>
      <td height="26" align="right" class="thinborder"><%=WI.getStrValue(strTemp,"", " hr(s) and","")%>&nbsp;<%=WI.getStrValue(strTemp2,"", " min ","")%>&nbsp;</td>
      <td height="26" align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalOT,true)%>&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td height="26" class="thinborder">&nbsp;</td>
		</tr>
  </table>
<%} // if vRetResult != null%>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="24"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
<input type="hidden" name="reset_page">
<input type="hidden" name="is_per_day" value="<%=WI.fillTextValue("is_per_day")%>">
<input type="hidden" name="ot_type" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>