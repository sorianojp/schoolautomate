<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";
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
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
	TABLE.thinborderTOPRIGHTBOTTOM {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	 border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
	TD.thinborderTOPLEFT {
	border-top: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
-->
</style>
<script>
function PopulateMajor(){
	var strMajor = prompt("Student major course","");
	document.getElementById('course_major').innerHTML = strMajor
}
</script>
</head>


<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = null;

	
	int iRowStartFr = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_start_fr"), "0"));
	int iRowCount   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_count"), "0"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"), "0"));
	
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_page_to_disp"), "0"));
	
	int iPageNumber = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_number"), "0"));


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-candidate for grad - form 18","rec_can_grad_print.jsp");
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
student.StudentInfo studInfo = new student.StudentInfo();

Vector vStudInfo = null;
Vector vEntranceData = null;
Vector vAdditionalInfo = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};

Vector vRetResult = null;//this is otr detail info, i have to break it to pages,
Vector vSubGroupInfo = null;//this is having subject group information.
Vector vCurGroupInfo = null;

String strSQLQuery = null;

if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else {
///I have to update subject group here. 
strSQLQuery = "select sg_index from SUB_GROUP_MAP_FORM19 where course_index_ = "+vStudInfo.elementAt(5);
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null) {
	strSQLQuery = "update SUBJECT_GROUP set GROUP_NAME = (select SG_NAME from SUB_GROUP_MAP_FORM19 where sg_index = GROUP_INDEX and course_index_ = "+
							vStudInfo.elementAt(5)+")";
	dbOP.forceAutoCommitToFalse();
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
}
///end of updating the group.. 
		strDegreeType = (String)vStudInfo.elementAt(15);
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
				(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
		vEntranceData = eData.operateOnEntranceData(dbOP, request,4);
		if(vEntranceData == null)
			strErrMsg = eData.getErrMsg();
	}
	if(strErrMsg == null) {//get the grad detail.
		vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType);
		if(vRetResult == null)
			strErrMsg = repRegistrar.getErrMsg();

//		if (vRetResult != null){
//			for (int k = 0; k  <vRetResult.size(); k+=11){
//				if (vRetResult.elementAt(k+10) == null){
//					vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);
//					vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);
//					vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);
//					vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);
//					k-=11;
//				}
//			}
//		}
	}
	//I have to get the subject group information as well.
	if(strErrMsg == null) {
		vSubGroupInfo = repRegistrar.getRecordsOfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType);
		if(vSubGroupInfo == null)
			strErrMsg = repRegistrar.getErrMsg();
		vCurGroupInfo = repRegistrar.getSubGroupUnitOfStud(dbOP, WI.fillTextValue("stud_id"),vSubGroupInfo);
		if(vCurGroupInfo == null)
			strErrMsg = repRegistrar.getErrMsg();
	}
}

dbOP.rollbackOP();
dbOP.forceAutoCommitToTrue();

boolean bolIsEnrich = false;
Vector vEnrichmentSubjects = new enrollment.GradeSystem().getEnrichmentSubject(dbOP);
if(vEnrichmentSubjects == null)
	vEnrichmentSubjects = new Vector();
double dSG1 =0d;	double dSG2 =0d;	double dSG3 =0d;	double dSG4 =0d;	double dSG5 =0d;
double dSG6 =0d;	double dSG7 =0d;	double dSG8 =0d;	double dSG9 =0d;	double dSG10 =0d;
double dSG11 =0d;	double dSG12 =0d;	double dSG13 =0d;	double dSG14 =0d;	double dTemp =0d;

