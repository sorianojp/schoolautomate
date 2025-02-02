<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>FATIMA OFFICIAL TRANSCRIPT OF RECORDS</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
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
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
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
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Registrar Management","OTR",request.getRemoteAddr(),
															null);
}
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


String[] astrConvertSem = {"SUMMER","1ST SEMESTER","2ND SEMESTER","3RD SEMESTER","4TH SEMESTER"};

String[] astrConvertSemUG  = {"SUMMER","1ST SEMESTER","2ND SEMESTER","3RD SEMESTER","4TH SEMESTER"};
String[] astrConvertSemMED = {"SUMMER","Academic Year","Academic Year","Academic Year","Academic Year"};
String[] astrConvertSemMAS = {"SUMMER","1ST TERM","2ND TERM","3RD TERM",""};

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
		//System.out.println("strCollegeName "+(String)vStudInfo.elementAt(5));
		if(strCollegeName != null)
			strCollegeName = strCollegeName.toUpperCase();
		
		strQuery = "select dean_name from college where c_index = "+(String)vStudInfo.elementAt(5);
		strCollegeDean = dbOP.getResultOfAQuery(strQuery, 0);
		//System.out.println("strCollegeDean "+strCollegeDean);
		if(strCollegeDean != null)
			strCollegeDean = strCollegeDean.toUpperCase();
		
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(12));
		//System.out.println(vAdditionalInfo);
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
	}
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,WI.fillTextValue("stud_id"),(String)vStudInfo.elementAt(7),(String)vStudInfo.elementAt(8));
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


int iIndexOf = 0;
Vector vExcludeSubList = new Vector();

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
//	System.out.println("strDegreeType : " + strDegreeType);
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
		
		
	//System.out.println(strExtraCon);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true, strExtraCon);
	
	//System.out.println("vRetResult "+vRetResult);
Vector vComponentGrade = new Vector();
Vector vComponent = new Vector();


vComponentGrade.addElement("NCM 101A");
	vComponent.addElement("NCFHN 101A");vComponent.addElement("NCMCN 101A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 102A");
	vComponent.addElement("NCOB 102A");vComponent.addElement("NCPE 102A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 103A");
	vComponent.addElement("NCMS 103A");vComponent.addElement("NCOR 103A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 104A");
	vComponent.addElement("NCD 104A");vComponent.addElement("NCS 104A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 102");
	vComponent.addElement("NCCO 102");vComponent.addElement("NCCO 102");vComponent.addElement("NCOR 102");vComponent.addElement("NCOB 102");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 104");
	vComponent.addElement("NCCD 104A");vComponent.addElement("NCMS 104A");vComponent.addElement("NCPS 104A");vComponent.addElement("NCPE 104A");
	vComponent.addElement("NCD 104A");vComponent.addElement("NCS 104A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 106A");
	vComponent.addElement("NONC 106A");vComponent.addElement("NABC 106A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 107A");
	vComponent.addElement("NCMG 107A");vComponent.addElement("NCPA 107A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 105C");
	vComponent.addElement("NCMG 105C");vComponent.addElement("NCMS 105C");
	vComponent.addElement("NCPA 105C");vComponent.addElement("NCSE 105C");
vComponentGrade.addElement(vComponent); vComponent = new Vector();


//check if this is available

