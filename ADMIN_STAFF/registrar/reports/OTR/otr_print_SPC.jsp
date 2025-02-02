<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>OFFICIAL TRANSCRIPT OF RECORD</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: "Courier New", Courier, monospace;
	font-size: 11px;
}

td {
	font-family: "Courier New", Courier, monospace;
	font-size: 11px;
}

th {
	font-family: "Courier New", Courier, monospace;
	font-size: 11px;
}

.fontsize9 {
	font-family: "Courier New", Courier, monospace;	
	font-size: 5px;
}

.fontsize14{
	font-family: "Courier New", Courier, monospace;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }	
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;
    }
    .thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;
    }

    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }
    TD.thinborderRIGHTBOTTOM {
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }
	
	TD.thinborderTOPRIGHTBOTTOM {
	border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }
	
	TD.thinborderTOPLEFTBOTTOM {
	border-top: solid 2px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }
	
	TD.thinborderTOPLEFT{
	border-top: solid 2px #000000;
    border-left: solid 1px #000000;    
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }
	
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }
	
	TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 11px;	
    }
	
    TD.thinborderLEFTRIGHTBOTTOM {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
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
	if(strPrintPage.length() == 0) 
		strPrintPage = "1";
	
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
		//strPrintPage  = "1";//"1" is print. 
		
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
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};
//end of authenticaion code.
boolean bolIsCareGiver = false;//if caregiver, i have to append hrs to the credit earned.

Vector vStudInfo = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;
Vector vCompliedRequirement = null;
Vector vReqList = null;
double dGWA = 0d;
int iLevelID = 0;

Vector vMulRemark = null;
int iMulRemarkIndex = -1;

String strSQLQuery    = null;

Vector vLecLabUnit = new Vector();
String strLecUnit  = null;
String strLabUnit  = null;

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

java.sql.ResultSet rs = null;

String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};

String[] astrConvertSemUG  = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};
String[] astrConvertSemMED = {"SUMMER","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR"};
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
		//if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
		//	strErrMsg = studInfo.getErrMsg();
		if(vAdditionalInfo == null)
			vAdditionalInfo = new Vector();
			
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
		
		if(vRetResult != null && vRetResult.size() > 0) {
		vLecLabUnit = repRegistrar.getLecLabUnitInfoDBTC(dbOP, (String)vStudInfo.elementAt(12));
		if(vLecLabUnit == null)
			vLecLabUnit = new Vector();
	}
}
String strGetTuitionType = "select course_type from stud_curriculum_hist where user_index = "+vStudInfo.elementAt(12)+" and stud_curriculum_hist.is_valid = 1 and sy_from = ";

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
	//if(vEntranceData == null || vGraduationData == null)
	//	strErrMsg = entranceGradData.getErrMsg();
	
	if(vEntranceData == null)
		vEntranceData = new Vector();
	if(vGraduationData == null)
		vGraduationData = new Vector();
	
	repRegistrar.setGetCreditSubject(0);	
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true, strExtraCon);
	
	//System.out.println(vRetResult);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	{
		vMulRemark = (Vector)vRetResult.remove(0);
		student.GWA gwa = new student.GWA();
		dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));
	}
}
String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);

double dTotCreditEarned = 0d;
boolean bolIsCurrSchool = false;

boolean bolIsRLEHrs = false;
boolean bolShowLecLabHr = false; String[] astrLecLabHr = null;//gets lec/lab hour information.
String strRLEHrs    = null;
String strCE        = null;

boolean bolIsMedTOR = strDegreeType.equals("2");

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


int iIndexOf   = 0;
%>

<body topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0">
<form action="otr_print_SPC.jsp" method="post" name="form_">


