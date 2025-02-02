<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CDD OFFICIAL TRANSCRIPT OF RECORD</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
#pic{
-webkit-box-shadow: 0 8px 6px -6px #666;
-moz-box-shadow: 0 8px 6px -6px black;
box-shadow: 0 8px 6px -6px black;
border:1px #999999 solid;
}
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

.fontsize9 {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 8px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
	TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }	
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;
    }
    .thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;
    }

    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
    TD.thinborderRIGHTBOTTOM {
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
	
	TD.thinborderTOPRIGHTBOTTOM {
	border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
	
	TD.thinborderTOPLEFTBOTTOM {
	border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
	
	TD.thinborderTOPLEFT{
	border-top: solid 1px #000000;
    border-left: solid 1px #000000;    
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
	
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
	
	TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
	
    TD.thinborderLEFTRIGHTBOTTOM {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 10px;	
    }
	
	TD.thinborderALLRed{
		border-left: solid 2px #FF0000;
		border-right: solid 2px #FF0000;
		border-bottom: solid 2px #FF0000;
		border-top: solid 2px #FF0000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
		font-size: 10px;	
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


///// extra condition for the selected courses
String strStudCourseToDisp = null; 
String strStudMajorToDisp = null;
String strNSTPSerial = null;
String strEntranceStatus = null;

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

java.sql.ResultSet rs = null;
String[] astrConvertSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};

String[] astrConvertSemUG  = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
String[] astrConvertSemMED = {"SUMMER","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR"};
String[] astrConvertSemMAS = astrConvertSemUG;

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
		strTemp = "select SERIAL_NO from NSTP_SERIALNO where STUD_INDEX = "+(String)vStudInfo.elementAt(12);
		strNSTPSerial = dbOP.getResultOfAQuery(strTemp, 0);
		if(strNSTPSerial != null && strNSTPSerial.indexOf("-") == 4)
			strNSTPSerial = null; // system generated ..
	
		//strTemp = "select entrance_status from entrance_data where stud_index = "+(String)vStudInfo.elementAt(12);
		//strEntranceStatus = dbOP.getResultOfAQuery(strTemp, 0);
		strEntranceStatus = WI.fillTextValue("entrance_stat");
		if(strEntranceStatus.length() == 0)
			strEntranceStatus = "New";
	
		strCollegeName = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(5));
		if(strCollegeName != null)
			strCollegeName = strCollegeName.toUpperCase();
			
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
			(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
			
		strReligion = "select religion,spouse_name from info_personal where user_index = "+(String)vStudInfo.elementAt(12);
		rs = dbOP.executeQuery(strReligion);
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


if(vRetResult != null && vRetResult.toString().indexOf("hrs") > 0 && WI.fillTextValue("show_rle").compareTo("1") == 0)
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
if(strStudCourseToDisp != null && strStudCourseToDisp.toLowerCase().indexOf("caregiver") > -1)
	bolIsCareGiver = true;

Vector vExcludeList = repRegistrar.operateOnExcludedSubjectTOR(dbOP, request, 4);
if(vExcludeList == null)
	vExcludeList = new Vector();
	
///get all transferee info.
Vector vCrossEnrollSYTerm = new Vector();
if(vStudInfo != null) {
	strTemp = "select distinct sy_from, semester from g_sheet_final join stud_curriculum_hist on (stud_curriculum_hist.cur_hist_index = g_sheet_final.cur_hist_index) "+
				" where user_index_ = "+(String)vStudInfo.elementAt(12)+" and g_sheet_final.is_valid = 1 and CE_SCH_INDEX is not null";
	rs = dbOP.executeQuery(strTemp);
	while(rs.next())
		vCrossEnrollSYTerm.addElement(rs.getString(1)+"-"+rs.getString(2));
	rs.close();
}	
	
%>

<body topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0" <%if(WI.fillTextValue("show_pic").length() == 0){%>onLoad="HideImg();"<%}%>>
<form action="./otr_print_CDD.jsp" method="post" name="form_">

<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
	<tr><td height="60">&nbsp;</td></tr>
</table>

<%if(vAdditionalInfo != null && vAdditionalInfo. size() > 0){%>
<div style="width:100%;">
	<div style="height:70px;">&nbsp;</div>
    <!-- place holder for the picture -->
    <div style="float:right; z-index:-1; margin:0in 0.5in 0in 0in" ><label id='hide_img' onClick='HideImg()'><img src="../../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()+".jpg"%>" width="99" height="127" id="pic"></label></div>
    
	<div style="margin:0in 0in 0in 1.75in"><strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong> &nbsp;</div>
	<div style="margin:0in 0in 0in 1.75in">
    <strong>
	
	<%=strStudCourseToDisp.toUpperCase()%> <%if(WI.fillTextValue("remove_major_tor").length() == 0) {%><%=(strStudMajorToDisp==null)?"":"MAJOR IN "+strStudMajorToDisp.toUpperCase()%><%}%>
    
    </strong>
    </div>

	<!-- Stundent Name -->
	<div style="margin:0.1in 0in 0in 1.75in">
    	<strong>
		<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		<%=WI.getStrValue((String)vStudInfo.elementAt(1)," ").toUpperCase()%>
        </strong>&nbsp;
    </div>

	<div style="margin:0.1in 0in 0in 5.25in"><strong><%=WI.getStrValue(strEntranceStatus)%></strong>&nbsp;</div> <!-- Date Admitted -->
	<div style="margin:0in 0in 0in 5.25in"><strong><%=WI.fillTextValue("entrance_data").toUpperCase()%></strong>&nbsp;</div> <!-- Entrance Credential -->

    <!-- Address -->
	<div style="margin:0in 0in 0in 1.75in">
        <strong>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","").toUpperCase()%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","").toUpperCase()%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","").toUpperCase()%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","").toUpperCase()%>
		</strong>&nbsp;
    </div>


	<!-- Secondary Education -->
    <div style="margin:0.2in 0in 0in 1.75in"><strong><%=WI.getStrValue((String)vEntranceData.elementAt(5),"")%></strong></div>
    
    <div style="margin:0in 0in 0in 0in;">
    	<div style="float:left; width:3.5in; margin:0in 0in 0in 1.75in">
        <!-- Year Graduated -->
        <strong><%=WI.getStrValue((String)vEntranceData.elementAt(22),"","","")%></strong>&nbsp;
        </div>
    	
      	<div style="float:left;"> 
		<!-- Birthday -->
 		<%
			strTemp = "";
			if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
				strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1));			
		%>
        <strong><%=strTemp.toUpperCase()%></strong>
        </div>
        
        <div style="clear:both;"></div>
        
      	<div style="float:left; width:3.5in;  margin:0in 0in 0in 1.75in;">&nbsp;</div>
      	<div style="float:left;">
        <!-- Birth Place -->
        <%
			strTemp = "";
			if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
				strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2));
			
		%>
        <strong><%=strTemp.toUpperCase()%></strong> &nbsp;       
        </div>        
        <div style="clear:both;"></div>
    </div>
    
	<div style="margin:0.1in 0in 0.2in 3in;">
         <!-- CHED Recognation -->
        <%
		strTemp = "";
		if (WI.fillTextValue("ched_recognition_no").length() > 0) 
			strTemp = WI.fillTextValue("ched_recognition_no");

		%>
        <strong><%=strTemp%></strong>&nbsp;</div>   

