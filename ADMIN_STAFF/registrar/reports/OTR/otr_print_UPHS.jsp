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
</script>
<%@ page language="java" import="utility.*" %>
<%@ page import="java.text.*"%>
<%@ page import="java.util.*;"%>

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

boolean bolNewPage = false;
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};


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
//System.out.println(vEntranceData);
//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;
String[] astrConvertToDocType = {"Form 137","Transcript of Record","C.E.A No."};

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
	
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


	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), 
													strDegreeType, true, strExtraCon);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);
		
}


String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);


//System.out.println(vMulRemark);
int iMulRemarkCount  = 0;// 

%>

<body topmargin="5">

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td colspan="3"> <div align="center">
      <font size="2"><strong><font size="4" face="Arial Black, Arial, Verdana">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;UNIVERSITY OF PERPETUAL HELP SYSTEM LAGUNA </font></strong><font size="3" face="Arial Black, Arial, Verdana"><br>
        </font></font>
        City of Bi&ntilde;an, Laguna, Philippines 4024<br>
		<strong>Granted AUTONOMOUS STATUS under Commission En Banc (CEB) <br>
		Resolution No. 195-2012</strong><br>
		<br>
        <div style="font-size:14px "><strong>Office of the University Registrar</strong></div>
		<br>
        
         
               </div></td>
  </tr>
  <tr>
    <td height="67" colspan="2"><div align="center"><font face="Arial Black, Arial, Verdana"><strong><font size="2">	<br>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	OFFICIAL TRANSCRIPT OF RECORDS</font></strong></font>
          <br>
    </div>
    </td>
    <td width="170" rowspan="3" valign="bottom" align="left">	&nbsp;
      <%
      strTemp = WI.fillTextValue("stud_id");
      strTemp = "<img src=\"../../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=125 height=125 align=\"center\" border=\"1\">";%>
      <%=WI.getStrValue(strTemp)%>&nbsp;</td>
  </tr>
  <tr> 
    <td height="18" align="right">&nbsp;</td>
	<td height="18" align="right">&nbsp;</td>
  </tr>
  <tr>
    <td width="561" height="18">Name : <strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
    <td width="242">Student No.: <strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="20" colspan="2">Address: <strong><%=WI.fillTextValue("address")%></strong> </td>
  </tr>
  <tr>
    <td height="20" colspan="2">Program: <strong>
    <%=strStudCourseToDisp/**(String)vStudInfo.elementAt(7)**/%>
		<%=WI.getStrValue(strStudMajorToDisp, "Major in ", "","")%>
	</strong>
      </td>
  </tr>
  <tr>
    <td width="78%" height="18">Admission Credential: <strong><%=WI.fillTextValue("entrance_data")%></strong></td>
	<%
	if(vGraduationData != null)
		strTemp = WI.getStrValue((String)vGraduationData.elementAt(15),"&nbsp;");
	else
		strTemp = "&nbsp;";
if(strTemp.startsWith("&")) {
	double dGWA = 0d;
	student.GWA gwa = new student.GWA();
	dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));	
	strTemp = CommonUtil.formatFloat(dGWA,true);

}
%>	
    <td width="22%"><strong><%//=strTemp%></strong></td>
    
  </tr>
  <tr>
    <td height="20" colspan="2">Previous&nbsp;School: <strong>
    <%
	if((String)vEntranceData.elementAt(7) != null)
		strTemp = (String)vEntranceData.elementAt(5);
	else
		strTemp = (String)vEntranceData.elementAt(7);
%>
    <%=strTemp%></strong></td>
  </tr>
</table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="1" cellpadding="2" cellspacing="0" bordercolor="#000000" bgcolor="#FFFFFF">
<tr>
	<td height="655" valign="top">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#E2E2E2" class="enclosed">
  <tr bgcolor="#FFFFFF"> 
    <td width="12%" height="25" class="thickSE"><div align="center"><font size="1"><strong>TERM</strong></font></div></td>
    <td width="14%" class="thickSE"><div align="center"><font size="1"><strong>COURSE CODE</strong> </font></div></td>
    <td width="53%" class="thickSE"><div align="center"><font size="1"><strong>C O U R S E&nbsp;&nbsp;&nbsp;T I T L E</strong></font></div></td>
    <td width="7%" class="thickSE"><div align="center"><strong><font size="1">FINAL GRADES</font></strong></div></td>
    <td width="7%" class="thickSE"><div align="center"><strong><font size="1">RE-<br>
    EXAMS  </font></strong></div></td>
    <td width="7%" class="thickSE"><div align="center"><strong><font size="1">CREDITS EARNED </font></strong></div></td>
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
String strExtraTD = null;

