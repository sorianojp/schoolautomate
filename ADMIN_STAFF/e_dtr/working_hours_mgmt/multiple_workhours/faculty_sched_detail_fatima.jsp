<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportMultipleWH, java.util.Date,java.util.Calendar, payroll.PRHolidays,payroll.PRFaculty" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(7);
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0){
		bolMyHome = true;
		strColorScheme = CommonUtil.getColorScheme(9);
	}	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty schedule details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.bgDynamic {
		background-color:<%=strColorScheme[1]%>
	}

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;
    }
 
	.txtbox_noborder {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		text-align:right;
		border: 0; 
	}
 
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
 	function ViewRecords(){
		document.form_.print_page.value = "";
		document.form_.page_action.value = 4;
 		document.form_.show_list.value = 1;
		this.SubmitOnce('form_');
	}  
 
	function focusID() {
		if(!document.form_.emp_id)
			return;
		document.form_.emp_id.focus();
	}
	
	function OpenSearch() {
		var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

	function PrintPage(){
		document.form_.print_page.value="1";
		this.SubmitOnce('form_');
	}

	
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
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
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
 
</script>
<body bgcolor="#D2AE72" <%if(!bolMyHome){%>onLoad="focusID();"<%}%> class="bgDynamic">
<%

	DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode = 
				WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
				
	if (WI.fillTextValue("print_page").equals("1")) {%> 
	<jsp:forward page="./faculty_sched_detail_print.jsp" />
<%  return;}

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","faculty_sched_detail.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(),
														"faculty_sched_detail.jsp");
strTemp = (String)request.getSession(false).getAttribute("userId");

if (strTemp != null ){
	if(bolMyHome){
		iAccessLevel = 1;
		request.setAttribute("emp_id",strTemp);
	}
}

if (strTemp == null)
	strTemp = "";
															
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

///// exclusive for testers only.. 
String strUserID = (String)request.getSession(false).getAttribute("userId");
//////////////////


ReportMultipleWH TInTOut = new ReportMultipleWH();
Vector vRetResult = null;
Vector vFacultyRate = null;
String[] astrSubjType = {"Lec", "Lab", "RLE", "NSTP","GRAD"};
String[] astrWeekday = {"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"};
double[] adSubjTotal = new double[5];
double[] adSubjRendered = new double[5];
double[] adFacultyRate = new double[5];
double dDuration = 0d;
double dDeducted = 0d;
double dAmountCredited = 0d;
String strSubjType = "0";
String strDateFr = WI.fillTextValue("login_fr");
String strDateTo = WI.fillTextValue("login_to");
boolean bolShowEquivalent = (WI.fillTextValue("show_equivalent").length() > 0);
int iSubjType = 0;
int iCols = 0;

//// start of additional variables for fatima holiday and suspension
    
    if(strSchCode == null)
        strSchCode = "";   
    boolean bolIsHoliday = false;
    boolean bolIsClassSuspend = false;
    double dTotalPay = 0d;
    Date odTemp = null;
    int iIndexOf = 0;
    double dMultiplier = 0d;
    boolean bolHolidayButNotSP = false;
    
    double dHolidayHours = 0d;
    double dHolidayPay = 0d;
    
    String strSubType = null;
    double dLoadHours = 0d;
    double[] dUserRates = new double[7];
    double dRate = 0d;   
    Vector vHolidays = new Vector();    
    Vector vSuspensions = new Vector(); 
    //// end of additional variables 
	
  String[] astrConverAMPM = {"AM","PM"};
	
	if (bolMyHome)
		strTemp = (String)request.getSession(false).getAttribute("userId");
	else
		strTemp = WI.fillTextValue("emp_id");

	vRetResult = TInTOut.viewFacultyDtrDetails(dbOP, request);
	
	if (vRetResult == null || vRetResult.size() == 0){
		strErrMsg  = TInTOut.getErrMsg();
	}else{
		vFacultyRate = TInTOut.getFacultyRateDetails(dbOP, strTemp, strDateFr, strDateTo);
 		if(vFacultyRate != null && vFacultyRate.size() > 0){
			adFacultyRate[0] = Double.parseDouble((String)vFacultyRate.elementAt(10));
			adFacultyRate[1] = Double.parseDouble((String)vFacultyRate.elementAt(11));
			adFacultyRate[2] = Double.parseDouble((String)vFacultyRate.elementAt(12));
			adFacultyRate[3] = Double.parseDouble((String)vFacultyRate.elementAt(13));
			adFacultyRate[4] = Double.parseDouble((String)vFacultyRate.elementAt(14));
		}else{
			strErrMsg  = TInTOut.getErrMsg();
		}
	}
