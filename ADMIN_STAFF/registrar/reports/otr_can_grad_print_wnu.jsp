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
    TD.thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	 TD.thinborderTOPRIGHT {
	 border-top: solid 1px #000000;
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
    TD.thinborderTOPBOTTOMRIGHT {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTBOTTOMRIGHT {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
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
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<script language="javascript">
function ChangeUnivCollege() {
	var obj = document.getElementById('univ_');
	var labelVal = obj.innerHTML;
	
	if(labelVal.indexOf('University') > -1)
		obj.innerHTML = '<font size="5">West Negros College </font>';
	else	
		obj.innerHTML = '<font size="5">West Negros University</font><br> <strong>(Formerly West Negros College)</strong>';
}
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
//
function UpdateGrpRequirement(strLabelID, strGroupNo) {
	strNewVal= prompt('Enter New Value. -1 to delete manaully encoded data','');
	if(strNewVal == null)
		return;
	if(strNewVal.length == 0) {
		alert('Please enter New Value.');
		return;
	}
	
	//call ajax here.
	var objCOAInput = document.getElementById(strLabelID);
	this.InitXmlHttpObject(objCOAInput, 2);
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=121&student_=<%=WI.fillTextValue("stud_id")%>&group="+strGroupNo+"&new_val="+strNewVal;
	//alert(strURL);
	this.processRequest(strURL);	
}
</script>
<%
	String strErrMsg = null;
	String strTemp = null;
	String strDegreeType = null;
	java.sql.ResultSet rs = null;
	
	int iRowStartFr = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_start_fr"), "0"));
	int iRowCount   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_count"), "0"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"), "0"));

	String strPrintPage = WI.fillTextValue("print_");//"1" is print. 

////////////////////////// to insert blank lines if TOR is not complete page.
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_page_to_disp"), "0"));
//////////////////////////

	int iPageNumber = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_number"), "0"));
	String strTotalPageNumber = WI.fillTextValue("total_page");

	//copied from AUF for print all page setting.. 
	String strPrintValueCSV = "";
	//System.out.println(WI.fillTextValue("print_all_pages"));
	if(WI.fillTextValue("print_all_pages").equals("1")) { //print all page called.
		strPrintValueCSV = WI.fillTextValue("print_value_csv");
		if(strPrintValueCSV.length() == 0) {
			strErrMsg = "End of printing. This error must not occur.";%>
			<%=strErrMsg%>
		<%	return;
		} 
		Vector vPrintVal = CommonUtil.convertCSVToVector(strPrintValueCSV);//[0] row_start_fr, [1] row_count, [2] last_page, [3] page_number, [4] max_page_to_disp, 
		//System.out.println(vPrintVal);
		iRowStartFr   = Integer.parseInt((String)vPrintVal.remove(0));
	    iRowCount     = Integer.parseInt((String)vPrintVal.remove(0));
		iRowEndsAt    = iRowStartFr + iRowCount;
		iLastPage     = Integer.parseInt((String)vPrintVal.remove(0));
		strPrintPage  = "1";//"1" is print. 
		
		iPageNumber   = Integer.parseInt((String)vPrintVal.remove(0));
		iMaxRowToDisp = Integer.parseInt((String)vPrintVal.remove(0));
		
		if(vPrintVal.size() == 0)
			strPrintValueCSV = "";
		else	
			strPrintValueCSV = CommonUtil.convertVectorToCSV(vPrintVal);
	}

//System.out.println(strPrintValueCSV);

	boolean bolIsEndOfContent = false;//this indicates there is still one more page to print but already done printing data.
	if(iLastPage == 0 && (iMaxRowToDisp > iRowCount))
		bolIsEndOfContent = true;
	else if(iLastPage == 1 && iRowCount == 0) 
		bolIsEndOfContent = false;
	else if(iLastPage == 1)
		bolIsEndOfContent = true;
	

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
student.StudentInfo studInfo = new student.StudentInfo();

Vector vApprenticeInfo = new Vector();
Vector vStudInfo = null;
Vector vEntranceData = null;
Vector vAdditionalInfo = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};

Vector vRetResult = null;//this is otr detail info, i have to break it to pages,
Vector vSubGroupInfo = null;//this is having subject group information.
Vector vCurGroupInfo = null;

String strSQLQuery = null; 

Vector vMulRemark = null; String strCol1, strCol2 = null;int iMulRemarkCount=0;
int iMulRemarkIndex = -1;

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

if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else {

		////////////// added.
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
					vStudInfo.setElementAt(strCourseIndex, 5);
				}
		
			}
			if(strStudCourseToDisp == null) {
				strStudCourseToDisp = (String)vStudInfo.elementAt(7);
				strStudMajorToDisp  = (String)vStudInfo.elementAt(8);
				strCourseIndex      = (String)vStudInfo.elementAt(5);
			}
		
		
		////////////// end of added code.. 	
	
		//forward different page if this is masteral.. 
		if(strDegreeType.equals("1")) {
			dbOP.cleanUP();
		%>
			<jsp:forward page="./otr_can_grad_print_wnu_masteral.jsp"/>
		
		<%return;}
	
		
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

		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
		vEntranceData = eData.operateOnEntranceData(dbOP, request,4);
		if(vEntranceData == null)
			strErrMsg = eData.getErrMsg();
	}
	if(strErrMsg == null) {//get the grad detail.
		vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true);
		if(vRetResult == null)
			strErrMsg = repRegistrar.getErrMsg();
		else{
			vMulRemark = (Vector)vRetResult.remove(0);
			enrollment.ReportRegistrarExtnWNU rprtReg = new enrollment.ReportRegistrarExtnWNU();
			vApprenticeInfo = rprtReg.operateOnApprenticeInfoWNU(dbOP, request, 4, (String)vStudInfo.elementAt(12), true);
			if(vApprenticeInfo == null)
				vApprenticeInfo = new Vector();
		}
			
		//System.out.println(vMulRemark);	

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
Vector vStudSubGroup = null;
if(vStudInfo != null) {
	vStudSubGroup = repRegistrar.getStudentSubGroupInfo(dbOP, (String)vStudInfo.elementAt(12), request);
	if(vStudSubGroup == null) {
		vStudSubGroup = new Vector();
		strErrMsg = repRegistrar.getErrMsg();
	}
}

