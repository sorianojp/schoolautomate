<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CSA OFFICIAL TRANSCRIPT OF RECORD</title>
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

.fontsize9 {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 8px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }
	TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }	
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;
    }
    .thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
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
	
	TD.thinborderTOPRIGHTBOTTOM {
	border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }
	
	TD.thinborderTOPLEFTBOTTOM {
	border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }
	
	TD.thinborderTOPLEFT{
	border-top: solid 1px #000000;
    border-left: solid 1px #000000;    
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }
	
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }
	
	TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
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

-->
</style>
</head>
<script language="javascript">
function HideImg() {
	document.getElementById('hide_img').innerHTML = "";
}
function UpdateLabel(strLevelID) {
	return;
	
	
	var newVal = prompt('Please enter new Value');
	if(newVal == null)
		return;
	document.getElementById(strLevelID).innerHTML = newVal;
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = null;
	
	String strReligion 	   = null;
	String strSpouse 	   = null;
	
	String strCollegeName = null;//I have to find the college offering course.
	
	int iRowStartFr = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_start_fr"), "0"));
	int iRowCount   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_count"), "0"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"), "0"));
	String strPrintPage = WI.fillTextValue("print_");//"1" is print. 
	
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_page_to_disp"), "0"));
	
	int iPageNumber = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_number"), "0"));
	String strTotalPageNumber = WI.fillTextValue("total_page");

	String strImgFileExt = null;
	
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
boolean bolIsCareGiver = false;//if caregiver, i have to append hrs to the credit earned.

Vector vStudInfo = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;
Vector vCompliedRequirement = null;
Vector vReqList = null;

int iLevelID = 0;

Vector vMulRemark = null;
int iMulRemarkIndex = -1;

int iIndexOf = 0;
boolean bolRemoveROTC  = false;
if(WI.fillTextValue("remove_nstp_opt").length() > 0)
	bolRemoveROTC  = true;
	
int iIsNextPage = 0;/// 1 = Yes next page, 2 = next page is set but wrapped in <!-- --> , show if 1.... 
String strNextPageSch = null;
String strNextPageTerm = null;
	
	
	
///// extra condition for the selected courses
String strStudCourseToDisp = null; 
String strStudMajorToDisp = null;

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


String[] astrConvertSem = {"SUMMER","First Semester","Second Semester","Third Semester","Fourth Semester"};

String[] astrConvertSemUG  = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
String[] astrConvertSemMED = {"SUMMER","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR"};
String[] astrConvertSemMAS = {"Summer","FIRST TRIMESTER","SECOND TRIMESTER","THIRD TRIMESTER",""};

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
	//System.out.println("vStudInfo "+vStudInfo.elementAt(12));
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
			
		strReligion = "select religion,spouse_name from info_personal where user_index = "+(String)vStudInfo.elementAt(12);
		java.sql.ResultSet rs = dbOP.executeQuery(strReligion);
		if(rs.next()){
			strReligion = rs.getString(1);
			strSpouse = rs.getString(2);
		}rs.close();
		
	}
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,WI.fillTextValue("stud_id"),
														(String)vStudInfo.elementAt(7),
													(String)vStudInfo.elementAt(8));
		if (vFirstEnrl != null) {
			vRetResult = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
											(String)vFirstEnrl.elementAt(2),false,false,true,true);
										
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = cRequirement.getErrMsg();
		else
			vCompliedRequirement = (Vector)vRetResult.elementAt(1);
	  }
	  else 
	  	strErrMsg = cRequirement.getErrMsg();	
}

//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);

if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);

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
		
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true, strExtraCon);
	
	//System.out.println(vRetResult);
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
String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);

boolean bolIsRLEHrs = false;
boolean bolShowLecLabHr = false; String[] astrLecLabHr = null;//gets lec/lab hour information.
String strRLEHrs    = null;
String strCE        = null;

boolean bolIsMedTOR = strDegreeType.equals("2");
//if(bolIsMedTOR) {
if (strDegreeType != null && strDegreeType.equals("2")) {
		astrConvertSem[0] = "SUMMER";
		astrConvertSem[1] = "ACADEMIC YEAR";
		astrConvertSem[2] = "ACADEMIC YEAR";
		astrConvertSem[3] = "ACADEMIC YEAR";
		astrConvertSem[4] = "ACADEMIC YEAR";
}


if(vRetResult.toString().indexOf("hrs") > 0 && WI.fillTextValue("show_rle").compareTo("1") == 0)
	bolIsRLEHrs = true;

