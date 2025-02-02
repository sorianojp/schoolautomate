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
	font-size: 10px;	
    }
	
	TABLE.enclosed {
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
	border-right: solid 1px #000000;
	border-left: solid 1px #000000;
	font-size: 10px;	
	}
	
	TD.thickSE {
		border-bottom: solid 1px #000000;
		border-right: solid 1px #000000;
		font-size: 10px;	
	}
	TD.thickTOPBOTTOM {
		border-bottom: solid 2px #000000;
		border-top: solid 2px #000000;
		font-size: 10px;	
	}
	TD.thickBOTTOM {
		border-bottom: solid 2px #000000;
		font-size: 10px;	
	}
	TD.thickTOP {
		border-top: solid 2px #000000;
		font-size: 10px;	
	}
	
	TD.thickE {
		border-right: solid 1px #000000;
		font-size: 10px;	
	}
	

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderLeftRight {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;	
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	TD.thinborderLeftRightBottom {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;	
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }


    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    
	TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
	TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

	TD.thinborderTopBottom {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
	TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }



-->
</style>
</head>
<script language="javascript">
function HideImg() {
	document.getElementById('hide_img').innerHTML = "";
}
function UpdateLabel(strLevelID) {
	var newVal = prompt('Please enter new Value');
	if(newVal == null)
		return;
	document.getElementById(strLevelID).innerHTML = newVal;
}
function ChangeUnivCollege() {
	var obj = document.getElementById('univ_');
	var labelVal = obj.innerHTML;
	
	if(labelVal.indexOf('UNIVERSITY') > -1)
		obj.innerHTML = '<font size="6">WEST NEGROS <br>COLLEGE </font>';
	else	
		obj.innerHTML = '<font size="6">WEST NEGROS <br>UNIVERSITY </font><br><br> <strong>(Formerly West Negros College)</strong>';
}
function Update(strLabelID) {
	strNewVal = prompt('Please enter new Value','');
	if(strNewVal == null)
		return;
	document.getElementById(strLabelID).innerHTML = strNewVal;
}
function updateSubjectRow(strLabelID) {
	strNewVal = prompt('Please enter next line Value','');
	if(strNewVal == null)
		return;
	document.getElementById(strLabelID).innerHTML = document.getElementById(strLabelID).innerHTML+"<br>"+strNewVal;

}
</script>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = null;

	int iRowStartFr = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_start_fr"), "0"));
	int iRowCount   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_count"), "0"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"), "0"));

	String strPrintPage = WI.fillTextValue("print_");//"1" is print. 

////////////////////////// to insert blank lines if TOR is not complete page.
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_page_to_disp"), "0"));
//////////////////////////

	int iPageNumber = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_number"), "0"));
	
	String strTotalPageNumber = WI.fillTextValue("total_page");

	String strImgFileExt = null;
	String strRootPath  = null;

	//copied from AUF for print all page setting.. 
		String strPrintValueCSV = "";
	
	if(WI.fillTextValue("print_all_pages").equals("1")) { //print all page called.
		strPrintValueCSV = WI.fillTextValue("print_value_csv");
		if(strPrintValueCSV.length() == 0) {
			strErrMsg = "End of printing. This error must not occur.";%>
			<%=strErrMsg%>
		<%	return;
		} 
		Vector vPrintVal = CommonUtil.convertCSVToVector(strPrintValueCSV);//[0] row_start_fr, [1] row_count, [2] last_page, [3] page_number, [4] max_page_to_disp, 
		iRowStartFr   = Integer.parseInt((String)vPrintVal.remove(0));
	    iRowCount     = Integer.parseInt((String)vPrintVal.remove(0));
		iRowEndsAt    = iRowStartFr + iRowCount;
		iLastPage     = Integer.parseInt((String)vPrintVal.remove(0));
		strPrintPage  = "1";//"1" is print. 
		
		iPageNumber   = Integer.parseInt((String)vPrintVal.remove(0));
		iMaxRowToDisp = Integer.parseInt((String)vPrintVal.remove(0));
		
		if(vPrintVal.size() == 0)
			strPrintValueCSV = "";
		else	
			strPrintValueCSV = CommonUtil.convertVectorToCSV(vPrintVal);
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-OTR","otr_print.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		
		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
			strErrMsg = "Installation directory path is not set.  " +
						 " Please check the property file for installDir KEY.";
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

int iLevelID = 0;//freedom to change everything.. 

//end of authenticaion code.
Vector vStudInfo = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;

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

String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester"};


enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();

if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
			(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
	}
}
if(vStudInfo != null && vStudInfo.size() > 0) {
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
			strStudCourseToDisp = rs.getString(3);
			strStudMajorToDisp  = rs.getString(4);
			vStudInfo.setElementAt(strStudCourseToDisp, 7);
			vStudInfo.setElementAt(strStudMajorToDisp, 8);
			vStudInfo.setElementAt(rs.getString(3), 24);
			vStudInfo.setElementAt(rs.getString(4), 25);
			
			strCourseIndex = rs.getString(5);
		}

	}
	if(strStudCourseToDisp == null) {
		strStudCourseToDisp = (String)vStudInfo.elementAt(24);
		strStudMajorToDisp  = (String)vStudInfo.elementAt(25);
		strCourseIndex      = (String)vStudInfo.elementAt(5);
	}
	//I have to set the course index so that the graduation data can get the info for that course.. 





	enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
	vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);
	request.setAttribute("course_ref", strCourseIndex);
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	if(vEntranceData == null || vGraduationData == null)
		strErrMsg = entranceGradData.getErrMsg();
}
//System.out.println(vEntranceData);
//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
	
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), 
													strDegreeType, true, strExtraCon);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);
		
}


