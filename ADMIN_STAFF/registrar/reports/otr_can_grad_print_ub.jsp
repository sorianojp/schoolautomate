<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	int iMulRemarkCount =0;
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	java.sql.ResultSet rs = null;
	
	
	String strCollegeName  = null;//I have to find the college offering course.
	String strDegreeType   = null;
	String strReligion 	  = null;
	String strSpouse 	     = null;
	boolean bolPrintPageNo = true;
	
	int iRowStartFr = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_start_fr"), "0"));
	int iRowCount   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_count"), "0"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"), "0"));
   int iPageNumber = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_number"), "1"));
	
	int iStartCount = iPageNumber;
	if(iPageNumber == 1)
		iStartCount = 0;
	
	int iMaxRowToDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_page_to_disp"), "0"));	
   int iMaxCourseDisplay = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_course_disp"),"0"));
	String strTotalPageNumber = WI.fillTextValue("total_page");
	
	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<style type="text/css">

body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
	counter-reset: page <%=iStartCount%>;
}


td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	
	TABLE.thinborderTOPRIGHTBOTTOM {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	
	
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	 
	 TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	 
	 TD.thinborderTOPLEFT {
    border-top: solid 1px #000000;
	 border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	 
	 TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;
	 border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	 
	 TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
	 border-left: solid 1px #000000;
	 border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	 
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	 
	 TD.thinborderTOPLEFTRIGHT {
    border-left: solid 1px #000000;
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	 
	 TD.thinborderTOPBOTTOM {

    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	 
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
	 
    /*@media screen {
        div.divFooter {
            display: none;
        }
    }*/
    @media print {
        div.divFooter {
            position: fixed;
            bottom: 20px;
			width: 100%;				
        }
    }
	 
	 @page {
		size:8.50in 13in; 
		margin:.2in .2in .2in .2in; 
	}
	 
	 H5:after {
		 font-weight:normal;
		 content: "Page " counter(page);
		 counter-increment: page;
	}
	 
</style>

</head>
<body topmargin="0">


<%	
	
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
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> Error in opening connection</font></p>
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
enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();
CommonUtil commExtn = new CommonUtil();

Vector vStudInfo = null;
Vector vEntranceData = null;
Vector vAdditionalInfo = null;
Vector vRetResult = null;//this is otr detail info, i have to break it to pages,
Vector vSubGroupInfo = null;//this is having subject group information.
Vector vCurGroupInfo = null;
Vector vGraduationData = null;
Vector vCompliedRequirement = null;
Vector vReqList = null;
Vector vMulRemark = null;

int iLevelID = 0;
int iMulRemarkIndex = -1;
int iRowSpan = 0;
int iRowsPrinted = 0;
int iTemp =0;

String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};
String[] astrConvertSemUG  = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};
String[] astrConvertSemMED = {"SUMMER","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR","ACADEMIC YEAR"};
String[] astrConvertSemMAS = {"Summer","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER",""};
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};
String[] strTok = null; 

String strStudCourseToDisp = null; 
String strStudMajorToDisp = null;
String strSQLQuery = null;
String strCourseIndex = null;//this is the course selected. If no course is selected, I get from student info.. 
String strExtraCon = " and (";

boolean bolIsCareGiver = false;//if caregiver, i have to append hrs to the credit earned.
boolean bolPageBreak = false;
boolean viewAll = true;


Vector vCourseSelected = new Vector(); 



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



if(WI.fillTextValue("stud_id").length() > 0){
      vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	  if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
	  else {
		   strCollegeName = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(5));
		   if(strCollegeName != null)
		      strCollegeName = strCollegeName.toUpperCase();
			
		   vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(12));
		   if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			  strErrMsg = studInfo.getErrMsg();
			
		   strReligion = "select religion,spouse_name from info_personal where user_index = "+(String)vStudInfo.elementAt(12);
		   rs = dbOP.executeQuery(strReligion);
		    if(rs.next()){
				strReligion = rs.getString(1);
				strSpouse = rs.getString(2);
			}rs.close();
			
	   }
}   
  
