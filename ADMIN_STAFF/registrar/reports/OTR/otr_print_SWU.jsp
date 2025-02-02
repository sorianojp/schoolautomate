<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SWU OFFICIAL TRANSCRIPT OF RECORD</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: "Courier New", Courier, monospace;
	font-size: 13px;
}
td {

	font-family: "Courier New", Courier, monospace;
	font-size: 13px;
}
th {
	font-family: "Courier New", Courier, monospace;
	font-size: 13px;
}
.fontsize9 {
	font-family: "Courier New", Courier, monospace;	
	font-size: 7px;
}
.fontsize14{
	font-family: "Courier New", Courier, monospace;
	font-size: 13px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }	
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;
    }
    .thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;
    }

    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }
    TD.thinborderRIGHTBOTTOM {
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }
	
	TD.thinborderTOPRIGHTBOTTOM {
	border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }
	
	TD.thinborderTOPLEFTBOTTOM {
	border-top: solid 2px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }
	
	TD.thinborderTOPLEFT{
	border-top: solid 2px #000000;
    border-left: solid 1px #000000;    
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }
	
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }
	
	TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
    }
	
    TD.thinborderLEFTRIGHTBOTTOM {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 13px;	
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
<form action="./otr_print_SWU.jsp" method="post" name="form_">
<%if(iPageNumber > 1){%>
<br><br><br><br><br>
<br><br><br><br><br><br>
<table align="center" onMouseDown="return false" width="95%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();" class="thinborder"> 
	<tr>
		 <td width="25%" height="25" class="thinborderLEFT">&nbsp;SURNAME</td>
		 <td width="30%">FIRSTNAME</td>
		 <td width="22%">MIDDLE NAME</td>
		 <td width="23%" align="center" class="thinborderLEFT">STUDENT NUMBER</td>
	</tr>
	<tr>
		<td height="25" class="thinborderLEFTBOTTOM">
		&nbsp;<strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></strong></td>
		<td class="thinborderBOTTOM"><strong><%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%></strong></td>
		<td class="thinborderBOTTOM"><strong><%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
		<td align="center" class="thinborderLEFTBOTTOM"><strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong></td>
	</tr>   
</table>
<%}else{%>
<br><br><br><br><br>
<br><br><br><br><br><br>
<table class="thinborder" align="center" onMouseDown="return false" width="95%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
	<tr>
		<td valign="bottom" class="thinborder">
			<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();"> 
				<tr>
					 <td width="25%" height="24">&nbsp;SURNAME</td>
					 <td width="31%">FIRSTNAME</td>
					 <td width="15%">MIDDLE NAME</td>
					 <td width="29%" align="center">STUDENT NUMBER</td>
				</tr>
				<tr>
					<td height="24">&nbsp;<strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></strong></td>
					<td><strong><%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%></strong></td>
					<td><strong><%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
					<td align="center"><strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="bottom" class="thinborder">
			<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
				<tr>
					<td width="19%" height="24">&nbsp;CITIZENSHIP</td>
					<td width="12%">SEX</td>
					<td width="18%">CIVIL STATUS</td>
					<td width="22%">RELIGION</td>
					<td width="29%" rowspan="8" class="thinborderLEFT" valign="top">
					
					<%
					strErrMsg = strRootPath+"upload_img/"+WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt;
					java.io.File file = new java.io.File(strErrMsg);
					if(file.exists()) {
						strErrMsg = "../../../../upload_img/"+WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt;						
						strTemp = "<img src=\""+strErrMsg+"\"  style='width:2in; height:2in;' name='stud_image'>";
					}
					else {
						strTemp = "<img src='../../../../images/blank.gif' name='stud_image' style='width:2in; height:2in;' border='1'>";
					}
					%>
					<%=strTemp%></td>
				</tr>
				<tr>
					<td height="24">&nbsp;<strong><%=WI.getStrValue((String)vStudInfo.elementAt(23), "&nbsp;").toUpperCase()%>
					</strong>
					</td>
					<%	strTemp = (String)vStudInfo.elementAt(16);
						if(strTemp.equals("M"))
							strTemp = "MALE";
						else
							strTemp = "FEMALE";
					%>
					<td><strong><%=strTemp.toUpperCase()%></strong></td>
					<td><strong><%=WI.getStrValue((String)vAdditionalInfo.elementAt(12)).toUpperCase()%></strong></td>
					<td><strong><%=WI.getStrValue(strReligion).toUpperCase()%></strong></td>
				</tr>
				<tr>
					<td class="thinborderTOP" width="19%" height="24">&nbsp;DATE OF BIRTH</td>
					<td class="thinborderTOP" colspan="3">PLACE OF BIRTH</td>
				</tr>
				<tr>
				<%	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
						strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1));
					}else{
						strTemp = "&nbsp;";
					}
				%>
				  <td width="19%" height="24">&nbsp;<strong><%=strTemp.toUpperCase()%></strong></td>
				<%	strTemp = "&nbsp;";
					if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
						strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2));
					
				%>
					<td colspan="3"><strong><%=strTemp.toUpperCase()%></strong></td>
				</tr>
				<tr>
					<td height="24" class="thinborderTOP" colspan="4">&nbsp;PARENT / GUARDIAN</td>
				</tr>
				<tr>
					<td colspan="4" height="24">&nbsp;<strong><%=WI.getStrValue(vAdditionalInfo.elementAt(13), "&nbsp;")%>
					</strong></td>
				</tr>
				<tr>
					<td height="24" colspan="4" class="thinborderTOP">&nbsp;PERMANENT ADDRESS</td>
				</tr>
				<tr>
				<%
				strTemp = null;
				if(vGraduationData != null && vGraduationData.size() > 0){
					strTemp = Integer.toString(Integer.parseInt((String)vGraduationData.elementAt(9))-1);

					strTemp = "select address_ from GRAD_CANDIDATE_LIST where is_valid =1 and STUD_INDEX = "+(String)vStudInfo.elementAt(12)+
					" and SY_FROM = "+strTemp+" and SEMESTER = "+(String)vGraduationData.elementAt(11);
					strTemp = dbOP.getResultOfAQuery(strTemp,0);
				}
				
				if(strTemp == null || strTemp.length() == 0)								
					strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(3)).toUpperCase()+
						WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","").toUpperCase()+
						WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","").toUpperCase()+
						WI.getStrValue((String)vAdditionalInfo.elementAt(7)).toUpperCase();
					
				
				%>
					<td colspan="4" height="24">&nbsp;<strong><%=WI.getStrValue(strTemp)%></strong></td>
				</tr>
				<tr>
					<td colspan="3" height="24" class="thinborderTOP">&nbsp;ENTRANCE DATA</td>
					<td colspan="2" class="thinborderTOP">APPLICABLE FOR FOREIGN STUDENT ONLY</td>
				</tr>
				<tr>
					<td  height="24" colspan="3" rowspan="2" valign="bottom">&nbsp;<strong><%=WI.fillTextValue("entrance_data")%></strong></td>
					<td>ACR NO.</td>
					<td>DATE SUBMITTED</td>				
				</tr>
				<tr>
				 <td>&nbsp;<strong></strong></td>
				 <td>&nbsp;<strong></strong></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<table align="center" onMouseDown="return false" width="95%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">   
	<tr>
		<td height="29" colspan="4" align="center" valign="bottom"><strong>PRELIMINARY EDUCATION</strong></td>
	</tr>
	<tr>
	    <td height="10" colspan="4">&nbsp;</td>
	</tr>
	<tr>
		<td width="17%" height="23" align="right">ELMENTARY:</td>
		<%	if(vEntranceData != null)
				strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
			else	
				strTemp = "&nbsp;"; 
		%>	
		<td colspan="2"><strong><%=strTemp%></strong></td>
	    <td width="23%">YEAR:&nbsp;<strong><%=(String)vEntranceData.elementAt(20)%></strong></td>
	</tr>
	<tr>
		<td width="17%" height="23" align="right">HIGH SCHOOL:</td>
		<td colspan="2"><strong><%=(String)vEntranceData.elementAt(5)%></strong></td>
		<td width="23%">YEAR:&nbsp;<strong><%=(String)vEntranceData.elementAt(22)%></strong></td>
	</tr>
	<tr>
		<td width="17%" height="23" align="right">COLLEGE:</td>
		<td colspan="2"><strong><%=WI.getStrValue((String)vEntranceData.elementAt(7),"&nbsp;")%></strong></strong></td>
		<td width="23%">YEAR:&nbsp;<strong><%=WI.getStrValue((String)vEntranceData.elementAt(24),"&nbsp;")%></strong></td>
	</tr>
