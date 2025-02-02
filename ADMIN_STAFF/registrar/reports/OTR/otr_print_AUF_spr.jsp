<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderRIGHTBOTTOM {
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderLEFTRIGHTBOTTOM {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
.fontsize9 {	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
}

-->
</style>
</head>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = null;
	
	String strCollegeName = null;//I have to find the college offering course.

	int iRowStartFr = Integer.parseInt(WI.fillTextValue("row_start_fr"));
	int iRowCount   = Integer.parseInt(WI.fillTextValue("row_count"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.fillTextValue("last_page"));
	
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.fillTextValue("max_page_to_disp"));
	
	int iPageNumber = Integer.parseInt(WI.fillTextValue("page_number"));
	String strTotalPageNumber = WI.fillTextValue("total_page");

	String strImgFileExt = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-OTR","otr_print.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Imange file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"otr_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vStudInfo = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;
Vector vCompliedRequirement = null;

Vector vMulRemark = null;
int iMulRemarkIndex = -1;

///// extra condition for the selected courses
String strStudCourseToDisp = null; String strStudMajorToDisp = null;
boolean viewAll = true;
int iMaxCourseDisplay = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_course_disp"),"0"));
String[] strTok = null; Vector vCourseSelected = new Vector(); 

String strCourseIndex = null;//this is the course selected. If no course is selected, I get from student info.. 

String strExtraCon = " and (";

for (int k = 0; k < iMaxCourseDisplay; k++){
	if (WI.fillTextValue("checkbox"+k).length() == 0 )
		continue;
	
	viewAll = false;
	strTok = (WI.fillTextValue("checkbox"+k)).split(",");
	
	if (strTok != null){
		if (strExtraCon.length() > 7) 
			strExtraCon += " or ";
	
		strExtraCon += " (stud_curriculum_hist.course_index = " + strTok[0];
		vCourseSelected.addElement(strTok[0]);
		
		if (!strTok[1].equals("null"))
			strExtraCon +=  
				" and stud_curriculum_hist.major_index = " + strTok[1];
		strExtraCon += ")";
	}	
}

strExtraCon += ")";

if (viewAll || strExtraCon.length() < 10){
	strExtraCon = null;
}
//System.out.println(strExtraCon);

///// end extra condition for the selected courses..

String[] astrConvertSem = {"SUMMER","1ST SEMESTER","2ND SEMESTER","3RD SEMESTER","4TH SEMESTER"};

enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();

///this is needed if there is a option to include or not include the Transferee information.
if(!WI.fillTextValue("tf_sel_list").equals("-1")) {
	if(WI.fillTextValue("tf_sel_list").length() == 0) 
		repRegistrar.strTFList = "0";
	else	
		repRegistrar.strTFList = WI.fillTextValue("tf_sel_list");
	
}
//////////////end...


if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		strCollegeName = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(5));
		if(strCollegeName != null)
			strCollegeName = strCollegeName.toUpperCase();
			
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
			(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
	}
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
	vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);
	
		Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,request.getParameter("stud_id"),
														(String)vStudInfo.elementAt(7),
													(String)vStudInfo.elementAt(8));
		if (vFirstEnrl != null) {
			vRetResult = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
											(String)vFirstEnrl.elementAt(2),false,false,true);
										
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = cRequirement.getErrMsg();
		else {
			vCompliedRequirement = (Vector)vRetResult.elementAt(1);
		}
	  }else strErrMsg = cRequirement.getErrMsg();
}

