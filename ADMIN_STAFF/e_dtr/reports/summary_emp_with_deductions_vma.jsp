<%@ page language="java" import="utility.*,eDTR.ReportEDTR,java.util.Vector, java.util.Calendar" %>
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
<title>Summary of Employee DTR</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
	document.form_.print_page.value = 1;
	document.form_.submit();
}
function ViewRD(strEmpID)
{
//popup window here. 
	var checkvalue;
	if (document.form_.show_awol.checked) checkvalue =1;
	else checkvalue = 0;
	
	var pgLoc = "./summary_emp_with_awol_detail.jsp?emp_id="+escape(strEmpID)+"&date_fr="+escape(document.form_.date_fr.value)+"&date_to="+escape(document.form_.date_to.value)+"&show_awol="+checkvalue+"&strMonth="+
	 document.form_.strMonth[document.form_.strMonth.selectedIndex].value;
	var win=window.open(pgLoc,"ShowAwolDetails",'width=550,height=400,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewLateDetails(strEmpID, strYear){
//popup window here. 
	var pgLoc = "./summary_emp_late_timein_detail.jsp?show_detail=1&viewRecords=1&emp_id="+escape(strEmpID)+
		"&from_date=" + escape(document.form_.date_fr.value) + "&to_date=" + escape(document.form_.date_to.value) +
		"&month=" + document.form_.strMonth[document.form_.strMonth.selectedIndex].value + 
		"&year="+strYear;
		
	var win=window.open(pgLoc,"ShowLateDetail",'width=550,height=400,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewUTDetails(strUserIndex, strEmpID, strYear){
	var pageLoc = "./summary_emp_undertime_detail.jsp?strUserIndex="+strUserIndex+
	"&strDateFrom="+document.form_.date_fr.value+"&strDateTo="+document.form_.date_to.value+
	"&strMonth="+document.form_.strMonth.value+"&emp_id=" + strEmpID+"&year="+strYear;
	var win=window.open(pageLoc,"ShowUTDetails",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewAwol(strEmpID, strYear)
{
//popup window here. 
	if(document.form_.awol_opt[0].checked)
		strOpt = "0";
	else if (document.form_.awol_opt[1].checked)
		strOpt = "1";
	else
		strOpt = "2";

 	var pgLoc = "./summary_emp_with_awol_detail.jsp?emp_id="+escape(strEmpID)+
	"&date_fr="+escape(document.form_.date_fr.value)+
	"&date_to="+escape(document.form_.date_to.value)+"&awol_opt="+strOpt+
	"&strMonth="+document.form_.strMonth[document.form_.strMonth.selectedIndex].value+
	"&year="+strYear;
	
	var win=window.open(pgLoc,"ShowAWOLDetails",'width=550,height=400,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function updateOptValue(strNewValue){
	if(strNewValue.length == '')
		strNewValue ="2";
	
 	document.form_.awol_opt.value = strNewValue;
}
</script>

<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if(WI.fillTextValue("print_page").equals("1")) {%>
		<jsp:forward page="./summary_emp_with_deductions_vma_print.jsp" />		
	<%return;}
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Reports & Statistics-Summary Emp with Deduction","summary_emp_with_deductions_vma.jsp");
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
														"summary_emp_with_deductions_vma.jsp");	
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
int iDays = 0;
int iHours = 0;
int iMins = 0;
int iRowCount = 0;

double dTemp = 0d;
if(WI.fillTextValue("init_").length() > 0 && WI.fillTextValue("date_fr").length() > 0) {
	//I have to initialize this report.. 
			eDTR.WorkingHour WH = new eDTR.WorkingHour();
			eDTR.ReportEDTRExtn RE = new eDTR.ReportEDTRExtn(request);
			
			String strDateFrom = WI.fillTextValue("date_fr");
			String strDateTo = WI.fillTextValue("date_to");
			strDateFrom = ConversionTable.convertTOSQLDateFormat(strDateFrom);
			if(strDateTo.length() > 0) 
				strDateTo = ConversionTable.convertTOSQLDateFormat(strDateTo);
			else	
				strDateTo = strDateFrom;
			String strSQLQuery = "delete from edtr_no_timelog where awol_date between '"+strDateFrom+"' and '"+strDateTo+"'";
			dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
			
 		 	WH.finalizeAwolForDates(dbOP, request, WI.fillTextValue("date_fr"), WI.fillTextValue("date_to"));
			RE.convertAwolToUndertime(dbOP, request, WI.fillTextValue("date_fr"), WI.fillTextValue("date_to"));
}


ReportEDTR rD = new ReportEDTR(request);
if(WI.fillTextValue("searchEmployee").equals("1")){
	//new eDTR.WorkingHour().populateAwolTable(dbOP, request, false);

	vRetResult = rD.viewDeductionsSummary(dbOP);
	if(vRetResult == null)
		strErrMsg = rD.getErrMsg();
	else
		iSearchResult = rD.getSearchCount();
}

String[] astrMonth = {" Select Month"," January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
%>
<form action="./summary_emp_with_deductions_vma.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF"><strong>:::: 
      SUMMARY OF EMPLOYEES WITH DEDUCTIBLES PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Date</td>
      <td colspan="3"><input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        <font size="1">(leave 'date to' field empty for a specific date)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Month / Year </td>
      <td colspan="3">
			<select name="strMonth">
	  <% 
	  	for (i = 0; i <= 12; ++i) {
	  		if (Integer.parseInt(WI.getStrValue(request.getParameter("strMonth"),"0")) == i) {
	  %>
	  	<option value="<%=i%>" selected><%=astrMonth[i]%></option>	  
	  <%}else{%>
	  	<option value="<%=i%>"><%=astrMonth[i]%></option>
	  <%} 
	  } // end for lop%>		
	  </select> 
		<!--
		<select name="strMonth" onChange="UpdateMonth()">
			<option value="">Select Month</option>
	  <%
	  //int iDefMonth = Integer.parseInt(strMonths);
	  //	for (i = 1; i <= 12; ++i) {
	  //		if (iDefMonth == i)
		//		strTemp = " selected";
		//	else
		//		strTemp = "";
	   %>
	  	<option value="<%//=i%>" <%//=strTemp%>><%//=astrMonth[i]%></option>
	  <%//} // end for lop%>
	  </select> 
		-->
				
		<select name="year_of">
      <%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
    </select>
	  <font size="1">(selecting a month will overwrite date(s) entry)</font></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%" class="fontsize11">Employee ID </td>
      <td width="14%">
				<select name="id_number_con">
				<%=rD.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
			</select>			</td>
      <td width="36%" align="left"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td style="font-size:16px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="init_"> Initialize this report </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Lastname</td>
      <td><select name="lname_con">
          <%=rD.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td align="left"><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td align="left">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Firstname</td>
      <td><select name="fname_con">
          <%=rD.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td align="left"><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td align="left">&nbsp;</td>
    </tr>
	<tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Employee Status</td>
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
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Employment Tenure</td>
      <td colspan="2"> <select name="current_status">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> </select></td>
      <td>&nbsp;</td>
    </tr>
		<%if(strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Employment Category </td>
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
      <td>&nbsp;</td>
    </tr>
		<%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Position&nbsp;</td>
      <td colspan="2"><select name="emp_type_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL = 0 " +
			WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
			" order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select></td>
      <td>&nbsp;</td>
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
      <td width="34%">&nbsp;</td>
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
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Office/Dept filter</td>
      <td colspan="2"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters) </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="4" class="fontsize11">Show : 
				<%
					strTemp = WI.fillTextValue("awol_opt");
 					if(strTemp.equals("0"))
						strTemp2 = " checked";
					else
						strTemp2 = "";
 				%>
				<input type="radio" name="awol_opt" value="0" <%=strTemp2%> onClick="updateOptValue('0')"> Show All Absences
				<%
					if(strTemp.equals("1"))
						strTemp2 = " checked";
					else
						strTemp2 = "";
				%>				
				<input type="radio" name="awol_opt" value="1" <%=strTemp2%> onClick="updateOptValue('1')"> 
				Remove all with Leave
				<%
					if(strTemp.length() == 0 || strTemp.equals("2"))
						strTemp2 = " checked";
					else
						strTemp2 = "";
				%>				
				<input type="radio" name="awol_opt" value="2" <%=strTemp2%> onClick="updateOptValue('2')"> 
				Remove only Leave with pay</td>
    </tr>
    <tr> 
      <td height="19" colspan="5"><hr size="1"></td>
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
      <td colspan="2"><a href="javascript:SearchEmployee();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
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
      <img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
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
      <td  width="2%" height="25" align="center"  class="thinborder">&nbsp;</td>
	   <td  width="10%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE ID</font></strong></td>
      <td width="17%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="22%" align="center" class="thinborder"><strong><font size="1">DIVISION/OFFICE</font></strong></td>
      <td width="18%" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
	  <td width="11%" align="center" class="thinborder"><strong><font size="1">HOURS WORKED</font></strong></td>
      <td width="9%" align="center" class="thinborder"><strong><font size="1">LATES (mins)</font></strong></td>
      <!-- <td width="12%" align="center" class="thinborder"><strong><font size="1">UNDERTIME</font></strong></td>-->
      <td width="11%" align="center" class="thinborder"><strong><font size="1">ABSENCES(days) </font></strong></td>
    </tr>
    <%
		String[] astrConvertGender = {"M","F"};
		for(i = 0 ; i < vRetResult.size(); i +=14){
		%>
    <tr> 
	
      <td height="25" class="thinborder" align="right"><%=++iRowCount%>&nbsp;</td>
	  <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>      
      <%if(vRetResult.elementAt(i + 8) != null) {//outer loop.
	  		  if(vRetResult.elementAt(i + 9) != null) //inner loop.
						strTemp = (String)vRetResult.elementAt(i + 8) + "/ " + (String)vRetResult.elementAt(i + 9);
					else
						strTemp = (String)vRetResult.elementAt(i + 8);					
  		 	}else if(vRetResult.elementAt(i + 9) != null){//outer loop else
				 	strTemp = (String)vRetResult.elementAt(i + 9);
			  }%> 
      <td class="thinborder">&nbsp;<%=strTemp%></td>
	  <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></td>
	    <td align="right" class="thinborder">
			<%
				dTemp =  Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 13),"0"));
				if(dTemp > 0)
					strTemp = CommonUtil.formatFloat(dTemp,false );	
				else
					strTemp = "";				
			%>	
			<%=strTemp%>  &nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 10), false);
				if(strTemp.equals("0"))
					strTemp = "";

				iDays = 0;
				iHours = 0;
				iMins = 0;
				
				iMins = (int)Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 10),"0"));
				//iMins = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 10),"0"));
				//System.out.println("iMIns : " + (String)vRetResult.elementAt(i + 10));		
				//iDays = iMins/480; //1 day is 8hrs as instructed by mis iren of EAC. sul03112013