///I have to update subject group here. 
	strSQLQuery = "select sg_index from SUB_GROUP_MAP_FORM19 where course_index_ = "+vStudInfo.elementAt(5);
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null) {
		strSQLQuery = "update SUBJECT_GROUP set GROUP_NAME = (select SG_NAME from SUB_GROUP_MAP_FORM19 where sg_index = GROUP_INDEX and course_index_ = "+ vStudInfo.elementAt(5)+")";
		dbOP.forceAutoCommitToFalse();
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}
///end of updating the group.. 
	
	
/*if(vStudInfo != null && vStudInfo.size() > 0) {
	   Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,WI.fillTextValue("stud_id"),(String)vStudInfo.elementAt(7),
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

//Vector vForm17Info = null;
//vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
//
//if(vForm17Info != null && vForm17Info.size() ==0)
//	vForm17Info = null;

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);

   if(vCourseSelected.size() > 0) {
	strTemp = "select degree_type from course_offered where course_index in ("+CommonUtil.convertVectorToCSV(vCourseSelected)+")";
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
   vEntranceData = eData.operateOnEntranceData(dbOP,request,4);	
   request.setAttribute("course_ref", strCourseIndex);
   vGraduationData = eData.operateOnGraduationData(dbOP,request,4);
  // if(vEntranceData == null || vGraduationData == null)
		
	if(vEntranceData == null)
		strErrMsg = eData.getErrMsg();
		
		

		
    vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true, strExtraCon);
	
    if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
	else	
		vMulRemark = (Vector)vRetResult.remove(0);
}

String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);
String strRLEHrs    = null;
String strCE        = null;

boolean bolIsRLEHrs = false;
boolean bolShowLecLabHr = false; String[] astrLecLabHr = null;//gets lec/lab hour information.
boolean bolIsMedTOR = strDegreeType.equals("2");

int iCredits = 0;
if(vRetResult.toString().indexOf("hrs") > 0 && WI.fillTextValue("show_rle").compareTo("1") == 0)
	bolIsRLEHrs = true;

if(WI.fillTextValue("show_leclab").compareTo("1") == 0)	
	bolShowLecLabHr = true;
 
Vector vInternshipInfo = repRegistrar.getInternshipInfo();
String strMulRemarkAtEndOfSYTerm = null;//if there is any remark added after the end of SY/term of Student.. 

//check if caregiver.. 
if(strStudCourseToDisp != null && strStudCourseToDisp.toLowerCase().equals("caregiver course"))
	bolIsCareGiver = true;
	
	//I have to get the subject group information as well.
	if(strErrMsg == null) {
		vSubGroupInfo = repRegistrar.getRecordsOfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType);
		if(vSubGroupInfo == null){
			strErrMsg = repRegistrar.getErrMsg();
			vSubGroupInfo = new Vector();
		}
		vCurGroupInfo = repRegistrar.getSubGroupUnitOfStud(dbOP, WI.fillTextValue("stud_id"),vSubGroupInfo);
		if(vCurGroupInfo == null)
			strErrMsg = eData.getErrMsg();
	}


dbOP.rollbackOP();
dbOP.forceAutoCommitToTrue();


strSQLQuery = "select SG_NAME from SUB_GROUP_MAP_FORM19 where course_index_ = "+vStudInfo.elementAt(5) + 
              " order by ORDER_NO";
rs = dbOP.executeQuery(strSQLQuery);

Vector vTemp = new Vector();
int iIndexOf =1;
while(rs.next()) {
	iIndexOf = vSubGroupInfo.indexOf(rs.getString(1));
	if(iIndexOf == -1)
		continue;
	vTemp.addElement(vSubGroupInfo.remove(iIndexOf));
	vTemp.addElement(vSubGroupInfo.remove(iIndexOf));
}
rs.close();

if(vTemp.size() > 0) {
	vTemp.insertElementAt(vSubGroupInfo.remove(0), 0);
	vSubGroupInfo = vTemp;
}

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

//I have to get addl number of groups.
int iAddlGroup =  0;
if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {
	iAddlGroup = vCurGroupInfo.size() / 2 - 10;
	if(iAddlGroup < 0)
		iAddlGroup = 0;
}
String strExpectedDate = "";
String strMonth = "";
String strYear = "";
String[] astrMonth = {"", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };

if(strErrMsg != null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	  <tr>
		<td><font size="3"><%=strErrMsg%></font> </td>
	  </tr>
	</table>
<%dbOP.cleanUP();return;}
 if(iPageNumber ==1){
 if(vAdditionalInfo != null) {
%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	  <tr>
		<td><font style="font-size:13px;" face="Courier New, Courier, monospace">(B. PR S Form No. 9)</font></td>
	  </tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	  <tr>
		<td>&nbsp;</td>
	  </tr>
	</table>
	<table  width="100%" border="0" cellspacing="0" cellpadding="0" onClick="PrintNextPage();">	  
	  <tr>
		<td colspan="2" align="center"><font style="font-size:17px;" face="Courier New, Courier, monospace"><strong>
				  <%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font>
				  <br><font style="font-size:15px;" face="Courier New, Courier, monospace">
				  TAGBILARAN CITY, BOHOL<br>
			<%=SchoolInformation.getInfo1(dbOP,false,false)%></font>
		</td>
	  </tr>	 
	  <tr>
		<td colspan="2">&nbsp;</td>
	  </tr>
	  <tr>
	   <td colspan="2" align="center"><font style="font-size:17px;" face="Courier New, Courier, monospace">
	   <strong>OFFICE OF THE REGISTRAR </strong></font></td></tr>
	  <tr>
		<td colspan="2">&nbsp;</td>
	  </tr>
	  <tr>
		<td width="70%"><strong><font style="font-size:16px;" face="Courier New, Courier, monospace">
		Official Transcript of Records</font></strong></td>
	  </tr>	 
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		 <td height="5" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td>
	  </tr>
	   <tr>
		 <td height="5" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td>
	  </tr>
	 
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" >
	  <tr>
		<td width="25%" height="23"><font face="Courier New, Courier, monospace" >NAME</font></td>
		<td width="36%"><font face="Courier New, Courier, monospace" >: <%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></font> </td>
		<td width="39%"><font face="Courier New, Courier, monospace" > <%=((String)vStudInfo.elementAt(24)).toUpperCase()%> 
		<%=WI.getStrValue((String)vStudInfo.elementAt(25)," Major in ","","").toUpperCase()%></font></td>
	  </tr>
	  <tr>
		<td height="23" ><font face="Courier New, Courier, monospace" >STUDENT #</font></td>
		<td colspan="2"><font face="Courier New, Courier, monospace" >: <%=WI.fillTextValue("stud_id").toUpperCase()%></font></td>
	  </tr>
	  <tr>
		<td height="23"><font face="Courier New, Courier, monospace" >ADDRESS</font></td>
		<td colspan="3"><font face="Courier New, Courier, monospace" >: 
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3)).toUpperCase()%> 
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","").toUpperCase()%> 
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","").toUpperCase()%> 
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(7)).toUpperCase()%></font> </td>
	  </tr>
	  <TR>
		<TD height="23"><font face="Courier New, Courier, monospace" >CITIZENSHIP</font></TD>
		<TD colspan="3"><font face="Courier New, Courier, monospace" >: 
		<%=WI.getStrValue((String)vStudInfo.elementAt(23), "&nbsp;").toUpperCase()%></font></TD>
	  </TR>
	  <tr>
		<td height="23"><font face="Courier New, Courier, monospace" >CIVIL STATUS</font></td>
		<td colspan="3"><font face="Courier New, Courier, monospace" >: 
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(12)).toUpperCase()%></font></td>
	  </tr>
<%      strTemp = (String)vStudInfo.elementAt(16);
		if(strTemp.equals("M"))
			strTemp = "MALE";
		else
			strTemp = "FEMALE";
%>
	  <tr>
		<td height="23"><font face="Courier New, Courier, monospace" >SEX</font></td>
		<td colspan="3"><font face="Courier New, Courier, monospace" >: <%=strTemp.toUpperCase()%></font></td>
	  </tr>
<%       if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
				strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1));
		 }else{
				strTemp = "&nbsp;";
		 }
%>
	  <tr>
		<td height="23"><font face="Courier New, Courier, monospace" >DATE OF BIRTH</font></td>
		<td colspan="3"><font face="Courier New, Courier, monospace" >: <%=strTemp.toUpperCase()%></font></td>
	  </tr>
<%       strTemp = "&nbsp;";
		 if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
			strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2));		
%>
	  <tr>
		<td height="23"><font face="Courier New, Courier, monospace" >RELIGION</font></td>
		<td colspan="3"><font face="Courier New, Courier, monospace" >:
		 <%=WI.getStrValue(strReligion).toUpperCase()%></font></td>
	  </tr>
	  <tr>
		<td height="23"><font face="Courier New, Courier, monospace" >FATHER</font></td>
		<td colspan="3"><font face="Courier New, Courier, monospace" >: 
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(8)).toUpperCase()%></font></td>
	  </tr>
	  <tr>
		<td height="23"><font face="Courier New, Courier, monospace" >MOTHER</font></td>
		<td colspan="3"><font face="Courier New, Courier, monospace" >: 
	    <%=WI.getStrValue((String)vAdditionalInfo.elementAt(9)).toUpperCase()%></font></td>
	  </tr>
	  <tr>
		<td height="23"><font face="Courier New, Courier, monospace" >SPOUSE</font></td>
		<td colspan="3"><font face="Courier New, Courier, monospace" >: 
		<%=WI.getStrValue(strSpouse).toUpperCase()%></font></td>
	  </tr>
	  <tr>
		<td colspan="3">&nbsp;</td>
	  </tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
	  <%
	  strTemp = WI.fillTextValue("date_grad");
	  
	  if(strTemp.length() > 0){
			
			strMonth = strTemp.substring(0, strTemp.indexOf("/"));
			strYear = strTemp.substring(strTemp.lastIndexOf("/")+1);
			
			if(Integer.parseInt(strMonth) > 0)
				strMonth = astrMonth[Integer.parseInt(strMonth)];
			
			strTemp = WI.getStrValue(strMonth) + ", "+WI.getStrValue(strYear);
		}
		
		strExpectedDate = strTemp;
	  %>
		<td height="19" colspan="9"><font face="Courier New, Courier, monospace" > 
		<%=WI.getStrValue((String)vStudInfo.elementAt(7)).toUpperCase()%> 
		( <%=((String)vStudInfo.elementAt(24)).toUpperCase()%> ) as of  <%=strExpectedDate%></font></td>
	  </tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		 <td height="1" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td>
	  </tr>
	  <tr> <td height="8" colspan="3"></td></tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="30%" height="20" align="center"><font face="Courier New, Courier, monospace" >
			Preliminary Education</font></td>
			<td height="20" align="center"><font face="Courier New, Courier, monospace" >Name of School</font></td>
			<td height="20" width="20%" align="center"><font face="Courier New, Courier, monospace" >SY Graduated</font></td>
		</tr>
		<tr> <td height="8" colspan="3"></td></tr>
		<tr>
		<td colspan="3" height="23"><font face="Courier New, Courier, monospace" >Primary :</font></td>
		</tr>
		<tr>
			<td height="23"><font face="Courier New, Courier, monospace" >Intermediate :</font></td>
<%       if(vEntranceData != null)
				strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
		 else	
				strTemp = "&nbsp;"; 
%>	
		
			<td><font face="Courier New, Courier, monospace" ><%=strTemp%></font></td>
			<td align="center"><font face="Courier New, Courier, monospace" >
			<%=(String)vEntranceData.elementAt(20)%></font></td>
		</tr>
		<tr>
			<td height="23"><font face="Courier New, Courier, monospace" >High School :</font></td>
			<td><font face="Courier New, Courier, monospace" ><%=(String)vEntranceData.elementAt(5)%> </font></td>
			<td align="center"><font face="Courier New, Courier, monospace" ><%=(String)vEntranceData.elementAt(22)%></font></td>
		</tr>
		<tr><td colspan="3" height="10"></td></tr>
		<tr><td height="1" colspan="3"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
		<tr><td colspan="3" height="10"></td></tr>	
	</table>
<% }//end vAdditionalinfo%>
	<table onMouseDown="return false" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr><td colspan="7" height="15"> <font face="Courier New, Courier, monospace" >Entrance Record: FORM 137-A</font>
		</td></tr>
		<tr><td colspan="7" height="18" align="center"><font face="Courier New, Courier, monospace" >GRADING SYSTEM</font>
		</td></tr>
		<tr>
			<td width="18%" height="25" align="center"> <font face="Courier New, Courier, monospace" >GRADING
			</font></td>
			<td width="15%"  align="center"><font face="Courier New, Courier, monospace" >EQUIVALENT</font></td>
			<td width="15%"  align="center"><font face="Courier New, Courier, monospace" >MEANING</font></td>
			<td width="17%" height="25" align="center" ><font face="Courier New, Courier, monospace" >GRADING
			</font></td>
			<td width="18%"  align="center"><font face="Courier New, Courier, monospace" >EQUIVALENT</font></td>
			<td width="17%" align="center"><font face="Courier New, Courier, monospace" >MEANING</font></td>
		</tr>
		
		<tr>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >1.0</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >100%</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >Excellent</font></td>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >2.2</font></td>
			<td width="18%" align="center"><font face="Courier New, Courier, monospace" >83-84%%</font></td>
			<td width="17%" align="center" rowspan="12">&nbsp;</td>
		</tr>
		<tr>
		<td height="20" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >1.1</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >99%</font></td>
			<td height="25" align="center" rowspan="5">&nbsp;</td>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >2.3</font></td>
			<td width="18%" align="center"><font face="Courier New, Courier, monospace" >82%</font></td>
			
		</tr>
		<tr>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >1.2</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >98%</font></td>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >2.4</font></td>
			<td width="18%" align="center"><font face="Courier New, Courier, monospace" >81%</font></td>
		</tr>
		<tr>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >1.3</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >97%</font></td>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >2.5</font></td>
			<td width="18%" align="center"><font face="Courier New, Courier, monospace" >80%</font></td>
		</tr>
		<tr>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >1.4</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >96%</font></td>
			<td height="25" align="center" colspan="2"></td>
		</tr>
		<tr>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >1.5</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >95%</font></td>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >2.6</font></td>
			<td width="18%" align="center"><font face="Courier New, Courier, monospace" >79%</font></td>
		</tr>
		<tr>
		<td height="20" colspan="3">&nbsp;</td>
		
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >2.7</font></td>
			<td width="18%" align="center"><font face="Courier New, Courier, monospace" >78%</font></td>
		</tr>
		<tr>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >1.6</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >94%</font></td>
			<td width="15%" align="center" rowspan="9">&nbsp;</td>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >2.8</font></td>
			<td width="18%" align="center"><font face="Courier New, Courier, monospace" >77%</font></td>
		</tr>
		<tr>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >1.7</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >93%</font></td>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >2.9</font></td>
			<td width="18%" align="center"><font face="Courier New, Courier, monospace" >76%</font></td>
		</tr>
		<tr>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >1.8</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >91-92%</font></td>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >3.0</font></td>
			<td width="18%" align="center"><font face="Courier New, Courier, monospace" >75%</font></td>
		</tr>
		<tr>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >1.9</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >89-90%</font></td>
			<td height="25" align="center"></td>
			<td height="25" colspan="1" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center"><font face="Courier New, Courier, monospace" >2.0</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >87-88%</font></td>
			<td width="17%" align="center"><font face="Courier New, Courier, monospace" >5</font></td>
			<td width="18%" align="center"><font face="Courier New, Courier, monospace" >74% and Below</font></td>
			<td width="17%" align="center"><font face="Courier New, Courier, monospace" >Failure</font></td>
			
	   </tr>
	   <tr>
			<td height="25" align="center" ><font face="Courier New, Courier, monospace" >2.1</font></td>
			<td width="15%" align="center"><font face="Courier New, Courier, monospace" >85-86%</font></td>
			<td width="17%" align="center"><font face="Courier New, Courier, monospace" >W</font></td>
			<td width="18%" align="center" rowspan="3">&nbsp;</td>
			<td width="17%" align="center"><font face="Courier New, Courier, monospace" >Withdrawn</font></td>
	   </tr>
	   <tr> 
			<td width="18%" align="center" rowspan="2">&nbsp;</td>
			<td width="15%" align="center" rowspan="2">&nbsp;</td>
			<td width="17%" height="24" align="center"><font face="Courier New, Courier, monospace" >NG</font></td>
			<td width="17%" align="center"><font face="Courier New, Courier, monospace" >No Grade</font></td>
	  </tr>
		<tr> 
			<td width="17%" height="21" align="center"><font face="Courier New, Courier, monospace" >DR</font></td>
			<td width="17%" align="center"><font face="Courier New, Courier, monospace" >Dropped</font></td>
		</tr>
		
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr><td colspan="7" height="20" class="thinborderBottom">&nbsp;</td></tr>
		<tr><td colspan="7" height="20">&nbsp;</td></tr>
		
		<tr>
			<td colspan="2">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">				
					<tr><td height="50"><font face="Courier New, Courier, monospace">NOT VALID<br>WITHOUT SEAL</font></td></tr>
				</table>			</td>
			<td width="37%">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" >
				<tr><td align="center" height="20"><font face="Courier New, Courier, monospace" >				
				<%=WI.getStrValue(WI.fillTextValue("registrar_name")).toUpperCase()%></font></td></tr>
				<tr><Td align="center" ><font face="Courier New, Courier, monospace" >
				Registrar</font></Td></tr>
			</table>			</td>
		</tr>
	</table>
	<div style="page-break-after:always">&nbsp;</div>
	<%} //end of iPageNumber==1%>
    
	
	<% 
	 if(vRetResult != null && vRetResult.size() > 0){
       int iNumWeeks = 0;
	   if (WI.fillTextValue("weeks").length() > 0) 
		   iNumWeeks = Integer.parseInt(WI.fillTextValue("weeks"));
    %>
	
<%

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

String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;

String strInternshipInfo = null;
String strGrade = null;

boolean bolIsSchNameNull    = false;
boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has 
boolean  bolPrinted = false; // print only once
boolean bolReExam = false;//if it is true, i have to set re-exam value.
				
double dSG1 =0d;	double dSG2 =0d;	double dSG3 =0d;	double dSG4 =0d;	double dSG5 =0d;
double dSG6 =0d;	double dSG7 =0d;	double dSG8 =0d;	double dSG9 =0d;	double dSG10 =0d;
double dSG11 =0d;	double dSG12 =0d;	double dSG13 =0d;	double dSG14 =0d;	double dTemp =0d;
				

//school name after it is null, it is encoded as cross enrollee.

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";


int iTitleLength    = 0;
int iTotalRowCount  = 67;
int iNumberRowCount = 0;
int iTitleRowCount  = 0;
int iCharPerLine  = 0;
int iOrgCharPerLine  = 22;
int iShowHeader = 0;
int iCurrentRow = 0;
bolPageBreak = false;

String strColSpan = "";

String strSubCode    = null;
Vector vMathEnglEnrichment = new enrollment.GradeSystem().getMathEngEnrichmentInfo(dbOP, request);
if(vMathEnglEnrichment == null)
	vMathEnglEnrichment = new Vector();


	if(WI.fillTextValue("addl_remark").length() > 0 && iLastPage == 1){
	
		iTemp = 1;
		strTemp = WI.fillTextValue("addl_remark");
		 iIndexOf = 0;
	
		while((iIndexOf = strTemp.indexOf("<br>",iIndexOf + 1)) != -1)
			++iTemp;
	
		 iMaxRowToDisp = iMaxRowToDisp - iTemp; 

	}

	if(vInternshipInfo == null)
		vInternshipInfo = new Vector();
		
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
		" and IS_CONFIRMED = 1 and user_index =  "+(String)vStudInfo.elementAt(12);
	java.sql.PreparedStatement pstmtEnrlCount = dbOP.getPreparedStatement(strTemp);
	
		

	for( int i=0; i < vRetResult.size(); ){
	
		iNumberRowCount = 0;
		if(bolPageBreak){bolPageBreak = false;%>
			<div style="page-break-after:always;">&nbsp;</div>
<%		}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%	
		for( iShowHeader = 0; i < vRetResult.size(); i += 11, ++iCurrentRow, iShowHeader++){		
		
		
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
				
				vRetResult.setElementAt("("+dGrade+")",i + 8);
			}
			catch(Exception e){
				vRetResult.setElementAt("(0.0)",i + 9);
			}
		}
		
		
//			
	    //I have to now check if this subject is having RLE hours. 
		if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && 
		   ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 &&
			vRetResult.elementAt(i + 6) != null && vRetResult.elementAt(i + 6 + 11) != null && 
			((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
			((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
			((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
			WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0)        {   //semester
				strTemp  = (String)vRetResult.elementAt(i + 9 + 11);
				strGrade = (String)vRetResult.elementAt(i + 8 + 11);
				
				bolReExam = true;
				i += 11; 
		}
		else {
			bolReExam = false;
			strTemp  = (String)vRetResult.elementAt(i + 9);
			strGrade = (String)vRetResult.elementAt(i + 8);
		}
		
		strCE  = strTemp;
		
		if (strCE!= null && strCE.equals("0") && 
		    WI.getStrValue((String)vRetResult.elementAt(i + 8),"").toLowerCase().equals("drp")) {
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
		if(vRetResult.elementAt(i) == null)
			bolIsSchNameNull = true;
	   
	    /*if(strSchoolName != null) {
			if(strPrevSchName == null) {
				strPrevSchName = strSchoolName ;
				strSchNameToDisp = strSchoolName;
			}
			else if(strPrevSchName.compareTo(strSchoolName) ==0) {      
			
				strPrevSchName = strSchoolName;
				strSchNameToDisp = null;
			}
			else { // it is having a new school name
				strPrevSchName = strSchoolName;
				strSchNameToDisp = strSchoolName; 
			}
		}
		
		
		
		// if prev school name is not null, show the current shcoll name			
		if(strSchoolName == null && strPrevSchName != null)    {
			strSchNameToDisp = strCurrentSchoolName;
			strPrevSchName = null;
		}*/
		
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
	    } // end of vRetResult.elementAt(i+ 3) != null
	
	
		if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//cross enrolled.
			if(strCrossEnrolleeSchPrev == null || strCrossEnrolleeSchPrev.compareTo(strSchoolName) != 0)           {

				strCrossEnrolleeSchPrev = strSchoolName;
				strCrossEnrolleeSch     = strSchoolName; 
				strSYToDisp = strCurSY;
				strSemToDisp = strCurSem;			
				strSchNameToDisp = strSchoolName;
			}
		}
		
		bolCrossEnrolled = false;
		if(vRetResult.elementAt(i) != null && bolIsSchNameNull) { //cross enrolled.. 
			strSYToDisp = null;
			strSemToDisp = null;	
			
			/**
			need to check if there are no other subject enrolled is same sy-term.
			if there is , its cross enrolled
			else	PERMIT TO STUDY
			
			strCurSem = (String)vRetResult.elementAt(i+ 3);
				strCurSY  = (String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);
			**/
			pstmtEnrlCount.setString(1, (String)vRetResult.elementAt(i+ 1));
			pstmtEnrlCount.setString(2, (String)vRetResult.elementAt(i+ 3));
			rs = pstmtEnrlCount.executeQuery();
			rs.next();
			if(rs.getInt(1) > 0)
				strTemp = "CROSS ENROLLED";				
			else
				strTemp = "PERMIT TO STUDY";
			rs.close();
			
			strSchNameToDisp = strSchNameToDisp + "<br>"+strCurSY+" "+strCurSem+" ("+strTemp+")";
			bolCrossEnrolled = true;
		}
	
	   //get here index of group .
		strTemp = (String)vRetResult.elementAt(i+ 9);
		if(strTemp != null) {
			iIndexOfSubGroup = strTemp.indexOf("(");
			if(iIndexOfSubGroup != -1) {
				strTemp = strTemp.substring(0, iIndexOfSubGroup);
			}
		}
		
				iIndexOfSubGroup = vSubGroupInfo.indexOf(vRetResult.elementAt(i+ 10));
				if (iIndexOfSubGroup != -1)
					iIndexOfSubGroup = iIndexOfSubGroup/2 + 1;
		
		try{
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		}catch(NumberFormatException nfe){
		dTemp = 0d;
		}
		if(iIndexOfSubGroup == 1)  dSG1  += dTemp;	if(iIndexOfSubGroup == 2)  dSG2  += dTemp;
		if(iIndexOfSubGroup == 3)  dSG3  += dTemp;	if(iIndexOfSubGroup == 4)  dSG4  += dTemp;
		if(iIndexOfSubGroup == 5)  dSG5  += dTemp;	if(iIndexOfSubGroup == 6)  dSG6  += dTemp;
		if(iIndexOfSubGroup == 7)  dSG7  += dTemp;	if(iIndexOfSubGroup == 8)  dSG8  += dTemp;
		if(iIndexOfSubGroup == 9)  dSG9  += dTemp;	if(iIndexOfSubGroup == 10) dSG10 += dTemp;
		if(iIndexOfSubGroup == 11) dSG11 += dTemp;	if(iIndexOfSubGroup == 12) dSG12 += dTemp;
		if(iIndexOfSubGroup == 13) dSG13 += dTemp;	if(iIndexOfSubGroup == 14) dSG14 += dTemp;
		 
	
		//check internship Info.. 
		strInternshipInfo = null;
		iTemp =0;
	    if(vInternshipInfo.size() > 0) {
		    iTemp = ((Integer)vInternshipInfo.elementAt(0)).intValue();
		    if(iTemp == i) {
				strInternshipInfo = (String)vInternshipInfo.remove(1);
				vInternshipInfo.remove(0);
			}
		    else if(iTemp == i + 11) {//may be inc
				if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && 
				   vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null && 
					((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
					((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
					((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
					WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(
					vRetResult.elementAt(i + 3 + 11),"1")) == 0){ //semester
						strInternshipInfo = (String)vInternshipInfo.remove(1);
						vInternshipInfo.remove(0);
				 }
			}
	     }			
		
			strColSpan = "";
			iCharPerLine = iOrgCharPerLine;
			iTemp = WI.getStrValue(strGrade).length();
			if(iTemp > 5){
				strColSpan = "colspan='2'";
			}	
		
			//iTitleLength = WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;").length();			
			
			iTitleRowCount = commExtn.getLineCount((String)vRetResult.elementAt(i + 7), iCharPerLine);
			
			//sub code sometimes makes 2 lines, I have to compare
			iTemp = commExtn.getLineCount(WI.getStrValue(vRetResult.elementAt(i + 6)), 11);
			
			if(iTemp > iTitleRowCount)
				iTitleRowCount = iTemp;
				
			
				
			iNumberRowCount+=iTitleRowCount;
			
			if( i +11 >= vRetResult.size())
				iNumberRowCount+=2;
			
			if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp))))
				++iNumberRowCount;
			
			if( strSYToDisp != null && strSemToDisp != null && i > 0)
				iNumberRowCount+=2;
			
			if(strSYToDisp != null && strSemToDisp != null)
				++iNumberRowCount;
			
			if(vMulRemark != null && vMulRemark.size() > 0){
				iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
				if(iMulRemarkIndex == i){
					iTitleRowCount = comUtil.getLineCount(ConversionTable.replaceString((String)vMulRemark.elementAt(1),"\n","<br>"), 46);
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
		
	 
		//if(iLastPage == 0 || (iLastPage == 1 && iRowCount > 0)) 
		if(iShowHeader == 0){
	%>
	
		
		<tr>
		 <td height="7" colspan="<%=iAddlGroup+16%>" valign="top">
		 		<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="7%" height="23"><font face="Courier New, Courier, monospace" >NAME:</font></td>
						<td width="36%"><font face="Courier New, Courier, monospace" ><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
						<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
					  <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></font> </td>
						<td width="57%"><font face="Courier New, Courier, monospace" > <%=((String)vStudInfo.elementAt(24)).toUpperCase()%> 
						<%=WI.getStrValue((String)vStudInfo.elementAt(25)," Major in ","","").toUpperCase()%></font></td>
				   </tr>
			 </table>		 </td>
	  </tr>
	   <tr>
		 <td height="7" colspan="<%=iAddlGroup+16%>"><div style="border-bottom:solid 1px #000000;"></div></td>
	  </tr>	   
		  <tr>
			<td width="14%" align="center" class="thinborderTOPBOTTOM"><font face="Courier New, Courier, monospace" >Course No.</font></td>
			<td colspan="2" align="center" class="thinborderTOPBOTTOM"><font face="Courier New, Courier, monospace" >Descriptive Title</font></td>
			<td width="7%" align="center"  class="thinborderTOPBOTTOM"><font face="Courier New, Courier, monospace" >RATING</font></td>
			<td width="7%" align="center" class="thinborderTOPBOTTOM"><font face="Courier New, Courier, monospace" >RE-EX</font></td>
			<td width="7%" align="center" class="thinborderTOPBOTTOM"><font face="Courier New, Courier, monospace" >CREDIT</font></td>            
			<td width="4%" class="thinborderTOPLEFTBOTTOM"><font face="Courier New, Courier, monospace" ><div align="center">1</div></font></td>
			<td width="4%" class="thinborderTOPLEFTBOTTOM"><font face="Courier New, Courier, monospace" ><div align="center">2</div></font></td>
			<td width="4%" class="thinborderTOPLEFTBOTTOM"><font face="Courier New, Courier, monospace" ><div align="center">3</div></font></td>
			<td width="4%" class="thinborderTOPLEFTBOTTOM"><font face="Courier New, Courier, monospace" ><div align="center">4</div></font></td>
			<td width="4%" class="thinborderTOPLEFTBOTTOM"><font face="Courier New, Courier, monospace" ><div align="center">5</div></font></td>
			<td width="4%" class="thinborderTOPLEFTBOTTOM"><font face="Courier New, Courier, monospace" ><div align="center">6</div></font></td>
			<td width="4%" class="thinborderTOPLEFTBOTTOM"><font face="Courier New, Courier, monospace" ><div align="center">7</div></font></td>
			<td width="4%" class="thinborderTOPLEFTBOTTOM"><font face="Courier New, Courier, monospace" ><div align="center">8</div></font></td>
			<td width="4%" class="thinborderTOPLEFTBOTTOM"><font face="Courier New, Courier, monospace" ><div align="center">9</div></font></td>
			<%
			strTemp = "thinborderALL";			
			if(iAddlGroup > 0)
				strTemp = "thinborderTOPLEFTBOTTOM";
			%>
			<td width="4%" class="<%=strTemp%>"><font face="Courier New, Courier, monospace" ><div align="center">10</div></font></td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td width="4%" class="thinborderALL"><font face="Courier New, Courier, monospace" ><div align="center"><%=(10 + j + 1)%></div></font></td>
			<%}%>
		  </tr>
<%}// end of iLastPage == 0 || (iLastPage == 1 && iRowCount > 0)	

	//Very important here, it print <!-- if it is not to be shown.
		 //if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
		 <%//=strHideRowLHS%>
<%       //}%>


<%if( strSYToDisp != null && strSemToDisp != null && i > 0){
	//iNumberRowCount+=2;
%>	 
		<tr> 
			<td height="14">&nbsp;</td>
			<td colspan="5"><font face="Courier New, Courier, monospace" >FLP &nbsp;&nbsp;_____ NO.:  _____</font></td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFTRIGHT" align="center">&nbsp;</td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td class="thinborderRIGHT" align="center">&nbsp;</td>
			<%}%>
		</tr>
		<tr> 
			<td height="14">&nbsp;</td>
			<td colspan="5"><font face="Courier New, Courier, monospace" >F19P:  _____ NO.:  _____</font></td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFTRIGHT" align="center">&nbsp;</td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td class="thinborderRIGHT" align="center">&nbsp;</td>
			<%}%>
		</tr>
