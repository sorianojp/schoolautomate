<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>OFFICIAL TRANSCRIPT OF RECORDS</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
@media print { 
  @page {
		margin-bottom:0in;
		margin-top:.5in;
		margin-right:.1in;
		margin-left:.1in;
	}
}
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
.fontsize9BOLD {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
	font-weight: bold;
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
TD.thinborderLEFT10px {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
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
TD.thinborderLEFTTOP{
    border-left: solid 1px #000000;
    border-top: solid 1px #000000;
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
</script>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = null;
	int iTemp = 0;
	String strCollegeName = null;//I have to find the college offering course.
	int iRowCount2 = 0;
	int iRowStartFr = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_start_fr"), "0"));
	int iRowCount   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_count"), "0"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"), "0"));
	String strPrintPage = WI.fillTextValue("print_");//"1" is print. 
	
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_page_to_disp"), "0"));
	
	int iPageNumber = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_number"), "0"));
	String strTotalPageNumber = WI.fillTextValue("total_page");
	String strRootPath  = null;
	String strImgFileExt = null;	
	String strPrintValueCSV = "";
	
	if(WI.fillTextValue("print_all_pages").equals("1")) { //print all page called.
		strPrintValueCSV = WI.fillTextValue("print_value_csv");
		if(strPrintValueCSV.length() == 0) {
			strErrMsg = "End of printing. This error must not occur.";%>
			<%=strErrMsg%>
		    <%return;
		} 
		Vector vPrintVal = CommonUtil.convertCSVToVector(strPrintValueCSV);
		//[0] row_start_fr, [1] row_count, [2] last_page, [3] page_number, [4] max_page_to_disp, 
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
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-OTR","otr_print.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0){
			strErrMsg = "Imange file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		
		if(strRootPath == null || strRootPath.trim().length() ==0){
			strErrMsg = "Installation directory path is not set.  " +
						 " Please check the property file for installDir KEY.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}

	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	CommonUtilExtn comUtilExtn = new CommonUtilExtn(request);
	
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
				"Registrar Management","REPORTS",request.getRemoteAddr(),"otr_print.jsp");
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
	String strAdmissionStatus = null;
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
			vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
				(String)vStudInfo.elementAt(12));
			if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
				strErrMsg = studInfo.getErrMsg();
		}
	}
	if(vStudInfo != null && vStudInfo.size() > 0) {
		Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,request.getParameter("stud_id"),(String)vStudInfo.elementAt(7),
														(String)vStudInfo.elementAt(8));
		  if (vFirstEnrl != null) {
				vRetResult = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
												(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
												(String)vFirstEnrl.elementAt(2),false,false,true,true);
											
				if(vRetResult == null && strErrMsg == null)
					strErrMsg = cRequirement.getErrMsg();
				else
					vCompliedRequirement = (Vector)vRetResult.elementAt(1);
					
					
				strAdmissionStatus = (String)vFirstEnrl.elementAt(3);
				if (strAdmissionStatus == null)
					strAdmissionStatus = "";
				else {
					strAdmissionStatus = strAdmissionStatus.toLowerCase();
					if (strAdmissionStatus.equals("new"))
						strAdmissionStatus = "Freshman";
					//else if (strAdmissionStatus.startsWith("trans"))
					//	strAdmissionStatus = "College Undergraduate";
					//else if (strAdmissionStatus.startsWith("second"))
					//	strAdmissionStatus = "College Graduate";
		
					// insert other status here!!
				}		
				
		  }else 
			strErrMsg = cRequirement.getErrMsg();	
	}

//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
//	System.out.println("strDegreeType : " + strDegreeType);
	if(vCourseSelected.size() > 0) {
		strTemp = "select degree_type from course_offered where course_index in ("+
		CommonUtil.convertVectorToCSV(vCourseSelected)+")";
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
	}
}
String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);

boolean bolIsRLEHrs = false;
boolean bolShowLecLabHr = false; String[] astrLecLabHr = null;//gets lec/lab hour information.
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

