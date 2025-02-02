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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
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
	document.dtr_op.view_all.checked = true;
	document.dtr_op.viewRecords.value = "1";
	document.dtr_op.print_page.value = "1";
	document.dtr_op.submit();
}

function viewLateDetails(strEmpID)
{
//popup window here. 
	var bolShowOnlyDeduct = "";
	var pgLoc = "./summary_faculty_late_ut_detail.jsp?show_detail=1&viewRecords=1&emp_id="+escape(strEmpID)+
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

function FirePrint() {
	window.print();
}
</script>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");

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
	
	boolean bolCalledFromEnrollment = false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Faculty with Late Time-in Record",
								"summary_faculty_lateUT.jsp");
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
														null);	
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","Faculty-DTR",request.getRemoteAddr(), 
														null);	
	bolCalledFromEnrollment = true;
}														
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

if (WI.fillTextValue("viewRecords").compareTo("1") == 0){
	vRetResult = RE.searchLateAndUndertime(dbOP);
		
	if (vRetResult == null || vRetResult.size() == 0)
		strErrMsg = RE.getErrMsg();
	else{
		iSearchResult = RE.getSearchCount();
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


boolean bolIsPrint = false;
boolean bolShowHoursWorked = false;
if(WI.fillTextValue("print_page").length() > 0) 
	bolIsPrint = true;
if(WI.fillTextValue("inc_hours_worked").length() > 0) 
	bolShowHoursWorked = true;


%>
<body <%if(bolIsPrint){%> onLoad="FirePrint();"<%}%>>
<form action="summary_faculty_late_ut.jsp" name="dtr_op" method="post">
<%if(!bolIsPrint){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td align="center" class="thinborderBOTTOM"><strong>:::: 
        SUMMARY OF FACULTIES WITH LATE TIME-IN PAGE ::::</strong></td>
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
      <td height="24">
	  <select name="c_index" onChange="ReloadPage();">
<%if(bolCalledFromEnrollment || WI.fillTextValue("called_fr_enrl").equals("1")){
	strTemp = "select c_index from info_faculty_basic where is_valid = 1 and user_index = "+(String)request.getSession(false).getAttribute("userIndex");
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 and c_index = "+strTemp, null, false)%> 
<%}else{%>
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", WI.fillTextValue("c_index"), false)%> 
<%}%>
	  </select></td>
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
	<!-- 	no ned of this..sul092012
    <tr> 
      <td>&nbsp;</td>
      <td height="25">Frequency of Lates</td>
      <td height="25"><input name="freq_late" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("freq_late")%>"  size="4" maxlength="2"></td>
    </tr>
	-->	    
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
      <td><input name="proceed" type="image" id="proceed" onClick="ViewRecords();" src="../../../images/form_proceed.gif"></td>
      <td colspan="3" style="font-size:9px;">
	  <input type="checkbox" name="only_lt_ut" value="checked" <%=WI.fillTextValue("only_lt_ut")%>> Show only having Late/ut
		&nbsp;&nbsp;&nbsp;&nbsp;	  
	  <input type="checkbox" name="no_tin_tout" value="checked" <%=WI.fillTextValue("no_tin_tout")%>> Show Faculty with no time-in/out
		&nbsp;&nbsp;&nbsp;&nbsp;	  
	  <input type="checkbox" name="inc_hours_worked" value="checked" <%=WI.fillTextValue("inc_hours_worked")%>> Include hours worked
	  </td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>
	  <%
			if(WI.fillTextValue("view_all").length() > 0){
				strTemp = " checked";				
			}else{
				strTemp = "";
			}
		%>
	  <input name="view_all" type="checkbox" value="1"<%=strTemp%>>View ALL	  </td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2" style="font-size:9px;">
      	<% if (vRetResult != null && vRetResult.size() > 0 ){%>
			Rows Per Page : <select name="num_rec_page">
	  		<% 	int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"40"));
				for(int i = 25; i <=60 ; i++) {
					if ( i == iDefault) {%>
                    	<option selected value="<%=i%>"><%=i%></option>
                    <%}else{%>
                    	<option value="<%=i%>"><%=i%></option>
                    <%}
				}%>
                  </select>
	
			<a href="javascript:PrintPage()"><img src="../../../images/print.gif"  border="0"></a>click to print
				  
		<%}%>	  </td>
    </tr>
  </table>
<%}//show if not print%>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%	
	if(WI.fillTextValue("view_all").length() == 0){
	iPageCount = iSearchResult/RE.defSearchSize;		
	if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;	
	if(iPageCount > 1){	
	%>
    <tr>
		<td style="font-weight:bold">Total Result: <%=iSearchResult%></td>
      <td><div align="right"><font size="2">Jump To page:
        <select name="jumpto" onChange="ViewRecords();">
      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
			
			for(int i =1; i<= iPageCount; ++i )
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
      </font></div></td>
    </tr>
    <%} // end if pages > 1	
		}// end if not view all%>
  </table> 
  
  <% 
  	String strDateRange = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); 
		
	 if (WI.fillTextValue("month").length() > 0) {
	 	strDateRange = astrMonth[Integer.parseInt(WI.getStrValue(WI.fillTextValue("month"),"0"))];
		
		strDateRange += " " + WI.fillTextValue("year");
	 }	  
  %>
 <%	//System.out.println(vRetResult);
 	