<%}
	
	
if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		iMulRemarkCount += 3;%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" align="center"> <%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></td>
	 <td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFTRIGHT" align="center">&nbsp;</td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td class="thinborderRIGHT" align="center">&nbsp;</td>
			<%}%>
  </tr>
  <%}//end of if
}//end of vMulRemark.	
	
	
	 //need to remember
//if(strSYToDisp != null && strSemToDisp != null)
if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){	
			 ++iRowsPrinted;
%>
   
	
      <tr bgcolor="#FFFFFF">
	    <td colspan="6"><label id="<%=++iLevelID%>"><font face="Courier New, Courier, monospace" ><%=WI.getStrValue(strSchNameToDisp)%></font></label></td>
	      <td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFTRIGHT" align="center">&nbsp;</td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td class="thinborderRIGHT" align="center">&nbsp;</td>
			<%}%>
      </tr>
<%strPrevSchName = strSchNameToDisp;}	
	

if( strSYToDisp != null && strSemToDisp != null){	
	++iRowsPrinted;	     
	if(bolIsCareGiver && vEntranceData.elementAt(27) != null)
		strTemp = strSemToDisp +", "+ ((String)vEntranceData.elementAt(27)).toUpperCase();
	else
		strTemp = strSemToDisp +", "+ strSYToDisp;
%>
      <tr bgcolor="#FFFFFF">
	    <td colspan="6"><label id="<%=++iLevelID%>"><font face="Courier New, Courier, monospace" ><%=strTemp%></font></label></td>
	        <td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFTRIGHT" align="center">&nbsp;</td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td class="thinborderRIGHT" align="center">&nbsp;</td>
			<%}%>
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
			strGrade = strGrade;
	}
	
	if(bolIsCareGiver && strCE.length() > 0) 
		strCE = strCE + "hrs";
	if(strCE.length() > 0 && strCE.indexOf(".") == -1)
		strCE=strCE.trim()+".0";	

