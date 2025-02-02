<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

	
    .thinborderALL {
		border-left: solid 1px #CCCCCC;
		border-right: solid 1px #CCCCCC;
		border-top: solid 1px #CCCCCC;
		border-bottom: solid 1px #CCCCCC;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
		font-size: 12px;
    }



	
-->
</style>
</head>
<script language="javascript">
function HideImg() {
	document.getElementById('hide_img').innerHTML = "";
}

function disableRightClick(e){
	var message = "Right click disabled";
	if(!document.rightClickDisabled){ // initialize
		if(document.layers){
			document.captureEvents(Event.MOUSEDOWN);
			document.onmousedown = disableRightClick;
		}else 
			document.oncontextmenu = disableRightClick;		
			return document.rightClickDisabled = true;	
	}	
	if(document.layers || (document.getElementById && !document.all)){
		if (e.which==2||e.which==3){
			alert(message);
			return false;
		}
	}else{
		alert(message);
		return false;
	}
}	
//disableRightClick();
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
	String strRootPath  = null;
	
	String strPrintValueCSV = "";
	
	if(false && WI.fillTextValue("print_all_pages").equals("1")) { //print all page called.
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
		
		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
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
	java.sql.ResultSet rs = null;
	
	int iLevelID = 0;	
	Vector vMulRemark = null;
	int iMulRemarkIndex = -1;	
	
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
	// end extra condition for the selected courses..

	String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};	
	String[] astrConvertSemUG  = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};
	String[] astrConvertSemMED = {"SUMMER","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR"};
	String[] astrConvertSemMAS = {"Summer","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER",""};
	String[] astrYearLevel = {"FIRST","SECOND","THIRD","FOURTH","FIFTH","SIXTH"};
	
	enrollment.GradeSystem GS = new enrollment.GradeSystem();
	enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
	enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
	enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();
	
	//this is needed if there is a option to include or not include the Transferee information.
	if(!WI.fillTextValue("tf_sel_list").equals("-1")) {
		if(WI.fillTextValue("tf_sel_list").length() == 0) 
			repRegistrar.strTFList = "0";
		else	
			repRegistrar.strTFList = WI.fillTextValue("tf_sel_list");		
	}
	//end...

	if(WI.fillTextValue("stud_id").length() > 0) {
		vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
		if(vStudInfo == null || vStudInfo.size() ==0)
			strErrMsg = offlineAdm.getErrMsg();
	}
	
	if(vStudInfo != null && vStudInfo.size() > 0) {
		strDegreeType = (String)vStudInfo.elementAt(15);
	
		if(vCourseSelected.size() > 0) {
			strTemp = "select degree_type from course_offered where course_index in ("+
			CommonUtil.convertVectorToCSV(vCourseSelected)+")";
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
			
		vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, false, strExtraCon);

		if(vRetResult == null)
			strErrMsg = repRegistrar.getErrMsg();
	}
	
	String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);
	
	boolean bolIsRLEHrs = false;
	boolean bolShowLecLabHr = false; String[] astrLecLabHr = null;//gets lec/lab hour information.
	String strRLEHrs    = null;
	String strCE        = null;	
	boolean bolIsMedTOR = strDegreeType.equals("2");
	
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
<body topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0"> 
<form action="./otr_print_SWU_gpa.jsp" method="post" name="form_">
<%

if(vRetResult != null && vRetResult.size() > 0){
	int iNumWeeks = 0;
	if (WI.fillTextValue("weeks").length() > 0) 
		iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));

