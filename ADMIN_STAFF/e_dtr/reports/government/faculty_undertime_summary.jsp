<%@page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn, eDTR.eDTRUtil, 
																java.util.Calendar, java.util.Date, eDTR.ReportEDTR" buffer="16kb"%>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if (strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;  
    }
		
		TD.BottomLeftRight {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;  
    }

    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;  
		}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
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

function ViewRecords()
{
	document.dtr_op.print_page.value="";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.submit();
}

function PrintPage() {
	if(document.dtr_op.prepared_by.value == ""){
		alert("Enter prepared by");
		document.dtr_op.prepared_by.focus();
		return;
	}

	if(document.dtr_op.approved_by.value == ""){
		alert("Enter approving officer");
		document.dtr_op.approved_by.focus();
		return;
	}
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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

<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ %>
	<jsp:forward page="./faculty_undertime_print.jsp" />
<%}

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	Calendar calTemp = Calendar.getInstance();
	String strTemp2 = null;
	String strDayCount = null;
	int iSearchResult =0;
	int iIndex = 0;
	int iCount = 1;
	String strMonths = WI.fillTextValue("month_of");
 	String strYear = WI.fillTextValue("year_of");
	if(strMonths.length() == 0)
		strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
	if(strYear.length() == 0)
		strYear = Integer.toString(calTemp.get(Calendar.YEAR));

	//add security herptExtn.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","faculty_undertime_summary.jsp");
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
														"faculty_undertime_summary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
ReportEDTRExtn rptExtn = new ReportEDTRExtn(request);
ReportEDTR RE = new ReportEDTR(request);
if(strErrMsg == null) 
	strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};
String strShowOpt = WI.getStrValue(WI.fillTextValue("DateDefaultSpecify"), "1");
String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};

String strDateFr = null;
String strDateTo = null;
String strAMPM = null;
String strPrevAMPM = null;

Vector vAWOLDates = null;
Vector vEmpAWOL = null;
Integer iUserIndex = null;
Vector vNoWork = null;
Vector vEmpNoWork = null;
Date odTemp = null;
Date odPrevDate = null;
double dDaysAbsent = 0d;
int iTimesAbsent = 0;
String strCheckDate = null;
String strPrevDate = null;

String strToPrint = null;
boolean bolContinuous = false;
boolean bolEnd = false;

String strPrevRestDay = null;
int iIndexOfAwol = 0;
Vector vFinalList = new Vector();

int iIndexOf = 0;
//for(int j = 0; j < 15; j++)
//	System.out.println(WI.formatDate(WI.getTodaysDate(1),j));
if (WI.fillTextValue("viewRecords").equals("1")) {	
	vRetResult = RE.searchEDTR(dbOP, true);
	vAWOLDates = rptExtn.getEmployeeAbsences(dbOP);
	vNoWork = rptExtn.getDaysEmployeeNoWork(dbOP);
	
	if (vRetResult == null)
		strErrMsg = RE.getErrMsg();

	// added by biswa to get from and to date.
	if(WI.fillTextValue("DateDefaultSpecify").equals("0")){
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
}

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="dtr_op" action="./faculty_undertime_summary.jsp" method="post">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="header_">
     <tr bgcolor="#A49A6A">
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
       DTR OPERATIONS - HALF-DAY UNDERTIME PAGE ::::</strong></font></td>
    </tr>
     <tr bgcolor="#FFFFFF">
      <td height="25" ><strong><a href="./gov_reports_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    
    <tr>
      <td height="24">&nbsp;</td>
      <td width="17%" height="24">Date</td>
      <td height="24"><select name="DateDefaultSpecify" onChange='ReloadPage();'>
        <option value="1">Specify date</option>
        <% if (WI.fillTextValue("DateDefaultSpecify").equals("2")){ %>
        <option value="2" selected>Month / year</option>
        <%}else{%>
        <option value="2">Month / year</option>
        <%}%>
				
      </select></td>
    </tr>
	<%if (strShowOpt.equals("1")){%>
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
  <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;to
        &nbsp;&nbsp;
        <input name="to_date" type="text" size="10" maxlength="10"
		value="<%=WI.fillTextValue("to_date")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'"
		onKeyUP = "AllowOnlyIntegerExtn('dtr_op','to_date','/')"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','to_date','/')">
        <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>			</td>
    </tr>
		<%}else if (strShowOpt.equals("2")) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Month / Year</td>
      <td height="25">
	<select name="month_of">
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
<select name="year_of">
  <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
</select></td>
    </tr>
		<%}%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td height="25">Enter Employee ID </td>
      <td height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">
        <label id="coa_info"></label></td>
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
        </table></td>
    </tr>
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
			<%
				strTemp = WI.fillTextValue("show_all");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td height="25" colspan="2"><input type="checkbox" name="show_all" value="1" <%=strTemp%>>
