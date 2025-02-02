<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
%>
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
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
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
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
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
    TD.thinborderLEFTTOPBOTTOM {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
<style type="text/css">
<!--
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
	TD.thickBOTTOM {
		border-bottom: solid 1px #000000;
		font-size: 11px;	
	}
	TD.thickENORIGHT {
		font-size: 11px;	
	}
	
	TD.thickE {
		border-right: solid 1px #000000;
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
	TD.thinborderTop{
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

-->
</style>
</head>

<script language="javascript">
function encodeCode(strLabel) {
	strVal = prompt('Please enter data to display','');
	if(strVal == null)
		return;
	document.getElementById(strLabel).innerHTML =  strVal;
}


function Update(strLabelID) {
	strNewVal = prompt('Please enter new Value','');
	if(strNewVal == null)
		return;
	document.getElementById(strLabelID).innerHTML = strNewVal;
}
function updateSubjectRow(strLabelID) {
	strNewVal = prompt('Please enter next line Value','');
	if(strNewVal == null)
		return;
	document.getElementById(strLabelID).innerHTML = document.getElementById(strLabelID).innerHTML+"<br>"+strNewVal;

}
</script>


<body topmargin="0" <%if(WI.fillTextValue("print_").equals("1")){%> onLoad="window.print();"<%}%>>
<%
	String strErrMsg = null;
	String strTemp = null;
	String strDegreeType = null;

	int iRowStartFr = Integer.parseInt(WI.fillTextValue("row_start_fr"));
	int iRowCount   = Integer.parseInt(WI.fillTextValue("row_count"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.fillTextValue("last_page"));

	String strDateOfGrad= WI.fillTextValue("date_grad");
	if(strDateOfGrad.length() > 0)
		strDateOfGrad = WI.formatDate(strDateOfGrad, 10);

	int iPageNumber = Integer.parseInt(WI.fillTextValue("page_number"));
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.fillTextValue("max_page_to_disp"));
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-candidate for grad - form 9","rec_can_grad_print.jsp");
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
														"rec_can_grad_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.EntranceNGraduationData eData = new enrollment.EntranceNGraduationData();
enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
//student.StudentInfo studInfo = new student.StudentInfo();

Vector vStudInfo = null;
Vector vEntranceData = null;
Vector vAdditionalInfo = null;
Vector vRetResult  = null;
boolean bolNewPage = false;
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};


/**
if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
				(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
		else {
			vEntranceData = eData.operateOnEntranceData(dbOP, request,4);
			if(vEntranceData == null)
				strErrMsg = eData.getErrMsg();
		}
	}

}
**/

Vector vMulRemark = null;
int iMulRemarkIndex = -1;
int iMulRemarkCount  = 0;// 

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
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,	(String)vStudInfo.elementAt(12));
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
		
	//System.out.println(strExtraCon);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true, strExtraCon);
	
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

String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);


if(strErrMsg != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
	<td><font size="3"><%=strErrMsg%></font>
	</td>
  </tr>
</table>
<%dbOP.cleanUP();return;}
if(iPageNumber > 1 && false) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="20">Name : 
	<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
  	<%=WI.getStrValue((String)vStudInfo.elementAt(1)," ","","").toUpperCase()%>
	</td>
    <td width="22%" height="20" align="right"></tr>
</table>
<%}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
    <td colspan="8" align="center"> 
		<font size="4">VIRGEN MILAGROSA UNIVERSITY FOUNDATION</font><br>
		<font size="1">
		Martin P. Posadas Avenue<br>
		San Carlos City, Pangasinan 2420, Philippines			</font>
      <br><br>
	  <font size="2" style="font-weight:bold">RECORDS OF CANDIDATE FOR GRADUATION</font>		</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td height="22" width="13%">Name: </td>
	<td width="52%" class="thinborderBOTTOM"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
  	<%=WI.getStrValue((String)vStudInfo.elementAt(1)," ","","").toUpperCase()%></td>
	<td width="3%"> </td>
	<td width="12%">Student I.D. </td>
	<td width="20%" class="thinborderBOTTOM"><%=WI.fillTextValue("stud_id")%></td>