</table>
<br><br><br><br>
<table align="center" onMouseDown="return false" width="70%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
	<tr>
		<td colspan="6" height="15">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="6" height="18" align="center"><font size="1"><strong>GRADING SYSTEM</strong></font></td>
	</tr>
	<tr>
		<td width="40%" height="18"><font size="1"><strong>RATING</strong></font></td>
		<td width="19%"><font size="1"><strong>LETTER</strong></font></td>
		<td width="18%"><font size="1"><strong>EQUIVALENT</strong></font></td>
		<td width="23%"><font size="1"><strong>QUALITY</strong></font></td>
	</tr>
	<tr>
		<td height="15"><font size="1">1.0</font></td>
		<td><font size="1">A+</font></td>
		<td width="18%"><font size="1">100%</font></td>
		<td rowspan="2"><font size="1"><font size="6">}</font> EXCELLENT</font></td>
	</tr>
	<tr>
		<td height="15" ><font size="1">1.1 - 1.3</font></td>
		<td height="15"><font size="1">A</font></td>
		<td width="18%"><font size="1">99-97%</font></td>
	</tr>
	<tr>
		<td height="15"><font size="1">1.4 - 1.6</font></td>
		<td height="15"><font size="1">A-</font></td>
		<td width="18%"><font size="1">96-94%</font></td>
		<td height="15" rowspan="2"><font size="1"><font size="6">}</font> VERY GOOD</font></td>
	</tr>
	<tr>
		<td height="15"><font size="1">1.7 - 1.9</font></td>
		<td height="15"><font size="1">B+</font></td>
		<td width="18%"><font size="1">93-91%</font></td>
	</tr>
	<tr>
		<td height="15"><font size="1">2.0 - 2.2</font></td>
		<td height="15"><font size="1">B</font></td>
		<td width="18%"><font size="1">90-88%</font></td>
		<td height="15" rowspan="2"><font size="1"><font size="6">}</font> GOOD</font></td>
	</tr>
	<tr>
		<td height="15"><font size="1">2.3 - 2.5</font></td>
		<td height="15"><font size="1">B-</font></td>
		<td width="18%"><font size="1">87-85%</font></td>	
	</tr>
	<tr>
		<td height="15" ><font size="1">2.6 - 2.8</font></td>
		<td height="15"><font size="1">C+</font></td>
		<td width="18%"><font size="1">84-79%</font></td>
		<td height="15" rowspan="2"><font size="1"><font size="6">}</font> FAIR</font></td>
	</tr>
	<tr>
		<td height="15"><font size="1">2.9 - 3.0</font></td>
		<td height="15"><font size="1">C</font></td>
		<td width="18%"><font size="1">78-75%</font></td>
	</tr>
	<tr>
		<td height="15"><font size="1">5.0</font></td>
		<td height="15"><font size="1">F</font></td>
		<td width="18%"><font size="1">BELOW 75%</font></td>
		<td height="15"><font size="1">FAILURE</font></td>
	</tr>
	<tr>
		<td height="15"><font size="1">INC, INE, INR, INT=INCOMPLETE</font></td>
		<td height="15"><font size="1">W=WITHDRAWN</font></td>
		<td width="18%"><font size="1">DR=DROPPED</font></td>
		<td height="15"><font size="1">NA=NO ATTENDANCE</font></td>
	</tr>
	<tr>
		<td height="15" colspan="4"><font size="1">INP = IN PROGRESS</font></td>
	</tr>