</div>
<%}//end vAdditionalInfo




if(vRetResult != null && vRetResult.size() > 0){
	int iNumWeeks = 0;
	if (WI.fillTextValue("weeks").length() > 0) 
		iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));		
	
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="30px;">&nbsp;</td></tr>
	<tr>
		<td width="100%" height="550px" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">	
<%

int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = "";
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


for(int i = 0 ; i < vRetResult.size(); i += 11){

	if(vRetResult.elementAt(i + 6) != null && vExcludeList.indexOf(vRetResult.elementAt(i + 6)) > -1) {
		vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);
		vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);
		vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);
		
		i = i - 11;		
	}
}





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
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) {   //semester
			strTemp  = (String)vRetResult.elementAt(i + 9 + 11);
			strGrade = (String)vRetResult.elementAt(i + 8); 
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
//	if(strSchoolName != null) {
//		if(strPrevSchName == null) {
//			//System.out.println("im here : "+(String)vRetResult.elementAt(i+ 7));			
//			strPrevSchName = strSchoolName;
//			strSchNameToDisp = strSchoolName;
//		}
//		else if(strPrevSchName.compareTo(strSchoolName) ==0) {
//			strSchNameToDisp = null;
//		}
//		else {//itis having a new school name.
//			//strPrevSchName = strSchoolName;
//			//strSchNameToDisp = strPrevSchName;
//			strSchNameToDisp = strSchoolName; //2008-06-23 = added;			
//		}
//	}
	
//	if(i == 0 && strSchoolName == null) {//I have to get the current school name
//		strSchNameToDisp = SchoolInformation.getSchoolName(dbOP,false,false);
//	}
//	if(strSchoolName == null)// && vRetResult.elementAt(i + 10) != null)//subject group name is not null for reg.sub
//		strSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);
//		
	if(strSchoolName != null)
		strSchNameToDisp = strSchoolName;	
		
	if(i > 0 && strSchoolName == null && strPrevSchName != null && strPrevSchName.length() > 0)	
		strSchNameToDisp = SchoolInformation.getSchoolName(dbOP,false,false);
	
 	//if prev school name is not not null, show the current shcool name.
	/*if(strSchoolName == null && strPrevSchName != null) {
		strSchoolName    = strCurrentSchoolName;
		strSchNameToDisp = strCurrentSchoolName;
		strPrevSchName = null;
	}*/
	
//	if(strSchoolName == null && strPrevSchName != null) {
//		strSchNameToDisp = strCurrentSchoolName;
//		strPrevSchName = null;
//	}

	//if(WI.fillTextValue("stud_id").equals("12-0933-251")) {
		/*System.out.println();
		System.out.println((String)vRetResult.elementAt(i+ 7));
		System.out.println("strSchoolName "+strSchoolName);
		System.out.println("strSchNameToDisp "+strSchNameToDisp);
		System.out.println("strPrevSchName "+strPrevSchName);*/
		//System.out.println(vRetResult.elementAt(i+ 1));
	//}

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
	if(/*vRetResult.elementAt(i) != null && bolIsSchNameNull &&*/ vCrossEnrollSYTerm.size() > 0) {//display will be schooo name<br>sy/term (cross enrolled)
		//strSYToDisp = null;
		//strSemToDisp = null;		
		if(vCrossEnrollSYTerm.indexOf((String)vRetResult.elementAt(i + 1) +"-"+(String)vRetResult.elementAt(i + 3)) > -1)
			strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSY+" "+strCurSem+" (CROSS ENROLLED)";
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
    <td height="20" colspan="5"><%=strTemp%></label></td>
  </tr>
  
  
  <%}//end of if(iMulRemarkIndex == i)
}//end of if(vMulRemark != null && vMulRemark.size() > 0) 



