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

String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

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
	
	//I have to get midterm grade only if selected to do so.. 
	if(WI.fillTextValue("consider_mterm").compareTo("1") == 0) 
		repRegistrar.getMidTermGrade();
	
	vRetResult = repRegistrar.getGraduatesHonorPoints(dbOP, WI.fillTextValue("stud_id"), strDegreeType);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
}

String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
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
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>, <%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
		</font><br>
        <font size="2"><strong> OFFICE OF THE UNIVERSITY REGISTRAR<br>
        </strong></font><br>
        <strong><font size="3"><U>HONORS CANDIDATE</U></font></strong></div></td>
    <td width="177" valign="bottom"> <table cellpadding="0" cellspacing="0">
        <tr> 
          <td valign="top"><font style="font-size: 8px;">Revision No.:00 Date:01July2001</font><br>
		  <img src="../../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt%>" height="130" width="130" border="1"></td>
        </tr>
      </table></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="18"><strong>Name</strong> </td>
    <td colspan="4"><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
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
if(vGraduationData == null || vGraduationData.elementAt(6) == null || ((String)vGraduationData.elementAt(6)).length() == 0){}
else {%>
	<%=(String)vStudInfo.elementAt(7)%>
<%}%>
	</td>
    <td colspan="3"><strong>Course</strong>: <%=(String)vStudInfo.elementAt(7)%></td>
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
    <td width="51%" class="thinborder"><strong> Where Completed</strong></td>
    <td width="9%" class="thinborder"><div align="center"><strong>When</strong><strong></strong></div></td>
    <td width="10%" class="thinborder">&nbsp;</td>
    <td width="18%" class="thinborder"><strong>Date</strong></td>
  </tr>
  <tr> 
    <td height="15" class="thinborder"><div align="left"><strong>Primary</strong></div></td>
    <td class="thinborder"> &nbsp;<%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(14),WI.getStrValue(vEntranceData.elementAt(3)));
else	
	strTemp = "&nbsp;";
%>
      <strong><%=strTemp%></strong></td>
    <td class="thinborder">&nbsp;
      <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(18),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
      <strong><%=strTemp%></strong></td>
    <td class="thinborder"><strong> Admission</strong></td>
    <td class="thinborder"> &nbsp; 
      <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(23),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
      <strong><%=strTemp%></strong></td>
  </tr>
  <tr> 
    <td height="15" class="thinborder"><div align="left"><strong>Intermediate</strong></div></td>
    <td class="thinborder"> &nbsp;<%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
else	
	strTemp = "&nbsp;";
%>
      <strong><%=strTemp%></strong></td>
    <td class="thinborder">&nbsp; 
      <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(20),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
      <strong><%=strTemp%></strong></td>
    <td class="thinborder"><strong> Graduation</strong></td>
    <td class="thinborder">&nbsp;
      <%
if(vGraduationData != null)
	strTemp = (String)vGraduationData.elementAt(8);
else
	strTemp = "";
%>
      <strong><%=WI.formatDate(strTemp,6)%></strong></td>
  </tr>
  <tr> 
    <td height="15" class="thinborder"><div align="left"><strong>High School&nbsp;&nbsp;&nbsp;</strong></div></td>
    <td class="thinborder"> &nbsp;<%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
      <strong><%=strTemp%></strong></td>
    <td class="thinborder">&nbsp; 
      <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(22),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
      <strong><%=strTemp%></strong></td>
    <td class="thinborder"><strong>Dismissal</strong></td>
    <td class="thinborder">&nbsp;</td>
  </tr>
</table>
<%}//if iPage number = 1
if(WI.fillTextValue("row_start_fr").compareTo("0") != 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="10" class="thinborderBOTTOM">&nbsp;</td>
</table>
<%}//if iPage number = 1
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#E2E2E2">
  <tr bgcolor="#FFFFFF"> 
    <td width="7%" height="25"><div align="center">Term</div></td>
    <td width="18%"><div align="center">Course No.</div></td>
    <td width="50%"><div align="center">Descriptive Title of the course</div></td>
    <td width="7%">Final</td>
<!--    <td width="7%">Re-Exam Grade</td>-->
    <td width="7%"><div align="center">Credit Earned</div></td>
    <td width="8%"><div align="center">Honor Points</div></td>
    <td width="10%"><div align="center">Total</div></td>
  </tr>
  <%
int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = null;
String strSchNameToDisp = null;

String strSYSemToDisp   = null;
String strCurSYSem      = null;
String strPrevSYSem     = null;

String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;
boolean bolIsSchNameNull    = false;
boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has 
//school name after it is null, it is encoded as cross enrollee.


