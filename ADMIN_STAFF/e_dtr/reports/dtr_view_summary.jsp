<%@page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil, 
																java.util.Calendar, java.util.Date" buffer="16kb"%>
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ %>
	<jsp:forward page="./dtr_view_summary_print.jsp" />
<%}
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if (strSchCode == null)
	strSchCode = "";
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
  Vector vRetEDTR = new Vector();
	Calendar calTemp = Calendar.getInstance();
	String strTemp2 = null;
	String strTemp3 = null;
	int iSearchResult =0;
	int iIndex = 0;
	int iCount = 0;
	String strMonths = WI.fillTextValue("strMonth");
 	String strYear = WI.fillTextValue("sy_");
	if(strMonths.length() == 0)
		strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
	if(strYear.length() == 0)
		strYear = Integer.toString(calTemp.get(Calendar.YEAR));
	boolean bolHasTeam = false;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Employee DTR Summary","dtr_view_summary.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(),
														"dtr_view_summary.jsp");
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
if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};

ReportEDTR RE = new ReportEDTR(request);
Vector vSummaryWrkHours = null;
Vector vHoursWork = null;
Vector vDayInterval = null;
Vector vHoursOT = null;

Vector vRetHolidays = null;
Vector vTempHoliday = null;
Vector vEmpLeave = null;
Vector vRetOBOT = null;
Vector vAWOLRecords = null;
Vector vLateUnderTime = null;
Vector vEmpLogout = null;
Vector vEmpOvertime = null;
Vector vMultipleLogin = null;

String strEmpDayRec = null;
String strDateFr = null;
String strDateTo = null;
String strHoliday  = null;
int iIndexOf  = 0;
String strLate = null;
String strUt = null;
double dAwol = 0d;

String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};

