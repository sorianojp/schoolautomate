<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>OFFICIAL TRANSCRIPT OF RECORDS</title>
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
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
			(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
	}
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,request.getParameter("stud_id"),
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
	
	//System.out.println(vRetResult);
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
	}//System.out.println(vRetResult);
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

<body topmargin="0">
<form action="./otr_print_UL.jsp" method="post" name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr > 
    <td width="15%" height="116px">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td width="15%">&nbsp;</td>
  </tr>
  <tr> 
    <td headers="20">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<%if(vAdditionalInfo != null) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="82%"><table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="15%">Name :<br> </td>
          <td width="92%" class="thinborderBOTTOM"><strong>&nbsp;<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
        </tr>
      </table></td>
    <td width="18%" rowspan="6" valign="bottom">
		<table cellpadding="0" cellspacing="0" width="100%">
			<tr>
			<%
			strTemp = WI.fillTextValue("stud_id").toUpperCase();
			
			if (strTemp.length() > 0) {
					
			java.io.File file = new java.io.File(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);			
			if(file.exists()) {				
				strTemp = "../../../../upload_img/"+strTemp+"."+strImgFileExt;
				strTemp = "<label id='hide_img' onClick='HideImg()'><img src=\""+strTemp+"\" width='86' height='83'></label>";
			}
			else {
				strTemp = "<label id='hide_img' onClick='HideImg()'><img src='../../../../images/blank.gif' width='86' height='83' border='1'></label>";
			}
		}
			
			%>
				<td colspan="2"><%=strTemp%>
					<!--<label id='hide_img' onClick='HideImg()'><img src="../../../../upload_img/<%//=WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt%>" 
							width="110" height="110" border="1" align="top"></label>				--></td>
			</tr>
			<tr> 
			  <td width="21%">ID#</td>
			  <td width="79%"><u><%=WI.fillTextValue("stud_id").toUpperCase()%></u></td>
			</tr>
		</table>	</td>
  </tr>
  <tr> 
    <td><table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr>
           <td>College of:</td>
           <td colspan="3" class="thinborderBOTTOM">&nbsp;<%=(String)vStudInfo.elementAt(26)%></td>
        </tr>
        <%if(WI.getStrValue(strStudMajorToDisp).length() > 0){%>
		  <tr> 
          <td width="14%">Course :</td>
          <td width="39%" class="thinborderBOTTOM">&nbsp;<%=strStudCourseToDisp/**(String)vStudInfo.elementAt(7)**/%></td>
          
			 <td width="9%" align="right">Major&nbsp;</td>
          <td width="38%" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(strStudMajorToDisp/**(String)vStudInfo.elementAt(8)**/)%></td>
        </tr>
		  <%}else{%>
		  <tr> 
          <td width="14%">Course :</td>
          <td colspan="3" class="thinborderBOTTOM">&nbsp;<%=strStudCourseToDisp%></td>
			 </tr>
			<%}%>
      </table></td>
  </tr>
  <!--<tr> 
    <td><table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="15%">Major :</td>
          <td width="91%" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(strStudMajorToDisp/**(String)vStudInfo.elementAt(8)**/)%></td>
        </tr>
      </table></td>
  </tr>-->
  <tr> 
    <td><table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="14%">Address :</td>
          <td width="86%" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","")%></td>
        </tr>
      </table></td>
  </tr>
  <tr> 
    <td><table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="14%">DOB :</td>
          <td width="31%" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></td>
          <td width="18%"> &nbsp;Place of Birth: </td>
          <td width="37%" class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(2),"&nbsp;")%></td>
        </tr>
      </table></td>
  </tr>
  <tr> 
    <td><table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="21%">Secondary School</td>
          <td width="58%" class="thinborderBOTTOM"> &nbsp; <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");
else	
	strTemp = "&nbsp;";
%> <%=strTemp%> </td>
          <td width="7%" align="right">Year:</td>
          <td width="14%" class="thinborderBOTTOM">&nbsp;<%
strTemp = "";
if(vEntranceData != null) {
	strTemp = WI.getStrValue(vEntranceData.elementAt(21));
	if(vEntranceData.elementAt(22) != null) {
		if(strTemp != null && strTemp.length() > 0) 
			strTemp = strTemp + "-" +(String)vEntranceData.elementAt(22);
		else
			strTemp = (String)vEntranceData.elementAt(22);
	}
}
else	
	strTemp = "&nbsp;";
