<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
	
String strAuthID = (String) request.getSession(false).getAttribute("userIndex");//used for SWU
	
boolean bolSWU = strSchoolCode.startsWith("SWU");
boolean bolSPC = strSchoolCode.startsWith("SPC");
boolean bolNEU = strSchoolCode.startsWith("NEU");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.print_pg.value = "0";
	this.SubmitOnce("form_");
}	
function PrintPg() {
	document.form_.c_index.value = "";
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}

function PrintPgPerCollege(strCollegeIndex){
	document.form_.print_pg.value = "1";
	document.form_.c_index.value = strCollegeIndex;
	this.SubmitOnce("form_");
}


function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}	
function UpdateLoadHr() {
	document.form_.update_loadhr.value = 1;
	document.form_.print_pg.value = "0";
	this.SubmitOnce('form_');
}
//all about ajax - to display student list with same name.
function AjaxMapName(e) {
		if(e.keyCode == 13) {
			this.ReloadPage();
			return;
		}
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.form_.print_pg.value = "";
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}


function AjaxUpdateOthers(strIndexName, strIndex, strTableName, strFieldName, strIsString, objCOA, strDefault){	
	//this.setEIP(false);
	this.InitXmlHttpObject2(objCOA, 2, strDefault);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20401&table_name="+strTableName+
	"&field_name="+strFieldName+
	"&table_index="+strIndex+
	"&is_string="+strIsString+
	"&field_value="+escape(objCOA.value)+
	"&"+strFieldName+"="+escape(objCOA.value)+
	"&index_name="+strIndexName;
	
	this.processRequest(strURL);
}

-->
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.emp_id.focus()">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);
	String strClassEnd = null;
	String strClassStart = null;
	String strEmpID = null;
	java.sql.ResultSet rs = null;
	strTemp = WI.fillTextValue("c_index");
	
	strEmpID = WI.getInsertValueForDB(WI.fillTextValue("emp_id"), true, null);
	
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-Faculty Load Print","teaching_load_slip.jsp");
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
	
	
	if(WI.fillTextValue("print_pg").compareTo("1") == 0){
		
		if(strSchoolCode.startsWith("CDD")){	
			dbOP.cleanUP();
		%>
			<jsp:forward page="./teaching_load_slip_print_cdd.jsp?c_index=<%=strTemp%>" />
		<%}else if(bolSWU){
		
		strClassStart = WI.fillTextValue("class_start");
		strClassStart = ConversionTable.convertTOSQLDateFormat(strClassStart);
		if(strClassStart == null)
			strErrMsg = "Please provide mm/dd/yyyy format for start of class.";
		else{
			strClassEnd = WI.fillTextValue("class_end");
			strClassEnd = ConversionTable.convertTOSQLDateFormat(strClassEnd);
			if(strClassEnd == null)
				strErrMsg = "Please provide mm/dd/yyyy format for end of class.";
			else{
				
				
				strTemp = 
					" update FACULTY_LOAD set class_start = '"+strClassStart+"', class_end = '"+strClassEnd+"' "+
					" where IS_VALID = 1 "+
					" and exists( "+
					" 	select * from E_SUB_SECTION where IS_VALID = 1 "+
					" 	and OFFERING_SY_FROM = "+WI.fillTextValue("sy_from")+
					" 	and OFFERING_SEM = "+WI.fillTextValue("semester")+
					" 	and SUB_SEC_INDEX = faculty_load.SUB_SEC_INDEX "+
					" ) and USER_INDEX = (select USER_INDEX from USER_TABLE where ID_NUMBER = "+strEmpID+") ";				
				if( dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1 )
					strErrMsg = "Error in updating class start and class end.";
				else{
					request.getSession(false).setAttribute("start_of_class",WI.fillTextValue("class_start"));
					request.getSession(false).setAttribute("end_of_class",WI.fillTextValue("class_end"));
					dbOP.cleanUP();
					%>
					<jsp:forward page="./teaching_load_slip_print_swu.jsp?c_index=<%=strTemp%>" />
				<%}				
			}
		}
	}else{dbOP.cleanUP();%>
		<jsp:forward page="./teaching_load_slip_print.jsp" >
			<jsp:param name="c_index" value="<%=strTemp%>" />
		</jsp:forward>
	<%}%>
	<%return;
	}

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-TEACHING LOAD"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}


CommonUtil comUtil = new CommonUtil();
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"teaching_load_slip.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
**/
Vector vRetResult = null; double dTotalLoadHour = 0d;
FacultyManagement FM = new FacultyManagement();
FM.setRequest(request);
Vector vUserDetail = null;
Vector vRetSummaryLoad = null;

