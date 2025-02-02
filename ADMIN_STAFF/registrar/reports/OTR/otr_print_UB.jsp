<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>UB OFFICIAL TRANSCRIPT OF RECORD</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--

@media print { 
  @page {
		margin-bottom:.1in;
		margin-top:.1in;
		margin-right:.1in;
		margin-left:.1in;
	}
}

body {
	font-family: "Courier New", Courier, monospace;
	font-size: 14px;
}

td {
	font-family: "Courier New", Courier, monospace;
	font-size: 14px;
}

th {
	font-family: "Courier New", Courier, monospace;
	font-size: 14px;
}

.fontsize9 {
	font-family: "Courier New", Courier, monospace;	
	font-size: 8px;
}

.fontsize14{
	font-family: "Courier New", Courier, monospace;
	font-size: 14px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }	
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;
    }
    .thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;
    }

    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }
    TD.thinborderRIGHTBOTTOM {
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }
	
	TD.thinborderTOPRIGHTBOTTOM {
	border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }
	
	TD.thinborderTOPLEFTBOTTOM {
	border-top: solid 2px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }
	
	TD.thinborderTOPLEFT{
	border-top: solid 2px #000000;
    border-left: solid 1px #000000;    
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }
	
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }
	
	TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
    }
	
    TD.thinborderLEFTRIGHTBOTTOM {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Courier New", Courier, monospace;	
	font-size: 14px;	
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
			}
			else document.oncontextmenu = disableRightClick;		
			return document.rightClickDisabled = true;	
		}	
		if(document.layers || (document.getElementById && !document.all)){
			if (e.which==2||e.which==3){
				alert(message);
				return false;
			}
		}
		else{
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
	int iTemp = 0;
	String strSQLQuery     = null;
	String strReligion 	   = null;
	String strSpouse 	   = null;
	java.sql.ResultSet rs  = null;
	String strCollegeName = null;//I have to find the college offering course.
	int iIndexOf = 0;
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
	
/*	if(false && WI.fillTextValue("print_all_pages").equals("1")) { //print all page called.
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

	}*/

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-OTR","otr_print.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
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
//CommonUtilExtn comUtilExtn = new CommonUtilExtn(request);
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
boolean bolIsPrinting = true;
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

String strUserIndex = null;
String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};

String[] astrConvertSemUG  = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};
String[] astrConvertSemMED = {"SUMMER","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR"};
String[] astrConvertSemMAS = {"Summer","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER",""};

enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();
//enrollment.ReportRegistrarExtn RPExtn = new enrollment.ReportRegistrarExtn();


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
	if(vStudInfo == null || vStudInfo.size() ==0){
		strErrMsg = offlineAdm.getErrMsg();
		bolIsPrinting = false;
	}
	else {
		strUserIndex = (String)vStudInfo.elementAt(12);
	
		//to prevent if the user click back button of the browser/backspace.. the print button is still in the page.		
		/*if(!RPExtn.isAllowOTRPrinting(dbOP, request, (String)vStudInfo.elementAt(12), false)){
			strErrMsg = WI.getStrValue(RPExtn.getErrMsg(),"Student OTR is not open for printing.");
			dbOP.cleanUP();
		%><%=strErrMsg%><%return;}*/
	
		strCollegeName = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(5));
		if(strCollegeName != null)
			strCollegeName = strCollegeName.toUpperCase();
			
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
			(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0){
			strErrMsg = studInfo.getErrMsg();
			
		}
			
		strReligion = "select religion,spouse_name from info_personal where user_index = "+(String)vStudInfo.elementAt(12);
		rs = dbOP.executeQuery(strReligion);
		if(rs.next()){
			strReligion = rs.getString(1);
			strSpouse = rs.getString(2);
		}rs.close();
		
	}
}
/*if(vStudInfo != null && vStudInfo.size() > 0) {
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
}*/

//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);