for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
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
					
		if (i+11 < vRetResult.size())	
		{
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
	
	
if(strSchNameToDisp != null){
	if (i==0)
		strTemp ="class=\"thinborderBottom\""; 
	else
		strTemp ="class=\"thinborderTopBottom\""; 
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" <%=strTemp%> align="center">
				<strong><font size="3"><%=strSchNameToDisp.toUpperCase()%></font></strong></td>
	</tr>
<%if(vEntranceData.elementAt(12) != null){%>
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
    <td height="18" valign="top" class="thickE"><div align="center" style="font-size:9px "><%=WI.getStrValue(strSYSemToDisp).toUpperCase()%></div></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></td>
    <td width="7%" valign="top" class="thickE"><div align="center">
      <%
	 //WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")
	 //String d = "5.0/50"; 
	 if ( WI.getStrValue(vRetResult.elementAt(i + 8))!=null )   {
	  String d = WI.getStrValue(vRetResult.elementAt(i + 8));
	   if ( d.indexOf("/")<=0 )  {out.print(d);}
	   else
       {out.print( nodformat(   Double.parseDouble(d.substring(0,d.indexOf("/")))    ) );}
	 }
	%>
    </div></td>
	
    <td width="7%" valign="top" class="thickE">
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
    <td width="7%" valign="top" ><div align="center"> <%=strCE%></div></td>
  </tr>
  <% if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){bolInComment = false;%>
  <%=strHideRowRHS%> 
  <%  }else bolRowSpan2 = false;%>
  <%}else if (bolNewEntry && !bolNextNew){
  %>
  <tr bgcolor="#FFFFFF"> 
    <td height="18" valign="top" class="thickE"><div align="center"  style="font-size:9px "><%=strSYSemToDisp.toUpperCase()%></div></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></td>
    <td width="7%" valign="top" class="thickE"><div align="center">
      <%
	 //WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")
	 //String d = "5.0/50"; 
	 if ( WI.getStrValue(vRetResult.elementAt(i + 8))!=null )   {
	  String d = WI.getStrValue(vRetResult.elementAt(i + 8));
	   if ( d.indexOf("/")<=0 )  {out.print(d);}
	   else
       {out.print( nodformat(   Double.parseDouble(d.substring(0,d.indexOf("/")))    ) );}
	 }
	%>
    </div></td>
    <td width="7%" valign="top" class="thickE">
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
    <td width="7%" valign="top" ><div align="center"> 
        <% strTemp = WI.getStrValue(vRetResult.elementAt(i + 9));
			if (strTemp.indexOf("(") != -1) 
				strTemp = strTemp.substring(0,strTemp.indexOf("(")-1);
		
		%>
        <%=strTemp%>
      </div></td>
  </tr>
  <%if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}else{ bolRowSpan2 = false;}%>
<%} else if (!bolNewEntry && bolNewPrev && !bolNewPage){ %>
  <tr bgcolor="#FFFFFF">
    <td height="18" valign="top" class="thickE">&nbsp;</td> 
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></td>
    <td width="7%" valign="top" class="thickE"><div align="center">
      <%
	 //WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")
	 //String d = "5.0/50"; 
	 if ( WI.getStrValue(vRetResult.elementAt(i + 8))!=null )   {
	  String d = WI.getStrValue(vRetResult.elementAt(i + 8));
	   if ( d.indexOf("/")<=0 )  {out.print(d);}
	   else
       {out.print( nodformat(   Double.parseDouble(d.substring(0,d.indexOf("/")))    ) );}
	 }
	%>
    </div></td>
    <td width="7%" valign="top" class="thickE">
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
    <td width="7%" valign="top" ><div align="center"> <%=strCE%></div></td>
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
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%></td>
    <td width="7%" valign="top" class="thickE"><div align="center">
      <%
	 //WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")
	 //String d = "5.0/50"; 
	 if ( WI.getStrValue(vRetResult.elementAt(i + 8))!=null )   {
	  String d = WI.getStrValue(vRetResult.elementAt(i + 8));
	   if ( d.indexOf("/")<=0 )  {out.print(d);}
	   else
       {out.print( nodformat(   Double.parseDouble(d.substring(0,d.indexOf("/")))    ) );}
	 }
	%>
    </div></td>
    <td width="7%" valign="top" class="thickE">
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
    <td width="7%" valign="top"><div align="center"> <%=strCE%></div></td>
  </tr>
<%if( (i + 12) > vRetResult.size() && iRevalidaIndex > -1){
strTemp = WI.getStrValue(vRetResult.elementAt(iRevalidaIndex + 9));
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="18" class="thickE">&nbsp;</td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(iRevalidaIndex + 6),"&nbsp;")%></td>
    <td valign="top" class="thickE">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(iRevalidaIndex + 7),"&nbsp;")%></td>
    <td width="7%" valign="top" class="thickE"><div align="center">
      <%
	 //WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")
	 //String d = "5.0/50"; 
	 if ( WI.getStrValue(vRetResult.elementAt(i + 8))!=null )   {
	  String d = WI.getStrValue(vRetResult.elementAt(i + 8));
	   if ( d.indexOf("/")<=0 )  {out.print(d);}
	   else
       {out.print( nodformat(   Double.parseDouble(d.substring(0,d.indexOf("/")))    ) );}
	 }
	%>
    </div></td>
    <td width="7%" valign="top" class="thickE">
		<div align="center">&nbsp;	</td>
    <td width="7%" valign="top"><div align="center"> <%=strTemp%></div></td>
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
<td >&nbsp;</td><td >&nbsp;</td>
</tr>
  
