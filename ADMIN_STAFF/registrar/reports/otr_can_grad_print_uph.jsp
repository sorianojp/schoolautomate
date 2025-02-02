<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

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
	
	TABLE.thinborderTOPRIGHTBOTTOM {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
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
	TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
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
	int iRowSpan = 0;
	//int iRowStartFr = Integer.parseInt(WI.fillTextValue("row_start_fr"));
	//int iRowCount   = Integer.parseInt(WI.fillTextValue("row_count"));
	//int iRowEndsAt  = iRowStartFr + iRowCount;
	//int iLastPage   = Integer.parseInt(WI.fillTextValue("last_page"));
	
	int iRowStartFr = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_start_fr"), "0"));
	int iRowCount   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_count"), "0"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"), "0"));


	//int iPageNumber = Integer.parseInt(WI.fillTextValue("page_number"));
	int iPageNumber = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_number"), "0"));
	int iRowsPrinted = 0;
	//int iMaxRowToDisp = Integer.parseInt(WI.fillTextValue("max_page_to_disp"));
	int iMaxRowToDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_page_to_disp"), "0"));

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


if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><font size="3"><%=strErrMsg%></font>
		</td>
	</tr>
</table>
<%dbOP.cleanUP();return;}


if(vAdditionalInfo != null) {%>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td><font size="1">(B. PR S Form No. 9) S. 1983</font></td></tr>
	<tr><td align="center"><font size="+1"><strong>RECORD OF CANDIDATE FOR GRADUATION<BR>FROM COLLEGIATE COURSE</strong></font></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="2%" height="20"><strong>I.</strong></td>
		<td><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></td>
	</tr>
	<tr>
		<td width="2%" height="20">II.</td>
		<td>
			<table width="100%">
				<tr>
					<td width="30%">RECORD OF CANDIDATE FOR THE TITLE</td>
					<td class="thinborderBOTTOM"><strong><%=((String)vStudInfo.elementAt(7)).toUpperCase()%></strong></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td height="20">III.</td>
		<td>PERSONAL RECORDS :</td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td>
			<table width="100%">
				<tr>
					<td width="5%">Name: </td>
					<td width="35%" align="center" class="thinborderBOTTOM"><%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%></td>
					<td align="center" class="thinborderBOTTOM"><%=WI.getStrValue(vStudInfo.elementAt(1),"&nbsp;").toUpperCase()%></td>
					<td width="35%" align="center" class="thinborderBOTTOM"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td align="center" valign="top">FIRST NAME</td>
					<td align="center" valign="top">MATERNAL SURNAME</td>
					<td align="center" valign="top">LAST NAME</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>
			<table width="100%">
				<tr>
					<td width="7%">Born in: </td>
					<td width="50%" class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(2),"&nbsp;").toUpperCase()%></td>
					<td width="7%">On :</td>
					<td class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(1),"&nbsp;")%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>
			<table width="100%">
				<tr>
					<td width="15%">Parent or Guardian: </td>
					<td width="42%" class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(13), "&nbsp;")%></td>
					<td width="10%">Occupation :</td>
					<td class="thinborderBOTTOM"><%=WI.getStrValue(vEntranceData.elementAt(28), "&nbsp;")%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td height="20">III.</td>
		<td>RECORDS OF PRELIMINARY EDUCATION: COMPLETED</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>
			<table width="100%">
				<tr>
					<td width="15%">Prim Course</td>
					<%
					strTemp = "&nbsp;";
					if(vEntranceData != null)
						strTemp = WI.getStrValue(vEntranceData.elementAt(14),"&nbsp;");											
					%>
					<td width="40%" class="thinborderBOTTOM"><%=strTemp%></td>
					<%
					strTemp = "&nbsp;";
					if(vEntranceData != null) {						
						if(vEntranceData.elementAt(18) != null)
							strTemp = (String)vEntranceData.elementAt(18);							
							else
								strTemp = "&nbsp;";
					}					
					%>
					<td width="8%" align="center" class="thinborderBOTTOM"><%=strTemp%></td>
					<td>&nbsp;</td>
				</tr>
				
				
				
				<tr>
					<td width="15%">Interm. Course</td>
					<%
					strTemp = "&nbsp;";
					if(vEntranceData != null)
						strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
					%>
					<td width="30%" class="thinborderBOTTOM"><%=strTemp%></td>
					<%
					strTemp = "&nbsp;";
					if(vEntranceData != null) {						
						if(vEntranceData.elementAt(20) != null)
							strTemp = (String)vEntranceData.elementAt(20);							
							else
								strTemp = "&nbsp;";
					}					
					%>
					<td align="center" class="thinborderBOTTOM"><%=strTemp%></td>
					<td>&nbsp;</td>
				</tr>
				
				
				<tr>
					<td>High School</td>
					<%
					strTemp = "&nbsp;";
					if(vEntranceData != null)
						strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");					
					%>
					<td class="thinborderBOTTOM"><%=strTemp%></td>
					<%
					strTemp = "&nbsp;";
					if(vEntranceData != null) {					
						if(vEntranceData.elementAt(22) != null)
							strTemp = (String)vEntranceData.elementAt(22);													
					}	
					%>
					<td align="center" class="thinborderBOTTOM"><%=strTemp%></td>
					<td>&nbsp;</td>
				</tr>				
			</table>
		</td>
	</tr>
	<tr>
		<td>V.</td>
		<td height="20">COLLEGE RECORDS:</td>
	</tr>
	
			
	
