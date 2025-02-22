<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) {%>
		<p style="font-family:Geneva, Arial, Helvetica, sans-serif; font-weight:bold; color:#FF0000;"> You are already logged out. please login again.</p>
<%return;}
if(strSchCode.startsWith("CIT")){%>
	<jsp:forward page="./grade_sheet_final_report_print_cit.jsp" />
<%return;}

if(strSchCode.startsWith("NEU")){%>
	<jsp:forward page="./grade_sheet_final_report_print_neu.jsp" />
<%return;}

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ReloadPage()
{
	document.gsheet.print_pg.value = "";
	document.gsheet.submit();
}
function PrintPg(strRowStartFr,strRowCount,strLastPage) {

	document.gsheet.print_pg.value = "1";
	
	document.gsheet.row_start_fr.value = strRowStartFr;
	document.gsheet.row_count.value = strRowCount;
	document.gsheet.first_page.value = strLastPage;
		
	document.gsheet.submit();
}
</script>


<body bgcolor="#D2AE72">
<form name="gsheet" action="./grade_sheet_print.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
if(WI.fillTextValue("print_pg").compareTo("1") ==0){%>
	<jsp:forward page="./grade_sheet_print_page.jsp" />
<%return;}
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vSecDetail = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheet Print","grade_sheet_print.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(), null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(), null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(), null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Printing",request.getRemoteAddr(), null);

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
enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
enrollment.GradeSystem  GS = new enrollment.GradeSystem();
GradeSystemExtn gsExtn     = new GradeSystemExtn();

String strSubSecIndex   = WI.fillTextValue("section");

Vector vEncodedGrade = null;

//get here necessary information.
if(strSubSecIndex.length() > 0 && WI.fillTextValue("section_name").length() > 0 && 
		WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
						"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
						" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
						WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
						" and e_sub_section.offering_sem="+WI.fillTextValue("offering_sem")+" and is_lec=0");
						
}
if(strSubSecIndex != null && strSubSecIndex.length() == 0)
	strSubSecIndex = null;
	
if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

//Get here the pending grade to be encoded list and list of grades encoded.
if(strSubSecIndex != null) {
	vEncodedGrade = gsExtn.getStudListForGradeSheetEncoding(dbOP, WI.fillTextValue("grade_for"),strSubSecIndex,true);
	if(vEncodedGrade == null)
		strErrMsg = gsExtn.getErrMsg();
}
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

boolean bolIsLocked = false;
java.sql.ResultSet rs    = null;
String strFinalPrintDate = null;
String strSQLQuery       = null;

boolean bolIsFinalCopy = WI.fillTextValue("is_final_copy").equals("1");
if(strErrMsg == null && bolIsFinalCopy && strSubSecIndex != null) {

	//make sure can't subject final grade if midter is not yet locked..  == turned off for now..
	if(false && WI.fillTextValue("grade_for").equals("3")) {//check if mter is already locked
		strSQLQuery = "select VERIFY_DATE from FACULTY_GRADE_VERIFY  where s_s_index = "+strSubSecIndex+" and pmt_sch_index = 2";
		if(dbOP.getResultOfAQuery(strSQLQuery, 0) == null) {
			dbOP.cleanUP();	%>
				<font style="font-size:16px; font-weight:bold; color:#FF0000">Please Lock Midterm grade first before printing Finals</font>
			<%return;
		}
		
	}
	
	//reset all individual lock status..
	if(WI.fillTextValue("grade_for").equals("3"))
		strSQLQuery = " g_sheet_final ";
	else
		strSQLQuery = "grade_sheet";
	//--> turned off for now.
	//strSQLQuery = "update "+strSQLQuery+" set FORCE_LOCK_STAT = null where sub_sec_index = "+strSubSecIndex;
	//dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	//end of resetting.. 

	
	strSQLQuery = "select VERIFY_DATE, verify_time, verify_index,is_unlocked from FACULTY_GRADE_VERIFY  where s_s_index = "+strSubSecIndex+
	" and pmt_sch_index = "+WI.fillTextValue("grade_for");
	rs = dbOP.executeQuery(strSQLQuery);
	strSQLQuery = null;
	if(rs.next()) {
		if(rs.getString(2) != null)
			strFinalPrintDate = WI.formatDateTime(rs.getLong(2), 5);
		else	
			strFinalPrintDate = WI.formatDate(rs.getDate(1), 6);
		if(rs.getInt(4) == 1)
			strSQLQuery = rs.getString(3);
	}
	rs.close();
	
	//System.out.println(strFinalPrintDate);
	
	if(strFinalPrintDate == null) {//save here.
		strFinalPrintDate = WI.getTodaysDate(1);
		strSQLQuery = "select load_index from faculty_load where sub_sec_index = "+strSubSecIndex +
					  " and user_index = "+(String)request.getSession(false).getAttribute("userIndex")+" and is_valid = 1";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		
		strSQLQuery = "insert into FACULTY_GRADE_VERIFY (LOAD_INDEX,PMT_SCH_INDEX,VERIFY_DATE," +
				      "VERIFIED_BY, s_s_index, verify_time) values (" + strSQLQuery + "," + WI.fillTextValue("grade_for") + ",'" +
          			   WI.getTodaysDate() + "'," + 
					   (String)request.getSession(false).getAttribute("userIndex") + ", "+strSubSecIndex+", " + new java.util.Date().getTime()+")";
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
		
		bolIsLocked = true;
	}
	else if(strSQLQuery != null) {
		dbOP.executeUpdateWithTrans("update FACULTY_GRADE_VERIFY set is_unlocked = 0 where verify_index = "+strSQLQuery, null, null, false);
		bolIsLocked = true;
	}
		
}