java.sql.ResultSet rs = null;
strSQLQuery = "select SG_NAME from SUB_GROUP_MAP_FORM19 where course_index_ = "+vStudInfo.elementAt(5) + " order by ORDER_NO";
rs = dbOP.executeQuery(strSQLQuery);
Vector vTemp = new Vector();
int iIndexOf = 0;
while(rs.next()) {
	iIndexOf = vSubGroupInfo.indexOf(rs.getString(1));
	if(iIndexOf == -1)
		continue;
	vTemp.addElement(vSubGroupInfo.remove(iIndexOf));
	vTemp.addElement(vSubGroupInfo.remove(iIndexOf));
//	System.out.println(rs.getString(1));
}
rs.close();
if(vTemp.size() > 0) {
	vTemp.insertElementAt(vSubGroupInfo.remove(0), 0);
	vSubGroupInfo = vTemp;
}

String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
//String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
//if(strSchoolCode == null)
//	strSchoolCode = "";


//I have to get addl number of groups.
int iAddlGroup =  0;
if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {
	iAddlGroup = vCurGroupInfo.size() / 2 - 10;
	if(iAddlGroup < 0)
		iAddlGroup = 0;
}
iAddlGroup = 4;%>


<body topmargin="0" <%if(iPageNumber == 1){%>onLoad="PopulateMajor();"<%}%>>
<%if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><font size="3"><%=strErrMsg%></font>
		</td>
	</tr>
</table>
<%dbOP.cleanUP();return;}

boolean bolIsMarE = false;
strTemp = WI.getStrValue((String)vStudInfo.elementAt(7)).toLowerCase();
if(strTemp.indexOf("marine") > -1)
	bolIsMarE = true;
	
strTemp = "RECORDS OF CANDIDATES FOR GRADUATION FROM COLLEGIATE COURSE";
if(!bolIsMarE)
	strTemp = "";

if(iPageNumber == 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center">Republic of the Philippines<br>COMMISION ON HIGHER EDUCATION<br>M a n i l a<br><br><br><%=strTemp%></td>
  </tr>
</table>
<%}




//show header only in first page.
if(iPageNumber == 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="3"></td><td colspan="2" align=""><strong><%=(String)vStudInfo.elementAt(7)%></strong></td></tr>
	<tr>
		<td width="3%"><strong>I.</strong></td>
		<td colspan="3"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%>, <%=SchoolInformation.getAddressLine2(dbOP,false,false)%> </strong></td>
	    <td width="31%" colspan="2">Title of : <%=WI.getStrValue((String)vStudInfo.elementAt(24),"(",")","")%></td>
    </tr>
	<tr>
		<td width="3%"><strong>II.</strong></td>
		<td width="42%"><strong>RECORD:</strong> Candidate for the </td>
		<td width="8%">&nbsp;</td>
		<td width="16%"><em>(Degree)Major in</em></td>
	    <td><label id="course_major"><%=WI.getStrValue(vStudInfo.elementAt(8))%></label></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="2">Minor in _______</td>
	</tr>
	<tr><td height="10" colspan="6"></td></tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td>As of:</td>
		<td colspan="2"><%=WI.fillTextValue("date_grad")%></td>
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="3%"><strong>III.</strong></td>
		<td colspan="6"><strong>PERSONAL RECORDS:</strong></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="24%" style="text-indent:30px;">Name of Candidate:</td>
		<td colspan="5">
		<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<% 
			strTemp = "&nbsp;";
			if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
				strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1));
				
			if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
				strTemp += " in: "+ WI.getStrValue((String)vAdditionalInfo.elementAt(2));
			
		%>
		<td style="text-indent:30px;">Born on:</td><td width="32%"><%=strTemp%></td>
		<%
		strTemp = "Sex";
		if(!bolIsMarE)
			strTemp = "Gender";
		%>
		<td width="11%"><%=strTemp%>:</td>
		<td width="12%"><%=WI.getStrValue(vAdditionalInfo.elementAt(0))%></td>
		<td width="8%"><%if(!bolIsMarE){%>Citizenship:<%}%></td>
		<td width="10%"><%if(!bolIsMarE){%><%=WI.getStrValue((String)vStudInfo.elementAt(23), "&nbsp;").toUpperCase()%><%}%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td style="text-indent:30px;">Parent/Guardian:</td><td><%=WI.getStrValue(vAdditionalInfo.elementAt(13), "&nbsp;")%></td>
		<td width="11%">Occupation:</td>
		<td colspan="3"><%=WI.getStrValue(vEntranceData.elementAt(28), "&nbsp;")%></td>
	</tr>
	