//it is re-exam if student has INC and cleared in same semester,
	strTemp = "";
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && vRetResult.elementAt(i + 6) != null  && 
	    vRetResult.elementAt(i + 6 + 11) != null && 
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester			
      strTemp = (String)vRetResult.elementAt(i + 8 + 11);
	  	i += 11;
     }
%>

		
	  <tr bgcolor="#FFFFFF">
        <td valign="top" height="14" style="padding-left:8px;"><font face="Courier New, Courier, monospace" ><%=WI.getStrValue(vRetResult.elementAt(i + 6))%></font></td>
        <td colspan="2" valign="top"><label id="<%=++iLevelID%>" ><font face="Courier New, Courier, monospace" >
	  		  <%=WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;")%></font> </label></td>
		<%
		if(bolCrossEnrolled){			
			try{
			
			
			if(strGrade != null && strGrade.length() > 0 && Double.parseDouble(strGrade) == 0){
				strTemp = "&nbsp;";
				strGrade = "&nbsp;";
				strCE = "&nbsp;";
			}
			
			}catch(Exception e){
			
			}		
		}
		%>
        <td valign="top" align="center" <%=strColSpan%>><label id="<%=++iLevelID%>"><font face="Courier New, Courier, monospace" ><%=strGrade%></font></label></td>
		<%if(strColSpan.length() == 0){%>
        <td valign="top" align="center"><label id="<%=++iLevelID%>"><font face="Courier New, Courier, monospace" ><%=WI.getStrValue(strTemp)%></font></label></td><%}%>
        <td valign="top" align="center"><font face="Courier New, Courier, monospace" ><%=strCE%></font></td>
		  
		  