<!--<table  width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td colspan="2" align="center"><font style="font-size:17px;" face="Courier New, Courier, monospace"><strong>
				  <%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font>
				  <br><font style="font-size:15px;" face="Courier New, Courier, monospace">
				  <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
			   <%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false), ", ", "", "")%><br>
			<%=SchoolInformation.getInfo1(dbOP,false,false)%></font>
		</td>
	  </tr>
	  <tr>
		<td colspan="2">&nbsp;</td>
	  </tr>
	  <tr>
	   <td colspan="2" align="center"><font style="font-size:15px;" face="Courier New, Courier, monospace">
	   <strong>OFFICE OF THE REGISTRAR </strong></font></td></tr>
	  <tr>
		<td colspan="2">&nbsp;</td>
	  </tr>
	  <tr>
		<td width="70%" align="center"><strong><font style="font-size:15px;" face="Courier New, Courier, monospace">
		OFFICIAL TRANSCRIPT OF RECORDS</font></strong></td>
	  </tr>
	  <tr><td height="5%">&nbsp;</td></tr>
	</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		 <td height="5" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td>
	  </tr>
	   <tr>
		 <td height="5" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td>
	  </tr>
	</table>	
-->

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="150px;">&nbsp;</td></tr>
</table>
	
<%if(iPageNumber > 1){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="5%" height="23"><font face="Courier New, Courier, monospace" >NAME:</font></td>
		<td width="95%"><font face="Courier New, Courier, monospace" ><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
      <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></font> </td>
		
	</table>
<%}else{%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" >
	<tr><td colspan="4">&nbsp;</td></tr>
	<tr><td height="23" colspan="3"><font face="Courier New, Courier, monospace" >Name</font>:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<font face="Courier New, Courier, monospace" ><u><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
	  <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></u></font>
	  </td>
	  <td width="18%" rowspan="9" valign="top" >
			<img src="../../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt%>" width="150" height="190" border="1" align="top">	  </td>
	  </tr>
		<%       
			if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
				strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1)).toUpperCase();
		 }else{
				strTemp = "&nbsp;";
		 }
%>
	<tr><td height="23" colspan="3"><font face="Courier New, Courier, monospace" >Date of Birth</font>:&nbsp;&nbsp;&nbsp;<u><font face="Courier New, Courier, monospace" ><%=strTemp%></font></u>&nbsp;&nbsp;
	<font face="Courier New, Courier, monospace" >PLACE OF BIRTH:</font> <u><font face="Courier New, Courier, monospace" ><%
                                if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
                                       strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2));
                                }else{
                                       strTemp = "&nbsp;";
                                }
                        %><%=strTemp%></font></u></td>
	</tr>
	
	<%      
		strTemp = (String)vStudInfo.elementAt(16);
		if(strTemp.equals("M"))
			strTemp = "MALE";
		else
			strTemp = "FEMALE";
%>
	
	<tr><td height="23" colspan="3"><font face="Courier New, Courier, monospace" >Sex</font>:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font face="Courier New, Courier, monospace"><u><%=strTemp.toUpperCase()%></u></font></td></tr>
	<%
	strTemp = "&nbsp;";
	if(vAdditionalInfo != null && vAdditionalInfo.size() > 0) {
		strTemp = (String)vAdditionalInfo.elementAt(8);
		//if(strTemp == null)
		//	strTemp = (String)vAdditionalInfo.elementAt(13);
	}
	%>
	<TR><TD height="23" colspan="3"><font face="Courier New, Courier, monospace" >Parent/Guardian: <u><%=WI.getStrValue(strTemp)%></u></font></TD></TR>
	
			
	<tr>
		<%
		strTemp = "&nbsp;";
		if(vAdditionalInfo != null && vAdditionalInfo.size() > 0)
			strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(3)).toUpperCase()+
				WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","").toUpperCase()+
				WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","").toUpperCase()+
				WI.getStrValue((String)vAdditionalInfo.elementAt(7)).toUpperCase();
		
		//spc ,, gets from gspis.
		strTemp = "select RES_HOUSE_NO, RES_PROVIENCE from INFO_CONTACT where user_index = "+(String)vStudInfo.elementAt(12);
		rs = dbOP.executeQuery(strTemp);
		if(rs.next()) {
			if(rs.getString(2) != null)
				strTemp = rs.getString(1)+", "+rs.getString(2);
			else	
				strTemp = rs.getString(1);
		}
		else	
			strTemp = "&nbsp;";
		rs.close();
		%>
	  <td height="23" colspan="3">
	  <font face="Courier New, Courier, monospace" >Address</font>:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font face="Courier New, Courier, monospace"><u><%=WI.getStrValue(strTemp, "&nbsp;")%></u></font>
		  <!--
		  <table width="100%" cellpadding="0" cellspacing="0">
		  		<tr>
					<td width="17%"><font face="Courier New, Courier, monospace" >Address</font>:</td>
					<td width="83%"><font face="Courier New, Courier, monospace" ><u><%=strTemp%></u></font></td>
				</tr>
		  </table>
		  -->
	  </td></tr>
	
	<%       if(vEntranceData != null && vEntranceData.size() > 0)
				strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
		 else	
				strTemp = "&nbsp;"; 
