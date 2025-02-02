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
<title>Leave Summary per Department/office</title>
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
<body onLoad="javascript:window.print();">
<form action="./emp_salary_deductions.jsp" method="post" name="form_">
  <%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td>		
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
		  <td width="27%" rowspan="2" align="center" class="thinborder"><strong>NAME</strong></td> 
			<td width="11%" rowspan="2" align="center" class="thinborder"><strong>UNIT</strong></td>
			<td height="12" colspan="4" align="center" class="thinborder"><strong>DURATION</strong></td>
			<td width="26%" rowspan="2" align="center" class="thinborder"><strong>REMARKS</strong></td>
		</tr>
		<tr>
		  <td width="11%" height="13" align="center" class="thinborder"><strong>FROM</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>TO</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>HRS</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>MIN</strong></td>
		</tr>
		<% 
		for (i = 0 ; i < vRetResult.size() ; i+=14) {
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
		  <td class="thinborder"><%=WI.getStrValue(strEmpName,"&nbsp;")%></td>
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
		 <td class="thinborder"><%=WI.getStrValue(strEmpName,"&nbsp;")%></td>
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
		 <td class="thinborder"><%=WI.getStrValue(strEmpName,"&nbsp;")%></td>
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
      <td height="25"  colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td width="10%" height="25">Noted by: </td>
      <td width="36%" height="25">&nbsp;<strong><%=WI.fillTextValue("noted_by")%></strong></td>
      <td width="19%" align="right">Prepared by: &nbsp;</td>
      <td width="35%">&nbsp;<strong><%=WI.fillTextValue("prepared_by")%></strong></td>
    </tr>
  </table>
	<%}%> 
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