</table>
<table align="center" onMouseDown="return false" width="95%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
	<tr>
		<td align="center" height="20"><font size="1"><strong>SEMESTER HOURS CREDIT</strong></font></td>
	</tr>
	<tr>
		<td align="justify" style="text-indent:30px; padding-left:20px; padding-right:30px;"><font size="1">One unit of credit is one hour lecture or recitation each week for a total of 18 hours in a semester. Three hours of laboratory work, each week or a total of 54 hours a semester are regarded as equivalent to one unit of credit.</font>
		</td>
	</tr>
	<tr>
		<td align="justify" style="text-indent:30px; padding-left:20px; padding-right:30px;"><font size="1">The semestral average grade of student is computed by multiplying the number of units assigned to a course by the grade earned and the product is divided by the total units earned for the semsester.</font>
		</td>
	</tr>
	<tr>
		<td align="justify" style="text-indent:30px; padding-left:20px; padding-right:30px;"><font size="1">The student is in GOOD STANDING unless otherwise indicated in the transcript.</font></td>
	</tr>
	<tr>
		<td align="justify" style="text-indent:30px; padding-left:20px; padding-right:30px;"><font size="1">The medium of instruction at all levels of education is ENGLISH.</font></td>
	</tr>
</table>
<table align="center" onMouseDown="return false" width="95%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
	<tr>
		<td colspan="6" height="15">&nbsp;</td></tr>
	<tr>
		<td height="25" colspan="2">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="15%" style="padding-left:20px;">REMARKS : </td>
				<td width="85%" valign="bottom"><div style="border-bottom:solid 1px #000000;"><strong><%=WI.fillTextValue("addl_remark")%></strong></div></td>
			</tr>
			</table></td></tr>
	<tr>
		<td colspan="2" height="40" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;NOT VALID<br>&nbsp;&nbsp;&nbsp;WITHOUT SEAL</td></tr>
	<tr>
		<td colspan="2" height="10" valign="bottom"><div style="border-bottom:solid 2px #000000;"></div></td></tr>
	<tr>
		<td width="60%">
			<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
			   <tr>
					<td width="23%" height="30" style="padding-left:20px;">PREPARED BY :</td>
			  </tr>
				<tr>
					<td height="30" valign="bottom" style="padding-left:20px;"><strong><%=WI.fillTextValue("prep_by1").toUpperCase()%></strong></td>
				</tr>
				<tr>
					<td height="30" style="padding-left:20px;">CHECKED BY :</td>
				</tr>
				<tr>
					<td height="30" valign="bottom" style="padding-left:20px;"><strong><%=WI.fillTextValue("check_by1").toUpperCase()%></strong></td>
				</tr>
			</table>
		</td>
		<td valign="bottom">
			<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
			    <tr>
					<td>&nbsp;</td>				
 				</tr>				
				
				<tr>
					<td align="center" height="20"><strong><%=WI.fillTextValue("registrar_name")%></strong></td>
				</tr>
				<tr>
					<Td align="center" valign="top">University Registrar</Td>
				</tr>
				 <tr>
					<td>&nbsp;</td>				
 				</tr>				
				<tr>
				    <td align="right">Page <%=iPageNumber%> of <%=Integer.parseInt(strTotalPageNumber)+1%> Pages&nbsp;&nbsp;</td>				
				</tr>
			</table>
		</td>
	</tr>
