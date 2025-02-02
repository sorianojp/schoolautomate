<%@ page language="java" import="utility.*,health.Dental,java.util.Vector " %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function FocusID() {
	document.form_.stud_id.focus();
}
function ReloadPage() {
	document.form_.reload_page.value = "1";
	document.form_.page_action.value = "";
	document.form_.submit();
}
function UpdateRecord(){
	document.form_.page_action.value = "1";
	document.form_.submit();
}
function CheckStickPerDay() {
	document.form_.sming_sticks_pd.selectedIndex = 0;
	document.form_.sming_age_started.value = "";
}
function CheckAlcohol() {
	document.form_.alcohol_freq.selectedIndex = 0;
}
function OpenSearch() {
<%
if(bolIsSchool){%>
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
<%}else{%>
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.stud_id";
<%}%>
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function AjaxMapName(strPos) {
		var strCompleteName;
			strCompleteName = document.form_.stud_id.value;
			
		if(strCompleteName.length <=2)
			return;
		
		var objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName)+ "&is_faculty=1";
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	//document.form_.stud_id.focus();
	//document.getElementById("coa_info").innerHTML = "";
	document.form_.show_result.value = '1';
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	//do nothing.. 
}
function Print() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<body onLoad="FocusID();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;

	boolean bolNoRecord = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-DENTAL STATUS","statistics.jsp");
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
														"Health Monitoring","DENTAL STATUS",request.getRemoteAddr(),
														"statistics.jsp");
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

Dental dental = new Dental();
Vector vRetResult = null; Vector vTempInfo = null;

