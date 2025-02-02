<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance, payroll.PRTransmittal, payroll.PReDTRME" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
boolean bolShowAll = false;

//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAG-IBIG LOANS MONTHLY REMITTANCES</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	<%if(WI.fillTextValue("generate").length() > 0){%>
	display: block;
	<%}else{%>
	display: none;
	<%}%>
	margin-left: 16px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function Generate()
{
	document.form_.generate.value = "1";
	SearchEmployee();
}

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}
///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}

function loadSalPeriods() {
		var strMonth = document.form_.month_of.value;
		var strYear = document.form_.year_of.value;
		var strWeekly = null;
		
		if(document.form_.is_weekly){
			if(document.form_.is_weekly.checked)
				strWeekly = "1";
			else
				strWeekly = "";
		}
		
		var objCOAInput = document.getElementById("sal_periods");
		
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
								 "&year_of="+strYear+"&is_weekly="+strWeekly;

		this.processRequest(strURL);
}

///////////////////////////////////////// End of collapse and expand filter ////////////////////
</script>
<%
	String strErrMsg = null;
	String strTemp = null;
	
	String strTemp2 = null;
	String strPayrollPeriod  = null;
	String strDateFrom = null;
	String strDateTo = null;
	String strHasWeekly = null;
	
	boolean bolProceed = true;
	boolean	showHeader = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolHasTeam = false;
	boolean bolHasInternal = false;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
//add security here.
/**
if (WI.fillTextValue("print_page").length() > 0){
  if(WI.fillTextValue("format").equals("2")){%>
	<jsp:forward page="./hdmf_remittance_print2.jsp" />
  <%}else{%>
    <jsp:forward page="./hdmf_remittance_print.jsp" />
<% 
return;}
}
**/
	String strTemp = WI.fillTextValue("format");
if (WI.fillTextValue("print_page").length() > 0){
  if(strTemp.equals("2")){%>
	<jsp:forward page="./hdmf_remittance_print2.jsp" />
  <%}else if(strTemp.equals("3")){%>
	<jsp:forward page="./hdmf_remittance_print3.jsp" />
  <%}else{%>
    <jsp:forward page="./hdmf_remittance_print.jsp" />
<% 
return;}
}



try	{
		strTemp = (String)request.getSession(false).getAttribute("userId");
		if(strTemp != null && strTemp.equals("bricks"))
			bolShowAll = true;
	
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Remittances-HDMF Premium","hdmf_monthly.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolHasInternal = (readPropFile.getImageFileExtn("HAS_INTERNAL","0")).equals("1");		
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"hdmf_monthly.jsp");
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

Vector vRetResult = null;
PReDTRME prEdtrME = new PReDTRME();
Vector vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
PRRemittance PRRemit = new PRRemittance(request);
PRTransmittal transmit = new PRTransmittal(request);

double dTemp  = 0d;
double dLineTotal  = 0d;
double dGrandEE = 0d;
double dGrandER = 0d;
double dGrandTotal = 0d;

String strFilename = null;
String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
String[] astrPtFt = {"PART-TIME","FULL-TIME"};
String[] astrRemarks = {"A", "B", "C", "D", "E", ""};
int i = 0;
	if(WI.fillTextValue("generate").length() > 0){
 		strFilename = transmit.HDMFTransmittal(dbOP);
		if(strFilename == null)
			strErrMsg = transmit.getErrMsg();
		else
			strErrMsg = "File Creation successful<br>" + WI.getStrValue(transmit.getErrMsg(),"");
	}

if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.HDMFMonthlyPremium(dbOP);
	if(vRetResult == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		iSearchResult = PRRemit.getSearchCount();
	}
}

