<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
-->
</style>
</head>

<body topmargin="0">
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


	int iPageNumber = Integer.parseInt(WI.fillTextValue("page_number"));
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.fillTextValue("max_page_to_disp"));

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
			strErrMsg = eData.getErrMsg();
	}
}

dbOP.rollbackOP();
dbOP.forceAutoCommitToTrue();

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

if(iPageNumber == 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(strSchoolCode.startsWith("UI")){%>
  <tr>
    <td width="50%" height="18">UI-REG-009</td>
    <td width="50%"><div align="right">REVISION NO. 01 DATE 23 MAY 2005 </div></td>
  </tr>
<%}%>
  <tr>
    <td colspan="2"><div align="center"><font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%><br>
        <strong> OFFICIAL TRANSCRIPT OF RECORDS OF CANDIDATE FOR GRADUATION</strong></font></div></td>
  </tr>
</table>
<%}
if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><font size="3"><%=strErrMsg%></font>
		</td>
	</tr>
</table>
<%dbOP.cleanUP();return;}

//show header only in first page.
if(iPageNumber == 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="23"><div align="right">NCEE &nbsp;<u><strong><%=WI.fillTextValue("ncee")%></strong></u>
        &nbsp;&nbsp;&nbsp;GSA &nbsp;<strong><u><%=WI.fillTextValue("gsa")%></u> </strong>&nbsp;&nbsp;&nbsp;
        %ile Rank &nbsp;<u><strong><%=WI.fillTextValue("percentile")%></strong></u> &nbsp;&nbsp;&nbsp;</div></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="11%" height="20">Name :</td>
    <td width="20%"><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></strong></td>
    <td width="29%"><strong><%=((String)vStudInfo.elementAt(0)).toUpperCase()%></strong></td>
    <td width="20%"><strong><%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
    <td width="20%" ><strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong></td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td valign="top" >(Last Name)</td>
    <td valign="top" >(First Name)</td>
    <td valign="top" >(Middle Name)</td>
    <td valign="top" >Student ID</td>
  </tr>
  <tr>
    <td height="20">Date of Birth :</td>
    <td><strong><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></strong></td>
    <td>Place of Birth : <strong><%=WI.getStrValue(vAdditionalInfo.elementAt(2))%></strong></td>
    <td colspan="2" >Gender : <strong><%=WI.getStrValue(vAdditionalInfo.elementAt(0))%></strong></td>
  </tr>
  <tr>
    <td height="20" colspan="5">Address : <strong><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","")%> </strong> </td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="20" colspan="5">Preliminary Education</td>
    <td width="19%">School Year</td>
    <td width="23%"> <% if (WI.fillTextValue("date_grad").length() != 0 ){%>
      Date of Graduation
      <%}else{%> &nbsp; <%}%> </td>
  </tr>
  <tr>
    <td width="7%">&nbsp;</td>
    <td width="12%">Primary</td>
    <td colspan="3"><strong><%=WI.getStrValue(vEntranceData.elementAt(14))%></strong></td>
    <td><strong><%=WI.getStrValue(vEntranceData.elementAt(17)) +" - "+
	  	WI.getStrValue(vEntranceData.elementAt(18))%></strong></td>
    <td>&nbsp;<strong><%=WI.formatDate(WI.fillTextValue("date_grad"),6)%></strong></td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td>Intermediate</td>
    <td colspan="3"><strong><%=WI.getStrValue(vEntranceData.elementAt(16))%></strong></td>
    <td colspan="2"><strong><%=WI.getStrValue(vEntranceData.elementAt(19)) +" - "+
	  WI.getStrValue(vEntranceData.elementAt(20))%></strong></td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td>Secondary</td>
    <td colspan="3"><strong><%=WI.getStrValue(vEntranceData.elementAt(5))%></strong></td>
    <td colspan="2"><strong><%=WI.getStrValue(vEntranceData.elementAt(21)) +" - "+
	  WI.getStrValue(vEntranceData.elementAt(22))%></strong></td>
  </tr>
  <tr>
    <td height="20" colspan="7">Admission Credentials </td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td colspan="3">1.) <%=WI.fillTextValue("adm_cre1")%></td>
    <td colspan="3">2.) <%=WI.fillTextValue("adm_cre2")%></td>
  </tr>