</tr>
<tr> 
	<td height="22">Place of Birth: </td>
	<td class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(2))%></td>
	<td> </td>
	<td>Date of Birth: </td>
	<td class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td height="22" width="13%">Sex: </td>
	<td width="7%" class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(0))%></td>
	<td width="12%" align="right">Nationality: &nbsp;</td>
	<td width="33%" class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(11), "&nbsp;")%></td>
	<td width="3%"> </td>
	<td width="12%">Civil Status</td>
	<td width="20%" class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(12), "&nbsp;")%></td>
</tr>
<tr>
  <td height="22">Address:</td>
  <td colspan="6" class="thinborderBOTTOM"><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","")%>&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td height="22" width="23%">Parent's/Guardian's Name</td>
	<td width="42%" class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(8), "&nbsp;")%></td>
	<td width="10%" align="right">Address: &nbsp;</td>
	<td width="25%" class="thinborderBOTTOM">
<%
strTemp = (String)vAdditionalInfo.elementAt(3);
String strMonth = null;//line 2.
if(strTemp != null) {
	if(vAdditionalInfo.elementAt(4) != null) //city
		strTemp = strTemp + ", "+(String)vAdditionalInfo.elementAt(4);
	if(vAdditionalInfo.elementAt(5) != null) {//province
		if(strTemp.length() > 60)
			strMonth = (String)vAdditionalInfo.elementAt(5);
		else
			strTemp = strTemp + ", "+(String)vAdditionalInfo.elementAt(5);
	}
	if(vAdditionalInfo.elementAt(7) != null) {//zip..
		if(strMonth != null)
			strMonth += " - "+(String)vAdditionalInfo.elementAt(7);
		else
			strTemp = strTemp + " - "+(String)vAdditionalInfo.elementAt(7);
	}
}
if(strTemp != null && strTemp.length() > 35) 
	strTemp = strTemp.substring(0,30)+"...";
%>
	<%=WI.getStrValue(strTemp, "&nbsp;")%></td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td height="22">PRELIMINARY EDUCATION:</td>
	<td align="center" width="17%">School Year</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td height="22" width="3%"></td>
	<td width="12%">Primary: </td>
	<td class="thinborderBOTTOM" width="65%">
  <%
  strTemp = WI.getStrValue(vEntranceData.elementAt(14),WI.getStrValue(vEntranceData.elementAt(3)));
  %><%=WI.getStrValue(strTemp, "&nbsp;")%>

	&nbsp;</td>
	<td width="3%">&nbsp;</td>
	<td class="thinborderBOTTOM"  width="17%" align="center">
	<%=WI.getStrValue(vEntranceData.elementAt(17)) +" - "+	WI.getStrValue(vEntranceData.elementAt(18))%>&nbsp;
	</td>
</tr>
<tr> 
	<td height="22" width="3%"></td>
	<td width="12%">Intermediate: </td>
	<td class="thinborderBOTTOM" width="65%">
  <%
  strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
  %><%=WI.getStrValue(strTemp, "&nbsp;")%>
	&nbsp;</td>
	<td width="3%">&nbsp;</td>
	<td class="thinborderBOTTOM"  width="17%" align="center">
	<%=WI.getStrValue(vEntranceData.elementAt(19)) +" - "+	WI.getStrValue(vEntranceData.elementAt(20))%>&nbsp;
	</td>
</tr>
<tr> 
	<td height="22" width="3%"></td>
	<td width="12%">High School:</td>
	<td class="thinborderBOTTOM" width="65%"><%=WI.getStrValue(vEntranceData.elementAt(5))%>&nbsp;</td>
	<td width="3%">&nbsp;</td>
	<td class="thinborderBOTTOM"  width="17%" align="center">
	<%=WI.getStrValue(vEntranceData.elementAt(21)) +" - "+	WI.getStrValue(vEntranceData.elementAt(22))%>&nbsp;
	</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td width="30%" height="22">CANDIDATE FOR THE TITLE/DEGREE :</td>
	<td class="thinborderBOTTOM"><%=(String)vStudInfo.elementAt(7)%>(<%=(String)vStudInfo.elementAt(24)%>)&nbsp;</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td width="10%" height="22">Major :</td>
	<td width="30%" class="thinborderBOTTOM"><%=WI.getStrValue(vStudInfo.elementAt(8),"&nbsp;")%></td>
	<td width="10%" align="right">Minor :</td>
	<td width="15%" class="thinborderBOTTOM">&nbsp;</td>
	<td width="20%" align="right">Date of Graduation :</td>
	<td width="15%" class="thinborderBOTTOM"> <%=WI.getStrValue(strDateOfGrad, "&nbsp;")%></td>
