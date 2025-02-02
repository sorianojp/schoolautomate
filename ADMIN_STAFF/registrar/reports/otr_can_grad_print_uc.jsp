<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

body {
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #aaaaaa;
    border-right: solid 1px #aaaaaa;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #aaaaaa;
    border-left: solid 1px #aaaaaa;
    border-right: solid 1px #aaaaaa;
    border-bottom: solid 1px #aaaaaa;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborder {
    border-left: solid 1px #aaaaaa;
    border-bottom: solid 1px #aaaaaa;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #aaaaaa;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #aaaaaa;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-left: solid 1px #aaaaaa;
    border-top: solid 1px #aaaaaa;
    border-bottom: solid 1px #aaaaaa;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #aaaaaa;
    border-bottom: solid 1px #aaaaaa;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #aaaaaa;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #aaaaaa;
    border-right: solid 1px #aaaaaa;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #aaaaaa;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBOTTOMDotted {
    border-bottom:dotted 1px #aaaaaa;
	font-family:Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

</style>
</head>

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
	String strTotalPageNumber = WI.fillTextValue("total_page");

	int iRowsPrinted = 0;
	//int iMaxRowToDisp = Integer.parseInt(WI.fillTextValue("max_page_to_disp"));
	int iMaxRowToDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_page_to_disp"), "0"));
	
	String strPrintPage = WI.fillTextValue("print_");//"1" is print. 
	
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
boolean bolShowFooter = true;
boolean bolShowOnlyFooter = false;//last page shows Details only.. 
//boolean bolSplitFooter    = false;//this happens when first page contains last page and 

	boolean bolIsEndOfContent = false;//this indicates there is still one more page to print but already done printing data.
	if(iLastPage == 0 && (iMaxRowToDisp > iRowCount)) {
		bolIsEndOfContent = true;
		bolShowFooter = false;// do not show the footer content.
	}
	else if(iLastPage == 1 && iRowCount == 0) {
		bolIsEndOfContent = false;
		bolShowOnlyFooter = true;
	}
	else if(iLastPage == 1)
		bolIsEndOfContent = true;
	
	//i have to check if first page contains last page.
	////if(iPageNumber == 1 && iLastPage == 1 && iRowCount > 23) {
	//	bolSplitFooter = true;
	//	bolShowFooter = false;
	//	strTotalPageNumber = "2";
	//}

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
java.sql.ResultSet rs = null;

if(!WI.fillTextValue("tf_sel_list").equals("-1")) {
	if(WI.fillTextValue("tf_sel_list").length() == 0) 
		repRegistrar.strTFList = "0";
	else	
		repRegistrar.strTFList = WI.fillTextValue("tf_sel_list");
}
///// extra condition for the selected courses
boolean viewAll = true;
int iMaxCourseDisplay = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_course_disp"),"0"));
String[] strTok = null; Vector vCourseSelected = new Vector();
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
/////////////end of extra Con.
//to identify if this is crossed enrolled.
Vector vCrossEnrollSYTerm = new Vector();


if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		///get all the subject completed as crossed erolled.
		strSQLQuery = "select distinct sy_from, semester from g_sheet_final join stud_curriculum_hist on (stud_curriculum_hist.cur_hist_index = g_sheet_final.cur_hist_index) "+
					" where user_index_ = "+(String)vStudInfo.elementAt(12)+" and g_sheet_final.is_valid = 1 and CE_SCH_INDEX is not null";
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next())
			vCrossEnrollSYTerm.addElement(rs.getString(1)+"-"+rs.getString(2));
		rs.close();
	
	
///I have to update subject group here. 
strSQLQuery = "select sg_index from SUB_GROUP_MAP_FORM19 where course_index_ = "+vStudInfo.elementAt(5);
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null) {
	strSQLQuery = "update SUBJECT_GROUP set GROUP_NAME = (select SG_NAME from SUB_GROUP_MAP_FORM19 where sg_index = GROUP_INDEX and course_index_ = "+
							vStudInfo.elementAt(5)+") where  group_index in (select sg_index from  SUB_GROUP_MAP_FORM19 where course_index_ = "+vStudInfo.elementAt(5)+")";
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
		repRegistrar.setGetCreditSubject(2);
		
		vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType,false,strExtraCon);
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
	}//System.out.println(strExtraCon);
	//I have to get the subject group information as well.
	if(strErrMsg == null) {
		vSubGroupInfo = repRegistrar.getRecordsOfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, strExtraCon);
		if(vSubGroupInfo == null)
			strErrMsg = repRegistrar.getErrMsg();
		
		vCurGroupInfo = repRegistrar.getSubGroupUnitOfStud(dbOP, WI.fillTextValue("stud_id"),vSubGroupInfo);
		if(vCurGroupInfo == null)
			strErrMsg = eData.getErrMsg();
	}
}
//System.out.println(vRetResult);
//System.out.println("Sub Group: "+vSubGroupInfo);
//System.out.println("Cur Group: "+vCurGroupInfo);



