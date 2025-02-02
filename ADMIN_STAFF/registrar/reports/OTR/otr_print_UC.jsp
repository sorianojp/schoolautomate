<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>UC OFFICIAL TRANSCRIPT OF RECORD</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	/**font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;**/;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

.fontsize9 {
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }	
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    .thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderRIGHTBOTTOM {
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborderLEFTRIGHTBOTTOM {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
pre{
    margin:0;
	font-family:Geneva, Arial, Helvetica, sans-serif;
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
	if(true)
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
	
	String strCollegeName = null;//I have to find the college offering course.
	String strAddlAwards  = WI.fillTextValue("accounting_division");//this is to be appended to Name.. for UC only, filed : FORM17_FORM18_TEMP_INFO.ACCOUNTING_DIVISION
	if(strAddlAwards.length() > 0) 
		strAddlAwards = "\""+strAddlAwards+"\"";//System.out.println(strAddlAwards);
	
	int iRowStartFr = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_start_fr"), "0"));
	int iRowCount   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_count"), "0"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"), "0"));
	String strPrintPage = WI.fillTextValue("print_");//"1" is print. 
	
	int iLastIndex = -1;
	
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
		//System.out.println("vPrintVal "+vPrintVal);
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
		<p align="center"> <font face="Geneva, Arial, Helvetica, sans-serif" size="3">
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


int iLevelID = 0;
Vector vStudInfo = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;
Vector vCompliedRequirement = null;
Vector vReqList = null;

Vector vMulRemark = null;
int iMulRemarkIndex = -1;

java.sql.ResultSet rs = null;
String strSQLQuery    = null;
///// extra condition for the selected courses
String strStudCourseToDisp = null; String strStudMajorToDisp = null;
boolean viewAll = true;
int iMaxCourseDisplay = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_course_disp"),"0"));
String[] strTok = null; Vector vCourseSelected = new Vector(); 

String strCollegeDean = null;
String strQuery = null;
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


String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};

String[] astrConvertSemUG  = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};
String[] astrConvertSemMED = {"SUMMER","Academic Year","Academic Year","Academic Year","Academic Year"};
String[] astrConvertSemMAS = {"SUMMER","FIRST TRIMESTER","SECOND TRIMESTER","THIRD TRIMESTER",""};

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
	//System.out.println("vStudInfo "+vStudInfo);
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		strCollegeName = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(5));
		//System.out.println("strCollegeName "+strCollegeName);
		if(strCollegeName != null)
			strCollegeName = strCollegeName.toUpperCase();
		
		strQuery = "select dean_name from college join course_offered on (course_offered.c_index = college.c_index) where course_index = "+(String)vStudInfo.elementAt(5);
		strCollegeDean = dbOP.getResultOfAQuery(strQuery, 0);
		//System.out.println("strCollegeDean "+strCollegeDean);
		if(strCollegeDean != null)
			strCollegeDean = strCollegeDean.toUpperCase();
		
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(12));
		//System.out.println("vAdditionalInfo "+vAdditionalInfo);
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
	}
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,WI.fillTextValue("stud_id"),(String)vStudInfo.elementAt(7),(String)vStudInfo.elementAt(8));
		//System.out.println("vFirstEnrl "+vFirstEnrl);
		if (vFirstEnrl != null) {
			vRetResult = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
											(String)vFirstEnrl.elementAt(2),false,false,true,true);
			//System.out.println("vRetResult "+vRetResult);			
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = cRequirement.getErrMsg();
		else
			vCompliedRequirement = (Vector)vRetResult.elementAt(1);
	  }
	  else 
	  	strErrMsg = cRequirement.getErrMsg();	
}

String strGetTuitionType = "select tution_type from stud_curriculum_hist join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) where user_index = "+vStudInfo.elementAt(12)+" and stud_curriculum_hist.is_valid = 1 and sy_from = ";

//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
//System.out.println("vForm17Info "+vForm17Info);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
//	System.out.println("strDegreeType : " + strDegreeType);
	if(vCourseSelected.size() > 0) {
		strTemp = "select degree_type from course_offered where course_index in ("+CommonUtil.convertVectorToCSV(vCourseSelected)+")";
		rs = dbOP.executeQuery(strTemp);
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
	//System.out.println("vEntranceData "+vEntranceData);
	request.setAttribute("course_ref", strCourseIndex);
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	//System.out.println("vGraduationData "+vGraduationData);
	if(vEntranceData == null || vGraduationData == null)
		strErrMsg = entranceGradData.getErrMsg();
		
	///apply condition here to remove the credit subject.
	repRegistrar.setGetCreditSubject(0);
	
	//System.out.println(strExtraCon);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true, strExtraCon);
	//System.out.println(vRetResult);
	
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);
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
		astrConvertSem[1] = "Academic Year";
		astrConvertSem[2] = "Academic Year";
		astrConvertSem[3] = "Academic Year";
		astrConvertSem[4] = "Academic Year";
}


if(vRetResult.toString().indexOf("hrs") > 0 && WI.fillTextValue("show_rle").compareTo("1") == 0)
	bolIsRLEHrs = true;

