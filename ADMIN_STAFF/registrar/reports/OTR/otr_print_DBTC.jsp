<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	//strSchCode = "AUF_PALOMPON";
	
	if(strSchCode == null) {%>
		<p style="font-size:14px; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif;"> Failed to proceed. You are already logged out. Please login again.</p>

<%return;}%>
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
	font-size: 11px;	
	}
	
	TD.thickSE {
		border-bottom: solid 1px #000000;
		border-right: solid 1px #000000;
		font-size: 11px;	
	}
	TD.thickTOPBOTTOM {
		border-bottom: solid 2px #000000;
		border-top: solid 2px #000000;
		font-size: 11px;	
	}
	TD.thickTOPBOTTOMRIGHT {
		border-bottom: solid 2px #000000;
		border-top: solid 2px #000000;
		border-right: solid 2px #000000;
		font-size: 11px;	
	}
	TD.thickBOTTOM {
		border-bottom: solid 2px #000000;
		font-size: 11px;	
	}
	TD.thickTOP {
		border-top: solid 2px #000000;
		font-size: 11px;	
	}
	
	TD.thickE {
		border-right: solid 1px #000000;
		font-size: 11px;	
	}
	TD.thickRIGHT {
		border-right: solid 2px #000000;
		font-size: 11px;	
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
function UpdateLabelCourse(strLevelID) {
	var newVal = prompt('Please enter new Value');
	if(newVal == null)
		return;
	document.getElementById(strLevelID).innerHTML = newVal;
}
function UpdateLabel(strLevelID) {
	return;
	
	var newVal = prompt('Please enter new Value');
	if(newVal == null)
		return;
	document.getElementById(strLevelID).innerHTML = newVal;
}
function Update(strLabelID) {
	return;
	
	strNewVal = prompt('Please enter new Value','');
	if(strNewVal == null)
		return;
	document.getElementById(strLabelID).innerHTML = strNewVal;
}
function updateSubjectRow(strLabelID) {
	return;
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
	//System.out.println("iPageNumber "+iPageNumber );
	String strTotalPageNumber = WI.fillTextValue("total_page");

	String strImgFileExt = null;
	String strRootPath  = null;

	//copied from AUF for print all page setting.. 
		String strPrintValueCSV = "";
	//System.out.println(WI.fillTextValue("print_all_pages"));
	if(WI.fillTextValue("print_all_pages").equals("1")) { //print all page called.
		strPrintValueCSV = WI.fillTextValue("print_value_csv");
		if(strPrintValueCSV.length() == 0) {
			strErrMsg = "End of printing. This error must not occur.";%>
			<%=strErrMsg%>
		<%	return;
		} 
		Vector vPrintVal = CommonUtil.convertCSVToVector(strPrintValueCSV);//[0] row_start_fr, [1] row_count, [2] last_page, [3] page_number, [4] max_page_to_disp, 
		//System.out.println(vPrintVal);
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

Vector vLecLabUnit = new Vector();
String strLecUnit  = null;
String strLabUnit  = null;

Vector vMulRemark = null;
int iMulRemarkIndex = -1;


///// extra condition for the selected courses
String strStudCourseToDisp = null; String strStudMajorToDisp = null;
String strStudCourseName   = null;

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
boolean bolRemoveMajor = false;
boolean bolRemoveROTC  = false;

boolean bolIsTVED = false; // c_index = 17

enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
if(strSchCode.startsWith("DBTC") || strSchCode.startsWith("PIT")) 
	repRegistrar.strTFList="0";

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
		strTemp = "select degree_type,course_code from course_offered where course_index in ("+CommonUtil.convertVectorToCSV(vCourseSelected)+")";
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		//System.out.println(strTemp);
		while(rs.next()) {
			strTemp = rs.getString(1);
			if(rs.getString(2).equals("T.C.P."))
				strTemp = "0";
				
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
		
		strTemp = "select course_name, major_name,course_offered.course_code, major.course_code,course_offered.course_index,course_offered.c_index "+
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
			
			strStudCourseName = rs.getString(1)+"("+rs.getString(3)+ ")";
			//if(rs.getString(2) != null)
			//	strStudCourseName += " - "+rs.getString(2);
			
			strCourseIndex = rs.getString(5);
			strStudCourseToDisp = rs.getString(1);
			//strStudMajorToDisp  = rs.getString(4);
			
			if(rs.getInt(6) == 17)
				bolIsTVED = true;
			
		}

	}
	if(strStudCourseToDisp == null) {
		strStudCourseToDisp = (String)vStudInfo.elementAt(24);
		strStudMajorToDisp  = (String)vStudInfo.elementAt(25);
		strCourseIndex      = (String)vStudInfo.elementAt(5);
		
		strStudCourseName = (String)vStudInfo.elementAt(26)+ " - "+(String)vStudInfo.elementAt(7)+
		"("+strStudCourseToDisp+")";
			//if(vStudInfo.elementAt(8) != null)
			//	strStudCourseName += " - "+(String)vStudInfo.elementAt(8);
	}
	//I have to set the course index so that the graduation data can get the info for that course.. 

	enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
	vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);
	request.setAttribute("course_ref", strCourseIndex);
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	if(vEntranceData == null || vGraduationData == null)
		strErrMsg = entranceGradData.getErrMsg();
	if(vEntranceData != null && vEntranceData.size() > 0) {
		if(vEntranceData.elementAt(30) != null && vEntranceData.elementAt(30).equals("1") )
			bolRemoveROTC = true;
		if(vEntranceData.elementAt(31) != null && vEntranceData.elementAt(31).equals("1") )
			bolRemoveMajor = true;
	}
}
//System.out.println(bolRemoveROTC);
//System.out.println(bolRemoveMajor);
//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};