if(strErrMsg == null) 
strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="./hdmf_monthly.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr  bgcolor="#A49A6A">
			<td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
			PAYROLL : PAG-IBIG PREMIUM MONTHLY REMITTANCES PAGE ::::</strong></font></td>
		</tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
	
	<tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">Salary Period</td>
      <td width="77%">
	  	<strong><label id="sal_periods">
			<select name="sal_period_index" style="font-weight:bold;font-size:11px">
          <%

			String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};
	 		strTemp = WI.fillTextValue("sal_period_index");		
			for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
				if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
					strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
					strTemp2 += "Whole Month";
				}else{
					strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
					strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
				}
				if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
					strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
					strDateFrom = (String)vSalaryPeriod.elementAt(i + 1);
					strDateTo = (String)vSalaryPeriod.elementAt(i + 2) ;
				
		 %>
			<option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
				
          		<%}else{%>
          	<option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          		<%}//end of if condition.
		 	}//end of for loop.%>
		 %>
        </select>
		</label>
        </strong>
		<%
			strTemp = WI.fillTextValue("is_monthly");
			if(strTemp.compareTo("1") == 0) 
				strTemp = " checked";
			else	
				strTemp = "";
		%>
        <input type="checkbox" name="is_monthly" value="1"  <%=strTemp%> />
        <font size="1">( Check if Monthly Transaction )</font>
		</td>
    </tr>
    
    	
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td><select name="pt_ft" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select></td>
    </tr>	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td><select name="employee_category" onChange="ReloadPage();">                    
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("employee_category").equals("0")){%>
		  <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>          
          <%}else if (WI.fillTextValue("employee_category").equals("1")){%>
		  <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>          
          <%}else{%>
		  <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>          
          <%}%>
        </select> </td>
    </tr>
	<%}%>
    
      <tr>
      <td height="24">&nbsp;</td>
      <td>Employer name </td>
      <td>
			<select name="employer_index" onChange="ReloadPage();">
			<%
			String strEmployer = WI.fillTextValue("employer_index");
			boolean bolIsDefEmployer = false;
			java.sql.ResultSet rs = null;
			strTemp = "select employer_index,employer_name,is_default from pr_employer_profile where is_del = 0 order by is_default desc";
			rs = dbOP.executeQuery(strTemp);
			while(rs.next()){
				strTemp = rs.getString(1);
				if(strEmployer.length() == 0 || strEmployer.equals(strTemp)) {
					strErrMsg = " selected";
					if(rs.getInt(3) == 1)
						bolIsDefEmployer = true;
					if(strEmployer.length() == 0)
						strEmployer = strTemp;
				}
				else	
					strErrMsg = "";
					
			%>			<option value="<%=strTemp%>" <%=strErrMsg%>><%=rs.getString(2)%></option>
			<%}
			rs.close();
			%>
			</select>			</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> 
			<!--
			<select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%//=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
			</select> 
			-->
			<select name="c_index" onChange="ReloadPage();">
        <option value="">N/A</option>
<%  
if(bolIsDefEmployer)
	strTemp = " from college where is_del= 0 and not exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index <>"+strEmployer+")";
else
	strTemp = " from college where is_del= 0 and exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index ="+strEmployer+")";
%>
        <%=dbOP.loadCombo("c_index","c_name", strTemp,strCollegeIndex,false)%>
      </select>			</td>
    </tr>
     <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td><!-- <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%//if ((strCollegeIndex.length() == 0)){%>
          <%//=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0", WI.fillTextValue("d_index"),false)%> 
          <%//}else if (strCollegeIndex.length() > 0){%>
          <%//=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%//}%>
        </select> 
				-->
        <select name="d_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <% 
				if(bolIsDefEmployer)
					strTemp = " from department where is_del= 0 " +
										" and not exists(select * from pr_employer_mapping " +
										"   where pr_employer_mapping.d_index = department.d_index " +
										"   and employer_index <> " + strEmployer + ")";
				else
					strTemp = " from department where is_del= 0 " +
										" and exists(select * from pr_employer_mapping " +
										"   where pr_employer_mapping.d_index = department.d_index " +
										"   and employer_index = " + strEmployer + ")";
				if ((strCollegeIndex.length() == 0))
					strTemp += " and (c_index = 0 or c_index is null) ";
				else
					strTemp += " and c_index = " + strCollegeIndex;
				%>
          <%=dbOP.loadCombo("d_index","d_name", strTemp,WI.fillTextValue("d_index"),false)%>
        </select></td>
    </tr>
 		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>      </td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = "";
				if(WI.fillTextValue("inc_resigned").length() > 0)
					strTemp = " checked";
			%>
      <td colspan="2"><input type="checkbox" name="inc_resigned" value="1" <%=strTemp%>>
      include resigned employees in report</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = "";
				if(WI.fillTextValue("show_adjusted").length() > 0)
					strTemp = " checked";
			%>			
      <td colspan="2"><input type="checkbox" name="show_adjusted" value="1" <%=strTemp%> onChange="SearchEmployee();">