if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);

	if(vCourseSelected.size() > 0) {
		strTemp = "select degree_type from course_offered where course_index in ("+CommonUtil.convertVectorToCSV(vCourseSelected)+")";
		//System.out.println("strTemp "+strTemp);
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
	if(vEntranceData == null){
		strErrMsg = entranceGradData.getErrMsg();
		
	}
	//System.out.println("strDegreeType "+strDegreeType);
	//System.out.println("strExtraCon "+strExtraCon);
	//strDegreeType = "5";
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true, strExtraCon);
	
	
	//System.out.println(vRetResult);
	if(vRetResult == null){
		strErrMsg = repRegistrar.getErrMsg();
		bolIsPrinting = false;
	}else	
		vMulRemark = (Vector)vRetResult.remove(0);
		
	Vector vTemp = new Vector();
	Vector vSYTermList = new Vector();
	if(vRetResult != null && vRetResult.size() > 0){
		for(int i = 0; i < vRetResult.size(); i+=11){
			strErrMsg = WI.getStrValue(vRetResult.elementAt(i + 7),"N/A");	
			if(vRetResult.elementAt(i+ 3) != null) {
				if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) 
					strTemp = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+" "+
								(String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);		
				else 
					strTemp = (String)vRetResult.elementAt(i+ 3)+" "+(String)vRetResult.elementAt(i+ 1)+"-"+
										(String)vRetResult.elementAt(i+ 2);
			}	
			
			iIndexOf = vSYTermList.indexOf(strTemp+" "+strErrMsg);
			if(iIndexOf > -1)
				continue;
			vSYTermList.addElement(strTemp+" "+strErrMsg);
			
			vTemp.addElement(vRetResult.elementAt(i));
			vTemp.addElement(vRetResult.elementAt(i+1));
			vTemp.addElement(vRetResult.elementAt(i+2));
			vTemp.addElement(vRetResult.elementAt(i+3));
			vTemp.addElement(vRetResult.elementAt(i+4));
			vTemp.addElement(vRetResult.elementAt(i+5));
			vTemp.addElement(vRetResult.elementAt(i+6));
			vTemp.addElement(vRetResult.elementAt(i+7));
			vTemp.addElement(vRetResult.elementAt(i+8));
			vTemp.addElement(vRetResult.elementAt(i+9));
			vTemp.addElement(vRetResult.elementAt(i+10));
			
			
			if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && 
				((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
				WI.getStrValue((String)vRetResult.elementAt(i + 1)).compareTo(WI.getStrValue(vRetResult.elementAt(i + 1 + 11))) == 0 && //sy_from
				WI.getStrValue((String)vRetResult.elementAt(i + 2)).compareTo(WI.getStrValue(vRetResult.elementAt(i + 2 + 11))) == 0 && //sy_to
				WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester							
				i += 11;				
				vTemp.addElement(vRetResult.elementAt(i));
				vTemp.addElement(vRetResult.elementAt(i+1));
				vTemp.addElement(vRetResult.elementAt(i+2));
				vTemp.addElement(vRetResult.elementAt(i+3));
				vTemp.addElement(vRetResult.elementAt(i+4));
				vTemp.addElement(vRetResult.elementAt(i+5));
				vTemp.addElement(vRetResult.elementAt(i+6));
				vTemp.addElement(vRetResult.elementAt(i+7));
				vTemp.addElement(vRetResult.elementAt(i+8));
				vTemp.addElement(vRetResult.elementAt(i+9));
				vTemp.addElement(vRetResult.elementAt(i+10));
			  }
		}
	}
	
	//if(vTemp != null && vTemp.size() > 0)
	//	vRetResult = vTemp;
	
	//for(int i = 0; i < vSYTermList.size(); i++)
	//	System.out.println("vSYTermList "+vSYTermList.elementAt(i));
		
	//System.out.println(vRetResult);
}
int iMulRemarkCount  = 0;// 

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
	
//System.out.println(vStudInfo);
//System.out.println(vMulRemark);


//get internship ifno.. 
Vector vInternshipInfo = repRegistrar.getInternshipInfo();
//System.out.println(vInternshipInfo);


String strMulRemarkAtEndOfSYTerm = null;//if there is any remark added after the end of SY/term of Student.. 

//check if caregiver.. 
if(strStudCourseToDisp != null && strStudCourseToDisp.toLowerCase().equals("caregiver course"))
	bolIsCareGiver = true;

Vector vMathEnglEnrichment = new enrollment.GradeSystem().getMathEngEnrichmentInfo(dbOP, request);
if(vMathEnglEnrichment == null)
	vMathEnglEnrichment = new Vector();


iPageNumber = 0;
/*if(bolIsPrinting && strPrintPage.equals("1")){	
	if(!RPExtn.isAllowOTRPrinting(dbOP, request, (String)vStudInfo.elementAt(12), true)){
		strErrMsg = RPExtn.getErrMsg();
		bolIsPrinting = false;
	}
}*/
	
if(strErrMsg != null && !bolIsPrinting){dbOP.cleanUP();%>
<div style="text-align:center; color:#FF0000; font-weight:bold;"><%=strErrMsg%></div>
<%return;}
	
%>

<body topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0">
<form action="./otr_print_UB.jsp" method="post" name="form_">

<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="2" align="center"><strong><font style="font-size:20px;" face="Courier New, Courier, monospace">UNIVERSITY OF BOHOL<br>City of Tagbilaran<br>OFFICE OF THE REGISTRAR</font>	
	</strong></td></tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr>
		<td width="70%"><strong>Official Transcript of Records</strong></td>
		<td><%=WI.getTodaysDate(6)%></td>
	</tr>
</table>


<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="2" colspan="2"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
	<tr><td height="2" valign="bottom" colspan="2"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
	
	<tr><td width="70%">&nbsp;</td><td>
	<%=((String)vStudInfo.elementAt(24)).toUpperCase()%>
	<%=WI.getStrValue((String)vStudInfo.elementAt(25)," Major in ","","").toUpperCase()%></td></tr>
</table>