//required units and group name.. ..
String[] astrGroupReq = new String[10];
String[] astrGroupName = new String[10];
//units completed.. 
double dSG1 =0d;	double dSG2 =0d;	double dSG3 =0d;	double dSG4 =0d;	double dSG5 =0d;
double dSG6 =0d;	double dSG7 =0d;	double dSG8 =0d;	double dSG9 =0d;	double dSG10 =0d;
double dSG11 =0d;	double dSG12 =0d;	double dSG13 =0d;	double dSG14 =0d;	double dTemp =0d;

Vector vEnrichmentSubjects = new enrollment.GradeSystem().getEnrichmentSubject(dbOP);
if(vEnrichmentSubjects == null)
	vEnrichmentSubjects = new Vector();

//System.out.println(" vEnrichmentSubjects : "+vEnrichmentSubjects);	
//System.out.println(" vSubGroupInfo : "+vSubGroupInfo);
//System.out.println(" vCurGroupInfo : "+vCurGroupInfo);
//System.out.println(" vStudSubGroup : "+vStudSubGroup);


dbOP.rollbackOP();
dbOP.forceAutoCommitToTrue();


strSQLQuery = "select SG_NAME from SUB_GROUP_MAP_FORM19 where course_index_ = "+vStudInfo.elementAt(5) + " order by ORDER_NO";
rs = dbOP.executeQuery(strSQLQuery);
Vector vTemp = new Vector();
int iIndexOf = 0;
while(rs.next()) {
	iIndexOf = -1;
	if(vSubGroupInfo != null && vSubGroupInfo.size() > 0)
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
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";


//I have to get addl number of groups.
int iAddlGroup =  0;
if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {
	iAddlGroup = vCurGroupInfo.size() / 2 - 10;
	//if(iAddlGroup < 0) ==> Forced to 0
		iAddlGroup = 0;
}


String strLastSY  = null;
String strLastSem = null;
String strELInfo  = null; Vector vELPrintedIndex = new Vector();
boolean bolRemoveROTC = false;//true only if WNU_REMOVE_ROTC is set to 1

if(vEntranceData != null) {
	if(vEntranceData.elementAt(29) != null)
		strELInfo = "(E.L. No. "+(String)vEntranceData.elementAt(29)+")";
	if(vEntranceData.elementAt(30) != null) {
		strTemp = (String)vEntranceData.elementAt(30);
		if(strTemp != null && strTemp.equals("1"))
			bolRemoveROTC = true;
	}
	
	
}


String strSeaferingInfo = null;Vector vSeafering = new Vector();
vSeafering.addElement("PHASE I");
vSeafering.addElement("PHASE II");
vSeafering.addElement("PHASE III");
vSeafering.addElement("PHASE IV");
vSeafering.addElement("PHASE V");
vSeafering.addElement("PHASE VI");
vSeafering.addElement("PHASE VII");
vSeafering.addElement("PHASE VIII");
vSeafering.addElement("PHASE IX");
vSeafering.addElement("PHASE X");
vSeafering.addElement("PHASE XI");
vSeafering.addElement("PHASE XII");





if(strErrMsg != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
	<td><font size="3"><%=strErrMsg%></font>
	</td>
  </tr>
</table>
<%dbOP.cleanUP();return;}
%>
<body topmargin="0" <%if(strPrintPage.equals("1")){%> onLoad="window.print();"<%}%>>
<form action="./otr_can_grad_print_wnu.jsp" method="post" name="form_">
<%if(iPageNumber > 1) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="20">Name : 
	<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
  	<%=WI.getStrValue((String)vStudInfo.elementAt(1)," ","","").toUpperCase()%>
	<%//=WebInterface.formatName((String)vStudInfo.elementAt(0), (String)vStudInfo.elementAt(1), (String)vStudInfo.elementAt(2),4).toUpperCase()%></td>
    <td width="22%" height="20" align="right">Page <%=iPageNumber%> of <%=strTotalPageNumber%></td>
  </tr>
</table>



<%}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
    <td colspan="8" align="center"> 
      <label id="univ_" onClick="ChangeUnivCollege();">
			<font size="5">West Negros University</font><br>
			<strong>(Formerly West Negros College)</strong>		</label>
		<br><br>
		<strong><font size="3">City Of Bacolod</font></strong><br><br>
		<div align="left">
          <font style="font-size:11px; font-weight:bold">Records of Candidates for Graduation with the Title/Degree: 
      	<%=(String)vStudInfo.elementAt(7)%>(<%=(String)vStudInfo.elementAt(24)%>)
		<%if(vStudInfo.elementAt(8) != null) {%>
			<br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			Major : 
			<%=(String)vStudInfo.elementAt(8)%> 
		<%}%>		</font></div><br>	  </td>
  </tr>
<tr>
  <td colspan="8" style="font-size:12px; font-weight:bold" height="25">PERSONAL RECORDS : </td>
</tr>
<tr>
  <td>Name: </td>
  <td>&nbsp;</td>
  <td colspan="4" class="thinborderBOTTOM"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
  	<%=WI.getStrValue((String)vStudInfo.elementAt(1)," ","","").toUpperCase()%></td>
  <td>Sex: </td>
  <td class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(0))%></td>
</tr>
<%
String strMonth = null;
String strDay   = null;
String strYear  = null;
strTemp = WI.getStrValue(vAdditionalInfo.elementAt(1));
if(strTemp.length() > 0) {
	iIndexOf = strTemp.indexOf(" ");
	strMonth = strTemp.substring(0,iIndexOf);
	strTemp = strTemp.substring(iIndexOf);
	iIndexOf = strTemp.indexOf(",");
	strDay = strTemp.substring(0,iIndexOf);
	strYear = strTemp.substring(iIndexOf + 1);
}
%>
<tr>
  <td>Date of Birth: </td>
  <td align="right">Year:&nbsp;&nbsp;</td>
  <td class="thinborderBOTTOM"><%=WI.getStrValue(strYear, "&nbsp;")%></td>
  <td>Month: </td>
  <td colspan="2" class="thinborderBOTTOM"><%=WI.getStrValue(strMonth, "&nbsp;")%></td>
  <td>Day: </td>
  <td class="thinborderBOTTOM"><%=WI.getStrValue(strDay, "&nbsp;")%></td>
</tr>
<%
strMonth = null;//province..
strDay   = null;//muncipality
strTemp = WI.getStrValue(vAdditionalInfo.elementAt(2));
iIndexOf = strTemp.indexOf(",");
if(iIndexOf > -1) {
	if(strTemp.length() > (iIndexOf + 1) ) 
		strMonth = strTemp.substring(iIndexOf + 1);
	strDay   = strTemp.substring(0,iIndexOf);
}
else	
	strDay = strTemp;