%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
    <input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>">
    <input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
    <input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
    <input type="hidden" name="grade_for" value="<%=WI.fillTextValue("grade_for")%>">
    <input type="hidden" name="section_name" value="<%=WI.fillTextValue("section_name")%>">
    <input type="hidden" name="subject" value="<%=WI.fillTextValue("subject")%>">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: 
          GRADE SHEETS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
      <td style="font-size:24px; font-weight:bold" align="right">
	  <%if(bolIsLocked) {%>
	  	Grade Sheet Is Locked
	  <%}%>
	  
	  </td>
    </tr>
<%if(request.getSession(false).getAttribute("userId_fac") != null) {%>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<a href="./grade_sheet_print_per_faculty_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
	  <font size="1">Go Back to Main</font>	  </td>
    </tr>
<%}%>
    <tr> 
      <td width="3%" height="0" >&nbsp;</td>
      <td width="52%" height="25" valign="bottom" >Grades for</td>
      <td width="45%" valign="bottom" >School Year - Term</td>
    </tr>
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td height="25" valign="bottom" > <strong><%=dbOP.mapOneToOther("FA_PMT_SCHEDULE","PMT_SCH_INDEX",WI.fillTextValue("grade_for"),
	  		"EXAM_NAME",null)%></strong></td>
      <td valign="bottom" > <strong><%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%> (<%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>)</strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%"></td>
      <td width="37%" height="25" valign="bottom" >Section Handled</td>
      <td width="60%" valign="bottom" >Instructor (Name of logged in user)</td>
    </tr>
    <tr> 
      <td></td>
      <td height="25" ><strong><%=WI.fillTextValue("section_name")%></strong></td>
      <td height="25" > <strong> 
        <%if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%> 
        <%}%>
        </strong> </td>
    </tr>
    <tr> 
      <td width="3%"></td>
      <td height="25">Subject Handled</td>
      <td>Subject Title </td>
    </tr>
    <tr> 
      <td width="3%"></td>
      <td height="25" > <strong><%=dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_code",null)%></strong></td>
      <td> <strong><%=dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name",null)%></strong></td>
    </tr>
  </table>
<%if(vSecDetail != null){%>
 <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM 
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%> 
	<tr>
	<td>&nbsp;</td>
	<td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
	<td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
	  <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
	<td>&nbsp;</td>
	</tr>  
	<%}%>  
	<tr>
	<td>&nbsp;</td>
	  <td align="center">&nbsp;</td>
	  <td align="center">&nbsp;</td>
	  <td align="center">&nbsp;</td>
	<td>&nbsp;</td>
	</tr>   
</table>		
<%}
 if(vEncodedGrade != null && vEncodedGrade.size() > 0){//System.out.println(" I am here .");
 int iTemp = vEncodedGrade.size() / 9;
 int iPageCount = 1;
 
 int iRowsPerPage = 25;
 int iFirstPageRowCount = 15;

if(WI.fillTextValue("first_page").length() > 0) {
	iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("first_page"), "0"));
	if(iRowsPerPage == 0)
		iRowsPerPage = 45;
	iFirstPageRowCount = iRowsPerPage;
}
	


 iTemp -= iFirstPageRowCount;
 iPageCount += iTemp / iRowsPerPage;
 if(iTemp % iRowsPerPage > 0)
 	++iPageCount;
int[] iRowsToShow = new int[iPageCount];
int[] iRowStartFrom = new int[iPageCount];
//if there are two pages, i have to findout the page counts here. only if the count is less than 30
iTemp = vEncodedGrade.size() / 9;
//iTemp = 56;
for(int i = 0 ; i < iPageCount; ++i){
	if(i == 0) {
		iRowsToShow[i] = iFirstPageRowCount;
		iRowStartFrom[i] = 0;
		iTemp -= iFirstPageRowCount; 
		if(iTemp <= 0) {
			iRowsToShow[i] = iTemp + iFirstPageRowCount;
			break;
		}//System.out.println(iRowsToShow[i]);System.out.println(iRowStartFrom[i]);
		continue;			
	}
	iRowsToShow[i] = iRowsPerPage;
	iRowStartFrom[i] = iFirstPageRowCount + iRowsPerPage * (i-1);
	
	iTemp -= iRowsPerPage;
	if(iTemp <= 0) {
		iTemp += iRowsPerPage;
		iRowsToShow[i] = iTemp;//end page.
		break;
	} 
}
 //here i have saga of computation of spliting record to page.%>
 
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
     <tr>
      <td width="0%" height="25">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="92%" colspan="4">TOTAL NUMBER OF STUDENTS IN CLASS : <strong><%=vEncodedGrade.size() / 9%></strong></td>
    </tr>
   <%
 int iFirstPage = 0;
for(int i = 1; i <= iPageCount; ++i){
iFirstPage = 0;
if(i == 1) {
	strTemp = "Print First Page";
	iFirstPage = 1;
}
else	
	strTemp = "Print Page "+i;
//Print page(start pt, no of rows, is last page.
%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"><b><font size="3"> <a href='javascript:PrintPg("<%=iRowStartFrom[i - 1]%>","<%=iRowsToShow[i - 1]%>","<%=iFirstPage%>");'> 
        <%=strTemp%></a></font></b></td>
    </tr>
    <%}%>
  </table>

<%}//end of showing encoded grade 
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="row_start_fr">
<input type="hidden" name="row_count">
<input type="hidden" name="first_page">
<input type="hidden" name="is_final_copy" value="<%=WI.fillTextValue("is_final_copy")%>">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
