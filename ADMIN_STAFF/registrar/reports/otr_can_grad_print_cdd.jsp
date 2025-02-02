<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

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

Vector vGraduationData = null;

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
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,	(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
			
		vEntranceData = eData.operateOnEntranceData(dbOP, request,4);
		vGraduationData = eData.operateOnGraduationData(dbOP,request,4);
		if(vEntranceData == null || vGraduationData == null)
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
		
		//vCurGroupInfo = repRegistrar.getSubGroupUnitOfStud(dbOP, WI.fillTextValue("stud_id"),vSubGroupInfo);
		//if(vCurGroupInfo == null)
			//strErrMsg = eData.getErrMsg();
	}
}

dbOP.rollbackOP();
dbOP.forceAutoCommitToTrue();

java.sql.ResultSet rs = null;
Vector vTemp = new Vector();
int iIndexOf = 0;
if(vSubGroupInfo != null && vSubGroupInfo.size() > 0) {
	strSQLQuery = "select SG_NAME from SUB_GROUP_MAP_FORM19 where course_index_ = "+vStudInfo.elementAt(5) + " order by ORDER_NO";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		iIndexOf = vSubGroupInfo.indexOf(rs.getString(1));
		if(iIndexOf == -1)
			continue;
		vTemp.addElement(vSubGroupInfo.remove(iIndexOf));
		vTemp.addElement(vSubGroupInfo.remove(iIndexOf));
	}
	rs.close();
}
if(vTemp.size() > 0) {
	vTemp.insertElementAt(vSubGroupInfo.remove(0), 0);
	vSubGroupInfo = vTemp;
}

String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";


//if(iPageNumber == 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">

  <tr>
    <td colspan="2"><div align="center"><font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
		<%if(strSchCode.startsWith("CDD")){%>(formerly Computronix College)<%}%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
        <br>
        <br>
        <strong>RECORD OF CANDIDATES FOR GRADUATION</strong></font></div></td>
  </tr>
</table>
<%//}
if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><font size="3"><%=strErrMsg%></font>
		</td>
	</tr>
</table>
<%dbOP.cleanUP();return;}


if(vAdditionalInfo != null) {
	//if(iPageNumber == 1){%>
	
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
	  <td width="24%">&nbsp;</td>
	  <td width="38%">&nbsp;</td>
	  <td width="16%">&nbsp;</td>
	  <td width="22%">&nbsp;</td>
  </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
  </tr>
	<tr>
		<td colspan="2">ID:<strong> <%=WI.fillTextValue("stud_id").toUpperCase()%></strong></td>
		<td colspan="2">Date of Graduation: <strong><%=WI.fillTextValue("date_grad")%></strong></td>
	</tr>
	<tr>
		<td colspan="2">Name:<strong> <%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,
	    <%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%>
	    <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
		<td colspan="2">BR No./SO No.: <strong><%=WI.getStrValue(strTemp)%></strong></td>
	    <%
	strTemp = "";
	if(vGraduationData != null && vGraduationData.size()!=0)
		strTemp = WI.getStrValue(vGraduationData.elementAt(6));
	%>
	</tr>
	<tr>
		<td colspan="2">Address:<strong> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","")%></strong></td>
		<%
		strTemp = "";
		if (vEntranceData != null && vEntranceData.size()>0){
			strTemp = (String)vEntranceData.elementAt(7);
			if (strTemp == null) 
				strTemp = (String)vEntranceData.elementAt(5);
   		}		
		%>
		<td rowspan="3" colspan="2" valign="top">Last School Attended : <strong><%=strTemp%></strong></td>		
	</tr>
	<tr>
		<td colspan="2">Date of Birth: <strong><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></strong></td>
	</tr>
	<tr>
		<td colspan="2">Age:<strong>
		<%if(vStudInfo.elementAt(19) != null) {%>
			<%=CommonUtil.calculateAGEDatePicker((String)vStudInfo.elementAt(19))%>
		<%}else{%>
			&nbsp;
		<%}%>
		<%//=vStudInfo.elementAt(5)%>
		
		</strong> &nbsp; &nbsp; Sex : <strong><%=WI.getStrValue((String)vAdditionalInfo.elementAt(0))%></strong></td>
	</tr>
	<tr>
		<td colspan="2">Place of Birth: <strong><%=WI.getStrValue((String)vAdditionalInfo.elementAt(2))%></strong></td>
		<td rowspan="2" colspan="2" valign="top">Highest Educ'l Attainment: 
		<strong><%=WI.fillTextValue("highest_edu")%></strong></td>
			
	</tr>
	<tr>
		<td colspan="2">Parent's/Guardian's:<strong> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(8), (String)vAdditionalInfo.elementAt(13))%></strong></td>
	</tr>
	
	<tr><td height="25" colspan="4">&nbsp;</td></tr>
	<tr><td>Title/Degree</td><td colspan="3"><strong><%=WI.getStrValue((String)vStudInfo.elementAt(7))%></strong></td></tr>