//if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){
if(strSchNameToDisp != null && !strPrevSchName.equals(strSchNameToDisp)){
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
	%>
  <tr bgcolor="#FFFFFF">     
    <td height="20" colspan="5"><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><u><%=strSchNameToDisp.toUpperCase()%></u></label></strong></td>	
  </tr>
<%strPrevSchName = strSchNameToDisp; } %>

<%
if(strSYToDisp != null && strSemToDisp != null){
		if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;

	if(bolIsCareGiver && vEntranceData.elementAt(27) != null)
		strTemp = strSemToDisp +" "+ ((String)vEntranceData.elementAt(27)).toUpperCase();		
	else
		strTemp = strSemToDisp +", "+ strSYToDisp;		
%>
  <tr bgcolor="#FFFFFF">   	  	
  	<td colspan="5"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><u><strong><%=strTemp%></strong></u></label></td>	
  </tr>
  
<%}

strGrade = WI.getStrValue(strGrade);

if(strGrade.equals("on going")) {
	strGrade = "In Progress";
	strCE = "";
}
else if(strGrade.compareToIgnoreCase("IP") == 0) {
	strGrade = "IP";
	strCE = "";
}
else {
	if(strGrade.indexOf(".") > -1 && strGrade.length() == 3) 
		strGrade = strGrade + "0";
}