//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
//	System.out.println("strDegreeType : " + strDegreeType);
	if(vCourseSelected.size() > 0) {
		strTemp = "select degree_type from course_offered where course_index in ("+CommonUtil.convertVectorToCSV(vCourseSelected)+")";
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		while(rs.next()) {
			strTemp = rs.getString(1);
			if(strTemp.equals("1")) {
				strDegreeType = "1";
				break;
			}
			if(strTemp.equals("2")) {
				strDegreeType = "2";
				break;
			}
			strDegreeType = "0";
		}
		strTemp = "select course_name, major_name,course_offered.course_code, major.course_code,course_offered.course_index "+
			" from stud_curriculum_hist "+
			"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
			"left join major on (major.major_index = stud_curriculum_hist.major_index) "+
			"join semester_sequence on (semester_val = semester) "+
			"where user_index = "+(String)vStudInfo.elementAt(12)+
			" and stud_curriculum_hist.is_valid = 1 and stud_curriculum_hist.course_index in ("+
			CommonUtil.convertVectorToCSV(vCourseSelected)+") order by sy_from desc, sem_order desc";
		rs = dbOP.executeQuery(strTemp);
		if(rs.next()) {
			strStudCourseToDisp = rs.getString(1);
			strStudMajorToDisp  = rs.getString(2);
			vStudInfo.setElementAt(strStudCourseToDisp, 7);
			vStudInfo.setElementAt(strStudMajorToDisp, 8);
			vStudInfo.setElementAt(rs.getString(3), 24);
			vStudInfo.setElementAt(rs.getString(4), 25);
			
			strCourseIndex = rs.getString(5);
		}

	}
	if(strStudCourseToDisp == null) {
		strStudCourseToDisp = (String)vStudInfo.elementAt(7);
		strStudMajorToDisp  = (String)vStudInfo.elementAt(8);
		strCourseIndex      = (String)vStudInfo.elementAt(5);
	}
	//I have to set the course index so that the graduation data can get the info for that course.. 
	enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
	vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);	
	request.setAttribute("course_ref", strCourseIndex);
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	if(vEntranceData == null || vGraduationData == null)
		strErrMsg = entranceGradData.getErrMsg();
		
		
	//System.out.println(strExtraCon);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true, strExtraCon);
	
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);

	if (strDegreeType != null && strDegreeType.equals("1")) {
		astrConvertSem[0] = "SUMMER";
		astrConvertSem[1] = "1ST TRIMESTER";
		astrConvertSem[2] = "2ND TRIMESTER";
		astrConvertSem[3] = "3RD TRIMESTER";
		astrConvertSem[4] = "";
	}//System.out.println(vRetResult);
}
/**
if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);
}**/

String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);

boolean bolIsRLEHrs = false;
boolean bolShowLecLabHr = false; String[] astrLecLabHr = null;//gets lec/lab hour information.
String strRLEHrs    = null;
String strCE        = null;


if(vRetResult.toString().indexOf("hrs") > 0 && WI.fillTextValue("show_rle").compareTo("1") == 0)
	bolIsRLEHrs = true;

if(WI.fillTextValue("show_leclab").compareTo("1") == 0)	
	bolShowLecLabHr = true;
	
//System.out.println(vStudInfo);
//System.out.println(vMulRemark);
%>

<body topmargin="5">
<%
if(iPageNumber != 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="3%">&nbsp;</td>
    <td width="78%" height="18" valign="top">Name &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;<strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
    <td width="19%">&nbsp;</td>
  </tr>
</table>
<%}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="164" valign="top">&nbsp;</td>
    <td width="587"> <div align="center"><strong><font size="4"> <%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
        <font size="2">
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>, <%=SchoolInformation.getAddressLine2(dbOP,false,false)%> </font><br>
        <br>
        <font size="2"><strong> Office of the University Registrar<br>
        <br>
        </strong></font><br>
        <strong><font size="3">Student Permanent Record</font></strong></div></td>
    <td width="177" valign="bottom"> <table cellpadding="0" cellspacing="0">
        <tr> 
          <td valign="top">
		  <img src="../../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt%>" height="130" width="130" border="1"></td>
        </tr>
      </table></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="16%" height="18"><strong>Student Number</strong></td>
    <td colspan="4"><%=WI.fillTextValue("stud_id").toUpperCase()%></td>
  </tr>
  <tr> 
    <td height="18"><strong>NAME</strong></td>
    <td colspan="2"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></td>
	<% if (WI.getStrValue((String)vStudInfo.elementAt(16),"M").compareTo("M") == 0) 
		strTemp = "MALE";
	else
		strTemp = "FEMALE";