if(WI.fillTextValue("show_leclab").compareTo("1") == 0)	
	bolShowLecLabHr = true;
	
//System.out.println(vStudInfo);
//System.out.println(vMulRemark);


//get internship ifno.. 
Vector vInternshipInfo = repRegistrar.getInternshipInfo();
//System.out.println(vInternshipInfo);


String strMulRemarkAtEndOfSYTerm = null;//if there is any remark added after the end of SY/term of Student.. 

//check if caregiver.. 
if(strStudCourseToDisp != null && strStudCourseToDisp.toLowerCase().equals("caregiver course"))
	bolIsCareGiver = true;
	
%>

<body topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0">
<form action="./otr_print_CSA.jsp" method="post" name="form_">

<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
	<tr><td height="60">&nbsp;</td></tr>
</table>

<%if(vAdditionalInfo != null && vAdditionalInfo. size() > 0){
	if(iPageNumber != 1){
		iIsNextPage = 1;/// next page.. 
	%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();" class="thinborder">
	<tr>
		<td rowspan="2" class="" style="text-indent:5px;" width="10%"><strong><font size="2">NAME:</font></strong></td>
		<td rowspan="2" class="" valign="bottom" align="center"><strong><font size="2">
		<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		<%
			strTemp = WI.getStrValue(vStudInfo.elementAt(1)," ").toLowerCase();
			if(strTemp.length() > 0)
				strTemp = String.valueOf(strTemp.charAt(0)).toUpperCase() + strTemp.substring(1);
		%>	
			
		
		<%=strTemp%></font></strong></td>
		<td width="20%" height="20" class="thinborder"><i>Stud No. &nbsp; &nbsp; <strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong></i></td>
	</tr>
	<tr>
		<td class="thinborderLEFT" height="20">Page No. <%=iPageNumber%></td>
	</tr>
	
</table>


<%}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();" class="thinborder">
	<tr>
		<td class="thinborderBOTTOM" style="text-indent:5px;" width="10%" height="25"><strong><font size="2">NAME:</font></strong></td>
		<td class="thinborderBOTTOM" valign="bottom" align="center"><strong><font size="2">
		<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		<%
			strTemp = WI.getStrValue(vStudInfo.elementAt(1)," ").toLowerCase();
			if(strTemp.length() > 0)
				strTemp = String.valueOf(strTemp.charAt(0)).toUpperCase() + strTemp.substring(1);
		%>	
			
		<%=strTemp%></font></strong></td>
		
		<%
		strTemp = (String)vStudInfo.elementAt(16);
		if(strTemp.equals("M"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td class="thinborderBOTTOM" valign="top" width="10%">
			<input type="checkbox" disabled="disabled" <%=strErrMsg%>><font size="1">Male</font>
		<%
		strTemp = (String)vStudInfo.elementAt(16);
		if(strTemp.equals("F"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
			<br><input type="checkbox" disabled="disabled" <%=strErrMsg%>><font size="1">Female</font>
		</td>
		<td class="thinborderBOTTOM" width="13%" rowspan="4" valign="top">
			<img src="../../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt%>" width="120" height="120" border="1" align="top">
		</td>
	</tr>
	
	<tr>
		<td class="thinborderBOTTOM" height="25" style="text-indent:5px;" valign="top"><font size="1"><i><strong>Address:</strong></i></font></td>
		<td class="thinborderBOTTOM" colspan="2" valign="bottom">
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3)).toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","").toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","").toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(7)).toUpperCase()%>
		</td>
	</tr>
	<tr>
		<td colspan="3" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
				<tr>
					<td class="thinborderBOTTOM" width="17%" height="25" style="text-indent:5px" valign="top">
						<strong><font size="1"><i>Birthdate:</i></font></strong></td> 
					<%
						strTemp = "&nbsp;";
						if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
							strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1));
						
					%>
					<td class="thinborderRIGHTBOTTOM" width="20%" valign="bottom"><%=strTemp.toUpperCase()%></td>
					<td class="thinborderBOTTOM" width="17%" height="25" valign="top">
						<strong><font size="1"><i>Birthplace:</i></font></strong></td>
					<%
						strTemp = "&nbsp;";
						if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
							strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2));
						
					%>
					<td class="thinborderBOTTOM" valign="bottom"><%=strTemp.toUpperCase()%></td>
				</tr>
			</table>

		</td>
	</tr>
	<tr>
		<td colspan="3" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
				<tr>
					<td class="thinborderBOTTOM" width="22%" height="25" style="text-indent:5px" valign="top">
						<strong><font size="1"><i>ACR No. / ICR No.:</i></font></strong></td>
					<td class="thinborderRIGHTBOTTOM" width="28%" valign="bottom">&nbsp;</td>
					<td class="thinborderBOTTOM" width="20%" height="25" valign="top">
						<strong><font size="1"><i>Citizenship:</i></font></strong></td>
					<td class="thinborderBOTTOM" valign="bottom"><%=WI.getStrValue((String)vStudInfo.elementAt(23), "&nbsp;").toUpperCase()%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="5" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
				<tr>
					<td class="thinborderBOTTOM" width="12%" height="25" style="text-indent:5px" valign="top">
						<strong><font size="1"><i>Parent:</i></font></strong></td>
					<td class="thinborderRIGHTBOTTOM" width="60%" valign="bottom">
						<%=WI.getStrValue(WI.getStrValue(WI.getStrValue((String)vAdditionalInfo.elementAt(8), (String)vAdditionalInfo.elementAt(9))).toUpperCase(),"&nbsp;")%>						
					</td>
					<td class="thinborderBOTTOM" width="10%" height="25" valign="top">
						<strong><font size="1"><i>Stud. No.:</i></font></strong></td>
					<td class="thinborderBOTTOM" valign="bottom"><%=WI.fillTextValue("stud_id").toUpperCase()%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="5" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
				<tr>
					<td valign="top" width="6%" style="text-indent:5px"><font size="1">School</font></td>
					<td class="thinborder" width="15%" height="25" valign="top"><font size="1"><strong><i>Elementary:</i></strong></font></td>
					<%
						strTemp = "&nbsp;"; 
						if(vEntranceData != null)
							strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
					%>
					<td class="thinborderBOTTOM" width="37%" valign="bottom"><%=strTemp%></td>
					<td class="thinborderRIGHTBOTTOM" width="7%" valign="bottom"><%=WI.getStrValue((String)vEntranceData.elementAt(20),"- ","","&nbsp;")%></td>
					<td class="thinborderBOTTOM" width="15%" valign="top"><strong><font size="1"><i>Title/Degree/Course:</i></font></strong></td>
					<td valign="bottom" class="thinborderBOTTOM"><strong><%=WI.getStrValue((String)vStudInfo.elementAt(24),"&nbsp;").toUpperCase()%></strong></td>
				</tr>
				<tr>
					<td valign="top" style="text-indent:5px"><font size="1">and</font></td>
					<td class="thinborder" height="25" valign="top"><font size="1"><strong><i>Secondary:</i></strong></font></td>
					<td class="thinborderBOTTOM" valign="bottom"><%=WI.getStrValue((String)vEntranceData.elementAt(5),"&nbsp;")%></td>
					<td class="thinborderRIGHTBOTTOM" valign="bottom"><%=WI.getStrValue((String)vEntranceData.elementAt(22),"- ","","&nbsp;")%></td>
					<td class="thinborderBOTTOM" valign="top"><strong><font size="1"><i>Majors:</i></font></strong></td>
					<td valign="bottom" class="thinborderBOTTOM"><strong><%=WI.getStrValue((String)vStudInfo.elementAt(25),"&nbsp;")%></strong></td>
				</tr>
				<tr>
					<td class="thinborderBOTTOM" valign="top" style="text-indent:5px"><font size="1">Year</font></td>
					<td class="thinborder" height="25" valign="top"><font size="1"><strong><i>College:</i></strong></font></td>
					<td class="thinborderBOTTOM" valign="bottom"><%=WI.getStrValue((String)vEntranceData.elementAt(7),"&nbsp;")%></td>
					<td class="thinborderRIGHTBOTTOM" valign="bottom">&nbsp;<%//=WI.getStrValue((String)vEntranceData.elementAt(21),"&nbsp;")%> </td>
					<td class="thinborderBOTTOM" valign="top"><strong><font size="1"><i>Date Graduated:</i></font></strong></td>
					<%if(vGraduationData != null)
						strTemp = WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
					  else
						strTemp = "&nbsp;";				  
					%>
					<td valign="bottom" class="thinborderBOTTOM"><strong><%=strTemp%></strong></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top" colspan="5">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
				<td class="" height="25" valign="top" width="15%" style="text-indent:5px;">
					<strong><font size="1"><i>Date Admitted:</i></font></strong></td>
				<td class="thinborderRIGHT" valign="bottom" width="20%">
					<% if(vEntranceData != null) {%>
						<%=WI.getStrValue((String)vEntranceData.elementAt(23),"&nbsp;")%> 
					<%}else{%> &nbsp; <%}%></td>
				<td class="" height="25" valign="top" width="10%">
					<strong><font size="1"><i>Credentials:</i></font></strong></td>
					<%strTemp = WI.fillTextValue("entrance_data");%> 
					
				<td class="thinborderRIGHT" valign="bottom" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%> </td>	
				<td class="" height="25" valign="top" width="15%">
					<strong><font size="1"><i>S.O. No. / Series:</i></font></strong></td>
				<%
				if(vGraduationData != null && vGraduationData.size()!=0)
					strTemp = WI.getStrValue(vGraduationData.elementAt(6));
				else	
					strTemp = "&nbsp;";
				%>
				<td width="20%" valign="bottom" class=""><%=strTemp.toUpperCase()%></td>
			</table>
		</td>
	</tr>