<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="17%" valign="top" height="23">NAME</td>
		<td width="1%" valign="top">:</td>
	    <td width="52%" valign="top">		 
		<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%>		</td>
	</tr>
	<tr><td height="23" valign="top">STUDENT #</td><td valign="top">:</td>	
		<td valign="top"> <%=WI.fillTextValue("stud_id").toUpperCase()%></td>
		<td valign="top" rowspan="11" width="30%">
			<img src="../../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt%>" width="170" height="190" border="1" align="top">	  </td>
	</tr>
	<tr><td height="23" valign="top">ADDRESS</td><td valign="top">:</td>
	    <td valign="top">
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3)).toUpperCase()%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","").toUpperCase()%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","").toUpperCase()%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(7)," ","","").toUpperCase()%>		</td>
	</tr>
	<TR><TD valign="top" height="23">CITIZENSHIP</TD><TD valign="top">:</TD>
	    <TD valign="top"> <%=WI.getStrValue(WI.getStrValue((String)vStudInfo.elementAt(23)).toUpperCase(), "&nbsp;")%></TD>
	</TR>
	
			
	<tr><td  valign="top" height="23">CIVIL STATUS</td><td  valign="top">:</td>
	    <td valign="top"> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(12)).toUpperCase()%></td>
	</tr>
	<%
	strTemp = (String)vStudInfo.elementAt(16);
	if(strTemp.equals("M"))
		strTemp = "MALE";
	else
		strTemp = "FEMALE";
	%>
	<tr><td valign="top" height="23">GENDER</td><td valign="top">:</td>
	    <td valign="top"> <%=strTemp.toUpperCase()%></td>
	</tr>
	<%
		if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
			strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1));
		}else{
			strTemp = "&nbsp;";
		}
	%>
    
	<tr><td valign="top" height="23">DATE OF BIRTH</td><td valign="top">:</td>
	    <td valign="top"> <%=strTemp.toUpperCase()%></td>
	</tr>
	<%
		strTemp = "&nbsp;";
		if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
			strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2));
		
	%>
      
	<tr><td valign="top" height="23">PLACE OF BIRTH</td><td valign="top">:</td>
	    <td valign="top"> <%=strTemp.toUpperCase()%></td>
	</tr>
	<tr><td valign="top" height="23">RELIGION</td><td valign="top">:</td>
	    <td valign="top"> <%=WI.getStrValue(strReligion).toUpperCase()%></td>
	</tr>
	<tr><td valign="top" height="23">FATHER</td><td valign="top">:</td>
	    <td valign="top"> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(8)).toUpperCase()%></td>
	</tr>
	<tr><td valign="top" height="23">MOTHER</td><td valign="top">: </td>
	    <td valign="top"><%=WI.getStrValue((String)vAdditionalInfo.elementAt(9)).toUpperCase()%></td>
	</tr>
	<tr><td valign="top" height="23">SPOUSE</td><td valign="top">:</td>
	    <td valign="top"> <%=WI.getStrValue(strSpouse).toUpperCase()%></td>
	</tr>	
	<tr><td colspan="4"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td></tr>
</table>

<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="3" height="15"></td></tr>
	<tr>
		<td width="30%" height="20"><strong>Preliminary Education</strong></td>
		<td height="20"><strong>Name of School</strong></td>
		<td height="20" width="20%"><strong>SY Graduated</strong></td>
	</tr>
	<tr>
		<td height="23">Elementary :</td>
		<%
			if(vEntranceData != null)
				strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
			else	
				strTemp = "&nbsp;"; 
		%>	
	
		<td><%=strTemp%></td>
		<%
		strTemp = WI.getStrValue(vEntranceData.elementAt(19));
		if(strTemp.length() > 0)
			strTemp += WI.getStrValue((String)vEntranceData.elementAt(20)," - ","","");
		else
			strTemp = WI.getStrValue((String)vEntranceData.elementAt(20));
		%>
		<td align="center"><%=strTemp%></td>
	</tr>
	<tr>
		<td height="23">High School :</td>
		<td><%=(String)vEntranceData.elementAt(5)%></td>
		<%
		strTemp = WI.getStrValue(vEntranceData.elementAt(21));
		if(strTemp.length() > 0)
			strTemp += WI.getStrValue((String)vEntranceData.elementAt(22)," - ","","");
		else
			strTemp = WI.getStrValue((String)vEntranceData.elementAt(22));
		%>
		<td align="center"><%=strTemp%></td>
	</tr>
	<tr><td colspan="3" height="10"></td></tr>
	<tr><td height="1" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td></tr>	
</table>