</table>




<%}//end vAdditionalinfo



if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="760px" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				  <tr>
					<td width="15%"><div align=""><strong>CODE</strong></div></td>
					<td width="25%"><div align=""><strong>DESCRIPTION</strong></div></td>
					<td width="5%"><div align="center"><strong>GRADES</strong></div></td>
					<td width="5%"><div align="center"><strong>UNITS</strong></div></td>
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
				
				
				/*double dSG1 =0d;	double dSG2 =0d;	double dSG3 =0d;	double dSG4 =0d;	double dSG5 =0d;
				double dSG6 =0d;	double dSG7 =0d;	double dSG8 =0d;	double dSG9 =0d;	double dSG10 =0d;
				double dSG11 =0d;	double dSG12 =0d;	double dSG13 =0d;	double dSG14 =0d;	double dTemp =0d;*/
				
				
				String strHideRowLHS = "";// "<!--";
				String strHideRowRHS = "";// "-->";
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
									(String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);
					}
					else {
						strCurSYSem = (String)vRetResult.elementAt(i+ 3)+" "+(String)vRetResult.elementAt(i+ 1)+"-"+
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
				
						//iIndexOfSubGroup = vSubGroupInfo.indexOf(vRetResult.elementAt(i+ 10));
						//if (iIndexOfSubGroup != -1)
						//	iIndexOfSubGroup = iIndexOfSubGroup/2 + 1;
				
				//try{
				//dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				//}catch(NumberFormatException nfe){
				//dTemp = 0d;
				//}
				/*if(iIndexOfSubGroup == 1)  dSG1  += dTemp;	if(iIndexOfSubGroup == 2)  dSG2  += dTemp;
				if(iIndexOfSubGroup == 3)  dSG3  += dTemp;	if(iIndexOfSubGroup == 4)  dSG4  += dTemp;
				if(iIndexOfSubGroup == 5)  dSG5  += dTemp;	if(iIndexOfSubGroup == 6)  dSG6  += dTemp;
				if(iIndexOfSubGroup == 7)  dSG7  += dTemp;	if(iIndexOfSubGroup == 8)  dSG8  += dTemp;
				if(iIndexOfSubGroup == 9)  dSG9  += dTemp;	if(iIndexOfSubGroup == 10) dSG10 += dTemp;
				if(iIndexOfSubGroup == 11) dSG11 += dTemp;	if(iIndexOfSubGroup == 12) dSG12 += dTemp;
				if(iIndexOfSubGroup == 13) dSG13 += dTemp;	if(iIndexOfSubGroup == 14) dSG14 += dTemp;*/
				
				 //Very important here, it print <!-- if it is not to be shown.
				 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
				  <%=strHideRowLHS%>
				  <%}
				  
				if(strSchNameToDisp != null && (i == 0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){%>
				  <tr>
					<td height="20" colspan="14"><strong><%=WI.getStrValue(strSchNameToDisp).toUpperCase()%> </strong></td>
				  </tr>
				  <%
				  strPrevSchName = strSchNameToDisp;
				  }
				  
				 if(strSYSemToDisp != null){%>
				  <tr>
					<td height="20" colspan="14"><strong> <%=strSYSemToDisp%></strong></td>
				  </tr>
<%strSYSemToDisp = null;}%> 
				  
				
				  <tr>
					<td width="15%" height="20"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
					<td width="25%"><%=vRetResult.elementAt(i + 7)%></td>
					<td align="center"> 
						<%
						if(bolReExam) 
							strTemp = (String) vRetResult.elementAt(i - 11 + 8);
						else 
						 	strTemp = (String)vRetResult.elementAt(i + 8);%> 
					<%=WI.getStrValue(strTemp, "&nbsp;")%></td>
					<td align="center">&nbsp;
						<%
						if (WI.getStrValue(strTemp).startsWith("on")) 
							strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"(",")","&nbsp;");
						else 
							strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"&nbsp;");%>
						
						<%=strTemp%>	</td>
				  </tr>
				  <%
				   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
				  <%=strHideRowRHS%>
				  <%}
				 }//end of for loop%>
		  </table>
				
				<%if(vSubGroupInfo != null && vSubGroupInfo.size() > 0) {%>
					<table width="100%" cellpadding="0" cellspacing="0" border="0">					
					<tr><td colspan="4">&nbsp;</td></tr>
					<tr><td align="center" colspan="4" height="15px"><strong>SUMMARY OF CREDITS EARNED</strong></td></tr>					
					<tr>
						<td>&nbsp;</td>
						<td><strong>GROUP</strong></td>
						<td align="right"><strong>UNITS</strong></td>
						<td></td>
					</tr>
					
					<%
					String strTotalSubGroup = (String)vSubGroupInfo.remove(0);
					
					for(int i = 0; i < vSubGroupInfo.size(); i += 2){
						strTemp = (String)vSubGroupInfo.elementAt(i+1);
						iIndexOf = strTemp.indexOf(".0");
						if(iIndexOf > -1)
							strTemp = strTemp+"0";
					%>
					<tr>
						<td width="20%">&nbsp;</td>
						<td width="50%"><%=(String)vSubGroupInfo.elementAt(i)%></td>
						<td align="right" width="7%"><%=strTemp%></td>
						<td>&nbsp;</td>
					</tr>
					<%}%>				
					
					<tr>
						<td>&nbsp;</td>
						<td align=""><strong>TOTAL</strong></td>
						<%
						iIndexOf = strTotalSubGroup.indexOf(".0");
						if(iIndexOf > -1)
							strTotalSubGroup = strTotalSubGroup+"0";
						%>
						<td align="right"><strong><%=strTotalSubGroup%></strong></td>
						<td>&nbsp;</td>
					</tr>
					<tr><td height="10" valign="bottom" colspan="4"><hr size="1"></td></tr>
					</table>
				<%}
				
				%>
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
						<tr><td height="15"></td></tr>
						<tr><td align="center"><font size="2"><strong>CERTIFICATION</strong></font></td></tr>
						<tr><td height="20">&nbsp;</td></tr>
						<tr>
							<td style="text-align:justify;">
								I hereby certify that foregoing records of 
								<strong>
								<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
								<%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
								<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%>			
								</strong>
								are verified by me and that
								true copies of the official records substantiating same 
								are kept in the files of the school.								
							</td>
						</tr>	
					</table>
					
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
						<tr>
						  <td>&nbsp;</td>
						  <td align="center">&nbsp;</td>
					  </tr>
						<tr>
						  <td>&nbsp;</td>
						  <td align="center">&nbsp;</td>
					  </tr>
						<tr>
						  <td>&nbsp;</td>
						  <td align="center">&nbsp;</td>
					  </tr>
						<tr>
						  <td>&nbsp;</td>
						  <td align="center">&nbsp;</td>
					  </tr>
						<tr>
							<td width="70%">&nbsp;</td>
							<td align="center"><strong><%=WI.getStrValue(WI.fillTextValue("registrar_name")).toUpperCase()%></strong></td>

						</tr>
						<tr>
							<td width="70%">&nbsp;</td>
							<td align="center"><%=WI.getStrValue(WI.fillTextValue("registrar_designation"),"Registrar")%></td>
						</tr>
					</table>				
		</td>
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