%> <%=strTemp%></td>
        </tr>
      </table></td>
  </tr>
  <tr> 
    <td valign="top"><table width="98%" border="0" cellpadding="0" cellspacing="0">        
		  <tr> 
          <td width="21%">Admission Date :</td>
          <td width="38%" class="thinborderBOTTOM"> &nbsp; 
		  <% if(vEntranceData != null) {%>
            <%=WI.getStrValue((String)vEntranceData.elementAt(23),"&nbsp;")%>
            <%}else{%>
&nbsp;
<%}%></td>
          <td width="4%">&nbsp;  </td>
          <td width="37%">Date OTR Printed: <%=WI.getTodaysDate(6)%></td>
        </tr>
      </table></td>
  </tr>
  <tr><td height="10"></td></tr>
  <!--<tr> 
    <td><table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="21%">Elementary School</td>
          <td width="59%" class="thinborderBOTTOM"> &nbsp; 
		  <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
else	
	strTemp = "&nbsp;";
%> <%=strTemp%></td>
          <td width="7%"><div align="right">&nbsp;Year:</div></td>
          <td width="13%" class="thinborderBOTTOM">&nbsp; <%
strTemp = "";
if(vEntranceData != null) {
	strTemp = WI.getStrValue(vEntranceData.elementAt(19));
	if(vEntranceData.elementAt(20) != null) {
		if(strTemp != null && strTemp.length() > 0) 
			strTemp = strTemp + " - " +(String)vEntranceData.elementAt(20);
		else
			strTemp = (String)vEntranceData.elementAt(20);
	}
}
else	
	strTemp = "&nbsp;";
%> <%=strTemp%></td>
        </tr>
      </table></td>
  </tr>-->
  
</table>
<%}//if iPage number = 1

if(vRetResult != null && vRetResult.size() > 0){
	int iNumWeeks = 0;
	int iColspan = 2;
	if (WI.fillTextValue("weeks").length() > 0) iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));
	
	if (bolShowLecLabHr)  iColspan +=2;
	if (bolIsRLEHrs) iColspan++;
		
