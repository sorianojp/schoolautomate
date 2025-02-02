<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);

	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}
function UpdateReportTitle() {
	document.getElementById('lbl_report_title').innerHTML = document.form_.title_report.value;
}
function ReloadPage(){
	document.form_.submit();
}

function showList(){
	document.form_.show_list.value="1";
	document.form_.submit();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<body onLoad="UpdateReportTitle();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-OB","hr_stat_logout_new.jsp");

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
														"hr_stat_logout_new.jsp");
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


HRStatsReports hrStat = new HRStatsReports(request);

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};

String[] astrSortByName    = {"College","Department","Emp. Status","First name", "Last Name"};
String[] astrSortByVal     = {"c_code","d_code","user_status.status","fname", "lname"};
							
if(!bolIsSchool) {
	astrSortByName[0] = "Division";
	astrSortByName[1] = "Department";
}

Vector vRetResult = null;

if (WI.fillTextValue("show_list").equals("1")){
	vRetResult = hrStat.hrEmpLogout(dbOP);	
	if (vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form action="./hr_stat_logout_new.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::OFFICIAL <%if(!strSchCode.startsWith("AUF")){%>BUSINESS<%}else{%>LOGOUT<%}%> REPORT ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" style="font-weight:bold; font-size:16px; color:#FF0000">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td width="13%" height="25" class="fontsize10">&nbsp;Date of <%if(strSchCode.startsWith("AUF")){%>Logout<%}else{%>OB<%}%></td>
      <td colspan="2">From : 
        <input name="date_from" type="text" class="textbox"   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_from','/')" onKeyUp="AllowOnlyIntegerExtn('form_','date_from','/')" value="<%=WI.fillTextValue("date_from")%>" size="12" maxlength="12"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        &nbsp;&nbsp;&nbsp;To : 
        <input name="date_to" type="text" class="textbox"   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_to','/')" onKeyUp="AllowOnlyIntegerExtn('form_','date_to','/')" value="<%=WI.fillTextValue("date_to")%>" size="12" maxlength="12"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        &nbsp;</td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Employee ID </td>
      <td width="17%"><input name="emp_id" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" > 
      </td>
      <td width="70%">&nbsp;<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Position</td>
      <td colspan="2"><select name="emp_type_index">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("emp_type_index", "emp_type_name"," from hr_employment_type where is_del =0 order by emp_type_name",WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Dept / Office </td>
      <td colspan="2"><select name="d_index">
          <option value=""> &nbsp;</option>
          <%
			if (WI.fillTextValue("c_index").length() > 0) 
				strTemp = "  c_index = " + WI.fillTextValue("c_index");
			else 
				strTemp = "  (c_index is null or c_index  = 0)";

		%>
          <%=dbOP.loadCombo("d_index", "d_name"," from department where "+ strTemp  +" and is_del = 0 order by d_name",WI.fillTextValue("d_index"), false)%> </select></td>
    </tr>
    <tr>
      <td class="fontsize10">&nbsp;Office/Dept filter </td>
      <td colspan="2"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
        (enter office/dept's first few characters) </td>
    </tr>
<!--
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Emp. Status</td>
      <td colspan="2"><select name="status_index">
          <option value=""> ALL</option>
          <%=dbOP.loadCombo("status_index", "status"," from user_status where IS_FOR_STUDENT = 0 order by status",
								WI.fillTextValue("status_index"), false)%> </select></td>
    </tr>
-->
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Destination </td>
      <td colspan="2"> <select name="destination_con">
          <%=hrStat.constructGenericDropList(WI.fillTextValue("destination_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="destination" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" value="<%=WI.fillTextValue("destination")%>" ></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Purpose </td>
      <td colspan="2"> <select name="purpose_con">
          <%=hrStat.constructGenericDropList(WI.fillTextValue("purpose_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="purpose" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" value="<%=WI.fillTextValue("purpose")%>" ></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="2" class="fontsize10">
		<% if (WI.fillTextValue("show_verified").equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
		%>
	  <input name="show_verified" type="checkbox" id="show_verified" value="1" <%=strTemp%>> check show only verified official time
<%
strTemp = WI.fillTextValue("not_returned");
if(strTemp.length() == 0) 
	strTemp = "2";
	
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		<input type="radio" name="not_returned" value="1" <%=strErrMsg%>> Not yet returned
<%
if(strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		<input type="radio" name="not_returned" value="0" <%=strErrMsg%>>
	    Already returned
        <%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		<input type="radio" name="not_returned" value="2" <%=strErrMsg%>> Ignore Condition
	  </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr> 
      <td height="18" colspan="5">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="20%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="22%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="47%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable4">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;&nbsp;Report Title: 
        <input name="title_report" type="text" value="<%=WI.fillTextValue("title_report")%>" size="64" onKeyUp="UpdateReportTitle();">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<font size="1">Number of Lines Per Page
        <select name="max_lines">
<% 
	int iDefRow = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_lines"), "45"));
	for (int i =40; i <= 65; ++i){ 
		if (iDefRow == i)
			strTemp = " selected";
		else	
			strTemp = "";
	  %>
          <option <%=strTemp%> value="<%=i%>"><%=i%></option>
	<%}%>	  
        </select>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:PrintPg()"%><img src="../../../images/print.gif" border="0"></a> Print page
		</font>
      </td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><a href="javascript:showList()"%><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></div>	  </td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>
<div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false),"","<br>","")%>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%> <br>

		<strong><label id="lbl_report_title"><%=WI.fillTextValue("title_report")%></label></strong>
<br>

        </font></div> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="49%" height="25" style="font-size:9px;"><b>&nbsp;TOTAL RESULT : <%=vRetResult.remove(0)%></b></td>
      <td width="51%">&nbsp;  </td>
    </tr>
  </table>

<%
int iNoOfRows = vRetResult.size()/9; int iCount = 0;
//System.out.println("No of Rows : "+iNoOfRows);

int iTotalNoOfPages = iNoOfRows/iDefRow;
if(iNoOfRows % iDefRow > 0) 
	++iTotalNoOfPages;

//System.out.println("iTotalNoOfPages : "+iTotalNoOfPages);
boolean bolSameUser = false; String strCurrentUserIndex = null;

for(int i = 0; i < iTotalNoOfPages; ++i){
	if(i > 0){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>	
	<%}%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <% 	
		iNoOfRows = 0; strCurrentUserIndex = null;
		while(vRetResult.size() > 0) {
			if(iNoOfRows >= iDefRow)
				break;
			++iNoOfRows;
			if(iNoOfRows == 1){%>
				<tr align="center" style="font-weight:bold">
				  <td width="2%"  class="thinborder"><font size="1">COUNT</font></td>
				  <td width="7%"  class="thinborder"><font size="1">ID NUMBER</font></td>
				  <td width="15%" height="25"  class="thinborder"><font size="1">EMPLOYEE NAME</font></td>
				  <td width="8%"  class="thinborder"><font size="1">OFFICE</font></td>
				  <td width="16%" class="thinborder"><font size="1">OFFICIAL <%if(!strSchCode.startsWith("AUF")){%>BUSINESS<%}else{%>LOGOUT<%}%> DURATION</font></td>
				  <td width="30%" class="thinborder"><font size="1">DESTINATION<br>(PURPOSE)</font></td>
				  <td width="20%" class="thinborder"><font size="1">COMMENTS</font></td>
				</tr>
    		<%}
			
			bolSameUser = false;
		 	if (WI.getStrValue(strCurrentUserIndex).equals((String)vRetResult.elementAt(0)))
				bolSameUser = true;
			else
				strCurrentUserIndex = (String)vRetResult.elementAt(0);
		
			if (bolSameUser) 
				strTemp = "";
			else
				strTemp = strCurrentUserIndex;
		
		strErrMsg = (String)vRetResult.elementAt(2);
		if(strErrMsg == null)
			strErrMsg = (String)vRetResult.elementAt(3);
		else {
			//there is a dept..
			if(vRetResult.elementAt(3) != null)
				strErrMsg = strErrMsg + " - "+vRetResult.elementAt(3);
		}
		%>
			<tr>
			  <td class="thinborder"><%if(bolSameUser){%>&nbsp;<%}else{%><%=++iCount%>.<%}%></td>
			  <td class="thinborder"><%if(bolSameUser){%>&nbsp;<%}else{%><%=vRetResult.elementAt(0)%><%}%></td>
			  <td height="23" class="thinborder"><%if(bolSameUser){%>&nbsp;<%}else{%><%=vRetResult.elementAt(1)%><%}%></td>
			  <td class="thinborder"><%if(bolSameUser){%>&nbsp;<%}else{%><%=WI.getStrValue(strErrMsg,"&nbsp;")%><%}%></td>
			  <td class="thinborder"><%=vRetResult.elementAt(6)%></td>
			  <td class="thinborder"><%=vRetResult.elementAt(5)%>(<%=vRetResult.elementAt(4)%>)</td>
			  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(8),"&nbsp;")%></td>
		</tr>
		<%
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);}//end of while loop..%>
  </table>
<%}//print outer loop.

}//if condition.%>
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>