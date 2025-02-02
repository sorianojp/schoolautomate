<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance, payroll.PRTransmittal, payroll.PReDTRME" %>
<%
WebInterface WI = new WebInterface(request);
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
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
    TABLE.thinborder {
    border-top: solid 1px #0000FF;
    border-right: solid 1px #0000FF;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }

    TD.thinborder {
    border-left: solid 1px #0000FF;
    border-bottom: solid 1px #0000FF;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

</style>
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function Generate()
{
	document.form_.generate.value = "1";
	SearchEmployee();
}
function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_pg.value = "1";
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
							 "&year_of="+strYear+"&is_weekly="+strWeekly+"&onchange=ReloadPage()";

	this.processRequest(strURL);
}

///////////////////////////////////////// End of collapse and expand filter ////////////////////
</script>
<%

	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	String strTemp2 = null;
	String strPayrollPeriod  = null;
	String strDateFrom = null;
	String strDateTo = null;
	String strHasWeekly = null;
	
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolHasTeam = false;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	String strTemp = WI.fillTextValue("format");
	
//add security here.
/**
if (WI.fillTextValue("print_pg").length() > 0){
  if(WI.fillTextValue("format").equals("2")){%>
	<jsp:forward page="./hdmf_loans_remittance_print.jsp" />
  <%}else{%>
    <jsp:forward page="./hdmf_loans_remittance_print2.jsp" />
<% 
return;}
}
**/

if (WI.fillTextValue("print_page").length() > 0){
  if(strTemp.equals("2")){%>
	<jsp:forward page="./hdmf_loans_remittance_print2.jsp" />
  <%}else if(strTemp.equals("3")){%>
	<jsp:forward page="./hdmf_loans_remittance_print3.jsp" />
  <%}else{%>
    <jsp:forward page="./hdmf_loans_remittance_print.jsp" />
<% 
return;}
}


try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Remittances-Pagibig Loans","hdmf_loans_remittance.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"hdmf_loans_remittance.jsp");
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

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
String[] astrPtFt = {"PART-TIME","FULL-TIME"};
String[] astrRemarks = {"A", "B", "C", "D", "E", ""};
String[] astrMeaning = {"Resigned/Separated", "Deceased", "Retired", "On Leave", "Others", ""};
String strCodeIndex = WI.fillTextValue("code_index");
String[] astrPayType = {"MC", "ST", "HL"};
String strLoanName = null;
String strFilename = null;
  if(strCodeIndex.length() > 0){
	 strLoanName = dbOP.mapOneToOther("ret_loan_code","code_index",WI.fillTextValue("code_index"),
									 "loan_name","");
  }
int i = 0;


	if(WI.fillTextValue("generate").length() > 0){
 		strFilename = transmit.PagibigLoanTransmittal(dbOP);
		if(strFilename == null)
			strErrMsg = transmit.getErrMsg();
		else
			strErrMsg = "File Creation successful<br>" + WI.getStrValue(transmit.getErrMsg(),"");
	}
if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.HDMFMonthlyLoan(dbOP);
	if(vRetResult == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		iSearchResult = PRRemit.getSearchCount();
	}
}

boolean bolSearchMultipleLoan = false;
if(WI.fillTextValue("sel_multiple").length() > 0) 
	bolSearchMultipleLoan = true;

