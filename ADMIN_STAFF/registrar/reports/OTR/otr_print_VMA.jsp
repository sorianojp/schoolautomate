<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>VMA OFFICIAL TRANSCRIPT OF RECORD</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--

@media print { 
  @page {
		margin-bottom:1in;
		margin-top:.1in;
		margin-right:.5in;
		margin-left:.5in;
	}
}


body {
	font-family: "Times New Roman";
	font-size: 13px;
}

td {
	font-family: "Times New Roman";
	font-size: 13px;
}

th {
	font-family: "Times New Roman";
	font-size: 13px;
}


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;	
    }	
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;
    }
    .thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;
    }

    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;	
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;	
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;	
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;	
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;	
    }
    TD.thinborderRIGHTBOTTOM {
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;	
    }
	
	TD.thinborderTOPRIGHTBOTTOM {
	border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;	
    }
	
	TD.thinborderTOPLEFTBOTTOM {
	border-top: solid 2px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;	
    }
	
	TD.thinborderTOPLEFT{
	border-top: solid 2px #000000;
    border-left: solid 1px #000000;    
	font-family: "Times New Roman";
	font-size: 13px;	
    }
	
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;	
    }
	
	TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 13px;	
    }
	
    TD.thinborderLEFTRIGHTBOTTOM {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
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

//end of authenticaion code.
boolean bolIsCareGiver = false;//if caregiver, i have to append hrs to the credit earned.
java.sql.ResultSet rs = null;
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
//if(vStudInfo != null && vStudInfo.size() > 0) {
//	Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,WI.fillTextValue("stud_id"),
//														(String)vStudInfo.elementAt(7),
//													(String)vStudInfo.elementAt(8));
//		if (vFirstEnrl != null) {
//			vRetResult = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
//											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
//											(String)vFirstEnrl.elementAt(2),false,false,true,true);
//										
//		if(vRetResult == null && strErrMsg == null)
//			strErrMsg = cRequirement.getErrMsg();
//		else
//			vCompliedRequirement = (Vector)vRetResult.elementAt(1);
//	  }
//	  else 
//	  	strErrMsg = cRequirement.getErrMsg();	
//}

//save encoded information if save is clicked.
//Vector vForm17Info = null;
//vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
//
//if(vForm17Info != null && vForm17Info.size() ==0)
//	vForm17Info = null;

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

	if (strDegreeType != null && strDegreeType.equals("1")) {
		astrConvertSem[0] = "Summer";
		astrConvertSem[1] = "1st Trimester";
		astrConvertSem[2] = "2nd Trimester";
		astrConvertSem[3] = "3rd Trimester";
		astrConvertSem[4] = "";
	}//System.out.println(vRetResult);
}
String strStudName = WI.formatName((String)vStudInfo.elementAt(0), (String)vStudInfo.elementAt(1), (String)vStudInfo.elementAt(2), 5).toUpperCase();

String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);
String strCurrentSchoolAdd  = "SUM-AG, BACOLOD CITY,NEGROS OCCIDENTAL";

boolean bolIsRLEHrs = false;
boolean bolShowLecLabHr = false; String[] astrLecLabHr = null;//gets lec/lab hour information.
String strRLEHrs    = null;
String strCE        = null;