String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);


//System.out.println(vMulRemark);
int iMulRemarkCount  = 0;// 

/////i have to put parenthesis for math and english enrichment.
Vector vEnrichmentSubjects = null;
boolean bolPutParanthesis = false;

String strSubCode = null;//this is added for CGH to
if(vRetResult != null) {
	vEnrichmentSubjects = new enrollment.GradeSystem().getEnrichmentSubject(dbOP);
}
//System.out.println(vEnrichmentSubjects);
%>

<body topmargin="5" <%if(WI.fillTextValue("print_").equals("1")){%> onLoad="window.print()"<%}%>>
<form action="./otr_print_WNU.jsp" method="post" name="form_">
<%if(iPageNumber > 1) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td colspan="2" align="right">Page <%=iPageNumber%></td>
  </tr>
<tr> 
    <td> <div align="center">
      <img src="../../../../images/blank.gif" width="145" height="180" align="left">
        <label id="univ_" onClick="ChangeUnivCollege();">
			<font size="6">WEST NEGROS <br>UNIVERSITY </font><br><br>
        	<strong>(Formerly West Negros College)</strong>		</label>
		<br>Bacolod City, Philippines 6100
		<br>
        <br>
        <font style="font-size:14px; font-weight:bold">OFFICE OF THE REGISTRAR</font><br><br><br>
          <font style="font-size:14px; font-weight:bold">OFFICIAL TRANSCRIPT OF RECORD<br><br>&nbsp;</font>
      </div></td>
    <td width="171" valign="bottom">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="14%" height="17">Name</td>
    <td width="86%" style="font-weight:bold"><%=((String)vStudInfo.elementAt(0)).toUpperCase()%>&nbsp; <%=WI.getStrValue((String)vStudInfo.elementAt(1)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(2)," ").toUpperCase()%></td>
  </tr>
  <tr>
    <td height="17" colspan="2" class="thickTOP">&nbsp;</td>
  </tr>
</table>
<%}
else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
    <td colspan="2"> <div align="center">
      <img src="../../../../images/blank.gif" width="145" height="180" align="left">
        <label id="univ_" onClick="ChangeUnivCollege();">
			<font size="6">WEST NEGROS <br>UNIVERSITY </font><br><br>
        	<strong>(Formerly West Negros College)</strong>
		</label>
		<br>Bacolod City, Philippines 6100
		<br>
        <br>
        <font style="font-size:14px; font-weight:bold">OFFICE OF THE REGISTRAR</font><br><br><br>
          <font style="font-size:14px; font-weight:bold">OFFICIAL TRANSCRIPT OF RECORD<br><br>&nbsp;</font>
      </div></td>
    <td width="171" valign="top">
	<%
		strTemp = WI.fillTextValue("stud_id").toUpperCase();
		//System.out.println("strTemp : " + strTemp);
		//System.out.println(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);
		if (strTemp.length() > 0) {
			java.io.File file = new java.io.File(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);

			if(file.exists()) {
				strTemp = "../../../../upload_img/"+strTemp+"."+strImgFileExt;
				strTemp = "<label id='hide_img' onClick='HideImg()'><img src=\""+strTemp+"\" width=145 height=145></label>";
			}
			else {
				strTemp = "<img src='../../../../images/blank.gif' width='145' height='145'>";
			}
		}
%>

	 <%=strTemp%></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
  <tr>
    <td>Name</td>
    <td style="font-weight:bold"><%=((String)vStudInfo.elementAt(0)).toUpperCase()%>&nbsp; <%=WI.getStrValue((String)vStudInfo.elementAt(1)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(2)," ").toUpperCase()%></td>
    <td>Date of Issue</td>
    <td><%=WI.formatDate(WI.fillTextValue("date_prepared"),6)%></td>
  </tr>
  
  <tr>
    <td width="15%">Birth Date</td>

    <td width="37%"><%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
		strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1));
	}else{
		strTemp = "&nbsp;";
	}
%>
    <%=strTemp%></td>
    <td width="19%">I.D Number</td>
    <td width="29%"><%=WI.fillTextValue("stud_id").toUpperCase()%></td>
  </tr>
  <tr>
    <td>Birth Place </td>
    <td><%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
		strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2));
	}else{
		strTemp = "&nbsp;";
	}