Show all in single page </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("exclude_ghosts");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>			
      <td height="25" colspan="2"><input type="checkbox" name="exclude_ghosts" value="1" <%=strTemp%>> 
        Exclude employees without dtr entry for the period
</td>
    </tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="97%" height="25" colspan="4"><a href="javascript:ViewRecords();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
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
      <td height="25" colspan="2"><hr size="1"></td>
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
<%}%>	   </td>
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

<%}%>	   </td>
     </tr>
  </table>
 <%}//show jump page if page count > 1

 } // if ( PrintPage is not called.)
 %>
 <%
 if (vRetResult!=null && vRetResult.size() > 0) {
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">		
    <tr >
      <td height="25" colspan="2" align="center" class="thinborder"><strong>NAME</strong></td>
      <td align="center" class="thinborder" width="52%">Date When Undertime Occurred</td>			
			<td width="13%" align="center" class="thinborder">Total No. of Days Absent</td>
			<td width="16%" align="center" class="thinborder"><font size="1"> Total No. of Times Half-Day Undertime </font></td>
    </tr>    
<%
	String strBGColor = "";
	int j = 0;
	double dTempCounter = 0d;
	int k = 0;
	String strNoWorkDate = null;
	int iDateCompare = 0;
	String strNextDate = null;
	String strExpNextDate = null;
	boolean bolOkHalfDay = false;
  for (int i=0; i < vRetResult.size() ; i+=7, iCount++){
 		iUserIndex = new Integer((String)vRetResult.elementAt(i+6));
		// System.out.println("iUserIndex " + iUserIndex);
		if(vAWOLDates != null){
			iIndexOf = vAWOLDates.indexOf(iUserIndex);
			if(iIndexOf != -1){
				vAWOLDates.remove(iIndexOf);
				vEmpAWOL = (Vector)vAWOLDates.remove(iIndexOf);			
			}else
				vEmpAWOL = null;			
		}else
			vEmpAWOL = null;
		
		if(vNoWork != null){
			//System.out.println("vNoWork " + vNoWork);
			iIndexOf = vNoWork.indexOf(iUserIndex);
			if(iIndexOf != -1){
				vNoWork.remove(iIndexOf);
				vEmpNoWork = (Vector)vNoWork.remove(iIndexOf);			
			}else
				vEmpNoWork = null;			
		}else
			vEmpNoWork = null;
		
		
		if(vEmpAWOL != null || vEmpNoWork != null){
			//vFinalList
			
			if(vEmpNoWork != null){
				for(j = 0; j < vEmpNoWork.size(); j++){
					strTemp = (String)vEmpNoWork.elementAt(j);
					if(vEmpAWOL != null){
						iIndexOf = vEmpAWOL.indexOf(strTemp);
						if(iIndexOf != -1){
							vEmpAWOL.remove(iIndexOf);
							vEmpAWOL.remove(iIndexOf);
						}
					}
				}				
			}			
		}

		// System.out.println("vEmpAWOL " + vEmpAWOL);
		// System.out.println("vEmpNoWork " + vEmpNoWork);
		
	if(i%14 == 7)
		strBGColor = "#EEEEEE";
	else
		strBGColor = "";
		
  strTemp = (String)vRetResult.elementAt(i+3);

	if(strTemp == null)
		strTemp = (String)vRetResult.elementAt(i+4);
	else if(vRetResult.elementAt(i+4) != null)
		strTemp += "/"+(String)vRetResult.elementAt(i+4);
%>
    <tr bgcolor="<%=strBGColor%>">
      <td width="3%" height="21" align="right" nowrap class="thinborder"><%=iCount%>&nbsp;</td>
			<td width="15%" nowrap class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+1), "", 
												 (String)vRetResult.elementAt(i+2),4).toUpperCase()%></td>
			<%
				//strTemp = CommonUtil.convertVectorToCSV(vEmpAWOL);
				/*
					March 24, 2010
					Warning... codes below were written when i was in a double depression and stupid mode.
					FYI: Stupid mode is the opposite of my autoprogram mode.
					so if naay error, dont be surprised... be more surprised kung walay error
					
					April 5, 2010
					back from vacation, my mind has somewhat cleared a little bit, so i was able to fix
					the problems previously encountered..
				*/
				strTemp = "";
 				dDaysAbsent = 0d;
				iTimesAbsent = 0;
				//System.out.println("---------------------------");
				//System.out.println("vEmpNoWork " + vEmpNoWork);
				//System.out.println("vEmpAWOL " + vEmpAWOL);
				strPrevDate = "";
				strPrevAMPM = "";
				if(vEmpAWOL != null && vEmpAWOL.size() > 0){
					for(j = 0; j < vEmpAWOL.size(); j+=2){
						bolOkHalfDay = false;
						strToPrint = (String)vEmpAWOL.elementAt(j);
						//System.out.println("strToPrint " + strToPrint + " +----------------------+ ");
						strDayCount = (String)vEmpAWOL.elementAt(j+1);
						strAMPM = "";
						bolContinuous = false;
						odTemp = ConversionTable.convertMMDDYYYYToDate(strToPrint);

						calTemp.setTime(odTemp);
						calTemp.add(Calendar.DAY_OF_YEAR, -1);

						strCheckDate = ConversionTable.convertMMDDYYYY(calTemp.getTime());

						//System.out.println("strToPrint " + strToPrint);
						//System.out.println("strPrevDate " + strPrevDate);
						//System.out.println("strCheckDate " + strCheckDate);
						if(!strDayCount.equals("2")){
							if(strDayCount.equals("0"))
								strAMPM = "am";
							else
								strAMPM = "pm";
						}
					
						if(strPrevDate.equals(strCheckDate)){
							if(j > 0){
								if(strPrevAMPM.equals("pm") || strPrevAMPM.length() == 0){
									if(strDayCount.equals("2") || (strDayCount.equals("0")))
										bolOkHalfDay = true;
								}
							}
							
							bolContinuous = true;
							bolEnd = false;
						}else {
							
							if(vEmpNoWork != null){
								//System.out.println("strCheckDate " + strCheckDate);
								while(vEmpNoWork.size() > 0){
									strNoWorkDate = (String)vEmpNoWork.elementAt(0);
									// if (strNoWorkDate > strCheckDate) == 1
									// if (strNoWorkDate = strCheckDate) == 0
									// if (strNoWorkDate < strCheckDate) == -1
									iDateCompare = ConversionTable.compareDate(strNoWorkDate, strCheckDate);
									if(iDateCompare == -1)
										vEmpNoWork.remove(0);
									else
										break;
								}
								
								iIndexOf = vEmpNoWork.indexOf(strCheckDate);
								if(iIndexOf != -1 && strPrevDate.length() > 0){
									vEmpNoWork.remove(iIndexOf);
									// System.out.println("iIndexOf " + iIndexOf);
									if(iIndexOf == 0)
										bolContinuous = true;
 								}
							} else
								bolContinuous = false;
						}
						
						if(strPrevAMPM.equals("am"))
							bolContinuous = false;
						
						if(strDayCount.equals("1")){
							if(j + 2 < vEmpAWOL.size()){
								strNextDate = (String)vEmpAWOL.elementAt(j+2);
								 
								calTemp.setTime(odTemp);
								calTemp.add(Calendar.DAY_OF_YEAR, 1);
								strExpNextDate = ConversionTable.convertMMDDYYYY(calTemp.getTime());
								iDateCompare = ConversionTable.compareDate(strExpNextDate, strNextDate);
								if(iDateCompare == 0 && !((String)vEmpAWOL.elementAt(j+3)).equals("1")){
									bolOkHalfDay = true;
								}
							}
						}
						
						if(strDayCount.equals("2"))
							dTempCounter++;
 						else
							dTempCounter += 0.5d;
						
						strPrevDate = ConversionTable.convertMMDDYYYY(odTemp);
						if(strDayCount.equals("0"))
							strPrevAMPM = "am";
						else if(strDayCount.equals("1"))
							strPrevAMPM = "pm";
						else
							strPrevAMPM = "";

						odPrevDate = odTemp;
						
						if(strDayCount.equals("2") || bolOkHalfDay || bolContinuous)
							continue;

						//System.out.println("strDayCount " + strDayCount);
 						if(strTemp.length() == 0){
 							strTemp = WI.formatDate(strToPrint, 9);							
							strTemp += strAMPM;
							//System.out.println("strTemp------- " + strTemp);	
						} else {
							if(!bolContinuous){
								strTemp += ", " + WI.formatDate(strToPrint, 9) + strAMPM;
 								dTempCounter = 0d;// reset absences counter
 							}
						}

						dDaysAbsent += 0.5d;
						
						if(!bolContinuous)
							iTimesAbsent++;
					}
				}
			%>
      <td height="21" class="thinborder" >&nbsp;<%=strTemp%></td>
			<td align="center" class="thinborder"><%=Double.toString(dDaysAbsent)%></td>
			<td align="center" class="thinborder"><%=iTimesAbsent%></td>
    </tr>
		<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="print_table">
	  <tr>
	    <td width="14%" height="25" align="right" bgcolor="#FFFFFF">Prepared by : </td>
      <td width="32%" height="25" bgcolor="#FFFFFF">
			<input name="prepared_by" type="text" size="32" value="<%=WI.fillTextValue("prepared_by")%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="8%" align="right" bgcolor="#FFFFFF">Title :</td>
			<%
				strTemp = WI.fillTextValue("title_1");
				if(strTemp.length() == 0)
					strTemp = "Administrative Officer V for HRM";
			%>
      <td width="46%" bgcolor="#FFFFFF"><input name="title_1" type="text" size="32" value="<%=strTemp%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  </tr>
	  <tr>
	    <td height="25" align="right" bgcolor="#FFFFFF">Approved by : </td>
			<%
				strTemp = WI.fillTextValue("approved_by");
 				if(strTemp.length() == 0)				
					strTemp = WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"University President",7)),"").toUpperCase();
				if(strTemp.length() == 0)
					strTemp = WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"President",7)),"").toUpperCase();
			%>
      <td height="25" bgcolor="#FFFFFF">
			<input name="approved_by" type="text" size="32" value="<%=strTemp%>" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	    <td height="25" align="right" bgcolor="#FFFFFF">Title :</td>
			<%
				strTemp = WI.fillTextValue("title_2");
				if(strTemp.length() == 0)
					strTemp = "President";
			%>
	    <td height="25" bgcolor="#FFFFFF"><input name="title_2" type="text" size="32" value="<%=strTemp%>" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  </tr>
	  <tr >
      <td height="25" colspan="4" bgcolor="#FFFFFF" align="center">
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
	  	<a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>
			<font size="1">click to print</font></td>
    </tr>
</table>
<%}// if (vRetResult)%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" id="footer_">
    <tr bgcolor="#ffffff">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25">&nbsp;</td>
    </tr>
</table>

<input type="hidden" name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
<input type="hidden" name="viewRecords" value="0">
<input type="hidden" name="for_undertime" value="1">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>