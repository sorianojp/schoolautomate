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
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
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

-->
</style>
</head>
<script language="javascript">
function UpdateLabel(strLevelID) {
	var newVal = prompt('Please enter new Value',document.getElementById(strLevelID).innerHTML);
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

	int iRowStartFr = Integer.parseInt(WI.fillTextValue("row_start_fr"));
	int iRowCount   = Integer.parseInt(WI.fillTextValue("row_count"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.fillTextValue("last_page"));
	
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.fillTextValue("max_page_to_disp"));
	
	int iPageNumber = Integer.parseInt(WI.fillTextValue("page_number"));
	String strTotalPageNumber = WI.fillTextValue("total_page");

	String strImgFileExt = null;

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

//end of authenticaion code.
Vector vStudInfo = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;

Vector vMulRemark = null;
int iMulRemarkIndex = -1;

///// extra condition for the selected courses
boolean viewAll = true;
int iMaxCourseDisplay = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_course_disp"),"0"));
String[] strTok = null;
String strExtraCon = " and (";

for (int k = 0; k < iMaxCourseDisplay; k++){
	if (WI.fillTextValue("checkbox"+k).length() == 0 ){
		viewAll = false;
		continue;
	}
	strTok = (WI.fillTextValue("checkbox"+k)).split(",");
	
	if (strTok != null){
		if (strExtraCon.length() > 7) 
			strExtraCon += " or ";
	
		strExtraCon +=  
			" (stud_curriculum_hist.course_index = " + strTok[0];
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


///// end extra condition for the selected courses..



String[] astrConvertSem = {"SUMMER","1ST SEMESTER","2ND SEMESTER","3RD SEMESTER","4TH SEMESTER"};

enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();

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
}

//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), 
													strDegreeType, true, strExtraCon);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);
}

String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);

boolean bolIsRLEHrs = false;
boolean bolShowLecLabHr = false; String[] astrLecLabHr = null;//gets lec/lab hour information.
String strRLEHrs    = null;
String strCE        = null;


if(vRetResult.toString().indexOf("hrs") > 0 && WI.fillTextValue("show_rle").compareTo("1") == 0)
	bolIsRLEHrs = true;

if(WI.fillTextValue("show_leclab").compareTo("1") == 0)	
	bolShowLecLabHr = true;
	
//System.out.println(vMulRemark);
int iMulRemarkCount  = 0;// 
%>

<body topmargin="5">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="15%" height="20"><div align="right">Sheet No. <%=iPageNumber%> of <%=strTotalPageNumber%></div></td>
  </tr>