%>
      <%=strTemp%></td>
    <td>Sex</td>
    <td>
<%
strTemp = (String)vStudInfo.elementAt(16);
if(strTemp.equals("M"))
	strTemp = "Male";
else
	strTemp = "Female";
%>
	<%=strTemp%></td>
  </tr>
  <tr>
    <td>Nationality</td>
    <td><%=WI.getStrValue((String)vStudInfo.elementAt(23), "&nbsp;")%></td>
    <td>Parent/Guardian</td>
    <td><%=WI.getStrValue((String)vAdditionalInfo.elementAt(8),"&nbsp;")%></td>
  </tr>
  <tr>
    <td>Permanent Address </td>
    <td><%=WI.fillTextValue("address")%></td>
    <td>Admission Credentials </td>
    <td><%strTemp = WI.fillTextValue("entrance_data");%> <%=strTemp%></td>
  </tr>
  <tr>
    <td>Education</td>
    <td>&nbsp;</td>
    <td>College</td>
    <td>
<%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
		strTemp = dbOP.mapOneToOther("course_offered join college on " +
									 "(course_offered.c_index = college.c_Index)",
									 "course_name", "'" + (String)vStudInfo.elementAt(7) +"'",
									 "c_name", " and course_offered.is_del = 0" +
									 " and college.is_del= 0");
		if (strTemp == null) {
			strTemp ="&nbsp;";
		}else{
			strTemp =  strTemp.substring(strTemp.indexOf("of") + 3);
		}
	}else{
		strTemp = "&nbsp;";
	}
%><%=strTemp%>	</td>
  </tr>
  <tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Elementary</td>
    <td>
<%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(14),WI.getStrValue(vEntranceData.elementAt(3)));
else
	strTemp = "&nbsp;";
%><%=strTemp%>	</td>
    <td>Degree/Course</td>
    <td><%=strStudCourseToDisp%></td>
  </tr>
  <tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Year Graduated </td>
    <td>
<%
if(vEntranceData != null && vEntranceData.elementAt(20) != null)
	strTemp = (String)vEntranceData.elementAt(19)+"-"+(String)vEntranceData.elementAt(20);
else
	strTemp = "&nbsp;";
%><%=strTemp%>	</td>
    <td>Major</td>
    <td><%=WI.getStrValue(strStudMajorToDisp)%></td>
  </tr>
  <tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Secondary</td>
    <td>
        <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");
else
	strTemp = "&nbsp;";
%><%=strTemp%>	</td>
    <td>Minor</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Year Graduated</td>
    <td>
<%
if(vEntranceData != null && vEntranceData.elementAt(22) != null)
	strTemp = (String)vEntranceData.elementAt(21)+"-"+(String)vEntranceData.elementAt(22);
else
	strTemp = "&nbsp;";
%><%=strTemp%>	
</td>
    <td>Date of Graduation </td>
    <td><%
	if(vGraduationData != null) {
		strTemp = (String)vGraduationData.elementAt(8);
		if(strTemp != null)
			strTemp = WI.formatDate(strTemp,6);
		else	
			strTemp = "&nbsp;";
	}
	else
		strTemp = "&nbsp;";
%>
      <%=WI.getStrValue(strTemp, "&nbsp;")%></td>
  </tr>
  <tr>
    <td height="17" colspan="4" class="thinborderBottom">&nbsp;</td>
  </tr>
  <tr>
    <td height="10" colspan="4" style="font-size:1px;">.</td>
  </tr>
</table>
<%}//show only if it is not first page.. 

if(vRetResult != null && vRetResult.size() > 0){%>
<%
if(iPageNumber == 1) {
	if(WI.fillTextValue("print_").equals("1")) 
		strTemp = "tor_bg_blank.jpg";
	else	
		strTemp = "tor_bg.jpg";
}
else {
	if(WI.fillTextValue("print_").equals("1")) 
		strTemp = "tor_bg_2_blank.jpg";
	else	
		strTemp = "tor_bg_2.jpg";
}

//if(!WI.fillTextValue("print_").equals("1")){//show the print layout..%>
	<table width="100%">
	<tr>
	<td valign="top"><img src="./<%=strTemp%>"></td>
	<td valign="top">
<%//}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#FFFFFF" onClick="PrintNextPage();"> 
    <td width="0%" height="25" class="thickTOPBOTTOM" align="center"><!-- this is not used.. but i can't remove this yet.. --></td>
    <td width="20%" class="thickTOPBOTTOM" align="center"><font size="1"><strong>Course Number</strong> </font></td>
    <td width="55%" class="thickTOPBOTTOM" align="center"><font size="1"><strong>Descriptive Title</strong></font></td>
    <td width="8%" class="thickTOPBOTTOM" align="center"><strong><font size="1">Grade</font></strong></td>
    <td width="15%" class="thickTOPBOTTOM" align="center"><strong><font size="1">Re-Exam/<br>Completion Grade</font></strong></div></td>
    <td width="7%" class="thickTOPBOTTOM"><div align="center"><strong><font size="1">Credit</font></strong></div></td>
  </tr>
<%
int iIndexOf   = 0;
String strCol1 = null;
String strCol2 = null;


int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = null;
String strSchNameToDisp = null;

String strSYSemToDisp   = null;
String strCurSYSem      = null;
String strPrevSYSem     = null;
String strNextSem       = null;

boolean bolNextNew = true;
boolean bolNewEntry = true;
boolean bolNewPrev =  true;

boolean bolNewPage = false;
String strSYTermInfoPrevPage = null;

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);
int iRevalidaIndex = -1;
String strCE ="";
boolean bolRowSpan2  = false; boolean bolInComment = false;
String strExtraTD = null;