</table>
<div style="page-break-after:always">&nbsp;</div>

<br><br><br><br><br>
<br><br><br><br><br><br>
<table align="center" onMouseDown="return false" width="95%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();" class="thinborder"> 
	<tr>
		 <td width="25%" height="25" class="thinborderLEFT">&nbsp;SURNAME</td>
		 <td width="30%">FIRSTNAME</td>
		 <td width="22%">MIDDLE NAME</td>
		 <td width="23%" align="center" class="thinborderLEFT">STUDENT NUMBER</td>
	</tr>
	<tr>
		<td height="25" class="thinborderLEFTBOTTOM">
		&nbsp;<strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></strong></td>
		<td class="thinborderBOTTOM"><strong><%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%></strong></td>
		<td class="thinborderBOTTOM"><strong><%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
		<td align="center" class="thinborderLEFTBOTTOM"><strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong></td>
	</tr>   
</table>
<%}
if(vRetResult != null && vRetResult.size() > 0){
	int iNumWeeks = 0;
	if (WI.fillTextValue("weeks").length() > 0) 
		iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));
%>
<table onMouseDown="return false" align="center" width="95%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td  colspan="4" class="thinborderBOTTOM">&nbsp;</td>
	</tr>
	<tr>
		<td width="100%" height="750px" valign="top">
			<table onMouseDown="return false" width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">			
				<tr>
					<td height="25" align="center" class="thinborderLEFTBOTTOM" colspan="2">COURSE AND DESCRIPTIVE TITLE</td>
					<td width="10%" align="center" class="thinborderLEFTBOTTOM">Final Ratings</td>
					<td width="10%" align="center" class="thinborderLEFTBOTTOM">Re-Exam<BR>Ratings</td>
					<td width="10%" align="center" class="thinborderLEFTRIGHTBOTTOM">Units</td>					
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
	int iCurSem = 0;

	if(WI.fillTextValue("addl_remark").length() > 0 && iLastPage == 1){
	
		int iTemp = 1;
		strTemp = WI.fillTextValue("addl_remark");
		int iIndexOf = 0;
	
		while((iIndexOf = strTemp.indexOf("<br>",iIndexOf + 1)) != -1)
			++iTemp;
	
		 iMaxRowToDisp = iMaxRowToDisp - iTemp; 
	}

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
	
	if (strCE!= null && strCE.equals("0") && WI.getStrValue((String)vRetResult.elementAt(i + 8),"").toLowerCase().equals("drp")) {
		strCE = "-";
	}
	
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
			iCurSem = Integer.parseInt((String)vRetResult.elementAt(i+3));
			if(iCurSem == 0)
				strCurSY  = (String)vRetResult.elementAt(i+ 2);
			else
				strCurSY  = (String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);
			
		}else {
			strCurSYSem = (String)vRetResult.elementAt(i+ 3)+" "+(String)vRetResult.elementAt(i+ 1)+"-"+
								(String)vRetResult.elementAt(i+ 2);								
			strCurSem = (String)vRetResult.elementAt(i+ 3);
			iCurSem = Integer.parseInt((String)vRetResult.elementAt(i+3));
			if(iCurSem == 0)
				strCurSY  = (String)vRetResult.elementAt(i+ 2);
			else
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

 //Very important here, it print <!-- if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){
 	strHideRowLHS = "<!--"; //I have to do this so i will know if I am priting data or not%>
  <%=strHideRowLHS%> 
  <%}else {
  	++iRowsPrinted;
	strHideRowLHS = "";
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
			if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && vRetResult.elementAt(i + 6) != null  && 
			vRetResult.elementAt(i + 6 + 11) != null && //&& ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 - remove the inc checking..
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
  	<td width="21%" height="20">&nbsp;</td>
    <td height="20" colspan="4">
        <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
  </tr>
  
  
  <%}//end of if(iMulRemarkIndex == i)
}//end of if(vMulRemark != null && vMulRemark.size() > 0) 

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
		//((String)vEntranceData.elementAt(27)).toUpperCase()
	else
		strTemp = strSemToDisp +" "+ strSYToDisp;		