</table>
<%
if(iPageNumber != 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="3%">&nbsp;</td>
    <td width="78%" height="18" valign="top">Name &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;<strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,<%=((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
    <td width="19%">&nbsp;</td>
  </tr>
</table>
<%}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="164" valign="top">&nbsp;UI-REG-017</td>
    <td width="587"> <div align="center"><strong><font size="5"> <%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
        <font size="2">
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>, <%=SchoolInformation.getAddressLine2(dbOP,false,false)%> </font><br>
        <br>
        <font size="2"><strong> OFFICE OF THE UNIVERSITY REGISTRAR<br>
        </strong></font><br>
        <strong><font size="3"><U>OFFICIAL TRANSCRIPT OF RECORD</U></font></strong></div></td>
    <td width="177" valign="bottom"> <table cellpadding="0" cellspacing="0">
        <tr> 
          <td valign="top"><font style="font-size: 8px;">Revision No.:01 Date:23May2005</font><br>
		  <img src="../../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt%>" height="130" width="130" border="1"></td>
        </tr>
      </table></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="18"><strong>Name</strong> </td>
    <td colspan="4"><strong><%=((String)vStudInfo.elementAt(2))%>, <%=WI.getStrValue((String)vStudInfo.elementAt(0))%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ")%></strong></td>
  </tr>
  <tr> 
    <td height="18"><strong>Address</strong></td>
    <td colspan="2"><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","")%></td>
    <td width="9%"><strong>Date</strong>:</td>
    <td><strong><%=WI.getTodaysDate(1)%></strong></td>
  </tr>
  <tr> 
    <td height="18" width="15%"><strong>College</strong></td>
    <td colspan="2"><%=strCollegeName%></td>
    <td><strong>S.C.A.N.</strong></td>
    <td width="19%"><strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong></td>
  </tr>
  <tr> 
    <td height="18"><strong>Title/Degree</strong></td>
    <td width="25%">
<%//do not display Title / Degree if no SO number 

/***** updated to manual encoding, August 30, 2007 *****/
//if(vGraduationData == null || vGraduationData.elementAt(6) == null || ((String)vGraduationData.elementAt(6)).length() == 0){}
//else {%>
	<%//=(String)vStudInfo.elementAt(7)%>
<%//}%> <%=WI.fillTextValue("title_degree")%>
	</td>
    <td colspan="3"><strong>Course</strong>: <label id="_1" onClick="UpdateLabel('_1')"><%=(String)vStudInfo.elementAt(7)%>
	<%=WI.getStrValue((String)vStudInfo.elementAt(8)," Major in ","","")%></label></td>
  </tr>
  <tr> 
    <td height="18"><strong>Date of Birth</strong></td>
    <td><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></td>
    <td colspan="3"><strong>Father's Name:</strong> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(8))%></td>
  </tr>
  <tr> 
    <td height="18"><strong>Place of Birth</strong></td>
    <td><%=WI.getStrValue(vAdditionalInfo.elementAt(2))%></td>
    <td colspan="3"><strong>Mother's Name:</strong> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(9))%></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr> 
    <td width="12%" class="thinborder"><strong>Courses</strong></td>
    <td width="51%" class="thinborder"><strong> &nbsp;Where Completed</strong></td>
    <td width="9%" class="thinborder">&nbsp;<strong>When</strong></td>
    <td width="10%" class="thinborder">&nbsp;</td>
    <td width="18%" class="thinborder">&nbsp;<strong>Date</strong></td>
  </tr>
  <tr> 
    <td height="15" class="thinborder"><div align="left"><strong>Primary</strong></div></td>
    <td class="thinborder"> &nbsp; <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(14),WI.getStrValue(vEntranceData.elementAt(3)));
else	
	strTemp = "&nbsp;";
%> <strong><%=strTemp%></strong></td>
    <td class="thinborder">&nbsp; <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(18),"&nbsp;");
else	
	strTemp = "&nbsp;";
%> <strong><%=strTemp%></strong></td>
    <td class="thinborder"><strong> Admission</strong></td>
    <td class="thinborder"> &nbsp; <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(23),"&nbsp;");
else	
	strTemp = "&nbsp;";
%> <strong><%=strTemp%></strong></td>
  </tr>
  <tr> 
    <td height="15" class="thinborder"><div align="left"><strong>Intermediate</strong></div></td>
    <td class="thinborder"> &nbsp; <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
else	
	strTemp = "&nbsp;";
%> <strong><%=strTemp%></strong></td>
    <td class="thinborder">&nbsp; <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(20),"&nbsp;");
else	
	strTemp = "&nbsp;";
%> <strong><%=strTemp%></strong></td>
    <td class="thinborder"><strong> Graduation</strong></td>
    <td class="thinborder">&nbsp; <%
if(vGraduationData != null)
	strTemp = (String)vGraduationData.elementAt(8);
else
	strTemp = "";
	
	if (strTemp != null && strTemp.length() !=0) strTemp= WI.formatDate(strTemp,10);
	else strTemp = "";
	
%> <strong><%=strTemp%></strong></td>
  </tr>
  <tr> 
    <td height="19" class="thinborder"><div align="left"><strong>High School&nbsp;&nbsp;&nbsp;</strong></div></td>
    <td class="thinborder"> &nbsp; <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");
else	
	strTemp = "&nbsp;";
%> <strong><%=strTemp%></strong></td>
    <td class="thinborder">&nbsp; <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(22),"&nbsp;");
else	
	strTemp = "&nbsp;";
%> <strong><%=strTemp%></strong></td>
    <td class="thinborder"><strong>Dismissal</strong></td>
    <td class="thinborder">&nbsp; <%
if(vGraduationData != null)
	strTemp = WI.getStrValue((String)vGraduationData.elementAt(14));
else
	strTemp = "";
	
if (strTemp != null && strTemp.length() !=0) strTemp= WI.formatDate(strTemp,10);
	else strTemp = "";