for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
//	strExtraTD = null;
  if( (i + 12) < vRetResult.size())//revalida.. 
	if ((String)vRetResult.elementAt(i + 6) != null && 
		((String)vRetResult.elementAt(i + 6)).toUpperCase().indexOf("REVALIDA") != -1) {
		iRevalidaIndex = i;
		continue;
	}
	
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && 
	(	((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 || ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("lfr") != -1 ) &&
	vRetResult.elementAt(i + 6 + 11) != null && vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) {   //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
	}
	else {
		strTemp = (String)vRetResult.elementAt(i + 9);
	}
	strCE = strTemp;

	if(strTemp != null && strTemp.indexOf("hrs") > 0) {
		strCE     = strTemp.substring(0,strTemp.indexOf("("));
	}
	
	strSchoolName = (String)vRetResult.elementAt(i);
	if(strSchoolName != null) {
		if(strPrevSchName == null) {
			strPrevSchName = strSchoolName ;
			strSchNameToDisp = strSchoolName;
		}
		else if(strPrevSchName.equals(strSchoolName)) { // need not to print
			strSchNameToDisp = null;
		}
		else {//itis having a new school name.
			strPrevSchName = strSchoolName;
			strSchNameToDisp = strPrevSchName;
		}
	}
 	//if prev school name is not null, show the current shcool name.
	if(strSchoolName == null && strPrevSchName != null) {
		strSchNameToDisp = strCurrentSchoolName;
		strPrevSchName = null;
	}
	
	// force data in case of first entry
	if (strSchNameToDisp == null && i==0){
		strSchNameToDisp = strCurrentSchoolName;
//		strPrevSchName = strCurrentSchoolName;
	}
		

//strCurSYSem =
if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+", "+(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
					
		if (i+11 < vRetResult.size())	{
			if(((String)vRetResult.elementAt(i+ 14)).length() == 1)
		 		strNextSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 14))]+", "+(String)vRetResult.elementAt(i+ 12)+" - "+(String)vRetResult.elementAt(i+ 13);
			else	
				strNextSem = (String)vRetResult.elementAt(i+ 14)+", "+(String)vRetResult.elementAt(i+ 12)+" - "+(String)vRetResult.elementAt(i+ 13);
		}
		else
			strNextSem = null;
	}
	else {
		strCurSYSem = (String)vRetResult.elementAt(i+ 3)+", "+(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
							
		if (i+11 < vRetResult.size())	
		{
		 strNextSem = (String)vRetResult.elementAt(i+ 14)+", "+(String)vRetResult.elementAt(i+ 12)+" - "+(String)vRetResult.elementAt(i+ 13);
		}
		else
			strNextSem = null;
	}
	if(strCurSYSem != null) {
		if(strPrevSYSem == null) {
			strPrevSYSem = strCurSYSem ;
			strSYSemToDisp = strCurSYSem;
		bolNewEntry = true;
		bolNewPrev = true;
		if (strNextSem != null)
			{
				if (strCurSYSem.equals(strNextSem))
					bolNextNew = false;
				else
					bolNextNew = true;
			}
		}
		else if(strPrevSYSem.compareTo(strCurSYSem) ==0) {
			strSYSemToDisp = null;
		if (bolNewEntry)
			bolNewPrev = true;
		else
			bolNewPrev = false;
		bolNewEntry = false;
			if (strNextSem != null)
			{
				if (strCurSYSem.equals(strNextSem))
					bolNextNew = false;
				else
					bolNextNew = true;
			}
		}
		else {//itis having a new school name.
			strPrevSYSem = strCurSYSem;
			strSYSemToDisp = strPrevSYSem;
			bolNewEntry = true;
			bolNewPrev = true;
			if (strNextSem != null)
			{
				if (strCurSYSem.equals(strNextSem))
					bolNextNew = false;
				else
					bolNextNew = true;
			}
		}
	}
}
 //Very important here, it print LHS ==> <!-- if it is not to be shown.    RHS--> 
 
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){bolInComment = true;bolNewPage = false;
 %>
  <%=strHideRowLHS%> 
  <%}else {bolInComment = false;
  ++iRowsPrinted;}//actual number of rows printed. 
	