<%
strTemp = (String)vAdditionalInfo.elementAt(3);
if(strTemp == null)
	strTemp = "";
String strMonth = null;//line 2.
	if(vAdditionalInfo.elementAt(4) != null) { //city
		if(strTemp != null && strTemp.length() > 0)
			strTemp = strTemp + ", ";
		
		strTemp = strTemp +(String)vAdditionalInfo.elementAt(4);
	}
	if(vAdditionalInfo.elementAt(5) != null) {//province
		if(strTemp.length() > 60)
			strMonth = (String)vAdditionalInfo.elementAt(5);
		else {
			if(strTemp != null && strTemp.length() > 0)
				strTemp = strTemp + ", ";
			strTemp = strTemp + (String)vAdditionalInfo.elementAt(5);
		}
	}
	if(vAdditionalInfo.elementAt(7) != null) {//zip..
		if(strMonth != null)
			strMonth += " - "+(String)vAdditionalInfo.elementAt(7);
		else {
			if(strTemp != null && strTemp.length() > 0)
				strTemp = strTemp + " - ";
			strTemp = strTemp + (String)vAdditionalInfo.elementAt(7);
		}
	}
%>

	<tr>
		<td>&nbsp;</td>
		<td width="24%" style="text-indent:30px;">Parent Address:</td>
		<td colspan="5"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="4" height="10"></td></tr>
	<tr>
		<td width="3%"><strong>IV.</strong></td>
		<td colspan="6"><strong>RECORDS OF PRELIMINARY EDUCATION COMPLETED:</strong></td>
	</tr>
</table>	
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
    <td width="19%" height="18">Primary</td>
    <td width="62%">: &nbsp; &nbsp; &nbsp; <strong><%=WI.getStrValue((String)vEntranceData.elementAt(14))%></strong></td>    
    <td width="19%"> <%=WI.getStrValue((String)vEntranceData.elementAt(18), "SY ", "","")%></td>
  </tr>
  <tr>
    <td height="18">Intermediate</td>
    <td>: &nbsp; &nbsp; &nbsp; <strong><%=WI.getStrValue((String)vEntranceData.elementAt(16))%></strong></td>   
    <td width="19%"> <%=WI.getStrValue((String)vEntranceData.elementAt(20), "SY ", "","")%></td>
  </tr>

  
  <tr>
    <td height="18">Secondary</td>
    <td>: &nbsp; &nbsp; &nbsp; <strong><%=WI.getStrValue((String)vEntranceData.elementAt(5))%></strong></td>    
    <td width="19%"> <%=WI.getStrValue((String)vEntranceData.elementAt(22), "SY ", "","")%></td>
  </tr>
  <tr><td height="10" colspan="5"></td></tr>
</table>
<%}else{//show only if iPageNumber == 1)%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="8%" valign="bottom" height="25">NAME : </td>
		<td width="45%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></div></td>
		<td width="9%" valign="bottom">COURSE</td>
		<td width="38%" valign="bottom"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vStudInfo.elementAt(24))%></div></td>
	</tr>
	<%if(bolIsMarE){%>
	<tr>
	    <td height="25" colspan="4" valign="bottom" align="center"><strong style="font-size:14px;">C &nbsp; O &nbsp; L &nbsp; L &nbsp; E &nbsp; G &nbsp; E  &nbsp;  &nbsp;  &nbsp; R &nbsp; E &nbsp; C &nbsp; O &nbsp; R &nbsp; D &nbsp; S </strong></td>
    </tr>
	<%}%>
</table>