if(strErrMsg == null) 
	strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="./hdmf_loans_remittance.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr  bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : PAG-IBIG LOANS MONTHLY REMITTANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3"><font size="1"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="23" colspan="3"><strong><%=strErrMsg%></strong></td>
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
%>      </select></td>
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
<%if(!bolSearchMultipleLoan) {%> 		
    <tr>
      <td height="25">&nbsp;</td>
      <td>Loan Name<br>
	  <font size="1"><input type="checkbox" name="sel_multiple" value="checked" onClick="document.form_.searchEmployee.value='';document.form_.submit();"> View Multiple Selection</font> </td>
	  <%
	  	strCodeIndex  = WI.fillTextValue("code_index");
	  %>
      <td><font size="1"><strong>
        <select name="code_index" onChange="ReloadPage();">
			<option value="">All</option>
          <%=dbOP.loadCombo("code_index","loan_name, loan_code",
		                    " from ret_loan_code where is_valid = 1 and loan_type = 4",
							strCodeIndex ,false)%>
        </select>
      </strong></font>
	  </td>
    </tr>
<%}else{
Vector vLoanList = new Vector();
String strSQLQuery = "select code_index, loan_code, loan_name from ret_loan_code where is_valid = 1 and loan_type = 4 order by loan_code";
int iMaxDisp = 0;
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vLoanList.addElement(rs.getString(1));//[0] code_index
	vLoanList.addElement(rs.getString(3)+" ("+rs.getString(2)+")");//[2] loan_name(loan_code)
}
rs.close();
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Loan Name<br>
	  <font size="1"><input type="checkbox" name="sel_multiple" value="checked" checked="checked" onClick="document.form_.searchEmployee.value='';document.form_.submit();"> View Multiple Selection</font> </td>
      <td>
	  		<table width="75%" cellpadding="0" cellspacing="0" border="0" class="thinborder" bgcolor="#DDDDDD">
			<%while(vLoanList.size() > 0) {
				strTemp = WI.fillTextValue("code_index"+iMaxDisp);
				if(strTemp.length() > 0) 
					strTemp = " checked";
				else	
					strTemp = "";
			%>
				<tr>
					<td width="49%" style="font-size:10px;" class="thinborder">&nbsp;<input type="checkbox" name="code_index<%=iMaxDisp++%>" value="<%=vLoanList.remove(0)%>" <%=strTemp%>> <%=vLoanList.remove(0)%></td>
					<td width="49%" style="font-size:10px;" class="thinborder">&nbsp;<%if(vLoanList.size() > 0) {
						strTemp = WI.fillTextValue("code_index"+iMaxDisp);
						if(strTemp.length() > 0) 
							strTemp = " checked";
						else	
							strTemp = "";
					%>
						<input type="checkbox" name="code_index<%=iMaxDisp++%>" value="<%=vLoanList.remove(0)%>" <%=strTemp%>> <%=vLoanList.remove(0)%>
					<%}%>
					</td>
				</tr>
			<%}%>
			<input type="hidden" name="sel_mutiple_max_disp" value="<%=iMaxDisp%>">
			</table>
	  </td>
    </tr>