%>
    <td colspan="2"><strong>Sex&nbsp;:</strong> <%=strTemp%></td>

  </tr>
  <tr> 
    <td height="18"><strong>Course</strong></td>
    <td width="34%"><%=(String)vStudInfo.elementAt(7)%></td>
    <td colspan="3"><strong>Major &nbsp;&nbsp;: <%=WI.getStrValue((String)vStudInfo.elementAt(8))%></strong></td>
  </tr>
  <tr> 
    <td height="18"><strong>Address</strong></td>
    <td colspan="2"><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","")%></td>
    <td width="12%"><strong>Nationality: </strong></td>
    <td width="23%"><%=WI.getStrValue((String)vStudInfo.elementAt(23))%></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td width="16%" height="18"><strong>Date of Birth</strong></td>
    <td width="49%"><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></td>
    <td width="35%" colspan="3"><strong>Place of Birth : </strong><%=WI.getStrValue(vAdditionalInfo.elementAt(2))%></td>
  </tr>
  <tr> 
    <td height="18"><strong>Father's Name:</strong></td>
    <td><%=WI.getStrValue((String)vAdditionalInfo.elementAt(8))%></td>
    <td colspan="3"><strong>Occupation : </strong><%=WI.getStrValue((String)vStudInfo.elementAt(21))%></td>
  </tr>
  <tr> 
    <td height="18"><strong>Mother's Name:</strong></td>
    <td><%=WI.getStrValue((String)vAdditionalInfo.elementAt(9))%></td>
    <td colspan="3"><strong>Occupation : </strong><%=WI.getStrValue((String)vStudInfo.elementAt(22))%></td>
  </tr>
  <tr> 
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr> 
    <td height="18" colspan="5"><strong>PRELIMINARY EDUCATION</strong></td>
  </tr>
  <tr> 
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="3">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="13%" height="15"><div align="left"><strong>Elementary :</strong></div></td>
    <td width="59%">&nbsp; <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
else	
	strTemp = "&nbsp;";
%> <%=strTemp%></td>
    <td width="18%">&nbsp; <%
if(vEntranceData != null) {
	strErrMsg = (String)vEntranceData.elementAt(19);
	if(vEntranceData.elementAt(20) != null) {
		if(strErrMsg == null)
			strTemp = Integer.toString(Integer.parseInt((String)vEntranceData.elementAt(20)) - 1) +
				" to " +(String)vEntranceData.elementAt(20);
		else	
			strTemp = strErrMsg + " to " +(String)vEntranceData.elementAt(20);
	}
	else	
		strTemp = "&nbsp;";
}
else	
	strTemp = "&nbsp;";
%> <%=strTemp%></td>
    <td width="10%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="15"><div align="left"><strong>High School : </strong></div></td>
    <td>&nbsp; <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");
else	
	strTemp = "&nbsp;";
%> <%=strTemp%> </td>
    <td>&nbsp; <%
if(vEntranceData != null) {
	strErrMsg = (String)vEntranceData.elementAt(21);
	if(vEntranceData.elementAt(22) != null) {
		if(strErrMsg == null)
			strTemp = Integer.toString(Integer.parseInt((String)vEntranceData.elementAt(22)) - 1) +
				" to " +(String)vEntranceData.elementAt(22);
		else	
			strTemp = strErrMsg + " to " +(String)vEntranceData.elementAt(22);
	}
	else	
		strTemp = "&nbsp;";
}
else	
	strTemp = "&nbsp;";
%> <%=strTemp%></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="19" colspan="2"><div align="left"><strong>Sch. Last Attended : </strong>
<% if (vEntranceData != null && vEntranceData.size()>0) {
	strTemp = (String)vEntranceData.elementAt(7);
	if (strTemp == null) 
		strTemp = (String)vEntranceData.elementAt(5);
		
}%>	<%=WI.getStrValue(strTemp)%>
        </div></td>
    <td>&nbsp;
      <%
if(vEntranceData != null) {
	if(vEntranceData.elementAt(24) != null) {
		strTemp = Integer.toString(Integer.parseInt((String)vEntranceData.elementAt(24)) - 1) +
				" to " +(String)vEntranceData.elementAt(24);
	}
	else	
		strTemp = "&nbsp;";
}
else	
	strTemp = "&nbsp;";
%>
    <%=strTemp%></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 

    <td height="19" colspan="2"><strong>Credentials Submitted :</strong><% strTemp ="";
 if (vCompliedRequirement != null && vCompliedRequirement.size() > 0) {
	for (int i = 0; i < vCompliedRequirement.size(); i+= 3) {
		if (i == 0) strTemp = (String)vCompliedRequirement.elementAt(i+1);
		else strTemp +="," + (String)vCompliedRequirement.elementAt(i+1);
		}
	}
