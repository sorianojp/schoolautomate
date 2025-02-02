<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>OTR</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

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
	
	TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
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
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
	boolean bolLP = strSchCode.startsWith("UPH01");
	//boolean bolMolino = strSchCode.startsWith("UPH03");
	//boolean bolCalamba = strSchCode.startsWith("UPH04");

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = null;
	
	String strCollegeName = null;//I have to find the college offering course.
	
	int iRowStartFr = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_start_fr"), "0"));
	int iRowCount   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_count"), "0"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"), "0"));
	String strPrintPage = WI.fillTextValue("print_");//"1" is print. 
	
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_page_to_disp"), "0"));
	
	int iPageNumber = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_number"), "0"));
	String strTotalPageNumber = Integer.toString(Integer.parseInt(WI.fillTextValue("total_page"))+1);

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

String[] astrConvertSemUG  = {"SUMMER","1ST SEMESTER","2ND SEMESTER","3RD SEMESTER","4TH SEMESTER"};
String[] astrConvertSemMED = {"SUMMER","Academic Year","Academic Year","Academic Year","Academic Year"};
String[] astrConvertSemMAS = {"SUMMER","1ST TRIMESTER","2ND TRIMESTER","3RD TRIMESTER",""};

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
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(12));
		
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
	}
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,WI.fillTextValue("stud_id"),
														(String)vStudInfo.elementAt(7),
												(String)vStudInfo.elementAt(8));
												
	//System.out.println("vFirstEnrl "+vFirstEnrl);
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
		
		//System.out.println("strErrMsg "+strErrMsg);
}

//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
//System.out.println("vForm17Info : " + vForm17Info);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
	//System.out.println("strDegreeType : " + strDegreeType);
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
	//System.out.println("vEntranceData "+vEntranceData);
	
	request.setAttribute("course_ref", strCourseIndex);
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	//System.out.println("vGraduationData "+vGraduationData);
	if(vEntranceData == null || vGraduationData == null)
		strErrMsg = entranceGradData.getErrMsg();
		
		
	//System.out.println(strExtraCon);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true, strExtraCon);
	
	//System.out.println("vRetResult "+vRetResult);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);

	if (strDegreeType != null && strDegreeType.equals("1")) {//masteral
		astrConvertSem[0] = "Summer";
		astrConvertSem[1] = "1st Semester";
		astrConvertSem[2] = "2nd Semester";
		astrConvertSem[3] = "3rd Semester";
		astrConvertSem[4] = "";
	}//System.out.println(vRetResult);
}
String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);

boolean bolIsRLEHrs = false;
boolean bolShowLecLabHr = false; 
String[] astrLecLabHr = null;//gets lec/lab hour information.
String strRLEHrs    = null;
String strCE        = null;

boolean bolIsMedTOR = strDegreeType.equals("2");
if(bolIsMedTOR) {
		astrConvertSem[0] = "SUMMER";
		astrConvertSem[1] = "Academic Year";
		astrConvertSem[2] = "Academic Year";
		astrConvertSem[3] = "Academic Year";
		astrConvertSem[4] = "Academic Year";
}


if(vRetResult != null && vRetResult.size() > 0 && vRetResult.toString().indexOf("hrs") > 0 && WI.fillTextValue("show_rle").compareTo("1") == 0)
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
	
boolean bolIsOldGrading = true;
String strSQLQuery = "select count(*) from stud_curriculum_hist where is_valid = 1 and sy_from < 2012 and user_index = "+
		(String)vStudInfo.elementAt(12);
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery.equals("0"))
	bolIsOldGrading = false;
%>

<body topmargin="0" bottommargin='0'>
<form action="./otr_print_UPHSD.jsp" method="post" name="form_">

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  
</table>


