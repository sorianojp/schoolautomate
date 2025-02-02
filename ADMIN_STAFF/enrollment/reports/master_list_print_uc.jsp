<%@ page language="java" import="utility.*,enrollment.EnrollmentStatusUC,java.util.Vector" %>
<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Master List Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>



<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>

<body bgcolor="" onLoad="window.print();">
<%
	String strErrMsg = null;
	String strTemp = null;
	

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security



	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-UC Master List","master_list_print_uc.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
String[] astrSortByName = {"ID Number","Name","Year Level","College","Course"};
String[] astrSortByVal = {"id_number","lname","stud_curriculum_hist.year_level", "course_offered.c_index", "stud_curriculum_hist.course_index"};
String[] astrConvertSem = {"SUMMER", "FIRST TRIMESTER", "SECOND TRIMESTER", "THIRD TRIMESTER", "FOURTH TRIMESTER"};



Vector vRetResult = new Vector();

EnrollmentStatusUC enrlStatus = new EnrollmentStatusUC();
vRetResult = enrlStatus.viewMasterList(dbOP, request);
if(vRetResult == null)
	strErrMsg = enrlStatus.getErrMsg();
String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
if(strSchCode.startsWith("UC"))
	strSchName = "University of the Cordilleras";
%>
  
<%if(vRetResult != null && vRetResult.size() > 0){%>


<%
boolean bolIsPageBreak = false;
int iResultSize = 9;
int iLineCount = 0;
int iMaxLineCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("line_per_page"),"100000"));	
int iCount = 1;	
int i = 0;
while(iResultSize <= vRetResult.size()){
iLineCount = 0;
%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable3">		
	<tr><td colspan="3" align="center"><font size="+3" color="#00CC33"><strong><%=strSchName%></strong></font></td></tr>
	<tr>
		<td width="30%">&nbsp;</td>
		<td align="center"><font size="1"><strong>
			<%=astrConvertSem[Integer.parseInt(WI.getStrValue(WI.fillTextValue("offering_sem")))]%> 
			<%=WI.getStrValue(WI.fillTextValue("sy_from"))%>-<%=WI.getStrValue(WI.fillTextValue("sy_to"))%></strong></font></td>
		<td width="30%" align="right"><font size="1">Date and Time Printed: <%=WI.getTodaysDateTime()%></font></td>
	</tr>
</table>
 
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">	
	
	
	<tr>
		<td height="18" align="center" width="5%" class="thinborder"><strong>Count</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>Student ID</strong></td>
		<td width="25%" align="center" class="thinborder"><strong>Student Name </strong></td>
		<td width="15%" align="center" class="thinborder"><strong>Gender</strong></td>
		<td width="20%" align="center" class="thinborder"><strong>Course</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>Year</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>Units Enrolled </strong></td>
	</tr>
		
	<%
		for( ; i<vRetResult.size() ; ){						
			iResultSize += 9;			
		%>
	
	<tr>
		<td height="18" align="" class="thinborder"><%=iCount%>.</td>
		<td height="25" align="" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
		<td height="25" align="left" class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+8);
		if(strTemp.equals("M"))
			strTemp = "Male";
		else
			strTemp = "Female";
		%>		
		<td height="25" align="center" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<td height="25" align="left" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"- ","","")%></td>
		<td height="25" align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%></td>
		<td height="25" align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7))%></td>
	</tr>
	
	<%
	iLineCount++;
	iCount++;
	i+=9;
	if(iLineCount >= iMaxLineCount){
		bolIsPageBreak = true;		
		break;		
	}else
		bolIsPageBreak = false;	
	%>
	
	<%
	
	}%>
	
</table>
	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>


	<%}
}%>



</body>
</html>
<%
dbOP.cleanUP();
%>