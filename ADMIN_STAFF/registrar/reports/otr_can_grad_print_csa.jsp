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

.fontsize9 {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 8px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }
	TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }	
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;
    }
    .thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
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
	
	TD.thinborderTOPRIGHTBOTTOM {
	border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }
	
	TD.thinborderTOPLEFTBOTTOM {
	border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }
	
	TD.thinborderTOPLEFT{
	border-top: solid 1px #000000;
    border-left: solid 1px #000000;    
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }
	
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
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
	
    TD.thinborderLEFTRIGHTBOTTOM {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	
	font-size: 11px;	
    }-->
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
	String strImgFileExt = null;

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
Vector vGraduationData = null;
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

if(strErrMsg != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td><font size="3"><%=strErrMsg%></font>
		</td>
	</tr>
</table>
<%dbOP.cleanUP();return;}

if(vAdditionalInfo != null && vAdditionalInfo. size() > 0){
	if(iPageNumber != 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td rowspan="2" class="" style="text-indent:30px;" width="10%"><strong><font size="2">NAME:</font></strong></td>
		<td rowspan="2" class="" valign="bottom"><strong><font size="2">
		<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></font></strong></td>
		<td width="20%" height="20" class="thinborder"><i>Stud No. &nbsp; &nbsp; <%=WI.fillTextValue("stud_id").toUpperCase()%></i></td>
	</tr>
	<tr>
		<td class="thinborderLEFT" height="20">Page No. <%=iPageNumber%></td>
	</tr>
	
</table>


<%}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td class="thinborderBOTTOM" style="text-indent:30px;" width="10%" height="25"><strong><font size="2">NAME:</font></strong></td>
		<td class="thinborderBOTTOM" valign="bottom"><strong><font size="2">
		<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, 
		<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> 
		<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></font></strong></td>
		
		<%
		strTemp = (String)vStudInfo.elementAt(16);
		if(strTemp.equals("M"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td class="thinborderBOTTOM" valign="top" width="10%">
			<input type="checkbox" disabled="disabled" <%=strErrMsg%>><font size="1">Male</font>
		<%
		strTemp = (String)vStudInfo.elementAt(16);
		if(strTemp.equals("F"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
			<br><input type="checkbox" disabled="disabled" <%=strErrMsg%>><font size="1">Female</font>
		</td>
		<td class="thinborderBOTTOM" width="13%" rowspan="4" valign="top">
			<img src="../../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt%>" width="120" height="120" border="1" align="top">
		</td>
	</tr>
	
	<tr>
		<td class="thinborderBOTTOM" height="25" style="text-indent:30px;" valign="top"><font size="1"><i><strong>Address:</strong></i></font></td>
		<td class="thinborderBOTTOM" colspan="2" valign="bottom">
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3)).toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","").toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","").toUpperCase()%>
		<%=WI.getStrValue((String)vAdditionalInfo.elementAt(7)).toUpperCase()%>
		</td>
	</tr>
	<tr>
		<td colspan="3" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="thinborderBOTTOM" width="17%" height="25" style="text-indent:30px" valign="top">
						<strong><font size="1"><i>Birthdate:</i></font></strong></td> 
					<%
						strTemp = "&nbsp;";
						if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
							strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(1));
						
					%>
					<td class="thinborderBOTTOM" width="20%" valign="bottom"><%=strTemp.toUpperCase()%></td>
					<td class="thinborderBOTTOM" width="17%" height="25" valign="top">
						<strong><font size="1"><i>Birthplace:</i></font></strong></td>
					<%
						strTemp = "&nbsp;";
						if (vAdditionalInfo != null && vAdditionalInfo.size() > 0)
							strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2));
						
					%>
					<td class="thinborderBOTTOM" valign="bottom"><%=strTemp.toUpperCase()%></td>
				</tr>
			</table>

		</td>
	</tr>
	<tr>
		<td colspan="3" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="thinborderBOTTOM" width="22%" height="25" style="text-indent:30px" valign="top">
						<strong><font size="1"><i>ACR No. / ICR No.:</i></font></strong></td>
					<td class="thinborderBOTTOM" width="28%" valign="bottom">&nbsp;</td>
					<td class="thinborderBOTTOM" width="20%" height="25" valign="top">
						<strong><font size="1"><i>Citizenship:</i></font></strong></td>
					<td class="thinborderBOTTOM" valign="bottom"><%=WI.getStrValue((String)vStudInfo.elementAt(23), "&nbsp;").toUpperCase()%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="5" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="thinborderBOTTOM" width="12%" height="25" style="text-indent:30px" valign="top">
						<strong><font size="1"><i>Parent:</i></font></strong></td>
					<td class="thinborderBOTTOM" width="60%" valign="bottom">
						<%=WI.getStrValue((String)vAdditionalInfo.elementAt(8), (String)vAdditionalInfo.elementAt(9)).toUpperCase()%>						
					</td>
					<td class="thinborderBOTTOM" width="10%" height="25" valign="top">
						<strong><font size="1"><i>Stud. No.:</i></font></strong></td>
					<td class="thinborderBOTTOM" valign="bottom"><%=WI.fillTextValue("stud_id").toUpperCase()%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="5" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td valign="top" align="center" width="6%" style="text-indent:15px"><font size="1">School</font></td>
					<td class="thinborder" width="15%" height="25" valign="top"><font size="1"><strong><i>Elementary:</i></strong></font></td>
					<%
						strTemp = "&nbsp;"; 
						if(vEntranceData != null)
							strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
					%>
					<td class="thinborderBOTTOM" width="37%" valign="bottom"><%=strTemp%></td>
					<td class="thinborderBOTTOM" width="7%" valign="bottom"><%=WI.getStrValue((String)vEntranceData.elementAt(20),"- ","","&nbsp;")%></td>
					<td class="thinborderBOTTOM" width="15%" valign="top"><strong><font size="1"><i>Title/Degree/Course:</i></font></strong></td>
					<td class="thinborderBOTTOM" valign="bottom"><%=WI.getStrValue((String)vStudInfo.elementAt(24),"&nbsp;").toUpperCase()%></td>
				</tr>
				<tr>
					<td valign="top" align="center" style="text-indent:15px"><font size="1">and</font></td>
					<td class="thinborder" height="25" valign="top"><font size="1"><strong><i>Secondary:</i></strong></font></td>
					<td class="thinborderBOTTOM" valign="bottom"><%=WI.getStrValue((String)vEntranceData.elementAt(5),"&nbsp;")%></td>
					<td class="thinborderBOTTOM" valign="bottom"><%=WI.getStrValue((String)vEntranceData.elementAt(22),"- ","","&nbsp;")%></td>
					<td class="thinborderBOTTOM" valign="top"><strong><font size="1"><i>Majors:</i></font></strong></td>
					<td class="thinborderBOTTOM" valign="bottom"><%=WI.getStrValue((String)vStudInfo.elementAt(25),"&nbsp;")%></td>
				</tr>
				<tr>
					<td class="thinborderBOTTOM" valign="top" align="center" style="text-indent:15px"><font size="1">Year</font></td>
					<td class="thinborder" height="25" valign="top"><font size="1"><strong><i>College:</i></strong></font></td>
					<td class="thinborderBOTTOM" valign="bottom"><%=WI.getStrValue((String)vEntranceData.elementAt(7),"&nbsp;")%></td>
					<td class="thinborderBOTTOM" valign="bottom">&nbsp;<%//=WI.getStrValue((String)vEntranceData.elementAt(21),"&nbsp;")%> </td>
					<td class="thinborderBOTTOM" valign="top"><strong><font size="1"><i>Date Graduated:</i></font></strong></td>
					<%if(vGraduationData != null)
						strTemp = WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
					  else
						strTemp = "&nbsp;";				  
					%>
					<td class="thinborderBOTTOM" valign="bottom"><%=strTemp%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top" colspan="5">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<td class="" height="25" valign="top" width="15%" style="text-indent:23px;">
					<strong><font size="1"><i>Date Admitted:</i></font></strong></td>
				<td class="" valign="bottom" width="20%">
					<% if(vEntranceData != null) {%>
						<%=WI.getStrValue((String)vEntranceData.elementAt(23),"&nbsp;")%> 
					<%}else{%> &nbsp; <%}%></td>
				<td class="" height="25" valign="top" width="10%">
					<strong><font size="1"><i>Credentials:</i></font></strong></td>
					<%strTemp = WI.fillTextValue("entrance_data");%> 
					
				<td class="" valign="bottom" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%> </td>	
				<td class="" height="25" valign="top" width="17%">
					<strong><font size="1"><i>S.O. No. / Series:</i></font></strong></td>
				<%
				if(vGraduationData != null && vGraduationData.size()!=0)
					strTemp = WI.getStrValue(vGraduationData.elementAt(6));
				else	
					strTemp = "&nbsp;";
				%>
				<td class="" valign="bottom"><%=strTemp.toUpperCase()%></td>
			</table>
		</td>
	</tr>