</table>
<%}//show only if iPageNumber == 1)
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(iPageNumber != 1){%>  <tr>
    <td height="20" colspan="3">Name : <strong>
	<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%>
	<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
    <td width="22%" height="20" colspan="2" valign="bottom" align="right">&nbsp;</td>
  </tr>
 <%}%>
  <tr>
    <td height="20" colspan="3">Candidate for the Title/Degree: <strong><%=(String)vStudInfo.elementAt(7)%></strong></td>
    <td width="22%" height="20" colspan="2" valign="bottom" align="right">Page <%=WI.fillTextValue("page_number")%> of <%=WI.fillTextValue("total_page")%></td>
  </tr>
  <tr>
    <td width="21%" height="20">&nbsp;</td>
    <td colspan="2" valign="bottom">Major: <strong><%=WI.getStrValue(vStudInfo.elementAt(8))%></strong></td>
    <td width="22%" colspan="2" valign="bottom">Minor </td>
  </tr>
</table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#E2E2E2">
    <td width="40%" class="thinborder" colspan="2"><div align="center"><strong>SUBJECTS</strong></div></td>
    <td width="5%" class="thinborder"><div align="center"><strong>Final Grade</strong></div></td>
    <td width="5%" class="thinborder"><div align="center"><strong>Units Earned</strong></div></td>
    <td width="5%" class="thinborder"><strong>RE-EXAM</strong></td>
    <td width="4%" class="thinborder"><div align="center"><strong>1</strong></div></td>
    <td width="4%" class="thinborder"><div align="center"><strong>2</strong></div></td>
    <td width="4%" class="thinborder"><div align="center"><strong>3</strong></div></td>
    <td width="4%" class="thinborder"><div align="center"><strong>4</strong></div></td>
    <td width="4%" class="thinborder"><div align="center"><strong>5</strong></div></td>
    <td width="4%" class="thinborder"><div align="center"><strong>6</strong></div></td>
    <td width="4%" class="thinborder"><div align="center"><strong>7</strong></div></td>
    <td width="4%" class="thinborder"><div align="center"><strong>8</strong></div></td>
    <td width="4%" class="thinborder"><div align="center"><strong>9</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>10</strong></div></td>
	<%for(int j = 0; j < iAddlGroup; ++j) {%>
    <td width="3%" class="thinborder"><div align="center"><strong><%=(10 + j + 1)%></strong></div></td>
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
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

boolean bolIsSchNameNull    = false;
boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has
//school name after it is null, it is encoded as cross enrollee.
String strCrossEnrolleeSchPrev   = null;
String strCrossEnrolleeSch       = null;


double dSG1 =0d;	double dSG2 =0d;	double dSG3 =0d;	double dSG4 =0d;	double dSG5 =0d;
double dSG6 =0d;	double dSG7 =0d;	double dSG8 =0d;	double dSG9 =0d;	double dSG10 =0d;
double dSG11 =0d;	double dSG12 =0d;	double dSG13 =0d;	double dSG14 =0d;	double dTemp =0d;


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

//////////////////// end of displaying school year ////////////////////////////////////////

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

 //Very important here, it print <!-- if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowLHS%>
  <%}

if(strSchNameToDisp != null && false){//school name is displayed with school year.%>
  <tr>
    <td height="20" colspan="2" class="thinborderLEFT"><%=strSchNameToDisp.toUpperCase()%></td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
	<%for(int j = 0; j < iAddlGroup; ++j) {%>
    <td width="3%" class="thinborderLEFT">&nbsp;</td>
	<%}%>
  </tr>
  <%strSchNameToDisp = null;}