</table>
<%}
}//end vAdditionalInfo%>




<%
if(vRetResult != null && vRetResult.size() > 0){
	int iNumWeeks = 0;
	if (WI.fillTextValue("weeks").length() > 0) 
		iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));
		
	if(iPageNumber != 1)
		strTemp = "930px";		//long bondpaper	
	else	
		strTemp = "730px";
	
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td width="100%" height="<%=strTemp%>" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">			
				
				<tr>
					<td width="17%" class="thinborderRIGHTBOTTOM" rowspan="2" align="center" height="25"><strong>COURSE NO</strong></td>
					<td width="53%" rowspan="2" align="center" class="thinborderBOTTOM"><strong>DESCRIPTIVE TITLE</strong></td>
					<td class="thinborder" align="center" colspan="3"><strong>RATING</strong></td>
				</tr>
				
				<tr>
					<td width="10%" align="center" class="thinborder"><strong>Final</strong></td>
					<td width="10%" align="center" class="thinborder"><strong>Comp.</strong></td>
					<td width="10%" align="center" class="thinborder"><strong>Credit</strong></td>
				</tr>

<%

int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = null;
String strSchNameToDisp = null;

String strSYSemToDisp   = null;
String strSYToDisp		= null;
String strSemToDisp		= null;

String strCurSYSem      = null;
String strCurSem		= null;
String strCurSY			= null;