<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="6" height="15">&nbsp;</td></tr>
	<tr><td colspan="6" height="18" align="center"><strong>GRADING SYSTEM</strong></td></tr>
	<tr>
		<td valign="bottom" height="25" align="center"><strong>GRADING</strong></td>
		<td width="20%" valign="bottom"><strong>EQUIVALENT</strong></td>
		<td valign="bottom" height="25" align="center"><strong>GRADING</strong></td>
		<td width="20%" valign="bottom"><strong>EQUIVALENT</strong></td>
		<td valign="bottom" height="25" align="center"><strong>GRADING</strong></td>
		<td width="20%" valign="bottom"><strong>EQUIVALENT</strong></td>
	</tr>
	
	<tr>
		<td height="23" align="center">1.0</td>
		<td width="20%">100%</td>
		<td align="center">2.0</td>
		<td width="20%">87-88%</td>
		<td align="center">3.0</td>
		<td width="20%">75%</td>
	</tr>
	<tr>
		<td height="23" align="center">1.1</td>
		<td width="20%">99%</td>
		<td align="center">2.1</td>
		<td width="20%">85-86%</td>
		<td align="center">5.0</td>
		<td width="20%">74% and Below</td>
	</tr>
	<tr>
		<td height="23" align="center">1.2</td>
		<td width="20%">98%</td>
		<td align="center">2.2</td>
		<td width="20%">83-84%</td>
		<td align="center">W</td>
		<td width="20%">Withdrawn</td>
	</tr>
	<tr>
		<td height="23" align="center">1.3</td>
		<td width="20%">97%</td>
		<td align="center">2.3</td>
		<td width="20%">82%</td>
		<td align="center">NG</td>
		<td width="20%">No Grade</td>
	</tr>
	<tr>
		<td height="23" align="center">1.4</td>
		<td width="20%">96%</td>
		<td align="center">2.4</td>
		<td width="20%">81%</td>
		<td align="center">DR</td>
		<td width="20%">Dropped</td>
	</tr>
	<tr>
		<td height="23" align="center">1.5</td>
		<td width="20%">95%</td>
		<td align="center">2.5</td>
		<td width="20%">80%</td>
		<td colspan="2" align="center">&nbsp;</td>
	</tr>
	<tr>
		<td height="23" align="center">1.6</td>
		<td width="20%">94%</td>
		<td align="center">2.6</td>
		<td width="20%">79%</td>
		<td colspan="2" align="center">&nbsp;</td>
	</tr>
	<tr>
		<td height="23" align="center">1.7</td>
		<td width="20%">93%</td>
		<td align="center">2.7</td>
		<td width="20%">78%</td>
		<td colspan="2" align="center">&nbsp;</td>
	</tr>
	<tr>
		<td height="23" align="center">1.8</td>
		<td width="20%">91-92%</td>
		<td align="center">2.8</td>
		<td width="20%">77%</td>
		<td colspan="2" align="center">&nbsp;</td>
	</tr>
	<tr>
		<td height="23" align="center">1.9</td>
		<td width="20%">89-90%</td>
		<td align="center">2.9</td>
		<td width="20%">76%</td>
		<td colspan="2" align="center">&nbsp;</td>
	</tr>
</table>


<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="7" class="thinborderBottom">&nbsp;</td></tr>
	<tr><td width="13%" height="25" valign="top">REMARKS :</td>
	    <td height="25" colspan="2" valign="top"> <strong><%=WI.fillTextValue("addl_remark")%></strong></td>
	    </tr>
	<tr>
		<td colspan="2">
			<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">				
				<tr><td height="50">NOT VALID<br>WITHOUT SEAL</td></tr>
				<tr><td height="30" width="25%">PREPARED BY :</td><td><%=WI.fillTextValue("prep_by1").toUpperCase()%></td></tr>
				<tr><td height="30">CHECKED BY :</td><td><%=WI.fillTextValue("check_by1").toUpperCase()%></td></tr>
			</table>		</td>
		<td width="37%"><table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr><td align="center" height="20"><strong><%=WI.fillTextValue("registrar_name")%></strong></td></tr>
			<tr>
			    <Td align="center" valign="top"><strong>Registrar</strong></Td>
			</tr>
		</table></td>
	</tr>
	<tr><td colspan="3" align="center">Page <%=++iPageNumber%> of <label id="page_no_<%=iPageNumber%>"></label></td></tr>
</table>
<div style="page-break-after:always">&nbsp;</div>



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
String strGraduatedOnRemarks = null;

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
String strSubCode    = null;

if(WI.fillTextValue("addl_remark").length() > 0 && iLastPage == 1){

	iTemp = 1;
	strTemp = WI.fillTextValue("addl_remark");
	iIndexOf = 0;

	while((iIndexOf = strTemp.indexOf("<br>",iIndexOf + 1)) != -1)
		++iTemp;

	 iMaxRowToDisp = iMaxRowToDisp - iTemp; 
}
//System.out.println(vRetResult);

if(vInternshipInfo == null)
	vInternshipInfo = new Vector();
	
boolean bolPageBreak = false;
int iTitleLength    = 0;
int iTotalRowCount  = 37;
int iNumberRowCount = 0;
int iTitleRowCount  = 0;
int iCharPerLine  = 43;

String strCourseCode = null;
String strMajorCode  = null;
boolean bolIsAssociate = false;

strTemp = " select count(*) from enrl_final_cur_list where is_valid =1  "+
		" and sy_from =  ? "+
		" and current_semester = ? "+
		" and IS_TEMP_STUD = 0  "+
		" and exists( "+
		"	select * from stud_curriculum_hist where is_valid =1 "+
		"	and user_index = enrl_final_cur_list.user_index  "+
		"	and semester = current_semester "+
		"	and sy_from = enrl_final_cur_list.sy_from "+
		" ) "+
		" and IS_CONFIRMED = 1 and user_index =  "+strUserIndex;