<% if(vAdditionalInfo != null && iPageNumber == 1) {%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0"  onClick="PrintNextPage();">
		<tr> 
		    <td height="135" colspan="5">&nbsp;</td>    
  		</tr> 
		<tr>
			<td width="5%">&nbsp;</td>
			<td colspan="2"><font size="2"><strong>PERSONAL INFORMATION</strong></font></td>
		</tr>

		<tr>
			<td width="5%">&nbsp;</td>
			<td width="20%">Student Name</td>
			<td><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
			<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%>
			<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
		</tr>


		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">ID Number</td>
			<td><%=WI.fillTextValue("stud_id").toUpperCase()%></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">Date of Birth</td>
			<td><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">Place of Birth</td>
			<td><%=WI.getStrValue((String)vAdditionalInfo.elementAt(2)).toUpperCase()%></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">Gender</td>
			<td><%=WI.getStrValue((String)vAdditionalInfo.elementAt(0)).toUpperCase()%></td>
		</tr>
		<tr>			
			<td width="5%">&nbsp;</td>
			<td width="15%">Religion</td>
			<%
				strTemp = (String)vStudInfo.elementAt(12);
				strTemp = dbOP.mapOneToOther("INFO_PERSONAL","USER_INDEX",""+strTemp+"","RELIGION","");				
			%>
			
			<td><%=WI.getStrValue(strTemp).toUpperCase()%></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">Citizenship</td>
			<td><%=WI.getStrValue((String)vAdditionalInfo.elementAt(11)).toUpperCase()%></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">Parent/Guardian</td>
			<td><%=WI.getStrValue(WI.getStrValue(vAdditionalInfo.elementAt(9)).toUpperCase(),WI.getStrValue(vAdditionalInfo.elementAt(8)).toUpperCase())%></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">Address</td>
			<td>
			<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3)).toUpperCase()%>
			<%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","").toUpperCase()%>
			<%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","").toUpperCase()%>			
			<%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","").toUpperCase()%>
			<%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"","","").toUpperCase()%>
			</td>
		</tr>
		<tr><td height="15" colspan="5">&nbsp;</td></tr>
	
	</table>
	
	
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
		<tr>
			<td width="5%">&nbsp;</td>
			<td colspan="4"><font size="2"><strong>PRELIMINARY EDUCATION</strong></font></td>
		</tr>

		<tr>
			<td width="5%">&nbsp;</td>
			<td width="20%">Elementary</td>
			<%
			if(vEntranceData != null)
				strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
			else	
				strTemp = "&nbsp;";
			%>
			<td width="44%"><%=strTemp.toUpperCase()%></td>
			<td width="8%">Year</td>
			<%
			strTemp = "";
			if(vEntranceData != null) {
				strTemp = WI.getStrValue(vEntranceData.elementAt(17));
				if(vEntranceData.elementAt(20) != null) {
					if(strTemp != null && strTemp.length() > 0) 
						strTemp = strTemp;
					else
						strTemp = (String)vEntranceData.elementAt(18);
				}
			}
			%> 
			
		  <td width="23%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="20%">High School</td>
			<%
				if(vEntranceData != null)
					strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");
				else	
					strTemp = "&nbsp;";
			%> 
			<td><%=strTemp.toUpperCase()%> </td>
			<td>Year</td>
			<%
			strTemp = "";
			if(vEntranceData != null) {
				strTemp = WI.getStrValue(vEntranceData.elementAt(19));
				if(vEntranceData.elementAt(22) != null) {
					if(strTemp != null && strTemp.length() > 0) 
						strTemp = strTemp;
					else
						strTemp = (String)vEntranceData.elementAt(20);
				}
			}
			else	
				strTemp = "&nbsp;";
			%>
			
			<td> <%=strTemp%></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="20%">School Last Attended</td>
			<% if (vEntranceData != null && vEntranceData.size()>0){
				strTemp = (String)vEntranceData.elementAt(7);
				if (strTemp == null) 
					strTemp = (String)vEntranceData.elementAt(5);
			   }
			%>
			
			<td><%=WI.getStrValue(strTemp.toUpperCase())%></td>
			<td>Year</td>			
			<td>
			<% if(vEntranceData != null) {%>
		  		<%=WI.getStrValue((String)vEntranceData.elementAt(21))%> 

			<%}%></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="20%">Admission Credential</td>
			<%strTemp = WI.fillTextValue("entrance_data");%> 
			<td colspan="3"><%=strTemp.toUpperCase()%> </td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="20%">Date of Admission</td>
		  <td colspan="3">
			<%if(vEntranceData != null) {%>
				<%=WI.getStrValue((String)vEntranceData.elementAt(23),"&nbsp;")%> 
			<%}else{%> &nbsp; <%}%></td>
		</tr>	
		<tr><td height="15" colspan="5">&nbsp;</td></tr>
	</table>
	
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
		<tr>
			<td width="5%">&nbsp;</td>
			<td colspan="2"><font size="2"><strong>GRADUATION DATA</strong></font></td>
		</tr>

		<tr>
			<td width="5%">&nbsp;</td>
			<td width="20%">College</td>
			<%
				if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
					strTemp = dbOP.mapOneToOther("course_offered join college on " + 
												 "(course_offered.c_index = college.c_Index)",
												 "course_name", "'" + (String)vStudInfo.elementAt(7) +"'",
												 "c_name", " and course_offered.is_del = 0" +
												 " and college.is_del= 0");
					if (strTemp == null) 
						strTemp ="&nbsp;";
				}else{
					strTemp = "&nbsp;";
				}
			%>
			<td><%=strTemp.toUpperCase()%></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">Degree/Title/Course</td>
			<td><%=((String)vStudInfo.elementAt(7)).toUpperCase()%><%=WI.getStrValue((String)vStudInfo.elementAt(8), " major in ", "","").toUpperCase()%></td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">Date of Graduation</td>
			<%
					if(vGraduationData != null)
						strTemp = WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
					 else
						strTemp = "N/A";				%>
    		
			<td><%=strTemp%></td>
		</tr>
			<%
				strTemp = null;
				if(vGraduationData != null)
					strTemp = (String)vGraduationData.elementAt(6);				
				strTemp = WI.getStrValue(WI.getStrValue(strTemp).toUpperCase(),"N/A");
			%>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">S.O. Number</td>
			<td><%=strTemp%></td>
		</tr>
			<%
				strTemp = null;
				if(vGraduationData != null)
					strTemp = (String)vGraduationData.elementAt(7);				
				strTemp = WI.getStrValue(strTemp,"N/A");
			%>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">Date Issued</td>
			<td><%=strTemp%></td>
		</tr>	
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="15%">Remarks</td>
			<td><strong><%=WI.getStrValue(WI.fillTextValue("addl_remark").toUpperCase(),"","","")%></strong></td>
		</tr>
		<tr><td height="15" colspan="5">&nbsp;</td></tr>	
	</table>
	
