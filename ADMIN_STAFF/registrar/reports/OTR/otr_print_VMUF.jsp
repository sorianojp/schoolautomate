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
	
	TABLE.enclosed {
	border-top: solid 2px #000000;
	border-bottom: solid 2px #000000;
	border-right: solid 2px #000000;
	border-left: solid 2px #000000;
	font-size: 11px;	
	}
	
	TD.thickSE {
		border-bottom: solid 2px #000000;
		border-right: solid 2px #000000;
		font-size: 11px;	
	}
	TD.thickBOTTOM {
		border-bottom: solid 2px #000000;
		font-size: 11px;	
	}
	TD.thickENORIGHT {
		font-size: 11px;	
	}
	
	TD.thickE {
		border-right: solid 2px #000000;
		font-size: 11px;	
	}

    TD.thinborder {
    border-left: solid 1px #000000;
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
	TD.thinborderTop{
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
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
boolean bolNewPage = false;
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};


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

enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();

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
	request.setAttribute("course_ref", strCourseIndex);
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	if(vEntranceData == null || vGraduationData == null)
		strErrMsg = entranceGradData.getErrMsg();
		
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
%>

<body topmargin="5">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="15%" height="25"><div align="right">Sheet No. <%=iPageNumber%> of <%=strTotalPageNumber%></div></td>
  </tr>
</table>
<%
if(iPageNumber != 1){
	bolNewPage = true;%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
   <tr>
  	<td colspan="3" height="9">&nbsp;</td>
  </tr>
    <tr>
  	<td colspan="3">&nbsp;</td>
  </tr>
    <tr>
  	<td colspan="3">&nbsp;</td>
  </tr>
  <tr> 
    <td width="2%">&nbsp;</td>
    <td width="45%" height="9">&nbsp;</td>
    <td width="53%">&nbsp; </td>
  </tr>
  <tr> 
    <td width="2%">&nbsp;</td>
    <td height="29">Name: &nbsp;<strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
    <td width="53%">Address: <strong> &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%> </strong></td>
  </tr>
</table>
<%}else{%>
<!--<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="164" valign="top"><strong>VMUF Form IX</strong></td>
    <td width="590"> <div align="center"><strong><font size="3"> <%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
        <strong><font size="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></strong><br>
        <%=SchoolInformation.getAddressLine2(dbOP,false,false)%><br>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%> <br>
        <font size="3"><strong>...</strong></font><br>
        <font size="3"><strong> OFFICE OF THE UNIVERSITY REGISTRAR<br>
        </strong></font><font size="3"><strong>...</strong></font><br>
        <strong><font size="3">Official Transcript of Record</font></strong><font size="2"><strong></strong></font></div></td>
    <td width="174" valign="bottom">&nbsp; </td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td height="23">&nbsp;</td>
  </tr>
</table>-->
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="109" height="20">Name </td>
    <td width="415"><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%>
      <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
    <td colspan="2">Course <strong><%=(String)vStudInfo.elementAt(7)%></strong></td>
  </tr>
  <tr>
    <td height="20">Address</td>
    <td><strong><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")%> </strong></td>
    <td colspan="2"><!--
	Title/Degree <strong><%=(String)vStudInfo.elementAt(7)%></strong>--></td>
  </tr>
  <tr>
    <td height="20">Entrance Data</td>
    <td><strong><%=WI.fillTextValue("entrance_data")%>
      </strong></td>
    <td colspan="2"><%=WI.fillTextValue("ched_sp_no")%>
      <%
if(vGraduationData != null)
	strTemp = (String)vGraduationData.elementAt(6);
else
	strTemp = "";
%>
      <strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
  </tr>
  <tr>
    <td height="20"><div align="center">Elementary</div></td>
    <td>
      <%
if(vEntranceData != null)
	strTemp = (String)vEntranceData.elementAt(3);
else
	strTemp = "";
%>
      <strong><%=strTemp%></strong></td>
    <td width="151">Date Issued</td>
    <td width="328">
      <%
if(vGraduationData != null)
	strTemp = (String)vGraduationData.elementAt(7);
else
	strTemp = "";
%>
      <strong><%=WI.getStrValue(WI.formatDate(strTemp,6),"&nbsp;")%></strong></td>
  </tr>
  <tr>
    <td height="20"><div align="center">Secondary&nbsp;</div></td>
    <td>
      <%
if(vEntranceData != null)
	strTemp = (String)vEntranceData.elementAt(5);
else
	strTemp = "";%>
      <strong><%=strTemp%></strong></td>
    <td>Date of Graduation</td>
    <td>
      <%
if(vGraduationData != null)
	strTemp = (String)vGraduationData.elementAt(8);
else
	strTemp = "";%>
      <strong><%=WI.getStrValue(WI.formatDate(strTemp,6),"&nbsp;")%></strong></td>
  </tr>
  <tr>
    <td height="20"><div align="center">College&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
    <td>
      <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(7));
else
	strTemp = "";
%>
      <strong><%=strTemp%></strong></td>
    <td>Date Prepared</td>
    <td><strong><%=WI.formatDate(WI.fillTextValue("date_prepared"),6)%></strong></td>
  </tr>
  <tr>
    <td height="9">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<%}//if iPage number = 1
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#E2E2E2" class="enclosed">
  <tr bgcolor="#FFFFFF"> 
    <td width="11%" height="25" align="center" class="thickSE">Term</td>
    <td width="20%" align="center" class="thickBOTTOM">Course No.</td>
    <td width="48%" align="center" class="thickSE">Descriptive Title</td>
    <td width="10%" align="center" class="thickSE">Final Grade</td>
    <td width="11%" class="thickSE"><div align="center">Credit Earned</div></td>
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
		
		strCurSYSem = strCurSYSem +" <br>"+
					(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
					
		if (i+11 < vRetResult.size() && vRetResult.elementAt(i+ 14) != null) {
			
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
    <td height="12" class="thickE"><%=WI.getStrValue(strSYSemToDisp).toUpperCase()%>&nbsp;</td>
    <td class="thickENORIGHT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
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
    <td class="thickENORIGHT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
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
    <td class="thickENORIGHT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
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
    <td class="thickENORIGHT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
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
		<td class="thickENORIGHT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(iRevalidaIndex + 6),"&nbsp;")%></td>
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
		vmuf-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf- END OF TRANSCRIPT-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf-vmuf</td>
	  </tr>
<%}//print only for last page.%>
<%}//print vmuf vmuf .. %>


  <% 