%>
<tr>
  <td>Place of Birth:</td>
  <td align="right">Province:&nbsp;&nbsp;</td>
  <td class="thinborderBOTTOM"><%=WI.getStrValue(strMonth,"&nbsp;")%></td>
  <td colspan="2">Municipality:&nbsp;</td>
  <td colspan="3" class="thinborderBOTTOM"><%=WI.getStrValue(strDay,"&nbsp;")%></td>
</tr>
<tr>
  <td colspan="2">Parent or Guardian: </td>
  <td class="thinborderBOTTOM"><%//=WI.getStrValue(vAdditionalInfo.elementAt(8), "&nbsp;") --> Father's name. Changed to Contact person Name.%>
  <%=WI.getStrValue(vAdditionalInfo.elementAt(13), "&nbsp;")%>
  </td>
  <td colspan="2">Occupation</td>
  <td colspan="3" class="thinborderBOTTOM"><%=WI.getStrValue(vEntranceData.elementAt(28), "&nbsp;")%></td>
  </tr>
<%
strTemp = (String)vAdditionalInfo.elementAt(3);
if(strTemp == null)
	strTemp = "";
strMonth = null;//line 2.
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
  <td colspan="2">Address of Parent or Guardian </td>
  <td colspan="6" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
  </tr>
<tr>
  <td colspan="2">&nbsp;</td>
  <td colspan="6" class="thinborderBOTTOM"><%=WI.getStrValue(strMonth, "&nbsp;")%></td>
  </tr>
<tr>
  <td width="15%">&nbsp;</td>
  <td width="10%">&nbsp;</td>
  <td width="20%">&nbsp;</td>
  <td width="5%">&nbsp;</td>
  <td width="2%">&nbsp;</td>
  <td width="38%">&nbsp;</td>
  <td width="5%">&nbsp;</td>
  <td width="5%">&nbsp;</td>
</tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td colspan="2" style="font-size:12px; font-weight:bold" height="20" valign="top">RECORDS OF PRELIMINARY EDUCATION : </td>
  <td colspan="2">&nbsp;</td>
</tr>
<tr>
  <td>Elementary Grade Completed: </td>
  <td class="thinborderBOTTOM">
  <%
  strTemp = WI.getStrValue(vEntranceData.elementAt(14),WI.getStrValue(vEntranceData.elementAt(3)));
  %>
  <%=WI.getStrValue(strTemp, "&nbsp;")%></td>
  <td>School Year: </td>
  <td class="thinborderBOTTOM"><%=WI.getStrValue(vEntranceData.elementAt(19)) +" - "+
	  	WI.getStrValue(vEntranceData.elementAt(20))%></td>
  </tr>
<tr>
  <td>High School Completed: </td>
  <td class="thinborderBOTTOM"><%=WI.getStrValue(vEntranceData.elementAt(5), "&nbsp;")%></td>
  <td>School Year: </td>
  <td class="thinborderBOTTOM"><%=WI.getStrValue(vEntranceData.elementAt(21)) +" - "+
	  WI.getStrValue(vEntranceData.elementAt(22))%></td>
  </tr>

<tr>
  <td width="24%">&nbsp;</td>
  <td width="52%">&nbsp;</td>
  <td width="12%">&nbsp;</td>
  <td>&nbsp;</td>
  </tr>
</table>
<%}//show only if it is not first page.. 
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(iLastPage == 0 || (iLastPage == 1 && iRowCount > 0)){%>
  <tr align="center">
    <td class="thinborderTOPBOTTOM" style="font-weight:bold; font-size:11px;"><%=WI.fillTextValue("stud_id")%></td>
    <td colspan="15" class="thinborderTOPBOTTOM" style="font-weight:bold; font-size:14px;">UNIVERSITY RECORDS </td>
  </tr>
  <tr style="font-weight:bold;" align="center" onDblClick="PrintNextPage();">
    <td width="10%" rowspan="2" class="thinborderBOTTOM">Course No </td>
    <td width="38%" rowspan="2" class="thinborderLEFTBOTTOM">Descriptive Title </td>
    <td width="4%" rowspan="2" class="thinborderLEFTBOTTOM" style="font-size:9px"> GRADES </td>
    <td width="4%" rowspan="2" class="thinborderLEFTBOTTOM" style="font-size:9px">RE-EXAM GRADE</td>
    <td width="4%" rowspan="2" class="thinborderLEFTBOTTOM" style="font-size:9px">CREDIT</td>
    <td colspan="10" class="thinborderLEFTBOTTOMRIGHT" width="40%">Credits According to Group </td>
  </tr>
  <tr style="font-weight:bold;" align="center">
    <td width="4%" class="thinborder">&nbsp;I&nbsp;</td>
    <td width="4%" class="thinborder">II</td>
    <td width="4%" class="thinborder">III</td>
    <td width="4%" class="thinborder">IV</td>
    <td width="4%" class="thinborder">&nbsp;V&nbsp;</td>
    <td width="4%" class="thinborder">VI</td>
    <td width="4%" class="thinborder">VII</td>
    <td width="4%" class="thinborder">VIII</td>
    <td width="4%" class="thinborder">IX</td>
    <td width="4%" class="thinborderLEFTBOTTOMRIGHT">&nbsp;X&nbsp;</td>
	<%for(int j = 0; j < iAddlGroup; ++j) {%>
    <td width="3%" class="thinborder"><%=(10 + j + 1)%></td>
	<%}%>
  </tr>
<%}//do not show if no data to show.%>

  <%
boolean booIsNewPage = false; //it is set to show school name/sy/term in each start of page.. 


int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = null;
String strSchNameToDisp = null;


String strSYSemToDisp   = null;
String strCurSYSem      = null;
String strPrevSYSem     = null;
String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","3rd Sem","4th Sem"};

boolean bolIsSchNameNull    = false;
boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has
//school name after it is null, it is encoded as cross enrollee.
String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;


///get the here required units.. 
for(int i = 1; i < 11; ++i) {
	iIndexOf = vStudSubGroup.indexOf(Integer.toString(i));
	if(iIndexOf == -1) {
		astrGroupReq[i - 1] = null;
		astrGroupName[i - 1] = null;
		//strUnitsCompleted = null; 
	} 
	else {
		astrGroupName[i - 1] = (String)vStudSubGroup.elementAt(iIndexOf + 1);
		strTemp = (String)vStudSubGroup.elementAt(iIndexOf + 2);
		if(strTemp != null) {
			if(strTemp.endsWith(".0"))
				strTemp = strTemp.substring(0,strTemp.length() - 2);
		}
		astrGroupReq[i - 1] = strTemp;
		//strUnitsCompleted = (String)vStudSubGroup.elementAt(iIndexOf + 3);
		//System.out.println(" i : "+i + ": "+astrGroupName[i - 1]);
	}
}