//				iMins = iMins%480;	
//				iHours  = iMins/60;
//				iMins = iMins%60;
//				
				strTemp = "";
//				if(iDays > 0)
//					strTemp += " " + iDays + ((iDays == 1)? " day":" days");
//				if(iHours > 0)
//					strTemp += " " + iHours + ((iHours == 1)? " hour":" hours");
				if(iMins > 0){
					strTemp = "" + iMins;
					//strTemp +=  " " + iMins + ((iMins == 1)? " min":" mins");		
				}
				
			%>	
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "")%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 11), false);
				if(strTemp.equals("0"))
					strTemp = "";
				iDays = 0;
				iHours = 0;
				iMins = 0;
				
				iMins = (int)Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 11),"0"));						
				iDays = iMins/480;//1 day is 8hrs as instructed by mis iren of EAC. sul03112013
				iMins = iMins%480;	
				iHours  = iMins/60;
				iMins = iMins%60;
				
				strTemp = "";
				if(iDays > 0)
					strTemp +=  " " + iDays + ((iDays == 1)? " day":" days");
				if(iHours > 0)
					strTemp +=  " " + iHours + ((iHours == 1)? " hour":" hours");
				if(iMins > 0)
					strTemp +=  " " + iMins + ((iMins == 1)? " min":" mins");	
					
			%>	
     <!-- <td align="right" class="thinborder">
			<a href="javascript:ViewUTDetails('<%=(String)vRetResult.elementAt(i)%>',
																				'<%=(String)vRetResult.elementAt(i+1)%>', 
																				'<%=WI.fillTextValue("year_of")%>')"%>
																				<%=WI.getStrValue(strTemp, "")%></a>&nbsp;</td>-->
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 12), false);
				if(strTemp.equals("0"))
					strTemp = "";	
					
				iDays = 0;
				iHours = 0;
				iMins = 0;
				
				dTemp = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 12),"0")) / 8;						
				//iDays = iHours/8;//1 day is 8hrs as instructed by mis iren of EAC. sul03112013
				//iHours = iHours%8;					
				
				dTemp = Double.parseDouble(CommonUtil.formatFloat(dTemp,false));
				strTemp = "";
				//if(iDays > 0)
//					strTemp +=  " " + iDays + ((iDays == 1)? " day":" days");
//				if(iHours > 0)
//					strTemp +=  " " + iHours + ((iHours == 1)? " hour":" hours");
				if(dTemp > 0){
					//strTemp +=  " " + dTemp + ((dTemp <= 1)? " day":" days");			
					strTemp = CommonUtil.formatFloat(dTemp,false);
				}
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25">&nbsp;</td>
      <td width="31%">&nbsp;</td>
    </tr>
  </table>
<%}//only if vRetResult not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
<input type="hidden" name="print_page" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>