if(WI.fillTextValue("show_leclab").compareTo("1") == 0)	
	bolShowLecLabHr = true;
	
//System.out.println(vStudInfo);
//System.out.println(vMulRemark);


//get internship ifno.. 
Vector vInternshipInfo = repRegistrar.getInternshipInfo();
//System.out.println("vInternshipInfo "+vInternshipInfo);


String strMulRemarkAtEndOfSYTerm = null;//if there is any remark added after the end of SY/term of Student.. 

//check if caregiver.. 
if(strStudCourseToDisp != null && strStudCourseToDisp.toLowerCase().equals("caregiver course"))
	bolIsCareGiver = true;

int iIndexOf = 0;
boolean bolShowParenthesis = false;
if(WI.fillTextValue("show_parenthesis").length() > 0) 
	bolShowParenthesis = true;



//Record OTR Printing Information.
if(strPrintPage.equals("1")) {
	strSQLQuery = "select print_index from track_printing where date_printed = '"+WI.getTodaysDate()+"' and stud_index = "+
						(String)vStudInfo.elementAt(12)+" and print_module = 3";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery == null) {
		strSQLQuery = "insert into track_printing (stud_index, print_module, date_printed, printed_by, time_printed, note_) values ("+
						(String)vStudInfo.elementAt(12)+", 3, '"+WI.getTodaysDate()+"',"+(String)request.getSession(false).getAttribute("userIndex")+
						","+new java.util.Date().getTime()+", "+WI.getInsertValueForDB(WI.fillTextValue("addl_remark"), true, null) +")";
	}
	else {
		strSQLQuery = "update track_printing set printed_by = "+(String)request.getSession(false).getAttribute("userIndex")+
						",time_printed = "+new java.util.Date().getTime()+
						",note_ = "+WI.getInsertValueForDB(WI.fillTextValue("addl_remark"), true, null) +" where print_index = "+strSQLQuery;	
	}
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);

}

boolean bolShowPic = false;
if(WI.fillTextValue("show_pic").length() > 0)
	bolShowPic = true;


///get all transferee info.
Vector vCrossEnrollSYTerm = new Vector();
if(vStudInfo != null) {
	strSQLQuery = "select distinct sy_from, semester from g_sheet_final join stud_curriculum_hist on (stud_curriculum_hist.cur_hist_index = g_sheet_final.cur_hist_index) "+
				" where user_index_ = "+(String)vStudInfo.elementAt(12)+" and g_sheet_final.is_valid = 1 and CE_SCH_INDEX is not null";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next())
		vCrossEnrollSYTerm.addElement(rs.getString(1)+"-"+rs.getString(2));
	rs.close();
}	
%>

<body topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0">
<form action="otr_print_UC.jsp" method="post" name="form_">

<table width="100%" border="0" onClick="PrintNextPage();">
	<tr><td height="74px">&nbsp;</td></tr><!--102 is the correct height -->
</table>