//I have to find here the group requirement if manually already set.. 
strSQLQuery = "select GROUP1, GROUP2, GROUP3, GROUP4, GROUP5, GROUP6, GROUP7, GROUP8, GROUP9, GROUP10 FROM FORM9_REQUIRED_UNIT WHERE STUD_INDEX = "+
	vStudInfo.elementAt(12);
rs = dbOP.executeQuery(strSQLQuery);
if(rs.next()) {
	for(int i = 0; i < 10; ++i) {
		if(rs.getInt(i + 1) <= 0) 
			continue;
		astrGroupReq[i] = rs.getString(i + 1);
	}
}
rs.close();


strTemp = "select course_index from stud_curriculum_hist where is_valid =1 and DATE_ENROLLED is not null and sy_from = ? and semester = ? and user_index = "+(String)vStudInfo.elementAt(12);
java.sql.PreparedStatement pstmtGetCourseIndex = dbOP.getPreparedStatement(strTemp);

boolean bolIsSeafering = false;
if(strCourseIndex.equals("110") || strCourseIndex.equals("124")) {
	bolIsSeafering = true;
}


String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;
boolean bolReExam = false;//if it is true, i have to set re-exam value.
boolean bolIsApprRemarks = false;
//System.out.println(vRetResult);
String strEnrichCE = null;






for(int i = 0 ; i < vRetResult.size(); i += 11){
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 6))+WI.getStrValue((String)vRetResult.elementAt(i + 7));
	iIndexOf = vApprenticeInfo.indexOf(strTemp);
	if(iIndexOf > -1){	
		int iii = i + 11;
		
		if(WI.getStrValue(vApprenticeInfo.elementAt(iIndexOf + 12)).length() > 0){
			vRetResult.insertElementAt(vRetResult.elementAt(i), iii);
			vRetResult.insertElementAt(vRetResult.elementAt(i+1), iii+1);
			vRetResult.insertElementAt(vRetResult.elementAt(i+2), iii+2);
			vRetResult.insertElementAt(vRetResult.elementAt(i+3), iii+3);
			vRetResult.insertElementAt(vRetResult.elementAt(i+4), iii+4);
			vRetResult.insertElementAt(vRetResult.elementAt(i+5), iii+5);
			vRetResult.insertElementAt("COMPLETED", iii+6);
			vRetResult.insertElementAt(vApprenticeInfo.elementAt(iIndexOf + 12), iii+7);
			vRetResult.insertElementAt("&nbsp;", iii+8);
			vRetResult.insertElementAt("&nbsp;", iii+9);
			vRetResult.insertElementAt("&nbsp;", iii+10);
		}
		
		vRetResult.insertElementAt(vRetResult.elementAt(i), iii);
		vRetResult.insertElementAt(vRetResult.elementAt(i+1), iii+1);
		vRetResult.insertElementAt(vRetResult.elementAt(i+2), iii+2);
		vRetResult.insertElementAt(vRetResult.elementAt(i+3), iii+3);
		vRetResult.insertElementAt(vRetResult.elementAt(i+4), iii+4);
		vRetResult.insertElementAt(vRetResult.elementAt(i+5), iii+5);
		vRetResult.insertElementAt("Apprenticeship:", iii+6);
		
		strTemp = (String)vApprenticeInfo.elementAt(iIndexOf + 5);
		strTemp += "<br>"+ WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 8),"From: ","","")+
			WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 9),"- ","","");
		strTemp += "<br>"+ WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 10),"Gross Tonnage: ","","");
		strTemp += "<br>"+ WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 11),"Registry Number: ","","");
		
		vRetResult.insertElementAt(strTemp, iii+7);
		vRetResult.insertElementAt(vApprenticeInfo.elementAt(iIndexOf + 7), iii+8);		
		vRetResult.insertElementAt("&nbsp;", iii+9);
		vRetResult.insertElementAt("INC", iii+10);
		
		vRetResult.insertElementAt(vRetResult.elementAt(i), iii);
		vRetResult.insertElementAt(vRetResult.elementAt(i+1), iii+1);
		vRetResult.insertElementAt(vRetResult.elementAt(i+2), iii+2);
		vRetResult.insertElementAt(vRetResult.elementAt(i+3), iii+3);
		vRetResult.insertElementAt(vRetResult.elementAt(i+4), iii+4);
		vRetResult.insertElementAt(vRetResult.elementAt(i+5), iii+5);
		vRetResult.insertElementAt("Apprenticeship:", iii+6);
		strTemp = (String)vApprenticeInfo.elementAt(iIndexOf + 5);
		strTemp += "<br>"+ WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 8),"From: ","","")+
			WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 9),"- ","","");
		strTemp += "<br>"+ WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 10),"Gross Tonnage: ","","");
		strTemp += "<br>"+ WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 11),"Registry Number: ","","");

		vRetResult.insertElementAt(strTemp, iii+7);
//		vRetResult.insertElementAt(vApprenticeInfo.elementAt(iIndexOf + 6), iii+8);
		vRetResult.insertElementAt("&nbsp;", iii+8);
		vRetResult.insertElementAt("&nbsp;", iii+9);
		vRetResult.insertElementAt("INC", iii+10);
		
		vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);
		vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);
		vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);
	}
}




for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
//I have to take care of re-exam.
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && 
	(	WI.getStrValue((String)vRetResult.elementAt(i + 10)).toLowerCase().indexOf("inc") != -1 || 
		((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 || ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("lfr") != -1 ) &&
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

	strSchoolName = (String)vRetResult.elementAt(i);
	//I have to now put the name of school if it is null.. 
	if(strSchoolName == null) {
		int iSY = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 1) , "0"));
		if(iSY < 2008)
			strSchoolName = "WEST NEGROS COLLEGE, BACOLOD CITY";
		else	
			strSchoolName = "WEST NEGROS UNIVERSITY, BACOLOD CITY";
	}
	
	
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
	
	
	
 	//if prev school name is not not null, show the current shcool name. == show current school only once.. 
	if(strSchoolName == null && strPrevSchName != null) {
		strSchNameToDisp = strCurrentSchoolName;
		if(strSchNameToDisp.equals(strPrevSchName))
			strSchNameToDisp = null;
		else
			strPrevSchName = strSchNameToDisp;
		//strPrevSchName = null;
	}
