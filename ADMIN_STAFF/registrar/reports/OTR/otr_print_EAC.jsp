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
		border-bottom: solid 1px #000000;
		border-right: solid 1px #000000;
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

	int iRowStartFr = Integer.parseInt(WI.fillTextValue("row_start_fr"));
	int iRowCount   = Integer.parseInt(WI.fillTextValue("row_count"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.fillTextValue("last_page"));


////////////////////////// to insert blank lines if TOR is not complete page.
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.fillTextValue("max_page_to_disp"));
//////////////////////////

	int iPageNumber = Integer.parseInt(WI.fillTextValue("page_number"));
	
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
int iMaxCourseDisplay = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_course_disp"),"0"));
String[] strTok = null; Vector vCourseSelected = new Vector(); 

String strExtraCon = " and (";

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
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
			(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
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
	
	
	
	/** end of added code **/
	enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
	vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);
	//added code.
	request.setAttribute("course_ref", strCourseIndex);
	
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	if(vEntranceData == null || vGraduationData == null)
		strErrMsg = entranceGradData.getErrMsg();


	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), 
													strDegreeType, true, strExtraCon);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);
		
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

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td colspan="2"> <div align="center">
      <font size="2"><strong><font size="3" face="Arial Black, Arial, Verdana"><br>
      </font></strong></font><br>
          <br>
          <br>
		  <br><br><br>
      </div></td>
    <td width="20%" rowspan="3" valign="bottom" >
<%if(iPageNumber == 1){
		strTemp = WI.fillTextValue("stud_id");
		
//		System.out.println(strTemp);
		
		if (strTemp.length() > 0) {
			java.io.File file = new java.io.File(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt); 
		
			if(file.exists()) {
				strTemp = "../../../../upload_img/"+strTemp+"."+strImgFileExt;
				strTemp = "<img src=\""+strTemp+"\" width=125 height=125>"; 
			}
			else {
				strTemp = "&nbsp;";
			}
		}
%>
	<label id='hide_img' onClick='HideImg()'><%=strTemp%></label>
<%}%>

	</td>
  </tr>
  <tr> 
    <td height="18" colspan="2" align="right">&nbsp;</td>
  </tr>
  <tr>
    <td width="52%" height="18">NAME: <strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
    <td width="28%">DATE: <%=WI.formatDate(WI.fillTextValue("date_prepared"),6).toUpperCase()%></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="52%" height="20">ADDRESS: <%=WI.fillTextValue("address").toUpperCase()%> </td>
    <td width="48%">
<%
	if(vEntranceData != null)
		strTemp = WI.getStrValue((String)vEntranceData.elementAt(23),"");
	else
		strTemp = "";
%>
DATE OF ADMISSION: <%=strTemp.toUpperCase()%> </td>
  </tr>
  <tr>
    <td height="20">DATE OF BIRTH:
      <%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
		strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1));
	}else{
		strTemp = "";
	}
%>
	<%=strTemp.toUpperCase()%></td>

<%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
		strTemp = dbOP.mapOneToOther("course_offered join college on " + 
									 "(course_offered.c_index = college.c_Index)",
									 "course_name", "'" + (String)vStudInfo.elementAt(7) +"'",
									 "c_name", " and course_offered.is_del = 0" +
									 " and college.is_del= 0");
		if (strTemp == null) 
			strTemp ="";
	}else{
		strTemp = "";
	}
%>
    <td><%=strTemp.toUpperCase()%></td>
  </tr>
  <tr>
    <td height="20">PLACE OF BIRTH:
      <%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
		strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2));
	}else{
		strTemp = "";
	}
%>	
	<%=strTemp.toUpperCase()%></td>
    <td>DATE OF GRADUATION: 
<%
	if(vGraduationData != null)
		strTemp = (String)vGraduationData.elementAt(8);
	else
		strTemp = "xxxxxxxxxxx";
