<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student Permanent Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
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
-->
</style>
</head>
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-OTR","otr_print.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0){
			strErrMsg = "Imange file extension is missing. Please contact school admin.";
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
	Vector vStudInfo = null;
	Vector vAdditionalInfo = null;
	Vector vEntranceData = null;
	Vector vGraduationData = null;
	Vector vRetResult  = null;
	Vector vCompliedRequirement = null;	
	Vector vMulRemark = null;
	Vector vPmtSch = null;
    Vector vGradeInfo = null;
	
	int iMulRemarkIndex = -1;
	int iMaxCourseDisplay = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_course_disp"),"0"));	
	
	Vector vGradeDetail = new Vector();
	Vector vLecLabUnit = new Vector();	
	Vector vCourseSelected = new Vector(); 
	
	// extra condition for the selected courses
	String[] astrLecLabHr = null;//gets lec/lab hour information.
	String strRLEHrs    = null;
	String strCE        = null;		
	String strLecUnit  = null;
	String strLabUnit  = null;
	String strStudCourseToDisp = null; 
	String strStudMajorToDisp = null;
	String[] strTok = null; 
	String[] astrConvertSem = {"Summer","First","Second","Third","Fourth"};
	String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};
	String strCourseIndex = null;//this is the course selected. If no course is selected, I get from student info.. 	
	String strExtraCon = " and (";
	String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);
	
	boolean viewAll = true;	
	boolean bolIsRLEHrs = false;
	boolean bolShowLecLabHr = false; 
	
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

	enrollment.StudentPermanentRecord SPR = new enrollment.StudentPermanentRecord();	
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
		enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
		vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);
				
