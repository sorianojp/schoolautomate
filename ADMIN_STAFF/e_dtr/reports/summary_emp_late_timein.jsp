<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, 
																eDTR.AllowedLateTimeIN"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employees with Late time-in</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	.bgDynamic {
		background-color:<%=strColorScheme[1]%>
	}
	.footerDynamic {
		background-color:<%=strColorScheme[2]%>
	}	
-->
</style>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
}	
function ReloadPage()
{
	document.dtr_op.print_page.value = "";
	document.dtr_op.reloadpage.value="1";
	this.SubmitOnce("dtr_op");;
}

function ViewRecordDetail(index){
	document.dtr_op.print_page.value = "";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.SummaryDetail.value="1";
	document.dtr_op.emp_id.value=index;
	document.dtr_op.emp_type.value ="";
	document.dtr_op.c_index.value ="";
	document.dtr_op.d_index.value ="";
	this.SubmitOnce("dtr_op");;
}
function ViewRecords()
{
	document.dtr_op.print_page.value = "";
	document.dtr_op.viewRecords.value="1";
	this.SubmitOnce("dtr_op");;
}
function PrintPage()
{
	document.dtr_op.print_page.value = "1";
	document.dtr_op.submit();
}

function viewLateDetails(strEmpID)
{
//popup window here. 
	var bolShowOnlyDeduct ;
	if (document.dtr_op.show_only_deduct.checked) 
		bolShowOnlyDeduct = "1";
	else 
		bolShowOnlyDeduct= "";

	var pgLoc = "./summary_emp_late_timein_detail.jsp?show_detail=1&viewRecords=1&emp_id="+escape(strEmpID)+
		"&from_date=" + escape(document.dtr_op.from_date.value) + "&to_date=" + escape(document.dtr_op.to_date.value) +
		"&show_only_deduct="+bolShowOnlyDeduct +
		"&month=" + document.dtr_op.month[document.dtr_op.month.selectedIndex].value + 
		"&year="+document.dtr_op.year.value;
		
	var win=window.open(pgLoc,"ShowDetail",'width=550,height=400,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.dtr_op.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body bgcolor="#D2AE72"  class="bgDynamic">
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");

if( request.getParameter("print_page") != null && request.getParameter("print_page").compareTo("1") ==0)
{ %>
	<jsp:forward page="./summary_emp_late_timein_print.jsp" />
<%}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	boolean bolHasTeam = false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Employees with Late Time-in Record",
								"summary_emp_late_timein.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
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
														"summary_emp_late_timein.jsp");	
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

ReportEDTR RE = new ReportEDTR(request);
AllowedLateTimeIN allowedLateTIN = new AllowedLateTimeIN();
Vector vRetResultConsec = null;
String strLateSetting = null;
Vector vLateTimeIn = null;
	vLateTimeIn = allowedLateTIN.operateOnLateSetting(dbOP, request, 3);
	if(vLateTimeIn != null && vLateTimeIn.size() > 0){
		strLateSetting = (String)vLateTimeIn.elementAt(0);
	}
if (WI.fillTextValue("viewRecords").compareTo("1") == 0){
	vRetResult = RE.searchLateTimeIn(dbOP);
		
	if (vRetResult == null || vRetResult.size() == 0)
		strErrMsg = RE.getErrMsg();
		
	if (WI.fillTextValue("consec_3_months").equals("1")){
		vRetResultConsec = RE.search3MonthsConsecutive9Late(dbOP);
		
		if (vRetResultConsec == null || vRetResultConsec.size() == 0)
			strErrMsg = RE.getErrMsg();	
	}
}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String strCollDiv = null;
if(bolIsSchool)
   strCollDiv = "College";
else
   strCollDiv = "Division";

String[] astrSortByName = {"ID #", "Last Name", "First Name", "Position", strCollDiv, 
													 "Department", "Total Late Minutes", "No. of Times"};
String[] astrSortByVal = {"id_number", "lname", "fname", "c_code", "d_name", 
										 			"emp_type_name","sum_late", "count_late"};
String[] astrMonth = {"","January", "February","March", "April", "May","June","July",  
						"August", "September", "October", "November", "December"};
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
%>
<form action="summary_emp_late_timein.jsp" name="dtr_op" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  class="footerDynamic" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        SUMMARY OF EMPLOYEES WITH LATE TIME-IN PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","&nbsp;")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="30"></td>
      <td width="19%" height="30">Date Range</td>
      <td height="30">&nbsp;From: 
        <input name="from_date" type="text"  id="from_date3" size="12" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("from_date")%>"> 
        <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To 
        : 
        <input name="to_date" type="text"  id="to_date3" size="12" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("to_date")%>"> 
        <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Month / Year </td>
      <td width="78%" height="25">
        <select name="month">
		<option value=""> Select Month</option>
		<%for (int i = 1; i < astrMonth.length; i++) {
			if (WI.fillTextValue("month").equals(Integer.toString(i))){%> 
			<option value="<%=i%>" selected><%=astrMonth[i]%></option>
		<%}else{%> 
			<option value="<%=i%>"><%=astrMonth[i]%></option>			
		<%}
		}%> 
        </select>
      <input name="year" type="text"  size="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("year")%>">
      <font size="1">(this option will overwrite the date range encoded above)</font></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp; </td>
      <td height="25">Employee ID</td>
      <td height="25"><input name="emp_id" type="text"  size="12" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			value="<%=WI.fillTextValue("emp_id")%>" onKeyUp="AjaxMapName(1);"> <label id="coa_info"></label></td>
    </tr>
    <% if (strSchCode.startsWith("AUF")) {%>
    <tr> 
      <td>&nbsp;</td>
      <td height="24">Employment Catg</td>
			<%
				strTemp = WI.fillTextValue("emp_type_catg");
			%>
      <td height="24"><select name="emp_type_catg" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%
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
      <td>&nbsp;</td>
      <td height="25">Position</td>
      <td height="25"><strong> 
        <%strTemp2 = WI.fillTextValue("emp_type");%>
        <select name="emp_type">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
					WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
					" order by EMP_TYPE_NAME asc", strTemp2, false)%> 
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="24"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="24"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", WI.fillTextValue("c_index"), false)%> </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Department/Office</td>
      <td height="25"><select name="d_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + 
				WI.getStrValue(request.getParameter("c_index"), " and c_index = ","","and (c_index is null or c_index = 0)") +
				" order by d_name asc",WI.fillTextValue("d_index"), false)%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Office/Dept filter<br></td>
      <td height="25"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters) </td>
    </tr>
 		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>
      </td>
    </tr>
		<%}%>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">Frequency of Lates</td>
      <td height="25"><input name="freq_late" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("freq_late")%>"  size="4" maxlength="2"></td>
    </tr>
		<%if(strLateSetting.equals("1")){%>
    <tr> 
      <td>&nbsp;</td>
      <td height="26" colspan="2">
	  <%  
	  	if (WI.fillTextValue("show_only_deduct").equals("1"))
			strTemp = "checked";
		else strTemp = "";
	  %>
	  <input name="show_only_deduct" type="checkbox" id="" value="1" <%=strTemp%>>
      check to show only late with salary deductions </td>
    </tr>
		<%}else{%>
		<input name="show_only_deduct" type="hidden" value="">
		<%}%>
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="2"><%  
	  	if (WI.fillTextValue("consec_3_months").equals("1"))
			strTemp = "checked";
		else strTemp = "";
	  %>
        <input name="consec_3_months" type="checkbox" value="1" <%=strTemp%>> 
        check to show employees who have 3 months with 9 consecutive tardiness</td>
    </tr>
    <tr> 
      <td height="30" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%" rowspan="2"><strong>&nbsp;SORT BY</strong> </td>
      <td width="21%" height="24"><strong> 
        <select name="sort_by1">
          <option value="">N/A</option>
          <%=RE.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
        </select>
        </strong></td>
      <td width="20%"><strong> 
        <select name="sort_by2">
          <option value="">N/A</option>
          <%=RE.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select>
        </strong></td>
      <td width="21%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=RE.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="23%"><select name="sort_by4">
          <option value="">N/A</option>
          <%=RE.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="25"><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td height="25"><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td height="25"><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td height="25"><select name="sort_by4_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" colspan="5">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><input name="proceed" type="image" id="proceed" onClick="ViewRecords();" src="../../../images/form_proceed.gif"></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
  </table>
  <% if (vRetResult !=null){  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;<strong>TOTAL : <%=RE.getSearchCount()%></strong></td>
      <td align="right">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ECF3FB"> 
  <% 
  	strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); 
		
	 if (WI.fillTextValue("month").length() > 0) {
	 	strTemp = astrMonth[Integer.parseInt(WI.getStrValue(WI.fillTextValue("month"),"0"))];
		
		strTemp += " " + WI.fillTextValue("year");
	 }	  
  %>
      <td height="25"  colspan="7" align="center" class="thinborder"><strong>SUMMARY OF EMPLOYEES WITH LATE TIME-IN (<%=strTemp%>)</strong></td>
    </tr>
    <tr>
      <td width="12%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="30%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>EMPLOYEE 
        NAME </strong></font></td>
      <td width="17%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
      <td width="18%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">DEPT 
        / OFFICE</font></strong></td>
      <td width="8%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">FREQ . <br> 
      LATE </font></strong></td>
      <td width="8%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">TOTAL 
          MINUTES </font></strong></td>
      <td width="7%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">VIEW 
          DETAILS</font></strong></td>
    </tr>
 <%	//System.out.println(vRetResult);
 	for ( int i = 0 ; i< vRetResult.size(); i+=12){  
 		if (vRetResult.elementAt(i+11) != null) 
			strTemp = "bgcolor=\"#FFF4F4\"";
		else
			strTemp = "";
 %>
    <tr <%=strTemp%>> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;</td>
			<%
				strTemp = WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
									(String)vRetResult.elementAt(i+4),4);
			%>	
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
	  <%
	  	strTemp = (String)vRetResult.elementAt(i+6);
		if (strTemp == null) 
			strTemp = (String)vRetResult.elementAt(i+7);
		else 
			strTemp += WI.getStrValue((String)vRetResult.elementAt(i+7), " :: ","","");
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp)%></td>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+9))%>&nbsp;</td>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8))%>&nbsp;</td>
      <td align="center" class="thinborder"><a href="javascript:viewLateDetails('<%=(String)vRetResult.elementAt(i+1)%>')"><img src="../../../images/view.gif" border="0" ></a></td>
    </tr>
    <%} // end for loop%>
  </table>
