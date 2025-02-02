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
<title>MONTHLY MISCELLANEOUS DEDUCTIONS</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
	font-size: 12px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

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

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=301&&has_all=1&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
}

function ajaxLoadEarnings() {
	var strType = document.form_.dType.value;
	var strFilter = document.form_.filter.value;
 	
	var objCOAInput = document.getElementById("earnings_");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=309&&dType="+strType+
							 "&filter="+strFilter+"&sel_name=earning_index&onchange=CopyEarningName()";

	this.processRequest(strURL);
}

function CopyEarningName(){
	if (!document.form_.earning_index) 
		return;
		document.form_.earning_name.value = 
			document.form_.earning_index[document.form_.earning_index.selectedIndex].text;	
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	String strPayrollPeriod = null;
	String strPayEnd = null;
	String strHasWeekly = null;
	boolean bolHasConfidential = false;
	boolean bolHasTeam = false;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./period_earnings_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Monthly Misc. Deductions","period_earnings.jsp");
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
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"period_earnings.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	PReDTRME prEdtrME = new PReDTRME();
	Vector vSalaryPeriod 		= null;//detail of salary period.
	Vector vRetResult = null;
	ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
	String[] astrMonth = {"January","February","March","April","May","June","July",
							"August", "September","October","November","December"};
	String strEarningName = WI.fillTextValue("earning_name");					  
	int i = 0;
	String strSchCode = dbOP.getSchoolIndex();
	String strType = null;
	String[] astrType = {"Misc. Earning","Allowances","Incentives"};
	
	if(WI.fillTextValue("searchEmployee").equals("1")){
		vRetResult = RptPay.getPeriodEarnings(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}else{	
			iSearchResult = RptPay.getSearchCount();
		}
	}

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);

	if(strErrMsg == null) 
	strErrMsg = "";
%>

<body class="bgDynamic" onLoad="javascript:CopyEarningName();">
<form name="form_" method="post" action="./period_earnings.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr  bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : EARNINGS MONTHLY SUMMARY PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="23" colspan="5"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Month and Year </td>
      <td colspan="3"> <select name="month_of">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
				 to 
				 <select name="month_to">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_to"))%> 
        </select>
        - 
        <select name="year_to">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_to"),2,1)%> 
        </select>				</td>
    </tr>
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><select name="pt_ft" onChange="ReloadPage();">
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
        </select> </td>
    </tr>
	<%}%>
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> <select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> 
				<select name="d_index" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> </td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Earning type </td>
			<%
			strType = WI.fillTextValue("dType");
			%>
      <td colspan="3"><font size="1">
        <select name="dType" onChange="ReloadPage();">
          <option value="0">Misc. Earning</option>
					<%for(i = 1; i < astrType.length; i++){
						if(strType.equals(Integer.toString(i))){
						%>
          <option value="<%=i%>" selected><%=astrType[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrType[i]%></option>
          <%}
					}%>
         </select>
      </font></td>
    </tr>
     <tr>
      <td height="25">&nbsp;</td>
      <td> Earning</td>
			<%
				strType = WI.getStrValue(strType, "0");
			%>
      <td colspan="3">
			<label id="earnings_">
			<select name="earning_index" onChange="CopyEarningName();">
      	<%if(strType.equals("0")){%>
						<%=dbOP.loadCombo("earn_ded_index","earn_ded_name", " from preload_earn_ded  " +
						" order by earn_ded_name", WI.fillTextValue("earning_index"), false)%>
				<%}else if(strType.equals("1")){%>
						<%=dbOP.loadCombo("cola_ecola_index","allowance_name, sub_type", " from pr_cola_ecola " +
						" where is_valid = 1 and is_cola = 0 order by allowance_name", WI.fillTextValue("earning_index"), false)%>
				<%}else  if(strType.equals("2")){%>
						<%=dbOP.loadCombo("BENEFIT_INDEX","BENEFIT_NAME,SUB_TYPE", " from HR_BENEFIT_INCENTIVE " +
					 " join HR_PRELOAD_BENEFIT_TYPE on (HR_PRELOAD_BENEFIT_TYPE.BENEFIT_TYPE_INDEX = "+
					 " HR_BENEFIT_INCENTIVE.BENEFIT_TYPE_INDEX) where IS_INCENTIVE = 1 "+
					 " and is_valid = 1 and is_del = 0 order by benefit_name", WI.fillTextValue("earning_index"), false)%>					
			 <%}%>
      </select>
			</label>
        <input name="filter" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  		onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("filter")%>" 
				size="8" maxlength="8" onKeyUp="ajaxLoadEarnings();"></td>
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
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%" colspan="3">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0 ){%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="18"><div align="right"><font size="2"> Number of Employees / rows Per 
          Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 10; i <=30 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/RptPay.defSearchSize;		
	if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr> 
      <td><div align="right"><font size="2">Jump To page: 
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
    <td colspan="5">&nbsp;</td>
  </tr>
  <tr>
		<%
			if(WI.fillTextValue("sal_period_index").length() > 0)
				strTemp = WI.formatDate(strPayEnd, 6);
			else
				strTemp = astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))] +" "+ WI.fillTextValue("year_of");
				
				if(strEarningName.indexOf("()") != -1)
					strEarningName = ConversionTable.replaceString(strEarningName, "()","");
		%>
    <td colspan="5"><div align="center"><strong><%=(WI.getStrValue(strEarningName,"")).toUpperCase()%> <br>
          <%=WI.getStrValue(strTemp)%> </strong></div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="thinborderBOTTOM">&nbsp;</td>
    <td class="thinborderBOTTOM">&nbsp;</td>
    <td class="thinborderBOTTOM">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>  
  <tr>
    <td>&nbsp;</td>
    <td align="center" class="thinborderBOTTOMLEFT">EMPLOYEE ID </td>
    <td height="21" align="center" class="thinborderBOTTOMLEFT">EMPLOYEE NAME </td>
    <td align="center" class="thinborderBOTTOMLEFTRIGHT">AMOUNT</td>
    <td>&nbsp;</td>
  </tr>
  <%int iCount = 1;
  for(i = 0; i < vRetResult.size();i+=15,iCount++){
  %>  
  <tr>
    <td width="10%">&nbsp;</td>
    <td width="13%" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
    <td width="49%" height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
				(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></td>
    <td width="18%" align="right" class="thinborderBOTTOMLEFTRIGHT"><span class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true)%>&nbsp;</span></td>
    <td width="10%">&nbsp;</td>
  </tr>
  <%}// end for loop%>
  <tr>
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
  <input type="hidden" name="print_page" value="">
	<input type="hidden" name="earning_name" value="<%=WI.fillTextValue("earning_name")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>