<%@ page language="java" import="utility.*,eDTR.eDTRGov,java.util.Vector, 
																 java.util.Calendar, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employees with deductibles</title>
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

<style>
	.fontsize11{
		font-size : 11px;
	}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage(){
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee(){
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function PrintPg() {
	document.form_.print_page.value = 1;
	document.form_.submit();
}

function loadSalPeriods() {
		var strMonth = document.form_.month_of.value;
		var strYear = document.form_.year_of.value;
		var strWeekly = null;
		
		if(document.form_.is_weekly)
			strWeekly = document.form_.is_weekly.value;
		var objCOAInput = document.getElementById("sal_periods");
			
		if(strMonth.length == 0){
			objCOAInput.innerHTML = "";
			return;
		}			
		
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		// has_all
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&has_all=1&month_of="+strMonth+
								 "&year_of="+strYear+"&is_weekly="+strWeekly;

		this.processRequest(strURL);
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}	
}

function AddRecord(){
	document.form_.print_page.value = "";
	document.form_.save_data.value ="1";
	document.form_.submit();
} 

function CancelRecord(){
	location = "./late_ut_gov.jsp";
}
 
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if(WI.fillTextValue("print_page").equals("1")) {%>
		<jsp:forward page="./summary_emp_with_deductions_print.jsp" />		
	<%return;}
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strHasWeekly = null;
	boolean bolHasTeam = false;
	
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Reports & Statistics-Summary Emp with Deduction","late_ut_gov.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");										
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"late_ut_gov.jsp");	
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
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String strMonths = WI.fillTextValue("strMonth");
if(strMonths.length() == 0){
	Calendar calendar = Calendar.getInstance();
	strMonths = Integer.toString(calendar.get(Calendar.MONTH) + 1);
}
if(bolIsSchool)
	strTemp = "College";
else
	strTemp = "Division";
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Emp. Status","Emp. Type", strTemp, "Department"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","user_status.status",
															"HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME","c_name","d_name"};

int iSearchResult = 0;
int i = 0;
double dTotal = 0d;
Vector vSalaryPeriod 		= null;//detail of salary period.
PReDTRME prEdtrME = new PReDTRME();
eDTRGov rD = new eDTRGov();

if(WI.fillTextValue("save_data").length() > 0){	
	vRetResult = rD.operateOnLateUtLeaveAdjustment(dbOP, request, 1, strSchCode);
	if(vRetResult == null)
		strErrMsg= rD.getErrMsg();
	else
		strErrMsg = "Operation Successful";
}


if(WI.fillTextValue("searchEmployee").equals("1")){
	//new eDTR.WorkingHour().populateAwolTable(dbOP, request, false);
	vRetResult = rD.operateOnLateUtLeaveAdjustment(dbOP, request, 4, strSchCode);
	if(vRetResult == null)
		strErrMsg = rD.getErrMsg();
	else
		iSearchResult = rD.getSearchCount();
}

vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);