if (WI.fillTextValue("viewRecords").equals("1")) {
	vRetResult = RE.searchEDTR(dbOP, true);

	if (vRetResult == null)
		strErrMsg = RE.getErrMsg();

//added by biswa to get from and to date.
	if( WI.fillTextValue("DateDefaultSpecify").equals("0")) {
		String[] astrTemp = eDTRUtil.getCurrentCutoffDateRange(dbOP, true);
		if(astrTemp != null) {
			strDateFr = astrTemp[0];
			strDateTo = astrTemp[1];
		}
	} else if( WI.fillTextValue("DateDefaultSpecify").equals("2")) {
		try{			
				if (strYear.length()> 0){
					if (Integer.parseInt(strYear) >= 2005)
						calTemp.set(Calendar.YEAR, Integer.parseInt(strYear));
				else
					strErrMsg = " Invalid year entry";
	
				}else{
					strYear = Integer.toString(calTemp.get(Calendar.YEAR));
				}
			}
			catch (NumberFormatException nfe){
			strErrMsg = " Invalid year entry";
			}
	
			calTemp.set(Calendar.DAY_OF_MONTH,1);
	
			 if(!strMonths.equals("0") && strMonths.length() > 0){
					calTemp.set(Calendar.MONTH,Integer.parseInt(strMonths)-1);
			 }else{
					strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
			 }

				strDateFr = strMonths + "/01/" + calTemp.get(Calendar.YEAR);
				strDateTo = strMonths + "/" + Integer.toString(calTemp.getActualMaximum(Calendar.DAY_OF_MONTH))
						+ "/" + calTemp.get(Calendar.YEAR); 
	} else {
		strDateFr = WI.fillTextValue("from_date");
		strDateTo = WI.fillTextValue("to_date");

	}

 		vDayInterval = RE.getDayNDateDetail(strDateFr,strDateTo, true);		
		if (vDayInterval == null)
			strErrMsg = RE.getErrMsg();
		vRetHolidays = RE.getHolidaysOfMonth(dbOP,request);
 }

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summary of Employee DTR</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.bgDynamic {
		background-color:<%=strColorScheme[1]%>
	}
	.footerDynamic {
		background-color:<%=strColorScheme[2]%>
	}

    table.thinborder {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }
    TD.thinborder {
    border-bottom: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
    }
		
		TD.BottomLeftRight {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
    }

    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
		}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
	document.dtr_op.submit();
}
function ReloadPage()
{
	document.dtr_op.print_page.value="";

	document.dtr_op.reloadpage.value="1";
//	document.dtr_op.viewRecords.value ="1";
	document.dtr_op.submit();
}
function ViewDTR(strEmpID,strDateFrom, strDateTo)
{
//popup window here.
	var pgLoc = "./dtr_view_summary.jsp?DateDefaultSpecify=1&SummaryDetail=1" +
	"&window_opener=1&viewRecords=1&view_one=1&emp_id="
	+escape(strEmpID)+"&from_date="+escape(strDateFrom)+"&to_date="+escape(strDateTo);

	var win=window.open(pgLoc,"EditWindow",'dependent=yes,width=750,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewRecords()
{
	document.dtr_op.print_page.value="";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
}

function PrintPage()
{
 	document.dtr_op.print_page.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.submit(); 
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
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="dtr_op" action="./dtr_view_summary.jsp" method="post">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="header_">
     <tr bgcolor="#A49A6A">
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
       DTR OPERATIONS - SUMMARY OF EMPLOYEE DTR PAGE ::::</strong></font></td>
    </tr>
     <tr bgcolor="#FFFFFF">
      <td height="25" ><strong><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    
    <tr>
      <td height="24">&nbsp;</td>
      <td width="17%" height="24">Date</td>
      <td height="24"><select name="DateDefaultSpecify" onChange='ReloadPage();'>
        <option value="0" >Default cut-off date</option>
        <% if (WI.fillTextValue("DateDefaultSpecify").equals("1")){ %>
        <option value="1" selected>Specify date</option>
        <%}else{%>
        <option value="1">Specify date</option>
        <%}%>
        <% if (WI.fillTextValue("DateDefaultSpecify").equals("2")){ %>
        <option value="2" selected>Month / year</option>
        <%}else{%>
        <option value="2">Month / year</option>
        <%}%>
				
      </select></td>
    </tr>
	<% if (WI.fillTextValue("DateDefaultSpecify").equals("1")) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Specific Date range </td>
      <td height="25">
From
  <input name="from_date" type="text" size="10" maxlength="10"
	  value="<%=WI.fillTextValue("from_date")%>" class="textbox"
	  onKeyUp="AllowOnlyIntegerExtn('dtr_op','from_date','/');"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','from_date','/')">
  <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;to
        &nbsp;&nbsp;
        <input name="to_date" type="text" size="10" maxlength="10"
		value="<%=WI.fillTextValue("to_date")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'"
		onKeyUP = "AllowOnlyIntegerExtn('dtr_op','to_date','/')"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','to_date','/')">
        <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>			</td>
    </tr>
		<%}%>
		<% if (WI.fillTextValue("DateDefaultSpecify").equals("2")) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Month / Year</td>
      <td height="25">
	<select name="strMonth">
  <%
	  int iDefMonth = Integer.parseInt(strMonths);
	  	for (int i = 1; i <= 12; ++i) {
	  		if (iDefMonth == i)
				strTemp = " selected";
			else
				strTemp = "";
	   %>
  <option value="<%=i%>" <%=strTemp%>><%=astrMonth[i]%></option>
  <%} // end for lop%>
</select>
-
<select name="sy_">
  <%=dbOP.loadComboYear(WI.fillTextValue("sy_"),2,1)%>
</select></td>
    </tr>
		<%}%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td>Enter Employee ID </td>
      <td><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"> <label id="coa_info"></label></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><select name="pt_ft">
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select></td>
    </tr>	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3"><select name="employee_category">
        <option value="" selected>ALL</option>
        <%if (WI.fillTextValue("employee_category").equals("0")){%>
        <option value="0" selected>Non-Teaching</option>
        <option value="1">Teaching</option>
        <%}else if (WI.fillTextValue("employee_category").equals("1")){%>
        <option value="0">Non-Teaching</option>
        <option value="1" selected>Teaching</option>
        <%}else{%>
        <option value="0">Non-Teaching</option>
        <option value="1">Teaching</option>
        <%}%>
      </select></td>
    </tr>		
		<%}%>
