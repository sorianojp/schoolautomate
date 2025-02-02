<%@page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil, eDTR.AllowedLateTimeIN" buffer="16kb"%>
<%
	///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode =  "";

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
  	Vector vRetEDTR = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	int iSearchResult =0;
	int iIndex = 0;
	String strOBLabel = " OL (";
	boolean bolHasTeam = false;
	
	if(strSchCode.startsWith("TSUNEISHI"))
		strOBLabel = " Official Business (";
	if(strSchCode.startsWith("EAC"))
		strOBLabel = " OB (";	
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","dtr_view.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"dtr_view.jsp");	
 if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS - Restricted",request.getRemoteAddr(),
														null);
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
if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};

ReportEDTR RE = new ReportEDTR(request);
AllowedLateTimeIN allowedLateTIN = new AllowedLateTimeIN();
Vector vSummaryWrkHours = null;
Vector vHoursWork       = null;
Vector vDayInterval     = null;
Vector vDayIntervalTemp = null;
Vector vHoursOT         = null;
Vector vEmpLogout       = null;//official logout - official business.
Vector vEmpLeave = null;
//additional.
Vector vRestDays    = null;
Vector vRetHolidays = null;
Vector vLateTimeIn  = null;
Vector vSuspended = null;

String strDateFr = null;
String strDateTo = null;

// for lates
// added august 13, 2008
String strLateSetting = null;
String strSQLQuery = null;
int iAllowedLateAm = 0;
int iAllowedLatePm = 0;
int iTempLateAM = 0;
int iTempLatePm = 0;
String strGraceSetting = "";

	vLateTimeIn = allowedLateTIN.operateOnLateSetting(dbOP, request, 3);
	if(vLateTimeIn != null && vLateTimeIn.size() > 0){
		strLateSetting = (String)vLateTimeIn.elementAt(0);
		strGraceSetting = (String)vLateTimeIn.elementAt(3);
	}

if (WI.fillTextValue("viewRecords").equals("1")) { 
	vRetResult = RE.searchEDTR(dbOP, false, true);
	
	
	if (vRetResult == null) 
		strErrMsg = RE.getErrMsg();

//added by biswa to get from and to date.
	if( WI.fillTextValue("DateDefaultSpecify").equals("0")) {
		String[] astrTemp = eDTRUtil.getCurrentCutoffDateRange(dbOP, true);
		if(astrTemp != null) {
			strDateFr = astrTemp[0];
			strDateTo = astrTemp[1];
		}	
	}
	else {
		strDateFr = WI.fillTextValue("from_date");
		strDateTo = WI.fillTextValue("to_date");
	}
	
	if (WI.fillTextValue("SummaryDetail").equals("1")){
		vDayInterval = RE.getDayNDateDetail(strDateFr,strDateTo);
			
		if (vDayInterval == null) 
			strErrMsg = RE.getErrMsg();
		else	
			vDayIntervalTemp = new Vector(vDayInterval);
	}

}
request.setAttribute("date_fr", strDateFr);
request.setAttribute("date_to", strDateTo);

vRetHolidays = RE.getHolidaysOfMonth(dbOP,request, true);//holidays .. 
if(vRetHolidays == null)
	vRetHolidays = new Vector();	


