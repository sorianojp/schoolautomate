<%@ page language="java" import="utility.*,eDTR.RestDays,java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
//	document.form_.print_page.value = 1;
//	document.form_.submit();
}
function ViewRD(strEmpID)
{
//popup window here. 
	var pgLoc = "./rest_days.jsp?emp_id="+escape(strEmpID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72">

<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	if(WI.fillTextValue("print_page").compareTo("1") == 0) {%>
		<jsp:forward page="./emp_absent_print.jsp" />		
	<%return;}
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","emp_absent.jsp");
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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"emp_absent.jsp");	
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
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Tenureship","Salary","Emp. Status","Emp. Type"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","doe","SALARY_AMT","user_status.status",
								"HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME","week_day"};

int iSearchResult = 0;

RestDays rD = new RestDays(request);
if(WI.fillTextValue("searchEmployee").compareTo("1") == 0){
	vRetResult = rD.searchRestDays(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rD.getErrMsg();
	else	
		iSearchResult = rD.getSearchCount();
}

%>
<form action="./emp_absent.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SEARCH ABSENT EMPLOYEE ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Day of Absence</td>
      <td colspan="4"><input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        (leave date to field empty for a specific date)</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%">Employee ID </td>
      <td width="9%"><select name="id_number_con">
          <%=rD.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="14%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td width="9%">Gender</td>
      <td width="47%"> <select name="gender">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("gender").compareTo("1") == 0){%>
          <option value="1" selected>Female</option>
          <%}else{%>
          <option value="1">Female</option>
          <%}if(WI.fillTextValue("gender").compareTo("0") ==0){%>
          <option value="0" selected>Male</option>
          <%}else{%>
          <option value="0">Male</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=rD.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td></select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=rD.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employment Status</td>
      <td colspan="2"> <select name="current_status">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> </select></td>
      <td>Emp. Type</td>
      <td><select name="emp_type_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="4"><select name="c_index" onChange="ReloadPage();">
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
      <td>Office/Dept</td>
      <td colspan="4"><select name="d_index">
          <option value="">N/A</option>
          <%
strTemp3 = "";
strTemp3 = WI.fillTextValue("d_index");
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index="+strTemp+" or c_index is null) order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
    <tr> 
      <td height="19" colspan="6"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
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
      <td colspan="2"> <input type="image" src="../../../images/refresh.gif" onClick="SearchEmployee();"> 
        <font size="1">Click to search Employee.</font></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><div align="right">
	  <!--
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
          <font size="1">click to print result</font>-->
		  </div></td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH
          RESULT</font></strong></div></td>
    </tr>
    <tr>
      <td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%> - Showing(<%=rD.getDisplayRange()%>)</b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/rD.defSearchSize;
		if(iSearchResult % rD.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
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
          <%}%>
        </div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="13%" height="25"  class="thinborder"><div align="center"><strong><font size="1">EMPLOYEE 
          ID</font></strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong><font size="1">NAME 
          (LNAME,FNAME MI)</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">GENDER</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">EMPLOYMENT 
          STATUS</font></strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong><font size="1">EMPLOYMENT 
          TYPE</font></strong></div></td>
      <td width="30%" class="thinborder"><div align="center"><strong><font size="1">DEPT/ 
          OFFICE</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">TENURESHIP</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>VIEW 
          DETAIL ATTENDANCE</strong></font></div></td>
    </tr>
    <%
	String[] astrConvertGender = {"M","F"};
for(int i = 0 ; i < vRetResult.size(); i +=11){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <td class="thinborder"><%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"> <% if(vRetResult.elementAt(i + 8) != null) {//outer loop.
	  		if(vRetResult.elementAt(i + 9) != null) {//inner loop.%> <%=(String)vRetResult.elementAt(i + 8)%>/<%=(String)vRetResult.elementAt(i + 9)%> <%}else{%> <%=(String)vRetResult.elementAt(i + 8)%> <%}//end of inner loop/
	  }else if(vRetResult.elementAt(i + 9) != null){//outer loop else%> <%=(String)vRetResult.elementAt(i + 9)%> <%}%> </td>
      <td class="thinborder"> <div align="center"> <%=ConversionTable.differenceInYearMonthDaysNow((String)vRetResult.elementAt(i + 10))%></div></td>
      <td class="thinborder" align="center">
	  <a href='javascript:ViewRD("<%=(String)vRetResult.elementAt(i + 1)%>");'><img src="../../../images/view.gif" border="0"></a></td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25">&nbsp;</td>
      <td width="31%"><div align="right"></div></td>
    </tr>
  </table>
<%}//only if vRetResult not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="searchEmployee" value="0">
<input type="hidden" name="print_page">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>