%>
<%
strTemp = "&nbsp;";
if(vEntranceData != null && vEntranceData.size() > 0)
	strTemp = WI.getStrValue((String)vEntranceData.elementAt(3));

		//spc ,, gets from gspis.
		strTemp = "select sch_name,course_taken from INFO_EDU_QUALIF where EXAM_NAME = 'Elementary' and user_index = "+(String)vStudInfo.elementAt(12);
		rs = dbOP.executeQuery(strTemp);
		if(rs.next()) {
			strTemp = rs.getString(1);
			strErrMsg = rs.getString(2);
		}
		else {	
			strTemp = "&nbsp;";
			strErrMsg= "&nbsp;";
		}
		rs.close();


%>
<tr><td height="23" colspan="2"><font face="Courier New, Courier, monospace" >Grade School Completed at</font>: <font face="Courier New, Courier, monospace" ><U><%=strTemp%></U></font></td>
<%
/**
	strTemp = "&nbsp;";
	if(vEntranceData != null && vEntranceData.size() > 0)
		strTemp = WI.getStrValue((String)vEntranceData.elementAt(19))+WI.getStrValue((String)vEntranceData.elementAt(20),"-","","");
**/
%>
<td width="14%"><u><font face="Courier New, Courier, monospace" ><%=WI.getStrValue(strErrMsg, "&nbsp;")%></font></u></td>
	
	</tr>
	<%
	strTemp = "&nbsp;";
	if(vEntranceData != null && vEntranceData.size() > 0)
		strTemp = (String)vEntranceData.elementAt(5);

		//spc ,, gets from gspis.
		strTemp = "select sch_name,course_taken from INFO_EDU_QUALIF where EXAM_NAME = 'High School' and user_index = "+(String)vStudInfo.elementAt(12);
		rs = dbOP.executeQuery(strTemp);
		if(rs.next()) {
			strTemp = rs.getString(1);
			strErrMsg = rs.getString(2);
		}
		else {	
			strTemp = "&nbsp;";
			strErrMsg= "&nbsp;";
		}
		rs.close();

	%>
	<tr><td height="23" colspan="2"><font face="Courier New, Courier, monospace" >High School Completed at</font>:&nbsp;<font face="Courier New, Courier, monospace" >
	<U><%=strTemp%></U></font></td>
	<%
	/**
	strTemp = "&nbsp;";
	if(vEntranceData != null && vEntranceData.size() > 0)
		strTemp = WI.getStrValue((String)vEntranceData.elementAt(21))+WI.getStrValue((String)vEntranceData.elementAt(22),"-","","");
	**/
	%>
	<td><u><font face="Courier New, Courier, monospace" ><%=WI.getStrValue(strErrMsg, "&nbsp;")%></font></u></td>
	</tr>
	
	<tr><td height="23" colspan="3"><font face="Courier New, Courier, monospace" >Date of Entrance</font>:&nbsp;&nbsp;<font face="Courier New, Courier, monospace" >
				<%if(vEntranceData != null && vEntranceData.size() > 0) {%>
						<u><%=WI.getStrValue((String)vEntranceData.elementAt(23),"")%></u> 
					<%}else{}%></font></td></tr>
	<%
	//if(vEntranceData != null && vEntranceData.size() > 0)
	//	strTemp = astrConvertToDocType[Integer.parseInt((String)vEntranceData.elementAt(8))];
	strTemp = WI.fillTextValue("entrance_data");
	%>
	<tr><td height="23" colspan="3"><font face="Courier New, Courier, monospace" >Basis of Admission</font>: 
		<font face="Courier New, Courier, monospace" ><u><%=strTemp%></u></font></td></tr>
	<tr><td colspan="4">&nbsp;</td>
	</tr>