if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		iMulRemarkCount += 3;
		
		Vector vTempRemark = CommonUtil.convertCSVToVector((String)vMulRemark.remove(0), "##", true);
		while(vTempRemark.size() > 0) {//for wnu more remark column in one remark.. 
		strTemp = (String)vTempRemark.remove(0);
		iIndexOf = strTemp.indexOf(": ");
		if(iIndexOf == -1) {
			strCol1 = "Graduated: ";
			strCol2 = strTemp;
		}
		else{
			strCol1 = strTemp.substring(0, iIndexOf + 2);
			strCol2 = strTemp.substring(iIndexOf+2);
		}%>
		  <tr bgcolor="#FFFFFF"> 
			<td height="17" class="thinborderNONE" align="center">&nbsp;</td>
			<td height="17" class="thinborderNONE" valign="top"><label onClick="Update('0<%=i%>')" id="0<%=i%>"><%=strCol1%> </label></td>
			<td height="17" colspan="4" class="thinborderNONE"><label onClick="Update('1<%=i%>')" id="1<%=i%>"><%=ConversionTable.replaceString(strCol2,"\n","<br>")%></label></td>
		  </tr>
		<%}//end of while. %>
  <%}//end of if
}//end of vMulRemark.
	
	
if(strSchNameToDisp != null){bolNewPage = false;
	strTemp = strSchNameToDisp.toUpperCase();
if(strTemp.indexOf("WEST NEGROS UNIVERSITY") > -1)
	strTemp = strTemp + ", BACOLOD CITY";

String strTemp2 = strSYSemToDisp.toUpperCase();
if(strTemp2.startsWith("1ST"))
	strTemp2 = "FIRST "+strTemp2.substring(4);
else if(strTemp2.startsWith("2ND"))
	strTemp2 = "SECOND "+strTemp2.substring(4);
else if(strTemp2.startsWith("3RD"))
	strTemp2 = "THIRD "+strTemp2.substring(4);

strSYTermInfoPrevPage = WI.getStrValue(strTemp2,"",", ","").toUpperCase() + strTemp;
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="17" colspan="6"><strong><u><i><label id="000<%=i%>" onClick="Update('000<%=i%>')"><%=WI.getStrValue(strTemp2,"",", ","").toUpperCase()%><%=strTemp%></label></i></u></strong></td>
  </tr>
<%if(vEntranceData.elementAt(12) != null){%>
  <tr bgcolor="#FFFFFF"> 
    <td height="17" colspan="6" class="thinborderNONE"><%=vEntranceData.elementAt(12)%></td>
  </tr>
<%vEntranceData.setElementAt(null, 12);}%>
  <%strSchNameToDisp = null;
  ++iRowsPrinted;
 strSYSemToDisp = null;}

if(strSYSemToDisp != null && strSYSemToDisp.length() > 0) {bolNewPage = false;
strSYSemToDisp = strSYSemToDisp.toUpperCase();
if(strSYSemToDisp.startsWith("SUMMER")) {
	strSYSemToDisp = "SUMMER, "+strSYSemToDisp.substring(strSYSemToDisp.length() - 4);
}
if(strSYSemToDisp.indexOf("WEST NEGROS UNIVERSITY") > 0)
	strTemp = strSYSemToDisp + ", BACOLOD CITY";
else	
	strTemp = strSYSemToDisp;

if(strTemp.startsWith("1ST"))
	strTemp = "FIRST "+strTemp.substring(4);
else if(strTemp.startsWith("2ND"))
	strTemp = "SECOND "+strTemp.substring(4);
else if(strTemp.startsWith("3RD"))
	strTemp = "THIRD "+strTemp.substring(4);

strSYTermInfoPrevPage = strTemp;
%>
   <tr bgcolor="#FFFFFF"> 
	   <td colspan="6"><strong><u><i><label id="000<%=i%>" onClick="Update('000<%=i%>')"><%=strTemp%></label></i></u></strong></td>
   </tr>
<%strSYSemToDisp = null;}

if(bolNewPage && strSYTermInfoPrevPage != null) {bolNewPage = false;%>
   <tr bgcolor="#FFFFFF"> 
	   <td colspan="6"><strong><u><i><label id="000<%=i%>" onClick="Update('000<%=i%>')"><%=strSYTermInfoPrevPage%></label></i></u></strong></td>
   </tr>
<%}


