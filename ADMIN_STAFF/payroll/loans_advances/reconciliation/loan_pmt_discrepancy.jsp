<%
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
<title>Period Loans Reconciliation</title>
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
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

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

function PrintPg(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}

function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
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

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2  = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	String strPayrollPeriod  = null;
	String strHasWeekly = null;
	boolean bolHasConfidential = false;
	boolean bolHasTeam = false;

	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./loan_period_recon_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS-Reports-Period Loans Reconciliation","loan_pmt_discrepancy.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");	
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
														"PAYROLL","LOANS/ADVANCES",request.getRemoteAddr(),
														"loan_pmt_discrepancy.jsp");
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


PReDTRME prEdtrME = new PReDTRME();
Vector vRetResult = null;
PRRetirementLoan RptPay = new PRRetirementLoan(request);
String strCurIndex = null;
String strPrevIndex = null; 

if(WI.fillTextValue("searchEmployee").equals("1")){  
	  vRetResult = RptPay.generateReconciliation(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}else{	
			iSearchResult = RptPay.getSearchCount();
		}
}


if(strErrMsg == null) 
strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="loan_pmt_discrepancy.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center" class="footerDynamic"><strong>:::: 
      PAYROLL: REPORT LOANS RECONCILIATION PAGE ::::</strong></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><strong><font size="1"><a href="../loans_report_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font>&nbsp;&nbsp;<%=strErrMsg%></strong></td>
    </tr>
    

    <tr>
      <td height="24">&nbsp;</td>
      <td>Schedule Date</td>
      <td colspan="3">From
        <input name="date_from" type="text" size="10" maxlength="10"
	  value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onKeyUp="AllowOnlyIntegerExtn('form_','date_from','/');"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_from','/')">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;to
        &nbsp;&nbsp;
        <input name="date_to" type="text" size="10" maxlength="10"
		value="<%=WI.fillTextValue("date_to")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'"
		onKeyUp = "AllowOnlyIntegerExtn('form_','date_to','/')"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_to','/')">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><font color="#000000" ><strong>
        <select name="pt_ft" onChange="ReloadPage();">
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
        </select>
      </strong></font></td>
    </tr>	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
	<%
	// Employee Category is onyl used in schools
	if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3"><select name="employee_category" onChange="ReloadPage();">
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
      </select></td>
    </tr>
	<%}%>
        
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> <select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> 
				<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> 
				</label>			</td>
    </tr>
		
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Office/Dept filter</td>
		  <td><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
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
		<%if(bolHasConfidential){%>
		<tr>
      <td height="10">&nbsp;</td>
      <td height="10">Process Option</td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";
			%>					
      <td height="10" colspan="3"><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
		<%}%>    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Loan Name </td>
      <td colspan="3"><select name="code_index" onChange="ReloadPage();">
        <option value="">All</option>
        <%=dbOP.loadCombo("code_index","loan_name, loan_code",
		                    " from ret_loan_code where is_valid = 1 order by loan_type, loan_code", WI.fillTextValue("code_index") ,false)%>
      </select></td>
    </tr>
    <!--
		<tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_per_employee");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td colspan="4">&nbsp;<input type="checkbox" name="show_per_employee" value="1" <%=strTemp%>> Show show per employee Total</td>
    </tr>
		-->
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%" colspan="3">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <% if(vRetResult != null && vRetResult.size() > 0) {%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="5" align="right"><font><a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print</font></font></td>
    </tr>
    <tr bgcolor="#B9B292" class="thinborder"> 
      <td height="23" colspan="5" align="center"  class="footerDynamic"><strong>LOANS RECONCILIATION  FOR THE PERIOD : <%=WI.getStrValue(strPayrollPeriod,"")%></strong></td>
    </tr>
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td class="thinborder" height="27" align="center">&nbsp;</td>
      <td class="thinborder" align="center"><strong>EMPLOYEE NAME</strong></td>
      <td class="thinborder" align="center"><strong><font size="1">LOAN 
      CODE </font></strong></td>
      <td class="thinborder" align="center"><strong><font size="1">SCHEDULE PAY</font></strong></td>
      <td class="thinborder" align="center"><strong><font size="1">ACTUAL PAID</font></strong></td>
    </tr>
    <% 	//System.out.println("size " +vRetResult.size());	
	int iCount=0;
	for(int i = 0; i < vRetResult.size();){		
	%>
	  <% 	//System.out.println("size " +vRetResult.size());	
		for(; i < vRetResult.size();i += 9){
			 if(i == 0){
		  		strPrevIndex = "";		  		
			 }
			
			strCurIndex = ((String)vRetResult.elementAt(i+1));
		 
			strTemp = (String)vRetResult.elementAt(i+6);
			strTemp = WI.getStrValue(strTemp, "0");
			strTemp = ConversionTable.replaceString(strTemp,",","");
			
			strTemp2 = (String)vRetResult.elementAt(i+8);
			strTemp2 = WI.getStrValue(strTemp2, "0");
			strTemp2 = ConversionTable.replaceString(strTemp2,",","");
			
			if(Double.parseDouble(strTemp) == 0d && Double.parseDouble(strTemp2) == 0d){
				continue;
			}		
	  %>	
		<tr bgcolor="#FFFFFF" class="thinborder">   
		  <%
		  	if(i > 1 && (strCurIndex).equals(strPrevIndex)){
				strTemp = "";	
				strTemp2 = "";
			}else{
				++iCount;				
				strTemp = WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
								(String)vRetResult.elementAt(i+4), 4).toUpperCase();
				strTemp2 = iCount + ".";	
			}			
		  %>		
		  <td height="25" class="thinborder">&nbsp;<%=strTemp2%></td>
		  <td class="thinborder" >&nbsp;<font size="1">&nbsp;<%=strTemp%></font></td>
		  <%
		  	strTemp = (String)vRetResult.elementAt(i+5);
			if(((String)vRetResult.elementAt(i+7)).equals("1"))
				strTemp2 = "int";
			else
				strTemp2 = "";
		  %>		  
		  <td class="thinborder" ><font size="1">&nbsp;<%=strTemp%> <%=WI.getStrValue(strTemp2,"(",")","")%></font></td>
		  <%
		  	strTemp = (String)vRetResult.elementAt(i+8);
			strTemp = CommonUtil.formatFloat(strTemp,true);
		  %>
		  <td align="right" class="thinborder"><font size="1"><%=strTemp%></font>&nbsp;</td>
		  <%
		  	strTemp = (String)vRetResult.elementAt(i+6);
			strTemp = CommonUtil.formatFloat(strTemp,true);
		  %>
		  <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
    </tr>		
  	  <%
		strPrevIndex = (String)vRetResult.elementAt(i+1);
	  } // end of inner for loop%>
    <%
	} // end for loop	
	} // end if vRetResult != null && vRetResult.size() %>
    <tr bgcolor="#FFFFFF" class="thinborder">
      <td height="14" width="4%">&nbsp;</td>
      <td width="36%">&nbsp;</td>
      <td width="18%">&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="14%">&nbsp;</td>
    </tr>	
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>	
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>