boolean bolIsMedTOR = strDegreeType.equals("2");
//if(bolIsMedTOR) {
if (strDegreeType != null && strDegreeType.equals("2")) {
		astrConvertSem[0] = "Summer";
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
//System.out.println(vInternshipInfo);


String strMulRemarkAtEndOfSYTerm = null;//if there is any remark added after the end of SY/term of Student.. 

//check if caregiver.. 
if(strStudCourseToDisp != null && strStudCourseToDisp.toLowerCase().equals("caregiver course"))
	bolIsCareGiver = true;



/** 
	special case for wup
**/
//Vector vRemovalGradeInfo  = new Vector();
//Vector vNotSubmittedGrade = new Vector();
//Vector vNotVerifiedGrade  = new Vector();
//
//String strRemovalGrade     = null;




	
%>

<body topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0">
<form action="./otr_print_VMA.jsp" method="post" name="form_">
<br><br><br><br><br><br><br><br>
<br><br><br><br><br><br><br>
<%
if(iPageNumber > 1) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="75%" height="17">NAME : <%=strStudName%></td>  
	<%
	strTemp = WI.getStrValue((String)vStudInfo.elementAt(24))+WI.getStrValue((String)vStudInfo.elementAt(14),"-","","");
	%>  
	<td width="25%">COURSE : <strong><%=WI.getStrValue(strTemp)%></strong></td>
  </tr>
  
</table>
<%}
else if(iPageNumber == 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
  
  <tr>
    <td width="19%">NAME:</td>
    <td width="56%"><font  style="font-weight:bold;"><%=strStudName%></font></td>
    <td width="25%" rowspan="9" valign="top" align="right">
	<%
		strTemp = WI.fillTextValue("stud_id").toUpperCase();
		
		if (strTemp.length() > 0) {
			/*java.io.File file = new java.io.File(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);

			if(file.exists()) {
				strTemp = "../../../../upload_img/"+strTemp+"."+strImgFileExt;
				strTemp = "<label id='hide_img' onClick='HideImg()'><img src=\""+strTemp+"\" width=100 height=100></label>";
			}
			else {
				strTemp = "<img src='../../../../images/blank.gif' width='100' height='100' border='1'>";
			}*/
			
			strErrMsg = strRootPath+"upload_img/otr/"+strTemp+"."+strImgFileExt;
			java.io.File file = new java.io.File(strErrMsg);
			strErrMsg = "../../../../upload_img/otr/"+strTemp+"."+strImgFileExt;
			if(!file.exists()){
				strErrMsg = strRootPath+"upload_img/"+strTemp+"."+strImgFileExt;
				file = new java.io.File(strErrMsg);
				strErrMsg = "../../../../upload_img/"+strTemp+"."+strImgFileExt;
			}
			
			if(file.exists()) {
				//strTemp = "../../../../upload_img/"+strTemp+"."+strImgFileExt;
				strTemp = "<img src=\""+strErrMsg+"\"  style='width:1.5in; height:1.5in;' name='stud_image'>";
			}
			else {
				strTemp = "<img src='../../../../images/blank.gif' name='stud_image' style='width:1.5in; height:1.5in;' border='1'>";
			}
		}
%>
	<div style="right:0px; top:0px; position: relative;"><%=strTemp%></div></td>
  </tr>
  
  <tr>
    <td>Address:</td>
    <td><%=WI.fillTextValue("address")%></td>
  </tr>
  <tr>
      <td>ID Number</td>
      <td><%=WI.fillTextValue("stud_id")%></td>
  </tr>
  <tr>
    <td>Birth Date:</td>
    <td> 
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
    <td>Birth Place:</td>
    <td> 
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
    <td>Parent/Guardian:</td>
	<%
	strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(8));
	if(strTemp.length() == 0)
		strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(9));
	%>
    <td><%=WI.getStrValue(strTemp,"Mr. &amp; Mrs. ","","&nbsp;")%></td>
    </tr>
  <tr>
    <td>Nationality:</td>
    <td><%=WI.getStrValue((String)vStudInfo.elementAt(23), "&nbsp;")%></td>
  </tr>
  <tr>
    <td>Sex:</td>
    <td> 
<%
strTemp = (String)vStudInfo.elementAt(16);
if(strTemp.equals("M"))
	strTemp = "MALE";
else
	strTemp = "FEMALE";