%>
    <%=WI.getStrValue(WI.formatDate(strTemp,6),"xxxxxxxxxxx").toUpperCase()%></td>
  </tr>
  <tr>
    <td height="20">ELEMENTARY SCHOOL:
      <%
	if(vEntranceData != null)
		strTemp = WI.getStrValue(vEntranceData.elementAt(14),WI.getStrValue(vEntranceData.elementAt(3)));
	else
		strTemp = "";
%>
    <%=strTemp.toUpperCase()%></td>
    <td>DEGREE: <strong>
	<%
	if(vGraduationData == null || vGraduationData.elementAt(8) == null) 
		strTemp = "xxxxxxxxxxx";
	else {	
		strTemp = (String)vStudInfo.elementAt(7);
		if(vStudInfo.elementAt(8) != null)
			strTemp += " Major in "+ (String)vStudInfo.elementAt(8);
	}
%>
	
	<%=strTemp.toUpperCase()%></strong></td>
  </tr>
  <tr>
    <td height="20">SECONDARY SCHOOL: 
      <%
if(vEntranceData != null)
	strTemp = WI.getStrValue((String)vEntranceData.elementAt(5));
else
	strTemp = "";
%>
	<%=strTemp.toUpperCase()%>
	</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="20">DATE OF GRADUATION:
      <%
	if(vEntranceData != null)
		strTemp = WI.getStrValue((String)vEntranceData.elementAt(22),"");
	else
		strTemp = "";
	
%>
    <%=strTemp.toUpperCase()%> </td>
<%
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
    <td>GWA: <%=strTemp%></td>
  </tr>
</table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="1" cellpadding="2" cellspacing="0" bordercolor="#000000" bgcolor="#FFFFFF">
<tr>
	<td>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#E2E2E2" class="enclosed">
  <tr bgcolor="#FFFFFF"> 
    <td width="11%" height="25" class="thickSE"><div align="center"><font size="1"><strong>TERM</strong></font></div></td>
    <td width="15%" class="thickSE"><div align="center"><font size="1"><strong>NAME OF COURSE</strong> </font></div></td>
    <td width="46%" class="thickSE"><div align="center"><font size="1"><strong>D E S C R I P T I O N</strong></font></div></td>
    <td width="10%" class="thickSE"><div align="center"><strong><font size="1">FINAL GRADES</font></strong></div></td>
    <td width="6%" class="thickSE"><div align="center"><strong><font size="1">RE-<br>
    EXAMS  </font></strong></div></td>
    <td width="12%" class="thickSE"><div align="center"><strong><font size="1">CREDITS EARNED </font></strong></div></td>
  </tr>
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

for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
//System.out.println("i: "+Integer.toString(i)+" -- "+vRetResult.elementAt(i + 6));
//	strExtraTD = null;
  if( (i + 12) < vRetResult.size())//revalida.. 
	if ((String)vRetResult.elementAt(i + 6) != null && 
		((String)vRetResult.elementAt(i + 6)).toUpperCase().indexOf("REVALIDA") != -1) {
		iRevalidaIndex = i;
		continue;
	}
	
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6 ) != null && vRetResult.elementAt(i + 6 + 11) != null && 
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
							
		if (i+11 < vRetResult.size())	
		{
		 strNextSem = (String)vRetResult.elementAt(i+ 14)+" <br>"+(String)vRetResult.elementAt(i+ 12)+" - "+
							(String)vRetResult.elementAt(i+ 13);
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
 
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){bolInComment = true;
 %>
  <%=strHideRowLHS%> 
  <%}else {bolInComment = false;
  ++iRowsPrinted;}//actual number of rows printed. 
//if(vMulRemark.size() > 3)
//	vMulRemark.setElementAt(new Integer(649),2);
if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		iMulRemarkCount += 3;%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" class="thinborderALL" align="center"> <%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></td>
  </tr>
  <%}//end of if
}//end of vMulRemark.
	
	//System.out.println(vMulRemark);

