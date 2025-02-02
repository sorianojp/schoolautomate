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
    TD.thinborderLEFTTOPBOTTOM {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>

<body>
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
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Registrar Management","OTR-GRAD",request.getRemoteAddr(),
															null);
}
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

if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else {
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
	}
	//I have to get the subject group information as well. 
	if(strErrMsg == null) {
		vSubGroupInfo = repRegistrar.getRecordsOfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType);
		if(vSubGroupInfo == null)
			strErrMsg = repRegistrar.getErrMsg();
	}
}	
String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolCode = dbOP.getSchoolIndex();

%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="19"><div align="center"> 
        <p align="right"><%if(strSchoolCode.startsWith("VMUF")){%>
		VMUF Form 17<%}%></div></td>
  </tr>
  <tr>
    <td height="83"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,true)%><br>
        <strong> OFFICIAL TRANSCRIPT OF RECORDS OF CANDIDATE FOR 
        GRADUATION</strong></font></div></td>
  </tr>
</table>
<%
if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><font size="3"><%=strErrMsg%></font>
		</td>
	</tr>
</table>
<%dbOP.cleanUP();return;}%>

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
    <td width="20%" height="20" ><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></strong></td>
    <td width="29%" height="20" ><strong><%=((String)vStudInfo.elementAt(0)).toUpperCase()%></strong></td>
    <td width="40%" height="20" ><strong><%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20" valign="top" >(Last Name)</td>
    <td height="20" valign="top" >(First Name)</td>
    <td height="20" valign="top" >(Middle Name)</td>
  </tr>
  <tr> 
    <td height="20">Date of Birth :</td>
    <td height="20" ><strong><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></strong></td>
    <td height="20" >Place of Birth : <strong><%=WI.getStrValue(vAdditionalInfo.elementAt(2))%></strong></td>
    <td height="20" >Gender : <strong><%=WI.getStrValue(vAdditionalInfo.elementAt(0))%></strong></td>
  </tr>
  <tr> 
    <td height="20" colspan="4">Address : <strong><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","")%> </strong> </td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="20" colspan="5">Preliminary Education</td>
    <td width="41%" height="20">School Year</td>
  </tr>
  <tr> 
    <td width="11%" height="20">&nbsp;</td>
    <td width="10%" height="20">Primary</td>
    <td height="20" colspan="3"><strong><%=WI.getStrValue(vEntranceData.elementAt(14))%></strong></td>
    <td height="20"><strong><%=WI.getStrValue(vEntranceData.elementAt(17)) +" - "+
	  	WI.getStrValue(vEntranceData.elementAt(18))%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20">Intermediate</td>
    <td height="20" colspan="3"><strong><%=WI.getStrValue(vEntranceData.elementAt(16))%></strong></td>
    <td height="20"><strong><%=WI.getStrValue(vEntranceData.elementAt(19)) +" - "+
	  WI.getStrValue(vEntranceData.elementAt(20))%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20">Secondary</td>
    <td height="20" colspan="3"><strong><%=WI.getStrValue(vEntranceData.elementAt(5))%></strong></td>
    <td height="20"><strong><%=WI.getStrValue(vEntranceData.elementAt(21)) +" - "+
	  WI.getStrValue(vEntranceData.elementAt(22))%></strong></td>
  </tr>
  <tr> 
    <td height="20" colspan="6">Admission Credentials </td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20" colspan="3">1.) <%=WI.fillTextValue("adm_cre1")%></td>
    <td height="20" colspan="2">2.) <%=WI.fillTextValue("adm_cre2")%></td>
  </tr>
  <tr valign="bottom"> 
    <td height="20" colspan="6">Candidate for the Title/Degree: <strong><%=(String)vStudInfo.elementAt(7)%></strong></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td width="21%" height="20">&nbsp;</td>
    <td height="20" colspan="2" valign="bottom">Major: <strong><%=WI.getStrValue(vStudInfo.elementAt(8))%></strong></td>
    <td width="22%" height="20" colspan="2" valign="bottom">Minor </td>
  </tr>