</table>



<%}//end vAdditionalinfo


if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="560px" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderTOPRIGHTBOTTOM">
				  <tr>
				  	<td width="8%" class="thinborder" rowspan="2" align="center" valign="top">SEMESTER</td>
					<td width="35%" class="thinborder" rowspan="2" align="center" valign="top">DESCRIPTIVE NAMES OF SUBJECT</td>					
					<td width="5%" class="thinborder" rowspan="2" align="center" valign="top">GRADES</td>
					<%
					int iTemp =  10 + iAddlGroup;
					%>
					<td colspan="<%=iTemp%>" class="thinborder"><div align="center">UNITS</div></td>
				  </tr>
				  <tr>
					<%
					//<td width="5%" class="thinborder"><div align="center">UNITS</div></td>
					%>
					
					<td width="3%" class="thinborder"><div align="center">1</div></td>
					<td width="3%" class="thinborder"><div align="center">2</div></td>
					<td width="3%" class="thinborder"><div align="center">3</div></td>
					<td width="3%" class="thinborder"><div align="center">4</div></td>
					<td width="3%" class="thinborder"><div align="center">5</div></td>
					<td width="3%" class="thinborder"><div align="center">6</div></td>
					<td width="3%" class="thinborder"><div align="center">7</div></td>
					<td width="3%" class="thinborder"><div align="center">8</div></td>
					<td width="3%" class="thinborder"><div align="center">9</div></td>
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
									((String)vRetResult.elementAt(i+ 1)).substring(2)+"-"+((String)vRetResult.elementAt(i+ 2)).substring(2);
					}
					else {
						strCurSYSem = (String)vRetResult.elementAt(i+ 3)+" "+((String)vRetResult.elementAt(i+ 1)).substring(2)+"-"+
											((String)vRetResult.elementAt(i+ 2)).substring(2);
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
				  
				if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){%>
				  <tr>
					<td  class="thinborder" height="20" colspan="15" align="center"><strong><%=WI.getStrValue(strSchNameToDisp).toUpperCase()%> </strong></td>
					<%for(int j = 0; j < iAddlGroup; ++j) {%>
					<%}%>
				  </tr>
				  <%
				  strPrevSchName = strSchNameToDisp;
				  }
				 %> 
				  
				
				  <tr>
				  	<%
					strTemp = "&nbsp;";
					if(strSYSemToDisp != null){						
						strTemp = strSYSemToDisp;
						strSYSemToDisp = null;
					}
					%>
					<td height="20" class="thinborderLEFT"><%=strTemp%></td>			
				  
				  
				  	
					
					<td class="thinborderLEFT">
						<table width="100%">
							<tr>
								<td width="20%"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
								<td><%=vRetResult.elementAt(i + 7)%></td>
							</tr>
						</table>
					</td>					
					<td class="thinborderLEFT" align="center"> <%if(bolReExam) strTemp = (String) vRetResult.elementAt(i + 11 + 8);
													 else strTemp = (String)vRetResult.elementAt(i + 8);%> <%=WI.getStrValue(strTemp, "&nbsp;")%></td>
					
					<%
					//<td class="thinborderLEFT" align="center">
					//	&nbsp;<%if (WI.getStrValue(strTemp).startsWith("on")) strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"(",")","&nbsp;");
					//									else strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"&nbsp;");% %//=strTemp%	</td>
					%>
					
					<%
					 	if(bolReExam) strTemp = (String) vRetResult.elementAt(i + 11 + 9);
						 else strTemp = (String)vRetResult.elementAt(i + 9);
						 
						 if(strTemp.indexOf(".") == -1)
						 	strTemp += ".0";
					%>
					
					
					
					<td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 1){%> <%=strTemp%> <%}%></td>
					<td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 2){%> <%=strTemp%> <%}%></td>
					<td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 3){%> <%=strTemp%> <%}%></td>
					<td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 4){%> <%=strTemp%> <%}%></td>
					<td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 5){%> <%=strTemp%> <%}%></td>
					<td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 6){%> <%=strTemp%> <%}%></td>
					<td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 7){%> <%=strTemp%> <%}%></td>
					<td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 8){%> <%=strTemp%> <%}%></td>
					<td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 9){%> <%=strTemp%> <%}%></td>
					<td class="thinborderLEFT" align="center">&nbsp; <%if(iIndexOfSubGroup == 10){%> <%=strTemp%> <%}%></td>
					<%for(int j = 0; j < iAddlGroup; ++j) {%>
					<td class="thinborderLEFT" width="3%" align="center">&nbsp;
						<%if(iIndexOfSubGroup == (12 + j + 1)){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
					<%}%>
				  </tr>
				  <%
				   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
				  <%=strHideRowRHS%>
				  <%}
				 }//end of for loop%>
		  </table>
		<%if(iLastPage ==1){%>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E5E5E5">
				<tr><td align="center">********** N O T H I N G &nbsp; F O L L O W S **********</td></tr>
			</table>
		<%}%>
		</td>
	</tr>
	
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td colspan="5">Official Remarks: 1.0(95-100), 1.25 (92-94), 1.5(90-91), 1.75(88-89), 2.0(85-87), 2.25(82-84), 2.5(80-81), 2.75(78-79), 5.0(Below 75).</td></tr>
	<tr><td colspan="5">One unit of credits is one hour lecture or recitation or 2 - 3 hours laboratory each week for the period of a complete semester.</td></tr>
	<tr><td colspan="5">If there are two grades for a given subject the second means removal examination grade.</td></tr>
	<tr><td colspan="5">&nbsp;</td></tr>
	<tr><td colspan="5">I certify that the foregoing records of _________<u><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
								<%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
								<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></u>_________ a candidate for graduation, 
			has been verified by me and that true copies of the official records sustaining the same are kept on file in this university.</td></tr>
	<tr><td colspan="5">&nbsp;</td></tr>
	<tr>
		<td width="7%">Date: </td>
		<td width="53%"><div style="border-bottom:solid 1px #000000; text-align:left; width:70%;"><%=WI.getTodaysDate(2)%></div></td>
		<td align="center"><div style="border-bottom:solid 1px #000000; white-space:80%"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%></div></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td align="center" valign="top">Registrar</td>
	</tr>
</table>


<%}//end if vRetResult != null && vRetResult.size() > 0%>

<%
if(WI.fillTextValue("print_").compareTo("1") == 0 ){%>
<script language="javascript">
 window.print();
</script>
<%}//print only if print page is clicked.%>
</body>
</html>
<%
dbOP.cleanUP();
%>