<%        if(bolReExam) 
              strTemp = (String) vRetResult.elementAt(i - 11 + 9);
		  	else 
		        strTemp = (String)vRetResult.elementAt(i + 9);
				  
			//they want the column clean
			strTemp = "&nbsp;";
%>
				  <td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 1){%><%=WI.getStrValue(strTemp, "&nbsp;")%> <%}%></td>
				  <td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 2){%><%=WI.getStrValue(strTemp, "&nbsp;")%> <%}%></td>
				  <td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 3){%><%=WI.getStrValue(strTemp, "&nbsp;")%> <%}%></td>
				  <td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 4){%><%=WI.getStrValue(strTemp, "&nbsp;")%> <%}%></td>
				  <td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 5){%><%=WI.getStrValue(strTemp, "&nbsp;")%> <%}%></td>
				  <td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 6){%><%=WI.getStrValue(strTemp, "&nbsp;")%> <%}%></td>
				  <td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 7){%><%=WI.getStrValue(strTemp, "&nbsp;")%> <%}%></td>
				  <td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 8){%><%=WI.getStrValue(strTemp, "&nbsp;")%> <%}%></td>
				  <td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 9){%><%=WI.getStrValue(strTemp, "&nbsp;")%> <%}%></td>
				  <td class="thinborderLEFTRIGHT" align="center">&nbsp; <%if(iIndexOfSubGroup == 10){%><%=WI.getStrValue(strTemp, "&nbsp;")%> <%}%></td>
				  <%for(int j = 0; j < iAddlGroup; ++j) {%>
					  <td class="thinborderRIGHT" align="center">&nbsp;
						  <%if(iIndexOfSubGroup == (12 + j + 1)){%><%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%><%}%>		            </td>
				  <%}%>
      </tr>
	  