<%if(vAdditionalInfo != null) {
if(bolShowPic){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td width="85%">
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						
						<td colspan="4" height="15px"><strong>PERSONAL INFORMATION:</strong></td>
					</tr>
					<tr>
						<td width="15%" height="15px">&nbsp;Name :</td>
						<td width="50%"><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,&nbsp;<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%> <%=strAddlAwards%></strong></td>
						<td width="15%" align="right">Student No. :</td>
						<td><%=WI.fillTextValue("stud_id").toUpperCase()%></td>
					</tr>
					<tr>
						
						<td height="15px">&nbsp;Place of Birth :</td>
						<td><%=WI.getStrValue(vAdditionalInfo.elementAt(2),"").toUpperCase()%></td>
						<td align="right">Date of Birth : </td>
						<td><%=WI.getStrValue(vAdditionalInfo.elementAt(1)).toUpperCase()%></td>
					</tr>
					<tr>
						
						<td height="15px">&nbsp;Home Address :</td>
						<td colspan='3'><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3)).toUpperCase()%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","").toUpperCase()%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","").toUpperCase()%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(7)," ","","").toUpperCase()%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","").toUpperCase()%></td>
					</tr>
				</table>
	
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td colspan="2" height="15px">
							<strong>PRELIMINARY EDUCATION:</strong>						</td>
						<td align="right">Gender :</td>
						<td><%=WI.getStrValue((String)vAdditionalInfo.elementAt(0)).toUpperCase()%></td>
					</tr>
					<tr>	
						<td width="30%" height="15px">&nbsp;Primary Grades Completed at</td>
						<td width="43%"><%
						if(vEntranceData != null)
							strTemp = WI.getStrValue(WI.getStrValue(vEntranceData.elementAt(14)).toUpperCase(),"&nbsp;");
							//strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(14)));
						else	
							strTemp = "&nbsp;";
						%> <%=strTemp%></td>
						<td width="8%" align="right">Year :</td>
						<td><%
						strTemp = "";
						if(vEntranceData != null) {
							//strTemp = WI.getStrValue(vEntranceData.elementAt(19));
							if(vEntranceData.elementAt(18) != null)
								strTemp = ((String)vEntranceData.elementAt(18)).toUpperCase();
								//if(strTemp != null && strTemp.length() > 0) 
									//strTemp = strTemp + " - " +(String)vEntranceData.elementAt(20);
								else
									strTemp = "&nbsp;";
									//strTemp = (String)vEntranceData.elementAt(20);
							
						}
						else	
							strTemp = "&nbsp;";
						%> <%=strTemp%></td>
					</tr>
					<tr>	
						<td height="15px">&nbsp;Intermediate  Grades Completed at</td>
						<td><%
						if(vEntranceData != null)
							strTemp = WI.getStrValue(WI.getStrValue(vEntranceData.elementAt(16)).toUpperCase(),"&nbsp;");
							//strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
						else	
							strTemp = "&nbsp;";
						%> <%=strTemp%></td>
						<td align="right">Year :</td>
						<td><%
						strTemp = "";
						if(vEntranceData != null) {
							//strTemp = WI.getStrValue(vEntranceData.elementAt(19));
							if(vEntranceData.elementAt(20) != null)
								strTemp = ((String)vEntranceData.elementAt(20)).toUpperCase();
								//if(strTemp != null && strTemp.length() > 0) 
									//strTemp = strTemp + " - " +(String)vEntranceData.elementAt(20);
								else
									strTemp = "&nbsp;";
									//strTemp = (String)vEntranceData.elementAt(20);
							
						}
						else	
							strTemp = "&nbsp;";
						%> <%=strTemp%></td>
					</tr>
					<tr>	
						<td height="15px">&nbsp;Secondary Grades Completed at</td>
						<td><%
						if(vEntranceData != null)
							strTemp = WI.getStrValue(WI.getStrValue(vEntranceData.elementAt(5)).toUpperCase(),"&nbsp;");
						else	
							strTemp = "&nbsp;";
						%> <%=strTemp%> </td>
						<td align="right">Year :</td>
						<td><%
						strTemp = "";
						if(vEntranceData != null) {
							//strTemp = WI.getStrValue(vEntranceData.elementAt(19));
							if(vEntranceData.elementAt(22) != null)
								strTemp = ((String)vEntranceData.elementAt(22)).toUpperCase();
								//if(strTemp != null && strTemp.length() > 0) 
									//strTemp = strTemp + " - " +(String)vEntranceData.elementAt(20);
							else
								strTemp = "&nbsp;";
									//strTemp = (String)vEntranceData.elementAt(20);
							
						}
						else	
							strTemp = "&nbsp;";
						%> <%=strTemp%></td>
					</tr>
					<tr>
					  <td height="15px" colspan="2"><strong>ENTRANCE CREDENTIALS:</strong></td>
					  <td align="right">&nbsp;</td>
					  <td>&nbsp;</td>
				  </tr>
					<tr>
					  <td height="15px">&nbsp;Date of Admission:</td>
					  <td height="15px">
					  <% if(vEntranceData != null) {%>
							<%=WI.getStrValue(WI.getStrValue((String)vEntranceData.elementAt(23)).toUpperCase(),"&nbsp;")%> 
						<%}else{%> &nbsp; <%}%></td>
					  <td align="right">&nbsp;</td>
					  <td>&nbsp;</td>
				  </tr>
					<tr>
					  <td height="15px">&nbsp;Entrance Data:</td>
					  <td height="15px" colspan="3"><%=WI.fillTextValue("entrance_data").toUpperCase()%></td>
				  </tr>
					<tr>
					  <td height="15px">&nbsp;Other Admission Credentials:</td>
					  <td height="15px" colspan="3"><%=WI.fillTextValue("entrance_data_other_uc")%></td>
				  </tr>
			</table>			</td>
			<td width="15%" valign="top">
				<img src="../../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt%>" width="142" height="142" border="1" align="top">			</td>
		</tr>
	</table>
