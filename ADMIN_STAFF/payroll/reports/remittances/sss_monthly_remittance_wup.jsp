<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
WebInterface WI = new WebInterface(request);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Monthly Remmitance Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

 TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size:11px;
		}


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


</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function Generate(strGen){
	document.form_.generate.value = strGen;
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
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
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}

function ForwardTo(){
//	document.form_.forward_ungrouped.value = "1";
//	document.form_.print_pg.value = "";
//	this.SubmitOnce('form_');
location = "./sss_monthly_unsort.jsp?month_of="+document.form_.month_of.value+
					 "&year_of="+document.form_.year_of.value+
					 "&pt_ft="+document.form_.pt_ft.value+
					 "&employee_category="+document.form_.employee_category.value+
					 "&employer_index="+document.form_.employer_index.value+
					 "&c_index="+document.form_.c_index.value+
					 "&d_index="+document.form_.d_index.value+
					 "&searchEmployee=1&grouped=0";
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
///////////////////////////////////////// End of collapse and expand filter ////////////////////


</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance, payroll.PRTransmittal" %>
<%

	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	int iSearchResult = 0;
	String strPayrollPeriod  = null;
	boolean bolHasTeam = false;	
	boolean bolHasInternal = false;
	
	String strFilename = null;
	String strEPFFilename = null;
	String strMCLFilename = null;
	boolean bolShowER = WI.fillTextValue("er").length() > 0;
	boolean bolShowEC = WI.fillTextValue("ec").length() > 0;
	boolean bolShowAll  = false;
	int iMonth = 0;
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./sss_monthly_remittance_wup_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
										"Admin/staff-Payroll-Reports-Remittances-SSS Premium","sss_monthly_remittance_wup.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
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
														"sss_monthly_remittance_wup.jsp");
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
PRRemittance PRRemit = new PRRemittance(request);
PRTransmittal transmit = new PRTransmittal(request);

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
String[] astrPtFt = {"PART-TIME","FULL-TIME"};

double dTemp = 0d;
double dLineTotal = 0d;
double dOfficeTotal = 0d;
double dStatusTotal = 0d;
double dGrandTotal = 0d;

double dEEOfficeTotal = 0d;
double dEROfficeTotal = 0d;
double dECOfficeTotal = 0d;

double dEEStatusTotal = 0d;
double dERStatusTotal = 0d;
double dECStatusTotal = 0d;

double dEEGrandTotal = 0d;
double dERGrandTotal = 0d;
double dECGrandTotal = 0d;


boolean bolPtFtHeader = true;
boolean bolShowHeader = true;

boolean bolPtFtTotal = false;
boolean bolOfficeTotal = false;

String strCurColl = "";
String strNextColl = "";
String strCurDept = "";
String strNextDept = "";
String strEmployer = "";



int i = 0;


if(WI.fillTextValue("generate").length() > 0){
		if(WI.fillTextValue("generate").equals("2"))
	 		strEPFFilename = transmit.SSSPreValidationTransmittal(dbOP);
		else if(WI.fillTextValue("generate").equals("3"))
			strMCLFilename = transmit.SSSMCLTransmittal(dbOP);
		else		
			strFilename = transmit.SSSTransmittal(dbOP);
			
		if(strFilename == null && strEPFFilename == null)
			strErrMsg = transmit.getErrMsg();
		else
			strErrMsg = "File Creation successful<br>" + WI.getStrValue(transmit.getErrMsg(),"");
	}





if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.getAllMonthlyPremium(dbOP,false);
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
<form name="form_" method="post" action="./sss_monthly_remittance_wup.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL: SSS PREMIUM MONTHLY REMITTANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table2">
    <tr>
      <td height="23" colspan="3"><font size="1"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="23" colspan="3"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Month and Year </td>
      <td> <select name="month_of">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select></td>
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
		<%}else{%>
		<input type="hidden" name="employee_category" value="">
    <%}%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employer name </td>
      <td>
			<select name="employer_index" onChange="ReloadPage();">
