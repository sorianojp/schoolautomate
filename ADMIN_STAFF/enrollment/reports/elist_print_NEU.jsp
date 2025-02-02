<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	java.sql.ResultSet rs = null;
	String strSchCode = null;//for UI , do not show remarks.
	//for CLDH, show total enrolled unit instead of remark.
	strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) {%>
	
		<p style="font-size:14px; color:#FF0000; font-weight:bold">You are already logged out. Please login again.</p>
	<%return;}


	String strOrigSchCode = strSchCode;
	boolean bolIsCSA = strSchCode.startsWith("CSA");
	boolean bolIsSPC = strSchCode.startsWith("SPC");
	
	String strFontSize = WI.fillTextValue("font_size");
	if(strFontSize.length() == 0) 
		strFontSize = "8";
		
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:9px;
}
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

    TABLE.jumboborder {
    border-top: solid 2px #000000;
    border-bottom: solid 2px #000000;
    border-left: solid 2px #000000;
    border-right: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.jumboborderRIGHT {
    border-right: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.jumboborderTOP {
    border-top: solid 2px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.jumboborderTOPex {
    /**border-top: solid 1px #000000;**/
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.jumboborderTOPONLY {
    border-top: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }


-->
</style>
</head>
<script>
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
<%
	String strErrMsg = null;String strTemp = null;

	String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER"};
	String[] astrConvertYr	= {"N/A","1","2","3","4","5","6","7"};

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

String strCourseType = null;//for masteral trimester.. 
String strSQLQuery = null;

//this is college list for NEU
int iCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("_count"), "0"));
for(int i = 0; i < iCount; ++i) {
	if(WI.fillTextValue("_"+i).length() > 0) {
	  if(strSQLQuery == null)
		  strSQLQuery = WI.fillTextValue("_"+i);
	  else
		strSQLQuery = strSQLQuery+","+WI.fillTextValue("_"+i);
	}
}
/*
if(strSQLQuery == null) {
	if(WI.fillTextValue("c_index").length() > 0)
		strSQLQuery = " and c_index = "+WI.fillTextValue("c_index");
	else if(WI.fillTextValue("course_index").length() > 0)
		strSQLQuery = " and course_index = "+WI.fillTextValue("course_index");
}
else {
	strSQLQuery = " and course_index in ("+strSQLQuery+")";
}

if(strSQLQuery != null) {
	strSQLQuery = "select distinct degree_type from course_offered where is_valid = 1 "+strSQLQuery;
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		if(strCourseType == null)
			strCourseType = rs.getString(1);
		else {
			strCourseType = null;
			strErrMsg = "Can't Print UG and Masteral course.";
			break;
		}
	}
	rs.close();
}


if(strCourseType == null && strErrMsg == null)
	strErrMsg = "Course Degree type is missing.";
	
if(strSchCode.startsWith("NEU"))
	strErrMsg = null;
*/

ReportEnrollment enrlReport = new ReportEnrollment();
int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("stud_per_pg"),"0"));
Vector vRetResult = null;
Vector vUserIndex     = new Vector();
Vector vStudBasicInfo = new Vector();
Vector vEnrlInfo      = new Vector();//[0] user_index, [1] = total units enrolled, [2] = total subjects enrolled, [3] sub_code, sub_name, units - Vector.
Vector vSubInfo       = new Vector();
Vector vCourseList    = new Vector();
boolean bolShowCourse = true;
	
/*if(WI.fillTextValue("c_index").length() > 0) {//print only RegularCollege	
	strCollegeName = "select c_name from college where c_index = "+WI.fillTextValue("c_index");
	strCollegeName = dbOP.getResultOfAQuery(strCollegeName,0);	
}*/



strTemp = "select course_index, course_code, course_name, c_name "+
	" from course_offered "+
	" join college on (college.c_index = course_offered.c_index ) "+
	" where course_offered.IS_DEL=0 and course_offered.is_valid=1 ";// and course_offered.is_offered = 1";
if(WI.fillTextValue("c_index").length() > 0)
	strTemp += " and course_offered.c_index = "+WI.fillTextValue("c_index");