java.sql.PreparedStatement pstmtEnrlCount = dbOP.getPreparedStatement(strTemp);
		
		
for(int i = 0 ; i < vRetResult.size(); ){
	iNumberRowCount = 0;
	if(bolPageBreak){bolPageBreak = false;%>
			<div style="page-break-after:always;">&nbsp;</div>
<%}%>

<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="2" align="center"><strong><font style="font-size:20px;" face="Courier New, Courier, monospace">UNIVERSITY OF BOHOL<br>City of Tagbilaran<br>OFFICE OF THE REGISTRAR</font>	
	</strong></td></tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr>
		<td width="70%"><strong>Official Transcript of Records</strong></td>
		<td><%=WI.getTodaysDate(6)%></td>
	</tr>
</table>
<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="23" style="text-indent:30px;"><strong>
		<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td></tr>
	<tr><td height="23" style="text-indent:30px;">
	<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3)).toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","").toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","").toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(7)).toUpperCase()%>
	</td></tr>
</table>
<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr>
		<td width="30%" height="20"><strong>Preliminary Education</strong></td>
		<td height="20"><strong>Name of School</strong></td>
		<td height="20" width="20%"><strong>SY Graduated</strong></td>
	</tr>
	<tr>
		<td height="23">Elementary :</td>
		<%
			if(vEntranceData != null)
				strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
			else	
				strTemp = "&nbsp;"; 
		%>	
	
		<td><%=strTemp%></td>
		<%
		strTemp = WI.getStrValue(vEntranceData.elementAt(19));
		if(strTemp.length() > 0)
			strTemp += WI.getStrValue((String)vEntranceData.elementAt(20)," - ","","");
		else
			strTemp = WI.getStrValue((String)vEntranceData.elementAt(20));
		%>
		<td align="center"><%=strTemp%></td>
	</tr>
	<tr>
		<td height="23">High School :</td>
		<td><%=(String)vEntranceData.elementAt(5)%></td>
		<%
		strTemp = WI.getStrValue(vEntranceData.elementAt(21));
		if(strTemp.length() > 0)
			strTemp += WI.getStrValue((String)vEntranceData.elementAt(22)," - ","","");
		else
			strTemp = WI.getStrValue((String)vEntranceData.elementAt(22));
		%>
		<td align="center"><%=strTemp%></td>
	</tr>	
	<tr><td height="5" valign="middle" colspan="3"><div style="border-bottom: solid 1px #000000;"></div></td></tr>
</table>


<table onMouseDown="return false" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100%" height="570px" valign="top">
			<table onMouseDown="return false" width="100%" border="0" cellpadding="0" cellspacing="0">			
				
				<tr>
					<td height="25" width="20%" align="center" class="thinborderTOPBOTTOM"><strong>COURSE NO</strong></td>
					<td align="center" class="thinborderTOPBOTTOM"><strong>DESCRIPTIVE TITLE</strong></td>
					<td width="10%" align="center" class="thinborderTOPBOTTOM"><strong>GRADE</strong></td>
					<td width="10%" align="center" class="thinborderTOPBOTTOM"><strong>RE-EXAM</strong></td>
					<td width="10%" align="center" class="thinborderTOPBOTTOM"><strong>CREDITS</strong></td>					
				</tr>
			


<%

for(; i < vRetResult.size(); i += 11, ++iCurrentRow){

		//check here NSTP(CWTS) must be converted to NSTP only.. 
		strSubCode = WI.getStrValue((String)vRetResult.elementAt(i + 6));
		int iIndexOf22 = 0;
		if(strSubCode.startsWith("NSTP") && (iIndexOf22 = strSubCode.indexOf("(")) > -1)
			strSubCode = strSubCode.substring(0, iIndexOf22);
		iIndexOf22 = vMathEnglEnrichment.indexOf(strSubCode);
		if(iIndexOf22 > -1) {
			try {
				double dGrade = Double.parseDouble((String)vRetResult.elementAt(i + 8));
				double dCE = Double.parseDouble((String)vMathEnglEnrichment.elementAt(iIndexOf22 + 1)) +
				Double.parseDouble((String)vMathEnglEnrichment.elementAt(iIndexOf22 + 2));
				
				if(dGrade <= 3d) {
					vRetResult.setElementAt("("+dCE+")",i + 9);
				}
				else 
					vRetResult.setElementAt("(0.0)",i + 9);
				
				//vRetResult.setElementAt("("+dGrade+")",i + 8);
			}
			catch(Exception e){
				vRetResult.setElementAt("(0.0)",i + 9);
			}
		}

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
			//strGrade = (String)vRetResult.elementAt(i + 8 + 11); 
	}
	else {
		strTemp  = (String)vRetResult.elementAt(i + 9);		
	}
	
	strGrade = (String)vRetResult.elementAt(i + 8);
	
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
/*	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//display will be schooo name<br>sy/term (cross enrolled)
		strSYToDisp = null;
		strSemToDisp = null;		
		strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSY+" "+strCurSem+" (CROSS ENROLLED)";
	}*/
	
	