</tr>
</table>
<br>
<%}//show only if it is not first page.. 

if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#E2E2E2" class="enclosed">
  <tr bgcolor="#FFFFFF"> 
    <td width="11%" height="25" align="center" class="thickSE">Term</td>
    <td width="20%" align="center" class="thickSE">Course No.</td>
    <td width="48%" align="center" class="thickSE">Descriptive Title</td>
    <td width="10%" align="center" class="thickSE">Grades</td>
    <td width="11%" class="thickBOTTOM"><div align="center">Units</div></td>
  </tr>
  <%
int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
int iIndexOfCE = 0; 

String strSchoolName = null;
String strPrevSchName = null;
String strSchNameToDisp = null;

String strSYSemToDisp   = null;
String strCurSYSem      = null;
String strPrevSYSem     = null;
String strNextSem       = null;

boolean bolNextNew  = true;
boolean bolNewEntry = true;
boolean bolNewPrev  =  true;

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);

///to fix error due to row span = 2
int iRevalidaIndex = -1;
String strCE ="";
boolean bolRowSpan2  = false; boolean bolInComment = false;
String strExtraTD = null;
//System.out.println(vRetResult);

//this is written to put the remark on top if remark is for foreign student.. 
if(vMulRemark != null && vMulRemark.size() > 0 && vRetResult.elementAt(3) == null) {
	int i = 0; 
	while(true) {
		if(vRetResult.size() <= i)
			break;
		if(vRetResult.elementAt(i + 3) != null)
			break;
		i += 11;
	}
	if(((Integer)vMulRemark.elementAt(0)).intValue() == i)
		vMulRemark.setElementAt(new Integer(0), 0); 
}
//System.out.println(vMulRemark);


for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
  if( (i + 12) < vRetResult.size())
	if ((String)vRetResult.elementAt(i + 6) != null && 
		((String)vRetResult.elementAt(i + 6)).toUpperCase().indexOf("REVALIDA") != -1 && vRetResult.elementAt(i) == null) {//not second course/tranferee.. 
		iRevalidaIndex = i;
		continue;
	}
	strSchoolName = (String)vRetResult.elementAt(i);
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
 	//if prev school name is not not null, show the current shcool name.
	if(strSchoolName == null && strPrevSchName != null) {
		strSchNameToDisp = strCurrentSchoolName;
		strPrevSchName = null;
	}

//strCurSYSem =
if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
		if(((String)vRetResult.elementAt(i+ 3)).length() > 1)
			strCurSYSem = ((String)vRetResult.elementAt(i+ 3));
		else
			strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))];

			strCurSYSem = strCurSYSem+" <br>"+
						(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
					
		if (i+11 < vRetResult.size())	
		{
			if(((String)vRetResult.elementAt(i+ 14)).length() > 1)
				strNextSem = ((String)vRetResult.elementAt(i+ 14));
			else
				strNextSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 14))];
			 strNextSem = strNextSem+" <br>"+
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
 //Very important here, it print <!-- if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){bolInComment = true;
 %>
  <%=strHideRowLHS%> 
  <%}else {bolInComment = false;
  ++iRowsPrinted;}//actual number of rows printed.
	
if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		iMulRemarkCount += 3;%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="5" <%=strTemp%>><div align="center"><%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></div></td>
  </tr>
  <%}//end of if
}//end of vMulRemark.
if(strSchNameToDisp != null){
	if (i==0)
		strTemp ="class=\"thinborderBottom\""; 
	else
		strTemp ="class=\"thinborderTopBottom\""; 
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="5" <%=strTemp%>><div align="center"><strong><%=strSchNameToDisp.toUpperCase()%></strong></div></td>
  </tr>
  <%strSchNameToDisp = null;}