else{
	if(strSQLQuery != null && strSQLQuery.length() > 0)
		strTemp += " and course_offered.c_index not in ("+strSQLQuery+")";
}
strTemp += " order by c_name, course_offered.course_name asc ";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	vCourseList.addElement(rs.getString(1));
	vCourseList.addElement(rs.getString(2));
	vCourseList.addElement(rs.getString(3));
	vCourseList.addElement(rs.getString(4));
}rs.close();

if(vCourseList.size() == 0)
	strErrMsg = "No course information found.";

if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0">
<tr>
	<td>
		<font size="4"><%=strErrMsg%></font>
	</td>
</tr>
</table>
<%dbOP.cleanUP();
return;
}


String[] astrConvertYear = {"&nbsp;","I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII","XIII","XIV","XV"};
int iPageNo      = 0;
int iStudCount   = 0; 
int iRowsPrinted = 0;
int iIndexOf     = 0;

String strUnitsEnrolled = null;

String strCollegeName = null;
String strCourseIndex = null;
String strCourseCode  = null;
String strCourseName  = null;
String strGender 	  = null;
String strYearLevel   = null;
String strPrevCourse  = "";

boolean bolChangeCourse = false;
boolean bolResetStudCount = false;

String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchAdd  = SchoolInformation.getAddressLine1(dbOP,false,false);
int iCourseCount = 0;
int iCourseLoopCount = 0;
while(vCourseList.size() > 0){
strCourseIndex = (String)vCourseList.remove(0);
strCourseCode  = (String)vCourseList.remove(0);
strCourseName  = (String)vCourseList.remove(0);
strCollegeName = (String)vCourseList.remove(0);

if(!strPrevCourse.equals(strCourseName) && iCourseCount > 1){
	strPrevCourse = strCourseName;
	bolChangeCourse = true;
}

request.setAttribute("course_indx",strCourseIndex);
request.setAttribute("course_index",strCourseIndex);

vRetResult = enrlReport.getEnrollmentListCSA(dbOP, request);
if(vRetResult == null || ((Vector)vRetResult.elementAt(0)) == null)
	continue;
	//strErrMsg = enrlReport.getErrMsg();

vUserIndex     = (Vector)vRetResult.remove(0);
vStudBasicInfo = (Vector)vRetResult.remove(0);
vEnrlInfo      = (Vector)vRetResult.remove(0);
bolResetStudCount = true;
//iPageNo      = 0;
iStudCount   = 0; //reset count per course change
iRowsPrinted = 0;
iIndexOf     = 0;

strUnitsEnrolled = null;

while(vUserIndex.size() > 0) {
iRowsPrinted =0;
if(iPageNo > 0 || (bolChangeCourse)) {%>
	<DIV style="page-break-after:always;" >&nbsp;</DIV>
<%}%>
	<table width="100%" cellpadding="0" cellspacing="0">
		
		<tr><td colspan="3" align="center">
		<font style="font-size:15px;"><%=strSchName%></font><br>
		<%=strSchAdd%>
		</td></tr>
		
		<tr>
			<td width="33%">&nbsp;</td>
			<td width="33%" align="center">
			ENROLLMENT LISTS <BR>
			<%=WI.getStrValue(strCollegeName,"<br>","<br>","")%>
			<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></td>
			<td width="33%" align="right">&nbsp;</td>
		</tr>
		<tr>
		  <td colspan="2">
		  Course : <%=strCourseName%><br>
		  Date: <%=WI.getTodaysDate(1)%></td>
		  <td align="right">PAGE NO.: <%=++iPageNo%></td>
	  </tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
		<%
		/*if(!bolIsSPC)
			strTemp = "EL NO.";
		else*/
			strTemp = "No.";
		%>
		  <td class="thinborder" width="2%" align="center"><%=strTemp%></td>			
			<td class="thinborder" width="20%" align="center">Name of Students</td>
			<td class="thinborder">Gender</td>
			<%if(!bolShowCourse){%><td class="thinborder">Course</td>			
			<td class="thinborder" align="center">Major</td><%}%>
			<td class="thinborder" align="center">Year</td>		
			<td class="thinborder" width="5%" align="center">Subject</td>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" align="center">Total Units </td>
		</tr>
		<%
		//String[] astrConvertYr
		
		while(vStudBasicInfo.size() > 0){	
		
		
			 
			  
			strTemp = (String)vStudBasicInfo.elementAt(5);
			  if(strYearLevel != null && !strYearLevel.equals(strTemp)){
			  	bolResetStudCount = true;
				strYearLevel = null;
			}else
				strYearLevel = strTemp;
				
			 strTemp = (String)vStudBasicInfo.elementAt(4);
			  if(strGender != null && !strGender.equals(strTemp)){
			  	bolResetStudCount = true;
				strGender = null;
			}else
				strGender = strTemp;
		
		if(bolResetStudCount){
			bolResetStudCount = false;
			//strGender = null;
			//strYearLevel = null;
			iStudCount = 0;
		}
		%>
			<tr>
			  <td class="thinborder"><%=++iStudCount%></td>
			  <!--<td><%//=++iStudCount%>.</td>
			  <td><%vStudBasicInfo.remove(0);%></td>--><!-- ID -->
			  <%
			  strTemp = vStudBasicInfo.remove(2)+", "+vStudBasicInfo.remove(0)+" "+WI.getStrValue(vStudBasicInfo.remove(0));
			  %>
			  <td class="thinborder"><%=WI.getStrValue(strTemp).toUpperCase()%>			  </td><!--name-->
			  <%
			  strTemp = (String)vStudBasicInfo.remove(0);			  
			  %>
			  <td class="thinborder" align="center"><%=strTemp%></td><!-- gender -->	
			  <%
			  strTemp = WI.getStrValue((String)vStudBasicInfo.remove(1),"&nbsp;");
			  %>		 
			  <%if(!bolShowCourse){%><td class="thinborder"><%=strTemp%></td><%}%><!-- course--->	
			  <%
			  strTemp = (String)vStudBasicInfo.remove(1);
			  vStudBasicInfo.remove(1);
			  %>		  
			   <%if(!bolShowCourse){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%><!-- course-major-->
			   <%
			   strTemp = astrConvertYr[Integer.parseInt(WI.getStrValue((String)vStudBasicInfo.remove(0),"0"))];
			   %>
			  <td class="thinborder" align="center"><%=strTemp%></td><!-- year -->
			  <%//System.out.println("User Index : "+vUserIndex.elementAt(0));
			  iIndexOf = vEnrlInfo.indexOf((String)vUserIndex.remove(0));
			  
			  strUnitsEnrolled = (String)vEnrlInfo.elementAt(iIndexOf + 1);
			  
			  vEnrlInfo.remove(iIndexOf);//remove user_index
			  vEnrlInfo.remove(iIndexOf + 1);//number of subject..
			  vSubInfo = (Vector)vEnrlInfo.remove(iIndexOf + 1);
			  
			  %>
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  
			  <%///enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnitsEnrolled, "&nbsp;")%></td><%//enrlReport.getNextElement(vSubInfo);%>
		  </tr>
		<!-- now, print if subject goes to 2nd or 3rd line -->
		<%while(vSubInfo.size() > 0){
		
		%>
			<tr>
			  <%
			  strTemp = "4";
			  if(!bolShowCourse)
			  	strTemp = "6";
				

			  %>
			  <td class="thinborder" colspan="<%=strTemp%>">&nbsp;</td>
			  
			  
			  
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td class="thinborder"><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center"><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <%enrlReport.getNextElement(vSubInfo);%>
			  <td class="thinborder" align="center">&nbsp;</td>
			  <%enrlReport.getNextElement(vSubInfo);%>
		  </tr>
		<%++iRowsPrinted;}%>



		<%
		if(++iRowsPrinted >=iRowsPerPage)
			break;
		}//end of showing per row%>
	</table>

<%
}//end of outer loop.. while(vUserIndex.size() > 0 
iCourseCount++;
}//end while loop for course
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