<%}else{%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		
		<td colspan="4" height="15px"><strong>PERSONAL INFORMATION:</strong></td>
	</tr>
	<tr>
		<td width="15%" height="15px">&nbsp;Name :</td>
		<td width="50%"><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,&nbsp;<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%> <%=strAddlAwards%></strong></td>
		<td width="15%" align="right">Student No. :</td>
		<td><%=WI.fillTextValue("stud_id").toUpperCase()%></td>
	</tr>
	<tr>
		
		<td height="15px">&nbsp;Place of Birth :</td>
		<td><%=WI.getStrValue(vAdditionalInfo.elementAt(2),"").toUpperCase()%></td>
		<td align="right">Date of Birth : </td>
		<td><%=WI.getStrValue(vAdditionalInfo.elementAt(1)).toUpperCase()%></td>
	</tr>
	<tr>
		
		<td height="15px">&nbsp;Home Address :</td>
		<td colspan='3'><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3)).toUpperCase()%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","").toUpperCase()%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","").toUpperCase()%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(7)," ","","").toUpperCase()%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","").toUpperCase()%></td>
	</tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2" height="15px">
			<strong>PRELIMINARY EDUCATION:</strong>
		</td>
		<td align="right">Gender :</td>
		<td><%=WI.getStrValue((String)vAdditionalInfo.elementAt(0)).toUpperCase()%></td>
	</tr>
	<tr>	
		<td width="30%" height="15px">&nbsp;Primary Grades Completed at</td>
		<td width="43%"><%
		if(vEntranceData != null)
			strTemp = WI.getStrValue(WI.getStrValue(vEntranceData.elementAt(14)).toUpperCase(),"&nbsp;");
			//strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(14)));
		else	
			strTemp = "&nbsp;";
		%> <%=strTemp%></td>
		<td width="7%" align="right">Year :</td>
		<td><%
		strTemp = "";
		if(vEntranceData != null) {
			//strTemp = WI.getStrValue(vEntranceData.elementAt(19));
			if(vEntranceData.elementAt(18) != null)
				strTemp = ((String)vEntranceData.elementAt(18)).toUpperCase();
				//if(strTemp != null && strTemp.length() > 0) 
					//strTemp = strTemp + " - " +(String)vEntranceData.elementAt(20);
				else
					strTemp = "&nbsp;";
					//strTemp = (String)vEntranceData.elementAt(20);
			
		}
		else	
			strTemp = "&nbsp;";
		%> <%=strTemp%></td>
	</tr>
	<tr>	
		<td height="15px">&nbsp;Intermediate  Grades Completed at</td>
		<td><%
		if(vEntranceData != null)
			strTemp = WI.getStrValue(WI.getStrValue(vEntranceData.elementAt(16)).toUpperCase(),"&nbsp;");
			//strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
		else	
			strTemp = "&nbsp;";
		%> <%=strTemp%></td>
		<td align="right">Year :</td>
		<td><%
		strTemp = "";
		if(vEntranceData != null) {
			//strTemp = WI.getStrValue(vEntranceData.elementAt(19));
			if(vEntranceData.elementAt(20) != null)
				strTemp = ((String)vEntranceData.elementAt(20)).toUpperCase();
				//if(strTemp != null && strTemp.length() > 0) 
					//strTemp = strTemp + " - " +(String)vEntranceData.elementAt(20);
				else
					strTemp = "&nbsp;";
					//strTemp = (String)vEntranceData.elementAt(20);
			
		}
		else	
			strTemp = "&nbsp;";
		%> <%=strTemp%></td>
	</tr>
	<tr>	
		<td height="15px">&nbsp;Secondary Grades Completed at</td>
		<td><%
		if(vEntranceData != null)
			strTemp = WI.getStrValue(WI.getStrValue(vEntranceData.elementAt(5)).toUpperCase(),"&nbsp;");
		else	
			strTemp = "&nbsp;";
		%> <%=strTemp%> </td>
		<td align="right">Year :</td>
		<td><%
		strTemp = "";
		if(vEntranceData != null) {
			//strTemp = WI.getStrValue(vEntranceData.elementAt(19));
			if(vEntranceData.elementAt(22) != null)
				strTemp = ((String)vEntranceData.elementAt(22)).toUpperCase();
				//if(strTemp != null && strTemp.length() > 0) 
					//strTemp = strTemp + " - " +(String)vEntranceData.elementAt(20);
			else
				strTemp = "&nbsp;";
					//strTemp = (String)vEntranceData.elementAt(20);
			
		}
		else	
			strTemp = "&nbsp;";
		%> <%=strTemp%></td>
	</tr>
	
	</table>
<%}%>
<%if(!bolShowPic){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr><td colspan="2" height="15px"><strong>ENTRANCE CREDENTIALS:</strong></td></tr>
	<tr>	
		<td width="25%">&nbsp;Date of Admission:</td>
		<td>
		<% if(vEntranceData != null) {%>
			<%=WI.getStrValue(WI.getStrValue((String)vEntranceData.elementAt(23)).toUpperCase(),"&nbsp;")%> 
		<%}else{%> &nbsp; <%}%></td>	
	</tr>
	<tr>	
		<td height="15px">&nbsp;Entrance Data:</td>
		<td><%=WI.fillTextValue("entrance_data").toUpperCase()%></td>	
	</tr>
	<tr>	
		<td height="15px">&nbsp;Other Admission Credentials:</td>
		<td><%=WI.fillTextValue("entrance_data_other_uc")%></td><!--//WI.getStrValue((String)request.getSession(false).getAttribute("other_requirement"))-->	
	</tr>
	</table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td colspan="4" height="15px"><strong>GRADUATION DATA:</strong></td></tr>
<tr>	
	<td width="15%" height="15px">&nbsp;Degree/Title/Course: </td>
	<td colspan="3"><%=strStudCourseToDisp.toUpperCase()/**(String)vStudInfo.elementAt(7)**/%></td>
</tr>
<tr>	
	<td height="15px">&nbsp;Date of Graduation:</td>
	<%if(vGraduationData != null)
		strTemp = (String)vGraduationData.elementAt(8);
	  else
		strTemp = "";				  
	%>
	<td width="48%"><%=WI.getStrValue(strTemp).toUpperCase()%></td>
	<td width="17%" align="right">Year Graduated:</td>
	<%
	if(vGraduationData != null && vGraduationData.size()!=0)
		strTemp = WI.getStrValue(vGraduationData.elementAt(9));
	else	
		strTemp = "";
	%>
	<td width="20%"><%=WI.getStrValue(strTemp).toUpperCase()%></td>
</tr>
<tr>	
	<td height="15px">&nbsp;R.O.G No.:</td>
	<%
	if(vGraduationData != null && vGraduationData.size()!=0)
		strTemp = WI.getStrValue(vGraduationData.elementAt(6));
	else	
		strTemp = "";
	%>
	<td><%=WI.getStrValue(strTemp).toUpperCase()%></td>
	<td align="right">Date:</td>
	<%if(vGraduationData != null)
		strTemp = (String)vGraduationData.elementAt(7);
	  else
		strTemp = "";				  
	%>
	<td><%=WI.getStrValue(strTemp).toUpperCase()%></td>
</tr>
</table>
<%}%>
<br>















