<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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


function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}


function PrintPage() {
	document.form_.print_page.value = "1";
	document.form_.submit();
}
</script>

<%
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	
	boolean bolShowSeminar = (WI.fillTextValue("show_seminar").length() > 0);
	boolean bolShowEducation = (WI.fillTextValue("show_education").length() > 0);
	boolean bolShowLengthOfService = (WI.fillTextValue("show_length_of_service").length() > 0);
	boolean bolShowDept    = (WI.fillTextValue("show_department").length() > 0);
	boolean bolShowAddress = (WI.fillTextValue("show_address").length() > 0);
	boolean bolShowLicense = (WI.fillTextValue("show_licenses").length() > 0);
	
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./hr_employee_directory_print.jsp"></jsp:forward>
	<%return;}
	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	boolean bolMyHome = false;

	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-REPORTS AND STATISTICS","hr_employee_directory.jsp");
		
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
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														"hr_employee_directory.jsp");

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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Emp. Status","Emp. Type"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","user_status.status","HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME","c_name","d_name"};

String[] astrCStatus = {"","Single","Married", "Divorced/Separated", "Widow/Widower","Annuled","Living Together"};
String[] astrPTFT    = {"Part-Time", "Full-Time"};

hr.HRStatsReportsExtn hrStatReportExtn = new hr.HRStatsReportsExtn();
Vector vRetResult = null;
int iElemCount = 0;
int iSearchResult = 0;
if(WI.fillTextValue("searchEmployee").length() > 0){
	vRetResult = hrStatReportExtn.getEmployeeDirectory(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hrStatReportExtn.getErrMsg();
	else{
		iElemCount = hrStatReportExtn.getElemCount();
		iSearchResult = hrStatReportExtn.getSearchCount();
	}
}


%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./hr_employee_directory.jsp" method="post" name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
  <tr>
    <td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="772%" height="25" colspan="4" align="center"  bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" size="2" ><strong>:::: 
        EMPLOYEE DIRECTORY PAGE ::::</strong></font></td>
    </tr>
  </table>
	</td>
  </tr>
  <tr>
    <td><table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" class="fontsize11">Employee ID </td>
      <td width="6%">
				<select name="id_number_con">
				<%=hrStatReportExtn.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
				</select>			</td>
      <td width="27%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td width="50%" rowspan="7" valign="top">
	  <%
	  strTemp = WI.fillTextValue("show_seminar");
	  if(strTemp.equals("1"))
	  	strErrMsg = "checked";
	else
		strErrMsg = "";
	  %>
	  <input type="checkbox" name="show_seminar" value="1" <%=strErrMsg%>>Show Seminars/Training<br>
	  <%
	  strTemp = WI.fillTextValue("show_education");
	  if(strTemp.equals("1"))
	  	strErrMsg = "checked";
	else
		strErrMsg = "";
	  %><input type="checkbox" name="show_education" value="1" <%=strErrMsg%>>Show Education<br>
	  <%
	  strTemp = WI.fillTextValue("show_length_of_service");
	  if(strTemp.equals("1"))
	  	strErrMsg = "checked";
	else
		strErrMsg = "";
	  %><input type="checkbox" name="show_length_of_service" value="1" <%=strErrMsg%>>Show Length on Service<br>
	  <%
	  strTemp = WI.fillTextValue("show_department");
	  if(strTemp.equals("1"))
	  	strErrMsg = "checked";
	else
		strErrMsg = "";
	  %><input type="checkbox" name="show_department" value="1" <%=strErrMsg%>>Show Department/Offices<br>
	  <%
	  strTemp = WI.fillTextValue("show_address");
	  if(strTemp.equals("1"))
	  	strErrMsg = "checked";
	else
		strErrMsg = "";
	  %><input type="checkbox" name="show_address" value="1" <%=strErrMsg%>>Show Address<br>
	  
	   <%
	  strTemp = WI.fillTextValue("show_licenses");
	  if(strTemp.equals("1"))
	  	strErrMsg = "checked";
	else
		strErrMsg = "";
	  %><input type="checkbox" name="show_licenses" value="1" <%=strErrMsg%>>Show License(s)
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Lastname</td>
      <td><select name="lname_con">
          <%=hrStatReportExtn.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Firstname</td>
      <td><select name="fname_con">
          <%=hrStatReportExtn.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Emp. Status</td>
      <td colspan="2"> <select name="current_status" style="width:100px;">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> </select></td>
      </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Position&nbsp;</td>
      <td colspan="2"><select name="emp_type_index" style="width:200px;">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select></td>
      </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="2"><select name="c_index" style="width:300px;" onChange="ReloadPage();">
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
      <td colspan="2"><select name="d_index" style="width:300px;">
          <option value="">N/A</option>
          <%
strTemp3 = "";
strTemp3 = WI.fillTextValue("d_index");
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index="+strTemp+" or c_index is null) order by d_name asc",strTemp3, false)%> </select></td>
      </tr>
    
    
    
    
    <tr> 
      <td height="19" colspan="5"><hr size="1"></td>
    </tr>
  </table>
	</td>
  </tr>
  <tr>
    <td><table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="8%" class="fontsize11">Sort by</td>
      <td width="25%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=hrStatReportExtn.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by1_con">
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
          <%=hrStatReportExtn.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by2_con">
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
          <%=hrStatReportExtn.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by3_con">
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
  </table></td>
  </tr>