if(vStudInfo != null && vStudInfo.size() > 0) {
	if(strDegreeType == null)
		strDegreeType = (String)vStudInfo.elementAt(15);
	
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), 
													strDegreeType, true, strExtraCon);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);
		
	if(vRetResult != null && vRetResult.size() > 0) {
		vLecLabUnit = repRegistrar.getLecLabUnitInfoDBTC(dbOP, (String)vStudInfo.elementAt(12));
		if(vLecLabUnit == null)
			vLecLabUnit = new Vector();
	}
	
}

String strStudName = WI.formatName((String)vStudInfo.elementAt(0), (String)vStudInfo.elementAt(1), (String)vStudInfo.elementAt(2), 5).toUpperCase();	

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


boolean bolNoThickTop = false;
%>

<body topmargin="5" <%if(WI.fillTextValue("print_").equals("1")){%> onLoad="window.print()"<%}%>>
<form action="./otr_print_DBTC.jsp" method="post" name="form_">
<!--<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="7%" height="22"></td>
    <td width="81%" align="right"></td>
    <td width="12%" align="right" valign="top">Page <u>&nbsp;&nbsp;<%=iPageNumber%>&nbsp;&nbsp;</u></td>
</table>-->
<%



if(iPageNumber > 1) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="14%" height="17">Name</td>
    <td width="74%" style="font-weight:bold; font-size:16px;"><%=strStudName%></td>
	<td width="12%" align="right" valign="top">Page <u>&nbsp;&nbsp;<%=iPageNumber%>&nbsp;&nbsp;</u></td>
  </tr>
  <tr>
    <td height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
