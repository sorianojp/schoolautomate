<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, 
																payroll.PReDTRME, payroll.OvertimeMgmt, eDTR.OverTime" buffer="16kb"%>
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
<title>Deduction Report</title>
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
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }	
	
  TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
  }
	
	TD.thinborderBOTTOMTOP {
    border-bottom: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
  }

	TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
  }
  TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }
	
	TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: 11px;
  }
  
	TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 11px;
  }
	
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
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
//add security here.


if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./psheet_grouped_wup_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Sheet (By Office)","psheet_grouped_wup.jsp");
								
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
														"psheet_grouped_wup.jsp");
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
	Vector vGroupDedNames = null;
	PReDTRME prEdtrME = new PReDTRME();
	OverTime overtime = new OverTime();
	PayrollSheet RptPSheet = new PayrollSheet(request);
	OvertimeMgmt otMgmt = new OvertimeMgmt();
	String strPayrollPeriod  = null;
	String strTemp2 = null;
	String strHourlyRate = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dDailyRate = 0d;
//	int iStart = 29; // this is where the null fields start
	int iFieldCount = 75;
	int iNumGroupDed = 0;
	int iEmpCount = 1;
	String strDateFrom = null;
	String strDateTo = null;
	String strBorder = "";
	

	double dBasic = 0d;
	double dTemp = 0d;
	double dLineTotal = 0d;
	double dTotalOTAmount = 0d;
		
	Vector vRows = null;
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

	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;
	Vector vOTDetail = null;
	Vector vSalDetail = null;