String[] astrMonth = {" January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
%>
<form action="./late_ut_gov.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF"><strong>:::: 
     EMPLOYEES WITH LATE/UNDERTIME PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Adjust from</td>
			<%
				strTemp = WI.fillTextValue("leave_ben_index");
			%>
      <td colspan="2"> <select name="leave_ben_index">
        <%=dbOP.loadCombo("benefit_index","sub_type"," from  hr_benefit_incentive where is_valid = 1" +
						 " and exists(select * from edtr_leave_usage where is_valid = 1 and purpose = 0" +
						 "    and hr_benefit_incentive.benefit_index = edtr_leave_usage.benefit_index) ",strTemp,false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Month / Year</td>
			<%
				strTemp = WI.fillTextValue("month_of");
			%>
      <td colspan="2">			
			<select name="month_of" onChange="loadSalPeriods();">
        <option value="">&nbsp;</option>
        <%for (i = 0; i < astrMonth.length; i++) {
			if (strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=astrMonth[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrMonth[i]%></option>
        <%}
			}%>
      </select>
         
			
      <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
        </select>
        <font size="1">(this option will overwrite the date range encoded above)</font></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">&nbsp;</td>
      <td colspan="2"><label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
				 <option value=""> &nbsp;</option>
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
				//strDateFrom = (String)vSalaryPeriod.elementAt(i + 1);
				//strDateTo = (String)vSalaryPeriod.elementAt(i + 2) ;
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
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%" class="fontsize11">Employee ID</td>
      <td width="17%">
				<select name="id_number_con">
				<%=rD.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
			</select>			</td>
      <td width="61%" align="left"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Lastname</td>
      <td><select name="lname_con">
          <%=rD.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td align="left"><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Firstname</td>
      <td><select name="fname_con">
          <%=rD.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td align="left"><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Emp. Status</td>
      <td colspan="2"> <select name="current_status">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> </select></td>
    </tr>
		<%if(strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Employment Category</td>
			<%
				strTemp = WI.fillTextValue("emp_type_catg");
			%>
      <td colspan="2"><select name="emp_type_catg" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%
				for(i = 0;i < astrCategory.length;i++){
					if(strTemp.equals(Integer.toString(i))) {%>
        <option value="<%=i%>" selected><%=astrCategory[i]%></option>
        <%}else{%>
        <option value="<%=i%>"> <%=astrCategory[i]%></option>
        <%}
							}%>
      </select></td>
    </tr>
		<%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Position</td>
      <td colspan="2"><select name="emp_type_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL = 0 " +
			WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
			" order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
	strTemp = WI.getStrValue(WI.fillTextValue("c_index"),"0");

if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Office/Dept</td>
      <td colspan="2"><select name="d_index">
          <option value="">N/A</option>
          <%
strTemp3 = "";
strTemp3 = WI.fillTextValue("d_index");
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index="+strTemp+" or c_index is null) order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Office/Dept filter</td>
      <td colspan="2"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters) </td>
    </tr>
		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td colspan="2">
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
	  </tr>
		<%}%>
    
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="8%" class="fontsize11">Sort by</td>
      <td width="25%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=rD.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="24%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=rD.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="40%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=rD.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3" align="right">
	    <font size="2">Number of Employees / rows Per 
        Page :</font>
      <select name="num_rec_page">
        <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
        <option selected value="<%=i%>"><%=i%></option>
        <%}else{%>
        <option value="<%=i%>"><%=i%></option>
        <%}}%>
      </select>
			<a href="javascript:PrintPg();">
      <img src="../../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print result</font>	  </td>
    </tr>
    <tr>
      <td height="25" colspan="3" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">SEARCH
        RESULT</font></strong></td>
    </tr>
    <tr>
      <td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%> - Showing(<%=rD.getDisplayRange()%>)</b></td>
      <td width="34%" align="right">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/rD.defSearchSize;
		if(iSearchResult % rD.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
Jump To page:
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
        <%}%>      </td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="8%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE ID</font></strong></td>
      <td width="35%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="27%" align="center" class="thinborder"><strong><font size="1">DEPT/OFFICE</font></strong></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">DATE</font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">TOTAL<br>
      (minutes)</font></strong></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
      </font></td>
    </tr>
    <%

		int iCount = 1;
		Vector vTimeInList = null;
		int j = 0;
		for(i = 0 ; i < vRetResult.size(); i +=20){
			dTotal = 0d;
			vTimeInList = (Vector)vRetResult.elementAt(i+10);
 		%>
    <tr>
		
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td valign="top" class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <%if(vRetResult.elementAt(i + 8) != null) {//outer loop.
	  		  if(vRetResult.elementAt(i + 9) != null) //inner loop.
						strTemp = (String)vRetResult.elementAt(i + 8) + "/ " + (String)vRetResult.elementAt(i + 9);
					else
						strTemp = (String)vRetResult.elementAt(i + 8);					
  		 	}else if(vRetResult.elementAt(i + 9) != null){//outer loop else
				 	strTemp = (String)vRetResult.elementAt(i + 9);
			  }%> 
      <td valign="top" class="thinborder"><%=strTemp%></td>
      <td colspan="3" align="right" class="thinborder">
			<%if(vTimeInList != null && vTimeInList.size() > 0){%>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <%  
 		for (j=0; j < vTimeInList.size() ; j+=10, iCount++){
		%>
			<input type="hidden" name="tin_tout_index_<%=iCount%>" value="<%=vTimeInList.elementAt(j+5)%>" >		
	  	<input type="hidden" name="user_index_<%=iCount%>" value="<%=vTimeInList.elementAt(j)%>" >
			<input type="hidden" name="id_number_<%=iCount%>" value="<%=vRetResult.elementAt(i + 1)%>" >		

		<% 
		strTemp = WI.getStrValue((String)vTimeInList.elementAt(j+8));
		%>	  
    <tr >
      <td width="49%" height="25" class="thinborderNONE" >&nbsp;<%=(String)vTimeInList.elementAt(j+3)%></td>
      <td width="32%" class="thinborderNONE">&nbsp;
		    <input type="text" class="textbox_noborder" value="<%=strTemp%>" size="3"
			maxlength="3"  readonly	name="adjust_total_<%=iCount%>" style="text-align:right">	</td>
    	<td width="19%" align="center" class="thinborderNONE"><input type="checkbox" value="1" name="save_<%=iCount%>"></td>
    </tr>
		<%} //end for loop%>
  </table>
			<%}%>			</td>
    </tr>
    <%}//end of for loop to display employee information.%>
			 <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td width="69%" height="25" align="center">
			<%if(iAccessLevel > 1){%>
 		  <a href="javascript:AddRecord();"><img src="../../../../images/save.gif" width="48" height="28" border="0"></a><font size="1">click to add</font>
			<%}%>
			<a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" width="51" height="26" border="0"></a> <font size="1">click to cancel or go previous</font>
      </td>
    </tr>
  </table>
<%}//only if vRetResult not null
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" class="footerDynamic">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
<input type="hidden" name="print_page" value="0">
<input type="hidden" name="save_data">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>