%> <%=strTemp%>    </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="19" colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<%}//if iPage number = 1
if(WI.fillTextValue("row_start_fr").compareTo("0") != 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="10" class="thinborderBOTTOM">&nbsp;</td>
</table>

<%}
if(vRetResult != null && vRetResult.size() > 0){
	int iNumWeeks = 0;
	if (WI.fillTextValue("weeks").length() > 0) iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#FFFFFF"> 
    <td width="7%" height="20" class="thinborder"><div align="center"><strong>School 
        Term</strong></div></td>
    <td width="18%" class="thinborder"><div align="center"><strong>Course 
        Number</strong></div></td>
    <td width="43%" class="thinborder"><div align="center"> <strong>DESCRIPTIVE 
        TITLE </strong></div></td>
    <%if(bolShowLecLabHr){%>
    <td width="7%" class="thinborderBOTTOM"><div align="center"><strong>LEC<br>
        (HRS) </strong></div></td>
    <td width="7%" class="thinborderBOTTOM"><div align="center"><strong>LAB (HRS)</strong></div></td>
    <%}%>
    <%if(bolIsRLEHrs){%>
    <td width="7%" class="thinborderBOTTOM"><div align="center"><strong> RLE (HRS)</strong></div></td>
    <%}%>
    <td width="7%" class="thinborder"><div align="center"> <strong>FINALs 
        Grades</strong></div></td>
    <td width="8%" class="thinborder"><div align="center"><strong>Re-Exam 
        Unit</strong></div></td>
    <td width="10%" class="thinborder"><div align="center"><strong>Credit 
        Unit</strong></div></td>
  </tr>
  <%
int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = null;
String strSchNameToDisp = null;

String strSYSemToDisp   = null;
String strCurSYSem      = null;
String strPrevSYSem     = null;

boolean bolIsSchNameNull    = false;
boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has 
//school name after it is null, it is encoded as cross enrollee.

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);

String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;
for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
//I have to now check if this subject is having RLE hours. 
//String strRLEHrs    = null;
//String strCE        = null;

	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6 + 11) != null && vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) {   //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
	}
	else {
		strTemp = (String)vRetResult.elementAt(i + 9);
	}
	strCE        = strTemp;
	
	if(strTemp != null && strTemp.indexOf("hrs") > 0 && strTemp.indexOf("(") > 0) {
		strRLEHrs = CommonUtil.formatGrade(strTemp.substring(strTemp.indexOf("(") + 1, strTemp.indexOf("hrs")),0f);
		strCE     = strTemp.substring(0,strTemp.indexOf("("));
	}
	else {
		strRLEHrs    = null;
	}
	
	strSchoolName = (String)vRetResult.elementAt(i);
	if(vRetResult.elementAt(i) == null)
		bolIsSchNameNull = true;
	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) //cross enrolled.
		strSchoolName += " (CROSS ENROLLED)";		
/** uncomment this if school name apprears once.
	if(strSchoolName != null) {
		if(strPrevSchName == null) {
			strPrevSchName = strSchoolName ;
			strSchNameToDisp = strSchoolName;
		}
		else if(strPrevSchName.compareTo(strSchoolName) ==0) {
			strSchNameToDisp = null;
		}
		else {//itis having a new school name.
			strPrevSchName = strSchoolName;
			strSchNameToDisp = strPrevSchName;
		}
	}
**/	if(i == 0 && strSchoolName == null) {//I have to get the current school name
		strSchNameToDisp = SchoolInformation.getSchoolName(dbOP,false,false);
	}
	if(strSchoolName == null)// && vRetResult.elementAt(i + 10) != null)//subject group name is not null for reg.sub
		strSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);
		
	if(strSchoolName != null)
		strSchNameToDisp = strSchoolName;	
		
 	//if prev school name is not not null, show the current shcool name.
	if(strSchoolName == null && strPrevSchName != null) {
		strSchNameToDisp = strCurrentSchoolName;
		strPrevSchName = null;
	}

//strCurSYSem =
if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+" "+
					(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
	}
	else {
		strCurSYSem = (String)vRetResult.elementAt(i+ 3)+" "+(String)vRetResult.elementAt(i+ 1)+" - "+
							(String)vRetResult.elementAt(i+ 2);
	}
	if(strCurSYSem != null) {
		if(strPrevSYSem == null) {
			strPrevSYSem = strCurSYSem ;
			strSYSemToDisp = strCurSYSem;
		}
		else if(strPrevSYSem.compareTo(strCurSYSem) ==0) {
			strSYSemToDisp = null;
		}
		else {//itis having a new school name.
			strPrevSYSem = strCurSYSem;
			strSYSemToDisp = strPrevSYSem;
		}
	}
}

	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//cross enrolled.
		if(strCrossEnrolleeSchPrev == null || strCrossEnrolleeSchPrev.compareTo(strSchoolName) != 0)  {
			strCrossEnrolleeSchPrev = strSchoolName;
			strCrossEnrolleeSch     = strSchoolName;
			strSYSemToDisp = strCurSYSem;
		}
	}


 //Very important here, it print <!-- if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){strHideRowLHS = "<!--";//I have to do this so i will know if I am priting data or not%>
  <%=strHideRowLHS%> 
  <%}else {++iRowsPrinted;strHideRowLHS = "";}//actual number of rows printed.