//		Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,request.getParameter("stud_id"),(String)vStudInfo.elementAt(7),
//															(String)vStudInfo.elementAt(8));
//		if (vFirstEnrl != null) {
//			vRetResult = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
//											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
//											(String)vFirstEnrl.elementAt(2),false,false,true);
//										
//			if(vRetResult == null && strErrMsg == null)
//				strErrMsg = cRequirement.getErrMsg();
//			else{
//				vCompliedRequirement = (Vector)vRetResult.elementAt(1);
//			}
//		}else 
//		   strErrMsg = cRequirement.getErrMsg();		
		
		if(vRetResult != null && vRetResult.size() > 0) {
			vLecLabUnit = repRegistrar.getLecLabUnitInfoDBTC(dbOP, (String)vStudInfo.elementAt(12));
			if(vLecLabUnit == null)
				vLecLabUnit = new Vector();
		}
		
		vGradeDetail = SPR.getStudentGrade(dbOP,(String)vStudInfo.elementAt(12));	
		if(vGradeDetail == null)
			strErrMsg = SPR.getErrMsg();
		else{	
			vPmtSch = (Vector) vGradeDetail.elementAt(0);
			vGradeInfo = (Vector) vGradeDetail.elementAt(1);		
		} 
	}

	//save encoded information if save is clicked.
	Vector vForm17Info = null;
	vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
	if(vForm17Info != null && vForm17Info.size() ==0)
		vForm17Info = null;
	

	if(vStudInfo != null && vStudInfo.size() > 0) {
		strDegreeType = (String)vStudInfo.elementAt(15);
		if(vCourseSelected.size() > 0) {
			strTemp = "select degree_type from course_offered where course_index in ("
			         +CommonUtil.convertVectorToCSV(vCourseSelected)+")";
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
/**
if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);
}**/
	
	if(vRetResult.toString().indexOf("hrs") > 0 && WI.fillTextValue("show_rle").compareTo("1") == 0)
		bolIsRLEHrs = true;
	
	if(WI.fillTextValue("show_leclab").compareTo("1") == 0)	
		bolShowLecLabHr = true;
		
		
	String strPrevSchName = null;
	int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
	String strSchoolName = null;
	
	String strSchNameToDisp = null;
	
	String strSYSemToDisp   = null;
	String strCurSYSem      = null;
	String strPrevSYSem     = null;
	
	boolean bolIsSchNameNull    = false;
	boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has 
	//school name after it is null, it is encoded as cross enrollee.
	
	String strHideRowLHS = "<!--";
	String strHideRowRHS = "-->";
	
	String strCrossEnrolleeSchPrev   = null;
	String strCrossEnrolleeSch       = null;
%>
<body topmargin="5">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr> 
		<td width="587">
			<div align="center">
			<strong><font size="4"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
			<font size="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%>, 
			<%=SchoolInformation.getAddressLine2(dbOP,false,false)%> </font><br><br>
			<font size="2">OFFICE OF THE REGISTRAR<br>STUDENT'S PERMANENT RECORD</font></div><br>
		</td>	
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td width="6%" valign="bottom" height="20">Name</td>
		<td width="54%" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
			<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
			<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%>
			</div>
		</td>
		<td width="16%" valign="bottom" style="padding-left:20px;">Date of Birth</td>
		<td width="18%" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<%=WI.getStrValue(vAdditionalInfo.elementAt(1))%>
			</div>
		</td>
	</tr>
	<tr>
		<td colspan="4">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr>
					<td width="12%" height="20" valign="bottom">Place of Birth</td>
					<td width="17%" valign="bottom">
						<div style="border-bottom:solid 1px #000000;">
						<%=WI.getStrValue(vAdditionalInfo.elementAt(2))%>
						</div>
					</td>
					<td width="17%" valign="bottom" style="padding-left:10px;">Entrance Credit From</td>
					<td width="19%" valign="bottom">
						<div style="border-bottom:solid 1px #000000;">
						<% if (vEntranceData != null && vEntranceData.size()>0) {
								strTemp = (String)vEntranceData.elementAt(7);
								if (strTemp == null) 
									strTemp = (String)vEntranceData.elementAt(5);
							}
						%>	
						<%=WI.getStrValue(strTemp)%>
						</div>
					</td>
					<td width="7%" valign="bottom" style="padding-left:5px;">Location</td>
					<td width="13%" valign="bottom">
						<div style="border-bottom:solid 1px #000000;">
						<%if(vEntranceData != null) {%>
							<%=(String)vEntranceData.elementAt(35)%>
						<%}%>
						</div>
					</td>
					<td width="5%" valign="bottom" style="padding-left:10px;">S/Y</td>
					<td width="10%" valign="bottom"><div style="border-bottom:solid 1px #000000;">
						<%if(vEntranceData != null) {
							if(vEntranceData.elementAt(24) != null) {
								strTemp =Integer.toString(Integer.parseInt((String)vEntranceData.elementAt(24)) - 1)
										+" - " +(String)vEntranceData.elementAt(24);
							}else	
								strTemp = (String)vEntranceData.elementAt(21) +" - " +(String)vEntranceData.elementAt(22);
						  }else	
							strTemp = "&nbsp;";
						%>
						<%=WI.getStrValue(strTemp,"&nbsp;")%></div></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="4">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr>
					<td width="31%" height="20" valign="bottom">Basis of Admission Certification</td>
						<% if(vEntranceData != null)
								strTemp = astrConvertToDocType[Integer.parseInt((String)vEntranceData.elementAt(8))];
						%>
					<td width="29%" valign="bottom">
					<div style="border-bottom:solid 1px #000000;">
					<%=WI.getStrValue(strTemp,"&nbsp;")%>
					</div></td>
					<td width="9%" valign="bottom" style="padding-left:10px;">Transfer</td>
					<td width="31%" valign="bottom">					
					<div style="border-bottom:solid 1px #000000;">
					<% 
					String strSchName = null;
					for(int x=0; x<vRetResult.size(); x+=11){
						strErrMsg = WI.getStrValue((String)vRetResult.elementAt(x));
						
						strTemp = SchoolInformation.getSchoolName(dbOP,false,false);
						
						if( !strTemp.equalsIgnoreCase(strErrMsg) )
							strSchName = strErrMsg;						
					  }%><%=WI.getStrValue(strSchName,"&nbsp;")%>
					</div></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
	<td height="25" colspan="4">&nbsp;</td>
	</tr>
</table>
<%if(WI.fillTextValue("row_start_fr").compareTo("0") != 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="10" class="thinborderBOTTOM">&nbsp;</td>
</table>
<%}
if(vRetResult != null && vRetResult.size() > 0){
		int iNumWeeks = 0;
		if (WI.fillTextValue("weeks").length() > 0) iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));	
		boolean bolPageBreak = false;
		int iMaxSemPerPage =2;			
		int iIncr =0;
		String strPrevSYTerm = "";
		String strCurrSYSem = null;
		int iCurrentRow = 0;	
		Integer objInt = null;
		double dTotal = 0d;
		double dUnit = 0d;
		String strSchoolDays = null;
		String strGrade = null;
		for(int i = 0 ; i < vRetResult.size();i += 11, ++iCurrentRow){
		
		if(bolPageBreak){%>
			<DIV style="page-break-after:always">&nbsp;</DIV>	
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
				 <td width="45" valign="bottom" height="20">Name</td>
					<td width="358" valign="bottom"><div style="border-bottom:solid 1px #000000;">		
					<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
					<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
					<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%>
					</div></td>
				  <td width="553">&nbsp;</td>
				</tr>
			</table>
		
		<%}
		
%> 
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="bottom">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr>
				<%
				try{					
					strTemp = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+3))];
				}catch(NumberFormatException nfe){
					strTemp = (String)vRetResult.elementAt(i+3);
				}
				%>
					<td width="16%" height="25" valign="bottom" style="padding-left:20px;" align="center">
					<div style="border-bottom:solid 1px #000000;"><%=strTemp%></div>
					</td>
					<td width="12%" valign="bottom" style="padding-left:20px;">Semester</td>
					<%if(i==0){%>
					<td width="19%" valign="bottom" style="padding-left:20px;">Date of Admission</td>
					<td width="17%" height="25" valign="bottom" align="center">
						<div style="border-bottom:solid 1px #000000;">
						<%if(vEntranceData != null) {%>
							<%=WI.getStrValue((String)vEntranceData.elementAt(23),"")%>
						<%}%>
						</div>
					</td>
					<%}%>
					<td width="13%" valign="bottom" align="right">School Year</td>
					<td width="23%" height="25" valign="bottom" align="center" style="padding-left:10px;">
					<div style="border-bottom:solid 1px #000000;">
					<%=(String)vRetResult.elementAt(i+1)%> - <%=(String)vRetResult.elementAt(i+2)%>
					</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<%if(i==0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td width="7%" height="25" valign="bottom">Course:</td>
		<td width="93%" valign="bottom">
		<%=WI.getStrValue((String)vStudInfo.elementAt(7)).toUpperCase()%> 
		(<%=((String)vStudInfo.elementAt(24)).toUpperCase()%>)
	  </td>
	</tr>
</table>
<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
	  <td valign="bottom">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr>
					<td width="2%">&nbsp;</td>
					<td width="9%" height="25" valign="bottom">Competency:</td>
				  <td width="89%" valign="bottom"><%=WI.getStrValue((String)vStudInfo.elementAt(8))%></td>
				</tr>	
			</table>	
	  </td>
	</tr>	
	<tr>
	   <td height="35" align="center">SCHOOL RECORD</td>		
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
 <%	int iColspan = 0;
  if(vPmtSch!=null && vPmtSch.size()>0){
	iColspan = vPmtSch.size()/2;
	int iCount = iColspan;
	String strPmtSch = null;		
 %>  
	<tr>
		<td width="15%" rowspan="2" class="thinborder" height="20">&nbsp;Course No.</td>
		<td width="23%" rowspan="2" class="thinborder" height="20">&nbsp;Description Title</td>
		<td height="20" colspan="<%=iColspan%>" class="thinborder" align="center">&nbsp;Periodic Rating</td>
			<td width="10%" align="center" class="thinborder" height="20">Final</td>
		<td width="9%" align="center" class="thinborder" height="20">Action</td>
		<td align="center" colspan="2" class="thinborder" height="20">No. of Hrs.</td>
		<td width="6%" align="center" class="thinborder" height="20">Unit</td>
	</tr>		
	<tr>
		<%for (int x = 0; x < vPmtSch.size(); x +=2) {%>
				<td height="20" class="thinborder" align="center">
			<%=vPmtSch.elementAt(x)%></td>
		<%}//end of vPmtSch loop%>
		<td align="center" class="thinborder" height="20">Rating</td>
		<td align="center" class="thinborder" height="20">Taken</td>
		<td align="center" width="6%" class="thinborder" height="20">Lec</td>
		<td align="center" width="8%" class="thinborder" height="20">Lab</td>
		<td align="center" class="thinborder" height="20">Total</td>
	</tr>	
<% 	


	for( ; i < vRetResult.size(); i += 11, ++iCurrentRow){
	
	strCurrSYSem = (String) vRetResult.elementAt(i+3) + (String) vRetResult.elementAt(i+1)+ (String) vRetResult.elementAt(i+2);
		   
	if(!strPrevSYTerm.equals(strCurrSYSem) && i > 0)	{
		i-=11;
		strPrevSYTerm = 	strCurrSYSem;
		break;
	}else
		strPrevSYTerm = 	strCurrSYSem;
		   		   
//I have to now check if this subject is having RLE hours. 
//String strRLEHrs    = null;
//String strCE        = null;

	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && 
		((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6 + 11) != null 
	   	&& vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) {   			//semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
	}
	else {
		strTemp = (String)vRetResult.elementAt(i + 9);
	}
	strCE        = strTemp;
	
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
		
	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) //cross enrolled.
		strSchoolName += " (CROSS ENROLLED)";		
// uncomment this if school name apprears once.
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
	if(strSchoolName == null){// && vRetResult.elementAt(i + 10) != null)//subject group name is not null for reg.sub
		strSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);
	}
		
	if(strSchoolName != null){
		strSchNameToDisp = strSchoolName;			
	}
 	//if prev school name is not not null, show the current shcool name.
	if(strSchoolName == null && strPrevSchName != null) {
		strSchNameToDisp = strCurrentSchoolName;
		strPrevSchName = null;
	}

//System.out.println("strSchNameToDisp "+strSchNameToDisp + " strPrevSchName " +strPrevSchName);


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


if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){//do not keep extra line for school name.
%>
	<tr bgcolor="#FFFFFF"> 
		<td height="20" colspan="9" class="thinborder" align="center">
			<strong><u><%=strSchNameToDisp.toUpperCase()%></u></strong>
		</td>
	</tr>
<%	strPrevSchName = strSchNameToDisp;}



	if(vMulRemark != null && vMulRemark.size() > 0) {
		iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
		if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
%>
	<tr bgcolor="#FFFFFF"> 
		<td height="20" colspan="9" class="thinborderALL" align="center"> 
		<%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%>
		</td>
	</tr>
   	 <%}//end of if
	}//end of vMulRemark.
