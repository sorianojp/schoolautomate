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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function showList(){
	document.form_.show_list.value="1";
}
function SetReportName() {
	var strReportName = "";
	document.form_.show_list.value='1';
	if(document.form_.c_index.selectedIndex > 0) 
		strReportName = document.form_.c_index[document.form_.c_index.selectedIndex].text;
	if(document.form_.d_index.selectedIndex > 0) {
		if(strReportName.length > 0)
			strReportName = strReportName + " - " + document.form_.d_index[document.form_.d_index.selectedIndex].text;
		else
			strReportName = document.form_.d_index[document.form_.d_index.selectedIndex].text;		
	}
/**
	if(document.form_.emp_type_index.selectedIndex > 0) {
		if(strReportName.length > 0)
			strReportName = strReportName + " :";
		strReportName = strReportName + " For Position " + document.form_.emp_type_index[document.form_.emp_type_index.selectedIndex].text;
	}
**/	document.form_.report_name.value = strReportName;
}
function PrintPage() {
	var objMyADTable1 = document.getElementById('myADTable1');
	//objMyADTable1.deleteRow(0);
	objMyADTable1.deleteRow(0);
	objMyADTable1.deleteRow(0);
	objMyADTable1.deleteRow(0);
	objMyADTable1.deleteRow(0);
	objMyADTable1.deleteRow(0);
	objMyADTable1.deleteRow(0);
	objMyADTable1.deleteRow(0);
	objMyADTable1.deleteRow(0);
	objMyADTable1.deleteRow(0);
	objMyADTable1.deleteRow(0);
	objMyADTable1.deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	alert("Click OK to print this page");
	window.print();
}
///ajax here to load major..
function loadDept() {
	var objCOA=document.getElementById("load_dept");
	var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
	//alert(strURL);
	this.processRequest(strURL);
}

</script>

<body>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";
		
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-REPORTS AND STATISTICS-Education","hr_stat_separating.jsp");

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
														"hr_stat_separating.jsp");
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
Vector vRetResult  = null;
HRStatsReports hrStat = new HRStatsReports(request);
if(WI.fillTextValue("show_list").length() > 0) {
	vRetResult = hrStat.getSeparatingEmployee(dbOP, request, true);
	if(vRetResult == null) 
		strErrMsg = hrStat.getErrMsg();
}

%>
<form action="./hr_stat_separating.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFF0F0" id="myADTable1">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF"><strong>:::: SEPARATING EMPLOYEE LISTING::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#FFFFFF">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr> 
      <td width="16%" height="18">&nbsp;</td>
      <td width="84%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" class="fontsize10" style="font-weight:bold">Note : This employee listing does not include employees already separated.</td>
    </tr>
<!--    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Position</td>
      <td><select name="emp_type_index">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("emp_type_index", "emp_type_name"," from hr_employment_type where is_del =0 order by emp_type_name",WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
-->    <tr> 
      <td height="25" class="fontsize10">&nbsp; <%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td><select name="c_index" onChange="loadDept();">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp; Dept / Office </td>
      <td><label id="load_dept">
	  <select name="d_index">
          <option value=""> &nbsp;</option>
<%
if (WI.fillTextValue("c_index").length() > 0) 
	strTemp = "  c_index = " + WI.fillTextValue("c_index");
else 
	strTemp = "  (c_index is null or c_index  = 0)";
%>
          <%=dbOP.loadCombo("d_index", "d_name"," from department where "+ strTemp  +" and is_del = 0 order by d_name",WI.fillTextValue("d_index"), false)%> </select>
	</label>		  </td>
    </tr>
    <tr>
      <td class="fontsize10">&nbsp; Office/Dept filter </td>
      <td><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
        (enter office/dept's first few characters) </td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp; Employee ID</td>
      <td>
        <input type="text" name="emp_id" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10" value="<%=WI.fillTextValue("emp_id")%>">       </td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp; Date Range</td>
      <td class="fontsize10">
	  <input type="text" name="date_from" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10" value="<%=WI.fillTextValue("date_from")%>"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        &nbsp;&nbsp;-- &nbsp;&nbsp; <input type="text" name="date_to" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10"
		value="<%=WI.fillTextValue("date_to")%>"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  (Note : Enter start date to get employees separating on or after that date) </td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp; Sort Result by </td>
      <td class="fontsize10">
<%
strTemp = WI.fillTextValue("order_by_dol");
if(strTemp.equals("1")) {
	strTemp = " checked";
	strErrMsg = "";
}
else {
	strErrMsg = " checked";
	strTemp   = "";
}
%>	  <input type="radio" value="1" name="order_by_dol" <%=strTemp%>> Date of Separation &nbsp;&nbsp;&nbsp;
	  <input type="radio" value="2" name="order_by_dol" <%=strErrMsg%>> Last Name, First Name&nbsp;&nbsp;&nbsp;	  </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  	<input type="submit" name="_" value="Get Result" onClick="SetReportName();"></td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td height="25"></td>
      <td height="25" align="right" class="fontsize10">&nbsp;<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a> Print Page</td>
    </tr>
<%
String strReportName = null;
if(WI.fillTextValue("date_from").length() > 0) {
	if(WI.fillTextValue("date_to").length() > 0) 
		strReportName = " Date Range : "+WI.fillTextValue("date_from")+" - "+WI.fillTextValue("date_to");
	else	
		strReportName = " Separating On or After : "+WI.fillTextValue("date_from");
}
else	
	strReportName = " Separating On or After : "+WI.getTodaysDate(1);
%>
    <tr> 
      <td height="25" colspan="2" align="center"><strong><u>Separating Employee Listing :: (<%=strReportName%>)</u> </strong>
	  <%if(WI.fillTextValue("report_name").length() > 0) {%><br><u><font size="1"><%=WI.fillTextValue("report_name")%></font></u><%}%>
	  
	  </td>
    </tr>
    <tr> 
      <td width="49%" height="25" class="fontsize10"><b>&nbsp;Total Result : <%=vRetResult.size()/15%> </b></td>
      <td width="51%" align="right" class="fontsize10">Date and time generated : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" class="thinborder">
    <tr style="font-weight:bold"> 
      <td width="13%" height="25"  class="thinborder" align="center"><font size="1">Employee ID</font></td>
      <td width="19%" class="thinborder" align="center"><font size="1">Office</font></td>
      <td width="24%" class="thinborder" align="center"><font size="1">Employee Name</font></td>
      <td width="17%" class="thinborder" align="center"><font size="1">Position</font></td>
      <td width="14%" class="thinborder" align="center"><font size="1">Separation Date</font></td>
      <td width="13%" class="thinborder" align="center"><font size="1">Days Remaining</font></td>
    </tr>
	<%for(int i = 0; i < vRetResult.size(); i += 15) {%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
    </tr>
	<%}%>
  </table>
<%}%>

  <input type="hidden" name="show_list" value="0">
  <input type="hidden" name="report_name">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>