<%
strEmployer = WI.fillTextValue("employer_index");
boolean bolIsDefEmployer = false;
String strEmployerSSSNo = "";
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
	String strCollegeIndex = WI.fillTextValue("c_index");	

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
      </select>			</td>
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
		
     
		<!--
	  <tr>
      <td height="25">&nbsp;</td>
	  <td>
			<% if (WI.fillTextValue("view_all").equals("1"))
					strTemp = "checked";
				else
					strTemp = "";
			%>
		
	  		<input type="checkbox" name="view_all" value="1" <%=strTemp%>> 
			view all employees	
		</td>
    <tr> -->
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
    </tr>
    
  </table>
	<%if (vRetResult != null && vRetResult.size() > 0 ){	%>
  	 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
		   <tr>
		      <td width="8%" height="18">&nbsp;</td>
			 </tr> 
		    <tr>
      <td width="8%" height="18">&nbsp;</td>
      <td width="92%"> Note: Employees with invalid entries will not be included in the transmittal list. 
			<div onClick="showBranch('branch6');swapFolder('folder6')">
          <img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
          <b><font color="#0000FF">SSS Transmittal</font></b></div>
        <span class="branch" id="branch6">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
						<%
							strTemp = WI.fillTextValue("branch_code");
						%>					
            <td>Code&nbsp;				
            <input type="text" class="textbox" name="branch_code" value="<%=WI.getStrValue(strTemp,"20")%>" size="5" maxlength="2"></td>
            <td colspan="2">&nbsp;</td>
          </tr>
          <tr>
						<%
							strTemp = WI.fillTextValue("sbr_no");
						%>					
            <td colspan="3">Trans/SBR No. 
            <input type="text" class="textbox" name="sbr_no" value="<%=WI.getStrValue(strTemp)%>" size="15"></td>
          </tr>
          <tr>
					<%
						strTemp = WI.fillTextValue("certified_by");
						if(strTemp.length() == 0)
							strTemp = CommonUtil.getNameForAMemberType(dbOP,"Payroll/HR Personnel",7);
						if(strTemp == null || strTemp.length() == 0)
							strTemp = (String)request.getSession(false).getAttribute("first_name");
					%>
            <td colspan="3">Certified by : 
            <input type="text" class="textbox" name="certified_by" value="<%=WI.getStrValue(strTemp,"20")%>" size="64" maxlength="64"></td>
          </tr>
          <tr>
            <td width="36%"><input type="button" name="proceed_btn2" value=" GENERATE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:Generate('1');"></td>						
            <%if(strFilename != null && strFilename.length() > 0){%>
						<td width="22%">&nbsp;
						<a href="../../../../download/nr3001dk.txt" target="_blank">
							<img src="../../../../images/download.gif" width="72" height="27" border="0">						</a>						</td>
           
						<%}%>						
          </tr>
        </table>
      </span> </td>
    </tr>
		
    <%if(strSchCode.startsWith("TSUN") || strSchCode.startsWith("TAMIYA") || 
				strSchCode.startsWith("CIT") || bolShowAll){%>
    <tr>
      <td height="18"></td>
      <td><div onClick="showBranch('branch1');swapFolder('folder1')">
          <img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
          <b><font color="#0000FF">Employee Pre-Validation File</font></b></div>
        <span class="branch" id="branch1">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="50%"><input type="button" name="proceed_btn2" value=" GENERATE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:Generate('2');">
            <%if(strEPFFilename != null && strEPFFilename.length() > 0){%>
						<a href="../../../../download/epf.txt" target="_blank"><img src="../../../../images/download.gif" width="72" height="27" border="0"></a>
						<%}%>						</td>						
						<td width="50%">&nbsp;</td>            
          </tr>
        </table>
      </span> </td>
    </tr>
		<tr>
      <td height="18"></td>
      <td><div onClick="showBranch('branch2');swapFolder('folder2')">
          <img src="../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2">
          <b><font color="#0000FF">SSS MCL </font></b></div>
        <span class="branch" id="branch2">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td>Document #</td>
						<%
							strTemp = WI.fillTextValue("doc_no");
							if(strTemp.length() == 0){
								iMonth = Integer.parseInt(WI.fillTextValue("month_of")) + 1;
								strTemp = Integer.toString(iMonth);
								if(strTemp.length() == 1)
									strTemp = "0" + strTemp;
								strTemp = WI.fillTextValue("year_of") + strTemp;
							}
							
						%>
            <td><input type="text" class="textbox" name="doc_no" value="<%=WI.getStrValue(strTemp)%>" 
						size="8" maxlength="6" onKeyUp="AllowOnlyInteger('form_','doc_no')" 
						onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','doc_no')"
					  onFocus="style.backgroundColor='#D3EBFF'"></td>
          </tr>
          <tr>
            <td>Transmission date</td>
						<%
							strTemp = WI.fillTextValue("transmit_date");
							if(strTemp.length() == 0)
								strTemp = WI.getTodaysDate(1);
						%>
            <td><input name="transmit_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
              <a href="javascript:show_calendar('form_.transmit_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
          </tr>
          <tr>
            <td>Branch Code</td>
						<%
							strTemp = WI.fillTextValue("mcl_branch_code");
						%>
            <td><input type="text" class="textbox" name="mcl_branch_code" value="<%=WI.getStrValue(strTemp)%>" size="5" maxlength="3"></td>
          </tr>
          <tr>
            <td>Locator Code</td>
						<%
							strTemp = WI.fillTextValue("locator_code");
						%>
            <td><input type="text" class="textbox" name="locator_code" value="<%=WI.getStrValue(strTemp)%>" size="5" maxlength="3"></td>
          </tr>
          <tr>
            <td>Payment Order # </td>
						<%
							strTemp = WI.fillTextValue("pay_order_no");
							if(strTemp.length() == 0){
								iMonth = Integer.parseInt(WI.fillTextValue("month_of")) + 1;								
								strTemp = Integer.toString(iMonth);
								if(strTemp.length() == 1)
									strTemp = "0" + strTemp;
								if(strTemp.equals("02"))									
									strTemp = WI.fillTextValue("year_of") + strTemp + "28";
								else
									strTemp = WI.fillTextValue("year_of") + strTemp + "30";
							}							
						%>						
            <td>
            <input type="text" class="textbox" name="pay_order_no" value="<%=WI.getStrValue(strTemp)%>" 
						size="10" maxlength="8" onKeyUp="AllowOnlyInteger('form_','pay_order_no')" 
						onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','pay_order_no')"
					  onFocus="style.backgroundColor='#D3EBFF'"></td>
          </tr>
          <tr>
            <td width="17%"><input type="button" name="proceed_btn2" value=" GENERATE " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:Generate('3');">            </td>						
						<td width="83%">
						<%if(strMCLFilename != null && strMCLFilename.length() > 0){%>
						<a href="../../../../download/sss_mcl.txt" target="_blank"><img src="../../../../images/download.gif" width="72" height="27" border="0"></a>
						<%}%></td>            
          </tr>
        </table>
      </span> </td>
    </tr>		
		<%} // END FOR TSUNEISHI%>
    
	</table>
 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	  	
  	<tr>
      <td width="3%" height="10">&nbsp;</td>	
	  </tr>
	  
	<tr>
      <td width="3%" height="10">&nbsp;</td>
      <td width="13%" height="10">Prepared By</td>
			<%
				strTemp = WI.fillTextValue("prepared_by");
				if(strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Payroll/HR Personnel",7);
				if( strTemp == null || strTemp.length() == 0)
					strTemp = (String)request.getSession(false).getAttribute("first_name");
			%>			
      <td width="84%" height="10">
	  <input type="text" name="prepared_by" maxlength="128" size="32" 
			value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr>
      <td width="2%" height="18">&nbsp;</td>
      <td width="20%">Certified Correct by :</td>
			<%
				strTemp = WI.fillTextValue("certified_by");								
			%>			
      <td width="78%"><input type="text" name="certified_by" class="textbox" value="<%=strTemp%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	
	 <tr>
      <td width="2%" height="18">&nbsp;</td>
      <td width="20%">Noted by :</td>
			<%
				strTemp = WI.fillTextValue("noted_by");								
			%>			
      <td width="78%"><input type="text" name="noted_by" class="textbox" value="<%=strTemp%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
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
  
    <tr> 
      <td height="24" colspan="23"> <%
		int iPageCount = iSearchResult/PRRemit.defSearchSize;
		if(iSearchResult % PRRemit.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="SearchEmployee();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( i =1; i<= iPageCount; ++i )
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
          <%}%>
        </div></td>
    </tr>
  </table>
 
  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
  <tr>
  	<td colspan="6">
		<table width="100%" cellpadding="0" cellspacing="0" border="0" align="center" style="display:none" id="table_header">
			<tr>
				<td colspan="3" align="right">&nbsp;</td>				
			</td>	
			<tr>
				<td width="25%" align="right">&nbsp;				</td>
				<td width="50%"  align="center">
					<div style=" width:500px">
					  <div style="text-align: left; position: relative; display: block; width: 70px; height: 70px; margin-left: -360px;"> <img src="../../../../images/logo/<%=strSchCode%>.gif" width="100%" height="100%" style="text-align:left"> </div>
					  <div style=" width: 500px; margin-top: -70px; padding-bottom: 30px;">
							<strong><font size ="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong> <br>
							<font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
							<font size ="1"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> <br>
							<font size ="1">HUMAN RESOURCE DEVELOPMENT DEPARTMENT</font> <br>			
					  </div>
				  </div>				</td>
				<td width="25%" valign="bottom">					
					<font size ="1"><%=WI.getTodaysDate(6)%></font><br /></td>
			</tr>
		</table>
  	</td>
  </tr>
  <tr>
    <td colspan="10"><div align="center"><strong>SSS PREMIUM REMITTANCE <BR/>
		</strong>for the month of <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></div></td>
  </tr>
  <tr>
    <td width="11%" height="18">&nbsp;</td>	
	<td width="2%">&nbsp;</td>
	<td width="20%">&nbsp;</td>
    <td width="19%">&nbsp;</td>
    <td width="6%">&nbsp;</td>
    <td width="11%">&nbsp;</td>	
    <td width="11%">&nbsp;</td>	
    <td width="9%">&nbsp;</td>
  </tr>  
  
   <tr>
  	<td class="thinborderTOPRIGHT">&nbsp;</td>
	<td align="center" class="thinborderTOPRIGHT" colspan="4"><strong>NAME OF MEMBER</strong></td>
	<td align="center" colspan="2" class="thinborderTOPRIGHT">
	<strong>SOCIAL SECURITY</strong></td>
	<td width="9%" align="center" class="thinborderTOPRIGHT">&nbsp;	</td>
	<td width="11%" align="center" class="thinborderTOPRIGHT">&nbsp;	</td>
  </tr>
  
  <tr>
  	<td align="right" class="thinborderBOTTOMRIGHT" height="30"><strong>(SS Number)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong></td>
	<td align="center" class="thinborderTOPBOTTOM">&nbsp;</td>
	<td align="left" class="thinborderTOPBOTTOM"><strong>(Surname)</strong></td>
	<td align="left" class="thinborderTOPBOTTOM"><strong>(Given Name)</strong></td>
	<td align="left" class="thinborderTOPBOTTOMRIGHT"><strong>(MI)</strong></td>
	<td align="center" class="thinborderTOPBOTTOMRIGHT"><strong>EMPLOYEE</strong></td>
	<td width="11%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>EMPLOYER</strong></td>	
	<td align="center" class="thinborderBOTTOMRIGHT"><strong>EC</strong></td>	
	<td align="center" class="thinborderBOTTOMRIGHT"><strong>TOTAL</strong></td>
  </tr>   
  
  <%
  int iCtr = 1;
  for(i = 3; i < vRetResult.size();){
 
  	dEEOfficeTotal = 0d;
  	dEROfficeTotal = 0d;
  	dECOfficeTotal = 0d;
	dOfficeTotal = 0d;
			
  if(bolPtFtHeader){
  	bolPtFtHeader = false;
  }
  
  for(; i < vRetResult.size();){
 	dLineTotal = 0d;			
	
	if(i+20 < vRetResult.size()){
		if(i == 3){
			strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+7),"");		
			strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+8),"");	
		}
		strNextColl = WI.getStrValue((String)vRetResult.elementAt(i+26),"");		
		strNextDept = WI.getStrValue((String)vRetResult.elementAt(i+27),"");		
		// i+9 is for pt ft status
		//if(!((String)vRetResult.elementAt(i+9)).equals((String)vRetResult.elementAt(i+28))){
		if(!(strNextColl+strNextDept).equals(strCurColl+strCurDept)){
			bolPtFtHeader = true;
			bolShowHeader = true;
			bolOfficeTotal = true;
		}
		if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
			bolShowHeader = true;
			bolOfficeTotal = true;
		}
	}
  %>
  
  <tr>
    <td class="thinborderRIGHT" height="20" align="right"><%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	<td  class="NoBorder"  >&nbsp;<%=iCtr++%>.&nbsp;</td>
	<td  class="NoBorder"  >&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%>&nbsp;</td>
	<td  class="NoBorder"  >&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%>&nbsp;</td>
	<td  class="thinborderRIGHT">&nbsp;<%=(WI.getStrValue((String)vRetResult.elementAt(i+5)," ")).charAt(0)%>&nbsp;</td>    
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dEEOfficeTotal+=dTemp;
		dEEStatusTotal+=dTemp;
		dEEGrandTotal += dTemp;
	%>
    <td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dEROfficeTotal+= dTemp;
		dERStatusTotal+= dTemp;
		dERGrandTotal += dTemp;
	%>	
    <td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dECOfficeTotal+=dTemp;		
		dECStatusTotal+=dTemp;
		dECGrandTotal += dTemp;		
	%>	
    <td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>	
	<%
		dOfficeTotal +=dLineTotal;
		dStatusTotal +=dLineTotal;
		dGrandTotal+= dLineTotal;
	%>
    <td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"")%>&nbsp;</font></div></td>
  </tr>
  <% 
  i = i + 19;  	
	 if(i < vRetResult.size()){
		 strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+7),"");
		 strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+8),"");
	 }	 
  	if(bolPtFtHeader || bolShowHeader){
		if(bolPtFtHeader){
			bolPtFtTotal = true;
			bolOfficeTotal = true;
		}
		break;
	}

  }%>
   
  
  <%}// first For loop%>  
  
  <tr>  
    <td colspan="9" class="thinborderTOP">&nbsp;</td>   
  </tr>
  <tr>   
  	 <td colspan="3" height="30"><div align="right">&nbsp;</td>
    <td colspan="2" height="30" align="center" class="thinborderALL"><strong>This page total... </strong></td>
    <td class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dEEGrandTotal,true),"")%>&nbsp;</div></td>
    <td class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dERGrandTotal,true),"")%>&nbsp;</div></td>	
    <td class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dECGrandTotal,true),"")%>&nbsp;</div></td>	
    <td class="thinborderTOPBOTTOMRIGHT" ><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dGrandTotal,true),"")%>&nbsp;</div></td>
  </tr>
</table>
<%} // if (vRetResult != null && vRetResult.size() > 0 )%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table4">
  
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="grouped" value="">  
 <input type="hidden" name="generate">		
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>