if(vRetResult.toString().indexOf("hrs") > 0 && WI.fillTextValue("show_rle").compareTo("1") == 0)
	bolIsRLEHrs = true;

if(WI.fillTextValue("show_leclab").compareTo("1") == 0)	
	bolShowLecLabHr = true;
	
//get internship ifno.. 
Vector vInternshipInfo = repRegistrar.getInternshipInfo();
String strMulRemarkAtEndOfSYTerm = null;//if there is any remark added after the end of SY/term of Student.. 

//check if caregiver.. 
if(strStudCourseToDisp != null && strStudCourseToDisp.toLowerCase().equals("caregiver course"))
	bolIsCareGiver = true;	
%>
<body topmargin="0">
<form action="./otr_print_NEU.jsp" method="post" name="form_">
<%if(vRetResult != null && vRetResult.size() > 0){
	int iNumWeeks = 0;
	int iColspan = 2;
	if (WI.fillTextValue("weeks").length() > 0) iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));
	
	if (bolShowLecLabHr)  iColspan +=2;
	if (bolIsRLEHrs) iColspan++;

int iLevelID = 0;

int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = null;
String strSchNameToDisp = null;

String strSYSemToDisp   = null;
String strCurSYSem      = null;
String strPrevSYSem     = null;

String strSYToDisp		= null;
String strSemToDisp		= null;


String strCurSem		= null;
String strCurSY			= null;

String strPrevSY		= null;
String strPrevSem		= null;

boolean bolIsSchNameNull    = false;
boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has 
boolean  bolPrinted = false; // print only once

//school name after it is null, it is encoded as cross enrollee.

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);

String strInternshipInfo = null;

String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;
//System.out.println("iMaxRowToDisp 1 : " + iMaxRowToDisp);
iLastPage = 0;
if(WI.fillTextValue("addl_remark").length() > 0 && iLastPage == 1){

	iTemp = 1;
	 strTemp = WI.fillTextValue("addl_remark");
	int iIndexOf = 0;

	while((iIndexOf = strTemp.indexOf("<br>",iIndexOf + 1)) != -1)
		++iTemp;

	 iMaxRowToDisp = iMaxRowToDisp - iTemp; 
}

if(vInternshipInfo == null)
	vInternshipInfo = new Vector();

