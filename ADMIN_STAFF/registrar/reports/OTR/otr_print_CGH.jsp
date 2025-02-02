<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Courior New;
	font-size: 12px;
}
td{
	font-family: Courior New;
	font-size: 12px;
}
td.tor_body {
	font-family: Courior New;
	font-size: 12px;
}

th {
	font-family: Courior New;
	font-size: 12px;
}


-->
</style>
</head>
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
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"),"0"));

	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.fillTextValue("max_page_to_disp"));

	int iLastIndex = -1;

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

//end of authenticaion code.
Vector vStudInfo = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;
Vector vCompliedRequirement = null;
Vector vStudRequirements = null;
String strAdmissionStatus = null;

Vector vMulRemark = null;
int iMulRemarkIndex = -1;


boolean bolShowLabel = false;


String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester",""};

enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();

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
	enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
	vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	if(vEntranceData == null || vGraduationData == null)
		strErrMsg = entranceGradData.getErrMsg();

	Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,request.getParameter("stud_id"),
														(String)vStudInfo.elementAt(7),
													(String)vStudInfo.elementAt(8));
		if (vFirstEnrl != null) {
			vStudRequirements = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
											(String)vFirstEnrl.elementAt(2),false,false,true,true);

			if(vStudRequirements == null) {
				if(strErrMsg == null)
					strErrMsg = cRequirement.getErrMsg();//System.out.println(strErrMsg);
			}
			else {
				vCompliedRequirement = (Vector)vStudRequirements.elementAt(1);
			}

		strAdmissionStatus = (String)vFirstEnrl.elementAt(3);
		if (strAdmissionStatus == null)
			strAdmissionStatus = "";
		else {
			strAdmissionStatus = strAdmissionStatus.toLowerCase();
			if (strAdmissionStatus.equals("new"))
				strAdmissionStatus = "High School Graduate";
			else if (strAdmissionStatus.startsWith("trans"))
				strAdmissionStatus = "College Undergraduate";
			else if (strAdmissionStatus.startsWith("second"))
				strAdmissionStatus = "College Graduate";

			// insert other status here!!
		}

	  }else strErrMsg = cRequirement.getErrMsg();
}

//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else {
		vMulRemark = (Vector)vRetResult.remove(0);
		for(int i = 0; i < vRetResult.size(); i += 11) {//remove credited subject from TOR.
			if(vRetResult.elementAt(i + 1) != null)
				break;
			vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);
			vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);
			vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);
			i -= 11;
		}
	}
}
String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);

String[] astrLecLabHr = null;//gets lec/lab hour information.
String strRLEHrs    = null;
String strCE        = null;


//System.out.println(vMulRemark);
%>

<script language="javascript">
function UpdateLastRemark() {
	obj = document.getElementById('last_remark');
	var strRemark = prompt("Please enter new remark",obj.innerHTML);
	if(strRemark == null)
		return;
	obj.innerHTML = strRemark;
}
function UpdateInfo(labelID) {
	obj = document.getElementById(labelID);
	var strNewVal = prompt("Please enter new value :",obj.innerHTML);
	if(strNewVal == null)
		return;
	obj.innerHTML = strNewVal;
}
</script>

<body topmargin="5" rightmargin="10">