<%
strTemp = WI.getStrValue((String)vStudInfo.elementAt(7)).toUpperCase();
iIndexOf = strTemp.indexOf("MAJOR IN");
if(iIndexOf > -1) {
	strErrMsg = strTemp.substring(iIndexOf + 9);
	strTemp = strTemp.substring(0, iIndexOf).toUpperCase();
}
else
	strErrMsg = "";
%>
	
	<tr><td height="23" colspan="4"><font face="Courier New, Courier, monospace" >Course</font>: <font face="Courier New, Courier, monospace" ><u> 
		<strong><%=strTemp%> (<%=((String)vStudInfo.elementAt(24)).toUpperCase()%>)</strong></u></font>&nbsp;&nbsp;
		<font face="Courier New, Courier, monospace" > Date of Graduation :</font>
	
	<%if(vGraduationData != null && vGraduationData.size() > 0)
						strTemp = WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
					  else
						strTemp = "";				  
					%> <font face="Courier New, Courier, monospace" ><u><%=strTemp%></u></font></td>
	
	
	
	</tr>
	<tr><td height="23" colspan="4"><font face="Courier New, Courier, monospace" >Major</font>:&nbsp;&nbsp;<font face="Courier New, Courier, monospace" ><u><%=WI.getStrValue(strErrMsg)%></u></font></td>
	</tr>
</table>

<%}




if(vRetResult != null && vRetResult.size() > 0){
	int iNumWeeks = 0;
	if (WI.fillTextValue("weeks").length() > 0) 
		iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100%" height="590px" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();">			
				
				<tr>
					<td height="25" width="20%" align="center" class="thinborderTOPBOTTOM">SUBJECT</td>
					<td align="center" class="thinborderTOPBOTTOM">DESCRIPTIVE TITLE</td>
					<td width="10%" align="center" class="thinborderTOPBOTTOM">FINAL</td>
					<td width="10%" align="center" class="thinborderTOPBOTTOM">COMPLETION</td>
					<td width="10%" align="center" class="thinborderTOPBOTTOM">CREDITS</td>					
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
int iCurrentRow = 0;//System.out.println(vRetResult);

String strInternshipInfo = null;

String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;
//System.out.println("iMaxRowToDisp 1 : " + iMaxRowToDisp);

if(WI.fillTextValue("addl_remark").length() > 0 && iLastPage == 1){

	int iTemp = 1;
	strTemp = WI.fillTextValue("addl_remark");
	iIndexOf = 0;

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
		strSQLQuery = strGetTuitionType + (String)vRetResult.elementAt(i+ 1)+" and semester = "+(String)vRetResult.elementAt(i+ 3);
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery,0);
		if(strSQLQuery != null && strSQLQuery.equals("1")) {
			astrConvertSem[1] = "FIRST TRIMESTER";
			astrConvertSem[2] = "SECOND TRIMESTER";
			astrConvertSem[3] = "THIRD TRIMESTER";
		}
		else {
			astrConvertSem[1] = "FIRST SEMESTER";
			astrConvertSem[2] = "SECOND SEMESTER";
			astrConvertSem[3] = "THIRD SEMESTER";
		}
	
	
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
	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//display will be schooo name<br>sy/term (cross enrolled)
		strSYToDisp = null;
		strSemToDisp = null;		
		//strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSY+" "+strCurSem+" (CROSS ENROLLED)";
//		strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSY+" "+strCurSem;
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

if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
		
	if(strSchNameToDisp.equalsIgnoreCase(strCurrentSchoolName))
		bolIsCurrSchool = true;
	else
		bolIsCurrSchool = false;
%>
  <tr bgcolor="#FFFFFF"> 
    
    <td height="20" style="padding-left:30px;" colspan="5"><strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strSchNameToDisp.toUpperCase()%></label>
    </strong></td>
  </tr>
  <%strPrevSchName = strSchNameToDisp;} 