if(false && strSchNameToDisp != null){//do not keep extra line for school name.%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="9" class="thinborderLEFTRIGHT" align="center"><strong><u><%=strSchNameToDisp.toUpperCase()%></u></strong></td>
  </tr>
  <%strSchNameToDisp = null;}

if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
	vMulRemark.removeElementAt(0);%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="9" class="thinborderALL" align="center"> <%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></td>
  </tr>
  <%}//end of if
}//end of vMulRemark.

if(strSYSemToDisp != null){%>
  <tr bgcolor="#FFFFFF"> 
    <td height="17" colspan="9" class="thinborderLEFTRIGHT">&nbsp;&nbsp;<strong> 
      <u><%=strSYSemToDisp%><%=WI.getStrValue(strSchNameToDisp," - ","","")%></u></strong></td>
  </tr>
  <%}
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="17" class="thinborderLEFT">&nbsp;</td>
    <td><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td ><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></td>
    <%if(bolShowLecLabHr){
	if(strHideRowLHS.length() == 0) 
		astrLecLabHr = repRegistrar.getOTROfCanLecLabHr(dbOP, false, (String)vRetResult.elementAt(i + 6),(String)vRetResult.elementAt(i + 7),null);%>
    <td width="7%" align="center">&nbsp;
      <%if(astrLecLabHr != null && iNumWeeks > 0){
	  if (Integer.parseInt(WI.getStrValue(astrLecLabHr[0],"0")) < 30){%>
      <%=Integer.parseInt(WI.getStrValue(astrLecLabHr[0],"0"))*iNumWeeks%>
	  <%}else{%>
      <%=WI.getStrValue(astrLecLabHr[0],"0")%>
      <%}}%></td>
    <td width="7%" align="center"> <%if(astrLecLabHr != null && iNumWeeks > 0){
	  if (Integer.parseInt(WI.getStrValue(astrLecLabHr[1],"0")) < 30){%>
      <%=Integer.parseInt(WI.getStrValue(astrLecLabHr[1],"0"))*iNumWeeks%>
	   <%}else{%>
      <%=WI.getStrValue(astrLecLabHr[1],"0")%>
      <%}}%></td>
    <%}%>
    <%if(bolIsRLEHrs){%>
    <td width="7%"><div align="center"><%=WI.getStrValue(strRLEHrs)%></div></td>
    <%}%>
    <%
if(WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;").compareTo("on going") == 0){%>
    <td colspan="3" class="thinborderRIGHT">&nbsp;&nbsp;Grade not yet available</td>
    <%}else{%>
    <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
    <td align="center"> <%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
			
			%> <%=(String)vRetResult.elementAt(i + 8 + 11)%> <%i += 11;}%> </td>
    <td class="thinborderRIGHT" align="center">&nbsp;<%=strCE%> 
	</td>
    <%}//show only if grade is not on going.%>
  </tr>
  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop
   %>
</table>
<%}//only if student is having grade infromation.%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(WI.fillTextValue("last_page").compareTo("1") != 0){%>
  <tr>
    <td height="20" colspan="2" class="thinborderTOP">
	<font size="2">REMARKS : </font><font size="1">
	continued on sheet no. <%=iPageNumber+1%></font></td>
  </tr>
<%}else{
 if(vEntranceData != null &&  (String)vEntranceData.elementAt(12) != null){//if last page, i have to show the remark.
 iMaxRowToDisp = iMaxRowToDisp - 2;%>  
  <tr>
    <td height="20" colspan="2" class="thinborderALL" align="center">&nbsp; <%=(String)vEntranceData.elementAt(12)%></td>
  </tr>
<%}%>
  <tr>
    <td height="20" colspan="2" class="thinborderALL" align="center">***NOTHING 
      FOLLOWS***</td>
  </tr>
<tr>
    <td height="10" colspan="2">&nbsp;</td>
  </tr>
<%}//end of last page.%>