String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAdd  = SchoolInformation.getAddressLine1(dbOP, false, false);
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center">
		<strong><%=strSchName%></strong><br><%=strSchAdd%><br>
		<strong>Grades Point Average<br><br>					
		<%=WI.fillTextValue("stud_id")%> &nbsp; <%=WI.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),1)%>
		&nbsp; <%=(String)vStudInfo.elementAt(24)%>
		</strong>
	</td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">			
	<tr>
		<td width="20%" height="25" align="center" class="thinborderALL">Term</td>
		<td height="25" align="center" class="thinborderALL">Subject</td>
		<td width="9%" align="center" class="thinborderALL">Rating</td>
		<td width="9%" align="right" class="thinborderALL">Equivalent</td>
		<td width="9%" align="center" class="thinborderALL">Units</td>										
		<td width="9%" align="center" class="thinborderALL">Average<br>Rating</td>
		<td width="9%" align="center" class="thinborderALL"><font size="1">Grades Below 25</font></td>
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
	int iCurrentRow = 0;
	
	String strInternshipInfo = null;
	
	String strCrossEnrolleeSchPrev   = null;
	String strCrossEnrolleeSch       = null;
	
	double dTotalUnit		= 0d;
	double dSubjectUnit     = 0d;
	double dAveRating 		= 0d;
	double dEquivalent 		= 0d;
	double dGrade 			= 0d;
	double dTotAveRating 	= 0d;
	double dGrandAveRating 	= 0d;
	double dGrandUnits 		= 0d;
	String strBelow25 		= null;//below 2.5
	String strSubIndex		= null;
	
	strTemp = "select sub_index from subject where is_del = 0 and sub_code = ? ";
	java.sql.PreparedStatement pstmtSelect = dbOP.getPreparedStatement(strTemp);
	
	if(vInternshipInfo == null)
		vInternshipInfo = new Vector();
	
	for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){

//I have to now check if this subject is having RLE hours. 
//String strRLEHrs    = null;
//String strCE        = null;
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && 
		//((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 &&  -- removed for inc checking. 
		vRetResult.elementAt(i + 6) != null && vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) {   //semester
			strTemp  = (String)vRetResult.elementAt(i + 9 + 11);
			strGrade = (String)vRetResult.elementAt(i + 8 + 11); 
	}else {
		strTemp  = (String)vRetResult.elementAt(i + 9);
		strGrade = (String)vRetResult.elementAt(i + 8);
	}
	
	strCE  = strTemp;
	
//	if (strCE!= null && strCE.equals("0") && WI.getStrValue((String)vRetResult.elementAt(i + 8),"").toLowerCase().equals("drp")) {
//		//strCE = "-";
//	}
	
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
	
	

	//strCurSYSem =
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
		if(strCrossEnrolleeSchPrev == null || strCrossEnrolleeSchPrev.compareTo(strSchoolName) != 0)  {
			strCrossEnrolleeSchPrev = strSchoolName;
			strCrossEnrolleeSch     = strSchoolName; 
			strSYToDisp = strCurSY;
			strSemToDisp = strCurSem;			
			strSchNameToDisp = strSchoolName;//added to display cross enrolled school :: 2008-06-23 = added followed by request from AUF to show crossenrolled school name.
		}
	}
	//cross enrolled.. 
	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//display will be schooo name<br>sy/term (cross enrolled)
		strSYToDisp = null;
		strSemToDisp = null;		
		strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSY+" "+strCurSem+" (CROSS ENROLLED)";
	}


/*if(strSYToDisp != null && strSemToDisp != null){
	if(strSchNameToDisp == null)
		strSchNameToDisp = "";
	if(strPrevSchName == null)
		strPrevSchName = "";
	strSchNameToDisp = strCurrentSchoolName;
}*/

if(strSYToDisp != null && strSemToDisp != null){
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
if(bolIsCareGiver && vEntranceData.elementAt(27) != null)
	strTemp = strSemToDisp +" "+ ((String)vEntranceData.elementAt(27)).toUpperCase();		
else
	strTemp = strSemToDisp +" "+ strSYToDisp;		

if(i > 0){
%>	
	<tr bgcolor="#FFFFFF">
	    <td height="14">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td align="center">&nbsp;</td>
	    <td align="center">&nbsp;</td>
	    <td align="right" style="border:solid 1px #CCCCCC;"><strong><%=CommonUtil.formatFloat(dTotalUnit, 1)%></strong></td>     
		<td align="right" style="border:solid 1px #CCCCCC;"><strong><%=CommonUtil.formatFloat(dTotAveRating,true)%></strong></td>
	    <td align="center">&nbsp;</td>
	</tr>
<%}%>
	<tr bgcolor="#FFFFFF">
		<td height=""><strong><%=strSemToDisp%></strong></td>  	    	
		<td colspan="6"><strong><%=strSYToDisp%> <%=strSchNameToDisp.toUpperCase()%></strong></td>
	</tr>
  
<%
dTotAveRating = 0d;
dTotalUnit = 0d;
}
strSubIndex =null;

if(WI.getStrValue(vRetResult.elementAt(i + 6)).length() > 0){
	pstmtSelect.setString(1, (String)vRetResult.elementAt(i + 6));
	rs = pstmtSelect.executeQuery();
	if(rs.next())
		strSubIndex = rs.getString(1);
	rs.close();
}