%>
	<%=strTemp%>	</td>
  </tr>
  
  <tr><td height="10" colspan="2"></td></tr>
  <tr>
  	<td height="18">DEGREE/TITLE:</td>
	<td colspan="2"><strong style="font-size:14px;"><%=strStudCourseToDisp.toUpperCase()%>
	<%
	strTemp = WI.getStrValue((String)vStudInfo.elementAt(24))+WI.getStrValue((String)vStudInfo.elementAt(14),"-","","");
	%>
		<%=WI.getStrValue(strTemp," (",")","")%></strong></td>
  </tr>
  <tr><td height="10" colspan="3"></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">
  	<tr><td height="20" colspan="3" style="font-size:13px;">PRELIMINARY EDUCATION COMPLETED : </td></tr>
	<tr><td height="10" colspan="3"></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">  

  <tr>
    <td style="padding-left:25px;" width="19%" height="18">Primary</td>
    <td width="62%">: <%=WI.getStrValue((String)vEntranceData.elementAt(14))%></td>    
    <td width="19%"> <%=WI.getStrValue((String)vEntranceData.elementAt(18), "SY ", "","")%></td>
  </tr>
  <tr>
    <td style="padding-left:25px;" height="18">Intermediate</td>
    <td>: <%=WI.getStrValue((String)vEntranceData.elementAt(16))%></td>   
    <td width="19%"> <%=WI.getStrValue((String)vEntranceData.elementAt(20), "SY ", "","")%></td>
  </tr>

  
  <tr>
    <td style="padding-left:25px;" height="18">Secondary</td>
    <td>: <%=WI.getStrValue((String)vEntranceData.elementAt(5))%></td>    
    <td width="19%"> <%=WI.getStrValue((String)vEntranceData.elementAt(22), "SY ", "","")%></td>
  </tr>
</table>
<%}//show only if it is not first page..%> 



<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
	<%
		if(iPageNumber != 1)
			strTemp = "675px";
		else
			strTemp = "500px";	
	%>
	
		<td width="100%" height="<%=strTemp%>" valign="top" colspan="5">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">
			<!---------------    HEADER--                       -----------------------------   ------------------>
				<tr>
					<td class="thinborderTOPBOTTOM" align="center" height="20px" width="18%"><strong>COURSE NUMBER</strong></td>
					<td class="thinborderTOPBOTTOM" align="center"><strong>DESCRIPTIVE TITLE</strong></td>
					<td class="thinborderTOPBOTTOM" width="10%" align="center"><strong>FINAL RATING</strong></td>
					<td class="thinborderTOPBOTTOM" width="10%" align="center"><strong>RE-EXAM</strong></td>
					<td class="thinborderTOPBOTTOM" width="10%" align="center"><strong>CREDITS EARNED</strong></td>
				</tr>
			<!---- ---------------- END OF HEADER -------------------------------------------------->

<%			
if(vRetResult != null && vRetResult.size() > 0){
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

boolean bolIsSchNameNull    = false;
boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has 
boolean  bolPrinted = false; // print only once

String strGrade = null;
String strTemp3 = null;
String strSQLQuery = null;

//school name after it is null, it is encoded as cross enrollee.

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);
int iCountLoop = 0;
String strInternshipInfo = null;

String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;
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