show adjusted contribution </td>
    </tr>
		
		<%
 		if(bolHasInternal){
			strTemp = WI.fillTextValue("show_internal");
			if(strTemp.length() > 0)
				strTemp = "checked";
			else	
				strTemp = "";
		%>		
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><input type="checkbox" name="show_internal" value="1" <%=strTemp%>>
      show internal</td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
		<%
			strTemp = WI.fillTextValue("view_all");
			if(strTemp.length() > 0)
				strTemp = "checked";
			else	
				strTemp = "";
		%>				
      <td colspan="2"><input type="checkbox" name="view_all" value="1" <%=strTemp%>>show result in single page</td>
    </tr>
	
	<tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = "";
				if(WI.fillTextValue("by_dept").length() > 0)
					strTemp = " checked";
			%>			
      <td colspan="2"><input type="checkbox" name="by_dept" value="1" <%=strTemp%>>show by department</td>
    </tr>

    <tr>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font>			</td>
    </tr>
    <tr> 
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0 ){%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%if(strSchCode.startsWith("TSUN") || strSchCode.startsWith("TAMIYA") || strSchCode.startsWith("EAC") || 
				strSchCode.startsWith("CIT") || bolShowAll){%>
		<tr>
      <td height="18">&nbsp;</td>
      <td colspan="2"><div onClick="showBranch('branch6');swapFolder('folder6')">
          <img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
          <b><font color="#0000FF">Pag ibig Transmittal</font></b></div>
        <span class="branch" id="branch6">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
						<%
							strTemp = WI.fillTextValue("branch_code");
						%>					
            <td>Branch Code&nbsp;				
              <input type="text" class="textbox" name="branch_code" value="<%=WI.getStrValue(strTemp,"64")%>" size="3" maxlength="2"></td>
						<%
							strTemp = WI.fillTextValue("pay_type");
						%>
            <td>Pay Type 
              <select name="pay_type">
                <option value="MC" selected>MC</option>
                <%if (strTemp.equals("ST")){%>
                <option value="ST" selected>ST</option>
                <%}else{%>
                <option value="ST">ST</option>
                <%}%>
                <%if (strTemp.equals("HL")){%>
                <option value="HL" selected>HL</option>
                <%}else{%>
                <option value="HL">HL</option>
                <%}%>
              </select></td>
            <td>&nbsp;</td>
          </tr>
					
          <tr>
            <td width="36%"><input type="button" name="proceed_btn2" value=" GENERATE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
					onClick="javascript:Generate();">
					<%
						strTemp = "";
						if(WI.fillTextValue("use_id").length() > 0)
							strTemp = " checked";
					%>
          <input type="checkbox" name="use_id" value="1" <%=strTemp%>>show Employee ID
				</td>						
            <%if(strFilename != null && strFilename.length() > 0){
				if(strFilename.endsWith(".xls"))
					strFilename = ".xls";
				else	
					strFilename = ".txt";
			%>
						<td width="28%">&nbsp;
						<a href="../../../../download/hdmf_premium<%=strFilename%>" target="_blank">
							<img src="../../../../images/download.gif" width="72" height="27" border="0"></a>						</td>
            <td width="36%"><a href="javascript:PrintCover()"> </a><font size="1">&nbsp;</font></td>
						<%}%>						
          </tr>
        </table>
      </span></td>
    </tr>
		<%}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td>Signatory name :</td>
			<%
				strTemp = WI.fillTextValue("signatory");
				if(strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Finance Manager ",7);
				if(strTemp == null || strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Payroll Officer",7);
			%>			
      <td><input type="text" name="signatory" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td width="2%" height="18">&nbsp;</td>
      <td width="18%">Designation :</td>
			<%
				strTemp = WI.fillTextValue("designation");
				if(strTemp.length() == 0){
					if(strSchCode.startsWith("CGH"))
						strTemp = "PAYROLL OFFICER";
					else if(strSchCode.startsWith("TSUNEISHI"))
						strTemp = "HR STAFF";
					else
						strTemp = "FINANCE MANAGER";
				}				
			%>
      <td width="80%"><input type="text" name="designation" class="textbox" value="<%=strTemp%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
	  <%
	  	strTemp = WI.fillTextValue("format");
	  %>
      <td height="18" colspan="3"><div align="right">
	  Print format
	  <select name="format">
		<option value="1">Format 1</option>
		<%if(strTemp.equals("2")){%>
		<option selected value="2">Format 2</option>
		<%}else{%>
		<option value="2">Format 2</option>
		<%}%>
	  </select>
	  </div></td>
    </tr>
    <tr> 
      <td height="18" colspan="3"><div align="right"><font size="2"> Number of Employees / rows Per 
          Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 5; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
    <%	
	if(WI.fillTextValue("view_all").length() == 0)	{
	int iPageCount = iSearchResult/PRRemit.defSearchSize;		
	if(iSearchResult % PRRemit.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr> 
      <td colspan="3"><div align="right"><font size="2">Jump To page: 
          <select name="jumpto" onChange="SearchEmployee();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          </font></div></td>
    </tr>
	<%}
	}%>
  </table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="9">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="9"><div align="center"><strong>PAG-IBIG  PREMIUM REMITTANCES <br>
          <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
  </tr>
  <tr>
    <td colspan="9" class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  <tr>
    <td rowspan="2" align="center" class="thinborderBOTTOMLEFT">TIN</td>
    <td rowspan="2" class="thinborderBOTTOMLEFT"><div align="center">DATE OF BIRTH / PAG-IBIG NO.</div></td>
    <td height="19" colspan="3" align="center" class="thinborderBOTTOMLEFT">NAME OF &nbsp;EMPLOYEES</td>
    <td colspan="3" align="center" class="thinborderBOTTOMLEFT">CONTRIBUTIONS</td>
    <td rowspan="2" align="center" class="thinborderBOTTOMLEFTRIGHT">REMARKS</td>
    </tr>
  <tr>
    <td height="27" align="center" class="thinborderBOTTOMLEFT">FAMILY NAME</td>
    <td align="center" class="thinborderBOTTOMLEFT">FIRST NAME</td>
    <td align="center" class="thinborderBOTTOMLEFT">MIDDLE NAME</td>
    <td align="center" class="thinborderBOTTOMLEFT">EMPLOYEE</td>
    <td align="center" class="thinborderBOTTOMLEFT">EMPLOYER</td>
    <td align="center" class="thinborderBOTTOMLEFT">TOTAL</td>
  </tr>
  <%int iCount = 1;
  for(i = 1; i < vRetResult.size();i+=16,iCount++){
 	 dLineTotal = 0d;
  %>
  
  	<%
		if(WI.fillTextValue("by_dept").length() > 0 ){
			if(showHeader){
				showHeader = false;
	%>
  	<tr>
		<td colspan="9" height="23" class="thinborderBOTTOMLEFTRIGHT">&nbsp;
			<font size="1">
				<strong><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"","",(String)vRetResult.elementAt(i+8))%></strong>
			</font>
		</td>
	</tr>
			<%}   
		}%>
		
	<%
		if( i+16 < vRetResult.size() ){
			if( !((String)vRetResult.elementAt(i+1)).equals((String)vRetResult.elementAt(i+17))  
					|| !((String)vRetResult.elementAt(i+2)).equals((String)vRetResult.elementAt(i+18)) )
				showHeader = true;
		}			
	%>
	
  <tr>
    <%
		strTemp = (String)vRetResult.elementAt(i+13);
	%>	
    <td width="11%" height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%
		strTemp = (String)vRetResult.elementAt(i+12);
		if(strTemp == null || strTemp.length() == 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14),"");
	%>
    <td width="9%" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <td width="12%" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
    <td width="19%" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+4)).toUpperCase()%></td>
    <td width="12%" class="thinborderBOTTOMLEFT">&nbsp;<%=(WI.getStrValue((String)vRetResult.elementAt(i+5))).toUpperCase()%></td>
    <% 
			strTemp = (String)vRetResult.elementAt(i+10);		
		%>
    <td width="8%" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
	<% 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dGrandEE += dTemp;		
		dLineTotal += dTemp;		
	%>
	<% strTemp = (String)vRetResult.elementAt(i+11);%>
    <td width="9%" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
	<% 
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+11),",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dGrandER += dTemp;		
		dLineTotal += dTemp;
		dGrandTotal += dLineTotal;		
	%>	
    <td width="10%" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
	<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15),"5");
	%>	
    <td width="10%" class="thinborderBOTTOMLEFTRIGHT"><strong>&nbsp;</strong></td>
    </tr>
  <%}%>
	<%if(WI.fillTextValue("view_all").length() > 0)	{%>
  <tr>
    <td height="24" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td colspan="4" align="right" class="thinborderBOTTOM"><strong>GRAND TOTAL : </strong></td>
    <td align="right" valign="bottom" class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGrandEE,true)%>&nbsp;</strong></span></td>
    <td align="right" valign="bottom" class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGrandER,true)%>&nbsp;</strong></span></td>
    <td align="right" valign="bottom" class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;</strong></span></td>
    <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
	<%}%>
</table>
<%} // if (vRetResult != null && vRetResult.size() > 0 )%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">
	<input type="hidden" name="generate">		
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>