/**
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
}**/

/**
//////////////////// school name is displayed with school year - school name repeats.. /////////////////////////////
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
**/


bolIsSeafering = false;
//strCurSYSem =
if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {//convert only if term is 0,1 or 2.
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+" "+
					(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
					
		pstmtGetCourseIndex.setString(1, (String)vRetResult.elementAt(i+ 1));
		pstmtGetCourseIndex.setString(2, (String)vRetResult.elementAt(i+ 3));
		rs = pstmtGetCourseIndex.executeQuery();
		if(rs.next()){
			if(rs.getString(1).equals("110") || rs.getString(1).equals("124")) 
				bolIsSeafering = true;			
		}
		rs.close();
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

//////////////////// end of displaying school year ////////////////////////////////////////
//System.out.println("I am out "+strSYSemToDisp);


//get here index of group .
strTemp = (String)vRetResult.elementAt(i+ 9);
if(strTemp != null) {
	iIndexOfSubGroup = strTemp.indexOf("(");
	if(iIndexOfSubGroup != -1) {
		strTemp = strTemp.substring(0, iIndexOfSubGroup);
	}
}

		iIndexOfSubGroup = vSubGroupInfo.indexOf(vRetResult.elementAt(i+ 10));
		//if (iIndexOfSubGroup != -1)
		//	iIndexOfSubGroup = iIndexOfSubGroup/2 + 1;
		iIndexOfSubGroup = -1;
		int p = astrGroupName.length;
		for(int q = 0; q < p; ++q) {
			if(astrGroupName[q] == null)
				continue;
			if(vRetResult.elementAt(i+ 10) == null)
				break;
				
			if(vRetResult.elementAt(i+ 10).equals(astrGroupName[q])) {
				iIndexOfSubGroup = q + 1;
				break;
			}
		}

	try{
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
	}
	catch(NumberFormatException nfe){
		dTemp = 0d;
	}
if(iIndexOfSubGroup == 1)  dSG1  += dTemp;	if(iIndexOfSubGroup == 2)  dSG2  += dTemp;
if(iIndexOfSubGroup == 3)  dSG3  += dTemp;	if(iIndexOfSubGroup == 4)  dSG4  += dTemp;
if(iIndexOfSubGroup == 5)  dSG5  += dTemp;	if(iIndexOfSubGroup == 6)  dSG6  += dTemp;
if(iIndexOfSubGroup == 7)  dSG7  += dTemp;	if(iIndexOfSubGroup == 8)  dSG8  += dTemp;
if(iIndexOfSubGroup == 9)  dSG9  += dTemp;	if(iIndexOfSubGroup == 10) dSG10 += dTemp;
if(iIndexOfSubGroup == 11) dSG11 += dTemp;	if(iIndexOfSubGroup == 12) dSG12 += dTemp;
if(iIndexOfSubGroup == 13) dSG13 += dTemp;	if(iIndexOfSubGroup == 14) dSG14 += dTemp;

 //Very important here, it print if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowLHS%>
<%booIsNewPage = false;}

	//added so that system will print sy/term every start of page.
	if(booIsNewPage && strSchNameToDisp == null && strSYSemToDisp == null) {
		strSYSemToDisp = strCurSYSem;
		//System.out.println("I am in "+strSYSemToDisp);
		strSchNameToDisp = strPrevSchName;
		booIsNewPage = false;
	}


//print here remark.. 
if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		iMulRemarkCount += 3;
		
		Vector vTempRemark = CommonUtil.convertCSVToVector((String)vMulRemark.remove(0), "##", true);
		while(vTempRemark.size() > 0) {//for wnu more remark column in one remark.. 
		strTemp = (String)vTempRemark.remove(0);
		iIndexOf = strTemp.indexOf(": ");
		if(iIndexOf == -1) {
			strCol1 = "Graduated: ";
			strCol2 = strTemp;
		}
		else{
			strCol1 = strTemp.substring(0, iIndexOf + 2);
			strCol2 = strTemp.substring(iIndexOf+2);
		}%>
		  <tr>
			<td height="20" class="thinborderTOPBOTTOM"><label onClick="Update('0<%=i%>')" id="0<%=i%>"><%=strCol1%> </label></td>
			<td height="20" colspan="14" class="thinborderTOPBOTTOMRIGHT"><label onClick="Update('1<%=i%>')" id="1<%=i%>"><%=ConversionTable.replaceString(strCol2,"\n","<br>")%></label></td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td width="3%" class="thinborderLEFT">&nbsp;</td>
			<%}%>
		  </tr>
		<%}//end of while. %>
  <%}//end of if
}//end of vMulRemark.


//print here sy/term/school name..

if(strSYSemToDisp != null){
booIsNewPage = false;
strTemp = strSYSemToDisp;
if(strTemp.toLowerCase().startsWith("1st semester"))
	strTemp = "FIRST SEMESTER, "+strTemp.substring(12);
else if (strTemp.toLowerCase().startsWith("2nd semester"))
	strTemp = "SECOND SEMESTER, "+strTemp.substring(12);
else if (strTemp.toLowerCase().startsWith("summer"))
	strTemp = "SUMMER, "+strTemp.substring(strTemp.length() - 4);
	//strTemp = "SUMMER, "+strTemp.substring(6);


if(strTemp.startsWith("1ST"))
	strTemp = "FIRST "+strTemp.substring(4);
else if(strTemp.startsWith("2ND"))
	strTemp = "SECOND "+strTemp.substring(4);
else if(strTemp.startsWith("3RD"))
	strTemp = "THIRD "+strTemp.substring(4);
else if(strTemp.startsWith("4TH"))
	strTemp = "FOURTH "+strTemp.substring(4);

//I have to convert the first ay to first semester ay
if(strTemp.startsWith("FIRST AY")) 
	strTemp = "FIRST SEMESTER AY"+strTemp.substring(8);
if(strTemp.startsWith("SECOND AY")) 
	strTemp = "SECOND SEMESTER AY"+strTemp.substring(9);

strSeaferingInfo = "";
if(vSeafering.size() > 0 && bolIsSeafering/* && strSchNameToDisp != null && strSchNameToDisp.startsWith("WEST NEGROS")*/) {	
	strSeaferingInfo = (String)vSeafering.remove(0);
}

%>
  <tr>
    <td height="20" colspan="15" class="thinborderTOPBOTTOMRIGHT"><strong> <%=WI.getStrValue(strSeaferingInfo, "","&nbsp;","")%><%=strTemp.toUpperCase()%><%=WI.getStrValue(strSchNameToDisp," - ","","").toUpperCase()%> 
	<label id="<%=i%>" onClick="encodeCode('<%=i%>');">&nbsp;
	<%if(strELInfo == null) {%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}else{%><%=strELInfo%>
	<%vELPrintedIndex.addElement(Integer.toString(i));}%>
	
	
	</label>
	
	
	</strong></td>
    <%for(int j = 0; j < iAddlGroup; ++j) {%>
    <td width="3%" class="thinborderLEFT">&nbsp;</td>
	<%}%>
  </tr>
<%
strSYSemToDisp = null;
}
strTemp = WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;");