<%if(bolIsOldGrading){%>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
		<tr>
			<td width="5%" valign="top">&nbsp;</td>
			<td colspan="9" style="border-top:solid 2px #000000;">&nbsp;</td></tr>		
		<tr>
			<td width="5%">&nbsp;</td>
			<td align="center" colspan="6"><strong>GRADING SYSTEM</strong></td></tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td colspan="8">One unit of credit is equivalent to 18 hours of lecture or 54 hours of laboratory for the period of a complete term.</td></tr>
		
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="8%">Grade</td>
			<td width="12%">Percentage</td>
			<td width="16%">Description</td>
			<td width="10%">Grade</td>
			<td width="15%">Percentage</td>
			<td>Description</td>
		</tr>
		
		<tr><td width="5%">&nbsp;</td>
			<td>1.00</td>
			<td>95-100</td>
			<td>Excellent</td>
			<td>2.75</td>
			<td>78-79</td>
			<td>Fairly Satisfactory</td>
		</tr>
		
		<tr><td width="5%">&nbsp;</td>
			<td>1.25</td>
			<td>92-94</td>
			<td>Superior</td>
			<td>3.00</td>
			<td>75-77</td>
			<td>Passing</td>
		</tr>
		
		<tr><td width="5%">&nbsp;</td>
			<td>1.50</td>
			<td>90-91</td>
			<td>Very Good</td>
			<td>5.00</td>
			<td>Below 75</td>
			<td>Failure</td>
		</tr>
		
		<tr><td width="5%">&nbsp;</td>
			<td>1.75</td>
			<td>88-89</td>
			<td>Good</td>
			<td>OD</td>
			<td>&nbsp;</td>
			<td>OFFICIALLY DROPPED</td>
		</tr>
		
		<tr><td width="5%">&nbsp;</td>
			<td>2.00</td>
			<td>85-87</td>
			<td>Meritorious</td>
			<td>UD</td>
			<td>&nbsp;</td>
			<td>UNOFFICIALLY DROPPED</td>
		</tr>
		
		<tr><td width="5%">&nbsp;</td>
			<td>2.25</td>
			<td>82-84</td>
			<td>Very Satisfactory</td>
			<td>NC</td>
			<td>&nbsp;</td>
			<td>NO CREDIT</td>
		</tr>
		
		<tr><td width="5%">&nbsp;</td>
			<td>2.50</td>
			<td>80-81</td>
			<td>SATISFACTORY</td>
			<td>FA</td>
			<td>&nbsp;</td>
			<td>FAILURE DUE TO EXCESSIVE ABSENCES</td>
		</tr>		
		<tr><td width="5%" valign="bottom">&nbsp;</td><td  colspan="9" style="border-bottom:solid 2px #000000;">&nbsp;</td></tr>
	</table>
<%}else{%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
	
			<tr>
				<td width="5%" valign="top">&nbsp;</td>
				<td colspan="9" style="border-top:solid 2px #000000;">&nbsp;</td></tr>
			<tr>
				<td width="5%">&nbsp;</td>
				<td align="center" colspan="6"><strong>GRADING SYSTEM</strong></td></tr>
			<tr>
				<td width="5%">&nbsp;</td>
				<td colspan="8">One unit of credit is equivalent to 18 hours of lecture or 54 hours of laboratory for the period of a complete term.</td></tr>
	
	
			<tr>
				<td width="5%">&nbsp;</td>
				<td width="8%">Grade</td>
				<td width="12%">Percentage</td>
				<td width="16%">Description</td>
				<td width="10%">Grade</td>
				<td width="15%">Percentage</td>
	
				<td>Description</td>
			</tr>
	
			<tr><td width="5%">&nbsp;</td>
				<td>1.00</td>
				<td>99-100</td>
				<td>Excellent</td>
				<td>2.75</td>
	
				<td>78-80</td>
				<td>Fairly Satisfactory</td>
			</tr>
	
			<tr><td width="5%">&nbsp;</td>
				<td>1.25</td>
				<td>96-98</td>
				<td>Superior</td>
	
				<td>3.00</td>
				<td>75-77</td>
				<td>Passing</td>
			</tr>
	
			<tr><td width="5%">&nbsp;</td>
				<td>1.50</td>
				<td>93-95</td>
	
				<td>Very Good</td>
				<td>5.00</td>
				<td>Below 75</td>
				<td>Failure</td>
			</tr>
	
			<tr><td width="5%">&nbsp;</td>
				<td>1.75</td>
	
				<td>90-92</td>
				<td>Good</td>
				<td>OD</td>
				<td>&nbsp;</td>
				<td>OFFICIALLY DROPPED</td>
			</tr>
	
			<tr><td width="5%">&nbsp;</td>
	
				<td>2.00</td>
				<td>87-89</td>
				<td>Meritorious</td>
				<td>UD</td>
				<td>&nbsp;</td>
				<td>UNOFFICIALLY DROPPED</td>
	
			</tr>
	
			<tr><td width="5%">&nbsp;</td>
				<td>2.25</td>
				<td>84-86</td>
				<td>Very Satisfactory</td>
				<td>NC</td>
				<td>&nbsp;</td>
	
				<td>NO CREDIT</td>
			</tr>
	
			<tr><td width="5%">&nbsp;</td>
				<td>2.50</td>
				<td>81-83</td>
				<td>SATISFACTORY</td>
				<td>FA</td>
	
				<td>&nbsp;</td>
				<td>FAILURE DUE TO EXCESSIVE ABSENCES</td>
			</tr>
			<tr><td width="5%" valign="bottom">&nbsp;</td><td  colspan="9" style="border-bottom:solid 2px #000000;">&nbsp;</td></tr>
		</table>
<%}%>
	
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
		<tr>
			<td width="5%">&nbsp;</td>
			<td height="15" width="20%">&nbsp;</td>
			<td>&nbsp;</td>
			<td width="20%">&nbsp;</td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>	
			<td width="20%">&nbsp;</td>	
			<td align="center" height="25"><strong>C E R T I F I C A T I O N</strong></td>
			<td width="20%">&nbsp;</td>
		</tr>
		
		<TR>		
			<td width="5%">&nbsp;</td>
			<td width="20%">&nbsp;</td>
			<TD align="center" height="25">I HEREBY CERTIFY THAT THE FOREGOING RECORDS OF</TD>
			<td width="20%">&nbsp;</td>
		</TR>
		
		<tr>		
			<td width="5%">&nbsp;</td>
			<td width="20%">&nbsp;</td>
			<td align="center" height="30"><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
			<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%>
			<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
			<td width="20%">&nbsp;</td>
		</tr>
		
		<tr>		
			<td width="5%">&nbsp;</td>
			<td width="20%">&nbsp;</td>
			<td align="justify" height="25">A STUDENT OF THIS UNIVERSITY, HAVE BEEN VERIFIED BY ME AND
			THAT THE TRUE COPIES OF THE OFFICIAL RECORDS SUBSTANTIATING THE SAME ARE KEPT IN THE FILES OF THE UNIVERSITY.</td>
			<td width="20%">&nbsp;</td>
		</tr>
	</table>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
		<tr>
			<td height="40" width="5%">&nbsp;</td>
			<td colspan="3" valign="bottom" align="center" style="font-size:12px;"><strong><u><%=WI.fillTextValue("registrar_name")%></u></strong></td>
		</tr>
		
		<tr><td width="5%">&nbsp;</td>
			<td align="center" valign="top" style="font-size:12px;" colspan='3'>UNIVERSITY REGISTRAR</td>
		</tr>
		<br>
			<%
			strTemp = "Finance Officer";
			if(!bolLP)
				strTemp = "School Director";
			%>
		<tr><td width="5%">&nbsp;</td>
			<td valign="bottom" style="font-size:9px;" width="30%">Prepared by: <%=WI.fillTextValue("prep_by1").toUpperCase()%></td>
			<td height="30" align="center" valign="bottom" style="font-size:9px;"><div style="border-bottom:solid 1px #000000; width:80%"><strong>
			<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,strTemp,7),"VIRGINIA O. CAINGLET").toUpperCase()%>
			</strong></div></td>
			<td valign="bottom" style="font-size:9px;" width="30%">Date Issued: ___________</td>
		</tr>
		
		<tr><td width="5%">&nbsp;</td>
			<td align="center" style="font-size:9px;"><div align="center" style="border-bottom:solid 1px #000000; width:40%">Registrar Staff</div></td>
			<td align="center" valign="top" style="font-size:9px;"><%=strTemp%></td>
			<td style="font-size:9px;">Released by: ___________</td>
		</tr>
		
		<tr><td width="5%">&nbsp;</td>
			<td><strong>NOTE:</strong> <font style="font-size:10px;"><!--This transcript is valid only when it
			bears the seal of the University and the original signature in ink
			<%
			strTemp = "Finance Officer";
			if(!bolLP)
				strTemp = "School Director";
			%>
			of the Assistant Registrar or Registrar and the <%=strTemp%>.
			Any erasures or alteration made in this copy renders the whole
			transcript invalid.-->
			
			This transcript is valid only when it bears the seal of the University 
			<%
			strTemp = "Finance Officer";
			if(!bolLP)
				strTemp = "School Director";
			%>
			and the original signature in ink of the University Registrar and the <%=strTemp%>. 
			Any erasure or alteration made in this copy renders the whole transcript invalid.
						
			</font></td>
			<td>&nbsp;</td>
		  <td valign="top" style="font-size:9px;">Page <%=iPageNumber%> of <%=strTotalPageNumber%></td>
		</tr>
	</table>
	
	<div style="page-break-after:always">&nbsp;</div>