<% if(WI.fillTextValue("print_by").compareTo("1") != 0){ %>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr bgcolor="#FFFFFF">
            <td width="18%" height="25">Employment Type</td>
            <td width="82%" height="25">
              <%strTemp2 = WI.fillTextValue("emp_type");%>
              <select name="emp_type">
                <option value="">ALL</option>
                <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp2, false)%>
              </select>            </td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            <td height="25"><select name="c_index" onChange="ReloadPage();">
              <option value="">ALL</option>
              <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
            </select></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25">Office</td>
            <td height="25"><select name="d_index" onChange="ReloadPage();">
              <option value="">ALL</option>
              <%if ((strCollegeIndex.length() == 0)){%>
              <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index is null or c_index = 0) ", WI.fillTextValue("d_index"),false)%>
              <%}else if (strCollegeIndex.length() > 0){%>
              <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%>
              <%}%>
            </select></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25">Office/Dept filter</td>
            <td height="25"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters) </td>
          </tr>
        </table></td>
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
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25">Print DTR whose lastname starts with
        <select name="lname_from" onChange="ReloadPage()">
<%
 strTemp = WI.fillTextValue("lname_from");
 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
 for(int i=0; i<28; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
<%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
<%}
}%>
        </select>
        to
        <select name="lname_to">
          <option value="0"></option>
          <%
			 strTemp = WI.fillTextValue("lname_to");

			 for(int i=++j; i<28; ++i){
			 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select> </td>
    </tr>
    <%}//end of print by.
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><br> <input name="proceed" type="image" onClick="ViewRecords();" src="../../../images/form_proceed.gif">      </td>
    </tr>
 </table>
<%
	if (vRetResult!=null) {
		iSearchResult = RE.getSearchCount();
		int iPageCount =  1;

		if (RE.defSearchSize != 0) {
			iPageCount = iSearchResult/RE.defSearchSize;
			if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
		}

	if(iPageCount > 1) {//show this if page cournt > 1%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
	 <tr>

      <td width="66%"><b>Total Result: <%=iSearchResult%>
<% 	strTemp = "checked";
	if (!WI.fillTextValue("show_all").equals("1")) {
	strTemp = "";
%>
	   - Showing(<%=RE.getDisplayRange()%>)
<%}%>
	   </b> &nbsp;&nbsp;&nbsp;
<% if (WI.fillTextValue("SummaryDetail").equals("0")){%>
       <input type="checkbox" name="show_all" value="1" <%=strTemp%>>
       click to show all
<%}%>
	   </td>
		  <td width="26%">&nbsp;
<% if (!WI.fillTextValue("show_all").equals("1")) {%>

		  Jump To page:
		<select name="jumpto" onChange="goToNextSearchPage()">
 <%
	strTemp = request.getParameter("jumpto");
	if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
	for( int i =1; i<= iPageCount; ++i ){
	if(i == Integer.parseInt(strTemp) ){%>
		<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
    <%}else{%>
	   <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
    <%}
	} // end for loop
%>
	   </select>

<%}%>
	   </td>
	    <td width="8%">&nbsp;</td>
	 </tr>
  </table>
 <%}//show jump page if page count > 1

 } // if ( PrintPage is not called.)
 %>
 	<%if(vDayInterval != null && vDayInterval.size() > 0){%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr >
      <td height="25" colspan="2" align="center"  class="thinborder"><strong>DTR
        DETAILS (From <%=strDateFr%> to <%=strDateTo%>)</strong></td>
    </tr>
	</table>	
	<table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">		
    <tr >
      <td width="12%" height="25" align="center" class="thinborder"><strong>Name</strong></td>
			<%for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){%>
      <td align="center" class="thinborder"><%=WI.formatDate((String)vDayInterval.elementAt(iDay),9)%><br>
<%=(String)vDayInterval.elementAt(iDay+1)%></td>			
			<%}%>
			<td width="8%" align="center" class="thinborder">Total W.Hours </td>
      <td width="8%" align="center" class="thinborder">Total Late/UT/<br>
      Absences</td>
      <td width="8%" align="center" class="thinborder">Overtime</td>
    </tr>
    <tr>
      <td height="25" class="NoBorder">&nbsp;</td>
			<%for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){
			strHoliday = "";
			if (vRetHolidays != null && vRetHolidays.size() > 0 &&
				((String)vRetHolidays.elementAt(1)).equals((String)vDayInterval.elementAt(iDay))){
				strHoliday = (String)vRetHolidays.remove(0);
				vRetHolidays.removeElementAt(0);
			} 
			%>
      <td height="25" align="right" class="NoBorder">&nbsp;<%=strHoliday%></td>			
			<%}%>
			<td align="right" class="NoBorder">&nbsp; </td>
      <td align="right" class="NoBorder">&nbsp;</td>
	    <td align="right" class="NoBorder">&nbsp;</td>
    </tr>