if(bolRemoveROTC) {
	iIndexOf = strTemp.indexOf("ROTC");
	if(iIndexOf == -1)
		iIndexOf = strTemp.indexOf("LTS");
	if(iIndexOf == -1)
		iIndexOf = strTemp.indexOf("CWTS");
	if(iIndexOf > 0)
		strTemp = strTemp.substring(0, iIndexOf-1);
	//System.out.println(iIndexOf);
	
}

if(strTemp != null && strTemp.toLowerCase().equals("completed")){
	strErrMsg = "class='thinborderTOPBOTTOM'";
}else{
	strErrMsg = "class='thinborderRIGHT'";
}
%>

  <tr>
    <td width="15%" <%=strErrMsg%> height="15">
		<label id="00<%=i%>" onClick="updateSubjectRow('00<%=i%>')"><%=strTemp%></label></td>
	<%
	if(strTemp != null && strTemp.toLowerCase().equals("completed")){
		strTemp = "colspan='"+Integer.toString(14+iAddlGroup)+"'  class='thinborderTOPBOTTOMRIGHT'";
		bolIsApprRemarks = true;
	}else{
		strTemp = "";
		bolIsApprRemarks = false;
	}
	%>
    <td width="25%" <%=strTemp%>>
		<label id="01<%=i%>" onClick="updateSubjectRow('01<%=i%>')"><%=vRetResult.elementAt(i + 7)%></label>
	</td>
	
	<%if(!bolIsApprRemarks){%>
	
    <td class="thinborderLEFT">&nbsp; <%if(bolReExam) strTemp = (String) vRetResult.elementAt(i - 11 + 8);
									 else strTemp = (String)vRetResult.elementAt(i + 8);
									 if(strTemp == null)
									 	strTemp = "";
									 if(strTemp.startsWith("on"))
									 	strTemp = "";
									 %> <%=WI.getStrValue(strTemp, "&nbsp;")%></td>
    <td class="thinborderLEFT">&nbsp; <%if(bolReExam) {%> <%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if (WI.getStrValue(strTemp).startsWith("on")) strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"(",")","&nbsp;");
										else strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"&nbsp;");
										if(strTemp != null && strTemp.indexOf("(") > 0)
											strTemp = strTemp.substring(0, strTemp.indexOf("("));
	//////////// added to put () around thd enrich subject.. 
	iIndexOf = vEnrichmentSubjects.indexOf((String)vRetResult.elementAt(i + 6));
	if(iIndexOf > -1) {
		if(vRetResult.elementAt(i + 8) != null && !vRetResult.elementAt(i + 8).equals("5.0"))
			strTemp = "("+ vEnrichmentSubjects.elementAt(iIndexOf + 3) +")";
	}
										if(iIndexOfSubGroup == -1 && false){%>(<%}%>
										<%=strTemp%>	
										<%if(iIndexOfSubGroup == -1 && false){%>)<%}%>
										</td>
<%
if(strTemp != null && strTemp.endsWith(".0"))
		strTemp = strTemp.substring(0,strTemp.length() - 2);
if(strTemp == null || strTemp.trim().equals("0"))
	strTemp = "&nbsp;";
%>
	<td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 1){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 2){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 3){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 4){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 5){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 6){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 7){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 8){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 9){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFTRIGHT">&nbsp; <%if(iIndexOfSubGroup == 10){%> <%=strTemp%> <%}%></td>
	<%for(int j = 0; j < iAddlGroup; ++j) {%>
    <td width="3%" class="thinborderLEFT">&nbsp;
		<%if(iIndexOfSubGroup == (12 + j + 1)){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
	<%}
	}//end if(!bolIsApprRemarks)%>
  </tr>
  
  

  
  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%>
  <%}
 }//end of for loop
 
 

  //print here remark.. 