dbOP.rollbackOP();
dbOP.forceAutoCommitToTrue();

String strGetTuitionType = "select tution_type from stud_curriculum_hist join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) where user_index = "+vStudInfo.elementAt(12)+" and stud_curriculum_hist.is_valid = 1 and sy_from = ";


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
	
	//System.out.println(vSubGroupInfo);
	double dTotalGroupUnit = 0d;
	for(int i  = 1; i < vSubGroupInfo.size(); i += 2)
		dTotalGroupUnit += Double.parseDouble(WI.getStrValue((String)vSubGroupInfo.elementAt(i + 1), "0"));
	strTemp = CommonUtil.formatFloat(dTotalGroupUnit, true);
	strTemp = strTemp.substring(0, strTemp.length() - 1);
	vSubGroupInfo.setElementAt(strTemp, 0);
}

String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";


//I have to get addl number of groups.
Vector vSubjGroupIP = new Vector();//group name, units.
int iAddlGroup =  0;
if(vCurGroupInfo != null && vCurGroupInfo.size() > 0) {
	iAddlGroup = vCurGroupInfo.size() / 2 - 10;
	if(iAddlGroup < 0)
		iAddlGroup = 0;
}%>
<body topmargin="0" <%if(strPrintPage.equals("1") && !WI.fillTextValue("print_").equals("0")){%> onLoad="window.print();"<%}%>>
<form action="./otr_can_grad_print_uc.jsp" method="post" name="form_">
<%if(iPageNumber == 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">

  <tr>
    <td colspan="2"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1">Baguio City</font><br>        
        APPLICATION FOR ISSUANCE OF REGISTRY OF GRADUATES NO.</div></td>
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


if(vAdditionalInfo != null) {
	if(iPageNumber == 1){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr>
	<td width="15%">&nbsp;Name :</td>
	<td width="50%" class="thinborderBOTTOMDotted"><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,
	<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%>
	<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
	<td width="15%" align="right">Student No. :</td>
	<td class="thinborderBOTTOMDotted"><strong><%=WI.fillTextValue("stud_id").toUpperCase()%></strong></td>
</tr>
<tr>
	
	<td>&nbsp;Place of Birth :</td>
	<td class="thinborderBOTTOMDotted"><strong><%=WI.getStrValue(vAdditionalInfo.elementAt(2),"").toUpperCase()%></strong></td>
	<td align="right">Date of Birth : </td>
	<td class="thinborderBOTTOMDotted"><strong><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></strong></td>
</tr>
<tr>
	
	<td>&nbsp;Address :</td>
	<td class="thinborderBOTTOMDotted">
		<strong><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3)).toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","").toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","").toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","").toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","").toUpperCase()%></strong></td>
	<td align="right">Gender :</td>
	<td class="thinborderBOTTOMDotted"><strong><%=WI.getStrValue((String)vAdditionalInfo.elementAt(0)).toUpperCase()%></strong></td>
</tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td colspan="4">PRELIMINARY EDUCATION:</td></tr>
<tr>	
	<td width="30%">&nbsp;Primary Grades Completed at</td>
	<td width="43%" class="thinborderBOTTOMDotted"><%
	if(vEntranceData != null)
		strTemp = WI.getStrValue(WI.getStrValue(vEntranceData.elementAt(14)).toUpperCase(), "&nbsp;");
		//strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(14)));
	else	
		strTemp = "&nbsp;";
	%> <strong><%=strTemp%></strong></td>
	<td width="7%" align="right">Year :</td>
	<td class="thinborderBOTTOMDotted"><%
	strTemp = "";
	if(vEntranceData != null) {
		//strTemp = WI.getStrValue(vEntranceData.elementAt(19));
		if(vEntranceData.elementAt(18) != null)
			strTemp = (String)vEntranceData.elementAt(18);
			//if(strTemp != null && strTemp.length() > 0) 
				//strTemp = strTemp + " - " +(String)vEntranceData.elementAt(20);
			else
				strTemp = "&nbsp;";
				//strTemp = (String)vEntranceData.elementAt(20);
		
	}
	else	
		strTemp = "&nbsp;";
	%> <strong><%=strTemp%></strong></td>