if(strSchNameToDisp != null){
	if (i==0)
		strTemp ="class=\"thinborderBottom\""; 
	else
		strTemp ="class=\"thinborderTopBottom\""; 
	
	if(strExtraTD.length() == 0) {//can't insert another full row%>
	  <tr bgcolor="#FFFFFF">
    	<td valign="top" class="thickE">&nbsp;</td>
    	<td valign="top" class="thickE">&nbsp;</td>
    	<td valign="top" class="thickE">&nbsp;</td>
    	<td valign="top" class="thickE">&nbsp;</td>
    	<td valign="top" class="thickE">&nbsp;</td>
    	<td valign="top" >&nbsp;</td>
  	</tr>
	<%strExtraTD = "<td valign=\"top\" class=\"thickE\">&nbsp;</td>";}
	
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" <%=strTemp%> align="center">
				<strong><font size="3"><%=strSchNameToDisp.toUpperCase()%></font></strong></td>
	</tr>
<%
if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		iMulRemarkCount += 3;%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" class="thinborderALL" align="center"> <%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></td>
  </tr>
  <%}//end of if
}//end of vMulRemark.

if(vEntranceData.elementAt(12) != null){%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" class="thinborderBottom">
				<%=vEntranceData.elementAt(12)%></td>
	</tr>
<%vEntranceData.setElementAt(null, 12);}%>

  <%strSchNameToDisp = null;
  ++iRowsPrinted;
 }

if (bolNewEntry && bolNextNew) {
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="18" valign="top" class="thickE"><div align="center"><%=WI.getStrValue(strSYSemToDisp).toUpperCase()%></div></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"").toUpperCase()%></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"").toUpperCase()%></td>
    <td width="10%" valign="top" class="thickE"><div align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "")%></div></td>
	
    <td width="6%" valign="top" class="thickE">
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
    <td width="12%" valign="top" ><div align="center"> <%=strCE%></div></td>
  </tr>
 
  <% if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){bolInComment = false;%>
  <%=strHideRowRHS%> 
  <%  }else bolRowSpan2 = false;%>
  <%}else if (bolNewEntry && !bolNextNew){

    if(bolAddEmptyRow) {%>
	  <tr bgcolor="#FFFFFF">     
    	<td valign="top" class="thickE">&nbsp;</td>
	    <td valign="top" class="thickE">&nbsp;</td>
    	<td valign="top" class="thickE">&nbsp;</td>
	    <td valign="top" class="thickE">&nbsp;</td>
    	<td valign="top" >&nbsp;</td>
	  </tr>
	<%}%>

  <tr bgcolor="#FFFFFF"> 
    <td height="36" 
	<%strExtraTD = "";
	if(true) {
	//i have to add condition to check if there are more subjects in the same sy-term. If only one subject in sy-term, row span should not be 2 	
	 if ((iRowEndsAt - iCurrentRow) > 1 && !bolInComment) {//condition below added '2012-09-12'
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
		strExtraTD = "<td valign=\"top\" class=\"thickE\">&nbsp;</td>";
	  }
	}
	//System.out.println(vRetResult.elementAt(i + 6)+" : "+strSYSemToDisp);
	bolAddEmptyRow = true;%>
	valign="top" class="thickE"><div align="center"><%=strSYSemToDisp.toUpperCase()%></div></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"").toUpperCase()%></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"").toUpperCase()%></td>
    <td valign="top" class="thickE"><div align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "")%></div></td>
    <td width="6%" valign="top" class="thickE">
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
    <td width="12%" valign="top" ><div align="center"> 
        <% strTemp = WI.getStrValue(vRetResult.elementAt(i + 9));
		//System.out.println(strTemp);
			if (strTemp.indexOf("(") > 0) 
				strTemp = strTemp.substring(0,strTemp.indexOf("(")-1);
		
		%>
        <%=strTemp%>
      </div></td>
  </tr>
  <%if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}else{ bolRowSpan2 = true;}%>