if(vMulRemark != null && vMulRemark.size() > 0) {
	iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
	//if(iMulRemarkIndex == i){
		vMulRemark.removeElementAt(0);
		//iMulRemarkCount += 3;
		
		Vector vTempRemark = CommonUtil.convertCSVToVector((String)vMulRemark.remove(0), "##", true);
		while(vTempRemark.size() > 0) {//for wnu more remark column in one remark.. 
		strTemp = (String)vTempRemark.remove(0);
		iIndexOf = strTemp.indexOf(": ");
		if(iIndexOf == -1) {
			strCol1 = "Graduated: ";
			strCol2 = strTemp;
		}
		else{
			strCol1 = strTemp.substring(0, iIndexOf + 2);
			strCol2 = strTemp.substring(iIndexOf+2);
		}%>
		  <tr>
			<td height="20" class="thinborderTOPBOTTOM"><%=strCol1%></td>
			<td height="20" colspan="14" class="thinborderTOPBOTTOMRIGHT"><%=ConversionTable.replaceString(strCol2,"\n","<br>")%></td>
			<%for(int j = 0; j < iAddlGroup; ++j) {%>
			<td width="3%" class="thinborderLEFT">&nbsp;</td>
			<%}%>
		  </tr>
		<%}//end of while. %>
  <%//}//end of if
}//end of vMulRemark.
 
 
if(bolIsEndOfContent){
int iIndex = 0;%>
  <tr>
    <td height="20" colspan="2" class="thinborderTOPBOTTOM"><div align="center">TOTAL UNITS EARNED </div></td>
    <td class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
    <td class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
    <td align="center" class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
    <td align="center" class="thinborderTOPLEFTBOTTOM"><%=CommonUtil.formatFloat(dSG1,false)%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM"><%if(dSG2 > 0d){%><%=CommonUtil.formatFloat(dSG2,false)%><%}else{%>&nbsp;<%}%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM"><%if(dSG3 > 0d){%><%=CommonUtil.formatFloat(dSG3,false)%><%}else{%>&nbsp;<%}%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM"><%if(dSG4 > 0d){%><%=CommonUtil.formatFloat(dSG4,false)%><%}else{%>&nbsp;<%}%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM"><%if(dSG5 > 0d){%><%=CommonUtil.formatFloat(dSG5,false)%><%}else{%>&nbsp;<%}%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM"><%if(dSG6 > 0d){%><%=CommonUtil.formatFloat(dSG6,false)%><%}else{%>&nbsp;<%}%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM"><%if(dSG7 > 0d){%><%=CommonUtil.formatFloat(dSG7,false)%><%}else{%>&nbsp;<%}%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM"><%if(dSG8 > 0d){%><%=CommonUtil.formatFloat(dSG8,false)%><%}else{%>&nbsp;<%}%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM"><%if(dSG9 > 0d){%><%=CommonUtil.formatFloat(dSG9,false)%><%}else{%>&nbsp;<%}%></td>
    <td align="center" class="thinborderALL"><%if(dSG10 > 0d){%><%=CommonUtil.formatFloat(dSG10,false)%><%}else{%>&nbsp;<%}%></td>
	<%for(int j = 0; j < iAddlGroup; ++j) {
		if(j == 0)
			strTemp = CommonUtil.formatFloat(dSG13,false);
		else if( j == 1)
			strTemp = CommonUtil.formatFloat(dSG14,false);
		else
			strTemp = "Column Over flow";
	%>
    <td width="3%" align="center" class="thinborderTOPLEFTBOTTOM">
	<%=strTemp%></td>
	<%}%>
  </tr>
  <tr align="center">
    <td height="20" colspan="2" class="thinborderNONE" align="center">TOTAL UNITS REQUIRED </td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT"><label id="_grp1" onDblClick="javascript:UpdateGrpRequirement('_grp1','1');"><%=WI.getStrValue(astrGroupReq[0], "&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborderLEFT"><label id="_grp2" onDblClick="javascript:UpdateGrpRequirement('_grp2','2');"><%=WI.getStrValue(astrGroupReq[1], "&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborderLEFT"><label id="_grp3" onDblClick="javascript:UpdateGrpRequirement('_grp3','3');"><%=WI.getStrValue(astrGroupReq[2], "&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborderLEFT"><label id="_grp4" onDblClick="javascript:UpdateGrpRequirement('_grp4','4');"><%=WI.getStrValue(astrGroupReq[3], "&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborderLEFT"><label id="_grp5" onDblClick="javascript:UpdateGrpRequirement('_grp5','5');"><%=WI.getStrValue(astrGroupReq[4], "&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborderLEFT"><label id="_grp6" onDblClick="javascript:UpdateGrpRequirement('_grp6','6');"><%=WI.getStrValue(astrGroupReq[5], "&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborderLEFT"><label id="_grp7" onDblClick="javascript:UpdateGrpRequirement('_grp7','7');"><%=WI.getStrValue(astrGroupReq[6], "&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborderLEFT"><label id="_grp8" onDblClick="javascript:UpdateGrpRequirement('_grp8','8');"><%=WI.getStrValue(astrGroupReq[7], "&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborderLEFT"><label id="_grp9" onDblClick="javascript:UpdateGrpRequirement('_grp9','9');"><%=WI.getStrValue(astrGroupReq[8], "&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborderLEFTRIGHT"><label id="_grp10" onDblClick="javascript:UpdateGrpRequirement('_grp10','10');"><%=WI.getStrValue(astrGroupReq[9], "&nbsp;&nbsp;&nbsp;")%></label></td>
		<%for(int j = 0; j < iAddlGroup; ++j) {%>
    <td width="3%" class="thinborderLEFT">&nbsp;</td>
	<%}%>
  </tr>
 <%}//only if last page.%>