if(strSYToDisp != null && strSemToDisp != null){
		if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
		++iRowsPrinted;
%>

	<%
	if(bolIsCareGiver && vEntranceData != null && vEntranceData.size() > 0 && vEntranceData.elementAt(27) != null)
		strTemp = strSemToDisp +" "+ ((String)vEntranceData.elementAt(27)).toUpperCase();		
	else
		strTemp = strSemToDisp +" "+ strSYToDisp;		
	%>	
  
  <tr bgcolor="#FFFFFF">  	    	
  	<td colspan="5" style="padding-left:30px;"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><u><%=strTemp%></u></label>	</td>
  </tr>  
<%}

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
    <td height="20" colspan="5" style="padding-left:30px;"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
  </tr>
  
  
  <%}//end of if(iMulRemarkIndex == i)
}//end of if(vMulRemark != null && vMulRemark.size() > 0) 

iIndexOf   = 0;
strGrade = WI.getStrValue(strGrade);

if(strGrade.equals("on going")) {
	strGrade = "&nbsp;";
	strCE = "";
}
else if(strGrade.compareToIgnoreCase("IP") == 0) {
	strGrade = "IP";//
	strCE = "";
}
else {
	if(strGrade.indexOf(".") > -1 && strGrade.length() == 3) 
		strGrade = strGrade + "0";
}

if(bolIsCareGiver && strCE.length() > 0) 
	strCE = strCE + "hrs";

//if(strCE.length() > 0 && strCE.indexOf(".0") > -1)
	
//if(strCE.length() > 0 && strCE.indexOf(".") == -1)
//	strCE=strCE.trim()+".00";	

//get lec lab unit
/*	try {
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
		
	}	*/
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
	  
if(bolIsCurrSchool){
	try{		
		dTotCreditEarned += Double.parseDouble(strCE);
	}catch(Exception e){}
}
	
%>
	
<tr bgcolor="#FFFFFF">      
	<td valign="top" height="14">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 6))%></td>  
	<td valign="top"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(WI.getStrValue(vRetResult.elementAt(i + 7)),"&nbsp;")%> </label></td>	
	<td valign="top" align="center"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strGrade%></label></td>
	<td valign="top" align="center"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(strTemp,"&nbsp;")%></label></td>
	<td valign="top" align="center" width="10%"><%=strCE%></td>
</tr>

	


  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop
   %>
   
   