for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow ){


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
		strSchNameToDisp = SchoolInformation.getSchoolName(dbOP,false,false);
	}
	if(strSchoolName == null){//-- && vRetResult.elementAt(i + 10) != null)//subject group name is not null for reg.sub
		strSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);
	}	
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
	
	//if(strCurSYSem.equals("FIRST SEMESTER 2009-2010"))
	//System.out.println("im here "+strCurSYSem);
	
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
		
		if(iCurrentRow == iRowStartFr){
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
		
	//++iCurrentRow;
	%>
  <tr bgcolor="#FFFFFF">
  	<td height="18" colspan="5"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td> 
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
	    		((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
				((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
				WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
					strInternshipInfo = (String)vInternshipInfo.remove(1);
					vInternshipInfo.remove(0);
				}
		}
}

%>

<%

String strTemp2 = "";
if( strSYToDisp != null && strSemToDisp != null && strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){ 
		strTemp2 = strSchNameToDisp.toUpperCase();
		
		//if(strTemp2.equalsIgnoreCase(strCurrentSchoolName))
		//	strTemp2 += " "+strCurrentSchoolAdd;
}

 if(strSYToDisp != null && strSemToDisp != null){ 
		if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
%>

	<%
	
	//if(bolIsCareGiver && vEntranceData.elementAt(27) != null)
		//strTemp = strSemToDisp +" "+ ((String)vEntranceData.elementAt(27)).toUpperCase();
		//((String)vEntranceData.elementAt(27)).toUpperCase()
	 // else 
				//strTemp = strSemToDisp +" "+ strSYToDisp + " " + strTemp2;
		
	strTemp3 = WI.getInsertValueForDB(strSchNameToDisp, true, null);
	strSQLQuery = "select SCH_CODE, SCH_ADDR from SCH_ACCREDITED where SCH_NAME="+strTemp3;
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()){
		strTemp3 = rs.getString(1);	 
		if(!strTemp2.equalsIgnoreCase(strCurrentSchoolName))
			strCurrentSchoolAdd = rs.getString(2);
	}else
		strTemp3 = ""; 
	rs.close();	
	
	if( WI.getStrValue(strTemp2).length() > 0 )
		strTemp2 += " " + WI.getStrValue(strCurrentSchoolAdd);
	
	if(iPageNumber > 1){	
		 //strTemp = strSemToDisp +" "+ strSYToDisp;
		 if(iRowStartFr == iCurrentRow)
			strTemp = strSemToDisp +" "+ strSYToDisp + " " + WI.getStrValue(strTemp3) + " Cont'd";
		 else
			strTemp = strSemToDisp +" "+ strSYToDisp + " " + strTemp2;
	}else	
		strTemp = strSemToDisp +" "+ strSYToDisp + " " + strTemp2;	
	//++iCurrentRow;
%>	  
  <tr bgcolor="#FFFFFF">    
	<td colspan="5"><u><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></strong></u></td>    	
  </tr>
  
<%
strPrevSchName = strSchNameToDisp;
}
strGrade = WI.getStrValue(strGrade);

if(strGrade.equals("on going")) {
	strGrade = "GNA";
	strCE = "";
}
else if(strGrade.compareToIgnoreCase("IP") == 0) {
	strGrade = "IP";
	strCE = "";
}
/**else {
	if(strGrade.indexOf(".") > -1 && strGrade.length() == 3) 
		strGrade = strGrade + "0";
}*/
//System.out.println(strCE);
if(bolIsCareGiver && strCE.length() > 0) 
	strCE = strCE + "hrs";
if(strCE.length() > 0 && strCE.indexOf(".") == -1)
	strCE = strCE + ".0";	

//it is re-exam if student has INC and cleared in same semester,
	strTemp = "";
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && //&& ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 - remove the inc checking..
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
			//System.out.println((String)vRetResult.elementAt(i + 9 + 11));
			
      strTemp = (String)vRetResult.elementAt(i + 8 + 11);	  
	  if(strTemp == null)	  	
	  	strTemp = "";
		
		
	  	i += 11;
      }