<table width="100%" height="100" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="95%" rowspan="2">&nbsp;</td>
    <td width="5%" height="36" valign="top">
	<%if(iPageNumber > 1){%>
    <font size="1"><br>
      <% if (bolShowLabel){%> Page <%}else{%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%><%//=iPageNumber%>
	  <% if (bolShowLabel){%> of <%}else{%>&nbsp;&nbsp;&nbsp;&nbsp;<%}%><%//=strTotalPageNumber%>
	  <% if (bolShowLabel){%> Pages <%}%></font> 
	 <%}%>
	</td>
  </tr>
  <tr>
    <td height="10" colspan="2">&nbsp;</td>
  </tr>
<%if(iPageNumber > 1){%>
  <tr>
    <td height="10" colspan="2">&nbsp;</td>
  </tr>
<%}%>
</table>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td height="20">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="6%" height="25">
	<% if (bolShowLabel){%>
	<strong>Name: </strong>
	<%}%>
	</td>
    <td width="61%" >
	<strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
    <td width="9%" ><% if (bolShowLabel) {%>
	<strong>Student Number : </strong>
	<%}%>
	</td>
    <td width="24%" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong></td>
  </tr>
 <% if (iPageNumber == 1) {%>
  <tr>
    <td height="20">
	<% if (bolShowLabel) {%>
	<strong>Address :</strong>
	<%}%>
	</td>
    <td>&nbsp;&nbsp;<strong><%=WI.fillTextValue("address")%></strong></td>
    <td>
	<% if (bolShowLabel) {%>
	<strong>DOB : </strong>
	<%}%>

	</td>
    <td><strong><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></strong></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>
<% if (bolShowLabel) {%>
	<strong>Date of Admission : </strong>
<%}%>
	</td>
    <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(23),"&nbsp;");
else
	strTemp = "&nbsp;";
%>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=strTemp%></strong></td>
  </tr>
 <%}%>
</table>

<% if (iPageNumber == 1) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">

  <tr>
    <td width="18%" height="25">
<% if (bolShowLabel) {%>
	<strong>School Last Attended : </strong>
<%}%>
	</td>
    <td width="37%"><strong>
<%
//System.out.println("vEntranceData : " + vEntranceData);
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(7));
else
	strTemp = "";

	if (strTemp.length() == 0) {
		strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");
		if(vEntranceData.elementAt(22) != null )
			strTemp = strTemp + " ("+(String)vEntranceData.elementAt(22)+")";
	}

%>
    <font style="font-size:11px;"><%=strTemp.toUpperCase()%></font></strong></td>
    <td width="16%">&nbsp;
	<%if (bolShowLabel) {%>
	<strong>Admission Status : </strong>
	<%}%>

	</td>
    <td width="29%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><label id="change_status" onClick="UpdateInfo('change_status')"><%=strAdmissionStatus%></label></strong></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="8%" height="25"><% if (bolShowLabel) {%> <strong>Course : </strong><%}%></td>
    <td width="92%"><strong> <%=((String)vStudInfo.elementAt(7)).toUpperCase()%>
    </strong></td>
  </tr>
</table>
<% }else{%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="30">&nbsp;</td>
  </tr>
</table>
<%}
if(vRetResult != null && vRetResult.size() > 0){

%>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr bgcolor="#FFFFFF">
    <td height="20" colspan="5">&nbsp;</td>
  </tr>
  <tr bgcolor="#FFFFFF">
    <td width="13%" height="40" align="center">&nbsp;
  <% if (bolShowLabel) {%>
      <strong>Course Code </strong>
    <%}%>	</td>
    <td width="49%"> &nbsp;
  <% if (bolShowLabel) {%>
      <div align="center"><strong>DESCRIPTIVE TITLE </strong></div>
  <%}%>
    &nbsp;</td>
    <td width="10%" height="30">
<% if (bolShowLabel) {%>
	<div align="center"><strong>FINAL</strong><br>
	  <strong>GRADE</strong></div>
<%}%>	</td>
    <td width="10%">
<% if (bolShowLabel) {%>
	<div align="center"><strong>comp<br>
	GRADE</strong></div>
<%}%>	</td>
    <td width="6%" align="center">
  <% if (bolShowLabel) {%>
      <strong>c<br>
      units</strong>
    <%}%>	</td>
  </tr>
  <%
int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = "";
String strSchNameToDisp = null;

String strSYSemToDisp   = null;
String strCurSYSem      = null;
String strPrevSYSem     = null;

boolean bolIsSchNameNull    = false;
boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has
//school name after it is null, it is encoded as cross enrollee.

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);

String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;