<%}
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"><br>
	<tr>
	<%
		if(iPageNumber != 1)
			strTemp = "750px";
		else
			strTemp = "580px";	
	%>
		<td valign="top" height="<%=strTemp%>">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderTOPRIGHTBOTTOM">
			  <tr>
				<td width="15%" class="thinborder"><div align="center"><strong>COURSE NUMBER</strong></div></td>
				<td width="" class="thinborder"><div align="center"><strong>DESCRIPTIVE TITLE</strong></div></td>
				<td width="5%" class="thinborder"><div align="center"><strong>RATING</strong></div></td>    
				<td width="4%" class="thinborder"><div align="center">1</div></td>
				<td width="4%" class="thinborder"><div align="center">2</div></td>
				<td width="4%" class="thinborder"><div align="center">3</div></td>
				<td width="4%" class="thinborder"><div align="center">4</div></td>
				<td width="4%" class="thinborder"><div align="center">5</div></td>
				<td width="4%" class="thinborder"><div align="center">6</div></td>
				<td width="4%" class="thinborder"><div align="center">7</div></td>
				<td width="4%" class="thinborder"><div align="center">8</div></td>
				<td width="4%" class="thinborder"><div align="center">9</div></td>
				<td width="3%" class="thinborder"><div align="center">10</div></td>
				<%for(int j = 0; j < iAddlGroup; ++j) {%>
				<td width="3%" class="thinborder"><div align="center"><%=(10 + j + 1)%></div></td>
				<%}%>
			  </tr>
			  <%
			int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
			String strSchoolName = null;
			String strPrevSchName = null;
			String strSchNameToDisp = null;
			
			String strSYSemToDisp   = null;
			String strCurSYSem      = null;
			String strPrevSYSem     = null;
			String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};
			
			boolean bolIsSchNameNull    = false;
			boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has
			//school name after it is null, it is encoded as cross enrollee.
			String strCrossEnrolleeSchPrev   = null;
			String strCrossEnrolleeSch       = null;
			
			
			
			
			
			String strHideRowLHS = "<!--";
			String strHideRowRHS = "-->";
			int iCurrentRow = 0;
			boolean bolReExam = false;//if it is true, i have to set re-exam value.
			//System.out.println(vRetResult);
			for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
			//I have to take care of re-exam.
				if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 &&
					WI.getStrValue(vRetResult.elementAt(i + 6)).equals(WI.getStrValue(vRetResult.elementAt(i + 6 + 11))) && //sub code,
					((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
					((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
					WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) {   //semester
					bolReExam = true;
					i += 11;
				}
				else
					bolReExam = false;
			
			/////////////////////// uncomment if school name is displayed once /////////////////////////////
			/**
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
				if(((String)vRetResult.elementAt(i+ 3)).length() == 1) {
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
			**/
			
			//////////////////// school name is displayed with school year/////////////////////////////
				strSchoolName = (String)vRetResult.elementAt(i);
				if(vRetResult.elementAt(i) == null)
					bolIsSchNameNull = true;
				if(vRetResult.elementAt(i) != null && bolIsSchNameNull) //cross enrolled.
					strSchoolName += " (CROSS ENROLLED)";
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
						strPrevSYSem = strCurSYSem;
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
			
			//////////////////// end of displaying school year ////////////////////////////////////////
			
			//get here index of group .
			
			
			iIndexOfSubGroup = vSubGroupInfo.indexOf(vRetResult.elementAt(i+ 10));
			if (iIndexOfSubGroup != -1)
				iIndexOfSubGroup = iIndexOfSubGroup/2 + 1;
			
			if(bolIsMarE)
				iIndexOfSubGroup = 1;
			
			
			
			 //Very important here, it print <!-- if it is not to be shown.
			 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
			  <%=strHideRowLHS%>
			  <%}
			
			
			String strTemp2 = "";
			if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){
				strTemp2 = strSchNameToDisp.toUpperCase() + " SUM-AG, BACOLOD CITY";
				strPrevSchName = strSchNameToDisp;
			} // if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp))))
			
			
			
			if(strSYSemToDisp != null || iRowStartFr == iCurrentRow){
			
			
			if(strCurrentSchoolName.toLowerCase().equalsIgnoreCase(strSchNameToDisp) && (strTemp2 == null || strTemp2.length() == 0))
				strTemp2 = "VMA";
				
			if(iPageNumber > 1){				 
			 if(iRowStartFr == iCurrentRow && strCurrentSchoolName.toLowerCase().equalsIgnoreCase(strSchNameToDisp)){
			 	if(strTemp2 == null || strTemp2.length() == 0)
					strTemp2 = "VMA Cont'd";
				else
					strTemp2 += " Cont'd";
			 }
			}
			
			if(i > 0)
				strTemp = "thinborderTOPLEFTBOTTOM";
			else
				strTemp = "thinborder";
			%>
			  <tr>
				<td height="20" colspan="<%=iAddlGroup + 13%>" class="<%=strTemp%>"><strong> <%=WI.getStrValue(strSYSemToDisp,strPrevSYSem)%> <%=WI.getStrValue(strTemp2).toUpperCase()%> </strong></td>  
			  </tr>
			  <%}%>
			
			  <tr>
				<td width="15%" height="20" class="thinborderLEFT"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
				<td width="25%" class="thinborderLEFT"><%=vRetResult.elementAt(i + 7)%></td>
				<td class="thinborderLEFT" align="center"> 
					<%
						if(bolReExam) 
							strTemp = (String) vRetResult.elementAt(i - 11 + 8);
						else 
							strTemp = (String)vRetResult.elementAt(i + 8);
					%> <%=WI.getStrValue(strTemp, "&nbsp;")%></td>    
					<%
						if(bolReExam) 
							strTemp = (String) vRetResult.elementAt(i - 11 + 9);
						else 
							strTemp = (String)vRetResult.elementAt(i + 9);

						if(strTemp != null) {
							iIndexOf = strTemp.indexOf("(");
							if(iIndexOf != -1) {
								strTemp = strTemp.substring(0, iIndexOf);
							}
						}						
						
						
						try{
							dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
						}catch(NumberFormatException nfe){
							dTemp = 0d;
							strTemp = "";
						}
						bolIsEnrich = false;
						iIndexOf = vEnrichmentSubjects.indexOf((String)vRetResult.elementAt(i + 6));
						if(iIndexOf > -1) {
							if(vRetResult.elementAt(i + 8) != null && !vRetResult.elementAt(i + 8).equals("5.0")){
								strTemp = "("+ vEnrichmentSubjects.elementAt(iIndexOf + 3) +")";
								bolIsEnrich = true;
							}
						}	

						if(iIndexOfSubGroup == 1)  dSG1  += dTemp;	if(iIndexOfSubGroup == 2)  dSG2  += dTemp;
						if(iIndexOfSubGroup == 3)  dSG3  += dTemp;	if(iIndexOfSubGroup == 4)  dSG4  += dTemp;
						if(iIndexOfSubGroup == 5)  dSG5  += dTemp;	if(iIndexOfSubGroup == 6)  dSG6  += dTemp;
						if(iIndexOfSubGroup == 7)  dSG7  += dTemp;	if(iIndexOfSubGroup == 8)  dSG8  += dTemp;
						if(iIndexOfSubGroup == 9)  dSG9  += dTemp;	if(iIndexOfSubGroup == 10) dSG10 += dTemp;
						if(iIndexOfSubGroup == 11) dSG11 += dTemp;	if(iIndexOfSubGroup == 12) dSG12 += dTemp;
						if(iIndexOfSubGroup == 13) dSG13 += dTemp;	if(iIndexOfSubGroup == 14) dSG14 += dTemp;	

							
					%> 
				<td class="thinborderLEFT">&nbsp;<%if(iIndexOfSubGroup == 1){%> <%=strTemp%> <%}%></td>
				<td class="thinborderLEFT">&nbsp;<%if(iIndexOfSubGroup == 2){%> <%=strTemp%> <%}%></td>
				<td class="thinborderLEFT">&nbsp;<%if(iIndexOfSubGroup == 3){%> <%=strTemp%> <%}%></td>
				<td class="thinborderLEFT">&nbsp;<%if(iIndexOfSubGroup == 4){%> <%=strTemp%> <%}%></td>
				<td class="thinborderLEFT">&nbsp;<%if(iIndexOfSubGroup == 5){%> <%=strTemp%> <%}%></td>
				<td class="thinborderLEFT">&nbsp;<%if(iIndexOfSubGroup == 6){%> <%=strTemp%> <%}%></td>
				<td class="thinborderLEFT">&nbsp;<%if(iIndexOfSubGroup == 7){%> <%=strTemp%> <%}%></td>
				<td class="thinborderLEFT">&nbsp;<%if(iIndexOfSubGroup == 8){%> <%=strTemp%> <%}%></td>
				<td class="thinborderLEFT">&nbsp;<%if(iIndexOfSubGroup == 9){%> <%=strTemp%> <%}%></td>
				<td class="thinborderLEFT">&nbsp;<%if(iIndexOfSubGroup == 10){%> <%=strTemp%> <%}%></td>
				<%for(int j = 0; j < iAddlGroup; ++j) {%>
				<td width="3%" class="thinborderLEFT">&nbsp;
					<%if(iIndexOfSubGroup == (10 + j + 1)){%> <%=strTemp%> <%}%></td>
				<%}%>
			  </tr>
			  <%
			   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
			  <%=strHideRowRHS%>
			  <%}
			 }//end of for loop
			
			if(iLastPage ==1){
			int iIndex = 0;%>
			  <tr>
				<td height="20" colspan="2" class="thinborderTOPLEFT"><div align="center">TOTAL CREDITS PRESENTER FOR GRADUATION </div></td>    
				<td align="center" class="thinborderTOPLEFT">&nbsp;</td>
				<td align="center" class="thinborderTOPLEFT"><%=CommonUtil.formatFloat(dSG1,false)%></td>
				<td align="center" class="thinborderTOPLEFT">&nbsp;<%=CommonUtil.formatFloat(dSG2,false)%></td>
				<td align="center" class="thinborderTOPLEFT">&nbsp;<%=CommonUtil.formatFloat(dSG3,false)%></td>
				<td align="center" class="thinborderTOPLEFT">&nbsp;<%=CommonUtil.formatFloat(dSG4,false)%></td>
				<td align="center" class="thinborderTOPLEFT">&nbsp;<%=CommonUtil.formatFloat(dSG5,false)%></td>
				<td align="center" class="thinborderTOPLEFT">&nbsp;<%=CommonUtil.formatFloat(dSG6,false)%></td>
				<td align="center" class="thinborderTOPLEFT">&nbsp;<%=CommonUtil.formatFloat(dSG7,false)%></td>
				<td align="center" class="thinborderTOPLEFT">&nbsp;<%=CommonUtil.formatFloat(dSG8,false)%></td>
				<td align="center" class="thinborderTOPLEFT">&nbsp;<%=CommonUtil.formatFloat(dSG9,false)%></td>
				<td align="center" class="thinborderTOPLEFT">&nbsp;<%=CommonUtil.formatFloat(dSG10,false)%></td>
				<%for(int j = 0; j < iAddlGroup; ++j) {
					if(j + 11 == 11)
						strTemp = CommonUtil.formatFloat(dSG11,false);
					else if( j + 11 == 12)
						strTemp = CommonUtil.formatFloat(dSG12,false);
					else if( j + 11 == 13)
						strTemp = CommonUtil.formatFloat(dSG13,false);
					else if( j + 11 == 14)
						strTemp = CommonUtil.formatFloat(dSG14,false);
					else
						strTemp = "Column Over flow";
				%>
				<td width="3%" align="center" class="thinborderTOPLEFT"><%=strTemp%></td>
				<%}%>
			  </tr>
			 <%if(false){%>
			  <tr align="center">
				<td height="20" colspan="2" class="thinborderLEFT"><div align="center">Total
					Units Required for Graduation</div></td>
				<td class="thinborderLEFT">&nbsp;</td>    
				<td class="thinborderLEFT" align="center"><%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%><%=vCurGroupInfo.remove(0)%><%}%>
				</td>
				<td class="thinborderLEFT" align="center">
				<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
				<%=vCurGroupInfo.remove(0)%>
				<%}else{%>&nbsp;<%}%>
				</td>
				<td class="thinborderLEFT" align="center">
				<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
				<%=vCurGroupInfo.remove(0)%>
				<%}else{%>&nbsp;<%}%>
				</td>
				<td class="thinborderLEFT" align="center">
				<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
				<%=vCurGroupInfo.remove(0)%>
				<%}else{%>&nbsp;<%}%>
				</td>
				<td class="thinborderLEFT" align="center">
				<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
				<%=vCurGroupInfo.remove(0)%>
				<%}else{%>&nbsp;<%}%>
				</td>
				<td class="thinborderLEFT" align="center">
				<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
				<%=vCurGroupInfo.remove(0)%>
				<%}else{%>&nbsp;<%}%>
				</td>
				<td class="thinborderLEFT" align="center">
				<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
				<%=vCurGroupInfo.remove(0)%>
				<%}else{%>&nbsp;<%}%>
				</td>
				<td class="thinborderLEFT" align="center">
				<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
				<%=vCurGroupInfo.remove(0)%>
				<%}else{%>&nbsp;<%}%>
				</td>
				<td class="thinborderLEFT" align="center">
				<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
				<%=vCurGroupInfo.remove(0)%>
				<%}else{%>&nbsp;<%}%>
				</td>
				<td class="thinborderLEFT" align="center">
				<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
				<%=vCurGroupInfo.remove(0)%>
				<%}else{%>&nbsp;<%}%>
				</td>
					<%for(int j = 0; j < iAddlGroup; ++j) {%>
				<td width="3%" class="thinborderLEFT" align="center">
					<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
				<%=vCurGroupInfo.remove(0)%>
				<%}%></td>
				<%}%>
			
			  </tr>
			 <%}//if(false)
			 }//only if last page.%>
			</table>
		</td>
	</tr>