<%

 if (vRetResult!=null && vRetResult.size() > 0) {
//	long lSubTotalWorkingHr = 0l;//sub total total working hour of employee.
	long lGTWorkingHr = 0l;//Total working hour of the employee for the specified date.
	long lOTHours = 0l; // Total OT hour for the day
	double dOTTotal = 0d; // Total OT Hours for the specified date
	double dHoursWork = 0d;
	long lTotalLateUt = 0l;
	long lLateUt = 0l;
	String strBGColor = "";

	double dTotalHoursWork = 0d;
//as requestd, i have to show all the days worked and non worked.
  for (int i=0; i<vRetResult.size() ; i+=7){
 		dTotalHoursWork = 0d;
		dOTTotal = 0d;
		lLateUt = 0l;
		lTotalLateUt = 0l;
		dAwol = 0d;
 		if(i%14 == 7){
			strBGColor = "#CCCCCC";
		}else{
			strBGColor = "";
		}
		
		vTempHoliday = new Vector();
	  strTemp = (String)vRetResult.elementAt(i+3);

	if(strTemp == null)
		strTemp = (String)vRetResult.elementAt(i+4);
	else if(vRetResult.elementAt(i+4) != null)
		strTemp += "/"+(String)vRetResult.elementAt(i+4);

	vRetEDTR = RE.getDTRDetails(dbOP, (String)vRetResult.elementAt(i), true);
	//vTempHoliday.addAll(vRetHolidays); uncomment this if per employee i display ang holiday
 	
	// leave.. vRetResult.elementAt(i+4)
	
	vEmpLeave = RE.getEmployeeLeave(dbOP, (String)vRetResult.elementAt(i+6),
										strDateFr, strDateTo);
 //System.out.println("vEmpLeave : "  + vEmpLeave);
		
	// trainings / ob / otin
	vRetOBOT = RE.getEmpOBOT(dbOP, (String)vRetResult.elementAt(i+6),
										strDateFr, strDateTo);
	//System.out.println("vRetOBOT : "  + vRetOBOT);
	
	// awol records..
	 vAWOLRecords = RE.getAWOLEmployee(dbOP, (String)vRetResult.elementAt(i+6),
										strDateFr, strDateTo);
	//System.out.println("vAWOLRecords : "  + vAWOLRecords);
	
	//Employee Logout..
	vEmpLogout = RE.getEmpLogout(dbOP, (String)vRetResult.elementAt(i+6),
										strDateFr, strDateTo);
	//System.out.println("vEmpLogout : "  + vEmpLogout);
	
	vEmpOvertime = RE.getEmpOverTime(dbOP, (String)vRetResult.elementAt(i+6),
										strDateFr, strDateTo);
	//System.out.println("vEmpOvertime : "  + vEmpOvertime);

	vHoursWork = RE.computeWorkingHour(dbOP, (String)vRetResult.elementAt(i),
												strDateFr, strDateTo, null, null);
	vHoursOT  =  RE.getOTHours(dbOP, (String)vRetResult.elementAt(i),
												strDateFr, strDateTo, null, null);
	vMultipleLogin = RE.getMultipleLogRange(dbOP, (String)vRetResult.elementAt(i),
												strDateFr, strDateTo);		
%>
		
    <tr bgcolor="<%=strBGColor%>">
      <td height="25" class="NoBorder"><%=WI.formatName((String)vRetResult.elementAt(i+1), "", 
												 (String)vRetResult.elementAt(i+2),4).toUpperCase()%></td>
		<%
		 for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){
		 //System.out.println("---------- " + vDayInterval.elementAt(iDay));
			strEmpDayRec = "";
			strTemp = "";
			strTemp2 = "";
			
			if (vRetEDTR == null || vRetEDTR.size() ==  0) {
				// this part here is for the multiple login employees				
				if(vMultipleLogin == null || vMultipleLogin.size() == 0)
					strErrMsg=RE.getErrMsg();
				else{
					iIndexOf = 0;
					while(iIndexOf != -1){
						iIndexOf = vMultipleLogin.indexOf((String)vDayInterval.elementAt(iDay));
 
  						if(iIndexOf != -1){
							//"select tin_tout_fac_index, user_index, login_date, sch_login_time_hr, " + // 0 - 3
							//" sch_login_time_min, sch_login_time_ampm, sch_logout_time_hr, " + // 4 - 6
							//" sch_logout_time_min, sch_logout_time_ampm, actual_login_time_bi, " + // 7 - 9
							//" actual_logout_time_bi, null, null, sch_login_time_bi, sch_logout_time_bi, " + // 14
							//" ut_min, late_min, mins_worked from tin_tout_faculty where is_valid = 1 " + // 17						
							vMultipleLogin.remove(iIndexOf); // remove login_date 2
							vMultipleLogin.remove(iIndexOf); // remove sch_login_time_hr 3
							vMultipleLogin.remove(iIndexOf); // remove sch_login_time_min 4
							vMultipleLogin.remove(iIndexOf); // remove sch_login_time_ampm 5
							vMultipleLogin.remove(iIndexOf); // remove sch_logout_time_hr 6
							vMultipleLogin.remove(iIndexOf); // remove sch_logout_time_min 7
							vMultipleLogin.remove(iIndexOf); // remove sch_logout_time_ampm 8
							vMultipleLogin.remove(iIndexOf); // remove actual_login_time_bi 9
							vMultipleLogin.remove(iIndexOf); // remove actual_logout_time_bi 10
							
							if(strTemp.length() == 0)
								strTemp = (String)vMultipleLogin.remove(iIndexOf); // remove actual time in // null 11
							else
								vMultipleLogin.remove(iIndexOf);

							if((String)vMultipleLogin.elementAt(iIndexOf) != null)
								strTemp2 = (String)vMultipleLogin.remove(iIndexOf);
							else
								vMultipleLogin.remove(iIndexOf);  // remove timeout 12
 							  							
							vMultipleLogin.remove(iIndexOf); // sch_login_time_bi 13
							vMultipleLogin.remove(iIndexOf); // sch_logout_time_bi 14
							
							strUt = (String)vMultipleLogin.remove(iIndexOf); // ut_min 15

							lLateUt = Long.parseLong(WI.getStrValue(strUt,"0"));
							strLate = (String)vMultipleLogin.remove(iIndexOf); // late_min 16

							lLateUt += Long.parseLong(WI.getStrValue(strLate,"0"));
							lTotalLateUt += lLateUt;
							
							dTotalHoursWork += Double.parseDouble((String)vMultipleLogin.remove(iIndexOf)); // hours worked 17
							
							vMultipleLogin.remove(iIndexOf - 1); // user_index 1
							vMultipleLogin.remove(iIndexOf - 2); // tin_tout_fac_indexs			0				
						} // end if(iIndexOf != -1)
					} // end while(iIndexOf != -1)
				}// end else
			}else{
				if (vRetEDTR.size() == 1){//non DTR employees
					strTemp = (String) vRetEDTR.elementAt(0);
 				}else{
					/*
					iIndexOf = 0;
					while(iIndexOf != -1){
						iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
 						if(iIndexOf != -1){
							vRetEDTR.remove(iIndexOf); // remove timein_date
							vRetEDTR.remove(iIndexOf); // remove timeout_date
							strTemp2 = WI.formatDateTime(((Long)vRetEDTR.remove(iIndexOf - 1)).longValue(),2);  // remove timeout
							strTemp  = WI.formatDateTime(((Long)vRetEDTR.remove(iIndexOf - 2)).longValue(),2);  // remove timein
							vRetEDTR.remove(iIndexOf - 3); // remove user_index
							vRetEDTR.remove(iIndexOf - 4); // remove wh_index
							if(strEmpDayRec.length() == 0)
								strEmpDayRec = WI.getStrValue(strTemp,""," - "+strTemp2,"");
							else
								strEmpDayRec += "<br>" + WI.getStrValue(strTemp,""," - "+strTemp2,"");
						}
						//iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
					}			
					*/
					
					iIndexOf = 0;
					while(iIndexOf != -1){
						iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
 						if(iIndexOf != -1){
							vRetEDTR.remove(iIndexOf); // remove timein_date
							vRetEDTR.remove(iIndexOf); // remove timeout_date
							
							strLate = (String)vRetEDTR.remove(iIndexOf); // remove late_time_in
							lLateUt = Long.parseLong(WI.getStrValue(strLate,"0"));
							strUt = (String)vRetEDTR.remove(iIndexOf); // remove under_time
 							lLateUt += Long.parseLong(WI.getStrValue(strUt,"0"));
 							lTotalLateUt += lLateUt;
							
							if(((Long)vRetEDTR.elementAt(iIndexOf - 1)).longValue() > 0)
								strTemp2 = WI.formatDateTime(((Long)vRetEDTR.remove(iIndexOf - 1)).longValue(),2);  // remove timeout
							else
								vRetEDTR.remove(iIndexOf - 1);  // remove timeout	
								
							if(strTemp.length() == 0)
								strTemp  = WI.formatDateTime(((Long)vRetEDTR.remove(iIndexOf - 2)).longValue(),2);  // remove timein
							else
								vRetEDTR.remove(iIndexOf - 2);
							
							vRetEDTR.remove(iIndexOf - 3); // remove user_index
							vRetEDTR.remove(iIndexOf - 4); // remove wh_index
								
						}						
						//iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
					}		
				}
			}// end else 

			strEmpDayRec = WI.getStrValue(strTemp,"","-"+strTemp2,"");					
			strEmpDayRec = ConversionTable.replaceString(strEmpDayRec,"AMPM","");
 			/*
 			if (vEmpLeave != null && vEmpLeave.size() > 0){
				iIndexOf = vEmpLeave.indexOf((String)vDayInterval.elementAt(iDay));
 				if(iIndexOf != -1){
					vEmpLeave.remove(iIndexOf);// remove date
					strHoliday = " leave (" + (String)vEmpLeave.remove(iIndexOf) +")";
	        vEmpLeave.remove(iIndexOf);																
				}else
				strHoliday = "";
			}else
				strHoliday = "";
				*/
				
 			if (vEmpLeave != null && vEmpLeave.size() > 0 &&
						((String)vEmpLeave.elementAt(0)).equals((String)vDayInterval.elementAt(iDay))){
 				vEmpLeave.removeElementAt(0);
				strHoliday = " leave (" + (String)vEmpLeave.remove(0) +")";
                               vEmpLeave.remove(0); 
			}else
				strHoliday = "";		
			
			if (vRetOBOT != null && vRetOBOT.size() > 0 &&
				((String)vRetOBOT.elementAt(0)).equals((String)vDayInterval.elementAt(iDay))){
				vRetOBOT.removeElementAt(0);
				if(strHoliday.length() > 0)
					strHoliday += "<br>";
				strHoliday += " OB/OT";
			}

			if (vAWOLRecords != null && vAWOLRecords.size() > 0 &&
			(ConversionTable.convertMMDDYYYY((Date)vAWOLRecords.elementAt(0)).equals((String)vDayInterval.elementAt(iDay)))){
				vAWOLRecords.removeElementAt(0);
				strTemp = (String)vAWOLRecords.remove(0);
				strHoliday += "Absent (" + CommonUtil.formatFloat(strTemp, true) +")";
				dAwol += Double.parseDouble(strTemp);
 			}

			if (vEmpLogout != null && vEmpLogout.size() > 0 &&
			((String)vEmpLogout.elementAt(0)).equals((String)vDayInterval.elementAt(iDay))){
				vEmpLogout.removeElementAt(0);
				strHoliday += "OL (" + (String)vEmpLogout.remove(0) +")";
			}

			if (vEmpOvertime != null && vEmpOvertime.size() > 0 &&
			((String)vEmpOvertime.elementAt(0)).equals((String)vDayInterval.elementAt(iDay))){
				vEmpOvertime.removeElementAt(0); // date
				strHoliday += "OT (" + (String)vEmpOvertime.remove(0) +")";
			}
			
				if(strHoliday.length() > 0)
					strEmpDayRec += strHoliday;
		
		%>			
      <td height="25" align="right" class="NoBorder">&nbsp;<font size="1"><%=strEmpDayRec%></font></td>			
			<%}// end for loop%>
			<% //System.out.println("vHoursWork main " + vHoursWork);
				if (vHoursWork != null && vHoursWork.size() > 0){		
					for(iCount = 0; iCount < vHoursWork.size(); iCount +=3){
						dHoursWork =((Double)vHoursWork.elementAt(iCount+2)).doubleValue();						
						dTotalHoursWork += dHoursWork;
					}
				} 				
			%>			
			<td align="right" class="NoBorder"><%=CommonUtil.formatFloat(dTotalHoursWork, true)%></td>
			<% strTemp = "";
			if(strSchCode.startsWith("CGH")){			
				if(lTotalLateUt > 0 || dAwol > 0d){
					dTotalHoursWork = ((double)lTotalLateUt/60) + dAwol;
					strTemp = CommonUtil.formatFloat(dTotalHoursWork, 2);
					strTemp = "<br>(" + strTemp + ")";
				}
			}
			%>
      <td align="right" class="NoBorder"><%=CommonUtil.formatFloat((lTotalLateUt + (dAwol*60)), true)%><%=strTemp%></td>
		<%
		if (vHoursOT != null && vHoursOT.size() > 0){
			for(iCount = 0; iCount < vHoursOT.size(); iCount +=3){
				dHoursWork =((Double)vHoursOT.elementAt(iCount+2)).doubleValue();
				dOTTotal += dHoursWork;
			}
		} 
 		%>					
      <td align="right" class="NoBorder"><%=CommonUtil.formatFloat(dOTTotal,true)%></td>
    </tr>
		<%}%>
    <tr>		
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="print_table">
    <tr >
      <td height="25" colspan="6" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
	<tr >
      <td height="25" colspan="6" bgcolor="#FFFFFF" align="center">
			<font size="2">Number of Employees Per Page :</font>
      <select name="num_rec_page">
        <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i =15; i <=45 ; i++) {
				if ( i == iDefault) {%>
        <option selected value="<%=i%>"><%=i%></option>
        <%}else{%>
        <option value="<%=i%>"><%=i%></option>
        <%}
			}%>
      </select>
	  	<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
			<font size="1">click to print</font></td>
    </tr>
</table>
<%}// if (vRetResult)%>
<%}// if vDayInterval%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="footer_">
    <tr bgcolor="#ffffff">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25">&nbsp;</td>
    </tr>
</table>

<input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
<input type=hidden name="viewRecords" value="0">
<input type=hidden name="print_page">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