//	Vector vLateUtDetail = null;
	Vector vOTTypes = null;
	Vector vOTType = null;//my variable.sul
	Vector vOTGroupName = overtime.operateOnOvertimeGrouping(dbOP,request,4);//group names
	Vector vOTGroup = overtime.operateOnOTGroupTypeMapping(dbOP,request,4);
	Vector vOTNoGroup = overtime.operateOnOTGroupTypeMapping(dbOP,request,5);	
	Vector vOTGroupList = new Vector(); //holds the index and amount of ot w/ group  ->[type_index][amount][type_index][amount]
	Vector vOTNoGroupList = new Vector();//holds the index and amount of ot w/o group->[type_index][amount][type_index][amount]
	Vector vTemp = null;
	Vector vGroupDedPerEmp = null;
	
	Vector vAdjTypes = null;
	Vector vEmpOT = null;
	Vector vEmpAdjust = null;
	Vector vContributions = null;
 	String strDeanName = null;
	double dOtherEarn = 0d;
	double dOtherDed  = 0d;
	String strUserIndex = null;
	int iIndex = 0;
	int iIndexOf = -1;
	int iOTCounter = 0;
	if(vOTGroupName != null && vOTGroupName.size() > 0)
			iOTCounter = vOTGroupName.size()/3;
	if(vOTNoGroup != null && vOTNoGroup.size() > 0)
			iOTCounter += vOTNoGroup.size()/3;	

	boolean bolShowHeader = true; 	
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
	boolean bolShowBorder = false;
	int i = 0;
	vRetResult = RptPSheet.getPSheetItems(dbOP);	
 	if(vRetResult == null)
		strErrMsg = RptPSheet.getErrMsg();
	else{
		vRows = (Vector)vRetResult.elementAt(0);
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);		
		
		vEarnDedCols = (Vector)vRetResult.elementAt(3);			
		if(WI.fillTextValue("hide_overtime").equals("1"))
			vOTTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, true);			
		else
			vOTTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "1");
			//System.out.println("vOTTypes " + vOTTypes);
		
		if(WI.fillTextValue("hide_adjustment").equals("1"))
			vAdjTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, false);			
		else
			vAdjTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "0");
			
		vContributions = RptPSheet.checkPSheetContributions(dbOP, request, WI.fillTextValue("sal_period_index"));
		
		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size() - 2;

		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size() - 1;		

		if (vEarnDedCols != null && vEarnDedCols.size() > 0)
			iEarnDedCount = vEarnDedCols.size()- 1;
			
		iSearchResult = RptPSheet.getSearchCount();		
	}

	String[] astrContributions = {"1", "1", "1", "1", "1"};
	// 0 = sss_amt
	// 1 = philhealth_amt
	// 2 = pag_ibig
	// 3 = gsis_ps
  // 4 = peraa
	
	
	if(WI.fillTextValue("hide_contributions").equals("1") && vContributions != null){
		for(i = 0; i < vContributions.size(); i++)
			astrContributions[i] = (String)vContributions.elementAt(i);
	}	
	
	double[] adEarningTotal = new double[iEarnColCount];
	double[] adDeductTotal = new double[iDedColCount];	
	double[] adEarnDedTotal = new double[iEarnDedCount];
	String[] astrSalaryBase = {"Monthly Rate", "Daily Rate", "Hourly Rate"};

	if(WI.fillTextValue("c_index").length() > 0){
		strDeanName = dbOP.mapOneToOther("college","c_index",WI.fillTextValue("c_index"),"dean_name","");
	}

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body onLoad="javascript:CopyTeamName();">
<form name="form_" 	method="post" action="psheet_grouped_wup.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr > 
			<td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
			PAYROLL: DEDUCTIONS PAGE :::: </strong></font></td>
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
	<tr> 
      <td height="24">&nbsp;</td>
      <td>Group Deduction Name</td>
      <td> <select name="group_name">
         	 <option value="">ALL</option>
         		<%=dbOP.loadCombo("distinct group_name","group_name"," from PR_GROUP_MAP " +
				" where is_deduction = 1 order by PR_GROUP_MAP.group_name",WI.fillTextValue("group_name"), false)%>
		 	</select> </td>
    </tr>
	<tr><td>&nbsp;</td></tr>
	
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
	  <%
	  	strTemp = WI.fillTextValue("employee_category");
	  %>
	   <select name="employee_category" onChange="ReloadPage();"> 
	   	 <option value="" <%=strTemp.equals("")?"selected":"" %> >All</option>  
	   	 <option value="0" <%=strTemp.equals("0")?"selected":"" %> >Non-Teaching</option>
		 <option value="1" <%=strTemp.equals("1")?"selected":"" %> >Teaching</option>		
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
    <tr> 
      <td height="10">&nbsp;</td>
      <td>Salary base </td>
			<%
				strTemp = WI.fillTextValue("salary_base");				
			%>
      <td>			
			<select name="salary_base" onChange="ReloadPage();">
				<option value="">ALL</option>
				<%for(i = 0; i < astrSalaryBase.length; i++){
					if(strTemp.equals(Integer.toString(i))){%>        
        <option value="<%=i%>" selected><%=astrSalaryBase[i]%></option>
				<%}else{%>
        <option value="<%=i%>"><%=astrSalaryBase[i]%></option>
        <%}
				}%>
      </select>
			<!--
			<select name="salary_base" onChange="ReloadPage();">
        <option value="0">Monthly rate</option>
        <%if (WI.fillTextValue("salary_base").equals("1")){%>
        <option value="1" selected>Daily Rate</option>
        <option value="2">Hourly Rate</option>
        <%} else if (WI.fillTextValue("salary_base").equals("2")){%>
        <option value="1">Daily Rate</option>
        <option value="2" selected>Hourly Rate</option>
        <%}else{%>
        <option value="1">Daily Rate</option>
        <option value="2">Hourly Rate</option>
        <%}%>
      </select>
			-->			</td>
    </tr>
	
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Show option </td>
			<%
				strTemp = WI.fillTextValue("is_resigned");
			%>			
      <td height="10"><select name="is_resigned" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%if (strTemp.equals("1")){%>
        <option value="1" selected>Show only resigned for the period</option>
        <option value="2">Show only with valid status</option>
        <%}else if (strTemp.equals("2")){%>
        <option value="1">Show only resigned for the period</option>
        <option value="2"selected>Show only with valid status</option>
        <%}else{%>
        <option value="1">Show only resigned for the period</option>
        <option value="2">Show only with valid status</option>
        <%}%>
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
    <%if(bolHasConfidential){%>
		<tr>
      <td height="10">&nbsp;</td>
      <td height="10">Process Option </td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";				
			%>
      <td height="10"><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
		<%}%>		
		<%if(bolShowALL || iAccessLevel == 2){%>
		<tr>
		  <td height="10">&nbsp;</td>
		  <td>Employee ID </td>
		  <td><input name="emp_id" type="text" size="16"maxlength="128" value="<%=WI.fillTextValue("emp_id")%>"
											onKeyUp="AjaxMapName(1);"><label id="coa_info"></label>	</td>
	  </tr>
		<%}%>	
    
	 
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
	<tr><td>&nbsp;</td></tr>
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
      <td height="10">&nbsp;</td>
 	  <% 	  
	  if (vRows != null && vRows.size() > 0 ){%>
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
  <% if (vRows != null && vRows.size() > 0 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
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
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
		<%		 
			//grouped ded
			vGroupDedNames = RptPSheet.getGroupedDeduction(dbOP);
			if(vGroupDedNames != null && vGroupDedNames.size() > 0){
				iNumGroupDed = vGroupDedNames.size();
				strTemp = " colspan='"+(iNumGroupDed+5)+"' ";
			}else{
				strTemp = " colspan='3' ";
			}	
			
		//this are the variables use for subtotal
		double[] adDeductSubTotal = new double[iNumGroupDed];
		double[] adDeductOverallTotal = new double[iNumGroupDed];
		double dOtherDedSubTotal = 0d;
		double dOtherDedOverallTotal = 0d;		
		double dLineDedSubTotal = 0d;
		double dLineDedOverallTotal = 0d;
		//end of var for subtotal
			
		%>
				
      <td height="60" <%=strTemp%> align="center" ><strong><font color="#0000FF"> DEDUCTIONS FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>	 
    </tr>	
    <tr>     
	  <td width="8%">&nbsp;</td>		
      <td width="17%" height="33"  align="center" class="thinborderBOTTOM">NAME 
        OF EMPLOYEE </td> 
		<!--<td width="19%" height="33"  align="center" class="thinborderBOTTOM">DEPARTMENT/COLLEGE  </td>      -->
			<%				
			for(iIndex = 0;iIndex < iNumGroupDed; iIndex++){
				strTemp = (String)vGroupDedNames.elementAt(iIndex);
			%>
	  <td width="11%"  align="center" class="thinborderBOTTOM"><%=strTemp%></td>
      		<%}//end of for loop%>			
      <!--<td width="23%"  align="center" class="thinborderBOTTOM">OTHER DED.</td>  -->
	  <td width="45%"  align="center" class="thinborderBOTTOM">TOTAL DED</td>     
    </tr>   
	
	
    <% 
    for(i = 0; i < vRows.size();){	
		if(bolShowHeader){
		bolShowHeader = false;
	  %>
    <tr>
	<!--<td width="3%">&nbsp;</td>-->  
      <%
			if(bolIsSchool)
				strTemp = "College : ";
			else
				strTemp = "Division : ";
				
			strTemp2 = (String)vRows.elementAt(i+63);
			strTemp2 = WI.getStrValue(strTemp2," Dept : ","","");
	
			if(bolShowBorder)
				strBorder =  "class='thinborderBottomLeftRight'";
			else
				strBorder = "class='NoBorder'";
			%>
		<!--	
      <td height="26" colspan="40" valign="bottom" class='thinborderBOTTOM'><strong>&nbsp;<%=(WI.getStrValue((String)vRows.elementAt(i+62),strTemp, strTemp2, strTemp2)).toUpperCase()%></strong> </td>
    </tr>-->
    <%}%>
		
    <%for(; i < vRows.size();){
			if(i % 150 == iFieldCount){
				strBgColor = "#EEEEEE";
			}else{
				strBgColor = "";
			}	
 	strUserIndex = (String)vRows.elementAt(i+1);
	if(i+iFieldCount+1 < vRows.size()){
		if(i == 0){
		strCurColl = WI.getStrValue((String)vRows.elementAt(i+2),"0");		
		strCurDept = WI.getStrValue((String)vRows.elementAt(i+3),"0");	
		}
		strNextColl = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 2),"0");		
		strNextDept = WI.getStrValue((String)vRows.elementAt(i + iFieldCount + 3),"0");		
 		
		if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
			bolShowHeader = true;
		} 
	}
	
  	//vEarnings = (Vector)vRows.elementAt(i+53);
	vDeductions = (Vector)vRows.elementAt(i+54);
		
	vSalDetail = (Vector)vRows.elementAt(i+55); 
	//vOTDetail = (Vector)vRows.elementAt(i+56);
	vEarnDed  = (Vector)vRows.elementAt(i+59);		
	//vLateUtDetail = (Vector)vRows.elementAt(i+64);
	//vEmpOT = (Vector)vRows.elementAt(i+65);
	//vOTType = (Vector)vRows.elementAt(i+65);	
	//vEmpAdjust = (Vector)vRows.elementAt(i+67);
	dLineTotal = 0d;
	dBasic = 0d;
 	dOtherEarn = 0d;
	dOtherDed = 0d;
	dTotalOTAmount = 0d;
	
	//call me here getDeductionDetails
	vGroupDedPerEmp = RptPSheet.getDeductionDetails(dbOP,strUserIndex,WI.fillTextValue("sal_period_index"));
	
		%>
    <tr>   
	<td width="8%" align="right"><%=iEmpCount++%>&nbsp;</td>
      <td height="24" valign="bottom" nowrap class='thinborder'>&nbsp;<%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 4)%></td>     
							
		 <%
				// department
				strTemp = null;
				if((String)vRows.elementAt(i + 62)== null || (String)vRows.elementAt(i + 63)== null){
					strTemp = " ";			
				  }else{
					strTemp = " - ";
				  }
			%>	
     						 
	   <!--<td height="24" valign="bottom" nowrap class='thinborder'>&nbsp;<%=WI.getStrValue((String)vRows.elementAt(i + 62),"")%><%=strTemp%><%=WI.getStrValue((String)vRows.elementAt(i + 63),"")%></td> -->
      <%
	  //map group ded here	  
	  for(iCols = 0;iCols < iNumGroupDed; iCols ++){	  			
				strTemp = (String)vGroupDedNames.elementAt(iCols);//column name				
				iIndexOf = vGroupDedPerEmp.indexOf(strTemp);				
				dTemp = 0d;
				if(iIndexOf < 0)//emp has no such ded
					dTemp = 0d;
				else if(vGroupDedPerEmp.size() > (iIndexOf + 1)){//emp has this ded
					strTemp = (String)vGroupDedPerEmp.elementAt(iIndexOf + 1);//ded_amount
					dTemp = Double.parseDouble(strTemp);
					dLineTotal += dTemp;
					adDeductSubTotal[iCols] += dTemp;
				}									
				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp <= 0)
					strTemp = "0.00";
			%>
      <td align="right" valign="bottom" class='thinborder'><%=strTemp%>&nbsp;</td>
      <%}%>
      <%
	  		
			// this is the other ungrouped deductions. they dont want to see other ded, ingon gretchen 02012013
			//strTemp = (String)vDeductions.elementAt(0);
