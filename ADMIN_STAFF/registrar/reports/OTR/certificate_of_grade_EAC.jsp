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
	font-size: 10px;	
	}
	
	TD.thickSE {
		border-bottom: dotted 1px #000000;		
		font-size: 10px;	
	}
	
	TD.thickE {
		border-right: solid 1px #000000;
		font-size: 10px;	
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

	TD.thinborderTopBottom {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

	@media print {
        div.divFooter {
            position: fixed;
            bottom: 20px;
			width: 100%;				
        }
    }
	 
	 H5:after {
		 font-weight:normal;
		 content: "Page " counter(page);
		 counter-increment: page;
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
function HideImg() {
	document.getElementById('hide_img').innerHTML = "";
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = null;
	CommonUtil commExtn = new CommonUtil();

	int iRowStartFr = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_start_fr"), "0"));
	int iRowCount   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_count"), "0"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"), "0"));

//////////////////////////

	int iPageNumber = 0;
	
	String strTotalPageNumber = WI.fillTextValue("total_page");

	String strImgFileExt = null;
	String strRootPath  = null;

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

String strMRMS = "";
String strHeShe = "";
String strHimHer = "";
Vector vStudInfo = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;

Vector vMulRemark = null;
int iMulRemarkIndex = -1;

boolean bolNewPage = false;
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

String strStudCourseToDisp = null; String strStudMajorToDisp = null;
String strCourseIndex = null;//this is the course selected. If no course is selected, I get from student info.. 
String strMajorIndex  = null;

String strPrintPerSY = WI.fillTextValue("print_per_school_year_from");
String strPrintPerSYSem = WI.fillTextValue("print_per_school_year_semester");

String strSYFrom = null;
String strSYTo   = null;
String strSemester = null;



int iMaxCourseDisplay = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_course_disp"),"0"));
String[] strTok = null; Vector vCourseSelected = new Vector(); 

String strExtraCon = " and (";

double dGWA = 0d;

for (int k = 0; k < iMaxCourseDisplay; k++){
	if (WI.fillTextValue("checkbox"+k).length() == 0 )
		continue;
	
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

if (strExtraCon.length() < 10){
	strExtraCon = null;
}

//System.out.println(strExtraCon);



enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
student.GWA gwa = new student.GWA();


///this is needed if there is a option to include or not include the Transferee information.
if(!WI.fillTextValue("tf_sel_list").equals("-1")) {
	if(WI.fillTextValue("tf_sel_list").length() == 0) 
		repRegistrar.strTFList = "0";
	else	
		repRegistrar.strTFList = WI.fillTextValue("tf_sel_list");
	
}

if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		strTemp = WI.getStrValue(vStudInfo.elementAt(16),"M");
		if(strTemp.toLowerCase().equals("m")){
			strMRMS = "Mr.";
			strHeShe = "He";
			strHimHer = "Him";
		}else{
			strMRMS = "Ms.";
			strHeShe = "She";
			strHimHer = "Her";
		}
	
		//student.StudentInfo studInfo = new student.StudentInfo();
		//vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
		//	(String)vStudInfo.elementAt(12));
		//if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
		//	strErrMsg = studInfo.getErrMsg();
	}
} 

//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
	
	/**** added code**/
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
		strTemp = "select course_name, major_name,course_offered.course_code, major.course_code,course_offered.course_index, stud_curriculum_hist.major_index "+
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
			strMajorIndex  = rs.getString(6);
		}

	}
	if(strStudCourseToDisp == null) {
		strStudCourseToDisp = (String)vStudInfo.elementAt(7);
		strStudMajorToDisp  = (String)vStudInfo.elementAt(8);
		strCourseIndex      = (String)vStudInfo.elementAt(5);
		strMajorIndex  		= (String)vStudInfo.elementAt(6);
	}
	
	
	
	/** end of added code **/
	enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
	//vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);
	//added code.
	request.setAttribute("course_ref", strCourseIndex);


	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), 
													strDegreeType, true, strExtraCon);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else{	
		vMulRemark = (Vector)vRetResult.remove(0);

		
		dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));
	}
		
}