String strPrevSYSem     = null;
String strPrevSY		= null;
String strPrevSem		= null;

boolean bolIsSchNameNull    = false;
boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has 
boolean  bolPrinted = false; // print only once

String strGrade = null;

//school name after it is null, it is encoded as cross enrollee.

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);

String strInternshipInfo = null;

String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;
//System.out.println("iMaxRowToDisp 1 : " + iMaxRowToDisp);

if(WI.fillTextValue("addl_remark").length() > 0 && iLastPage == 1){

	int iTemp = 1;
	strTemp = WI.fillTextValue("addl_remark");

	while((iIndexOf = strTemp.indexOf("<br>",iIndexOf + 1)) != -1)
		++iTemp;

	 iMaxRowToDisp = iMaxRowToDisp - iTemp; 
}
//System.out.println(vRetResult);

if(vInternshipInfo == null)
	vInternshipInfo = new Vector();

for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){

//I have to now check if this subject is having RLE hours. 
//String strRLEHrs    = null;
//String strCE        = null;
//System.out.println(vRetResult.elementAt(i + 8));
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && 
		//((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 &&  -- removed for inc checking. 
		vRetResult.elementAt(i + 6) != null && vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) {   //semester
			strTemp  = (String)vRetResult.elementAt(i + 9 + 11);
			strGrade = (String)vRetResult.elementAt(i + 8 + 11); 
	}
	else {
		strTemp  = (String)vRetResult.elementAt(i + 9);
		strGrade = (String)vRetResult.elementAt(i + 8);
	}
	
	strCE  = strTemp;
	
	if (strCE!= null && strCE.equals("0") && WI.getStrValue((String)vRetResult.elementAt(i + 8),"").toLowerCase().equals("drp")) {
		strCE = "-";
	}
	
	if(strTemp != null && strTemp.indexOf("hrs") > 0) {
		strRLEHrs = CommonUtil.formatGrade(strTemp.substring(strTemp.indexOf("(") + 1, strTemp.indexOf("hrs")),0f);
		strCE     = strTemp.substring(0,strTemp.indexOf("("));
	}
	else {
		strRLEHrs    = null;
	}
	
	strSchoolName = (String)vRetResult.elementAt(i);	
	//System.out.println(vRetResult.elementAt(i));
	if(vRetResult.elementAt(i) == null)
		bolIsSchNameNull = true;
	///this is because, cross enrollee are after transferee.. so, once transferee 
	// are printed, school name is null and it becomes value again only if it is
	//cross enrolled.

	//for cross enrolled, I have to 
