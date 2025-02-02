<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) {%>	
		<p style="font-size:14px; color:#FF0000; font-weight:bold">You are already logged out. Please login again.</p>
	<%return;}
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	java.sql.ResultSet rs = null;

	
	boolean bolShowData = true;
	if(WI.fillTextValue("print_to_excel").length() > 0)
		bolShowData = false;


	String strOrigSchCode = strSchCode;
	
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

<body topmargin="0" bottommargin="0" <%if(bolShowData){%>onLoad="CallOnLoad();window.print();"<%}%>  bgcolor="#DDDDDD">
<!-- Printing information. -->
<%if(bolShowData){%>
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
<%}

	String strErrMsg = null;String strTemp = null;

	String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER"};
	String[] ConvertYearLevel	= {"N/A","First Year","Second Year","Third Year","Fourth Year","Fifth Year","Sixth Year","Seventh Year"};

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

int iMale = 0;
int iFemale =0;
int iTotGender = 0;

int iIrMale = 0;
int iIrFemale = 0;
int iIrTotGender = 0;

int iMaxSubject = -1;
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
if(WI.fillTextValue("course_index").length() > 0)
	strTemp += " and course_offered.course_index = "+WI.fillTextValue("course_index");

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

utility.CreateExcelSheet ces = new utility.CreateExcelSheet();
ces.dontCreateFile(bolShowData);
ces.createFile(dbOP, request, "EnrollmentList");	
ces.createNewSheet("EnrollmentList");


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

String strStudId = null;


Vector vRegular = new Vector();
Vector vIrregular = new Vector();


Vector vRegularUser = new Vector();
Vector vIrregularUser = new Vector();

Vector vRegIrregStud = new Vector();
strTemp = " select user_table.user_index, id_number, COURSE_REGULARITY_STAT  "+
	" from STUD_CURRICULUM_HIST "+
	" join user_table on (user_table.user_index = stud_curriculum_hist.user_index)"+
	" where STUD_CURRICULUM_HIST.IS_VALID = 1 "+
	" and SY_FROM = "+WI.fillTextValue("sy_from")+
	" and SEMESTER  = "+WI.fillTextValue("semester")+
	" and COURSE_INDEX  > 0 ";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	vRegIrregStud.addElement(rs.getString(2)+"_user");//id
	vRegIrregStud.addElement(rs.getString(1));//user
	if(rs.getString(3) == null)
		vRegIrregStud.addElement("1");
	else
		vRegIrregStud.addElement(rs.getString(3));
}rs.close();


String strUserIndex = null;
boolean bolIsIrregular = false; //flag to check if the loop user_index already irregular

