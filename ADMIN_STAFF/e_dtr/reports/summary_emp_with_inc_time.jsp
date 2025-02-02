<%@ page language="java" import="utility.*,eDTR.ReportEDTRExtn,java.util.Vector, java.util.Calendar" %>
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
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
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
		<jsp:forward page="./summary_emp_with_deductions_print.jsp" />		
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
								"Admin/staff-eDaily Time Record-Reports & Statistics-Summary Emp Incomplete Work","summary_emp_with_inc_time.jsp");
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
														"summary_emp_with_inc_time.jsp");	
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
String[] astrAMPM = {"AM","PM"};

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
int iCount = 0;
long lTime = 0l;
ReportEDTRExtn rDExtn = new ReportEDTRExtn(request);
if(WI.fillTextValue("searchEmployee").equals("1")){
	//new eDTR.WorkingHour().populateAwolTable(dbOP, request, false);

	vRetResult = rDExtn.searchEmpWithLateUtNoWorkCredit(dbOP, strSchCode);
	if(vRetResult == null)
		strErrMsg = rDExtn.getErrMsg();
	else
		iSearchResult = rDExtn.getSearchCount();
}

String[] astrMonth = {" Select Month"," January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
Vector vEmpDtr = null;
Vector vEmployeeWH = null;
%>
<form action="./summary_emp_with_inc_time.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF"><strong>:::: 
      SUMMARY OF EMPLOYEES WITH DEDUCTIBLES PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Date</td>
      <td colspan="2"><input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
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
      <td colspan="2">
			<select name="month">
	  <% 
	  	for (i = 0; i <= 12; ++i) {
	  		if (Integer.parseInt(WI.getStrValue(request.getParameter("month"),"0")) == i) {
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
				
		<select name="year">
      <%=dbOP.loadComboYear(WI.fillTextValue("year"), 2, 1)%>
    </select>
	  <font size="1">(selecting a month will overwrite date(s) entry)</font></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%" class="fontsize11">Employee ID </td>
      <td width="18%">
				<select name="id_number_con">
				<%=rDExtn.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
			</select>			</td>
      <td width="60%" align="left"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Lastname</td>
      <td><select name="lname_con">
          <%=rDExtn.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td align="left"><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Firstname</td>
      <td><select name="fname_con">
          <%=rDExtn.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
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
    
    
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td width="3%">&nbsp;</td>
    <td width="14%"><span class="fontsize11">Show Option </span></td>
    <td width="83%">&nbsp;</td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="15%">Minutes Late </td>
				<% strTemp = WI.fillTextValue("late_value"); %>
        <td width="19%"><strong>
          <input  value="<%=strTemp%>" name="late_value" type= "text" class="textbox" 
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','late_value')" 
			  onKeyUp="AllowOnlyInteger('form_','late_value')" size="4" maxlength="3">
        </strong></td>
        <td width="13%" align="center">OR </td>
        <td width="17%">Minutes Undertime </td>
				<% strTemp = WI.fillTextValue("undertime_value"); %>
        <td width="36%"><strong>
          <input  value="<%=WI.getStrValue(strTemp)%>" name="undertime_value" type= "text" class="textbox" 
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','undertime_value')" 
			  onKeyUp="AllowOnlyInteger('form_','undertime_value')" size="4" maxlength="3">
        </strong></td>
      </tr>
    </table></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td colspan="2">Note: Entries with zero(0) valid hours worked are shown always. </td>
    </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="9%" class="fontsize11">Sort by</td>
      <td width="24%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=rDExtn.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by1_con">
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
          <%=rDExtn.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by2_con">
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
          <%=rDExtn.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by3_con">
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
      <td height="25" colspan="3" align="right">&nbsp;
			<!--
	    <font size="2">Number of Employees / rows Per 
        Page :</font>
      <select name="num_rec_page">
        <%// int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			//for(i = 10; i <=40 ; i++) {
			//	if ( i == iDefault) {%>
        <option selected value="<%//=i%>"><%//=i%></option>
        <%//}else{%>
        <option value="<%//=i%>"><%//=i%></option>
        <%//}}%>
      </select>
			<a href="javascript:PrintPg();">
      <img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print result</font>	  
			-->	
			</td>
    </tr>
    <tr>
      <td height="25" colspan="3" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">SEARCH
        RESULT</font></strong></td>
    </tr>
    <tr>
      <td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%></b></td>
      <td width="34%" align="right">&nbsp;</td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <%
		String[] astrConvertGender = {"M","F"};		
		for(i = 0 ; i < vRetResult.size(); i +=16){
			vEmpDtr = (Vector)vRetResult.elementAt(i+8);
			
		%>		
    <tr>
      <td height="25" colspan="6"  class="thinborder"><strong>&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%> - (<%=(String)vRetResult.elementAt(i + 1)%>) </strong></td>
    </tr>
    <tr>
      <td width="10%" align="center" class="thinborder">DATE</td>
      <td width="33%" height="25" align="center" class="thinborder">SCHEDULE</td>
      <td width="33%" align="center" class="thinborder">DTR ENTRIES </td>
      <td width="8%" align="center" class="thinborder">LATE</td>
      <td width="8%" align="center" class="thinborder">UNDERTIME</td>
      <td width="8%" align="center" class="thinborder">HOURS WORK </td>
    </tr>
		<%for(iCount = 0 ; iCount < vEmpDtr.size(); iCount +=15){
			vEmployeeWH = (Vector)vEmpDtr.elementAt(iCount+9);
		%>
    <tr>
      <td class="thinborder">&nbsp;<%=(String)vEmpDtr.elementAt(iCount+4)%></td>
		<% 	
			if(vEmployeeWH != null && vEmployeeWH.size() > 0) {
				strTemp = (String)vEmployeeWH.elementAt(3) +  ":"  + 
				CommonUtil.formatMinute((String)vEmployeeWH.elementAt(4)) + " " +
				astrAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(5))] + " - " + (String)vEmployeeWH.elementAt(6)  +
				":"  + CommonUtil.formatMinute((String)vEmployeeWH.elementAt(7))  + " " + 
				astrAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(8))];
				
				if ((String)vEmployeeWH.elementAt(12) != null)
				strTemp += " / " + (String)vEmployeeWH.elementAt(12) +  ":" + 
				CommonUtil.formatMinute((String)vEmployeeWH.elementAt(13)) +
				" " + astrAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(14))] + " - " + 
				(String)vEmployeeWH.elementAt(15) + ":"  + 
				CommonUtil.formatMinute((String)vEmployeeWH.elementAt(16)) +  " " + 
				astrAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(17))];
						 
					if (((String)vEmployeeWH.elementAt(9)).equals("1"))
						strTemp +="(next day)";
			}else{
				strTemp = "&nbsp;";
			}
		%>		
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
			<%
				strTemp = (String)vEmpDtr.elementAt(iCount + 2);				
				lTime = Long.parseLong(strTemp);
				if(lTime > 0l)
					strTemp = WI.formatDateTime(lTime, 2);
				else
					strTemp = "";
				strTemp = WI.getStrValue(strTemp, "&nbsp;");
				
				strTemp2 = (String)vEmpDtr.elementAt(iCount + 3);				
				lTime = Long.parseLong(strTemp2);
				if(lTime > 0l)
					strTemp2 = WI.formatDateTime(lTime, 2);
				else
					strTemp2 = "";
				strTemp2 = WI.getStrValue(strTemp2, "&nbsp;");
			%>
      <td class="thinborder">&nbsp;<%=strTemp%> - <%=strTemp2%></td>
			<%
				strTemp = (String)vEmpDtr.elementAt(iCount + 7);
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
			<%
				strTemp = (String)vEmpDtr.elementAt(iCount + 8);
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
			<%
				strTemp = (String)vEmpDtr.elementAt(iCount + 6);
			%>				
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
    </tr>				
    <%} // end inner for loop for dtr entries with problems%>
		<%}//end of outer for loop to display employee information.%>
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