<%}if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>
      </td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
			<%
				strTemp = "";
				if(WI.fillTextValue("inc_resigned").length() > 0)
					strTemp = " checked";
			%>			
      <td><input type="checkbox" name="inc_resigned" value="1" <%=strTemp%>>
      include resigned employees in report</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#000000"></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0 ){%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		
    <tr>
      <td height="18">&nbsp;</td>
      <td colspan="2"><div onClick="showBranch('branch6');swapFolder('folder6')">
          <img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
          <b><font color="#0000FF">Pag-ibig Loan Transmittal(Unionbank format only)</font></b></div>
        <span class="branch" id="branch6">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
						<%
							strTemp = WI.fillTextValue("branch_code");
						%>					
            <td width="16%">Branch Code&nbsp;</td>
            <td colspan="3"><input type="text" class="textbox" name="branch_code" value="<%=WI.getStrValue(strTemp)%>" size="5" maxlength="2"></td>
          </tr>
					
          <tr>
            <td>Pay Type            </td>
						<%
							strTemp = WI.fillTextValue("pay_type");
						%>
            <td colspan="3">
						<select name="pay_type">
						<%for(i = 0; i < astrPayType.length;i++){
							if(strTemp.equals(Integer.toString(i))){%>
              <option value="<%=astrPayType[i]%>" selected><%=astrPayType[i]%></option>
 						  <%}else{%>
							<option value="<%=astrPayType[i]%>"><%=astrPayType[i]%></option>
							<%}
							}%>
            </select></td>
          </tr>
		    <td >File Format: &nbsp;&nbsp; </td>
			<td>
				<select name="fileformat" >
					<%if (WI.fillTextValue("fileformat").matches("1|")){%>
						<%if(!strSchCode.startsWith("EAC")){%><option value="1" selected>Format 1</option><%}%>
						<option value="2">Format 2</option>
					<%}else if (WI.fillTextValue("fileformat").equals("2")){%>
						<option value="2" selected>Format 2</option>
						<%if(!strSchCode.startsWith("EAC")){%><option value="1">Format 1</option><%}%>
					<%}%>
				</select>
			</td>
          <tr>
            <td colspan="4">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="2">
				<input type="button" name="proceed_btn2" value=" GENERATE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:Generate();">              
			</td>						
            <%if(strFilename != null && strFilename.length() > 0){%>
				<%
					strTemp = "../../../../download/hdmfloan";
					if(WI.fillTextValue("fileformat").matches("1|")){
						strTemp += ".txt";
					}else if(WI.fillTextValue("fileformat").equals("2")){
						strTemp += ".xls";
					}
				%>	 	
					
				<td width="22%">&nbsp;
					<a href=<%=strTemp%> target="_blank">
						<img src="../../../../images/download.gif" width="72" height="27" border="0">
					</a>
				</td>
				<td width="42%"><a href="javascript:PrintCover()"> </a><font size="1">&nbsp;</font></td>
			<%}%>						
          </tr>
        </table>
      </span></td>
    </tr>
		
    <tr>
      <td width="2%" height="18">&nbsp;</td>
      <td width="17%">Signatory name :</td>
			<%
				strTemp = WI.fillTextValue("signatory");
				if(strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Finance Manager ",7);
				if(strTemp == null || strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Payroll Officer",7);
			%>
      <td width="81%"><input type="text" name="signatory" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>Designation :</td>
			<%
				strTemp = WI.fillTextValue("designation");
				if(strTemp.length() == 0){
					if(strSchCode.startsWith("CGH"))
						strTemp = "PAYROLL OFFICER";
					else
						strTemp = "FINANCE MANAGER";
				}				
			%>			
      <td><input type="text" name="designation" class="textbox" value="<%=strTemp%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    
    <tr>
	<%
		strTemp = WI.fillTextValue("format");
	%>
      <td height="18" colspan="3"><div align="right">
        <div align="right">Print format
          <select name="format">
              <option value="1">Format 1</option>
              <%if(strTemp.equals("2")){%>
              <option selected value="2">Format 2</option>
              <%}else{%>
              <option value="2">Format 2</option>
              <%}%>
            </select>
        </div>
      </div></td>
    </tr>
    <tr> 
      <td height="18" colspan="3"><div align="right"><font size="2"> Number of Employees / rows Per 
          Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 5; i <=50 ; i++) {
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
	<%}%>
  </table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="8">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="8"><div align="center"><strong><%=(WI.getStrValue(strLoanName,"")).toUpperCase()%>  REMITTANCES <br>
          <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
  </tr>
  <tr>
    <td colspan="8" class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  <tr>
    <td rowspan="2" class="thinborderBOTTOMLEFT"><div align="center"><strong>Pag-IBIG ID No.</strong></div></td>
    <td rowspan="2" class="thinborderBOTTOMLEFT"><div align="center"><strong>Promissory Note </strong></div></td>
    <td height="19" colspan="3" class="thinborderBOTTOMLEFT"><div align="center"><strong>NAME OF &nbsp;BORROWER</strong><strong>S</strong></div></td>
    <td rowspan="2" class="thinborderBOTTOMLEFT"><div align="center"><strong>MONTHLY AMORTIZATION</strong></div></td>
    <td rowspan="2" class="thinborderBOTTOMLEFT"><div align="center"><strong>USE CODE </strong></div></td>
    <td rowspan="2" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><strong>REMARKS</strong></div></td>
    </tr>
  <tr>
    <td height="27" class="thinborderBOTTOMLEFT"><div align="center"><strong>FAMILY NAME</strong></div></td>
    <td class="thinborderBOTTOMLEFT"><div align="center"><strong>FIRST NAME</strong></div></td>
    <td class="thinborderBOTTOMLEFT"><div align="center"><strong>MIDDLE NAME</strong></div></td>
    </tr>
  <%int iCount = 1;
  for(i = 1; i < vRetResult.size();i+=20,iCount++){
  %>
  
  <tr>
    <%
		strTemp = (String)vRetResult.elementAt(i+11);
	%>	
    <td width="10%" height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <td width="9%" class="thinborderBOTTOMLEFT"><div align="center">&nbsp;-</div></td>
    <td width="15%" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
    <td width="20%" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+4)).toUpperCase()%></td>
    <td width="14%" class="thinborderBOTTOMLEFT">&nbsp;<%=(WI.getStrValue((String)vRetResult.elementAt(i+5))).toUpperCase()%></td>
    <% 
			strTemp = (String)vRetResult.elementAt(i+10);
			strTemp = CommonUtil.formatFloat(strTemp,true);
		%>
    <td width="12%" class="thinborderBOTTOMLEFT"><div align="right"><%=strTemp%>&nbsp;</div></td>
	<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12),"5");
	%>
    <td width="5%" class="thinborderBOTTOMLEFT"><div align="left"><strong>&nbsp;<%=astrRemarks[Integer.parseInt(strTemp)]%></strong>&nbsp;</div></td>	
    <td width="12%" class="thinborderBOTTOMLEFTRIGHT"><strong>&nbsp;<%=astrMeaning[Integer.parseInt(strTemp)]%></strong></td>
    </tr>
  <%}%>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    </tr>
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
	<input type="hidden" name="generate" value="">
  <input type="hidden" name="print_pg" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>