%>
<table cellpadding="0" cellspacing="0" width="100%" border="0" height="550px">
	<tr valign="top">
		<td>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" onClick="PrintNextPage();" class="thinborder">			 
			  <!--<tr bgcolor="#FFFFFF"> 
				<td class="thinborder">&nbsp;</td>
				<td height="25" colspan="<%=iColspan - 1%>" class="thinborderBOTTOM"><div align="center"><strong>ACADEMIC RECORD</strong></div></td>
				<td colspan="2" class="thinborder"><div align="center"><strong>GRADES</strong></div></td>
				<td width="10%" rowspan="2" class="thinborderLEFTRIGHTBOTTOM"><div align="center"><strong>UNITS</strong></div></td>
			  </tr>-->
			  <tr bgcolor="#FFFFFF"> 
					<td width="12%" height="25" class="thinborder"><div align="center"><strong>COURSE NO.</strong></div></td>
					<td width="38%" class="thinborder"><div align="center"> <strong>DESCRIPTIVE TITLE </strong></div></td>
					<%if(bolShowLecLabHr){%>
					<td width="4%" class="thinborder"><div align="center"><strong>LEC<br>(HRS) </strong></div></td>
					<td width="4%" class="thinborder"><div align="center"><strong>LAB (HRS)</strong></div></td>
					<%}if(bolIsRLEHrs){%>
					<td width="4%" class="thinborder"><div align="center"><strong> RLE (HRS)</strong></div></td>
					<%}%>
					<td width="7%" class="thinborder"><div align="center"> <strong>FINAL<br>GRADES</strong></div></td>
					<td width="7%" class="thinborder"><div align="center"><strong>RE-EXAM</strong></div></td>
					<td width="12%" class="thinborder"><div align="center"><strong>CREDITS<br>EARNED</strong></div></td>
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
						strTemp = (String)vRetResult.elementAt(i + 9 + 11);
				}
				else {
					strTemp = (String)vRetResult.elementAt(i + 9);
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
						//System.out.println(" strCrossEnrolleeSch ; "+strCrossEnrolleeSch);
						strSchNameToDisp = strSchoolName;//added to display cross enrolled school :: 2008-06-23 = added followed by request from AUF to show crossenrolled school name.
					}
				}
				//cross enrolled.. 
				if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//display will be schooo name<br>sy/term (cross enrolled)
					strSYSemToDisp = null;
					strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSYSem+" (CROSS ENROLLED)";
				}
			
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
				<td class="thinborderLEFT" height="20" colspan="<%=iColspan+3%>">  &nbsp;&nbsp;<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
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
				<td class="thinborderLEFTBOTTOM" height="20" colspan="<%=iColspan+3%>">&nbsp; <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
			  </tr>
			<%}%>  
			
			<%if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){
				if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
					++iRowsPrinted;
			//	System.out.println("iRowsPrinted 3:" + iRowsPrinted + "; strSchNameToDisp"+ strSchNameToDisp );		
					//do not keep extra line for school name.%>
			  <tr bgcolor="#FFFFFF"> 
				<td  class="thinborderLEFT" height="20">&nbsp;</td>
				<td class="thinborderLEFT" height="20">&nbsp;<strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strSchNameToDisp.toUpperCase()%></label>
				</strong></td>
				<%if(bolShowLecLabHr){%>
					<td class="thinborderLEFT">&nbsp;</td>
					<td class="thinborderLEFT">&nbsp;</td>
					<%}if(bolIsRLEHrs){%>
					<td class="thinborderLEFT">&nbsp;</td>
					<%}%>
					<td class="thinborderLEFT">&nbsp;</td>
					<td class="thinborderLEFT">&nbsp;</td>
					<td class="thinborderLEFT">&nbsp;</td>
			  </tr>
			  <%strPrevSchName = strSchNameToDisp;
			 } // if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp))))
			
			if(strSYSemToDisp != null){
					if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
					++iRowsPrinted;
			%>
			  <tr bgcolor="#FFFFFF"> 
				<td class="thinborderLEFT" height="17">&nbsp;</td>
				<td class="thinborderLEFT" height="17">&nbsp;<strong><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%if(bolIsCareGiver && vEntranceData.elementAt(27) != null){%><%=((String)vEntranceData.elementAt(27)).toUpperCase()%><%}else{%><%=strSYSemToDisp%><%}%>
				</label>
				</strong></td>
				
				<%if(bolShowLecLabHr){%>
					<td class="thinborderLEFT">&nbsp;</td>
					<td class="thinborderLEFT">&nbsp;</td>
					<%}if(bolIsRLEHrs){%>
					<td class="thinborderLEFT">&nbsp;</td>
					<%}%>
					<td class="thinborderLEFT">&nbsp;</td>
					<td class="thinborderLEFT">&nbsp;</td>
					<td class="thinborderLEFT">&nbsp;</td>
				
			  </tr>
			  <%}
			%>
			  <tr bgcolor="#FFFFFF"> 
				<td class="thinborderLEFT" height="17">&nbsp;&nbsp;<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></label></td>
				<td class="thinborderLEFT" >&nbsp;<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;")%></label>
				<%if(strInternshipInfo != null) {%>
				<br>
					<table width="100%"><tr><td width="3%"></td><td><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strInternshipInfo%></label></td></tr></table>
				<%}%>
				</td>
				<%if(bolShowLecLabHr){
				if(strHideRowLHS.length() == 0) 
					astrLecLabHr = repRegistrar.getOTROfCanLecLabHr(dbOP, false, (String)vRetResult.elementAt(i + 6),(String)vRetResult.elementAt(i + 7),null);%>
				<td class="thinborderLEFT"  width="4%" align="center">&nbsp;
				  <%if(astrLecLabHr != null && iNumWeeks > 0){
				  if (Integer.parseInt(WI.getStrValue(astrLecLabHr[0],"0")) < 30){%>
				  <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=Integer.parseInt(WI.getStrValue(astrLecLabHr[0],"0"))*iNumWeeks%></label>
				  <%}else{%>
				  <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(astrLecLabHr[0],"0")%></label> 
				  <%}}%>
				</td>
				<td class="thinborderLEFT" width="4%" align="center">&nbsp;
				  <%if(astrLecLabHr != null && iNumWeeks > 0){
				  if (Integer.parseInt(WI.getStrValue(astrLecLabHr[1],"0")) < 30){%>
				  <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=Integer.parseInt(WI.getStrValue(astrLecLabHr[1],"0"))*iNumWeeks%></label>
				  <%}else{%>
				  <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(astrLecLabHr[1],"0")%></label>
				  <%}}%>
				</td>
				<%}%>
				<%if(bolIsRLEHrs){%>
				<td class="thinborderLEFT" width="4%"><div align="center"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(strRLEHrs)%></label></div></td>
				<%} 
			if(WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;").compareTo("on going") == 0){%>
				<td class="thinborderLEFT"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')">GNYA</label></div></td>
				<td class="thinborderLEFT">&nbsp;</td>
				<td class="thinborderLEFT">&nbsp;</td>
				<%}else if(WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;").compareToIgnoreCase("IN PROGRESS") == 0){%>
				<td class="thinborderLEFT"><div align="left">&nbsp;&nbsp;<label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')">IN PROGRESS</label></div></td>
				<td class="thinborderLEFT">&nbsp;</td>
				<td class="thinborderLEFT">&nbsp;</td>
				<%}else{%>
				<td width="2%" align="left" class="thinborderLEFT">&nbsp;&nbsp;&nbsp;&nbsp;
				   <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue((String)vRetResult.elementAt(i + 8), "&nbsp;")%></label></td>
				<td width="1%" align="center" class="thinborderLEFT">&nbsp;
			<%
				//it is re-exam if student has INC and cleared in same semester,
				strTemp = null;
				if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && //&& ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 - remove the inc checking..
					((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
					((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
					((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
					WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
						strTemp = (String)vRetResult.elementAt(i + 9 + 11);
						%>
				  <%=WI.getStrValue((String)vRetResult.elementAt(i + 8 + 11),"&nbsp;")%> 
				  <%i += 11;
						//if (strCE.equals("0")) {
						//	strCE = "-";
						//}
					}
				  
			//	  if (strCE.equals("0")) {
			//	  	strCE = "-";
			//	  }
					if(bolIsCareGiver && strCE.length() > 0) 
						strCE = strCE + " hrs";
				  %>
				</td>
				<td width="3%" align="<%if(!bolIsMedTOR && !bolIsCareGiver){%>center<%}else{%>right<%}%>" class="thinborderLEFT">&nbsp;<%=strCE%><%if(bolIsMedTOR || bolIsCareGiver){%>&nbsp;&nbsp;<%}%></td>
				<%}//sho only if grade is not on going.%>
			  </tr>
				<%if(strMulRemarkAtEndOfSYTerm != null){%>	
				  <tr bgcolor="#FFFFFF"> 
					<td class="thinborderLEFT" height="20" colspan="<%=iColspan+3%>"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strMulRemarkAtEndOfSYTerm%></label></td>
				  </tr>
				<%}//prints remarks at end of Sy/Term.%>
			
			
			  <%
			   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
			  <%=strHideRowRHS%> 
			  <%}
			   }//end of for loop
			   
				
				
				
				if (iLastPage == 1){%>
			
			<%  if(vGraduationData != null &&  vGraduationData.size() > 0){
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
				<td class="thinborderLEFTTOP" height="20"  colspan="<%=iColspan+3%>" align="center">&nbsp; <label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
			  </tr>
			<%} iRowsPrinted++; 
			//	System.out.println("iRowsPrinted 5:" + iRowsPrinted );
			// for nothing follows%>
			  <tr>
				<td class="thinborderLEFT" height="20"  colspan="<%=iColspan+3%>" align="center">***** NOTHING FOLLOWS  ******</td>
			  </tr>
			<%if(vGraduationData != null && vGraduationData.elementAt(14) != null) {%>
			  <tr>
				<td class="thinborderLEFT" height="20"  colspan="<%=iColspan+3%>" align="center">GRANTED TRANSFER CREDENTIAL EFFECTIVE <%=WI.formatDate((String)vGraduationData.elementAt(14),6).toUpperCase()%></td>
			  </tr>
			<%}%>
			<%if(WI.fillTextValue("endof_tor_remark").length() > 0 && false) {%>
			  <tr>
				<td class="thinborderLEFT" height="20"  colspan="<%=iColspan+3%>" align="center"><%=WI.fillTextValue("endof_tor_remark")%></td>
			  </tr>
			<%}%>
			<tr><td  colspan="<%=iColspan+3%>" class="thinborder">&nbsp;</td></tr>
			
			
			<% } // if (iLastPage == 1)
				else { // 
			%>
				
				
				
				<tr bgcolor="#FFFFFF"> 
					<td height="15" class="thinborder">&nbsp;</td>
					<td class="thinborder" align="center">*****  more on page <%=iPageNumber + 1%> ******</td>
					<%if(bolShowLecLabHr){%>
					<td class="thinborder">&nbsp;</td>
					<td class="thinborder">&nbsp;</td>
					<%}if(bolIsRLEHrs){%>
					<td class="thinborder">&nbsp;</td>
					<%}%>
					<td class="thinborder">&nbsp;</td>
					<td class="thinborder">&nbsp;</td>
					<td class="thinborder">&nbsp;</td>
			  </tr>
				
				<%}%>
			</table>
			
			
		</td>
	</tr>
</table>

<%}//only if student is having grade infromation.%>
<% if (true ) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"onClick="PrintNextPage();">
	<tr><td height="3">&nbsp;</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderALL" onClick="PrintNextPage();">
  
<!--
  <tr> 
    <td width="4%" height="13" class="fontsize9BOLD">&nbsp;</td>
    <td width="7%">&nbsp;</td>
    <td width="11%">&nbsp;</td>
    <td width="4%">&nbsp;</td>
    <td width="7%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
    <td width="4%">&nbsp;</td>
    <td width="7%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
    <td width="4%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
    <td width="4%">&nbsp;</td>
    <td width="12%">&nbsp;</td>
  </tr>
-->
  <tr>
    <td width="8%" height="15" class="fontsize9BOLD">&nbsp;<u>GRADE</u></td>
    <td width="10%" class="fontsize9BOLD"><u>EQUIVALENT</u></td>
    <td width="12%" class="fontsize9BOLD"><u>DESCRIPTION</u></td>
    <td width="2%" class="fontsize9BOLD">&nbsp;</td>
    <td width="8%" class="fontsize9BOLD"><u>GRADE</u></td>
    <td width="13%" class="fontsize9BOLD"><u>EQUIVALENT</u></td>
    <td width="17%" class="fontsize9BOLD"><u>DESCRIPTION</u></td>
    <td width="30%" class="fontsize9BOLD">&nbsp;</td>
    </tr>
  <tr> 
    <td height="15" class="fontsize9BOLD">&nbsp;&nbsp;&nbsp;1.00</td>
    <td class="fontsize9BOLD">97 - 100%</td>
    <td class="fontsize9BOLD">Excellent</td>
    <td class="fontsize9BOLD">&nbsp;</td>
    <td class="fontsize9BOLD">2.75</td>
    <td class="fontsize9BOLD">76 - 78%</td>
    <td class="fontsize9BOLD">FAIR   </td>
    <td class="fontsize9BOLD">FOR GRADUATE SCHOOL:</td>
    </tr>
  <tr> 
    <td height="15" class="fontsize9BOLD">&nbsp;&nbsp;&nbsp;1.25</td>
    <td class="fontsize9BOLD">94 - 96%</td>
    <td class="fontsize9BOLD">Outstanding </td>
    <td class="fontsize9BOLD">&nbsp;</td>
    <td class="fontsize9BOLD">3.00</td>
    <td class="fontsize9BOLD">75% </td>
    <td class="fontsize9BOLD">PASSING  </td>
    <td rowspan="3" class="fontsize9BOLD" valign="top"><br>below 90 no credit for Ph.D   -  below 85 no credit for M.A</td>
    </tr>

  <tr> 
    <td height="15" class="fontsize9BOLD">&nbsp;&nbsp;&nbsp;1.50</td>
    <td class="fontsize9BOLD">91 - 93%</td>
    <td class="fontsize9BOLD">Very Satisfactory</td>
    <td class="fontsize9BOLD">&nbsp;</td>
    <td class="fontsize9BOLD">5.00</td>
    <td class="fontsize9BOLD">74% and below</td>
    <td class="fontsize9BOLD">FAILURE </td>
    </tr>
  <tr>
    <td class="fontsize9BOLD">&nbsp;&nbsp;&nbsp;1.75</td>
    <td class="fontsize9BOLD">88 - 90%</td>
    <td class="fontsize9BOLD">Good </td>
    <td class="fontsize9BOLD">&nbsp;</td>
    <td class="fontsize9BOLD">INC</td>
    <td class="fontsize9BOLD">&nbsp;</td>
    <td class="fontsize9BOLD">INCOMPLETE</td>
    </tr>
  <tr>
    <td class="fontsize9BOLD">&nbsp;&nbsp;&nbsp;2.00</td>
    <td class="fontsize9BOLD">85 - 87%</td>
    <td class="fontsize9BOLD">Good</td>
    <td class="fontsize9BOLD">&nbsp;</td>
    <td class="fontsize9BOLD">&nbsp;</td>
    <td class="fontsize9BOLD">W</td>
    <td class="fontsize9BOLD">WITHDRAWN</td>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td class="fontsize9BOLD">&nbsp;&nbsp;&nbsp;2.25</td>
    <td class="fontsize9BOLD">82 - 84%</td>
    <td class="fontsize9BOLD">Satisfactory</td>
    <td class="fontsize9BOLD">&nbsp;</td>
    <td class="fontsize9BOLD">&nbsp;</td>
    <td class="fontsize9BOLD">DR</td>
    <td class="fontsize9BOLD">DROPPED</td>
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td class="fontsize9BOLD">&nbsp;&nbsp;&nbsp;2.50</td>
    <td class="fontsize9BOLD">79 - 81%</td>
    <td class="fontsize9BOLD">Satisfactory</td>
    <td class="fontsize9BOLD">&nbsp;</td>
    <td class="fontsize9BOLD">&nbsp;</td>
    <td class="fontsize9BOLD">UD</td>
    <td class="fontsize9BOLD">UN-OFFICIALLY DROPPED </td>
    <td>&nbsp;</td>
    </tr>
  
  <tr> 
    <td height="10" colspan="8" class="fontsize9BOLD">&nbsp;&nbsp;</td>
  </tr>
  <tr valign="top"> 
    <td height="20" colspan="8" class="fontsize9">&nbsp;&nbsp;&nbsp;Note:   Any erasure or alteration on this transcript unless countersigned renders the whole Transcript <strong>NULL</strong> and <strong>VOID</strong></td>
  </tr>
</table>
<%} %>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="6" colspan="3"></td>
  </tr>  
  <tr> 
    <td height="19" colspan="3"> 
		<table width="100%" height="50px" cellpadding="0" cellspacing="0">
			<tr valign="top">
				<td width="8%">REMARKS: </td>
				<td width="92%">
				<b><%=WI.getStrValue(WI.fillTextValue("addl_remark"),"\"","\"","")%></b>
				<%if(iLastPage == 1 && WI.fillTextValue("endof_tor_remark").length() > 0) {%>
					<br><%=WI.fillTextValue("endof_tor_remark")%>
				<%}%>
				</td>
			</tr>
		</table>
	
	</td>
  </tr>
  <tr> 
    <td width="35%" height="18" class="thinborderBOTTOM" align="center"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"Vice President",7)).toUpperCase()%></td>
    <td width="41%" height="18">&nbsp;</td>
    <td width="24%" class="thinborderBOTTOM" align="center"><%=WI.fillTextValue("registrar_name")%></td>
  </tr>
  <tr> 
    <td height="18" align="center">Vice President For Academic Affairs </td>
    <td height="18">&nbsp;</td>
    <td align="center">University Registrar </td>
  </tr>  
  <tr> 
    <td height="20" colspan="3" align="center" style="font-weight:bold; font-size:8px">
	NOT VALID WITHOUT THE UNIVERSITY SEAL<br>
	UNLESS COUNTERSIGNED BY THE<br>
	VICE PRESIDENT</td>
  </tr>
  <tr> 
    <td height="20" colspan="3">&nbsp;</td>
  </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="2">
  <tr> 
    <td height="10" colspan="5" valign="bottom" class="fontsize9">&nbsp;</td>
  </tr>
  <tr> 
    <td width="30%" height="10" valign="bottom"><font>
	Prepared by: <%=WI.getStrValue(WI.fillTextValue("prep_by1"), "<u>","</u>","___________")%></font></td>
    <td width="5%" valign="bottom"><font>&nbsp;</font></td>
    <td width="30%" valign="bottom"><font>
	Checked by: <%=WI.getStrValue(WI.fillTextValue("check_by1"), "<u>","</u>","___________")%></font></td>
    <td width="5%" valign="bottom">&nbsp;</td>
    <td width="30%" valign="bottom"><font>
	Re-checked by: <%=WI.getStrValue(WI.fillTextValue("check_by2"), "<u>","</u>","___________")%></font></td>
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