strTemp = WI.getStrValue(vRetResult.elementAt(i + 9));
iIndexOfCE = strTemp.indexOf("(");
if(iIndexOfCE > 0) 
	strTemp = strTemp.substring(0,iIndexOfCE);
iIndexOfCE = strTemp.indexOf(".");
if(iIndexOfCE == -1)
	strTemp = strTemp.trim()  + ".0";

if (bolNewEntry && bolNextNew) {%>
  <tr bgcolor="#FFFFFF"> 
    <td height="12" class="thickE"><%=WI.getStrValue(strSYSemToDisp).toUpperCase()%></td>
    <td class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></td>
    <td width="10%" align="center" class="thickE"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
    <td width="11%" ><div align="center"> 
        <%//if(strTemp != null) {%>
        <%=strTemp%> 
        <%//}else{%>
        <%//=WI.getStrValue(vRetResult.elementAt(i + 9))%>
        <%//}%>
      </div></td>
  </tr>
  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){bolInComment = false;%>
  <%=strHideRowRHS%> 
  	<%}else bolRowSpan2 = false;%>
  <%} else if (bolNewEntry && !bolNextNew){%>
  <tr bgcolor="#FFFFFF"> 
    <td height="12" 
	<% if ((iRowEndsAt - iCurrentRow) > 1 && !bolInComment) {
		strExtraTD = "";
	%>  
		rowspan="2" 
	<%}else{
		strExtraTD = "<td valign=\"top\" class=\"thickE\">&nbsp;Printing</td>";
	}%> class="thickE"><%=strSYSemToDisp.toUpperCase()%></td>
    <td class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></td>
    <td width="10%" align="center" class="thickE"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
    <td width="11%" ><div align="center"> 
        <%//if(strTemp != null) {%>
        <%=strTemp%> 
        <%//}else{%>
        <%//=WI.getStrValue(vRetResult.elementAt(i + 9))%>
        <%//}%>
      </div></td>
  </tr>
  <%if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%>
  	<%}else{ bolRowSpan2 = true;}%>
  <%} else if (!bolNewEntry && bolNewPrev && !bolNewPage){%>
  <tr bgcolor="#FFFFFF"> 
    <%=strExtraTD%>
    <td class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></td>
    <td width="10%" align="center" class="thickE"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
    <td width="11%" ><div align="center"> 
        <%//if(strTemp != null) {%>
        <%=strTemp%> 
        <%//}else{%>
        <%//=WI.getStrValue(vRetResult.elementAt(i + 9))%>
        <%//}%>
      </div></td>
  </tr>
  <%if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
		<%}else bolRowSpan2 = false;%>
  <%} else if ((!bolNewEntry && !bolNewPrev) || (!bolNewEntry && bolNewPrev && bolNewPage)){%>
  <tr bgcolor="#FFFFFF"> 
    <%if(!bolRowSpan2){%><td height="12" class="thickE">&nbsp;</td><%}%>
    <td class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></td>
    <td width="10%" align="center" class="thickE"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
    <td width="11%"><div align="center"> 
        <%//if(strTemp != null) {%>
        <%=strTemp%> 
        <%//}else{%>
        <%//=WI.getStrValue(vRetResult.elementAt(i + 9))%>
        <%//}%>
      </div></td>
  </tr>

  <% if (bolNewPage && iCurrentRow == iRowStartFr)
  		bolNewPage = false;
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
		<%}else bolRowSpan2 = false;%>
  <%}%>

<%if( (i + 12) > vRetResult.size() && iLastPage == 1 ) {
	if(iRevalidaIndex > -1){//print revalida.. 
		strTemp = WI.getStrValue(vRetResult.elementAt(iRevalidaIndex + 9));
		iIndexOfCE = strTemp.indexOf("(");
		if(iIndexOfCE > 0) 
			strTemp = strTemp.substring(0,iIndexOfCE);
		iIndexOfCE = strTemp.indexOf(".");
		if(iIndexOfCE == -1)
			strTemp = strTemp.trim()  + ".0";
		%>
	  <tr bgcolor="#FFFFFF"> 
		<td height="12" class="thickE">&nbsp;</td>
		<td class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(iRevalidaIndex + 6),"&nbsp;")%></td>
		<td class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(iRevalidaIndex + 7),"&nbsp;")%></td>
		<td width="10%" align="center" class="thickE"><%=WI.getStrValue(vRetResult.elementAt(iRevalidaIndex + 8), "&nbsp;")%></td>
		<td width="11%"><div align="center"> 
			<%//if(strTemp != null) {%>
			<%=strTemp%> 
			<%//}else{%>
			<%//=WI.getStrValue(vRetResult.elementAt(i + 9))%>
			<%//}%>
		  </div></td>
	  </tr>
	<%}//revalida.. %>