<%}
else if(iPageNumber == 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
  </tr>
  <tr>
    <td width="15%" height="18">Name</td>
    <td width="73%">: <font  style="font-weight:bold; font-size:16px;"><%=strStudName%></font></td>
    <td width="12%" align="right" valign="top">Page <u>&nbsp;&nbsp;<%=iPageNumber%>&nbsp;&nbsp;</u></td>
  </tr>
  <tr>
    <td height="18">Student ID.# </td>
    <td>: <%=WI.fillTextValue("stud_id").toUpperCase()%></td>
	<td width="12%" rowspan="11" valign="top" align="right">
<%
		strTemp = WI.fillTextValue("stud_id").toUpperCase();
		//System.out.println("strTemp : " + strTemp);
		//System.out.println(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);
		if (strTemp.length() > 0) {
			java.io.File file = new java.io.File(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);

			if(file.exists()) {
				strTemp = "../../../../upload_img/"+strTemp+"."+strImgFileExt;
				strTemp = "<label id='hide_img' onClick='HideImg()'><img src=\""+strTemp+"\" width=75 height=75></label>";
			}
			else {
				strTemp = "<img src='../../../../images/blank.gif' width='75' height='75' border='1'>";
			}
		}

String strMajorToDispDBTC = strStudMajorToDisp;
if(strStudMajorToDisp != null && strStudMajorToDisp.length() > 0) {
	if(!strStudMajorToDisp.startsWith("Specializing"))
		strMajorToDispDBTC = WI.getStrValue(strStudMajorToDisp," major in ","","");
	//else
	//	strErrMsg = strStudMajorToDisp;
}
%>

	 <%=strTemp%>	</td>
  </tr>
  <tr>
    <td height="18">Program</td>
    <td>: <label id="_0_" onDblClick="UpdateLabelCourse('_0_')"><%=strStudCourseToDisp%> <%=WI.getStrValue(strMajorToDispDBTC)%></label></td>
  </tr>
  <tr>
    <td height="18">Sex</td>
    <td>: 
<%
strTemp = (String)vStudInfo.elementAt(16);
if(strTemp.equals("M"))
	strTemp = "MALE";
else
	strTemp = "FEMALE";
%>
	<%=strTemp%>
	</td>
  </tr>
  <tr>
    <td height="18">Date of Birth </td>
    <td>: 
<%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
		strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1));
	}else{
		strTemp = "&nbsp;";
	}
%>
    <%=strTemp.toUpperCase()%>	</td>
  </tr>
  <tr>
    <td height="18">Place of Birth </td>
    <td>: 
<%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
		strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2));
	}else{
		strTemp = "&nbsp;";
	}
%>
      <%=strTemp%>	</td>
  </tr>
  <tr>
    <td height="18">Citizenship</td>
    <td>: <%=WI.getStrValue((String)vStudInfo.elementAt(23), "&nbsp;")%></td>
  </tr>
  <tr>
    <td height="18">Home Address</td>
    <td>: <%=WI.fillTextValue("address")%></td>
  </tr>
  <tr>
    <td height="18">Tel. No. </td>
    <td>: <%=WI.getStrValue((String)vAdditionalInfo.elementAt(20), "&nbsp;")%></td>
    </tr>
  <tr>
    <td height="18">Parent/Guardian</td>
<%
if(vEntranceData != null && vEntranceData.size() > 0 && vEntranceData.elementAt(45) != null)
	strTemp = (String)vEntranceData.elementAt(45);
else
	strTemp = (String)vAdditionalInfo.elementAt(8);
%>
    <td>: <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
  <tr>
    <td height="25" colspan="3" style="font-weight:bold; font-size:12px;" align="center">PRELIMINARY EDUCATION</td>
    </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
  <tr style="font-weight:bold">
    <td width="15%" height="18">GRADE</td>
    <td width="39%">&nbsp;&nbsp;NAME OF SCHOOL</td>
    <td width="34%">ADDRESS</td>
    <td width="12%">SCH. YR.</td>
  </tr>
<%if(false){%>
  <tr>
    <td height="18">Primary</td>
    <td>: <%=(String)vEntranceData.elementAt(14)%></td>
    <td><%=(String)vEntranceData.elementAt(33)%></td>
    <td width="12%"><%=(String)vEntranceData.elementAt(17)%> - <%=(String)vEntranceData.elementAt(18)%></td>
  </tr>
  <tr>
    <td height="18">Intermediate</td>
    <td>: <%=(String)vEntranceData.elementAt(16)%></td>
    <td><%=(String)vEntranceData.elementAt(34)%></td>
    <td width="12%"><%=(String)vEntranceData.elementAt(19)%> - <%=(String)vEntranceData.elementAt(20)%></td>
  </tr>
<%}%>
  <tr>
    <td height="18">Elementary</td>
    <td>: 