for(int i =1; i < vRetResult.size(); i += 11) {
	iIndexOf = vComponentGrade.indexOf(WI.getStrValue(vRetResult.elementAt(i + 6)));
	if(iIndexOf > -1) {
		vComponentGrade.remove(iIndexOf);
		vComponent = (Vector)vComponentGrade.remove(iIndexOf);
		vExcludeSubList.addAll(vComponent);
	}
}
//System.out.println(vExcludeSubList);


	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);

	if (strDegreeType != null && strDegreeType.equals("1")) {
		astrConvertSem[0] = "SUMMER";
		astrConvertSem[1] = "1ST TERM";
		astrConvertSem[2] = "2ND TERM";
		astrConvertSem[3] = "3RD TERM";
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
	
%>

<body topmargin="0" leftmargin="0" rightmargin="0">
<form action="./otr_print_FATIMA.jsp" method="post" name="form_">

<table width="100%" border="0" onClick="PrintNextPage();">
	<tr height="">
		<td height="100px">&nbsp;</td>
	</tr>	
</table>




<table width="100%" border="0">
	<tr valign="top">
	  <td width="240px"><br>			
			<table width="100%" border="0">
				<tr>
				<td width="2%">&nbsp;</td>
				<td><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,&nbsp;<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td></tr>
				<tr><td>&nbsp;</td></tr>
				
				
				<tr><td>&nbsp;<br><br>&nbsp;</td></tr><!--ADDRESS-->
				<tr>
				<td width="2%">&nbsp;</td>
				<td width="" class=""><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%>			
				<%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")%>
				<%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")%>
				<%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","")%>
				<%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"","","")%>				</td></tr>
				<tr><td>&nbsp;</td></tr>
				
				
				<tr><td>&nbsp;</td></tr><!--ENTRANCE DATA..-->
				<tr>
				<td width="2%">&nbsp;</td>
				<td>Admission Status: <%strTemp = WI.fillTextValue("entrance_data");%> <%=strTemp%> </td></tr>
				<tr>
				<td width="2%">&nbsp;</td>
				<td>Date of Admission: 
				<% if(vEntranceData != null) {%>
		  			<%=WI.getStrValue((String)vEntranceData.elementAt(23),"&nbsp;")%> 
				<%}else{%> &nbsp; <%}%></td></tr>
				<tr><td height="25">&nbsp;</td></tr>
				
				
				<%if(strDegreeType != "1" || strDegreeType != "2"){%>
				<tr><td height="">&nbsp;</td></tr><!--COURSE-->
				<tr>
				<td width="2%">&nbsp;</td>
				<td><%=strStudCourseToDisp%></td></tr>
				<tr><td height="">&nbsp;</td></tr>
				<%}%>
				
				<tr><td height="">&nbsp;</td></tr><!--RECORD OF GRADUATION-->
				<%if(vGraduationData != null)
					strTemp = (String)vGraduationData.elementAt(8);
				  else
					strTemp = "";				  
				%>
				<tr>
				<td width="2%">&nbsp;</td>
				<td><font size="1">Date of Graduation/Completion: <%=strTemp%></font></td></tr>
				<!-- TITLE/DEGREE -->
				<tr>
				<td width="2%">&nbsp;</td>
				<td width="" class="">
				  <strong> 
					<% if (iLastIndex != -1){%>
					 <%=((String)vStudInfo.elementAt(7)).substring(0,iLastIndex)%>
					<%}else{%>
					 <%=(String)vStudInfo.elementAt(7)%>
					<%}%>
			    </strong>		 	 	</td></tr>