</table>


 <%if(iLastPage ==1){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E5E5E5">
  <tr>
    <td height="25" align="center" class="">&nbsp;</td>
  </tr>
<% if (WI.fillTextValue("notes").length() > 0 && false){%>
  <tr>
    <td height="25"><font size=1>REMARKS : &nbsp;<%=WI.getStrValue(WI.fillTextValue("notes"))%></font></td>
  </tr>
<%}%>
  <tr>
    <td height="20">&nbsp;</td>
  </tr>
</table>
  <%}
}//end if vRetResult != null && vRetResult.size() > 0
if(iLastPage ==0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E5E5E5">
  <tr>
    <td height="25" colspan="27" class="">&nbsp;</td>
  </tr>
</table>
<%}
if(iPageNumber == 1 && vCurGroupInfo != null) {//In first page show legend for group
%>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
<% 

int iCount = 0;
int iNumber= 0;
if(vSubGroupInfo != null && vSubGroupInfo.size() > 0){
//while(iCount <= 14){
//for(int i = 0, j = 1; i < 15; i += 6){
vSubGroupInfo.remove(0);
%>
  <tr>
	<td colspan="4" align="center">C L A S S I F I C A T I O N</td>
 </tr>
<%//}//show only at start.%>
<tr>
	<td valign="top" width="23%">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<%
			while(iCount <= 4){
			%>
			<tr>			
				<%++iCount;%>
				<td style="font-size:11px;" width="30%" align="right">Group <%=++iNumber%></td>
				<td style="font-size:11px;" align="">&nbsp; :: <%if(vSubGroupInfo.size() > 0) {%><%=(String)vSubGroupInfo.remove(0)%><%vSubGroupInfo.remove(0);}%></td>				
			 </tr>
			 <%}%>
		</table>
	</td>	
	<td width="24%" valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<%
			while(iCount < 10){
			%>
			<tr>			
				<%++iCount;%>
				<td style="font-size:11px;" width="30%" align="right">Group <%=++iNumber%></td>
				<td style="font-size:11px;" align="">&nbsp; :: <%if(vSubGroupInfo.size() > 0) {%><%=(String)vSubGroupInfo.remove(0)%><%vSubGroupInfo.remove(0);}%></td>				
			 </tr>
			 <%}%>
		</table>
	</td>
	<td valign="top" width="25%">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<%
			while(iCount < 14){
			%>
			<tr>			
				<%++iCount;%>
				<td style="font-size:11px;" width="33%" align="right">Group <%=++iNumber%></td>
				<td width="67%" align="" style="font-size:11px;">&nbsp; :: 
				    <%if(vSubGroupInfo.size() > 0) {%><%=(String)vSubGroupInfo.remove(0)%><%vSubGroupInfo.remove(0);}%></td>				
			 </tr>
			 <%}%>
		</table>
	</td>	
	<td width="28%" valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td style="font-size:11px;" width="48%">Prepared by:</td>
				<td style="font-size:11px;" width="52%">____________</td>
			</tr>
			<tr>
				<td style="font-size:11px;">Evaluated:</td>
				<td style="font-size:11px;">____________</td>
			</tr>
			<tr>
				<td style="font-size:11px;">Checked:</td>
				<td style="font-size:11px;">____________</td>
			</tr>
		</table>
	</td>
 </tr>
<%}%>
</table>

<%}if(iLastPage == 1){ //it is last page, show the last page content%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="79%" height="204" valign="top">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td width="2%">&nbsp; </td>
          <td width="98%" valign="top"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="47%" height="15">Recommended for Graduation:</td>
				
                <td width="53%" height="15"><%if(false && !bolIsMarE){%>Total : <%=dSG1+dSG2+dSG3+dSG4+dSG5+dSG6+dSG7+dSG8+dSG9+dSG10+dSG11+dSG12%> Units<%}%></td>
              </tr>
              <tr>
                  <td height="15">&nbsp;</td>
                  <td height="15">&nbsp;</td>
              </tr>
              <tr>
                <td height="15" colspan="2"><div align="center">C E R T I F I C A T I O N</div></td>
              </tr>
              <tr>
                <td height="15" colspan="2">&nbsp;</td>
              </tr>
              <tr>
                <td height="15" colspan="2" style="text-indent:50px;">				  
				  I hereby certify that the foregoing records of 
				  <strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
				  <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase().charAt(0)%>.</strong> a candidate
				  for graduation in this institution, has been verified by me and that copies of the Official Record substantiates
				  same are kept on file in this College.			    </td>
              </tr>
            </table>


            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td height="30" colspan="2">&nbsp;</td>
              </tr>
			  <tr>
                <td height="15" align="center">Checked against the original:</td>
                <td height="15">&nbsp;</td>
              </tr>
              <tr>
                <td height="15" align="center">______________________</td>
                <td height="15">&nbsp;</td>
              </tr>
              <tr>
                <td height="15" align="center">Area Supervisor</td>
                <td height="15">&nbsp;</td>
              </tr>
              <tr>
                <td height="15">&nbsp;</td>
                <td width="57%" height="15" valign="bottom"><div align="center"><u><strong><%=WI.getStrValue(WI.fillTextValue("registrar_name")).toUpperCase()%></strong></u></div></td>
              </tr>
              <tr>
                <td height="15">&nbsp;</td>
                <td height="15" valign="top"><div align="center">University Registrar</div></td>
              </tr>              
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%}
if(WI.fillTextValue("print_").compareTo("1") == 0 ){%>
<script language="javascript">
 window.print();
</script>
<%}//print only if print page is clicked.
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