//	if(vRetResult.elementAt(i) != null)// && bolIsSchNameNull) //cross enrolled.
//		strSchoolName += " <br>(CROSS ENROLLED)";	
	
		
//System.out.println("strSchNameToDisp : "+strSchNameToDisp+ " strPrevSchName  : "+strPrevSchName+ " strSchoolName: "+strSchoolName); 
// uncomment this if school name apprears once.//
	if(strSchoolName != null) {
		if(strPrevSchName == null) {
			strPrevSchName = strSchoolName ;
			strSchNameToDisp = strSchoolName;
		}
		else if(strPrevSchName.compareTo(strSchoolName) ==0) {
			strSchNameToDisp = null;
		}
		else {//itis having a new school name.
			//strPrevSchName = strSchoolName;
			//strSchNameToDisp = strPrevSchName;
			strSchNameToDisp = strSchoolName; //2008-06-23 = added;
		}
	}
	
	if(i == 0 && strSchoolName == null) {//I have to get the current school name
		strSchNameToDisp = "COLEGIO SAN AGUSTIN - BACOLOD, Bacolod City";
	}
	//if(strSchoolName == null)// && vRetResult.elementAt(i + 10) != null)//subject group name is not null for reg.sub
	//	strSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);
		
	if(strSchoolName != null)
		strSchNameToDisp = strSchoolName;	
		
 	//if prev school name is not not null, show the current shcool name.
	if(strSchoolName == null && strPrevSchName != null) {
		strSchNameToDisp = strCurrentSchoolName;
		strPrevSchName = null;
	}

	


//System.out.println("strSchNameToDisp-11xx : "+strSchNameToDisp+ " strPrevSchName  : "+strPrevSchName+ " strSchoolName: "+strSchoolName); 

//strCurSYSem =
if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.	
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+" "+
					(String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);
					
		strCurSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+3))];
		strCurSY  = (String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);
		
	}
	else {
		strCurSYSem = (String)vRetResult.elementAt(i+ 3)+" "+(String)vRetResult.elementAt(i+ 1)+"-"+
							(String)vRetResult.elementAt(i+ 2);
							
		strCurSem = (String)vRetResult.elementAt(i+ 3);
		strCurSY  = (String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);
	}
	if(strCurSem != null && strCurSY != null) {		
		if(strPrevSY == null && strPrevSem == null) {
			strPrevSY = strCurSY;
			strPrevSem = strCurSem;
			
			strSYToDisp = strCurSY;
			strSemToDisp = strCurSem;
			
		}
		else if(strPrevSY.compareTo(strCurSY) ==0 && strPrevSem.compareTo(strCurSem)==0) {			
			strSYToDisp = null;
			strSemToDisp = null;			
		}
		else {//itis having a new school name.			
			strPrevSY = strCurSY;
			strPrevSem = strCurSem;
			
			strSYToDisp = strPrevSY;
			strSemToDisp = strPrevSem;			
		}
	}
}


	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//cross enrolled.
		if(strCrossEnrolleeSchPrev == null || strCrossEnrolleeSchPrev.compareTo(strSchoolName) != 0)  {
			strCrossEnrolleeSchPrev = strSchoolName;
			strCrossEnrolleeSch     = strSchoolName; 
			strSYToDisp = strCurSY;
			strSemToDisp = strCurSem;			
			//System.out.println(" strCrossEnrolleeSch ; "+strCrossEnrolleeSch);
			strSchNameToDisp = strSchoolName;//added to display cross enrolled school :: 2008-06-23 = added followed by request from AUF to show crossenrolled school name.
		}
	}
	//cross enrolled.. 
	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//display will be schooo name<br>sy/term (cross enrolled)
		strSYToDisp = null;
		strSemToDisp = null;		
		strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSY+" "+strCurSem+" (CROSS ENROLLED)";
	}

 //Very important here, it print <!-- if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){
 	if(iIsNextPage == 1)
		iIsNextPage = 2;
		
 	strHideRowLHS = "<!--"; //I have to do this so i will know if I am priting data or not%>
  <%=strHideRowLHS%> 
  <%}else {
  	++iRowsPrinted;
	strHideRowLHS = "";
//	System.out.println("iRowsPrinted 1:" + iRowsPrinted );
	}//actual number of rows printed. 