<table width="100%" border="0">
	<tr valign="top">
		<td width="135px" height="760px">&nbsp;</td>	  
	  <td>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">
			<!---------------    HEADER--                       -----------------------------   ------------------>
				<tr>
					<td width="21%">&nbsp;</td>
					<td width="71%">&nbsp;</td>
					<td width="5%">&nbsp;</td>					
					<td width="3%">&nbsp;</td>
				</tr>
			<!---- ---------------- END OF HEADER -------------------------------------------------->

<%if(vRetResult != null && vRetResult.size() > 0){

	int iNumWeeks = 0;
	if (WI.fillTextValue("weeks").length() > 0) 
		iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));

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

String strNextSem       = null;
String strNextSY		= null;

boolean bolNextNew = true;
boolean bolNewEntry = true;
boolean bolNewPrev =  true;

boolean bolNewPage = false;

boolean bolRowSpan2  = false; 
boolean bolInComment = false;

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
		((String)vRetResult.elementAt(i + 7)).compareTo((String)vRetResult.elementAt(i + 7 + 11)) == 0 && //sub name,
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

//System.out.println("strSchNameToDisp-11xx : "+strSchNameToDisp+ " strPrevSchName  : "+strPrevSchName+ " strSchoolName: "+strSchoolName); 

//strCurSYSem =
//System.out.println("vRetResult12 "+vRetResult.elementAt(i+12));
//System.out.println("vRetResult13 "+vRetResult.elementAt(i+13));
//System.out.println("vRetResult14 "+vRetResult.elementAt(i+14));
/*if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.	
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
			
			//bolNewEntry = true;
			//bolNewPrev = true;
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
}*/