//strSchoolCode = "UI";
if(strSchoolCode == null)
	strSchoolCode = "";
if(strSchoolCode.startsWith("WNU"))
	strSchoolCode = "UI";
boolean bolShowPrint = true;
boolean bolAllowLoadHour = true;

boolean bolGetAddInfo = false;
int iElemCount = 0;

//if(strSchoolCode.startsWith("VMUF") || strSchoolCode.startsWith("CGH"))
//	bolAllowLoadHour = false;	

String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");
							

if(strEmployeeIndex != null) {
	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));
	if(vUserDetail == null)
		strErrMsg = FM.getErrMsg();
	else {//System.out.println("View : "+vUserDetail);
		if(WI.fillTextValue("update_loadhr").length() > 0) 
			FM.saveFacultyLoadHr(dbOP, request);
		
		strTemp = WI.fillTextValue("print_option_swu");			
		if(strTemp.length() > 0){
			if(strTemp.equals("1"))//print only graduate schoool
				strTemp = " and E_SUB_SECTION.DEGREE_TYPE = 1 ";//" and C_NAME like 'graduate school%'";
			else if(strTemp.equals("2"))
				strTemp = " and E_SUB_SECTION.DEGREE_TYPE <> 1 ";//" and C_NAME not like 'graduate school%'";
			else
				strTemp = "";//meaning all print all subjects
		}
		
		/*the get additional data is set to true always.
		if ever this is updated to false.
		SWU && SPC must make this to true.
		*/
		bolGetAddInfo = true;
		vRetResult = FM.viewFacultyLoadSummary(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"), strTemp, bolGetAddInfo);//get additional data.
					
		if(vRetResult == null)
			strErrMsg = FM.getErrMsg();
		else{
			iElemCount = FM.getElemCount();			
		}
			
		vRetSummaryLoad = FM.getFacultySummaryLoadCollege(dbOP,request);
		if ( vRetSummaryLoad == null) 
			strErrMsg =  FM.getErrMsg();
		else {//get total number of hours. 
			for (int i= 0; i < vRetSummaryLoad.size() ; i+=8)
				dTotalLoadHour += Double.parseDouble((String)vRetSummaryLoad.elementAt(i + 7));
			//System.out.println(vRetSummaryLoad);
		}
	}
}else if (WI.fillTextValue("emp_id").length() != 0)
	strErrMsg = " Invalid employee ID ";

//end of authenticaion code.
%>
<form name="form_" action="./teaching_load_slip.jsp" method="post">  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#A49A6A"> 
    <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          VIEW/PRINT TEACHING LOAD SLIP PAGE ::::</strong></font></div></td>
  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