%>

<form action="./faculty_sched_detail_fatima.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        DTR OPERATIONS - EDIT TIME-IN TIME-OUT PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25">
	  		<%if(!bolMyHome) {%>
				<%if(WI.fillTextValue("viewonly").length() == 0){%>
				&nbsp;<a href="./working_hour_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a>
				<%}%>
			<%}%>
			 <strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
	<%if(WI.fillTextValue("viewonly").length() == 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(!bolMyHome){%>
		<tr>
      <td height="23">&nbsp;</td>
      <td height="23" nowrap>Employee ID </td>
      <td width="18%" height="23">
        <input name="emp_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16"
	   onKeyUp="AjaxMapName(1);"></td>
      <td width="63%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a>
      <label id="coa_info"></label></td>
    </tr>
		<%}else{%>
			<input name="emp_id" type="hidden" value="<%=WI.fillTextValue("emp_id")%>">
		<%}%>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Date </td>
      <td height="20" colspan="2">
<%
strTemp = WI.fillTextValue("login_fr");
//if(strTemp.length() == 0)
//	strTemp = WI.getTodaysDate(1);
%>	  <input name="login_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.login_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
<!--
		&nbsp;&nbsp;<a href="javascript:ClearDate();"><img src="../../../../images/clear.gif" width="55" height="19" border="0" ></a><font size="1">
        clear the date</font> -->to 
<%
strTemp = WI.fillTextValue("login_to");
//if(strTemp.length() == 0)
//	strTemp = WI.getTodaysDate(1);
%>				
<input name="login_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<a href="javascript:show_calendar('form_.login_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
			<%
				if(bolShowEquivalent)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td colspan="3"><input type="checkbox" name="show_equivalent" value="1" <%=strTemp%>>show equivalent late</td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td width="4%" height="35">&nbsp;</td>
      <td width="15%" height="35">&nbsp;</td>
      <td colspan="2"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewRecords();"></td>
    </tr>
		<!--
    <tr>
      <td valign="top">&nbsp;</td>
      <td height="25">Display by </td>
			<%
				strTemp = WI.fillTextValue("group_option");
			%>
      <td height="25" colspan="2">
        <select name="group_option">
          <option value="0" >Date</option>
          <% if (strTemp.equals("1")) {%>
          <option value="1" selected>Subject</option>
          <% }else {%>
          <option value="1">Subject</option>
          <%}%>
        </select>
				</td>
    </tr>
		-->
  </table>
	<%}else{%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="white">
  <tr>
    <td width="4%" height="25">&nbsp;</td>
    <td width="15%" nowrap>Employee ID </td>
		<% if (bolMyHome)
				strTemp = (String)request.getSession(false).getAttribute("userId");
			else
				strTemp = WI.fillTextValue("emp_id"); %>
    <td width="81%">&nbsp;<strong><%=strTemp%></strong></td></tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>Date</td>
    <td><strong>&nbsp;
      <%
strTemp = WI.fillTextValue("login_date");
//if(strTemp.length() == 0)
//	strTemp = WI.getTodaysDate(1);
%>
      <input name="login_date" type="hidden" value="<%=strTemp%>">
      <%=strTemp%>
			
      </strong>to 
      <strong>
      <%
strTemp = WI.fillTextValue("login_date_to");
//if(strTemp.length() == 0)
//	strTemp = WI.getTodaysDate(1);
%>
      <input name="login_date_to" type="hidden"value="<%=strTemp%>">
      <%=strTemp%></strong></td>
  </tr>
	</table>

	<%}%>
  <%
	if ((vRetResult != null) && (vRetResult.size()>0)) {
	
		 //>sul
      if(strSchCode.startsWith("FATIMA")){
	  		String strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
	  		String strSQLLoginFr = ConversionTable.convertTOSQLDateFormat(strDateFr);
	  		String strSQLLoginTo = ConversionTable.convertTOSQLDateFormat(strDateTo);	  
            //get all the holidays
            vHolidays = new payroll.PRHolidays().getHolidayRate(dbOP, strSQLLoginFr, strSQLLoginTo, strEmpIndex);              
            //get all the suspensions
            vSuspensions = new payroll.PRFaculty().getClassSuspensions(dbOP, strEmpIndex, strSQLLoginFr, strSQLLoginTo);
       }      
      //<sul
	 %>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(!bolMyHome){%>
  <tr>
    <td align="right"><a href="javascript:PrintPage()"><img src="../../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click to print</font></td>
  </tr>
<%}%>
</table>

 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
   <tr>
     <td height="25" colspan="11" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF 
       TIME RECORDED FOR ID : <strong><%=WI.fillTextValue("emp_id").toUpperCase()%></strong></strong></td>
   </tr>
</table>

 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
   <tr>
     <td width="14%" height="26" align="center" class="thinborder"><strong>Scheduled Time </strong></td>
     <td width="8%" align="center" class="thinborder"><strong>Time in </strong></td>
     <td width="7%" align="center" class="thinborder"><strong>Loc</strong></td>
     <td width="8%" align="center" class="thinborder"><strong>Time out </strong></td>
     <td width="7%" align="center" class="thinborder"><strong>Loc</strong></td>
     <td width="6%" align="center" class="thinborder"><strong>ACTUAL LATE</strong></td>
     <%if(bolShowEquivalent){%>
		 <td width="6%" align="center" class="thinborder"><strong>EQUIV.<br>
      LATE</strong></td>
		 <%}%>
     <td width="5%" align="center" class="thinborder"><strong>UT</strong></td>
     <td width="7%" align="center" class="thinborder"><strong>SUBJECT TYPE </strong></td>
     <td width="7%" align="center" class="thinborder"><strong>HOURS REQUIRED </strong></td>     
     <td width="7%" align="center" class="thinborder"><strong>HOURS RENDERED </strong></td>	
	 <%if(WI.fillTextValue("show_amount").length() > 0){%>	
     	<td width="9%" align="center" class="thinborder"><strong>AMOUNT CREDIT</strong></td>
	 	<td width="9%" align="center" class="thinborder"><strong>AMOUNT TO DEDUCT </strong></td>	
	 <%}%>	 
	 <td width="9%" align="center" class="thinborder"><strong>LAST ADJUSTED </strong></td>
   </tr>
   <% int iCount = 1;
	 	String strLoginDate = null;
		String strCurrentDate = null;
		Date dtLoginDate = null;
		Calendar calTemp = Calendar.getInstance();
		long lTimeIn = 0;
		long lStartOfSuspension = 0;
		double dTemp = 0d;
		//for(int o = 0; o < 15; o++)
		//	System.out.println("" + WI.formatDate("11/25/2011", o));
 		for(int i = 0; i < vRetResult.size(); i += 35, iCount++){				
	 %>
	 <%
	 	
		if((i == 0 || !((Date)vRetResult.elementAt(i+1)).equals(dtLoginDate)) && !WI.fillTextValue("group_option").equals("1")){
			strLoginDate = ConversionTable.convertMMDDYYYY((Date)vRetResult.elementAt(i+1));
		dtLoginDate = (Date)vRetResult.elementAt(i+1);
	 %>
   <tr>
	 		<%		
			
			if(WI.fillTextValue("show_amount").length() > 0){
				iCols = 14;
			}else{
				iCols = 12;
			}
			if(bolShowEquivalent)
				iCols++;
			%>
     <td height="25" colspan="<%=iCols%>" class="thinborder">&nbsp;<strong><%=WI.formatDate(strLoginDate, 3)%></strong></td>
    </tr>
	 <%}%>
   <tr>
	 	<input type="hidden" name="info_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		<input type="hidden" name="sched_login_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+3)%>">
		<input type="hidden" name="sched_logout_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+7)%>">
     <%
			strTemp = (String)vRetResult.elementAt(i + 4);		
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+5),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" +astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))];
			
			// time to here
			strTemp += " - " + (String)vRetResult.elementAt(i + 8);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+9),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+10))];
			%>
     <td height="19" align="right" nowrap class="thinborder">&nbsp;<%=strTemp%></td>
		 <input type="hidden"	 name="schedule_<%=iCount%>" value="<%=strTemp%>">
		<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+25));
		%>	
     <td align="right" nowrap class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
		 <%
		 strTemp = WI.getStrValue((String)vRetResult.elementAt(i+30));
		 %>		 
		 <td class="thinborder">&nbsp;<%=strTemp%></td>
		 <%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+26));
		%>		 
		 <td align="right" nowrap class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
		 <%	
		 strTemp = WI.getStrValue((String)vRetResult.elementAt(i+31));
		 %>		 		 
		 <td class="thinborder">&nbsp;<%=strTemp%></td>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+20));			
		 %>		 
     <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <%if(bolShowEquivalent){%>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14));			
		 %>		 		 
		 <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <%}%>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13));			
		 %>		 
     <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <%
		 strSubjType = WI.getStrValue((String)vRetResult.elementAt(i + 24),"0");
		 iSubjType = Integer.parseInt(strSubjType);
		 %>
     <td class="thinborder">&nbsp;<%=astrSubjType[iSubjType]%></td>
		<%
				dDuration = Double.parseDouble((String)vRetResult.elementAt(i + 28));
				dDuration = dDuration/3600000;
				adSubjTotal[iSubjType] += dDuration;
				dDeducted = dDuration;
			%>		 
     <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dDuration, false)%> hrs</td><!-- hours required -->
		 <%
		 		 		
			////////////////////// additional code for fatima holiday and suspension rates..sul09222012 \\\\\\\\\\\\\\\|
       		 if(strSchCode.startsWith("FATIMA")){
				 bolHolidayButNotSP = false;  
				 bolIsHoliday = false;
				 bolIsClassSuspend = false;
				 dMultiplier = 0d;    
				 dLoadHours = 0d;
				//This rules are plaily based only on sir Harvey's comments found in PRFaculty (word for word)
				// According to the paper na gihatag sa Fatima
				// "ALL FACULTUES ARE ENTITLED WITH PAY DURING SPECIAL HOLIDAYS"
				// holidays are given higher priority
				// automatic half jud dayon na sa iyang total load for the day
				// skip class suspension code if holiday
				// 02/08/2012
				// ONLY special holidays will be given half day... the rest. walay bayad.
				
				odTemp = (Date) vRetResult.elementAt(i + 1);				
				dRate = adFacultyRate[iSubjType];
            
				if (vHolidays != null && vHolidays.size() > 0) {
					iIndexOf = vHolidays.indexOf(odTemp);
					if (iIndexOf > 0) {
						strTemp = (String) vHolidays.elementAt(iIndexOf - 1);					
						if(strTemp != null){
							if(strTemp.toUpperCase().indexOf("SPECIAL") != -1)
								bolIsHoliday = true;
							else
								bolHolidayButNotSP = true;                    
						}            
					}
				}
				if (!bolIsHoliday && vSuspensions != null && vSuspensions.size() > 0) {
					iIndexOf = vSuspensions.indexOf(odTemp);
					if (iIndexOf != -1) {
						bolIsClassSuspend = true;
						lStartOfSuspension = 0;
						lTimeIn =0 ;
						 
						/**************	commented because suspension pay will be based on the first subject
						* but this one is per subject..sul10042012
						*											
						//compare time in and suspension cut-off to get the appropriate multiplier						
						//time in
						calTemp.set(Calendar.HOUR, Integer.parseInt((String)vRetResult.elementAt(i + 4)));
						calTemp.set(Calendar.MINUTE, Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0")));
						calTemp.set(Calendar.AM_PM, Integer.parseInt((String)vRetResult.elementAt(i+6)));
						lTimeIn = calTemp.getTimeInMillis();		
						//System.out.println("\nlTimeIn " + ConversionTable.ConvertYYYYMMDDHHMMSS(lTimeIn));
						
						//suspension cut-off											
						dTemp = Double.parseDouble((String) vSuspensions.elementAt(iIndexOf + 1));
						calTemp.set(Calendar.HOUR_OF_DAY, (int) dTemp);//HOUR_OF_DAY is already  24 hour based, so no need to set the am_pm				
						
						calTemp.set(Calendar.MINUTE, (int)( (dTemp - (int)dTemp) * 60 ));								
						lStartOfSuspension = calTemp.getTimeInMillis();					
						//System.out.println("lStartOfSuspension " + ConversionTable.ConvertYYYYMMDDHHMMSS(lStartOfSuspension));						
						if(lTimeIn < lStartOfSuspension) //before cut-off
							dMultiplier = Double.parseDouble((String) vSuspensions.elementAt(iIndexOf + 6));
						else
							dMultiplier = Double.parseDouble((String) vSuspensions.elementAt(iIndexOf + 7));
						*/	
						dMultiplier = Double.parseDouble((String) vSuspensions.elementAt(iIndexOf + 5));
					}
				}			   
				dLoadHours = Double.parseDouble((String)vRetResult.elementAt(i + 28));//required hours
				if (bolIsHoliday) {
					dLoadHours = dLoadHours / 2;
					dDeducted = 0d;					
				} else if (bolIsClassSuspend) {
					dLoadHours = dLoadHours * dMultiplier;
				}
				//sul
				if(bolHolidayButNotSP){
					dLoadHours = 0;		
					dDeducted = 0d;
				}					
			dDuration = dLoadHours;											
		 }	
		dDuration = dDuration/3600000;	
		dAmountCredited = dDuration * adFacultyRate[iSubjType];	
		strTemp = CommonUtil.formatFloat(dDuration, true);	
		
		////////// hours rendered \\\\\\\\\\\\\\\
		if(!bolIsClassSuspend  && !bolIsHoliday){
			strTemp = (String)vRetResult.elementAt(i+29);
			dDuration = Double.parseDouble(strTemp);					
			strTemp = CommonUtil.formatFloat(strTemp, false);
			adSubjRendered[iSubjType] += dDuration;
			if(dDuration == 0d)
				strTemp = "";
			dDeducted -= dDuration;
			if(dDeducted < 0)
				dDeducted = 0;				
		}else
			dDeducted = 0;
		%>
     <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, ""," hr(s)","&nbsp;")%>&nbsp;</td>	
	 <%if(WI.fillTextValue("show_amount").length() > 0){%>
     	<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dAmountCredited, true)%>&nbsp;</td>
		<%
			if(dDeducted == 0)
				strTemp = "&nbsp;";
			else	
				strTemp = CommonUtil.formatFloat(dDeducted * adFacultyRate[iSubjType], true);			
		%>		 
		<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>	 			
	<%}%>	
		 <%	
		 strTemp = WI.getStrValue((String)vRetResult.elementAt(i+32));
		 %>		 				
	<td class="thinborder">&nbsp;<%=strTemp%></td>
   </tr>   
   <%}%>
	  <input type="hidden" name="emp_count" value="<%=iCount%>">
 </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
    <td colspan="5" class="thinborder"><strong>HOURS REQUIRED </strong></td>
    </tr>
  <tr>
    <td width="16%" align="center" class="thinborder">Lecture</td>
    <td width="16%" align="center" class="thinborder">Laboratory</td>
    <td width="16%" align="center" class="thinborder">RLE</td>
    <td width="16%" align="center" class="thinborder">NSTP</td>
    <td width="16%" align="center" class="thinborder">Graduate</td>
    </tr>
   <tr>
		<%
		strTemp = null;
		if(adSubjTotal[0] > 0d)
			strTemp = CommonUtil.formatFloat(adSubjTotal[0], true) + " hr(s)";
		%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjTotal[1] > 0d)
			strTemp = CommonUtil.formatFloat(adSubjTotal[1], true) + " hr(s)";
		%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjTotal[2] > 0d)
			strTemp = CommonUtil.formatFloat(adSubjTotal[2], true) + " hr(s)";
		%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjTotal[3] > 0d)
			strTemp = CommonUtil.formatFloat(adSubjTotal[3], true) + " hr(s)";
		%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjTotal[4] > 0d)
			strTemp = CommonUtil.formatFloat(adSubjTotal[4], true) + " hr(s)";
		%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
    </tr>
 </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
    <td colspan="5" class="thinborder"><strong>HOURS RENDERED </strong></td>
    </tr>
  <tr>
    <td width="16%" align="center" class="thinborder">Lecture</td>
    <td width="16%" align="center" class="thinborder">Laboratory</td>
    <td width="16%" align="center" class="thinborder">RLE</td>
    <td width="16%" align="center" class="thinborder">NSTP</td>
    <td width="16%" align="center" class="thinborder">Graduate</td>
    </tr>
   <tr>
		<%
			strTemp = CommonUtil.formatFloat(adSubjRendered[0], true);
		%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
			strTemp = CommonUtil.formatFloat(adSubjRendered[1], true);
		%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
			strTemp = CommonUtil.formatFloat(adSubjRendered[2], true);
		%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
			strTemp = CommonUtil.formatFloat(adSubjRendered[3], true);
		%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
			strTemp = CommonUtil.formatFloat(adSubjRendered[4], true);
		%>
    <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
    </tr>
 </table>
   <%} // end else (vRetResult == null)%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>


 <input type="hidden" name="page_action" value="">
 <input type="hidden" name="print_page">
 <input type="hidden" name="viewonly" value="<%=WI.fillTextValue("viewonly")%>">
 <input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
 <input type="hidden" name="show_amount" value="<%=WI.fillTextValue("show_amount")%>">
 <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