<%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
else	
	strTemp = "&nbsp;"; 
%>	
	<%=strTemp%></td>
    <td>
<%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(34),WI.getStrValue(vEntranceData.elementAt(36)));
else	
	strTemp = "&nbsp;"; 
%>	<%=WI.getStrValue(strTemp)%></td>
    <td width="12%"><%=(String)vEntranceData.elementAt(19)%> - <%=(String)vEntranceData.elementAt(20)%></td>
  </tr>
  <tr>
    <td height="18">Secondary</td>
    <td>: <%=(String)vEntranceData.elementAt(5)%></td>
    <td><%=(String)vEntranceData.elementAt(35)%></td>
    <td width="12%"><%=(String)vEntranceData.elementAt(21)%> - <%=(String)vEntranceData.elementAt(22)%></td>
  </tr>
</table>
<%
}//show only if it is not first page.. 

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

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#FFFFFF" onClick="PrintNextPage();" style="font-weight:bold"> 
    <td width="20%" height="25" rowspan="2" align="center" class="thickTOPBOTTOMRIGHT"><font size="1">SUBJECT NO.</font></td>
    <td width="63%" rowspan="2" align="center" class="thickTOPBOTTOMRIGHT"><font size="1">DESCRIPTIVE TITLE</font></td>
    <td width="7%" rowspan="2" align="center" class="thickTOPBOTTOMRIGHT"><font size="1">RATING</font></td>
    <td width="10%" colspan="2" align="center" class="thickTOP">UNITS</td>
    </tr>
  <tr bgcolor="#FFFFFF" onClick="PrintNextPage();" style="font-weight:bold">
    <td width="5%" class="thickTOPBOTTOMRIGHT" align="center"><font size="1">LEC  </font></td>
    <td width="5%" align="center" class="thickTOPBOTTOM">LAB </td>
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
			<td height="17" colspan="5" valign="top" class="thinborderNONE"><label onClick="Update('0<%=i%>')" id="0<%=i%>"></label>			  <label onClick="Update('1<%=i%>')" id="1<%=i%>"><%=ConversionTable.replaceString(strCol2,"\n","<br>")%></label></td>
		  </tr>
		<%}//end of while. %>
  <%}//end of if
}//end of vMulRemark.
	
	
if(strSchNameToDisp != null){
	bolNewPage = false;
	strTemp = strSchNameToDisp.toUpperCase();

String strTemp2 = WI.getStrValue(strSYSemToDisp).toUpperCase();
if(strTemp2.startsWith("SUMMER")) {
	strTemp2 = "SUMMER, "+strTemp2.substring(strTemp2.length() - 4);
}

if(strTemp2.startsWith("1ST"))
	strTemp2 = "FIRST "+strTemp2.substring(4);
else if(strTemp2.startsWith("2ND"))
	strTemp2 = "SECOND "+strTemp2.substring(4);
else if(strTemp2.startsWith("3RD"))
	strTemp2 = "THIRD "+strTemp2.substring(4);

//I have to convert the first ay to first semester ay
if(strTemp2.startsWith("FIRST AY")) 
	strTemp2 = "FIRST SEMESTER AY"+strTemp2.substring(8);
if(strTemp2.startsWith("SECOND AY")) 
	strTemp2 = "SECOND SEMESTER AY"+strTemp2.substring(9);

strSYTermInfoPrevPage = WI.getStrValue(strTemp2,"",", ","").toUpperCase() + strTemp;
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="17" colspan="5" class="thickBOTTOM"><strong><label id="000<%=i%>" onClick="Update('000<%=i%>')"><%=WI.getStrValue(strTemp2).toUpperCase()%><%//=strTemp%></label></strong></td>
  </tr>
<%bolNoThickTop = false;
if(vEntranceData.elementAt(12) != null){%>
  
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

//I have to convert the first ay to first semester ay
if(strTemp.startsWith("FIRST AY")) 
	strTemp = "FIRST SEMESTER AY"+strTemp.substring(8);
if(strTemp.startsWith("SECOND AY")) 
	strTemp = "SECOND SEMESTER AY"+strTemp.substring(9);


strSYTermInfoPrevPage = strTemp;
%>
   <tr bgcolor="#FFFFFF"> 
	   <td colspan="5" class="<%if(bolNoThickTop){%>thickBOTTOM<%}else{%>thickTOPBOTTOM<%}%>"><strong><label id="000<%=i%>" onClick="Update('000<%=i%>')"><%=strTemp%></label></strong></td>
   </tr>
<%strSYSemToDisp = null;bolNoThickTop = false;}

if(bolNewPage && strSYTermInfoPrevPage != null) {bolNewPage = false;%>
   <tr bgcolor="#FFFFFF"> 
	   <td colspan="5" class="thickBOTTOM"><strong><label id="000<%=i%>" onClick="Update('000<%=i%>')"><%=strSYTermInfoPrevPage%></label></strong></td>
   </tr>
<%bolNoThickTop = false;}


//if (bolNewEntry && bolNextNew ) {
if(true){%>
  <tr bgcolor="#FFFFFF"> 
    <%
strTemp = (String)WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;");
if(bolRemoveROTC) {
	iIndexOf = strTemp.indexOf("ROTC");
	if(iIndexOf == -1)
		iIndexOf = strTemp.indexOf("LTS");
	if(iIndexOf == -1)
		iIndexOf = strTemp.indexOf("CWTS");
	if(iIndexOf > -1)
		strTemp = strTemp.substring(0, iIndexOf-1);
	//System.out.println(iIndexOf);
	
}
%>   <td height="17" valign="top" class="thickRIGHT">
		<label id="00<%=i%>" onClick="updateSubjectRow('00<%=i%>')"><%=strTemp%></label>
	</td>
    <td valign="top" class="thickRIGHT">
		<label id="01<%=i%>" onClick="updateSubjectRow('01<%=i%>')"><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></label>	</td>
<%
strTemp = WI.getStrValue(vRetResult.elementAt(i + 8), "-");
if(strTemp.startsWith("on going")) {
	strTemp = "EN";
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

    <td width="8%" valign="top" class="thickRIGHT"><div align="center"><label id="02<%=i%>" onClick="updateSubjectRow('02<%=i%>')"><%=strTemp%></label></div></td>
	
    <%
	if(strCE != null && strCE.length() > 0 && strCE.endsWith(".0"))
		strCE = strCE.substring(0, strCE.length() - 2);
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
	}	
	catch(Exception e) {
		
	}	
		
		
	
	iIndexOf = vEnrichmentSubjects.indexOf(vRetResult.elementAt(i + 6));
	if(iIndexOf > -1) {
		try {
			double dGrade = Double.parseDouble(strTemp);
			if(dGrade > 0d && (dGrade < 5d || dGrade >= 75d) && !strCE.startsWith("(") )
				strCE = "(" + (String)vEnrichmentSubjects.elementAt(iIndexOf + 3) + ")";
			
		}
		catch(Exception e){}
		//System.out.println("Star of printing : "+strTemp);
		//System.out.println(strCE);
		//System.out.println("Subject : "+vRetResult.elementAt(i + 6));
		//System.out.println(strTemp+ ": end of printing: ");
	}

	%>	
	<td valign="top" class="thickRIGHT"><div align="center"> <label id="03<%=i%>" onClick="updateSubjectRow('03<%=i%>')"><%=strLecUnit%></label></div></td>
    <td valign="top" ><div align="center"> <label id="03_<%=i%>" onClick="updateSubjectRow('03_<%=i%>')"><%=strLabUnit%></label></div></td>
  </tr>
  <% if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){bolInComment = false; bolNewPage = true;%>
  <%=strHideRowRHS%> 
  <% bolNoThickTop = true; }
  }%>