<%}//if iPage number = 1%>

	
	
	
<%if(true){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr> 
		<td height="135" colspan="5">&nbsp;</td>    
	</tr> 

  <tr> 
  	<td width="5%">&nbsp;</td>    
    <td width="15%" height="18">Student Name</td>
    <td width="" colspan="3" class=""><strong>: &nbsp;
		<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,&nbsp;
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>    
  </tr>
  <tr> 
  	<td width="5%">&nbsp;</td>    
    <td height="18">ID Number</td>
    <td width="60%">: &nbsp; <%=WI.fillTextValue("stud_id").toUpperCase()%></td>
    <td>&nbsp;</td>
    <td>Page <%=iPageNumber+1%> of <%=strTotalPageNumber%></td>
  </tr>
</table>
<%}%>


<%
if(vRetResult != null && vRetResult.size() > 0){
	int iNumWeeks = 0;
	int iColspan = 2;
	if (WI.fillTextValue("weeks").length() > 0) iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));
	
	if (bolShowLecLabHr)  iColspan +=2;
	if (bolIsRLEHrs) iColspan++;
		
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">
	<tr><td height="15" colspan="6">&nbsp;</td></tr>
	 <tr>
	 	<td height="890" valign="top">
		
			<table width="100%" cellpadding="0" cellspacing="0">
				
				<tr bgcolor="#FFFFFF">
					<td width="5%" height="25">&nbsp;</td> 
					<td width="12%" class="thinborderTOPBOTTOM">Course Code</td>
					<td width="59%" class="thinborderTOPBOTTOM" align="center">Course Title</td>
					<td width="7%" class="thinborderTOPBOTTOM" align="center">Grade</td>    
					<td width="8%" class="thinborderTOPBOTTOM" align="center">Credit Unit/s</td>
					<td width="9%" class="thinborderTOPBOTTOM" align="center">Completion</td>
			  </tr>
				
				<%