<%} else if (!bolNewEntry && bolNewPrev && !bolNewPage){ bolAddEmptyRow = false;%>
  <tr bgcolor="#FFFFFF"> 
    <%=strExtraTD%>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"").toUpperCase()%></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"").toUpperCase()%></td>
    <td width="10%" valign="top" class="thickE"><div align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "")%></div></td>
    <td width="6%" valign="top" class="thickE">
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
    <td width="12%" valign="top" ><div align="center"> <%=strCE%></div></td>
  </tr>
 <%
  	if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){
%>
  <%=strHideRowRHS%> 
<%}else bolRowSpan2 = false;%>
<%} else if ((!bolNewEntry && !bolNewPrev) || (!bolNewEntry && bolNewPrev && bolNewPage)){
  
  %>
  <tr bgcolor="#FFFFFF"> 
    <td height="18" class="thickE">&nbsp;</td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"").toUpperCase()%></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"").toUpperCase()%></td>
    <td valign="top" class="thickE"><div align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "")%></div></td>
    <td width="6%" valign="top" class="thickE">
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
    <td width="12%" valign="top"><div align="center"> <%=strCE%></div></td>
  </tr>
<%if( (i + 12) > vRetResult.size() && iRevalidaIndex > -1){
strTemp = WI.getStrValue(vRetResult.elementAt(iRevalidaIndex + 9));
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="18" class="thickE">&nbsp;</td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(iRevalidaIndex + 6),"").toUpperCase()%></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(iRevalidaIndex + 7),"").toUpperCase()%></td>
    <td valign="top" class="thickE"><div align="center"><%=WI.getStrValue(vRetResult.elementAt(iRevalidaIndex + 8), "")%></div></td>
    <td width="6%" valign="top" class="thickE">
		<div align="center">&nbsp;	</td>
    <td width="12%" valign="top"><div align="center"> <%=strTemp%></div></td>
  </tr>

<%}%>

  <% if (bolNewPage && iCurrentRow == iRowStartFr)
  		bolNewPage = false;
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%} else  bolRowSpan2 = false;
  //if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt) %>
  <%}//if ((!bolNewEntry && !bolNewPrev) || (!bolNewEntry && bolNewPrev && bolNewPage))%>
  <%}//end of for loop%> 
  
<% if (bolRowSpan2 && false)  {%>  
<tr  bgcolor="#FFFFFF" >
<td height="18"  class="thickE">&nbsp;</td>
<td class="thickE">&nbsp;</td>
<td class="thickE">&nbsp;</td>
<td class="thickE">&nbsp;</td>
<td class="thickE">&nbsp;</td>
<td >&nbsp;</td>
</tr>
  
<% } // end bolRowSpan2 == true 
	if (iLastPage == 1){
		iRowsPrinted++;
if(vMulRemark != null && vMulRemark.size() > 0){%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" class="thinborderALL" align="center"> <%=ConversionTable.replaceString((String)vMulRemark.remove(1),"\n","<br>")%></td>
  </tr>
<%}%>
<tr  bgcolor="#FFFFFF" >
	<td height="18" class="thinborderTopBottom" colspan="6"><div align="center"><strong><font size="3">**** END OF TRANSCRIPT****</font></strong></div></td>
</tr>
<%
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
	 if (vGraduationData.elementAt(6) != null && vGraduationData.elementAt(7) != null) 
	 	 strTemp += ", " + WI.formatDate((String)vGraduationData.elementAt(7),6).toUpperCase() + ".";
	 else	
	 	strTemp += ".";
		
	if (strTemp.length()/100 > 0) {
		iTemp = strTemp.length()/100;
		if (strTemp.length()%100 > 0)
			iTemp +=1;
	}
	 iRowsPrinted += iTemp; 
// 	System.out.println("iRowsPrinted 4:" + iRowsPrinted );
%>  
<tr  bgcolor="#FFFFFF" >
	<td height="18" class="thinborderBottom" colspan="6"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><%=strTemp%></label></td>
</tr>
<%} for(;iRowsPrinted < iMaxRowToDisp; ++iRowsPrinted){%>
<tr  bgcolor="#FFFFFF" >
<td height="18"  class="thickE">&nbsp;</td>
<td class="thickE">&nbsp;</td>
<td class="thickE">&nbsp;</td>
<td class="thickE">&nbsp;</td>
<td class="thickE">&nbsp;</td>
<td >&nbsp;</td>
</tr>


<%} // end display of blank rows
}%>
<tr>
<td height="18" bgcolor="#FFFFFF" class="thickE">&nbsp;</td>
<td height="18" bgcolor="#FFFFFF" class="thickE">&nbsp;</td>
<td height="18" bgcolor="#FFFFFF" class="thickE"><div align="center">
	<font style="font-size:9px">- Page <%=iPageNumber%> -</font></div></td>