/**
	1-2 : schoolyear
	3   : semester
	12-13 : schoolyear
	14  : semester
*/
if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.
	//System.out.println(vRetResult.elementAt(i+11));
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
		
						strSQLQuery = strGetTuitionType + (String)vRetResult.elementAt(i+ 1)+" and semester = "+(String)vRetResult.elementAt(i+ 3);
						strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery,0);
						if(strSQLQuery != null && strSQLQuery.equals("1")) {
							astrConvertSem[1] = "FIRST SEMESTER";
							astrConvertSem[2] = "SECOND SEMESTER";
							astrConvertSem[3] = "THIRD SEMESTER";
						}
						else {
							astrConvertSem[1] = "FIRST TRIMESTER";
							astrConvertSem[2] = "SECOND TRIMESTER";
							astrConvertSem[3] = "THIRD TRIMESTER";
						}
		
		
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+" <br>"+
					(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
		
		strCurSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+3))];
		strCurSY  = (String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);
		//strNextSem 
		//strNextSY
		//System.out.println(vRetResult.elementAt(i+11));
		if (i+11 < vRetResult.size()) {
			if(((String)vRetResult.elementAt(i+ 14)).length() == 1)		 
				strNextSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 14))];
			else	
				strNextSem = (String)vRetResult.elementAt(i+ 14);
			strNextSY  = (String)vRetResult.elementAt(i+ 12)+"-"+(String)vRetResult.elementAt(i+ 13);
			//System.out.println("xxxx");
		}
		else{
			strNextSem = null;
			strNextSY  = null;
			}
	}
	else {
		strCurSYSem = (String)vRetResult.elementAt(i+ 3)+" <br>"+(String)vRetResult.elementAt(i+ 1)+" - "+
							(String)vRetResult.elementAt(i+ 2);
		
		strCurSem = (String)vRetResult.elementAt(i+ 3);
		strCurSY  = (String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);
		
		///transferee
		if(strCurSem.startsWith("1ST"))
			strCurSem = "FIRST"+strCurSem.substring(3);
		if(strCurSem.startsWith("2ND"))
			strCurSem = "SECOND"+strCurSem.substring(3);
		if(strCurSem.startsWith("3RD"))
			strCurSem = "THIRD"+strCurSem.substring(3);
		strCurSem = strCurSem.toUpperCase();			
							
		if (i+11 < vRetResult.size())	
		{
			if(((String)vRetResult.elementAt(i+ 14)).length() == 1)		 
				strNextSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 14))];
			else	
				strNextSem = (String)vRetResult.elementAt(i+ 14);
		 strNextSY  = (String)vRetResult.elementAt(i+ 12)+"-"+(String)vRetResult.elementAt(i+ 13);
		 //System.out.println("yyyyy");
		}
		else{
			strNextSem = null;
			strNextSY  = null;
			}
	}
	
	if(strCurSem != null && strCurSY != null) {		
		if(strPrevSY == null && strPrevSem == null) {
		//System.out.println("aa");
			strPrevSY = strCurSY;
			strPrevSem = strCurSem;
			
			strSYToDisp = strCurSY;
			strSemToDisp = strCurSem;
			
			bolNewEntry = true;
			bolNewPrev = true;
			
		if (strNextSem != null && strNextSY != null)
			{
				if (strCurSem.equals(strNextSem) && strCurSY.equals(strNextSY))
					bolNextNew = false;
				else
					bolNextNew = true;
			}
		}
		
		else if(strPrevSY.compareTo(strCurSY) ==0 && strPrevSem.compareTo(strCurSem)==0) {
			//System.out.println("bb");
			//strSYSemToDisp = null;
			strSYToDisp = null;
			strSemToDisp = null;
			
		if (bolNewEntry)
			bolNewPrev = true;
		else
			bolNewPrev = false;
			bolNewEntry = false;
			if (strNextSem != null && strNextSY != null)
			{
				if (strCurSem.equals(strNextSem) && strCurSY.equals(strNextSY))
					bolNextNew = false;
				else
					bolNextNew = true;
			}
		}
		
		else {//itis having a new school name.
			//System.out.println("cc");
			strPrevSY = strCurSY;
			strPrevSem = strCurSem;
			
			strSYToDisp = strPrevSY;
			strSemToDisp = strPrevSem;
			
			bolNewEntry = true;
			bolNewPrev = true;
			
			if (strNextSem != null && strNextSY != null)
			{
				if (strCurSem.equals(strNextSem) && strCurSY.equals(strNextSY))
					bolNextNew = false;
				else
					bolNextNew = true;
			}
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
	//cross enrolled.. ==REMOVED..
	if(vRetResult.elementAt(i) != null && bolIsSchNameNull && vCrossEnrollSYTerm.size() > 0) {//display will be schooo name<br>sy/term (cross enrolled)
	//	strSYToDisp = null;
	//	strSemToDisp = null;	
		//System.out.println((String)vRetResult.elementAt(i + 1) +"-"+(String)vRetResult.elementAt(i + 3));
		if(vCrossEnrollSYTerm.indexOf((String)vRetResult.elementAt(i + 1) +"-"+(String)vRetResult.elementAt(i + 3)) > -1)	
			strSchNameToDisp = strSchNameToDisp + " - W/PERMIT FROM UC";//+" (CROSS ENROLLED)";
	}

 //Very important here, it print <!-- if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){
 	strHideRowLHS = "<!--"; //I have to do this so i will know if I am priting data or not%>
  <%=strHideRowLHS%> 
  <%}else {
  	++iRowsPrinted;
	strHideRowLHS = "";
//	System.out.println("iRowsPrinted 1:" + iRowsPrinted );
	}//actual number of rows printed. 
//
if(vMulRemark != null && vMulRemark.size() > 0 ) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i + 11 && i + 11 >= vRetResult.size()) {
		vMulRemark.removeElementAt(0);
		strMulRemarkAtEndOfSYTerm = ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>");
		strTemp = null;
	}
	
	
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		strTemp = ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>");
	if (strTemp != null)
		strTemp = strTemp.toUpperCase();
	%>
  <tr bgcolor="#FFFFFF">
  	<td width="2%">&nbsp;</td> 
    <td height="18" colspan="4"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
  </tr>
  
  
  <%}//end of if(iMulRemarkIndex == i)
}//end of if(vMulRemark != null && vMulRemark.size() > 0) 

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
				((String)vRetResult.elementAt(i + 7)).compareTo((String)vRetResult.elementAt(i + 7 + 11)) == 0 && //sub name,
	    		((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
				((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
				WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
					strInternshipInfo = (String)vInternshipInfo.remove(1);
					vInternshipInfo.remove(0);
				}
		}
}

%>

<%  if(vEntranceData != null &&  (String)vEntranceData.elementAt(12) != null
		&& iPageNumber == 1 && !bolPrinted){
		bolPrinted = true;
		//if last page, i have to show the remark.
		// iMaxRowToDisp = iMaxRowToDisp - 2;
		
	int iTemp = 1;
	 strTemp = WI.getStrValue((String)vEntranceData.elementAt(12));
	while((iIndexOf = strTemp.indexOf("<br>",iIndexOf + 1)) != -1)
		++iTemp;

	if (iTemp == 1 && (strTemp.length()/100 > 0)) {
		iTemp = strTemp.length()/100;
		if (strTemp.length()%100 > 0)
			iTemp +=1;
	}
	 iRowsPrinted += iTemp; 
// 	System.out.println("iRowsPrinted 4:" + iRowsPrinted );
%>
  <tr>
  	<td width="2%">&nbsp;</td> 
    <td height="17" colspan="4"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
  </tr>
<%}%>  

<%if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
//	System.out.println("iRowsPrinted 3:" + iRowsPrinted + "; strSchNameToDisp"+ strSchNameToDisp );		
		//do not keep extra line for school name.%>
  <tr bgcolor="#FFFFFF">     
    <td height="17" colspan="5"> <strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strSchNameToDisp.toUpperCase()%></label>
    </strong></td>
  </tr>
  <%strPrevSchName = strSchNameToDisp;
 } // if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp))))