<%}//end of for loop%> 
  
<tr  bgcolor="#FFFFFF" >
<td colspan="5" class="thickTOP">&nbsp;</td>
</tr>
  
<%
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
	
	//I have to find here how many year is this course.. 
	strTemp = "select max(year) from curriculum where is_valid = 1 and course_index = "+vStudInfo.elementAt(5);
	strTemp = dbOP.getResultOfAQuery(strTemp, 0) ;
	if(strTemp == null)
		strTemp = "";
	else {
		Vector vTesdaCourse = new Vector();
		vTesdaCourse.addElement("BWI NC II - B1");
		vTesdaCourse.addElement("BWI NC II - B2");
		vTesdaCourse.addElement("CPT NC II - B1");
		vTesdaCourse.addElement("CPT NC II - B2");
		vTesdaCourse.addElement("GR11-MACH NC II");
		vTesdaCourse.addElement("GR12-MACH NC II");
		vTesdaCourse.addElement("HST");
		vTesdaCourse.addElement("MACH NC I - B1");
		vTesdaCourse.addElement("MACH NC I - B2");
		vTesdaCourse.addElement("MACH NC II - B1");
		vTesdaCourse.addElement("MACH NC II - B2");
		vTesdaCourse.addElement("STP ET");
		vTesdaCourse.addElement("STP FT");
		vTesdaCourse.addElement("STP MT");
		vTesdaCourse.addElement("STP SE");
		vTesdaCourse.addElement("WFT - B1");
		vTesdaCourse.addElement("WFT - B2");
		
		if(!strTemp.equals("1") && vTesdaCourse.indexOf(strCourseCode.toUpperCase()) > -1)
			strTemp = "1";
		
	
	
		if(strTemp.equals("1"))
			strTemp = "ONE-YEAR";
		else if(strTemp.equals("2"))
			strTemp = "TWO-YEAR";
		else if(strTemp.equals("3"))
			strTemp = "THREE-YEAR";
		else if(strTemp.equals("4"))
			strTemp = "FOUR-YEAR";
		else if(strTemp.equals("5"))
			strTemp = "FIVE-YEAR";
		else if(strTemp.equals("1"))
			strTemp = "SIX-YEAR";
		else	
			strTemp = "";
			
		if(strCourseCode.equals("STP SE"))
			strTemp = "THREE-MONTH";

	}
	 if(strCourseCode.equals("STP SE"))
	 	strTemp = "COMPLETED THE "+strTemp+" BASIC TRAINING IN <b>";
	 else	
	 	strTemp = "GRADUATED FROM THE "+strTemp+" COURSE IN <b>";
		
	 //strTemp = "GRADUATED FROM THE "+strTemp+" COURSE IN <b>" + ((String)vStudInfo.elementAt(7)).toUpperCase()+"</b>";
	 strTemp = strTemp + ((String)vStudInfo.elementAt(7)).toUpperCase()+"</b>";
	 
	 if(strMajorCode != null && strMajorCode.length() > 0) {
		if(((String)vStudInfo.elementAt(8)).startsWith("Specializing"))
			strTemp += " <b>";
		else
			strTemp += " MAJOR IN <b>";

	 	//strTemp += " MAJOR IN <b>"+((String)vStudInfo.elementAt(8)).toUpperCase()+"</b>";
		strTemp += ((String)vStudInfo.elementAt(8)).toUpperCase()+"</b>";
		strCourseCode = strCourseCode + "-"+strMajorCode;
	 }
	
	 strTemp += WI.getStrValue(strCourseCode," <b>(",")</b> ","");
				
	 if ((String)vGraduationData.elementAt(8) != null)
	 	strTemp += " ON <b>" + WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase()+"</b>";
	
	 if(vGraduationData.elementAt(6) != null)
	 	strTemp +=	" PER <b>" +vGraduationData.elementAt(6)+"</b>";
	 if (vGraduationData.elementAt(6) != null && vGraduationData.elementAt(7) != null) 
	 	 strTemp += "<b>, DATED " + WI.formatDate((String)vGraduationData.elementAt(7),6).toUpperCase() + ".</b>";
	 else	
	 	strTemp += ".";
		
	if (strTemp.length()/100 > 0) {
		iTemp = strTemp.length()/100;
		if (strTemp.length()%100 > 0)
			iTemp +=1;
	}
	 iRowsPrinted += iTemp; 