</table>
<%}
}//end vAdditionalInfo




if(vRetResult != null && vRetResult.size() > 0){
	if(iPageNumber != 1)
		strTemp = "930px";	//long bondpaper	
	else	
		strTemp = "730px";
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td width="100%" height="<%=strTemp%>" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				  <tr>
					<td rowspan="2"><strong>COURSE NO</strong></td>
					<td rowspan="2"><strong>DESCRIPTIVE TITLE</strong></td>
					<td colspan="3" align="center" class="thinborder"><strong>RATING</strong></td>
					<td colspan="80" align="center" class="thinborder"><strong>DISTRIBUTION BY GROUP</strong></td>
				  </tr>
				  <tr>    
					<td width="5%" class="thinborder" align="center"><strong>Final</strong></td>
					<td width="5%" class="thinborder" align="center"><strong>Comp.</strong></td>
					<td width="5%" class="thinborder" align="center"><strong>Credit</strong></td>    
					<td width="4%" class="thinborder" align="center"><strong>1</strong></td>
					<td width="4%" class="thinborder" align="center"><strong>2</strong></td>
					<td width="4%" class="thinborder" align="center"><strong>3</strong></td>
					<td width="4%" class="thinborder" align="center"><strong>4</strong></td>
					<td width="4%" class="thinborder" align="center"><strong>5</strong></td>
					<td width="4%" class="thinborder" align="center"><strong>6</strong></td>
					<td width="4%" class="thinborder" align="center"><strong>7</strong></td>
					<td width="4%" class="thinborder" align="center"><strong>8</strong></td>
					<td width="4%" class="thinborder" align="center"><strong>9</strong></td>
					<td width="3%" class="thinborder" align="center"><strong>10</strong></td>
					<%for(int j = 0; j < iAddlGroup; ++j) {%>
					<td width="3%" class="thinborder" align="center"><div align="center"><strong><%=(10 + j + 1)%></strong></div></td>
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
				String[] astrConvertSem = {"SUMMER","First Semester","Second Semester","Third Semester","Fourth Semester"};
				
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
						strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+", "+
									(String)vRetResult.elementAt(i+ 1)+"-"+(String)vRetResult.elementAt(i+ 2);
					}
					else {
						strCurSYSem = (String)vRetResult.elementAt(i+ 3)+", "+(String)vRetResult.elementAt(i+ 1)+"-"+
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
				  
				  
				if(strSchNameToDisp != null && (i ==  0 || (strPrevSchName != null && !strPrevSchName.equals(strSchNameToDisp)))){
					//if (strHideRowLHS == null || strHideRowLHS.length() == 0) 
					//	++iRowsPrinted;
					%>
				  <tr>
					<td>&nbsp;</td>
					<td height="20"><strong><u><%=strSchNameToDisp.toUpperCase()%></u></strong></td>
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
				<%strPrevSchName = strSchNameToDisp; } %> 
				  
				  
				  
				  
				  
				  
				  
				  
				
				<%if(strSYSemToDisp != null){%>
				  <tr>
					<td>&nbsp;</td>					
					<td height="20"><strong><u><%=strSYSemToDisp%></u></strong></td>
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
					<td width="10%" height="20" class=""><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
					<td width="30%"><%=vRetResult.elementAt(i + 7)%></td>
					<td class="thinborderLEFT" align="center"> 
						<%
							if(bolReExam) 
								strTemp = (String) vRetResult.elementAt(i - 11 + 8);
							else 
								strTemp = (String)vRetResult.elementAt(i + 8);%> 
							<%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true), "&nbsp;")%></td>
					<td class="thinborderLEFT" align="center">&nbsp; 
						<%if(bolReExam) {%> 
							<%=WI.getStrValue(CommonUtil.formatFloat((String)vRetResult.elementAt(i + 8),true), "&nbsp;")%> 
						<%}%></td>
						<%
						if (WI.getStrValue(strTemp).startsWith("on")) 
							strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"(",")","&nbsp;");
					  	else 
							strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9),"&nbsp;");%>
					<td class="thinborderLEFT" align="center">&nbsp;<%=strTemp%></td>
					
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
					<td width="3%" class="thinborderLEFT" align="center">&nbsp;
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
					<td height="20" colspan="2" class="thinborderBOTTOM"><div align="center"><strong>Total Units Submitted for Graduation</strong></div></td>
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
				  
				 <%}else{%>
				 	<tr>
						<td>&nbsp;</td>
						<td><strong><font size="1"><i>( continued on page <%=iPageNumber+1%>)</i></font></strong></td>
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
				 <%}%>
				</table>
		</td>
	</tr>
	<tr>
		<td width="100%" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="thinborderTOPBOTTOM" width="12%" height="20"><strong><i><font size="1">REMARKS:</font></i></strong></td>
					<td class="thinborderTOPBOTTOM"><%=WI.getStrValue(WI.fillTextValue("notes"),"&nbsp;")%></td>
					<td class="thinborderTOPLEFTBOTTOM" width="17%"><font size="1"><i>Prepared By:</i></font></td>
					<td class="thinborderTOPBOTTOM" width="17%"><font size="1"><i>Checked By:</i></font></td>
				</tr>
				<tr>
					<td class="thinborderBOTTOM" height="20"><strong><i><font size="1">PURPOSE</font></i></strong></td>
					<td class="thinborderBOTTOM">&nbsp;</td>
					<td class="thinborderLEFTBOTTOM" align="center"><%=WI.fillTextValue("prep_by1").toUpperCase()%></td>
					<td class="thinborderBOTTOM" align="center"><%=WI.fillTextValue("check_by1").toUpperCase()%></td>
				</tr>
				<tr>
					<td class="thinborderBOTTOM" height="20"><strong><i><font size="1">T / R Sent to:</font></i></strong></td>
					<td class="thinborderBOTTOM">&nbsp;</td>
					<td class="thinborderLEFTBOTTOM" colspan="2"><font size="1"><i>Date Issued</i></font> &nbsp; &nbsp; <i><%=WI.getTodaysDate(6)%></i></td>
				</tr>
				
				<tr>
					<td colspan="2">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td colspan="6" height="28"><strong>GRADING SYSTEM</strong></td></tr>
							<tr>
								<td height="17"><font size="1"><i>95-100</i></font></td>
								<td><font size="1"><i>Excellent</i></font></td>
								<td><font size="1"><i>80-84</i></font></td>
								<td><font size="1"><i>Satisfactory</i></font></td>
								<td><font size="1"><i>INC</i></font></td>
								<td><font size="1"><i>Incomplete</i></font></td>
							</tr>
							<tr>
								<td height="17"><font size="1"><i>90-94</i></font></td>
								<td><font size="1"><i>Very Good</i></font></td>
								<td><font size="1"><i>75-79</i></font></td>
								<td><font size="1"><i>Fair</i></font></td>
								<td><font size="1"><i>DRP</i></font></td>
								<td><font size="1"><i>Dropped</i></font></td>
							</tr>	
							<tr>
								<td height="17"><font size="1"><i>85-89</i></font></td>
								<td><font size="1"><i>Good</i></font></td>
								<td><font size="1"><i>74-Below</i></font></td>
								<td><font size="1"><i>Failure</i></font></td>
								<td><font size="1"><i>OW/UW</i></font></td>
								<td><font size="1"><i>Officially/Unofficially Withdrawn</i></font></td>
							</tr>
							<tr><td class="thinborderBOTTOM" colspan="6">
							<font size="1"><i>One Unit of Credit is One Hour Lecture or Three Hours Laboratory each week</i></font></td></tr>				
						</table>
					</td>
					
					<td colspan="2" valign="top" class="thinborderLEFTBOTTOM">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td height="50" align="center" valign="bottom"><strong>FR. NOEL P. COGASA, O.S.A.</strong></td></tr>
							<tr><td height="25" valign="top" align="center"><font size="1"><strong>REGISTRAR</strong></font></td></tr>
							<tr><td align="center"><i><font size="1">Not Valid Without College Seal</font></i></td></tr>
						</table>
					</td>
				</tr>
				
				</table>
		</td>
	</tr>

</table>





















<%
}//end if vRetResult != null && vRetResult.size() > 0






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
