<%if(request.getSession(false).getAttribute("userIndex") == null){%>
	<p style="font-size:14px; font-weight:bold; color:#FF0000;">You are logged out. Please login again.</p>
<%return;}%>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
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
	font-size: <%=WI.fillTextValue("font_size")%>px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
}
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

/**
<%if(WI.fillTextValue("show_border").compareTo("1") ==0){%>
**/
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.thinborderSP {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
/**
<%}else{%>
**/
    TD.thinborderSP {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
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
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderRIGHT {
    border-right: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
	
	TD.jumboborderRIGHTBottom {
    border-right: solid 1px #AAAAAA;
    border-bottom: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

	TD.jumboborderBottom {
    border-bottom: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
	
    TD.jumboborderTOP {
    border-top: solid 2px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderTOPex {
    /**border-top: solid 1px #000000;**/
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.jumboborderTOPONLY {
    border-top: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TABLE.thinborderALL {
    border-left: solid 2px #000000;
    border-right: solid 2px #000000;
    border-top: solid 2px #000000;
    border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
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
	String[] astrConvertYr	= {"ALL YEAR LEVEL","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};

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
Vector vEnrlInfo = new Vector();
boolean bolSeparateName = false;
int iNoOfSubPerRow = 6;
boolean bolShowPageBreak = false;

strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

int iTotalStud = 0;
Vector vRetResult = null; Vector vCourseInfo = new Vector();
int iDefNoOfRowPerPg = 0;
if(request.getParameter("stud_per_pg") == null)
	iDefNoOfRowPerPg = 36;
else
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));

int iNoOfRowPerPg = iDefNoOfRowPerPg;
boolean bolPrintALL = false;
if(WI.fillTextValue("print_all_course").length() > 0) 
	bolPrintALL = true;

if(bolPrintALL) {
	strTemp = "select course_offered.course_index, major_index from course_offered left join major on (course_offered.course_index = major.course_index) "+
				" and major.is_del = 0 where is_valid = 1 order by course_offered.course_code, major.course_code ";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		vCourseInfo.addElement(rs.getString(1));//course_index
		vCourseInfo.addElement(rs.getString(2));//major_index
	}
	rs.close();
}	
else {
	vCourseInfo.addElement(WI.fillTextValue("course_index"));
	vCourseInfo.addElement(WI.fillTextValue("major_index"));
}
String strCourseIndex = null;
String strMajorIndex  = null;
String strCourseName  = null;
String strMajorName   = null; int iPageCount = 1;



Vector vSubList = new Vector();

String strIDNumber = null;
String strSubCode = null;
int iIndexOf = 0;
String strSQLQuery = "";
		
if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("print_all_course").length() == 0)//if they select course
 	strSQLQuery += " and stud_curriculum_hist.course_index = "+WI.fillTextValue("course_index");    

if(WI.fillTextValue("major_index").length() > 0 && WI.fillTextValue("print_all_course").length() == 0)//if they select major
 	strSQLQuery += " and stud_curriculum_hist.major_index = "+WI.fillTextValue("major_index");     

if(WI.fillTextValue("year_level").length() > 0) //if they select year
	strSQLQuery += " and stud_curriculum_hist.year_level = "+WI.fillTextValue("year_level");

strSQLQuery = " select distinct id_number, sub_code, unit_enrolled, section "+
	 " from enrl_final_cur_list "+
	 " join e_sub_section on (e_sub_section.sub_sec_index = enrl_final_cur_list.sub_sec_index) "+	
	 " join stud_curriculum_hist on (stud_curriculum_hist.user_index = enrl_final_cur_list.user_index) "+ 
	 "      and stud_curriculum_hist.sy_from = enrl_final_cur_list.sy_from "+
	 "      and stud_curriculum_hist.semester = enrl_final_cur_list.current_semester "+
	 " join subject on (subject.sub_index = e_sub_section.sub_index) "+
	 " join user_table on (user_table.user_index = stud_curriculum_hist.user_index) "+	
	 " where enrl_final_cur_list.is_valid = 1 "+
	 " and enrl_final_cur_list.sy_from = " + WI.fillTextValue("sy_from") +
	 " and enrl_final_cur_list.current_semester = " + WI.fillTextValue("semester") + strSQLQuery;
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);

while(rs.next()){
	vSubList.addElement(rs.getString(1)+"-"+rs.getString(2));//[0]id_number-sub_code	
	vSubList.addElement(CommonUtil.formatFloat(rs.getDouble(3),false));//[1]credit_earned
	vSubList.addElement(rs.getString(4));//[2]section	
}rs.close();










while(vCourseInfo.size() > 0) {
	strCourseIndex = (String)vCourseInfo.remove(0);
	strMajorIndex  = WI.getStrValue((String)vCourseInfo.remove(0), null);
	
	request.setAttribute("course_",strCourseIndex);
	request.setAttribute("major_",strMajorIndex);
	
	strCourseIndex = "select course_name from course_offered where course_index = "+strCourseIndex;
	strCourseIndex = dbOP.getResultOfAQuery(strCourseIndex, 0);
	
	if(strMajorIndex != null) {
		strMajorIndex = "select major_name from major where major_index = "+strMajorIndex;
		strMajorIndex = dbOP.getResultOfAQuery(strMajorIndex, 0);
	}



		
	
	

	
	strErrMsg = null;
	vRetResult = enrlReport.getEnrollmentListEAC(dbOP,request);
	
	if(vRetResult == null) 
		strErrMsg = enrlReport.getErrMsg();
	else
		iTotalStud = vRetResult.size() - 4;
	//dbOP.cleanUP();
	if(strErrMsg != null)
		continue;
	
	int iStudCount = 1;
	int iTemp = iTotalStud;//total no of rows.
	//iTemp is not correct -- i have to run a for loop to find number of rows.
	
	int iTotalNoOfPage = iTemp / iNoOfRowPerPg;
	if(iTemp%iNoOfRowPerPg > 0) ++iTotalNoOfPage;
	
	
	String strUserIndex = null;
	String strPgCountDisp = null;
	
	double dUnitEnrolled = 0d; String strUnit = null; String strGrade = null;
	String strClass = null;
	int k = 0 ; // index for inner loop (student loop) 
	String strSubjectsLoad = null;
	int iStudNumber = 1;
	
	int iSubLen = 0; double dTotalUnit = 0d;
	
	for(int i=4; i<vRetResult.size();){
		if(iPageCount > 1) {%>
				<DIV style="page-break-after:always">&nbsp;</DIV>
		<%}%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
			  <td width="53%"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
				<td width="47%" align="right">Page <%=Integer.toString(iPageCount++)%></td>
			</tr>
			<tr>
				<td height="18">Enrollment Listing ( per College )</td>
				<td align="right"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))].toUpperCase()%>			  
		<%=request.getParameter("sy_from")%> - <%=Integer.parseInt((String)request.getParameter("sy_from")) + 1%></td>
			</tr>
			<tr><td colspan="2" height="18"><%=strCourseIndex%><%=WI.getStrValue(strMajorIndex, " - ", "", "")%></td></tr>
			<tr><td colspan="2" height="20">&nbsp;</td></tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			
		<%
		for(; i<vRetResult.size();++i){// this is for page wise display.
			vEnrlInfo = (Vector)vRetResult.elementAt(i);
			iTemp = (vEnrlInfo.size() - 12)/3;
			iNoOfRowPerPg = iNoOfRowPerPg - iTemp-1;//to make sure one student printed in a page.
			
			//if(iNoOfRowPerPg <= 0) 
			if(!bolShowPageBreak && iStudCount > 1 && (iStudCount - 1) %5 == 0) {
				bolShowPageBreak = true;
				iNoOfRowPerPg = iDefNoOfRowPerPg;
				break;
			}
			bolShowPageBreak = false;
		%>
			<tr>
				<td colspan="5" valign="top" height="20">
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td valign="top" height="20" width="3%"><%=iStudCount++%>.</td>
							<%
							strIDNumber = (String)vEnrlInfo.elementAt(0);				
							%>
							<td width="57%" valign="top"><%=vEnrlInfo.elementAt(0)%> &nbsp; &nbsp; <%=((String)vEnrlInfo.elementAt(1)).toUpperCase()%> </td>
							<td width="40%" valign="top"><%=WI.getStrValue(vEnrlInfo.elementAt(7))%><%=WI.getStrValue((String)vEnrlInfo.elementAt(8)," MAJOR IN ","","")%>
							<%=WI.getStrValue((String)vEnrlInfo.elementAt(9)," - ","","")%></td>
						</tr>	
					</table>				
				</td>				
			</tr>			
			<tr>
			  <td>&nbsp;</td>
			  <td>Subject</td>
			  <td>Descriptive Title</td>
			  <td align="right">Units</td>
			  <td align="">&nbsp;Classcode</td>
		  	</tr>
			<%
			vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);
			vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);
			vEnrlInfo.remove(0);vEnrlInfo.remove(0);
			int iCount = 1;
			while(vEnrlInfo.size() > 0) {
			dTotalUnit += Double.parseDouble((String)vEnrlInfo.elementAt(2));
			%>
				
				<tr>
					<td width="3%"><%=iCount++%>.</td>					
					<%
					strErrMsg = null;
					strSubCode = (String)vEnrlInfo.remove(0);					
					strTemp = strIDNumber +"-"+ strSubCode;					
					iIndexOf = vSubList.indexOf(strTemp);
					if(iIndexOf > -1)
						strErrMsg = (String)vSubList.elementAt(iIndexOf + 2);
					%>
					
					<td style="font-weight:bold" width="13%"><%=strSubCode%></td>
					<td style="font-weight:bold" width="74%"><%=((String)vEnrlInfo.remove(0)).toUpperCase()%></td>
					<td style="font-weight:bold" width="5%" align="right"><%=vEnrlInfo.remove(0)%></td>
					<td width="5%" align="">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
				</tr>
			<%}%>
				<tr>
					<td valign="top" height="30" width="3%">&nbsp;</td>
					<td valign="top" width="13%">&nbsp;</td>
					<td valign="top" width="74%" align="center"> * &nbsp; * &nbsp; * Total Units * &nbsp; * &nbsp; * </td>
					<td valign="top" width="5%" align="right" style="font-weight:bold"><%=dTotalUnit%></td>
					<td valign="top" width="5%">&nbsp;</td>
				</tr>
		<%dTotalUnit = 0d;}//end of for loop to display content.. %>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tr><td align="right"><font style="font-size:9px;"><%=WI.getTodaysDateTime()%></font></td></tr>
		</table>
	<%}%>	
<%}//print all LOOOOOOOOOOOP%>



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
this.updateTotalPg();
alert("Total no of pages to print : <%=iPageCount%>");
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>