int iLevelID = 0;

int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = null;
String strSchNameToDisp = null;

String strSYSemToDisp   = null;
String strCurSYSem      = null;
String strPrevSYSem     = null;

boolean bolIsSchNameNull    = false;
boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has 
boolean  bolPrinted = false; // print only once

//school name after it is null, it is encoded as cross enrollee.

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);

String strGrade = null;

String strInternshipInfo = null;

String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;
//System.out.println("iMaxRowToDisp 1 : " + iMaxRowToDisp);

if(WI.fillTextValue("addl_remark").length() > 0 && iLastPage == 1){

	int iTemp = 1;
	 strTemp = WI.fillTextValue("addl_remark");
	int iIndexOf = 0;

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
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 7 + 11)) == 0 && //sub name,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) {   //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
			strGrade = (String)vRetResult.elementAt(i + 8 + 11); 
	}
	else {
		strTemp = (String)vRetResult.elementAt(i + 9);
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
if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+" , "+
					(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
	}
	else {
		strCurSYSem = (String)vRetResult.elementAt(i+ 3)+" , "+(String)vRetResult.elementAt(i+ 1)+" - "+
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
			//System.out.println(" strCrossEnrolleeSch ; "+strCrossEnrolleeSch);
			strSchNameToDisp = strSchoolName;//added to display cross enrolled school :: 2008-06-23 = added followed by request from AUF to show crossenrolled school name.
		}
	}
	//cross enrolled.. 
	//if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//display will be schooo name<br>sy/term (cross enrolled)
	//	strSYSemToDisp = null;
	//	strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSYSem+" (CROSS ENROLLED)";
	//}

 //Very important here, it print <!-- if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){strHideRowLHS = "<!--";//I have to do this so i will know if I am priting data or not%>
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
  	<td>&nbsp;</td> 
    <td height="20" colspan="5">  &nbsp;&nbsp;<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
  </tr>
  
  
  <%}//end of if(iMulRemarkIndex == i)
}//end of if(vMulRemark != null && vMulRemark.size() > 0) 