</table>

 <%if(iLastPage ==1){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E5E5E5">
  <tr>
    <td height="25" align="center" class="thinborderTOP">&nbsp;</td>
  </tr>
<% if (WI.fillTextValue("notes").length() > 0){%>
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
    <td height="25" colspan="27" class="thinborderTOP" align="center">
	<%if(iPageNumber != 1){%>
		<div align="right"><br><br>
		<u>&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(WI.fillTextValue("registrar_name"))%>&nbsp;&nbsp;&nbsp;</u> <br>
		University Registrar&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		
		</div>
	<%}%>	
	- more on page <%=iPageNumber + 1%> -</td>
  </tr>
</table>
<%}
if(iLastPage == 1 && vCurGroupInfo != null) {//Show in last page.. 
%>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
  <tr align="center">
	<td colspan="2" height="25"> <strong><u>R E C A P I T U L A T I O N</u></strong></td>
	<td width="1%">&nbsp;</td>
	<td width="27%"><strong><u>Group Requirements</u></strong></td>
	<td width="1%">&nbsp;</td>
    <td width="21%"><strong><u>Credits Earned</u></strong></td>
  </tr>
<%
String[] astrGroupNo = {"","Group I","Group II","Group III","Group IV","Group V","Group VI","Group VII","Group VIII","Group IX","Group X"};

double dTotalReq       = 0d;
double dTotalCompleted = 0d;
for(int i = 1; i < 11; ++i) {
	dTotalReq += Double.parseDouble(WI.getStrValue(astrGroupReq[i - 1], "0"));
		
	switch (i) {
		case 1:
			strTemp = CommonUtil.formatFloat(dSG1,false);
			dTotalCompleted += dSG1; 
			break;
		case 2:
			strTemp = CommonUtil.formatFloat(dSG2,false);
			dTotalCompleted += dSG2; 
			break;
		case 3:
			strTemp = CommonUtil.formatFloat(dSG3,false);
			dTotalCompleted += dSG3; 
			break;
		case 4:
			strTemp = CommonUtil.formatFloat(dSG4,false);
			dTotalCompleted += dSG4; 
			break;
		case 5:
			strTemp = CommonUtil.formatFloat(dSG5,false);
			dTotalCompleted += dSG5; 
			break;
		case 6:
			strTemp = CommonUtil.formatFloat(dSG6,false);
			dTotalCompleted += dSG6; 
			break;
		case 7:
			strTemp = CommonUtil.formatFloat(dSG7,false);
			dTotalCompleted += dSG7; 
			break;
		case 8:
			strTemp = CommonUtil.formatFloat(dSG8,false);
			dTotalCompleted += dSG8; 
			break;
		case 9:
			strTemp = CommonUtil.formatFloat(dSG9,false);
			dTotalCompleted += dSG9; 
			break;
		case 10:
			strTemp = CommonUtil.formatFloat(dSG10,false);
			dTotalCompleted += dSG10; 
			break;
	}

if(strTemp == null || strTemp.equals("0"))
	strTemp = "&nbsp;";
%>
<tr>
	<td width="11%"><%=astrGroupNo[i]%>: </td>
	<td width="39%" class="thinborderBOTTOM"><%=WI.getStrValue(astrGroupName[i - 1], "&nbsp;")%></td>
	<td>&nbsp;</td>
	<td class="thinborderBOTTOM" align="center"><%=WI.getStrValue(astrGroupReq[i - 1], "&nbsp;")%></td>
	<td>&nbsp;</td>
    <td class="thinborderBOTTOM" align="center"><%=strTemp%></td>
</tr>
<%}%>
<tr>
	<td width="11%">&nbsp;</td>
	<td width="39%" class="thinborderNONE" align="right">Total &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	<td>&nbsp;</td>
	<td class="thinborderNONE" align="center"><%=CommonUtil.formatFloat(dTotalReq, false)%></td>
	<td>&nbsp;</td>
    <td class="thinborderNONE" align="center"><%=CommonUtil.formatFloat(dTotalCompleted, false)%></td>
</tr>
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
                <td width="100%" height="15">&nbsp;</td>
              </tr>
              <tr>
                <td height="15">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I
                  hereby certify that the foregoing records of <u><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%>.</u> are verified by me and that the original copies of the official records substantiating the same are kept in the files of the university. I also certify that this student was enrolled in our institution  <u><%=WI.getStrValue(WI.fillTextValue("date_enrolled"))%></u>, of the current school year. </td>
              </tr>
            </table>


            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td height="15" colspan="2">&nbsp;</td>
                <td height="15" valign="bottom">&nbsp;</td>
              </tr>
              <tr>
                <td height="15" colspan="2">&nbsp;</td>
                <td height="15" valign="bottom">&nbsp;</td>
              </tr>
              <tr>
                <td height="15" colspan="2">&nbsp;</td>
                <td width="57%" height="15" valign="bottom"><div align="center"><u>&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(WI.fillTextValue("registrar_name"))%>&nbsp;&nbsp;&nbsp;</u></div></td>
              </tr>
              <tr>
                <td width="12%" height="15">Evaluated and Prepared by: </td>
                <td width="31%" height="15" class="thinborderBOTTOM"><%=WI.getStrValue(WI.fillTextValue("prep_by1").toUpperCase(), "&nbsp;")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getTodaysDate(1)%></td>
                <td height="15" valign="top"><div align="center">University Registrar</div></td>
              </tr>
              
              <tr>
                <td height="15">Reviewed by: </td>
                <td height="15" class="thinborderBOTTOM"><!--<%=WI.getStrValue(WI.fillTextValue("prep_by1").toUpperCase(), "&nbsp;")%>-->&nbsp;</td>
                <td height="15">&nbsp;</td>
              </tr>
              <tr>
                <td height="15">&nbsp;</td>
                <td height="15">&nbsp;</td>
                <td height="15">&nbsp;</td>
              </tr>
              <tr>
                <td height="15" colspan="2">WNU-REG-F14<br>
                  Rev 6(04-01-13) </td>
                <td height="15">&nbsp;</td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%}%>

<%
if(vELPrintedIndex != null && vELPrintedIndex.size() > 1) {%>
<script language="javascript">
<%while(vELPrintedIndex.size() > 1) {
	strTemp = (String)vELPrintedIndex.remove(0);%>
	if(document.getElementById("<%=strTemp%>"))
		document.getElementById("<%=strTemp%>").innerHTML = "";
<%}%>
</script>
<%}%>

<script>
function PrintNextPage() {
	<%if(!WI.fillTextValue("print_all_pages").equals("1")){%>
		return;
	<%}%>
	<%if(strPrintValueCSV.length() > 0){%>
	if(!confirm("Click Ok to print next page and Cancel to stay in this page."))
		return;
	document.form_.submit();
	<%}else{%>
	alert("End of printing");
	<%}%>
}
</script>

<input type="hidden" name="print_all_pages" value="<%=WI.fillTextValue("print_all_pages")%>">
<input type="hidden" name="print_value_csv" value="<%=strPrintValueCSV%>">
<input type="hidden" name="print_" value="<%=WI.fillTextValue("print_")%>">


	<input type="hidden" name="total_page" value="<%=strTotalPageNumber%>">
	<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">

<input type="hidden" name="ncee" value="<%=WI.fillTextValue("ncee")%>">
<input type="hidden" name="gsa" value="<%=WI.fillTextValue("gsa")%>">
<input type="hidden" name="percentile" value="<%=WI.fillTextValue("percentile")%>">
<input type="hidden" name="el_no" value="<%=WI.fillTextValue("el_no")%>">
<input type="hidden" name="con_addr_rel" value="<%=WI.fillTextValue("con_addr_rel")%>">
<input type="hidden" name="remove_nstp_opt" value="<%=WI.fillTextValue("remove_nstp_opt")%>">
<input type="hidden" name="adm_cre1" value="<%=WI.fillTextValue("adm_cre1")%>">
<input type="hidden" name="adm_cre2" value="<%=WI.fillTextValue("adm_cre2")%>">
<input type="hidden" name="prep_by1" value="<%=WI.fillTextValue("prep_by1")%>">
<input type="hidden" name="prep_by2" value="<%=WI.fillTextValue("prep_by2")%>">
<input type="hidden" name="check_by1" value="<%=WI.fillTextValue("check_by1")%>">
<input type="hidden" name="check_by2" value="<%=WI.fillTextValue("check_by2")%>">
<input type="hidden" name="accounting_division" value="<%=WI.fillTextValue("accounting_division")%>">
<input type="hidden" name="registrar_name" value="<%=WI.fillTextValue("registrar_name")%>" >										

<input type="hidden" name="dean_name" value="<%=WI.fillTextValue("dean_name")%>" >
<input type="hidden" name="notes" value="<%=WI.fillTextValue("notes")%>" >
<input type="hidden" name="date_enrolled" value="<%=WI.fillTextValue("date_enrolled")%>" >
<input type="hidden" name="date_grad" value="<%=WI.fillTextValue("date_grad")%>" >
<input type="hidden" name="show_chedformat" value="<%=WI.fillTextValue("show_chedformat")%>" >
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