%> <strong><%=strTemp%></strong></td>
  </tr>
  <tr>
    <td height="19" colspan="5" class="thinborder"><strong>Entrance Credential : <%=WI.fillTextValue("entrance_data")%></strong></td>
  </tr>
  <tr>
    <td height="19" colspan="5" class="thinborder"><strong>NCEE</strong> &nbsp;<u><strong><%=WI.fillTextValue("ncee")%></strong></u>&nbsp;&nbsp;&nbsp;<strong>GSA</strong> &nbsp;<strong><u><%=WI.fillTextValue("gsa")%></u> </strong>&nbsp;&nbsp;&nbsp; <strong>%ile Rank</strong> 
      &nbsp;<u><strong><%=WI.fillTextValue("percentile")%></strong></u></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td class="thinborderLEFT">&nbsp;</td>
<td class="thinborderRIGHT">&nbsp;</td></tr>
</table>
<%}//if iPage number = 1
if(WI.fillTextValue("row_start_fr").compareTo("0") != 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="10" class="thinborderBOTTOM">&nbsp;</td>
</table>

<%}
if(vRetResult != null && vRetResult.size() > 0){
	int iNumWeeks = 0;
	if (WI.fillTextValue("weeks").length() > 0) iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#FFFFFF"> 
    <td width="7%" height="20" class="thinborderLEFTBOTTOM"><div align="center"><strong>Term</strong></div></td>
    <td width="18%" class="thinborderBOTTOM"><div align="center"><strong>Course 
        No.</strong></div></td>
    <td width="43%" class="thinborderBOTTOM"><div align="center"><strong>Descriptive 
        Title of the Course</strong></div></td>
    <%if(bolShowLecLabHr){%>
    <td width="7%" class="thinborderBOTTOM"><div align="center"><strong>LEC<br>
        (HRS) </strong></div></td>
    <td width="7%" class="thinborderBOTTOM"><div align="center"><strong>LAB (HRS)</strong></div></td>
    <%}%>
    <%if(bolIsRLEHrs){%>
    <td width="7%" class="thinborderBOTTOM"><div align="center"><strong> RLE (HRS)</strong></div></td>
    <%}%>
    <td width="7%" class="thinborderBOTTOM"><div align="center"><strong>Final 
        Grade</strong></div></td>
    <td width="8%" class="thinborderBOTTOM"><div align="center"><strong>Re-Exam 
        Grade</strong></div></td>
    <td width="10%" class="thinborderRIGHTBOTTOM"><div align="center"><strong>Credit 
        Earned</strong></div></td>
  </tr>
  <%
int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = null;
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
for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){//System.out.println("i : "+i+ " ; "+vRetResult.elementAt(i + 8));
//I have to now check if this subject is having RLE hours. 
//String strRLEHrs    = null;
//String strCE        = null;

	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6 + 11) != null && vRetResult.elementAt(i + 6 + 11) != null && 
		WI.getStrValue(vRetResult.elementAt(i + 6)).equals(WI.getStrValue(vRetResult.elementAt(i + 6 + 11))) && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) {   //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
	}
	else {
		strTemp = (String)vRetResult.elementAt(i + 9);
	}
	strCE        = strTemp;
	if(strTemp != null && strTemp.indexOf("hrs") > 0 && strTemp.indexOf("(") > 0) {
		strRLEHrs = CommonUtil.formatGrade(strTemp.substring(strTemp.indexOf("(") + 1, strTemp.indexOf("hrs")),0f);
		if(strTemp.indexOf("(") > -1) 
			strCE     = strTemp.substring(0,strTemp.indexOf("("));
	}
	else {
		strRLEHrs    = null;
	}
	
		

	strSchoolName = (String)vRetResult.elementAt(i);
	if(vRetResult.elementAt(i) == null)
		bolIsSchNameNull = true;
	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) //cross enrolled.
		strSchoolName += " (CROSS ENROLLED)";		
