<%@ page language="java" import="utility.*,eDTR.ReportEDTR,java.util.Vector, java.util.Calendar"%>
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
<title>Perfect Attendance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11{
		font-size : 11px;
	}
	
	.bgDynamic {
		background-color:<%=strColorScheme[1]%>
	}
	.footerDynamic {
		background-color:<%=strColorScheme[2]%>
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
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
 
</script>

<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	Vector vRetResult = null;
	boolean bolHasTeam = false;
	
	Calendar calTemp = Calendar.getInstance();
	String strMonths = WI.fillTextValue("month_of");
 	String strYear = WI.fillTextValue("year_of");
	if(strMonths.length() == 0)
		strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
	if(strYear.length() == 0)
		strYear = Integer.toString(calTemp.get(Calendar.YEAR));

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Perfect Attendance","summary_perfect_attendance.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");								
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
														"summary_perfect_attendance.jsp");	
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
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Emp. Status","Emp. Type"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","user_status.status",
								"HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME","week_day"};

int iSearchResult = 0;

ReportEDTR rD = new ReportEDTR(request);
if(WI.fillTextValue("searchEmployee").compareTo("1") == 0){
	vRetResult = rD.generatePerfectAttendance(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rD.getErrMsg();
	else	
		iSearchResult = rD.getSearchCount();
}

String strDateTo = WI.fillTextValue("date_to");
String strMonth = WI.fillTextValue("strMonth");

String[] astrMonth = {"", "January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};
String strSchCode = dbOP.getSchoolIndex();
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};

%>
<form action="./summary_perfect_attendance.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF"><strong>:::: 
      SUMMARY OF EMPLOYEES WITH PERFECT ATTENDANCE PAGE ::::</strong></font></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
		
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Date</td>
      <td class="fontsize11">
			<input name="date_fr" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to 
        <input name="date_to" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
		
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Month</td>
      <td class="fontsize11">
			  <select name="month_of">
          <%
	  int iDefMonth = Integer.parseInt(strMonths);
	  	for (int i = 0; i <= 12; ++i) {
	  		if (iDefMonth == i)
				strTemp = " selected";
			else
				strTemp = "";
	   %>
          <option value="<%=i%>" <%=strTemp%>><%=astrMonth[i]%></option>
          <%} // end for lop%>
        </select>
        -
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
      </select><font size="1">(selecting a month will overwrite date(s) entry)</font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%" class="fontsize11">Employee ID </td>
      <td width="78%" class="fontsize11"><select name="id_number_con">
      <%=rD.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select>
        <input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Lastname</td>
      <td class="fontsize11"><select name="lname_con">
          <%=rD.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select>
        <input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Firstname</td>
      <td class="fontsize11"><select name="fname_con">
          <%=rD.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select>
        <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
		<%if(strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Employment Category </td>
      <td class="fontsize11"><select name="emp_type_catg" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%
				strTemp = WI.fillTextValue("emp_type_catg");
				for(int i = 0;i < astrCategory.length;i++){
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
      <td class="fontsize11">Employee Position </td>
      <td class="fontsize11"><select name="emp_type_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
			WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
			" order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Employment Tenure </td>
      <td class="fontsize11"> <select name="current_status">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td class="fontsize11"><select name="c_index" onChange="ReloadPage();">
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
      <td class="fontsize11"><select name="d_index">
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
      <td class="fontsize11"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters) </td>
    </tr>
		<%if(bolHasTeam){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Team</td>
      <td class="fontsize11"><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
    </tr>
		<%}%>
    <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("view_all");
				if(strTemp.equals("1"))
					strTemp = "checked";
				else	
					strTemp = "";
			%>
      <td class="fontsize11"><input type="checkbox" name="view_all" value="1" <%=strTemp%>>
view search result in single page </td>
    </tr>
	
	 <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("include_leave");
				if(strTemp.equals("1"))
					strTemp = "checked";
				else	
					strTemp = "";
			%>			
      <td class="fontsize11"><input type="checkbox" name="include_leave" value="1" <%=strTemp%>>
include employees with leave</td>
    </tr>
	
	
    <tr> 
      <td height="19" colspan="3"><hr size="1"></td>
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
      <td colspan="2"><a href="javascript:SearchEmployee();"><img src="../../../images/form_proceed.gif" border="0"> </a></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
  <% 
  	strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); 
		
	 if (!WI.fillTextValue("month_of").equals("0")) {
	 	strTemp = astrMonth[Integer.parseInt(WI.getStrValue(WI.fillTextValue("month_of"),"0"))];
		strTemp += "-" + WI.fillTextValue("year_of");
	 }	  
  %>
      <td height="25" colspan="3" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">SUMMARY 
          OF EMPLOYEES WITH PERFECT ATTENDANCE (<%=strTemp%>)</font></strong></td>
    </tr>
    <tr>
      <td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%> 
			<%if(WI.fillTextValue("view_all").length() == 0){%>
			- Showing(<%=rD.getDisplayRange()%>)
			<%}%>
			</b></td>
      <td width="34%" align="right">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		if(WI.fillTextValue("view_all").length() == 0){
		int iPageCount = iSearchResult/rD.defSearchSize;
		if(iSearchResult % rD.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
Jump To page:
<select name="jumpto" onChange="SearchEmployee();">
  <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
        <%}
				}%>      </td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="12%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="32%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
        NAME </font></strong></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
      <td width="20%" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
      <td width="21%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
      OFFICE</font></strong></td>
    </tr>
    <%
	String[] astrConvertGender = {"M","F"};
for(int i = 0 ; i < vRetResult.size(); i +=15){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder">&nbsp; 
	  <% 
	  	strTemp = "";
	  	if(vRetResult.elementAt(i + 8) != null) {
	  		if(vRetResult.elementAt(i + 9) != null) {
				strTemp = (String)vRetResult.elementAt(i + 8) + " / "  + (String)vRetResult.elementAt(i + 9);
			}else{
				strTemp = (String)vRetResult.elementAt(i + 8);
			}//end of inner loop/
	     }else 
	 		if(vRetResult.elementAt(i + 9) != null){ 
				strTemp = (String)vRetResult.elementAt(i + 9);
			}
	  %><%=WI.getStrValue(strTemp)%></td>
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
<input type="hidden" name="print_page">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>