//System.out.println(vRetResult);
String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);


//System.out.println(vMulRemark);
int iMulRemarkCount  = 0;// 

//get excluded subject list
Vector vExcludeList = repRegistrar.operateOnExcludedSubjectTOR(dbOP, request, 4);
if(vExcludeList == null)
	vExcludeList = new Vector();

%>

<body topmargin="5">



<%



if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td align="center">
			<%=SchoolInformation.getSchoolName(dbOP, false, false)%><br>
			<%=SchoolInformation.getAddressLine1(dbOP, false, false)%><br><br>
			OFFICE OF THE REGISTRAR<br><br>
		</td>
	</tr>
	<tr><td  align="right"><%=WI.getTodaysDate(1)%></td></tr>
	<tr><td height="35px;" align="center">CERTIFICATION</td></tr>
	<tr><td height="18px;" valign="bottom">TO WHOM IT MAY CONCERN:</td></tr>
	<tr>
		<td style="text-indent:50px; text-align:justify;" height="40px" valign="bottom">
	This is to certify that on the basis of records on file in our office.
<%=strMRMS.toUpperCase()%> <%=WI.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),7).toUpperCase()%> is a student of <%=SchoolInformation.getSchoolName(dbOP, false, false)%>
of <%=WI.getStrValue((String)vStudInfo.elementAt(7)).toUpperCase()%> and <%=strHeShe.toLowerCase()%> obtained the grades in the term(s)
indicated below:
</td>
	</tr>
	<tr><td height="30px;">&nbsp;</td></tr>
</table>
<%
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

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);
int iRevalidaIndex = -1;
String strCE ="";
boolean bolRowSpan2  = false; boolean bolInComment = false;
String strExtraTD = "";


//for Math / english enrichment - i have to put parenthesis.
boolean bolPutParanthesis  = false;
Vector vMathEnglEnrichment = new enrollment.GradeSystem().getMathEngEnrichmentInfo(dbOP, request);
int iIndexOf = 0;
String strSubCode = null;

//added on March 14, 2013. this fixes the probelm when student takes only one subject in sy-term.
boolean bolAddEmptyRow = false;// set to false if a row is added below sy-term.



float fTotalUnits = 0;
int iMaxLineCount = 35;
int iLineCount = 0;

int iTotalRowCount  = 35;
int iNumberRowCount = 0;
int iTitleRowCount  = 0;
int iCharPerLine  = 48;
int iTemp = 0;
boolean bolPageBreak = false;

for(int i = 0 ; i < vRetResult.size(); i += 11){
	bolPutParanthesis = false;
	strSubCode = (String)vRetResult.elementAt(i + 6);
	if(strSubCode == null)
		strSubCode = "";
		
	if(strSubCode.startsWith("NSTP") && (iIndexOf = strSubCode.indexOf("(")) > -1)
		strSubCode = strSubCode.substring(0, iIndexOf);

	iIndexOf = vMathEnglEnrichment.indexOf(strSubCode);
	if(vMathEnglEnrichment != null && iIndexOf > -1) {
		try {
			double dGrade = Double.parseDouble((String)vRetResult.elementAt(i + 8));
			//System.out.println(dGrade);
			bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
			if(dGrade <= 3d) {//pass
				dGrade = Double.parseDouble(WI.getStrValue((String)vMathEnglEnrichment.elementAt(iIndexOf + 1), "0"));
				dGrade += Double.parseDouble(WI.getStrValue((String)vMathEnglEnrichment.elementAt(iIndexOf + 2), "0"));
				vRetResult.setElementAt("("+Double.toString(dGrade)+")",i + 9);
			}
			else 
				vRetResult.setElementAt("(0.0)",i + 9);
			
		}
		catch(Exception e){vRetResult.setElementAt("(0.0)",i + 9);}
	}



	if(vRetResult.elementAt(i + 6) != null && vExcludeList.indexOf(vRetResult.elementAt(i + 6)) > -1) {
		vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);
		vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);
		vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);
		
		i = i - 11;		
	}
}