<% if (iLastPage == 1){%>
	<tr>
		<td>&nbsp;</td>
		<td align="center">--- nothing follows ---</td>
		<td align="center" style="border-top:solid 1px #000000;"><%=CommonUtil.formatFloat(dGWA, 1)%></td>
		<td>&nbsp;</td>
		<td align="center" style="border-top:solid 1px #000000;"><%=CommonUtil.formatFloat(dTotCreditEarned, false)%></td>
	</tr>


		<tr>
					<%if(vGraduationData != null &&  vGraduationData.size() > 0){	
						String strCourseCode = (String)vStudInfo.elementAt(24);
						String strMajorCode  = null;
						if(vStudInfo.size() > 25)
							strMajorCode = (String)vStudInfo.elementAt(25);
						else if(vStudInfo.elementAt(8) != null) {
							strMajorCode = "select course_code from major where course_index="+vStudInfo.elementAt(5)+" and major_index="+vStudInfo.elementAt(6)+" and is_del=0";
							strMajorCode = dbOP.getResultOfAQuery(strMajorCode,0);		
						}
						boolean bolIsAssociate = false;
						if( ((String)vStudInfo.elementAt(7)).toLowerCase().indexOf("associate") > -1 )
							bolIsAssociate = true;
						int iTemp = 1;
						if(bolIsCareGiver)
							strTemp = "GRADUATED WITH THE SIX-MONTH CARE GIVER";
						else{
							if(!bolIsAssociate)
//								strTemp = "ON "+WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase() ;
								strTemp = " FROM THE DEGREE OF "+WI.getStrValue((String)vStudInfo.elementAt(7)).toUpperCase();		
							else{
								strTemp = WI.getStrValue((String)vStudInfo.elementAt(2)).toUpperCase() +", "+ 
									WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase() + " " +
									WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase();
							
								strTemp = "Completed all "+
									" the requirements leading to the title of "+WI.getStrValue((String)vStudInfo.elementAt(7)).toUpperCase()+
									" on "+WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
								}
							//strTemp = "Graduated with the degree of " +((String)vStudInfo.elementAt(7)).toUpperCase();			
						} 
						 if(strMajorCode != null) {
							strTemp += " MAJOR IN "+WI.getStrValue((String)vStudInfo.elementAt(8)).toUpperCase();
							strCourseCode = strCourseCode + " "+strMajorCode;
						 }
						
						 if(!bolIsAssociate)
						 	strTemp += WI.getStrValue(strCourseCode," (",")","");
						
						 //if ((String)vGraduationData.elementAt(8) != null)
						//	strTemp += " on " +WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase()+".";
						
						 /*
							 if(vGraduationData.elementAt(6) != null){
								strTemp += " PER SPECIAL ORDER "+WI.getStrValue(vGraduationData.elementAt(6))+
									" DATED "+WI.formatDate((String)vGraduationData.elementAt(7),6).toUpperCase();
									//strTemp += " Exempted from the issuance of Special Order by virtue of the AUTONOMOUS STATUS granted by the "+
								//"COMMISSION ON HIGHER EDUCATION (CHED) Resolution No. "+WI.getStrValue(vGraduationData.elementAt(6))+".";	
							 }else{
								strTemp += " EXEMPTED FROM SPECIAL ORDER.";
							 }		
						*/	 			
						if (strTemp.length()/100 > 0) {
							iTemp = strTemp.length()/100;
							if (strTemp.length()%100 > 0)
								iTemp +=1;
						}
						 iRowsPrinted += iTemp; 
					%>  									
						<td colspan="5" class="thinborderTOP">
							<table width="100%">
								<tr>
									<td valign="top" width="15%"><strong>&nbsp;<%if(!bolIsAssociate && !bolIsCareGiver){%>GRADUATED :<%}%></strong></td>
									<td valign="top" align="justify"><%=WI.getStrValue(strTemp).toUpperCase()%></td>
								</tr>
							</table>						</td>
						<%}%>  	
		</tr>			
					
		<!-- removed as per Paolo July 21, 2014
		<tr><td height="18" colspan="5" align="center"><strong>--- End of Transcript --- </strong></td></tr>	
		-->
	<%if(WI.fillTextValue("addl_remark").length() > 0){%>
		<tr>
			<td colspan="5" align="justify"><strong>REMARKS : </strong><%=WI.fillTextValue("addl_remark")%></td>
		</tr>
	<%}%>
		<tr>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td  height="20" colspan="3" align="center">I hereby certify that the above transcript of record is correct.</td>
			  </tr>
			  <tr>
				<td  height="20" ><font face="Courier New, Courier, monospace">Checked by:</font></td>
				<td  height="20" ><font face="Courier New, Courier, monospace">Verified by:</font></td>
				<td  height="20" >&nbsp;</td>
			  </tr>
			  <tr>
				<td  height="20" colspan="3">&nbsp;</td>
			  </tr>
			  <tr>
				<td  height="20">
				 <table width="99%" border="0" cellspacing="0" cellpadding="0" >
				  <tr>
					<td align="left" height="20"><font face="Courier New, Courier, monospace" > 
					<%=WI.getStrValue(WI.fillTextValue("check_by1")).toUpperCase()%></font> </td>
				  </tr>
				  <tr>
					<td align="left" ><font face="Courier New, Courier, monospace" >Records In-Charge</font> </td>
				  </tr>
				</table></td>
				<td><table width="100%" border="0" cellspacing="0" cellpadding="0" >
				  <tr>
					<td height="20"><font face="Courier New, Courier, monospace" > <%=WI.getStrValue(WI.fillTextValue("check_by2")).toUpperCase()%></font> </td>
				  </tr>
				  <tr>
					<td><font face="Courier New, Courier, monospace" >Comptroller</font> </td>
				  </tr>
				</table></td>
				<td><table width="100%" border="0" cellspacing="0" cellpadding="0" >
				  <tr>
					<td height="20"><font face="Courier New, Courier, monospace" > <%=WI.getStrValue(WI.fillTextValue("registrar_name"))%></font> </td>
				  </tr>
				  <tr>
					<td><font face="Courier New, Courier, monospace" >Registrar</font> </td>
				  </tr>
				</table></td>
			  </tr>
			  <tr>
				<td colspan="2">Date : <%=WI.getTodaysDate(6)%></td>
			  </tr>
			</table>
		</tr>

<%}%>
		</table>
			<!-- Table inside td. -->
	
		</td>
	</tr>	