boolean bolPageBreak = false;
int iTitleLength    = 0;
int iTotalRowCount  = 35;
int iNumberRowCount = 0;
int iTitleRowCount  = 0;
int iCharPerLine  = 40;	
int iOrgNumRowCount = 0;
int iSubjHeight = 0;
int iMulRemarkHeight = 0;
String strGrade = null;
for(int i = 0 ; i < vRetResult.size();){
  iNumberRowCount = 0;   
  if(bolPageBreak){
            bolPageBreak = false;%>
			<div style="page-break-after:always;">&nbsp;</div>
<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
   <tr>
   		<td colspan="2" align="center">
		</td>
   </tr>
   <tr>
   		<td height="60">&nbsp;</td>
   </tr>
   <tr>
   		<td align="center" height="25"></td>
   </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
  	<td>
	   <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td height="30" valign="bottom" width="16%">&nbsp;</td>
          <td width="30%" valign="bottom" >&nbsp;<%=WI.fillTextValue("stud_id").toUpperCase()%></td>
		  <td width="54%" valign="bottom"><%=strAdmissionStatus%></td>
		  </tr>
      </table>
	</td>	
  </tr>
  <tr> 
    <td height="20" width="82%">
	 	<table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="16%">&nbsp;</td>
          <td width="56%" ><strong>&nbsp;<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
			 <%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		    <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
			 <td width="3%">&nbsp;&nbsp;</td>
	<%  strTemp = (String)vStudInfo.elementAt(16);
		if(strTemp.equals("M"))
			strTemp = "Male";
		else
			strTemp = "Female";
	%>	
			 <td width="25%" >&nbsp;<%=strTemp%></td>
        </tr>
      </table>
	 </td>	     
  </tr>  
  <tr> 
    <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td  height="20" width="16%">&nbsp;</td>
          <td width="84%">&nbsp;<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%>
		  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")%>
		  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")%>
		  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%>
		  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","")%></td>
        </tr>
      </table>
	  </td>
  </tr>
  <tr> 
    <td>
	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td height="20" width="16%">&nbsp;</td>
          <% if (vEntranceData != null && vEntranceData.size()>0){
				strTemp = (String)vEntranceData.elementAt(7);
				if (strTemp == null) 
					strTemp = (String)vEntranceData.elementAt(5);
			 }
		  %><td width="84%">&nbsp;<%=WI.getStrValue(strTemp)%></td>         
        </tr>
      </table></td>
  </tr>  
  <tr> 
    <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
	 	  <tr> 
          <td height="20" width="16%">&nbsp;</td>
          <td width="84%" >&nbsp;<%=strStudCourseToDisp/**(String)vStudInfo.elementAt(7)**/%>
		  <%if(WI.getStrValue(strStudMajorToDisp).length() > 0){%>
		  / <%=WI.getStrValue(strStudMajorToDisp/**(String)vStudInfo.elementAt(8)**/)%>
		  <%}%>
		 </td>  
        </tr>		 		 
      </table></td>
  </tr>  
  <tr> 
    <td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">        
		  <tr> 
          <td height="20" width="16%">&nbsp;</td>
		  <% if(vGraduationData != null && vGraduationData.size() > 0) {
		  		strTemp = WI.getStrValue(WI.formatDate((String)vGraduationData.elementAt(8),6),null);
		  		if(strTemp == null || strTemp.length() == 0){
					String[] astrMonth = { "", "January", "February", "March", "April", "May", "June", "July", 
					"August", "September", "October", "November", "December" };
					int iMonth = Integer.parseInt(WI.getStrValue(vGraduationData.elementAt(10),"0"));
					if(iMonth > 12)
						iMonth = 12;
					strTemp = astrMonth[iMonth] + " " + WI.getStrValue(vGraduationData.elementAt(9));
			}
			}else
				strTemp = "&nbsp;";
		  %>
          <td width="17%">&nbsp;<%=strTemp%></td>   
		  <%
				if(vGraduationData != null && vGraduationData.size()!=0)
					strTemp = WI.getStrValue(vGraduationData.elementAt(6));
				else	
					strTemp = "&nbsp;";
				%>       
		  <td width="39%">S. O. Number: <%=strTemp%>&nbsp;&nbsp;</td>
		  <%
				if(vGraduationData != null && vGraduationData.size()!=0)
					strTemp = WI.getStrValue(vGraduationData.elementAt(7));
				else	
					strTemp = "&nbsp;";
				%> 
		  <td width="28%">Date Issued: <%=strTemp%></td>          
        </tr>
      </table></td>
  </tr>  
  <tr><td height="10"></td></tr>
</table>		
<table cellpadding="0" cellspacing="0" width="100%" border="0">
	<tr>
		<td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();" >
          <tr bgcolor="#FFFFFF">
            <td width="14%"  rowspan="2" height="25" align="center"><strong>&nbsp;</strong></td>
            <td rowspan="2" align="center" ><strong>&nbsp; </strong></td>
            <td height="25"  colspan="2" align="center"><strong>&nbsp;</strong></td>
            <td rowspan="2"  align="center"><strong>&nbsp;<br>&nbsp;</strong></td>
            <td width="18%" >&nbsp;</td>
          </tr>
          <tr>
            <td height="25" align="center"><strong>&nbsp;</strong></td>
            <td align="center"><strong>&nbsp;</strong></td>
            <td rowspan="27" valign="top">&nbsp;</td>
          </tr>
<%for(; i < vRetResult.size(); i += 11, ++iCurrentRow){
			iSubjHeight = 20;
			iMulRemarkHeight = 20;
			
			iOrgNumRowCount = iNumberRowCount;
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
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { 
		  //semester
						strTemp = (String)vRetResult.elementAt(i + 9 + 11);
						strGrade = (String)vRetResult.elementAt(i + 8 + 11); 
				}else {
					strTemp = (String)vRetResult.elementAt(i + 9);
					strGrade = (String)vRetResult.elementAt(i + 8);
				}
				
				strCE  = strTemp;				
				/*if (strCE!= null && strCE.equals("0") && 
				WI.getStrValue((String)vRetResult.elementAt(i + 8),"").toLowerCase().equals("drp")) {
					strCE = "-";
				}*/
				
				if(strTemp != null && strTemp.indexOf("hrs") > 0) {
					strRLEHrs = CommonUtil.formatGrade(strTemp.substring(strTemp.indexOf("(") + 1, strTemp.indexOf("hrs")),0f);
					strCE     = strTemp.substring(0,strTemp.indexOf("("));
				}else {
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
					}else if(strPrevSchName.compareTo(strSchoolName) ==0) {
						strSchNameToDisp = null;
					}else {//itis having a new school name.
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
						
			if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.	
				if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
					strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+" "+
								(String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);
								
					strCurSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+3))];
					strCurSY  = (String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);
					
				}else {
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
						
					}else if(strPrevSY.compareTo(strCurSY) ==0 && strPrevSem.compareTo(strCurSem)==0) {			
						strSYToDisp = null;
						strSemToDisp = null;			
					}else {//itis having a new school name.			
						strPrevSY = strCurSY;
						strPrevSem = strCurSem;
						
						strSYToDisp = strPrevSY;
						strSemToDisp = strPrevSem;			
					}
				}
			}
			
				if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//cross enrolled.
					//check if this is cross enrolled. 
					if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
						String strSQLQuery = "select gs_index from g_sheet_final join stud_curriculum_hist "+
						" on (stud_curriculum_hist.cur_hist_index = g_sheet_final.cur_hist_index) "+
						" where sy_from = "+vRetResult.elementAt(i+ 1)+" and semester = "+
						vRetResult.elementAt(i+ 3)+" and g_sheet_final.is_valid = 1 and "+
						" ce_sch_index is not null";
						if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null) {				
							if(strCrossEnrolleeSchPrev == null || strCrossEnrolleeSchPrev.compareTo(strSchoolName) != 0)  {
								strCrossEnrolleeSchPrev = strSchoolName;
								strCrossEnrolleeSch     = strSchoolName; 
								strSYSemToDisp = strCurSYSem;
								strSchNameToDisp = strSchoolName;
	//added to display cross enrolled school :: 2008-06-23 = added followed by request from AUF to show crossenrolled school name.
							}							
							//display will be schooo name<br>sy/term (cross enrolled)
							strSYSemToDisp = null;
							strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSYSem+" (CROSS ENROLLED)";
						}
					}
				}			
			 //Very important here, it print <!-- if it is not to be shown.