<%
int iHeight = 40;
if(vGraduationData != null && vGraduationData.elementAt(6) != null) {iHeight = iHeight - 15;%>
				<tr>
				  <td>&nbsp;</td>
				  <td class="">S.O.#: <%=vGraduationData.elementAt(6)%></td>
			  </tr>
	<%if(vGraduationData.elementAt(7) != null) {iHeight = iHeight - 15;%>
				<tr>
				  <td>&nbsp;</td>
				  <td class="">Date: <%=vGraduationData.elementAt(7)%></td>
			  </tr>
	<%}
}%>
				
				<!-- DATE RELEASE/DATE PRINTED -->
				<tr><td height="<%=iHeight%>">&nbsp;</td></tr>
				<tr><td height="40">&nbsp;</td></tr>
				<tr>
				<td width="2%" height="">&nbsp;</td>
				<td><%=WI.getTodaysDate(1)%></td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr><td height="190">&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>			
				
				
				<tr>
				<td width="2%">&nbsp;</td>
				<td height="75" colspan="" align="left" valign="top"><%=WI.getStrValue(WI.fillTextValue("addl_remark"),"","","")%><br><br></td>
				</tr>
		
				<tr>
				<td width="2%">&nbsp;</td>
				<td><strong>Prepared by</strong></td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr>
				<td width="2%">&nbsp;</td>
				<td><%=WI.fillTextValue("prep_by1").toUpperCase()%></td></tr>
				<tr>
				<td width="2%">&nbsp;</td>
				<td>&nbsp;</td>
				</tr>
				<tr><td>&nbsp;</td></tr>
				<tr>
				<td width="2%">&nbsp;</td>
				<td>&nbsp;</td>
				</tr>
				<tr>
				<td width="2%">&nbsp;</td>
				<td><strong>Checked by</strong></td>
				</tr>
				<tr><td>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr>
				<td width="2%">&nbsp;</td>
				<td><%=WI.fillTextValue("check_by1").toUpperCase()%></td>
				</tr>

				<tr><td>&nbsp;</td></tr>
				
				<%if(strCollegeDean != null){%>
				<tr>
				<td width="2%">&nbsp;</td>
				<td><%=strCollegeDean%></td></tr>
				<tr>
				<td width="2%">&nbsp;</td>
				<td>Dean</td></tr>
				<%}%>
				<tr><td>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr>
				<td width="2%">&nbsp;</td>
				<td><%=WI.fillTextValue("registrar_name").toUpperCase()%></td></tr>
				<tr>
				<td width="2%">&nbsp;</td>
				<td>Registrar</td></tr>
				<tr><td>&nbsp;</td></tr>				
			</table>
	  </td>
	  <td width="10">&nbsp;</td>
		<td>	
	<%	
		
	if(vRetResult != null && vRetResult.size() > 0){
	int iNumWeeks = 0;
	if (WI.fillTextValue("weeks").length() > 0) iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">

<!------------------------------------------------------ HEADER---------------------------------------------- ---------->  
  
  <tr bgcolor="#FFFFFF" height="25">   
  	<td width="2%">&nbsp;</td> 
    <td width="84%"></td>    
    <td width="8%"></td>
    <td width="6%"></td>
  </tr>
  
<!---------------------------------------------- END OF HEADER ----------------------------------------------------------------->
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
	
	if(vExcludeSubList.indexOf(vRetResult.elementAt(i + 6)) > -1)
		continue;
		
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
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+" "+
					(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
					
		strCurSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+3))];
		strCurSY  = (String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
		
	}
	else {
		strCurSYSem = (String)vRetResult.elementAt(i+ 3)+" "+(String)vRetResult.elementAt(i+ 1)+" - "+
							(String)vRetResult.elementAt(i+ 2);
							
		strCurSem = (String)vRetResult.elementAt(i+ 3);
		strCurSY  = (String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
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
    <td height="18" colspan="3"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
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
  	<td width="2%">&nbsp;</td> 
    <td height="17" colspan="3"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
  </tr>
<%}%>  

<%if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
//	System.out.println("iRowsPrinted 3:" + iRowsPrinted + "; strSchNameToDisp"+ strSchNameToDisp );		
		//do not keep extra line for school name.%>
  <tr bgcolor="#FFFFFF"> 
    <td width="2%">&nbsp;</td> 
    <td height="17" colspan="3"> <strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strSchNameToDisp.toUpperCase()%></label>
    </strong></td>
  </tr>
  <%strPrevSchName = strSchNameToDisp;
 } // if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp))))





if(strSYToDisp != null && strSemToDisp != null){
		if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
%>


  <tr bgcolor="#FFFFFF">     
  <td width="2%">&nbsp;</td> 
    <td colspan="3"><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')">
	<%if(bolIsCareGiver && vEntranceData.elementAt(27) != null){%>
		<%=((String)vEntranceData.elementAt(27)).toUpperCase()%>
	<%}else{%>
		<%=strSYToDisp%>
	<%}%>
	</label></strong>
	</td>  
  </tr>
  
 	<tr bgcolor="#FFFFFF">  
	<td width="2%">&nbsp;</td>    	
  	<td colspan="3"><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=strSemToDisp%></label></strong>
	</td>
  </tr>
  
<%}
strGrade = WI.getStrValue(strGrade);