if(WI.fillTextValue("show_result").length() > 0) {
	vRetResult = dental.getDentalRecordStatistics(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = dental.getErrMsg();	
}
int iReportType = Integer.parseInt(WI.getStrValue(WI.fillTextValue("report_type"), "0"));
String[] astrConvertMonth = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec"};
String strReportName = null;
if(iReportType == 0) {
	strReportName = " Year : "+WI.fillTextValue("year_");
}
else if(iReportType == 1 && WI.fillTextValue("month_1").length() > 0) {//one month
	strReportName = astrConvertMonth[Integer.parseInt(WI.fillTextValue("month_1"))]+"' "+WI.fillTextValue("year_");
}
else if(iReportType == 2 && WI.fillTextValue("month_2").length() > 0) {//month range.
	strReportName = astrConvertMonth[Integer.parseInt(WI.fillTextValue("month_1"))]+"' "+WI.fillTextValue("year_")+
	" to "+astrConvertMonth[Integer.parseInt(WI.fillTextValue("month_2"))]+"' "+WI.fillTextValue("year_");
}
else {//date range.
	strReportName = " Date : "+WI.fillTextValue("date_1")+" to Date : "+WI.fillTextValue("date_2");
}
%>
<form action="./statistics.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr >
      <td height="28" colspan="4" bgcolor="#697A8F" class="footerDynamic" align="center"><font color="#FFFFFF" ><strong>::::
        DENTAL RECORD STATISTICS PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr valign="top">
      <td width="5%">&nbsp;</td>
      <td width="13%">Enter ID</td>
      <td width="22%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">      
	  </td>
      <td width="60%"><label id="coa_info" style="font-size:11px;"></label></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td style="font-size:11px; font-weight:bold; color:#0000FF"> <input name="is_deciduous" type="checkbox" value="checked" <%=WI.fillTextValue("is_deciduous")%>> Is Deciduous</td>
      <td colspan="2" >Current statistics Cutoff Date : 
<%
strTemp = WI.fillTextValue("stat_date");
if(strTemp.length() == 0) {
	strTemp = WI.getTodaysDate().substring(0,4);
	strTemp = "01/01/"+strTemp;
}%>
	  <input name="stat_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.stat_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	   <input name="show_detail" type="checkbox" value="checked" <%=WI.fillTextValue("show_detail")%> onClick="document.form_.show_result.value='1';document.form_.submit();"> 
	   <font style="font-size:11px; font-weight:bold; color:#0000FF">Show Detail</font></td>
	  
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Statistics  </td>
      <td colspan="2">
<%
if(iReportType == 0)
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
		  <input type="radio" name="report_type" value="0" onClick="document.form_.show_result.value='';document.form_.submit()"<%=strErrMsg%>>Yearly 
<%
if(iReportType == 1)
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
		  <input type="radio" name="report_type" value="1" onClick="document.form_.show_result.value='';document.form_.submit()"<%=strErrMsg%>>Monthly 
<%
if(iReportType == 2)
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
		  <input type="radio" name="report_type" value="2" onClick="document.form_.show_result.value='';document.form_.submit()"<%=strErrMsg%>>Month Range 
<%
if(iReportType == 3)
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
		  <input type="radio" name="report_type" value="3" onClick="document.form_.show_result.value='';document.form_.submit()"<%=strErrMsg%>>Date Range	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="3" >
<%
if(iReportType < 3){%>
	  <select name="year_">
<%=dbOP.loadComboYear(WI.fillTextValue("year_"), 5, 0)%>	  
	  </select>
<%}if(iReportType == 1 || iReportType == 2){%>
&nbsp;&nbsp;Month : 
	  <select name="month_1">
<%=dbOP.loadComboMonth(WI.fillTextValue("month_1"))%>	  
	  </select>
<%}if(iReportType == 2){%>
&nbsp;&nbsp; - &nbsp;&nbsp;
	  <select name="month_2">
<%=dbOP.loadComboMonth(WI.fillTextValue("month_2"))%>	  
	  </select>
<%}if(iReportType == 3){%>
&nbsp;&nbsp;&nbsp;	  
	  <input name="date_1" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_1")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_1');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  &nbsp;&nbsp; - &nbsp;&nbsp;
	  <input name="date_2" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_2")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_2');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
<%}%>	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td ><input name="image" type="image" src="../../../images/form_proceed.gif" onClick="document.form_.show_result.value='1'"></td>
      <td >&nbsp;</td>
    </tr>
    <tr >
      <td height="18" colspan="4" >&nbsp;</td>
    </tr>
  </table>
<%if(WI.fillTextValue("show_result").length() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr >
      <td height="25" colspan="2" align="right" style="font-size:9px;"><a href="javascript:Print();"><img src="../../../images/print.gif" border="0"></a> Print page.</td>
    </tr>
    <tr >
      <td height="25" colspan="2" align="center" style="font-size:14px;" class="thinborderBOTTOM">
	  <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
	</td>
    </tr>
    <tr >
      <td height="28" colspan="2" style="font-size:11px; font-weight:bold">&nbsp;&nbsp;<u>Current Status As of <%=strTemp%></u></td>
    </tr>
    <tr >
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%" >
<%
String strVisitCount = null; 
if(vRetResult != null){
	strVisitCount = (String)vRetResult.remove(0);
	vTempInfo     = (Vector)vRetResult.remove(0);
}//System.out.println(vTempInfo);
%>
	  <u><strong>N</strong>umber of Visits: <%=WI.getStrValue(strVisitCount,"0")%></u>
	  <%if(vTempInfo != null && vTempInfo.size() > 0) {%>
	  	<table cellpadding="0" cellspacing="0" width="80%">
			<%while(vTempInfo.size() > 0) {vTempInfo.remove(2);%>
			<tr>
				<td width="50%"><%=vTempInfo.remove(1)%> (<%=vTempInfo.remove(0)%>) : <%=vTempInfo.remove(0)%></td>
				<td width="50%"><%if(vTempInfo.size() > 0){vTempInfo.remove(2);%>
					<%=vTempInfo.remove(1)%> (<%=vTempInfo.remove(0)%>) : <%=vTempInfo.remove(0)%><%}%>				</td>
			</tr>
			<%}%>
		</table>
	  <%}%>	  </td>
    </tr>
    <tr >
      <td height="25" colspan="2" style="font-size:11px; font-weight:bold">&nbsp;&nbsp;<u>Statistics For  <%=strReportName%></u></td>
    </tr>
<%
strVisitCount = null;vTempInfo = null;
if(vRetResult != null && vRetResult.size() > 0){
	strVisitCount = (String)vRetResult.remove(0);
	vTempInfo     = (Vector)vRetResult.remove(0);
}
%>

    <tr >
      <td height="25">&nbsp;</td>
      <td >
	  <u><strong>N</strong>umber of Visits: <%=WI.getStrValue(strVisitCount,"0")%></u>
	  <%if(vTempInfo != null && vTempInfo.size() > 0) {%>
	  	<table cellpadding="0" cellspacing="0" width="80%">
			<%while(vTempInfo.size() > 0) {vTempInfo.remove(2);%>
			<tr>
				<td width="50%"><%=vTempInfo.remove(1)%> (<%=vTempInfo.remove(0)%>) : <%=vTempInfo.remove(0)%></td>
				<td width="50%"><%if(vTempInfo.size() > 0){vTempInfo.remove(2);%>
					<%=vTempInfo.remove(1)%> (<%=vTempInfo.remove(0)%>) : <%=vTempInfo.remove(0)%><%}%>				</td>
			</tr>
			<%}%>
		</table>
	  <%}%>	  </td>
    </tr>
  </table>  
<%//System.out.println(vRetResult);
if(vRetResult != null && vRetResult.size() > 0) {
Vector vDentalStat = (Vector)vRetResult.remove(0);
int iCOlSpan = 2 + vDentalStat.size()/3;

%>
<table  width="75%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" align="center">
    <tr >
      <td height="22" colspan="<%=iCOlSpan%>" class="thinborder" align="center" style="font-weight:bold" bgcolor="#FFFFCC">Detailed Information</td>
    </tr>
    <tr align="center">
      <td width="28%" height="22" class="thinborder" style="font-weight:bold">Date of Visit</td>
      <td width="18%" class="thinborder" style="font-weight:bold">No of tests </td>
		<%for(int i = 0; i < vDentalStat.size(); i += 3){%>
			<td width="18%" class="thinborder" style="font-weight:bold"><%=vDentalStat.elementAt(i + 1)%>(<%=vDentalStat.elementAt(i + 2)%>)</td>
		<%}%>
    </tr>
<%
int iIndexOf = 0; String strFrequency = null;
for(int i = 0; i < vRetResult.size(); i += 3){
vTempInfo = (Vector)vRetResult.elementAt(i + 2);
%>
    <tr align="center">
      <td height="22" class="thinborder"><%=ConversionTable.convertMMDDYYYY( new java.util.Date(((Long)vRetResult.elementAt(i)).longValue()), true)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
		<%for(int p = 0; p < vDentalStat.size(); p += 3){
		strTemp = (String)vDentalStat.elementAt(p + 1);//status code.. 
		iIndexOf = vTempInfo.indexOf(strTemp);
		//System.out.println(strTemp + " ::: "+iIndexOf);
		if(iIndexOf == -1)
			strFrequency = "0";
		else {	
			strFrequency = (String)vTempInfo.elementAt(iIndexOf + 3);
			vTempInfo.remove(iIndexOf);vTempInfo.remove(iIndexOf);vTempInfo.remove(iIndexOf);vTempInfo.remove(iIndexOf);
		}
		%>
			<td width="18%" class="thinborder"><%=strFrequency%></td>
		<%}%>
    </tr>
<%}%>
  </table>

<%}//if vRetREsult. is not null & size > 0
}%>  
<!--
<table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
-->
<input type="hidden" name="show_result">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