//			 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){strHideRowLHS = "<!--";//I have to do this so i will know if I am priting data or not%>
          <%//=//strHideRowLHS%>
          <%//iRowCount2 = 0;}else {
//				++iRowsPrinted;
//				strHideRowLHS = "";
//			//	System.out.println("iRowsPrinted 1:" + iRowsPrinted );
//				}//actual number of rows printed. 
			//check internship Info.. 
			strInternshipInfo = null;
			/**
			while(vInternshipInfo.size() > 0) {
				iTemp = ((Integer)vInternshipInfo.elementAt(0)).intValue();
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
				iTemp = ((Integer)vInternshipInfo.elementAt(0)).intValue();
				if(iTemp == i) {
					strInternshipInfo = (String)vInternshipInfo.remove(1);
					vInternshipInfo.remove(0);
				}else if(iTemp == i + 11) {//may be inc
					if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && 
					vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && 
					//&& ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 - remove the inc checking..
					((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
					((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
					((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		            WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
								strInternshipInfo = (String)vInternshipInfo.remove(1);
								vInternshipInfo.remove(0);
					}
			
				}
			}
			
//sub code sometimes makes 2 lines, I have to compare
iTemp = comUtilExtn.getLineCount(WI.getStrValue(vRetResult.elementAt(i + 6)), 14);
//iTitleLength = WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;").length();		
iTitleRowCount = comUtilExtn.getLineCount((String)vRetResult.elementAt(i + 7), iCharPerLine);

if(iTemp > iTitleRowCount)
	iTitleRowCount = iTemp;
iSubjHeight = iSubjHeight * iTitleRowCount;
	
iNumberRowCount+=iTitleRowCount;

if( strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp))))
	++iNumberRowCount;
	
if( strSYToDisp != null && strSemToDisp != null )
	++iNumberRowCount;
	
if(vMulRemark != null && vMulRemark.size() > 0){
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		iTitleRowCount = comUtilExtn.getLineCount(ConversionTable.replaceString((String)vMulRemark.elementAt(1),"\n","<br>"), 80);
		iNumberRowCount+=iTitleRowCount;
		iMulRemarkHeight = iMulRemarkHeight * iTitleRowCount;
	}
}

if(vEntranceData != null &&  (String)vEntranceData.elementAt(12) != null && !bolPrinted){	
	strTemp = WI.getStrValue((String)vEntranceData.elementAt(12));
	iTitleRowCount = comUtilExtn.getLineCount(strTemp, iCharPerLine);
	iNumberRowCount+=iTitleRowCount;	
}

if(iNumberRowCount > iTotalRowCount){
	bolPageBreak = true;
	if(strSYToDisp != null && strSemToDisp != null){
		strPrevSY = null;
		strPrevSem = null;
	}
	break;
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
          <tr valign="top" bgcolor="#FFFFFF">
            <td  height="<%=iMulRemarkHeight%>" colspan="<%=iColspan+3%>">&nbsp;
                <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
          </tr>
          <%}//end of if(iMulRemarkIndex == i)
			}//end of if(vMulRemark != null && vMulRemark.size() > 0) 
			if(vEntranceData != null &&  (String)vEntranceData.elementAt(12) != null && !bolPrinted){
					bolPrinted = true;
					//if last page, i have to show the remark.
					// iMaxRowToDisp = iMaxRowToDisp - 2;					
				iTemp = 1;
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
			
			%>
          <tr valign="top">
            <td height="20" colspan="<%=iColspan+3%>">&nbsp;
                <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
          </tr>
          <%}			
			if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){
				if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
					++iRowsPrinted;
		  %>
          <tr valign="top" bgcolor="#FFFFFF">
            <td height="20">&nbsp;</td>
            <td height="20" style="padding-left:10px;"><strong>
              <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strSchNameToDisp.toUpperCase()%></label>
            </strong></td>
            <td >&nbsp;</td>
            <td >&nbsp;</td>
            <td >&nbsp;</td>
          </tr>
          <%strPrevSchName = strSchNameToDisp;
			 } // if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp))))			
			if( strSYToDisp != null && strSemToDisp != null ){
					if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
					++iRowsPrinted;
				
				if(bolIsCareGiver && vEntranceData.elementAt(27) != null)
					strTemp = strSemToDisp +" "+ ((String)vEntranceData.elementAt(27)).toUpperCase();		
				else
					strTemp = strSemToDisp +" "+ strSYToDisp;
					
		  %>
          <tr valign="top" bgcolor="#FFFFFF">
            <td  height="20">&nbsp;</td>
            <td  height="20" style="padding-left:10px;"><strong>
              <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label>
            </strong></td>
            <td >&nbsp;</td>
            <td >&nbsp;</td>
            <td >&nbsp;</td>
          </tr>
          <%}%>
          <tr valign="top" bgcolor="#FFFFFF">
            <%	strTemp = WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;");
				if(strTemp.length() > 15)	
					strTemp = strTemp.substring(0, 15);// + " " + strTemp.substring(9, strTemp.length());		
			%>
            <td height="<%=iSubjHeight%>" style="padding-left:5px;">
			<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
            <%	if(iSubjHeight > 20)
					strTemp = WI.getStrValue(comUtilExtn.getTextPerLine()).toUpperCase();
				else
					strTemp = WI.getStrValue(WI.getStrValue(vRetResult.elementAt(i + 7)).toUpperCase(),"&nbsp;");
				//strTemp = WI.getStrValue(WI.getStrValue(vRetResult.elementAt(i + 7)).toUpperCase(),"&nbsp;");
			%>
            <td  style="padding-left:10px;">
			<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label>
                <%if(strInternshipInfo != null) {%>
                <br>
                <table width="100%">
                  <tr>
                    <td width="3%"></td>
                    <td><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strInternshipInfo%></label></td>
                  </tr>
                </table>
              <%}%>            </td>
<%	strGrade = WI.getStrValue(strGrade);	
	if(strGrade.equals("on going")) {
		strGrade = "GNYA";
		strCE = "";
	}else if(strGrade.compareToIgnoreCase("IP") == 0 || strGrade.compareToIgnoreCase("IN PROGRESS") == 0) {
		strGrade = "IN PROGRESS";
		strCE = "";
	}else {
		if(strGrade.indexOf(".") > -1 && strGrade.length() == 3) 
			strGrade = strGrade + "0";
	}
	
	if(bolIsCareGiver && strCE.length() > 0) 
		strCE = strCE + "hrs";
	//if(strCE.length() > 0 && strCE.indexOf(".") == -1)
	//	strCE=strCE.trim()+".0";				
	
	try{
		strCE = Integer.toString((int)Double.parseDouble(strCE));
	}catch(Exception e){}
%>
            <td width="7%" align="center" style="padding-right:30px;">
			<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(strGrade, "&nbsp;")%></label>
			</td>
            <%  strTemp = null;
				if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && vRetResult.elementAt(i + 6) != null && 
				   vRetResult.elementAt(i + 6 + 11) != null && 
				   ((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
				   ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
				   ((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
					WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
					//strTemp = (String)vRetResult.elementAt(i + 9 + 11);
				 	strTemp=WI.getStrValue((String)vRetResult.elementAt(i + 8 + 11),"&nbsp;"); 
				  	i += 11;						
				}
			%>
            <td width="7%" align="center" style="padding-right:17px;"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
            <td width="7%" align="center" style="padding-right:17px;"><%=WI.getStrValue(strCE,"&nbsp;")%></td>
          </tr>
          <%if(strMulRemarkAtEndOfSYTerm != null){%>
          <tr bgcolor="#FFFFFF">
            <td height="20" colspan="<%=iColspan+3%>"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"> <%=strMulRemarkAtEndOfSYTerm%></label></td>
          </tr>
          <%}//prints remarks at end of Sy/Term.%>
          <%
			   //if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
          <%//=strHideRowRHS%>
          <%//}else{
			  	//iRowCount2++;
			  	//}
			   }//end of for loop
		if (i+11 >= vRetResult.size()){
				iLastPage = 1;
				if(vGraduationData != null &&  vGraduationData.size() > 0 && false){
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
				
				iTemp = 1;
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
				 }else	
					strTemp += ".";
				 if(vGraduationData.elementAt(16) != null)
					strTemp = strTemp + " "+((String)vGraduationData.elementAt(16)).toUpperCase();
					
					if (strTemp.length()/100 > 0) {
						iTemp = strTemp.length()/100;
						if (strTemp.length()%100 > 0)
							iTemp +=1;
					}
				 iRowsPrinted += iTemp; 
			// 	System.out.println("iRowsPrinted 4:" + iRowsPrinted );
			%>
          <tr>
            <td  height="20"  colspan="<%=iColspan+3%>" align="center">&nbsp;
                <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
          </tr>
          <%} iRowsPrinted++; 
			//	System.out.println("iRowsPrinted 5:" + iRowsPrinted );
			// for nothing follows
			    strTemp = "thinborderLEFT";				
				if(iRowCount2 >= iMaxRowToDisp)
					strTemp = "thinborder";
		  %>
          <!-- <tr>
				<td class="<%=strTemp%>" height="18"  colspan="<%=iColspan+3%>" align="center">***** NOTHING FOLLOWS  ******</td>
			  </tr>-->
          <tr bgcolor="#FFFFFF">
            <td >&nbsp;</td>
            <td height="20"  align="center">***** NOTHING FOLLOWS  ******</td>
            <td >&nbsp;</td>
            <td>&nbsp;</td>
            <td >&nbsp;</td>
          </tr>
          <%if(vGraduationData != null && vGraduationData.elementAt(14) != null && false) {%>
          <tr>
            <td  height="18"  colspan="<%=iColspan+3%>" align="center">
			GRANTED TRANSFER CREDENTIAL EFFECTIVE <%=WI.formatDate((String)vGraduationData.elementAt(14),6).toUpperCase()%></td>
          </tr>
          <%}
			if(WI.fillTextValue("endof_tor_remark").length() > 0 && false) {%>
          <tr>
            <td height="20"  colspan="<%=iColspan+3%>" align="center">
			<%=WI.fillTextValue("endof_tor_remark")%></td>
          </tr>
          <%}
			if(iNumberRowCount < iTotalRowCount){
				//if(iNumberRowCount > iTotalRowCount)
				for(int xx = iNumberRowCount+1; xx <= iTotalRowCount; xx++){
				strTemp = "thinborderLEFT";				
				if(xx+1 > iTotalRowCount)
					strTemp = "thinborder";
		  %>
          
          <%}
			}			
			} // if (iLastPage == 1)
				else { // 			
					if(iOrgNumRowCount < iTotalRowCount){
						//if(iNumberRowCount > iTotalRowCount)
						for(int xx = iOrgNumRowCount+1; xx <= iTotalRowCount; xx++){
							strTemp = "thinborderLEFT";				
		  %>
          
          <%           }//end of for loop
				}%>
          <tr bgcolor="#FFFFFF">
            <td height="20" >&nbsp;</td>
            <td align="center">*****  more on page <%=++iPageNumber%> ******</td>
            <td >&nbsp;</td>
            <td >&nbsp;</td>
            <td >&nbsp;</td>
          </tr>
          <%}%>
        </table></td>
	</tr>
</table>		
<div style="bottom:0px;">
<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">
	<tr><td height="3">&nbsp;</td></tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="2" >
  <tr>
  	<td width="25%" height="105" align="center" valign="bottom"><%=WI.getStrValue(WI.fillTextValue("prep_by1"), "&nbsp;")%></td>
     <td width="25%" align="center" valign="bottom"><%=WI.getStrValue(WI.fillTextValue("check_by1"), "&nbsp;")%></td>
	 <td width="25%" align="center" valign="bottom"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "Auditor",7)).toUpperCase()%></td>
	 <td width="25%" align="center" valign="bottom"><%=WI.getStrValue(WI.fillTextValue("registrar_name"),"&nbsp;")%></td>
  </tr>
</table>

</div>
<%}//end of for vRetResult loop
}//end of vRetResult !=null && vRetResult.size()>0
  if(strPrintPage.compareTo("1") == 0){%>
<script language="javascript">
 window.print();
</script>
<%}%>
<script>
function PrintNextPage() {
	return;
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

<input type="hidden" name="endof_tor_remark" value="<%=WI.fillTextValue("endof_tor_remark")%>">
<input type="hidden" name="prep_by1" value="<%=WI.fillTextValue("prep_by1")%>">
<input type="hidden" name="check_by1" value="<%=WI.fillTextValue("check_by1")%>">
<input type="hidden" name="check_by2" value="<%=WI.fillTextValue("check_by2")%>">
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