for(int i = 0 ; i < vRetResult.size();){
iLineCount = 0;
iNumberRowCount = 0;
if(i > 0)
	iMaxLineCount = 40;
	
	if(bolPageBreak){
		bolPageBreak = false;
%>
	<div style="page-break-after:always;">&nbsp;</div>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#E2E2E2">
  <tr bgcolor="#FFFFFF"> 
    <td valign="bottom" width="11%" height="25" class="thickSE"><div align="center"><strong>Term</strong></div></td>
    <td valign="bottom" width="15%" class="thickSE"><div align="center"><strong>Subject<br>Code</strong> </div></td>
    <td valign="bottom" class="thickSE"><div align="center"><strong>Subject<br>Description</strong></div></td>
    <td valign="bottom" width="8%" class="thickSE"><div align="center"><strong>Final<br>Grade</strong></div></td>
    <td valign="bottom" width="8%" class="thickSE"><div align="center"><strong>Comp.<br>Grade</strong></div></td>
    <td valign="bottom" width="8%" class="thickSE"><div align="center"><strong>Units</strong></div></td>
  </tr>
<%

for(; i < vRetResult.size(); i += 11, ++iCurrentRow){
	

//System.out.println("i: "+Integer.toString(i)+" -- "+vRetResult.elementAt(i + 6));
//	strExtraTD = null;
  if( (i + 12) < vRetResult.size())//revalida.. 
	if ((String)vRetResult.elementAt(i + 6) != null && 
		((String)vRetResult.elementAt(i + 6)).toUpperCase().indexOf("REVALIDA") != -1) {
		iRevalidaIndex = i;
		continue;
	}
	
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6 + 11) != null && vRetResult.elementAt(i + 6 + 11) != null && 
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

	if(strTemp != null && strTemp.indexOf("hrs") > 0 && strTemp.indexOf("(") > 0) {
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
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+" <br>"+
					(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
		strSemester = (String)vRetResult.elementAt(i+ 3);
		if (i+11 < vRetResult.size())	
		{
			if(((String)vRetResult.elementAt(i+ 14)) != null && ((String)vRetResult.elementAt(i+ 14)).length() > 1) {
		 		strNextSem = (String)vRetResult.elementAt(i+ 14)+" <br>"+(String)vRetResult.elementAt(i+ 12)+" - "+
							(String)vRetResult.elementAt(i+ 13);
			}
			else
		 		strNextSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 14))]+" <br>"+
							(String)vRetResult.elementAt(i+ 12)+" - "+(String)vRetResult.elementAt(i+ 13);
		}
		else
			strNextSem = null;
	}
	else {
		strCurSYSem = (String)vRetResult.elementAt(i+ 3)+" <br>"+(String)vRetResult.elementAt(i+ 1)+" - "+
							(String)vRetResult.elementAt(i+ 2);
		strSemester = null;					
		if (i+11 < vRetResult.size())	
		{
		 strNextSem = (String)vRetResult.elementAt(i+ 14)+" <br>"+(String)vRetResult.elementAt(i+ 12)+" - "+
							(String)vRetResult.elementAt(i+ 13);
		}
		else
			strNextSem = null;
	}
	
	strSYFrom = (String)vRetResult.elementAt(i + 1);
	strSYTo = (String)vRetResult.elementAt(i + 2);
	
	if(strPrintPerSY.length() > 0){
		if(!strSYFrom.equals(strPrintPerSY))
			continue;
			
		if(strPrintPerSYSem.length() > 0){
			if(strSemester != null && !strSemester.equals(strPrintPerSYSem))
				continue;
			strPrintPerSYSem = strSemester;
		}
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

iTitleRowCount = commExtn.getLineCount((String)vRetResult.elementAt(i + 7), iCharPerLine);
//sub code sometimes makes 2 lines, I have to compare
iTemp = commExtn.getLineCount(WI.getStrValue(vRetResult.elementAt(i + 6)), 12);

if(iTemp > iTitleRowCount)
	iTitleRowCount = iTemp;
	
iNumberRowCount+=iTitleRowCount;

if(strSchNameToDisp != null)
	++iNumberRowCount;
	
	

/*
if(++iLineCount >= iMaxLineCount){
		bolPageBreak = true;
		break;
}
*/
if(iNumberRowCount >= iMaxLineCount){
	bolPageBreak = true;
	break;
}



if(strSchNameToDisp != null){
	
	if(strExtraTD.length() == 0) {//can't insert another full row%>
	  <tr bgcolor="#FFFFFF">
    	<td valign="top" class="">&nbsp;</td>
    	<td valign="top" class="">&nbsp;</td>
    	<td valign="top" class="">&nbsp;</td>
    	<td valign="top" class="">&nbsp;</td>
    	<td valign="top" class="">&nbsp;</td>
    	<td valign="top" >&nbsp;</td>
  	</tr>
	<%strExtraTD = "<td valign=\"top\" class=\"thickE\">&nbsp;</td>";}
	
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" align="center">
				<strong><font size="3"><%=strSchNameToDisp.toUpperCase()%></font></strong></td>
	</tr>
<%strSchNameToDisp = null;}

if (bolNewEntry && bolNextNew) {
%>
  <tr bgcolor="#FFFFFF"> 
    <td width="11%" height="18" valign="top" class=""><div align="center"><%=WI.getStrValue(strSYSemToDisp).toUpperCase()%></div></td>
    <td width="15%" valign="top" class="">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"").toUpperCase()%></td>
    <td valign="top" class=""><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"").toUpperCase()%>&nbsp;</td>
    <td width="8%" valign="top" class=""><div align="center"><%=CommonUtil.formatFloat(WI.getStrValue(vRetResult.elementAt(i + 8),"0"), true)%></div></td>
	
    <td width="8%" valign="top" class="">