if(strSYSemToDisp != null){%>
  <tr>
    <td height="20" colspan="2" class="thinborderLEFT"><strong> <%=strSYSemToDisp%><%=WI.getStrValue(strSchNameToDisp," - ","","").toUpperCase()%> </strong></td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
	<%for(int j = 0; j < iAddlGroup; ++j) {%>
    <td width="3%" class="thinborderLEFT">&nbsp;</td>
	<%}%>
  </tr>
  <%}
%>

  <tr>
    <td width="15%" height="20" class="thinborderLEFT"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td width="25%"><%=vRetResult.elementAt(i + 7)%></td>
    <td class="thinborderLEFT"> <%if(bolReExam) strTemp = (String) vRetResult.elementAt(i - 11 + 8);
									 else strTemp = (String)vRetResult.elementAt(i + 8);%> <%=WI.getStrValue(strTemp, "&nbsp;")%></td>
    <td class="thinborderLEFT">&nbsp;<%if (WI.getStrValue(strTemp).startsWith("on")) strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"(",")","&nbsp;");
										else strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"&nbsp;");%><%=strTemp%>
	</td>
    <td class="thinborderLEFT">&nbsp; <%if(bolReExam) {%> <%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 1){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 2){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 3){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 4){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 5){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 6){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 7){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 8){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 9){%> <%=strTemp%> <%}%></td>
    <td class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 10){%> <%=strTemp%> <%}%></td>
	<%for(int j = 0; j < iAddlGroup; ++j) {%>
    <td width="3%" class="thinborderLEFT">&nbsp;
		<%if(iIndexOfSubGroup == (12 + j + 1)){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
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
    <td height="20" colspan="2" class="thinborderTOPLEFTBOTTOM"><div align="center">Total
        Units Presented For Graduation </div></td>
    <td class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
    <td class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
    <td align="center" class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
    <td align="center" class="thinborderTOPLEFTBOTTOM"><%=CommonUtil.formatFloat(dSG1,false)%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM">&nbsp;<%=CommonUtil.formatFloat(dSG2,false)%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM">&nbsp;<%=CommonUtil.formatFloat(dSG3,false)%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM">&nbsp;<%=CommonUtil.formatFloat(dSG4,false)%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM">&nbsp;<%=CommonUtil.formatFloat(dSG5,false)%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM">&nbsp;<%=CommonUtil.formatFloat(dSG6,false)%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM">&nbsp;<%=CommonUtil.formatFloat(dSG7,false)%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM">&nbsp;<%=CommonUtil.formatFloat(dSG8,false)%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM">&nbsp;<%=CommonUtil.formatFloat(dSG9,false)%></td>
    <td align="center" class="thinborderTOPLEFTBOTTOM">&nbsp;<%=CommonUtil.formatFloat(dSG10,false)%></td>
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
    <td height="20" colspan="2" class="thinborderLEFT"><div align="center">Total
        Units Required for Graduation</div></td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT">&nbsp;</td>
    <td class="thinborderLEFT"><%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%><%=vCurGroupInfo.remove(0)%><%}%>
	</td>
    <td class="thinborderLEFT">
	<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
	<%=vCurGroupInfo.remove(0)%>
	<%}else{%>&nbsp;<%}%>
	</td>
    <td class="thinborderLEFT">
	<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
	<%=vCurGroupInfo.remove(0)%>
	<%}else{%>&nbsp;<%}%>
	</td>
    <td class="thinborderLEFT">
	<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
	<%=vCurGroupInfo.remove(0)%>
	<%}else{%>&nbsp;<%}%>
	</td>
    <td class="thinborderLEFT">
	<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
	<%=vCurGroupInfo.remove(0)%>
	<%}else{%>&nbsp;<%}%>
	</td>
    <td class="thinborderLEFT">
	<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
	<%=vCurGroupInfo.remove(0)%>
	<%}else{%>&nbsp;<%}%>
	</td>
    <td class="thinborderLEFT">
	<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
	<%=vCurGroupInfo.remove(0)%>
	<%}else{%>&nbsp;<%}%>
	</td>
    <td class="thinborderLEFT">
	<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
	<%=vCurGroupInfo.remove(0)%>
	<%}else{%>&nbsp;<%}%>
	</td>
    <td class="thinborderLEFT">
	<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
	<%=vCurGroupInfo.remove(0)%>
	<%}else{%>&nbsp;<%}%>
	</td>
    <td class="thinborderLEFT">
	<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
	<%=vCurGroupInfo.remove(0)%>
	<%}else{%>&nbsp;<%}%>
	</td>
		<%for(int j = 0; j < iAddlGroup; ++j) {%>
    <td width="3%" class="thinborderLEFT">
		<%if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {vCurGroupInfo.removeElementAt(0);%>
	<%=vCurGroupInfo.remove(0)%>
	<%}%></td>
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
    <td height="25" colspan="27" class="thinborderTOP">- continued on next sheet -</td>
  </tr>
</table>
<%}
if(iPageNumber == 1 && vCurGroupInfo != null) {//In first page show legend for group
%>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
<% for(int i = 0, j = 1; i < vSubGroupInfo.size(); i += 6){
if( i == 0) {vSubGroupInfo.remove(0);%>
  <tr>
	<td colspan="3"> <strong>Subject Group Legend :::</strong></td>
 </tr>
<%}//show only at start.%>
<tr>
	<td>Group <%=j++%> :: <%=(String)vSubGroupInfo.elementAt(i)%></td>
	<td><%if(i + 2 < vSubGroupInfo.size()) {%>Group <%=j++%> :: <%=(String)vSubGroupInfo.elementAt(i + 2)%><%}%></td>
	<td><%if(i + 4 < vSubGroupInfo.size()) {%>Group <%=j++%> :: <%=(String)vSubGroupInfo.elementAt(i + 4)%><%}%></td>
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
                <td width="40%" height="15"><strong>RECOMMENDED FOR GRADUATION:</strong></td>
                <td width="60%" height="15">&nbsp;</td>
              </tr>
              <tr>
                <td height="15">&nbsp;</td>
                <td height="15" valign="bottom"><div align="center"><%=WI.getStrValue(WI.fillTextValue("dean_name")).toUpperCase()%></div></td>
              </tr>
              <tr>
                <td height="15">&nbsp;</td>
                <td height="15" valign="top"><div align="center">Dean</div></td>
              </tr>
              <tr>
                <td height="15">&nbsp;</td>
                <td height="15">&nbsp;</td>
              </tr>
              <tr>
                <td height="15" colspan="2"><div align="center"><strong>CERTIFICATION</strong></div></td>
              </tr>
              <tr>
                <td height="15" colspan="2">&nbsp;</td>
              </tr>
              <tr>
                <td height="15" colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I
                  hereby certify that the foregoing records of <u><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase().charAt(0)%>.</u> a candidate for graduation in this Institution
                  , have been verified by me and that copies of official records
                  substantiating same are kept in the files of this university.<br>
                  I also certify that this student is enrolled in <%=WI.getStrValue(WI.fillTextValue("date_enrolled"))%></td>
              </tr>
            </table>


            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td height="15" colspan="2">&nbsp;</td>
                <td height="15" valign="bottom">&nbsp;</td>
              </tr>
              <tr>
                <td height="15" colspan="2">&nbsp;</td>
                <td width="57%" height="15" valign="bottom"><div align="center"><%=WI.getStrValue(WI.fillTextValue("registrar_name")).toUpperCase()%></div></td>
              </tr>
              <tr>
                <td height="15" colspan="2">&nbsp;</td>
                <td height="15" valign="top"><div align="center">University Registrar</div></td>
              </tr>
              <tr>
                <td width="12%" height="15">Prepared by :</td>
                <td width="31%" height="15">&nbsp;</td>
                <td height="15">&nbsp;</td>
              </tr>
              <tr>
                <td height="15">&nbsp;</td>
                <td height="15"><%=WI.getStrValue(WI.fillTextValue("prep_by1")).toUpperCase()%></td>
                <td height="15">&nbsp;</td>
              </tr>
              <tr>
                <td height="15">&nbsp;</td>
                <td height="15">Records Clerk</td>
                <td height="15">&nbsp;</td>
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