//check internship Info.. 
strInternshipInfo = null;
/**
while(vInternshipInfo.size() > 0) {
	int iTemp = ((Integer)vInternshipInfo.elementAt(0)).intValue();
	System.out.println("i == "+i+" and internship loc : "+iTemp);
	if(iTemp > i)
		break;
	if(i > iTemp) {
		vInternshipInfo.remove(0);
		vInternshipInfo.remove(0);
		continue;
	}
	if(i == iTemp) {
		strInternshipInfo = (String)vInternshipInfo.remove(1);
		vInternshipInfo.remove(0);
		break;
	}
}
**/

if(vInternshipInfo.size() > 0) {
	int iTemp = ((Integer)vInternshipInfo.elementAt(0)).intValue();
	if(iTemp == i) {
		strInternshipInfo = (String)vInternshipInfo.remove(1);
		vInternshipInfo.remove(0);
	}
	else if(iTemp == i + 11) {//may be inc
			if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && //&& ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 - remove the inc checking..
				((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
				((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 7 + 11)) == 0 && //sub name,
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
	int iIndexOf = 0;
	while(  (iIndexOf = strTemp.indexOf("<br>",iIndexOf + 1)) != -1)
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
  	<td>&nbsp;</td>
    <td height="20" colspan="5">&nbsp; <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
  </tr>
<%}%>  

<%if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
//	System.out.println("iRowsPrinted 3:" + iRowsPrinted + "; strSchNameToDisp"+ strSchNameToDisp );		
		//do not keep extra line for school name.%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20">&nbsp;</td>
    <td height="20" colspan="5" align="center"><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strSchNameToDisp.toUpperCase()%></label>
    </strong></td>
  </tr>
  <%strPrevSchName = strSchNameToDisp;
 } // if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp))))

if(strSYSemToDisp != null){
		if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
%>
  <tr bgcolor="#FFFFFF"> 
    <td>&nbsp;</td>
	<%//semesters ni dri%>
    <td colspan="5" align="center"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><u>
	<%if(bolIsCareGiver && vEntranceData.elementAt(27) != null){%>
		<%=((String)vEntranceData.elementAt(27)).toUpperCase()%>
	<%}else{%>
		<%=strSYSemToDisp%>
	<%}%>
	</u>
	</label>
	
    </td>
  </tr>
  <%}


strGrade = WI.getStrValue(strGrade);

if(strGrade.equals("on going")) {
	strGrade = "GNA";
	strCE = "&nbsp;";
}
else if(strGrade.compareToIgnoreCase("IP") == 0) {
	strGrade = "IP";
	strCE = "&nbsp;";
}
else {
	if(strGrade.indexOf(".") > -1 && strGrade.length() == 3) 
		strGrade = strGrade + "0";
}
if(bolIsCareGiver && strCE.length() > 0) 
	strCE = strCE + " hrs";
if(strCE != null && strCE.indexOf(".") == -1)
	strCE = strCE + ".0";
%>



  <tr bgcolor="#FFFFFF">    
  	<td width="5%" height="18">&nbsp;</td>
	<td><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></label></td>  
    <td ><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;")%></label></td>
    <td align="center"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strGrade%></label></td>
    <td align="center">&nbsp;&nbsp;&nbsp;<%=strCE%></td>
	<%//para ni sa completion dri%>
	<td>&nbsp;</td>
  </tr>
  

  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop
   %>

				
			<tr>
				<td>&nbsp;</td>
				<td colspan="5" style="border-top:solid 2px #000000;" align="center">
				<% if (iLastPage == 1){%>
					***** E N D &nbsp; O F &nbsp; T R A N S C R I P T  ******
				<%}else{%>
					<font size="1">*****  Continued On Next Page  ******</font>
				<%}%>
				</td>
			</tr>
				
				
				
				
				
			</table>
			
<% if (iLastPage == 1){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%  

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
	if(bolIsCareGiver)
		strTemp = "GRADUATED WITH THE SIX-MONTH CARE GIVER";
	else
		strTemp = "GRADUATED WITH THE DEGREE OF " + ((String)vStudInfo.elementAt(7)).toUpperCase();
	
	 
	 if(strMajorCode != null) {
	 	strTemp += ", MAJOR IN "+((String)vStudInfo.elementAt(8)).toUpperCase();
		strCourseCode = strCourseCode + " "+strMajorCode;
	 }
	
	 strTemp += WI.getStrValue(strCourseCode," (",") ","");
				
	 if ((String)vGraduationData.elementAt(8) != null)
	 	strTemp += " ON " + WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
	
	 if(vGraduationData.elementAt(6) != null)
	 	strTemp +=	", AS PER " +vGraduationData.elementAt(6);
	 if (vGraduationData.elementAt(6) != null && vGraduationData.elementAt(7) != null) {
	 	if(bolIsCareGiver)
			strTemp +=  " DATED " ;
		else	
			strTemp +=  ", " ;
		strTemp +=WI.formatDate((String)vGraduationData.elementAt(7),6).toUpperCase() + ".";
	 }
	 else	
	 	strTemp += ".";
	 if(vGraduationData.elementAt(16) != null)
	 	strTemp = strTemp + " "+WI.getStrValue((String)vGraduationData.elementAt(16)).toUpperCase();
		
	if (strTemp.length()/100 > 0) {
		iTemp = strTemp.length()/100;
		if (strTemp.length()%100 > 0)
			iTemp +=1;
	}
	 iRowsPrinted += iTemp; 
%>  
  
<%} iRowsPrinted++; 

// for nothing follows%>
  <tr>
    <td height="20" colspan="2" align="center"><strong>®ANY ERASURE OR ALTERATION RENDERS THE WHOLE TRANSCRIPT NULL AND VOID</strong></td>
  </tr>
<%if(WI.fillTextValue("endof_tor_remark").length() > 0) {%>
  <tr>
    <td height="20" colspan="2" align="center"><%=WI.fillTextValue("endof_tor_remark")%></td>
  </tr>
<%}%>

<% }//if last page = 1%>
</table>
		
		</td>	 
	 </tr>
 </table>
  <br>
<table width="100%" border="0" cellpadding="0" cellspacing="0">	
	<tr><td height="40" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:55%; vertical-align:bottom;"><strong><%=WI.fillTextValue("registrar_name")%></strong></div>
  		UNIVERSITY REGISTRAR
  	</td></tr>
  	<tr><td><strong>NOT VALID WITHOUT SCHOOL SEAL</strong></td></tr>
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