<% } // end bolRowSpan2 == true 
	if (iLastPage == 1){
		iRowsPrinted++;
%>
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
	<td height="18" class="thinborderBottom" colspan="6"><label id="<%=++iLevelID%>" onClick="UpdateLabel('<%=iLevelID%>')"><strong>
	<%=WI.getStrValue(request.getParameter("endof_tor_remark"))%> 
	</strong></label></td>
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


<% if (!strDegreeType.equals("1")) {%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="18" colspan="6" valign="bottom"><strong>&nbsp;&nbsp;GRADING SYSTEM : </strong></td>
  </tr>
  <tr>
    <td height="15" colspan="6" align="center" valign="bottom"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	1.00=95-100%&nbsp;&nbsp;&nbsp;
	1.25=92-94% &nbsp;&nbsp;&nbsp;
    1.50=90-91% &nbsp;&nbsp;&nbsp;
    1.75=88-89% &nbsp;&nbsp;&nbsp;
    2.00=85-87% &nbsp;&nbsp;&nbsp;
	2.25=82-84% &nbsp;&nbsp;&nbsp;
    2.50=80-81% &nbsp;&nbsp;&nbsp;
    2.75=78-79% &nbsp;&nbsp;&nbsp;
    3.00=75-77% &nbsp;&nbsp;&nbsp;
    5.0=below 75% &nbsp;&nbsp;&nbsp;
	INC=Incomplete &nbsp;&nbsp;&nbsp;
	DR=Dropped &nbsp;&nbsp;&nbsp;
	UAW=Unauthorized Withdrawal &nbsp;&nbsp;&nbsp;</font></td>
    </tr>
  <tr>
    <td width="14%" height="19" align="center" valign="top">&nbsp;</td>
    <td width="16%" valign="top">&nbsp;</td>
    <td width="14%" align="center" valign="top">&nbsp;</td>
    <td width="16%" valign="top">&nbsp;</td>
    <td width="14%" valign="top">&nbsp;</td>
    <td width="26%" valign="top">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="6" valign="bottom"><div align="left"><font size="1"><font size="1">1.&nbsp;&nbsp;&nbsp;One unit of credit is equal to an 18-hour lecture class or a 54-hour laboratory class taken within one semester.</font></font></div></td>
  </tr>
  <tr>
    <td height="15" colspan="6" valign="top"><div align="left"><font size="1">2.&nbsp;&nbsp;&nbsp;Any alteration or erasure renders this transcript null and void.</font></div></td>
  </tr>
</table>

<%}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="18" colspan="6" valign="bottom"><strong>&nbsp;&nbsp;GRADING SYSTEM : </strong></td>
  </tr>
  <tr>
    <td height="15" colspan="6" align="center" valign="bottom"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1.00=95-100%&nbsp;&nbsp;&nbsp; 1.25=92-94% &nbsp;&nbsp;&nbsp; 1.50=90-91% &nbsp;&nbsp;&nbsp; 1.75=88-89% &nbsp;&nbsp;&nbsp; 2.00=85-87% &nbsp;&nbsp;&nbsp; 2.25=82-84% &nbsp;&nbsp;&nbsp; 2.50=80-81% &nbsp;&nbsp;&nbsp; 2.75=78-79% &nbsp;&nbsp;&nbsp; 3.00=75-77% &nbsp;&nbsp;&nbsp; 5.0=below 75% &nbsp;&nbsp;&nbsp; INC=Incomplete &nbsp;&nbsp;&nbsp; DR=Dropped &nbsp;&nbsp;&nbsp; UAW=Unauthorized Withdrawal &nbsp;&nbsp;&nbsp;</font></td>
  </tr>
  <tr>
    <td height="19" align="center" valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td align="center" valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr>
    <td height="15" colspan="6" valign="bottom"><div align="left"><font size="1"><font size="1">1.&nbsp;&nbsp;&nbsp;One unit of credit is equal to an 18-hour lecture class or a 54-hour laboratory class taken within one semester.</font></font></div></td>
  </tr>
  <tr>
    <td height="15" colspan="6" valign="top"><div align="left"><font size="1">2.&nbsp;&nbsp;&nbsp;Any alteration or erasure renders this transcript null and void.</font></div></td>
  </tr>
</table>
<%}%></td>
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
    <td width="7%" height="25" valign="top">
	<font size="1">Remarks: </font><br></td> 
	<td width="93%" valign="bottom"><font size="1"><%=WI.fillTextValue("addl_remark")%></font></td>
  </tr>