//for Math / english enrichment - i have to put parenthesis.
boolean bolPutParanthesis  = false;
Vector vMathEnglEnrichment = new enrollment.GradeSystem().getMathEngEnrichmentInfo(dbOP, request);
String strGradeValue = null;
String strSubCode    = null;
int iIndexOf         = 0;
for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
	bolPutParanthesis = false;
	//check here NSTP(CWTS) must be converted to NSTP only.. 
	strSubCode = (String)vRetResult.elementAt(i + 6);
	if(strSubCode.startsWith("NSTP") && (iIndexOf = strSubCode.indexOf("(")) > -1)
		strSubCode = strSubCode.substring(0, iIndexOf);
	if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
		try {
			double dGrade = Double.parseDouble((String)vRetResult.elementAt(i + 8));
			//System.out.println(dGrade);
			bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
			if(dGrade < 5d)
				vRetResult.setElementAt("(3.0)",i + 9);
			else 
				vRetResult.setElementAt("(0.0)",i + 9);
			
		}
		catch(Exception e){vRetResult.setElementAt("(0.0)",i + 9);}
	}

//I have to now check if this subject is having RLE hours.
//String strRLEHrs    = null;
//String strCE        = null;


	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6 + 11) != null && vRetResult.elementAt(i + 6 + 11) != null &&
		((String)vRetResult.elementAt(i + 6)).equals((String)vRetResult.elementAt(i + 6 + 11)) && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).equals((String)vRetResult.elementAt(i + 1 + 11))  && //sy_from
		((String)vRetResult.elementAt(i + 2)).equals((String)vRetResult.elementAt(i + 2 + 11)) && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").equals(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1"))) {   //semester
			
			//I have to take care of the paranthesis for inc. 
		if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
			try {
				double dGrade = Double.parseDouble((String)vRetResult.elementAt(i +11+ 8));
				//System.out.println(dGrade);
				bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
				if(dGrade < 5d)
					vRetResult.setElementAt("(3.0)",i +11+ 9);
				else 
					vRetResult.setElementAt("(0.0)",i +11+ 9);
			
			}
			catch(Exception e){vRetResult.setElementAt("(0.0)",i +11+ 9);}
		}

		
		
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
	}
	else {
		strTemp = (String)vRetResult.elementAt(i + 9);
	}
	strCE        = strTemp;
	if(strTemp != null && strTemp.indexOf("hrs") > 0 && strTemp.indexOf("(") > 0) {
		strRLEHrs = CommonUtil.formatGrade(strTemp.substring(strTemp.indexOf("(") + 1, strTemp.indexOf("hrs")),0f);
		strCE     = strTemp.substring(0,strTemp.indexOf("("));
	}
	else {
		strRLEHrs    = null;
	}
	
	//strTemp is subject code.. 
	



	strSchoolName = (String)vRetResult.elementAt(i);

	if(vRetResult.elementAt(i) == null)
		bolIsSchNameNull = true;

	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) //cross enrolled.
		strSchoolName += " (CROSS ENROLLED)";

/** uncomment this if school name apprears once. */
	if(i == 0 && strSchoolName == null) {//I have to get the current school name
		strSchNameToDisp = SchoolInformation.getSchoolName(dbOP,false,false);
		strSchoolName = strSchNameToDisp;
	}

	if (WI.getStrValue(strSchoolName).length() == 0)
		strSchoolName = strCurrentSchoolName;

	if(strPrevSchName.equals(WI.getStrValue(strSchoolName))) {
		strSchNameToDisp = null;
	} else {//itis having a new school name.
		strPrevSchName = strSchoolName;
		strSchNameToDisp = strPrevSchName;
	}