if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//cross enrolled.
	//check if this is cross enrolled. 
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
		strSQLQuery = "select gs_index from g_sheet_final join stud_curriculum_hist "+
		" on (stud_curriculum_hist.cur_hist_index = g_sheet_final.cur_hist_index) "+
		" where sy_from = "+vRetResult.elementAt(i+ 1)+" and semester = "+vRetResult.elementAt(i+ 3)+" and g_sheet_final.is_valid = 1 and "+
		" ce_sch_index is not null";
		if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null) {				
			if(strCrossEnrolleeSchPrev == null || strCrossEnrolleeSchPrev.compareTo(strSchoolName) != 0)  {
				strCrossEnrolleeSchPrev = strSchoolName;
				strCrossEnrolleeSch     = strSchoolName; 
				strSYSemToDisp = strCurSYSem;
				//System.out.println(" strCrossEnrolleeSch ; "+strCrossEnrolleeSch);
				strSchNameToDisp = strSchoolName;//added to display cross enrolled school :: 2008-06-23 = added followed by request from AUF to show crossenrolled school name.
			}
			
			//display will be schooo name<br>sy/term (cross enrolled)
			/*strSYSemToDisp = null;
			strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSYSem+" (CROSS ENROLLED)";*/
			
			pstmtEnrlCount.setString(1, (String)vRetResult.elementAt(i+ 1));
			pstmtEnrlCount.setString(2, (String)vRetResult.elementAt(i+ 3));
			rs = pstmtEnrlCount.executeQuery();
			rs.next();
			if(rs.getInt(1) > 0)
				strTemp = "CROSS ENROLLED";				
			else
				strTemp = "PERMIT TO STUDY";
			rs.close();
			
			strSYToDisp = null;
			strSemToDisp = null;		
			strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSY+" "+strCurSem+" ("+strTemp+")";
		}
	}
}
	
	
	

 //Very important here, it print <!-- if it is not to be shown.
// if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){
// 	strHideRowLHS = "<!--"; //I have to do this so i will know if I am priting data or not%>
  <%//=strHideRowLHS%> 
  <%//}else {
//  	++iRowsPrinted;
//	strHideRowLHS = "";
////	System.out.println("iRowsPrinted 1:" + iRowsPrinted );
//	}//actual number of rows printed. 


//check internship Info.. 
strInternshipInfo = null;

if(vInternshipInfo.size() > 0) {
	iTemp = ((Integer)vInternshipInfo.elementAt(0)).intValue();
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


//iTitleLength = WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;").length();		
iTitleRowCount = comUtil.getLineCount((String)vRetResult.elementAt(i + 7), iCharPerLine);
//sub code sometimes makes 2 lines, I have to compare
iTemp = comUtil.getLineCount(WI.getStrValue(vRetResult.elementAt(i + 6)), 14);

if(iTemp > iTitleRowCount)
	iTitleRowCount = iTemp;
	
iNumberRowCount+=iTitleRowCount;

if( strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp))))
	++iNumberRowCount;
	
if( strSYToDisp != null && strSemToDisp != null )
	++iNumberRowCount;
	
if(vMulRemark != null && vMulRemark.size() > 0){
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		iTitleRowCount = comUtil.getLineCount(ConversionTable.replaceString((String)vMulRemark.elementAt(1),"\n","<br>"), 80);
		iNumberRowCount+=iTitleRowCount;
	}
}

if (i + 11 >= vRetResult.size() ){
	if(vGraduationData != null &&  vGraduationData.size() > 0){	
		strCourseCode = (String)vStudInfo.elementAt(24);
		strMajorCode  = null;
		bolIsAssociate = false;
		if(vStudInfo.size() > 25)
			strMajorCode = (String)vStudInfo.elementAt(25);
		else if(vStudInfo.elementAt(8) != null) {
			strMajorCode = "select course_code from major where course_index="+vStudInfo.elementAt(5)+" and major_index="+vStudInfo.elementAt(6)+" and is_del=0";
			strMajorCode = dbOP.getResultOfAQuery(strMajorCode,0);		
		}
		
		if( ((String)vStudInfo.elementAt(7)).toLowerCase().indexOf("associate") > -1 )
			bolIsAssociate = true;
		iTemp = 1;
		if(bolIsCareGiver)
			strGraduatedOnRemarks = "GRADUATED WITH THE SIX-MONTH CARE GIVER";
		else{
			if(!bolIsAssociate)
				strGraduatedOnRemarks = "ON "+WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase() +
					" FROM THE DEGREE OF "+((String)vStudInfo.elementAt(7)).toUpperCase();		
			else{		
	//			strTemp = ((String)vStudInfo.elementAt(2)).toUpperCase() +", "+ 
	//				WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase() + " " +
	//				WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase();
				strGraduatedOnRemarks = "Completed all "+
					" the requirements leading to the title of "+((String)vStudInfo.elementAt(7)).toUpperCase()+
					" on "+WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
			}
	//		strTemp = "Graduated with the degree of " +((String)vStudInfo.elementAt(7)).toUpperCase();			
		} 
		
		if(strMajorCode != null) {
			strGraduatedOnRemarks += " MAJOR IN "+((String)vStudInfo.elementAt(8)).toUpperCase();
			strCourseCode = strCourseCode + " "+strMajorCode;
		}
	
		if(!bolIsAssociate)
			strGraduatedOnRemarks += WI.getStrValue(strCourseCode," (",")","");
	
	//	if ((String)vGraduationData.elementAt(8) != null)
	//		strTemp += " on " +WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase()+".";
	
	
		if(vGraduationData.elementAt(6) != null){
			strGraduatedOnRemarks += " PER SPECIAL ORDER "+WI.getStrValue(vGraduationData.elementAt(6))+
				" DATED "+WI.formatDate((String)vGraduationData.elementAt(7),6).toUpperCase();
	//		strTemp += " Exempted from the issuance of Special Order by virtue of the AUTONOMOUS STATUS granted by the "+
	//			"COMMISSION ON HIGHER EDUCATION (CHED) Resolution No. "+WI.getStrValue(vGraduationData.elementAt(6))+".";	
		}else{
			strGraduatedOnRemarks += " EXEMPTED FROM SPECIAL ORDER.";
		}
		
		iTitleRowCount = comUtil.getLineCount(strGraduatedOnRemarks, 80);
		iNumberRowCount+=iTitleRowCount;
	}	
}