// 	System.out.println("iRowsPrinted 4:" + iRowsPrinted );


String strShowGWA = WI.fillTextValue("show_gwa");
String strGWAValue = WI.fillTextValue("gwa");

if(strShowGWA.length() > 0 && strGWAValue.length() > 0){
%>  

<tr  bgcolor="#FFFFFF">
	<td height="17" colspan="5" valign="top" class="thinborderNONE">
		<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><strong>GWA : <%=strGWAValue%></strong></label></td>
</tr>
<%}%>
<tr  bgcolor="#FFFFFF" align="center">
	<td height="17" colspan="5" valign="top" class="thinborderNONE"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
    </tr>
<%}%>
<tr bgcolor="#FFFFFF" >
	<td height="17" class="thinborderNONE" colspan="5" align="center">**************(TRANSCRIPT CLOSED. ANY ENTRY BELOW THIS LINE IS NULL AND VOID.)**************</td>
</tr>

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

<%}//only if student is having grade infromation.%>

<%if(iLastPage == 1){%>
<b>GRADING SYSTEM</b>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr style="font-weight:bold">
  	<td class="thinborder" style="font-size:9px;" width="20%">GRADE  </td>
  	<td class="thinborder" style="font-size:9px;" width="63%">EQUIVALENT RATING</td>
  	<td class="thinborder" style="font-size:9px;">INDICATION</td>
  </tr>
  <tr>
  	<td class="thinborder" style="font-size:9px;">1.0</td>
  	<td class="thinborder" style="font-size:9px;">95 to 100% </td>
  	<td class="thinborder" style="font-size:9px;">Excellent</td>
  </tr>
  <tr>
  	<td class="thinborder" style="font-size:9px;">1.1 to 1.5</td>
  	<td class="thinborder" style="font-size:9px;">90 to 94%</td>
  	<td class="thinborder" style="font-size:9px;">Very Good</td>
  </tr>
  <tr>
  	<td class="thinborder" style="font-size:9px;">1.6 to 2.5</td>
  	<td class="thinborder" style="font-size:9px;">80 to 89%</td>
  	<td class="thinborder" style="font-size:9px;">Good</td>
  </tr>
  <tr>
  	<td class="thinborder" style="font-size:9px;">2.6 to 3.0</td>
  	<td class="thinborder" style="font-size:9px;">75 to 79%</td>
  	<td class="thinborder" style="font-size:9px;">Fair</td>
  </tr>
  <tr>
  	<td class="thinborder" style="font-size:9px;">5.0</td>
  	<td class="thinborder" style="font-size:9px;">74%</td>
  	<td class="thinborder" style="font-size:9px;">Failure</td>
  </tr>
  <tr>
  	<td class="thinborder" style="font-size:9px;">NA</td>
  	<td class="thinborder" style="font-size:9px;">"No Attendance"</td>
  	<td class="thinborder" style="font-size:9px;">&nbsp;</td>
  </tr>
  <tr>
  	<td class="thinborder" style="font-size:9px;">W</td>
  	<td class="thinborder" style="font-size:9px;">"Withdrawal w/ Official Notice"</td>
  	<td class="thinborder" style="font-size:9px;">&nbsp;</td>
  </tr>
  <tr>
  	<td class="thinborder" style="font-size:9px;">DR</td>
  	<td class="thinborder" style="font-size:9px;">"Dropped"</td>
  	<td class="thinborder" style="font-size:9px;">&nbsp;</td>
  </tr>
  <tr>
  	<td class="thinborder" style="font-size:9px;">NC</td>
  	<td class="thinborder" style="font-size:9px;">"No Credit"</td>
  	<td class="thinborder" style="font-size:9px;">&nbsp;</td>
  </tr>
  <tr>
  	<td class="thinborder" style="font-size:9px;">EN</td>
  	<td class="thinborder" style="font-size:9px;">"Enrolled"</td>
  	<td class="thinborder" style="font-size:9px;">&nbsp;</td>
  </tr>
</table>
<%if(!bolIsTVED) {%>
	One Collegiate unit of credit is one hour lecture / recitation / drafting / laboratory / shopwork each week or a
	total of 18 hours in a semester.<br><br>
	The semestral average grade of a student is computed by multiplying the number of units assigned to a
	course by the grade earned and the product divided by the total units earned for the semester.
<%}%>
	<br><br>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(WI.fillTextValue("addl_remark").length() > 0) {
	if(vGraduationData != null)
		strTemp = WI.getStrValue((String)vGraduationData.elementAt(15),"");
	else
		strTemp = "";
	if(strTemp.startsWith("&")) {
		double dGWA = 0d;
		student.GWA gwa = new student.GWA();
		dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));	
		strTemp = CommonUtil.formatFloat(dGWA,true);
	
	}