///////////////// add this to show school year/school name in next page.. // at start of page.
if(strSchNameToDisp != null) {
	strNextPageSch = strSchNameToDisp;
	if(strNextPageSch.toUpperCase().equals(SchoolInformation.getSchoolName(dbOP,false,false).toUpperCase()))
		strNextPageSch = "COLEGIO SAN AGUSTIN - BACOLOD, Bacolod City";
}
if(strSemToDisp != null)
	strNextPageTerm = strSemToDisp+", "+ strSYToDisp;
	
/////////////////// end here code to show school name/sy in next page -- start of page. -- also set bolIsNextPage in iLastPage == 1


//check internship Info.. 
strInternshipInfo = null;

if(vInternshipInfo.size() > 0) {
	int iTemp = ((Integer)vInternshipInfo.elementAt(0)).intValue();
	if(iTemp == i) {
		strInternshipInfo = (String)vInternshipInfo.remove(1);
		vInternshipInfo.remove(0);
	}
	else if(iTemp == i + 11) {//may be inc
			if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && //&& ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 - remove the inc checking..
				((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    		((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
				((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
				WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
					strInternshipInfo = (String)vInternshipInfo.remove(1);
					vInternshipInfo.remove(0);
				}
		}
}

%>
<%if(iIsNextPage == 1 || 
	(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp))))) {
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
	%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" class="thinborderRIGHT">&nbsp;</td>
    <td height="20"><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')">&nbsp;<u>
		<%if(iIsNextPage == 1) {%>
			<%=strNextPageSch.toUpperCase()%>
		<%}else{%>
			<%=strSchNameToDisp.toUpperCase()%>
		<%}%>
		</u></label>
    </strong></td>
	<td height="20" class="thinborderLEFT">&nbsp;</td>
	<td height="20" class="thinborderLEFT">&nbsp;</td>
	<td height="20" class="thinborderLEFT">&nbsp;</td>
  </tr>
<%strPrevSchName = strSchNameToDisp; } %>

<%//System.out.println(bolIsNextPage);
if(iIsNextPage == 1 || (strSYToDisp != null && strSemToDisp != null)){
		if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;

	if(bolIsCareGiver && vEntranceData.elementAt(27) != null)
		strTemp = strSemToDisp +" "+ ((String)vEntranceData.elementAt(27));		
	else
		strTemp = strSemToDisp +", "+ strSYToDisp;		
%>
  <tr bgcolor="#FFFFFF"> 
  	<td class="thinborderRIGHT">&nbsp;</td> 	    	
  	<td ><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')">&nbsp;<u><strong>
		<%if(iIsNextPage == 1) {iIsNextPage = 0;%>
			<%=strNextPageTerm%>
		<%}else{%>
			<%=strTemp%>
		<%}%>
		
	</strong></u></label>
	</td>
	<td height="20" class="thinborderLEFT">&nbsp;</td>
	<td height="20" class="thinborderLEFT">&nbsp;</td>
	<td height="20" class="thinborderLEFT">&nbsp;</td>
  </tr>
  
<%}

strGrade = WI.getStrValue(strGrade, "-");
if(strGrade.startsWith("on going")) {
	strGrade = "-";
	if(strCE != null && strCE.length() > 0 && !strCE.startsWith("(")) {
		try {
			if(Double.parseDouble(strCE) > 0d) 
				strCE = "(" + strCE + ")";
			
		}
		catch(Exception e) {}
	}
}
/**
if(strGrade.equals("on going")) {
	strGrade = "GNA";
	strCE = "";
}
**/
else if(strGrade.compareToIgnoreCase("IP") == 0) {
	strGrade = "IP";
	strCE = "";
}
else {
	if(strGrade.indexOf(".") > -1 && strGrade.length() == 3) 
		strGrade = strGrade + "0";
}

if(bolIsCareGiver && strCE.length() > 0) 
	strCE = strCE + "hrs";
try {
	Double.parseDouble(strCE);
	strCE = CommonUtil.formatFloat(strCE, false);
}
catch(Exception e) {
	//do nothing.
}
//it is re-exam if student has INC and cleared in same semester,
	strTemp = "";
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester			
      strTemp = (String)vRetResult.elementAt(i + 8 + 11);	  	  
		
	  	i += 11;
      }
	  
	  //format here sub_code.
	  strErrMsg = WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;");
	  if(bolRemoveROTC) {
		iIndexOf = strErrMsg.indexOf("ROTC");
		if(iIndexOf == -1)
			iIndexOf = strErrMsg.indexOf("LTS");
		if(iIndexOf == -1)
			iIndexOf = strErrMsg.indexOf("CWTS");
		if(iIndexOf > 0)
			strErrMsg = strErrMsg.substring(0, iIndexOf-1);
		//System.out.println(iIndexOf);
	  }
	  
%>
	
  <tr bgcolor="#FFFFFF">      
  	<td class="thinborderRIGHT" height="14">&nbsp; &nbsp; &nbsp; <%=strErrMsg%></td>  
    <td><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')">&nbsp; <%=WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;")%> </label></td>
    <td align="center" class="thinborderLEFT"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(strGrade,"&nbsp;")%></label></td>
	<td align="center" class="thinborderLEFT"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(strTemp,"&nbsp;")%></label></td>
    <td align="center" class="thinborderLEFT" width="10%"><%=WI.getStrValue(strCE,"&nbsp;")%></td>
  </tr>

	


  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){
   		if(iIsNextPage == 2)
			iIsNextPage = 1;
	%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop
   %>
   
   
<%if(iLastPage == 1){%>
		<tr>
		<%if(vGraduationData != null &&  vGraduationData.size() > 0){	
			String strCourseCode = (String)vStudInfo.elementAt(24);
			String strMajorCode  = null;
			if(vStudInfo.size() > 25)
				strMajorCode = (String)vStudInfo.elementAt(25);
			else if(vStudInfo.elementAt(8) != null) {
				strMajorCode = "select course_code from major where course_index="+vStudInfo.elementAt(5)+" and major_index="+vStudInfo.elementAt(6)+" and is_del=0";
				strMajorCode = dbOP.getResultOfAQuery(strMajorCode,0);		
			}
			
			int iTemp = 1;
			if(bolIsCareGiver)
				strTemp = "GRADUATED WITH THE SIX-MONTH CARE GIVER";
			else
				strTemp = "GRADUATED: With the degree of "+((String)vStudInfo.elementAt(7)).toUpperCase();
			 
			 if(strMajorCode != null) {
				strTemp += " MAJOR IN "+((String)vStudInfo.elementAt(8)).toUpperCase();
				strCourseCode = strCourseCode + " "+strMajorCode;
			 }
			
			 strTemp += WI.getStrValue(strCourseCode," (",") ","")+". ";
			
			 if ((String)vGraduationData.elementAt(8) != null)
				strTemp += " on " +WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
			
			 
			 if(vGraduationData.elementAt(6) != null){
				strTemp += " with Special Order "+WI.getStrValue(vGraduationData.elementAt(6))+
					" issued by the Commision on Higher Education on "+WI.formatDate((String)vGraduationData.elementAt(7),6).toUpperCase();							
			 }					
			if (strTemp.length()/100 > 0) {
				iTemp = strTemp.length()/100;
				if (strTemp.length()%100 > 0)
					iTemp +=1;
			}
			 iRowsPrinted += iTemp; 
		%>  									
			<td colspan="5" style="padding-left:50px; padding-right:50px;">
				<%=strTemp%>
			</td>
			
			
			<%}%>  	
		<tr><td height="18" colspan="5" align="center"><strong> * * * END OF TRANSCRIPT * * *  </strong></td></tr>	
<%}else{%>
		<tr>
			<td class="">&nbsp;</td>
			<td class=""><strong><font size="1"><i>( continued on page <%=iPageNumber+1%>)</i></font></strong></td>
			<td class="">&nbsp;</td>
			<td class="">&nbsp;</td>
			<td class="">&nbsp;</td>
		</tr>

<%}%>
		</table><!-- Table inside td. -->
		</td>
	</tr>
	
	
	
	
	
	
	
	
	<tr>
		<td width="100%" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
				<tr>
					<td class="thinborderTOPBOTTOM" width="12%" height="20"><strong><i><font size="1">REMARKS:</font></i></strong></td>
					<td class="thinborderTOPBOTTOM"><%=WI.fillTextValue("addl_remark")%>&nbsp;</td>
					<td class="thinborderTOPLEFTBOTTOM" width="17%"><font size="1"><i>Prepared By:</i></font></td>
					<td class="thinborderTOPBOTTOM" width="17%"><font size="1"><i>Checked By:</i></font></td>
				</tr>
				<tr>
					<td class="thinborderBOTTOM" height="20"><strong><i><font size="1">PURPOSE</font></i></strong></td>
					<td class="thinborderBOTTOM"><%=WI.getStrValue(WI.fillTextValue("purpose_csa"),"&nbsp;")%></td>
					<td class="thinborderLEFTBOTTOM" align="center">&nbsp;<%=WI.fillTextValue("prep_by1").toUpperCase()%></td>
					<td class="thinborderBOTTOM" align="center">&nbsp;<%=WI.fillTextValue("check_by1").toUpperCase()%></td>
				</tr>
				<tr>
					<td class="thinborderBOTTOM" height="20"><strong><i><font size="1">T / R Sent to:</font></i></strong></td>
					<td class="thinborderBOTTOM"><%=WI.getStrValue(WI.fillTextValue("tr_sent_to_csa"),"&nbsp;")%></td>
					<td class="thinborderLEFTBOTTOM" colspan="2"><font size="1"><i>Date Issued</i></font> &nbsp; &nbsp; <i><%=WI.getTodaysDate(6)%></i></td>
				</tr>
				
				<tr>
					<td colspan="2">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
							<tr><td colspan="6" height="28"><strong>GRADING SYSTEM</strong></td></tr>
							<tr>
								<td height="17"><font size="1"><i>95-100</i></font></td>
								<td><font size="1"><i>Excellent</i></font></td>
								<td><font size="1"><i>80-84</i></font></td>
								<td><font size="1"><i>Satisfactory</i></font></td>
								<td><font size="1"><i>INC</i></font></td>
								<td><font size="1"><i>Incomplete</i></font></td>
							</tr>
							<tr>
								<td height="17"><font size="1"><i>90-94</i></font></td>
								<td><font size="1"><i>Very Good</i></font></td>
								<td><font size="1"><i>75-79</i></font></td>
								<td><font size="1"><i>Fair</i></font></td>
								<td><font size="1"><i>DRP</i></font></td>
								<td><font size="1"><i>Dropped</i></font></td>
							</tr>	
							<tr>
								<td height="17"><font size="1"><i>85-89</i></font></td>
								<td><font size="1"><i>Good</i></font></td>
								<td><font size="1"><i>74-Below</i></font></td>
								<td><font size="1"><i>Failure</i></font></td>
								<td><font size="1"><i>OW/UW</i></font></td>
								<td><font size="1"><i>Officially/Unofficially Withdrawn</i></font></td>
							</tr>
							<tr><td class="thinborderBOTTOM" colspan="6">
							<font size="1"><i>One Unit of Credit is One Hour Lecture or Three Hours Laboratory each week</i></font></td></tr>				
						</table>
					</td>
					
					<td colspan="2" valign="top" class="thinborderLEFTBOTTOM">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
							<tr><td height="50" align="center" valign="bottom"><strong><%=WI.getStrValue(WI.fillTextValue("assistant_registrar"),WI.fillTextValue("registrar_name")).toUpperCase()%></strong></td></tr>
							<tr><td height="25" valign="top" align="center"><font size="1"><strong>
							<%if(WI.fillTextValue("assistant_registrar").length() > 0){%> ASSISTANT<%}%>
							REGISTRAR</strong></font></td></tr>
							<tr><td align="center"><i><font size="1">Not Valid Without College Seal</font></i></td></tr>
						</table>
					</td>
				</tr>
				
			</table>
		</td>
	</tr>
		
</table>

















<%}//only if student is having grade infromation.%>



<%//System.out.println(WI.fillTextValue("print_"));
if(strPrintPage.compareTo("1") == 0){%>
<script language="javascript">
 window.print();
</script>
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


	<input type="hidden" name="total_page" value="<%=WI.fillTextValue("total_page")%>">
	<input type="hidden" name="curr_stud_id" value="<%=WI.fillTextValue("curr_stud_id")%>">
	<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">

<input type="hidden" name="prep_by1" value="<%=WI.fillTextValue("prep_by1")%>">
<input type="hidden" name="check_by1" value="<%=WI.fillTextValue("check_by1")%>">
<input type="hidden" name="registrar_name" value="<%=WI.fillTextValue("registrar_name")%>">
<input type="hidden" name="check_by2" value="<%=WI.fillTextValue("check_by2")%>">
<input type="hidden" name="endof_tor_remark1" value="<%=WI.fillTextValue("endof_tor_remark")%>">

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