//if (bolNewEntry && bolNextNew ) {
if(true){%>
  <tr bgcolor="#FFFFFF"> 
    <td height="17" valign="top" class="thinborderNONE"><div align="center"><%//=WI.getStrValue(strSYSemToDisp).toUpperCase()%></div></td>
    <td valign="top" class="thinborderNONE">
		<label id="00<%=i%>" onClick="updateSubjectRow('00<%=i%>')"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></label>
	</td>
    <td valign="top" class="thinborderNONE">
		<label id="01<%=i%>" onClick="updateSubjectRow('01<%=i%>')"><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></label>
	</td>
<%
strTemp = WI.getStrValue(vRetResult.elementAt(i + 8), "-");
if(strTemp.startsWith("on going")) {
	strTemp = "-";
	if(strCE != null && strCE.length() > 0 && !strCE.startsWith("(")) {
		try {
			if(Double.parseDouble(strCE) > 0d) 
				strCE = "(" + strCE + ")";
			
		}
		catch(Exception e) {}
	}
}
else {
	//I have to check if this subject is enrichment subject.. 
	iIndexOf = vEnrichmentSubjects.indexOf(vRetResult.elementAt(i + 6));
	if(iIndexOf > -1) {
		try {
			double dGrade = Double.parseDouble(strTemp);
			if(dGrade > 0d && (dGrade < 5d || dGrade >= 75d) && !strCE.startsWith("(") )
				strCE = "(" + (String)vEnrichmentSubjects.elementAt(iIndexOf + 3) + ")";
			
		}
		catch(Exception e){}
	}
}

%>

    <td width="8%" valign="top" class="thinborderNONE"><div align="center"><label id="02<%=i%>" onClick="updateSubjectRow('02<%=i%>')"><%=strTemp%></label></div></td>
	
    <td width="15%" valign="top" class="thinborderNONE" align="center">
<%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && 
	(	((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 || ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("lfr") != -1 ) &&
	vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
		%> 
		<%=(String)vRetResult.elementAt(i + 8 + 11)%> <%i += 11;}%>&nbsp;	</td>
    <%
	if(strCE != null && strCE.length() > 0 && strCE.endsWith(".0"))
		strCE = strCE.substring(0, strCE.length() - 2);
	%>	
	<td width="7%" valign="top" ><div align="center"> <label id="03<%=i%>" onClick="updateSubjectRow('03<%=i%>')"><%=strCE%></label></div></td>
  </tr>
  <% if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){bolInComment = false; bolNewPage = true;%>
  <%=strHideRowRHS%> 
  <%  }
  }%>

<%}//end of for loop%> 
  
<% if (bolRowSpan2 && false)  {%>  
<tr  bgcolor="#FFFFFF" >
<td height="17"  class="thinborderNONE">&nbsp;</td>
<td class="thinborderNONE">&nbsp;</td>
<td class="thinborderNONE">&nbsp;</td>
<td class="thinborderNONE">&nbsp;</td>
<td >&nbsp;</td>
</tr>
  
<% } // end bolRowSpan2 == true 
	if (iLastPage == 1){
		iRowsPrinted++;

//it will have entrance data information.. 
if(vGraduationData != null &&  vGraduationData.size() > 0){
//		System.out.println(vGraduationData);
		//if last page, i have to show the remark.
		// iMaxRowToDisp = iMaxRowToDisp - 2;
		
	String strCourseCode = (String)vStudInfo.elementAt(24);
	String strMajorCode  = null;
	if(vStudInfo.size() > 25)
		strMajorCode = (String)vStudInfo.elementAt(25);
	else if(vStudInfo.elementAt(8) != null) {
		strMajorCode = "select course_code from major where course_index = "+vStudInfo.elementAt(5)+

						" and major_index = "+vStudInfo.elementAt(6)+" and is_del = 0";
		strMajorCode = dbOP.getResultOfAQuery(strMajorCode,0);		
	}
	
	int iTemp = 1;
	 strTemp = "WITH THE DEGREE OF " + ((String)vStudInfo.elementAt(7)).toUpperCase();
	 if(strMajorCode != null) {
	 	strTemp += ", MAJOR IN "+((String)vStudInfo.elementAt(8)).toUpperCase();
		strCourseCode = strCourseCode + " "+strMajorCode;
	 }
	
	 strTemp += WI.getStrValue(strCourseCode," (",") ","");
				
	 if ((String)vGraduationData.elementAt(8) != null)
	 	strTemp += " ON " + WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
	
	 if(vGraduationData.elementAt(6) != null)
	 	strTemp +=	", AS PER " +vGraduationData.elementAt(6);
	 if (vGraduationData.elementAt(6) != null && vGraduationData.elementAt(7) != null) 
	 	 strTemp += ", " + WI.formatDate((String)vGraduationData.elementAt(7),6).toUpperCase() + ".";
	 else	
	 	strTemp += ".";
		
	if (strTemp.length()/100 > 0) {
		iTemp = strTemp.length()/100;
		if (strTemp.length()%100 > 0)
			iTemp +=1;
	}
	 iRowsPrinted += iTemp; 
// 	System.out.println("iRowsPrinted 4:" + iRowsPrinted );
%>  
<tr  bgcolor="#FFFFFF" >
	<td height="17" class="thinborderNONE" style="font-weight:bold"></td>
    <td height="17" class="thinborderNONE" style="font-weight:bold" valign="top">GRADUATED: </td>
    <td height="17" colspan="4" class="thinborderNONE" style="font-weight:bold"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
  </tr>
<%}%>
<tr bgcolor="#FFFFFF" >
	<td height="17" class="thinborderNONE" colspan="6" align="center">**** End Of Transcript****</td>
</tr>
<%strTemp = WI.fillTextValue("endof_tor_remark");
if(strTemp.length() > 0) {
  
iIndexOf = strTemp.indexOf(" ");
if(iIndexOf > -1) {
	strCol1 = strTemp.substring(0, iIndexOf + 1);
	strCol2 = strTemp.substring(iIndexOf);
}
else {
	strCol1 = "";
	strCol2 = strTemp;
}
++iRowsPrinted;
if(strCol2.indexOf("\n") > -1)
	++iRowsPrinted;
%>
<tr  bgcolor="#FFFFFF" >
	<td height="17" class="thinborderNONE" style="font-weight:bold"></td>
    <td height="17" class="thinborderNONE" valign="top"><%=strCol1%> </td>
    <td height="17" colspan="4" class="thinborderNONE"><%=ConversionTable.replaceString(strCol2,"\n","<br>")%></td>
  </tr>
<%}%>
<%
 for(;iRowsPrinted < iMaxRowToDisp; ++iRowsPrinted){%>
<!-- no need, i am using image.. 
<tr  bgcolor="#FFFFFF" >
<td height="17"  class="thinborderNONE">&nbsp;</td>
<td class="thinborderNONE">&nbsp;</td>
<td class="thinborderNONE">&nbsp;</td>
<td class="thinborderNONE">&nbsp;</td>
<td class="thinborderNONE">&nbsp;</td>
<td >&nbsp;</td>
</tr>
-->

<%} // end display of blank rows
}%>
</table>