//if(strSYSemToDisp != null){%>
  <%--<tr bgcolor="#FFFFFF"> 
    <td height="17" colspan="9" class="thinborderLEFTRIGHT">&nbsp;&nbsp;<strong> 
      <u><%=strSYSemToDisp%><%=WI.getStrValue(strSchNameToDisp," - ","","")%></u></strong></td>
  </tr>--%>
  <%//}
 	int iIndexOf   = 0;  
    //get lec lab unit
	try {
		strLecUnit = "0";
		strLabUnit = "0";
		double dCE = Double.parseDouble(strCE);
		if(dCE > 0d) {
			//I have to now get lec and lab units.. 
			strTemp = (String)vRetResult.elementAt(i + 6);
			if(strTemp.startsWith("NSTP") && strTemp.indexOf("(") > 0) 
				strTemp = strTemp.substring(0, strTemp.indexOf("("));
				
			iIndexOf = vLecLabUnit.indexOf(strTemp);
			while(iIndexOf > -1) {
				if(vLecLabUnit.elementAt(iIndexOf + 1).equals(vRetResult.elementAt(i + 7)) ) {
					strLecUnit = (String)vLecLabUnit.elementAt(iIndexOf + 2);
					strLabUnit = (String)vLecLabUnit.elementAt(iIndexOf + 3);
					
					if(strLecUnit != null && strLecUnit.length() > 0 && strLecUnit.endsWith(".0"))
						strLecUnit = strLecUnit.substring(0, strLecUnit.length() - 2);
					if(strLabUnit != null && strLabUnit.length() > 0 && strLabUnit.endsWith(".0"))
						strLabUnit = strLabUnit.substring(0, strLabUnit.length() - 2);
					break;
				}
				iIndexOf = vLecLabUnit.indexOf((String)vRetResult.elementAt(i + 6), iIndexOf + 2);
			}
		}
	}catch(Exception e) {	
		
	}	
	  String strSYTerm = (String) vRetResult.elementAt(i+1) +"-"+ (String) vRetResult.elementAt(i+2)
									+" to "+ (String) vRetResult.elementAt(i+3);
	  String strSubCode = (String)vRetResult.elementAt(i+6) + " " + strSYTerm ; 
	  int iIndexOf1= 0;
	  Vector vTemp = new Vector();
	  strErrMsg = "&nbsp;";
	  strSchoolDays = "&nbsp;";
	  if( (iIndexOf1 = vGradeInfo.indexOf(strSubCode)) > -1){
			vGradeInfo.remove(iIndexOf1);
			strSchoolDays =(String)vGradeInfo.remove(iIndexOf1);
			 vTemp = (Vector)vGradeInfo.remove(iIndexOf1);
			 strErrMsg = WI.getStrValue(vGradeInfo.remove(iIndexOf1),"&nbsp;");
	  }
  %>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
    <td height="20" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></td>	
    
	<%for (int x = 0; x < vPmtSch.size(); x += 2) {		
	   if(WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;").compareTo("on going") == 0){
	   		strTemp = "Grade not Ready";
	   }else{	    
			if(vTemp != null && vTemp.size() > 0)
				strTemp = WI.getStrValue(vTemp.remove(0),"&nbsp;");
			else
				strTemp = "&nbsp;";
		}
	%>     
		<td class="thinborder" align="center"><%=strTemp%></td>
	<%}%>
	<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
	
	<%
	if(WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;").compareTo("on going") == 0){
		strErrMsg = "&nbsp;";
		strLecUnit = "&nbsp;";
		strLabUnit = "&nbsp;";
		strTemp = "&nbsp;";
	}else{
		
		dUnit = Double.parseDouble((String)strCE);
		strTemp = CommonUtil.formatFloat(dUnit, true);
	}
	%>
	
		
	<td height="20" class="thinborder" align="center"><%=strErrMsg%></td>	
	<td height="20" class="thinborder" align="center"><%=strLecUnit%></td>
	<td height="20" class="thinborder" align="center"><%=strLabUnit%></td>	 
	<td width="2%" height="20" align="center" class="thinborder"><%=strTemp%> 
	</td>
    <%dTotal+=dUnit;%>	
  </tr>  
  <%//if(false && ( iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt )){%>
  	<%//=strHideRowRHS%> 
  <%//}
 }//end of for loop
 }//end of vPmtSch !=null && vPmtSch.size()>0%>
</table>
<table width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td width="96%" height="20" align="right" valign="bottom" style="padding-right:30px;">TOTAL</td>
	<td width="4%" valign="bottom"><%=dTotal%></td>
  </tr>
  <tr>
  	<td colspan="2" valign="bottom"><div style="border-top:solid 1px #000000;"></div></td>
  </tr>
  <tr>
 	 <td colspan="2" height="20" align="center">School Days <%=WI.getStrValue(strSchoolDays,"")%></td>
  </tr>
  <tr>
 	 <td colspan="2" valign="bottom"><div style="border-top:solid 1px #000000;"></div></td>
  </tr>	
</table>
<%if (++iIncr>=iMaxSemPerPage){
	bolPageBreak  =true;
	iIncr =0;

   // bolPageBreak = false;
}
  dTotal= 0;
  dUnit= 0;
}//end of upper loop 
}//end of vRetResult != null && vRetResult.size()>0%>
<%if(WI.fillTextValue("print_").compareTo("1") == 0){%>
<script language="javascript">
 window.print();
</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