<td bgcolor="#FFFFFF" class="thickE">&nbsp;</td>
<td height="18" bgcolor="#FFFFFF" class="thickE">&nbsp;</td>
<td height="18" bgcolor="#FFFFFF">&nbsp;</td>
</tr>
</table>
<%}//only if student is having grade infromation.%>


<% if (!strDegreeType.equals("1") || true) {%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="18" colspan="8" valign="bottom"><strong>&nbsp;&nbsp;GRADING SYSTEM : </strong></td>
  </tr>
  <tr>
    <td width="8%" height="15" align="center" valign="bottom"><strong><font size="1">Grade</font></strong></td>
    <td width="15%" valign="bottom"><strong><font size="1">Equivalent </font></strong></td>
    <td width="10%" valign="bottom"><strong><font size="1">Meaning</font></strong></td>
    <td width="8" align="center" valign="bottom"><strong><font size="1">Grade</font></strong></td>
    <td width="15%" valign="bottom"><strong><font size="1">Equivalent</font></strong></td>
    <td width="10%" valign="bottom"><strong><font size="1">Meaning</font></strong></td>
    <td width="8%"><div align="center"><font size="1"><strong><font size="1">Grade</font></strong></font></div></td>
    <td width="25%"><font size="1"><strong><font size="1">Equivalent Meaning </font></strong></font></td>
  </tr>
  <tr>
    <td height="19" align="center" valign="top"><font size="1">1.0<br>
    &nbsp; 1.25<br>
    1.5<br>
    &nbsp; 1.75<br>
    2.0<br>
    </font></td>
    <td valign="top"><font size="1">97 - 100%  <br>
      94 - 96%<br>
      91 - 93% &nbsp;&nbsp;<br>
      88 - 90%<br>
      85 - 87% &nbsp;&nbsp;<br>
    </font></td>
    <td valign="top"><font size="1">Excellent
	<br><br>
	Very Good<br><br>
	Good
	
	
	</font></td>
    <td align="center" valign="top"><font size="1">&nbsp; 2.25<br>
    2.5<br>
    &nbsp; 2.75<br>
    3.0<br>
    5.0<br>
    </font><br></td>
    <td valign="top"><font size="1">82 - 84%<br>
      79 - 81%<br>
    76 - 78%<br>
    75%<br>
    Below 74%<br>
    <br>
    </font></td>
    <td valign="top"><font size="1">
	&nbsp;
	<br><br>
	Fair<br>
	Passed <br>
	Failed
	</font>	</td>
    <td valign="top"><div align="center"><font size="1">INC<br>
      O.W.<br>
      U.W.<br>
	  </font></div></td>
    <td valign="top"><font size="1">INCOMPLETE<br>
      OFFICIAL WITHDRAWAL<br>
       UNOFFICIAL WITHDRAWAL </font></td>
  </tr>
  
  <tr>
    <td height="15" colspan="8" valign="top"><div align="center"><font size="1">Note : Any ERASURE or ALTERATION on this Transcript unless countersigned renders the whole transcript NULL and VOID. </font></div></td>
  </tr>
</table>

<%}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="18" colspan="6" valign="bottom"><strong>&nbsp;&nbsp;GRADING SYSTEM : </strong></td>
  </tr>
  <tr>
    <td width="14%" height="15" align="center" valign="bottom">&nbsp;</td>
    <td width="17%" valign="bottom"><strong><font size="1">Grade</font></strong></td>
    <td width="9%" valign="bottom"><strong><font size="1">Equivalent </font></strong></td>
    <td width="20%" align="center" valign="bottom">&nbsp;</td>
    <td width="8%" valign="bottom" style="font-size:9px; font-weight:bold">Grade</td>
    <td width="32%" valign="bottom" style="font-size:9px; font-weight:bold">Equivalent</td>
  </tr>
  <tr>
    <td height="19" valign="top">&nbsp;</td>
    <td height="19" valign="top"><font size="1">1.0<br>
 1.25<br>