<%//if(!WI.fillTextValue("print_").equals("1")){//end of this table... %>
	</td></tr></table>
<%//}%>

<%}//only if student is having grade infromation.%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="20" colspan="2" class="thickBOTTOM">&nbsp;</td> 
  </tr>
<%if(!WI.fillTextValue("last_page").equals("1")){
	strTemp = "(more on page " + (iPageNumber +1)+")";%>
  <tr>
    <td height="20"><font size="2">REMARKS :</font></td> 
    <td width="93%" class="thinborderBottom" align="center" valign="bottom" style="font-weight:bold"><font style="font-size:12px;"><%=strTemp%></font></td> 
  </tr>
<%}else{%>
  <tr>
    <td height="20"><font size="2">REMARKS :</font></td> 
    <td width="93%" class="thinborderBottom" valign="bottom"><font size="2"><%=WI.fillTextValue("addl_remark")%></font>&nbsp;</td> 
  </tr>
<%}%>  
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="36%" height="23" valign="bottom" style="font-size:12px;">(NOT VALID WITHOUT  UNIVERSITY SEAL)</td>
    <td width="12%" valign="bottom" style="font-size:12px;">Prepared By :</td>
    <td width="20%" valign="bottom" style="font-size:12px;" class="thinborderBottom" align="left"><%=(String)request.getSession(false).getAttribute("first_name")%></td>
    <td width="13%" valign="bottom" style="font-size:12px;">&nbsp;&nbsp;&nbsp;Reviewed By : </td>
    <td width="19%" valign="bottom" class="thinborderBottom" style="font-size:12px;">&nbsp;</td>
  </tr>
  <tr> 
    <td height="23" valign="bottom">&nbsp;</td>
    <td align="right" valign="bottom"><br><br>&nbsp;</td>
    <td valign="bottom" align="center" class="thickBOTTOM" style="font-size:12px;"><%=WI.fillTextValue("registrar_name")%></td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" valign="bottom">&nbsp;</td>
    <td align="right" style="font-size:12px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td align="center" style="font-size:12px;">Registrar</td>
    <td colspan="2" valign="top">&nbsp;</td>
  </tr>
</table>

<% if (strStudCourseToDisp.equals("T.C.P.") ||
	( !strDegreeType.equals("1") && !strDegreeType.equals("2"))) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  
  <tr>
    <td width="100%" height="17" valign="bottom" style="font-size:9px;">
	GRADING SYTEM UNTIL SUMMER 1999:<br>
	(97-100)=1.0;(94-96)=1.25;(91-93)=1.5;(88-90)=1.75;(85-87)=2.0;(82-84)=2.25;(79-81)=2.5;(77-78)=2.75;(75-76)=3.0;(BELOW 75)=5.0<br>
	GRADING SYTEM UNTIL SUMMER 2007:<br>
	(100)=1.0;(99)=1.1;(98)=1.2;(97)=1.3;(96)=1.4;(95)=1.5;(94)=1.6;(93)=1.7;(92)=1.8;(91)=1.9;(90)=2.0;(89)=2.1;(88)=2.2;(87)=2.3;(86)=2.4;(85)=2.5;(84)=2.6;(83)=2.7;(82)=2.8;(81)=2.9;(80)=3.0;(79)=3.1;(78)=3.2;(77)=3.3;(76)=3.4;(75)=3.5;(BELOW 75)=5.0
	<br>
	GRADING SYSTEM EFFECTIVE FIRST SEMESTER 2007-2008:<br>
	(100)=1.0;(99)=1.1;(98)=1.2;(97)=1.3;(96)=1.4;(95)=1.5;(94)=1.6;(93)=1.7;(92)=1.8;(91)=1.9;(90)=2.0;(89)=2.1;(88)=2.2;(87)=2.3;(86)=2.4;(85)=2.5;(84)=2.6;(83)=2.7;(82)=2.8;(81)=2.9;(80)=3.0;(79)=3.1;(78)=3.2;(77)=3.3;(76)=3.4;(75)=3.5;(BELOW 75)=5.0;INC.
	<br>
	One(1) Unit credit is given for one hour of lecture or recitation each week, pursued for a whole semester. Two-and a-half or three hours of laboratory work are regarded as the equivalent of an hour’s recitation or lecture.
	<br>
	REG-F07<br>
	REV 5(07-10-09)