int iNoOfEmpPerPage = 2;
String[] astrWeekDays={"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View/Print DTR</title>
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
	document.dtr_op.submit();
}	
function ReloadPage()
{
//	document.dtr_op.print_page.value="";
	
	document.dtr_op.reloadpage.value="1";
//	document.dtr_op.viewRecords.value ="1";
	document.dtr_op.submit();
}
function ViewDTR(strEmpID,strDateFrom, strDateTo)
{
//popup window here. 
	var pgLoc = "./dtr_view.jsp?DateDefaultSpecify=1&SummaryDetail=1" +
	"&window_opener=1&viewRecords=1&view_one=1&emp_id="
	+escape(strEmpID)+"&from_date="+escape(strDateFrom)+"&to_date="+escape(strDateTo);

	var win=window.open(pgLoc,"EditWindow",'dependent=yes,width=750,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewRecords()
{
//	document.dtr_op.print_page.value="";	
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
}

function PrintPage()
{
	document.getElementById("header_").deleteRow(0);
	document.getElementById("header_").deleteRow(0);

	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	
	document.getElementsByClassName = function(cl) {
		var retnode = [];
		var myclass = new RegExp('\\b'+cl+'\\b');
		var elem = this.getElementsByTagName('*');
		for (var i = 0; i < elem.length; i++) {
			var classes = elem[i].className;
			if (myclass.test(classes)) 
				retnode.push(elem[i]);
		}
			return retnode;
	};
	
   var inputs = document.getElementsByClassName('footer_note');
   for (var i=0;i<inputs.length;i++)       
            inputs[i].style.display = "block";
			
	inputs = document.getElementsByClassName('school_header');
   for (var i=0;i<inputs.length;i++)       
            inputs[i].style.display = "block";				

//document.getElementsByClassName("footer_note").style.display = "table-row";
	
	alert("Please click ok to print");
	window.print();							
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

function GoToNewReport() {
	if(document.dtr_op.from_date)
		location = "./dtr_view.jsp?from_date="+document.dtr_op.from_date.value+
							 "&to_date="+document.dtr_op.to_date.value+
							 "&emp_type="+document.dtr_op.emp_type.value+
							 "&c_index="+document.dtr_op.c_index.value+
							 "&d_index="+document.dtr_op.d_index.value+
 							 "&emp_id="+document.dtr_op.emp_id.value;	
	else
		location = "./dtr_view.jsp?emp_type="+document.dtr_op.emp_type.value+
							 "&c_index="+document.dtr_op.c_index.value+
							 "&d_index="+document.dtr_op.d_index.value+
 							 "&emp_id="+document.dtr_op.emp_id.value;	
		
}

function checkKeyPress(strFormName, strFieldName, strExtn, strKeyCode){
	/*
		strKeyCodes
			35 = end, 36 = home, 37 = left, 38 = up, 39 = right, 40 = down
			8 = backspace, 46 = delete
			96 - 105 - numpad
			48 - 57 - kanang sa taas na numbers
			110 - period sa main
			190 - period sa numpad
			111 - / sa keypad
			191 - / sa main
	*/
	//alert("strKeyCode - " + strKeyCode);
 	if((strKeyCode >= 35 && strKeyCode <= 40)		
		|| (strKeyCode >= 48	&& strKeyCode <= 57)
		|| (strKeyCode >= 96	&& strKeyCode <= 105)
		|| strKeyCode == 8	|| strKeyCode == 46)
		return;
	
	AllowOnlyIntegerExtn(strFormName, strFieldName, strExtn);
}
</script>
<body onLoad="document.getElementById('loading_').innerHTML='';">
<form name="dtr_op" action="./dtr_view_new.jsp" method="post">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="header_" >
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" ><strong>:::: 
      DTR OPERATIONS - VIEW/PRINT DTR PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" ><strong><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong>
	  
	  <label id="loading_" style="font-size:15px; color:#FF0000; font-weight:bold; margin-left:200px;">Loading .... Please wait.... </label></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
		<!--
    <tr> 
      <td height="24">&nbsp;</td>
      <td width="17%" height="24">View/Print Type</td>
      <td height="24">
			  <select name="SummaryDetail">
          <option value="1">Detail</option>
        </select></td>
      <td>Date 
        <select name="DateDefaultSpecify">
          <option value="1">Specify date</option>
        </select> </td>
    </tr>
		-->
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><input type="checkbox" name="show_new" value="1" onClick="GoToNewReport();">
Go to other report format</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td height="25"> Employee ID </td>
      <td height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"><label id="coa_info"></label></td>
      <td width="49%">
        From 
     <input name="from_date" type="text" size="10" maxlength="10" 
	  value="<%=WI.fillTextValue("from_date")%>" class="textbox" 
	  onKeyUp="checkKeyPress('dtr_op','from_date','/',event.keyCode);"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white';checkKeyPress('dtr_op','from_date','/', event.keyCode)"> 
        <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        &nbsp;&nbsp;to 
        &nbsp;&nbsp;
        <input name="to_date" type="text" size="10" maxlength="10" 
		value="<%=WI.fillTextValue("to_date")%>" class="textbox" 
		onfocus="style.backgroundColor='#D3EBFF'" 
		onKeyUP = "checkKeyPress('dtr_op','to_date','/',event.keyCode)"
		onBlur="style.backgroundColor='white';checkKeyPress('dtr_op','to_date','/',event.keyCode)"> 
        <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      </td>
    </tr>
<% if(WI.fillTextValue("print_by").compareTo("1") != 0){ %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><table width="100%" border="0" cellspacing="0" cellpadding="0">
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
                <option value="">N/A</option>
                <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length()<1) strTemp="0";
   if(strTemp.compareTo("0") ==0)
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";
%>
                <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td height="25"><%=strTemp2%></td>
            <td height="25"> <select name="d_index">
                <% if(strTemp.compareTo("") ==0){//only if from non college.%>
                <option value="">All</option>
                <%}else{%>
                <option value="">All</option>
                <%} strTemp3 = WI.fillTextValue("d_index");%>
                <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> </select> </td>
          </tr>
          <%if(bolHasTeam){%>
					<tr bgcolor="#FFFFFF">
            <td height="25">Team</td>
            <td height="25"><select name="team_index">
              <option value="">All</option>
              <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
            </select></td>
          </tr>
					<%}%>
		 <%if(strSchCode.startsWith("EAC")){%>
					<tr bgcolor="#FFFFFF">
            <td height="25">View Option</td>
            <td height="25">			
			<%	strTemp = WI.fillTextValue("bundy_option"); %>
			<select name="bundy_option">
				<option value="0" <%=strTemp.equals("0")?"selected":"" %> >View All</option>
				<option value="1" <%=strTemp.equals("1")?"selected":"" %> >View Bundy Employees only</option>
				<option value="2" <%=strTemp.equals("2")?"selected":"" %> >Don't include Bundy Bmployees</option>
			</select>			
			</td>
          </tr>
		<%}%>			
					
        </table></td>
    </tr>
		
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" height="25"><%=WI.getStrValue(strLateSetting, "Current late setting : <strong>Setting ","</strong>","")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3" height="25">Print DTR whose lastname starts with 
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
      <td height="25" colspan="3">
		<%  
		if(strLateSetting.equals("1")){
	  	if (WI.fillTextValue("show_only_deduct").equals("1"))
				strTemp = "checked";
			else 
				strTemp = "";
	  %>
        <input name="show_only_deduct" type="checkbox" id="show_only_deduct" value="1" <%=strTemp%>>
		check to exclude late within grace period from total late<br>
		<%}// end if strLateSetting.equals("1")%>
<input type="checkbox" name="show_sum" value="checked"<%=WI.fillTextValue("show_sum")%>> Show Late/UT/Absent Summary<br>
		<%
			if(WI.fillTextValue("exclude_ghosts").length() > 0)
				strTemp = " checked";
			else
				strTemp = "";			
		%>
		<input type="checkbox" name="exclude_ghosts" value="1" <%=strTemp%>> show only with dtr<br>
			<%
				if(WI.fillTextValue("show_weekday").length() > 0)
					strTemp = " checked";
				else
					strTemp = "";			
			%>	
			<input type="checkbox" name="show_weekday" value="1" <%=strTemp%>>show weekday
	  </td>
    </tr>
		
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><input name="proceed" type="image" onClick="ViewRecords();" src="../../../images/form_proceed.gif"> 
	  <%if(vRetResult != null && vRetResult.size() > 0) {%>
	  <div align="right">
	  No of Employees Per page : <select name="emp_per_page">
	  <option value="1">One</option>
<%strTemp = WI.fillTextValue("emp_per_page");
if(strTemp.length()> 0)
	iNoOfEmpPerPage = Integer.parseInt(strTemp);
if(iNoOfEmpPerPage == 2)
	strTemp = " selected";
else	
	strTemp = "";
%>	  
	  <option value="2"<%=strTemp%>>Two</option>
	  </select>
	  &nbsp;&nbsp;&nbsp;
	  <a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>	  </div>
	  <div align="left">Total Employees Shown: <%=vRetResult.size()/13%></div>
	  <%}%>      </td>
    </tr>	
 </table>
 
<% if (WI.fillTextValue("viewRecords").equals("1")){ %>

<!--  <table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr > 
      <td height="25" colspan="13" align="center" bgcolor="#B9B292" class="thinborder"><strong><font color="#FFFFFF">DTR 
        DETAILS (From <%=strDateFr%> to <%=strDateTo%>)</font></strong></td>
    </tr>-->
<% 
int iTotalLate = 0; int iFreqLate = 0; 
int iTotalUT   = 0; int iFreqUT   = 0; int iTotalDaysWorked = 0;

int iTotalLateAM = 0; 
int iTotalLatePM = 0; 
int iTotalUTAM   = 0; 
int iTotalUTPM   = 0; int iTemp = 0;

double dTotalAWOL = 0d; double dTemp = 0d;
int iAWOLFreq = 0;
	
 if (vRetResult!=null && vRetResult.size() > 0) {
//	long lSubTotalWorkingHr = 0l;//sub total total working hour of employee.
	long lGTWorkingHr = 0l;//Total working hour of the employee for the specified date.
	long lOTHours = 0l; // Total OT hour for the day


	double dOTTotal = 0l; // Total OT Hours for the specified date
	
	double dTotalHoursWork = 0d;
	//as requestd, i have to show all the days worked and non worked.
	//Vector vDayInterval = RE.getDayNDateDetail(strDateFr,strDateTo);
	boolean bolErrorInWH = false; /// if working hour is not computed - there is error in working hour.
	String strCurDate    = null;

	int iCounter = 0;
	// branch index = college inde or c_index
	Long lHolidayBranch = null;	
	Long lEmployeeBranch = null;
	boolean bolHasHoliday = false;
	
  for (int i=0; i<vRetResult.size() ; i+=13){			
		bolHasHoliday = false;
		lEmployeeBranch = (Long)vRetResult.elementAt(i+9);
		//System.out.println("------------------ employee---------" + lEmployeeBranch);
 	iAllowedLateAm = 0;
	iAllowedLatePm = 0;
///late, ut, 
iTotalLate = 0; iFreqLate = 0; 
iTotalUT   = 0; iFreqUT   = 0; iTotalDaysWorked = 0;

iTotalLateAM = 0; 
iTotalLatePM = 0; 
iTotalUTAM   = 0; 
iTotalUTPM   = 0; iTemp = 0;

dTotalAWOL = 0d; dTemp = 0d;
iAWOLFreq = 0;

	  strTemp = (String)vRetResult.elementAt(i+3);
	
	if(strTemp == null)
		strTemp = (String)vRetResult.elementAt(i+4);
	else if(vRetResult.elementAt(i+4) != null)
		strTemp += "/"+(String)vRetResult.elementAt(i+4); 
		
 	if(vDayIntervalTemp != null)
		vDayInterval = new Vector(vDayIntervalTemp);
 	
if(i > 0 && (i/13 % iNoOfEmpPerPage) == 0){%>
<div style="page-break-after:always">&nbsp;</div>
<%}%>	
	<table width="100%">
	<% //start of school header
   if(strSchCode.startsWith("EAC")){%>
    <tr>
		<td>
			<div align="center" style="display:none" class="school_header"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong> <br>
				<font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
				<font size ="1"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> <br>
			</div>
		</td>
	</tr>
	<%}//end of school header%>
	
	</table>
   <table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">   
	<tr > 
      <td height="25" colspan="10" class="thinborderBOTTOMLEFT"> <%=(String)vRetResult.elementAt(i)%><font color="#0000FF"> :: &nbsp;</font> <font color="#FF0000"><%=(String)vRetResult.elementAt(i+2)%>, <%=(String)vRetResult.elementAt(i+1)%> </font> <font color="#0000FF"> :: &nbsp;</font> <%=WI.getStrValue(strTemp)%><font color="#0000FF"> :: &nbsp;</font> <%=(String)vRetResult.elementAt(i+5)%></td>
      <td height="25" colspan="3" class="thinborderBOTTOM" style="font-size:9px;" align="right"><u>DTR:  <%=strDateFr%> to <%=strDateTo%></u>&nbsp;&nbsp;<br>
	  Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>
    </tr>
    <tr > 
      <td width="10%" height="25" align="center" class="thinborder"><strong><font size="1">Date</font></strong></td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><strong><font size="1">IN</font></strong></td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><strong>Late<br>(Mins)</strong></td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><strong><font size="1">OUT</font></strong></td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><strong>UT<br>(Mins)</strong></td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><strong><font size="1">IN</font></strong></td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><strong>Late<br>(Mins)</strong></td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><strong><font size="1">OUT</font></strong></td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><strong>UT<br>(Mins)</strong></td>
<!--64-->
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Hours Worked <strong><font size="1"> </font></strong></td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><strong><font size="1">OT</font></strong></td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Absent (AWOL)</td>
      <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Remarks</td>
    </tr>
    <%

//long lCurrentTime =  new java.util.Date().getTime();

vRetEDTR   = RE.getDTRDetails(dbOP,(String)vRetResult.elementAt(i),true); 
vHoursWork = RE.computeWorkingHour(dbOP, (String)vRetResult.elementAt(i), strDateFr, strDateTo, null, null);
//System.out.println("jsp vHoursWork :" + vHoursWork);

vHoursOT   = RE.getOTHours(dbOP, (String)vRetResult.elementAt(i), strDateFr, strDateTo, null, null);
//System.out.println("vHoursOT " + vHoursOT);

vRestDays  = RE.getEmployeeRestDays(dbOP, (String)vRetResult.elementAt(i + 6), strDateFr, strDateTo);
//System.out.println("vRestDays " + vRestDays);

vEmpLogout = RE.getEmpLogout(dbOP, (String)vRetResult.elementAt(i + 6), strDateFr, strDateTo);
//System.out.println("vEmpLogout " + vEmpLogout);

vEmpLeave = RE.getEmployeeLeaveAndName(dbOP, (String)vRetResult.elementAt(i+6), strDateFr, strDateTo, strSchCode);
//System.out.println("vEmpLeave " + vEmpLeave);

vSuspended = RE.getEmpSuspensions(dbOP, (String)vRetResult.elementAt(i+6), strDateFr, strDateTo);
//System.out.println("vSuspended " + vSuspended);

  
// awol records..
Vector vAWOLRecords = RE.getAWOLEmployee(dbOP, (String)vRetResult.elementAt(i + 6),
									strDateFr, strDateTo);
//System.out.println("644 jsp view print dtr vAWOLRecords " + vAWOLRecords);
strSQLQuery = "select user_index_ from edtr_no_grace where user_index_ = " + (String)vRetResult.elementAt(i + 6);
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery,0);
// check if in the no grace period table
//      if(strSQLQuery == null && (strLateSetting.equals("2") || strLateSetting.equals("3"))){
if(strSQLQuery == null && vLateTimeIn != null){
	iAllowedLateAm = Integer.parseInt((String)vLateTimeIn.elementAt(1));
	iAllowedLatePm = Integer.parseInt((String)vLateTimeIn.elementAt(2));
}									

if(vRestDays == null)
	vRestDays = new Vector();
if(vEmpLogout == null)
	vEmpLogout = new Vector();
	
if(vAWOLRecords == null)
	vAWOLRecords = new Vector();
else
	for(int a = 0; a < vAWOLRecords.size(); a += 2) 
		vAWOLRecords.setElementAt(ConversionTable.convertMMDDYYYY((java.util.Date)vAWOLRecords.elementAt(a)), a);
		
//System.out.println("vRetEDTR : "  +vRetEDTR);
//System.out.println("vHoursWork : "+vHoursWork);
//System.out.println("vHoursOT : "  +vHoursOT);
//System.out.println("vRetHolidays : "  +vRetHolidays);
//System.out.println("vAWOLRecords : "  + vAWOLRecords);


if (vRetEDTR == null || vRetEDTR.size() ==  0) { 
	strErrMsg=RE.getErrMsg();
}else{
	if (vRetEDTR.size() == 1){//non DTR employees
%>
    <tr> 
      <td height="20" colspan="13" align="center" class="thinborder"><%=vRetEDTR.elementAt(0)%></td>
    </tr>
	
<%}else{
		strTemp3 = "";
		
		String strPrevDate = "";//this is added to avoid displaying date in 2nd row.
		boolean bolDateRepeated = false;
		
	String strLatePMEntry = null;
	String strUTPMEntry = null;
			
	int iIndexOf = 0;
	String strHrsWork = null;

	double dHoursWork = 0d;
	long lCurrenTime  = new java.util.Date().getTime();
	
	String strAbsentAWOL = null; 
	String strHoliday = null;
	boolean bolHasLate = false;
	String strLeave = null;	
	int iIndexOfSuspension = 0;
	String strLoginDate = null;
	String[] astrWeekday = {"","SU","MO","TU","WE","TH","FR","SA"};
	
	for(iIndex = 0; iIndex < vRetEDTR.size(); iIndex +=8){
		iTempLateAM = iAllowedLateAm;
		iTempLatePm = iAllowedLatePm;
			
		strTemp =(String)vRetEDTR.elementAt(iIndex+4);
		
		if (strTemp!=null &&  (iIndex+8) < vRetEDTR.size() && 
			 strTemp.equals((String)vRetEDTR.elementAt(iIndex+12))){
			strTemp = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 10)).longValue(),2);
			strTemp2 = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 11)).longValue(),2);
			strLatePMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+6+8));
			strUTPMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+7+8));			
		}
		else {
			strTemp =  null; 				
			strTemp2 = null;
			strLatePMEntry = "0";
			strUTPMEntry = "0";			
		}
		if(strPrevDate.equals((String)vRetEDTR.elementAt(iIndex+4))) {
			bolDateRepeated = true;
		}
		else {
			bolDateRepeated = false;
			strPrevDate = (String)vRetEDTR.elementAt(iIndex+4);
		}
		//System.out.println(strTemp + "... "+strTemp2);
			