</table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<!--<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#E2E2E2" class="thinborder">
  <tr> 
    <td width="39%" class="thinborder"><div align="center"><strong>SUBJECTS</strong></div></td>
    <td width="5%" class="thinborder"><div align="center"><strong>Final Grade</strong></div></td>
    <td width="5%" class="thinborder"><div align="center"><strong>Units Earned</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>1</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>2</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>3</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>4</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>5</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>6</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>7</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>8</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>9</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>10</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>11</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>12</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>13</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>14</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>15</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>16</strong></div></td>
    <td width="3%" class="thinborder"><div align="center"><strong>17</strong></div></td>
  </tr>
</table>-->
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#E2E2E2"> 
    <td width="39%" class="thinborderLEFTTOPBOTTOM" colspan="2"><div align="center"><strong>SUBJECTS</strong></div></td>
    <td width="5%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>Final Grade</strong></div></td>
    <td width="5%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>Units Earned</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>1</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>2</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>3</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>4</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>5</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>6</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>7</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>8</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>9</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>10</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>11</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>12</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>13</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>14</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>15</strong></div></td>
    <td width="3%" class="thinborderLEFTTOPBOTTOM"><div align="center"><strong>16</strong></div></td>
    <td width="3%" class="thinborderALL"><div align="center"><strong>17</strong></div></td>
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

String strFinalGrade = null;//it is on going for UI and for VMU, In progress.


String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;
for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
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

//get here index of group . 
iIndexOfSubGroup = vSubGroupInfo.indexOf(vRetResult.elementAt(i+ 10));
iIndexOfSubGroup = iIndexOfSubGroup/2 + 1;

 //Very important here, it print <!-- if it is not to be shown. 
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowLHS%> 
  <%}
		
if(strSchNameToDisp != null){%>
  <tr> 
    <td height="20" colspan="2" class="thinborderLEFT"><%=strSchNameToDisp.toUpperCase()%></td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFTRIGHT">&nbsp;</td>
  </tr>
  <%strSchNameToDisp = null;}

if(strSYSemToDisp != null){%>
  <tr> 
    <td height="20" colspan="2" class="thinborderLEFT"><strong><%=strSYSemToDisp%></strong></td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFT">&nbsp;</td>
    <td height="20" class="thinborderLEFTRIGHT">&nbsp;</td>
  </tr>
  <%}
  
  strFinalGrade = WI.getStrValue(vRetResult.elementAt(i + 8));
  if(strFinalGrade.startsWith("on"))
  	strFinalGrade = "In Progress";
