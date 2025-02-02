<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Salary Deductions</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size: 11px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function FocusID() {
	document.form_.emp_id.focus();
}

function ViewPrintDetails(strEmpID, strYear,strYearTo,strSemester,strBenefitIndex){
	var pgLoc = "../leave/leave_apply.jsp?view_only=1&emp_id="+ strEmpID  +
		"&sy_from="+strYear+"&sy_to="+strYearTo+"&semester="+strSemester+"&benefit_index=" + strBenefitIndex;
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PrintPg() {
	document.form_.print_page.value = "1";
	if(document.form_.noted_by.value.length == 0 
		|| document.form_.prepared_by.value.length == 0){
		alert("Please entered noted by and prepared by for printing");
		return;
	}
	this.SubmitOnce('form_');
}

function ReloadPage()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
</script>

<%
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	
//add security hehol.
if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ %>
	<jsp:forward page="./emp_salary_deductions_print.jsp" />
<%}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Leave Application","emp_salary_deductions.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"emp_salary_deductions.jsp");

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
Vector vRetResult = null;
Vector vEmpRec = null; 
Vector vEmpLeaves = null;
Vector vLateUT = null;
Vector vAwol = null;
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Emp. Status","Emp. Type"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","user_status.status","HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME","c_name","d_name"};

int iSearchResult = 0;
ReportEDTRExtn rptLeave = new ReportEDTRExtn(request);
int iAction =  -1;
boolean bolShowName = false;

 if (WI.fillTextValue("view_all").equals("1")) {
	vRetResult = rptLeave.viewSalaryDeductionsAUF(dbOP, request);	
 	
	if (vRetResult == null){
		strErrMsg = rptLeave.getErrMsg();
	}else
		iSearchResult = rptLeave.getSearchCount();
 }
 
 String[] astrMonth = {" Select Month"," January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};
 String strSYFrom = WI.fillTextValue("sy_from");
 String strSYTo = WI.fillTextValue("sy_to");
 String strSemester = WI.fillTextValue("semester");
 
 String[] astrNature = {"Sick Leave", "Maternity Leave","Vacation Leave","Emergency Leave",
 												"Paternity Leave","Bereavement Leave","Others"};

	String strOffice = "";
	Long lUserIndex = null;
	String strSem = null;
	int iLeaves = 0;
	int iHour = 0;
	int iMin = 0;
	double dDuration = 0d;
	double dTotalLeave = 0d;
	int i = 0;
	String strEmpName = null;
	String strUnit = null;
%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./emp_salary_deductions.jsp" method="post" name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
  <tr>
    <td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25" colspan="4" align="center"  bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" size="2" ><strong>:::: 
        eDTR : SALARY DEDUCTIONS SUMMARY ::::</strong></font></td>
    </tr>
  </table>	</td>
  </tr>
  <tr>
    <td><table width="100%" height="403" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Date</td>
      <td><input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
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
      <td class="fontsize11">Month</td>
      <td><select name="strMonth">
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
		<select name="year_of">
      <%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
    </select><font size="1">(selecting a month will overwrite date(s) entry)</font></td>
    </tr>
    
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="16%" class="fontsize11">Employee ID </td>
      <td width="80%">
				<select name="id_number_con">
				<%=rptLeave.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
				</select>
				<input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Lastname</td>
      <td><select name="lname_con">
          <%=rptLeave.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select>
        <input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Firstname</td>
      <td><select name="fname_con">
          <%=rptLeave.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select>
        <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Employee Status</td>
      <td><select name="pt_ft" onChange="ReloadPage();">
        <option value="" selected>All</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part - time</option>
        <option value="1">Full - time</option>
        <%}else if (WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="0">Part - time</option>
        <option value="1" selected>Full - time</option>
        <%}else {%>
        <option value="0">Part - time</option>
        <option value="1">Full - time</option>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Emp. Tenure </td>
      <td> <select name="current_status">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> </select></td>
      </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Position&nbsp;</td>
      <td><select name="emp_type_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select></td>
      </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td><select name="c_index" onChange="ReloadPage();">
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
      <td><select name="d_index">
          <option value="">N/A</option>
          <%
strTemp3 = "";
strTemp3 = WI.fillTextValue("d_index");
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index="+strTemp+" or c_index is null) order by d_name asc",strTemp3, false)%> </select></td>
      </tr>
    <tr>
      <td height="24">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_leave");
				if(strTemp.length() > 0)
					strTemp = " checked";
				else
					strTemp = "";
			%>
      <td colspan="2" class="fontsize11"><input type="checkbox" name="show_leave" value="1" <%=strTemp%>>show leave without pay</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_late_ut");
				if(strTemp.length() > 0)
					strTemp = " checked";
				else
					strTemp = "";
			%>
      <td colspan="2" class="fontsize11"><input type="checkbox" name="show_late_ut" value="1" <%=strTemp%>>
        show late / undertime </td>
    </tr>
    
    <tr>
      <td height="19">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_awol");
				if(strTemp.length() > 0)
					strTemp = " checked";
				else
					strTemp = "";
			%>			
      <td colspan="2" class="fontsize11">
      <input type="checkbox" name="show_awol" value="1" <%=strTemp%>>show awol</td>
      </tr>
    <tr>
      <td height="19">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("optional_awol");
				if(strTemp.length() > 0)
					strTemp = " checked";
				else
					strTemp = "";
			%>						
      <td colspan="2">
        <input type="checkbox" name="optional_awol" value="1" <%=strTemp%>>
        exclude from awol the days with dtr entry</td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      </tr>
    <tr> 
      <td height="19">&nbsp;</td>
      <td><a href="javascript:SearchEmployee();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="9" colspan="3"><hr size="1" ></td>
      </tr>
  </table>
		</td>
  </tr>