//System.out.println("bolNewEntry "+bolNewEntry+" bolNextNew "+bolNextNew);
if (bolNewEntry && bolNextNew) {
	//System.out.println("a");
//if(strSYToDisp != null && strSemToDisp != null)
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
 
	if(bolIsCareGiver && vEntranceData.elementAt(27) != null)
		strTemp = strSemToDisp +" "+ ((String)vEntranceData.elementAt(27)).toUpperCase();
		//strTemp = ((String)vEntranceData.elementAt(27)).toUpperCase()
	else {
		strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp,"",":","");
		if(strTemp.startsWith("SUMMER") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(5),"",":","");
		else if(strTemp.startsWith("SPRING") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
		else if(strTemp.startsWith("WINTER") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
		else if(strTemp.startsWith("FALL") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
	}

	%>	  
  <tr bgcolor="#FFFFFF">	   	
  	<td colspan="5"><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></strong>
	</td>
  </tr>  
  
<%}else if (bolNewEntry && !bolNextNew && iCurrentRow == iRowStartFr){
	//System.out.println("b");
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
 
	if(bolIsCareGiver && vEntranceData.elementAt(27) != null)
		strTemp = strSemToDisp +" "+ ((String)vEntranceData.elementAt(27)).toUpperCase();
		//strTemp = ((String)vEntranceData.elementAt(27)).toUpperCase()
	else {
		strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp,"",":","");
		if(strTemp.startsWith("SUMMER") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(5),"",":","");
		else if(strTemp.startsWith("SPRING") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
		else if(strTemp.startsWith("WINTER") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
		else if(strTemp.startsWith("FALL") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
	}

	%>	  
  <tr bgcolor="#FFFFFF">	   	
  	<td colspan="5"><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></strong>
	</td>
  </tr> 
  
<%}else if (!bolNewEntry && !bolNextNew && iCurrentRow == iRowStartFr){
	//System.out.println("b");
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
 
	if(bolIsCareGiver && vEntranceData.elementAt(27) != null)
		strTemp = strPrevSem +" "+ ((String)vEntranceData.elementAt(27)).toUpperCase();
		//strTemp = ((String)vEntranceData.elementAt(27)).toUpperCase()
	else {
		strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp,"",":","");
		if(strTemp.startsWith("SUMMER") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(5),"",":","");
		else if(strTemp.startsWith("SPRING") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
		else if(strTemp.startsWith("WINTER") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
		else if(strTemp.startsWith("FALL") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
	}
	//else
	//	strTemp = WI.getStrValue(strPrevSem,"",",","") +" "+ WI.getStrValue(strPrevSY,"",":","");

	%>	  
  <tr bgcolor="#FFFFFF">	   	
  	<td colspan="5"><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></strong>
	</td>
  </tr>   
  
<%}else if (bolNewEntry && !bolNextNew){
	//System.out.println("c");
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
 
	if(bolIsCareGiver && vEntranceData.elementAt(27) != null)
		strTemp = strSemToDisp +" "+ ((String)vEntranceData.elementAt(27)).toUpperCase();
		//strTemp = ((String)vEntranceData.elementAt(27)).toUpperCase()
	else {
		strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp,"",":","");
		if(strTemp.startsWith("SUMMER") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(5),"",":","");
		else if(strTemp.startsWith("SPRING") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
		else if(strTemp.startsWith("WINTER") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
		else if(strTemp.startsWith("FALL") && WI.getStrValue(strSYToDisp).indexOf("-") > -1)
			strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp.substring(0,4),"",":","");
	}
	//else
	//	strTemp = WI.getStrValue(strSemToDisp,"",",","") +" "+ WI.getStrValue(strSYToDisp,"",":","");

	%>	  
  <tr bgcolor="#FFFFFF">	   	
  	<td colspan="5"><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></strong>
	</td>
  </tr>  
<%}

strGrade = WI.getStrValue(strGrade);

if(strGrade.equals("on going")) {
	strGrade = "IP";
	if(strCE != null)
		strCE = "("+strCE+")";
	else	
		strCE = "";
}
else if(strGrade.compareToIgnoreCase("IP") == 0) {
	strGrade = "IP";
	if(strCE != null)
		strCE = "("+strCE+")";
	else	
		strCE = "";
}
/*else {
	if(strGrade.indexOf(".") > -1 && strGrade.length() == 3) 
		strGrade = strGrade + "0";
}*/
//System.out.println(strCE);
if(bolIsCareGiver && strCE.length() > 0) 
	strCE = strCE + "hrs";
//if(strCE.length() > 0 && strCE.indexOf(".") == -1)
//	strCE = strCE + ".0";

//I have to format if sub_code = - , ce = - and grade = -
if(WI.getStrValue(vRetResult.elementAt(i + 6)).equals("-") && strGrade.equals("-") && strCE.equals("-")) {
	strTemp = "<pre>"+WI.getStrValue(vRetResult.elementAt(i + 7))+"</pre>";
	//System.out.println(strTemp);
	vRetResult.setElementAt(strTemp, i + 7);
	//strTemp = ConversionTable.replaceString(strTemp, "    ", "&nbsp;&nbsp;&nbsp;&nbsp;");
	//strTemp = ConversionTable.replaceString(strTemp, "   ", "&nbsp;&nbsp;&nbsp;");
	//strTemp = ConversionTable.replaceString(strTemp, "   ", "&nbsp;&nbsp;");
	//System.out.println(strTemp);
}



strTemp = WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;");
if(!bolShowParenthesis) {
	iIndexOf = strTemp.indexOf("(");
	if(iIndexOf > -1)
		strTemp = strTemp.substring(0, iIndexOf);
}
if(strGrade.equals("NG"))
	strCE = "-";
else if(strGrade.equals("-")) {
	strGrade = "&nbsp;";
	strCE = "&nbsp;";
}
else if(strCE != null && strCE.length() > 0 && strCE.indexOf(".") > -1 && (strCE.endsWith(".0") || strCE.endsWith(".00")))
	strCE = strCE.substring(0, strCE.indexOf("."));

if(strTemp.equals("-") || strTemp.length() == 0)
	strTemp = "&nbsp;";
else
	strTemp = strTemp.toUpperCase();
%>
	
  <tr bgcolor="#FFFFFF">      
	<td height="14">&nbsp;<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>  
    <td >
		<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td width="2%">&nbsp;</td><td>	
			<%=WI.getStrValue(WI.getStrValue(vRetResult.elementAt(i + 7)).toUpperCase(),"&nbsp;")%>
		</td></tr></table>
	</td>
    <td align="left"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strGrade%></label></td>	
    <td align="right"><%=strCE%></td>
  </tr>

	


  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop
  %>
  
<%if (iLastPage == 1){%>    	
  	<tr><td colspan="5" align="center">END OF TRANSCRIPT</td></tr>  
<%}else{%>
	<tr><td colspan="5" align="center" valign="bottom">PLEASE TURN TO NEXT PAGE</td></tr>
  	<tr><td colspan="4" align="center" valign="top">***** Page <%=iPageNumber%> ****</td></tr>
<%}%>

<%}//only if student is having grade infromation.%>

		</table><!------------ END OF TABLE INSIDE TD ------------------>		
		
	  </td>		
	</tr>
</table>

<table width="100%" border="0">
<tr><td colspan="3"><font size="2"><%=WI.getStrValue(WI.fillTextValue("addl_remark").toUpperCase(), "&nbsp;")%></font></td></tr>
<tr><td colspan="3">&nbsp;</td></tr>
<tr>
	<td colspan="5">
		<table width="100%" border="0">
			<tr>
				<td width="2%">&nbsp;</td>
				<td align="center" class="" width="40%"><strong><font size="2"><%=WI.fillTextValue("registrar_name").toUpperCase()%></font></strong></td>
				<td width="6%">&nbsp;</td>	
				<%
					
				%>			
				<td align="center" class="" width="40%"><strong><font size="2"><%=WI.getStrValue(strCollegeDean)%></font></strong></td>				
				<td width="2%">&nbsp;</td>
			</tr>
			<tr>
				<td width="2%">&nbsp;</td>
				<td align="center" class="thinborderTOP"><font size="2">REGISTRAR</font></td>
				<td width="6%">&nbsp;</td>
				<td align="center" class="thinborderTOP"><font size="2">COLLEGE DEAN</font></td>
				<td width="2%">&nbsp;</td>
			</tr>
		</table>	
	</td>	
</tr>

<tr>
	<td width="40%" align="center" valign="bottom"><%=WI.fillTextValue("prep_by1").toUpperCase()%></td>
	<td width="40%" align="center" valign="bottom"><%=WI.fillTextValue("check_by1").toUpperCase()%></td>
	<td width="20%" align="right" valign="bottom"><%=WI.getTodaysDate(1)%>&nbsp;&nbsp;&nbsp;</td>
</tr>

<!--
<tr><td colspan="3"><font size="1"><%=WI.getTodaysDateTime()%></font></td></tr>
-->
</table>







<%if(strPrintPage.compareTo("1") == 0){%>
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
	//document.form_.prevSYSemToDisplay.value = '1' ;
	document.form_.submit();
	<%}else{%>
	alert("End of printing");
	<%}%>
}
</script>
<input type="hidden" name="prevSYSemToDisplay" value="<%=WI.fillTextValue("prevSYSemToDisplay")%>" />
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