<%if(WI.fillTextValue("addl_remark").length() > 0 && WI.fillTextValue("last_page").compareTo("1") == 0){
//I have to now remove the lines takes by remarks
int iTemp = 1;
 strTemp = WI.fillTextValue("addl_remark");
int iIndexOf = 0;

while(  (iIndexOf = strTemp.indexOf("<br>",iIndexOf + 1)) != -1)
	++iTemp;
//System.out.println("Printing :"+iTemp);
 iMaxRowToDisp = iMaxRowToDisp - iTemp;//I have to remove number of lines from  iMaxDisplay.
%>
<tr>
    <td height="20" colspan="2"><font size="2"><%=WI.fillTextValue("addl_remark")%></font></td>
  </tr>

<%}//I have to now run a loop to fill up the empty rows.
//System.out.println(iRowsPrinted);
//System.out.println(iMaxRowToDisp);
for(int abc = 0; abc < iMaxRowToDisp - iRowsPrinted; ++abc){
%>
<tr>
    <td height="20" colspan="2">&nbsp;</td>
  </tr>
<%}%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="20" colspan="4"><strong>Grading System</strong></td>
    <td width="20%">&nbsp;</td>
    <td width="46%">&nbsp;</td>
  </tr>
  <tr> 
    <td width="5%" height="15"><font size="1">1.0</font></td>
    <td width="10%"><font size="1">97 - 100</font></td>
    <td width="5%"><font size="1">2.75</font></td>
    <td width="14%"><font size="1">77 - 78</font></td>
    <td width="20%">&nbsp;</td>
    <td width="46%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="15"><font size="1">1.25</font></td>
    <td><font size="1">94 - 96</font></td>
    <td><font size="1">3.0</font></td>
    <td><font size="1">75 - 76 </font></td>
    <td width="20%">&nbsp;</td>
    <td width="46%">Certified Correct: </td>
  </tr>
  <tr> 
    <td height="15"><font size="1">1.5</font></td>
    <td><font size="1">91 - 93</font></td>
    <td><font size="1">5.0</font></td>
    <td><font size="1">Below 75 (Failure)</font></td>
    <td width="20%">&nbsp;</td>
    <td width="46%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="15"><font size="1">1.75</font></td>
    <td><font size="1">88 - 90</font></td>
    <td><font size="1">INC</font></td>
    <td><font size="1">INCOMPLETE</font></td>
    <td width="20%">&nbsp;</td>
    <td width="46%"><div align="center"></div></td>
  </tr>
  <tr> 
    <td height="15"><font size="1">2.0</font></td>
    <td><font size="1">85 - 87</font></td>
    <td><font size="1">Dr</font></td>
    <td><font size="1">DROPPED</font></td>
    <td width="20%">&nbsp;</td>
    <td width="46%"><div align="center"><strong><%=WI.fillTextValue("registrar_name").toUpperCase()%></strong></div></td>
  </tr>
  <tr> 
    <td height="10"><font size="1">2.25</font></td>
    <td><font size="1">82 - 84</font></td>
    <td><font size="1">FA</font></td>
    <td><font size="1">Failure due to Absences</font></td>
    <td>&nbsp;</td>
    <td valign="top"><div align="center">University Registrar</div></td>
  </tr>
  <tr> 
    <td height="10"><font size="1">2.50</font></td>
    <td><font size="1">79 - 81</font></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr> 
    <td height="10" colspan="3"><font size="1">For Graduate School : </font></td>
    <td height="10" colspan="2"><font size="1">Below 90 no credit for Ph.D.</font></td>
    <td height="10">Date Issued : &nbsp;&nbsp;&nbsp;<%=WI.getTodaysDate(6)%></td>
  </tr>
  <tr> 
    <td height="10" colspan="3"><font size="1">&nbsp;</font></td>
    <td height="10" colspan="2"><font size="1">Below 85 no credit for M.A</font></td>
    <td height="10">&nbsp;</td>
  </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="10" valign="bottom">&nbsp;</td>
  </tr>
  <tr> 
    <td height="10" valign="bottom"><strong><font size="1">Not Valid Without University 
      Seal</font></strong></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="15%" height="20"><div align="left">Sheet No. <%=iPageNumber%> of <%=strTotalPageNumber%></div></td>
  </tr>
  <tr>
    <td height="18"><br>
	<font face="Arial, Helvetica, sans-serif" style="font-size:9px;">
	AUF-Form-RO-04<br>
	August 1, 2007-Rev.0
	</font><!--<img src="./image/auf_ro_04.jpg">-->
	</td>
  </tr>
</table>
<%//System.out.println(WI.fillTextValue("print_"));
if(WI.fillTextValue("print_").compareTo("1") == 0){%>
<script language="javascript">
 window.print();
</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