<%  
if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		iMulRemarkCount += 3;%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" align="center"> <%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></td>
	 <td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFTRIGHT" align="center">&nbsp;</td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td class="thinborderRIGHT" align="center">&nbsp;</td>
			<%}%>
  </tr>
  <%}//end of if
}//end of vMulRemark.
		 
if( i +11 >= vRetResult.size()){
	//iNumberRowCount +=2;
%>	 
		<tr> 
			<td height="14">&nbsp;</td>
			<td colspan="5"><font face="Courier New, Courier, monospace" >FLP &nbsp;&nbsp;_____ NO.:  _____</font></td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFTRIGHT" align="center">&nbsp;</td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td class="thinborderRIGHT" align="center">&nbsp;</td>
			<%}%>
		</tr>
		<tr> 
			<td height="14">&nbsp;</td>
			<td colspan="5"><font face="Courier New, Courier, monospace" >F19P:  _____ NO.:  _____</font></td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFTRIGHT" align="center">&nbsp;</td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td class="thinborderRIGHT" align="center">&nbsp;</td>
			<%}%>
		</tr>
		
<%
	if(vMulRemark != null && vMulRemark.size() > 0) {	
		vMulRemark.removeElementAt(0);%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6" align="center"> <%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></td>
	 <td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFTRIGHT" align="center">&nbsp;</td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td class="thinborderRIGHT" align="center">&nbsp;</td>
			<%}%>
  </tr>
  <%
}//end of vMulRemark.
		
}%>			 
		 
			  
	  <% //if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
	  <%//=strHideRowRHS%>
	  <%//} 
	}	//end of inner for loop%>
	
	
	<%
	if(iNumberRowCount < iTotalRowCount){
		for(int k = iNumberRowCount+ 4; k < iTotalRowCount; k++ ){
	%>
		<tr> 
			<td height="14" colspan="6">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFTRIGHT" align="center">&nbsp;</td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td class="thinborderRIGHT" align="center">&nbsp;</td>
			<%}%>
		</tr>
		<%}
	}%>
	</table>