String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);
for(int i = 4 ; i < vRetResult.size(); i += 13, ++iCurrentRow){
	strSchoolName = (String)vRetResult.elementAt(i);
	if(vRetResult.elementAt(i) == null)
		bolIsSchNameNull = true;
	if(vRetResult.elementAt(i) != null && bolIsSchNameNull) //cross enrolled.
		strSchoolName += " (CROSS ENROLLED)";		
/*	if(strSchoolName != null) {
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
 */	
 
 	if (i==4 && strSchoolName == null) {
		strSchNameToDisp = SchoolInformation.getSchoolName(dbOP,false,false);
	}
	if(strSchoolName == null)// && vRetResult.elementAt(i + 10) != null)//subject group name is not null for reg.sub
		strSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);

	if (strSchoolName !=null){
		strSchNameToDisp = strSchoolName;
	}
 
	 //if prev school name is not not null, show the current shcool name.
	if(strSchoolName == null && strPrevSchName != null) {
		strSchNameToDisp = strCurrentSchoolName;
		strPrevSchName = null;
	}

//strCurSYSem =
if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+" ,"+
					(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
	}
	else {
		strCurSYSem = (String)vRetResult.elementAt(i+ 3)+" ,"+(String)vRetResult.elementAt(i+ 1)+" - "+
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
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowLHS%> 
  <%}

if(false && strSchNameToDisp != null){%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="8"><div align="center"><strong><u><%=strSchNameToDisp.toUpperCase()%></u></strong></div></td>
  </tr>
  <%strSchNameToDisp = null;}

if(strSYSemToDisp != null){
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="8"><strong><u><%=strSYSemToDisp%> 
			<%=WI.getStrValue(strSchNameToDisp," - " ,"","")%></u></strong></td>
  </tr>
  <%}
%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20">&nbsp;</td>
    <td><%=vRetResult.elementAt(i + 6)%></td>
    <td><%=vRetResult.elementAt(i + 7)%></td>
    <td>      <%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vRetResult.size() > (i + 5 + 13) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6) != null && vRetResult.elementAt(i + 6 + 13) != null &&
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 13)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 13)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 13)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 13),"1")) == 0) { //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 13);
			%>
      <%=(String)vRetResult.elementAt(i + 8 + 13)%> 
      <% i += 13;}
	  else {%>
			<%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%>	  
	  <%}%>
</td>
    <td><div align="center">
<%
if(strTemp == null) 
	strTemp = WI.getStrValue(vRetResult.elementAt(i + 9));
%>
        <%=strTemp%> 
      </div></td>
    <td><div align="center"> 
<%
if(strTemp.compareTo("0") == 0 || strTemp.compareTo("0.0") == 0)
	strTemp = "0";
else	
	strTemp = WI.getStrValue(vRetResult.elementAt(i + 11));
%>
		<%=strTemp%></div></td>
    <td width="8%"><div align="center"> <%=WI.getStrValue(vRetResult.elementAt(i + 12))%></div></td>
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
    <td height="20" class="thinborderTOP"> <font size="2">REMARKS : continued 
      on sheet no. <%=iPageNumber+1%></font></td>
  </tr>
  <%}else{
 if(vEntranceData != null &&  (String)vEntranceData.elementAt(12) != null){//if last page, i have to show the remark.%>
  <tr> 
    <td height="20" class="thinborderALL" align="center">&nbsp; <strong>Transcript 
      Closed</strong> 
      <%//=(String)vEntranceData.elementAt(12)%></td>
  </tr>
  <%}%>
  <tr>
    <td height="20" align="center">&nbsp;</td>
  </tr>
  <tr> 
    <td height="20" align="center" class="thinborderALL"><strong>CREDIT EARNED 
      :</strong> &nbsp;&nbsp;<font color="#FF0000"><strong><%=(String)vRetResult.elementAt(2)%> &nbsp;</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>HONOR 
      POINTS:&nbsp;</strong>&nbsp;<font color="#FF0000"><strong><%=(String)vRetResult.elementAt(3)%>&nbsp;</strong></font>&nbsp;&nbsp; &nbsp;<strong>&nbsp;&nbsp;TOTAL 
      POINTS :</strong>&nbsp;&nbsp; <font color="#FF0000"><strong><%=(String)vRetResult.elementAt(1)%> &nbsp;</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;<strong>&nbsp;AVERAGE 
      HONOR POINTS: <font color="#FF0000"><%=(String)vRetResult.elementAt(0)%> </font></strong></td>
  </tr>
  <tr> 
    <td height="10">&nbsp;</td>
  </tr>
  <%}//end of last page.
if(WI.fillTextValue("addl_remark").length() > 0 && WI.fillTextValue("last_page").compareTo("1") == 0){%>
  <tr> 
    <td height="20">&nbsp;&nbsp;<font size="2"><b><%=WI.fillTextValue("addl_remark")%></b></font></td>
  </tr>
  <%}//I have to now run a loop to fill up the empty rows.
//System.out.println(iRowsPrinted);
//System.out.println(iMaxRowToDisp);
//for(int abc = 0; abc < iMaxRowToDisp - iRowsPrinted; ++abc){
%>
  <tr> 
    <td height="20">&nbsp;</td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
  </tr>
  <%//}%>
</table>
<%
if(WI.fillTextValue("last_page").compareTo("1") == 0) {//show in last page only.%>
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
    <td><div align="center">University Registrar</div></td>
  </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" height="10" valign="bottom"><strong><font size="1">Not Valid Without University 
      Seal</font></strong></td>
  </tr>
</table>

<%}//show grading system info for last page only.


//System.out.println(WI.fillTextValue("print_"));
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