%>
  <tr> 
    <td width="15%" height="20" class="thinborderLEFT"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td width="24%"><%=vRetResult.elementAt(i + 7)%></td>
    <td width="5%" class="thinborderLEFT"><%=WI.getStrValue(strFinalGrade, "&nbsp;")%></td>
    <td width="5%" class="thinborderLEFT">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 9))%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 1){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 2){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 3){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 4){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 5){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 6){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 7){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 8){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 9){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 10){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 11){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 12){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 13){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 14){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 15){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFT">&nbsp; <%if(iIndexOfSubGroup == 16){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
    <td width="3%" class="thinborderLEFTRIGHT">&nbsp; <%if(iIndexOfSubGroup == 17){%> <%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%> <%}%></td>
  </tr>
  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop 
   %>
</table>

 <%if(iLastPage ==1){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E5E5E5">
  <tr> 
    <td height="15" colspan="21" align="center" class="thinborderTOP" valign="bottom">xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
      END OF PRINTING xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</td>
  </tr>
  <tr> 
    <td height="10" colspan="21" align="center">&nbsp;</td>
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
<%}if(iLastPage == 1){ //it is last page, show the last page content%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td width="79%" height="204" valign="top">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderALL">
        <tr> 
          <td width="21%" height="206"> 
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#E5E5E5">
              <tr> 
                <td width="52%" height="123" valign="top"><div align="left"><font size="1">Percentage</font></div>
                  <div align="left"><font size="1">98 - 100</font></div>
                  <div align="left"><font size="1">95 - 97</font></div>
                  <div align="left"><font size="1">92 - 94</font></div>
                  <div align="left"><font size="1">89 - 91</font></div>
                  <div align="left"><font size="1">86 - 88</font></div>
                  <div align="left"><font size="1">83 - 85</font></div>
                  <div align="left"><font size="1">80 - 82</font></div>
                  <div align="left"><font size="1">78 - 79</font></div>
                  <div align="left"><font size="1">75 - 77<br>
                    Below 75<br>
                    DR =Dropped<br>
                    INC = Incomplete </font></div></td>
                <td width="48%" valign="top"><div align="left"><font size="1">Numerical</font></div>
                  <div align="left"><font size="1">1.0</font></div>
                  <div align="left"><font size="1">1.25</font></div>
                  <div align="left"><font size="1">1.5</font></div>
                  <div align="left"><font size="1">1.75</font></div>
                  <div align="left"><font size="1">2.0</font></div>
                  <div align="left"><font size="1">2.25</font></div>
                  <div align="left"><font size="1">2.5</font></div>
                  <div align="left"><font size="1">2.75</font></div>
                  <div align="left"><font size="1">3.0<br>
                    Failed<br>
                    Must repeat<br>
                    Must repeat
                    </font></div></td>
              </tr>
            </table></td>
          <td width="79%" valign="top">REMARKS : <u>-Last sheet -</u><br>
            <br>
            CERTIFICATION : <br>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We 
            hereby certify that the foregoing records of <u><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
			<%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase().charAt(0)%>.</u> 
            a candidate for graduation, have been verified by and that true copies 
            are kept in the files of our college.
            <br>
            <br> 
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr> 
                <td width="12%" height="16">Prepared by : </td>
                <td width="36%" height="16"> <%=WI.getStrValue(WI.fillTextValue("prep_by1"))%></td>
                <td width="11%" height="16">Checked by: </td>
                <td width="41%" height="16"><%=WI.getStrValue(WI.fillTextValue("check_by1"))%></td>
              </tr>
<%
if(WI.fillTextValue("prep_by2").length() > 0 || WI.fillTextValue("prep_by2").length() > 0){%>               
			  <tr> 
                <td height="15">&nbsp;</td>
                <td height="15"><%=WI.getStrValue(WI.fillTextValue("prep_by2"))%></td>
                <td height="15">&nbsp;</td>
                <td height="15"><%=WI.getStrValue(WI.fillTextValue("check_by2"))%></td>
              </tr>
<%}%>			  
              <tr>
                <td height="15">&nbsp;</td>
                <td height="15">&nbsp;</td>
                <td height="15">&nbsp;</td>
                <td height="15">&nbsp;</td>
              </tr>
              <tr> 
                <td height="15">&nbsp;</td>
                <td height="15">&nbsp;</td>
                <td height="15">&nbsp;</td>
                <td height="15">&nbsp;</td>
              </tr>
              <tr> 
                <td height="15" colspan="2"><%=WI.getStrValue(WI.fillTextValue("dean_name")).toUpperCase()%></td>
                <td height="15" colspan="2"><%=WI.getStrValue(WI.fillTextValue("accounting_division")).toUpperCase()%></td>
              </tr>
              <tr> 
                <td height="15" colspan="2"><em>Dean/Principal</em></td>
                <td height="15" colspan="2"><em>Accounting Division</em></td>
              </tr>
              <tr> 
                <td height="15" colspan="2">&nbsp;</td>
                <td height="15" colspan="2">&nbsp;</td>
              </tr>
              <tr> 
                <td height="15" colspan="2">&nbsp;</td>
                <td height="15" colspan="2"><%=WI.getStrValue(WI.fillTextValue("registrar_name")).toUpperCase()%></td>
              </tr>
              <tr> 
                <td height="15" colspan="2">&nbsp;</td>
                <td height="15" colspan="2"><em>Registrar</em></td>
              </tr>
            </table><%if(WI.fillTextValue("notes").length() > 0){%>
            <hr size="1">
            <%=WI.getStrValue(WI.fillTextValue("notes"))%><br><%}%>
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