</table>







<% if (iLastPage != 1){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td  height="20" colspan="3" align="center"> - <%=iPageNumber%> - </td>
	  </tr>
		<tr><td colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
	  <tr>
		<td  height="20" ><font face="Courier New, Courier, monospace">Checked by:</font></td>
		<td  height="20" ><font face="Courier New, Courier, monospace">Verified by:</font></td>
		<td  height="20" >&nbsp;</td>
	  </tr>
	  <tr>
		<td  height="20" colspan="3">&nbsp;</td>
	  </tr>
	  <tr>
		<td  height="20">
		 <table width="99%" border="0" cellspacing="0" cellpadding="0" >
		  <tr>
			<td align="left" height="20"><font face="Courier New, Courier, monospace" > 
			<%=WI.getStrValue(WI.fillTextValue("check_by1")).toUpperCase()%></font> </td>
		  </tr>
		  <tr>
			<td align="left" ><font face="Courier New, Courier, monospace" >Records In-Charge</font> </td>
		  </tr>
		</table></td>
		<td><table width="100%" border="0" cellspacing="0" cellpadding="0" >
		  <tr>
			<td height="20"><font face="Courier New, Courier, monospace" > <%=WI.getStrValue(WI.fillTextValue("check_by2")).toUpperCase()%></font> </td>
		  </tr>
		  <tr>
			<td><font face="Courier New, Courier, monospace" >Comptroller</font> </td>
		  </tr>
		</table></td>
		<td><table width="100%" border="0" cellspacing="0" cellpadding="0" >
		  <tr>
			<td height="20"><font face="Courier New, Courier, monospace" > <%=WI.getStrValue(WI.fillTextValue("registrar_name"))%></font> </td>
		  </tr>
		  <tr>
			<td><font face="Courier New, Courier, monospace" >Registrar</font> </td>
		  </tr>
		</table></td>
	  </tr>
	  <tr>
		<td colspan="2">Date : <%=WI.getTodaysDate(6)%></td>
	  </tr>
	</table>
<%}else{%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td  height="20" colspan="3" align="center"> - <%=iPageNumber%> - </td>
	  </tr>
		<tr><td colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
	</table>
<%}%>






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
<input name="print_" type="hidden" value="<%=WI.fillTextValue("print_")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>