</table>

  

		
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable2">
		<tr>
			<td align="right">Number of Employees  Per 
        Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 15; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"><font size="1"></font></a>click to print</td>
		</tr>
		<tr>
		  <td align="right">
    <%		
	int iPageCount = iSearchResult/rptLeave.defSearchSize;		
	if(iSearchResult % rptLeave.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>				
			<font size="2">Jump To page:
          <select name="jumpto" onChange="SearchEmployee();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i ){
			if(i == Integer.parseInt(strTemp) ){%>
					<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%}else{%>
					<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%
				}
			}
			%>
          </select>
		  </font>
			<%}%>
			</td>
	  </tr>		
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td>		
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
		  <td width="28%" rowspan="2" align="center" class="thinborder"><strong>NAME</strong></td> 
			<td width="10%" rowspan="2" align="center" class="thinborder"><strong>UNIT</strong></td>
			<td height="12" colspan="4" align="center" class="thinborder"><strong>DURATION</strong></td>
			<td width="26%" rowspan="2" align="center" class="thinborder"><strong>REMARKS</strong></td>
		</tr>
		<tr>
		  <td width="10%" height="13" align="center" class="thinborder"><strong>FROM</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>TO</strong></td>
			<td width="8%" align="center" class="thinborder"><strong>HRS</strong></td>
			<td width="8%" align="center" class="thinborder"><strong>MIN</strong></td>
		</tr>
		<% //System.out.println("------------------------------" + vRetResult.size());
		for (i = 0 ; i < vRetResult.size() ; i+=14) {
			//System.out.println(vRetResult.elementAt(i+1) + "========================== " +i);
			vEmpLeaves = (Vector)vRetResult.elementAt(i+10);
			vLateUT = (Vector)vRetResult.elementAt(i+11);
			vAwol = (Vector)vRetResult.elementAt(i+12);
			dTotalLeave = 0d;
			bolShowName = true;
			iLeaves = 0;
			if((String)vRetResult.elementAt(i+6) != null)
				strUnit = (String)vRetResult.elementAt(i+6);
			else
				strUnit = (String)vRetResult.elementAt(i+7);			
 			strEmpName = (String)vRetResult.elementAt(i+1) + "<br>";
			strEmpName += WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4), 4);
			
		%>		
		
		<%
		if(vEmpLeaves != null && vEmpLeaves.size() > 0){
		strSem = null;
		for(iLeaves = 0; iLeaves < vEmpLeaves.size(); iLeaves+=21){
			if(bolShowName)
				bolShowName = false;
			else{
				strEmpName = "";
				strUnit = "";
			}
		%>
		<tr>		
		  <td class="thinborder">&nbsp;<%=WI.getStrValue(strEmpName,"&nbsp;")%></td>
	   <td class="thinborder"><%=WI.getStrValue(strUnit,"&nbsp;")%></td> 
		 <td height="25" class="thinborder">&nbsp;<%=(String)vEmpLeaves.elementAt(iLeaves)%></td>
		 <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vEmpLeaves.elementAt(iLeaves+4),"&nbsp;")%></td>
		 <%
		 	strTemp = WI.getStrValue((String)vEmpLeaves.elementAt(iLeaves+17),"0");
			dDuration = Double.parseDouble(strTemp);
			iHour = (int)dDuration;
			iMin = (int)((dDuration  - iHour) * 60);
			dTotalLeave += dDuration;
		 %>
		 <td height="25" align="right" class="thinborder"><%=Integer.toString(iHour)%>&nbsp;</td>
		 <td height="25" align="right" class="thinborder"><%=Integer.toString(iMin)%>&nbsp;</td>
		 <td class="thinborder"><%=WI.getStrValue((String)vEmpLeaves.elementAt(iLeaves+16),"&nbsp;")%></td>
		</tr>
		<%} // end for loop %>
	 <%}%>
 		<%
		if(vLateUT != null && vLateUT.size() > 0){
		for(iLeaves = 0; iLeaves < vLateUT.size(); iLeaves+=4){
			if(bolShowName)
				bolShowName = false;
			else{
				strEmpName = "";
				strUnit = "";
			}
		%>
		<tr>		
		 <td class="thinborder">&nbsp;<%=WI.getStrValue(strEmpName,"&nbsp;")%></td>
	   <td class="thinborder"><%=WI.getStrValue(strUnit,"&nbsp;")%></td> 
		 <td height="25" class="thinborder">&nbsp;<%=(String)vLateUT.elementAt(iLeaves)%></td>
		 <td height="25" class="thinborder">&nbsp;<%=(String)vLateUT.elementAt(iLeaves+1)%></td>
		 <%
		 	strTemp = WI.getStrValue((String)vLateUT.elementAt(iLeaves+2),"0");
			dDuration = Double.parseDouble(strTemp);
			iHour = (int)dDuration/60;
			iMin = (int)(dDuration % 60);
		 %>
		 <td height="25" align="right" class="thinborder"><%=Integer.toString(iHour)%>&nbsp;</td>
		 <td height="25" align="right" class="thinborder"><%=Integer.toString(iMin)%>&nbsp;</td>
		 <td class="thinborder"><%=WI.getStrValue((String)vLateUT.elementAt(iLeaves+3),"&nbsp;")%></td>
		</tr>
		<%} // end for loop %>
	 <%}%>
	 <%
		if(vAwol != null && vAwol.size() > 0){
		for(iLeaves = 0; iLeaves < vAwol.size(); iLeaves+=3){
			if(bolShowName)
				bolShowName = false;
			else{
				strEmpName = "";
				strUnit = "";
			}
		%>
		<tr>		
		 <td class="thinborder">&nbsp;<%=WI.getStrValue(strEmpName,"&nbsp;")%></td>
		 <td class="thinborder"><%=WI.getStrValue(strUnit,"&nbsp;")%></td> 
		 <td height="25" class="thinborder">&nbsp;<%=(String)vAwol.elementAt(iLeaves)%></td>
		 <td height="25" class="thinborder">&nbsp;</td>
		 <%
		 	strTemp = WI.getStrValue((String)vAwol.elementAt(iLeaves+1),"0");
			dDuration = Double.parseDouble(strTemp);
			iHour = (int)dDuration;
			iMin = (int)((dDuration  - iHour) * 60);
			dTotalLeave += dDuration;
 		 %>
		 <td height="25" align="right" class="thinborder"><%=Integer.toString(iHour)%>&nbsp;</td>
		 <td height="25" align="right" class="thinborder"><%=Integer.toString(iMin)%>&nbsp;</td>
		 <td class="thinborder"><%=WI.getStrValue((String)vAwol.elementAt(iLeaves+2),"&nbsp;")%></td>
		</tr>
		<%} // end for loop %>
	 <%}%>
	 
 	<%}// end main for loop%>
	</table>
		
		</td>
  </tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="13%" height="25">Noted by: </td>
			<%
			strTemp = WI.fillTextValue("noted_by");
			%>
      <td width="87%" height="25"><input type="text" size="32" maxlength="64" name="noted_by"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="25">Prepared by: </td>
			<%
			strTemp = WI.fillTextValue("prepared_by");
			%>			
      <td height="25"><input type="text" size="32" maxlength="64" name="prepared_by"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
  </table>
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
	<input type="hidden" name="print_page">
	
	<input type="hidden" name="view_all" value="1">
	<input type="hidden" name="per_college" value="1">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