String strRegular = null;
while(vCourseList.size() > 0){
strCourseIndex = (String)vCourseList.remove(0);
strCourseCode  = (String)vCourseList.remove(0);
strCourseName  = (String)vCourseList.remove(0);
strCollegeName = (String)vCourseList.remove(0);
bolIsIrregular = false;
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



	for(int i = 0 ; i < vStudBasicInfo.size(); i+=9){
		strUserIndex = (String)vStudBasicInfo.elementAt(i);//this is ID
		
		iIndexOf = vRegIrregStud.indexOf(strUserIndex+"_user");
		if(iIndexOf == -1)
			continue;
			
		strTemp = (String)vRegIrregStud.elementAt(iIndexOf + 2);
		if(strTemp.equals("0")){
			vRegularUser.addElement((String)vRegIrregStud.elementAt(iIndexOf + 1));
			vRegular.addElement(strUserIndex);
			vRegular.addElement(vStudBasicInfo.elementAt(i + 1));
			vRegular.addElement(vStudBasicInfo.elementAt(i + 2));
			vRegular.addElement(vStudBasicInfo.elementAt(i + 3));
			vRegular.addElement(vStudBasicInfo.elementAt(i + 4));
			vRegular.addElement(vStudBasicInfo.elementAt(i + 5));
			vRegular.addElement(vStudBasicInfo.elementAt(i + 6));
			vRegular.addElement(vStudBasicInfo.elementAt(i + 7));
			vRegular.addElement(vStudBasicInfo.elementAt(i + 8));
		}else{
			vIrregularUser.addElement((String)vRegIrregStud.elementAt(iIndexOf + 1));
			vIrregular.addElement(strUserIndex);
			vIrregular.addElement(vStudBasicInfo.elementAt(i + 1));
			vIrregular.addElement(vStudBasicInfo.elementAt(i + 2));
			vIrregular.addElement(vStudBasicInfo.elementAt(i + 3));
			vIrregular.addElement(vStudBasicInfo.elementAt(i + 4));
			vIrregular.addElement(vStudBasicInfo.elementAt(i + 5));
			vIrregular.addElement(vStudBasicInfo.elementAt(i + 6));
			vIrregular.addElement(vStudBasicInfo.elementAt(i + 7));
			vIrregular.addElement(vStudBasicInfo.elementAt(i + 8));
		}
	}

/*vUserIndex = new Vector();
if(vRegularUser.size() > 0)
	vUserIndex.addAll(vRegularUser);
if(vIrregularUser.size() > 0){
	vUserIndex.addAll(vIrregularUser);	
}*/


vUserIndex = new Vector();
if(vRegularUser.size() > 0){
	vUserIndex.addAll(vRegularUser);
	vRegularUser = new Vector();
}
if(vIrregularUser.size() > 0){
	vUserIndex.addAll(vIrregularUser);	
	vIrregularUser = new Vector();
}


vStudBasicInfo = new Vector();
if(vRegular.size() > 0){
	vStudBasicInfo.addAll(vRegular);
	
}
if(vIrregular.size() > 0 && vRegular.size() == 0){
	vStudBasicInfo.addAll(vIrregular);	
}


Vector vTemp = null;
for(int i =0 ; i < vEnrlInfo.size(); i+=4){
	vTemp = (Vector)vEnrlInfo.elementAt(i+3);
	if((vTemp.size()/3) > iMaxSubject)
		iMaxSubject = (vTemp.size()/3);	
}


bolResetStudCount = true;
//iPageNo      = 0;
iStudCount   = 0; //reset count per course change
iRowsPrinted = 0;
iIndexOf     = 0;

strUnitsEnrolled = null;

iMale = 0;
iFemale =0;
iTotGender = 0;

iIrMale = 0;
iIrFemale = 0;
iIrTotGender = 0;

while(vUserIndex.size() > 0) {

ces.setFontSize(Integer.parseInt(WI.fillTextValue("font_size")));				
ces.setBorderLineStyle(0);
ces.setBorder(0);

ces.setAlignment(0);

if( iPageNo > 0 || bolChangeCourse || bolIsIrregular) {


if(!bolShowData){
	ces.addData("&nbsp;", true, (iMaxSubject * 2) + 8, 0);	
	ces.addData("&nbsp;", true, (iMaxSubject * 2) + 8, 0);	
	ces.addData("&nbsp;", true, (iMaxSubject * 2) + 8, 0);	
	ces.addData("&nbsp;", true, (iMaxSubject * 2) + 8, 0);	
	ces.addData("&nbsp;", true, (iMaxSubject * 2) + 8, 0);			
}else{
%>
	<DIV style="page-break-after:always;" >&nbsp;</DIV>
<%}}
++iPageNo;


if(vStudBasicInfo.size() == 0 && vIrregular.size() > 0){
	vStudBasicInfo.addAll(vIrregular);
	bolIsIrregular = true;
	vIrregular = new Vector();
	iStudCount = 0;
	iRowsPrinted = 0;
}





ces.setBold(false);
ces.addData("School:", false, 1);
ces.setBold(true);
ces.addData(strSchName, true, (iMaxSubject * 2) + 6);

ces.setBold(false);
ces.addData("Address:", false, 1);
ces.setBold(true);
ces.addData(strSchAdd, true, (iMaxSubject * 2) + 6);


ces.setBold(false);
ces.addData("Region:", false, 1);
ces.setBold(true);
ces.addData("IV", true, (iMaxSubject * 2) + 6);

ces.setBold(false);
ces.addData("Tel#:", false, 1);
ces.setBold(true);
ces.addData("(046)  481-8000 / (02) 988-3100", true, (iMaxSubject * 2) + 6);


ces.setBold(true);
strTemp = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]+" "+
	WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to");
ces.addData(strTemp, true, (iMaxSubject * 2) + 8);

ces.setBold(false);
ces.addData("Course:", false, 1);
ces.setBold(true);
ces.addData(strCourseName, true, (iMaxSubject * 2) + 6);

if(WI.fillTextValue("year_level").length() > 0){
	ces.setBold(false);
	ces.addData("Year Level:", false, 1);
	ces.setBold(true);
	ces.addData(ConvertYearLevel[Integer.parseInt(WI.fillTextValue("year_level"))], true, iMaxSubject + 6);
}


strRegular = "Regular";
if(bolIsIrregular)
	strRegular = "Irregular";
	
ces.setBold(true);
ces.addData(strRegular, true, iMaxSubject + 8);

if(bolShowData){
%>
	<table width="100%" cellpadding="0" cellspacing="0">
		
		<tr><td width="7%" align="left" style="font-size:11px;">School:</td>
		    <td style="font-size:11px;" width="33%" align="left"><strong><%=strSchName%></strong></td>
		    <td style="font-size:11px;" width="6%" align="left">Course</td>
		    <td style="font-size:11px;" width="23%" align="left"><strong><%=strCourseName%></strong></td>
			<%
			strTemp = WI.fillTextValue("year_level");
			if(strTemp.length() > 0)
				strTemp = ConvertYearLevel[Integer.parseInt(WI.fillTextValue("year_level"))];
			else
				strTemp = "";				
			%>
		    <td style="font-size:11px;" width="9%" align="left"><%if(strTemp.length() > 0){%>Year Level<%}%></td>			
		    <td style="font-size:11px;" width="10%" align="left"><strong><%=strTemp%></strong></td>
		    <td  style="font-size:11px;" width="12%" align="left"><strong><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%></strong></td>
		</tr>
		<tr>
		    <td style="font-size:11px;" align="left">Address</td>
		    <td style="font-size:11px;" align="left"><strong><%=strSchAdd%></strong></td>
		    <td style="font-size:11px;" align="left">Tel#</td>
		    <td style="font-size:11px;" align="left"><strong>(046)  481-8000 / (02) 988-3100</strong></td>
		    <td style="font-size:11px;" align="left">Region</td>
		    <td style="font-size:11px;" align="left"><strong>IV</strong></td>
	        <td style="font-size:11px;" align="left"><strong><%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></td>
		</tr>
		<tr>
		    <td style="font-size:11px;" align="left">&nbsp;</td>
		    <td style="font-size:11px;" align="left">&nbsp;</td>
		    <td style="font-size:11px;" align="left">&nbsp;</td>
		    <td style="font-size:11px;" align="left">&nbsp;</td>
		    <td style="font-size:11px;" align="left">&nbsp;</td>
		    <td style="font-size:11px;" align="left">&nbsp;</td>
		    <td style="font-size:11px;" align="left">&nbsp;</td>
	    </tr>
		<%
			strTemp = WI.fillTextValue("year_level");
			if(strTemp.length() > 0)
				strTemp = ConvertYearLevel[Integer.parseInt(WI.fillTextValue("year_level"))];
			else
				strTemp = "";				
			%>
		<tr>
		    <td colspan="7" align="left" style="font-size:11px;"><strong><%=strTemp%></strong></td>
	    </tr>
		<tr>
		    <td colspan="7" align="left" style="font-size:11px;"><strong><%=strRegular.toUpperCase()%></strong></td>
	    </tr>
	</table>
<%}
ces.setBorderLineStyle(1);
ces.setBold(false);
ces.setBorder(1);
ces.setAlignment(1);
ces.addData("No.", false);
ces.addData("Student No.", false);
ces.addData("Name of Students", false);
ces.addData("M", false);
ces.addData("F", false);
ces.addData("Total", false);
ces.addData("Gender", false);
for(int x = 0 ; x < iMaxSubject; x++){
	ces.addData("Subject", false);
	ces.addData("Units", false);
}
ces.addData("Total Unit(s)", false);
ces.addData("Remarks", true);

if(bolShowData){ 
%>
	<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>		
		  <td class="thinborder" width="2%" align="center">No.</td>			
			<td class="thinborder" width="8%" align="center">Student No.</td>
			<td align="center" class="thinborder">Name of Students</td>
			<td class="thinborder" width="2%" align="center">M</td>
			<td class="thinborder" width="2%" align="center">F</td>
			<td class="thinborder" width="3%" align="center">TOTAL</td>
			<td width="3%" class="thinborder">Gender</td>
			<%for(int x = 0 ; x < iMaxSubject; x++){%>
			<td class="thinborder" width="4%" align="center">Subject</td>
			<td width="2%" align="center" class="thinborder">Units</td>
			<%}%>			
			<td width="3%" align="center" class="thinborder">Total Units </td>
		    <td width="5%" align="center" class="thinborder">Remarks</td>
		</tr>
		<%}//end if(bolShowData)

		
		while(vStudBasicInfo.size() > 0){	
		
		
		
		ces.setBorderLineStyle(1);
		ces.setAlignment(0);
		//strStudId = (String)vStudBasicInfo.remove(0);
		strStudId = (String)vStudBasicInfo.elementAt(0);
		ces.addData(Integer.toString((++iStudCount)), false);
		
		ces.addData(strStudId, false);
		
		strTemp = vStudBasicInfo.elementAt(3)+", "+vStudBasicInfo.elementAt(1)+" "+WI.getStrValue(vStudBasicInfo.elementAt(2));
		ces.addData(strTemp, false);

		strTemp = WI.getStrValue((String)vStudBasicInfo.elementAt(4),"M").toLowerCase();			  
	  	if(strTemp.equals("m")){
			strTemp = "1";
			strErrMsg = "&nbsp;";
	  	}else{
			strTemp = "&nbsp;";
			strErrMsg = "1";
	  	}			  	
		
		
		if(!bolIsIrregular){
			try{
			iMale += Integer.parseInt(strTemp);
			}catch(Exception e){}
			
			try{
			iFemale += Integer.parseInt(strErrMsg);
			}catch(Exception e){}				

			iTotGender += 1;
		  }else{
			try{
			iIrMale += Integer.parseInt(strTemp);
			}catch(Exception e){}
			
			try{
			iIrFemale += Integer.parseInt(strErrMsg);
			}catch(Exception e){}				

			iIrTotGender += 1;
		  }
		
		ces.setAlignment(1);
		ces.addData(strTemp, false);//M
		ces.addData(strErrMsg, false);//F
		ces.addData("1", false);//TOTAL
		
		strTemp = WI.getStrValue((String)vStudBasicInfo.elementAt(4),"M");	
		ces.addData(strTemp, false);//GENDER
		ces.setAlignment(0);
		if(bolShowData){
		%>
			<tr>
			  <td height="18" class="thinborder"><%=iStudCount%></td>			  
			  <td class="thinborder"><%=strStudId%></td>
			  <%
			  //strTemp = vStudBasicInfo.remove(2)+", "+vStudBasicInfo.remove(0)+" "+WI.getStrValue(vStudBasicInfo.remove(0));
			  strTemp = vStudBasicInfo.elementAt(3)+", "+vStudBasicInfo.elementAt(1)+" "+WI.getStrValue(vStudBasicInfo.elementAt(2));
			  %>
			  <td class="thinborder"><%=WI.getStrValue(strTemp).toUpperCase()%>			  </td>
			  <%
			  strTemp = WI.getStrValue((String)vStudBasicInfo.elementAt(4),"M").toLowerCase();			  
			  if(strTemp.equals("m")){
			  	strTemp = "1";
				strErrMsg = "&nbsp;";
			  }else{
			  	strTemp = "&nbsp;";
				strErrMsg = "1";
			  }					  	  	
			  %>
			  <td class="thinborder" align="center"><%=strTemp%></td>
			  <td class="thinborder" align="center"><%=strErrMsg%></td>
			  <td class="thinborder" align="center">1</td>			  
			  <td class="thinborder" align="center"><%=(String)vStudBasicInfo.elementAt(4)%></td><!-- gender -->	
			 
			  <%}//end if(bolShowData)
			  
				vStudBasicInfo.remove(0);vStudBasicInfo.remove(0);vStudBasicInfo.remove(0);
				vStudBasicInfo.remove(0);vStudBasicInfo.remove(0);vStudBasicInfo.remove(0);
				vStudBasicInfo.remove(0);vStudBasicInfo.remove(0);vStudBasicInfo.remove(0);
			
			  //if(strStudId.equals("2008-00674"))
			  //if(iStudCount < 60)
			//	  System.out.println((String)vUserIndex.elementAt(0));
				  
			  iIndexOf = vEnrlInfo.indexOf((String)vUserIndex.remove(0));	
			  
			  /*if(strStudId.equals("2008-00674")){
			  	//System.out.println(vEnrlInfo);
				System.out.println(vEnrlInfo.elementAt(iIndexOf));
				System.out.println(vEnrlInfo.elementAt(iIndexOf+1));
				System.out.println(vEnrlInfo.elementAt(iIndexOf+2));
				System.out.println(vEnrlInfo.elementAt(iIndexOf+3));			  
			  }*/
			  	
			  

			  
			  strUnitsEnrolled = (String)vEnrlInfo.elementAt(iIndexOf + 1);
			  
			  vEnrlInfo.remove(iIndexOf);//remove user_index
			  vEnrlInfo.remove(iIndexOf);//total units
			  vEnrlInfo.remove(iIndexOf);//number of subjects
			  vSubInfo = (Vector)vEnrlInfo.remove(iIndexOf);//sub info
			  //if(strStudId.equals("2004-01758"))
				//  System.out.println(vSubInfo);
			  %>
			  <%for(int x = 0 ; x < iMaxSubject; x++){
			  
			  strTemp = enrlReport.getNextElement(vSubInfo);//code
			  enrlReport.getNextElement(vSubInfo);//name
			  strErrMsg = enrlReport.getNextElement(vSubInfo);//subject unit
			  
			  ces.addData(strTemp);//M
			  ces.addData(strErrMsg);//F
			  if(bolShowData){
			  %>
			  <td class="thinborder"><%=strTemp%></td><%%>
			  <td class="thinborder" align="center"><%=strErrMsg%></td>
			  <%
			  }
			  }//end loop
			  
			  ces.addData(WI.getStrValue(strUnitsEnrolled, "&nbsp;"));//F
			  ces.addData(strRegular, true);//F
			  if(bolShowData){
			  %>
			  
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnitsEnrolled, "&nbsp;")%></td>
			  <td class="thinborder" align="center"><%=strRegular%></td>
			  <%//enrlReport.getNextElement(vSubInfo);%>
		  </tr>
		<%}//end if(bolShowData)
		if(vStudBasicInfo.size() == 0){
		
		ces.setBorder(1);
		ces.setBorderLineStyle(1);
		ces.addData("&nbsp;");
		ces.addData("&nbsp;");
		ces.addData("&nbsp;");
		
		strTemp = Integer.toString(iMale);
		if(bolIsIrregular)
			strTemp = Integer.toString(iIrMale);
		ces.addData(strTemp);
		
		strTemp = Integer.toString(iFemale);
		if(bolIsIrregular)
			strTemp = Integer.toString(iIrFemale);
		ces.addData(strTemp);
		
		strTemp = Integer.toString(iTotGender);
		if(bolIsIrregular)
			strTemp = Integer.toString(iIrTotGender);
		ces.addData(strTemp);
		
		ces.addData("&nbsp;");
		for(int x = 0 ; x < iMaxSubject; x++){
		ces.addData("&nbsp;");
		ces.addData("&nbsp;");
		}
		ces.addData("&nbsp;");
		ces.addData("&nbsp;", true);
		
		if(bolShowData){
		%>
		<tr>
			    <td height="18" class="thinborder">&nbsp;</td>
			    <td class="thinborder">&nbsp;</td>
			    <td class="thinborder">&nbsp;</td>
				<%
				strTemp = Integer.toString(iMale);
				if(bolIsIrregular)
					strTemp = Integer.toString(iIrMale);
				%>
			    <td class="thinborder" align="center"><%=strTemp%></td>
				<%
				strTemp = Integer.toString(iFemale);
				if(bolIsIrregular)
					strTemp = Integer.toString(iIrFemale);
				%>
			    <td class="thinborder" align="center"><%=strTemp%></td>
				<%
				strTemp = Integer.toString(iTotGender);
				if(bolIsIrregular)
					strTemp = Integer.toString(iIrTotGender);
				%>
			    <td class="thinborder" align="center"><%=strTemp%></td>
				
			    <td class="thinborder" align="center">&nbsp;</td>
				<%for(int x = 0 ; x < iMaxSubject; x++){%>
			    <td class="thinborder">&nbsp;</td>
			    <td class="thinborder" align="center">&nbsp;</td>
				<%}%>
			    <td class="thinborder" align="center">&nbsp;</td>
			    <td class="thinborder" align="center">&nbsp;</td>
	    </tr>
		<%}}
		
		if((++iRowsPrinted >=iRowsPerPage)){
			iRowsPrinted = 0;
			//bolIsIrregular = false;
			break;
		}
		}//end of showing per row
		
		if(bolShowData){
		%>
	</table>

<%}

}//end of outer loop.. while(vUserIndex.size() > 0 
iCourseCount++;
}//end while loop for course