<%}//end of outer for loop  %>



<%//if(iLastPage == 1){%>

<div style="page-break-after:always">&nbsp;</div>

<table width="100%" border="0" cellpadding="0" cellspacing="0">



<% 
  if(vSubGroupInfo != null && vSubGroupInfo.size() > 0) {	
  
 String strClass = "thinborderLEFTRIGHT";
 if(iAddlGroup > 0)
 	strClass = "thinborderLEFT";
  
%>
		<tr>
			<td width="14%" align="center" class="thinborderTOP">&nbsp;</td>
			<td width="26%" align="right" class="thinborderTOP">&nbsp;</td> 
			<td colspan="2" align="center" class="thinborderTOP"><font face="Courier New, Courier, monospace" >Units Required</font></td>					
			<td width="4%" rowspan="2" align="center" class="thinborderTOPLEFT">&nbsp;</td>
			<td width="4%" rowspan="2" align="center" class="thinborderTOPLEFT">&nbsp;</td>
			<td width="4%" rowspan="2" align="center" class="thinborderTOPLEFT">&nbsp;</td>
			<td width="4%" rowspan="2" align="center" class="thinborderTOPLEFT">&nbsp;</td>
			<td width="4%" rowspan="2" align="center" class="thinborderTOPLEFT">&nbsp;</td>
			<td width="4%" rowspan="2" align="center" class="thinborderTOPLEFT">&nbsp;</td>
			<td width="4%" rowspan="2" align="center" class="thinborderTOPLEFT">&nbsp;</td>
			<td width="4%" rowspan="2" align="center" class="thinborderTOPLEFT">&nbsp;</td>
			<td width="4%" rowspan="2" align="center" class="thinborderTOPLEFT">&nbsp;</td>
			<%
			strTemp = "thinborderTOPLEFTRIGHT";
			if(iAddlGroup > 0)
			strTemp = "thinborderTOPLEFT";
			%>
			<td width="4%" rowspan="2" align="center" class="<%=strTemp%>">&nbsp;</td>	
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
				<td width="4%" class="thinborderTOPLEFTRIGHT" rowspan="8" align="center">&nbsp;</td>
			<%}%>		
		</tr>
		<tr>
			<td colspan="4" style="padding-left:50px;" align="left"><font face="Courier New, Courier, monospace" >SUMMARY</font></td>
		</tr>
	  <% 
	  String[] astrNumber = {"I.","II.","III.","IV.","V.",
	                         "VI.","VII.","VIII.","IX.","X.","XI.","XII.","XIII.","XIV.","XV.","XVI.","XVII","XVIII","XIX","XX"};
	  
	  String strTotalSubGroup = (String)vSubGroupInfo.remove(0);
	  int iCount = 0;
	  for(int i=0; i<vSubGroupInfo.size(); i+=2,iCount++){
	  strTemp = (String)vSubGroupInfo.elementAt(i+1);
	  iIndexOf = strTemp.indexOf(".0");
		if(iIndexOf > -1)
			strTemp = strTemp+"0";
	  %>
		<tr>		
			<td colspan="2" valign="top">
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="10%"><font face="Courier New, Courier, monospace" ><%=astrNumber[iCount]%></font></td>
						<td width="90%"><font face="Courier New, Courier, monospace" ><%=(String)vSubGroupInfo.elementAt(i)%></font></td>
					</tr>
				</table>
			
			</td>
			<td colspan="2" valign="top"><font face="Courier New, Courier, monospace" >&nbsp;</font></td>
			
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>		
			<td class="<%=strClass%>" align="center">&nbsp;</td>
		</tr>
	  <%} //end of vSubGroupInfo loop%> 
	  
	  
	  
	  
	  
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td class="thinborderTOP">&nbsp;</td>
			<td class="thinborderTOP">&nbsp;</td>
			
			
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="thinborderLEFT" align="center">&nbsp;</td>
			<td class="<%=strClass%>" align="center">&nbsp;</td>
		</tr>  
	  <tr><td height="36" colspan="4"><font face="Courier New, Courier, monospace" >Totals</font></td>
	  <td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="<%=strClass%>" align="center">&nbsp;</td>
	  </tr>
	  <tr><td colspan="4"><font face="Courier New, Courier, monospace" >Units Required</font><font face="Courier New, Courier, monospace" ></font><font face="Courier New, Courier, monospace" ></font></td>
	  <td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="<%=strClass%>" align="center">&nbsp;</td>
	  </tr>
	  <tr><td colspan="4"><font face="Courier New, Courier, monospace" >Units Earned</font><font face="Courier New, Courier, monospace" >&nbsp;</font><font face="Courier New, Courier, monospace" >&nbsp;</font></td>
	  <td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="thinborderLEFT" align="center">&nbsp;</td>
		<td class="<%=strClass%>" align="center">&nbsp;</td>
	  </tr>
	  
	  
	  <tr>
	  <td colspan="4" class="thinborderBOTTOM"><font face="Courier New, Courier, monospace" >Totals Units</font><font face="Courier New, Courier, monospace" ></font><font face="Courier New, Courier, monospace" ></font></td>  
	  <td class="thinborderBOTTOMLEFT" align="center">&nbsp;</td>
		<td class="thinborderBOTTOMLEFT" align="center">&nbsp;</td>
		<td class="thinborderBOTTOMLEFT" align="center">&nbsp;</td>
		<td class="thinborderBOTTOMLEFT" align="center">&nbsp;</td>
		<td class="thinborderBOTTOMLEFT" align="center">&nbsp;</td>
		<td class="thinborderBOTTOMLEFT" align="center">&nbsp;</td>
		<td class="thinborderBOTTOMLEFT" align="center">&nbsp;</td>
		<td class="thinborderBOTTOMLEFT" align="center">&nbsp;</td>
		<td class="thinborderBOTTOMLEFT" align="center">&nbsp;</td>
		<%		
		strTemp = "thinborderBOTTOMLEFTRIGHT";
		if(iAddlGroup > 0)
			strTemp = "thinborderBOTTOMLEFT";
		
		%>
		<td class="<%=strTemp%>" align="center">&nbsp;</td>
	  </tr>
	  <%} //end of vSubGroupInfo != null && vSubGroupInfo.size() > 0%>

		<tr>
			<td colspan="51" valign="top">
				
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
				 <tr><td colspan="5"> <font face="Courier New, Courier, monospace" >Remarks: </font></td></tr>
				  <tr>
					<td colspan="5"><font face="Courier New, Courier, monospace" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I HEREBY CERTIFY that the foregoing record of <%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%> a candidate for graduation. 
					  Has been verified by me and true copies of the official records substaining the same are kept on file in this office.
					  </font></td>
				  </tr>
				  <tr>
					<td colspan="5">&nbsp;</td></tr>
				  <tr>
					<td colspan="5">&nbsp;</td>
				  </tr>
				  <tr>
				  
					<td><font face="Courier New, Courier, monospace" >Date: <%=WI.getStrValue(strExpectedDate)%></font></td>
					<td><font face="Courier New, Courier, monospace" ></font></td>
					<td align="center"><font face="Courier New, Courier, monospace" >
					<%=WI.getStrValue(WI.fillTextValue("registrar_name")).toUpperCase()%></font></td>
				  </tr>
				  <tr>
					<td colspan="2">&nbsp;</td>
					<td align="center" ><font face="Courier New, Courier, monospace" >Registrar</font></td>
				  </tr>
			</table>			
			</td>
		</tr>
</table>
<%//}%>
	


<!---DO NOT DELETE THIS IS IS THE PAGE NUMBER --->
<div class="divFooter">
	<div style="border-bottom: solid 1px #000000; margin-top:1%; float:left; width:45%;">&nbsp;</div>	
	<div style="float:left; width:10%; text-align:center;"><H5></H5></div>
	<div style="border-bottom: solid 1px #000000; margin-top:1%; float:left; width:45%;">&nbsp;</div>
</div>

<%
 }//end if vRetResult != null && vRetResult.size() > 0%>
<%if(WI.fillTextValue("print_").compareTo("1") == 0 ){%>
<script language="javascript">
 window.print();
</script>
<%}//print only if print page is clicked.%>

</body>
</html>
<%
dbOP.cleanUP();
%>