//I ahve to display here for the days employee did not work. 
if(!bolDateRepeated && vDayInterval != null && vDayInterval.size() > 0) {
	while(vDayInterval.size() > 0 && !strPrevDate.equals((String)vDayInterval.elementAt(0))) {
	strAbsentAWOL = "";strHoliday = "";
	bolHasHoliday = false;
	strCurDate = (String)vDayInterval.elementAt(0);
	iIndexOf = vRetHolidays.indexOf(strCurDate);
	if(iIndexOf > -1) {
		lHolidayBranch = (Long)vRetHolidays.elementAt(iIndexOf+1);
		if(lHolidayBranch == null){
			strHoliday = (String)vRetHolidays.elementAt(iIndexOf-1);
			bolHasHoliday = true;		
		}else{
			while(iIndexOf != -1){
				iIndexOf = vRetHolidays.indexOf(strCurDate, iIndexOf+1);
				if(iIndexOf == -1)
					break;
				lHolidayBranch = (Long)vRetHolidays.elementAt(iIndexOf+1);
				if(lHolidayBranch.equals(lEmployeeBranch)){
					strHoliday = (String)vRetHolidays.elementAt(iIndexOf-1);
					bolHasHoliday = true;		
					break;
				}
				
			}
		}
	}

	if (vEmpLeave != null && vEmpLeave.size() > 0 &&
			!bolDateRepeated){		
 		iIndexOf = vEmpLeave.indexOf(strCurDate);
		while(iIndexOf != -1){
			vEmpLeave.remove(iIndexOf);// remove date
			strLeave = (String)vEmpLeave.remove(iIndexOf); // remove leave hours
			vEmpLeave.remove(iIndexOf);// remove leave status
			strLeave = WI.getStrValue((String)vEmpLeave.remove(iIndexOf),"w/out pay") + "(" + strLeave +")";
			vEmpLeave.remove(iIndexOf); // remove free
			vEmpLeave.remove(iIndexOf); // remove free
			vEmpLeave.remove(iIndexOf); // remove free
			vEmpLeave.remove(iIndexOf); // remove free
			vEmpLeave.remove(iIndexOf); // remove free
			vEmpLeave.remove(iIndexOf); // remove free
			strHoliday += strLeave; 
			iIndexOf = vEmpLeave.indexOf(strCurDate);
		}
	}

	if (vEmpLogout != null && vEmpLogout.size() > 0 && 
		((String)vEmpLogout.elementAt(0)).equals(strCurDate) && 
			!bolDateRepeated){
			vEmpLogout.removeElementAt(0);
			strHoliday += strOBLabel + WI.getStrValue((String)vEmpLogout.remove(0),"Whole day") +")";
	}
	
	if(!bolHasHoliday){				
		iIndexOf = vAWOLRecords.indexOf(strCurDate);
		if(iIndexOf > -1) {
			iIndexOfSuspension = -1;
			if(vSuspended != null && vSuspended.size() > 0)
				iIndexOfSuspension = vSuspended.indexOf(strCurDate);
			
			if(iIndexOfSuspension != -1){
				vAWOLRecords.remove(iIndexOf + 1);
				vAWOLRecords.remove(iIndexOf);
				strAbsentAWOL = "Suspended";
			}else{
				dTemp = Double.parseDouble((String)vAWOLRecords.remove(iIndexOf + 1)); 
				vAWOLRecords.remove(iIndexOf);
				dTotalAWOL += dTemp;
				++ iAWOLFreq;
				strAbsentAWOL = " Absent("+dTemp+")";
			}
		}
	}
	%>
  <tr>
    <td height="20" class="thinborder" bgcolor="#CCDDDD" style="font-size:9px; font-weight:bold">
	<%=(String)vDayInterval.remove(0) +"-"+((String)vDayInterval.remove(0)).substring(0,2)%></td>
    <td height="20" class="thinborder" colspan="11" align="center" bgcolor="#CCDDDD">&nbsp;<b><%=strHoliday%></b></td>
    <td height="20" class="thinborder" align="center" bgcolor="#CCDDDD">&nbsp;
	<%if(vRestDays.indexOf(strCurDate) != -1){%> - Rest Day <%}%>
	<%=strAbsentAWOL%></td>
  </tr>
  <%}//end of while looop
  if(vDayInterval.size() > 0)  {
  	vDayInterval.removeElementAt(0);
		vDayInterval.removeElementAt(0);
  }
  
}//end of if condition to print holidays.%>
    <tr> 
      <td height="20" class="thinborder">
	    <%if(!bolDateRepeated){
				strLoginDate = (String)vRetEDTR.elementAt(iIndex+4);
			%>
        <%=strLoginDate%>
				<%if(WI.fillTextValue("show_weekday").length() > 0){%>
					<%=astrWeekday[eDTR.eDTRUtil.getWeekDay(strLoginDate)]%>
				<%}%>				
        <%}else{%>
				&nbsp;
        <%}%>
	  </td>
      <td class="thinborder"><%++iTotalDaysWorked;//one more day worked.. %>
	  <%=WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),2)%></td>
      <td class="thinborder">
	  <% bolHasLate = false;
		if(vRetEDTR.elementAt(iIndex + 6) != null)
			iTemp = Integer.parseInt(WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6), "0"));
		else
			iTemp = 0;
		if(iTemp > 0) {		
			if(strGraceSetting.equals("1"))
				bolHasLate = true;
			if(WI.fillTextValue("show_only_deduct").equals("1")){				
				if(iTemp <= iTempLateAM)
					iTemp = 0;
			}			
			iTotalLateAM += iTemp;
			iTotalLate += iTemp;
			++iFreqLate;
		}
		
	  	iTemp = Integer.parseInt(WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7), "0"));
		if(iTemp > 0) {
			iTotalUTAM += iTemp;
			iTotalUT   += iTemp;
			++iFreqUT;
		}
	  	iTemp = Integer.parseInt(WI.getStrValue(strLatePMEntry, "0"));
		if(iTemp > 0) {
			if(WI.fillTextValue("show_only_deduct").equals("1")){
				if(bolHasLate)
					iTempLatePm = 0;
				if(iTemp <= iTempLatePm)
					iTemp = 0;
			}		
			iTotalLatePM += iTemp;
			iTotalLate   += iTemp;
			++iFreqLate;
		}
	  	iTemp = Integer.parseInt(WI.getStrValue(strUTPMEntry, "0"));
		if(iTemp > 0) {
			iTotalUTPM += iTemp;
			iTotalUT   += iTemp;
			++iFreqUT;
		}
		%>		
	  <%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6))%>&nbsp;</td>
      <td class="thinborder"><%=WI.getStrValue(WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 3)).longValue(),2),
	  								"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7),"0")%>&nbsp;</td>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder"><%=strLatePMEntry%>&nbsp;</td>
      <td class="thinborder"><%=WI.getStrValue(strTemp2,"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strUTPMEntry,"0")%>&nbsp;</td>
      <%  // compute for the working hour for the day
		
//		System.out.println("heellow world");
		
		if(strTemp2 != null) iIndex += 8; 
		

//	 ---- Updated to Vector.. 
//		lSubTotalWorkingHr = RE.computeWorkingHour(dbOP, (String)vRetResult.elementAt(i), 
//								(String)vRetEDTR.elementAt(iIndex+4));
		

//		System.out.println("lSubTotalWorkingHr : " + lSubTotalWorkingHr);

//		lOTHours = RE.getOTHours(dbOP,(String)vRetResult.elementAt(i),
//								(String)vRetEDTR.elementAt(iIndex+4));

//		if (lSubTotalWorkingHr < 0) lSubTotalWorkingHr = 0l;
//		if (lOTHours < 0) lOTHours = 0l;
		
//		if (!strTemp3.equals((String)vRetEDTR.elementAt(iIndex+4))){
//				strTemp3  = (String)vRetEDTR.elementAt(iIndex+4);
//				lGTWorkingHr += lSubTotalWorkingHr;
//				lOTTotal +=lOTHours;
//		}else{
//			lSubTotalWorkingHr = 0l;
//		}
		
		if (vHoursWork != null && vHoursWork.size() > 0){
			
			iIndexOf = vHoursWork.indexOf((String)vRetEDTR.elementAt(iIndex+4));
			if (iIndexOf != -1) {
				vHoursWork.removeElementAt(iIndexOf-1);vHoursWork.removeElementAt(iIndexOf-1);
				dHoursWork =((Double)vHoursWork.remove(iIndexOf-1)).doubleValue();
				strHrsWork = CommonUtil.formatFloat(dHoursWork,true);
				dTotalHoursWork += dHoursWork;
			} 
		}
	%>
      <td class="thinborder">&nbsp;
        <%if(iIndexOf != -1){%>
        <%=WI.getStrValue(strHrsWork)%>
        <%}%></td>
	
<%iIndexOf = -1;
		dHoursWork = 0d;
		//System.out.println("vHoursOT " + vHoursOT);
		if (vHoursOT != null && vHoursOT.size() > 0){			
			iIndexOf = vHoursOT.indexOf((String)vRetEDTR.elementAt(iIndex+4));
			while (iIndexOf != -1) {
				vHoursOT.removeElementAt(iIndexOf-1);
				vHoursOT.removeElementAt(iIndexOf-1);
				dTemp = ((Double)vHoursOT.remove(iIndexOf-1)).doubleValue();				
				dHoursWork += dTemp;
				strHrsWork = CommonUtil.formatFloat(dHoursWork,true);
				dOTTotal += dTemp;				
				iIndexOf = vHoursOT.indexOf((String)vRetEDTR.elementAt(iIndex+4));
			}
		} 
 		%>
		
      <td class="thinborder">&nbsp;<%=(dHoursWork > 0d)?strHrsWork:""%>	  </td>
<%
	  //get here AWOL.. 
	  iIndexOf = vAWOLRecords.indexOf(vRetEDTR.elementAt(iIndex+4));
		if(iIndexOf > -1) {
				iIndexOfSuspension = -1;
				if(vSuspended != null && vSuspended.size() > 0)
					iIndexOfSuspension = vSuspended.indexOf(vRetEDTR.elementAt(iIndex+4));
		
				if(iIndexOfSuspension != -1){
					vAWOLRecords.removeElementAt(iIndexOf + 1);
					vAWOLRecords.removeElementAt(iIndexOf);
					strAbsentAWOL = "Suspended";
				}else{
					dTemp = Double.parseDouble((String)vAWOLRecords.remove(iIndexOf + 1)); 
					vAWOLRecords.remove(iIndexOf);
					dTotalAWOL += dTemp;
					++ iAWOLFreq;
					strAbsentAWOL = CommonUtil.formatFloat(dTemp, false);
				}		
 		}
		else
			strAbsentAWOL = "&nbsp;";
//	System.out.println("Emp logout Date : "+vEmpLogout.elementAt(0));
%>
      <td class="thinborder">&nbsp;<%=strAbsentAWOL%></td>
<%
strAbsentAWOL = "";
if (vEmpLeave != null && vEmpLeave.size() > 0 &&
		!bolDateRepeated){		
 		iIndexOf = vEmpLeave.indexOf(vRetEDTR.elementAt(iIndex + 4));
		while(iIndexOf != -1){
			vEmpLeave.remove(iIndexOf);// remove date
			strLeave = (String)vEmpLeave.remove(iIndexOf); // remove leave hours
			vEmpLeave.remove(iIndexOf);// remove leave status
			strLeave = WI.getStrValue((String)vEmpLeave.remove(iIndexOf),"w/out pay") + "(" + strLeave +")";
			vEmpLeave.remove(iIndexOf); // remove free
			vEmpLeave.remove(iIndexOf); // remove free
			vEmpLeave.remove(iIndexOf); // remove free
			vEmpLeave.remove(iIndexOf); // remove free
			vEmpLeave.remove(iIndexOf); // remove free
			vEmpLeave.remove(iIndexOf); // remove free
			strAbsentAWOL += strLeave; 
			iIndexOf = vEmpLeave.indexOf(vRetEDTR.elementAt(iIndex + 4));
		}
	}
if (!bolDateRepeated && vEmpLogout.size() > 0 && vEmpLogout.elementAt(0).equals(vRetEDTR.elementAt(iIndex + 4))){
	vEmpLogout.removeElementAt(0);
	strAbsentAWOL += strOBLabel + (String)vEmpLogout.remove(0) +")";
}
else
	strAbsentAWOL += "&nbsp;";
%>
      <td class="thinborder"><%=strAbsentAWOL%></td>
    </tr>
    <% 
	  } // end for loop
