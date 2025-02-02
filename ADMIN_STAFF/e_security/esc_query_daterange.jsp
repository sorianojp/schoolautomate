<%@ page language="java" import="utility.*,eSC.CampusQuery,java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
//strColorScheme is never null. it has value always.


	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	String strReportToDisp = null;
	String[] astrConvertToTerm ={"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";
		


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eSecurity Check-Campus Query","esc_query_daterange.jsp");
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
														"eSecurity Check","STUDENTS CAMPUS ATTENDANCE QUERY",request.getRemoteAddr(), 
														"esc_query_daterange.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String[] astrSortByName = {"Student ID #","Lastname","Firstname","Course"};
String[] astrSortByVal  = {"id_number","lname","fname","COURSE_NAME"};
int iSearchResult = 0;
CampusQuery CQ = new CampusQuery(request);
if(WI.fillTextValue("search_page").compareTo("1") == 0){
	vRetResult = CQ.searchCampusAttendance(dbOP,0);
	if(vRetResult == null)
		strErrMsg = CQ.getErrMsg();
	else	
		iSearchResult = CQ.getSearchCount();
}

strReportToDisp = WI.fillTextValue("report_name").toUpperCase();
if(WI.fillTextValue("date_fr").length() > 0)
	strReportToDisp += " AS OF DATE: "+WI.fillTextValue("date_fr");
if(WI.fillTextValue("date_to").length() > 0)
	strReportToDisp += " to "+WI.fillTextValue("date_to");
if(WI.fillTextValue("sy_from").length() > 0)
	strReportToDisp += ", "+WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to");
	if(WI.fillTextValue("semester").length() > 0) 
		strReportToDisp += ","+astrConvertToTerm[Integer.parseInt(WI.fillTextValue("semester"))];

boolean bolSearchFaculty = WI.fillTextValue("is_faculty").equals("checked");
%>	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ClearSY() {
	document.esecurity_.semester.selectedIndex = 0;
	document.esecurity_.sy_from.value = "";
	document.esecurity_.sy_to.value = "";
	document.esecurity_.sy_from.focus();
}
function EnterStudID() {
	/**
	if(document.esecurity_.stud_id.value == "<ID Number>")
		document.esecurity_.stud_id.value = "";
	else if(document.esecurity_.stud_id.value == "")
		document.esecurity_.stud_id.value = "<ID Number>";
	**/
}
function ReloadPage() {
	document.esecurity_.report_name.value = document.esecurity_.report_type[document.esecurity_.report_type.selectedIndex].text;
	document.esecurity_.print_pg.value = "";
	document.esecurity_.view_detail.value = "";
	document.esecurity_.submit();
}
function ViewAttendanceDetail(strStudID) {
	var strDateFr   = document.esecurity_.date_fr.value;
	var strDateTo   = document.esecurity_.date_to.value;
	var strLocation = document.esecurity_.loc_index[document.esecurity_.loc_index.selectedIndex].value;
	
	var strLoc = "./e_security_campus_query_detail.jsp?is_faculty=checked&search_other=1&stud_id="+
				strStudID+"&id_number="+strStudID+"&date_fr="+strDateFr+"&report_to_disp="+
				escape("<%=strReportToDisp%>");
	if(strDateTo.length > 0) 
		strLoc +="&date_to="+strDateTo;
	if(strLocation.length > 0) 
		strLoc += "&loc_index="+strLoc; 
	//alert(strLoc);
	location = strLoc;
}
function PrintPg() {
	document.esecurity_.print_pg.value = "1";
	document.esecurity_.submit();
}
function OpenSearch() {
	var pgLoc;
	if(document.esecurity_.is_faculty.checked)
		pgLoc = "../../search/srch_emp.jsp?opner_info=esecurity_.stud_id";
	else
		pgLoc = "../../search/srch_stud.jsp?opner_info=esecurity_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//all about ajax - to display student list with same name.
function AjaxMapName(searchType) {
		var strCompleteName = document.esecurity_.stud_id.value;
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
		
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.esecurity_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	this.viewInfo();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<body bgcolor="#D2AE72">

<form action="./esc_query_daterange.jsp" method="post" name="esecurity_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="88%" height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          <%if(bolIsSchool){%>STUDENTS CAMPUS <%}%>ATTENDANCE QUERY PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" style="font-size:11px; color:#0000FF; font-weight:bold">
<%if(bolIsSchool){%>
        <input type="checkbox" name="is_faculty" value="checked" <%=WI.fillTextValue("is_faculty")%>> Search Employee 
<%}else{%>
        <input type="checkbox" name="is_faculty" value="checked" checked readonly> Search Employee 
<%}%>		</td>
    </tr>
    <tr > 
      <td width="3%" height="33">&nbsp;</td>
      <td width="9%">ID </td>
      <td colspan="2"><%
strTemp = WI.fillTextValue("stud_id");
%>
        <input name="stud_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF';javascript:EnterStudID();" 
	  onblur="style.backgroundColor='white';javascript:EnterStudID();" value="<%=strTemp%>" size="16" onKeyUp="AjaxMapName(1);">
	  <a href="javascript:OpenSearch();"><img src="../../images/search.gif" width="37" height="30" border="0"></a>
        &nbsp;<em><font color="#0000FF" size="1">NOTE: Provide  ID to get 
        specific student report</font></em></td>
    </tr>
    <tr >
      <td></td>
      <td colspan="3">
	  <table width="100%">
	  	<tr>
			<td width="35%"><label id="coa_info"></label></td>
			<td></td>
		</tr>
	  </table>
	  
	  </td>
    </tr>
    <tr > 
      <td height="33">&nbsp;</td>
      <td>DATE :</td>
      <td colspan="2"> <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('esecurity_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../images/calendar_new.gif" border="0"></a> to 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('esecurity_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
         <img src="../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;<em><font color="#0000FF" size="1">NOTE: 
        Leave the date fileds empty to display record for entire term specified</font></em></td>
    </tr>

	<tr > 
      <td height="33">&nbsp;</td>
      <td>LOC :</td>
      <td colspan="2">
	  <select name="loc_index"> 
	  <option value=""> ALL LOCATIONS </option>
	  	<%=dbOP.loadCombo("LOCATION_INDEX","LOC_NAME",
			" from ESC_LOGIN_LOC order by LOC_NAME", WI.fillTextValue("loc_index"),false)%>
 	 </select>	  </td>
    </tr>	
    <tr > 
	
      <td height="10">&nbsp;</td>
      <td colspan="3" align="center">
        <input type="submit" name="12" value="Search Attendance" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.esecurity_.search_page.value='1'">	  </td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0" ></a><font size="1">click 
          to print listing/report</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" bgcolor="#B9B292"><div align="center"><strong><%=strReportToDisp%></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="66%" height="25"><b> TOTAL RESULT : <%=vRetResult.size()/4%></b></td>
      <td width="34%">&nbsp; </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="19%" height="25" align="center" class="thinborder"><font size="1"><strong><%if(bolSearchFaculty){%>Employee<%}else{%>Student<%}%> ID</strong></font></td>
      <td width="39%" align="center" class="thinborder"><font size="1"><strong><%if(bolSearchFaculty){%>Employee<%}else{%>Student<%}%> Name<BR>
        (lname, fname, mi.) </strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>Attendance Detail</strong></font></td>
    </tr>
<%for(int i = 0; i< vRetResult.size(); i +=4){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td height="25" class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i+1),
	  (String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>
      <td align="center" class="thinborder"><a href='javascript:ViewAttendanceDetail("<%=(String)vRetResult.elementAt(i)%>");'>
  	  <img src="../../images/view.gif" border="0" ></a></td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" bgcolor="#FFFFFF"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0" ></a><font size="1">click 
        to print listing/report</font></td>
    </tr>
  </table>
 <%}//only if vRetResult is not null %>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="search_page"> 
<input type="hidden" name="report_name" value="<%=WI.fillTextValue("report_name")%>">
<input type="hidden" name="report_to_disp" value="<%=strReportToDisp%>">
<input type="hidden" name="print_pg">
<input type="hidden" name="view_detail">
<input type="hidden" name="stud_id2">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>