1.5<br>
 1.75<br>
2.0<br>
    </font></td>
    <td valign="top"><font size="1">&nbsp;97 - 100<br>
      &nbsp;94 - 96<br>
      &nbsp;91 - 93<br>
      &nbsp;88 - 90<br>
      &nbsp;85 - 87<br>
    </font></td>
    <td valign="top"><font size="1"> Outsanding <br>
    Highly Satisfactory <br>
    Very Satisfactory <br>
    Satisfactory<br>
    Passed<br>
    </font><br></td>
    <td valign="top" style="font-size:9px">5.0<br>
      INC<br>
      OD<br>
      FDA<br>
      FDW</td>
    <td valign="top" style="font-size:9px">FAILED<br>
      INCOMPLETE<br>
      DROPPED<br>
      FAILURE DUE TO ABSENCES<br>
      FAILURE DUE TO WITHDRAWAL </td>
  </tr>
  <tr>
    <td height="15" colspan="6" valign="bottom"><div align="center"><font size="1">CREDITS : One unit or credit is one hour lecture or recitation each week for a period of a complete term. </font></div></td>
  </tr>
  <tr>
    <td height="15" colspan="6" valign="top"><div align="center"><font size="1">Note : Any ERASURE or ALTERATION on this Transcript unless countersigned renders the whole transcript NULL and VOID. </font></div></td>
  </tr>
</table>



<%}%>
</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(!WI.fillTextValue("last_page").equals("1")){
		strTemp = " REMARKS : continued on sheet no." + (iPageNumber +1);
%>
  <tr>
    <td height="25" colspan="2">
	<font size="1"><%=strTemp%></font></td> 
  </tr>
<%} 
   else 
  {// end not first page %>
  <tr>
    <td height="25" colspan="2">
	<font size="1">Remarks : <%=WI.fillTextValue("addl_remark")%></font></td> 
  </tr>
<%}%>  
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="233" height="10">&nbsp;</td>
    <td width="271" height="10">&nbsp;</td>
    <td width="246" height="10"><div align="center"><strong><font style="font-size:12px"><br>
    <%=WI.fillTextValue("registrar_name")%></font></strong></div></td>
  </tr>
  <tr> 
    <td height="23" valign="bottom"><font size="1">Prepared by: <strong><%=WI.fillTextValue("prep_by1")%></strong></font></td>
    <td valign="bottom"><font size="1">Checked by:<strong><%=WI.fillTextValue("check_by1")%></strong></font></td>
    <td align="center" valign="top">Registrar</td>
  </tr>
  <tr>
    <td height="20" valign="bottom">&nbsp;</td>
    <td align="center" valign="bottom"><font size="1">NOT VALID WITHOUT THE COLLEGE SEAL</font> </td>
    <td valign="top">&nbsp;</td>
  </tr>
</table>



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