//  System.out.println(" Row "+iCurrentRow+" is new? "+bolNewPage);
  }//end of for loop%>
</table>
<%}//only if student is having grade infromation.%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(WI.fillTextValue("last_page").compareTo("1") != 0){
	if (iPageNumber != 1)
		strTemp = " <font size=1>REMARKS : continued on sheet no." + (iPageNumber +1)+"</font>";
	else
		strTemp = " <font size=1>continued on sheet no. 2</font>";%>
  <tr>
    <td height="25" colspan="2">
	<font size="2"><%=strTemp%></font></td>
  </tr>
<%} // end not first page
else{
 if(vEntranceData != null &&  (String)vEntranceData.elementAt(12) != null){//if last page, i have to show the remark.%>  
  <tr>
    <td height="25" colspan="2" align="center">&nbsp; <%=(String)vEntranceData.elementAt(12)%></td>
  </tr>
<%}%>
  <tr>
    <td height="150" colspan="2" align="center">&nbsp;
		<!-- pic is removed by diane's request : May 17 2007 put back by her the same day.. -->
			<img src="../../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt%>" height="150" width="150" border="1">
	</td>
  </tr>
<%}//end of last page.%>
<% if (iLastPage == 1){// || iPageNumber > 1%>
<!--
  <tr>
    <td height="10" colspan="2"><hr size="1"></td>
  </tr>
  <tr>
    <td width="3%" height="25">&nbsp;</td>
    <td width="97%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;One unit of credit is
      equivalent to one hour lecture or recitation each week for the period of
      a complete semester. Two to three hours of laboratory is equivalent of one
      lecture hour.</td>
  </tr>
  <tr>
    <td height="10" colspan="2"><hr size="1"></td>
  </tr>
-->
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <%
for(int abc = 0; abc < iMaxRowToDisp - iRowsPrinted; ++abc){
%>
<tr>
    <td height="10" colspan="5">&nbsp;</td>
  </tr>
<%}%>   
  <tr>
    <td height="25" colspan="5">
	<% if (WI.fillTextValue("last_page").compareTo("1") == 0) {%>
		<font style="font-size:12px">REMARKS : <strong><%=WI.fillTextValue("addl_remark")%></strong></font>
	<%}%></td>
  </tr>
<tr>
    <td height="10" colspan="5"><font style="font-size:12px">NOT VALID WITHOUT SCHOOL SEAL :</font></td>
</tr>
<tr>
    <td height="10" colspan="5"><hr size="1"></td>
</tr>
<tr>
    <td height="10">&nbsp;</td>
    <td height="10" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;One unit of credit is
      equivalent to one hour lecture or recitation each week for the period of
      a complete semester. Two to three hours of laboratory is equivalent of one
    lecture hour.</td>
  </tr>
<tr>
    <td height="10" colspan="5"><hr size="1"></td>
</tr>
  <tr> 
    <td height="10" colspan="2">Prepared by:</td>
    <td height="10" colspan="2">Checked by:</td>
    <td width="29%" height="10">&nbsp;</td>
  </tr>
  <tr> 
    <td width="4%" height="10">&nbsp;</td>
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="18" colspan="2"><div align="center"><strong><%=WI.fillTextValue("prep_by1")%></strong></div></td>
    <td width="8%">&nbsp;</td>
    <td width="26%" valign="bottom"><div align="center"><strong><%=WI.fillTextValue("check_by1")%></strong></div></td>
    <td valign="bottom"><div align="center"><strong><%=WI.fillTextValue("check_by2")%></strong></div></td>
  </tr>
  <tr> 
    <td height="15" colspan="2" valign="top"><div align="center"><em>Staff -In- 
        Charge</em></div></td>
    <td>&nbsp;</td>
    <td valign="top"><div align="center"><em>Records Section</em></div></td>
    <td valign="top"><div align="center"><em>Assessment Section</em></div></td>
  </tr>
  <tr> 
    <td height="15">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="10" colspan="5"><table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr> 
          <td width="50%" valign="bottom"><div align="center"><strong><font style="font-size:12px">MA. LILIA 
              POSADAS-JUAN, M.D. FPCHA</font></strong></div></td>
          <td colspan="2" valign="bottom"><div align="center"><strong><font style="font-size:12px"><%=WI.fillTextValue("registrar_name").toUpperCase()%></font></strong></div></td>
        </tr>
        <tr> 
          <td width="24%" height="18" valign="top"><div align="center">President</div></td>
          <td colspan="2" valign="top"><div align="center">University Registrar</div></td>
        </tr>
        <tr>
          <td height="18" valign="top">&nbsp;</td>
          <td colspan="2" valign="top">&nbsp;</td>
        </tr>
      </table></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="12%" height="19" valign="top">GRADING SYSTEM</td>
    <td width="88%" valign="top">1.0 - 98-100%; 1.25 - 95-97%; 1.5 - 92-94%; 1.75 
      - 89-91%; 2.0 86-88%; 2.25 - 83-85%; <br>
      2.5 - 80-82%; 2.75 - 78-79%; 3.0 - 75-77%; 5.0 - Below 75% - Failed, must 
      repeat<br>  INC - Incomplete, DRP - Dropped</td>
  </tr>
</table>
<% } // end if iPageNumber != 1%>

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
