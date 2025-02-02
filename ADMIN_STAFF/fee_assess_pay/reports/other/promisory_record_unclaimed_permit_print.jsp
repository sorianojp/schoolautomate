<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
</script>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*, enrollment.FAPromisoryNote ,java.util.Vector, java.util.Date" buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSemester = WI.fillTextValue("semester");
	String strPmtIndex = WI.fillTextValue("pmt_schedule");  
	
	if(strSYFrom.length() == 0 || strSemester.length() == 0 || strPmtIndex.length() == 0){
		strErrMsg = "Please provide SY-Term and Exam Period information.";
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%return;}

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assess & Payment - Reports - Promisory Note record unclaimed Permit.",
								"promisory_record_unclaimed_permit.jsp");
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

String[] astrConvertTerm = {"Summer","First Semester", "Second Semester","Third Semester"};
String strExamName = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+strPmtIndex;
strExamName = dbOP.getResultOfAQuery(strExamName, 0).toUpperCase();

String strReportTitle = astrConvertTerm[Integer.parseInt(strSemester)]+", "+strSYFrom+" - "+ 
						Integer.toString(Integer.parseInt(strSYFrom) + 1) +" - "+strExamName;



int iMaxDisp = 0;
Vector vRetResult = new Vector();
String strSQLQuery = "select id_number, fname, mname, lname, course_code, YEAR_LEVEL, UP_AMOUNT, c_name "+
	" 	from AUF_UNCLAIMED_PERMIT "+
	"	join user_table on (user_table.user_index = AUF_UNCLAIMED_PERMIT.stud_index) "+
	"	join stud_curriculum_hist on (stud_curriculum_hist.user_index = AUF_UNCLAIMED_PERMIT.stud_index) "+
	" 	and stud_curriculum_hist.sy_from = AUF_UNCLAIMED_PERMIT.sy_from_ and stud_curriculum_hist.semester = AUF_UNCLAIMED_PERMIT.sem_ "+
	"	join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
	"	join college on (college.c_index = course_offered.c_index)"+
	"	where sy_from_ = "+strSYFrom+" and sem_ = "+strSemester+
	" and EXAM_PERIOD_INDEX = "+strPmtIndex+" and 	AUF_UNCLAIMED_PERMIT.is_valid = 1 "+
	WI.getStrValue(WI.fillTextValue("c_index")," and course_offered.c_index = ","","")+
	" order by c_name, lname, fname";
java.sql.ResultSet rs= dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vRetResult.addElement(rs.getString(1));//[0]id_number
	vRetResult.addElement(rs.getString(2));//[1]fname
	vRetResult.addElement(rs.getString(3));//[2]mname
	vRetResult.addElement(rs.getString(4));//[3]lname
	vRetResult.addElement(rs.getString(5));//[4]course_code
	vRetResult.addElement(rs.getString(6));//[5]YEAR_LEVEL
	vRetResult.addElement(rs.getString(7));//[6]UP_AMOUNT
	vRetResult.addElement(rs.getString(8));//[7]c_name
}rs.close();



if(vRetResult != null && vRetResult.size() > 0){

int iStudCount = 0;
int iRowCount = 1;
int iNoOfStudPerPage = 45;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
	
int iPageCount = 1;
int iTotalStud = (vRetResult.size()/8);
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud % iNoOfStudPerPage > 0)
	++iTotalPageCount;
boolean bolPageBreak = false;	

String strPrevCollege = "";
String strCurrCollege = null;

double dSubTotal = 0d;
double dGrandTotal = 0d;

for(int i = 0; i < vRetResult.size(); ){
	iRowCount = 1;
	if(bolPageBreak){
		bolPageBreak = false;
		%>
		<div style="page-break-after:always;">&nbsp;</div>
	<%}
%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td align="center" bgcolor="#EEEEEE" height="25" class="thinborderTOPLEFTRIGHT"><strong>UNCLAIMED PERMIT LISTING <br><%=strReportTitle%></strong></td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr style="font-weight:bold;" bgcolor="#CCCCCC">
			<td height="22" align="center" width="7%" class="thinborder">Count</td>
		    <td width="19%" class="thinborder">Student ID </td>
		    <td width="38%" class="thinborder">Student Name </td>
		    <td width="20%" class="thinborder">Course</td>
		    <td width="16%" class="thinborder" align="center">Unclaimed Permit </td>
	    </tr>
<%




for(; i < vRetResult.size();){
	
	strCurrCollege = (String)vRetResult.elementAt(i+7);%>
<%
if(!strPrevCollege.equals(strCurrCollege) && i > 0){
%> 
	<tr>
	    <td height="22" colspan="4" align="right" class="thinborder"><strong><%=strCurrCollege%> TOTAL : &nbsp;</strong></td>
	    <td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(dSubTotal,true)%></strong></td>
	</tr>
<%}	
	

	if(!strPrevCollege.equals(strCurrCollege)){
		strPrevCollege = strCurrCollege;
		iStudCount = 0;
		dSubTotal = 0d;
%>
	<tr>
		<td class="thinborder" colspan="5"><strong><%=strCurrCollege%></strong></td>
	</tr>	
<%}//end if(!strPrevCollege.equals(strCollegeName))%>
	<tr>
	  <td height="22" class="thinborder" align="right"><%=++iStudCount%>.&nbsp;&nbsp;</td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
	  <td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%><%=WI.getStrValue((String)vRetResult.elementAt(i+5), "-", "","")%></td>
	  <%
	  dSubTotal += Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+6)));
	  dGrandTotal += Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+6)));
	  %>
	  <td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6), true)%></td>
  </tr>
<%
if(i+8 >= vRetResult.size()){
%> 
	<tr>
	    <td height="18" colspan="4" align="right" class="thinborder"><strong><%=strCurrCollege%> TOTAL : &nbsp;</strong></td>
	    <td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(dSubTotal,true)%></strong></td>
	</tr>
<%}
	i+=8;
	if(++iRowCount > iNoOfStudPerPage){			
		bolPageBreak = true;
		break;
	}
}%>
	</table>
<%
}//end of outer loop%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="22" align="right"><strong>Grand Total : &nbsp;</strong></td>
		<td width="16%" align="right"><strong><%=CommonUtil.formatFloat(dGrandTotal,true)%></strong></td>
	</tr>
</table>


<%}else{%><div style="text-align:center">No Result Found</div><%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>