%>	

	<tr bgcolor="#FFFFFF"> 
		<td height="">&nbsp;</td>
		<td height="" colspan="4"><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strSchNameToDisp.toUpperCase()%></label></strong></td>
	</tr>
  
	<tr bgcolor="#FFFFFF">
		<td height="">&nbsp;</td>  	    	
		<td colspan="4"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><i><strong><%=strTemp%></strong></i></label></td>
	</tr>
  
<%}

strGrade = WI.getStrValue(strGrade);

if(strGrade.equals("on going")) {
	strGrade = "&nbsp;";
	strCE = "";
}else if(strGrade.compareToIgnoreCase("IP") == 0) {
	strGrade = "IP";
	strCE = "";
}else {
	if(strGrade.indexOf(".") > -1 && strGrade.length() == 3) 
		strGrade = strGrade + "0";
}

if(bolIsCareGiver && strCE.length() > 0) 
	strCE = strCE + "hrs";
if(strCE.length() > 0 && strCE.indexOf(".") == -1)
	strCE=strCE.trim()+".00";	

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
						<td height="14">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 6))%></td>  
						<td><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')">
						<%=WI.getStrValue(WI.getStrValue(vRetResult.elementAt(i + 7)),"&nbsp;")%> </label></td>
						<td align="center" width="10%"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')">
						<%=strGrade%></label></td>
						<td width="10%" align="center"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')">
						<%=WI.getStrValue(strTemp)%></label></td>
						<td align="center" width="10%"><%=strCE%></td>
					</tr>
  <%if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop%>      