/** uncomment this if school name apprears once.
	if(strSchoolName != null) {
		if(strPrevSchName == null) {
			strPrevSchName = strSchoolName ;
			strSchNameToDisp = strSchoolName;
		}
		else if(strPrevSchName.compareTo(strSchoolName) ==0) {
			strSchNameToDisp = null;
		}
		else {//itis having a new school name.
			strPrevSchName = strSchoolName;
			strSchNameToDisp = strPrevSchName;
		}
	}
**/	if(i == 0 && strSchoolName == null) {//I have to get the current school name
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
		}
	}


 //Very important here, it print <!-- if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){strHideRowLHS = "<!--";//I have to do this so i will know if I am priting data or not%>
  <%=strHideRowLHS%> 
  <%}else {++iRowsPrinted;strHideRowLHS = "";}//actual number of rows printed.

if(false && strSchNameToDisp != null){//do not keep extra line for school name.%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="9" class="thinborderLEFTRIGHT" align="center"><strong><u><%=strSchNameToDisp.toUpperCase()%></u></strong></td>
  </tr>
  <%strSchNameToDisp = null;}
if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		iMulRemarkCount += 3;%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="9" class="thinborderALL" align="center"> <%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></td>
  </tr>
  <%}//end of if
}//end of vMulRemark.

if(strSYSemToDisp != null){
	if(strSYSemToDisp.startsWith("FALL")) {
		strSYSemToDisp = "FALL "+strSYSemToDisp.substring(strSYSemToDisp.length() - 4);
	}
	else if(strSYSemToDisp.startsWith("SPRING")) {
		strSYSemToDisp = "SPRING "+strSYSemToDisp.substring(strSYSemToDisp.length() - 4);
	}

%>
  <tr bgcolor="#FFFFFF"> 
    <td height="17" colspan="9" class="thinborderLEFTRIGHT">&nbsp;&nbsp;<strong> 
      <u><%=strSYSemToDisp%><%=WI.getStrValue(strSchNameToDisp," - ","","")%></u></strong></td>
  </tr>
  <%}
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="17" class="thinborderLEFT">&nbsp;</td>
    <td><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td ><%=vRetResult.elementAt(i + 7)%></td>
    <%if(bolShowLecLabHr){
	if(strHideRowLHS.length() == 0) 
		astrLecLabHr = repRegistrar.getOTROfCanLecLabHr(dbOP, false, (String)vRetResult.elementAt(i + 6),(String)vRetResult.elementAt(i + 7),null);
		//System.out.println(astrLecLabHr[0] +" " +astrLecLabHr[1]);%>
    <td width="7%" align="center">&nbsp;
      <%strTemp = "";
	  if(astrLecLabHr != null && iNumWeeks > 0){
		  if (Integer.parseInt(WI.getStrValue(astrLecLabHr[0],"0")) < 30){
		  	strTemp = Integer.toString(Integer.parseInt(WI.getStrValue(astrLecLabHr[0],"0"))*iNumWeeks);
		  }else{
		  	strTemp = WI.getStrValue(astrLecLabHr[0],"0");
	  	  }
	  }%>
	  <%=strTemp%>
    <td width="7%" align="center"> <%if(astrLecLabHr != null && iNumWeeks > 0){
	  if (Integer.parseInt(WI.getStrValue(astrLecLabHr[1],"0")) < 30){%>
      <%=Integer.parseInt(WI.getStrValue(astrLecLabHr[1],"0"))*iNumWeeks%>
	   <%}else{%>
      <%=WI.getStrValue(astrLecLabHr[1],"0")%>
      <%}}%></td>
    <%}%>
    <%if(bolIsRLEHrs){%>
    <td width="7%"><div align="center">
		  <input type="text" style="border:0px; font-family:Verdana, Geneva, Arial, Helvetica, sans-serif; font-size:11px; text-align:center" size="4" value="<%=WI.getStrValue(strRLEHrs)%>">
	</div></td>
    <%}%>
    <%
if(WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;").compareTo("on going") == 0){%>
    <td colspan="3" class="thinborderRIGHT">&nbsp;&nbsp;Grade not ready</td>
    <%}else{%>
    <td >&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
    <td align="center"> <%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && 
		((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && 
		vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && 
		WI.getStrValue(vRetResult.elementAt(i + 6)).equals(WI.getStrValue(vRetResult.elementAt(i + 6 + 11))) && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
			
			%> <%=(String)vRetResult.elementAt(i + 8 + 11)%> <%i += 11;}%> </td>
    <td class="thinborderRIGHT" align="center">&nbsp;<%=strCE%> <%//if(strTemp != null) {%> <%//=strTemp%> <%//}else{%> <%//=WI.getStrValue(vRetResult.elementAt(i + 9))%> <%//}%> </td>
    <%}//sho only if grade is not on going.%>
  </tr>
  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop
   %>
</table>
<%}//only if student is having grade infromation.%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(WI.fillTextValue("last_page").compareTo("1") != 0){%>
  <tr>
    <td height="20" colspan="2" class="thinborderTOP">
	<font size="2">REMARKS : </font><font size="1">
	continued on sheet no. <%=iPageNumber+1%></font></td>
  </tr>
