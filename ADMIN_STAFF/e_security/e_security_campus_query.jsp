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
<script language="JavaScript">
function ClearSY() {
	document.esecurity_.semester.selectedIndex = 0;
	document.esecurity_.sy_from.value = "";
	document.esecurity_.sy_to.value = "";
	document.esecurity_.sy_from.focus();
}
function EnterStudID() {
	if(document.esecurity_.stud_id.value == "<Student ID>")
		document.esecurity_.stud_id.value = "";
	else if(document.esecurity_.stud_id.value == "")
		document.esecurity_.stud_id.value = "<Student ID>";
}
function ReloadPage() {
	document.esecurity_.report_name.value = document.esecurity_.report_type[document.esecurity_.report_type.selectedIndex].text;
	document.esecurity_.print_pg.value = "";
	document.esecurity_.view_detail.value = "";
	document.esecurity_.submit();
}
function SearchPage() {
	document.esecurity_.report_name.value = document.esecurity_.report_type[document.esecurity_.report_type.selectedIndex].text;
	document.esecurity_.print_pg.value = "";
	document.esecurity_.view_detail.value = "";
	document.esecurity_.search_page.value = "1";
}
function JumpToPage(){
	document.esecurity_.search_page.value = "1";
	document.esecurity_.print_pg.value = "";
	document.esecurity_.view_detail.value = "";
	document.esecurity_.submit();
}
function ViewStudDetail(strStudID)
{
//popup window here. 
	var pgLoc = "../../search/stud_info_view.jsp?stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ViewAttendanceDetail(strStudID) {
	document.esecurity_.stud_id2.value = strStudID;

	document.esecurity_.view_detail.value = "1";
	document.esecurity_.print_pg.value = "";
	document.esecurity_.submit();
}
function PrintPg() {
	document.esecurity_.print_pg.value = "1";
	document.esecurity_.view_detail.value = "";
	document.esecurity_.submit();
}
function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=esecurity_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,eSC.CampusQuery,java.util.Vector" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	String strReportToDisp = null;
	String[] astrConvertToTerm ={"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	if(WI.fillTextValue("print_pg").compareTo("1") ==0){%>
		<jsp:forward page="./e_security_campus_query_print.jsp" />
	<%}
	if(WI.fillTextValue("view_detail").compareTo("1") ==0){
		strTemp = "./e_security_campus_query_detail.jsp?stud_id="+
			WI.getStrValue(WI.fillTextValue("stud_id2"),"0");
	%>
		<jsp:forward page="<%=strTemp%>" />
	<%}

	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";
		


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eSecurity Check-Campus Query","e_security_campus_query.jsp");
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
														"e_security_campus_query.jsp");	
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
String[] astrSortByVal  = {"id_number","lname","fname","course_offered.course_code"};
int iSearchResult = 0;
CampusQuery CQ = new CampusQuery(request);
if(WI.fillTextValue("search_page").compareTo("1") == 0){
	vRetResult = CQ.getStudCampusQuery(dbOP,request);
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
	strReportToDisp += "("+WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to");
	if(WI.fillTextValue("semester").length() > 0) 
		strReportToDisp += ","+astrConvertToTerm[Integer.parseInt(WI.fillTextValue("semester"))]+")";
	else	
		strReportToDisp += ")";
%>	

<form action="./e_security_campus_query.jsp" method="post" name="esecurity_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENTS CAMPUS ATTENDANCE QUERY PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">School Year : </td>
      <td width="66%"> 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("esecurity_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes">
        - 
        <select name="semester">
          <option value="">N/A</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && request.getParameter("semester") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
        <a href="javascript:ClearSY();"><img src="../../images/clear.gif" border="0"></a><font size="1">Click to clear SY/Term</font></td>
      <td width="20%"><input type="image" src="../../images/refresh.gif" onClick="SearchPage();"></td>
    </tr>
    <tr > 
      <td height="18" colspan="5"><hr size="1"></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="3%" height="33">&nbsp;</td>
      <td width="9%">SHOW : </td>
      <td colspan="2"><select name="report_type" onChange="ReloadPage();">
<% if (!strSchCode.startsWith("AUF")) {%> 
          <option value="0">List of students currently inside Campus</option>
<%}%> 
          <%
strTemp = WI.fillTextValue("report_type");





if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Student Campus Attendance for Specific Date(Range)</option> 
          <%}else{%>
          <option value="1">Student Campus Attendance for Specific Date(Range)</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Invalid Students Entering Campus</option>
          <%}else{%>
          <option value="2">Invalid Students Entering Campus</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>Valid Students Not Having Record in eSecurity</option>
          <%}else{%>
          <option value="3">Valid Students Not Having Record in eSecurity</option>
          <%}%>
        </select> 
        <%
strTemp = WI.fillTextValue("stud_id");
if(strTemp.length() ==0)
	strTemp = "<Student ID>";
%>
        <input name="stud_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF';javascript:EnterStudID();" 
	  onblur="style.backgroundColor='white';javascript:EnterStudID();" value="<%=strTemp%>" size="16">
	  <a href="javascript:OpenSearch();"><img src="../../images/search.gif" width="37" height="30" border="0"></a>
        &nbsp;<em><font color="#0000FF" size="1">NOTE: Provide Student ID to get 
        specific student report</font></em></td>
    </tr>
<%
strTemp = WI.fillTextValue("report_type");
if (strSchCode.startsWith("AUF") && strTemp.length() == 0) 
	strTemp = "1";


if(strTemp.length() > 0 && !strTemp.equals("0")){%>
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

<%
  } 
%>

<% if (strTemp.equals("1") || strTemp.equals("0")) {%> 
	<tr > 
      <td height="33">&nbsp;</td>
      <td>LOC :</td>
      <td colspan="2">
	  <select name="loc_index"> 
	  <option value=""> ALL LOCATIONS </option>
	  	<%=dbOP.loadCombo("LOCATION_INDEX","LOC_NAME",
			" from ESC_LOGIN_LOC order by LOC_NAME", WI.fillTextValue("loc_index"),false)%>
 	 </select>
		</td>
    </tr>	
<%  } %>
    <tr > 
	
      <td height="33">&nbsp;</td>
      <td colspan="2">ORDER BY :</td>
      <td width="57%" colspan="-1">&nbsp;</td>
    </tr>
    <tr > 
      <td height="33">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><select name="sort_by1">
          <option value="">N/A</option>
          <%=CQ.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
        </select> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select>
        &nbsp;&nbsp; &nbsp; <select name="sort_by2">
          <option value="">N/A</option>
          <%=CQ.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select>
		<select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
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
      <td width="66%" height="25"><b> TOTAL RESULT : <%=iSearchResult%> - Showing(<%=CQ.getDisplayRange()%>)</b></td>
      <td width="34%"> 
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/CQ.defSearchSize;
		if(iSearchResult % CQ.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page: 
          <select name="jumpto" onChange="JumpToPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
          <%}%>
        </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="19%" height="25" align="center" class="thinborder"><font size="1"><strong>STUDENT 
          ID</strong></font></td>
      <td width="39%" align="center" class="thinborder"><font size="1"><strong>STUDENT NAME<BR>
        (LNAME, FNAME, MI.) </strong></font></td>
      <td width="21%" align="center" class="thinborder"><font size="1"><strong>COURSE</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>ATTENDACE DETAIL</strong></font></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>CURRENT STUDENT 
          INFO</strong></font></td>
    </tr>
<%for(int i = 0; i< vRetResult.size(); i +=5){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td height="25" class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i+1),
	  (String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td align="center" class="thinborder"><a href='javascript:ViewAttendanceDetail("<%=(String)vRetResult.elementAt(i)%>");'>
  	  <img src="../../images/view.gif" border="0" ></a></td>
      <td height="25" align="center" class="thinborder">
	    <a href='javascript:ViewStudDetail("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/view.gif" border="0" ></a></td>
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