<%
if(bolSWU){
%>
    <tr >
        <td height="25">&nbsp;</td>
        <td>Print Option</td>
        <td>
		<select name="print_option_swu">
				<%
				strTemp = WI.fillTextValue("print_option_swu");
				if(strTemp.length() == 0 || strTemp.equals("0"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
				%><option value="0" <%=strErrMsg%>>All Subject</option>
				<%				
				if(strTemp.equals("1"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
				%><option value="1" <%=strErrMsg%>>Only Graduate School Subject</option>
				<%				
				if(strTemp.equals("2"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
				%><option value="2" <%=strErrMsg%>>Exclude Graduate School Subject</option>
			</select>
		</td>
        <td>&nbsp;</td>
    </tr>
<%}%>
    <tr > 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="14%">Employee ID</td>
      <td width="31%"> <input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event);"></td>
      <td width="53%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a><font size="1">click 
        to search </font></td>
    </tr>
    <tr >
      <td></td>
      <td colspan="3"><label id="coa_info"></label></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>School Year</td>
      <td>
        <%
	strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchoolCode.startsWith("CPU")) {
		    if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <% }
	     }if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td height="25"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
<!--
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" style="font-size:9px; font-weight:bold; color:#0000FF"><input type="checkbox" name="dynamic" value="checked" <%=WI.fillTextValue("dynamic")%>>
      Compute load Hour dynamically (Option available until 2008 1st sem) </td>
    </tr>
-->
    <tr > 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(vUserDetail != null && vUserDetail.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Employee Name</td>
      <td width="24%"><strong><%=(String)vUserDetail.elementAt(1)%></strong></td>
      <td width="19%">Employment Status</td>
      <td width="35%"><strong><%=(String)vUserDetail.elementAt(2)%></strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td><strong><%=WI.getStrValue(vUserDetail.elementAt(4))%></strong></td>
      <td>Employment Type</td>
      <td><strong><%=(String)vUserDetail.elementAt(7)%></strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>Department</td>
      <td><strong><%=WI.getStrValue(vUserDetail.elementAt(5),"N/A")%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%

if(bolSWU){
	if(strAuthID != null && strAuthID.length() > 0){
		strTemp = "select ETO_INCHARGE_INDEX from CIT_ETO_INCHARGE where ETO_INCHARGE_INDEX = "+strAuthID;
		if(dbOP.getResultOfAQuery(strTemp, 0) != null)
			bolShowPrint = true;
		else
			bolShowPrint = false;	
	}else
		bolShowPrint = false;
}
if(bolShowPrint){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="40" align="right" valign="bottom">
	  <%if(strSchoolCode.startsWith("UB")){%>
	  <input type="checkbox" name="show_enroll_stud" value="1">Show no. of enrolled student
	  &nbsp;&nbsp;
	  <input type="checkbox" name="show_sub_desc" value="1">Show subject description
	  <%}%>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
          <font size="1">click to print load</font></td>
      
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 

<% if (strSchoolCode!= null && strSchoolCode.startsWith("UI"))
		strTemp = " ASSIGNMENTS";
	else
		strTemp = " DETAILS";
//System.out.println("user detail : "+strSchoolCode);
%>
	
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong>TEACHING 
          LOAD <%=strTemp%></strong></div></td>
    </tr>
    <tr> 
      <td width="33%" height="25"><font size="1">TOTAL NO. OF SECTION : <strong><%=(String)vUserDetail.elementAt(8)%></strong></font></td>
      <td width="26%"> <font size="1">TOTAL UNITS :<strong><%=CommonUtil.formatFloat((String)vUserDetail.elementAt(6),true)%></strong></font></td>
      <td width="37%"><font size="1">TOTAL NO. OF HOURS/WEEK : <strong>
	  <%if(bolAllowLoadHour || WI.fillTextValue("dynamic").length() > 0){%>
	  	<%=CommonUtil.formatFloat(dTotalLoadHour,true)%><%}else{%>
	  <%=(String)vUserDetail.elementAt(9)%><%}%>
	  </strong></font></td>
    </tr>
  </table>
	  
<%}//end of vUserDetail.
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="9%" height="25" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT 
      CODE</strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT TITLE 
      </strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>COLLEGE OFFERING 
      </strong></font></div></td>
	<%if(!bolSWU){%>  
      <td width="4%" class="thinborder"><div align="center"><font size="1"><strong> 
          <%if(strSchoolCode.startsWith("UI")){%>LOAD UNITS <%}else{%>LEC/LAB UNITS<%}%>
      </strong></font></div></td>
	<%}	
	if(bolSPC || bolSWU){
		strTemp = "LEC HOURS";
		if(bolSPC)
			strTemp = "LOAD UNITS";
	%>
		<td width="4%" class="thinborder" align="center"><font size="1"><strong> <%=strTemp%></strong></font></td>
	<%}if(bolSWU){%>
	  	<td width="4%" class="thinborder" align="center"><font size="1"><strong>LAB HOURS</strong></font></td>
	<%}%>
      <td width="11%" class="thinborder"><div align="center"><strong><font size="1"> 
          <%if(bolAllowLoadHour){%>LOAD HOURS<%}else{%>FACULTY LOAD<%}%>
      </font></strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>SECTION </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="4%" class="thinborder"><div align="center"><font size="1"><strong>ROOM #</strong></font></div></td>
      <td width="4%" class="thinborder"><div align="center"><font size="1"><strong>NO. OF STUD.</strong></font></div></td>
      <%
	  if(bolNEU){
	  %><td width="7%" class="thinborder"><div align="center"><font size="1"><strong>EFFECTIVITY DATE</strong></font></div></td>
      <% }if (strSchoolCode!= null && strSchoolCode.startsWith("UI"))
			strTemp = " REMARKS/DATE STARTED";
		else if(strSchoolCode != null && strSchoolCode.startsWith("CDD"))
			strTemp = "SELECT";
		else
			strTemp = "DEAN'S SIGNATURE";
%>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong> 
          <%=strTemp%></strong></font></div></td>
    </tr>
    <%
int p = 0; 	
String strSubjCSVToPrint = request.getParameter("subjToPrint");


strTemp = " select specific_date from FA_FEE_ADJ_ENROLLMENT where sy_from = "+WI.fillTextValue("sy_from")+
		" and semester = "+WI.fillTextValue("semester")+
		" and is_valid =1 and ADJ_PARAMETER = 6";
rs= dbOP.executeQuery(strTemp);
String strStartClass = null;
if(rs.next())
	strStartClass = ConversionTable.convertMMDDYYYY(rs.getDate(1));
rs.close();

if(iElemCount == 0){//its returning 0 in UB, IDK why. T_T
	iElemCount = 9;
	if(bolGetAddInfo){
		iElemCount = 12;	
		if(bolSWU)
			iElemCount = 15;
		if(bolNEU)
			iElemCount = 13;
	}
}
int k = 0;
for(int i = 0 ; i < vRetResult.size() ; i +=iElemCount,k++, ++p){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
    <%if(!bolSWU){%>  
	  <td class="thinborder"> <%if(strSchoolCode.startsWith("UI")){%> <%=(String)vRetResult.elementAt(i + 8)%> <%}else{%> <%=(String)vRetResult.elementAt(i + 3)%> <%}%> </td>
	<%}
	if(bolSPC || bolSWU){
		
		
		if(bolSPC)
			strTemp = (String)vRetResult.elementAt(i + 8);
		else
			strTemp = (String)vRetResult.elementAt(i +12);
	%>
		<td class="thinborder" align="center">
			<input type="text" name="lec_units_<%=p%>" value="<%=strTemp%>" class="textbox"
				  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','lec_units_<%=p%>');style.backgroundColor='white'"
				  onKeyUp="javascript:AllowOnlyFloat('form_','lec_units_<%=p%>');" size="3">		</td>
		<%
	}
	if(bolSWU){	
		//strTemp = (String)vRetResult.elementAt(i + 11);
		if(bolAllowLoadHour)
	  		strTemp = (String)vRetResult.elementAt(i + 9);
		if(strTemp == null)
	  		strTemp = (String)vRetResult.elementAt(i + 11);
			
		if(vRetResult.elementAt(i + 13) != null)
			strTemp = (String)vRetResult.elementAt(i + 13);
		%>
	  	<td class="thinborder" align="center">
			<input type="text" name="lab_units_<%=p%>" value="<%=strTemp%>" class="textbox"
				  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','lab_units_<%=p%>');style.backgroundColor='white'"
				  onKeyUp="javascript:AllowOnlyFloat('form_','lab_units_<%=p%>');" size="3">		</td>
	<%}	%>
      <td align="center" class="thinborder"> 
	  	<%
	  	if(bolAllowLoadHour){
	  		strTemp = (String)vRetResult.elementAt(i + 9);
		if(strTemp == null)
	  		strTemp = (String)vRetResult.elementAt(i + 11);
			
		if(bolNEU){
			//strTemp = (String)vRetResult.elementAt(i + 11);
			//if(strTemp == null)
				strTemp = (String)vRetResult.elementAt(i + 9);
		}
		%> <input type="text" name="load_hr<%=p%>" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','load_hr<%=p%>');style.backgroundColor='white'"
	  onKeyUp="javascript:AllowOnlyFloat('form_','load_hr<%=p%>');" size="3"> 
	  <input type="hidden" name="load_index<%=p%>" value="<%=(String)vRetResult.elementAt(i + 10)%>">
      <%}else{%> <%=(String)vRetResult.elementAt(i + 8)%> <%}%> </td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"&nbsp;")%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
	  
	  
	  <%
	if(bolNEU){
	  strTemp = (String)vRetResult.elementAt(i+12);
	  if(strTemp == null || strTemp.length() == 0)
	  	strTemp = strStartClass;
	  %>
	  <td class="thinborder" align="center">
	  <input name="effectivity_date_<%=k%>" type="text" size="10" value="<%=WI.getStrValue(strTemp)%>" class="textbox"	  
	  onfocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="javascript:AjaxUpdateOthers('load_index', '<%=(String)vRetResult.elementAt(i+10)%>','faculty_load',
	  	'effectivity_date_neu','1', document.form_.effectivity_date_<%=k%>,'<%=strTemp%>');
	  	style.backgroundColor='white'" readonly="yes">
	  <a href="javascript:show_calendar('form_.effectivity_date_<%=k%>');" title="Click to select date" 
			onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0" /></a>
		<script>AjaxUpdateOthers('load_index', '<%=(String)vRetResult.elementAt(i+10)%>',
			'faculty_load','effectivity_date_neu','1', document.form_.effectivity_date_<%=k%>, '<%=strTemp%>')</script>
	  </td>
	  <%}
	  	strTemp = "";
	  if(strSchoolCode!=null && strSchoolCode.startsWith("CDD")){
	  	//if(WI.fillTextValue("subj_sel_"+k).equals("on"))
			strTemp = " checked";
	  	
	  %>
	      <td class="thinborder" align="center"><input type="checkbox" name="subj_sel_<%=k%>" value="<%=(String)vRetResult.elementAt(i+10)%>" <%=strTemp%>/></td>
	  <%}else{%>
	  	  <td class="thinborder">&nbsp;</td>
	  <%}%>	  
    </tr>
    <%} %>
	<input type="hidden" name="max_sub_count" value="<%=k%>">
  </table>
<%	if(bolAllowLoadHour){ %>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="10" ><div align="center"><a href="javascript:UpdateLoadHr();"><img src="../../../images/update.gif" border="0"></a> <font size="1">Update faculty load hour&nbsp;</font>&nbsp;</div></td>
    </tr>
	</table>
<%}%> 
<input type="hidden" name="max_disp_fl" value="<%=p%>">
<% if (vRetSummaryLoad != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
<%if(strSchoolCode.startsWith("SWU")){



strTemp = " select distinct class_start, class_end "+
	" from FACULTY_LOAD "+
	" where IS_VALID = 1 "+
	" and exists( "+
	" 	select * from E_SUB_SECTION where IS_VALID = 1 "+
	" 	and OFFERING_SY_FROM = "+WI.fillTextValue("sy_from")+
	" 	and OFFERING_SEM = "+WI.fillTextValue("semester")+
	" 	and SUB_SEC_INDEX = faculty_load.SUB_SEC_INDEX "+
	" ) and USER_INDEX = (select USER_INDEX from USER_TABLE where ID_NUMBER = "+strEmpID+") ";

rs = dbOP.executeQuery(strTemp);
if(rs.next()){
	if(rs.getDate(1) != null)
		strClassStart = ConversionTable.convertMMDDYYYY(rs.getDate(1));
	if(rs.getDate(2) != null)
		strClassEnd = ConversionTable.convertMMDDYYYY(rs.getDate(2));
}rs.close();


if(strClassStart == null)
	strClassStart = WI.getStrValue((String)request.getSession(false).getAttribute("start_of_class"));
if(strClassEnd == null)
	strClassEnd = WI.getStrValue((String)request.getSession(false).getAttribute("end_of_class"));


if(strClassStart == null || strClassStart.length() == 0)
	strClassStart = WI.getTodaysDate(1);
if(strClassEnd == null || strClassEnd.length() == 0)
	strClassEnd = "";
%>
    <tr> 
      <td width="44%" height="25" style="font-size:14px; ">
	  Start of Class: <input name="class_start" type="text" size="10" value="<%=strClassStart%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
	  <a href="javascript:show_calendar('form_.class_start');" title="Click to select date" 
			onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0" /> </a>
	  </td>
      <td width="56%" style="font-size:14px; ">End of Class: 
	  <input name="class_end" type="text" size="10" value="<%=strClassEnd%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
	  <a href="javascript:show_calendar('form_.class_end');" title="Click to select date" 
			onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0" /></a>
	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong>SUMMARY OF TEACHING LOAD</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="44%" height="26"><div align="center"><strong>COLLEGES / DEPARTMENTS</strong></div></td>
      <td width="34%"> <div align="center"><strong> 
          <%if(strSchoolCode.startsWith("UI")){%>
          NO OF UNITS
          <%}else{%>
          LOAD
          <%}%>
          </strong></div></td>
      <%if(bolAllowLoadHour){%>
      <td width="22%"><div align="center"><strong>NO OF HOURS</strong></div></td>
      <%}%>
    </tr>
    <%  String[] astrConvertUnitType = {"unit(s)", "","",""};
	for (int i= 0; i < vRetSummaryLoad.size() ; i+=8){%>
    <tr> 
      <td height="25">&nbsp;<%=(String)vRetSummaryLoad.elementAt(i) + 
	  			WI.getStrValue((String)vRetSummaryLoad.elementAt(i+1), " / ","","")%></td>
      <td>&nbsp;<%=CommonUtil.formatFloat((String)vRetSummaryLoad.elementAt(i+2),true) + " " +  
	  			astrConvertUnitType[Integer.parseInt(WI.getStrValue((String)vRetSummaryLoad.elementAt(i+3),"3"))]%> <%if (strSchoolCode.startsWith("LNU")){%> &nbsp;&nbsp;&nbsp;&nbsp;<font size="1"><a href="javascript:PrintPgPerCollege('<%=(String)vRetSummaryLoad.elementAt(i+4)%>');"><img src="../../../images/print.gif" border="0"></a> 
        <font size="1">click to print</font></font> <%}%> </td>
      <%if(bolAllowLoadHour){%>
      <td><%=CommonUtil.formatFloat((String)vRetSummaryLoad.elementAt(i+7),true)%></td>
      <%}%>
    </tr>
    <%} // end for loop 
	if(strSchoolCode.startsWith("UI")){%>
    <tr>
      <td height="25"><div align="right"><strong>TOTAL&nbsp;&nbsp;&nbsp;</strong></div></td>
      <td>&nbsp;<%=(String)vUserDetail.elementAt(6)%></td>
      <td><%=CommonUtil.formatFloat(dTotalLoadHour,true)%></td>
    </tr>
	<%}%>
  </table>
  <% if(strSchoolCode.startsWith("UI") && !strSchoolCode.equals("UI")){%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
  	<td height="25" colspan="3" bgcolor="#B9B292">
		<div align="center"><strong>LIST OF SIGNATORIES	</strong></div></td>
  </tr>
      <tr align="center">
        <td width="11%" height="20">Order No. </td>
        <td width="39%" height="20">Signatory </td>
        <td width="50%">Position, College / Dept </td>
      </tr>
<%  int iCtr = 1;
	for (int j= 0; j < vRetSummaryLoad.size() ; j+=8, ++iCtr  ) {
%>
<tr align="center">
        <td>&nbsp;<%=iCtr%></td>
      <td height="20">
	  <input type="text" class="textbox"  name="signatory<%=iCtr%>"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value ="<%=WI.getStrValue((String)vRetSummaryLoad.elementAt(j+5),"&nbsp;")%>" size="32" /> </td>
      <td>
		<input type="text" class="textbox" name="position<%=iCtr%>"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value ="Dean,<%=WI.getStrValue((String)vRetSummaryLoad.elementAt(j+6),"&nbsp;")%>" size="32" />		
	  </td>
    </tr>
   <%} // for loop%>
<tr align="center">
        <td>&nbsp;<%=iCtr%></td>
      <td height="20">
	  <input type="text" class="textbox"  name="signatory<%=iCtr%>"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.fillTextValue("signatory"+iCtr)%>" size="32" /> </td>
      <td>
		<input type="text" class="textbox" name="position<%=iCtr%>"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value ="<%=WI.fillTextValue("position"+iCtr)%>" size="32" />		
	  </td>
    </tr>
	<% ++iCtr; %>
<tr align="center">
        <td>&nbsp;<%=iCtr%></td>
      <td height="20">
	  <input type="text" class="textbox"  name="signatory<%=iCtr%>"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value ="" size="32" /> </td>
      <td>
		<input type="text" class="textbox" name="position<%=iCtr++%>"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value ="" size="32" />		
	  </td>
    </tr>
  </table>
	<input type="hidden" name="max_counter" value="<%=iCtr%>">
  <% } %>	
  
  
 <%} //  vRetSummaryLoad != null%>
 
<%
if(bolShowPrint){
%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18" align="right">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td width="50%" height="28" align="right">
	  Number of Sections Per Page  : 
	  <select name="iMaxRows">
	  <% 
	  
	  	strTemp = WI.fillTextValue("iMaxRows");
		if (strTemp.length() == 0){
			if (strSchoolCode.startsWith("UI")) 
				strTemp = "11";
			else
				strTemp = "12";
		}
	  for (k =8; k <= 25; ++k) { 
	  	if (strTemp.equals(Integer.toString(k))) {
	  %> 
	  	<option value="<%=k%>" selected> <%=k%></option>
	  <%}else{%>
	  	<option value="<%=k%>"> <%=k%></option>
	  <%}}%> 
	  </select></td>
      <td width="50%" height="28">&nbsp;&nbsp;<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> <font size="1">click to print load</font></td>
    </tr>
  </table>
  <%}
}//if vRetResult != null %>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="31%" valign="middle">&nbsp;</td>
      <td width="50%" valign="middle"></tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_pg"> 
<input type="hidden" name="c_index">
<input type="hidden" name="update_loadhr">
<input type="hidden" name="get_hour_load" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>