<%}else{
 if(vEntranceData != null &&  (String)vEntranceData.elementAt(12) != null){//if last page, i have to show the remark.
 iMaxRowToDisp = iMaxRowToDisp - 2;%>  
  <tr>
    <td height="20" colspan="2" class="thinborderALL" align="center">&nbsp; <%=(String)vEntranceData.elementAt(12)%></td>
  </tr>
<%}%>
  <tr>
    <td height="20" colspan="2" class="thinborderALL" align="center">&nbsp;Transcript Closed</td>
  </tr>
<tr>
    <td height="10" colspan="2">&nbsp;</td>
  </tr>
<%}//end of last page.%>

<%if(WI.fillTextValue("addl_remark").length() > 0 && WI.fillTextValue("last_page").compareTo("1") == 0){
//I have to now remove the lines takes by remarks
int iTemp = 1;
 strTemp = WI.fillTextValue("addl_remark");
int iIndexOf = 0;

while(  (iIndexOf = strTemp.indexOf("<br>",iIndexOf + 1)) != -1)
	++iTemp;
//System.out.println("Printing :"+iTemp);
 iMaxRowToDisp = iMaxRowToDisp - iTemp;//I have to remove number of lines from  iMaxDisplay.
%>
<tr>
    <td height="20" colspan="2"><font size="2"><%=WI.fillTextValue("addl_remark")%></font></td>
  </tr>

<%}//I have to now run a loop to fill up the empty rows.
//System.out.println(iRowsPrinted);
//System.out.println(iMaxRowToDisp);
for(int abc = iMulRemarkCount; abc < iMaxRowToDisp - iRowsPrinted; ++abc){
%>
<tr>
    <td height="20" colspan="2">&nbsp;</td>
  </tr>
<%}%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="20" colspan="4"><strong>Grading System</strong></td>
    <td width="38%">&nbsp;</td>
    <td width="33%">&nbsp;</td>
  </tr>
  <tr> 
    <td width="4%" height="15">1.0</td>
    <td width="9%">98 - 100</td>
    <td width="4%">2.25</td>
    <td width="12%">83 - 85</td>
    <td width="38%">&nbsp;</td>
    <td width="33%"><strong>ENDORSEMENT</strong></td>
  </tr>
  <tr> 
    <td height="15">1.25</td>
    <td>95 - 97</td>
    <td>2.5</td>
    <td>80 - 82</td>
    <td width="38%">Prepared by : <strong><%=WI.fillTextValue("prep_by1")%></strong></td>
    <td width="33%">Correct Transcript of Record</td>
  </tr>
  <tr> 
    <td height="15">1.5</td>
    <td>92 - 94</td>
    <td>2.75</td>
    <td>77 - 79</td>
    <td width="38%">&nbsp;</td>
    <td width="33%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="15">1.75</td>
    <td>89 - 91</td>
    <td>3.0</td>
    <td>75 - 76</td>
    <td width="38%">&nbsp;</td>
    <td width="33%"><div align="center">_____________________________</div></td>
  </tr>
  <tr> 
    <td height="15">2.0</td>
    <td>86 - 88</td>
    <td>5.0</td>
    <td>70 - 74</td>
    <td width="38%">Checked by : <strong><%=WI.fillTextValue("check_by1")%></strong></td>
    <td width="33%"><div align="center"><strong><%=WI.fillTextValue("registrar_name").toUpperCase()%></strong></div></td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><div align="center"><%=WI.getStrValue(WI.fillTextValue("registrar_desig"),"University Registrar")%></div></td>
  </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" height="10" valign="bottom"><strong><font size="1">Not Valid Without University 
      Seal</font></strong></td>
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