%>
  <tr align="right">
  	<td style="font-size:9px;"><b>GPA/GWA: <%=strTemp%> &nbsp;&nbsp;REMARKS: &nbsp;&nbsp;</b><%=WI.fillTextValue("addl_remark").toUpperCase()%></td>
  </tr>
  <tr>
  	<td height="20" valign="top">&nbsp;</td>
  </tr>
<%}if(WI.fillTextValue("copy_to1").length() > 0) {%>
  <tr>
  	<td height="20" valign="top">

		<table width="90%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="40%">&nbsp;</td>
				<td width="10%">COPY FOR: </td>
				<td width="50%" class="thinborderBottom">&nbsp;<%=WI.fillTextValue("copy_to1")%></td>
			</tr>
			<tr>
				<td height="20">&nbsp;</td>
				<td></td>
				<td class="thinborderBottom">&nbsp;<%=WI.fillTextValue("copy_to2")%></td>
			</tr>
			<tr>
				<td height="20">&nbsp;</td>
				<td>&nbsp;</td>
				<td class="thinborderBottom">&nbsp;<%=WI.fillTextValue("copy_to3")%></td>
			</tr>
		</table>		

	</td>
  </tr>
<%}%>
  <tr>
  	<td height="30" valign="top"><strong>Prepared by :</strong> <%=WI.fillTextValue("prep_by1")%></td>
  </tr>
  <tr>
  	<td height="30"><strong>Checked by &nbsp;:</strong> <%=WI.fillTextValue("check_by1")%></td>
  </tr>
</table>
<%}//show only if last page.
else {//show continue in next page. %>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr align="right">
  	<td style="font-size:9px;"><br>REMARKS: &nbsp;&nbsp;</b>  continued on page <%=iPageNumber + 1%></td>
  </tr>
</table>
<%}%> 

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="20" colspan="2" class="thinborderNONE">
	<table width="100%">
		<tr valign="bottom">
			<td width="20%" height="50"></td>
			<td></td>
			<td width="20%" align="center"><font style="font-weight:bold; font-size:12px;"><br><br><%=WI.fillTextValue("registrar_name").toUpperCase()%></font><br>Registrar</td>
  		</tr>
		<tr>
		  <td align="center">NOT VALID<br>WITHOUT DBTC SEAL</td>
		  <td></td>
		  <td align="center">&nbsp;</td>
		  </tr>
	</table>
  </td></tr>
</table>


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

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