<%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
		%> 
		<div align="center"><%=(String)vRetResult.elementAt(i + 8 + 11)%></div> <%i += 11;}%>&nbsp;	</td>
		<%
		try {
		fTotalUnits += Float.parseFloat(WI.getStrValue(strCE,"0"));
		}catch(Exception e){}
		%>
    <td width="8%" valign="top" ><div align="center"> <%=strCE%></div></td>
  </tr>
 
  <% if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){bolInComment = false;%>
 
  <%  }else bolRowSpan2 = false;%>
  <%}else if (bolNewEntry && !bolNextNew){

    if(bolAddEmptyRow) {%>
	  <tr bgcolor="#FFFFFF">     
    	<td valign="top" class="">&nbsp;</td>
	    <td valign="top" class="">&nbsp;</td>
    	<td valign="top" class="">&nbsp;</td>
	    <td valign="top" class="">&nbsp;</td>
    	<td valign="top" >&nbsp;</td>
	  </tr>
	<%}%>

  <tr bgcolor="#FFFFFF"> 
    <td height="36" 
	<%strExtraTD = "";
	if(true) {
	//i have to add condition to check if there are more subjects in the same sy-term. If only one subject in sy-term, row span should not be 2 	
	 if ((iRowEndsAt - iCurrentRow) > 1 && !bolInComment || true) {//condition below added '2012-09-12'
	 	strExtraTD = "";
		//System.out.println(vRetResult.elementAt(i + 6));
		//System.out.println(vRetResult.elementAt(i + 17));
		//System.out.println(vRetResult.elementAt(i + 1));
		//System.out.println(vRetResult.elementAt(i + 12));
		//System.out.println(vRetResult.elementAt(i + 3));
		//System.out.println(vRetResult.elementAt(i + 14));
	%>  
		rowspan="2" 
	<%}else{
		strExtraTD = "<td valign=\"top\" class=\"thickE\">aaaa</td>";
	  }
	}
	//System.out.println(vRetResult.elementAt(i + 6)+" : "+strSYSemToDisp);
	bolAddEmptyRow = true;%>
	valign="top" class="" width="11%"><div align="center"><%=strSYSemToDisp.toUpperCase()%></div></td>
    <td width="15%" valign="top" class="">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"").toUpperCase()%></td>
    <td valign="top" class=""><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"").toUpperCase()%>&nbsp;</td>
    <td width="8%" valign="top" class=""><div align="center"><%=CommonUtil.formatFloat(WI.getStrValue(vRetResult.elementAt(i + 8),"0"), true)%></div></td>
    <td width="8%" valign="top" class="">