<%}%>  
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="320" height="20"><font size="1">Prepared by:</font></td>
    <td width="320" height="20">&nbsp;</td>
    <td width="318" height="20"><div align="center"><strong><font style="font-size:12px"><br>
    </font></strong></div></td>
  </tr>
  <tr> 
    <td height="18" valign="bottom">&nbsp;</td>
    <td valign="bottom"><font size="1">&nbsp;</font></td>
    <td align="center" valign="top">&nbsp;</td>
  </tr>
  <tr>
    <td height="10"><div align="center"><font style="font-size:10px "><strong><%=WI.fillTextValue("prep_by1")%></strong></font></div>
	</td>
    <td height="10">&nbsp;</td>
    <td height="10"><div align="center"><strong><font style="font-size:10px">HERMINIA S. LAGLIVA, CPA</font></strong></div></td>
  </tr>
  <tr>
    <td height="10" align="center"><font size="1">Evaluator</font></td>
    <td height="10">&nbsp;</td>
    <td><div align="center"><font size="1">Vice-President for Finance<br>
    </font></div></td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="10"><div align="center"><strong><font style="font-size:10px "><%=WI.fillTextValue("prep_by2")%></font></strong></div></td>
    <td><div align="center"><strong><font style="font-size:10px">REMINA L. TANYAG, MAEd SPED </font></strong></div></td>
    <td><div align="center"><strong><font style="font-size:10px">FERDINAND C. SOMIDO, PHD </font></strong></div></td>
  </tr>
  <tr>
    <td height="12"><div align="center"><font size="1">Dean</font><font size="1"><br>
    </font></div></td>
    <td><div align="center"><font size="1">University Registrar<br>
    </font></div></td>
    <td><div align="center"><font size="1">Executive School Director <br>
    </font></div></td>
  </tr>
  <tr>
    <td align="left" valign="bottom"><font style="font-size:9px ">&nbsp;&nbsp;&nbsp;&nbsp;Not valid<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;without<br>
    University seal</font> </td>
    <td height="53">&nbsp;</td>
    <td height="53">&nbsp;</td>
  </tr>
  <tr>
    <td align="center" valign="bottom">&nbsp;</td>
    <td height="10">&nbsp;</td>
    <td height="10">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" valign="bottom">&nbsp;</td>
    <td align="center" valign="bottom">&nbsp;</td>
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

<%!
public String nodformat(double n) {
java.text.NumberFormat nf = new java.text.DecimalFormat("##0.00");
return nf.format(n);
}
%>