</td>
  </tr>
</table>
<%}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" height="17" valign="bottom" style="font-size:9px;">GRADING SYTEM FOR DOCTORAL DEGREE EFFECTIVE FIRST SEMESTER 2007-2008<br>
	(99-100)=1.0;(97-98)=1.1;(95-96)=1.2;(93-94)=1.3;(91-92)=1.4;(89-90)=1.5;(87-88)=1.6;(85-86)=1.7;INC
	<br>
	GRADING SYTEM FOR MASTERAL DEGREE EFFECTIVE FIRST SEMESTER 2007-2008<br>
	(97-100)=1.0;(95-96)=1.1;(94)=1.2;(93)=1.3;(92)=1.4;(91)=1.5;(90)=1.6;(89)=1.7;(88)=1.8;(87)=1.9;(85-86)=2.0;INC
	<br>
	Credit: One (1) Unit of credit is given for one hour lecture or recitation each week, pursued for a whole semester.
	<br>
	REG-FO6<br>
	Rev 5(07-10-09)
</td>
  </tr>
</table>
<%}%>

<script>
function PrintNextPage() {
	<%if(!WI.fillTextValue("print_all_pages").equals("1")){%>
		return;
	<%}%>
	<%if(strPrintValueCSV.length() > 0){%>
	if(!confirm("Click Ok to print next page and Cancel to stay in this page."))
		return;
	document.form_.submit();
	<%}else{%>
	alert("End of printing");
	<%}%>
}
</script>
<input type="hidden" name="print_all_pages" value="<%=WI.fillTextValue("print_all_pages")%>">
<input type="hidden" name="print_value_csv" value="<%=strPrintValueCSV%>">
<input type="hidden" name="tf_sel_list" value="<%=WI.fillTextValue("tf_sel_list")%>">
<input type="hidden" name="print_" value="<%=WI.fillTextValue("print_")%>">


	<input type="hidden" name="total_page" value="<%=WI.fillTextValue("total_page")%>">
	<input type="hidden" name="curr_stud_id" value="<%=WI.fillTextValue("curr_stud_id")%>">
	<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">

<input type="hidden" name="prep_by1" value="<%=WI.fillTextValue("prep_by1")%>">
<input type="hidden" name="check_by1" value="<%=WI.fillTextValue("check_by1")%>">
<input type="hidden" name="registrar_name" value="<%=WI.fillTextValue("registrar_name")%>">

<!-- construct here course displays.. -->
<input type="hidden" name="max_course_disp" value="<%=WI.fillTextValue("max_course_disp")%>">
<%
//I have to construct here what are the courses checked already.. 
int iMaxCourseDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_course_disp"), "0"));
for(int i = 0; i < iMaxCourseDisp; ++i) {%>
	<input type="hidden" name="checkbox<%=i%>" value="<%=WI.fillTextValue("checkbox"+i)%>">
<%}%>
<!-- end of printing course checked. -->
<!-- Other values -->	
	<input type="hidden" name="honor_point" value="<%=WI.fillTextValue("honor_point")%>">
	<input type="hidden" name="show_rle" value="<%=WI.fillTextValue("show_rle")%>">
	<input type="hidden" name="show_leclab" value="<%=WI.fillTextValue("show_leclab")%>">
	<input type="hidden" name="weeks" value="<%=WI.fillTextValue("weeks")%>">
<%if(WI.fillTextValue("entrance_data").length() > 0) {
strTemp = WI.fillTextValue("entrance_data");
strTemp = ConversionTable.replaceString(strTemp, "<","&lt;");
strTemp = ConversionTable.replaceString(strTemp, ">","&gt;");
strTemp = ConversionTable.replaceString(strTemp, "'","&acute;");
%>
	<input type="hidden" name="entrance_data" value="<%=strTemp%>">
<%}if(WI.fillTextValue("addl_remark").length() > 0) {
strTemp = WI.fillTextValue("addl_remark");
strTemp = ConversionTable.replaceString(strTemp, "<","&lt;");
strTemp = ConversionTable.replaceString(strTemp, ">","&gt;");
strTemp = ConversionTable.replaceString(strTemp, "'","&acute;");
%>
	<input type="hidden" name="addl_remark" value='<%=strTemp%>'>
<%}%>
<input name="show_spr" type="hidden" value="<%=WI.fillTextValue("show_spr")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