if(iNumberRowCount >= iTotalRowCount){
	bolPageBreak = true;
	if(strSYToDisp != null && strSemToDisp != null){
		strPrevSY = null;
		strPrevSem = null;
	}
	break;
}
	
	
	


if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		iMulRemarkCount += 3;%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="5" align="center"> <%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></td>
  </tr>
  <%}//end of if
}//end of vMulRemark.



if( strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
	++iRowsPrinted;
%>
<tr bgcolor="#FFFFFF">
     <td colspan="5"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><i><strong><%=WI.getStrValue(strSchNameToDisp)%></strong></i></label>	</td>
</tr>



<%
strPrevSchName = strSchNameToDisp;}
if( strSYToDisp != null && strSemToDisp != null ){
	if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
	++iRowsPrinted;


if(bolIsCareGiver && vEntranceData.elementAt(27) != null)
	strTemp = strSemToDisp +" "+ ((String)vEntranceData.elementAt(27)).toUpperCase();		
else
	strTemp = strSemToDisp +" "+ strSYToDisp;		
%>	
  
  <tr bgcolor="#FFFFFF">  	    	
  	<td colspan="5"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><i><strong><%=strTemp%></strong></i></label>	</td>
  </tr>
  
<%}




strGrade = WI.getStrValue(strGrade);

if(strGrade.equals("on going")) {
	strGrade = "&nbsp;";
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
	strCE = strCE + "hrs";
if(strCE.length() > 0 && strCE.indexOf(".") == -1 && strCE.indexOf("(") == -1)
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
	<td valign="top" height="14" style="padding-left:10px;"><%=WI.getStrValue(vRetResult.elementAt(i + 6))%></td>  
	<td valign="top"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(WI.getStrValue(vRetResult.elementAt(i + 7)),"&nbsp;")%> </label></td>
	<td valign="top" align="center"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strGrade%></label></td>
	<td valign="top" align="center"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=WI.getStrValue(strTemp)%></label></td>
	<td valign="top" align="center" width="10%"><%=strCE%></td>
</tr>



<%
if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		iMulRemarkCount += 3;%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" class="thinborderALL" align="center"><%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></td>
  </tr>
  <%}//end of if
}//end of vMulRemark.


%>

  <%
   //if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%//=strHideRowRHS%> 
  <%//}
   }//end of for loop
   %>
   
   
<% if (i + 11 > vRetResult.size() ){

if(vMulRemark != null && vMulRemark.size() > 0){%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" class="thinborderALL" align="center"> <%=ConversionTable.replaceString((String)vMulRemark.remove(1),"\n","<br>")%></td>
  </tr>
<%}

if(WI.fillTextValue("endof_tor_remark").length() > 0) {
%>  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" class="thinborderALL" align="center"><%=WI.fillTextValue("endof_tor_remark")%></td>
  </tr>
  <%
}//end of vMulRemark.
%>
		<tr>
					<%/*if(vGraduationData != null &&  vGraduationData.size() > 0){	
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
						iTemp = 1;
						if(bolIsCareGiver)
							strTemp = "GRADUATED WITH THE SIX-MONTH CARE GIVER";
						else{
							if(!bolIsAssociate)
								strTemp = "ON "+WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase() +
									" FROM THE DEGREE OF "+((String)vStudInfo.elementAt(7)).toUpperCase();		
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
							strCourseCode = strCourseCode + " "+strMajorCode;
						 }
						
						 if(!bolIsAssociate)
						 	strTemp += WI.getStrValue(strCourseCode," (",")","");
						
						 //if ((String)vGraduationData.elementAt(8) != null)
						//	strTemp += " on " +WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase()+".";
						
						 
							 if(vGraduationData.elementAt(6) != null){
								strTemp += " PER SPECIAL ORDER "+WI.getStrValue(vGraduationData.elementAt(6))+
									" DATED "+WI.formatDate((String)vGraduationData.elementAt(7),6).toUpperCase();
									//strTemp += " Exempted from the issuance of Special Order by virtue of the AUTONOMOUS STATUS granted by the "+
								//"COMMISSION ON HIGHER EDUCATION (CHED) Resolution No. "+WI.getStrValue(vGraduationData.elementAt(6))+".";	
							 }else{
								strTemp += " EXEMPTED FROM SPECIAL ORDER.";
							 }		
							 			
//						if (strTemp.length()/100 > 0) {
//							iTemp = strTemp.length()/100;
//							if (strTemp.length()%100 > 0)
//								iTemp +=1;
//						}
//						 iRowsPrinted += iTemp;*/ 
					%>  									
						<td colspan="5" class="">
							<table onMouseDown="return false" width="100%">
								<tr>
								<%
								strTemp = "";
								if(strGraduatedOnRemarks != null && strGraduatedOnRemarks.length() > 0)
									strTemp = "GRADUATED :";
								%>
									<td valign="top" width="15%"><strong>&nbsp;<%if(!bolIsAssociate && !bolIsCareGiver){%><%=strTemp%><%}%></strong></td>
									<td valign="top" align="justify"><%=WI.getStrValue(strGraduatedOnRemarks).toUpperCase()%></td>
								</tr>
							</table>						</td>
						<%//}%>  	
		</tr>			
					
		<tr><td height="18" colspan="5" align="center"><strong>--- End of Transcript --- </strong></td></tr>	
<%}%>
		</table>
			<!-- Table inside td. -->
	
		</td>
	</tr>	