if(strGrade.equals("on going")) {
	strGrade = "GNA";
	strCE = "0";
}
else if(strGrade.compareToIgnoreCase("IP") == 0) {
	strGrade = "IP";
	strCE = "0";
}
else {
	if(strGrade.indexOf(".") > -1 && strGrade.length() == 3) 
		strGrade = strGrade + "0";
}
if(bolIsCareGiver && strCE.length() > 0) 
	strCE = strCE + " hrs";
if(strCE != null && strCE.indexOf(".") == -1 && strCE.indexOf("nbsp") == -1)
	strCE = strCE.trim() + ".0";


//start of chopping the subject.
strTemp = WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;");
if(strTemp.length() > 65) {
	int iBreakPoint = 65;
	while(iBreakPoint > 0) {
		if(strTemp.charAt(iBreakPoint) == ' ')
			break;
		--iBreakPoint;
	}
	strTemp = strTemp.substring(0, iBreakPoint) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+strTemp.substring(iBreakPoint+1);
}

%>

  <tr bgcolor="#FFFFFF">    
  <td width="2%" height="18">&nbsp;</td>  
    <td >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
    <td align="center"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strGrade%></label></td>
    <td align="center">&nbsp;&nbsp;&nbsp;<%=strCE%></td>
  </tr>
	<%if(strMulRemarkAtEndOfSYTerm != null){%>	
	  <tr bgcolor="#FFFFFF"> 
	  <td width="2%">&nbsp;</td> 
    	<td height="18" colspan="3"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strMulRemarkAtEndOfSYTerm%></label></td>
  	  </tr>
	<%}//prints remarks at end of Sy/Term.%>


  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop
   %>
</table>


<% if (iLastPage == 1){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">

  <tr>  
    <td height="18" colspan="5" align="center">------------------------ NO ENTRIES TO FOLLOW ------------------------</td>	
  </tr>
  
  <tr>    	
    <td height="18" colspan="5" align="center"><label id='hide_img' onClick='HideImg()'><img src="../../../../upload_img/<%=WI.fillTextValue("stud_id")%>.jpg" width="100" height="100" border="1"></label></td>	
  </tr>
  
  <%
  if(WI.fillTextValue("endof_tor_remark").length() > 0) {%>  	
  	<tr>	  
	  <td width="20%">&nbsp;</td>	  	
		<td height="18" colspan="" align="center" style="text-align:justify"><%=WI.fillTextValue("endof_tor_remark")%></td>			
		<td width="20%">&nbsp;</td> 
	</tr>
  <%}else if(WI.fillTextValue("endof_tor_remark1").length() > 0 && WI.fillTextValue("endof_tor_remark").length() == 0) {%>
	  <tr>	  
	  <td width="20%">&nbsp;</td>	  	
		<td height="18" colspan="" align="center" style="text-align:justify"><%=WI.fillTextValue("endof_tor_remark1")%></td>			
		<td width="20%">&nbsp;</td> 
	  </tr>
  <%}%>
</table>
<% } // if (iLastPage == 1)
	else { // 
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="18" colspan="2" align="center">*****  NEXT PAGE  ******</td>
  </tr>
</table>
<% }

if (iMaxRowToDisp - iRowsPrinted > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%   for(int abc = 0; abc < iMaxRowToDisp - iRowsPrinted; ++abc){  // insert space  %>
<tr>
    <td height="18">&nbsp;</td>
  </tr>
<%}%>
</table>
<%}%>



<%}//only if student is having grade infromation.%>
		
		
		
		</td>	
		
<!--MAIN TABLE-->
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