<% if (vRetResultConsec!= null && vRetResultConsec.size() > 0){%>   
<br /><br/>
<table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ECF3FB"> 
      <td height="25"  colspan="4" align="center" class="thinborder"><strong>SUMMARY OF EMPLOYEES WITH 3 MONTHS CONSECUTIVE WITH 9 TARDINESS</strong></td>
    </tr>
    <tr> 
      <td width="12%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="30%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>EMPLOYEE 
        NAME </strong></font></td>
      <td width="17%" height="30" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
      <td width="18%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">DEPT 
        / OFFICE</font></strong></td>
    </tr>
 <%	//System.out.println(vRetResult);
 	for ( int i = 0 ; i< vRetResultConsec.size(); i+=8){  
 %>
    <tr> 
      <td height="20" class="thinborder"><%=(String)vRetResultConsec.elementAt(i+1)%>&nbsp;</td>
      <td class="thinborder"><%=WI.formatName((String)vRetResultConsec.elementAt(i+2),
	  									(String)vRetResultConsec.elementAt(i+3),
										(String)vRetResultConsec.elementAt(i+4),4)%></td>
      <td class="thinborder"><%=(String)vRetResultConsec.elementAt(i+5)%></td>
	  <%
	  	strTemp = (String)vRetResultConsec.elementAt(i+6);
		if (strTemp == null) 
			strTemp = (String)vRetResultConsec.elementAt(i+7);
		else 
			strTemp += WI.getStrValue((String)vRetResult.elementAt(i+7), " :: ","","");
	  %>
      <td class="thinborder"><%=strTemp%>&nbsp;</td>
    </tr>
    <%} // end for loop%>
  </table>  
<%}%>   
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="bottom"> 
      <td height="46" align="center"><a href="javascript:PrintPage()"><img src="../../../images/print.gif"  border="0"></a><font size="1">click to print list</font> </td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  class="footerDynamic">
     <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
   <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
  <input type="hidden" name="viewRecords" value="0">
  <input type="hidden" name="print_page">
  <input type="hidden" name="consecutive_lates" value="1"> 
  <input type="hidden" name="show_only_total" value="1">  
</form>
</body>
</html>
<% dbOP.cleanUP(); %>