<%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
		%> 
		<div align="center"><%=(String)vRetResult.elementAt(i + 8 + 11)%></div>	 <%i += 11;}%>&nbsp;	</td>
    <td width="8%" valign="top" ><div align="center"> 
        <% strTemp = WI.getStrValue(vRetResult.elementAt(i + 9));
		//System.out.println(strTemp);
			if (strTemp.indexOf("(") > 0) 
				strTemp = strTemp.substring(0,strTemp.indexOf("(")-1);
		
		
		try {
		fTotalUnits += Float.parseFloat(WI.getStrValue(strTemp,"0"));
		}catch(Exception e){}
		%>
        <%=strTemp%>
      </div></td>
  </tr>
  <%if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  
  <%}else{ bolRowSpan2 = true;}%>
<%} else if (!bolNewEntry && bolNewPrev && !bolNewPage){ bolAddEmptyRow = false;%>
  <tr bgcolor="#FFFFFF">   
    <%=strExtraTD%>
    <td width="15%" valign="top" class="">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"").toUpperCase()%></td>
    <td valign="top" class=""><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"").toUpperCase()%>&nbsp;</td>
    <td width="8%" valign="top" class=""><div align="center"><%=CommonUtil.formatFloat(WI.getStrValue(vRetResult.elementAt(i + 8),"0"), true)%></div></td>
    <td width="8%" valign="top" class="">
<%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
		%> 
		<div align="center"><%=(String)vRetResult.elementAt(i + 8 + 11)%></div>	 <%i += 11;}%>&nbsp;	</td>
		<%
		try {
		fTotalUnits += Float.parseFloat(WI.getStrValue(strCE,"0"));
		}catch(Exception e){}
		%>
    <td width="8%" valign="top" ><div align="center"> <%=strCE%></div></td>
  </tr>
 <%
  	if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){
%>
  
<%}else bolRowSpan2 = false;%>
<%} else if ((!bolNewEntry && !bolNewPrev) || (!bolNewEntry && bolNewPrev && bolNewPage)){
  
  %>
  <tr bgcolor="#FFFFFF"> 
    <td height="18" width="11%" class="">&nbsp;</td>
    <td width="15%" valign="top" class="">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"").toUpperCase()%></td>
    <td valign="top" class=""><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"").toUpperCase()%>&nbsp;</td>
    <td width="8%" valign="top" class=""><div align="center"><%=CommonUtil.formatFloat(WI.getStrValue(vRetResult.elementAt(i + 8),"0"), true)%></div></td>
    <td width="8%" valign="top" class="">
<%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).equals((String)vRetResult.elementAt(i + 6 + 11)) && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).equals((String)vRetResult.elementAt(i + 1 + 11)) && //sy_from
		((String)vRetResult.elementAt(i + 2)).equals((String)vRetResult.elementAt(i + 2 + 11)) && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").equals(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1"))) { //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
		%> 
		<div align="center"><%=(String)vRetResult.elementAt(i + 8 + 11)%></div> <%i += 11;}%>&nbsp;	</td>
		<%
		try {
		fTotalUnits += Float.parseFloat(WI.getStrValue(strCE,"0"));
		}catch(Exception e){}
		%>
    <td width="8%" valign="top"><div align="center"> <%=strCE%></div></td>
  </tr>