</tr>
<tr>	
	<td>&nbsp;Intermediate  Grades Completed at</td>
	<td class="thinborderBOTTOMDotted"><%
	if(vEntranceData != null)
		strTemp = WI.getStrValue(WI.getStrValue(vEntranceData.elementAt(16)).toUpperCase(),"&nbsp;");
		//strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
	else	
		strTemp = "&nbsp;";
	%> <strong><%=strTemp%></strong></td>
	<td align="right">Year :</td>
	<td class="thinborderBOTTOMDotted"><%
	strTemp = "";
	if(vEntranceData != null) {
		//strTemp = WI.getStrValue(vEntranceData.elementAt(19));
		if(vEntranceData.elementAt(20) != null)
			strTemp = (String)vEntranceData.elementAt(20);
			//if(strTemp != null && strTemp.length() > 0) 
				//strTemp = strTemp + " - " +(String)vEntranceData.elementAt(20);
			else
				strTemp = "&nbsp;";
				//strTemp = (String)vEntranceData.elementAt(20);
		
	}
	else	
		strTemp = "&nbsp;";
	%> <strong><%=strTemp%></strong></td>
</tr>
<tr>	
	<td>&nbsp;Secondary Grades Completed at</td>
	<td class="thinborderBOTTOMDotted"><%
	if(vEntranceData != null)
		strTemp = WI.getStrValue(WI.getStrValue(vEntranceData.elementAt(5)).toUpperCase(),"&nbsp;");
	else	
		strTemp = "&nbsp;";
	%> <strong><%=strTemp%></strong> </td>
	<td align="right">Year :</td>
	<td class="thinborderBOTTOMDotted"><%
	strTemp = "";
	if(vEntranceData != null) {
		//strTemp = WI.getStrValue(vEntranceData.elementAt(19));
		if(vEntranceData.elementAt(22) != null)
			strTemp = (String)vEntranceData.elementAt(22);
			//if(strTemp != null && strTemp.length() > 0) 
				//strTemp = strTemp + " - " +(String)vEntranceData.elementAt(20);
		else
			strTemp = "&nbsp;";
				//strTemp = (String)vEntranceData.elementAt(20);
		
	}
	else	
		strTemp = "&nbsp;";
	%> <strong><%=strTemp%></strong></td>
</tr>

</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td height="15px" colspan="3"></td></tr>
<tr>	
	<td width="16%">&nbsp;Entrance Data: </td>
	<td width="52%" class="thinborderBOTTOMDotted"><strong><%=WI.fillTextValue("entrance_data").toUpperCase()%></strong></td>
	<td width="15%" align="right">Date of Admission:</td>
	<td width="17%" class="thinborderBOTTOMDotted">
	<% if(vEntranceData != null) {%>
		<strong><%=WI.getStrValue((String)vEntranceData.elementAt(23),"&nbsp;")%> </strong>
	<%}else{%> &nbsp; <%}%></td>	
</tr>
<tr>	
	<td>&nbsp;Other Admission Credentials:</td>
    <td colspan="3" class="thinborderBOTTOMDotted"><strong><%=WI.fillTextValue("adm_cre1").toUpperCase()%><%=WI.getStrValue(WI.fillTextValue("adm_cre2"),"/","","").toUpperCase()%></strong></td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td colspan="4" height="15px"></td></tr>
<tr>	
	<td width="15%">&nbsp;Course: </td>
	<td width="53%" class="thinborderBOTTOMDotted"><strong><%=(String)vStudInfo.elementAt(7)%></strong></td>	
	<td width="15%" align="right">Date of Graduation:</td>	
	<td width="17%" class="thinborderBOTTOMDotted"><strong><%=WI.fillTextValue("date_grad")%></strong></td>
</tr>
<tr><td colspan="4" height="15px"></td></tr>
</table>
<%}//end iPageNumber == 1
}//end vAdditionalinfo%>