</table>








<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="7" height="20" class="thinborderBottom">&nbsp;</td></tr>
	<tr><td width="13%" height="25" valign="top">REMARKS :</td>
	    <td height="25" colspan="2" valign="top"> <strong><%=WI.fillTextValue("addl_remark")%></strong></td>
	    </tr>
	<tr>
		<td colspan="2">
			<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">				
				<tr><td height="50">NOT VALID<br>WITHOUT SEAL</td></tr>
				<tr><td height="30" width="25%">PREPARED BY :</td><td><%=WI.fillTextValue("prep_by1").toUpperCase()%></td></tr>
				<tr><td height="30">CHECKED BY :</td><td><%=WI.fillTextValue("check_by1").toUpperCase()%></td></tr>
			</table>		</td>
		<td width="37%"><table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr><td align="center" height="20"><strong><%=WI.fillTextValue("registrar_name")%></strong></td></tr>
			<tr>
			    <Td align="center" valign="top"><strong>Registrar</strong></Td>
			</tr>
		</table></td>
	</tr>
	<tr><td colspan="3" align="center">Page <%=++iPageNumber%> of <label id="page_no_<%=iPageNumber%>"></label></td></tr>
</table>





<%}//end of outer loop%>


<%}//only if student is having grade infromation.%>



<%//System.out.println(WI.fillTextValue("print_"));
if(strPrintPage.compareTo("1") == 0){

/*strSQLQuery = "select prop_val from read_Property_file where proP_name = 'TOR_PMT_REQUIRED'";
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(WI.getStrValue(strSQLQuery).equals("1")) {
	//may be unhold already.. get current sy-term.. 
	//strSQLQuery = "select EXCEPTION_INDEX,is_locked from OTR_PRINT_EXCEPTION where is_valid = 1 and valid_until >='"+WI.getTodaysDate()+"' and user_index = "+strUserIndex;
	strSQLQuery = "select EXCEPTION_INDEX,is_locked from OTR_PRINT_EXCEPTION where is_valid = 1 and valid_until >='"+WI.getTodaysDate()+
			"' and user_index = "+strUserIndex+" order by is_locked ";
	rs = dbOP.executeQuery(strSQLQuery);
	String strExceptionIndex = null;
	if(rs.next()) {
		strExceptionIndex = rs.getString(1);
		if(rs.getInt(2) == 0)
			strSQLQuery = "update OTR_PRINT_EXCEPTION set is_locked = 1, OTR_PRINT_BY="+(String)request.getSession(false).getAttribute("userIndex")+
				",OTR_PRINT_DATE='"+WI.getTodaysDate()+"' where exception_index = "+strExceptionIndex;
		else	
			strSQLQuery = null;
	}rs.close();
	if(strExceptionIndex != null && strSQLQuery != null) 		
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	
}*/


strSQLQuery = "select EXCEPTION_INDEX from OTR_PRINT_EXCEPTION where is_valid = 1 and valid_until >='"+WI.getTodaysDate()+
	"' and PRINTED_BY_ is null and user_index = "+strUserIndex;
rs = dbOP.executeQuery(strSQLQuery);
String strExceptionIndex = null;
if(rs.next())
	strExceptionIndex = rs.getString(1);
rs.close();

if(strExceptionIndex != null) {
	strSQLQuery = "update OTR_PRINT_EXCEPTION set PRINTED_BY_ = "+(String)request.getSession(false).getAttribute("userIndex")+
	", PRINTED_DATE='"+WI.getTodaysDate()+"' where EXCEPTION_INDEX = "+strExceptionIndex; 
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
}

%>
<script language="javascript">
 window.print(); 
</script>
<%}%>

<script>

<%
for(int i =1; i <=iPageNumber; ++i ){
%>
document.getElementById('page_no_<%=i%>').innerHTML = <%=iPageNumber%>;
<%}%>

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