<%if( (i + 12) > vRetResult.size() && iRevalidaIndex > -1){
strTemp = WI.getStrValue(vRetResult.elementAt(iRevalidaIndex + 9));
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="18" width="11%" class="">&nbsp;</td>
    <td width="15%" valign="top" class="">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(iRevalidaIndex + 6),"").toUpperCase()%></td>
    <td valign="top" class=""><%=WI.getStrValue((String)vRetResult.elementAt(iRevalidaIndex + 7),"").toUpperCase()%>&nbsp;</td>
    <td width="8%" valign="top" class=""><div align="center"><%=CommonUtil.formatFloat(WI.getStrValue(vRetResult.elementAt(iRevalidaIndex + 8),"0"), true)%></div></td>
    <td width="8%" valign="top" class=""></td>
	<%
		try {
		fTotalUnits += Float.parseFloat(WI.getStrValue(strTemp,"0"));
		}catch(Exception e){}
		%>
    <td width="8%" valign="top"><div align="center"> <%=strTemp%></div></td>
  </tr>

<%}%>

  <% if (bolNewPage && iCurrentRow == iRowStartFr)
  		bolNewPage = false;
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
 
  <%} else  bolRowSpan2 = false;
  //if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt) %>
  <%}//if ((!bolNewEntry && !bolNewPrev) || (!bolNewEntry && bolNewPrev && bolNewPage))%>
 
<%}//end inner Loop%>  


</table>

<%
if(i < vRetResult.size()){
%>
<div style="text-align:center; border-top:dotted 1px #000000;">next page. please</div>  
<%}else{%>
<div style="text-align:center; border-top:dashed 1px #000000;">ENTRY BELOW NOT VALID</div>
<%}%>




  <%}//end of for loop%>
  
<table cellpadding="0" cellspacing="0" width="100%" border="0">  
	<tr>
		<td valign="bottom" height="30px;" style="padding-left:50px;">
			Total Units : <%=fTotalUnits%><br>
			<%
			if(strPrintPerSY.length() > 0){
				if(strPrintPerSYSem.length() == 0)
					strPrintPerSYSem = "0,1,2";
					
				strTemp = Integer.toString(Integer.parseInt(strPrintPerSY)+1);
					
				dGWA = gwa.getGWAForAStud(dbOP,(String)vStudInfo.elementAt(12), strPrintPerSY, strTemp, "", strCourseIndex, strMajorIndex, strPrintPerSYSem);
			}
			%>
			G.W.A : <%=CommonUtil.formatFloat(dGWA, 2)%> [E.A.C]
		</td>
	</tr>
  <tr><td style="text-indent:50px;text-align:justify;" height="40px" colspan="2" valign="bottom">
  	This cerfication is issued upon the request of <%=strMRMS.toUpperCase()%> <%=WI.getStrValue((String)vStudInfo.elementAt(2)).toUpperCase()%> 
	for whatever purpose it may lawfully serve <%=strHimHer.toLowerCase()%>.
  </td></tr>
  <tr>
  	<td style="text-indent:50px;text-align:justify;" width="60%" valign="bottom">School Seal</td>
	<td width="40%" height="60" valign="bottom" align="center">
		<div align="center">
		<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7))%><br>
        Registrar
	</div>
	</td>
  </tr>
  
</table>

<div class="divFooter">
	<div style="margin-top:1%; float:left; width:45%;">&nbsp;</div>	
	<div style="float:left; width:10%; text-align:center;"><H5></H5></div>
	<div style="margin-top:1%; float:left; width:45%;">&nbsp;</div>
</div>  
  
<%}//only if student is having grade infromation.%>












<%//System.out.println(WI.fillTextValue("print_"));
if(WI.fillTextValue("print_").compareTo("1") == 0){%>
<script language="javascript">
 window.print();
</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