dSubjectUnit = 0d;
if(strSubIndex != null && strSubIndex.length() > 0){//get the subject unit first
	strTemp = GS.getLoadingForSubject(dbOP, strSubIndex);
	dSubjectUnit = Double.parseDouble(WI.getStrValue(strTemp,"0"));
}

try{
	if(dSubjectUnit == 0d)//if sub unit is 0, maybe its transfee, get the Credit Earned
		dSubjectUnit = Double.parseDouble(strCE);
}catch(Exception e){
	dSubjectUnit  = 0d;
}

strGrade = WI.getStrValue(strGrade);

if(strGrade.equals("on going")) {
	strGrade = "enrolled";
	//strCE = "";
}else if(strGrade.compareToIgnoreCase("IP") == 0) {
	strGrade = "IP";
	//strCE = "";
}else {
	if(strGrade.indexOf(".") > -1 && strGrade.length() == 3) 
		strGrade = strGrade + "0";
}

try{
	dGrade = Double.parseDouble(strGrade);
}catch(Exception e){
	dGrade  = 0d;
}

strBelow25 = "";
if(dGrade > 0 && dGrade > 2.5)//1 is the highest, 5 lowest
	strBelow25 = CommonUtil.formatFloat(dGrade,1);

dEquivalent = dGrade;

try{
	dAveRating = dGrade * dSubjectUnit;
}catch(Exception e){
	dAveRating  = 0d;
}

if(dAveRating > 0d){
	dTotalUnit += dSubjectUnit;
	dGrandUnits +=  dSubjectUnit;
}

dTotAveRating += dAveRating;
dGrandAveRating  += dAveRating;



%>
	<tr bgcolor="#FFFFFF">      
		<td height="14">&nbsp;</td>  
		<td><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
		<td align="center"><%=strGrade%></td>
		<td align="right"><%=CommonUtil.formatFloat(dEquivalent,1)%></td>
		<td align="right"><%=CommonUtil.formatFloat(dSubjectUnit,1)%></td>
		<td align="right"><%=CommonUtil.formatFloat(dAveRating,true)%></td>
		<td align="center"><%=strBelow25%></td> 
	</tr>

<%}//end of for loop%>   
	<tr bgcolor="#FFFFFF">
	    <td height="14">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td align="center">&nbsp;</td>
	    <td align="center">&nbsp;</td>
	    <td align="right" style="border:solid 1px #CCCCCC;"><strong><%=CommonUtil.formatFloat(dTotalUnit, 1)%></strong></td>     
		<td align="right" style="border:solid 1px #CCCCCC;"><strong><%=CommonUtil.formatFloat(dTotAveRating,true)%></strong></td>
	    <td align="center">&nbsp;</td>
	</tr>
	<tr bgcolor="#FFFFFF">
	    <td height="14">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td align="center">&nbsp;</td>
	    <td align="right" style="border:solid 1px #CCCCCC;"><strong><%=CommonUtil.formatFloat(dGrandAveRating,true)%></strong></td>
		<td align="right" style="border:solid 1px #CCCCCC;"><strong><%=CommonUtil.formatFloat(dGrandUnits,1)%></strong></td>     
		<td align="right"><strong>AVG:</strong></td>
	    <%
		if(dGrandUnits > 0)
			dGrandUnits = dGrandAveRating / dGrandUnits;
		else
			dGrandUnits = 0d;
		%>
		<td align="right" style="border:solid 1px #CCCCCC;"><strong><%=CommonUtil.formatFloat(dGrandUnits,true)%></strong></td>
	</tr>
   
</table>

<%}//only if student is having grade infromation.%>
<%//System.out.println(WI.fillTextValue("print_"));
if(strPrintPage.compareTo("1") == 0){%>
<script language="javascript">
 window.print();
</script>
<%}%>

<input type="hidden" name="curr_stud_id" value="<%=WI.fillTextValue("curr_stud_id")%>">
<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="max_course_disp" value="<%=WI.fillTextValue("max_course_disp")%>">
<%//I have to construct here what are the courses checked already.. 
int iMaxCourseDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_course_disp"), "0"));
for(int i = 0; i < iMaxCourseDisp; ++i) {%>
	<input type="hidden" name="checkbox<%=i%>" value="<%=WI.fillTextValue("checkbox"+i)%>">
<%}%>
<input name="show_spr" type="hidden" value="<%=WI.fillTextValue("show_spr")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>