int iCount = 1;
int iMaxRows = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"40"));
int iTemp = 0;

for ( int i = 0 ; i< vRetResult.size();){   		
	if(i > 0){%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
	<%}
%>
  
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ECF3FB"> 
      <td height="25"  colspan="9" align="center" class="thinborder"><strong>SUMMARY OF EMPLOYEES WITH LATE TIME-IN (<%=strDateRange%>)</strong></td>
    </tr>
    <tr align="center" bgcolor="#EBEBEB">
      <td width="4%" height="25" class="thinborder" style="font-size:9px;"><strong>COUNT</strong></td>
	 <td width="11%" class="thinborder"><strong><font size="1">EMPLOYEE ID</font></strong></td>	
      <td width="20%" class="thinborder"><font size="1"><strong>EMPLOYEE NAME </strong></font></td>
      <td width="15%" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
      <td width="20%" class="thinborder"><strong><font size="1">DEPT/ OFFICE</font></strong></td>
<%if(bolShowHoursWorked){%>
      <td width="15%" class="thinborder"><strong><font size="1">HOURS WORKED</font></strong></td>
<%}%>
      <td width="5%" class="thinborder"><strong><font size="1"> TOTAL LATE </font></strong></td>
      <td width="5%" class="thinborder"><strong><font size="1"> TOTAL UNDERTIME </font></strong></td>
<%if(!bolIsPrint){%>
      <td width="9%" class="thinborder"><strong><font size="1">VIEW DETAILS</font></strong></td>
<%}%>
    </tr>
 <%for (; i< vRetResult.size(); i+=13){
 
 	iTemp = Integer.parseInt((String)vRetResult.elementAt(i + 12));
 	if(iTemp == 0) 
 		strErrMsg = "0.00";
	else
		strErrMsg = comUtil.convertMinToHr(iTemp);
 %>
    <tr> 
	  <td class="thinborder" align="center" height="20"><%=iCount++%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;</td>
      <td class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
	  <%
	  	strTemp = (String)vRetResult.elementAt(i+6);
		if (strTemp == null) 
			strTemp = (String)vRetResult.elementAt(i+7);
		else 
			strTemp += WI.getStrValue((String)vRetResult.elementAt(i+7), " :: ","","");
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
<%if(bolShowHoursWorked){%>
      <td class="thinborder"><%=strErrMsg%></td>
<%}%>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8), "0")%>&nbsp;</td>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10), "0")%>&nbsp;</td>
<%if(!bolIsPrint){%>
      <td align="center" class="thinborder"><a href="javascript:viewLateDetails('<%=(String)vRetResult.elementAt(i+1)%>')"><img src="../../../images/view.gif" border="0" ></a></td>
<%}%>
    </tr>
    <%
	if((iCount-1)%(iMaxRows) == 0)
		break; 
	} // end for loop%>
  </table>
  <%
	}//outer for loop.
	
}%>


  <input type="hidden" name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
  <input type="hidden" name="viewRecords" value="0">
  <input type="hidden" name="print_page">
  <input type="hidden" name="consecutive_lates" value="1"> 
  <input type="hidden" name="show_only_total" value="1"> 
  <input type="hidden" name="called_fr_enrl" value="<%=WI.fillTextValue("called_fr_enrl")%>">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>