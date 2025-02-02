<%if(request.getSession(false).getAttribute("userIndex") == null){%>
	<p style="font-size:14px; font-weight:bold; color:#FF0000;">You are logged out. Please login again.</p>
<%return;}%>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFontSize = "10";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }

/**
<%if(WI.fillTextValue("show_border").compareTo("1") ==0){%>
**/
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
    TD.thinborderSP {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
/**
<%}else{%>
**/
    TD.thinborderSP {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
/**
<%}%>
**/
    TABLE.jumboborder {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }

    TD.jumboborderRIGHT {
    border-right: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
	
	TD.jumboborderRIGHTBottom {
    border-right: solid 1px #AAAAAA;
    border-bottom: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }

	TD.jumboborderBottom {
    border-bottom: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
	
    TD.jumboborderTOP {
    border-top: solid 2px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }

    TD.jumboborderTOPex {
    /**border-top: solid 1px #000000;**/
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
    TD.jumboborderTOPONLY {
    border-top: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
    TABLE.thinborderALL {
    border-left: solid 2px #000000;
    border-right: solid 2px #000000;
    border-top: solid 2px #000000;
    border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }


-->
</style>
</head>
<script language="javascript">
function CallOnLoad() {
	document.all.processing.style.visibility='hidden';	
	document.bgColor = "#FFFFFF";
}
</script>
<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">
<!-- Printing information. -->
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFFFFF">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>
			
			<img src="../../../Ajax/ajax-loader_small_black.gif"></td>
      </tr>
</table>
</div>
<form name="form_">
<%
	String strErrMsg = null;String strTemp = null;

	String strSchCode = null;//for UI , do not show remarks.
	//for CLDH, show total enrolled unit instead of remark.


	String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester","4th Semester","5th Semester"};
	String[] astrConvertYr	= {"ALL YEAR LEVEL","First Year","Second Year","Third Year","Fourth Year","Fifth Year","Sixth Year"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-Enrollment list print","elist_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//get the enrollment list here.
ReportEnrollment enrlReport = new ReportEnrollment();

/**VMAEnrollmentReports vmaenrlReport = new VMAEnrollmentReports();*/
Vector vForm9GradeList = new Vector();

int iIndexOf = 0;
String strIDNumberNew = null;

Vector vEnrlInfo = new Vector();
Vector vStudUnitEarned = new Vector();
boolean bolSeparateName = false;
int iNoOfSubPerRow = 6;
boolean bolShowPageBreak = false;

strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
int iTotalStud = 0;
Vector vRetResult = null; Vector vCourseInfo = new Vector();
int iDefNoOfRowPerPg = 0;
//if(request.getParameter("stud_per_pg") == null)
	iDefNoOfRowPerPg = 44;
	//already moved to number of students per page.
	int iDefNoOfStudPerPg = 12;
	if(WI.fillTextValue("semester").equals("0"))
		iDefNoOfStudPerPg = 18;
		
	int iNoOfStudent      = iDefNoOfStudPerPg;
//else
	//iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));

int iNoOfRowPerPg = iDefNoOfRowPerPg;

String strCourseName  = null;
String strMajorName   = null; int iPageCount = 1;

int iYearLevel = Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"), "0"));

	strCourseName = "select course_name from course_offered where course_index = "+WI.fillTextValue("course_index");
	strCourseName = dbOP.getResultOfAQuery(strCourseName, 0);
	
	if(WI.fillTextValue("major_index").length() > 0) {
		strMajorName = "select major_name from major where major_index = "+WI.fillTextValue("major_index");
		strMajorName = dbOP.getResultOfAQuery(strMajorName, 0);
	}
	strErrMsg = null;
	vRetResult = enrlReport.getEnrollmentListEAC(dbOP,request);
	if(vRetResult == null) 
		strErrMsg = enrlReport.getErrMsg();
	else{
		iTotalStud = vRetResult.size() - 4;
		
		String strSQLQuery = "";
		
		if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("print_all_course").length() == 0)
    	 strSQLQuery += " and stud_curriculum_hist.course_index = "+WI.fillTextValue("course_index");     
     
     	if(WI.fillTextValue("year_level").length() > 0)
    	 strSQLQuery += " and stud_curriculum_hist.year_level = "+WI.fillTextValue("year_level");
		
		strSQLQuery = " select distinct id_number, sub_code, grade, remark_abbr, credit_earned "+
			 " from g_sheet_final "+
			 " join stud_curriculum_hist on (stud_curriculum_hist.cur_hist_index = g_sheet_final.cur_hist_index) "+
			 " join subject on (subject.sub_index = g_sheet_final.s_index) "+
			 " join user_table on (user_table.user_index = stud_curriculum_hist.user_index) "+
			 " join REMARK_STATUS on (REMARK_STATUS.remark_index = g_sheet_final.remark_index) "+
			 " where g_sheet_final.is_valid = 1 "+
			 " and stud_curriculum_hist.sy_from = " + WI.fillTextValue("sy_from") +
			 " and stud_curriculum_hist.semester = " + WI.fillTextValue("semester") + strSQLQuery;
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		
		while(rs.next()){
			vForm9GradeList.addElement(rs.getString(1)+"-"+rs.getString(2));//[0]id_number-sub_code
			if(rs.getString(3) == null)
				vForm9GradeList.addElement(rs.getString(4));//[1]remark
			else			
				vForm9GradeList.addElement(rs.getString(3));//[1]grade
				
			vForm9GradeList.addElement(CommonUtil.formatFloat(rs.getDouble(5),false));//[2]credit_earned
			
			iIndexOf = 	vStudUnitEarned.indexOf(rs.getString(1));
			if(iIndexOf == -1){
				vStudUnitEarned.addElement(rs.getString(1));//[0]id_number-sub_code
				vStudUnitEarned.addElement(new Double(rs.getDouble(5)));//[2]credit_earned
			}else{
				vStudUnitEarned.setElementAt(new Double(((Double)vStudUnitEarned.elementAt(iIndexOf + 1)).doubleValue()+rs.getDouble(5)) ,iIndexOf + 1);
			}
		}rs.close();
		
	}
			
if(vRetResult == null) {
	dbOP.cleanUP();
	%><%=strErrMsg%>
<%return;
}	
	int iStudCount = 1;
	int iTemp = iTotalStud;//total no of rows.
	//iTemp is not correct -- i have to run a for loop to find number of rows.
		
	String strPgCountDisp = null;
	
	String strStudName = null;
	String strIDNumber = null;
	
	
	double dTotalUnit = 0d; int iCount = 1;
	
	String strGenderPrinting = "MALE";
	boolean bolIsMaleAvailable = false;
	
	Vector vMale = new Vector();
	Vector vFemale = new Vector();
	
	//I have to first check if gender is there in vector.. 
	for(int i=4; i<vRetResult.size(); ++i) {
		vEnrlInfo = (Vector)vRetResult.elementAt(i);
		if(vEnrlInfo.elementAt(2).equals("M"))
			vMale.addElement(vEnrlInfo);
		else	
			vFemale.addElement(vEnrlInfo);
	} 
	if(vMale.size() > 0) {
		vRetResult = vMale;
		strGenderPrinting = "MALE";	
	}
	else {
		vRetResult = vFemale;
		strGenderPrinting = "FEMALE";	
	}
	
	while(vRetResult.size() > 0) {
		iNoOfRowPerPg = iDefNoOfRowPerPg;
		iNoOfStudent = iDefNoOfStudPerPg; 
		
		if(iPageCount++ > 1) {%>
				<DIV style="page-break-after:always">&nbsp;</DIV>
		<%}%>
		
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tr>
			<td colspan="2" style="font-weight:bold">
			<div align="center">
				<font style="font-size:12px; font-weight:bold"> CEBU INSTITUTE OF TECHNOLOGY - UNIVERSITY</font><br>
			N. Bacalso Ave., Cebu City, 6000 Philippines<br><br>	
			
			OFFICE OF THE REGISTRAR <div align="left">FORM XIX</div>
			REPORT ON COLLEGIATE GRADES & CREDITS EARNED
			<div align="left">		
			<%=strCourseName.toUpperCase()%><%=WI.getStrValue(strMajorName, " - ", "", "").toUpperCase()%></div>
		<%if(iYearLevel > 0) {%>
			<div align="left">Curriculum Year: <%=astrConvertYr[iYearLevel]%></div>	
		<%}%>
				<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>			  
		<%=request.getParameter("sy_from")%> - <%=Integer.parseInt((String)request.getParameter("sy_from")) + 1%>

		
		<br>&nbsp;		  
			</div>
		</td>
		  </tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr style="font-weight:bold" align="center">
			  	<td width="2%">&nbsp;</td>
				<td width="40%"><u><%=strGenderPrinting%></u></td>
				<td width="2%">&nbsp;</td>
				<td colspan="5"><u>SUBJECTS</u></td>
			</tr>
			<tr style="font-weight:bold" align="center">
			  <td></td>
				<td></td>
				<td>&nbsp;</td>
				<td width="14%">&nbsp;</td>
				<td><strong>Rating</strong></td>
				<td><strong>&nbsp;Units</strong></td>
				<td width="14%">&nbsp;</td>
				<td><strong>Rating</strong></td>
				<td><strong>&nbsp;Units</strong></td>
				<td width="14%">&nbsp;</td>
				<td><strong>Rating</strong></td>
				<td><strong>&nbsp;Units</strong></td>
			</tr>
			<%while(vRetResult.size() > 0) {
				vEnrlInfo = (Vector)vRetResult.elementAt(0);				
				//check if still can print in the page.. 
				iTemp = vEnrlInfo.size() - 12;
				//System.out.println("Before: "+iNoOfRowPerPg);
				iNoOfRowPerPg = iNoOfRowPerPg - iTemp/9;//3 subjects per row.. 
				if(iTemp%9 > 0)
					--iNoOfRowPerPg;
				//changed to number of students per page.
				//if(iNoOfRowPerPg < 0)//must break so that i cna print all subject of a student in same page.
				//	break;
				if(iNoOfStudent <= 0) 
					break;
				
			
				vRetResult.remove(0);
				
				dTotalUnit = 0d;
				//for(int p = 12; p < vEnrlInfo.size(); p += 3)	
				//	dTotalUnit += Double.parseDouble((String)vEnrlInfo.elementAt(p + 2));
				
				iIndexOf = vStudUnitEarned.indexOf((String)vEnrlInfo.elementAt(0));
				if(iIndexOf  > -1)
					dTotalUnit = ((Double)vStudUnitEarned.elementAt(iIndexOf + 1)).doubleValue();
				
				strStudName = WebInterface.formatName((String)vEnrlInfo.elementAt(4), (String)vEnrlInfo.elementAt(5), (String)vEnrlInfo.elementAt(6), 4);				
				strIDNumber = (String)vEnrlInfo.elementAt(0)+" ("+CommonUtil.formatFloat(dTotalUnit, false)+" units)";
				strIDNumberNew = (String)vEnrlInfo.elementAt(0);
				
				vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);
				vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);
				
				--iNoOfStudent;
				%>
					<tr>
					  <td><%=iCount++%></td>
					  <td>&nbsp;<strong><font style="font-size:9px;"><%=strStudName%></font></strong></td>
					  <td>&nbsp;</td>
					  <%
					  strTemp = "";
					  if(vEnrlInfo.size() > 0)
						  strTemp = (String)vEnrlInfo.elementAt(0);
					  iIndexOf = vForm9GradeList.indexOf(strIDNumberNew+"-"+strTemp);					  
					  %>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=strTemp%><%}%></td>
					  <%
					  strTemp = null;
					  strErrMsg = null;
					  if(iIndexOf > -1){
					  	strTemp = (String)vForm9GradeList.elementAt(iIndexOf + 1);
						strErrMsg = (String)vForm9GradeList.elementAt(iIndexOf + 2);
						if(strErrMsg != null && strErrMsg.equals("0"))
							strErrMsg = "-";
					  }
					  %>
					  <td align="center"><%=WI.getStrValue(strTemp)%><%if(vEnrlInfo.size()>0){%><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>			  
					  <td align="center"><%=WI.getStrValue(strErrMsg)%></td>
					  <%
					  strTemp = "";
					  if(vEnrlInfo.size() > 0)
						  strTemp = (String)vEnrlInfo.elementAt(0);
					  iIndexOf = vForm9GradeList.indexOf(strIDNumberNew+"-"+strTemp);					  
					  %>
					  <td><%if(vEnrlInfo.size() > 0) {%> &nbsp;<%=strTemp%><%}%></td>
					  <%
					  strTemp = null;
					  strErrMsg = null;
					  if(iIndexOf > -1){
					  	strTemp = (String)vForm9GradeList.elementAt(iIndexOf + 1);
						strErrMsg = (String)vForm9GradeList.elementAt(iIndexOf + 2);
						if(strErrMsg != null && strErrMsg.equals("0"))
							strErrMsg = "-";
					  }
					  %>
					  <td align="center"><%=WI.getStrValue(strTemp)%><%if(vEnrlInfo.size() > 0) {%><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td align="center"><%=WI.getStrValue(strErrMsg)%></td>
					  <%
					  strTemp = "";
					  if(vEnrlInfo.size() > 0)
						  strTemp = (String)vEnrlInfo.elementAt(0);
					  iIndexOf = vForm9GradeList.indexOf(strIDNumberNew+"-"+strTemp);					  
					  %>
					  <td><%if(vEnrlInfo.size() > 0) {%> &nbsp;<%=strTemp%><%}%></td>
					  <%
					  strTemp = null;
					  strErrMsg = null;
					  if(iIndexOf > -1){
					  	strTemp = (String)vForm9GradeList.elementAt(iIndexOf + 1);
						strErrMsg = (String)vForm9GradeList.elementAt(iIndexOf + 2);
						if(strErrMsg != null && strErrMsg.equals("0"))
							strErrMsg = "-";
					  }
					  %>
					  <td align="center"><%=WI.getStrValue(strTemp)%><%if(vEnrlInfo.size() > 0) {%><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td align="center"><%=WI.getStrValue(strErrMsg)%></td>
				  </tr>
					<tr>
					  <td>&nbsp;</td>
					  <td>&nbsp;<%=strIDNumber%></td>
					  <td>&nbsp;</td>
					  <%
					  strTemp = "";
					  if(vEnrlInfo.size() > 0)
						  strTemp = (String)vEnrlInfo.elementAt(0);
					  iIndexOf = vForm9GradeList.indexOf(strIDNumberNew+"-"+strTemp);					  
					  %>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=strTemp%><%}%></td>
					  <%
					  strTemp = null;
					  strErrMsg = null;
					  if(iIndexOf > -1){
					  	strTemp = (String)vForm9GradeList.elementAt(iIndexOf + 1);
						strErrMsg = (String)vForm9GradeList.elementAt(iIndexOf + 2);
						if(strErrMsg != null && strErrMsg.equals("0"))
							strErrMsg = "-";
					  }
					  %>
					  <td align="center"><%=WI.getStrValue(strTemp)%><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td align="center"><%=WI.getStrValue(strErrMsg)%></td>
					  <%
					  strTemp = "";
					  if(vEnrlInfo.size() > 0)
						  strTemp = (String)vEnrlInfo.elementAt(0);
					  iIndexOf = vForm9GradeList.indexOf(strIDNumberNew+"-"+strTemp);					  
					  %>
					  <td><%if(vEnrlInfo.size() > 0) {%> &nbsp;<%=strTemp%><%}%></td>
					  <%
					  strTemp = null;
					  strErrMsg = null;
					  if(iIndexOf > -1){
					  	strTemp = (String)vForm9GradeList.elementAt(iIndexOf + 1);
						strErrMsg = (String)vForm9GradeList.elementAt(iIndexOf + 2);
						if(strErrMsg != null && strErrMsg.equals("0"))
							strErrMsg = "-";
					  }
					  %>
					  <td align="center"><%=WI.getStrValue(strTemp)%><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td align="center"><%=WI.getStrValue(strErrMsg)%></td>
					  <%
					  strTemp = "";
					  if(vEnrlInfo.size() > 0)
						  strTemp = (String)vEnrlInfo.elementAt(0);
					  iIndexOf = vForm9GradeList.indexOf(strIDNumberNew+"-"+strTemp);					  
					  %>
					  <td><%if(vEnrlInfo.size() > 0) {%> &nbsp;<%=strTemp%><%}%></td>
					  <%
					  strTemp = null;
					  strErrMsg = null;
					  if(iIndexOf > -1){
					  	strTemp = (String)vForm9GradeList.elementAt(iIndexOf + 1);
						strErrMsg = (String)vForm9GradeList.elementAt(iIndexOf + 2);
						if(strErrMsg != null && strErrMsg.equals("0"))
							strErrMsg = "-";
					  }
					  %>
					  <td align="center"><%=WI.getStrValue(strTemp)%><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td align="center"><%=WI.getStrValue(strErrMsg)%></td>
				  </tr>
				  <%while(vEnrlInfo.size() > 0) {%>
					<tr>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <%
					  strTemp = "";
					  if(vEnrlInfo.size() > 0)
						  strTemp = (String)vEnrlInfo.elementAt(0);
					  iIndexOf = vForm9GradeList.indexOf(strIDNumberNew+"-"+strTemp);					  
					  %>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=strTemp%><%}%></td>
					  <%
					  strTemp = null;
					  strErrMsg = null;
					  if(iIndexOf > -1){
					  	strTemp = (String)vForm9GradeList.elementAt(iIndexOf + 1);
						strErrMsg = (String)vForm9GradeList.elementAt(iIndexOf + 2);
						if(strErrMsg != null && strErrMsg.equals("0"))
							strErrMsg = "-";
					  }
					  %>
					  <td align="center"><%=WI.getStrValue(strTemp)%><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td align="center"><%=WI.getStrValue(strErrMsg)%></td>
					  <%
					  strTemp = "";
					  if(vEnrlInfo.size() > 0)
						  strTemp = (String)vEnrlInfo.elementAt(0);
					  iIndexOf = vForm9GradeList.indexOf(strIDNumberNew+"-"+strTemp);					  
					  %>
					  <td><%if(vEnrlInfo.size() > 0) {%> &nbsp;<%=strTemp%><%}%></td>
					  <%
					  strTemp = null;
					  strErrMsg = null;
					  if(iIndexOf > -1){
					  	strTemp = (String)vForm9GradeList.elementAt(iIndexOf + 1);
						strErrMsg = (String)vForm9GradeList.elementAt(iIndexOf + 2);
						if(strErrMsg != null && strErrMsg.equals("0"))
							strErrMsg = "-";
					  }
					  %>
					  <td align="center"><%=WI.getStrValue(strTemp)%><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td align="center"><%=WI.getStrValue(strErrMsg)%></td>
					  <%
					  strTemp = "";
					  if(vEnrlInfo.size() > 0)
						  strTemp = (String)vEnrlInfo.elementAt(0);
					  iIndexOf = vForm9GradeList.indexOf(strIDNumberNew+"-"+strTemp);					  
					  %>
					  <td><%if(vEnrlInfo.size() > 0) {%> &nbsp;<%=strTemp%><%}%></td>
					  <%
					  strTemp = null;
					  strErrMsg = null;
					  if(iIndexOf > -1){
					  	strTemp = (String)vForm9GradeList.elementAt(iIndexOf + 1);
						strErrMsg = (String)vForm9GradeList.elementAt(iIndexOf + 2);
						if(strErrMsg != null && strErrMsg.equals("0"))
							strErrMsg = "-";
					  }
					  %>
					  <td align="center"><%=WI.getStrValue(strTemp)%><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td align="center"><%=WI.getStrValue(strErrMsg)%></td>
				    </tr>
				  <%}%>
				<tr>
					<td colspan="8" height="12" style="font-size:1px;">&nbsp;</td>
				</tr>

			<%}//end of while loop to print content.. %>
			</table>
			<%if(iPageCount > 1) {%>
				<table width="100%">
					<tr>
						<td colspan="3">&nbsp;</td>
					</tr>
					<tr>
						<td width="25%">&nbsp;</td>
						<td width="35%">&nbsp;</td>
						<td width="40%" align="center" style="font-weight:bold"><u>GRETCHEN LIZARES-TORMIS, MBA</u><br>
					  UNIVERSITY REGISTRAR</td>
					</tr>
				</table>
			<%}%>

		<%
		if(vRetResult.size() == 0 && vFemale.size() > 0 && !strGenderPrinting.equals("FEMALE")) {
			vRetResult = vFemale;
			strGenderPrinting = "FEMALE";
			iCount = 1;	
		}

		%>
			


	
<%}%>	



<%
--iPageCount;
%>

<script language="JavaScript">
function updateTotalPg() {
	var totalPg = <%=iPageCount + 1%>;
	var objLabel; var strTemp;
	for(var i = 2; i <= totalPg; ++i) {
		strTemp = i; 
		eval('objLabel=document.form_._'+i);
		if(!objLabel)
			continue;
		
		objLabel.value = "<%=iPageCount%>";
	}
}
//this.updateTotalPg();
alert("Total no of pages to print : <%=iPageCount%>");
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>