<%if(WI.fillTextValue("last_page").compareTo("1") == 0){%>
	  <tr bgcolor="#FFFFFF"> 
		<td height="12" colspan="5" align="center" class="thinborderTop">
		vmuf-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf-NOTHING FOLLOWS-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf</td>
	  </tr>
<%}//print only for last page.%>
<%}//print vmuf vmuf .. %>


  <% 
  }//end of for loop%>
</table>
<%}//only if student is having grade infromation.%>
<%if(iLastPage !=1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td height="22" class="thinborderBOTTOM"> -- continued on page <%=iPageNumber + 1%> -- </td>
	</tr>
</table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="20%" valign="top">
		<table width="100%" cellpadding="0" cellspacing="0">
			<tr>
				<td>Percentage</td>
				<td>Numerical</td>
			</tr>
			<tr>
				<td>98-100</td>
				<td>1.0</td>
			</tr>
			<tr>
				<td>95-97</td>
				<td>1.25</td>
			</tr>
			<tr>
				<td>92-94</td>
				<td>1.5</td>
			</tr>
			<tr>
				<td>89-91</td>
				<td>1.75</td>
			</tr>
			<tr>
				<td>86-88</td>
				<td>2.0</td>
			</tr>
			<tr>
				<td>83-85</td>
				<td>2.25</td>
			</tr>
			<tr>
				<td>80-82</td>
				<td>2.50</td>
			</tr>
			<tr>
				<td>78-79</td>
				<td>2.75</td>
			</tr>
			<tr>
				<td>75-77</td>
				<td>3.0</td>
			</tr>
			<tr>
				<td>F</td>
				<td>5.0</td>
			</tr>
			<tr>
				<td colspan="2">Inc-Incomplete</td>
			</tr>
			<tr>
				<td colspan="2">Drp-Dropped</td>
			</tr>
		</table>
	</td>    
	<td valign="top">
<%
strTemp = WI.getStrValue(vAdditionalInfo.elementAt(0));
if(strTemp.startsWith("M"))
	strTemp = "Mr.";
else	
	strTemp = "Ms.";
%>
		<table width="100%" cellpadding="0" cellspacing="0">
			<tr>
				<td colspan="3">CERTIFICAITON<br>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; We hereby certify that foregoing records of <b><i><u>
				<%=strTemp%><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
  				<%=WI.getStrValue((String)vStudInfo.elementAt(1)," ","","").toUpperCase()%></u></i></b>
				a candidate for graduation as of <b><i><u><%=WI.getStrValue(strDateOfGrad)%></u></i></b> have been verified by us that true copies 
				substantiating the same are kept in the files of our university.				</td>
			</tr>
			<tr>
				<td height="50" width="33%">Prepared by:</td>
				<td width="33%">Checked by:</td>
				<td width="34%">&nbsp;</td>
			</tr>
			<tr valign="top">
			  <td height="50"><%=WI.getStrValue(WI.fillTextValue("prep_by1"), "","<br>Staff-In-Charge","")%></td>
			  <td><%=WI.getStrValue(WI.fillTextValue("check_by1"), "","<br>Records Section","")%></td>
			  <td><%=WI.getStrValue(WI.fillTextValue("accounting_division"), "","<br>Billing Section","")%></td>
		  </tr>
		</table>
		<table width="100%" cellpadding="0" cellspacing="0">
			<tr align="center" valign="bottom">
				<td width="50%" height="36"><%=WI.getStrValue(WI.fillTextValue("dean_name"), "","<br>D e a n","")%></td>
				<td><%=WI.fillTextValue("registrar_name").toUpperCase()%><br>University Registrar</td>
			</tr>
		</table>
	</td>
  </tr>
</table>

</body>
</html>
<%
dbOP.cleanUP();
%>