%>
	
  <tr bgcolor="#FFFFFF">      
  <td height="14"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>  
    <td><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;")%></label></td>
    <td style="padding-left:30px;"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strGrade%></label></td>
	<td align="center"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
	<td align="center"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strCE%></label></td>    
  </tr>

	


  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop
   
   if(iLastPage ==1){
   Vector vTrainings = new Vector();
   strTemp = WI.fillTextValue("additional_training");
   if(strTemp.length() > 0){
   		vTrainings = CommonUtil.convertCSVToVector(strTemp, "<br>", true);
   }
   
   	if(vTrainings.size() > 0){
	while(vTrainings.size() > 0){
		strTemp = (String)vTrainings.remove(0);
		strErrMsg = "";
		if(strTemp.indexOf("remarks") > -1){
			strErrMsg = strTemp.substring(strTemp.indexOf("remarks")+7);
			strTemp = strTemp.substring(0, strTemp.indexOf("remarks"));
		}
	%>
   	<tr><td colspan="2"><%=strTemp%></td><td colspan="3" style="padding-left:30px;"><%=strErrMsg%></td></tr>
	
	<%}}%>
   <tr><td colspan="5" class="thinborderTOP"><font style="font-size:13px;"><%=WI.fillTextValue("endof_tor_remark")%></font></td></tr>
   <tr><td colspan="5" class="thinborderTOP"  align="center">ENTRY BELOW THIS LINE IS NOT VALID</td></tr>
	<%}%>


		</table>
			<!-- Table inside td. -->
	<%}//only if student is having grade infromation.%>
		</td>
	</tr>
			
	<% if (iLastPage == 1){%>

	<!--<tr>
		<%if(vGraduationData != null &&  vGraduationData.size() > 0){				
			
					String strCourseCode = (String)vStudInfo.elementAt(24);
					String strMajorCode  = null;
					if(vStudInfo.size() > 25)
						strMajorCode = (String)vStudInfo.elementAt(25);
					else if(vStudInfo.elementAt(8) != null) {
						strMajorCode = "select course_code from major where course_index="+vStudInfo.elementAt(5)+
						" and major_index="+vStudInfo.elementAt(6)+" and is_del=0";
						strMajorCode = dbOP.getResultOfAQuery(strMajorCode,0);		
					}
					
					int iTemp = 1;
					if(bolIsCareGiver)
						strTemp = "GRADUATED WITH THE SIX-MONTH CARE GIVER";
					else
						strTemp = "GRADUATED WITH THE DEGREE, " +((String)vStudInfo.elementAt(7)).toUpperCase();						
					 
					 if(strMajorCode != null) {
						strTemp += ", MAJOR IN "+((String)vStudInfo.elementAt(8)).toUpperCase();
						strCourseCode = strCourseCode + " "+strMajorCode;
					 }
					
					 strTemp += WI.getStrValue(strCourseCode," (",") ","");
					//System.out.println(strTemp);	
					 if ((String)vGraduationData.elementAt(8) != null)
						strTemp += " AS OF " +WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
					
						
					 if(vGraduationData.elementAt(6) != null)
						strTemp +=	" AS PER " +vGraduationData.elementAt(6);
					 if (vGraduationData.elementAt(6) != null && vGraduationData.elementAt(7) != null) {
						if(bolIsCareGiver)
							strTemp +=  " DATED " ;
						else	
							strTemp +=  " DATED: " ;
						strTemp +=WI.formatDate((String)vGraduationData.elementAt(7),6).toUpperCase() + ".";
					 }
					 else	
						strTemp += ".";
						
					 if(vGraduationData.elementAt(16) != null)
						strTemp = strTemp + " "+((String)vGraduationData.elementAt(16)).toUpperCase();
					
					if (strTemp.length()/100 > 0) {
						iTemp = strTemp.length()/100;
						if (strTemp.length()%100 > 0)
							iTemp +=1;
					}
					 iRowsPrinted += iTemp; 
				%>  									
			<td valign="bottom" colspan="5" class="thinborderTOP" style="text-indent:50px;"><strong><font size="2"><%=strTemp.toUpperCase()%></font></strong></td>
			
			
			<%}
			 /* if(WI.fillTextValue("addl_remark").length() > 0)
					strTemp = WI.fillTextValue("addl_remark");
			  else
					strTemp = "";*/
			%>   	
					
		</tr>-->
		
		
		<tr>
			<td class="thinborderTOP" valign="bottom"><strong>REMARKS : </strong></td>
			<td valign="bottom" class="thinborderTOP"><strong><%=WI.getStrValue(WI.fillTextValue("addl_remark"))%></strong></td>
			<td valign="bottom" colspan="3" class="thinborderTOP" align="center">Date Issued: <%=WI.getTodaysDate(6)%></td>
		</tr>
<%}else{%>
  		<tr>
			<td class="thinborderTOP" valign="bottom"><strong>REMARKS : </strong></td>
			<td class="thinborderTOP" valign="bottom"><strong>Next page please</strong></td>
			<td class="thinborderTOP" valign="bottom" colspan="3" align="center">Date Issued: <%=WI.getTodaysDate(6)%></td>
		</tr>
<%}%>
		<tr>
			<td align="right" height="40" valign="bottom">Prepared by: </td>
			<td valign="bottom"> &nbsp; <%=WI.getStrValue(WI.fillTextValue("prep_by1"),WI.fillTextValue("prep_by2"))%></td>
		</tr>
		<tr>
			<td height="30">&nbsp;</td>
			<td height="30">&nbsp;</td>
			<td align="center" valign="bottom" colspan="3"><strong><%=WI.fillTextValue("registrar_name")%></strong></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td align="center" valign="top" colspan="3">Registrar</td>
		</tr>
		
</table>



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