<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="720px" valign="top" onDblClick="PrintNextPage();">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<%if(!bolShowOnlyFooter){%>
				  <tr>
					<td width="12%" class="thinborderTOPBOTTOM"><div align="center"><strong>SUBJECT NAME</strong></div></td>
					<td width="48%" class="thinborderTOPBOTTOM"><div align="center"><strong>DESCRIPTIVE TITLE</strong></div></td>
					<td width="5%" class="thinborderTOPBOTTOM"><div align="center"><strong>GRADES</strong></div></td>
					<td width="5%" class="thinborderTOPBOTTOM"><div align="center"><strong>UNITS</strong></div></td>
					
					<td width="3%" class="thinborderTOPBOTTOM"><div align="center"><strong>1</strong></div></td>
					<td width="3%" class="thinborderTOPBOTTOM"><div align="center"><strong>2</strong></div></td>
					<td width="3%" class="thinborderTOPBOTTOM"><div align="center"><strong>3</strong></div></td>
					<td width="3%" class="thinborderTOPBOTTOM"><div align="center"><strong>4</strong></div></td>
					<td width="3%" class="thinborderTOPBOTTOM"><div align="center"><strong>5</strong></div></td>
					<td width="3%" class="thinborderTOPBOTTOM"><div align="center"><strong>6</strong></div></td>
					<td width="3%" class="thinborderTOPBOTTOM"><div align="center"><strong>7</strong></div></td>
					<td width="3%" class="thinborderTOPBOTTOM"><div align="center"><strong>8</strong></div></td>
					<td width="3%" class="thinborderTOPBOTTOM"><div align="center"><strong>9</strong></div></td>
					<td width="3%" class="thinborderTOPBOTTOM"><div align="center"><strong>10</strong></div></td>
					<%for(int j = 0; j < iAddlGroup; ++j) {%>
					<td width="3%" class="thinborderTOPBOTTOM"><div align="center"><strong><%=(10 + j + 1)%></strong></div></td>
					<%}%>
				  </tr>
				  <%}
				int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
				String strSchoolName = null;
				String strPrevSchName = null;
				String strSchNameToDisp = null;
				
				String strSYSemToDisp   = null;
				String strCurSYSem      = null;
				String strPrevSYSem     = null;
				String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};
				String[] astrConvertTri = {"SUMMER","FIRST TRIMESTER","SECOND TRIMESTER","THIRD TRIMESTER",""};
				
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
					strTemp = (String)vRetResult.elementAt(i + 9);
					if(strTemp != null && strTemp.indexOf("hrs") > -1) {
						strTemp = strTemp.substring(0,strTemp.indexOf(" ("));
						vRetResult.setElementAt(strTemp, i + 9);
					}
					
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
					if(vRetResult.elementAt(i) != null && bolIsSchNameNull && vCrossEnrollSYTerm.size() > 0) //cross enrolled.
						if(vCrossEnrollSYTerm.indexOf((String)vRetResult.elementAt(i + 1) +"-"+(String)vRetResult.elementAt(i + 3)) > -1)	
							strSchoolName += " - W/PERMIT FROM UC";
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
						strSQLQuery = strGetTuitionType + (String)vRetResult.elementAt(i+ 1)+" and semester = "+(String)vRetResult.elementAt(i+ 3);
						strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery,0);
						if(strSQLQuery != null && strSQLQuery.equals("1")) {
							strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+", "+
										(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2); 
						}
						else	
							strCurSYSem = astrConvertTri[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+", "+
										(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2); 
					}
					else {
						strCurSYSem = (String)vRetResult.elementAt(i+ 3)+", "+(String)vRetResult.elementAt(i+ 1)+" - "+
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
				
					//if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//cross enrolled.
					//	if(strCrossEnrolleeSchPrev == null || strCrossEnrolleeSchPrev.compareTo(strSchoolName) != 0)  {
					//		strCrossEnrolleeSchPrev = strSchoolName;
					//		strCrossEnrolleeSch     = strSchoolName;
					//		strSYSemToDisp = strCurSYSem;
					//	}
					//}
				
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
				if(dTemp == 0d)
					iIndexOfSubGroup = 0;//do not place under group column if ce is 0.
					
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
					<td height="14" colspan="15"><strong><%=WI.getStrValue(strSchNameToDisp).toUpperCase()%> </strong></td>
					<%for(int j = 0; j < iAddlGroup; ++j) {%>
					<%}%>
				  </tr>
				  <%
				  strPrevSchName = strSchNameToDisp;
				  }
				  
				 if(strSYSemToDisp != null){
					if(strSYSemToDisp.startsWith("1ST"))
						strSYSemToDisp = "FIRST"+strSYSemToDisp.substring(3);
					if(strSYSemToDisp.startsWith("2ND"))
						strSYSemToDisp = "SECOND"+strSYSemToDisp.substring(3);
					strSYSemToDisp = strSYSemToDisp.toUpperCase();			
					
					if(strSYSemToDisp.startsWith("SUMMER"))
						strSYSemToDisp = "SUMMER, " + strSYSemToDisp.substring(strSYSemToDisp.length() - 4);
				 
				 %>
				  <tr>
					<td height="14" colspan="15"><strong> <%=strSYSemToDisp%></strong></td>
					<%for(int j = 0; j < iAddlGroup; ++j) {%>
					<%}%>
				  </tr>
				  <%strSYSemToDisp = null;}
				  strTemp = WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;");
				  	iIndexOf = strTemp.indexOf("(");
					if(iIndexOf > -1)
						strTemp = strTemp.substring(0, iIndexOf);
					
					//if(strTemp.startsWith("NSTP")) {
					//	System.out.println("Printing nstp only: "+vRetResult.elementAt(i+ 10));
					//}
				%> 
				  
				
				  <tr>
					<td width="15%" height="14"><%=strTemp%></td>
					<td width="25%"><%=vRetResult.elementAt(i + 7)%></td>
					<td align="center"> <%if(bolReExam) strTemp = (String) vRetResult.elementAt(i - 11 + 8);
													 else strTemp = (String)vRetResult.elementAt(i + 8);
													 if (WI.getStrValue(strTemp).startsWith("on")) {
													 		strTemp = "IP ";
															vSubjGroupIP.addElement(vRetResult.elementAt(i+ 10));
															vSubjGroupIP.addElement(vRetResult.elementAt(i+ 9));
													 }
													 %> <%=WI.getStrValue(strTemp, "&nbsp;")%></td>
					<td align="center">&nbsp;<%if (WI.getStrValue(strTemp).startsWith("IP ")) strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"(",")","&nbsp;");
														else strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"&nbsp;");
														
						if(strTemp != null && strTemp.length() > 0 && strTemp.indexOf(".") > -1)
							strTemp = strTemp.substring(0, strTemp.indexOf("."));
						%>			
														<%=strTemp%>	</td>
					
					<td align="center">&nbsp; <%if(iIndexOfSubGroup == 1){%> <%=strTemp%> <%}%></td>
					<td align="center">&nbsp; <%if(iIndexOfSubGroup == 2){%> <%=strTemp%> <%}%></td>
					<td align="center">&nbsp; <%if(iIndexOfSubGroup == 3){%> <%=strTemp%> <%}%></td>
					<td align="center">&nbsp; <%if(iIndexOfSubGroup == 4){%> <%=strTemp%> <%}%></td>
					<td align="center">&nbsp; <%if(iIndexOfSubGroup == 5){%> <%=strTemp%> <%}%></td>
					<td align="center">&nbsp; <%if(iIndexOfSubGroup == 6){%> <%=strTemp%> <%}%></td>
					<td align="center">&nbsp; <%if(iIndexOfSubGroup == 7){%> <%=strTemp%> <%}%></td>
					<td align="center">&nbsp; <%if(iIndexOfSubGroup == 8){%> <%=strTemp%> <%}%></td>
					<td align="center">&nbsp; <%if(iIndexOfSubGroup == 9){%> <%=strTemp%> <%}%></td>
					<td align="center">&nbsp; <%if(iIndexOfSubGroup == 10){%> <%=strTemp%> <%}%></td>
					<%for(int j = 0; j < iAddlGroup; ++j) {%>
					<td width="3%" align="center">&nbsp;
						<%if(iIndexOfSubGroup == (12 + j + 1)){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
					<%}%>
				  </tr>
				  <%
				   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
				  <%=strHideRowRHS%>
				  <%}
				 }//end of for loop%>

		  </table>

				<%if(bolIsEndOfContent){%>
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E5E5E5">
						<tr><td align="center" class="thinborderTOP">GRADE ENTRY BELOW THIS LINE NOT VALID</td></tr>
					</table>
				<%}
				if(bolShowOnlyFooter || (bolIsEndOfContent && vSubGroupInfo != null && vSubGroupInfo.size() > 0 && bolShowFooter)) {%>
					<table width="100%" cellpadding="0" cellspacing="0" border="0">					
					<tr><td colspan="4">&nbsp;</td></tr>
					<tr><td align="center" height="15px">&nbsp;</td>
					  <td height="15px" colspan="2" align="center" class="thinborderTOPBOTTOM">SUMMARY OF GROUP DISTRIBUTION</td>
					  <td align="center" height="15px">&nbsp;</td>
					</tr>					
					<%
					String strTotalSubGroup = (String)vSubGroupInfo.remove(0);
					//System.out.println(vSubjGroupIP);
					double dTotalSubGroup = Double.parseDouble(WI.getStrValue(strTotalSubGroup, "0"));
					dTemp = 0d;
					//if(false)
					for(int i = 0; i < vSubGroupInfo.size(); i += 2){
						while(vSubjGroupIP.size() > 0) {
							iIndexOf = vSubjGroupIP.indexOf(vSubGroupInfo.elementAt(i));
							if(iIndexOf == -1)
								break;
							dTemp = Double.parseDouble(WI.getStrValue(vSubjGroupIP.elementAt(iIndexOf + 1), "0"));
							if(dTemp > 0) {
								dTotalSubGroup += dTemp;
								
								dTemp += Double.parseDouble(WI.getStrValue(vSubGroupInfo.elementAt(i + 1), "0"));
								vSubGroupInfo.setElementAt(String.valueOf(dTemp), i + 1);
							}
							vSubjGroupIP.remove(iIndexOf);vSubjGroupIP.remove(iIndexOf);
						}
					}
					
					strTotalSubGroup = String.valueOf(dTotalSubGroup);
					
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
						<td align="center" class="thinborderTOP">*** TOTAL GROUP DISTRIBUTION ***</td>
						<%
						iIndexOf = strTotalSubGroup.indexOf(".0");
						if(iIndexOf > -1)
							strTotalSubGroup = strTotalSubGroup+"0";
						%>
						<td align="right" class="thinborderTOP"><%=strTotalSubGroup%></td>
						<td>&nbsp;</td>
					</tr>
					</table>
				<%}
				
				if(bolShowOnlyFooter || (bolIsEndOfContent && bolShowFooter)){ %>
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
						<tr><td height="14">&nbsp;</td></tr>
						<tr><td align="center"><font size="2">C E R T I F I C A T I O N</font></td></tr>
						<tr><td height="14">&nbsp;</td></tr>
						<tr>
							<td style="text-indent:50px; text-align:justify;">
								I HEREBY CERTIFY that the foregoing records of 
								<strong>
								<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
								<%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
								<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%>			
								</strong> has been verified by me, and that the true copies of the
								official records substantiating the same are kept in the files of the college.
							</td>
						</tr>	
					</table>
					
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="70%">&nbsp;</td>
							<td align="center" class="thinborderBOTTOM"><%=WI.getStrValue(WI.fillTextValue("registrar_name")).toUpperCase()%></td>
						</tr>
						<tr>
							<td width="70%">&nbsp;</td>
							<td align="center">Registrar</td>
						</tr>
					</table>
				<%}%>

		</td>
	</tr>
	
</table>




<%}//end if vRetResult != null && vRetResult.size() > 0%>




		  		<%//if(iLastPage != 1){ %>
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E5E5E5">
					  <tr>
						<td width="52%" height="14" class="thinborderTOP"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,
						<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%>
						<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%>
						(<%=WI.fillTextValue("stud_id")%>)
						</td>
						<td width="48%" class="thinborderTOP">Page <%=iPageNumber%> of <%=strTotalPageNumber%></td>
					  </tr>
					</table>
				<%//}%>





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

<input type="hidden" name="adm_cre1" value="<%=WI.fillTextValue("adm_cre1")%>" >
<input type="hidden" name="adm_cre2" value="<%=WI.fillTextValue("adm_cre2")%>" >
<input type="hidden" name="entrance_data" value="<%=WI.fillTextValue("entrance_data")%>" >
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