//	  System.out.println("Time : " + (lCurrenTime - new java.util.Date().getTime()));

	  //I have to now print if there are any days having zero working hours.
	while(vDayInterval != null && vDayInterval.size() > 0) {
	strHoliday = "";
	strAbsentAWOL = "";
	bolHasHoliday = false;
	strCurDate = (String)vDayInterval.elementAt(0);
	iIndexOf = vRetHolidays.indexOf(strCurDate);
	if(iIndexOf > -1) {		
		//lHolidayBranch = (Long)vRetHolidays.elementAt(iIndexOf+1);
		//if(lHolidayBranch == null){
		//	strHoliday = (String)vRetHolidays.elementAt(iIndexOf-1);
		//} else{
		//	if(lHolidayBranch.equals(lEmployeeBranch))
		//		strHoliday = (String)vRetHolidays.elementAt(iIndexOf - 1);		
		//}

		lHolidayBranch = (Long)vRetHolidays.elementAt(iIndexOf+1);
		if(lHolidayBranch == null){
			strHoliday = (String)vRetHolidays.elementAt(iIndexOf-1);
			bolHasHoliday = true;		
		}else{
			lHolidayBranch = (Long)vRetHolidays.elementAt(iIndexOf+1);
		
			if(lHolidayBranch.equals(lEmployeeBranch)){
				strHoliday = (String)vRetHolidays.elementAt(iIndexOf-1);
				bolHasHoliday = true;		
 			}
			while(iIndexOf != -1 && !bolHasHoliday){
				iIndexOf = vRetHolidays.indexOf(strCurDate, iIndexOf+1);
				if(iIndexOf == -1)
					break;
				lHolidayBranch = (Long)vRetHolidays.elementAt(iIndexOf+1);
				if(lHolidayBranch.equals(lEmployeeBranch)){
					strHoliday = (String)vRetHolidays.elementAt(iIndexOf-1);
					bolHasHoliday = true;		
					break;
				}
			}
		}
	}
	
	if (vEmpLeave != null && vEmpLeave.size() > 0 &&
		!bolDateRepeated){
		
			iIndexOf = vEmpLeave.indexOf(strCurDate);
			while(iIndexOf != -1){
 				vEmpLeave.remove(iIndexOf);// remove date
				strLeave = (String)vEmpLeave.remove(iIndexOf); // remove leave hours
        vEmpLeave.remove(iIndexOf);// remove leave status
				if(strSchCode.startsWith("AUF")){
					vEmpLeave.remove(iIndexOf);// remove leave type
					strLeave = "Leave(" + strLeave +")";
				}else{
					strLeave = WI.getStrValue((String)vEmpLeave.remove(iIndexOf),"w/out pay") + "(" + strLeave +")";
				}
				vEmpLeave.remove(iIndexOf); // remove free
				vEmpLeave.remove(iIndexOf); // remove free
				vEmpLeave.remove(iIndexOf); // remove free
				vEmpLeave.remove(iIndexOf); // remove free
				vEmpLeave.remove(iIndexOf); // remove free
				vEmpLeave.remove(iIndexOf); // remove free
				strHoliday += strLeave; 
				iIndexOf = vEmpLeave.indexOf(strCurDate);
			}
	}

	if(!bolHasHoliday){
		iIndexOf = vAWOLRecords.indexOf(strCurDate);
		if(iIndexOf > -1) {
				iIndexOfSuspension = -1;
				if(vSuspended != null && vSuspended.size() > 0)
					iIndexOfSuspension = vSuspended.indexOf(strCurDate);
		
				if(iIndexOfSuspension != -1){
					vAWOLRecords.remove(iIndexOf+1);
					vAWOLRecords.remove(iIndexOf);
					strAbsentAWOL = "Suspended";
				}else{
					dTemp = Double.parseDouble((String)vAWOLRecords.remove(iIndexOf + 1)); 
					vAWOLRecords.remove(iIndexOf);
					dTotalAWOL += dTemp;
					++ iAWOLFreq;
					strAbsentAWOL = " Absent1("+dTemp+")";	
				}		
		}
	}
	
	if (vEmpLogout != null && vEmpLogout.size() > 0 &&
		((String)vEmpLogout.elementAt(0)).equals(strCurDate) &&
		!bolDateRepeated){			
			vEmpLogout.removeElementAt(0);
			strHoliday += strOBLabel + WI.getStrValue((String)vEmpLogout.remove(0),"Whole day") +")";
	}
	%>
  <tr>
    <td height="20" class="thinborder" bgcolor="#CCDDDD" style="font-size:9px;">
	<%=(String)vDayInterval.remove(0)+"-"+((String)vDayInterval.remove(0)).substring(0,2)%></td>
    <td height="20" class="thinborder" colspan="11" align="center" bgcolor="#CCDDDD">&nbsp;<b><%=strHoliday%></b></td>
    <td height="20" class="thinborder" bgcolor="#CCDDDD">&nbsp;
	<%if(vRestDays.indexOf(strCurDate) != -1){%> - Rest Day <%}%>
	<%=strAbsentAWOL%></td>
  </tr>
  <%}//end of while looop
	 }
	} 
	%>
    <tr > 
      <td height="20" align="right" class="thinborder" style="font-size:9px; font-weight:bold">TOTAL&nbsp;&nbsp;</td>
      <td height="20" class="thinborder" style="font-size:9px; font-weight:bold">Days Worked: <%=iTotalDaysWorked%></td>
      <td height="20" class="thinborder" style="font-size:9px; font-weight:bold"><%=iTotalLateAM%>&nbsp;</td>
      <td height="20" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;</td>
      <td height="20" class="thinborder" style="font-size:9px; font-weight:bold"><%=iTotalUTAM%>&nbsp;</td>
      <td height="20" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;</td>
      <td height="20" class="thinborder" style="font-size:9px; font-weight:bold"><%=iTotalLatePM%>&nbsp;</td>
      <td height="20" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold"><%=iTotalUTPM%>&nbsp;</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold"> <%=CommonUtil.formatFloat(dTotalHoursWork,true)%></td>
      <td class="thinborder" style="font-size:9px; font-weight:bold"> <%=CommonUtil.formatFloat(dOTTotal,true)%></td>
      <td class="thinborder" style="font-size:9px; font-weight:bold"><%=dTotalAWOL%>&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" cellspacing="0" cellpadding="0">
  <tr>
  	<td width="75%" style="font-size:9px;" valign="top">Printed By : <%=(String)request.getSession(false).getAttribute("first_name")%></td>
  	<td width="25%" style="font-size:9px;" valign="top"> <%if(WI.fillTextValue("show_sum").length() > 0) {%>
		<u>Summary :</u><br>Late Freq : <%=iFreqLate%><br>UT Freq : <%=iFreqUT%><br>Absent Freq : <%=iAWOLFreq%><%}%>
	</td>
  </tr>
  <%
  //eac has some additional line here..sul11222012ss
  if(strSchCode.startsWith("EAC")){%>
  <tr >
  	<td colspan="2">
	  <div style="display:none" class="footer_note">
	  <table width="100%">
	  <tr>
		<td align="left" colspan="2"> 
			<font size="1px"> <br />I hereby certify that the entries on the time record which were made by myself at the <br />time of arrival at and departure from office, are true and correct.</font>
		</td>  
	  </tr>	 
	  <tr >
		<td width="75%" >&nbsp; </td>
		<td width="25%" align="left">
			<font size="1px">____________________________</font><font size="1px"><br >
			 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Employee's Signature</font>
		</td>  
	  </tr>
	  <tr>
		<td>&nbsp; </td>
		<td align="left">
			<font size="1px"><br ><br >____________________________<br >  &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Supervisor / Head<br ><br ></font>
		</td>  
	  </tr>
	  </table>
	  </div>
	 </td>
	 </tr> 
  <%}
  %>
  
  
  
  </table>
    <%
	dTotalHoursWork = 0d;
	dOTTotal = 0d;
	}
	 %>
 <%}else{///show only if vRetResult!=null && vRetResult.size() > 0%>
    <table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
	<tr > 
      <td height="25" colspan="13"><strong><%=WI.getStrValue(strErrMsg)%></strong> <br> <br>        <strong>O RECORD FOUND</strong></td>
    </tr>
    </table>
	<%}///end of priting edtr working hour information.%>
<% }// end if(vRetEDTR == null || vRetEDTR.size() ==  0)%>

<input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
<input type=hidden name="viewRecords" value="0">
<input type=hidden name="print_page" value="1">
<input type="hidden" name="SummaryDetail" value="1">
<input type="hidden" name="DateDefaultSpecify" value="1">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>