strTemp = WI.getStrValue((String)request.getSession(false).getAttribute("first_name"));
String strPreparedby = WI.getStrValue(WI.fillTextValue("printed_by"),strTemp);
String strPreparedbyDesig = WI.getStrValue(WI.fillTextValue("printed_by_designation"),"Coordinator, Enrollment Services");


strTemp = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7));
String strNotedby = WI.getStrValue(WI.fillTextValue("checked_by"),strTemp);
String strNotedbyDesig = WI.getStrValue(WI.fillTextValue("checked_by_designation"),"Registrar");

if(!bolShowData){
	ces.setBorder(0);
	ces.addData("&nbsp;", true, (iMaxSubject * 2) + 8, 0);	
	ces.addData("&nbsp;", true, (iMaxSubject * 2) + 8, 0);	
	ces.addData("&nbsp;", true, (iMaxSubject * 2) + 8, 0);	
	
	ces.setBold(false);
	ces.addData("Prepared by:", false, 1);
	ces.setBold(true);
	ces.addData(strPreparedby, true, (iMaxSubject * 2) + 6);
	ces.setBold(false);
	ces.addData("&nbsp;", false, 1);	
	ces.addData(strPreparedbyDesig, true, (iMaxSubject * 2) + 6);
	
	
	ces.addData("&nbsp;", true, (iMaxSubject * 2) + 8, 0);	
	ces.addData("&nbsp;", true, (iMaxSubject * 2) + 8, 0);
	
	ces.setBold(false);
	ces.addData("Noted by:", false, 1);
	ces.setBold(true);
	ces.addData(strNotedby, true, (iMaxSubject * 2) + 6);
	ces.setBold(false);
	ces.addData("&nbsp;", false, 1);	
	ces.addData(strNotedbyDesig, true, (iMaxSubject * 2) + 6);
			
}else{
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
	    <td height="22">&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
	<tr>
		<td style="font-size:11px;" height="22" width="10%">Prepared by:</td>
		<td style="font-size:11px;" width="90%"><%=strPreparedby%></td>
	</tr>
	<tr>
	    <td style="font-size:11px;">&nbsp;</td>
	    <td style="font-size:11px;" valign="top"><%=strPreparedbyDesig%></td>
    </tr>
	<tr>
	    <td style="font-size:11px;" height="22">&nbsp;</td>
	    <td style="font-size:11px;">&nbsp;</td>
    </tr>
	<tr>
	    <td style="font-size:11px;" height="22">&nbsp;</td>
	    <td style="font-size:11px;">&nbsp;</td>
    </tr>
	<tr>
	    <td style="font-size:11px;" height="22">Noted by:</td>
	    <td style="font-size:11px;"><%=WI.fillTextValue("checked_by")%></td>
    </tr>
	<tr>
	    <td style="font-size:11px;">&nbsp;</td>
	    <td style="font-size:11px;" valign="top"><%=strNotedbyDesig%></td>
    </tr>	
</table>

<%}
ces.writeAndClose(request);
if(!bolShowData){
	strTemp = "../../../download/EnrollmentList_"+WI.getTodaysDate()+".xls";
%>
	<a href="<%=strTemp%>"><strong style="font-size:12px">Click to download excel file</strong></a>
<%}

%>
</body>
</html>
<%
dbOP.cleanUP();
%>