<% if (iLastPage == 1){%>
					<tr>
					<%if(vGraduationData != null &&  vGraduationData.size() > 0){	
						String strCourseCode = (String)vStudInfo.elementAt(24);
						String strMajorCode  = null;
						if(vStudInfo.size() > 25)
							strMajorCode = (String)vStudInfo.elementAt(25);
						else if(vStudInfo.elementAt(8) != null) {
							strMajorCode = "select course_code from major where course_index="+vStudInfo.elementAt(5)
							+" and major_index="+vStudInfo.elementAt(6)+" and is_del=0";
							strMajorCode = dbOP.getResultOfAQuery(strMajorCode,0);		
						}
						boolean bolIsAssociate = false;
						if( ((String)vStudInfo.elementAt(7)).toLowerCase().indexOf("associate") > -1 )
							bolIsAssociate = true;
						int iTemp = 1;
						String strCIndex = "select c_index from course_offered where is_valid =1 and course_index= "+
						(String)vStudInfo.elementAt(5);
						strCIndex = dbOP.getResultOfAQuery(strCIndex,0);	
						String strCollege = "select c_name from college where is_college=1 and c_index = "+strCIndex;
						strCollege = dbOP.getResultOfAQuery(strCollege,0);	
						
						if(bolIsCareGiver)
							strTemp = "GRADUATED WITH THE SIX-MONTH CARE GIVER";
						else{
							if(!bolIsAssociate)
								strTemp =" FROM THE "+astrYearLevel[Integer.parseInt((String)vStudInfo.elementAt(14))]+" - YEAR COURSE IN THE "+strCollege+" WITH THE DEGREE OF "+((String)vStudInfo.elementAt(7)).toUpperCase();
										
							else{
								strTemp = ((String)vStudInfo.elementAt(2)).toUpperCase() +", "+ 
									WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase() + " " +
									WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase();
							
								strTemp = "Completed all "+
									" the requirements leading to the title of "+((String)vStudInfo.elementAt(7)).toUpperCase()+
									" on "+WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
							}
							//strTemp = "Graduated with the degree of " +((String)vStudInfo.elementAt(7)).toUpperCase();			
						} 
						if(strMajorCode != null) {
							strTemp += " MAJOR IN "+((String)vStudInfo.elementAt(8)).toUpperCase();
							strCourseCode = strCourseCode + " "+strMajorCode +  
							" AS OF "+WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase() ;;
						}
						
						 if(!bolIsAssociate)
						 	strTemp += WI.getStrValue(strCourseCode," (",")","") +  
							" AS OF "+WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
						
						 //if ((String)vGraduationData.elementAt(8) != null)
						//	strTemp += " on " +WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase()+".";
						
						 
							 if(vGraduationData.elementAt(6) != null){
								strTemp += " AS PER SPECIAL ORDER "+WI.getStrValue(vGraduationData.elementAt(6))+
									", DATED "+WI.formatDate((String)vGraduationData.elementAt(7),6).toUpperCase()+
									" AT "+ strCurrentSchoolName + 
									", CEBU CITY, PHILIPPINES.";
									//strTemp += " Exempted from the issuance of Special Order by virtue of the AUTONOMOUS STATUS granted by the "+
								//"COMMISSION ON HIGHER EDUCATION (CHED) Resolution No. "+WI.getStrValue(vGraduationData.elementAt(6))+".";	
							 }else{
								strTemp += " EXEMPTED FROM SPECIAL ORDER.";
							 }		
							 			
						if (strTemp.length()/100 > 0) {
							iTemp = strTemp.length()/100;
							if (strTemp.length()%100 > 0)
								iTemp +=1;
						}
						 iRowsPrinted += iTemp; 
					%>  									
						<td colspan="5" class="thinborderTOP">
							<table onMouseDown="return false" width="100%">
							    <tr>
							        <td height="18" colspan="5" align="center">
							<strong>------------swu--swu-swu TRANSCRIPT CLOSED swu--swu--swu------------</strong></td></tr>
								<tr>
									<td valign="top" width="16%"><strong>&nbsp;
								  <%if(!bolIsAssociate && !bolIsCareGiver){%>GRADUATED :<%}%></strong></td>
									<td width="84%" align="justify" valign="top"><%=WI.getStrValue(strTemp).toUpperCase()%></td>
								</tr>
							</table>
						</td>
						<%}%>  	
		            </tr>			
					<tr>
					    <td height="18" colspan="5" align="center"><strong>--- nothing follows ---  </strong></td>
					</tr>	
<%}%>
		</table><!-- Table inside td. -->	
		</td>
	</tr>	
