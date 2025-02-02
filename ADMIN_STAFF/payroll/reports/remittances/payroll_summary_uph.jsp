<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, 
																payroll.PReDTRME, payroll.OvertimeMgmt,payroll.PRSalary" buffer="16kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
  TD.thinborderTOP {
    border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 13px;
  }
	
  TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
  }	
	
  TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
  }
	
	TD.thinborderBOTTOMTOP {
    border-bottom: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
  }

	TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
  }
  TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
  }
	
	TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
  }
  
	TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
  }
	
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
	}
	
	TD.headerthinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>px;
	}
	
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function CopyTeamName(){
	if(!document.form_.team_index)
		return;
		
  if(document.form_.team_index.value)
		document.form_.team_name.value = document.form_.team_index[document.form_.team_index.selectedIndex].text;
  else
  	document.form_.team_name.value = "";
}
</script>

<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	String strUserId = (String)request.getSession(false).getAttribute("userId");	
	boolean bolShowALL = false;
	if(strUserId != null && strUserId.equals("bricks"))
		bolShowALL = true;
	boolean bolHasTeam = false;
	boolean bolHasPeraa = false;
	int iNumOTTypes = 0;
	int iIndexOf  = -1;
//add security here.


if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./payroll_summary_uph_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Summary","payroll_summary_uph.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");

		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");		
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolHasPeraa =(readPropFile.getImageFileExtn("HAS_PERAA","0")).equals("1");
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
														"payroll_summary_uph.jsp");
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	Vector vSalaryDetails = null;
	PReDTRME prEdtrME = new PReDTRME();
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
//	OvertimeMgmt otMgmt = new OvertimeMgmt();
	OvertimeMgmt otMgmt = new OvertimeMgmt(dbOP, WI);
	String strPayrollPeriod  = null;
	String strTemp2 = null;
	String strHourlyRate = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dDailyRate = 0d;
//	int iStart = 29; // this is where the null fields start
	int iFieldCount = 29;
	String strDateFrom = null;
	String strDateTo = null;
	String strBorder = "";

	double dBasic = 0d;
	double dTemp = 0d;
	double dLineTotal = 0d;
	double dTotalOTAmount = 0d;		
	
	Vector vEarnCols = null;
	Vector vDedCols = null;
	Vector vEarnDedCols = null;

	Vector vRetResult = null;
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;
	int iOT = 0;
	String strBgColor = "";

	Vector vOTDetail = otMgmt.operateOnOvertimeType(dbOP,request,4,"1");
	Vector vSalDetail = null;
//	Vector vLateUtDetail = null;
	Vector vOTWithType  = null;

	Vector vEmpOT = null;
	Vector vEmpAdjust = null;
	Vector vAllowances = null;
	Vector vAllowanceNames = null;
	Vector vAllowanceGroupNames = null;
	Vector vEmpAllowance = null;
	Vector vTemp = null;

	
 	String strDeanName = null;
	double dOtherEarn = 0d;
	double dOtherDed  = 0d;
	String strUserIndex = null;
	int iIndex = 0;

	boolean bolShowHeader = true; 	
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
	boolean bolShowBorder = false;
	int i = 0;
	vRetResult = RptPSheet.getPayrollSummary(dbOP,WI);	
 	if(vRetResult == null)
		strErrMsg = RptPSheet.getErrMsg();
	else{		
			
		iSearchResult = RptPSheet.getSearchCount();		
	}
	
	
	String[] astrSalaryBase = {"Monthly Rate", "Daily Rate", "Hourly Rate"};

	if(WI.fillTextValue("c_index").length() > 0){
		strDeanName = dbOP.mapOneToOther("college","c_index",WI.fillTextValue("c_index"),"dean_name","");
	}

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body onLoad="javascript:CopyTeamName();">
<form name="form_" 	method="post" action="payroll_summary_uph.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr > 
			<td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
			PAYROLL: PAYROLL SHEET PAGE :::: </strong></font></td>
		</tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
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
      <td width="77%"><strong>
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			System.out.println("i+=10 " + i);
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
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
        </select>
		</label>
        </strong>
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
		<%if(strSchCode.startsWith("CGH")){%>
			<input type="hidden" name="pt_ft" value="1">
		<%}else{%>
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
		<%}%>
		<%if(bolIsSchool){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td>
	   <select name="employee_category" onChange="ReloadPage();">  
		<%if( WI.fillTextValue("employee_category").equals("1")){%>
			<option selected value="1">Teaching</option>
			<option value="0">Non-Teaching</option>
			<option value="">ALL</option>
		<%}else if( WI.fillTextValue("employee_category").equals("0")){%>
			<option selected value="0">Non-Teaching</option>
			<option value="1">Teaching</option>
			<option value="">ALL</option>
		<%}else{%>
			<option selected value="">ALL</option>
			<option value="1">Teaching</option>
			<option value="0">Non-Teaching</option>
		<%}%>			
       </select></td>
    </tr>
		<%}%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee Type </td>
      <td><select name="status"  onChange="ReloadPage();">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("status"), false)%>
      </select></td>
    </tr>
    <% 	
		String strCollegeIndex = WI.fillTextValue("c_index");	
		%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> <select name="c_index" onChange="document.form_.noted_by.value='';ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td> <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Office/Dept filter</td>
      <td height="10"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