//strCurSYSem =
if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))];
	} else {
		strCurSYSem = (String)vRetResult.elementAt(i+ 3);
	}

	if (strCurSYSem != null && strCurSYSem.length() > 0){
//		if (strCurSYSem.toLowerCase().startsWith("sum")){
//			strCurSYSem += " " +  (String)vRetResult.elementAt(i+ 2);
//		}else{
			strCurSYSem += " " + (String)vRetResult.elementAt(i+ 1)+ " - " +
							(String)vRetResult.elementAt(i+ 2);
//		}
	}

	if(strCurSYSem != null) {
		if(strPrevSYSem == null) {
			strPrevSYSem = strCurSYSem ;
			strSYSemToDisp = strCurSYSem;
		}
		else if(strPrevSYSem.equals(strCurSYSem)) {
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


 //Very important here, it print <!-- if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){strHideRowLHS = "<!--";//I have to do this so i will know if I am priting data or not%>
  <%=strHideRowLHS%>
  <%}else {++iRowsPrinted;strHideRowLHS = "";}//actual number of rows printed.

if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
%>
  <tr bgcolor="#FFFFFF">
    <td height="20" colspan="5" class="tor_body"><strong><%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></strong></td>
  </tr>
  <%}//end of if
}//end of vMulRemark.

///if nothing is printed and it is chinese gen, then do not print
	
 if (strSchNameToDisp != null && strSchNameToDisp.length() > 0 && (i > 0 || (i == 0 && !strSchNameToDisp.toUpperCase().startsWith("CHINESE"))) ) { %>
  <tr bgcolor="#FFFFFF">
    <td height="17" colspan="5" class="tor_body"><strong>&nbsp;<%=WI.getStrValue(strSchNameToDisp).toUpperCase()%></strong></td>
  </tr>
<%}if(strSYSemToDisp != null){%>
  <tr bgcolor="#FFFFFF">
    <td height="17" colspan="5" class="tor_body"><strong> <%=strSYSemToDisp%>
    </strong>      <div align="center"></div></td>
  </tr>
  <%}
  
  strGradeValue = null;