</table>
<div style="bottom:0px;">
<table align="center" onMouseDown="return false" width="95%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
	<tr>
		<td colspan="6" height="20">&nbsp;</td>
	</tr>
	<tr>
		<td height="43" colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;NOT VALID<br>&nbsp;&nbsp;&nbsp;WITHOUT SEAL</td>
	</tr>
	<tr>
		<td colspan="2"><div style="border-bottom:solid 2px #000000;"></div></td>
	</tr>
	<tr>
		<td colspan="2" height="30">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="15%" style="padding-left:20px;">REMARKS : </td>
				<td width="85%" valign="bottom"><div style="border-bottom:solid 1px #000000;"><strong><%=WI.fillTextValue("addl_remark")%></strong></div></td>
			</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td width="60%" valign="bottom">
			<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
				<tr>
				    <td>&nbsp;</td>
				</tr>				
				<tr>
					<td height="30" style="padding-left:20px;">CHECKED BY :</td>
				</tr>
				<tr>
					<td height="30" valign="bottom">
					&nbsp;&nbsp;<strong><%=WI.fillTextValue("check_by1").toUpperCase()%></strong></td>
				</tr>
			</table>
		</td>
		<td>
			<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
				<tr>
					<td align="center" height="20"><strong><%=WI.fillTextValue("registrar_name")%></strong></td>
				</tr>
				<tr>
					<Td align="center" valign="top">University Registrar</Td>
				</tr>
				 <tr>
					<td>&nbsp;</td>				
 				</tr>				
				<tr>
				    <td align="right">Page <%=++iPageNumber%> of <%=Integer.parseInt(strTotalPageNumber)+1%> Pages&nbsp;&nbsp;</td>				
				</tr>
			</table>
		</td>
	</tr>
</table>
</div>
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
<%//I have to construct here what are the courses checked already.. 
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