//			dTemp = Double.parseDouble(strTemp);
//			dOtherDed += dTemp;
//			
//			// misc_deduction
//			strTemp = (String)vRows.elementAt(i + 45); 
//			strTemp = WI.getStrValue(strTemp,"0");
//			strTemp = ConversionTable.replaceString(strTemp,",","");
//			dOtherDed += Double.parseDouble(strTemp);				
//
//			dLineTotal += dOtherDed;
//			strTemp = CommonUtil.formatFloat(dOtherDed,true);
//			if(dOtherDed <= 0d)
//				strTemp = "";
//				
//			dOtherDedSubTotal += dOtherDed;	
//			dLineDedSubTotal  += dLineTotal;				
	  %>
      <!--<td width="23%" align="right" valign="bottom" class='thinborder'><%=strTemp%>&nbsp;</td>--><!-- oehter ded -->     
	  <td width="45%" align="right" valign="bottom" class='thinborderBottomLeftRight'><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
	  <!-- TOTAL ded -->
    </tr>
    <% 
     i = i + iFieldCount;  	
	 if(i < vRows.size()){
		 strCurColl = WI.getStrValue((String)vRows.elementAt(i+2),"0");
		 strCurDept = WI.getStrValue((String)vRows.elementAt(i+3),"0");
	 }	 
  	 
	if(bolShowHeader){
		break;
	}

  %>
    <%}//end for loop %>
    <%
		//print sub total here
		 %>
		 
		 <!-- hide the whole <tr> because not by dept.only aphabetical order -->
		<!-- <tr> -->  
	 <!--<td>&nbsp;</td>-->
     <!-- <td width="14%" height="33"  align="center" class="thinborder"><strong>Dept. total</strong>&nbsp; </td>      
			<%				
			for(iIndex = 0;iIndex < iNumGroupDed; iIndex++){				
			%>
      			<td width="7%"  align="right" class="thinborder"><strong><%=CommonUtil.formatFloat(adDeductSubTotal[iIndex],true)%>&nbsp;</strong></td>
      		<%
			adDeductSubTotal[iIndex] = 0d;
			}//end of for loop%>			
      <td width="23%"  align="right" class="thinborder"><strong><%=CommonUtil.formatFloat(dOtherDedSubTotal,true)%>&nbsp;</strong></td>  
	  <td width="23%"  align="right" class="thinborderBOTTOMLEFTRIGHT"><strong><%=CommonUtil.formatFloat(dLineDedSubTotal,true)%>&nbsp;</strong></td>     
    </tr> 
	-->
	
	 <%
	 	dOtherDedSubTotal = 0d;
		dLineDedSubTotal = 0d;
	 }// end outer for loop... for office name
		%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>	
  </table>
  <input type="hidden" name="is_grouped" value="">
	<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
	<input type="hidden" name="date_from" value="<%=WI.getStrValue(strDateFrom)%>">  
	<input type="hidden" name="date_to" value="<%=WI.getStrValue(strDateTo)%>">  
  <input type="hidden" name="print_pg" value="">  
	<input type="hidden" name="team_name" value="<%=WI.fillTextValue("team_name")%>">
	 <input type="hidden" name="show_border" value="1"> 
	
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