</table>
<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
	<tr><td align="right">
		<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>
	</td></tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
	<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="6">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(hrStatReportExtn.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="21"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/hrStatReportExtn.defSearchSize;		
				if(iSearchResult % hrStatReportExtn.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+hrStatReportExtn.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i = 1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}%> </td>
		</tr>
		<tr valign="bottom" style="font-weight:bold;">
			<td width="4%" class="thinborder">Name</td>
			<%if(bolShowDept){%><td width="9%" class="thinborder">Department/Offices</td><%}%>
			<%if(bolShowAddress){%><td width="4%" class="thinborder">Address</td><%}%>
			<td width="4%" class="thinborder">Contact No.</td>
			<td width="4%" class="thinborder">Date<br>
		    of<br>Birth</td>
			<td width="4%" class="thinborder">Civil<br>
		    Status</td>
			<td width="5%" class="thinborder">Spouse,<br>
		    If Married</td>
			<td width="4%" class="thinborder">SSS Num.</td>
			<td width="4%" class="thinborder">TIN</td>
			<td width="3%" class="thinborder">Pag-ibig</td>
			<td width="5%" class="thinborder">Date Hired</td>
			<%if(bolShowLengthOfService){%><td width="4%" class="thinborder">Length<br>
		    on<br>Service</td><%}%>
			<td width="9%" class="thinborder">Emp. Tenureship<br>
		    (Regular/Probi)</td>
			<td width="7%" class="thinborder">Emp. Status <br>
		    (Full-Time/PartTime<br>/Profesional<br>Lecturer)</td>
			<%if(bolShowEducation){%><td width="10%" class="thinborder">Education</td><%}%>
			<%if(bolShowLicense){%><td width="10%" class="thinborder">Licenses</td><%}%>
			
			<td width="4%" class="thinborder">Job Rank</td>
			<%if(bolShowSeminar){%><td width="16%" class="thinborder">Seminars/Training<br>
		    (Name of Seminar/Date/Venue)</td><%}%>
		</tr>
	<%
	
	Vector vTraining = null;
	Vector vEduHist  = null;
	Vector vLicenseList  = null;
	int iCount = 0;
	for(int i = 0; i < vRetResult.size(); i+=iElemCount){
		vTraining = (Vector)vRetResult.elementAt(i+24);
		if(vTraining == null)
			vTraining = new Vector();
		vEduHist = (Vector)vRetResult.elementAt(i+22);
		if(vEduHist == null)
			vEduHist = new Vector();
		vLicenseList = (Vector)vRetResult.elementAt(i+25);
		if(vLicenseList == null)
			vLicenseList = new Vector();
	%>
		<tr valign="bottom">
			<%
			strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
			%>
			<td height="25" class="thinborder"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+6));
			strErrMsg = WI.getStrValue(vRetResult.elementAt(i+8));			
			if(strTemp.length() > 0 && strErrMsg.length() > 0)
				strTemp += "/";
			strTemp += strErrMsg;
			%>
			<%if(bolShowDept){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+9));			
			%>
			<%if(bolShowAddress){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+10));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+11));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = astrCStatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+12),"1"))];
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+13),(String)vRetResult.elementAt(i+14),(String)vRetResult.elementAt(i+15),4);
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+16));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+17));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+18));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+19));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = new hr.HRUtil().getServicePeriodLength(dbOP,(String)vRetResult.elementAt(i));
			%>
			<%if(bolShowLengthOfService){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+20));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = astrPTFT[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+21)))];
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			iCount = 0;
			strTemp = null;
			for(int x=0; x < vEduHist.size(); x+=2){
				if(strTemp == null)
					strTemp = (++iCount)+".) "+(String)vEduHist.elementAt(x)+WI.getStrValue((String)vEduHist.elementAt(x+1)," (Major in ",")","");
				else
					strTemp += "<br>"+ (++iCount)+".) "+(String)vEduHist.elementAt(x)+WI.getStrValue((String)vEduHist.elementAt(x+1)," (Major in ",")","");
			}		
			%>
			<%if(bolShowEducation){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
			
			<%
			iCount = 0;
			strTemp = null;
			for(int x=0; x < vLicenseList.size(); x+=2){
				if(strTemp == null)
					strTemp = (++iCount)+".) "+(String)vLicenseList.elementAt(x)+WI.getStrValue((String)vLicenseList.elementAt(x+1)," - ","","");
				else
					strTemp += "<br>"+ (++iCount)+".) "+(String)vLicenseList.elementAt(x)+WI.getStrValue((String)vLicenseList.elementAt(x+1)," - ","","");
			}		
			%>
			<%if(bolShowLicense){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
			
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+23));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			iCount = 0;
			strTemp = null;
			for(int x=0; x < vTraining.size(); x+=4){
				if(strTemp == null)
					strTemp = (++iCount)+".) "+(String)vTraining.elementAt(x)+
						WI.getStrValue((String)vTraining.elementAt(x+1))+
						WI.getStrValue((String)vTraining.elementAt(x+2)," to ","","")+
						WI.getStrValue((String)vTraining.elementAt(x+3));
				else
					strTemp += "<br>"+ (++iCount)+".) "+(String)vTraining.elementAt(x)+
						WI.getStrValue((String)vTraining.elementAt(x+1))+
						WI.getStrValue((String)vTraining.elementAt(x+2)," to ","","")+
						WI.getStrValue((String)vTraining.elementAt(x+3));
			}		
			%>
			<%if(bolShowSeminar){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
		</tr>
	<%}%>
</table>

<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
<tr><td height="25"  colspan="3">&nbsp;</td></tr>
<tr><td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>
  
	<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
	<input type="hidden" name="print_page">
	<input type="hidden" name="exclude_mem_type" value="5">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