(enter office/dept's first few characters)</td>
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
		  <td height="10">&nbsp;</td>
		  <td>Employee ID </td>
		  <td><input name="emp_id" type="text" size="16"maxlength="128" value="<%=WI.fillTextValue("emp_id")%>"
											onKeyUp="AjaxMapName(1);"><label id="coa_info"></label>	</td>
	  </tr>
		
					
   
  
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="3%" height="10">&nbsp;</td>
      <td width="13%" height="10">&nbsp;</td>
      <td width="84%" height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10"><font size="1">
        <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
        click to display employee list to print.</font></td>
    </tr>
    
    <tr> 
      <td height="10">&nbsp;</td>
 	  <% if (vRetResult != null && vRetResult.size() > 0 ){%>
      <td height="10" colspan="2"><div align="right"><font size="2">Number of Employees / rows Per 
          Page :</font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"25"));
			for(i = 15; i <=30 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a>
          <font size="1">click to print</font></div></td>
	   <%}%>
    </tr>
    
   
  </table>
  <% 
  if (vRetResult != null && vRetResult.size() > 0 ){%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("size_header");
				if(strTemp.length() == 0)
					strTemp = "10";
			%>
      <td height="10" colspan="2" align="right"><font size="2">Font size of header:
          <select name="size_header">	
					<%for(i = 8; i < 13; i++){%>
						<%if(strTemp.equals(Integer.toString(i))){%>
            <option value="<%=i%>" selected><%=i%> px</option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> px</option>
            <%}
						}%>
          </select>
      </font></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("font_size");
				if(strTemp.length() == 0)
					strTemp = "10";
			%>
      <td height="10" colspan="2" align="right"><font size="2">Font size of details:
          <select name="font_size">
            <%for(i = 8; i < 13; i++){%>
            <%if(strTemp.equals(Integer.toString(i))){%>
            <option value="<%=i%>" selected><%=i%> px</option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> px</option>
            <%}
						}%>
          </select>
      </font></td>
    </tr>
    
	
	<tr> 
	  <td height="24" colspan="23"> <%
		int iPageCount = iSearchResult/RptPSheet.defSearchSize;
		if(iSearchResult % RptPSheet.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
		  <select name="jumpto" onChange="ReloadPage();">
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
	  <%}%>
		</div></td>
	</tr>
	
  </table> 
  <table  bgcolor="#FFFFFF" width="150%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="30" colspan="28" align="center" class="thinborderBOTTOM"><strong><font color="#0000FF"> PAYROLL SUMMARY FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
    <tr>
     
		<td width="7%"  align="center" class="headerthinborder">ID</td>			
      <td width="13%" height="33"  align="center" class="headerthinborder">NAME 
        OF EMPLOYEE </td>
    <td width="5%"  align="center" class="headerthinborder">&nbsp;MONTHLY RATE </td>
    <td width="5%"  align="center" class="headerthinborder">&nbsp;DAILY RATE </td>	
	<td width="5%"  align="center" class="headerthinborder">&nbsp;HOURLY RATE </td>	
	<td width="5%"  align="center" class="headerthinborder">&nbsp;TEACHING RATE </td>	
	<td width="5%"  align="center" class="headerthinborder">&nbsp;OVERLOAD RATE </td>
	<td width="5%"  align="center" class="headerthinborder">&nbsp;LOAD UNITS </td>	
	<td width="5%"  align="center" class="headerthinborder">&nbsp;LOAD HOURS </td>	
	<td width="5%"  align="center" class="headerthinborder">&nbsp;REG DAYS </td>	
	 <%
		//OT names here
		if(vOTDetail != null && vOTDetail.size() > 0){
			int iRow = 0;
			for(int j = 0; j < vOTDetail.size(); j+=19){
				strTemp = (String)vOTDetail.elementAt(j+1);
				%>
	  <td width="5%"  align="center" class="headerthinborder"><%=strTemp%></td>
			<%	
			}//end of for loop vOTDetail
		}//end of vOTDetail	
		%>		
    <td width="6%"  align="center" class="headerthinborder">&nbsp;NDF HRS </td>	
	<td width="6%"  align="center" class="headerthinborder">&nbsp;ABSENCES (Days)</td>		  
	<td width="6%"  align="center" class="headerthinborder">&nbsp;TARDINESS(mins) </td>	  
	<td width="6%"  align="center" class="headerthinborder">&nbsp;UNDERTIME(mins) </td>	
	<%
		int iAllowanceCount = 0;
		vAllowances = RptPSheet.getAllowancesForPSheet(dbOP);	
		//allowance
		if(vAllowances != null && vAllowances.size() > 0){			
			vAllowanceGroupNames = (Vector)vAllowances.elementAt(0);
			if(vAllowanceGroupNames != null && vAllowanceGroupNames.size() > 0){
				iAllowanceCount = 	vAllowanceGroupNames.size();
				for(int iCtr2 = 0; iCtr2 < vAllowanceGroupNames.size(); iCtr2+=1){%>
					<td width="6%"  align="center" class="headerthinborder">&nbsp;<%=(String)vAllowanceGroupNames.elementAt(iCtr2)%></td>
				<%}//end of for loop vAllowanceGroupNames
			}//end of vAllowanceGroupNames
		}//end of if vAllowance
	%>	
	<td width="6%"  align="center" class="headerthinborder">&nbsp;CASH CONVERSION (leave) </td>	
    </tr>
    <% 
    for(i = 0; i < vRetResult.size();){
		if(bolShowHeader){
			bolShowHeader = false;
	  %>
    <tr>
      <%
			if(bolIsSchool)
				strTemp = "College : ";
			else
				strTemp = "Division : ";
				
			strTemp2 = (String)vRetResult.elementAt(i+6);
			strTemp2 = WI.getStrValue(strTemp2," Dept : ","","");	
			%>
      <td height="26" colspan="54" valign="bottom"class='thinborderBottomLeftRight' ><strong>&nbsp;<%=(WI.getStrValue((String)vRetResult.elementAt(i+5),strTemp, strTemp2, strTemp2)).toUpperCase()%></strong> </td>
    </tr>
    <%}%>
		
    <%for(; i < vRetResult.size();){
		vEmpAllowance = (Vector)vRetResult.elementAt(i+24);	
		vOTWithType = (Vector)vRetResult.elementAt(i+19);	
		strUserIndex = (String)vRetResult.elementAt(i);
		
		if(i+iFieldCount+1 < vRetResult.size()){
		if(i == 0){
			strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+7),"0");		
			strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+8),"0");	
		}
		strNextColl = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 7),"0");		
		strNextDept = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 8),"0");		
 		
		if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
			bolShowHeader = true;
		} 
	}  	
		%>
    <tr>
	<td valign="bottom" nowrap class='thinborderBOTTOMLEFT' >&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 1))%></td>
	  <td height="24" valign="bottom" nowrap class='thinborder' ><strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4)%></strong></td>
			<%
	  		//monthly rate
			strTemp = (String)vRetResult.elementAt(i + 9);
			strTemp = WI.getStrValue(strTemp, "0");
 			if(strTemp.equals("0"))
				strTemp = "&nbsp;";
  	  %>					
      <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>			
			<%
	  		//rate per hour
				strHourlyRate = "";
				strHourlyRate = WI.getStrValue((String)vRetResult.elementAt(i+11),"0"); 			
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+10),"0");				
			%>			
	 <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
     <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strHourlyRate,true)%>&nbsp;</td>
	 <%
	  		//teahing rate
				strTemp = "";					
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12),"0");
				if(Double.parseDouble(ConversionTable.replaceString(strTemp, ",", "")) > 0){ 	
					strTemp2 = (String)vRetResult.elementAt(i+13); //unit			
					if(strTemp2.equals("1"))//per unit
						strTemp = strTemp + "/unit";
					else
						strTemp = strTemp + "/hr";	
				}else
					strTemp = "";	
				
			%>			
	 <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
	 <%
	  		//overload rate
				strTemp = "";				
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14),"0");
				if(Double.parseDouble(ConversionTable.replaceString(strTemp, ",", "")) > 0){
					strTemp2 = (String)vRetResult.elementAt(i+15); //unit			
					if(strTemp2.equals("1"))//per unit
						strTemp = strTemp + "/unit";
					else
						strTemp = strTemp + "/hr";	
				}else
					strTemp = "";		
			%>			
	 <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>	
	 	<%
		//load UNITS
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+17),"");				
		%>			
	 <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>	
	 <%
		//load hours
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+18),"");				
		%>			
	 <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>	
	 
	 <%
		//REG DAYS
		strTemp = "";//WI.getStrValue((String)vRetResult.elementAt(i+23),"");				
		%>			
	 <td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>	
	 
		
		<%
		//OT hrs here
		if(vOTDetail != null && vOTDetail.size() > 0){
			int iRow = 0;			
			for(int j = 0; j < vOTDetail.size(); j+=19){
				strTemp = (String)vOTDetail.elementAt(j+1);				
				if(vOTWithType != null && vOTWithType.size() > 0){//check if exists in emp ot
					iIndexOf = vOTWithType.indexOf(strTemp); 					
					if(iIndexOf != -1){
						strTemp2 = WI.getStrValue((String)vOTWithType.elementAt(iIndexOf-3),"0");
						if(Double.parseDouble(ConversionTable.replaceString(strTemp2, ",", "")) <= 0)
							strTemp2 = "";
					}else
						strTemp2 = "";	
				}else{
					strTemp2 = otMgmt.getOTManualEncoded((String)vRetResult.elementAt(i), WI.fillTextValue("sal_period_index"), vOTDetail.elementAt(j)+"");
					if( strTemp2 == null )
						strTemp2 = "";
				}
				
				%>
	  <td width="5%"  align="right" class="thinborder"><%=CommonUtil.formatFloat(strTemp2,true)%>&nbsp;</td>
			<%	
			}//end of for loop vOTDetail
		}//end of vOTDetail	
		%>		
		
		 <%
			//ndf
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+20),"0");
			if(Double.parseDouble(ConversionTable.replaceString(strTemp, ",", "")) <= 0)
				strTemp = "";				
		%> 	
    	<td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
		
		 <%
			//absences
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+26),"");	
			if( strTemp == null || strTemp.equals("0") ){
				strTemp = otMgmt.getAbsenceManualEncoded((String)vRetResult.elementAt(i), WI.fillTextValue("sal_period_index"));
				strTemp = ( strTemp == null || strTemp.equals("") ? "0" : strTemp );
			}
			

			if(Double.parseDouble(ConversionTable.replaceString(strTemp, ",", "0")) <= 0)
				strTemp = "";				
		%> 	
    	<td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
		
		 <%
		//LATE
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+21),"");	
		if(Double.parseDouble(ConversionTable.replaceString(strTemp, ",", "")) <= 0)
				strTemp = "";				
		%>			
	 	<td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>	
		<%
		//ut
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+22),"");	
		if(Double.parseDouble(ConversionTable.replaceString(strTemp, ",", "")) <= 0)
				strTemp = "";				
		%>			
	 	<td align="right" valign="bottom" class='thinborder'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>	
	 		
		<%
		//allowance here		
		if(vAllowances != null && vAllowances.size() > 0){			
			vAllowanceNames = (Vector)vAllowances.elementAt(1);			
			if(vAllowanceNames != null && vAllowanceNames.size() > 0){				
				for(int iCtr2 = 0; iCtr2 < vAllowanceNames.size(); iCtr2+=1){	
					dTemp = 0d;				
					vTemp = (Vector)vAllowanceNames.elementAt(iCtr2);
					for(int k = 0; k < vTemp.size(); k++){
						strTemp = "";
						iIndexOf = vEmpAllowance.indexOf((String)vTemp.elementAt(k));						
						if(iIndexOf != -1){ 
							strTemp = WI.getStrValue((String)vEmpAllowance.elementAt(iIndexOf+2),"0");
							dTemp += Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
						}//end of -1						
					}//end of vtemp for loop	
					if(dTemp <= 0)
						strTemp = "";	
					else
						strTemp = CommonUtil.formatFloat(dTemp,true);	
					%>
						<td width="6%"  align="center" class="thinborder">&nbsp;<%=strTemp%></td>
					<%			
				}//end of for loop vAllowanceGroupNames
			}//end of vAllowanceGroupNames
		}//end of if vAllowance
		
	
		//ut
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+27),"");	
		if(Double.parseDouble(ConversionTable.replaceString(strTemp, ",", "")) <= 0)
				strTemp = "";				
		%>			
	 	<td align="right" valign="bottom" class='thinborderBOTTOMLEFTRIGHT'><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>	
	<%
     i = i + iFieldCount;  	
	 if(i < vRetResult.size()){
		 strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+7),"0");
		 strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+8),"0");
	 }	 
  	 
	if(bolShowHeader){
		break;
	}

  %>
    <%}//end for loop %>
    <%
	 }// end outer for loop... for office name
		%>
	</tr>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="is_grouped" value="1">
	<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
	<input type="hidden" name="date_from" value="<%=WI.getStrValue(strDateFrom)%>">  
	<input type="hidden" name="date_to" value="<%=WI.getStrValue(strDateTo)%>">  
  	<input type="hidden" name="print_pg" value="">  
	<input type="hidden" name="team_name" value="<%=WI.fillTextValue("team_name")%>">
	<!-- this ot type is to get the overtime types in the table only
			naka share man gud ang table sa types of adjustment og ang table sa overtime types
			if zero or blank ni. and adjustment types ang i return sa system. 	
			// had to hide this one also... kailangan sad nako mapagawas ang adjustment columns
			<input type="hidden" name="ot_type" value="1">  	
			
	-->
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>