%>
  <tr bgcolor="#FFFFFF">
    <td class="tor_body"><%=strSubCode%></td>
    <td class="tor_body"><%=vRetResult.elementAt(i + 7)%></td>
    <% if(WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;").compareTo("on going") == 0){%>
    <td colspan="3" class="tor_body">&nbsp;&nbsp;Grade not ready</td>
    <%}else{
		strGradeValue = WI.getStrValue(vRetResult.elementAt(i + 8));
		if( (strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
			strGradeValue = strGradeValue+"0";
		if(bolPutParanthesis && !strGradeValue.equals("INC"))
			strGradeValue = "("+strGradeValue+")";
		%>
    <td width="2%" align="center" class="tor_body"><%=WI.getStrValue(strGradeValue, "&nbsp;")%>&nbsp;</td>
    <td width="3%" align="center" class="tor_body"><%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null &&
		((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 &&
		vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null &&
		((String)vRetResult.elementAt(i + 6)).equals((String)vRetResult.elementAt(i + 6 + 11)) && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).equals((String)vRetResult.elementAt(i + 1 + 11)) && //sy_from
		((String)vRetResult.elementAt(i + 2)).equals((String)vRetResult.elementAt(i + 2 + 11)) && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").equals(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1"))) { //semester

		if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
			try {
				double dGrade = Double.parseDouble((String)vRetResult.elementAt(i +11+ 8));
				//System.out.println(dGrade);
				bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
				if(dGrade < 5d)
					vRetResult.setElementAt("(3.0)",i +11+ 9);
				else 
					vRetResult.setElementAt("(0.0)",i +11+ 9);
			
			}
			catch(Exception e){vRetResult.setElementAt("(0.0)",i +11+ 9);}
		}
		
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
		
		strGradeValue = (String)vRetResult.elementAt(i + 8 + 11);
		if( (strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
			strGradeValue = strGradeValue+"0";
		if(bolPutParanthesis)
			strGradeValue = "("+strGradeValue+")";
		
		%>
        <%=strGradeValue%>&nbsp;
        <%i += 11;}else{%>&nbsp;
		<%}
		strCE = strCE.trim();
		if(!strCE.endsWith(")") && strCE.indexOf(".") == -1)
			strCE = strCE + ".0";
		%></td>
    <td width="7%" align="center" class="tor_body"><%=strCE%>&nbsp;</td>
    <%}//sho only if grade is not on going.%>
  </tr>
  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%>
  <%}
   }//end of for loop
	if (iLastPage != 1){
%>
<tr>
	<td>&nbsp;</td>
	<td height="17" class="tor_body"><div align="center"><strong>More on next page...<br>&nbsp;</strong></div>	</td>
    <td >&nbsp;</td>
    <td >&nbsp;</td>
    <td >&nbsp;</td>
</tr>
<%}else{
	iRowsPrinted++;
%>



<%strTemp = ""; 
if (vEntranceData!= null && vEntranceData.size() > 0) {
		strTemp = WI.getStrValue((String)vEntranceData.elementAt(12));
		int iTemp = 1;
		if (strTemp.length() > 100){
			if (strTemp.length()/100 > 3)
				iTemp = strTemp.length()/100;
			else
				iTemp = 3;
		}
		iRowsPrinted +=iTemp;
}
if(strTemp.length() > 0) {%>
	<tr>
		<td colspan="5" class="tor_body">&nbsp;<%=strTemp%></td>
	</tr>
<%}%>
<%if(vGraduationData != null) {
strTemp = "Graduated with the DEGREE of "+((String)vStudInfo.elementAt(7)).toUpperCase()+" ("+
 ((String)vStudInfo.elementAt(24)).toUpperCase()+") on "+
	WI.formatDate((String)vGraduationData.elementAt(8), 6)+
	"<br>Commission on Higher Education Spec. Order (B) No. "+vGraduationData.elementAt(6)+
	" dated "+vGraduationData.elementAt(7);
%>
<tr>
	<td height="17" colspan="5" class="tor_body"><div align="center">
		<label id="last_remark" onClick="UpdateLastRemark();"><%=strTemp%></label>
		</div></td>
</tr>
<%}%>
<tr>
	<td height="17" colspan="5" class="tor_body"><div align="center">*********************  entry below not valid*********************</div></td>
</tr>

<% iRowsPrinted += 1; 
for(;iRowsPrinted < iMaxRowToDisp-1; ++ iRowsPrinted){ %>
<tr>
	<td class=>&nbsp;</td>
	<td height="17" >&nbsp;</td>
	<td >&nbsp;</td>
	<td >&nbsp;</td>
	<td >&nbsp;</td>
</tr>

<%}%>
<tr>
	<td height="17">&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
</tr>

<%
} // end if else last page%>
</table>
<%}//only if student is having grade infromation.%>

<table width="98%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td width="13%" height="10">&nbsp;</td>
    <td width="87%"><%=WI.fillTextValue("addl_remark")%></td>
  </tr>
<!--
  <tr>
    <td height="17" colspan="2">&nbsp;</td>
  </tr>
-->
</table>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
<%if (iLastPage == 1){%>
  <tr>
    <td colspan="2" height="27">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
<%}%>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="15%">&nbsp;
      <% if (bolShowLabel) {%>
	Prepared by :<%}%></td>
    <td width="19%" style="font-size:12px;">
    <strong><%=WI.fillTextValue("prep_by1")%></strong></td>
    <td width="46%">
    <div align="center" style="font-size:12px;"><strong><%=WI.fillTextValue("registrar_name")%></strong></div>	</td>
    <td width="20%"><div align="center"><strong>
	<% strTemp = WI.fillTextValue("date_prepared");
	  if (strTemp.length() > 0)
	  	strTemp = WI.formatDate(strTemp,6); %>

	<%=strTemp%></strong> </div></td>
  </tr>
<% if (bolShowLabel) {%>
  <tr>
    <td height="15" colspan="2">&nbsp;</td>
    <td width="46%"><% if (bolShowLabel) {%><div align="center">College Registrar </div><%}%></td>
    <td width="20%"><% if (bolShowLabel) {%><div align="center">Date</div><%}%></td>
  </tr>
<%}%>
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