if(bolIsCareGiver && strCE.length() > 0) 
	strCE = strCE + " hrs";
if(strCE.length() > 0 && strCE.indexOf(".") == -1 && strCE.toLowerCase().indexOf("hrs") == -1)
	strCE=strCE+".00";	

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
%>
	
  <tr bgcolor="#FFFFFF">      
  	<td width="20%" height="14" style="padding-left:40px;"><strong><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></strong></td>  
    <td><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><strong><%=WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;")%></strong> </label></td>
    <td align="center" width="10%"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><strong><%=WI.getStrValue(strGrade,"&nbsp;")%>&nbsp; &nbsp; &nbsp; &nbsp; 
		</strong></label></td>
	<td align="center" width="10%"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp; &nbsp; &nbsp;
		</strong></label></td>
    <td align="center" width="10%"><strong><%=WI.getStrValue(strCE,"&nbsp;")%>&nbsp; &nbsp; &nbsp;</strong></td>
  </tr>
  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop
   %>
   
   
<%if(iLastPage == 1){
	if(strNSTPSerial != null){
%>

		<tr>
			<td colspan="5" style="padding-left:100px; padding-right:100px;"><strong>With NSTP Serial No. (<%=strNSTPSerial%>).</strong></td>
		</tr>
        

<%
	}//nstp not null
		strTemp = WI.fillTextValue("endof_tor_remark");
		int iTemp = 0;
		if(strTemp.length() > 0){	
			if (strTemp.length()/100 > 0) {
				iTemp = strTemp.length()/100;
				if (strTemp.length()%100 > 0)
					iTemp +=1;
			}
			 iRowsPrinted += iTemp; 
		%>  									
		<tr>
			<td colspan="5" style="padding-left:100px; padding-right:100px;"><strong><%=strTemp.toUpperCase()%></strong></td>
		</tr>			
			
			
<%}%>  			
		<tr><td height="18" colspan="5" align="center"><font size="1"><strong>cddcddcddcddcddcddcddcddTRANSCRIPT CLOSEDcddcddcddcddcddcddcddcdd</strong></font></td></tr>	
<%}else{%>
		<tr>			
			<td align="center" colspan="5"><strong><font size="1">--== more ==--</font></strong></td>			
		</tr>

<%}%>
		</table>
			<!-- Table inside td. -->
		
	</td>
</tr>


<tr>
		<td width="100%" valign="top">
		
		<%
		strTemp = WI.fillTextValue("addl_remark").toUpperCase();
		int iIndexOf = 0;
		
		iIndexOf = strTemp.indexOf("BOARD EXAMINATION");
		if(iIndexOf != -1){
		
		%>
		
			<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">
				<tr>
					<td width="6%">&nbsp;</td>
					<td class="thinborderALLRed" align="center"><font size="3"><strong>>>><%=strTemp%><<<</strong></font></td>
					<td width="6%">&nbsp;</td>
				</tr>
			</table>
			
		<%}else{%>	
		
			<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">
				<tr>
					<td width="10%">&nbsp;</td>
					<td class=""><%=strTemp%></td>
					<td width="10%">&nbsp;</td>
				</tr>
			</table>
			
		<%}%>
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